--QUESTION SET1
--Q1: Who is the senior most employee based on job title?
--Ans:

select * from employee
order by levels desc
limit 1

--Q2: Which countries have the most invoices?
--Ans:

select COUNT(*) as c, billing_country
from invoice
group by billing_country
order by c desc

--Q3: What are top 3 values of total invoice?
--Ans:

select total from invoice
order by total desc
limit 3

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival 
--in the city we made the most money. Write a query that returns one city that has the highest 
--sum of invoice totals. Return both the city name & sum of all invoice totals
--Ans:

Select SUM(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc

--Q5: Who is the best customer? The customer who has spent the most money will be declared 
--the best customer. Write a query that returns the person who has spent the most money?
--Ans:

select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total desc
limit 1

--QUESTION SET2

--Q1:Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A
--ANS:

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN  invoice on customer.customer_id = invoice.customer_id
JOIN invoice_lines on invoice.invoice_id = invoice_lines.invoice_id
WHERE track_id IN(
      SELECT track_id FROM tracks
	  JOIN genre on tracks.genre_id = genre.genre_id
	  WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--Let's invite the artists who have written the most rock music in our dataset. Write a query 
--that returns the Artist name and total track count of the top 10 rock bands
--ANS:

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM tracks
join album on album.album_id = tracks.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = tracks.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

--Return all the track names that have a song length longer than the average song length. Return 
--the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
--ANS:

select name,milliseconds
from tracks
WHERE milliseconds > (
      select avg(milliseconds) as avg_track_length
	  from tracks
)
order by milliseconds desc;


--QUESTION SET3

--Q1:Find how much amount spent by each customer on artists? Write a query to return customer name,
--artist name and total spent
--ANS:

WITH best_selling_artist AS (
     select artist.artist_id AS artist_id, artist.name AS artist_name,
	 SUM(invoice_lines.unit_price*invoice_lines.quantity) AS total_sales
	 from invoice_lines
	 join tracks on tracks.track_id = invoice_lines.track_id
	 join album on album.album_id = tracks.album_id
	 join artist on artist.artist_id = album.artist_id
	 group by 1
	 order by 3 desc
	 limit 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
join customer c on c.customer_id = i.customer_id
join invoice_lines il on il.invoice_id = i.invoice_id
join tracks t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
Join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

--Q2:We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with 
--the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres
--ANS:

WITH popular_genre AS 
(
    SELECT COUNT(invoice_lines.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_lines.quantity) DESC) AS RowNo 
    FROM invoice_lines 
	JOIN invoice ON invoice.invoice_id = invoice_lines.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN tracks ON tracks.track_id = invoice_lines.track_id
	JOIN genre ON genre.genre_id = tracks.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


--Q3:Write a query that determines the customer that has spent the most on music for each country. Write a query that returns
--the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide
--all customers who spent this amount
--ANS:

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1




