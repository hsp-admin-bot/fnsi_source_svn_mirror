--期間
ALTER TABLE mst_obs_kind ALTER COLUMN post_period SET DEFAULT 0;

--周知先
ALTER TABLE mst_obs_kind ALTER COLUMN post_address_class SET DEFAULT 0;

--FNW+で管理する施設内の一意なコード
ALTER TABLE mst_obs_kind ADD COLUMN fn_kind_id integer;