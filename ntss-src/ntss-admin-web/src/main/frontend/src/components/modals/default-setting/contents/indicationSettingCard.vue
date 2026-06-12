/**
 * デフォルト設定タブ - 指示受け・指示承認画面設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable v-model:expanded="isExpanded">
      <div class="top"><!-- OnsenUI挙動制御：自動挿入されるラッパー用divを予め書いておき適用されるスタイルを制御 -->
        <div class="center card-header color-header">
          {{ funcName }}
        </div>
        <div class="right"><!-- OnsenUI挙動制御：空にすることで矢印を抑制 --></div>
      </div>
      <div class="expandable-content card-contents">
        <table>
          <!-- 治療単位 -->
          <tbody v-show="isTreatmentUnit">
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">治療方法</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="mstTreatment"
                  v-model="treatmentCd"
                  data-text-field="treatmentName"
                  data-value-field="treatmentCd"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">クール</label>
              </td>
              <td class="default-setting-content">
                <kendo-multiselect
                  :data-source="mstKur"
                  v-model="kurCds"
                  data-text-field="kurName"
                  data-value-field="kurCd"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">ベッドグループ</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="mstRoomBedGroup"
                  v-model="bedGroupCd"
                  data-text-field="roomBedGroupName"
                  data-value-field="roomBedGroupCd"
                />
              </td>
            </tr>
            <tr v-show="columnStatus.isShowChecker1 || columnStatus.isShowChecker2 || columnStatus.isShowApprover1 || columnStatus.isShowApprover2">
              <td class="default-setting-content-title" colspan="2">
                <label class="default-setting-content-label">未指示受け、未指示承認の表示</label>
              </td>
            </tr>
            <tr v-show="columnStatus.isShowChecker1">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">未指示受け1のみ表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="checker1HasNotReceived"></v-ons-switch>
              </td>
            </tr>
            <tr v-show="columnStatus.isShowChecker2">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">未指示受け2のみ表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="checker2HasNotReceived"></v-ons-switch>
              </td>
            </tr>
            <tr v-show="columnStatus.isShowApprover1">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">未指示承認1のみ表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="approver1HasNotApproved"></v-ons-switch>
              </td>
            </tr>
            <tr v-show="columnStatus.isShowApprover2">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">未指示承認2のみ表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="approver2HasNotApproved"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">指示者</label>
              </td>
              <td class="default-setting-content-last-row">
                <kendo-dropdownlist
                  :data-source="mstPersonalUser"
                  v-model="instructorId"
                  data-text-field="userFullName"
                  data-value-field="userId"
                  :disabled="!hasAuthority"
                />
              </td>
            </tr>
          </tbody>

          <!-- 指示単位 -->
          <tbody v-show="! isTreatmentUnit">
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">治療予定日</label>-->
                <label id="pc-show-indication" class="default-setting-content-label white-space-nowrap">治療予定日</label>
                <label id="phone-show-indication" class="default-setting-content-label white-space-nowrap">治療予定日</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstTreatmentScheduledDate"
                  v-model="treatmentScheduledDate"
                  data-text-field="title"
                  data-value-field="value"
                  @select="onTreatmentScheduledDateSelect"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">クール</label>
              </td>
              <td class="default-setting-content">
                <kendo-multiselect
                  :data-source="mstKur"
                  v-model="indKurCds"
                  data-text-field="kurName"
                  data-value-field="kurCd"
                  :disabled="!isTreatmentScheduledDateSet"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">ベッドグループ</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="mstRoomBedGroup"
                  v-model="indBedGroupCd"
                  data-text-field="roomBedGroupName"
                  data-value-field="roomBedGroupCd"
                  :disabled="!isTreatmentScheduledDateSet"
                />
              </td>
            </tr>
            <tr v-show="columnStatus.isShowChecker1">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">指示受け1</label>
              </td>
              <td class="default-setting-content">
                <v-ons-radio
                  name="radio-check1"
                  value="1"
                  id="input-radio-check1-all"
                  class="switch-time-range"
                  v-model="check1"
                  modifier="round"
                />
                <label @click="clickRadioLabelCheck1('1')" class="label">すべて</label>
                <v-ons-radio
                  name="radio-check1"
                  value="2"
                  id="input-radio-check1-unchecked"
                  class="switch-time-range"
                  v-model="check1"
                  modifier="round"
                />
                <label @click="clickRadioLabelCheck1('2')" class="label">未</label>
                <v-ons-radio
                  name="radio-check1"
                  value="3"
                  id="input-radio-check1-already"
                  class="switch-time-range"
                  v-model="check1"
                  modifier="round"
                />
                <label @click="clickRadioLabelCheck1('3')" class="label">済</label>
              </td>
            </tr>
            <tr v-show="columnStatus.isShowChecker2">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">指示受け2</label>
              </td>
              <td class="default-setting-content">
                <v-ons-radio
                  name="radio-check2"
                  value="1"
                  id="input-radio-check2-all"
                  class="switch-time-range"
                  v-model="check2"
                  modifier="round"
                />
                <label @click="clickRadioLabelCheck2('1')" class="label">すべて</label>
                <v-ons-radio
                  name="radio-check2"
                  value="2"
                  id="input-radio-check2-unchecked"
                  class="switch-time-range"
                  v-model="check2"
                  modifier="round"
                />
                <label @click="clickRadioLabelCheck2('2')" class="label">未</label>
                <v-ons-radio
                  name="radio-check2"
                  value="3"
                  id="input-radio-check2-already"
                  class="switch-time-range"
                  v-model="check2"
                  modifier="round"
                />
                <label @click="clickRadioLabelCheck2('3')" class="label">済</label>
              </td>
            </tr>
            <tr v-show="columnStatus.isShowApprover1">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">指示承認1</label>
              </td>
              <td class="default-setting-content">
                <v-ons-radio
                  name="radio-approver1"
                  value="1"
                  id="input-radio-approver1-all"
                  class="switch-time-range"
                  v-model="approver1"
                  modifier="round"
                />
                <label @click="clickRadioLabelapprover1('1')" class="label">すべて</label>
                <v-ons-radio
                  name="radio-approver1"
                  value="2"
                  id="input-radio-approver1-unchecked"
                  class="switch-time-range"
                  v-model="approver1"
                  modifier="round"
                />
                <label @click="clickRadioLabelapprover1('2')" class="label">未</label>
                <v-ons-radio
                  name="radio-approver1"
                  value="3"
                  id="input-radio-approver1-already"
                  class="switch-time-range"
                  v-model="approver1"
                  modifier="round"
                />
                <label @click="clickRadioLabelapprover1('3')" class="label">済</label>
              </td>
            </tr>
            <tr v-show="columnStatus.isShowApprover2">
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">指示承認2</label>
              </td>
              <td class="default-setting-content">
                <v-ons-radio
                  name="radio-approver2"
                  value="1"
                  id="input-radio-approver2-all"
                  class="switch-time-range"
                  v-model="approver2"
                  modifier="round"
                />
                <label @click="clickRadioLabelapprover2('1')" class="label">すべて</label>
                <v-ons-radio
                  name="radio-approver2"
                  value="2"
                  id="input-radio-approver2-unchecked"
                  class="switch-time-range"
                  v-model="approver2"
                  modifier="round"
                />
                <label @click="clickRadioLabelapprover2('2')" class="label">未</label>
                <v-ons-radio
                  name="radio-approver2"
                  value="3"
                  id="input-radio-approver2-already"
                  class="switch-time-range"
                  v-model="approver2"
                  modifier="round"
                />
                <label @click="clickRadioLabelapprover2('3')" class="label">済</label>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">指示者</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="mstPersonalUser"
                  v-model="userId"
                  data-text-field="userFullName"
                  data-value-field="userId"
                  :disabled="!hasAuthority"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">対象指示</label>
              </td>
              <td class="default-setting-content-last-row">
                <kendo-multiselect
                  :data-source="indicationTargetDataSources"
                  v-model="indicationList"
                  data-text-field="name"
                  data-value-field="value"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

 <script>
   import {mapActions, mapGetters} from "@/compat/vue/vuex";
   /*add FNSI-改修内容4214 任 start*/

   /*add FNSI-改修内容4214 任 end*/
   import {DATE_CHOICES, INDICATION} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {AUTHORITY_CODES} from "@/constants/userAuthority";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/compat/vue/event-bus.js";
import { getScopedElementById, isScopedElementDisplayInline } from "@/functions/common/LayoutMeasureHelper";
   //add FNSI-5687 劉全航 end

   const ALL = "1";
const UNCHECKED = "2";
const ALREADY = "3";

export default {
  props: {
    // カード開閉初期状態
    defaultExpanded: {
      type: Boolean,
      default: true
    }
  },
  data() {
    // 治療予定日：未指定
    const unspecified = {
      title: "未指定",
      value: ""
    };
    return {
      // 対象の画面名
      funcName:"指示受け・指示承認",
      // データ初期値
      initialValue: {},
      // 編集する指示受け・指示承認設定レコード
      editRecord: {},
      // 治療予定日・選択肢
      lstTreatmentScheduledDate: [
        unspecified,
        DATE_CHOICES.TODAY
      ],
      indicationTargetDataSources: [
        { name: "クール", value: "クール" },
        { name: "治療開始時刻", value: "治療開始時刻" },
        { name: "ベッド", value: "ベッド" },
        { name: "治療時間", value: "治療時間" },
        { name: "VA", value: "VA" },
        { name: "目標体重", value: "目標体重" },
        { name: "除水量制限", value: "除水量制限" },
        { name: "ダイアライザ", value: "ダイアライザ" },
        { name: "吸着カラム", value: "吸着カラム" },
        { name: "1次膜", value: "1次膜" },
        { name: "2次膜", value: "2次膜" },
        { name: "穿刺針(A針)", value: "穿刺針(A針)" },
        { name: "穿刺針(V針)", value: "穿刺針(V針)" },
        { name: "穿刺針(SN)", value: "穿刺針(SN)" },
        { name: "シングルニードル使用", value: "シングルニードル使用" },
        { name: "血液回路", value: "血液回路" },
        { name: "血液量", value: "血液量" },
        { name: "透析液", value: "透析液" },
        { name: "透析液流量", value: "透析液流量" },
        { name: "透析液使用数", value: "透析液使用数" },
        { name: "透析液温度", value: "透析液温度" },
        { name: "補液", value: "補液" },
        { name: "補液量", value: "補液量" },
        { name: "補液選択", value: "補液選択" },
        { name: "補液使用数", value: "補液使用数" },
        { name: "補液温度", value: "補液温度" },
        { name: "補液速度", value: "補液速度" },
        { name: "抗凝固剤", value: "抗凝固剤" },
        { name: "抗凝固剤ワンショット量", value: "抗凝固剤ワンショット量" },
        { name: "抗凝固剤持続速度", value: "抗凝固剤持続速度" },
        { name: "抗凝固剤持続総量", value: "抗凝固剤持続総量" },
        { name: "IP使用選択", value: "IP使用選択" },
        { name: "IPスタート", value: "IPスタート" },
        { name: "IP速度", value: "IP速度" },
        { name: "IP速度最大値", value: "IP速度最大値" },
        { name: "IPワンショットスタート", value: "IPワンショットスタート" },
        { name: "IPワンショット量", value: "IPワンショット量" },
        { name: "IP電源自動切り", value: "IP電源自動切り" },
        { name: "IP電源自動切り時間", value: "IP電源自動切り時間" },
        { name: "IP電源OKモニタ切り", value: "IP電源OKモニタ切り" },
        { name: "IP電源OKモニタ切り時間", value: "IP電源OKモニタ切り時間" },
        { name: "投与薬剤", value: "投与薬剤" },
        { name: "医療材料", value: "医療材料" },
        { name: "指示コメント", value: "指示コメント" },
        { name: "治療予定", value: "治療予定" },
        { name: "治療方法", value: "治療方法" }
      ],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  methods: {
    ...mapActions("pat-event/list", [
      "fetchPatEventMaster"
    ]),
    ...mapActions("indication", [
      "checkFacilitySetting",
      "getMst"
    ]),
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: INDICATION.KEY_NAME,
        data: {}
      };
      rtnData.data[INDICATION.KEY_NAME_TREATMENT_CD] = this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD];
      // 治療単位と指示単位のクール、ベッドグループは別プロパティでDB登録する
      // 治療単位：kurCds
      rtnData.data[INDICATION.KEY_NAME_KUR_CDS] = this.editRecord[INDICATION.KEY_NAME_KUR_CDS];
      // 指示単位：indKurCds
      rtnData.data[INDICATION.KEY_NAME_IND_KUR_CDS] = this.editRecord[INDICATION.KEY_NAME_IND_KUR_CDS];
      // 治療単位：bedGroupCd
      rtnData.data[INDICATION.KEY_NAME_BED_GROUP_CD] = this.editRecord[INDICATION.KEY_NAME_BED_GROUP_CD];
      // 指示単位：indBedGroupCd
      rtnData.data[INDICATION.KEY_NAME_IND_BED_GROUP_CD] = this.editRecord[INDICATION.KEY_NAME_IND_BED_GROUP_CD];
      rtnData.data[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED] = this.editRecord[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED];
      rtnData.data[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED] = this.editRecord[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED];
      rtnData.data[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED] = this.editRecord[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED];
      rtnData.data[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED] = this.editRecord[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED];
      rtnData.data[INDICATION.KEY_NAME_INSTRUCTOR_ID] = this.editRecord[INDICATION.KEY_NAME_INSTRUCTOR_ID];
      rtnData.data[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] = this.editRecord[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE];
      rtnData.data[INDICATION.KEY_NAME_CHECK1] = this.editRecord[INDICATION.KEY_NAME_CHECK1];
      rtnData.data[INDICATION.KEY_NAME_CHECK2] = this.editRecord[INDICATION.KEY_NAME_CHECK2];
      rtnData.data[INDICATION.KEY_NAME_APPROVER1] = this.editRecord[INDICATION.KEY_NAME_APPROVER1];
      rtnData.data[INDICATION.KEY_NAME_APPROVER2] = this.editRecord[INDICATION.KEY_NAME_APPROVER2];
      rtnData.data[INDICATION.KEY_NAME_USER_ID] = this.editRecord[INDICATION.KEY_NAME_USER_ID];
      rtnData.data[INDICATION.KEY_NAME_INDICATION_LIST] = this.editRecord[INDICATION.KEY_NAME_INDICATION_LIST];
      return rtnData;
    },
    clickRadioLabelCheck1(mode) {
      this.check1 = mode;
    },
    clickRadioLabelCheck2(mode) {
      this.check2 = mode;
    },
    clickRadioLabelapprover1(mode) {
      this.approver1 = mode;
    },
    clickRadioLabelapprover2(mode) {
      this.approver2 = mode;
    },
    onTreatmentScheduledDateSelect(e) {
      const selectedDataItem = e?.dataItem;
      const selectedValue = selectedDataItem && typeof selectedDataItem === "object"
        ? selectedDataItem.value
        : (e?.value ?? this.treatmentScheduledDate);
      this.treatmentScheduledDate = selectedValue;
    }
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd", userAuthorityCds: "getUserAuthorityCds" }),
    ...mapGetters("indication", [
      "mstTreatment",
      "mstKur",
      "mstPersonalUser",
      "mstRoomBedGroup",
      "isTreatmentUnit",
      "columnStatus"
    ]),
    treatmentCd: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD];
      },
      set(value) {
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
        //this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD] = value;
        this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD] = Number(value);
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
      }
    },
    kurCds: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_KUR_CDS];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_KUR_CDS] = value;
      }
    },
    indKurCds: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_IND_KUR_CDS];
        },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_IND_KUR_CDS] = value;
      }
    },
    bedGroupCd: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    indBedGroupCd: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_IND_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_IND_BED_GROUP_CD] = value;
      }
    },
    checker1HasNotReceived: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED] = value;
      }
    },
    checker2HasNotReceived: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED] = value;
      }
    },
    approver1HasNotApproved: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED] = value;
      }
    },
    approver2HasNotApproved: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED] = value;
      }
    },
    instructorId: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_INSTRUCTOR_ID];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_INSTRUCTOR_ID] = value;
      }
    },
    treatmentScheduledDate: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] = value;
      }
    },
    check1: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_CHECK1];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_CHECK1] = value;
      }
    },
    check2: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_CHECK2];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_CHECK2] = value;
      }
    },
    approver1: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_APPROVER1];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_APPROVER1] = value;
      }
    },
    approver2: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_APPROVER2];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_APPROVER2] = value;
      }
    },
    userId: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_USER_ID];
      },
      set(value) {
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
        //this.editRecord[INDICATION.KEY_NAME_USER_ID] = value;
        this.editRecord[INDICATION.KEY_NAME_USER_ID] = Number(value);
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
      }
    },
    indicationList: {
      get() {
        return this.editRecord[INDICATION.KEY_NAME_INDICATION_LIST];
      },
      set(value) {
        this.editRecord[INDICATION.KEY_NAME_INDICATION_LIST] = value;
      }
    },
    ALL() {
      return ALL;
    },
    UNCHECKED() {
      return UNCHECKED;
    },
    ALREADY() {
      return ALREADY;
    },
    hasAuthority() {
      return this.userAuthorityCds.includes(AUTHORITY_CODES.IND_RECEIVE_PEDIT) || this.userAuthorityCds.includes(AUTHORITY_CODES.IND_RECEIVE_EDIT);
    },
    /**
     * 施設設定マスタのNo23で「2:指示単位」が選択されている場合、治療日が指定されているか否か
     */
    isTreatmentScheduledDateSet() {
      return this.treatmentScheduledDate ? true : false;
    }
  },
  watch: {
    //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "indicationSetting", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "indicationSetting", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
    /**
     * 治療予定日変更時の処理
     */
    treatmentScheduledDate(newVal) {
      // 未指定の場合はクール、ベッドグループを初期値でクリア
      if (!newVal) {
        this.indKurCds = [];
        // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている Start
        // this.indBedGroupCd = "";
        this.indBedGroupCd = "0";
        // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている End
      }
    }
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
    //this.initialValue[INDICATION.KEY_NAME_TREATMENT_CD] = 0;
    this.initialValue[INDICATION.KEY_NAME_TREATMENT_CD] = "0";
    //this.initialValue[INDICATION.KEY_NAME_KUR_CDS] = "";
    this.initialValue[INDICATION.KEY_NAME_KUR_CDS] = [];
    this.initialValue[INDICATION.KEY_NAME_IND_KUR_CDS] = [];
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end

    // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている Start
    // this.initialValue[INDICATION.KEY_NAME_BED_GROUP_CD] = "";
    this.initialValue[INDICATION.KEY_NAME_BED_GROUP_CD] = "0";
    // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている End
    this.initialValue[INDICATION.KEY_NAME_IND_BED_GROUP_CD] = "0";
    this.initialValue[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED] = false;
    this.initialValue[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED] = false;
    this.initialValue[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED] = false;
    this.initialValue[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED] = false;
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
    //this.initialValue[INDICATION.KEY_NAME_INSTRUCTOR_ID] = 0;
    this.initialValue[INDICATION.KEY_NAME_INSTRUCTOR_ID] = "0";
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end
    this.initialValue[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] = "";
    this.initialValue[INDICATION.KEY_NAME_CHECK1] = ALL;
    this.initialValue[INDICATION.KEY_NAME_CHECK2] = ALL;
    this.initialValue[INDICATION.KEY_NAME_APPROVER1] = ALL;
    this.initialValue[INDICATION.KEY_NAME_APPROVER2] = ALL;
    this.initialValue[INDICATION.KEY_NAME_USER_ID] = 0;
    this.initialValue[INDICATION.KEY_NAME_INDICATION_LIST] = [];

    // 施設設定マスタの情報取得
    await this.checkFacilitySetting();
    // 各マスタ情報を取得
    await this.getMst();

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[INDICATION.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD] == null) {
          this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD] = this.initialValue[INDICATION.KEY_NAME_TREATMENT_CD];
        } else if (!this.mstTreatment.some(t => +t.treatmentCd === +this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD])) {
          // NOTE: マスタ削除された場合、「0 : 全て」を再設定
          this.editRecord[INDICATION.KEY_NAME_TREATMENT_CD] = "0";
        }
        if (this.editRecord[INDICATION.KEY_NAME_KUR_CDS] == null) {
          this.editRecord[INDICATION.KEY_NAME_KUR_CDS] = this.initialValue[INDICATION.KEY_NAME_KUR_CDS];
        }
        if (this.editRecord[INDICATION.KEY_NAME_IND_KUR_CDS] == null) {
          this.editRecord[INDICATION.KEY_NAME_IND_KUR_CDS] = this.initialValue[INDICATION.KEY_NAME_IND_KUR_CDS];
        }
        if (this.editRecord[INDICATION.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[INDICATION.KEY_NAME_BED_GROUP_CD] = this.initialValue[INDICATION.KEY_NAME_BED_GROUP_CD];
        } else if (!this.mstRoomBedGroup.some(rbg => +rbg.roomBedGroupCd === +this.editRecord[INDICATION.KEY_NAME_BED_GROUP_CD])) {
          // NOTE: マスタ削除された場合、「0 : すべて」を再設定
          this.editRecord[INDICATION.KEY_NAME_BED_GROUP_CD] = "0";
        }
        if (this.editRecord[INDICATION.KEY_NAME_IND_BED_GROUP_CD] == null) {
          this.editRecord[INDICATION.KEY_NAME_IND_BED_GROUP_CD] = this.initialValue[INDICATION.KEY_NAME_IND_BED_GROUP_CD];
        } else if (!this.mstRoomBedGroup.some(rbg => +rbg.roomBedGroupCd === +this.editRecord[INDICATION.KEY_NAME_IND_BED_GROUP_CD])) {
          // NOTE: マスタ削除された場合、「0 : すべて」を再設定
          this.editRecord[INDICATION.KEY_NAME_IND_BED_GROUP_CD] = "0";
        }
        if (this.editRecord[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED] == null) {
          this.editRecord[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED] = this.initialValue[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED];
        }
        if (this.editRecord[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED] == null) {
          this.editRecord[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED] = this.initialValue[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED];
        }
        if (this.editRecord[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED] == null) {
          this.editRecord[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED] = this.initialValue[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED];
        }
        if (this.editRecord[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED] == null) {
          this.editRecord[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED] = this.initialValue[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED];
        }
        if (this.editRecord[INDICATION.KEY_NAME_INSTRUCTOR_ID] == null) {
          this.editRecord[INDICATION.KEY_NAME_INSTRUCTOR_ID] = this.initialValue[INDICATION.KEY_NAME_INSTRUCTOR_ID];
        } else if (!this.mstPersonalUser.some(pu => +pu.userId === +this.editRecord[INDICATION.KEY_NAME_INSTRUCTOR_ID])) {
          // NOTE: マスタ削除された場合、「0 : 未登録」を再設定
          this.editRecord[INDICATION.KEY_NAME_INSTRUCTOR_ID] = "0";
        }
        if (this.editRecord[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] == null) {
          this.editRecord[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] = this.initialValue[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE];
        }
        if (this.editRecord[INDICATION.KEY_NAME_CHECK1] == null) {
          this.editRecord[INDICATION.KEY_NAME_CHECK1] = this.initialValue[INDICATION.KEY_NAME_CHECK1];
        }
        if (this.editRecord[INDICATION.KEY_NAME_CHECK2] == null) {
          this.editRecord[INDICATION.KEY_NAME_CHECK2] = this.initialValue[INDICATION.KEY_NAME_CHECK2];
        }
        if (this.editRecord[INDICATION.KEY_NAME_APPROVER1] == null) {
          this.editRecord[INDICATION.KEY_NAME_APPROVER1] = this.initialValue[INDICATION.KEY_NAME_APPROVER1];
        }
        if (this.editRecord[INDICATION.KEY_NAME_APPROVER2] == null) {
          this.editRecord[INDICATION.KEY_NAME_APPROVER2] = this.initialValue[INDICATION.KEY_NAME_APPROVER2];
        }
        if (this.editRecord[INDICATION.KEY_NAME_USER_ID] == null) {
          this.editRecord[INDICATION.KEY_NAME_USER_ID] = this.initialValue[INDICATION.KEY_NAME_USER_ID];
        } else if (!this.mstPersonalUser.some(pu => +pu.userId === +this.editRecord[INDICATION.KEY_NAME_USER_ID])) {
          // NOTE: マスタ削除された場合、「0 : 未登録」を再設定
          this.editRecord[INDICATION.KEY_NAME_USER_ID] = 0;
        }
        if (this.editRecord[INDICATION.KEY_NAME_INDICATION_LIST] == null) {
          this.editRecord[INDICATION.KEY_NAME_INDICATION_LIST] = this.initialValue[INDICATION.KEY_NAME_INDICATION_LIST];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-indication", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-indication", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
};
</script>

<style scoped>
  /*add FNSI-改修内容4214 任 start*/
  @media (max-width: 500px){
    #pc-show-indication{display:none;}
  }
  @media (min-width: 501px){
    #phone-show-indication{display:none;}
    .label{
      margin-right: 10px;
    }
  }
  /*add FNSI-改修内容4214 任 end*/
</style>
