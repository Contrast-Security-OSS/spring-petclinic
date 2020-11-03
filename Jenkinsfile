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
                withCredentials([file(credentialsId: 'teamserver_yaml', variable: 'yaml')]) {
                    sh "echo username ${yaml.api.user_name}"
                    sh "echo api_key ${yaml.api.api_key}"
                    sh "echo apiUrl ${yaml.api.apiUrl}"
                    sh "echo orgUuid ${yaml.api.orgUuid}"
                    echo "mvn -P contrast-maven  -Dcontrast-username=\"${yaml.api.user_name}\" -Dcontrast-apiKey=${yaml.api.api_key} -Dcontrast-serviceKey=${yaml.api.user_name} -Dcontrast-apiUrl=\"${yaml.api.url}\" -Dcontrast-orgUuid=${jenkins.orgUuid} clean verify"
                }
            }
        }
        stage("QA") {
            steps {
                sh 'echo "deploy to QA"'
                sh 'echo "Run QA Tests"'
                sh "ls target"
                sh """
                FILE=/usr/bin/terraform
                if [ -f "\$FILE" ]; then
                    echo "\$FILE exists, skipping download"
                else
                    echo "\$FILE does not exist"
                    cd /tmp
                    curl -o terraform.zip https://releases.hashicorp.com/terraform/'$terraform_version'/terraform_'$terraform_version'_linux_amd64.zip
                    unzip -o terraform.zip
                    sudo mv terraform /usr/binex
                    rm -rf terraform.zip
                fi
                """
                script {
                    withCredentials([file(credentialsId: env.contrast_yaml, variable: 'path')]) {
                        def contents = readFile(env.path)
                        writeFile file: 'contrast_security.yaml', text: "$contents"
                    }
                }
                sh """
                terraform init
                npm i puppeteer
                """
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
