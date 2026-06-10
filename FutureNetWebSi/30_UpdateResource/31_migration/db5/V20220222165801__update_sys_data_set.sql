delete from "ntss"."sys_data_set" where "sql_cd" = -103;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-103, 'select 
	all_cost.*
from
(select --ベッド情報
	''予約詳細'' as detail_id,
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
  mbd.bed_cd =ord.ind_bed_cd
where
	ord.ord_no = @ordNo

union

select --治療項目情報
	''予約詳細'' as detail_id,
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
  mtt.treatment_cd = ord.ind_treatment_cd
where
	ord.ord_no = @ordNo

union

select --透析開始時刻情報
	''予約詳細'' as detail_id,
	''VA6'' as sbt_key,
	''99999'' as e01,--治療コード
	''VA6'' as e02,
	 substring(ind_treat_start_time,1,25) as e03,
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
	''予約詳細'' as detail_id,
	''VA7'' as sbt_key,
	''99999'' as e01,--コード
	''VA7'' as e02,
	 to_char(to_timestamp(ord.treat_date || '' '' || substring(ord.ind_treat_start_time,1,2) || '':'' || substring(ord.ind_treat_start_time,3,2) || '':00'', ''YYYYMMDD HH24:MI:SS'') + (interval ''1minute'' * to_number(ord.ind_cond_info->''1''->>''value'',''999999'')) ,''HH24:MI'')   as e03,--項目名
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
	''予約詳細'' as detail_id,
	''VA8'' as sbt_key,
	''99999'' as e01,--コード
	''VA8'' as e02,
	RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999''),60),2) as e03,--項目名
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

select --目標体重情報
	''予約詳細'' as detail_id,
	''VF1'' as sbt_key,
	''99999'' as e01,--コード
	''VF1'' as e02,
	substring(ord.treat_date,1,25)  as e03,--項目名
	to_char(TO_NUMBER (ord.ind_cond_info -> ''3'' ->> ''value'',''999999999.999'') ,''999999.999'') as e04,
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
	''予約詳細'' as detail_id,
	''VF3'' as sbt_key,
	''99999'' as e01,--コード
	''VF3'' as e02,
	ord.treat_date  as e03,--項目名
	physical->>''dw''  as e04,
	''0'' as e05,
	'''' as e06,
	'''' as e07,
	'''' as e08,
	'''' as e09,
	''09'' as e10,
	'''' as e11
from
	ord_main ord,
 	pat_unique puq
	 cross join lateral
	json_array_elements (puq.physical_info :: json) physical
where
	ord.pat_id = puq.pat_id and
	physical->>''exam_date'' = (select max(physical2->>''exam_date'') from ord_main ord2,pat_unique puq2 cross join lateral
	json_array_elements (puq2.physical_info :: json) physical2 where 
	physical2->>''exam_date'' <= ord.treat_date and
	COALESCE(physical2->>''dw'' ,''ZERO'') <> ''ZERO'' and 
	ord.pat_id = puq2.pat_id ) and
	ord.ord_no = @ordNo 

union

select --VA情報
	''予約詳細'' as detail_id,
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
 	 mva.va_cd = TO_NUMBER (ord.ind_cond_info->''2''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --ダイアライザ情報
	''予約詳細'' as detail_id,
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
 	 mdz.dialyzer_cd = TO_NUMBER (ord.ind_cond_info->''5''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --医材内ダイアライザ情報
 	''予約詳細'' as detail_id,
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
      json_array_elements (ord.ind_equip_info :: json) equip
	left outer join
 	 mst_dialyzer as mdz
	on
 	 mdz.dialyzer_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  equip->>''equip_type'' = ''1'' and
  ord.ord_no = @ordNo

union

select --吸着器情報
	''予約詳細'' as detail_id,
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
 	 meq.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --1次膜情報
	''予約詳細'' as detail_id,
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
 	 meq.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --2次膜情報
	''予約詳細'' as detail_id,
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
 	 meq.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --A針情報
 	''予約詳細'' as detail_id,
	''VR1'',
	meq.in_hospital_cd_1 as e1,
	 COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
	substring(ord.ind_cond_info->''9''->>''value_name_1'',1,25) as e3,
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
   meq.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --V針情報
 	''予約詳細'' as detail_id,
	''VR1'',
	meq.in_hospital_cd_1 as e1,
	 COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
	substring(ord.ind_cond_info->''10''->>''value_name_1'',1,25) as e3,
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
   meq.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --SN針情報
 	''予約詳細'' as detail_id,
	''VR1'',
	meq.in_hospital_cd_1 as e1,
	 COALESCE(meq.in_hospital_cd_2, ''VR1'') as e2,
	substring(ord.ind_cond_info->''11''->>''value_name_1'',1,25) as e3,
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
   meq.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --医材内穿刺針情報
 	''予約詳細'' as detail_id,
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
      json_array_elements (ord.ind_equip_info :: json) equip
	left outer join
	  mst_equipment as meq
	on
	  meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  equip->>''class_type'' in (''2'',''3'') and
  ord.ord_no = @ordNo

union

select --医材情報
 	''予約詳細'' as detail_id,
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
      json_array_elements (ord.ind_equip_info :: json) equip
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
	''予約詳細'' as detail_id,
	''VI1'',
	mmd.in_hospital_cd_1 as e1,
	COALESCE(mmd.in_hospital_cd_2, ''VI1'') as e2,
	substring(mmd.medicine_name,1,25),--e3
	to_char(TO_NUMBER (COALESCE(ord.ind_cond_info->''17''->>''value'',''0''),''999999999.999'') + TO_NUMBER (COALESCE(ord.ind_cond_info->''20''->>''value'',''0''),''999999999.999''),''999999.999'') as e4,
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
  mmd.medicine_cd = TO_NUMBER (ord.ind_cond_info->''15''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --抗凝固剤初回
	''予約詳細'' as detail_id,
	''VGX'',
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_1 else  mmd.in_hospital_cd_1 end),--e1
	COALESCE((case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_2 else mmd.in_hospital_cd_2 end), ''VGX'') as e2,
	substring((case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.medicine_mix_name else  mmd.medicine_name end),1,25),--e3
	to_char(TO_NUMBER (COALESCE(ord.ind_cond_info->''26''->>''value'',''0''),''999999999.999''),''999999.999''),--e4
	''1'',--e5
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e6
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e7
	'''' as e08,
	'''' as e09,
	''24'' as e10,
	'''' as e11
from
	ord_main ord
	 left outer join
  mst_medicine as mmd
 on
  mmd.medicine_cd = TO_NUMBER (ord.ind_cond_info->''25''->>''value'',''999999999999'')
left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.ind_cond_info->''25''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --抗凝固剤持続
	''予約詳細'' as detail_id,
	''VGY'',
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_1 else  mmd.in_hospital_cd_1 end),--e1
	COALESCE((case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_2 else mmd.in_hospital_cd_2 end), ''VGX'') as e2,
	substring((case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.medicine_mix_name else  mmd.medicine_name end),1,25),--e3
	to_char(TO_NUMBER (COALESCE(ord.rst_cond_info->''27''->>''value'',''0''),''999999999.999''),''999999.999''),--e4
	''1'',--e5
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e6
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e7
	'''' as e08,
	'''' as e09,
	''25'' as e10,
	'''' as e11
from
	ord_main ord
	 left outer join
  mst_medicine as mmd
 on
  mmd.medicine_cd = TO_NUMBER (ord.ind_cond_info->''25''->>''value'',''999999999999'')
left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.ind_cond_info->''25''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --抗凝固剤TOTAL
	''予約詳細'' as detail_id,
	''VGZ'',
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_1 else  mmd.in_hospital_cd_1 end),--e1
	COALESCE((case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.in_hospital_cd_2 else mmd.in_hospital_cd_2 end), ''VGX'') as e2,
	substring((case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.medicine_mix_name else  mmd.medicine_name end),1,25),--e3
	to_char(TO_NUMBER (COALESCE(ord.ind_cond_info->''26''->>''value'',''0''),''999999999.999'') + TO_NUMBER (COALESCE(ord.ind_cond_info->''28''->>''value'',''0''),''999999999.999''),''999999.999''),--e4
	''1'',--e5
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e6
	(case ord.ind_cond_info->''25''->>''medicine_type'' when ''2'' then mmx.unit else mmd.unit end),--e7
	'''' as e08,
	'''' as e09,
	''26'' as e10,
	'''' as e11
from
	ord_main ord
	 left outer join
  mst_medicine as mmd
 on
  mmd.medicine_cd = TO_NUMBER (ord.ind_cond_info->''25''->>''value'',''999999999999'')
left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.ind_cond_info->''25''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --血液流量情報
	''予約詳細'' as detail_id,
	''VK3'',
	''99999'',--e1
	 ''VK3'' ,--e2
	''血液流量'',--e3
	to_char(TO_NUMBER (ord.ind_cond_info->''14''->>''value'',''999999999999''),''999999999.999'') as e04,--e4
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
	''予約詳細'' as detail_id,
	''VK4'',
	''99999'',--e1
	 ''VK4'' ,--e2
	''透析液流量'',--e3
	to_char(TO_NUMBER (ord.ind_cond_info->''16''->>''value'',''999999999999''),''999999999.999'') as e04,--e4
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
	 ''予約詳細'' as detail_id,
	''VO2'',
	mmd.in_hospital_cd_1,--e1
	 COALESCE(mmd.in_hospital_cd_2, ''VO2'') as e2,
	substring(mmd.medicine_name,1,25),--e3
	(case mmxd->>''solvent'' when ''1'' then mmxd->>''amount'' else to_char((TO_NUMBER (COALESCE(ord.ind_cond_info->''26''->>''value'',''0''),''999999999.999'') + TO_NUMBER (COALESCE(ord.ind_cond_info->''28''->>''value'',''0''),''999999999.999'')) / mmx2.amount_unit * to_number(mmxd->>''amount'',''999999.999''),''999990.000'') end) as e04,--e4
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
	  mmx.medicine_mix_cd = TO_NUMBER (ord.ind_cond_info->''25''->>''value'',''999999999999''),
	mst_medicine_mix as mmx2
	cross join lateral
      json_array_elements (mmx2.mix_info :: json) mmxd
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (mmxd ->> ''cd'',''999999999999'')
    where
	  ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' and
      ord.ord_no = @ordNo

union

select --投与薬剤情報(通常)
	 ''予約詳細'' as detail_id,
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
      json_array_elements (ord.ind_medi_info :: json) medi
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    where
	  medi ->> ''medicine_type'' = ''1'' and
      ord.ord_no = @ordNo

union

select --投与薬剤情報(調製)
	 ''予約詳細'' as detail_id,
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
      json_array_elements (ord.ind_medi_info :: json) medi
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
	  medi ->> ''medicine_type'' = ''2'' and
      ord.ord_no = @ordNo
) all_cost

where 
 all_cost.e01 is not null
order by all_cost.e10,all_cost.e01
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通：透析予約繰り返し部', '2020-05-08 16:22:41', CURRENT_TIMESTAMP, NULL);
