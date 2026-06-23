delete from ntss.sys_data_set where sql_cd in ('-61', '-87');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-61, e'WITH default_user_no AS (-- デフォルト利用者番号（透析実績用)
    SELECT 0                                                            AS order_no,
           COALESCE(NULLIF(info ->> \'value\', \'\'), info ->> \'default_v\') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE facility_cd = @facilityCd
      AND is_del = \'0\'
	  AND COALESCE(info ->> \'key0\',\'\') = @key0
      AND info ->> \'key1\' = \'FJI_COM_INFO\'
      AND info ->> \'key2\' = \'DIAL_DEFAULT_USER_NO\'
    UNION
    SELECT 1  AS order_no,
           \'\' AS staff_cd
    ORDER BY order_no ASC
    LIMIT 1),
     user_no_setting AS (-- 利用者番号出力設定（透析実績用）
         SELECT 0                                                                                       AS order_no,
                COALESCE(NULLIF(info ->> \'value\', \'\'), COALESCE(NULLIF(info ->> \'default_v\', \'\'), \'0\')) AS setting
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
         WHERE facility_cd = @facilityCd
           AND is_del = \'0\'
		   AND COALESCE(info ->> \'key0\',\'\') = @key0
           AND info ->> \'key1\' = \'FJI_COM_INFO\'
           AND info ->> \'key2\' = \'DIAL_USER_NO_SETTING\'
         UNION
         SELECT 1   AS order_no,
                \'0\' AS setting
         ORDER BY order_no ASC
         LIMIT 1),
     up_user_id_info AS (-- 版確定者
         (SELECT 0                                                                         AS order_no,
                 COALESCE(NULLIF(TO_CHAR(om.up_user_id, \'FM9999999999\'), \'\'), dn.staff_cd) AS staff_cd
          FROM ord_main om,
               default_user_no dn
          WHERE om.ord_no = @ordNo)
         UNION
         (SELECT 2        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     staff_user_info_1 AS (-- 担当医1
         (SELECT row_number() over ()             AS order_no,
                 NULLIF(staff ->> \'staff_cd\', \'\') AS staff_cd
          FROM pat_main pm
                   CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info :: json) staff
          WHERE staff ->> \'is_main\' = \'1\'
            AND pm.pat_id = @patId
          ORDER BY staff ->> \'disp_order\'
          limit 1 offset 0)
         UNION
         (SELECT 3        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     staff_user_info_2 AS (-- 担当医2
         (SELECT row_number() over ()             AS order_no,
                 NULLIF(staff ->> \'staff_cd\', \'\') AS staff_cd
          FROM pat_main pm
                   CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info :: json) staff
          WHERE staff ->> \'is_main\' = \'1\'
            AND pm.pat_id = @patId
          ORDER BY staff ->> \'disp_order\'
          limit 1 offset 1)
         UNION
         (SELECT 3        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     mst_user_authenticator as (--常勤医
         select (case when t0.staff_cd is null then default_user_no.staff_cd else t0.staff_cd end) as staff_cd
         from (select nullif((select (json_array_elements((mst.mst_user_authentication ->> \'data\')::json) ->>
                                      (select (
                                                  case
                                                      when 1 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Mon\'
                                                      when 2 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Tues\'
                                                      when 3 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Wednes\'
                                                      when 4 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Thurs\'
                                                      when 5 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Fri\'
                                                      when 6 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Satur\'
                                                      when 7 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Sun\'
                                                      END) as weeks))::json ->> \'user_id\'
                              from ord_main ord,
                                   mst_kur mst
                              where ord.rst_kur_cd = mst.kur_cd
                                and ord.ord_no = @ordNo), \'\') as staff_cd) as t0,
              default_user_no)
SELECT (SELECT staff_cd FROM default_user_no)                                     as default_user_no,
       COALESCE(NULLIF(MAX(CASE part WHEN \'comm\' THEN staff_cd ELSE \'\' END), \'\')) as staff_cd_comm,
       COALESCE(NULLIF(MAX(CASE part WHEN \'comm\' THEN staff_cd ELSE \'\' END), \'\')) as staff_name_comm,
       COALESCE(NULLIF(MAX(CASE part WHEN \'data\' THEN staff_cd ELSE \'\' END), \'\')) as staff_cd_data,
       COALESCE(NULLIF(MAX(CASE part WHEN \'data\' THEN staff_cd ELSE \'\' END), \'\')) as staff_name_data
FROM (
         -- 0：共通部 版確定者
         (SELECT \'comm\' AS part, staff_cd
          FROM up_user_id_info
          WHERE (SELECT setting FROM user_no_setting) IN (\'0\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 1， 3：共通部 担当医１
         (SELECT \'comm\' AS part, staff_cd
          FROM staff_user_info_1
          WHERE (SELECT setting FROM user_no_setting) IN (\'1\', \'3\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 2， 4：共通部 担当医２
         (SELECT \'comm\' AS part, staff_cd
          FROM staff_user_info_2
          WHERE (SELECT setting FROM user_no_setting) IN (\'2\', \'4\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 5：共通部：常勤医
         (SELECT \'comm\' AS part, staff_cd
          FROM mst_user_authenticator
          WHERE (SELECT setting FROM user_no_setting) IN (\'5\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 0：内容部 版確定者
         (SELECT \'data\' AS part, staff_cd
          FROM up_user_id_info
          WHERE (SELECT setting FROM user_no_setting) IN (\'0\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 1, 3：内容部 担当医１
         (SELECT \'data\' AS part, staff_cd
          FROM staff_user_info_1
          WHERE (SELECT setting FROM user_no_setting) IN (\'1\', \'3\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 2, 4：内容部 担当医２
         (SELECT \'data\' AS part, staff_cd
          FROM staff_user_info_2
          WHERE (SELECT setting FROM user_no_setting) IN (\'2\', \'4\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 5：内容部：常勤医
         (SELECT \'data\' AS part, staff_cd
          FROM mst_user_authenticator
          WHERE (SELECT setting FROM user_no_setting) IN (\'5\')
          LIMIT 1 OFFSET 0)) AS T', 2, '[{}]', '0', '{"applications": [4]}', null, '（実績）「利用者番号」に設定する値の取得', '2022-03-16 08:52:30.730', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-87, e'WITH default_user_no AS (-- デフォルト利用者番号（透析実績用)
    SELECT 0                                                            AS order_no,
           COALESCE(NULLIF(info ->> \'value\', \'\'), info ->> \'default_v\') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE facility_cd = @facilityCd
      AND is_del = \'0\'
      AND COALESCE(info ->> \'key0\',\'\') = @key0
      AND info ->> \'key1\' = \'FJI_COM_INFO\'
      AND info ->> \'key2\' = \'DIAL_DEFAULT_USER_NO\'
    UNION
    SELECT 1  AS order_no,
           \'\' AS staff_cd
    ORDER BY order_no ASC
    LIMIT 1),
     user_no_setting AS (-- 利用者番号出力設定（透析実績用）
         SELECT 0                                                                                       AS order_no,
                COALESCE(NULLIF(info ->> \'value\', \'\'), COALESCE(NULLIF(info ->> \'default_v\', \'\'), \'0\')) AS setting
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
         WHERE facility_cd = @facilityCd
           AND is_del = \'0\'
           AND COALESCE(info ->> \'key0\',\'\') = @key0
           AND info ->> \'key1\' = \'FJI_COM_INFO\'
           AND info ->> \'key2\' = \'DIAL_USER_NO_SETTING\'
         UNION
         SELECT 1   AS order_no,
                \'0\' AS setting
         ORDER BY order_no ASC
         LIMIT 1),
     up_user_id_info AS (-- 版確定者
         (SELECT 0                                                                         AS order_no,
                 COALESCE(NULLIF(TO_CHAR(om.up_user_id, \'FM9999999999\'), \'\'), dn.staff_cd) AS staff_cd
          FROM ord_main om,
               default_user_no dn
          WHERE om.ord_no = @ordNo)
         UNION
         (SELECT 2        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     staff_user_info_1 AS (-- 担当医1
         (SELECT row_number() over ()             AS order_no,
                 NULLIF(staff ->> \'staff_cd\', \'\') AS staff_cd
          FROM pat_main pm
                   CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info :: json) staff
          WHERE staff ->> \'is_main\' = \'1\'
            AND pm.pat_id = @patId
          ORDER BY staff ->> \'disp_order\'
          limit 1 offset 0)
         UNION
         (SELECT 3        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     staff_user_info_2 AS (-- 担当医2
         (SELECT row_number() over ()             AS order_no,
                 NULLIF(staff ->> \'staff_cd\', \'\') AS staff_cd
          FROM pat_main pm
                   CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info :: json) staff
          WHERE staff ->> \'is_main\' = \'1\'
            AND pm.pat_id = @patId
          ORDER BY staff ->> \'disp_order\'
          limit 1 offset 1)
         UNION
         (SELECT 3        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     mst_user_authenticator as (--常勤医
         select (case when t0.staff_cd is null then default_user_no.staff_cd else t0.staff_cd end) as staff_cd
         from (select nullif((select (json_array_elements((mst.mst_user_authentication ->> \'data\')::json) ->>
                                      (select (
                                                  case
                                                      when 1 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Mon\'
                                                      when 2 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Tues\'
                                                      when 3 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Wednes\'
                                                      when 4 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Thurs\'
                                                      when 5 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Fri\'
                                                      when 6 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Satur\'
                                                      when 7 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                                          then \'Sun\'
                                                      END) as weeks))::json ->> \'user_id\'
                              from ord_main ord,
                                   mst_kur mst
                              where ord.rst_kur_cd = mst.kur_cd
                                and ord.ord_no = @ordNo), \'\') as staff_cd) as t0,
              default_user_no)
SELECT (SELECT staff_cd FROM default_user_no)                                     as default_user_no,
       COALESCE(NULLIF(MAX(CASE part WHEN \'comm\' THEN staff_cd ELSE \'\' END), \'\')) as staff_cd_comm,
       COALESCE(NULLIF(MAX(CASE part WHEN \'comm\' THEN staff_cd ELSE \'\' END), \'\')) as staff_name_comm,
       COALESCE(NULLIF(MAX(CASE part WHEN \'data\' THEN staff_cd ELSE \'\' END), \'\')) as staff_cd_data,
       COALESCE(NULLIF(MAX(CASE part WHEN \'data\' THEN staff_cd ELSE \'\' END), \'\')) as staff_name_data
FROM (
         -- 0：共通部 版確定者
         (SELECT \'comm\' AS part, staff_cd
          FROM up_user_id_info
          WHERE (SELECT setting FROM user_no_setting) IN (\'0\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 1， 3：共通部 担当医１
         (SELECT \'comm\' AS part, staff_cd
          FROM staff_user_info_1
          WHERE (SELECT setting FROM user_no_setting) IN (\'1\', \'3\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 2， 4：共通部 担当医２
         (SELECT \'comm\' AS part, staff_cd
          FROM staff_user_info_2
          WHERE (SELECT setting FROM user_no_setting) IN (\'2\', \'4\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 5：共通部：常勤医
         (SELECT \'comm\' AS part, staff_cd
          FROM mst_user_authenticator
          WHERE (SELECT setting FROM user_no_setting) IN (\'5\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 0：内容部 版確定者
         (SELECT \'data\' AS part, staff_cd
          FROM up_user_id_info
          WHERE (SELECT setting FROM user_no_setting) IN (\'0\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 1, 3：内容部 担当医１
         (SELECT \'data\' AS part, staff_cd
          FROM staff_user_info_1
          WHERE (SELECT setting FROM user_no_setting) IN (\'1\', \'3\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 2, 4：内容部 担当医２
         (SELECT \'data\' AS part, staff_cd
          FROM staff_user_info_2
          WHERE (SELECT setting FROM user_no_setting) IN (\'2\', \'4\')
          LIMIT 1 OFFSET 0)
         UNION
         -- 5：内容部：常勤医
         (SELECT \'data\' AS part, staff_cd
          FROM mst_user_authenticator
          WHERE (SELECT setting FROM user_no_setting) IN (\'5\')
          LIMIT 1 OFFSET 0)) AS T', 2, '[{}]', '0', '{"applications": [4]}', null, '富士通）透析レポート：施設内職員ID取得', '2022-08-29 00:43:43.516', CURRENT_TIMESTAMP, null);
