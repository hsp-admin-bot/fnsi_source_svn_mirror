with
ind_kur_cd1 as (
 select ind_kur_cd,facility_cd from ord_main where pat_id = (select pat_id from pat_exam_main where exam_main_cd = /*ordNo*/0)
 and     date_part('YEAR',cast(treat_date as date))= (select date_part('YEAR',reg_exam_date) from pat_exam_main where exam_main_cd = /*ordNo*/0)
 and     date_part('month',cast(treat_date as date))= (select date_part('month',reg_exam_date) from pat_exam_main where exam_main_cd = /*ordNo*/0)
 and     date_part('day',cast(treat_date as date))= (select date_part('day',reg_exam_date) from pat_exam_main where exam_main_cd = /*ordNo*/0)
),
	ind_kur_cd as (
	 select kur_cd as ind_kur_cd from mst_kur,ind_kur_cd1 where mst_kur.kur_cd = ind_kur_cd1.ind_kur_cd and mst_kur.facility_cd = ind_kur_cd1.facility_cd
	 and is_del = '0' order by kur_end_time  limit 1
),
reg_order_class as (
select reg_order_class from pat_exam_main where exam_main_cd = /*ordNo*/0
),
kur_qt as(
select (staff.value ->'set_cd')::text as exam_set_cd from pat_exam_main as pat CROSS JOIN LATERAL json_array_elements(pat.order_exam_set_info ::json) staff where pat.exam_main_cd = /*ordNo*/0
),
kur_time as (
select kur_cd,kur_start_time :: time as time1,kur_end_time ::time as time2 from mst_kur where facility_cd = /* facilityCd */'0' and is_del = '0'
),
ind_kur_cd3 as (
select kur_cd ::text as ind_kur_cd from kur_time where time1 <= (select other_exam_time :: time as mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = /* facilityCd */'0' ) and time2 >= (select other_exam_time ::time as mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = /* facilityCd */'0')
),
weekend as(
select EXTRACT(DOW FROM reg_exam_date)  as reg_exam_date from pat_exam_main where exam_main_cd = /*ordNo*/0
),
mst_user_authenticator1 as (
select
(json_array_elements((mst.mst_user_authentication ->> 'data')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )
then 'Mon'
 when 2 =(select reg_exam_date from weekend )
then 'Tues'
 when 3 =(select reg_exam_date from weekend )
then 'Wednes'
 when 4 =(select reg_exam_date from weekend )
then 'Thurs'
 when 5 =(select reg_exam_date from weekend)
then 'Fri'
 when 6 =(select reg_exam_date from weekend)
then 'Satur'
 when 0 =(select reg_exam_date from weekend)
then 'Sun'
END ) as aaa))::json->>'disp_user_id' as staff_cd from mst_kur mst where  mst.kur_cd::text = (select ind_kur_cd from ind_kur_cd3)
and facility_cd = /* facilityCd */'0'

),
mst_user_authenticator as(
select (json_array_elements((mst.mst_user_authentication ->> 'data')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )
then 'Mon'
 when 2 =(select reg_exam_date from weekend )
then 'Tues'
 when 3 =(select reg_exam_date from weekend )
then 'Wednes'
 when 4 =(select reg_exam_date from weekend )
then 'Thurs'
 when 5 =(select reg_exam_date from weekend)
then 'Fri'
 when 6 =(select reg_exam_date from weekend)
then 'Satur'
 when 0 =(select reg_exam_date from weekend)
then 'Sun'
END ) as aaa))::json->>'disp_user_id' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = /* facilityCd */'0'
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
	AND info ->> 'key1' = 'EXAMSCHESEND'
	AND info ->> 'key2' = 'DOCTOR_SELECT_MODE'
	AND is_disp = '1' AND is_del = '0'order by up_date desc
	),
	mst_user_authenticator2 as (
select
case when (select reg_order_class from reg_order_class) = '0'
then (select staff_cd from mst_user_authenticator1)
else
(select staff_cd from mst_user_authenticator) end as staff_cd
)
     select staff_cd from(
     select  (case when (((select staff_cd  from mst_user_authenticator2)is NULL OR
 		(select staff_cd from mst_user_authenticator2)= ''
 		OR  (select staff_cd from mst_user_authenticator2) = '0') and
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
 	  AND info ->> 'key1' = 'EXAMSCHESEND'
 	  AND info ->> 'key2' = 'DOCTOR_DEF'
 	  AND is_disp = '1' AND is_del = '0'order by up_date desc
 	  )
 	  when ((select staff_cd from mst_user_authenticator2)is not NULL and
 		(select staff_cd from mst_user_authenticator2)!= ''
 		and (select staff_cd from mst_user_authenticator2) != '0'  and
 	  '2' = (select * from ini_key) ) then
 	  (select staff_cd from mst_user_authenticator2)
 		end) as staff_cd) Alldoctor where Alldoctor.staff_cd is not null




