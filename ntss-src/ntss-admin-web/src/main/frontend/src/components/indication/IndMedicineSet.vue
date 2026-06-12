/** * 投与薬剤セット */

<template>
  <div>
    <v-ons-row class="container-row-style">
      <v-ons-col width="10em"> 薬剤セット </v-ons-col>
      <v-ons-col>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="popoverButtonMedicineSet" -->
        <!--   class="common-style-select-button" -->
        <!--   @click="createPopoverDataMedicineSet()" -->
        <!-- > -->
        <common-master-selector
          :masterType="MasterType.MEDICINE_SET_INDICATION_RECORD"
          :initItem="{ value: null }"
          :editItem="{ value: null }"
          :extraParams="{ treatDate: getIndStartDate }"
          :patientId="selectedPatId"
          :facilityCd="facilityCd"
          :dialysisState="0"
          :hasChangedOption="false"
          :changeOptionMode="'nameOnly'"
          :hasUnregisteredOption="false"
          :btnName="'追加'"
          :isVisible="false"
          :btnClass="'common-style-select-button'"
          :btnDisabled="!getItemAuthorized('Indication', 'default_authority')"
          @popover-return="updateInputMedicineSet($event)"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="container-row-style">
      <v-ons-col width="10em"> 薬剤 </v-ons-col>
      <v-ons-col>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="popoverButtonMedicine" -->
        <!--   class="common-style-select-button" -->
        <!--   @click="createPopoverDataMedicine()" -->
        <!-- > -->
        <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
       <!-- <v-ons-button
          ref="popoverButtonMedicine"
          class="common-style-select-button"
          @click="createPopoverDataMedicine()"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        >-->
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
           <!--追加
        </v-ons-button>-->
        <common-master-selector
          :masterType="MasterType.MEDICATION_TREATMENT_RECORD"
          :extraParams="{treatDate: treatDate,rstInfo:{ rstName:'', rstUnit: ''}}"
          :patientId="selectedPatId"
          :facilityCd="facilityCd"
          :dialysisState="Number(rstDialysisState || 0)"
          :btnName="'追加'"
          :isVisible="false"
          :hasUnregisteredOption="false"
          :hasChangedOption="true"
          :selectedItemClass="'com-basic-sub-input'"
          :backgroundColor="'#f7f7f7'"
          :btnClass="'com-basic-sub-btn'"
          :btnDisabled="!getItemAuthorized('Indication', 'default_authority')"
          @popover-return="masterUpdateInput($event);"
        />
      </v-ons-col>
      <!--<pop-over
        v-bind="popoverDataMedicine"
        :target-position-element="$refs.popoverButtonMedicine"
        @popover-close="closePopoverMedicine"
        @popover-return="updateInputMedicine"
      />-->
      <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
    </v-ons-row>
    <v-ons-row class="container-row-style">
      <div class="content-div-style">
        <div v-show="isLoading" class="content-loading-style">
          <v-ons-icon icon="fa-spinner" size="20px" spin="true" />
        </div>
        <div v-show="!isLoading" class="medicine-set-style">
          <div v-show="listData.length === 0">薬剤を追加してください</div>
          <v-ons-row
            v-for="(data, index) in listData"
            :key="data.id"
            class="medicine-set-row-style"
          >
            <v-ons-col>
              <ind-medicine-edit :ref="data.id" :fields-data="data" />
            </v-ons-col>
            <v-ons-col class="medicine-set-delete-container-style">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-button -->
              <!--   class="medicine-set-delete-button-style" -->
              <!--   @click="deleteRow(index)" -->
              <!-- > -->
              <button
                class="ntss-btn-outset button-delete"
                @click="deleteRow(index)"
                :disabled="!getItemAuthorized('Indication', 'default_authority')"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <v-ons-icon icon="fa-trash"/>
              </button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
    </v-ons-row>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { medicine, medicineClass, medicineMix, medicineMixTabooAllergy, medicineTabooAllergy } from "@/functions/mst/MstGetters.js";
import _ from "@/compat/collections/lodash";
import IndMedicineEdit from "@/components/indication/IndMedicineEdit";
import { dateFormat, fitTermCheck, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/27 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/27 メッセージボックス全調整 林峻峰 end
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

import { nextId } from "@/functions/common/id";
import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
export default {
  mixins: [IndicationOwnerMixin],
  components: {
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    "common-master-selector": commonMasterSelector,
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    "ind-medicine-edit": IndMedicineEdit
  },

  data() {
    return {
      isMasterSelecting: false,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      treatDate:'',
      MasterType,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      popoverDataMedicine: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },
      listData: [],
      isLoading: false,
      medicineData: [],
      medicineMixData: []
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    rstDialysisState() {
      const om = this.settingIndData && this.settingIndData.orderMainData;
      return om && om.rstDialysisState != null ? om.rstDialysisState : 0;
    },
  },

  watch: {
    getIndStartDate: {
      handler(val) {
        this.treatDate = this.normalizeTreatDate(val);
      },
      immediate: true
    },
  },

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    ...mapActions("treatment-record/mediInfo", {
      sendRequestChangeIndMediInfoRst: "sendRequestChangeIndMediIn",
    }),
    ...mapActions("treatment-record/common", ["getMstMachineByOrdNoRst", "sendGetNoticeMedi"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    normalizeTreatDate(val) {
      if (val == null) return "";
      return String(val).replaceAll("-", "");
    },
    masterUpdateInput(val) {
      if (this.isMasterSelecting) {
        return;
      }
      this.isMasterSelecting = true
      let item = {
        isDisp: val.isDisp,
        text: val.text,
        value: val.value,
        type: val.key_type ?? val.kbnValue ?? val.type
      }
      this.updateInputMedicine(item)
      setTimeout(() => {
        this.isMasterSelecting = false;
      }, 500);
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    async createPopoverDataMedicine() {
      // del FNSI-改修内容6512修正 xuty start
      // this.$parent.$parent.editAddFlg = true;
      // del FNSI-改修内容6512修正 xuty end
      let filterArr = [];
      let contentArr = [];
      const [medicineData, medicineMixData, classData] = await Promise.all([
        medicineTabooAllergy(this.selectedPatId),
        medicineMixTabooAllergy(this.selectedPatId),
        medicineClass(this.facilityCd)
      ]).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndMedicineSet.vue', 'createPopoverDataMedicine', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      // 予定範囲と薬剤の使用期限を見て表示内容を補正する
      const filteredMedicineData = medicineData.filter(medi => {
        return fitTermCheck(medi.useStartDate, medi.useEndDate, this.getIndStartDate);
      });
      this.medicineDataset = filteredMedicineData;
      const filteredMedicineMixData = medicineMixData.filter(medi => {
        return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, this.getIndStartDate);
      });
      this.medicineMixDataset = filteredMedicineMixData;

      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };
      filterArr = classData.map(filterMapping);
      filterArr.unshift({ text: "すべて", value: 0 });
      // mod #8202 2022/12/22 投与薬剤編集モーダルにて薬剤分類「未分類」を選択して抽出すると、薬剤が何も表示されない dou start
      // filterArr.push({ text: "未分類", value: null });
      filterArr.push({ text: "未分類", value: -1 });
      // mod #8202 2022/12/22 投与薬剤編集モーダルにて薬剤分類「未分類」を選択して抽出すると、薬剤が何も表示されない dou end

      // ポップオーバのコンテンツデータ(フィルターしたデータ)を取りまとめる
      const contentParamIsDisp = item => {
        return item.isDisp === "1";
      };
      const contentMapping = (item, cdKey, nameKey, category) => {
        return {
          value: category === "1" ? item[cdKey] : `${item[cdKey]}$`,
          fnValue: {
            薬剤区分: category,
            薬剤分類: item.classCd
          },
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item[nameKey]
          text: getPrefix(item) + item[nameKey]
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        };
      };

      contentArr = filteredMedicineData
        .filter(contentParamIsDisp)
        .map(item => contentMapping(item, "medicineCd", "medicineName", "1"));
      const mixArr = filteredMedicineMixData
        .filter(contentParamIsDisp)
        .map(item =>
          contentMapping(item, "medicineMixCd", "medicineMixName", "2")
        );
      contentArr = [...contentArr, ...mixArr];

      this.popoverDataMedicine.popoverTitleHeader = "薬剤";
      this.popoverDataMedicine.popoverFilter = [
        {
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            { text: "すべて", value: 0 },
            { text: "通常薬剤", value: "1" },
            { text: "調製薬剤", value: "2" }
          ]
        },
        {
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: filterArr
        }
      ];
      this.popoverDataMedicine.popoverContentLabel = "薬剤名";
      this.popoverDataMedicine.popoverContentDataset = contentArr;
      // add #9848+9849 薬剤選択IF，空選択肢なし linjunfeng start
      this.popoverDataMedicine.hasUnregisteredOption = false;
      // add #9848+9849 薬剤選択IF，空選択肢なし linjunfeng end
      this.showPopoverMedicine();
    },

    /**
     * @description 薬剤マスター選択を表示
     */
    showPopoverMedicine() {
      this.popoverDataMedicine.popoverVisible = true;
    },

    /**
     * @description 薬剤マスター選択を非表示
     */
    closePopoverMedicine() {
      this.popoverDataMedicine.popoverVisible = false;
    },

    /**
     * @description 薬剤セットマスター選択から選択後のコールバック
     */
    async updateInputMedicineSet(data) {
      this.isLoading = true;

      let listData = [
        {
          id: nextId("medicine"),
          cd: null,
          unit: null,
          amount: 0,
          procedureCd: null,
          timingCd: null,
          comment: null,
          medicineType: null
        }
      ];

      const setInfoRaw = data?.setInfo;
      if (setInfoRaw == null || setInfoRaw === "") {
        this.isLoading = false;
        return;
      }

      let medicineSetJson;
      try {
        if (typeof setInfoRaw === "string") {
          medicineSetJson = JSON.parse(setInfoRaw);
        } else if (Array.isArray(setInfoRaw)) {
          medicineSetJson = setInfoRaw;
        } else if (
          typeof setInfoRaw === "object" &&
          setInfoRaw.value != null &&
          typeof setInfoRaw.value === "string"
        ) {
          medicineSetJson = JSON.parse(setInfoRaw.value);
        } else {
          medicineSetJson = setInfoRaw;
        }
      } catch (error) {
        getErrorMessage("IndMedicineSet.vue", "updateInputMedicineSet", error);
        this.isLoading = false;
        return;
      }

      if (!Array.isArray(medicineSetJson)) {
        this.isLoading = false;
        return;
      }

      if (medicineSetJson.length) {
        // データ順番を薬剤セット画面の表示順に合わせる
        /* modify by chamaojia 2023-08-01 [9197] 薬剤セットは正常な順序で展示されており、順序を反転する必要はありません  --start */
        /* modify by chamaojia 2023-08-01 [9197] 薬剤セットは正常な順序で展示されており、順序を反転する必要はありません  --end */
        const medicineData = await medicine(this.facilityCd).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndMedicineSet.vue', 'updateInputMedicineSet', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          }
        );
        const medicineMixData = await medicineMix(this.facilityCd).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndMedicineSet.vue', 'medicineMixData', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          }
        );

        listData = medicineSetJson.map(item => {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //const medicineType = String(item.class);
          // mod #10101 条件送信後にチェックリストが0件になる dou start
          const rawType = item?.key_class;
          let medicineType = Number(rawType);
          if (!Number.isFinite(medicineType) || (medicineType !== 1 && medicineType !== 2)) {
            medicineType = 1;
          }
          // mod #10101 条件送信後にチェックリストが0件になる dou end
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          let mstMedi = medicineData;
          let mstMediCd = "medicineCd";
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (medicineType === "2") {
          if (medicineType == 2) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            // 調製薬剤なら
            mstMedi = medicineMixData;
            mstMediCd = "medicineMixCd";
          }
          const med = mstMedi.find(i => item.cd === i[mstMediCd]);
          return {
            id: nextId("medicine"),
            cd: med && med[mstMediCd],
            unit: med && med.unit,
            amount: item.amount,
            procedureCd: item.procedure_timing_cd,
            timingCd: item.medicate_timing_cd,
            comment: null,
            medicineType
          };
        });
      }

      // 削除済み非表示へ
      this.listData = this.listData.concat(listData.filter(item => item.cd));
      this.isLoading = false;
      // add FNSI-改修内容6512修正 xuty start
      this._indicationDialogOwner().editAddFlg = this.listData.length > 0;
      // add FNSI-改修内容6512修正 xuty end
    },

    /**
     * @description 薬剤マスター選択から選択後のコールバック
     */
    async updateInputMedicine(data) {
      this.isLoading = true;
      const selectedData = data;
      let mstmedi = [];
      let medicineCdKey = "medicineCd";
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      //const medicineType = String(data.value).match(/\$/) ? "2" : "1";
      const medicineType =
        selectedData.key_type ??
        selectedData.keyType ??
        selectedData.kbnValue ??
        selectedData.type ??
        null;
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤マスタ
        mstmedi = await medicineMix(this.facilityCd).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndMedicineSet.vue', 'updateInputMedicine', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
        medicineCdKey = "medicineMixCd";
        selectedData.value = Number(String(selectedData.value).split("$")[0]);
      } else {
        mstmedi = await medicine(this.facilityCd).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndMedicineSet.vue', 'updateInputMedicine', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
      }

      const medicineData = mstmedi.find(item => {
        return item[medicineCdKey] === selectedData.value;
      });

      const listData = selectedData.value
        ? {
            id: nextId("medicine"),
            cd: medicineData[medicineCdKey],
            unit: medicineData.unit,
            amount: 0,
            procedureCd: medicineData.procedureCd,
            timingCd: medicineData.medicateTimingCd,
            comment: null,
            medicineType
          }
        : {
            id: nextId("medicine"),
            cd: null,
            unit: null,
            amount: 0,
            procedureCd: null,
            timingCd: null,
            comment: null,
            medicineType: null
          };

      // 削除済み非表示へ
      this.listData = this.listData.concat(listData);
      this.isLoading = false;
      // add FNSI-改修内容6512修正 xuty start
      this._indicationDialogOwner().editAddFlg = true;
      // add FNSI-改修内容6512修正 xuty end
    },

    /**
     * @description 投薬セットから項目を削除
     */
    deleteRow(item) {
      this.listData.splice(item, 1);
      if (this.listData.length === 0) {
        this._indicationDialogOwner().editAddFlg = false;
      }
    },

    /**
     * @description APIにリクエストする
     */
    async updateIndInfo(structData, limit = null) {
      console.log("IndMedicineSet.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 必須項目の入力チェック
      let hasError = false;
      // メッセージ置換文字
      let stringParam = null;

      // サーバ処理結果格納用
      let response = {};

      const medicineSetItems = _.omit(this.$refs, "popoverButtonMedicineSet");

      // 未選択チェック
      if (await this.chkUnselected(medicineSetItems)) {
        stringParam = "薬剤";
        this._indicationDialogOwner().messageDialogInfo.messageCd = 22010001;
        this._indicationDialogOwner().messageDialogInfo.type = "1";
        this._indicationDialogOwner().messageDialogInfo.stringParams = [stringParam];
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        console.log("IndMedicineSet.vue updateIndInfo return true; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return true;
      }
      // 使用期限のチェック
      if (!await this.chkInExpiryDate(medicineSetItems, structData.indDayIntervalStartDate, structData.indEndDate)) {
        console.log("IndMedicineSet.vue updateIndInfo return true; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // キャンセルの場合処理終了
        return true;
      }

      /* del by chamaojia 2023-08-09 [9303] このパラメータや論理判断は不要  --start */
      // let countMax = 0
      let sendJsonList = [];
      // for (const key in medicineSetItems) {
      //   if (medicineSetItems[key][0]) {
      //     countMax = countMax + 1;
      //   }
      // }
      // let iCount = 0
      /* del by chamaojia 2023-08-09 [9303] このパラメータや論理判断は不要  --end */
      for (const key in medicineSetItems) {
        if (medicineSetItems[key][0]) {
          /* del by chamaojia 2023-08-09 [9303] このパラメータや論理判断は不要  --start */
          // iCount = iCount + 1;
          // if (iCount != countMax) {
          //   structData.nLstFlg = 1;
          // } else {
          //   structData.nLstFlg = null;
          // }
          /* del by chamaojia 2023-08-09 [9303] このパラメータや論理判断は不要  --end */
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---start */
          // response = await medicineSetItems[key][0].updateIndInfo(
          //   structData,
          //   limit
          // );
          let sendJson = await medicineSetItems[key][0].updateIndInfo(
            structData,
            limit
          );
          if(sendJson){
            sendJsonList.push(sendJson);
          }
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---end */
        }
      }
      /* add #IES_6790 by zhangruixue 2023-07-04 --start */
      let uniqueOrdNoList = [];
      sendJsonList.forEach(itemJson => {
        if (itemJson.ords.length > 0) {
          uniqueOrdNoList.push(...itemJson.ords);
        }
      });
      uniqueOrdNoList = [...new Set(uniqueOrdNoList)];
      /* add #IES_6790 by zhangruixue 2023-07-04 --end */
      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---start */
      // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
      if (structData.type && 'add' === structData.type) {
        response = await ApiHelper.post(
          "/patients/medications/create",
          sendJsonList
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndMedicineSet.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("IndMedicineSet.vue updateIndInfo throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
      } else {
        // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
        response = await ApiHelper.post(
          "/mainData/createOrdMainMediInfoBatch",
          sendJsonList
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndMedicineSet.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("IndMedicineSet.vue updateIndInfo throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
      }
      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---end */

      /* add #IES_6790 by zhangruixue 2023-07-04 --start */
      if (uniqueOrdNoList.length > 0) {
        uniqueOrdNoList.forEach(ordNo =>{
          this.sendGetNoticeMedi(ordNo).then(results=>{
            if (results.data == true) {
              this.getMstMachineByOrdNoRst(ordNo).then(machineRes => {
                const params = {
                  ordNo: ordNo, //オーダー番号
                  machineNo: machineRes.data[0].machineNo, //装置マスタ.装置番号
                  deviceEdgeNo: machineRes.data[0].deviceEdgeNo, //デバイスエッジ番号
                  facilityCd: this.facilityCd //施設コード
                };
                try {
                  this.sendRequestChangeIndMediInfoRst(params);
                } catch (e) {
                  getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', '装置へ送信に失敗しました。');
                  this.$ons.notification.alert({
                    modifier: "warn",
                    title: DIALOG_MESSAGES['00200033'].title,
                    message: messageFormat(DIALOG_MESSAGES['00200033'].message),
                  });
                }
              });
            }
          });
        })
      }
      /* add #IES_6790 by zhangruixue 2023-07-04 --end */

      if (200 === response.status && undefined !== response.data.msgCd) {
        this._indicationDialogOwner().messageDialogInfo.messageCd = response.data.msgCd;
        this._indicationDialogOwner().messageDialogInfo.type = "1";
        this._indicationDialogOwner().messageDialogInfo.stringParams = [""];
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        console.log("IndMedicineSet.vue updateIndInfo return true; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // 処理終了
        return true;
      }

      console.log("IndMedicineSet.vue updateIndInfo return hasError; this.finishLoadingScreen();");
      this.finishLoadingScreen();
      return hasError;
    },

    /**
     * 未選択項目チェック処理
     */
    async chkUnselected(medicineSetItems) {
      let rtn = false;
      for (const key in medicineSetItems) {
        if (medicineSetItems[key][0]) {
          if (!medicineSetItems[key][0].medicineInputValue.editValue) {
            rtn = true;
            break;
          }
        }
      }
      return rtn;
    },
    /**
     * 使用期限のチェック処理
     */
    async chkInExpiryDate(medicineSetItems, indStartDate, indEndDate) {
      let msg = "";
      for (const key in medicineSetItems) {
        if (medicineSetItems[key][0]) {
          const selectedCd = medicineSetItems[key][0].medicinePopoverData.popoverContentSelected.value;
          // 薬剤/調製薬剤項目
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (medicineSetItems[key][0].medicineType === "1") {
          if (medicineSetItems[key][0].medicineType == 1) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            // 薬剤の場合
            const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineData"].filter(medi => medi.medicineCd === selectedCd);
            if (tmpMediObj.length === 0) {
              continue;
            }
            const mediObj = tmpMediObj[0];
            if (!fitTermCheckForUpdate(mediObj.useStartDate, mediObj.useEndDate, indStartDate, indEndDate)) {
              msg += "</br>" + mediObj.medicineName + "："
                  + dateFormat.normalDateWithCheck(mediObj.useStartDate)
                  + "～" + dateFormat.normalDateWithCheck(mediObj.useEndDate);
            }
          } else {
            // 調製薬剤の場合
            const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineMixTabooAllergyData"].filter(medi => medi.medicineMixCd === selectedCd);
            if (tmpMediObj.length === 0) {
              continue;
            }
            const mediObj = tmpMediObj[0];
            if (!fitTermCheckForUpdate(mediObj.maxUseStartDate, mediObj.minUseEndDate, indStartDate, indEndDate)) {
              msg += "</br>" + mediObj.medicineMixName + "："
                  + dateFormat.normalDateWithCheck(mediObj.maxUseStartDate)
                  + "～" + dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
            }
          }
        }
      }
      if (msg) {
        let rtn = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
           title: DIALOG_MESSAGES[13000059].title,
          // message: "指示期間に使用期間外となる薬剤が含まれています。" + msg + "</br>登録してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000059].message, msg),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              rtn = true;
            } else {
              // 処理を中止するので保存ボタン無効を解除
              this._indicationDialogOwner().updateDisable = false;
            }
          }
        });
        return rtn;
      } else {
        // チェック対象項目なし / 期限切れ項目なしの場合
        return true;
      }
    },

    /**
     * チェック処理
     */
    checkEdit(num) {
      // キャンセル時チェック処理
      if (1 === num) {
        const medicineSetItems = this.$refs;
        let isCheck = false;

        Object.keys(medicineSetItems).forEach(key => {
          if (medicineSetItems[key][0]) {
            if (medicineSetItems[key][0].checkEdit()) {
              this._indicationDialogOwner().messageDialogInfo.messageCd = 20010001;
              this._indicationDialogOwner().messageDialogInfo.type = "2";
              this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
              isCheck = medicineSetItems[key][0].checkEdit();
            }
          }
        });
        return isCheck;
      }
    }
  }
};
</script>

<style scoped>
.container-row-style {
  margin-bottom: 5px;
}

.medicine-set-input-style {
  width: 70%;
  margin: 0px 5px 0px 0px;
}

.content-div-style {
  width: 100%;
  overflow: hidden auto;
  border: 1px solid rgb(154, 154, 154);
}

.content-loading-style {
  text-align: center;
}

.medicine-set-style {
  border-collapse: collapse;
}

.medicine-set-row-style {
  text-align: left;
  border-bottom: 1px solid rgb(154, 154, 154);
}

.medicine-set-delete-container-style {
  vertical-align: top;
  flex: 0;
}

.common-style-select-button {
  height: 2em;
}

.button-delete {
  height: 100%;
}
</style>
