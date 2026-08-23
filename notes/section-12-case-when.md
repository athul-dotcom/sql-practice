# Section 12: CASE WHEN

## What it is

**CASE is SQL's if/else that produces a value.** It sits wherever a column would normally go, computing a value per row instead of reading one from the table.

```sql
-- reads a stored value
SELECT empname, salary FROM Employee;

-- computes a value
SELECT empname,
    CASE WHEN salary >= 50000 THEN 'High' ELSE 'Low' END AS pay_level
FROM Employee;
```

The whole `CASE...END` block acts as **one column**.

---

## The two forms

### Simple CASE — compare one thing against fixed values
```sql
SELECT empname,
    CASE dept_id
        WHEN 'D01' THEN 'Tech Team'
        WHEN 'D02' THEN 'People Team'
        ELSE 'Other'
    END AS team
FROM Employee;
```

### Searched CASE — full conditions (use this 90% of the time)
```sql
SELECT empname, salary,
    CASE
        WHEN salary >= 50000 THEN 'Senior'
        WHEN salary >= 40000 THEN 'Mid'
        ELSE 'Junior'
    END AS level
FROM Employee;
```

---

## Reading the syntax

```sql
CASE                          -- start deciding a value
    WHEN condition THEN value -- if true, the value is...
    WHEN condition THEN value -- otherwise check this
    ELSE value                -- if nothing matched
END                           -- done deciding
AS column_name                -- name the resulting column
```

`END` closes the block. `AS` names the output column, same as any other alias.

> **Don't forget the comma** after `END AS name` if another column follows. Easy to miss because `END AS band` on its own line *looks* finished.

---

## ⚠️ Order matters — first match wins

Conditions evaluate **top to bottom**, and evaluation **stops at the first match**.

```sql
-- WRONG: Arun (55000) gets labelled 'Mid'
CASE
    WHEN salary >= 40000 THEN 'Mid'      -- 55000 matches here first!
    WHEN salary >= 50000 THEN 'Senior'   -- never reached
END
```

**Always order from most restrictive to least.**

### Bonus: only one boundary needed per line

```sql
-- redundant
WHEN salary >= 40000 AND salary < 50000 THEN 'Mid'

-- sufficient — if a row reaches line 2, line 1 already ruled out 50000+
WHEN salary >= 50000 THEN 'Senior'
WHEN salary >= 40000 THEN 'Mid'
ELSE 'Junior'
```

---

## ⚠️ Boundary values — the #1 CASE bug

```sql
-- Neha earns exactly 50000
WHEN salary > 50000  THEN 'Above Average'   -- 50000 > 50000 is FALSE
WHEN salary > 40000 AND salary < 50000 THEN 'Average'  -- 50000 < 50000 is FALSE
ELSE 'Below Average'                         -- Neha lands here — wrong!
```

> Always test the **exact edge values** before moving on. Interviewers deliberately put boundary numbers in their test data.

`>` excludes the endpoint. `>=` includes it. Decide which band each boundary belongs to and write it explicitly.

---

## ELSE is optional

Without it, unmatched rows get **NULL**:
```sql
CASE WHEN salary >= 50000 THEN 'Senior' END   -- everyone else → NULL
```

Sometimes that's exactly what you want — see conditional aggregation below.

> **But watch out:** if you're passing values through, you need `ELSE column_name`, otherwise every non-matching row becomes NULL.
> ```sql
> -- WRONG: everyone with a department gets NULL
> CASE WHEN dept_id IS NULL THEN 'No Department' END
>
> -- RIGHT
> CASE WHEN dept_id IS NULL THEN 'No Department' ELSE dept_id END
> ```

---

## ⚠️ `= NULL` never works inside CASE either

```sql
WHEN dept_id = NULL THEN 'No Department'    -- never matches
WHEN dept_id IS NULL THEN 'No Department'   -- correct
```

Same Section 6 rule: comparing anything to NULL returns UNKNOWN, never TRUE.

---

## Conditional Aggregation

Counting or summing **different things in one pass**.

```sql
SELECT
    COUNT(CASE WHEN salary >= 45000 THEN 1 END) AS high_earners,
    COUNT(CASE WHEN salary < 45000 THEN 1 END) AS low_earners
FROM Employee;
```

**Why it works:** rows failing the condition produce NULL (no ELSE), and `COUNT(column)` skips NULLs — the Section 7 rule, used deliberately.

### With SUM
```sql
SELECT
    SUM(CASE WHEN dept_id = 'D01' THEN salary ELSE 0 END) AS IT_total,
    SUM(CASE WHEN dept_id = 'D02' THEN salary ELSE 0 END) AS HR_total
FROM Employee;
```

> Note the `ELSE 0` here — SUM needs a number, so non-matching rows contribute zero rather than NULL.

### Combined with a plain total
```sql
SELECT COUNT(*) AS total_employees,
    COUNT(CASE WHEN dept_id = 'D01' THEN 1 END) AS it_employees,
    COUNT(CASE WHEN dept_id = 'D02' THEN 1 END) AS hr_employees
FROM Employee;
```

> This is **pivoting** — turning rows into columns. Very common in reporting questions.

---

## CASE with GROUP BY

Group *by* a CASE expression to create categories that don't exist as a column:

```sql
SELECT
    CASE
        WHEN salary >= 50000 THEN '50K+'
        WHEN salary >= 40000 THEN '40K-50K'
        ELSE 'Below 40K'
    END AS band,
    COUNT(*) AS headcount
FROM Employee
GROUP BY band;
```

| band | headcount |
|---|---|
| 50K+ | 2 |
| 40K-50K | 1 |
| Below 40K | 2 |

> MySQL allows `GROUP BY band` using the alias. Strict SQL doesn't — repeat the full CASE expression in GROUP BY if portability matters.

---

## CASE in ORDER BY

Custom sort orders that aren't alphabetical or numeric:

```sql
SELECT empname, dept_id FROM Employee
ORDER BY CASE dept_id
    WHEN 'D01' THEN 1
    WHEN 'D03' THEN 2
    ELSE 3
END;
```

Sorts IT first, Sales second, everything else last.

---

## CASE vs WHERE

| Task | Tool |
|---|---|
| Change what a column **shows** | CASE |
| Decide which rows **appear** | WHERE |

You *can* filter with CASE:
```sql
WHERE CASE WHEN id % 2 != 0 THEN 1 ELSE 0 END = 1
```
But it's a needless workaround for `WHERE id % 2 != 0`. An interviewer would notice the overcomplication.

---

## Shortcuts: IF, IFNULL, COALESCE

```sql
-- IF(condition, value_if_true, value_if_false)  — MySQL only
SELECT empname, IF(salary >= 45000, 'High', 'Low') AS band FROM Employee;

-- IFNULL(value, replacement)  — MySQL only
SELECT empname, IFNULL(dept_id, 'Unassigned') AS dept FROM Employee;

-- COALESCE(value, replacement)  — standard SQL, works everywhere
SELECT empname, COALESCE(dept_id, 'Unassigned') AS dept FROM Employee;
```

| Function | Portable? | Use for |
|---|---|---|
| `CASE` | ✅ everywhere | complex, multi-branch logic |
| `COALESCE` | ✅ everywhere | plain NULL substitution |
| `IF()` | ❌ MySQL only | quick two-way choice |
| `IFNULL()` | ❌ MySQL only | quick NULL substitution |

> Prefer `CASE` in interviews unless asked for the shortest form. Use `COALESCE` over `IFNULL` for portability.

---

## Setup script

```sql
CREATE TABLE Department (
    dept_id VARCHAR(10) PRIMARY KEY,
    dept_name VARCHAR(50)
);

INSERT INTO Department VALUES
('D01', 'IT'), ('D02', 'HR'), ('D03', 'Sales'), ('D04', 'Finance');

CREATE TABLE Employee (
    empid INT PRIMARY KEY,
    empname VARCHAR(50),
    dept_id VARCHAR(10),
    salary INT,
    manager_id INT,
    joindate DATE,
    email VARCHAR(100)
);

INSERT INTO Employee VALUES
(1, 'Arun',   'D01', 55000, 3,    '2022-05-14', 'arun@company.com'),
(2, 'Rahul',  'D02', 35000, 3,    '2024-03-11', 'rahul@company.com'),
(3, 'Neha',   'D01', 50000, NULL, '2020-09-21', 'neha@company.com'),
(4, 'Priya',  NULL,  40000, 1,    '2023-11-02', NULL),
(5, 'Vishnu', 'D03', 45000, 1,    '2021-07-19', 'vishnu@company.com'),
(6, 'Meera',  'D02', 38000, 3,    '2024-01-05', 'meera@company.com'),
(7, 'Kiran',  'D03', 62000, 1,    '2019-02-28', 'kiran@company.com'),
(8, 'Divya',  'D01', 40000, 3,    '2025-06-15', NULL);
```

**Edge cases built in:** NULL dept_id (Priya), NULL manager_id (Neha), NULL emails, empty department (Finance), exact boundaries at 40000 and 50000, duplicate salary (Priya & Divya).
