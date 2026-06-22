<!-- 
 新規患者登録・患者情報カード一覧
-->
<template>
  <main-content class="main-content">
    <div
      id="card"
      class="card-list"
      :style="cardListStyle"
      ref="cardListDiv"
      @scroll="scrollHandler"
    >
      <!-- 装置設定マスタと患者メモマスタ取得を待機 -->
      <!-- #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng start -->
      <card-list
        v-if="mstPatMemo !== null && mstDeviceSetInfo !== null"
        :pat-record="newPatObj"
        :is-creation-pat="true"
        ref="cardListCreate"
        @card-list-mounted="cardListMountedHandler"
        @card-list-refresh="cardListRefreshHandler"
      />
      <!-- #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng end -->
    </div>
    <div class="type-right">
      <img class="menu-btn" id="menu-btn" :src="imgUrl" ref="menuBtn" @click="menuDisplay()" />
    </div>
  </main-content>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
import { patMemo } from "@/functions/mst/MstGetters.js";
import { getDeviceSetInfoMst } from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
import cardList from "@/components/pat-info/PatInfoCardList.vue";
import PatInfoContentMixin from "@/components/pat-info/PatInfoContentMixin.js"
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getLatestHeaderElement, getHeaderHeight } from "@/functions/common/LayoutMeasureHelper";

import { CREATE_CONTENT } from "@/components/pat-info/PatInfoConfig.js"

export default {
  components: {
    "card-list": cardList
  },
  inject: {
    getNtssLayoutRootElement: { default: null },
    getNtssFooterMenuElement: { default: null }
  },
  mixins: [PatInfoContentMixin],
  mounted() {
    EventBus.$off("switchSidebar", this.handleSwitchSidebar);
    EventBus.$on("switchSidebar", this.handleSwitchSidebar);
    this.calculateContentHeight();// add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎
  },
  data() {
    return {
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
      cardListName: "patInfoCreate",
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
      mstDeviceSetInfo: null,
      mstHostNotificationInfo: null,
      mstPatMemo: null,
      mstTare: null,
      mstOffWater: null,
      mstHostNotification: null,
      // 新規登録用オブジェクト
      newPatObj: {
        pat_personal_main: {
          facility_cd: null,
          hosp_pat_id: null,
          pat_last_name: null,
          pat_first_name: null,
          pat_last_name_kana: null,
          pat_first_name_kana: null,
          pat_last_name_alpha: null,
          pat_first_name_alpha: null,
          pat_birth_name: null,
          pat_birth_name_kana: null,
          pat_birth_name_alpha: null,
          pat_birthday: null,
          pat_sex: 0,
          nationality: "JPN",
          //mod 8397 【デグレ】患者情報編集中に画面遷移した際、内容破棄確認メッセージが出ない 周安寧 start
          pat_blood_type_abo: 0,
          pat_blood_type_rh: 0,
          pat_blood_type_serovar: 0,
          //mod 8397 【デグレ】患者情報編集中に画面遷移した際、内容破棄確認メッセージが出ない 周安寧 end
          primary_disease_cd: null,
          //mod 8397 【デグレ】患者情報編集中に画面遷移した際、内容破棄確認メッセージが出ない 周安寧 start
          in_out_class: 3,
          //mod 8397 【デグレ】患者情報編集中に画面遷移した際、内容破棄確認メッセージが出ない 周安寧 end
          is_die: "0",
          die_cd: null,
          die_date: null,
          dial_diff_com_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          severity_cd: null,
          transport_cd: null,
          pat_contact_info: JSON.stringify({
            fax: null,
            tel1: null,
            tel2: null,
            memo1: null,
            memo2: null,
            e_mail: null,
            zip_cd: null,
            address: null,
            work_tel: null,
            work_name: null,
            work_address: null
          }),
          other_contact_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          vendor_contact_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          insurance_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          remote_monitor_service: "0",
          remote_monitor_user_id: "",
          remote_monitor_user_pw: ""
        },
        pat_main: {
          facility_cd: null,
          is_same: "0",
          is_implant: "0",
          is_infect: "0",
          is_diabetes: "0",
          is_blood_suger_exam: "0",
          is_wheel_chair: "0",
          in_out_current_state: null,
          in_out_plan_state: null,
          in_out_plan_date: null,
          pat_memo_info: null,
          addition_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          charge_staff_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          pat_group_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          taboo_allergy_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          infect_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          implant_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          tare_info: null,
          off_water_info: null,
          device_set_info: null,
          host_notification_info: null,
          acceptance_status_info: JSON.stringify([]),
          medical_care_info: JSON.stringify({
            ward_cd: null,
            facility_cd: null,
            dialysis_count: null,
            main_course_cd: null,
            dialysis_course_cd: null,
            purification_count: null,
            pat_dialysis_count: null,
            dialysis_start_date: null,
            hospital_start_date: null
          }),
          wheel_chair_cd: null
        },
        pat_unique: {
          medical_hst_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          in_out_visit_history_info: CREATE_CONTENT.JSON_EMPTY_ARRAY,
          physical_info: CREATE_CONTENT.JSON_EMPTY_ARRAY
        },
        pat_insurance_info: {
          insurance_list: CREATE_CONTENT.JSON_EMPTY_ARRAY
        },
        pat_group_info: {
          pat_group_list: CREATE_CONTENT.JSON_EMPTY_ARRAY
        }
      }
    };
  },
  computed: {
    ...mapGetters("pat-info", ["getCardListScrollPos", "selectedPatId"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getTheme", "isDispMenu"]),
    ...mapGetters("account-edit", { getFontSize: "getFontSize" }),// add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎
    ...mapGetters("window-size", { windowWidth: "getSplittedWidth", windowHeight: "getWindowHeight" }),// mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎
    /**
     * カード一覧領域のインラインスタイルを返す
     * 
     * メニューバーの表示状態に応じて、カード一覧領域<div id="card" class="card-list"...>のwidth／margin-leftを切替える。
     * メニューバーopen時は左側にメニューバー幅(143px)を確保し、close時は確保しない。
     */
    cardListStyle() {
      if (this.isMenuBarShowing) {
        return {
          width: this.windowWidth - 143 + "px",
          marginLeft: "143px"
        };
      }
      return {
        width: this.windowWidth + "px",
        marginLeft: "0px"
      };
    },
  },
  watch: {
    // 装置設定マスタの内容を初期値として新規登録用オブジェクトに設定
    mstDeviceSetInfo() {
      this.newPatObj.pat_main.device_set_info = JSON.stringify(this.mstDeviceSetInfo.pat);
    },
    mstHostNotificationInfo() {
      this.newPatObj.pat_main.host_notification_info = this.mstHostNotificationInfo;
    },
    // 患者メモマスタの内容をテンプレートとして新規登録用オブジェクトに設定
    mstPatMemo() {
      const patMemoTemplate = [];
      for (const patMemo of this.mstPatMemo) {
        patMemoTemplate.push({
          ctl_no: patMemo.patMemoNo,
          title: patMemo.title,
          content: patMemo.content
        });
      }
      this.newPatObj.pat_main.pat_memo_info = JSON.stringify(patMemoTemplate);
    },
    mstTare(value) {
      this.newPatObj.pat_main.tare_info = JSON.stringify({
        1: value,
        2: value,
        3: value,
        4: value,
        5: value,
        6: value,
        7: value
      });
    },
    mstOffWater(value) {
      this.newPatObj.pat_main.off_water_info = JSON.stringify({
        1: value,
        2: value,
        3: value,
        4: value,
        5: value,
        6: value,
        7: value
      });
    },
    mstHostNotification(value) {
      this.newPatObj.pat_main.host_notification_info = value;
    },
    // add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
    windowHeight(val) {
      const cardListDOM = this.$refs.cardListDiv || this.getPatInfoFirstByClassName("card-list");
      const btn = this.getPatInfoFirstByClassName("right-exe-btn");
      if (!cardListDOM || !btn) {
        return;
      }
      const headerHeight = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const footHeight = (typeof this.getNtssFooterMenuElement === "function"
        ? this.getNtssFooterMenuElement()
        : this.getPatInfoElementById("footer-menu"))?.clientHeight || 0;
      const btnHeight = btn.clientHeight || 0;
      const cardListNewHeight = val - headerHeight - footHeight - btnHeight - 4;
      cardListDOM.style.height = `${cardListNewHeight}px`;
    },
    getFontSize() {
      const cardListDOM = this.$refs.cardListDiv || this.getPatInfoFirstByClassName("card-list");
      const btn = this.getPatInfoFirstByClassName("right-exe-btn");
      if (!cardListDOM || !btn) {
        return;
      }
      const headerHeight = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const footHeight = (typeof this.getNtssFooterMenuElement === "function"
        ? this.getNtssFooterMenuElement()
        : this.getPatInfoElementById("footer-menu"))?.clientHeight || 0;
      const btnHeight = btn.clientHeight || 0;
      const cardListNewHeight = this.windowHeight - headerHeight - footHeight - btnHeight - 4;
      cardListDOM.style.height = `${cardListNewHeight}px`;
    },
    // add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
    isDispMenu() {
      this.calculateContentHeight();
    },
    windowWidth() {
      this.$nextTick(() => {
        this.$refs.cardListCreate?.updateMasonry?.();
      });
    },
    isMenuBarShowing() {
      this.$nextTick(() => {
        this.$refs.cardListCreate?.updateMasonry?.();
      });
    }
  },
  async created() {
    // 患者情報画面ページ表示中は患者情報ヘッダからカード一覧を表示させなくする
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--start */
    this.setIsPatInfoPageShowing(true);
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--end */
    // 現在の施設コードをセット
    this.newPatObj.pat_personal_main.facility_cd = this.facilityCd;
    this.newPatObj.pat_main.facility_cd = this.facilityCd;
    // 初期値に必要なマスタ取得
    let mstTareOffWater;
    let tmpHostNotification;
    [
      this.mstDeviceSetInfo,
      this.mstPatMemo,
      mstTareOffWater,
      tmpHostNotification
    ] = await Promise.all([
      getDeviceSetInfoMst(this.facilityCd, this.selectedPatId),
      patMemo(this.facilityCd),
      ApiHelper.get(`deviceSetInfo/getSysTareAndOffWaterById/${this.facilityCd}`, {
        selectedPatId: this.selectedPatId
      }),
      ApiHelper.get(`deviceSetInfo/getSysHostNoticeById/${this.facilityCd}`, {
        selectedPatId: this.selectedPatId
      })
    ]).catch(error => {
      getErrorMessage('PatInfoCreateContent.vue', 'created', error);
      throw new Error(error);
    });
    mstTareOffWater = JSON.parse(mstTareOffWater.data[0]);
    this.mstTare = JSON.parse(mstTareOffWater.tare_info);
    this.mstOffWater = JSON.parse(mstTareOffWater.off_water_info);
    this.mstHostNotificationInfo = JSON.parse(tmpHostNotification.data[0]);
  },
  // ページを離れたとき再び表示できるようにする

  methods: {
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--start */
    ...mapMutations("pat-info", ["setIsPatInfoPageShowing", "setCardListScrollPos"]),
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--end */
    handleSwitchSidebar() {
      this.$nextTick(() => {
        this.setMenuBarLeft();
        this.$nextTick(() => {
          this.$refs.cardListCreate?.updateMasonry?.();
        });
      });
    },
    // add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
    calculateContentHeight() {
      let headerHeight = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      let windowHeight = this.windowHeight;
      const footHeight = (typeof this.getNtssFooterMenuElement === "function"
        ? this.getNtssFooterMenuElement()
        : this.getPatInfoElementById("footer-menu"))?.clientHeight || 0;
      let cardListDOM = this.$refs.cardListDiv || this.getPatInfoFirstByClassName("card-list");
      if (undefined === cardListDOM || null === cardListDOM) {
        return;
      }
      let btnHeight = 44;
      switch (this.getFontSize) {
        case 0:
          btnHeight = 29;
          break;
        case 1:
          btnHeight = 35;
          break;
        case 2:
          btnHeight = 38;
          break;
      }
      let cardListNewHeight = windowHeight - headerHeight - footHeight - btnHeight - 4;
      cardListDOM.style.height = cardListNewHeight + "px";
    }
    // add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
  },
  beforeUnmount() {
    this.setIsPatInfoPageShowing(false); // add by shiyinwang 2022-08-26 [6119] When leaving the patient information page, set the variable IsPatInfoPageShowing to false
    EventBus.$off("switchSidebar", this.handleSwitchSidebar);
  }
};
</script>

<style scoped>
@media print {
  .main-content :deep(div){
    height: auto !important;
  }
  /** 見出し開閉ボタン非表示 */
  .type-right {
    display: none;
  }
}
.card-list {
  overflow-y: scroll;
  position: absolute;
  height: auto;
  top: 0;
  bottom: 34px;
}
.block {
  display: block;
}
.none {
  display: none;
}
.type-right {
  margin-left: 143px;
}
</style>
