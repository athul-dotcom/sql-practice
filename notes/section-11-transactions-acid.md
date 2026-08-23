# Section 11: Transactions & ACID

## What is a Transaction?

**A group of SQL statements treated as a single unit of work — either all succeed, or none do.**

**The classic example:** Account A sends ₹1,000 to Account B.

```sql
UPDATE Account SET balance = balance - 1000 WHERE acc_id = 'A';
UPDATE Account SET balance = balance + 1000 WHERE acc_id = 'B';
```

If the server crashes between these two statements, ₹1,000 has left A but never arrived at B. Money vanishes. A transaction prevents this — both commit together, or neither does.

> **Interview one-liner:** A transaction is a logical unit of work containing one or more SQL statements that must either all complete successfully or all be rolled back.

---

## The Commands

| Command | What it does |
|---|---|
| `START TRANSACTION` | begins a transaction (also `BEGIN`) |
| `COMMIT` | saves all changes permanently |
| `ROLLBACK` | undoes everything since the transaction started |
| `SAVEPOINT name` | marks a point you can roll back *to* |
| `ROLLBACK TO name` | undoes back to that savepoint only |
| `RELEASE SAVEPOINT name` | discards the mark |

---

## Bank Transfer — worked example

**Account table before:**

| acc_id | holder | balance |
|---|---|---|
| A | Athul | 5000 |
| B | Meera | 3000 |

### Success case
```sql
START TRANSACTION;

UPDATE Account SET balance = balance - 1000 WHERE acc_id = 'A';
UPDATE Account SET balance = balance + 1000 WHERE acc_id = 'B';

COMMIT;
```

**After COMMIT:** A = 4000, B = 4000. Permanent — even a crash won't undo it.

### Failure case
```sql
START TRANSACTION;

UPDATE Account SET balance = balance - 1000 WHERE acc_id = 'A';
-- something goes wrong

ROLLBACK;
```

**After ROLLBACK:** A = 5000, B = 3000. As if nothing happened.

> Until you COMMIT, changes are only visible **inside your own session**. Other users still see the old values.

---

## ⚠️ What can and cannot be rolled back

| | DELETE | TRUNCATE |
|---|---|---|
| Category | **DML** | **DDL** |
| How it works | removes rows one by one, logging each | deallocates the whole data structure at once |
| Rollback? | **Yes** | **No** |

DELETE logs every row it removes, so the database can reverse it. TRUNCATE doesn't log — it drops and recreates the storage. Nothing to reverse from.

**Extra wrinkle:** in MySQL, DDL statements cause an **implicit commit**. Running `TRUNCATE` inside a transaction doesn't just fail to roll back — it silently commits everything before it too.

> **Memory hook:** *DML is forgiving, DDL is final.*
> DELETE, UPDATE, INSERT → recoverable.
> TRUNCATE, DROP, ALTER, CREATE → point of no return.

---

## ACID Properties

### A — Atomicity
**All or nothing.** Every statement succeeds, or none take effect.

*Bank transfer:* both the debit and credit happen, or neither. Money never disappears mid-transfer.

### C — Consistency
**The database moves from one valid state to another.** All constraints, keys, and rules hold before and after.

*Bank transfer:* total money stays the same. 5000 + 3000 = 8000 before; 4000 + 4000 = 8000 after. A transaction violating a foreign key or CHECK constraint is rejected.

### I — Isolation
**Concurrent transactions don't interfere.** Each behaves as if running alone.

*Bank transfer:* if two people withdraw from account A simultaneously, isolation prevents both from reading the same starting balance and overdrawing.

### D — Durability
**Once committed, changes survive anything** — crashes, power loss, restarts.

*Bank transfer:* after COMMIT, the money has moved. A crash a second later doesn't undo it.

---

## ⭐ Atomicity vs Durability — the boundary

This is the pair most often confused.

| Scenario | Property |
|---|---|
| Fails **before** commit → partial work undone | **Atomicity** |
| Succeeds, **then** crash → work still there | **Durability** |

- **Atomicity** protects you *during* the transaction
- **Durability** protects you *after* commit

Once COMMIT succeeds, Atomicity's job is done and Durability takes over.

**Keyword giveaways:**
- crash / power failure / restart / "still there afterwards" → **Durability**
- fails halfway / partial / rolled back → **Atomicity**
- two users at once / simultaneous / concurrent → **Isolation**
- constraints / valid state / totals match → **Consistency**

---

## Interview delivery

> **Atomicity** — all statements succeed or none do.
> **Consistency** — the database stays in a valid state, respecting all constraints.
> **Isolation** — concurrent transactions don't interfere with each other.
> **Durability** — committed changes survive system failures.

---

## SAVEPOINT

A bookmark inside a transaction. Instead of rolling back everything, roll back to a specific point.

```sql
START TRANSACTION;

UPDATE Account SET balance = balance - 1000 WHERE acc_id = 'A';
SAVEPOINT after_debit;

UPDATE Account SET balance = balance + 1000 WHERE acc_id = 'B';
-- something goes wrong with B

ROLLBACK TO after_debit;   -- undoes only the second update

UPDATE Account SET balance = balance + 1000 WHERE acc_id = 'C';  -- send to C instead

COMMIT;
```

The debit from A survives; only the failed credit to B is undone.

> **Interview point:** `ROLLBACK TO savepoint` keeps the transaction **open** — you can continue working. Plain `ROLLBACK` ends it entirely.

### Worked trace

```sql
START TRANSACTION;
INSERT INTO Employee VALUES (6, 'Kiran', 'D01', 60000);
SAVEPOINT sp1;
INSERT INTO Employee VALUES (7, 'Divya', 'D02', 42000);
ROLLBACK TO sp1;
COMMIT;
```

| Step | State |
|---|---|
| INSERT Kiran | Kiran added (uncommitted) |
| SAVEPOINT sp1 | bookmark placed |
| INSERT Divya | Divya added (uncommitted) |
| ROLLBACK TO sp1 | Divya removed, Kiran remains, transaction still open |
| COMMIT | Kiran saved permanently |

**Result:** Kiran exists, Divya does not.

---

## Setup script for practice

```sql
CREATE TABLE Account (
    acc_id VARCHAR(10) PRIMARY KEY,
    holder VARCHAR(50),
    balance INT
);

INSERT INTO Account VALUES
('A', 'Athul', 5000),
('B', 'Meera', 3000),
('C', 'Aatish', 7500);
```

> **Note on practice environments:** DB Fiddle runs each query panel as a fresh auto-committed session, so `ROLLBACK` won't visibly undo anything there. To see transactions actually work you need MySQL Workbench locally. For placement prep the theory is what gets tested — interviewers ask "what does ROLLBACK do?", not "run me a transaction."
