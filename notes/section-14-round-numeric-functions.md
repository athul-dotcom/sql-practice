# Section 14: ROUND & Numeric Functions

## ROUND()

```sql
ROUND(value, decimals)
```

```sql
ROUND(3.14159, 2)   -- 3.14
ROUND(66.6667, 2)   -- 66.67
ROUND(50, 2)        -- 50.00
ROUND(1234.5, -2)   -- 1200 (negative = rounds LEFT of the decimal)
```

---

## ⭐ The percentage pattern

Nearly every "find the percentage" question follows this exact shape:

```sql
ROUND(<count of what you want> * 100.0 / <count of everything>, 2) AS some_percentage
```

### Option A — two subqueries
```sql
SELECT ROUND(
    (SELECT COUNT(*) FROM Employee WHERE dept_id = 'D01') * 100.0
    / (SELECT COUNT(*) FROM Employee)
, 2) AS it_percentage;
```

### Option B — CASE + SUM, one table scan (usually preferred)
```sql
SELECT ROUND(
    SUM(CASE WHEN dept_id = 'D01' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
, 2) AS it_percentage
FROM Employee;
```

**How it works:** CASE produces 1 for each matching row, 0 otherwise. SUM adds those up, giving the count of matches. Divide by COUNT(*) for the total, multiply by 100 for percentage scale, ROUND to finish.

> **Why `100.0` and not `100`:** integer division silently truncates — `2 / 4 = 0` in integer math, but `2 * 100.0 / 4 = 50.0` in floating point. Always multiply by a decimal before dividing.

### Worked example
```sql
SELECT ROUND(
    SUM(CASE WHEN salary > 45000 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
, 2) AS percentage
FROM Employee;
```
3 employees (Arun 55000, Neha 50000, Kiran 62000) above 45000, out of 8 total.
`3 * 100.0 / 8 = 37.5` → `ROUND(37.5, 2) = 37.50`

> Boundary check matters here too — "above" means `>`, not `>=`. Read the exact wording before choosing the operator.

---

## Other numeric functions

| Function | What it does | Example |
|---|---|---|
| `FLOOR(x)` | round down | `FLOOR(4.9)` → 4 |
| `CEILING(x)` / `CEIL(x)` | round up | `CEILING(4.1)` → 5 |
| `ABS(x)` | absolute value | `ABS(-7)` → 7 |
| `TRUNCATE(x, d)` | cut decimals, no rounding | `TRUNCATE(4.999, 1)` → 4.9 |
| `POWER(x, y)` | x to the power y | `POWER(2, 3)` → 8 |
| `SQRT(x)` | square root | `SQRT(16)` → 4 |
| `MOD(x, y)` | remainder (same as `%`) | `MOD(10, 3)` → 1 |

### ROUND vs TRUNCATE vs FLOOR vs CEILING — interview trap
```sql
ROUND(4.7)       -- 5  (rounds to nearest)
FLOOR(4.7)       -- 4  (always down)
TRUNCATE(4.7, 0) -- 4  (chops off, no rounding logic)
CEILING(4.1)     -- 5  (always up)
```

---

## Date functions

| Function | What it does |
|---|---|
| `YEAR(date)` | extracts the year |
| `MONTH(date)` | extracts the month |
| `DAY(date)` | extracts the day |
| `DATEDIFF(d1, d2)` | days between two dates |
| `DATE_ADD(date, INTERVAL n DAY)` | add days to a date |
| `CURDATE()` | today's date |

```sql
SELECT * FROM Employee WHERE YEAR(joindate) = 2024;
```
