update ntss.sys_data_set set "sql"='with  ord_tbl AS (
    SELECT
        ord_no
      , facility_cd
      , json_idx
      , to_date(treat_date, ''yyyymmdd'') as treat_date
      , treat_week
      , info ->> ''medicine_type'' as medicine_type
      , info ->> ''cd'' as cd
      , info ->> ''amount'' as amount
      , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
      , info ->> ''date_interval'' as date_interval
      , info ->> ''timing_cd'' as timing_cd
      , info ->> ''procedure_cd'' as procedure_cd
      , info ->> ''comment'' as comment
      , info ->> ''ind_user_id'' as ind_user_id
      , info ->> ''upd_user_id'' as upd_user_id
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no = @ordNo
)
, medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
  select
    *
  from
    mst_medicine_mix
  where
    mst_medicine_mix.facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine_mix.is_disp = ''1''
  and
    mst_medicine_mix.is_del = ''0''
), medicine_class_tbl as (
  select
    *
  from
    mst_medicine_class
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine_class.is_disp = ''1''
  and
    mst_medicine_class.is_del = ''0''
), timing_tbl as (
  select
    *
  from
    mst_medicate_timing
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicate_timing.is_disp = ''1''
  and
    mst_medicate_timing.is_del = ''0''
), procedure_tbl as (
  select
    *
  from
    mst_procedure
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
)
select
  ord.*
  ,case
    when medicine_type = ''2'' then mix.medicine_mix_name
    else med.medicine_name
  end as medicine_name,
  case
    when medicine_type = ''2'' then mix.unit
    else med.unit
  end as medicine_unit,
  case
    when medicine_type = ''2'' then mix.class_cd
    else med.class_cd
  end as class_cd,
  case
    when medicine_type = ''2'' then mix_cls.class_name
    else med_cls.class_name
  end as class_name,
  case
    when medicine_type = ''2'' then mix_cls.class_type
    else med_cls.class_type
  end as class_type,
  tim.medicate_timing_name,
  pro.pricedure_name
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_1 else mix.in_hospital_cd_1 end as medi_in_hospital_cd_1
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_2 else mix.in_hospital_cd_2 end as medi_in_hospital_cd_2
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_3 else mix.in_hospital_cd_3 end as medi_in_hospital_cd_3
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_4 else '''' end as medi_in_hospital_cd_4
  ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
   then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
  ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
  then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  left join medicine_tbl as med on ord.cd = med.medicine_cd::text
  left join medicine_mix_tbl as mix on ord.cd = mix.medicine_mix_cd::text
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join medicine_class_tbl as mix_cls on mix.class_cd = mix_cls.class_cd
  left join timing_tbl as tim on ord.timing_cd = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on ord.procedure_cd = pro.procedure_cd::text',db_class=2,detail='[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "strnig", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [1, 2, 3, 9]}',memo='指示：投薬 @ordNo 使用',reg_date=now(),up_date=now(),pre_sql_info=null where sql_cd=4;
insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values 
    (188,'WITH ord AS (
    SELECT
        ord_no,
        facility_cd,
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
)
,
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
select * from (
    select
      json_idx,
      ord.facility_cd,
      medi ->> ''cd'' as medi_cd,
      medi ->> ''name'' as medi_name,
      medi ->> ''unit'' as medi_unit,
      medi ->> ''amount'' as medi_amount,
      medi ->> ''class_cd'' :: text as medi_class_cd,
      medi ->> ''class_name'' as medi_class_name,
      medi ->> ''class_type'' :: text as medi_class_type,
      medi ->> ''effect_flg'' as effect_flg,
      medi ->> ''short_name'' as short_name,
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
      from
        ord
        left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
        
      where
      ord.medi->>''medicine_type'' = ''1''
    union  
    select
      json_idx,
      ord.facility_cd,
      mixtemp.medi_cd  :: text  as medi_cd,
      mstMedic.medicine_name as medi_name,
      mstMedic.unit  as medi_unit,
      mixtemp.amount  as medi_amount,
      mstMedic.class_cd :: text as  medi_class_cd,
      classtemp.class_name as medi_class_name,
      classtemp.class_type :: text as medi_class_type,
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
      from
        ord
        inner join  medicine_mix_temp  mixtemp on (mixtemp.medicine_mix_cd :: text= medi ->> ''cd'' )
        left join mst_medicine as  mstMedic  on (mstMedic.medicine_cd :: text = mixtemp.medi_cd and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
        left join  mst_medicine_class  classtemp on (classtemp.class_cd :: text = mstMedic.class_cd :: text  and classtemp.facility_cd = mstMedic.facility_cd )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
      where
      ord.medi->>''medicine_type'' = ''2''
) A  
  order by json_idx asc
  ',2,'[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dia_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "dia_medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dia_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dia_medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dia_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dia_medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dia_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dia_effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "dia_effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dia_effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "dia_effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬（分解）", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]','1','{"applications": [1]}','{"classes": [1, 2, 3, 9]}','実績：投薬（分解） @ordNo 使用',now(),now(),null)
  , (189,'WITH ord AS (
    SELECT
        ord_no,
        facility_cd,
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
)
,
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
select * from (
    select
      json_idx,
      ord.facility_cd,
      '''' as medicine_mix_cd,
      medi ->> ''cd'' as medi_cd,
      medi ->> ''name'' as medi_name,
      mstMedic.unit_second  as medi_unit,
      save.receipt_value  as medi_amount,
      medi ->> ''class_cd'' :: text as medi_class_cd,
      medi ->> ''class_name'' as medi_class_name,
      medi ->> ''class_type'' :: text as medi_class_type,
      medi ->> ''effect_flg'' as effect_flg,
      medi ->> ''short_name'' as short_name,
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
      from
        ord
        left join mst_medicine as  mstMedic  on (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ''998998'' )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ''998998'')
        left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.medi ->> ''cd''  = save.supplies_cd  and save.supplies_source_class = ''1'' and save.medicine_mix_cd  is null)
      where
      ord.medi->>''medicine_type'' = ''1''
    union  
    select
      json_idx,
      ord.facility_cd,
      mixtemp.medicine_mix_cd  :: text as medicine_mix_cd,
      mixtemp.medi_cd  :: text  as medi_cd,
      mstMedic.medicine_name as medi_name,
      mstMedic.unit_second  as medi_unit,
      save.receipt_value  as medi_amount,
      mstMedic.class_cd :: text as  medi_class_cd,
      classtemp.class_name as medi_class_name,
      classtemp.class_type :: text as medi_class_type,
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
      from
        ord
        inner join  medicine_mix_temp  mixtemp on (mixtemp.medicine_mix_cd :: text= medi ->> ''cd'' )
        left join mst_medicine as  mstMedic  on (mstMedic.medicine_cd :: text = mixtemp.medi_cd and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
        left join  mst_medicine_class  classtemp on (classtemp.class_cd :: text = mstMedic.class_cd :: text  and classtemp.facility_cd = mstMedic.facility_cd )
        left join mst_procedure as mstP on (ord.medi ->> ''procedure_cd'' = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
        left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mixtemp.medi_cd  = save.supplies_cd and save.supplies_source_class = ''1'' and  save.medicine_mix_cd != '''')
     where
      ord.medi->>''medicine_type'' = ''2''
) A  
order by json_idx asc
  ',2,'[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "receipt_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "receipt_medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "receipt_rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "receipt_rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "receipt_rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "receipt_rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "receipt_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "receipt_rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "receipt_rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "receipt_medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "receipt_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "receipt_effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "receipt_effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "receipt_effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "receipt_effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬（レセ）", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "medi_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（レセ）", "field_name": "medi_class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]','1','{"applications": [1]}','{"classes": [1, 2, 3, 9]}','実績：投薬（レセ） @ordNo 使用',now(),now(),null)
  , (190,'with  ord_tbl AS (
    SELECT
        ord_no
      , facility_cd
      , json_idx
      , to_date(treat_date, ''yyyymmdd'') as treat_date
      , treat_week
      , info
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no =  @ordNo
)
,medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
select
     mix.*
    , medimix ->> ''cd'' as medi_cd
    , medimix ->> ''amount'' as amount 
from
    mst_medicine_mix mix 
    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx) 
  where
    mix.facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mix.is_disp = ''1''
  and
    mix.is_del = ''0''
), medicine_class_tbl as (
  select
    *
  from
    mst_medicine_class
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine_class.is_disp = ''1''
  and
    mst_medicine_class.is_del = ''0''
), timing_tbl as (
  select
    *
  from
    mst_medicate_timing
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicate_timing.is_disp = ''1''
  and
    mst_medicate_timing.is_del = ''0''
), procedure_tbl as (
  select
    *
  from
    mst_procedure
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
)
select * from (
select
   json_idx
   , info ->> ''cd'' as cd
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , info ->> ''amount'' as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , med.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  left join medicine_tbl as med on info ->> ''cd'' = med.medicine_cd::text
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''1''

union 
 
select
     json_idx
   , mixtemp.medi_cd  :: text  as cd
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , mixtemp.amount as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , med.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  inner join  medicine_mix_tbl  mixtemp on (mixtemp.medicine_mix_cd :: text= info ->> ''cd'')
  left join medicine_tbl as med on  med.medicine_cd::text = mixtemp.medi_cd 
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''2''
) A  
  order by json_idx asc
  ',2,'[
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "dial_medi_class_cd",
        "data_name": "薬剤分類コード",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "class_cd",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "dial_medi_class_type",
        "data_name": "分類区分",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "class_type",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "dial_medi_cd",
        "data_name": "薬剤(調整薬剤)コード",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "cd",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2011/03/04",
        "can_calc": "0",
        "data_code": "dial_treat_date",
        "data_name": "治療日",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "treat_date",
        "disp_format": "yyyy/mm/dd",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2011/03/07",
        "can_calc": "0",
        "data_code": "dial_init_date",
        "data_name": "指示開始日",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "init_date",
        "disp_format": "yyyy/mm/dd",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "テスト薬剤１",
        "can_calc": "0",
        "data_code": "dial_medi_name",
        "data_name": "薬剤名",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "medicine_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "項目未分類",
        "can_calc": "0",
        "data_code": "dial_class_name",
        "data_name": "薬剤分類名",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "class_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "dial_medi_in_hospital_cd_1",
        "data_name": "薬剤連携コード１",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "medi_in_hospital_cd_1",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "dial_medi_in_hospital_cd_2",
        "data_name": "薬剤連携コード２",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "medi_in_hospital_cd_2",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "dial_medi_in_hospital_cd_3",
        "data_name": "薬剤連携コード３",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "medi_in_hospital_cd_3",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "dial_medi_in_hospital_cd_4",
        "data_name": "薬剤連携コード４",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "medi_in_hospital_cd_4",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "dial_medi_amount",
        "data_name": "数量",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "amount",
        "disp_format": "0",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "本",
        "can_calc": "0",
        "data_code": "dial_medicine_unit",
        "data_name": "単位",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "medicine_unit",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "静脈側回路内注射",
        "can_calc": "0",
        "data_code": "dial_pricedure_name",
        "data_name": "手技",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "pricedure_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "dial_procedure_in_hospital_cd_1",
        "data_name": "手技連携コード１",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "procedure_in_hospital_cd_1",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "dial_procedure_in_hospital_cd_2",
        "data_name": "手技連携コード２",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "procedure_in_hospital_cd_2",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "透析中",
        "can_calc": "0",
        "data_code": "dial_medicate_timing_name",
        "data_name": "投与時間帯",
        "data_type": "strnig",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "medicate_timing_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "予定薬剤です。",
        "can_calc": "0",
        "data_code": "dial_comment",
        "data_name": "コメント",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "comment",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "テスト医師",
        "can_calc": "0",
        "conv_sql": {
            "sql_cd": -2,
            "field_name": "user_name",
            "target_var": "@userId"
        },
        "data_code": "dial_ind_user_id",
        "data_name": "指示者",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "ind_user_id",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "テスト技士",
        "can_calc": "0",
        "conv_sql": {
            "sql_cd": -2,
            "field_name": "user_name",
            "target_var": "@userId"
        },
        "data_code": "dial_upd_user_id",
        "data_name": "更新者",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（分解）",
        "field_name": "upd_user_id",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "毎回",
        "can_calc": "0",
        "data_code": "dial_date_interval",
        "data_name": "投与間隔",
        "data_type": "string",
        "conv_table": [
            {
                "code": "0",
                "disp": "毎回",
                "item": "毎回"
            },
            {
                "code": "1",
                "disp": "毎週",
                "item": "毎週"
            },
            {
                "code": "2",
                "disp": "1回/2週",
                "item": "1回/2週"
            },
            {
                "code": "3",
                "disp": "1回/3週",
                "item": "1回/3週"
            },
            {
                "code": "4",
                "disp": "1回/4週",
                "item": "1回/4週"
            },
            {
                "code": "5",
                "disp": "1回/月：第1曜日",
                "item": "1回/月：第1曜日"
            },
            {
                "code": "6",
                "disp": "1回/月：第2曜日",
                "item": "1回/月：第2曜日"
            },
            {
                "code": "7",
                "disp": "1回/月：第3曜日",
                "item": "1回/月：第3曜日"
            },
            {
                "code": "8",
                "disp": "1回/月：第4曜日",
                "item": "1回/月：第4曜日"
            },
            {
                "code": "9",
                "disp": "1回/月：最終曜日",
                "item": "1回/月：最終曜日"
            },
            {
                "code": "10",
                "disp": "1回/3月：最終治療日",
                "item": "1回/月：最終治療日"
            }
        ],
        "data_class": "投薬（分解）",
        "field_name": "date_interval",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    }
]','1','{"applications": [1]}','{"classes": [1, 2, 3, 9]}','指示：投薬（分解） @ordNo 使用',now(),now(),null)
  , (191,'with  ord_tbl AS (
    SELECT
        ord_no
      , facility_cd
      , json_idx
      , to_date(treat_date, ''yyyymmdd'') as treat_date
      , treat_week
      , info
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no =  @ordNo
)
,medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
select
     mix.*
    , medimix ->> ''cd'' as medi_cd
    , medimix ->> ''amount'' as amount 
from
    mst_medicine_mix mix 
    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx) 
  where
    mix.facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mix.is_disp = ''1''
  and
    mix.is_del = ''0''
), medicine_class_tbl as (
  select
    *
  from
    mst_medicine_class
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine_class.is_disp = ''1''
  and
    mst_medicine_class.is_del = ''0''
), timing_tbl as (
  select
    *
  from
    mst_medicate_timing
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicate_timing.is_disp = ''1''
  and
    mst_medicate_timing.is_del = ''0''
), procedure_tbl as (
  select
    *
  from
    mst_procedure
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
)
select * from (
select
   json_idx
   , info ->> ''cd'' as cd
   , med.medicine_name
   , med.unit_second as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , save.receipt_value as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , med.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.info ->> ''cd''  = save.supplies_cd  and save.supplies_source_class = ''1'' and save.medicine_mix_cd  is null)
  left join medicine_tbl as med on info ->> ''cd'' = med.medicine_cd::text
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''1''

union 
 
select
     json_idx
   , mixtemp.medi_cd  :: text  as cd
   , med.medicine_name
   , med.unit_second as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , save.receipt_value as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , med.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  inner join  medicine_mix_tbl  mixtemp on (mixtemp.medicine_mix_cd :: text= info ->> ''cd'')
  left join medicine_tbl as med on  med.medicine_cd::text = mixtemp.medi_cd 
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
  left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mixtemp.medi_cd  = save.supplies_cd and save.supplies_source_class = ''1'' and  save.medicine_mix_cd != '''')
where
ord.info ->> ''medicine_type'' = ''2''
) A  
  order by json_idx asc
  ',2,'[
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "receipt_medi_class_cd",
        "data_name": "薬剤分類コード",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "class_cd",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "receipt_medi_class_type",
        "data_name": "分類区分",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "class_type",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "receipt_medi_cd",
        "data_name": "薬剤(調整薬剤)コード",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "cd",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2011/03/04",
        "can_calc": "0",
        "data_code": "receipt_treat_date",
        "data_name": "治療日",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "treat_date",
        "disp_format": "yyyy/mm/dd",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2011/03/07",
        "can_calc": "0",
        "data_code": "receipt_init_date",
        "data_name": "指示開始日",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "init_date",
        "disp_format": "yyyy/mm/dd",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "テスト薬剤１",
        "can_calc": "0",
        "data_code": "receipt_medi_name",
        "data_name": "薬剤名",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "medicine_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "項目未分類",
        "can_calc": "0",
        "data_code": "receipt_class_name",
        "data_name": "薬剤分類名",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "class_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "receipt_medi_in_hospital_cd_1",
        "data_name": "薬剤連携コード１",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "medi_in_hospital_cd_1",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "receipt_medi_in_hospital_cd_2",
        "data_name": "薬剤連携コード２",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "medi_in_hospital_cd_2",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "receipt_medi_in_hospital_cd_3",
        "data_name": "薬剤連携コード３",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "medi_in_hospital_cd_3",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "receipt_medi_in_hospital_cd_4",
        "data_name": "薬剤連携コード４",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "medi_in_hospital_cd_4",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1",
        "can_calc": "0",
        "data_code": "receipt_medi_amount",
        "data_name": "数量",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "amount",
        "disp_format": "0",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "本",
        "can_calc": "0",
        "data_code": "receipt_medicine_unit",
        "data_name": "単位",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "medicine_unit",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "静脈側回路内注射",
        "can_calc": "0",
        "data_code": "receipt_pricedure_name",
        "data_name": "手技",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "pricedure_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "receipt_procedure_in_hospital_cd_1",
        "data_name": "手技連携コード１",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "procedure_in_hospital_cd_1",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "0",
        "data_code": "receipt_procedure_in_hospital_cd_2",
        "data_name": "手技連携コード２",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "procedure_in_hospital_cd_2",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "透析中",
        "can_calc": "0",
        "data_code": "receipt_medicate_timing_name",
        "data_name": "投与時間帯",
        "data_type": "strnig",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "medicate_timing_name",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "予定薬剤です。",
        "can_calc": "0",
        "data_code": "receipt_comment",
        "data_name": "コメント",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "comment",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "テスト医師",
        "can_calc": "0",
        "conv_sql": {
            "sql_cd": -2,
            "field_name": "user_name",
            "target_var": "@userId"
        },
        "data_code": "receipt_ind_user_id",
        "data_name": "指示者",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "ind_user_id",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "テスト技士",
        "can_calc": "0",
        "conv_sql": {
            "sql_cd": -2,
            "field_name": "user_name",
            "target_var": "@userId"
        },
        "data_code": "receipt_upd_user_id",
        "data_name": "更新者",
        "data_type": "string",
        "conv_table": [],
        "data_class": "投薬（レセ）",
        "field_name": "upd_user_id",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "毎回",
        "can_calc": "0",
        "data_code": "receipt_date_interval",
        "data_name": "投与間隔",
        "data_type": "string",
        "conv_table": [
            {
                "code": "0",
                "disp": "毎回",
                "item": "毎回"
            },
            {
                "code": "1",
                "disp": "毎週",
                "item": "毎週"
            },
            {
                "code": "2",
                "disp": "1回/2週",
                "item": "1回/2週"
            },
            {
                "code": "3",
                "disp": "1回/3週",
                "item": "1回/3週"
            },
            {
                "code": "4",
                "disp": "1回/4週",
                "item": "1回/4週"
            },
            {
                "code": "5",
                "disp": "1回/月：第1曜日",
                "item": "1回/月：第1曜日"
            },
            {
                "code": "6",
                "disp": "1回/月：第2曜日",
                "item": "1回/月：第2曜日"
            },
            {
                "code": "7",
                "disp": "1回/月：第3曜日",
                "item": "1回/月：第3曜日"
            },
            {
                "code": "8",
                "disp": "1回/月：第4曜日",
                "item": "1回/月：第4曜日"
            },
            {
                "code": "9",
                "disp": "1回/月：最終曜日",
                "item": "1回/月：最終曜日"
            },
            {
                "code": "10",
                "disp": "1回/3月：最終治療日",
                "item": "1回/月：最終治療日"
            }
        ],
        "data_class": "投薬（レセ）",
        "field_name": "date_interval",
        "disp_format": "",
        "filter_type": "Medicine",
        "data_category": "指示",
        "facility_table": "",
        "facility_filter_type": "0"
    }
]','1','{"applications": [1]}','{"classes": [1, 2, 3, 9]}','指示：投薬（レセ） @ordNo 使用',now(),now(),null);
