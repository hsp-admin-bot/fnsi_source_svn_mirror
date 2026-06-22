delete from mnt_weight_state;
delete from mnt_client_connect;

insert into mnt_weight_state
  ( scale_cd,  --体重計管理コード
    facility_cd,  --施設コード
    weight_no,  --体重計番号
    is_connect,  --接続状態
    scale_value,  --測定値
    barcode_value,  --バーコードリーダー取得値
    card_read_value,  --カード取得値
    card_write_value,  --カード書き込み内容
    write_result,  --カード書き込み結果
    reg_date,  --登録日時
    up_date --更新日時
  )
values
  (1, '999999', '99', '1', NULL, NULL, NULL, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
  ;
  
insert into mnt_client_connect
(ip_address, facility_cd, reg_date, up_date, server_type)
values
('127.0.0.1', '999999', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '0')
;