# 🔍 Master Flow Monitoring Guide

## Quick Start

### 1. Setup (One-Time)

#### Create the Dataverse Table
1. Go to **Power Apps** (make.powerapps.com)
2. Select your environment
3. Navigate to **Tables** → **+ New table** → **New table**
4. Configure:
   - **Display name**: `Master Flow Checks`
   - **Plural name**: `Master Flow Checks`
   - Click **Save**
5. Add columns as documented in `DATAVERSE_TABLE_SCHEMA.md`

#### Import Solution
1. Import `DeltaFlowsFramework_v1.0.0.17_MASTER_LOGGING_*.zip`
2. Connect the **Dataverse connection reference** when prompted
3. Turn on both flows

---

## 2. Monitoring During Execution

### Real-Time View
While the Master flow is running:

1. Open **Power Apps** → **Tables** → **Master Flow Checks**
2. Switch to **Active Master Flow Checks** view
3. Look for records with:
   - **Status** = "Checking"
   - **Check End Time** = *blank*
   - **Check Start Time** = more than 5 minutes ago

**These are your long-running or hung checks!**

### Quick Query for Hung Checks
```
Status = "Checking" 
AND Check Start Time < [Now - 5 minutes]
AND Check End Time is null
```

---

## 3. Post-Execution Analysis

### Slowest Tables (Last Run)
1. Filter: **Flow Run ID** = *[your run ID]*
2. Add calculated column: **Duration** = `Check End Time - Check Start Time`
3. Sort by **Duration** (descending)
4. Top 5 = your slowest tables

### Tables That Failed Checks
```
Filter: Status = "Failed"
Sort: Check Start Time (newest first)
View: Source Table, Error Message
```

### Average Duration by Table (Historical)
Group by: **Source Table**
Show: 
- Count of checks
- Average duration
- Max duration
- Failure rate

---

## 4. Identifying the Problem

### Scenario A: Specific Table Always Slow
**Symptom**: Same table shows up as slow every run  
**Analysis**: Check `wspCheckOrGetChanges` stored procedure performance for that table  
**Action**: Optimize indexes on source table or add WHERE clause filtering

### Scenario B: Random Tables Hang
**Symptom**: Different tables hang on different runs  
**Analysis**: Database server resource contention  
**Action**: 
- Reduce concurrency from 20 to 10 in Master flow
- Check SQL Server CPU/memory during run
- Look for locking/blocking queries

### Scenario C: All Checks Slow at Specific Time
**Symptom**: All tables take longer during certain hours  
**Analysis**: Server busy during peak hours  
**Action**: Schedule Master flow during off-peak hours

---

## 5. Power Automate Flow Run Monitoring

### While Flow is Running
1. Open **Power Automate** (make.powerautomate.com)
2. Go to **My flows** → **Master**
3. Click on the running flow instance
4. Expand **Does_the_Source_Data_View_Have_Changes**
5. Look for iterations that are **"Running"** for a long time

### Cross-Reference with Dataverse
1. Note which iteration is stuck (shows table name)
2. Query `Master Flow Checks` for that table name
3. See the exact start time and duration

---

## 6. Alerting (Advanced)

### Option A: Power Automate Alert Flow
Create a separate scheduled flow:
1. **Trigger**: Every 5 minutes
2. **Action**: Query `Master Flow Checks` for stuck checks
3. **Condition**: If any found with Status = "Checking" AND Start Time > 10 min ago
4. **Action**: Send Teams/Email alert with table name

### Option B: Power BI Dashboard
1. Connect Power BI to Dataverse
2. Create visual showing "Current Checks In Progress"
3. Set up alert when count > 0 for more than 10 minutes
4. Include table name in alert

---

## 7. Performance Tuning Based on Logs

### Analyze Your Data
After running for a week, query to find:

#### Slowest Tables (Optimize First)
```sql
SELECT 
  trz_sourcetable,
  AVG(DATEDIFF(second, trz_checkstarttime, trz_checkendtime)) AS AvgSeconds,
  COUNT(*) AS CheckCount
FROM trz_masterflowcheck
WHERE trz_checkendtime IS NOT NULL
GROUP BY trz_sourcetable
ORDER BY AvgSeconds DESC
```

#### Failure Rate by Table
```sql
SELECT 
  trz_sourcetable,
  COUNT(*) AS TotalChecks,
  SUM(CASE WHEN trz_status = 'Failed' THEN 1 ELSE 0 END) AS Failures,
  (SUM(CASE WHEN trz_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS FailurePercent
FROM trz_masterflowcheck
GROUP BY trz_sourcetable
HAVING COUNT(*) > 10
ORDER BY FailurePercent DESC
```

### Tuning Actions

| Finding | Action |
|---|---|
| **5+ tables take > 60 seconds** | Reduce concurrency to 10 |
| **1-2 specific tables always slow** | Optimize those tables' indexes |
| **All checks slow after 4pm** | Reschedule to off-peak hours |
| **High failure rate on specific table** | Check `wspCheckOrGetChanges` SP logic |
| **Duration increasing over time** | Archive/partition historical data |

---

## 8. Troubleshooting

### Logs Not Appearing
1. **Check Dataverse connection**: Edit Master flow → Connections → Verify Dataverse is connected
2. **Check table name**: Ensure table is named `trz_masterflowchecks` (with your publisher prefix)
3. **Check permissions**: Flow needs Create/Update permissions on the table

### "Record Not Found" Error on Update
- The log start action failed - check Dataverse connection
- Table schema mismatch - verify all columns exist

### All Checks Show as "Checking" Forever
- The update action is failing (check flow run history for errors)
- Verify the `trz_masterflowcheckid` column exists and is the primary key

---

## 9. Example: Finding Your Slow Table

### Step-by-Step
1. Start Master flow
2. Wait 5 minutes
3. Open **Master Flow Checks** table in Power Apps
4. Filter: **Check Start Time** >= Today AND **Status** = "Checking"
5. Sort by: **Check Start Time** (oldest first)
6. **The top record is your bottleneck!**

Example result:
```
Name: Check: wsvTimeCardHistory
Source Table: wsvTimeCardHistory
Check Start Time: 10/2/25 2:15:30 PM
Check End Time: (blank)
Status: Checking
Duration: 12 minutes and counting...
```

**Now you know**: `wsvTimeCardHistory` is the problem table!

### Next Steps
1. Check that table's row count in source database
2. Review indexes on `wsvTimeCardHistory`
3. Check `wspCheckOrGetChanges` execution plan for that table
4. Consider adding filters or date ranges to limit scope

---

## 10. Long-Term Strategy

### Daily Review
- Check for any failed checks
- Note average duration trends
- Identify new slow tables

### Weekly Optimization
- Focus on top 3 slowest tables
- Test index changes in dev environment
- Measure improvement

### Monthly Analysis
- Review overall execution time trends
- Adjust concurrency settings if needed
- Archive old logs (keep 90 days)

---

## Quick Reference Commands

### Find Currently Running Checks
```
Power Apps → Tables → Master Flow Checks
Filter: Status = "Checking" AND Check End Time is null
Sort: Check Start Time ascending
```

### Find Yesterday's Slowest Checks
```
Filter: Check Start Time >= [Yesterday] AND Check End Time is not null
Add Column: Duration (calculated)
Sort: Duration descending
Top: 10
```

### Find All Failures This Week
```
Filter: Status = "Failed" AND Check Start Time >= [This Week]
Sort: Check Start Time descending
View: Source Table, Error Message
```

---

**🎯 You now have complete visibility into your Master flow's table checking performance!**
