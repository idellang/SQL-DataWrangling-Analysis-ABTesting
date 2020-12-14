
--Flexible data format
--This line of code ignores the NULL values

SELECT event_id, event_time, user_id, platform,
	MAX(CASE WHEN parameter_name = 'item_id' THEN CAST(parameter_value AS INT) ELSE NULL END) AS item_id,
	MAX(CASE WHEN parameter_name = 'referrer' THEN parameter_value ELSE NULL END) AS referrer
FROM dsv1069.events 
WHERE event_name  = 'view_item'
GROUP BY event_id, event_time, user_id, platform
ORDER BY event_id


--simple sanity check on date
SELECT 
 date(event_time) AS date,
 COUNT(*)
FROM dsv1069.events_ex2
GROUP BY date(event_time)

--can join using coalesce
SELECT COUNT(*) FROM 
dsv1069.users u
JOIN dsv1069.orders o
ON o.user_id = COALESCE(u.parent_user_id, u.id)


-- most basic. Count users per day
SELECT 
  DATE(created_at) AS day,
  COUNT(*) AS users
FROM dsv1069.users
GROUP BY DATE(created_at)

--remove rows where deleted_at is not null annd the id<> parent_user_id
SELECT 
  DATE(created_at) AS day,
  COUNT(*) AS users
FROM 
   dsv1069.users
WHERE 
   deleted_at IS NULL 
AND 
    (id <> parent_user_id OR 
    parent_user_id IS NULL)
GROUP BY 
   DATE(created_at)
   
   
--- create columns of all created users, num of users with deleted at, num of users that are merge, left join all of them on the the date created. 
--- use coalesce function for null values and then get the net
SELECT 
  new.day,
  new.new_users_added,
  COALESCE(deleted.deleted_users,0) AS deleted_users,
  COALESCE(merged.merged_users,0) AS merged_users,
  (new.new_users_added -COALESCE(deleted.deleted_users,0) - COALESCE(merged.merged_users,0)) AS new_net_users
FROM
  (SELECT 
    DATE(created_at) AS day,
    COUNT(*) AS new_users_added
  FROM 
     dsv1069.users
  GROUP BY 
    DATE(created_at)
  ) new
LEFT JOIN 
  (SELECT 
    DATE(created_at) AS day,
    COUNT(*) AS deleted_users
  FROM 
    dsv1069.users
  WHERE
   deleted_at IS NOT NULL
  GROUP BY
    DATE(created_at)) deleted
ON deleted.day = new.day
LEFT JOIN
  (SELECT 
    date(merged_at) AS day,
    COUNT(*) AS merged_users
  FROM 
    dsv1069.users
  WHERE 
    id<>parent_user_id
  AND 
    parent_user_id IS NOT NULL 
  GROUP BY 
    date(merged_at)
  ) merged
ON merged.day = new.day   


