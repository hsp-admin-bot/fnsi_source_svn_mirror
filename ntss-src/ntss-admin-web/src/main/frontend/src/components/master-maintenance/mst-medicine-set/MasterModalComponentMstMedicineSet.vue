<template>
  <div>
    <div class="medicine-set-info">
      <v-ons-row class="row-height">
        <v-ons-col class="item-title">薬剤セット名</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            class="set-name-input"
            :value="medicineSetInfo.medicineSetName"
            @blur="onNameChange()"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">省略薬剤セット名</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            class="set-name-input"
            :value="medicineSetInfo.medicineSetShortName"
            @blur="onShortNameChange()"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">連携コード1</v-ons-col>
        <v-ons-col class="item-data">
          <custom-input
            :value="medicineSetInfo.inHospitalCd1"
            @blur="onInHospitalCd1Change()"
          />
        </v-ons-col>
        <v-ons-col class="item-title">連携コード2</v-ons-col>
        <v-ons-col class="item-data">
          <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start-->
          <!-- <custom-input
            :value="medicineSetInfo.inHospitalCd2"
            @change="changeButton"
            @blur="onInHospitalCd2Change()"
          /> -->
          <custom-input
            :value="medicineSetInfo.inHospitalCd2"
            @blur="onInHospitalCd2Change()"
          />
          <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end-->
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-row class="frame">
      <v-ons-col class="item-title">
        <v-ons-col>セット情報</v-ons-col>
        <v-ons-col>
          <v-ons-button class="item-button btn3-normal" style="margin-top: 5px;" @click="addMedicineSet()">
            追加
          </v-ons-button>
        </v-ons-col>
      </v-ons-col>
      <v-ons-col class="item-data data-table print-height-auto">
        <div class="detail-list">
          <table class="ntss-list sticky_table" style="position: relative;table-layout: fixed;">
            <thead display="block">
            <tr>
              <th class="ntss-list-header-th-sticky list-class color-header">分類</th>
              <th class="ntss-list-header-th-sticky list-name color-header">薬剤名</th>
              <th class="ntss-list-header-th-sticky list-num color-header">数量</th>
              <th class="ntss-list-header-th-sticky list-unit color-header">指示単位</th>
              <th class="ntss-list-header-th-sticky list-code color-header">手技</th>
              <th class="ntss-list-header-th-sticky list-timing-code color-header">投与タイミング</th>
              <th class="ntss-list-header-th-sticky list-delete color-header"/>
            </tr>
            </thead>
            <tr v-for="(column, index) in dispArr" :key="column.id">
              <!-- 薬剤分類 -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                {{
                  getMedicineClass(
                    dispArr[index].cd.editValue,
                    dispArr[index].class.editValue
                  )
                }}
              </td>
              <!-- 薬剤名 -->
              <td class="ntss-list-body-td ntss-list-body-td-background medi-name-wrapper">
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start-->
                <!-- <custom-input
                  style="margin-top: 4px;"
                  class="choice-input mediName-width"
                  :value="dispArr[index].cd"
                  :display-string="
                  getMediName(
                    dispArr[index].cd.editValue,
                    dispArr[index].class.editValue
                  )
                "
                  disabled
                  @change="changeButton"
                /> -->
                <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
                <!--<custom-input
                  class="medi-name"
                  :value="dispArr[index].cd"
                  :display-string="
                  getMediName(
                    dispArr[index].cd.editValue,
                    dispArr[index].class.editValue
                  )
                "
                  disabled
                />-->
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end-->
                <!--<v-ons-button
                  style="margin-bottom: 5px;"
                  :ref="index"
                  class="select-button btn3-normal"
                  @click="
                  selectMedicine(
                    index,
                    dispArr[index].cd.editValue,
                    dispArr[index].class.editValue
                  )
                "
                >
                  選択
                </v-ons-button>-->
                <common-master-selector
                  :masterType="MasterType.ANTICOAGULANT_INDICATION"
                  :initItem="{text: dispArr[index].text, value: dispArr[index].value}"
                  :editItem="{text: getMediName(dispArr[index].cd.editValue, dispArr[index].class.editValue), value: dispArr[index].cd.editValue}"
                  :extraParams="{treatDate: treatDate,rstInfo:{ rstName:getMediName(dispArr[index].cd.editValue, dispArr[index].class.editValue), 
                    rstUnit:getMediUnit(dispArr[index].cd.editValue, dispArr[index].class.editValue)}}"
                  :patientId="selectedPatId"
                  :facilityCd="getFacilityCd"
                  :hasChangedOption="true"
                  :selectedItemClass="'com-basic-sub-input'"
                  :backgroundColor="'#f7f7f7'"
                  :btnClass="'com-basic-sub-btn'"
                  :btnDisabled="false"
                  :isSelectionRequired="true"
                  :hasUnregisteredOption="false"
                  @popover-return="masterUpdateInput($event,index);"
                />
                
                <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
              </td>
              <!-- 数量 -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
                <!-- <custom-input-number
                  :value="dispArr[index].amount"
                  style="width:100%; min-width: 100px;"
                  :digits="8"
                  :decimal-digits="getMediUnitStep(dispArr[index])"
                  :min-value="0"
                  :max-value="99999999.999999999"
                  :initial-value-lock="true"
                  @change="changeButton"
                /> -->
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start-->
                <!-- <custom-input-number
                  :value="dispArr[index].amount"
                  style="width:100%; min-width: 100px;"
                  :digits="8"
                  :decimal-digits="getMediUnitStep(dispArr[index])"
                  :min-value="0"
                  :max-value="99999999.999999999"
                  :initial-value-lock="true"
                  @change="changeDown(index)"
                  @wheel="changeDown(index)"
                /> -->
                <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start -->
                <!-- <custom-input-number
                  :value="dispArr[index].amount"
                  style="width:100%; min-width: 100px;"
                  :digits="8"
                  :decimal-digits="getMediUnitStep(dispArr[index])"
                  :min-value="0"
                  :max-value="99999999.999999999"
                  :initial-value-lock="true"
                /> -->
                <custom-input-number-pro
                  :value="dispArr[index].amount.editValue"
                  :step="getMediUnitNewStep(dispArr[index])"
                  :invalidArray="getInvalidArray(dispArr[index])"
                  :required="true"
                  :min="0"
                  :max="maxPrecision(dispArr[index], 99999999)"
                  @handlerInput="(val) =>{ dispArr[index].amount.editValue = val }"
                />
                <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end -->
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end-->
                <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
              </td>
              <!-- 指示単位 -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                {{
                  getMediUnit(
                    dispArr[index].cd.editValue,
                    dispArr[index].class.editValue
                  )
                }}
              </td>
              <!-- 手技 -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start-->
                <!-- <custom-select
                  class="item-select"
                  :value="dispArr[index].procedure_timing_cd"
                  style="width:100%"
                  :options="mstProcedureList"
                  @change="updateHanle(index,$event)"
                /> -->
                <custom-select
                  class="item-select"
                  :value="dispArr[index].procedure_timing_cd"
                  style="width:100%"
                  :options="mstProcedureList"
                />
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end-->
              </td>
              <!-- 投与タイミング -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start-->
                <!-- <custom-select
                  class="item-select"
                  :value="dispArr[index].medicate_timing_cd"
                  style="width:100%"
                  :options="mstMedicateTimingList"
                  @change="updateSelect(index,$event)"
                /> -->
                <custom-select
                  class="item-select"
                  :value="dispArr[index].medicate_timing_cd"
                  style="width:100%"
                  :options="mstMedicateTimingList"
                />
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end-->
              </td>
              <!-- 削除 -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                <button class="ntss-btn-outset button-delete" @click="delMedicineSet(index)">
                  <v-ons-icon icon="fa-trash"/>
                </button>
              </td>
            </tr>
          </table>
        </div>
      </v-ons-col>
    </v-ons-row>
    <!-- 薬剤選択ボタンポップオーバー -->
    <pop-over
      v-bind="popParam"
      :target-position-element="popoverTargetElement(selectedIndex)"
      @popover-return="selectedMedi($event, selectedIndex)"
      @popover-close="closePopover(popParam)"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customSelect from "@/components/common/custom-form-tags/CustomSelect";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox";
import { showPopover, closePopover } from "@/functions/PopoverFunctions";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// FNSI-修正 マスタ削除の対応 楊 add start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
// FNSI-修正 マスタ削除の対応 楊 add end
import {EventBus} from "@/eventBus";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import cloneDeep from "lodash/cloneDeep";
import isEqualWith from "lodash/isEqualWith";
import { customComparator } from "@/utils/util.js";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
// add #9848+9849 数値IFのスタイル全不正 linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
import BigNumber from "bignumber.js";
// add #9848+9849 数値IFのスタイル全不正 linjunfeng end
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { Master } from "@/models/common/master-selector-condition/Master";
import { getMstListCompose } from "@/apis/pat-prescription"
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

export default {
  name: "MstMedicineSet",
  components: {
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    "common-master-selector": commonMasterSelector,
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-select": customSelect,
    "custom-checkbox": customCheckbox,
    "pop-over": MasterSelector,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro":CustomInputNumberPro,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
  },

  data() {
    return {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      MasterType,
      treatDate: "",
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      medicineSetInfo: {
        medicineSetName: { initValue: "", editValue: "" },
        medicineSetShortName: { initValue: "", editValue: "" },
        inHospitalCd1: { initValue: "", editValue: "" },
        inHospitalCd2: { initValue: "", editValue: "" },
        setInfoJsonStr: "",
        setInfoJsonArr: [], // 内部処理用
        setInfoJsonArrCustom: [] // 画面表示用
      },
      //薬剤マスタ
      mstMedicine: [],
      mstMedicineMix: [],
      //薬剤分類マスタ
      mstMediClass: [],
      mstProcedureList: [],
      mstMedicateTimingList: [],
      //薬剤選択ポップオーバーのパラメータ
      popParam: {
        popoverVisible: false, //表示非表示
        popoverDisplayDirection: "down", //出現位置
        popoverTitleHeader: "薬剤", //タイトル
        popoverFilter: [], //抽出条件
        popoverContentLabel: "薬剤名", //選択する項目一覧のタイトル
        popoverContentDataset: [], //選択する項目一覧
        popoverContentSelected: {}, //選択した項目
        hasUnregisteredOption: false //「未登録」選択の有無
      },
      // 選択されたボタン位置
      selectedIndex: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
      dispArrDefault:null,
      editRecordDefault:null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    };
  },

  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", ["getFontSize"]),
    //表示用パラメータの変数名を短く変換
    dispArr() {
      return this.medicineSetInfo.setInfoJsonArrCustom;
    },
  },

  watch: {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
    "editRecord.name":{
      handler(val) {
        EventBus.$emit("mstHolidayRegistered",isEqualWith(val,this.editRecordDefault.name,customComparator) 
           && isEqualWith(this.editRecord.medicineSetShortName,this.editRecordDefault.medicineSetShortName,customComparator)
           && isEqualWith(this.editRecord.inHospitalCd1,this.editRecordDefault.inHospitalCd1,customComparator)
           && isEqualWith(this.editRecord.inHospitalCd2,this.editRecordDefault.inHospitalCd2,customComparator)
           )
      },
      deep:true
    },
    "editRecord.medicineSetShortName":{
      handler(val) {
        EventBus.$emit("mstHolidayRegistered",isEqualWith(val,this.editRecordDefault.medicineSetShortName,customComparator)
            && isEqualWith(this.editRecord.name,this.editRecordDefault.name,customComparator)
            && isEqualWith(this.editRecord.inHospitalCd1,this.editRecordDefault.inHospitalCd1,customComparator)
            && isEqualWith(this.editRecord.inHospitalCd2,this.editRecordDefault.inHospitalCd2,customComparator)
        )
      },
      deep:true
    },
    "editRecord.inHospitalCd1":{
      handler(val) {
        EventBus.$emit("mstHolidayRegistered",isEqualWith(val,this.editRecordDefault.inHospitalCd1,customComparator)
            && isEqualWith(this.editRecord.name,this.editRecordDefault.name,customComparator)
            && isEqualWith(this.editRecord.medicineSetShortName,this.editRecordDefault.medicineSetShortName,customComparator)
            && isEqualWith(this.editRecord.inHospitalCd2,this.editRecordDefault.inHospitalCd2,customComparator)
            )
      },
      deep:true
    },
    "editRecord.inHospitalCd2":{
      handler(val) {
        EventBus.$emit("mstHolidayRegistered",isEqualWith(val,this.editRecordDefault.inHospitalCd2,customComparator)
            && isEqualWith(this.editRecord.name,this.editRecordDefault.name,customComparator)
            && isEqualWith(this.editRecord.medicineSetShortName,this.editRecordDefault.medicineSetShortName,customComparator)
            && isEqualWith(this.editRecord.inHospitalCd1,this.editRecordDefault.inHospitalCd1,customComparator)
           )
      },
      deep:true
    },
    
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/16 start
    dispArr: {
      handler(val) {
        EventBus.$emit("mstHolidayRegistered",isEqualWith(JSON.stringify(val),JSON.stringify(this.dispArrDefault))
          && isEqualWith(this.editRecord.name,this.editRecordDefault.name,customComparator)
          && isEqualWith(this.editRecord.medicineSetShortName,this.editRecordDefault.medicineSetShortName,customComparator)
          && isEqualWith(this.editRecord.inHospitalCd1,this.editRecordDefault.inHospitalCd1,customComparator)
          && isEqualWith(this.editRecord.inHospitalCd2,this.editRecordDefault.inHospitalCd1,customComparator)
          )
        //セット情報を変更した際、ストアに書き込みを行う
        this.onSetInfoChange();
      },
      deep: true
    },
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/16 end

    windowHeight: {
      handler() {
        this.calculateDataListHeight();
      }
    },
    windowWidth: {
      handler() {
        this.calculateDataListHeight();
      }
    },
    getFontSize: {
      handler() {
        this.calculateDataListHeight();
      }
    },
  },

  async created() {
    this.setLoadingScreenVisible(true);
    let mstProcedure = null;
    let mstMedicateTiming = null;

    //施設コードを抽出条件に追加
    // add マスタ一覧 施設切替を可能とする 王 start
    const requestParam = {
      // facilityCd: this.getFacilityCd
      facilityCd: this.getFacilitySwitch
    };
    // add マスタ一覧 施設切替を可能とする 王 end

    // add 削除されたデータの処理  王 start
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    const item = {
      lists: [
        {
          id: "list1",
          name: "固定分类",
          sourceType: "FIXED",
          fixedItems: [
            { value: "0", text: "すべて" },
            { value: "1", text: "通常薬剤" },
            { value: "2", text: "調製薬剤" }
          ],
          keyMapping: [
            { keyName: "key_type", valueFrom: "value" }
          ]
        },
        {
          id: "list2",
          name: "药剂分类MST",
          sourceType: "MST",
          mstSource: {
            mstCode: "mstMedicineClassDaoImpl",
            sqlParams: { facilityCd: this.getFacilityCd }
          },
          keyMapping: [
            { keyName: "key_class", valueFrom: "classCd" }
          ]
        },
        {
          id: "list3",
          name: "通常药剂 + 调制药剂 合并",
          sourceType: "MST_COMBINED",
          mstSourceList: [
            {
              mstCode: "mstMedicineDaoImpl",
              sourceTag: "1",
              sqlParams: { facilityCd: this.getFacilityCd,patId: null },
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineCd" }
              ]
            },
            {
              mstCode: "mstMedicineMixDaoImpl",
              sourceTag: "2",
              sqlParams: { facilityCd: this.getFacilityCd,patId: null },
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineMixCd" }
              ]
            }
          ]
        }
      ]
    }
    const res = await getMstListCompose(item);
    const [
      // 薬剤マスタ
      // responseMstMedicine,
      // 薬剤分類マスタ
      //responseMstMediClass,
      // 手技マスタ
      responseMstProcedure,
      // 投与タイミング
      responseMstMedicateTiming,
      // 調製薬剤
      // responseMstMedicineMix,
      // 薬剤マスタ（削除済のデータも含む）
      //responseMstMedicineData,
      // 調製薬剤（削除済のデータも含む）
      //responseMstMedicineMixData,
      resMstListCompose,
    ] = await Promise.all([
      // ApiHelper.get("/mstInfo/mstMedicine", requestParam),
      //ApiHelper.get("/mstInfo/mstMedicineClass", requestParam),
      ApiHelper.get("/mstInfo/mstProcedure", requestParam),
      ApiHelper.get("/mstInfo/mstMedicateTiming", requestParam),
      // ApiHelper.get("/mstInfo/mstMedicineMix", requestParam),
      //ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam),
      //ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", requestParam),
      getMstListCompose(item),
    ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MasterModalComponentMstMedicineSet.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw error;
    });
    // this.mstMedicine = responseMstMedicine.data;
    //this.mstMedicine = responseMstMedicineData.data;
    const responseMstMedicineData = resMstListCompose.data.lists.list3.items.filter(item => item.key_type == 1)
    const responseMstMedicineMixData = resMstListCompose.data.lists.list3.items.filter(item => item.key_type == 2)

    this.mstMedicine = responseMstMedicineData;
    this.mstMedicine = this.mstMedicine.map((item) =>{
        if (item.isDisp === "0") {
          item.medicineName = MASTER_DELETE_DISPLAY.DELETED + item.medicineName;
        }
        return item;
      }
    )
    //this.mstMediClass = responseMstMediClass.data;
    this.mstMediClass = resMstListCompose.data.lists.list2.items;
    mstProcedure = responseMstProcedure.data;
    mstMedicateTiming = responseMstMedicateTiming.data;

    // this.mstMedicineMix = responseMstMedicineMix.data;
    //this.mstMedicineMix = responseMstMedicineMixData.data;
    this.mstMedicineMix = responseMstMedicineMixData;
    /*this.mstMedicineMix = this.mstMedicineMix.map((item) =>{
        if (item.isDisp === "0") {
          item.medicineMixName = MASTER_DELETE_DISPLAY.DELETED + item.medicineMixName;
        }
        return item;
      }
    )*/
    // add 削除されたデータの処理  王 end
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    for (const num in mstProcedure) {
      this.mstProcedureList.splice(num, 0, {
        value: mstProcedure[num].procedureCd,
        displayValue: mstProcedure[num].pricedureName
      });
    }

    for (const num in mstMedicateTiming) {
      this.mstMedicateTimingList.splice(num, 0, {
        value: mstMedicateTiming[num].medicateTimingCd,
        displayValue: mstMedicateTiming[num].medicateTimingName
      });
    }
    // #9848+9849 手技、投与タイミング 空選択肢あり linjunfeng start
    this.mstProcedureList.unshift({
      value: null,
      displayValue: null,
    })
    this.mstMedicateTimingList.unshift({
      value: null,
      displayValue: null,
    })
    // #9848+9849 手技、投与タイミング 空選択肢あり linjunfeng end
    this.calculateDataListHeight();
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    // 表示用ローカル配列に、入力項目をコピー
    for (const i in this.medicineSetInfo.setInfoJsonArr) {
      this.dispArr.splice(i, 1, {
        id: _.uniqueId("medicine"),
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        text: this.getMediName(this.medicineSetInfo.setInfoJsonArr[i].cd,this.medicineSetInfo.setInfoJsonArr[i].class),
        value: this.medicineSetInfo.setInfoJsonArr[i].cd,
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        cd: {
          initValue: this.medicineSetInfo.setInfoJsonArr[i].cd,
          editValue: this.medicineSetInfo.setInfoJsonArr[i].cd
        },
        class: {
          initValue: this.medicineSetInfo.setInfoJsonArr[i].class,
          editValue: this.medicineSetInfo.setInfoJsonArr[i].class
        },
        amount: {
          initValue: this.medicineSetInfo.setInfoJsonArr[i].amount > 0 && this.medicineSetInfo.setInfoJsonArr[i].amount < 99999999.999999999 ? this.medicineSetInfo.setInfoJsonArr[i].amount : 0,
          editValue: this.medicineSetInfo.setInfoJsonArr[i].amount > 0 && this.medicineSetInfo.setInfoJsonArr[i].amount < 99999999.999999999 ? this.medicineSetInfo.setInfoJsonArr[i].amount : 0,
        },
        procedure_timing_cd: {
          initValue: this.medicineSetInfo.setInfoJsonArr[i].procedure_timing_cd,
          editValue: this.medicineSetInfo.setInfoJsonArr[i].procedure_timing_cd
        },
        medicate_timing_cd: {
          initValue: this.medicineSetInfo.setInfoJsonArr[i].medicate_timing_cd,
          editValue: this.medicineSetInfo.setInfoJsonArr[i].medicate_timing_cd
        },
        del_check: {
          initValue: "0",
          editValue: "0"
        }
      });
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
    this.editRecordDefault = cloneDeep(this.editRecord)
    this.dispArrDefault = cloneDeep(this.dispArr)
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
  },

  mounted() {
    // 内部処理用ローカル配列に、入力項目をコピー
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "name") {
        this.medicineSetInfo.medicineSetName.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.medicineSetInfo.medicineSetName.editValue = this.medicineSetInfo.medicineSetName.initValue;
      } else if (this.columnDefinition[num].field === "medicineSetShortName") {
        this.medicineSetInfo.medicineSetShortName.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.medicineSetInfo.medicineSetShortName.editValue = this.medicineSetInfo.medicineSetShortName.initValue;
      } else if (this.columnDefinition[num].field === "inHospitalCd1") {
        this.medicineSetInfo.inHospitalCd1.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.medicineSetInfo.inHospitalCd1.editValue = this.medicineSetInfo.inHospitalCd1.initValue;
      } else if (this.columnDefinition[num].field === "inHospitalCd2") {
        this.medicineSetInfo.inHospitalCd2.initValue = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.medicineSetInfo.inHospitalCd2.editValue = this.medicineSetInfo.inHospitalCd2.initValue;
      }else if (this.columnDefinition[num].field === "setInfo") {
        this.medicineSetInfo.setInfoJsonStr = this.getValueByField(
          this.columnDefinition[num].field
        );
        if (this.medicineSetInfo.setInfoJsonStr && this.medicineSetInfo.setInfoJsonStr !== null) {
          if (this.medicineSetInfo.setInfoJsonStr.length !== 0) {
            // セット情報はJSONなので、配列に置換
            this.medicineSetInfo.setInfoJsonArr = JSON.parse(
              this.medicineSetInfo.setInfoJsonStr
            );
          }
        }
      }
    }
    // del #9848+9849 数値IFのスタイル全不正 linjunfeng start
    // 表示用ローカル配列に、入力項目をコピー
    // for (const i in this.medicineSetInfo.setInfoJsonArr) {
    //   this.dispArr.splice(i, 1, {
    //     cd: {
    //       initValue: this.medicineSetInfo.setInfoJsonArr[i].cd,
    //       editValue: this.medicineSetInfo.setInfoJsonArr[i].cd
    //     },
    //     class: {
    //       initValue: this.medicineSetInfo.setInfoJsonArr[i].class,
    //       editValue: this.medicineSetInfo.setInfoJsonArr[i].class
    //     },
    //     amount: {
    //       initValue: this.medicineSetInfo.setInfoJsonArr[i].amount > 0 && this.medicineSetInfo.setInfoJsonArr[i].amount < 99999999.999999999 ? this.medicineSetInfo.setInfoJsonArr[i].amount : 0,
    //       editValue: this.medicineSetInfo.setInfoJsonArr[i].amount > 0 && this.medicineSetInfo.setInfoJsonArr[i].amount < 99999999.999999999 ? this.medicineSetInfo.setInfoJsonArr[i].amount : 0,
    //     },
    //     procedure_timing_cd: {
    //       initValue: this.medicineSetInfo.setInfoJsonArr[i].procedure_timing_cd,
    //       editValue: this.medicineSetInfo.setInfoJsonArr[i].procedure_timing_cd
    //     },
    //     medicate_timing_cd: {
    //       initValue: this.medicineSetInfo.setInfoJsonArr[i].medicate_timing_cd,
    //       editValue: this.medicineSetInfo.setInfoJsonArr[i].medicate_timing_cd
    //     },
    //     del_check: {
    //       initValue: "0",
    //       editValue: "0"
    //     }
    //   });
    // }
    // del #9848+9849 数値IFのスタイル全不正 linjunfeng end
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
    // del #9848+9849 数値IFのスタイル全不正 linjunfeng start
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
    // this.editRecordDefault = cloneDeep(this.editRecord)
    // this.dispArrDefault = cloneDeep(this.dispArr)
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    // del #9848+9849 数値IFのスタイル全不正 linjunfeng end
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    masterUpdateInput(val,index){
      this.selectedMedi(val,index)
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    maxPrecision(data, value) {
      const decPoint = this.getMediUnitStep(data)
      let num = parseInt(decPoint);
      if(isNaN(num)){
        return value;
      }
      const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
      return Number(decimalNumber.toFixed(num));
    },
    getMediUnitNewStep(data) {
      const decPoint = this.getMediUnitStep(data)
      let num = parseInt(decPoint);
      let step = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());      
      return step;
    },
    getInvalidArray(obj) {
      let arr = [];
      const decPoint = this.getMediUnitStep(obj)
      let num = parseInt(decPoint);
      let zero = 0;
      let data = isNaN(num) ? "0" : zero.toFixed(num);
      arr.push(data)
      return arr;
    },
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end

    getValueByField(field) {
      return this.editRecord[field];
    },
   //[確認]ボタンの状態の変更をトリガーします
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
    // updateSelect(index,e){
    //  if (Number(e.target.value)!==this.dispArr[index].medicate_timing_cd.initValue) {
    //   this.changeButton();
    //  }else{
    //   EventBus.$emit("mstHolidayRegistered", true);
    //  }
    // },

    // updateHanle(index,e){
    //  if (Number(e.target.value)!==this.dispArr[index].procedure_timing_cd.initValue) {
    //   this.changeButton();
    //  }else{
    //   EventBus.$emit("mstHolidayRegistered", true);
    //  }
    // },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },

    /**
     * @description 薬剤用ポップオーバーを表示
     */
    selectMedicine(index, mediCd, mediClass) {
      //選択したボタンの位置を格納
      this.selectedIndex = index;

      //絞り込み条件を作成(薬剤分類)
      //薬剤分類マスタから分類名称と分類コード一覧を保持したリストを作成
      const mediClassList = this.mstMediClass.map(item => {
        return {
          text: item.className, //分類名称
          value: item.classCd //分類コード
        };
      });
      //リストに全選択の項目を追加
      mediClassList.unshift({ text: "すべて", value: 0 });

      //絞り込み条件(薬剤区分・薬剤分類)をパラメータに設定
      this.popParam.popoverFilter = [
        {
          //薬剤区分の絞り込み条件を追加
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            { text: "すべて", value: 0 },
            { text: "通常薬剤", value: "1" },
            { text: "調製薬剤", value: "2" }
          ]
        },
        {
          //薬剤分類の絞り込み条件を追加
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: mediClassList
        }
      ];

      // add 削除されたデータの処理  王 start
      //薬剤名一覧を作成
      //薬剤マスタの薬剤名称と薬剤コードに薬剤区分と薬剤分類を追加したリストを作成(
      const mediList = this.mstMedicine.map(item => {
        return {
          value: item.medicineCd, //薬剤コード
          fnValue: {
            薬剤区分: "1",
            薬剤分類: item.classCd
          },
          text: item.medicineName, //薬剤名称
          isDisp: item.isDisp
        };
      });

      const mediMixList = this.mstMedicineMix.map(item => {
        return {
          // 薬剤マスタcdと区別するため、文字列へ変換
          value: `${item.medicineMixCd}$`,
          fnValue: {
            薬剤区分: "2",
            薬剤分類: item.classCd
          },
          text: item.medicineMixName,
          isDisp: item.isDisp
        };
      });

      //リストをパラメータに格納
      this.popParam.popoverContentDataset = [...mediList, ...mediMixList];
      this.popParam.popoverContentDataset = this.popParam.popoverContentDataset.filter(item => {
        return item.isDisp === "1";
      });
      // add 削除されたデータの処理  王 end

      const findSelectedMedicine = (arr, cd) => arr.find(i => i.value === cd);
      const selectedItem =
        mediClass === "1"
          ? findSelectedMedicine(mediList, mediCd)
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
          //: findSelectedMedicine(mediMixList, `${mediCd}$`);
          : findSelectedMedicine(mediMixList, `${mediCd}`);
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      this.popParam.popoverContentSelected = selectedItem || {};

      //ポップオーバー表示
      showPopover(this.popParam);
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    },

    /**
     * @description 薬剤選択ボタン押下時のポップオーバー表示位置を取得
     * @param ポップオーバー表示位置
     */
    popoverTargetElement(index) {
      //ポップオーバーの表示位置を取得(薬剤選択ボタン押下時はそのボタンの位置、それ以外はnull)
      const position = index === null ? null : this.$refs[index][0];
      return position;
    },

    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択した薬剤情報
     */
    selectedMedi(event, index) {
      //選択した薬剤名称とその分類を表示用・保存用パラメータに格納
      this.mediChange(event, index);
      //選択したボタンの場所データをリセット
      this.selectedIndex = null;
    },

    /**
     * @description ポップオーバー内、キャンセルボタン押下時の処理
     */
    closePopover,

    // セット情報、行追加
    addMedicineSet() {
      this.medicineSetInfo.setInfoJsonArr.push({
        cd: "",
        class: "",
        // add 9973 -4 by kangjie 20231025 start
        // amount: 0,
        // #9848+9849 追加希望は空欄です linjunfeng start
        // amount: "0",
        amount: "",
         // #9848+9849 追加希望は空欄です linjunfeng end
        // add 9973 -4 by kangjie 20231025 end
        procedure_timing_cd: "",
        medicate_timing_cd: ""
      })
      this.dispArr.push({
        id: _.uniqueId("medicine"),
        cd: { initValue: "", editValue: "" },
        class: { initValue: "", editValue: "" },
        // add 9973 -4 by kangjie 20231025 start
        // amount: { initValue: 0, editValue: 0 },
        // #9848+9849 追加希望は空欄です linjunfeng start
        // amount: { initValue: "0", editValue: "0" },
        amount: { initValue: "", editValue: "" },
        // #9848+9849 追加希望は空欄です linjunfeng end
        // add 9973 -4 by kangjie 20231025 end
        procedure_timing_cd: { initValue: "", editValue: "" },
        medicate_timing_cd: { initValue: "", editValue: "" },
        del_check: { initValue: "0", editValue: "0" }
      })
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end

      // 最後までスクロールする
      this.$nextTick(() => {
        const ele = document.getElementsByClassName("data-table")[0];
        if (ele) {
          ele.scrollTop = ele.scrollHeight;
        }
      });
    },

    /**
     * @description セット情報、削除ボタン押下時の行削除処理
     */
    delMedicineSet(num) {
      //保存用パラメータから削除
      this.medicineSetInfo.setInfoJsonArr.splice(num, 1);
      //表示用パラメータから削除
      this.dispArr.splice(num, 1);
    },

    // 薬剤セット名変更
    onNameChange() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "name") {
          this.updateEditRecord(
            "name",
            this.medicineSetInfo.medicineSetName.editValue
          );
        }
      }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
      // if (this.medicineSetInfo.medicineSetName.initValue!=this.medicineSetInfo.medicineSetName.editValue) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    },

    // 省略薬剤セット名変更
    onShortNameChange() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "medicineSetShortName") {
          this.updateEditRecord(
            "medicineSetShortName",
            this.medicineSetInfo.medicineSetShortName.editValue
          );
        }
      }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
    //  if (this.medicineSetInfo.medicineSetShortName.initValue!=this.medicineSetInfo.medicineSetShortName.editValue) {
    //     this.changeButton();
    //   }else{
    //     EventBus.$emit("mstHolidayRegistered", true);
    //   }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    },

    // 連携コード1情報変更
    onInHospitalCd1Change() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "inHospitalCd1") {
          this.updateEditRecord(
            "inHospitalCd1",
            this.medicineSetInfo.inHospitalCd1.editValue
          );
        }
      }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
      // if (this.medicineSetInfo.inHospitalCd1.initValue!=this.medicineSetInfo.inHospitalCd1.editValue) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    },

    // 連携コード2情報変更
    onInHospitalCd2Change() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "inHospitalCd2") {
          this.updateEditRecord(
            "inHospitalCd2",
            this.medicineSetInfo.inHospitalCd2.editValue
          );
        }
      }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
      //  if (this.medicineSetInfo.inHospitalCd2.initValue!=this.medicineSetInfo.inHospitalCd2.editValue) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
    // checkUpdate(index){
      //  if (this.dispArr[index].del_check.initValue!==this.dispArr[index].del_check.editValue) {
      //   this.changeButton();
      //  }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      //  }
    // },
    // changeDown(index){
      //  if (this.dispArr[index].amount.initValue!=this.dispArr[index].amount.editValue) {
      //   this.changeButton();
      //  }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      //  }
    // },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    // セット情報変更
    onSetInfoChange() {
      for (const i in this.medicineSetInfo.setInfoJsonArr) {
        //薬剤コード
        this.medicineSetInfo.setInfoJsonArr[i].cd = this.dispArr[
          i
          ].cd.editValue;

        //薬剤区分
        this.medicineSetInfo.setInfoJsonArr[i].class = this.dispArr[
          i
          ].class.editValue;

        //数量
        // add 9973 -4 by kangjie 20231025 start
        // this.medicineSetInfo.setInfoJsonArr[i].amount = this.dispArr[
        //   i
        //   ].amount.editValue ;
        this.medicineSetInfo.setInfoJsonArr[i].amount = this.dispArr[
          i
          ].amount.editValue +"";
        // add 9973 -4 by kangjie 20231025 end

        //手技
        this.medicineSetInfo.setInfoJsonArr[
          i
          ].procedure_timing_cd = this.dispArr[i].procedure_timing_cd.editValue;

        //投与タイミング
        this.medicineSetInfo.setInfoJsonArr[
          i
          ].medicate_timing_cd = this.dispArr[i].medicate_timing_cd.editValue;
      }

      //保存用パラメータをコピー
      const saveArr = Array.from(this.medicineSetInfo.setInfoJsonArr);

      //薬剤が選択されていない or 数量がnullの場合は保存パラメータから外す処理
      for (let i = saveArr.length - 1; i > -1; i--) {
        //薬剤コード
        const saveCd = saveArr[i].cd;
        //薬剤数量
        const saveNum = saveArr[i].amount;

        //薬剤が選択されていない or 数量がnullか判定
        if (!saveCd || saveNum === null) {
          //保存用パラメータから削除
          saveArr.splice(i, 1);
        }
      }

      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "setInfo") {
          this.medicineSetInfo.setInfoJsonStr = JSON.stringify(saveArr);
          this.updateEditRecord("setInfo", this.medicineSetInfo.setInfoJsonStr);
        }
      }
    },

    // セット情報の薬剤が変更された際、薬剤名称と薬剤分類を変更する処理
    mediChange(event, index) {
      let medicineCd = event.value;
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      //const medicineType = medicineCd ? event.fnValue.薬剤区分 : null;
      const medicineType = event.kbnValue || null;
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤コードのみString型で取得するためNumberへ変換
        medicineCd = Number(event.value.split("$")[0]);
      }

      //選択した薬剤のコードをリストに格納
      this.dispArr[index].cd.editValue = medicineCd;

      //選択した薬剤の薬剤分類をリストに格納
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      //this.dispArr[index].class.editValue = medicineType;
      this.dispArr[index].class.editValue = event.kbnValue
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

      // #9848+9849 薬剤変更時,薬剤マスタ依存＋薬剤マスタで未指定の場合変更しない linjunfeng start
      //選択した薬剤の手技をリストに格納
      // this.dispArr[index].procedure_timing_cd.editValue = this.getMediProcedureCd(medicineCd, medicineType);
      const procedureTimingCd = this.getMediProcedureCd(medicineCd, medicineType);
      if (procedureTimingCd) {
        this.dispArr[index].procedure_timing_cd.editValue = procedureTimingCd;
      }
      //選択した薬剤の投与タイミングをリストに格納
      // this.dispArr[index].medicate_timing_cd.editValue = this.getMediTimingCd(medicineCd, medicineType);
      const timingCd = this.getMediTimingCd(medicineCd, medicineType);
      if (timingCd) {
        this.dispArr[index].medicate_timing_cd.editValue = timingCd;
      }
      // #9848+9849 薬剤変更時,薬剤マスタ依存＋薬剤マスタで未指定の場合変更しない linjunfeng end
    },

    getMedicineClass(medicineCd, medicineType) {
      let mstData = this.mstMedicine;
      let cdKey = "medicineCd";
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤なら
        mstData = this.mstMedicineMix;
        cdKey = "medicineMixCd";
      }
      const medicineInfo = mstData.find(mst => mst[cdKey] === medicineCd);
      if (!medicineInfo) {
        return null;
      }

      const classCd = medicineInfo.classCd;
      return this.getmediClass(classCd);
    },

    /**
     * @description 薬剤コードを薬剤名称に変換する処理
     * @param 画面上に表示する薬剤のコード
     */
    getMediName(cd, medicineType) {
      //薬剤名称(nullだと薬剤コードが画面に表示される、空文字で定義)
      let mediName = "";

      let mstData = this.mstMedicine;
      let cdKey = "medicineCd";
      let nameKey = "medicineName";
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤なら
        mstData = this.mstMedicineMix;
        cdKey = "medicineMixCd";
        nameKey = "medicineMixName";
      }

      //薬剤マスタが取得出来ているなら変換を行う
      if (mstData) {
        for (const item of mstData) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item[cdKey] === cd) {
            // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
            //mediName = item[nameKey];
            mediName = (item.key_type == 2 && item.key_class == -1 ? "【分類不一致】" : '') + item.tabooAllergy + item.expired + item.deleted + item.includeDeleted + item[nameKey];
            // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
            break;
          }
        }
      }
      return mediName;
    },

    /**
     * @description 薬剤コードに対応する薬剤分類を返す処理
     * @param 画面上に表示する薬剤分類
     */
    getmediClass(classCd) {
      //薬剤分類
      let mediClass = null;

      //薬剤分類マスタが取得出来ているなら変換を行う
      if (this.mstMediClass) {
        for (const item of this.mstMediClass) {
          //薬剤分類マスタのコードと画面上の薬剤の分類コードが同じ、薬剤分類を取得
          if (item.classCd === classCd) {
            mediClass = item.className;
            break;
          }
        }
      }
      return mediClass;
    },

    /**
     * @description 薬剤コードを薬剤単位に変換する処理
     * @param 画面上に表示する薬剤の単位
     */
    getMediUnit(cd, medicineType) {
      //薬剤単位
      let mediUnit = null;

      let mstData = this.mstMedicine;
      let cdKey = "medicineCd";
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤なら
        mstData = this.mstMedicineMix;
        cdKey = "medicineMixCd";
      }

      //薬剤マスタが取得出来ているなら変換を行う
      if (mstData) {
        for (const item of mstData) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item[cdKey] === cd) {
            mediUnit = item.unit;
            break;
          }
        }
      }
      return mediUnit;
    },

    /**
     * @description 薬剤コードを薬剤数量のステップ数に変換する処理
     * @param 画面上に表示する薬剤の単位
     */
    getMediUnitStep(data){
      let decPoint = null;
      let mstData = this.mstMedicine;
      if (data.class.editValue === "2") {
        // 調製薬剤なら
        mstData = this.mstMedicineMix;
      }
      //薬剤マスタが取得出来ているなら変換を行う
      if (mstData.length > 0) {
        for (const item of mstData) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item.medicineCd === data.cd.editValue || item.medicineMixCd === data.cd.editValue) {
            decPoint = item.unitDecimalPoint;
            break;
          }
        }
      }
      decPoint = parseInt(decPoint);
      if(isNaN(decPoint)){
        decPoint = 0;
      }
      return decPoint;
    },

    /**
     * @description 薬剤コードを薬剤手技に変換する処理
     * @param 画面上に表示する薬剤の手技
     */
    getMediProcedureCd(cd, medicineType) {
      const medicine = this.getMedicine(cd, medicineType);
      return medicine ? medicine.procedureCd : null;
    },

    /**
     * @description 薬剤コードを薬剤投与タイミングに変換する処理
     * @param 画面上に表示する薬剤の投与タイミング
     */
    getMediTimingCd(cd, medicineType) {
      const medicine = this.getMedicine(cd, medicineType);
      return medicine ? medicine.medicateTimingCd : null;
    },

    /**
     * @description 薬剤コードと種別から薬剤マスタ情報を取得する
     * @param cd 薬剤コード
     * @param medicineType 薬剤種別(1:通常薬剤、2:調製薬剤)
     */
    getMedicine(cd, medicineType) {
      // 薬剤区分に応じたマスタを取得.
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //const mstData = medicineType === "2" ? this.mstMedicineMix : this.mstMedicine;
      //const cdKey = medicineType === "2" ? "medicineMixCd" : "medicineCd";
      const mstData = medicineType == 2 ? this.mstMedicineMix : this.mstMedicine;
      const cdKey = medicineType == 2 ? "medicineMixCd" : "medicineCd";
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      if (!mstData) {
        return null;
      }
      return mstData.find(m => m[cdKey] === cd);
    },
    /**
     * @description データリストの高さを計算します
     */
    calculateDataListHeight(){
      // #9863 加算マスタ詳細を開くとtypeエラーが発生する 横展開2 linjunfeng start
      // let rowHeight = document.getElementsByClassName("medicine-set-info")[0].clientHeight;
      // let totalHeight = document.getElementsByClassName("modal-container")[0].clientHeight;
      // let topHeight = document.getElementsByClassName("toolbar")[0].clientHeight;
      // let bottomHeight = document.getElementsByClassName("modal-footer")[0].clientHeight;
      let rowHeight = document.getElementsByClassName("medicine-set-info")[0] ? document.getElementsByClassName("medicine-set-info")[0].clientHeight : 0;
      let totalHeight = document.getElementsByClassName("modal-container")[0] ? document.getElementsByClassName("modal-container")[0].clientHeight : 0;
      let topHeight = document.getElementsByClassName("toolbar")[0] ? document.getElementsByClassName("toolbar")[0].clientHeight : 0;
      let bottomHeight = document.getElementsByClassName("modal-footer")[0] ? document.getElementsByClassName("modal-footer")[0].clientHeight : 0;
      // #9863 加算マスタ詳細を開くとtypeエラーが発生する 横展開2 linjunfeng end
      let dataList = document.getElementsByClassName("data-table")[0];

      let actualHeight = totalHeight - topHeight - bottomHeight - rowHeight - 9;
      if (dataList) {
        dataList.style.height = actualHeight + "px";
      }

      // add 薬剤名の長さの調整 鞠 start
      if (document.getElementsByClassName("ntss-list-body-td ntss-list-body-td-background")[2]) {
        document.getElementsByClassName("ntss-list-body-td ntss-list-body-td-background")[2].style.width="30%"
      }
      // add 薬剤名の長さの調整 鞠 end
    },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 start
    // changeButton() {
    //   EventBus.$emit("mstHolidayRegistered", false);
    // }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 張玲 2024/01/08 end
    // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng start
    validateOnRegistration() {
      return this.validateData();
    },
    validateData() {
      let amountFlg = true;
      if (this.medicineSetInfo.setInfoJsonArr.length > 0) {
        for (let i = 0; i < this.medicineSetInfo.setInfoJsonArr.length; i++) {
          if (this.medicineSetInfo.setInfoJsonArr[i].amount == "" || isNaN(this.medicineSetInfo.setInfoJsonArr[i].amount) || this.medicineSetInfo.setInfoJsonArr[i].amount == 0) {
            amountFlg = false;
          }
        }
        if (!amountFlg) {
          // エラーメッセージ表示
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[13000170].title,
            message: DIALOG_MESSAGES[13000170].message
          });
          return false;
        }
      }
      return true;
    },
    // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng end
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.setInfo-list {
  height: 60vh;
  border-left: 1px solid;
  border-right: 1px solid;
  overflow: auto;
}
table {
  border-collapse: collapse;
}
table th,
table td {
  /*border: solid 1px black;*/
}

th.ntss-list-header-th-sticky {
  z-index: 1;
}

ons-col >>> * {
  box-sizing: border-box;
}

.list-delete {
  width: 3em;
}

.list-class {
  width: 7em;
}

.list-name {
  width: 100%;
  min-width: calc(11em + 50px);
}

.list-num {
  width: 10em;
}

.list-unit {
  width: 7em;
}

.list-code {
  width: 16em;
}

.list-timing-code {
  width: 16em;
}

.item-select {
  padding: 2px;
  width: 97% !important;
}

.item-button {
  width: 60px;
  padding: 0;
  margin-left: 2px;
}

.select-button {
  width: 50px;
  padding: 1px;
  margin: 2px 0 0 2px;
}

/* 項目名 mod=>flex: 0 0 35%;鞠 */
.item-title {
  max-width: 11em;
  margin-left: 5px;
}

/* 項目内容 */
.item-data {
  padding-bottom: 3px;
  padding-left: 3px;
  padding-right: 3px;
}
.data-table {
  display: block;
  overflow-x: auto;
}
.data-table >>> ons-row {
  min-width: 640px;
}
.link-code-input {
  width: 49% !important;
  box-sizing: border-box;
}
.set-name-input {
  width: 100%;
  box-sizing: border-box;
}
.spacer {
  display: inline-block;
  width: 2% !important;
  box-sizing: border-box;
}
.select-button.button {
  height: 1.9em;
  margin: auto 2px;
}
/* 一覧領域の幅
 * 各項目の幅：72em
 * 各項目のマージンなど：10px * 7
 * 選択ボタンの幅：50px
 */
.detail-list {
  min-width: calc(70em + 10px * 7  + 50px);
}
@media screen and (max-height: 510px) {
  .setInfo-list {
    height: 36vh;
  }
}
@media screen and (max-height: 610px) and (min-height: 510px) {
  .setInfo-list {
    height: 43vh;
  }
}
@media screen and (max-height: 740px) and (min-height: 610px){
  .setInfo-list {
    height: 50vh;
  }
}
@media screen and (max-height: 830px) and (min-height: 740px){
  .setInfo-list {
    height: 56vh;
  }
}
@media screen and  (min-width:480px) and (max-width:869px) {
  .setInfo-list {
    height: 56vh;
  }
}
@media screen and (max-width: 667px) {
  .setInfo-list >>> .item-title {
    max-height: 62px;
  }
  .data-table {
    display: block;
    overflow-x: auto;
  }
}
@media screen and (max-width: 375px) {
  .setInfo-list >>> .item-title {
    max-height: 62vh;
  }
  .data-table {
    display: block;
    overflow-x: auto;
    /* max-height: 49vh; */
  }
}
.frame{
  border: 1px solid black;
}

.ntss-list {
  position: unset;
}

.medi-name-wrapper {
  white-space: nowrap;
}
.medi-name {
  margin-top: 4px;
  width: calc(100% - 50px);
  min-width: 11em;
}
/* 削除ボタン */
.button-delete {
  display: block;
  margin: auto;
}
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
::v-deep .com-basic-sub-btn {
  margin-left: 5px
}
::v-deep .com-basic-sub-input {
  min-width: 13em;
  width: 100%;
  max-width: 28em;
  background-color: #f7f7f7;
  white-space: normal;
}
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
