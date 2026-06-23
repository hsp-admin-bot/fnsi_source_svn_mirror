-- デフォルト設定＞患者検索＞ベッドグループ ベッドグループコードにデータ修正
UPDATE mst_user
SET user_settings = jsonb_set(
    user_settings,
    '{default_setting,patient-search,bedCdListString}',
    -- CASEで条件分岐
    CASE 
        -- "[]"の場合は0に設定
        WHEN user_settings->'default_setting'->'patient-search'->>'bedCdListString' = '[]' 
        THEN '0'::jsonb
        -- {"key":<key_value>,"value":"[...]"} の形式の場合、<key_value> の数値を抽出して設定
        ELSE 
            (regexp_match(
                user_settings->'default_setting'->'patient-search'->>'bedCdListString', 
                '\{"key":([0-9]+),"value":".*"\}'
            ))[1]::int::text::jsonb
    END
	),
	up_date = CURRENT_TIMESTAMP
WHERE
	(
    user_settings->'default_setting'->'patient-search'->>'bedCdListString' = '[]' 
    OR user_settings->'default_setting'->'patient-search'->>'bedCdListString' ~ '^\{"key":[0-9]+,"value":".*"\}$'
    )
;
