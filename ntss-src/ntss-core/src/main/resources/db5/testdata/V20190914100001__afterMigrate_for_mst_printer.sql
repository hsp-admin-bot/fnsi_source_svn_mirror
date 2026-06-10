-- プリンターマスタのデータ追加
INSERT INTO mst_printer
  (printer_cd, facility_cd, client_key, printer_name, disp_printer_name, is_disp, is_del, reg_date, up_date) 
 VALUES
  (1, '009999', 'client_key_1', 'EPSON LP-S950 FULL', 'EPSON LP-S950', '1', '0', '2019-09-14 10:00:00.000', '2019-09-14 10:00:00.000')
, (2, '009999', 'client_key_2', 'PIXUS TS8230 FULL', 'PIXUS TS8230', '1', '0', '2019-09-14 10:00:00.000', '2019-09-14 10:00:00.000')
, (3, '009999', 'client_key_3', 'カラリオ EP-881A FULL', 'カラリオ EP-881A', '1', '0', '2019-09-14 10:00:00.000', '2019-09-14 10:00:00.000')
, (4, '009999', 'client_key_4', 'PIXUS TS6230 FULL', 'PIXUS TS6230', '0', '0', '2019-09-14 10:00:00.000', '2019-09-14 10:00:00.000')
, (5, '009999', 'client_key_5', 'PIXUS TS3130S FULL', 'PIXUS TS3130S', '1', '1', '2019-09-14 10:00:00.000', '2019-09-14 10:00:00.000')
;
SELECT setval('mst_printer_printer_cd_seq', 5);
