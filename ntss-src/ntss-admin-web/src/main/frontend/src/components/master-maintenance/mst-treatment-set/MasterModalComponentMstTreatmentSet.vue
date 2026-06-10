<template>
  <div class="main-area">
    <v-ons-button
      v-if="false"
      class="btn3-normal copy-btn"
      :disabled="'' === getEditRecord.name"
      @click="copyTreatmentSet()"
    >
      コピー
    </v-ons-button>

    <table class="disp-item-area custom-disp-item-area mst-treatment-set-area">
      <tr>
        <td height="30">
          セット名
        </td>
        <td>
          <input
            :value="getEditRecord.name"
            class="k-textbox input-required"
            @blur="setLayoutName($event.target.value)"
            @input="closeInvalidCss"
          />
        </td>
      </tr>
      <tr>
        <td>
          セット内容
        </td>
        <td>
          <div class="disp-item-content-area">
            <v-ons-row>
              <v-ons-col width="150px" class="cond-title-style cond-td-style">
                治療方法
              </v-ons-col>
              <v-ons-col class="cond-td-style">
                <v-ons-select
                  v-model="treatMethodCd"
                  class="k-textbox p-0"
                  name="mstModalTreatSetSelect"
                  @change="changeDown"
                >
                  <option
                    v-for="treat in treatMethod"
                    :key="treat.treatmentCd"
                    :value="treat.treatmentCd"
                  >
                    {{ treat.treatmentName }}
                  </option>
                </v-ons-select>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col width="150px" class="cond-title-style cond-td-style">
                治療条件
              </v-ons-col>
              <v-ons-col class="cond-td-style">
                <div v-for="treat in treatCond" :key="treat.id">
                  <div v-if="treat.isUse">
                    <!-- mod 10443 身体情報・DW・目標体重バグ 関 start -->
                    <!-- <component
                      :is="treat.component"
                      :ref="treat.treatCondNo"
                      :value="treat.value"
                      :is-mst="true"
                      :mstTreatmentSetDay="mstTreatmentSetDay"
                      :mstTreatmentSetDayDisplay = "mstTreatmentSetDayDisplay"
                      @mstTreatmentSetDay = 'changeMstTreatmentSetDay'
                      :medicine-type="treat.medicineType"
                      @input="editItem('cond', $event, treat.treatCondNo)"
                    /> -->
                    <component
                      :is="treat.component"
                      :ref="treat.treatCondNo"
                      :value="treat.value"
                      :is-mst="true"
                      :mstTreatmentSetDay="mstTreatmentSetDay"
                      :mstTreatmentSetDayDisplay = "mstTreatmentSetDayDisplay"
                      @mstTreatmentSetDay = 'changeMstTreatmentSetDay'
                      :medicine-type="treat.medicineType"
                      @input="editItem('cond', $event, treat.treatCondNo)"
                      v-show="treat.treatCondNo!=='3'"
                    />
                  </div>
                  <div v-else class="cond-disabled">
                    <!-- <component
                      :is="treat.component"
                      :ref="treat.treatCondNo"
                      :value="treat.value"
                      :is-mst="true"
                    /> -->
                    <component
                      :is="treat.component"
                      :ref="treat.treatCondNo"
                      :value="treat.value"
                      :is-mst="true"
                      v-show="treat.treatCondNo!=='3'"
                    />
                    <!-- mod 10443 身体情報・DW・目標体重バグ 関 end -->
                  </div>
                </div>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col width="150px" class="cond-title-style cond-td-style">
                <v-ons-col>薬剤セット</v-ons-col>
                <v-ons-col>
                  <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start  -->
                  <!-- <v-ons-button
                    ref="popoverButtonMedicineSet"
                    class="btn3-normal common-style-select-button"
                    @click="createPopoverDataMedicineSet(),changeButton()"
                  > -->
                  <v-ons-button
                    ref="popoverButtonMedicineSet"
                    class="btn3-normal common-style-select-button"
                    @click="createPopoverDataMedicineSet()"
                  >
                  <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end  -->
                    追加
                  </v-ons-button>
                </v-ons-col>
                <pop-over
                  v-bind="popoverDataMedicineSet"
                  :target-position-element="$refs.popoverButtonMedicineSet"
                  @popover-close="closePopoverMedicineSet"
                  @popover-return="updateInputMedicineSet"
                />
                <v-ons-col>薬剤</v-ons-col>
                <v-ons-col>
                  <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
                  <common-master-selector
                    :masterType="MasterType.ANTICOAGULANT_INDICATION"
                    :extraParams="{treatDate: '',rstInfo:{ rstName:'', rstUnit: ''}}"
                    :patientId="selectedPatId"
                    :facilityCd="facilityCd"
                    :btnName="'追加'"
                    :dialysisState="getDialysisState"
                    :isVisible="false"
                    :hasChangedOption="true"
                    :selectedItemClass="'com-basic-sub-input'"
                    :backgroundColor="'#f7f7f7'"
                    :btnClass="'com-basic-sub-btn'"
                    :btnDisabled="false"
                    :isSelectionRequired="true"
                    :hasUnregisteredOption="false"
                    @popover-return="masterUpdateInput($event);"
                  />
                  <!--<v-ons-button
                    ref="popoverButtonMedicine"
                    class="btn3-normal common-style-select-button"
                    @click="createPopoverDataMedicine(),changeButton()"
                  >
                    追加
                  </v-ons-button>-->
                </v-ons-col>
              </v-ons-col>
              <!--<pop-over
                v-bind="popoverDataMedicine"
                :target-position-element="$refs.popoverButtonMedicine"
                @popover-close="closePopoverMedicine"
                @popover-return="updateInputMedicine"
              />-->
              <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
              <transition-group
                name="cond-transition"
                class="cond-td-style"
                tag="ons-col"
              >
                <v-ons-row style="flex-wrap: nowrap;" v-for="(medi, index) in medicine" :key="medi.id">
                  <v-ons-col class="cond-td-style-child">
                    <!-- mod #10359 編集権限の動作不正 dengshen start -->
                    <!-- <ind-medicine-edit -->
                    <!--   :fields-data="medi" -->
                    <!--   :is-comment="true" -->
                    <!--   @input="editItem('medicine', $event, medi.id)" -->
                    <!-- /> -->
                    <ind-medicine-edit
                      :fields-data="medi"
                      :is-comment="true"
                      @input="editItem('medicine', $event, medi.id)"
                      :is-mst="true"
                    />
                    <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  </v-ons-col>
                  <v-ons-col class="cond-del-style">
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                    <!-- <button @click="deleteItem('medicine', index),changeButton()"> -->
                    <button class="ntss-btn-outset" @click="deleteItem('medicine', index)">
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                      <v-ons-icon icon="fa-trash" />
                    </button>
                  </v-ons-col>
                </v-ons-row>
              </transition-group>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col width="150px" class="cond-title-style cond-td-style">
                <v-ons-col>医療材料セット</v-ons-col>
                <v-ons-col>
                  <v-ons-button
                    ref="popoverButtonEquipmentSet"
                    class="btn3-normal common-style-select-button"
                    @click="createPopoverDataEquipmentSet()"
                  >
                    追加
                  </v-ons-button>
                </v-ons-col>
                <pop-over
                  v-bind="popoverDataEquipmentSet"
                  :target-position-element="$refs.popoverButtonEquipmentSet"
                  @popover-close="closePopoverEquipmentSet"
                  @popover-return="updateInputEquipmentSet"
                />
                <v-ons-col>医療材料</v-ons-col>
                <v-ons-col>
                  <v-ons-button
                    ref="popoverButtonEquipment"
                    class="btn3-normal common-style-select-button"
                    @click="createPopoverDataEquipment()"
                  >
                    追加
                  </v-ons-button>
                </v-ons-col>
                <!-- 医療材料選択ボタンポップオーバー(共通部品 医療材料選択(有効なマスタからの選択)) -->
                <pop-over v-bind="this.popoverDataValidEquipment"
                  :target-position-element="popoverTargetElement(buttonPosi)"
                  @popover-return="updateInputEquipment"
                  @popover-close="closePopoverEquipment"
                />
              </v-ons-col>
              <transition-group
                name="cond-transition"
                class="cond-td-style"
                tag="ons-col"
              >
                <v-ons-row v-for="(equip, equipIndex) in equipment" :key="equip.id">
                  <v-ons-col class="cond-td-style-child">
                    <v-ons-row class="row-style">
                      <v-ons-col class="action-condition-column">医療材料</v-ons-col>
                      <v-ons-col class="equipment-data-column" style="display: flex; padding-left: 10px;">
                        <custom-input
                          :value="{initValue: equip.cd, editValue: equip.cd}"
                          :display-string="
                            setInitialEquipmentInputValue(equip.cd, equip.equipType).name
                          "
                          disabled
                          propBackgroundColor="#ebebe4"
                          class="custom-div-show-selected-item"
                        />
                        <v-ons-button
                          style="margin-bottom: 5px;"
                          :ref="equip.id"
                          class="common-style-select-button button"
                          @click="selectEquipment( equip.id, equip.cd, equip.equipType)"
                        >
                          選択
                        </v-ons-button>
                      </v-ons-col>
                    </v-ons-row>

                    <v-ons-row class="row-style">
                      <v-ons-col class="action-condition-column">数量</v-ons-col>
                      <v-ons-col class="equipment-data-column" style="display: flex; padding-left: 10px;">
                        <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start  -->
                        <!-- <custom-input-number
                          :ref="equip.id"
                          :value="getEquipmentAmountString(equipIndex)"
                          :digits="4"
                          :min-value="1"
                          :max-value="9999"
                          @change="editEquipmentAmountValue('equipment', $event, equip.id)"
                          @wheel="changeDown()"
                          style="width: 50px"
                          class="amount-input-style common-style-input ntss-custom-input-cond"
                          @input="editItem('equipment', $event, equip.id)"
                        /> -->
                        <custom-input-number-pro
                          :ref="equip.id"
                          :value="equip.amount"
                          :step="1"
                          :min="0"
                          :max="9999"
                          :invalidArray="['0']"
                          :required="true"
                          style="width: 50px"
                          class="amount-input-style common-style-input ntss-custom-input-cond"
                          @handlerInput="editEquipmentAmountValue('equipment', $event, equip.id)"
                        />
                        <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end  -->
                        <!-- 医療材料の数量の単位 -->
                        <label class="equipment-unit">&nbsp;{{ setInitialEquipmentInputValue(equip.cd, equip.equipType).unit }}</label>
                      </v-ons-col>
                    </v-ons-row>
                  </v-ons-col>

                  <!-- 医療材料の削除アイコン -->
                  <v-ons-col class="cond-del-style">
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
                    <!-- <button @click="deleteItem('equipment', equipIndex),changeButton()"> -->
                    <button class="ntss-btn-outset" @click="deleteItem('equipment', equipIndex)">
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
                      <v-ons-icon icon="fa-trash" />
                    </button>
                  </v-ons-col>
                </v-ons-row>
              </transition-group>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col width="150px" class="cond-title-style cond-td-style">
                <v-ons-col>指示コメント</v-ons-col>
                <v-ons-col>
                  <!-- #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng start -->
                  <!-- <v-ons-button
                    class="btn3-normal common-style-select-button"
                    @click="addItem('comment'),changeButton()"
                  > -->
                  <v-ons-button
                    class="btn3-normal common-style-select-button"
                    @click="addItem('comment'),changeButton()"
                    :disabled="treatComment.length >= 99"
                  >
                  <!-- #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng end -->
                    追加
                  </v-ons-button>
                </v-ons-col>
              </v-ons-col>
              <transition-group
                name="cond-transition"
                class="cond-td-style"
                tag="ons-col"
              >
                <v-ons-row
                  v-if="treatComment.length && treatComment[0].no !== null"
                  style="flex-wrap: nowrap;"
                  v-for="(comment, index) in treatComment"
                  :key="comment.id"
                >
                  <v-ons-col class="cond-td-style-child">
                    <!-- mod #10359 編集権限の動作不正 dengshen start -->
                    <!-- <ind-comment-create -->
                    <!--   class="ind-comment-create" -->
                    <!--   :id="comment.id" -->
                    <!--   :comment-num="comment.no" -->
                    <!--   :props-comment-content="comment.content" -->
                    <!--   @input="editItem('comment', $event, comment.id)" -->
                    <!-- /> -->
                    <ind-comment-create
                      class="ind-comment-create"
                      :id="comment.id"
                      :comment-num="comment.no"
                      :props-comment-content="comment.content"
                      @input="editItem('comment', $event, comment.id)"
                      :is-mst="true"
                    />
                    <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  </v-ons-col>
                  <v-ons-col class="cond-del-style" style="margin-left: 0.5em;">
                    <button class="ntss-btn-outset" @click="deleteItem('comment', index)">
                      <v-ons-icon icon="fa-trash" />
                    </button>
                  </v-ons-col>
                </v-ons-row>
              </transition-group>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col width="150px" class="cond-title-style cond-td-style">
                <v-ons-col>装置設定</v-ons-col>
              </v-ons-col>
              <transition-group
                name="cond-transition"
                class="cond-td-style"
                tag="ons-col"
              >
              <!-- mod 治療方法セットマスタ 装置modeがI-HFDの場合、urfおよび血流制御 start-->
                <!-- <v-ons-row
                  v-for="device in deviceList"
                  :key="device.name"
                  @click="showSubModal(device, dataSourceType)"
                > -->
                <!--mod #7236-治療方法セットマスタのプログラムの動作不正 徐博 start-->
<!--                mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start-->
<!--                <v-ons-row-->
<!--                    v-for="device in deviceArr"-->
<!--                    :key="device.name"-->
<!--                    @click="showSubModalSpcl(device, dataSourceType)"-->
<!--                    :style="getDeviceListStyle(device)"-->
<!--                >-->
                <v-ons-row
                  v-for="device in deviceArr"
                  :key="device.name"
                  @click="showSubModalSpcl(device, dataSourceType)"
                  :style="[getDeviceListStyle(device), { padding: '10px' }]"
                  v-show="(device.type != DEVICE_TYPE_BVUFC && device.type != DEVICE_TYPE_DIA)
                  || device.type == DEVICE_TYPE_BVUFC && hasExtendBVUFCFuncPermiss
                  || device.type == DEVICE_TYPE_DIA && hasExtendDIAFuncPermiss"
                >
<!--                mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end-->
              <!-- mod 治療方法セットマスタ 装置modeがI-HFDの場合、urfおよび血流制御 end-->
                  <v-ons-col>{{ device.name }} {{ device.info }}</v-ons-col>
                <!--mod #7236-治療方法セットマスタのプログラムの動作不正 徐博 end-->
                </v-ons-row>
              </transition-group>
            </v-ons-row>
          </div>
        </td>
      </tr>
    </table>
  </div>
</template>

<script>

import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters, mapActions, mapMutations } from "vuex";
import { equipmentSet, medicine, medicineClass, medicineMix, medicineSet, treatment } from "@/functions/mst/MstGetters.js";
import _ from "underscore";
import IndMedicineEdit from "@/components/indication/IndMedicineEdit";


// [共通部品] UI関連
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
//#8484　医療材料選択IFのリスト不正　Start
// 共通部品 医療材料選択(有効なマスタからの選択)
import ValidEquipmentSelectMixin from "@/components/ValidEquipmentSelectMixin";
//#8484　医療材料選択IFのリスト不正　End
// 部材(医療材料・ダイアライザ)の医療材料区分 equipType に関する共通関数
import {
  encryptPersistentCodeToInternalCd,
  decryptDialyzerCdToPersistentCode,
  detectEquipTypeFromCode
} from "@/functions/EquipTypeFunctions";

import IndCommentCreate from "@/components/indication/IndCommentCreate";
import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
import {
  DATA_SOURCE_TYPE_MST_EDIT_RECORD,
  defaultMstDeviceInfo
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import { CODES } from "@/constants/TreatmentRecord.js";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import {
  mapDeviceSetInfoEditable,
  mapDeviceSetInfoOrigin
} from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions";
import { LIQUID_AMOUNT_TEXT,LIQUID_SPEED_TEXT } from "@/constants/PatViewerConstants.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import {EventBus} from "@/eventBus";

// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
import { deepCopy } from "@/functions/common/CommonFunctions";
// #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
// add #9848+9849 数値IFのスタイル全不正 linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
// add #9848+9849 数値IFのスタイル全不正 linjunfeng end
class Device {
  constructor(name, type) {
    this.name = name;
    this.type = type;
  }
}
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { Master } from "@/models/common/master-selector-condition/Master";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
export default {
  name: "MstTreatmentSet",
  components: {
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    "common-master-selector": commonMasterSelector,
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    "ind-medicine-edit": IndMedicineEdit,
    "ind-comment-create": IndCommentCreate,
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
  },
  mixins: [baseDeviceSetInfoList, ValidEquipmentSelectMixin],

  data() {
    return {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      MasterType,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      deviceArr: [],
      treatMethodCd: null,
      treatMethod: null,
      getEditRecordName:"",
      initTreatMethodCd:"",
      treatCond: [
        {
          id: _.uniqueId("cond"),
          treatCondNo: "1",
          component: () => import("@/components/indication/IndTreatCondTime"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "2",
          component: () => import("@/components/indication/IndTreatCondVa"),
          value: null,
          medicineType: null
        },
        // 治療方法セットマスタ DWを追加します 孔 start
        // {
        //   id: _.uniqueId("cond"),
        //   treatCondNo: "39",
        //   component: () =>
        //     import("@/components/indication/IndTreatCondDW"),
        //   value: null,
        //   medicineType: null
        // },
        // 治療方法セットマスタ DWを追加します 孔 end
        {
          id: _.uniqueId("cond"),
          treatCondNo: "3",
          component: () =>
            import("@/components/indication/IndTreatCondTargetWeight"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "4",
          component: () =>
            import("@/components/indication/IndTreatCondFilterLimit"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "5",
          component: () =>
            import("@/components/indication/IndTreatCondDialyzer"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "6",
          component: () =>
            import("@/components/indication/IndTreatCondSeparatoryColumn"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "7",
          component: () =>
            import("@/components/indication/IndTreatCondFirstPass"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "8",
          component: () =>
            import("@/components/indication/IndTreatCondSecondPass"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "12",
          component: () =>
            import("@/components/indication/IndTreatCondNeedleSelection"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "9",
          component: () =>
            import("@/components/indication/IndTreatCondNeedleA"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "10",
          component: () =>
            import("@/components/indication/IndTreatCondNeedleV"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "11",
          component: () =>
            import("@/components/indication/IndTreatCondNeedleSN"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "13",
          component: () => import("@/components/indication/IndTreatCondTube"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "14",
          component: () =>
            import("@/components/indication/IndTreatCondBloodFlowRate"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "15",
          component: () =>
            import("@/components/indication/IndTreatCondDialysate"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "16",
          component: () =>
            import("@/components/indication/IndTreatCondDialysateFlowRate"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "17",
          component: () =>
            import("@/components/indication/IndTreatCondDialysateAmount"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "18",
          component: () =>
            import("@/components/indication/IndTreatCondDialysateTemperature"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "19",
          component: () => import("@/components/indication/IndTreatCondIv"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "20",
          component: () =>
            import("@/components/indication/IndTreatCondIvAmount"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "21",
          component: () =>
            import("@/components/indication/IndTreatCondIvSelection"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "22",
          component: () =>
            import("@/components/indication/IndTreatCondIvCount"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "23",
          component: () =>
            import("@/components/indication/IndTreatCondIvTemperature"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "24",
          component: () =>
            import("@/components/indication/IndTreatCondIvFlowRate"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "25",
          component: () =>
            import("@/components/indication/IndTreatCondAntiCoagulant"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "26",
          component: () =>
            import(
              "@/components/indication/IndTreatCondAntiCoagulantOneshotAmount"
            ),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "27",
          component: () =>
            import("@/components/indication/IndTreatCondAntiCoagulantFlowRate"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "28",
          component: () =>
            import(
              "@/components/indication/IndTreatCondAntiCoagulantAmountTotal"
            ),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "29",
          component: () =>
            import("@/components/indication/IndTreatCondIpSelection"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "30",
          component: () =>
            import("@/components/indication/IndTreatCondIpStart"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "32",
          component: () =>
            import("@/components/indication/IndTreatCondIpFlowRate"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "33",
          component: () =>
            import("@/components/indication/IndTreatCondIpFlowRateLimit"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "34",
          component: () =>
            import("@/components/indication/IndTreatCondIpOneshotSelection"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "31",
          component: () =>
            import("@/components/indication/IndTreatCondIpOneshotAmount"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "35",
          component: () =>
            import("@/components/indication/IndTreatCondIpAutoOff"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "36",
          component: () =>
            import("@/components/indication/IndTreatCondIpAutoOffTiming"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "37",
          component: () =>
            import("@/components/indication/IndTreatCondIpMonitorOff"),
          value: null,
          medicineType: null
        },
        {
          id: _.uniqueId("cond"),
          treatCondNo: "38",
          component: () =>
            import("@/components/indication/IndTreatCondIpMonitorOffTiming"),
          value: null,
          medicineType: null
        }
      ],
      // add #10150 piao start
      oldTreatCond: null,
      // add #10150 piao end
      medicine: [
        {
          id: _.uniqueId("medicine"),
          cd: null,
          // 子へ渡すデータ※保存対象外
          unit: null,
          amount: null,
          timingCd: null,
          procedureCd: null,
          medicineType: null,
          // {comment} add redmine 4903 薬剤のコメントが存在しない 孔
          comment: ""
        }
      ],
      equipment: [
        {
          id: _.uniqueId("equipment"),
          cd: null,
          amount: null,
          equipType: null
        }
      ],
      //編集対象の医療材料
      buttonPosi: null,
      treatComment: [
        {
          id: _.uniqueId("comment"),
          no: null,
          content: null
        }
      ],
      mstTreatmentSetDay:0,
      mstTreatmentSetDayDisplay:false,
      /**
       * レコードデフォルトデータ
       */
      recordDefaultData: {},
      // データ取得元はマスタ
      dataSourceType: DATA_SOURCE_TYPE_MST_EDIT_RECORD,
      deviceList: [],
      /**
       * 薬剤セット選択吹き出し用データセット
       */
      popoverDataMedicineSet: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      /**
       * 薬剤選択吹き出し用データセット
       */
      popoverDataMedicine: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },
      medicineSetData: [],
      medicineData: [],
      medicineMixData: [],
      /**
       * 医療材料セット選択吹き出し用データセット
       */
      popoverDataEquipmentSet: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      /** 変更前の医療材料情報 */
      prevIndEquipInfo: null,
      equipmentSetData: [],
      isShowDeviceList: false,
      // mod 9664補液及び透析液仕様修正します yangqingzhe start
      // ivChangeDeviceModeList: [CODES.DEVICE_MODE.HD_HO.cd, CODES.DEVICE_MODE.ECUM_HO.cd, CODES.DEVICE_MODE.OHDF.cd, CODES.DEVICE_MODE.OHF.cd],
      ivChangeDeviceModeList: [CODES.DEVICE_MODE.HD_HO.cd, CODES.DEVICE_MODE.ECUM_HO.cd, CODES.DEVICE_MODE.OHDF.cd, CODES.DEVICE_MODE.OHF.cd,CODES.DEVICE_MODE.IHDF.cd],
      newIndTreatCondIvMode: "offLine",
      oldIndTreatCondIvMode: "offLine",
      // mod 9664補液及び透析液仕様修正します yangqingzhe end
      tempIndIndCommentInfo: null,
      tempIndDeviceSetInfo: null,
      tempTreatmentCd: null,
      tempIndCondInfo: null,
      tempIndMediInfo: "[]",
      tempIndEquipInfo: null,
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 start
      isEdit: false,
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 end

      /**
       * 医療材料 数量の表示.
       * @param {*} index 医療材料セット内の表示順番.
       */
      getEquipmentAmountString(index) {
        //コンポーネント生成前の状態で呼び出された場合はnull値を返却
        if (this.equipment[0].amount == null) {return {initValue: null, editValue: null }}
        let initialValue = 1;
        let equipment = this.equipment[index];
        if (!equipment.hasOwnProperty("amount")) {
          return {initValue: null, editValue: null };
        }
        let amount = Number.parseFloat(this.equipment[index].amount);
        if (amount !== NaN) {
          // add 9973 -4 by kangjie 20231102 start
          // initialValue = amount;
          initialValue = amount +"";
          // add 9973 -4 by kangjie 20231102 end
        }
        return {
              initValue: initialValue,
              editValue: initialValue
        }
      },
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
      treatMethodCount: 0,
      getEditRecordDefault: {},
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
    };
  },

  computed: {
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("master-maintenance", { facilityCd: "getFacilitySwitch" }),
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    ...mapGetters("master-maintenance", [
      "getColumns",
      "getEditRecord",
      "getMasterRecordList",
      "getFacilitySwitchAdvancedSettings"
    ]),
    ...mapGetters("user", ["getAdvancedSettings"]),
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    ...mapGetters("device-set-info-modal", [
      "getSelectedDeviceSetType",
      "getSelectedDeviceSetState"
    ]),
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    ...mapGetters("treatment-record/common", ["getDialysisState"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    treatCondSetting() {
      const setting = this.treatMethod.find(item => {
        return item.treatmentCd === this.treatMethodCd;
      });

      return setting ? JSON.parse(setting.treatmentConditionSetting) : null;
    },

    treatMethodDeviceMode() {
      if (!this.treatMethod) return null;
      const method = this.treatMethod.find(item => {
        return item.treatmentCd === this.treatMethodCd;
      });

      return method ? method.deviceMode : null;
    },

    isTreatmentName() {
      return this.getEditRecord.name !== null && this.getEditRecord.name !== "";
    },
    // add #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
    hasExtendBVUFCFuncPermiss() {
      //BV_UFC: 'A04'
      const isDispBvUfc = this.getFacilitySwitchAdvancedSettings.some(
          setting => setting === ADVANCED_SETTINGS.BV_UFC
      );
      return isDispBvUfc;
    },

    hasExtendDIAFuncPermiss() {
      //DIALYSIS_AMOUNT_PROGRAM: 'A02'
      const isDAProgram = this.getFacilitySwitchAdvancedSettings.some(
          setting => setting === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
      );
      return isDAProgram;
    },
    // add #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
  },

  watch: {
    // mod #10150 piao start
    //  treatMethodCd(data) {
    treatMethodCd(data, oldData) {
      this.oldTreatCond = deepCopy(this.treatCond);
      if(Number(this.selectTreatCondByTreatCondNo(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd).isUse) === 0){
        this.oldIndTreatCondIvMode = "noIv";
      } else if(this.ivChangeDeviceModeList.includes(this.getTreatMethodDeviceMode(oldData))){
        this.oldIndTreatCondIvMode = "onLine";
      } else {
        this.oldIndTreatCondIvMode = "offLine";
      }
    // mod #10150 piao end
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 start
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      // if (this.isEdit) {
      //   ApiHelper.get(`/deviceSetInfo/getDeviceSetInfoMst/${this.facilityCd}`).then((res) => {
      //     this.deviceArr = []
      //     let ufrInfo = ""
      //     if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.HD.cd ||
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.ECUM.cd ||
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.HDF.cd ||
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.HF.cd ||
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHDF.cd ||
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHF.cd
      //     ) {
      //       res.data.ord.ihdf.dev.A[432] = '0'
      //       //#9340  治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-05 卓 start
      //       this.setDeviceInfo(this.DEVICE_TYPE_IHDF, 432, "0")
      //       //#9340  治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-05 卓 end
      //     } else if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd) {
      //       res.data.ord.ihdf.dev.A[432] = '0'
      //       res.data.ord.dc.dev.A[340] = '0'
      //       res.data.ord.qbqd.dev.A[430] = '0'
      //       res.data.ord.qbqd.dev.A[431] = '0'
      //       res.data.ord.dia.dev.A[282] = '0'
      //       //#9340  治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-05 卓 start
      //       this.setDeviceInfo(this.DEVICE_TYPE_IHDF, 432, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_DC, 340, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 430, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 431, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_DIA, 282, "0")
      //       //#9340  治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-05 卓 end
      //     } else if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd) {
      //       res.data.ord.ihdf.dev.A[432] = '0'
      //       res.data.ord.ufr.dev.A[290] = '0'
      //       res.data.ord.dc.dev.A[340] = '0'
      //       res.data.ord.na.dev.A[315] = "0"
      //       res.data.ord.qbqd.dev.A[430] = '0'
      //       res.data.ord.qbqd.dev.A[431] = '0'
      //       res.data.ord.bvufc.dev.A[196] = '0'
      //
      //       //#9340  治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-05 卓 start
      //       this.setDeviceInfo(this.DEVICE_TYPE_IHDF, 432, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_UFR, 290, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_DC, 340, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_NA, 315, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 430, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 431, "0")
      //       this.setDeviceInfo(this.DEVICE_TYPE_BVUFC, 196, "0")
      //       //#9340  治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-05 卓 end
      //     }
      //     // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 start
      //     // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 start
      //     else if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd) {
      //       //res.data.ord.ihdf.dev.A[432] = '1'
      //       res.data.ord.bvufc.dev.A[196] = '0' // BV-UFC
      //       res.data.ord.dia.dev.A[290] = '0' // 除水
      //       res.data.ord.qbqd.dev.A[430] = '0' // QD
      //       res.data.ord.qbqd.dev.A[431] = '0' // QD
      //       //#9340 add 治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-13 卓 start
      //       // 除水プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //       this.setDeviceInfo(this.DEVICE_TYPE_UFR, 290, "0") //除水プログラム電源ＳＷ
      //       // BV-UFCを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //       this.setDeviceInfo(this.DEVICE_TYPE_BVUFC, 196, "0") //透析量プログラム使用選択
      //       // 血流量、透析液流量プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //       this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 430, "0") //QBプログラム電源
      //       this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 431, "0") //QDプログラム電源
      //       //#9340 add 治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-13 卓 end
      //     }
      //     // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 end
      //     // this.getEditRecord.indDeviceSetInfo = JSON.stringify(res.data.ord)
      //     // res.data.ord.ufr.dev.A[290] = '0'
      //     // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 end
      //     if (res.data.ord.ufr.dev.A[290] === "0" || res.data.ord.ufr.dev.A[290] == null) {
      //       ufrInfo = "（切り）"
      //     } else if (res.data.ord.ufr.dev.A[290] === "1") {
      //       ufrInfo = "（入り[ステップ]）"
      //     } else if (res.data.ord.ufr.dev.A[290] === "2") {
      //       ufrInfo = "（入り[コース]）"
      //     }
      //     let naInfo = ""
      //     if (res.data.ord.na.dev.A[315] === "0" || res.data.ord.na.dev.A[315] == null) {
      //       naInfo = "（切り）"
      //     } else if (res.data.ord.na.dev.A[315] === "1") {
      //       naInfo = "（入り[ステップ]）"
      //     } else if (res.data.ord.na.dev.A[315] === "2") {
      //       naInfo = "（入り[コース]）"
      //     }
      //     let dcInfo = ""
      //     if (res.data.ord.dc.dev.A[340] === "0" || res.data.ord.dc.dev.A[340] == null) {
      //       dcInfo = "（切り）"
      //     } else if (res.data.ord.dc.dev.A[340] === "2") {
      //       dcInfo = "（入り[ステップ]）"
      //     } else if (res.data.ord.dc.dev.A[340] === "3") {
      //       dcInfo = "（入り[コース]）"
      //     }
      //     let qbqdInfo = "（「Qdプログラム："
      //     if (res.data.ord.qbqd.dev.A[430] === "0" || res.data.ord.qbqd.dev.A[430] == null) {
      //       qbqdInfo += "切」「Qbプログラム："
      //     } else if (res.data.ord.qbqd.dev.A[430] === "1") {
      //       qbqdInfo += "入」「Qbプログラム："
      //     }
      //     if (res.data.ord.qbqd.dev.A[431] === "0" || res.data.ord.qbqd.dev.A[431] == null) {
      //       qbqdInfo += "切」）"
      //     } else if (res.data.ord.qbqd.dev.A[431] === "1") {
      //       qbqdInfo += "入」）"
      //     }
      //     this.deviceArr.push(
      //       {
      //         name: "I-HDF",
      //         type: this.DEVICE_TYPE_IHDF,
      //         info: (res.data.ord.ihdf.dev.A[432] === "1") ? "（使用する）" : "（使用しない）"
      //       }
      //     )
      //     // mod #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 start
      //     // this.deviceArr.push(
      //     //   {
      //     //     name: "除水プログラム",
      //     //     type: this.DEVICE_TYPE_UFR,
      //     //     info: ufrInfo
      //     //   }
      //     // )
      //     if (this.treatMethodDeviceMode === 10) {
      //       this.deviceArr.push(
      //         {
      //           name: "除水プログラム",
      //           type: this.DEVICE_TYPE_UFR,
      //           info: "（切り）"
      //         }
      //       )
      //     } else {
      //       this.deviceArr.push(
      //         {
      //           name: "除水プログラム",
      //           type: this.DEVICE_TYPE_UFR,
      //           info: ufrInfo
      //         }
      //       )
      //     }
      //     // mod #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 end
      //     this.deviceArr.push(
      //       {
      //         name: "Na注入プログラム",
      //         type: this.DEVICE_TYPE_NA,
      //         info: naInfo
      //       }
      //     )
      //     this.deviceArr.push(
      //       {
      //         name: "透析液濃度プログラム",
      //         type: this.DEVICE_TYPE_DC,
      //         info: dcInfo
      //       }
      //     )
      //     this.deviceArr.push(
      //       {
      //         name: "血流量・透析液流量プログラム",
      //         type: this.DEVICE_TYPE_QBQD,
      //         info: qbqdInfo
      //       }
      //     )
      //     this.deviceArr.push(
      //       {
      //         name: "BV-UFC",
      //         type: this.DEVICE_TYPE_BVUFC,
      //         info: (res.data.ord.bvufc.dev.A[196] === "1") ? "（使用する）" : "（使用しない）"
      //       }
      //     )
      //     this.deviceArr.push(
      //       {
      //         name: "透析量プログラム",
      //         type: this.DEVICE_TYPE_DIA,
      //         info: (res.data.ord.dia.dev.A[282] === "1") ? "（使用する）" : "（使用しない）"
      //       }
      //     )
      //   })
      // }
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 end
      const befData = this.getEditRecord.treatmentCd;
      this.setTreatmentCd(data);
      this.setDeviceMode(this.treatMethodDeviceMode);
      // 治療方法による治療条件設定の可否チェック
      _.each(this.treatCond, (value) => {
        const settingItems = this.treatCondSetting
          ? _.flatten(
              this.treatCondSetting.map(item => {
                return item.items;
              })
            )
          : null;
        const setting = settingItems
          ? settingItems.find(item => {
              return item.ctl_no === value.treatCondNo;
            })
          : null;
        const isUse = setting ? Number(setting.is_use) : 1;

        this.$set(this.treatCond.find(cond => cond.treatCondNo === value.treatCondNo), "isUse", isUse);

        if (!isUse) {
          this.$set(this.treatCond.find(cond => cond.treatCondNo === value.treatCondNo), "value", null);
        }
        // add 10739 by shiyw 20250303 start
        else if (value.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.TARGET_WEIGHT.cd) {
          this.$set(this.treatCond.find(cond => cond.treatCondNo === value.treatCondNo), "value", "-1");
        }
        // add 10739 by shiyw 20250303 end
      });

      /* add 治療時間制限 start*/
      let MChar = this.treatCond.filter(cond => cond.treatCondNo === '1')[0].value;
      // 特殊净化
      if (this.treatMethodDeviceMode === 9) {
        this.mstTreatmentSetDayDisplay = true;
        this.mstTreatmentSetDay =0;
      } else {
        MChar = Number(MChar%1440);
        if(this.treatMethodDeviceMode !== -1){
          MChar = this.changeConTreatTime(MChar);
        }
        this.$set(this.treatCond.find(cond => cond.treatCondNo === '1'), "value", MChar);
        this.mstTreatmentSetDayDisplay = false;
        this.mstTreatmentSetDay = 0;
      }
      /* add 治療時間制限 end*/
      //add #10150 piao start
      if(Number(this.selectTreatCondByTreatCondNo(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd).isUse) === 0){
        this.newIndTreatCondIvMode = "noIv"
      } else if(this.ivChangeDeviceModeList.includes(this.treatMethodDeviceMode)){
        this.newIndTreatCondIvMode = "onLine"
      } else {
        this.newIndTreatCondIvMode = "offLine"
      }
      if(this.newIndTreatCondIvMode === this.oldIndTreatCondIvMode){
        // なにもしない
      }else{
        if(this.newIndTreatCondIvMode === "onLine"){
          // 治療方法にOHDF、OHF、HD+補液、ECUM+補液が選択されている場合は、補液情報を透析液情報で上書きする
          //this.$set(this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd), "medicineType", this.selectTreatCondByTreatCondNo(CODES.TREATMENT_CONDITION_ITEM.DIALYSATE.cd).medicineType);
          this.$set(this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd), "medicineType",
            this.selectTreatCondByTreatCondNo(CODES.TREATMENT_CONDITION_ITEM.DIALYSATE.cd).medicineType != null ?
              Number(this.selectTreatCondByTreatCondNo(CODES.TREATMENT_CONDITION_ITEM.DIALYSATE.cd).medicineType) : null);
          //mod 9306  ljx start
          //this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd, data);
          this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd,
            this.selectTreatCondByTreatCondNo(CODES.TREATMENT_CONDITION_ITEM.DIALYSATE.cd).value);
          //mod 9306  ljx end
        }
        if(this.newIndTreatCondIvMode === "offLine" && this.oldIndTreatCondIvMode === "onLine"){
          // 補液情報をクリア
          this.$set(this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd), "medicineType", null);
          this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd, null);
        }
        if(this.oldIndTreatCondIvMode === "noIv"){
          this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_AMOUNT.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_AMOUNT.cd));
          this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TIMING.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TIMING.cd));
          this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_USE_COUNT.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_USE_COUNT.cd));
          this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TEMPERATURE.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TEMPERATURE.cd));
          this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_SPEED.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_SPEED.cd));
        }
      }
      // noUseからuseへ変更時、初期値を設定する。
      _.each(this.oldTreatCond, (item) => {
        if(item.isUse === 0){
          let cond = this.treatCond.find(cond => cond.treatCondNo === item.treatCondNo);
          if(cond.isUse === 1){
            if(cond.value === null
              && cond.treatCondNo !== CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd
              && cond.treatCondNo !== CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_AMOUNT.cd
              && cond.treatCondNo !== CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TIMING.cd
              && cond.treatCondNo !== CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_USE_COUNT.cd
              && cond.treatCondNo !== CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TEMPERATURE.cd
              && cond.treatCondNo !== CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_SPEED.cd){
              this.setTreatCondValue(cond.treatCondNo, this.getTreatCondDefaultValue(cond.treatCondNo));
            }
          }
        }
      });
      //add #10150 piao end

      // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 start
      // 除水プログラムのHD/ECUMの切替をHDに強制変更して非活性。
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      // if (
      //   this.treatMethodDeviceMode &&
      //   (
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.HDF.cd || this.treatMethodDeviceMode === CODES.DEVICE_MODE.HF.cd || //HDF・HF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHDF.cd || this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHF.cd || //OHDF・OHF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd || //AFBF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd //I-HDF
      //   )
      // ) {
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 291, "0") //治療モード1
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 292, "0") //治療モード2
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 293, "0") //治療モード3
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 294, "0") //治療モード4
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 295, "0") //治療モード5
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 296, "0") //治療モード6
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 297, "0") //治療モード7
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 298, "0") //治療モード8
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 299, "0") //治療モード9
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 300, "0") //治療モード10
      // }
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end

      //#9340 rm 治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-13 卓 start
      // // 除水プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      // if ( this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd ) { //I-HDF
      //   this.setDeviceInfo(this.DEVICE_TYPE_UFR, 290, "0") //除水プログラム電源ＳＷ
      // }

      // BV-UFCを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      // if ( this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd ) { //I-HDF
      //   this.setDeviceInfo(this.DEVICE_TYPE_BVUFC, 196, "0") //透析量プログラム使用選択
      // }
      //#9340  rm 治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-13 卓 end

      // 透析量プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      // if (
      //   this.treatMethodDeviceMode &&
      //   (
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.HDF.cd || this.treatMethodDeviceMode === CODES.DEVICE_MODE.HF.cd || //HDF・HF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHDF.cd || this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHF.cd || //OHDF・OHF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd || //AFBF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd || //I-HDF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd //特殊浄化
      //   )
      // ) {
      //   this.setDeviceInfo(this.DEVICE_TYPE_DIA, 282, "0") //透析量プログラム使用選択
      // }
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end

      //#9340 rm 治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-13 卓 start
      // // 透析液濃度プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      // if (this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd) { //AFBF
      //   this.setDeviceInfo(this.DEVICE_TYPE_DC, 340, "0") //濃度プログラム電源ＳＷ
      // }
      //
      // // 血流量、透析液流量プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      // if (this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd) { //I-HDF
      //   this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 430, "0") //QBプログラム電源
      //   this.setDeviceInfo(this.DEVICE_TYPE_QBQD, 431, "0") //QDプログラム電源
      // }
      //#9340 rm 治療方法セットマスタの新規登録時の装置プログラムのデフォルトが不正。保存前後の内容が異なる。2023-09-13 卓 end
      // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 end
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 start
      // del 9306 ljx start
      // if (this.treatMethodDeviceMode && (this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHDF.cd || this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHF.cd)) {
      //   const IndTreatCondDialysate = this.treatCond.find(item => item.treatCondNo === '15')
      //   if (IndTreatCondDialysate !== undefined || IndTreatCondDialysate !== null) {
      //     if (IndTreatCondDialysate.value === null || IndTreatCondDialysate.value === '') {
      //       this.$set(this.treatCond[18], 'value', 0)
      //     }
      //   }
      // }
      // del 9306 ljx end
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 end
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 start
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      // this.isEdit = true
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
      // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 end
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
    getEditRecord :{
      handler(newVal) {
        if (this.compareObjects(this.getEditRecordDefault, newVal)) {
          EventBus.$emit("mstHolidayRegistered", true);
        }else{
          this.changeButton();
        }
      },
      deep: true
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
    treatCond: {
      handler(data) {
        this.setIndCondInfo(data);
      },
      deep: true
    },

    medicine(data) {
      this.setIndMediInfo(data);
    },

    equipment(data) {
      this.setIndEquipInfo(data);
    },

    treatComment(data) {
      this.setIndCommentInfo(data);
    },
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    getSelectedDeviceSetState (data) {
      // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc start
      // mod #9340_#10246 装置プログラムの並び順追を修正する 20240708 ztc start
      if (!!data) {
        if (this.getSelectedDeviceSetType === 'ufr') {
          if (data === '0' || data === null) {
            // this.$set(this.deviceArr, 1, { name: '除水プログラム', type: this.DEVICE_TYPE_UFR, info: '（切り）' })
            this.$set(this.deviceArr, 0, { name: '除水プログラム', type: this.DEVICE_TYPE_UFR, info: '（切り）' })
          } else if (data === '1') {
            // this.$set(this.deviceArr, 1, { name: '除水プログラム', type: this.DEVICE_TYPE_UFR, info: '（入り[ステップ]）' })
            this.$set(this.deviceArr, 0, { name: '除水プログラム', type: this.DEVICE_TYPE_UFR, info: '（入り[ステップ]）' })
          } else if (data === '2') {
            // this.$set(this.deviceArr, 1, { name: '除水プログラム', type: this.DEVICE_TYPE_UFR, info: '（入り[コース]）' })
            this.$set(this.deviceArr, 0, { name: '除水プログラム', type: this.DEVICE_TYPE_UFR, info: '（入り[コース]）' })
          }
        } else if (this.getSelectedDeviceSetType === 'na') {
          if (data === '0' || data === null) {
            // this.$set(this.deviceArr, 2, { name: 'Na注入プログラム', type: this.DEVICE_TYPE_NA, info: '（切り）' })
            this.$set(this.deviceArr, 1, { name: 'Na注入プログラム', type: this.DEVICE_TYPE_NA, info: '（切り）' })
          } else if (data === '1') {
            // this.$set(this.deviceArr, 2, { name: 'Na注入プログラム', type: this.DEVICE_TYPE_NA, info: '（入り[ステップ]）' })
            this.$set(this.deviceArr, 1, { name: 'Na注入プログラム', type: this.DEVICE_TYPE_NA, info: '（入り[ステップ]）' })
          } else if (data === '2') {
            // this.$set(this.deviceArr, 2, { name: 'Na注入プログラム', type: this.DEVICE_TYPE_NA, info: '（入り[コース]）' })
            this.$set(this.deviceArr, 1, { name: 'Na注入プログラム', type: this.DEVICE_TYPE_NA, info: '（入り[コース]）' })
          }
        } else if (this.getSelectedDeviceSetType === 'dc') {
          if (data === '0' || data === null) {
            // this.$set(this.deviceArr, 3, { name: '透析液濃度プログラム', type: this.DEVICE_TYPE_DC, info: '（切り）' })
            this.$set(this.deviceArr, 2, { name: '透析液濃度プログラム', type: this.DEVICE_TYPE_DC, info: '（切り）' })
          } else if (data === '2') {
            // this.$set(this.deviceArr, 3, { name: '透析液濃度プログラム', type: this.DEVICE_TYPE_DC, info: '（入り[ステップ]）' })
            this.$set(this.deviceArr, 2, { name: '透析液濃度プログラム', type: this.DEVICE_TYPE_DC, info: '（入り[ステップ]）' })
          } else if (data === '3') {
            // this.$set(this.deviceArr, 3, { name: '透析液濃度プログラム', type: this.DEVICE_TYPE_DC, info: '（入り[コース]）' })
            this.$set(this.deviceArr, 2, { name: '透析液濃度プログラム', type: this.DEVICE_TYPE_DC, info: '（入り[コース]）' })
          }
        } else if (this.getSelectedDeviceSetType === 'qbqd') {
          let qbqdInfo = "（「Qdプログラム："
          if (data[431] === '0' || data[431] === null) {
            qbqdInfo += "切」「Qbプログラム："
          } else if (data[431] === '1') {
            qbqdInfo += "入」「Qbプログラム："
          }
          if (data[430] === '0' || data[430] === null) {
            qbqdInfo += "切」）"
          } else if (data[430] === '1') {
            qbqdInfo += "入」）"
          }
          // this.$set(this.deviceArr, 4, { name: '血流量・透析液流量プログラム', type: this.DEVICE_TYPE_QBQD, info: qbqdInfo })
          this.$set(this.deviceArr, 3, { name: '血流量・透析液流量プログラム', type: this.DEVICE_TYPE_QBQD, info: qbqdInfo })
        } else if (this.getSelectedDeviceSetType === 'bvufc') {
          const msg = data === '1' ? '（使用する）' : '（使用しない）'
          this.$set(this.deviceArr, 5, { name: 'BV-UFC', type: this.DEVICE_TYPE_BVUFC, info: msg })
        } else if (this.getSelectedDeviceSetType === 'dia') {
          const msg = data === '1' ? '（使用する）' : '（使用しない）'
          this.$set(this.deviceArr, 6, { name: '透析量プログラム', type: this.DEVICE_TYPE_DIA, info: msg })
        } else if (this.getSelectedDeviceSetType === 'ihdf') {
          // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
          // const msg = data === '1' ? '（使用する）' : '（使用しない）'
          const msg = data === '1' ? '（I-HDFプログラム使用する）' : ' （I-HDFプログラム使用しない）'
          // this.$set(this.deviceArr, 0, { name: 'I-HDF', type: this.DEVICE_TYPE_IHDF, info: msg })
          // this.$set(this.deviceArr, 0, { name: 'I-HDF設定', type: this.DEVICE_TYPE_IHDF, info: msg })
          this.$set(this.deviceArr, 4, { name: 'I-HDF設定', type: this.DEVICE_TYPE_IHDF, info: msg })
          // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
        }
        // mod #9340_#10246 装置プログラムの並び順追を修正する 20240708 ztc end
        // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc end
      }
    },
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
  },

  async created() {
    // add FNSI-8003 劉全航 start
    this.getMstMedicine({ facilityCd: this.facilityCd });
    // add 8681 ljx start
    this.getMstMedicineMix({ facilityCd: this.facilityCd });
    // add 8681 ljx end
    this.getEditRecordName = this.getEditRecord.name;
     //7155 -----ljg   end
    // del マスタ一覧 1･施設切替を可能とする 孔s start
    // if(!this.getAdvancedSettings.func_advcds) {
    //   this.getAdvancedSettings.func_advcds = [];
    // }
    // del マスタ一覧 1･施設切替を可能とする 孔s end
    // mod #7236-治療方法セットマスタのプログラムの動作不正 徐博 start
    // this.deviceList = [
    //   new Device("I-HDF", this.DEVICE_TYPE_IHDF),
    //   // mod FNSI-UFRプログラムの修正 楊 start
    //   // new Device("UFRプログラム", this.DEVICE_TYPE_UFR),
    //   new Device("除水プログラム", this.DEVICE_TYPE_UFR),
    //   // mod FNSI-UFRプログラムの修正 楊 end
    //   new Device("Na注入プログラム", this.DEVICE_TYPE_NA),
    //   new Device("透析液濃度プログラム", this.DEVICE_TYPE_DC),
    //   // new Device("I-HDF", this.DEVICE_TYPE_IHDF)
    // ];
    // this.deviceList.push(new Device("血流量・透析液流量プログラム", this.DEVICE_TYPE_QBQD));

    if (this.getEditRecord.indDeviceSetInfo == null || this.getEditRecord.indDeviceSetInfo == "") {
      ApiHelper.get(`/deviceSetInfo/getDeviceSetInfoMst/${this.facilityCd}`).then((res) => {
        let ufrInfo = ""
        // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 start
        this.getEditRecord.indDeviceSetInfo = JSON.stringify(res.data.ord)
        // res.data.ord.ufr.dev.A[290] = '0'
        // add #7236/#7762 【デグレ】治療方法セットマスタのプログラムの動作不正 付 end
        if (res.data.ord.ufr.dev.A[290] === "0" || res.data.ord.ufr.dev.A[290] == null) {
          ufrInfo = "（切り）"
        } else if (res.data.ord.ufr.dev.A[290] === "1") {
          ufrInfo = "（入り[ステップ]）"
        } else if (res.data.ord.ufr.dev.A[290] === "2") {
          ufrInfo = "（入り[コース]）"
        }
        let naInfo = ""
        if (res.data.ord.na.dev.A[315] === "0" || res.data.ord.na.dev.A[315] == null) {
          naInfo = "（切り）"
        } else if (res.data.ord.na.dev.A[315] === "1") {
          naInfo = "（入り[ステップ]）"
        } else if (res.data.ord.na.dev.A[315] === "2") {
          naInfo = "（入り[コース]）"
        }
        let dcInfo = ""
        if (res.data.ord.dc.dev.A[340] === "0" || res.data.ord.dc.dev.A[340] == null) {
          dcInfo = "（切り）"
        } else if (res.data.ord.dc.dev.A[340] === "2") {
          dcInfo = "（入り[ステップ]）"
        } else if (res.data.ord.dc.dev.A[340] === "3") {
          dcInfo = "（入り[コース]）"
        }
        let qbqdInfo = "（「Qdプログラム："
        if (res.data.ord.qbqd.dev.A[430] === "0" || res.data.ord.qbqd.dev.A[430] == null) {
          qbqdInfo += "切」「Qbプログラム："
        } else if (res.data.ord.qbqd.dev.A[430] === "1") {
          qbqdInfo += "入」「Qbプログラム："
        }
        if (res.data.ord.qbqd.dev.A[431] === "0" || res.data.ord.qbqd.dev.A[431] == null) {
          qbqdInfo += "切」）"
        } else if (res.data.ord.qbqd.dev.A[431] === "1") {
          qbqdInfo += "入」）"
        }
        // mod #9340_#10246 装置プログラムの並び順追を修正する 20240708 ztc start
        // this.deviceArr.push(
        //     {
        //       // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
        //       // name: "I-HDF",
        //       name: "I-HDF設定",
        //       type: this.DEVICE_TYPE_IHDF,
        //       // info: (res.data.ord.ihdf.dev.A[432] === "1") ? "（使用する）" : "（使用しない）"
        //       info: (res.data.ord.ihdf.dev.A[432] === "1") ? "（I-HDFプログラム使用する）" : "（I-HDFプログラム使用しない）"
        //       // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
        //     }
        // )
        this.deviceArr.push(
          {
            name: "除水プログラム",
            type: this.DEVICE_TYPE_UFR,
            info: ufrInfo
          }
        )
        this.deviceArr.push(
          {
            name: "Na注入プログラム",
            type: this.DEVICE_TYPE_NA,
            info: naInfo
          }
        )
        this.deviceArr.push(
          {
            name: "透析液濃度プログラム",
            type: this.DEVICE_TYPE_DC,
            info: dcInfo
          }
        )
        this.deviceArr.push(
          {
            name: "血流量・透析液流量プログラム",
            type: this.DEVICE_TYPE_QBQD,
            info: qbqdInfo
          }
        )
        this.deviceArr.push(
            {
              // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
              // name: "I-HDF",
              name: "I-HDF設定",
              type: this.DEVICE_TYPE_IHDF,
              // info: (res.data.ord.ihdf.dev.A[432] === "1") ? "（使用する）" : "（使用しない）"
              info: (res.data.ord.ihdf.dev.A[432] === "1") ? "（I-HDFプログラム使用する）" : "（I-HDFプログラム使用しない）"
              // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            }
        )
        // mod #9340_#10246 装置プログラムの並び順追を修正する 20240708 ztc end
        this.deviceArr.push(
          {
            name: "BV-UFC",
            type: this.DEVICE_TYPE_BVUFC,
            info: (res.data.ord.bvufc.dev.A[196] === "1") ? "（使用する）" : "（使用しない）"
          }
        )
        this.deviceArr.push(
          {
            name: "透析量プログラム",
            type: this.DEVICE_TYPE_DIA,
            info: (res.data.ord.dia.dev.A[282] === "1") ? "（使用する）" : "（使用しない）"
          }
        )
      })
    } else {
      const Arr = JSON.parse(this.getEditRecord.indDeviceSetInfo)
      let ufrInfo = ""
      if (Arr.ufr.dev.A[290] === "0" || Arr.ufr.dev.A[290] == null) {
        ufrInfo = "（切り）"
      } else if (Arr.ufr.dev.A[290] === "1") {
        ufrInfo = "（入り[ステップ]）"
      } else if (Arr.ufr.dev.A[290] === "2") {
        ufrInfo = "（入り[コース]）"
      }
      let naInfo = ""
      if (Arr.na.dev.A[315] === "0" || Arr.na.dev.A[315] == null) {
        naInfo = "（切り）"
      } else if (Arr.na.dev.A[315] === "1") {
        naInfo = "（入り[ステップ]）"
      } else if (Arr.na.dev.A[315] === "2") {
        naInfo = "（入り[コース]）"
      }
      let dcInfo = ""
      if (Arr.dc.dev.A[340] === "0" || Arr.dc.dev.A[340] == null) {
        dcInfo = "（切り）"
      } else if (Arr.dc.dev.A[340] === "2") {
        dcInfo = "（入り[ステップ]）"
      } else if (Arr.dc.dev.A[340] === "3") {
        dcInfo = "（入り[コース]）"
      }
      let qbqdInfo = "（「Qdプログラム："
      if (Arr.qbqd.dev.A[431] === "0" || Arr.qbqd.dev.A[431] == null) {
        qbqdInfo += "切」「Qbプログラム："
      } else if (Arr.qbqd.dev.A[431] === "1") {
        qbqdInfo += "入」「Qbプログラム："
      }
      if (Arr.qbqd.dev.A[430] === "0" || Arr.qbqd.dev.A[430] == null) {
        qbqdInfo += "切」）"
      } else if (Arr.qbqd.dev.A[430] === "1") {
        qbqdInfo += "入」）"
      }
      // mod #9340_#10246 装置プログラムの並び順追を修正する 20240708 ztc start
      // this.deviceArr.push(
      //     {
      //       // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      //       // name: "I-HDF",
      //       name: "I-HDF設定",
      //       type: this.DEVICE_TYPE_IHDF,
      //       // info: (Arr.ihdf.dev.A[432] === "1") ? "（使用する）" : "（使用しない）"
      //       info: (Arr.ihdf.dev.A[432] === "1") ? "（I-HDFプログラム使用する）" : "（I-HDFプログラム使用しない）"
      //       // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
      //     }
      // )
      this.deviceArr.push(
        {
          name: "除水プログラム",
          type: this.DEVICE_TYPE_UFR,
          info: ufrInfo
        }
      )
      this.deviceArr.push(
        {
          name: "Na注入プログラム",
          type: this.DEVICE_TYPE_NA,
          info: naInfo
        }
      )
      this.deviceArr.push(
        {
          name: "透析液濃度プログラム",
          type: this.DEVICE_TYPE_DC,
          info: dcInfo
        }
      )
      this.deviceArr.push(
        {
          name: "血流量・透析液流量プログラム",
          type: this.DEVICE_TYPE_QBQD,
          info: qbqdInfo
        }
      )
      this.deviceArr.push(
          {
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            // name: "I-HDF",
            name: "I-HDF設定",
            type: this.DEVICE_TYPE_IHDF,
            // info: (Arr.ihdf.dev.A[432] === "1") ? "（使用する）" : "（使用しない）"
            info: (Arr.ihdf.dev.A[432] === "1") ? "（I-HDFプログラム使用する）" : "（I-HDFプログラム使用しない）"
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
          }
      )
      // mod #9340_#10246 装置プログラムの並び順追を修正する 20240708 ztc end
      this.deviceArr.push(
        {
          name: "BV-UFC",
          type: this.DEVICE_TYPE_BVUFC,
          info: (Arr.bvufc.dev.A[196] === "1") ? "（使用する）" : "（使用しない）"
        }
      )
      this.deviceArr.push(
        {
          name: "透析量プログラム",
          type: this.DEVICE_TYPE_DIA,
          info: (Arr.dia.dev.A[282] === "1") ? "（使用する）" : "（使用しない）"
        }
      )
    }
    // mod #7236-治療方法セットマスタのプログラムの動作不正 徐博 end
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // const isDispBvUfc = this.getAdvancedSettings.func_advcds.some(
    //   setting => setting.func_advcd === ADVANCED_SETTINGS.BV_UFC
    // );
    // const isDAProgram = this.getAdvancedSettings.func_advcds.some(
    //   setting =>
    //     setting.func_advcd === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
    // );
    // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
    // const isDispBvUfc = this.getFacilitySwitchAdvancedSettings.some(
    //   setting => setting === ADVANCED_SETTINGS.BV_UFC
    // );
    // const isDAProgram = this.getFacilitySwitchAdvancedSettings.some(
    //   setting => setting === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
    // );
    // mod マスタ一覧 1･施設切替を可能とする 孔s end

    // if (isDispBvUfc) {
    //   // 施設設定-拡張設定-BV-UFCが"ON"の場合のみ一覧に表示する
    //   this.deviceList.push(new Device("BV-UFC", this.DEVICE_TYPE_BVUFC));
    // }
    // if (isDAProgram) {
    //   // 施設設定-拡張設定-透析量プログラムが"ON"の場合のみ一覧に表示する
    //   this.deviceList.push(new Device("透析量プログラム", this.DEVICE_TYPE_DIA));
    // }
    // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
    // this.deviceList.push(new Device("血流量・透析液流量プログラム", this.DEVICE_TYPE_QBQD));

    [this.medicineData, this.medicineMixData] = await Promise.all([
      medicine(this.facilityCd),
      medicineMix(this.facilityCd)
    ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw error;
    });

    // mod マスタ一覧 412画面と同じように記載を表示する。 start
    const response = await ApiHelper.get(
      `/deviceSetInfo/getDeviceSetInfoMst/${this.facilityCd}`
    ).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw new Error(error);
    });
    this.setLiquidDelayTiming(Number(response.data.pat.ope.dev.A[398]));

    const val_389 = response.data.pat.ope.dev.A[389];
    const displayStringLiquidAmount = LIQUID_AMOUNT_TEXT[parseInt(val_389)];
    const displayStringLiquidSpeed = LIQUID_SPEED_TEXT[parseInt(val_389)];

    // 補液速度のメッセージ表示設定
    this.setLiquidAmountDisplayString(displayStringLiquidAmount);
    this.setLiquidAmountCommentIsShow(true);
    // 補液量のメッセージ表示設定
    this.setLiquidSpeedDisplayString(displayStringLiquidSpeed);
    this.setLiquidSpeedCommentIsShow(true);

    document.getElementsByClassName("mst-treatment-set-amount")[0].style.minWidth = '50%'
    document.getElementsByClassName("mst-treatment-set-speed")[0].style.minWidth = '50%';
    this.initTreatMethodCd = this.treatMethodCd;
  },

  async mounted() {
    // 治療方法セットのデフォルト値を取得
    await this.getDefaultRecordData();
    // mod redmine 4551 小窓時の詳細モーダルのスクロール不正 孔 start
    // this.$el.parentElement.style.height = "100%";
    this.$el.parentElement.style.height = "98%";
    // mod redmine 4551 小窓時の詳細モーダルのスクロール不正 孔 end
    this.retrieveMstData();
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },

  beforeDestroy() {
    // dataの初期化(メモリリークに対する基本的な対応)
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    // mod マスタ一覧 412画面と同じように記載を表示する。 start
    ...mapMutations("pat-viewer-treat-cond", [
      "setLiquidAmountCommentIsShow",
      "setLiquidAmountDisplayString",
      "setLiquidSpeedCommentIsShow",
      "setLiquidSpeedDisplayString",
      "setLiquidDelayTiming",
    ]),
    // mod マスタ一覧 412画面と同じように記載を表示する。 end
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "edit",
      "setMasterRecordList",
      "editRecordBeEmpty",
      "setEditRecord"
    ]),
    ...mapActions("pat-viewer-treat-cond", ["initTreatCondData"]),
    ...mapMutations("pat-viewer-treat-cond", ["setDeviceMode"]),
    // add FNSI-8003 劉全航 start
    // mod 8681 ljx start
    ...mapActions("pat-viewer", ["getMstMedicine","getMstMedicineMix"]),
    // mod 8681 ljx end
    // add FNSI-8003 劉全航 end
    closeInvalidCss(event) {
      event.target.classList.remove("input-invalid")
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    masterUpdateInput(val){
      const data = {
        fnValue:{
          '薬剤分類': val.classCd,
          '薬剤区分': val.kbnValue
        },
        isDisp: val.isDisp,
        text: val.text,
        type: val.kbnValue,
        value: val.value
      }
      this.updateInputMedicine(data)
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ start
    getDeviceListStyle(device){
      if (device && device.type === this.DEVICE_TYPE_IHDF) { //I-HDF
        const deviceMode = this.treatMethodDeviceMode;
        // mod redmine 6044 I-HDFプログラムは治療方法がI-HDFではない場合は使用するに設定できないようにする。宋qy start
        // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
        if (
          // deviceMode === CODES.DEVICE_MODE.HD.cd || deviceMode === CODES.DEVICE_MODE.ECUM.cd || //HD・ECUM
          // deviceMode === CODES.DEVICE_MODE.HDF.cd || deviceMode === CODES.DEVICE_MODE.HF.cd || //HDF・HF
          // deviceMode === CODES.DEVICE_MODE.OHDF.cd || deviceMode === CODES.DEVICE_MODE.OHF.cd || //OHDF・OHF
          // deviceMode === CODES.DEVICE_MODE.AFBF.cd //AFBF
          deviceMode !== CODES.DEVICE_MODE.IHDF.cd
        ) {
        // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
        // mod redmine 6044 I-HDFプログラムは治療方法がI-HDFではない場合は使用するに設定できないようにする。宋qy end
          return "background-color: #696969;"
        }
      }
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      // if (this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd) { //特殊浄化
      //   if (
      //     device &&
      //     (
      //       device.type === this.DEVICE_TYPE_UFR || //除水プログラム
      //       device.type === this.DEVICE_TYPE_NA || //Na注入プログラム
      //       device.type === this.DEVICE_TYPE_DC || //透析液濃度プログラム
      //       device.type === this.DEVICE_TYPE_IHDF || //I-HDF
      //       device.type === this.DEVICE_TYPE_QBQD || //血流量・透析液流量プログラム
      //       device.type === this.DEVICE_TYPE_BVUFC //BV-UFC
      //     )
      //   ) {
      //     return "background-color: #696969;"
      //   }
      // }
      // add redmine 6038 治療モードAFBFの時にQdQbプログラムが入りにできてしまう。宋qy start
      // if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd) { //AFBF
      //   // mod #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
      //   if (device.type === this.DEVICE_TYPE_QBQD || device.type === this.DEVICE_TYPE_DC || device.type === this.DEVICE_TYPE_DIA) { // 血流量・透析液流量プログラムQdQb
      //   // mod #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
      //     return "background-color: #696969;"
      //   }
      // }
      // add redmine 6038 治療モードAFBFの時にQdQbプログラムが入りにできてしまう。宋qy end
      // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 start
      // if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd) { //I-HDF
      //   if (device.type === this.DEVICE_TYPE_QBQD || device.type === this.DEVICE_TYPE_UFR || device.type === this.DEVICE_TYPE_BVUFC) {
      //     return "background-color: #696969;"
      //   }
      // }
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
      // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 end
      return ""
    },

    setDeviceInfo(type, code, value){
      let deviceSetInfoRaw;
      if (this.getEditRecord.indDeviceSetInfo) {
        deviceSetInfoRaw = JSON.parse(
          this.getEditRecord.indDeviceSetInfo
        )
          ? JSON.parse(this.getEditRecord.indDeviceSetInfo)
          : this.getEditRecord.indDeviceSetInfo;
      }
      if (!deviceSetInfoRaw) {
        // 装置設定値がnullの場合は定義された初期値を設定
        deviceSetInfoRaw = defaultMstDeviceInfo.ord;
      }

      const deviceSetInfo = mapDeviceSetInfoEditable(deviceSetInfoRaw, type)

      deviceSetInfo.dev.A[code].value.editValue = value;

      const devInfoOrigin = mapDeviceSetInfoOrigin(
        deviceSetInfo,
        type
      );

      const devInfoUpdate = {
        [type]: devInfoOrigin
      };

      const indDeviceSetInfo = JSON.stringify({
        ...deviceSetInfoRaw,
        ...devInfoUpdate
      });
      this.setEditRecord({ ...this.getEditRecord, indDeviceSetInfo });
      if(this.tempIndDeviceSetInfo == null){
        this.tempIndDeviceSetInfo = indDeviceSetInfo;
      } else {
        if(this.tempIndDeviceSetInfo != indDeviceSetInfo){
            // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
            // this.changeButton();
            // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
        }
      }

    },

    //[確認]ボタンの状態の変更をトリガーします
   changeButton() {
      // 同時に実行されている非同期命令等がすべて完了してから[確認]ボタンの状態の変更する
      this.$nextTick(() => {
        EventBus.$emit("mstHolidayRegistered", false);
      })
    },
    changeDown(){
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
    //  if (this.treatMethodCd!==this.initTreatMethodCd) {
    //   this.changeButton();
    //  }else{
    //   EventBus.$emit("mstHolidayRegistered", true);
    //  }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
    },
    // del #7236-治療方法セットマスタのプログラムの動作不正 徐博 start
    // previewText(type) {
    //   let deviceSetInfoRaw;
    //   if (this.getEditRecord.indDeviceSetInfo) {
    //     deviceSetInfoRaw = JSON.parse(
    //       this.getEditRecord.indDeviceSetInfo
    //     )
    //       ? JSON.parse(this.getEditRecord.indDeviceSetInfo)
    //       : this.getEditRecord.indDeviceSetInfo;
    //   }
    //   if (!deviceSetInfoRaw) {
    //     // 装置設定値がnullの場合は定義された初期値を設定
    //     deviceSetInfoRaw = defaultMstDeviceInfo.ord;
    //   }
    //
    //   const deviceSetInfo = mapDeviceSetInfoEditable(deviceSetInfoRaw, type)
    //
    //   let text = ""
    //   let item
    //   let valueName = "value"
    //   let displayTextName = "displayValue"
    //   switch (type) {
    //     case this.DEVICE_TYPE_IHDF:
    //       item = deviceSetInfo.dev.A[432];
    //       valueName = "radioValue"
    //       displayTextName = "displayString"
    //       item.options[0].displayString = "I-HDFプログラム使用しない";
    //       item.options[1].displayString = "I-HDFプログラム使用する";
    //       break;
    //     case this.DEVICE_TYPE_UFR:
    //       item = deviceSetInfo.dev.A[290];
    //       break;
    //     case this.DEVICE_TYPE_NA:
    //       item = deviceSetInfo.dev.A[315];
    //       break;
    //     case this.DEVICE_TYPE_DC:
    //       item = deviceSetInfo.dev.A[340];
    //       break;
    //     case this.DEVICE_TYPE_BVUFC:
    //       item = deviceSetInfo.dev.A[196];
    //       valueName = "radioValue"
    //       displayTextName = "displayString"
    //       break;
    //     case this.DEVICE_TYPE_DIA:
    //       item = deviceSetInfo.dev.A[282];
    //       valueName = "radioValue"
    //       displayTextName = "displayString"
    //       break;
    //     default:
    //       break;
    //   }
    //
    //   if (type !== this.DEVICE_TYPE_QBQD) {
    //     if (item) {
    //       const itemValue = item.value.initValue
    //       const itemOptions = item.options
    //       const displayValue = itemOptions.find(i => i[valueName] === itemValue)
    //       text = displayValue ? displayValue[displayTextName] : ""
    //     }
    //   } else {
    //     //QB
    //     const QbItem = deviceSetInfo.dev.A[430]
    //     let QbDisplayValue = QbItem.options.find(i => i.radioValue === QbItem.value.initValue)
    //     if (!QbDisplayValue) {
    //       QbDisplayValue = QbItem.options[0]
    //     }
    //     const QbText = QbDisplayValue ? "「" + QbItem.formLabel + " : " + QbDisplayValue.displayString + "」" : ""
    //     //QD
    //     const QdItem = deviceSetInfo.dev.A[431]
    //     let QdDisplayValue = QdItem.options.find(i => i.radioValue === QdItem.value.initValue)
    //     if (!QdDisplayValue) {
    //       QdDisplayValue = QdItem.options[0]
    //     }
    //     const QdText = QdDisplayValue ? "「" + QdItem.formLabel + " : " + QdDisplayValue.displayString + "」" : ""
    //
    //     text = QdText + QbText
    //   }
    //
    //   if (text.length > 0) {
    //     text = "（" + text + "）"
    //   }
    //   return text
    // },
    // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ end
    // del #7236-治療方法セットマスタのプログラムの動作不正 徐博 end

    // add 治療方法セットマスタ 装置モードがI-HFDの場合、urfおよび血流量制御 start
    async showSubModalSpcl(device, dataSourceType){
      // I-HDF
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      // if (device.type === this.DEVICE_TYPE_IHDF) {
      //   if (
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.HD.cd    || //HD
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.ECUM.cd  || //ECUM
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.HDF.cd   || //HDF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.HF.cd    || //HF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHDF.cd  || //OHDF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHF.cd   || //OHF
      //     this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd   //AFBF
      //   ) {
      //     return;
      //   }
      // }

      // 特殊浄化
      // if (this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd) {
      //   if (device && (
      //       device.type === this.DEVICE_TYPE_UFR  || //除水プログラム
      //       device.type === this.DEVICE_TYPE_NA   || //Na注入プログラム
      //       device.type === this.DEVICE_TYPE_DC   || //透析液濃度プログラム
      //       device.type === this.DEVICE_TYPE_IHDF || //I-HDF
      //       device.type === this.DEVICE_TYPE_QBQD || //血流量・透析液流量プログラム
      //       device.type === this.DEVICE_TYPE_BVUFC   //BV-UFC
      //     )) {
      //     return;
      //   }
      // }

      // AFBF
      // if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd) {
      //   // 血流量・透析液流量プログラムQdQb
      //   // mod #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
      //   if (device.type === this.DEVICE_TYPE_QBQD || device.type === this.DEVICE_TYPE_DC || device.type === this.DEVICE_TYPE_DIA) {
      //   // mod #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
      //     return
      //   }
      // }

      // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 start
      // if (this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd) { // I-HDF
      //   if (device.type === this.DEVICE_TYPE_QBQD || device.type === this.DEVICE_TYPE_UFR || device.type === this.DEVICE_TYPE_BVUFC) {
      //     return
      //   }
      // }
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
      // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 王永吉 end

      await this.showSubModal(device, dataSourceType)

      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
      // if (device.type === this.DEVICE_TYPE_UFR) {
      //   // 除水プログラムのHD/ECUMの切替をHDに強制変更して非活性。
      //   if (
      //     this.treatMethodDeviceMode &&
      //     (
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.HDF.cd   || //HDF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.HF.cd    || //HF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHDF.cd  || //OHDF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHF.cd   || //OHF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd  || //AFBF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd  //I-HDF
      //     )
      //   ) {
      //     this.$nextTick(() => {
      //       setTimeout(() =>{
      //         $(".sub-modal-mask .sub-modal-body #ufrHdEucm *").attr("disabled",true);
      //       },1);
      //     })
      //   }
      //
      //   // 除水プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //   if ( this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd ) { //I-HDF]
      //     this.$nextTick(() => {
      //       setTimeout(() =>{
      //         $(".sub-modal-mask .sub-modal-body #ufrId *").attr("disabled",true);
      //       },1);
      //     })
      //   }
      // }

      // if (device.type === this.DEVICE_TYPE_BVUFC) {
      //   // シングルニードル使用するにした場合、BV-UFCを強制OFFに変更して、BV-UFC使用選択を変更不可にする。それ以外の項目以外は編集可能とする。
      //   const singleNeedle = this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.SINGLE_NEEDLE.cd)
      //   if (singleNeedle.value == '1') { // mod #9973 value Number→文字列  shiyw
      //     this.$nextTick(() => {
      //       setTimeout(() =>{
      //         $(".sub-modal-mask .sub-modal-body .device-info-content .bv-ufc-row:first *").attr("disabled",true)
      //       },1);
      //     })
      //   }

      //   // BV-UFCを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //   if ( this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd ) { //I-HDF
      //     this.$nextTick(() => {
      //       setTimeout(() =>{
      //         $(".sub-modal-mask .sub-modal-body .device-info-content .bv-ufc-row:first *").attr("disabled",true)
      //       },1);
      //     })
      //   }
      // }

      // if (device.type === this.DEVICE_TYPE_DIA) {
      //   // 透析量プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //   if (
      //     this.treatMethodDeviceMode &&
      //     (
      //       this.treatMethodDeviceMode == CODES.DEVICE_MODE.HDF.cd || this.treatMethodDeviceMode === CODES.DEVICE_MODE.HF.cd || //HDF・HF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHDF.cd || this.treatMethodDeviceMode === CODES.DEVICE_MODE.OHF.cd || //OHDF・OHF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd || //AFBF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd || //I-HDF
      //       this.treatMethodDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd //特殊浄化
      //     )
      //   ) {
      //     this.$nextTick(() => {
      //       setTimeout(() =>{
      //         $(".sub-modal-mask .sub-modal-body .device-info-content .device-info-cell:first *").attr("disabled",true)
      //       },1);
      //     })
      //   }
      // }

      // if (device.type === this.DEVICE_TYPE_DC) {
      //   // 透析液濃度プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //   if (
      //     this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.AFBF.cd //AFBF
      //   ) {
      //     this.$nextTick(() => {
      //       setTimeout(() =>{
      //         $(".sub-modal-mask .sub-modal-body #dcSwitch *").attr("disabled",true)
      //       },1);
      //     })
      //   }
      // }
      //
      // if (device.type === this.DEVICE_TYPE_QBQD) {
      //   // 血流量、透析液流量プログラムを強制的にOFFにして変更不可にする。スイッチ部分以外は変更可能とする。
      //   if (
      //     this.treatMethodDeviceMode && this.treatMethodDeviceMode === CODES.DEVICE_MODE.IHDF.cd //I-HDF
      //   ) {
      //     this.$nextTick(() => {
      //       setTimeout(() =>{
      //         $(".sub-modal-mask .sub-modal-body .sub-area .sub-area-item:lt(2) *").attr("disabled",true)
      //       },1);
      //     })
      //   }
      // }
      // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
    },
    // add 治療方法セットマスタ 装置モードがI-HFDの場合、urfおよび血流量制御 end
    /**
     * @description 編集データを取得
     */
    async retrieveMstData() {
      // 新規追加フラグ
      const isNew =
        "" === this.getEditRecord.treatmentCd &&
        "" === this.getEditRecord.indCondInfo &&
        "" === this.getEditRecord.indMediInfo &&
        "" === this.getEditRecord.indEquipInfo &&
        "" === this.getEditRecord.indIndCommentInfo;
      // 新規追加の際に、それぞれの項目にデフォルト値を格納する
      const treatCond = isNew
        ? JSON.parse(this.recordDefaultData.indCondInfo)
        : this.getEditRecord.indCondInfo &&
          JSON.parse(this.getEditRecord.indCondInfo);
      const medicine = isNew
        ? JSON.parse(this.recordDefaultData.indMediInfo)
        : this.getEditRecord.indMediInfo &&
          JSON.parse(this.getEditRecord.indMediInfo);
      const equipment = isNew
        ? JSON.parse(this.recordDefaultData.indEquipInfo)
        : this.getEditRecord.indEquipInfo &&
          JSON.parse(this.getEditRecord.indEquipInfo);
      const treatComment = isNew
        ? JSON.parse(this.recordDefaultData.indIndCommentInfo)
        : this.getEditRecord.indIndCommentInfo &&
          JSON.parse(this.getEditRecord.indIndCommentInfo);

      // 治療方法
      this.treatMethod = await treatment(this.facilityCd).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'retrieveMstData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      this.treatMethodCd = parseInt(this.getEditRecord.treatmentCd);

      // 治療条件
      if (treatCond) {
        var mergeTreatCond = [];
        for (let idx = 0; idx < this.treatCond.length; idx++){
          var cond = this.treatCond[idx];
          /* modify by chamaojia 2023-10-27 [9973] NULL値が存在する場合は、判断条件を追加する必要がある --start */
          if (treatCond[cond.treatCondNo]) {
          cond.value = treatCond[cond.treatCondNo].value;
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 №42 dengshen start
          // cond.medicineType = treatCond[cond.treatCondNo].medicine_type;
            cond.medicineType = treatCond[cond.treatCondNo].medicine_type != null ? Number(treatCond[cond.treatCondNo].medicine_type) : null;
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 №42 dengshen end
          }
          /* modify by chamaojia 2023-10-27 [9973] NULL値が存在する場合は、判断条件を追加する必要がある --end */
          mergeTreatCond.push(cond);
        }
        this.treatCond = mergeTreatCond;
      }

      // 治療条件のストアを初期化
      this.initTreatCondData({ indCondInfo: treatCond });
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
      this.getEditRecordDefault.indCondInfo = JSON.stringify(treatCond);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end

      // 投与薬剤
      this.medicine = !medicine
        ? this.medicine
        : medicine.map(item => {
            return {
              id: _.uniqueId("medicine"),
              cd: item.cd,
              // 子へ渡すデータ※保存対象外
              unit: this.getUnit(item.cd, item.medicine_type),
              amount: item.amount,
              timingCd: item.timing_cd,
              procedureCd: item.procedure_cd,
              medicineType: item.medicine_type,
              // {comment} add redmine 4903 薬剤のコメントが存在しない 孔
              comment: item.medicine_comment
            };
          });

      // 医療材料
      this.equipment = !equipment
        ? this.equipment
        : equipment.map(item => {
            return {
              id: _.uniqueId("equipment"),
              cd: item.cd,
              amount: item.amount,
              equipType: item.equip_type
            };
          });

      // 指示コメント
      this.treatComment = !treatComment
        ? this.treatComment
        : treatComment.map(item => {
            return {
              id: _.uniqueId("comment"),
              no: item.no,
              content: item.content
            };
          });
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
      this.getEditRecordDefault = deepCopy(this.getEditRecord);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
    },

    /**
     * @description セット名更新
     */
    setLayoutName(value) {
      const name = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, name });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
      // if (this.getEditRecordName !== this.getEditRecord.name) {
      // this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
    },

    /**
     * @description 治療時間更新
     */
    changeMstTreatmentSetDay(data){
      this.mstTreatmentSetDay = data.mstTreatmentSetDay;
      let MChar = Number(this.mstTreatmentSetDay*24*60 + data.conTreatTime);
      this.$set(this.treatCond.find(cond => cond.treatCondNo === '1'), "value", MChar);
    },

    /**
     * @description 表示時間を変更する
     */
    changeConTreatTime(conTreatTime){
      if(conTreatTime <= 0 ){
        conTreatTime = 0;
        let temp = document.getElementsByClassName('text-input')[1].value;
        document.getElementsByClassName('text-input')[1].value = "00:00";
        document.getElementsByClassName('text-input')[1].value = temp;
        document.getElementsByClassName('time')[0].value = "00";
        document.getElementsByClassName('time')[1].value = "00";
      }else if(conTreatTime >= 599){
        conTreatTime = 599;
        let temp = document.getElementsByClassName('text-input')[1].value;
        document.getElementsByClassName('text-input')[1].value = "09:59"
        document.getElementsByClassName('text-input')[1].value = temp;
        document.getElementsByClassName('time')[0].value = "09";
        document.getElementsByClassName('time')[1].value = "59";
      }
      return conTreatTime;
    },

    /**
     * @description 治療方法更新
     */
    setTreatmentCd(value) {
      const treatmentCd = parseInt(value);
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, treatmentCd });
      if(this.tempTreatmentCd == null){
        this.tempTreatmentCd = treatmentCd;
      } else {
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
        // if(this.tempTreatmentCd != treatmentCd){
        //  this.changeButton();
        // }
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
      }
    },

    /**
     * @description 治療条件変更
     * @param value 治療条件のオブジェクト
     */
    setIndCondInfo(value) {
      var objIndCondInfo = {};
      for (let idx = 0; idx < value.length; idx++){
        const cond = value[idx];
        objIndCondInfo[Number(cond.treatCondNo)] = {
          value: cond.value == null? null : (cond.value + ''), // mod #9973 value Number→文字列  shiyw
          medicine_type: cond.medicineType
        };
        // add #10196_ord_mainのデータ定義から外れているデータ登録・参照処理の修正 shiyw start
        if(cond.medicineType == null){
          delete objIndCondInfo[Number(cond.treatCondNo)].medicine_type;
        }
        // add #10196_ord_mainのデータ定義から外れているデータ登録・参照処理の修正 shiyw end
      }

      const indCondInfo = JSON.stringify(objIndCondInfo);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
      if (this.treatMethodCount === 0) {
        this.getEditRecordDefault.indCondInfo = indCondInfo;
      }
      this.treatMethodCount++;
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, indCondInfo });
    },

    /**
     * @description 投与薬剤変更
     * @param value 投与薬剤の配列
     */
    setIndMediInfo(value) {
      // 投与薬剤のcdがnullのものを医療材料の配列から外す
      value = value.filter(item => {
        return null !== item.cd;
      });
      const indMediInfo = JSON.stringify(
        value.map(item => {
          return {
            cd: item.cd,
            // add 9973 -4 by kangjie 20231102 start
            // amount: item.amount,
            amount: item.amount + "",
            // add 9973 -4 by kangjie 20231102 end
            timing_cd: item.timingCd,
            procedure_cd: item.procedureCd,
            medicine_type: item.medicineType,
            // {medicine_comment} add redmine 4903 薬剤のコメントが存在しない 孔
            // modify 11323 by kangjie 20241203 start 投与薬剤コメットが空の場合はnullを一括保存
            // medicine_comment: item.comment
            medicine_comment: item.comment === "" ?null:item.comment
            // modify 11323 by kangjie 20241203 end
          };
        })
      );
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, indMediInfo });
    },

    /**
     * 医療材料の更新
     * @param value 医療材料の配列
     */
    setIndEquipInfo(value) {
      // 医療材料のcdがnullのものを医療材料の配列から外す
      value = value.filter(item => {
        return null !== item.cd;
      });
      const indEquipInfo = JSON.stringify(
        value.map(item => {
          return {
            cd: item.cd,
            // add 9973 -4 by kangjie 20231102 start
            // amount: item.amount,
            amount: item.amount + "",
            // add 9973 -4 by kangjie 20231102 end
            equip_type: item.equipType
          };
        })
      );

      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, indEquipInfo });
      // 変更前後の比較による更新ボタンの活性化・非活性化の制御
      if(this.prevIndEquipInfo == null){
        this.prevIndEquipInfo = indEquipInfo;
      } else {
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
        // if(this.prevIndEquipInfo !== indEquipInfo){
        //   this.changeButton();
        // } else {
        //   EventBus.$emit("mstHolidayRegistered", true);
        // }
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
      }
    },

    /**
     * 医材選択ボタン押下時のポップオーバー表示位置を取得.
     * @return {Element} クリックされた選択ボタン要素.
     */
     popoverTargetElement(index) {
      switch (index) {
        case "addEquipment":
          // 医療材料の追加の時
          return this.$refs.popoverButtonEquipment;
          break;
        case null:
          // 詳細画面描画前に呼ばれた場合にはポップオーバー表示をキャンセルする考慮
          this.closePopover();
          break;
        default:
          // 医療材料の選択(確定前)のとき
          return this.$refs[this.buttonPosi][0];
      }
    },

    /**
     * @description 指示コメント変更
     * @param value 指示コメントの配列
     */
    setIndCommentInfo(value) {
      // 指示コメントのnoがnullのものを医療材料の配列から外す
      value = value.filter(item => {
        return null !== item.no;
      });
      const indIndCommentInfo = JSON.stringify(
        value.map(item => {
          return {
            no: item.no,
            content: item.content
          };
        })
      );

      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, indIndCommentInfo });
      if(this.tempIndIndCommentInfo == null){
        this.tempIndIndCommentInfo = indIndCommentInfo;
      } else {
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
        // if(this.tempIndIndCommentInfo != indIndCommentInfo){
        //   this.changeButton();
        // }
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end
      }

    },

    /**
     * @description 項目内容編集後コールバック
     * @param type  編集項目の種類
     * @param data  編集内容
     * @param id    内部識別キー
     */
    editItem(type, data, id) {
      let editIndex = null;

      // 抗凝固剤、透析液、補液
      const useMedicineMixList = ["25","15","19"];
      //del 9664補液及び透析液仕様修正します yangqingzhe start
      // let chgDataFlg = false;
      //del 9664補液及び透析液仕様修正します yangqingzhe　end
      switch (type) {
        case "cond":
          // 通常薬剤・調製薬剤の分類を導入
          if (useMedicineMixList.includes(id)) {
            const popoverEditedValue = this.$refs[id][0].popoverData
              .popoverContentSelected.value;
            // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
            const popoverEditedType = this.$refs[id][0].popoverData
            .popoverContentSelected.type;
            // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
            // mod #9973 cond No.15 19 25 medicineType complement 20240105 ztc start
            if (popoverEditedValue !== null) {
              // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
              //if (String(popoverEditedValue).match(/\$/)) {
                if (popoverEditedType == 2) {
              // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
                // 調製薬剤
                this.$set(this.treatCond.find(cond => cond.treatCondNo === id), "medicineType", 2);
                // this.$set(this.treatCond.find(cond => cond.treatCondNo === id), "medicineType", "2");
              } else {
                // 薬剤
                this.$set(this.treatCond.find(cond => cond.treatCondNo === id), "medicineType", 1);
                // this.$set(this.treatCond.find(cond => cond.treatCondNo === id), "medicineType", "1");
              }
            } else {
              this.$set(this.treatCond.find(cond => cond.treatCondNo === id), "medicineType", null);
            }
            // mod #9973 cond No.15 19 25 medicineType complement 20240105 ztc end
          }

          /* add 治療時間制限 start*/
          if(id === "1" && this.treatMethodDeviceMode !== 9 && this.treatMethodDeviceMode !== -1){
            data = this.changeConTreatTime(data);
          }
          /* add 治療時間制限 end*/

          // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 start
          // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
          // if (CODES.TREATMENT_CONDITION_ITEM.SINGLE_NEEDLE.cd === id && data) {
            // シングルニードル使用するにした場合、BV-UFCを強制OFFに変更して、BV-UFC使用選択を変更不可にする。
            // this.setDeviceInfo(this.DEVICE_TYPE_BVUFC ,196 ,"0")
          // }
          // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
          // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 end

          // デフォルト値の格納処理
          //del 9664補液及び透析液仕様修正します yangqingzhe start
          // chgDataFlg = data != this.selectTreatCondByTreatCondNo(id).value;  // mod #9973 value Number→文字列  shiyw
          //del 9664補液及び透析液仕様修正します yangqingzhe end
          this.setTreatCondDefault(id, data);
          this.$set(this.treatCond.find(cond => cond.treatCondNo === id), "value", data);

          // 治療方法にOHDF、OHF、HD+補液、ECUM+補液が選択されている場合
          // 透析液変更時に補液も同じ変更を行う
          if (id === CODES.TREATMENT_CONDITION_ITEM.DIALYSATE.cd && this.ivChangeDeviceModeList.includes(this.treatMethodDeviceMode)){
            const popoverEditedValue = this.$refs[id][0].popoverData
              .popoverContentSelected.value;
            if (
              popoverEditedValue !== null &&
              String(popoverEditedValue).match(/\$/)
            ) {
              // 調製薬剤
              this.$set(this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd), "medicineType", 2);
              // this.$set(this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd), "medicineType", "2");
            } else {
              // 薬剤
              this.$set(this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd), "medicineType", 1);
              // this.$set(this.treatCond.find(cond => cond.treatCondNo === CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd), "medicineType", "1");
            }
            // デフォルト値の格納処理
            this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT.cd, data);

            // 補液量、補液選択、補液使用数、補液温度、補液速度を編集可能とする(補液は直接編集不可のまま)
            //del 9664補液及び透析液仕様修正します yangqingzhe start
            // if (chgDataFlg && data !== null){
            //   this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_AMOUNT.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_AMOUNT.cd));
            //   this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TIMING.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TIMING.cd));
            //   this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_USE_COUNT.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_USE_COUNT.cd));
            //   this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TEMPERATURE.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_TEMPERATURE.cd));
            //   this.setTreatCondValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_SPEED.cd, this.getTreatCondDefaultValue(CODES.TREATMENT_CONDITION_ITEM.FLUID_REPLACEMENT_SPEED.cd));
            // }
            //del 9664補液及び透析液仕様修正します yangqingzhe end
          }

          break;
        case "medicine":
          editIndex = this.medicine.findIndex(item => {
            return item.id === id;
          });

          this.$set(this.medicine, editIndex, {
            ...this.medicine[editIndex],
            ...data
          });
          break;
        case "equipment":
          editIndex = this.equipment.findIndex(item => {
            return item.id === id;
          });

          this.$set(this.equipment, editIndex, {
            ...this.equipment[editIndex],
            ...data
          });
          break;
        case "comment":
          document.getElementById(id).classList.remove("input-invalid-comment-number")
          // add #11731_【因島：改良】指示コメント番号の指定方法（必須項目エラー背景色を解除）start
          if (data.content) {
            document.getElementById(id).classList.remove("input-invalid-comment-content");
          }
          // add #11731_【因島：改良】指示コメント番号の指定方法 end

          editIndex = this.treatComment.findIndex(item => {
            return item.id === id;
          });
          // data をオブジェクトリテラルで展開してthis.treatComment[editIndex]のプロパティの値を上書きして$setで更新する
          this.$set(this.treatComment, editIndex, {
            ...this.treatComment[editIndex],
            ...data
          });
          break;
        default:
          break;
      }
    },

    /**
     * 医療材料 数量の保存.
     */
    editEquipmentAmountValue(type, data, id) {
      // 編集対象の医療材料の引き当て
      const editIndex = this.equipment.findIndex(item => {
            return item.id == id;
      });
      // add 9973 -4 by kangjie 20231102 start
      // this.$set(this.equipment[editIndex], 'amount', Number(data.target.value));
      // #9848+9849 数値IFのスタイル全不正 linjunfeng start
      // this.$set(this.equipment[editIndex], 'amount', Number(data.target.value) +"");
      this.$set(this.equipment[editIndex], 'amount', Number(data) +"");
      // #9848+9849 数値IFのスタイル全不正 linjunfeng end
      // add 9973 -4 by kangjie 20231102 end
      // 医療材料の保存
      this.setIndEquipInfo(this.equipment);
    },

    /**
     * @description 項目を配列にアペンド
     * @param type  追加項目の種類
     */
    addItem(type) {
      // 治療方法セットマスタ 障害修正 指示コメント番号は重複の場合も保存しました 孔 start
      let commentNo = 1
      if (type === "comment") {
        // add #10777 しかし治療方法セットマスタで指示コメント番号99を追加した際に自動で次の番号で追加されるためそれ以上の指示コメント番号が追加可能であったNG linjunfeng start
        const maxNo = 99;
        if (this.treatComment.length >= maxNo) {
          return;
        }
        // add #10777 しかし治療方法セットマスタで指示コメント番号99を追加した際に自動で次の番号で追加されるためそれ以上の指示コメント番号が追加可能であったNG linjunfeng end
        if (this.treatComment.length > 0) {
          // #10777 しかし治療方法セットマスタで指示コメント番号99を追加した際に自動で次の番号で追加されるためそれ以上の指示コメント番号が追加可能であったNG linjunfeng start
          // const maxNo = Math.max(...this.treatComment.map(item => {return item.no}))
          // commentNo = maxNo+1
          const baseList = [...Array(maxNo).keys()].map(i => ++i);
          const treatNo = this.treatComment.map(item => {return item.no});
          for (let item of baseList) {
            if (!treatNo.includes(item)) {
              commentNo = item;
              break;
            }
          }
          // #10777 しかし治療方法セットマスタで指示コメント番号99を追加した際に自動で次の番号で追加されるためそれ以上の指示コメント番号が追加可能であったNG linjunfeng end
        }
      }
      // 治療方法セットマスタ 障害修正 指示コメント番号は重複の場合も保存しました 孔 end

      switch (type) {
        case "medicine":
          this.medicine.push({
            id: _.uniqueId("medicine"),
            cd: null,
            // 子へ渡すデータ※保存対象外
            unit: null,
            amount: null,
            timingCd: null,
            procedureCd: null,
            medicineType: null,
            // {comment} add redmine 4903 薬剤のコメントが存在しない 孔
            comment: ""
          });
          break;
        case "equipment":
          this.equipment.push({
            id: _.uniqueId("equipment"),
            cd: null,
            amount: null,
            equip_type: null
          });
          break;
        case "comment":
          this.treatComment.push({
            id: _.uniqueId("comment"),
            // no: null,
            no: commentNo,
            content: null
          });
          break;
        default:
          break;
      }
    },

    /**
     * @description 項目を配列から削除
     * @param type  削除項目の種類
     * @param index 要素番号
     */
    deleteItem(type, index) {
      switch (type) {
        case "medicine":
          this.medicine.splice(index, 1);
          break;
        case "equipment":
          this.equipment.splice(index, 1);
          break;
        case "comment":
          this.treatComment.splice(index, 1);
          break;
        default:
          break;
      }
    },

    /**
     * 治療方法セットをコピーする
     * @description
     *  現在表示している治療方法セット情報をコピーして新しくレコードを追加する
     */
    copyTreatmentSet() {
      // 名称を空にしてこの画面内容のレコードをストアに登録
      const d = new Object();
      // コピー元となる治療条件情報を格納
      const indCondInfo = JSON.stringify(
        _.mapObject(this.treatCond, o => {
          return {
            value: o.value,
            medicine_type: o.medicineType
          };
        })
      );

      // コピー元となる投与薬剤情報を格納
      const indMedi = this.medicine.map(item => {
        return {
          cd: item.cd,
          // 子へ渡すデータ※保存対象外
          unit: item.unit,
          amount: item.amount,
          timing_cd: item.timingCd,
          procedure_cd: item.procedureCd,
          medicine_type: item.medicineType,
          // {medicine_comment} add redmine 4903 薬剤のコメントが存在しない 孔
          medicine_comment: item.comment
        };
      });
      // ストア更新用に値を加工
      const indMediInfo = 0 === indMedi.length ? "" : JSON.stringify(indMedi);

      // コピー元となる医療材料情報を格納
      const indEquip = this.equipment.map(item => {
        return {
          cd: item.cd,
          amount: item.amount,
          equip_type: item.equip_type
        };
      });
      // ストア更新用に値を加工
      const indEquipInfo =
        0 === indEquip.length ? "" : JSON.stringify(indEquip);

      // コピー元となる指示コメント情報を格納
      const indIndComment = this.treatComment.map(item => {
        return {
          no: item.no,
          content: item.content
        };
      });
      // ストア更新用に値を加工
      const indIndCommentInfo =
        0 === indIndComment.length ? "" : JSON.stringify(indIndComment);

      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          this.$set(d, k, fields[k].defaultValue);
        } else if ("string" === fields[k].type) {
          this.$set(d, k, "");
        } else if ("number" === fields[k].type) {
          this.$set(d, k, 0);
        } else {
          this.$set(d, k, null);
        }
        // 治療方法コード、治療条件、投与薬剤、医療材料、指示コメント格納用
        let setValue = null;
        switch (k) {
          // 治療方法コード
          case "treatmentCd":
            setValue = this.treatMethodCd;
            break;

          // 治療条件
          case "indCondInfo":
            setValue = indCondInfo;
            break;

          // 投与薬剤
          case "indMediInfo":
            setValue = indMediInfo;
            break;

          // 医療材料
          case "indEquipInfo":
            setValue = indEquipInfo;
            break;

          case "indIndCommentInfo":
            setValue = indIndCommentInfo;
            break;

          // 異常値
          default:
            break;
        }
        if (null !== setValue) {
          this.$set(d, k, setValue);
        }
      });
      // 削除フラグ情報を格納する
      this.$set(d, "isDel", "0");
      // 編集済みとする
      this.$set(d, "operation", 2);
      // レコードを追加する
      this.edit({ editRecord: d, isSortMode: false });
      // ====================================================================================
      // TODO: 以下コメントアウトしている部分を適用するか要検討
      // 上記の処理の場合、コピーしたレコードに編集を加えず保存ボタンをクリックした際にレコードが削除されてしまう
      // ※コメントアウトしている部分もシステムエラーで保存できていないため修正が必要
      // ====================================================================================

      // // マスターレコードリストを取得
      // const masterRecordList = deepCopy(this.getMasterRecordList);
      //
      // masterRecordList.data.unshift(d);

      // // コピーしたレコードをストアで反映させる
      // this.setMasterRecordList(undefined);
      // this.setMasterRecordList(masterRecordList);

      // // state.editRecordを空にする
      // this.editRecordBeEmpty();

      // 治療方法セット編集モーダルを閉じる
      this.$emit("closeMasterEditModal");
    },
    //add 9664補液及び透析液仕様修正します yangqingzhe start
    getTreatMethodDeviceMode(treatMethodCd) {
      if (!treatMethodCd) return null;
      const method = this.treatMethod.find(item => {
        return item.treatmentCd === treatMethodCd;
      });
      return method ? method.deviceMode : null;
    },
    //add 9664補液及び透析液仕様修正します yangqingzhe end
    /**
     * 治療条件情報値の変更
     * @description 編集コンポーネントの表示値と内部値の変更
     * @param id   内部識別キー
     * @param data 編集内容
     */
    setTreatCondValue(id, data) {
      // 編集コンポーネントの値格納
      this.$set(this.$refs[id][0].displayInputValue, "editValue", data);
      // 内部値の格納
      this.$set(this.treatCond.find(cond => cond.treatCondNo === id), "value", data);
    },

    /**
     * 治療条件デフォルト値変換
     * @description
     * 治療方法変更時に補液、補液量、補液使用数、補液速度を変更
     * 抗凝固剤変更時に抗凝固剤ワンショット量、抗凝固剤持続速度、抗凝固剤持続総量を変更
     * @param id   内部識別キー
     * @param data 編集内容
     */
    setTreatCondDefault(id, data) {
      // デフォルト値格納先内部識別キー
      let idList = [];
      switch (Number(id)) {
        // 補液
        case 19:
          // 補液が未登録になった場合
          if (null === data) {
            // 補液量、補液使用数、補液速度が編集不可の場合
            if (0 === Number(this.selectTreatCondByTreatCondNo("20").isUse)){
              this.setTreatCondValue("20", null);
              this.setTreatCondValue("22", null);
              this.setTreatCondValue("24", null);
            }
          }
          break;

        // 抗凝固剤
        case 25:
          // 抗凝固剤が変更された時
          if (this.selectTreatCondByTreatCondNo(id).value != data) { // mod #9973 value Number→文字列  shiyw
            // 抗凝固剤ワンショット量、抗凝固剤持続速度、抗凝固剤持続総量の内部識別キーを格納
            idList = [26, 27, 28];
          }
          break;

        // 異常値
        default:
          break;
      }
      // 格納された識別キー分ループ
      idList.forEach(index => {
        this.setTreatCondValue(
          String(index),
          this.getTreatCondDefaultValue(index)
        );
      });
    },

    /**
     * デフォルト値を格納
     * @description
     * 治療方法セットコードが0で施設コードが"nkknkk"に治療方法セットのデフォルト値が格納されており、
     * そのデフォルト値を取得し格納する
     */
    async getDefaultRecordData() {
      // TODO: 一時的にコメントアウト
      // const response = await ApiHelper.get(apiPath);
      // 治療方法セットコードが0で施設コードが"nkknkk"のものを取得
      // const d = response.data.find(eleItem => {
      //   return 0 === eleItem.treatmentSetCd && "nkknkk" === eleItem.facilityCd;
      // });
      const d = {
        // mod #9973 value Number→文字列 shiyw start
        // indCondInfo: `{"1": {"value": 240}, "2": {"value": null}, "3": {"value": -1}, "4": {"value": 5}, "5": {"value": null}, "6": {"value": null}, "7": {"value": null}, "8": {"value": null}, "9": {"value": null}, "10": {"value": null}, "11": {"value": null}, "12": {"value": 0}, "13": {"value": null}, "14": {"value": 200}, "15": {"value": null}, "16": {"value": 500}, "17": {"value": 0}, "18": {"value": 36}, "19": {"value": null}, "20": {"value": 0}, "21": {"value": 1}, "22": {"value": 0}, "23": {"value": 36}, "24": {"value": 0}, "25": {"value": null}, "26": {"value": 0}, "27": {"value": 0}, "28": {"value": 0}, "29": {"value": 1}, "30": {"value": 1}, "31": {"value": 0}, "32": {"value": 0}, "33": {"value": 10}, "34": {"value": 0}, "35": {"value": 0}, "36": {"value": 0}, "37": {"value": 0}, "38": {"value": 0}, "39": {"value": 0}}`,
        // mod #9973 cond No.15 19 25 medicineType complement 20240105 ztc start
        // indCondInfo: `{"1": {"value": "240"}, "2": {"value": null}, "3": {"value": "-1"}, "4": {"value": "5"}, "5": {"value": null}, "6": {"value": null}, "7": {"value": null}, "8": {"value": null}, "9": {"value": null}, "10": {"value": null}, "11": {"value": null}, "12": {"value": "0"}, "13": {"value": null}, "14": {"value": "200"}, "15": {"value": null}, "16": {"value": "500"}, "17": {"value": "0"}, "18": {"value": "36"}, "19": {"value": null}, "20": {"value": "0"}, "21": {"value": "1"}, "22": {"value": "0"}, "23": {"value": "36"}, "24": {"value": "0"}, "25": {"value": null}, "26": {"value": "0"}, "27": {"value": "0"}, "28": {"value": "0"}, "29": {"value": "1"}, "30": {"value": "1"}, "31": {"value": "0"}, "32": {"value": "0"}, "33": {"value": "10"}, "34": {"value": "0"}, "35": {"value": "0"}, "36": {"value": "0"}, "37": {"value": "0"}, "38": {"value": "0"}, "39": {"value": "0"}}`,
        indCondInfo: `{"1": {"value": "240"}, "2": {"value": null}, "3": {"value": "-1"}, "4": {"value": "5"}, "5": {"value": null}, "6": {"value": null}, "7": {"value": null}, "8": {"value": null}, "9": {"value": null}, "10": {"value": null}, "11": {"value": null}, "12": {"value": "0"}, "13": {"value": null}, "14": {"value": "200"}, "15": {"value": null, "medicine_type": null}, "16": {"value": "500"}, "17": {"value": "0"}, "18": {"value": "36"}, "19": {"value": null, "medicine_type": null}, "20": {"value": "0"}, "21": {"value": "1"}, "22": {"value": "0"}, "23": {"value": "36"}, "24": {"value": "0"}, "25": {"value": null, "medicine_type": null}, "26": {"value": "0"}, "27": {"value": "0"}, "28": {"value": "0"}, "29": {"value": "1"}, "30": {"value": "1"}, "31": {"value": "0"}, "32": {"value": "0"}, "33": {"value": "10"}, "34": {"value": "0"}, "35": {"value": "0"}, "36": {"value": "0"}, "37": {"value": "0"}, "38": {"value": "0"}, "39": {"value": "0"}}`,
        // mod #9973 value Number→文字列 shiyw end
        // mod #9973 cond No.15 19 25 medicineType complement 20240105 ztc end
        indEquipInfo: "[]",
        indIndCommentInfo: "[]",
        indMediInfo: "[]",
        indDeviceSetInfo: null
      };

      this.recordDefaultData = d;
    },

    /**
     * 治療条件初期値設定
     * @description
     * 画面立ち上げ時に治療方法セットが新規編集の場合、
     * デフォルト値を格納する
     * TODO: 治療方法法セットコードの0がデフォルト値のため、この関数はよんでいないが念の為残している
     * @return treatCondInfo 治療条件デフォルト値
     */
    setInitTreatCondDefault() {
      // 治療条件情報格納用
      const treatCondInfo = {};
      for (let i = 1; i <= 38; i++) {
        // キーが存在しない場合
        if (!_.has(treatCondInfo, String(i))) {
          this.$set(treatCondInfo, String(i), {});
        }
        // 取得したデフォルト値を格納する
        this.$set(
          treatCondInfo[String(i)],
          "value",
          this.getTreatCondDefaultValue(i)
        );
      }
      return treatCondInfo;
    },

    /**
     * 治療条件のデフォルト値を取得
     * @param id 治療条件内部識別キー
     */
    getTreatCondDefaultValue(id) {
      let value = null;
      switch (Number(id)) {
        // 治療時間
        case 1:
          value = "240";
          break;
        // 除水量制限
        case 4:
          value = "5";
          break;
        // 補液選択, IP使用選択, IPスタート
        case 21:
        case 29:
        case 30:
          value = "1";
          break;

        /**
         * シングルニードル, 透析液流量,
         * 補液, 補液量, 補液使用数, 補液速度,
         * IPワンショット量, IPワンショットスタート, IP電源自動切り,
         * IP電源自動切り時間, IP電源OKモニタ切り,
         * IP電源OKモニタ切り時間
         */
        //mod 9664補液及び透析液仕様修正します yangqingzhe start
        // 透析液流量
        // case 16:
        case 16:
          value = "500";
          break;
        //mod 9664補液及び透析液仕様修正します yangqingzhe start
        case 12:
        case 19:
        //mod 9664補液及び透析液仕様修正します yangqingzhe start
        // case 20:
        case 22:
        case 24:
        case 26:
        case 27:
        case 28:
        case 31:
        case 32:
        case 34:
        case 35:
        case 36:
        case 37:
        case 38:
          value = "0";
          break;
        case 20:
          value = "0.0";
          break;
        //mod 9664補液及び透析液仕様修正します yangqingzhe end
        // 血液流量
        case 14:
          value = "200";
          break;
        //mod 9664補液及び透析液仕様修正します yangqingzhe start
        // // 透析液流量
        // case 17:
        //   value = "500";
        //   break;
        // 透析液使用数
        case 17:
          value = "0";
          break;
        //mod 9664補液及び透析液仕様修正します yangqingzhe end
        // 透析液温度, 補液温度
        case 18:
        case 23:
          value = "36";
          break;

        // IP速度最大値
        case 33:
          value = "10";
          break;

        default:
          break;
      }
      return value;
    },

    /**
     * @description バリデーションチェック
     * @summary 確定ボタン押下でイベント発火
     * @returns 「true: 編集内容設定&閉じる」, 「false: メッセージ表示」
     */
    validateOnRegistration() {
      if (!this.isTreatmentName) {
        document.getElementsByClassName("input-required")[0]?.classList?.add("input-invalid");
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "必須入力",
          // message: "セット名を設定して下さい"
          title: DIALOG_MESSAGES['00200098'].title,
          message: messageFormat(DIALOG_MESSAGES['00200098'].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }
      // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng start
      for (let item of this.medicine) {
        if (item.amount === "" || isNaN(item.amount) || item.amount == 0) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[13000170].title,
            message: DIALOG_MESSAGES[13000170].message
          });
          return;
        }
      }
      for (let item of this.equipment) {
        if (item.amount === "" || isNaN(item.amount) || item.amount == 0) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[13000170].title,
            message: DIALOG_MESSAGES[13000170].message
          });
          return;
        }
      }
      // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng end

      // 治療方法セットマスタ 障害修正 指示コメント番号は重複の場合も保存しました 孔 start
      if(this.treatComment.length > 1) {
        const notRepeatingItems = []
        const repeatingItems = []
        this.treatComment.forEach(item => {
          if (notRepeatingItems.some(i => i.no === item.no)) {
            repeatingItems.push(item)
          } else {
            notRepeatingItems.push(item)
          }
        })
        if (repeatingItems.length > 0) {
          repeatingItems.forEach(item => {
            document.getElementById(item.id)?.classList?.add("input-invalid-comment-number")
          })
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // const message = DIALOG_MESSAGES[60000001].replace(/{\$\d*}/, "指示コメント番号")
          const message =  messageFormat(DIALOG_MESSAGES[60000001].message, "指示コメント番号")
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES["00300006"].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: message
          });
          return false;
        }
      }
      // 治療方法セットマスタ 障害修正 指示コメント番号は重複の場合も保存しました 孔 end

      // add #11731_【因島：改良】指示コメント番号の指定方法（指示コメントの入力チェック）start
      if(this.treatComment.length) {
        let isInvalidCommentContent = false;
        this.treatComment.forEach(item => {
          // 指示コメントのチェック（空白は許容）
          if (!item.content) {
            // 指示コメントの背景色を設定
            isInvalidCommentContent = true;
            document.getElementById(item.id)?.classList?.add("input-invalid-comment-content");
          }
        });
        if (isInvalidCommentContent) {
          const message =  messageFormat(DIALOG_MESSAGES["00200162"].message, "指示コメント", "指示コメント");
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES["00200162"].title,
            message: message
          });
          return false;
        }
      }
      // add #11731_【因島：改良】指示コメント番号の指定方法 end

      // for文の場合$refsが配列になる
      // IP電源自動切り時間
      const ipAutoOffTiming = this.$refs["36"][0].inputValue;
      // IP電源OKモニタ切時間
      const ipMonitorOffTiming = this.$refs["38"][0].inputValue;

      if (ipAutoOffTiming > ipMonitorOffTiming) {
        // IP電源自動切り時間 > IP電源OKモニタ切時間場合
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "警告",
          // message: `「IP電源自動切り時間」は\n「IP電源OKモニタ切り時間」以下の\n値にして下さい`
          title: DIALOG_MESSAGES['00200099'].title,
          message: messageFormat(DIALOG_MESSAGES['00200099'].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
      return ipAutoOffTiming <= ipMonitorOffTiming;
    },
    /**
     * @description ポップオーバーを表示する前に、必要なデータを取得して、
     *              ポップオーバー用フォーマットをコンバートする
     */
    async createPopoverDataMedicineSet() {
      this.medicineSetData = await medicineSet(this.facilityCd).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'createPopoverDataMedicineSet', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        }
      );

      const contentArr = this.medicineSetData.map(item => {
        return {
          value: item.medicineSetCd,
          text: item.medicineSetName
        };
      });
      this.popoverDataMedicineSet.popoverTitleHeader = "薬剤セット";
      this.popoverDataMedicineSet.popoverContentLabel = "薬剤セット名";
      this.popoverDataMedicineSet.popoverContentDataset = contentArr;
      this.showPopoverMedicineSet();
    },

    /**
     * @description ポップオーバーを表示する前に、必要なデータを取得して、
     *              ポップオーバー用フォーマットをコンバートする
     */
    async createPopoverDataMedicine() {
      this.medicineData = await medicine(this.facilityCd).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'createPopoverDataMedicine', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      this.medicineMixData = await medicineMix(this.facilityCd).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'createPopoverDataMedicine', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        }
      );
      const classData = await medicineClass(this.facilityCd).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'async', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        }
      );
      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };
      let filterArr = [];
      filterArr = classData.map(filterMapping);
      filterArr.unshift({ text: "すべて", value: 0 });
      filterArr.push({ text: "未分類", value: null });

      // ポップオーバのコンテンツデータ(フィルターしたデータ)を取りまとめる
      const contentParamIsDisp = item => {
        return item.isDisp === "1";
      };
      const contentMapping = (item, cdKey, nameKey, category) => {
        return {
          // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
          //value: category === "1" ? item[cdKey] : `${item[cdKey]}$`,
          value: category === "1" ? item[cdKey] : `${item[cdKey]}`,
          type: category,
          // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
          fnValue: {
            薬剤区分: category,
            薬剤分類: item.classCd
          },
          text: item[nameKey]
        };
        };
      const medicineList = this.medicineData
        .filter(contentParamIsDisp)
        .map(item => contentMapping(item, "medicineCd", "medicineName", "1"));
      const medicineMixList = this.medicineMixData
        .filter(contentParamIsDisp)
        .map(item =>
          contentMapping(item, "medicineMixCd", "medicineMixName", "2")
        );
      const contentArr = [...medicineList, ...medicineMixList];

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

      this.popoverDataMedicine.popoverTitleHeader = "薬剤";
      this.popoverDataMedicine.popoverContentLabel = "薬剤名";
      this.popoverDataMedicine.popoverContentDataset = contentArr;
      // add #9848+9849 薬剤選択IF，空選択肢なし linjunfeng start
      this.popoverDataMedicine.hasUnregisteredOption = false;
      // add #9848+9849 薬剤選択IF，空選択肢なし linjunfeng end
      this.showPopoverMedicine();
    },

    /**
     * 医療材料の追加.
     * 医療材料選択ボタンポップオーバー(共通部品 医療材料選択(有効なマスタからの選択)用)にてポップオーバー画面の表示.
     */
    async createPopoverDataEquipment() {
      // 選択状態は常にクリアする
      this.popoverDataValidEquipment.popoverContentSelected = {};
      // ホップオーバー画面の表示位置は「追加」ボタン
      this.buttonPosi = "addEquipment";
      //ポップオーバー表示
      this.createPopoverData();
    },

    /**
     * 医療材料の選択.
     * 選択ボタンによる医療材料選択用ポップオーバーを表示する.
     */
     selectEquipment(equipId, equipmentCd, equipType) {
      if (equipId == null) {return;}
      // 選択済医療材料の保持
      this.popoverDataValidEquipment.popoverContentSelected = this.mstEquipmentDialyzerIncludedDeleted.find(
        // ダイアライザの場合のcdは内部展開したコードで比較(例. 10 -> "dialyzer10")
        equipment => equipment.value == encryptPersistentCodeToInternalCd(equipmentCd, equipType)
      );
      // 操作した「選択」ボタンの情報を保持
      this.buttonPosi = equipId;
      //ポップオーバー表示
      this.createPopoverData();
    },

    /**
     * @description 医療材料セット
     *              ポップオーバーを表示する前に、必要なデータを取得して、
     *              ポップオーバー用フォーマットをコンバートする
     */
    async createPopoverDataEquipmentSet() {
      this.equipmentSetData = await equipmentSet(this.facilityCd).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'createPopoverDataEquipmentSet', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        }
      );
      const contentArr = this.equipmentSetData.map(item => {
        return {
          value: item.equipmentSetCd,
          text: item.equipmentSetName
        };
      });
      this.popoverDataEquipmentSet.popoverTitleHeader = "医療材料セット";
      this.popoverDataEquipmentSet.popoverContentLabel = "医療材料セット名";
      this.popoverDataEquipmentSet.popoverContentDataset = contentArr;
      this.showPopoverEquipmentSet();
    },

    /**
     * @description 薬剤セットマスター選択を表示
     */
    showPopoverMedicineSet() {
      this.popoverDataMedicineSet.popoverVisible = true;
    },

    /**
     * @description 薬剤マスター選択を表示
     */
    showPopoverMedicine() {
      this.popoverDataMedicine.popoverVisible = true;
    },

    /**
     * @description 医療材料セットマスター選択を表示
     */
    showPopoverEquipmentSet() {
      this.popoverDataEquipmentSet.popoverVisible = true;
    },

    /**
     * @description 薬剤セットマスター選択を非表示
     */
    closePopoverMedicineSet() {
      this.popoverDataMedicineSet.popoverVisible = false;
    },

    /**
     * @description 薬剤マスター選択を非表示
     */
    closePopoverMedicine() {
      this.popoverDataMedicine.popoverVisible = false;
    },

    /**
     * @description 医療材料セットマスター選択を非表示
     */
    closePopoverEquipmentSet() {
      this.popoverDataEquipmentSet.popoverVisible = false;
    },

    /**
     * @description 医療材料マスター選択を非表示
     */
    closePopoverEquipment() {
      this.closePopover();
    },

    /**
     * @description 薬剤セットマスター選択から選択後のコールバック
     */
    async updateInputMedicineSet(data) {
      const medicineSetData = this.medicineSetData.find(item => {
        return item.medicineSetCd === data.value;
      });
      const medicineSetJson = JSON.parse(medicineSetData.setInfo);
      const medicineData = await medicine(this.facilityCd).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'updateInputMedicineSet', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      const medicineMixData = await medicineMix(this.facilityCd).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MasterModalComponentMstTreatmentSet.vue', 'updateInputMedicineSet', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        }
      );

      if (!medicineSetJson) return
      const listData = medicineSetJson.map(item => {
        const medicineType = Number(item.class);
        // const medicineType = String(item.class);
        let mstMedi = medicineData;
        let mstMediCd = "medicineCd";
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //if (medicineType === "2") {
        if (medicineType == 2) {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          // 調製薬剤
          mstMedi = medicineMixData;
          mstMediCd = "medicineMixCd";
        }
        const med = mstMedi.find(i => {
          return item.cd === i[mstMediCd];
        });

        return {
          id: _.uniqueId("medicine"),
          cd: med && med[mstMediCd],
          unit: med.unit,
          amount: item.amount,
          procedureCd: item.procedure_timing_cd,
          timingCd: item.medicate_timing_cd,
          medicineType
        };
      });

      for (let idx = 0; idx < listData.length; idx++) {
        const data = listData[idx];
        this.medicine.push({
          id: data.id,
          cd: data.cd,
          // 子へ渡すデータ※保存対象外
          unit: data.unit,
          amount: data.amount,
          timingCd: data.timingCd,
          procedureCd: data.procedureCd,
          medicineType: data.medicineType,
          // {comment} add redmine 4903 薬剤のコメントが存在しない 孔
          comment: ""
        });
      }
    },

    /**
     * @description 薬剤マスター選択から選択後のコールバック
     */
    async updateInputMedicine(data) {
      const selectedData = data;
      let mstmedi = [];
      let medicineCdKey = "medicineCd";
      // const medicineType = String(data.value).match(/\$/) ? "2" : "1";
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      //const medicineType = String(data.value).match(/\$/) ? 2 : 1;
      const medicineType = data.type
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤マスタ
        mstmedi = this.medicineMixData;
        medicineCdKey = "medicineMixCd";
        selectedData.value = Number(selectedData.value.split("$")[0]);
      } else {
        mstmedi = this.medicineData;
      }

      const medicineData = mstmedi.find(item => {
        return item[medicineCdKey] === selectedData.value;
      });

      const listData = selectedData.value
        ? {
            id: _.uniqueId("medicine"),
            cd: medicineData[medicineCdKey],
            // 子へ渡すデータ※保存対象外
            unit: medicineData.unit,
            amount: 0,
            timingCd: medicineData.medicateTimingCd,
            procedureCd: medicineData.procedureCd,
            medicineType,
            // {comment} add redmine 4903 薬剤のコメントが存在しない 孔
            comment: ""
          }
        : {
            id: _.uniqueId("medicine"),
            cd: null,
            // 子へ渡すデータ※保存対象外
            unit: null,
            amount: 0,
            timingCd: null,
            procedureCd: null,
            medicineType: null,
            // {comment} add redmine 4903 薬剤のコメントが存在しない 孔
            comment: ""
          };

      this.medicine.push(listData);
    },

    /**
     * @description 医療材料セットマスター選択から選択後のコールバック
     */
    async updateInputEquipmentSet(data) {
      const equipmentSetData = this.equipmentSetData.find(item => {
        return item.equipmentSetCd === data.value;
      });
      const equipmentSetJson = JSON.parse(equipmentSetData.setInfo);
      const listData = equipmentSetJson.map(item => {
        // 医療材料セットの後方互換として医療材料区分なしの部材は医療材料とみなす
        let equip_type = !item.hasOwnProperty('equip_type') ? 0 : item.equip_type;
        return {
          id: _.uniqueId("equipment"),
          cd: item.cd,
          amount: item.amount,
          equipType: equip_type
        };
      });

      // 医療材料セットに紐づく医療材料を追加する
      for (let idx = 0; idx < listData.length; idx++) {
        const data = listData[idx];

        // 医療材料とダイアライザの削除・期限切れを含む全てのマスタデータから部材コード、医療材料区分で引き当てる
        if(this.mstEquipmentDialyzerIncludedDeleted.find(item => {
          return data.cd == decryptDialyzerCdToPersistentCode(item.value) &&
              data.equipType == detectEquipTypeFromCode(item.value);
        })){

          this.equipment.push({
            id: data.id,
            cd: data.cd,
            amount: data.amount,
            equipType: data.equipType
          });
        }
      }
    },

    /**
     * @description 医療材料マスター選択から選択後のコールバック
     */
    updateInputEquipment(data) {
      // 内部展開コードから永続化コードへの変換
      data.cd = decryptDialyzerCdToPersistentCode(data.value);
      data.equipType = detectEquipTypeFromCode(data.value);
      // 医療材料区分の判定の取りこぼし防止
      if (data.fnValue != undefined && data.fnValue['医療材料分類'] == "dialyzer") {
        data.equipType = 1;
      }

      // 治療材料のセットに含まれている医療材料の場合は更新、含まれていなければ追加
      if (this.buttonPosi == "addEquipment") {
        this.equipment.push({
          id: _.uniqueId("equipment"),
          cd: decryptDialyzerCdToPersistentCode(data.value),
          amount: 1,
          equipType: detectEquipTypeFromCode(data.value)
        });
      } else {
        const editIndex = this.equipment.findIndex(item => {
            return item.id == this.buttonPosi;
        });
        if (editIndex > -1) {
          this.$set(this.equipment, editIndex, {
            ...this.equipment[editIndex],
            ...data
          });
        }
      }
      // 編集対象の医療材料のid情報をクリア
      this.buttonPosi = null;
    },

    /**
     * @description indMediInfo(ord_main薬剤情報)に単位がないためDBから取得
     */
    getUnit(mediCd, medicineType) {
      if (this.medicineData.length === 0 && this.medicineMixData === 0) {
        return null;
      }

      let mstMedi = this.medicineData;
      let mstMediCd = "medicineCd";
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤
        mstMedi = this.medicineMixData;
        mstMediCd = "medicineMixCd";
      }

      const mediRecord = mstMedi.find(record => record[mstMediCd] === mediCd);
      return mediRecord ? mediRecord.unit : null;
    },

    /**
     * @description treatCondから引数で指定した治療条件項目番号のデータを返却する
     */
     selectTreatCondByTreatCondNo(no) {
       return this.treatCond.find(cond => {
         return cond.treatCondNo === no;
       });
     },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
    compareObjects(obj1, obj2) {
      if (this.isJSON(obj1)) {
        obj1 = JSON.parse(obj1)
      }
      if (this.isJSON(obj2)) {
        obj2 = JSON.parse(obj2)
      }

      // 基本型(文字列、数字など)の場合は、そのまま等価比較をします。
      if (!this.isObject(obj1)) {
        if (this.isNumber(obj1) && this.isNumber(obj2)) {
          return Number(obj1) == Number(obj2);
        }
        if (obj1 == "" && obj2 == null) {
          return true;
        }
        if (obj1 == "" && isNaN(obj2)) {
          return true;
        }
        return obj1 == obj2;
      }

      if (obj1.length !== obj2.length) {
        return false;
      }
      // 1つ目のオブジェクトの属性名を全て取得します
      const keys = Object.keys(obj1);
      // 属性を横断して深さを比較します
      for (let key of keys) {
        if (["indEquipInfo", "indIndCommentInfo", "indMediInfo"].includes(key) && obj1[key] === "" && obj2[key] === "[]") {
          obj1[key] = "[]";
        }
        if (!this.compareObjects(obj1[key], obj2[key])) {
          return false;
        }
      }
      return true;
    },

    isObject(value) {
      return value && typeof value === 'object';
    },
    isJSON(str) {
      try {
        JSON.parse(str);
        return true;
      } catch (e) {
        return false;
      }
    },
    isNumber(str) {
        return !isNaN(parseFloat(str)) && isFinite(str);
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
  }
};
</script>

<style scoped>
.row-style {
  margin: 2.5px 0px;
}

.layout-name-area,
.disp-item-name-area {
  padding-left: 8px;
  vertical-align: top;
}

.disp-item-no,
.k-textbox {
  width: 100%;
}

.disp-item-content-area {
  overflow-y: scroll;
  height: 100%;
  /* height: 50vh; */
}

.disp-item-content-area ons-row {
  height: auto;
}

.disp-item-area {
  /* height: 90%; */
  /*height: 97%;*/
  height: 99%;
  width: 100%;
  border-collapse: collapse;
}

/* .disp-item-area tr {
  height: 30px;
} */

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr td:first-child {
  border: 1px solid lightgray;
  text-align: left;
  /* mod 治療方法セットマスタ 画面レイアウト修正 start */
  /* width: 25%; */
  width: 15%;
  /* mod 治療方法セットマスタ 画面レイアウト修正 end */
}

.disp-item-area tr td:nth-child(2) {
  border: 1px solid lightgray;
  text-align: left;
}

.cond-title-style {
  color: #fafafa;
  background-color: #333333;
  text-align: left;
  padding: 5px;
}

.cond-td-style {
  border-bottom: 0.5px solid var(--ntss-border-color);
  border-right: 0.5px solid var(--ntss-border-color);
}

.cond-td-style > ons-row {
  border: 1px solid var(--ntss-border-color);
}

.cond-td-style-child {
  padding: 10px 0 10px 10px;
}

.cond-del-style {
  max-width: 25px;
}

.cond-del-style > * {
  height: 100%;
}

.cond-disabled * {
  /* mod 9664補液及び透析液仕様修正します yangqingzhe start */
  /* opacity: 0.5; */
  pointer-events: none;
  background-color: var(--pat-viewer-ind-cond-info-disabled);
  /* mod 9664補液及び透析液仕様修正します yangqingzhe end */
}

.cond-transition-enter-active {
  transition: opacity 0.5s, max-height 0.5s;
}

.cond-transition-enter {
  opacity: 0.5;
  max-height: 0px;
}

.copy-btn {
  float: right;
  color: #fafafa;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  min-width: 5em;
  width: 5em;
  margin-right: 2em;
  margin-bottom: 10px;
}

.ind-comment-create >>> .title-area {
  flex: 0 0 9.4em;
  max-width: 30%;
}

.ind-comment-create >>> .text-area {
  text-align: initial;
  padding-left: 10px;
}
/* mod #11731_【因島：改良】指示コメント番号の指定方法（スペルミス） */
.ind-comment-create >>> .instructionNumber {
  margin: 10px 0;
}

ons-col >>> .action-condition-column {
  flex: 0 0 9.4em;
  max-width: 30%;
}

ons-col >>> .custom-div-show-selected-item{
  width: 100%;
  max-width: 300px;
  margin: 0 5px 0 0;
}

@media screen and (max-width: 685px) {


  select[name="mstModalTreatSetSelect"] {
    padding: 0;
  }

  ons-col >>> .action-condition-column {
    flex: none;
    max-width: 100%;
  }

  ons-col >>> .action-condition-data-column {
    padding-left: 0;
    display: -webkit-box;
    display: -moz-box;
    display: -webkit-flex;
    display: -ms-flexbox;
    display: flex;
    align-items: center;
  }

  ons-col >>> .action-condition-input {
    width: 70%;
    box-sizing: border-box;
    margin: 0;
  }

  ons-col >>> .common-style-select-button {
    /*mod redmine 5078 詳細モーダル内のボタンが大きすぎる 孔 start*/
    /*width: 30% !important;*/
    width: 15% !important;
    /*mod redmine 5078 詳細モーダル内のボタンが大きすぎる 孔 end*/
    box-sizing: border-box;
    min-width: 3.5em !important;
  }

  ons-col >>> .medicine-column {
    flex: none;
    max-width: 100%;
  }

  ons-col >>> .medicine-data-column {
    padding-left: 0;
  }

  ons-col >>> .medicine-input-style {
    width: 70%;
    box-sizing: border-box;
    margin: 0;
  }

  ons-col >>> .equipment-column {
    flex: none;
    max-width: 100%;
  }

  ons-col >>> .equipment-data-column {
    padding-left: 0;
  }

  ons-col >>> .equipment-input-style {
    width: 70%;
    box-sizing: border-box;
    margin: 0;
  }

  .amount-input-style {
    width: 50px;
    padding-left:10px;
  }

  .equipment-input-style {
    width: 70%;
    margin: 0px 5px 0px 0px;
  }

  .ntss-custom-input-cond {
    height: 2em;
    font-size: inherit;
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    display: inline-flex;
  }

  .ind-comment-create >>> .title-area {
        flex: none;
      max-width: 100%;
  }

  .ind-comment-create >>> .text-area {
    text-align: initial;
    padding-left: 0;
  }
}

@media screen and (max-width: 869px) {
  .cond-title-style {
    flex: 0 0 100% !important;
    max-width: unset !important;
  }
}
.p-0 {
  padding: 0;
}

.custom-disp-item-area .k-textbox{
  font-size: unset;
}

.input-required{
  color: black;
  background-color: #ffff99;
}
.input-invalid{
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
/* #11731_【因島：改良】指示コメント番号の指定方法（チェックエラーの背景色） start */
.input-invalid-comment-number >>> .instructionNumber select {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}

.input-invalid-comment-content >>> .instructionComment textarea {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
/* #11731_【因島：改良】指示コメント番号の指定方法 end */

/* add redmine 4901 指示コメント欄が横に広げられない 宋qy start */
.cond-td-style >>> .comTextarea textarea {
  resize: both;
  max-width: 100%;
}
/* add redmine 4901 指示コメント欄が横に広げられない 宋qy end */

.equipment-unit {
  display: block;
  padding: 0.3em;
}
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
::v-deep .com-basic-sub-btn {
    margin-left: 0px
}
::v-deep .com-basic-sub-input {
  min-width: 13em;
  width: 100%;
  max-width: 28em;
  background-color: #f7f7f7;
}
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
