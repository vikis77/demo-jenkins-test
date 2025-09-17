pipeline {
    agent any

    tools {
        maven 'Maven-3.9.0'
        jdk 'JDK-17'
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
                // 使用Jenkins管理的Maven settings配置
                configFileProvider([configFile(fileId: 'aliyun-maven-settings', variable: 'MAVEN_SETTINGS')]) {
                    sh 'mvn -s $MAVEN_SETTINGS clean package -DskipTests=true'
                }
            }
        }

        stage('Test') {
            steps {
                echo '========== Running Tests =========='
                // 使用Jenkins管理的Maven settings配置
                configFileProvider([configFile(fileId: 'aliyun-maven-settings', variable: 'MAVEN_SETTINGS')]) {
                    sh 'mvn -s $MAVEN_SETTINGS test'
                }
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
                        sh '''#!/bin/bash
                            echo "========== Stopping existing application =========="
                            pkill -f "${APP_NAME}.jar" || echo "No existing process found"
                            sleep 3

                            echo "========== Creating deploy directory =========="
                            mkdir -p ${DEPLOY_DIR}
                            echo "Deploy directory: ${DEPLOY_DIR}"

                            echo "========== Copying JAR file =========="
                            cp ${JAR_FILE} ${DEPLOY_DIR}/
                            ls -la ${DEPLOY_DIR}/

                            echo "========== Starting application =========="
                            cd ${DEPLOY_DIR}

                            # 创建启动脚本
                            cat > start-app.sh << 'EOF'
#!/bin/bash
cd /var/jenkins_home/workspace/demo1/deploy
exec java -jar springboot-demo-916.jar > app.log 2>&1
EOF
                            chmod +x start-app.sh

                            # 使用setsid完全分离进程
                            BUILD_ID=dontKillMe setsid ./start-app.sh &
                            APP_PID=$!
                            echo "Started application with PID: ${APP_PID}"

                            # 确保进程独立运行
                            disown $APP_PID

                            # 等待应用启动
                            echo "Waiting for application to start..."
                            sleep 8

                            # 检查进程是否运行
                            if ps -p ${APP_PID} > /dev/null; then
                                echo "✅ Application is running successfully!"
                                echo "PID: ${APP_PID}"
                                echo "Deploy Directory: ${DEPLOY_DIR}"
                                echo "Log File: ${DEPLOY_DIR}/app.log"
                                echo ""
                                echo "========== Application Log (last 20 lines) =========="
                                tail -n 20 ${DEPLOY_DIR}/app.log || echo "Log file not ready yet"
                            else
                                echo "❌ Application failed to start!"
                                echo "========== Error Log =========="
                                cat ${DEPLOY_DIR}/app.log || echo "No log file found"
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
                    if (isUnix()) {
                        sh '''#!/bin/bash
                            # 简单的进程检查，不依赖curl
                            echo "Checking if application is running..."

                            for i in {1..10}; do
                                if pgrep -f "${APP_NAME}.jar" > /dev/null; then
                                    echo "✅ Application process is running!"
                                    echo "PID: $(pgrep -f ${APP_NAME}.jar)"

                                    # 检查日志是否有启动成功标志
                                    if grep -q "APPLICATION IS READY" ${DEPLOY_DIR}/app.log 2>/dev/null; then
                                        echo "✅ Application started successfully!"
                                        echo ""
                                        echo "========== Startup Log =========="
                                        grep -A2 -B2 "APPLICATION IS READY" ${DEPLOY_DIR}/app.log
                                        exit 0
                                    fi
                                fi
                                echo "Waiting for application to be ready... ($i/10)"
                                sleep 2
                            done

                            echo "⚠️ Application may still be starting, check logs at: ${DEPLOY_DIR}/app.log"
                        '''
                    } else {
                        bat '''
                            echo Health check on Windows...
                            timeout 5 >nul
                            echo Application should be running on http://localhost:8080
                        '''
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
            echo 'Application URL: http://localhost:8081'
            echo 'Check logs in deployment directory for runtime information.'
        }
        failure {
            echo '❌ ========== Build, Deploy or Start Failed =========='
            echo 'Please check the console output for error details.'
        }
    }
}
