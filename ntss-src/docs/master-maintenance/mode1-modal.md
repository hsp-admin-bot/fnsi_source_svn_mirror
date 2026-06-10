## マスタメンテナンス モーダル画面について
マスタメンテ用モーダル画面については、モード1と共通化されています。  
モード1にモーダル画面表示用ボタンを定義することで、モーダル画面への遷移を実現できます。

※ モードについては[マスタメンテについて](about-master-maintenance.md)を参照

### モーダル画面表示用ボタン定義方法
マスタ定義テーブルのカラム情報（`sys_master_define.column_info`）に下記を設定します。（`hoge`:任意のタイトル）
```
{"type": "modal", "title": "hoge"}
```

## マスタメンテ用モーダル画面の構成概要
マスタメンテ用モーダル画面は、
* ヘッダーコンポーネント
* メインコンポーネント

の要素で構成されているページとなっています。  
各社にてヘッダーコンポーネントとメインコンポーネントを作成し、 画面描画時にコンポーネントを差し替えることで中身のコンテンツが置き換わることを想定した作りとなっています。  
ヘッダーコンポーネントの作成・インポートは任意です。ヘッダーコンポーネントを作成しない場合は、空のコンポーネントが描画されます。
メインコンポーネントは必ず作成・インポートしてください。
以下を参考にマスタメンテ用モーダル画面コンポーネントを作成してください。

## マスタ用モーダル画面コンポーネント作成手順

```
frontend/src
├── components
│   ├── master-maintenance
│   │   ├── ヘッダーコンポーネントとメインコンポーネントを配置するディレクトリ（マスタごとに作成してください。）
│   │   ├── IndividualMasterHeaderComponent.vue
│   │   ├── MasterEditModalHeaderComponent.vue
│   │   ├── MasterListComponent.vue
│   │   ├── MasterListHeaderComponent.vue
│   │   ├── MasterRecordComponent.vue
│   │   └── MasterRecordHeaderComponent.vue
├── views
│   ├── master-maintenance
│   │   ├── IndividualMasterView.vue
│   │   ├── MasterEditModal.vue ← ヘッダーコンポーネントとメインコンポーネントをインポートする.vueファイル
│   │   ├── MasterEditModalBase.vue
```

### １．コンポーネントを配置するディレクトリの作成
frontend/src/components/master-maintenance 直下にディレクトリを作成してください。<br>
※ディレクトリ名は、マスタの物理名をケバブケースに変換した名前にしてください。<br>
（ケバブケースとは https://wa3.i-3-i.info/word16380.html ）<br>
例: mst_example → mst-example

### 2．ヘッダーコンポーネントの作成
上記１．で作成したディレクトリ に`.vue`ファイルを作成します。<br>
※コンポーネントファイル名は任意です。<br>
※ヘッダーコンポーネントを作成しない場合は空のコンポーネントが表示されます。

### 3．メインコンポーネントの作成
上記１．で作成したディレクトリ に`.vue`ファイルを作成します。<br>
※コンポーネントファイル名は任意です。<br>
※実装については下記の「Storeの仕様」を参考にしてください。

### 4．コンポーネントのインポート
差し替え対象のコンポーネント（上記2．3で作成したコンポーネント）を  
予めマスタメンテ用モーダル画面コンポーネントとして定義しておきます。<br>
以下のようにインポートします。<br>
定義場所：frontend/src/views/master-maintenance/MasterEditModal.vue

```js
components: {
    "bread-crumbs-component": BreadCrumbsComponent,
    "default-header": HeaderComponent,
    "mst-hoge": () => import("@/components/master-maintenance/mst-hoge/MstHogeMainModalComponent"),
    "mst-fuga": () => import("@/components/master-maintenance/mst-fuga/MstFugaMainModalComponent"),
    "mst-fuga-header": () => import("@/components/master-maintenance/mst-fuga/MstFugaMainModalComponentHeader")
  },
```
※コンポーネント名をキーに部品の差し替えを行います。

### コンポーネントのname要素命名規約
ケバブケースで定義します。（ケバブケースとは https://wa3.i-3-i.info/word16380.html ）
* ヘッダーコンポーネント
  - マスタ物理名称＋ `-header`
* メインコンポーネント
  - マスタ物理名称

例
```js
    components: {
    //   Headerページ：テーブル物理名＋_header（例：mst_hoge_header）
           "mst-hoge-header": () => import("@/components/master-maintenance/mst-hoge/MasterModalComponentMstHogeHeader"),
    //   Mainページ：テーブル物理名（例：mst_hoge）
           "mst-hoge": () => import("@/components/master-maintenance/mst-hoge/MasterModalComponentMstHoge")
    }
```

## Storeの仕様

ヘッダーコンポーネント、メインコンポーネント内で「マスタ一覧で選択されたマスタの物理名」や「マスタ編集画面のグリッドで選択されたデータ」等への
アクセスはStore経由で行ってください。

以下にStoreの仕様を解説します。以下で解説されているもの以外の状態については利用しないようお願いいたします。

### Store.state一覧

```js
{
  selectedMasterName: string  ← マスタ一覧画面で選択されたマスタの物理名
  editRecord: object,         ← マスタ編集画面のグリッドで、「詳細」ボタンで選択されたオブジェクト
  schema: object,             ← マスタ編集画面のグリッドに表示するデータの構造を表現する情報
  columns: array              ← マスタ編集画面のグリッドの構成を表現する情報
}
```

### Store.getters一覧

```js
{
  getMasterName, ← state.selectedMasterNameを取得する
  getSchema,     ← state.schemaを取得する
  getColumns,    ← state.columnsを取得する
  getEditRecord  ← state.editRecordを取得する
}
```

### Store.actions一覧

```js
{
  setEditRecord ← state.editRecordにオブジェクトを保存する。
}
```

1. state.selectedMasterName
- マスタ一覧画面で選択されたマスタの物理名  
- getters.getMasterNameで取得する。  

2. state.columns  
```
state.columns: [
  {
    field: string（カラムの物理名をキャメルケースに変換したもの）,
    format: string（kendoUIで表示するためのフォーマット）,
    hidden: boolean（true: グリッド上は描画されない）,
    locked: boolean（true: グリッド上固定列となる）,
    originalEditable: boolean（true: グリッド上で編集できる）,
    title: string（グリッドのヘッダーに表示する名前）,
    values: null
  }
]
```
- マスタ編集画面のグリッドの構成を表現する情報
- getters.getColumnsで取得する。  

3. state.schema
```
state.schema: {
  model: {
    fields: {
      field（実際はカラムの物理名をキャメルケースに変換したもの）: {
        type: "string" or "number" or "date" or "json",
        validation(optional): {
          maxlength: number,
          max: number,
          min: number,
          required: boolean
        }
      }
    }
  },
  id: string
}

```
- マスタ編集画面のグリッドに表示するデータの構造を表現する情報
- getters.getSchemaで取得する。  

4. state.editRecord
```
state.editRecord: {
  key（実際はカラムの物理名をキャメルケースに変換したもの）: value
}
```
- マスタ編集画面のグリッドで、「詳細」ボタンで選択されたオブジェクト  
- sys_master_define.column_infoでhidden: trueに設定されている要素も含む  
- メインコンポーネントでは、state.editRecordを操作する。<br>（ ***注意*** state.editRecordを編集後の状態にしないと、マスタ編集画面のグリッドに反映されず、DBに永続化もされない）  
- getters.getEditRecordで取得する。  
- actions.setEditRecordで保存する。  
- state.editRecord中のプロパティの型について  
  - string → 取得される時: string、保存する時: string  
  - number → 取得される時: number、保存する時: number  
  - date → 取得される時: string フォーマット: ISO 8601(YYYY-MM-DDTHH:mm:ss.sss)<br>保存する時: string フォーマット: ISO 8601(YYYY-MM-DDTHH:mm:ss.sss)  
  - json → 取得される時: string、保存する時: string

## state.editRecordに定義されているが、差し替え先で操作しないプロパティ
以下のプロパティはシステムのみが利用するものなので、差し替え先のコンポーネントでは操作しないでください。  
- sortInputTime  
- operation  
- allowAddRecord  
- allowSort  
- isDel  
- code  
- $modalType  
- sortRank  

## コンポーネントのサンプルコード

ヘッダーコンポーネント

#### MasterModalComponentMstTestTableHeader.vue

```js
<template>
  <div>
    <span>MstTestTableHeader</span>
  </div>
</template>

<script>
export default {
  name: "MstTestTableHeader"
};
</script>

<style>
</style>
```

メインコンポーネント

#### MasterModalComponentMstTestTable.vue

```js
<template>
  <div>
    <table>
      <thead>
        <tr>
          <template v-for="(column, index) in normalizedColumnDefinition">
            <th v-if="!validationField(column.field)" :key="index">
              <span>{{ column.title }}</span>
            </th>
          </template>
        </tr>
      </thead>
      <tbody>
        <tr>
          <template v-for="(column, index) in normalizedColumnDefinition">
            <td v-if="!validationField(column.field)" :key="index">
              <div v-if="getSchemaByField(column.field).type === 'string'">
                <input type="text"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
              <div v-else-if="getSchemaByField(column.field).type === 'json'" >
                <input type="text"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
              <div v-else-if="getSchemaByField(column.field).type === 'number'">
                <input type="number"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
              <div v-else-if="getSchemaByField(column.field).type === 'date'">
                <input type="date"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
            </td>
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";

export default {
  name: "MstTestTable",
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    normalizedColumnDefinition() {
      // データの定義にあわせてcolumnを正規化する。
      const recordKeys = Object.keys(this.editRecord);
      return this.columnDefinition.filter(cd => recordKeys.includes(cd.field));
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },
    updateEditRecord(key, ev) {
      this.editRecord[key] = ev.target.value;
      this.setEditRecord(this.editRecord);
    },
    validationField(field) {
      return [
        "sortInputTime",
        "operation",
        "allowAddRecord",
        "allowSort",
        "isDel",
        "code",
        "$modalType",
        "sortRank"
      ].some(el => el === field);
    }
  }
};
</script>

<style scoped>
table {
  border-collapse: collapse;
}
table th,
table td {
  border: solid 1px black;
}
</style>
```

上記を利用すると、マスタを編集するモーダル画面が表示されます。
