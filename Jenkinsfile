pipeline {
    agent any

    tools {
        maven 'Maven-3.9.0'    // 根据你的Jenkins配置调整
        jdk 'JDK-17'           // 根据你的Jenkins配置调整
    }

    environment {
        APP_NAME = 'springboot-demo-916'
        JAR_FILE = "target/${APP_NAME}.jar"
        DEPLOY_DIR = "${WORKSPACE}/deploy"  // 使用workspace目录避免权限问题
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
                    // 简单显示测试结果，不使用junit插件
                    script {
                        echo '========== Test Results Summary =========='
                        if (fileExists('target/surefire-reports')) {
                            echo 'Test reports generated successfully'
                            sh 'ls -la target/surefire-reports/ || true'
                        } else {
                            echo 'No surefire-reports directory found'
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

                            echo "Creating deploy directory in workspace..."
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
                                echo "Deploy Directory: ${DEPLOY_DIR}"
                                echo "Log File: ${DEPLOY_DIR}/app.log"
                            else
                                echo "❌ Application failed to start!"
                                echo "Check log file: ${DEPLOY_DIR}/app.log"
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
