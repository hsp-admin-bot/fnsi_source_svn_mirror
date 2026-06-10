# クライアント側の機能毎の権限制御について
- 各社様にて対応して頂く内容として、下記の通りでの対応が必要となります。
    - import文の追加
    - mixinへの追加
    - 権限コードの設定追加

## 各コンポーネントの対応について

### ESMでの対応について
1. 権限コードの定数用のファイル(`@/constants/userAuthority`)を追加します。
1. 権限で入力部品を活性／非活性を制御する共通処理(`@/components/common/UserAuthorityMixin`)を追加します。
1. コンポーネント単位でガードを入れて(`@/components/common/ComponentGuardMixin`)、権限制御（入力部品の活性/非活性処理）を実行します。
1. 対象とする入力部品は下記の通りです。
    ```javascript
    // 操作制御するTAG名
    const TARGET_TAGS = [
      "ons-input",
      "ons-select",
      "ons-radio",
      "ons-checkbox",
      "ons-button",
      "input",
      "select",
      "checkbox",
      "textarea",
      "button"
    ];
    ```

### 各社様での対応について
1. Mixinファイル及び定数ファイルの定義を追加します。  
  (1) コンポーネント単位のガードで権限制御を入れる場合
    ```javascript
    import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
    import { AUTHORITY_CODES } from "@/constants/userAuthority";

    export default {
        mixins: [ComponentGuardMixin], 
        // (省略)
    ```

   (2) 任意のタイミングで制御を入れる場合

    ```javascript
    import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
    import { AUTHORITY_CODES } from "@/constants/userAuthority";

    export default {
        mixins: [UserAuthorityMixin], 
        // (省略)
    ```

2. 権限制御を行いたいコンポーネントに下記を追加します。
    ```javascript
    export default {
        // (省略)
        data() {
            // (省略)
            // 対象とする権限コードを配列で指定
            return {
                authorityCds:[ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ]
            };
        }
    }
    ```
2. その他不足している入力部品や定義コードがあった場合に追加します。
   * 権限コードが新しく追加された場合 ==> `@/constants/userAuthority`　に定義を追加します。
   * 制御する入力部品を追加する場合 ==> `@/components/common/UserAuthorityMixin`　の`TARGET_TAGS`に定義を追加します。


### 権限制御から除外したい入力部品について
- `data-non-authorize` 属性で`true`を指定する事で権限制御から除外します。
    ``` html
    <v-ons-input data-non-authorize="true" type="text" ・・・ />
    ```
    ※`data-non-authorize=true` が登録されている入力部品は権限による活性／非活性の対象外となります。<br>
    ※定義がなければデフォルト`false`として扱われます。

# モーダル画面の対応について

## ESMでの対応について
1. 下記のファイルにimport文及びmixin追加を行います。
    - ntss-admin-web\src\main\frontend\src\components\modals\ModalBase.vue
1. 対象とする入力部品は下記の通りです。  
※下記のタグに含まれてはいませんが、`v-ons-segment`も対象となっています。（後述の注意事項を参照）
)
    ```javascript
    // 操作制御するTAG名
    const TARGET_TAGS = [
      "ons-input",
      "ons-select",
      "ons-radio",
      "ons-checkbox",
      "ons-button",
      "input",
      "select",
      "checkbox",
      "textarea",
      "button"
    ];
    ```

## 各社様での対応について
- 下記のファイルにモーダル画面の入力部品を制御する為の処理を追記して頂きます。
    - ntss-admin-web\src\main\frontend\src\stores\modals\MultiModalStore.js
        ``` javascript
        showAccountEdit({ commit }) {
            commit("setModal", "AccountEdit");
            commit("setTitle", "アカウント編集");
            commit("setAuthorityCds", [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ]); // ここを追加
        },
        ```
    ※`setAuthorityCds` は固定とし、モーダルに対する権限コードを指定します。<br>
    ※権限制御が不要なモーダルには追加する必要はございません。

## 補足
1個のモーダルを複数個所から呼び出していてかつ、呼出元によって権限が異なる場合、呼出側より権限コードを指定する必要があります。
- モーダルを開く時に各機能で許可する権限コードを引き渡して`MultiModalStore`に格納します。
- 権限コードは `@/constants/userAuthority` に定数化(const)してあるので、こちらも各コンポーネントでimportして利用して下さい。<br>
    ＜呼び出し側＞ ※サンプル
    ```javascript
    import { AUTHORITY_CODES } from "@/constants/userAuthority";

    export default {
        data() {
            return {
            authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ]
            };
        }
    }

    // モーダル表示
    this.showTreatmentRecordWeightInput({ title: "モーダルタイトル", authorityCds: this.authorityCds });
    ```

    ＜MultiModalStore.js側＞
    ```javascript
    showTreatmentRecordWeightInput({ commit }, {title, authorityCds}) {
        commit("setModal", "TreatmentRecordWeightInput");
        commit("setTitle", title);
        commit("setAuthorityCds", authorityCds); // ここを追加
    },
    ```

# 注意事項
### data-non-authorize属性
`v-ons-segment` を使用している場合、実際にノード展開される部品構造はbutton+input(radio)になります。<br>
親要素に`data-non-authorize`をつけたとしても子要素のinputはその属性を引き継がないため、子要素のinputはdisabled対象となってしまいます。<br>
つまり、親の部品の属性で活性非活性を判定してもらう必要が出てきます。  
※`v-ons-segment` に限らず、展開される場合に親子関係となる部品が対象です。

`components/common/UserAuthorityMixin.js` に以下の対応策を実装いたしました。  
現状、ESM側で影響のあった２つの部品(`v-ons-segment`,`v-ons-select`)についてのみ回避の実装を入れましたので、同じようなケースが発生した場合には、`UserAuthorityMixin.js`に実装を追加してください。  

```javascript
    /**
     * 利用者権限対象を判定する部品を返します.
     * 自分自身以外の部品で判定する場合にはこちらに定義を追加すること.
     * @param {*} element 対象の入力部品
     * @returns true - 親要素の権限
     */
    getTargetElement(element) {
      // v-ons-segment の場合親要素のボタンで非活性制御を決定
      if (element.type === "radio" && element.className === "segment__input") {
        const parent = element.closest(".segment__item");
        if (parent) {
          return parent;
        }
      }
      // v-ons-select の場合親要素のボタンで非活性制御を決定
      if (element.tagName === "SELECT") {
        const parent = element.closest(".select");
        if (parent) {
          return parent;
        }
      }
      // 上記以外は指定部品自身で決定する
      return element;
    }
```

### Tableなど動的に作成されるDOM上に入力部品を展開している場合

活性非活性対象とする入力部品がTABLEなど動的に作成される場合にはDOM上まだ生成されていないため、コンポーネント単位のガードでは権限制御できません。  
この場合は、コンポーネント単位ガードとは別に個別（確実にDOM上で展開されたとするタイミング）で権限制御を入れる必要があります。  
この権限制御を入れるべきタイミングは、各機能により様々ですので各社対応でお願いいたします。

各コンポーネント対応についての、(2) 任意のタイミングで制御を入れる場合、を参考にして`UserAuthorityMixin#disableElement(this.$el)`を利用してください。

### 制御対象の入力部品にすでにdisabled制御を入れている場合

活性非活性制御で`disabled=true`とした入力部品について、対象画面にて`disabled`を決定する評価結果が`false`としてしまい、非活性にならないケースがあるかと思います。  
そのため`disabled`を決定する条件に`権限があるかどうか`を別途加える必要があります。  
`UserAuthorityMixin`の`computed`に`authorized`プロパティを定義してありますので、そちらを使ってください。  
*これをmixinする各コンポーネントで`authorityCds`を上書き定義していることが前提です。

```javascript
export default {
  data() {
    return {
      authorityCds: null
    }
  },
  computed: {
    authorized() {
      return this.hasAuthority();
    }
  },
  methods: {
    ...(省略)
    /**
     * 指定の権限コードが利用者権限に含まれているかどうか返します.
     */
    hasAuthority() {
      // 利用者権限情報を取得
      const userAuthorityCds = this.getUserAuthorityCds();
      return this.authorityCds.some(cd => {
        // 利用者権限情報に、指定の権限コードが１つでも含まれていればOK
        return userAuthorityCds.includes(cd);
      });
    },
  }
```
