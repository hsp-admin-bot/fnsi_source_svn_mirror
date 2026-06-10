<template>
  <div class="main-area">
    <div class="upper">
      <v-ons-row  class="item-row">
        <v-ons-col class="item-title">処方セット名</v-ons-col>
        <v-ons-col class="item-data item-input">
          <custom-input
            :value="prescriptionSetName"
            :is-required="true"
            maxlength="256"
            @change="onNameChange()"
            @input="warningCancel"
          />
        </v-ons-col>
      </v-ons-row>
      <ons-row class="hospital-cd-row">
        <div class="hospital-cd">
          <ons-col class="item-title">連携コード1</ons-col>
          <ons-col class="item-data">
            <custom-input
              :value="inHospitalCd1"
              @blur="onInHospitalCd1Change()"
              :maxlength="20"
            />
          </ons-col>
        </div>
      
        <div class="hospital-cd">
          <ons-col class="item-title">連携コード2</ons-col>
          <ons-col class="item-data">
            <custom-input
              :value="inHospitalCd2"
              @blur="onInHospitalCd2Change()"
              :maxlength="20"
            />
          </ons-col>
        </div>
      </ons-row>
    </div>
    <!-- 処方エリア -->
    <div ref="prescriptionWrapper" class="prescription-wrapper">
      <div class="prescription-area">
        <v-ons-row class="condition-row">
          <!-- ヘッダ -->
          <v-ons-row>
            <v-ons-col class="custom-btn-area">
              <v-ons-row class="custom-button-figure">
                <v-ons-col class="row-buttons">
                  <span class="row-buttons-span">
                    <label class="label-title"><b>処方</b></label>
                  </span>
                </v-ons-col>
                <v-ons-col style="width: 4.2em;">
                  <v-ons-button
                    ref="prescriptionSetBtn"
                    class="btn3-normal common-style-select-button"
                    @click="createPopoverDataPrescriptionSet($refs.prescriptionSetBtn, getFacilitySwitch, -1)"
                  >処方ｾｯﾄ</v-ons-button>
                </v-ons-col>
                <pop-over
                  v-bind="popoverDataPrescriptionSet"
                  :target-position-element="popoverPrescriptionTarget"
                  @popover-close="closePopoverPrescriptionSet"
                  @popover-return="(data) => {
                    updateInputPrescriptionSet(data, false, getFacilitySwitch);
                  }"
                />
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="custom-input-area">
              <v-ons-row class="custom-element-input-area" style="max-width: 2.5em;"><label class="label-title">後発<br/>不可</label></v-ons-row>
              <v-ons-row class="custom-element-input-area" style="max-width: 2.5em;"><label class="label-title">患者<br/>希望</label></v-ons-row>
              <v-ons-row class="custom-element-input-area"><label class="label-title">薬剤・用法</label></v-ons-row>
              <v-ons-row class="custom-element-input-area" style="max-width: 5em;"><label class="label-title">数量</label></v-ons-row>
              <v-ons-row class="custom-element-input-area" style="max-width: 7em;"><label class="label-title">単位</label></v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- 明細行 -->
          <draggable
              v-model="dataList"
              handle=".dragg"
              v-bind="dragOptions"
              style="width:100%"
              class="draggable-area"
              @start="onDragStart"
              @end="onDragEnd"
              @change="refacterDataList"
              :move="onMove"
          >
            <v-ons-row
                v-for="(item, index) in getEditRecord"
                :key="`${item.uniqueId}-${index}`"
                class="prescription-detail-row"
                :class="{
                  'sortable-chosen': isDraggItem(index),
                  'sortable-related': isGhost(index) && !isDraggItem(index),
                  'ghost': isGhost(index),
                  'master-edited-row': !isEdit || item.isNew
                }"
            >
              <!-- NOTE: 処方列（各ボタン：削除・並び替え・追加のエリア） -->
              <v-ons-col class="custom-btn-area">
                <v-ons-row class="custom-button-figure">
                  <v-ons-col class="row-buttons">
                    <span class="row-buttons-span">
                      <ons-toolbar-button
                        class="close-btn manual-close-btn"
                        style="line-height: 1.875em;"
                        @click="deleteCols(index)"
                      >
                        <ons-icon icon="fa-times"></ons-icon>
                      </ons-toolbar-button>
                      <ons-toolbar-button 
                        class="close-btn manual-close-btn" 
                        :class="{ 'moved-row': isMoved(item.uniqueId) }" 
                      >
                        <ons-icon icon="fa-sort" class="dragg"></ons-icon>
                      </ons-toolbar-button>
                    </span>
                    <v-ons-col>
                      <v-ons-button
                        class="btn3-normal common-style-select-button"
                        @click="showPopoverToChange($event,item.dataButtonName,index)"
                      >{{ item.dataButtonName }}
                      </v-ons-button>
                    </v-ons-col>
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
              <!-- NOTE: 薬剤・用法、数量、単位列 -->
              <v-ons-col class="custom-input-area">
                <v-ons-row
                  class="custom-element-input-area"
                  v-for="(itemChild, i) in item.buttonItems"
                  :style="{ width: itemChild.itemWidth, maxWidth: itemChild.itemMaxWidth, minWidth: itemChild.itemMinWidth }"
                  :key="`${item.index}-${itemChild.itemName}-${item.dataButtonNo}`"
                  :class="{
                    'rx-drug-f1-wrap': item.dataButtonNo === 2 && itemChild.itemName === 'F1',
                    'rx-drug-f2-wrap': item.dataButtonNo === 2 && itemChild.itemName === 'F2'
                  }"
                >
                  <v-ons-col
                    class="custom-checkbox custom-element-input-area-inner"
                    v-if="itemChild.itemName == 'check-box1' && itemChild.type == 'checkBox' && itemChild.hidden == false"
                  >
                    <v-ons-checkbox v-model="itemChild.itemValue"></v-ons-checkbox>
                  </v-ons-col>
                  <v-ons-col
                    class="custom-checkbox custom-element-input-area-inner"
                    v-if="itemChild.itemName == 'check-box2' && itemChild.type == 'checkBox' && itemChild.hidden == false"
                  >
                    <v-ons-checkbox v-model="itemChild.itemValue"></v-ons-checkbox>
                  </v-ons-col>
                  <v-ons-col class="custom-element-input-area-inner" v-else-if="itemChild.type == 'text' && itemChild.hidden == false">
                    <v-ons-input
                      type="text"
                      class="input disabled-input"
                      :class="isEditedDataList(item, itemChild.itemName, 'ons')" 
                      style="width: 100%"
                      :disabled="(itemChild.disabled ? true : false)"
                      v-model="itemChild.itemValue"
                    ></v-ons-input>
                  </v-ons-col>
                  <v-ons-col class="col-rp custom-element-input-area-inner" v-else-if="itemChild.type == 'text-readonly' && itemChild.hidden == false">
                    <ons-toolbar-button class="toolbar-button-rp">
                      <ons-icon icon="fa-sort" class="dragg dragg-rp"></ons-icon>
                    </ons-toolbar-button>
                    <v-ons-input
                      type="text"
                      class="input rp-input disabled-input"
                      :disabled="(itemChild.disabled ? true : false)"
                      :value="'Rp'+itemChild.itemValue"
                    ></v-ons-input>
                  </v-ons-col>
                  <v-ons-col v-else-if="itemChild.type == 'button' && itemChild.hidden == false" class="custom-element-input-area-inner">
                    <v-ons-button
                      class="btn3-normal common-style-select-button"
                      @click="showModal(index)"
                    >選択</v-ons-button>
                  </v-ons-col>
                  <v-ons-col
                    v-else-if="itemChild.type == 'dataList' && itemChild.hidden == false && itemChild.itemName == 'F6' && item.dataButtonNo != 2"
                    class="datalist custom-element-input-area-inner"
                  >
                    <v-ons-select
                      :id="`myDropdown${index}-list`"
                      v-model="itemChild.itemValue"
                      data-non-authorize="true"
                      style="width:-webkit-fill-available;"
                      @change="onOpen(index)"
                      :class="isEditedDataList(item, itemChild.itemName, 'ons')">
                      <template v-for="item in timeList">
                        <option :key="item" :value="item">{{ item }}</option>
                      </template>
                    </v-ons-select>
                  </v-ons-col>
                  <v-ons-col
                    v-else-if="itemChild.type == 'dataList' && itemChild.hidden == false && itemChild.listClass != null"
                    class="datalist position-input custom-element-input-area-inner"
                  >
                    <div class="position-relative" style="width:-webkit-fill-available;">
                      <input
                        :id="'input-' + index + '-' + i"
                        type="text"
                        autocomplete="off"
                        v-model="itemChild.itemValue"
                        style="width:-webkit-fill-available;"
                        :class="[!itemChild.showSelectFlagdouble ? '' : 'select-inputcolor', isEditedDataList(item, itemChild.itemName)]"
                        @focus="changeListInput(index, i, 'focus')"
                        @blur="listBlur(itemChild.itemValue, index, i)"
                        @input="inputChange(itemChild.itemValue, listDetailMedicine(itemChild.listClass))">
                      <span
                        class="k-icon down-arrow"
                        id="myInput"
                        @mousedown="changeListInput(index, i, 'mousedown')"
                      ></span>
                    </div>
                    <ul class="form-ul" style="width:-webkit-fill-available;" v-if="itemChild.showSelectFlag">
                      <li
                        id="myElement"
                        v-for="(item, idx) in arrFlag ? arr : listDetailMedicine(itemChild.listClass)"
                        :key="idx"
                        :class="[itemChild.itemValue == item && colorFlag ? 'bacground-highlight' : 'bacground-color', !itemChild.showSelectFlagdouble ? 'colora' : 'colorb']"
                        v-show="!emptyFlag"
                        @mousedown="itemChild.itemValue = item; itemChild.showSelectFlag = (itemChild.showSelectFlag ? false : true)"
                        @mouseover="mouseover"
                      >{{ item }}</li>
                      <div class="empty-style" v-show="emptyFlag">NO DATA FOUND</div>
                    </ul>
                  </v-ons-col>
                  <v-ons-col
                    v-else-if="itemChild.type == 'dataList' && itemChild.hidden == false"
                    class="datalist custom-element-input-area-inner"
                  >
                    <v-ons-select
                        :id="`myDropdown${index}-list`"
                        v-model="itemChild.itemValue"
                        data-non-authorize="true"
                        style="width:-webkit-fill-available;"
                        :class="isEditedDataList(item, itemChild.itemName, 'ons')"
                        @change="onOpen(index)"
                    >
                      <template v-for="item in getUnit(itemChild.dataList)">
                        <option :key="item" :value="item">{{ item }}</option>
                      </template>
                    </v-ons-select>
                  </v-ons-col>
                  <v-ons-col v-else-if="itemChild.type == 'number' && itemChild.hidden == false" style="display:flex; justify-content: center; align-items: center; margin-left: 5px;">
                    <v-ons-input
                      :id="'number-' + index + '-' + i"
                      type="number"
                      class="input number-input"
                      :class="isEditedDataList(item, itemChild.itemName, 'ons')"
                      style="width:100%"
                      :step="unitStep(itemChild.unitDecimalPoint)"
                      :disabled="(itemChild.disabled ? true : false)"
                      v-model="itemChild.itemValue"
                      @change="changeValuePoint(itemChild.unitDecimalPoint,index, i, $event)"
                      @mousewheel.prevent="stopScrollFun(index, i, $event)"
                      @blur="formatValue(index, i, $event)"
                      @focus="handleFocus(i)"
                    ></v-ons-input>
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </draggable>
          <!-- 余白行 -->
          <v-ons-row>
            <v-ons-col class="custom-btn-area">
              <v-ons-row class="custom-button-figure">
                <v-ons-col class="row-buttons">
                    <span class="row-buttons-span"></span>
                  <v-ons-col>
                    <v-ons-button
                      class="btn3-normal common-style-select-button"
                      @click="showPopoverToAdd($event)"
                    >追加</v-ons-button>
                    <v-ons-popover
                      cancelable
                      :visible.sync="popoverVisible"
                      :target="popoverTarget"
                      :direction="popoverDirection"
                      :cover-target="false"
                      :class="[fontSizeSet, 'grid']"
                      @preshow="popoverPreShow"
                      @postshow="popoverPostShow"
                      @posthide="popoverPosthide"
                    >
                      <div v-for="(item, index) in listButton" :key="index" class="grid-item">
                        <v-ons-button
                          class="button btn3-normal"
                          style="width:100%;"
                          @click="onClickButton(item, popoverTarget, getFacilitySwitch)"
                        >
                          {{ item }}
                        </v-ons-button>
                      </div>
                    </v-ons-popover>
                  </v-ons-col>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col vertical-align="center" class="custom-input-area">
            </v-ons-col>
          </v-ons-row>        
        </v-ons-row>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import vuedraggable from "vuedraggable";
import { ApiHelper } from "@/apis/AxiosHelper";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import PatPrescriptionMixin from "@/components/pat-prescription/PatPrescriptionMixin";
import PopoverMixin from "@/components/PopoverMixin";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import {
  popoverPostShow,
  popoverPosthide,
  popoverPreShow
} from "@/functions/common/CommonPopoverFunctions";
import { EventBus } from "@/eventBus";

export default {
  mixins: [MasterMaintenanceMixin, PopoverMixin, PatPrescriptionMixin],
  props: ["propsIsHideMainList"],
  components: {
    "custom-input": customInput,
    "draggable": vuedraggable,
    "pop-over": MasterSelector,
  },

  data() {
    return {
      // 処方セット名
      prescriptionSetName: { initValue: "", editValue: "" },
      // 連携コード1、2
      inHospitalCd1: { initValue: "", editValue: "" },
      inHospitalCd2: { initValue: "", editValue: "" },
      // 変更ありフラグ
      isChangedUpper: false,
      
      // 処方エリアはPatPrescriptionMixinで定義
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getMasterEditRecord: "getEditRecord", 
      getFacilitySwitch: "getFacilitySwitch"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    ...mapGetters("pat-prescription", [
      "getIsChanged",
      "getEditRecord",
      "getOriginalEditRecord",
      "getListTakeMedicine",
      "getPrescriptionDetail",
    ]),
    /**
     * 編集モードか否か
     */
    isEdit() {
      return this.getMasterEditRecord.operation !== 1 || this.getPrescriptionDetail.length > 0;
    }
  },
  
  async created() {
    this.setLoadingScreenVisible(true);
    
    /** 初期値を設定 */
    // 処方セット名
    this.prescriptionSetName.initValue = this.prescriptionSetName.editValue = this.getMasterEditRecord.name !== null ? this.getMasterEditRecord.name : "";
    // セット情報
    if (this.getMasterEditRecord.setInfo) {
      this.setPrescriptionDetail(JSON.parse(this.getMasterEditRecord.setInfo));
    }
    // 連携コード1
    this.inHospitalCd1.initValue = this.inHospitalCd1.editValue = this.getMasterEditRecord.inHospitalCd1 !== null ? this.getMasterEditRecord.inHospitalCd1 : "";
    // 連携コード2
    this.inHospitalCd2.initValue = this.inHospitalCd2.editValue = this.getMasterEditRecord.inHospitalCd2 !== null ? this.getMasterEditRecord.inHospitalCd2 : "";
    
    // 処方エリアの初期処理
    await this.init();
    
    this.setLoadingScreenVisible(false);
  },
  mounted() {
    window.addEventListener("resize", this.calculateGridHeight, false);
    document.addEventListener("mousedown", this.handleMousedown);
    
    // モーダル画面の高さ調整
    this.calculateGridHeight();
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.calculateGridHeight, false);
    document.removeEventListener("mousedown", this.handleMousedown);
  },
  watch: {
    getFontSize() {
      this.calculateGridHeight();
    },
    /** 処方セット情報の変更 */
    getEditRecord: {
      handler() {
        this.updateEditRecord("setInfo");
      },
      deep: true
    },
  },
  methods: {
    ...mapActions("master-maintenance", {
      setMasterEditRecord: "setEditRecord"
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("pat-prescription", [
      "setEditRecord",
      "setOriginalEditRecord",
      "setIndexRow",
      "setTakeMedicine",
    ]),
    ...mapActions("multi-sub-modal", ["showPatPrescriptionSelectDrugSub"]),   
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    
    /** 薬剤選択IFを表示する */
    async showModal(index) {
      this.setIndexRow(index);
      await this.showPatPrescriptionSelectDrugSub();
    },
    /** 処方エリアの初期処理 */
    async init() {
      // 薬剤マスタ、一般名処方マスタ(削除済みを含む)を取得
      const [ medicineRes, genericMedicineRes ] = await Promise.all([
        ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", { facilityCd: this.getFacilitySwitch }),
        ApiHelper.get("/mstInfo/sysGenericMedicineIncludeDeleted"),
        this.setTakeMedicine(this.getFacilitySwitch)
      ]);   
         
      this.mstMedicine = medicineRes.data;
      this.sysGenericMedicine = genericMedicineRes.data;

      // 用法・用語マスタを取得
      this.listTakeMedicine = this.getListTakeMedicine;
      

      if (!this.isEdit) {
        // 新規追加
        this.getDataList();
      } else {
        // 編集
        this.changeFormatData(0);
      }
      this.refacterDataList();
      
      // 初期値退避
      this.setOriginalEditRecord(deepCopy(this.dataList));

      this.blockUnecessaryDigit();
    },
    /**
     * 処方エリア 編集未保存スタイルを適用
     * @param {String} item 行オブジェクト
     * @param {String} itemName 項目名
     * @param {String} elementType onsen ui の場合は"ons"が設定される
     */
    isEditedDataList(item, itemName, elementType) {
      
      if (this.isEdit && Object.keys(this.getOriginalEditRecord).length === 0) return;
      
      // リスト各項目の値取得 関数
      const getItemValue = (records, uniqueId, dataButtonNo, itemName) => {
        const record = records.find(item => item.uniqueId === uniqueId && item.dataButtonNo === dataButtonNo);
        const buttonItem = record?.buttonItems?.find(button => button.itemName === itemName);
        // itemValueCd（薬剤）が存在する場合はitemValueCdを返す
        const value = buttonItem?.itemValueCd !== undefined ? buttonItem.itemValueCd : buttonItem?.itemValue;
        // itemValueCd、itemValueがundefinedの場合は追加行のため"isNew"を返す
        return value !== undefined ? value : "";
      };

      // this.getOriginalEditRecord: 編集前、this.getEditRecord: 編集後
      let beforeVal = this.isEdit ? getItemValue(this.getOriginalEditRecord, item.uniqueId, item.dataButtonNo, itemName) : ""; // 新規作成の場合は""
      let afterVal = getItemValue(this.getEditRecord, item.uniqueId, item.dataButtonNo, itemName);
      
      // 変更があればクラスを適用
      const className = elementType === "ons" ? "ons-element-edited" : "custom-element-edited";
      return beforeVal !== afterVal ? className : "";
    },
   
    /**
     * 処方エリアの高さ調整
     */
    calculateGridHeight(){
      // 10は画面下部の余白
      const newHeight = document.getElementsByClassName("modal-body")[0].clientHeight - document.getElementsByClassName("upper")[0].clientHeight - 10;
      document.getElementsByClassName("prescription-wrapper")[0].style.height = newHeight + "px"
    },

    /** 確定ボタンの活性or非活性 */
    emitNotChangedState(state) {
      EventBus.$emit("mstHolidayRegistered", state);
    },
    
    /** 各項目の値反映 */
    // 処方セット名
    onNameChange() {
      this.prescriptionSetName.editValue = this.prescriptionSetName.editValue !== null ? this.prescriptionSetName.editValue : "";
      this.updateEditRecord("name", this.prescriptionSetName);
    },
    // 連携コード1
    onInHospitalCd1Change() {
      this.inHospitalCd1.editValue = this.inHospitalCd1.editValue !== null ? this.inHospitalCd1.editValue : "";
      this.updateEditRecord("inHospitalCd1", this.inHospitalCd1);
    },
    // 連携コード2
    onInHospitalCd2Change() {
      this.inHospitalCd2.editValue = this.inHospitalCd2.editValue !== null ? this.inHospitalCd2.editValue : "";
      this.updateEditRecord("inHospitalCd2", this.inHospitalCd2);
    },
    /** マスタの編集レコード更新 */
    updateEditRecord(key, value) {
      if (key === "setInfo") {
        // セット情報
        this.getMasterEditRecord[key] = JSON.stringify(this.convertData());
      } else {
        // 処方セット名、連携コード1、連携コード2
        this.isChangedUpper = value.initValue !== value.editValue;
        this.getMasterEditRecord[key] = value.editValue;
      }
      // 確定ボタンの活性or非活性
      const changed = this.getIsChanged || this.isChangedUpper;
      this.emitNotChangedState(!changed);
      
      // 編集レコード更新
      this.setMasterEditRecord(this.getMasterEditRecord);
    },
    /**
     * 入力チェック
     */
    validateData() {
      // 処方セット名
      const name = this.prescriptionSetName.editValue;
      return {
        nameValid: name !== null && name !== "" // 処方セット名：必須チェック
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        // 全てチェックOK
        return true;
      }
      
      const message = `
          ${
            !validationResult.nameValid
              ? messageFormat(messageFormat(DIALOG_MESSAGES["00200162"].message, "処方セット名", "処方セット名"))
              : ""
          }
        `;

      if(!validationResult.nameValid) {
        document.getElementsByClassName("custom-input-required")[0]?.classList?.add("custom-input-invalid");
      }
      // ダイアログ表示
      this.$ons.notification.alert({
        title: DIALOG_MESSAGES["00200162"].title,
        message: message
      });
      return false;
    },
    /** エラースタイルを解除する */
    warningCancel() {
      document.getElementsByClassName("custom-input-required")[0].classList.remove("custom-input-invalid");
    }, 
  }
};
</script>

<style>
  /* 吹き出し */
  .popover__content hr {
    width: 100%;
  }
  .popover__content ons-row {
    height: auto;
  }
</style>

<style scoped>
/* 処方セット名、連携コード1、2のスタイル */
@media (max-width: 420px) {
  .hospital-cd {
    flex-direction: column;
    align-items: unset !important;
  }
  .hospital-cd .item-title {
    flex: none !important;
    width: auto;
    margin-bottom: 4px;
  }
  .hospital-cd-row {
    justify-content: flex-start;
    gap: 15px;
  }
}
.upper {
  border-bottom: 1px solid #8a8a8a;
}
.item-input {
  flex: 0 0 78%;
}
.item-row {
  display: flex;
}
.hospital-cd-row {
  display: flex;
  gap: 15px;            /* 連携コード1と2の間隔 */
  margin: 15px 0;
  flex-wrap: wrap;
}
.hospital-cd {
  display: flex;
  align-items: center;
  flex: 1 1 360px;
}
.item-title {
  flex: 0 0 160px;
  white-space: nowrap;
}
.item-data {
  flex: 1;
  min-width: 200px;
}
/* 入力コンポーネントを親幅いっぱいにする */
.item-input,
.ntss-custom-input {
  width: 100%;
}
.ntss-custom-input input {
  width: 100%;
}

/* 処方エリアのスタイル start */
.prescription-wrapper {
  overflow: auto;
}
.prescription-area {
  padding: 5px;
  min-width: 50em;
  margin-left: 10px;
}
ons-row {
  width: 100%;
  height: auto;
}
.select {
  vertical-align: middle;
}
.input {
  vertical-align: middle;
  background-color: white;
}
.input >>> .text-input {
  height: 2em;
  line-height: 2em;
}
.input >>> .text-input:disabled {
  opacity: 1;
}
ons-input#add >>> input {
  text-align: center;
}
ons-popover >>> div {
  display: flex;
  flex-wrap: wrap;
  padding: 5px;
}
.grid-item {
  flex-grow: 1;
  min-width: 45%;
}

label {
  color: var(--ntss-base-color);
}
.rp-input >>> input {
  background-color: #ddd;
}
.add-btn >>> input {
  background-color: #ddd;
}
.select-input {
  height: 100%;
  width: 100%;
}
.condition-row {
  width: 100%;
  float: left;
}
.col-rp {
  display: flex;
  align-items: center;
}
.disabled-input >>> .text-input:disabled {
  opacity: 1;
  border: 0.5px solid rgb(169,169,169);
}
.rp-input {
  flex: 1;
  min-width: 0;
}
@media screen and (max-width: 1024px) {
  .btn3-normal {
    width: 4.0em;
  }
}
.datalist >>> input::-webkit-calendar-picker-indicator {
  display: none;
}
.datalist >>> input {
  background-color: #F7F7F7
}
.datalist {
  display: flex;
  justify-content: center;
  align-items: center;
}
.number-input >>> input{
  background-color: #F7F7F7;
}
.row-buttons {
  width: 15%;
  display: flex;
}
.toolbar-button {
  padding: 5px 13%;
}

.toolbar-button-rp {
  padding: 5px;
  margin-right: 3px;
}
.toolbar-button--material {
  margin: 0 7% !important;
  padding: 0 !important;
}
.row-buttons-span {
  width: 4em;
  text-align: center;
}
@media screen and (max-width: 1200px) {
  .label-title {
    line-height: 1.5em;
  }
}
@media screen and (max-width: 1440px) and (min-width: 1200px) {
  .label-title {
    line-height: 1.5em;
  }
}
.custom-button-figure ons-col{
  display: flex;
  justify-content: center;
  align-items: center;
}
.custom-btn-area {
  max-width: 8em;
  display: flex;
  justify-content: center;
  align-items: center;
}
.custom-input-area {
  height: 3.0rem;
  display: flex;
  justify-content: flex-start;
}
.custom-element-input-area {
  display: flex;
  align-items: center;
  justify-content: center;
}
.custom-element-input-area-inner {
  margin-left: 5px;
}
.custom-checkbox {
  display: flex;
  align-items: center;
  justify-content: center;
}
::v-deep .k-button {
  background: #fff;
  border: none;
  box-shadow: none;
}
.form-ul {
  list-style: none;
  padding: 0;
  margin: 0;
  position: absolute;
  top: 35px;
  width: 200px;
  z-index: 100;
  border: 1px solid #bababa;
  overflow: auto;
  min-height: 30px;
  max-height: 200px;
  background: #fff;
  text-align: left;
}
li {
  padding: 0;
  padding-left: 2px;
  cursor: pointer;
  text-align: left;
  min-height: 22px;
}
.position-input {
  position: relative;
}
.empty-style {
  text-align: center;
  line-height: 100px;
}
.bacground-color:hover {
  background: #0090ff;
  color: white;
}
.bacground-highlight {
  background: #0090ff;
}
.down-arrow {
  position: absolute;
  top: 50%;
  right: 2px;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-left: 6px solid transparent;
  border-right: 6px solid transparent;
  border-top: 6px solid #757575;
}
.position-relative {
  position: relative;
}
.colora {
  color: black;
}
.colorb {
  color: #55953B;
}
.select-inputcolor {
  border: 2px solid#55953B;
  color: #55953B;
  font-weight: bold;
}

/* ドラッグしている要素のghost */
.ghost {
  opacity: 0.5;
}
.moved-row {
  background-color: #ccffcc;
}
.custom-element-edited {
  color: green;
  border: 2px green solid !important;
}

/* 明細行：ボタン列 + 入力列 */
.prescription-detail-row {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
  width: 100%;
}
/* 左：処方列（削除/並び替え/追加ボタンのエリア）を固定幅に */
.prescription-detail-row > .custom-btn-area {
  flex: 0 0 8em;
  max-width: 8em;
}
/* 右：薬剤・用法、数量、単位列は残り幅を全部使う */
.prescription-detail-row > .custom-input-area {
  flex: 1 1 auto;
  min-width: 0;
}

/* NOTE: 区分「薬剤のF1/F2」用「ons-row width:100%」対応 */
.rx-drug-f1-wrap,
.rx-drug-f2-wrap {
  width: auto !important;
  flex-basis: 0 !important;
  min-width: 0;
}
.rx-drug-f1-wrap { flex: 2 1 0 !important; }
.rx-drug-f2-wrap { flex: 1 1 0 !important; }
.btn-prescription-set {
    background-color: var(--btn1-execute-color) !important;
    background-image: none !important;
}
/* 処方エリアのスタイル end */

</style>
