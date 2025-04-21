-- 1. answer 
 SELECT s.customer_id,sum(m.price)
FROM dannys_diner.menu as m
inner join dannys_diner.sales as s
on m.product_id = s.product_id
group by customer_id
order by customer_id;



-- 2. answer

SELECT customer_id,
count(EXTRACT(DAY FROM order_date)) as total_days

FROM dannys_diner.sales
group by customer_id
order by customer_id;

-- 3. answer

 with cte as(SELECT 
distinct customer_id,
first_value(product_id) over(partition by customer_id order by order_date) as first_product_purchased
from dannys_diner.sales )

select c.customer_id,
m.product_name
from cte c


-- 4. answer
 with cte as(select product_id,
count(product_id) as times_buy           
from dannys_diner.sales
group by product_id
order by product_id)

select  (c.times_buy),
 m.product_name
from cte c
join dannys_diner.menu m
on c.product_id=m.product_id
order by c.times_buy desc
limit 1;

-- 5 answer
with product_counts as (SELECT
    customer_id,
    product_id,
    COUNT(*) AS times_bought
  FROM dannys_diner.sales
  GROUP BY customer_id, product_id
 ),
  
  ranked_products as
  (select *,
  rank() over(partition by customer_id order by times_bought desc) as ranking
  from product_counts)
  
  select rp.* , m.product_name
  
  from ranked_products rp
  join dannys_diner.menu m
  on rp.product_id=m.product_id
  where ranking =1
  order by customer_id;
  



-- 6 answer
with member_sales_cte as(
SELECT s.customer_id, m.join_date, s.order_date,   s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS ranking
      FROM sales AS s
      JOIN members AS m
      ON s.customer_id = m.customer_id
     WHERE s.order_date >= m.join_date)
     
 SELECT ms.customer_id,
 m2.product_name
 from member_sales_cte AS ms
 join dannys_diner.menu AS m2
 on ms.product_id = m2.product_id
 where ranking =1;

-- 7 answer
WITH prior_purchase_cte AS(
SELECT s.customer_id, m.join_date, s.order_date,   s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date desc) AS ranking
      FROM sales AS s
      JOIN members AS m
      ON s.customer_id = m.customer_id
     WHERE s.order_date < m.join_date)
     
 SELECT 
 ms.customer_id,ms.product_id,m2.product_name
 from prior_purchase_cte AS ms
 join menu m2 on
 ms.product_id = m2.product_id
 where ranking = 1;



--8 answer

WITH prior_purchase_cte AS(
SELECT s.customer_id, m.join_date, s.order_date,   s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date desc) AS ranking
      FROM sales AS s
      JOIN members AS m
      ON s.customer_id = m.customer_id
     WHERE s.order_date < m.join_date)
 

 SELECT 
 ms.customer_id,count(distict ms.product_id) as total_items,sum(m2.price) as amount_spent
 from prior_purchase_cte AS ms
 join menu m2 on
 ms.product_id = m2.product_id
 group by customer_id
 order by customer_id;

-- OR
SELECT s.customer_id,
  COUNT(DISTINCT s.product_id) AS unique_menu_item, 
  SUM(mm.price) AS total_sales
  FROM sales AS s
  JOIN members AS m
  ON s.customer_id = m.customer_id
  JOIN menu AS mm
  ON s.product_id = mm.product_id
  WHERE s.order_date < m.join_date
  GROUP BY s.customer_id;
 
 -- 9 answer
  with price_points AS (
    SELECT *, 
 CASE
  WHEN product_id = 1 THEN price * 20
  ELSE price * 10
  END AS points
 FROM menu
 )
  SELECT s.customer_id, SUM(p.points) AS total_points
 FROM price_points AS p
 JOIN sales AS s
 ON p.product_id = s.product_id
 GROUP BY s.customer_id;


-- 10 answer
select 
s.customer_id,
sum(case when s.order_date between m.join_date and m.join_date + interval '6 days' 
then me.price*20
else 
    case when me.product_name='sushi' then me.price*20
    else me.price*10
    end
   end)
    AS points
from sales s
join menu me on s.product_id= me.product_id
join members m on s.customer_id= m.customer_id
where s.order_date <='2021-01-31'
and s.customer_id in ('A','B')
group by s.customer_id;



