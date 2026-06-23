ALTER TABLE pat_ind_approve
  DROP COLUMN IF EXISTS is_content_change_since_created,
  ADD COLUMN IF NOT EXISTS is_content_appd_changed VARCHAR(1) DEFAULT '0',
  ADD COLUMN IF NOT EXISTS approve_content jsonb;

-- コメント修正
COMMENT ON TABLE "pat_ind_approve" IS E'指示受け承認情報';
COMMENT ON COLUMN "pat_ind_approve"."ord_no" IS E'オーダ番号';
COMMENT ON COLUMN "pat_ind_approve"."check_user1_cd" IS E'指示受け者1';
COMMENT ON COLUMN "pat_ind_approve"."check_user2_cd" IS E'指示受け者2';
COMMENT ON COLUMN "pat_ind_approve"."approve_user1_cd" IS E'指示承認者1';
COMMENT ON COLUMN "pat_ind_approve"."approve_user2_cd" IS E'指示承認者2';
COMMENT ON COLUMN "pat_ind_approve"."check_user1_time" IS E'指示受け1日時';
COMMENT ON COLUMN "pat_ind_approve"."check_user2_time" IS E'指示受け2日時';
COMMENT ON COLUMN "pat_ind_approve"."approve_user1_time" IS E'指示承認1日時';
COMMENT ON COLUMN "pat_ind_approve"."approve_user2_time" IS E'指示承認2日時';
COMMENT ON COLUMN "pat_ind_approve"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_ind_approve"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_ind_approve"."is_content_changed" IS E'指示受け変更ありフラグ';
COMMENT ON COLUMN "pat_ind_approve"."is_content_appd_changed" IS E'指示承認変更ありフラグ';
COMMENT ON COLUMN "pat_ind_approve"."check_content" IS E'治療単位指示受け時指示内容';
COMMENT ON COLUMN "pat_ind_approve"."approve_content" IS E'治療単位指示承認時指示内容';
COMMENT ON COLUMN "pat_ind_approve"."is_user1_checked" IS E'指示受け1フラグ';
COMMENT ON COLUMN "pat_ind_approve"."is_user2_checked" IS E'指示受け2フラグ';
COMMENT ON COLUMN "pat_ind_approve"."is_user1_approved" IS E'指示承認1フラグ';
COMMENT ON COLUMN "pat_ind_approve"."is_user2_approved" IS E'指示承認2フラグ';
