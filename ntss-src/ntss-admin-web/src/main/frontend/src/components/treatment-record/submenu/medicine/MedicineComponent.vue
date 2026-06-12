/**
* 治療記録の子機能 投与薬剤ページ
*/
<template>
  <submenu-base v-if="hasOrdNo">
    <template #main>
      <div id="medicine-component" style="width: calc(100% - 1px);">
      <div>
        <table class="treatment-record-list">
          <thead>
          <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
          <!-- start 治療記録バッグ修正 改修2 房 start -->
          <!-- mod FNSI-共有を追加 王 20200921 start -->
          <tr>
            <th colspan="9" style="background-image: none;">
              <div>
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <!-- <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!isShared" style="float: left;" @click="addRow()">追加</v-ons-button> -->
              <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!isShared|| !getItemAuthorized('TreatmentRecord', 'default_authority')" style="float: left;" @click="addRow()">追加</v-ons-button>
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              </div>
            </th>
          </tr>
          <!-- mod FNSI-共有を追加 王 20200921 end -->
          <!-- start 治療記録バッグ修正 改修2 房 end -->
          <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
          <tr>
            <th class="ntss-list-header-th-sticky" colspan="2">実施状況</th>
            <th class="ntss-list-header-th-sticky">薬剤名</th>
            <th class="ntss-list-header-th-sticky">数量</th>
            <th class="ntss-list-header-th-sticky">単位</th>
            <th class="ntss-list-header-th-sticky">手技</th>
            <th class="ntss-list-header-th-sticky">時間帯</th>
            <th class="ntss-list-header-th-sticky">実施者</th>
            <th class="ntss-list-header-th-sticky delete-col"></th>
          </tr>
          </thead>
          <tbody>
          <template v-for="(data, index) in mediInfoList.value()" :key="index">
            <tr  :class="['ntss-list-body-tr', data.is_new ? 'added-item' : '', data.be_deleted ? 'deleted-item' : '']">
              <td class='ntss-list-body-td align-center'>
                <v-ons-button
                  :class="['button', 'button-area', data.effect_flg == 1 ? 'done' : 'not-yet']"
                  @click="clickChangeEffectStatus(index)"
                >
                  {{ data.getEffectStatus() }}
                </v-ons-button>
              </td>
              <!--   #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start -->
              <td class='ntss-list-body-td' style="min-width:9em">
                <!-- mod FNSI-共有を追加 王 20200921 start -->
                <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
                <!-- <com-time-input
                  class="time-input"
                  :disabled="!isShared"
                  input-id="effect-time"
                  :value="data.effect_time"
                  :index="index"
                  @input="updateEffectDate"
                /> -->
                <v-ons-row>
                  <v-ons-col>
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                <!-- <com-time-input
                  :is-show-clear="true"
                  class="time-input"
                  :disabled="!isShared"
                  input-id="effect-time"
                  :value="data.effect_time"
                  :index="index"
                  @input="updateEffectDate"
                /> -->
                <com-time-input
                  class="time-input"
                  :classes="'' + inputClass('effect_time', index)"
                  :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                  input-id="effect-time"
                  v-model="data.effect_time"
                  :index="index"
                  @focus="onFocusTime(index)"
                  @input="updateEffectDate"
                />
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                </v-ons-col>
				        <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                  <!-- <common-calendar
                    v-model="data.effect_date"
                    class="button-calendar"
                    :disabled="!isShared"
                    @input="updateEffectDateByCalendar(index)"
                  /> -->
                  <common-calendar
                    v-model="data.effect_date"
                    class="button-calendar"
                    :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                    @input="updateEffectDateByCalendar(index)"
                  />
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                </v-ons-row>
                <!--   #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 end -->
                <!-- mod FNSI-共有を追加 王 20200921 end -->
              </td>
              <td class='ntss-list-body-td medicine-selector-td' style='min-width:15em; width: 100%;'>
                <!-- <com-master-selector
                  :index="index"
                  name="medicine-all"
                  labelName=""
                  :showLabelName="false"
                  :showClassFilter="true"
                  :readMasterData="fetchMedicineAll"
                  :masterDefine="masterDefine"
                  v-model="medicines[index]"
                  @input="onSelectMedicine"
                /> -->
                <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
                  <!--<v-ons-col>
                  <v-ons-col>
                    <show-selected-item
                      :propEditValue="medicines[index].name"
                      propBackgroundColor="#ebebe4"
                    />
                  </v-ons-col>-->
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                  <!--<com-master-selector
                    :index="index"
                    name="medicine-all"
                    labelName=""
                    :showLabelName="false"
                    :showClassFilter="true"
                    :readMasterData="fetchMedicineAll"
                    :masterDefine="masterDefine"
                    v-model="medicines[index]"
                    @input="onSelectMedicine"
                    :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
                    :isActiveBtn="false"
                  />-->
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                <common-master-selector
                  :masterType="MasterType.MEDICATION_TREATMENT_RECORD"
                  :initItem="{text:medicines[index].name, value: medicines[index].cd, unit: medicines[index] && medicines[index].unit != null ? medicines[index].unit : null}"
                  :editItem="{text:data.name, value: data.cd, unit: data.unit, procedureCd: data.procedure_cd, medicateTimingCd: data.timing_cd}"
                  :patientId="selectedPatId"
                  :extraParams="{ treatDate: treatDate, rstInfo: { rstName: medicines[index].name, rstUnit: data.unit }, medicineType: data.type != null ? data.type : (medicines[index].type != null ? medicines[index].type : data.medicine_type), actualName: medicines[index].name || data.name || '', compareProcedure: true, compareTiming: true, currentProcedureCd: data.procedure_cd, currentTimingCd: data.timing_cd }"
                  :facilityCd="getFacilityCd"
                  :dialysisState="Number(rstDialysisState)"
                  :hasChangedOption="true"
                  :changeOptionMode="'nameAndUnit'"
                  :selectedItemClass="'com-basic-sub-input'"
                  :backgroundColor="'#f7f7f7'"
                  :btnClass="'com-basic-sub-btn'"
                  :btnDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority')"
                  :isSelectionRequired="true"
                  :hasUnregisteredOption="false"
                  @popover-return="masterUpdateInput($event,index);"
                />
              <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
              </td>
              <td class='ntss-list-body-td number-input' style='width:1em'>
                <!-- mod FNSI-共有を追加 王 20200921 start -->
                <!-- mod FNSI7363-治療記録の投与薬剤の数量を患者経過総合ビューアの薬剤指示の数量上限と合わせる ljx start -->
                <!--<com-number-input
                 input-id="amount"
                 v-model="data.amount"
                 :disabled="!isShared"
                 name="amount"
                 :step="unitStep(index)"
                 :min=0
                 :max=9999999999.99
                 :initialValueLock="true"
                 @blur="onInputAmount(index)"
               /> -->
               <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
               <!-- <com-number-input
                 input-id="amount"
                 v-model="data.amount"
                 :disabled="!isShared"
                 name="amount"
                 :step="unitStep(index)"
                 :min=0
                 :max=999999
                 :initialValueLock="true"
                 @blur="onInputAmount(index)"
               /> -->
               <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start  -->
                <!-- <com-number-input
                 input-id="amount"
                 v-model="data.amount"
                 :disabled="!isShared"
                 name="amount"
                 :inputType='"number"'
                 :inputMin="0"
                 :inputMax="999999"
                 :step="unitStep(index)"
                 :initialValueLock="true"
                 @blur="onInputAmount(index)"
               /> -->
               <!-- mod #10359 編集権限の動作不正 start -->
               <!-- <custom-input-number-pro -->
               <!--    class="amount-number" -->
               <!--    name="amount" -->
               <!--    input-id="amount" -->
               <!--    :disabled="!isShared" -->
               <!--    :invalidArray="getInvalidArray(index)" -->
               <!--    :required="true" -->
               <!--    :value="data.amount" -->
               <!--    :min="0" -->
               <!--    :max="maxPrecision(index, 999999)" -->
               <!--    :step="unitStep(index)" -->
               <!--    @blur="onInputAmount(index)" -->
               <!--    @handlerInput="(val) =>{ data.amount = val }" -->
               <!--  /> -->
               <custom-input-number-pro
                  class="amount-number"
                  name="amount"
                  input-id="amount"
                  :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                  :invalidArray="getInvalidArray(index)"
                  :required="true"
                  :value="data.amount"
                  :min="0"
                  :max="maxPrecision(index, 999999)"
                  :step="unitStep(index)"
                  @blur="onInputAmount(index)"
                  @handlerInput="(val) =>{ data.amount = Number(val) }"
                />
               <!-- mod #10359 編集権限の動作不正 end -->
               <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end  -->
               <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
                <!-- mod FNSI7363-治療記録の投与薬剤の数量を患者経過総合ビューアの薬剤指示の数量上限と合わせる ljx end -->
               <!-- mod FNSI-共有を追加 王 20200921 end -->
              </td>
              <td class='ntss-list-body-td' style='min-width: 3em; width: 3em;'>{{ data.unit }}</td>
              <td class='ntss-list-body-td' style='min-width: 10em; width: 10em;'>
                <!-- mod FNSI-共有を追加 王 20200921 start -->
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                <!-- <v-ons-select
                  :class="inputClass('procedure_cd', index)"
                  class="selectbox"
                  select-id="procedure-cd"
                  :disabled="!isShared"
                  v-model="data.procedure_cd"
                  name="procedure-cd"
                  @change="onSelectProcedure(index)" > -->
                <v-ons-select
                  :class="inputClass('procedure_cd', index)"
                  class="selectbox"
                  select-id="procedure-cd"
                  :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                  v-model="data.procedure_cd"
                  name="procedure-cd"
                  @change="onSelectProcedure(index)" >
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
<!--                  upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start-->
                  <option v-for="(item, idx) in procedureCombo2DArray[index]" :key="idx" :value="item.cd" :hidden="item.hidden" :disabled="item.hidden">
                    {{ item.text }}
                  </option>
<!--                  upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end-->
                </v-ons-select>
                <!-- mod FNSI-共有を追加 王 20200921 end -->
              </td>
              <td class='ntss-list-body-td' style='min-width: 8em; width: 8em;'>
                <!-- mod FNSI-共有を追加 王 20200921 start -->
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                <!-- <v-ons-select
                  :class="inputClass('timing_cd', index)"
                  class="selectbox"
                  select-id="timing-cd"
                  :disabled="!isShared"
                  v-model="data.timing_cd"
                  name="timing-cd"
                  @change="onSelectTiming(index)" > -->
                <v-ons-select
                  :class="inputClass('timing_cd', index)"
                  class="selectbox"
                  select-id="timing-cd"
                  :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                  v-model="data.timing_cd"
                  name="timing-cd"
                  @change="onSelectTiming(index)" >
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
<!--                  upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start-->
                  <option v-for="(item, idx) in medicateTiming2DArray[index]" :key="idx" :value="item.cd" :hidden="item.hidden" :disabled="item.hidden">
                    {{ item.text }}
                  </option>
<!--                  upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end-->
                </v-ons-select>
                <!-- mod FNSI-共有を追加 王 20200921 end -->
              </td>
              <td class='ntss-list-body-td personal-select-td' style='width: 12em; min-width:12em;'>
                <!-- <com-master-selector
                  :index="index"
                  name="personal-user-all"
                  labelName=""
                  :showLabelName="false"
                  :showClassFilter="true"
                  :readMasterData="fetchPersonalUserAll"
                  :masterDefine="personalUser"
                  v-model="effectUsers[index]"
                  @input="data.is_edited = true"
                  @changePersonalUser="setEffectUserByIndex"
                /> -->
                <v-ons-row>
             <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->

                  <!-- mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start-->
<!--                  <com-master-selector-->
<!--                    :index="index"-->
<!--                    name="personal-user-all"-->
<!--                    labelName=""-->
<!--                    :showLabelName="false"-->
<!--                    :showClassFilter="true"-->
<!--                    :readMasterData="fetchPersonalUserAll"-->
<!--                    :masterDefine="personalUser"-->
<!--                    v-model="effectUsers[index]"-->
<!--                    @input="data.is_edited = true"-->
<!--                    @changePersonalUser="setEffectUserByIndex"-->
<!--                    :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority')"-->
<!--                  />-->
                  <common-master-selector
                    :masterType="MasterType.PERSONAL_USER_TREATMENT_RECORD"
                    :facilityCd="getFacilityCd"
                    :initItem="{ text: effectUsers[index] ? effectUsers[index].name : null, value: effectUsers[index] ? effectUsers[index].cd : null }"
                    :editItem="{ text: effectUsers[index] ? effectUsers[index].name : null, value: effectUsers[index] ? effectUsers[index].cd : null }"
                    :selectedItemClass="'com-basic-sub-input'"
                    :backgroundColor="'#f7f7f7'"
                    :btnClass="'com-basic-sub-btn'"
                    :hasUnregisteredOption="true"
                    :btnDisabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                    @popover-return="onPopoverEffectUser($event, index)"
                  />
                  <!-- mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end-->
             <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                </v-ons-row>
              </td>
              <td class="ntss-list-body-td">
                <button class="ntss-btn-outset button-delete" @click="deleteMediInfo(index)">
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
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="registration-btn-area">
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start-->
<!--        <v-ons-button class="button registration-btn btn1-execute" :disabled="!canSave || isReadOnly || !isShared" @click="updateMediInfo">保存</v-ons-button>-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <!-- <v-ons-button class="button registration-btn btn1-execute" :disabled="isEditable" @click="updateMediInfo">保存</v-ons-button> -->
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||isEditable" @click="updateMediInfo">保存</v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end-->
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
      </div>
    </template>
  </submenu-base>
</template>

<script>
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";

import { parseStoredArray } from "@/functions/common/CommonFunctions";
  import dayjs from "@/compat/date/dayjs";
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
  import {mapGetters, mapActions, mapMutations} from "@/compat/vue/vuex";
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
  import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
  import CommonTimeComponent from "@/components/treatment-record/submenu/common/CommonTimeComponent";
  import {
    medicineAll,
    personalUser
  } from "@/components/common/master-selector/MasterSelectorDefinitions";
  //mod FutreNetWeb+SI課題管理 no.5531 劉全航 start
  // import CommonMasterSelectorComponent from "@/components/common/master-selector/CommonMasterSelectorComponent";
  import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
  //mod FutreNetWeb+SI課題管理 no.5531 劉全航 end
  import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
  //import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  import {
    sendRequestGetMstMedicineTabooAllergy,
    sendRequestGetMstMedicineClass,
    sendRequestGetMstMedicineMixTabooAllergy,
    getMedicineAllTabooAllergy,
  } from "@/apis/treatment-record";
  import { CODES } from "@/constants/TreatmentRecord";
  // import { AUTHORITY_CODES } from "@/constants/userAuthority";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  import { Master } from "@/models/common/master-selector-condition/Master";
  import { MediInfo } from "@/models/treatment-record/medicine/MediInfo";
  import { MediInfoList } from "@/models/treatment-record/medicine/MediInfoList";
  import {
    DATE_FORMAT,
    SHORT_TIME_FORMAT,
    dateFormat
  } from "@/functions/common/DateTimeUtils";
  import { EventBus } from "@/compat/vue/event-bus.js";
  import BigNumber from "@/compat/number/bignumber";
  import CommonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
  import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
  import { sendRequestGetMstPersonalUser, sendRequestMstGetJobs } from "@/apis/user-selector-popover";
  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
  import { ApiHelper } from "@/apis/AxiosHelper";
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
  // add #10359 編集権限の動作不正 start
  // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
  // import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
  // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
  // add #10359 編集権限の動作不正 end
  // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
  import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
  // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
  // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
  import { medicineAllergy, medicineMixAllergy } from "@/functions/mst/MstGetters.js";
  // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
  import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
  import * as MasterType from "@/components/common/master-selector/MasterType";
  import { getMstListCompose } from "@/apis/pat-prescription"
  import { getMasterConfig } from "@/components/common/master-selector/builder/masterPopoverConfig";
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  export default {
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
    mixins: [DiscardConfirmationMixin],
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    components: {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      "common-master-selector": commonMasterSelector,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      "submenu-base": SubmenuBase,
      "com-master-selector": CommonMasterSelectorComponent,
      "com-time-input": CommonTimeComponent,
      "com-number-input": CommonNumberInputComponent,
      // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
      "custom-input-number-pro":CustomInputNumberPro,
      // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
      "common-calendar": CommonCalender,
      "show-selected-item": CustomDivShowSelectedItem
    },
    data() {
      return {
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        initItem:{},
        MasterType,
        mstData:{},
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        mediInfoList: new MediInfoList(),
        mediInfoListInitial: new MediInfoList(),
        treatDate: "",
        rstDialysisState: "",
        rstStartDate: "",
        rstEndDate: "",
        procedureComboList: [],
        //add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
        procedureCombo2DArray: [],
        medicateTimingComboList: [],
        medicateTiming2DArray: [],
        //add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
        masterDefine: medicineAll,
        latestMedicine: [],
        latestMedicineMix: [],
        latestMedicineClass: [],
        personalUser: personalUser,
        latestPersonalUser: [],
        medicines: [],
        effectUsers: [],
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
        // authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
        selfScreenName: "",
        //add FNSI-改修内容：初期flag追加 房 start
        initFlg: false,
        alertFlag: true,
        mediNoticeFlag: false,
        surplusList: new MediInfoList(),
        tempSurplusList: new MediInfoList(),
        //add FNSI-改修内容：初期flag追加 房 end
        aFlag: false
      };
    },
    computed: {
      ...mapGetters("treatment-record/grid-size", {
        gridHeight: "getHeight"
      }),
      ...mapGetters("account-edit", {
        stateUserAccountInfo: "getStateUserAccountInfo",
        userId: "getUserId",
        userName: "getUserName"
      }),
      ...mapGetters("treatment-record/common", [
        "getOrdNo",
        "getOrd",
        "getSharedFacilityCd",
        "getDialysisState",
        "getRstEditionDate"
      ]),
      ...mapGetters("window-size", {
        windowWidth: "getMainWindowWidth"
      }),
      ...mapGetters("pat-info", ["selectedPatId"]),
      ...mapGetters("user", { facilityCd: "getFacilityCd" }),
      // add FNSI-共有を追加 王 20200921 start
      ...mapGetters("user", ["getFacilityCd"]),
      ...mapGetters("mst-user", {getSharedFlag: "getIsRegisteredShared"}),
      isShared() {
        return this.getFacilityCd === this.getSharedFacilityCd;
      },
      // add FNSI-共有を追加 王 20200921 end

      canDelete() {
        return this.mediInfoList.beDeleted();
      },
      canSave() {
        return this.mediInfoList.hasEditedMediInfo();
      },
      isPastInfo() {
        //upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
        return (
          // this.rstDialysisState === CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd
          this.rstDialysisState > CODES.DIALYSIS_STATE.BEFORE_SEND_CONDITION.cd
        );
        //upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
      },
      isChanged() {
        return this.canDelete || this.canSave;
      },

      isReadOnly() {
        return this.getOrd.readOnly;
      },
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      isEditable(){
        this.setIsPatInfoChaned(!(!this.canSave || this.isReadOnly || !this.isShared))
        return !this.canSave || this.isReadOnly || !this.isShared
      }
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    },

    methods: {
      // #9195 投与薬剤を追加してすぐに消える時がある zihao start
      ...mapActions("loading-screen", {
        setLoadingScreenVisible: "setLoadingScreenVisible",
        setLoadingScreenMessage: "setLoadingScreenMessage",
      }),
      // #9195 投与薬剤を追加してすぐに消える時がある zihao end
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      async masterUpdateInput(data,index){
        //this.medicinesp[index].name = data.text
        //this.medicinesp[index].cd = data.value
        const medicineKbn = data.kbnValue ?? data.key_type ?? data._sourceTag;
        await this.onSelectMedicine({name:data.text,cd: Number(data.value),type:medicineKbn},index)
        //this.medicines[index].name = this.mediInfoList.get(index).name
        this.mediInfoList.get(index).cd = Number(data.value)
        this.mediInfoList.get(index).name = data.text
        this.mediInfoList.get(index).unit = data && data.unit != null ? data.unit : this.mediInfoList.get(index).unit
        const row = this.mediInfoList.get(index);
        const procedureCd =
          data && (data.procedureCd != null ? data.procedureCd : (data.procedure_cd != null ? data.procedure_cd : null));
        const timingCd =
          data && (data.medicateTimingCd != null ? data.medicateTimingCd :
            (data.medicate_timing_cd != null ? data.medicate_timing_cd :
              (data.timingCd != null ? data.timingCd : (data.timing_cd != null ? data.timing_cd : null))));
        if (procedureCd != null && procedureCd !== "") row.procedure_cd = procedureCd;
        if (timingCd != null && timingCd !== "") row.timing_cd = timingCd;

        if (procedureCd != null && procedureCd !== "") {
          const procOpts = this.procedureCombo2DArray && this.procedureCombo2DArray[index] ? this.procedureCombo2DArray[index] : [];
          const procOpt = procOpts.find(opt => opt && String(opt.cd) === String(procedureCd));
          if (procOpt && procOpt.text != null) row.procedure_name = procOpt.text;
        }
        if (timingCd != null && timingCd !== "") {
          const timingOpts = this.medicateTiming2DArray && this.medicateTiming2DArray[index] ? this.medicateTiming2DArray[index] : [];
          const timingOpt = timingOpts.find(opt => opt && String(opt.cd) === String(timingCd));
          if (timingOpt && timingOpt.text != null) row.timing_name = timingOpt.text;
        }
      },
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      // #5835【リクレーション】治疗记录药剂不能实施 訾浩 statr
      checkHandle (index) {
         if (this.mediInfoList.value()[index] && this.mediInfoList.value()[index].effect_user_first_name && this.mediInfoList.value()[index].effect_user_last_name && (this.mediInfoList.value()[index].name == undefined || this.mediInfoList.value()[index].amount == undefined || this.mediInfoList.value()[index].procedure_cd == undefined)) {
          this.aFlag = false
        } else if (this.mediInfoList.value()[index] && this.mediInfoList.value()[index].effect_user_first_name && this.mediInfoList.value()[index].effect_user_last_name && ((this.mediInfoList.value()[index].name !== null) && (this.mediInfoList.value()[index].name !== undefined)) && ((this.mediInfoList.value()[index].amount !== null) && (this.mediInfoList.value()[index].amount !== undefined)) && ((this.mediInfoList.value()[index].procedure_cd !== null) && (this.mediInfoList.value()[index].procedure_cd !== undefined))) {
          this.aFlag = true
        } else if (this.mediInfoList.value()[index] && !this.mediInfoList.value()[index].effect_user_first_name && !this.mediInfoList.value()[index].effect_user_last_name && ((this.mediInfoList.value()[index].name !== null) && (this.mediInfoList.value()[index].name !== undefined))) {
          this.aFlag = true
        } else {
          this.aFlag = false
        }
      },
      // #5835【リクレーション】治疗记录药剂不能实施 訾浩 end
      ...mapActions("treatment-record/mediInfo", {
        getTreatmentRecordMediInfo: "getTreatmentRecordMediInfo",
        updateTreatmentRecordMediInfo: "updateTreatmentRecordMediInfo",
        //add FNSI内容修正 外部Api調用 房 start
        sendRequestChangeIndMediInfoRst: "sendRequestChangeIndMediIn",
        //add FNSI内容修正 外部Api調用 房 end
      }),
      ...mapActions("reference-combo", {
        getProcedureComboList: "getProcedureComboList",
        getMedicateTimingComboList: "getMedicateTimingComboList"
      }),
      //add FNSI内容修正 外部Api調用 房 start
      ...mapActions("treatment-record/common", ["getMstMachineByOrdNoRst", "sendGetNoticeMedi"]),
      //add FNSI内容修正 外部Api調用 房 end
      ...mapActions("pat-viewer", [
        "getMstRecordInState",
        //add FNSI-修正 #8356 【デグレ】治療記録－投与薬剤の表示順が施設設定の設定順序とならない　周安寧 start
        "getMstMedicineTabooAllergy",
        "getMstMedicine",
        "getMstMedicineAllergy" ,
        "getMstMedicineMixTabooAllergy",
        "getMstMedicineMix",
        "getMstMedicineMixAllergyData"
        //add FNSI-修正 #8356 【デグレ】治療記録－投与薬剤の表示順が施設設定の設定順序とならない　周安寧 end
      ]),
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      // add #10359 編集権限の動作不正 start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },
      // add #10359 編集権限の動作不正 end
      // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている横展開 訾浩 start
      onInputAmount(index) {
        this.$nextTick(() => {
          const initialVal = Number(this.mediInfoListInitial.get(index).amount);
          const newVal = Number(this.mediInfoList.get(index).amount);
          this.mediInfoListInitial.get(index).amount = Number(this.mediInfoListInitial.get(index).amount)
          if (newVal != initialVal) {
            // 過去実積以外は全マスタを更新
            if (!this.isPastInfo) {
              this.mediInfoList.refreshAllMaster(index);
            }
            // del 治療記録バッグ修正 改修2 房 start
            // this.setNewRecord(index);
            // del 治療記録バッグ修正 改修2 房 end
            this.mediInfoList.get(index).setUpdUser(this.stateUserAccountInfo);
          }
          this.checkHandle(index)
        });
      },
      unitStep(index){
        var num = parseInt(this.mediInfoList.get(index).decPoint);
        if(isNaN(num)){
          num = 0;
        }
        var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
        return data;
      },
      // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
      maxPrecision(index, value) {
        let num = parseInt(this.mediInfoList.get(index).decPoint);
        if(isNaN(num)){
          return value;
        }
        const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
        return Number(decimalNumber.toFixed(num));
      },
      getInvalidArray(index) {
        let arr = [];
        let num = parseInt(this.mediInfoList.get(index).decPoint);
        let zero = 0;
        let data = isNaN(num) ? "0" : zero.toFixed(num);
        arr.push(data)
        return arr;
      },
      /**
       * 薬剤情報を表示用の情報に変換
       */
      convertMedicine2Master() {
        this.medicines = this.mediInfoList.value().map((m) => {
          //del 治療記録バッグ修正 改修2 房 start
          // if (index === 0) {
          //   // グリッドの１行目は新規行なので薬剤名は設定されていない
          //   return new Master();
          // }
          //del 治療記録バッグ修正 改修2 房 end
          // 過去実績
          if (this.isPastInfo) {
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // return new Master(m.cd, m.name);
            let cd = m.cd;
            if (m.medicine_type == CODES.MEDICINE_TYPE.MIX.cd) {
              // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
              //cd = m.cd + "$";
              cd = m.cd;
              // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
            }
            const master = new Master(cd, m.name);
            master.unit = m && m.unit != null ? m.unit : null;
            return master;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          }
          // 薬剤コード
          let medicineByCd;
          // 薬剤名称
          let medicineName;
          let medicineCd;
          // 通常薬剤の場合
          //mod FNSI-修正redmine4745 房 start
          if (m.medicine_type == CODES.MEDICINE_TYPE.NORMAL.cd) {
            medicineByCd = this.latestMedicine.find(
              lm => lm.medicineCd == m.cd && lm.isDisp === CODES.IS_DISP.DISPLAY.cd
            );
            if (medicineByCd !== undefined) {
              medicineCd = medicineByCd.medicineCd;
              medicineName = medicineByCd.medicineName;
            }
            // 調整薬剤の場合
          } else if (m.medicine_type == CODES.MEDICINE_TYPE.MIX.cd) {
            medicineByCd = this.latestMedicineMix.find(
              lmm => lmm.medicineMixCd == m.cd && lmm.isDisp === CODES.IS_DISP.DISPLAY.cd
            );
            if (medicineByCd !== undefined) {
              medicineCd = medicineByCd.medicineMixCd + "$";
              medicineName = medicineByCd.medicineMixName;
            }
          }
          //mod FNSI-修正redmine4745 房 end
          //add 治療記録バッグ修正 改修2 房 start
          let reMedicineName = "";
          if (m.is_new) {
            reMedicineName = medicineByCd === undefined ? "" : medicineName;
          } else {
            reMedicineName = medicineByCd === undefined ? `【削除】${m.name}` : medicineName;
          }
          //add 治療記録バッグ修正 改修2 房 end
          const master = new Master(medicineCd, reMedicineName);
          master.unit = m && m.unit != null ? m.unit : null;
          return master;
        });
      },
      // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
      createEffectUserValue(index) {
        const m = this.mediInfoList.value()[index];
        let fName = '';
        if (m.effect_user_first_name != null && m.effect_user_first_name.toString().trim() !== "") {
          fName = m.effect_user_first_name.toString();
        }
        let lName = '';
        if (m.effect_user_last_name != null && m.effect_user_last_name.toString().trim() !== "") {
          lName = m.effect_user_last_name.toString();
        }
        let userId = '';
        if (m.effect_user_id != null && m.effect_user_id.toString().trim() !== "") {
          userId = m.effect_user_id;
        }
        else {
          userId = this.stateUserAccountInfo.userId;
        }
        // return this.effectUsers[index] || new Master(userId, '' !== lName || '' !== fName ? lName + " " + fName : '');
        this.effectUsers[index] = new Master(userId, '' !== lName || '' !== fName ? lName + " " + fName : '');
        return this.effectUsers[index];
      },
      // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
      convertEffectUser2Master() {
        // mod #7784「治療記録の投薬で実施者が表示されない項目がある」について、対応する。 dengshen start
        // this.effectUsers = this.mediInfoList.value().map(m => {
        //   if (m.effect_user_id === null) return new Master();
        //   const effectUser = this.latestPersonalUser.find(
        //     lm => lm.userId === m.effect_user_id
        //   );
        //   if (effectUser === undefined) {
        //     return new Master(m.effect_user_id, m.effect_user_id.toString());
        //   } else {
        //     const fullName = this.isPastInfo
        //       ? m.getEffectUserFullName()
        //       : `${effectUser.userLastName} ${effectUser.userFirstName}`;
        //     return new Master(m.effect_user_id, fullName);
        //   }
        // });
        this.effectUsers = this.mediInfoList.value().map(m => {
          let fName = '';
          if ( m.effect_user_first_name != null && m.effect_user_first_name.toString().trim() != "") {
            fName = m.effect_user_first_name.toString();
          }
          let lName = '';
          if ( m.effect_user_last_name != null && m.effect_user_last_name.toString().trim() != "") {
            lName = m.effect_user_last_name.toString();
          }
          let userId = '';
          if ( m.effect_user_id != null && m.effect_user_id.toString().trim() != "") {
            userId = m.effect_user_id.toString();
          }
          return new Master(userId, '' != lName || '' != fName ? lName + " " + fName : '');
        });
        // mod #7784「治療記録の投薬で実施者が表示されない項目がある」について、対応する。 dengshen end
      },
      /**
       * コンボボックスのリスト変換処理.
       */
      comboListMatchingBody(list, e, cd, text, fieldName) {
        //add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
        let newList = [];
        const node = list.find(elem => elem.cd === cd);

        // 名称変更/削除なしの場合は何もしない
        if (node !== undefined && node.text === text) {
          if(fieldName === 'procedure_name'){
            this.procedureCombo2DArray.push(list);
          }
          if(fieldName === 'timing_name'){
            this.medicateTiming2DArray.push(list);
          }
          return;
        }
        //add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
        // 過去実績の場合はリストに追加
        if (this.isPastInfo) {
          //upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
          newList = [{ cd: cd, text: text, hidden: true }].concat(list);
          // list.unshift({ cd: cd, text: text, hidden: true });
          if(fieldName === 'procedure_name'){
            this.procedureCombo2DArray.push(newList);
          }
          if(fieldName === 'timing_name'){
            this.medicateTiming2DArray.push(newList);
          }
          //upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
          return;
        }

        // 過去実績以外の場合
        // マスタ削除の場合は【削除】を付加
        if (node === undefined) {
          if (text) {
            text = `【削除】${text}`;
            //upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
            // list.unshift({ cd: cd, text: text, hidden: true });
            newList = [{ cd: cd, text: text, hidden: true }].concat(list);
            if(fieldName === 'procedure_name'){
              this.procedureCombo2DArray.push(newList);
            }
            if(fieldName === 'timing_name'){
              this.medicateTiming2DArray.push(newList);
            }
            //upd #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
          }
        } else {
          // マスタ名称変更の場合は最新名称に更新
          e[fieldName] = node.text;
          //add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
          if(fieldName === 'procedure_name'){
            this.procedureCombo2DArray.push(list);
          }
          if(fieldName === 'timing_name'){
            this.medicateTiming2DArray.push(list);
          }
          //add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
        }
      },
      /**
       * 薬剤マスタ及び調整薬剤マスタ、薬剤分類を取得する.
       */
      fetchMedicineAllWithMix(opts = {}) {
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        const initCd =
          opts.initCd != null && opts.initCd !== "" ? String(opts.initCd).trim() : null;
        const medicineType = opts.medicineType;
        const extraParams = {
          treatDate: this.treatDate || "",
          rstInfo: { rstName: "", rstUnit: "" },
          ...(medicineType != null ? { medicineType } : {}),
          ...(initCd != null ? { initValue: initCd } : {})
        };
        const context = {
          facilityCd: this.facilityCd,
          patientId: this.selectedPatId,
          extraParams,
          initItem: initCd != null ? { value: initCd } : {},
          selectedItem: initCd != null ? { value: initCd } : {},
          dialysisState: Number(this.rstDialysisState || 0),
          allowedFields: {}
        };
        const item = getMasterConfig(MasterType.MEDICATION_TREATMENT_RECORD, context);
        return Promise.all([
          sendRequestGetMstMedicineTabooAllergy(this.selectedPatId),
          sendRequestGetMstMedicineMixTabooAllergy(this.selectedPatId),
          sendRequestGetMstMedicineClass(this.selectedPatId),
          getMstListCompose(item)
        ]);
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      },
      /**
       * 薬剤マスタ及び調整薬剤マスタ、薬剤分類を取得する.
       * ※薬剤選択画面用
       */
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      async fetchMedicineAll(index) {
        // return Promise.all([
        //   getMedicineAllTabooAllergy(this.selectedPatId),
        //   sendRequestGetMstMedicineClass()
        // ])
        const cd = this.mediInfoListInitial.get(index).cd;
        const name = this.mediInfoListInitial.get(index).name;
        let medicineList = Promise.all([
          getMedicineAllTabooAllergy(this.selectedPatId),
          sendRequestGetMstMedicineClass(this.selectedPatId)
        ]);
        await medicineList.then(async (response)=>{
          let medicinePopover = response[0].data;
          medicinePopover.forEach((item) => {
            item.medicineName = getPrefix(item) + item.medicineName;
          })
          let medicinePopoverCd = medicinePopover.map(item => item.medicineCd)
          // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
          let patId = this.selectedPatId ? this.selectedPatId : "-1";
          // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
          if (!medicinePopoverCd.includes(Number(cd))) {
            // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
            let medicineAll = await medicineAllergy(patId, true);
            // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
            let medicineAllObj = medicineAll.find(item => item.medicineCd == cd);
            if (!medicineAll) {
              // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
              let medicineMixAll = await medicineMixAllergy(patId, true);
              // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
              medicineAllObj = medicineMixAll.find(item => item.medicineMixCd == cd);
            }
            if (medicineAllObj) {
              let obj = {
                classCd: medicineAllObj.classCd,
                isDisp: "1",
                medicineCd: cd,
                medicineName: name,
                medicineType: medicineAll ? 1 : 2,
                unit: medicineAllObj.unit,
                unitDecimalPoint: medicineAllObj.unitDecimalPoint,
                unitDecimalPointSecond: medicineAllObj.unitDecimalPointSecond,
                unitSecond: medicineAllObj.unitSecond,
              }
              medicinePopover.push(obj)
            }
          } else {
            medicinePopover.forEach((item) => {
              if (item.medicineCd == cd) {
                item.medicineName = name;
                item.medicineCd = cd;
              }
            })
          }
          return medicinePopover;
        })
        // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        //this.medicines[index].cd = cd+"$";
        this.medicines[index].cd = cd;
        // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        return medicineList;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      },
      fetchPersonalUserAll() {
        return Promise.all([
          sendRequestGetMstPersonalUser(this.facilityCd, this.selectedPatId),
          sendRequestMstGetJobs(this.facilityCd, this.selectedPatId)
        ]);
      },
      /**
       * 薬剤選択時イベント
       * @param master 選択薬剤マスタ
       * @param index 変更行インデックス
       */

      onSelectMedicine(master, index) {
        // コードと名称を更新
        this.mediInfoList.get(index).cd = master.cd;
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        this.mediInfoList.get(index).type = master.type;
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

        // 過去実積なら薬剤のみ更新、それ以外は全マスタ及び薬剤情報を更新
        if (this.isPastInfo) {
          this.mediInfoList.refreshMedicineAndClass(index);
          this.mediInfoList.get(index).setUpdUser(this.stateUserAccountInfo);
        } else {
          this.mediInfoList.refreshAllMasterAndMediInfo(index);
        }
        // del 治療記録バッグ修正 改修2 房 start
        // this.setNewRecord(index);
        // del 治療記録バッグ修正 改修2 房 end
        this.checkHandle(index)
      },
      // 手技コード
      onSelectProcedure(index) {
        this.$nextTick(() => {
          // 過去実積なら手技のみ更新、それ以外は全マスタを更新
          if (this.isPastInfo) {
            this.mediInfoList.refreshProcedure(index);
            this.mediInfoList.get(index).setUpdUser(this.stateUserAccountInfo);
          } else {
            this.mediInfoList.refreshAllMaster(index);
          }
          // del 治療記録バッグ修正 改修2 房 start
          // this.setNewRecord(index);
          // del 治療記録バッグ修正 改修2 房 end
        });
        this.checkHandle(index)
      },
      // 時間帯コード
      onSelectTiming(index) {
        this.checkHandle(index)
        this.$nextTick(() => {
          // 過去実積なら時間帯のみ更新、それ以外は全マスタを更新
          if (this.isPastInfo) {
            this.mediInfoList.refreshMedicateTiming(index);
            this.mediInfoList.get(index).setUpdUser(this.stateUserAccountInfo);
          } else {
            this.mediInfoList.refreshAllMaster(index);
          }
          // del 治療記録バッグ修正 改修2 房 start
          // this.setNewRecord(index);
          // del 治療記録バッグ修正 改修2 房 end
        });
      },
      syncCurrentMedicineUnit() {
        if (this.isPastInfo) {
          return;
        }
      },
      // 小数点桁数セット
      syncCurrentMedicineDecPoint(tempMediInfoList) {
        let treatMedicine;
        tempMediInfoList.value().map(m => {
          treatMedicine = null;
          // mod #9973 shiyw  start
          //if(m.medicine_type === CODES.MEDICINE_TYPE.NORMAL.cd){
          if(m.medicine_type == CODES.MEDICINE_TYPE.NORMAL.cd){
            // mod #9973 shiyw  end
            treatMedicine = this.latestMedicine.find(
              medi => medi.medicineCd === m.cd
            );
            // mod #9973 shiyw  start
            //}else if(m.medicine_type === CODES.MEDICINE_TYPE.MIX.cd){
          }else if(m.medicine_type == CODES.MEDICINE_TYPE.MIX.cd){
            // mod #9973 shiyw  end
            treatMedicine = this.latestMedicineMix.find(
              medi => medi.medicineMixCd === m.cd
            );
          }
          if (treatMedicine !== undefined && treatMedicine != null) m.decPoint = treatMedicine.unitDecimalPoint;
          return m;
        });
        return tempMediInfoList;
      },

      /**
       * 実施者設定
       * 選択画面で未登録が選択された場合には、実施状況の時刻も合わせてクリアする.
       *
       * @param {*} effectUserInfo 選択された利用者情報
       * @param {Integer} index 選択された投与薬剤のインデックス
       */
      setEffectUserByIndex(effectUserInfo, index) {
        this.mediInfoList.get(index).setEffectUser(effectUserInfo);
        this.mediInfoList.get(index).setUpdUser(this.stateUserAccountInfo);
        this.setNewRecord(index);
        if (effectUserInfo && !this.mediInfoList.get(index).effect_time) {
          // デフォルト日時設定
          this.mediInfoList.get(index).effect_date = this.getDefaultDate();
          const effectTime = this.getDefaultTime();
          // 実施状況を設定する関数を呼ぶ
          this.updateEffectDate(effectTime, index);
        }
        // 過去実積以外は全マスタを更新
        if (this.isPastInfo) {
          this.mediInfoList.refreshAllMaster(index);
        }
        this.mediInfoList.get(index).setUpdUser(this.stateUserAccountInfo);
        this.setNewRecord(index);
        // 実施者選択で未登録が選択された場合、実施状況の時刻をクリアする.
        if (effectUserInfo === undefined) {
          this.updateEffectDate(null, index);
        }
        this.checkHandle(index)
        // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
        if (effectUserInfo === undefined) {
          this.effectUsers[index] = new Master();
        } else {
          this.createEffectUserValue(index);
        }
        // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
      },
      onPopoverEffectUser(item, index) {
        if (!item) return;
        const uid = item.value != null ? item.value : item.key_cd ?? item.userId;
        if (uid == null || uid === "") {
          this.setEffectUserByIndex(undefined, index);
          return;
        }
        const personal = item.personalUserInfo;
        const userInfo = personal
          ? { id: personal.id, lastName: personal.lastName, firstName: personal.firstName }
          : {
              id: uid,
              lastName: item.userLastName != null ? item.userLastName : null,
              firstName: item.userFirstName != null ? item.userFirstName : null
            };
        this.setEffectUserByIndex(userInfo, index);
      },
      updateEffectDateByCalendar(index) {
        //mod FNSI-改修内容：初期flag追加 房 start
        //this.mediInfoList.get(index).setOnlyEffectDate(index, dayjs(this.mediInfoList.get(index).effect_date).format('YYYYMMDD'), true);
        this.mediInfoList.get(index).setOnlyEffectDate(dayjs(this.mediInfoList.get(index).effect_date).format('YYYYMMDD'), this.initFlg);
        //mod FNSI-改修内容：初期flag追加 房 end
      },
      /**
       * 実施状況の更新
       *
       * @param {Date} 投与時間
       * @param {Integer} 対象の投与薬剤のインデックス
       */
      updateEffectDate(effectTime, index) {
        this.checkHandle(index)
        this.$nextTick(() => {
          const initialVal = this.mediInfoListInitial.get(index).effect_time;
          const newVal = effectTime;
          this.mediInfoList.get(index).effect_time = newVal;
          // mod 治療記録バッグ修正 改修 周雨晴 start
          if (this.mediInfoList.get(index).effect_date === null) {
            this.mediInfoList.get(index).setOnlyEffectDate(dayjs().format('YYYYMMDD'), this.initFlg);
          }
          // mod 治療記録バッグ修正 改修 周雨晴 end

          // effectTimeがnullの場合、以降の処理は行わない.
          if (newVal === null) {
            // デフォルト日付設定
            const effectDate = this.getDefaultDate();
            this.mediInfoList.get(index).is_edited = true;
            this.mediInfoList
              .get(index)
              .setEffectDate(null, this.stateUserAccountInfo, effectDate);
            // 実施者が登録されている場合にはクリアする.
            this.mediInfoList.get(index).setEffectUser(undefined);
            // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj del start
            // this.setNewRecord(index);
            // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj del end
            // FNSI-修正 #6525 投与薬剤の実施判定不正、xugj mod start
            this.effectUsers[index] = new Master();
            // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう zhangyue start
            // this.mediInfoList.get(index).is_edited = false;
            // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう zhangyue end
            // FNSI-修正 #6525 投与薬剤の実施判定不正、xugj mod end
            return;
          }
          const effectDate = dayjs(this.mediInfoList.get(index).effect_date).format('YYYYMMDD');
          this.mediInfoList
            .get(index)
            .setEffectDate(this.treatDate, this.stateUserAccountInfo, effectDate);
          this.setNewRecord(index);
          // 過去実積以外は全マスタを更新
          if (!this.isPastInfo) {
            this.mediInfoList.refreshAllMaster(index);
          }

          //mod FNSI修正外結バッグ40 房 start
          if (this.mediInfoList.get(index).effect_user_id == null || this.mediInfoList.get(index).effect_user_id == undefined) {
            this.effectUsers[index] = new Master(this.userId, this.userName);
            // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj mod start
            // 実施者にサインイン中ユーザーを設定する
            const userInfo = {
              id: this.userId,
              firstName: this.stateUserAccountInfo.userFirstName,
              lastName: this.stateUserAccountInfo.userLastName
            };
            this.setEffectUserByIndex(userInfo, index);
            this.mediInfoList.get(index).is_edited = true;
            // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj mod end
          }
          //mod FNSI修正外結バッグ40 房 end
        });
      },
      deleteMediInfo(targetIndex) {
        const targetItem = this.mediInfoList.get(targetIndex);
        if (targetItem.is_new) {
          // 追加行の場合
          this.mediInfoListInitial.removeAt(targetIndex);
          this.mediInfoList.removeAt(targetIndex);
          this.convertMedicine2Master();
          this.convertEffectUser2Master();
          this.procedureCombo2DArray.push(this.procedureComboList)
          this.medicateTiming2DArray.push(this.medicateTimingComboList)
        } else {
          // DB登録済み行の場合
          targetItem.be_deleted = !targetItem.be_deleted;
          targetItem.is_edited = true;
        }
      },
      updateMediInfo() {
        if(this.isReadOnly) {
          return;
        }

        // 空行は削除して保存する
        const { tempMediInfoList, tempMediInfoListInitial } = this.removeEmptyRows();

        // 空行はvalidate対象外
        const validateMediInfoList = new MediInfoList();
        validateMediInfoList.addAll(tempMediInfoList);
        if (this.validate(validateMediInfoList) === false) {
          return;
        }

        // リストを更新
        this.mediInfoList.deleteAll();
        this.mediInfoList.addAll(tempMediInfoList);
        this.mediInfoListInitial.deleteAll();
        this.mediInfoListInitial.addAll(tempMediInfoListInitial);

        // 更新対象リストを作成
        const mediInfoList = new MediInfoList();
        //del 治療記録バッグ修正 改修2 房 start
        // if (!this.mediInfoList.get(0).isEmpty()) {
        //   mediInfoList.add(this.mediInfoList.get(0));
        // }
        //del 治療記録バッグ修正 改修2 房 end
        // 更新されていない行は、初期リストから作成する
        this.mediInfoList.value().forEach((m, index) => {
          // 削除データは更新対象から除去するため、スキップ
          if (this.mediInfoList.get(index).be_deleted) {
            //add #11499 クライアント端末で投与薬剤を実施済みにすると透析装置へ指示変更のお知らせ情報が送信される zrx start
            // effect_flg == 0 :   未
            if(this.mediInfoListInitial.get(index).effect_flg == 0) {
              this.mediNoticeFlag = true;
            }
            //add #11499 クライアント端末で投与薬剤を実施済みにすると透析装置へ指示変更のお知らせ情報が送信される zrx end
            return;
          }
          if (this.mediInfoList.get(index).effect_date != "")
            this.mediInfoList.get(index).is_new = false;

          mediInfoList.add(
            this.mediInfoList.get(index).is_edited
              ? this.mediInfoList.get(index)
              : this.mediInfoListInitial.get(index)
          );
          //mod #11499 クライアント端末で投与薬剤を実施済みにすると透析装置へ指示変更のお知らせ情報が送信される zrx start
          // if (this.mediInfoList.get(index).is_edited) {
          //   if (this.mediInfoList.get(index).timing_cd !== this.mediInfoListInitial.get(index).timing_cd
          //     || this.mediInfoList.get(index).cd !== this.mediInfoListInitial.get(index).cd
          //     //add FNSI-7131 実施日付、時間、実施者が変更される場合もCOMSV/10を送信する。 ljx start
          //     || this.mediInfoList.get(index).effect_date !== this.mediInfoListInitial.get(index).effect_date
          //     || this.mediInfoList.get(index).effect_time !== this.mediInfoListInitial.get(index).effect_time
          //     || this.mediInfoList.get(index).effect_user_id !== this.mediInfoListInitial.get(index).effect_user_id
          //     //add FNSI-7131 実施日付、時間、実施者が変更される場合もCOMSV/10を送信する。 ljx end
          //     //  add 9973 -4 by kangjie 20231030 start
          //     // || this.mediInfoList.get(index).amount !== this.mediInfoListInitial.get(index).amount) {
          //     || this.mediInfoList.get(index).amount != this.mediInfoListInitial.get(index).amount) {
          //     // add 9973 -4 by kangjie 20231030 end
          //     this.mediNoticeFlag = true;
          //   }
          // }
          // effect_flg == 0 :   未
          if (this.mediInfoList.get(index).is_edited && this.mediInfoListInitial.get(index).effect_flg == 0) {
            if (this.mediInfoList.get(index).cd !== this.mediInfoListInitial.get(index).cd
              || this.mediInfoList.get(index).timing_cd !== this.mediInfoListInitial.get(index).timing_cd
              || this.mediInfoList.get(index).procedure_cd !== this.mediInfoListInitial.get(index).procedure_cd
              || this.mediInfoList.get(index).amount != this.mediInfoListInitial.get(index).amount) {
              this.mediNoticeFlag = true;
            }
          }
          //mod #11499 クライアント端末で投与薬剤を実施済みにすると透析装置へ指示変更のお知らせ情報が送信される zrx end
          //mod 治療記録バッグ修正 改修2 房 end

          // 時刻空値の場合には、日付も空値扱いにする
          if (!this.mediInfoList.get(index).effect_time) {
            this.mediInfoList.get(index).effect_date = null;
            this.mediInfoListInitial.get(index).effect_date = null;
          }
        });

        this.updateTreatmentRecordMediInfo({
          ordNo: this.getOrdNo,
          treatmentRecordMediInfo: {
            treat_date: this.treatDate,
            rst_dialysis_state: this.rstDialysisState,
            rst_start_date: this.rstStartDate,
            rst_end_date: this.rstEndDate,
            rst_medi_info: mediInfoList.toString()
          }
        }).then(() => {
          //add FNSI内容修正 外部Api調用 房 start
          if (this.mediNoticeFlag) {
            this.sendGetNoticeMedi({
              ordNo: this.getOrdNo,
              selectedPatId: this.selectedPatId
            }).then(results=>{
              if (results.data == true) {
                this.getMstMachineByOrdNoRst({
                  ordNo: this.getOrdNo,
                  selectedPatId: this.selectedPatId
                }).then(machineRes => {
                  const params = {
                    ordNo: this.getOrdNo, //オーダー番号
                    machineNo: machineRes.data[0].machineNo, //装置マスタ.装置番号
                    deviceEdgeNo: machineRes.data[0].deviceEdgeNo, //デバイスエッジ番号
                    facilityCd: this.facilityCd //施設コード
                  };
                  try {
                    this.sendRequestChangeIndMediInfoRst(params);
                  } catch (e) {
                    //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
                    getErrorMessage('MedicineComponent.vue','updateMediInfo',e)
                    //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
                    this.$ons.notification.alert({
                      modifier: "warn",
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "送信に失敗しました",
                      // message: `装置へ送信に失敗しました。`
                      title: DIALOG_MESSAGES['00200033'].title,
                      message: messageFormat(DIALOG_MESSAGES['00200033'].message),
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    });
                  }
                });
              }
            })
          }
          //add FNSI内容修正 外部Api調用 房 end
          // 初期化処理を実行
          this.init();
          // 子機能ボタンエリアの更新
          this.$emit("update");
        });
      },
      /**
       * 編集前後のリストから空行を削除して返却
       * @return Array tempMediInfoList: 編集後リスト、tempMediInfoListInitial: 編集前リスト
       */
      removeEmptyRows() {
        const indexesToRemove = [];
        // mediInfoListをフィルタリングし、削除するインデックスを記録
        const tempMediInfoList = this.mediInfoList.list.filter((item, index) => {
          if (item.isEmpty()) {
            indexesToRemove.push(index);
            return false; // リストから削除
          }
          return true;
        });

        // mediInfoListInitialからも同じインデックスを削除
        const tempMediInfoListInitial = this.mediInfoListInitial.list.filter((item, index) => !indexesToRemove.includes(index));

        return {
          tempMediInfoList,
          tempMediInfoListInitial
        };
      },
      /**
       * 保存ボタン押下時のvalidate
       * @param validateMediInfoList 空行削除済みのリスト
       */
      validate(validateMediInfoList) {
        function getErrMessageWord(columnName) {
          return `</br>&nbsp&nbsp・${columnName}`;
        }

        const validateResult = validateMediInfoList.validate();
        let errMessage =
          (validateResult.name ? "" : getErrMessageWord("薬剤名")) +
          (validateResult.amount ? "" : getErrMessageWord("数量"))
          // del #9848+9849 投与薬剤登録検証追加 linjunfeng start
          // (validateResult.procedure ? "" : getErrMessageWord("手技"));
          // del #9848+9849 投与薬剤登録検証追加 linjunfeng end
          // #5835【リクレーション】治疗记录药剂不能实施 訾浩 statr
          // #9848+9849 投与薬剤登録検証追加 linjunfeng start
          // if (this.aFlag) {
        if (!errMessage) {
          return true;
        }
        // #9848+9849 投与薬剤登録検証追加 linjunfeng end
          // #5835【リクレーション】治疗记录药剂不能实施 訾浩 end
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // errMessage = `以下の列に未入力項目が存在します。 ${errMessage}`;
        // mod #9848+9849 投与薬剤登録検証追加 linjunfeng start
        //errMessage = messageFormat(DIALOG_MESSAGES[12000005].message, errMessage)
        errMessage = messageFormat(DIALOG_MESSAGES[12000005].message + errMessage)
        // mod #9848+9849 投与薬剤登録検証追加 linjunfeng end
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + errMessage + "</div>"
        });
        return false;
      },
      async init() {
        if (!this.getOrdNo) {
          return;
        }
        // #9195 投与薬剤を追加してすぐに消える時がある zihao start
        this.setLoadingScreenVisible(true);
        this.setLoadingScreenMessage("処理中・・・");
        // #9195 投与薬剤を追加してすぐに消える時がある zihao end
        // 初期化処理を実行
        this.mediInfoList.deleteAll();
        this.mediInfoListInitial.deleteAll();
        const response = await this.getTreatmentRecordMediInfo({
          ordNo: this.getOrdNo,
          selectedPatId: this.selectedPatId
        });
        const mediInfo = response.data;

        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
        // const mediInfoOptional = JSON.parse(mediInfo.rst_medi_info);
        // const mediInfoArray = mediInfoOptional ? mediInfoOptional : [];
        const mediInfoArray = (mediInfo && mediInfo.rst_medi_info) ? JSON.parse(mediInfo.rst_medi_info) : [];
        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */

        this.treatDate = mediInfo.treat_date;
        this.rstEndDate = mediInfo.rst_end_date;
        this.rstDialysisState = mediInfo.rst_dialysis_state;
        this.rstStartDate = mediInfo.rst_start_date;

        const firstRow = mediInfoArray[0];
        const initOpts =
          firstRow && firstRow.cd != null && firstRow.cd !== ""
            ? { initCd: firstRow.cd, medicineType: firstRow.medicine_type }
            : {};

        //const medicineAndClassResponse = await this.fetchMedicineAll();
        const medicineAndClassResponse = await this.fetchMedicineAllWithMix(initOpts);
        const latestMedicineResponse = medicineAndClassResponse[0];
        const latestMedicineMixResponse = medicineAndClassResponse[1];
        const latestMedicineClassResponse = medicineAndClassResponse[2];
        this.latestMedicine = latestMedicineResponse.data;
        // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        /*const latestMedicineResponse = medicineAndClassResponse[3];
        const latestMedicineMixResponse = medicineAndClassResponse[3];
        const latestMedicineClassResponse = medicineAndClassResponse[3];
        this.latestMedicine = latestMedicineResponse.data.lists.list3.items.filter(item => item.key_type == 1)*/
        // 調整薬剤
        this.latestMedicineMix = latestMedicineMixResponse.data;
        this.latestMedicineClass = latestMedicineClassResponse.data;
        //this.latestMedicineMix = latestMedicineMixResponse.data.lists.list3.items.filter(item => item.key_type == 2);
        //this.latestMedicineClass = latestMedicineClassResponse.data.lists.list2.items;
        // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

        const latestPersonalUserResponse = await this.fetchPersonalUserAll();
        this.latestPersonalUser = latestPersonalUserResponse[0].data;

        //add FNSI-修正 #8356 【デグレ】治療記録－投与薬剤の表示順が施設設定の設定順序とならない　周安寧 start
        //mod 9706 ljx start
        const patIdParam = this.selectedPatId == null?-1:this.selectedPatId
        await this.getMstMedicineTabooAllergy({ patId: patIdParam }), await this.getMstMedicine({ facilityCd: this.facilityCd });
        await this.getMstMedicineAllergy({ patId: patIdParam, is_Del_Flg: true });
        await this.getMstMedicineMixTabooAllergy({ patId: patIdParam });
        await this.getMstMedicineMix({ facilityCd: this.facilityCd });
        await this.getMstMedicineMixAllergyData({ patId: patIdParam, isDelFlg: true });

        // await this.getMstMedicineTabooAllergy({ patId: this.selectedPatId }),
        // await this.getMstMedicine({ facilityCd: this.facilityCd });
        // await this.getMstMedicineAllergy({ patId: this.selectedPatId, is_Del_Flg: true });
        // await this.getMstMedicineMixTabooAllergy({ patId: this.selectedPatId });
        // await this.getMstMedicineMix({ facilityCd: this.facilityCd });
        // await this.getMstMedicineMixAllergyData({ patId: this.selectedPatId, isDelFlg: true });
        //mod 9706 ljx end
        // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
        const procedureSelector = await ApiHelper.get(
          `/report_designer/master/mst_procedure`,
          { selectedPatId: this.selectedPatId }).catch(err => {
          getErrorMessage('Medicine.vue', 'created', err);
          throw err;
        });
        const timingSelector = await ApiHelper.get(
          `/report_designer/master/mst_medicate_timing`,
          { selectedPatId: this.selectedPatId }).catch(err => {
           getErrorMessage('Medicine.vue', 'created', err);
           throw err;
        });
        const classSelector = await ApiHelper.get(
          `/report_designer/master/mst_medicine_class`,
          { selectedPatId: this.selectedPatId }).catch(err => {
          getErrorMessage('Medicine.vue', 'created', err);
          throw err;
        });
        // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
        //add FNSI-修正 #8356 【デグレ】治療記録－投与薬剤の表示順が施設設定の設定順序とならない　周安寧 end
        for(let i = 0; i < mediInfoArray.length; i++) {
          const mediInfo = mediInfoArray[i];
          const mediMst = await this.getMstRecordInState({
            // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
            // mod #9973 shiyw  start
            //mstClass: mediInfo.medicine_type === "2" ? 11 : 10,
            mstClass: mediInfo.medicine_type == 2 ? 11 : 10,
            // mod #9973 shiyw  end
            code: mediInfo.cd,
            notExistReturnValue: "削除済み"
          });
          let index = mediMst ? mediMst.index : "";
          mediInfoArray[i].index = index;
          // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
          let timingCdIndex = timingSelector.data.findIndex(el => el.code == mediInfo.timing_cd);
          mediInfoArray[i].medicateTimingCdIndex = timingCdIndex === -1 ? 999999 :timingCdIndex;
          let procedureCdIndex = procedureSelector.data.findIndex(el => el.code == mediInfo.procedure_cd);
          mediInfoArray[i].procedureCdIndex = procedureCdIndex === -1 ? 999999 :procedureCdIndex;
          let classCdIndex = classSelector.data.findIndex(el => el.code == mediInfo.class_cd);
          mediInfoArray[i].classCdIndex = classCdIndex === -1 ? 999999 :classCdIndex;
          // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end

          // 投与未実施（時刻空）の場合、カレンダー表示した際のデフォルト日付を変更するためデフォルト値を日付（非表示）に設定する
          if (mediInfo.effect_flg == 0) {
            mediInfoArray[i].effect_date = this.getDefaultDate();
          }
        }

        if (mediInfoArray) {
          // RestAPI実行
          //mod FNSI-7270 劉全航 start
          var facility_cd = this.facilityCd;
          //mod FNSI-7270 劉全航 end
          const response = await ApiHelper.get(
            "/mainData/displayOrder",
            //mod FNSI-7270 劉全航 start
            {
              facility_cd,
              selectedPatId: this.selectedPatId
            }
            //mod FNSI-7270 劉全航 end
          ).catch(err => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('Medicine.vue', 'created', err);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw err;
          });

          if (response.data) {
            let medOrderNo = response.data.find(item => item.facilitySettingNo == '3007');
            if (medOrderNo) {
              //FNSI-修正 #5880 投薬の表示順の修正　ljx start
              let medOrderNoValueArray = parseStoredArray(medOrderNo.value);
              let sortKeyObj = {};
              for(let i=0;i<medOrderNoValueArray.length;i++){
                switch (medOrderNoValueArray[i]){
                  // 薬剤分類名称コード
                  case '1':
                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                    //sortKeyObj['class_cd'] = "ascending";
                    sortKeyObj['classCdIndex'] = "ascending";
                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                    break;
                  // 薬剤区分
                  case '2':
                    sortKeyObj['medicine_type'] = "ascending";
                    break;
                  // 薬剤マスタ表示順
                  case '3':
                    sortKeyObj['index'] = "ascending";
                    break;
                  // 投与時間帯
                  case '4':
                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                    //sortKeyObj['timing_cd'] = "ascending";
                    sortKeyObj['medicateTimingCdIndex'] = "ascending";
                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                    break;
                  // 手技
                  case '5':
                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                    //sortKeyObj['procedure_cd'] = "ascending";
                    sortKeyObj['procedureCdIndex'] = "ascending";
                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                    break;
                  // 投薬パターンコード
                  case '6':
                    sortKeyObj['date_interval'] = "ascending";
                    break;
                }
              }
              mediInfoArray.sort((frontValue, nextValue) => this.sortByProps(frontValue, nextValue, sortKeyObj));
              //FNSI-修正 #5880 投薬の表示順の修正　ljx end
            }
          }
        }
        // const mediArray = mediInfoArray.forEach(async item => {
        //   const mediMst = await this.getMstRecordInState({
        //     // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
        //     mstClass: item.medicine_type === "2" ? 11 : 10,
        //     code: item.cd,
        //     notExistReturnValue: "削除済み"
        //   });
        //   item.index = mediMst.index;
        // });

        // // 未実施で並び替え
        // const unexecuted = mediInfoArray.filter(el => el.effect_flg != 1);
        // const unexecutedMediInfo = unexecuted.sort((a, b) => {
        //   const noA = +a.no;
        //   const noB = +b.no;
        //   // 識別番号（no）の降順
        //   return noB - noA;
        // });
        // // 実施済で並び替え
        // const executed = mediInfoArray.filter(el => el.effect_flg == 1);
        // const executedMediInfo = executed.sort((a, b) => {
        //   const effectDateA = new Date(a.effect_date).getTime();
        //   const effectDateB = new Date(b.effect_date).getTime();
        //   //  effect_dateの昇順
        //   return effectDateA - effectDateB;
        // });

        //del 治療記録バッグ修正 改修2 房 start
        // const initialMediInfo = MediInfo.of({
        //   ind_user_id: this.stateUserAccountInfo.userId,
        //   ind_user_last_name: this.stateUserAccountInfo.userLastName,
        //   ind_user_first_name: this.stateUserAccountInfo.userFirstName
        // });
        //del 治療記録バッグ修正 改修2 房 end

        let tempMediInfoList = new MediInfoList();
        tempMediInfoList
          //del 治療記録バッグ修正 改修2 房 start
          //.add(initialMediInfo)
          //del 治療記録バッグ修正 改修2 房 end
          // .addAll(executedMediInfo.map(info => MediInfo.of(info)))
          .addAll(mediInfoArray.map(info => MediInfo.of(info)));

        // 薬剤小数点設定
        this.mediInfoList = this.syncCurrentMedicineDecPoint(tempMediInfoList)
        for (let index = 0; index < this.surplusList.list.length; index++) {
          this.mediInfoList.list.push(this.surplusList.list[index]);
        }
        this.surplusList = new MediInfoList();
        this.convertMedicine2Master();
        this.convertEffectUser2Master();

        // コンボデータの取得
        const emptyOption = { text: null, cd: null };
        const procedureComboResponse = await this.getProcedureComboList({
          selectedPatId: this.selectedPatId
        });
        this.procedureComboList = [emptyOption].concat(
          procedureComboResponse.data
        );
        const medicateTimingComboResponse = await this.getMedicateTimingComboList({
          selectedPatId: this.selectedPatId
        });
        this.medicateTimingComboList = [emptyOption].concat(
          medicateTimingComboResponse.data
        );
        this.procedureCombo2DArray = []
        this.medicateTiming2DArray = []
        this.mediInfoList.list.forEach(e => {
          if (!e.is_new) {
            this.comboListMatchingBody(this.procedureComboList, e, e.procedure_cd, e.procedure_name, "procedure_name");
            this.comboListMatchingBody(this.medicateTimingComboList, e, e.timing_cd, e.timing_name, "timing_name");
            // #9848+9849 追加の場合、新たに追加されたデータは削除し、手技、時間帯データはクリアします。linjunfeng start
          } else {
            this.procedureCombo2DArray.push(this.procedureComboList)
            this.medicateTiming2DArray.push(this.medicateTimingComboList)
            // #9848+9849 追加の場合、新たに追加されたデータは削除し、手技、時間帯データはクリアします。linjunfeng end
          }
        });

        // 初期状態を退避
        this.mediInfoListInitial
          //del 治療記録バッグ修正 改修2 房 start
          // .add(MediInfo.of())
          //del 治療記録バッグ修正 改修2 房 end
          // .addAll(executedMediInfo.map(info => MediInfo.of(info)))
          // .addAll(unexecutedMediInfo.map(info => MediInfo.of(info)))
          .addAll(mediInfoArray.map(info => MediInfo.of(info)));

        for (let index = 0; index < this.tempSurplusList.list.length; index++) {
          this.mediInfoListInitial.list.push(this.tempSurplusList.list[index]);
        }
        this.tempSurplusList = new MediInfoList();
        // 薬剤単位取得
        this.syncCurrentMedicineUnit();

        // 最新の薬剤と薬剤区分、実施者、手技、時間帯をMediInfoListに設定
        this.mediInfoList.latestMedicineList = this.latestMedicine;
        this.mediInfoList.latestMedicineMixList =this.latestMedicineMix;
        this.mediInfoList.latestMedicineClassList = this.latestMedicineClass;
        this.mediInfoList.latestPersonalUserList = this.latestPersonalUser;
        this.mediInfoList.procedureComboList = this.procedureComboList;
        this.mediInfoList.medicateTimingComboList = this.medicateTimingComboList;
        this.mediInfoList.stateUserAccountInfo = this.stateUserAccountInfo;
        //this.initEffectDate();//
        this.$nextTick(() => {
          //add FNSI-改修内容：初期flag追加 房 start
          this.initFlg = true;
          //add FNSI-改修内容：初期flag追加 房 end
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
          // this.disableElement(this.$el);
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
        });
        // add FNSI-共有を追加 王 20200921 start
        const selectBtn = getScopedElementsByClassName("button select-btn", this.$el || this);
        if (this.getSharedFacilityCd !== undefined && this.getSharedFacilityCd != null) {
          if (this.getSharedFlag === 1 && this.facilityCd !== this.getSharedFacilityCd) {
            for (let i = 0; i < selectBtn.length; i++) {
              selectBtn[i].disabled = true ;
            }
          } else {
            for (let i = 0; i < selectBtn.length; i++) {
              selectBtn[i].disabled = false ;
            }
          }
        } else {
          for (let i = 0; i < selectBtn.length; i++) {
            selectBtn[i].disabled = false ;
          }
        }
        // add FNSI-共有を追加 王 20200921 end
        // #9195 投与薬剤を追加してすぐに消える時がある zihao start
        this.setLoadingScreenVisible(false);
        // #9195 投与薬剤を追加してすぐに消える時がある zihao end
      },
      setNewRecord(index) {
        //del 治療記録バッグ修正 改修2 房 start
        // if (index == 0) {
        //   this.mediInfoList.get(index).is_new = true;
        // }
        //del 治療記録バッグ修正 改修2 房 end
        if (this.mediInfoList.get(index).effect_time) {
          this.mediInfoList.get(index).is_edited = true;
        } else {
          this.mediInfoList.get(index).is_edited = false;
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
        //mod メッセージ順番修正 房 start
        // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
        // if (this.isChanged && this.alertFlag) {
        //   this.discardConfirm(this.init);
        // } else {
        //   this.init();
        // }
        this.init();
        // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
        this.alertFlag = true;
        //mod メッセージ順番修正 房 end
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
      // add 治療記録バッグ修正 改修2 房 start
      addRow(){
        const initialMediInfo = MediInfo.of({
          is_edited: true,
          is_new: true,
          ind_user_id: this.stateUserAccountInfo.userId,
          ind_user_last_name: this.stateUserAccountInfo.userLastName,
          ind_user_first_name: this.stateUserAccountInfo.userFirstName
        });
        initialMediInfo.is_new = true;
        const tempMediInfo = MediInfo.of({
          is_edited: true,
          is_new: true,
          ind_user_id: this.stateUserAccountInfo.userId,
          ind_user_last_name: this.stateUserAccountInfo.userLastName,
          ind_user_first_name: this.stateUserAccountInfo.userFirstName
        });
        // add FNSI-6504 ljx start
        //実施時刻 デフォルト値設定
        const effect_time = this.getDefaultTime();
        //実施日付 デフォルト値設定
        const effect_date = this.getDefaultDate();
        //追加された行に実施時刻と実施日付を初期化表示
        initialMediInfo.effect_date = effect_date;
        initialMediInfo.effect_time = effect_time;
        this.updateEffectDate(effect_time, this.mediInfoList.size());
        // add FNSI-6504 ljx end
        // 薬剤小数点設定
        this.mediInfoListInitial.add(tempMediInfo);
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        this.initItem = initialMediInfo
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        this.mediInfoList.add(initialMediInfo);
        this.convertMedicine2Master();
        this.convertEffectUser2Master();
        this.procedureCombo2DArray.push(this.procedureComboList)
        this.medicateTiming2DArray.push(this.medicateTimingComboList)
      },
      // add 治療記録バッグ修正 改修2 房 end
      //add メッセージ順番修正 房 start
      getChangeStatus(){
        return this.canDelete || this.canSave;
      },
      updateChangeStatus(){
        this.alertFlag = false;
      },
      //add メッセージ順番修正 房 end
      diffValue(){
        let diffFlag = false;
        if (this.mediInfoListInitial.list.length != this.mediInfoList.list.length) {
          diffFlag = true;
        } else {
          for (let index = 0; index < this.mediInfoListInitial.list.length; index++) {
            let beforeTarget =
              {
                effect_date:dayjs(this.mediInfoListInitial.get(index).effect_date).format('YYYYMMDD'),
                effect_time:this.mediInfoListInitial.get(index).effect_time,
                cd:this.mediInfoListInitial.get(index).cd,
                name:this.mediInfoListInitial.get(index).name,
                amount:this.mediInfoListInitial.get(index).amount,
                unit:this.mediInfoListInitial.get(index).unit,
                procedure_cd:this.mediInfoListInitial.get(index).procedure_cd,
                procedure_name:this.mediInfoListInitial.get(index).procedure_name,
                timing_cd:this.mediInfoListInitial.get(index).timing_cd,
                timing_name:this.mediInfoListInitial.get(index).timing_name,
                effect_user_id:this.mediInfoListInitial.get(index).effect_user_id,
                effect_user_last_name:this.mediInfoListInitial.get(index).effect_user_last_name,
                effect_user_first_name:this.mediInfoListInitial.get(index).effect_user_first_name,
              }

            let afterTarget =
              {
                effect_date:dayjs(this.mediInfoList.get(index).effect_date).format('YYYYMMDD'),
                effect_time:this.mediInfoList.get(index).effect_time,
                cd:this.mediInfoList.get(index).cd,
                name:this.mediInfoList.get(index).name,
                amount:this.mediInfoList.get(index).amount,
                unit:this.mediInfoList.get(index).unit,
                procedure_cd:this.mediInfoList.get(index).procedure_cd,
                procedure_name:this.mediInfoList.get(index).procedure_name,
                timing_cd:this.mediInfoList.get(index).timing_cd,
                timing_name:this.mediInfoList.get(index).timing_name,
                effect_user_id:this.mediInfoList.get(index).effect_user_id,
                effect_user_last_name:this.mediInfoList.get(index).effect_user_last_name,
                effect_user_first_name:this.mediInfoList.get(index).effect_user_first_name,
              }

            if (JSON.stringify(beforeTarget) !== JSON.stringify(afterTarget)) {
              diffFlag = true;
              break;
            }

            // 削除対象かどうか
            if (this.mediInfoList.get(index).be_deleted) {
              diffFlag = true;
              break;
            }
          }
        }
        if (!diffFlag) {
          for (let index = 0; index < this.mediInfoList.list.length; index++) {
            this.mediInfoList.get(index).is_edited = false;
          }
        }
      },
      inputClass(element, index){
        if (this.mediInfoListInitial.list == undefined) {
          return "custom-input-edited";
        } else if (this.mediInfoListInitial.list[index] != undefined && this.mediInfoListInitial.list[index][element] == null && this.mediInfoList.list[index][element] == "") {
          return "";
        } else if (this.mediInfoListInitial.list[index] != undefined && this.mediInfoListInitial.list[index][element] != this.mediInfoList.list[index][element]) {
          return "custom-input-edited";
        } else {
          return "";
        }
      },
      //FNSI-修正 #5880 投薬の表示順の修正　ljx start
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
      //FNSI-修正 #5880 投薬の表示順の修正　ljx end
      /**
      * 実施状況(投与日時)のデフォルト値を取得
      *   rst_dialysis_state1～5の場合：sysdate
      *   rst_dialysis_state6の場合の場合：実績初版確定日時
      */
      getDefaultDate() {
        let defaultDate = new Date();
        if (+this.getDialysisState === +CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd) {
          // rst_dialysis_state6
          defaultDate =  this.getRstEditionDate ? new Date(this.getRstEditionDate) : new Date();
        }
        return dateFormat.utc2Jst(defaultDate.toISOString());
      },
      getDefaultTime() {
        let defaultDate = new Date();
        if (+this.getDialysisState === +CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd) {
          // rst_dialysis_state6
          defaultDate =  this.getRstEditionDate ? new Date(this.getRstEditionDate) : new Date();
        }
        const hours = String(defaultDate.getHours()).padStart(2, '0');
        const minutes = String(defaultDate.getMinutes()).padStart(2, '0');
        return `${hours}:${minutes}`;
      },
      /**
      * 実施状況(投与日時)時刻入力フォーカス
      */
      onFocusTime(index){
        // 時刻が空の場合、デフォルト日時を設定
        if (!this.mediInfoList.get(index).effect_time) {
          const effectTime = this.getDefaultTime();
          this.updateEffectDate(effectTime, index);
        }
      },
      /**
      * 済/未を切り替える
      */
      clickChangeEffectStatus(index) {
        const mediInfo = this.mediInfoList.get(index);
        const effectFlg = mediInfo.effect_flg;
        if (effectFlg == 0) {
          mediInfo.effect_date = this.getDefaultDate();
          const effectTime = this.getDefaultTime();
          this.updateEffectDate(effectTime, index);
        } else {
          this.updateEffectDate(null, index);
        }
      }
    },
    async created() {
      // 画面名称取得
      this.selfScreenName = this.$route.name;
      EventBus.$on("refresh", this.eventBusRefresh);
      // OrdMainレコードをチェックする
      if (!this.checkOrdNo()) {
        return;
      }
      await this.init();
    },
    watch:{
      mediInfoList: {
        handler(){
          this.diffValue();
        },
        deep: true,
      }
    },
    beforeUnmount() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
      // del refresh方法処理不正について、対応する。 dengshen start
      // EventBus.$off("refresh");
      // del refresh方法処理不正について、対応する。 dengshen end
      // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
      // EventBus.$off("refresh", this.refresh);
      EventBus.$off("refresh", this.eventBusRefresh);
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
      // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    }
  };
</script>

<style scoped>
  .ntss-list-body-td :deep(ons-button.button) {
    width: 3em;
  }
  .ntss-list-body-td :deep(ons-row) {
    flex-wrap: nowrap;
  }
  .ntss-list-body-td :deep(ons-col) {
    flex: 1 1 0%;
    width: auto;          /* 避免 Safari 按 100% 撑满 */
    min-width: 0;
    margin-right: 5px;
  }
  .ntss-list-header-th-sticky {
    z-index: 1;
  }
  .align-center {
    text-align: center;
  }
  .scroll-table {
    width: 1px;
  }
  .medicine-selector-td :deep(ons-col.text-value),
  .personal-select-td :deep(ons-col.text-value) {
    display: flex;
    align-items: center;
  }
  .medicine-selector-td :deep(.select-btn),
  .personal-select-td :deep(.select-btn) {
    font-size: 1em;
  }
  .number-input :deep(.num-value label) {
    margin-left: 0em;
  }
  .number-input :deep(.num-value ons-input) {
    width: 5em;
  }
  .ntss-list-body-td :deep(.select-input) {
    border: solid 1px var(--treatment-record-select-border-color);
  }
  .button-calendar {
    margin-left: 2px;
    width: 2em;
  }
  div :deep(.common-time-input) {
    width: calc(100% - 30px);
  }
  div :deep(.common-time-input > input[type="time"]) {
    width: 100%;
  }
  .toolbar-btn {
    font-size: 1.0em;
    padding: 0.2em 1em 0em 1em;
    line-height: 2em;
    width: auto;
    margin: 0.1em;
  }
  td ons-select {
    width: 100%;
  }
  .custom-input-edited :deep(select) {
    border: 2px green solid !important;
    outline: 0 !important;
    border-radius: 5px !important;
  }
  .ntss-custom-input {
    width: -webkit-fill-available;
  }
  /* add #9848+9849  数値ボックス仕様修正です。 linjunfeng start */
  .amount-number {
    width: 70px;
  }
  /* add #9848+9849  数値ボックス仕様修正です。 linjunfeng end */
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
  /* 未実施 */
  .not-yet {
    background-color: #dddddd;
    color: #808080;
    border-radius: 1em;
    background-image: linear-gradient(#fdfcfc 0%,#e0e0e0 50%,#e0e0e0 50%,#d2d2d2 100%);
    box-shadow: unset;
  }
  /* 実施済 */
  .done {
    background-color: #3cb371;
    color: #ffffff;
    border-radius: 1em;
    background-image: -webkit-linear-gradient(
      rgba(255, 255, 255, 0.3) 0%,
      transparent 50%,
      transparent 50%,
      rgba(0, 0, 0, 0.1) 100%
    );
    border-bottom: solid 3px var(--btn-common-border-color);
    box-shadow: unset;
  }
    /*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
    :deep(.com-basic-sub-btn) {
      margin-left: 5px
    }
    :deep(.com-basic-sub-input) {
      min-width: 13em;
      width: 100%;
      max-width: 28em;
      background-color: #f7f7f7;
    }
    /*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
