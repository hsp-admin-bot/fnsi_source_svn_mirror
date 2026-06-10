/**
 * 個人設定タブ - 共通設定タブのコンポーネント
 */
 <template>
  <div class="common-tab-area">
    <div class="common-tab-content" :style="heightStyles">
      <v-ons-row class="tab-item" v-for="item in defineItem.item_info" :key="item.identifier">
        <template v-if="isNumber(item.type)">
          <v-ons-col>
            <com-number-input
              :labelName="item.title"
              :input-id="item.identifier"
              :name="item.identifier"
              :step="getNumberStep(item)"
              :min="item.validation.min"
              :max="item.validation.max"
              v-model="personalSettings[item.identifier]"
            />
          </v-ons-col>
        </template>
        <template v-else>
          <v-ons-col class="item-title">{{ item.title }}</v-ons-col>
          <v-ons-col v-if="isCombo(item.type)">
            <v-ons-select :name="item.identifier" v-model="personalSettings[item.identifier]">
              <option
                v-for="data in getComboData(item.identifier)"
                :key="data.value"
                :value="data.value"
              >{{ data.text }}</option>
            </v-ons-select>
          </v-ons-col>
          <v-ons-col v-else>
            <v-ons-input
              class="item-input"
              :input-id="item.identifier"
              :name="item.identifier"
              :maxlength="item.validation.maxlength"
              v-model="personalSettings[item.identifier]"
            />
          </v-ons-col>
        </template>
      </v-ons-row>
    </div>
    <div class="common-tab-footer">
      <v-ons-row width="100%">
        <v-ons-col width="50%">
          <v-ons-button class="button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="button registration-btn"
            style="width: auto;"
            :disabled="!isChanged"
            @click="save"
          >保存</v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

 <script>
import { mapActions, mapGetters } from "vuex";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "com-number-input": CommonNumberInputComponent
  },
  data() {
    return {
      // gridの高さ
      contentsAreaHeight: 200,
      // 設定項目の定義
      defineItem: {
        item_info: []
      },
      // 入力内容
      personalSettings: {},
      // 初期表示時の値
      initData: "{}"
    };
  },
  methods: {
    ...mapActions("personal-setting", [
      "getPersonalSettingsDefine",
      "getPersonalSettings",
      "updatePersonalSettings"
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    ...mapActions("multi-modal", ["hideModal"]),
    /**
     * キャンセルボタンクリックイベント処理.
     */
    cancel() {
      if (!this.isChanged) {
        this.hideModal();
        return;
      }

      this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) await this.hideModal();
        }
      });
    },
    /**
     * 保存ボタンクリックイベント処理.
     */
    /* eslint-disable no-unused-vars */
    save() {
      // 必須（required=true）かつ値が入力されていなければ、ダイアログを表示する
      const identifiers = Object.entries(this.personalSettings)
        .filter(e => this.isRequired(e[0]) && !e[1] && e[1] !== 0)
        .map(e => e[0]);

      if (identifiers.length > 0) {
        const itemNames = this.defineItem.item_info
          .map(e =>
            identifiers.includes(e.identifier)
              ? `</br>&nbsp&nbsp・${e.title}`
              : null
          )
          .filter(e => e !== null);

        return this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: `<div style="text-align:left;">以下の項目が未入力です。 ${itemNames.join(
          //   ""
          // )}</div>`
          title: DIALOG_MESSAGES['00200111'].title,
          message: `<div style="text-align:left;">${messageFormat(DIALOG_MESSAGES['00200111'].message)}${itemNames.join(
            ""
          )}</div>`
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      }

      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // 設定内容をパラメータに格納
      const param = {
        tab_define_cd: this.tabDefineCd,
        values: Object.keys(this.personalSettings).map(key => {
          return {
            setting_identifier: key,
            value: this.personalSettings[key]
          };
        })
      };
      // 利用者マスタに保存
      this.updatePersonalSettings(param)
        .then(response => {
          this.$ons.notification
            .alert({
              title: "設定完了",
              message: "設定が完了しました。"
            })
            .then(() => this.hideModal());
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PersonalSettingComponent.vue', 'save', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            this.$ons.notification
              .alert({
                title: "設定に失敗しました。",
                message: error.response.data.errorMessage
              })
              .then(() => this.hideModal());
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    /**
     * 初期処理.
     */
    async init() {
      // クリア
      this.defineItem = {
        item_info: []
      };
      this.personalSettings = {};

      // 指定のタブ定義に紐づく設定項目と保存されている個人設定値を取得
      await this.fetchTabDefine();

      // 指定のタブ定義で入力した個人設定値を取得する
      await this.fetchPersonalSetting();
    },
    /**
     * タブ定義コードより設定項目情報を取得する.
     */
    async fetchTabDefine() {
      const response = await this.getPersonalSettingsDefine(this.tabDefineCd);
      this.defineItem = response.data;
    },
    /**
     * タブ定義コードより個人設定値を取得する.
     */
    async fetchPersonalSetting() {
      const response = await this.getPersonalSettings(this.tabDefineCd);
      if (response.data.length === 0) {
        // 設定値なしの場合は定義情報より初期値を格納する
        this.personalSettings = this.defineItem.item_info.reduce(
          (item, current) => {
            item[current.identifier] = null;
            return item;
          },
          {}
        );
      } else {
        this.personalSettings = response.data.reduce((item, current) => {
          item[current.setting_identifier] = current.value;
          return item;
        }, {});
      }
      // 編集前の値を保存
      this.initData = JSON.stringify(this.personalSettings);
    },
    /**
     * 指定された識別子の項目が入力必須であるかどうかを返す。
     * true: 必須である、false: 必須でない
     */
    isRequired(identifier) {
      const validation = this.defineItem.item_info.find(item => {
        return item.identifier === identifier;
      }).validation;

      return validation === null ? false : validation.required;
    },
    /**
     * 指定の設定項目のタイプが数値かどうか返す.
     * @param type 設定項目のタイプ
     */
    isNumber(type) {
      return type === "number";
    },
    /**
     * 指定の設定項目のタイプがコンボボックスかどうか返す.
     * @param type 設定項目のタイプ
     */
    isCombo(type) {
      return type.indexOf("combo") >= 0;
    },
    /**
     * 指定の設定項目IDのコンボデータを取得する.
     * @param settingIdentifier 設定項目ID
     */
    getComboData(settingIdentifier) {
      const data = this.defineItem.combo_data.find(
        e => e.setting_identifier === settingIdentifier
      );
      if (data) {
        if (this.isRequired(settingIdentifier)) {
          return data.values;
        }
        // 必須設定なしの場合は未選択肢を追加
        return [{ text: "", value: null }].concat(data.values);
      }
      return [];
    },
    /**
     * 数値項目に対する小数点のstepを返す.
     */
    getNumberStep(item) {
      if (item.hasOwnProperty("validation")) {
        if (item.validation.hasOwnProperty("digit")) {
          return 1 / Math.pow(10, item.validation.digit);
        }
      }
      return 1;
    },
    /**
     * Gridの高さを調整する
     */
    calculateGridHeight() {
      const contentsHeight = document.getElementsByClassName(
        "tab-contents-area"
      )[0].clientHeight;
      const footerHeight = document.getElementsByClassName(
        "common-tab-footer"
      )[0].clientHeight;
      this.contentsAreaHeight = contentsHeight - footerHeight - 10;
    }
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("personal-setting", {
      tabDefineCd: "getSelectedTabDefineCd"
    }),
    /**
     * コンテンツの高さをCSS変数を利用して書き換える
     */
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
    /**
     * 初期表示時と比較して変更が入っているかどうか返す.
     */
    isChanged() {
      const input = JSON.stringify(this.personalSettings);
      return this.initData !== input;
    }
  },
  watch: {
    /**
     * ウィンドウサイズが変更された時の処理.
     */
    windowHeight() {
      this.calculateGridHeight();
    },
    /**
     * タブ定義コードが変更された時の処理.
     */
    async tabDefineCd() {
      await this.init();
    }
  },
  async created() {
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");

    await this.init();
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  }
};
</script>

 <style scoped>
.common-tab-area {
  margin: 5px;
}
@media print {
  .common-tab-area, .common-tab-content {
    height: auto !important;
  }
}
@media screen and (max-width: 480px) {
  .common-tab-area {
    font-size: 1.1em; /* ベースのサイズ確認要 */
  }
}
.common-tab-content {
  border-bottom: none;
  overflow-y: auto;
}
.common-tab-footer {
  margin: 5px;
}
.right {
  text-align: right;
}
.common-tab-content >>> .text-input,
.common-tab-content >>> select {
  font-size: 1em;
}
.common-tab-content >>> ons-row {
  height: auto;
}
.common-tab-content >>> .tab-item {
  margin-bottom: 5px;
}
.item-input {
  width: 95%;
}
.item-title,
.tab-item >>> ons-col.title {
  flex: 0 0 33%;
  max-width: 33%;
}
.common-tab-content >>> select {
  border: solid 1px var(--personal-setting-select-border-color);
}
</style>
