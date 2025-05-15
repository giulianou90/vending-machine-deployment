# vending-machine-deployment
Infrastructure and deployment setup for the Vending Machine microservice

## Architecture Overview
+--------------------------------------------------------------+
|                            VPC                               |
| +-------------------+        +-------------------------+    |
| |   Public Subnet   |        |     Private Subnet(s)   |    |
| |                   |        |                         |    |
| |  +-------------+  |        |  +-------------------+  |    |
| |  | Public ALB  |  |        |  | Internal ALB       | |    |
| |  | (SG: Allow  |  |        |  | (SG: Allow VPC CIDR)||    |
| |  | 0.0.0.0/0) |  |        |  +---------|---------+   |
| |  +------+------+  |        |            |            |    |
| |         |         |        |  +---------v---------+  |    |
| |         |         |        |  | ECS Fargate Tasks  | |    |
| |         |         |        |  | (Containers run    | |    |
| |         |         |        |  |  both endpoints)   | |    |
| |         |         |        |  +-------------------+  |    |
| |         |         |        |                         |    |
| |  +------+-------+ |        |                         |    |
| |  | NAT Gateway  | |        |                         |    |
| |  +-------------+ |         |                         |    |
| +--------|---------+         +-----------|-------------+    |
|          |                               |                  |
|          |                               |                  |
|          |                               |                  |
|      +---v------------------------------ v---+              |
|      |         Internet Gateway (IGW)        |              |
|      +---------------------------------------+              |
+--------------------------------------------------------------+

Outside VPC:
+----------------------+          +-------------------------+
| Elastic Container    |<---------| ECS Task Execution       |
| Registry (ECR)       |          | (pull container images)  |
+----------------------+          +-------------------------+

+----------------------+          +-------------------------+
| CloudWatch Logs      |<---------| ECS Tasks (send logs)    |
+----------------------+          +-------------------------+



### Components Description

- **VPC (Virtual Private Cloud)**  
  Provides isolated networking for the application. Contains public and private subnets.

- **Public Subnet**  
  Hosts the Application Load Balancer (ALB) and NAT Gateway. The ALB routes external traffic securely to backend services.

- **Private Subnet(s)**  
  Houses ECS Fargate tasks running the vending-machine application containers, isolated from direct internet exposure.

- **Public ALB**  
  Internet-facing, deployed in public subnet, security group allows inbound HTTP from anywhere, routes /beverages requests to ECS tasks.

- **Internal ALB**  
  Internal-only, deployed in private subnet(s), security group restricts inbound HTTP to VPC CIDR, routes /ingredients requests.

- **Internet Gateway (IGW)**  
  Enables internet connectivity for resources in the VPC that require it (e.g., ALB, NAT Gateway).

- **NAT Gateway**  
  Allows ECS tasks in private subnets to access the internet for pulling container images and updates securely.

- **ECS Fargate Tasks**  
  Serverless container execution running the vending machine microservice, managed by ECS for scaling and availability.

- **Elastic Container Registry (ECR)**  
  Amazon-managed private Docker registry storing container images used by ECS tasks.

- **CloudWatch Logs**  
  Centralized logging service where ECS tasks send application and infrastructure logs for monitoring and troubleshooting.

---

## Deployment and Testing Instructions

### Deploying the Application

- **CI/CD Automation:**  
  Pushing code to the `main` branch triggers a GitHub Actions workflow that:
  1. Builds the Docker image.
  2. Pushes the image to Amazon ECR.
  3. Updates the ECS service to deploy the new image.

- **Manual Deployment:**  
  If needed, you can manually trigger the GitHub Actions workflow via the GitHub UI under **Actions** > *Deploy workflow*.


