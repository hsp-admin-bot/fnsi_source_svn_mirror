-- 通知カテゴリ
-- 0  機能遷移通知
-- 10 患者情報通知
-- 20 治療中通知
-- 30 患者イベント通知
-- 40 治療スケジュール通知
-- 50 施設イベント通知
-- 60 連携通知
-- 70 マスタ通知
-- 80 検査通知
DELETE FROM "sys_notification" WHERE "notification_no"  IN (29,30,31,32,33,34,35,36);

-- 新規患者登録時の通知定義を登録
INSERT INTO sys_notification(
  notification_no,
  notification_category, 
  setting_name, 
  message, 
  additional_info, 
  disp_order, 
  available_keys, 
  is_disp, 
  is_del, 
  reg_date, 
  up_date,
  help
)
VALUES(
  29,
  '40',
  'サインイン時クール未登録チェック通知',
  '本日の治療でクール未登録の治療予定が[COUNT]件あります。',
  '{"FUNC": "009", "FACILITYCD": "[FACILITYCD]"}',
  '24',
  '[COUNT]：クール未登録件数、[FACILITYCD]：施設コード、[USERID]：サインイン利用者ID',
  '1',
  '0',
  now(),
  now(),
  'サインイン時に当日の治療予定にクール未登録があった場合に通知します。'
),(
  30,
  '40',
  'サインイン時ベッド未登録チェック通知',
  '本日の治療でベッド未登録の治療予定が[COUNT]件あります。',
  '{"FUNC": "009", "FACILITYCD": "[FACILITYCD]"}',
  '25',
  '[COUNT]：ベッド未登録件数、[FACILITYCD]：施設コード、[USERID]：サインイン利用者ID',
  '1',
  '0',
  now(),
  now(),
  'サインイン時に当日の治療予定にベッド未登録があった場合に通知します。'
),(
  31,
  '20',
  '回診記録通知',
  '[BEDNAME]：[LASTNAME] [FIRSTNAME]さんの回診記録に[CATEGORY]が登録されました。',
  '{"FUNC": "00612", "ORDNO": "[ORDNO]", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]"}',
  '21',
  '[PATID]：内部患者ID、[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)、[BEDNAME]：ベッド名、[FACILITYCD]：施設コード、[ORDNO]：オーダ番号、[CATEGORY]：回診記録カテゴリ',
  '1',
  '0',
  now(),
  now(),
  '回診記録マスタで通知対象の項目が、治療記録の回診記録で登録されると通知します。'
),(
  32,
  '50',
  '掲示板施設カレンダー(施設イベント)',
  '施設イベント：[CATEGORY] [TITLE]が登録されました。',
  '{"FUNC": "02002", "FACILITYCD": "[FACILITYCD]", "BBSCTLNO": "[BBSCTLNO]"}',
  '26',
  '[CATEGORY]：施設イベントカテゴリ、[TITLE]：タイトル、[FACILITYCD]：施設コード、[BBSCTLNO]：掲示板管理番号',
  '1',
  '0',
  now(),
  now(),
  '通知対象とした施設イベントが登録されると通知します。'
),(
  33,
  '30',
  '患者イベント',
  '[LASTNAME] [FIRSTNAME] さんの患者イベント：[CATEGORY]が登録されました。',
  '{"FUNC": "027", "FACILITYCD": "[FACILITYCD]", "PATEVENTCD": "[PATEVENTCD]", "PATID": "[PATID]"}',
  '23',
  '[PATID]：内部患者ID、[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)、[CATEGORY]：患者イベントサブカテゴリ、[FACILITYCD]：施設コード、[PATEVENTCD]：患者イベントコード',
  '1',
  '0',
  now(),
  now(),
  '通知対象とした患者イベントが登録されると通知します。'
),(
  34,
  '20',
  'ナースコール',
  '[BEDNAME]：[NAME]さんがナースコールしています。',
  '{"FUNC": "006", "ORDNO": "[ORDNO]", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]"}',
  '22',
  '[PATID]：内部患者ID、[NAME]：患者名(姓) + 患者名(名) もしくは "不明な患者"、[BEDNAME]：ベッド名、[FACILITYCD]：施設コード、[ORDNO]：オーダ番号',
  '1',
  '0',
  now(),
  now(),
  '日機装製透析装置にてナースコールを押すと通知します。'
),(
  35,
  '90',
  '申込完了',
  '[DATE]に申込んだ機能を解放しました。設定の上お使いください。',
  '{"FUNC": "005", "FACILITYCD": "[FACILITYCD]"}',
  '35',
  '[DATE]：申込日、[FACILITYCD]：施設コード',
  '1',
  '0',
  now(),
  now(),
  '申込んだ機能が解放されると通知します。'
),(
  36,
  '20',
  '治療中指示変更通知',
  '[BEDNAME]：[LASTNAME] [FIRSTNAME]さんの指示が変更されました。',
  '{"FUNC": "011", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]", "ORDNO": "[ORDNO]"}',
  '20',
  '[PATID]：内部患者ID、[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)、[BEDNAME]：ベッド名、[FACILITYCD]：施設コード、[ORDNO]：オーダ番号',
  '1',
  '0',
  now(),
  now(),
  '前体重測定後から後体重測定前までの間に指示情報が変更されると通知します。'
);