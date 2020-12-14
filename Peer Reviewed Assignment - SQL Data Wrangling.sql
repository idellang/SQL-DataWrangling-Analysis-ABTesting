-- Compute for lift metrics and pvalues for binary metrics 30 day order binary and 30 day view binary using 95% confidence interval
--for orders bin the success rate is similar for both test with 30% success rate. THe pvalue is 0.88 and the imporovement is -1%. 
-- The range of improvement is -14% - 12%


--for item views
--the success rate is very close with 81% on the control and 83% on the treatment. The pvalue is 0.2 meaning that the value might be due to 20% chance
--and therefore not significant
--The lift value is 2.6% with ranging from -1.4% - 6.5%

--Summary
--for test assignment 2, the test was not significant


--write a query and table creation to make final_assignments_qa look like the final_assignments table
--if you discovered something in part 1, you may fill in the value with a place holder of the appropriate data type

SELECT *
FROM 
  dsv1069.final_assignments

--need to have columns of item_id, test_assignment, test_number, and test_date
--take note that this uses postgreqsql for date functions. I just deducted each year from each test
SELECT 
  item_id,
  test_a AS test_assignment,
  'test_a' AS test_id,
  CURRENT_TIMESTAMP as start_date
FROM 
  dsv1069.final_assignments_qa
UNION 
SELECT 
  item_id,
  test_b AS test_assignment,
  'test_b' AS test_id,
  CURRENT_TIMESTAMP - interval '1 year' as start_date
FROM 
  dsv1069.final_assignments_qa
UNION 
SELECT 
  item_id,
  test_c AS test_assignment,
  'test_c' AS test_id,
  CURRENT_TIMESTAMP - interval '2 year' as start_date
FROM 
  dsv1069.final_assignments_qa  
UNION 
SELECT 
  item_id,
  test_d AS test_assignment,
  'test_d' AS test_id,
  CURRENT_TIMESTAMP - interval '3 year' as start_date
FROM 
  dsv1069.final_assignments_qa  
UNION 
SELECT 
  item_id,
  test_e AS test_assignment,
  'test_e' AS test_id,
  CURRENT_TIMESTAMP - interval '4 year' as start_date
FROM 
  dsv1069.final_assignments_qa  
UNION 
SELECT 
  item_id,
  test_f AS test_assignment,
  'test_f' AS test_id,
  CURRENT_TIMESTAMP - interval '5 year' as start_date
FROM 
  dsv1069.final_assignments_qa    
  
  
 --use final assignments table to calculate order binary 30 days after assignment for item_test 2
-- the inside select statement gets the item id and assignment along with 1 if there are orders within 30 days and 0 if there is none
--the outside select statement groups the test assignmetn and gets the total number of orders and total number of orders within 30 days
SELECT 
  order_item_test_binary.test_assignment, 
  COUNT(order_item_test_binary.item_id) AS orders,
  SUM(order_item_test_binary.orders_binary_30d) AS total_orders_binary_30d
FROM
  (SELECT 
    final_assignments.item_id,
    final_assignments.test_assignment,
    MAX(CASE WHEN 
        (orders.created_at > final_assignments.test_start_date  AND 
        DATE_PART('day', orders.created_at - final_assignments.test_start_date) <= 30)
       THEN 1 ELSE 0 END) AS orders_binary_30d
  FROM 
    dsv1069.final_assignments
  LEFT JOIN
    dsv1069.orders
  ON 
    final_assignments.item_id = orders.item_id
  WHERE
    test_number = 'item_test_2'
  GROUP BY 
    final_assignments.item_id,
    final_assignments.test_assignment
    ) order_item_test_binary
GROUP BY 
  order_item_test_binary.test_assignment

--use final assignments to calculate view binary and average views within 30 day window after test assignment two.
-- almost teh same as the orders table but instead used view items table from the events table

SELECT 
  view_item_binary.test_assignment,
  COUNT(view_item_binary.item_id) AS num_item_views,
  SUM(view_item_binary.view_item_30d) AS total_views_30d
FROM
  (SELECT 
    final_assignments.item_id,
    final_assignments.test_assignment,
    MAX(CASE WHEN 
        (view_item.event_time > final_assignments.test_start_date  AND 
        DATE_PART('day', view_item.event_time - final_assignments.test_start_date) <= 30)
       THEN 1 ELSE 0 END) AS view_item_30d
  FROM 
    dsv1069.final_assignments
  LEFT JOIN
    (SELECT 
      event_id,
      event_time, 
      user_id,
      platform,
      MAX(CASE WHEN parameter_name = 'item_id' THEN CAST(parameter_value AS int) ELSE NULL END) AS item_id,
      MAX(CASE WHEN parameter_name = 'referrer' THEN parameter_value ELSE NULL END) AS referrer
    FROM 
      dsv1069.events
    WHERE 
      event_name = 'view_item'
    GROUP BY 
      event_id,
      event_time, 
      user_id,
      platform) view_item
  ON 
    final_assignments.item_id = view_item.item_id
  WHERE
    test_number = 'item_test_2'
  GROUP BY 
    final_assignments.item_id,
    final_assignments.test_assignment
    ) view_item_binary
GROUP BY 
  view_item_binary.test_assignment

  
  