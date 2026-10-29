# Issue #4 Native Prototype Validation

Date: 2026-10-22  
Simio: 20.295.56007.0  
Prototype: `/Project/Proto_V0_1_TaskTable`  
Persistent model file: not verified; MCP has no project-save operation and the Windows Computer Use native pipe was unavailable.

## Results

| Check | Status | Evidence and boundary |
|---|---|---|
| #3 shared data tables | Verified in live session; persistence unverified | `/Project/Model/Tables/Tbl_Tasks` has 83 rows and 13 columns including `OwnerCell` (ForeignKey); `Tbl_Cells` has 5 rows and keyed `CellID`; `Tbl_Stations` has 5 rows and a `CellID` ForeignKey. The independent workbook validator passed. These are live-session observations, not proof that the current root `.spfx` contains the edits. |
| Prototype structure | Partial | In the live Simio session, created `Src_TestAircraft -> Srv_Cell2Prototype -> Snk_TestAircraft` with two zero-travel Connectors, set `Srv_Cell2Prototype.Process Type` to `Task Sequence`, and inspected the task and resource requirement schemas. A separate `TS_Cell2Prototype` TaskSequence element was created for schema inspection but is not configured or referenced. No run was performed. |
| S1: filter one shared task table by cell | Not run | The live Server exposes `Processing Tasks` as a RepeatGroup and exposes no table-binding property for this task list. Its supported table references are for resource, material, and state-assignment tables. The requested `Tbl_Cells.SetRow`/filtered task binding was therefore not configured. The 20-task result is not claimed. |
| S2: resource count from `Mechanics` and preferred list selection | Not run | Task resource requirements expose `Select From List`, `Preferred Order`, and a number-of-resources field, but no task row was bound to them and no resource seize was run. |
| S3: overnight suspension | Property verified; scenario not run | The Server's default `Off Shift Rule` is `Suspend Processing`. No work schedule or 10-hour task scenario was configured, so the Tuesday 14:30 result is unverified. |
| S4: task time by aircraft type | Not run | The task RepeatGroup supports task processing-time expressions, but no `PlaneType` state, task-table row context, or two-aircraft deterministic comparison was configured. |
| Diagnostics | Passed for current in-memory prototype | `get_diagnostics` returned zero errors after the current prototype objects and TaskSequence element were created. Diagnostics must be repeated after reload. |
| Save/reload | Not run | No save tool is exposed by the MCP tool list. At the time of the original entry, Computer Use initialization failed because its native pipe was unavailable; the follow-up below records the later UI-channel result and current file hash. No claim is made that prototype edits reached disk. |

## Design consequence

Do not treat these checks as completed or use the prototype as evidence for #5 onward. First resolve how the installed Simio `ServerUsingTaskSequenceWithDataTables_Flexible` SimBit binds a cell-specific task set to a Server, or select and test one of Issue #4's fallback designs. Then run S1-S4, capture native trace/results, save a versioned `.spfx`, reopen it, and repeat diagnostics.

## Follow-up inspection: 2026-10-22

The Simio MCP endpoint is available in this session. The active UI model is `/Project/Model`; the Issue #4 test target remains `/Project/Proto_V0_1_TaskTable`.

| Check | Status | Follow-up evidence |
|---|---|---|
| RepeatGroup task template | Inspected | `Srv_Cell2Prototype.Processing Tasks` has one fixed tuple, with `TaskSequenceNumber=Tbl_Tasks.Seq`, `TaskName=Tbl_Tasks.TaskName`, conditional branch `Tbl_Tasks.OwnerCell==2`, and `TaskProcessingTime=Tbl_Tasks.T101_Mean`. The RepeatGroup reports `canAdd=false` and `canRemove=false`. |
| S2 resource selection | Blocked; not run | The tuple schema supports `Select From List`, `Preferred Order`, `TaskResourceRequirementsNumberOfResources`, and a resource list. MCP exposes whole-group replacement but no tuple-field setter; replacing the group was rejected because this required tuple cannot be removed. A generic `set_property` attempt on `Processing Tasks.TaskResourceRequirementsResourceType` was rejected as an unknown property. The tuple remains `ResourceType=Specific`, list unset, number of resources `1`; no resources were seized in a run. |
| S3 schedule | Blocked; not run | The Server task's off-shift rule is `Suspend Processing`, but the target exposes no work schedule collection or configured schedule, and the available element types do not expose a schedule element. No Tuesday 14:30 result is claimed. |
| S4 aircraft type | Blocked; not run | `Tbl_Tasks` has 14 columns but no `PlaneType`; the prototype model's `States` collection has no such state. The deterministic SA101/SA102 comparison is not configured, and 79.9/65.5 hours are not model results. |
| Logs, trace, diagnostics | No runtime evidence; diagnostics pass | All 15 available log types report no data. Trace is enabled but has zero lines and no output file. `get_diagnostics` reports zero errors. No run was performed during this follow-up. |
| Disk persistence | Unchanged; unverified | `Aerospace.spfx` and `snapshots/Aerospace_V0.3_PreS2_20261022.spfx` both hash to `7593661C386B9102278F02308128AA450CA36BD203E5E83317436929EEE04E19`; the model file timestamp is 2026-10-22 20:05:03. The live prototype edits are not saved in the file. |

Computer Use subsequently connected and brought the Simio window forward, confirming the prototype and selected Server on screen. However, the property-grid accessibility indexes were rejected as unavailable in the cached app state, while a coordinate input landed in another window; no property edit was made through Computer Use. Continue S2-S4 when tuple-row editing and schedule creation are reliably available through the Simio UI or a supported MCP operation. Preserve the current table data; do not narrow `Tbl_Tasks` to manufacture a one-task test.

## Follow-up retry: 2026-10-22

The user confirmed the prior window conflict had ended and authorized continuing Computer Use. The Simio MCP endpoint responds, but the Windows UI channel could not be recovered: after re-enumerating the unique `Aerospace - Simio RPS版本` window and reacquiring its handle, both activation and state capture failed with `failed to activate captured window`. No stale coordinates or UI indexes were reused after the failure.

MCP readback confirmed that the active model is still `/Project/Proto_V0_1_TaskTable`, not `/Project/Model`. `Srv_Cell2Prototype.Processing Tasks` remains the single fixed tuple documented above. Work-schedule and day-pattern collections are not exposed by the MCP collection/type APIs. No model run was started: run status is idle, trace is enabled with zero lines, and all 15 log types have zero records. A fresh diagnostics request returned a generic invocation error, so this retry provides no new diagnostics result.

No model property or table was changed in this retry. `Aerospace.spfx` and `snapshots/Aerospace_V0.3_PreS2_20261022.spfx` still have the same SHA-256 `7593661C386B9102278F02308128AA450CA36BD203E5E83317436929EEE04E19`. S2, S3, and S4 remain unconfigured and unrun; the 79.9/65.5 hour values and Tuesday 14:30 finish remain analytic expectations only. Resume these checks when the Simio UI channel can be activated or the MCP adds supported tuple-field and schedule editing.

## Follow-up status: 2026-10-23

The Simio endpoint was reinitialized over its local JSON-RPC transport. It reports Simio 20.297.56736.0 and 128 tools. The active model is /Project/Proto_V0_1_TaskTable; no model mutation or simulation run was performed during this follow-up.

| Check | Status | Follow-up evidence |
|---|---|---|
| Active model and run state | Inspected; idle | get_active_model returned /Project/Proto_V0_1_TaskTable. get_run_status reports no active run, pending command, warnings, or start/completion timestamp. |
| S1 task-table filter | Configured; not run | Srv_Cell2Prototype.Processing Tasks is one fixed tuple (canAdd=false, canRemove=false) using Tbl_Tasks.Seq, Tbl_Tasks.TaskName, and Tbl_Tasks.OwnerCell==2. Tbl_Tasks has 83 rows. No Task log records exist; the expected 20 tasks are not confirmed. |
| S2 resource selection | Not configured; not run | The fixed tuple still has ResourceType=Specific, blank resource name, and NumberOfResources=1; its task resource off-shift rule is Suspend Processing. The model contains Mech_C2_01–Mech_C2_08 and Lst_Mech_C2, but no resource allocation result has been observed. |
| S3 schedule | Not configured; not run | Srv_Cell2Prototype.Capacity Type remains Fixed. The Server exposes Off Shift Rule=Suspend Processing but no Work Schedule property. The MCP tool list and creatable collection kinds expose no schedule/day-pattern operations. No Tuesday 14:30 result is claimed. |
| S4 aircraft-type time | Not configured; not run | The Source creates DefaultEntity. Searching the active prototype for PlaneType returned no references, and the model's custom States collection contains no PlaneType. Thus 79.9/65.5 h remain analytic expectations, not Simio results. |
| Logs and diagnostics | No runtime evidence | All 15 available logs, including Task, TaskState, and ResourceUsage, have zero records. No run was executed in this follow-up. |
| Computer Use | Unavailable | Initializing @oai/sky returned: Computer Use native pipe is unavailable: failed to connect native pipe: 系统找不到指定的文件。 No UI coordinates or controls were used. |
| Disk baseline | Snapshotted; not edited | Root Aerospace.spfx is 177,085 bytes, last written 2026-10-22 22:52:59, SHA-256 19D4253444B5453719D2C0063F4DE6208DA36D321EA8870BC756D742C8322023. A byte-for-byte copy was created as snapshots/Aerospace_PreS2_20261023_053448.spfx with the same SHA-256. This differs from the earlier 174,533-byte baseline; the current source was preserved, not overwritten. |

No further work is in progress. Resume only when the user restarts the task and the Simio UI/MCP capabilities needed to edit the task tuple and configure a work schedule are available.

## Follow-up: 2026-10-23, Cell1 S4 completion attempt

The user confirmed that the root model file had been saved and that `Initial Work Schedule` now points to the intended schedule. The live MCP session reports Simio 20.297.56736.0. The target remained `/Project/Proto_V0_1_TaskTable`; no changes were made to `/Project/Model`.

| Check | Status | Evidence and boundary |
|---|---|---|
| Cell2 work schedule and mechanic requirement | Read back | `Srv_Cell2Prototype.Initial Work Schedule=StandardWeek`. Its single Processing Tasks tuple still requests `Lst_Mech_C2`, with `Tbl_Tasks.Mechanics` resources seized simultaneously. This confirms the mechanic requirement is enabled. |
| Cell1 S4 | Not completed | `Srv_Cell1Prototype` was `Process Type=Specific Time` with no Processing Tasks group when inspected. A prior runtime record shows a Cell1 test entity entered, then failed at 6 simulation hours because `ProcessingTasks[1].TaskSequenceNumber=Tbl_Tasks.Seq` could not resolve a current `Tbl_Tasks` row reference. This is a historical runtime error, not a new run in this follow-up. |
| Temporary Cell1 configuration | Restored | During inspection, Cell1 was temporarily changed to Task Sequence and bound to `Tbl_Tasks` to reveal its dynamic group. The group was only an autogenerated default tuple, not a valid OwnerCell=1 template. These two changes were reverted; final readback is `Process Type=Specific Time`. No new run was started. |
| Diagnostics and runtime | Diagnostics pass; runtime contains historical error | `get_diagnostics` returned zero errors. `get_run_status` reports idle dispatcher/no active run but retains the prior 6-hour runtime error. The existing `Src_S4Test_Codex` object was present before this follow-up and was left untouched. |
| Disk state | User-confirmed saved; current file snapshotted before live test edits | The root `Aerospace.spfx` was 180,215 bytes, last written 2026-10-23 08:21, SHA-256 `1C6A6920F843E77CD8BF5933C1922589CA074C2F263DB42B779159F88376C170`. A byte-for-byte snapshot is `snapshots/Aerospace_PreS4_20261023.spfx`; its hash is in `snapshots/Aerospace_PreS4_20261023.sha256`. No MCP save operation was used. |

The remaining blocker is specifically the Cell1 task-row context: the Task Sequence references `Tbl_Tasks`, but the aircraft does not have a resolvable row reference when the sequence evaluates. The 79.9333 h and 65.45 h Cell1 totals remain table-derived expectations, not Cell1 simulation results. Cell2's previously recorded PlaneType 1/2 runs remain separate evidence and do not close this Cell1 check.

## Read-only status check: 2026-10-23, after user updated Server Process Types

The user changed all five prototype Server instances to `Task Sequence`. This check made no model changes and did not run the simulation.

| Check | Current status | Evidence |
|---|---|---|
| Server Process Types | Configured | `Srv_Cell1Prototype` through `Srv_Cell5Prototype` all read back `Process Type=Task Sequence`. Only Cell2 has a configured Processing Tasks tuple; Cell1, Cell3, Cell4, and Cell5 each have zero tuples. |
| S1: Cell2 table filter | Configured; current run evidence unavailable | Cell2 tuple references `Tbl_Tasks.Seq` and `Tbl_Tasks.TaskName`, with conditional `Tbl_Tasks.OwnerCell==2`. The table has 83 rows, 20 owned by Cell2. Current Task log is empty, so this read-only check does not confirm 20 task executions. |
| S2: mechanics count and list selection | Configured; current run evidence unavailable | Cell2 tuple selects from `Lst_Mech_C2`, uses `Tbl_Tasks.Mechanics`, and requires simultaneous seize. Cell2 data includes six tasks with Mechanics=3. Current ResourceUsage log is empty, so actual three-person allocation and preferred-order selection are not confirmed by the current run data. |
| S3: overnight suspension | Configuration verified; prior scenario result recorded | Cell2 is `Capacity Type=WorkSchedule`, `Initial Work Schedule=StandardWeek`, and has `Off Shift Rule=Suspend Processing`. The prior native validation record reports a single 10-hour task completing Tuesday 14:30 after 18.5 elapsed hours. This is the isolated S3 scenario; the current live logs do not retain its records. |
| S4: Cell1 PlaneType comparison | Not complete | Cell1 now has `Process Type=Task Sequence` but its Processing Tasks tuple count is zero. `PlaneType` exists on the shared `ModelEntity` and initializes to 1. Table-derived Cell1 critical-path totals are 79.9333 h for T101 and 65.45 h for T102, but the current Task log is empty and the historical Cell1 run failed to resolve a `Tbl_Tasks` row reference. |
| Diagnostics and run | Diagnostics pass; no new run | `get_diagnostics` returned zero errors. `get_run_status` reports no active run, while retaining the historical 6-hour Cell1 row-reference runtime error. |

## S4 result: Cell1 PlaneType comparison, 2026-10-23

S4 was completed with two deterministic one-aircraft runs in `/Project/Proto_V0_1_TaskTable`. The test used the Cell1 `Task Sequence` with `Processing Tasks` bound to `Tbl_Tasks`, the conditional task filter `Tbl_Tasks.OwnerCell==1`, and `Math.If(ModelEntity.PlaneType == 2, Tbl_Tasks.T102_Mean, Tbl_Tasks.T101_Mean)`. A temporary `Entered` process set the entity's `Tbl_Cells` row reference to row 1. The test skipped secondary mechanic requirements so that Cell1 processing time was isolated from Cell2's mechanic pool.

| PlaneType | Expected Cell1 critical path | Simio `Srv_Cell1Prototype` processing time | Sink observations / flow time | Result |
|---:|---:|---:|---:|---|
| 1 (SA101/SA103) | 79.9333 h | 79.9333 h | 1 / 79.9333 h | Pass |
| 2 (SA102) | 65.45 h | 65.45 h | 1 / 65.45 h | Pass |

Each run created and completed exactly one aircraft at the test Source/Sink. `get_run_status` reported no runtime error or warning after both runs. The expected values are the sum of the maximum mean task duration within each Cell1 sequence number, then summed across sequence numbers; the Simio `TimeInStation` and Sink `TimeInSystem` observations matched them exactly.

The temporary test Source, Sink, Connectors, and `Prc_SetCell1Row_S4` process were removed after validation. `PlaneType` initial value was restored to 1. Cell1 remains `Process Type=Task Sequence` with an empty Processing Tasks group, so the S4 test template itself is not retained as a production configuration. Final diagnostics returned zero errors and the model is idle. The live test results were captured from native Simio statistics; no screenshot or trace file was generated. The root `.spfx` was not saved by MCP, and this validation does not claim that the temporary test wiring is persisted.

## S1/S2 result: Cell2 task filter and mechanic allocation, 2026-10-23

This result supersedes the earlier read-only status above that marked S1/S2 runtime evidence unavailable. The S1/S2 run completed in `/Project/Proto_V0_1_TaskTable` using the one-aircraft `Src_TestAircraft -> Srv_Cell2Prototype -> Snk_TestAircraft` test flow. The active model was confirmed through MCP immediately before inspection. `Tbl_Tasks` contains 83 rows; filtering its rows to `OwnerCell=2` yields 20 tasks.

| Check | Result | Native evidence |
|---|---|---|
| S1 Cell2 task filtering | Pass | The trace contains one Cell2 task-sequence start and 20 `Branch condition is True` task evaluations for `DefaultEntity.47`; ResourceUsage contains 20 distinct TaskIds (1-20). The aircraft was created once and destroyed once at the Sink. |
| S2 Mechanics quantity | Pass | All 48 ResourceUsage rows map to the 20 Cell2 TaskIds. Comparing the number of usage rows for each TaskId with its `Tbl_Tasks.Mechanics` value found zero mismatches. For TaskId 2 (`C2-02`, Mechanics=3), the log records simultaneous usage by `Mech_C2_03`, `Mech_C2_04`, and `Mech_C2_05`. |
| Resource list and seize location | Pass | All 48 ResourceUsage rows name `Lst_Mech_C2` as the ResourceList and `Srv_Cell2Prototype` as the SeizeLocation. The selected resource names belong to the Cell2 mechanic pool. |
| Run completion | Pass | One entity was created and destroyed. Sink `Average TimeInSystem` was 208.0333 h; Cell2 `Processing` `Average TimeInStation` was 202.0333 h. The latter includes waiting across off-shift periods, not only net task processing. The Constraint log has one record for the initial wait until the 06:00 shift. |
| Diagnostics and runtime | Pass | `get_diagnostics` returned zero errors. `get_run_status` reports idle dispatcher, no runtime error, and zero warnings. |

The Task log itself has zero records, so task execution is corroborated by trace branch decisions and ResourceUsage records rather than Task-log rows. The CSV `Aerospace_Proto_V0_1_TaskTable_trace.csv` contains 2,128 trace lines. Interactive runtime logging and resource-usage logging were enabled temporarily for this validation. After collecting results, RunSetup was restored to `EndTimeValue=120` and `LogInteractiveRuntimeData=False`; `Log Resource Usage=False` was restored on all eight Cell2 mechanics, and interactive trace was disabled. The trace CSV remains available as evidence. No model reset was performed after the run, to preserve the completed-run statistics and logs.

These are live Simio results from the prototype and do not establish that the prototype configuration or its temporary test flow was saved into the root `.spfx`. The formal `/Project/Model` was not modified.
