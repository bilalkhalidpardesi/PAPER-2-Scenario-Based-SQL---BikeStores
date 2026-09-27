/*
Task 1 — Build the Sales Detail Dataset (6 marks)
Management needs a detailed sales dataset for analysis. Return one row per order item containing:
order_id and order_date
customer full name
store name
staff full name
product name
category name
brand name
quantity, list_price, discount
calculated net_line_revenue
*/

select
o.order_id,
o.order_date,
c.first_name + ' ' + c.last_name as full_name,
ss.store_name,
s.first_name + ' ' + s.last_name as staff_full_name,
p.product_name,
cc.category_name,
b.brand_name,
oi.quantity * oi.list_price * (1-oi.discount) as Revenue
from sales.order_items as oi 
join sales.orders as o
on o.order_id = oi.order_id
join sales.customers as c
on c.customer_id = o.customer_id
join sales.staffs as s
on s.staff_id = o.staff_id
join sales.stores as ss
on ss.store_id = o.store_id 
join production.products as p
on p.product_id = oi.product_id
join production.categories as cc
on cc.category_id = p.category_id
join production.brands as b
on b.brand_id = p.brand_id;

/*
Task 2 — Store Performance Summary (5 marks)
Create a store-level performance report for completed orders showing:
store name
number of distinct orders
total units sold
total net revenue
average order value

Return one row per store and order the stores from highest to lowest total net revenue.
*/

SELECT
    s.store_name,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS Revenue,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount))
        / COUNT(DISTINCT o.order_id) AS average_order_value
FROM sales.stores AS s
JOIN sales.orders AS o
    ON s.store_id = o.store_id
JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY
    s.store_id,
    s.store_name
ORDER BY
    Revenue DESC;


/*Task 3 — High-Value Customers (5 marks)
Management wants to identify high-value customers. Return customers
whose total completed-order spending is greater than the
average total spending of customers who have completed orders.
*/

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(o.order_id) AS completed_order_count,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending
    FROM sales.customers c
    JOIN sales.orders o
        ON c.customer_id = o.customer_id
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    customer_id,
    first_name,
    last_name,
    completed_order_count,
    total_spending
FROM customer_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY total_spending DESC;


/*
Task 4 — Inventory Risk Report (5 marks)
Operations wants to identify inventory risk. Return products where the stock quantity is below 5 in at least one store.
Show product name, store name, current quantity, category name, and brand name.
Products with zero stock should appear first, followed by the lowest remaining quantities.
*/

SELECT
p.product_name,
s.store_name,
st.quantity,
c.category_name,
b.brand_name
FROM production.stocks st
JOIN production.products p
ON st.product_id = p.product_id
JOIN sales.stores s
ON st.store_id = s.store_id
JOIN production.categories c
ON p.category_id = c.category_id
JOIN production.brands b
ON p.brand_id = b.brand_id
WHERE st.quantity < 5
ORDER BY st.quantity ASC;

/*
Task 5 — Top Products Within Each Category (6 marks)
For each product category, identify the top 3 products by total net revenue from completed orders.
Return category name, product name, total units sold, total net revenue, and the product's position within its category.
Tied products must receive the same position and the next position should not contain gaps.
*/

WITH productrevenue AS (
SELECT
c.category_name,
p.product_name,
SUM(oi.quantity) AS total_units_sold,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
FROM sales.order_items oi
JOIN sales.orders o
ON oi.order_id = o.order_id
JOIN production.products p
ON oi.product_id = p.product_id
JOIN production.categories c
ON p.category_id = c.category_id
WHERE o.order_status = 4
GROUP BY
c.category_name,
p.product_name
),

rankedproducts AS (
SELECT
category_name,
product_name,
total_units_sold,
total_net_revenue,
DENSE_RANK() OVER (
PARTITION BY category_name
ORDER BY total_net_revenue DESC
) AS product_position
FROM productrevenue
)

SELECT
category_name,
product_name,
total_units_sold,
total_net_revenue,
product_position
FROM rankedproducts
WHERE product_position <= 3
ORDER BY
category_name,
product_position;
 
/*
Task 6 — Monthly Sales Trend (6 marks)
Create a monthly sales trend for completed orders.

For each calendar month return:
year
month
total net revenue
previous month's total net revenue
revenue change from the previous month
*/

WITH monthly_sales AS (
    SELECT
        YEAR(o.order_date) AS year,
        MONTH(o.order_date) AS month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM sales.orders o
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    year,
    month,
    total_net_revenue,
    LAG(total_net_revenue) OVER (
        ORDER BY year, month
    ) AS previous_month_revenue,
    total_net_revenue
        - LAG(total_net_revenue) OVER (
            ORDER BY year, month
        ) AS revenue_change
FROM monthly_sales
ORDER BY year, month;

/*
Task 7 — Reusable Reporting View (4 marks)
Create a view named sales.vw_customer_sales_summary that returns one row per customer and includes:
customer_id
customer full name
total number of completed orders
total units purchased
total net revenue
most recent completed order date
*/

create view sales.vw_customer_sales_summary
as
select
c.customer_id,
concat(c.first_name, ' ', c.last_name) as customer_full_name,
count(distinct case when o.order_status = 4 then o.order_id end) as total_completed_orders,
coalesce(sum(case when o.order_status = 4 then oi.quantity else 0 end), 0) as total_units_purchased,
coalesce(sum(case when o.order_status = 4 then oi.quantity * oi.list_price * (1 - oi.discount) else 0 end), 0) as total_net_revenue,
max(case when o.order_status = 4 then o.order_date end) as most_recent_completed_order_date
from sales.customers c
left join sales.orders o
on c.customer_id = o.customer_id
left join sales.order_items oi
on o.order_id = oi.order_id
group by
c.customer_id,
c.first_name,
c.last_name;
go


/*Task 9 — Store Sales Procedure (6 marks)
Create a stored procedure named sales.usp_store_sales_report with these input parameters:
@store_id
@start_date
@end_date

The procedure should return completed-order sales for the requested store and date range, grouped by product. Return product name, total units sold, and total net revenue, ordered by revenue descending.

Add appropriate error handling for invalid date ranges where @start_date is later than @end_date.
*/


create procedure sales.usp_store_sales_report
@store_id int,
@start_date date,
@end_date date
as
begin

if @start_date > @end_date
begin
throw 50001, 'Start date cannot be later than end date.', 1
end

select
p.product_name,
sum(oi.quantity) as total_units_sold,
sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_net_revenue
from sales.orders o
join sales.order_items oi
on o.order_id = oi.order_id
join production.products p
on oi.product_id = p.product_id
where o.store_id = @store_id
and o.order_status = 4
and o.order_date >= @start_date
and o.order_date <= @end_date
group by
p.product_name
order by
total_net_revenue desc

end
go

/*
Task 10 — Management Insight Query (3 marks)
Write one additional SQL query that you believe would provide useful insight to BikeStores management using at least three tables.

Below the query, add a SQL comment of no more than three lines explaining:
1. the business question,
2. what the result measures, and
3. why management should care about it.
*/

select
p.product_name,
b.brand_name,
sum(oi.quantity) as total_units_sold,
sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_net_revenue
from sales.order_items oi
join production.products p
on oi.product_id = p.product_id
join production.brands b
on p.brand_id = b.brand_id
join sales.orders o
on oi.order_id = o.order_id
where o.order_status = 4
group by
p.product_name,
b.brand_name
order by
total_net_revenue desc

-- business question: which products generate the most revenue?
-- result measures total units sold and net revenue for each product.
-- management can use this to identify high-revenue products.