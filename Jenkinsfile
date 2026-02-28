pipeline {
    agent any

    parameters {
        choice(name: 'TERRAFORM_ACTION', choices: "plan\napply\ndestroy", description: 'Terraform action to perform')
        choice(name: 'ENVIRONMENT', choices: "dev\nint\nuat\nprod\ndr", description: 'Target environment')
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
                dir('S3') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('S3') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression {
                    params.TERRAFORM_ACTION == 'plan' || params.TERRAFORM_ACTION == 'apply'
                }
            }
            steps {
                dir('S3') {
                    sh "terraform plan -out=tfplan -var=environment=${params.ENVIRONMENT}"
                }

        stage('Terraform Apply') {
            when {
                allOf {
                    expression { params.TERRAFORM_ACTION == 'apply' }
                    branch 'main'
                }
            }
            steps {
                dir('S3') {
                    sh "terraform apply -auto-approve tfplan -var=environment=${params.ENVIRONMENT}"
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.TERRAFORM_ACTION == 'destroy' }
            }
            steps {
                dir('S3') {
                    sh "terraform destroy -auto-approve -var=environment=${params.ENVIRONMENT}"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline Completed'
        }
    }
}