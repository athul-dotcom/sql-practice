# Section 10: Normalization

## Why normalization exists

Consider one big table storing everything:

**StudentCourse (badly designed):**

| roll_no | student_name | dept | course_id | course_name | instructor |
|---|---|---|---|---|---|
| 101 | Athul | MCA | C01 | DBMS | Dr. Rao |
| 101 | Athul | MCA | C02 | NLP | Dr. Kumar |
| 102 | Aatish | MCA | C01 | DBMS | Dr. Rao |
| 103 | Meera | MBA | C01 | DBMS | Dr. Rao |

It has three problems, and interviewers expect you to name them:

### The three anomalies

**1. Insertion anomaly**
You want to add a new course nobody has enrolled in yet. You can't — every row needs a `roll_no`. The course can't exist without a student.

**2. Update anomaly**
Dr. Rao changes his name. "DBMS" appears in three rows, so all three need updating. Miss one and the database contradicts itself.

**3. Deletion anomaly**
Delete the last student taking a course, and the course record vanishes too. You lose data you never meant to delete.

**Root cause:** the table stores two different *things* (students and courses) mashed together.

> **Interview one-liner:** Normalization is the process of organizing data to reduce redundancy and eliminate insertion, update, and deletion anomalies.

---

## Functional Dependency

**Functional Dependency (FD)** — if you know column A, you can determine column B. Written `A → B`, read as *"A determines B."*

```
roll_no   → student_name
roll_no   → dept
course_id → course_name
course_id → instructor
```

But `student_name → roll_no` fails — two students could share a name.

### The test for any FD

> Pick any value of A. Does it always give exactly **one** value of B? If two rows share the same A but differ in B, the dependency does not hold.

Example — does `dept_id → salary` hold?

| dept_id | salary | |
|---|---|---|
| D01 | 55000 | |
| D01 | 50000 | same A, different B → **no FD** |

Salary depends on the individual employee, not the department.

> Every normal form is a rule about which FDs are allowed. Get the FDs right and normalization becomes mechanical.

---

## 1NF — First Normal Form

**Rule:** every cell holds a **single, atomic value**. No lists, no repeating groups.

**Violates 1NF:**

| roll_no | name | phone |
|---|---|---|
| 101 | Athul | 9876543210, 9123456780 |
| 102 | Aatish | 9998887766 |

**Fixed:**

| roll_no | name | phone |
|---|---|---|
| 101 | Athul | 9876543210 |
| 101 | Athul | 9123456780 |
| 102 | Aatish | 9998887766 |

> **1NF = atomic values, no multi-valued attributes, no repeating groups.**

---

## 2NF — Second Normal Form

**Rule:** in 1NF, **plus** no **partial dependency** — every non-key column must depend on the **entire** primary key, not just part of it.

> Only relevant when the primary key is **composite**. A single-column primary key passes 2NF automatically.

**Violates 2NF** — PK is `(roll_no, course_id)`:

| roll_no | course_id | student_name | course_name |
|---|---|---|---|
| 101 | C01 | Athul | DBMS |
| 101 | C02 | Athul | NLP |
| 102 | C01 | Aatish | DBMS |

| Column | Depends on | Verdict |
|---|---|---|
| student_name | roll_no alone | partial |
| course_name | course_id alone | partial |

**Fixed — three tables:**

**Student:** `roll_no (PK) | student_name`
**Course:** `course_id (PK) | course_name`
**Enrollment:** `(roll_no, course_id)` composite PK

### Important: key columns are never "partially dependent"

Partial dependency is a property of **non-key** columns only. Don't say "order_id has a partial dependency" — order_id is part of the key.

### Worked example

**OrderDetails**, PK `(order_id, product_id)`:

| order_id | product_id | product_name | product_price | quantity |
|---|---|---|---|---|
| 1 | P01 | Pen | 10 | 5 |
| 1 | P02 | Notebook | 40 | 2 |
| 2 | P01 | Pen | 10 | 3 |

| Column | Needs which part of key? | Verdict |
|---|---|---|
| product_name | product_id only | partial |
| product_price | product_id only | partial |
| **quantity** | **both** | full — stays |

**Why quantity stays:** "how many pens in order 1?" needs *both* the order and the product. Order 1 had 5 pens, order 2 had 3. Neither column alone answers it.

**Fixed — two tables, not three:**

**Product:** `product_id (PK) | product_name | product_price`
**OrderDetails:** `(order_id, product_id) PK | quantity`

### The method for any 2NF question
1. Identify the composite primary key
2. List every non-key column
3. For each, ask: does this need the *whole* key, or just part?
4. Part only → move to a new table with that part as PK
5. Whole key → stays put

---

## 3NF — Third Normal Form

**Rule:** in 2NF, **plus** no **transitive dependency** — no non-key column may depend on another non-key column.

A transitive dependency is a chain: `A → B → C`.

**Violates 3NF:**

**Employee:** `empid (PK) | empname | dept_id | dept_name`

| empid | empname | dept_id | dept_name |
|---|---|---|---|
| 1 | Arun | D01 | IT |
| 2 | Rahul | D02 | HR |
| 3 | Neha | D01 | IT |

The chain: `empid → dept_id → dept_name`

`dept_name` depends on `dept_id`, which is itself a non-key column. So "IT" repeats for every IT employee.

**Fixed:**

**Department:** `dept_id (PK) | dept_name`
**Employee:** `empid (PK) | empname | dept_id (FK)`

> This is exactly the Employee/Department structure used throughout the JOINs section — now you know *why* it's split that way.

> **Interview one-liner:** 3NF removes transitive dependencies — no non-key attribute should depend on another non-key attribute. Every non-key column must depend directly on the primary key.

---

## BCNF — Boyce-Codd Normal Form

**Rule:** in 3NF, **plus** for every dependency `A → B`, **A must be a super key**.

A stricter 3NF. Only matters when a table has **multiple overlapping candidate keys**.

**Example** — a student takes a subject; each subject has one teacher; a teacher teaches only one subject:

| student | subject | teacher |
|---|---|---|
| Athul | DBMS | Rao |
| Athul | NLP | Kumar |
| Aatish | DBMS | Rao |

**Candidate keys:** `(student, subject)` and `(student, teacher)` — overlapping.

**Problem dependency:** `teacher → subject`. Is `teacher` a super key? No — "Rao" appears twice, so it can't identify a row alone. → **violates BCNF**, though it passes 3NF (because `subject` is part of a candidate key, which 3NF permits).

**Fixed:**

**TeacherSubject:** `teacher (PK) | subject`
**StudentTeacher:** `(student, teacher)` PK

> **Interview answer:** BCNF is a stronger version of 3NF. For every functional dependency A → B, A must be a super key. A table can be in 3NF but not BCNF when it has overlapping candidate keys.

> BCNF rarely comes up beyond the definition. Know the one-liner and that it's stricter than 3NF.

---

## Summary

| Form | Removes | Rule |
|---|---|---|
| **1NF** | Multi-valued cells | Atomic values only |
| **2NF** | Partial dependencies | Non-key columns depend on the *whole* composite key |
| **3NF** | Transitive dependencies | No non-key column depends on another non-key column |
| **BCNF** | Remaining anomalies | Every determinant must be a super key |

**The memorable phrase:** *"The key, the whole key, and nothing but the key."*
- the key → 1NF
- the whole key → 2NF
- nothing but the key → 3NF

---

## ⭐ The pattern to recognize in any normalization question

**LibraryRecord**, PK `issue_id`:

| issue_id | book_id | book_title | author | member_id | member_name | issue_date |
|---|---|---|---|---|---|---|

**Dependencies:**
```
issue_id  → book_id, member_id, issue_date
book_id   → book_title, author
member_id → member_name
```

`book_title`, `author`, `member_name` are all transitive. `issue_date` is **direct** — it belongs to the specific issue event, not to the member (one member borrows on many dates).

**3NF split — three tables:**

**Book:** `book_id (PK) | book_title | author`
**Member:** `member_id (PK) | member_name`
**Issue:** `issue_id (PK) | book_id (FK) | member_id (FK) | issue_date`

> **The general shape:** columns describing an **entity** (book, member, product, department) move out to their own table. Columns describing the **event or transaction** (dates, quantities, amounts) stay in the central table alongside the foreign keys.
>
> This is why `quantity` stayed in OrderDetails and `issue_date` stays in Issue. It's the structure of almost every normalized database.
