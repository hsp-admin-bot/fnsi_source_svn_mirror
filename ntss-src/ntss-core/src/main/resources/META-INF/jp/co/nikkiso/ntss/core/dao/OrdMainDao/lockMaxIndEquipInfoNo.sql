SELECT COALESCE(
  (
    SELECT equip_info_no
    FROM equipment_latest_no
    WHERE facility_cd = /*facilityCd*/''
      AND pat_id = /*patId*/0
    FOR UPDATE
  ),
  0
) AS equip_info_no
