# Data Pipeline

## Workflow

### Step 1: Upload Data
Transaction CSV files are uploaded to Amazon S3.

### Step 2: Data Cleaning
AWS Lambda cleans and validates transaction records.

### Step 3: Store Processed Data
Cleaned files are stored in a processed S3 location.

### Step 4: Load to Database
A Lambda function loads cleaned records into Amazon RDS MySQL.

### Step 5: Analytics
Power BI connects to RDS for reporting and visualization.

## Benefits
- Automated processing
- Improved data quality
- Faster reporting
