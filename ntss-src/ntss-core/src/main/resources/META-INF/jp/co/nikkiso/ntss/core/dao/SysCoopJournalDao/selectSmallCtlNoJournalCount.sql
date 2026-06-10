WITH temp_hpi AS (
  SELECT
    temp_content -> 0 -> 'pat_personal_main' ->> 'hosp_pat_id' AS hosp_pat_id
  FROM
    sys_coop_journal
  WHERE
    ctl_no = /*ctlNo*/0
)
SELECT
  count(1)
FROM
  sys_coop_journal
WHERE
  facility_cd = /* facilityCd */'999999'
AND
  direction = /* direction */''
AND
  coop_cd = /* coopCd */''
AND
  ana_result = /* anaResult */''
AND
  coop_result = /* coopResult */''
AND
  ctl_no < /*ctlNo*/0
AND
  is_del = '0'
and
  CASE WHEN (SELECT hosp_pat_id FROM temp_hpi) IS NOT NULL
    THEN (SELECT hosp_pat_id FROM temp_hpi) = temp_content -> 0 -> 'pat_personal_main' ->> 'hosp_pat_id'
          OR temp_content IS NULL
    ELSE TRUE
    END
;