<template>
  <div style="padding-bottom: 0.5px; min-width: 1050px; overflow-x: auto">
    <div class="medicine-mix-info" >
      <v-ons-row>
        <v-ons-col class="item-title">調製薬剤名</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="editMixRecord.name"
            @blur="updateInfo('name', $event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">省略調製薬剤名</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="editMixRecord.medicineMixShortName"
            @blur="updateInfo('medicineMixShortName', $event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">薬剤分類区分</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-select
            :value="editMixRecord.classCd"
            :options="medicineClassOptionList"
             @change="updateInfo('classCd', Number($event.target.value))"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">指示単位</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="editMixRecord.unit"
            @blur="updateInfo('unit', $event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-if="editMixRecord.unitDecimalPoint.editValue !== null">
        <v-ons-col class="item-title">指示単位小数部桁数</v-ons-col>
        <v-ons-col class="item-data list-input">
          <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng start -->
          <!-- <custom-input-number-pro
            class="custom-input-number"
            :value="editMixRecord.unitDecimalPoint.editValue"
            :digits="1"
            :step="1"
            :required="true"
            :min="0"
            :max="9"
            :emptyVal="9"
            @handlerInput="(val) => {
              updateInfo('unitDecimalPoint', val);
              editMixRecord.unitDecimalPoint.editValue = val;
            }"
          /> -->
          <custom-input-number-pro
            class="custom-input-number"
            :value="editMixRecord.unitDecimalPoint.editValue"
            :digits="1"
            :step="1"
            :required="true"
            :min="0"
            :max="8"
            :emptyVal="8"
            @handlerInput="(val) => {
              updateInfo('unitDecimalPoint', val);
              editMixRecord.unitDecimalPoint.editValue = val;
            }"
          />
          <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng end -->
        </v-ons-col>
      </v-ons-row>
      <!-- add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny start-->
      <v-ons-row v-if="editMixRecord.medicineSetNum.editValue !== null">
        <v-ons-col class="item-title">薬剤セット数</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input-number-pro
            class="custom-input-number"
            :value="editMixRecord.medicineSetNum.editValue"
            :digits="0"
            :step="1"
            :required="true"
            :min="0"
            :max="999"
            :emptyVal="1"
            @handlerInput="(val) => {
              updateInfo('medicineSetNum', val);
              editMixRecord.medicineSetNum.editValue = val;
            }"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">レせ単位</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="editMixRecord.unitSecond"
            @blur="updateInfo('unitSecond', $event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <!-- add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny end-->
      <v-ons-row>
        <v-ons-col class="item-title">注射薬</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-checkbox
            :value="editMixRecord.isShot"
            checked-value="1"
            unchecked-value="0"
            @change="updateInfo('isShot', $event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">自動実施</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-checkbox
            :value="editMixRecord.isMedicated"
            checked-value="1"
            unchecked-value="0"
            @change="updateInfo('isMedicated', $event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title" />
        <v-ons-col class="item-data list-input">
          <v-ons-row>
            <v-ons-col style="max-width:36%;">
              基準量<span style="margin-left: 33%;">指示単位</span>
            </v-ons-col>
            <v-ons-col>
              変換量
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">
          mL換算設定
        </v-ons-col>
        <v-ons-col class="item-data list-input">
          <v-ons-row>
            <v-ons-col style="max-width:25.5%;height:100%;line-height:170%">
              <!-- <custom-input-number
                :value="editMixRecord.amountUnit"
                style="width:60%"
                :digits="8"
                :decimal-digits="getDecDigits(checkEditRecord.unitDecimalPoint)"
                :min-value="0"
                :max-value="99999999.999999999"
                :loop-flg="true"
                :initial-value-lock="false"
                @input="
                  updateInfo(
                    'amountUnit',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
                @wheel.prevent="
                  updateInfo(
                    'amountUnit',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
                @keydown.up.prevent="
                  updateInfo(
                    'amountUnit',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
                @keydown.down.prevent="
                  updateInfo(
                    'amountUnit',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
              /> -->
              <custom-input-number-pro
                v-if="customInputNumberProIsShow"
                :value="editMixRecord.amountUnit.editValue"
                style="width:60%"
                :step="getAmountUnitStep(checkEditRecord.unitDecimalPoint)"
                :min="0"
                :max="getAmountUnitMaxPrecision(checkEditRecord.unitDecimalPoint, 99999999)"
                @handlerInput="(val) =>{ editMixRecord.amountUnit.editValue = val;changeButton() }"
              />
              {{ editMixRecord.unit.editValue }}
            </v-ons-col>
            <v-ons-col style="max-width:10%;">
              ＝
            </v-ons-col>
            <v-ons-col style="max-width:25.5%;height:100%;line-height:170%">
              <!-- <custom-input-number
                step="0.1"
                @blur="blurValueMl"
                :value="editMixRecord.amountMl"
                style="width:60%"
                :digits="8"
                :decimal-digits="1"
                :min-value="0"
                :max-value="99999999"
                :loop-flg="true"
                @input="
                  updateInfo(
                    'amountMl',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
                @wheel.prevent="
                  updateInfo(
                    'amountMl',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
                @keydown.up.prevent="
                  updateInfo(
                    'amountMl',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
                @keydown.down.prevent="
                  updateInfo(
                    'amountMl',
                    Number($event.target.value) > 99999999
                      ? 99999999
                      : Number($event.target.value)
                  )
                "
              /> -->
              <custom-input-number-pro
                v-if="customInputNumberProIsShow"
                :value="editMixRecord.amountMl.editValue"
                style="width:60%"
                :step="0.1"
                :min="0"
                :max="99999999.9"
                :emptyVal="null"
                @blur="blurValueMl"
                @handlerInput="(val) =>{ editMixRecord.amountMl.editValue = val;changeButton() }"
              />
              mL
            </v-ons-col>
            <v-ons-col >
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">投与タイミング</v-ons-col>
        <v-ons-col class="item-data list-input">
          <v-ons-select
            v-model="editMixRecord.medicateTimingCd.editValue"
            select-id="medicate-timing-cd"
          >
            <option
              v-for="(item, index) in comboMedicineTiming"
              :key="index"
              :value="item.value"
            >
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">手技</v-ons-col>
        <v-ons-col class="item-data list-input">
          <v-ons-select
            v-model="editMixRecord.procedureCd.editValue"
            select-id="procedure-cd"
          >
            <option
              v-for="(item, index) in comboMedicineProcedure"
              :key="index"
              :value="item.value"
            >
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">連携コード1</v-ons-col>
        <v-ons-col class="item-data list-input" style="margin-right: 30px;">
          <custom-input
                :value="editMixRecord.inHospitalCd1"
                oninput="if(value.length>20)value=value.slice(0,20)"
                @blur="updateInfo('inHospitalCd1', $event.target.value)"
              />
        </v-ons-col>
        <v-ons-col class="item-title">連携コード2</v-ons-col>
        <v-ons-col class="item-data list-input" style="margin-right: 30px;">
          <custom-input
                :value="editMixRecord.inHospitalCd2"
                oninput="if(value.length>20)value=value.slice(0,20)"
                @blur="updateInfo('inHospitalCd2', $event.target.value)"
              />
        </v-ons-col>
        <v-ons-col class="item-title">連携コード3</v-ons-col>
        <v-ons-col class="item-data list-input">
          <custom-input
            :value="editMixRecord.inHospitalCd3"
            oninput="if(value.length>20)value=value.slice(0,20)"
            @blur="updateInfo('inHospitalCd3', $event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-row class="setInfo-list custom-setInfo-list">
        <v-ons-col class="item-title">
          <div class="setInfo-title" :style="{ clip: clipValue }">
            <v-ons-col>調製情報</v-ons-col>
            <v-ons-col>
              <div>
                <v-ons-button class="item-button btn3-normal" @click="addMedicineSet()">
                  追加
                </v-ons-button>
              </div>
            </v-ons-col>
          </div>
        </v-ons-col>
        <v-ons-col class="item-data list-input data-table print-height-auto">
          <div>
            <table class="ntss-list sticky_table" style="position: relative;table-layout: fixed;">
              <thead display="block" class="setInfo-thead" :style="{ clip: clipValue }">
                <tr>
                  <th class="ntss-list-header-th-sticky list-class color-header">数量固定</th>
                  <th class="ntss-list-header-th-sticky list-name color-header">薬剤名</th>
                  <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng start  -->
                  <!-- <th class="ntss-list-header-th-sticky list-num color-header">数量modify by lijingnan 2022-11-04[5548]調整薬剤マスタのレイアウト不正 -- start<v-ons-icon style="margin-left: 5px;" icon="fa-question-circle" @click="showPopOver($event)"></v-ons-icon>modify by lijingnan 2022-11-04[5548]調整薬剤マスタのレイアウト不正 -- end -->
                  <th class="ntss-list-header-th-sticky list-num-pro color-header">数量
                    <v-ons-icon style="margin-left: 5px;" icon="fa-question-circle" @click="showPopOver($event)"></v-ons-icon>
                  </th>
                  <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng end  -->
                  <th class="ntss-list-header-th-sticky list-num color-header">指示単位</th>
                  <th class="ntss-list-header-th-sticky list-delete color-header"/>
                </tr>
              </thead>
              <tr ref="setInfoDummyItem" class="non-display setInfo-dummy-item" style="height: 2.7em;">
                <th>Dummy</th>
              </tr>
              <tr v-for="(item, index) in editMixInfoList" :key="item.id.editValue">
                <!-- 数量固定 -->
                <td style="" class="ntss-list-body-td ntss-list-body-td-background">
                  <custom-checkbox
                    :value="item.solvent"
                    checked-value="1"
                    unchecked-value="0"
                  />
                </td>
                <!-- 薬剤名 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <custom-input
                    style="width:100%; min-width: 100px;"
                    class="medicine_name"
                    :value="item.cd"
                    :display-string="getMediName(item.cd.editValue)"
                    disabled
                  />
                  <v-ons-button
                    :ref="index"
                    class="select-button btn3-normal"
                    @click="selectMedicine(index, item.cd.editValue)"
                    style="margin-bottom: 5px;"
                  >
                    <!-- mod 画面デザイン 對應 王 end-->
                    選択
                  </v-ons-button>
                </td>
                <!-- 数量 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <custom-input-simple-number
                    :value="item.amount"
                    :step-value="getMediUnitStepSimple(item)"
                    :min-value="0"
                    :max-value="99999999.999999999"
                    :loop-flg="false"
                    :style="displayStyles"
                    @change="changeValueAmount(index,item.decPoint),changeButton()"
                    @input="inputValueAmount($event,item.decPoint)"
                    @keydown.69.prevent
                  /> -->
                  <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start -->
                  <!-- <custom-input-simple-number
                    :value="item.amount"
                    :step-value="getMediUnitStepSimple(item)"
                    :minValue="0"
                    :maxValue="99999999.999999999"
                    :loop-flg="false"
                    :style="displayStyles"
                    @change="changeValueAmount(index,item.decPoint)"
                    @input="inputValueAmount($event,item.decPoint)"
                    @keydown.69.prevent
                  /> -->
                  <custom-input-number-pro
                    :value="item.amount.editValue"
                    :step="getMediUnitStepSimple(item)"
                    :invalidArray="getInvalidArray(item.decPoint)"
                    :required="true"
                    :min="0"
                    :max="maxPrecision(item.decPoint, 99999999)"
                    @handlerInput="(val) =>{ item.amount.editValue = val }"
                  />
                  <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end -->
                  <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
                <!-- 指示単位 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  {{ getMediUnit(item.cd.editValue) }}
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
    <v-ons-popover cancelable
                   :visible.sync="userMenuPopoverVisible"
                   :target="userMenuPopoverTarget"
                   :cover-target="false"
                   :direction="userMenuPopoverDirection"
                   :class="fontSizeSet"
                   @preshow="popoverPreShow"
                   @postshow="popoverPostShow"
                   @posthide="popoverPosthide"
    >
      <p id="popOverMessage" style="margin: 10px;">テスト</p>
    </v-ons-popover>
  </div>
</template>

<script>
import _ from "underscore";
import { mapActions, mapGetters } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import BigNumber from "bignumber.js";
import { showPopover, closePopover } from "@/functions/PopoverFunctions";
import {
  encodeEditableRecord,
  decodeEditableRecord
} from "@/functions/PatInfoFunctions";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customSelect from "@/components/common/custom-form-tags/CustomMstMedicineMixSelect.vue";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
// import {
//   DEFAULT_PROCEDURE,
//   DEFAULT_MEDICATE_TIMING
// } from "@/constants/facilitySetting";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// FNSI-修正 マスタ削除の対応 楊 add start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
// FNSI-修正 マスタ削除の対応 楊 add end
import PopoverMixin from "@/components/PopoverMixin";
import { EventBus } from "@/eventBus.js";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #9848+9849 数値IFのスタイル全不正 linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
// add #9848+9849 数値IFのスタイル全不正 linjunfeng end
export default {
  name: "MstMedicineMix",
  mixins: [PopoverMixin],
  components: {
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
      // 編集レコード
      editMstMedicineMixRecord: {
        medicineMixCd: { initValue: null, editValue: null },
        name: { initValue: null, editValue: null },
        medicineMixShortName: { initValue: null, editValue: null },
        classCd: { initValue: null, editValue: null },
        unit: { initValue: null, editValue: null },
        amountUnit: { initValue: null, editValue: null },
        amountMl: { initValue: null, editValue: null },
        mixInfo: { initValue: null, editValue: null },
        isShot: { initValue: null, editValue: null },
        isMedicated: { initValue: null, editValue: null },
        inHospitalCd1: { initValue: null, editValue: null },
        inHospitalCd2: { initValue: null, editValue: null },
        inHospitalCd3: { initValue: null, editValue: null },
        medicateTimingCd: { initValue: null, editValue: null },
        procedureCd: { initValue: null, editValue: null },
        unitDecimalPoint:{ initValue: null, editValue: null },
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny start
        medicineSetNum:{ initValue: null, editValue: null },
        unitSecond:{ initValue: null, editValue: null },
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny end
        classiFicationFlg: null
      },
      // jsonArray型(調整薬剤情報)
      editMixInfoList: [],
      initEditMixInfoList:[],
      // 薬剤マスタ
      mstMedicine: [],
      // 薬剤分類マスタ
      mstMedicineClass: [],
      // 調製薬剤マスタ
      mstMedicineMix: [],
      // 投与タイミングマスタ
      comboMedicineTiming: [],
      // 手技マスタ
      comboMedicineProcedure: [],
      // 薬剤選択ポップオーバーのパラメータ
      popParam: {
        popoverVisible: false, // 表示非表示
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
      // 数量入力制限
      pattern: new RegExp("[+-]?\\d+(?:\\.\\d+)?(?:[+-]?\\d+)?"),
      classCd: null,
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: 'up',
      clipValue: null,
      customInputNumberProIsShow: false
    };
  },

  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    // add 調整情報部分の余白が不適切 鞠 start
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    // add 調整情報部分の余白が不適切 鞠 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
    }),
    editMixRecord() {
      return this.editMstMedicineMixRecord;
    },

    checkEditRecord(){
      return this.editRecord;
    },
    // del #9848+9849 数値IFのスタイル全不正 linjunfeng start
    // displayStyles() {
    //     return {width: "83.5%"}
    // },
    // del #9848+9849 数値IFのスタイル全不正 linjunfeng end
    medicineClassOptionList() {
      const filterMst = this.mstMedicineClass.filter(
        // 透析液・補液は除外
        mst => !(mst.classType === 2 || mst.classType === 3)
      );
      /* add 空欄,save -1 楊 start*/
      filterMst.unshift({
        classCd: -1,
        className: " "
      });
      /* add 空欄,save -1 楊 end*/
      return filterMst.map(mst => ({
        value: mst.classCd,
        //  FNSI-修正 マスタ削除の対応 Du add start
        displayValue: mst.isDisp == "1" || !mst.isDisp ? mst.className : MASTER_DELETE_DISPLAY.DELETED + mst.className,
        // #9863 Invalid prop: custom validator check failed for prop "options".横展開2 linjunfeng start
        // isDisp: mst.isDisp
        // #9863 Invalid prop: custom validator check failed for prop "options".横展開2 linjunfeng end
        //  FNSI-修正 マスタ削除の対応 Du add end
      }));
    },
    isAnticoagulant() {
      const classCd = this.editMixRecord.classCd.editValue;
      const classInfo = this.mstMedicineClass.find(
        mst => mst.classCd === classCd
      );
      // 抗凝固剤フラグ
      return classInfo ? classInfo.classType : null === 1;
    }
  },

  watch: {
    "editMixRecord.medicateTimingCd.editValue"(value) {
      if (value === "") {
        this.updateInfo("medicateTimingCd", null);
      } else {
        this.updateInfo("medicateTimingCd", value);
      }
    },
    "editMixRecord.procedureCd.editValue"(value) {
      if (value === "") {
        this.updateInfo("procedureCd", null);
      } else {
        this.updateInfo("procedureCd", value);
      }
    },
    "editMixRecord.amountUnit.editValue"(value) {
      if (value === "") {
        this.updateInfo("amountUnit", null);
      } else {
        this.updateInfo("amountUnit", value);
      }
    },
    //add #9612 薬剤分類を切り替える場合は、分類無しを選択し、ml換算設定をクリアしません。zhangbo start
    "editMixRecord.amountMl.editValue"(value) {
      if (value === "") {
        this.updateInfo("amountMl", null);
      } else {
        this.updateInfo("amountMl", value);
      }
    },
    //add #9612 薬剤分類を切り替える場合は、分類無しを選択し、ml換算設定をクリアしません。。zhangbo end
    // add 調整情報部分の余白が不適切 鞠 start
    getFontSize() {
      this.changeMedicineSet();
      this.calculateListHeight();
    },
    // add 調整情報部分の余白が不適切 鞠 end
    windowWidth() {
      this.scrollHandler();
      this.calculateListHeight();
    },
    windowHeight() {
      this.calculateListHeight();
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    editMstMedicineMixRecord:{
      handler(){
        if (this.editMstMedicineMixRecord.isMedicated.initValue ===null ) {
          this.editMstMedicineMixRecord.isMedicated.initValue = "0";
        }
        if (this.editMstMedicineMixRecord.isMedicated.editValue ===null ) {
          this.editMstMedicineMixRecord.isMedicated.editValue = "0";
        }
        // nullを"0"に置換える
        const normalizeNullZero = v => (v === null ? "0" : v);
        
        if (
        this.editMstMedicineMixRecord.name.initValue!=this.editMstMedicineMixRecord.name.editValue||
        this.editMstMedicineMixRecord.medicineMixShortName.initValue!=this.editMstMedicineMixRecord.medicineMixShortName.editValue||
        this.editMstMedicineMixRecord.classCd.initValue!=this.editMstMedicineMixRecord.classCd.editValue||
        this.editMstMedicineMixRecord.unit.initValue!=this.editMstMedicineMixRecord.unit.editValue||
        this.editMstMedicineMixRecord.amountUnit.initValue!=this.editMstMedicineMixRecord.amountUnit.editValue||
        this.editMstMedicineMixRecord.amountMl.initValue!=this.editMstMedicineMixRecord.amountMl.editValue||
        this.editMstMedicineMixRecord.mixInfo.initValue!=this.editMstMedicineMixRecord.mixInfo.editValue||
        normalizeNullZero(this.editMstMedicineMixRecord.isShot.initValue)!=normalizeNullZero(this.editMstMedicineMixRecord.isShot.editValue)||
        normalizeNullZero(this.editMstMedicineMixRecord.isMedicated.initValue)!=normalizeNullZero(this.editMstMedicineMixRecord.isMedicated.editValue)||
        this.editMstMedicineMixRecord.inHospitalCd1.initValue!=this.editMstMedicineMixRecord.inHospitalCd1.editValue||
        this.editMstMedicineMixRecord.inHospitalCd2.initValue!=this.editMstMedicineMixRecord.inHospitalCd2.editValue||
        this.editMstMedicineMixRecord.inHospitalCd3.initValue!=this.editMstMedicineMixRecord.inHospitalCd3.editValue||
        this.editMstMedicineMixRecord.medicateTimingCd.initValue!=this.editMstMedicineMixRecord.medicateTimingCd.editValue||
        this.editMstMedicineMixRecord.procedureCd.initValue!=this.editMstMedicineMixRecord.procedureCd.editValue||
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny start
        this.editMstMedicineMixRecord.medicineSetNum.initValue!=this.editMstMedicineMixRecord.medicineSetNum.editValue||
        this.editMstMedicineMixRecord.unitSecond.initValue!=this.editMstMedicineMixRecord.unitSecond.editValue||
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切  susny end
        this.editMstMedicineMixRecord.unitDecimalPoint.initValue!=this.editMstMedicineMixRecord.unitDecimalPoint.editValue
        ) {
          this.changeButton();
        } else {
          EventBus.$emit("mstHolidayRegistered", true);
        }
      },
      deep:true
    },
    editMixInfoList:{
      handler(){
        if (JSON.stringify(this.editMixInfoList)!==JSON.stringify(this.initEditMixInfoList)) {
          this.changeButton();
        }else{
          EventBus.$emit("mstHolidayRegistered", true);
        }
      },
      deep:true
    }
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
  },

  async created() {
    //施設コードを抽出条件に追加
    // add マスタ一覧 施設切替を可能とする 王 start
    const requestParam = {
      // facilityCd: this.getFacilityCd
      facilityCd: this.getFacilitySwitch
    };
    // add マスタ一覧 施設切替を可能とする 王 end

    // add 削除されたデータの処理  王 start
    const [
      // 薬剤マスタ
      // mstMedicine,
      // 薬剤分類マスタ
      mstMedicineClass,
      // 調製薬剤マスタ
      mstMedicineMix,
      // 薬剤マスタ（削除済のデータも含む）
      responseMstMedicineData,
    ] = await Promise.all([
      // ApiHelper.get("/mstInfo/mstMedicine", requestParam),
      ApiHelper.get("/mstInfo/mstMedicineClassIncludeDeleted", requestParam),
      ApiHelper.get("/mstInfo/mstMedicineMix", requestParam),
      ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam),
    ]).catch(() => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MasterModalComponentMstMedicineMix.vue', 'created', 'マスタ取得失敗');
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw new Error("マスタ取得失敗");
    });
    // this.mstMedicine = mstMedicine.data;
    this.mstMedicine = responseMstMedicineData.data;

    this.mstMedicine = this.mstMedicine.map((item) =>{
        if (item.isDisp === "0") {
          item.medicineName = MASTER_DELETE_DISPLAY.DELETED + item.medicineName;
        }
        return item;
      }
    )
    // add 削除されたデータの処理  王 start
    this.mstMedicineClass = mstMedicineClass.data;
    this.mstMedicineMix = mstMedicineMix.data;

    // 選択リストのデータはsys_master_defineで定義したものを取得
    // 投与タイミング区分
    let combo1 = this.columnDefinition.find(column => {
      return column.field === "medicateTimingCd";
    });
    this.comboMedicineTiming = combo1.values;

    // 手技
    combo1 = this.columnDefinition.find(column => {
      return column.field === "procedureCd";
    });
    this.comboMedicineProcedure = combo1.values;

    const editMstMedicineMix = this.editRecord;
    this.classCd = this.editRecord.classCd

    // modify start #9301
    // 投与タイミングと手技は新規作成かつ初回限定で施設設定マスタのデフォルト値を取る
    // if (this.editRecord.operation === 1) {
    //   const medicate = this.editRecord.medicateTimingCd;
    //   const procedure = this.editRecord.procedureCd;

    //   // add マスタ一覧 施設切替を可能とする 王 start
    //   let selectCd = await this.findFacilitySettingInfo({
    //     // facilityCd: this.getFacilityCd,
    //     facilityCd: this.getFacilitySwitch,
    //     settingNo: DEFAULT_MEDICATE_TIMING
    //   });
    //   if (selectCd.data > 0 && medicate === "") {
    //     editMstMedicineMix.medicateTimingCd = selectCd.data;
    //   }

    //   selectCd = await this.findFacilitySettingInfo({
    //     // facilityCd: this.getFacilityCd,
    //     facilityCd: this.getFacilitySwitch,
    //     settingNo: DEFAULT_PROCEDURE
    //   });
    //   // add マスタ一覧 施設切替を可能とする 王 end
    //   if (selectCd.data > 0 && procedure === "") {
    //     editMstMedicineMix.procedureCd = selectCd.data;
    //   }
    // }
    editMstMedicineMix.medicateTimingCd = this.editRecord["medicateTimingCd"];
    editMstMedicineMix.procedureCd = this.editRecord["procedureCd"];
    // modify end #9301
    // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny start
    // 新規作成時のみ、薬剤セット数が未設定の場合はデフォルト1（一覧addRowでnumber型は0になる）
    const isNewRecord =
      this.editRecord.operation === 1 || this.editRecord.isAddRow === true;
    const medicineSetNum = editMstMedicineMix.medicineSetNum;
    if (
      isNewRecord &&
      (medicineSetNum == null ||
        medicineSetNum === "" ||
        medicineSetNum === 0 ||
        medicineSetNum === "0")
    ) {
      editMstMedicineMix.medicineSetNum = 1;
    }
    // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny end

    this.editMstMedicineMixRecord = encodeEditableRecord(editMstMedicineMix);
    this.customInputNumberProIsShow = true;

    if (editMstMedicineMix.mixInfo && editMstMedicineMix.mixInfo !== "") {
      const mixInfo = JSON.parse(editMstMedicineMix.mixInfo);
      this.editMixInfoList = mixInfo.map(item=>
      encodeEditableRecord({
          id: _.uniqueId("medicineMix"),
          cd:item.cd,
          amount:this.defaultValueAmount(item.amount,this.getMediUnitStepDefault(item.cd)),
          solvent:item.solvent,
          decPoint:this.getMediUnitStepDefault(item.cd),
          del_check: "0"
        })
      );
    }
   this.initEditMixInfoList=JSON.parse(JSON.stringify(this.editMixInfoList));
    // 高さを計算する
    this.$nextTick(() => {
      this.calculateListHeight();
    });
    // add #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 start
    // POP画面閉じる前にイベント処理を追加する
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    // add #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 end
  },

  methods: {
    ...mapActions("master-maintenance", [
      "setEditRecord",
      // "findFacilitySettingInfo"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    maxPrecision(decPoint, value) {
      let num = parseInt(decPoint.editValue);
      if(isNaN(num)){
        return value;
      }
      const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
      return Number(decimalNumber.toFixed(num));
    },
    getInvalidArray(decPoint) {
      let arr = [];
      let num = parseInt(decPoint.editValue);
      let zero = 0;
      let data = isNaN(num) ? "0" : zero.toFixed(num);
      arr.push(data)
      return arr;
    },
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
    // ml換算-換算数量のfocusOut時制御
    //add start 鞠 mL換算は小数点1桁
    blurValueMl() {
      // #9612 vue.esm.js:1906 TypeError: Cannot read properties of null (reading 'toString')。linjunfeng start
      // if (this.editMixRecord.amountMl.editValue.toString().split(".")[1].length > 1) {
      if (this.editMixRecord.amountMl.editValue?.toString().split(".")[1]?.length > 1) {
      // #9612 vue.esm.js:1906 TypeError: Cannot read properties of null (reading 'toString')。linjunfeng end
        let str = this.editMixRecord.amountMl.editValue.toString();
        let strIndex = str.indexOf('.');
        this.editMixRecord.amountMl.editValue = str.substring(0, strIndex + 2);
      }
      // add end
    },
    // add 4734 調製情報の余白の改修 鞠 start
    changeMedicineSet() {
      document.getElementsByClassName("setInfo-list custom-setInfo-list")[0].style.marginTop = "12px"
    },
    // add 4734 調製情報の余白の改修 鞠 end
    /**
     * @description プロンプト
     */
    showPopOver(event) {
      let pop = document.getElementById("popOverMessage");
      // add 全マスタメッセージ調整 王 start
      // pop.innerText = "指示数量1あたりの数量を入れる。";
      pop.innerText = DIALOG_MESSAGES[12000016].message;
      // add 全マスタメッセージ調整 王 end
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    },

    /**
     * @description 薬剤用ポップオーバーを表示
     */
    selectMedicine(index, mediCd) {
      // 吹き出し位置用：選択したボタンの位置を格納
      this.selectedIndex = index;

      // 絞り込み条件を作成(薬剤分類)
      const mediClassList = this.mstMedicineClass.map(item => {
        return {
          // 分類名称
          text: item.className,
          // 分類コード
          value: item.classCd
        };
      });
      // リストに全選択の項目を追加
      mediClassList.unshift({ text: "すべて", value: 0 });

      //絞り込み条件(薬剤区分・薬剤分類)をパラメータに設定
      this.popParam.popoverFilter = [
        {
          // 薬剤区分の絞り込み条件を追加
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [{ text: "通常薬剤", value: "1" }]
        },
        {
          // 薬剤分類の絞り込み条件を追加
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: mediClassList
        }
      ];

      // add 削除されたデータの処理  王 start
      // 薬剤名一覧を作成
      // 薬剤マスタの薬剤名称と薬剤コードに薬剤区分と薬剤分類を追加したリストを作成
      const mediList = this.mstMedicine.map(item => {
        return {
          // 薬剤コード
          value: item.medicineCd,
          // フィルタ用
          fnValue: {
            薬剤区分: "1",
            薬剤分類: item.classCd
          },
          // 薬剤名称
          text: item.medicineName,
          isDisp: item.isDisp
        };
      });
      // リストをパラメータに格納
      this.popParam.popoverContentDataset = mediList;
      this.popParam.popoverContentDataset = this.popParam.popoverContentDataset.filter(item => {
        return item.isDisp === "1";
      });
      // add 削除されたデータの処理  王 end
      this.popParam.popoverContentSelected = mediList.find(medi => medi.value === mediCd) || {};

      // ポップオーバー表示
      showPopover(this.popParam);
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
    },

    /**
     * @description 薬剤選択ボタン押下時のポップオーバー表示位置を取得
     * @param ポップオーバー表示位置
     */
    popoverTargetElement(index) {
      // ポップオーバーの表示位置を取得(薬剤選択ボタン押下時はそのボタンの位置、それ以外はnull)
      const position = index === null ? null : this.$refs[index][0];
      return position;
    },
       //[確認]ボタンの状態の変更をトリガーします
      changeButton() {
          EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択した薬剤情報
     */
    selectedMedi(event, index) {
      // 選択した薬剤のコードをリストに格納
      this.editMixInfoList[index].cd.editValue = event.value;
      this.editMixInfoList[index].decPoint.editValue = this.getMediUnitStepDefault(event.value);
      // del #9848+9849 数値IFのスタイル全不正 linjunfeng start
      // this.editMixInfoList[index].amount.editValue =
      //   this.convertExponential(this.editMixInfoList[index].amount.editValue,
      //     this.editMixInfoList[index].decPoint.editValue);
      // del #9848+9849 数値IFのスタイル全不正 linjunfeng end
      // 選択したボタンの場所データをリセット
      this.selectedIndex = null;
    },

    /**
     * @description ポップオーバー内、キャンセルボタン押下時の処理
     */
    closePopover,

    // セット情報、行追加
    addMedicineSet() {
      const addInfo = {
        id: _.uniqueId("medicineMix"),
        cd: { initValue: null, editValue: null },
        // #9848+9849 追加希望は空欄です linjunfeng start
        // amount: { initValue: "0", editValue: "0" },
        amount: { initValue: "", editValue: "" },
        // #9848+9849 追加希望は空欄です linjunfeng end
        solvent: { initValue: "0", editValue: "0" },
        del_check: { initValue: "0", editValue: "0" },
        decPoint: { initValue:"0", editValue:"0" }
      };
      this.editMixInfoList = [...this.editMixInfoList, addInfo];
      this.$nextTick(() => {
        const ele = document.getElementsByClassName("modal-body modal-scroll")[0];
        if (ele) {
          ele.scrollTop = ele.scrollHeight;
        }
      });
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
    },

    /**
     * @description セット情報、削除ボタン押下時の行削除処理
     */
    delMedicineSet(index) {
      this.editMixInfoList.splice(index, 1);
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
    },

    /**
     * @description 薬剤コードを薬剤名称に変換する処理
     * @param 画面上に表示する薬剤のコード
     */
    getMediName(cd) {
      //薬剤名称(nullだと薬剤コードが画面に表示される、空文字で定義)
      let mediName = "";

      //薬剤マスタが取得出来ているなら変換を行う
      if (this.mstMedicine) {
        for (const item of this.mstMedicine) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item.medicineCd === cd) {
            mediName = item.medicineName;
            break;
          }
        }
      }
      return mediName;
    },

    /**
     * @description 薬剤コードを薬剤単位に変換する処理
     * @param 画面上に表示する薬剤の単位
     */
    getMediUnit(cd) {
      //薬剤単位
      let mediUnit = null;

      //薬剤マスタが取得出来ているなら変換を行う
      if (this.mstMedicine) {
        for (const item of this.mstMedicine) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item.medicineCd === cd) {
            mediUnit = item.unit;
            break;
          }
        }
      }
      return mediUnit;
    },

    addRecord() {
      const addRecord = {
        medicineMixCd: null,
        medicineMixName: null,
        medicineMixShortName: null,
        classCd: null,
        unit: null,
        amountUnit: null,
        amountMl: null,
        mixInfo: null,
        isShot: null,
        isMedicated: null,
        inHospitalCd1: null,
        inHospitalCd2: null,
        inHospitalCd3: null,
        medicateTimingCd: null,
        procedureCd: null,
        unitDecimalPoint: null,
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny start
        medicineSetNum: 1,
        unitSecond: null
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny end
      };
      return addRecord;
    },

    updateMixInfo() {
      let mixInfoList = this.editMixInfoList.filter(
        info => info.cd.editValue !== null
      );
      if (mixInfoList.length > 0) {
        // 1.画面表示用に文字列化していた数量を数値変換
        mixInfoList.map(item =>
          item.amount.editValue =
          // #10196 数値IFのスタイル全不正 linjunfeng start
          // isNaN(item.amount.editValue) || item.amount.editValue === null ? null: Number(item.amount.editValue)
          isNaN(item.amount.editValue) || item.amount.editValue === null ? null: item.amount.editValue
          // #10196 数値IFのスタイル全不正 linjunfeng end
        );
        // 2.不要な項目を削除しjson用にデコード
        mixInfoList = mixInfoList.map(item =>
          _.omit(decodeEditableRecord({ ...item }), "del_check","decPoint","id")
        );
      }
      const mixInfo = JSON.stringify(mixInfoList);
      this.editMstMedicineMixRecord.mixInfo.editValue = mixInfo;
      this.setEditRecord({ ...this.editRecord, mixInfo });
    },

    updateInfo(key, value) {
      this.setEditRecord({ ...this.editRecord, [key]: value });
      if (key === "classCd" && !this.isAnticoagulant) {
        // 抗凝固剤フラグ
        //add #9612 薬剤分類を切り替える場合は、分類無しを選択し、ml換算設定をクリアしません。zhangbo start
        // this.setEditRecord({ ...this.editRecord, amountUnit: null });
        // this.setEditRecord({ ...this.editRecord, amountMl: null });
        this.editMixRecord.amountUnit.editValue = null;
        this.editMixRecord.amountMl.editValue = null;
        //add #9612 薬剤分類を切り替える場合は、分類無しを選択し、ml換算設定をクリアしません。zhangbo end
      }
      if (key === "classCd" && this.classCd != value) {
        this.editRecord["classiFicationFlg"] = true;
      }
    },

    /**
     * @description 画面入力された小数部桁数の換算設定
     * @param 画面上に表示するml換算基準量の単位
     */
    getDecDigits(value){
      if(!value) return 0;

      let decPoint = value;
      decPoint = parseInt(decPoint);
      if(isNaN(decPoint)){
        decPoint = 0;
      }
      decPoint > 9 ? decPoint = 9 : decPoint < 0 ? decPoint = 0 : decPoint = Math.floor(decPoint);
      return decPoint;
    },

    /**
     * @description 薬剤コードを薬剤数量のステップ数に変換する処理
     * @param 画面上に表示する薬剤の単位
     */
    getMediUnitStep(data){
      //let unitStep = null;
      let decPoint = null;
      let mstData = this.mstMedicine;
      //薬剤マスタが取得出来ているなら変換を行う
      if (mstData.length > 0) {
        for (const item of mstData) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item.medicineCd === data.cd.editValue) {
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
     * @description 初期表示時に明細行小数点桁数を取得するための処理
     * @param cd 対象薬剤コード
     * @return 明細行小数点桁数（例：2ケタなど）
     */
    getMediUnitStepDefault(cd){
      let decPoint = null;
      const mstData = this.mstMedicine;
      //薬剤マスタが取得出来ているなら変換を行う
      if (mstData.length > 0) {
        for (const item of mstData) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item.medicineCd === cd) {
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
     * @description 明細行数量のステップ数を自動取得切り替えする処理
     * @param data 明細1行データ
     * @return 明細行ステップ数(例:0.1,0.01など)
     */
    getMediUnitStepSimple(data){
      let decPoint = null;
      const mstData = this.mstMedicine;
      //薬剤マスタが取得出来ているなら変換を行う
      if (mstData.length > 0) {
        for (const item of mstData) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item.medicineCd === data.cd.editValue) {
            decPoint = item.unitDecimalPoint;
            break;
          }
        }
      }
      decPoint = parseInt(decPoint);
      if(isNaN(decPoint)){
        decPoint = 0;
      }
      var step = BigNumber(10).exponentiatedBy(BigNumber(decPoint).negated()).valueOf();
      return Number(step);
    },

    /**
     * @description 明細行数量が入力時：指数制御処理
     * @param event 入力対象項目
     * @param decPoint 入力行小数点桁数(2ケタなど)
     */
    inputValueAmount(event,decPoint){
      if(this.pattern.test(event.target.value) && decPoint.editValue !== null && event.inputType === null){
          event.target.value = this.convertExponential(event.target.value, decPoint.editValue);
      }
    },

    /**
     * @description 明細行数量が変更された時：値セット処理
     * @param index 入力対象明細行番号
     * @param decPoint 入力行小数点桁数(2ケタなど)
     */
    changeValueAmount(index,decPoint){
      let convertValue = this.convertExponential(this.editMixInfoList[index].amount.editValue, decPoint.editValue);
      if(Number(convertValue) === Number(this.editMixInfoList[index].amount.editValue)){
        this.editMixInfoList[index].amount.editValue = convertValue;
      }
    },

    /**
     * @description 画面表示時：初期値の小数点桁数処理
     * @param amount 初期数量
     * @param decPoint 入力行小数点桁数(2ケタなど)
     */
    defaultValueAmount(amount,decPoint){
      let convertValue = this.convertExponential(amount, decPoint);
      if(Number(convertValue) === Number(amount)){
        return convertValue;
      }else{
        return amount;
      }
    },

    /**
     * @description 指数変換処理
     * @param num 数値
     * @param decPoint 入力行小数点桁数(2ケタなど)
     */
    convertExponential(num,decPoint){
      var decStep = 0;
      var setStep = 0;
      var setNum = 0;
      decStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint)).valueOf();
      setStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint).negated()).valueOf();
      num = BigNumber(num).multipliedBy(BigNumber(decStep)).valueOf();
      setNum = num >=0 ?  Math.floor(num):Math.ceil(num);
      var returnVal = BigNumber(setNum).multipliedBy(BigNumber(setStep)).valueOf();
      return BigNumber(returnVal).toFixed(decPoint);
    },

    /**
     * @description 小数点桁数取得処理
     * @param number 対象入力値
     * @return numberの小数部桁数
     */
    getDecimalPointLength(number) {
      var numbers = String(number).split('.');
      return (numbers[1]) ? numbers[1].length : 0;
    },

    /**
     * @description 確定ボタン押下時共通バリデーションチェックイベント
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true || v === "")) {
         this.updateMixInfo();
        return true;
      }
      // メッセージ組み立て
      const title = validationResult.validTitle;
      const message = `
          ${
            !validationResult.convertAmountValid ? validationResult.validMsg: ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },

    /**
     * @description バリデーションデータ確認
     * @return エラー項目フラグ及び出力メッセージ
     */
    validateData() {
      let validTitle = "";
      let validMsg= "";
      let isConvertPoint = true;
      // 1.調製情報入力桁数チェック
      for(const mixItem of this.editMixInfoList) {
        // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng start
        if (mixItem.amount && (mixItem.amount.editValue === "" || isNaN(mixItem.amount.editValue) || mixItem.amount.editValue == 0)) {
          isConvertPoint = false;
          validTitle = DIALOG_MESSAGES[13000170].title;
          validMsg = DIALOG_MESSAGES[13000170].message;
          break;
        }
        // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng end
        // del #9848+9849 数値IFのスタイル全不正 linjunfeng start
        // let checkInfo = this.getDecimalPointLength(mixItem.amount.editValue);
        // if(checkInfo > mixItem.decPoint.editValue){
        //   isConvertPoint = false;
        //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        //   // validTitle = "調製薬剤情報エラー";
        //   // validMsg = "薬剤:" + this.getMediName(mixItem.cd.editValue) +"<br>小数部桁数が薬剤マスタの設定範囲("+ mixItem.decPoint.editValue+"桁)を超えています。<br>";
        //   validTitle = DIALOG_MESSAGES[12000126].title;
        //   validMsg = messageFormat(DIALOG_MESSAGES[12000126].message, this.getMediName(mixItem.cd.editValue), mixItem.decPoint.editValue);
        //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        // }
        // del #9848+9849 数値IFのスタイル全不正 linjunfeng end
      }
      return {
        convertAmountValid:isConvertPoint,
        validTitle:validTitle,
        validMsg:validMsg
      };
    },
    /**
     * スクロール時に要素を調整する
     */
     scrollHandler() {
      const body = document.getElementsByClassName('modal-body')[0];
      const setInfoTable  = document.getElementsByClassName('sticky_table')[0];
      const setInfoThead  = document.getElementsByClassName('setInfo-thead')[0];
      const setInfoTitle  = document.getElementsByClassName('setInfo-title')[0];

      let targetTop = setInfoTable.getBoundingClientRect().top;
      let bodyTop = body.getBoundingClientRect().top;
      if (targetTop < bodyTop) {
        this.$refs.setInfoDummyItem.classList.remove('non-display');
        setInfoThead?.classList?.add('scroll');
        setInfoThead.style.left = setInfoTable.offsetLeft - body.scrollLeft + 'px';
        setInfoThead.style.width = setInfoTable.offsetWidth - 1 + 'px';
        setInfoThead.style.clip = `rect(0px, ${body.offsetLeft + body.offsetWidth - setInfoThead.offsetLeft}px, 500px, ${-setInfoThead.offsetLeft}px)`;

        setInfoTitle?.classList?.add('scroll');
        setInfoTitle.style.left = 6 - body.scrollLeft + 'px';
        const parentRect = body.getBoundingClientRect();
        setInfoTitle.style.clip = `rect(0px, 500px, 500px, ${-setInfoTitle.offsetLeft}px)`;
      } else {
        this.$refs.setInfoDummyItem?.classList?.add('non-display');
        setInfoThead.classList.remove('scroll');
        setInfoTitle.classList.remove('scroll');
      }
    },
    /**
     * 高さを計算する
     */
    calculateListHeight() {
      // モーダル内部の高さを取得
      const modalBody = document.getElementsByClassName("modal-body")[0];
      // #9863 TypeError: Cannot read properties of undefined (reading 'clientHeight') 横展開2 linjunfeng start
      // const modalBodyHeight = modalBody.clientHeight;
      const modalBodyHeight = modalBody && modalBody.clientHeight ? modalBody.clientHeight : 0;
      // #9863 TypeError: Cannot read properties of undefined (reading 'clientHeight') 横展開2 linjunfeng end
      // 付帯情報部分の高さを取得
      const infoWrapper = document.getElementsByClassName("medicine-mix-info")[0];
      // #9863 TypeError: Cannot read properties of undefined (reading 'clientHeight') 横展開2 linjunfeng start
      // const infoWrapperHeight = infoWrapper.clientHeight;
      const infoWrapperHeight = infoWrapper && infoWrapper.clientHeight ? infoWrapper.clientHeight : 0;
      // #9863 TypeError: Cannot read properties of undefined (reading 'clientHeight') 横展開2 linjunfeng end
      const remainHeight = modalBodyHeight - infoWrapperHeight - 14;
      // #9863 TypeError: Cannot read properties of undefined (reading 'style') 横展開2 linjunfeng start
      // document.getElementsByClassName("setInfo-list")[0].style.minHeight = remainHeight + "px";
      if (document.getElementsByClassName("setInfo-list")[0]) {
        document.getElementsByClassName("setInfo-list")[0].style.minHeight = remainHeight + "px";
      }
      // #9863 TypeError: Cannot read properties of undefined (reading 'style') 横展開2 linjunfeng end
    },

    // add #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 start
    /**
     * POP画面閉じる前にイベント処理を追加する
     */
    onCloseMasterEditModal() {
      const body = document.getElementsByClassName('modal-body')[0];
      // #9863 Error in event handler for "onCloseMasterEditModal": "TypeError: Cannot read properties of undefined (reading 'removeEventListener')" 横展開2 linjunfeng start
      // body.removeEventListener("scroll", this.scrollHandler);
      if (body) {
        body.removeEventListener("scroll", this.scrollHandler);
      }
      // #9863 Error in event handler for "onCloseMasterEditModal": "TypeError: Cannot read properties of undefined (reading 'removeEventListener')" 横展開2 linjunfeng end
    },
    // add #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 end
    getAmountUnitStep(decPoint) {
      var num = parseInt(decPoint);

      if(isNaN(num)){
        return 1;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    getAmountUnitMaxPrecision(decPoint, value) {
      let num = parseInt(decPoint);
      if(isNaN(num)){
        return value;
      }
      const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
      return Number(decimalNumber.toFixed(num));
    },
  },
  async mounted() {
    // 縦スクロールバー表示
    let modalObj = document.getElementsByClassName("modal-body");
    if (modalObj.length >= 1) {
      modalObj[0].classList.remove("modal-overflow-hidden");
      modalObj[0]?.classList?.add("modal-scroll");
    }

    // スクロール処理を追加する
    modalObj[0].addEventListener('scroll', this.scrollHandler);

    // add 4734 調製情報の余白の改修 鞠 start
    this.changeMedicineSet()
    // add 4734 調製情報の余白の改修 鞠 end
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);

    // del #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 start
    // 高さを計算する
    // this.$nextTick(() => {
    //   this.calculateListHeight();
    // });
    // del #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 end
  },
  beforeDestroy() {
    // スクロール処理を解除する
    // mod #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 start
    // let modalObj = document.getElementsByClassName('modal-body');
    // modalObj[0].removeEventListener("scroll", this.scrollHandler);
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    // mod #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 end
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto {
    height: auto !important;
  }
}
.setInfo-list {
  border: 1px solid;
}
table {
  border-collapse: collapse;
}
table th,
table td {
  /*border: solid 1px black;*/
}

.list-input {
  /* flex: 0 0 78%; */
}

.list-delete {
  width: 3em;
}

.list-class {
  width: 7em;
}

.list-name {
  min-width: 14em;
}

.list-num {
  width: 10em;
}

/* add #10713 小数点以下桁数指定を0～8までにする linjunfeng start */
.list-num-pro {
  width: 13em;
}
/* add #10713 小数点以下桁数指定を0～8までにする linjunfeng end */

.list-unit {
  width: 7em;
}

.item-button {
  width: 60px;
  padding: 0;
  margin-left: 2px;
  font-size: unset;
  /* add redmine 4555 小窓時のレイアウト不正 孔 start */
  margin-block: 2px;
  /* add redmine 4555 小窓時のレイアウト不正 孔 end */
}

.select-button {
  width: 50px;
  padding: 1px;
  margin: 2px 0 0 2px;
}

/* 項目名 */
.item-title {
  width: 15%;
  max-width: 15%;
  margin-left: 5px;
}
@media screen and (max-width: 1050px){
  .item-title {
    max-width: 9rem;
  }
}

/* 項目内容 */
/* modify by lijingnan 2022-11-04[5548]調整薬剤マスタのレイアウト不正 -- start */
.item-data {
  padding-bottom: 3px;
  padding-left: 3px;
  padding-right: 3px;
}
/* modify by lijingnan 2022-11-04[5548]調整薬剤マスタのレイアウト不正 -- end */

.custom-input-number {
  width: auto;
}
ons-input >>> .text-input {
  font-size: 100%;
}

/* 指定単位 */
.input-item-converted-label{
  max-width: 20%;
  min-width: 20%;
  word-wrap: break-word;
}

.custom-setInfo-list >>> .button{
  font-size: unset;
}

.ntss-list {
  position: unset;
}

.data-table {
  display: block;
  overflow-x: auto;
  white-space: nowrap;
}
.data-table >>> ons-row {
  min-width: 640px;
}

.setInfo-thead.scroll {
  top: 50px;
  position: fixed;
  z-index: 2;
  display: table;
}
.setInfo-title.scroll {
  top: 50px;
  position: fixed;
  z-index: 2;
}
.non-display{
  display: none !important;
}

.medicine_name {
  width: 70% !important;
  min-width: 14em;
}
/* @media screen and (max-width: 1080px) {
  .medicine_name {
    max-width: 140px;
  }
} */
/* 削除ボタン */
.button-delete {
  display: block;
  margin: auto;
}
</style>
