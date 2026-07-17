---
name: Task Prioritizer
description: "Stack rank tasks by ROI and urgency — score by revenue impact, time sensitivity, and effort. Output prioritized task list. Triggers on: prioritize, what is most important, stack rank, triage tasks."
---

# Task Prioritizer

## Overview
Score and rank your task list by revenue impact, time sensitivity, and effort required. Uses a weighted scoring model to cut through overwhelm and tell you exactly what to do next. Separates high-ROI quick wins from low-value time sinks.

## When to Use
- Overwhelmed with too many tasks
- Need to decide what to do next
- Weekly planning — prioritize the task backlog
- After a meeting dump — lots of new action items

## Inputs
- **Task list** (from ClickUp, meeting notes, or manual input)
- **Context**: deadlines, deal values, dependencies

## Process

### Step 1: Score Each Task

| Factor | Weight | 5 (Highest) | 3 (Medium) | 1 (Lowest) |
|--------|--------|-------------|------------|------------|
| Revenue Impact | 40% | Directly closes a deal or generates income | Moves a deal forward | Admin/maintenance |
| Time Sensitivity | 35% | Due today/tomorrow or deal expires | Due this week | No hard deadline |
| Effort Required | 25% | <15 min (quick win) | 30-60 min | 2+ hours |

```
Priority Score = (Revenue × 0.40) + (Time × 0.35) + (Effort × 0.25)
```

Note: For effort, LOWER effort gets a HIGHER score (quick wins rank higher).

### Step 2: Rank and Categorize

| Rank | Task | Rev | Time | Effort | Score | Action |
|------|------|-----|------|--------|-------|--------|
| 1 | [Task] | [X] | [X] | [X] | [X] | DO NOW |
| 2 | [Task] | [X] | [X] | [X] | [X] | DO NOW |
| 3 | [Task] | [X] | [X] | [X] | [X] | DO TODAY |

**Categories:**
- Score 4.0-5.0: DO NOW — drop everything
- Score 3.0-3.9: DO TODAY — schedule in today's plan
- Score 2.0-2.9: THIS WEEK — schedule this week
- Score 1.0-1.9: BACKLOG — do when time allows or delegate

### Step 3: Quick Win Identification
Tasks scoring high on effort (easy) + high on revenue = **Quick Wins**. Do these first for momentum.

## Output Format
```
PRIORITIZED TASK LIST
═════════════════════
DO NOW (Score 4+):
1. [Task] — Score: [X] — [Est time]
2. [Task] — Score: [X] — [Est time]

DO TODAY (Score 3-3.9):
3. [Task] — Score: [X]
4. [Task] — Score: [X]

THIS WEEK (Score 2-2.9):
[List]

DELEGATE OR DROP:
[Low-score tasks with recommendations]

QUICK WINS (do first for momentum):
[High-revenue, low-effort tasks]
```

## Example Prompts
- "Prioritize these tasks: call back 3 sellers, pull comps on Oak Ave deal, update CRM, send buyer blast, pay marketing invoice."
- "I have 2 hours free — what should I focus on from my task list?"
- "Stack rank my action items from this morning's meeting."

## Suggested Next Steps
1. **`/operations/daily-planner`** — Build today's plan around prioritized tasks
2. **`/operations/calendar-optimizer`** — Block time for top priorities
3. **`/operations/weekly-review`** — Review what got done vs planned
