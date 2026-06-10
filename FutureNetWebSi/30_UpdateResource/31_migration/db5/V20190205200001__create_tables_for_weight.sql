DROP TABLE IF EXISTS mst_weight;
-- テーブル作成
CREATE TABLE mst_weight
(
    weight_cd bigserial NOT NULL,  --体重計管理コード
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd) ,  --施設コード
    weight_no smallint NOT NULL,  --体重計番号
    weight_name character varying,  --体重計名称
    port_name character varying(10),  --体重計接続ポート
    device_class numeric(1,0),  --体重計機種
    is_auto_send_before character varying(1),  --前体重自動送信
    is_auto_send_after character varying(1),  --後体重自動送信
    wait_auto_send_before smallint,  --前体重自動送信待ち時間
    wait_auto_send_after smallint,  --後体重自動送信待ち時間
    is_default_print_before character varying(1),  --前体重印刷初期状態
    is_default_print_after character varying(1),  --後体重印刷初期状態
    printer_class smallint,  --使用プリンター
    bed_group_cd integer,  --所属透析室
    is_has_card_reader character varying(1),  --カードリーダー有無
    check_content jsonb,  --体重測定チェック項目
    print_setting jsonb,  --印字設定項目
    color_setting jsonb,  --配色設定項目
    audio_setting jsonb,  --音声再生設定項目
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_weight_01 PRIMARY KEY (weight_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_weight" IS E'体重計マスタ';
COMMENT ON COLUMN "mst_weight"."weight_cd" IS E'体重計管理コード';
COMMENT ON COLUMN "mst_weight"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_weight"."weight_no" IS E'体重計番号';
COMMENT ON COLUMN "mst_weight"."weight_name" IS E'体重計名称';
COMMENT ON COLUMN "mst_weight"."port_name" IS E'体重計接続ポート';
COMMENT ON COLUMN "mst_weight"."device_class" IS E'体重計機種';
COMMENT ON COLUMN "mst_weight"."is_auto_send_before" IS E'前体重自動送信';
COMMENT ON COLUMN "mst_weight"."is_auto_send_after" IS E'後体重自動送信';
COMMENT ON COLUMN "mst_weight"."wait_auto_send_before" IS E'前体重自動送信待ち時間';
COMMENT ON COLUMN "mst_weight"."wait_auto_send_after" IS E'後体重自動送信待ち時間';
COMMENT ON COLUMN "mst_weight"."is_default_print_before" IS E'前体重印刷初期状態';
COMMENT ON COLUMN "mst_weight"."is_default_print_after" IS E'後体重印刷初期状態';
COMMENT ON COLUMN "mst_weight"."printer_class" IS E'使用プリンター';
COMMENT ON COLUMN "mst_weight"."bed_group_cd" IS E'所属透析室';
COMMENT ON COLUMN "mst_weight"."is_has_card_reader" IS E'カードリーダー有無';
COMMENT ON COLUMN "mst_weight"."check_content" IS E'体重測定チェック項目';
COMMENT ON COLUMN "mst_weight"."print_setting" IS E'印字設定項目';
COMMENT ON COLUMN "mst_weight"."color_setting" IS E'配色設定項目';
COMMENT ON COLUMN "mst_weight"."audio_setting" IS E'音声再生設定項目';
COMMENT ON COLUMN "mst_weight"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_weight"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_weight"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_weight"."up_date" IS E'更新日時';


-- テーブル削除
DROP TABLE IF EXISTS mst_weight_print;
-- テーブル作成
CREATE TABLE mst_weight_print
(
    content_cd serial NOT NULL,  --項目コード
    content_name character varying(20),  --項目名
    print_class numeric(2,0),  --印刷区分
    print_item_type character varying(10),  --データ種別
    default_data_format character varying(10),  --印刷フォーマット
    default_before_word character varying(50),  --データ前文字列
    default_after_word character varying(50),  --データ後文字列
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_weight_print_01 PRIMARY KEY (content_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_weight_print" IS E'体重計印字項目マスタ';
COMMENT ON COLUMN "mst_weight_print"."content_cd" IS E'項目コード';
COMMENT ON COLUMN "mst_weight_print"."content_name" IS E'項目名';
COMMENT ON COLUMN "mst_weight_print"."print_class" IS E'印刷区分';
COMMENT ON COLUMN "mst_weight_print"."print_item_type" IS E'データ種別';
COMMENT ON COLUMN "mst_weight_print"."default_data_format" IS E'印刷フォーマット';
COMMENT ON COLUMN "mst_weight_print"."default_before_word" IS E'データ前文字列';
COMMENT ON COLUMN "mst_weight_print"."default_after_word" IS E'データ後文字列';
COMMENT ON COLUMN "mst_weight_print"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_weight_print"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_weight_print"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_weight_print"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_weight_scale;
-- テーブル作成
CREATE TABLE mst_weight_scale
(
    weight_scale_cd serial NOT NULL,  --体重測定設定管理コード
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd) ,  --施設コード
    ic_card numeric(1,0),  --ICカード種別
    pat_id_digit smallint,  --患者バーコード有効桁
    default_screen_class numeric(1,0),  --測定初期画面
    exam_period smallint,  --検査結果有効期間
    wheel_chair_period smallint,  --車いす校正有効日数
    tare_unit_class numeric(1,0),  --風袋初期単位
    water_unit_class numeric(1,0),  --除水初期単位
    is_double_check character varying(1),  --２回測定チェック
    double_check_tolerance numeric(6,3),  --２回測定チェック許容値
    is_during_dialysis_view character varying(1),  --透析中条件送信画面表示
    previous_weight_source_class numeric(1,0),  --前回後体重取得元
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_weight_scale_01 PRIMARY KEY (weight_scale_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_weight_scale" IS E'体重測定設定マスタ';
COMMENT ON COLUMN "mst_weight_scale"."weight_scale_cd" IS E'体重測定設定管理コード';
COMMENT ON COLUMN "mst_weight_scale"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_weight_scale"."ic_card" IS E'ICカード種別';
COMMENT ON COLUMN "mst_weight_scale"."pat_id_digit" IS E'患者バーコード有効桁';
COMMENT ON COLUMN "mst_weight_scale"."default_screen_class" IS E'測定初期画面';
COMMENT ON COLUMN "mst_weight_scale"."exam_period" IS E'検査結果有効期間';
COMMENT ON COLUMN "mst_weight_scale"."wheel_chair_period" IS E'車いす校正有効日数';
COMMENT ON COLUMN "mst_weight_scale"."tare_unit_class" IS E'風袋初期単位';
COMMENT ON COLUMN "mst_weight_scale"."water_unit_class" IS E'除水初期単位';
COMMENT ON COLUMN "mst_weight_scale"."is_double_check" IS E'２回測定チェック';
COMMENT ON COLUMN "mst_weight_scale"."double_check_tolerance" IS E'２回測定チェック許容値';
COMMENT ON COLUMN "mst_weight_scale"."is_during_dialysis_view" IS E'透析中条件送信画面表示';
COMMENT ON COLUMN "mst_weight_scale"."previous_weight_source_class" IS E'前回後体重取得元';
COMMENT ON COLUMN "mst_weight_scale"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_weight_scale"."up_date" IS E'更新日時';
-- テーブル削除
DROP TABLE IF EXISTS mst_wheel_chair;
-- テーブル作成
CREATE TABLE mst_wheel_chair
(
    wheel_chair_cd bigserial NOT NULL,  --車いすコード
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd) ,  --施設コード
    fn_wheel_chair_cd character varying(8),  --FNW+で管理する施設内で一意な車いすコード
    wheel_chair_name character varying(256),  --車いす名称
    wheel_chair_weight numeric(6,0),  --重量
    scale_date timestamp(3),  --重量校正日
    scale_user_id bigint,  --重量校正者
    is_parsonal character varying(1) DEFAULT '0',  --個人所有フラグ
    pat_id bigint,  --所有患者ID
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_wheel_chair_01 PRIMARY KEY (wheel_chair_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_wheel_chair" IS E'車いすマスタ';
COMMENT ON COLUMN "mst_wheel_chair"."wheel_chair_cd" IS E'車いすコード';
COMMENT ON COLUMN "mst_wheel_chair"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_wheel_chair"."fn_wheel_chair_cd" IS E'FNW+で管理する施設内で一意な車いすコード';
COMMENT ON COLUMN "mst_wheel_chair"."wheel_chair_name" IS E'車いす名称';
COMMENT ON COLUMN "mst_wheel_chair"."wheel_chair_weight" IS E'重量';
COMMENT ON COLUMN "mst_wheel_chair"."scale_date" IS E'重量校正日';
COMMENT ON COLUMN "mst_wheel_chair"."scale_user_id" IS E'重量校正者';
COMMENT ON COLUMN "mst_wheel_chair"."is_parsonal" IS E'個人所有フラグ';
COMMENT ON COLUMN "mst_wheel_chair"."pat_id" IS E'所有患者ID';
COMMENT ON COLUMN "mst_wheel_chair"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_wheel_chair"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_wheel_chair"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_wheel_chair"."up_date" IS E'更新日時';
-- テーブル削除
DROP TABLE IF EXISTS ord_weight_scale;
-- テーブル作成
CREATE TABLE ord_weight_scale
(
    weight_scale_no bigserial NOT NULL,  --測定管理番号
    ord_no bigint,  --オーダー番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    weight_cd bigint,  --体重計管理コード
    weight_name character varying,  --体重計名称
    machine_no bigint,  --装置番号
    machine_name character varying(40),  --装置名称
    weight_scale_status smallint,  --体重測定状況
    message character varying(256),  --メッセージ
    measure_date timestamp(3),  --測定日時
    kur_cd bigint,  --クール
    kur_name character varying,  --クール名
    bed_cd bigint,  --ベッドコード
    bed_name character varying,  --ベッド名
    pat_id bigint,  --患者ID
    scale_class smallint,  --測定区分
    scale_mode smallint,  --測定モード
    scale_value numeric(5,2),  --測定値
    rst_tare_info jsonb,  --風袋
    rst_off_water_info jsonb,  --除水補正値
    weight_value numeric(6,3),  --体重値
    target_weight_value numeric(6,3),  --目標体重
    off_water_limit numeric(6,3),  --除水制限値
    wheel_chair_cd bigint,  --車いすコード
    wheel_chair_name character varying(256),  --車いす名称
    wheel_chair_weight numeric(6,0),  --車いす重量
    user_id bigint,  --スタッフ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_ord_weight_scale_01 PRIMARY KEY (weight_scale_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "ord_weight_scale" IS E'体重計測定実績';
COMMENT ON COLUMN "ord_weight_scale"."weight_scale_no" IS E'測定管理番号';
COMMENT ON COLUMN "ord_weight_scale"."machine_no" IS E'装置番号';
COMMENT ON COLUMN "ord_weight_scale"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_weight_scale"."weight_cd" IS E'体重計管理コード';
COMMENT ON COLUMN "ord_weight_scale"."weight_name" IS E'体重計名称';
COMMENT ON COLUMN "ord_weight_scale"."machine_name" IS E'装置名称';
COMMENT ON COLUMN "ord_weight_scale"."ord_no" IS E'オーダー番号';
COMMENT ON COLUMN "ord_weight_scale"."weight_scale_status" IS E'体重測定状況';
COMMENT ON COLUMN "ord_weight_scale"."message" IS E'メッセージ';
COMMENT ON COLUMN "ord_weight_scale"."measure_date" IS E'測定日時';
COMMENT ON COLUMN "ord_weight_scale"."kur_cd" IS E'クール';
COMMENT ON COLUMN "ord_weight_scale"."kur_name" IS E'クール名';
COMMENT ON COLUMN "ord_weight_scale"."bed_cd" IS E'ベッドコード';
COMMENT ON COLUMN "ord_weight_scale"."scale_mode" IS E'測定モード';
COMMENT ON COLUMN "ord_weight_scale"."pat_id" IS E'患者ID';
COMMENT ON COLUMN "ord_weight_scale"."rst_tare_info" IS E'風袋';
COMMENT ON COLUMN "ord_weight_scale"."scale_class" IS E'測定区分';
COMMENT ON COLUMN "ord_weight_scale"."scale_value" IS E'測定値';
COMMENT ON COLUMN "ord_weight_scale"."bed_name" IS E'ベッド名';
COMMENT ON COLUMN "ord_weight_scale"."rst_off_water_info" IS E'除水補正値';
COMMENT ON COLUMN "ord_weight_scale"."weight_value" IS E'体重値';
COMMENT ON COLUMN "ord_weight_scale"."target_weight_value" IS E'目標体重';
COMMENT ON COLUMN "ord_weight_scale"."off_water_limit" IS E'除水制限値';
COMMENT ON COLUMN "ord_weight_scale"."wheel_chair_cd" IS E'車いすコード';
COMMENT ON COLUMN "ord_weight_scale"."wheel_chair_name" IS E'車いす名称';
COMMENT ON COLUMN "ord_weight_scale"."wheel_chair_weight" IS E'車いす重量';
COMMENT ON COLUMN "ord_weight_scale"."user_id" IS E'スタッフ';
COMMENT ON COLUMN "ord_weight_scale"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_weight_scale"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mnt_weight_state;
-- テーブル作成
CREATE TABLE mnt_weight_state
(
    weight_cd bigint NOT NULL,  --体重計管理コード
    is_connect character varying(1),  --接続状態
    scale_value numeric(6,3),  --測定値
    barcode_value character varying(20),  --バーコードリーダー取得値
    card_read_value jsonb,  --カード取得値
    card_write_value jsonb,  --カード書き込み内容
    write_result numeric(1,0),  --カード書き込み結果
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mnt_weight_state_01 PRIMARY KEY (weight_cd)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "mnt_weight_state" IS E'体重計状態管理';
COMMENT ON COLUMN "mnt_weight_state"."weight_cd" IS E'体重計管理コード';
COMMENT ON COLUMN "mnt_weight_state"."is_connect" IS E'接続状態';
COMMENT ON COLUMN "mnt_weight_state"."scale_value" IS E'測定値';
COMMENT ON COLUMN "mnt_weight_state"."barcode_value" IS E'バーコードリーダー取得値';
COMMENT ON COLUMN "mnt_weight_state"."card_read_value" IS E'カード取得値';
COMMENT ON COLUMN "mnt_weight_state"."card_write_value" IS E'カード書き込み内容';
COMMENT ON COLUMN "mnt_weight_state"."write_result" IS E'カード書き込み結果';
COMMENT ON COLUMN "mnt_weight_state"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_weight_state"."up_date" IS E'更新日時';
