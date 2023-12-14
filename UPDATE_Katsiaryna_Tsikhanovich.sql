UPDATE film
SET
    rental_duration = 3,
    rental_rate = 9.99
WHERE title = 'Green Book';

UPDATE customer
SET
    first_name = 'Katsiaryna',
    last_name = 'Tsikhanovich',
    email = 'tsikhanovich.katsiaryna@student.ehu.lt',
    address_id = 8,
    active = 1
WHERE customer_id = (
    SELECT c.customer_id
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(DISTINCT r.rental_id) >= 10 AND COUNT(DISTINCT p.payment_id) >= 10
    LIMIT 1  
   );

UPDATE customer
SET create_date = CURRENT_DATE
WHERE last_name = 'Tsikhanovich';

