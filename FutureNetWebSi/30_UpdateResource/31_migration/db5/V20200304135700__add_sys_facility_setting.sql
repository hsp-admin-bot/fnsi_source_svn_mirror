insert 
into sys_facility_setting( 
  facility_setting_no
  , setting_name
  , default_value
  , input_type
  , option_value
  , function_name
  , maker_setting
  , description
  , disp_order
  , reg_date
  , up_date
) 
values (
  '1036'
  , 'パスワードポリシー適用レベル'
  , '4'
  , 4
  , '[{"id":"1","name":"1:無し"},{"id":"2","name":"2:ポリシー低"},{"id":"3","name":"3:ポリシー中"},{"id":"4","name":"4:ポリシー高"}]'
  , 'アカウント編集'
  , 0
  , '第三者から不正にアクセスされるリスクを軽減するための設定です。<br>

【無し】文字数のみ <br>​

【ポリシー低】英小文字 と数字を含む <br>​

【ポリシー中】次の 4 種類のうち 3 つの文字を使う。<br>​
・英大文字 (A から Z) <br>​
・英小文字 (a から z) <br>​
・10 進数の数字 (0 から 9) <br>​
・記号 (!、$、#、% など) <br>​

【ポリシー高】次の 4 種類の文字を使う。<br>​
・英大文字 (A から Z) <br>​
・英小文字 (a から z) <br>​
・10 進数の数字 (0 から 9) <br>​
・記号 (!、$、#、% など) '
    , 36
    , now()
    , now()
);

insert 
into sys_facility_setting( 
  facility_setting_no
  , setting_name
  , default_value
  , input_type
  , option_value
  , function_name
  , maker_setting
  , description
  , disp_order
  , reg_date
  , up_date
) 
values (
  '1037'
  , 'パスワード文字数'
  , '8'
  , 2
  , '[{"min":"4",  "max":"16"}]'
  , 'アカウント編集'
  , 0
  , '4文字～16文字の設定が可能。<br>​
  (初期値:8文字)'
    , 38
    , now()
    , now()
);

insert 
into sys_facility_setting( 
  facility_setting_no
  , setting_name
  , default_value
  , input_type
  , option_value
  , function_name
  , maker_setting
  , description
  , disp_order
  , reg_date
  , up_date
) 
values (
  '1038'
  , '２要素認証'
  , '0'
  , 4
  , '[{"id":"0","name":"0:使用しない"},{"id":"1","name":"1:任意使用"},{"id":"2","name":"2:必須使用"}]'
  , 'サインイン'
  , 0
  , 'ID/パスワードの他に、ソフトトークンなどを使用することでセキュリティを向上させる設定です。<br>

【使用しない】<br>​

　サインイン画面でのIDパスワードのみ。<br>​

【任意使用】<br>​

【必須使用】<br>​

　ランダムで生成される数字を使用 '
    , 37
    , now()
    , now()
);