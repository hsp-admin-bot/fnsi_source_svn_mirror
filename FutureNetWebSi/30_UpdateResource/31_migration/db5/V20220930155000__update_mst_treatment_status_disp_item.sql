-- #7865 名称修正　治療状況レイアウトマスタ>治療条件：血流量
update mst_treatment_status_disp_item set item_name = '血流量（治療条件）' where item_cd = 84;
update mst_treatment_status_disp_item set item_name = 'IP速度（治療条件）' where item_cd = 102;
