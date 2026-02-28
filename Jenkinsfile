pipeline {
    agent any

    parameters {
        choice(name: 'TERRAFORM_ACTION', choices: "plan\napply\ndestroy", description: 'Terraform action to perform')
        choice(name: 'ENVIRONMENT', choices: "dev\nint\nuat\nprod\ndr", description: 'Target environment')
        choice(name: 'MODULE', choices: "S3\nEC2\nALL", description: 'Terraform module/directory to operate on (or ALL)')
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
                script {
                    def mods = params.MODULE == 'ALL' ? ['S3','EC2'] : [params.MODULE]
                    parallel mods.collectEntries { m -> ["Init-${m}" : {
                        dir(m) { sh 'terraform init' }
                    }]
                    }
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                script {
                    def mods = params.MODULE == 'ALL' ? ['S3','EC2'] : [params.MODULE]
                    parallel mods.collectEntries { m -> ["Validate-${m}" : {
                        dir(m) { sh 'terraform validate' }
                    }]
                    }
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
                script {
                    def mods = params.MODULE == 'ALL' ? ['S3','EC2'] : [params.MODULE]
                    parallel mods.collectEntries { m -> ["Plan-${m}" : {
                        dir(m) { sh "terraform plan -out=tfplan -var=environment=${params.ENVIRONMENT}" }
                    }]
                    }
                }
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
                script {
                    def mods = params.MODULE == 'ALL' ? ['S3','EC2'] : [params.MODULE]
                    parallel mods.collectEntries { m -> ["Apply-${m}" : {
                        dir(m) { sh "terraform apply -auto-approve tfplan -var=environment=${params.ENVIRONMENT}" }
                    }]
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.TERRAFORM_ACTION == 'destroy' }
            }
            steps {
                script {
                    def mods = params.MODULE == 'ALL' ? ['S3','EC2'] : [params.MODULE]
                    parallel mods.collectEntries { m -> ["Destroy-${m}" : {
                        dir(m) { sh "terraform destroy -auto-approve -var=environment=${params.ENVIRONMENT}" }
                    }]
                    }
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