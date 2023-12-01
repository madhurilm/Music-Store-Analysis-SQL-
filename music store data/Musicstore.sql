--Music store Analysis in SQL
--Problem statements:
---Q1.Who is the senior most employee based on job title? –

select Top 1 concat(first_name,last_name) as Name,title as Title,levels as Level from employee 
order by levels desc

--Q2: Which countries have the most Invoices?
select Top 5 count(*)as Count_invoice,billing_country from invoice 
group by billing_country 
order by 1 desc

--Q3: What are top 3 values of total invoice?
select * from invoice
select Top 3 round(total,2) as Total_Invoice from invoice 
order by total desc

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals

select Top 1 round(sum(total),2) as TotalInvoice, billing_city as City from invoice 
group by billing_city
order by 1 desc

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money

select Top 1 concat(c.first_name,c.last_name) as CustomerName, sum(i.total) as Total from customer c 
inner join
invoice i 
on
c.customer_id=i.customer_id
group by c.first_name,c.last_name
order by Total desc

--Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.

select  distinct c.email as Email,concat(c.first_name,c.last_name) as CustomerName  from customer c 
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
where il.track_id in 
(select track_id from track t 
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
)
order by c.email 

--Q7: Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands. 

select Top 10 art.name as ArtistName,count(art.artist_id)as TotalTrackcount from track t
join album a on a.album_id = t.album_id
join artist art on art.artist_id=a.artist_id 
join genre g on g.genre_id=t.genre_id 
where g.name like 'Rock' 
group by art.name
order by TotalTrackcount desc

-- Q8: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select name,milliseconds from track where milliseconds>
( select avg(milliseconds) from track)
order by milliseconds desc

--Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT  TOP 1 art.artist_id AS Artist_id, art.name AS Artist_name, SUM(il.unit_price*il.quantity) AS total_sales
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album a ON a.album_id = t.album_id
	JOIN artist art ON art.artist_id = a.artist_id
	GROUP BY Artist_id
	ORDER BY total_sales DESC
	
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(iln.unit_price*iln.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line iln ON iln.invoice_id = i.invoice_id
JOIN track t ON t.track_id = iln.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC

--Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres.
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country as country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY country, genre.name, genre.genre_id
	
)
SELECT * FROM popular_genre WHERE RowNo <= 1 ORDER BY purchases DESC

--11) Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount. 
with customer_withcountry as
(
select c.customer_id,c.first_name,c.last_name,i.billing_country as Country,round(sum(i.total),2) As Total_spending,
ROW_NUMBER() over(partition by i.billing_country order by sum(i.total) desc) as Row_num
from customer c  inner join invoice i on 
i.customer_id= c.customer_id 
group by c.customer_id,c.first_name,c.last_name,i.billing_country
)
SELECT * FROM customer_withcountry WHERE Row_num = 1 order by Country asc, Total_spending desc













 