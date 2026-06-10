SELECT A.mainte_layout_cd,
       A.mainte_comment_1,
       COUNT ( 1 ) AS detail
FROM
     ( SELECT mainte_layout_cd, to_char( mainte_date, 'yyyyMMdd' ) AS mainte_date, to_char( mainte_date, 'yyyy/MM/dd' ) AS mainte_comment_1, facility_cd
      FROM mnt_mainte_main WHERE mainte_class = '1' AND mainte_ans_1 = '1' AND is_disp = '1' AND is_del = '0' ) AS A,
    ( SELECT mainte_layout_cd, facility_cd FROM mst_mainte_layout WHERE facility_cd = /* facilityCd */'0' AND layout_class = '1' AND is_disp = '1' AND is_del = '0' ) AS B
WHERE
        A.facility_cd = B.facility_cd
  AND A.mainte_layout_cd = B.mainte_layout_cd
  AND A.mainte_date BETWEEN /*startDate*/'19000101'
    AND /*endDate*/'99991230'
GROUP BY
    A.mainte_layout_cd, A.mainte_comment_1
