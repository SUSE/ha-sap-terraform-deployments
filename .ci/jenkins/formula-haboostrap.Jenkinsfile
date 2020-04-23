/**
 * Run haboostrap formula in ci
 */

pipeline {
    agent { node { label 'sles-sap' } }

    environment {
        PR_MANAGER = 'ci/pr-manager'
    }

    stages {

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
