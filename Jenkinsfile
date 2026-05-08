pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }

    environment {
        APP_NAME    = 'VehicleRentalPlatform'
        WAR_FILE    = "target/${APP_NAME}-1.0-SNAPSHOT.war"
        DEPLOY_DIR  = 'C:/tomcat/webapps'
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Cloning source code..."
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Compiling and packaging the WAR..."
                bat 'mvn clean package -DskipTests'
            }
            post {
                success { echo "Build succeeded — WAR created at ${env.WAR_FILE}" }
                failure { echo "Build FAILED. Check Maven output above." }
            }
        }

        stage('Test') {
            steps {
                echo "Running unit tests..."
                bat 'mvn test'
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Archive Artifact') {
            steps {
                echo "Archiving WAR file..."
                archiveArtifacts artifacts: "${env.WAR_FILE}",
                                 fingerprint: true,
                                 allowEmptyArchive: false
            }
        }

        stage('Deploy to Tomcat') {
            when {
                branch 'main'
            }
            steps {
                echo "Deploying ${env.APP_NAME} to Tomcat..."
                bat """
                    copy /Y "${env.WAR_FILE}" "${env.DEPLOY_DIR}\\${env.APP_NAME}.war"
                """
                echo "Deployment complete. App available at http://localhost:8080/${env.APP_NAME}/"
            }
        }

    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline FAILED. Review the logs above."
        }
        always {
            cleanWs()
        }
    }
}
