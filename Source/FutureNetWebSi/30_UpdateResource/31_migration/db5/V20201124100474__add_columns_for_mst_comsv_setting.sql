--装置通信・仮想端末マスタ「投薬変更のお知らせ」の有無を判断する項目を追加
ALTER TABLE ntss.mst_comsv_setting ADD is_notice_medi character varying(1) default '0';

COMMENT ON COLUMN ntss.mst_comsv_setting.is_notice_medi IS '投薬変更のお知らせ';