-- SQLite checks foreign keys only after this line (run it once per connection)
PRAGMA foreign_keys = ON;

-- Beyond School · SQL Part 9: Database Design
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

-- A messy table
CREATE TABLE messy (loan_id INTEGER,   member TEXT, city TEXT, books TEXT); INSERT INTO messy VALUES   (1, 'Aisha', 'Austin', 'Harry Potter, Wonder'),   (2, 'Ben', 'Denver', 'Matilda, Dog Man'),   (3, 'Carlos', 'Austin', 'The Hobbit, Harry Potter');
SELECT * FROM messy;

-- The problem with lists
SELECT * FROM messy WHERE books LIKE '%Potter%';

-- Fixing it: 1NF
CREATE TABLE visit_books (   loan_id INTEGER, member TEXT, book TEXT); INSERT INTO visit_books VALUES   (1, 'Aisha', 'Harry Potter'), (1, 'Aisha', 'Wonder'),   (2, 'Ben', 'Matilda'), (2, 'Ben', 'Dog Man'),   (3, 'Carlos', 'The Hobbit'), (3, 'Carlos', 'Harry Potter');
SELECT * FROM visit_books;

-- Now counting works
SELECT book, COUNT(*) AS times FROM visit_books GROUP BY book ORDER BY times DESC, book;

-- 3NF: a cities table
CREATE TABLE cities (city TEXT PRIMARY KEY, state TEXT); INSERT INTO cities VALUES ('Austin', 'Texas'),   ('Denver', 'Colorado'), ('Boston', 'Massachusetts');
SELECT m.name, m.city, c.state FROM members AS m JOIN cities AS c ON m.city = c.city;

-- One-to-many in SQL
SELECT m.name, COUNT(l.loan_id) AS loans FROM members AS m LEFT JOIN loans AS l ON m.member_id = l.member_id GROUP BY m.name ORDER BY m.name;

-- Many-to-many: authors
CREATE TABLE authors (author_id INTEGER PRIMARY KEY, name TEXT); INSERT INTO authors VALUES (1, 'Neil Gaiman'),   (2, 'Terry Pratchett'), (3, 'Roald Dahl'); INSERT INTO books VALUES (9, 'Good Omens',   'Gaiman & Pratchett', 1990, 'Fantasy', 412);
SELECT * FROM authors;

-- The junction table
CREATE TABLE book_authors (   book_id INTEGER REFERENCES books(id),   author_id INTEGER REFERENCES authors(author_id),   PRIMARY KEY (book_id, author_id)); INSERT INTO book_authors VALUES   (8, 1), (9, 1), (9, 2), (2, 3);
SELECT * FROM book_authors;

-- Querying many-to-many
SELECT b.title, a.name FROM book_authors AS ba JOIN books AS b ON ba.book_id = b.id JOIN authors AS a ON ba.author_id = a.author_id ORDER BY b.title, a.name;

-- Counting across the bridge
SELECT a.name, COUNT(*) AS books FROM authors AS a JOIN book_authors AS ba ON a.author_id = ba.author_id GROUP BY a.name ORDER BY books DESC, a.name;

-- ===== CHALLENGES (try first!) =====
-- C1. Practice the bridge: add Terry Pratchett as a pretend co-author of Coraline, list all pairs, then remove that row.
-- C2. Add 'Chicago, Illinois' to cities and list members with their state (keep members with no match).
-- C3. Which authors have written more than one book?

-- ===== ANSWERS =====

-- C1. Practice the bridge: add Terry Pratchett as a pretend co-author of Coraline, list all pairs, then remove that row.
INSERT INTO book_authors VALUES (8, 2);
SELECT b.title, a.name FROM book_authors AS ba JOIN books AS b ON ba.book_id = b.id JOIN authors AS a ON ba.author_id = a.author_id;
DELETE FROM book_authors WHERE book_id = 8 AND author_id = 2;

-- C2. Add 'Chicago, Illinois' to cities and list members with their state (keep members with no match).
INSERT INTO cities VALUES ('Chicago', 'Illinois');
SELECT m.name, c.state FROM members AS m LEFT JOIN cities AS c ON m.city = c.city;

-- C3. Which authors have written more than one book?
SELECT a.name FROM authors AS a JOIN book_authors AS ba ON a.author_id = ba.author_id
GROUP BY a.name HAVING COUNT(*) > 1;
