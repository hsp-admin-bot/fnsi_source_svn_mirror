-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
UPDATE
    pat_insurance
SET is_selected = 0
WHERE pat_id = /*patId*/0
  AND facility_cd = /*facilityCd*/'X'
-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
