class PrStatus:
    def __init__(self, build_url, repo):
        self.build_url = build_url
        self.repo = repo

    def _create_pr_status(self, commit_sha, context, description, state):
        commit = self.repo.get_commit(sha=commit_sha)
        commit.create_status(state=state,
                             target_url=f'{self.build_url}display/redirect',
                             description=description,
                             context=context)

    def update_pr_status(self, commit_sha, context, state):
        if state == 'error':
            self._create_pr_status(commit_sha, context, 'error', state)
        elif state == 'failure':
            self._create_pr_status(commit_sha, context, 'failed', state)
        elif state == 'pending':
            self._create_pr_status(commit_sha, context, 'in-progress', state)
        elif state == 'success':
            self._create_pr_status(commit_sha, context, 'success', state)
        else:
            raise Exception('Unknown state')
