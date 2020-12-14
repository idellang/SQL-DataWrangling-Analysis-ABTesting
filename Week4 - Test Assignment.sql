-- how many tests do we have running
SELECT 
  COUNT(DISTINCT parameter_value) AS tests
FROM 
  dsv1069.events 
WHERE
  event_name = 'test_assignment'
AND 
  parameter_name = 'test_id'
  
  
 --check for potential problems
SELECT 
  date(event_time) AS day,
  COUNT(*)
FROM 
  dsv1069.events 
WHERE
  event_name = 'test_assignment'
GROUP BY
  date(event_time)
  
--check for potential problems
-- Check for data per tests
SELECT
  parameter_value AS test_id,
  date(event_time) AS day,
  COUNT(*)
FROM 
  dsv1069.events 
WHERE
  event_name = 'test_assignment'
AND
  parameter_name = 'test_id'
GROUP BY
  date(event_time),
  parameter_value  
  
  
 --write a query that returns a table of assignments and dates for each test
SELECT 
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
  platform
ORDER BY 
  event_id
  
  
--check for potential problems with test_id = 5
-- make sure users are assigned only ine one group
SELECT 
  test_id,
  user_id,
  COUNT(DISTINCT test_assignment) AS assignments
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
    platform
  ORDER BY 
    event_id) test_events
GROUP BY 
  test_id,
  user_id
ORDER BY 
  COUNT(DISTINCT test_assignment) DESC


  