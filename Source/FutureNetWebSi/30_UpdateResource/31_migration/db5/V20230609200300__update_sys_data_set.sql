DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2013);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2013,'select
    CAST(mst.dialysis_difficulty_cd AS VARCHAR) as dialdiffcd
    , mst.in_hospital_cd_1 as dialdiffhospitalcd1
    , mst.dialysis_difficulty_name as dialdiffcomment
from
    mst_dialysis_difficulty mst
where
    mst.facility_cd = @facilityCd',2,'[]','1','{"applications": [5]}','{"classes": []}','患者基本情報：@facilityCd使用 {"Mergekey": ["dialdiffcd"]}','2021/07/29 16:18:57','2021/07/29 16:19:00',NULL);
