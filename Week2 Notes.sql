SELECT 
  id                                    									AS user_id,
  (CASE WHEN u.created_at = '2018-01-01' THEN 1 ELSE 0 END)  				AS created_today,
  (CASE WHEN u.deleted_at <= '2018-01-01' THEN 1 ELSE 0 END) 				AS is_deleted,
  (CASE WHEN u.deleted_at = '2018-01-01' THEN 1 ELSE 0 END)  				AS is_deleted_today,
  (CASE WHEN users_with_order.user_id IS NOT NULL THEN 1 ELSE 0 END)        AS has_ever_ordered,
  (CASE WHEN users_with_order_today.user_id IS NOT NULL THEN 1 ELSE 0 END)  AS ordered_today,
  '2018-01-01'                            									AS ds
FROM
   dsv1069.users u
LEFT JOIN
  (SELECT 
    DISTINCT o.user_id
  FROM 
    dsv1069.orders o
  WHERE
    o.created_at <= '2018-01-01'
  ) users_with_order
ON 
  users_with_order.user_id = u.id
LEFT JOIN
  (SELECT 
    DISTINCT o.user_id
  FROM 
    dsv1069.orders o
  WHERE
    o.created_at = '2018-01-01'
  ) users_with_order_today
ON 
  users_with_order_today.user_id = u.id


CREATE TABLE IF NOT EXISTS user_info 
	(
	user_id				INT(10) NOT NULL,
	created_today		INT(1)  NOT NULL,
    is_deleted          INT(1)  NOT NULL,
    is_deleted_today    INT(1)  NOT NULL,
    has_ever_ordered    INT(1)  NOT NULL,
    ordered_today       INT(1)  NOT NULL,
    ds                  INT(1)  NOT NULL
	)
	
INSERT INTO 
	user_info
SELECT ....