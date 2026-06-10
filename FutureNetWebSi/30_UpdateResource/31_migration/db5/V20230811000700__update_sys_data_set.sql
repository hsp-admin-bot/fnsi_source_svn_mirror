DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 9629;

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9629, 'WITH tabooAllergy AS (
	SELECT
		( idx - 1 ) AS idx,
		ms ->> ''memo'' AS memo,
		ms ->> ''ctl_no'' AS ctl_no,
		ms ->> ''content'' AS CONTENT,
		ms ->> ''disp_order'' AS disp_order,
		ms ->> ''category_class'' AS category_class,
		ms ->> ''taboo_allergy_cd'' AS taboo_allergy_cd,
		ms ->> ''taboo_allergy_class'' AS taboo_allergy_class,
		ms ->> ''new_flag'' AS new_flag,
		regexp_matches( ms ->> ''memo'', ''【分類】[^【]*'' ) AS memo_class 
	FROM
		pat_main
		AS A CROSS JOIN LATERAL jsonb_array_elements ( A.taboo_allergy_info :: JSONB ) WITH ORDINALITY AS info ( ms, idx ) 
	WHERE
		A.is_del = ''0'' 
		AND A.facility_cd = ''@facilityCd'' 
		AND A.pat_id = @patId UNION
	SELECT
		( idx - 1 ) AS idx,
		ms ->> ''memo'' AS memo,
		ms ->> ''ctl_no'' AS ctl_no,
		ms ->> ''content'' AS CONTENT,
		ms ->> ''disp_order'' AS disp_order,
		ms ->> ''category_class'' AS category_class,
		ms ->> ''taboo_allergy_cd'' AS taboo_allergy_cd,
		ms ->> ''taboo_allergy_class'' AS taboo_allergy_class,
		ms ->> ''new_flag'' AS new_flag,
		NULL AS memo_class 
	FROM
		pat_main
		AS A CROSS JOIN LATERAL jsonb_array_elements ( A.taboo_allergy_info :: JSONB ) WITH ORDINALITY AS info ( ms, idx ) 
	WHERE
		A.is_del = ''0'' 
		AND A.facility_cd = ''@facilityCd'' 
		AND A.pat_id = @patId 
		AND ( ms ->> ''memo'' NOT LIKE''%【分類】%'' OR ms ->> ''memo'' IS NULL ) 
	),
	tabooAllergyUpdate AS (
	SELECT OLD
		.idx AS oldIdx,
		NEW.idx AS newIdx,
		OLD.ctl_no AS ctl_no,
		NEW.memo AS memo,
		NEW.CONTENT AS CONTENT,
		OLD.disp_order AS disp_order,
		NEW.category_class AS category_class,
		NEW.taboo_allergy_cd AS taboo_allergy_cd,
		NEW.taboo_allergy_class AS taboo_allergy_class,
		NEW.memo_class AS memo_class 
	FROM
		( SELECT idx, memo, ctl_no, CONTENT, disp_order, category_class, taboo_allergy_cd, taboo_allergy_class, memo_class FROM tabooAllergy WHERE new_flag IS NULL ) AS OLD,
		( SELECT idx, memo, ctl_no, CONTENT, disp_order, category_class, taboo_allergy_cd, taboo_allergy_class, memo_class FROM tabooAllergy WHERE new_flag IS NOT NULL ) AS NEW 
	WHERE
		( OLD.taboo_allergy_cd IS NOT NULL AND OLD.taboo_allergy_cd != '''' AND OLD.taboo_allergy_cd = NEW.taboo_allergy_cd ) 
		OR ( ( OLD.taboo_allergy_cd IS NULL OR OLD.taboo_allergy_cd = '''' ) AND OLD.CONTENT = NEW.CONTENT ) 
		AND NEW.memo_class = OLD.memo_class 
	),
	tabooAllergyCreate AS (
	SELECT
		idx AS idx,
		memo AS memo,
		ctl_no AS ctl_no,
		CONTENT AS CONTENT,
		disp_order AS disp_order,
		category_class AS category_class,
		taboo_allergy_cd AS taboo_allergy_cd,
		taboo_allergy_class AS taboo_allergy_class,
		memo_class AS memo_class 
	FROM
		tabooAllergy 
	WHERE
		new_flag IS NOT NULL 
		AND idx NOT IN ( SELECT oldIdx FROM tabooAllergyUpdate ) 
		AND idx NOT IN ( SELECT newIdx FROM tabooAllergyUpdate ) 
	),
	tabooAllergyClass AS ( SELECT memo_class FROM tabooAllergyUpdate UNION SELECT memo_class FROM tabooAllergyCreate ),
	tabooAllergyRetain AS (
	SELECT
		idx AS idx,
		memo AS memo,
		ctl_no AS ctl_no,
		CONTENT AS CONTENT,
		disp_order AS disp_order,
		category_class AS category_class,
		taboo_allergy_cd AS taboo_allergy_cd,
		taboo_allergy_class AS taboo_allergy_class 
	FROM
		tabooAllergy 
	WHERE
		new_flag IS NULL 
		AND ( memo_class NOT IN ( SELECT * FROM tabooAllergyClass ) OR memo_class IS NULL ) 
	)
,tabooAllergyTojsonb AS (
SELECT COALESCE (
													json_agg (
														jsonb_build_object (
															''memo'',
															memo,
															''ctl_no'',
															ctl_no :: INTEGER,
															''content'',
															CONTENT,
															''disp_order'',
															no,
															''category_class'',
															category_class,
															''taboo_allergy_cd'',
															taboo_allergy_cd,
															''taboo_allergy_class'',
															taboo_allergy_class 
														) 
													),
													''[]'' 
												) AS js
	FROM (SELECT ROW_NUMBER() OVER () AS no,*
		FROM
			(
			SELECT
				memo,
				ctl_no,
				CONTENT,
				disp_order :: INTEGER,
				category_class,
				taboo_allergy_cd,
				taboo_allergy_class 
			FROM
				tabooAllergyUpdate UNION ALL
			SELECT
				memo,
				ctl_no,
				CONTENT,
				disp_order :: INTEGER,
				category_class,
				taboo_allergy_cd,
				taboo_allergy_class 
			FROM
				tabooAllergyCreate UNION ALL
			SELECT
				memo,
				ctl_no,
				CONTENT,
				disp_order :: INTEGER,
				category_class,
				taboo_allergy_cd,
				taboo_allergy_class 
			FROM
				tabooAllergyRetain 
			ORDER BY
				disp_order 
			) AS x) AS xx)
	UPDATE pat_main
SET
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = js
from tabooAllergyTojsonb
WHERE is_del = ''0''
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(アレルギー情報)', '2023-05-31 17:24:39', CURRENT_TIMESTAMP, NULL);
