-- Beyond School · SQL Part 3: Joins: Connecting Tables
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

-- The members table
SELECT * FROM members;

-- The loans table
SELECT * FROM loans;

-- INNER JOIN
SELECT members.name, loans.book_id,        loans.loan_date FROM loans INNER JOIN members   ON loans.member_id = members.member_id;

-- Short table nicknames
SELECT m.name, l.loan_date FROM loans AS l JOIN members AS m   ON l.member_id = m.member_id WHERE m.city = 'Austin';

-- Joining three tables
SELECT m.name, b.title, l.loan_date FROM loans AS l JOIN members AS m ON l.member_id = m.member_id JOIN books AS b ON l.book_id = b.id ORDER BY l.loan_date;

-- LEFT JOIN
SELECT m.name, l.loan_id, l.book_id FROM members AS m LEFT JOIN loans AS l   ON m.member_id = l.member_id;

-- Finding unmatched rows
SELECT m.name FROM members AS m LEFT JOIN loans AS l   ON m.member_id = l.member_id WHERE l.loan_id IS NULL;

-- Books never borrowed
SELECT b.title FROM books AS b LEFT JOIN loans AS l ON b.id = l.book_id WHERE l.loan_id IS NULL;

-- FULL JOIN example
SELECT m.name, l.loan_id FROM members AS m FULL JOIN loans AS l   ON m.member_id = l.member_id ORDER BY l.loan_id;

-- RIGHT JOIN example
SELECT l.loan_id, m.name FROM members AS m RIGHT JOIN loans AS l   ON m.member_id = l.member_id;

-- JOIN + GROUP BY
SELECT m.name, COUNT(l.loan_id) AS loans FROM members AS m LEFT JOIN loans AS l   ON m.member_id = l.member_id GROUP BY m.name ORDER BY loans DESC;

-- JOIN + WHERE
SELECT m.name, b.title, l.loan_date FROM loans AS l JOIN members AS m ON l.member_id = m.member_id JOIN books AS b ON l.book_id = b.id WHERE l.return_date IS NULL;

-- JOIN + GROUP BY city
SELECT m.city, COUNT(*) AS loans FROM loans AS l JOIN members AS m ON l.member_id = m.member_id GROUP BY m.city ORDER BY loans DESC;

-- Most popular book
SELECT b.title, COUNT(*) AS times FROM loans AS l JOIN books AS b ON l.book_id = b.id GROUP BY b.title ORDER BY times DESC LIMIT 2;

-- ===== CHALLENGES (try first!) =====
-- C1. List every book title with how many times it was borrowed (include zeros).
-- C2. Show the titles Aisha borrowed.
-- C3. Which books are still out (not returned)? Show title and member.

-- ===== ANSWERS =====

-- C1. List every book title with how many times it was borrowed (include zeros).
SELECT b.title, COUNT(l.loan_id) AS times_borrowed
FROM books AS b LEFT JOIN loans AS l ON b.id = l.book_id
GROUP BY b.title ORDER BY times_borrowed DESC;

-- C2. Show the titles Aisha borrowed.
SELECT b.title FROM loans AS l
JOIN members AS m ON l.member_id = m.member_id
JOIN books AS b ON l.book_id = b.id
WHERE m.name = 'Aisha';

-- C3. Which books are still out (not returned)? Show title and member.
SELECT b.title, m.name FROM loans AS l
JOIN books AS b ON l.book_id = b.id
JOIN members AS m ON l.member_id = m.member_id
WHERE l.return_date IS NULL;
