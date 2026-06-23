-- 患者連携情報の連携オーダ種別に検査依頼と一般撮影検査依頼の情報を追加する
update 
  sys_coop_no 
set 
  coop_ord_cd = coop_ord_cd || '[{"ord_cd": "exam_ord"}, {"ord_cd": "rad_ord"}]';
