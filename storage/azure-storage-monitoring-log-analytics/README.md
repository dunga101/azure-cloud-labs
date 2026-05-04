# Azure Storage Monitoring with Log Analytics

## Overview

This project demonstrates how to monitor Azure Blob Storage activity using Azure Monitor and Log Analytics.

The objective is to capture blob access events, such as downloads, and analyze them using KQL queries for observability and troubleshooting.

---

## Architecture

![Architecture](./architecture.png)

---

## Flow

### Data Flow: User Activity

* User uploads or downloads files through the Azure Portal.
* Files are stored inside the Blob Container.

### Monitoring Flow: Telemetry

* Blob activity occurs in the Storage Account.
* Diagnostic Settings collect selected log categories.
* StorageRead logs are sent to Log Analytics.
* KQL is used to query and analyze the captured activity.

---

## Components

* Azure Storage Account
* Blob Container: `monitor-blobs-container`
* Log Analytics Workspace
* Diagnostic Settings
* StorageRead log category
* KQL query editor

---

## Key Implementation Steps

1. Created an Azure Storage Account.
2. Created a Blob Container.
3. Uploaded sample files to the container.
4. Created a Log Analytics Workspace.
5. Enabled Diagnostic Settings for the Blob service.
6. Selected the `StorageRead` category.
7. Routed logs to the Log Analytics Workspace.
8. Downloaded a blob to generate read activity.
9. Queried the activity using KQL.
10. Verified that the `GetBlob` operation appeared in Log Analytics.

---

## Primary KQL Query

```kql
StorageBlobLogs
| where TimeGenerated > ago(1h)
| where OperationName == "GetBlob"
| project TimeGenerated,
          AuthenticationType,
          RequesterObjectId,
          OperationName,
          Uri
```

---

## Query Purpose

This query searches the `StorageBlobLogs` table for blob download activity within the last hour.

The `GetBlob` operation represents a blob read/download event. The query returns useful audit fields such as the time of access, authentication method, requester identity, operation name, and blob URI.

---

## Observations

* Blob downloads generate `GetBlob` operations.
* Authentication method observed: `SAS`.
* Logs are not real-time and may take a few minutes to appear.
* Only activity after enabling Diagnostic Settings is captured.
* Azure Monitor does not backfill earlier storage activity into Log Analytics.

---

## Lessons Learned

* Azure Storage does not emit detailed logs to Log Analytics by default.
* Diagnostic Settings must be explicitly configured.
* The Blob service must be selected when configuring storage diagnostics.
* Log Analytics is the destination where logs are stored and queried.
* Azure Monitor log ingestion can be delayed.
* Fresh activity may be required after enabling diagnostics.
* Monitoring flow and data flow are separate pipelines.
* KQL is essential for troubleshooting, auditing, and validating resource activity.

---

## Additional KQL Queries

### Recent Blob Downloads

```kql
StorageBlobLogs
| where OperationName == "GetBlob"
| sort by TimeGenerated desc
```

### All Recent Blob Operations

```kql
StorageBlobLogs
| sort by TimeGenerated desc
```

### Filter by SAS Authentication

```kql
StorageBlobLogs
| where AuthenticationType == "SAS"
| sort by TimeGenerated desc
```

### Track Write Operations

```kql
StorageBlobLogs
| where OperationName == "PutBlob"
| sort by TimeGenerated desc
```

### Track Delete Operations

```kql
StorageBlobLogs
| where OperationName == "DeleteBlob"
| sort by TimeGenerated desc
```

---

## Troubleshooting Notes

### Issue Encountered

Initial KQL query returned no results.

### Cause

The logs had not appeared yet due to Azure Monitor ingestion delay. A fresh blob download was also required after enabling diagnostics.

### Resolution

1. Confirmed Diagnostic Settings were enabled.
2. Confirmed `StorageRead` was selected.
3. Confirmed logs were routed to the correct Log Analytics Workspace.
4. Downloaded a blob again to generate a new `GetBlob` event.
5. Waited a few minutes for ingestion.
6. Re-ran the KQL query.
7. Verified that the `GetBlob` operation appeared successfully.

---

## Validation Result

The final query returned a successful `GetBlob` result in the `StorageBlobLogs` table.

The result confirmed that the monitoring pipeline was functioning correctly:

```text
Blob Download Activity
        ↓
Azure Storage Account
        ↓
Diagnostic Settings
        ↓
Log Analytics Workspace
        ↓
KQL Query Result
```

---

## Real-World Relevance

This lab demonstrates a foundational cloud observability pattern used in production Azure environments.

The same approach can be used to:

* Audit storage access.
* Investigate unusual blob downloads.
* Validate diagnostic log routing.
* Support security investigations.
* Build alerting rules for abnormal activity.
* Feed logs into Microsoft Sentinel for SIEM use cases.

---

## Future Improvements

* Enable additional diagnostic categories such as `StorageWrite` and `StorageDelete`.
* Create an alert rule for abnormal blob download activity.
* Build an Azure Workbook to visualize storage access patterns.
* Integrate Storage logs with Microsoft Sentinel.
* Compare SAS-based access with Microsoft Entra ID-based access.
* Add screenshots of query results and alert configuration.

---

## Summary

This project shows how Azure Storage activity can be monitored using Diagnostic Settings, Log Analytics, and KQL.

The key takeaway is that storage activity must be routed intentionally into Log Analytics before it can be queried. Once configured, KQL provides a powerful way to investigate and validate blob access events.
