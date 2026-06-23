-- タイプを変更
ALTER TABLE ord_prescription ALTER COLUMN issue_date TYPE text;
ALTER TABLE ord_prescription ALTER COLUMN expiration_date TYPE text;
-- データを変換する
UPDATE ord_prescription SET issue_date = replace(substring(issue_date, 1, 10), '-', '')
WHERE issue_date IS NOT NULL;

UPDATE ord_prescription SET expiration_date = replace(substring(expiration_date, 1, 10), '-', '')
WHERE expiration_date IS NOT NULL;
-- タイプをもう一度変更
ALTER TABLE ord_prescription ALTER COLUMN issue_date TYPE character varying(8);
ALTER TABLE ord_prescription ALTER COLUMN expiration_date TYPE character varying(8);