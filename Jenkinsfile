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
                    sh """trivy image --format template --template "@/home/core/contrib/html.tpl" -o report.html ubuntu"""
                    
                }  
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: "report.html", fingerprint: true
                
            publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'report.html',
                reportName: 'Trivy Scan',
                ])
            }
        }
}
