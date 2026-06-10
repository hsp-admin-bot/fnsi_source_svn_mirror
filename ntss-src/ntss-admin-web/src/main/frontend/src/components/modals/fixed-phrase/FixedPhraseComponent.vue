/**
 * 個人設定タブ - 定型文タブのコンポーネント
 */
 <template>
  <div class="common-tab-area">
    <div class="common-tab-content" :style="heightStyles" ref="contentArea">
      <v-ons-list modifier="inset" style="height: auto;">
        <v-ons-list-header>定型文</v-ons-list-header>
        <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
          <div>
            <div class="flex">
              <div class="col-del"/>
              <div class="col-handle"></div>
              <div class="col-no">No</div>
              <div :style="contentWidthStyles">内容</div>
            </div>
            <draggable
              v-model="fixedPhraseList"
              :options="{ ...dragOptions, handle: '.drag-handle' }"
              @choose="isDraggingCategory = true"
              @end="onMoveCallback"
            >
              <div v-for="(phrase, index) in fixedPhraseList" class="flex" :key="phrase.identifier">
                <ons-toolbar-button @click="deletePhrase(index)">
                  <ons-icon icon="fa-times"/>
                </ons-toolbar-button>
                <ons-toolbar-button class="close-btn manual-close-btn">
                  <ons-icon icon="fa-sort" class="drag-handle"/>
                </ons-toolbar-button>
                <div class="col-no">
                  <label>{{ phrase.setting_identifier }}</label>
                </div>
                <div class="col-content" :style="contentWidthStyles">
                  <com-textarea
                    :content="phrase.value"
                    cssClass="text-area-personal-phrase textarea-custom-text-font textarea-resize-vertical"
                    :idTextarea="'com-textarea-personal-phrase' + index"
                    class="comTextarea"
                    @set-content-data="setContentData($event, index)"
                  />
                </div>
              </div>
            </draggable>
          </div>
        </v-ons-list-item>
      </v-ons-list>
      <div class="btn-area">
        <v-ons-row>
          <div class="registration-btn-area" style="background:none">
            <!--mod FNSI-改修内容画面デザイン 任 start-->
            <!--<button class="button registration-btn" @click="addNewPhrase">追加</button>
          </div>
          <div class="registration-btn-area" style="background:none">
            <button class="button registration-btn" @click="deletePhrase">削除</button>
          </div>
        </v-ons-row>
      </div>
    </div>

    <div class="common-tab-footer">
      <v-ons-row width="100%">
        <v-ons-col width="50%">
          <v-ons-button
            class="button denial-btn"
            style="width: auto;"
            @click="cancel"
          >キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="button registration-btn"
            style="width: auto;"
            :disabled="!isChanged"
            @click="save"
          >保存</v-ons-button>-->
            <button class="button registration-btn btn3-normal" @click="addNewPhrase">追加</button>
          </div>
        </v-ons-row>
      </div>
    </div>

    <div class="common-tab-footer">
      <v-ons-row width="100%">
        <v-ons-col width="50%">
          <v-ons-button
            class="button denial-btn btn2-cancel"
            style="width: auto;"
            @click="cancel"
          >キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="button registration-btn btn1-execute"
            style="width: auto;"
            :disabled="!isChanged"
            @click="save"
          >保存</v-ons-button>
          <!--mod FNSI-改修内容画面デザイン 任 end-->
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

 <script>
   import { EventBus } from "@/eventBus.js";
   import {mapActions, mapGetters} from "vuex";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import vuedraggable from "vuedraggable";
   import CommonTextArea from "@/components/common/CommonTextArea";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
   import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
   // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
   import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
   import { messageFormat } from '@/functions/common/MessageFormat';
   // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
   export default {
  components: {
    draggable: vuedraggable,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      differenceHeight:0,
      // gridの高さ
      contentsAreaHeight: 200,

      // 定型文の配列(画面表示用)
      fixedPhraseList: [],

      // 初期表示時の値
      initData: "{}",

      // ドラッグ
      dragOptions: {
        animation: 250,
        ghostClass: "ghost",
        dragClass: "drag",
        forceFallback: true
      },

      // "内容"欄の幅
      textAreaWidth: "300px"
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


    onMoveCallback(evt){
      this.isDraggingCategory = false
      for(let i = 0;i<this.fixedPhraseList.length;i++){
        let el = document.getElementById(`com-textarea-personal-phrase${i}`)
        el.style.height = 'auto'
        if (el.scrollHeight < 40) {
          el.style.height = "41px";
        } else {
          el.style.height = `${el.scrollHeight}px`;
        }
      }
      EventBus.$emit('updateDifferenceHeight')
    },
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
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // Noを先頭から1,2,3・・となるよう振り直し
      for (let idx = 0; idx < this.fixedPhraseList.length; idx++) {
        let phrase = this.fixedPhraseList[idx];
        phrase.setting_identifier = String(idx + 1);
        this.fixedPhraseList[idx] = phrase;
      }

      // 設定内容をパラメータに格納
      const param = {
        tab_define_cd: this.tabDefineCd,
        values: this.fixedPhraseList.filter(p => p.value !== null && p.value.trim() !== "")
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
          getErrorMessage('FixedPhraseComponent.vue', 'save', error);
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
      if (this.tabDefineCd === null) {
        return;
      }

      // 指定のタブ定義で入力した個人設定値を取得する
      await this.fetchPersonalSetting();
    },

    /**
     * タブ定義コードより個人設定値を取得する.
     */
    async fetchPersonalSetting() {
      let personalSettings = [];
      const response = await this.getPersonalSettings(this.tabDefineCd);
      if (response.data.length === 0) {
        personalSettings = [{"setting_identifier": "1", "value": ""}];
      } else {
        personalSettings = response.data;
      }
      // 画面表示用のデータ
      this.fixedPhraseList = personalSettings;
      // 編集前の値を保存
      this.initData = deepCopy(this.fixedPhraseList);
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
    },

    /**
     * 内容欄の幅を調整する
     */
    calculateTextAreaWidth() {
      const contentsWidth = this.$refs.contentArea.clientWidth - 40;
      // NOTE: 32px * 2 (col-del, col-handle) と 2em (col-no)
      this.textAreaWidth = `calc(${contentsWidth}px - 64px - 2em)`;
    },

    /**
     * 新しい定型文を追加する
     */
    addNewPhrase() {
      // 空行追加
      const newPhrase = {"setting_identifier": String(this.fixedPhraseList.length + 1), "value": ""};
      this.fixedPhraseList.push(newPhrase);
    },

    /**
     * 定型文削除実行
     */
    deletePhrase(index) {
      this.fixedPhraseList.splice(index, 1);
      // Noを先頭から1,2,3・・となるよう振り直し
      for (let idx = 0; idx < this.fixedPhraseList.length; idx++) {
        let phrase = this.fixedPhraseList[idx];
        phrase.setting_identifier = String(idx + 1);
        this.fixedPhraseList[idx] = phrase;
      }
    },

    setContentData(newValue, index) {
     this.fixedPhraseList[index].value = newValue;
    }
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("personal-setting", {
      tabDefineCd: "getSelectedTabDefineCd"
    }),
    ...mapGetters("account-edit", {
      fontSize: "getFontSize"
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
      return JSON.stringify(this.initData) !== JSON.stringify(this.fixedPhraseList);
    },
    /**
     * 内容欄の幅をCSS変数を利用して書き換える
     */
    contentWidthStyles() {
      return { width: `${this.textAreaWidth}` };
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
     * ウィンドウサイズが変更された時の処理.
     */
    windowWidth() {
      this.calculateTextAreaWidth();
    },
    /**
     * 文字サイズが変更された時の処理.
     */
    fontSize() {
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
      this.calculateTextAreaWidth();
    });
  },
  updated() {
    //console.log(this.fixedPhraseList)
  },
};
</script>

 <style scoped>
 @media print {
  .common-tab-area, .common-tab-content {
    height: auto !important;
  }
}
.common-tab-area {
  margin: 5px;
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
.item-checkbox {
  flex: 1 0 15px;
  max-width: 35px;
}
.common-tab-content >>> select {
  border: solid 1px var(--personal-setting-select-border-color);
}
.checkbox-header {
  width: 45px;
  text-align: center;
}
.btn-area {
  margin: 2px 8px 0 8px;
}
.ghost {
  opacity: 0.5;
}

.drag {
  display: none;
}
.flex {
  display: flex;
}
.col-del,
.col-handle {
  width: 32px;
}
.col-no {
  width: 2em;
}
div >>> .text-area-personal-phrase {
  font: inherit;
  width: 100%;
  height: 2.5em;
  max-height: 1000px;
}
.flex ons-toolbar-button {
  width: 10px;
  padding: 0 10px;
}
@media print {
  .list-item {
    overflow: visible !important;
  }
  .col-content {
    width: 60% !important;
  }
}
</style>
