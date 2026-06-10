-- add FNSI-保険選択の変更 関 start
UPDATE
    pat_insurance
SET is_selected = 0
WHERE pat_id = /*patId*/0
-- add FNSI-保険選択の変更 関 start
