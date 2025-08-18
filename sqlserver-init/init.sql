CREATE DATABASE IF NOT EXISTS customers_db;
GO

USE customers_db;
GO

CREATE TABLE IF NOT EXISTS customers (
    id GUID PRIMARY KEY,
    name NVARCHAR(100),
    email NVARCHAR(100),
    created_at DATETIME
    );
GO
