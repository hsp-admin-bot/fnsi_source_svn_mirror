SELECT
  coalesce(MAX(A.revision) + 1, 0)
FROM
  pat_hhd_pattern A
WHERE
  A.pat_id = /*pat_id*/null