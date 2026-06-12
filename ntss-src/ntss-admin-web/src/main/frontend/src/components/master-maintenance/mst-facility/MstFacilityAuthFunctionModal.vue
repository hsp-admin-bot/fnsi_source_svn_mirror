/**
 * 各施設の使用機能変更モーダル画面用ページ
 */
<template>
  <modal-base @onClose="cancel">
        <template #body>
<div class="custom-ons-list-header">
      <v-ons-list modifier="inset">
        <v-ons-list-header>メニューバー表示機能設定</v-ons-list-header>
        <v-ons-list-item class="ntss-theme-screen print-height-auto">
          <table class="table-drag">
            <thead>
              <tr>
                <th align="center" class="drag-item-button-area">
                  <div class="right">
                    <v-ons-switch id="switch-all-check" @change="allFunctionChange" :disabled="!isAdminUser"></v-ons-switch>
                  </div>
                </th>
                <th style="font-weight: unset;">すべてON/OFF</th>
              </tr>
              <tr>
                <th align="center" class="drag-item-button-area th-font-weight">使用<br>機能</th>
                <th class="th-font-weight" style="padding-left:6px;">機能名</th>
              </tr>
            </thead>
          </table>
          <draggable v-if="isAdminUser"
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
                <div align="center" class="drag-item-button-area">
                  <!--「申込一覧」対応   杜  start-->
                  <v-ons-switch
                    v-if="isdisDabled(item.code)==0 ||isdisDabled(item.code)==1"
                    :value="item.code"
                    v-model="inputModel.useAuthFuncs"
                    @mousedown.stop @touchstart.stop>
                  </v-ons-switch>
                  <v-ons-switch
                    v-if="isdisDabled(item.code)==2"
                    disabled="true"
                    :value="item.code"
                    v-model="inputModel.useAuthFuncs"
                    @mousedown.stop @touchstart.stop>
                  </v-ons-switch>
                  <!--「申込一覧」対応   杜  end-->
                </div>
                <div class="drag-item-label">
                  {{ item.label }}
                </div>
              </div>
            </div>
          </draggable>
          <div v-else>
            <div v-for="(item, index) in menuList" :index="index" :key="item.code">
              <div class="drag-item">
                <div align="center" class="drag-handle">
                  <ons-toolbar-button disabled>
                    <ons-icon icon="fa-sort"></ons-icon>
                  </ons-toolbar-button>
                </div>
                <div align="center" class="drag-item-button-area">
                   <!--「申込一覧」対応   杜  start-->
                  <v-ons-switch
                    v-if="isdisDabled(item.code)==0 ||isdisDabled(item.code)==1"
                    disabled
                    :value="item.code"
                    v-model="inputModel.useAuthFuncs"
                    @mousedown.stop @touchstart.stop>
                  </v-ons-switch>
                  <v-ons-switch
                    v-if="isdisDabled(item.code)==2"
                    disabled="true"
                    :value="item.code"
                    v-model="inputModel.useAuthFuncs"
                    @mousedown.stop @touchstart.stop>
                  </v-ons-switch>
                  <!--「申込一覧」対応   杜  end-->
                </div>
                <div class="drag-item-label">
                  {{ item.label }}
                </div>
              </div>
            </div>
          </div>
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
        <v-ons-button class="button common-style-select-button registration-btn" @click="registration">確定</v-ons-button>
      </div>
    </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapState, mapActions, mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import { FUNC_SHARING_PATIENT_INFORMATION } from "@/constants/function-code";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
import { getModalContainerElement, getModalToolbarElement, getModalFooterElement, queryScopedSelector, getScopedElementById } from '@/functions/common/LayoutMeasureHelper';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

//URI
const uriFunctionAll = "/mstInfo/sysFunction";
//初期表示機能
const defaultFunction = "005";

export default {
  name: "UserFunctionModal",
  components: {
    "modal-base": ModalBase,
    "draggable": VueDraggable
  },
  data() {
    return {
      // 入力項目
      inputModel: {
        useAuthFuncs: []
      },
      menuList: [],
      initialMenuList: [],
      sysFunctions: null,
      defaultUseAuthFuncs: [],
      initialData: []
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      "getMasterRecordList",
      "getCancelFacilityCd"
    ]),
    ...mapGetters("account-edit", [
      "getFontSize",
      "getStateUserAccountInfo"
    ]),
    ...mapGetters("window-size", [
      "getWindowHeight"
      ]
    ),
    ...mapState("mst-user", ["userInfoModal"]),

    /**
     * 編集中の使用可能機能リスト(並び順反映).
     */
    editingUseFunctions() {
      return this.menuList.filter(m => this.isChecked(m.code)).map(m => m.code);
    },
    isAdminUser() {
      //管理者ならtrue/それ以外はfalse
      return 1 === this.getStateUserAccountInfo.administrator;
    },
    //「申込一覧」対応   杜  start
    isdisDabled() {
      // 管理者ならtrue/それ以外はfalse
      return function (code) {
        // 「申込一覧」判断する
        if (code == "038") {
          if (this.getEditRecord.facilityCd == "nkknkk") {
            return 1;
          } else {
            return 2;
          }
        } else {
          return 0;
        }
      };
    },
    //「申込一覧」対応   杜  end
  },
  watch: {
    inputModel: {
      handler(newVal) {
        var allFuncSwitch = getScopedElementById('switch-all-check', this.getCurrentModalContainer() || this.$el);
        var useAutLeng = newVal.useAuthFuncs.length;
        var menulistLeng = this.menuList.length;
        var isnkknkk = this.getEditRecord.facilityCd == "nkknkk";
        // 非日本機装施設（nkkk）の場合  杜  start
        // mod 施設マスタ 障害対応 孔 start
        // if (!isnkknkk && useAutLeng === menulistLeng - 1) {
        //     allFuncSwitch.checked = true;
        if (!isnkknkk) {
          if (this.menuList.find(i => i.code == "038") && useAutLeng === menulistLeng-1) {
            allFuncSwitch.checked = true;
          } else if (!this.menuList.find(i => i.code == "038") && useAutLeng === menulistLeng){
            allFuncSwitch.checked = true;
          }else {
            allFuncSwitch.checked = false;
          }
        // mod 施設マスタ 障害対応 孔 end
        } else if( isnkknkk && useAutLeng === menulistLeng){
            allFuncSwitch.checked = true;
        }else{
            allFuncSwitch.checked = false;
        }
        // 非日本機装施設（nkkk）の場合  杜  end
      },
      deep: true
    },
    getWindowHeight() {
      this.calculateHeight();
    },
    getFontSize() {
      this.calculateHeight();
    }
  },
  async created() {
    // 施設コード、システム利用設定を取得
    const editFacilityCd = this.getEditRecord.facilityCd;
    const systemUseSetting = this.getEditRecord.systemUseSetting;

    // マスタから機能一覧を作成
    await ApiHelper.get(uriFunctionAll)
      .then(response => {
        this.sysFunctions = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstFacilityAuthFunctionModal.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    for (const functionInfo of this.sysFunctions) {
      this.initialMenuList.push({
        code: `${functionInfo.functionCd}`,
        label: `${functionInfo.functionName}`,
        isNkk: `${functionInfo.isNkk}`,
        systemUseDisp: `${functionInfo.systemUseDisp}`
      });
    }

    // 日機装施設の場合
    if (editFacilityCd === "nkknkk") {
      // システム利用設定がReMSの場合
      if (systemUseSetting === "1") {
        // メニューの並びを設定する
        this.menuList = this.initialMenuList.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1";
        })
      } else if (systemUseSetting === "2") {
        // システム利用設定がFNSiの場合、メニューの並びを設定する
        this.menuList = this.initialMenuList.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "2";
        })
      } else {
        // システム利用設定がReMS+FNSiの場合、メニューの並びを設定する
        this.menuList = this.initialMenuList.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1" || item.systemUseDisp === "2";
        })
      }
    } else {
      // 日機装施設以外の場合、メニューの並びを設定する
      this.initialMenuList = this.initialMenuList.filter(item => {
        return item.isNkk == "0";
      })
      // システム利用設定がReMSの場合
      if (systemUseSetting === "1") {
        // メニューの並びを設定する
        this.menuList = this.initialMenuList.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1";
        })
      } else if (systemUseSetting === "2") {
        // システム利用設定がFNSiの場合、メニューの並びを設定する
        this.menuList = this.initialMenuList.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "2";
        })
      } else {
        // システム利用設定がReMS+FNSiの場合、メニューの並びを設定する
        this.menuList = this.initialMenuList.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1" || item.systemUseDisp === "2";
        })
      }
    }

    // 初期の使用可能機能一覧を保存
    if (this.getEditRecord.useFunction !== null) {
      const arrAuthFunctions = JSON.parse(this.getEditRecord.useFunction);
      var arrFuncCds = [];
      Object.keys(arrAuthFunctions.func_cds).forEach(function(key) {
        arrFuncCds.push(arrAuthFunctions.func_cds[key].func_cd);
      });
      this.inputModel.useAuthFuncs = arrFuncCds;
      this.defaultUseAuthFuncs = arrFuncCds;
    }

    // ユーザー設定で指定された順番に並べ替え（使用しない機能は末尾）
    this.menuList.forEach(menuItem => {
      menuItem.order = this.inputModel.useAuthFuncs.indexOf(menuItem.code);
      if (menuItem.order < 0) {
        menuItem.order = Number.MAX_VALUE;
      }
    });
    this.menuList.sort((a, b) => a.order - b.order);
    // スタイルの設定
    this.calculateHeight();
    let temp = this.menuList
    this.initialData = temp.filter(m => this.isChecked(m.code)).map(m => m.code)
  },

  methods: {
    getCurrentModalContainer() {
      return getModalContainerElement(this.$el) || null;
    },
    getCurrentModalToolbar() {
      return getModalToolbarElement(this.$el) || null;
    },
    getCurrentModalFooter() {
      return getModalFooterElement(this.$el) || null;
    },
    getFacilityAuthElement(selector) {
      return this.getCurrentModalContainer()?.querySelector?.(selector) || this.$el?.querySelector?.(selector) || queryScopedSelector(selector, this.$el);
    },
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "editRecordBeEmpty",
      "setMasterRecordList",
      "setCancelFacilityCd"
    ]),

    calculateHeight(){
      // スタイルの設定
      const dialogheigth = this.getCurrentModalContainer()?.offsetHeight || 0;
      const dialogHeaderheigth = this.getCurrentModalToolbar()?.offsetHeight || 0;
      const dialogFooterheigth = this.getCurrentModalFooter()?.offsetHeight || 0;
      // ヘッダー、フッター以外のマージン等の調整
      let adjustHeigth = 0;
      if (((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").match(/Android/)) {
        adjustHeigth = 82;
      } else {
        adjustHeigth = 47;
      }
      const listItem = this.getFacilityAuthElement('.list-item');
      if (listItem) {
        listItem.style.height = (dialogheigth - dialogHeaderheigth - dialogFooterheigth - adjustHeigth) + 'px';
        if (listItem.firstElementChild) {
          listItem.firstElementChild.style.display = 'unset';
        }
      }
    },

    /**
     * 全体オン/オフ
     */
    allFunctionChange(e) {
      if (e.value) {
        let tmpUseAuthFuncs = [];
        for (const menu of this.menuList) {
          // 「申込一覧」選択しない 杜  start
          if (menu.code == "038") {
            if (this.getEditRecord.facilityCd == "nkknkk") {
              tmpUseAuthFuncs.push(menu.code);
            }
          } else {
            tmpUseAuthFuncs.push(menu.code);
          }
           // 「申込一覧」選択しない 杜  end
        }
        this.inputModel.useAuthFuncs = tmpUseAuthFuncs;
      } else {
        if (this.menuList.indexOf(defaultFunction) != 0) {
          // 選択可能なメニューにマスタ一覧がある場合、マスタ一覧を選択状態とする
          this.inputModel.useAuthFuncs = [defaultFunction];
        } else {
          // マスタ一覧がない場合、メニューの一番先頭のメニューを選択状態とする
          this.inputModel.useAuthFuncs = [];
          if (this.menuList.length > 0) {
            this.inputModel.useAuthFuncs.push(this.menuList[0]);
          }
        }
      }
    },
    /**
     * 処理：選択・入力された情報で使用可能機能設定情報登録(更新)
     */
    registration() {
      // 使用可能機能のリスト
      var isChange =
        this.defaultUseAuthFuncs.toString() !==
        this.editingUseFunctions.toString();

      if (!isChange || !this.isAdminUser) {
        // 変更がない場合/権限がない場合は何もしないで画面を閉じる
        this.closeModalWindow();
      }
      // 更新用の許可機能をJSON形式で作成する
      var newFunctions = {};
      var arrEditFuncCds = [];
      const arrFuncCds = this.editingUseFunctions;
      for (let funcCode of arrFuncCds) {
        const newFuncCd = {};
        newFuncCd.func_cd = funcCode;
        arrEditFuncCds.push(newFuncCd);
      }
      newFunctions.func_cds = arrEditFuncCds;
      // 編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        useFunction: JSON.stringify(newFunctions)
      });

      const masterRecordList = this.getMasterRecordList;

      // state.editRecordを取得
      const editRecord = this.getEditRecord;
      // operationがないときは編集とみなす
      if (!editRecord.operation) {
        editRecord.operation = 2;
      } else if (editRecord.operation === 1) {
        // "追加"の場合は、"編集済"フラグを立てる
        editRecord.edited = true;
      }

      // state.masterRecordListにマージ
      const index = masterRecordList.data.findIndex(
        masterRecord => masterRecord.code === editRecord.code
      );
      masterRecordList.data[index] = editRecord;

      // TODO: 対症療法的なので直したい。
      // 配列の要素を入れ替えただけでは、「stateの変更」とみなしてくれず、一覧が再描画されなかった。
      // state.masterRecordListをwatchする（？）
      this.setMasterRecordList(undefined);
      this.setMasterRecordList(masterRecordList);

      // 患者情報共有機能のON/OFFによって、患者情報共有を管理する
      const defaultFlg = this.defaultUseAuthFuncs.find(func_cds => func_cds === FUNC_SHARING_PATIENT_INFORMATION);
      const editFlg = this.editingUseFunctions.find(func_cds => func_cds === FUNC_SHARING_PATIENT_INFORMATION);
      let cancelFacilityCdList = this.getCancelFacilityCd ? this.getCancelFacilityCd : [];
      if (defaultFlg) {
        // 患者情報共有機能をON→OFFにした施設コードを設定
        if (!editFlg) {
          cancelFacilityCdList.push(this.getEditRecord.facilityCd);
          this.setCancelFacilityCd(cancelFacilityCdList)
        }
      } else {
        // 患者情報共有機能をOFF→ONにした場合、
        if (editFlg) {
          // 解除する施設コードをリストに検索し、存在する場合はリストから削除する
          let idx = cancelFacilityCdList.findIndex(facilityCd => facilityCd === this.getEditRecord.facilityCd);
          if (idx != -1) {
            cancelFacilityCdList.splice(idx,1);
          }
        }
      }
      this.closeModalWindow();
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 変更の有無を判断
      // 使用可能機能のリスト
      var isChange =
        (this.defaultUseAuthFuncs.toString() !== this.editingUseFunctions.toString()) &&
        (this.initialData.toString() !== this.editingUseFunctions.toString()) ;

      // 上記いずれかに変更がある場合はメッセージを表示
      if (isChange) {
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
              this.closeModalWindow();
            }
          }
        });
      } else {
        this.closeModalWindow();
      }
    },
    /**
     * モーダル画面を閉じる処理
     */
    closeModalWindow() {
      // state.editRecordを空にする
      this.editRecordBeEmpty();
      this.hideModal();
      EventBus.$emit("onCloseMasterEditModal");
    },
    /**
     * 指定された機能の使用可能トグルがONになっているか確認.
     * ONの場合、trueを返す
     */
    isChecked(functionCd) {
      return this.inputModel.useAuthFuncs.indexOf(functionCd) >= 0;
    },
    /**
     * ドラッグ中アイテムのサイズ指定
     */
    getHelperDimension({ node }) {
      return {
        width: node.offsetWidth * 1.1,
        height: node.offsetHeight
      };
    }
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
.drag-handle{
  width: 2em;
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
.table-drag {
  padding-left: 1.8em;
}
.custom-ons-list-header :deep(.list-header) {
  font-size: inherit;
  display: flex;
  align-items: center;
}
.th-font-weight {
  font-weight: unset;
}
</style>
