pipeline {
    agent any
    stages {
        stage('Build') {
            steps  {
              sh 'docker build -t infinte .'
            }
        }
        stage('Trivy') {
            steps  {
              sh 'wget https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb'
              sh 'sudo dpkg -iS trivy_0.18.3_Linux-64bit.deb'  
            }
        }
    }
}
