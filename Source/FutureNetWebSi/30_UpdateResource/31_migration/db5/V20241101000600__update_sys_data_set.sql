DELETE FROM "ntss"."sys_data_set" where sql_cd in (8,165,188);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8, 'WITH ord AS (
    SELECT
       treat_date,
       facility_cd,
        ord_no,
        json_idx,
        medi,
        is_del
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
	AND ord_no in ( @ordNos )

    AND rst_dialysis_state <> ''0''
), b AS (
    select ord_main.* from ord_main
     where 	rst_dialysis_state between ''1'' and ''5''
     and
	   ord_no in ( @ordNos )

     and
       is_del = ''0''
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
),g as (
select
-- 終了予定
b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
-- 終了予測
CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS ind_end_date_time
-- 透析開始
, b.rst_start_date
-- 透析終了
, b.rst_end_date
, b.ord_no
from  b left join e on b.ord_no = e.ord_no left join f on b.ord_no = f.ord_no)

select g.*,a.* from (select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.ord_no,
  medi ->> ''cd'' as medi_cd,
  medi ->> ''name'' as medi_name,
  medi ->> ''unit'' as medi_unit,
  medi ->> ''amount'' as medi_amount,
  medi ->> ''class_cd'' as medi_class_cd,
  case when  (medi ->> ''class_cd''):: TEXT = ''-1'' then ''未分類'' else medi ->> ''class_name'' end as medi_class_name,
  medi ->> ''class_type'' as medi_class_type,
  medi ->> ''effect_flg'' as effect_flg,
  medi ->> ''short_name'' as short_name,
  CASE WHEN medi ->> ''effect_date'' <> ''null'' THEN
    to_timestamp( substring(medi ->> ''effect_date''::text from 0 for 11) || '' '' || substring(medi ->> ''effect_date''::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
  END as effect_date,
  medi ->> ''effect_user_id'' as effect_user_id,
  medi ->> ''timing_name'' as medi_timing_name,
  medi ->> ''procedure_name'' as procedure_name,
  COALESCE(medi ->> ''effect_user_last_name''::text, '''') || '' '' || COALESCE(medi ->> ''effect_user_first_name''::text, '''') as effect_user_name,
  medi->>''comment'' as comment
  , medi->>''medicine_type'' as medicine_type
	,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.class_cd else mstMedicMix.class_cd end as medicine_class_cd
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_1 else mstMedicMix.in_hospital_cd_1 end as rst_medi_in_hospital_cd_1
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_2 else mstMedicMix.in_hospital_cd_2 end as rst_medi_in_hospital_cd_2
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_3 else mstMedicMix.in_hospital_cd_3 end as rst_medi_in_hospital_cd_3
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_4 else '''' end as rst_medi_in_hospital_cd_4
	,case 
	   when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
	   when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b1
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a1
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b1
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a1
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b1
		 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
		 else ''''
	 end as rst_procedure_in_hospital_cd_1
	,case 
	   when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
	   when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b2
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a2
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b2
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a2
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b2
		 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
		 else ''''
	 end as rst_procedure_in_hospital_cd_2

	
  ,save.receipt_value as receipt_value
  ,mstMedic.unit_second as unit_second
  from
    ord
    left join mst_medicine_mix  as mstMedicMix  on (ord.medi ->> ''cd'' = mstMedicMix.medicine_mix_cd :: text and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'' )
    left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1''  )
    left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  )
    left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mstMedic.medicine_cd :: text  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and supplies_class != ''20'')
  where
	ord.ord_no in ( @ordNos )

  and ord.is_del = ''0''
order by json_idx) a
left join g
on a.ord_no=g.ord_no
where a.medicine_class_cd IN ( @medIds );', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "袋", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：投薬 @ordNo 使用', '2019-09-17 11:32:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (165, 'WITH DATA AS (

WITH ord AS (
    SELECT
        ord_no,
				treat_date,
        json_idx,
        medi,
        is_del
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no = @ordNo
    AND facility_cd = @facilityCd
    AND rst_dialysis_state > ''0'' AND rst_dialysis_state < ''6''
)
select @ordNo as ord_no_t,a.*
 from (
select
  medi ->> ''cd'' as medi_cd,
  medi ->> ''name'' as medi_name,
  medi ->> ''unit'' as medi_unit,
  medi ->> ''amount'' as medi_amount,
  case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.class_cd else mstMedicMix.class_cd end as medi_class_cd,
  medi ->> ''class_name'' as medi_class_name,
  medi ->> ''class_type'' as medi_class_type,
  medi ->> ''effect_flg'' as effect_flg,
  medi ->> ''short_name'' as short_name,
  CASE WHEN medi ->> ''effect_date'' <> ''null'' THEN
    to_timestamp( substring(medi ->> ''effect_date''::text from 0 for 11) || '' '' || substring(medi ->> ''effect_date''::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
  END as effect_date,
  medi ->> ''effect_user_id'' as effect_user_id,
  medi ->> ''timing_name'' as medi_timing_name,
  medi ->> ''procedure_name'' as procedure_name,
	COALESCE(medi ->> ''effect_user_last_name''::text, '''') || '' '' || COALESCE(medi ->> ''effect_user_first_name''::text, '''') as effect_user_name,
  medi->>''comment'' as comment
  , medi->>''medicine_type'' as medicine_type
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_1 else mstMedicMix.in_hospital_cd_1 end as rst_medi_in_hospital_cd_1
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_2 else mstMedicMix.in_hospital_cd_2 end as rst_medi_in_hospital_cd_2
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_3 else mstMedicMix.in_hospital_cd_3 end as rst_medi_in_hospital_cd_3
  ,case when  ord.medi->>''medicine_type'' = ''1'' then mstMedic.in_hospital_cd_4 else '''' end as rst_medi_in_hospital_cd_4
	,case 
	   when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
	   when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b1
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a1
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b1
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a1
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b1
		 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
		 else ''''
	 end as rst_procedure_in_hospital_cd_1
	,case 
	   when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
	   when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b2
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a2
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b2
		 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a2
		 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b2
		 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
		 else ''''
	 end as rst_procedure_in_hospital_cd_2
  from
    ord
    left join mst_medicine_mix  as mstMedicMix  on (ord.medi ->> ''cd'' = mstMedicMix.medicine_mix_cd :: text and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'' and mstMedicMix.facility_cd = @facilityCd )
    left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = @facilityCd )
    left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = @facilityCd)

  where
    ord.ord_no = @ordNo
  and ord.is_del = ''0'' )  a where a.medi_class_cd in ( @medIds )

	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
		ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ord_no
	;
	', 2, '[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：投薬 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (188, 'WITH DATA AS (

WITH ord AS (
    SELECT
        ord_no,
        facility_cd,
				treat_date,
        json_idx,
        medi,
        is_del
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no = @ordNo
    AND rst_dialysis_state <> ''0''
),
medicine_order AS (

  select
    one_json ->> ''code'' as medicine_cd
    , json_idx as medicine_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = (select facility_cd from ord limit 1)
    and master_physical_name = ''mst_medicine''

),
medicine_mix_temp AS (

select
    mix.facility_cd
    , mix.medicine_mix_cd
    , medimix ->> ''cd'' as medi_cd
    , medimix ->> ''amount'' as amount
from
    mst_medicine_mix mix
    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
where
    mix.facility_cd  = (select facility_cd from ord limit 1)
    and mix.is_del = ''0''
    and mix.is_disp = ''1''
)
select A.*, @ordNo as ord_no_t from (
    select
      json_idx,
      ord_no,
      ord.facility_cd,
      medi ->> ''cd'' as medi_cd,
      medi ->> ''name'' as medi_name,
      medi ->> ''unit'' as medi_unit,
      cast(medi ->> ''amount'' AS NUMERIC) as medi_amount,
      medi ->> ''class_cd'' :: text as medi_class_cd,
      medi ->> ''class_name'' as medi_class_name,
      medi ->> ''class_type'' :: text as medi_class_type,
            medi->>''medicine_type'' as medicine_type,
      medi ->> ''effect_flg'' as effect_flg,
      medi ->> ''short_name'' as short_name,
      CASE WHEN medi ->> ''effect_date'' <> ''null'' THEN
        to_timestamp( substring(medi ->> ''effect_date''::text from 0 for 11) || '' '' || substring(medi ->> ''effect_date''::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
      END as effect_date,
      medi ->> ''effect_user_id'' as effect_user_id,
      medi ->> ''timing_name'' as medi_timing_name,
      medi ->> ''procedure_name'' as procedure_name,
			COALESCE(medi ->> ''effect_user_last_name''::text, '''') || '' '' || COALESCE(medi ->> ''effect_user_first_name''::text, '''') as effect_user_name,
      medi->>''comment'' as comment
      ,mstMedic.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
      ,mstMedic.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
      ,mstMedic.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
      ,mstMedic.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
			,case 
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b1
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a1
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b1
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a1
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b1
				 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a1
				 else ''''
			 end as rst_procedure_in_hospital_cd_1
			,case 
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mstP.in_hosp_a_startdate) then mstP.in_hospital_cd_b2
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_b_startdate) is null then mstP.in_hospital_cd_a2
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mstP.in_hosp_a_startdate) is null then mstP.in_hospital_cd_b2
				 when date_trunc(''day'', mstP.in_hosp_b_startdate) < date_trunc(''day'', mstP.in_hosp_a_startdate) and date_trunc(''day'', mstP.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_a2
				 when date_trunc(''day'', mstP.in_hosp_a_startdate) < date_trunc(''day'', mstP.in_hosp_b_startdate) and date_trunc(''day'', mstP.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mstP.in_hospital_cd_b2
				 when (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_a_startdate) and (ord.treat_date :: TIMESTAMP) = date_trunc(''day'', mstP.in_hosp_b_startdate) then mstP.in_hospital_cd_a2
				 else ''''
			 end as rst_procedure_in_hospital_cd_2
      ,mstMedic.unit_second as   unit_second
      ,save.receipt_value as receipt_value
      from
        ord
        left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
        left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and medi ->> ''cd'' :: text  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and save.supplies_class != ''20'')
      where
      ord.medi->>''medicine_type'' = ''1''
    union
    select
      json_idx,
      ord_no,
      ord.facility_cd,
      mixtemp.medi_cd  :: text  as medi_cd,
      mstMedic.medicine_name as medi_name,
      mstMedic.unit  as medi_unit,
      (medi ->> ''amount'') :: NUMERIC *  mixtemp.amount :: NUMERIC as medi_amount,
      mstMedic.class_cd :: text as  medi_class_cd,
      classtemp.class_name as medi_class_name,
      classtemp.class_type :: text as medi_class_type,
            medi->>''medicine_type'' as medicine_type,
      medi ->> ''effect_flg'' :: text as effect_flg,
      mstMedic.medicine_short_name as short_name,
      CASE WHEN medi ->> ''effect_date'' <> ''null'' THEN
        to_timestamp( substring(medi ->> ''effect_date''::text from 0 for 11) || '' '' || substring(medi ->> ''effect_date''::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
      END as effect_date,
      medi ->> ''effect_user_id'' as effect_user_id,
      medi ->> ''timing_name'' as medi_timing_name,
      medi ->> ''procedure_name'' as procedure_name,
      (medi ->> ''effect_user_last_name''::text) || '' '' || (medi ->> ''effect_user_first_name''::text) as effect_user_name,
      medi->>''comment'' as comment
      ,mstMedic.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
      ,mstMedic.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
      ,mstMedic.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
      ,mstMedic.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
      ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
        then  mstP.in_hospital_cd_a1 else mstP.in_hospital_cd_b1 end as rst_procedure_in_hospital_cd_1
      ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
        then  mstP.in_hospital_cd_a2 else mstP.in_hospital_cd_b2 end as rst_procedure_in_hospital_cd_2
      ,mstMedic.unit_second as   unit_second
      ,save.receipt_value as receipt_value
      from
        ord
        inner join  medicine_mix_temp  mixtemp on (mixtemp.medicine_mix_cd :: text= medi ->> ''cd'' )
        left join mst_medicine as  mstMedic  on (mstMedic.medicine_cd :: text = mixtemp.medi_cd and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
        left join  mst_medicine_class  classtemp on (classtemp.class_cd :: text = mstMedic.class_cd :: text  and classtemp.facility_cd = mstMedic.facility_cd )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
        left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mixtemp.medi_cd  :: text :: text  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and save.supplies_class = ''20'' )
      where
      ord.medi->>''medicine_type'' = ''2''
) A
left join medicine_order O on (A.medi_cd = O.medicine_cd)
order by json_idx asc ,medicine_cd_order asc


	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
             ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ord_no
	;
	', 2, '[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dia_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "dia_medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dia_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dia_medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dia_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dia_medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dia_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dia_effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "dia_effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dia_effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "dia_effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬（分解）", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36',CURRENT_TIMESTAMP, NULL);
