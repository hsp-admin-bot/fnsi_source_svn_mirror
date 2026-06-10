-- スケジュール列のデータ追加
UPDATE sys_master_define
SET
  column_info =
  '
    {
      "fields": [
        {
          "type": "number",
          "alias": "code",
          "title": "警報通知コード",
          "physical_name": "alarm_notification_cd"
        },
        {
          "type": "string",
          "alias": "name",
          "title": "警報通知名",
          "validation": {"required": true},
          "physical_name": "alarm_notification_name"
        },
        {
          "type": "modal",
          "title": "詳細"
        },
        {
          "type": "disp",
          "title": "削除",
          "physical_name": "is_disp"
        },
        {
          "type": "del",
          "title": "削除",
          "physical_name": "is_del"
        },
        {
          "type": "string",
          "title": "送信先施設コード",
          "validation": {"required": true},
          "hidden": "true",
          "physical_name": "destination_facility_cd"
        },
        {
          "type": "string",
          "title": "送信先グループコード",
          "validation": {"required": true},
          "hidden": "true",
          "physical_name": "destination_group_cd"
        },
        {
          "type": "json",
          "title": "対象装置記録",
          "hidden": "true",
          "physical_name": "target_machine_record"
        },
        {
          "type": "string",
          "title": "通知フラグ(月)",
          "hidden": "true",
          "physical_name": "is_notice_mon"
        },
        {
          "type": "string",
          "title": "開始時間(月)",
          "hidden": "true",
          "physical_name": "start_time_mon"
        },
        {
          "type": "string",
          "title": "終了時間(月)",
          "hidden": "true",
          "physical_name": "end_time_mon"
        },
        {
          "type": "string",
          "title": "翌日フラグ(月)",
          "hidden": "true",
          "physical_name": "is_next_day_mon"
        },
        {
          "type": "string",
          "title": "通知フラグ(火)",
          "hidden": "true",
          "physical_name": "is_notice_tue"
        },
        {
          "type": "string",
          "title": "開始時間(火)",
          "hidden": "true",
          "physical_name": "start_time_tue"
        },
        {
          "type": "string",
          "title": "終了時間(火)",
          "hidden": "true",
          "physical_name": "end_time_tue"
        },
        {
          "type": "string",
          "title": "翌日フラグ(火)",
          "hidden": "true",
          "physical_name": "is_next_day_tue"
        },
        {
          "type": "string",
          "title": "通知フラグ(水)",
          "hidden": "true",
          "physical_name": "is_notice_wed"
        },
        {
          "type": "string",
          "title": "開始時間(水)",
          "hidden": "true",
          "physical_name": "start_time_wed"
        },
        {
          "type": "string",
          "title": "終了時間(水)",
          "hidden": "true",
          "physical_name": "end_time_wed"
        },
        {
          "type": "string",
          "title": "翌日フラグ(水)",
          "hidden": "true",
          "physical_name": "is_next_day_wed"
        },
        {
          "type": "string",
          "title": "通知フラグ(木)",
          "hidden": "true",
          "physical_name": "is_notice_thu"
        },
        {
          "type": "string",
          "title": "開始時間(木)",
          "hidden": "true",
          "physical_name": "start_time_thu"
        },
        {
          "type": "string",
          "title": "終了時間(木)",
          "hidden": "true",
          "physical_name": "end_time_thu"
        },
        {
          "type": "string",
          "title": "翌日フラグ(木)",
          "hidden": "true",
          "physical_name": "is_next_day_thu"
        },
        {
          "type": "string",
          "title": "通知フラグ(金)",
          "hidden": "true",
          "physical_name": "is_notice_fri"
        },
        {
          "type": "string",
          "title": "開始時間(金)",
          "hidden": "true",
          "physical_name": "start_time_fri"
        },
        {
          "type": "string",
          "title": "終了時間(金)",
          "hidden": "true",
          "physical_name": "end_time_fri"
        },
        {
          "type": "string",
          "title": "翌日フラグ(金)",
          "hidden": "true",
          "physical_name": "is_next_day_fri"
        },
        {
          "type": "string",
          "title": "通知フラグ(土)",
          "hidden": "true",
          "physical_name": "is_notice_sat"
        },
        {
          "type": "string",
          "title": "開始時間(土)",
          "hidden": "true",
          "physical_name": "start_time_sat"
        },
        {
          "type": "string",
          "title": "終了時間(土)",
          "hidden": "true",
          "physical_name": "end_time_sat"
        },
        {
          "type": "string",
          "title": "翌日フラグ(土)",
          "hidden": "true",
          "physical_name": "is_next_day_sat"
        },
        {
          "type": "string",
          "title": "通知フラグ(日)",
          "hidden": "true",
          "physical_name": "is_notice_sun"
        },
        {
          "type": "string",
          "title": "開始時間(日)",
          "hidden": "true",
          "physical_name": "start_time_sun"
        },
        {
          "type": "string",
          "title": "終了時間(日)",
          "hidden": "true",
          "physical_name": "end_time_sun"
        },
        {
          "type": "string",
          "title": "翌日フラグ(日)",
          "hidden": "true",
          "physical_name": "is_next_day_sun"
        }
      ]
    }
  '
WHERE master_physical_name = 'mst_alarm_notification'
;

