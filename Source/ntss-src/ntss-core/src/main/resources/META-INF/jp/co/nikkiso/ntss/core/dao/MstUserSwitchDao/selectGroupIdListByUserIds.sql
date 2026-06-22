SELECT
	group_id
FROM
	mst_user_switch
WHERE
	user_id in (
	/*%for id : list*/
	  /*id*/0
	  /*%if id_has_next*/
	  ,
	  /*%end*/
	/*%end*/
	)
