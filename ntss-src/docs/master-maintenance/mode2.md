## 独自編集するマスタについて
ある程度共通化が図れるマスタ(単純なマスタ)については汎用的なマスタメンテ画面(一覧編集)を利用する想定ですが  
汎用的なマスタメンテナンス画面での吸収が難しい特別なマスタについては  
各社にて`独自編集マスタ`として該当マスタのメンテナンス画面を作成することになっています。   
※枠組みは共通化するため下記構成としています

## 独自編集マスタの構成概要

独自編集マスタは、
* ヘッダーコンポーネント
* パンくずコンポーネント
* メインコンポーネント

の要素で構成されているページとなっています。  
各社にてメインコンポーネントとヘッダーコンポーネントを作成し、画面描画時にコンポーネントを差し替えることで中身のコンテンツが置き換わることを想定した作りとなっています。  
ヘッダーコンポーネントの作成・インポートは任意です。ヘッダーコンポーネントを作成しない場合は、空のコンポーネントが描画されます。  
メインコンポーネントは必ず作成・インポートしてください。  
以下を参考に独自編集マスタ用コンポーネントを作成してください。  

## 独自編集マスタの作成手順

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
│   │   ├── IndividualMasterView.vue ← ヘッダーコンポーネントとメインコンポーネントをインポートする.vueファイル
│   │   ├── MasterEditModal.vue
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

### 4．コンポーネントのimport
差し替え対象のコンポーネント（上記2．3で作成したコンポーネント）を  
予め独自編集マスタページのコンポーネントとして定義しておきます。<br>
以下のようにインポートします。<br>
　定義場所：/src/views/master-maintenance/IndividualMasterView.vue

```js
components: {
    "bread-crumbs-component": BreadCrumbsComponent,
    "default-header": HeaderComponent,
    "mst-hoge": () => import("@/components/master-maintenance/MstHogeMainComponent"),
    "mst-fuga": () => import("@/components/master-maintenance/MstFugaMainComponent"),
    "mst-fuga-header": () => import("@/components/master-maintenance/MstFugaMainComponentHeader")
  },
```
※コンポーネント名をキーに部品の差し替えを行います。

### 独自編集マスタコンポーネントのname要素命名規約
ケバブケースで定義します。（ケバブケースとは https://wa3.i-3-i.info/word16380.html ）
* ヘッダーコンポーネント
  - マスタ物理名称＋ `-header`
* メインコンポーネント
  - マスタ物理名称

例
```js
    components: {
    //   Headerページ：テーブル物理名＋_header（例：mst_hoge_header）
           "mst-hoge-header": () => import("@/components/master-maintenance/MasterComponentMstHogeHeader"),
    //   Mainページ：テーブル物理名（例：mst_hoge）
           "mst-hoge": () => import("@/components/master-maintenance/MasterComponentMstHoge")
    }
```

## ストアの作成
ヘッダーコンポーネントやメインコンポーネントで状態管理が必要な場合は、各々のマスタでストアを作成します。  
（`MasterMaintenanceStore.js` を拡張しないでください）

**ストア追加イメージ**
```js
index.js
MasterMaintenanceStore.js
mst_hoge用Store.js
mst_huga用Store.js
  ・
  ・
  ・
```

ストアファイル作成後、vue生成時に作成したストアファイルが読み込まれるように、  
`stores > master-maintenance > index.js`にストアファイル名を追記します。  

**追記イメージ**
```js
import MasterMaintenanceStore from "@/stores/master-maintenance/MasterMaintenanceStore";
import mst_hoge用Store from "@/stores/master-maintenance/mst_hoge用Store";

export const MASTER_MAINTENANCE_STORES = {
  "master-maintenance": MasterMaintenanceStore,
  "mst-hoge": mst_hoge用Store
};

```
