UPDATE "sys_data_set" SET "memo" = '(受信用)' || "memo" WHERE "sql_cd" >= 1100 and "sql_cd" < 5400 and "memo" not like '(受信用)%';
