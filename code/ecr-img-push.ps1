param ( 
    [string]$AWS_REGION,
    [string]$AWS_ACCOUNT_ID,
    [string]$ECR_REPO_NAME,
    [string]$gitHash
)

echo $gitHash
# Docker image details
$DOCKER_IMAGE_NAME = $ECR_REPO_NAME

# Build Docker image
docker build -t ($DOCKER_IMAGE_NAME + ":" + $gitHash) .

# # Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com


# Tag Docker image with ECR repository URI
$DOCKER_ECR_REPO_URI = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME"
docker tag ($DOCKER_IMAGE_NAME + ":" + $gitHash) ($DOCKER_ECR_REPO_URI + ":" + $gitHash)

# Push Docker image to ECR
docker push ($DOCKER_ECR_REPO_URI + ":" + $gitHash)
