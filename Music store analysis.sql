Q1: who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1

Q2 : which countries have the most invoices?

select count(*) as c,billing_country from invoice
group by billing_country
order by c desc

Q3 : what are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3

Q4 : which city has the best customer? we would like to throw 
a promotional music festival in the city we made the most money.
write a query that returns one city that has the highest sum of invoice
totals. return both the city name and sum of all invoice totals?

select sum(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc

Q5: who is the best customer? the customer who has spent the most 
money will be declared the best customer. write a query that returns 
the person who has spent the most money?

select 
c.customer_id,
c.first_name,
c.last_name,
sum(i.total)
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by sum(i.total) desc
limit 1


Q6 : write a query to return the email,first name,last
name,genre of all rock music listeners. return your list
ordered alphabetically by email starting with A?

select distinct cu.email,cu.first_name,cu.last_name
from customer cu
join invoice i on cu.customer_id = i.customer_id
join invoice_line ls on i.invoice_id = ls.invoice_id
where track_id in(
select 
track_id from track tr
join genre ge on tr.genre_id =ge.genre_id
where ge.name = 'Rock'
)
order by cu.email;

Q7: lets invite a artist who have written the most rock music in our dataset.
write a query that returns artist name and total track count
of top 10 rock bands?

select 
ar.artist_id,
ar.name,
count(ar.artist_id) as number_of_songs
from track tr
join album al on al.album_id = tr.album_id
join artist ar on al.artist_id = ar.artist_id
join genre ge on ge.genre_id = tr.genre_id
where ge.name = 'Rock'
group by ar.artist_id
order by number_of_songs desc
limit 10;

Q8: return all track names that have song length longer than
average song length. return name and millisecond for each
track. order by song length with longest songs listed first?

select name, milliseconds 
from track 
where milliseconds > (
select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;


Q9: find how much amount spent by each customers on artists?
write a query to return customer name, artist name, total spent?

WITH best_selling_artist as
(	
	select ar.artist_id as artist_id, ar.name as artist_name,
	sum(il.unit_price * il.quantity) as total_sales
	from invoice_line il
	join track tr on tr.track_id = il.track_id
	join album al on tr.album_id = al.album_id
	join artist ar on al.album_id = ar.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price * il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track tr on tr.track_id = il.track_id
join album al on al.album_id = tr.album_id
join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc;

Q10: find out most popular genre for each country. we determine most popular
genre as the genre with highest amount of purchases. write query that returns
each country along with top genre. for countries where maximum number of purchases
is shared return all genres?

with popular_genre as
(
	select count(invoice_line.quantity) as purchases,
	customer.country,
	genre.name,
	genre.genre_id,
	row_number() over (partition by customer.country order by count(invoice_line.quantity)desc) as rownum
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
	
)
select * from popular_genre where rownum <= 1

Q11 : query that determines the customer that has spent the most 
on music for each country. write query that returns the country along
with top customer and how much they spent. for countries where top amount
spent is shared, provide all customers this amount?

Method 1:

with customer_with_country as (
	select cu.customer_id,cu.first_name,cu.last_name,
	invoice.billing_country,sum(invoice.total) as total_spending,
	row_number() over (partition by invoice.billing_country order by sum(invoice.total)desc) as rownum
	from invoice
	join customer cu on cu.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc)
select * from customer_with_country where rownum = 1
	

Method 2:
with recursive 
	customer_with_country as (
		select cu.customer_id,cu.first_name,cu.last_name,
		i.billing_country,sum(i.total) as total_spending
		from invoice i
		join customer cu on cu.customer_id = i.customer_id
		group by 1,2,3,4
		order by 2,3 desc),
		
	country_max_spending as(
		select billing_country,max(total_spending) as max_spending
		from customer_with_country
		group by billing_country)
		
select cc.billing_country, cc.total_spending, cc.first_name,
cc.last_name,cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;





