DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (7204,1717);
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
	, deal_flag_info AS (
	--名称はマスタに存在するかどうかの判定
		SELECT
			CASE WHEN (implant_cd = 0 AND ''@implantInfo.implantName'' <> '''')
			     THEN 0
					 ELSE 1
			 END AS deal_flag
		FROM
			mst_exist_info 
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
  AND (SELECT deal_flag FROM deal_flag_info ) = 1
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(インプラント情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1717, 'WITH tmp_info AS (
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
	, tmp_cd_info AS (
  --今回取り込む対象のimplant_cd
	(
	SELECT 
		(info ->> ''implant_cd'') :: INTEGER AS implant_cd_info
	FROM
		( SELECT jsonb_array_elements ( implant_info ) AS info FROM pat_main patm WHERE pat_id = @patId AND facility_cd = ''@facilityCd'' AND is_del = ''0'' ) A 
	WHERE
		info ->> ''getInFlg'' IN ( ''add'', ''mod'' ) 
	)
		UNION
	(
		SELECT 
		''0'' AS implant_cd_info
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
 	, mod_info AS (
	--更新待ち対象
	(
	SELECT
		info AS implant_mod
	FROM
		(
		SELECT
			info,
			ROW_NUMBER ( ) OVER ( PARTITION BY b.info ->> ''implant_cd'' ORDER BY b.info ->> ''reg_date'' DESC NULLS LAST ) AS rownum 
		FROM
			implant_info_before b
		WHERE
			1 = 1 
			AND b.info ->> ''remove_date'' ISNULL 
			AND (b.info ->> ''reg_date'' <= TO_CHAR( CURRENT_DATE, ''yyyyMMdd'' ) OR b.info ->> ''reg_date'' ISNULL ) 
			AND (b.info ->> ''implant_cd'') :: INTEGER NOT IN (SELECT implant_cd_info FROM tmp_cd_info)
		) A 
	WHERE
		rownum = 1 
	)
		UNION
	(
		SELECT 
		''{"ctl_no": null}'' :: jsonb
	)
	) 
	, origin_info AS (
		(	
		SELECT
			info AS implant_origin
		FROM
			implant_info_before
		WHERE
			info NOT IN ( SELECT implant_mod FROM mod_info )
		)
				UNION
		(
			SELECT 
			''{"ctl_no": null}'' :: jsonb
		)
	)
	, add_info AS (
  --今回取り込む対象
	(
	SELECT 
		info AS implant_add
	FROM
		( SELECT jsonb_array_elements ( implant_info ) AS info FROM pat_main patm WHERE pat_id = @patId AND facility_cd = ''@facilityCd'' AND is_del = ''0'' ) A 
	WHERE
		info ->> ''getInFlg'' IN ( ''add'' ) 
	)
		UNION
	(
		SELECT 
		''{"ctl_no": null}'' :: jsonb
	)
	)
, result_implant_info AS (
	SELECT
		jsonb_agg (info :: jsonb) AS implant_info
	FROM
	(
	SELECT
		*
	FROM
		(
		SELECT
			jsonb_array_elements (
				( SELECT jsonb_agg ( implant_origin :: jsonb ) FROM origin_info ) || (
				SELECT
					jsonb_agg ( REPLACE ( implant_mod :: TEXT, ''"remove_date": null'', ''"remove_date": "'' || TO_CHAR( CURRENT_DATE, ''yyyyMMdd'' ) || ''"'' ) :: jsonb ) 
				FROM
					mod_info 
				) || ( SELECT jsonb_agg ( implant_add :: jsonb - ''getInFlg'' ) FROM add_info ) 
			) info 
		) A 
	WHERE
		A.info ->> ''ctl_no'' IS NOT NULL 
  ORDER BY A.info ->> ''ctl_no''
	) B
)
UPDATE pat_main 
SET 
up_date = CURRENT_TIMESTAMP,
implant_info = (SELECT implant_info FROM result_implant_info ) 
WHERE
is_del = ''0'' 
AND pat_id = @patId
AND facility_cd = ''@facilityCd''
AND (SELECT count(1) FROM tmp_info) > 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡以外)', '2022-06-27 12:39:12.395', CURRENT_TIMESTAMP, NULL);
