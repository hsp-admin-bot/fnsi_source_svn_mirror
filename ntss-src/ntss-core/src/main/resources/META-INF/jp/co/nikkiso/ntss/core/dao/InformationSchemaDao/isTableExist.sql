SELECT EXISTS
(
  SELECT
    table_name
  FROM
    information_schema.tables
  WHERE
    table_name=/*tableName*/'sys_master_define'
)
;
