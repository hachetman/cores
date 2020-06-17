pipeline {
    agent any

    stages {
        stage('Cmake') {
            steps {
                echo 'Cmake..'
                sh 'cmake .'
            }
        }
        stage('Simulation: Uart') {
            steps {
                sh 'make uart.sim'
            }            
        }
        stage('Prove: Uart') {
            steps {
                sh 'make uart.proove'
            }            
        }
        stage('Coverage: Uart') {
            steps {
                sh 'make uart.cover'
            }            
        }        
    }
}
