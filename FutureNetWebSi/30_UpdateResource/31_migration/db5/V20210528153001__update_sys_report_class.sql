UPDATE "ntss"."sys_report_class" SET 
"report_type" = '[{"cd": "1", "name": "スゲージュル表"}, {"cd": "2", "name": "週間薬剤集計表"}, {"cd": "3", "name": "水質調査一覧"}, {"cd": "4", "name": "血液検査実績表"}, {"cd": "5", "name": "装置使用一覧表"}]',
"up_date" = now()
WHERE "report_class_cd" = 11;