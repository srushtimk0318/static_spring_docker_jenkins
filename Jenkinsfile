pipeline {
    agent any

    tools {
        maven 'maven'
    }
    stages {
        stage('Build') {
            steps {
                echo "Building the project..."
                sh 'mvn clean package'
            }
            post {
                success {
                    echo 'Build stage completed successfully.'
                }
                failure {
                    echo 'Build stage failed.'
                }
            }
        }
        stage('Docker Build the Image') {
            steps {
                echo "Building the Docker image..."
                sh 'sudo docker build -t devguru-kashi-cicd-docker .'
            }
            post {
                success {
                    echo 'Docker image built successfully.'
                }
                failure {
                    echo 'Docker image build failed.'
                }
            }
        }
        stage('Docker Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-cred-id',  
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                        echo "$PASS" | sudo docker login -u "$USER" --password-stdin
                    '''
                }
            }
        }
        stage('Docker Tag the Image') {
            steps {
                echo "Tagging the Docker image..."
                sh 'sudo docker tag devguru-kashi-cicd-docker sareenakashi/devguru-kashi-cicd-docker:latest'
            }
            post {
                success {
                    echo 'Docker image tagged successfully.'
                }
                failure {
                    echo 'Failed to tag Docker image.'
                }
            }
        }
        stage('Docker Push the Image') {
            steps {
                echo "Pushing the Docker image to DockerHub..."
                sh 'sudo docker push sareenakashi/devguru-kashi-cicd-docker:latest'
            }
            post {
                success {
                    echo 'Docker image pushed to DockerHub successfully.'
                }
                failure {
                    echo 'Failed to push Docker image to DockerHub.'
                }
            }
        }
        stage('Cleanup Local Docker Images') {
            steps {
                echo "Cleaning up local Docker images..."
                sh '''
                    sudo docker rmi sareenakashi/devguru-kashi-cicd-docker:latest
                    sudo docker rmi devguru-kashi-cicd-docker
                '''
            }
            post {
                success {
                    echo 'Local Docker images cleaned up successfully.'
                }
                failure {
                    echo 'Failed to clean up local Docker images.'
                }
            }
        }
        stage('Done') {
            steps {
                echo "Pipeline execution completed."
            }
        }
        stage('Docker Logout from DockerHub') {
            steps {
                echo "Logging out from DockerHub..."
                sh 'sudo docker logout'
            }
        }
        stage('Docker container run') {
            steps {
                script {
                    echo "🧩 Checking if the Docker container is already running..."
                    // Check if container exists
                    def containerExists = sh(
                        script: "sudo docker ps -a --format '{{.Names}}' | grep -w snapchat-container || true",
                        returnStdout: true
                    ).trim()
                    if (containerExists) {
                        echo "⚠️ Container 'snapchat-container' already exists."
                        // Ask user for confirmation
                        def userChoice = input(
                            id: 'ContainerRestart',
                            message: 'Container already running. Do you want to stop and redeploy?',
                            parameters: [choice(choices: ['Yes', 'No'], description: 'Choose action', name: 'Confirm')]
                        )
                        if (userChoice == 'Yes') {
                            echo "🛑 Stopping and removing old container..."
                            sh '''
                                sudo docker stop snapchat-container || true
                                sudo docker rm snapchat-container || true
                                echo "🚀 Starting new container..."
                                sudo docker run -d -p 8084:8080 --name snapchat-container sareenakashi/devguru-kashi-cicd-docker:latest
                            '''
                        } else {
                            echo "⏩ Skipping container restart as per user choice."
                        }
                    } else {
                        echo "🚀 No existing container found — starting new one..."
                        sh 'sudo docker run -d -p 8084:8080 --name snapchat-container sareenakashi/devguru-kashi-cicd-docker:latest'
                    }
                }
            }
        }
    }  
    post {
        always {
            echo 'This will always run after the stages are complete.'
        }
        success {
            echo 'This will run only if the pipeline succeeds.'
        }
        failure {
            echo 'This will run only if the pipeline fails.'
        }
    }
}
