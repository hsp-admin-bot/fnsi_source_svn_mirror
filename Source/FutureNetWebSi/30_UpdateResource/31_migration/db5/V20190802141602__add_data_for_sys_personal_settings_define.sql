-- 施設ごとの個人設定タブ定義
UPDATE
  mst_personal_tab_define
SET
  display_name='通知メッセージ'
  , contents_id='common-tab-contents-1'
  , "mode" = '1'
WHERE
  tab_define_cd = 1
;

-- 共通設定タブ定義
UPDATE
  sys_personal_settings_define
SET
  item_info =
    '{
      "item_info": [
        {
          "identifier": "1",
          "type": "combo1",
          "title": "通知メッセージジャンプで既読",
          "validation": { "required": true }
        }
      ]
    }'
  , combo_data =
    '{
      "combos": [
        {
          "values": [
            { "text": "しない", "value": "0" },
            { "text": "する", "value": "1" }
          ],
          "setting_identifier": "1"
        }
      ]
    }'
  , reference_combo_def = NULL
WHERE
  personal_settings_cd = 1
;
