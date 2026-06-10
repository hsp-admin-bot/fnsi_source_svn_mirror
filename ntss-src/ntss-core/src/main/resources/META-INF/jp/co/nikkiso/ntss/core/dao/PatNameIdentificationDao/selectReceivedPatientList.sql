SELECT pat_id_dst AS pat_id,
       cast(coalesce(nullif(count(pat_id_dst), NULL), '0') AS bigint) AS already,
       0 AS not_yet
FROM pat_name_identification
WHERE approve = '1'
AND receive = '1'
  AND pat_id_dst IN /*lstPatInfo*/(0)
  AND facility_cd_dst = /*loginFacilityCd*/null
GROUP BY pat_id_dst