DELETE FROM mst_coop_layout
WHERE ctl_no IN (-3080003, -3080004, -3080010, -3080011, -3080018, -3080019);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080003, 'N_hosp', 'rep_dial', '', 'S', 'del', 'xml', 'NEC', 'NEC', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
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
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="delete">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.object_uid</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080004, 'N_hosp', 'rep_dial', '', 'S', 'del', 'xml', 'NEC', 'NEC', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
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
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="delete">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.object_uid</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');


INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080010, 'N_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
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
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.object_uid</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="1">%</disp_info>
        <disp_info no="2">%</disp_info>
        <disp_info no="3">%</disp_info>
        <disp_info no="4">%</disp_info>
        <disp_info no="5">%</disp_info>
        <disp_info no="6">%</disp_info>
        <disp_info no="7">%</disp_info>
        <disp_info no="8">%</disp_info>
        <disp_info no="9">%</disp_info>
        <disp_info no="10">%</disp_info>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-600019.filename"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600019, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080011, 'N_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
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
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.object_uid</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="1">%</disp_info>
        <disp_info no="2">%</disp_info>
        <disp_info no="3">%</disp_info>
        <disp_info no="4">%</disp_info>
        <disp_info no="5">%</disp_info>
        <disp_info no="6">%</disp_info>
        <disp_info no="7">%</disp_info>
        <disp_info no="8">%</disp_info>
        <disp_info no="9">%</disp_info>
        <disp_info no="10">%</disp_info>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-600019.filename"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600019, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080018, 'N_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
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
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.object_uid</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="1">%</disp_info>
        <disp_info no="2">%</disp_info>
        <disp_info no="3">%</disp_info>
        <disp_info no="4">%</disp_info>
        <disp_info no="5">%</disp_info>
        <disp_info no="6">%</disp_info>
        <disp_info no="7">%</disp_info>
        <disp_info no="8">%</disp_info>
        <disp_info no="9">%</disp_info>
        <disp_info no="10">%</disp_info>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-600019.filename"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600019, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080019, 'N_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
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
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.object_uid</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="1">%</disp_info>
        <disp_info no="2">%</disp_info>
        <disp_info no="3">%</disp_info>
        <disp_info no="4">%</disp_info>
        <disp_info no="5">%</disp_info>
        <disp_info no="6">%</disp_info>
        <disp_info no="7">%</disp_info>
        <disp_info no="8">%</disp_info>
        <disp_info no="9">%</disp_info>
        <disp_info no="10">%</disp_info>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-600019.filename"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600019, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');