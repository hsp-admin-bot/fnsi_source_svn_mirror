-- テーブル削除（利用者マスタ）
DROP TABLE IF EXISTS mst_user CASCADE;
-- テーブル作成（利用者マスタ）
CREATE TABLE mst_user
(
    user_id bigint NOT NULL,  --利用者ID（内部用ID）
    user_settings jsonb,  --ユーザー設定
    is_provisional numeric(1,0),  --仮登録フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_user_01 PRIMARY KEY (user_id)
);
-- コメント追加（利用者マスタ）
COMMENT ON TABLE "mst_user" IS E'利用者マスタ';
COMMENT ON COLUMN "mst_user"."user_id" IS E'利用者ID（内部用ID）';
COMMENT ON COLUMN "mst_user"."user_settings" IS E'ユーザー設定';
COMMENT ON COLUMN "mst_user"."is_provisional" IS E'仮登録フラグ';
COMMENT ON COLUMN "mst_user"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_user"."up_date" IS E'更新日時';

-- テーブル削除（装置モニタデータ）
DROP TABLE IF EXISTS mni_monitor;
-- テーブル作成（装置モニタデータ）
CREATE TABLE mni_monitor
(
    bio_moni_ctl_no bigserial NOT NULL,  --生体モニタリング管理番号
    facility_cd character varying(6),  --施設コード
    machine_type_cd character varying(3),  --型式コード
    machine_serial character varying(8),  --製造番号
    ord_no bigint,  --システムで管理する一意なオーダ番号
    pat_id bigint,  --システムで管理する一意な患者ID
    data_type smallint,  --データ種別
    monitor_data jsonb,  --モニタデータ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    occur_date timestamp(3),  --発生日時
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mni_monitor_01 PRIMARY KEY (bio_moni_ctl_no)
);
-- コメント追加（装置モニタデータ）
COMMENT ON TABLE "mni_monitor" IS E'装置モニタデータ';
COMMENT ON COLUMN "mni_monitor"."bio_moni_ctl_no" IS E'生体モニタリング管理番号';
COMMENT ON COLUMN "mni_monitor"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mni_monitor"."machine_type_cd" IS E'型式コード';
COMMENT ON COLUMN "mni_monitor"."machine_serial" IS E'製造番号';
COMMENT ON COLUMN "mni_monitor"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "mni_monitor"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "mni_monitor"."data_type" IS E'データ種別';
COMMENT ON COLUMN "mni_monitor"."monitor_data" IS E'モニタデータ';
COMMENT ON COLUMN "mni_monitor"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mni_monitor"."occur_date" IS E'発生日時';
COMMENT ON COLUMN "mni_monitor"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mni_monitor"."up_date" IS E'更新日時';

-- テーブル削除（WebSocketクライアント接続状態）
DROP TABLE IF EXISTS mnt_client_connect;
-- テーブル作成（WebSocketクライアント接続状態）
CREATE TABLE mnt_client_connect
(
    ip_address inet NOT NULL,  --通信サービス稼働IPアドレス
    facility_cd character varying(6) NOT NULL,  --施設コード
    server_type smallint,  --サーバ種別
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_client_connect_01 PRIMARY KEY (ip_address,facility_cd)
);
-- コメント追加（WebSocketクライアント接続状態）
COMMENT ON TABLE "mnt_client_connect" IS E'WebSocketクライアント接続状態';
COMMENT ON COLUMN "mnt_client_connect"."ip_address" IS E'通信サービス稼働IPアドレス';
COMMENT ON COLUMN "mnt_client_connect"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_client_connect"."server_type" IS E'サーバ種別';
COMMENT ON COLUMN "mnt_client_connect"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_client_connect"."up_date" IS E'更新日時';

-- テーブル削除（デバイスエッジ状態管理）
DROP TABLE IF EXISTS mnt_device_edge_state;
-- テーブル作成（デバイスエッジ状態管理）
CREATE TABLE mnt_device_edge_state
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    device_edge_no numeric(2,0) NOT NULL,  --デバイスエッジ番号
    alive_moni_status character varying(2),  --死活監視ステータス
    version_information jsonb,  --バージョン情報
    last_moni_time timestamp(3),  --最終確認日時
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_device_edge_state_01 PRIMARY KEY (facility_cd,device_edge_no)
);
-- コメント追加（デバイスエッジ状態管理）
COMMENT ON TABLE "mnt_device_edge_state" IS E'デバイスエッジ状態管理';
COMMENT ON COLUMN "mnt_device_edge_state"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_device_edge_state"."device_edge_no" IS E'デバイスエッジ番号';
COMMENT ON COLUMN "mnt_device_edge_state"."alive_moni_status" IS E'死活監視ステータス';
COMMENT ON COLUMN "mnt_device_edge_state"."version_information" IS E'バージョン情報';
COMMENT ON COLUMN "mnt_device_edge_state"."last_moni_time" IS E'最終確認日時';
COMMENT ON COLUMN "mnt_device_edge_state"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_device_edge_state"."up_date" IS E'更新日時';

-- テーブル削除（データ収集管理）
DROP TABLE IF EXISTS mnt_gathering_manage;
-- テーブル作成（データ収集管理）
CREATE TABLE mnt_gathering_manage
(
    gathering_manage_no bigserial NOT NULL,  --データ収集管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    gathering_status numeric(1,0) NOT NULL,  --データ収集ステータス
    gathering_info jsonb,  --データ収集情報
    ope_info numeric(1,0),  --操作情報
    parent_manage_no bigint,  --親管理番号
    user_id bigint,  --利用者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_gathering_manage_01 PRIMARY KEY (gathering_manage_no)
);
-- コメント追加（データ収集管理）
COMMENT ON TABLE "mnt_gathering_manage" IS E'データ収集管理';
COMMENT ON COLUMN "mnt_gathering_manage"."gathering_manage_no" IS E'データ収集管理番号';
COMMENT ON COLUMN "mnt_gathering_manage"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_gathering_manage"."gathering_status" IS E'データ収集ステータス';
COMMENT ON COLUMN "mnt_gathering_manage"."gathering_info" IS E'データ収集情報';
COMMENT ON COLUMN "mnt_gathering_manage"."ope_info" IS E'操作情報';
COMMENT ON COLUMN "mnt_gathering_manage"."parent_manage_no" IS E'親管理番号';
COMMENT ON COLUMN "mnt_gathering_manage"."user_id" IS E'利用者ID';
COMMENT ON COLUMN "mnt_gathering_manage"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_gathering_manage"."up_date" IS E'更新日時';

-- テーブル削除（装置状態管理）
DROP TABLE IF EXISTS mnt_machine_state;
-- テーブル作成（装置状態管理）
CREATE TABLE mnt_machine_state
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    machine_type_cd character varying(3) NOT NULL,  --型式コード
    machine_serial character varying(8) NOT NULL,  --製造番号
    model character varying(3),  --機種
    machine_name character varying(40),  --装置名
    bed_cd bigint,  --ベッドコード
    bed_name character varying,  --ベッド名
    process_state character varying(2),  --工程状態
    m_notice_cnt integer,  --緊急発報件数
    preventive_mainte_cnt integer,  --予防保守件数
    is_preventive_mainte integer,  --通信不良有無
    use_time jsonb,  --部品運転時間
    machine_status numeric(3,0),  --装置ステータス
    alarm_moni character varying,  --警報監視状態
    is_offline character varying(1) DEFAULT '0',  --オフラインフラグ
    ord_no bigint,  --システムで管理する一意なオーダ番号
    next_ord_no bigint,  --次回透析オーダ番号
    pat_id bigint,  --システムで管理する一意な患者ID
    next_patid bigint,  --次患者ID
    next_kur_cd bigint,  --次患者クールCD
    start_plan_date timestamp(3),  --透析開始予定日時
    end_plan_date timestamp(3),  --透析終了予定日時
    weigh_before_date timestamp(3),  --前体重測定日時
    cond_send_date timestamp(3),  --条件送信日時
    cond_set_date timestamp(3),  --条件確認日時
    start_date timestamp(3),  --透析開始日時
    end_date timestamp(3),  --透析終了日時
    weigh_after_date timestamp(3),  --後体重測定日時
    alarm_list jsonb,  --警報、注意発生中リスト
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_machine_state_01 PRIMARY KEY (facility_cd,machine_type_cd,machine_serial)
);
-- コメント追加（装置状態管理）
COMMENT ON TABLE "mnt_machine_state" IS E'装置状態管理';
COMMENT ON COLUMN "mnt_machine_state"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_machine_state"."machine_type_cd" IS E'型式コード';
COMMENT ON COLUMN "mnt_machine_state"."machine_serial" IS E'製造番号';
COMMENT ON COLUMN "mnt_machine_state"."model" IS E'機種';
COMMENT ON COLUMN "mnt_machine_state"."machine_name" IS E'装置名';
COMMENT ON COLUMN "mnt_machine_state"."bed_cd" IS E'ベッドコード';
COMMENT ON COLUMN "mnt_machine_state"."bed_name" IS E'ベッド名';
COMMENT ON COLUMN "mnt_machine_state"."process_state" IS E'工程状態';
COMMENT ON COLUMN "mnt_machine_state"."m_notice_cnt" IS E'緊急発報件数';
COMMENT ON COLUMN "mnt_machine_state"."preventive_mainte_cnt" IS E'予防保守件数';
COMMENT ON COLUMN "mnt_machine_state"."is_preventive_mainte" IS E'通信不良有無';
COMMENT ON COLUMN "mnt_machine_state"."use_time" IS E'部品運転時間';
COMMENT ON COLUMN "mnt_machine_state"."machine_status" IS E'装置ステータス';
COMMENT ON COLUMN "mnt_machine_state"."alarm_moni" IS E'警報監視状態';
COMMENT ON COLUMN "mnt_machine_state"."is_offline" IS E'オフラインフラグ';
COMMENT ON COLUMN "mnt_machine_state"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "mnt_machine_state"."next_ord_no" IS E'次回透析オーダ番号';
COMMENT ON COLUMN "mnt_machine_state"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "mnt_machine_state"."next_patid" IS E'次患者ID';
COMMENT ON COLUMN "mnt_machine_state"."next_kur_cd" IS E'次患者クールCD';
COMMENT ON COLUMN "mnt_machine_state"."start_plan_date" IS E'透析開始予定日時';
COMMENT ON COLUMN "mnt_machine_state"."end_plan_date" IS E'透析終了予定日時';
COMMENT ON COLUMN "mnt_machine_state"."weigh_before_date" IS E'前体重測定日時';
COMMENT ON COLUMN "mnt_machine_state"."cond_send_date" IS E'条件送信日時';
COMMENT ON COLUMN "mnt_machine_state"."cond_set_date" IS E'条件確認日時';
COMMENT ON COLUMN "mnt_machine_state"."start_date" IS E'透析開始日時';
COMMENT ON COLUMN "mnt_machine_state"."end_date" IS E'透析終了日時';
COMMENT ON COLUMN "mnt_machine_state"."weigh_after_date" IS E'後体重測定日時';
COMMENT ON COLUMN "mnt_machine_state"."alarm_list" IS E'警報、注意発生中リスト';
COMMENT ON COLUMN "mnt_machine_state"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_machine_state"."up_date" IS E'更新日時';

-- テーブル削除（装置動作記録）
DROP TABLE IF EXISTS mnt_motion_record;
-- テーブル作成（装置動作記録）
CREATE TABLE mnt_motion_record
(
    motion_record_no bigserial NOT NULL,  --装置動作記録番号
    event_reg_date timestamp(3),  --イベント発生日時
    m_notice_status numeric(1,0),  --緊急発報ステータス
    facility_cd character varying(6),  --施設コード
    device_edge_no numeric(2,0),  --デバイスエッジ番号
    machine_type_cd character varying(3),  --型式コード
    machine_serial character varying(8),  --製造番号
    com_format_cd character varying(1),  --通信フォーマット
    data_type numeric(1,0) NOT NULL,  --データ種別
    test_type numeric(1,0),  --自己診断種別
    gathering_manage_no bigint,  --データ収集管理番号
    email_send_date timestamp(3),  --メール送信日時
    email_text character varying(4000),  --メール本文
    machine_record_cd character varying(4),  --装置記録コード
    machine_record_message character varying(256),  --装置記録メッセージ
    contents jsonb,  --内容
    machine_record_aux_data character varying(256),  --装置記録補助データ
    email_address character varying(4000),  --メールアドレス
    email_name character varying(4000),  --宛先名称
    remarks character varying(4000),  --備考
    is_correction character varying(1),  --対処
    user_id bigint REFERENCES mst_user(user_id) ,  --対処者
    ord_no bigint,  --システムで管理する一意なオーダ番号
    log_type smallint,  --装置記録区分
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_motion_record_01 PRIMARY KEY (motion_record_no)
);
-- コメント追加（装置動作記録）
COMMENT ON TABLE "mnt_motion_record" IS E'装置動作記録';
COMMENT ON COLUMN "mnt_motion_record"."motion_record_no" IS E'装置動作記録番号';
COMMENT ON COLUMN "mnt_motion_record"."event_reg_date" IS E'イベント発生日時';
COMMENT ON COLUMN "mnt_motion_record"."m_notice_status" IS E'緊急発報ステータス';
COMMENT ON COLUMN "mnt_motion_record"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_motion_record"."device_edge_no" IS E'デバイスエッジ番号';
COMMENT ON COLUMN "mnt_motion_record"."machine_type_cd" IS E'型式コード';
COMMENT ON COLUMN "mnt_motion_record"."machine_serial" IS E'製造番号';
COMMENT ON COLUMN "mnt_motion_record"."com_format_cd" IS E'通信フォーマット';
COMMENT ON COLUMN "mnt_motion_record"."data_type" IS E'データ種別';
COMMENT ON COLUMN "mnt_motion_record"."test_type" IS E'自己診断種別';
COMMENT ON COLUMN "mnt_motion_record"."gathering_manage_no" IS E'データ収集管理番号';
COMMENT ON COLUMN "mnt_motion_record"."email_send_date" IS E'メール送信日時';
COMMENT ON COLUMN "mnt_motion_record"."email_text" IS E'メール本文';
COMMENT ON COLUMN "mnt_motion_record"."machine_record_cd" IS E'装置記録コード';
COMMENT ON COLUMN "mnt_motion_record"."machine_record_message" IS E'装置記録メッセージ';
COMMENT ON COLUMN "mnt_motion_record"."contents" IS E'内容';
COMMENT ON COLUMN "mnt_motion_record"."machine_record_aux_data" IS E'装置記録補助データ';
COMMENT ON COLUMN "mnt_motion_record"."email_address" IS E'メールアドレス';
COMMENT ON COLUMN "mnt_motion_record"."email_name" IS E'宛先名称';
COMMENT ON COLUMN "mnt_motion_record"."remarks" IS E'備考';
COMMENT ON COLUMN "mnt_motion_record"."is_correction" IS E'対処';
COMMENT ON COLUMN "mnt_motion_record"."user_id" IS E'対処者';
COMMENT ON COLUMN "mnt_motion_record"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "mnt_motion_record"."log_type" IS E'装置記録区分';
COMMENT ON COLUMN "mnt_motion_record"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_motion_record"."up_date" IS E'更新日時';

-- テーブル削除（デバイスエッジマスタ）
DROP TABLE IF EXISTS mst_device_edge;
-- テーブル作成（デバイスエッジマスタ）
CREATE TABLE mst_device_edge
(
    serial_no character varying(20) NOT NULL,  --製造番号
    facility_cd character varying(6),  --施設コード
    device_edge_no numeric(2,0),  --デバイスエッジ番号
    device_name character varying(20),  --デバイス名
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    setting_date timestamp(3),  --設置日
    delete_date timestamp(3),  --破棄日
    memo character varying(255),  --メモ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_device_edge_01 PRIMARY KEY (serial_no)
);
-- コメント追加（デバイスエッジマスタ）
COMMENT ON TABLE "mst_device_edge" IS E'デバイスエッジマスタ';
COMMENT ON COLUMN "mst_device_edge"."serial_no" IS E'製造番号';
COMMENT ON COLUMN "mst_device_edge"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_device_edge"."device_edge_no" IS E'デバイスエッジ番号';
COMMENT ON COLUMN "mst_device_edge"."device_name" IS E'デバイス名';
COMMENT ON COLUMN "mst_device_edge"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_device_edge"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_device_edge"."setting_date" IS E'設置日';
COMMENT ON COLUMN "mst_device_edge"."delete_date" IS E'破棄日';
COMMENT ON COLUMN "mst_device_edge"."memo" IS E'メモ';
COMMENT ON COLUMN "mst_device_edge"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_device_edge"."up_date" IS E'更新日時';

-- テーブル削除（施設マスタ）
DROP TABLE IF EXISTS mst_facility CASCADE;
-- テーブル作成（施設マスタ）
CREATE TABLE mst_facility
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    facility_name character varying(40) NOT NULL,  --施設名
    facility_name_kana character varying(50),  --施設カナ名
    prefectures_cd character varying(2),  --都道府県コード
    department_cd character varying(4),  --部署符号
    m_notice_mail_template character varying(4000),  --緊急発報メールテンプレート
    auto_gathering_start_time character varying(4),  --自動データ収集開始時刻
    alive_moni_interval numeric(8,0) DEFAULT 600,  --死活監視間隔
    certification_key character varying(128),  --認証キー
    use_function jsonb,  --使用可能機能
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_facility_01 PRIMARY KEY (facility_cd)
);
-- コメント追加（施設マスタ）
COMMENT ON TABLE "mst_facility" IS E'施設マスタ';
COMMENT ON COLUMN "mst_facility"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_facility"."facility_name" IS E'施設名';
COMMENT ON COLUMN "mst_facility"."facility_name_kana" IS E'施設カナ名';
COMMENT ON COLUMN "mst_facility"."prefectures_cd" IS E'都道府県コード';
COMMENT ON COLUMN "mst_facility"."department_cd" IS E'部署符号';
COMMENT ON COLUMN "mst_facility"."m_notice_mail_template" IS E'緊急発報メールテンプレート';
COMMENT ON COLUMN "mst_facility"."auto_gathering_start_time" IS E'自動データ収集開始時刻';
COMMENT ON COLUMN "mst_facility"."alive_moni_interval" IS E'死活監視間隔';
COMMENT ON COLUMN "mst_facility"."certification_key" IS E'認証キー';
COMMENT ON COLUMN "mst_facility"."use_function" IS E'使用可能機能';
COMMENT ON COLUMN "mst_facility"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_facility"."up_date" IS E'更新日時';

-- テーブル削除（装置マスタ）
DROP TABLE IF EXISTS mst_machine;
-- テーブル作成（装置マスタ）
CREATE TABLE mst_machine
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    machine_type_cd character varying(3) NOT NULL,  --型式コード
    machine_serial character varying(8) NOT NULL,  --製造番号
    machine_name character varying(40),  --装置名
    machine_no bigserial,  --装置番号
    ip_address inet,  --IPアドレス
    port character varying(5),  --ポート番号
    com_format_cd character varying(1),  --通信フォーマット
    com_type numeric(1,0),  --通信種別
    device_edge_no numeric(2,0),  --デバイスエッジ番号
    is_ftp character varying(1) NOT NULL,  --データ収集可否
    is_va character varying(1) NOT NULL,  --画像転送可否
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_machine_01 PRIMARY KEY (facility_cd,machine_type_cd,machine_serial)
);
-- コメント追加（装置マスタ）
COMMENT ON TABLE "mst_machine" IS E'装置マスタ';
COMMENT ON COLUMN "mst_machine"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_machine"."machine_type_cd" IS E'型式コード';
COMMENT ON COLUMN "mst_machine"."machine_serial" IS E'製造番号';
COMMENT ON COLUMN "mst_machine"."machine_name" IS E'装置名';
COMMENT ON COLUMN "mst_machine"."machine_no" IS E'装置番号';
COMMENT ON COLUMN "mst_machine"."ip_address" IS E'IPアドレス';
COMMENT ON COLUMN "mst_machine"."port" IS E'ポート番号';
COMMENT ON COLUMN "mst_machine"."com_format_cd" IS E'通信フォーマット';
COMMENT ON COLUMN "mst_machine"."com_type" IS E'通信種別';
COMMENT ON COLUMN "mst_machine"."device_edge_no" IS E'デバイスエッジ番号';
COMMENT ON COLUMN "mst_machine"."is_ftp" IS E'データ収集可否';
COMMENT ON COLUMN "mst_machine"."is_va" IS E'画像転送可否';
COMMENT ON COLUMN "mst_machine"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_machine"."up_date" IS E'更新日時';

-- テーブル削除（装置記録マスタ）
DROP TABLE IF EXISTS mst_machine_record;
-- テーブル作成（装置記録マスタ）
CREATE TABLE mst_machine_record
(
    machine_record_cd character varying(4) NOT NULL,  --装置記録コード
    machine_record_message character varying(256),  --装置記録メッセージ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_machine_record_01 PRIMARY KEY (machine_record_cd)
);
-- コメント追加（装置記録マスタ）
COMMENT ON TABLE "mst_machine_record" IS E'装置記録マスタ';
COMMENT ON COLUMN "mst_machine_record"."machine_record_cd" IS E'装置記録コード';
COMMENT ON COLUMN "mst_machine_record"."machine_record_message" IS E'装置記録メッセージ';
COMMENT ON COLUMN "mst_machine_record"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_machine_record"."up_date" IS E'更新日時';

-- テーブル削除（型式マスタ）
DROP TABLE IF EXISTS mst_machine_type;
-- テーブル作成（型式マスタ）
CREATE TABLE mst_machine_type
(
    machine_type_cd character varying(3) NOT NULL,  --型式コード
    machine_type character varying(20) NOT NULL,  --型式
    model character varying(3),  --機種
    maker character varying(50),  --メーカー
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_machine_type_01 PRIMARY KEY (machine_type_cd)
);
-- コメント追加（型式マスタ）
COMMENT ON TABLE "mst_machine_type" IS E'型式マスタ';
COMMENT ON COLUMN "mst_machine_type"."machine_type_cd" IS E'型式コード';
COMMENT ON COLUMN "mst_machine_type"."machine_type" IS E'型式';
COMMENT ON COLUMN "mst_machine_type"."model" IS E'機種';
COMMENT ON COLUMN "mst_machine_type"."maker" IS E'メーカー';
COMMENT ON COLUMN "mst_machine_type"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_machine_type"."up_date" IS E'更新日時';

-- テーブル削除（緊急発報マスタ）
DROP TABLE IF EXISTS mst_m_notice;
-- テーブル作成（緊急発報マスタ）
CREATE TABLE mst_m_notice
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    machine_record_cd character varying(4) NOT NULL,  --装置記録コード
    machine_record_message character varying(256),  --装置記録メッセージ
    email_address character varying(4000) NOT NULL,  --メールアドレス
    email_name character varying(4000) NOT NULL,  --宛先名称
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_m_notice_01 PRIMARY KEY (facility_cd,machine_record_cd)
);
-- コメント追加（緊急発報マスタ）
COMMENT ON TABLE "mst_m_notice" IS E'緊急発報マスタ';
COMMENT ON COLUMN "mst_m_notice"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_m_notice"."machine_record_cd" IS E'装置記録コード';
COMMENT ON COLUMN "mst_m_notice"."machine_record_message" IS E'装置記録メッセージ';
COMMENT ON COLUMN "mst_m_notice"."email_address" IS E'メールアドレス';
COMMENT ON COLUMN "mst_m_notice"."email_name" IS E'宛先名称';
COMMENT ON COLUMN "mst_m_notice"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_m_notice"."up_date" IS E'更新日時';

-- テーブル削除（並び順管理マスタ）
DROP TABLE IF EXISTS mst_selector;
-- テーブル作成（並び順管理マスタ）
CREATE TABLE mst_selector
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    master_physical_name character varying(40) NOT NULL,  --マスタ物理名称
    order_settings jsonb,  --並び順設定
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_selector_01 PRIMARY KEY (facility_cd,master_physical_name)
);
-- コメント追加（並び順管理マスタ）
COMMENT ON TABLE "mst_selector" IS E'並び順管理マスタ';
COMMENT ON COLUMN "mst_selector"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_selector"."master_physical_name" IS E'マスタ物理名称';
COMMENT ON COLUMN "mst_selector"."order_settings" IS E'並び順設定';
COMMENT ON COLUMN "mst_selector"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_selector"."up_date" IS E'更新日時';

-- テーブル削除（担当施設マスタ）
DROP TABLE IF EXISTS mst_staff_facility;
-- テーブル作成（担当施設マスタ）
CREATE TABLE mst_staff_facility
(
    user_id bigint NOT NULL REFERENCES mst_user(user_id) ,  --担当者ID
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd) ,  --担当施設コード
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_staff_facility_01 PRIMARY KEY (user_id,facility_cd)
);
-- コメント追加（担当施設マスタ）
COMMENT ON TABLE "mst_staff_facility" IS E'担当施設マスタ';
COMMENT ON COLUMN "mst_staff_facility"."user_id" IS E'担当者ID';
COMMENT ON COLUMN "mst_staff_facility"."facility_cd" IS E'担当施設コード';
COMMENT ON COLUMN "mst_staff_facility"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_staff_facility"."up_date" IS E'更新日時';

-- テーブル削除（マスタ定義）
DROP TABLE IF EXISTS sys_master_define;
-- テーブル作成（マスタ定義）
CREATE TABLE sys_master_define
(
    master_physical_name character varying(40) NOT NULL,  --マスタ物理名称
    master_name character varying(40),  --マスタ名
    disp_class character varying(1),  --表示区分
    master_type character varying(1),  --マスタ分類  
    allow_sort character varying(1),  --並び替え可否
    allow_add_record character varying(1),  --新規レコード追加可否
    disp_order numeric(5),  --表示順
    column_info jsonb,  --カラム情報
    combo_data jsonb,  --コンボデータ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_master_define_01 PRIMARY KEY (master_physical_name)
);
-- コメント追加（マスタ定義）
COMMENT ON TABLE "sys_master_define" IS E'マスタ定義';
COMMENT ON COLUMN "sys_master_define"."master_physical_name" IS E'マスタ物理名称';
COMMENT ON COLUMN "sys_master_define"."master_name" IS E'マスタ名';
COMMENT ON COLUMN "sys_master_define"."disp_class" IS E'表示区分';
COMMENT ON COLUMN "sys_master_define"."master_type" IS E'マスタ分類  ';
COMMENT ON COLUMN "sys_master_define"."allow_sort" IS E'並び替え可否';
COMMENT ON COLUMN "sys_master_define"."allow_add_record" IS E'新規レコード追加可否';
COMMENT ON COLUMN "sys_master_define"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_master_define"."column_info" IS E'カラム情報';
COMMENT ON COLUMN "sys_master_define"."combo_data" IS E'コンボデータ';
COMMENT ON COLUMN "sys_master_define"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_master_define"."up_date" IS E'更新日時';

-- テーブル削除（都道府県マスタ）
DROP TABLE IF EXISTS sys_prefectures;
-- テーブル作成（都道府県マスタ）
CREATE TABLE sys_prefectures
(
    pref_cd character varying(2) NOT NULL,  --都道府県コード
    pref_name character varying(8) NOT NULL,  --都道府県名称
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_prefectures_01 PRIMARY KEY (pref_cd)
);
-- コメント追加（都道府県マスタ）
COMMENT ON TABLE "sys_prefectures" IS E'都道府県マスタ';
COMMENT ON COLUMN "sys_prefectures"."pref_cd" IS E'都道府県コード';
COMMENT ON COLUMN "sys_prefectures"."pref_name" IS E'都道府県名称';
COMMENT ON COLUMN "sys_prefectures"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_prefectures"."up_date" IS E'更新日時';

-- テーブル削除（システム設定）
DROP TABLE IF EXISTS sys_system_define;
-- テーブル作成（システム設定）
CREATE TABLE sys_system_define
(
    ctl_no numeric(4,0) NOT NULL,  --管理番号
    service_cd character varying(3),  --サービスコード
    name character varying(256),  --名称
    value jsonb,  --値
    description character varying(4000),  --説明
    is_enable character varying(1),  --編集可否フラグ
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_system_define_01 PRIMARY KEY (ctl_no)
);
-- コメント追加（システム設定）
COMMENT ON TABLE "sys_system_define" IS E'システム設定';
COMMENT ON COLUMN "sys_system_define"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_system_define"."service_cd" IS E'サービスコード';
COMMENT ON COLUMN "sys_system_define"."name" IS E'名称';
COMMENT ON COLUMN "sys_system_define"."value" IS E'値';
COMMENT ON COLUMN "sys_system_define"."description" IS E'説明';
COMMENT ON COLUMN "sys_system_define"."is_enable" IS E'編集可否フラグ';
COMMENT ON COLUMN "sys_system_define"."up_date" IS E'更新日時';
