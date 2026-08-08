# Section 8: JOINs

## What is a JOIN?

Combines rows from two tables based on a related column (usually a foreign key).

### Sample tables used throughout

**Department**

| dept_id | dept_name |
|---|---|
| D01 | IT |
| D02 | HR |
| D03 | Sales |
| D04 | Finance |

**Employee**

| empid | empname | dept_id | salary |
|---|---|---|---|
| 1 | Arun | D01 | 55000 |
| 2 | Rahul | D02 | 35000 |
| 3 | Neha | D01 | 50000 |
| 4 | Priya | NULL | 40000 |
| 5 | Vishnu | D03 | 45000 |
| 6 | Meera | D02 | 38000 |

Two deliberate edge cases:
- **Priya** has no department (`dept_id` is NULL)
- **Finance (D04)** has no employees

These two are what separate INNER from LEFT/RIGHT JOIN.

---

## Left vs Right — which is which?

Purely positional:

```
FROM  Employee  LEFT JOIN  Department
      ↑                    ↑
      LEFT table           RIGHT table
```

Whatever follows `FROM` is the left table. Whatever follows `JOIN` is the right table.

| Join type | Keeps all rows from |
|---|---|
| INNER JOIN | neither — only matches |
| LEFT JOIN | the table after FROM |
| RIGHT JOIN | the table after JOIN |

**When writing a query, ask: "which table's rows must all survive?"** Put that one first and use LEFT JOIN.

> The ON condition is symmetric — `a.id = b.id` and `b.id = a.id` are identical. Only the FROM/JOIN order matters.

---

## INNER JOIN

Returns only rows with a match in **both** tables.

```sql
SELECT e.empname, d.dept_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id;
```

Returns 5 rows, not 6. Priya is dropped (NULL dept), Finance is dropped (no employees).

> INNER JOIN is strict — no match on either side means the row disappears.

---

## LEFT JOIN

All rows from the left table + matching rows from the right. No match → NULLs on the right.

```sql
SELECT e.empname, d.dept_name
FROM Employee e
LEFT JOIN Department d ON e.dept_id = d.dept_id;
```

6 rows — Priya appears with `dept_name = NULL`. Finance still missing.

---

## RIGHT JOIN

Mirror of LEFT JOIN — all rows from the right table.

```sql
SELECT e.empname, d.dept_name
FROM Employee e
RIGHT JOIN Department d ON e.dept_id = d.dept_id;
```

6 rows — Finance appears with `empname = NULL`. Priya dropped.

> **`A RIGHT JOIN B` is identical to `B LEFT JOIN A`.** Most developers only use LEFT JOIN and reorder the tables instead. If asked which is more common: LEFT JOIN, by far.

---

## FULL OUTER JOIN

All rows from both tables. **MySQL does not support it** — favourite interview question.

### MySQL workaround: UNION of LEFT and RIGHT

```sql
SELECT e.empname, d.dept_name
FROM Employee e
LEFT JOIN Department d ON e.dept_id = d.dept_id

UNION

SELECT e.empname, d.dept_name
FROM Employee e
RIGHT JOIN Department d ON e.dept_id = d.dept_id;
```

7 rows — everything from both sides.

| Database | FULL OUTER JOIN | UNION workaround |
|---|---|---|
| MySQL | Not supported | Required |
| PostgreSQL / Oracle / SQL Server | Supported | Works, but unnecessary |

**Interview answer:** "MySQL doesn't support FULL OUTER JOIN, so you simulate it with a UNION of LEFT JOIN and RIGHT JOIN. Other databases support it natively."

### Why UNION and not UNION ALL?

The 5 **matched** rows appear in both halves — a matched row satisfies LEFT and RIGHT equally. Only unmatched rows are unique to one side (Priya from LEFT, Finance from RIGHT).

- `UNION ALL` → 12 rows, 5 duplicated pairs
- `UNION` → 7 rows

> Rule of thumb: **matched rows duplicate, unmatched rows don't.**

UNION compares the **entire row** — two rows are duplicates only if every column matches. `(Arun, IT)` and `(Neha, IT)` are not duplicates; the repeated *value* "IT" doesn't matter.

> UNION removes duplicates (slower — must sort/compare). UNION ALL keeps everything (faster). Both SELECTs need the same column count and compatible datatypes.

---

## ⭐ The Unmatched-Rows Pattern

The single most-asked JOIN interview question shape.

```
FROM      [table you want to keep]      ← LEFT table
LEFT JOIN [other table]                 ← RIGHT table
WHERE     [RIGHT table].column IS NULL  ← always the right one
```

### Employees with no department
```sql
SELECT e.empname
FROM Employee e
LEFT JOIN Department d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
```

### Departments with no employees
```sql
SELECT d.dept_name
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
WHERE e.empid IS NULL;
```

### Customers who never placed an order
```sql
SELECT c.first_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

**Same pattern, different clothes:** "products never sold", "students with no marks", "users who never logged in".

| Goal | Left table | WHERE checks |
|---|---|---|
| Employees with no dept | Employee | `d.dept_id IS NULL` |
| Departments with no employees | Department | `e.empid IS NULL` |

The left table flips depending on the question. **"Check the right table" never changes.**

> **Use the right table's PRIMARY KEY in the IS NULL check.** A regular column might genuinely contain NULL in the data (false positives). A primary key never can — so a NULL there proves the join failed.

> Also note: `WHERE dept_id IS NULL` without a table prefix throws "Column is ambiguous" when both tables have that column. Always qualify.

---

## SELF JOIN

A table joined to itself — for rows that relate to other rows in the same table.

**Employee with manager_id:**

| empid | empname | manager_id |
|---|---|---|
| 1 | Arun | 3 |
| 2 | Rahul | 3 |
| 3 | Neha | NULL |
| 4 | Priya | 1 |

```sql
SELECT e.empname AS Employee, m.empname AS Manager
FROM Employee e
JOIN Employee m ON e.manager_id = m.empid;
```

| Employee | Manager |
|---|---|
| Arun | Neha |
| Rahul | Neha |
| Priya | Arun |

> Aliases are **mandatory** in a self join — `e` and `m` are the same table treated as two copies. Without them MySQL can't distinguish the two.

Neha is missing (NULL manager, dropped by INNER JOIN). Use LEFT JOIN to include her.

---

## CROSS JOIN

Every row of A paired with every row of B. No ON condition. **Cartesian product.**

```sql
SELECT e.empname, d.dept_name
FROM Employee e
CROSS JOIN Department d;
```

6 employees × 4 departments = 24 rows.

> **Why it matters:** forgetting the ON clause creates one accidentally. `SELECT * FROM A, B` with no WHERE gives a Cartesian product — on two 10,000-row tables that's 100 million rows. Common "what went wrong" interview question.

---

## JOIN + GROUP BY

### Employee count per department (including empty ones)
```sql
SELECT d.dept_name, COUNT(e.empid) AS emp_count
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

| dept_name | emp_count |
|---|---|
| IT | 2 |
| HR | 2 |
| Sales | 1 |
| Finance | **0** |

### ⚠️ Count the RIGHT table's column

After the LEFT JOIN, Finance produces one row with NULLs on the Employee side:

| d.dept_name | d.dept_id | e.empid |
|---|---|---|
| Finance | D04 | NULL |

- `COUNT(*)` counts rows → Finance = **1** ❌
- `COUNT(d.dept_id)` — left table, never NULL → Finance = **1** ❌
- `COUNT(e.empid)` — right table, NULL skipped → Finance = **0** ✅

> **In a LEFT JOIN with COUNT, always count a column from the right table.**
>
> Same principle as the IS NULL pattern: the right table is where evidence of a failed match lives. In WHERE you check it for NULL; in COUNT you let it skip the NULL.

### Average salary per department
```sql
SELECT d.dept_name, AVG(e.salary) AS average_salary
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

Finance shows **NULL**, not 0 — AVG of nothing is undefined.

> **COUNT of an empty group is 0, but SUM and AVG are NULL.** Use `COALESCE(AVG(e.salary), 0)` to display 0 instead.

### JOIN + GROUP BY + HAVING
```sql
SELECT d.dept_name, SUM(e.salary) AS Total_salary
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING SUM(e.salary) > 80000;
```

Finance drops out — its SUM is NULL, and `NULL > 80000` is UNKNOWN, so it fails the filter.

---

## Setup script for practice

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
    manager_id INT
);

INSERT INTO Employee VALUES
(1, 'Arun',   'D01', 55000, 3),
(2, 'Rahul',  'D02', 35000, 3),
(3, 'Neha',   'D01', 50000, NULL),
(4, 'Priya',  NULL,  40000, 1),
(5, 'Vishnu', 'D03', 45000, 1),
(6, 'Meera',  'D02', 38000, 3);
```

---

## Note on practice environments
