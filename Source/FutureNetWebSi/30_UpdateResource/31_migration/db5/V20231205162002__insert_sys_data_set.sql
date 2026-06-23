delete from ntss.sys_data_set where sql_cd = '-604173';

INSERT INTO ntss.sys_data_set (sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info)
	VALUES (-604173,'SELECT
  info ->> ''cd'' as equip_cd,
  info ->> ''name'' as equip_name,
  info ->> ''class_type'' as class_type,
  info ->> ''class_cd'' as class_cd,
  info ->> ''class_name'' as class_name,
  info ->> ''amount'' as amount,
  info ->> ''unit'' as unit,
  info ->> ''cop_order_no'' as cop_order_no,
  info ->> ''is_editable'' as is_editable,
  meqa.reg_date,
  meqa.in_hospital_cd_1,
  meqa.in_hospital_cd_2
FROM
  ord_main as ord
  cross join lateral json_array_elements (ord.rst_equip_info :: json) info
  LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(info ->> ''cd'', ''999999999999'')
WHERE
  ord.ord_no = @ordNo',2,'[]'::jsonb,'0','{"applications": [4]}'::jsonb,'{"classes": []}'::jsonb,'CSI透析実績(医療材料)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);