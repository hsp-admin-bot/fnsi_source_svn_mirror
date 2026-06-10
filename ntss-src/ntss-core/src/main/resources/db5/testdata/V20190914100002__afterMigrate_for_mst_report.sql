-- 帳票マスタのデータ更新
UPDATE mst_report
SET
  default_printer = 1
WHERE
  report_cd = 1;

UPDATE mst_report
SET
  default_printer = 2
WHERE
  report_cd = 2;

UPDATE mst_report
SET
  default_printer = 3
WHERE
  report_cd = 3;
