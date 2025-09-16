pipeline {
    agent any

    tools {
        jdk 'jdk17'       // Jenkins 全局配置里的名字
        maven 'maven3'    // Jenkins 全局配置里的名字
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/vikis77/demo-jenkins-test.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Package') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}
