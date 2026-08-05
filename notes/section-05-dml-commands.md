# Section 5: INSERT, UPDATE, DELETE

## INSERT

### Form 1 — all columns, in order
```sql
INSERT INTO Employee VALUES (1, 'Arun', 'IT', 50000, '2024-01-15', '9876543210');
```

### Form 2 — named columns (safer)
```sql
INSERT INTO Employee (empid, empname, department, salary, joindate, phone)
VALUES (5, 'Vishnu', 'Sales', 45000, '2021-07-19', '9765432180');
```

> Form 2 is safer — if the table gains a new column later, Form 1 queries break, Form 2 still works.

### Multiple rows in one query
```sql
INSERT INTO Employee VALUES
(2, 'Rahul', 'HR', 35000, '2024-03-11', '9998887766'),
(3, 'Neha',  'IT', 50000, '2003-09-21', '9999999999'),
(4, 'Priya', 'MR', 40000, '2023-11-02', '9876543211');
```

---

## Common INSERT mistakes

**1. Dates need quotes.**
`2024-11-22` without quotes is read as subtraction: 2024 − 11 − 22 = 1991. It fails silently rather than erroring.

**2. MySQL date format is `'YYYY-MM-DD'`.**
`'2024-22-11'` is invalid — there is no month 22.

**3. Use single quotes.**
`'text'` not `"text"`. Single quotes are the SQL standard and portable to PostgreSQL and others.

**4. Column names must match exactly.**
`empid` vs `emp_id` will throw "Unknown column". Check with `DESCRIBE table_name;` if unsure.

---

## UPDATE

Modifies existing rows.

```sql
UPDATE Employee SET salary = 65000 WHERE empid = 3;
```

> **Warning:** Forget the WHERE clause and **every row** gets updated. One of the most common real-world SQL disasters.

---

## DELETE

Removes rows. Unlike TRUNCATE, it supports WHERE.

```sql
DELETE FROM Employee WHERE empid = 5;
DELETE FROM Employee WHERE department = 'Sales';
```

> **Warning:** No WHERE means all rows deleted — but the structure survives (unlike DROP).

---

## Quick reference

| Command | Category | Changes | Rollback? |
|---|---|---|---|
| INSERT | DML | Adds rows | Yes |
| UPDATE | DML | Modifies rows | Yes |
| DELETE | DML | Removes rows | Yes |
| TRUNCATE | DDL | Removes all rows | No |
| DROP | DDL | Removes table | No |
