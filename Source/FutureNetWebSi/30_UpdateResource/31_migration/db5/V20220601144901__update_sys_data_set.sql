DELETE FROM sys_data_set WHERE sql_cd in (-18,-19,-497);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-497, 'SELECT
  ''薬剤'' AS detail_id,
  all_cost.e01 AS item_cd,
  (sum(all_cost.e04::float)*100)::INTEGER AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
	(select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO'' 
    AND ord.ord_no =@ordNo  
  UNION
	SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
	   meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
	  and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''nkknkk'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
		 meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
		and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''nkknkk'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
	  and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''nkknkk'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
     SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    COALESCE (
      (
      CASE
          mmxd ->> ''solvent'' 
          WHEN ''1'' THEN
            to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
          ELSE 
	    CASE WHEN mmx.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
            THEN ''0.00'' 
            ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
            END 
        END 
        ),
        ''0.00'' 
      ) AS e04,
      COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
      AND ord.ord_no = @ordNo 
  UNION
      SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      ord.ord_no = @ordNo ) as all_cost1 where all_cost1.e01 = all_cost.e01) count
FROM
  (
	SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
	   meq.unit AS e05,
    ''1'' AS e06,
	  ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
	  and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''nkknkk'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
	   meq.unit AS e05,
    ''1'' AS e06,
	  ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo  
		and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''nkknkk'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
	   meq.unit AS e05,
    ''1'' AS e06,
	  ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
	  and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''nkknkk'' 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
	UNION
    SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO'' 
    AND ord.ord_no =@ordNo 
  UNION
     SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    COALESCE (
      (
      CASE
          mmxd ->> ''solvent'' 
          WHEN ''1'' THEN
            to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
          ELSE 
	    CASE WHEN mmx.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
            THEN ''0.00'' 
            ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
            END 
        END 
        ),
        ''0.00'' 
      ) AS e04,
      COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
      AND ord.ord_no = @ordNo 
  UNION
      SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      ord.ord_no = @ordNo 
    ) all_cost 
WHERE
  all_cost.e01 IS NOT NULL
	group by all_cost.e01,all_cost.e05
	ORDER BY all_cost.e01
	limit 135
', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤の投薬回数のSQL)', '2022-05-09 05:52:21.853', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-18, 'select 	
''指示薬剤''::TEXT as detail_id,
		a.medi_cd1
		,sum(medi_amount::Float) as  medi_amount
		,COUNT(medi_cd1) as medi_back
		,a.medi_unit		
		from 
		(select
	  ''指示薬剤'' as detail_id,
		medc.in_hospital_cd_1 as medi_class_cd,
		medc.class_name as medi_class_type,
		mmd.medicine_name  as medi_name,
		medi ->> ''amount'' as medi_amount,
		mmd.unit as medi_unit,
	  (case when mmd.unit_second is null then to_number(medi ->> ''amount'',''FM99999.99'') else (case  when mmd.is_exchange = ''0'' then to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second   when mmd.is_exchange = ''1'' then trunc( to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second + 0.9 ,0) when mmd.is_exchange = ''2'' then 1 else  to_number(medi ->> ''amount'',''FM99999.99'') end) end) as res_amount,
		mmd.unit_second as res_unit,
		medi ->> ''timing_name'' as medi_timing_name,
		mp.pricedure_name as procedure_name,
		mp.in_hospital_cd_a1 as procedure_cd1,
		mmd.in_hospital_cd_1 as medi_cd1,
		mmd.in_hospital_cd_2 as medi_cd2,
		mmd.in_hospital_cd_3 as medi_cd3,
		mmd.in_hospital_cd_4 as medi_cd4
    from
		mst_medicine_class as medc,
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
		mmd.class_cd = medc.class_cd and 
		mmd.in_hospital_cd_1 is not null and
	ord.ord_no =  @ordNo)  as a 
	GROUP BY a.medi_cd1,a.medi_unit	
  limit 135	', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）投与薬剤コード', '2020-04-10 15:28:38.712', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-19, 'select 
 ''指示医材'' as detail_id,
 row_number() over() as equip_no,
 all_equip.class as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.name as name,
 all_equip.amount as amount,
 all_equip.unit as unit
from
(select
  ''吸着器'' as class,
  --ord.ind_cond_info->''6''->>''value_name_1'' as name,
  meqad.equipment_name as name,
  trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
   trim(meqad.in_hospital_cd_2) as cd2,
   trim(meqad.in_hospital_cd_3) as cd3,
   trim(meqad.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqad.unit
from
  ord_main as ord
left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.ind_cond_info->''6''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
  ''1次膜'' as class,
  --ord.ind_cond_info->''7''->>''value_name_1'' as primary_film,
  meqpr.equipment_name as primary_film,
  trim(meqpr.in_hospital_cd_1) as pr_cd1,--1次膜コード１
   trim(meqpr.in_hospital_cd_2) as pr_cd2,
   trim(meqpr.in_hospital_cd_3) as pr_cd3,
   trim(meqpr.in_hospital_cd_4) as pr_cd4,
  ''1'' as amount,
  meqpr.unit
 from
  ord_main as ord
  left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
  where
  ord.ord_no = @ordNo
 union
 select
  ''2次膜'' as class,
  --ord.ind_cond_info->''8''->>''value_name_1'' as secondary_film,
  meqse.equipment_name as secondary_film,
  trim(meqse.in_hospital_cd_1) as se_cd1,--2次膜コード１
   trim(meqse.in_hospital_cd_2) as se_cd2,
   trim(meqse.in_hospital_cd_3) as se_cd3,
   trim(meqse.in_hospital_cd_4) as se_cd4,
  ''1'' as amount,
  meqse.unit
  from
  ord_main as ord
  left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
  where
  ord.ord_no = @ordNo
 union
 select
  ''穿刺針A'' as class,
  --ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  meqa.equipment_name as puncture_needle_a,
  trim(meqa.in_hospital_cd_1) as a_cd1,--穿刺針Aコード１
   trim(meqa.in_hospital_cd_2) as a_cd2,
   trim(meqa.in_hospital_cd_3) as a_cd3,
   trim(meqa.in_hospital_cd_4) as a_cd4,
  ''1'' as amount,
  meqa.unit
 from
  ord_main ord
   left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo
 union
 select
  ''穿刺針V'' as class,
  --ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  meqv.equipment_name as puncture_needle_v,
  trim(meqv.in_hospital_cd_1) as v_cd1,--穿刺針Vコード１
   trim(meqv.in_hospital_cd_2) as v_cd2,
   trim(meqv.in_hospital_cd_3) as v_cd3,
   trim(meqv.in_hospital_cd_4) as v_cd4,
  ''1'' as amount,
  meqv.unit
  from
  ord_main ord
   left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo
 union
 select
  ''穿刺針SN'' as class,
  --ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  meqsn.equipment_name as puncture_needle_sn,
  trim(meqsn.in_hospital_cd_1) as sn_cd1,--穿刺針SNコード１
   trim(meqsn.in_hospital_cd_2) as sn_cd2,
   trim(meqsn.in_hospital_cd_3) as sn_cd3,
   trim(meqsn.in_hospital_cd_4) as sn_cd4,
  ''1'' as amount,
  meqsn.unit
   from
  ord_main ord
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
  ''血液回路'' as class,
  --ord.ind_cond_info->''13''->>''value'' as blood_circuit,
  meqbc.equipment_name as blood_circuit,
  trim(meqbc.in_hospital_cd_1) as bc_cd1, --血液回路コード１
  trim(meqbc.in_hospital_cd_2) as bc_cd2,
  trim(meqbc.in_hospital_cd_3) as bc_cd3,
  trim(meqbc.in_hospital_cd_4) as bc_cd4,
  ''1'' as amount,
  meqbc.unit
from
  ord_main as ord
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.ind_cond_info->''13''->>''value'',''999999999999'')
where
 ord.ord_no = @ordNo
union
select
   --equip ->> ''class_type'' as equip_class_type,
   --equip ->> ''name'' as equip_name,
   meqc.class_name  as equip_class_type,
   meq.equipment_name as equip_name,
   trim(meq.in_hospital_cd_1) as equip_cd1,
   trim(meq.in_hospital_cd_2) as equip_cd2,
   trim(meq.in_hospital_cd_3) as equip_cd3,
   trim(meq.in_hospital_cd_4) as equip_cd4,
   equip ->> ''amount'' as equip_amount,
   meq.unit as equip_unit
    from
      mst_equipment_class as meqc,
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_equip_info :: json) equip
 left outer join
   mst_equipment as meq
 on
   meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
    where
      meq.class_cd = meqc.class_cd and
      ord.ord_no = @ordNo) all_equip
where
 all_equip.cd1 is not null
 limit 108', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）指示医材コード', '2020-04-10 16:42:55.734', CURRENT_TIMESTAMP, NULL);
