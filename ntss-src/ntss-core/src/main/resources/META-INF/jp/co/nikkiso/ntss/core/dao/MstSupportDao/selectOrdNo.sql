SELECT
  om.ord_no
FROM
  ord_main om,
  mst_kur mk
WHERE
  om.facility_cd = /*facilityCd*/'996996'
  AND om.pat_id = /*patId*/'33'
  AND om.is_del = '0'
  AND om.ind_kur_cd = mk.kur_cd
  AND om.treat_date =
  ( SELECT MAX ( treat_date )
      FROM ord_main
     WHERE facility_cd = /*facilityCd*/'996996'
       AND pat_id = /*patId*/'33'
       AND treat_date <= /*baseDate*/'20200609'
       AND is_del = '0' )
ORDER BY
  kur_start_time DESC
