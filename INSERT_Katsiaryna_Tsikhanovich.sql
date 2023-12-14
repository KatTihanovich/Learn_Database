INSERT INTO film (title, description, release_year, language_id, rental_duration, length, rating)
VALUES (
    'Green Book',
    'A story of an unlikely friendship between a black musician and a white driver during the era of segregation in the USA.',
    2018,
    1,
    2,  
    130,
    'PG-13'
    );

INSERT INTO actor (first_name, last_name)
VALUES
    ('Viggo', 'Mortensen'),
    ('Mahershala', 'Ali'),
    ('Linda', 'Cardellini');
    
INSERT INTO film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM actor a
JOIN film f ON f.title = 'Green Book' 
WHERE a.last_name = 'Mortensen';

INSERT INTO film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM actor a
JOIN film f ON f.title = 'Green Book' 
WHERE a.last_name = 'Ali';

INSERT INTO film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM actor a
JOIN film f ON f.title = 'Green Book' 
WHERE a.last_name = 'Cardellini';

INSERT INTO inventory (film_id, store_id)
SELECT f.film_id, 1
FROM film f
WHERE f.title = 'Green Book';
