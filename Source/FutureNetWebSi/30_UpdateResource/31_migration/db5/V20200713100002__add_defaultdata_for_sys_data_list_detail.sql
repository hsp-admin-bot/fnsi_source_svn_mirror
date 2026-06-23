INSERT INTO sys_data_list_detail (data_list_detail_cd, disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql,data_set,cell_display) VALUES 
(1,1,1,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11001}, {"param": "unit", "sql_cd": -11002}]','[count]  [unit] 集計')
,(2,1,2,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0''
union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''
 
','[{"param": "count", "sql_cd": -11003}, {"param": "unit", "sql_cd": -11004}]','[count]  [unit] 集計')
,(3,1,3,'[name]','1','select class_cd as id, class_name as name from mst_equipment_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0''','[{"param": "count", "sql_cd": -11005}, {"param": "unit", "sql_cd": -11006}]','[count]  [unit] 集計')
,(4,1,4,'[name]','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11007}]','[count] 本')
,(5,1,5,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11002}]','[count]  [unit] 集計')
,(6,1,6,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0''
union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''

','[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11004}]','[count]  [unit] 集計')
,(7,1,7,'[name]','1','select class_cd as id, class_name as name from mst_equipment_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0''','[{"param": "count", "sql_cd": -11010}, {"param": "unit", "sql_cd": -11006}]','[count]  [unit] 集計')
,(8,1,8,'[name]','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11011}]','[count] 本')
,(9,1,9,'全治療予定件数','2',NULL,'全治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11012}]','[count] 件')
,(10,2,9,'入院患者治療予定件数','2',NULL,'入院患者治療予定件数','2',NULL,NULL,NULL)
,(11,3,9,'外来患者治療予定件数','2',NULL,'外来患者治療予定件数','2',NULL,NULL,NULL)
,(12,4,9,'透析治療予定件数','2',NULL,'透析治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11013}]','[count] 件')
,(13,5,9,'特殊浄化治療予定件数','2',NULL,'特殊浄化治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11014}]','[count] 件')
,(14,6,9,'[name]','1','select treatment_cd as id, treatment_name as name from mst_treatment where facility_cd = @facilityCd AND is_del = ''0''','[name]治療予定件数','1','select treatment_cd as id, treatment_name as name from mst_treatment where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11015}]','[count] 件')
,(15,7,9,'[name]','1','select kur_cd as id, kur_name as name from mst_kur where facility_cd = @facilityCd AND is_del = ''0''','[name]クール治療予定件数','1','select kur_cd as id, kur_name as name from mst_kur where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11016}]','[count] 件')
,(16,1,10,'全治療実績件数','2',NULL,'全治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11017}]','[count] 件')
,(17,2,10,'入院患者治療実績件数','2',NULL,'入院患者治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11018}]','[count] 件')
,(18,3,10,'外来患者治療実績件数','2',NULL,'外来患者治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11019}]','[count] 件')
,(19,4,10,'透析治療実績件数','2',NULL,'透析治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11020}]','[count] 件')
,(20,5,10,'特殊浄化治療実績件数','2',NULL,'特殊浄化治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11021}]','[count] 件')
,(21,6,10,'[name]','1','select treatment_cd as id, treatment_name as name from mst_treatment where is_del = ''0''  AND facility_cd = @facilityCd','[name]治療実績件数','1','select treatment_cd as id, treatment_name as name from mst_treatment where is_del = ''0''  AND facility_cd = @facilityCd','[{"param": "count", "sql_cd": -11022}]','[count] 件')
,(22,7,10,'[name]','1','select kur_cd as id, kur_name as name from mst_kur where is_del = ''0''  AND facility_cd = @facilityCd','[name]クール治療実績件数','1','select kur_cd as id, kur_name as name from mst_kur where is_del = ''0''  AND facility_cd = @facilityCd','[{"param": "count", "sql_cd": -11023}]','[count] 件')
,(23,1,11,'導入人数','2',NULL,'導入人数','2',NULL,'[{"param": "count", "sql_cd": -11024}]','[count] 人')
,(24,2,11,'転入人数','2',NULL,'転入人数','2',NULL,'[{"param": "count", "sql_cd": -11025}]','[count] 人')
,(25,3,11,'転出人数','2',NULL,'転出人数','2',NULL,'[{"param": "count", "sql_cd": -11026}]','[count] 人')
,(26,4,11,'入院人数','2',NULL,'入院人数','2',NULL,'[{"param": "count", "sql_cd": -11027}]','[count] 人')
,(27,5,11,'退院人数','2',NULL,'退院人数','2',NULL,'[{"param": "count", "sql_cd": -11028}]','[count] 人')
,(28,6,11,'外来人数','2',NULL,'外来人数','2',NULL,'[{"param": "count", "sql_cd": -11029}]','[count] 人')
,(29,7,11,'離脱人数','2',NULL,'離脱人数','2',NULL,'[{"param": "count", "sql_cd": -11030}]','[count] 人')
,(30,8,11,'移植人数','2',NULL,'移植人数','2',NULL,'[{"param": "count", "sql_cd": -11031}]','[count] 人')
,(31,9,11,'一時転出(出)人数','2',NULL,'一時転出(出)人数','2',NULL,'[{"param": "count", "sql_cd": -11032}]','[count] 人')
,(32,10,11,'一時転出(入)人数','2',NULL,'一時転出(入)人数','2',NULL,'[{"param": "count", "sql_cd": -11033}]','[count] 人')
,(33,11,11,'拒否・不明人数','2',NULL,'拒否・不明人数','2',NULL,'[{"param": "count", "sql_cd": -11034}]','[count] 人')
,(34,12,11,'死亡人数','2',NULL,'死亡人数','2',NULL,'[{"param": "count", "sql_cd": -11035}]','[count] 人')
,(35,13,11,'検査予定人数','2',NULL,'検査予定人数','2',NULL,'[{"param": "count", "sql_cd": -11036}]','[count] 人')
,(36,14,11,'放射線予定人数','2',NULL,'放射線予定人数','2',NULL,'[{"param": "count", "sql_cd": -11037}]','[count] 人')
,(37,1,12,'[name]件数','1','select sub_category_cd as id, sub_category_name as name from mst_pat_event_sub_category where facility_cd = @facilityCd AND is_del = ''0''','[name]件数','1','select sub_category_cd as id, sub_category_name as name from mst_pat_event_sub_category where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11038}]','[count] 件')
,(38,1,13,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11001}, {"param": "unit", "sql_cd": -11002}]','[count]  [unit] 集計')
,(39,1,14,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0''
union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''
 
','[{"param": "count", "sql_cd": -11003}, {"param": "unit", "sql_cd": -11004}]','[count]  [unit] 集計')
,(40,1,15,'[name]','1','select class_cd as id, class_name as name from mst_equipment_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0''','[{"param": "count", "sql_cd": -11005}, {"param": "unit", "sql_cd": -11006}]','[count]  [unit] 集計')
,(41,1,16,'[name]','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11007}]','[count] 本')
,(42,1,17,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11002}]','[count]  [unit] 集計')
,(43,1,18,'[name]','1','select class_cd as id, class_name as name from mst_medicine_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0''
union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''

','[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11004}]','[count]  [unit] 集計')
,(44,1,19,'[name]','1','select class_cd as id, class_name as name from mst_equipment_class where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0''','[{"param": "count", "sql_cd": -11010}, {"param": "unit", "sql_cd": -11006}]','[count]  [unit] 集計')
,(45,1,20,'[name]','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[name] 使用予定数','1','select dialyzer_cd as id, CONCAT(maker,'' '',model_number) as name from mst_dialyzer where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11011}]','[count] 本')
,(46,1,21,'全治療予定件数','2',NULL,'全治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11012}]','[count] 件')
,(47,2,21,'入院患者治療予定件数','2',NULL,'入院患者治療予定件数','2',NULL,NULL,NULL)
,(48,3,21,'外来患者治療予定件数','2',NULL,'外来患者治療予定件数','2',NULL,NULL,NULL)
,(49,4,21,'透析治療予定件数','2',NULL,'透析治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11013}]','[count] 件')
,(50,5,21,'特殊浄化治療予定件数','2',NULL,'特殊浄化治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11014}]','[count] 件')
,(51,6,21,'[name]','1','select treatment_cd as id, treatment_name as name from mst_treatment where facility_cd = @facilityCd AND is_del = ''0''','[name]治療予定件数','1','select treatment_cd as id, treatment_name as name from mst_treatment where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11015}]','[count] 件')
,(52,7,21,'[name]','1','select kur_cd as id, kur_name as name from mst_kur where facility_cd = @facilityCd AND is_del = ''0''','[name]クール治療予定件数','1','select kur_cd as id, kur_name as name from mst_kur where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11016}]','[count] 件')
,(53,1,22,'全治療実績件数','2',NULL,'全治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11017}]','[count] 件')
,(54,2,22,'入院患者治療実績件数','2',NULL,'入院患者治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11018}]','[count] 件')
,(55,3,22,'外来患者治療実績件数','2',NULL,'外来患者治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11019}]','[count] 件')
,(56,4,22,'透析治療実績件数','2',NULL,'透析治療予定件数','2',NULL,'[{"param": "count", "sql_cd": -11020}]','[count] 件')
,(57,5,22,'特殊浄化治療実績件数','2',NULL,'特殊浄化治療実績件数','2',NULL,'[{"param": "count", "sql_cd": -11021}]','[count] 件')
,(58,6,22,'[name]','1','select treatment_cd as id, treatment_name as name from mst_treatment where is_del = ''0''  AND facility_cd = @facilityCd','[name]治療実績件数','1','select treatment_cd as id, treatment_name as name from mst_treatment where is_del = ''0''  AND facility_cd = @facilityCd','[{"param": "count", "sql_cd": -11022}]','[count] 件')
,(59,7,22,'[name]','1','select kur_cd as id, kur_name as name from mst_kur where is_del = ''0''  AND facility_cd = @facilityCd','[name]クール治療実績件数','1','select kur_cd as id, kur_name as name from mst_kur where is_del = ''0''  AND facility_cd = @facilityCd','[{"param": "count", "sql_cd": -11023}]','[count] 件')
,(60,1,23,'導入人数','2',NULL,'導入人数','2',NULL,'[{"param": "count", "sql_cd": -11024}]','[count] 人')
,(61,2,23,'転入人数','2',NULL,'転入人数','2',NULL,'[{"param": "count", "sql_cd": -11025}]','[count] 人')
,(62,3,23,'転出人数','2',NULL,'転出人数','2',NULL,'[{"param": "count", "sql_cd": -11026}]','[count] 人')
,(63,4,23,'入院人数','2',NULL,'入院人数','2',NULL,'[{"param": "count", "sql_cd": -11027}]','[count] 人')
,(64,5,23,'退院人数','2',NULL,'退院人数','2',NULL,'[{"param": "count", "sql_cd": -11028}]','[count] 人')
,(65,6,23,'外来人数','2',NULL,'外来人数','2',NULL,'[{"param": "count", "sql_cd": -11029}]','[count] 人')
,(66,7,23,'離脱人数','2',NULL,'離脱人数','2',NULL,'[{"param": "count", "sql_cd": -11030}]','[count] 人')
,(67,8,23,'移植人数','2',NULL,'移植人数','2',NULL,'[{"param": "count", "sql_cd": -11031}]','[count] 人')
,(68,9,23,'一時転出(出)人数','2',NULL,'一時転出(出)人数','2',NULL,'[{"param": "count", "sql_cd": -11032}]','[count] 人')
,(69,10,23,'一時転出(入)人数','2',NULL,'一時転出(入)人数','2',NULL,'[{"param": "count", "sql_cd": -11033}]','[count] 人')
,(70,11,23,'拒否・不明人数','2',NULL,'拒否・不明人数','2',NULL,'[{"param": "count", "sql_cd": -11034}]','[count] 人')
,(71,12,23,'死亡人数','2',NULL,'死亡人数','2',NULL,'[{"param": "count", "sql_cd": -11035}]','[count] 人')
,(72,13,23,'検査予定人数','2',NULL,'検査予定人数','2',NULL,'[{"param": "count", "sql_cd": -11036}]','[count] 人')
,(73,14,23,'放射線予定人数','2',NULL,'放射線予定人数','2',NULL,'[{"param": "count", "sql_cd": -11037}]','[count] 人')
,(74,1,24,'[name]件数','1','select sub_category_cd as id, sub_category_name as name from mst_pat_event_sub_category where facility_cd = @facilityCd AND is_del = ''0''','[name]件数','1','select sub_category_cd as id, sub_category_name as name from mst_pat_event_sub_category where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11038}]','[count] 件')
;
