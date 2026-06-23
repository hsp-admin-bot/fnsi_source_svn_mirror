-- テーブル削除(装置記録マスタ)
DROP TABLE IF EXISTS mst_machine_record_control;
-- テーブル作成(装置記録マスタ)
CREATE TABLE mst_machine_record_control
(
	facility_cd character varying(6) NOT NULL,  --施設コード	
	machine_record_cd character varying(4) NOT NULL,  --装置記録コード							
    machine_record_message character varying(256),  --装置記録メッセージ							
    disp_flg character varying(1),  --表示フラグ						
    reg_date timestamp(3),  --登録日時							
    up_date timestamp(3),  --更新日時							

	CONSTRAINT unq_mst_machine_record_control_01 PRIMARY KEY (facility_cd,machine_record_cd)									

);
-- コメント追加(装置記録マスタ)
COMMENT ON TABLE "mst_machine_record_control" IS E'装置記録マスタControl';
COMMENT ON COLUMN "mst_machine_record_control"."facility_cd" IS '施設コード';
COMMENT ON COLUMN "mst_machine_record_control"."machine_record_cd" IS '装置記録コード';
COMMENT ON COLUMN "mst_machine_record_control"."machine_record_message" IS '装置記録メッセージ';
COMMENT ON COLUMN "mst_machine_record_control"."disp_flg" IS '表示フラグ';
COMMENT ON COLUMN "mst_machine_record_control"."reg_date" IS '登録日時';
COMMENT ON COLUMN "mst_machine_record_control"."up_date" IS '更新日時';
