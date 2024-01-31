--1
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT name AS category,
    COALESCE(sum(amount), 0::numeric) AS revenue
   FROM category 
     JOIN film_category USING (category_id)
     JOIN film USING (film_id)
     LEFT JOIN inventory USING (film_id)
     LEFT JOIN rental USING (inventory_id)
     LEFT JOIN payment USING (rental_id)
  WHERE EXTRACT(year FROM CURRENT_DATE) = EXTRACT(year FROM payment_date) AND EXTRACT(quarter FROM CURRENT_DATE) = EXTRACT(quarter FROM payment_date)
  GROUP BY name
  ORDER BY (sum(amount)) ASC;

 --2
CREATE FUNCTION get_sales_revenue_by_category_qtr(qtr DATE)
RETURNS TABLE (category VARCHAR, revenue NUMERIC)
AS $$
BEGIN
  RETURN QUERY
  SELECT name AS category, COALESCE(sum(amount), 0::numeric) AS revenue
  FROM category 
     JOIN film_category USING (category_id)
     JOIN film USING (film_id)
     LEFT JOIN inventory USING (film_id)
     LEFT JOIN rental USING (inventory_id)
     LEFT JOIN payment USING (rental_id)
  WHERE EXTRACT(year FROM current_quarter) = EXTRACT(year FROM p.payment_date) AND EXTRACT(quarter FROM current_quarter) = EXTRACT(quarter FROM p.payment_date)
  GROUP BY name
  ORDER BY (sum(amount)) ASC;
END;
$$ LANGUAGE plpgsql;

--3
CREATE OR REPLACE PROCEDURE new_movie(movie_title VARCHAR DEFAULT 'Lord of the Trees')
LANGUAGE plpgsql
AS $$
DECLARE
    s_language_id INT;
    new_film_id INT;
BEGIN
    SELECT language_id INTO s_language_id
    FROM language
    WHERE name = 'Klingon';
    IF s_language_id IS NULL THEN
        RAISE EXCEPTION 'Language "Klingon" does not exist in the language table.';
    END IF;
    SELECT COALESCE(MAX(film_id), 0) + 1 INTO new_film_id
    FROM film;
    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), s_language_id);
END;
$$

CALL new_movie();

 