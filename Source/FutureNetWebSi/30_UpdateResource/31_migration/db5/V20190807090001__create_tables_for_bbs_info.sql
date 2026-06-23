-- テーブル削除(掲示板登録情報)
DROP TABLE IF EXISTS bbs_info;
-- テーブル作成(掲示板登録情報)
CREATE TABLE bbs_info
(
    bbs_ctl_no bigserial NOT NULL,  --掲示板管理番号
    fn_seq_id bigint,  --FNW+で管理する施設内の一意なシーケンスID
    facility_cd character varying(6),  --施設コード
    pat_info jsonb,  --対象患者
    staff_info jsonb,  --対象スタッフ
    func_cd character varying(3),  --機能コード
    kind_no bigint,  --種別番号
    content character varying,  --内容
    file_info jsonb,  --ファイル情報
    notice_start_date timestamp(3),  --掲載開始日時
    notice_end_date timestamp(3),  --掲載終了日時
    reg_staff_id bigint,  --起票者ID
    reg_staff_name character varying,  --起票者名
    upd_staff_id bigint,  --最終更新者ID
    upd_staff_name character varying,  --最終更新者名
    transition_router_path character varying,  --遷移先機能パス
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_bbs_info_01 PRIMARY KEY (bbs_ctl_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(掲示板登録情報)
COMMENT ON TABLE "bbs_info" IS E'掲示板登録情報';
COMMENT ON COLUMN "bbs_info"."bbs_ctl_no" IS E'掲示板管理番号';
COMMENT ON COLUMN "bbs_info"."fn_seq_id" IS E'FNW+で管理する施設内の一意なシーケンスID';
COMMENT ON COLUMN "bbs_info"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "bbs_info"."pat_info" IS E'対象患者';
COMMENT ON COLUMN "bbs_info"."staff_info" IS E'対象スタッフ';
COMMENT ON COLUMN "bbs_info"."func_cd" IS E'機能コード';
COMMENT ON COLUMN "bbs_info"."kind_no" IS E'種別番号';
COMMENT ON COLUMN "bbs_info"."content" IS E'内容';
COMMENT ON COLUMN "bbs_info"."file_info" IS E'ファイル情報';
COMMENT ON COLUMN "bbs_info"."notice_start_date" IS E'掲載開始日時';
COMMENT ON COLUMN "bbs_info"."notice_end_date" IS E'掲載終了日時';
COMMENT ON COLUMN "bbs_info"."reg_staff_id" IS E'起票者ID';
COMMENT ON COLUMN "bbs_info"."reg_staff_name" IS E'起票者名';
COMMENT ON COLUMN "bbs_info"."upd_staff_id" IS E'最終更新者ID';
COMMENT ON COLUMN "bbs_info"."upd_staff_name" IS E'最終更新者名';
COMMENT ON COLUMN "bbs_info"."transition_router_path" IS E'遷移先機能パス';
COMMENT ON COLUMN "bbs_info"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "bbs_info"."up_date" IS E'更新日時';
