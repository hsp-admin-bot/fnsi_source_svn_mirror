-- FNSIVIEWユーザのテーブルすべてにFNSIユーザの参照権限を付与するSQLを自動作成する
-- 作成されるSQLはGRANT.sql
set echo off
set pages 999
set line 32767
set head off
set feed off
SET TRIMSPOOL ON
spool SQL\GRANT.sql
SELECT
   LOG 
FROM
  ( 
    ( 
      SELECT
        0 AS NO
        , 'set echo on' AS log 
      FROM
        dual
    ) 
    UNION     ( 
      SELECT
        0 AS NO
        , 'spool GRANT.log' AS log 
      FROM
        dual
    ) 
    UNION ( 
      SELECT
        1 AS NO
        , 'GRANT SELECT on ' || '"FNSIVIEW"."' || (TABLE_NAME) || '" to ' || '"FNSI";' AS log 
      FROM
        DBA_TABLES 
      WHERE
        OWNER = 'FNSIVIEW'
    ) 
    UNION ( 
      SELECT
        1 AS NO
        , 'GRANT SELECT on ' || '"FNSIVIEW"."' || (VIEW_NAME) || '" to ' || '"FNSI";' AS log 
      FROM
        DBA_VIEWS 
      WHERE
        OWNER = 'FNSIVIEW'
    ) 
    UNION (SELECT 2 AS NO, 'spool off' AS log FROM dual)
    UNION (SELECT 3 AS NO, 'exit' AS log FROM dual)
  ) 
ORDER BY
  NO
  , LOG;
spool off
exit
