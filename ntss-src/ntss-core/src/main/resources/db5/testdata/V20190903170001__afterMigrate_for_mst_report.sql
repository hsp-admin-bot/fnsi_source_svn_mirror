-- 帳票マスタのデータ更新
UPDATE mst_report
set
  report_type = 2
WHERE
  report_cd > 1;
