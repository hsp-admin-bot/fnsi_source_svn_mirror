DROP TABLE
IF
	EXISTS sys_coop_journal_wait;
CREATE TABLE sys_coop_journal_wait (
	ctl_no bigserial NOT NULL,--管理番号
	facility_cd CHARACTER VARYING ( 6 ) NOT NULL,--施設コード
	coop_cd CHARACTER VARYING ( 20 ) NOT NULL,--電文種別
	coop_cd_index CHARACTER VARYING ( 10 ) NOT NULL DEFAULT '',--付帯情報（電文）
	crud CHARACTER VARYING ( 1 ) NOT NULL,--作成更新区分
	direction CHARACTER VARYING ( 1 ) NOT NULL,--向き（送受信）
	ord_no BIGINT,--（次世代FN)オーダ番号
	coop_ord_no CHARACTER VARYING,--（連携先)オーダ番号
	hosp_pat_id CHARACTER VARYING ( 12 ),--患者番号（連携用）
	pat_id BIGINT,--患者番号（システム）
	accept_no BIGINT,--受付番号
	base_date TIMESTAMP ( 3 ),--基準日
	report_cd BIGINT,--レポートCD
	ana_result CHARACTER VARYING ( 2 ) NOT NULL DEFAULT '0',--変換処理ステータス
	in_ana_date TIMESTAMP ( 3 ),--変換処理開始日時
	out_ana_date TIMESTAMP ( 3 ),--変換処理完了日時
	coop_result CHARACTER VARYING ( 2 ) NOT NULL DEFAULT '0',--配信処理ステータス
	in_reg_date TIMESTAMP ( 3 ),--配信処理開始日時
	out_reg_date TIMESTAMP ( 3 ),--配信処理完了日時
	message CHARACTER VARYING,--メッセージ
	dump_path CHARACTER VARYING,--電文パス
	dump bytea,--電文内容
	is_editable CHARACTER VARYING ( 1 ) NOT NULL DEFAULT '1',--編集可否フラグ
	is_del CHARACTER VARYING ( 1 ) NOT NULL DEFAULT '0',--削除フラグ
	user_id BIGINT,--操作者ID
	reg_date TIMESTAMP ( 3 ),--登録日時
	up_date TIMESTAMP ( 3 )--更新日時
) ;
-- ユーザ設定
ALTER TABLE sys_coop_journal_wait OWNER TO nkk5;


COMMENT ON TABLE "sys_coop_journal_wait" IS E'外部連携用ジャーナル';
COMMENT ON COLUMN "sys_coop_journal_wait"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_coop_journal_wait"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_coop_journal_wait"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "sys_coop_journal_wait"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "sys_coop_journal_wait"."crud" IS E'作成更新区分';
COMMENT ON COLUMN "sys_coop_journal_wait"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "sys_coop_journal_wait"."ord_no" IS E'（次世代FN)オーダ番号';
COMMENT ON COLUMN "sys_coop_journal_wait"."coop_ord_no" IS E'（連携先)オーダ番号';
COMMENT ON COLUMN "sys_coop_journal_wait"."hosp_pat_id" IS E'患者番号（連携用）';
COMMENT ON COLUMN "sys_coop_journal_wait"."pat_id" IS E'患者番号（システム）';
COMMENT ON COLUMN "sys_coop_journal_wait"."accept_no" IS E'受付番号';
COMMENT ON COLUMN "sys_coop_journal_wait"."base_date" IS E'基準日';
COMMENT ON COLUMN "sys_coop_journal_wait"."report_cd" IS E'レポートCD';
COMMENT ON COLUMN "sys_coop_journal_wait"."ana_result" IS E'変換処理ステータス';
COMMENT ON COLUMN "sys_coop_journal_wait"."in_ana_date" IS E'変換処理開始日時';
COMMENT ON COLUMN "sys_coop_journal_wait"."out_ana_date" IS E'変換処理完了日時';
COMMENT ON COLUMN "sys_coop_journal_wait"."coop_result" IS E'配信処理ステータス';
COMMENT ON COLUMN "sys_coop_journal_wait"."in_reg_date" IS E'配信処理開始日時';
COMMENT ON COLUMN "sys_coop_journal_wait"."out_reg_date" IS E'配信処理完了日時';
COMMENT ON COLUMN "sys_coop_journal_wait"."message" IS E'メッセージ';
COMMENT ON COLUMN "sys_coop_journal_wait"."dump_path" IS E'電文パス';
COMMENT ON COLUMN "sys_coop_journal_wait"."dump" IS E'電文内容';
COMMENT ON COLUMN "sys_coop_journal_wait"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "sys_coop_journal_wait"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_coop_journal_wait"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "sys_coop_journal_wait"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_coop_journal_wait"."up_date" IS E'更新日時';
