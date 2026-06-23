-- #12555 トースト通知表示時間の設定追加
-- 機能遷移通知→通知設定
UPDATE ntss.sys_system_define
SET value = (
  SELECT jsonb_agg(
           CASE
             WHEN e->>'name' = '機能遷移通知'
               THEN jsonb_set(e, '{name}', to_jsonb('通知設定'::text), false)
             ELSE e
           END
         )
  FROM jsonb_array_elements(value) AS e
),
up_date = now()
WHERE ctl_no = 12;
