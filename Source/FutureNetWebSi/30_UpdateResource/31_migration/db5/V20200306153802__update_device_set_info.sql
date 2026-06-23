--装置設定デフォルトマスタの更新
update mst_device_set_info_default
 set device_set_info=jsonb_merge_recursive(device_set_info::jsonb, '{"pat":{"ope":{"dev":{"A":{"472": 0,"473": 0,"474": 5,"475": 5}}}}}'::jsonb),
     up_date=CURRENT_TIMESTAMP;

--患者情報の更新
update pat_main
 set device_set_info=jsonb_merge_recursive(device_set_info::jsonb, '{"ope":{"dev":{"A":{"472": 0,"473": 0,"474": 5,"475": 5}}}}'::jsonb),
     up_date=CURRENT_TIMESTAMP
;