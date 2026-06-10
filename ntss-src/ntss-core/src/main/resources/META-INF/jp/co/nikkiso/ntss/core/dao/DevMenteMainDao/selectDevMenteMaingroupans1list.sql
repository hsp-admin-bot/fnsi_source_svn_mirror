SELECT A.mainte_layout_group_cd,
       A.mainte_comment_1,
       COUNT ( 1 ) AS detail
FROM
    ( SELECT mainte_layout_group_cd, to_char( mainte_date, 'yyyyMMdd' ) AS mainte_date, to_char( mainte_date, 'yyyy/MM/dd' ) AS mainte_comment_1, facility_cd
--     mod FNSI-7912 劉全航 start
--       FROM mnt_mainte_main WHERE mainte_class = '2' AND mainte_ans_1 = '1' AND is_disp = '1' AND is_del = '0' ) AS A,
    FROM mnt_mainte_main WHERE mainte_class = '2' AND mainte_ans_1 = '1' AND is_disp = '1' AND is_del = '0' ) AS A,
--     mod FNSI-7912 劉全航 end
    ( SELECT mainte_layout_group_cd, facility_cd FROM mst_mainte_layout_group WHERE facility_cd = /*facilityCd*/'0' AND is_disp = '1' AND is_del = '0' ) AS B
WHERE
        A.facility_cd = B.facility_cd
  AND A.mainte_layout_group_cd = B.mainte_layout_group_cd
  AND A.mainte_date BETWEEN /*startDate*/'19000101'
    AND /*endDate*/'99991230'

GROUP BY
    A.mainte_layout_group_cd, A.mainte_comment_1
