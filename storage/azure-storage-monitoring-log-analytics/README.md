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
