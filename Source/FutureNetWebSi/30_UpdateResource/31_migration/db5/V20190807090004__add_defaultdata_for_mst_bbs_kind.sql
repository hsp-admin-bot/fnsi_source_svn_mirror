-- 掲示板種別マスタ
delete from mst_bbs_kind where fn_category_id = '01';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '01', facility_cd, '施設イベント', null, '1', '0', current_timestamp, current_timestamp from mst_facility;

delete from mst_bbs_kind where fn_category_id = '05';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '05', facility_cd, '在庫', null, '1', '0', current_timestamp, current_timestamp from mst_facility;

delete from mst_bbs_kind where fn_category_id = '06';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '06', facility_cd, 'スタッフ予定', null, '1', '0', current_timestamp, current_timestamp from mst_facility;

delete from mst_bbs_kind where fn_category_id = '07';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '07', facility_cd, '製品保守', null, '1', '0', current_timestamp, current_timestamp from mst_facility;

delete from mst_bbs_kind where fn_category_id = '08';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '08', facility_cd, '検査', null, '1', '0', current_timestamp, current_timestamp from mst_facility;

delete from mst_bbs_kind where fn_category_id = '09';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '09', facility_cd, '申し送り', null, '1', '0', current_timestamp, current_timestamp from mst_facility;

delete from mst_bbs_kind where fn_category_id = '10';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '10', facility_cd, '警告', null, '1', '0', current_timestamp, current_timestamp from mst_facility;

delete from mst_bbs_kind where fn_category_id = '12';
insert into mst_bbs_kind (fn_category_id, facility_cd, kind_name, fixed_phrase, is_disp, is_del, reg_date, up_date) select '12', facility_cd, 'その他', null, '1', '0', current_timestamp, current_timestamp from mst_facility;
