-- user_settings->'default_setting'->'patient-search'->'kurCdList' プロパティが存在する場合は'kurCdList' プロパティを削除する
UPDATE mst_user
SET user_settings = jsonb_set(
    user_settings,
    '{default_setting,patient-search}',
    (user_settings->'default_setting'->'patient-search') - 'kurCdList'
)
WHERE user_settings->'default_setting'->'patient-search'->'kurCdList' IS NOT NULL
;
