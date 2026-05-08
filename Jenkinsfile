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

                echo "Starting Tomcat via Task Scheduler (escapes Jenkins process tree)..."
                powershell """
                    \$startScript = '${env.TOMCAT_DIR}\\bin\\tomcat_start_vrp.bat'

                    # Write a standalone start script next to catalina.bat
                    \$script = "@echo off`r`nset CATALINA_HOME=${env.TOMCAT_DIR}`r`nset JRE_HOME=C:\\Program Files\\Amazon Corretto\\jdk17.0.14_7`r`ncall `"${env.TOMCAT_DIR}\\bin\\catalina.bat`" start`r`n"
                    \$script | Out-File -FilePath \$startScript -Encoding ascii

                    # Remove any leftover task, ignore errors
                    schtasks /delete /tn 'StartTomcatVRP' /f 2>\$null | Out-Null

                    # Schedule an immediate one-shot task running as the current user
                    schtasks /create /f /sc once /st '00:00' /tn 'StartTomcatVRP' /tr \$startScript
                    schtasks /run /tn 'StartTomcatVRP'

                    Start-Sleep -Seconds 10
                    Write-Host 'Tomcat start task launched.'
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
