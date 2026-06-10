-- 治療状況レイアウト表示項目マスタの項目タイトルを変更する
update mst_treatment_status_disp_item set item_name = '治療開始' where item_cd = 8;
update mst_treatment_status_disp_item set item_name = '治療終了' where item_cd = 12;
update mst_treatment_status_disp_item set item_name = '治療時間' where item_cd = 13;
update mst_treatment_status_disp_item set item_name = '患者確認' where item_cd = 50;
