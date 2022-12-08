pipeline {
    agent any
    stages {
        stage('Build') {
            steps  {
              sh 'docker build -t fifa .'
            }
        }
        stage('Trivy Scan') {
            steps  {
              script {
                    sh """trivy image --exit-code 1 --severity=CRITICAL --format template --template "@/home/core/contrib/html.tpl" -o report.html ubuntu"""
                    
                }  
            }
        }
        stage('Docker Tag'){
          steps  {
            sh 'docker tag fifa sidhant0605/fifa '
          }
        }
        stage('Login') {
          steps{
            sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
          }
        }
        stage('Docker Push'){
          steps  {
            sh 'docker push sidhant0605/fifa '
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
