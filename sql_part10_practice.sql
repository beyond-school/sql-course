-- Beyond School · SQL Part 10: Final Project: Pet Shop Database
-- Open sqliteonline.com (SQLite), db-fiddle.com (SQLite) or sqlime.org, paste the SETUP and Run, then run each query.

-- ===== SETUP =====
-- Part 10 builds the pet shop from scratch. Run every statement below, in order.

-- ===== QUERIES FROM THE VIDEO (run in order) =====

-- Build: owners
CREATE TABLE owners (   owner_id INTEGER PRIMARY KEY,   name TEXT NOT NULL,   city TEXT,   phone TEXT UNIQUE); INSERT INTO owners VALUES   (1, 'Maya', 'Austin', '555-0101'), (2, 'Leo', 'Denver', '555-0102'),   (3, 'Priya', 'Austin', '555-0103'), (4, 'Sam', 'Boston', '555-0104'),   (5, 'Zoe', 'Denver', '555-0105');
SELECT * FROM owners;

-- Build: pets
CREATE TABLE pets (   pet_id INTEGER PRIMARY KEY,   name TEXT NOT NULL, species TEXT NOT NULL,   birth_year INTEGER,   owner_id INTEGER REFERENCES owners(owner_id)); INSERT INTO pets VALUES (1, 'Biscuit', 'Dog', 2019, 1),   (2, 'Whiskers', 'Cat', 2021, 1), (3, 'Rex', 'Dog', 2016, 2),   (4, 'Nemo', 'Fish', 2024, 3), (5, 'Luna', 'Cat', 2020, 3),   (6, 'Coco', 'Parrot', 2018, 4), (7, 'Pepper', 'Dog', 2022, 3);
SELECT * FROM pets;

-- Build: products
CREATE TABLE products (   product_id INTEGER PRIMARY KEY,   name TEXT NOT NULL, category TEXT,   price REAL CHECK (price > 0)); INSERT INTO products VALUES (1, 'Dog Food 5kg', 'Food', 25.0),   (2, 'Cat Food 2kg', 'Food', 15.0), (3, 'Squeaky Bone', 'Toy', 6.0),   (4, 'Fish Flakes', 'Food', 4.5), (5, 'Bird Cage', 'Home', 80.0),   (6, 'Cat Tree', 'Home', 60.0), (7, 'Laser Pointer', 'Toy', 8.0);
SELECT * FROM products;

-- Build: sales + sale_items
CREATE TABLE sales (sale_id INTEGER PRIMARY KEY,   owner_id INTEGER NOT NULL REFERENCES owners(owner_id),   sale_date TEXT NOT NULL); CREATE TABLE sale_items (   sale_id INTEGER REFERENCES sales(sale_id),   product_id INTEGER REFERENCES products(product_id),   qty INTEGER DEFAULT 1 CHECK (qty > 0),   PRIMARY KEY (sale_id, product_id));
SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;

-- Fill: a week of sales
BEGIN; INSERT INTO sales VALUES (1, 1, '2026-03-01'), (2, 2, '2026-03-02'),   (3, 3, '2026-03-02'), (4, 1, '2026-03-05'),   (5, 4, '2026-03-07'), (6, 3, '2026-03-09'); INSERT INTO sale_items VALUES (1, 1, 2), (1, 3, 1), (2, 1, 1),   (3, 4, 3), (3, 2, 1), (4, 2, 2), (4, 3, 2), (5, 5, 1),   (6, 1, 1), (6, 3, 1); COMMIT;
SELECT * FROM sale_items;

-- Q1: owners and their pets
SELECT o.name AS owner, p.name AS pet, p.species FROM pets AS p JOIN owners AS o ON p.owner_id = o.owner_id ORDER BY o.name, p.name;

-- Q2: pets per species
SELECT species, COUNT(*) AS pets FROM pets GROUP BY species ORDER BY pets DESC, species;

-- Q3: owners with no pets
SELECT o.name FROM owners AS o LEFT JOIN pets AS p ON o.owner_id = p.owner_id WHERE p.pet_id IS NULL;

-- Q4: total of each sale
SELECT s.sale_id, s.sale_date,        SUM(si.qty * pr.price) AS total FROM sales AS s JOIN sale_items AS si ON s.sale_id = si.sale_id JOIN products AS pr ON si.product_id = pr.product_id GROUP BY s.sale_id;

-- Q5: best-selling products
SELECT pr.name, SUM(si.qty) AS sold FROM sale_items AS si JOIN products AS pr ON si.product_id = pr.product_id GROUP BY pr.name ORDER BY sold DESC, pr.name LIMIT 3;

-- Q6: rank the customers
SELECT o.name, SUM(si.qty * pr.price) AS spent,   RANK() OVER (ORDER BY SUM(si.qty * pr.price) DESC) AS rnk FROM owners AS o JOIN sales AS s ON o.owner_id = s.owner_id JOIN sale_items AS si ON s.sale_id = si.sale_id JOIN products AS pr ON si.product_id = pr.product_id GROUP BY o.name;

-- Q7: running revenue
WITH daily AS (   SELECT s.sale_date, SUM(si.qty * pr.price) AS revenue   FROM sales AS s   JOIN sale_items AS si ON s.sale_id = si.sale_id   JOIN products AS pr ON si.product_id = pr.product_id   GROUP BY s.sale_date) SELECT sale_date, revenue,   SUM(revenue) OVER (ORDER BY sale_date) AS so_far FROM daily;

-- Q8: products never sold
SELECT name, price FROM products AS p WHERE NOT EXISTS (   SELECT 1 FROM sale_items AS si   WHERE si.product_id = p.product_id);

-- Q9: price labels
SELECT name, price,   CASE WHEN price >= 50 THEN 'Big buy'        WHEN price >= 10 THEN 'Regular'        ELSE 'Small treat' END AS label FROM products ORDER BY price DESC;

-- Q10: above-average spenders (view)
CREATE VIEW vip AS WITH spend AS (   SELECT s.owner_id, SUM(si.qty * pr.price) AS spent   FROM sales AS s   JOIN sale_items AS si ON s.sale_id = si.sale_id   JOIN products AS pr ON si.product_id = pr.product_id   GROUP BY s.owner_id) SELECT o.name, sp.spent FROM spend AS sp JOIN owners AS o ON sp.owner_id = o.owner_id WHERE sp.spent > (SELECT AVG(spent) FROM spend);
SELECT * FROM vip ORDER BY spent DESC;

-- Bonus: an index
CREATE INDEX idx_sales_owner ON sales(owner_id); CREATE INDEX idx_pets_owner ON pets(owner_id);
EXPLAIN QUERY PLAN SELECT * FROM pets WHERE owner_id = 3;

-- ===== CHALLENGES (try first!) =====
-- C1. Add a grooming appointments table for pets, then find which pet has the most appointments.
-- C2. Total revenue per product category.
-- C3. Which owners in Austin bought something?

-- ===== ANSWERS =====

-- C1. Add a grooming appointments table for pets, then find which pet has the most appointments.
CREATE TABLE appointments (appt_id INTEGER PRIMARY KEY, pet_id INTEGER REFERENCES pets(pet_id), appt_date TEXT, service TEXT);
INSERT INTO appointments VALUES (1, 1, '2026-03-03', 'Bath'), (2, 1, '2026-03-10', 'Nail trim'), (3, 5, '2026-03-04', 'Bath');
SELECT p.name, COUNT(*) AS visits FROM appointments AS a JOIN pets AS p ON a.pet_id = p.pet_id GROUP BY p.name ORDER BY visits DESC LIMIT 1;

-- C2. Total revenue per product category.
SELECT pr.category, SUM(si.qty * pr.price) AS revenue FROM sale_items AS si JOIN products AS pr ON si.product_id = pr.product_id GROUP BY pr.category ORDER BY revenue DESC;

-- C3. Which owners in Austin bought something?
SELECT DISTINCT o.name FROM owners AS o JOIN sales AS s ON o.owner_id = s.owner_id WHERE o.city = 'Austin';
