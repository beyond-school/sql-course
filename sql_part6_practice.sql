-- Beyond School · SQL Part 6: Window Functions
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

-- AVG OVER: every row stays
SELECT title, pages,        AVG(pages) OVER () AS avg_pages FROM books;

-- ROW_NUMBER
SELECT ROW_NUMBER() OVER (ORDER BY pages DESC) AS num,        title, pages FROM books;

-- RANK and DENSE_RANK
SELECT title, pages,   RANK() OVER (ORDER BY pages DESC) AS rnk,   DENSE_RANK() OVER (ORDER BY pages DESC) AS dense FROM books;

-- Rank inside each genre
SELECT genre, title, pages,   RANK() OVER (PARTITION BY genre                ORDER BY pages DESC) AS rnk FROM books;

-- Top 1 per group
SELECT genre, title, pages FROM (   SELECT genre, title, pages,     ROW_NUMBER() OVER (PARTITION BY genre       ORDER BY pages DESC, year) AS rn   FROM books) WHERE rn = 1;

-- SUM OVER: running total
SELECT loan_date, loan_id,   COUNT(*) OVER (ORDER BY loan_date) AS so_far FROM loans ORDER BY loan_date;

-- Running total of pages
SELECT l.loan_date, b.title, b.pages,   SUM(b.pages) OVER (ORDER BY l.loan_date) AS total FROM loans AS l JOIN books AS b ON l.book_id = b.id WHERE l.member_id = 3;

-- Running total per member
SELECT m.name, l.loan_date,   COUNT(*) OVER (PARTITION BY m.name     ORDER BY l.loan_date) AS so_far FROM loans AS l JOIN members AS m ON l.member_id = m.member_id;

-- LAG: compare with the previous row
SELECT loan_id, loan_date,   LAG(loan_date) OVER (ORDER BY loan_date) AS previous FROM loans ORDER BY loan_date;

-- LEAD: peek at the next row
SELECT title, pages,   LEAD(title) OVER (ORDER BY pages) AS next_longer FROM books ORDER BY pages;

-- LAG with math
SELECT title, pages,   pages - LAG(pages) OVER (ORDER BY pages) AS extra FROM books ORDER BY pages;

-- ===== CHALLENGES (try first!) =====
-- C1. Rank members by how many loans they have made.
-- C2. Number each member's loans 1, 2, 3 in date order.
-- C3. Show each book's year and the year of the next newer book.

-- ===== ANSWERS =====

-- C1. Rank members by how many loans they have made.
SELECT m.name, COUNT(*) AS loans,
  RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM loans AS l JOIN members AS m ON l.member_id = m.member_id
GROUP BY m.name;

-- C2. Number each member's loans 1, 2, 3 in date order.
SELECT member_id, loan_date,
  ROW_NUMBER() OVER (PARTITION BY member_id ORDER BY loan_date) AS nth
FROM loans;

-- C3. Show each book's year and the year of the next newer book.
SELECT title, year, LEAD(year) OVER (ORDER BY year) AS next_year
FROM books;
