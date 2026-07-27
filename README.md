# AWS Infrastructure as Code Pipeline
##  Requirements
Requirements for a self managed relational database in the cloud
### Functional Requirements
- Provide a self-managed relational database hosted in AWS.
- Support the PostgreSQL database engine.
- Store persistent application data.
- Accept connections only from authorized clients.
- Support database creation, user management, and authentication.
- Support backup and restoration of database data.

### Non-Functional Requirements
### Maintainability
- Infrastructure shall be reproducible using Infrastructure as Code (IaC).
- Configuration changes shall be idempotent.
- IaC shall be version controlled.

#### Security
- Encrypt data at rest.
- Encrypt data in transit.
- The database shall be directly accessible from the public Internet.
- Restrict network access using Security Groups.
- Administrative access shall be restricted to trusted IP addresses.
- Support key-based SSH authentication for administration.
- Store database credentials securely.
- Principle of least privilege shall be applied to AWS IAM permissions.

#### Reliability
- Support automated backups.
  - Database backups shall be retained for a configurable number of days.
- Support database recovery from backups.
  - The database should be recoverable after an EC2 instance failure.
- Ensure data persistence across instance restarts.

#### Scalability
- Support vertical scaling by increasing compute resources.
- Support storage expansion without data loss.

#### Operations
- Provide monitoring of CPU, memory, storage, and database health.
- Collect and retain system and database logs.

### Constraints
- Cloud provider shall be AWS.
- Database shall be self-managed on an EC2 instance.
- Database engine shall be PostgreSQL.
- Infrastructure shall be provisioned using Terraform.
- Server and database configuration shall be managed using Ansible.

## Architecture
### AWS Implementation
| Category                    | Component                   | Purpose                                           |
| --------------------------- | --------------------------- | ------------------------------------------------- |
| **Provider**                | AWS                         | Cloud platform                                    |
| **Network**                 | VPC                         | Isolated network                                  |
|                             | Public Subnet               | Hosts the EC2 instance                            |
|                             | Internet Gateway            | Internet access for public resources              |
|                             | Route Table                 | Routing configuration                             |
| **Compute**                 | EC2 Instance                | Server for DBMS                                   |
| **Storage**                 | S3 Bucket                   | Terraform backend, backups                        |
|                             | Amazon EBS                  | ...                                               |
| **Identity**                | IAM Role & Instance Profile | Secure AWS access without embedded credentials    |
| **Monitoring**              | CloudWatch                  | Operation and performance monitoring              |
| **Logging**                 |                             | Logs                                              |
| **Security**                | Security Groups             | Firewall rules                                    |
|                             | AWS KMS                     | Encryption                                        |
| **Database**                | PostgreSQL                  | DBMS                                              |

### IaC Orchestration
Provisioning:	Terraform
Configuration:	Ansible
CICD pipelines: GitHub Actions

## Infrastructure Provisioning
### Terraform
- Creates cloud infrastructure
- Manages infrastructure state
## Configuration Management
### Ansible
- Configure the servers
- Deploy applications
- Manages application state
## CICD
### GitHub Actions