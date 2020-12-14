--orders per day
SELECT 
  date(paid_at) AS day,
  COUNT(DISTINCT invoice_id) AS orders,
  COUNT(DISTINCT line_item_id) AS line_items
FROM 
  dsv1069.orders
GROUP BY
  date(paid_at)
  

--join to rollup
SELECT *
FROM 
  dsv1069.dates_rollup
LEFT OUTER JOIN 
  (
  SELECT 
    date(paid_at) AS day,
    COUNT(DISTINCT invoice_id) AS orders,
    COUNT(DISTINCT line_item_id) AS line_items
  FROM 
    dsv1069.orders
  GROUP BY
    date(paid_at)
  ) daily_orders  
ON 
  daily_orders.day = dates_rollup.date
  
 --Clean the data
SELECT 
  r.date, 
  COALESCE(SUM(orders),0) AS orders,
  COALESCE(SUM(line_items),0) AS items_ordered
FROM 
  dsv1069.dates_rollup r
LEFT OUTER JOIN 
  (
  SELECT 
    date(paid_at) AS day,
    COUNT(DISTINCT invoice_id) AS orders,
    COUNT(DISTINCT line_item_id) AS line_items
  FROM 
    dsv1069.orders
  GROUP BY
    date(paid_at)
  ) daily_orders  
ON 
  daily_orders.day = r.date
GROUP BY
  r.date
  
 
 
--7 day average
-- COUNT invoice id and item per day 
-- JOIN with rollup date. the date must be between an interval and then you group by the date. 
-- you will also have values from 7 days ago. 
SELECT 
  r.date, 
  COALESCE(SUM(orders),0) AS orders,
  COALESCE(SUM(line_items),0) AS items_ordered,
  COUNT(*) AS rows
FROM 
  dsv1069.dates_rollup r
LEFT OUTER JOIN 
  (
  SELECT 
    date(paid_at) AS day,
    COUNT(DISTINCT invoice_id) AS orders,
    COUNT(DISTINCT line_item_id) AS line_items
  FROM 
    dsv1069.orders
  GROUP BY
    date(paid_at)
  ) daily_orders  
ON 
  r.date >= daily_orders.day 
AND
  r.d7_ago < daily_orders.day
GROUP BY
  r.date
  
  
-- JOin subtable, user table, and item table
SELECT * 
FROM
  (SELECT 
    user_id, 
    item_id,
    event_time,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC) AS view_number
  FROM 
    dsv1069.view_item_events
    ) recent_views
JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id 
JOIN 
  dsv1069.items 
ON 
  items.id = recent_views.item_id
  
 
-- cleaning up
SELECT 
  first_name,
  last_name,
  email_address, 
  category,
  name AS item_name
FROM
  (SELECT 
    user_id, 
    item_id,
    event_time,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC) AS view_number
  FROM 
    dsv1069.view_item_events
    ) recent_views
JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id 
JOIN 
  dsv1069.items 
ON 
  items.id = recent_views.item_id
RIGHT JOIN 
  dsv1069.orders
ON 
  orders.user_id = users.id AND orders.item_id = items.id
WHERE 
  deleted_at IS NULL 


-- create subtable
SELECT 
  user_id,
  item_id,
  event_time, 
  ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC) AS view_number
FROM dsv1069.view_item_events

-- Join tables
SELECT *
FROM(
  SELECT 
    user_id,
    item_id,
    event_time, 
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC) AS view_number
  FROM dsv1069.view_item_events
  ) recent_views
JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id
JOIN 
  dsv1069.items 
ON 
  items.id = recent_views.item_id
  
 --pull only columns we need
SELECT 
  users.id AS user_id,
  users.email_address, 
  items.id AS item_id,
  items.name AS item_name, 
  items.category AS item_category
FROM(
  SELECT 
    user_id,
    item_id,
    event_time, 
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC) AS view_number
  FROM dsv1069.view_item_events
  ) recent_views
JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id
JOIN 
  dsv1069.items 
ON 
  items.id = recent_views.item_id

----Fine tuning
-- left joined with orders and filter those with item_id that is NULL which means that they were not ordered yet
SELECT 
  COALESCE(users.parent_user_id,users.id) AS user_id,
  users.email_address, 
  items.id AS item_id,
  items.name AS item_name, 
  items.category AS item_category
FROM(
  SELECT 
    user_id,
    item_id,
    event_time, 
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC) AS view_number
  FROM 
    dsv1069.view_item_events
  WHERE 
    event_time >= '2017-01-01'
  ) recent_views
JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id
JOIN 
  dsv1069.items 
ON 
  items.id = recent_views.item_id
LEFT OUTER JOIN 
  dsv1069.orders 
ON 
  orders.item_id = recent_views.item_id 
AND 
  orders.user_id = recent_views.user_id
WHERE 
  view_number = 1
AND
  users.deleted_at IS NOT NULL
AND 
  orders.item_id IS NULL   
 








