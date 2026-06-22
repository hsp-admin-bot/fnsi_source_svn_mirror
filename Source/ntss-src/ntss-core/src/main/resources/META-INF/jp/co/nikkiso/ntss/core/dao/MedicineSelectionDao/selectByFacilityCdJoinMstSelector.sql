SELECT M.medicine_cd,
       M.medicine_name,
       M.class_cd,
       M.standard_medicine_cd,
       M.unit_decimal_point,
       M.unit,
       M.unit_second,
       is_medicine_taboo_type(CAST(M.medicine_cd AS CHARACTER VARYING), /*patId*/0) AS medicine_taboo_type
FROM mst_medicine M,
     (
         SELECT mss.facility_cd,
                ms.*,
                ROW_NUMBER() OVER ( ) AS INDEX
         FROM mst_selector mss
                  CROSS JOIN LATERAL jsonb_to_recordset (mss.order_settings -> 'items' ) AS ms ( code INT, NAME TEXT )
         WHERE
             mss.facility_cd = /* facilityCd*/null
           AND mss.master_physical_name = 'mst_medicine'
     ) ms
WHERE M.medicine_cd IS NOT NULL
  AND M.is_disp = '1'
  AND M.is_del = '0'
  AND M.facility_cd = /* facilityCd*/null
  AND M.medicine_cd = ms.code
ORDER BY ms.INDEX