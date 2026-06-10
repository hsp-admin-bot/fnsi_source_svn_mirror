# CoopSettingTool 連携機能インストール画面 実装概要

調査日: 2026-06-04

## 対象

CoopSettingTool の「連携機能インストール」画面は WinForms / MaterialSkin の `CoopInstallView` で実装されている。

主な実装ファイル:

- `ntss-win/CoopSettingTool/CoopSettingTool.App/Views/Implements/CoopInstallView.cs`
- `ntss-win/CoopSettingTool/CoopSettingTool.App/Views/Implements/CoopInstallView.Designer.cs`
- `ntss-win/CoopSettingTool/CoopSettingTool.App/Controllers/Implements/CoopInstallController.cs`
- `ntss-win/CoopSettingTool/CoopSettingTool.App/Models/Implements/CoopInstallModel.cs`
- `ntss-win/CoopSettingTool/CoopSettingTool.Service/Constant.cs`

## 起動導線

`ApplicationModule` で `ICoopInstallView` が `CoopInstallView`、`ICoopInstallModel` が `CoopInstallModel` にバインドされている。

メインメニューでは `btnCoopInstall` が「連携機能インストール」ボタンで、初期表示は `Visible = false`。対象施設が選択されると `UpdateViewByFacility` で `btnCoopInstall.Visible = true` になり、施設名ラベルも更新される。

`btnCoopInstall.Click` は `MainMenuView.BtnCoopInstall_Click` に接続され、メインメニューを隠して `coopInstallView.ShowDialog(this, SelectedFacility)` を開く。画面が `DialogResult.Abort` で閉じた場合はメニューも Abort 終了し、それ以外ではメニューを再表示して `LoadFacilityData()` を再実行する。

関連箇所:

- `Module/ApplicationModule.cs:67`, `:89`
- `Views/Implements/MainMenuView.Designer.cs:144`, `:155`
- `Views/Implements/MainMenuView.cs:151`, `:343`
- `Views/Implements/MainMenuView.cs:480`
- `Controllers/Implements/MainMenuController.cs:61`

## 画面項目

`CoopInstallView.Designer.cs` で定義される表示項目は次の通り。

| コントロール | 表示内容 / 初期状態 | 実装箇所 |
| --- | --- | --- |
| `clbCoopArtifact` | インストール候補のチェックリスト。`CheckOnClick = true`。 | `CoopInstallView.Designer.cs:52`, `:64` |
| `btnSave` | 「保存」。初期状態は `Enabled = false`。 | `CoopInstallView.Designer.cs:54`, `:89`, `:96` |
| `btnCancel` | 「キャンセル」。押下で Cancel 終了。 | `CoopInstallView.Designer.cs:53`, `:82` |
| `cbShowFullCoop` | 「他の施設の連携も表示する」。初期状態は `Visible = false`。 | `CoopInstallView.Designer.cs:55`, `:108`, `:110` |
| `lbFacName` | 対象施設の `DisplayMember` を表示。 | `CoopInstallView.Designer.cs:56`, `CoopInstallView.cs:166` |
| 画面タイトル | 「連携機能インストール」 | `CoopInstallView.Designer.cs:139` |

## 初期表示と一覧表示

`CoopInstallView` のコンストラクタは `CoopInstallController` を生成し、`RegisterEvent()` でイベントを接続する。

イベント接続:

- `Shown` -> `OnFormShown`
- `FormClosing` -> `CoopInstallView_FormClosing`
- `Model.PropertyChanged` -> `Model_PropertyChanged`
- `btnSave.Click` -> `BtnSave_Click`
- `btnCancel.Click` -> `BtnCancel_Click`
- `clbCoopArtifact.SelectedIndexChanged` -> `ClbCoopArtifact_SelectedIndexChanged`
- `cbShowFullCoop.CheckStateChanged` -> `CbShowFullCoop_CheckStateChanged`

画面表示時は `OnFormShown()` -> `LoadView()` -> `controller.LoadCoopFacilityArtifactsData(cbShowFullCoop.Checked)` の順に進む。通常は `cbShowFullCoop.Visible = false` かつ未チェックのため、`showOtherCopFac = false` でロードされる。

`LoadCoopFacilityArtifactsData(bool showOtherCopFac)` は次の処理を行う。

1. `ShowLoading()` でローディング表示にする。
2. `mstCoopFacilityService.GetNewestMstCoopFacilityCtlNoList()` で最新 `MstCoopFacility` の CtlNo 一覧を取得する。
3. `showOtherCopFac == true`、または `ctlNo[0] == '-'` のものだけ `GetMstCoopFacility(CtlNo)` で実体を取得する。
4. 取得した `MstCoopFacilityEntity` を `Description` 昇順でソートし、`Model.CoopFacilityArtifacts` に設定する。
5. 取得失敗時は `ERROR_GET_DATA + ASK_ABORT` を表示し、ユーザーが中断を選ぶと `DialogResult.Abort` で閉じる。

`Model.CoopFacilityArtifacts` が更新されると `Model_PropertyChanged()` から `UpdateCoopFacilityArtifactsView()` が呼ばれる。ここでは `MstCoopFacilityEntity.Description` だけを `CheckedListBox` の `DataSource` に設定し、全項目を未チェックに戻す。

注意点:

- 一覧の表示文字列は `Description` のみ。
- 選択後の保存処理は `CheckedListBox` の表示文字列ではなく、ソート済み `Model.CoopFacilityArtifacts` とチェック済みインデックスで対象 Entity を引く。
- `UpdateCoopFacilityArtifactsView()` はチェック状態を未チェックに戻すが、`btnSave.Enabled` や `Model.SelectedArtifactIndices` を明示初期化していない。

関連箇所:

- `CoopInstallView.cs:44`, `:56`, `:221`, `:229`
- `CoopInstallView.cs:141`, `:189`
- `CoopInstallController.cs:92`, `:99`, `:121`

## 選択状態とボタン制御

`clbCoopArtifact` の選択変更時、`ClbCoopArtifact_SelectedIndexChanged()` は `CheckedIndices` を `List<int>` に変換して `Model.SelectedArtifactIndices` に保持する。

チェック済み件数が 1 件以上なら `btnSave.Enabled = true`、0 件なら `false`。保存ボタンはこの条件だけで有効化され、保存前の確認ダイアログはない。

`btnCancel` は `DialogResult.Cancel` で画面を閉じる。`FormClosing` では `controller.ClearData()` が呼ばれ、`CoopInstallModel.ClearData()` により `Facility`、`CoopFacilityArtifacts`、`SelectedArtifactIndices` が `null` に戻る。

関連箇所:

- `CoopInstallView.cs:95`
- `CoopInstallView.cs:121`
- `CoopInstallView.cs:131`
- `CoopInstallView.cs:75`
- `CoopInstallModel.cs:97`

## 保存ボタン押下後の処理

保存ボタン押下時は `BtnSave_Click()` から `controller.SaveData()` を呼ぶ。`SaveData()` は `async void` で、内部の主要処理は `Task.Run()` 内で同期的に service の `.Result` を呼びながら進む。

### 1. 現在の対象施設設定を取得

最初に対象施設コードで現在の `MstCoopFacility` を取得する。

現在の `MstCoopFacility` が存在する場合のみ、既存の `MstCoopApilink` と `MstCoopIni` も取得して、後続の重複判定・マージ元にする。

関連箇所:

- `CoopInstallController.cs:168`
- `CoopInstallController.cs:188`
- `CoopInstallController.cs:202`

### 2. チェックされたインストール候補からコピー対象を収集

`Model.SelectedArtifactIndices` を順に処理し、対応する `Model.CoopFacilityArtifacts[index]` をコピー元として扱う。

`MstCoopFacility` の扱い:

- 対象施設に `MstCoopFacility` が存在せず、かつ最初の選択候補の場合、コピー元の `MstCoopFacilityEntity` を `JsonClone()` し、`CtlNo = null`、`FacilityCd = 対象施設コード`、`Description = 対象施設コード`、`UserId = ログインユーザー番号` に差し替える。
- それ以外の場合、`mstCoopFacilityEntity.CommonSettingObject` と `IfEdgeSetting` をコピー元候補の値で上書きする。
- 複数候補が選択された場合、`CommonSettingObject` と `IfEdgeSetting` は後続候補の値で上書きされる。`CommonSetting.Merge()` はこの保存処理では使われない。

コピー対象として収集するマスタ:

- `MstCoopDistribute`
- `MstCoopLayout`
- `MstCoopLayoutDetail`
- `MstCoopFilename`
- `MstCoopApilink`
- `MstCoopIni`
- `SysCoopNo`

重複判定:

- `MstCoopApilink` は `IsSimilar()` で既存リストに同等設定がない場合だけ追加する。同等判定キーは `CoopCd`、`CoopCdIndex`、`Crud`、`Direction`、`ApiTimingIo`、`ApiTimingBa`、`ApiTimingSeq`。
- `MstCoopIni` は `Key0`、`Key1`、`Key2` が同じものを重複として追加しない。
- `MstCoopLayout`、`MstCoopLayoutDetail`、`MstCoopDistribute`、`MstCoopFilename`、`SysCoopNo` について、Controller 側では既存対象施設データとの重複判定はしていない。

関連箇所:

- `CoopInstallController.cs:221`
- `CoopInstallController.cs:223`
- `CoopInstallController.cs:229`
- `CoopInstallController.cs:237`
- `CoopInstallController.cs:241`, `:263`, `:285`, `:307`, `:329`, `:348`, `:380`
- `CoopInstallController.cs:336`
- `CoopInstallController.cs:367`
- `MstCoopApilinkEntity.cs:236`
- `MstCoopFacilityEntity.cs:275`

### 3. API で保存

収集後、API へ順に保存する。

保存順:

1. `MstCoopFacility` を `SubmitMstCoopFacility()` で保存。
2. `MstCoopLayout` は各 Entity の `CtlNo = null`、`FacilityCd = 対象施設コード` にして `CreateOrUpdateMstCoopLayout()`。
3. `MstCoopLayoutDetail` も同様に `CtlNo` と `FacilityCd` を差し替えて `CreateOrUpdateMstCoopLayoutDetail()`。
4. `MstCoopDistribute` も同様に `CreateOrUpdateMstCoopDistribute()`。
5. `MstCoopFilename` も同様に `CreateOrUpdateMstCoopFilename()`。
6. `MstCoopApilink` は `CtlNo != null` の既存データをスキップし、追加分だけ `FacilityCd` を差し替えて `SubmitMstCoopApilink()`。
7. `MstCoopIni` がある場合は `FacilityCd` を差し替え、`SetCoopIniInfos()` でマージ後リストを再 JSON 化して `SubmitMstCoopIni()`。
8. `SysCoopNo` は `FacilityCd` を差し替えて `SubmitSysCoopNo()`。

途中で 1 件でも API 結果が `null` または `StatusCode != OK` なら `false` を返す。最後まで成功した場合は `DialogResult.OK` で閉じる。失敗時は `ERROR_DATA_SAVE + ASK_ABORT` を表示し、ユーザーが中断を選ぶと `DialogResult.Abort` で閉じる。

関連箇所:

- `CoopInstallController.cs:399`
- `CoopInstallController.cs:405`
- `CoopInstallController.cs:416`
- `CoopInstallController.cs:428`
- `CoopInstallController.cs:440`
- `CoopInstallController.cs:452`
- `CoopInstallController.cs:468`
- `CoopInstallController.cs:480`
- `CoopInstallController.cs:491`
- `CoopInstallController.cs:507`
- `CoopInstallController.cs:514`

## 利用 API

Service 層のエンドポイント定義は `CoopSettingTool.Service/Constant.cs` にある。

| 対象 | 取得 | 保存 |
| --- | --- | --- |
| `MstCoopFacility` | `linkage_definition/coopFacility/newestCtlNo`, `linkage_definition/coopFacility` | `linkage_definition/coopFacility/submit` |
| `MstCoopLayout` | `linkage_definition/coopLayout/newestCtlNo`, `linkage_definition/coopLayout` | `linkage_definition/coopLayout/submit` |
| `MstCoopLayoutDetail` | `linkage_definition/coopLayoutDetail/newestCtlNo`, `linkage_definition/coopLayoutDetail` | `linkage_definition/coopLayoutDetail/submit` |
| `MstCoopDistribute` | `linkage_definition/coopDistribute/newestCtlNo`, `linkage_definition/coopDistribute` | `linkage_definition/coopDistribute/submit` |
| `MstCoopFilename` | `linkage_definition/coopFilename/newestCtlNo`, `linkage_definition/coopFilename` | `linkage_definition/coopFilename/submit` |
| `MstCoopApilink` | `linkage_definition/mstCoopApilink` | `linkage_definition/mstCoopApilink/submit` |
| `MstCoopIni` | `linkage_definition/coopIni` | `linkage_definition/coopIni/submit` |
| `SysCoopNo` | `sysCoopNo/getByFacility` | `sysCoopNo/submit` |

## 改修時の注意点

- 保存処理は複数 API を順次呼ぶが、Controller 側にトランザクション制御やロールバックはない。途中失敗時は、それ以前の保存が残る可能性がある。
- `SaveData()` と `LoadCoopFacilityArtifactsData()` は `async void`。画面イベントからの呼び出し前提で、呼び出し側が完了待ちや例外捕捉をしにくい。
- `cbShowFullCoop` は表示切替用の実装があるが、Designer では `Visible = false`。画面改修で表示する場合、`showOtherCopFac` のフィルタ条件と一覧再読込時の選択状態初期化を合わせて確認する。
- 一覧再読込時、`SelectedArtifactIndices` と `btnSave.Enabled` は明示的に初期化されていない。表示切替や再読込を追加する場合は、選択状態の残り方を確認する。
- 複数候補選択時、`MstCoopFacility.CommonSettingObject` と `IfEdgeSetting` はマージではなく上書き。複数連携を合成する改修では `CommonSetting.Merge()` の利用可否を検討する。
- Controller 側の重複抑制は `MstCoopApilink` と `MstCoopIni` に限られる。他のマスタは service/API 側の `CreateOrUpdate` 仕様に依存する。
- `MstCoopFacility.Description` は新規作成時に対象施設コードへ置き換えられる。表示名や説明を引き継ぐ改修ではこの代入箇所を変更する必要がある。
