-- Beyond School · SQL Part 8: Views, Indexes & Transactions
-- Open sqliteonline.com (SQLite), db-fiddle.com (SQLite) or sqlime.org, paste the SETUP and Run, then run each query.

-- ===== SETUP =====
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  title TEXT,
  author TEXT,
  year INTEGER,
  genre TEXT,
  pages INTEGER
);
INSERT INTO books VALUES
  (1, 'Harry Potter', 'J.K. Rowling', 1997, 'Fantasy', 309),
  (2, 'Matilda', 'Roald Dahl', 1988, 'Comedy', 240),
  (3, 'Wonder', 'R.J. Palacio', 2012, 'Drama', 310),
  (4, 'The Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasy', 310),
  (5, 'Holes', 'Louis Sachar', 1998, 'Mystery', 233),
  (6, 'Charlotte''s Web', 'E.B. White', 1952, 'Classic', 192),
  (7, 'Dog Man', 'Dav Pilkey', 2016, 'Comedy', 240),
  (8, 'Coraline', 'Neil Gaiman', 2002, 'Fantasy', 162);

CREATE TABLE members (
  member_id INTEGER PRIMARY KEY,
  name TEXT,
  city TEXT,
  joined TEXT,
  email TEXT
);
INSERT INTO members VALUES
  (1, 'Aisha', 'Austin', '2023-01-15', 'aisha@mail.com'),
  (2, 'Ben', 'Denver', '2023-03-02', NULL),
  (3, 'Carlos', 'Austin', '2024-06-20', 'carlos@mail.com'),
  (4, 'Dana', 'Boston', '2024-09-10', NULL),
  (5, 'Eli', 'Denver', '2025-02-01', 'eli@mail.com');

CREATE TABLE loans (
  loan_id INTEGER PRIMARY KEY,
  book_id INTEGER,
  member_id INTEGER,
  loan_date TEXT,
  return_date TEXT
);
INSERT INTO loans VALUES
  (1, 1, 1, '2026-01-05', '2026-01-19'),
  (2, 3, 1, '2026-02-10', NULL),
  (3, 2, 2, '2026-01-20', '2026-02-03'),
  (4, 4, 3, '2026-03-01', '2026-03-15'),
  (5, 1, 3, '2026-04-02', NULL),
  (6, 7, 4, '2026-04-10', '2026-04-24'),
  (7, 7, 2, '2026-05-01', NULL),
  (8, 5, 4, '2026-05-15', NULL);

-- ===== QUERIES FROM THE VIDEO (run in order) =====

-- CREATE VIEW
CREATE VIEW open_loans AS SELECT l.loan_id, m.name, b.title, l.loan_date FROM loans AS l JOIN members AS m ON l.member_id = m.member_id JOIN books AS b ON l.book_id = b.id WHERE l.return_date IS NULL;
SELECT * FROM open_loans;

-- Using a view like a table
SELECT name, title FROM open_loans WHERE loan_date >= '2026-04-01' ORDER BY loan_date;

-- Views stay up to date
UPDATE loans SET return_date = '2026-05-20' WHERE loan_id = 7;
SELECT * FROM open_loans;

-- Make a big table
CREATE TABLE visits AS WITH RECURSIVE n(x) AS (   SELECT 1 UNION ALL SELECT x + 1 FROM n WHERE x < 100000) SELECT x AS visit_id, (x % 5) + 1 AS member_id,        date('2026-01-01', '+' || (x % 365) || ' days') AS day FROM n;
SELECT COUNT(*) AS visits FROM visits;

-- EXPLAIN QUERY PLAN: SCAN
EXPLAIN QUERY PLAN SELECT * FROM visits WHERE day = '2026-03-15';

-- CREATE INDEX
CREATE INDEX idx_visits_day ON visits(day);
EXPLAIN QUERY PLAN SELECT * FROM visits WHERE day = '2026-03-15';

-- Same answer, faster
SELECT COUNT(*) AS visits FROM visits WHERE day = '2026-03-15';

-- BEGIN and COMMIT
BEGIN; UPDATE loans SET return_date = '2026-05-21'   WHERE loan_id = 5; INSERT INTO loans VALUES   (9, 8, 3, '2026-05-21', NULL); COMMIT;
SELECT * FROM loans WHERE member_id = 3;

-- ROLLBACK: the undo button
BEGIN; DELETE FROM loans; ROLLBACK;
SELECT COUNT(*) AS loans FROM loans;

-- CHECK and DEFAULT
CREATE TABLE ratings (   rating_id INTEGER PRIMARY KEY,   book_id INTEGER NOT NULL REFERENCES books(id),   stars INTEGER CHECK (stars BETWEEN 1 AND 5),   source TEXT DEFAULT 'desk' ); INSERT INTO ratings (rating_id, book_id, stars) VALUES (1, 7, 5), (2, 6, 4);
SELECT * FROM ratings;

-- ===== CHALLENGES (try first!) =====
-- C1. Create a view of members who have no email yet, then select from it.
-- C2. Add an index on loans(member_id) and check the query plan.
-- C3. Inside a transaction, delete all ratings, then undo it.

-- ===== ANSWERS =====

-- C1. Create a view of members who have no email yet, then select from it.
CREATE VIEW no_email AS SELECT name, city FROM members WHERE email IS NULL;
SELECT * FROM no_email;

-- C2. Add an index on loans(member_id) and check the query plan.
CREATE INDEX idx_loans_member ON loans(member_id);
EXPLAIN QUERY PLAN SELECT * FROM loans WHERE member_id = 2;

-- C3. Inside a transaction, delete all ratings, then undo it.
BEGIN;
DELETE FROM ratings;
ROLLBACK;
SELECT COUNT(*) FROM ratings;
