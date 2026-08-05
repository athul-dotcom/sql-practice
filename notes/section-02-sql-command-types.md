# Section 2: SQL Command Types

## The 5 Categories

| Category | Full Form | Commands | What it does |
|---|---|---|---|
| **DDL** | Data Definition Language | CREATE, ALTER, DROP, TRUNCATE, RENAME | Defines the **structure** |
| **DML** | Data Manipulation Language | INSERT, UPDATE, DELETE | Changes the **data** |
| **DQL** | Data Query Language | SELECT | **Reads** data |
| **DCL** | Data Control Language | GRANT, REVOKE | Controls **permissions** |
| **TCL** | Transaction Control Language | COMMIT, ROLLBACK, SAVEPOINT | Manages **transactions** |

Memory trick: DDL = structure, DML = data, DQL = read, DCL = permission, TCL = transaction.

---

## Interview Trap: Is SELECT a DML command?

> Strictly, SELECT is **DQL**, though some books club it under DML.

Say "SELECT is DQL" and mention some classify it as DML — that earns bonus points.

---

## DELETE vs TRUNCATE vs DROP

The single most-asked SQL interview question. Learn this cold.

| Point | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| Removes | Rows (can use WHERE) | **All** rows | Entire table |
| Structure kept? | Yes | Yes | No |
| Category | **DML** | DDL | DDL |
| ROLLBACK possible? | **Yes** | No | No |
| Speed | Slow (row by row) | Fast | Fast |

**One-liner:**
> DELETE removes selected rows and can be rolled back; TRUNCATE removes all rows but keeps the structure; DROP removes the whole table. TRUNCATE and DROP are DDL and can't be rolled back.

**Which is faster — DELETE or TRUNCATE?**
TRUNCATE. DELETE logs each row deletion one by one; TRUNCATE deallocates the whole table data at once.

**Can DELETE be rolled back?**
> Yes — DELETE is DML and each row deletion is logged, so it can be rolled back inside a transaction. TRUNCATE cannot, because it's DDL and deallocates data directly.

Memory aid: **DML is forgiving, DDL is final.**

---

## Scenario Questions

**"Remove all 10,000 rows but keep the table for future use."**
→ TRUNCATE. All rows gone, structure stays, faster than DELETE.

**"Remove only the employees from the Sales department."**
→ DELETE, because only DELETE supports a WHERE condition.
```sql
DELETE FROM Employee WHERE department = 'Sales';
```

---

## ALTER vs UPDATE

- **ALTER** changes the table **structure** (DDL)
- **UPDATE** changes the **data** inside rows (DML)
