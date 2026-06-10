delete from "sys_data_set" where "sql_cd" in (-99995,-300001,-452,-453,-454);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-452, 'SELECT
  medical_care_info ->> ''ward_cd'' AS ward_cd
  , ward.ward_name AS ward_name
  , ward.in_hospital_cd_1 AS ward_in_hospital_cd
  , medical_care_info ->> ''main_course_cd'' AS main_course_cd
  , course.course_name AS course_name
  , course.in_hospital_cd_1 AS course_in_hospital_cd
FROM
  pat_main AS main 
  LEFT JOIN mst_ward AS ward ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
  LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
WHERE
  pat_id = @patId', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'Medicom検査オーダ', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-453, 'select
  ''検査項目'' as detail_id,
  (exam_full.exam_row + 1) as exam_row,
  substring(max(case exam_full.exam_col when 0 then exam_full.in_hospital_cd1 else null end ),2) as exam1,
  substring(max(case exam_full.exam_col when 0 then exam_full.sub_no else null end ),1,1) as exam1p,
  substring(max(case exam_full.exam_col when 1 then exam_full.in_hospital_cd1 else null end ),2) as exam2,
  substring(max(case exam_full.exam_col when 1 then exam_full.sub_no else null end ),1,1) as exam2p,
  substring(max(case exam_full.exam_col when 2 then exam_full.in_hospital_cd1 else null end ),2) as exam3,
  substring(max(case exam_full.exam_col when 2 then exam_full.sub_no else null end ),1,1) as exam3p,
  substring(max(case exam_full.exam_col when 3 then exam_full.in_hospital_cd1 else null end ),2) as exam4,
  substring(max(case exam_full.exam_col when 3 then exam_full.sub_no else null end ),1,1) as exam4p,
  substring(max(case exam_full.exam_col when 4 then exam_full.in_hospital_cd1 else null end ),2) as exam5,
  substring(max(case exam_full.exam_col when 4 then exam_full.sub_no else null end ),1,1) as exam5p
from
  ( 
    select
      (row_number() over () - 1) / 5 as exam_row
      , (row_number() over () - 1) % 5 as exam_col
      , exam.sub_no 
      , exam.in_hospital_cd1 
    from
      ( 
        select
          exam_all.* 
        from
          ( 
            select
              info ->> ''no'' as seq_no
              , ''6'' as sub_no -- 子（検査項目）
              , info ->> ''item_cd'' as item_cd 
              , info ->> ''item_name'' as item_name
              , item.in_hospital_cd1 as in_hospital_cd1
              , item.sbt_cd1 as sbt_cd1
              , item.in_hospital_cd2 as in_hospital_cd2
              , item.sbt_cd2 as sbt_cd2
              , item.in_hospital_cd3 as in_hospital_cd3
              , item.sbt_cd3 as sbt_cd3
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.exam_order_info ::json) info 
              left outer join mst_exam_item as item 
                on info ->> ''item_cd'' = (item.exam_item_cd || '''') 
            union all 
            select
              info ->> ''no'' as seq_no
              , ''5'' as sub_no -- 親（検査セット）
              , info ->> ''set_cd'' as item_cd 
              , info ->> ''set_name'' as item_name
              , item.in_hospital_cd1 as in_hospital_cd1
              , item.sbt_cd1 as sbt_cd1
              , item.in_hospital_cd2 as in_hospital_cd2
              , item.sbt_cd2 as sbt_cd2
              , item.in_hospital_cd3 as in_hospital_cd3
              , item.sbt_cd3 as sbt_cd3
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              left outer join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
          ) exam_all 
        where
          COALESCE(exam_all.in_hospital_cd1, ''no_cd'') <> ''no_cd'' 
        order by
          seq_no ASC 
          , sub_no ASC
      ) exam
  ) exam_full 
group by
  detail_id
  , exam_full.exam_row 
order by
  exam_row', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'Medicom検査オーダ 繰り返し部', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-454, 'select
  count(1) as exam_set_cnt
from
  ( 
    select
      info ->> ''no'' as seq_no
      , ''6'' as sub_no -- 子（検査項目）
      , info ->> ''item_cd'' as item_cd
      , info ->> ''item_name'' as item_name
      , item.in_hospital_cd1 as in_hospital_cd1
      , item.sbt_cd1 as sbt_cd1
      , item.in_hospital_cd2 as in_hospital_cd2
      , item.sbt_cd2 as sbt_cd2
      , item.in_hospital_cd3 as in_hospital_cd3
      , item.sbt_cd3 as sbt_cd3 
    from
      ( 
        select
          m.* 
        from
          pat_exam_main as m 
        where
          m.is_del = ''0'' 
          and jsonb_array_length(m.order_exam_set_info) > 0 
          and m.exam_main_cd = @ordNo
      ) p 
      cross join lateral json_array_elements(p.exam_order_info ::json) info 
      left outer join mst_exam_item as item 
        on info ->> ''item_cd'' = (item.exam_item_cd || '''') 
    union all 
    select
      info ->> ''no'' as seq_no
      , ''5'' as sub_no -- 親（検査セット）
      , info ->> ''set_cd'' as item_cd
      , info ->> ''set_name'' as item_name
      , item.in_hospital_cd1 as in_hospital_cd1
      , item.sbt_cd1 as sbt_cd1
      , item.in_hospital_cd2 as in_hospital_cd2
      , item.sbt_cd2 as sbt_cd2
      , item.in_hospital_cd3 as in_hospital_cd3
      , item.sbt_cd3 as sbt_cd3 
    from
      ( 
        select
          m.* 
        from
          pat_exam_main as m 
        where
          m.is_del = ''0'' 
          and jsonb_array_length(m.order_exam_set_info) > 0 
          and m.exam_main_cd = @ordNo
      ) p 
      cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
      left outer join mst_exam_set as item 
        on info ->> ''set_cd'' = (item.exam_set_cd || '''')
  ) exam_all 
where
  COALESCE(exam_all.in_hospital_cd1, ''no_cd'') <> ''no_cd'' 
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom検査オーダ セット数', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99995, 'WITH journal AS ( 
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
  WHERE
    EXISTS ( 
      SELECT
        1 
      FROM
        sys_coop_journal AS coop2 
      WHERE
        coop2.ctl_no = @ctlNo
        AND TO_CHAR(coop2.reg_date, ''YYYYMMDD'') = TO_CHAR(coop1.reg_date, ''YYYYMMDD'') 
        AND coop2.coop_cd = coop1.coop_cd
    )
) 
SELECT to_char(CURRENT_TIMESTAMP, ''YYMMDD'') || ''_'' || TO_CHAR((journal.CNT - 1)%100, ''FM09'') || ''.txt'' AS filename FROM journal', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom検査オーダファイル名取得', '2021-04-20 09:19:08.001', '2021-04-20 09:19:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-300001, ' select
 hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 pat_birthday as pat_birthday_yyyymmdd,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else to_char(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))), ''FM999'')
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
 pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'Medicom', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
