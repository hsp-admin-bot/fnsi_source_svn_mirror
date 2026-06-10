SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
  pat_id,CONCAT(COALESCE(pat_last_name_kana, ''), COALESCE(pat_first_name_kana, '')) pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
FROM
  pat_personal_main
WHERE
  is_del = '0'
  AND facility_cd = /*facilityCd*/''
  AND pat_id in /*patId*/(null)
order by
/*%if "asc" != sortValue */
    CONCAT(COALESCE(pat_last_name_kana, ''), COALESCE(pat_first_name_kana, '')) DESC
/*%else*/
    CONCAT(COALESCE(pat_last_name_kana, ''), COALESCE(pat_first_name_kana, '')) ASC
/*%end*/
