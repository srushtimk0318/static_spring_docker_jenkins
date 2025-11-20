pipeline {

    agent any

    /******************************
     * GLOBAL ENVIRONMENT VARIABLES
     ******************************/
    environment {
        KUBECONFIG_PATH = "/var/lib/jenkins/kubeconfig.yml"
        REGISTRY = "docker.io"
        IMAGE_NAME = "sak/yamaha"
        DOCKER_CREDS = "dockerhub-credentials"
    }

    /******************************
     * PIPELINE PARAMETERS
     ******************************/
    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'pre_prod', 'prod'],
            description: 'Select deployment environment'
        )

        choice(
            name: 'ACTION',
            choices: ['deploy', 'destroy'],
            description: 'Select action type'
        )

        string(
            name: 'VERSION',
            defaultValue: '',
            description: 'Optional: version tag for application image (used in prod & pre_prod). If empty, BUILD_ID will be used at runtime.'
        )
    }

    stages {

        /******************************
         * DEV ENVIRONMENT (Docker Compose)
         ******************************/
        stage('DEV - Docker Environment Check') {
            when { expression { params.ENV == 'dev' } }
            steps {
                sh """
                echo "===== Checking Docker & Docker-Compose ====="
                docker --version
                docker-compose --version
                """
            }
        }

        stage('DEV - Deploy / Destroy') {
            when { expression { params.ENV == 'dev' } }
            steps {
                script {
                    if (params.ACTION == "deploy") {
                        sh """
                        echo "===== DEV Deploy Using Docker Compose ====="
                        docker-compose down
                        docker-compose up -d --build
                        """
                    } else {
                        sh """
                        echo "===== DEV Destroy Using Docker Compose ====="
                        docker-compose down -v
                        docker rmi `docker images -q` || true
                        """
                    }
                }
            }
        }

        /******************************
         * PRE-PRODUCTION (Build + Push)
         ******************************/
        stage('PRE_PROD - Build Docker Image') {
            when { expression { params.ENV == 'pre_prod' && params.ACTION == 'deploy' } }
            steps {
                script {
                    def versionTag = params.VERSION ?: env.BUILD_ID
                    def latestTag = "latest"
                    env.IMAGE_TAG = versionTag

                    sh """
                    echo "===== Building Docker Image ====="
                    docker build -t ${IMAGE_NAME}:${versionTag} .
                    docker tag ${IMAGE_NAME}:${versionTag} ${IMAGE_NAME}:${latestTag}
                    """
                }
            }
        }

        stage('PRE_PROD - Push to DockerHub') {
            when { expression { params.ENV == 'pre_prod' && params.ACTION == 'deploy' } }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo "===== Logging into DockerHub ====="
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                    echo "===== Pushing Docker Images ====="
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest

                    echo "===== Logging Out ====="
                    docker logout
                    """
                }
            }
        }

        stage('PRE_PROD - Cleanup Local Images') {
            when { expression { params.ENV == 'pre_prod' } }
            steps {
                sh """
                echo "===== Cleaning Local Docker Images ====="
                docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                docker rmi ${IMAGE_NAME}:latest || true
                """
            }
        }

        /******************************
         * PRODUCTION (Kubernetes)
         ******************************/
        stage('PROD - MySQL Deploy / Destroy') {
            when { expression { params.ENV == 'prod' && params.ACTION != '' } }
            steps {
                script {
                    if (params.ACTION == "deploy") {
                        sh """
                        echo "===== PROD: Deploy MySQL ====="
                        chmod +x scripts/mysql.sh
                        ./scripts/mysql.sh deploy
                        """
                    } else if (params.ACTION == "destroy") {
                        sh """
                        echo "===== PROD: Destroy MySQL ====="
                        chmod +x scripts/mysql.sh
                        ./scripts/mysql.sh destroy
                        """
                    }
                }
            }
        }

        stage('PROD - Blue/Green App Deploy') {
            when { expression { params.ENV == 'prod' && params.ACTION == 'deploy' } }
            steps {
                script {
                    if (!params.VERSION?.trim()) {
                        error("VERSION parameter is required for PROD deployments!")
                    }

                    def fullImage = "${IMAGE_NAME}:${params.VERSION}"

                    sh """
                    echo "===== PROD: Blue/Green App Deployment ====="
                    chmod +x scripts/app.sh
                    ./scripts/app.sh deploy ${fullImage}
                    """
                }
            }
        }

        stage('PROD - Blue/Green Destroy') {
            when { expression { params.ENV == 'prod' && params.ACTION == 'destroy' } }
            steps {
                script {
                    if (!params.VERSION?.trim()) {
                        error("VERSION (blue or green) required for destroy!")
                    }

                    sh """
                    echo "===== PROD: Destroy Blue/Green Deployment ====="
                    chmod +x scripts/app.sh
                    ./scripts/app.sh destroy ${params.VERSION}
                    """
                }
            }
        }
    }

    /******************************
     * FINAL POST ACTIONS
     ******************************/
    post {
        always {
            echo "======= Pipeline Completed ======="
        }
        success {
            echo "======= SUCCESS ======="
        }
        failure {
            echo "======= FAILED ======="
        }
    }
}
