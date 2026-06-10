SELECT
  main.mainte_no,
  main.mainte_class,
  main.machine_no,
  main.rec_no,
  main.mainte_date,
  main.mainte_layout_group_cd,
  main.mainte_layout_group_edition,
  main.mainte_layout_cd,
  main.mainte_layout_edition,
  main.mainte_category_cd,
  main.checker_id_1,
  main.checker_id_2,
  main.mainte_ans_1,
  main.mainte_comment_1,
  main.detail,
  main.is_disp,
  main.is_del,
  main.up_date,
  main.reg_date
FROM
  mnt_mainte_main as main
  INNER JOIN
  mst_mainte_layout_hst as layout ON (
    main.mainte_layout_cd = layout.mainte_layout_cd
    AND
    main.mainte_layout_edition = layout.edition_no
  )
WHERE
  main.facility_cd = /* facilityCd */'000000'
  AND
  main.mainte_class = /* mainteClass */'0'
  /*%if machineNo != null */
  AND
  main.machine_no = /* machineNo */0
  /*%end */
  AND
  main.mainte_date <= /* mainteDate */'9999-12-31'
  AND
  main.mainte_date >= /* mainteDateHistory */'1900-01-01'
  AND
  main.is_disp = '1'
  AND
  main.is_del = '0'
  AND
  layout.is_del = '0'
ORDER BY
  main.machine_no
;
