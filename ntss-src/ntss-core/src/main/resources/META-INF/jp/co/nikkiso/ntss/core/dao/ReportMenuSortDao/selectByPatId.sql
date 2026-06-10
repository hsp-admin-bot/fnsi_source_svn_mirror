SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
-- mod  吉 start
--   pat_id,pat_id pat_name
pat_id,hosp_pat_id pat_name
  -- mod  吉 end
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
FROM
  pat_personal_main
WHERE
  is_del = '0'
  AND facility_cd = /*facilityCd*/''
  AND pat_id in /*patId*/(null)
order by
/*%if "asc" != sortValue */
-- mod  吉 start
--     pat_id DESC
    hosp_pat_id DESC
    -- mod  吉 end
/*%else*/
-- mod  吉 start
--     pat_id ASC
    hosp_pat_id ASC
    -- mod  吉 end
/*%end*/
