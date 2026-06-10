with mst_user_authenticator as(		select (json_array_elements((mst.mst_user_authentication ->> 'data')::json)->>(select  (
case when 1 =(select treat_week from ord_main ord where ord.ord_no = /*ordNo*/0 )
then 'Mon'
 when 2 =(select treat_week from ord_main ord where ord.ord_no = /*ordNo*/0 )
then 'Tues'
 when 3 =(select treat_week from ord_main ord where ord.ord_no = /*ordNo*/0 )
then 'Wednes'
 when 4 =(select treat_week from ord_main ord where ord.ord_no = /*ordNo*/0 )
then 'Thurs'
 when 5 =(select treat_week from ord_main ord where ord.ord_no = /*ordNo*/0 )
then 'Fri'
 when 6 =(select treat_week from ord_main ord where ord.ord_no = /*ordNo*/0 )
then 'Satur'
 when 7 =(select treat_week from ord_main ord where ord.ord_no = /*ordNo*/0 )
then 'Sun'
END ) as aaa))::json->>'disp_user_id' as staff_cd from ord_main ord, mst_kur mst where ord.rst_kur_cd = mst.kur_cd
		and ord.ord_no = /*ordNo*/0

),
ini_key as (SELECT COALESCE ( NULLIF( info ->> 'value', '' ), info ->> 'default_v' ) AS staff_cd
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = /* facilityCd */'0'

	AND is_del = '0'
   -- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 ljg start
	AND COALESCE(info->>'key0', '') = /* key0 */''
    -- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 ljg end
	AND info ->> 'key1' = 'DIALYSISSEND'
	AND info ->> 'key2' = 'DOCTOR_TYPE'
	AND is_disp = '1'
    AND is_del = '0'
    order by up_date desc
	)
	 select  (case when (((select staff_cd  from mst_user_authenticator)is NULL OR
 		(select staff_cd from mst_user_authenticator)= ''
 		OR  (select staff_cd from mst_user_authenticator) = '0') and
 	  '2' = (select * from ini_key))
 		THEN (SELECT COALESCE ( NULLIF( info ->> 'value', '' ), info ->> 'default_v' ) AS staff_cd
     FROM mst_coop_ini AS ini
     CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
     WHERE
 	  facility_cd = /* facilityCd */'0'
 	  AND is_del = '0'
      -- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 ljg start
	  AND COALESCE(info->>'key0', '') = /* key0 */''
      -- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 ljg end
 	  AND info ->> 'key1' = 'DIALYSISSEND'
 	  AND info ->> 'key2' = 'DOCTOR_DEF'
 	  AND is_disp = '1'
      AND is_del = '0'
      order by up_date desc)
 	  when ((select staff_cd from mst_user_authenticator)is not NULL and
 		(select staff_cd from mst_user_authenticator)!= ''
 		and (select staff_cd from mst_user_authenticator) != '0'  and
 	  '2' = (select * from ini_key) ) then
 	  (select staff_cd from mst_user_authenticator)
 		end) as staff_cd
