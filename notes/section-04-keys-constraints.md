# Section 4: Keys & Constraints

## Types of Keys

**Super Key** — *Any* set of columns that uniquely identifies a row.
Example: `{roll_no}`, `{roll_no, name}`, `{email}` — extra columns allowed.
> Broadest category. Every other key is a subset of this.

**Candidate Key** — A **minimal** super key (remove any column and it stops being unique).
Example: `{roll_no}`, `{admission_no}`, `{email}` — each alone is enough.
> `{roll_no, name}` is NOT a candidate key — `name` is redundant baggage.

**Primary Key** — The candidate key actually chosen to identify rows.
> Cannot be NULL, cannot repeat. Exactly **one** per table.

**Alternate Key** — Candidate keys not chosen as the primary key.

**Composite Key** — A primary key made of **two or more columns** together.

**Foreign Key** — A column referring to the primary key of another table.
> Creates the relationship between tables. This is what JOINs use.

**Unique Key** — Ensures all values in a column are different.
> Unlike a primary key, it **can hold one NULL**, and a table can have many.

---

## The Key Hierarchy

```
Super Key  ⊃  Candidate Key  ⊃  Primary Key
```

> Every primary key is a candidate key; every candidate key is a super key. Not the reverse.

---

## Critical Concept: A key belongs to the TABLE, not the column

`student_id` is unique in the **Student** table (one row per student).
But in a **Marks** table, the same student has many rows — one per subject. So `student_id` is NOT unique there.

> Uniqueness depends on the table the column sits in, not on what the column represents.

---

## Finding a Composite Key — the method

**Marks table:**

| student_id | subject_id | score |
|---|---|---|
| 101 | S01 | 85 |
| 101 | S02 | 78 |
| 102 | S01 | 92 |

Neither column alone is unique (101 repeats, S01 repeats). Together they are.

```sql
PRIMARY KEY (student_id, subject_id)
```

### Steps
1. Check each column alone — is any one unique?
2. If not, try pairs.
3. Still not? Add a third.
4. Stop at the **minimum** set that works. Extra columns make it a super key, not a candidate key.

### Three-column example

**Enrollment table** — a student can repeat a course in a later semester:

| course_id | student_id | semester | grade |
|---|---|---|---|
| C101 | 201 | 1 | A |
| C101 | 202 | 1 | B |
| C102 | 201 | 1 | A |
| C101 | 201 | 2 | B |

`(course_id, student_id)` fails — rows 1 and 4 collide. Add semester:

```sql
PRIMARY KEY (course_id, student_id, semester)
```

> Value columns like `grade`, `score`, `salary` can never be part of a key. Keys answer "which row is this?" — value columns answer "what's in it?"

> Composite keys appear constantly in junction tables (student–subject, order–product, employee–project). Any many-to-many relationship expects one.

---

## Foreign Key

A column in one table referring to the primary key of another.

**Department** (parent): `dept_id (PK) | dept_name`
**Employee** (child): `empid (PK) | empname | dept_id (FK)`

```sql
CREATE TABLE Employee (
    empid INT PRIMARY KEY,
    empname VARCHAR(50),
    dept_id VARCHAR(10),
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);
```

### Referential Integrity

A foreign key value must **either match an existing primary key in the parent table, or be NULL.**

```sql
INSERT INTO Employee VALUES (4, 'Priya', 'D99');  -- fails if D99 doesn't exist
```
The insert is rejected with a **referential integrity constraint violation**. This prevents **orphaned records**.

### Can a foreign key be NULL?

> Yes. A NULL foreign key means the row isn't linked yet — e.g. a new employee with no department assigned. A primary key can never be NULL, but a foreign key can.

This is exactly what **LEFT JOIN** questions test ("find employees with no department").

---

## ON DELETE / ON UPDATE

What happens to child rows when the parent row is deleted?

| Option | Behaviour |
|---|---|
| `RESTRICT` | Blocks the delete (**default**) |
| `CASCADE` | Child rows deleted too |
| `SET NULL` | Foreign key set to NULL |

```sql
FOREIGN KEY (cust_id) REFERENCES Customer(cust_id) ON DELETE CASCADE
```

Real-world: deleting a user account → CASCADE removes their posts. Deleting a customer with invoices → RESTRICT, since financial records must survive.

---

## Constraints

| Constraint | What it does |
|---|---|
| `PRIMARY KEY` | Unique + NOT NULL, identifies the row |
| `FOREIGN KEY` | Links to another table's primary key |
| `UNIQUE` | No duplicate values |
| `NOT NULL` | Value cannot be empty |
| `DEFAULT` | Auto-fills a value if none supplied |
| `CHECK` | Value must satisfy a condition |
| `AUTO_INCREMENT` | Auto-generates the next number |

### Full example
```sql
CREATE TABLE Student (
    roll_no INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT CHECK (age >= 17),
    city VARCHAR(50) DEFAULT 'Kochi'
);
```

> **Watch out:** text values in DEFAULT need quotes — `DEFAULT 'Kochi'`, not `DEFAULT Kochi`. Without quotes MySQL reads it as a column name. Numbers don't need quotes: `DEFAULT 25000` is fine.

### Table-level (needed for composite and foreign keys)
```sql
CREATE TABLE Marks (
    student_id INT,
    subject_id INT,
    score INT,
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
);
```

### Adding a constraint later
```sql
ALTER TABLE Employee ADD CONSTRAINT fk_dept
FOREIGN KEY (dept_id) REFERENCES Department(dept_id);
```

---

## Primary Key vs Unique Key

| Point | Primary Key | Unique Key |
|---|---|---|
| NULL allowed? | No | Yes (one NULL) |
| How many per table? | Exactly one | Many |
| Purpose | Identifies the row | Prevents duplicates |

---

## Interview Points

**Can a table have multiple primary keys?**
> No. One primary key only — but it can be composite (built from multiple columns).

**Can a primary key be NULL?**
> No. It must uniquely identify a row, and NULL means unknown.

**Difference between primary key and foreign key?**
> A primary key uniquely identifies rows within its own table. A foreign key refers to a primary key in another table, creating the relationship.

**Why use CHECK?**
> To enforce business rules at the database level rather than trusting application code — e.g. salary must be positive, age at least 18.
