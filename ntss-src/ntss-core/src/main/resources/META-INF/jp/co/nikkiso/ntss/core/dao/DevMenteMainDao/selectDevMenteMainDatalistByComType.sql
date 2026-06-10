SELECT -1 AS mainte_layout_group_cd,
       A.mainte_layout_cd,
       '' as mainte_comment_1,
       COUNT ( 1 ) AS detail,
       '-1' AS mainte_class
FROM
    (SELECT mml.mainte_layout_cd, mml.facility_cd, (ti ->> 'machineNo') :: NUMERIC as machine_no
     FROM mst_mainte_layout mml CROSS JOIN LATERAL json_array_elements(mml.type_info ::json) AS ti
     WHERE mml.facility_cd = /*facilityCd*/'0' AND mml.layout_class = '1' AND mml.is_disp = '1' AND mml.is_del = '0') as A,
    mst_machine as B,
    mst_machine_type as C
WHERE
        A.facility_cd = B.facility_cd
  AND A.machine_no = B.machine_no
  AND B.is_disp = '1' AND B.is_del = '0'
  AND B.machine_type_cd = C.machine_type_cd
  AND C.model in ('001', '002', '003')
GROUP BY
    A.mainte_layout_cd
