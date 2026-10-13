-- Beyond School · SQL Part 2: Counting, Math & Grouping
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

-- ===== QUERIES FROM THE VIDEO (run in order) =====

-- COUNT: how many?
SELECT COUNT(*) FROM books;

-- SUM: add it all up
SELECT SUM(pages) FROM books;

-- AVG: the average
SELECT AVG(pages) FROM books;

-- MIN and MAX
SELECT MIN(year), MAX(year) FROM books;

-- AS: friendly names
SELECT COUNT(*) AS total_books,        AVG(pages) AS avg_pages FROM books;

-- DISTINCT: no repeats
SELECT DISTINCT genre FROM books;

-- GROUP BY: count per genre
SELECT genre, COUNT(*) AS books FROM books GROUP BY genre;

-- GROUP BY with AVG + ORDER BY
SELECT genre, AVG(pages) AS avg_pages FROM books GROUP BY genre ORDER BY avg_pages DESC;

-- HAVING in action
SELECT genre, COUNT(*) AS books FROM books GROUP BY genre HAVING COUNT(*) >= 2;

-- Putting it all together
SELECT genre, COUNT(*) AS books,        MAX(pages) AS longest FROM books WHERE year > 1950 GROUP BY genre HAVING COUNT(*) >= 2 ORDER BY books DESC;

-- COUNT(DISTINCT)
SELECT COUNT(DISTINCT author) AS authors,        COUNT(*) AS books FROM books;

-- WHERE + COUNT
SELECT COUNT(*) AS old_books FROM books WHERE year < 2000;

-- ROUND + top genre
SELECT genre, SUM(pages) AS total_pages,        ROUND(AVG(pages), 0) AS avg_rounded FROM books GROUP BY genre ORDER BY total_pages DESC LIMIT 1;

-- ===== CHALLENGES (try first!) =====
-- C1. Show the average pages per genre, only for genres with 2 or more books.
-- C2. How many books were written before 2000?
-- C3. Total pages per genre, biggest first.
-- C4. How many different authors are there?

-- ===== ANSWERS =====

-- C1. Show the average pages per genre, only for genres with 2 or more books.
SELECT genre, AVG(pages) AS avg_pages FROM books
GROUP BY genre
HAVING COUNT(*) >= 2;

-- C2. How many books were written before 2000?
SELECT COUNT(*) AS old_books FROM books WHERE year < 2000;

-- C3. Total pages per genre, biggest first.
SELECT genre, SUM(pages) AS total_pages FROM books
GROUP BY genre ORDER BY total_pages DESC;

-- C4. How many different authors are there?
SELECT COUNT(DISTINCT author) AS authors FROM books;
