DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (7204);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7204, 'WITH mst_exist_info AS (
  --取り込む対象の名称でインプラントマスタからimplant_cd取得
	( 
		SELECT
			implant_cd 
		FROM
			mst_implant 
		WHERE
			facility_cd = ''@facilityCd'' 
			AND implant_name = ''@implantInfo.implantName''
	) 
	UNION
	( 
		SELECT
			0 AS implant_cd
	)
	ORDER BY implant_cd DESC
	LIMIT 1
	)
 , tmp_info AS (
  --今回取り込む対象
	(
	SELECT 
		info AS implant
	FROM
		( SELECT jsonb_array_elements ( implant_info ) AS info FROM pat_main patm WHERE pat_id = @patId AND facility_cd = ''@facilityCd'' AND is_del = ''0'' ) A 
	WHERE
		info ->> ''getInFlg'' IN ( ''add'', ''mod'' ) 
	)
			UNION
	(
		SELECT 
		''{"ctl_no": null}'' :: jsonb
	)
	)
  , implant_info_before AS (
	--今回取り込む前DB対象
	(	
	SELECT
		A.info 
	FROM
		( SELECT jsonb_array_elements ( implant_info ) AS info FROM pat_main patm WHERE pat_id = @patId AND facility_cd = ''@facilityCd'' AND is_del = ''0'' ) A
	WHERE
		A.info NOT IN ( SELECT implant FROM tmp_info )
	)
		UNION
	(
		SELECT 
		''{"ctl_no": null}'' :: jsonb
	)
	)
	, deal_obj_info AS (
	--今回取り込む前DBの判定処理対象
	SELECT
		info 
	FROM
		(
		SELECT
			info,
			ROW_NUMBER ( ) OVER ( PARTITION BY b.info ->> ''implant_cd'' ORDER BY b.info ->> ''reg_date'' DESC NULLS LAST ) AS rownum 
		FROM
			implant_info_before b
		WHERE
			1 = 1 
			AND ( b.info ->> ''remove_date'' ISNULL OR b.info ->> ''remove_date'' >= TO_CHAR( CURRENT_DATE, ''yyyyMMdd'' ) ) 
		) A 
	WHERE
		rownum = 1 
	) 
  , flag_info AS (
	(
	SELECT 
		1 AS order_no,
		''mod'' AS getInFlg
		FROM deal_obj_info doi
		WHERE
		((doi.info->>''implant_cd'') :: INTEGER = (SELECT implant_cd FROM mst_exist_info))
		OR ((SELECT implant_cd FROM mst_exist_info) = 0)
	)
		UNION
	(
	SELECT
		2 AS order_no,
		''add'' AS getInFlg
	)
	ORDER BY order_no
	LIMIT 1
  )
	, get_in_info AS (
		SELECT json_build_object( 
      ''ctl_no''
      , CASE WHEN getInFlg = ''mod''
						 THEN (cast(@nextCtlNo5 as int) - 1)
						 ELSE @nextCtlNo5
				 END
      , ''disp_order''
      , TO_NUMBER(COALESCE(NULLIF(''@implantInfo.dispOrder'', ''''), ''0''), ''FM999999999'')
      , ''implant_cd''
			, (SELECT implant_cd FROM mst_exist_info)
      , ''reg_date''
      , TO_CHAR( CURRENT_DATE, ''yyyyMMdd'' ) 
      , ''remove_date''
      , null
			, ''getInFlg''
      , getInFlg
    ) :: jsonb AS getInObj
		FROM flag_info
	)
UPDATE pat_main 
SET 
up_date = CURRENT_TIMESTAMP,
implant_info = implant_info || (SELECT getInObj FROM get_in_info)
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(インプラント情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
