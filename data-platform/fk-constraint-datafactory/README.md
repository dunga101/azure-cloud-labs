# Foreign Key Constraint Failure in Azure Data Factory Pipeline

## 🎯 Objective
Load CSV data from Azure Blob Storage into Azure SQL Database using Azure Data Factory.

---

## 🏗 Architecture
- Azure Blob Storage (CSV files)
- Azure Data Factory (Copy Activity)
- Azure SQL Database (target)

---

## ⚠️ Issue Encountered

Pipeline execution failed with error:
The INSERT statement conflicted with the FOREIGN KEY constraint
"FK_Orders_customer_..."

---

## 🔍 Root Cause

The `Orders` table contains a foreign key:
Orders.customer_id → Customers.customer_id

However:
- Orders data was loaded **before Customers**
- This caused referential integrity violation

---

## 🧠 Analysis

Azure Data Factory does NOT automatically handle relational dependencies.

Data must be loaded in correct order:
1. Customers
2. Orders
3. Transactions

---

## ✅ Resolution

Two possible solutions:

### Option 1 (Correct approach)
Load tables in proper sequence:
- Customers → Orders → Transactions

### Option 2 (Temporary workaround)
Drop foreign key constraint before load, then re-create after

---

## 📌 Key Learning

- Data pipelines must respect relational constraints
- Azure Data Factory does not enforce load ordering
- Understanding database relationships is critical for data engineering

---

## 🚀 Outcome

Pipeline successfully diagnosed and corrected by identifying data dependency issue.

---

## 📸 Screenshots

(to be added)
