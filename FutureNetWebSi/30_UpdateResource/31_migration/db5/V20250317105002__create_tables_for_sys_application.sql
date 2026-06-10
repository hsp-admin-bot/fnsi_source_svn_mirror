-- #11618 単体アプリダウンロード画面作成
-- アプリケーションダウンロード
DROP TABLE IF EXISTS sys_application;
-- テーブル作成
CREATE TABLE sys_application
(
    application_name character varying,  --アプリケーション名
    version character varying,  --バージョン
    path character varying,  --パス
    disp_order integer,  --表示順
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0'  --削除フラグ
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "sys_application" IS E'アプリケーションダウンロード';
COMMENT ON COLUMN "sys_application"."application_name" IS E'アプリケーション名';
COMMENT ON COLUMN "sys_application"."version" IS E'バージョン';
COMMENT ON COLUMN "sys_application"."path" IS E'パス';
COMMENT ON COLUMN "sys_application"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_application"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_application"."up_date" IS E'更新日時';
COMMENT ON COLUMN "sys_application"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_application"."is_del" IS E'削除フラグ';

-- 初期データ登録
INSERT INTO sys_application VALUES ('FNWeb⁺Siカードアプリ',15,'\ntss-admin-web\src\main\frontend\public\application\download\NKKAccessCardServiceSetup.msi',1,current_timestamp,current_timestamp);
INSERT INTO sys_application VALUES ('体重計アプリ',8,'\ntss-admin-web\src\main\frontend\public\application\download\NKKWeightSetup.msi',2,current_timestamp,current_timestamp);
INSERT INTO sys_application VALUES ('印刷サーバーアプリ',9,'\ntss-admin-web\src\main\frontend\public\application\download\NKKPrintServerSetup.msi',3,current_timestamp,current_timestamp);
INSERT INTO sys_application VALUES ('帳票レイアウトデザイナーアプリ',7,'\ntss-admin-web\src\main\frontend\public\application\download\LayoutDesignerSetup.msi',4,current_timestamp,current_timestamp);
INSERT INTO sys_application VALUES ('特殊浄化通信アプリ',11,'\ntss-admin-web\src\main\frontend\public\application\download\BloodPurifySetup.msi',5,current_timestamp,current_timestamp);
