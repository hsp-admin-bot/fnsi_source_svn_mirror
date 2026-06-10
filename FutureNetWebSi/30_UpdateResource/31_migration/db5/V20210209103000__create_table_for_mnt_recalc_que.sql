-- Drop table

-- DROP TABLE ntss.mnt_recalc_que;

CREATE TABLE ntss.mnt_recalc_que (
	recalc_que_cd bigserial NOT NULL, -- 処理順(登録順）
	status varchar NULL, -- ステータス (2:処理完了、1:処理中、0:未処理、3:スキップ、8:エラー（スキップ）、9:中止)
	facility_cd varchar NULL, -- 施設コード
	reg_date timestamp NULL, -- 依頼日時
	end_date timestamp NULL, -- 完了日時
	"content" jsonb NULL, -- 内容
	detail jsonb NULL, -- 進捗
	reg_id varchar NULL, -- 依頼者id
	up_id varchar NULL, -- 更新者ID
	del_flg varchar NULL DEFAULT '0'::character varying, -- 削除フラグ
	up_date timestamp NULL, -- 更新日時
	disp_flg varchar NULL DEFAULT '1'::character varying, -- 表示フラグ
	journal varchar NULL, -- ログ
	CONSTRAINT unq_mnt_recalc_que_01 PRIMARY KEY (recalc_que_cd)
);
COMMENT ON TABLE ntss.mnt_recalc_que IS '検査再計算依頼キューテーブル';

-- Column comments

COMMENT ON COLUMN ntss.mnt_recalc_que.recalc_que_cd IS '処理順(登録順）';
COMMENT ON COLUMN ntss.mnt_recalc_que.status IS 'ステータス (2:処理完了、1:処理中、0:未処理、3:スキップ、8:エラー（スキップ）、9:中止)';
COMMENT ON COLUMN ntss.mnt_recalc_que.facility_cd IS '施設コード';
COMMENT ON COLUMN ntss.mnt_recalc_que.reg_date IS '依頼日時';
COMMENT ON COLUMN ntss.mnt_recalc_que.end_date IS '完了日時';
COMMENT ON COLUMN ntss.mnt_recalc_que."content" IS '内容';
COMMENT ON COLUMN ntss.mnt_recalc_que.detail IS '進捗';
COMMENT ON COLUMN ntss.mnt_recalc_que.reg_id IS '依頼者id';
COMMENT ON COLUMN ntss.mnt_recalc_que.up_id IS '更新者ID';
COMMENT ON COLUMN ntss.mnt_recalc_que.del_flg IS '削除フラグ';
COMMENT ON COLUMN ntss.mnt_recalc_que.up_date IS '更新日時';
COMMENT ON COLUMN ntss.mnt_recalc_que.disp_flg IS '表示フラグ';
COMMENT ON COLUMN ntss.mnt_recalc_que.journal IS 'ログ';
