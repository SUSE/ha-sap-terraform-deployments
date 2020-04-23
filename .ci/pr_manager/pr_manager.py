#!/usr/bin/env python3

import argparse
import configparser
import os
import sys

from github import Github

from pr_checks import PrChecks
from pr_merge import PrMerge
from pr_status import PrStatus

CHANGE_ID = os.getenv('CHANGE_ID')
CHANGE_AUTHOR = os.getenv('CHANGE_AUTHOR')
GITHUB_ORG = 'SUSE'
GITHUB_REPO = f'{GITHUB_ORG}/skuba'
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
JENKINS_CONFIG = configparser.ConfigParser()

if GITHUB_TOKEN is None:
    print('Env var GITHUB_TOKEN missing please set it')
    sys.exit(1)
else:
    # Make sure to only grab the token
    GITHUB_TOKEN = GITHUB_TOKEN.split(':')[-1]

if CHANGE_ID is not None:
    CHANGE_ID = int(CHANGE_ID)


def _read_config(config_path):
    if config_path is None:
        print('No config provided please set JENKINS_CONFIG or use the --config arg')
    JENKINS_CONFIG.read(config_path)


def check_pr(args):
    if CHANGE_ID:
        g = Github(GITHUB_TOKEN)
        org = g.get_organization(GITHUB_ORG)
        repo = g.get_repo(GITHUB_REPO)

        pr_checks = PrChecks(org, repo)

        if args.is_fork:
            pr_checks.check_pr_from_fork(CHANGE_ID)
        if args.check_pr_details:
            pr_checks.check_pr_details(CHANGE_ID)
        if args.collab_check:
            pr_checks.check_pr_from_collaborator(CHANGE_AUTHOR)
    else:
        print('No CHANGE_ID was set assuming this is not a PR. Skipping checks...')


def filter_pr(args):
    if CHANGE_ID:
        g = Github(GITHUB_TOKEN, per_page=1000)
        repo = g.get_repo(GITHUB_REPO)

        pull = repo.get_pull(CHANGE_ID)
        files_list = [f.filename for f in pull.get_files()]

        if any([s for s in files_list if args.filename in s]):
            msg = "contains"
        else:
            msg = "does not contain"

        print(f"Pull Request {GITHUB_REPO}#{CHANGE_ID} {msg} changes for {args.filename}")
    else:
        print('No CHANGE_ID was set assuming this is not a PR. Skipping filters...')


def merge_prs(args):
    if args.config:
        _read_config(args.config)
    else:
        _read_config(os.getenv('JENKINS_CONFIG'))

    g = Github(GITHUB_TOKEN)
    repo = g.get_repo(GITHUB_REPO)

    merger = PrMerge(JENKINS_CONFIG, repo)
    merger.merge_prs()


def update_pr_status(args):
    build_url = os.getenv('BUILD_URL')
    if build_url is None:
        print('Env var BUILD_URL missing please set it')
        sys.exit(1)

    g = Github(GITHUB_TOKEN)
    repo = g.get_repo(GITHUB_REPO)

    status = PrStatus(build_url, repo)
    status.update_pr_status(args.commit_sha, args.context, args.state)


def parse_args():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    # Parse check-pr command
    checks_parser = subparsers.add_parser('check-pr', help='Check to make sure the PR meets certain standards')
    checks_parser.add_argument('--is-fork', action='store_true')
    checks_parser.add_argument('--check-pr-details', action='store_true')
    checks_parser.add_argument('--collab-check', action='store_true')
    checks_parser.set_defaults(func=check_pr)

    # Parse merge-prs command
    merge_parser = subparsers.add_parser('merge-prs', help='Look for and merge a Pull Request')
    merge_parser.add_argument('--config', help='Path to ini config for interacting with Jenkins')
    merge_parser.set_defaults(func=merge_prs)

    # Parse update-pr-status command
    update_status_parser = subparsers.add_parser('update-pr-status', help='Update the status of a Pull Request')
    update_status_parser.add_argument('commit_sha')
    update_status_parser.add_argument('context')
    update_status_parser.add_argument('state', choices=['error', 'failure', 'pending', 'success'])
    update_status_parser.set_defaults(func=update_pr_status)

    # Parse filter-pr command
    filter_parser = subparsers.add_parser('filter-pr', help='Filter Pull Request by a file/pathname')
    filter_parser.add_argument('--filename', help='Name of the path or File to filter')
    filter_parser.set_defaults(func=filter_pr)

    parsed_args = parser.parse_args()

    return parsed_args


if __name__ == '__main__':
    args = parse_args()
    args.func(args)
