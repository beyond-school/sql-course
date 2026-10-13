-- Beyond School · SQL Part 4: Smarter Queries
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

-- Subquery with a single value
SELECT title, pages FROM books WHERE pages > (SELECT AVG(pages)                FROM books);

-- Subquery with IN
SELECT name FROM members WHERE member_id IN (   SELECT member_id FROM loans   WHERE return_date IS NULL);

-- CASE: if this, then that
SELECT title, pages,   CASE WHEN pages >= 300 THEN 'Long'        WHEN pages >= 200 THEN 'Medium'        ELSE 'Short'   END AS size FROM books;

-- CASE + GROUP BY
SELECT CASE WHEN pages >= 300 THEN 'Long'             WHEN pages >= 200 THEN 'Medium'             ELSE 'Short' END AS size,        COUNT(*) AS books FROM books GROUP BY size;

-- UNION
SELECT genre FROM books WHERE year < 1990 UNION SELECT genre FROM books WHERE year > 2010;

-- UNION ALL
SELECT genre FROM books WHERE year < 1990 UNION ALL SELECT genre FROM books WHERE year > 2010;

-- UPPER and LENGTH
SELECT UPPER(title) AS shout,        LENGTH(title) AS letters FROM books ORDER BY letters DESC;

-- || and SUBSTR
SELECT title || ' by ' || author AS label,        SUBSTR(author, 1, 1) AS initial FROM books LIMIT 5;

-- Date functions
SELECT loan_id, loan_date,        strftime('%m', loan_date) AS month,        date(loan_date, '+14 days') AS due FROM loans;

-- Days between dates
SELECT loan_id,        julianday(return_date)      - julianday(loan_date) AS days_kept FROM loans WHERE return_date IS NOT NULL;

-- IS NULL
SELECT name, email FROM members WHERE email IS NULL;

-- COALESCE
SELECT name,        COALESCE(email, 'no email yet') AS contact FROM members;

-- NOT IN subquery
SELECT title FROM books WHERE id NOT IN (   SELECT book_id FROM loans);

-- CASE with NULL
SELECT loan_id,   CASE WHEN return_date IS NULL        THEN 'Still out'        ELSE 'Returned'   END AS status FROM loans;

-- LOWER and REPLACE
SELECT title,   LOWER(REPLACE(title, ' ', '-')) AS web_name FROM books;

-- COUNT skips NULL
SELECT COUNT(*) AS members,        COUNT(email) AS with_email FROM members;

-- ===== CHALLENGES (try first!) =====
-- C1. Use CASE to label each loan as Returned or Still out.
-- C2. Which books have fewer pages than the longest book? (subquery)
-- C3. Show every member name in capitals with their city glued on.
-- C4. Show each loan's return date, or 'not yet' if missing.

-- ===== ANSWERS =====

-- C1. Use CASE to label each loan as Returned or Still out.
SELECT loan_id,
  CASE WHEN return_date IS NULL THEN 'Still out' ELSE 'Returned' END AS status
FROM loans;

-- C2. Which books have fewer pages than the longest book? (subquery)
SELECT title, pages FROM books WHERE pages < (SELECT MAX(pages) FROM books);

-- C3. Show every member name in capitals with their city glued on.
SELECT UPPER(name) || ' - ' || city AS label FROM members;

-- C4. Show each loan's return date, or 'not yet' if missing.
SELECT loan_id, COALESCE(return_date, 'not yet') AS returned FROM loans;
