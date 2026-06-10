SELECT
    save_1 AS save1,
    save_2 AS save2,
    save_3 AS save3,
    save_4 AS save4,
    save_5 AS save5,
    save_6 AS save6,
    save_7 AS save7,
    save_8 AS save8,
    save_9 AS save9,
    save_10 AS save10
FROM
    pat_coop_detail
WHERE facility_cd = /* facilityCd */NULL
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
/*%if coopVersion != null */
AND coop_version = /* coopVersion */''
/*%end*/
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
AND pat_id = /* selectedPatId */NULL;
