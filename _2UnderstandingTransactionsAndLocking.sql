-- Working with PostgreSQL transactions
SELECT now(), now();

-- Running more than one command into a transaction
BEGIN;
	SELECT now();
	
	SELECT now();
COMMIT;

-- Handling errors inside a transaction
BEGIN;
	SELECT 1;
	
	SELECT 1 / 0;
	
	SELECT 1;
COMMIT;

-- Making use of SAVEPOINT
BEGIN;
	SELECT 1;
	
	SAVEPOINT a;
	
	SELECT 2 / 0;
	
	SELECT 2;
	
	ROLLBACK TO SAVEPOINT a;
	
	SELECT 3;
COMMIT;

-- Transactional DDLs
-- postgres=# \d
BEGIN;
	CREATE TABLE t_test (id int);
	
	ALTER TABLE t_test
	ALTER COLUMN id TYPE int8;
	
	-- postgres=# \d
ROLLBACK;
	
-- postgres=# \d

-- Understanding basic locking
CREATE TABLE t_test(id int);
INSERT INTO t_test VALUES (1);

-- Avoiding typical mistakes and explicit locking
CREATE TABLE product (id int);
BEGIN;
	LOCK TABLE product IN ACCESS EXCLUSIVE MODE;
	
	INSERT INTO product
	SELECT COALESCE(max(id) + 1, 1) FROM product;
COMMIT;

SELECT * FROM product;

-- Alternative to locking
/*
Consider the following example: you are asked to write an application generating invoice numbers. 
The tax office might require you to create invoice numbers without gaps and without duplicates. 
How would you do it? Of course, one solution would be a table lock. However, you can really do better. 
Here is what I would do
*/
SELECT * FROM t_invoice;
SELECT * FROM t_watermark;
CREATE TABLE t_invoice (id int PRIMARY KEY);
CREATE TABLE t_watermark (id int);
INSERT INTO t_watermark VALUES (0);
WITH x AS (UPDATE t_watermark SET id = id + 1 RETURNING *)
	INSERT INTO t_invoice
	SELECT * FROM x RETURNING *;
	
-- Watching VACUUM at work
CREATE TABLE t_test_vacuum (id int)
WITH (autovacuum_enabled = off);

INSERT INTO t_test_vacuum
SELECT * FROM  generate_series(1, 100000);

SELECT pg_size_pretty(pg_relation_size('t_test_vacuum'));
