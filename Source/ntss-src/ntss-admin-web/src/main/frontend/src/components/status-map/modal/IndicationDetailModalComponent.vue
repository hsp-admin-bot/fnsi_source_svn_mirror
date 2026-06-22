<template>
  <modal-base @onClose="closeIndicationModal" class="custom-modal">
    <template #header>
      <div>
        <component :is="header"></component>
      </div>
    </template>
    <template #body>
      <div>
        <div class="modal-content d-flex flex-column" :style="{ 'height':tableHeight + 'px' }">
        <!-- mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start -->
        <!-- Grid -->
        <div>
          <table class="grid status-map-pat-ind-modal-list">
            <thead>
            <tr>
              <th class="col-header th-sticky" colspan="2"></th>
              <th class="col-header th-sticky">{{ dispDate }}</th>
              <th class="col-header th-sticky">指示者</th>
              <th class="col-header th-sticky">入力者</th>
            </tr>
            </thead>
            <template v-for="subCategory in layout">
              <template v-if="subCategory.subCategoryItem.length >= 0 && !subCategory.hasOwnProperty('itemInfo')">
                <tr v-for="(item, itemIdx) in subCategory.subCategoryItem" :key="`${subCategory.subCategoryNo}${subCategory.subCategoryNo !== 6 ? item.itemInfo.itemNo : item.itemInfo.itemCd}`"
                  :class="{'content-change': isContentChangeWithUnit(item.itemInfo, subCategory.subCategoryNo)}">
                  <td class="cat-header" v-if="itemIdx === 0" :rowspan="subCategory.subCategoryItem.length">
                    <span>{{ subCategory.subCategoryName }}</span>
                  </td>
                  <td class="sub-cat-header">{{ item.itemInfo.itemName }}</td>
                  <!--#10407:変更なしでも画面を表示させる Start-->
                  <td class="sub-category-item item-value {'whiteThemeBackground' : getTheme === 0} {'darkThemeBackground' : getTheme === 1}"
                      :class="[{ 'is-disabled' : item.itemInfo.data.isDisable }, { 'hide-text' : item.itemInfo.data.isDisable }]"
                  >
                  <!--#10407:変更なしでも画面を表示させる End-->
                    <span v-if="isContentChangeExtends(item.itemInfo, subCategory.subCategoryNo)">
                      <span v-if="item.itemInfo.status === undefined">
                        {{getLeftItemValue(item.itemInfo, subCategory.subCategoryNo)}}&nbsp;&rarr;&nbsp;
                      </span>
                    </span>
                    {{ getItemValue(item.itemInfo, subCategory.subCategoryNo) }}
                    <!-- #8535 ⑤投与薬剤、医療材料、指示コメントを中止した際、治療状況リスト、マップは「変更あり」の表示となるが、指示変更内容モーダルに変更内容が表示されない。林峻峰 start -->
                    <span v-if="item.itemInfo.status === 2">&nbsp;&rarr;&nbsp;(中止)</span>
                    <!-- #8535 ⑤投与薬剤、医療材料、指示コメントを中止した際、治療状況リスト、マップは「変更あり」の表示となるが、指示変更内容モーダルに変更内容が表示されない。林峻峰 end -->
                  </td>
                  <td class="sub-category-item instructor" :class="{ 'is-disabled' : item.itemInfo.data.isDisable }">{{ item.itemInfo.data.instructor }}</td>
                  <td class="sub-category-item updater" :class="{ 'is-disabled' : item.itemInfo.data.isDisable }">{{ item.itemInfo.data.updater }}</td>
                </tr>
              </template>
              <tr v-else :key="subCategory.subCategoryNo" :class="{'content-change': isContentChange(subCategory)}">
                <td colspan="2" class="cat-header align-items-center">{{ subCategory.subCategoryName }}</td>
                <td class="sub-category-item">
                  <div class="header d-flex align-items-center">
                  <span v-if="isContentChangeWithUnit(subCategory.itemInfo, subCategory.subCategoryNo)">
                    {{ getLeftTreatMethod(subCategory.subCategoryNo) }}&nbsp;&rarr;&nbsp;
                </span>
                  {{ getTreatMethod(subCategory) }}
                </div>
                </td>
                <td class="sub-category-item instructor">
                  {{ subCategory.itemInfo.data.instructor }}
                </td>
                <td class="sub-category-item updater">
                  {{ subCategory.itemInfo.data.updater }}
                </td>
              </tr>
            </template>
          </table>
        </div>
        <!-- / Grid -->
        <!-- mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end -->

        <!-- Loading -->
        <v-ons-modal :visible="isLoading">
          <p class="loading-modal">
            {{ loadingMessage }}
            <v-ons-icon icon="fa-spinner" spin />
          </p>
        </v-ons-modal>
        <!-- / Loading -->
      </div>
      </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
      <div class="denial-btn-area" style="background:none">
        <button class="button denial-btn btn2-cancel" @click="closeIndicationModal">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!--#10407:変更なしでも画面を表示させる Start-->
        <button class="button registration-btn btn1-execute" :disabled="!editState()"  @click="save">確認OK</button>
        <!--#10407:変更なしでも画面を表示させる End-->
      </div>
      <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import _ from "@/compat/collections/lodash";
import Indication from "@/apis/indication";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  va as getMstVA,
  dialyzer as getMstDialyzer,
  equipment as getMstEquipment,
  medicine as getMstMedicine,
  medicineMix as getMstMedicineMix
} from "@/functions/mst/MstGetters.js";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { getPatById } from "@/functions/PatInfoFunctions.js";
import BigNumber from "@/compat/number/bignumber";
import { EventBus } from "@/compat/vue/event-bus.js";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getModalBodyElement } from "@/functions/common/LayoutMeasureHelper";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
export default {
  mixins: [MasterMaintenanceMixin],
  name: "IndicationDetailComponent",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      header: "",
      layout: null,
      layoutCategoryNo: 1,
      layoutSubCategoryNo: [2, 3, 4, 5, 6, 7],
      ordDetail: null,
      patIndApprove: null,
      patPersonal: null,
      mstBed: [],
      mstVA: [],
      mstDialyzer: [],
      mstEquipment: [],
      mstMedicine: [],
      mstMedicineMix: [],
      selectedPat: [],
      checkedData: {},
      selectedStaffCd1: "",
      selectedStaffCd2: "",
      isLoading: false,
      loadingMessage: "",
      RECEIVE: "receive",
      SIGN_TYPE: {
        REMOVE: "0",
        SETTING: "1"
      },
      tableHeight: 100,
      tableTop: 2
    };
  },
  computed: {
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    ...mapGetters("indication", [
      "mstTreatment",
      "mstTreatmentDel",
      "mstKur",
      "mstPersonalUser",
      "userId",
      "indicationsUnchecked",
      "indContent"
    ]),
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("treatment-record/common", ["getOrdNoForSideBarRecord"]),
    ...mapGetters("status-map/ind", ["getOrdNo"]),
    //#10407:変更なしでも画面を表示させる Start
    ...mapGetters("account-edit", {
      getTheme: "getTheme"
    }),
    //#10407:変更なしでも画面を表示させる End
    isApproving() {
      return this.$route.name === "indication-approve-detail";
    },
    isReceive() {
      return this.$route.params.method === this.RECEIVE ? true : false;
    },
    dispDate() {
      if (this.ordDetail && this.ordDetail.treatDate) {
        return dayjs(this.ordDetail.treatDate, "YYYYMMDD").format(
          "YYYY/MM/DD(ddd)");
      }
      return "";
    }
  },
  watch: {
    async $route() {
      this.layout = null;
      this.ordDetail = null;
      this.patIndApprove = null;
      this.patPersonal = null;
      this.checkedData = {};
      this.selectedStaffCd1 = "";
      this.selectedStaffCd2 = "";

      await this.getIndicationDetail();
      this.convertIndData();
    }
  },
  methods: {
    //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    ...mapActions("indication", [
      "getPatPersonal", "setIndicationsUnchecked", "setIndContent"
    ]),
    //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("bread-crumb", ["resetTitle"]),
    ...mapActions("indication", [
      "getPatPersonal",
      "setIndicationsUnchecked",
      "getMst"
    ]),
    ...mapActions("status-map/ind", {
      setIndOrdNo: "setOrdNo",
      checkForMap: "checkForMap"
    }),
    ...mapActions("multi-modal", ["showIndicationsHistoryModal"]),
    async getIndicationDetail() {
      try {
        this.startLoading("指示情報を取得しています");
        const ordNo = this.getOrdNo;
        const [
          [ordDetail, patIndApprove],
          mstBed,
          mstVA,
          mstDialyzer,
          mstEquipment,
          mstMedicine,
          mstMedicineMix,
        ] = await Promise.all([
          Indication.getIndicationDetail(ordNo),
          this.getMstBed(),
          getMstVA(this.facilityCd),
          getMstDialyzer(this.facilityCd),
          getMstEquipment(this.facilityCd),
          getMstMedicine(this.facilityCd),
          getMstMedicineMix(this.facilityCd)
        ]);
        //#10407:変更なしでも画面を表示させる Start

        if (patIndApprove != undefined && patIndApprove != null) {
          let patInfo = null;
          if (ordDetail.patId != null) {
              patInfo = await getPatById(ordDetail.patId).catch(() => {
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
              getErrorMessage('IndicationDetailModalComponent.vue','getIndicationDetail','[IndicationDetailModalComponent.vue]: 患者取得失敗');
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
              //#10407:変更なしでも画面を表示させる Start End SystemError スルー
              });
          }
          if (ordDetail.patId != null) this.selectedPat = patInfo;
          //#10407:変更なしでも画面を表示させる End
          const selectedStaffCd1 = this.isApproving
            ? patIndApprove.approve_user1_cd
            : patIndApprove.check_user1_cd;

          this.selectedStaffCd1 = selectedStaffCd1 ? selectedStaffCd1 + "" : null;

          const selectedStaffCd2 = this.isApproving
            ? patIndApprove.approve_user2_cd
            : patIndApprove.check_user2_cd;

          this.selectedStaffCd2 = selectedStaffCd2 ? selectedStaffCd2 + "" : null;

          ordDetail.indCondInfo = JSON.parse(ordDetail.indCondInfo);
          ordDetail.indMediInfo = JSON.parse(ordDetail.indMediInfo);
          ordDetail.indEquipInfo = JSON.parse(ordDetail.indEquipInfo);
          ordDetail.indIndCommentInfo = JSON.parse(ordDetail.indIndCommentInfo);
          ordDetail.indScheduleUserInfo = JSON.parse(
            ordDetail.indScheduleUserInfo
          );
          this.ordDetail = ordDetail;

          patIndApprove.content_for_map = JSON.parse(
            patIndApprove.content_for_map
          );
          this.patIndApprove = patIndApprove;

          this.mstBed = mstBed;
          this.mstVA = mstVA;
          this.mstDialyzer = mstDialyzer;
          this.mstEquipment = mstEquipment;
          this.mstMedicine = mstMedicine;
          this.mstMedicineMix = mstMedicineMix;
          //#10407:変更なしでも画面を表示させる Start
          if (ordDetail.patId != null) await this.getPatPersonal(this.ordDetail.patId);
        }
        //#10407:変更なしでも画面を表示させる End
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('IndicationDetailModalComponent.vue','getIndicationDetail',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        //#10407:変更なしでも画面を表示させる Start End SystemError スルー
      }

      this.stopLoading();
    },
    async getMstBed() {
      const res = await ApiHelper.get("/mstInfo/mstBed", {
        facility_cd: this.facilityCd,
        is_disp: 1,
        is_del: 0
      });
      return res.data;
    },
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    async convertIndData() {
      if (!this.ordDetail) {
        return;
      }

      this.startLoading("レイアウトを表示しています。");
      await this.setIndContent({ordDetail: this.ordDetail, selectedPat: this.selectedPat});
      this.layout = this.indContent;
      this.mergeCancelledData('content_for_map');
      this.convertCheckedData("content_for_map");
      this.stopLoading();
    },
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
    mergeCancelledData(content) {
      if (_.isEmpty(this.patIndApprove[content])) return;
      // 中止した投与薬剤/医療材料/指示コメントをlayoutにマージする
      // this.patIndApprove: pat_ind_approve(指示受け承認情報) -> 中止前のデータ
      // this.layout       : ord_main(治療情報)                -> 中止後のデータ（画面表示内容）
      this.layout.forEach((subCategory) => {
        if ([5, 6, 7].includes(subCategory.subCategoryNo)) {
          const currentSubCategory = this.patIndApprove[content]?.filter(item => item.subCategoryNo === subCategory.subCategoryNo) || [];
          const itemNoSet = new Set(subCategory.subCategoryItem.map(item => item.itemInfo.itemNo));//O(n) → O(1)
          if (currentSubCategory[0].subCategoryItem && currentSubCategory[0].subCategoryItem.length > 0) {
            currentSubCategory[0].subCategoryItem.forEach((e) => {
              const itemIdx = 6 === subCategory.subCategoryNo ? e.itemInfo.itemCd : e.itemInfo.itemNo;
              if (!itemNoSet.has(itemIdx)) {
                subCategory.subCategoryItem.push({
                  itemInfo: {
                    itemName: e.itemInfo.itemName,
                    itemNo: 6 === subCategory.subCategoryNo ? e.itemInfo.itemCd : e.itemInfo.itemNo * -1,
                    itemCd: e.itemInfo.itemCd,
                    itemType: e.itemInfo.itemType,
                    status: 2,  // 中止 ※治療状況リスト・マップ > 指示変更内容の実装と合わせる
                    data: {...e.itemInfo.data}
                  }
                });
              }
            });
          }
        }
      })
    },
    convertCheckedData(content) {
      if (_.isEmpty(this.patIndApprove[content])) return;
      this.patIndApprove[content].forEach(
        ({itemInfo, subCategoryItem, subCategoryNo}) => {
          if (subCategoryNo === 2) {
            this.checkedData[`${subCategoryNo}0`] = itemInfo;
          } else if (subCategoryNo === 6) {
            subCategoryItem.forEach((e) => {
              e.itemInfo.itemNo = e.itemInfo.itemCd;
              this.checkedData[`${subCategoryNo}${e.itemInfo.itemCd}`] = e.itemInfo;
            });
          } else {
            subCategoryItem.forEach((e) => {
              const itemNo = e.itemInfo.itemNo;
              this.checkedData[`${subCategoryNo}${itemNo}`] = e.itemInfo;
            });
          }
        }
      );
    },

    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    getTreatMethod(subCategory) {
      let prefix = subCategory.itemInfo.data.value.prefix !== null ? subCategory.itemInfo.data.value.prefix : "";
      let dispVal = subCategory.itemInfo.data.value.dispVal !== null ? subCategory.itemInfo.data.value.dispVal : "未登録";
      return prefix + dispVal;
    },
    getLeftTreatMethod(subCategoryNo) {
      let value = this.checkedData[`${subCategoryNo}0`]?.data.value;
      let prefix = value.prefix !== null ? value.prefix : "";
      let dispVal = value.dispVal !== null ? value.dispVal : "未登録";
      return prefix + dispVal;
    },
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
    async cancel() {
      this.closeIndicationModal();
    },
    async save() {
      this.startLoading("指示を確認しています。");
      // #8535 ⑤投与薬剤、医療材料、指示コメントを中止した際、治療状況リスト、マップは「変更あり」の表示となるが、指示変更内容モーダルに変更内容が表示されない。林峻峰 start
      this.layout.forEach((subCategory)=>{
        if ([5, 6, 7].includes(subCategory.subCategoryNo)) {
          subCategory.subCategoryItem = subCategory.subCategoryItem.filter((item) => {
            return item.itemInfo.status !== 2;
          });
        }
        if (6 === subCategory.subCategoryNo) {
          subCategory.subCategoryItem.forEach(item => {
            item.itemInfo.itemNo = null;
          })
        }
      })
      // #8535 ⑤投与薬剤、医療材料、指示コメントを中止した際、治療状況リスト、マップは「変更あり」の表示となるが、指示変更内容モーダルに変更内容が表示されない。林峻峰 end
      try {
        const ordNo = this.getOrdNo;
        await this.checkForMap({
          ordNo: ordNo,
          content: JSON.stringify(this.layout)
        });
        this.closeIndicationModal();
        EventBus.$emit("refresh");
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('IndicationDetailModalComponent.vue','save',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.internalServerError(error);
      }
      this.stopLoading();
    },

    //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    getItemValue(item, subCategoryNo) {
      if ((item.itemNo === 20 && item.data.value.dispVal === "-1" && item.data.value.unit === "L")
        || (item.itemNo === 24 && item.data.value.dispVal === "-1" && item.data.value.unit === "L/h")) {
        return "濾過率から算出";
      }
      let prefix = item.data.value.prefix ? item.data.value.prefix : "";
      let dispVal = item.data.value.dispVal ? item.data.value.dispVal : "未登録";
      let unit = item.data.value.unit ? item.data.value.unit : "";
      if (4 === subCategoryNo && [2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25].includes(item.itemNo)) {
        unit = "";
      }

      let leftIsDisable = this.checkedData[`${subCategoryNo}${item.itemNo}`]?.isDisable || false;
      let rightIsDisable = item.data.isDisable || false;
      let res = unit ? `${prefix}${dispVal} ${unit}` : `${prefix}${dispVal}`;
      if (res === '未登録' && !leftIsDisable && rightIsDisable) {
        res = '(未登録)';
      }
      return res;
    },
    getLeftItemValue(itemInfo, subCategoryNo) {
      // let value = this.checkedData[`${subCategoryNo}${itemInfo.itemNo}`].value;
      let value = this.checkedData[`${subCategoryNo}${itemInfo.itemNo}`]?.data.value;
      // const rstDialysisState = this.ordDetail.rstDialysisState;
      if (value == null) {
        return '(新規)';
      }
      let prefix = value.prefix ? value.prefix : "";
      let dispVal = value.dispVal;
      let unit = value.unit;
      if ((itemInfo.itemNo === 20 && dispVal === "-1" && unit === "L")
        || (itemInfo.itemNo === 24 && dispVal === "-1" && unit === "L/h")) {
        return "濾過率から算出";
      }
      let val = `${prefix}${dispVal}`;
      let res;
      // if (rstDialysisState == "0") {
        if (val && val === '未登録') {
          res = val;
        } else {
          // res = val ? val + `${unit ? " " + unit : ""}` : '(新規)';
          if (4 === subCategoryNo && [2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25].includes(itemInfo.itemNo)) {
            res = val ? val : '(新規)';
          } else {
            res = val ? val + `${unit && "DWと同じ" !== dispVal ? " " + unit : ""}` : '(新規)';
          }
        }
      // } else {
      //   res = val ? val : '(新規)';
      // }

      let leftIsDisable = this.checkedData[`${subCategoryNo}${itemInfo.itemNo}`]?.isDisable || false;
      let rightIsDisable = itemInfo.data.isDisable || false;
      if (res === '未登録' && leftIsDisable && !rightIsDisable) {
        res = '(未登録)';
      }

      return res;
    },

    isContentChangeExtends(itemInfo, subCategoryNo = 0) {
      let leftIsDisable = this.checkedData[`${subCategoryNo}${itemInfo.itemNo}`]?.isDisable || false;
      let rightIsDisable = itemInfo.data.isDisable || false;
      const itemNo = itemInfo.itemNo;
      const dialysisState = this.ordDetail.rstDialysisState;

      if ([5, 6, 7].includes(subCategoryNo)) {
        // 投与薬剤、医療材料、指示コメント
        if (itemNo !== 0 && !_.isEmpty(this.checkedData) &&                   // チェック済み状態
          (this.checkedData[`${subCategoryNo}0`] === ""                         // 新規登録
            || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined)) {  // 追加
          return true;
        }
      }
      if (this.checkedData[`${subCategoryNo}${itemNo}`] === null || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined) return false;
      // const checkedData = this.checkedData[`${subCategoryNo}${itemNo}`].value;
      const checkedData = this.checkedData[`${subCategoryNo}${itemNo}`].data.value;

      let unit = itemInfo.data.value.unit ? " " + itemInfo.data.value.unit : "";
      let dispVal = itemInfo.data.value.dispVal;
      let prefix = itemInfo.data.value.prefix ? itemInfo.data.value.prefix : "";
      let val = dispVal;
      if (dialysisState !== "0") {
        val = prefix + dispVal + unit;
      }

      let dispValChk = checkedData.dispVal;
      let prefixChk = checkedData.prefix ? checkedData.prefix : "";
      let unitChk = checkedData.unit ? " " + checkedData.unit : "";
      let checkedDataTmp = undefined;
      if (this.isNumber(dispValChk)) {
        checkedDataTmp = BigNumber(dispValChk).toFixed();
      }
      let valueTmp = undefined;
      if (this.isNumber(val)) {
        valueTmp = BigNumber(val).toFixed();
      }
      if (dialysisState == "0" && this.isNumber(checkedDataTmp) && this.isNumber(valueTmp)) {
        if (checkedDataTmp !== valueTmp) return true;
        if ((leftIsDisable && !rightIsDisable) || (!leftIsDisable && rightIsDisable)) return true;
        return false;
      }

      if (dispValChk === null || dispValChk === undefined) return false;

      if (prefixChk + dispValChk + unitChk !== val) return true;

      if ((leftIsDisable && !rightIsDisable) || (!leftIsDisable && rightIsDisable)) return true;
    },
    isContentChangeWithUnit(itemInfo, subCategoryNo = 0) {
      if(itemInfo == null){
        return true;
      }
      if(Object.keys(this.checkedData).length === 0) {
        return false;
      }
      let itemNo = itemInfo.itemNo;
      if(subCategoryNo == 2) { // 治療方法
        itemNo = 0;
      }
      // if (this.checkedData[`${subCategoryNo}${itemNo}`] === null || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined) return false;
      if (this.checkedData[`${subCategoryNo}${itemNo}`] === null || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined) return true;

      if (2 === itemInfo.status) {
        return true;
      }

      const dialysisState = this.ordDetail.rstDialysisState;
      const checkedDataItemInfo = this.checkedData[`${subCategoryNo}${itemNo}`];
      const checkedData = checkedDataItemInfo.data.value;

      let itemCdChk = checkedDataItemInfo.itemCd;
      let prefixChk = checkedData.prefix ? checkedData.prefix : "";
      let dispValChk = checkedData.dispVal;
      dispValChk = this.isNumber(dispValChk)?BigNumber(dispValChk ? dispValChk : 0).toFixed():dispValChk;
      let unitChk = checkedData.unit ? " " + checkedData.unit : "";

      let itemCd = itemInfo.itemCd;
      let prefix = itemInfo.data.value.prefix ? itemInfo.data.value.prefix : "";
      let dispVal = itemInfo.data.value.dispVal;
      dispVal = this.isNumber(dispVal)?BigNumber(dispVal ? dispVal : 0).toFixed():dispVal;
      let unit = itemInfo.data.value.unit ? " " + itemInfo.data.value.unit : "";

      if(subCategoryNo == 2) { // 治療方法
        if (dialysisState == "0") {
          return (itemCdChk != itemCd);
        } else {
          return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
        }
      } else if (subCategoryNo == 3) { // スケジュール
        // 1: クール
        // 3: ベッド
        if ([1,3].includes(itemNo)) {
          if (dialysisState == "0") {
            return (itemCdChk != itemCd);
          } else {
            return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
          }
        }
        // 2: 治療開始時刻
        if ([2].includes(itemNo)) {
          return (prefixChk + dispValChk != prefix + dispVal);
        }
      } else if (subCategoryNo == 4) { // 治療条件
        //no key → have key ： leftIsDisable && !rightIsDisable && prefixChk + dispValChk + unitChk === val       true
        //have key → no key ： !leftIsDisable && rightIsDisable && prefixChk + dispValChk + unitChk === val       true
        //have key → have key ： 正常比较
        //no key → no key ： false 灰色
        let leftIsDisable = checkedDataItemInfo.isDisable || false;
        let rightIsDisable = itemInfo?.data.isDisable || false;
        if ((leftIsDisable && !rightIsDisable) || (!leftIsDisable && rightIsDisable)) {
          return true;
        }
        // 2:  VA
        // 5:  ダイアライザ
        // 6:  吸着カラム
        // 7:  1次膜
        // 8:  2次膜
        // 9:  穿刺針(A針)
        // 10: 穿刺針(V針)
        // 11: 穿刺針(SN)
        // 13: 血液回路
        // 15: 透析液
        // 19: 補液
        // 25: 抗凝固剤
        if ([2,5,6,7,8,9,10,11,13,15,19,25].includes(itemNo)) {
          if (dialysisState === "0") {
            return (itemCdChk !== itemCd);
          } else {
            return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
          }
        }
        // -1:  dw
        // 1:  治療時間
        // 3:  目標体重
        // 4:  除水量制限
        // 12: シングルニードル使用
        // 14: 血流量
        // 16: 透析液流量
        // 17: 透析液使用数
        // 18: 透析液温度
        // 20: 補液量
        // 21: 補液選択
        // 22: 補液使用数
        // 23: 補液温度
        // 24: 補液速度
        // 26: 抗凝固剤ワンショット量
        // 27: 抗凝固剤持続速度
        // 28: 抗凝固剤持続総量
        // 29: IP使用選択
        // 30: IPスタート
        // 31: IPワンショット量
        // 32: IP速度
        // 33: IP速度最大値
        // 34: IPワンショットスタート
        // 35: IP電源自動切り
        // 36: IP電源自動切り時間
        // 37: IP電源OKモニタ切り
        // 38: IP電源OKモニタ切り時間
        if ([-1,1,3,4,12,14,16,17,18,20,21,22,23,24,26,27,28,29,30,31,32,33,34,35,36,37,38].includes(itemNo)) {
          if (dialysisState === "0") {
            return (dispValChk !== dispVal);
          } else {
            return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
          }
        }
      } else if ([5, 6].includes(subCategoryNo)) { // 投与薬剤, 医療材料
        if (itemNo !== 0 && !_.isEmpty(this.checkedData) &&                   // チェック済み状態
          (this.checkedData[`${subCategoryNo}0`] === ""                         // 新規登録
            || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined)) {  // 追加
          return true;
        }
        if (itemCdChk !== itemCd) {
          return false;
        }
        if (dialysisState === "0") {
          return (prefixChk + dispValChk) !== (prefix + dispVal);
        } else {
          return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit);
        }
      } else if (subCategoryNo === 7) { // 指示コメント
        if (itemNo !== 0 && !_.isEmpty(this.checkedData) &&                   // チェック済み状態
          (this.checkedData[`${subCategoryNo}0`] === ""                         // 新規登録
            || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined)) {  // 追加
          return true;
        }
        return (dispValChk !== dispVal);
      }
    },
    isNumber(value) {
      const regex = /^-?\d+(\.\d+)?$/;
      return regex.test(value);
    },
    //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    isContentChange(subCategory, itemNo = 0) {
      if (2 === subCategory.subCategoryNo) {
        if (subCategory.itemInfo.length === 0) {
          return false;
        }
      } else {
        if (subCategory.subCategoryItem.length === 0) {
          return false;
        }
      }

      if(Object.keys(this.checkedData).length === 0) {
        return false;
      }

      let value = subCategory.itemInfo.data.value;
      let prefix = value.prefix != null ? value.prefix : "";
      let dispVal = value.dispVal;
      let subCategoryNo = subCategory.subCategoryNo;

      if (this.checkedData[`${subCategoryNo}${itemNo}`] === null || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined) return false;
      const checkedData = this.checkedData[`${subCategoryNo}${itemNo}`].data.value;

      let prefixChk = checkedData.prefix ? checkedData.prefix : "";
      let dispValChk = checkedData.dispVal;

      return prefix + dispVal !== prefixChk + dispValChk;
    },
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

    //#10407:変更なしでも画面を表示させる Start
    editState() {
      if (this.patIndApprove && this.patIndApprove.is_content_changed_for_map) {
          return this.patIndApprove.is_content_changed_for_map === "1";
      }
      return false;
    },
    //#10407:変更なしでも画面を表示させる End
    startLoading(message) {
      this.isLoading = true;
      this.loadingMessage = message;
    },
    stopLoading() {
      this.isLoading = false;
    },
    internalServerError(error) {
      console.log(error);
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー",
      //   callback: () => {
      //     this.$router.push({ name: "signin" });
      //   }
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message)  , {
        title: DIALOG_MESSAGES['00200002'].title,
        callback: () => {
          this.$router.push({ name: "signin" });
        }
      });
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
    },
    // モーダルの高さからtableコンポーネント領域の高さを算出
    onResize() {
      const mb = getModalBodyElement(this.$el || this);
      if (mb) {
        const mbh = mb.clientHeight;

        this.tableHeight = mbh - 3;
        this.tableHeight = this.tableHeight < 100 ? 100 : this.tableHeight;
        // モーダルの高さからGirdコンポーネント領域のTopを算出
        this.$nextTick(() => {
          this.tableTop = 3;
        });
      }
    },

    closeIndicationModal() {
      // モーダルを非表示に
      this.hideModal();
    }
  },
  async created() {
    this.getMst(this.facilityCd);
    if (this.getOrdNo) {
      await this.getIndicationDetail();
      this.convertIndData();
    }
  },
  mounted() {
    this.$nextTick(async () => {
      (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize", this.onResize);
      this.onResize();
      EventBus.$emit("stopMapPolling");
      EventBus.$emit("stopListPolling");
    });
  },
  beforeUnmount() {
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.onResize);
    this.setIndOrdNo(null);
    EventBus.$emit("startMapPolling");
    EventBus.$emit("startListPolling");
  }
};
</script>

<style scoped>
.modal-content {
  font-size: 1.25em;
}

.loading-modal {
  font-size: 2.4em;
}
.grid {
  max-height: 100%;
  overflow-y: hidden;
  overflow-x: auto;
  margin-left: 3px;
  margin-right: 3px;
}
.grid .col-header,
.grid .cat-header,
.grid .sub-cat-header {
  padding: 0.1em 0.2em;
  color: var(--ntss-header-color);
  background-color: var(--ntss-header-background-color);
  word-break: break-all;
  border-left: 1px solid var(--ntss-border-color);
  border-bottom: 1px solid var(--ntss-border-color);
}
.grid .th-sticky {
  /*#10407:変更なしでも画面を表示させる Start*/
  top: -1.0px;
  /*#10407:変更なしでも画面を表示させる End*/
  position: -webkit-sticky;
  position: sticky;
}
.grid .cat-header {
  min-width: 1.5em;
  width: 1.5em;
  padding-top: 0.3em;
  padding-bottom: 0.3em;
}
.grid .cat-header span {
  writing-mode: vertical-rl;
  align-items: center;
  word-break: keep-all;
}
.grid .sub-cat-header {
  min-width: 8.5em;
  width: 8.5em;
  padding-top: 0.3em;
  padding-bottom: 0.3em;
}
/*#10407:変更なしでも画面を表示させる Start*/
.grid .sub-category-item {
  border-bottom: 1px solid var(--ntss-border-color);
  border-left: 1px solid var(--ntss-border-color);
  padding: 5px;
}
.grid .darkThemeBackground {
  background-color: rgb(30, 30, 31);
  color: #fafafa;
}
.grid .whiteThemeBackground {
  background-color: #fafafa;
  color: #050505;
}
/*#10407:変更なしでも画面を表示させる End*/
.grid .item-value {
  min-width: 12em;
}
.grid .instructor {
  min-width: 8em;
}
.grid .updater {
  border-right: 1px solid var(--ntss-border-color);
  min-width: 8em;
}
.grid .content-change > .sub-category-item {
  background-color: orange;
}
.right {
  text-align: right;
}
.icon {
  display: flex;
  align-items: center;
  height: calc(1.5em + 10px);
  padding: 5px;
  background-color: #0076ff;
  border-radius: 4px;
  line-height: 20px;
}
.icon :deep(img) {
  width: 1.5em;
}
.is-disabled {
  background-color: #aaaaaa !important;
}
.hide-text {
  color: #aaaaaa !important;
}
@media print {
  /** モーダル高さ確保 */
  .modal-mask :deep(div){
    height: auto !important;
  }
  /** レイアウト崩れ防止 */
  div :deep(.modal-wrapper){
    display: inline-block !important;
    width: 100%;
  }
  .status-map-pat-ind-modal-list {
    position: static;
  }
}
</style>
