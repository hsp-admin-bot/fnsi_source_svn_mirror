 with kur_qt as (
(select reg_rad_date::time as exam_set_cd from pat_rad_main where rad_result_cd = /*ordNo*/1)
union
(select reg_rad_date::time as exam_set_cd from pat_rad_main_hst where rad_result_cd = /*ordNo*/1
and 'D' = /*crud*/'' order by up_date desc limit 1)
),
kur_time as (
select kur_cd,kur_start_time :: time as time1,kur_end_time :: time as time2 from mst_kur where facility_cd = /* facilityCd */'999999' and is_del = '0'
),
ind_kur_cd as (
select kur_cd as ind_kur_cd from kur_time
where time1 <= (select exam_set_cd from kur_qt )
and time2 >= (select exam_set_cd from kur_qt )
),
weekend as(
(select EXTRACT(DOW FROM reg_rad_date)  as reg_rad_date from pat_rad_main where rad_result_cd = /*ordNo*/1 )
union
(select EXTRACT(DOW FROM reg_rad_date)  as reg_rad_date from pat_rad_main_hst where rad_result_cd = /*ordNo*/1
and 'D' = /*crud*/'' order by up_date desc limit 1)
)
 ((select
                (json_array_elements((mst.mst_user_authentication ->> 'data')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Mon'
                                 when 2 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Tues'
                                 when 3 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Wednes'
                                 when 4 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Thurs'
                                 when 5 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Fri'
                                 when 6 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Satur'
                                 when 7 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Sun'
                                 END) as aaa))::json ->> 'disp_user_id' as staff_cd
         from ord_main ord,
              mst_kur mst
         where ord.ind_kur_cd = mst.kur_cd
           and ord.ord_no = /*ordNo*/1
					 and 'ind_dial'=/* coopcd */''
					 )
 union
 (select
                (json_array_elements((mst.mst_user_authentication ->> 'data')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Mon'
                                 when 2 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Tues'
                                 when 3 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Wednes'
                                 when 4 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Thurs'
                                 when 5 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Fri'
                                 when 6 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Satur'
                                 when 7 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Sun'
                                 END) as aaa))::json ->> 'disp_user_id' as staff_cd
         from ord_main_restore ord,
              mst_kur mst
         where ord.ind_kur_cd = mst.kur_cd
           and ord.ord_no = /*ordNo*/1
					 and 'ind_dial'=/* coopcd */''
					 and 'D' = /*crud*/''
					 and (select count(1) from ord_main where ord_no = /*ordNo*/1)='0'
					 order by ord.up_date desc limit 1
					 ))
 union all
 ((--常勤医
         select
                (json_array_elements((mst.mst_user_authentication ->> 'data')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Mon'
                                 when 2 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Tues'
                                 when 3 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Wednes'
                                 when 4 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Thurs'
                                 when 5 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Fri'
                                 when 6 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Satur'
                                 when 7 = (select treat_week from ord_main ord where ord.ord_no = /*ordNo*/1)
                                     then 'Sun'
                                 END) as aaa))::json ->> 'disp_user_id' as staff_cd
         from ord_main ord,
              mst_kur mst
         where ord.rst_kur_cd = mst.kur_cd
           and ord.ord_no = /*ordNo*/1 and ('rst_dial/repdial'=/* coopcd */'' or 'rst_dial'=/* coopcd */'')
        )
				union
				(--常勤医
         select
                (json_array_elements((mst.mst_user_authentication ->> 'data')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Mon'
                                 when 2 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Tues'
                                 when 3 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Wednes'
                                 when 4 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Thurs'
                                 when 5 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Fri'
                                 when 6 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Satur'
                                 when 7 = (select treat_week from ord_main_restore ord where ord.ord_no = /*ordNo*/1
																 order by up_date desc limit 1)
                                     then 'Sun'
                                 END) as aaa))::json ->> 'disp_user_id' as staff_cd
         from ord_main_restore ord,
              mst_kur mst
         where ord.rst_kur_cd = mst.kur_cd
           and ord.ord_no = /*ordNo*/1
					 and ('rst_dial/repdial'=/* coopcd */'' or 'rst_dial'=/* coopcd */'') 
					 and 'D' = /*crud*/''
-- 					 and (select count(1) from ord_main where ord_no = /*ordNo*/1)='0'
					 order by ord.up_date desc limit 1
        ))
			union all
		(
select
(json_array_elements((mst.mst_user_authentication ->> 'data')::json)->>(select  (
case when 1 =(select reg_rad_date from weekend )
then 'Mon'
 when 2 =(select reg_rad_date from weekend )
then 'Tues'
 when 3 =(select reg_rad_date from weekend )
then 'Wednes'
 when 4 =(select reg_rad_date from weekend )
then 'Thurs'
 when 5 =(select reg_rad_date from weekend)
then 'Fri'
 when 6 =(select reg_rad_date from weekend)
then 'Satur'
 when 0 =(select reg_rad_date from weekend)
then 'Sun'
END ) as aaa))::json->>'disp_user_id' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = /* facilityCd */'999999' and 'rad_ord'=/* coopcd */''
)
