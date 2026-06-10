SELECT
  CASE WHEN M2.user_id is null THEN 0
    ELSE 1
  END AS is_charge,
  M1.facility_cd,
  M1.department_cd,
  M1.prefectures_cd,
  S1.pref_name as prefectures_name,
  M1.facility_name,
  M1.facility_name_kana
FROM
  mst_facility M1
  LEFT OUTER JOIN
    sys_prefectures S1 ON
      S1.pref_cd = M1.prefectures_cd
  LEFT OUTER JOIN
    mst_staff_facility M2 ON
      M2.facility_cd = M1.facility_cd AND
      M2.user_id = /*userId*/1
WHERE
  M1.facility_cd NOT IN
    (SELECT
      facility_cd
    FROM
      mnt_facility_cancel_manage
    WHERE
      proc_status IN ('1', '2', '3', '9')
    AND
      proc_class = '1'
    AND is_disp = '1'
    AND is_del = '0')
ORDER BY
  M2.user_id,
  M1.prefectures_cd,
  M1.facility_name_kana
