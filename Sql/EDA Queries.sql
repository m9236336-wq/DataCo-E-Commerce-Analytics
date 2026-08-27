-- 1. OVERALL BUSINESS PERFORMANCE
-- Q1- how much revenue, profit, and how many orders did the business generate?

select 
	round(sum(sales), 2) as total_revenue,
	round(sum(order_profit_per_order), 2) AS total_profit,
	count(distinct(order_id)) as total_orders 
	from order_items;


-- Q2- how has revenue, profit and orders changed over time?;

select 
o.order_year,
o.order_month, 
count(distinct(o.order_id)) orders,
round(sum(oi.sales), 2) as revenue,
round(sum(oi.order_profit_per_order), 2) as profit,
round(sum(oi.order_profit_per_order), 2) / round(sum(oi.sales), 2) * 100 as profit_margin,
round(sum(oi.sales)  / count(DISTINCT o.order_id), 2) AS AOV
from orders o 
join order_items oi on o.order_id = oi.order_id
group by o.order_year, o.order_month
order by o.order_year, o.order_month ;



-- Q3- which countries generate the most revenue, profit and orders?

select 
o.order_country,
count(distinct(o.order_id)) as orders,
round(sum(oi.sales), 2) as total_revenue,
round(sum(oi.order_profit_per_order), 2) as total_profit
from orders o 
join order_items oi on o.order_id = oi.order_id 
group by o.order_country
order by total_revenue desc, total_profit desc;




-- 2. PRODUCT ANALYSIS

-- Q1- Which products generate the most revenue?

select
p.product_name,
round(sum(oi.sales), 2) as total_revenue
from products p 
join order_items oi on p.product_card_id = oi.product_card_id
group by p.product_card_id, p.product_name
order by total_revenue desc
;

-- Q2- which products generate the most profit?

select
p.product_name,
round(sum(oi.order_profit_per_order), 2) as total_profit
from products p
join order_items oi on p.product_card_id = oi.product_card_id
group by p.product_card_id, p.product_name
order by total_profit desc ;


-- Q3- which products sell the most units?

select 
p.product_name,
sum(oi.order_item_quantity) as total_quantity_sold
from products p 
join order_items oi on p.product_card_id = oi.product_card_id
group by p.product_card_id, p.product_name
order by total_quantity_sold desc;




-- Q4- which product categories generate the most revenue and profit?

select
p.category_name,
round(sum(oi.sales), 2) as total_revenue,
round(sum(oi.order_profit_per_order), 2) as total_profit,
sum(oi.order_item_quantity) as total_quantity_sold,
round(sum(oi.order_profit_per_order) / sum(oi.sales) * 100, 2) AS profit_margin
from products p 
join order_items oi on p.product_card_id = oi.product_card_id
group by p.product_category_id, p.category_name
order by total_revenue desc, total_profit desc;




-- Q5- which products have high revenue but low profitability?
select 
p.product_name,
round(sum(oi.order_profit_per_order), 2) as total_profit,
round(sum(oi.sales), 2) as total_revenue
from products p 
join order_items oi on p.product_card_id = oi.product_card_id
group by p.product_card_id, p.product_name
order by total_profit, total_revenue desc;




-- 3.  CUSTOMER ANALYSIS

-- Q1- which customer segments generate the most profit and revenue?

select 
c.customer_segment,
round(sum(oi.order_profit_per_order), 2) as profit,
round(sum(oi.sales), 2) as revenue,
round(sum(oi.sales)  / count(DISTINCT o.order_id), 2) AS AOV,
round(sum(oi.order_profit_per_order) / sum(oi.sales) * 100, 2) as profit_margin
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_segment
order by profit desc, revenue desc;



-- Q2- who are the top 10 customers by revenue?
select 
c.customer_id,
c.customer_fullname,
sum(oi.sales) as sales 
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_id, c.customer_fullname
order by sales desc
limit 10;



-- 4. SHIPPING AND DELIVERY PERFORMANCE

-- Q1- what is the overall percentage of each delivery status?

SELECT
    delivery_status,
    count(*) AS orders,
    round(count(*) / (select count(*) from order_items) * 100, 2) as percentage
from  order_processing
group by delivery_status;



-- Q2- what is the average profit and revenue for each shipping mode?

select
op.shipping_mode,
round(avg(oi.order_profit_per_order), 2) as average_profit_per_order
from order_processing op 
join order_items oi on op.order_id = oi.order_id
group by op.shipping_mode;



-- Q3- what is the percentage of late deliveries in each shipping mode
select
shipping_mode,
count(order_id) as orders,
round(count(*) / (select count(*) from orders) * 100, 2) as percentage
from order_processing
where delivery_status = 'Late delivery'
group by shipping_mode, delivery_status ;


-- Q4- how has the late delivery rate changed over time?

select 
o.order_year,
o.order_month,
count(o.order_id) AS total_orders,
sum(case when op.delivery_status = 'Late delivery' then 1 else 0 end) as number_of_late_orders,
round(sum(case when op.delivery_status = 'Late delivery' then 1 else 0 end) / count(o.order_id) *100, 2) as late_delivery_percentage
from orders o
join order_processing op on o.order_id = op.order_id
group by o.order_year,o.order_month
order by o.order_year, o.order_month 
;


-- Q5- which countries have the highest late delivery rates?

select 
o.order_country,
count(op.order_id) as total_orders,
sum(case when op.delivery_status = 'Late delivery' then 1 else 0 end) as number_of_late_orders,
round(sum(case when op.delivery_status = 'Late delivery' then 1 else 0 end) / count(*) * 100, 2) as late_delivery_percentage
from orders o
join order_processing op on o.order_id = op.order_id
group by o.order_country
order by late_delivery_percentage desc;


-- 5. GEOGRAPHIC PERFORMANCE

-- Q1- Which countries generate the most revenue and profit?

select 
o.order_country,
round(sum(oi.sales), 2) as revenue,
round(sum(oi.order_profit_per_order), 2) as profit,
round(sum(oi.order_profit_per_order) / sum(oi.sales) * 100, 2) as profit_margin
from orders o 
join order_items oi on o.order_id = oi.order_id
group by o.order_country 
order by revenue desc;



-- 6. SHIPPING AND ORDER PERFORMANCE

-- Q1. which shipping modes generate the most revenue and profit?

select 
op.shipping_mode,
round(sum(oi.sales), 2) as revenue,
round(sum(oi.order_profit_per_order), 2) as profit,
round(sum(oi.order_profit_per_order) / sum(oi.sales) * 100, 2) as profit_margin
from order_processing op
join order_items oi on op.order_id = oi.order_id
group by op.shipping_mode
order by revenue desc;

select
shipping_mode,
ROUND(AVG(days_for_shipping_real), 2) AS avg_shipping_days
from order_processing
group by shipping_mode
order by avg_shipping_days;



