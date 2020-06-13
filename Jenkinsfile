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
                sh 'make uart_sim'
            }            
        }
        stage('Prove: Uart') {
            steps {
                sh 'make uart_sim'
            }            
        }
        stage('Coverage: Uart') {
            steps {
                sh 'make uart_sim'
            }            
        }        
    }
}
