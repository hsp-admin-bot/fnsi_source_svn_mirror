SELECT EXISTS
(
  SELECT
    column_name
  FROM
    information_schema.columns
  WHERE
    table_name=/*tableName*/'sys_master_define'
    AND
    column_name=/*columnName*/'master_physical_name'
)
;
