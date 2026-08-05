# Section 6: SELECT & WHERE

## SELECT
Retrieves data from a table.

```sql
SELECT * FROM Employee;              -- all columns
SELECT empname, salary FROM Employee; -- specific columns
```

## WHERE
Filters rows based on a condition.

```sql
SELECT * FROM Employee WHERE salary > 40000;
```

## AND / OR / NOT

| Operator | Meaning |
|---|---|
| AND | Both conditions must be true |
| OR | At least one condition true |
| NOT | Reverses a condition |

**Interview point:** AND has higher precedence than OR. `A OR B AND C` is evaluated as `A OR (B AND C)`. Use parentheses to be explicit.

## IN / NOT IN
Shorthand for multiple OR conditions.

```sql
WHERE department IN ('IT', 'HR')
-- same as: WHERE department = 'IT' OR department = 'HR'
```

**Gotcha:** NOT IN can return zero rows if the list contains NULL.

## BETWEEN
Inclusive on both ends.

```sql
WHERE salary BETWEEN 40000 AND 50000
-- same as: salary >= 40000 AND salary <= 50000
```

## LIKE + Wildcards

| Wildcard | Meaning |
|---|---|
| % | Any sequence of characters (0 or more) |
| _ | Exactly one character |

```sql
WHERE empname LIKE 'N%'     -- starts with N
WHERE empname LIKE '%a'     -- ends with a
WHERE empname LIKE '%ah%'   -- contains "ah"
WHERE empname LIKE '_____'  -- exactly 5 characters
```

## IS NULL / IS NOT NULL

**Why `WHERE phone = NULL` returns nothing:**
NULL means UNKNOWN, not a value. Any comparison with NULL returns UNKNOWN (not TRUE/FALSE). WHERE only keeps rows evaluating to TRUE, so nothing ever matches.

- `NULL = NULL` → UNKNOWN
- `NULL != NULL` → UNKNOWN
- `salary > NULL` → UNKNOWN

No comparison operator works with NULL. Use `IS NULL` / `IS NOT NULL`.

## ORDER BY / LIMIT / OFFSET

- **LIMIT** = how many rows to return
- **OFFSET** = how many rows to skip first

```sql
SELECT * FROM Employee ORDER BY salary DESC LIMIT 1;  -- highest paid
```

### Nth Highest Salary
Formula: `LIMIT 1 OFFSET (N-1)`

| Rank | OFFSET |
|---|---|
| 1st | 0 |
| 2nd | 1 |
| 3rd | 2 |
| Nth | N-1 |

```sql
SELECT * FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET 2;  -- 3rd highest
```

**Note:** MySQL requires plain integers. `OFFSET (3-1)` is a syntax error.

**Duplicate salaries:** use DISTINCT for true "Nth highest distinct salary":
```sql
SELECT DISTINCT salary FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET 2;
```

### Pagination
Formula: `OFFSET = (page_number - 1) × rows_per_page`

```sql
LIMIT 5 OFFSET 0   -- page 1
LIMIT 5 OFFSET 5   -- page 2
LIMIT 5 OFFSET 10  -- page 3
```
ORDER BY is mandatory, otherwise rows shuffle between page loads.

## DISTINCT
```sql
SELECT DISTINCT department FROM Employee;
```

## Aliases (AS)
```sql
SELECT empname AS Employee_Name, salary * 12 AS Annual_Salary FROM Employee;
```
