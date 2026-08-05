# Section 7: Aggregate Functions, GROUP BY, HAVING

## Aggregate Functions

Collapse **many rows** into **one value**.

| Function | Returns |
|---|---|
| `COUNT()` | number of rows |
| `SUM()` | total |
| `AVG()` | average |
| `MIN()` | smallest value |
| `MAX()` | largest value |

```sql
SELECT COUNT(*)    FROM Employee;   -- 7
SELECT SUM(salary) FROM Employee;   -- 325000
SELECT AVG(salary) FROM Employee;   -- 46428.57
SELECT MAX(salary), MIN(salary) FROM Employee;
```

Combined with WHERE:
```sql
SELECT COUNT(*) FROM Employee WHERE department = 'IT';
```

---

## Interview: COUNT(*) vs COUNT(column)

- `COUNT(*)` counts **all rows**, including rows with NULLs
- `COUNT(column)` counts only rows where that column is **NOT NULL**

If 2 employees had no phone: `COUNT(*)` = 7 but `COUNT(phone)` = 5.

**Also:** `AVG()` and `SUM()` **ignore NULLs** — they don't treat them as zero.
AVG of (10, NULL, 20) = 15, not 10.

---

## GROUP BY

Collapses rows into groups and runs the aggregate on **each group at once**.

```sql
SELECT department, COUNT(*) FROM Employee GROUP BY department;
```

| department | COUNT(*) |
|---|---|
| IT | 2 |
| HR | 2 |
| MR | 1 |
| Sales | 2 |

```sql
SELECT department, SUM(salary) AS total_salary FROM Employee GROUP BY department;
SELECT department, MAX(salary) AS max_sal FROM Employee GROUP BY department;
```

### Golden rule

> Every column in SELECT must either be **in the GROUP BY** or be **inside an aggregate function**.

This fails:
```sql
SELECT department, empname, COUNT(*) FROM Employee GROUP BY department;  -- ERROR
```
Why? IT has two employees — SQL can't decide which single name to show.

---

## HAVING

Filters **groups**, after grouping has happened.

```sql
SELECT department, AVG(salary) AS avg_sal
FROM Employee
GROUP BY department
HAVING AVG(salary) > 45000;
```

This **fails** — WHERE runs before grouping, so no average exists yet:
```sql
SELECT department, AVG(salary) FROM Employee
WHERE AVG(salary) > 45000 GROUP BY department;  -- ERROR
```

More examples:
```sql
-- departments with more than 1 employee
SELECT department, COUNT(*) AS number_emp
FROM Employee GROUP BY department HAVING COUNT(*) > 1;

-- departments where total salary exceeds 70000
SELECT department, SUM(salary) AS total_sal
FROM Employee GROUP BY department HAVING SUM(salary) > 70000;
```

---

## WHERE vs HAVING

| | WHERE | HAVING |
|---|---|---|
| Filters | Individual **rows** | **Groups** |
| Runs | Before GROUP BY | After GROUP BY |
| Aggregates allowed? | No | Yes |

**One-liner:**
> WHERE filters rows before grouping; HAVING filters groups after grouping. Aggregate functions can only be used in HAVING.

---

## Clause Order

**WHERE → GROUP BY → HAVING → ORDER BY**

```sql
SELECT department, AVG(salary) AS avg_sal
FROM Employee
WHERE salary > 30000           -- 1. filter rows first
GROUP BY department            -- 2. then group them
HAVING AVG(salary) > 45000     -- 3. then filter the groups
ORDER BY avg_sal DESC;         -- 4. finally sort
```

Writing these clauses out of order is a syntax error. Interviewers ask you to recite this.

---

## Note on aliases in HAVING

MySQL allows `HAVING number_emp > 1` using the alias, but the SQL standard does not and other databases may reject it. Repeating the full aggregate (`HAVING COUNT(*) > 1`) is the safer habit.
