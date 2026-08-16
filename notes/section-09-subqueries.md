# Section 9: Subqueries

## What is a Subquery?

A query inside another query. The **inner query runs first**, produces a result, and the outer query uses it.

**Real-life logic:** "Who earns more than the average salary?" can't be answered in one step — you must first calculate the average, then compare each person to it. Two steps, one nested inside the other.

### Why you need it

```sql
SELECT empname FROM Employee WHERE salary > AVG(salary);  -- ERROR
```

WHERE runs row by row, and a single row has no "average." Same reason aggregates can't go in WHERE (Section 7).

```sql
SELECT empname, salary
FROM Employee
WHERE salary > (SELECT AVG(salary) FROM Employee);
```

**Execution:**
1. Inner runs alone → `43833.33`
2. Value replaces the subquery → `WHERE salary > 43833.33`

> **Read subqueries inside-out, not top-to-bottom.** The inner query executes first, independently.

---

## Single-Row Subqueries

Inner query returns exactly **one value**. Use with `=`, `>`, `<`, `>=`, `<=`, `!=`.

```sql
-- Employee earning the maximum salary
SELECT empname FROM Employee
WHERE salary = (SELECT MAX(salary) FROM Employee);

-- Employees earning below average
SELECT empname, salary FROM Employee
WHERE salary < (SELECT AVG(salary) FROM Employee);
```

> If the inner query returns more than one row and you use `=`, MySQL errors: **"Subquery returns more than 1 row."**

---

## Multiple-Row Subqueries: IN, ANY, ALL

### IN

Same as Section 6's `IN`, except the list comes from a query.

```sql
SELECT empname FROM Employee
WHERE dept_id IN (SELECT dept_id FROM Department WHERE dept_name IN ('IT', 'HR'));
```

Inner returns `D01, D02` → outer becomes `WHERE dept_id IN ('D01','D02')`.

### ANY

`> ANY (list)` = greater than **at least one** value = greater than the **minimum**.

```sql
SELECT empname, salary FROM Employee
WHERE salary > ANY (SELECT salary FROM Employee WHERE dept_id = 'D02');
```

### ALL

`> ALL (list)` = greater than **every** value = greater than the **maximum**.

```sql
SELECT empname, salary FROM Employee
WHERE salary > ALL (SELECT salary FROM Employee WHERE dept_id = 'D03');
```

### Interview shortcut

| Written as | Equivalent to |
|---|---|
| `> ANY` | `> MIN(...)` |
| `> ALL` | `> MAX(...)` |
| `< ANY` | `< MAX(...)` |
| `< ALL` | `< MIN(...)` |

> **SQLite does not support ANY/ALL.** Use DB Fiddle with MySQL 8, not Programiz.

---

## EXISTS / NOT EXISTS

`EXISTS` doesn't care *what* the subquery returns — only **whether it returns anything**. True if ≥1 row, false if zero.

The subquery is **correlated**: it references the outer query and re-runs for each outer row.

### EXISTS

```sql
-- Departments that have at least one employee
SELECT dept_name FROM Department d
WHERE EXISTS (SELECT 1 FROM Employee e WHERE e.dept_id = d.dept_id);
```

| Department | Inner finds | EXISTS? |
|---|---|---|
| IT | Arun, Neha | keep |
| HR | Rahul, Meera | keep |
| Sales | Vishnu | keep |
| Finance | nothing | drop |

> `SELECT 1` is convention — since EXISTS only checks existence, `SELECT 1`, `SELECT *`, and `SELECT empname` behave identically.

### NOT EXISTS

```sql
-- Departments with no employees
SELECT d.dept_name FROM Department d
WHERE NOT EXISTS (SELECT 1 FROM Employee e WHERE d.dept_id = e.dept_id);
```

### Self-referencing NOT EXISTS

```sql
-- Employees with no manager
SELECT e.empname FROM Employee e
WHERE NOT EXISTS (SELECT 1 FROM Employee m WHERE m.empid = e.manager_id);
```

> Aliases are mandatory when referencing the same table twice — same rule as self joins.

### Which table goes outer?

> **Whatever the question asks you to list goes in the outer SELECT.**
> "Find employees…" → Employee is outer. "Find departments…" → Department is outer.

---

## ⭐ Three ways to find unmatched rows

```sql
-- 1. LEFT JOIN + IS NULL (Section 8)
SELECT d.dept_name FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
WHERE e.empid IS NULL;

-- 2. NOT IN + subquery
SELECT dept_name FROM Department
WHERE dept_id NOT IN (SELECT dept_id FROM Employee WHERE dept_id IS NOT NULL);

-- 3. NOT EXISTS (usually preferred)
SELECT d.dept_name FROM Department d
WHERE NOT EXISTS (SELECT 1 FROM Employee e WHERE e.dept_id = d.dept_id);
```

### Why NOT EXISTS beats NOT IN

> If the subquery returns **any NULL**, `NOT IN` returns **zero rows** — silently, with no error. `NOT EXISTS` handles NULLs correctly.

This is a favourite interview gotcha. It's the same NULL rule from Section 6: comparing anything to NULL gives UNKNOWN, and `NOT IN` is internally a chain of `!=` comparisons.

---

## ⭐ Nth Highest Salary

### Method 1 — LIMIT + OFFSET
```sql
SELECT DISTINCT salary FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET 2;  -- 3rd
```
Formula: `OFFSET = N - 1`

### Method 2 — Nested MAX
```sql
-- 2nd highest
SELECT MAX(salary) FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee);

-- 3rd highest
SELECT MAX(salary) FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee
                WHERE salary < (SELECT MAX(salary) FROM Employee));
```

**Counting the rank:** each MAX layer strips one rank off the top. **N nested MAXes = Nth highest.**

| Nesting | Rank |
|---|---|
| 1 MAX | 1st |
| 2 MAXes | 2nd |
| 3 MAXes | 3rd |

> Doesn't scale. The 6th highest would need six nested SELECTs — unreadable and slow.

### Method 3 — Correlated COUNT
```sql
SELECT salary FROM Employee e1
WHERE 3 = (SELECT COUNT(DISTINCT salary) FROM Employee e2 WHERE e2.salary >= e1.salary);
```
Read as: *"keep the salary that has exactly 3 distinct salaries greater than or equal to it."* Change the number for any N.

### Comparison

| Method | Pros | Cons |
|---|---|---|
| LIMIT/OFFSET | simple, readable | MySQL/PostgreSQL only |
| Nested MAX | works everywhere | unusable past 3rd |
| Correlated COUNT | any N, portable | slower, harder to read |

### Which to use

| N | Method |
|---|---|
| 1st | `SELECT MAX(salary)` |
| 2nd–3rd | nested MAX acceptable |
| 4th+ | LIMIT/OFFSET or COUNT |

> **Interview answer:** "Nested MAX works for 2nd or 3rd but doesn't scale. For arbitrary N I'd use LIMIT with OFFSET, or a correlated COUNT if the database doesn't support LIMIT."
>
> Knowing *when each method breaks down* matters more than memorizing one.

---

## Subquery in FROM (Derived Table)

A subquery can act as a temporary table.

```sql
SELECT dept_id, avg_sal
FROM (SELECT dept_id, AVG(salary) AS avg_sal FROM Employee GROUP BY dept_id) AS dept_avg
WHERE avg_sal > 40000;
```

The inner query builds a mini-table; the outer filters it.

> **A derived table must have an alias** (`AS dept_avg`). MySQL errors without one — common interview gotcha.

---

## Subquery vs JOIN

| | Subquery | JOIN |
|---|---|---|
| Readability | clearer for "does X exist" questions | clearer for combining columns |
| Returns columns from | outer table only | both tables |
| Performance | can be slower if correlated | usually faster |

> If you need columns from **both** tables in the output, use a JOIN. If you're only filtering the outer table based on a condition, a subquery reads more naturally.

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
