-- modify by chamaojia 2026-03-19 [12471] ord_main.ind_medi_infoに不正データが登録される --start
SELECT COALESCE(
  (
    SELECT medi_info_no
    FROM medicine_latest_no
    WHERE facility_cd = /*facilityCd*/''
      AND pat_id = /*patId*/0
    FOR UPDATE
  ),
  0
) AS medi_info_no
-- modify by chamaojia 2026-03-19 [12471] ord_main.ind_medi_infoに不正データが登録される --end
