-- Count tables in BikeStores database
select count(*) as table_count
from information_schema.tables
where table_catalog = 'BikeStores';

-- Count rows in each table of BikeStores database
select 
	t.name as TABLE_NAME
	,p.rows as TABLE_ROWS
from sys.tables t
join sys.partitions p
on t.object_id = p.object_id;

-- Get a list of customers with phone numbers
select 
	first_name + ' ' + last_name as customer_name
	,phone as phone_number
from sales.customers
where phone is not null;

-- Get a list of customers whose first_name starts with the letter A
select 
	first_name + ' ' + last_name as customer_name
from sales.customers
where first_name like 'A%';

-- Sales Statistics by Product
select 
	p.product_name
	,sum(oi.quantity) as sold_quantities
	,sum(oi.quantity*oi.list_price*(1-oi.discount)) as sold_revenue
from sales.order_items oi
join production.products p
on oi.product_id = p.product_id
group by 
	p.product_id
	,p.product_name
order by sum(oi.quantity) desc;

-- Number of orders of each store
select
	s.store_name
	,count(*) as number_of_orders
from sales.orders o
join sales.stores s
on o.store_id = s.store_id
group by 
	s.store_id
	,s.store_name
order by count(*) desc;

-- Sales statistics of each store
select 
	s.store_name
	,sum(oi.quantity) as sold_quantities
	,sum(oi.quantity*oi.list_price*(1-oi.discount)) as sold_revenue
from sales.order_items oi
join sales.orders o
on oi.order_id= o.order_id
join sales.stores s
on s.store_id = o.store_id
group by 
	s.store_id
	,s.store_name
order by sum(oi.quantity) desc;

-- Sales statistics by employee
select
	st.first_name +' '+st.last_name  as staff_name
	,sum(oi.quantity) as sold_quantities
	,sum(oi.quantity*oi.list_price*(1-oi.discount)) as sold_revenue
from sales.order_items oi
join sales.orders o
on o.order_id = oi.order_id
join sales.staffs st
on o.staff_id = o.staff_id
group by 
	st.staff_id
	,st.first_name +' '+st.last_name 
order by sum(oi.quantity) desc;

-- Inventory by product
select 
	p.product_name
	,sum(s.quantity) as total_quantity
from production.products p
join production.stocks s
on s.product_id = p.product_id
group by 
	p.product_id
	,p.product_name
order by sum(s.quantity) desc;

-- List of products that have not been sold yet
select * 
from production.products p
where not exists (select 1 from sales.order_items oi where p.product_id = oi.product_id);

-- List of customers who have never purchased anything
select * 
from sales.customers c
where not exists (select 1 from sales.orders o where c.customer_id = o.customer_id);

-- List of customers who have purchased 10 or more orders
select 
	c.first_name +' ' +c.last_name as customer_name
	,count(*) as purchased_times
from sales.customers c
join sales.orders o
on o.customer_id = c.customer_id
group by 
	o.customer_id
	,c.first_name +' ' +c.last_name
having count(*) > 10;

-- Sales statistics of each store by year
select
	s.store_name
	,year(o.order_date) as year
	,sum(oi.quantity*oi.list_price*(1-oi.discount)) as total_sales
from sales.order_items oi
join sales.orders o 
on oi.order_id = o.order_id
join sales.stores s
on o.store_id = s.store_id
group by 
	s.store_id
	,s.store_name
	,year(o.order_date)
order by 
	year(o.order_date) desc
	,sum(oi.quantity*oi.list_price*(1-oi.discount)) desc;

-- Extract different domain email data from customer data
select
	c.first_name+' '+c.last_name as customer_name
	,c.email
	,substring(c.email, charindex('@', c.email) , len(c.email)) as domain
from sales.customers c;

-- Write a function to calculate the sum from 1 to n
create function sum_from_1_to_n (@n int)
returns int
as 
begin
	declare @result int = 0;
	declare @count int = 1;

	while @count <= @n 
	begin
		set @result = @result + @count;
		set @count = @count + 1;
	end;

	return @result;
end;

-- Write a function to calculate the price of an order
create function total_price_per_order
(
    @orderID nvarchar(50)  -- Declare the input parameter correctly
)
returns nvarchar(50)
as
begin
    declare @price float;
    declare @result nvarchar(50);

    -- Check if the order_id exists
    if NOT EXISTS (select 1 from sales.order_items oi where oi.order_id = @orderID)
    begin 
        set @result = 'No order_id found';
    end
    else
    begin
        -- Calculate the total price without using GROUP BY
        select @price = sum(oi.quantity * oi.list_price * (1 - oi.discount))
        from sales.order_items oi
        where oi.order_id = @orderID;

        -- Set the result as the calculated price or 0 if NULL
        set @result = cast(isnull(@price, 0) as nvarchar(50));
    end
    
    return @result;  -- Return the result
end;

