# 連携イベント作成・中止ツール

## 画面名

画面名は `連携イベント作成・中止ツール` である。

## 主なソース

- `ntss-win\CoopEventCreateTool\CoopEventCreateTool\FormCoopEventCreate.cs`
- `FormCoopEventCreate.Designer.cs`
- `ComboxXML.xml`
- `MyJson.cs`

## 主要画面項目・ボタン名

- `施設`
- `種別`
- `連携イベント`
- `作成`
- `中止`
- `期間指定`
- `検索`
- `患者指定`
- `送信`
- `初期化`
- `中断`

## 補足

種別一覧は `ComboxXML.xml` から取得される。

検索 API は以下である。

`/ntss-admin-web/api/pat_event/PatientInfo/{facilityCd}/{date_from}/{date_to}/{strSyubetu}/{strkbn}`

送信 API は以下である。

`/ntss-coop-api/journal/create`

`strkbn` は以下の意味を持つ。

- `C`: 作成
- `D`: 中止