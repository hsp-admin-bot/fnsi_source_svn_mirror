/**
 * マスタメンテナンス  MainContent
 */
<template>
  <div class="main-content-area" ref="main-content-area-block">
    <table class="ntss-list" id="master-list">
      <thead>
        <tr>
          <th class="ntss-list-header-th-sticky" style="font-weight: 300; width: 3em;" scope="col">No</th>
          <th class="ntss-list-header-th-sticky" scope="col">マスタ名</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for='master in filteredMasterList'
          :key='master.masterCd'
          :class="'ntss-list-body-tr'"
          @click='goNext(master.masterPhysicalName, master.masterName, master.mode)'>
          <!-- <td class='ntss-list-body-td'>{{ master.masterPhysicalName }}</td> -->
          <td class='ntss-list-body-td'>{{ master.dispOrder }}</td>
          <td class='ntss-list-body-td'>{{ master.masterName }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { MODE } from "@/constants/masterMaintenanceConstants";
import { SYS_USE_DISP } from "@/constants/sysUseConstants";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { FUNC_SPLIT_GRAPH } from "@/constants/function-code.js";
// add マスタ一覧 1･施設切替を可能とする 孔s start
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
// add マスタ一覧 1･施設切替を可能とする 孔s end
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [NextTransitionMixin],
  data() {
    return {
      masterList: [],
      condition: {
        masterName: ""
      }
      // add マスタ一覧 1･施設切替を可能とする 孔s start
      ,facilitySwitchSysUseSetting: ""
      // add マスタ一覧 1･施設切替を可能とする 孔s end
    };
  },
  computed: {
    ...mapGetters("master-maintenance", ["getScrollToTop", "getSearchMasterName","getFacilitySwitch","getFacilitySwitchUseFunction","getFacilitySwitchAdvancedSettings"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      systemUseSetting: "getSystemUseSetting",
      advancedSettings: "getAdvancedSettings"
    }),
    ...mapGetters("user", {
      getUserAuthorityCds: "getUserAuthorityCds"
    }),

    // 検索条件が変更されたら表示内容を更新
    filteredMasterList() {
      if (this.condition.masterName != "") {
        // 条件にマスタ名称が設定されている場合
        return this.masterList.filter(
          e => e.masterName.indexOf(this.condition.masterName) != -1
        );
      } else {
        // 条件がない場合、全件返す
        return this.masterList;
      }
    },
    isShowAdditionInfo() {
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // if (!this.advancedSettings.func_advcds) return false;
      // return this.advancedSettings.func_advcds.some(
      //   a => a.func_advcd === ADVANCED_SETTINGS.ADDITION_INFO
      // );
      if (!this.getFacilitySwitchAdvancedSettings) return false;
      return this.getFacilitySwitchAdvancedSettings.includes(ADVANCED_SETTINGS.ADDITION_INFO);
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    },
    isShowGraphSetting() {
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // return this.useFunction.includes(FUNC_SPLIT_GRAPH);
      if (!this.getFacilitySwitchUseFunction) return false
      return this.getFacilitySwitchUseFunction.includes(FUNC_SPLIT_GRAPH);
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    },
    isShowMedicationSupport() {
      if (!this.getFacilitySwitchAdvancedSettings) return false;
      return this.getFacilitySwitchAdvancedSettings.includes(ADVANCED_SETTINGS.MEDICATION_SUPPORT);
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["findMasterList"]),
    ...mapActions("master-maintenance", [
      "setMasterName",
      "setLogicalMasterName",
      "setScrollToTop",
    ]),
    // mod #9764  by zhangruixue 2023-09-04 --start
    ...mapActions("user", [
      "fetchUserAuthorityCds",
      "setFailureCnt",
      "setAccountLockSetting",
      "setOtpFailureCnt"
    ]),
    // mod #9764  by zhangruixue 2023-09-04 --end
    // マスタ一覧のデータを取得
    findList() {

      this.fetchUserAuthorityCds();
      let userAuthorityCds = this.getUserAuthorityCds;

      // apiをコールして値を取得
      this.findMasterList()
      .then(response => {
          let dispSystem = null;
          // システム利用設定ごとの利用可能機能
          // mod マスタ一覧 1･施設切替を可能とする 孔s start
          // switch (this.systemUseSetting) {
          this.masterList=[];
          switch (this.facilitySwitchSysUseSetting) {
          // mod マスタ一覧 1･施設切替を可能とする 孔s end
            case "1":
              // ReMSのみ
              dispSystem = SYS_USE_DISP.REMS_ONLY;
              break;
            case "2":
              dispSystem = SYS_USE_DISP.FNSI_ONLY;
              break;
            case "3":
              dispSystem = SYS_USE_DISP.REMS_AND_FNSI;
              break;
          }
          for (
            let rwCount = 0;
            rwCount < response.data.masterList.length;
            rwCount++
          ) {
            const masterItem = response.data.masterList[rwCount];

            // 対象システムのみ
            if(dispSystem.indexOf(masterItem.systemUseDisp) >= 0){
              switch (masterItem.editLevel) {
                case "1":
                  // 全ユーザ
                  this.masterList.push(masterItem);
                  break;
                case "2":
                  // 管理者のみ
                  if (1 === this.getStateUserAccountInfo.administrator) {
                    this.masterList.push(masterItem);
                  }
                  break;
                case "3":
                  // 日機装社員のみ
                  if (
                    1 === this.getStateUserAccountInfo.userType &&
                    "nkknkk" === this.getFacilitySwitch) {
                    this.masterList.push(masterItem);
                  }
                  break;
                case "4":
                  // 日機装社員・管理者のみ
                  if (
                    "nkknkk" === this.getFacilitySwitch &&
                    1 === this.getStateUserAccountInfo.userType &&
                    1 === this.getStateUserAccountInfo.administrator
                  ) {
                    this.masterList.push(masterItem);
                  }
                  break;
                case "5":
                  // 管理者 または 日機装社員のみ
                  if (
                    1 === this.getStateUserAccountInfo.userType ||
                    1 === this.getStateUserAccountInfo.administrator
                  ) {
                    this.masterList.push(masterItem);
                  }
                  break;
                default:
                  break;
              }
            }
          }
          if (!this.isShowAdditionInfo) {
            this.masterList = this.masterList.filter(item => item.masterPhysicalName !== "mst_addition");
          }
          if (!this.isShowGraphSetting) {
            this.masterList = this.masterList.filter(item => item.masterPhysicalName !== "mst_graph_setting");
          }
          if (!this.isShowMedicationSupport) {
            this.masterList = this.masterList.filter(item => item.masterPhysicalName !== "mst_medicine_support");
          }
          /* ADD 観察記録カテゴリマスタの削除対応 劉 */
          // del 9191 【デグレ】観察記録カテゴリマスタのマスタ一覧での非表示のさせ方が不正 関 start
          // this.masterList = this.masterList.filter( item => item.masterPhysicalName !== "mst_obs_kind");
          // del 9191 【デグレ】観察記録カテゴリマスタのマスタ一覧での非表示のさせ方が不正 関 end
        })
        .catch(error => {
          if (error.response && error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterListComponent.vue', 'findList', 'マスタ一覧情報の取得に失敗しました。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "マスタ一覧情報の取得に失敗しました。"
              title: DIALOG_MESSAGES['00200038'].title,
              message: messageFormat(DIALOG_MESSAGES['00200038'].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MasterListComponent.vue', 'findList', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    // 次ページへの遷移
    goNext(masterPhysicalName, masterLogicalName, mode) {
      if (masterPhysicalName === "usage_subscription") {
        this.$router.push({ name: "usage-subscription" });
        return;
      }
      this.setScrollToTop(this.$refs["main-content-area-block"].scrollTop);
      this.setMasterName(masterPhysicalName);
      this.setLogicalMasterName(masterLogicalName);
      // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
      if (['mst_mainte_detail', 'mst_exam_item', 'mst_taboo_allergy'].includes(masterPhysicalName)) {
        this.goSpecifiedView("individual-master");
        return;
      }
      // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
      if (mode === MODE.MODE1) {
        this.goSpecifiedView("master-record");
      } else if (mode === MODE.MODE2) {
        this.goSpecifiedView("individual-master");
      }
    },
    setFilterCondition(condition) {
      this.condition.masterName = condition.masterName;
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    async setFacility() {
      if (this.getFacilitySwitch !== this.getStateUserAccountInfo.facilityCd) {
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.getFacilitySwitch);
        if (mstFacilityHash.data.systemUseSetting) {
          this.facilitySwitchSysUseSetting = mstFacilityHash.data.systemUseSetting
        }
        // add #9764  by zhangruixue 2023-09-04 --start
        if (mstFacilityHash.data.failureCnt) {
          this.setFailureCnt(mstFacilityHash.data.failureCnt)
        }
        if (mstFacilityHash.data.accountLockSetting) {
          this.setAccountLockSetting(mstFacilityHash.data.accountLockSetting)
        }
        if (mstFacilityHash.data.otpFailureCnt) {
          this.setOtpFailureCnt(mstFacilityHash.data.otpFailureCnt)
        }
        // add #9764  by zhangruixue 2023-09-04 --end
      } else {
        this.facilitySwitchSysUseSetting = this.systemUseSetting
      }
      this.findList()
    },
    refresh() {
      const currentRouteName = this.$route?.name
        || this.$router?.currentRoute?.value?.name
        || this.$router?.currentRoute?.name;
      if (currentRouteName === "master-maintenance") {
        return this.setFacility();
      }
      return undefined;
    }
    // add マスタ一覧 1･施設切替を可能とする 孔s end
  },
  created() {
    EventBus.$on("filterMasterList", this.setFilterCondition);
    this.condition.masterName = this.getSearchMasterName;
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    EventBus.$on("mstFacilitySwitch", this.setFacility);
    EventBus.$on("refresh", this.refresh);
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
  },
  updated() {
    this.$refs["main-content-area-block"].scrollTop = this.getScrollToTop;
  },
  beforeUnmount() {
    EventBus.$off("filterMasterList", this.setFilterCondition);
    EventBus.$off("mstFacilitySwitch", this.setFacility);
    EventBus.$off("refresh", this.refresh);
  }
};
</script>
<style>
#master-list tr:nth-child(2n){
  background-color: var(--ntss-list-content-2nd-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}
.main-font .main-font {
  font-size: 1em;
}
.main-font .header {
  font-size: 0.667em;
}
</style>