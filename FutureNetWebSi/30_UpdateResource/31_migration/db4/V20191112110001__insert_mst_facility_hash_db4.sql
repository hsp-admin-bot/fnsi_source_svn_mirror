-- 日機装施設のハッシュ情報の削除
-- 既に登録されている場合はコメントアウトして下さい。
DELETE FROM mst_facility_hash WHERE facility_cd = 'nkknkk';
-- 日機装施設のハッシュ情報の登録
INSERT INTO mst_facility_hash(
    facility_cd,
    hash_value,
    reg_date,
    up_date
)
VALUES(
    'nkknkk',
    '$2a$10$ZNBjrHx1NVLktwVKx5oP9uIRfbNnlO3NwfmlEtyFV77jG6mABx3We',
    now(),
    now()
);
