-- add #10210 帳票における患者情報の取得元について sunsy start
SELECT
    ord_prescription_no
FROM
    ord_prescription
WHERE
    issue_date
    between TO_CHAR(DATE_TRUNC('day', (CAST(/* fromDate */'' AS TIMESTAMP) - INTERVAL '1 year')), 'yyyymmdd')
    AND TO_CHAR(DATE_TRUNC('day', CAST(/* fromDate */'' AS TIMESTAMP)), 'yyyymmdd')
    AND pat_id = /* patId */0
    AND	facility_cd = /* facilityCd */null
    AND is_del = '0'
    AND is_disp = '1'
ORDER BY
    issue_date DESC,
    ord_prescription_no DESC
LIMIT 1
-- add #10210 帳票における患者情報の取得元について sunsy end
