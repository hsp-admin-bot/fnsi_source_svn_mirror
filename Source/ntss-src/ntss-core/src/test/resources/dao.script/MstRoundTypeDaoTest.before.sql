DELETE FROM mst_round_type;
DELETE FROM mst_facility where facility_cd in ('1001', '1002', '9999');

INSERT INTO
  mst_facility
  (
    facility_cd
    , facility_name
  )
VALUES
  (
    '1001'
    , 'sisetu1'
  )
  , (
    '1002'
    , 'sisetu2'
  )
;

INSERT INTO
  mst_round_type
  (
    round_type_cd
    , facility_cd
    , round_type_name
    , content
    , is_content_omission
    , comment_post_default
    , posting_class_default
    , is_disp
    , is_del
  )
VALUES
  (
    1
    , '1001'
    , 'name1'
    , 'content1'
    , '0'
    , '0'
    , '1'
    , '0'
    , '0'
  )
  , (
    2
    , '1001'
    , 'name2'
    , 'content2'
    , '0'
    , '0'
    , '1'
    , '1'
    , '0'
  )
  , (
    3
    , '1001'
    , 'name3'
    , 'content3'
    , '0'
    , '1'
    , '0'
    , '0'
    , '1'
  )
  , (
    4
    , '1002'
    , 'name4'
    , 'content4'
    , '0'
    , '0'
    , '1'
    , '0'
    , '0'
  )
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_round_type
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;
