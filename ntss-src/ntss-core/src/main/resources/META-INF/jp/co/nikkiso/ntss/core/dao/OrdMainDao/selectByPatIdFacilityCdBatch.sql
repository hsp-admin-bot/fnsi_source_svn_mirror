SELECT
    o.ord_no
  , o.pat_id
  , o.treat_date
  , o.facility_cd
  , o.rst_start_date
  , o.rst_dialysis_state
  , o.rst_weight_info
  , o.is_del
  , o.reg_date
  , o.up_date
FROM ord_main o
INNER JOIN (
  SELECT
    o2.ord_no,
    ROW_NUMBER() OVER (PARTITION BY v.pat_id ORDER BY o2.rst_start_date DESC) AS rn
  FROM (
    VALUES
      /*%for p : pairs */
      (/*p.patId*/null::bigint, /*p.anchorTs*/null::timestamp)
      /*%if p_has_next */
      ,
      /*%end */
      /*%end */
  ) AS v (pat_id, anchor_ts)
  INNER JOIN ord_main o2
    ON o2.pat_id = v.pat_id
    AND o2.facility_cd = /*facilityCd*/''
    AND o2.rst_start_date < v.anchor_ts::timestamp
    AND o2.rst_weight_info IS NOT NULL
) sub
  ON o.ord_no = sub.ord_no
WHERE sub.rn = 1
;
