/**
 * Run haboostrap formula in ci
 */

pipeline {
    agent { node { label 'sles-sap' } }

    environment {
        PR_MANAGER = 'ci/pr-manager'
    }

    stages {
       stage('Git Clone') { steps {
            deleteDir()
            checkout([$class: 'GitSCM',
                      branches: [[name: "*/${BRANCH_NAME}"]],
                      doGenerateSubmoduleConfigurations: false,
                      extensions: [[$class: 'LocalBranch'],
                                   [$class: 'WipeWorkspace'],
                                   [$class: 'RelativeTargetDirectory', relativeTargetDir: 'skuba']],
                      submoduleCfg: [],
                      userRemoteConfigs: [[refspec: '+refs/pull/*/head:refs/remotes/origin/PR-*',
                                           credentialsId: 'github-token',
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
