truncate table log_table_comment;
insert into log_table_comment(tbl_name,tbl_comment,col_name,col_comment,pk_flg,json_flg) 
SELECT 
   tabname,
	 tblcomment,
	 colname,
	 coalesce(colcomment,colname) as colcomment,
   case when (
	   SELECT
    	   count(1)
	   FROM
    	   pg_constraint
	   INNER JOIN pg_class ON pg_constraint.conrelid = pg_class.oid
	   INNER JOIN pg_attribute ON pg_attribute.attrelid = pg_class.oid
	   AND (pg_attribute.attnum = pg_constraint.conkey [1]
	        or pg_attribute.attnum = pg_constraint.conkey [2]
		 	   or pg_attribute.attnum = pg_constraint.conkey [3]
		 	   or pg_attribute.attnum = pg_constraint.conkey [4]
		 	   or pg_attribute.attnum = pg_constraint.conkey [5]
	   		 or pg_attribute.attnum = pg_constraint.conkey [6]
	   		 or pg_attribute.attnum = pg_constraint.conkey [7]
		 	   or pg_attribute.attnum = pg_constraint.conkey [8]
		 	   or pg_attribute.attnum = pg_constraint.conkey [9]
		 	   or pg_attribute.attnum = pg_constraint.conkey [10])
	   INNER JOIN pg_type ON pg_type.oid = pg_attribute.atttypid
	   WHERE
    	   pg_class.relname = tabname
				 AND pg_attribute.attname = colname
	   	   AND pg_constraint.contype = 'p') > 0
	 then 1
	 else 0
	 end as pkflg,
	 case when typname='jsonb' then 1 else 0 end as jsonflg
FROM
(
SELECT 
    c.tabname,
		pg_type.typname,
    c.comment as tblcomment,
    a.attname as colname,
    col_description(a.attrelid,a.attnum) as colcomment
FROM 
     pg_attribute as a ,
		 pg_type,
     (select 
        oid,
        relname as tabname,
        case  
	        when relname = 'sys_report_setting' then '機能帳票マスタ'
	        when relname = 'sys_master_define' then 'マスタ定義'
	        when relname = 'sys_data_set' then 'データセット'
	      else
	        cast(obj_description(relfilenode,'pg_class') as varchar) 
	      end as comment 
      from 
        pg_class c 
      where  
        relkind = 'r' and 
        relname not like 'pg_%' and 
        relname not like 'flyway_%' and 
        relname not like 'sql_%' and
        relname not in ('log_json_comment','log_table_comment') and
				cast(obj_description(relfilenode,'pg_class') as varchar) is not null
    ) as c
where 
      a.attrelid = c.oid and 
      a.attnum > 0 and
			pg_type.oid = a.atttypid
) T
order by tabname;

UPDATE LOG_TABLE_COMMENT SET KEYSTEP = 1 WHERE TBL_NAME='ord_weight_scale' AND COL_NAME='print_content';
UPDATE LOG_TABLE_COMMENT SET KEYSTEP = 1 WHERE TBL_NAME='pat_event' AND COL_NAME='result_params';
UPDATE LOG_TABLE_COMMENT SET KEYSTEP = 1 WHERE TBL_NAME='pat_hhd_pattern' AND COL_NAME='ind_cond_info';
UPDATE LOG_TABLE_COMMENT SET KEYSTEP = 1 WHERE TBL_NAME='pat_main' AND COL_NAME='tare_info';
UPDATE LOG_TABLE_COMMENT SET KEYSTEP = 1 WHERE TBL_NAME='pat_main' AND COL_NAME='off_water_info';

update log_table_comment set ord_main_hst_ins_flg=1 where tbl_name='ord_main' and col_name in ('rst_relation_dialysis_no',
'rst_input_class',
'rst_kur_cd',
'rst_kur_name',
'rst_bed_cd',
'rst_bed_name',
'rst_machine_no',
'rst_machine_name',
'rst_accept_date',
'rst_return_home_date',
'rst_in_out_class',
'rst_dialysis_cnt',
'rst_ward_cd',
'rst_ward_name',
'rst_course_cd',
'rst_course_name',
'rst_dw',
'rst_puncture_user_info',
'rst_return_user_info',
'rst_blood_circulate_total',
'rst_running_time',
'rec_set_date',
'send_ctl_no',
'blood_purifier_name',
'pull_leave_amount',
'rst_tare_info',
'rst_off_water_info',
'rst_device_set_info',
'is_confirm',
'rst_purification_cnt',
'rst_fn_dialysis_no',
'rst_is_update_edition',
'rst_start_date',
'rst_kt_v',
'weight_scale_no',
'rst_equip_info',
'rst_rounds_info',
'rst_vital_info',
'rst_treatment_info',
'rst_treat_staff_info',
'rst_complaint_info',
'rst_medi_info',
'rst_charge_user_info',
'rst_ind_comment_info',
'rst_cond_send_date',
'rst_treatment_cd',
'rst_treatment_name',
'rst_cond_info',
'rst_dialysis_state',
'rst_end_date',
'rst_edition',
'rst_weight_info'
);