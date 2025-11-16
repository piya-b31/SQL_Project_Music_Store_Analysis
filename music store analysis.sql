/* Q.1 WHO IS THE SENIOR MOST EMPLOYEE BASED ON JOB TITLE?*/
SELECT * FROM employee

SELECT first_name, last_name, title FROM employee
ORDER BY levels DESC 
LIMIT 1

----

/* Q2: Which countries have the most Invoices? */
SELECT * FROM invoice

SELECT billing_country, COUNT(*) as invoices
FROM invoice
GROUP BY 1
ORDER BY 2 DESC

----

/* Q3: What are top 3 values of total invoice? */
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

----

/* Q4: Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
SELECT * FROM invoice

SELECT billing_city, SUM(total) AS total_invoice
FROM invoice
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

----

/* Q5: Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the most money.*/
SELECT * FROM customer

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spending
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1
ORDER BY 4 DESC
LIMIT 1

----

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners.  Return your list ordered alphabetically by email starting with A. */

SELECT * FROM customer
SELECT * FROM genre
SELECT * FROM track

SELECT DISTINCT(c.email), c.first_name, c.last_name FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY 1

----

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/
SELECT ar.artist_id, ar.name, COUNT(*) FROM track t
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10

----

/* Q8: Return all the track names that have a song length longer than the average 
song length.  Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first. */

SELECT name, milliseconds FROM track
WHERE milliseconds > (
SELECT AVG(milliseconds) FROM track
)ORDER BY 2 DESC

----

/* Q9: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

----

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

----