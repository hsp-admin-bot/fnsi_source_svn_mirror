delete from mst_exam_item where facility_cd = '009997' and exam_item_name in ('K(ｶﾘｳﾑ)','AST(GOT)','Ca','Cr除去率','尿酸(UA)','総蛋白(TP)','総鉄結合能(TIBC)','HBs抗体価(半定量)[PA]','α1-ｸﾞﾛﾌﾞﾘﾝ','ﾌｪﾘﾁﾝ精密','血小板数','多染性');


INSERT INTO mst_exam_item
  (facility_cd 
  , fn_exam_item_cd 
  , exam_item_name 
  , data_type 
  , unit 
  , normal_value_class 
  , normal_value_upper 
  , normal_value_lower 
  , normal_value_upper_m 
  , normal_value_lower_m 
  , normal_value_upper_w 
  , normal_value_lower_w 
  , input_integer_figure 
  , input_decimal_figure 
  , input_upper 
  , input_lower 
  , graph_upper 
  , graph_lower 
  , console_class 
  , exam_class 
  , in_hospital_cd1 
  , sbt_cd1 
  , in_hospital_cd2 
  , sbt_cd2 
  , in_hospital_cd3 
  , sbt_cd3 
  , spitz_cd 
  , jlac10_cd 
  , infection_cd 
  , default_calc_exam_item_cd 
  , free_calc 
  , is_disp 
  , is_del 
  , reg_date 
  , up_date)
VALUES
 ('009997','','K(ｶﾘｳﾑ)','1','mm','1',5,3.6,10,6,4,2.5,2,1,20,0,20,0,'1','0','101','A','201','B','301','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','AST(GOT)','1','b','0',40,10,40,10,40,10,3,1,50,1,50,1,'1','0','102','A','202','B','302','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','Ca','1','c','0',10.2,8.5,10.2,8.5,10.2,8.5,3,1,20,1,20,1,'1','0','103','A','203','B','303','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','Cr除去率','1','d','0',null,null,null,null,null,null,'3','1','100','1','100','1','1','0','104','A','204','B','304','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','尿酸(UA)','1','e','0',7,3.7,7,3.7,7,3.7,3,1,40,1,40,1,'1','0','105','A','205','B','305','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','総蛋白(TP)','1','f','1',null,null,null,null,null,null,null,null,null,null,null,null,'1','0','106','A','206','B','306','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','総鉄結合能(TIBC)','1','g','1',385,231,385,231,385,231,3,1,999,1,999,1,'1','0','107','A','207','B','307','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','HBs抗体価(半定量)[PA]','1','h','1',null,null,null,null,null,null,3,1,100,1,100,1,'1','0','108','A','208','B','308','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','α1-ｸﾞﾛﾌﾞﾘﾝ','1','i','0',100,90,1000,0,1000,0,3,1,1000,1,1000,1,'1','0','109','A','209','B','309','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','ﾌｪﾘﾁﾝ精密','1','','1',null,null,null,null,null,null,3,1,100,1,100,1,'1','0','110','A','210','B','310','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','血小板数','1','x','1',35,13,35,13,35,13,3,1,120,20,120,20,'1','0','111','A','211','B','311','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00'),
 ('009997','','多染性','0','','1',null,null,null,null,null,null,3,1,100,1,100,1,'1','0','112','A','212','B','312','C',null,null,null,0,null,1,0,'2019/10/11  0:00:00','2019/10/11  0:00:00')
  ;
