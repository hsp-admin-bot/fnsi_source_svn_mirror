delete from "mst_coop_layout" where "ctl_no" in (-3080001,-3080002,-3080003,-3080004,-3080005,-3080006,-3080007,-3080008,-3080009,-3080010,-3080011);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080001, 'N_hosp', 'rep_dial', '', 'S', 'cre', 'xml', 'NEC', 'NEC', '透析レポート送信', '1', '
<multimedia_entry_service>
	<xmlmessage_type>
		<message_name>multimedia_entry_service</message_name>
		<message_type>reference</message_type>
		<message_version>1.0.0.0</message_version>
		<protocol_type>Send_Only</protocol_type>
	</xmlmessage_type>
	<send_message_attribute>
		<send_manufacture_name>日機装株式会社</send_manufacture_name>
		<send_application_name>FutureNet Web+Si</send_application_name>
		<send_application_version>1.0</send_application_version>
		<send_device_name>FutureNetWeb+Si</send_device_name>
		<send_ip_address>192.168.10.52</send_ip_address>
		<send_datetime>$sysdate</send_datetime>
		<additional_information></additional_information>
	</send_message_attribute>
	<application_data_section>
		<entry_data_object type="MMREF" execute="insert" >
			<patient_data>
				<patient_hospital_code>0001</patient_hospital_code>
				<patient_id>dataset:1.hosp_pat_id</patient_id>
				<patients_name>dataset:1.pat_name</patients_name>
				<patients_sex>detaset:1.pat_sex</patients_sex>
				<patients_birthdate>dataset:1.pat_birthday</patients_birthdate>
			</patient_data>
			<object_attribute>
				<object_typ>NIKKISO_FUTUREN</object_typ>
				<object_uid>dataset:-205.tar_key</object_uid>
				<send_system_code>NIKKISO_FUTUREN</send_system_code>
				<relation_typ>URL</relation_typ>
				<me_typ>MMREF</me_typ>
				<me_styp>X</me_styp>
				<datacreater_userid>auth_id:$journal.user_id</datacreater_userid>
				<request_depart_code>dataset:-11.course_cd</request_depart_code>
				<request_userid>dataset:-11.ind_user_id</request_userid>
				<transaction_time>dataset:-11.start_date</transaction_time>
				<flowsheet_starttime>dataset:-11.start_date</flowsheet_starttime>
				<flowsheet_endtime>dataset:-11.end_date</flowsheet_endtime>
				<patient_interactiontime>dataset:-11.start_date</patient_interactiontime>
				<order_id></order_id>
				<host_name>FutureNetWeb+Si</host_name>
			</object_attribute>
			<object_data>
				<title_code>2010_001</title_code>
				<title_name>血液透析記録用紙</title_name>
				<fs_disp>○</fs_disp>
				<disp_info no="n"></disp_info>
			</object_data>
			<storage_data_part mode="filename" count="1">
				<storage_data_information>
					<content_number>0001</content_number>
					<content_type>application/pdf</content_type>
					<extent_name>pdf</extent_name>
					<data_position source="dataset:-104.pdf_file"></data_position>
				</storage_data_information>
			</storage_data_part>
		</entry_data_object>
	</application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -205}, {"ordNo": "ordNo", "sqlCode": -104}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080002, 'N_hosp', 'rep_dial', '', 'S', 'upd', 'xml', 'NEC', 'NEC', '透析レポート送信', '1', '
<multimedia_entry_service>
	<xmlmessage_type>
		<message_name>multimedia_entry_service</message_name>
		<message_type>reference</message_type>
		<message_version>1.0.0.0</message_version>
		<protocol_type>Send_Only</protocol_type>
	</xmlmessage_type>
	<send_message_attribute>
		<send_manufacture_name>日機装株式会社</send_manufacture_name>
		<send_application_name>FutureNet Web+Si</send_application_name>
		<send_application_version>1.0</send_application_version>
		<send_device_name>FutureNetWeb+Si</send_device_name>
		<send_ip_address>192.168.10.52</send_ip_address>
		<send_datetime>$sysdate</send_datetime>
		<additional_information></additional_information>
	</send_message_attribute>
	<application_data_section>
		<entry_data_object type="MMREF" execute="insert" >
			<patient_data>
				<patient_hospital_code>0001</patient_hospital_code>
				<patient_id>dataset:1.hosp_pat_id</patient_id>
				<patients_name>dataset:1.pat_name</patients_name>
				<patients_sex>detaset:1.pat_sex</patients_sex>
				<patients_birthdate>dataset:1.pat_birthday</patients_birthdate>
			</patient_data>
			<object_attribute>
				<object_typ>NIKKISO_FUTUREN</object_typ>
				<object_uid>dataset:-205.tar_key</object_uid>
				<send_system_code>NIKKISO_FUTUREN</send_system_code>
				<relation_typ>URL</relation_typ>
				<me_typ>MMREF</me_typ>
				<me_styp>X</me_styp>
				<datacreater_userid>auth_id:$journal.user_id</datacreater_userid>
				<request_depart_code>dataset:-11.course_cd</request_depart_code>
				<request_userid>dataset:-11.ind_user_id</request_userid>
				<transaction_time>dataset:-11.start_date</transaction_time>
				<flowsheet_starttime>dataset:-11.start_date</flowsheet_starttime>
				<flowsheet_endtime>dataset:-11.end_date</flowsheet_endtime>
				<patient_interactiontime>dataset:-11.start_date</patient_interactiontime>
				<order_id></order_id>
				<host_name>FutureNetWeb+Si</host_name>
			</object_attribute>
			<object_data>
				<title_code>2010_001</title_code>
				<title_name>血液透析記録用紙</title_name>
				<fs_disp>○</fs_disp>
				<disp_info no="n"></disp_info>
			</object_data>
			<storage_data_part mode="filename" count="1">
				<storage_data_information>
					<content_number>0001</content_number>
					<content_type>application/pdf</content_type>
					<extent_name>pdf</extent_name>
					<data_position source="dataset:-104.pdf_file"></data_position>
				</storage_data_information>
			</storage_data_part>
		</entry_data_object>
	</application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -205}, {"ordNo": "ordNo", "sqlCode": -104}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080003, 'N_hosp', 'rep_dial', '', 'S', 'del', 'xml', 'NEC', 'NEC', '透析レポート送信', '1', '
<multimedia_entry_service>
	<xmlmessage_type>
		<message_name>multimedia_entry_service</message_name>
		<message_type>reference</message_type>
		<message_version>1.0.0.0</message_version>
		<protocol_type>Send_Only</protocol_type>
	</xmlmessage_type>
	<send_message_attribute>
		<send_manufacture_name>日機装株式会社</send_manufacture_name>
		<send_application_name>FutureNet Web+Si</send_application_name>
		<send_application_version>1.0</send_application_version>
		<send_device_name>FutureNetWeb+Si</send_device_name>
		<send_ip_address>192.168.10.52</send_ip_address>
		<send_datetime>$sysdate</send_datetime>
		<additional_information></additional_information>
	</send_message_attribute>
	<application_data_section>
		<entry_data_object type="MMREF" execute="insert" >
			<patient_data>
				<patient_hospital_code>0001</patient_hospital_code>
				<patient_id>dataset:1.hosp_pat_id</patient_id>
				<patients_name>dataset:1.pat_name</patients_name>
				<patients_sex>detaset:1.pat_sex</patients_sex>
				<patients_birthdate>dataset:1.pat_birthday</patients_birthdate>
			</patient_data>
			<object_attribute>
				<object_typ>NIKKISO_FUTUREN</object_typ>
				<object_uid>dataset:-205.tar_key</object_uid>
				<send_system_code>NIKKISO_FUTUREN</send_system_code>
				<relation_typ>URL</relation_typ>
				<me_typ>MMREF</me_typ>
				<me_styp>X</me_styp>
				<datacreater_userid>auth_id:$journal.user_id</datacreater_userid>
				<request_depart_code>dataset:-11.course_cd</request_depart_code>
				<request_userid>dataset:-11.ind_user_id</request_userid>
				<transaction_time>dataset:-11.start_date</transaction_time>
				<flowsheet_starttime>dataset:-11.start_date</flowsheet_starttime>
				<flowsheet_endtime>dataset:-11.end_date</flowsheet_endtime>
				<patient_interactiontime>dataset:-11.start_date</patient_interactiontime>
				<order_id></order_id>
				<host_name>FutureNetWeb+Si</host_name>
			</object_attribute>
			<object_data>
				<title_code>2010_001</title_code>
				<title_name>血液透析記録用紙</title_name>
				<fs_disp>○</fs_disp>
				<disp_info no="n"></disp_info>
			</object_data>
			<storage_data_part mode="filename" count="1">
				<storage_data_information>
					<content_number>0001</content_number>
					<content_type>application/pdf</content_type>
					<extent_name>pdf</extent_name>
					<data_position source="dataset:-104.pdf_file"></data_position>
				</storage_data_information>
			</storage_data_part>
		</entry_data_object>
	</application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -205}, {"ordNo": "ordNo", "sqlCode": -104}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080004, 'N_hosp', 'rep_dial', 'xml', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(xml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-600001.up_date">
    <DISP_PATID>dataset:-600001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-600001.pat_name</NAME>
    <KANA>dataset:-600001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-600001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-600001.pat_age</AGE>
    <SEX>dataset:-600001.pat_sex</SEX>
    <INOUT>dataset:-600001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-600000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600000}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080005, 'N_hosp', 'rep_dial', 'xml', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(xml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-600001.up_date">
    <DISP_PATID>dataset:-600001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-600001.pat_name</NAME>
    <KANA>dataset:-600001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-600001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-600001.pat_age</AGE>
    <SEX>dataset:-600001.pat_sex</SEX>
    <INOUT>dataset:-600001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-600000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600000}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080006, 'N_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(listxml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-600010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-600001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-600001.pat_name" KANA="dataset:-600001.pat_name_kana"  SEX="dataset:-600001.pat_sex" BLOODABO="dataset:-600001.pat_blood_type_abo" BLOODRH="dataset:-600001.pat_blood_type_rh" AGE="dataset:-600001.pat_age" UPDATE_DATETIME="dataset:-600001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600010, "facilityCd": "facilityCd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080007, 'N_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(listxml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-600010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-600001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-600001.pat_name" KANA="dataset:-600001.pat_name_kana"  SEX="dataset:-600001.pat_sex" BLOODABO="dataset:-600001.pat_blood_type_abo" BLOODRH="dataset:-600001.pat_blood_type_rh" AGE="dataset:-600001.pat_age" UPDATE_DATETIME="dataset:-600001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600010, "facilityCd": "facilityCd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080008, 'N_hosp', 'rep_dial', 'pdf', 'S', 'upd', 'pdf', 'NEC標準(MegaOakHR) 透析レポート(pdf)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', NULL, NULL, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080009, 'N_hosp', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'NEC標準(MegaOakHR) 透析レポート(pdf)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', NULL, NULL, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080010, 'N_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-600001.up_date">
    <DISP_PATID>dataset:-600001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-600001.pat_name</NAME>
    <KANA>dataset:-600001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-600001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-600001.pat_age</AGE>
    <SEX>dataset:-600001.pat_sex</SEX>
    <INOUT>dataset:-600001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-600000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600000}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3080011, 'N_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-600001.up_date">
    <DISP_PATID>dataset:-600001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-600001.pat_name</NAME>
    <KANA>dataset:-600001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-600001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-600001.pat_age</AGE>
    <SEX>dataset:-600001.pat_sex</SEX>
    <INOUT>dataset:-600001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-600000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600000}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
