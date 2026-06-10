# テーブル参照

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `テーブル参照`
- Category: overview

## Content

| テーブル参照 | col2 | col3 | col4 | 透析運用保守 | col6 | col7 | col8 | col9 | col10 | デバイスエッジ | col12 | 生体モニタリング | 透析業務支援 | col15 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| NTSSデータベース設計書.xlsm | ■ | No | テーブル名 | 稼働ビューア | 緊急発報 | マスタ同期 | データ収集 | DE死活監視 | 装置死活監視 | 通知用EC2アプリ | デバイスエッジデータ取得用EC2アプリ | 生体モニタリング | 患者経過総合ビューア | マスタメンテナンス |
|  |  |  | 確認日時 | 43430 | 43430 | 43441 | 43441 | 43441 | 43441 | 43430 | 43430 | 43430 | 43524 | 43430 |
| 2 | ■ | 1 | mni_monitor | - | - | - | - | - | - | - | ○ | ○ | - |  |
| 3 | ■ | 2 | mnt_client_connect | - | - | ○ | - | - | - | ○ | - | ○ | - |  |
| 5 | ■ | 3 | mnt_device_edge_state | ○ | ○ | - | - | ○ | ○ | - | ○ | - | - |  |
| 2 | ■ | 4 | mnt_gathering_manage | ○ | - | - | ○ | - | - | - | - | - | - |  |
| 4 | ■ | 5 | mnt_machine_state | ○ | - | - | - | - | ○ | - | ○ | ○ | - |  |
| 4 | ■ | 6 | mnt_motion_record | ○ | ○ | - | ○ | - | - | - | ○ | - | - |  |
| 0 | ■ | 7 | mnt_weight_state | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 8 | mnt_websocket_certification | - | - | - | - | - | - | - | - | ○ | - |  |
| 2 | ■ | 9 | mst_bed | - | - | - | - | - | - | - | - | ○ | ○ |  |
| 1 | ■ | 10 | mst_bio_moni_frame_pattern | - | - | - | - | - | - | - | - | ○ | - |  |
| 0 | ■ | 11 | mst_com_fixed_phrase | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 12 | mst_course | - | - | - | - | - | - | - | - | - | - |  |
| 5 | ■ | 13 | mst_device_edge | ○ | ○ | ○ | ○ | ○ | - | - | - | - | - |  |
| 0 | ■ | 14 | mst_dialysis_difficulty | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 15 | mst_dialyzer | - | - | - | - | - | - | - | - | - | ○ |  |
| 0 | ■ | 16 | mst_disease | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 17 | mst_equipment | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 18 | mst_equipment_class | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 19 | mst_equipment_set | - | - | - | - | - | - | - | - | - | ○ |  |
| 5 | ■ | 20 | mst_facility | ○ | ○ | ○ | ○ | ○ | - | - | - | - | - |  |
| 1 | ■ | 21 | mst_facility_hash | ○ | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 22 | mst_frame_define | - | - | - | - | - | - | - | - | ○ | - |  |
| 0 | ■ | 23 | mst_implant | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 24 | mst_infection | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 25 | mst_kur | - | - | - | - | - | - | - | - | - | ○ |  |
| 2 | ■ | 26 | mst_m_notice | - | ○ | ○ | - | - | - | - | - | - | - |  |
| 5 | ■ | 27 | mst_machine | ○ | ○ | ○ | ○ | - | - | - | - | ○ | - |  |
| 2 | ■ | 28 | mst_machine_record | - | ○ | - | - | - | - | - | ○ | - | - |  |
| 2 | ■ | 29 | mst_machine_type | ○ | ○ | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 30 | mst_medicate_timing | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 31 | mst_medicine | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 32 | mst_medicine_class | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 33 | mst_medicine_set | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 34 | mst_moni_item | - | - | - | - | - | - | - | - | ○ | - |  |
| 0 | ■ | 35 | mst_obs_kind | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 36 | mst_pat_memo | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 37 | mst_pat_viewer_layout | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 38 | mst_personal_user | ○ | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 39 | mst_preparation_medicine | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 40 | mst_procedure | - | - | - | - | - | - | - | - | - | ○ |  |
| 0 | ■ | 41 | mst_relationship | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 42 | mst_room_bed_group | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 43 | mst_selector | - | - | - | - | - | - | - | - | - | - | ○ |
| 0 | ■ | 44 | mst_severity | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 45 | mst_staff_facility | ○ | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 46 | mst_standard_course | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 47 | mst_standard_disease | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 48 | mst_standard_medicine | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 49 | mst_taboo_allergy | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 50 | mst_transport | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 51 | mst_treatment | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 52 | mst_treatment_set | - | - | - | - | - | - | - | - | - | ○ |  |
| 2 | ■ | 53 | mst_user | ○ | - | ○ | - | - | - | - | - | - | - |  |
| 1 | ■ | 54 | mst_user_authentication | ○ | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 55 | mst_va | - | - | - | - | - | - | - | - | - | ○ |  |
| 0 | ■ | 56 | mst_ward | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 57 | mst_weight | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 58 | mst_weight_print | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 59 | mst_weight_scale | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 60 | mst_wheel_chair | - | - | - | - | - | - | - | - | - | - |  |
| 2 | ■ | 61 | ord_main | - | - | - | - | - | - | - | - | ○ | ○ |  |
| 1 | ■ | 62 | ord_schedule | - | - | - | - | - | - | - | - | - | ○ |  |
| 0 | ■ | 63 | ord_weight_scale | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 64 | pat_event | - | - | - | - | - | - | - | - | - | - |  |
| 2 | ■ | 65 | pat_main | - | - | - | - | - | - | - | - | ○ | ○ |  |
| 0 | ■ | 66 | pat_personal_main | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 67 | pat_unique | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 68 | pat_obs_rec | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 69 | pat_prescription | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 70 | pat_prescription_detail | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 71 | sys_address | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 72 | sys_country | - | - | - | - | - | - | - | - | - | - |  |
| 1 | ■ | 73 | sys_data_item | - | - | - | - | - | - | - | - | - | ○ |  |
| 1 | ■ | 74 | sys_master_define | - | - | - | - | - | - | - | - | - | - | ○ |
| 1 | ■ | 75 | sys_prefectures | ○ | - | - | - | - | - | - | - | - | - |  |
| 4 | ■ | 76 | sys_system_define | - | ○ | - | ○ | ○ | ○ | - | - | - | - |  |
| 0 | ■ | 77 | mst_destination_group |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 78 | mst_alarm_notification |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 79 | ord_treat_condition |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 80 | mst_treatment_status_layout |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 81 | mst_comsv_setting |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 82 | ord_treat_condition |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 83 | mst_treatment_status_layout |  |  |  |  |  |  |  |  |  |  |  |
| 1 | ■ | 84 | pat_treatment_pattern | - | - | - | - | - | - | - | - | - | ○ |  |
| 0 | ■ | 85 | mst_checklist | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 86 | mst_dialysis_progress | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 87 | ord_checklist | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 88 | mst_status_map_bed_layout | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 89 | mst_pat_list_layout | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 90 | mst_device_set_info_default | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 91 | mst_facility_setting | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 92 | mst_treatment_status_disp_item | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 93 | ord_monitor |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 94 | mst_personal_tab_define |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 95 | mst_job |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 96 | mst_report | - | - | - | - | - | - | - | - | - | - | - |
| 0 | ■ | 97 | mst_printer | - | - | - | - | - | - | - | - | - | - | - |
| 1 | ■ | 98 | sys_function | - | - | - | - | - | - | - | - | - | - | ○ |
| 0 | ■ | 99 | mst_round_type |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 100 | mst_complaint |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 101 | mst_comp_treatment |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 102 | mst_bbs_kind | - | - | - | - | - | - | - | - | - | - | - |
| 0 | ■ | 103 | bbs_info | - | - | - | - | - | - | - | - | - | - | - |
| 0 | ■ | 104 | mst_temporary_dialysis | - | - | - | - | - | - | - | - | - | - |  |
| 0 | ■ | 105 | mst_monitor_graph |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 106 | sys_personal_settings_define |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 107 | sys_facility_setting |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 108 | mst_notification_message |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 109 | mnt_notification_message |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 110 | mnt_notification_status |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 111 | mst_function_report |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 112 | mst_pat_event_category |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 113 | mst_pat_event_sub_category |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 114 | mst_pat_event_data_template |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 115 | mst_trend_graph_template |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 116 | mst_trend_graph_monitor_set |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 117 | mst_spitz |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 118 | mst_exam_item |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 119 | mst_exam_set |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 120 | pat_exam_pattern |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 121 | pat_exam_main |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 122 | mst_rad_set |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 123 | pat_rad_pattern |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 124 | pat_rad_main |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 125 | sys_data_set |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 126 | pat_group |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 127 | pat_group_detail |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 128 | mst_pat_calendar_layout |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 129 | mst_pat_hash |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 130 | mnt_device_edge_manage |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 131 | pat_ind_approve |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 132 | pat_hhd_pattern |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 133 | mst_insurance |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 134 | pat_insurance |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 135 | mst_medicine_mix |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 136 | mnt_if_edge_healthmon |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 137 | mst_coop_distribute |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 138 | mst_coop_facility |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 139 | mst_coop_layout |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 140 | mst_coop_layout_detail |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 141 | mst_if_edge |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 142 | sys_coop_journal |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 143 | mst_medicine_group |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 144 | mst_add_monitor |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 145 | sys_monitor_item |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 146 | sys_facility |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 147 | mst_favorite_facility |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 148 | ord_addition |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 149 | mst_holiday |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 150 | mst_addition |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 151 | sys_notification |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 152 | mst_url_link_register |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 153 | mst_mainte_detail |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 154 | mnt_mainte_main |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 155 | mst_mainte_layout_group |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 156 | mst_mainte_category |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 157 | mst_mainte_layout |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 158 | mnt_water_survey |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 159 | mst_water_survey_point |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 160 | mst_water_survey_type |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 161 | mnt_batch_manager |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 162 | sys_notification_list |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 163 | sys_daily_no |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 164 | pat_name_identification |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 165 | mst_facility_calendar_layout |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 166 | mst_mainte_detail_hst |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 167 | mst_mainte_layout_group_hst |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 168 | mst_mainte_category_hst |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 169 | mst_mainte_layout_hst |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 170 | sys_medicine |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 171 | ord_prescription |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 172 | ord_personal_prescription |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 173 | sys_generic_medicine |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 174 | mst_take_medicine |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 175 | sys_subscription_plan |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 176 | sal_subscription_manage |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 177 | sys_function_advanced |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 178 | mst_pat_search_detail |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 179 | pat_ind_approve_history |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 180 | sys_release_info |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 181 | sys_signin_manager |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 182 | sys_data_list_category |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 183 | sys_data_list_detail |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 184 | mst_graph_setting |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 185 | mnt_facility_cancel_manage |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 186 | mnt_find_machine |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 187 | mst_self_measure_result |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 188 | mnt_cardapp_port |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 189 | mst_vital_graph |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 190 | mst_machine_record_control |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 191 | mst_self_measure_result |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 192 | log_table_comment |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 193 | log_json_comment |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 194 | log_table_comment(db4) |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 195 | log_json_comment(db4) |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 196 | log_table_comment(db6) |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 197 | log_json_comment(db6) |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 198 | mst_exam_matome |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 199 | sys_report_setting |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 200 | mst_medicine_support |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 201 | ord_material_save |  |  |  |  |  |  |  |  |  |  |  |
| 0 | ■ | 202 | mst_menu_group |  |  |  |  |  |  |  |  |  |  |  |
| 0 |  | 203 | =IF(""<>テーブル一覧!E208,テーブル一覧!E208,"") |  |  |  |  |  |  |  |  |  |  |  |
| 0 |  | 204 | =IF(""<>テーブル一覧!E209,テーブル一覧!E209,"") |  |  |  |  |  |  |  |  |  |  |  |
| 0 |  | 205 | =IF(""<>テーブル一覧!E210,テーブル一覧!E210,"") |  |  |  |  |  |  |  |  |  |  |  |
| 0 |  | 206 | =IF(""<>テーブル一覧!E211,テーブル一覧!E211,"") |  |  |  |  |  |  |  |  |  |  |  |
