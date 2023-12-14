DELETE FROM inventory 
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Green Book');

DELETE FROM rental
WHERE inventory_id IN (
    SELECT i.inventory_id
    FROM inventory i
    JOIN film f ON i.film_id = f.film_id
    WHERE f.title = 'Green Book'
);


DELETE FROM film_actor fa 
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Green Book');

DELETE FROM film 
WHERE title = 'Green Book';

DELETE FROM payment
WHERE customer_id = (SELECT customer_id FROM customer WHERE last_name = 'Tsikhanovich');

DELETE FROM rental
WHERE customer_id = (SELECT customer_id FROM customer WHERE last_name = 'Tsikhanovich');