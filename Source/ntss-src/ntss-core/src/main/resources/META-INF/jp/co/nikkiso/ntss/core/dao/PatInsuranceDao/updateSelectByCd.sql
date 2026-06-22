-- add FNSI-保険選択の変更 関 start
UPDATE
    pat_insurance
SET is_selected = /*isSelected*/0
WHERE insurance_cd = /*insurancdCd*/0
-- add FNSI-保険選択の変更 関 start
