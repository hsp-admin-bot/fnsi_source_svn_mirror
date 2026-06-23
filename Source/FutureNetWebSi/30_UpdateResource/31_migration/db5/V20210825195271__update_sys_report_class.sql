----------------------------------------------------------------------------
-- sys_report_classの再作成 2021.08.25 鄧シン
----------------------------------------------------------------------------
TRUNCATE sys_report_class;
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (1, '治療経過表', '[]', '1', '0', '2021-05-17 18:47:02', '2021-05-17 18:47:05');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (2, '単患者帳票', '[]', '1', '0', '2021-05-17 18:47:27', '2021-05-17 18:47:30');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (3, '複数患者帳票', '[]', '1', '0', '2021-05-17 18:47:49', '2021-05-17 18:47:52');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (4, '準備リスト', '[]', '1', '0', '2021-05-17 18:48:20', '2021-05-17 18:48:23');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (5, '配布リスト(ベッド)', '[]', '1', '0', '2021-05-17 18:48:55', '2021-05-17 18:48:59');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (6, '配布リスト(物品)', '[]', '1', '0', '2021-05-17 18:49:26', '2021-05-17 18:49:28');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (7, '装置帳票', '[]', '1', '0', '2021-05-17 18:49:53', '2021-05-17 18:49:57');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (8, 'ラベル', '[]', '1', '0', '2021-05-17 18:50:17', '2021-05-17 18:50:24');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (9, '紹介状', '[{"cd": "1", "name": "紹介状集計"}, {"cd": "2", "name": "紹介状"}]', '1', '0', '2021-05-17 18:50:52', '2021-05-17 18:50:57');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (10, '単一集計', '[{"cd": "1", "name": "紹介状集計"}]', '1', '0', '2021-05-17 18:53:16', '2021-05-17 18:53:21');
INSERT INTO "ntss"."sys_report_class"("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (11, '複数集計', '[{"cd": "1", "name": "スゲージュル表"}, {"cd": "2", "name": "週間薬剤集計表"}, {"cd": "3", "name": "水質調査一覧"}]', '1', '0', '2021-05-17 18:53:10', '2021-05-17 18:53:13');
