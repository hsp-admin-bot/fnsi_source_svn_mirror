COMMENT ON COLUMN "pat_event"."letter_info" IS E'紹介状情報';
COMMENT ON COLUMN "mst_if_edge_command"."command_key" IS E'コマンドキー';
COMMENT ON COLUMN "mst_if_edge_command"."add_setting" IS E'追加設定フラグ';
COMMENT ON COLUMN "mst_mainte_layout_hst"."layout_header" IS E'力ラム名';
COMMENT ON COLUMN "ord_coop_no"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_obs_kind"."fn_kind_id" IS E'種別ID';
COMMENT ON COLUMN "mnt_if_edge_manage"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_unique"."old_up_date_unique" IS E'(旧)更新日時';
COMMENT ON COLUMN "sal_subscription_manage"."canceller" IS E'キャンセラー';
COMMENT ON COLUMN "sal_subscription_manage"."cancel_date" IS E'キャンセル日時';
COMMENT ON COLUMN "ord_exception_period"."exception_period_no" IS E'除外期間番号';
COMMENT ON COLUMN "ord_exception_period"."facility_cd" IS E'施設コード';

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
	        coalesce(cast(obj_description(relfilenode,'pg_class') as varchar) ,
	       (select description from pg_description where objsubid=0 and c.oid=objoid limit 1)) end as comment 
      from 
        pg_class c 
      where  
        relkind = 'r' and 
        relname not like 'pg_%' and 
        relname not like 'flyway_%' and 
        relname not like 'sql_%' and
        relname not in ('log_json_comment','log_table_comment') 
    ) as c
where 
      a.attrelid = c.oid and 
      a.attnum > 0 and
			pg_type.oid = a.atttypid
) T where tblcomment is not null
order by tabname;

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

update log_table_comment set pk_flg=1 where tbl_name='pat_group' and col_name='pat_group_cd';

update 
    log_table_comment 
set 
    keystep = 0 
where (tbl_name,col_name) in 
(select 
    distinct tbl_name,col_name 
 from (
       select 
		       * 
		   from 
		      log_json_comment 
		   where json_key_name like '%-%'
		  ) a
);