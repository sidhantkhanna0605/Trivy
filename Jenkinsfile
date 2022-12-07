pipeline {
    agent any
    stages {
        stage('Build') {
            steps  {
              sh 'docker build -t ubuntu .'
            }
        }
        stage('Trivy Scan') {
            steps  {
              script {
                    sh """trivy image ubuntu"""
                    
                }  
            }
        }
    }
}
