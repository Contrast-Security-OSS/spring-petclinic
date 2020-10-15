pipeline {
    agent {
        docker { image 'maven:3-alpine' }
    }
    stages {
        stage("DEV") {
            steps {
                sh 'echo "build"'
                sh 'echo "unit test"'
                sh '''
                echo "$PATH"
                echo "M2_HOME"
                mvn --version
                '''
                sh "mvn clean package"
            }
        }
        stage("QA") {
            steps {
                sh 'echo "deploy to QA"'
                sh 'echo "Run QA Tests"'
                sh "ls target"
            }
        }
        stage("UAT") {
            steps {
                sh 'echo "deploy to UAT"'
                sh 'echo "Run Acceptance Tests"'
            }
        }
        stage("PERF") {
            steps {
                sh 'echo "deploy to PERF"'
                sh 'echo "Run Performance Tests"'
            }
        }
        stage("PRE-PROD") {
            steps {
                sh 'echo "deploy to PRE-PROD"'
            }
        }
        stage("PROD") {
            steps {
                sh 'echo "deploy to PROD"'
                sh 'echo "Configure Load Balancers"'
                sh 'echo "Verify B"'
                sh 'echo "Drain A"'
            }
        }
        stage("OPERATE") {
            steps {
                sh 'echo "Update SIEM"'
                sh 'echo "Update AppMonitoring"'
            }
        }
    }
}
