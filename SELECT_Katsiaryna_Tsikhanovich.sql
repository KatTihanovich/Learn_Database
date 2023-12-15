--1.1
SELECT s.store_id, s.staff_id, CONCAT(s.first_name, ' ', s.last_name) as employee_name, SUM(p.amount) as total
FROM staff s
JOIN payment p USING (staff_id)
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY s.store_id, s.staff_id, employee_name
HAVING SUM(p.amount) = (
    SELECT MAX(sum_amount)
    FROM (
        SELECT s.store_id, s.staff_id, SUM(p.amount) as sum_amount
        FROM staff s
        JOIN payment p ON s.staff_id = p.staff_id
        WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
        GROUP BY s.store_id, s.staff_id
    ) res
    WHERE s.store_id = res.store_id
    GROUP BY res.store_id)
ORDER BY s.store_id;



    
--1.2
SELECT DISTINCT s.staff_id, s.first_name, s.last_name, SUM(p.amount) OVER (PARTITION BY s.staff_id) AS total
FROM staff AS s
JOIN payment AS p ON s.staff_id = p.staff_id
where EXTRACT(YEAR FROM p.payment_date) = 2017
    AND s.staff_id IN (
        SELECT staff_id
        FROM ( SELECT staff_id, ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY SUM(amount) DESC) AS rn
                FROM payment
                JOIN staff USING (staff_id)
                where EXTRACT(YEAR FROM payment_date) = 2017
                GROUP BY store_id, staff_id
            ) AS ranked_data
        WHERE rn = 1
    )
ORDER BY total DESC;


--2.1
SELECT f.film_id, f.title, film_rentals.rental_count, f.rating
FROM film f
JOIN (
    SELECT i.film_id,SUM(rental_counts.cnt) as rental_count
    FROM inventory i
    JOIN (SELECT inventory_id, COUNT(inventory_id) as cnt
        FROM rental
        GROUP BY inventory_id
    ) AS rental_counts
    ON i.inventory_id = rental_counts.inventory_id
    GROUP BY i.film_id
) AS film_rentals
ON f.film_id = film_rentals.film_id
ORDER BY film_rentals.rental_count DESC, f.film_id
LIMIT 5;


--2.2
SELECT f.film_id, f.title, CASE WHEN rental_counts.film_count IS NULL THEN 0 ELSE rental_counts.film_count END AS film_count, f.rating
FROM film f
LEFT JOIN (
    SELECT i.film_id, COUNT(r.inventory_id) AS film_count
    FROM inventory i
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY i.film_id
) AS rental_counts
ON f.film_id = rental_counts.film_id
ORDER BY film_count DESC, f.film_id
LIMIT 5;

--3.1
WITH actor_films AS (SELECT a.actor_id, a.first_name || ' ' || a.last_name AS actor_name, f.title, f.release_year - LAG(f.release_year) OVER (PARTITION BY a.actor_id ORDER BY f.release_year) AS years_between_films
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id = f.film_id
)

select actor_id, actor_name, title, years_between_films
FROM actor_films
WHERE
    years_between_films IS NOT NULL
    AND years_between_films > (SELECT AVG(years_between_films) FROM actor_films WHERE years_between_films IS NOT NULL)
ORDER BY
    years_between_films DESC;
   
--3.2
SELECT a.actor_id,a.first_name,a.last_name,MAX(film.release_year) AS last_movie_year
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film ON fa.film_id = f.film_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name
HAVING MAX(film.release_year) < EXTRACT(YEAR FROM CURRENT_DATE) - 4;


















--3.2


