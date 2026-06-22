/**
 * 各ユーザの使用機能変更モーダル画面用ページ
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div>
      <v-ons-list modifier="inset">
        <!-- del #10136 利用者マスタで職種を変更した場合に仮利用者しかデフォルトメニュー設定/権限が展開されない。 dou start-->
        <!-- <div :style="isRemsOnly">-->
        <!--   <v-ons-list-header>職種選択</v-ons-list-header>-->
        <!--   <v-ons-list-item class="ntss-theme-screen">-->
        <!--     <div class="right" style="background-position:unset">-->
        <!--       <v-ons-select v-model="selectedJobCd" @change="changeItem">-->
        <!--         <option v-for="job in getMstJobList" :key=job.length :value=job.jobCd>-->
        <!--           {{ job.jobName }}-->
        <!--         </option>-->
        <!--       </v-ons-select>-->
        <!--     </div>-->
        <!--   </v-ons-list-item>-->
        <!-- </div>-->
        <!-- del #10136 利用者マスタで職種を変更した場合に仮利用者しかデフォルトメニュー設定/権限が展開されない。 dou end-->
        <v-ons-list-header>1メニューバー表示機能設定</v-ons-list-header>
        <v-ons-list-item class="ntss-theme-screen print-height-auto">
          <table class="table-drag">
            <thead>
              <tr>
                <th class="drag-item-check-button-area"></th>
                <th align="center" class="drag-item-button-area">
                  <div class="right">
                    <v-ons-switch id="switch-all-check" @change="allFunctionChange"></v-ons-switch>
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
        <v-ons-button class="btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="btn1-execute registration-btn"  :disabled="registeredFlag" @click="registration">保存</v-ons-button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapState, mapActions, mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import { FUNC_DEVICE_EDGE_OPERATION } from "@/constants/function-code";
import { PERMISSION_CHANGE_SIGNOUT } from "@/constants/facilitySetting";
import { MSG_SETTING_REFLECTION } from "@/constants/masterMaintenanceConstants";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { customComparator } from "@/utils/util.js";
import { fetchMenuData , validateOnRegistration } from "@/functions/MenuBarFunctions";
import {
  getModalContainerElement,
  getModalFooterElement,
  getModalToolbarElement,
  getScopedElementById,
  getScopedElementsByClassName,
  getScopedNavigator
} from "@/functions/common/LayoutMeasureHelper";

//URI
const uriGetUserInfo = "/user/get_by_id/";
const uriFunctionAll = "/mstInfo/sysFunction";
const uriFunctionFacility = "/mstInfo/mstFacility/";
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
        useAuthFuncs: [],
        initialFunction: ""
      },
      menuList: [],
      initialMenuList: [],
      sysFunctions: null,
      // 編集ユーザー情報
      editUserId: "",
      editFacilityCd: "",
      defaultUseAuthFuncs: [],
      defaultInitialFunction: "",
      defaultJobCd: "",
      selectedJobCd: "",
      selectedJobCdClone: "",
      userType: 0,
      administrator: 0,
      // 選択施設のシステム利用設定
      facilitySysUseSetting: "",
      // 施設設定：権限変更時サインアウトさせるかの設定
      signoutFlg: false,
      menuListClone: null,
      inputModelClone: null,
      // 初期データ取得完了前は保存ボタンを非活性のままにする（非同期読込中のちらつき防止）
      isInitialDataReady: false,
      // 施設許可OFFで画面上は非表示だが、既存設定で許可されている機能は保存時に削除しないよう退避する。
      hiddenUseAuthFuncs: []
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getRegistResult",
      "isDispMenu",
      "getUseFunctions",
      "getInitialFunction",
      "isUseFunction",
      "getAuthorizedFunctions",
      "getStateUserAccountInfo"
    ]),
    ...mapGetters("mst-user", ["getMstJobList"]),
    ...mapState("mst-user", ["userInfoModal"]),
    ...mapGetters("user", {
      getSystemUseSetting: "getSystemUseSetting"
    }),
    /**
     * 編集中の使用可能機能リスト(並び順反映).
     */
    editingUseFunctions() {
      return this.menuList.filter(m => this.isChecked(m.code)).map(m => m.code);
    },
    isRemsOnly() {
      if(this.facilitySysUseSetting === "1") {
        return { display: "none" };
      }
      return {};
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx start
    registeredFlag() {
      if (!this.isInitialDataReady) {
        return true;
      }
      const inputModel = cloneDeep(this.inputModel);
      inputModel.useAuthFuncs = inputModel.useAuthFuncs?.sort();
      return isEqualWith(this.inputModelClone, inputModel, customComparator) &&
        isEqualWith(this.menuListClone, this.menuList, customComparator) &&
        isEqualWith(this.selectedJobCdClone, this.selectedJobCd, customComparator);
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx end
  },
  watch: {
    "inputModel.useAuthFuncs"() {
      this.syncAllFunctionSwitch();
    },
  },
  async created() {
    // 対象ユーザの情報を設定
    this.editUserId = this.userInfoModal.userId;
    this.editFacilityCd = this.userInfoModal.facilityCd;

    if (this.editFacilityCd) {
      // 施設のシステム利用設定を取得する
      const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.editFacilityCd);
      this.facilitySysUseSetting = mstFacilityHash.data.systemUseSetting ? mstFacilityHash.data.systemUseSetting : "";
    } else {
      this.facilitySysUseSetting = ""
    }
    // 施設設定：権限変更時サインアウトさせるかの設定を取得
    sendRequestGetMstFacilitySettingValue(this.editFacilityCd, PERMISSION_CHANGE_SIGNOUT).then(response => {
      this.signoutFlg = (response.data == 1);
    });

    // 対象ユーザ情報を取得
    await ApiHelper.get(uriGetUserInfo + this.editUserId)
      .then(response => {
        const userAccountInfo = response.data.userAccountInfo;
        this.inputModel.useAuthFuncs =
          userAccountInfo.userSettings.authorized_functions;
        this.defaultUseAuthFuncs =
          userAccountInfo.userSettings.authorized_functions;
        this.inputModel.initialFunction =
          userAccountInfo.userSettings.initial_function;
        this.defaultInitialFunction =
          userAccountInfo.userSettings.initial_function;
        this.selectedJobCd = userAccountInfo.jobCd;
        this.defaultJobCd = userAccountInfo.jobCd;
        this.userType = userAccountInfo.userType;
        this.administrator = userAccountInfo.administrator;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('MstUserFunctionModal.vue','created',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        throw error;
      });

    // マスタから機能一覧を作成
    await ApiHelper.get(uriFunctionAll)
      .then(response => {
        this.sysFunctions = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('MstUserFunctionModal.vue','created',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        throw error;
      });

    // 個人の許可機能のみリストに表示
    ApiHelper.get(uriFunctionFacility + this.editFacilityCd)
      .then(async responseFacility => {
        const authFuncFacilityjson = JSON.parse(
          responseFacility.data.useFunction);
        for (const functionInfo of authFuncFacilityjson.func_cds) {
          const editFuncInfo = this.sysFunctions.find(
            item => item.functionCd === functionInfo.func_cd);
          if (editFuncInfo) {
            this.initialMenuList.push({
              code: `${editFuncInfo.functionCd}`,
              label: `${editFuncInfo.functionName}`
            });
          }
        }
        const isNkkAdmin = this.userType === 1 && this.administrator === 1;
        // 003:デバイスエッジ稼働監視は日機装ユーザー(user_type: 1)かつ管理者のみ表示
        this.menuList = this.initialMenuList
          .concat()
          .filter(i => i.code !== FUNC_DEVICE_EDGE_OPERATION || isNkkAdmin);
        
        /// 外部リンクメニュー、メニューグループをメニューリストに追加
        const tmpMenuList = await fetchMenuData(this.editFacilityCd); 
        this.menuList.push(...tmpMenuList);
        
        // ユーザー設定で指定された順番に並べ替え（使用しない機能は末尾）
        this.menuList.forEach(menuItem => {
          menuItem.order = this.inputModel.useAuthFuncs.indexOf(menuItem.code);
          if (menuItem.order < 0) {
            menuItem.order = Number.MAX_VALUE;
          }
        });
        this.menuList.sort((a, b) => a.order - b.order);

        // 施設許可OFFで非表示になった既存許可機能は UI に出さず、保存時だけ保持する。
        const visibleMenuCodes = this.menuList.map(menuItem => menuItem.code);
        const savedAuthorizedFunctions = this.inputModel.useAuthFuncs || [];
        this.hiddenUseAuthFuncs = savedAuthorizedFunctions.filter(
          functionCd => visibleMenuCodes.indexOf(functionCd) < 0
        );
        this.inputModel.useAuthFuncs = savedAuthorizedFunctions.filter(
          functionCd => visibleMenuCodes.indexOf(functionCd) >= 0
        );

        // 全件ON/OFFのスイッチ切り替え
        this.syncAllFunctionSwitch();
        this.inputModelClone = cloneDeep(this.inputModel);
        this.inputModelClone.useAuthFuncs = this.inputModelClone.useAuthFuncs.sort();
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx start
        this.menuListClone = cloneDeep(this.menuList);
        this.selectedJobCdClone = this.selectedJobCd;
        this.isInitialDataReady = true;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx end
        // スタイルの調整
        this.$nextTick(() => {
          this.adjustListLayout();
        });
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('MstUserFunctionModal.vue','created',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        throw error;
      });
  },
  mounted() {},
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("mst-checklist", [
      "setSelectEditSetting",
      "setDialysisProgName",
      "regEditData",
      "sortData"
    ]),
    ...mapActions("account-edit", ["updateUseAuthFunctions", "getUserAccountInfo"]),

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
      if (e.value) {
        let tmpUseAuthFuncs = [];
        for (const menu of this.menuList) {
          tmpUseAuthFuncs.push(menu.code);
        }
        this.inputModel.useAuthFuncs = tmpUseAuthFuncs;
      } else {
        if (this.menuList.indexOf(defaultFunction) != 0) {
          // 選択可能なメニューにマスタ一覧がある場合、マスタ一覧を選択状態とする
          this.inputModel.useAuthFuncs = [defaultFunction];
          this.inputModel.initialFunction = defaultFunction;
        } else {
          // マスタ一覧がない場合、メニューの一番先頭のメニューを選択状態とする
          this.inputModel.useAuthFuncs = [];
          if (this.menuList.length > 0) {
            this.inputModel.useAuthFuncs.push(this.menuList[0]);
            this.inputModel.initialFunction = this.menuList[0];
          }
        }
      }
    },
    mergeHiddenUseFunctions(visibleUseFunctions) {
      const mergedUseFunctions = visibleUseFunctions.concat();
      // 施設許可OFFで非表示になった既存許可機能は、今回の編集対象外として保持する。
      this.hiddenUseAuthFuncs.forEach(functionCd => {
        if (mergedUseFunctions.indexOf(functionCd) < 0) {
          mergedUseFunctions.push(functionCd);
        }
      });
      return mergedUseFunctions;
    },
    /**
     * 処理：選択・入力された情報で使用可能機能設定情報登録(更新)
     */
    async registration() {
      // 入力チェック
      if (!validateOnRegistration(this.inputModel, this.$ons)) {
        return;
      }
      // 登録確認
      if (!await this.regiConfirm()) {
        // キャンセルされたら何もせずに抜ける
        return;
      }
      // 共通ローダー:表示名設定・表示開始
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);

      const parmSignoutFlg = this.getStateUserAccountInfo.userId != this.editUserId ? this.signoutFlg : false;
      const updatedAuthorizedFunctions = this.mergeHiddenUseFunctions(this.editingUseFunctions);
      const request = {
        userId: this.editUserId,
        useAuthFunctions: updatedAuthorizedFunctions,
        initialFunction: this.inputModel.initialFunction,
        jobCd: this.selectedJobCd,
        signoutFlg: parmSignoutFlg
      };

      // 更新処理呼び出し
      this.updateUseAuthFunctions(request)
        .then(() => {
          (async () => {
            // アカウント情報の再読み込み
            await this.getUserAccountInfo();
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            // 画面を閉じる
            this.hideModal();
          })();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MstUserFunctionModal.vue','registration',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          // 共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
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
     * 登録確認
     */
    async regiConfirm() {
      let rtn = true;
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
      const currentUseAuthFunctions = this.mergeHiddenUseFunctions(this.editingUseFunctions);
      let changeFlg = this.defaultUseAuthFuncs.every(element => currentUseAuthFunctions.includes(element));
      if (changeFlg) {
        return rtn;
      }
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
      // 施設設定で権限変更時サインアウトが有効、又は編集者以外の権限変更の場合
      if (this.signoutFlg && this.getStateUserAccountInfo.userId != this.editUserId) {
        // mod 6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
        // // 無効にされた機能の有無を確認
        // const notDeleteFlg = await this.defaultUseAuthFuncs.every(funcNo => {
        //   return (this.editingUseFunctions.indexOf(funcNo) > -1);
        // });
        // // 無効にされた機能がある場合は確認ダイアログを表示
        // if (!notDeleteFlg) {
        //   await this.$ons.notification.confirm({
        //     title: "変更確認",
        //     message: MSG_SETTING_REFLECTION,
        //     callback: answer => {
        //       if (answer !== 1) {
        //         // キャンセル
        //         rtn = false;
        //       }
        //     }
        //   });
        // }
        await this.$ons.notification.confirm({
         // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "変更確認",
          title: DIALOG_MESSAGES[13000157].title,
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          message: MSG_SETTING_REFLECTION,
          callback: answer => {
            if (answer !== 1) {
              // キャンセル
              rtn = false;
            }
          }
        });
        // mod 6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
      }
      return rtn;
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 変更の有無を判断

      // 上記いずれかに変更がある場合はメッセージを表示
      if (!this.registeredFlag) {
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
      if (!this.isChecked(initialFunction)) {
        const useAuthFuncs = this.inputModel.useAuthFuncs.concat(
          initialFunction);
        this.inputModel.useAuthFuncs = useAuthFuncs;
      }
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
    syncAllFunctionSwitch() {
      const allFuncSwitch = getScopedElementById("switch-all-check", this.$el || this);
      if (!allFuncSwitch) {
        return;
      }
      allFuncSwitch.checked = this.menuList.length === this.inputModel.useAuthFuncs.length && this.menuList.length !== 0;
    },
    adjustListLayout() {
      const root = this.$el || this;
      const listItems = getScopedElementsByClassName("list-item", root);
      if (!listItems[1]) {
        return;
      }
      listItems[1].style.paddingLeft = "0px";
      const dialogHeigth = getModalContainerElement(root)?.offsetHeight || 0;
      const dialogHeaderHeigth = getModalToolbarElement(root)?.offsetHeight || 0;
      const dialogFooterHeigth = getModalFooterElement(root)?.offsetHeight || 0;
      const settingAreaHeigth = listItems[0]?.offsetHeight || 0;
      const settingItemHeaderHeigth = getScopedElementsByClassName("list-header", root)[0]?.offsetHeight || 0;
      let adjustHeigth = 0;
      if (getScopedNavigator(root)?.userAgent?.match(/Android/)) {
        adjustHeigth = 82;
      } else {
        adjustHeigth = 47;
      }
      listItems[1].style.height = `${dialogHeigth - dialogHeaderHeigth - dialogFooterHeigth - settingAreaHeigth - adjustHeigth - settingItemHeaderHeigth}px`;
      if (listItems[1].firstElementChild) {
        listItems[1].firstElementChild.style.display = "unset";
      }
    },
    // del #10136 利用者マスタで職種を変更した場合に仮利用者しかデフォルトメニュー設定/権限が展開されない。 dou start
    // /**
    //  * 職種変更時処理
    //  */
    // changeItem() {
    //   if ( this.selectedJobCd !== ""){
    //     // 選択した職種に設定された使用機能情報を取得して設定する
    //     const selectJob = this.getMstJobList.filter(item => {
    //       return item.jobCd === this.selectedJobCd;
    //     });
    //     // 使用可能メニュー反映
    //     this.inputModel.useAuthFuncs = selectJob[0].defaultMenuFunctions;
    //     // 初期表示メニュー反映
    //     this.inputModel.initialFunction = selectJob[0].initialMenuFunction;
    //   }
    // }
    // del #10136 利用者マスタで職種を変更した場合に仮利用者しかデフォルトメニュー設定/権限が展開されない。 dou end
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
  height: calc(100% - 7.3em);
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
  font-size: inherit;
  display: flex;
  align-items: center;
}
.table-drag {
  padding-left:1.6em;
}
.th-font-weight {
  font-weight: unset;
}
 
/* add #10136 利用者マスタで職種を変更した場合に仮利用者しかデフォルトメニュー設定/権限が展開されない。 dou start*/
.list-item :deep(.list-item__center) {
  display: block;
}
/* add #10136 利用者マスタで職種を変更した場合に仮利用者しかデフォルトメニュー設定/権限が展開されない。 dou end*/
</style>
