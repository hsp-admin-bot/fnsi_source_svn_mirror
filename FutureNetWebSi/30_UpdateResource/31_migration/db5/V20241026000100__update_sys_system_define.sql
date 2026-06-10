UPDATE sys_system_define
SET "value" = jsonb_set("value", '{backup_path_template_cancel}','"/efs/delete-facility/%FACILITY_CD%/%DATE%/%DB_NAME%_%TABLE_NAME%.csv"'  )
WHERE ctl_no = 29;