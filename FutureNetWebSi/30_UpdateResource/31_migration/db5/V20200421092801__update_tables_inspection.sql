
DROP TABLE IF EXISTS mst_mainte_detail;
CREATE TABLE mst_mainte_detail
(
    mainte_detail_cd bigserial NOT NULL,
    edition_no integer,
    facility_cd character varying(6) NOT NULL,
    mainte_category_cd bigint,
    mainte_content_1 character varying ,
    mainte_content_2 character varying ,
    mainte_content_3 character varying ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_detail_01 PRIMARY KEY (mainte_detail_cd)
);

COMMENT ON TABLE "mst_mainte_detail" IS E'日常・定期点検項目マスタ';
COMMENT ON COLUMN "mst_mainte_detail"."mainte_detail_cd" IS E'点検詳細品目コード';
COMMENT ON COLUMN "mst_mainte_detail"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_detail"."mainte_category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "mst_mainte_detail"."mainte_content_1" IS E'内容１';
COMMENT ON COLUMN "mst_mainte_detail"."mainte_content_2" IS E'内容2';
COMMENT ON COLUMN "mst_mainte_detail"."mainte_content_3" IS E'内容3';
COMMENT ON COLUMN "mst_mainte_detail"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_detail"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_detail"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_detail"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mainte_detail_hst;
CREATE TABLE mst_mainte_detail_hst
(
    mainte_detail_cd bigserial NOT NULL,
    edition_no integer,
    facility_cd character varying(6) NOT NULL,
    mainte_category_cd bigint,
    mainte_content_1 character varying ,
    mainte_content_2 character varying ,
    mainte_content_3 character varying ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_detail_hst_01 PRIMARY KEY (mainte_detail_cd,edition_no)
);

COMMENT ON TABLE "mst_mainte_detail_hst" IS E'日常・定期点検項目履歴マスタ';
COMMENT ON COLUMN "mst_mainte_detail_hst"."mainte_detail_cd" IS E'点検詳細品目コード';
COMMENT ON COLUMN "mst_mainte_detail_hst"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_detail_hst"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_detail_hst"."mainte_category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "mst_mainte_detail_hst"."mainte_content_1" IS E'内容１';
COMMENT ON COLUMN "mst_mainte_detail_hst"."mainte_content_2" IS E'内容2';
COMMENT ON COLUMN "mst_mainte_detail_hst"."mainte_content_3" IS E'内容3';
COMMENT ON COLUMN "mst_mainte_detail_hst"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_detail_hst"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_detail_hst"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_detail_hst"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mainte_category;

CREATE TABLE mst_mainte_category
(
    mainte_category_cd bigserial NOT NULL,
    edition_no integer DEFAULT 1,
    facility_cd character varying(6) NOT NULL,
    category_name character varying(256) ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_category_01 PRIMARY KEY (mainte_category_cd)
);

COMMENT ON TABLE "mst_mainte_category" IS E'定期点検項目グループマスタ';
COMMENT ON COLUMN "mst_mainte_category"."mainte_category_cd" IS E'点検カテゴリコード';
COMMENT ON COLUMN "mst_mainte_category"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_category"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_category"."category_name" IS E'カテゴリー名';
COMMENT ON COLUMN "mst_mainte_category"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_category"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_category"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_category"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mainte_category_hst;

CREATE TABLE mst_mainte_category_hst
(
    mainte_category_cd bigserial NOT NULL,
    edition_no integer,
    facility_cd character varying(6) NOT NULL,
    category_name character varying(256) ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_category_hst_01 PRIMARY KEY (mainte_category_cd, edition_no)
);

COMMENT ON TABLE "mst_mainte_category_hst" IS E'定期点検項目グループ履歴マスタ';
COMMENT ON COLUMN "mst_mainte_category_hst"."mainte_category_cd" IS E'点検カテゴリコード';
COMMENT ON COLUMN "mst_mainte_category_hst"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_category_hst"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_category_hst"."category_name" IS E'カテゴリー名';
COMMENT ON COLUMN "mst_mainte_category_hst"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_category_hst"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_category_hst"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_category_hst"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mainte_layout;

CREATE TABLE mst_mainte_layout
(
    mainte_layout_cd bigserial NOT NULL,
    edition_no integer,
    facility_cd character varying(6) NOT NULL,
    layout_class character varying(1),
    layout_name character varying(265) ,
    type_info jsonb,
    detail_info_1 jsonb ,
    detail_info_2 jsonb ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_layout_01 PRIMARY KEY (mainte_layout_cd)
);

COMMENT ON TABLE "mst_mainte_layout" IS E'日常・定期点検レイアウトマスタ';
COMMENT ON COLUMN "mst_mainte_layout"."mainte_layout_cd" IS E'点検レイアウトコード';
COMMENT ON COLUMN "mst_mainte_layout"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_layout"."layout_class" IS E'レイアウトクラス';
COMMENT ON COLUMN "mst_mainte_layout"."layout_name" IS E'レイアウト名';
COMMENT ON COLUMN "mst_mainte_layout"."type_info" IS E'マシンタイプリスト';
COMMENT ON COLUMN "mst_mainte_layout"."detail_info_1" IS E'詳細検査リスト1';
COMMENT ON COLUMN "mst_mainte_layout"."detail_info_2" IS E'詳細検査リスト2';
COMMENT ON COLUMN "mst_mainte_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_layout"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_layout"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mainte_layout_hst;

CREATE TABLE mst_mainte_layout_hst
(
    mainte_layout_cd bigserial NOT NULL,
    edition_no integer,
    facility_cd character varying(6) NOT NULL,
    layout_class character varying(1),
    layout_name character varying(265) ,
    type_info jsonb,
    detail_info_1 jsonb ,
    detail_info_2 jsonb ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_layout_hst_01 PRIMARY KEY (mainte_layout_cd, edition_no)
);

COMMENT ON TABLE "mst_mainte_layout_hst" IS E'日常・定期点検レイアウト履歴マスタ';
COMMENT ON COLUMN "mst_mainte_layout_hst"."mainte_layout_cd" IS E'点検レイアウトコード';
COMMENT ON COLUMN "mst_mainte_layout_hst"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_layout_hst"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_layout_hst"."layout_class" IS E'レイアウトクラス';
COMMENT ON COLUMN "mst_mainte_layout_hst"."layout_name" IS E'レイアウト名';
COMMENT ON COLUMN "mst_mainte_layout_hst"."type_info" IS E'マシンタイプリスト';
COMMENT ON COLUMN "mst_mainte_layout_hst"."detail_info_1" IS E'詳細検査リスト1';
COMMENT ON COLUMN "mst_mainte_layout_hst"."detail_info_2" IS E'詳細検査リスト2';
COMMENT ON COLUMN "mst_mainte_layout_hst"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_layout_hst"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_layout_hst"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_layout_hst"."reg_date" IS E'登録日時';



DROP TABLE IF EXISTS mst_mainte_layout_group;

CREATE TABLE mst_mainte_layout_group
(
    mainte_layout_group_cd bigserial NOT NULL,
    edition_no integer,
    facility_cd character varying(6) NOT NULL,
    group_name character varying(265) ,
    layout_default bigint NOT NULL,
    layout_list jsonb NOT NULL,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_layout_group_01 PRIMARY KEY (mainte_layout_group_cd)
);

COMMENT ON TABLE "mst_mainte_layout_group" IS E'定期点検機種別レイアウトマスタ';
COMMENT ON COLUMN "mst_mainte_layout_group"."mainte_layout_group_cd" IS E'点検レイアウトグループコード';
COMMENT ON COLUMN "mst_mainte_layout_group"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_layout_group"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_layout_group"."group_name" IS E'点検レイアウトグループ名';
COMMENT ON COLUMN "mst_mainte_layout_group"."layout_default" IS E'デフォルトレイアウト';
COMMENT ON COLUMN "mst_mainte_layout_group"."layout_list" IS E'レイアウトリスト';
COMMENT ON COLUMN "mst_mainte_layout_group"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_layout_group"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_layout_group"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_layout_group"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mainte_layout_group_hst;

CREATE TABLE mst_mainte_layout_group_hst
(
    mainte_layout_group_cd bigserial NOT NULL,
    edition_no integer,
    facility_cd character varying(6) NOT NULL,
    group_name character varying(265) ,
    layout_default bigint NOT NULL,
    layout_list jsonb NOT NULL,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mainte_layout_group_hst_01 PRIMARY KEY (mainte_layout_group_cd, edition_no)
);

COMMENT ON TABLE "mst_mainte_layout_group_hst" IS E'定期点検機種別レイアウト履歴マスタ';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."mainte_layout_group_cd" IS E'点検レイアウトグループコード';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."edition_no" IS E'版数';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."group_name" IS E'点検レイアウトグループ名';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."layout_default" IS E'デフォルトレイアウト';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."layout_list" IS E'レイアウトリスト';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mainte_layout_group_hst"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mnt_mainte_main;

CREATE TABLE mnt_mainte_main
(
    mainte_no bigserial NOT NULL,
    facility_cd character varying(6) NOT NULL,
    mainte_class character varying(1),
    machine_no bigint,
    rec_no int,
    mainte_date date,
    mainte_layout_group_cd bigint,
    mainte_layout_group_edition integer,
    mainte_layout_cd bigint,
    mainte_layout_edition integer,
    mainte_category_cd jsonb,
    checker_id_1 character varying,
    checker_id_2 character varying,
    mainte_ans_1 character varying(1),
    mainte_ans_2 character varying(1),
    mainte_comment_1 character varying,
    mainte_comment_2 character varying,
    detail jsonb,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mainte_main_01 PRIMARY KEY (mainte_no)
);

CREATE UNIQUE INDEX unq_mnt_mainte_main_02
ON mnt_mainte_main(machine_no, mainte_layout_cd, mainte_date)
WHERE is_del = '0';

COMMENT ON TABLE "mnt_mainte_main" IS E'点検結果';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_no" IS E'点検結果コード';
COMMENT ON COLUMN "mnt_mainte_main"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_class" IS E'型式検査';
COMMENT ON COLUMN "mnt_mainte_main"."machine_no" IS E'装置番号';
COMMENT ON COLUMN "mnt_mainte_main"."rec_no" IS E'記録番号';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_date" IS E'点検日';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_layout_group_cd" IS E'点検レイアウトグループコード';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_layout_group_edition" IS E'点検レイアウトグループコード版数';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_layout_cd" IS E'点検レイアウトコード';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_layout_edition" IS E'点検レイアウトコード版数';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_category_cd" IS E'点検カテゴリコード版数';
COMMENT ON COLUMN "mnt_mainte_main"."checker_id_1" IS E'点検実施者';
COMMENT ON COLUMN "mnt_mainte_main"."checker_id_2" IS E'確認者';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_ans_1" IS E'結果入力パターン1';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_ans_2" IS E'結果入力パターン2';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_comment_1" IS E'定期検査記録コメント';
COMMENT ON COLUMN "mnt_mainte_main"."mainte_comment_2" IS E'定期交換部品記録コメント';
COMMENT ON COLUMN "mnt_mainte_main"."detail" IS E'内容';
COMMENT ON COLUMN "mnt_mainte_main"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mnt_mainte_main"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mnt_mainte_main"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mnt_mainte_main"."reg_date" IS E'登録日時';

DROP TRIGGER IF EXISTS trigger_on_mst_mainte_category ON mst_mainte_category;

CREATE or REPLACE FUNCTION trigger_on_mst_mainte_category()
RETURNS TRIGGER LANGUAGE plpgsql
AS $function$
BEGIN
	IF NEW.edition_no = 0 THEN
		NEW.edition_no = 1;
	ELSE
		NEW.edition_no = NEW.edition_no + 1;
	END IF;
	IF NEW.is_disp = '0' THEN
		NEW.is_del = '1';
	END IF;
	INSERT INTO mst_mainte_category_hst
	SELECT NEW.*;
	RETURN NEW;
END; $function$;

CREATE TRIGGER trigger_on_mst_mainte_category
	BEFORE INSERT or UPDATE or DELETE
	ON mst_mainte_category
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_on_mst_mainte_category();



DROP TRIGGER IF EXISTS trigger_on_mst_mainte_detail ON mst_mainte_detail;

CREATE or REPLACE FUNCTION trigger_on_mst_mainte_detail()
RETURNS TRIGGER LANGUAGE plpgsql
AS $function$
BEGIN
	IF NEW.edition_no = 0 THEN
		NEW.edition_no = 1;
	ELSE
		NEW.edition_no = NEW.edition_no + 1;
	END IF;
	IF NEW.is_disp = '0' THEN
		NEW.is_del = '1';
	END IF;
	INSERT INTO mst_mainte_detail_hst
	SELECT NEW.*;
	RETURN NEW;
END; $function$;

CREATE TRIGGER trigger_on_mst_mainte_detail
	BEFORE INSERT or UPDATE or DELETE
	ON mst_mainte_detail
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_on_mst_mainte_detail();





DROP TRIGGER IF EXISTS trigger_on_mst_mainte_layout ON mst_mainte_layout;

CREATE or REPLACE FUNCTION trigger_on_mst_mainte_layout()
RETURNS TRIGGER LANGUAGE plpgsql
AS $function$
BEGIN
	IF NEW.edition_no = 0 THEN
		NEW.edition_no = 1;
	ELSE
		NEW.edition_no = NEW.edition_no + 1;
	END IF;	IF NEW.is_disp = '0' THEN
		NEW.is_del = '1';
	END IF;
	INSERT INTO mst_mainte_layout_hst
	SELECT NEW.*;
	RETURN NEW;
END; $function$;

CREATE TRIGGER trigger_on_mst_mainte_layout
	BEFORE INSERT or UPDATE or DELETE
	ON mst_mainte_layout
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_on_mst_mainte_layout();




DROP TRIGGER IF EXISTS trigger_on_mst_mainte_layout_group ON mst_mainte_layout_group;

CREATE or REPLACE FUNCTION trigger_on_mst_mainte_layout_group()
RETURNS TRIGGER LANGUAGE plpgsql
AS $function$
BEGIN
	IF NEW.edition_no = 0 THEN
		NEW.edition_no = 1;
	ELSE
		NEW.edition_no = NEW.edition_no + 1;
	END IF;
	IF NEW.is_disp = '0' THEN
		NEW.is_del = '1';
	END IF;
	INSERT INTO mst_mainte_layout_group_hst
	SELECT NEW.*;
	RETURN NEW;
END; $function$;

CREATE TRIGGER trigger_on_mst_mainte_layout_group
	BEFORE INSERT or UPDATE or DELETE
	ON mst_mainte_layout_group
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_on_mst_mainte_layout_group();


