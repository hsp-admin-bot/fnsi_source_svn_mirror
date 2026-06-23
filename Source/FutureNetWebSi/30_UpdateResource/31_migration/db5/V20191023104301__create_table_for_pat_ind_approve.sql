-- ----------------------------
-- Table structure for pat_ind_approve
-- ----------------------------
DROP TABLE IF EXISTS pat_ind_approve;
CREATE TABLE pat_ind_approve (
  "ord_no" bigint NOT NULL,
  "check_user1_cd" bigint,
  "check_user2_cd" bigint,
  "approve_user1_cd" bigint,
  "approve_user2_cd" bigint,
  "check_user1_time" timestamp(3),
  "check_user2_time" timestamp(3),
  "approve_user1_time" timestamp(3),
  "approve_user2_time" timestamp(3),
  "reg_date" timestamp(3),
  "up_date" timestamp(3),
  "is_content_changed" varchar(1) DEFAULT '0',
  "is_content_change_since_created" varchar(1) DEFAULT '0',
  "check_content" jsonb,
  "is_user1_checked" varchar(1) DEFAULT '0',
  "is_user2_checked" varchar(1) DEFAULT '0',
  "is_user1_approved" varchar(1) DEFAULT '0',
  "is_user2_approved" varchar(1) DEFAULT '0',
  CONSTRAINT unq_pat_ind_approve_01 PRIMARY KEY (ord_no)
)
WITH (OIDS=FALSE)

;
COMMENT ON COLUMN "pat_ind_approve"."ord_no" IS 'ord_mainのオーダ番号';
COMMENT ON COLUMN "pat_ind_approve"."check_user1_cd" IS 'チェック者１のID';
COMMENT ON COLUMN "pat_ind_approve"."check_user2_cd" IS 'チェック者２のID';
COMMENT ON COLUMN "pat_ind_approve"."approve_user1_cd" IS '承認者１のID';
COMMENT ON COLUMN "pat_ind_approve"."approve_user2_cd" IS '承認者２のID';
COMMENT ON COLUMN "pat_ind_approve"."check_user1_time" IS 'チェック者１がチェックした日時';
COMMENT ON COLUMN "pat_ind_approve"."check_user2_time" IS 'チェック者２がチェックした日時';
COMMENT ON COLUMN "pat_ind_approve"."approve_user1_time" IS '承認者１が承認した日時';
COMMENT ON COLUMN "pat_ind_approve"."approve_user2_time" IS '承認者２が承認した日時';
COMMENT ON COLUMN "pat_ind_approve"."reg_date" IS '登録日';
COMMENT ON COLUMN "pat_ind_approve"."up_date" IS '更新日';
COMMENT ON COLUMN "pat_ind_approve"."is_content_changed" IS '指示受け後の変更があるかの判断';
COMMENT ON COLUMN "pat_ind_approve"."check_content" IS 'チェック者１がチェックした時点の内容';
COMMENT ON COLUMN "pat_ind_approve"."is_user1_checked" IS 'チェック者１のチェック状態';
COMMENT ON COLUMN "pat_ind_approve"."is_user2_checked" IS 'チェック者２のチェック状態';
COMMENT ON COLUMN "pat_ind_approve"."is_user1_approved" IS '承認者１の承認状態';
COMMENT ON COLUMN "pat_ind_approve"."is_user2_approved" IS '承認者２の承認状態';

-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------
