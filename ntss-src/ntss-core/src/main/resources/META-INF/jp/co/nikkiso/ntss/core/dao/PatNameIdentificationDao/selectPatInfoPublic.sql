SELECT coalesce(nullif((a.pat_id_src), NULL),(b.pat_id_src)) AS pat_id,
       cast(coalesce(nullif(a.not_yet, NULL), '0') AS bigint) as not_yet,
       cast(coalesce(nullif(b.approve, NULL), '0') AS bigint) as already
FROM
  (SELECT pat_id_src,
          count(pat_id_src) AS not_yet
   FROM pat_name_identification
   WHERE approve= '0'
     AND pat_id_src IN /*lstPatInfo*/(0)
     AND facility_cd_src IN /*lstFacility_cd*/(null)
   GROUP BY pat_id_src) AS a
FULL OUTER JOIN
  (SELECT pat_id_src,
          count(pat_id_src) AS approve
   FROM pat_name_identification
   WHERE approve = '1'
     AND pat_id_src IN /*lstPatInfo*/(0)
     AND facility_cd_src IN /*lstFacility_cd*/(null)
   GROUP BY pat_id_src) AS b ON a.pat_id_src = b.pat_id_src