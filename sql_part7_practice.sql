-- Beyond School · SQL Part 7: CTEs, EXISTS & Correlated Subqueries
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

-- Your first CTE
WITH long_books AS (   SELECT title, pages FROM books   WHERE pages >= 300 ) SELECT * FROM long_books ORDER BY title;

-- CTE + JOIN
WITH reading AS (   SELECT l.member_id, SUM(b.pages) AS pages_read   FROM loans AS l JOIN books AS b ON l.book_id = b.id   GROUP BY l.member_id ) SELECT m.name, r.pages_read FROM reading AS r JOIN members AS m ON r.member_id = m.member_id ORDER BY r.pages_read DESC, m.name;

-- Two CTEs together
WITH reading AS (   SELECT l.member_id, SUM(b.pages) AS pages_read   FROM loans AS l JOIN books AS b ON l.book_id = b.id   GROUP BY l.member_id), avg_reading AS (   SELECT AVG(pages_read) AS avg_pages FROM reading) SELECT r.member_id, r.pages_read, a.avg_pages FROM reading AS r, avg_reading AS a WHERE r.pages_read > a.avg_pages;

-- Recursive: count 1 to 10
WITH RECURSIVE numbers(x) AS (   SELECT 1   UNION ALL   SELECT x + 1 FROM numbers WHERE x < 10 ) SELECT x FROM numbers;

-- Recursive: a list of months
WITH RECURSIVE months(m) AS (   SELECT '2026-01-01'   UNION ALL   SELECT date(m, '+1 month') FROM months   WHERE m < '2026-05-01') SELECT m AS month,   (SELECT COUNT(*) FROM loans    WHERE strftime('%m', loan_date) = strftime('%m', m)) AS loans FROM months;

-- Longer than its genre average
SELECT title, genre, pages FROM books AS b WHERE pages > (   SELECT AVG(pages) FROM books AS b2   WHERE b2.genre = b.genre);

-- Correlated subquery in SELECT
SELECT b.title,   (SELECT COUNT(*) FROM loans AS l    WHERE l.book_id = b.id) AS times FROM books AS b ORDER BY times DESC, b.title;

-- EXISTS
SELECT m.name FROM members AS m WHERE EXISTS (   SELECT 1 FROM loans AS l   JOIN books AS b ON l.book_id = b.id   WHERE l.member_id = m.member_id     AND b.genre = 'Fantasy');

-- NOT EXISTS
SELECT title FROM books AS b WHERE NOT EXISTS (   SELECT 1 FROM loans AS l   WHERE l.book_id = b.id);

-- NOT EXISTS for members
SELECT name FROM members AS m WHERE NOT EXISTS (   SELECT 1 FROM loans AS l   WHERE l.member_id = m.member_id);

-- Earliest member in each city
SELECT name, city, joined FROM members AS m WHERE joined = (   SELECT MIN(joined) FROM members AS m2   WHERE m2.city = m.city);

-- ===== CHALLENGES (try first!) =====
-- C1. Use EXISTS to list books that are still out on loan.
-- C2. Use a recursive CTE to count down from 5 to 1.
-- C3. Use a CTE to find genres with more than one book, then list those books.

-- ===== ANSWERS =====

-- C1. Use EXISTS to list books that are still out on loan.
SELECT title FROM books AS b
WHERE EXISTS (SELECT 1 FROM loans AS l WHERE l.book_id = b.id AND l.return_date IS NULL);

-- C2. Use a recursive CTE to count down from 5 to 1.
WITH RECURSIVE countdown(n) AS (
  SELECT 5 UNION ALL SELECT n - 1 FROM countdown WHERE n > 1)
SELECT n FROM countdown;

-- C3. Use a CTE to find genres with more than one book, then list those books.
WITH big AS (SELECT genre FROM books GROUP BY genre HAVING COUNT(*) > 1)
SELECT title, genre FROM books WHERE genre IN (SELECT genre FROM big);
