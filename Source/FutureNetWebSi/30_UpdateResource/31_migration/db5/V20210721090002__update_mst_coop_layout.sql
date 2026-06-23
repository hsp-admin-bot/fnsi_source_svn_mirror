delete from "mst_coop_layout" where "ctl_no" = -2080008 OR "ctl_no" = -2080009 ;
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080008, 'F_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'listxml', 'fujitsu', 'report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-100010.hosp_pat_id_len">



<PATIENT DISP_PATID="dataset:-100001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-100001.pat_name" KANA="dataset:-100001.pat_name_kana"  SEX="dataset:-100001.pat_sex" BLOODABO="dataset:-100001.pat_blood_type_abo" BLOODRH="dataset:-100001.pat_blood_type_rh" AGE="dataset:-100001.pat_age" UPDATE_DATETIME="dataset:-100001.up_date"></PATIENT>



</rootNode>



', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100010, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080009, 'F_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'listxml', 'fujitsu', 'report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-100010.hosp_pat_id_len">



<PATIENT DISP_PATID="dataset:-100001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-100001.pat_name" KANA="dataset:-100001.pat_name_kana"  SEX="dataset:-100001.pat_sex" BLOODABO="dataset:-100001.pat_blood_type_abo" BLOODRH="dataset:-100001.pat_blood_type_rh" AGE="dataset:-100001.pat_age" UPDATE_DATETIME="dataset:-100001.up_date"></PATIENT>



</rootNode>



', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100010, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
