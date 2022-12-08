pipeline {
    agent any
    environment {
      dockerhub=credentials('dockerhub')
      image="cricket"
    }
    stages {
        stage('Build') {
            steps  {
                sh 'docker build -t ${image} .'
            }
        }
        stage('Trivy Scan') {
            steps  {
              script {
                    sh 'trivy image --exit-code 1 --severity=CRITICAL --format template --template "@/home/core/contrib/html.tpl" -o report.html ${image}'
                    
                }  
            }
        }
        stage('Docker Tag'){
          steps  {
              sh 'docker tag fifa sidhant0605/${image} '
          }
        }
        stage('Login') {
          steps{
            sh 'echo $dockerhub_PSW |docker login -u $dockerhub_USR --password-stdin'
          }
        }
        stage('Docker Push'){
          steps  {
              sh 'docker push sidhant0605/${image} '
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
