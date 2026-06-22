SELECT mainte_layout_group_cd, mainte_layout_cd, mainte_comment_1, detail, mainte_class
FROM
  (SELECT A.mainte_layout_group_cd,
          -1 AS mainte_layout_cd,
          A.mainte_comment_1,
          COUNT ( 1 ) AS detail,
          '3' AS mainte_class
   FROM
     ( SELECT mainte_layout_group_cd, to_char( mainte_date, 'yyyyMMdd' ) AS mainte_date, to_char( mainte_date, 'yyyy/MM/dd' ) AS mainte_comment_1, facility_cd
       FROM mnt_mainte_main WHERE mainte_class = '2'
                              AND mainte_ans_1 IS NOT NULL AND mainte_ans_1 <> '' AND is_disp = '1' AND is_del = '0' ) AS A,
     ( SELECT mainte_layout_group_cd, facility_cd FROM mst_mainte_layout_group WHERE facility_cd = /*facilityCd*/'0' AND is_disp = '1' AND is_del = '0' ) AS B
   WHERE
     A.facility_cd = B.facility_cd
     AND A.mainte_layout_group_cd = B.mainte_layout_group_cd
     AND A.mainte_date BETWEEN /*startDate*/'19000101'
     AND /*endDate*/'99991230'
   GROUP BY
     A.mainte_layout_group_cd, A.mainte_comment_1
 union all
-- add bug 5866 修正 chen start
 SELECT -1 AS mainte_layout_group_cd,
       A.mainte_layout_cd,
       A.mainte_comment_1,
       COUNT ( 1 ) AS detail,
       '4' AS mainte_class
FROM
  ( SELECT mainte_layout_cd, to_char( mainte_date, 'yyyyMMdd' ) AS mainte_date, to_char( mainte_date, 'yyyy/MM/dd' ) AS mainte_comment_1, facility_cd
    FROM mnt_mainte_main WHERE mainte_class = '1' AND mainte_ans_1 IS NOT NULL AND mainte_ans_1 <> '' AND is_disp = '1' AND is_del = '0' ) AS A,
  ( SELECT mainte_layout_cd, facility_cd FROM mst_mainte_layout WHERE facility_cd = /* facilityCd */'0' AND layout_class = '1' AND is_disp = '1' AND is_del = '0' ) AS B
WHERE
  A.facility_cd = B.facility_cd
  AND A.mainte_layout_cd = B.mainte_layout_cd
  AND A.mainte_date BETWEEN /*startDate*/'19000101'
  AND /*endDate*/'99991230'
GROUP BY
  A.mainte_layout_cd, A.mainte_comment_1
 union all
-- add bug 5866 修正 chen end

SELECT -1 AS mainte_layout_group_cd,
       A.mainte_layout_cd,
       A.mainte_comment_1,
       COUNT ( 1 ) AS detail,
       '1' AS mainte_class
FROM
    ( SELECT mainte_layout_cd, to_char( mainte_date, 'yyyyMMdd' ) AS mainte_date, to_char( mainte_date, 'yyyy/MM/dd' ) AS mainte_comment_1, facility_cd
      FROM mnt_mainte_main WHERE mainte_class = '1' AND mainte_ans_1 IS NOT NULL AND mainte_ans_1 <> '' AND is_disp = '1' AND is_del = '0' ) AS A,
    ( SELECT mainte_layout_cd, facility_cd FROM mst_mainte_layout WHERE facility_cd = /* facilityCd */'0' AND layout_class = '1' AND is_disp = '1' AND is_del = '0' ) AS B
WHERE
        A.facility_cd = B.facility_cd
  AND A.mainte_layout_cd = B.mainte_layout_cd
  AND A.mainte_date BETWEEN /*startDate*/'19000101'
    AND /*endDate*/'99991230'
GROUP BY
    A.mainte_layout_cd, A.mainte_comment_1) AS TAB1
ORDER BY TAB1.mainte_comment_1 ASC
