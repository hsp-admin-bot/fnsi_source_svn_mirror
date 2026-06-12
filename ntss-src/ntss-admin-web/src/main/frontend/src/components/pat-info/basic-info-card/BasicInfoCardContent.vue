<template>
  <table class="card-table">
    <tbody>
    <tr>
      <td class="item-title">ID</td>
      <td colspan="2" class="item-data">
        <div style="display: flex">
          <custom-input
            ref="hosp_pat_id"
            :value="getPatData('hosp_pat_id')"
            :is-required="true"
            :validators="[validateID]"
            maxlength="12"
            form-name="ID"
            :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
            class="idInputChange"
            @input="filterInput($event, 'hosp_pat_id')"
          />
          <v-ons-button
            v-show="isCreationPat && isShowPatientCapture"
            class="patient-capture common-style-select-button btn3-normal"
            :disabled ="!getItemAuthorized('PatInfo', 'default_authority') || this.isEnAblePatCap || getIsOtherFacility"
            @click="showPatCapture"
          >
            取込
          </v-ons-button>
        </div>
      </td>
    </tr>
    <tr>
      <td class="item-title">患者名</td>
      <td class="item-data">
        <custom-simple-textarea-a
          ref="pat_last_name"
          :value="getPatData('pat_last_name')"
          :is-required="true"
          placeholder="姓"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          form-name="患者名(姓)"
          @input="filterInput($event, 'pat_last_name')"
          style="vertical-align: middle;"
        />
      </td>
      <td class="item-data">
        <custom-simple-textarea-a
          ref="pat_first_name"
          :value="getPatData('pat_first_name')"
          :is-required="true"
          placeholder="名"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          form-name="患者名(名)"
          @input="filterInput($event, 'pat_first_name')"
          style="vertical-align: middle;"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">フリガナ</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="getPatData('pat_last_name_kana')"
          placeholder="セイ"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @input="filterInput($event, 'pat_last_name_kana')"
          style="vertical-align: middle;"
        />
      </td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="getPatData('pat_first_name_kana')"
          placeholder="メイ"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @input="filterInput($event, 'pat_first_name_kana')"
          style="vertical-align: middle;"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">英語表記</td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="getPatData('pat_last_name_alpha')"
          placeholder="last name"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @input="filterInput($event, 'pat_last_name_alpha')"
          style="vertical-align: middle;"
        />
      </td>
      <td class="item-data">
        <custom-simple-textarea-a
          :value="getPatData('pat_first_name_alpha')"
          placeholder="first name"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @input="filterInput($event, 'pat_first_name_alpha')"
          style="vertical-align: middle;"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">入外区分</td>
        <custom-select
          v-if="inOutClassValue === 2"
          style="width: 100px;"
          ref="in_out_class"
          :value="getPatData('in_out_class')"
          :options="deathOptions"
          :disabled="true"
        />
        <custom-select
          v-else
          style="width: 100px;"
          ref="in_out_class"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :value="getPatData('in_out_class')"
          :options="optionsInOutClass"
        />
    </tr>
    <tr>
      <td class="item-title">在院</td>
      <td colspan="2" class="item-data">
        {{ inOutCurrentState }}
      </td>
    </tr>
    <tr>
      <td class="item-title">生年月日</td>
      <td colspan="2" class="item-data">
        <custom-input-date
          v-if="inOutClassValue === 2"
          class="input-date"
          :disabled="true"
          :value="getPatData('pat_birthday')"
          :birthday-mode="true"
        />
        <custom-input-date
          v-else
          class="input-date"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :value="getPatData('pat_birthday')"
          :birthday-mode="true"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">年齢</td>
      <td colspan="2" class="item-data">
        {{ age }}
      </td>
    </tr>
    <tr>
      <td class="item-title">性別</td>
      <td colspan="2" class="item-data">
        <custom-radio
          :value="getPatData('pat_sex')"
          :radio-value="0"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          name="sex"
        >
          不明
        </custom-radio>
        <custom-radio
          :value="getPatData('pat_sex')"
          :radio-value="1"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          name="sex"
        >
          男性
        </custom-radio>
        <custom-radio
          :value="getPatData('pat_sex')"
          :radio-value="2"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          name="sex"
        >
          女性
        </custom-radio>
      </td>
    </tr>
    <tr>
      <td class="item-title">血液型</td>
      <td colspan="2" class="item-data">
        <div class="item-data-blood">
          <div class="item-data-conponent">
            <span class="blood-input-area">ABO型</span>
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <custom-select -->
            <!--   :value="getPatData('pat_blood_type_abo')" -->
            <!--   :disabled="this.editFlag" -->
            <!--   :options="optionTypeAbo" -->
            <!--   class="blood-input-area" -->
            <!--   @change="setBloodType" -->
            <!-- /> -->
            <custom-select
              :value="getPatData('pat_blood_type_abo')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              :options="optionTypeAbo"
              class="blood-input-area"
              @change="setBloodType"
            />

          </div>
          <div class="item-data-conponent">
            <span class="blood-input-area">Rh型</span>
            <custom-select
              :value="getPatData('pat_blood_type_rh')"
              :options="optionTypeRh"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              class="blood-input-area"
            />
          </div>
          <div class="item-data-conponent">
            <br v-if="isABBloodType()">
            <span class="blood-input-area">亜型</span>
            <custom-select
              name="亜型"
              id="blood-serovar"
              :value="getBloodSerovar()"
              :options="filteredOptionSerovar"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              class="blood-input-area"
              @change="setBloodSerovarData"
            />
            <custom-select v-if="isABBloodType()"
             id="blood-AB-for-B-type"
             :value="getBloodSerovarTypeBForABBlood()"
             :options="filteredOptionSerovarTypeBForABBlood"
             :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
             class="blood-input-area"
             @change="setBloodSerovarData"
            />
          </div>
        </div>
      </td>
    </tr>
    <tr>
<!--      mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start-->
      <td class="item-title">国籍</td>
<!--      <td class="item-data">-->
<!--        <custom-simple-textarea-a-->
<!--            :value="getPatData('nationality')"-->
<!--            :display-string="mstCdToName(mstSysCountry, getPatData('nationality').editValue, 'countryCdAlpha3', 'countryName')"-->
<!--            :disabled="true"-->
<!--            style="vertical-align: middle; color: #1f1f21;"-->
<!--        />-->
<!--      </td>-->
      <td class="item-data">
        <custom-simple-textarea-a
          ref="nationalityDisplay"
          class="nationality-textarea-field"
          :value="getPatData('nationality')"
          :display-string="mstCdToCountryName(
              mstSysCountry,
              getPatData('nationality').editValue,
              'countryCdAlpha3',
              'countryName')"
          :disabled="true"
          style="vertical-align: middle; color: #1f1f21;"
        />
      </td>
<!--      mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end-->
      <td class="item-data">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="btnSelectMst" -->
        <!--   class="common-style-select-button btn3-normal" -->
        <!--   :disabled="this.editFlag" -->
        <!--   @click="handleShowPopover()" -->
        <!-- > -->
        <common-master-selector
          :masterType="MasterType.NATIONALITY_PAT_INFO"
          :facilityCd="getFacilityCd"
          :initItem="{ value: getPatData('nationality') ? getPatData('nationality').initValue : null }"
          :editItem="{ value: getPatData('nationality') ? getPatData('nationality').editValue : null }"
          :btnName="'選択'"
          :isVisible="false"
          :btnClass="'common-style-select-button btn3-normal'"
          :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @popover-return="onNationalityReturn"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">
        郵便番号
        <span class="zip-hyphen">(ﾊｲﾌﾝなし)</span>
      </td>
      <td class="item-data">
        <custom-input
          ref="zip_cd"
          :value="patContactInfo('zip_cd')"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :validators="[]"
          type="tel"
          maxlength="7"
          form-name="郵便番号"
        />
      </td>
      <td class="item-data">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   class="common-style-select-button btn3-normal" -->
        <!--   :disabled="this.editFlag" -->
        <!--   @click=" -->
        <!--     showAddressSearchModal(setAddressValues); -->
        <!--     mapVisible = true; -->
        <!--   " -->
        <!-- > -->
        <ons-button
          class="common-style-select-button btn3-normal"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          @click="
            showAddressSearchModal(setAddressValues);
            mapVisible = true;
          "
        >

          住所検索
        </ons-button>
      </td>
    </tr>
    <tr>
      <td class="item-title">住所</td>
      <td colspan="2" class="item-data">
        <com-textarea
          ref="comTextareaAddress"
          :content="patContactInfo('address')"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          cssClass="textarea-custom-text-font textarea-resize-vertical"
          idTextarea="com-textarea-address"
          class="comTextarea"
          @set-content-data="setContentDataAddress"
        />
      </td>
    </tr>
    <!-- バリデーション未定義 -->
    <tr>
      <td class="item-title">電話番号</td>
      <td colspan="2" class="item-data">
        <custom-input
          ref="tel1"
          :value="patContactInfo('tel1')"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :validators="[]"
          type="tel"
          form-name="電話番号"
        />
      </td>
    </tr>
    <!-- バリデーション未定義 -->
    <tr>
      <td class="item-title">電話番号2</td>
      <td colspan="2" class="item-data">
        <custom-input
          ref="tel2"
          :value="patContactInfo('tel2')"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :validators="[]"
          type="tel"
          form-name="電話番号2"
        />
      </td>
    </tr>
    <!-- バリデーション未定義 -->
    <tr>
      <td class="item-title">FAX</td>
      <td colspan="2" class="item-data">
        <custom-input
          ref="fax"
          :value="patContactInfo('fax')"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :validators="[]"
          type="tel"
          form-name="FAX"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">Email</td>
      <td colspan="2" class="item-data">
        <custom-input
          ref="e_mail"
          :value="patContactInfo('e_mail')"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          :validators="[]"
          type="email"
          form-name="Email"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">勤務先名</td>
      <td colspan="2" class="item-data">
        <custom-simple-textarea-a
          :value="patContactInfo('work_name')"
          :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          style="vertical-align: middle;"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">勤務先電話番号</td>
      <td colspan="2" class="item-data">
        <custom-input
          ref="work_tel"
          :value="patContactInfo('work_tel')"
          :validators="[]"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          type="tel"
          form-name="勤務先電話番号"
          readonly="readonly"
          @focus="addFocusEvent($event)"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">メモ1</td>
      <td colspan="2" class="item-data">
        <com-textarea
          ref="comTextareaMemo1"
          :content="patContactInfo('memo1')"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          cssClass="textarea-custom-text-font textarea-resize-vertical"
          idTextarea="com-textarea-memo1"
          class="comTextarea"
          @set-content-data="setContentDataMemo1"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">メモ2</td>
      <td colspan="2" class="item-data">
        <com-textarea
          ref="comTextareaMemo2"
          :content="patContactInfo('memo2')"
          :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          cssClass="textarea-custom-text-font textarea-resize-vertical"
          idTextarea="com-textarea-memo2"
          class="comTextarea"
          @set-content-data="setContentDataMemo2"
        />
      </td>
    </tr>
  
    </tbody>
  </table>
    <v-ons-modal :visible="patCaptureVisible" :class="fontSizeSet">
      <div>
        <transition name="modal">
          <div class="modal-mask">
            <div class="modal-wrapper">
              <div class="modal-container modal-container-custom">
                <div class="modal-header">
                  <ons-toolbar style="background: #333333;">
                    <div class="left toolbar__title">
                      <span style="color: #fafafa">患者取込</span>
                    </div>
                    <div class="right">
                      <ons-toolbar-button class="close-btn print-none" @click="cancelPatCapture">
                        <ons-icon icon="fa-times" />
                      </ons-toolbar-button>
                    </div>
                  </ons-toolbar>
                </div>
                <div id="m-content" class="modal-body m-content">
                  <v-ons-row class="condition-row">
                    <v-ons-col style="text-align: left">
                      <label>
                        患者IDを入力し患者取込ボタンを押してください
                        <br/>
                        （半角カンマ(,)区切りで、複数患者を指定できます。）
                      </label>
                      <custom-input
                        :value="hostpatId"
                        :validators="[validateInputId]"
                      />
                    </v-ons-col>
                  </v-ons-row>
                  <hr style="border-color: #ececec">
                  <div class="condition-row" style="height:30px;margin-bottom:5px;margin-top:10px;">
                    <div class="cancelbtn" style="float:left;">
                      <v-ons-button class="clear custom-button btn2-cancel" @click="cancelPatCapture">キャンセル</v-ons-button>
                    </div>
                    <div style="float:right;" class="btnok">
                      <!-- mod #10359 編集権限の動作不正 dengshen start -->
                      <!-- <v-ons-button -->
                      <!--   class="common-style-ok-button custom-button btn1-execute" -->
                      <!--   @click="getInputId" -->
                      <!--   :disabled="checkEmpty || editFlag" -->
                      <!-- > -->
                      <v-ons-button
                        class="common-style-ok-button custom-button btn1-execute"
                        @click="getInputId"
                        :disabled="checkEmpty || !getItemAuthorized('PatInfo', 'default_authority')"
                      >

                        取込
                      </v-ons-button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </v-ons-modal>

</template>

<script>
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import {ApiHelper} from "@/apis/AxiosHelper";
  import {calculateAge} from "@/functions/PatInfoFunctions.js";
  import {
    PAT_PERSONAL_MAIN_COL_IN_OUT_VISIT_HISTORY_INFO_IN_OUT_CLASS,
    PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_MOVE_IN_OUT_DB
  } from "@/constants/PatInfo.js";
  import {EventBus} from "@/compat/vue/event-bus.js";
  import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
  import {sendRequestGetMstFacilityByCd} from "@/apis/facility";
  import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
  import {createJournal} from "@/apis/journal";
  import CommonTextArea from "@/components/common/CommonTextArea";
  import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
  import dayjs from "@/compat/date/dayjs";
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  import _ from "@/compat/collections/lodash";
  import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
  import * as MasterType from "@/components/common/master-selector/MasterType";
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
export default {
  name: 'BasicInfoCard',
  mixins: [baseCardContent, MasterMaintenanceMixin],
  components: {
    "com-textarea": CommonTextArea,
    "common-master-selector": commonMasterSelector
  },
  data() {
    return {
      // add FNSI-じょはく start
      inOutClassValue: null,
      optionsInOutClass: [
        { value: 3, displayValue: '－' },
        { value: 0, displayValue: '外来' },
        { value: 1, displayValue: '入院' }
      ],
      // mod No.20 じょはく start
      deathOptions: [
        { value: 2, displayValue: '死亡' }
      ],
      // mod No.20 じょはく end
      // add FNSI-じょはく end
      hostpatId : {
        editValue: null,
        initValue: null
      },
      patCaptureVisible: false,
      popoverDirection: "down",
      coopCd : "",
      MasterType,
      mstSysCountry: null,
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 liang start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 liang end
      // del #10359 編集権限の動作不正 dengshen end
      mapVisible: false,
      optionTypeAbo: [
        { value: 0, displayValue: "不明" },
        { value: 1, displayValue: "A型" },
        { value: 2, displayValue: "B型" },
        { value: 3, displayValue: "O型" },
        { value: 4, displayValue: "AB型" }
      ],
      optionTypeRh: [
        { value: 0, displayValue: "不明" },
        { value: 1, displayValue: "Rh+" },
        { value: 2, displayValue: "Rh-" }
      ],
      optionTypeSerovar: [
        { value: 0, displayValue: "不明" },
        { value: 11, displayValue: "A1" },
        { value: 12, displayValue: "Aint" },
        { value: 13, displayValue: "A2" },
        { value: 14, displayValue: "A3" },
        { value: 15, displayValue: "Ax" },
        { value: 16, displayValue: "Am" },
        { value: 17, displayValue: "Ael" },
        { value: 18, displayValue: "Aend" },
        { value: 21, displayValue: "B1" },
        { value: 22, displayValue: "Bint" },
        { value: 23, displayValue: "B2" },
        { value: 24, displayValue: "B3" },
        { value: 25, displayValue: "Bx" },
        { value: 26, displayValue: "Bm" },
        { value: 27, displayValue: "Bel" },
        { value: 28, displayValue: "Bend" },
        { value: 31, displayValue: "Oh" },
        { value: 32, displayValue: "Ah" },
        { value: 33, displayValue: "Bh" },
        { value: 34, displayValue: "Om" },
        { value: 35, displayValue: "Am" },
        { value: 36, displayValue: "Bm" }
      ],
      advancedSettings: {},
      // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 start
      clickTrue: false,
      // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 end
      selectPatInfoAddressEventName: null,

    };
  },

  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },

  computed: {
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getUserId","getStateUserAccountInfo","getUseFunctions"]),
    ...mapGetters("account-edit", ["getUserId","getStateUserAccountInfo","getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    ...mapGetters("user", ["getFacilityCd"]),
    // add 機能帳票パラメータ確認 黄 start
    // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関 start
    // ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-info", ["selectedPatId","selectedPat", "getIsOtherFacility", "getOtherFacilityCd"]),
    // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関  end
    // add 機能帳票パラメータ確認 黄 end
    /**
     * @description 亜型選択肢
     * @summary ABO型で絞り込み
     */
    checkEmpty() {
      if (this.hostpatId.editValue) {
        return false;
      }
      return true;
    },
    filteredOptionSerovar() {
      const value = this.getPatData("pat_blood_type_abo").editValue;

      if (value === 1 || value === 4) {
        // A型のみ表示
        return this.optionTypeSerovar.filter(
          // 不明とA1～Aendのみ表示
          option =>
            (option.value >= 11 && option.value <= 18) || option.value === 0
        );
      } else if (value === 2) {
        // B型のみ表示
        return this.optionTypeSerovar.filter(
          // 不明とB1～Bendのみ表示
          option =>
            (option.value >= 21 && option.value <= 28) || option.value === 0
        );
      } else if (value === 3) {
        // O型のみ表示
        return this.optionTypeSerovar.filter(
          // 不明とOh～Bmのみ表示
          option =>
            (option.value >= 31 && option.value <= 38) || option.value === 0
        );
      } else {
        return [
          this.optionTypeSerovar.find(
            // 不明のみ表示
            option => option.value === 0
          )
        ];
      }
    },
    filteredOptionSerovarTypeBForABBlood() {
      const value = this.getPatData("pat_blood_type_abo").editValue;

      if (value === 4) {
        // B型のみ表示
        return this.optionTypeSerovar.filter(
          // 不明とB1～Bendのみ表示
          option =>
            (option.value >= 21 && option.value <= 28) || option.value === 0
        );
      } else {
        return [
          this.optionTypeSerovar.find(
            // 不明のみ表示
            option => option.value === 0
          )
        ];
      }
    },
    /**
     * @description 誕生日から算出した年齢
     */
    age() {
      const birthday = this.getPatData("pat_birthday").editValue;
      // 仅新規患者登録：未选择生年月日时显示「不明」
      if (this.isCreationPat && (birthday == null || birthday === "")) {
        return "不明";
      }
      // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関 start
      // const age = this.calculateAge(birthday);
      // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関 start
      // const date = this.selectedPat.pat_personal_main["is_die"] == 1 ? dayjs(this.selectedPat.pat_personal_main["die_date"]).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD");
      const date = this.selectedPat === null ? dayjs(new Date()).format("YYYYMMDD") : this.selectedPat.pat_personal_main["is_die"] == 1 ? dayjs(this.selectedPat.pat_personal_main["die_date"]).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD");
      const age = this.calculateAge(birthday,date);
      // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関  end
      this.inOutClassValue = this.getPatData('in_out_class').initValue;
      // mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関  end
      // add by maxueqiang bug:5372
      // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      // return age > 0 ? age+" 歳" : "不明";
      return age >= 0 ? age+" 歳" : "不明";
      // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    },

    /**
     * @description 画面表示用入外
     * @summary DBの値を画面表示用値へ変換
     * @returns {String}
     */
    inOutClass() {
      const dbValue = this.getPatData("in_out_class").editValue;
      const inOutClassData = PAT_PERSONAL_MAIN_COL_IN_OUT_VISIT_HISTORY_INFO_IN_OUT_CLASS.find(
        inOutClass => inOutClass.value === dbValue
      );

      // TODO: 一時的に保留:DB値が不適切だったら不明を表示
      if (inOutClassData === undefined) {
        return "不明";
      }
      return inOutClassData.displayValue;
    },

    inOutCurrentState() {
      const dbValue = this.getPatData("in_out_current_state").editValue;
      const inOutClassData = PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_MOVE_IN_OUT_DB.find(
        inOutClass => inOutClass.value === dbValue
      );
      // TODO: 一時的に保留:DB値が不適切だったら不明を表示
      if (inOutClassData === undefined) {
        return "不明";
      }
      return inOutClassData.displayValue;
    },
    setAddressValues() {
      return {
        postalCode: this.patContactInfo('zip_cd').editValue,
        address: this.patContactInfo('address').editValue
      }
    },

    isShowPatientCapture() {
      if (!this.advancedSettings.func_advcds) return false;

      return this.advancedSettings.func_advcds.some(
        setting =>
          setting.func_advcd === ADVANCED_SETTINGS.PATIENT_CAPTURE_BUTTON
      );
    },
    /**
     * add by maxueqiang
     * after click the button will be not used
     */
    isEnAblePatCap(){
      return this.patCaptureVisible;
    }
  },

  // マスタ取得完了後にポップオーバーオブジェクトを作成
  watch: {
    mstSysCountry() {
      this.resizeNationalityTextarea();
    }
  },

  async created() {
    this.refreshData()
    let inOutInitValue = this.getPatData('in_out_class').initValue;
    this.inOutClassValue = inOutInitValue;
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$on("requestReportParams", this.requestrReportParams);
    if ( inOutInitValue === "" || inOutInitValue == null) {
      this.setPatData('in_out_class', 3);
      this.initRecord['in_out_class'] = {
        initValue: 3,
        editValue: 3
      };
      this.editRecord['in_out_class'] = {
        initValue: 3,
        editValue: 3
      };
    }
    if (this.isCreationPat) this.setPatData('nationality', "JPN");
    if (this.isCreationPat) this.setPatData('pat_blood_type_abo', 0);
    if (this.isCreationPat) this.setPatData('pat_blood_type_rh', 0);
    if (this.isCreationPat) this.setPatData('pat_blood_type_serovar', 0);
    this.selectPatInfoAddressEventName = this.isCreationPat ? "selectPatInfoAddressNew" : "selectPatInfoAddressChange";
    EventBus.$off(this.selectPatInfoAddressEventName, this.onSelectPatInfoAddress);
    EventBus.$on(this.selectPatInfoAddressEventName, this.onSelectPatInfoAddress);
    // 施設拡張
    await this.setAdvancedSettings();
  },
  // add 画面印刷プレビューと印刷の実現 黄 start
  beforeUnmount() {
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 start
    // EventBus.$off("selectPatInfoAddress");
    if (this.selectPatInfoAddressEventName) {
      EventBus.$off(this.selectPatInfoAddressEventName, this.onSelectPatInfoAddress);
    }
    // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 end

  },
  // add 画面印刷プレビューと印刷の実現 黄 end
  methods: {
    ...mapActions("multi-modal", ["showAddressSearchModal"]),
    //add FNSI-7767 劉全航 start
    ...mapActions("loading-screen", ["setLoadingScreenMessage","setLoadingScreenVisible"]),
    //add FNSI-7767 劉全航 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    onSelectPatInfoAddress(event) {
      if (!this.mapVisible) return;
      this.setPatDataJson("pat_contact_info", "address", event.address);
      this.setPatDataJson("pat_contact_info", "zip_cd", event.zipCd);
      this.mapVisible = false;
    },
    //bug:4274 add by maxueqiang
    addFocusEvent(event){
      let element = event.target;
      element.removeAttribute("readonly");
    },
    //bug:4274 add by maxueqiang end
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setPatDataBasicInfo(item, value) {
      this.setPatData(item, value);
      if (item === "nationality") {
        this.resizeNationalityTextarea();
      }
    },

    onNationalityReturn(ev) {
      this.setPatDataBasicInfo("nationality", ev && ev.value != null ? ev.value : null);
    },

    resizeNationalityTextarea() {
      this.$nextTick(() => {
        setTimeout(() => {
          const el = this.$refs.nationalityDisplay?.$el;
          if (!el) {
            return;
          }
          const peer = this.$refs.pat_last_name?.$el;
          el.style.setProperty("height", "0px", "important");
          let height = el.scrollHeight + 4;
          if (peer?.offsetHeight) {
            height = Math.max(height, peer.offsetHeight);
          }
          el.style.setProperty("height", `${height}px`, "important");
        }, 50);
      });
    },

    adjustCardTextareaHeights() {
      this.resizeNationalityTextarea();
      this.adjustComTextareaHeight("com-textarea-address", "comTextareaAddress");
      this.adjustComTextareaHeight("com-textarea-memo1", "comTextareaMemo1");
      this.adjustComTextareaHeight("com-textarea-memo2", "comTextareaMemo2");
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      const response = await ApiHelper.get("/mstInfo/sysCountry").catch(error => {
        this.setLoadingScreenVisible(false);
        getErrorMessage('BasicInfoCardContent.vue', 'created', error);
        throw new Error(
          `[BasicInfoCardContent.vue]created(): マスタ取得失敗
        エラー内容: ${error}`
        );
      });
      this.setLoadingScreenVisible(false);
      this.mstSysCountry = response.data;
      this.resizeNationalityTextarea();
    },
    // add bug #7125 修正 chen end

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    // add 画面印刷プレビューと印刷の実現 黄 start
    requestrReportParams(param) {
      // 機能コード判定
      //mod 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
      // if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
      if (param.substring(0, 3) === '007') {
        //mod 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
        // 機能一致
        // 印刷パラメータを応答
        //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
        var curDate = new Date();
        //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
        const param = {
          facilityCd: this.getFacilityCd,
          patId: this.selectedPatId,
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"00701",
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          reportOneFlag: "0",
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          fromDate: dayjs(Date.now()).format("YYYY/MM/DD"),
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //toDate: dayjs(new Date(curDate.getTime() + 6*24*60*60*1000)).format("YYYY/MM/DD"),
          toDate: dayjs(new Date(curDate.setMonth(curDate.getMonth() + 1))).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          date: dayjs(Date.now()).format("YYYYMMDD")
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 黄 end
    calculateAge,
    //add FNSI-画面部品デザイン じょはく start
    changeFlag() {
      this.inOutClassValue = 3;
    },
    // mod No.20 じょはく start
    addDeathItem() {
      this.setPatData('in_out_class', 2);
      this.inOutClassValue = 2;
    },
    // mod No.20 じょはく end
    //add FNSI-画面部品デザイン じょはく end
    cancelPatCapture() {
      this.hostpatId.editValue = null;
      this.patCaptureVisible = false;
    },
    patContactInfo(jsonKey) {
      return this.getPatDataJson("pat_contact_info", jsonKey);
    },

    showPatCapture() {
      this.patCaptureVisible = true;
    },
    splitListId() {
      const hospPatId = this.hostpatId.editValue;
      const id = hospPatId.split(",");
      return id;
    },
    validateInputId() {
      const hospPatId = this.hostpatId.editValue;
      const id = hospPatId.split(",");
      let rs = "";
      id.forEach(i => {
        if (this.validateID(i.trim())) {
          rs = "IDの形式が不正です。\n半角英数字のみ登録できます。";
        }
      });
      return rs;
    },
    async getInputId(){
      // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 start
      if(this.clickTrue == true) {
        return;
      }
      //add FNSI-7767 劉全航 start
      this.patCaptureVisible = false;
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
        //add FNSI-7767 劉全航 end
      if(this.clickTrue == false) {
        this.clickTrue = true
      }
      // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 end
      // mod 2021-03-25 患者取込の[IDの形式不正]のメッセージを追加 孫 start
      // if (!this.validateInputId()) {
      let validateResult = this.validateInputId();
      if (!validateResult) {
      // mod 2021-03-25 患者取込の[IDの形式不正]のメッセージを追加 孫 end
        const listId = this.splitListId();
        if (listId.length > 10) {
          this.$ons.notification
            .alert({
              title: "",
              message: "一括申込人数の上限（１０人）を超えています。"
            })
        } else {
          const successList = [];
          const failedList = [];
          let isNotFound = false;
          this.getPatData('pat_sex').initValue = parseInt(this.getPatData('pat_sex').initValue);
          this.getPatData('pat_sex').editValue = parseInt(this.getPatData('pat_sex').editValue);
          await Promise.all(listId.map(item => {
            const params = {
              facility_cd: this.getFacilityCd,
              coop_cd: "profile",
              coop_cd_index: "",
              crud: "C",
              direction: "S",
              ana_result: "0",
              coop_result: "0",
              pat_id: "",
              hosp_pat_id: item.trim(),
              ord_no: "",
              /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
              base_date: dayjs().format("YYYYMMDD"),
              ope_cd: "017001",
              /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
              user_id: this.getUserId
            }
            return createJournal(params).then(() => {
              successList.push(item.trim());
            }).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
              getErrorMessage('BasicInfoCardContent.vue', 'getInputId', error);
              //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
              if (error.response.status === 400) {
                failedList.push(item.trim());
              } else if (error.response.status === 404) {
                isNotFound = true;
              }
            })
          }))
          let message = "";
          if (isNotFound) {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // message = "当該機能が連携対象外施設";
            message = messageFormat(DIALOG_MESSAGES['00200114'].message);
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          } else {
            if (successList.length > 0) {
              // add FNSI-改修内容 複数患者さん取込の場合、入力と出力の順位を一値にする必要 dou start
              let newList = listId.filter(x => successList.some(y => y == x.trim()));
              // add FNSI-改修内容 複数患者さん取込の場合、入力と出力の順位を一値にする必要 dou end
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // message += `[${newList.join()}] をリクエストしました。<br> `;
              message += messageFormat(DIALOG_MESSAGES['00100016'].message, newList.join());
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            }
            if (failedList.length > 0) {
              // add FNSI-改修内容 複数患者さん取込の場合、入力と出力の順位を一値にする必要 dou start
              let newList = listId.filter(x => failedList.some(y => y == x.trim()));
              // add FNSI-改修内容 複数患者さん取込の場合、入力と出力の順位を一値にする必要 dou end
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // message += `[${newList.join()}] をリクエストしませんでした。`;
              message += messageFormat(DIALOG_MESSAGES['00200115'].message, newList.join());
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            }
          }
          //add FNSI-7767 劉全航 start
          this.setLoadingScreenVisible(false);
          //add FNSI-7767 劉全航 end
          this.$ons.notification.alert({
            title: "",
            message: message
          });
          this.cancelPatCapture();
        }
        // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 start
        this.clickTrue = false
        // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 end
      }
      // add 2021-03-25 患者取込の[IDの形式不正]のメッセージを追加 孫 start
      else {
        //add FNSI-7767 劉全航 start
        this.setLoadingScreenVisible(false);
        //add FNSI-7767 劉全航 end
        this.$ons.notification
          .alert({
            title: "",
            message: validateResult
          })
        // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 start
        this.clickTrue = false
        // add FNSI-redmine bug #3948[患者取込ボタンが何度も押せてしまう]を修正 江 end
      }
      // add 2021-03-25 患者取込の[IDの形式不正]のメッセージを追加 孫 end
    },

    /**
     * @description 院内IDを0詰め12桁にする
     */
    // paddingHospId(hospId) {
    //   if (hospId !== "") {
    //     const padHospId = hospId.padStart(12, "0");
    //     this.setPatData("hosp_pat_id", padHospId);
    //   }
    // },

    /**
     * @description 院内ID取得
     * @summary カード一覧画面が保存時の院内ID重複チェック用に呼び出す
     */
    getHospPatId() {
      return this.getPatData("hosp_pat_id").editValue;
    },

    // add FNSI-入外区分の入力方法を2種類(簡易/詳細)用意し、簡易入力 徐博 start
    getPatInOutClass() {
      return this.getPatData("in_out_class").editValue;
    },
    // add FNSI-入外区分の入力方法を2種類(簡易/詳細)用意し、簡易入力 徐博 end
    // add FutreNetWeb+SI課題管理No6016 趙 start
    getPatInOutClassInitValue() {
      return this.getPatData("in_out_class").initValue;
    },
    // add FutreNetWeb+SI課題管理No6016 趙 end
    /**
     * @description 新旧患者名取得
     * @summary カード一覧画面が保存時の同姓同名チェック用に呼び出す
     * @returns {Object}
     */
    getOldNewPatName() {
      const oldLastName = this.getPatData("pat_last_name").initValue;
      const oldFirstName = this.getPatData("pat_first_name").initValue;
      const newLastName = this.getPatData("pat_last_name").editValue;
      const newFirstName = this.getPatData("pat_first_name").editValue;
      const oldLastNameKana = this.getPatData("pat_last_name_kana").initValue;
      const oldFirstNameKana = this.getPatData("pat_first_name_kana").initValue;
      const newLastNameKana = this.getPatData("pat_last_name_kana").editValue;
      const newFirstNameKana = this.getPatData("pat_first_name_kana").editValue;
      const oldLastNameAlpha = this.getPatData("pat_last_name_alpha").initValue;
      const oldFirstNameAlpha = this.getPatData("pat_first_name_alpha")
        .initValue;
      const newLastNameAlpha = this.getPatData("pat_last_name_alpha").editValue;
      const newFirstNameAlpha = this.getPatData("pat_first_name_alpha")
        .editValue;

      return {
        oldLastName,
        oldFirstName,
        newLastName,
        newFirstName,
        oldLastNameKana,
        oldFirstNameKana,
        newLastNameKana,
        newFirstNameKana,
        oldLastNameAlpha,
        oldFirstNameAlpha,
        newLastNameAlpha,
        newFirstNameAlpha
      };
    },

    async setAdvancedSettings() {
      // 施設拡張設定を取得
      const responseFacility = await sendRequestGetMstFacilityByCd(
        this.getFacilityCd,
        this.selectedPatId
      )
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('BasicInfoCardContent.vue', 'setAdvancedSettings', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw error;
      });
      let advancedSettings = {};
      try {
        if (responseFacility.data.advancedSettings) {
          advancedSettings = JSON.parse(
            responseFacility.data.advancedSettings
          );
        }
      } catch {
        advancedSettings = {};
      }
      if (!advancedSettings.func_advcds) {
        advancedSettings.func_advcds = [];
      }
      this.advancedSettings = advancedSettings;
    },
    setContentDataAddress(e) {
     this.patContactInfo("address").editValue = e;
    },
    setContentDataMemo1(e) {
     this.patContactInfo("memo1").editValue = e;
    },
    setContentDataMemo2(e) {
     this.patContactInfo("memo2").editValue = e;
    },
    isABBloodType() {
      return this.getPatData("pat_blood_type_abo").editValue === 4;
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setBloodType() {
      this.setPatData('pat_blood_type_serovar', 0);
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    setBloodSerovarData() {
      if (this.isABBloodType()) {
        const bloodSerovarTypeA = getScopedElementById("blood-serovar", this.$el || this).value;
        const bloodSerovarTypeB = getScopedElementById("blood-AB-for-B-type", this.$el || this).value;
        const bloodSerovarTypeAInt = parseInt(bloodSerovarTypeA) % 10;
        const bloodSerovarTypeBInt = parseInt(bloodSerovarTypeB) % 10;
        this.setPatData('pat_blood_type_serovar', "4" + bloodSerovarTypeAInt + bloodSerovarTypeBInt);
      }
    },
    getBloodSerovar() {
      if (this.isABBloodType()) {
        const bloodSerOvarInit = this.getPatData('pat_blood_type_serovar').initValue;
        const bloodSerOvarEdit = this.getPatData('pat_blood_type_serovar').editValue;
        const bloodSerOvarABTypeAInitVal = bloodSerOvarInit !== null ? Math.floor((bloodSerOvarInit % 100) / 10) : 0;
        const bloodSerOvarABTypeAEditVal = bloodSerOvarEdit !== null ? Math.floor((bloodSerOvarEdit % 100) / 10) : 0;
        const bloodSerOvarABTypeAInit = bloodSerOvarABTypeAInitVal !== 0 ? "1" + bloodSerOvarABTypeAInitVal : "0";
        const bloodSerOvarABTypeAEdit = bloodSerOvarABTypeAEditVal !== 0 ? "1" + bloodSerOvarABTypeAEditVal : "0";
        return {
          initValue: bloodSerOvarABTypeAInit,
          editValue: bloodSerOvarABTypeAEdit
        }
      }
      return this.getPatData('pat_blood_type_serovar');
    },
    getBloodSerovarTypeBForABBlood() {
      const bloodSerOvarInit = this.getPatData('pat_blood_type_serovar').initValue;
      const bloodSerOvarEdit = this.getPatData('pat_blood_type_serovar').editValue;
      const bloodSerOvarABTypeBInitVal = bloodSerOvarInit !== null ? Math.floor((bloodSerOvarInit % 100) % 10) : 0;
      const bloodSerOvarABTypeBEditVal = bloodSerOvarEdit !== null ? Math.floor((bloodSerOvarEdit % 100) % 10) : 0;
      const bloodSerOvarABTypeBInit = bloodSerOvarABTypeBInitVal !== 0 ? "2" + bloodSerOvarABTypeBInitVal : "0";
      const bloodSerOvarABTypeBEdit = bloodSerOvarABTypeBEditVal !== 0 ? "2" + bloodSerOvarABTypeBEditVal : "0";
      return {
        initValue: bloodSerOvarABTypeBInit || null,
        editValue: bloodSerOvarABTypeBEdit || null
      }
    },
    // mod 患者名入力チェック不正について、対応する。 dengshen start
    // filterInput(e){
    //   e.target.value = e.target.value.replace(/[`~!@#$%^&*()_\-+=<>?:"{}|,./;'\\[\]·~！@#￥%……&*（）——\-+={}|《》？：“”【】、；‘’，。、]/g, '').replace(/\s/g, "");
    // },
    filterInput: _.debounce(function (e) {
      e.target.value = e.target.value.replace(/[`~!@#$%^&*()_+=<>?:"{}|,./;'\\[\]·~！@#￥%……&*（）——+={}|《》？：“”【】、；‘’，。、＃-]/g, '').replace(/\s/g, "");
    }),
    // mod 患者名入力チェック不正について、対応する。 dengshen end
    getInOutClass(){
      let inOutObj = this.getPatData('in_out_class');
      return inOutObj;
    }
  }
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
  @import "../../../assets/styles/modal.css";
  .zip-hyphen {
    font-size: 10px;
  }
  .blood-input-area {
    width: 5.0em;
    height: 2em;
    vertical-align: middle;
    display: flex;
    align-items: center;
  }
  .input-date :deep(.custom-input-date) {
    width: auto;
  }
  .cancelbtn :deep(.clear) {
    width: 110px;
  }
  .patient-capture {
    line-height: 17px;
  }
  .modal-container-custom {
    width: 40em;
    height: 14em;
  }
  /*** #9846 start */
  .font-size-set-small > .modal-wrapper > .font-size-set-small{
    height: 17em!important;
  }
  /*** #9846 end */
  .m-content {
    margin: 10px;
    width: calc(100% - 20px);;
    height: auto;
  }
  .idInputChange {
    flex: 1
  }
  .custom-button {
    font-size: 1em;
  }
  .item-data-blood{
    width: 100%;
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    padding: 2px;
  }
  .item-data-conponent{
    display: flex;
    align-items: center;
    flex-basis: 50%;
  }
  .custom-textarea-edited {
    border: 2px green solid;
  }
  .custom-textarea-required {
    background-color: #ffff99;
  }
  .custom-textarea-invalid {
    background-color: rgba(255, 0, 0, 0.5);
  }
  :deep(textarea.nationality-textarea-field) {
    height: auto !important;
    min-height: 2em;
  }
</style>
