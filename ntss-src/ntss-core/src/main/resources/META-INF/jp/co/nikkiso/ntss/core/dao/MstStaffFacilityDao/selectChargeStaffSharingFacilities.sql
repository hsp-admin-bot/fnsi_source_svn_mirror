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
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
  -- (SELECT *
  (SELECT facility_cd, department_cd, facility_name, facility_name_kana, prefectures_cd
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
  FROM mst_facility
  WHERE use_function->'func_cds' @> '[{"func_cd":"036"}]') AS M1
  INNER JOIN
    sys_prefectures S1 ON
      S1.pref_cd = M1.prefectures_cd
  LEFT OUTER JOIN
    mst_staff_facility M2 ON
      M2.facility_cd = M1.facility_cd AND
      M2.user_id = /*userId*/1
ORDER BY
  M2.user_id,
  M1.prefectures_cd,
  M1.facility_name_kana
