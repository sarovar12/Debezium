IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'customers_db')
BEGIN
    CREATE DATABASE customers_db;
END
GO