-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
UPDATE
    pat_insurance
SET is_selected = /*isSelected*/0
WHERE insurance_cd = /*insurancdCd*/0
  AND facility_cd = /*facilityCd*/'X'
-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
