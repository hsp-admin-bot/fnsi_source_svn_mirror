WITH mss_bed AS (
  SELECT
    mss.facility_cd, ms.*, row_number() over() AS ord_index
  FROM
    mst_selector mss
    cross JOIN lateral jsonb_to_recordset(mss.order_settings->'items') AS ms
    (
      code bigint,
      name text
    )
  WHERE
    master_physical_name = 'mst_bed'
    AND facility_cd = /*facilityCd*/''
)
SELECT 
    om.pat_id, 
    om.ind_kur_cd, 
    om.ind_bed_cd,
    CASE WHEN om.ind_kur_cd = 0 THEN '未登録' ELSE mk.kur_name END AS kur_name,
    CASE WHEN om.ind_bed_cd = 0 THEN '未登録' ELSE b.bed_name END AS bed_name,
    om.treat_date,
    CASE WHEN om.ind_kur_cd = 0 THEN '999999' ELSE mk.kur_start_time END AS ind_kur_start_time,
    CASE WHEN om.ind_bed_cd = 0 THEN 999999 ELSE mss_bed.ord_index END AS ind_bed_order_index 
FROM 
    ord_main AS om 
    LEFT JOIN mst_kur mk ON om.ind_kur_cd = mk.kur_cd
    LEFT JOIN mst_bed b ON om.ind_bed_cd = b.bed_cd
    LEFT JOIN mss_bed ON om.ind_bed_cd = mss_bed.code
WHERE 
    om.pat_id IN /* patIdList */(null)
    AND om.facility_cd = /* facilityCd */'' 
    /*%if treatDate != null*/
    AND om.treat_date = /* treatDate */''
    /*%end*/
    /*%if treatDateStart != null*/
    AND om.treat_date >= /* treatDateStart */''
    /*%end*/
    /*%if treatDateEnd != null*/
    AND om.treat_date <= /* treatDateEnd */''
    /*%end*/