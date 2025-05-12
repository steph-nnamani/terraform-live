permissions:
  id-token: write
  contents: read 
name: Terraform Destroy
on:
  # Keep manual trigger option
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to destroy (e.g., prod)'
        required: true
        default: 'prod'
      service:
        description: 'Service to destroy (e.g., webserver-cluster)'
        required: true
        default: 'webserver-cluster'
      confirm_destroy:
        description: 'Type "destroy" to confirm'
        required: true
  
  # Add trigger on push to destroy branch
  push:
    branches:
      - destroy

jobs:
  terraform-destroy:
    runs-on: ubuntu-latest
    if: github.event_name == 'workflow_dispatch' && github.event.inputs.confirm_destroy == 'destroy' || github.event_name == 'push' && github.ref == 'refs/heads/destroy'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Authenticate to AWS using OIDC
        uses: aws-actions/configure-aws-credentials@v1
        with:
          # specify the IAM role to assume here
          role-to-assume: "arn:aws:iam::418272752575:role/github-actions-oidc-example20250511055154010500000001"
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.1.0  
          terraform_wrapper: false

      - name: Terraform Destroy with Dependencies
        working-directory: ./prod/services/webserver-cluster
        run: |
          terraform init        
          # # First destroy resources that depend on security groups
          # echo "Destroying Auto Scaling Group..."
          # terraform destroy -target=module.webserver_cluster.aws_autoscaling_group.example -auto-approve || true
          
          # echo "Destroying Load Balancer and related resources..."
          # terraform destroy -target=module.webserver_cluster.aws_lb.example -auto-approve || true
          # terraform destroy -target=module.webserver_cluster.aws_lb_listener.http -auto-approve || true
          # terraform destroy -target=module.webserver_cluster.aws_lb_listener_rule.asg -auto-approve || true
          
          # # Wait for resources to be fully deleted
          # echo "Waiting for resources to be fully deleted..."
          # sleep 60
          
          # # Use AWS CLI to find and detach any remaining network interfaces
          # echo "Checking for remaining ENIs attached to security groups..."
          # SG_INSTANCE=$(terraform state show module.webserver_cluster.aws_security_group.instance | grep "id" | head -n 1 | cut -d "=" -f 2 | tr -d ' "')
          # SG_ALB=$(terraform state show module.webserver_cluster.aws_security_group.alb | grep "id" | head -n 1 | cut -d "=" -f 2 | tr -d ' "')
          
          # if [ ! -z "$SG_INSTANCE" ]; then
          #   echo "Finding ENIs for security group $SG_INSTANCE"
          #   ENI_IDS=$(aws ec2 describe-network-interfaces --filters Name=group-id,Values=$SG_INSTANCE --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text)
          #   for ENI_ID in $ENI_IDS; do
          #     echo "Detaching ENI $ENI_ID"
          #     ATTACHMENT_ID=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Attachment.AttachmentId' --output text)
          #     if [ "$ATTACHMENT_ID" != "None" ] && [ ! -z "$ATTACHMENT_ID" ]; then
          #       aws ec2 detach-network-interface --attachment-id $ATTACHMENT_ID --force
          #       sleep 10
          #     fi
          #     echo "Deleting ENI $ENI_ID"
          #     aws ec2 delete-network-interface --network-interface-id $ENI_ID || true
          #   done
          # fi
          
          # if [ ! -z "$SG_ALB" ]; then
          #   echo "Finding ENIs for security group $SG_ALB"
          #   ENI_IDS=$(aws ec2 describe-network-interfaces --filters Name=group-id,Values=$SG_ALB --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text)
          #   for ENI_ID in $ENI_IDS; do
          #     echo "Detaching ENI $ENI_ID"
          #     ATTACHMENT_ID=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Attachment.AttachmentId' --output text)
          #     if [ "$ATTACHMENT_ID" != "None" ] && [ ! -z "$ATTACHMENT_ID" ]; then
          #       aws ec2 detach-network-interface --attachment-id $ATTACHMENT_ID --force
          #       sleep 10
          #     fi
          #     echo "Deleting ENI $ENI_ID"
          #     aws ec2 delete-network-interface --network-interface-id $ENI_ID || true
          #   done
          # fi
          
          # # Then destroy security groups
          # echo "Destroying security groups..."
          # terraform destroy -target=module.webserver_cluster.aws_security_group.instance -auto-approve || true
          # terraform destroy -target=module.webserver_cluster.aws_security_group.alb -auto-approve || true
          
          # # Finally destroy everything else
          # echo "Destroying remaining resources..."
          terraform destroy -auto-approve