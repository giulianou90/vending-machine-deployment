# vending-machine-deployment
Infrastructure and deployment setup for the Vending Machine microservice

## Architecture Overview

```
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

```


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

# Detailed Project explanation

For deploying the Vending Machine microservice, I chose a cloud-native architecture focused on simplicity, scalability, security, and maintainability.

To run the application containers, I selected AWS ECS Fargate. This serverless container platform abstracts away server and cluster management, allowing me to focus purely on the application itself. Compared to more complex options like Kubernetes or managing EC2 container hosts, Fargate is straightforward and well-suited for this relatively simple microservice. 

For infrastructure provisioning, I used Terraform due to its ability to manage cloud resources reproducibly and version controlled. To simplify managing multiple stacks and environments, I wrapped Terraform with Terraspace.

On the networking side, the application’s requirement to expose some endpoints publicly and others privately shaped the architecture. I created a VPC with separate public and private subnets and deployed two distinct Application Load Balancers (ALBs):

A Public ALB, deployed in the public subnet with a security group allowing inbound traffic from anywhere. This ALB routes requests for the /beverages endpoints and exposes them publicly.

An Internal ALB, deployed within private subnets and restricted by security groups to only allow traffic from within the VPC CIDR. This ALB handles the /ingredients endpoint, making it accessible only within the private network.

I chose ALBs because they operate at Layer 7 and also integrate natively with ECS, simplifying service discovery and load balancing.

To store container images, I used AWS Elastic Container Registry, which is a secure, private, and highly available Docker image repository integrated with ECS, minimizing latency and simplifying authentication.

For logging and monitoring, I decided to go with AWS CloudWatch Logs. This native service requires minimal setup, centralizes log aggregation, and integrates easily with alerts and dashboards. I think that Grafana/Loki/Prometheus are too complex for this use case.

Security is always a primary concern; by isolating the application containers in private subnets with no direct inbound internet access and using a NAT Gateway to allow only outbound internet connectivity, I reduced the attack surface . Security Groups enforce strict access controls: the public ALB accepts requests from all IPs only for public endpoints, while the internal ALB restricts traffic to the VPC only.

In summary, this architecture balances simplicity, security, and scalability while making use of modern infrastructure as code practices to deliver a maintainable and robust deployment solution.

Finally, I chose GitHub Actions as the CI/CD tool for this deployment due to its seamless integration with the GitHub repository hosting the code, which simplifies automation without introducing additional external tools. GitHub Actions allows for easy setup of workflows that trigger automatically on code pushes, enabling fast, reliable builds, container image creation, and deployment to AWS services such as ECR and ECS.

Compared to other CI/CD solutions like Jenkins, GitHub Actions requires minimal maintenance because it’s a fully managed service integrated directly where the code lives; Also, it's really easy to use.



## Deployment and Testing Instructions

### Deploying the Application

- **CI/CD Automation:**  
  Pushing code to the `main`, `dev` or `chore/trigger-deploy` branch triggers a GitHub Actions workflow that:
  1. Builds the Docker image.
  2. Pushes the image to Amazon ECR.
  3. Updates the ECS service to deploy the new image.

- **Manual Deployment:**  
  If needed, you can manually trigger the GitHub Actions workflow via the GitHub UI under **Actions** > *Deploy workflow*.

### Testing the endpoints

Run `curl -v http://prd-vending-public-alb-2021859691.us-east-1.elb.amazonaws.com/beverages` from your terminal.

Expected response: [{"name":"coffee","price":2.5},{"name":"tea","price":2},{"name":"hotChocolate","price":2.7},{"name":"latte","price":3.5},{"name":"cappuccino","price":3.2}]


Run ``` curl -v -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "beverageName": "coffee",
    "sugarLevel": 3,
    "coins": [2, 0.2, 0.2, 0.2]
  }' \
  http://prd-vending-public-alb-2021859691.us-east-1.elb.amazonaws.com/beverages ```

Expected response: {"name":"coffee","change":[0.1],"txId":"1234567890abcdef"}


Run `curl -v http://prd-vending-public-alb-2021859691.us-east-1.elb.amazonaws.com/ingredients`

Expected response: 403 Forbidden


To test /ingredients endpoint you need to make a request from inside the VPC (for example connected to the ECS container):
`wget -qO-  http://internal-prd-vending-internal-alb-2118490102.us-east-1.elb.amazonaws.com/ingredients` 

Expected response: [{"name":"water","quantity":99},{"name":"sugar","quantity":47},{"name":"coffee","quantity":29},{"name":"tea","quantity":30},{"name":"milk","quantity":20},{"name":"iceCream","quantity":10}]

## How to connect to ECS container (YOU WON'T BE ABLE TO TEST THIS since you do not have the credentials)

* Login to the terminal with AWS credentials
* Check if you have the [Session Manager plugin for the AWS CLI installed](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

* Run: aws ecs execute-command  --cluster $CLUSTER_NAME   --task $ECS_TASK_ID --container $CONTAINER_NAME   --interactive --region=us-east-1 --command "/bin/sh"

For example:

aws ecs execute-command  --cluster vending-machine-cluster-ecs-prd   --task c4e715b5591145db807c2cbeb1b02a32 --container vending-machine-prd   --interactive   --command "/bin/sh"

* You can find the $ECS_TASK_ID in the aws ecs console, under the label **Tasks** inside the cluster.

