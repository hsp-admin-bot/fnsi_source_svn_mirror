/**
 * 各施設の使用機能変更モーダル画面用ページ
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
                  <!-- mod redmine 6611 職種マスタ＞削除権限のヘルプの位置がおかしい 宋qy start -->
                  <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, delAuthItm.txtHelp)"></v-ons-icon>
                  <!-- mod redmine 6611 職種マスタ＞削除権限のヘルプの位置がおかしい 宋qy end -->
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
        :class="['tips-popover', fontSizeSet]"
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
        <v-ons-button class="btn2-cancel button denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="common-style-select-button button registration-btn" :disabled="registeredFlag" @click="registration">確定</v-ons-button>
      </div>
    </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { editAuthorityList, deleteAuthorityList, patientSharedAuthorityList } from "@/constants/authorityList";
import { FUNC_SHARING_PATIENT_INFORMATION } from "@/constants/function-code.js";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { sortCompare } from "@/utils/util.js"

import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { facilityByCd } from "@/functions/mst/MstGetters.js";
export default {
  name: "MstJobEditAuthorityModal",
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
      defaultAuthority: [],
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: 'up'
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getFacilitySwitch",
      "getEditRecord",
      "getMasterRecordList"
    ]),
    ...mapGetters("facility", ["isUseFunction"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx start
    registeredFlag() {
      return isEqualWith(this.checkedAuthority, this.defaultAuthority, sortCompare);
    },
    isPatientSharedAuthorized() {
      if (Array.isArray(this.latestUseFunctions)) {
        return this.latestUseFunctions.indexOf(FUNC_SHARING_PATIENT_INFORMATION) >= 0;
      }
      return this.isUseFunction(FUNC_SHARING_PATIENT_INFORMATION);
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx end
  },
  async created() {
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
      // 権限取得失敗時は既存store値で継続（画面自体は開けるようにする）
      this.latestUseFunctions = null;
    }
    // mod #12462 患者共有権限 関 end

    // 初期値に''が入っていることがある為、その対応
    if (this.getEditRecord.defaultAuthorizedAuthorities !== null && this.getEditRecord.defaultAuthorizedAuthorities.length > 0) {
    // add 職種マスタ 職種マスタの権限設定に祝日設定があるべきではない 障害対応 start
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // if (this.facilityCd !== "nkknkk") this.editAuthList = editAuthorityList.filter(item => item.code!=="123");
      // if (this.getFacilitySwitch !== "nkknkk") this.editAuthList = editAuthorityList.filter(item => item.code!=="123");
      // mod マスタ一覧 1･施設切替を可能とする 孔s end
      // add 職種マスタ 職種マスタの権限設定に祝日設定があるべきではない 障害対応 end
        const codes = this.getEditRecord.defaultAuthorizedAuthorities
          .split(',')
          .map((code) => String(code).trim())
          .filter(Boolean);
        this.checkedAuthority = [...new Set(codes)];
        
    } else {
      this.checkedAuthority = [];
    }
    // add 権限編集制御 楊zc start
    if (this.getFacilitySwitch !== "nkknkk") this.editAuthList = editAuthorityList.filter(item => item.code!=="123");
    // add 権限編集制御 楊zc end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx start
    this.defaultAuthority = cloneDeep(this.checkedAuthority);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_職種マスタ 20240105 mrx end
  },

  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      // "editRecordBeEmpty",
      "setMasterRecordList"
    ]),
    ...mapActions("mst-job", [
      "setIsEditAuthority"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 処理：選択・入力された情報で権限情報登録(更新)
     */
    onChangeEditAuth(e) {
      if (!e.target.checked) {
        return;
      }
      // 代行編集可と編集可はどちらか一方のみチェックとするので、チェックON時は同プレフィックスの他コードを削除する。
      // v-model が既に e.target.value を配列に追加しているため push しない（Vue3 で重複し、OFF が効かなくなる）。
      const chkValHead = e.target.value.substring(0, 2);
      for (let i = this.checkedAuthority.length - 1; i >= 0; i--) {
        const v = this.checkedAuthority[i];
        if (v !== e.target.value && v.indexOf(chkValHead) === 0) {
          this.checkedAuthority.splice(i, 1);
        }
      }
    },
    /**
     * 処理：選択・入力された情報で権限情報登録(更新)
     */
    registration() {
      // 編集中マスタを更新
      const editRecord = cloneDeep(this.getEditRecord);
      editRecord.defaultAuthorizedAuthorities = this.checkedAuthority.toString();
      this.setEditRecord(editRecord);

      // 権限編集フラグを立てる
      this.setIsEditAuthority(true);
      this.closeModalWindow();
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 上記いずれかに変更がある場合はメッセージを表示
      if (JSON.stringify(this.checkedAuthority) != JSON.stringify(this.defaultAuthority)) {
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
      // this.editRecordBeEmpty();
      this.hideModal();
      EventBus.$emit("onCloseMasterEditModal");
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
.list-item__center {
  background-position: bottom;
}
.button-label {
  width: 5em;
}
.custom-ons-list-header :deep(ons-list-header) {
  font-size: inherit;
  display: flex;
  align-items: center;
}
.icon-tips {
  position: absolute;
  right: 8px;
}
.tips-popover :deep(.popover),
.tips-popover :deep(.popover__content) {
  min-width: fit-content;
  min-height: fit-content;
}

.popover-message {
  margin: 15px;
}
</style>
