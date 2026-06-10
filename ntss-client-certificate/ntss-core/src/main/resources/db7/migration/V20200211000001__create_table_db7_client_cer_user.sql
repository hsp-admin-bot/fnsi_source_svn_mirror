
DROP TABLE IF EXISTS client_cer_user;
CREATE TABLE client_cer_user
(
    id bigserial NOT NULL,
    user_id character varying(40) NOT NULL,
    user_role character varying(40) NOT NULL,
    user_name character varying(40) NOT NULL,
    user_pass character varying(256) NOT NULL,
    is_delete character varying(1) NOT NULL,
    reg_date timestamp without time zone NOT NULL,
    up_date timestamp without time zone NOT NULL,
    department_cd character varying(40) NOT NULL,
    num_login_attempt integer NOT NULL,
    CONSTRAINT cl_user_pkey PRIMARY KEY (id)
)WITH (
    OIDS=FALSE
);
COMMENT ON TABLE "client_cer_user" IS E'よく使う施設マスタ';
COMMENT ON COLUMN "client_cer_user"."user_role" IS E'ユーザー役割';
COMMENT ON COLUMN "client_cer_user"."user_name" IS E'ユーザー名';
COMMENT ON COLUMN "client_cer_user"."is_delete" IS E'削除フラグ';
COMMENT ON COLUMN "client_cer_user"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "client_cer_user"."up_date" IS E'更新日時';
COMMENT ON COLUMN "client_cer_user"."user_id" IS E'ユーザーID';
COMMENT ON COLUMN "client_cer_user"."department_cd" IS E'部門コード';
COMMENT ON COLUMN "client_cer_user"."user_pass" IS E'ユーザーのパスワード';
COMMENT ON COLUMN "client_cer_user"."num_login_attempt" IS E'ログイン数';
COMMENT ON COLUMN "client_cer_user"."id" IS E'ID';
