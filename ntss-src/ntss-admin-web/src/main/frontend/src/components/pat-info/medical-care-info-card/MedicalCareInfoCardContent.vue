<template>
  <table class="card-table">
    <tbody>
    <tr>
      <td class="item-title">診療科</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="medicalCareInfo('main_course_cd')"
          :display-string="courseName"
          :disabled="true"
          style="vertical-align: middle; color: #1f1f21;"
        />
      </td>
      <td class="item-data choice-button-area">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   :disabled="editFlag" -->
        <!--   ref="btnSelectCourse" -->
        <!--   class="common-style-select-button btn3-normal" -->
        <!--   @click="handleShowPopover('main_course_cd', popoverDataMstCourse)" -->
        <!-- > -->
        <common-master-selector
          :masterType="MasterType.COURSE_PAT_INFO"
          :facilityCd="medicalCareComposeFacilityCd"
          :initItem="{ value: medicalCareInfo('main_course_cd').initValue }"
          :editItem="{ value: medicalCareInfo('main_course_cd').editValue }"
          :btnName="'選択'"
          :isVisible="false"
          :btnClass="'common-style-select-button btn3-normal'"
          :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @popover-return="onMcMainCourseReturn"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">透析実施科</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="medicalCareInfo('dialysis_course_cd')"
          :display-string="dialysisDataName"
          :disabled="true"
          style="vertical-align: middle; color: #1f1f21;"
        />
      </td>
      <td class="item-data choice-button-area">
        <common-master-selector
          :masterType="MasterType.DIALYSIS_COURSE_PAT_INFO"
          :facilityCd="medicalCareComposeFacilityCd"
          :initItem="{ value: medicalCareInfo('dialysis_course_cd').initValue }"
          :editItem="{ value: medicalCareInfo('dialysis_course_cd').editValue }"
          :btnName="'選択'"
          :isVisible="false"
          :btnClass="'common-style-select-button btn3-normal'"
          :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @popover-return="onMcDialysisCourseReturn"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">病棟</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="medicalCareInfo('ward_cd')"
          :display-string="wardName"
          :disabled="true"
          style="vertical-align: middle; color: #1f1f21;"
        />
      </td>
      <td class="item-data choice-button-area">
        <common-master-selector
          :masterType="MasterType.WARD_PAT_INFO"
          :facilityCd="medicalCareComposeFacilityCd"
          :initItem="{ value: medicalCareInfo('ward_cd').initValue }"
          :editItem="{ value: medicalCareInfo('ward_cd').editValue }"
          :btnName="'選択'"
          :isVisible="false"
          :btnClass="'common-style-select-button btn3-normal'"
          :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @popover-return="onMcWardReturn"
        />
      </td>
    </tr>
    <tr>
      <!-- TODO: 上下限値検討 -->
      <td class="item-title">自施設通算透析回数</td>
      <td colspan="2" class="item-data">
        <custom-input-number
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :value="medicalCareInfo('dialysis_count')"
          :max-value="99999"
          :min-value="0"
          :digits="5"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </td>
    </tr>
    <!--add FNSI-患者通算透析回数 じょはく start-->
    <tr>
      <!-- TODO: 上下限値検討 -->
      <td class="item-title">患者通算透析回数</td>
      <td colspan="2" class="item-data">
        <custom-input-number
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :value="medicalCareInfoWithoutThrow('pat_dialysis_count')"
          :max-value="99999"
          :min-value="0"
          :digits="5"
        />
      </td>
    </tr>
    <!--add FNSI-患者通算透析回数 じょはく end-->
    <tr>
      <!-- TODO: 上下限値検討 -->
      <td class="item-title">自施設通算特殊浄化回数</td>
      <td colspan="2" class="item-data">
        <custom-input-number
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :value="medicalCareInfo('purification_count')"
          :max-value="99999"
          :min-value="0"
          :digits="5"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </td>
    </tr>
    <tr>
      <td class="item-title">透析歴</td>
      <td colspan="2" class="item-data" v-if="!selectedVisitHst">
        {{ dialHstYear }} 年 {{ dialHstMonth }} ヶ月
      </td>
      <td colspan="2" class="item-data" v-else>
        不明
      </td>
    </tr>
  
    </tbody>
  </table>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import dayjs from "@/compat/date/dayjs";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { mapGetters, mapActions } from "@/compat/vue/vuex";

// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

export default {
  name: "MedicalCareInfoCard",
  mixins: [baseCardContent],
  components: {
    "common-master-selector": commonMasterSelector
  },

  data() {
    return {
      MasterType,
      mainMstCourse: null,
      dialysisMstCourse: null,
      mstWard: null,
      deleteMstWard: null,
      // add 編集権限の適用 じょはく start
      // add FNSI-患者通算透析回数 じょはく start
      patDialysisCount: "",
      courseName: "",
      dialysisDataName: "",
      wardName: "",
      // del #10359 編集権限の動作不正 dengshen start
      // // add FNSI-患者通算透析回数 じょはく end
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 じょはく end
      // del #10359 編集権限の動作不正 dengshen end

    };
  },
  // add 編集権限の適用 じょはく start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 じょはく end
  computed: {
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPat", "selectedPatId", "getIsOtherFacility", "getOtherFacilityCd"]),

    medicalCareComposeFacilityCd() {
      return this.getIsOtherFacility ? this.getOtherFacilityCd : this.getFacilityCd;
    },

    // 透析歴(年)
    dialHstYear() {
      const startDate = this.medicalCareInfo("dialysis_start_date").editValue;
      const year = dayjs().diff(startDate, "years");
      return year > 0 ? year : 0;
    },

    // 透析歴(月)
    dialHstMonth() {
      const startDate = this.medicalCareInfo("dialysis_start_date").editValue;
      const month = dayjs().diff(startDate, "months") % 12;
      return month > 0 ? month : 0;
    },

    selectedVisitHst() {
      const patInfo = deepCopy(this.selectedPat);
      try {
        const arrayPatInfo = JSON.parse(
          patInfo.pat_unique.in_out_visit_history_info
        );

        if (arrayPatInfo.length === 0) return true;
        const valPatInfo = arrayPatInfo.find(val => val.move_in_out === "1");
        if (!valPatInfo) return true;
        return !valPatInfo.period_start;
      } catch(error) {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('MedicalCareInfoCardContent.vue', 'selectedVisitHst', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        return false;
      }
    }
  },

  watch: {
    selectedPatId() {
      this.refreshData();
    },
    getOtherFacilityCd() {
      this.refreshData();
    }
  },

  created() {
    this.refreshData()
    // add FNSI-患者通算透析回数 じょはく start
    // if ( this.getPatCreateDataJson("medical_care_info", "pat_dialysis_count") === false ) {
    //   this.patDialysisCount = "";
    // } else {
    //   this.patDialysisCount = this.getPatCreateDataJson("medical_care_info", "pat_dialysis_count")
    // }
    if ( this.getPatCreateDataJson("medical_care_info", "pat_dialysis_count") === false ) {
      this.setPatDataJsonWithoutThrow("medical_care_info", "pat_dialysis_count", 0);
    }
    // add FNSI-患者通算透析回数 じょはく end
    // del #10359 編集権限の動作不正 dengshen start
    // // add 編集権限の適用 じょはく start
    // if ( this.isCreationPat ) {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    // } else {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // }
    // // add 編集権限の適用 じょはく end
    // del #10359 編集権限の動作不正 dengshen end
  },

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    medicalCareInfo(jsonKey) {
      return this.getPatDataJson("medical_care_info", jsonKey);
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      try {
        const requestParam = {
          facilityCd: this.getIsOtherFacility ? this.getOtherFacilityCd : this.getFacilityCd,
          selectedPatId: this.selectedPatId
        };

        ApiHelper.get("/mstInfo/mstCourseIncludeDel", requestParam)
          .then(response => {
            const mainCourseCd = this.medicalCareInfo('main_course_cd').editValue;
            const dialysisCourseCd = this.medicalCareInfo('dialysis_course_cd').editValue;
            const filterData = (data, code) => {
              return data.filter(x => (x.isDisp !== "0" && x.isDel !== "1") || x.courseCd === code);
            };
            // 診療科
            const mainDataFilter = filterData(response.data, mainCourseCd);
            this.mainMstCourse = mainDataFilter;
            this.courseName = this.mstCdToNameIncludeDeleted(
              this.mainMstCourse,
              this.medicalCareInfo("main_course_cd").editValue,
              "courseCd",
              "courseName"
            );
            // 透析実施科
            const dialysisDataFilter = filterData(response.data, dialysisCourseCd);
            this.dialysisMstCourse = dialysisDataFilter;
            this.dialysisDataName = this.mstCdToNameIncludeDeleted(
              this.dialysisMstCourse,
              this.medicalCareInfo("dialysis_course_cd").editValue,
              "courseCd",
              "courseName"
            );
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('MedicalCareInfoCardContent.vue', 'created', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });
        ApiHelper.get("/mstInfo/mstWardIncludeDel", requestParam)
          .then(response => {
            this.deleteMstWard = response.data;
            this.wardName = this.mstCdToNameIncludeDeleted(
              this.deleteMstWard,
              this.medicalCareInfo("ward_cd").editValue,
              "wardCd",
              "wardName"
            );
            const wardCd = this.medicalCareInfo('ward_cd').editValue;
            this.mstWard = response.data.map(item => {
              return {
                wardCd: item.wardCd,
                facilityCd: item.facilityCd,
                fnWardCd: item.fnCourseCd,
                wardName: (item.isDisp === "0" || item.isDel === "1") ? "【削除済み】" + item.wardName : item.wardName,
                inHospitalCd_1: item.inHospitalCd_1,
                isDisp: item.isDisp,
                isDel: item.isDel,
                regDate: item.regDate,
                upDate: item.upDate,
                operatorId: item.operatorId,
                clientIp: item.clientIp,
                logUserId: item.logUserId,
                updateFlg: item.updateFlg,
              };
            }).filter(item => (item.isDisp !== "0" && item.isDel !== "1") || item.wardCd === wardCd);
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('MedicalCareInfoCardContent.vue', 'created', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });
      } catch (error) {
        this.setLoadingScreenVisible(false);
      }
      // this.initRecord = deepCopy(this.editRecord);
      this.setLoadingScreenVisible(false);
    },
    medicalCareInfoWithoutThrow(jsonKey) {
      return this.getPatDataJsonWithoutThrow("medical_care_info", jsonKey);
    },

    // ポップオーバー確定イベントハンドラ
    setPopoverData(jsonKey, mstCd) {
      this.setPatDataJson("medical_care_info", jsonKey, mstCd);
    },

    getDialysisCourseCd() {
      if (this.medicalCareInfo("dialysis_course_cd").editValue !== undefined) {
        return this.medicalCareInfo("dialysis_course_cd").editValue;
      } else {
        return null;
      }
    },

    /**
     * @description 保存時に入外カードの最古の区分「導入」の日付・施設を導入施設・導入日として設定する
     */
    setOldestDialysis({ facilityCd, date }) {
      this.setPatDataJson("medical_care_info", "facility_cd", facilityCd);
      this.setPatDataJson("medical_care_info", "dialysis_start_date", date);
    },

    onMcMainCourseReturn(ev) {
      this.setPopoverData("main_course_cd", ev && ev.value != null ? ev.value : null);
      this.courseName = ev?.text;
    },

    onMcDialysisCourseReturn(ev) {
      this.setPopoverData("dialysis_course_cd", ev && ev.value != null ? ev.value : null);
      this.dialysisDataName = ev?.text;
    },

    onMcWardReturn(ev) {
      this.setPopoverData("ward_cd", ev && ev.value != null ? ev.value : null);
      this.wardName = ev?.text;
    }
  }
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/* カード個別のスタイルはここ */
/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
td .custom-textarea-edited {
  border: 2px green solid;
}
</style>
