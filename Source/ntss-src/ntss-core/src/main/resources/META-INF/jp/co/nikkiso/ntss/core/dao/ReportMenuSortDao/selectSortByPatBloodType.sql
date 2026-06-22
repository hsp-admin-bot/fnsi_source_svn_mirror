SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
  pat_id,pat_blood_type_abo pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
FROM
  pat_personal_main
WHERE
  is_del = '0'
  AND facility_cd = /*facilityCd*/''
  AND pat_id in /*patId*/(null)
order by
/*%if "asc" != sortValue */
    pat_blood_type_abo DESC
/*%else*/
    pat_blood_type_abo ASC
/*%end*/
