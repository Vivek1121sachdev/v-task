pipeline{
    
    agent any
    environment {
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = "593242862402"
        ECR_REPO_NAME = "v_task_ecr"
    }
    options {
        ansiColor('xterm')
    }
    stages{
        stage('terraform init'){
            steps{
                bat "terraform init"
            }
        }
        stage('creating_ecr_repo'){
            steps{
                script{
                    bat "terraform apply -target=module.ecr --auto-approve"
                }
            }
        }
        stage('pushing image to ecr')
        {
            steps{
                script{
                        bat '''
                            cd code
                            aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
	                        powershell.exe -ExecutionPolicy Bypass -File ./ecr-img-push.ps1 %AWS_REGION% %AWS_ACCOUNT_ID% %ECR_REPO_NAME% "12345"
	                        cd ..
                        '''
                }    
            }
                        
        }       
        stage('terraform plan'){
            steps{
                bat "terraform plan"
            }
        }
        
        stage('terraform apply'){
            steps{
                script{
                    bat "terraform apply --auto-approve"
                }
            }
        }
    }
}
