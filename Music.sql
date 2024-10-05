-- Easy Level

-- Q1: Who is the senior most employee  based on job title?
select * from employee
Order by levels desc
limit 1


-- Q2: Which countries have the most invoices?
select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc


-- Q3: What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3


-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
select sum(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc
limit 1


-- Q5: Who is the best customer? The customer who has spent the most money will be decared the best customer.
-- Write a query that returns the person who has the most money.
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1



-- Moderate Level

-- Q1: Write query to return the email, first name, last name & Genre of all rock music listeners.  Return your list ordered 
-- alphabetically by email starting with A
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name = 'Rock'
	)
order by email;



-- Q2: Let's invite the artists who have written the most rocks music in our dataset. Write a query that returns the 
-- Artist name and total track count of the top 10 rock bands.
select  artist.name, count(artist.artist_id) as number_of_rock_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_rock_songs desc
limit 10;



-- Q3: Return all the track names that have a song length longer than the average song length, 
-- Return the name and milliseconds for each track. Order by the song length with the longest songs listed first

select name, milliseconds 
from track
where milliseconds >(
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc;




-- Advance Level

-- Q1: find how much amount spent by each customer on artists? write a query to return customer name, 
-- artist name and total spent.
WITH best_selling_artist AS (
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(li.unit_price*li.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line li on li.invoice_id = i.invoice_id
join track t on t.track_id = li.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;



-- Q2: We want to find out the most popular music genre for each country. we determine the most popular genre 
-- as the genre with the highest amount of purchases. write a query that returns each country along with the top genre. 
-- for countries where the maximum number of purchases is shared return all genres.
WITH popular_genre AS 
(
	select sum(invoice_line.quantity) as purchases, customer.country, genre.genre_id, genre.name,
		row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo<= 1



-- Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.
with customer_with_country as(
	select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
		row_number() over(partition by billing_country order by sum(total) desc) as RowNo
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc
)
select * from customer_with_country where RowNo <= 1




	