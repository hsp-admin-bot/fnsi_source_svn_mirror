delete from "sys_data_set" where "sql_cd" in (-460,-461,-462,-463,-464,-465,-466,-467,-468,-469);
delete from "sys_data_set" where "sql_cd" in (-470,-471,-472,-473,-483);
delete from "sys_data_set" where "sql_cd" in (-474,-475,-476,-477,-478,-479,-480,-481,-482);
delete from "sys_data_set" where "sql_cd" in (-484,-485,-486,-487,-488,-489,-490,-491,-492,-493);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-493, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT >= 10
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査１０以上', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-492, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 9
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査９)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-491, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 8
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査８)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-490, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 7
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査７)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-489, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 6
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査６)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-488, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 5
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査５)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-487, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 4
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査４)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-486, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 3
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査３)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-485, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 2
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査２)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-484, 'WITH exam_info AS ( 
  SELECT
    ROW_NUMBER() OVER (ORDER BY exam.reg_order_class ASC, exam.exam_main_cd ASC) AS CNT
    , exam.exam_main_cd 
  FROM
    pat_exam_main AS exam 
    INNER JOIN ord_main AS ord 
      ON ord.ord_no = @ordNo 
      AND ord.treat_date = to_char(exam.result_exam_date, ''YYYYMMDD'') 
      AND ord.pat_id = exam.pat_id 
      AND exam.exam_status = ''1'' 
      AND exam.is_del = ''0'' 
      AND jsonb_array_length(exam.exam_result_info) > 0
) 
SELECT
  ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS e01
  , item.exam_item_name AS e02
  , ''1'' AS e03
  , '''' AS e04
  , '''' AS e05  
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) info 
  LEFT OUTER JOIN mst_exam_item AS item 
    ON item.exam_item_cd = (info ->> ''item_cd'') ::INT 
WHERE
  EXISTS ( 
    SELECT
      1 
    FROM
      exam_info 
    WHERE
      exam_info.exam_main_cd = exam.exam_main_cd 
      AND CNT = 1
  )
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(検査情報)(検査１)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-483, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''手術・麻酔'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(手術・麻酔情報)(手術・麻酔)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-482, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''--'')  --種別区分:無し
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察９)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-481, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''12'')  --種別区分:''12''：汎用
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察８)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-480, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''8'')  --種別区分:''8''：処置（検査）
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察７)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-479, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''7'')  --種別区分:''7''：処置（イベント）
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察６)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-478, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''6'')  --種別区分:''6''：薬剤
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察５)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-477, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''5'')  --種別区分:''5''：長時間
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察４)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-476, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''4'')  --種別区分:''4''：ろ過
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察３)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-475, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''3'')  --種別区分:''3''：患者（病）
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察２)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-474, 'SELECT
  ''医学管理料'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''2'')  --種別区分:''2''：患者（困）
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(医学管理料情報)(診察１)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-473, 'SELECT
  ''導入期加算'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''9'') --種別区分:''9''：導入期
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(処置・人工腎臓以外（導入期加算）情報)(処置)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-472, 'SELECT
  ''夜間・休日加算'' AS detail_id
  , mst.in_hospital_cd_1 AS e01
  , mst.addition_name AS e02
  , '''' AS e03
  , '''' AS e04
  , '''' AS e05 
FROM
  ord_main AS ord 
  CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) AS info 
  INNER JOIN mst_addition AS mst 
    ON info ->> ''cd'' = mst.addition_cd ::TEXT 
    AND mst.addition_class IN (''10'', ''11'') --種別区分:''10''：休日、''11''：時間外
WHERE
  ord.ord_no = @ordNo 
ORDER BY
  e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(処置・人工腎臓以外（夜間・休日加算）情報)(処置)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-471, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''処置・酸素'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(処置・酸素情報)(処置)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-470, 'WITH treat_all AS ( 
  SELECT
    --治療項目情報
    ''処置'' AS detail_id
    , mtt.in_hospital_cd_a1 AS e01
    , ord.rst_treatment_name AS e02
    , ord.rst_cond_info -> ''1'' ->> ''value'' AS e03
    , ''分'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_treatment AS mtt 
      ON mtt.treatment_cd = ord.rst_treatment_cd 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --加算項目情報
    ''処置'' AS detail_id
    , madd.in_hospital_cd_1 AS e01
    , madd.addition_name AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) oadd 
    LEFT OUTER JOIN mst_addition AS madd 
      ON madd.addition_cd = to_number(oadd ->> ''cd'', ''9999999999'') 
  WHERE
    ord.ord_no = @ordNo 
    AND madd.addition_class NOT IN (''9'', ''10'', ''11'') 
  UNION 
  SELECT
    --加算する治療項目情報
    ''処置'' AS detail_id
    , mtt.in_hospital_cd_a2 AS e01
    , ord.rst_treatment_name AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_treatment AS mtt 
      ON mtt.treatment_cd = ord.rst_treatment_cd 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --抗凝固剤(単独分）
    ''処置'' AS detail_id
    , med25.in_hospital_cd_1 AS e01 
    , ord.rst_cond_info -> ''25'' ->> ''value_name_1'' AS e02
    , to_char( 
      TO_NUMBER( 
        ord.rst_cond_info -> ''26'' ->> ''value''
        , ''FM999999999999''
      ) + TO_NUMBER( 
        ord.rst_cond_info -> ''28'' ->> ''value''
        , ''FM999999999999''
      ) 
      , ''FM99990.99''
    ) AS e03
    , ord.rst_cond_info -> ''26'' ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine AS med25 
      ON med25.medicine_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''25'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --抗凝固剤(調製分）
    ''処置'' AS detail_id
    , mmd.in_hospital_cd_1 AS e01 
    , mmd.medicine_name AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN to_char( 
          to_number(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
          , ''FM999999999''
        ) 
        ELSE to_char( 
          ( 
            TO_NUMBER( 
              COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0'')
              , ''FM99999.9999''
            ) + TO_NUMBER( 
              COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0'')
              , ''FM99999.9999''
            )
          ) / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
              ) 
              END
          ) 
          , ''FM999999999''
        ) 
        END
    ) AS e03
    , mmd.unit AS e04
    , ''-'' AS e05
    , ''5'' AS esort_no 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''25'' ->> ''value''
        , ''FM999999999999''
      ) 
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --透析液情報
    ''処置'' AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , mmd.medicine_name AS e02
    , to_char( 
      TO_NUMBER( 
        COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', ''0'')
        , ''FM99999.99''
      ) 
      , ''FM99990.99''
    ) AS e03
    , mmd.unit AS e04
    , ''-'' AS e05
    , ''6'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''15'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --補液情報
    ''処置'' AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , mmd.medicine_name AS e02
    , to_char( 
      TO_NUMBER( 
        COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', ''0'')
        , ''FM99999.9999''
      ) * 1000
      , ''FM999999999''
    ) AS e03
    , mmd.unit AS e04
    , ''-'' AS e05
    , ''7'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''19'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --A針情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , ''1'' AS e03
    , meq.unit AS e04
    , ''-'' AS e05
    , ''8'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''9'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --V針情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , ''1'' AS e03
    , meq.unit AS e04
    , ''-'' AS e05
    , ''9'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''10'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --SN針情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , ''1'' AS e03
    , meq.unit AS e04
    , ''-'' AS e05
    , ''9'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''11'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --医材内穿刺針情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , equip ->> ''amount'' AS e03
    , equip ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''10'' AS sort_no 
  FROM
    ord_main ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
  WHERE
    equip ->> ''class_type'' IN (''2'', ''3'') 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --医材情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , equip ->> ''amount'' AS e03
    , equip ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''11'' AS sort_no 
  FROM
    ord_main ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
  WHERE
    equip ->> ''equip_type'' = ''0'' 
    AND equip ->> ''class_type'' NOT IN (''2'', ''3'') 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --ダイアライザ情報
    ''処置'' AS detail_id
    , mdz.in_hospital_cd_1 AS e01
    , mdz.model_number AS e02
    , ''1'' AS e03
    , ''個'' AS e04
    , ''-'' AS e05
    , ''12'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_dialyzer AS mdz 
      ON mdz.dialyzer_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''5'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --ダイアライザ情報
    ''処置'' AS detail_id
    , mdz.in_hospital_cd_1 AS e01
    , mdz.model_number AS e02
    , ''1'' AS e03
    , ''個'' AS e04
    , ''-'' AS e05
    , ''13'' AS sort_no 
  FROM
    ord_main ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip 
    LEFT OUTER JOIN mst_dialyzer AS mdz 
      ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
  WHERE
    equip ->> ''equip_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --1次膜情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , ''1'' AS e03
    , meq.unit AS e04
    , ''-'' AS e05
    , ''14'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''7'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --2次膜情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , ''1'' AS e03
    , meq.unit AS e04
    , ''-'' AS e05
    , ''15'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''8'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --吸着カラム情報
    ''処置'' AS detail_id
    , meq.in_hospital_cd_1 AS e01
    , meq.equipment_name AS e02
    , ''1'' AS e03
    , meq.unit AS e04
    , ''-'' AS e05
    , ''16'' AS sort_no 
  FROM
    ord_main ord 
    LEFT OUTER JOIN mst_equipment AS meq 
      ON meq.equipment_cd = TO_NUMBER( 
        ord.rst_cond_info -> ''6'' ->> ''value''
        , ''FM999999999999''
      ) 
  WHERE
    ord.ord_no = @ordNo
) 
SELECT
  treat_all.detail_id AS detail_id
  , treat_all.e01 AS e01
  , treat_all.e02 AS e02
  , REPLACE (TRIM(treat_all.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (treat_all.e04, ''-'', '''') AS e04
  , REPLACE (treat_all.e05, ''-'', '''') AS e05 
FROM
  treat_all 
WHERE
  COALESCE(treat_all.e01, ''NONE'') <> ''NONE'' 
ORDER BY
  treat_all.sort_no
', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(処置・治療項目情報)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-469, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''特注'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(特注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-468, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''点滴'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)点滴)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-467, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''皮内注'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(皮内注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-466, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''皮下注'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(皮下注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-465, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''筋注'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(筋注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-464, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''静注'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(注射情報)(静注)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-463, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''自己注射'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(自己注射)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-462, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''外用'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(外用)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-461, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''頓服'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(頓服)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-460, 'WITH oxy_info AS ( 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素吸入'' AS e02
    , ''-'' AS e03
    , ''-'' AS e04
    , ''-'' AS e05
    , ''1'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') = ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --酸素情報
    ''処置・酸素'' AS detail_id
    , ''999999'' AS e01
    , ''酸素'' AS e02
    , to_char( 
      to_number(oxy ->> ''oxygen_amount'', ''FM999999.99'')
      , ''FM999990.99''
    ) AS e03
    , ''L'' AS e04
    , ''-'' AS e05
    , ''2'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) oxy 
  WHERE
    COALESCE(oxy ->> ''oxygen_amount'', ''end'') <> ''end'' 
    AND oxy ->> ''treat_class'' = ''3'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , medi ->> ''name'' AS e02
    , ( 
      CASE 
        WHEN mmd.unit_second IS NULL 
          THEN to_char( 
          to_number(medi ->> ''amount'', ''FM99999.99'')
          , ''FM99990.99''
        ) 
        ELSE ( 
          CASE 
            WHEN mmd.is_exchange = ''0'' 
              THEN to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'') / ( 
                CASE 
                  WHEN ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) = 0 
                    THEN NULL 
                  ELSE ( 
                    mmd.unit_converted_amount * mmd.unit_converted_amount_second
                  ) 
                  END
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''1'' 
              THEN to_char( 
              trunc( 
                to_number(medi ->> ''amount'', ''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second
                 + 0.9
                , 0
              ) 
              , ''FM99990.99''
            ) 
            WHEN mmd.is_exchange = ''2'' 
              THEN ''1'' 
            ELSE to_char( 
              to_number(medi ->> ''amount'', ''FM99999.99'')
              , ''FM99990.99''
            ) 
            END
        ) 
        END
    ) AS e03
    , ( 
      CASE COALESCE(mmd.unit_second, ''NORESE'') 
        WHEN ''NORESE'' THEN medi ->> ''unit'' 
        ELSE mmd.unit_second 
        END
    ) AS e04
    , ''-'' AS e05
    , ''3'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(medi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND ord.ord_no = @ordNo 
  UNION 
  SELECT
    --処置薬剤情報
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(tmedi ->> ''treat_medicine_name'', 1, 25) AS e02
    , tmedi ->> ''amount'' AS e03
    , tmedi ->> ''unit'' AS e04
    , ''-'' AS e05
    , ''4'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = TO_NUMBER(tmedi ->> ''class_cd'', ''FM999999999999'') 
  WHERE
    ord.ord_no = @ordNo 
  UNION 
  SELECT
    --投与薬剤情報(調製)
    CASE 
      WHEN mp.pricedure_name LIKE ''%静注%'' 
        THEN ''静注'' 
      WHEN mp.pricedure_name LIKE ''%筋注%'' 
        THEN ''筋注'' 
      WHEN mp.pricedure_name LIKE ''%皮内注%'' 
        THEN ''皮内注'' 
      WHEN mp.pricedure_name LIKE ''%皮下注%'' 
        THEN ''皮下注'' 
      WHEN mp.pricedure_name LIKE ''%点滴%'' 
        THEN ''点滴'' 
      WHEN mp.pricedure_name LIKE ''%特注%'' 
        THEN ''特注'' 
      ELSE CASE 
        WHEN mmc.class_name LIKE ''%内服%'' 
          THEN ''内服'' 
        WHEN mmc.class_name LIKE ''%頓服%'' 
          THEN ''頓服'' 
        WHEN mmc.class_name LIKE ''%外用%'' 
          THEN ''外用'' 
        WHEN mmc.class_name LIKE ''%自己注射%'' 
          THEN ''自己注射'' 
        WHEN mmc.class_name LIKE ''%手術・麻酔%'' 
          THEN ''手術・麻酔'' 
        ELSE ''処置・酸素'' 
        END 
      END AS detail_id
    , mmd.in_hospital_cd_1 AS e01
    , SUBSTRING(mmd.medicine_name, 1, 25) AS e02
    , ( 
      CASE mmxd ->> ''solvent'' 
        WHEN ''1'' THEN mmxd ->> ''amount'' 
        ELSE to_char( 
          to_number(medi ->> ''amount'', ''FM999999.999'') / ( 
            CASE 
              WHEN ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM999999.999'')
              ) = 0 
                THEN NULL 
              ELSE ( 
                mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''999999.999'')
              ) 
              END
          ) 
          , ''FM999990.000''
        ) 
        END
    ) AS e03
    , COALESCE(mmd.unit_second, mmd.unit) AS e04
    , ''-'' AS e05
    , ''5'' AS sort_no 
  FROM
    ord_main AS ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
    LEFT OUTER JOIN mst_procedure AS mp 
      ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_mix AS mmx 
      ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
    LEFT OUTER JOIN mst_medicine_class AS mmc 
      ON mmc.class_cd = mmx.class_cd
    , mst_medicine_mix AS mmx2 
    CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
    LEFT OUTER JOIN mst_medicine AS mmd 
      ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''2'' 
    AND ord.ord_no = @ordNo
) 
SELECT
  oxy_info.detail_id AS detail_id
  , oxy_info.e01 AS e01
  , oxy_info.e02 AS e02
  , REPLACE (TRIM(oxy_info.e03, ''.''), ''-'', '''') AS e03
  , REPLACE (oxy_info.e04, ''-'', '''') AS e04
  , REPLACE (oxy_info.e05, ''-'', '''') AS e05 
FROM
  oxy_info 
WHERE
  COALESCE(oxy_info.e01, ''NONE'') <> ''NONE'' 
  AND oxy_info.detail_id = ''内服'' 
ORDER BY
  oxy_info.sort_no ASC
  , oxy_info.e01 ASC', 2, '[]', '0', '{"applications": [4]}', NULL, 'Medicom処方薬剤連携(投薬情報)(内服)', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', NULL);
