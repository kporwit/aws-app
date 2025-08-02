# Application AWS project

## Used tools

- [taskfile](https://taskfile.dev)
- terraform (>= v1.2.0)
- [pre-commit](https://pre-commit.com/)
    - [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform?tab=readme-ov-file#terraform_trivy)
    - [gitleaks](https://github.com/gitleaks/gitleaks)

## Terraform resources

All terraform resources can be found under `terraform` directory.

### Remote state

Terraform script was created to create state and lock resources in `terraform/remote-state/main.tf`.
This script should be applied only **once** at the begging of the work with the repository.
To create the resources log in to the AWS through CLI and then run `cd terrafrom/remote-state/ && terraform init && terraform apply`.
The name of the state bucket (which can be taken from the outputs) should be then placed in the `Taskfile.yaml` under the `STATE_BUCKET` key.
To upload the `terraform.tfstate` to the state bucket run `upload-remote-state` from the repository root which will allow other users to read it. The state file can be now safely removed.
In the Taskfile 'wrapper' commands exists for the `remote-state` directory which downloads the state before any actual operation:

- `apply-remote-state`
- `plan-remote-state`
- `destroy-remote-state`

in case that anyone would need to run the `remote-state` again.

### Environment

The `backend.tf` uses empty configuration which means that it expets proper key values in form of a file.
Then during init the value will be filled to the backend configuration. This allows for backend configuration
separation accross different environment with usage of `.tfbackend` files.
To use such file one need to run `terraform` with `-backend-config` flag which points to the `.tfbackend` file
and `-reconfigure` flag which resets the backend configuration. In this repository such files are placed in `terraform/config` path.
The taskfile defines one command to run init for the `prod` environment: `configure-backend-prod`.

Similarly we can use different variables for different environments. With use of `-var-file` flag which points to the `.tfvar` file
we can switch to different environment values with ease.
In this repository variable files are defined in the `terraform/config` path. Moreover, the values for `prod` are defined
in `variables.tf` as defaults for convinience.

### Plan and Apply

To run plan/apply operations enter `terraform` directory and hit `terraform plan` or `terraform apply` comand.

## Created AWS resources

All environment/application scoped resources will start with <company>-<business-unit>-<application>-<environment> prefix. The values can be changed by adding additional variable
file (together with backend file) for different environment.

### Network part

All networking resources can be found under `terraform/network.tf` file.

- VPC with internet gateway to establish connectivity with IP CIDR `10.0.0.0/16`
- two private subnets in separate AZs with CIDRs `10.0.1.0/24` and `10.0.2.0/24`
- two private db subnets in separate AZs with CIDRs `10.0.3.0/24` and `10.0.4.0/24`
- two public subnets in separate AZs with CIDRs `10.0.101.0/24` and `10.0.102.0/24`
- NAT Gateway in single AZ
- Route pollicies to make the connectivity work
- data resource for the domain

### ECS part

All ECS part can be found under `terraform/ecs.tf` file.

- ECS cluster with enabled CloudWatch monitoring with default capacity provider which will distribute the tasks between On-demand and Spot instances with 80/20 ratio with 2 first tasks always running on On-demand instances.

- ECS service where the tasks are deployed to the private subnets to not expose the service to the world (yet).

- ECS Task Definition with CloudWatch monitoring enabled. Set up as a Fargate tasks.

- IAM policy with S3 bucket access attached to the task role.


### Security Group part

- ALB SG (allows ingress from cidrs defined in `locals.tf`)
- ECS SG (allows ingress from ALB on 80 port and egrees to MySQL on 3306 port)
- MySQL SG (allows ingress from ECS SG on 3306 port)

### ALB part

- ALB with SSL termination (certificate attached) will be created. Traffic for HTTP gets redirected to HTTPS port while HTTPS traffic will be SSL terminated and passed to the Target Group (with ECS task as a target) on 80 port.

- ACM certificate for `example.com` domain which is connected to HTTPS listener (SSL termination).

- Route53 CNAME record which points `<appliction>-<environment>` subdomain to ALB DNS.

### S3 part

- KMS key used for bucket encryption
- S3 bucket with private ACL, versioning enabled and server side encryption set to KMS key
