delete from "sys_data_set" where "sql_cd" in (-99989,-500001,-307,-306,-305,-13);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-500001, ' select
 hosp_pat_id,
 lpad(hosp_pat_id, 12, ''0'') AS hosp_pat_id12,
 CASE WHEN LENGTH(hosp_pat_id) >= 8 THEN hosp_pat_id ELSE LPAD(hosp_pat_id, 8, ''0'') END AS hosp_pat_id8,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 pat_birthday as pat_birthday8,
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
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date
 from
 pat_personal_main
 where
 is_del = ''0''
 and
 pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'SSI 透析レポート', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99989, 'SELECT
  ''DIALYSISPLAN_'' || 
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISSMS_'') ||
  CASE WHEN LENGTH(journal.hosp_pat_id) >= 8 THEN journal.hosp_pat_id ELSE LPAD(journal.hosp_pat_id, 8, ''0'') END ||
  ''.xml'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', NULL, 'SSI 透析予約[送信]ファイル名取得', '2021-04-20 09:19:08.001', '2021-04-20 09:19:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-307, 'select
  ''透析条件'' as detail_id
  , split_part(cond_arr.cond_row, ''-@-'', 1) as e01
  , split_part(cond_arr.cond_row, ''-@-'', 2) as e02
  , split_part(cond_arr.cond_row, ''-@-'', 3) as e03
  , split_part(cond_arr.cond_row, ''-@-'', 4) as e04
  , split_part(cond_arr.cond_row, ''-@-'', 5) as e05 
from
  ( 
    select
      regexp_split_to_table( 
        array_to_string( 
          array [
            concat(''001-@-透析開始時刻-@-'',ord.ind_treat_start_time ,''-@--@-'') ,
            concat(''002-@-透析時間-@-'',ord.ind_cond_info->''1''->>''value'' ,''-@--@-分'') ,
            concat(''003-@-VA-@-'',trim(mva.in_hospital_cd_1),''-@-'',ord.ind_cond_info->''2''->>''value_name_1'',''-@-'') ,
            concat(''004-@-DW-@-'',physical->>''dw'',''-@-'',''-@-'',''kg'') ,
            concat(''005-@-目標体重-@-'',ord.ind_cond_info->''3''->>''value'',''-@-'',''-@-'',''kg'') ,
            concat(''006-@-治療方法-@-'',mtt.in_hospital_cd_a1,''-@-'',mtt.treatment_name,''-@-'') ,
            concat(''007-@-除水量制限-@-'',to_char(to_number(ord.ind_cond_info->''4''->>''value'',''FM99.99''),''FM90.99''),''-@-'',''-@-'',''L''),
            concat(''008-@-ダイアライザー-@-'',trim(mdr.in_hospital_cd_1),''-@-'',ord.ind_cond_info->''5''->>''value_name_1'',''-@-''),
            concat(''009-@-吸着カラム-@-'',trim(meqad.in_hospital_cd_1),''-@-'',ord.ind_cond_info->''6''->>''value_name_1'',''-@-''),
            concat(''010-@-血流量-@-'',ord.ind_cond_info->''14''->>''value'',''-@-'',''-@-'',''mL/min''),
            concat(''011-@-抗凝固剤-@-'',(case ord.ind_cond_info->''25''->>''medicine_type'' when ''1'' then med25.in_hospital_cd_1 when ''2'' then mmx.in_hospital_cd_1 end) ,''-@-'',ord.ind_cond_info->''25''->>''value_name_1'',''-@-'') ,
            concat(''012-@-抗凝固剤ワンショット量-@-'',ord.ind_cond_info->''26''->>''value'',''-@-'',''-@-'',ord.ind_cond_info->''26''->>''unit''),
            concat(''013-@-抗凝固剤持続速度-@-'',ord.ind_cond_info->''27''->>''value'',''-@-'',''-@-'',ord.ind_cond_info->''27''->>''unit''),
            concat(''014-@-抗凝固剤持続総量-@-'',ord.ind_cond_info->''28''->>''value'',''-@-'',''-@-'',ord.ind_cond_info->''28''->>''unit''),
            concat(''015-@-IP使用選択-@-'',ord.ind_cond_info->''29''->>''value'',''-@-'',(case ord.ind_cond_info->''29''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end) ,''-@-''),
            concat(''016-@-IPワンショット量-@-'',ord.ind_cond_info->''31''->>''value'',''-@-'',''-@-'',''mL'') ,
            concat(''017-@-IP速度-@-'',ord.ind_cond_info->''32''->>''value'',''-@-'',''-@-'',''“mL/h''),
            concat(''018-@-透析液-@-'',(case ord.ind_cond_info->''15''->>''medicine_type'' when ''1'' then trim(med15.in_hospital_cd_1) when ''2'' then trim(mmmx.in_hospital_cd_1) end) ,''-@-'',ord.ind_cond_info->''15''->>''value_name_1'',''-@-'') ,
            concat(''019-@-透析液流量-@-'',ord.ind_cond_info->''16''->>''value'',''-@-'',''-@-'',''mL/min'') ,
            concat(''020-@-透析液量-@-'',ord.ind_cond_info->''17''->>''value'',''-@-'',''-@-'',ord.ind_cond_info->''17''->>''unit'') ,
            concat(''021-@-透析液温度-@-'',ord.ind_cond_info->''18''->>''value'',''-@-'',''-@-'',''℃'') ,
            concat(''022-@-補液-@-'', (case ord.ind_cond_info->''19''->>''medicine_type'' when ''1'' then med19.in_hospital_cd_1 when ''2'' then mmmmx.in_hospital_cd_1 end),''-@-'',ord.ind_cond_info->''19''->>''value_name_1'',''-@-'') ,
            concat(''023-@-補液量-@-'',ord.ind_cond_info->''20''->>''value'',''-@-'',''-@-'',''L'') ,
            concat(''024-@-補液選択-@-'',ord.ind_cond_info->''21''->>''value'',''-@-'',(case ord.ind_cond_info->''21''->>''value'' when ''1'' then ''前補液'' when ''0'' then ''後補液'' else null end),''-@-'') ,
            concat(''025-@-補液温度-@-'',ord.ind_cond_info->''23''->>''value'',''-@-'',''-@-'',''℃'') ,
            concat(''029-@-シングルニードル電源-@-'',ord.ind_cond_info->''12''->>''value'',''-@-'',(case ord.ind_cond_info->''12''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-'') ,
            concat(''030-@-補液使用数-@-'',ord.ind_cond_info->''22''->>''value'',''-@-'',''-@-'',ord.ind_cond_info->''22''->>''unit'') ,
            concat(''031-@-IPスタート-@-'',ord.ind_cond_info->''30''->>''value'',''-@-'',(case ord.ind_cond_info->''30''->>''value'' when ''0'' then ''手動'' when ''1'' then ''自動'' else null end),''-@-''),
            concat(''032-@-自動ワンショット-@-'',ord.ind_cond_info->''34''->>''value'',''-@-'',(case ord.ind_cond_info->''34''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-''),
            concat(''033-@-IP電源自動切り-@-'',ord.ind_cond_info->''35''->>''value'',''-@-'',(case ord.ind_cond_info->''35''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
            concat(''034-@-IP電源自動切り時間-@-'',ord.ind_cond_info->''36''->>''value'',''-@-'',''-@-'',''分'') ,
            concat(''035-@-IP電源OKモニタ切り-@-'',ord.ind_cond_info->''37''->>''value'',''-@-'',(case ord.ind_cond_info->''37''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
            concat(''036-@-IP電源OKモニタ切り時間-@-'',ord.ind_cond_info->''38''->>''value'',''-@-'',''-@-'',''分''),
            concat(''037-@-IP速度最大値-@-'',ord.ind_cond_info->''33''->>''value'',''-@-'',''-@-'',''mL/h''),
            concat(''038-@-補液速度-@-'',ord.ind_cond_info->''24''->>''value'',''-@-'',''-@-'',''L/h''),
            concat(''039-@-1次膜-@-'',meqpr.in_hospital_cd_1,''-@-'',ord.ind_cond_info->''7''->>''value_name_1'',''-@-'') ,
            concat(''040-@-2次膜-@-'',meqse.in_hospital_cd_1,''-@-'',ord.ind_cond_info->''8''->>''value_name_1'',''-@-'')
          ]
          , ''-@@-''
        ) 
        , ''-@@-''
      ) as cond_row 
    from
      ord_main as ord 
      left outer join mst_equipment as meqa 
        on meqa.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqv 
        on meqv.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqsn 
        on meqsn.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqad 
        on meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqpr 
        on meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqbc 
        on meqbc.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqse 
        on meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine as med15 
        on med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine as med19 
        on med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine as med25 
        on med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_treatment as mtt 
        on mtt.treatment_cd = ord.ind_treatment_cd 
      left outer join mst_dialyzer as mdr 
        on mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_va as mva 
        on mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_bed as mbd 
        on mbd.bed_cd = ord.ind_bed_cd 
-- left outer join
--  mst_course as mcs
-- on
--  mcs.course_cd = ord.ind_course_cd
-- left outer join
--  mst_ward as mwd
-- on
--  mwd.ward_cd = ord.ind_ward_cd
      left outer join mst_medicine_mix as mmx 
        on mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine_mix as mmmx 
        on mmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine_mix as mmmmx 
        on mmmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
      left outer join pat_unique as puq 
        on puq.pat_id = ord.pat_id 
      cross join lateral json_array_elements(puq.physical_info ::json) physical 
    where
      physical ->> ''exam_date'' = ( 
        select
          max(physical2 ->> ''exam_date'') 
        from
          ord_main ord2
          , pat_unique puq2 
          cross join lateral json_array_elements(puq2.physical_info ::json) physical2 
        where
          TO_CHAR(CAST(physical2 ->> ''exam_date'' AS TIMESTAMP), ''YYYYMMDD'') <= ord.treat_date
          and COALESCE(physical2 ->> ''dw'', ''ZERO'') <> ''ZERO'' 
          and ord.pat_id = puq2.pat_id
      ) 
      and ord.ord_no = @ordNo
  ) cond_arr 
where
  length(split_part(cond_arr.cond_row, ''-@-'', 3)) > 0', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'SSI予約）条件繰り返し部', '2020-05-25 10:29:43.001', '2020-05-25 10:29:50', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-306, 'SELECT
  cost_fin.*
  , TO_CHAR(ROW_NUMBER() OVER (), ''FM0000'') AS cost_no 
FROM
  ( 
    SELECT
      all_cost.* 
    FROM
      ( 
        SELECT
          --投与薬剤情報(通常)
          ''投与薬剤'' AS detail_id
          , mmd.in_hospital_cd_1 AS e01
          , mmd.medicine_name AS e02
          , mclass.class_name AS e03
          , TO_CHAR( TO_NUMBER(medi ->> ''amount'', ''FM99999.99''), ''FM99990.99'') AS e04
          , medi ->> ''unit'' AS e05
          , mp.in_hospital_cd_a1 AS e06
          , mp.pricedure_name AS e07 
        FROM
          ord_main AS ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) medi 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_procedure AS mp 
            ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_medicine_class AS mclass 
            ON mclass.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
        WHERE
          medi ->> ''medicine_type'' = ''1'' 
          AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --投与薬剤情報(調製)
          ''投与薬剤'' AS detail_id
          , mmd.in_hospital_cd_1 AS e1
          , mmd.medicine_name AS e2
          , mmdc.class_name AS e03
          , COALESCE( 
            ( 
              CASE mmxd ->> ''solvent'' 
                WHEN ''1'' THEN TO_CHAR( TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99''), ''99990.99'') 
                ELSE ( CASE WHEN (mmx2.amount_unit * TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99'')) = 0 THEN ''0.00''
                       ELSE TO_CHAR( TO_NUMBER(medi ->> ''amount'', ''FM99999.99'') / mmx2.amount_unit * TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99''), ''FM99990.99'') 
                       END
                     )
                END
            ) 
            , ''0.00''
          ) AS e04
          , COALESCE(mmd.unit_second, mmd.unit) AS e05
          , mp.in_hospital_cd_a1 AS e06
          , mp.pricedure_name AS e07 
        FROM
          ord_main AS ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) medi 
          LEFT OUTER JOIN mst_procedure AS mp 
            ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_medicine_mix AS mmx 
            ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'')
          , mst_medicine_mix AS mmx2 
          CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_medicine_class AS mmdc 
            ON mmdc.class_cd = mmd.class_cd 
        WHERE
          medi ->> ''medicine_type'' = ''2'' 
          AND ord.ord_no = @ordNo
      ) all_cost 
    WHERE
      all_cost.e01 IS NOT NULL
  ) cost_fin 
ORDER BY
  cost_no ASC', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'SSI予約）薬剤繰り返し部', '2020-05-25 10:28:20.001', '2020-05-25 10:28:26.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-305, 'SELECT
  cost_fin.*
  , TO_CHAR(ROW_NUMBER() OVER (), ''FM0000'') AS cost_no 
FROM
  ( 
    SELECT
      all_cost.* 
    FROM
      ( 
        SELECT
          --血液回路情報
          ''血液回路'' AS detail_id
          , meq.in_hospital_cd_1 AS e01
          , meq.equipment_name AS e02
          , ''血液回路'' AS e03
          , ''0'' AS e04
          , ''1'' AS e05
          , meq.unit AS e06 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''13'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --A針情報
          ''穿刺針'' AS detail_id
          , meq.in_hospital_cd_1 AS e01
          , meq.equipment_name AS e02
          , ''A針'' AS e03
          , ''1'' AS e04
          , ''1'' AS e05
          , meq.unit AS e06 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''9'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --V針情報
          ''穿刺針'' AS detail_id
          , meq.in_hospital_cd_1 AS e01
          , meq.equipment_name AS e02
          , ''V針'' AS e03
          , ''2'' AS e04
          , ''1'' AS e05
          , meq.unit AS e06 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''10'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --SN針情報
          ''穿刺針'' AS detail_id
          , meq.in_hospital_cd_1 AS e01
          , meq.equipment_name AS e02
          , ''SN針'' AS e03
          , ''3'' AS e04
          , ''1'' AS e05
          , meq.unit AS e06 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''11'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --医材内穿刺針情報
          ''穿刺針'' AS detail_id
          , meq.in_hospital_cd_1 AS e01
          , meq.equipment_name AS e02
          , ''穿刺針'' AS e03
          , ''0'' AS e04
          , equip ->> ''amount'' AS e05
          , equip ->> ''unit'' AS e06 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''class_type'' IN (''2'', ''3'') 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --医材情報
          ''医材'' AS detail_id
          , meq.in_hospital_cd_1 AS e01
          , meq.equipment_name AS e02
          , ''医材'' AS e03
          , ''0'' AS e04
          , equip ->> ''amount'' AS e05
          , equip ->> ''unit'' AS e06 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''equip_type'' = ''0'' 
          AND equip ->> ''class_type'' NOT IN (''2'', ''3'') 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --吸着カラム情報
          ''医材'' AS detail_id
          , meq.in_hospital_cd_1 AS e01
          , meq.equipment_name AS e02
          , ''吸着カラム'' AS e03
          , ''0'' AS e04
          , ''1'' AS e05
          , meq.unit AS e06 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''6'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
      ) all_cost 
    WHERE
      all_cost.e01 IS NOT NULL 
    ORDER BY
      all_cost.e04 ASC, all_cost.e01 ASC
  ) cost_fin 
ORDER BY
  cost_no ASC', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'SSI予約）医材繰り返し部', '2020-05-25 10:26:47', '2020-05-25 10:26:53', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-13, 'SELECT
  ord.treat_date AS dialysis_date,
  ord.facility_cd AS facility_cd,
  COALESCE ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), '''' ) AS ind_name,
  COALESCE ( LEFT ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), 5 ), '''' ) AS ind_name10,
  COALESCE ( ord.ind_treat_start_time, '''' ) AS start_time,
  COALESCE ( mkr.in_hospital_cd_1, '''' ) AS kur_cd1,
  COALESCE ( mkr.kur_name, '''' ) AS kur_name,
  COALESCE ( mbd.bed_cd, 0 ) AS bed_cd,
  COALESCE ( mbd.in_hospital_cd_1, '''' ) AS bed_cd1,
  COALESCE ( mbd.bed_name, '''' ) AS bed_name,
  COALESCE ( mtt.treatment_name, '''' ) AS treatment_name,
  COALESCE ( mtt.in_hospital_cd_a1, '''' ) AS treatment_cd,
  COALESCE ( ord.ind_dw, 0 ) AS dw,
  TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) AS dialysis_time_m,
  COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    '''' 
  ) AS treatment_time,
  COALESCE ( ord.rst_cond_info -> ''1'' ->> ''value'', '''' ) AS treatment_time_m,--追加
  COALESCE ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''' ) AS va,
  COALESCE ( SUBSTRING ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', 1, 3 ), '''' ) AS va3,
  COALESCE ( mva.in_hospital_cd_1, '''' ) AS va_cd1,
  COALESCE (
    ( CASE mva.va_direct WHEN ''0'' THEN ''右'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''両方'' WHEN ''3'' THEN ''無'' ELSE''不明'' END ),
    '''' 
  ) AS va_direct,
  COALESCE ( ord.ind_cond_info -> ''3'' ->> ''value'', '''' ) AS target_weight,
  COALESCE ( ord.ind_cond_info -> ''4'' ->> ''value'', '''' ) AS water_removal_amount_limit,
--ord.ind_cond_info->''5''->>''value_name_1'' as dialyzer,
  COALESCE ( mdr.model_number, '''' ) AS dialyzer,
--ord.ind_cond_info->''5''->>''value'' as dialyzer_cd,
  COALESCE ( mdr.in_hospital_cd_1, '''' ) AS dialyzer_cd1,
  COALESCE ( ord.ind_cond_info -> ''6'' ->> ''value_name_1'', '''' ) AS adsorption_column,
  COALESCE ( meqad.in_hospital_cd_1, '''' ) AS ad_cd1,
  COALESCE ( ord.ind_cond_info -> ''7'' ->> ''value_name_1'', '''' ) AS primary_film,
  COALESCE ( meqpr.in_hospital_cd_1, '''' ) AS pr_cd1,
  COALESCE ( ord.ind_cond_info -> ''8'' ->> ''value_name_1'', '''' ) AS secondary_film,
  COALESCE ( meqse.in_hospital_cd_1, '''' ) AS se_cd1,
--ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  COALESCE ( meqa.equipment_name, '''' ) AS puncture_needle_a,
  COALESCE ( meqa.in_hospital_cd_1, '''' ) AS a_cd1,
--ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  COALESCE ( meqv.equipment_name, '''' ) AS puncture_needle_v,
  COALESCE ( meqv.in_hospital_cd_1, '''' ) AS v_cd1,
--ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  COALESCE ( meqsn.equipment_name, '''' ) AS puncture_needle_sn,
  COALESCE ( meqsn.in_hospital_cd_1, '''' ) AS sn_cd1,
  COALESCE ( ( CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''' ) AS single_needle,
  COALESCE ( ord.ind_cond_info -> ''13'' ->> ''value'', '''' ) AS blood_circuit,
  COALESCE ( meqbc.in_hospital_cd_1, '''' ) AS bc_cd1,
  COALESCE ( ord.ind_cond_info -> ''14'' ->> ''value'', '''' ) AS blood_flow,
--ord.ind_cond_info->''15''->>''value_name_1'' as dialysate,
  COALESCE ( med15.medicine_name, '''' ) AS dialysate,
  COALESCE ( med15.in_hospital_cd_1, '''' ) AS dialysate_cd1,
  COALESCE ( ord.ind_cond_info -> ''16'' ->> ''value'', '''' ) AS dialysate_flow_rate,
  COALESCE ( ord.ind_cond_info -> ''17'' ->> ''value'', '''' ) AS dialysate_amount,
--ord.ind_cond_info->''17''->>''unit'' as dialysate_amount_unit,
  COALESCE ( med15.unit, '''' ) AS dialysate_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''18'' ->> ''value'', '''' ) AS dialysate_temperature,
--ord.ind_cond_info->''19''->>''value_name_1'' as fluid_replacement,
  COALESCE ( med19.medicine_name, '''' ) AS fluid_replacement,
  COALESCE ( med19.in_hospital_cd_1, '''' ) AS ds_cd1,
  COALESCE ( ord.ind_cond_info -> ''20'' ->> ''value'', '''' ) AS fluid_replacement_amount,
  COALESCE ( ( CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''' ) AS fluid_replacement_timing,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''value'', '''' ) AS fluid_replacement_use_count,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''unit'', '''' ) AS fluid_replacement_use_count_unit,
  COALESCE ( ord.ind_cond_info -> ''23'' ->> ''value'', '''' ) AS fluid_replacement_temperature,
  COALESCE ( ord.ind_cond_info -> ''24'' ->> ''value'', '''' ) AS fluid_replacement_speed,
--ord.ind_cond_info->''25''->>''value_name_1'' as anti_coagulant,
  COALESCE ( med25.medicine_name, '''' ) AS anti_coagulant,
  COALESCE ( med25.in_hospital_cd_1, '''' ) AS anti_coagulant_cd1,
  COALESCE ( ord.ind_cond_info -> ''26'' ->> ''value'', '''' ) AS anti_coagulant_one_shot_amount,
--ord.ind_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
  COALESCE ( med25.unit, '''' ) AS anti_coagulant_one_shot_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''value'', '''' ) AS anti_coagulant_sustained_speed,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_speed_unit,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''value'', '''' ) AS anti_coagulant_sustained_amount,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_amount_unit,
  COALESCE (
    TO_NUMBER( ord.ind_cond_info -> ''26'' ->> ''value'', ''999999999999'' ) + TO_NUMBER( ord.ind_cond_info -> ''28'' ->> ''value'', ''999999999999'' ),
    0 
  ) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE ( ( CASE ord.ind_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS ip,
  COALESCE ( ( CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''' ) AS ip_start,
  COALESCE ( ord.ind_cond_info -> ''31'' ->> ''value'', '''' ) AS ip_one_short_amount,
  COALESCE ( ord.ind_cond_info -> ''32'' ->> ''value'', '''' ) AS ip_speed,
  COALESCE ( ord.ind_cond_info -> ''33'' ->> ''value'', '''' ) AS ip_speed_max,
  COALESCE ( ( CASE ord.ind_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS auto_one_shot,
  COALESCE ( ( CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_auto_off,
  COALESCE ( ord.ind_cond_info -> ''36'' ->> ''value'', '''' ) AS ip_auto_off_time,
  COALESCE ( ( CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_monitor_auto_off,
  COALESCE ( ord.ind_cond_info -> ''38'' ->> ''value'', '''' ) AS ip_monitor_auto_off_time,
  COALESCE ( pm.medical_care_info ->> ''dialysis_start_date'', '''' ) AS dialysis_start_date,
  COALESCE ( to_char( ord.up_date, ''YYYYMMDD'' ), '''' ) AS update_ymd,
  COALESCE ( to_char( ord.up_date, ''HH24MISS'' ), '''' ) AS update_hms 
FROM
  pat_main AS pm,
  ord_main AS ord
  LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
  LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
  LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd 
WHERE
  ord.ord_no = @ordNo and
  pm.pat_id = ord.pat_id', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2020-03-18 19:07:17.001', '2020-03-18 19:07:21', NULL);
