-- #10419 患者カレンダー表示内容修正
-- 職種マスタ＞デフォルト表示設定で旧構造の患者カレンダーレイアウトマスタ指定を除去
UPDATE mst_job mj
SET default_disp_settings =
  jsonb_set(
    mj.default_disp_settings,
    '{pat-calendar,selectedLayoutCd}',
    '""'::jsonb,
    true
  )
WHERE
  mj.default_disp_settings -> 'pat-calendar' ->> 'selectedLayoutCd' <> ''
  AND (mj.default_disp_settings -> 'pat-calendar' ->> 'selectedLayoutCd')::bigint
      IN (
        SELECT mpl.pat_calendar_layout_cd
        FROM mst_pat_calendar_layout mpl
        WHERE mpl.disp_class IS NULL
      )
;