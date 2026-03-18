pipeline {
    agent any

    parameters {
        choice(name: 'TERRAFORM_ACTION', choices: "plan\napply\ndestroy", description: 'Terraform action to perform')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            when {
                expression {
                    params.TERRAFORM_ACTION == 'plan' || params.TERRAFORM_ACTION == 'apply'
                }
            }
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            when {
                allOf {
                    expression { params.TERRAFORM_ACTION == 'apply' }
                    branch 'main'
                }
            }
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.TERRAFORM_ACTION == 'destroy' }
            }
            steps {
                sh 'terraform destroy -auto-approve'
            }
        }
    }

    post {
        always {
            echo 'Pipeline Completed'
        }
    }
}hello world
