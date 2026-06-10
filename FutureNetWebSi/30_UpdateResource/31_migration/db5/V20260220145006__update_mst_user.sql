-- #10419 患者カレンダー表示内容修正
-- 個人設定＞デフォルト設定の旧構造の患者カレンダーレイアウトマスタ指定を除去
UPDATE mst_user mu
SET user_settings =
  jsonb_set(
    mu.user_settings,
    '{default_setting,pat-calendar,selectedLayoutCd}',
    '""'::jsonb,
    true
  )
WHERE
  mu.user_settings -> 'default_setting' -> 'pat-calendar' ->> 'selectedLayoutCd' <> ''
  AND (mu.user_settings -> 'default_setting' -> 'pat-calendar' ->> 'selectedLayoutCd')::bigint
      IN (
        SELECT mpl.pat_calendar_layout_cd
        FROM mst_pat_calendar_layout mpl
        WHERE mpl.disp_class IS NULL
      )
;