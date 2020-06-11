pipeline {
    agent any

    stages {
        stage('Cmake') {
            steps {
                echo 'Cmake..'
                sh 'cmake .'
            }
        stage('Simulation: Uart') {
            steps {
                sh 'make uart_sim'
            }            
        }
    }
}
