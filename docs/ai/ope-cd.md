# ope_cd 調査メモ

`ope_cd` は「操作番号」を表す。外部連携ジャーナル、施設連携設定、IF Edge 設定、ジャーナル作成ロジックをまたぐキーであり、単一テーブルの外部キーとしてだけ扱わないこと。

## 基本的な見方

- `ope_cd` は、どの業務操作で発生した連携かを識別する番号である。
- `sys_coop_journal.ope_cd` には、作成された外部連携ジャーナルの操作番号が入る。
- `mst_coop_facility.common_setting` の `coop_ope_cd` では、操作番号ごとの送信・受信可否と `status` を管理する。
- `mst_coop_facility.common_setting` の `coop_ord_cd` では、操作番号から `coop_cd`、`direction`、`ana_result`、`coop_result`、`coop_cd_index`、`coop_version` などの連携定義へ対応付ける。
- `mst_coop_facility.if_edge_setting` や `ntss-coop-edge/if_edge/conf/ifedge_setting.json` では、IF Edge の受信監視、タイマー送信、データ種別と操作番号が対応する。

## 探索時の優先確認順

`ope_cd` がキーワードになった場合は、番号そのものの一致だけで判断せず、以下の順で確認する。

1. ジャーナル作成元を確認する。
   - 送信系は `JournalCreatePayloadServiceImpl` の `OPECDENUM` が主要な入口になる。
   - `OPECDENUM` は `tablePhysicalName`、`crud`、`option` から操作番号を引く。
   - `payload.setOpeCd("900001")` のような直指定もあるため、`setOpeCd` も検索する。
2. 施設連携設定を確認する。
   - `mst_coop_facility.common_setting.coop_ope_cd.ope_cd_send`
   - `mst_coop_facility.common_setting.coop_ope_cd.ope_cd_receive`
   - `mst_coop_facility.common_setting.coop_ord_cd[].ope_cd`
   - `status` が `on` か、送信・受信のどちらに属するか、`coop_version` が一致するかを見る。
3. ジャーナル作成 API 側の検証を確認する。
   - `JournalResource` は `facility_cd` と `ope_cd` から施設連携設定を読み、送信・受信の重複、未定義、無効状態を検証する。
   - `coop_ord_cd[].ope_cd` に含まれる場合、`coop_cd` や `coop_cd_index` がリクエストへ反映される。
   - `900004` は連携イベント作成・中止ツール用で、通常の `coop_cd` 再設定とは扱いが異なる。
4. ジャーナル登録処理を確認する。
   - `JournalServiceImpl` は `coop_ord_cd[].ope_cd` と `coop_version` で連携対象か判定し、対象外ならエラーにする。
   - 登録時に `SysCoopJournal.opeCd` へ設定され、`sys_coop_journal.ope_cd` に保存される。
5. 変換・配信での参照を確認する。
   - `ConvertSendCommonServiceImpl` では電文項目 `ope_cd` の差し込み値としてジャーナルの操作番号を使う。
   - `DeliveryServiceImpl`、`JournalInfo`、`JournalDistribute` などでは配信対象情報として持ち回る。
6. IF Edge 設定を確認する。
   - 受信系は `if_edge_setting.receive.watch[].ope_cd` を確認する。
   - 定時送信系は `if_edge_setting.timer[].ope_cd` を確認する。
   - 例として `031001` は患者プロファイル定時送信、`800003` は患者プロファイル受信、`800005` は検査結果受信で使われることがある。

## 番号帯の目安

番号帯は厳密な仕様表として固定視せず、調査の当たりを付けるために使う。

- `004xxx`、`006xxx`、`011xxx`、`013xxx` など: 透析予約、治療実績、レポート、受付、体重測定などの送信操作で多く出る。
- `021xxx`: 検査オーダ系で多く出る。
- `022xxx`: 放射線検査オーダ系で多く出る。
- `031xxx`: 患者情報、プロファイル、死亡患者関連、定時送信などで多く出る。
- `800xxx`: 外部からの受信操作で多く出る。IF Edge の `receive.watch` と対応することが多い。
- `900xxx`: 日次処理、マスタ編集、連携イベント作成・中止など、通常画面操作以外の特別処理で多く出る。

## 主要ファイル

- `ntss-src/ntss-api/src/main/java/jp/co/nikkiso/ntss/api/service/journal/JournalCreatePayloadServiceImpl.java`
  - `OPECDENUM` で、テーブル名、CRUD、画面・処理オプションから `ope_cd` を決める。
- `ntss-src/ntss-coop-api/src/main/java/jp/co/nikkiso/ntss/coop_api/web/rest/JournalResource.java`
  - ジャーナル作成 API の入口。施設連携設定と `ope_cd` の整合性を検証する。
- `ntss-src/ntss-coop-api/src/main/java/jp/co/nikkiso/ntss/coop_api/service/JournalServiceImpl.java`
  - `coop_ord_cd` と `ope_cd` から連携対象判定を行い、`sys_coop_journal` へ登録する。
- `ntss-src/ntss-core/src/main/java/jp/co/nikkiso/ntss/core/entity/MstCoopFacility.java`
  - `common_setting` JSON の `coop_ope_cd`、`coop_ord_cd` の Java マッピングを定義する。
- `ntss-src/ntss-core/src/main/java/jp/co/nikkiso/ntss/core/entity/SysCoopJournal.java`
  - `sys_coop_journal.ope_cd` のエンティティ定義。
- `ntss-src/ntss-coop-api/src/main/java/jp/co/nikkiso/ntss/coop_api/service/ConvertSendCommonServiceImpl.java`
  - 電文項目 `ope_cd` にジャーナルの操作番号を出力する。
- `ntss-coop-edge/if_edge/conf/ifedge_setting.json`
  - IF Edge の受信監視・定時送信で使う `ope_cd` の設定例。
- `FutureNetWebSi/30_UpdateResource/31_migration/db5/*mst_coop_facility*.sql`
  - 施設別の `common_setting`、`if_edge_setting` の初期値・更新差分。
- `FutureNetWebSi/30_UpdateResource/31_migration/db5/V20201228131501__alter_column_for_sys_coop_journal.sql`
  - `sys_coop_journal.ope_cd` の追加定義。

施設設定内の JSON は 1 行が長くなりやすい。マイグレーション差分を見る場合は、`docs/ai/migration-diff.md` に従い、DELETE 対象主キーごとに直近 INSERT ブロックをたどって比較する。

## 注意点

- `ope_cd` と `coop_cd` は別物である。`ope_cd` は操作番号、`coop_cd` は電文種別である。
- 同じ `ope_cd` でも、施設設定や `coop_version` により有効・無効、送信・受信、電文種別が変わる可能性がある。
- `coop_ope_cd` に存在しても、`coop_ord_cd[].ope_cd` に対応がなければジャーナル作成時に連携対象外になる。
- `coop_ord_cd[].ope_cd` に存在しても、`coop_ope_cd` 側の `status` が `off` なら API 検証で止まる。
- `800xxx` は受信系であることが多いが、必ず `direction` と IF Edge 設定を確認する。
- `900004` は連携イベント作成・中止ツール用の特別値である。通常の画面操作由来の `ope_cd` と同じ扱いで説明しない。
- `ope_id` という古い列追加マイグレーションがあるが、現行調査では基本的に `ope_cd` を追う。
