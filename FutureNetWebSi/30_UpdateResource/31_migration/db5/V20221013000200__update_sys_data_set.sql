DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (-101);
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
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
 ),
 device AS (
		SELECT device_mode
		FROM mst_treatment mst JOIN ord_main ord 
		ON ord.rst_treatment_cd = mst.treatment_cd 
		AND ord.ord_no = @ordNo
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
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
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
  AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
 ),
 DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」 
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
		AND info ->> ''key1'' = ''FJI_COM_INFO'' 
		AND info ->> ''key2'' = ''BED_CODE_CONV'' UNION
	SELECT
		1 AS order_no,
		1 AS bed_conv 
	ORDER BY
		order_no ASC 
		LIMIT 1 
 )
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
      ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BED_NO'' ), '''' ) ) AS sortTag 
  FROM
   ord_main ord
   LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd 
  WHERE
   ord.ord_no = @ordNo 
  ) UNION
  (--  浄化方法
		SELECT
    ''実績詳細'' AS detail_id, 
		''VC1'' AS sbt_key,
    --項目コード
			CASE
				--患者の入外区分が外来の場合
				WHEN @inOut = ''0''
					THEN COALESCE(mtt.in_hospital_cd_a1, '''')
				--患者の入外区分が入院の場合
				WHEN @inOut = ''1''
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
    COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_TREAT''), '''') AS sortTag
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_treatment mtt
ON
    mtt.treatment_cd = ord.rst_treatment_cd
WHERE
    ord.ord_no = @ordNo
  ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_START_DATE_TIME'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_END_DATE_TIME'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SCHE_TIME'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BEFORE_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_AFTER_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
						( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_TARGET_WEIGHT'' ), '''' ) ) AS sortTag 
					FROM
						ord_main ord 
					WHERE
						ord.ord_no = @ordNo
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DRY_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
						NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DATE_INTRODUCED'' ), '''' ) AS sortTag 	
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
								) UNION
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
       ) UNION
       (-- 障害者加算タイトル
       SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ( mad.in_hospital_cd_1, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_CODE'' ), '''' ) AS e01,--コード
        COALESCE ( mad.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( addi ->> ''name'', 1, 25 ), ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_NAME'' ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        ''33'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag 
       FROM
        ord_main ord
        CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addi
        LEFT OUTER JOIN mst_addition AS mad ON mad.addition_cd = to_number( addi ->> ''cd'', ''9999999999'' ) 
       WHERE
        mad.addition_class = ''2'' 
        AND ord.ord_no = @ordNo 
        AND ( SELECT VALUE FROM dialysis_send WHERE key2 = ''ADD_TITLE_SEND_FLG'' ) = ''1'' 
       ) UNION
       (--  障害者加算:患者基本情報から取得
       SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ( mdd.in_hospital_cd_1, '''' ) AS e01,--コード
        COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        ''33'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag 
       FROM
        ord_main ord
        CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addi
        LEFT OUTER JOIN mst_addition AS mad ON mad.addition_cd = to_number( addi ->> ''cd'', ''9999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mad.addition_tar_cd :: json ) addtr
        LEFT OUTER JOIN mst_dialysis_difficulty AS mdd ON mdd.dialysis_difficulty_cd = to_number( addtr ->> ''cd'', ''9999999999'' ) 
       WHERE
        mad.addition_cond = ''2'' 
        AND addi ->> ''is_enable'' = ''1'' 
        AND mad.addition_class <> ''2'' 
        AND ord.ord_no = @ordNo 
        AND ( SELECT VALUE->>''memo_flg''  FROM sys_system_define WHERE ctl_no = 134 ) IS NOT NULL 
        AND ( SELECT VALUE->>''memo_flg''  FROM sys_system_define WHERE ctl_no = 134 ) = ''1'' 
       ) UNION
       (--  障害者加算：透析実績レセプトメモ履歴から取得-主要的透析困难
       SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ( mdd.in_hospital_cd_1, '''' ) AS e01,--コード
        COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        ''33'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag 
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
       ) UNION
       (-- 障害者加算：透析実績レセプトメモ履歴から取得-主要的透析困难以外
       SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ( mdd.in_hospital_cd_1, '''' ) AS e01,--コード
        COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        ''33'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag 
       FROM
        ord_main ord
        CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addi
        LEFT OUTER JOIN mst_addition AS mad ON mad.addition_cd = to_number( addi ->> ''cd'', ''9999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mad.addition_tar_cd :: json ) addtr
        LEFT OUTER JOIN mst_dialysis_difficulty AS mdd ON mdd.dialysis_difficulty_cd = to_number( addtr ->> ''cd'', ''9999999999'' ) 
       WHERE
        mad.addition_cond = ''2'' 
        AND addi ->> ''is_enable'' = ''1'' 
        AND mad.addition_class <> ''2'' 
        AND ord.ord_no = @ordNo 
        AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) IS NULL 
        AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) <> ''0'' 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SHUNT_PART'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DIAL_INST'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_dialyzer AS mdz ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FILM'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FIRST_FILM'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SECOND_FILM'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo 
       ) UNION
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
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
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
    ord.ord_no = @ordNo AND
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
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
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
    ord.ord_no = @ordNo AND
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
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
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
    ord.ord_no = @ordNo AND
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
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
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
    ord.ord_no = @ordNo AND
    ord.rst_cond_info->''13''->>''value'' IS NOT NULL
       ) UNION ALL
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
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
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
     ord.ord_no = @ordNo AND
     equip->>''equip_type'' = ''0''  		 
			 )UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION'' ), '''' ) ) AS sortTag 
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
        ord.ord_no = @ordNo 
        AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
       ) UNION
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
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_REPLACE'' ), '''' ) ) AS sortTag 
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
       ) UNION
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
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_ONESHOT'' ), '''' ) ) AS sortTag 
 FROM
  ord_main ord
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
 WHERE
  ord.ord_no = @ordNo 
  AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION
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
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG'' ), '''' ) ) AS sortTag 
FROM
 ord_main ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ord.ord_no = @ordNo 
 AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0''   
 ) UNION
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
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_TOTAL'' ), '''' ) ) AS sortTag 
FROM
 ord_main ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ord.ord_no = @ordNo 
 AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION
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
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BLOOD_AMT'' ), '''' ) ) AS sortTag 
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo 
  AND TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ) > 1 
  AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
  
 )UNION(-- 透析液流量
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
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION_AMT'' ), '''' ) ) AS sortTag 
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo  
  AND TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ) >= 1 
 
 )
UNION
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
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_UP_LIQUID'' ), '''' ) ) AS sortTag 
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo 
  AND TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ) > 1 
  AND (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
  AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') in (''0'',''1'',''2'') 
  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
  OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
 ) UNION
 (-- 薬品手技7606
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO1'' AS sbt_key,
  COALESCE ( mp.in_hospital_cd_a1, '''' ) AS e01,-- 項目コード
 COALESCE ( mp.in_hospital_cd_a2, ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_PROCEDURE_ATTR'' ), '''' ) ), '''' ) AS e02,-- 項目属性
  COALESCE ( mp.pricedure_name, '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,-- 数量
  ''0'' AS e05,-- 選択単位フラグ
  '''' AS e06,-- 単位コード
  '''' AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1 ), '''' ) AS e11,-- タグ名称
--   NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'' ), '''' ) AS sortTag 
COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''1'' AS sortTag
 FROM
  ord_main ord
	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
	LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
 WHERE
 ord.ord_no = @ordNo																																																																	
 AND medi ->> ''procedure_cd'' IS NOT NULL
 and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) is not NULL
 and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) != ''''
 ) UNION
  (--  処置薬品名-手技あり薬剤
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
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
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''2'' AS sortTag
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
    AND medi ->> ''procedure_cd'' IS NOT NULL
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 ) UNION
(--  処置薬品名-手技なし薬剤
SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
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
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''3'' AS sortTag
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
    AND (medi ->> ''procedure_cd'' IS  NULL
    or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
   or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 ) 
 UNION
 (--  実施コメンSOAP ト A
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC7'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_A'' ), '''' ) AS e02,
  ''A'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_A'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト O
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC6'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_O'' ), '''' ) AS e02,
  ''O'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_O'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト P
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC8'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_P'' ), '''' ) AS e02,
  ''P'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_P'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト S
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC5'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_S'' ), '''' ) AS e02,
  ''S'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_S'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
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
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN'' ), '''' ) ) AS sortTag 
 FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 
  AND ord.ord_no = @ordNo 
  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_FLAG'' ) = ''1'' 
 ) UNION
 (-- 酸素吸入
 SELECT
  ''実績詳細'' AS detail_id,
  ''VQ1'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_NAME'' ), '''' ) AS e03,-- 項目名称
  COALESCE ( to_char( TO_NUMBER( oxy ->> ''amount'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''31'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN'' ), '''' ) ) AS sortTag 
 FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 
  AND ord.ord_no = @ordNo 
  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 
 ) UNION
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
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_RECORD'' ), '''' ) AS sortTag 
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
 )  UNION
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
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag 
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
order by all_cost.sortTag, all_cost.sbt_key
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）実績繰り返し部', '2020-04-24 19:15:25.001',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}]');
