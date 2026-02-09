select * from amazon_sales_cleaned
limit 10;

----Q1) Which product categories generate above-average total revenue?

WITH category_revenue AS (
    SELECT
        product_category,
        SUM(total_revenue) AS total_revenue
    FROM amazon_sales_cleaned
    GROUP BY product_category
)
SELECT
    product_category,
    total_revenue
FROM category_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM category_revenue);


-----Q2) Classify orders into discount levels and find total revenue for each level.

SELECT SUM(total_revenue) AS total_revenue,
    CASE
        WHEN discount_percent = 0 THEN 'No Discount'
        WHEN discount_percent BETWEEN 1 AND 20 THEN 'Low Discount'
        WHEN discount_percent BETWEEN 21 AND 40 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_bucket
FROM amazon_sales_cleaned
GROUP BY discount_bucket;



----Q3)Find the top 2 highest-revenue orders in each product category.

WITH cte AS (
    SELECT
        order_id,
        product_category,
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY total_revenue DESC) AS rn
    FROM amazon_sales_cleaned
)
SELECT *
FROM cte
WHERE rn <= 2;


-----Q4) Find regions where average order rating is above 3.5 and total revenue exceeds 50,000.
SELECT
    customer_region,
    AVG(rating) AS avg_rating,
    SUM(total_revenue) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY customer_region 
HAVING AVG(rating) >3.5
   AND SUM(total_revenue) > 50000;


-----Q5) For each customer region, identify the highest-revenue order and label whether it was a discounted or non-discounted order.

WITH cte1 AS (
    SELECT
        order_id,
        customer_region,
        total_revenue,
        discount_percent,
        ROW_NUMBER() OVER (PARTITION BY customer_region ORDER BY total_revenue DESC) AS rn
    FROM amazon_sales_cleaned
    )
    SELECT order_id,customer_region,total_revenue,
    CASE
        WHEN discount_percent > 0 THEN 'Discounted'
        ELSE 'No Discount'
    END AS discounts
FROM cte1
WHERE rn = 1;




0