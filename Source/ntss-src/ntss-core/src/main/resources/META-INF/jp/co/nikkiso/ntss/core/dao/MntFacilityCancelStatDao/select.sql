SELECT
  a.table_catalog AS db_name,
  CASE
    WHEN position('4' in a.table_catalog) !=0 THEN 1
    WHEN position('5' in a.table_catalog) !=0 THEN 2
    WHEN position('6' in a.table_catalog) !=0 THEN 3
    ELSE 0
  END AS db_class,
  a.table_name AS table_name
FROM
  information_schema.columns a
WHERE
  a.column_name ='facility_cd'
AND
  a.table_name NOT IN /* excludedTableList */('')
ORDER BY
  a.table_catalog, a.table_name
;
