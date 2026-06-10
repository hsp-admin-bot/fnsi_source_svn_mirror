--sys_report_class初期データを追加
TRUNCATE TABLE sys_report_class;
insert into sys_report_class(report_class_cd,report_class_name,report_type,is_disp,is_del,up_date,reg_date) values 
    (1,'治療経過表','[]','1','0',now(),now())
  , (2,'単患者帳票','[]','1','0',now(),now())
  , (3,'複数患者帳票','[]','1','0',now(),now())
  , (4,'準備リスト','[]','1','0',now(),now())
  , (5,'配布リスト(ベッド)','[]','1','0',now(),now())
  , (6,'配布リスト(物品)','[]','1','0',now(),now())
  , (7,'装置帳票','[]','1','0',now(),now())
  , (8,'ラベル','[]','1','0',now(),now())
  , (9,'紹介状','[{"cd": "1", "name": "紹介状"}, {"cd": "2", "name": "紹介状集計"}]','1','0',now(),now())
  , (10,'単一集計','[{"cd": "1", "name": "紹介状"}]','1','0',now(),now())
  , (11,'複数集計','[{"cd": "1", "name": "スゲージュル表"}, {"cd": "2", "name": "週間薬剤集計表"}, {"cd": "3", "name": "水質調査一覧"}]','1','0',now(),now());
