delete from "sys_data_set" where "sql_cd" = -100000 or "sql_cd" = -100001 or "sql_cd" = -100006 or "sql_cd" = -100007 or "sql_cd" = -100008 or "sql_cd" = -100009 or "sql_cd" = -104 or "sql_cd" = -101;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100009, 'select t.filename as filename from ( (select ''PatientInfo.xml'' as filename, 1 as key) union all (select ''pdfserverinfo.xml'' as filename, 2 as key) union all (select ''sample_001.xml'' as filename, 3 as key) union all (select ''sample_002.xml'' as filename, 4 as key) ) t where t.key = @key', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'report test', '2020-07-31 18:29:49.294', '2020-07-31 18:29:49.294', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100008, 'select journal.hosp_pat_id || lpad(trim(to_char(coalesce(ord.rst_fn_dialysis_no,0), ''999999999999'')), 12, ''0'')  || lpad(trim(to_char(ord.rst_edition, ''9999'')), 4, ''0'') ||''.pdf'' as filename from sys_coop_journal journal  inner join ord_main ord on journal.ord_no = ord.ord_no where journal.ord_no = @ordNo and journal.direction = ''S'' and journal.ana_result = ''0'' and journal.is_del = ''0'' limit 1;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'report test', '2020-07-31 18:29:49.294', '2020-07-31 18:29:49.294', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100007, 'select ''TAR'' || to_char(NOW(), ''YYYYMMDDHH24MISS'') || ''.tar'' as filename', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'report test', '2020-07-31 18:29:49.294', '2020-07-31 18:29:49.294', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100006, 'select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  rst_bed_name as bed_name,
  coalesce(rst_fn_dialysis_no,0) as dialysis_no,
  rst_edition as edition,
  up_date as up_date
  
from
  ord_main as ord
where
  ord.ord_no = @ordNo', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'report test', '2020-07-31 18:29:49.294', '2020-07-31 18:29:49.294', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100001, 'select
hosp_pat_id,
personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
case when pat_birthday is null then null
else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))
end as pat_age,
case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,
pat_blood_type_abo,
pat_blood_type_rh,
pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
pat_blood_type_serovar as pat_blood_type_serovar,
in_out_class,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
nationality as nationality,
severity_cd,
transport_cd,
is_die,
die_date,
die_cd,
die_cd as die_cd1,
up_date
from
pat_personal_main
where
is_del = ''0''
and
pat_id = @patId', 3, '[]', '0', '{"applications": []}', '{"classes": []}', 'report test', '2020-07-31 18:29:49.294', '2020-07-31 18:29:49.294', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100000, 'SELECT ''05'' AS detail_id', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'report test', '2020-07-31 18:29:49.294', '2020-07-31 18:29:49.294', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-104, 'select
 concat(to_char(ord.ord_no,''fm000000000000''),
 ''-'',
 to_char(ord.rst_edition,''fm000''),
 ''.pdf'') as pdf_file
from 
 ord_main ord
where
 ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-101, 'select 
    all_cost.*
from
(select --ベッド情報
    ''実績詳細'' as detail_id,
    ''VE1'' as sbt_key,
    mbd.in_hospital_cd_1 as e01,--ベッドコード
    ''VE1'' as e02,
    substring(mbd.bed_name,1,25) as e03,--ベッド名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''01'' as e10,
    '''' as e11
from
    ord_main ord
left outer join
  mst_bed as mbd
 on
  mbd.bed_cd =ord.rst_bed_cd
where
    ord.ord_no = @ordNo

union

select --治療項目情報
    ''実績詳細'' as detail_id,
    ''VC1'' as sbt_key,
    mtt.in_hospital_cd_a1 as e01,--治療コード
    ''VC1'' as e02,
    substring(mtt.treatment_name,1,25) as e03,--治療項目名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''02'' as e10,
    '''' as e11
from
    ord_main ord
 left outer join
  mst_treatment as mtt
 on
  mtt.treatment_cd = ord.rst_treatment_cd
where
    ord.ord_no = @ordNo

union

select --透析開始時刻情報
    ''実績詳細'' as detail_id,
    ''VA6'' as sbt_key,
    ''99999'' as e01,--治療コード
    ''VA6'' as e02,
     substring(to_char(rst_start_date,''HH24:MI''),1,25) as e03,--治療項目名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''03'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo

union

select --透析終了時刻情報
    ''実績詳細'' as detail_id,
    ''VA7'' as sbt_key,
    ''99999'' as e01,--コード
    ''VA7'' as e02,
     to_char(rst_end_date,''HH24:MI'') as e03,--項目名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''04'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo

union

select --透析所要時間情報
    ''実績詳細'' as detail_id,
    ''VA8'' as sbt_key,
    ''99999'' as e01,--コード
    ''VA8'' as e02,
     to_char(rst_end_date-rst_start_date,''HH24:MI'') as e03,--項目名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''05'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo

union

select --前体重情報
    ''実績詳細'' as detail_id,
    ''VF2'' as sbt_key,
    ''99999'' as e01,--コード
    ''VF2'' as e02,
    substring(ord.rst_weight_info ->> ''weight_before_date'',1,25)  as e03,--項目名
    to_char(TO_NUMBER (ord.rst_weight_info ->> ''weight_before'',''999999999.999''),''999999.999'')  as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''06'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo 

union

select --後体重情報
    ''実績詳細'' as detail_id,
    ''VF9'' as sbt_key,
    ''99999'' as e01,--コード
    ''VF9'' as e02,
    substring(ord.rst_weight_info ->> ''weight_after_date'',1,25)  as e03,--項目名
    to_char(TO_NUMBER (ord.rst_weight_info ->> ''weight_after'',''999999999.999''),''999999.999'')   as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''07'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo 

union

select --目標体重情報
    ''実績詳細'' as detail_id,
    ''VF1'' as sbt_key,
    ''99999'' as e01,--コード
    ''VF1'' as e02,
    substring(to_char(ord.rst_start_date,''YYYY/MM/DD''),1,25)  as e03,--項目名
    to_char(TO_NUMBER (ord.rst_cond_info -> ''3'' ->> ''value'',''999999999.999'') ,''999999.999'') as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''08'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo 

union

select --DW情報
    ''実績詳細'' as detail_id,
    ''VF3'' as sbt_key,
    ''99999'' as e01,--コード
    ''VF3'' as e02,
    to_char(ord.rst_start_date,''YYYY/MM/DD'')  as e03,--項目名
    to_char(ord.rst_dw,''999999.999'')  as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''09'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo 

union

select --透析導入日情報
    ''実績詳細'' as detail_id,
    ''VS3'' as sbt_key,
    ''99999'' as e01,--コード
    ''VS3'' as e02,
    pma.medical_care_info ->>''dialysis_start_date'' as e03,--名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''10'' as e10,
    '''' as e11
from
    ord_main ord
left outer join
  pat_main as pma
 on
  pma.pat_id =ord.pat_id
where
    ord.ord_no = @ordNo

union

--障害者加算から再開
select --障害者加算情報
    ''実績詳細'' as detail_id,
    ''VAB'' as sbt_key,
    mad.in_hospital_cd_1 as e01,--コード
    ''VAB'' as e02,
    substring(addi ->> ''name'',1,25) as e03,--名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''11'' as e10,
    '''' as e11
from
    ord_main ord
    cross join lateral
      json_array_elements (ord.addition_info :: json) addi
left outer join
  mst_addition as mad
 on
  mad.addition_cd = to_number(addi ->> ''cd'',''9999999999'')
where
    mad.addition_class = ''2'' and
    ord.ord_no = @ordNo

union

select --VA情報
    ''実績詳細'' as detail_id,
    ''VN1'',
    mva.in_hospital_cd_1,--e1
     ''VN1'' ,--e2
    substring(mva.va_name,1,25),--e3
    ''0000000.000'' as e04,--e4
    ''0'',--e5
    '''',--e6
    '''',--e7
    '''' as e08,
    '''' as e09,
    ''12'' as e10,
    '''' as e11
from
    ord_main ord
    left outer join
      mst_va as mva
    on
      mva.va_cd = TO_NUMBER (ord.rst_cond_info->''2''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --ダイアライザ情報
    ''実績詳細'' as detail_id,
    ''VH1'',
    mdz.in_hospital_cd_1 as e1,
     COALESCE(mdz.in_hospital_cd_2, ''VH1'') as e2,
    substring(mdz.model_number,1,25) as e3,
    ''0000001.000'' as e04,
    ''0'' as e5,
    '''' as e6,
    '''' as e7,
    '''' as e08,
    '''' as e09,
    ''13'' as e10,
    '''' as e11
from
    ord_main ord
    left outer join
      mst_dialyzer as mdz
    on
      mdz.dialyzer_cd = TO_NUMBER (ord.rst_cond_info->''5''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --医材内ダイアライザ情報
     ''実績詳細'' as detail_id,
    ''VH1'',
    mdz.in_hospital_cd_1 as e1,
     COALESCE(mdz.in_hospital_cd_2, ''VH1'') as e2,
    substring(mdz.model_number,1,25) as e3,
    ''0000001.000'' as e04,
    ''0'' as e5,
    '''' as e6,
    '''' as e7,
    '''' as e08,
    '''' as e09,
    ''14'' as e10,
    '''' as e11
 from
  ord_main ord
   cross join lateral
      json_array_elements (ord.rst_equip_info :: json) equip
    left outer join
      mst_dialyzer as mdz
    on
      mdz.dialyzer_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  equip->>''equip_type'' = ''1'' and
  ord.ord_no = @ordNo

union

select --吸着器情報
    ''実績詳細'' as detail_id,
    ''VH2'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VH2'') as e2,
    substring(meq.equipment_name,1,25) as e3,
    ''0000001.000'' as e04,
    ''1'' as e5,
    meq.unit as e6,
    meq.unit as e7,
    '''' as e08,
    '''' as e09,
    ''15'' as e10,
    '''' as e11
from
    ord_main ord
    left outer join
      mst_equipment as meq
    on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''7''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --1次膜情報
    ''実績詳細'' as detail_id,
    ''VH3'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VH3'') as e2,
    substring(meq.equipment_name,1,25) as e3,
    ''0000001.000'' as e04,
    ''1'' as e5,
    meq.unit as e6,
    meq.unit as e7,
    '''' as e08,
    '''' as e09,
    ''16'' as e10,
    '''' as e11
from
    ord_main ord
    left outer join
      mst_equipment as meq
    on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''7''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --2次膜情報
    ''実績詳細'' as detail_id,
    ''VH3'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VH3'') as e2,
    substring(meq.equipment_name,1,25) as e3,
    ''0000001.000'' as e04,
    ''1'' as e5,
    meq.unit as e6,
    meq.unit as e7,
    '''' as e08,
    '''' as e09,
    ''17'' as e10,
    '''' as e11
from
    ord_main ord
    left outer join
      mst_equipment as meq
    on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''8''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --A針情報
     ''実績詳細'' as detail_id,
    ''VR1'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
    substring(ord.rst_cond_info->''9''->>''value_name_1'',1,25) as e3,
    ''0000001.000'' as e04,
    ''1'' as e5,
    meq.unit as e6,
    meq.unit as e7,
    '''' as e08,
    '''' as e09,
    ''18'' as e10,
    '''' as e11
 from
  ord_main ord
   left outer join
   mst_equipment as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --V針情報
     ''実績詳細'' as detail_id,
    ''VR1'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
    substring(ord.rst_cond_info->''10''->>''value_name_1'',1,25) as e3,
    ''0000001.000'' as e04,
    ''1'' as e5,
    meq.unit as e6,
    meq.unit as e7,
    '''' as e08,
    '''' as e09,
    ''19'' as e10,
    '''' as e11
 from
  ord_main ord
   left outer join
   mst_equipment as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --SN針情報
     ''実績詳細'' as detail_id,
    ''VR1'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
    substring(ord.rst_cond_info->''11''->>''value_name_1'',1,25) as e3,
    ''0000001.000'' as e04,
    ''1'' as e5,
    meq.unit as e6,
    meq.unit as e7,
    '''' as e08,
    '''' as e09,
    ''20'' as e10,
    '''' as e11
 from
  ord_main ord
   left outer join
   mst_equipment as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''11''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --医材内穿刺針情報
     ''実績詳細'' as detail_id,
    ''VR1'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
    substring(equip ->> ''name'',1,25) as e3,
    equip ->> ''amount'' as e04,
    ''1'' as e5,
    equip ->> ''unit'' as e6,
    equip ->> ''unit'' as e7,
    '''' as e08,
    '''' as e09,
    ''21'' as e10,
    '''' as e11
 from
  ord_main ord
   cross join lateral
      json_array_elements (ord.rst_equip_info :: json) equip
    left outer join
      mst_equipment as meq
    on
      meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  equip->>''class_type'' in (''2'',''3'') and
  ord.ord_no = @ordNo

union

select --医材情報
     ''実績詳細'' as detail_id,
    ''VR1'',
    meq.in_hospital_cd_1 as e1,
     COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
    substring(equip ->> ''name'',1,25) as e3,
    equip ->> ''amount'' as e04,
    ''1'' as e5,
    equip ->> ''unit'' as e6,
    equip ->> ''unit'' as e7,
    '''' as e08,
    '''' as e09,
    ''22'' as e10,
    '''' as e11
 from
  ord_main ord
   cross join lateral
      json_array_elements (ord.rst_equip_info :: json) equip
    left outer join
      mst_equipment as meq
    on
      meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  equip->>''equip_type'' = ''0'' and
  equip->>''class_type'' not in (''2'',''3'') and
  ord.ord_no = @ordNo

union

select --透析液+補液情報
    ''実績詳細'' as detail_id,
    ''VI1'',
    mmd.in_hospital_cd_1 as e1,
    COALESCE(mmd.in_hospital_cd_2, ''VI1'') as e2,
    substring(mmd.medicine_name,1,25),--e3
    to_char(TO_NUMBER (COALESCE(ord.rst_cond_info->''17''->>''value'',''0''),''999999999.999'') + TO_NUMBER (COALESCE(ord.rst_cond_info->''20''->>''value'',''0''),''999999999.999''),''999999.999'') as e4,
    ''1'',--e5
    mmd.unit,--e6
    mmd.unit,--e7
    '''' as e08,
    '''' as e09,
    ''23'' as e10,
    '''' as e11
from
    ord_main ord
     left outer join
  mst_medicine as mmd
 on
  mmd.medicine_cd = TO_NUMBER (ord.rst_cond_info->''15''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --抗凝固剤初回
    ''実績詳細'' as detail_id,
    ''VGX'',
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_1 else  mmd.in_hospital_cd_1 end),--e1
    COALESCE((case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_2 else mmd.in_hospital_cd_2 end), ''VGX'') as e2,
    substring((case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.medicine_mix_name else  mmd.medicine_name end),1,25),--e3
    to_char(TO_NUMBER (COALESCE(ord.rst_cond_info->''26''->>''value'',''0''),''999999999.999''),''999999.999''),--e4
    ''1'',--e5
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e6
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e7
    '''' as e08,
    '''' as e09,
    ''24'' as e10,
    '''' as e11
from
    ord_main ord
     left outer join
  mst_medicine as mmd
 on
  mmd.medicine_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --抗凝固剤持続
    ''実績詳細'' as detail_id,
    ''VGY'',
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_1 else  mmd.in_hospital_cd_1 end),--e1
    COALESCE((case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_2 else mmd.in_hospital_cd_2 end), ''VGX'') as e2,
    substring((case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.medicine_mix_name else  mmd.medicine_name end),1,25),--e3
    to_char(TO_NUMBER (COALESCE(ord.rst_cond_info->''27''->>''value'',''0''),''999999999.999''),''999999.999''),--e4
    ''1'',--e5
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e6
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e7
    '''' as e08,
    '''' as e09,
    ''25'' as e10,
    '''' as e11
from
    ord_main ord
     left outer join
  mst_medicine as mmd
 on
  mmd.medicine_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --抗凝固剤TOTAL
    ''実績詳細'' as detail_id,
    ''VGZ'',
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_1 else  mmd.in_hospital_cd_1 end),--e1
    COALESCE((case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_2 else mmd.in_hospital_cd_2 end), ''VGX'') as e2,
    substring((case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.medicine_mix_name else  mmd.medicine_name end),1,25),--e3
    to_char(TO_NUMBER (COALESCE(ord.rst_cond_info->''26''->>''value'',''0''),''999999999.999'') + TO_NUMBER (COALESCE(ord.rst_cond_info->''28''->>''value'',''0''),''999999999.999''),''999999.999''),--e4
    ''1'',--e5
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e6
    (case ord.rst_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e7
    '''' as e08,
    '''' as e09,
    ''26'' as e10,
    '''' as e11
from
    ord_main ord
     left outer join
  mst_medicine as mmd
 on
  mmd.medicine_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
where
    ord.ord_no = @ordNo

union

select --血液流量情報
    ''実績詳細'' as detail_id,
    ''VK3'',
    ''99999'',--e1
     ''VK3'' ,--e2
    ''血液流量'',--e3
    to_char(TO_NUMBER (ord.rst_cond_info->''14''->>''value'',''999999999999''),''999999999.999'') as e04,--e4
    ''1'',--e5
    ''MLH'',--e6
    ''MLH'',--e7
    '''' as e08,
    '''' as e09,
    ''27'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo

union

select --透析液流量情報
    ''実績詳細'' as detail_id,
    ''VK4'',
    ''99999'',--e1
     ''VK4'' ,--e2
    ''透析液流量'',--e3
    to_char(TO_NUMBER (ord.rst_cond_info->''16''->>''value'',''999999999999''),''999999999.999'') as e04,--e4
    ''1'',--e5
    ''MLH'',--e6
    ''MLH'',--e7
    '''' as e08,
    '''' as e09,
    ''28'' as e10,
    '''' as e11
from
    ord_main ord
where
    ord.ord_no = @ordNo

union

select --抗凝固剤(算定分)
     ''実績詳細'' as detail_id,
    ''VO2'',
    mmd.in_hospital_cd_1,--e1
     COALESCE(mmd.in_hospital_cd_2, ''VO2'') as e2,
    substring(mmd.medicine_name,1,25),--e3
    (case mmxd->>''solvent'' when ''1'' then mmxd->>''amount'' else to_char((TO_NUMBER (COALESCE(ord.rst_cond_info->''26''->>''value'',''0''),''999999999.999'') + TO_NUMBER (COALESCE(ord.rst_cond_info->''28''->>''value'',''0''),''999999999.999'')) / mmx2.amount_unit * to_number(mmxd->>''amount'',''999999.999''),''999990.000'') end) as e04,--e4
    ''1'',--e5
    COALESCE(mmd.unit_second, mmd.unit) ,--e6
    COALESCE(mmd.unit_second, mmd.unit),--e7
    '''' as e08,
    '''' as e09,
    ''29'' as e10,
    '''' as e11
    from
      ord_main as ord
    left outer join
      mst_medicine_mix as mmx
     on
      mmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999''),
    mst_medicine_mix as mmx2
    cross join lateral
      json_array_elements (mmx2.mix_info :: json) mmxd
    left outer join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (mmxd ->> ''cd'',''999999999999'')
    where
      ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' and
      ord.ord_no = @ordNo

union

select --投与薬剤情報(通常)
     ''実績詳細'' as detail_id,
    ''VO2'',
    mmd.in_hospital_cd_1,--e1
     COALESCE(mmd.in_hospital_cd_2, ''VO2'') as e2,
    substring(medi ->> ''name'',1,25),--e3
    medi ->> ''amount'' as e04,--e4
    ''1'',--e5
    medi ->> ''unit'',--e6
    medi ->> ''unit'',--e7
    '''' as e08,
    '''' as e09,
    ''29'' as e10,
    '''' as e11
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
    left outer join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
      mst_procedure as mp
    on
      mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    where
      medi ->> ''effect_flg'' = ''1'' and
      medi ->> ''medicine_type'' = ''1'' and
      ord.ord_no = @ordNo
    --order by medi ->> ''effect_date'',medi ->> ''cd''

union

select --投与薬剤情報(調製)
     ''実績詳細'' as detail_id,
    ''VO2'',
    mmd.in_hospital_cd_1,--e1
     COALESCE(mmd.in_hospital_cd_2, ''VO2'') as e2,
    substring(mmd.medicine_name,1,25),--e3
    (case mmxd->>''solvent'' when ''1'' then mmxd->>''amount'' else to_char(to_number(medi ->> ''amount'',''999999.999'') / mmx2.amount_unit * to_number(mmxd->>''amount'',''999999.999''),''999990.000'') end) as e04,--e4
    ''1'',--e5
    COALESCE(mmd.unit_second, mmd.unit) ,--e6
    COALESCE(mmd.unit_second, mmd.unit),--e7
    '''' as e08,
    '''' as e09,
    ''29'' as e10,
    '''' as e11
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
    left outer join
      mst_procedure as mp
    on
      mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    left outer join
      mst_medicine_mix as mmx
     on
      mmx.medicine_mix_cd = TO_NUMBER (medi ->> ''cd'',''999999999999''),
    mst_medicine_mix as mmx2
    cross join lateral
      json_array_elements (mmx2.mix_info :: json) mmxd
    left outer join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (mmxd ->> ''cd'',''999999999999'')
    where
      medi ->> ''effect_flg'' = ''1'' and
      medi ->> ''medicine_type'' = ''2'' and
      ord.ord_no = @ordNo

union

select --処置薬剤情報
     ''実績詳細'' as detail_id,
    ''VO2'',
    mmd.in_hospital_cd_1,--e1
     COALESCE(mmd.in_hospital_cd_2, ''VO2'') as e2,
    substring(tmedi ->> ''treat_medicine_name'',1,25),--e3
    tmedi ->> ''amount'' as e04,--e4
    ''1'',--e5
    tmedi ->> ''unit'',--e6
    tmedi ->> ''unit'',--e7
    '''' as e08,
    '''' as e09,
    ''30'' as e10,
    '''' as e11
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) tmedi
    left outer join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (tmedi ->> ''treat_medicine_cd'',''999999999999'')
    left outer join
      mst_procedure as mp
    on
      mp.procedure_cd = TO_NUMBER (tmedi ->> ''procedure_cd'',''999999999999'')
    where
      ord.ord_no = @ordNo
    --order by tmedi ->> ''occur_date'',tmedi ->> ''treat_medicine_cd''

union

select --酸素情報
     ''実績詳細'' as detail_id,
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN ''OX1'' else ''OX2'' end),
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN ''99999'' else ''12345'' end),--e1
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN ''VO1'' else ''VO2'' end) as e2,
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN ''酸素手技'' else ''酸素量'' end),--e3
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN ''000000.000'' else to_char(to_number(oxy ->> ''oxygen_amount'',''999999.999''),''999999.999'') end) as e04,--e4
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN ''0'' else ''1'' end),--e5
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN '''' else ''L'' end),--e6
    (case COALESCE(oxy ->> ''oxygen_amount'',''end'') when ''end'' THEN '''' else ''L'' end),--e7
    '''' as e08,
    '''' as e09,
    ''31'' as e10,
    '''' as e11
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) oxy
    left outer join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (oxy ->> ''treat_medicine_cd'',''999999999999'')
    where
      oxy ->> ''treat_class'' = ''3'' and
      ord.ord_no = @ordNo

union

select --観察記録情報
     ''実績詳細'' as detail_id,
     ''COM'' ,
     (case split_part(split_part(soap ->> ''result_value'',''>'',2),''<'',1) when '''' then null else ''99999'' end) as e2,--e1
    (case row_number()over() % 4 when 1 then ''VC5'' when 2 then ''VC6'' when 3 then ''VC7'' else ''VC8'' end) as e2,
    substring(split_part(split_part(soap ->> ''result_value'',''>'',2),''<'',1),1,25),--e3
     ''000000.000''  as e04,--e4
     ''0'' ,--e5
     '''',--e6
     '''',--e7
    '''' as e08,
    '''' as e09,
    ''32'' as e10,
    '''' as e11
    from
      pat_event as pev,
      ord_main as ord
    cross join lateral
      json_array_elements (pev.result_params :: json) soap
    where
      pev.event_start_date = ord.treat_date and
      ord.pat_id= pev.pat_id and
      pev.use_type = 2 and
          json_array_length(pev.result_params :: json) = 4 and
      ord.ord_no = @ordNo

union

select --加算情報
    ''実績詳細'' as detail_id,
    ''VAB'' as sbt_key,
    mad.in_hospital_cd_1 as e01,--コード
    ''VAB'' as e02,
    substring(addi ->> ''name'',1,25) as e03,--名
    ''0000000.000'' as e04,
    ''0'' as e05,
    '''' as e06,
    '''' as e07,
    '''' as e08,
    '''' as e09,
    ''33'' as e10,
    '''' as e11
from
    ord_main ord
    cross join lateral
      json_array_elements (ord.addition_info :: json) addi
left outer join
  mst_addition as mad
 on
  mad.addition_cd = to_number(addi ->> ''cd'',''9999999999'')
where
    mad.addition_class  <> ''2'' and
    ord.ord_no = @ordNo

) all_cost

where 
 all_cost.e01 is not null
order by all_cost.e10,all_cost.e01
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）実績繰り返し部', '2020-04-24 19:15:25.57', '2020-04-28 12:15:29.486', NULL);
