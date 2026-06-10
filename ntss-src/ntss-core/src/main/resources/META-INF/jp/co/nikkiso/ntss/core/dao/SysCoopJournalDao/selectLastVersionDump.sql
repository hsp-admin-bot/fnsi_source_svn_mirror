SELECT
    dump
FROM
    sys_coop_journal
WHERE
    facility_cd = /*facilityCd*/'999999'
  AND
      coop_cd = 'rst_dial'
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = /*coopVersion*/''
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND
      direction = 'S'
    /*%if ordNo != null*/
  AND
      ord_no = /*ordNo*/NULL
    /*%end*/
    /*%if patId != null*/
  AND
      pat_id = /*patId*/NULL
    /*%end*/
  AND
      ana_result = '9'
  AND
      ope_cd = '006001'
  AND
      is_del = '0'
ORDER BY
    reg_date DESC
LIMIT 1
