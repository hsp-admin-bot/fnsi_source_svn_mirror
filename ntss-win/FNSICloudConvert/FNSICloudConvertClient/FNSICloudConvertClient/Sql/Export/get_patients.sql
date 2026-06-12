-- 施設に紐づく患者データを取得する
-- パラメーター:
--   :facilityCd  施設コード
--   :onlyActive  true の場合のみ active 条件を付加 (省略可)
SELECT
    p.patient_id,
    p.facility_cd,
    p.patient_no,
    p.name,
    p.birth_date,
    p.sex,
    p.created_at,
    p.updated_at
FROM
    patient p
WHERE
    p.facility_cd = /* :facilityCd */'F001'
    /*IF :onlyActive */ AND p.delete_flag = 0 /*END*/
ORDER BY
    p.patient_id
