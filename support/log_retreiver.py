"""
Support tool to retrieve the execution logs to the local machine

:author: xarbulu
:organization: SUSE LLC
:contact: xarbulu@suse.com

:since: 2020-05-22
"""

import os
import argparse
import subprocess
import shutil
import shlex
import json
import logging
import pprint


DESCRIPTION = """This tool provides the option to download the logs generated during the \
deployment from all of the machines in paralell and store them in a folder so they can be debugged
and shared easily"""

OUTPUT_NAMES = {
    "cluster_nodes_public_ip": "hana",
    "drbd_public_ip": "drbd",
    "netweaver_nodes_public_ip": "netweaver",
    "iscsisrv_public_ip": "iscsi",
    "monitoring_public_ip": "monitoring"
}

LOG_LIST = [
    "/var/log/provisioning.log",
    "/var/log/salt-predeployment.log",
    "/var/log/salt-os-setup.log",
    "/var/log/salt-deployment.log",
    "/var/log/ha-cluster-bootstrap.log"
]

LOGGER = logging.getLogger(__name__)


def parse_arguments():
    """
    Parse command line arguments
    """
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument(
        "-v", "--verbosity", default="INFO", choices=["DEBUG", "INFO", "WARN", "ERROR"],
        help="Python logging level")
    parser.add_argument(
        "-p", "--provider", choices=["aws", "azure", "gcp", "libvirt"], required=True,
        help="The provider to get the logs from")
    parser.add_argument(
        "-w", "--workspace",
        help="Get the logs for a specific workspace")
    parser.add_argument(
        "-u", "--user", default="root",
        help="User used to create the scp connection")
    parser.add_argument(
        "-i", "--identity",
        help="Path to a SSH private key used to connect to the created machines")
    parser.add_argument(
        "-o", "--output-dir",
        help="Folder where the logs will be stored")

    args = parser.parse_args()
    return parser, args


def sanity_check(args):
    """
    Test if the used tools are available in the system
    """
    # Check terraform is available
    if not shutil.which("terraform"):
        LOGGER.error("terraform is not available in the system")
        exit(1)
    # Check scp is available. For windows WinScp must be installed
    if not shutil.which("scp"):
        LOGGER.error(
            "scp is not available in the system. In windows systems pscp must be installed. \
            Here some help on how to configure it: https://itekblog.com/how-to-scp-from-windows/")
        exit(1)
    if args.provider in ["aws", "azure", "gcp"] and not args.identity:
        LOGGER.error("identity flag (-i) must be provided if the provider is [aws, azure, gcp]")
        exit(1)


def get_current_workspace(provider):
    """
    Get the current workspace
    """
    current_path = os.path.dirname(os.path.realpath(__file__))
    terraform_path = os.path.join(current_path, "..", provider)
    cmd = "terraform workspace show"
    LOGGER.debug(cmd)
    proc = subprocess.Popen(
        shlex.split(cmd), cwd=terraform_path,
        stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate()
    LOGGER.debug(out)
    LOGGER.debug(err)
    workspace = out.decode().strip()
    LOGGER.info("Terraform workspace: %s", workspace)
    return workspace


def get_terraform_output(provider, workspace):
    """
    Get terraform output data
    """
    current_path = os.path.dirname(os.path.realpath(__file__))
    terraform_path = os.path.join(current_path, "..", provider)
    if workspace == "default":
        state_path = "./terraform.tfstate"
    else:
        state_path = "./terraform.tfstate.d/{}/terraform.tfstate".format(workspace)

    cmd = "terraform output -state={} -no-color -json".format(state_path)
    LOGGER.debug(cmd)
    proc = subprocess.Popen(
        shlex.split(cmd), cwd=terraform_path,
        stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate()
    out_json = json.loads(out.decode())
    LOGGER.debug(pprint.pformat(out_json))
    LOGGER.debug(err)
    return out_json


def retrieve_logs(
        provider, workspace, user, addresses, folder_prefix, identity=None, output_dir=None):
    """
    Retrieve logs from addresses
    """
    if not output_dir:
        output_dir = os.path.dirname(os.path.realpath(__file__))
    if identity:
        identity_str = "-i {}".format(identity)

    logfiles = " ".join(LOG_LIST)
    for index, address in enumerate(addresses, 1):
        local_folder = os.path.join(
            output_dir, provider, workspace, "{}-{}".format(folder_prefix, index))
        os.makedirs(local_folder, exist_ok=True)
        LOGGER.info("Retrieving logs from %s (to %s)", address, local_folder)
        cmd = "scp -T -o StrictHostKeyChecking=no {identity}{user}@{address}:\"{logfiles}\" "\
            "{local_folder}".format(
                identity="-i {} ".format(identity) if identity else "",
                user=user, address=address, logfiles=logfiles, local_folder=local_folder)
        LOGGER.debug(cmd)
        proc = subprocess.Popen(
            shlex.split(cmd),
            stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate()
        LOGGER.debug(out)
        LOGGER.debug(err)


def main():
    """
    Main method
    """
    parser, args = parse_arguments()
    logging.basicConfig(level=args.verbosity)
    sanity_check(args)
    workspace = args.workspace or get_current_workspace(args.provider)
    output = get_terraform_output(args.provider, workspace)

    for output_name in OUTPUT_NAMES:
        output_data = output.get(output_name, None)
        if output_data and output_data['value']:
            if isinstance(output_data['value'], str):
                data = [output_data['value']]
            else:
                data = output_data['value']
            retrieve_logs(
                args.provider, workspace, args.user,
                data, OUTPUT_NAMES[output_name],
                args.identity, args.output_dir)


if __name__ == "__main__":
    main()
