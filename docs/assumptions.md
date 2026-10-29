# Simio Aerospace Assumptions List

Version: 1.1  
Status: project baseline aligned with GitHub Issues #1 through #4  
Model baseline: `Aerospace.spfx` SHA-256 `091BDB1417CDA9ABDC70B16EFEF390C774712014FECF769B6A73D955466C1613` (before Simio opened/normalized the package)  
Input snapshot: `data/Tbl_Tasks.xlsx`

This document records the model's shared business assumptions. It distinguishes case statements from implementation choices; it is not evidence that the corresponding Simio mechanisms have passed native tests.

| ID | Assumption | Basis / validation boundary |
|---|---|---|
| A1 | `LaborHours` is task elapsed duration in hours. `Mechanics` is the number of people required simultaneously; it does not divide task duration. | Case workbook formulas sum the maximum duration within each parallel sequence and divide by 15 work hours/day. |
| A2 | Tasks with the same `Seq` run in parallel. A task in a later sequence waits until all tasks in every earlier sequence are complete. | Case PDF and workbook. Task Sequence behavior remains subject to Issue #4 native validation. |
| A3 | Each aircraft-task pair receives an independent `Random.Triangular(Min, Mode, Max)` sample. | Implements the case workbook's `RiskTriang` parameters and the no-common-shock assumption. Samples are taken once when that task begins. |
| A4 | SA103 uses the SA101 task-time columns (`T101_*`). | Case PDF. |
| A5 | The 75-aircraft mix is 45 SA101 and 30 SA102. The 100-aircraft mix is 45 SA101, 30 SA102, and 25 SA103. Each replication randomizes order without replacement, so counts remain exact. | Issue #2 implementation choice for unknown order and lower mix variance. |
| A6 | Run start `t0` is Monday 06:00. Two-shift production runs Monday-Friday: 06:00-10:00, 10:30-14:30, 14:30-18:30, and 19:00-22:00, totaling 15 work hours/day and 75/week. A third shift adds 23:00-03:00 and 03:30-06:00 (6.5 hours) as a scenario option. | Case PDF. Breaks are non-working time. |
| A7 | Work stops at shift end and resumes at the next shift without restart/setup time. | Intended Simio rule: `Off Shift Rule = Suspend Processing`; Issue #4 must verify actual server/resource behavior. |
| A8 | The system starts empty and idle. Unreleased aircraft remain in an off-line pool and are excluded from manufacturing WIP. | Case and Issue #2. |
| A9 | Pulse movement occurs every 4 calendar days, including weekends. | User-confirmed project decision recorded in Issue #1. |
| A10 | Each cell has eight staffed positions per shift. The model represents positions; different people rotate between shifts. | Case PDF. Position identity is the resource-capacity representation. |
| A11 | Reassigning mechanics between cells has zero travel time. | Explicit simplification because no walking-time data is available; full-pool labor is an optimistic upper bound. |
| A12 | Mechanic requests use FIFO; earlier aircraft, including traveled work, retain priority. | Default modeling choice; revisit as a sensitivity case if evidence warrants. |
| A13 | Task responsibility (`OwnerCell`) and aircraft location (`CurLoc`) are separate concepts. Completion-driven processing keeps them equal; pulse movement can leave unfinished tasks behind, so `CurLoc` may exceed `OwnerCell`. | User-confirmed in Issue #2/#3/#5/#9. `OwnerCell` selects who performs work; `CurLoc` records where the aircraft is and does not filter task data. |

The four-calendar-day departure rule applies to the pulse-flow alternative; departure after completion applies to the completion-driven alternative. These are separate comparison scenarios, not simultaneous rules.

## Analytic reference values

These are mean-duration calculations for deterministic checks, not simulation results. For each cell, sum the maximum task mean in each `Seq` group. The mixed column uses the 75-aircraft mix (60% SA101/SA103 and 40% SA102).

| Cell | SA101/SA103 critical path (h) | SA102 critical path (h) | 75-aircraft mix (h) | Mixed labor-hours/aircraft |
|---:|---:|---:|---:|---:|
| 1 | 79.9 | 65.5 | 74.1 | 238.5 |
| 2 | 102.5 | 100.7 | 101.8 | 324.1 |
| 3 | 67.9 | 70.3 | 68.8 | 225.9 |
| 4 | 75.9 | 67.7 | 72.6 | 286.6 |
| 5 | 6.4 | 6.4 | 6.4 | 24.0 |

Issue #2 estimates 42.9 work hours in an average four-calendar-day interval and a 9.5-calendar-day capacity-one completion-driven cadence from the cell-2 mixed critical path. Both remain analytic expectations until native scenarios reproduce them.

The campaign targets “75 aircraft in 316 days” and “100 aircraft in 3.5 days per aircraft” are not equivalent under the stated serial five-cell approximation: `(75+4)*4 = 316` days, `(100+4)*3.5 = 364` days, and 316 days for 100 aircraft implies about 3.04 days per aircraft. Experiment C must report these as separate targets.

## Change log

| Version | Change | Model version / evidence |
|---|---|---|
| 1.1 | Added A13 and clarified the mutually exclusive departure rules for pulse-flow and completion-driven scenarios. | User-confirmed Issue updates; native Simio validation pending. |
