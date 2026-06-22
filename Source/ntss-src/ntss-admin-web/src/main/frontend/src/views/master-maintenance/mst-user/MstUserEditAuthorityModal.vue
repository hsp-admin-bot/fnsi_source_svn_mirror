/**
 * 各ユーザの使用機能変更モーダル画面用ページ
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div class="custom-ons-list-header">
      <v-ons-list modifier="inset">
        <v-ons-list-header>編集権限</v-ons-list-header>
        <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
          <table>
            <thead>
              <tr>
                <th>代行編集可</th>
                <th>編集可</th>
                <th>機能名</th>
              </tr>
            </thead>
            <tbody v-for="(editAuthItm,$index) in editAuthList" :key="$index">
              <tr>
                <td align="center">
                  <v-ons-checkbox v-if="editAuthItm.isDispProxy === true"
                    :input-id="'checkboxProxy-' + $index"
                    :value="editAuthItm.codeProxy"
                    v-model="checkedAuthority"
                    @change="onChangeEditAuth"
                  >
                  </v-ons-checkbox>
                </td>
                <td align="center">
                  <v-ons-checkbox
                    :input-id="'checkbox-' + $index"
                    :value="editAuthItm.code"
                    v-model="checkedAuthority"
                    @change="onChangeEditAuth"
                  >
                  </v-ons-checkbox>
                </td>
                <td>
                  <label>{{ editAuthItm.label }}</label>
                  <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, editAuthItm.txtHelp)"></v-ons-icon>
                </td>
              </tr>
            </tbody>
          </table>
        </v-ons-list-item>
        <v-ons-list-header>削除権限</v-ons-list-header>
        <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
          <table>
            <thead>
              <tr>
                <th>編集可</th>
                <th>機能名</th>
              </tr>
            </thead>
            <tbody v-for="(delAuthItm,$index) in deleteAuthList" :key="$index">
              <tr>
                <td align="center">
                  <v-ons-checkbox
                    :input-id="'checkboxDel-' + $index"
                    :value="delAuthItm.code"
                    v-model="checkedAuthority"
                  >
                  </v-ons-checkbox>
                </td>
                <td>
                  <label>{{ delAuthItm.label }}</label>
                  <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, delAuthItm.txtHelp)"></v-ons-icon>
                </td>
              </tr>
            </tbody>
          </table>
        </v-ons-list-item>
        <!-- add #12462 患者共有権限 関 start -->
        <template v-if="isPatientSharedAuthorized">
          <v-ons-list-header>患者共有権限</v-ons-list-header>
          <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
            <table>
              <thead>
                <tr>
                  <th>閲覧可</th>
                  <th>機能名</th>
                </tr>
              </thead>
              <tbody v-for="(psAuthItm,$index) in patientSharedAuthorityList" :key="$index">
                <tr>
                  <td align="center">
                    <v-ons-checkbox
                      :input-id="'pscheckbox-' + $index"
                      :value="psAuthItm.code"
                      v-model="checkedAuthority"
                    >
                    </v-ons-checkbox>
                  </td>
                  <td>
                    <label>{{ psAuthItm.label }}</label>
                    <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, psAuthItm.txtHelp)"></v-ons-icon>
                  </td>
                </tr>
              </tbody>
            </table>
          </v-ons-list-item>
        </template>
        <!-- add #12462 患者共有権限 関 end -->
      </v-ons-list>
      <v-ons-popover cancelable
        v-model:visible="userMenuPopoverVisible"
        :target="userMenuPopoverTarget"
        :cover-target="false"
        :direction="userMenuPopoverDirection"
        :class="fontSizeSet"
        @preshow="popoverPreShow"
        @postshow="popoverPostShow"
        @posthide="popoverPosthide"
       >
         <p class="popover-message" id="popOverMessage">テスト</p>
       </v-ons-popover>
    </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="btn1-execute registration-btn" :disabled="registeredFlag" @click="registration">保存</v-ons-button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import ModalBase from "@/components/modals/ModalBase";
import { PERMISSION_CHANGE_SIGNOUT } from "@/constants/facilitySetting";
import { MSG_SETTING_REFLECTION } from "@/constants/masterMaintenanceConstants";
import { editAuthorityList, deleteAuthorityList, patientSharedAuthorityList } from "@/constants/authorityList";
import { FUNC_SHARING_PATIENT_INFORMATION } from "@/constants/function-code.js";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapState, mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { sortCompare } from "@/utils/util.js"
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import { facilityByCd } from "@/functions/mst/MstGetters.js";
export default {
  name: "MstUserEditAuthorityModal",
  mixins: [MultiModalMixin, PopoverMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      // 入力項目
      editAuthList: editAuthorityList,
      deleteAuthList: deleteAuthorityList,
      patientSharedAuthorityList: patientSharedAuthorityList,
      // store を更新せず、当画面表示用に最新機能権限を保持
      latestUseFunctions: null,
      checkedAuthority: [],
      // 編集ユーザー情報
      editUserId: "",
      editFacilityCd: "",
      defaultAuthority: [],
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: 'right up',
      // 施設設定：権限変更時サインアウトさせるかの設定
      signoutFlg: false
    };
  },
  computed: {
    ...mapGetters("account-edit", [
        "getStateUserAccountInfo"
    ]),
    ...mapGetters("facility", ["isUseFunction"]),
    ...mapState("mst-user", ["userInfoModal"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx start
    registeredFlag() {
      return isEqualWith(this.checkedAuthority, this.defaultAuthority, sortCompare);
    },
    isPatientSharedAuthorized() {
      if (Array.isArray(this.latestUseFunctions)) {
        return this.latestUseFunctions.indexOf(FUNC_SHARING_PATIENT_INFORMATION) >= 0;
      }
      return this.isUseFunction(FUNC_SHARING_PATIENT_INFORMATION);
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx end
  },
  watch: {
  },
  async created() {
    this.editUserId = this.userInfoModal.userId;
    this.editFacilityCd = this.userInfoModal.facilityCd;

    // mod #12462 患者共有権限 関 start
    // login 時点の useFunction が古い場合があるため、表示前に最新を取得する（storeは更新しない）
    try {
      const facilityCd = this.$store.getters["user/getFacilityCd"];
      const response = await facilityByCd(facilityCd);
      const useFunction = response?.useFunction;
      if (useFunction && useFunction.length > 0) {
        const useFuncObj = JSON.parse(useFunction);
        this.latestUseFunctions = (useFuncObj?.func_cds ?? []).map(e => e.func_cd);
      } else {
        this.latestUseFunctions = [];
      }
    } catch (e) {
      this.latestUseFunctions = null;
    }
    // 利用機能の最新状態が OFF の場合は、DB 側で更新済みの authorities を反映するため
    // 利用者一覧を再取得し、モーダル表示用データを最新化する（既存値を手動削除補正しない）
    if (!this.isPatientSharedAuthorized) {
      try {
        await this.getUserDataList(this.editFacilityCd);
        const latest = this.$store.state["mst-user"]?.masterRecordList?.data?.find(
          u => u.userId == this.editUserId
        );
        if (latest) {
          this.setUserData({
            userId: latest.userId,
            authorities: latest.authorities,
            facilityCd: this.editFacilityCd,
          });
        }
      } catch (e) {
        // 取得失敗時は既存 store 値で継続
      }
    }
    // mod #12462 患者共有権限 関 end

    if (this.userInfoModal.authorities.length !== 0){
      this.checkedAuthority = [...this.checkedAuthority,...this.userInfoModal.authorities];
      // this.userInfoModal.authorities.forEach(item => {
      //   this.checkedAuthority.push(item);
      // });
    }
    // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    // this.defaultAuthority = this.checkedAuthority;
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx start
    this.defaultAuthority = cloneDeep(this.checkedAuthority);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx end
    // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
    /* ADD 追加「祝日设定」楊zc strat */
    if(this.editFacilityCd != "nkknkk") {
      this.editAuthList = this.editAuthList.filter(item => item.label != '祝日設定');
    }
    /* ADD 追加「祝日设定」楊zc end */

    // 施設設定：権限変更時サインアウトさせるかの設定を取得
    sendRequestGetMstFacilitySettingValue(this.editFacilityCd, PERMISSION_CHANGE_SIGNOUT).then(response => {
      this.signoutFlg = (response.data == 1);
    });
  },
  mounted() {
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("account-edit", ["updateAuthority", "getUserAccountInfo"]),
    ...mapMutations("account-edit", ["setUserAccountInfo"]),
    ...mapActions("mst-user", ["resetUserDataList", "getUserDataList", "setUserData"]),

    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    /**
     * 処理：選択・入力された情報で権限情報登録(更新)
     */
    onChangeEditAuth(e) {
      if (e.target.checked){
        // 代行編集可と編集可はどちらか一方のみチェックとするので、チェックON時はもう一方をチェックOFFにする
        let chkValHead = e.target.value.substring(0,2);
        for(let i=0; i < this.checkedAuthority.length; i++){
          if (this.checkedAuthority[i] !== e.target.value && this.checkedAuthority[i].indexOf(chkValHead) === 0){
            this.checkedAuthority.splice(i, 1);
            // なぜかチェックした要素が未チェック状態になったのでチェックされるように修正
            // this.checkedAuthority.push(e.target.value);
            // break;
          }
        }
      }
    },
    /**
     * 処理：選択・入力された情報で権限情報登録(更新)
     */
    async registration() {
      // 登録確認
      if (!await this.regiConfirm()) {
        // キャンセルされたら何もせずに抜ける
        return;
      }
      // 共通ローダー:表示名設定・表示開始
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);

      const parmSignoutFlg = this.getStateUserAccountInfo.userId != this.editUserId ? this.signoutFlg : false;
      const request = [{
        userId: this.editUserId,
        authorities: this.checkedAuthority,
        signoutFlg: parmSignoutFlg
      }];
      // 更新処理呼び出し
      this.updateAuthority(request)
        .then(() => {
          (async () => {
            // アカウント情報の再読み込み
            this.getUserAccountInfo();

            if(this.getStateUserAccountInfo.userId == this.editUserId){

              // メニューバー情報取得用パラメータ
              var userAccountInfo = this.getStateUserAccountInfo;
              var userSettings = userAccountInfo.userSettings;
              userSettings.authorized_authorities = this.checkedAuthority;
              userAccountInfo.userSettings = userSettings;
              this.setUserAccountInfo(userAccountInfo);
            }

            // ユーザー情報更新
            await this.resetUserDataList(this.editFacilityCd);
            EventBus.$emit("mst-user-grid-refresh");

            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            // 画面を閉じる
            this.hideModal();
          })();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MstUserEditAuthorityModal.vue','registration','更新に失敗しました。');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          // 共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // 登録失敗
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新に失敗しました。",
              title: DIALOG_MESSAGES['00300011'].title,
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
      // 上記いずれかに変更がある場合はメッセージを表示
      // modify #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx start
      if (!this.registeredFlag) {
      // modify #10053 破棄確認・保存活性(複数変更含む)・削除対応_利用者マスタ 20240105 mrx end
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
     * 登録確認
     */
    async regiConfirm() {
      let rtn = true;
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
      let changeFlg = this.defaultAuthority.every(element => this.checkedAuthority.includes(element));
      if (changeFlg) {
        return rtn;
      }
      // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
      // 施設設定で権限変更時サインアウトが有効、又は編集者以外の権限変更の場合
      if (this.signoutFlg && this.getStateUserAccountInfo.userId != this.editUserId) {
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
      }
      return rtn;
    },
    /**
     * 吹き出し表示処理
     */
    showPopOver(event, message) {
      var pop = getScopedElementById("popOverMessage", this.$el || this);
      pop.innerText = message;
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    }
  }
};
</script>

<style scoped>
.button-label {
  width: 5em;
}

.custom-ons-list-header :deep(ons-list-header) {
  font-size: inherit;
  display: flex;
  align-items: center;
}
.popover-message {
  margin: 10px;
}
</style>
