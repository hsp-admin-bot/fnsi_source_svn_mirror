SELECT
  	/*%expand */*
FROM
  	mst_user
WHERE
  	is_del = '0'
AND
	  is_set_qr_code is null
AND
	  secret_key is null
AND
	  user_id in /* listUserId*/(0)
