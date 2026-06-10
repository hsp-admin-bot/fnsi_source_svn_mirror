DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-101);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-101, 'WITH dialysis_item_send AS (-- 透析項目送信
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd

  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
	 OR info ->> ''key1'' = ''SEND_COMMENT'')
 ),
 device AS (
		SELECT device_mode
		FROM mst_treatment mst JOIN ord_main ord 
		ON ord.rst_treatment_cd = mst.treatment_cd 
		AND ord.ord_no =  @ordNo


),
 fji_com_info AS (-- 富士通共通設定
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd


  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''FJI_COM_INFO'' 
 ),
 dialyis_item_sort AS (-- 項目情報部出力順（予約/実績送信用）
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE 
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd =  @facilityCd


  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SORT'' 
 ),
 conv_teart_item_send_out AS ( -- 浄化方法変換（予約/実績送信用：外来）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( STRING_TO_ARRAY( ( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) ), '','' ) ) AS 
 VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd


  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT'' 
 ),
 conv_treat_item_send_in AS ( -- 浄化方法変換（予約/実績送信用：入院）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd


  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN'' 
 ),
 dialysis_send AS ( -- 透析发送
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd


  AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''DIALYSIS_SEND'' 
 ),
 int_set_medicine_resolve AS ( -- 薬剤分類が「透析液」のもの。セット薬剤の扱いについては、連携設定に従う。

 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd



  AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''RST_SET_MEDICINE_RESOLVE'' 
 ),
 DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」 
  SELECT
   info ->> ''key2'' AS key2,
   COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE 
  FROM
   mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
   facility_cd = @facilityCd



   AND is_del = ''0'' 
	 	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
   AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
 ),
 RST_MEDI_INFO AS (-- 透析実績投薬
 SELECT
  medi ->> ''cd'' AS medi_cd 
 FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi 
 WHERE
  ord.ord_no = @ordNo

 ),
 do_medicine_mix_in_orders1 as (
select mmxd ->> ''cd'' as medicine_cd ,ROW_NUMBER() OVER()::INTEGER as ordernow
FROM ord_main AS ord
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info->''25''->>''value'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json )  mmxd 
WHERE   ord.ord_no = @ordNo),
 bed_conv as(	 	
	SELECT
	0 AS order_no,
		to_number(COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), ''9999999999'') AS bed_conv
	 FROM
		mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	 WHERE
    facility_cd = @facilityCd



    AND is_del = ''0'' 
			-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0


-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
		AND info ->> ''key1'' = ''FJI_COM_INFO'' 
		AND info ->> ''key2'' = ''BED_CODE_CONV'' UNION
	SELECT
		1 AS order_no,
		1 AS bed_conv 
	ORDER BY
		order_no ASC 
		LIMIT 1 
 )
, dialysis_difficulty_info AS ( 
	SELECT ROW_NUMBER
		( ) OVER ( ) AS row_no,
		details 
	FROM
		( SELECT regexp_split_to_table( @dial_diff_cd

, '','' ) AS details ) AS T
 ),
 do_order_data_equip_from AS ( --施設設定106设置获取
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd


),'',''))), ''999999999999'') AS a1) AS datt
),
do_mstmeq_cd AS (--医療材料マスタ表示顺
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd



AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (--医療材料分類マスタ表示顺
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd



AND master_physical_name = ''mst_equipment_class'' 
),
kou_coag_procedur_data AS(            
    SELECT 
    VALUE   
    FROM
        (
        SELECT
            info ->> ''key2'' AS key2,
            COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
        VALUE
            
        FROM
            mst_coop_ini AS ini
            CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
        WHERE
            facility_cd = @facilityCd
            AND is_del = ''0'' 
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start            
            AND COALESCE(info->>''key0'','''') = @key0
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
        ) T 
    WHERE
        key2 = ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_PROCEDURE_CODE'' ) 
        LIMIT 1
),
kou_coag_procedur_falg AS (
    SELECT
        1 AS ctl 
    FROM
        (
        SELECT COUNT
            ( * ) AS cnt 
        FROM
            int_set_medicine_resolve 
        WHERE
            ( key2 IN ( ''KOU_COAG_PROCEDURE_ATTR'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_CODE'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_NAME'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
        ) T 
    WHERE
        cnt = 3 UNION
    SELECT
        2 AS ctl 
    ORDER BY
        ctl 
        LIMIT 1
    ) ,
 do_order_data_from AS (--施設設定107设置获取
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd



),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmedi_cd AS (--薬剤マスタ表示顺
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd



AND master_physical_name = ''mst_medicine'' 
),
do_mst_timing AS (
SELECT index_no AS timing_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code, order_cd ->> ''name'' AS timing_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

 
   AND master_physical_name = ''mst_medicate_timing'' 
)
, do_mst_procedure AS (
SELECT index_no AS procedure_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code, order_cd ->> ''name'' AS procedure_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

 
   AND master_physical_name = ''mst_procedure'' 
),
 do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

 
   AND master_physical_name = ''mst_medicine_mix'' 
),
do_medicine_mix_in_orders AS ( --調製薬剤内のソート順
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM (SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'' and  ord.ord_no = @ordNo ) AS middl

        GROUP BY mix_M_cd)
)
, do_mstmedi_class_cd AS (--薬剤分類マスタ表示顺
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd



AND master_physical_name = ''mst_medicine_class'' 
)
, data_middle_all AS (
SELECT
 all_cost.* 
FROM
 (
  (--  ベッドＮＯ
  SELECT
     ''実績詳細'' AS detail_id,
     ''VE1'' AS sbt_key,
	    CASE (SELECT bed_conv FROM bed_conv)
					WHEN 1 THEN
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_1),1,7)) :: TEXT, 7, ''0'' ) )
					WHEN 2 then 
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_2),1,7)) :: TEXT, 7, ''0'' ) )
					ELSE
						''V9999999'' 
				END AS e01,--項目コード
      COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_ATTR'' ), '''' ) AS e02,-- 項目属性
      COALESCE ( SUBSTRING ( mbd.bed_name, 1, 50 ), '''' ) AS e03,--項目名称
      ''0000000.000'' AS e04,--数量
      ''0'' AS e05,-- 選択単位フラグ
      '''' AS e06,-- 単位コード
      '''' AS e07,-- 単位名称
      '''' AS e08,
      '''' AS e09,
	    '''' AS e10,
       COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_TAG'' ), '''' ) AS e11,-- タグ名称
      ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BED_NO'' ), '''' ) ) AS sortTag ,
			'''' as sorttag1,
			'''' as sorttag2
  FROM
   ord_main ord
   LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd 
  WHERE
   ord.ord_no = @ordNo



  ) UNION ALL
  (--  浄化方法
		SELECT
    ''実績詳細'' AS detail_id, 
		''VC1'' AS sbt_key,
    --項目コード
			CASE
			--患者の入外区分が外来の場合
				WHEN @inOut
= ''0''
					THEN COALESCE(mtt.in_hospital_cd_a1, '''')
				--患者の入外区分が入院の場合
				WHEN @inOut
 = ''1''
					THEN COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), mtt.in_hospital_cd_a1, '''')
				ELSE ''''
      END AS e01, 
    --項目属性
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(mtt.treatment_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
		'''' AS e08,
    '''' AS e09,
    '''' AS e10,
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_TAG''), '''') AS e11, 
    --出力順
    COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_TREAT''), '''') AS sortTag,
		'''' as sorttag1,
		'''' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_treatment mtt
ON
    mtt.treatment_cd = ord.rst_treatment_cd
WHERE
    ord.ord_no = @ordNo



  ) UNION ALL
  (-- 希望開始時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA6'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        SUBSTRING ( to_char( rst_start_date, ''HH24:MI'' ), 1, 25 ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_START_DATE_TIME'' ), '''' ) ) AS sortTag ,
			 '''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 希望終了時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA7'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_CODE'' ), '''' ) AS e01,--項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_END_DATE_TIME'' ), '''' ) ) AS sortTag ,
						'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 予定所要時間
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA8'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date - rst_start_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,--数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_TAG'' ), '''' ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SCHE_TIME'' ), '''' ) ) AS sortTag, 
      '''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 透析前体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF2'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE (  to_char( ( ord.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,--  選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BEFORE_WEIGHT'' ), '''' ) ) AS sortTag ,
			'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 透析後体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF9'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ( ord.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
        ''1'' AS e05,--   選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_AFTER_WEIGHT'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 目標体重
					SELECT
						''実績詳細'' AS detail_id,
						''VF1'' AS sbt_key,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
						COALESCE ( to_char( ord.treat_date :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称
	          COALESCE ( to_char( TO_NUMBER(  ord.rst_cond_info -> ''3'' ->> ''value'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
						''1'' AS e05,-- 選択単位フラグ
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
						'''' AS e08,
						'''' AS e09,
						'''' AS e10,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG'' ), '''' ) AS e11,--  タグ名称
						( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_TARGET_WEIGHT'' ), '''' ) ) AS sortTag,
					'''' as sorttag1,
			'''' as sorttag2
					FROM
						ord_main ord 
					WHERE
						ord.ord_no = @ordNo



       ) UNION ALL
       (-- ドライウェイト
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF3'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ord.rst_start_date, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( ord.rst_dw, ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DRY_WEIGHT'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (--  透析導入日
							 SELECT
						''実績詳細'' AS detail_id,--項目コード
						''VS3'' AS sbt_key,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_CODE'' ), '''' ) AS e01,-- 項目コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_ATTR'' ), '''' ) AS e02,-- 項目属性 
						COALESCE ( to_char( ( patu.iov ->> ''period_start'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称
						''0000000.000'' AS e04,-- 数量
						''0'' AS e05,-- 選択単位フラグ
						'''' AS e06,-- 単位コード
						'''' AS e07,-- 単位名称
						'''' AS e08,
						'''' AS e09,
						'''' AS e10,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_TAG'' ), '''' ) AS e11,--タグ名称
						NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DATE_INTRODUCED'' ), '''' ) AS sortTag,
						'''' as sorttag1,
			'''' as sorttag2
					FROM
						ord_main ord
						LEFT JOIN (
						SELECT
							* 
						FROM
							(
								(
								SELECT
									1 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId

									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NOT NULL 
								) UNION ALL
								(
								SELECT
									2 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId

									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NULL 
								) 
							) DATA 
						ORDER BY
							DATA.NO,
							DATA.iov ->> ''period_start'' 
							LIMIT 1 
						) AS patu ON patu.pat_id = ord.pat_id 
					WHERE
						ord.ord_no = @ordNo



						AND patu IS NOT NULL
       ) UNION ALL
       (-- 障害者加算タイトル
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_CODE'' ),'''') AS e01,--コード
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_ATTR'' ),'''') AS e02,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_NAME'' ),'''') AS e03,--名
        ''0000000.000'' AS e04,
        ''0''AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       WHERE
        ((SELECT VALUE FROM dialysis_send WHERE key2 = ''ADD_TITLE_SEND_FLG'' ) = ''1'') AND  ''925,182''
 <>
 ''''
       ) UNION ALL
       (--  障害者加算:患者基本情報から取得
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE (nullif(mdd.in_hospital_cd_1,'''') ,( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_CODE'' ), '''' ) AS e01,--コード
        COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09, 
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' )||''-''||row_no AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
        FROM
        mst_dialysis_difficulty mdd,
				dialysis_difficulty_info
				WHERE
					dialysis_difficulty_cd :: TEXT IN (dialysis_difficulty_info.details)
       )  UNION ALL
       (-- VA
       SELECT
        ''実績詳細'' AS detail_id,
        ''VN1'' AS sbt_key,
        COALESCE ( mva.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mva.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mva.va_name, 1, 25 ), '''' ) AS e03,--項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,--  単位コード
        '''' AS e07,--  単位名称
        '''' AS e08,
        '''' AS e09,
        ''12'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SHUNT_PART'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 透析器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH1'' AS sbt_key,
        COALESCE ( mdz.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mdz.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mdz.model_number, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--  数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''14'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DIAL_INST'' ), '''' ) ) AS sortTag,
				'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_dialyzer AS mdz ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 吸着器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH2'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_ATTR'' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,--  項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,--  選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''15'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FILM'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 1次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''16'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FIRST_FILM'' ), '''' ) ) AS sortTag,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
       (-- 2次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( meq.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''17'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SECOND_FILM'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo



       ) UNION ALL
             (-- A針情報
			 SELECT
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag ,
		 ''1'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo



 AND
    ord.rst_cond_info->''9''->>''value'' IS NOT NULL
       ) UNION ALL 
			 (
			 SELECT
    --V針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag,
			''2'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo



 AND
    ord.rst_cond_info->''10''->>''value'' IS NOT NULL	 
			 )
			 UNION ALL
       (-- SN針情報
     SELECT
    --SN針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
       --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag,
			''3'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo



 AND
    ord.rst_cond_info->''11''->>''value'' IS NOT NULL
       ) UNION ALL
       (-- 血液回路
      SELECT
    --血液回路情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
      --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag ,
		 	''4'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo



 AND ord.rst_cond_info->''13''->>''value'' IS NOT NULL
       ) UNION ALL
       (-- 透析液
       SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_ATTR'' ), '''' ) ) ) AS e02,--項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
CASE
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
					 ((SELECT device_mode FROM device) NOT IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999''), ''FM0099999.990'')
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') AND
					 ((SELECT device_mode FROM device) IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999'') + TO_NUMBER(COALESCE(ord.rst_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0099999.990'')
      ELSE ''0000000.000''
			END AS e04,
        ''1''  AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_TAG'' ), '''' ) ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION'' ), '''' ) ) AS sortTag ,
				'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
        ord.ord_no = @ordNo



        AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
       ) UNION ALL
       (-- 置換液（補液）
       SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_ATTR'' ), '''' ) ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
        to_char( TO_NUMBER( ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999.999'' ), ''FM0000099.990'' ) AS e04,-- 数量
				''1'' e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_TAG'' ), '''' ) ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_REPLACE'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
        ord.ord_no = @ordNo



        AND (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
				AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0''
			  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
		    OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
       ) UNION ALL
       (-- 抗凝固剤初回
       SELECT
        ''実績詳細'' AS detail_id,
        ''VGX'' AS sbt_key,
        ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
        COALESCE (
         ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
         ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_ATTR'' ) 
        ) AS e02,-- 項目属性
        COALESCE (
        SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),
    '''' 
   ) AS e03,-- 項目名称
   to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,-- 数量
   (
    COALESCE (
    CASE
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN
       ''0'' 
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN
    ''0'' ELSE NULL 
   END,
   ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
    ) 
  ) AS e05,-- 選択単位フラグ
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e06,-- 単位コード
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''24'' AS e10,
  ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_TAG'' ), '''' ) ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_ONESHOT'' ), '''' ) ) AS sortTag ,
		'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
 WHERE
  ord.ord_no = @ordNo
  AND 
	CASE WHEN (ord.rst_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
 ) UNION ALL
 (-- 抗凝固剤持続
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGY'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ATTR'' ) 
  ) AS e02,-- 項目属性
  COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''') AS e03,-- 項目名称
 to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''27'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,--e4
 (
  COALESCE (
  CASE
   WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0'' 
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
 ) 
 ) AS e05,-- 選択単位フラグ
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN '''' 
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e06,-- 単位コード
 (
  COALESCE (
  CASE
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''''
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''25'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG'' ), '''' ) ) AS sortTag ,
 	'''' as sorttag1,
			'''' as sorttag2
FROM
 ord_main ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ord.ord_no = @ordNo
AND 
	CASE WHEN (ord.rst_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
 ) UNION ALL
 (-- 抗凝固剤TOTAL
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGZ'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_ATTR'' ) 
  ) AS e2,-- 項目属性,
    COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''')  AS e03,-- 項目名称
 to_char(
  TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ) + TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''28'' ->> ''value'', ''0'' ), ''999999999.999'' ),
  ''FM0999999.990'' 
 ) AS e04,-- 選択単位フラグ
 (
  COALESCE (
  CASE 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0''  
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) ) 
 ) AS e05,-- 選択単位フラグ
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e06,-- 単位コード
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''26'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_TOTAL'' ), '''' ) ) AS sortTag ,
 	'''' as sorttag1,
			'''' as sorttag2
FROM
 ord_main ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ord.ord_no = @ordNo
AND 
	CASE WHEN (ord.rst_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
 ) UNION ALL
 (--  血液流量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VK3'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_NAME'' ), '''' ) AS e03,-- 項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e07,-- 単位コード
  '''' AS e08,
  '''' AS e09,
  ''27'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BLOOD_AMT'' ), '''' ) ) AS sortTag ,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo



  AND TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ) > 1 
  AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
  
 )UNION ALL(-- 透析液流量
  SELECT
  ''実績詳細'' AS detail_id,
  ''VK4'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_ATTR'' ), '''' ) AS e02,--e2
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_NAME'' ), '''' ) AS e03,--e3
  to_char( TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,--e4
  ''1'' AS e05,--e5
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e06,--e6
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_TAG'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION_AMT'' ), '''' ) ) AS sortTag ,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo



  AND TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ) >= 1 
 )
UNION ALL
 (-- 補液量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VS2'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_CODE'' ), '''' ) AS e01,--項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_ATTR'' ), '''' ) AS e02,--項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_NAME'' ), '''' ) AS e03,--項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ), ''FM0000099.990'' ) AS e04,--数量
  ''1'' AS e05,-- 選択単位フラグ
	COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e06,--単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e07,--単位名称
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_UP_LIQUID'' ), '''' ) ) AS sortTag ,
'''' as sorttag1,
'''' as sorttag2
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo



  AND TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ) > 1 
  AND (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
  AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') in (''0'',''1'',''2'') 
  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
  OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
 ) 
 UNION ALL
 (-- レセプトメモ
 SELECT
  ''実績詳細'' AS detail_id,
  '''' AS sbt_key,
  COALESCE ( mdd.in_hospital_cd_1, '''' ) AS e01,--コード
  COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_ATTR'' ), '''' ) AS e02,
  COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  ''33'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_RECORD'' ), '''' ) AS sortTag,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord
  CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addi
  LEFT OUTER JOIN mst_addition AS mad ON mad.addition_cd = to_number( addi ->> ''cd'', ''9999999999'' )
  CROSS JOIN LATERAL json_array_elements ( mad.addition_tar_cd :: json ) addtr
  LEFT OUTER JOIN mst_dialysis_difficulty AS mdd ON mdd.dialysis_difficulty_cd = to_number( addtr ->> ''cd'', ''9999999999'' ) 
 WHERE
  mad.addition_cond = ''2'' 
  AND addi ->> ''is_enable'' = ''1'' 
  AND mad.addition_class = ''2'' 
  AND ord.ord_no = @ordNo



  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) IS NOT NULL 
  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) <> ''0'' 
 )
 UNION ALL
 (-- 加算・管理料
 SELECT
  ''実績詳細'' AS detail_id,
  ''VAB'' AS sbt_key,
  COALESCE ( adt.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
	COALESCE ( adt.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_ATTR'' ) ) AS e02,-- 項目属性
  COALESCE ( SUBSTRING ( adt.addition_name, 1, 25 ), '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  '''' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag ,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord
	CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
	LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
 WHERE
  addition ->> ''is_enable'' = ''1''
  AND ord.ord_no = @ordNo



 ) 
 ) all_cost 
WHERE
  all_cost.sortTag IS NOT NULL and
  all_cost.e01 IS NOT NULL AND all_cost.e01 <> ''''
), 
data_oxygen as
	(--酸素吸入手技・酸素吸入量、の順序
	select detail_id,e01,e02,e03,e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''酸素''::text as  aa from (
   (-- 酸素吸入手技
    SELECT
     ''実績詳細'' AS detail_id,
     ''VQ1'' AS sbt_key,
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_CODE'' ), '''' ) AS e01,-- 項目コード
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_ATTR'' ), '''' ) AS e02,-- 項目属性
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_NAME'' ), '''' ) AS e03,-- 項目名称
     ''0000000.000'' AS e04,-- 数量
     ''0'' AS e05,-- 選択単位フラグ
     '''' AS e06,-- 単位コード
     '''' AS e07,-- 単位名称
     '''' AS e08,
     '''' AS e09,
     ''31'' AS e10,
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_TAG'' ), '''' ) AS e11,-- タグ名称
   	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN''), '''') AS sortTag,
		'''' as sorttag1,
			'''' as sorttag2,
    ROW_NUMBER() OVER()::text as ordernow
    FROM
     ord_main AS ord
     CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
    WHERE
     oxy ->> ''treat_class'' = ''3'' 
   	AND  (oxy ->> ''oxygen_amount'') is not NULL
     AND ord.ord_no = @ordNo



     AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_FLAG'' ) = ''1'' 
   	AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 
    ) 
   UNION ALL
 (-- 酸素吸入
 SELECT
  ''実績詳細'' AS detail_id,
  ''VQ1'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_NAME'' ), '''' ) AS e03,-- 項目名称
  COALESCE( TO_CHAR(TO_NUMBER(oxy ->> ''oxygen_amount'',''9999999999.999''),''FM0999999.990'') ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''31'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_TAG'' ), '''' ) AS e11,-- タグ名称
  COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN''), '''') AS sortTag,
	'''' as sorttag1,
			'''' as sorttag2,
  ROW_NUMBER() OVER()::text as ordernow
 FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 
	AND  (oxy ->> ''oxygen_amount'') is not NULL
  AND ord.ord_no = @ordNo



  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 

 )) as aa1 order by ordernow,e04),
 data_soap_inikey as(
 select * from (
select * from (
select *,ROW_NUMBER() OVER(PARTITION by pet.pat_event_cd order by ordernow1)::INTEGER as ordernow from (
  select 
	''S''::text as title,
	input_params_info :: json ->> ''field_name'' as field_name,
(input_params_info :: json ->> ''item_json'')::json->> ''is_formatting''
	as is_formatting,
	pet.pat_event_cd ,
	ROW_NUMBER() OVER()::INTEGER as ordernow1
	from pat_event pet,jsonb_array_elements(pet.input_params) as input_params_info
WHERE pet.ord_no = @ordNo and is_del = ''0'' 
	) as pet ) as pet where pet.field_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''S_FIELD'' ), '''' )
		union all
select * from (
select *,ROW_NUMBER() OVER(PARTITION by pet.pat_event_cd order by ordernow1)::INTEGER as ordernow from (
  select 
	''O''::text as title,
	input_params_info :: json ->> ''field_name'' as field_name,
(input_params_info :: json ->> ''item_json'')::json->> ''is_formatting''
	as is_formatting,
	pet.pat_event_cd ,
	ROW_NUMBER() OVER()::INTEGER as ordernow1
	from pat_event pet,jsonb_array_elements(pet.input_params) as input_params_info
WHERE pet.ord_no = @ordNo and is_del = ''0'' 
	) as pet ) as pet where pet.field_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''O_FIELD'' ), '''' )
		union all
		select * from (
select *,ROW_NUMBER() OVER(PARTITION by pet.pat_event_cd order by ordernow1)::INTEGER as ordernow from (
  select 
	''A''::text as title,
	input_params_info :: json ->> ''field_name'' as field_name,
(input_params_info :: json ->> ''item_json'')::json->> ''is_formatting''
	as is_formatting,
	pet.pat_event_cd ,
	ROW_NUMBER() OVER()::INTEGER as ordernow1
	from pat_event pet,jsonb_array_elements(pet.input_params) as input_params_info
WHERE pet.ord_no = @ordNo and is_del = ''0'' 
	) as pet ) as pet where pet.field_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''A_FIELD'' ), '''' )
		union all
		select * from (
select *,ROW_NUMBER() OVER(PARTITION by pet.pat_event_cd order by ordernow1)::INTEGER as ordernow from (
  select 
	''P''::text as title,
	input_params_info :: json ->> ''field_name'' as field_name,
(input_params_info :: json ->> ''item_json'')::json->> ''is_formatting''
	as is_formatting,
	pet.pat_event_cd ,
	ROW_NUMBER() OVER()::INTEGER as ordernow1
	from pat_event pet,jsonb_array_elements(pet.input_params) as input_params_info
WHERE pet.ord_no = @ordNo and is_del = ''0'' 
	) as pet ) as pet where pet.field_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''P_FIELD'' ), '''' )
	)	as soap order by pat_event_cd,ordernow
),

 data_soap as
 (
 SELECT detail_id,e01,e02,e03,e04,e05,e06,e07,e08,e09,e10,e11,e12,sortTag,sortTag1,sortTag2,''SOAP''::text as  aa
FROM(
 (--  実施コメンSOAP ト S
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC5'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_S'' ), '''' ) AS e02,
	case when data_soap_inikey.is_formatting = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->>     ''result_value'',50),E''[\\n\\r]'','' '',''g'')
  when data_soap_inikey.is_formatting = ''1''
	then REGEXP_REPLACE(REGEXP_REPLACE(((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->> ''result_value'')::text,''(<br />)|(</p>)'','' '',''g''),''<[^<]*?>'','''',''g'')
 	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_S'' ), '''' ) AS e11,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''S_FIELD'' ), '''' ) AS e12,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''1'' ) AS sortTag,
  pet.pat_event_cd ::TEXT as sorttag1,
	''1'' as sorttag2
	FROM pat_event pet
-- 	LEFT JOIN mst_pat_event_data_template petdt
-- 	ON pet.template_cd = petdt.template_cd
	LEFT JOIN mst_pat_event_sub_category petcg
	ON (pet.sub_category_cd = petcg.sub_category_cd
	and pet.sub_category_name = petcg.sub_category_name
	)
		LEFT JOIN data_soap_inikey ON (
	pet.pat_event_cd = data_soap_inikey.pat_event_cd
	and data_soap_inikey.title = ''S''
	)
	WHERE pet.ord_no = @ordNo
	AND pet.facility_cd = @facilityCd
	AND pet.is_del = ''0''
	AND pet.category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''CATEGORY'' ), '''' )
	AND petcg.sub_category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''SUB_CATEGORY'' ), '''' )
-- 	AND (pet.input_params ::json ->> 0) ::json->> ''field_name''= COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''S_FIELD'' ), '''' )
 )
	 UNION ALL
 (--  実施コメンSOAP ト A
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC7'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_A'' ), '''' ) AS e02,
	case when data_soap_inikey.is_formatting = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->>     ''result_value'',50),E''[\\n\\r]'','' '',''g'')
  when data_soap_inikey.is_formatting = ''1''
	then REGEXP_REPLACE(REGEXP_REPLACE(((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->> ''result_value'')::text,''(<br />)|(</p>)'','' '',''g''),''<[^<]*?>'','''',''g'')
 	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  '''' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_A'' ), '''' ) AS e11,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''A_FIELD'' ), '''' ) AS e12,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''3'' ) AS sortTag,
	pet.pat_event_cd ::TEXT as sorttag1,
	''3'' as sorttag2
	FROM pat_event pet
-- 	LEFT JOIN mst_pat_event_data_template petdt
-- 	ON pet.template_cd = petdt.template_cd
	LEFT JOIN mst_pat_event_sub_category petcg
	ON (pet.sub_category_cd = petcg.sub_category_cd
	and pet.sub_category_name = petcg.sub_category_name
	)
	LEFT JOIN data_soap_inikey ON (
	pet.pat_event_cd = data_soap_inikey.pat_event_cd
	and data_soap_inikey.title = ''A''
	)
	WHERE pet.ord_no = @ordNo
	AND pet.facility_cd = @facilityCd
	AND pet.is_del = ''0'' 
	AND pet.category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''CATEGORY'' ), '''' )
	AND petcg.sub_category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''SUB_CATEGORY'' ), '''' )
-- 	AND (pet.input_params ::json ->> 2) ::json->> ''field_name''= COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''A_FIELD'' ), '''' )
) UNION ALL
 (--  実施コメンSOAP ト O
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC6'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_O'' ), '''' ) AS e02,
	case when data_soap_inikey.is_formatting = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->>     ''result_value'',50),E''[\\n\\r]'','' '',''g'')
  when data_soap_inikey.is_formatting = ''1''
	then REGEXP_REPLACE(REGEXP_REPLACE(((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->> ''result_value'')::text,''(<br />)|(</p>)'','' '',''g''),''<[^<]*?>'','''',''g'')
 	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_O'' ), '''' ) AS e11,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''O_FIELD'' ), '''' ) AS e12,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''2'' ) AS sortTag,
   pet.pat_event_cd ::TEXT as sorttag1,
	 ''2'' as sorttag2	
	FROM pat_event pet
	LEFT JOIN mst_pat_event_data_template petdt
	ON pet.template_cd = petdt.template_cd
	LEFT JOIN mst_pat_event_sub_category petcg
	ON (pet.sub_category_cd = petcg.sub_category_cd
	and pet.sub_category_name = petcg.sub_category_name
	)
	LEFT JOIN data_soap_inikey ON (
	pet.pat_event_cd = data_soap_inikey.pat_event_cd
	and data_soap_inikey.title = ''O''
	)
	WHERE pet.ord_no = @ordNo
	AND pet.facility_cd = @facilityCd
	AND pet.is_del = ''0'' 
	AND pet.category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''CATEGORY'' ), '''' )
	AND petcg.sub_category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''SUB_CATEGORY'' ), '''' )
-- 	AND (pet.input_params ::json ->> 1) ::json->> ''field_name''= COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''O_FIELD'' ), '''' )
) UNION ALL
 (--  実施コメンSOAP ト P
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC8'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_P'' ), '''' ) AS e02,
	case when data_soap_inikey.is_formatting = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->>     ''result_value'',50),E''[\\n\\r]'','' '',''g'')
  when data_soap_inikey.is_formatting = ''1''
	then REGEXP_REPLACE(REGEXP_REPLACE(((pet.result_params ::json ->> data_soap_inikey.ordernow::INTEGER-1) ::json->> ''result_value'')::text,''(<br />)|(</p>)'','' '',''g''),''<[^<]*?>'','''',''g'')
 	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_P'' ), '''' ) AS e11,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''P_FIELD'' ), '''' ) AS e12,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''4'' ) AS sortTag,
   pet.pat_event_cd ::TEXT as sorttag1,
	 ''4'' as sorttag2		
	FROM pat_event pet
-- 	LEFT JOIN mst_pat_event_data_template petdt
-- 	ON pet.template_cd = petdt.template_cd
	LEFT JOIN mst_pat_event_sub_category petcg
	ON (pet.sub_category_cd = petcg.sub_category_cd
	and pet.sub_category_name = petcg.sub_category_name
	)
	LEFT JOIN data_soap_inikey ON (
	pet.pat_event_cd = data_soap_inikey.pat_event_cd
	and data_soap_inikey.title = ''P''
	)
	WHERE pet.ord_no = @ordNo
	AND pet.facility_cd = @facilityCd
	AND pet.is_del = ''0'' 
	AND pet.category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''CATEGORY'' ), '''' )
	AND petcg.sub_category_name = COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''SUB_CATEGORY'' ), '''' )
-- 		AND (pet.input_params ::json ->> 3) ::json->> ''field_name''= COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''P_FIELD'' ), '''' )
 )
 ) B
 	ORDER BY B.sorttag1 ,B.sorttag2 :: INTEGER),
	equip_all_copy as
(
(--  処置薬品名-手技あり薬剤
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999.999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	medi ->> ''no''  as sorttag1,
	''2'' as sorttag2,
	  (medi->>''cd'') as mdcd,
		(medi->>''class_cd'') as mdclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    ord.ord_no = @ordNo


    AND medi->>''medicine_type'' = ''1'' 
    AND medi ->> ''procedure_cd'' IS NOT NULL
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 ) UNION ALL
(--  処置薬品名-手技なし薬剤
SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999.999''),''FM0999999.990'') )  AS e04,-- 数量

    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	medi ->> ''no'' as sorttag1,
	''3'' as sorttag2,
	(medi->>''cd'') as mdcd,
	(medi->>''class_cd'') as mdclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    ord.ord_no = @ordNo


    AND medi->>''medicine_type'' = ''1'' 
    AND (medi ->> ''procedure_cd'' IS  NULL
    or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
   or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 )
union all
(--  処置薬品名-手技あり薬剤
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999.999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	 (medi->>''no'') as sorttag1,
	''22'' as sorttag2,
	(medi->>''cd'') as mdcd,
	(medi->>''class_cd'') as mdclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    ord.ord_no = @ordNo


    AND medi->>''medicine_type'' = ''2'' 
    AND medi ->> ''procedure_cd'' IS NOT NULL
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 ) UNION ALL
(--  処置薬品名-手技なし薬剤
SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999.999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	(medi->>''no'') as sorttag1,
	''33'' as sorttag2,
	(medi->>''cd'') as mdcd,
	(medi->>''class_cd'') as mdclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    ord.ord_no = @ordNo


    AND medi->>''medicine_type'' = ''2'' 
    AND (medi ->> ''procedure_cd'' IS  NULL
    or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
   or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 )
),
data_all AS (
SELECT data_middle_all.*,''''::text as equipment_cd,''''::text as mqclass_cd
FROM data_middle_all
union all		
	 (
 SELECT
    --医療材料情報
     ''実績詳細'' AS detail_id, 
		 	''VR1'' AS sbt_key,
     --項目コード
     COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
     --項目属性
     COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
     --項目名称
     COALESCE(meq.equipment_name, '''') AS e03, 
     --数量
     COALESCE(TO_CHAR(TO_NUMBER(equip->>''amount'',''9999999.999'') ,''FM0999999.990''), '''') AS e04, 
     --選択単位フラグ
     CASE WHEN meq.unit IS NULL OR meq.unit = ''''
     THEN ''0'' ELSE ''1'' END AS e05, 
     --単位コード
     COALESCE(meq.unit, '''') AS e06, 
     --単位名称
     COALESCE(meq.unit, '''') AS e07, 
      '''' AS e08,
      '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag ,
		 	'''' as sorttag1,
			'''' as sorttag2,
			equip->>''cd'' as equipment_cd,
			equip->>''class_cd'' as mqclass_cd
 FROM
     ord_main ord
     cross join lateral json_array_elements (ord.rst_equip_info :: json) equip

 LEFT OUTER JOIN
     mst_equipment meq
 ON
     meq.equipment_cd = TO_NUMBER(equip->>''cd'',''999999999999'')  
 LEFT OUTER JOIN
     mst_equipment_class meqc
 ON
     meq.class_cd = meqc.class_cd
 WHERE
     ord.ord_no = @ordNo



 AND
     equip->>''equip_type'' = ''0''  		 
			 )		
),
data_all_copy AS (--と薬剤、の適合
SELECT equip_all_copy.detail_id, equip_all_copy.sbt_key,equip_all_copy.e01, equip_all_copy.e02, equip_all_copy.e03, equip_all_copy.e04, equip_all_copy.e05, equip_all_copy.e06, equip_all_copy.e07, equip_all_copy.e08, equip_all_copy.e09,equip_all_copy.e10,equip_all_copy.e11,equip_all_copy.sortTag
       ,sortTag1,sortTag2,mdcd,mdclass 
FROM equip_all_copy 
		where (sorttag2= ''2'' or sorttag2= ''3'')
union all
SELECT equip_all_copy.detail_id, equip_all_copy.sbt_key,equip_all_copy.e01, equip_all_copy.e02, equip_all_copy.e03, equip_all_copy.e04, equip_all_copy.e05, equip_all_copy.e06, equip_all_copy.e07, equip_all_copy.e08, equip_all_copy.e09,equip_all_copy.e10,equip_all_copy.e11,equip_all_copy.sortTag
       ,sortTag1,sortTag2,mdcd,mdclass
FROM equip_all_copy 
		where (sorttag2= ''22'' or sorttag2= ''33'')
),
data_commmon as(--一般のモジュール
select detail_id, e01,e02,e03,data_all.e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''一般''::text as aa
			 from data_all where 
		 sorttag <> (SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'')
),
data_all_meq0 as (
 select detail_id, e01,e02,e03,data_all.e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''治療条件''::text as  aa,equipment_cd,mqclass_cd 
			 from data_all where sorttag=(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'') and sortTag2 =''18'' 
),
data_all_meq as(--医療材料のモジュール
select detail_id, e01,e02,e03,data_all.e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''医療材料''::text as  aa,equipment_cd,mqclass_cd 
			 from data_all where sorttag=(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'')	and sortTag2 !=''18'' 
),
 order_qcode_F AS (--医療材料の1，2场合
 SELECT DISTINCT ON (item_cd_f)* FROM (
   SELECT
     e01 AS item_cd_f,  
     CASE WHEN ''1'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_qcd_f,
     CASE WHEN ''2'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_code_order :: text, ''999999999999'' ) ELSE NULL END AS meq_cd_f
   FROM
     data_all_meq
     LEFT OUTER JOIN do_mstmeq_cd ON meq_code::text = data_all_meq.equipment_cd
     LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code ::text= data_all_meq.mqclass_cd
   ORDER BY item_cd_f asc) AS order_code_middle_QA 
 ), order_qcode_S AS (--医療材料のない治療条件0场合
   SELECT
     (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
     CASE WHEN ''0'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
		 (SELECT COALESCE(TO_CHAR(TO_NUMBER(eqp->> ''amount'',''9999999.999'') ,''FM0999999.990''), '''') FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'', ''FM0999999.990'')) AS amount,
		 ROW_NUMBER() OVER() as class_cd,
		 ROW_NUMBER() OVER() as equip_cd
   FROM
     ord_main AS ord
     CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(eqp, json_idx)
   WHERE ord.ord_no = @ordNo



   ORDER BY item_cd_s, login_ord_s asc
 	)	,
	
	dataequipOrder as(--医療材料の0场合すでにソートされている
 		select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sortTag,sortTag1,sortTag2,aa,ROW_NUMBER() OVER() as login_ord,class_cd,equip_cd from (
 	(select distinct ''実績詳細'' as detail_id, order_qcode_S.item_cd_s as e01, data_all_meq.e02, data_all_meq.e03, 
 		order_qcode_S.amount as e04, data_all_meq.e05, data_all_meq.e06, data_all_meq.e07, data_all_meq.e08,
 		data_all_meq.e09,data_all_meq.e10,data_all_meq.e11,data_all_meq.sortTag,data_all_meq.sortTag1,data_all_meq.sortTag2,
 		data_all_meq.aa,order_qcode_S.login_ord_s,
     class_cd, 
      equip_cd
 		from order_qcode_S,data_all_meq where order_qcode_S.item_cd_s = data_all_meq.e01 
		and aa = ''医療材料''
		and order_qcode_S.amount = data_all_meq.e04 order by login_ord_s
     )) as dataequipOrder),
		  dataequipOrder1 as(
 	select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sortTag,sortTag1,sortTag2,aa, 
 	
 	dataequipOrder.login_ord,order_qcode_F.class_qcd_f as class_cd,order_qcode_F.meq_cd_f as equip_cd
 	from dataequipOrder,order_qcode_F where dataequipOrder.e01 =order_qcode_F.item_cd_f ), 
 	 equip_order as(--医療材料の最終版
 SELECT  detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag, sortTag1,sortTag2, aa
 -- ,login_ord,class_cd,equip_cd
 FROM dataequipOrder1
 ORDER BY 
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 2 THEN equip_cd END
 				 ),
	equip_order1 as (--最終版
(SELECT  detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag, sortTag1,sortTag2, aa from data_all_meq0 order by sortTag1)
				 union all
(SELECT  detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag, sortTag1,sortTag2, aa from equip_order))			 
 , order_code_F AS (--薬剤ない手技のない治療条件1,3场合
   SELECT
     e01 AS item_cd_f, 
		 data_all_copy.Sorttag1 as medi_no, 
		 ''1'':: text as medicine_type,
     CASE WHEN ''1'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_cd_f,
     CASE WHEN ''3'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_code_order :: text, ''999999999999'' ) ELSE NULL END AS medi_cd_f
   FROM
     data_all_copy
     LEFT OUTER JOIN do_mstmedi_cd ON medi_code ::text= data_all_copy.mdcd
     LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code ::text  = data_all_copy.mdclass
		 where sorttag2 = ''2'' or sorttag2 = ''3''
   ORDER BY item_cd_f asc 
 ),
 order_code_G AS (--薬剤ない手技のない治療条件1,3场合
 select * from order_code_F
 union all
   (SELECT
    e01 AS item_cd_f, 
		data_all_copy.Sorttag1 as medi_no,
		''2''::text as medicine_type,
     CASE WHEN ''1'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_cd_f,
     CASE WHEN ''3'' in (SELECT a1 FROM do_order_data_from) THEN 
     (select max(medi_cd_f) from order_code_F)+ TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) 
		 ELSE NULL END AS medi_cd_f
   FROM
     data_all_copy
		 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd ::text = data_all_copy.mdcd
     LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
     LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code ::text  = data_all_copy.mdclass
		 where sorttag2 = ''22'' or sorttag2 = ''33''
   ORDER BY item_cd_f asc )
 ),
 order_code_S AS (--薬剤ない手技のない治療条件0,2,4,5,6场合
SELECT
	 (case when medi->>''medicine_type'' = ''1'' then  
     (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999''))
	 else  (SELECT in_hospital_cd_1 FROM mst_medicine_mix WHERE medicine_mix_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'')) 
	 end ) as item_cd_s,
     CASE WHEN ''0'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
     CASE WHEN ''2'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) ELSE NULL END AS medicine_type_s,
     CASE WHEN ''4'' in (SELECT a1 FROM do_order_data_from) THEN 
		 TO_NUMBER( timing_code_order :: text, ''999999999999'' ) 
		 ELSE NULL END AS timing_cd_s,
     CASE WHEN (''5'' in (SELECT a1 FROM do_order_data_from)
		 ) THEN
		   TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) 
		 ELSE NULL END AS procedure_cd_s,
     CASE WHEN ''6'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) ELSE NULL END AS date_interval_s,
		  medi ->> ''no'' as medi_no,
			medi ->> ''medicine_type'' ::text as medicine_type
   FROM
 
     ord_main AS ord
     CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
 WHERE ord.ord_no = @ordNo

ORDER BY item_cd_s, login_ord_s asc
 )
 , dataAndOrder AS (--薬剤ない手技のない治療条件0,1,2,3,4,5,6场合
  SELECT DISTINCT ON (sortTag2,e01,e04,sortTag1,sortTag)* FROM (
 SELECT
     distinct detail_id,sbt_key, 
		 e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sortTag,sortTag1,sortTag2,
     order_code_S.login_ord_s AS login_ord,
     order_code_G.class_cd_f  AS class_cd,
		 order_code_S.medicine_type_s AS medicine_type, 
		 		 order_code_G.medi_cd_f  AS medi_cd,
		 order_code_S.timing_cd_s  AS timing_cd,
		 order_code_S.procedure_cd_s AS procedure_cd, 
		 order_code_S.date_interval_s AS date_interval
 FROM
     data_all_copy,order_code_S,order_code_G where   
		  order_code_G.medicine_type = order_code_S.medicine_type and
		 order_code_S.medi_no = data_all_copy.sortTag1
		 and order_code_S.medi_no=order_code_G.medi_no
		 )  AS order_code_middle_B
		 
 ),
 med_order as(--薬剤ない手技の场合
 SELECT med_orderA.*,ROW_NUMBER() OVER()::INTEGER as ordernow FROM (
 SELECT
     detail_id,sbt_key,e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag,sortTag1,sortTag2,''薬剤''::text as  aa,
		 login_ord, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
 FROM
      dataAndOrder
  ORDER BY 
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
           WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END
  ) AS med_orderA
  ),
   med_orderA as(--单体手技取得
   (SELECT
     ''実績詳細''::text AS detail_id,
  	'' ''::text as sbt_key,
     COALESCE ( mp.in_hospital_cd_a1, '''' )::text AS e01,-- 項目コード
    COALESCE ( mp.in_hospital_cd_a2, ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_PROCEDURE_ATTR'' ), '''' ) ), '''' )::text AS e02,-- 項目属性
     COALESCE ( mp.pricedure_name, '''' )::text AS e03,-- 項目名称
     ''0000000.000''::text AS e04,-- 数量
     ''0''::text AS e05,-- 選択単位フラグ
     ''''::text AS e06,-- 単位コード
     ''''::text AS e07,-- 単位名称
     ''''::text AS e08,
     ''''::text AS e09,
     ''29''::text AS e10,
     COALESCE ( (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1 ), '''' )::text AS e11,-- タグ名称
     COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')::text AS sortTag,
   (medi->>''no'')::text as sortTag1,
   ''1''::text as sortTag2,
   ''单体手技''::text as aa,
	  med_order.ordernow::INTEGER  as ordernow
    from 
     ord_main ord
   	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
   	LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
		LEFT OUTER JOIN med_order ON med_order.sorttag1= (medi->>''no'') and (med_order.sorttag2 = ''2'' or med_order.sorttag2 = ''3'')
    WHERE
    ord.ord_no = @ordNo

 
  	AND medi->>''medicine_type'' = ''1'' 																																																			
    AND medi ->> ''procedure_cd'' IS NOT NULL
    and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) is not NULL
    and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) != '''')
		union all
		(SELECT
     ''実績詳細''::text AS detail_id,
  	 '' ''::text as sbt_key,
     COALESCE ( mp.in_hospital_cd_a1, '''' )::text AS e01,-- 項目コード
    COALESCE ( mp.in_hospital_cd_a2, ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_PROCEDURE_ATTR'' ), '''' ) ), '''' )::text AS e02,-- 項目属性
     COALESCE ( mp.pricedure_name, '''' )::text AS e03,-- 項目名称
     ''0000000.000''::text AS e04,-- 数量
     ''0''::text AS e05,-- 選択単位フラグ
     ''''::text AS e06,-- 単位コード
     ''''::text AS e07,-- 単位名称
     ''''::text AS e08,
     ''''::text AS e09,
     ''29''::text AS e10,
     COALESCE ( (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1 ), '''' )::text AS e11,-- タグ名称
     COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')::text AS sortTag,
   (medi->>''no'')::text as sortTag1,
   ''1''::text as sortTag2,
   ''調製手技''::text as aa,
	  med_order.ordernow::INTEGER  as ordernow
    from 
     ord_main ord
   	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
   	LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
		LEFT OUTER JOIN med_order ON med_order.sorttag1= (medi->>''no'') and (med_order.sorttag2 = ''22'' or med_order.sorttag2 = ''33'')
    WHERE
    ord.ord_no = @ordNo

 
  	AND medi->>''medicine_type'' = ''2'' 																																																			
    AND medi ->> ''procedure_cd'' IS NOT NULL
    and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) is not NULL
    and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) != '''')
		
		
		),
  med_orderB as (--調製分裂
 select * from ( (
   SELECT
    ''実績詳細'' AS detail_id,
    ''VO2'' AS sbt_key,
     CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01, 
  	  COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
  	  COALESCE(mmd.medicine_name, '''''''') AS e03, 
  	 
  	 
    COALESCE( TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) )  AS e04,-- 数量
  
      CASE 
        WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
             (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
          THEN ''0'' 
        ELSE ''1''
      END AS e05, -- 選択単位フラグ
     COALESCE(mmd.unit, '''''''') AS e06,  --単位コード
     COALESCE(mmd.unit, '''''''') AS e07, --単位名称
    '''' AS e08,
    '''' AS e09,
    ''29'' AS e10,
    COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
  	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
  	(medi->>''no'')  as sorttag1,
  	''22'' as sorttag2,
		''調製'' as aa,
			(SELECT login_ord_in_mm FROM do_medicine_mix_in_orders 
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd 
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm)::text AS ord_medicine_mix
    FROM
  ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
  WHERE
      ord.ord_no = @ordNo

 
      AND medi->>''medicine_type'' = ''2'' 
      AND medi ->> ''procedure_cd'' IS NOT NULL
      AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
      AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
  )
  UNION ALL
  (
   SELECT
    ''実績詳細'' AS detail_id,
    ''VO2'' AS sbt_key,
     CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01, 
  	  COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
  	  COALESCE(mmd.medicine_name, '''''''') AS e03, 
  	 
  	 
        COALESCE( TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) )  AS e04,-- 数量
      CASE 
        WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
             (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
          THEN ''0'' 
        ELSE ''1''
      END AS e05, -- 選択単位フラグ
     COALESCE(mmd.unit, '''''''') AS e06,  --単位コード
     COALESCE(mmd.unit, '''''''') AS e07, --単位名称
    '''' AS e08,
    '''' AS e09,
    ''29'' AS e10,
    COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
  	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
  	(medi->>''no'')  as sorttag1,
  	''33'' as sorttag2,
		''調製'' as aa,
		(SELECT login_ord_in_mm FROM do_medicine_mix_in_orders 
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd 
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm)::text AS ord_medicine_mix
    FROM
  ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
  WHERE
      ord.ord_no = @ordNo

 
      AND medi->>''medicine_type'' = ''2'' 
      AND (medi ->> ''procedure_cd'' IS  NULL
      or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
     or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
  )) as med_orderB where  e01 <>''''
	 order by sorttag1,ord_medicine_mix
  ),
  med_orderC as (--調製薬剤グループ
	select detail_id,sbt_key,e01,e02,e03,e04,e05,e06,e07,e08,e09,e10,e11,sorttag,sorttag1,sorttag2,aa,ordernow from (
	select med_orderA.*,''''::text as ord_medicine_mix from med_orderA
	where ordernow is not null and aa = ''单体手技'' and  sorttag1 in (select sorttag1 from med_order where (sorttag2= ''2'' or sorttag2= ''3'')    and e01 != '''')
	union all
	select med_orderA.*,''''::text as ord_medicine_mix from med_orderA
	where ordernow is not null and aa = ''調製手技'' and sorttag1 in (select sorttag1 from med_orderB)
	union all
  (select detail_id,sbt_key,e01,e02,e03,e04,e05,e06,e07,e08,e09,e10,e11,sorttag,sorttag1,sorttag2,aa,ordernow,''''::text as ord_medicine_mix
	from med_order
  where sorttag2 != ''22'' and  sorttag2 != ''33''
  union all
  select med_orderB.detail_id, med_orderB.sbt_key,med_orderB.e01, med_orderB.e02,
	 med_orderB.e03,med_orderB.e04,	med_orderB.e05,	med_orderB.e06, med_orderB.e07,	
	 med_orderB.e08,med_orderB.e09,	med_orderB.e10,	med_orderB.e11,	med_orderB.sorttag,
	 med_orderB.sorttag1,med_orderB.sorttag2,med_orderB.aa,med_order.ordernow,med_orderB.ord_medicine_mix::text
   from med_orderB, med_order where med_orderB.sorttag1 = med_order.sorttag1)
	order by ordernow ,sorttag1,ord_medicine_mix,sorttag2,e04) as med_orderC
	),
	kou_coag_procedu AS(
    SELECT
    * 
FROM
    ( SELECT 
   ''実績詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM int_set_medicine_resolve WHERE key2 =''KOU_COAG_PROCEDURE_CODE''),'''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM int_set_medicine_resolve WHERE key2 =''KOU_COAG_PROCEDURE_ATTR''),'''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM int_set_medicine_resolve WHERE key2 =''KOU_COAG_PROCEDURE_NAME''),'''')  AS e03, 
    --数量
   ''0000000.000'' AS e04, 
    --選択単位フラグ
   ''0'' AS e05, 
    --単位コード
   '''' AS e06, 
    --単位名称
   '''' AS e07, 
	 '''' AS e08, 
	 '''' AS e09, 
   ''0000000.000'' AS e10,
	 COALESCE(((SELECT VALUE FROM kou_coag_procedur_data)),'''') AS e11,-- タグ名称
    --出力順
  (COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')::INTEGER - 0.2) :: text AS sorttag ,  
	 ''0'' as sorttag1,
   '''' as sorttag2,
   ''抗凝固剤手技'' as aa,
	 null as ord_medicine_mix
     FROM kou_coag_procedur_falg
         WHERE ctl = 1 
         AND ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')       
                AND EXISTS(SELECT 1 FROM ord_main ord  WHERE ord.ord_no = @ordNoand   (rst_cond_info->''25''->>''value'' is NOT NULL) AND (rst_cond_info->''25''->>''medicine_type'' = ''2'') )
        ) T
        
        UNION 
    SELECT
    --⑯抗凝固剤・初回(調製情報)
    ''実績詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
    --項目属性
        CASE (select ctl FROM kou_coag_procedur_falg) WHEN 1  THEN COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''') WHEN 2 THEN COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''') ELSE ''''  end AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
    --選択単位フラグ
    CASE 
      WHEN mmd.unit IS NULL OR 
          mmd.unit = ''''
        THEN ''0''
          ELSE ''1''
  
    END AS e05, 
    --単位コード
   COALESCE(mmd.unit, '''') AS e06,
    --単位名称
   COALESCE(mmd.unit, '''') AS e07,
	 '''' as e08,
	 '''' as e09,
	 ''0000000.000'' as e10,
    --タグ名称
   COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e11, 
(COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')::INTEGER - 0.1) :: text AS sorttag , 
    ''1'' as sorttag1,
    '''' as sorttag2,
    ''抗凝固剤'' as aa,
		(SELECT ordernow FROM do_medicine_mix_in_orders1 
                            WHERE TO_NUMBER(mmxd ->> ''cd'', ''999999999999'') = medicine_cd::INTEGER )::text AS ord_medicine_mix
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info->''25''->>''value'',''999999999999'')
 CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
 ord.ord_no = @ordNoand
    ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
        AND ord.rst_cond_info->''25''->>''medicine_type'' = ''2''
        AND (mmd.in_hospital_cd_2 IS NULL OR mmd.in_hospital_cd_2 ='''')
          UNION
  SELECT
      --⑯抗凝固剤・初回(調製情報)
      ''実績詳細'' AS detail_id, 
      --項目コード
          CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
      --項目属性
      COALESCE(mmd.in_hospital_cd_2, '''') AS e02, 
      --項目名称
      COALESCE(mmd.medicine_name, '''') AS e03,
      --数量
      COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
      --選択単位フラグ
      CASE 
        WHEN mmd.unit IS NULL OR 
            mmd.unit = ''''
          THEN ''0''
            ELSE ''1''
    
      END AS e05, 
      --単位コード
     COALESCE(mmd.unit, '''') AS e06,
      --単位名称
     COALESCE(mmd.unit, '''') AS e07,
      --タグ名称
     '''' as e08,
	   '''' as e09,
	   ''0000000.000'' as e10,
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e11, 
(COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')::INTEGER - 0.1) :: text AS sorttag , 
      ''2'' as sorttag1,
      '''' as sorttag2,
      ''抗凝固剤'' as aa,
			(SELECT ordernow FROM do_medicine_mix_in_orders1 
                            WHERE TO_NUMBER(mmxd ->> ''cd'', ''999999999999'') = medicine_cd::INTEGER )::text AS ord_medicine_mix
  FROM
      ord_main ord
  LEFT OUTER JOIN
      mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info->''25''->>''value'',''999999999999'')
   CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
  WHERE
	   ord.ord_no = @ordNo
		 and
      ((SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
          (SELECT value FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
          AND ord.rst_cond_info->''25''->>''medicine_type'' = ''2''
          AND (mmd.in_hospital_cd_2 IS NOT NULL OR mmd.in_hospital_cd_2 <>'''')
          AND ((select ctl FROM kou_coag_procedur_falg) = 1   OR (select ctl FROM kou_coag_procedur_falg) = 2) 
 ),
  data_soap_check as(
 select sortTag1 from (
select sortTag1,count(1) as count from data_soap where e03 = '''' or e03 is null group by sortTag1 ) as data_soap_check
where  count = 4
 )
 select * from (
 select *, ROW_NUMBER() OVER()::INTEGER as ordernow from 
   ( select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,sorttag::text,sortTag1::text,sortTag2::text,aa from kou_coag_procedu
	where  (select count(1) from kou_coag_procedu where aa = ''抗凝固剤'' and e01 !='''') >0
and e01 !=''''
	order by sorttag,ord_medicine_mix ) as kou_coag_procedu
 union all
  ( select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
   sorttag::text,sortTag1::text,sortTag2::text,aa, null as ordernow from data_commmon)
 	union all
   (select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
   sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from med_orderC)
 	union all
 	(select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
   sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from equip_order1)
 	union all
--  	(select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
--    sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from data_soap)
 	(select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
   ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ),'''' ))::text as sorttag,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from data_soap
	 where sortTag1 not in ( select sortTag1 from data_soap_check)
	 )
 	union all
 	(select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
   sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from data_oxygen)
 	) as aaaa where  e01<>'''' and  e01 IS NOT NULL
 	order by sorttag,ordernow', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）実績繰り返し部', '2020-04-24 19:15:25.001',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -79, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}]');
