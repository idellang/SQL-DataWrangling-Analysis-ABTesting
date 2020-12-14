-- how many users have ordered
SELECT COUNT(DISTINCT user_id) AS users_with_orders
FROM
  dsv1069.orders
  
--users who reordered the same item
SELECT 
  COUNT(DISTINCT user_id) AS users_who_reordered
FROM(
  SELECT 
    user_id,
    item_id, 
    item_name, 
    COUNT(line_item_id) AS times_user_ordered
  FROM 
    dsv1069.orders
  GROUP BY 
    user_id,
    item_id, 
    item_name
  )  user_level_orders
WHERE times_user_ordered > 1


--People who ordered more than once
SELECT 
  COUNT(DISTINCT user_id)
FROM (
  SELECT 
    user_id,
    COUNT(DISTINCT invoice_id) AS order_count
  FROM 
    dsv1069.orders
  GROUP BY    
    user_id
  ) AS user_level
WHERE order_count > 1


--orders per item
SELECT 
  item_id,
  COUNT(line_item_id) AS times_ordered
FROM 
  dsv1069.orders
GROUP BY item_id

--Do users order multiple things from same category?
SELECT
  item_category,
  AVG(times_category_ordered) AS avg_times_category_ordered
FROM (
  SELECT 
    user_id,
    --item_id,
    item_category,
    COUNT(DISTINCT line_item_id) AS times_category_ordered
  FROM 
    dsv1069.orders
  GROUP BY 
    user_id,
    item_category
  )  user_level
GROUP BY item_category  

--find average time between orders
SELECT 
  first_orders.user_id,
  date(first_orders.paid_at) AS first_order_date,
  date(second_orders.paid_at) AS second_order_date,
  (date(second_orders.paid_at) - date(first_orders.paid_at)) AS date_diff
FROM(
  SELECT 
    user_id,
    invoice_id,
    paid_at,
    DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ASC) AS order_num
  FROM 
    dsv1069.orders
  )  first_orders
JOIN 
  (
  SELECT 
    user_id,
    invoice_id,
    paid_at,
    DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ASC) AS order_num
  FROM 
    dsv1069.orders
  ) second_orders
ON first_orders.user_id = second_orders.user_id
WHERE
  first_orders.order_num = 1
AND 
  second_orders.order_num = 2
    