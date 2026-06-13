# Cloud-Native Payment Analytics Platform

An end-to-end, serverless data engineering and analytics solution that automatically ingests a daily payment transaction CSV, cleans and validates it through an AWS pipeline, loads it into a relational data store, and refreshes interactive Power BI dashboards — with no manual intervention required.

## Overview

This project simulates a real-world fintech data platform with a **fully automated daily refresh cycle**. Every day, a new transaction CSV is uploaded to Amazon S3, which automatically triggers AWS Lambda to clean and validate the data, load it into Amazon RDS (MySQL), and update the underlying tables that Power BI reads from. The dashboards reflect the latest data dynamically — transaction volume, revenue, payment method performance, merchant activity, and success/failure trends are always up to date without any manual ETL or report rebuilding.

## Architecture

```
Daily Transaction CSV (uploaded automatically each day)
        │
        ▼
Amazon S3 (raw/)  ──S3 Event──▶  AWS Lambda (Data Cleaning ETL)
        │                                 │
        │                                 ▼
        │                       Amazon S3 (cleaned/ & quarantine/)
        │                                 │
        │                          S3 Event Trigger
        │                                 ▼
        │                       AWS Lambda (RDS Loader)
        │                                 │
        │                                 ▼
        │                       Amazon RDS (MySQL — payment_analytics.transactions)
        │                                 │
        │                                 ▼
        │                Power BI Dashboards (auto-refreshed with latest data)
        │
   Supporting Services: AWS IAM (access control) · Amazon CloudWatch (logs & monitoring)
```

**Daily automated workflow:**
1. A new transaction CSV is uploaded to the S3 raw zone every day (manually, via script, or via a scheduled job).
2. The upload triggers an S3 `ObjectCreated` event, which automatically invokes the cleaning Lambda — no manual step required.
3. The cleaning Lambda removes duplicates, standardizes text fields, parses timestamps, fills missing values, and validates each record.
4. Valid records are written to `cleaned/`; invalid records are written to `quarantine/` with a reason code.
5. A second S3 event automatically triggers the loader Lambda, which connects to RDS (via VPC) and batch-inserts (50 records/batch) cleaned records using `INSERT IGNORE` to prevent duplicates — so re-running or re-uploading never creates double counts.
6. Power BI connects directly to RDS MySQL. On each scheduled/manual refresh, the dashboards automatically pull in the newly loaded day's transactions — KPIs, trends, and charts update dynamically with zero manual data prep.

## Key Features

- **Daily automated ingestion** — a new transaction CSV is uploaded to S3 every day, kicking off the entire pipeline with zero manual steps.
- **Automatic cleaning & validation** — AWS Lambda standardizes, deduplicates, and validates each day's data on arrival.
- **Self-loading database** — cleaned records are automatically batch-inserted into RDS MySQL with duplicate protection (`INSERT IGNORE`).
- **Dynamic dashboards** — Power BI connects live to RDS, so KPIs, trends, and charts update automatically as new daily data lands, without rebuilding the report.
- **Quarantine & monitoring** — invalid records are isolated for review, and CloudWatch tracks every pipeline run.

## Tech Stack

| Layer | Technology |
|---|---|
| Storage | Amazon S3 (raw, cleaned, quarantine zones) |
| Processing | AWS Lambda (Python, Pandas, Boto3) |
| Database | Amazon RDS for MySQL |
| Access Control | AWS IAM (least-privilege roles) |
| Monitoring | Amazon CloudWatch |
| Visualization | Power BI |

## Data Cleaning Logic

The cleaning Lambda (`lambda/transaction_cleaner.ipynb`) performs:
- **Deduplication** on `transaction_id`
- **Standardization** of `merchant`, `currency`, `payment_method`, and `status` (trim + uppercase)
- **Timestamp parsing** with error coercion
- **Missing value handling**: nulls/blanks mapped to `UNKNOWN_MERCHANT`, `UNKNOWN_STATUS`, `UNKNOWN_CURRENCY`, `UNKNOWN_PAYMENT_METHOD`
- **Validation rules**: records with missing/zero amounts, unparseable timestamps, or invalid status values are routed to a quarantine file with a `reason` column (`INVALID_AMOUNT`, `INVALID_TIMESTAMP`, `INVALID_STATUS`)

## Database Schema

```sql
CREATE TABLE transactions (
    transaction_id   VARCHAR(50) PRIMARY KEY,
    transaction_date DATE,
    merchant         VARCHAR(100),
    payment_method   VARCHAR(50),
    currency         VARCHAR(10),
    amount           DECIMAL(12,2),
    status           VARCHAR(20)
);
```

## Repository Structure

```
├── architecture/         # Architecture & pipeline diagrams
├── data/                 # Sample raw and cleaned transaction CSVs
├── docs/                 # Project documentation
│   ├── project_overview.md
│   ├── data_pipeline.md
│   ├── aws_setup.md
│   └── business_use_cases.md
├── images/               # Dashboard screenshots and architecture diagrams
├── lambda/               # Lambda function notebooks (cleaning, RDS loading)
├── power BI/              # Power BI dashboard files (.pbix) and exports
├── scripts/              # Utility scripts (S3 loader)
└── sql/                  # Database schema
```

## Dashboards

The Power BI report connects live to RDS MySQL and refreshes automatically as each day's transactions are loaded, with three pages:

1. **Payment Transaction Overview** — KPIs (total transactions, total amount, success/failure/pending rates), payment method success rates, and transaction status distribution.
2. **Payment Method & Merchant Analysis** — Payment method usage breakdown and merchant-wise transaction volume with success rate coloring.
3. **Transaction Trends** — Monthly transaction value trend and success vs. failure rate trend, filterable by currency, merchant, and quarter.

## Business Use Cases

- **Transaction Monitoring** — track volume and performance over time
- **Success & Failure Analysis** — identify failed transactions and monitor success rates
- **Revenue Analysis** — monitor transaction amounts and revenue trends
- **Payment Method Analysis** — compare UPI, cards, wallets, and net banking
- **Merchant Analytics** — analyze per-merchant transaction activity
- **Executive KPI Reporting** — total transactions, revenue, success/failure/pending rates

## Setup

1. Create an S3 bucket with `raw/`, `cleaned/`, and `quarantine/` prefixes.
2. Provision an Amazon RDS MySQL instance and run `sql/schema.sql`.
3. Configure IAM roles with least-privilege access for Lambda to S3 and RDS.
4. Deploy the cleaning Lambda (`lambda/transaction_cleaner.ipynb`) with an S3 `ObjectCreated` trigger on `raw/`.
5. Deploy the RDS loader Lambda with an S3 `ObjectCreated` trigger on `cleaned/`.
6. Enable CloudWatch logging for both functions.
7. Schedule a daily upload of the transaction CSV to `raw/` (e.g., a cron job, scheduled script, or upstream system export) — this single step triggers the entire pipeline end to end.
8. Connect Power BI to the RDS instance and open `power BI/Payment_Analytics.pbix`; set a refresh schedule so the dashboards pick up each day's newly loaded data automatically.

## Sample Data

The `data/` folder contains sample raw and cleaned transaction datasets for local testing and demonstration without requiring live AWS resources.
