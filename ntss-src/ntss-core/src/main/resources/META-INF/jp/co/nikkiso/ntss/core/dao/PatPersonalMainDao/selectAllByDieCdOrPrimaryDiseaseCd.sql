SELECT
    primary_disease_cd,
    pat_id
FROM
    pat_personal_main
WHERE
        facility_cd = /*facilityCd*/null
  AND primary_disease_cd IN /*diseaseCdList*/(null) UNION
SELECT
    die_cd AS primary_disease_cd,
    pat_id
FROM
    pat_personal_main
WHERE
        facility_cd = /*facilityCd*/null
  AND die_cd IN /*diseaseCdList*/(null);