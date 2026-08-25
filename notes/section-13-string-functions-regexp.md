# Section 13: String Functions & REGEXP

## Core string functions

| Function | What it does | Example |
|---|---|---|
| `LENGTH(str)` | length in **bytes** | `LENGTH('Athul')` → 5 |
| `CHAR_LENGTH(str)` | length in **characters** | `CHAR_LENGTH('Athul')` → 5 |
| `UPPER(str)` | uppercase | `UPPER('athul')` → `ATHUL` |
| `LOWER(str)` | lowercase | `LOWER('ATHUL')` → `athul` |
| `SUBSTRING(str, start, len)` | extract part of a string | `SUBSTRING('Athul', 1, 3)` → `Ath` |
| `CONCAT(a, b, ...)` | join strings | `CONCAT('Athul', ' ', 'K')` → `Athul K` |
| `CONCAT_WS(sep, a, b, ...)` | join with separator, skips NULLs | `CONCAT_WS('-', 'A', 'B')` → `A-B` |
| `TRIM(str)` | remove leading/trailing spaces | `TRIM('  hi  ')` → `hi` |
| `REPLACE(str, old, new)` | replace occurrences | `REPLACE('cat','c','b')` → `bat` |
| `GROUP_CONCAT(...)` | aggregate rows into one string | *(below)* |

---

## LENGTH vs CHAR_LENGTH

`LENGTH` counts **bytes**. `CHAR_LENGTH` counts **characters**. Identical for plain English text, but differ for multi-byte characters:

```sql
LENGTH('café')       -- 5 (é takes 2 bytes in UTF-8)
CHAR_LENGTH('café')  -- 4 (4 actual characters)
```

> **Interview point:** default to `CHAR_LENGTH` for text-length problems.

---

## SUBSTRING

```sql
SUBSTRING(str, start, length)
```

- Position counting starts at **1**, not 0
- Omit `length` to go to the end of the string
- Negative start counts from the end

```sql
SUBSTRING('Athul', 1, 1)   -- 'A'
SUBSTRING('Athul', 2)      -- 'thul'
SUBSTRING('Athul', -3)     -- 'hul'
```

**Fixing capitalization:**
```sql
SELECT CONCAT(UPPER(SUBSTRING(name, 1, 1)), LOWER(SUBSTRING(name, 2))) AS name
FROM Users;
```

---

## CONCAT vs CONCAT_WS — the NULL trap

```sql
CONCAT('Athul', NULL, 'MCA')          -- NULL — any NULL poisons the WHOLE result
CONCAT_WS('-', 'Athul', NULL, 'MCA')  -- 'Athul-MCA' — NULL silently skipped
```

> **Interview point:** `CONCAT(first_name, ' ', last_name)` silently returns NULL for anyone missing a last name. `CONCAT_WS` avoids this — prefer it when NULLs are possible.

---

## Handling NULL in string operations (recap from CASE section)

Any string function applied to NULL returns NULL — same poisoning rule as CONCAT:

```sql
REPLACE(NULL, '@company.com', '@newcompany.com')  -- NULL
```

**Fix with CASE:**
```sql
SELECT empname,
CASE WHEN email IS NULL THEN 'No email'
     ELSE REPLACE(email, '@company.com', '@newcompany.com')
END AS new_email
FROM Employee;
```

**Or shorter with COALESCE** (returns first non-NULL):
```sql
SELECT empname,
COALESCE(REPLACE(email, '@company.com', '@newcompany.com'), 'No email') AS new_email
FROM Employee;
```

---

## GROUP_CONCAT

Squashes many rows into **one string**, joining values together — the string equivalent of COUNT/SUM.

```sql
GROUP_CONCAT(DISTINCT column ORDER BY column SEPARATOR ',')
```

| Part | Purpose |
|---|---|
| `DISTINCT` | removes duplicate values before joining |
| `ORDER BY` | controls order inside the string |
| `SEPARATOR ','` | glue character (comma is default) |

**Example — employees per department, including empty departments:**
```sql
SELECT d.dept_name,
       GROUP_CONCAT(e.empname ORDER BY e.empname SEPARATOR ', ') AS employees
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

| dept_name | employees |
|---|---|
| IT | Arun, Divya, Neha |
| HR | Meera, Rahul |
| Sales | Kiran, Vishnu |
| Finance | NULL |

> Finance shows NULL — `GROUP_CONCAT` over zero rows returns NULL, same as SUM/AVG over empty groups (Section 8).
>
> **Needs LEFT JOIN + GROUP BY together** — INNER JOIN would drop Finance entirely; missing GROUP BY would jam every employee into one row instead of one row per department.

> **Cross-database names:** MySQL → `GROUP_CONCAT`. PostgreSQL → `STRING_AGG`. Oracle → `LISTAGG`. Same concept, different syntax.
>
> **Gotcha:** default length limit (1024 chars in older MySQL) — can silently truncate on very large aggregations.

---

## LIKE vs REGEXP

| Need | Tool |
|---|---|
| starts with / ends with / contains | **LIKE** — simpler, faster |
| character sets, repetition, alternatives | **REGEXP** |

```sql
-- equivalent
WHERE name LIKE 'A%'
WHERE name REGEXP '^A'

-- only REGEXP can do this
WHERE name REGEXP '^[AEIOU]'
WHERE phone REGEXP '^[0-9]{10}$'
```

### Anchor cheat sheet

| Pattern | Meaning |
|---|---|
| `'rahul'` (no anchors) | contains "rahul" anywhere |
| `'^rahul'` | starts with "rahul" |
| `'rahul$'` | ends with "rahul" |
| `'^rahul$'` | equals "rahul" exactly |

### LIKE "contains" needs wildcards on both sides
```sql
WHERE email LIKE '%rahul%'   -- contains
WHERE email LIKE 'rahul%'    -- starts with (different!)
```

---

## Building a regex pattern — the method

Translate the English rule phrase by phrase. Don't memorize whole patterns — build them from the rule.

| Rule says | You write |
|---|---|
| "starts with" | `^` |
| "ends with" | `$` |
| "a letter" | `[a-zA-Z]` |
| "a digit" | `[0-9]` |
| "any of these characters" | `[list them]` |
| "any number of them" | `*` |
| "one or more" | `+` |
| "exactly this text" | type it directly |
| "a literal dot" | `\\.` (escaped — bare `.` means "any character") |

**Worked example — "starts with a letter, then letters/digits/underscore/period/dash, ends with @leetcode.com":**
```sql
^[a-zA-Z][a-zA-Z0-9_.-]*@leetcode\\.com$
```

Built piece by piece:
- starts, a letter → `^[a-zA-Z]`
- then, allowed chars, any number → `[a-zA-Z0-9_.-]*`
- ends, literal text → `@leetcode\\.com$`

---

## Case sensitivity — the trap

MySQL string comparisons are **case-insensitive by default** — applies to `=`, `LIKE`, and `REGEXP` alike.

```sql
WHERE name = 'arun'              -- matches 'Arun', 'ARUN', 'arun' — all the same
WHERE mail REGEXP '^winston'     -- case doesn't matter by default
```

**Force case sensitivity with BINARY or the 'c' flag** — this *turns on* strictness, it does not turn it off:

```sql
WHERE name = BINARY 'arun'                          -- now ONLY matches lowercase
WHERE mail REGEXP BINARY '^...@leetcode\\.com$'      -- case now matters
WHERE REGEXP_LIKE(mail, '^...@leetcode\\.com$', 'c') -- 'c' = case-sensitive mode
```

> **Interview question:** "Is `WHERE name = 'arun'` the same as `WHERE name = 'Arun'` in MySQL?" → Yes, by default. No, with `BINARY`.
>
> **Memory hook:** `BINARY` = "compare raw bytes, don't be lenient about case." It switches MySQL *out of* its default forgiving mode.

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
