--体重計マスターテーブルにスケールベッド設定項目を追加する。
--項目削除
ALTER TABLE mst_weight DROP COLUMN IF EXISTS weight_type ;
ALTER TABLE mst_weight DROP COLUMN IF EXISTS scale_bed_setting ;

--項目追加
ALTER TABLE mst_weight ADD COLUMN weight_type numeric(1,0) DEFAULT 0;
ALTER TABLE mst_weight ADD COLUMN scale_bed_setting jsonb;
--物理名称
comment on column mst_weight.weight_type is '体重計種別';
comment on column mst_weight.scale_bed_setting is 'スケールベッド設定';

