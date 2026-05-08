pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
    }

    environment {
        APP_NAME   = 'VehicleRentalPlatform'
        WAR_FILE   = "target\\${APP_NAME}.war"
        TOMCAT_DIR = 'C:\\Users\\LENOVO\\Downloads\\apache-tomcat-10.1.24'
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
            steps {
                echo "Stopping Tomcat..."
                bat """
                    set CATALINA_HOME=${env.TOMCAT_DIR}
                    call "${env.TOMCAT_DIR}\\bin\\shutdown.bat" 2>nul
                    exit 0
                """

                echo "Removing old deployment..."
                bat """
                    if exist "${env.TOMCAT_DIR}\\webapps\\${env.APP_NAME}.war" (
                        del /F /Q "${env.TOMCAT_DIR}\\webapps\\${env.APP_NAME}.war"
                    )
                    if exist "${env.TOMCAT_DIR}\\webapps\\${env.APP_NAME}" (
                        rmdir /S /Q "${env.TOMCAT_DIR}\\webapps\\${env.APP_NAME}"
                    )
                """

                echo "Copying new WAR to Tomcat..."
                bat "copy /Y \"${env.WAR_FILE}\" \"${env.TOMCAT_DIR}\\webapps\\${env.APP_NAME}.war\""

                echo "Starting Tomcat..."
                powershell """
                    \$env:CATALINA_HOME = '${env.TOMCAT_DIR}'
                    \$env:JRE_HOME     = 'C:\\Program Files\\Amazon Corretto\\jdk17.0.14_7'
                    Start-Process -FilePath '${env.TOMCAT_DIR}\\bin\\catalina.bat' `
                                  -ArgumentList 'start' `
                                  -WorkingDirectory '${env.TOMCAT_DIR}\\bin' `
                                  -WindowStyle Hidden
                    Start-Sleep -Seconds 8
                    Write-Host 'Tomcat started.'
                """

                echo "Deployed! App will be live at http://localhost:8081/${env.APP_NAME}/"
            }
        }

    }

    post {
        success {
            echo "Pipeline completed! App live at http://localhost:8081/${env.APP_NAME}/"
        }
        failure {
            echo "Pipeline FAILED. Review the logs above."
        }
        always {
            cleanWs(notFailBuild: true)
        }
    }
}
