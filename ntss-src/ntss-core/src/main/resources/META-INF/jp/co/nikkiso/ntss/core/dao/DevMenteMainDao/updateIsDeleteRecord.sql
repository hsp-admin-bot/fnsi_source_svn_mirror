UPDATE
		mnt_mainte_main
SET
		is_disp = '0',
		up_date = current_timestamp
WHERE
		mainte_no in /* mainNoList*/(0)
  -- #11205 -ペンテスト2－4認可制御の不備  add 20260416 start
  AND facility_cd = /* facilityCd */'X'
  -- #11205 -ペンテスト2－4認可制御の不備  add 20260416 end
