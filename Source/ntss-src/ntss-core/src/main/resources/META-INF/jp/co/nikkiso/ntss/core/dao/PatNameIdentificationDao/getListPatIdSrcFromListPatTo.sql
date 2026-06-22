SELECT b.from_pat_id
FROM shr_pat_info AS b
WHERE b.is_from_consent = '1'
  AND b.is_to_consent = '1'
  AND b.is_pat_consent = '1'
  AND b.to_pat_id in /*pat_id_dst*/(0)
  AND is_disp = '1'
  AND is_del = '0'
