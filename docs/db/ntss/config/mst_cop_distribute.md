# mst_cop_distribute

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_cop_distribute`
- Category: config/reference

## Content

| 項目名 | col2 | col3 | Value | コメント | col6 | col7 | col8 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| protocolInfo |  |  | - |  |  |  |  |
|  |  |  | ○ | "file", "socket", "ftp" |  |  |  |
|  | ※ | protocol=fileの場合 | - |  |  |  |  |
|  | address |  | ○ | Path |  |  |  |
|  | renameWhenCopying |  | ○ | コピーする際に一旦リネームする際の規則。「.tmp」のように設定する。記載なしはリネームなし |  |  |  |
|  | dummy |  | ○ | true: ダミーファイルをコピーする。コピーする際にはdataに表示されたファイル名にする。 |  |  |  |
|  | delete |  | ○ | true: 削除, false:削除せず。 <=同じレポートを二箇所に送るときにあるといいのか？ |  |  |  |
|  | ※ | protocol=socketの場合 | - |  |  |  |  |
|  | socket-type |  | ○ | "normal", "standard", "TSHPlus" |  |  |  |
|  | host |  | ○ | サーバ名、IP |  |  |  |
|  | port |  | ○ | ポート |  |  |  |
|  | user |  | ○ | 認証ユーザ |  |  |  |
|  | password |  | ○ | 認証パスワード |  |  |  |
|  | retryMax |  | ○ | リトライ回数 |  |  |  |
|  | ※ | protocol=ftpの場合 | - |  |  |  |  |
|  | host |  | ○ | サーバ名、IP |  |  |  |
|  | port |  | ○ | ポート |  |  |  |
|  | user |  | ○ | 認証ユーザ |  |  |  |
|  | address |  | ○ | Path |  |  |  |
|  | password |  | ○ | 認証パスワード | { |  |  |
|  | renameWhenCopying |  | ○ | コピーする際に一旦リネームする際の規則。「.tmp」のように設定する。記載なしはリネームなし |  | "result" : [ |  |
|  | dummy |  | ○ | true: ダミーファイルをコピーする。コピーする際にはdataに表示されたファイル名にする。 |  |  |  |
|  | delete |  | ○ | true: 削除, false:削除せず。 <=同じレポートを二箇所に送るときにあるといいのか？ |  |  | { |
|  |  |  |  |  |  |  | "journalInfo" : {"ctlno" : "134", "coop_id_cd" : "patient", "coop_id_index" : "data"}, |
|  |  |  |  |  |  |  | "protocolInfo" : { |
|  |  |  |  |  |  |  | "protocol" : "file", |
|  |  |  |  |  |  |  | "address" : "\\\\hostname\\pat\\data", |
|  |  |  |  |  |  |  | "renameWhenCopying" : ".tmp", |
|  |  |  |  |  |  |  | "delete" : "true" |
|  |  |  |  |  |  |  | } |
|  |  |  |  |  |  |  | "data" : {"filename" : "aaaaa.txt"} |
|  |  |  |  |  |  |  | }, |
|  |  |  |  |  |  |  | { |
|  |  |  |  |  |  |  | "journalInfo" : {"ctlno" : "134", "coop_id_cd" : "patient", "coop_id_index" : "data"}, |
|  |  |  |  |  |  |  | "protocolInfo" : { |
|  |  |  |  |  |  |  | "protocol" : "file", |
|  |  |  |  |  |  |  | "address" : "\\\\hostname\\pat\\data", |
|  |  |  |  |  |  |  | "renameWhenCopying" : ".tmp", |
|  |  |  |  |  |  |  | "delete" : "true" |
|  |  |  |  |  |  |  | } |
|  |  |  |  |  |  |  | "data" : {"filename" : "aaaaa.txt"} |
|  |  |  |  |  |  |  | } |
|  |  |  |  |  |  | ] |  |
|  |  |  |  |  | } |  |  |
