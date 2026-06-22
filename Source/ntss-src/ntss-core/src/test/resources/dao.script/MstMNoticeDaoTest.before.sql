delete from mst_m_notice;

insert into mst_m_notice
  (
    facility_cd
    , machine_record_cd
    , machine_record_message
    , email_address,email_name
    , reg_date
    , up_date
  )
 values
 ('000001','0101','血圧測定','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017/11/15 0:54:18','2017/11/15 0:54:18'),
 ('000001','0102','','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017/11/15 0:54:18','2017/11/15 0:54:18'),
 ('000001','0301','','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017/11/15 0:54:18','2017/11/15 0:54:18'),
 ('000001','0400','','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017/11/15 0:54:18','2017/11/15 0:54:18'),
 ('000001','G000','デバイスエッジ通信異常','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2018/03/30 1:03:00','2018/03/30 1:03:00'),
 ('000001','G001','デバイスエッジ異常','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2018/03/30 1:03:00','2018/03/30 1:03:00'),
 ('000002','F00A','デバイスエッジ機器異常','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2018/03/30 1:03:00','2018/03/30 1:03:00'),
 ('999900','958A','テストメッセージ','k-takahara@esm.co.jp,kynkjr-0510-taurus@ezweb.ne.jp','ESM高原（会社）、ESM高原（携帯）','2017/11/15 0:54:18','2017/11/15 0:54:18')
;

-- テスト前にmst_m_noticeにダミー列を追加
ALTER TABLE
  mst_m_notice
ADD COLUMN dummy character varying(1) -- ダミー列
;
