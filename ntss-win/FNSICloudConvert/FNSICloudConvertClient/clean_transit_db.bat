@echo off
REM ============================================================
REM  localhost:5433（中転庫）の pg_dump_config.yaml 対象テーブルを全削除
REM  実行前に PostgreSQL クライアントツール (psql) のパスを確認すること
REM ============================================================

set PSQL="C:\Program Files\PostgreSQL\16\bin\psql.exe"
set HOST=localhost
set PORT=5433

echo.
echo ============================================================
echo  WARNING: localhost:%PORT% の対象テーブルを全件削除します
echo ============================================================
echo.
pause

REM ------------------------------------------------------------
REM  ntss_db4
REM ------------------------------------------------------------
echo [1/3] ntss_db4 を削除中...
set PGPASSWORD=nkk4
%PSQL% -h %HOST% -p %PORT% -U nkk4 -d ntss_db4 -c ^
"TRUNCATE ntss.mnt_websocket_certification, ntss.mst_facility_hash, ntss.mst_pat_hash, ntss.mst_user_authentication CASCADE;"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ntss_db4 の削除に失敗しました
    pause
    exit /b 1
)
echo [OK] ntss_db4 完了

REM ------------------------------------------------------------
REM  ntss_db5
REM ------------------------------------------------------------
echo [2/3] ntss_db5 を削除中...
set PGPASSWORD=nkk5
%PSQL% -h %HOST% -p %PORT% -U nkk5 -d ntss_db5 -c ^
"TRUNCATE ntss.bbs_info, ntss.medicine_latest_no, ntss.mni_monitor, ntss.mnt_batch_manager, ntss.mnt_cardapp_port, ntss.mnt_client_connect, ntss.mnt_device_edge_manage, ntss.mnt_device_edge_state, ntss.mnt_facility_cancel_manage, ntss.mnt_find_machine, ntss.mnt_gathering_manage, ntss.mnt_if_edge_client_connect, ntss.mnt_if_edge_healthmon, ntss.mnt_if_edge_manage, ntss.mnt_machine_state, ntss.mnt_mainte_main, ntss.mnt_motion_record, ntss.mnt_notification_message, ntss.mnt_notification_status, ntss.mnt_recalc_que, ntss.mnt_water_survey, ntss.mnt_weight_state, ntss.mst_add_monitor, ntss.mst_addition, ntss.mst_alarm_notification, ntss.mst_bbs_kind, ntss.mst_bed, ntss.mst_checklist, ntss.mst_com_fixed_phrase, ntss.mst_comp_treatment, ntss.mst_complaint, ntss.mst_comsv_setting, ntss.mst_coop_apilink, ntss.mst_coop_distribute, ntss.mst_coop_facility, ntss.mst_coop_filename, ntss.mst_coop_ini, ntss.mst_coop_layout, ntss.mst_coop_layout_detail, ntss.mst_course, ntss.mst_destination_group, ntss.mst_device_edge, ntss.mst_device_set_info_default, ntss.mst_dialysis_difficulty, ntss.mst_dialyzer, ntss.mst_disease, ntss.mst_equipment, ntss.mst_equipment_class, ntss.mst_equipment_set, ntss.mst_exam_item, ntss.mst_exam_matome, ntss.mst_exam_set, ntss.mst_facility, ntss.mst_facility_calendar_layout, ntss.mst_facility_setting, ntss.mst_favorite_facility, ntss.mst_function_report, ntss.mst_graph_setting, ntss.mst_holiday, ntss.mst_if_edge, ntss.mst_if_edge_command, ntss.mst_implant, ntss.mst_infection, ntss.mst_insurance, ntss.mst_job, ntss.mst_kur, ntss.mst_m_notice, ntss.mst_machine, ntss.mst_machine_record, ntss.mst_machine_record_control, ntss.mst_machine_type, ntss.mst_mainte_category, ntss.mst_mainte_category_hst, ntss.mst_mainte_detail, ntss.mst_mainte_detail_hst, ntss.mst_mainte_layout, ntss.mst_mainte_layout_group, ntss.mst_mainte_layout_group_hst, ntss.mst_mainte_layout_hst, ntss.mst_medicate_timing, ntss.mst_medicine, ntss.mst_medicine_class, ntss.mst_medicine_group, ntss.mst_medicine_mix, ntss.mst_medicine_set, ntss.mst_medicine_support, ntss.mst_menu_group, ntss.mst_monitor_graph, ntss.mst_notification_message, ntss.mst_obs_kind, ntss.mst_pat_calendar_layout, ntss.mst_pat_event_category, ntss.mst_pat_event_data_template, ntss.mst_pat_event_sub_category, ntss.mst_pat_list_layout, ntss.mst_pat_memo, ntss.mst_pat_search_detail, ntss.mst_pat_viewer_layout, ntss.mst_personal_tab_define, ntss.mst_printer, ntss.mst_procedure, ntss.mst_rad_set, ntss.mst_relationship, ntss.mst_report, ntss.mst_room_bed_group, ntss.mst_round_type, ntss.mst_selector, ntss.mst_self_measure_result, ntss.mst_severity, ntss.mst_spitz, ntss.mst_staff_facility, ntss.mst_status_map_bed_layout, ntss.mst_taboo_allergy, ntss.mst_take_medicine, ntss.mst_transport, ntss.mst_treatment, ntss.mst_treatment_set, ntss.mst_treatment_status_disp_item, ntss.mst_treatment_status_layout, ntss.mst_trend_graph_monitor_set, ntss.mst_trend_graph_template, ntss.mst_url_link_register, ntss.mst_user, ntss.mst_va, ntss.mst_vital_graph, ntss.mst_ward, ntss.mst_water_survey_point, ntss.mst_water_survey_type, ntss.mst_weight, ntss.mst_weight_print, ntss.mst_weight_scale, ntss.mst_wheel_chair, ntss.ord_checklist, ntss.ord_coop_no, ntss.ord_exception_period, ntss.ord_main, ntss.ord_main_restore, ntss.ord_material_save, ntss.ord_prescription, ntss.ord_schedule, ntss.ord_treat_condition, ntss.ord_weight_scale, ntss.pat_coop_detail, ntss.pat_event, ntss.pat_exam_main, ntss.pat_exam_main_hst, ntss.pat_exam_pattern, ntss.pat_group, ntss.pat_group_detail, ntss.pat_hhd_pattern, ntss.pat_ind_approve, ntss.pat_ind_approve_history, ntss.pat_main, ntss.pat_name_identification, ntss.pat_obs_rec, ntss.pat_rad_main, ntss.pat_rad_main_hst, ntss.pat_rad_pattern, ntss.pat_treatment_pattern, ntss.pat_unique, ntss.sal_subscription_manage, ntss.sys_coop_journal, ntss.sys_coop_no, ntss.sys_daily_no, ntss.sys_data_item, ntss.sys_notification_list CASCADE;"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ntss_db5 の削除に失敗しました
    pause
    exit /b 1
)
echo [OK] ntss_db5 完了

REM ------------------------------------------------------------
REM  ntss_db6
REM ------------------------------------------------------------
echo [3/3] ntss_db6 を削除中...
set PGPASSWORD=nkk6
%PSQL% -h %HOST% -p %PORT% -U nkk6 -d ntss_db6 -c ^
"TRUNCATE ntss.mst_personal_user, ntss.ord_personal_prescription, ntss.pat_insurance, ntss.pat_personal_main CASCADE;"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] ntss_db6 の削除に失敗しました
    pause
    exit /b 1
)
echo [OK] ntss_db6 完了

echo.
echo ============================================================
echo  完了: localhost:%PORT% の全対象テーブルを削除しました
echo ============================================================
echo.
pause
