# Section 3: DDL Commands

## CREATE TABLE

Creates a new table (structure only, no data).

```sql
CREATE TABLE Employee (
    empid INT,
    empname VARCHAR(100),
    department VARCHAR(50),
    salary INT,
    joindate DATE
);
```

Common MySQL datatypes: `INT`, `VARCHAR(size)`, `DATE`, `DECIMAL(10,2)` for money.

### Interview point: What does INT(5) mean?

> It's a **display width** hint, not a storage limit — and it's deprecated in MySQL 8. An `INT(5)` column can still store 1000000. INT always takes 4 bytes.

**Rule:** `VARCHAR` needs a size; `INT` does not.

---

## ALTER TABLE

Modifies the structure of an existing table.

```sql
ALTER TABLE Employee ADD phone VARCHAR(15);
ALTER TABLE Employee MODIFY empname VARCHAR(150);
ALTER TABLE Employee DROP COLUMN phone;
```

A newly added column gets `NULL` for all existing rows.

---

## RENAME TABLE

```sql
RENAME TABLE Employee TO Staff;
```

Same table, same data, new name.

---

## TRUNCATE TABLE

Deletes **all rows** but keeps the table structure.

```sql
TRUNCATE TABLE Employee;
```

Table becomes empty; you can INSERT into it immediately.

---

## DROP TABLE

Deletes the entire table — structure and data — permanently.

```sql
DROP TABLE Employee;
```

After this, SELECT on the table gives an error: it no longer exists.

---

## Database-level commands

```sql
CREATE DATABASE college;
SHOW DATABASES;
USE college;
DROP DATABASE college;
```

## Table inspection

```sql
SHOW TABLES;
DESCRIBE Employee;   -- shows columns, datatypes, keys
```

`DESCRIBE` is useful for checking exact column names when a query fails with "Unknown column".
