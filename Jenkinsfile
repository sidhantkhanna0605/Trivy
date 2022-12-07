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
                    sh """trivy image --exit-code 1 --severity MEDIUM ubuntu"""
                    
                }  
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: "trivy_report.html", fingerprint: true
                
            publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'trivy_report.html',
                reportName: 'Trivy Scan',
                ])
            }
        }
}
