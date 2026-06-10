/**
 * 職種マスタモーダル
 */
<template>
  <div>
    <div slot="body" class="custom-ons-list-header">
      <v-ons-list modifier="inset">
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
                    v-model="inputModel.useAuthFuncs"
                    :disabled="item.code === inputModel.initialFunction"
                    @mousedown.stop @touchstart.stop
                    @change="setCheckStatus">
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
  </div>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters } from "vuex";
import {EventBus} from "@/eventBus";
import { FUNC_DEVICE_EDGE_OPERATION } from "@/constants/function-code";
import vuedraggable from "vuedraggable";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import cloneDeep from "lodash/cloneDeep";
import isEqualWith from "lodash/isEqualWith";
import { customComparator } from "@/utils/util.js";
import { fetchMenuData , validateOnRegistration } from "@/functions/MenuBarFunctions";

//URI
const uriFunctionAll = "/mstInfo/sysFunction";
const uriFunctionFacility = "/mstInfo/mstFacility/";
//初期表示機能
const defaultFunction = "005";

export default {
  name: "jobMainModal",
  components: {
    "draggable": vuedraggable
  },
  data() {
    return {
      // 入力項目
      inputModel: {
        useAuthFuncs: [],
        initialFunction: ""
      },
      menuList: [],
      initialMenuList: [],
      saveJsonObj: [],
      allOn: false,
      // モバイル端末フラグ
      isAndroid: false,
      menuListClone: null,
      editRecordCompare: null,
      editRecordClone: null,
      // 施設許可OFFで画面上は非表示だが、既存設定でONの機能は保存時に削除しないよう退避する。
      hiddenUseAuthFuncs: []
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getRegistResult",
      "getStateUserAccountInfo",
      "isUseFunction"
    ]),
    ...mapGetters("master-maintenance", [
      "getFacilitySwitch",
      "getEditRecord",
      "getMasterRecordList"
    ]),
    ...mapGetters("account-edit", {getFontSize: "getFontSize"}),

    /**
     * 編集中の使用可能機能リスト(並び順反映).
     */
    editingUseFunctions() {
      return this.menuList.filter(m => this.isChecked(m.code)).map(m => m.code);
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
    // 並び替えが行われた時にデータを反映
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx start
    menuList: {
      handler(val) {
        this.updateEditMaster(this.inputModel.useAuthFuncs, false);
        this.notifyRegisteredFlag(val);
      },
      deep: true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx end
    // 全体オン/オフ
    "inputModel.useAuthFuncs"() {
      if (this.menuList.length == this.inputModel.useAuthFuncs.length) {
        this.allOn = true;
      } else {
        this.allOn = false;
      }
      this.updateEditMaster(this.inputModel.useAuthFuncs);
    },
    "inputModel.initialFunction"() {
      this.updateEditMaster(this.inputModel.useAuthFuncs);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx start
    editRecordClone: {
      handler() {
        this.notifyRegisteredFlag();
      },
      deep: true
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx end
  },
  mounted() {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx start
    if (!this.getEditRecord.defaultMenuSettings) {
      this.updateEditMaster(this.inputModel.useAuthFuncs);
    }
    this.editRecordCompare = cloneDeep(this.getEditRecord);
    this.editRecordClone = cloneDeep(this.getEditRecord);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx end
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
},
  methods: {
    ...mapActions("account-edit", ["updateMenuBar", "setMenuBar"]),
    // ...mapActions("master-maintenance", ["setEditRecord"]),
    createMenuSettingCompareRecord(record) {
      const compareRecord = cloneDeep(
        record && typeof record.toJSON === "function" ? record.toJSON() : record || {}
      );
      if (compareRecord.defaultMenuSettings) {
        compareRecord.defaultMenuSettings = JSON.parse(compareRecord.defaultMenuSettings);
      }
      return compareRecord;
    },
    isRegisteredState(menuList = this.menuList) {
      if (!this.editRecordClone || !this.editRecordCompare || !this.menuListClone) {
        return true;
      }
      const editRecord = this.createMenuSettingCompareRecord(this.editRecordClone);
      const editRecordCompare = this.createMenuSettingCompareRecord(this.editRecordCompare);
      return (
        isEqualWith(editRecordCompare, editRecord, customComparator) &&
        isEqualWith(this.menuListClone, menuList, customComparator)
      );
    },
    notifyRegisteredFlag(menuList = this.menuList) {
      // スイッチ変更はKendoのsaveイベントを通らないため、確定ボタン状態をここで明示更新する。
      EventBus.$emit("mstHolidayRegistered", this.isRegisteredState(menuList));
    },

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
          this.inputModel.useAuthFuncs = tmpUseAuthFuncs;
          // 初期表示機能にチェックがなかった場合
          if (this.inputModel.useAuthFuncs.indexOf(this.inputModel.initialFunction) < 0) {
            this.inputModel.initialFunction = this.inputModel.useAuthFuncs[0];
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
            this.inputModel.useAuthFuncs = [defaultFunction];
            this.inputModel.initialFunction = defaultFunction;
          } else {
            // なければ一番上のメニューを初期表示とする
            this.inputModel.useAuthFuncs = [this.menuList[0].code];
            this.inputModel.initialFunction = this.menuList[0].code;
          }
        }
      }

      // 編集中マスタを更新
      this.updateEditMaster(this.inputModel.useAuthFuncs);
    },
    /**
     * スイッチの状態を更新
     */
    setCheckStatus(e) {
      let tmpUseAuthFuncs = this.inputModel.useAuthFuncs;
      if (e.value) {
        // スイッチがオンされた時の処理
        tmpUseAuthFuncs.push(e.switch.value);
        // 初期表示機能にチェックがなかった場合
        if (this.inputModel.initialFunction == "") {
          this.inputModel.initialFunction = e.switch.value;
        }
      } else {
        // スイッチがオフされた時の処理
        const index = tmpUseAuthFuncs.indexOf(e.switch.value);
        if (index >= 0) {
          tmpUseAuthFuncs.splice(index, 1);
        }
      }
      // 編集中マスタを更新
      this.updateEditMaster(tmpUseAuthFuncs);
    },
    /**
     * ラジオボタンがONにされたら、使用可能トグルもONにする
     */
    changeUseFunction(initialFunction) {
      if (!this.isChecked(initialFunction)) {
        const useAuthFuncs = this.inputModel.useAuthFuncs.concat(
          initialFunction
        );
        this.inputModel.useAuthFuncs = useAuthFuncs;
      }
      // 更新が取得値に反映されない為、手動で反映する
      this.inputModel.initialFunction = initialFunction;
      // 編集中マスタを更新
      this.updateEditMaster(this.inputModel.useAuthFuncs);
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
    },
    mergeHiddenUseFunctions(visibleUseFunctions) {
      const mergedUseFunctions = visibleUseFunctions.concat();
      // 施設許可OFFかつ職種デフォルトONの機能はUIに表示しない。
      // ただし保存時に消さないよう、読み込み時に退避した hiddenUseAuthFuncs を戻す。
      this.hiddenUseAuthFuncs.forEach(functionCd => {
        if (mergedUseFunctions.indexOf(functionCd) < 0) {
          mergedUseFunctions.push(functionCd);
        }
      });
      return mergedUseFunctions;
    },
    // 編集中マスタを更新
    updateEditMaster(useAuthList, notify = true) {
      // 現在の状態をJSON形式にまとめる
      this.saveJsonObj.initial_menu_function = this.inputModel.initialFunction;
      this.saveJsonObj.default_menu_functions = [];
      this.menuList.forEach(menuItem => {
        if (useAuthList.indexOf(menuItem.code) >= 0) {
          this.saveJsonObj.default_menu_functions.push(menuItem.code);
        }
      });
      this.saveJsonObj.default_menu_functions =
        this.mergeHiddenUseFunctions(this.saveJsonObj.default_menu_functions);
      const defaultMenuSettings = JSON.stringify(this.saveJsonObj);
      // 更新
      if (!this.editRecordClone) {
        return;
      }
      if (typeof this.editRecordClone.set === "function") {
        this.editRecordClone.set("defaultMenuSettings", defaultMenuSettings);
      } else {
        this.editRecordClone.defaultMenuSettings = defaultMenuSettings;
      }
      if (notify) {
        this.notifyRegisteredFlag();
      }
    },
    /**
     * 確定ボタン押下時 バリデーション
     */
    validateOnRegistration() {
      return validateOnRegistration(this.inputModel, this.$ons);
    },
  },
  async created() {
    // マスタから機能一覧を作成
    await ApiHelper.get(uriFunctionAll)
      .then(response => {
        this.sysFunctions = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstJobMainModalComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    }

    // 施設の許可機能のみリストに表示
    // mod マスタ一覧 1･施設切替を可能とする 孔s this.getStateUserAccountInfo.facilityCd => this.getFacilitySwitch
    // await ApiHelper.get(
    //   uriFunctionFacility + this.getStateUserAccountInfo.facilityCd
    // )
    ApiHelper.get(
      uriFunctionFacility + this.getFacilitySwitch
    )
      .then(async responseFacility => {
        const authFuncFacilityjson = JSON.parse(
          responseFacility.data.useFunction
        );
        for (const functionInfo of authFuncFacilityjson.func_cds) {
          const editFuncInfo = this.sysFunctions.find(
            item => item.functionCd === functionInfo.func_cd
          );
          if (editFuncInfo) {
            this.initialMenuList.push({
              code: `${editFuncInfo.functionCd}`,
              label: `${editFuncInfo.functionName}`
            });
          }
        }
        
        // 外部リンクメニュー、メニューグループをメニューリストに追加
        const tmpMenuList = await fetchMenuData(this.getFacilitySwitch); 
        this.initialMenuList.push(...tmpMenuList);

        // mod マスタ一覧 1･施設切替を可能とする 孔s start
        // const isNkkAdmin = this.getStateUserAccountInfo.userType === 1 && this.getStateUserAccountInfo.administrator === 1;
        const isNkkAdmin = this.getStateUserAccountInfo.userType === 1 && this.getStateUserAccountInfo.administrator === 1 && this.getFacilitySwitch === "nkknkk";
        // mod マスタ一覧 1･施設切替を可能とする 孔s end

        // 003:デバイスエッジ稼働監視は日機装ユーザー(user_type: 1)かつ管理者のみ表示
        this.menuList = this.initialMenuList
          .concat()
          .filter(i => i.code !== FUNC_DEVICE_EDGE_OPERATION || isNkkAdmin);

        // 対象のレコードを取得
        const settingData = this.getEditRecord.defaultMenuSettings;
        if (settingData == "" || settingData == null) {
          this.saveJsonObj = {
            default_menu_functions: [],
            initial_menu_function: ""
          };

          // 選択可能なメニューにマスタ一覧がある場合、初期表示とする
          if (this.menuList.indexOf(defaultFunction) != 0) {
            this.saveJsonObj.default_menu_functions.push(defaultFunction);
            this.saveJsonObj.initial_menu_function = defaultFunction;
          }
        } else {
          this.saveJsonObj = JSON.parse(settingData);
        }

        // 施設許可OFFで非表示になった既存ON機能は UI に出さず、保存時だけ保持する。
        const visibleMenuCodes = this.menuList.map(menuItem => menuItem.code);
        const savedDefaultMenuFunctions = this.saveJsonObj.default_menu_functions || [];
        this.hiddenUseAuthFuncs = savedDefaultMenuFunctions.filter(
          functionCd => visibleMenuCodes.indexOf(functionCd) < 0
        );

        // 現在のカラムからデフォルト表示メニューの設定を取得
        this.inputModel.initialFunction = this.saveJsonObj.initial_menu_function;
        this.inputModel.useAuthFuncs = savedDefaultMenuFunctions.filter(
          functionCd => visibleMenuCodes.indexOf(functionCd) >= 0
        );

        // ユーザー設定で指定された順番に並べ替え（使用しない機能は末尾）
        this.menuList.forEach(menuItem => {
          menuItem.order = this.inputModel.useAuthFuncs.indexOf(menuItem.code);
          if (menuItem.order < 0) {
            menuItem.order = Number.MAX_VALUE;
          }
        });
        this.menuList.sort((a, b) => a.order - b.order);

        // スタイルの調整
        document.getElementsByClassName("list-item")[0].style.paddingLeft = "0px"
        const dialogheigth = document.getElementsByClassName("modal-container")[0].offsetHeight;
        const dialogHeaderheigth = document.getElementsByClassName("toolbar")[0].offsetHeight;
        const dialogFooterheigth = document.getElementsByClassName("modal-footer")[0].offsetHeight;
        // ヘッダー、フッター以外のマージン等の調整
        let adjustHeigth = 0;
        if (navigator.userAgent.match(/Android/)) {
          adjustHeigth = 82;
        } else {
          adjustHeigth = 47;
        }
        document.getElementsByClassName("list-item")[0].style.height = (dialogheigth - dialogHeaderheigth - dialogFooterheigth - adjustHeigth) + "px";
        document.getElementsByClassName("list-item")[0].firstElementChild.style.display = "unset";
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx start
        this.menuListClone = cloneDeep(this.menuList);
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx end
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstJobMainModalComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
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
  height: calc(100% - 7.2em);
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
.th-font-weight {
  font-weight: unset;
}
.custom-ons-list-header >>> .list-header {
  font-size: inherit;
  display: flex;
  align-items: center;
}
</style>
