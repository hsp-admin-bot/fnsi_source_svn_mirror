-- mod 4036 の1件にまとめて表示するよう修正願います 吉 start
-- SELECT date(mainte_date) AS mainte_date,
--        mainte_ans_2 AS mainte_ans,
--        count(*) AS number_of_mainte_ans
-- FROM mnt_mainte_main
-- WHERE mainte_class = '2'
--   AND date(mainte_date) >= /*startDate*/NULL
--   AND date(mainte_date) <= /*endDate*/NULL
--   AND facility_cd = /*facilityCd*/NULL
--   AND is_del = '0'
--   AND is_disp = '1'
-- GROUP BY date(mainte_date),
--          mainte_ans_2
	select date(mainte_date) AS mainte_date,machine_no,1 as mainte_ans from mnt_mainte_main  WHERE mainte_class = '2' AND facility_cd = /*facilityCd*/NULL AND is_del = '0'
  AND is_disp = '1' AND date(mainte_date) >= /*startDate*/NULL
  AND date(mainte_date) <= /*endDate*/NULL and mainte_ans_1='1' GROUP BY date(mainte_date),machine_no
	UNION  all
	select date(mainte_date) AS mainte_date,machine_no as machineNo,2 as mainteAns from mnt_mainte_main  WHERE mainte_class = '2' AND facility_cd = /*facilityCd*/NULL AND is_del = '0'
  AND is_disp = '1' AND date(mainte_date) >= /*startDate*/NULL
  AND date(mainte_date) <= /*endDate*/NULL and mainte_ans_1='3' GROUP BY date(mainte_date),machine_no
	UNION  all
	select date(mainte_date) AS mainte_date,machine_no as machineNo,0 as mainteAns from mnt_mainte_main  WHERE mainte_class = '2' AND facility_cd = /*facilityCd*/NULL AND is_del = '0'
  AND is_disp = '1' AND date(mainte_date) >= /*startDate*/NULL
  AND date(mainte_date) <= /*endDate*/NULL and (mainte_ans_1 IS NULL OR mainte_ans_1 NOT IN ('1', '3')) GROUP BY date(mainte_date),machine_no;
-- //mod 4036 の1件にまとめて表示するよう修正願います 吉 end
