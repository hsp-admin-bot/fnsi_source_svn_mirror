SELECT
  to_char(mmm.mainte_date, 'YYYYMMDD') AS str_date,
  mb.bed_cd
FROM
  mnt_mainte_main mmm
INNER JOIN mst_bed mb ON
  mmm.machine_no = mb.machine_no
WHERE
  mmm.is_disp = '1'
  AND mmm.is_del = '0'
  AND mmm.facility_cd = /*facilityCd*/null
  AND mmm.mainte_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
  AND mmm.mainte_date <= TO_TIMESTAMP(/* endDate */null, 'YYYY/MM/DD')::timestamp
  AND mmm.mainte_class = '2' -- 定期点検
;