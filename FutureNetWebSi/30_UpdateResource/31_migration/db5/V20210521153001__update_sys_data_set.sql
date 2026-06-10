UPDATE "ntss"."sys_data_set" SET 
"can_repeat" = '1',
"use_application" = '{"applications": [1]}',
"report_class" = '{"classes": [11]}',
"up_date" = now()
WHERE "sql_cd" = 127;