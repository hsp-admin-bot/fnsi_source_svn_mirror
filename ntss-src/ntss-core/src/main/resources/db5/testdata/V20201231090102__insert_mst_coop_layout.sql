INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130004, '999998', 'profile', 'send_time', 'S', 'cre', 'text     ', '定時一括送信機能（患者プロファイル用）', 'fujitsu', 'テスト用', '1', '<root name="患者情報要求">
    <item  name="共通部.電文種別" len="2" value="const:VO"/>
    <item  name="共通部.レコード継続指示" len="1" value="const:E"/>
    <item  name="共通部.送信先システムコード" len="2" value="const:XX"/>
    <item  name="共通部.発信元システムコード" len="2" value="const:VN"/>
    <item  name="共通部.処理日時.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="共通部.処理日時.処理時間" len="6" value="$SYSTIME"/>
    <item  name="共通部.端末名" len="8" value="const:VOSERVER"/>
    <item  name="共通部.利用者番号" len="8" value="const:        "/>
    <item  name="共通部.処理区分" len="2" value="const:01"/>
    <item  name="共通部.応答種別" len="2" value="$BLANK"/>
    <item  name="共通部.電文長" len="6" value="$LENGTH"/>
    <item  name="共通部.エラーコード" len="5" value="$BLANK"/>
    <item  name="共通部.予備" len="12" value="$BLANK"/>
    <item  name="内容部.患者情報.患者番号" len="10" value="$JOURNAL.hosp_pat_id"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -999}]}', '1', '0', -2, '2020-01-21 08:29:41.74', '2020-01-21 08:29:41.74');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130005, '999998', 'exam_rst', 'send_time', 'S', 'cre', 'text     ', '定時一括送信機能（透析初回申し込み用）', 'fujitsu', 'テスト用', '1', '<root name="検査結果(pre)">
    <item  name="電文種別" len="2" type="string"/>
    <item  name="レコード継続指示" len="1" type="string"/>
    <item  name="送信先システムコード" len="2" type="string"/>
    <item  name="発信元システムコード" len="2" type="string"/>
    <item  name="処理情報.処理年月日" len="8" type="string"/>
    <item  name="処理情報.処理時刻" len="6" type="string"/>
    <item  name="端末名" len="8" type="string"/>
    <item  name="利用者番号" len="8" type="string"/>
    <item  name="処理区分" len="2" type="string"/>
    <item  name="応答種別" len="2" type="string"/>
    <item  name="電文長" len="6" type="string"/>
    <item  name="エラーコード" len="5" type="string"/>
    <item  name="予備" len="12" type="string"/>
    <item  name="検査状態" len="2" type="string"/>
    <item  name="伝票情報.レポート種別" len="4" key="レポート種別" type="string"/>
    <item  name="伝票情報.文書番号" len="30" type="string"/>
    <item  name="版数" len="2" type="string"/>
    <item  name="枝番" len="4" type="string"/>
    <item  name="オーダ番号" len="8" type="string"/>
    <item  name="依頼日" len="8" type="string"/>
    <item  name="患者番号" len="10" type="string"/>
    <item  name="科コード" len="3" type="string"/>
    <item  name="入外区分" len="1" type="string"/>
    <item  name="病棟コード" len="3" type="string"/>
    <item  name="採取日" len="8" type="string"/>
    <item  name="採取時間" len="6" type="string"/>
    <item  name="依頼コメントコード" len="20" type="string"/>
    <item  name="ドクタコード" len="8" type="string"/>
    <item  name="フリーコメント" len="50" type="string"/>
    <item  name="フリーコメント" len="50" type="string"/>
    <item  name="画像フラグ" len="1" type="string"/>
    <item  name="生体情報.身長" len="5" type="string"/>
    <item  name="生体情報.体重" len="5" type="string"/>
    <item  name="生体情報.畜尿量" len="5" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <occ  name="検体情報" len="0" repeat="50"/>
    <occ  name="結果情報" len="0" repeat="300"/>
    <item  name="終端" len="1" type="string"/>
</root>', '{"key": {"レポート種別": {"ER01": "検体検査", "ER02": "一般細菌", "ER03": "抗酸菌", "ER04": "その他細菌"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
