DROP TABLE IF EXISTS pat_ind_approve_history;

CREATE TABLE pat_ind_approve_history (
  ind_approve_history_no bigserial not null primary key,
  ord_no bigint not null,
  approve_kind varchar(1),
  approve_bef_id bigint,
  approve_aft_id bigint,
  user_id bigint,
  sign_type varchar(1),
  reg_date timestamp(3),
  up_date timestamp(3),
  is_disp varchar(1) default '1',
  is_del varchar(1) default '0'
);

-- コメント
COMMENT ON TABLE "pat_ind_approve_history" IS E'指示受け・承認詳細';
COMMENT ON COLUMN "pat_ind_approve_history"."ind_approve_history_no" IS E'指示受け承認履歴番号';
COMMENT ON COLUMN "pat_ind_approve_history"."ord_no" IS E'オーダ番号';
COMMENT ON COLUMN "pat_ind_approve_history"."approve_kind" IS E'指示受け承認区分';
COMMENT ON COLUMN "pat_ind_approve_history"."approve_bef_id" IS E'変更前指示受け承認者';
COMMENT ON COLUMN "pat_ind_approve_history"."approve_aft_id" IS E'変更後指示受け承認者';
COMMENT ON COLUMN "pat_ind_approve_history"."user_id" IS E'操作者';
COMMENT ON COLUMN "pat_ind_approve_history"."sign_type" IS E'登録区分';
COMMENT ON COLUMN "pat_ind_approve_history"."reg_date" IS E'登録日';
COMMENT ON COLUMN "pat_ind_approve_history"."up_date" IS E'更新日';
COMMENT ON COLUMN "pat_ind_approve_history"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "pat_ind_approve_history"."is_del" IS E'削除フラグ';
