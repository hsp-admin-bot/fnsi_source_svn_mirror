/**
 * マスタ編集（愁訴処置マスタ）の処置マスタ編集モーダル
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body">
      <div class="expandable-content">
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <!-- mod 愁訴処置マスタ 4・愁訴名→愁訴 処置名→処置に文言修正 孔 start -->
            <!--<label>処置内容</label>-->
            <label>処置</label>
            <!-- mod 愁訴処置マスタ 4・愁訴名→愁訴 処置名→処置に文言修正 孔 end -->
          </v-ons-col>
          <v-ons-col>
            <!-- mod #7727 処置薬剤と数量は必須であってはいけない。start -->
            <!-- <com-textarea
              :content="actualModel.treatment"
              idTextarea="com-textarea-treatment"
              propMaxlength="256"
              rows="3"
              refProp="treatment"
              cssClass="textarea-custom-text-font textarea-resize-vertical"
              class="input_change input-required"
              @set-content-data="setContentData"
              @input="setCss($event.target.value)"
            /> -->
            <com-textarea
              :content="actualModel.treatment"
              idTextarea="com-textarea-treatment"
              propMaxlength="256"
              rows="3"
              refProp="treatment"
              cssClass="textarea-custom-text-font textarea-resize-vertical"
              class=""
              @set-content-data="setContentData"
            />
            <!-- mod #7727 処置薬剤と数量は必須であってはいけない。end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col vertical-align="center">
            <com-master-selector
              class="treat-medicine-selector"
              labelName="処置薬剤"
              :showClassFilter="true"
              :readMasterData="fetchMedicineAllByFacilityCd"
              :masterDefine="treatMedicineMasterDef"
              v-model="selectedTreatMedicine.model"
              @input="onSelectTreatMedicine"
              @changeUnit="(unit) => actualModel.treatMedicine.unit = unit"
              @changeDecPoint="(decPoint) => actualModel.treatMedicine.decPoint = decPoint"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col>
            <!-- mod #5589  2023/04/14 数値IFのスタイル全不正 林峻峰 start -->
            <!-- <com-number-input
              class="number-input input-required input_change"
              style="margin-top: 0;"
              input-id="amount"
              name="amount"
              labelName="数量"
              :step="this.unitStep"
              :min="0"
              :max="9999999999.999999999"
              :unitName="actualModel.treatMedicine.unit"
              :disabled="actualModel.isTreatment"
              :initialValueLock="true"
              v-model="actualModel.amount"
              @input.native="setCss2($event)"
            /> -->
             <com-number-input
              class="number-input input-required input_change"
              style="margin-top: 0;"
              input-id="amount"
              labelName="数量"
              name="amount"
              :step="this.unitStep"
              :unitName="actualModel.treatMedicine.unit"
              :disabled="actualModel.isTreatment"
              :initialValueLock="true"
              :inputType="'number'"
              :inputTextAlign="'right'"
              :inputMin="0"
              :inputMax="9999999999.999999999"
              v-model="actualModel.amount"
              @input.native="setCss2($event)"
            />
            <!-- mod #5589  2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>手技</label>
          </v-ons-col>
          <v-ons-col>
            <v-ons-select
              class="selectbox"
              select-id="procedure-cd"
              name="procedure-cd"
              v-model="selectedProcedureIndex"
              :disabled="actualModel.isTreatment"
              @change="onSelectProcedure()"
            >
              <option
                v-for="(item, index) in comboList.procedure"
                :key="index"
                :value="index"
                :hidden="item.hidden"
                :disabled="item.hidden"
              >{{ item.text }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>利用開始日A</label>
          </v-ons-col>
          <v-ons-col>
            <div class="flex-align-center">
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
              <!-- <input class="inhosp-style ntss-input-date" v-model="inHospAStartdate" type="date" ref="inHospAStartdate" /> -->
              <date-input :classes="'inhosp-style ntss-input-date'" v-model="inHospAStartdate" ref="inHospAStartdate" @handleClearInput="actualModel.inHospAStartdate = null" />
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="inHospAStartdate" />
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードA-1</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdA1"
              type="text"
              ref="inhospitalCdA1"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードA-2</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdA2"
              type="text"
              ref="inhospitalCdA2"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードA-3</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdA3"
              type="text"
              ref="inhospitalCdA3"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードA-4</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdA4"
              type="text"
              ref="inhospitalCdA4"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>利用開始日B</label>
          </v-ons-col>
          <v-ons-col>
            <div class="flex-align-center">
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
              <!-- <input class="inhosp-style ntss-input-date" v-model="inHospBStartdate" type="date" ref="inHospBStartdate" /> -->
              <date-input :classes="'inhosp-style ntss-input-date'" v-model="inHospBStartdate" @handleClearInput="actualModel.inHospBStartdate = null" />
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="inHospBStartdate" />
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードB-1</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdB1"
              type="text"
              ref="inhospitalCdB1"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードB-2</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdB2"
              type="text"
              ref="inhospitalCdB2"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードB-3</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdB3"
              type="text"
              ref="inhospitalCdB3"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コードB-4</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCdB4"
              type="text"
              ref="inhospitalCdB4"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <!-- TODO 用法マスタが存在しないので非表示
        <v-ons-row>
          <v-ons-col width="30%">
            <label>用法</label>
          </v-ons-col>
          <v-ons-col>
            <v-ons-select
              class="selectbox"
              select-id="take-medicine-cd"
              v-model="selectedTakeMedicineIndex"
              name="take-medicine-cd"
              @change="onSelectTakeMedicine()"
              >
              <option v-for="(item, index) in comboList.takeMedicine" :key="index" :value="index" :hidden="item.hidden" :disabled="item.hidden">
                {{ item.text }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        -->
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="cancel">
          キャンセル
        </v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button
          :disabled="!isChanged"
          class="button registration-btn common-style-select-button"
          @click="reflect"
        >
          確定
        </v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import MstComplaintComponentMixin from "@/components/master-maintenance/mst-complaint/MstComplaintComponentMixin";
import CommonMasterSelectorComponent from "@/components/master-maintenance/mst-complaint/modal/MstComplaintModalSelectorComponent";
import {
  treatMedicine,
  procedure
} from "@/components/common/master-selector/MasterSelectorDefinitions";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import { Master } from "@/models/common/master-selector-condition/Master";
import { MstCompTreatment } from "@/models/master-maintenance/mst-complaint/MstCompTreatment";
import moment from "moment";
import BigNumber from "bignumber.js";
import { CODES } from "@/constants/TreatmentRecord";
import CommonTextArea from "@/components/common/CommonTextArea";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/18 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/18 ×を常に表示するように修正 張博 end
import { replaceNullWithEmptyString } from "@/utils/util.js";

export default {
  mixins: [MultiModalMixin, MstComplaintComponentMixin],
  components: {
    "common-calendar": commonCalender,
    "modal-base": ModalBase,
    "com-master-selector": CommonMasterSelectorComponent,
    "com-number-input": CommonNumberInputComponent,
    "com-textarea": CommonTextArea,
    //#5590 2023/04/18 ×を常に表示するように修正 張博 start
    DateInput,
    //#5590 2023/04/18 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      actualModel: new MstCompTreatment(),
      comparisonModel: {},
      treatMedicineMasterDef: treatMedicine,
      selectedTreatMedicine: {
        unit: "",
        model: new Master()
      },
      procedureMasterDef: procedure,
      selectedProcedureIndex: 0,
      // TODO 用法マスタが存在しない
      // selectedTakeMedicineIndex: 0,
      comboList: {
        // TODO 処置区分 コード定義
        procedure: []
        // TODO 用法マスタが存在しない
        // takeMedicine: []
      },
      // mod #5589  2023/04/14 数値IFのスタイル全不正 林峻峰 start
      min:0,
      max:9999999999,
      // mod #5589  2023/04/14 数値IFのスタイル全不正 林峻峰 end
    };
  },
  methods: {
    ...mapGetters("mst-complaint", ["getMstCompTreatmentEdit"]),
    ...mapActions("mst-complaint", ["setMstCompTreatmentEdit"]),
    ...mapActions("reference-combo", ["getProcedureComboListByFacilityCd"]),
    fetchMedicineAllByFacilityCd() {
      return this.fetchMedicineAll(this.getFacilitySwitch);
    },
    /**
     * 初期処理.
     */
    async init() {
      // 手技コンボデータ取得
      const emptyOption = { text: null, cd: null };
      const response = await this.getProcedureComboListByFacilityCd(this.getFacilitySwitch);
      const medicineAndClassResponse = await this.fetchMedicineAll(this.getFacilitySwitch);
      this.comboList.procedure = [emptyOption].concat(response.data);
      // TODO 用法マスタコンボデータ取得
      // this.comboList.takeMedicine = [emptyOption];
      // this.rebuildComboList(this.comboList.takeMedicine, this.comparisonModel.takeMedicine);

      this.$nextTick(() => {
        // 編集対象のモデルをストアより取得
        this.comparisonModel = this.getMstCompTreatmentEdit();

        // 削除済みマスタの再設定
        this.rebuildComboList(this.comboList.procedure, this.comparisonModel.procedure);

        // 最新の薬剤を取得
        const medicine = medicineAndClassResponse[0].data;
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        const filtered = medicineAndClassResponse[2].data.lists.list3.items.filter(item => item.isDisp == 1 && item.isDel == 0);
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        // 薬剤マスタ or 調整薬剤マスタ
        let treatMedicine = null;
        const mstMedicine = medicine.filter(m => {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //return m.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd;
          return m.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        });
        const mstMedicineMix = medicine.filter(m => {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //return m.medicineType === CODES.MEDICINE_TYPE.MIX.cd;
          return m.medicineType == CODES.MEDICINE_TYPE.MIX.cd;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        });

        // 薬剤区分によるマスタ
        if(this.comparisonModel.treatClass === CODES.TREATMENT_CLASS.MIX.cd){
          treatMedicine = mstMedicineMix.find(
            medi => medi.medicineCd === this.comparisonModel.treatMedicine.code
          );
        }else if(this.comparisonModel.treatClass === CODES.TREATMENT_CLASS.NORMAL.cd){
          treatMedicine = mstMedicine.find(
            medi => medi.medicineCd === this.comparisonModel.treatMedicine.code
          );
        }

        // 薬剤コードに該当する薬剤マスタがある場合
        if (treatMedicine) {
          this.comparisonModel.treatMedicine.decPoint = treatMedicine ? treatMedicine.unitDecimalPoint : 0;
        }

        // Objectを保有しておりObject.assignはシャローコピーになるので一旦一つずつコピー
        this.actualModel = new MstCompTreatment();
        this.deepCopyMstCompTreatment(this.actualModel, this.comparisonModel, true);
        if (this.comparisonModel.treatClass === CODES.TREATMENT_CLASS.MIX.cd) {
          // 調製薬剤の場合、cdの後ろに"$"をつける
          //this.selectedTreatMedicine.model.cd = this.comparisonModel.treatMedicine.code + "$";
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
          this.selectedTreatMedicine.model.cd = this.comparisonModel.treatMedicine.code;
          this.selectedTreatMedicine.model.type = '2'

        } else {
          this.selectedTreatMedicine.model.cd = this.comparisonModel.treatMedicine.code;
          this.selectedTreatMedicine.model.type = '1'

        }
        this.selectedTreatMedicine.model.name = this.comparisonModel.treatMedicine.name;
        this.selectedTreatMedicine.model.initCd = this.comparisonModel.treatMedicine.code;
        this.selectedTreatMedicine.model.initName = this.comparisonModel.treatMedicine.name;
        this.selectedTreatMedicine.model.unit = this.comparisonModel.treatMedicine.unit;
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        this.selectedTreatMedicine.unit = this.comparisonModel.treatMedicine.unit;
        this.selectedProcedureIndex = this.comboList.procedure.findIndex(item => item.cd === this.comparisonModel.procedure.code);
      });
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      if (this.isChanged) {
        this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              this.hideModal();
            }
          }
        });
        return;
      }
      this.hideModal();
    },
    /**
     * 確定ボタン押下時イベント処理
     */
    reflect() {
      if (!this.isValid()) {
        // バリデーションエラー
        return;
      }
      if (this.isChanged) {
        // 修正ありにする
        this.actualModel.updated();

        // 数量値をゼロ埋めし直す
        if(this.actualModel.treatMedicine && this.actualModel.treatMedicine.decPoint){
        let numbers = String(this.actualModel.amount).split('.');
        let decPoint = (numbers[1]) ? numbers[1].length : 0;
          if(decPoint > this.actualModel.treatMedicine.decPoint){
            this.actualModel.amount = BigNumber(1 * this.actualModel.amount).toFixed();
          }else{
            this.actualModel.amount = BigNumber(1 * this.actualModel.amount).toFixed(this.actualModel.treatMedicine.decPoint);
          }
        }
        // 入力した内容を反映
        // Objectを保有しておりObject.assignはシャローコピーになるので一旦一つずつコピー
        if (!this.compareData(this.comparisonModel, this.actualModel)) {
          this.deepCopyMstCompTreatment(this.comparisonModel, this.actualModel, false);
        }
      }
      this.hideModal();
    },
    /**
     * 処置薬剤選択イベント処理
     */
    onSelectTreatMedicine() {
      // 選択された薬剤コードが数値ではない場合、調整薬剤とする.
      let medicineCd;
      if (this.selectedTreatMedicine.model.cd === null) {
        // 薬剤で未登録選択時 → 処置
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //this.actualModel.treatClass = "2";
        this.actualModel.treatClass = 2;
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        this.clearMedicineItems();
      } else {
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        //if (isNaN(this.selectedTreatMedicine.model.cd)) {
          if (this.selectedTreatMedicine.model.type == 2) {
          // 調製薬剤
          //medicineCd = Number(this.selectedTreatMedicine.model.cd.split("$")[0]);
          medicineCd = Number(this.selectedTreatMedicine.model.cd);
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //this.actualModel.treatClass = "0"
          this.actualModel.treatClass = 0;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        } else {
          // 通常薬剤
          medicineCd = this.selectedTreatMedicine.model.cd;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //this.actualModel.treatClass = "1"
          this.actualModel.treatClass = 1;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        }
        this.actualModel.treatMedicine.code = medicineCd;
        this.actualModel.treatMedicine.name = this.selectedTreatMedicine.model.name;
      }
      // del #7727 処置薬剤と数量は必須であってはいけない。start
      // document.getElementsByClassName("input_change")[1].classList.remove("input-invalid");
      // del #7727 処置薬剤と数量は必須であってはいけない。end
    },
    /**
     * 手技マスタ選択イベント処理.
     */
    onSelectProcedure() {
      const item = this.comboList.procedure[this.selectedProcedureIndex];
      if (item) {
        this.actualModel.procedure.code = item.cd;
        this.actualModel.procedure.name = item.text;
      }
    },
    // TODO 用法マスタが存在しない
    // /**
    //  *
    //  * 用法マスタ選択イベント処理.
    //  */
    // onSelectTakeMedicine() {
    //   const item = this.comboList.takeMedicine[this.selectedTakeMedicineIndex];
    //   if (item) {
    //     this.actualModel.takeMedicine.code = item.cd;
    //     this.actualModel.takeMedicine.name = item.text;
    //   }
    // }
    /**
     * 作成済みのコンボリストに削除済みのものがある場合に
     * コンボリストを再作成する
     */
    rebuildComboList(comboList, master) {
      if (comboList.some(item => item.cd === master.code)) {
        // 一致するものがあれば何もしない
        return;
      }
      comboList.unshift({ cd: master.code, text: master.name, hidden: true });
    },
    /**
     * バリデーションを行う.
     */
    isValid() {
      if (this.actualModel.isTreatment) {
        // del #7727 処置薬剤と数量は必須であってはいけない。start
        // // 処置の場合、処置内容は必須
        // if (!this.actualModel.treatment) {
        //   document.getElementsByClassName("input-required")[0]?.classList?.add("input-invalid");
        //   const message =
        //     '<div style="text-align:left;">' +
        //     "以下の項目に未入力項目が存在します。" +
        //     "<br>&nbsp;&nbsp;・処置内容</div>";
        //   this.$ons.notification.alert({
        //     title: "チェックエラー",
        //     message: message
        //   });
        //   return false;
        // }

        // if(this.selectedTreatMedicine.model.cd == null){
        //   document.getElementsByClassName("input-required")[1]?.classList?.add("input-invalid");
        //   const message =
        //       '<div style="text-align:left;">' +
        //       "以下の項目に未入力項目が存在します。" +
        //       "<br>&nbsp;&nbsp;・処置薬剤</div>";
        //     this.$ons.notification.alert({
        //       title: "チェックエラー",
        //       message: message
        //     });
        //     return false;
        // }
        // del #7727 処置薬剤と数量は必須であってはいけない。end
      } else {
        // 処置以外は薬剤と数量が必須
        if (
          !this.actualModel.treatMedicine ||
          (!this.actualModel.treatMedicine.code || !this.actualModel.amount)
        ) {
          // mod #7727 処置薬剤と数量は必須であってはいけない。start
          //document.getElementsByClassName("input-required")[2]?.classList?.add("input-invalid");
          document.getElementsByClassName("input-required")[0]?.classList?.add("input-invalid");
          // mod #7727 処置薬剤と数量は必須であってはいけない。end
          // add 愁訴処置マスタ 障害対応 No237 詳細画面項目「処置薬剤」を入力→確定を押下→未入力と提示される 孔 start
          // const message =
          //   '<div style="text-align:left;">' +
          //   "以下の項目に未入力項目が存在します。" +
          //   "<br>&nbsp;&nbsp;・処置薬剤" +
          //   "<br>&nbsp;&nbsp;・数量</div>";
          let message =
            '<div style="text-align:left;">' +
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // "以下の項目に未入力項目が存在します。";
            messageFormat(DIALOG_MESSAGES['00200044'].message);
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          if (!this.actualModel.treatMedicine.code)
            message += '<br>&nbsp;&nbsp;・処置薬剤';
          if (!this.actualModel.amount)
            message += '<br>&nbsp;&nbsp;・数量';
          message += '</div>';
          // add 愁訴処置マスタ 障害対応 No237 詳細画面項目「処置薬剤」を入力→確定を押下→未入力と提示される 孔 end
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES['00200044'].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: message
          });
          return false;
        }
        // TODO 削除済みマスタ（薬剤、手技、用法）を参照していないこと
      }
      return true;
    },
    /**
     * 薬剤情報をクリア(未登録を選択)時に薬剤をクリアする.
     */
    clearMedicineItems() {
      if(this.actualModel.isTreatment) {
        this.selectedTreatMedicine.model = new Master();
        this.actualModel.treatMedicine.code = null;
        this.actualModel.treatMedicine.name = "";
        this.actualModel.treatMedicine.unit = "";
        this.actualModel.treatMedicine.decPoint = null;
        this.actualModel.amount = null;
        this.selectedProcedureIndex = this.comboList.procedure.findIndex(item => item.cd === null);
        this.onSelectProcedure();
      }
    },
    setContentData(newValue) {
      this.actualModel.treatment = newValue;
    },
    // del #7727 処置薬剤と数量は必須であってはいけない。start
    // setCss(value) {
    //   if(value && document.getElementsByClassName("input-invalid")[0])
    //     document.getElementsByClassName("input-invalid")[0].classList.remove("input-invalid");
    // },
    // del #7727 処置薬剤と数量は必須であってはいけない。end
    // mod #7727 処置薬剤と数量は必須であってはいけない。start
    // setCss2(value) {
    //   if(value !== null && value !== 0)
    //     document.getElementsByClassName("input_change")[2].classList.remove("input-invalid");
    // },
    setCss2(value) {
      if(value !== null && value !== 0)
        document.getElementsByClassName("input_change")[0].classList.remove("input-invalid");
    },
    // mod #7727 処置薬剤と数量は必須であってはいけない。end
  },
  computed: {
    ...mapGetters("master-maintenance", {
        getFacilitySwitch: "getFacilitySwitch"
    }),
    /**
     * 編集中フラグ.
     */
    isChanged() {
      if (
        replaceNullWithEmptyString(this.actualModel.treatment) !== replaceNullWithEmptyString(this.comparisonModel.treatment) ||
        replaceNullWithEmptyString(this.actualModel.treatClass) !== replaceNullWithEmptyString(this.comparisonModel.treatClass) ||
        // 愁訴処置マスタ check失敗 林峻峰 start
        // this.actualModel.amount !== this.comparisonModel.amount ||
        replaceNullWithEmptyString(this.actualModel.amount) != replaceNullWithEmptyString(this.comparisonModel.amount) ||
        // 愁訴処置マスタ check失敗 林峻峰 end
        replaceNullWithEmptyString(this.actualModel.treatMedicine.code) !==
          replaceNullWithEmptyString(this.comparisonModel.treatMedicine.code) ||
        replaceNullWithEmptyString(this.actualModel.procedure.code) !== replaceNullWithEmptyString(this.comparisonModel.procedure.code) ||
        replaceNullWithEmptyString(this.actualModel.inHospAStartdate) != replaceNullWithEmptyString(this.comparisonModel.inHospAStartdate) ||
        replaceNullWithEmptyString(this.actualModel.inHospBStartdate) != replaceNullWithEmptyString(this.comparisonModel.inHospBStartdate) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdA1) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdA1) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdA2) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdA2) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdA3) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdA3) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdA4) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdA4) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdB1) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdB1) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdB2) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdB2) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdB3) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdB3) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCdB4) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCdB4)
      ) {
        return true;
      }
      return false;
    },
    inHospAStartdate: {
      get: function(){
        // #5590 2023/04/20 ×を常に表示するように修正 張博 start
        if (this.actualModel.inHospAStartdate==null) {
          return null;
        }
        // #5590 2023/04/20 ×を常に表示するように修正 張博 end
        return moment(this.actualModel.inHospAStartdate).format("YYYY-MM-DD");
      },
      set: function(newValue) {
        /* mod 日付項目修正 楊 start */
        if(newValue === "") {
          this.actualModel.inHospAStartdate = null;
        }else{
          this.actualModel.inHospAStartdate = moment(newValue).format("YYYYMMDD");
        }
        /* mod 日付項目修正 楊 end */
      }
    },
    inHospBStartdate: {
      get: function(){
        // #5590 2023/04/20 ×を常に表示するように修正 張博 start
        if (this.actualModel.inHospBStartdate==null) {
          return null
        }
        // #5590 2023/04/20 ×を常に表示するように修正 張博 end
        return moment(this.actualModel.inHospBStartdate).format("YYYY-MM-DD");
      },
      set: function(newValue) {
        /* mod 日付項目修正 楊 start */
        if(newValue === "") {
          this.actualModel.inHospBStartdate = null;
        }else{
          this.actualModel.inHospBStartdate = moment(newValue).format("YYYYMMDD");
        }
        /* mod 日付項目修正 楊 end */
      }
    },
    unitStep(){
      var num = parseInt(this.actualModel.treatMedicine.decPoint);
      if(isNaN(num)){
        num = 0;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    }
  },
  async created() {
    // Objectを保有しておりObject.assignはシャローコピーになるので一旦一つずつコピー
    this.comparisonModel = this.getMstCompTreatmentEdit();
    this.actualModel = new MstCompTreatment();
    Object.assign(this.actualModel, this.comparisonModel);
    await this.init();
  },
  mounted() {
    this.$nextTick(() => {
      document.getElementById("com-textarea-treatment").focus();
    });
  }
};
</script>

<style scoped>
.expandable-content {
  background-color: inherit;
  background-image: none;
  font-family: inherit;
  padding: 1em;
}
.expandable-content >>> ons-row {
  margin-top: 15px;
}
.expandable-content >>> .k-button,
.expandable-content >>> .text-input,
.expandable-content >>> textarea,
.expandable-content >>> select {
  font-size: 1em;
  line-height: unset;
  font-family: inherit;
}
.expandable-content >>> textarea {
  width: 100%;
  border: 1px solid var(--master-maintenance-complaint-select-border-color);
}
.expandable-content >>> .num-value ons-input {
  width: 8em;
}
.number-input >>> .title,
.treat-medicine-selector >>> .title {
  flex: 0 0 30%;
  max-width: 30%;
}
.expandable-content >>> ons-col.num-value {
  display: flex;
  align-items: center;
}
.expandable-content >>> .num-value ons-input {
  min-width: 8.5em;
}
.treat-medicine-selector >>> .theme {
  vertical-align: -webkit-baseline-middle;
}
.treat-medicine-selector >>> .select-button {
  text-align: center;
  background-image: none;
}
.treat-medicine-selector >>> .k-button {
  width: auto;
}
.inhosp-style {
  font-size: 1em;
  height: 31px;
}
.input-required >>> textarea {
  color: black;
  background-color: #ffff99;
}
.input-required >>> input {
  color: black;
  background-color: #ffff99;
}
.input-invalid >>> textarea {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.input-invalid >>> input {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.col-width {
  width: 50%
}
</style>
