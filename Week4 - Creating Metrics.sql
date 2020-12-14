--whether user created an order after test assignment
-- if user have zero order should add a row that counts their number of orders as zero
SELECT 
  test_events.test_id, 
  test_events.test_assignment,
  test_events.user_id,
  (CASE WHEN orders.created_at  > test_events.event_time THEN invoice_id ELSE NULL END) AS orders_after_assignment
FROM 
(SELECT 
  event_id,
  event_time,
  user_id,
  platform, 
  MAX(CASE WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT) ELSE NULL END) AS test_id,
  MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END) AS test_assignment
FROM 
  dsv1069.events 
WHERE 
  event_name = 'test_assignment'
GROUP BY 
  event_id, 
  event_time,
  user_id,
  platform) test_events
LEFT JOIN 
  dsv1069.orders
ON 
  orders.user_id = test_events.user_id
  

--change if the user has ordered
SELECT 
  test_events.test_id, 
  test_events.test_assignment,
  test_events.user_id,
  MAX(CASE WHEN orders.created_at  > test_events.event_time THEN 1 ELSE 0 END) AS has_ordered
FROM 
(SELECT 
  event_id,
  event_time,
  user_id,
  platform, 
  MAX(CASE WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT) ELSE NULL END) AS test_id,
  MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END) AS test_assignment
FROM 
  dsv1069.events 
WHERE 
  event_name = 'test_assignment'
GROUP BY 
  event_id, 
  event_time,
  user_id,
  platform) test_events
LEFT JOIN 
  dsv1069.orders
ON 
  orders.user_id = test_events.user_id
GROUP BY 
  test_events.test_id, 
  test_events.test_assignment,
  test_events.user_id


--compute invoices,
--compute lineitems
--total revenue
SELECT 
  test_events.test_id, 
  test_events.test_assignment,
  test_events.user_id,
  COUNT(DISTINCT(CASE WHEN orders.created_at  > test_events.event_time THEN invoice_id ELSE NULL END)) AS orders_after_assignment,
  COUNT(DISTINCT(CASE WHEN orders.created_at  > test_events.event_time THEN line_item_id ELSE NULL END)) AS items_after_assignment,
  SUM((CASE WHEN orders.created_at  > test_events.event_time THEN price ELSE 0 END)) AS total_revenue
FROM 
(SELECT 
  event_id,
  event_time,
  user_id,
  platform, 
  MAX(CASE WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT) ELSE NULL END) AS test_id,
  MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END) AS test_assignment
FROM 
  dsv1069.events 
WHERE 
  event_name = 'test_assignment'
GROUP BY 
  event_id, 
  event_time,
  user_id,
  platform) test_events
LEFT JOIN 
  dsv1069.orders
ON 
  orders.user_id = test_events.user_id
GROUP BY 
  test_events.test_id, 
  test_events.test_assignment,
  test_events.user_id  