/**
 * 治療記録の子機能 医療材料一覧.
 *
 */
<template>
  <submenu-base v-if="hasOrdNo">
    <template #main>
      <div id="equipment-component" style="width: calc(100% - 1px);">
      <div>
        <table class="treatment-record-list">
          <thead>
            <tr>
              <th colspan="4" style="background-image: none;">
                <div>
                <!-- mod #10359 編集権限の動作不正 start -->
                <!-- <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!isShared" style="float: left;" @click="addRow()">追加</v-ons-button> -->
                <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!isShared||!getItemAuthorized('TreatmentRecord', 'default_authority')" style="float: left;" @click="addRow()">追加</v-ons-button>
                <!-- mod #10359 編集権限の動作不正 end -->
                </div>
              </th>
            </tr>
            <tr>
              <th class="ntss-list-header-th-sticky">医療材料名</th>
              <th class="ntss-list-header-th-sticky" style="width: 10em">数量</th>
              <th class="ntss-list-header-th-sticky" style="width: 4em">単位</th>
              <th class="ntss-list-header-th-sticky delete-col"></th>
            </tr>
          </thead>
          <tbody>
            <template v-for="(data, index) in rstEquipInfoList.value()" :key="index">
              <tr :class="['ntss-list-body-tr', data.isNew ? 'added-item' : '', data.be_deleted ? 'deleted-item' : '']">
                <td class="ntss-list-body-td equipment-selector-td" style="min-width:22em">
                  <!-- <v-ons-row>
                    <v-ons-col>
                      <show-selected-item
                        :propEditValue="rstEquipInfoListAsMaster[index].name"
                        propBackgroundColor="#ebebe4"
                      />
                    </v-ons-col> -->
                    <!-- 医療材料の選択ボタン -->
                    <!-- mod #10359 編集権限の動作不正 start -->
                    <!-- <com-master-selector
                      v-if="isShared"
                      :index="index"
                      name="equipment-all"
                      labelName=""
                      :showLabelName="false"
                      :readMasterData="fetchEquipmentAndEquipmentClass"
                      :masterDefine="masterDefine"
                      v-model="rstEquipInfoListAsMaster[index]"
                      @input="onSelectEquipment"
                    /> -->
                    <common-master-selector
                      :masterType="MasterType.EQUIPMENT_TREATMENT_RECORD"
                      :initItem="{ text: rstEquipInfoListAsMaster[index].name, value: rstEquipInfoListAsMaster[index].cd, unit: rstEquipInfoListAsMaster[index].unit }"
                      :editItem="{ text: data.name, value: data.cd, unit: data.unit }"
                      :patientId="selectedPatId"
                      :extraParams="buildEquipmentSelectorExtraParams(index, data)"
                      :facilityCd="getFacilityCd"
                      :dialysisState="getDialysisState"
                      :hasChangedOption="true"
                      :changeOptionMode="'nameAndUnit'"
                      :selectedItemClass="'com-basic-sub-input'"
                      :hasUnregisteredOption="false"
                      :backgroundColor="'#ebebe4'"
                      :btnClass="'com-basic-sub-btn'"
                      :btnDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
                      @popover-return="masterUpdateInput($event, index)"
                    />
                    <!-- mod #10359 編集権限の動作不正 end -->
                  <!-- </v-ons-row> -->
                </td>
                <td class="ntss-list-body-td" style="min-width:3em">
                  <!-- 医療材料の数量入力 -->
                  <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start -->
                  <!-- <com-number-input
                    input-id="amount"
                    name="amount"
                    :inputTextAlign='"right"'
                    :inputType='"number"'
                    :step=1
                     v-model="data.amount"
                    :disabled="!isShared"
                    :inputMin="1"
                    :inputMax="9999"
                    @blur="onInputAmount(index)"
                    @input="onInputChangeAmount"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- <custom-input-number-pro -->
                  <!--   input-id="amount" -->
                  <!--   name="amount" -->
                  <!--   :invalidArray="['0']" -->
                  <!--   :required="true" -->
                  <!--   v-model="data.amount" -->
                  <!--   :disabled="!isShared" -->
                  <!--   :min="0" -->
                  <!--   :max="9999" -->
                  <!--   :step="1" -->
                  <!--   :loop-flg="true" -->
                  <!--   :initial-value-lock="true" -->
                  <!--   @handlerInput="(val) =>{ data.amount = Number(val);onInputAmount(index) }" -->
                  <!-- /> -->
                  <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
                  <!-- <custom-input-number-pro
                    input-id="amount"
                    name="amount"
                    :invalidArray="['0']"
                    :required="true"
                    v-model="data.amount"
                    :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                    :min="0"
                    :max="9999"
                    :step="1"
                    :loop-flg="true"
                    :initial-value-lock="true"
                    @handlerInput="(val) =>{ data.amount = Number(val);onInputAmount(index) }"
                  /> -->
                  <custom-input-number-pro
                    input-id="amount"
                    name="amount"
                    :invalidArray="['0']"
                    :required="true"
                    :value="data.amount"
                    :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                    :min="0"
                    :max="9999"
                    :step="1"
                    :roll-flag="true"
                    @handlerInput="(val) =>{ data.amount = Number(val);onInputAmount(index) }"
                  />
                  <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
                  <!-- mod #10359 編集権限の動作不正 end -->
                  <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end -->
                </td>
                <!-- 医療材料の単位表示 -->
                <td class="ntss-list-body-td" style="min-width:4em">{{ data.unit }}</td>
                <!-- 削除ボタン -->
                <td class="align-center ntss-list-body-td">
                  <button class="ntss-btn-outset button-delete" :disabled="!isShared" @click="deleteEquipInfo(index)">
                    <v-ons-icon icon="fa-trash"/>
                  </button>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container justify-content-flex-end">
      <div class="registration-btn-area">
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start-->
<!--        <v-ons-button class="button registration-btn btn1-execute"  :disabled="(editFlag && !canSave) || isReadOnly || !isShared" @click="updateEquipInfo">-->
        <!-- mod #10359 編集権限の動作不正 start -->
        <!-- <v-ons-button class="button registration-btn btn1-execute"  :disabled="isEditable" @click="updateEquipInfo"> -->
        <v-ons-button class="button registration-btn btn1-execute"  :disabled="isEditable || !getItemAuthorized('TreatmentRecord', 'default_authority')" @click="updateEquipInfo">
          <!-- mod #10359 編集権限の動作不正 end -->
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end-->
          保存
        </v-ons-button>

      </div>
      </div>
    </template>
  </submenu-base>
</template>

<script>
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
import {mapGetters, mapActions, mapMutations} from "@/compat/vue/vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
//#8484　医療材料選択IFのリスト不正 追加修正　Start
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
//#8484　医療材料選択IFのリスト不正 追加修正　End
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import { Equipment } from "@/models/treatment-record/equipment/Equipment";
import { EquipmentList } from "@/models/treatment-record/equipment/EquipmentList";
import {
  sendRequestGetMstEquipmentClass
} from "@/apis/treatment-record";
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import { equipmentAll } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { Master } from "@/models/common/master-selector-condition/Master";
import { CODES } from "@/constants/TreatmentRecord";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// 選択項目の先頭に「すべて」、末尾に「未分類」を追加する.
import { shapeSelectionItem } from "@/functions/for-componet/ListSelector";
// 部材(医療材料・ダイアライザ)の医療材料区分 equipType に関する共通関数
import {
  encryptPersistentCodeToInternalCd,
  decryptDialyzerCdToPersistentCode,
  detectEquipTypeFromCode
} from "@/functions/EquipTypeFunctions";
// add #10359 編集権限の動作不正 start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
  // import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
  // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 end
// add #9848+9849 数値IFのスタイル全不正 linjunfeng start
import { parseStoredArray } from "@/functions/common/CommonFunctions";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

// add #9848+9849 数値IFのスタイル全不正 linjunfeng end
export default {
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
  mixins: [DiscardConfirmationMixin],
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  components: {
    "submenu-base": SubmenuBase,
    "com-master-selector": CommonMasterSelectorComponent,
    "com-number-input": CommonNumberInputComponent,
    "show-selected-item": CustomDivShowSelectedItem,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
    "common-master-selector": commonMasterSelector,
  },
  data() {
    return {
      MasterType,
      rstDialysisState: undefined,
      rstEquipInfoList: new EquipmentList(),
      rstEquipInfoListAsMaster: [],
      rstEquipInfoListInitial: new EquipmentList(),
      masterDefine: equipmentAll,
      latestEquipment: [],
      // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
      equipInfoOptional: [],
      // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
      latestEquipmentClass: [],
      // ダイアライザマスタ
      latestDialyzer: [],
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      // authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
      selfScreenName: "",
      alertFlag: true,
      noDeleteData: [],
      // マスタ
      mstEquipmentInfo: null,
      rsrEquipNewData:[],
      editFlag: true
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      stateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("window-size", {
      windowWidth: "getMainWindowWidth"
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),

    canDelete() {
      return this.rstEquipInfoList.beDeleted();
    },
    canSave() {
      return this.rstEquipInfoList.hasEditedEquipment();
    },
    ...mapGetters("treatment-record/common", [
      "getOrdNo",
      "getOrd",
      "getSharedFacilityCd",
      "getDialysisState",
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      "getTreatDate"
       //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      ]),
    ...mapGetters("user", ["getFacilityCd"]),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // 治療状況：後体重確認済み(過去実績)かどうか(true: 後体重確認済み(過去実績) , false:それ以外のステータス)
    isPastInfo() {
      // upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
      return (
          // this.rstDialysisState === CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd
          this.rstDialysisState > CODES.DIALYSIS_STATE.BEFORE_SEND_CONDITION.cd
      );
      // upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
    },
    isChanged() {
      return this.canDelete || this.canSave;
    },

    isReadOnly() {
      return this.getOrd.readOnly;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    isEditable(){
      this.setIsPatInfoChaned(!((this.editFlag && !this.canSave) || this.isReadOnly || !this.isShared));
      return (this.editFlag && !this.canSave) || this.isReadOnly || !this.isShared;
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
  },
  methods: {
    ...mapActions("treatment-record/equipInfo", [
      "getTreatmentRecordEquipInfo",
      "putTreatmentRecordEquipInfo"
    ]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    /**
     * マスタ選択用プルダウン生成.
     * <p>医療材料マスタ、医療材料分類マスタ、ダイアライザマスタを成形する.</p>
     */
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // async fetchEquipmentAndEquipmentClass() {
    async fetchEquipmentAndEquipmentClass(index) {
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // 医療材料マスタ、医療材料分類マスタ、ダイアライザマスタの取得
      const mstEquipmentResponse = await this.fetchDataList();
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      if (index == null) {
        return mstEquipmentResponse;
      }
      const cd = this.rstEquipInfoListInitial.get(index) ? this.rstEquipInfoListInitial.get(index).cd : 0;
      const name = this.rstEquipInfoListInitial.get(index) ? this.rstEquipInfoListInitial.get(index).name : "";

      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // ダイアライザを医療材料のリストに含める
      const contentDialyzer = mstEquipmentResponse[2].data
        .map(item => {
          return {
            // 医療材料マスタと項目名などフォーマットを合わせる
            equipmentCd: `dialyzer${item.dialyzerCd}`,
            cd: item.dialyzerCd,
            equipmentName: item.modelNumber,
            unit: null,
            classCd: -2,
            isDisp: item.isDisp,
            //#8484　医療材料選択IFのリスト不正 追加修正　Start
            name: item.modelNumber,
            useStartDate: item.useStartDate,
            useEndDate: item.useEndDate,
            // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            isTaboo: item.isTaboo,
            isAllergy: item.isAllergy,
            // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            //#8484　医療材料選択IFのリスト不正 追加修正　End
          };
        });
        // add #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng start
        let filterArr = [];
        this.rstEquipInfoList.value().forEach((item, listIndex) => {
          // #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 linjunfeng start
          // if (item.cd && !item.be_deleted) {
          if (item.cd && !item.be_deleted && listIndex != index) {
          // #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 linjunfeng start
            filterArr.push(item.cd);
          }
        });
        // add #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng end
      //#8484　医療材料選択IFのリスト不正 追加修正　Start
      mstEquipmentResponse[2].data = contentDialyzer.filter(item => {
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return fitTermCheck(item.useStartDate, item.useEndDate, this.getTreatDate) || item.equipmentCd === this.localSelectedCd;
          // #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng start
          // return fitTermCheck(item.useStartDate, item.useEndDate, this.getTreatDate) || item.equipmentCd == cd;
          return (fitTermCheck(item.useStartDate, item.useEndDate, this.getTreatDate) || item.equipmentCd === cd) && !filterArr.includes(item.equipmentCd);
          // #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng end
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
      //#8484　医療材料選択IFのリスト不正 追加修正　End
      // 医療材料分類にダイアライザを含める
      mstEquipmentResponse[1].data.push({classCd:-2,className:"ダイアライザ"});
      // 医療材料分類一覧の先頭に「すべて」、末尾に「未分類」を追加する
      shapeSelectionItem( mstEquipmentResponse[1].data, true);
      //#8484　医療材料選択IFのリスト不正 追加修正　Start
      mstEquipmentResponse[0].data = mstEquipmentResponse[0].data.filter(item => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return fitTermCheck(item.useStartDate, item.useEndDate, this.getTreatDate) || item.equipmentCd === this.localSelectedCd;
          // #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng start
          // return fitTermCheck(item.useStartDate, item.useEndDate, this.getTreatDate) || item.equipmentCd === cd;
          return (fitTermCheck(item.useStartDate, item.useEndDate, this.getTreatDate) || item.equipmentCd === cd) && !filterArr.includes(item.equipmentCd);
          // #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng end
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      mstEquipmentResponse[0].data.forEach((item) => {
        if (item.equipmentCd == cd) {
          item.equipmentName = name;
          item.isDisp = "1"
        } else {
          item.equipmentName = getPrefix(item) + item.equipmentName;
        }
      })
      mstEquipmentResponse[2].data.forEach((item) => {
        if (item.equipmentCd == cd) {
          item.equipmentName = name;
          item.isDisp = "1"
        } else {
          item.equipmentName = getPrefix(item) + item.equipmentName;
        }
      })
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      //#8484　医療材料選択IFのリスト不正 追加修正　End
      return mstEquipmentResponse;
    },

    /**
     * 医療材料マスタ、医療材料分類マスタ、ダイアライザマスタの取得.
     */
    fetchDataList() {
      // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
      let patId = this.selectedPatId ? this.selectedPatId : "-1";
      // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
      return Promise.all([
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // sendRequestGetMstEquipmentTabooAllergy(this.selectedPatId),
        // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
        // ApiHelper.get(`/mstInfo/mstEquipment/${this.selectedPatId}/true`),
        ApiHelper.get(`/mstInfo/mstEquipment/${patId}/true`),
        // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
        sendRequestGetMstEquipmentClass(),
        // sendRequestGetMstDialyzerTabooAllergy(this.selectedPatId)
        // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
        // ApiHelper.get(`/mstInfo/mstDialyzerIncludeDel/${this.selectedPatId}`)
        ApiHelper.get(`/mstInfo/mstDialyzerIncludeDel/${patId}`)
        // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      ]);
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    /**
     * 最新の医療材料マスタ、ダイアライザマスタから対象レコードを見つける。
     * @param {*} cd 材料コード(ex. 1(医療材料の場合), 'dialyzer1'(医療材料の場合)).
     * @param {number} equipType (0:医療材料, 1:ダイアライザ).
     * @return {Object} 該当する医療材料マスタレコード、またはダイアライザマスタレコード。いずれにも該当しない場合はundefined.
     */
    //mod 9694 ljx start
    // findEquipByCd(cd, equipType) {
    //   const latestMaster = equipType === 1 ? this.latestDialyzer : this.latestEquipment;
    //   return latestMaster.find(e => e.equipmentCd == encryptPersistentCodeToInternalCd(cd, equipType));
    // },
    findEquipByCd(cd, equipType,index){
      let findEquipInfo = "";
      if(index < this.equipInfoOptional?.length){
         findEquipInfo = this.equipInfoOptional[index];
      }else{
        const latestMaster = equipType === 1 ? this.latestDialyzer : this.latestEquipment;
        findEquipInfo =  latestMaster.find(e => e.equipmentCd == encryptPersistentCodeToInternalCd(cd, equipType));
      }
      return findEquipInfo;
      //mod 9694 ljx end
    },

    /**
     * 治療情報の医療材料コードでmst_selectorテーブルから取得したダイアライザより引き当てる.
     * @param  cd
     */
    findMstByCd (cd) {
      let cdString = cd+"";
      if (cdString.indexOf("dialyzer") !== -1) {
        let code = cdString.replace(/dialyzer/g,"");
        return this.rsrEquipNewData.find(e=> e.code == code);
      }
      // ⇓ 医療材料のレコードと判断されているコードと
      // mst_selectorテーブルから取得したダイアライザをマッチさせようとしているのでマッチしない
      return this.rsrEquipNewData.find(e=> e.code == cd);
    },

    syncCurrentEquipmentUnit(equipInfoList) {
      // 過去実績の場合、登録されている単位を表示
      if (this.isPastInfo) {
        return equipInfoList;
      }
      // 過去実績以外の場合、マスタ情報から単位を最新化
      //mod 9694 ljx start
      // return equipInfoList.map(equip => {
      // const mstEquip = this.findEquipByCd(equip.cd, equip.equip_type);
      return equipInfoList.map((equip,index) => {
        const mstEquip = this.findEquipByCd(equip.cd, equip.equip_type,index);
        //mod 9694 ljx end
        if (mstEquip !== undefined) equip.unit = mstEquip.unit;
        return equip;
      });
    },

    /**
     * 医療材料一覧を表示するために治療情報の実績:医療材料(ダイアライザ含む)よりリストを生成する.
     */
    // mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
    equipInfoListFromOrdMain() {
      this.rstEquipInfoListAsMaster = this.rstEquipInfoList
        .value()
        .map((info, index) => {
          let name = "";
          let cd = null;
          let equip_type = info.equip_type ?? 0;
          const unit = info && info.unit != null ? info.unit : null;
          const equipment = this.findEquipByCdFromMstAndOrdMain(info.cd, equip_type, index);

          // 既存変更ID
          const changeFlag = this.comparisonExistingChangeCd(equipment, index, info.cd);
          if (equipment == undefined) {
            const mstInfo = null;
            // #8203以外のチケットで見直す予定のため、一旦このロジックはこのままとする
            // TODO: 見直し後に接頭辞を引き続き利用する場合は定数化する
            if (mstInfo  && Object.prototype.hasOwnProperty.call(mstInfo, "isDel") && mstInfo.isDel ==="1") {
              // 引き当てたマスタレコードが日機装の保守作業により削除されたものである場合
              if (this.isPastInfo) {
                name = `${info.name}【削除済み含む】`; // 【削除済み含む】⇒調製薬剤マスタとの突き合わせた結果、一部の薬剤がマスタから削除されている場合の接尾辞(医療材料、ダイアライザでは付与することがないので不要)
                cd = info.cd;
              } else {
                name = `【削除】${info.name}`;
                cd = info.cd;
              }
              return new Master(cd,name);
            }
          }

          if (equipment) {
            if (changeFlag) {
              if (this.isPastInfo) {
                name = equip_type === 1 ? equipment.modelNumber : equipment.equipmentName;
                cd = equip_type === 1 ? equipment.dialyzerCd : equipment.equipmentCd;
              } else {
                name = info.name;
                cd = info.cd;
              }
            } else {
              name = this.isPastInfo ? equipment.name || equipment.equipmentName : info.name;
              cd = this.isPastInfo ? equipment.cd || equipment.equipmentCd : info.cd;
            }
          } else {
            if (info.name != undefined) {
              if (this.isPastInfo) {
                name = `${info.name}【削除済み含む】`;
                cd = info.cd;
              } else {
                name = `【削除】${info.name}`;
                cd = info.cd;
              }
            }
          }

          const m = new Master(cd, name);
          m.unit = unit;
          return m;
        });
    },
    // mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
    // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
    findEquipByCdFromMstAndOrdMain(cd, equipType, index) {
      if (!cd) return null;

      if (
        index < this.equipInfoOptional?.length &&
        cd === this.equipInfoOptional[index]?.cd
      ) {
        return this.equipInfoOptional[index];
      }

      return equipType === 1
        ? this.latestDialyzer.find((e) => String(e.dialyzerCd) === String(cd))
        : this.latestEquipment.find((e) => e.equipmentCd == cd);
    },
    comparisonExistingChangeCd (equipment, index, cd) {
      if (!equipment) return false;
      if (!this.equipInfoOptional || this.equipInfoOptional.length === 0) return true;
      if (!this.equipInfoOptional[index]) return true;
      return index < this.equipInfoOptional.length && cd !== this.equipInfoOptional[index].cd;
    },
    // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
    /**
     * マスタ選択ポップオーバーにて選択された項目のコールバック.
     * <p>選択されたマスタに差し替え、本画面で操作するに必要な属性を補完する</p>
     * @param {*} master 選択されたマスタのコード(cd*)と表示項目名(name) *:ダイアライザの場合は内部展開されたコード(例. dialyzer1).
     * @param {*} index  選択された医療材料一覧のインデックス.
     */
    onSelectEquipment(master, index) {
      const equipInfo = this.rstEquipInfoList.get(index);
      equipInfo.equip_type = detectEquipTypeFromCode(master.cd);
      equipInfo.cd = master.cd;
      equipInfo.name = master.name;
      // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
      // equipInfo.needle_type = master.needle ? master.needle : 0;
      // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
      equipInfo.setUpdUser(this.stateUserAccountInfo);
      this.rstEquipInfoList.refreshEquipmentAndClass(index);
    },
    masterUpdateInput(data = {}, index) {
      const isDialyzer = String(data && data.key_class != null ? data.key_class : "") === "-2";
      const cd = data && data.value != null ? data.value : null;
      const masterCd = cd != null && cd !== "" ? Number(cd) : null;
      const row = this.rstEquipInfoList.get(index);
      row.cd = masterCd;
      row.name = data && data.text != null ? data.text : null;
      row.unit = data && data.unit != null && data.unit !== "" ? data.unit : null;
      row.equip_type = isDialyzer ? 1 : 0;
      if (isDialyzer) {
        row.class_cd = null;
        row.class_name = null;
        row.class_type = null;
      } else {
        row.class_cd = data && data.classCd != null ? data.classCd : (data && data.key_class != null ? data.key_class : row.class_cd);
        row.class_name = row.class_name;
        row.class_type = row.class_type;
      }
      row.setUpdUser(this.stateUserAccountInfo);
    },
    buildEquipmentSelectorExtraParams(index, rowData) {
      const excludeEquipment = [];
      const excludeDialyzer = [];

      (this.rstEquipInfoList?.value?.() || []).forEach((item, i) => {
        if (i === index) return;
        if (!item || item.be_deleted) return;

        const cd = item.cd;
        if (cd == null || cd === "") return;

        const equipType = item.equip_type != null ? item.equip_type : detectEquipTypeFromCode(cd);
        if (equipType === 1) {
          excludeDialyzer.push(cd);
        } else {
          excludeEquipment.push(cd);
        }
      });

      return {
        treatDate: this.getTreatDate,
        equipType: rowData?.equip_type,
        actualName: this.rstEquipInfoListAsMaster?.[index]?.name || rowData?.name || "",
        excludeEquipmentCdList: excludeEquipment.length ? excludeEquipment.join(",") : null,
        excludeDialyzerCdList: excludeDialyzer.length ? excludeDialyzer.join(",") : null
      };
    },

    onInputChangeAmount(amount) {
      this.editFlag = false;
    },

    onInputAmount(index) {
      this.$nextTick(() => {
        const initialVal = this.rstEquipInfoListInitial.get(index) && this.rstEquipInfoListInitial.get(index).amount;
        const newVal = this.rstEquipInfoList.get(index) && this.rstEquipInfoList.get(index).amount;
        // add 9973 -4 by kangjie 20231030 start
        // if (newVal !== initialVal) {
        if (newVal != initialVal) {
          // add 9973 -4 by kangjie 20231030 end
          this.rstEquipInfoList
            .get(index)
            .setUpdUser(this.stateUserAccountInfo);
          this.editFlag = false;
        }
        this.editFlag = true;
      });
    },
    async init() {
      if (!this.getOrdNo) {
        return;
      }
      // 初期化処理を実行
      this.rstEquipInfoList.deleteAll();
      this.rstEquipInfoListInitial.deleteAll();
      // 治療情報の取得
      const response = await this.getTreatmentRecordEquipInfo({
        ordNo: this.getOrdNo,
        selectedPatId: this.selectedPatId
      });
      // マスタ類の取得
      const mstEquipmentResponse = await this.fetchEquipmentAndEquipmentClass();
      this.latestEquipment = mstEquipmentResponse[0].data;
      this.latestEquipmentClass = mstEquipmentResponse[1].data;
      this.latestDialyzer = mstEquipmentResponse[2].data;

      this.rstDialysisState = response.data.rst_dialysis_state;
      // upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
      this.equipInfoOptional = JSON.parse(response.data.rst_equip_info);
      const equipInfoArray = this.equipInfoOptional ? this.equipInfoOptional : [];
      // upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start

      if (equipInfoArray) {
        // RestAPI実行
        var facility_cd = this.getFacilityCd;
        const displayOrder = await ApiHelper.get(
          "/mainData/displayOrder",
          {
            facility_cd,
            selectedPatId: this.selectedPatId
          }).catch(err => {
          getErrorMessage('EquipmentComponent.vue', 'init', err);
          throw err;
        });
        const paramJson = {};
        paramJson.facilityCd = this.getFacilityCd;
        paramJson.selectedPatId = this.selectedPatId;
        const mstEquipment = await ApiHelper.get(
          "/mstInfo/mstEquipment",
          paramJson).catch(error => {
          getErrorMessage('EquipmentComponent.vue', 'init', error);
          throw error;
        });
        this.mstEquipmentInfo = mstEquipment.data;
        const tableName = "mst_equipment_class";
        const mstselector = await ApiHelper.get(
          `/report_designer/master/${tableName}`,
          { selectedPatId: this.selectedPatId }).catch(err => {
          getErrorMessage('EquipmentComponent.vue', 'init', err);
          throw err;
        });
        const mstselectorDialyzer = await ApiHelper.get(
        `/report_designer/master/mst_dialyzer`,
        { selectedPatId: this.selectedPatId }).catch(err => {
          throw err;
        });

        // 医療材料(ダイアライザ含む)一覧の並び替え(医療材料>未分類の医療材料>ダイアライザ)
        this.rsrEquipNewData = mstselectorDialyzer.data;
        for(let i = 0 ; i< equipInfoArray.length ; i++) {
          if (equipInfoArray[i].equip_type === 0){
            for (let j = 0 ; j< this.mstEquipmentInfo.length ; j++) {
              if (equipInfoArray[i].cd === this.mstEquipmentInfo[j].equipmentCd) {
                equipInfoArray[i].index = j;
              }
            }
            let classCdIndex = mstselector.data.findIndex(el => el.code == equipInfoArray[i].class_cd);
            equipInfoArray[i].classCdIndex = classCdIndex === -1 ? 999999 : classCdIndex;
          } else if (equipInfoArray[i].equip_type === 1) {
            equipInfoArray[i].index = Number("999999" + mstselectorDialyzer.data.findIndex(el => el.code == equipInfoArray[i].cd));
            equipInfoArray[i].classCdIndex = Number("999999" + mstselectorDialyzer.data.findIndex(el => el.code == equipInfoArray[i].cd));

            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // for (let y=0;y<mstselectorDialyzer.data.length;y++) {
            //   if(mstselectorDialyzer.data[y].code == equipInfoArray[i].cd) {
            //     equipInfoArray[i].name = mstselectorDialyzer.data[y].name;
            //   }
            // }
            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          }
        }
        if (displayOrder.data) {
          let medOrderNo = displayOrder.data.find(item => item.facilitySettingNo == '3006');
          if (medOrderNo) {
            let medOrderNoValueArray = parseStoredArray(medOrderNo.value);
            let sortKeyObj = [];
            for (let i = 0; i < medOrderNoValueArray.length; i++) {
              switch (medOrderNoValueArray[i]) {
                // 医療材料分類名称コード
                case '1':
                  sortKeyObj['classCdIndex'] = "ascending";
                  break;
                // 医療材料マスタ表示順
                case '2':
                  sortKeyObj['index'] = "ascending";
                  break;
              }
            }
            equipInfoArray.sort((frontValue, nextValue) => this.sortByProps(frontValue, nextValue, sortKeyObj));
          }
        }
      }

      equipInfoArray.forEach(json => {
        this.rstEquipInfoListInitial.add(Equipment.of(json));
      });

      equipInfoArray.forEach(json => {
        this.rstEquipInfoList.add(Equipment.of(json));
      });
      if (this.noDeleteData.length > 0) {
        this.noDeleteData.forEach(el=>{
          this.rstEquipInfoList.add(el);
        })
        this.noDeleteData = [];
      }

      this.rstEquipInfoListAsMaster = this.rstEquipInfoList
        .value()
        .map(info => {
          const m = new Master(info && info.cd != null ? info.cd : null, info && info.name != null ? info.name : "");
          m.unit = info && info.unit != null ? info.unit : null;
          return m;
        });
      // 最新の医療材料マスタ、ダイヤライザマスタと医療材料分類マスタを
      // rstEquipInfoList(EquipmentListクラス。医療材料情報（rst_equip_info）の集合を表現)に設定
      this.rstEquipInfoList.latestEquipmentList = this.latestEquipment;
      this.rstEquipInfoList.latestEquipmentClassList = this.latestEquipmentClass;
      this.rstEquipInfoList.latestDialyzerList = this.latestDialyzer;
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      // this.$nextTick(() => {
      //   this.disableElement(this.$el);
      // });
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    },

    /**
     * 画面に表示する医療材料(ダイアライザ含む)一覧の並び替え.
     * @param {*} item1
     * @param {*} item2
     * @param {*} obj
     */
    sortByProps(item1,item2,obj){
      var props = [];
      if(obj){
        props.push(obj)
      }
      var cps = [];
      var asc;
      if (props.length < 1) {
        for (var p in item1) {
          if (item1[p] > item2[p]) {
            cps.push(1);
            break;
          } else if (item1[p] === item2[p]) {
            cps.push(0);
          } else {
            cps.push(-1);
            break;
          }
        }
      }
      else {
        for (var i = 0; i < props.length; i++) {
          var prop = props[i];
          for (var o in prop) {
            asc = prop[o] === "ascending";
            if (item1[o] > item2[o]) {
              cps.push(asc ? 1 : -1);
              break;
            } else if (item1[o] === item2[o]) {
              cps.push(0);
            } else {
              cps.push(asc ? -1 : 1);
              break;
            }
          }
        }
      }
      for (var j = 0; j < cps.length; j++) {
        if (cps[j] === 1 || cps[j] === -1) {
          return cps[j];
        }
      }
      return false;
    },

    /**
     * バリデーション.
     * <p>注意: この関数ではバリデーションに関する実装に専念すること。値を補完する実装はここに記載しない</p>
     */
    validate() {
      function getErrMessageWord(columnName) {
        return `</br>&nbsp&nbsp・${columnName}`;
      }
      const validateResult = this.rstEquipInfoList.validate();
      if (Object.values(validateResult).every(r => r === true)) {
        return true;
      }

      let errMessage =
        (validateResult.name ? "" : getErrMessageWord("医療材料名")) +
        (validateResult.amount ? "" : getErrMessageWord("数量"));

      // #9848+9849 数値IFのスタイル全不正 linjunfeng start
      // errMessage = messageFormat(DIALOG_MESSAGES[12000005].message, errMessage)
      errMessage = messageFormat(DIALOG_MESSAGES[12000005].message + errMessage)
      // #9848+9849 数値IFのスタイル全不正 linjunfeng end
      this.$ons.notification.alert({
        title: DIALOG_MESSAGES[12000005].title,
        message: '<div style="text-align:left;">' + errMessage + "</div>"
      });
      return false;
    },

    /**
     * 医療材料(ダイアライザ含む)の更新.
     *
     */
    updateEquipInfo() {
      if(this.isReadOnly) {
        return;
      }
      if (!this.validate()) return false;
      // 更新対象リストを作成
      const equipmentList = new EquipmentList();
      // add #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng start
      const equipmentListCd = [];
      // add #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng end
      this.rstEquipInfoList.value().forEach((equip, index) => {
        // 削除データは更新対象から除去するため、スキップ
        if (this.rstEquipInfoList.get(index).be_deleted) {
          return;
        }
          // #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng start
          // equipmentList.add(
          //   this.rstEquipInfoList.get(index).is_edited
          //     ? this.rstEquipInfoList.get(index)
          //     : this.rstEquipInfoListInitial.get(index)
          // );
          if(!equipmentListCd.includes(equip.cd)) {
            equipmentList.add(
              this.rstEquipInfoList.get(index).is_edited
                ? this.rstEquipInfoList.get(index)
                : this.rstEquipInfoListInitial.get(index)
            );
          } else {
            const res = this.rstEquipInfoList.value().find(item => item.cd == equip.cd);
            const index = this.rstEquipInfoList.value().findIndex(item => item.cd == equip.cd);
            res.amount = (Number(res.amount) + Number(equip.amount)).toString();
            equipmentList.update(index, res);
          }
          equipmentListCd.push(equip.cd);
          // #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng end
      });
      // ダイアライザのID補正を除去
      equipmentList.list.forEach(obj => {
        if (obj.equip_type === 1) {
          // ダイアライザ用の内部展開したコード表現をDB永続化用のコードに戻す
          obj.cd = decryptDialyzerCdToPersistentCode(obj.cd);
          obj.class_cd = null;
        } else {
          obj.equip_type = 0;
        }
      });
      // 治療情報 実績:医療材料情報の更新
      this.putTreatmentRecordEquipInfo({
        ordNo: this.getOrdNo,
        treatmentRecordEquipInfo: {
          rst_dialysis_state: this.rstDialysisState,
          rst_equip_info: equipmentList.toString()
        }
      }).then(() => {
        // 初期化処理を実行
        this.init();
        // 子機能ボタンエリアの更新
        this.$emit("update");
      });
    },

    /**
     * 指定した医療材料(ダイアライザ含む)の削除.
     */
    deleteEquipInfo(targetIndex) {
      if (this.rstEquipInfoList.get(targetIndex).isNew) {
        // 追加行の場合
        this.rstEquipInfoList.removeAt(targetIndex);
        this.equipInfoListFromOrdMain();
      } else {
        // DB登録済み行の場合
        this.rstEquipInfoList.get(targetIndex).be_deleted = !this.rstEquipInfoList.get(targetIndex).be_deleted;
        this.rstEquipInfoList.get(targetIndex).is_edited = !this.rstEquipInfoList.get(targetIndex).is_edited;
      }
    },
    /**
     * 再描画処理
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue
      // if (this.isChanged && this.alertFlag) {
      //   this.discardConfirm(this.init);
      // } else {
      //   this.init();
      // }
      this.init();
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。end
      this.alertFlag = true;
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    eventBusRefresh() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      if (this.isChanged && this.alertFlag) {
        this.discardConfirm(this.init);
      } else {
        this.init();
      }
      this.alertFlag = true;
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    getChangeStatus(){
      return this.canDelete || this.canSave;
    },
    updateChangeStatus(){
      this.alertFlag = false;
    },

    diffValue(){
      let diffFlag = false;
      if (this.rstEquipInfoListInitial.list.length != this.rstEquipInfoList.list.length) {
        diffFlag = true;
      } else {
        for (let index = 0; index < this.rstEquipInfoListInitial.list.length; index++) {
          let beforeTarget =
            {
              cd:this.rstEquipInfoListInitial.get(index).cd,
              name:this.rstEquipInfoListInitial.get(index).name,
              amount:this.rstEquipInfoListInitial.get(index).amount,
            }

          let afterTarget =
            {
              cd:this.rstEquipInfoList.get(index).cd,
              name:this.rstEquipInfoList.get(index).name,
              amount:this.rstEquipInfoList.get(index).amount,
            }

          if (JSON.stringify(beforeTarget) !== JSON.stringify(afterTarget)) {
            diffFlag = true;
            break;
          }
          // 削除対象かどうか
          if (this.rstEquipInfoList.get(index).be_deleted) {
            diffFlag = true;
            break;
          }
        }
      }
      if (!diffFlag) {
        for (let index = 0; index < this.rstEquipInfoList.list.length; index++) {
          this.rstEquipInfoList.get(index).is_edited = false;
        }
      }
    },

    /**
     * 医療材料(ダイアライザ含む)一覧への行追加.
     */
    addRow(){
      // 追加する空行の準備(医療従事者の情報をセットする)
      this.rstEquipInfoList.add(
        Equipment.of({
          ind_user_id: this.stateUserAccountInfo.userId,
          ind_user_last_name: this.stateUserAccountInfo.userLastName,
          ind_user_first_name: this.stateUserAccountInfo.userFirstName,
          isNew: true,
          // #9848+9849 医療材料 追加の場合です 数量1 linjunfeng start
          amount: 1
          // #9848+9849 医療材料 追加の場合です 数量1 linjunfeng end
        })
      );
      // 医療材料一覧を表示するために治療情報の実績:医療材料(ダイアライザ含む)よりリストを生成する.
      this.equipInfoListFromOrdMain();
    }
  },
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // イベント登録
    EventBus.$on("refresh", this.eventBusRefresh);
    // OrdMainレコードをチェックする
    if (!this.checkOrdNo()) {
      return;
    }
    await this.init();
  },
  /**
   * コンポーネント破棄前.
   */
  beforeUnmount() {
    // dataの初期化(メモリリークに対する基本的な対応)
    Object.assign(this.$data, this.$options.data());
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    EventBus.$off("refresh", this.eventBusRefresh);
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
  },

  watch:{
    rstEquipInfoList: {
      handler(){
        this.diffValue();
      },
      deep: true,
    }
  },
};
</script>

<style scoped>
.ntss-list-header-th-sticky {
  z-index: 1;
}
.align-center {
  text-align: center;
}
.scroll-table {
  width: 1px;
}
.equipment-selector-td :deep(ons-col.text-value) {
  display: flex;
  align-items: center;
}
.equipment-selector-td :deep(.select-btn) {
  font-size: 1em;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
  margin: 0.1em;
}
/* 削除エリア */
.delete-col {
  width: 2.2em;
  min-width: 2.2em;
}
/* 追加項目 */
.added-item {
  background-color: #ccffcc !important;
}
/* 削除項目 */
.deleted-item {
  background-color: rgba(255, 0, 0, 0.5);
}
/* 削除ボタン */
.button-delete {
  max-width: 25px;
}
:deep(.com-basic-sub-btn) {
  margin-left: 5px;
}
:deep(.com-basic-sub-input) {
  min-width: 11em;
  width: 100%;
  background-color: #ebebe4;
}
</style>
