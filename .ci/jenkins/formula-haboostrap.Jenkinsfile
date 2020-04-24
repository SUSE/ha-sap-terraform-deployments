/**
 * Run haboostrap formula in ci
 */

pipeline {
    agent { node { label 'caasp-team-private-integration' } }

    environment {
        PR_MANAGER = 'ci/pr-manager'
        GITHUB_TOKEN = credentials('github-token')
    }

    stages {
      stage('Git Clone') { steps {
            deleteDir()
            checkout([$class: 'GitSCM',
                      branches: [[name: "*/${env.BRANCH}"]],
                      doGenerateSubmoduleConfigurations: false,
                      extensions: [[$class: 'LocalBranch'],
                                   [$class: 'WipeWorkspace'],
                                   [$class: 'RelativeTargetDirectory', relativeTargetDir: 'skuba'],
                                   [$class: 'ChangelogToBranch', options: [compareRemote: "origin", compareTarget: "master"]]],
                      submoduleCfg: [],
                      userRemoteConfigs: [[refspec: '+refs/pull/*/head:refs/remotes/origin/PR-*',
                                           credentialsId: "${env.GITHUB_TOKEN}",
                                           url: 'https://github.com/SUSE/skuba']]])
        }}
        stage('Setting GitHub in-progress status') { steps {
            sh(script: "ls")
            sh(script: "${PR_MANAGER} update-pr-status ${GIT_COMMIT} ${PR_CONTEXT} 'pending'", label: "Sending pending status")
           } 
        }

        stage('Initialize terraform') { steps {
              sh(script: 'echo terraform init')
           } 
        }

        stage('Apply terraform') {
            steps {
                sh(script: 'echo terraform apply')
            }
        }
    }
    post {
        always {
            sh(script: "echo destroy terraform")
        }
        cleanup {
            dir("${WORKSPACE}@tmp") {
                deleteDir()
            }
            dir("${WORKSPACE}@script") {
                deleteDir()
            }
            dir("${WORKSPACE}@script@tmp") {
                deleteDir()
            }
            dir("${WORKSPACE}") {
                deleteDir()
            }
        }
    }
}
