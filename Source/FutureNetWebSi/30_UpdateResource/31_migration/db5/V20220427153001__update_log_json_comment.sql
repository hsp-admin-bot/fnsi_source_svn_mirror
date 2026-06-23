-- ベース：加算データに指定日(start_date)を追加
DELETE FROM LOG_JSON_COMMENT WHERE TBL_NAME = 'ord_main' AND COL_NAME = 'addition_info' AND JSON_KEY_NAME = 'start_date';
DELETE FROM LOG_JSON_COMMENT WHERE TBL_NAME = 'pat_main' AND COL_NAME = 'addition_info' AND JSON_KEY_NAME = 'start_date';
INSERT INTO LOG_JSON_COMMENT(TBL_NAME, COL_NAME, JSON_KEY_NAME, JSON_KEY_COMMENT) VALUES('ord_main', 'addition_info', 'start_date', '指定日');
INSERT INTO LOG_JSON_COMMENT(TBL_NAME, COL_NAME, JSON_KEY_NAME, JSON_KEY_COMMENT) VALUES('pat_main', 'addition_info', 'start_date', '指定日');
