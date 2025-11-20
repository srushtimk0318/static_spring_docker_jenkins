pipeline {
    agent any

    tools{
        maven 'maven'
    }

    environment {
        IMAGE_NAME = "sareenakashi/devguru-app"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/srushtimk0318/static_spring_docker_jenkins.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker buildx build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push $IMAGE_NAME:latest'
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh '''
                docker-compose down
                docker-compose pull
                docker-compose up -d --build
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline completed."
        }
    }
}
