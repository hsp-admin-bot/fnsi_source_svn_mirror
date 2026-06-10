SELECT
  main.mainte_no,
  main.mainte_class,
--add FNSI-No.756 点検歴にあるデータから、詳細情報参照できる「点検項目入力」画面を閉じると、検索前の検索データが保持されていない 吉 start
  main.facility_cd,
--add FNSI-No.756 点検歴にあるデータから、詳細情報参照できる「点検項目入力」画面を閉じると、検索前の検索データが保持されていない  吉 end
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
  main.mainte_ans_1,
  main.mainte_comment_1,
  main.detail,
  main.is_disp,
  main.is_del,
  main.up_date,
  main.reg_date

FROM
  		mnt_mainte_main as main
WHERE
		main.facility_cd = /* facilityCd*/'00000'
	AND
		main.machine_no = /* machineNo*/'0'
	AND
		main.mainte_class = /* menteClass*/'0'
	AND
		main.mainte_date <= /* menteDateEnd*/'2010-01-01'
	AND
		main.mainte_date >= /* menteDateStart*/'2010-01-01'
	AND
		main.is_disp = '1'
	AND
		main.is_del = '0'
ORDER BY
	main.mainte_date DESC
