DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-604901,-610904)
;


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-610904, 'WITH user_info AS(
  (SELECT
    ind_user_id
  FROM
    pat_exam_main
  WHERE
    exam_main_cd = @ordNo
  UNION
  SELECT
    ind_user_id
  FROM
    pat_exam_main_hst
  WHERE
    exam_main_cd = @ordNo)
  limit 1
)
SELECT
  CASE
    WHEN user_settings -> ''authorized_authorities'' @> ''["073"]''::jsonb THEN ''3''
    ELSE ''0''
  END AS acl
FROM
  mst_user
WHERE
  user_id = (SELECT ind_user_id FROM user_info)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_exam_ord_ACL取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604901, 'WITH user_info AS(
  (SELECT
    ord_i.del_date as up_date_switch,
    ord_i.up_ind_user_id
  FROM ord_main_restore as ord_i
  JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
  WHERE ord_i.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord_i.ord_no = journal.ord_no
    AND journal.reg_date >= ord_i.del_date
  ORDER BY ord_i.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord_i.rst_edition_date as up_date_switch,
    ord_i.up_ind_user_id
  FROM ord_main AS ord_i
  WHERE ord_i.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
SELECT
  CASE
    WHEN user_settings -> ''authorized_authorities'' @> ''["053"]''::jsonb THEN ''3''
    ELSE ''0''
  END AS acl
FROM
  mst_user
WHERE
  user_id = (SELECT up_ind_user_id FROM user_info)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_ind_rst_dial_ACL取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);