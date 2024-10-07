pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        PACKER_TEMPLATE = 'packer.json'
        REPO_URL = 'https://github.com/your-github-account/simple-web-app'
        ASG_NAME = 'your-asg-name'  // Specify your ASG name here
    }
    stages {
        stage('Checkout Code') {
            steps {
                git url: "${REPO_URL}", branch: 'main'
            }
        }
        stage('Get AMI ID from ASG') {
            steps {
                script {
                    // Fetch the AMI ID from the Launch Template or Launch Configuration of the ASG
                    def amiId = sh(script: """
                        aws autoscaling describe-auto-scaling-groups \
                        --auto-scaling-group-names ${ASG_NAME} \
                        --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' \
                        --output text
                    """, returnStdout: true).trim()

                    // Fetch the launch template version to get the current Image ID (AMI ID)
                    def imageId = sh(script: """
                        aws ec2 describe-launch-template-versions \
                        --launch-template-id ${amiId} \
                        --query 'LaunchTemplateVersions[0].LaunchTemplateData.ImageId' \
                        --output text
                    """, returnStdout: true).trim()

                    echo "Current AMI ID: ${imageId}"

                    // Store the AMI ID in the environment variable to be used in the Packer build
                    env.SOURCE_AMI_ID = imageId
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t my-web-app .'
                }
            }
        }
        stage('Run Packer to Create AMI') {
            steps {
                script {
                    // Run Packer with the automatically fetched AMI ID
                    sh """
                        packer build \
                        -var 'source_ami_id=${SOURCE_AMI_ID}' \
                        -var 'instance_type=t2.micro' \
                        ${PACKER_TEMPLATE}
                    """
                }
            }
        }
        stage('Update ASG Launch Template') {
            steps {
                script {
                    // Get the new AMI ID created by Packer
                    def newAmiId = sh(script: "aws ec2 describe-images --filters 'Name=name,Values=web-app-updated-*' --query 'Images[*].[ImageId]' --output text", returnStdout: true).trim()
                    
                    // Update the ASG's launch template with the new AMI ID
                    sh """
                        aws ec2 modify-launch-template \
                        --launch-template-id ${amiId} \
                        --source-version 1 \
                        --launch-template-data '{
                            "ImageId": "${newAmiId}"
                        }'
                    """
                }
            }
        }
    }
}
