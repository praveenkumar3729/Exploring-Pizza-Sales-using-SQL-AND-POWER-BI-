create database pizza_sales;

use pizza_sales;

create table orders (
	order_id int primary key,
    date text,
    time text
    );
    
    load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
    into table orders
    fields terminated by ',' optionally enclosed by '"'
    lines terminated by '\n'
    ignore 1 lines;
    
create table order_details (
	order_details int primary key,
    order_id int,
    pizza_id text,
    quantity int 
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
into table order_details
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

select * from orders
select * from order_details
select * from pizzas
select * from pizza_types
    
create view pizza_details as
select p.pizza_id,p.pizza_type_id,pt.name,pt.category,p.size,p.price,pt.ingredients
from pizzas p
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id

select * from pizza_details

alter table orders
modify date date;

alter table orders
modify time time;

-- total revenue
select round(sum(od.quantity * p.price),2) as total_revenue
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id;

-- total no.of pizzas sold
select sum(od.quantity) as pizza_sold
from order_details od;


-- total orders
select count(distinct(order_id)) as total_orders
from order_details;


-- average order value 
select sum(od.quantity *p.price) / count(distinct(od.order_id)) as avg_order_value
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id;


-- average no.of pizza per order
select round(sum(od.quantity) / count(distinct(od.order_id)),0) as avg_no_pizza_per_order
from order_details od;

-- total revenue and no of orders per category
select p.category,sum(od.quantity *p.price) as total_revenue,count(distinct(od.order_id)) as total_orders
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.category

-- total revenue and numbers of orders per size
select p.size,sum(od.quantity *p.price) as total_revenue,count(distinct(od.order_id)) as total_orders
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.size

-- hourly, daily and monthly trend in orders and revenue of pizza
select
	  case
		when hour(o.time)between 9 and 12 then 'Late Morning'
        when hour(o.time)between 12 and 15 then 'Lunch'
        when hour(o.time)between 15 and 18 then 'Mid Afternoon'
        when hour(o.time)between 18 and 21 then 'Dinner'
        when hour(o.time)between 21 and 23 then 'Late Night'
        else 'others'
        end as meal_time, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o on o.order_id = od.order_id
group by meal_time
order by total_orders desc;

-- weekdays
select dayname(o.date) as day_name, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on  o.order_id = od.order_id
group by dayname(o.date)
order by total_orders desc;

-- monthly wise trend
select monthname(o.date) as day_name, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on  o.order_id = od.order_id
group by monthname(o.date)
order by total_orders desc;

-- most ordered pizza 
select p.name, count(od.order_id) as count_pizzas
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name
order by count_pizzas desc
limit 1

-- most ordered pizza along with size
select p.name,p.size, count(od.order_id) as count_pizzas
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name,p.size
order by count_pizzas desc;

-- top 5 pizzas by revenue
select p.name, sum(od.quantity * p.price) as total_revenue
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name
order by total_revenue desc
limit 5

-- top pizzas by sale
select p.name, sum(od.quantity ) as pizzas_sold
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name
order by pizzas_sold desc
limit 5

-- pizza analysis
select name,price
from pizza_details
order by price desc

-- top used ingredients
select * from pizza_details

create temporary table numbers as (
	select 1 as n union all
    select 2 union all select 3 union all select 4 union all
    select 5 union all select 6 union all select 7 union all
    select 8 union all select 9 union all select 10 order_details
);

select ingredient, count(ingredient) as ingredient_count
from(
	  select substring_index(substring_index(ingredients, ',',n), ',',-1) as ingredient
      from order_details
      join pizza_details on pizza_details.pizza_id = order_details.pizza_id
      join numbers on char_length(ingredients) - char_length(replace(ingredients, ',','')) >=n-1
      ) as subquery
group by ingredient
order by ingredient_count desc


