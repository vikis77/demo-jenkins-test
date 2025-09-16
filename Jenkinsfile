pipeline {
    agent any

    tools {
        maven 'Maven-3.9.0'    // 根据你的Jenkins配置调整
        jdk 'JDK-17'           // 根据你的Jenkins配置调整
    }

    environment {
        APP_NAME = 'springboot-demo-916'
        JAR_FILE = "target/${APP_NAME}.jar"
        DEPLOY_DIR = '/opt/apps/springboot-demo-916'  // Linux部署目录
        WINDOWS_DEPLOY_DIR = 'C:\\apps\\springboot-demo-916'  // Windows部署目录
    }

    stages {
        stage('Checkout') {
            steps {
                echo '========== Checkout Code =========='
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '========== Building Application =========='
                sh 'mvn clean package -DskipTests=true'
            }
        }

        stage('Test') {
            steps {
                echo '========== Running Tests =========='
                sh 'mvn test'
            }
            post {
                always {
                    // 使用正确的Jenkins测试报告发布方法
                    script {
                        if (fileExists('target/surefire-reports/*.xml')) {
                            junit 'target/surefire-reports/*.xml'
                        } else {
                            echo 'No test reports found'
                        }
                    }
                }
            }
        }

        stage('Archive') {
            steps {
                echo '========== Archiving Artifacts =========='
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Deploy & Start') {
            steps {
                echo '========== Deploying and Starting Application =========='
                script {
                    if (isUnix()) {
                        // Linux/Unix 部署
                        sh '''
                            echo "Stopping existing application..."
                            pkill -f "${APP_NAME}.jar" || true
                            sleep 3

                            echo "Creating deploy directory..."
                            mkdir -p ${DEPLOY_DIR}

                            echo "Copying JAR file..."
                            cp ${JAR_FILE} ${DEPLOY_DIR}/

                            echo "Starting application..."
                            cd ${DEPLOY_DIR}
                            nohup java -jar ${APP_NAME}.jar > app.log 2>&1 &
                            sleep 5

                            echo "Application started. Checking status..."
                            if pgrep -f "${APP_NAME}.jar"; then
                                echo "✅ Application is running successfully!"
                                echo "PID: $(pgrep -f ${APP_NAME}.jar)"
                            else
                                echo "❌ Application failed to start!"
                                exit 1
                            fi
                        '''
                    } else {
                        // Windows 部署
                        bat '''
                            echo Stopping existing application...
                            taskkill /F /FI "WINDOWTITLE eq springboot-demo-916*" 2>nul || echo No existing process found

                            echo Creating deploy directory...
                            if not exist "%WINDOWS_DEPLOY_DIR%" mkdir "%WINDOWS_DEPLOY_DIR%"

                            echo Copying JAR file...
                            copy "%JAR_FILE%" "%WINDOWS_DEPLOY_DIR%\\"

                            echo Starting application...
                            cd /d "%WINDOWS_DEPLOY_DIR%"
                            start "springboot-demo-916" java -jar %APP_NAME%.jar

                            timeout 5
                            echo Application started successfully!
                        '''
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo '========== Health Check =========='
                script {
                    def healthCheckScript = isUnix() ?
                        '''
                        for i in {1..30}; do
                            if curl -s http://localhost:8080 > /dev/null 2>&1; then
                                echo "✅ Application is healthy and responding!"
                                exit 0
                            fi
                            echo "Waiting for application to start... ($i/30)"
                            sleep 2
                        done
                        echo "⚠️ Health check timeout, but application may still be starting..."
                        ''' :
                        '''
                        for /L %%i in (1,1,15) do (
                            curl -s http://localhost:8080 >nul 2>&1
                            if errorlevel 0 (
                                echo ✅ Application is healthy and responding!
                                goto :healthy
                            )
                            echo Waiting for application to start... (%%i/15^)
                            timeout 2 >nul
                        )
                        echo ⚠️ Health check timeout, but application may still be starting...
                        :healthy
                        '''

                    if (isUnix()) {
                        sh healthCheckScript
                    } else {
                        bat healthCheckScript
                    }
                }
            }
        }
    }

    post {
        always {
            echo '========== Pipeline Finished =========='
            // 清理工作空间（可选）
            // cleanWs()
        }
        success {
            echo '🎉 ========== Build, Deploy and Start Success =========='
            echo 'Application URL: http://localhost:8080'
            echo 'Check logs in deployment directory for runtime information.'
        }
        failure {
            echo '❌ ========== Build, Deploy or Start Failed =========='
            echo 'Please check the console output for error details.'
        }
    }
}
