-- #12698 pat_main.pat_group_infoの既存データ修正

-- 患者情報で患者グループを1件以上→0件のゴミデータ削除
UPDATE pat_main pm
SET pat_group_info = '[]'::jsonb
WHERE pm.pat_group_info <> 'null'::jsonb
  AND pm.pat_group_info IS NOT NULL
  AND pm.pat_group_info <> '[]'::jsonb
  AND NOT EXISTS (
    SELECT 1
    FROM pat_group_detail pgd
    WHERE pgd.facility_cd = pm.facility_cd
      AND pgd.pat_id = pm.pat_id
  );

-- 文字列"null"を[]に置換
UPDATE pat_main pm
SET pat_group_info = '[]'::jsonb
WHERE pm.pat_group_info = 'null'::jsonb
;

-- ["グループ１", "グループ２"...]の形式で登録されているデータを正しい形式に修正
UPDATE pat_main pm
SET pat_group_info = src.pat_group_info
FROM (
    SELECT
        pgd.facility_cd,
        pgd.pat_id,
        jsonb_agg(
            jsonb_build_object(
                'ctl_no', rn,
                'patGroupCd', pgd.pat_group_cd::text
            )
            ORDER BY rn
        ) AS pat_group_info
    FROM (
        SELECT
            facility_cd,
            pat_id,
            pat_group_cd,
            ROW_NUMBER() OVER (
                PARTITION BY facility_cd, pat_id
                ORDER BY pat_group_cd
            ) AS rn
        FROM pat_group_detail
    ) pgd
    GROUP BY
        pgd.facility_cd,
        pgd.pat_id
) src
WHERE pm.facility_cd = src.facility_cd
  AND pm.pat_id = src.pat_id
  AND jsonb_typeof(pm.pat_group_info -> 0) = 'string'
;
