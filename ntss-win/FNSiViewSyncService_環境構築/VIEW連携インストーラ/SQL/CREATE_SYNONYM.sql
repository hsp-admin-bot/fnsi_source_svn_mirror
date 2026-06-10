-- FNSIユーザがFNSIVIEWスキーマの指定なしでテーブル参照できるようにシノニム付与するSQLを自動作成する
-- 作成されるSQLはSYNONYM.sql
set echo off
set pages 999
set line 32767
set head off
set feed off
SET TRIMSPOOL ON
spool SQL\SYNONYM.sql
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
        , 'spool SYNONYM.log' AS log 
      FROM
        dual
    ) 
    UNION ( 
      SELECT
        1 AS NO
        , 'CREATE OR REPLACE SYNONYM "FNSI"."' || (TABLE_NAME) || '" FOR "FNSIVIEW"."' || (TABLE_NAME) || '";' AS log 
      FROM
        DBA_TABLES 
      WHERE
        OWNER = 'FNSIVIEW'
    ) 
    UNION ( 
      SELECT
        1 AS NO
        , 'CREATE OR REPLACE SYNONYM "FNSI"."' || (VIEW_NAME) || '" FOR "FNSIVIEW"."' || (VIEW_NAME) || '";' AS log 
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
