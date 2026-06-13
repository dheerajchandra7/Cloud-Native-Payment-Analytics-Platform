# AWS Setup

## Services Used

### Amazon S3
- Raw transaction storage
- Processed transaction storage

### AWS Lambda
- Data cleaning
- Data validation
- Data transformation

### Amazon RDS MySQL
- Stores cleaned transaction records

### IAM
- Secure access management

### CloudWatch
- Monitoring and logging

## Deployment Steps
1. Create S3 bucket
2. Create RDS instance
3. Configure IAM roles
4. Deploy Lambda functions
5. Configure S3 triggers
6. Connect Power BI to RDS
