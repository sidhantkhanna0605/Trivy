pipeline {
    agent any
    stages {
        stage('Build') {
            steps  {
              sh 'docker build -t infinte .'
            }
        }
        stage('Trivy Scan') {
            steps  {
              script {
                    sh """trivy image infinte"""
                    
                }  
            }
        }
    }
}
