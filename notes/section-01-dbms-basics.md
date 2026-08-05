# Section 1: DBMS Basics

## Core Definitions

**Data** — Raw facts and figures with no meaning on their own.
Example: "Athul", 22, "Kochi" — just values, no context.
> Data becomes **information** when processed and given context.

**Database** — An organized collection of related data stored so it can be easily accessed and managed.
Example: A college's student records, all stored together.
> Organized ≠ just stored. A folder of random files is storage; a database has structure.

**DBMS (Database Management System)** — Software used to create, store, manage, and retrieve data from a database.
Example: The college office software that adds a student, updates marks, searches a roll number.
> DBMS is the **software layer** between the user and the data. Examples: MySQL, Oracle, MongoDB.

**RDBMS (Relational DBMS)** — A DBMS that stores data in **tables** (rows & columns) and links tables using **keys**.
Example: A `Students` table and a `Courses` table connected by `student_id`.
> Based on E.F. Codd's relational model. All RDBMS are DBMS, but not all DBMS are RDBMS.

**MySQL** — An open-source RDBMS that uses SQL as its query language.
> MySQL is the *database software*; SQL is the *language*. Classic trick question — don't mix these up.

---

## SQL vs MySQL

> **SQL** is the *language* used to query and manipulate data. **MySQL** is the *software (RDBMS)* that uses SQL to manage databases.

Analogy: SQL is like English; MySQL is like a person who speaks English. Oracle and PostgreSQL also "speak" SQL.

---

## Is MongoDB an RDBMS?

> No. MongoDB is a NoSQL DBMS that stores data as JSON-like documents (technically BSON) with a flexible schema, whereas an RDBMS stores data in tables with a fixed schema and relationships.

---

## DBMS vs RDBMS

| Point | DBMS | RDBMS |
|---|---|---|
| Storage | Files, hierarchies, documents | **Tables** (rows & columns) |
| Relationships | No relationships between data | Tables linked via **keys** |
| Normalization | Not supported | Supported |
| Example | MongoDB, XML DB | MySQL, Oracle, PostgreSQL |

One-liner: **"RDBMS is a DBMS based on the relational model, where data is stored in tables and related using keys."**

---

## DBMS vs File System

A **file system** is just storing data in ordinary files — Excel sheets, .txt files, folders. No software managing them.

| Problem in File System | How DBMS solves it |
|---|---|
| **Redundancy** — same data copied in many files | Single central storage |
| **Inconsistency** — update one copy, forget another | One update reflects everywhere |
| **Security** — anyone can open a file | User access control (GRANT/REVOKE) |
| **Hard to search** — must write code to read files | Simple queries (SELECT) |
| **No concurrent access** — two people can't safely edit | Handles multiple users safely |

Memory trick: **R-I-S-C** → Redundancy, Inconsistency, Security, Concurrency. File systems fail at all four.

**Interview answer:**
> In a file system, the same data gets duplicated across files, causing redundancy and inconsistency when one copy is updated but others aren't. A DBMS stores data centrally, so updates reflect everywhere, and it also provides security, easy searching with queries, and safe concurrent access by multiple users.

---

## What makes an RDBMS "relational"?

> Data is stored in **tables**, and tables are **related to each other using keys** (primary and foreign keys).

---

## Quick-Fire Terms

| Term | Definition | Formal name |
|---|---|---|
| **Table** | Collection of related data in rows & columns | Relation |
| **Row** | One single record in a table | Tuple |
| **Column** | One field/property of the table | Attribute |
| **Schema** | The structure/blueprint of the database — table names, columns, datatypes, keys | — |

> The formal words matter: **Table = Relation, Row = Tuple, Column = Attribute.** Interviewers deliberately say "tuple" to check if you know it's just a row.
