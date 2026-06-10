# テーブル一覧

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `テーブル一覧`
- Category: overview

## Content

| テーブル一覧 | col2 | col3 | col4 | ↓テーブル名記入 | col6 | col7 | ↓関連サービスなどを記入 | バックアップ除外リスト（「SYS_」はバックアップ対象外） | col10 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| NTSSデータベース設計書.xlsm | ■ | No | 接頭文字 | テーブル名 | 対応履歴テーブル名 | 最終更新日時 | 備考 |  | テーブル名 |
|  | ■ | 1 | mni | mni_monitor | =IF(E3<>"",IFERROR(IF(E3=VLOOKUP(E3,$K$3:$K$213,1,FALSE),""),E3&"_hst"),"") | 44132 | アプリケーション共通 |  | mni_monitor |
|  | ■ | 2 | mnt | mnt_client_connect |  | 43430 | アプリケーション共通 |  | mnt_machine_state |
|  | ■ | 3 | mnt | mnt_device_edge_state |  | 44113 | アプリケーション共通 |  | mnt_device_edge_state |
|  | ■ | 4 | mnt | mnt_gathering_manage | mnt_gathering_manage_hst | 43452 | データ収集系 |  | mnt_client_connect |
|  | ■ | 5 | mnt | mnt_machine_state |  | 44247 | アプリケーション共通 |  | sys_data_item |
|  | ■ | 6 | mnt | mnt_motion_record | mnt_motion_record_hst | =IFERROR(VLOOKUP(E8,変更履歴!$A$3:$G$1062,7,FALSE),"") | 緊急発報系 |  | sys_system_define |
|  | ■ | 7 | mnt | mnt_weight_state | mnt_weight_state_hst | =IFERROR(VLOOKUP(E9,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  | sys_prefectures |
|  | ■ | 8 | mnt | mnt_websocket_certification | mnt_websocket_certification_hst | 43511 | アプリケーション共通 |  | sys_country |
|  | ■ | 9 | mst | mst_bed | mst_bed_hst | =IFERROR(VLOOKUP(E11,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  | sys_address |
|  | ■ | 10 | mst | mst_bio_moni_frame_pattern | mst_bio_moni_frame_pattern_hst | 43488 | 生体モニタリング系 |  | sys_process_server |
|  | ■ | 11 | mst | mst_com_fixed_phrase | mst_com_fixed_phrase_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 12 | mst | mst_course | mst_course_hst | 44124 | 透析業務支援系 |  |  |
|  | ■ | 13 | mst | mst_device_edge | mst_device_edge_hst | 43432 | アプリケーション共通 |  |  |
|  | ■ | 14 | mst | mst_dialysis_difficulty | mst_dialysis_difficulty_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 15 | mst | mst_dialyzer | mst_dialyzer_hst | 43908 | 透析業務支援系 |  |  |
|  | ■ | 16 | mst | mst_disease | mst_disease_hst | 43678 | 透析業務支援系 |  |  |
|  | ■ | 17 | mst | mst_equipment | mst_equipment_hst | 43908 | 透析業務支援系 |  |  |
|  | ■ | 18 | mst | mst_equipment_class | mst_equipment_class_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 19 | mst | mst_equipment_set | mst_equipment_set_hst | 44965 | 透析業務支援系 |  |  |
|  | ■ | 20 | mst | mst_facility | mst_facility_hst | =IFERROR(VLOOKUP(E22,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 21 | mst | mst_facility_hash | mst_facility_hash_hst | 44151 | アプリケーション共通 |  |  |
|  | ■ | 22 | mst | mst_frame_define | mst_frame_define_hst | 43488 | アプリケーション共通 |  |  |
|  | ■ | 23 | mst | mst_implant | mst_implant_hst | 44124 | 透析業務支援系 |  |  |
|  | ■ | 24 | mst | mst_infection | mst_infection_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 25 | mst | mst_kur | mst_kur_hst | 44153 | 透析業務支援系 |  |  |
|  | ■ | 26 | mst | mst_m_notice | mst_m_notice_hst | 43074 | 緊急発報系 |  |  |
|  | ■ | 27 | mst | mst_machine | mst_machine_hst | =IFERROR(VLOOKUP(E29,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 28 | mst | mst_machine_record | mst_machine_record_hst | 44162 | アプリケーション共通 |  |  |
|  | ■ | 29 | mst | mst_machine_type | mst_machine_type_hst | =IFERROR(VLOOKUP(E31,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 30 | mst | mst_medicate_timing | mst_medicate_timing_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 31 | mst | mst_medicine | mst_medicine_hst | 43908 | 透析業務支援系 |  |  |
|  | ■ | 32 | mst | mst_medicine_class | mst_medicine_class_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 33 | mst | mst_medicine_set | mst_medicine_set_hst | 43908 | 透析業務支援系 |  |  |
|  | ■ | 34 | mst | mst_moni_item | mst_moni_item_hst | 43488 | アプリケーション共通 |  |  |
|  | ■ | 35 | mst | mst_obs_kind | mst_obs_kind_hst | 43500 | 透析業務支援系 |  |  |
|  | ■ | 36 | mst | mst_pat_memo | mst_pat_memo_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 37 | mst | mst_pat_viewer_layout | mst_pat_viewer_layout_hst | 43829 | 透析業務支援系 |  |  |
|  | ■ | 38 | mst | mst_personal_user | mst_personal_user_hst | 44099 | アプリケーション共通 |  |  |
|  | ■ | 39 | mst | mst_preparation_medicine | mst_preparation_medicine_hst | 43839 | 透析業務支援系 ※変更履歴:No.624 で削除 |  |  |
|  | ■ | 40 | mst | mst_procedure | mst_procedure_hst | 43908 | 透析業務支援系 |  |  |
|  | ■ | 41 | mst | mst_relationship | mst_relationship_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 42 | mst | mst_room_bed_group | mst_room_bed_group_hst | 43486 | 透析業務支援系 |  |  |
|  | ■ | 43 | mst | mst_selector | mst_selector_hst | 43494 | 透析業務支援系 |  |  |
|  | ■ | 44 | mst | mst_severity | mst_severity_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 45 | mst | mst_staff_facility | mst_staff_facility_hst | 43454 | アプリケーション共通 |  |  |
|  | ■ | 46 | mst | mst_standard_course | mst_standard_course_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 47 | mst | mst_standard_disease | mst_standard_disease_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 48 | mst | mst_standard_medicine | mst_standard_medicine_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 49 | mst | mst_taboo_allergy | mst_taboo_allergy_hst | 44173 | 透析業務支援系 |  |  |
|  | ■ | 50 | mst | mst_transport | mst_transport_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 51 | mst | mst_treatment | mst_treatment_hst | =IFERROR(VLOOKUP(E53,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 52 | mst | mst_treatment_set | mst_treatment_set_hst | =IFERROR(VLOOKUP(E54,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 53 | mst | mst_user | mst_user_hst | =IFERROR(VLOOKUP(E55,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 54 | mst | mst_user_authentication | mst_user_authentication_hst | 44099 | アプリケーション共通 |  |  |
|  | ■ | 55 | mst | mst_va | mst_va_hst | 43552 | 透析業務支援系 |  |  |
|  | ■ | 56 | mst | mst_ward | mst_ward_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 57 | mst | mst_weight | mst_weight_hst | 44190 | 透析業務支援系 |  |  |
|  | ■ | 58 | mst | mst_weight_print | mst_weight_print_hst | 44127 | 透析業務支援系 |  |  |
|  | ■ | 59 | mst | mst_weight_scale | mst_weight_scale_hst | 43501 | 透析業務支援系 |  |  |
|  | ■ | 60 | mst | mst_wheel_chair | mst_wheel_chair_hst | =IFERROR(VLOOKUP(E62,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 61 | ord | ord_main | ord_main_hst | =IFERROR(VLOOKUP(E63,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 62 | ord | ord_schedule | ord_schedule_hst | 43601 | 透析業務支援系 |  |  |
|  | ■ | 63 | ord | ord_vital | ord_vital_hst | 43823 | 透析業務支援系 ※変更履歴:No.619 で削除 |  |  |
|  | ■ | 64 | ord | ord_weight_scale | ord_weight_scale_hst | =IFERROR(VLOOKUP(E66,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 65 | pat | pat_event | pat_event_hst | =IFERROR(VLOOKUP(E67,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 66 | pat | pat_main | pat_main_hst | =IFERROR(VLOOKUP(E68,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 67 | pat | pat_personal_main | pat_personal_main_hst | =IFERROR(VLOOKUP(E69,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 68 | pat | pat_unique | pat_unique_hst | =IFERROR(VLOOKUP(E70,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 69 | pat | pat_obs_rec | pat_obs_rec_hst | 43493 | 透析業務支援系 |  |  |
|  | ■ | 70 | pat | pat_prescription | pat_prescription_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 71 | pat | pat_prescription_detail | pat_prescription_detail_hst | 43488 | 透析業務支援系 |  |  |
|  | ■ | 72 | sys | sys_address |  | 43488 | 透析業務支援系 |  |  |
|  | ■ | 73 | sys | sys_country |  | 43488 | 透析業務支援系 |  |  |
|  | ■ | 74 | sys | sys_data_item |  | 43488 | 患者経過総合ビューア系 |  |  |
|  | ■ | 75 | sys | sys_master_define | sys_master_define_hst | 44123 | 透析業務支援系 |  |  |
|  | ■ | 76 | sys | sys_prefectures |  | 43245 | アプリケーション共通 |  |  |
|  | ■ | 77 | sys | sys_system_define |  | 43522 | アプリケーション共通 |  |  |
|  | ■ | 78 | mst | mst_destination_group | mst_destination_group_hst | 43522 | 透析業務支援系 |  |  |
|  | ■ | 79 | mst | mst_alarm_notification | mst_alarm_notification_hst | 43686 | 透析業務支援系 |  |  |
|  | ■ | 80 | mst | mst_comsv_setting | mst_comsv_setting_hst | =IFERROR(VLOOKUP(E82,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 81 | ord | ord_treat_condition | ord_treat_condition_hst | 43546 | 透析業務支援系 |  |  |
|  | ■ | 82 | mst | mst_treatment_status_layout | mst_treatment_status_layout_hst | 43527 | 透析業務支援系 |  |  |
|  | ■ | 83 | pat | pat_treatment_pattern | pat_treatment_pattern_hst | =IFERROR(VLOOKUP(E85,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 84 | mst | mst_checklist | mst_checklist_hst | =IFERROR(VLOOKUP(E86,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 85 | mst | mst_dialysis_progress | mst_dialysis_progress_hst | 43546 | 透析業務支援系 |  |  |
|  | ■ | 86 | ord | ord_checklist | ord_checklist_hst | 44204 | 透析業務支援系 |  |  |
|  | ■ | 87 | mst | mst_status_map_bed_layout | mst_status_map_bed_layout_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 88 | mst | mst_pat_list_layout | mst_pat_list_layout_hst | =IFERROR(VLOOKUP(E90,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 89 | mst | mst_device_set_info_default | mst_device_set_info_default_hst | =IFERROR(VLOOKUP(E91,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 90 | mst | mst_facility_setting | mst_facility_setting_hst | 43990 | 透析業務支援系 |  |  |
|  | ■ | 91 | mst | mst_treatment_status_disp_item | mst_treatment_status_disp_item_hst | 43602 | 透析業務支援系 |  |  |
|  | ■ | 92 | ord | ord_monitor | ord_monitor_hst | 43823 | 透析業務支援系 ※変更履歴:No.618 で削除 |  |  |
|  | ■ | 93 | mst | mst_personal_tab_define | mst_personal_tab_define_hst | 43613 | 透析業務支援系 |  |  |
|  | ■ | 94 | mst | mst_job | mst_job_hst | 43614 | アプリケーション共通 |  |  |
|  | ■ | 95 | mst | mst_report | mst_report_hst | =IFERROR(VLOOKUP(E97,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 96 | mst | mst_printer | mst_printer_hst | 43711 | 透析業務支援系 |  |  |
|  | ■ | 97 | sys | sys_function | sys_function_hst | 43628 | アプリケーション共通 |  |  |
|  | ■ | 98 | mst | mst_round_type | mst_round_type_hst | 43642 | 透析業務支援系 |  |  |
|  | ■ | 99 | mst | mst_complaint | mst_complaint_hst | 43651 | 透析業務支援系 |  |  |
|  | ■ | 100 | mst | mst_comp_treatment | mst_comp_treatment_hst | 43651 | 透析業務支援系 |  |  |
|  | ■ | 101 | mst | mst_bbs_kind | mst_bbs_kind_hst | 43929 | 透析業務支援系 |  |  |
|  | ■ | 102 | bbs | bbs_info | bbs_info_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 103 | mst | mst_temporary_dialysis | mst_temporary_dialysis_hst | 43656 | 透析業務支援系 |  |  |
|  | ■ | 104 | mst | mst_monitor_graph | mst_monitor_graph_hst | 43665 | 透析業務支援系 |  |  |
|  | ■ | 105 | sys | sys_personal_settings_define | sys_personal_settings_define_hst | 43665 | 透析業務支援系 |  |  |
|  | ■ | 106 | sys | sys_facility_setting | sys_facility_setting_hst | =IFERROR(VLOOKUP(E108,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 107 | mst | mst_notification_message | mst_notification_message_hst | 43679 | 透析業務支援系 |  |  |
|  | ■ | 108 | mnt | mnt_notification_message | mnt_notification_message_hst | 43679 | 透析業務支援系 |  |  |
|  | ■ | 109 | mnt | mnt_notification_status | mnt_notification_status_hst | 43679 | 透析業務支援系 |  |  |
|  | ■ | 110 | mst | mst_function_report | mst_function_report_hst | 43697 | 透析業務支援系 |  |  |
|  | ■ | 111 | mst | mst_pat_event_category | mst_pat_event_category_hst | =IFERROR(VLOOKUP(E113,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 112 | mst | mst_pat_event_sub_category | mst_pat_event_sub_category_hst | =IFERROR(VLOOKUP(E114,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 113 | mst | mst_pat_event_data_template | mst_pat_event_data_template_hst | =IFERROR(VLOOKUP(E115,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 114 | mst | mst_trend_graph_template | mst_trend_graph_template_hst | =IFERROR(VLOOKUP(E116,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 115 | mst | mst_trend_graph_monitor_set | mst_trend_graph_monitor_set_hst | 44454 | 透析業務支援系 |  |  |
|  | ■ | 116 | mst | mst_spitz | mst_spitz_hst | =IFERROR(VLOOKUP(E118,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 117 | mst | mst_exam_item | mst_exam_item_hst | =IFERROR(VLOOKUP(E119,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 118 | mst | mst_exam_set | mst_exam_set_hst | =IFERROR(VLOOKUP(E120,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 119 | pat | pat_exam_pattern | pat_exam_pattern_hst | 44126 | 透析業務支援系 |  |  |
|  | ■ | 120 | pat | pat_exam_main | pat_exam_main_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 121 | mst | mst_rad_set | mst_rad_set_hst | =IFERROR(VLOOKUP(E123,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 122 | pat | pat_rad_pattern | pat_rad_pattern_hst | 44126 | 透析業務支援系 |  |  |
|  | ■ | 123 | pat | pat_rad_main | pat_rad_main_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 124 | sys | sys_data_set | sys_data_set_hst | 43727 | アプリケーション共通 |  |  |
|  | ■ | 125 | pat | pat_group | pat_group_hst | =IFERROR(VLOOKUP(E127,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 126 | pat | pat_group_detail | pat_group_detail_hst | 44127 | 透析業務支援系 |  |  |
|  | ■ | 127 | mst | mst_pat_calendar_layout | mst_pat_calendar_layout_hst | =IFERROR(VLOOKUP(E129,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 128 | mst | mst_pat_hash | mst_pat_hash_hst | 43742 | 透析業務支援系 |  |  |
|  | ■ | 129 | mnt | mnt_device_edge_manage | mnt_device_edge_manage_hst | 44046 | アプリケーション共通 |  |  |
|  | ■ | 130 | pat | pat_ind_approve | pat_ind_approve_hst | 44222 | 透析業務支援系 |  |  |
|  | ■ | 131 | pat | pat_hhd_pattern | pat_hhd_pattern_hst | 43784 | 透析業務支援系 |  |  |
|  | ■ | 132 | mst | mst_insurance | mst_insurance_hst | 44280 |  |  |  |
|  | ■ | 133 | pat | pat_insurance | pat_insurance_hst | =IFERROR(VLOOKUP(E135,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  | ■ | 134 | mst | mst_medicine_mix | mst_medicine_mix_hst | =IFERROR(VLOOKUP(E136,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 135 | mnt | mnt_if_edge_healthmon | mnt_if_edge_healthmon_hst | 43865 | 外部システム連携 |  |  |
|  | ■ | 136 | mst | mst_coop_distribute | mst_coop_distribute_hst | 43865 | 外部システム連携 |  |  |
|  | ■ | 137 | mst | mst_coop_facility | mst_coop_facility_hst | 43865 | 外部システム連携 |  |  |
|  | ■ | 138 | mst | mst_coop_layout | mst_coop_layout_hst | 43865 | 外部システム連携 |  |  |
|  | ■ | 139 | mst | mst_coop_layout_detail | mst_coop_layout_detail_hst | 43865 | 外部システム連携 |  |  |
|  | ■ | 140 | mst | mst_if_edge | mst_if_edge_hst | 43865 | 外部システム連携 |  |  |
|  | ■ | 141 | sys | sys_coop_journal | sys_coop_journal_hst | 43865 | 外部システム連携 |  |  |
|  | ■ | 142 | mst | mst_medicine_group | mst_medicine_group_hst | 43822 | 透析業務支援系 |  |  |
|  | ■ | 143 | mst | mst_add_monitor | mst_add_monitor_hst | 43823 | 透析業務支援系 |  |  |
|  | ■ | 144 | sys | sys_monitor_item | sys_monitor_item_hst | 43823 | 透析業務支援系 |  |  |
|  | ■ | 145 | sys | sys_facility | sys_facility_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 146 | mst | mst_favorite_facility | mst_favorite_facility_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 147 | ord | ord_addition | ord_addition_hst | =IFERROR(VLOOKUP(E149,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 148 | mst | mst_holiday | mst_holiday_hst | =IFERROR(VLOOKUP(E150,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 149 | mst | mst_addition | mst_addition_hst | =IFERROR(VLOOKUP(E151,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 150 | sys | sys_notification | sys_notification_hst | 44544 | 透析業務支援系 |  |  |
|  | ■ | 151 | mst | mst_url_link_register | mst_url_link_register_hst | 43895 | 透析業務支援系 |  |  |
|  | ■ | 152 | mst | mst_mainte_detail | mst_mainte_detail_hst | 44259 | 透析業務支援系 |  |  |
|  | ■ | 153 | mnt | mnt_mainte_main | mnt_mainte_main_hst | =IFERROR(VLOOKUP(E155,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 154 | mst | mst_mainte_layout_group | mst_mainte_layout_group_hst | =IFERROR(VLOOKUP(E156,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 155 | mst | mst_mainte_category | mst_mainte_category_hst | =IFERROR(VLOOKUP(E157,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 156 | mst | mst_mainte_layout | mst_mainte_layout_hst | =IFERROR(VLOOKUP(E158,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 157 | mnt | mnt_water_survey | mnt_water_survey_hst | =IFERROR(VLOOKUP(E159,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 158 | mst | mst_water_survey_point | mst_water_survey_point_hst | =IFERROR(VLOOKUP(E160,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 159 | mst | mst_water_survey_type | mst_water_survey_type_hst | 44307 | 透析業務支援系 |  |  |
|  | ■ | 160 | mnt | mnt_batch_manager | mnt_batch_manager_hst | 44069 | アプリケーション共通 |  |  |
|  | ■ | 161 | sys | sys_notification_list | sys_notification_list_hst | 43924 | アプリケーション共通 |  |  |
|  | ■ | 162 | sys | sys_daily_no | sys_daily_no_hst | 43926 | アプリケーション共通 |  |  |
|  | ■ | 163 | pat | pat_name_identification | pat_name_identification_hst | 43929 | 透析業務支援系 |  |  |
|  | ■ | 164 | mst | mst_facility_calendar_layout | mst_facility_calendar_layout_hst | 43929 | 透析業務支援系 |  |  |
|  | ■ | 165 | mst | mst_mainte_detail_hst | mst_mainte_detail_hst_hst | 43929 | 透析業務支援系 |  |  |
|  | ■ | 166 | mst | mst_mainte_layout_group_hst | mst_mainte_layout_group_hst_hst | 43929 | 透析業務支援系 |  |  |
|  | ■ | 167 | mst | mst_mainte_category_hst | mst_mainte_category_hst_hst | 43929 | 透析業務支援系 |  |  |
|  | ■ | 168 | mst | mst_mainte_layout_hst | mst_mainte_layout_hst_hst | 43929 | 透析業務支援系 |  |  |
|  | ■ | 169 | sys | sys_medicine | sys_medicine_hst | 43934 | アプリケーション共通 |  |  |
|  | ■ | 170 | ord | ord_prescription | ord_prescription_hst | 43935 | 透析業務支援系 |  |  |
|  | ■ | 171 | ord | ord_personal_prescription | ord_personal_prescription_hst | =IFERROR(VLOOKUP(E173,変更履歴!$A$3:$G$1062,7,FALSE),"") | 透析業務支援系 |  |  |
|  | ■ | 172 | sys | sys_generic_medicine | sys_generic_medicine_hst | 43935 | 透析業務支援系 |  |  |
|  | ■ | 173 | mst | mst_take_medicine | mst_take_medicine_hst | 43935 | 透析業務支援系 |  |  |
|  | ■ | 174 | sys | sys_subscription_plan | sys_subscription_plan_hst | 43935 | 透析業務支援系 |  |  |
|  | ■ | 175 | sal | sal_subscription_manage | sal_subscription_manage_hst | 44280 | 透析業務支援系 |  |  |
|  | ■ | 176 | sys | sys_function_advanced | sys_function_advanced_hst | 44236 | 透析業務支援系 |  |  |
|  | ■ | 177 | mst | mst_pat_search_detail | mst_pat_search_detail_hst | 43935 | 透析業務支援系 |  |  |
|  | ■ | 178 | pat | pat_ind_approve_history | pat_ind_approve_history_hst | 44127 | 透析業務支援系 |  |  |
|  | ■ | 179 | sys | sys_release_info | sys_release_info_hst | 43951 | アプリケーション共通 |  |  |
|  | ■ | 180 | sys | sys_signin_manager | sys_signin_manager_hst | 43993 | アプリケーション共通 |  |  |
|  | ■ | 181 | sys | sys_data_list_category | sys_data_list_category_hst | 43990 | 透析業務支援系 |  |  |
|  | ■ | 182 | sys | sys_data_list_detail | sys_data_list_detail_hst | 43990 | 透析業務支援系 |  |  |
|  | ■ | 183 | mst | mst_graph_setting | mst_graph_setting_hst | 44015 | 透析業務支援系 |  |  |
|  | ■ | 184 | mnt | mnt_facility_cancel_manage | mnt_facility_cancel_manage_hst | 44021 | データ削除機能 |  |  |
|  | ■ | 185 | mnt | mnt_find_machine | mnt_find_machine_hst | 44049 | アプリケーション共通 |  |  |
|  | ■ | 186 | mst | mst_self_measure_result | mst_self_measure_result_hst | 44099 | アプリケーション共通 |  |  |
|  | ■ | 187 | mnt | mnt_cardapp_port | mnt_cardapp_port_hst | 44099 | カードアプリポート管理 |  |  |
|  | ■ | 188 | mst | mst_vital_graph | mst_vital_graph_hst | 44147 |  |  |  |
|  | ■ | 189 | mst | mst_machine_record_control | mst_machine_record_control_hst | 44131 |  |  |  |
|  | ■ | 190 | mst | mst_self_measure_result | mst_self_measure_result_hst | 44139 | アプリケーション共通 |  |  |
|  | ■ | 191 | log | log_table_comment |  | 44285 |  |  |  |
|  | ■ | 192 | log | log_json_comment |  | 44151 |  |  |  |
|  | ■ | 193 | log | log_table_comment(db4) |  | 44217 |  |  |  |
|  | ■ | 194 | log | log_json_comment(db4) |  | 44166 |  |  |  |
|  | ■ | 195 | log | log_table_comment(db6) |  | 44217 |  |  |  |
|  | ■ | 196 | log | log_json_comment(db6) |  | 44166 |  |  |  |
|  | ■ | 197 | mst | mst_exam_matome |  | 44176 |  |  |  |
|  | ■ | 198 | sys | sys_report_setting | sys_report_setting_hst | 44343 | 機能帳票設定 |  |  |
|  | ■ | 199 | mst | mst_medicine_support | mst_medicine_support_hst | 44202 |  |  |  |
|  | ■ | 200 | ord | ord_material_save | ord_material_save_hst | 44202 |  |  |  |
|  | ■ | 201 | mnt | mnt_recalc_que | mnt_recalc_que_hst | =IFERROR(VLOOKUP(E203,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  | ■ | 202 | ord | ord_main_restore | ord_main_restore_hst | =IFERROR(VLOOKUP(E204,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  | ■ | 203 | sys | sys_application |  | =IFERROR(VLOOKUP(E205,変更履歴!$A$3:$G$1062,7,FALSE),"") | アプリケーション共通 |  |  |
|  | ■ | 204 | mst | mst_menu_group | mst_menu_group_hst | 45737 | 透析業務支援系 |  |  |
|  | ■ | 205 | mst | mst_prescription_set | mst_prescription_set_hst | 46085 | 透析業務支援系 |  |  |
|  |  | 206 |  |  | =IF(E208<>"",IFERROR(IF(E208=VLOOKUP(E208,$K$3:$K$213,1,FALSE),""),E208&"_hst"),"") | =IFERROR(VLOOKUP(E208,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  |  | 207 |  |  |  | =IFERROR(VLOOKUP(E209,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  |  | 208 |  |  |  | =IFERROR(VLOOKUP(E210,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  |  | 209 |  |  |  | =IFERROR(VLOOKUP(E211,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  |  | 210 |  |  |  | =IFERROR(VLOOKUP(E212,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  |  | 211 |  |  |  | =IFERROR(VLOOKUP(E213,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
|  |  | 212 |  |  |  | =IFERROR(VLOOKUP(E214,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |
