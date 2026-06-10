DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-2012);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2012, 'select

    mst.user_id as doctorcd1

    , mst.user_id as doctorcd2

    , mst.user_id as staffcd1

    , mst.user_id as staffcd2

    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS

    doctorname1                                 --担当医1

    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS

    doctorname2                                 --担当医1

    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS

    staffname1                                  --担当医1

    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS

    staffname2                                  --担当医1

from

    mst_personal_user mst

where

    mst.facility_cd = @facilityCd', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：　@facilityCd使用 {"Mergekey": ["doctorcd1","doctorcd2","staffcd1","staffcd2"]}', '2021-07-29 16:18:57', '2021-07-29 16:19:00', NULL);
