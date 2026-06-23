delete from "mst_coop_layout_detail" where "ctl_no" in (-3010000028,-3010000027,-3010000026,-3010000025,-3010000024,-3010000023,-3010000022,-3010000021,-3010000020,-3010000019,-3010000018,-3010000017,-3010000016,-3010000015,-3010000014,-3010000013,-3010000012,-3010000011,-3010000010,-3010000009,-3010000008,-3010000007,-3010000006,-3010000005,-3010000004,-3010000003,-3010000002,-3010000001);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000028, 'N_hosp', 'ini_dial', 'R', '透析コメント明細_空白', 'all', 'NEC想定初回指示-詳細', '初回指示電文ver2、患者情報、患者死亡退院情報用', '1', '<root name="透析コメント明細(all)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000027, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細_空白', 'all', 'NEC想定初回指示-詳細', '初回指示電文ver2、患者情報、患者死亡退院情報用', '1', '<root name="透析指示オーダ明細(all)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000026, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '空白', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(空白)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000025, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '会計コメン', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(会計コメン)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000024, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '指示コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(指示コメント)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000023, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', '原疾患', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(原疾患)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000022, 'N_hosp', 'ini_dial', 'R', '透析コメント明細', 'pre', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析コメント明細(pre)">
    <item  name="明細.コメント連番" len="3" type="string"/>
    <item  name="明細.コメント種別" len="2" key="コメント種別" type="string"/>
    <item  name="明細.コメント内容" len="60" type="string"/>
</root>', '{"key": {"コメント種別": {"01": "原疾患", "20": "指示コメント", "60": "会計コメン", "_DEFAULT": "空白"}}}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000021, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '空白', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(空白)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000020, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '会計コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(会計コメント)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000019, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント５', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント５)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000018, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント４', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント４)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000017, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント３', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント３)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000016, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント２', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント２)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000015, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析コメント１', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析コメント１)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000014, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '項目コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(項目コメント)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000013, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'その他項目', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(その他項目)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000012, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '加算（その他）', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(加算（その他）)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000011, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '使用材料', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(使用材料)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000010, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '穿刺針', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(穿刺針)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string" col="$journal.ord_main.ind_cond_info.9.value"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.9.value_name_1"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000009, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '薬剤', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(薬剤)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000008, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '抗凝固剤', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(抗凝固剤)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string" col="$journal.ord_main.ind_cond_info.25.value"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.25.value_name_1"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string" col="$journal.ord_main.ind_cond_info.28.value"/>
    <item  name="明細.使用量単位" len="2" type="string" col="$journal.ord_main.ind_cond_info.28.unit"/>
    <item  name="明細.使用量単位名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.28.unit_name"/>
    <item  name="明細.速度" len="9" type="string" col="$journal.ord_main.ind_cond_info.27.value"/>
    <item  name="明細.速度単位" len="2" type="string" col="$journal.ord_main.ind_cond_info.27.unit"/>
    <item  name="明細.速度単位名称" len="60" type="string" col="$journal.ord_main.ind_cond_info.27.unit_name"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000007, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'ダイアライザ', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(ダイアライザ)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000006, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '透析方法', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(透析方法)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string" col="$journal.ord_main.ind_treatment_cd"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string" col="$journal.ord_main.ind_treatment_name"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000005, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '指示コメント', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(指示コメント)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string" col="$journal.detail.ord_main_2.ind_ind_comment_info.cd"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string" col="$journal.detail.ord_main_2.ind_ind_comment_info.content"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000004, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '部位', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(部位)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000003, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'ブラッドアクセス', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(ブラッドアクセス)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000002, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', '加算（患者）', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(加算（患者）)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string" col="$journal.detail.ord_main_1.addition_info.cd"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string" col="$journal.detail.ord_main_1.addition_info.name"/>
    <item  name="明細.機能コード" len="2" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010000001, 'N_hosp', 'ini_dial', 'R', '透析指示オーダ明細', 'pre', 'NEC想定初回指示-詳細', '初回指示電文ver1用', '1', '<root name="透析指示オーダ明細(pre)">
    <item  name="明細.項目連番" len="3" type="string"/>
    <item  name="明細.項目コード" len="6" type="string"/>
    <item  name="明細.項目世代番号" len="1" type="string"/>
    <item  name="明細.項目名称" len="60" type="string"/>
    <item  name="明細.機能コード" len="2" key="機能コード" type="string"/>
    <item  name="明細.使用量" len="9" type="string"/>
    <item  name="明細.使用量単位" len="2" type="string"/>
    <item  name="明細.使用量単位名称" len="60" type="string"/>
    <item  name="明細.速度" len="9" type="string"/>
    <item  name="明細.速度単位" len="2" type="string"/>
    <item  name="明細.速度単位名称" len="60" type="string"/>
    <item  name="明細.コメントコード１" len="6" type="string"/>
    <item  name="明細.コメントコード１世代" len="1" type="string"/>
    <item  name="明細.コメント１名称" len="60" type="string"/>
    <item  name="明細.コメントコード２" len="6" type="string"/>
    <item  name="明細.コメントコード２世代" len="1" type="string"/>
    <item  name="明細.コメント２名称" len="60" type="string"/>
    <item  name="明細.コメントコード３" len="6" type="string"/>
    <item  name="明細.コメントコード３世代" len="1" type="string"/>
    <item  name="明細.コメント３名称" len="60" type="string"/>
    <item  name="明細.フリーコメント" len="60" type="string"/>
    <item  name="明細.医事インターフェースフラグ" len="1" type="string"/>
    <item  name="明細.予備" len="30" type="string"/>
</root>', '{"key": {"機能コード": {"20": "加算（患者）", "21": "ブラッドアクセス", "22": "部位", "23": "指示コメント", "24": "透析方法", "25": "ダイアライザ", "26": "抗凝固剤", "27": "薬剤", "28": "穿刺針", "29": "使用材料", "30": "加算（その他）", "31": "その他項目", "32": "項目コメント", "3A": "透析コメント１", "3B": "透析コメント２", "3C": "透析コメント３", "3D": "透析コメント４", "3E": "透析コメント５", "3K": "会計コメント", "_DEFAULT": "空白"}}}', '1', '0', -1, '2021-11-23 12:12:12', '2021-11-23 12:12:12');
