/**
 * メニューバー設定Page
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div>
      <v-ons-list modifier="inset">
        <v-ons-list-header>メニューバー表示設定</v-ons-list-header>
        <v-ons-list-item class="ntss-theme-screen">
          <label class="center">
            メニューバー表示
          </label>
          <div class="right">
            <v-ons-switch v-model="inputModel.isDispMenu"></v-ons-switch>
          </div>
        </v-ons-list-item>
        <v-ons-list-header>メニューバー表示機能設定</v-ons-list-header>
        <v-ons-list-item class="ntss-theme-screen print-height-auto">
          <table :style="adjustPadding">
            <thead>
              <tr>
                <th class="drag-item-check-button-area"></th>
                <th align="center" class="drag-item-button-area">
                  <div class="right">
                    <v-ons-switch v-model="allOn" @change="allFunctionChange"></v-ons-switch>
                  </div>
                </th>
                <th style="font-weight: unset;">すべてON/OFF</th>
              </tr>
              <tr>
                <th align="center" class="drag-item-check-button-area th-font-weight">初期<br>表示</th>
                <th align="center" class="drag-item-button-area th-font-weight">使用<br>機能</th>
                <th class="th-font-weight" style="padding-left:6px;">機能名</th>
              </tr>
            </thead>
          </table>
          <draggable
            v-model="menuList"
            animation="250"
            handle=".drag-handle"
            :forceFallback="true"
          >
            <div v-for="(item, index) in menuList" :index="index" :key="item.code">
              <div class="drag-item">
                <div align="center" class="drag-handle">
                  <ons-toolbar-button>
                    <ons-icon icon="fa-sort"></ons-icon>
                  </ons-toolbar-button>
                </div>
                <div align="center" class="drag-item-check-button-area">
                  <!-- 初期表示ラジオボタン 外部リンクメニューは非活性 -->
                  <v-ons-radio name="initial-functions"
                    :input-id="'radio-' + index"
                    :value="item.code"
                    modifier="round"
                    v-model="inputModel.initialFunction"
                    :disabled="item.code.startsWith('url')"
                    @change="changeUseFunction(item.code)">
                  </v-ons-radio>
                </div>
                <div align="center" class="drag-item-button-area">
                  <v-ons-switch
                    :value="item.code"
                    v-model="inputModel.useFuncs"
                    :disabled="item.code === inputModel.initialFunction"
                    @mousedown.stop @touchstart.stop>
                  </v-ons-switch>
                </div>
                <div class="drag-item-label">
                  {{ item.label }}
                </div>
              </div>
            </div>
          </draggable>
        </v-ons-list-item>
      </v-ons-list>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button btn1-execute registration-btn" :disabled="!isChanged" @click="registration">保存</v-ons-button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { FUNC_DEVICE_EDGE_OPERATION } from "@/constants/function-code";
import { EventBus } from "@/compat/vue/event-bus.js";
import { VueDraggable } from "@/compat/drag/VueDraggable";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { fetchMenuData } from "@/functions/MenuBarFunctions";
import {
  getModalContainerElement,
  getModalFooterElement,
  getModalToolbarElement,
  getScopedElementsByClassName,
  getScopedNavigator
} from "@/functions/common/LayoutMeasureHelper";

//URI
const uriFunction = "/mstInfo/sysFunction";
//初期表示機能
const defaultFunction = "005";

export default {
  name: "menuBarEdit",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase,
    "draggable": VueDraggable
  },
  data() {
    return {
      // 入力項目
      inputModel: {
        isDispMenu: true,
        useFuncs: [],
        initialFunction: ""
      },
      menuList: [],
      initialMenuList: [],
      initialFuncCdList: [],
      sysFunctions: null,
      allOn: false,
      // 施設許可OFF / 利用者許可OFFで画面上は非表示だが、既存設定で保持しているメニューは保存時に削除しない。
      hiddenUseFuncs: [],
      // DB保存値の初期表示機能。画面上は fallback 表示でも、未編集ならこの値を保持する。
      savedInitialFunction: "",
      initialFunctionChangedByUser: false,
      // モバイル端末フラグ
      isAndroid: false
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getRegistResult",
      "getStateUserAccountInfo",
      "isDispMenu",
      "getUseFunctions",
      "getInitialFunction",
      "isUseFunction",
      "getAuthorizedFunctions",
      "getIsNkkAdmin"
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {getFontSize: "getFontSize"}),

    /**
     * 編集中の使用可能機能リスト(並び順反映).
     */
    editingUseFunctions() {
      return this.menuList.filter(m => this.isChecked(m.code)).map(m => m.code);
    },
    /**
     * 初期表示から変更されているかどうか
     */
    isChanged() {
      return this.inputModel.isDispMenu != Boolean(this.isDispMenu)
        || this.initialFuncCdList.toString() != this.editingUseFunctions.toString()
        || this.getInitialFunction !== this.inputModel.initialFunction;
    },
    /**
     * 文字サイズに応じてヘッダーの位置を調整する
     */
    adjustPadding() {
      let leftPadding = "2.1em";
      if(this.isAndroid) {
        if (this.getFontSize == 3) {
          // 特大
          leftPadding = "2em";
        } else if (this.getFontSize == 2) {
          // 大
          leftPadding = "2.4em";
        } else if (this.getFontSize == 1) {
          // 中
          leftPadding = "2.6em";
        } else {
          // 小
          leftPadding = "3.2em";
        }
      } else {
        if (this.getFontSize == 3) {
          // 特大
          leftPadding = "1.3em";
        } else if (this.getFontSize == 2) {
          // 大
          leftPadding = "1.5em";
        } else if (this.getFontSize == 1) {
          // 中
          leftPadding = "1.7em";
        }
      }
      return { paddingLeft: leftPadding };
    }
  },
  watch: {
    // 全体オン/オフ
    "inputModel.useFuncs"() {
      if (this.menuList.length == this.inputModel.useFuncs.length) {
        this.allOn = true;
      } else {
        this.allOn = false;
      }
    }
  },
  methods: {
    ...mapActions("account-edit", ["updateMenuBar", "getUserAccountInfo"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),

    /**
     * 全体オン/オフ
     */
    allFunctionChange(e) {
      if (this.menuList.length != 0) {
        if (e.value) {
          let tmpUseAuthFuncs = [];
          for (const menu of this.menuList) {
            tmpUseAuthFuncs.push(menu.code);
          }
          this.inputModel.useFuncs = tmpUseAuthFuncs;
          // 初期表示機能にチェックがなかった場合
          if (this.inputModel.useFuncs.indexOf(this.inputModel.initialFunction) < 0) {
            this.inputModel.initialFunction = this.inputModel.useFuncs[0];
            this.initialFunctionChangedByUser = true;
          }
        } else {
          // 選択可能なメニューにマスタ一覧がある場合、初期表示とする
          let mstListExists = false;
          this.menuList.forEach(menuItem => {
            if (menuItem.code == defaultFunction) {
              mstListExists = true;
            }
          });
          if (mstListExists) {
            this.inputModel.useFuncs = [defaultFunction];
            this.inputModel.initialFunction = defaultFunction;
            this.initialFunctionChangedByUser = true;
          } else {
            // なければ一番上のメニューを初期表示とする
            this.inputModel.useFuncs = [this.menuList[0].code];
            this.inputModel.initialFunction = this.menuList[0].code;
            this.initialFunctionChangedByUser = true;
          }
        }
      }
    },
    mergeHiddenUseFunctions(visibleUseFunctions) {
      const mergedUseFunctions = visibleUseFunctions.concat();
      this.hiddenUseFuncs.forEach(functionCd => {
        if (mergedUseFunctions.indexOf(functionCd) < 0) {
          mergedUseFunctions.push(functionCd);
        }
      });
      return mergedUseFunctions;
    },
    resolveInitialFunction() {
      // 画面に出ていない旧初期表示機能は、ユーザーがこの画面で明示的に変更していない限り保持する。
      if (!this.initialFunctionChangedByUser) {
        const visibleMenuCodes = this.menuList.map(menuItem => menuItem.code);
        if (visibleMenuCodes.indexOf(this.savedInitialFunction) < 0) {
          return this.savedInitialFunction;
        }
      }
      return this.inputModel.initialFunction;
    },
    /**
     * 処理：選択・入力された情報でメニューバー設定情報登録(更新)
     */
    registration() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      const updatedUseFunctions = this.mergeHiddenUseFunctions(this.editingUseFunctions);
      const updatedInitialFunction = this.resolveInitialFunction();
      const request = {
        userId: this.getStateUserAccountInfo.userId,
        isDispMenu: this.inputModel.isDispMenu ? 1 : 0,
        useFunctions: updatedUseFunctions,
        initialFunction: updatedInitialFunction
      };
      // 更新処理呼び出し
      this.updateMenuBar(request)
        .then(() => {
          (async () => {
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            // 登録成功
            await this.getUserAccountInfo();
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録成功",
              // message: "メニューバー設定情報が</br>正常に設定されました。"
              title: DIALOG_MESSAGES[12000294].title,
              message: messageFormat(DIALOG_MESSAGES[12000294].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            EventBus.$emit("refreshUrlList");
            // 画面を閉じる
            this.hideModal();
          })();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MenuBarEditView.vue','registration',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            // 登録失敗
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新に失敗しました。",
              title: DIALOG_MESSAGES["00300011"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 内容に変更がある場合はメッセージを表示
      if (this.isChanged) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.hideModal();
            }
          }
        });
      } else {
        this.hideModal();
      }
    },
    /**
     * ラジオボタンがONにされたら、使用可能トグルもONにする
     */
    changeUseFunction(initialFunction) {
      this.initialFunctionChangedByUser = true;
      if (!this.isChecked(initialFunction)) {
        const useFuncs = this.inputModel.useFuncs.concat(initialFunction);
        this.inputModel.useFuncs = useFuncs;
      }
    },
    /**
     * 指定された機能の使用可能トグルがONになっているか確認.
     * ONの場合、trueを返す
     */
    isChecked(functionCd) {
      return this.inputModel.useFuncs.indexOf(functionCd) >= 0;
    },
    /**
     * ドラッグ中アイテムのサイズ指定
     */
    getHelperDimension({ node }) {
      return {
        width: node.offsetWidth * 1.1,
        height: node.offsetHeight
      };
    },
    adjustModalLayout() {
      const root = this.$el || this;
      const listItems = getScopedElementsByClassName("list-item", root);
      if (!listItems[1]) {
        return;
      }
      listItems[1].style.paddingLeft = "0px";
      const dialogHeigth = getModalContainerElement(root)?.offsetHeight || 0;
      const dialogHeaderHeigth = getModalToolbarElement(root)?.offsetHeight || 0;
      const dialogFooterHeigth = getModalFooterElement(root)?.offsetHeight || 0;
      const settingAreaHeigth = (listItems[0]?.offsetHeight || 0) + 28;
      let adjustHeigth = 0;
      if (getScopedNavigator(root)?.userAgent?.match(/Android/)) {
        adjustHeigth = 82;
      } else {
        adjustHeigth = 47;
      }
      listItems[1].style.height = `${dialogHeigth - dialogHeaderHeigth - dialogFooterHeigth - settingAreaHeigth - adjustHeigth}px`;
      if (listItems[1].firstElementChild) {
        listItems[1].firstElementChild.style.display = "unset";
      }
    }
  },
  created() {
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 共通ローダー:表示開始
    this.setLoadingScreenVisible(true);

    const ua = getScopedNavigator(this.$el || this).userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    }

    ApiHelper.get(uriFunction)
      .then(async response => {
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
        this.sysFunctions = response.data;

        // マスタから機能一覧を作成
        for (const functionInfo of this.getAuthorizedFunctions) {
          const editFuncInfo = this.sysFunctions.find(
            item => item.functionCd === functionInfo
          );
          if (editFuncInfo) {
            this.initialMenuList.push({
              code: `${editFuncInfo.functionCd}`,
              label: `${editFuncInfo.functionName}`
            });
          }
        }
        
        // 外部リンクメニュー、メニューグループをメニューリストに追加
        const tmpMenuList = await fetchMenuData(this.facilityCd, this.getAuthorizedFunctions); 
        this.initialMenuList.push(...tmpMenuList);

        const savedUseFunctions =
          this.getStateUserAccountInfo?.userSettings?.use_functions || [];
        this.savedInitialFunction =
          this.getStateUserAccountInfo?.userSettings?.initial_function || "";

        this.inputModel.isDispMenu = Boolean(this.isDispMenu);
        const visibleMenuCodes = this.initialMenuList.map(item => item.code);
        this.hiddenUseFuncs = savedUseFunctions.filter(
          functionCd => visibleMenuCodes.indexOf(functionCd) < 0
        );
        this.inputModel.useFuncs = savedUseFunctions.filter(
          functionCd => visibleMenuCodes.indexOf(functionCd) >= 0
        );
        // サインイン時の実表示は getter 側の fallback に任せるが、
        // この画面で未編集の hidden 初期表示機能は保存時に維持する。
        this.inputModel.initialFunction = this.getInitialFunction;
        this.initialFunctionChangedByUser = false;

        // メニューの並びを初期化
        this.menuList = this.initialMenuList.concat();

        // ログインユーザの許可機能のみリストに表示
        // 003:デバイスエッジ稼働監視は日機装ユーザー(user_type: 1)かつ管理者のみ表示
        this.menuList = this.initialMenuList
          .concat()
          .filter(i => i.code !== FUNC_DEVICE_EDGE_OPERATION || this.initialMenuList);

        // ユーザー設定で指定された順番に並べ替え（使用しない機能は末尾）
        this.menuList.forEach(menuItem => {
          menuItem.order = this.getUseFunctions.indexOf(menuItem.code);
          if (menuItem.order < 0) {
            menuItem.order = Number.MAX_VALUE;
          }
        });
        this.menuList.sort((a, b) => a.order - b.order);

        this.initialFuncCdList = this.menuList.map(e => e.code)
          .filter(e => this.inputModel.useFuncs.includes(e));

        // スタイルの調整
        this.adjustModalLayout();
      })
      .catch(error => {
        // 共通ローダー:表示終了
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('MenuBarEditView.vue','created',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.setLoadingScreenVisible(false);
        throw error;
      });
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.list-item__center {
  background-position: bottom;
}
.drag-area {
  width: 100%;
  margin: 0px 4px 0px 4px;
  overflow-x: auto;
  height: calc(100% - 7em);
}
.drag-item {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex-wrap: nowrap;
  width: max-content;
}
.drag-handle ons-toolbar-button {
  cursor: move;
}
ons-switch {
  cursor: default;
}
.drag-item-label {
  flex-grow: 3;
  white-space: nowrap;
  padding-right: 5px;
  padding-left: 5px;
}
.drag-item-check-button-area {
  width: 4em;
}
.drag-item-button-area {
  width: 5em;
  padding-bottom: 3px;
  min-width: max-content;
}
.drag-helper {
  z-index: 10000;
}
.drag-helper .drag-item-label {
  box-shadow: 0 0 8px gray;
  border-radius: 4px;
}
.drag-helper .drag-item-button-area > ons-switch {
  display: none;
}
.drag-helper .drag-item-check-button-area > ons-radio {
  display: none;
}
ons-list-header {
  font-size: unset;
  display: flex;
  align-items: center;
}
.th-font-weight {
  font-weight: unset;
}
</style>
