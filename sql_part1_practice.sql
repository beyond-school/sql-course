-- SQL Part 1 practice script
-- 1) Open sqliteonline.com (choose SQLite), db-fiddle.com (SQLite) or sqlime.org
-- 2) Paste the SETUP block and Run. 3) Run each query one at a time.

-- ===== SETUP =====
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  title TEXT,
  author TEXT,
  year INTEGER,
  genre TEXT
);

INSERT INTO books (id, title, author, year, genre) VALUES
  (1, 'Harry Potter', 'J.K. Rowling', 1997, 'Fantasy'),
  (2, 'Matilda', 'Roald Dahl', 1988, 'Comedy'),
  (3, 'Wonder', 'R.J. Palacio', 2012, 'Drama'),
  (4, 'The Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasy'),
  (5, 'Holes', 'Louis Sachar', 1998, 'Mystery'),
  (6, 'Charlotte''s Web', 'E.B. White', 1952, 'Classic'),
  (7, 'Dog Man', 'Dav Pilkey', 2016, 'Comedy'),
  (8, 'Coraline', 'Neil Gaiman', 2002, 'Fantasy');

-- ===== QUERIES FROM THE VIDEO =====

-- Your first query: SELECT *
SELECT * FROM books;

-- Pick columns: SELECT title, author
SELECT title, author FROM books;

-- WHERE with = (equals)
SELECT * FROM books WHERE genre = 'Fantasy';

-- WHERE with > and <
SELECT title, year FROM books WHERE year > 2000;

-- AND: both must be true
SELECT title, genre, year FROM books WHERE genre = 'Fantasy' AND year > 1990;

-- OR: either can be true
SELECT title, genre FROM books WHERE genre = 'Comedy' OR genre = 'Mystery';

-- LIKE: search by pattern
SELECT title FROM books WHERE title LIKE 'H%';

-- ORDER BY ASC / DESC
SELECT title, year FROM books ORDER BY year DESC;

-- LIMIT: top results
SELECT title, year FROM books ORDER BY year DESC LIMIT 3;

-- Putting it all together
SELECT title, year FROM books WHERE year < 2000 ORDER BY year ASC LIMIT 2;

-- ===== CHALLENGES (try first! answers at the bottom) =====
-- C1. Two newest Fantasy books (video challenge)
-- C2. Show only title and year
-- C3. Books older than 1960
-- C4. Comedy books written after 2000
-- C5. Titles containing the word 'man'
-- C6. All books sorted A to Z by title
-- C7. The single oldest book

-- ===== ANSWERS =====

-- C1. Two newest Fantasy books (video challenge)
SELECT title, year FROM books
WHERE genre = 'Fantasy'
ORDER BY year DESC
LIMIT 2;

-- C2. Show only title and year
SELECT title, year FROM books;

-- C3. Books older than 1960
SELECT title, year FROM books
WHERE year < 1960;

-- C4. Comedy books written after 2000
SELECT title, year FROM books
WHERE genre = 'Comedy' AND year > 2000;

-- C5. Titles containing the word 'man'
SELECT title FROM books
WHERE title LIKE '%man%';

-- C6. All books sorted A to Z by title
SELECT * FROM books
ORDER BY title ASC;

-- C7. The single oldest book
SELECT title, year FROM books
ORDER BY year ASC
LIMIT 1;
