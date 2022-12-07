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
                    sh """trivy image --format template --template \"@/home/vijeta1/contrib/html.tpl\" --output trivy_report.html XXXXXXX.dkr.ecr.ap-south-1.amazonaws.com/${params.SERVICE}:${BUILD_NUMBER} """
                    
                }  
            }
        }
    }
}
