INSERT INTO mst_exam_set
  (facility_cd
  , fn_exam_set_cd 
  , set_class 
  , exam_set_name 
  , exam_set_short_name 
  , exam_set_class 
  , is_in_hospital 
  , can_emergency 
  , other_exam_time 
  , exam_item_info 
  , in_hospital_cd1 
  , sbt_cd1 
  , in_hospital_cd2 
  , sbt_cd2 
  , in_hospital_cd3 
  , sbt_cd3 
  , label_info 
  , is_disp 
  , is_del 
  , reg_date 
  , up_date)
VALUES
 ('009997',null,0,'Aセット','A',0,0,0,'0000','[{"exam_item_cd": 1, "exam_item_name": "K(ｶﾘｳﾑ)"}, {"exam_item_cd": 2, "exam_item_name": "AST(GOT)"}, {"exam_item_cd": 3, "exam_item_name": "Ca"}, {"exam_item_cd": 4, "exam_item_name": "Cr除去率"}, {"exam_item_cd": 5, "exam_item_name": "尿酸(UA)"}]','1','1','2','2','3','3','[]',1,0,'2019/9/27  12:00:00','2019/9/27  12:00:00'),
 ('009997',null,0,'Bセット','B',0,0,0,'0000','[{"exam_item_cd": 6, "exam_item_name": "総蛋白(TP)"}, {"exam_item_cd": 7, "exam_item_name": "総鉄結合能(TIBC)"}, {"exam_item_cd": 8, "exam_item_name": "HBs抗体価(半定量)[PA]"}, {"exam_item_cd": 9, "exam_item_name": "α1-ｸﾞﾛﾌﾞﾘﾝ"}, {"exam_item_cd": 10, "exam_item_name": "ﾌｪﾘﾁﾝ精密"}]','1','1','2','2','3','3','[]',1,0,'2019/9/27  12:00:00','2019/9/27  12:00:00'),
 ('009997',null,0,'Cセット','C',0,0,0,'0000','[{"exam_item_cd": 11, "exam_item_name": "血小板数"}, {"exam_item_cd": 12, "exam_item_name": "多染性"}, {"exam_item_cd": 1, "exam_item_name": "K(ｶﾘｳﾑ)"}, {"exam_item_cd": 5, "exam_item_name": "尿酸(UA)"}, {"exam_item_cd": 3, "exam_item_name": "Ca"}]','1','1','2','2','3','3','[]',1,0,'2019/9/27  12:00:00','2019/9/27  12:00:00')
 ;
