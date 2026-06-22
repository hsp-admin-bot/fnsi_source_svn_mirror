SELECT
  main.mainte_no,
  main.mainte_class,
  main.machine_no,
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
  COALESCE(main.mainte_ans_1,'') AS mainte_ans_1,
  main.mainte_comment_1,
  main.detail,
  main.is_disp,
  main.is_del,
  main.up_date,
  main.reg_date

FROM
  	mnt_mainte_main as main
WHERE
		main.facility_cd = /* facilityCd */'000000'
	AND
		main.mainte_class = /* mainteClass */'0'
  /*%if mainteDateStart != null && !mainteDateStart.isEmpty() */
	AND
		main.mainte_date >= /* mainteDateStart */'2010-01-01'
  /*%end */
  /*%if mainteDateEnd != null && !mainteDateEnd.isEmpty() */
	AND
		main.mainte_date <= /* mainteDateEnd */'2010-01-01'
  /*%end */
	AND
		main.is_disp = '1'
	AND
		main.is_del = '0'
ORDER BY machine_no
