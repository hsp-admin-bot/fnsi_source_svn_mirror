# mst_job

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_job`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| ■JSON情報 |  |  |  |  |
|  | カラム名 | 名称 | 値 | 説明 |
|  | default_menu_settings | デフォルトメニュー設定 | {<br>  default_menu_functions: [string, …],<br>  initial_menu_function : string<br>} | default_menu_functions<br>(デフォルト使用機能コード)：<br>　機能コードを表示する順番に配列で指定<br><br>initial_menu_function<br>(初期表示する機能)：<br>　ログインした時に初期表示しておく機能<br><br>職種のデフォルトメニュー設定。<br>この設定は、利用者マスタの職種選択時にデフォルトメニューとして利用される。 |
|  | default_disp_settings | デフォルト表示設定 | @mst_userシートの「■user_settings ->> default_settingの詳細」を参照 | 職種のデフォルト表示設定。<br>この設定は、利用者マスタの職種選択時にデフォルト表示設定として利用される。 |
|  | default_notification_settings | デフォルト通知設定 | @mst_userシートの「■JSON情報の「ユーザー定義」内の『personal_settings』」を参照 | 職種のデフォルト通知設定。<br>この設定は、利用者マスタの職種選択時にデフォルト通知設定として利用される。 |
