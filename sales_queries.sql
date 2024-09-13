-- Create tables for reuse 
CREATE TEMPORARY TABLE top_5_customers_by_revenue (
    customer_name VARCHAR(50),
    contributed_revenue FLOAT
);
CREATE TEMPORARY TABLE top_5_markets_by_revenue (
    market_name VARCHAR(50),
    contributed_revenue FLOAT
);
CREATE TEMPORARY TABLE top_5_products_by_revenue (
    product_name VARCHAR(50),
    contributed_revenue FLOAT
);
CREATE TEMPORARY TABLE top_5_months_by_revenue (
    year VARCHAR(50),
    month VARCHAR(50),
    contributed_revenue FLOAT
);
CREATE TEMPORARY TABLE total_sales_per_product_by_customers_in_top5customerbyrevenue (
    customer_name VARCHAR(50),
    product_code VARCHAR(50),
    total_sales FLOAT
);
CREATE TEMPORARY TABLE for_refer (
    customer_name VARCHAR(50),
    total_sales VARCHAR(50)
);



-- Insert all data needed into corresponding tables
insert into top_5_markets_by_revenue (market_name, contributed_revenue)
select sales.markets.markets_name, 
		round(sum((sales_qty*sales_amount)),2) as total_revenue_by_market
from sales.transactions
join sales.markets
on sales.transactions.market_code = sales.markets.markets_code
group by market_code
order by total_revenue_by_market desc 
limit 5;


insert into top_5_customers_by_revenue (customer_name, contributed_revenue)
select custmer_name, 
		round(sum((sales_qty*sales_amount)),2) as total_revenue_per_customer
from sales.transactions
join sales.customers
using(customer_code)
group by customer_code
order by total_revenue_per_customer desc
limit 5;


insert into top_5_products_by_revenue (product_name, contributed_revenue)
select product_code, 
		round(sum((sales_qty*sales_amount)),2) as total_revenue_per_product
from sales.transactions
group by product_code
order by total_revenue_per_product desc
limit 5;


insert into top_5_months_by_revenue (year, month, contributed_revenue)
SELECT year, 
		month_name,
        round(sum((sales_qty*sales_amount)),2) as total_revenue_per_month
from sales.transactions
join sales.date
on sales.transactions.order_date = sales.date.date
group by year,month_name 
order by total_revenue_per_month desc
limit 5;



-- Counted the customers who frequently made purchases over the years
select count(distinct customer_code) as prequently_buying_customers
from
	(SELECT t.customer_code, 
		   d.year
	FROM sales.transactions t
	JOIN sales.date d 
	ON t.order_date = d.date  
	GROUP BY t.customer_code, d.year) as customer_prequently_buying;



-- Total sales per product by customers in top5 customers by revenue
insert into total_sales_per_product_by_customers_in_top5customerbyrevenue(customer_name, product_code, total_sales)
select c.custmer_name as customer_name,
       t.product_code as product_code,
       SUM(t.sales_qty) as total_sales_per_product_by_customers_in_top5customerbyrevenue
from sales.transactions t
join sales.customers c
on t.customer_code = c.customer_code
where c.custmer_name in (select customer_name from top_5_customers_by_revenue)
group by c.custmer_name, t.product_code
order by total_sales_per_product_by_customers_in_top5customerbyrevenue desc;

insert into for_refer (customer_name, total_sales)
select customer_name,
	max(total_sales) as total_sales
from total_sales_per_product_by_customers_in_top5customerbyrevenue
group by customer_name;



-- Most_prefered product by customers in the top 5 customers by revenue
select f.customer_name,
		t.product_code as most_sold_product,
        f.total_sales
from total_sales_per_product_by_customers_in_top5customerbyrevenue t 
join for_refer f 
using(total_sales);



--  number_of_products_sold
select product_code, 
		sum(sales_qty) as number_of_products_sold
from sales.transactions
group by product_code 
order by  sum(sales_qty) desc
limit 5;

 

-- avg_amount_of_the_product sort by desc or asc
select product_code, 
		avg(sales_amount) as avg_price_of_the_product
from sales.transactions
group by product_code 
order by  avg(sales_amount) asc
limit 5;










