-- NOL NULL 制約の削除
ALTER TABLE ntss.mst_personal_tab_define
ALTER COLUMN facility_cd drop not null;

-- 桁数無制限に変更
ALTER TABLE ntss.mst_personal_tab_define
ALTER COLUMN facility_cd type character varying;
