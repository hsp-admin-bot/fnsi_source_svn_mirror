## 個人設定画面へのコンポーネント追加の仕方

### 施設ごとの個人設定タブ定義マスタへのレコード追加

1. 作成するタブのレコードを用意する
   - 施設ごとの個人設定タブ定義マスタ(mst_personal_tab_define)に該当のタブ定義を必要な施設分、insertしてください。タブ定義コード(tab_define_cd)は自動採番されます。
   ```sql
    INSERT INTO mst_personal_tab_define
      (facility_cd, display_name, contents_id, disp_order, is_disp, mode)
    VALUES
      ('009999', 'タブA', 'tab-contents-A', 1, '1', '1')
    ;
   ```
    <table>
      <tr>
        <th>プロパティ</th>
        <th>概要</th>
        <th>設定値</th>
      </tr>
      <tr>
        <td>facility_cd</td>
        <td>施設コードを指定</td>
        <td>文字列</td>
      </tr>
      <tr>
        <td>display_name</td>
        <td>タブ一覧に表示するラベル</td>
        <td>文字列</td>
      </tr>
      <tr>
        <td>contents_id</td>
        <td>独自設定画面の場合のコンポーネントID</td>
        <td>文字列</td>
      </tr>
      <tr>
        <td>disp_order</td>
        <td>タブ一覧の表示順</td>
        <td>数値</td>
      </tr>
      <tr>
        <td>is_disp</td>
        <td>表示フラグ</td>
        <td>'0':非表示,'1':表示</td>
      </tr>
      <tr>
        <td>mode</td>
        <td>モード</td>
        <td>'1':モード1,'2':モード2</td>
      </tr>
    </table>

#### 設定タブのモードについて

設定タブのモードは下記の通りです。
   * モード1: 共通設定タブ。共通設定タブ定義テーブル(`sys_personal_setting_define`)に項目情報を定義することで自動で個人設定画面を生成するモード。
   * モード2: 個別設定タブ。独自に実装した個人設定画面を呼び出すモード。

#### 表示制御について

`is_disp`は対象施設で利用するしない（論理削除か否か）となります。  
ユーザごとに制御したい場合は、共通設定タブ定義テーブルの表示管理レベル(edit_level)で指定します。

独自画面の場合にも、共通設定タブ定義テーブルにレコードを追加してください。 
タブ定義コード(tab_define_cd)と表示管理レベル（edit_level）は必ず指定してください。
その他の設定項目情報、コンボ情報等は定義不要です。

### 共通設定タブ定義テーブルへの定義方法

モード1で個人設定画面を作成する場合について説明します。  
モード1の場合は共通設定タブ定義テーブル(`sys_personal_setting_define`)に、入力部品の情報を定義します。

* タブ定義コード(tab_define_cd): 個人設定タブ定義テーブルに登録した該当のタブ定義コード
* 表示管理レベル(edit_level): 下記のいずれかを指定します
   * 1 : 全てのユーザにタブ一覧に表示
   * 2 : 管理者ユーザのみタブ一覧に表示
   * 3 : 日機装社員のみタブ一覧に表示
   * 4 : 日機装社員 かつ 管理者ユーザのみタブ一覧に表示
   * 上記以外 : タブ一覧から非表示
* 設定項目情報(item_info): 入力部品の情報を定義します.（独自画面の場合は不要）
   <table>
    <tr>
      <th colspan="2">プロパティ</th>
      <th>概要</th>
      <th>設定値</th>
      <th>説明</th>
    </tr>
    <tr>
      <td colspan="2">identifier</td>
      <td>設定項目ID</td>
      <td>文字列</td>
      <td>設定項目を一意にするID</td>
    </tr>
    <tr>
      <td rowspan="4" colspan="2">type</td>
      <td rowspan="4">部品の種類</td>
      <td>"string"</td>
      <td>数値以外のテキスト</td>
    </tr>
    <tr>
      <td>"number"</td>
      <td>数値のテキスト</td>
    </tr>
    <tr>
      <td>"combo1"</td>
      <td>固定値のコンボボックス<br/>(comno_dataの設定必須)</td>
    </tr>
    <tr>
      <td>"combo2"</td>
      <td>参照型コンボボックス<br/>(reference_combo_defの設定必須)</td>
    </tr>
    <tr>
      <td colspan="2">title</td>
      <td>ラベル</td>
      <td>文字列</td>
      <td>入力部品のラベルを指定</td>
    </tr>
    <tr>
      <td colspan="2">validation</td>
      <td>バリデーション</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>required</td>
      <td>必須</td>
      <td>true</td>
      <td>未指定時はfalse</td>
    </tr>
    <tr>
      <td></td>
      <td>maxlength</td>
      <td>最大桁数</td>
      <td>数値</td>
      <td>任意</td>
    </tr>
    <tr>
      <td></td>
      <td>max</td>
      <td>最大値</td>
      <td>数値</td>
      <td>数値型の場合に有効。任意</td>
    </tr>
    <tr>
      <td></td>
      <td>min</td>
      <td>最小値</td>
      <td>数値</td>
      <td>数値型の場合に有効。任意</td>
    </tr>
    <tr>
      <td></td>
      <td>digit</td>
      <td>小数点以下の桁数</td>
      <td>数値</td>
      <td>数値型の場合に有効。任意</td>
    </tr>
  </table>
* 固定コンボデータ(combo_data): 設定項目情報にて固定コンボ(combo1)を指定した場合に必ず定義します.（独自画面の場合は不要）
   <table>
    <tr>
      <th colspan="2">プロパティ</th>
      <th>概要</th>
      <th>設定値</th>
    </tr>
    <tr>
      <td colspan="2">combos</td>
      <td>先頭に必ず指定</td>
      <td></td>
    </tr>
    <tr>
      <td colspan="2">setting_identifier</td>
      <td>定義元の設定項目ID</td>
      <td>文字列</td>
    </tr>
    <tr>
      <td colspan="2">values</td>
      <td>ドロップダウンリストの情報を指定</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>text</td>
      <td>optionに指定するラベル</td>
      <td>文字列</td>
    </tr>
    <tr>
      <td></td>
      <td>value</td>
      <td>optionに指定するvalue</td>
      <td>any</td>
    </tr>
  </table>
* 参照型コンボデータ(reference_combo_def): 設定項目情報にて参照型コンボ(combo2)を指定した場合に必ず定義します.（独自画面の場合は不要）
  <table>
    <tr>
      <th colspan="2">プロパティ</th>
      <th>概要</th>
      <th>設定値</th>
    </tr>
    <tr>
      <td colspan="2">combos</td>
      <td>先頭に必ず指定</td>
      <td></td>
    </tr>
    <tr>
      <td colspan="2">setting_identifier</td>
      <td>定義元の設定項目ID</td>
      <td>文字列</td>
    </tr>
    <tr>
      <td colspan="2">target_table</td>
      <td>参照先のテーブル情報</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>name</td>
      <td>参照テーブルの物理名</td>
      <td>文字列</td>
    </tr>
    <tr>
      <td></td>
      <td>identifier</td>
      <td>参照テーブルのプライマリキーとなる列の物理名</td>
      <td>文字列</td>
    </tr>
    <tr>
      <td></td>
      <td>display_column</td>
      <td>ドロップダウンリストで表示する参照テーブルの列の物理名</td>
      <td>文字列</td>
    </tr>
    <tr>
      <td></td>
      <td>referenced_column</td>
      <td>ドロップダウンリストで値とする参照テーブルの列の物理名</td>
      <td>文字列</td>
    </tr>
  </table>

### コンポーネント作成（モード2の場合のみ）

1. タブを押下された時に表示するコンポーネントを作成する
1. `views/modals/PersonalSettingsView.vue`に、1.で作成したコンポーネントをimportする。
   ```js
    components: {
      "modal-base": ModalBase,
      "tab-contents-A": () =>
        import("@/components/modals/personal-setting/SampleA") // import
    },
   ```
### 個人設定画面で入力された個人設定値の保存先について

個人設定画面で入力された内容は、利用者マスタのユーザ設定(user_settings)に格納されます.  
あらかじめ初期値を設定したい場合は、利用者マスタに初期値を定義してください.  
(設定値自体がなくてもnull扱いで初期表示されます)

```json
personal_settings: [
  {
    tab_define_cd: number // mst_personal_tab_define.tab_define_cd,
    values: [
      {
        setting_identifier: string,
        value: any
      },...
    ]
  },...
]
```
### サンプル

#### 設定項目情報(item_info)
```json
{
    "item_info": [
        {
            "type": "string",
            "title": "項目3-1",
            "identifier": "1",
            "validation": {
                "required": true,
                "maxlength": 4
            }
        },
        {
            "type": "number",
            "title": "項目3-2",
            "identifier": "2",
            "validation": {
                "max": 5000,
                "min": 10
            }
        },
        {
            "type": "combo1",
            "title": "項目3-3",
            "identifier": "3",
            "validation": {
                "required": true
            }
        },
        {
            "type": "combo1",
            "title": "項目3-4",
            "identifier": "4"
        }
    ]
}
```
#### 固定コンボデータ(combo_data)

```json
{
    "combos": [
        {
            "values": [
                {
                    "text": "データ1",
                    "value": 1
                },
                {
                    "text": "データ2",
                    "value": 2
                },
                {
                    "text": "データ3",
                    "value": 3
                },
                {
                    "text": "データ4",
                    "value": 4
                },
                {
                    "text": "データ5",
                    "value": 5
                }
            ],
            "setting_identifier": "3"
        }
    ]
}
```

#### 参照型コンボデータ(reference_combo_def)
```json
{
    "combos": [
        {
            "target_table": {
                "name": "mst_treatment",
                "identifier": "treatment_cd",
                "display_column": "treatment_name",
                "referenced_column": "treatment_cd"
            },
            "setting_identifier": "4"
        }
    ]
}
```