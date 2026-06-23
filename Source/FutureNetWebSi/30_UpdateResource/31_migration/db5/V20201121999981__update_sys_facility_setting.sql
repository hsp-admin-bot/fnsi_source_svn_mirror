update sys_facility_setting set description='サインインパスワードの最低文字数を設定します。<br>
4文字～16文字の設定が可能です。' where facility_setting_no='1037';
update sys_facility_setting set description='過去のパスワードの再利用を禁止する設定です。<br>
何世代前までの再利用を禁止するか設定します。（最大9世代前まで）<br>
0を設定すると、過去のパスワードの再利用を禁止しません。' where facility_setting_no='1060';
update sys_facility_setting set description='連続でサインインに失敗した場合、アカウントをロックするか設定します。<br>
0:アカウントロックしない：連続でサインインに失敗してもアカウントロックは行いません。<br>
1:アカウントロックする：連続でサインインに失敗した回数が、設定したサインイン失敗回数に達した場合、アカウントをロックします。' where facility_setting_no='1061';
update sys_facility_setting set description='連続でサインインに失敗した場合にアカウントロックする許容回数を設定します。<br>
' where facility_setting_no='1062';
update sys_facility_setting set description='2要素認証に失敗した場合、再度サインインからやり直しとなる許容回数を設定します。' where facility_setting_no='1063';
update sys_facility_setting set description='サインインしている利用者に対して利用者マスタでの編集権限変更や、使用機能設定で機能の削除が行われた場合の動作を設定します。<br>
0:無効：次回のサインインより変更した設定が有効になります。<br>
1:有効：直ちに変更した設定を有効にするため、強制サインアウトさせます。' where facility_setting_no='1064';
