delete from ntss.sys_data_set where sql_cd in ('-19', '-13');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-19, e'WITH do_order_data_from AS (SELECT ROW_NUMBER() OVER () AS no2, datt.ora::numeric
                            FROM (SELECT jsonb_array_elements_text(mst_f.value::jsonb) AS ora
                                  FROM mst_facility_setting AS mst_f
                                  WHERE mst_f.facility_setting_no = \'3007\'
                                    AND mst_f.facility_cd = @facilityCd) AS datt)
   , do_mstmeq_cd AS (SELECT index_no                                       AS meq_code_order,
                             TO_NUMBER(order_cd ->> \'code\', \'999999999999\') AS meq_code,
                             order_cd ->> \'name\'                            AS meq_code_name
                      FROM mst_selector
                               CROSS JOIN LATERAL jsonb_array_elements(order_settings -> \'items\') with ordinality as tmp(order_cd, index_no)
                      WHERE facility_cd = @facilityCd
                        AND master_physical_name = \'mst_equipment\')
   , do_mstmeq_class_cd AS (SELECT index_no                                       AS meq_class_code_order,
                                   TO_NUMBER(order_cd ->> \'code\', \'999999999999\') AS meq_class_code,
                                   order_cd ->> \'name\'                            AS meq_class_code_name
                            FROM mst_selector
                                     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> \'items\') with ordinality as tmp(order_cd, index_no)
                            WHERE facility_cd = @facilityCd
                              AND master_physical_name = \'mst_equipment_class\')
   , data_middle_all AS (select \'指示医材\'                                          as detail_id,
                                row_number() over ()                                as equip_no,
                                all_equip.equip_class_type                          as class,
                                all_equip.cd1                                       as cd1,
                                all_equip.cd2                                       as cd2,
                                all_equip.cd3                                       as cd3,
                                all_equip.cd4                                       as cd4,
                                all_equip.equip_name                                as name,
                                ((COALESCE(all_equip.amount, \'0\')::FLOAT))::INTEGER AS amount,
                                all_equip.unit                                      as unit,
                                all_equip.syoumouhinOrder                           as syoumouhinOrder
                         from (select \'吸着器\'                     as equip_class_type,
                                      meqad.equipment_name         as equip_name,
                                      trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
                                      trim(meqad.in_hospital_cd_2) as cd2,
                                      trim(meqad.in_hospital_cd_3) as cd3,
                                      trim(meqad.in_hospital_cd_4) as cd4,
                                      \'1\'                          as amount,
                                      meqad.unit,
                                      1                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqad
                                                  on meqad.equipment_cd =
                                                     cast(ord.ind_cond_info -> \'6\' ->> \'value\' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select \'1次膜\'                      as equip_class_type,
                                      meqpr.equipment_name         as equip_name,
                                      trim(meqpr.in_hospital_cd_1) as cd1,--1次膜コード１
                                      trim(meqpr.in_hospital_cd_2) as cd2,
                                      trim(meqpr.in_hospital_cd_3) as cd3,
                                      trim(meqpr.in_hospital_cd_4) as cd4,
                                      \'1\'                          as amount,
                                      meqpr.unit,
                                      2                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqpr
                                                  on meqpr.equipment_cd =
                                                     cast(ord.ind_cond_info -> \'7\' ->> \'value\' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select \'2次膜\'                      as equip_class_type,
                                      meqse.equipment_name         as equip_name,
                                      trim(meqse.in_hospital_cd_1) as cd1,--2次膜コード１
                                      trim(meqse.in_hospital_cd_2) as cd2,
                                      trim(meqse.in_hospital_cd_3) as cd3,
                                      trim(meqse.in_hospital_cd_4) as cd4,
                                      \'1\'                          as amount,
                                      meqse.unit,
                                      3                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqse
                                                  on meqse.equipment_cd =
                                                     cast(ord.ind_cond_info -> \'8\' ->> \'value\' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select \'穿刺針A\'                   as equip_class_type,
                                      meqa.equipment_name         as equip_name,
                                      trim(meqa.in_hospital_cd_1) as cd1,--穿刺針Aコード１
                                      trim(meqa.in_hospital_cd_2) as cd2,
                                      trim(meqa.in_hospital_cd_3) as cd3,
                                      trim(meqa.in_hospital_cd_4) as cd4,
                                      \'1\'                         as amount,
                                      meqa.unit,
                                      4                           as syoumouhinOrder
                               from ord_main ord
                                        left join mst_equipment as meqa
                                                  on meqa.equipment_cd =
                                                     cast(ord.ind_cond_info -> \'9\' ->> \'value\' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select \'穿刺針V\'                   as equip_class_type,
                                      meqv.equipment_name         as equip_name,
                                      trim(meqv.in_hospital_cd_1) as cd1,--穿刺針Vコード１
                                      trim(meqv.in_hospital_cd_2) as cd2,
                                      trim(meqv.in_hospital_cd_3) as cd3,
                                      trim(meqv.in_hospital_cd_4) as cd4,
                                      \'1\'                         as amount,
                                      meqv.unit,
                                      4                           as syoumouhinOrder
                               from ord_main ord
                                        left join mst_equipment as meqv
                                                  on meqv.equipment_cd =
                                                     cast(ord.ind_cond_info -> \'10\' ->> \'value\' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select \'穿刺針SN\'                   as equip_class_type,
                                      meqsn.equipment_name         as equip_name,
                                      trim(meqsn.in_hospital_cd_1) as cd1,--穿刺針SNコード１
                                      trim(meqsn.in_hospital_cd_2) as cd2,
                                      trim(meqsn.in_hospital_cd_3) as cd3,
                                      trim(meqsn.in_hospital_cd_4) as cd4,
                                      \'1\'                          as amount,
                                      meqsn.unit,
                                      4                            as syoumouhinOrder
                               from ord_main ord
                                        left join mst_equipment as meqsn
                                                  on meqsn.equipment_cd =
                                                     cast(ord.ind_cond_info -> \'11\' ->> \'value\' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select \'血液回路\'                   as equip_class_type,
                                      meqbc.equipment_name         as equip_name,
                                      trim(meqbc.in_hospital_cd_1) as cd1, --血液回路コード１
                                      trim(meqbc.in_hospital_cd_2) as cd2,
                                      trim(meqbc.in_hospital_cd_3) as cd3,
                                      trim(meqbc.in_hospital_cd_4) as cd4,
                                      \'1\'                          as amount,
                                      meqbc.unit,
                                      5                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqbc
                                                  on meqbc.equipment_cd =
                                                     cast(ord.ind_cond_info -> \'13\' ->> \'value\' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select meqc.class_name            as equip_class_type,
                                      meq.equipment_name         as equip_name,
                                      trim(meq.in_hospital_cd_1) as cd1,
                                      trim(meq.in_hospital_cd_2) as cd2,
                                      trim(meq.in_hospital_cd_3) as cd3,
                                      trim(meq.in_hospital_cd_4) as cd4,
                                      equip ->> \'amount\'         as equip_amount,
                                      meq.unit                   as equip_unit,
                                      6                          as syoumouhinOrder
                               from ord_main as ord
                                        cross join lateral jsonb_array_elements(ord.ind_equip_info) equip
                                        left join mst_equipment as meq
                                                  on meq.equipment_cd = cast(equip ->> \'cd\' as integer)
                                        left join mst_equipment_class as meqc on meq.class_cd = meqc.class_cd
                               where ord.ord_no = @ordNo
                                 and equip ->> \'equip_type\' = \'0\'
                               UNION ALL
                               SELECT \'ダイアライザ\'       as equip_class_type,
                                      meq.model_number     as equip_name,
                                      meq.in_hospital_cd_1 AS cd1,
                                      meq.in_hospital_cd_2 AS cd2,
                                      meq.in_hospital_cd_3 AS cd3,
                                      meq.in_hospital_cd_4 AS cd4,
                                      equip ->> \'amount\'   as equip_amount,
                                      equip ->> \'unit\'     as equip_unit,
                                      25                   AS syoumouhinOrder
                               FROM ord_main ord
                                        CROSS JOIN LATERAL jsonb_array_elements(ord.ind_equip_info) equip
                                        LEFT JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = cast(equip ->> \'cd\' as integer)
                               WHERE equip ->> \'equip_type\' = \'1\'
                                 AND ord.ord_no = @ordNo) all_equip
                         where all_equip.cd1 is not null)
   , do_data_group AS (SELECT (detail_id:: text)                as detail_id
                            , cd1
                            , name
                            , sum(amount)                       as amount
                            , CASE
                                  WHEN SUM(syoumouhinOrder) > 6 THEN SUM(syoumouhinOrder) - 6
                                  ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
                       FROM data_middle_all
                       GROUP BY cd1, detail_id :: text, name)
   , data_all AS (SELECT DISTINCT do_data_group.detail_id       AS detail_id,
                                  do_data_group.cd1             AS cd1,
                                  cd2,
                                  cd3,
                                  cd4,
                                  do_data_group.name            AS name,
                                  do_data_group.amount          AS amount,
                                  unit,
                                  do_data_group.syoumouhinOrder AS syoumouhinOrder
                  FROM do_data_group
                           LEFT JOIN data_middle_all ON data_middle_all.cd1 = do_data_group.cd1)
   , order_code_up_F AS (SELECT DISTINCT ON (e01f)*
                         FROM (SELECT meq.in_hospital_cd_1 AS e01f
                                    , CASE
                                          WHEN 1 in (SELECT ora FROM do_order_data_from)
                                              THEN cast(do_mstmeq_class_cd.meq_class_code_order as numeric)
                                 END                       AS cl_cd_f
                                    , CASE
                                          WHEN 2 in (SELECT ora FROM do_order_data_from)
                                              THEN cast(do_mstmeq_cd.meq_code_order as numeric)
                                 END                       AS eq_cd_f
                               FROM do_mstmeq_cd
                                        LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
                                        LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
                               WHERE meq.in_hospital_cd_1 IS NOT NULL
                               ORDER BY e01f asc) AS order_code_middle_F)
   , order_code_up_S AS (SELECT DISTINCT ON (e01s)*
                         FROM (SELECT CASE
                                          WHEN (SELECT in_hospital_cd_1
                                                FROM mst_equipment AS meq
                                                WHERE meq.equipment_cd = cast(equip ->> \'cd\' as integer)
                                                  AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
                                              THEN (SELECT in_hospital_cd_1
                                                    FROM mst_dialyzer AS dia
                                                    WHERE dia.dialyzer_cd = cast(equip ->> \'cd\' as integer)
                                                      AND dia.in_hospital_cd_1 IS NOT NULL)
                                          ELSE (SELECT in_hospital_cd_1
                                                FROM mst_equipment AS meq
                                                WHERE meq.equipment_cd = cast(equip ->> \'cd\' as integer)
                                                  AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
                                      CASE
                                          WHEN 0 in (SELECT ora FROM do_order_data_from)
                                              THEN TO_NUMBER(json_idx :: text, \'999999999999\')
                                          END                                               AS login_ord_s
                               FROM ord_main AS ord
                                        CROSS JOIN LATERAL
                                   jsonb_array_elements(ind_equip_info) with ordinality as tmp(equip, json_idx)
                               WHERE ord.ord_no = @ordNo
                               ORDER BY e01s, login_ord_s) AS order_code_middle_S)
   , do_data AS (SELECT detail_id
                      , cd1
                      , cd2
                      , cd3
                      , cd4
                      , name
                      , amount
                      , unit
                      , syoumouhinOrder
                      , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = cd1)          AS login_ord
                      , CASE
                            WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) IS NULL THEN 0
                            ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) END AS cl_cd
                      , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = cd1)              AS eq_cd
                 FROM data_all
                 ORDER BY syoumouhinOrder)
SELECT detail_id,
       cd1,
       cd2,
       cd3,
       cd4,
       name,
       amount,
       unit,
       syoumouhinOrder,
       login_ord,
       cl_cd,
       eq_cd
FROM do_data
ORDER BY     CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END
limit 12', 2, '[{}]', '1', '{"applications": [4]}', null, '指示）指示医材コード', '2020-04-10 16:42:55.734', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-13, e'SELECT ord.treat_date                                               AS dialysis_date,
       ord.facility_cd                                              AS facility_cd,
       COALESCE(concat(ord.ind_schedule_user_info ->> \'ind_user_last_name\', \' \',
                       ord.ind_schedule_user_info ->> \'ind_user_first_name\'),
                \'\')                                                 AS ind_name,
       COALESCE(LEFT(concat(ord.ind_schedule_user_info ->> \'ind_user_last_name\', \' \',
                            ord.ind_schedule_user_info ->> \'ind_user_first_name\'), 5),
                \'\')                                                 AS ind_name10,
       COALESCE(ord.ind_schedule_user_info ->> \'ind_user_id\', \'\')   AS staff_cd_comm,
       COALESCE(ord.ind_treat_start_time, \'\')                       AS start_time,
       COALESCE(mkr.in_hospital_cd_1, \'\')                           AS kur_cd1,
       COALESCE(mkr.kur_name, \'\')                                   AS kur_name,
       COALESCE(mbd.bed_cd, 0)                                      AS bed_cd,
       COALESCE(mbd.in_hospital_cd_1, \'\')                           AS bed_cd1,
       COALESCE(mbd.bed_name, \'\')                                   AS bed_name,
       COALESCE(CASE
                    WHEN mtt.in_hospital_cd_a1 = \'\' or mtt.in_hospital_cd_a1 is NULL THEN \'不明\'
                    ELSE mtt.treatment_name END,
                \'\')                                                 AS treatment_name,
       COALESCE(CASE
                    WHEN mtt.in_hospital_cd_a1 = \'\' or mtt.in_hospital_cd_a1 is NULL THEN \'-\'
                    ELSE mtt.in_hospital_cd_a1 END,
                \'\')                                                 AS treatment_cd,
       COALESCE(ord.ind_dw, 0)                                      AS dw,
       ord.ind_cond_info -> \'1\' ->> \'value\'                         AS dialysis_time_m,
       case
           when RIGHT((COALESCE(
                               RIGHT(\'00\' || TRUNC(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\') / 60, 0),
                                     2) ||
                               RIGHT(\'00\' || MOD(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\'), 60), 2),
                               \'0\'
                       )::INTEGER + COALESCE(ord.ind_treat_start_time, \'0\')::INTEGER)::TEXT, 2)::INTEGER >= 60
               then ((COALESCE(
                              RIGHT(\'00\' || TRUNC(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\') / 60, 0),
                                    2) ||
                              RIGHT(\'00\' || MOD(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\'), 60), 2),
                              \'0\'
                      )::INTEGER + COALESCE(ord.ind_treat_start_time, \'0\')::INTEGER) + 100 - 60) ::TEXT

           else
               CASE
                   WHEN
                       COALESCE(
                               RIGHT(\'00\' || TRUNC(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\') / 60, 0),
                                     2) ||
                               RIGHT(\'00\' || MOD(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\'), 60), 2),
                               \'0\'
                       )::INTEGER + COALESCE(ord.ind_treat_start_time, \'0\')::INTEGER >= 2400
                       THEN
                       LPAD((COALESCE(
                                     RIGHT(\'00\' ||
                                           TRUNC(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\') / 60, 0),
                                           2) ||
                                     RIGHT(\'00\' || MOD(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\'), 60),
                                           2),
                                     \'0\'
                             )::INTEGER + COALESCE(ord.ind_treat_start_time, \'0\')::INTEGER - 2400) ::TEXT, 4, \'0\')
                   ELSE
                       (COALESCE(
                                RIGHT(\'00\' || TRUNC(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\') / 60, 0),
                                      2) ||
                                RIGHT(\'00\' || MOD(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\'), 60), 2),
                                \'0\'
                        )::INTEGER + COALESCE(ord.ind_treat_start_time, \'0\')::INTEGER) ::TEXT
                   END
           END                                                      as end_time,
       COALESCE(
               RIGHT(\'00\' || TRUNC(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\') / 60, 0), 2) || \':\' ||
               RIGHT(\'00\' || MOD(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\'), 60), 2),
               \'0\'
       )                                                            AS treatment_time,
       COALESCE(
               RIGHT(\'00\' || TRUNC(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\') / 60, 0), 2) ||
               RIGHT(\'00\' || MOD(TO_NUMBER(ord.ind_cond_info -> \'1\' ->> \'value\', \'999999\'), 60), 2),
               \'\'
       )                                                            AS treatment_time4,
       COALESCE(ord.rst_cond_info -> \'1\' ->> \'value\', \'\')           AS treatment_time_m,--追加
       COALESCE(ord.ind_cond_info -> \'2\' ->> \'value_name_1\', \'\')    AS va,
       COALESCE(SUBSTRING(ord.ind_cond_info -> \'2\' ->> \'value_name_1\', 1, 3),
                \'\')                                                 AS va3,
       COALESCE(mva.in_hospital_cd_1, \'\')                           AS va_cd1,
       COALESCE(
               (CASE mva.va_direct
                    WHEN \'0\' THEN \'右\'
                    WHEN \'1\' THEN \'左\'
                    WHEN \'2\' THEN \'両方\'
                    WHEN \'3\' THEN \'無\'
                    ELSE \'不明\' END),
               \'\'
       )                                                            AS va_direct,
       COALESCE(ord.ind_cond_info -> \'3\' ->> \'value\', \'\')           AS target_weight,
       COALESCE(ord.ind_cond_info -> \'4\' ->> \'value\', \'\')           AS water_removal_amount_limit,
--ord.ind_cond_info->\'5\'->>\'value_name_1\' as dialyzer,
       COALESCE(mdr.model_number, \'\')                               AS dialyzer,
--ord.ind_cond_info->\'5\'->>\'value\' as dialyzer_cd,
       COALESCE(mdr.in_hospital_cd_1, \'\')                           AS dialyzer_cd1,
       COALESCE(ord.ind_cond_info -> \'6\' ->> \'value_name_1\', \'\')    AS adsorption_column,
       COALESCE(meqad.in_hospital_cd_1, \'\')                         AS ad_cd1,
       COALESCE(ord.ind_cond_info -> \'7\' ->> \'value_name_1\', \'\')    AS primary_film,
       COALESCE(meqpr.in_hospital_cd_1, \'\')                         AS pr_cd1,
       COALESCE(ord.ind_cond_info -> \'8\' ->> \'value_name_1\', \'\')    AS secondary_film,
       COALESCE(meqse.in_hospital_cd_1, \'\')                         AS se_cd1,
--ord.ind_cond_info->\'9\'->>\'value_name_1\' as puncture_needle_a,
       COALESCE(meqa.equipment_name, \'\')                            AS puncture_needle_a,
       COALESCE(meqa.in_hospital_cd_1, \'\')                          AS a_cd1,
--ord.ind_cond_info->\'10\'->>\'value_name_1\' as puncture_needle_v,
       COALESCE(meqv.equipment_name, \'\')                            AS puncture_needle_v,
       COALESCE(meqv.in_hospital_cd_1, \'\')                          AS v_cd1,
--ord.ind_cond_info->\'11\'->>\'value_name_1\' as puncture_needle_sn,
       COALESCE(meqsn.equipment_name, \'\')                           AS puncture_needle_sn,
       COALESCE(meqsn.in_hospital_cd_1, \'\')                         AS sn_cd1,
       COALESCE((CASE ord.ind_cond_info -> \'12\' ->> \'value\' WHEN \'1\' THEN \'有り\' WHEN \'0\' THEN \'無し\' ELSE NULL END),
                \'\')                                                 AS single_needle,
       COALESCE(ord.ind_cond_info -> \'13\' ->> \'value\', \'\')          AS blood_circuit,
       COALESCE(meqbc.in_hospital_cd_1, \'\')                         AS bc_cd1,
       COALESCE(ord.ind_cond_info -> \'14\' ->> \'value\', \'\')          AS blood_flow,
--ord.ind_cond_info->\'15\'->>\'value_name_1\' as dialysate,
       COALESCE(med15.medicine_name, \'\')                            AS dialysate,
       COALESCE(med15.in_hospital_cd_1, \'\')                         AS dialysate_cd1,
       COALESCE(ord.ind_cond_info -> \'16\' ->> \'value\', \'\')          AS dialysate_flow_rate,
       COALESCE(ord.ind_cond_info -> \'17\' ->> \'value\', \'\')          AS dialysate_amount,
--ord.ind_cond_info->\'17\'->>\'unit\' as dialysate_amount_unit,
       COALESCE(med15.unit_second, \'\')                              AS dialysate_amount_unit,
       COALESCE(ord.ind_cond_info -> \'18\' ->> \'value\', \'\')          AS dialysate_temperature,
--ord.ind_cond_info->\'19\'->>\'value_name_1\' as fluid_replacement,
       COALESCE(med25.medicine_name, \'\')                            AS fluid_replacement,
       COALESCE(med25.in_hospital_cd_1, \'\')                         AS ds_cd1,
       COALESCE(ord.ind_cond_info -> \'20\' ->> \'value\', \'\')          AS fluid_replacement_amount,
       COALESCE(
               (CASE ord.ind_cond_info -> \'21\' ->> \'value\' WHEN \'1\' THEN \'前補液\' WHEN \'0\' THEN \'後補液\' ELSE NULL END),
               \'\')                                                  AS fluid_replacement_timing,
       COALESCE(ord.ind_cond_info -> \'22\' ->> \'value\', \'\')          AS fluid_replacement_use_count,
       COALESCE(ord.ind_cond_info -> \'22\' ->> \'unit\', \'\')           AS fluid_replacement_use_count_unit,
       COALESCE(ord.ind_cond_info -> \'23\' ->> \'value\', \'\')          AS fluid_replacement_temperature,
       COALESCE(ord.ind_cond_info -> \'24\' ->> \'value\', \'\')          AS fluid_replacement_speed,
--ord.ind_cond_info->\'25\'->>\'value_name_1\' as anti_coagulant,
       COALESCE(med25.medicine_name, \'\')                            AS anti_coagulant,
       COALESCE(med25.in_hospital_cd_1, \'\')                         AS anti_coagulant_cd1,
       COALESCE(ord.ind_cond_info -> \'26\' ->> \'value\', \'\')          AS anti_coagulant_one_shot_amount,
--ord.ind_cond_info->\'26\'->>\'unit\' as anti_coagulant_one_shot_amount_unit,
       COALESCE(med25.unit, \'\')                                     AS anti_coagulant_one_shot_amount_unit,
       COALESCE(ord.ind_cond_info -> \'27\' ->> \'value\', \'\')          AS anti_coagulant_sustained_speed,
       COALESCE(ord.ind_cond_info -> \'27\' ->> \'unit\', \'\')           AS anti_coagulant_sustained_speed_unit,
       COALESCE(ord.ind_cond_info -> \'28\' ->> \'value\', \'\')          AS anti_coagulant_sustained_amount,
       COALESCE(ord.ind_cond_info -> \'28\' ->> \'unit\', \'\')           AS anti_coagulant_sustained_amount_unit,
       COALESCE(
               TO_NUMBER(ord.ind_cond_info -> \'26\' ->> \'value\', \'999999999999\') +
               TO_NUMBER(ord.ind_cond_info -> \'28\' ->> \'value\', \'999999999999\'),
               0
       )                                                            AS anti_coagulant_total_amount,--抗凝固剤総量
       COALESCE((CASE ord.ind_cond_info -> \'29\' ->> \'value\'
                     WHEN \'1\' THEN \'使用する\'
                     WHEN \'0\' THEN \'使用しない\'
                     ELSE NULL END),
                \'\')                                                 AS ip,
       COALESCE((CASE ord.ind_cond_info -> \'30\' ->> \'value\' WHEN \'0\' THEN \'手動\' WHEN \'1\' THEN \'自動\' ELSE NULL END),
                \'\')                                                 AS ip_start,
       COALESCE(ord.ind_cond_info -> \'31\' ->> \'value\', \'\')          AS ip_one_short_amount,
       COALESCE(ord.ind_cond_info -> \'32\' ->> \'value\', \'\')          AS ip_speed,
       COALESCE(ord.ind_cond_info -> \'33\' ->> \'value\', \'\')          AS ip_speed_max,
       COALESCE((CASE ord.ind_cond_info -> \'34\' ->> \'value\'
                     WHEN \'1\' THEN \'使用する\'
                     WHEN \'0\' THEN \'使用しない\'
                     ELSE NULL END),
                \'\')                                                 AS auto_one_shot,
       COALESCE((CASE ord.ind_cond_info -> \'35\' ->> \'value\' WHEN \'1\' THEN \'入\' WHEN \'0\' THEN \'切\' ELSE NULL END),
                \'\')                                                 AS ip_auto_off,
       COALESCE(ord.ind_cond_info -> \'36\' ->> \'value\', \'\')          AS ip_auto_off_time,
       COALESCE((CASE ord.ind_cond_info -> \'37\' ->> \'value\' WHEN \'1\' THEN \'入\' WHEN \'0\' THEN \'切\' ELSE NULL END),
                \'\')                                                 AS ip_monitor_auto_off,
       COALESCE(ord.ind_cond_info -> \'38\' ->> \'value\', \'\')          AS ip_monitor_auto_off_time,
       COALESCE(pm.medical_care_info ->> \'dialysis_start_date\', \'\') AS dialysis_start_date,
       COALESCE(to_char(ord.up_date, \'YYYYMMDD\'), \'\')               AS update_ymd,
       COALESCE(to_char(ord.up_date, \'HH24MISS\'), \'\')               AS update_hms
FROM pat_main AS pm,
     ord_main AS ord
         LEFT OUTER JOIN mst_equipment AS meqa
                         ON meqa.equipment_cd = cast(ord.ind_cond_info -> \'9\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_equipment AS meqv
                         ON meqv.equipment_cd = cast(ord.ind_cond_info -> \'10\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_equipment AS meqsn
                         ON meqsn.equipment_cd = cast(ord.ind_cond_info -> \'11\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_equipment AS meqad
                         ON meqad.equipment_cd = cast(ord.ind_cond_info -> \'6\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_equipment AS meqpr
                         ON meqpr.equipment_cd = cast(ord.ind_cond_info -> \'7\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_equipment AS meqbc
                         ON meqbc.equipment_cd = cast(ord.ind_cond_info -> \'13\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_equipment AS meqse
                         ON meqse.equipment_cd = cast(ord.ind_cond_info -> \'8\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_medicine AS med15
                         ON med15.medicine_cd = cast(ord.ind_cond_info -> \'15\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_medicine AS med19
                         ON med19.medicine_cd = cast(ord.ind_cond_info -> \'19\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_medicine AS med25
                         ON med25.medicine_cd = cast(ord.ind_cond_info -> \'25\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
         LEFT OUTER JOIN mst_dialyzer AS mdr
                         ON mdr.dialyzer_cd = cast(ord.ind_cond_info -> \'5\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = cast(ord.ind_cond_info -> \'2\' ->> \'value\' as int)
         LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
         LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
WHERE ord.ord_no = @ordNo
  and pm.pat_id = ord.pat_id', 2, '[{}]', '0', '{"applications": [4]}', null, '汎用）指示）透析条件', '2022-08-05 10:58:32.885', CURRENT_TIMESTAMP, null);
