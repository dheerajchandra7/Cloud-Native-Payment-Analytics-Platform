
CREATE DATABASE IF NOT EXISTS payment_analytics;
USE payment_analytics;

CREATE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    transaction_date DATE,
    merchant VARCHAR(100),
    payment_method VARCHAR(50),
    currency VARCHAR(10),
    amount DECIMAL(12,2),
    status VARCHAR(20)
);