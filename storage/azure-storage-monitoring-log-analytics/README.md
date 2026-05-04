# Azure Storage Monitoring with Log Analytics

## Overview
This lab demonstrates how to monitor Azure Blob Storage activity using Azure Monitor and Log Analytics.

The objective is to capture blob access events (such as downloads) and analyze them using KQL queries for observability and troubleshooting.

---

## Architecture

![Architecture](./architecture.png)

### Flow

**Data Flow (User Activity):**
- User uploads/downloads files to Blob Container

**Monitoring Flow (Telemetry):**
- Storage Account → Diagnostic Settings → Log Analytics → KQL Query

---

## Components

- Azure Storage Account (Standard, GRS, Hot tier)
- Blob Container (`monitor-blobs-container`)
- Log Analytics Workspace
- Diagnostic Settings (StorageRead enabled)

---

## Key Implementation Steps

1. Created storage account
2. Created blob container and uploaded files
3. Created Log Analytics workspace
4. Enabled diagnostic settings (StorageRead → Log Analytics)
5. Generated activity (blob download)
6. Queried logs using KQL

---

## KQL Query

```kql
StorageBlobLogs
| where TimeGenerated > ago(1h)
| where OperationName == "GetBlob"
| project TimeGenerated, AuthenticationType, RequesterObjectId, OperationName, Uri
Observations
Blob downloads generate GetBlob operations
Authentication method observed: SAS
Logs are not real-time (delay observed)
Only activity after enabling diagnostics is captured
Lessons Learned
Azure Storage does not emit logs by default
Diagnostic settings must be explicitly configured
There is ingestion delay in Azure Monitor
KQL is essential for log analysis and troubleshooting
Monitoring and data flow are separate pipelines
Future Improvements
Track write/delete operations (PutBlob, DeleteBlob)
Create alerts for abnormal access patterns
Visualize logs using Azure Workbooks
Integrate with Microsoft Sentinel for security monitoring


---

# 🧩 Step 3 — queries.kql

Create a file:

```plaintext
queries.kql

// Recent blob downloads
StorageBlobLogs
| where OperationName == "GetBlob"
| sort by TimeGenerated desc

// All operations
StorageBlobLogs
| sort by TimeGenerated desc

// Filter by authentication type
StorageBlobLogs
| where AuthenticationType == "SAS"

## Notes

- Logs required 2–5 minutes to appear in Log Analytics
- No results initially due to ingestion delay
- Additional blob download was required after enabling diagnostics
- Verified that only post-diagnostic activity is captured
