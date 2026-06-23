delete from "mst_coop_layout" where "ctl_no"  = -2030004;
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2030004, 'F_hosp', 'profile', '', 'S', 'cre', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者情報要求">

    <item  name="共通部.電文種別" len="2" value="const:XI"/>

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

</root>', '{}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
