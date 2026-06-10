<template>
  <div>
    <!-- TODO:  透析導入原疾患も死因と同じように「患者基本情報」のカラムにする -->
    <div>
      <custom-checkbox
        :value="getPatData('is_diabetes')"
        checked-value="1"
        :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
        unchecked-value="0"
      >
        糖尿病患者
      </custom-checkbox>
      <custom-checkbox
        :value="getPatData('is_blood_suger_exam')"
        checked-value="1"
        :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
        unchecked-value="0"
      >
        血糖検査
      </custom-checkbox>
    </div>
    <table class="table-area">
      <tr>
        <td class="item-title">透析導入原疾患</td>
        <td>
          <!-- mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start -->
          <custom-input
            class="item-area"
            :value="getPatData('primary_disease_cd')"
            :display-string="
              mstCdToNameFreeWord(
                  selectedDiseaseList,
                  getPatData('primary_disease_cd').editValue,
                  'diseaseCd',
                  'diseaseName'
                )
            "
            :disabled="true"
          />

          <!-- mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end -->
        </td>
        <td class="item-data choice-button-area"></td>
      </tr>
      <tr v-if="isDie">
        <td class="item-title">死因</td>
        <td>
          <!-- mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start -->
          <custom-input
            :value="getPatData('die_cd')"
            :display-string="mstCdToNameFreeWord(
                  selectedDiseaseList,
                  getPatData('die_cd').editValue,
                  'diseaseCd',
                  'diseaseName'
                )"
            :disabled="true"
          />
        </td>
        <td class="item-data choice-button-area"></td>
      </tr>
    </table>

    <div
      v-for="(json, index) in jsonArray"
      :key="index"
      :class="classObjectItem(json)"
    >
      <table class="card-table">
        {{
          index + 1
        }}
        <button
          v-show="actionMode"
          class="button-delete ntss-btn-outset"
          @click="setJsonIndex(json, index)"
          :disabled="isOtherFacilityRow(json)"
        >
          <v-ons-icon icon="fa-trash"/>
        </button>
        <!-- del FutreNetWeb+SI課題管理No6117 趙 start -->
        <!--  <message-dialog-->
        <!--   :visible.sync="isMedicalHstMessage"-->
        <!--   :message-cd="11010002"-->
        <!--   :string-params="['入外・転入出']"-->
        <!--   type="2"-->
        <!--   @confirm="confirmSave"-->
        <!--  />-->
        <!-- del FutreNetWeb+SI課題管理No6117 趙 end -->
        <br />

        <tr>
          <td class="item-title">発症日</td>
          <!--#10715:日付IF修正Start-->
          <td colspan="2" class="item-data-period">
            <span v-if="!isStartDateInputFreedisease(json)" class="span-flex">
              <custom-input-date
                ref="disease_date"
                class="death-date"
                :value="getPatDataJsonArray(json, 'disease_date')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :callBackFunc="setDateEach"
                :arguments="{json: json, fromData: 'disease_date'}"
              />
              <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="changeinputfreedisease(json, '1')"
              >
                <v-ons-icon icon="fa-dot-circle" />
              </button>
            </span>
            <span v-else class="flex-align-center visit-history">
              <!--#10866：日付(不定型)の部品修正Start -->
              <!--//#10866:日付(不定型)の部品修正・検証NG対応　Start -->
              <custom-input
                ref="disease_year"
                class="diagnosis-date"
                :maxlength="4"
                :validators="[validateInteger]"
                form-name="発症日"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'disease_year')"
                :datetype="'period-year'"
                :datetypeym="datetypechk(json, 'disease_')"
                :datetypeindex="datetypeindex('year_h', index)"
                :wheelChangeUse="true"
                @blur="
                addNumber(json, 'disease_year');
                "
              />年
              <!--#10866：日付(不定型)の部品修正End -->
              <!--#10866：日付(不定型)の部品修正Start -->
              <custom-input
                class="diagnosis-date"
                :maxlength="2"
                :validators="[validateInteger]"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'disease_month')"
                :datetype="'period-month'"
                :datetypeym="datetypechk(json, 'disease_')"
                :datetypeindex="datetypeindex('month_h', index)"
                :wheelChangeUse="true"
                @blur="
                addNumber(json, 'disease_month');
                "
              />月
              <!--#10866：日付(不定型)の部品修正End -->
              <!--#10866：日付(不定型)の部品修正Start -->
              <custom-input
                class="diagnosis-date"
                :maxlength="2"
                :validators="[validateInteger]"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'disease_day')"
                :datetype="'period-day'"
                :datetypeym="datetypechk(json, 'disease_')"
                :datetypeindex="datetypeindex('day_h', index)"
                :wheelChangeUse="true"
                @blur="
                addNumber(json, 'disease_day');
                "
              />日
              <!--#10866：日付(不定型)の部品修正End -->
              <custom-input-calender
                class="calender"
                :value="getPatDataJsonArray(json, 'disease_date')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :callBackFunc="setDateEach"
                :arguments="{
                    json: json,
                    fromData: 'disease_date'
                }"
              />
              <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="changeinputfreedisease(json, '0')"
                >
                <v-ons-icon icon="fa-dot-circle" />
              </button>
            </span>
        </td>
      </tr>
      <tr>
      <td class="item-title">診断日</td>
      <td class="item-data" colspan="2">
          <span v-if="!isStartDateInputFreediagnosis(json)" class="span-flex">
              <custom-input-date
                ref="diagnosis_date"
                class="death-date"
                :value="getPatDataJsonArray(json, 'diagnosis_date')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :callBackFunc="setDateEach"
                :arguments="{json: json, fromData: 'diagnosis_date'}"
              />
              <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="changeinputfreediagnosis(json, '1')"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <v-ons-icon icon="fa-dot-circle" />
              </button>
          </span>
          <span v-else class="flex-align-center visit-history">
            <!--#10866：日付(不定型)の部品修正Start -->
            <custom-input
            ref="diagnosis_year"
            class="diagnosis-date"
            :maxlength="4"
            :validators="[validateInteger]"
            form-name="診断日"
            :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
            :value="getPatDataJsonArray(json, 'diagnosis_year')"
            :datetype="'period-year'"
            :datetypeym="datetypechk(json, 'diagnosis_')"
            :datetypeindex="datetypeindex('year_S', index)"
            :wheelChangeUse="true"
            @blur="
            addNumber(json, 'diagnosis_year');
            "
            />年
            <!--#10866：日付(不定型)の部品修正End -->
            <!--#10866：日付(不定型)の部品修正Start -->
            <custom-input
            class="diagnosis-date"
            :maxlength="2"
            :validators="[validateInteger]"
            :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
            :value="getPatDataJsonArray(json, 'diagnosis_month')"
            :datetype="'period-month'"
            :datetypeym="datetypechk(json, 'diagnosis_')"
            :datetypeindex="datetypeindex('month_S', index)"
            :wheelChangeUse="true"
            @blur="
            addNumber(json, 'diagnosis_month');
            "
            />月
            <!--#10866：日付(不定型)の部品修正End -->
            <!--#10866：日付(不定型)の部品修正Start -->
            <custom-input
            class="diagnosis-date"
            :maxlength="2"
            :validators="[validateInteger]"
            :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
            :value="getPatDataJsonArray(json, 'diagnosis_day')"
            :datetype="'period-day'"
            :datetypeym="datetypechk(json, 'diagnosis_')"
            :datetypeindex="datetypeindex('day_S', index)"
            :wheelChangeUse="true"
            @blur="
            addNumber(json, 'diagnosis_day');
            "
            />日
            <!--#10866：日付(不定型)の部品修正End -->
            <custom-input-calender
            class="calender"
            :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
            :value="getPatDataJsonArray(json, 'diagnosis_date')"
            :callBackFunc="setDateEach"
            :arguments="{
                json: json,
                fromData: 'diagnosis_date'
            }"
            />
            <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="changeinputfreediagnosis(json, '0')"
                >
                <v-ons-icon icon="fa-dot-circle" />
            </button>
          </span>
        </td>
        <!--#10715:日付IF修正End-->
        </tr>

        <tr>
          <td class="item-title">診断施設</td>
          <td class="item-data">
            <!-- <custom-simple-textarea-a
              class="input-style"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'diagnosis_facility_cd')"
              :display-string="dispFacilityName(json)"
              style="vertical-align: middle;"
            /> -->
            <custom-simple-textarea-a
              class="input-style"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getFieldValue(json, 'diagnosis_facility_cd', 'diagnosis_facility_name')"
              :display-string="getNameDisplay(json, dispFacilityName)"
              style="vertical-align: middle;"
            />
          </td>
          <td class="item-data choice-button-area">
            <v-ons-button
              :ref="'btnSelectFacility' + index"
              class="common-style-select-button btn3-normal"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              @click="showPopoverFacilityCd(json, index)"
            >
              選択
            </v-ons-button>
          </td>
        </tr>

        <tr>
          <td class="item-title">診療科</td>
          <td class="item-data">
            <!-- <custom-simple-textarea-a
              class="input-style"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'course_cd')"
              :display-string="dispCourseName(json)"
              style="vertical-align: middle;"
            /> -->
            <custom-simple-textarea-a
              class="input-style"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getFieldValue(json, 'course_cd', 'course_name')"
              :display-string="getNameDisplay(json, dispCourseName)"
              style="vertical-align: middle;"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </td>
          <td class="item-data choice-button-area">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   :ref="'btnSelectCourseCd' + index" -->
            <!--   class="common-style-select-button btn3-normal" -->
            <!--   :disabled="editFlag" -->
            <!--   @click="showPopoverCourseCd(json, index)" -->
            <!-- > -->
            <v-ons-button
              :ref="'btnSelectCourseCd' + index"
              class="common-style-select-button btn3-normal"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              @click="showPopoverCourseCd(json, index)"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              選択
            </v-ons-button>
          </td>
        </tr>

        <tr>
          <td class="item-title">診断医</td>
          <td class="item-data">
            <!-- <custom-simple-textarea-a
              class="input-style"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'diagnostician_cd')"
              :display-string="diagnosticianName(json)"
              style="vertical-align: middle;"
            /> -->
            <custom-simple-textarea-a
              class="input-style"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getFieldValue(json, 'diagnostician_cd', 'diagnostician_name')"
              :display-string="getNameDisplay(json, diagnosticianName)"
              style="vertical-align: middle;"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </td>
          <td class="item-data choice-button-area">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   :ref="'btnSelectUserId' + index" -->
            <!--   class="common-style-select-button btn3-normal" -->
            <!--   :disabled="editFlag" -->
            <!--   @click="showPopoverUserId(json, index)" -->
            <!-- > -->
            <v-ons-button
              :ref="'btnSelectUserId' + index"
              class="common-style-select-button btn3-normal"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              @click="showPopoverUserId(json, index)"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              選択
            </v-ons-button>
          </td>
        </tr>
        <tr>
          <td class="item-title">病名</td>
          <td class="item-data">
            <!-- <custom-simple-textarea-a
              class="input-style"
              :value="getPatDataJsonArray(json, 'disease_cd')"
              :display-string="dispDiseaseName(json)"
              :disabled="true"
              style="vertical-align: middle;"
            /> -->
            <custom-simple-textarea-a
              class="input-style"
              :value="getFieldValue(json, 'disease_cd', 'disease_name')"
              :display-string="getNameDisplay(json, dispDiseaseName)"
              :disabled="true"
              style="vertical-align: middle;"
            />
            <!-- mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end -->
          </td>
          <td class="item-data choice-button-area">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   :ref="'btnSelectDiseaseCd' + index" -->
            <!--   class="common-style-select-button btn3-normal" -->
            <!--   :disabled="editFlag" -->
            <!--   @click="showPopoverDiseaseCd(json, index)" -->
            <!-- > -->
            <v-ons-button
              :ref="'btnSelectDiseaseCd' + index"
              class="common-style-select-button btn3-normal"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              @click="showPopoverDiseaseCd(json, index)"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              選択
            </v-ons-button>
          </td>
        </tr>
        <!--mod FNSI じょはく start-->
        <tr>
          <td></td>
          <td class="item-data">
            <custom-checkbox
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'is_main_disease')"
              checked-value="1"
              unchecked-value="0"
              @change="changeMainDisease(json)"
            >
              主病
            </custom-checkbox>
          </td>

        </tr>
        <tr>
          <td></td>
          <td class="item-data">
            <custom-checkbox
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'is_notice')"
              checked-value="1"
              unchecked-value="0"
            >
              告知
            </custom-checkbox>
          </td>
        </tr>

        <tr>
          <td></td>
          <td class="item-data">
            <custom-checkbox
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'is_dialysis_underlying_disease')"
              checked-value="1"
              unchecked-value="0"
              @change="changeDialysisUnderlyingDisease($event.target.value, json)"
            >
              透析導入原疾患として扱う
            </custom-checkbox>
          </td>

          <!--<td class="item-data">
            <custom-checkbox
              :disabled="isDisabled(json)"
              :value="getPatDataJsonArray(json, 'is_confirmation_biopsy')"
              checked-value="1"
              unchecked-value="0"
            >
              生検確認あり
            </custom-checkbox>
          </td>-->
        </tr>
        <tr>
          <td></td>
          <td class="item-data">
            <custom-checkbox
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'is_confirmation_biopsy')"
              checked-value="1"
              unchecked-value="0"
            >
              生検確認あり
            </custom-checkbox>
          </td>
        </tr>

        <tr>
          <td></td>
          <td class="item-data">
            <custom-checkbox
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'is_diagnosed')"
              checked-value="1"
              unchecked-value="0"
            >
              確定診断あり
            </custom-checkbox>
          </td>
        </tr>

        <tr>
          <td class="item-title">転帰</td>
          <td class="item-data">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <custom-select -->
            <!--   :disabled="editFlag" -->
            <!--   :value="getPatDataJsonArray(json, 'out_come')" -->
            <!--   :options="outComeList" -->
            <!--   @focus="focusOutCome($event.target.value, json)" -->
            <!--   @change="changeOutCome($event.target.value, json)" -->
            <!-- /> -->
            <custom-select
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'out_come')"
              :options="outComeList"
              @focus="focusOutCome($event.target.value, json)"
              @change="changeOutCome($event.target.value, json)"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </td>
          <!--<td class="item-data">
            <custom-checkbox
              :disabled="isDisabled(json)"
              :value="getPatDataJsonArray(json, 'is_diagnosed')"
              checked-value="1"
              unchecked-value="0"
            >
              確診あり
            </custom-checkbox>
          </td>-->
        </tr>
        <!--mod FNSI じょはく end-->
        <tr v-show="isDie">
          <td class="item-title">死亡日</td>
          <td class="item-data">
            <custom-input-date
              class="input-date"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'die_date')"
              :disableDatesAfter="getDisableDatesAfter"
            />
          </td>
        </tr>

        <tr>
          <td class="item-title">転帰変更日</td>
          <td class="item-data">
            <custom-input-date
              class="input-date"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :value="getPatDataJsonArray(json, 'out_come_date')"
            />
          </td>
        </tr>

        <tr>
          <td class="item-title">コメント</td>
          <td class="item-data">
            <com-textarea
              class="comTextarea"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              :content="getPatDataJsonArray(json, 'memo')"
              :idTextarea="'com-textarea-medical-hts-memo' + index"
              cssClass="textarea-custom-text-font textarea-resize-vertical"
              @set-content-data="setContentDataMemo($event,index)"
            />
          </td>
        </tr>
      </table>
    </div>
      <div>
        <pop-over-facility
          v-bind="popoverDataFacilityCd"
          :target-position-element="popoverTargetElement('btnSelectFacility')"
          @popover-close="closePopover()"
          @popover-return="updateInput($event, 'diagnosis_facility_cd')"
        />
        <pop-over
          v-bind="popoverDataCourseCd"
          :target-position-element="popoverTargetElement('btnSelectCourseCd')"
          @popover-close="closePopover()"
          @popover-return="updateInput($event, 'course_cd')"
        />
        <pop-over
          v-bind="popoverDataUserId"
          :target-position-element="popoverTargetElement('btnSelectUserId')"
          @popover-close="closePopover()"
          @popover-return="updateInput($event, 'diagnostician_cd')"
        />
        <pop-over-disea
          v-bind="popoverDataDiseaseCd"
          :target-position-element="popoverTargetElement('btnSelectDiseaseCd')"
          @popover-close="closePopover()"
          @popver-search-condition="setPopoverSearchCondition"
          @popover-return="updateInput($event, 'disease_cd')"
        />
        <message-dialog
          :visible.sync="isWarningDialogVisible"
          :message-cd="40000001"
          type="1"
          :string-params="stringParams"
          @confirm="confirm"
        />
      </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import moment from "moment";
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { getMaxDay } from "@/functions/common/DateTimeUtils";
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

export default {
  name: "MedicalHstCard",
  mixins: [baseCardContent],

  data() {
    return {
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 じょはく start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 じょはく end
      // del #10359 編集権限の動作不正 dengshen end
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      isInitFinished: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
      arrayColName: "medical_hst_info",
      outComeList: [
        { value: "1", displayValue: "治療中" },
        { value: "2", displayValue: "診断のみ" },
        { value: "3", displayValue: "治癒" },
        { value: "4", displayValue: "軽快" },
        { value: "5", displayValue: "寛解" },
        { value: "6", displayValue: "不変" },
        { value: "7", displayValue: "増悪" },
        { value: "8", displayValue: "中止" },
        { value: "9", displayValue: "転医" },
        { value: "10", displayValue: "死亡" }
      ],

      popoverDataFacilityCd: {
        popoverVisible: false,
        popoverDisplayDirection: "right",
        popoverTitleHeader: "施設",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverFilterDisabled: "",
        popoverContentLabel: "施設名",
        popoverContentDataset: []
      },

      popoverDataCourseCd: {
        popoverVisible: false,
        popoverDisplayDirection: "right",
        popoverTitleHeader: "診療科",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverFilterDisabled: "",
        popoverContentLabel: "診察科名",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },

      popoverDataUserId: {
        popoverVisible: false,
        popoverDisplayDirection: "right",
        popoverTitleHeader: "診断医",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverFilterDisabled: "",
        popoverContentLabel: "診断医名",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },

      popoverDataDiseaseCd: {
        // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
        // popoverVisibleDisea: false,
        popoverVisible: false,
        // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end
        popoverDisplayDirection: "right",
        popoverTitleHeader: "病名",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverFilterDisabled: "",
        popoverContentLabel: "病名",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },

      /* del by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // mstFacility: null,
      /* del by chamaojia 2025-05-21 [11871]  --end */
      mstCourse: null,
      mstUser: [],
      mstDisease: null,
      deleteMstDisease: null,
      isWarningDialogVisible: false,
      messageCd: "",
      stringParams: [""],

      inputValue: [],
      selectedJson: null,
      previousOutCome: "",
      selectedIndex: null,
      isGotMstUser: false,

      selectedMainDisease: null,
      dialysisUnderlyingDisease: null,
      selectJson: null,
      selectIndex: null,
      isMedicalHstMessage: false,
      userData: [],

      // #9482 病名翻訳用の容器
      selectedDiseaseList: []
      /* add by chamaojia 2025-05-21 [11871]  --start */
      ,facilityNameList: []
      /* add by chamaojia 2025-05-21 [11871]  --end */
    };
  },

  // add 編集権限の適用 じょはく start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 じょはく end

  computed: {
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions", "getPatientShareMode", "getPatientShareFacilityCdMode"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("user-selector-popover", ["mstJob"]),
    /* del by chamaojia 2025-05-21 [11871]  --start */
    // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
    /*...mapGetters("sys-facility", ["getSysFacilities", "getSysFacilitiesForName"]),*/
    /* del by chamaojia 2025-05-21 [11871]  --end */
    ...mapGetters("pat-info", ["selectedPatId", "selectedPat", "getIsOtherFacility", "getOtherFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    jsonArray: {
      get() {
        let arrMedicalHstInfoSorted = [];
        // 発症日/診断日の降順でソートするため、日付を確認
        for (let mediHstInf of this.editRecord[this.arrayColName]) {
          let sortDate = "";
          if (this.valiateObj(mediHstInf["disease_year"]) && mediHstInf["disease_year"].initValue && this.valiateObj(mediHstInf["disease_month"]) && mediHstInf["disease_month"].initValue  && mediHstInf["disease_day"].initValue) {
            // 発症日の年月日がそろっている場合
            sortDate = mediHstInf["disease_year"].initValue + mediHstInf["disease_month"].initValue + mediHstInf["disease_day"].initValue + "01";
          } else if (mediHstInf["diagnosis_year"].initValue && mediHstInf["diagnosis_month"].initValue  && mediHstInf["diagnosis_day"].initValue) {
            // 診断日の年月日がそろっている場合
            sortDate = mediHstInf["diagnosis_year"].initValue + mediHstInf["diagnosis_month"].initValue + mediHstInf["diagnosis_day"].initValue + "00";
          } else if (this.valiateObj(mediHstInf["disease_year"]) && mediHstInf["disease_year"].initValue &&this.valiateObj(mediHstInf["disease_month"]) &&  mediHstInf["disease_month"].initValue) {
            // 発症日の年月が入力されている場合
            sortDate = mediHstInf["disease_year"].initValue + mediHstInf["disease_month"].initValue + "0001";
          } else if (mediHstInf["diagnosis_year"].initValue && mediHstInf["diagnosis_month"].initValue) {
            // 診断日の年月が入力されている場合
            sortDate = mediHstInf["diagnosis_year"].initValue + mediHstInf["diagnosis_month"].initValue + "0000";
          } else if (this.valiateObj(mediHstInf["disease_year"]) && mediHstInf["disease_year"].initValue) {
            // 発症日の年が入力されている場合
            sortDate = mediHstInf["disease_year"].initValue + "000001";
          } else if (mediHstInf["diagnosis_year"].initValue) {
            // 診断日の年が入力されている場合
            sortDate = mediHstInf["diagnosis_year"].initValue + "000000";
          } else {
            // 発症日/診断日が空
            sortDate = "0000000000";
          }
          mediHstInf["sort_date"] = sortDate;
          arrMedicalHstInfoSorted.push(mediHstInf);
        }
        // 並べ替え実施
        arrMedicalHstInfoSorted.sort(function(a,b){
          if(a.sort_date < b.sort_date) return 1;
          if(a.sort_date > b.sort_date) return -1;
            return 0;
        });
        // 並べ替え用のカラムを削除
        arrMedicalHstInfoSorted.forEach(p => delete p.sort_date);
        return arrMedicalHstInfoSorted;
      },

      set(sortedAry) {
        this.editRecord[this.arrayColName] = sortedAry;
      }
    },

    isDie() {
      return "1" === this.getPatData("is_die").editValue;
    },

    /**
     * @description 死因内容を抽出
     * @returns {Object}
     */
    dieInfo() {
      let data = { is_die: "0", die_cd: null };
      if (this.jsonArray.length === 0) {
        return data;
      }

      let isDie = true;
      // 配列から死因選択時のものを探す
      for (const json of this.jsonArray) {
        if (
          this.getPatDataJsonArray(json, "out_come").editValue === "10" &&
          json.ctl_no.editValue >= 0
        ) {
          isDie = false;
          data = {
            is_die: "1",
            die_cd: this.getPatDataJsonArray(json, "disease_cd").editValue
          };
        } else if (isDie) {
          data = { is_die: "0", die_cd: null };
        }
      }
      return data;
    },

    /**
     * @description 原疾患内容フラグを抽出
     * @returns {Number}
     */
    primaryDiseaseCd() {
      let primaryDiseaseCd = null;
      if (this.jsonArray.length === 0) {
        return primaryDiseaseCd;
      }

      // 配列から死因選択時のものを探す
      for (const json of this.jsonArray) {
        if (
          this.getPatDataJsonArray(json, "is_dialysis_underlying_disease")
            .editValue === "1" &&
	  // add #12462 患者情報共有 Ji start  
          (
            this.getPatDataJsonArray(json, "facility_cd").initValue === this.facilityCd ||
            (
              this.getPatDataJsonArray(json, "facility_cd").initValue === this.getPatientShareFacilityCdMode &&
              this.getPatientShareMode == 0
            )
          ) &&
	  // add #12462 患者情報共有 Ji end
          json.ctl_no.editValue >= 0
        ) {
          primaryDiseaseCd = this.getPatDataJsonArray(json, "disease_cd")
            .editValue;
          break;
        }
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
	// mod #12462 患者情報共有 Ji start
        else if(
          this.getPatDataJsonArray(json, "is_dialysis_underlying_disease")
            .editValue === "0" &&
          this.getPatDataJsonArray(json, "facility_cd")
            .initValue === this.facilityCd
          ){
	  // mod #12462 患者情報共有 Ji end
          primaryDiseaseCd = null;
        }
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
      }
      return primaryDiseaseCd;
    },

    /**
     * @description 透析導入原疾患が設定されているフラグ
     * @returns {Boolean}
     */
    isSelectedPrimaryDiseaseCd() {
      // 設定されていたら編集不可へ
      return this.getPatData("primary_disease_cd").initValue !== null;
    },

    dieDate() {
      const die = this.jsonArray.find(json => json.out_come.editValue === "10");
      if (die !== undefined) {
        // add FutreNetWeb+SI課題管理No6115 趙 start
        if(die.die_date.editValue == null || die.die_date.editValue == ''){
          die.die_date.editValue = moment(new Date()).format("YYYYMMDD");
        }
        // add FutreNetWeb+SI課題管理No6115 趙 end
        const dieDate = moment(die.die_date.editValue, "YYYYMMDD");
        if (dieDate.isValid()) {
          return dieDate.format("YYYY-MM-DD HH:mm:ss");
        }
      }
      return null;
    },

    getDisableDatesAfter() {
      return moment(new Date()).format("YYYYMMDD");
    },

    selectedDate: () => {
      return function (json) { this.getPatDataJsonArray(json, 'disease_date');}
    },

    userArray() {
      return this.userData
    }
  },

  watch: {
    selectedPatId(val) {
      this.switchingSelectedPatFlg = true;
      this.refreshData();
      this.$nextTick(() => {
        this.switchingSelectedPatFlg = false;
      });
    },
    /**
     * @description 死因を設定
     */
    dieInfo() {
      this.setDie(this.dieInfo.is_die, this.dieInfo.die_cd);
    },

    primaryDiseaseCd() {
      this.setPatData("primary_disease_cd", this.primaryDiseaseCd);
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
      this.$nextTick(()=>{
        this.$forceUpdate();
      })
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
    },
  },

  async created() {
    this.refreshData()
    // del #10359 編集権限の動作不正 dengshen start
    // // add 編集権限の適用 じょはく start
    // if ( this.isCreationPat ) {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    // } else {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // }
    // // add 編集権限の適用 じょはく end
    // del #10359 編集権限の動作不正 dengshen end
    /* del by chamaojia 2025-05-21 [11871]  --start */
    // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
    // if (!this.mstFacility || this.mstFacility.length === 0) {
    //   await this.loadSysFacility();
    //   this.mstFacility = this.getSysFacilities;
    // }
    /* del by chamaojia 2025-05-21 [11871]  --end */
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    this.initRecord = JSON.parse(JSON.stringify(this.editRecord));
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    this.isInitFinished = true;
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
  },
  // add bug #7125 修正 chen start
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add bug #7125 修正 chen end

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    ...mapActions("mst-facility-setting", [
      "getDoctorsAtFacility",
      "getDoctorsAtFacilityIncludeDel",
    ]),
    ...mapActions("user-selector-popover", ["getMstJobData"]),
    // ...mapActions("user-selector-popover", ["getMst"]),modify by maxueqiang
    /* del by chamaojia 2025-05-21 [11871]  --start */
    // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
    /*...mapActions("sys-facility", ["loadSysFacility"]),*/
    /* del by chamaojia 2025-05-21 [11871]  --end */
    //#10866：日付(不定型)の部品修正Start
    datetypechk(json, itemnm) {
        const yy = this.getPatDataJsonArray(json, itemnm + 'year')
        const mm = this.getPatDataJsonArray(json, itemnm + 'month')
        const yy_str = yy.editValue != null ? yy.editValue : '0000';
        const mm_str = mm.editValue != null ? mm.editValue : '00';
        return yy_str + mm_str + '  ';
    },
    datetypeindex(action, index) {
        return action + index;
    },
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    //#10715:日付IF修正Start
    /**
     * @description 開始日フリー入力が選択されたらtrueを返す
     * @param {Object} json
     * @returns {Boolean}
     */
    isStartDateInputFreedisease(json) {
      return (
          this.getPatDataJsonArray(json, "disease_start_input_free").editValue ===
          "1"
        );
      },
    /**
     * @description 開始日フリー入力が選択されたらtrueを返す
     * @param {Object} json
     * @returns {Boolean}
     */
     isStartDateInputFreediagnosis(json) {
      return (
          this.getPatDataJsonArray(json, "diagnosis_start_input_free").editValue ===
          "1"
        );
      },
    changeinputfreedisease(json, Flag) {
        let start_date = this.getPatDataJsonArray(json, 'disease_date');
        this.setPatDataJsonArray(json, 'disease_start_input_free', Flag);
        if (start_date.editValue === null || start_date.editValue === 'Invalid date') {
          //#10715：日付IF修正20240910検証NG対応：村上Start
          if ((start_date.editValue != start_date.initValue) || start_date.initValue === null) {
            //#10715：日付IF修正20240910検証NG対応：村上End
            this.setPatDataJsonArray(json, 'disease_date', null);
            this.setPatDataJsonArray(json, 'disease_year', null);
            this.setPatDataJsonArray(json, 'disease_month', null);
            this.setPatDataJsonArray(json, 'disease_day', null);
          }
        }
    },
    changeinputfreediagnosis(json, Flag) {
        let start_date = this.getPatDataJsonArray(json, 'diagnosis_date');
        this.setPatDataJsonArray(json, 'diagnosis_start_input_free', Flag);
        if (start_date.editValue === null || start_date.editValue === 'Invalid date') {
          //#10715：日付IF修正20240910検証NG対応：村上Start
          if ((start_date.editValue != start_date.initValue) || start_date.initValue === null) {
            //#10715：日付IF修正20240910検証NG対応：村上End
            this.setPatDataJsonArray(json, 'diagnosis_date', null);
            this.setPatDataJsonArray(json, 'diagnosis_year', null);
            this.setPatDataJsonArray(json, 'diagnosis_month', null);
            this.setPatDataJsonArray(json, 'diagnosis_day', null);
          }
        }
    },
    //#10715:日付IF修正End
    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      try {
        // mod #6634 既往歴に登録した診療科と病名のマスタを削除すると診療科がコードで表示される。 付 start
        // const responseCourse = await ApiHelper.get("/mstInfo/mstCourse").catch(
        const responseCourse = await ApiHelper.get("/mstInfo/mstAllCourse").catch(
        // mod #6634 既往歴に登録した診療科と病名のマスタを削除すると診療科がコードで表示される。 付 end
          error => {
            getErrorMessage('MedicalHstCardContent.vue', 'created', error);
            throw error;
          }
        );
        this.mstCourse = responseCourse.data;

        // 登録済みの診断医を取得
        const facility_cd = this.facilityCd;
        const responseUser = await this.getDoctorsAtFacilityIncludeDel(facility_cd)
          .catch(error => {
            getErrorMessage('MedicalHstCardContent.vue', 'created', error);
            throw error;
          });
        this.mstUser = responseUser.data;
        // マスタユーザ取得フラグ
        this.isGotMstUser = true;

        this.userData = [];
        let params = [];
        /* add by chamaojia 2025-05-21 [11871]  --start */
        let cdList = [];
        /* add by chamaojia 2025-05-21 [11871]  --end */
        this.editRecord[this.arrayColName] && this.editRecord[this.arrayColName].forEach(info => {
          if (info.readonly) {
            if (info.readonly.initValue && info.readonly.editValue) {
              params.push(info.diagnostician_cd.initValue);
            }
          }
          /* add by chamaojia 2025-05-21 [11871]  --start */
          const diagnosisFacilityCd = this.getPatDataJsonArray(info, "diagnosis_facility_cd").editValue;
          if (diagnosisFacilityCd) {
            cdList.push(diagnosisFacilityCd);
          }
          /* add by chamaojia 2025-05-21 [11871]  --end */
        });
        /* add by chamaojia 2025-05-21 [11871]  --start */
        if(cdList.length > 0 ) {
          await ApiHelper.post("/sysFacility/getSysFacilityByCdList", cdList)
              .then(
                  (rest) =>{
                    for (let i = 0; i < rest.data.length; i++) {
                      const obj = {
                        cd: rest.data[i].medicalInstitutionCd,
                        name: rest.data[i].facilityName
                      }
                      this.facilityNameList.push(obj);
                    }
                  });
        } else {
          this.facilityNameList = [];
        }
        /* add by chamaojia 2025-05-21 [11871]  --end */
        params = params.filter(e => e !== null);
        if (params.length > 0) {
          await ApiHelper.post("/mstInfo/mstPersonalUserByIdList", params).then(res => {
            let item = [];
            for (let i = 0; i < res.data.length; i++) {
              const userInfo = {
                userId: res.data[i].userId,
                userName: res.data[i].userName,
              };
              item.push(userInfo);
            }
            this.userData = this.userData.concat(item);
          });
        }
        this.getMstJobData();

        // #9482 Stripping translation fields from the original structure
        this.selectedDiseaseList = [];
        let diseaseList = this.selectedDiseaseList;
        this.jsonArray.forEach( item => {
          diseaseList.push({
              diseaseCd: item.disease_cd?.initValue,
              facilityCd: facility_cd,
              diseaseName: item.disease_name?.initValue
          })
          // del #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 start
          // delete item.disease_name;
          // del #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241008 end
        })

      } catch (error) {
        this.setLoadingScreenVisible(false);
      }
      this.initRecord = deepCopy(this.editRecord);
      this.setLoadingScreenVisible(false);
    },
    // add bug #7125 修正 chen end

    mstDiseaseCdToNameIncludeDeleted(diseaseCd) {
      return this.mstCdToNameIncludeDeleted(this.deleteMstDisease, diseaseCd, "cd", "nm");
    },

    /**
     * 判断对象是否为null or undefined
     */
    valiateObj(obj){
      if(null != obj && undefined != obj){
        return true;
      } else {
        return false;
      }
    },
    // ---- ---- ---- ---- ---- ----
    // 項目追加
    // ---- ---- ---- ---- ---- ----
    async addItem() {
      // 新規項目作成
      const newItem = {
        ctl_no: 0, // 管理番号
        facility_cd: this.facilityCd,
        disp_order: 0, // 表示順
        disease_date: null, // 発症日付 YYYYMMDD
        disease_year: null, // 発症年 YYYY
        disease_month: null, // 発症月 MM
        disease_day: null, // 発症日 DD
        //#10715:日付IF修正Start
        disease_start_input_free: "0",
        disease_end_input_free: "0",
        //#10715:日付IF修正End
        diagnosis_date: null, // 診断日付 YYYYMMDD
        diagnosis_year: null, // 診断年 YYYYY
        diagnosis_month: null, // 診断月 MM
        diagnosis_day: null, // 診断日 DD
        //#10715:日付IF修正Start
        diagnosis_start_input_free: "0",
        diagnosis_end_input_free: "0",
        //#10715:日付IF修正End
        diagnosis_facility_cd: null, // 施設 施設マスタ.施設コード
        diagnosis_facility_is_free: "0", // 施設がフリーワードで入力されているか '0':選択、 '1':フリーワード
        course_cd: null, // 診療科 診療科マスタ.診療科コード
        course_is_free: "0", // 診療科がフリーワードで入力されているか '0':選択、 '1':フリーワード
        diagnostician_cd: null, // 診断医 利用者マスタ.利用者ＩＤ
        diagnostician_is_free: "0", // 診断医がフリーワードで入力されているか '0':選択、 '1':フリーワード
        disease_cd: null, // 病名 病名マスタ.病名コード,
        is_main_disease: "0", // 主病 '0':主病以外、'1':主病
        is_notice: "0", // 告知 '1:告知済、0:未告知
        is_dialysis_underlying_disease: "0", // 透析導入原疾患として扱う
        is_confirmation_biopsy: "0", // 生検確認
        out_come: "0", // 転帰
        is_diagnosed: "0", // 確診
        out_come_date: null, // 転帰日 YYYYMMDD
        memo: null,
        die_date: null, // 死亡日 YYYYMMDD
      };
      /* modify by chamaojia 2025-05-21 [11871]  --start */
      // if (this.mstFacility) {
      //   // 自施設が選択肢に存在する場合診断施設の初期値を自施設にする
      //   const loginFacility = this.mstFacility.find(item => item.facilityCd === this.facilityCd)
      //   if (loginFacility) {
      //     // mod 自施設の場合、診断施設コードを名称に変換する問題の対応 劉 start
      //     // newItem.diagnosis_facility_cd = loginFacility.facilityCd;
      //     newItem.diagnosis_facility_cd = loginFacility.medicalInstitutionCd;
      //     // mod 自施設の場合、診断施設コードを名称に変換する問題の対応 劉 end
      //   }
      // }
      const rest = await ApiHelper.get('/sysFacility/getSysFacilityByFacilityCd/'+this.facilityCd);
      if(rest.data) {
        newItem.diagnosis_facility_cd = rest.data.medicalInstitutionCd;
        const obj = {
          cd: rest.data.medicalInstitutionCd,
          name: rest.data.facilityName
        }
        this.facilityNameList.push(obj);
      }
      /* modify by chamaojia 2025-05-21 [11871]  --end */

      this.pushJsonArray(this.arrayColName, newItem);
    },

    setDie(isDievalue, dieCdValue) {
      // 死亡フラグをセット
      this.setPatData("is_die", isDievalue);
      // 死因に病名をセット
      this.setPatData("die_cd", dieCdValue);
      // 死亡日をセット
      this.setDieDate();
    },

    setDieDate() {
      // 死亡日をセット
      let dieDate = null;
      if (this.isDie) {
        dieDate = this.dieDate;
        dieDate = dieDate ? Date.parse(dieDate) : null;
      }

      this.setPatData("die_date", dieDate);
    },

    // ---- ---- ---- ---- ---- ----
    // 施設選択ポップアップ
    // ---- ---- ---- ---- ---- ----
    showPopoverFacilityCd(json, index) {
      this.selectedJson = json;
      this.selectedIndex = index;

      // ポップオーバのコンテンツデータを取りまとめる
      this.popoverDataFacilityCd.popoverVisible = true;
      this.popoverDataFacilityCd.popoverFilterLabel = "都道府県";

      const diagnosisFacilityCd = this.getPatDataJsonArray(json, "diagnosis_facility_cd").editValue;
      /* del by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // const popoverDataFacility = this.createPopoverDataFacility(
      //   this.popoverDataFacilityCd.popoverTitleHeader,
      //   this.popoverDataFacilityCd.popoverContentLabel,
      //   this.mstFacility,
      //   diagnosisFacilityCd
      // );
      /* del by chamaojia 2025-05-21 [11871]  --end */
      /* modify by chamaojia 2025-05-21 [11871]  --start */
      // this.popoverDataFacilityCd.popoverContentDataset = popoverDataFacility.popoverContentDataset;
      // this.popoverDataFacilityCd.popoverContentSelected = popoverDataFacility.popoverContentSelected;
      this.popoverDataFacilityCd.popoverContentDataset = [];
      this.popoverDataFacilityCd.popoverContentSelected = {
        "value": diagnosisFacilityCd,
        "text": "",
        "prefecturesCd": "",
        "medicalInstitutionCd": diagnosisFacilityCd
      };
      /* modify by chamaojia 2025-05-21 [11871]  --end */
    },

    // ---- ---- ---- ---- ---- ----
    // 診療科選択ポップアップ
    // ---- ---- ---- ---- ---- ----
    showPopoverCourseCd(json, index) {
      this.selectedJson = json;
      this.selectedIndex = index;

      const diagnosis_facility_cd = this.facilityCd

      // ポップオーバのコンテンツデータ(フィルタしたデータ)を取りまとめる
      const sortedMstCourse = this.mstCourse.sort((a, b) => a.standardCourseCd - b.standardCourseCd);
      const contentArr = sortedMstCourse.map(item => {
        return {
          value: item.courseCd,
          fnValue: item.facilityCd,
          text: item.courseName,
          isDisp: item.isDisp,
          isDel: item.isDel,
        };
      }).filter(item => (item.isDisp !== "0" && item.isDel !== "1"));

      const shavedContentArr = this.shavedFacility(
        contentArr,
        diagnosis_facility_cd
      );

      this.popoverDataCourseCd.popoverContentSelected.value = json.course_cd.editValue;
      this.popoverDataCourseCd.popoverVisible = true;
      this.popoverDataCourseCd.popoverFilterLabel = "施設";
      this.popoverDataCourseCd.popoverContentDataset = shavedContentArr;
    },

    // ---- ---- ---- ---- ---- ----
    // 診断医選択ポップアップ
    // ---- ---- ---- ---- ---- ----
    async showPopoverUserId(json, index) {
      const diagnosis_facility_cd = this.facilityCd;
      const responseUser= await this.getDoctorsAtFacility(diagnosis_facility_cd)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('MedicalHstCardContent.vue', 'showPopoverUserId', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw error;
        });

      this.selectedJson = json;
      this.selectedIndex = index;

      // ポップオーバのフィルタデータを取りまとめる
      /* modify by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // const filterArr = [
      //   {
      //     text: this.mstCdToName(
      //       this.mstFacility,
      //       diagnosis_facility_cd,
      //       "facilityCd",
      //       "facilityNameKana"
      //     ),
      //     value: diagnosis_facility_cd
      //   }
      // ];
      const filterArr = [
        {
          text: "削除済み",
          value: diagnosis_facility_cd
        }
      ];
      /* modify by chamaojia 2025-05-21 [11871]  --end */

      // ポップオーバのコンテンツデータ(フィルタしたデータ)を取りまとめる
      const contentArr = responseUser.data.map(item => {
        return {
          value: item.user_id,
          fnValue: diagnosis_facility_cd,
          text: `${item.user_last_name} ${item.user_first_name}`,
          // add start 馬 #10097
          jobCd: item.job_cd
          // add end 馬 #10097
        };
      });

      const shavedContentArr = this.shavedFacility(
        contentArr,
        diagnosis_facility_cd
      );
      // ポップオーバのフィルタデータを取りまとめる
      const all = { text: "すべて", value: 0 };
      // modify start 馬 #10097
      const filterJobCdArr = [
        all,
        ...this.mstJob?.filter((item) => {
          return item.isDoctor === '1';
        })?.map(item => ({
          text: item.jobName,
          value: String(item.jobCd)
        }))
      ];
      // modify end 馬 #10097

      // ドロップダウン選択肢設定
      this.popoverDataUserId.popoverFilter = [
        {
          popoverFilterLabel: "職種",
          popoverFilterDataset: filterJobCdArr
        }
      ];

      // mod 11872 利用者指定IFのデフォルト選択状態 zrx start  新規患者登録-既往歴-診断医
      // this.popoverDataUserId.popoverContentSelected.value = json.diagnostician_cd.editValue;
      this.popoverDataUserId.popoverContentSelected.value = json.diagnostician_cd.editValue ? json.diagnostician_cd.editValue :
        this.getStateUserAccountInfo.userId;

      // mod 11872 利用者指定IFのデフォルト選択状態 zrx start

      // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  補充する start 
      let isUsedUserInfoID = false;
      isUsedUserInfoID = json.diagnostician_cd.editValue?false:true
      this.popoverDataUserId.isUsedUserInfoID = isUsedUserInfoID;
      // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  補充する end 
      
      this.popoverDataUserId.popoverVisible = true;
      this.popoverDataUserId.popoverFilterLabel = "施設";
      this.popoverDataUserId.popoverFilterDataset = filterArr;
      // modify start 馬 #10097
      this.popoverDataUserId.popoverFilterDisabled = false;
      // modify end 馬 #10097
      this.popoverDataUserId.popoverContentDataset = shavedContentArr;

      // 取得したマスタユーザーを表示ようにマスタへ格納
      const isFacilityCd = this.mstUser.find(item => {
        return item.facilityCd === diagnosis_facility_cd;
      });
      if (isFacilityCd === undefined) {
        this.mstUser.push(...responseUser.data);
      }
    },

    // ---- ---- ---- ---- ---- ----
    // 病名選択ポップアップ
    // ---- ---- ---- ---- ---- ----
    showPopoverDiseaseCd(json, index) {
      this.selectedJson = json;
      this.selectedIndex = index;

      const diagnosis_facility_cd = this.facilityCd;

      // ポップオーバのフィルタデータを取りまとめる
      /* modify by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // const filterArr = [
      //   {
      //     text: this.mstCdToName(
      //       this.mstFacility,
      //       diagnosis_facility_cd,
      //       "facilityCd",
      //       "facilityNameKana"
      //     ),
      //     value: diagnosis_facility_cd
      //   }
      // ];
      const filterArr = [
        {
          text: "削除済み",
          value: diagnosis_facility_cd
        }
      ];
      /* modify by chamaojia 2025-05-21 [11871]  --end */
      

      // ポップオーバのコンテンツデータ(フィルタしたデータ)を取りまとめる
      // const contentArr = this.mstDisease.map(item => {
      //   // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
      //   // return {
      //   //   value: item.diseaseCd,
      //   //   fnValue: item.facilityCd,
      //   //   text: item.diseaseName
      //   // };
      //   return {
      //     value: item.cd,
      //     fnValue: this.facilityCd,
      //     text: item.nm
      //   };
      //   // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end
      // });

      // const shavedContentArr = this.shavedFacility(
      //   contentArr,
      //   diagnosis_facility_cd
      // );

      this.popoverDataDiseaseCd.popoverContentSelected.value = json.disease_cd.editValue;
      // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
      // this.popoverDataDiseaseCd.popoverVisibleDisea = true;
      this.popoverDataDiseaseCd.popoverVisible = true;
      // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end
      this.popoverDataDiseaseCd.popoverFilterLabel = "施設";
      this.popoverDataDiseaseCd.popoverFilterDataset = filterArr;
      this.popoverDataDiseaseCd.popoverFilterDisabled = true;
      // this.popoverDataDiseaseCd.popoverContentDataset = shavedContentArr;
      this.popoverDataDiseaseCd.isAllValues = false;
    },

    /**
     * @description 施設から診療科・診断医・病名を絞り込み
     * @param {Object} facility 施設コード
     * @param {Object} mstData マスタデータ
     * @returns {Object}
     */
    shavedFacility(mstData, diagnosis_facility_cd) {
      return mstData.filter(mst => mst.fnValue === diagnosis_facility_cd);
    },

    // ---- ---- ---- ---- ---- ----
    // ポップアップ終了
    // ---- ---- ---- ---- ---- ----
    closePopover() {
      this.selectedJson = null;
      this.popoverDataFacilityCd.popoverVisible = false;
      this.popoverDataCourseCd.popoverVisible = false;
      this.popoverDataUserId.popoverVisible = false;
      // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
      // this.popoverDataDiseaseCd.popoverVisibleDisea = false;
      this.popoverDataDiseaseCd.popoverVisible = false;
      // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end
    },

    /**
     * @description 吹き出し選択内容を各キーに設定
     * @param {Object} data
     * @param {String} jsonKey
     */
    updateInput(data, jsonKey) {
      if (data !== null) {
        /* add by chamaojia 2025-05-21 [11871]  --start */
        // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
        // バウンディングボックスで選択したデータは、エコー用の配列に格納されます。
        let obj = {
          cd:data.value,
          name:data.text
        };
        this.facilityNameList.push(obj);
        /* add by chamaojia 2025-05-21 [11871]  --end */
        // 施設を選択したらフリーワードフラグを0にする
        if (jsonKey === "diagnosis_facility_cd") {
          this.setPatDataJsonArray(this.selectedJson, "diagnosis_facility_is_free", "0");
        }
        // 診療科を選択したらフリーワードフラグを0にする
        if (jsonKey === "course_cd") {
          this.setPatDataJsonArray(this.selectedJson, "course_is_free", "0");
        }
        // 診断医を選択したらフリーワードフラグを0にする
        if (jsonKey === "diagnostician_cd") {
          this.setPatDataJsonArray(this.selectedJson, "diagnostician_is_free", "0");
        }
        if (jsonKey === "disease_cd") {
          const index = this.selectedDiseaseList.findIndex((item) => {
            return item.diseaseCd === data.value;
          })
          index < 0 && this.selectedDiseaseList.push({
            diseaseCd: data.value,
            facilityCd: data.fnValue,
            diseaseName: data.text
          })
        }
        this.setPatDataJsonArray(this.selectedJson, jsonKey, data.value);
      }
    },

    /**
     * @description 施設変更時、診療科・診断医・病名をnull
     * @param {Object} json
     */
    clearCourseDoctor(json) {
      this.setPatDataJsonArray(json, "course_cd", null);
      this.setPatDataJsonArray(json, "diagnostician_cd", null);
      this.setPatDataJsonArray(json, "disease_cd", null);
    },

    // ---- ---- ---- ---- ---- ----
    // 主病変更
    // ---- ---- ---- ---- ---- ----
    // mod 主病重複エラーチェック不正について、修正する。 dengshen start
    // changeMainDisease(data, json) {
    //   if (data === "1") {
    changeMainDisease(json) {
      let data = this.getPatDataJsonArray(json, 'is_main_disease');
      if (data.editValue === "1") {
    // mod 主病重複エラーチェック不正について、修正する。 dengshen end
        if (this.duplicationChecker("is_main_disease", "1") > 1) {
          this.selectedMainDisease = json;
          // 主病重複エラー
          this.stringParams = ["主病"];
          this.isWarningDialogVisible = true;
        }
      }
    },

    // ---- ---- ---- ---- ---- ----
    // 透析導入原疾患変更
    // ---- ---- ---- ---- ---- ----
    changeDialysisUnderlyingDisease(value, json) {
      // チェック時
      if (value === "1") {
        // 重複チェック時
        if (
          this.duplicationChecker("is_dialysis_underlying_disease", "1") > 1
        ) {
          this.dialysisUnderlyingDisease = json;

          // メッセージ表示:透析導入原疾患として扱う重複エラー
          this.stringParams = ["透析導入原疾患"];
          this.isWarningDialogVisible = true;
        }
      }
    },

    // ---- ---- ---- ---- ---- ----
    // 転帰変更
    // ---- ---- ---- ---- ---- ----
    focusOutCome(data, json) {
      this.previousOutCome = this.getPatDataJsonArray(
        json,
        "out_come"
      ).editValue;
    },
    changeOutCome(data, json) {

      // 転帰変更時、転帰変更日に当日日付を設定する
      this.setPatDataJsonArray(json, "out_come_date", moment(new Date).format("YYYYMMDD"));

      if (data === "10") {
        // 死亡の場合
        // add FutreNetWeb+SI課題管理No6115 start
        // 死亡の場合、死亡日に当日日付を設定する
        this.setPatDataJsonArray(json, "die_date", moment(new Date).format("YYYYMMDD"));
        // add FutreNetWeb+SI課題管理No6115 end
        if (this.duplicationChecker("out_come", "10") > 1) {
          this.setPatDataJsonArray(json, "out_come", this.previousOutCome);

          // 転帰－死亡重複エラー
          this.stringParams = ["転帰－死亡"];
          this.isWarningDialogVisible = true;
        }
      }
    },

    /**
     * @description 重複チェック
     * @param {String} jsonKey
     * @param {String} checkValue
     * @returns {String}
     */
    duplicationChecker(jsonKey, checkValue) {
      let targetCount = 0;
      for (const json of this.jsonArray) {
        // 重複している場合値を加算する
        if (
          this.getPatDataJsonArray(json, jsonKey).editValue === checkValue &&
          json.ctl_no.editValue >= 0
        ) {
          targetCount++;
        }
      }
      return targetCount;
    },

    /**
     * @description 担当医コードを名字と名前に変換する
     * @param {Object} json
     * @param {String} jsonKey
     * @returns {String}
     */
    diagnosticianName(json) {
      if (this.isGotMstUser) {
        const diagnostician = this.getPatDataJsonArray(json, "diagnostician_cd")
          .editValue;
        if (!diagnostician || !this.mstUser) return "";
        const lastName = this.mstCdToNameFreeWord(
          this.mstUser,
          diagnostician,
          "user_id",
          "user_last_name"
        );
        const firstName = this.mstCdToNameFreeWord(
          this.mstUser,
          diagnostician,
          "user_id",
          "user_first_name"
        );
        if (!lastName || !firstName) {
          this.setPatDataJsonArray(json, "diagnostician_is_free", "1");
          return `${diagnostician}`;
        }
        return `${lastName} ${firstName}`;
      }
    },

    // ※保存時、死亡選択時trueを返す
    hasDeathItem() {
      const deathItem = this.jsonArray.find(
        json =>
          json.out_come.editValue === this.outComeList[9].value &&
          json.ctl_no.editValue >= 0
      );
      return deathItem !== undefined;
    },

    /**
     * @description 削除した死亡データ(json)
     * @summary 保存時に呼び出す
     * @returns { Object }
     */
    deathItem() {
      // 編集前の死亡jsonを取得
      const json = this.jsonArray.find(
        json => json.out_come.initValue === this.outComeList[9].value
      );
      if (json === undefined) {
        // 編集前に死亡がない場合
        return undefined;
      }

      const deleteJson = { ...json };
      deleteJson.period_start = {
        initValue: this.changeDate(deleteJson, "initValue"),
        editValue: this.changeDate(deleteJson, "editValue")
      };
      // 削除した死亡jsonを返す
      if (
        // ctl_noが負数なら削除
        deleteJson.ctl_no.editValue < 0 ||
        // out_comeが編集前後違うなら死亡から別に変更
        deleteJson.out_come.initValue !== deleteJson.out_come.editValue ||
        deleteJson.period_start.initValue !==
          deleteJson.period_start.editValue ||
        deleteJson.diagnosis_facility_cd.initValue !==
          deleteJson.diagnosis_facility_cd.editValue ||
        deleteJson.course_cd.initValue !== deleteJson.course_cd.editValue ||
        deleteJson.diagnostician_cd.initValue !==
          deleteJson.diagnostician_cd.editValue
      ) {
        // 編集後に死亡を削除したか変更した場合
        // または診断日,施設,診療科,診断医が編集前後違うなら入外・転入出に再度設定するため削除する
        return deleteJson;
      }

      return undefined;
    },

    // TODO: 一時的に保留: 保存時バリデーション精査中
    //※保存時、死亡時:死亡日を入外・転入出に投げる
    getDeathDate() {
      const deathItem = this.jsonArray.find(
        json =>
          json.out_come.editValue === this.outComeList[9].value &&
          json.ctl_no.editValue >= 0
      );
      if (deathItem === undefined) {
        return null;
      }
      return this.changeDate(deathItem, "editValue");
    },

    changeDate(json, key) {
      const dieDate = json.die_date[key];
      if (dieDate) {
        return dieDate;
      } else {
        return null;
      }
    },

    // ※保存時、死亡時:施設を入外・転入出に投げる
    getDeathFacility() {
      for (const json of this.jsonArray) {
        if (
          this.getPatDataJsonArray(json, "out_come").editValue ===
            this.outComeList[9].value &&
          json.ctl_no.editValue >= 0
        ) {
          return this.getPatDataJsonArray(json, "diagnosis_facility_cd")
            .editValue;
        }
      }
      return null;
    },

    // ※保存時、死亡時:診療科を入外・転入出に投げる
    getDeathCourse() {
      for (const json of this.jsonArray) {
        if (
          this.getPatDataJsonArray(json, "out_come").editValue ===
            this.outComeList[9].value &&
          json.ctl_no.editValue >= 0
        ) {
          return this.getPatDataJsonArray(json, "course_cd").editValue;
        }
      }
      return null;
    },
    // ※保存時、死亡時:診断医を入外・転入出に投げる
    getDeathDiagnostician() {
      for (const json of this.jsonArray) {
        if (
          this.getPatDataJsonArray(json, "out_come").editValue ===
            this.outComeList[9].value &&
          json.ctl_no.editValue >= 0
        ) {
          return this.getPatDataJsonArray(json, "diagnostician_cd").editValue;
        }
      }
      return null;
    },

    // 月・日を2桁へ変換
    addNumber(json, key) {
      const value = this.getPatDataJsonArray(json, key).editValue;
      if (value !== null) {
        if (key === "diagnosis_year" || key === "disease_year") {
          // 年が編集された場合、数値以外はnullにする
          if (isFinite(value)) {
            const year = value.padStart(4, 0);
            this.setPatDataJsonArray(json, key, year);
          }else{
            this.setPatDataJsonArray(json, key, null);
          }
        }
        else if (key === "diagnosis_month" || key === "disease_month") {
          // 月が編集された場合、12を超える数値は12にする、数値以外はnullにする
          if (isFinite(value) && Number(value) <= 12 && Number(value) >= 1){
            const month = value.padStart(2, 0);
            this.setPatDataJsonArray(json, key, month);
          } else if (isFinite(value) && Number(value) > 12) {
            this.setPatDataJsonArray(json, key, "12");
          } else{
            this.setPatDataJsonArray(json, key, null);
          }
        }
        else if (key === "diagnosis_day" || key === "disease_day") {
          // 日が編集された場合、数値以外はnullにする
          if (isFinite(value)){
            const day = value.padStart(2, 0);
            this.setPatDataJsonArray(json, key, day);
          } else{
            this.setPatDataJsonArray(json, key, null);
          }
        }

        // 入力された年月日が正当な日付であるかチェックする
        let setDayKey = ""
        let keyYear = "";
        let keyMonth = "";
        let keyDay = ""
        if (key.match(/disease/)) {
          setDayKey = "disease_day";
          keyYear = this.getPatDataJsonArray(json, "disease_year").editValue;
          keyMonth = this.getPatDataJsonArray(json, "disease_month").editValue;
          keyDay = this.getPatDataJsonArray(json, "disease_day").editValue;
        }
        else if (key.match(/diagnosis/)) {
          setDayKey = "diagnosis_day";
          keyYear = this.getPatDataJsonArray(json, "diagnosis_year").editValue;
          keyMonth = this.getPatDataJsonArray(json, "diagnosis_month").editValue;
          keyDay = this.getPatDataJsonArray(json, "diagnosis_day").editValue;
        }
        const maxDay = getMaxDay(keyYear, keyMonth);
        this.setCheckedheDay(maxDay, json, setDayKey, keyDay)


        // 発症日が変更された場合disease_dateを更新
        if (key === "disease_year" || key === "disease_month" || key === "disease_day" ) {
          const year = this.getPatDataJsonArray(json, "disease_year").editValue;
          const month = this.getPatDataJsonArray(json, "disease_month").editValue;
          const day = this.getPatDataJsonArray(json, "disease_day").editValue;

          if (year && month && day) {
            const diseaseDate = moment(`${year}${month}${day}`)
            // 入力された日付が正しい日付の場合のみセット
            if (diseaseDate.isValid()) {
              this.setPatDataJsonArray(json, "disease_date", diseaseDate.format("YYYYMMDD"));
            } else {
              this.setPatDataJsonArray(json, "disease_date", null);
            }
          } else {
            this.setPatDataJsonArray(json, "disease_date", null);
          }
        }
        // 診断日が変更された場合diagnosis_dateを更新
        if (key === "diagnosis_year" || key === "diagnosis_month" || key === "diagnosis_day" ) {
          const year = this.getPatDataJsonArray(json, "diagnosis_year").editValue;
          const month = this.getPatDataJsonArray(json, "diagnosis_month").editValue;
          const day = this.getPatDataJsonArray(json, "diagnosis_day").editValue;

          if (year && month && day) {
            const diagnosisDate = moment(`${year}${month}${day}`)
            // 入力された日付が正しい日付の場合のみセット
            if (diagnosisDate.isValid()) {
              this.setPatDataJsonArray(json, "diagnosis_date", diagnosisDate.format("YYYYMMDD"));
            } else {
              this.setPatDataJsonArray(json, "diagnosis_date", null);
            }
          } else {
            this.setPatDataJsonArray(json, "diagnosis_date", null);
          }
        }
      } else {
        // 入力年/月/日いずれかが空欄の場合は不正な日付としてdate項目をnullにする
        if (key === "disease_year" || key === "disease_month" || key === "disease_day") {
          // 発症日
          this.setPatDataJsonArray(json, "disease_date", null);
        } else if (key === "diagnosis_year" || key === "diagnosis_month" || key === "diagnosis_day") {
          // 診断日
          this.setPatDataJsonArray(json, "diagnosis_date", null);
        }
      }
    },

    // 年月日が正当な日付かチェックする
    setCheckedheDay(maxDay, json, key, value) {
      if (isFinite(value) && Number(value) <= maxDay && Number(value) >= 1) {
        // 正当な日付の場合、日をセットする
        const day = value.padStart(2, 0);
        this.setPatDataJsonArray(json, key, day);
      } else if (isFinite(value) && Number(value) > maxDay) {
        // 年月の最終日を超える場合、最終日をセットする
        this.setPatDataJsonArray(json, key,  String(maxDay).padStart(2, 0));
      } else{
        // 正当な日付じゃない場合、nullをセットする
        this.setPatDataJsonArray(json, key, null);
      }
    },

    // マスタ選択ポップオーバーの表示位置とする対象コンポーネント
    popoverTargetElement(btnSelect) {
      // 初期表示時は未選択なのでnull
      return this.selectedIndex === null
        ? null
        : this.$refs[`${btnSelect}${this.selectedIndex}`][0];
    },

    /**
     * @description 重複した項目をリセット
     */
    confirm() {
      if (
        this.selectedMainDisease !== null &&
        this.stringParams[0] === "主病"
      ) {
        // 主病が重複いる場合
        this.setPatDataJsonArray(
          this.selectedMainDisease,
          "is_main_disease",
          "0"
        );
      }

      if (
        this.dialysisUnderlyingDisease !== null &&
        this.stringParams[0] === "透析導入原疾患"
      ) {
        // 透析導入原疾患が重複いる場合
        this.setPatDataJsonArray(
          this.dialysisUnderlyingDisease,
          "is_dialysis_underlying_disease",
          "0"
        );
      }
    },

    /**
     * @description 死亡選択フラグ
     */
    isSelectedDie(json) {
      // 死亡が選択されていたら編集不可へ
      return this.getPatDataJsonArray(json, "out_come").initValue === "10";
    },

    /**
     * @description 透析導入原疾患選択フラグ
     */
    isSelectedDialysisUnderlyingDisease(json) {
      // 透析導入原疾患が選択されていたら編集不可へ
      return (
        this.getPatDataJsonArray(json, "is_dialysis_underlying_disease")
          .initValue === "1"
      );
    },

    /**
     * @description 死亡データを削除
     * @summary 既往歴の死亡を削除すると発火
     * @param { Array } 削除する死亡リスト
     */
    deleteDeathItem(deleteJson) {
      if (
        this.jsonArray.find(
          json => json.out_come.editValue === this.outComeList[9].value
        )
      ) {
        const die_date = deleteJson.die_date.editValue;
        const diagnosis_facility_cd = deleteJson.from_facility.editValue;
        const course_cd = deleteJson.from_course.editValue;
        const diagnostician_cd = deleteJson.from_doctor.editValue;

        const removedDeleteJsonArray = this.jsonArray.filter(
          json =>
            json.die_date.editValue !== die_date ||
            json.diagnosis_facility_cd.editValue !== diagnosis_facility_cd ||
            json.course_cd.editValue !== course_cd ||
            json.diagnostician_cd.editValue !== diagnostician_cd
        );
        this.jsonArray = removedDeleteJsonArray;
        this.setDieInfo();
      }
    },

    setDieInfo() {
      this.setDie(this.dieInfo.is_die, this.dieInfo.die_cd);
    },

    confirmSave(answer) {
      this.isVisitHstMessage = false;
      // del FutreNetWeb+SI課題管理No6117 趙 start
      // if (answer === "OK") {
      // del FutreNetWeb+SI課題管理No6117 趙 end
        this.deleteJsonArray(
          this.arrayColName,
          this.selectJson,
          this.selectIndex
        );
      // del FutreNetWeb+SI課題管理No6117 趙 start
      // }
      // del FutreNetWeb+SI課題管理No6117 趙 end
    },

    setJsonIndex(json, index) {
      this.selectJson = json;
      this.selectIndex = index;
      if (json.out_come.editValue === this.outComeList[9].value) {
        // mod FutreNetWeb+SI課題管理No6117 趙 start
        // this.isMedicalHstMessage = true;
        this.$ons.notification
          .confirm({
            title: "既往歴の削除",
            message: "入外・転入出の死亡情報も削除されますがよろしいですか？"
          })
          .then((ok) => {
            if (ok) {
              this.confirmSave();
            }
          });
        // mod FutreNetWeb+SI課題管理No6117 趙 end
      } else {
        this.deleteJsonArray(
          this.arrayColName,
          this.selectJson,
          this.selectIndex
        );
      }
    },

    /**
     * @description 診療科を変換する
     * @param {Object} json
     * @returns {String}
     */
    dispCourseName(json) {
      const courseCd = this.getPatDataJsonArray(json, "course_cd").editValue;
      if (!courseCd || !this.mstCourse) return "";
      const courseName = this.mstCdToNameFreeWord(
        this.mstCourse,
        courseCd,
        "courseCd",
        "courseName"
      );
      if (!courseName) {
        this.setPatDataJsonArray(json, "course_is_free", "1");
        return `${courseCd}`;
      }
      return `${courseName}`;
    },

    /**
     * @description 施設を変換する
     * @param {Object} json
     * @returns {String}
     */
    dispFacilityName(json) {
      const diagnosisFacilityCd = this.getPatDataJsonArray(json, "diagnosis_facility_cd").editValue;
      if (!diagnosisFacilityCd) return "";
	  
      //全施設マスタのデータが取得できなかった場合
	  if(this.facilityNameList.length === 0){
        this.setPatDataJsonArray(json, "diagnosis_facility_is_free", "1");
        return `${diagnosisFacilityCd}`;
	  }
	  
      let diagnosisFacilityName = "";
      const facilityName = this.facilityNameList.find(item => item.cd == diagnosisFacilityCd);
      diagnosisFacilityName = facilityName?.name;

      if (diagnosisFacilityName) {
        this.setPatDataJsonArray(json, "diagnosis_facility_is_free", "0");
        return `${diagnosisFacilityName}`;
      }else{
        this.setPatDataJsonArray(json, "diagnosis_facility_is_free", "1");
        return `${diagnosisFacilityCd}`;
	  }
      
    },

    /**
     * @description 発症日、診断日のカレンダーを選択したときに呼び出される処理
     * @param {String} value
     * @param {Object} params
     */
    setDateEach: function(value,params) {
      if (params.fromData && params.fromData === "disease_date") {
        const diseaseDate = moment(value);
        // 入力された日付が正しい日付の場合のみセット
        if (diseaseDate.isValid() && params.json) {
          this.setPatDataJsonArray(params.json, "disease_year", diseaseDate.format("YYYY"));
          this.setPatDataJsonArray(params.json, "disease_month", diseaseDate.format("MM"));
          this.setPatDataJsonArray(params.json, "disease_day", diseaseDate.format("DD"));
        } else {
          this.setPatDataJsonArray(params.json, "disease_year", null);
          this.setPatDataJsonArray(params.json, "disease_month", null);
          this.setPatDataJsonArray(params.json, "disease_day", null);
        }
      }
      else if (params.fromData && params.fromData === "diagnosis_date") {
        const diagnosisDate = moment(value);
        // 入力された日付が正しい日付の場合のみセット
        if (diagnosisDate.isValid() && params.json) {
          this.setPatDataJsonArray(params.json, "diagnosis_year", diagnosisDate.format("YYYY"));
          this.setPatDataJsonArray(params.json, "diagnosis_month", diagnosisDate.format("MM"));
          this.setPatDataJsonArray(params.json, "diagnosis_day", diagnosisDate.format("DD"));
        } else {
          this.setPatDataJsonArray(params.json, "diagnosis_year", null);
          this.setPatDataJsonArray(params.json, "diagnosis_month", null);
          this.setPatDataJsonArray(params.json, "diagnosis_day", null);
        }
      }
    },

    setContentDataMemo(newValue, index) {
      this.setPatDataJsonArray(this.jsonArray[index], "memo", newValue);
    },

    // #9482 Add method to fixed performance issues
    setPopoverSearchCondition (searchCondition) {
      this.popoverDataDiseaseCd.popoverSearchQuery = searchCondition;
    },

    /**
     * @description 病名を変換する
     * @param {Object} json
     * @returns {String}
     */
    dispDiseaseName(json) {
      const diseaseName = this.mstCdToNameFreeWord(
        this.selectedDiseaseList,
        this.getPatDataJsonArray(json, 'disease_cd').editValue,
        'diseaseCd',
        'diseaseName'
      );
      // prefix【削除済み】を除去して返却
      const diseaseNameReplace =  !diseaseName ? "" : diseaseName.replace("【削除済み】", "");
      return diseaseNameReplace;
    },

  // add #12462 患者情報共有 Ji start
  /**
   * @description 該当行が他院情報かどうかを判定
   * @param {Object} json - 患者情報
   * @returns {Boolean} true = 他施設のデータは参照のみ
   */
    isOtherFacilityRow(json) {
      return (json.facility_cd?.initValue !== this.facilityCd || this.getIsOtherFacility);
    },
    /**
     *
     * @param json - 患者情報
     * @param cdKey - code(自施設)
     * @param nameKey - name(他施設)
     */
    getFieldValue(json, cdKey, nameKey) {
      const isOtherFacility = json.facility_cd?.initValue !== this.facilityCd;
      return this.getPatDataJsonArray(
        json,
        isOtherFacility ? nameKey : cdKey
      );
    },
    /**
     *
     * @param json - 患者情報
     * @param displayFunc - 変換Function
     */
    getNameDisplay(json, displayFunc, nameKey) {
      if (json.facility_cd?.initValue !== this.facilityCd) {
        const nameObj = this.getPatDataJsonArray(json, nameKey);
        return nameObj.editValue;
      }
      return displayFunc(json);
    }
  }
  // add #12462 患者情報共有 Ji end
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/* カード個別のスタイルはここ */

.table-area {
  width: 100%;
}

.custom-select {
  /* width: 30%; */
  /* modify by maxueqiang */
  width: 100px !important;
}

.diagnosis-date {
  width: 20%;
}
.input-date >>> .custom-input-date {
  width: auto;
}
.card-table >>> textarea.custom-textarea {
  color: black !important;
}
/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
td .custom-textarea-edited {
  border: 2px green solid;
}
</style>
