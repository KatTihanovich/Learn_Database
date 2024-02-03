--1
CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;

--2
GRANT SELECT ON TABLE customer TO rentaluser;
SET ROLE rentaluser;
SELECT * FROM customer;
RESET ROLE;

--3
CREATE GROUP rental WITH USER rentaluser;

--4
GRANT INSERT,SELECT,UPDATE ON TABLE rental TO rental;
GRANT USAGE, SELECT ON SEQUENCE rental_rental_id_seq TO rental;
SET ROLE rentaluser;
SHOW ROLE ;
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update) VALUES (CURRENT_DATE , 130, 452, CURRENT_DATE , 2, NOW());
UPDATE rental SET return_date = CURRENT_DATE  WHERE rental_id = 35;
RESET ROLE;

--5
REVOKE INSERT ON TABLE rental FROM rental;

SET ROLE rentaluser;
INSERT INTO rental(rental_date,inventory_id , customer_id, return_date,staff_id ,last_update) VALUES(CURRENT_DATE , 234, 567, CURRENT_DATE, 890, NOW());
RESET ROLE;

--6
CREATE OR REPLACE FUNCTION set_new_user_role()
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  new_customer_id int;
  new_username text;
BEGIN

  SELECT c.customer_id INTO new_customer_id
  FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
  JOIN payment p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name
  HAVING COUNT(DISTINCT r.rental_id) > 0 AND COUNT(DISTINCT p.payment_id) > 0
  LIMIT 1;

  SELECT CONCAT('client_', c.first_name, '_', c.last_name) INTO new_username
  FROM customer c
  WHERE c.customer_id = new_customer_id;
	
  new_username := LOWER(new_username);

  EXECUTE FORMAT('CREATE ROLE %I', new_username);

  EXECUTE FORMAT('GRANT CONNECT ON DATABASE dvdrental TO %I', new_username);
  EXECUTE FORMAT('GRANT SELECT ON TABLE rental TO %I', new_username);
  EXECUTE FORMAT('GRANT SELECT ON TABLE payment TO %I', new_username);
  ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
  ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

  EXECUTE FORMAT('CREATE POLICY new_user_policy_on_rental
  ON rental
  FOR SELECT
  TO %I
  USING (customer_id = %L)',new_username,new_customer_id);
  
  EXECUTE FORMAT('CREATE POLICY new_user_policy_on_payment
  ON payment
  FOR SELECT
  TO %I
  USING (customer_id = %L)',new_username,new_customer_id);

  EXECUTE 'SET ROLE ' || new_username;

  RETURN new_username;
END $$;

SELECT set_new_user_role();
SELECT * FROM rental;
SELECT * FROM payment;
RESET ROLE;