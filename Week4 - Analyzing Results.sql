--use order binary metrics
-- find proportion to compute the following
-- count of users per treatment group for test_id = 7
-- count of users with orders per treatment group
SELECT 
  test_assignment,
  SUM(order_binary) AS users_with_orders,
  COUNT(user_id) AS users
FROM 
  (SELECT 
    test_events.test_id, 
    test_events.test_assignment,
    test_events.user_id,
    MAX(CASE WHEN orders.created_at  > test_events.event_time THEN 1 ELSE 0 END) AS order_binary
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
    ) user_level
WHERE 
  test_id = 7
GROUP BY
 test_assignment
 
 
 --change to views binary
SELECT 
  test_assignment,
  SUM(views_binary) AS views_binary,
  COUNT(user_id) AS users
FROM 
  (SELECT 
    assignments.test_id, 
    assignments.test_assignment,
    assignments.user_id,
   MAX(CASE WHEN views.event_time  > assignments.event_time THEN 1 ELSE 0 END) AS views_binary
  FROM 
  (SELECT 
    event_id,
    event_time,
    user_id,
    MAX(CASE WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT) ELSE NULL END) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END) AS test_assignment
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'test_assignment'
  GROUP BY 
    event_id, 
    event_time,
    user_id) assignments
  LEFT JOIN 
    (
    SELECT *
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    ) views
  ON 
    views.user_id = assignments.user_id
  GROUP BY 
    assignments.test_id, 
    assignments.test_assignment,
    assignments.user_id 
    ) order_binary
WHERE 
  test_id = 7
GROUP BY
 test_assignment
 
 
 --alter the metric so taht viewed an item within 30 days
SELECT 
  test_assignment,
  SUM(views_binary) AS views_binary,
  SUM(views_binary_30d) AS views_binary_30d,
  COUNT(user_id) AS users
FROM 
  (SELECT 
    assignments.test_id, 
    assignments.test_assignment,
    assignments.user_id,
   MAX(CASE WHEN views.event_time  > assignments.event_time THEN 1 ELSE 0 END) AS views_binary,
   MAX(CASE WHEN (views.event_time  > assignments.event_time AND 
        DATE_PART('day', views.event_time - assignments.event_time) <= 30)
        THEN 1 ELSE 0 END) AS views_binary_30d
  FROM 
  (SELECT 
    event_id,
    event_time,
    user_id,
    MAX(CASE WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT) ELSE NULL END) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END) AS test_assignment
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'test_assignment'
  GROUP BY 
    event_id, 
    event_time,
    user_id) assignments
  LEFT JOIN 
    (
    SELECT *
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    ) views
  ON 
    views.user_id = assignments.user_id
  GROUP BY 
    assignments.test_id, 
    assignments.test_assignment,
    assignments.user_id 
    ) order_binary
WHERE 
  test_id = 7
GROUP BY
 test_assignment
 
 
 --use metric from previous table
-- for the mean value of invoices, line items, total revenue, compute the following
-- count of users per treatment group
-- average value of metric treatmenet per group
-- standard deviation per group
SELECT 
  test_id,
  test_assignment,
  COUNT(user_id) AS users,
  AVG(invoices) AS avg_invoices,
  STDDEV(invoices) AS stddev_invoices
FROM
  (SELECT 
      assignments.test_id, 
      assignments.test_assignment,
      assignments.user_id,
      COUNT(DISTINCT CASE WHEN orders.created_at  > assignments.event_time THEN orders.invoice_id ELSE NULL END) AS invoices,
      COUNT(DISTINCT CASE WHEN orders.created_at > assignments.event_time THEN orders.line_item_id ELSE NULL END) AS line_items,
      COALESCE(SUM(CASE WHEN orders.created_at > assignments.event_time THEN orders.price ELSE 0 END)) AS total_revenue
  FROM 
    (SELECT 
      event_id,
      event_time,
      user_id,
      MAX(CASE WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT) ELSE NULL END) AS test_id,
      MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value ELSE NULL END) AS test_assignment
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'test_assignment'
    GROUP BY 
      event_id, 
      event_time,
      user_id) assignments
  LEFT JOIN 
      dsv1069.orders
  ON 
      orders.user_id = assignments.user_id
  GROUP BY 
      assignments.test_id, 
      assignments.test_assignment,
      assignments.user_id 
   )  mean_metrics
GROUP BY 
  test_id,
  test_assignment
ORDER BY 
  test_id
 