-- add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
SELECT
  *
FROM
  ord_main A
WHERE
    A.facility_cd = /*facilityCd*/''
  AND A.treat_date = /*baseDate*/'20180220'
  AND A.pat_Id IS NOT NULL
  AND A.is_del = '0'
-- add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
