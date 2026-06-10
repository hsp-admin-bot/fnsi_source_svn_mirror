SELECT
  COALESCE(to_pat_id, from_pat_id) AS patient_id,
  COUNT(*) AS count
FROM shr_pat_info
WHERE to_facility_cd = /* hospitalCd */''
  AND is_del = '0'
  AND is_disp = '1'
    AND is_from_consent = '1'
    AND is_to_consent = '1'
    AND is_pat_consent = '1'
GROUP BY COALESCE(to_pat_id, from_pat_id)
