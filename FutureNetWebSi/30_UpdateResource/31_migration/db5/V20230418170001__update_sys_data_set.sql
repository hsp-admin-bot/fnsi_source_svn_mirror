UPDATE "ntss"."sys_data_set"
SET "sql" = '{"collection": "pat_personal_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_pat_contact_info}', "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = 1;
