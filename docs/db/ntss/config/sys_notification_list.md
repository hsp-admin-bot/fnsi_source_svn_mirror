# sys_notification_list

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@sys_notification_list`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| Push通知先情報 |  |  |
| { |  |  |
| jwt | String | プッシュ通知用の署名トークン (JSON Web Token) |
| key | String | ブラウザの公開鍵 |
| auth | String | 認証シークレット(鍵生成をさらに複雑にするための秘密の乱数) |
| endpoint | String | 接続先エンドポイント |
| vapidVersion | String | VAPID (Voluntary Application Server Identification) のバージョン |
| contentEncoding | String | 通知本文の暗号化方式 |
| } |  |  |
