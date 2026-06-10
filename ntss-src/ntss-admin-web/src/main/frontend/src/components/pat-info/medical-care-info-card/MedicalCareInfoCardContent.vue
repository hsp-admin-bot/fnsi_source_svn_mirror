<template>
  <table class="card-table">
    <tr>
      <td class="item-title">診療科</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="medicalCareInfo('main_course_cd')"
          :display-string="
            mstCdToNameIncludeDeleted(
              mainMstCourse,
              medicalCareInfo('main_course_cd').editValue,
              'courseCd',
              'courseName'
            )
          "
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
        <v-ons-button
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          ref="btnSelectCourse"
          class="common-style-select-button btn3-normal"
          @click="handleShowPopover('main_course_cd', popoverDataMstCourse)"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          選択
        </v-ons-button>
        <!-- 診療科選択ポップオーバー -->
        <pop-over
          v-bind="popoverDataMstCourse"
          :target-position-element="$refs.btnSelectCourse"
          @popover-close="closePopover(popoverDataMstCourse)"
          @popover-return="setPopoverData('main_course_cd', $event.value)"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">透析実施科</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="medicalCareInfo('dialysis_course_cd')"
          :display-string="
            mstCdToNameIncludeDeleted(
              dialysisMstCourse,
              medicalCareInfo('dialysis_course_cd').editValue,
              'courseCd',
              'courseName'
            )
          "
          :disabled="true"
          style="vertical-align: middle; color: #1f1f21;"
        />
      </td>
      <td class="item-data choice-button-area">
        <v-ons-button
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          ref="btnSelectDialCourse"
          class="common-style-select-button btn3-normal"
          @click="handleShowPopover('dialysis_course_cd', popoverDataMstDialysisCourse)"
        >
          選択
        </v-ons-button>
        <!-- 透析実施科選択ポップオーバー -->
        <pop-over
          v-bind="popoverDataMstDialysisCourse"
          :target-position-element="$refs.btnSelectDialCourse"
          @popover-close="closePopover(popoverDataMstDialysisCourse)"
          @popover-return="setPopoverData('dialysis_course_cd', $event.value)"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">病棟</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="medicalCareInfo('ward_cd')"
          :display-string="
            mstCdToNameIncludeDeleted(
              deleteMstWard,
              medicalCareInfo('ward_cd').editValue,
              'wardCd',
              'wardName'
            )
          "
          :disabled="true"
          style="vertical-align: middle; color: #1f1f21;"
        />
      </td>
      <td class="item-data choice-button-area">
        <v-ons-button
          ref="btnSelectWard"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          class="common-style-select-button btn3-normal"
          @click="handleShowPopover('ward_cd', popoverDataMstWard)"
        >
          選択
        </v-ons-button>
        <!-- 病棟選択ポップオーバー -->
        <pop-over
          v-bind="popoverDataMstWard"
          :target-position-element="$refs.btnSelectWard"
          @popover-close="closePopover(popoverDataMstWard)"
          @popover-return="setPopoverData('ward_cd', $event.value)"
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
  </table>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import moment from "moment";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { mapGetters, mapActions } from "vuex"; //施設コード取得のために追加
import { deepCopy } from "@/functions/common/CommonFunctions.js";
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

export default {
  name: "MedicalCareInfoCard",
  mixins: [baseCardContent],

  data() {
    return {
      popoverDataMstCourse: {},
      popoverDataMstDialysisCourse: {},
      popoverDataMstWard: {},
      popoverDataFacility: {},
      mainMstCourse: null,
      dialysisMstCourse: null,
      mstWard: null,
      deleteMstWard: null,
      popOverMainMstCourse: null,
      popOverDialysisMstCourse: null,
      // add 編集権限の適用 じょはく start
      // add FNSI-患者通算透析回数 じょはく start
      patDialysisCount: "",
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
    // 透析歴(年)
    dialHstYear() {
      const startDate = this.medicalCareInfo("dialysis_start_date").editValue;
      const year = moment().diff(startDate, "years");
      return year > 0 ? year : 0;
    },

    // 透析歴(月)
    dialHstMonth() {
      const startDate = this.medicalCareInfo("dialysis_start_date").editValue;
      const month = moment().diff(startDate, "months") % 12;
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

  // マスタ取得完了後にポップオーバーオブジェクトを作成
  watch: {
    selectedPatId() {
      this.refreshData();
    },
    // 診療科用
    mainMstCourse() {
      this.popoverDataMstCourse = this.createPopoverData(
        "診療科",
        null,
        null,
        "診療科名",
        this.popOverMainMstCourse,
        "courseCd",
        "courseName",
        null
      );
    },
    // 透析実施科用
    dialysisMstCourse() {
      this.popoverDataMstDialysisCourse = this.createPopoverData(
        "透析実施科",
        null,
        null,
        "透析実施科名",
        this.popOverDialysisMstCourse,
        "courseCd",
        "courseName",
        null
      );
    },

    mstWard() {
      this.popoverDataMstWard = this.createPopoverData(
        "病棟",
        null,
        null,
        "病棟名",
        this.mstWard,
        "wardCd",
        "wardName",
        null
      );
    },
    // add #12462 患者情報共有 Ji start
    getOtherFacilityCd() {
      this.refreshData();
    },
    // add #12462 患者情報共有 Ji end
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
	  // mod #12462 患者情報共有 Ji start
          // facilityCd: this.getFacilityCd
          facilityCd: this.getIsOtherFacility ? this.getOtherFacilityCd : this.getFacilityCd
	  // mod #12462 患者情報共有 Ji end
        };

        ApiHelper.get("/mstInfo/mstCourseIncludeDel", requestParam)
          .then(response => {
            const mainCourseCd = this.medicalCareInfo('main_course_cd').editValue;
            const dialysisCourseCd = this.medicalCareInfo('dialysis_course_cd').editValue;
            // ポップオーバーの選択肢
            const filterData = (data, code) => {
              return data.filter(x => (x.isDisp !== "0" && x.isDel !== "1") || x.courseCd === code);
            };
            // 画面表示マスタデータ
            const mapData = (data, code) => {
              return data.map(item => ({
                courseCd: item.courseCd,
                facilityCd: item.facilityCd,
                fnCourseCd: item.fnCourseCd,
                courseName: (item.isDisp === "0" || item.isDel === "1") ? "【削除済み】" + item.courseName : item.courseName,
                standardCourseCd: item.standardCourseCd,
                inHospitalCd_1: item.inHospitalCd_1,
                isDisp: item.isDisp,
                isDel: item.isDel,
                regDate: item.regDate,
                upDate: item.upDate,
                operatorId: item.operatorId,
                clientIp: item.clientIp,
                logUserId: item.logUserId,
                updateFlg: item.updateFlg,
              })).filter(item => (item.isDisp !== "0" && item.isDel !== "1") || item.courseCd === code);
            };
            // 診療科
            const mainDataFilter = filterData(response.data, mainCourseCd);
            const mainListFilter = mapData(response.data, mainCourseCd);
            this.mainMstCourse = mainDataFilter;
            this.popOverMainMstCourse = mainListFilter;
            // 透析実施科
            const dialysisDataFilter = filterData(response.data, dialysisCourseCd);
            const dialysisListFilter = mapData(response.data, dialysisCourseCd);
            this.dialysisMstCourse = dialysisDataFilter;
            this.popOverDialysisMstCourse = dialysisListFilter;
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
    handleShowPopover(jsonKey, popoverData) {
      popoverData.popoverContentSelected.value = this.editRecord['medical_care_info'][jsonKey].editValue;
      this.showPopover(popoverData);
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
