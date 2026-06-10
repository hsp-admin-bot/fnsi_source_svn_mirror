-- テーブル作成
CREATE TABLE IF NOT EXISTS ord_treat_condition
(
    condition_cd bigserial NOT NULL,  --治療条件管理番号
    ord_no bigint,  --オーダー番号
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd) ,  --施設コード
    machine_no bigint NOT NULL,  --装置番号
    receive_date timestamp(3),  --条件取得日時
    treat_condition jsonb,  --治療条件
    treat_class smallint,  --区分
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_ord_treat_condition_01 PRIMARY KEY (condition_cd)
)
;

INSERT INTO
  mst_facility
  (
    facility_cd
    , facility_name
    , facility_name_kana
    , department_cd
    , prefectures_cd
  )
VALUES
   (
     '001111'
     , 'テスト施設3'
     , 'テストシセツ3'
     , '9003'
     , '01'
   )
;

INSERT INTO
  ord_treat_condition
  (
    ord_no
    , facility_cd
    , machine_no
    , receive_date
    , treat_condition
    , treat_class
    , is_disp
    , is_del
  )
VALUES
  (
    1
    , '001111'
    , 11
    , '2019-03-22T14:35:00.000+09:00'
    , '{"a": "aaa", "b": "bbb"}'
    , 0
    , '1'
    , '0'
  )
  ,
  (
    1
    , '001111'
    , 12
    , '2019-03-21T18:00:00.000+09:00'
    , '{"a": "aaa", "b": "bbb"}'
    , 2
    , '1'
    , '0'
  )
  ,
  (
    1
    , '001111'
    , 12
    , '2019-03-23T21:35:00.000+09:00'
    , '{"a": "aaa", "b": "bbb"}'
    , 1
    , '1'
    , '0'
  )
  ,
  (
    1
    , '001111'
    , 13
    , null
    , '{"a": "aaa", "b": "bbb"}'
    , 3
    , '1'
    , '0'
  )
  ,
  (
    1
    , '001111'
    , 14
    , '2019-03-23T14:35:00.000+09:00'
    , '{"a": "aaa", "b": "bbb"}'
    , 4
    , '0'
    , '0'
  )
  ,
  (
    1
    , '001111'
    , 15
    , '2019-03-23T14:35:00.000+09:00'
    , '{"a": "aaa", "b": "bbb"}'
    , 5
    , '1'
    , '1'
  )
  ,
  (
    1
    , '001111'
    , 16
    , '2019-03-23T14:35:00.000+09:00'
    , '{"a": "aaa", "b": "bbb"}'
    , 6
    , '0'
    , '1'
  )
  ,
  (
    999
    , '001111'
    , 0
    , '2019-03-23T14:35:00.000+09:00'
    , '{"a": "aaa", "b": "bbb"}'
    , 6
    , '1'
    , '0'
  )
  ,
  (
     1
     , '001111'
     , 12
     , '2019-03-23T21:36:00.000+09:00'
     , '{"a": "aaa", "b": "bbb"}'
     , null
     , '1'
     , '0'
   )
;
