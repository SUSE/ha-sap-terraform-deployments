"""
Count salt states that are executed during the predeployment and deployment
"""

import logging
import subprocess
import shlex
import json

LOWSTATE_CMD = "salt-call --local -l quiet --no-color state.show_lowstate saltenv={saltenv} --out=json"
LOWSTATE_SLS_CMD = "salt-call --local -l quiet --no-color state.show_low_sls {state_path} saltenv={saltenv} --out=json"

SALTENVS = ["predeployment", "base"]

LOGGER = logging.getLogger(__name__)


def execute_command(cmd):
    """
    Execute command and return output
    """
    LOGGER.debug("Executing command: %s", cmd)
    proc = subprocess.Popen(
        shlex.split(cmd),
        stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE)

    out, err = proc.communicate()
    return json.loads(out)

def count_inner_states(saltenv, states):
    """
    Count inner states show_low_sls
    """
    state_count = 0
    for state in states["local"]:
        if "state.sls" in state and state["state"] == "module":
            LOGGER.debug("Inner state found: %s", state["name"])
            mods = state["state.sls"][0]["mods"]
            for mod in mods:
                cmd = LOWSTATE_SLS_CMD.format(state_path=mod, saltenv=saltenv)
                state_data = execute_command(cmd)
                state_count += len(state_data["local"])
                state_count += count_inner_states(saltenv, state_data)
            LOGGER.debug("States count: %d", state_count)
    return state_count


def main():
    """
    Main method
    """
    state_count = 0
    for saltenv in SALTENVS:
        cmd = LOWSTATE_CMD.format(saltenv=saltenv)
        state_data = execute_command(cmd)
        current_state_count = len(state_data["local"])
        LOGGER.debug("States count: %d", current_state_count)
        state_count += current_state_count
        state_count += count_inner_states(saltenv, state_data)
    LOGGER.debug("Planned states count: %d", state_count)
    return state_count


if __name__ == "__main__":
    logging.basicConfig(level="INFO")
    state_count = main()
    print("Total planned states count:", state_count)
