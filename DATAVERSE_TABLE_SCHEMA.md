# Dataverse Table Schema for Master Flow Monitoring

## 📊 Table: `trz_masterflowchecks`

### Purpose
Tracks each individual table change check performed by the Master flow's "Does_the_Source_Data_View_Have_Changes" loop. Enables identification of slow-running or hanging table checks.

### Display Name
**Master Flow Checks**

### Schema Name
**trz_masterflowcheck**

### Primary Key
**trz_masterflowcheckid** (auto-generated GUID)

---

## 📋 Columns

| Display Name | Schema Name | Data Type | Max Length | Required | Description |
|---|---|---|---|---|---|
| **Name** | `trz_name` | Single Line of Text | 200 | ✅ Yes | Primary name field - shows "Check: [TableName]" |
| **Flow Run ID** | `trz_flowrunid` | Single Line of Text | 100 | ✅ Yes | Unique ID for the Master flow execution |
| **Flow Name** | `trz_flowname` | Single Line of Text | 100 | ❌ No | Master flow workflow ID |
| **Source Table** | `trz_sourcetable` | Single Line of Text | 200 | ✅ Yes | Name of source table being checked |
| **Target Table** | `trz_targettable` | Single Line of Text | 200 | ❌ No | Name of target table |
| **Check Start Time** | `trz_checkstarttime` | Date and Time | - | ✅ Yes | When the change check started |
| **Check End Time** | `trz_checkendtime` | Date and Time | - | ❌ No | When the change check completed |
| **Changes Found** | `trz_changesfound` | Yes/No | - | ❌ No | True if changes were detected |
| **Status** | `trz_status` | Single Line of Text | 50 | ✅ Yes | Status: "Checking", "Completed", "Failed" |
| **Error Message** | `trz_errormessage` | Multiple Lines of Text | 4000 | ❌ No | Error details if check failed |
| **Processing Status** | `trz_processingstatus` | Choice | - | ❌ No | Status of child flow execution |
| **Child Flow Run ID** | `trz_childflowrunid` | Single Line of Text | 100 | ❌ No | Run ID of the child flow execution |
| **Child Flow Start Time** | `trz_childflowstarttime` | Date and Time | - | ❌ No | When child flow processing started |
| **Child Flow End Time** | `trz_childflowendtime` | Date and Time | - | ❌ No | When child flow processing completed |
| **Child Flow Error** | `trz_childflowerror` | Multiple Lines of Text | 4000 | ❌ No | Error from child flow if failed |

---

## 🔄 Processing Status Choice Values

The `trz_processingstatus` field should be a **Choice** (Option Set) with these values:

| Label | Value |
|---|---|
| Not Needed | 0 |
| Pending | 1 |
| Processing | 2 |
| Completed | 3 |
| Failed | 4 |
| Retrying | 5 |

---

## 🎯 Usage

### Creating the Table in Dataverse

1. **Navigate to Power Apps** (make.powerapps.com)
2. Select your **environment**
3. Go to **Tables** → **New table** → **New table**
4. Set:
   - **Display name**: `Master Flow Checks`
   - **Plural name**: `Master Flow Checks`
   - **Schema name**: `trz_masterflowcheck` (system will add publisher prefix)
5. **Save** the table
6. Add the columns listed above using **+ New** → **Column**

### Querying Logs

#### Find Long-Running Checks
```
Filter: Check Start Time > [Today] AND Status = "Checking"
Sort: Check Start Time (Oldest first)
```
Shows checks that started but haven't completed - likely hung.

#### Check Duration Analysis
Create a **calculated column** or **view** with:
```
Duration = Check End Time - Check Start Time
```
Then filter for checks taking > 5 minutes.

#### Today's Checks by Table
```
Filter: Check Start Time >= [Today]
Group by: Source Table
Show: Count, Avg Duration
```

---

## 📈 Power BI Integration (Optional)

Connect Power BI to this table for:
- **Real-time monitoring dashboard**
- **Duration trending over time**
- **Identification of consistently slow tables**
- **Failure rate analysis**

---

## 🔧 Alternative: Reuse Existing Table

If you prefer not to create a new table, you can modify the Master flow to use your existing **`trz_flowexecutionlogs`** table:

### Changes Needed
1. In the Master flow JSON, replace:
   - `"entityName": "trz_masterflowchecks"` → `"entityName": "trz_flowexecutionlogs"`
2. Map fields to existing columns in `trz_flowexecutionlogs`
3. Add a prefix like `"Check: "` to distinguish Master check logs from Framework execution logs

### Pros & Cons
| Approach | Pros | Cons |
|---|---|---|
| **New Table** | Clean separation, custom fields, easy querying | Requires table creation |
| **Reuse Existing** | No new table needed, unified logging | Mixed log types, less specific fields |

---

## 🚀 Benefits

✅ **Real-time visibility**: See which table is currently being checked  
✅ **Performance analysis**: Identify slow-running wspCheckOrGetChanges calls  
✅ **Failure tracking**: Catch and diagnose check errors  
✅ **Historical data**: Analyze patterns over time  
✅ **Proactive monitoring**: Set up alerts for long-running checks

---

## 📝 Example Records

| Name | Source Table | Check Start Time | Check End Time | Changes Found | Status | Duration |
|---|---|---|---|---|---|
| Check: wsvEmployeeBar | wsvEmployeeBar | 10/2/25 10:15:30 AM | 10/2/25 10:15:32 AM | Yes | Completed | 2 sec |
| Check: wsvTimeCard | wsvTimeCard | 10/2/25 10:15:30 AM | 10/2/25 10:18:45 AM | Yes | Completed | 3 min 15 sec |
| Check: wsvLeaveBalance | wsvLeaveBalance | 10/2/25 10:15:31 AM | *null* | No | Checking | **HUNG!** |

The third record shows a table check that started but never completed - this is what you're looking for!
