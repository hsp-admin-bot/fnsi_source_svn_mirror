<!-- 保険情報 追加・編集モーダル -->
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div id="m-content" class="modal-body-content">
        <table>
          <tr>
            <td width="25%">保険区分</td>
            <td>
              <div class="radio-group">
                <custom-radio
                  :value="getDataFromJson(selectedJson,'insu_class')"
                  :radio-value="0"
                  name="insu_class"
                  @click="radioChange()"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >保険</custom-radio>
                <custom-radio
                  :value="getDataFromJson(selectedJson,'insu_class')"
                  :radio-value="1"
                  name="insu_class"
                  @click="radioChange()"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >公費</custom-radio>
                <custom-radio
                  :value="getDataFromJson(selectedJson,'insu_class')"
                  :radio-value="2"
                  name="insu_class"
                  @click="radioChange()"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >セット</custom-radio>
                <custom-radio
                  :value="getDataFromJson(selectedJson,'insu_class')"
                  :radio-value="3"
                  name="insu_class"
                  @click="radioChange()"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >自費</custom-radio>
              </div>
            </td>
          </tr>
        </table>

        <!-- 保険 (insu_class == 0) -->
        <div
          id="insurance-form"
          class="m-form"
          style="width: 99.9%;"
          v-if="getDataFromJson(selectedJson,'insu_class').editValue == 0"
        >
          <table class="card-table">
            <tr>
              <td>保険名</td>
              <td class="flex-area">
                <custom-input
                  id="hokenname"
                  :value="getInsuranceInfoJson('insu_info', 'insu_name')"
                  class="input-fix margin-input"
                  :is-required="true"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
                <div class="short-name-area">
                  <v-ons-button
                    ref="popoverButton"
                    class="common-style-select-button btn3-normal"
                    @click="showPopover"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  >検索</v-ons-button>
                  <span>略称</span>
                  <custom-input
                    :value="getInsuranceInfoJson('insu_info','insu_name_short')"
                    style="width: 70px"
                    maxlength="4"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  />
                </div>
              </td>
            </tr>
            <tr>
              <td>扶養区分</td>
              <td>
                <div class="radio-group">
                  <custom-radio
                    :value="getInsuranceInfoJson('insu_info', 'insu_kbn')"
                    radio-value="0"
                    name="insu_kbn"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  >被保険者</custom-radio>
                  <custom-radio
                    :value="getInsuranceInfoJson('insu_info', 'insu_kbn')"
                    radio-value="1"
                    name="insu_kbn"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  >被扶養者</custom-radio>
                </div>
              </td>
            </tr>
            <tr>
              <td>保険者番号</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_info', 'insu_no')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>保険者名称</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_info', 'insu_pat_name')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>被保険者記号</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_info', 'insu_pat_mark')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>被保険者番号</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_info', 'insu_pat_no')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td class="right">開始日</td>
              <td>
                <custom-input-date
                  :value="getInsuranceInfoJson('insu_info', 'start_date')"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td class="right">終了日</td>
              <td>
                <custom-input-date
                  :value="getInsuranceInfoJson('insu_info', 'end_date')"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td class="right">確認日</td>
              <td>
                <custom-input-date
                  :value="getInsuranceInfoJson('insu_info', 'check_date')"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
                <v-ons-button
                  class="common-style-select-button btn3-normal"
                  @click="onCheckDate"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >確認</v-ons-button>
              </td>
            </tr>
            <tr>
              <td>長期高額療養</td>
              <td>
                <div>
                  <div class="radio-group">
                    <custom-radio
                      :value="getInsuranceInfoJson('insu_info', 'cki_class')"
                      radio-value="0"
                      name="cki_class"
                      class="margin-radio"
                      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    >対象外</custom-radio>
                    <custom-radio
                      :value="getInsuranceInfoJson('insu_info', 'cki_class')"
                      radio-value="1"
                      name="cki_class"
                      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    >対象者</custom-radio>
                  </div>
                  <div class="radio-group">
                    <custom-radio
                      :value="getInsuranceInfoJson('insu_info', 'cki_class')"
                      radio-value="2"
                      name="cki_class"
                      class="margin-radio-right"
                      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    >1000円対象者</custom-radio>
                    <custom-radio
                      :value="getInsuranceInfoJson('insu_info', 'cki_class')"
                      radio-value="3"
                      name="cki_class"
                      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    >2000円対象者</custom-radio>
                  </div>
                </div>
              </td>
            </tr>
            <tr>
              <td style="white-space: normal;">高額受給者又は後期高齢者医療</td>
              <td>
                <div>
                  <div class="d-flex flex-row">
                    <div class="radio-group">
                      <custom-radio
                        :value="getInsuranceInfoJson('insu_info', 'kki_class')"
                        radio-value="0"
                        name="kki_class"
                        class="margin-radio"
                        :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                      >対象外</custom-radio>
                      <custom-radio
                        :value="getInsuranceInfoJson('insu_info', 'kki_class')"
                        radio-value="1"
                        name="kki_class"
                        :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                      >一般・低所得</custom-radio>
                    </div>
                  </div>
                  <div class="radio-group">
                    <custom-radio
                      :value="getInsuranceInfoJson('insu_info', 'kki_class')"
                      radio-value="2"
                      name="kki_class"
                      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    >7割給付</custom-radio>
                  </div>
                </div>
              </td>
            </tr>
            <tr>
              <td>6歳未満</td>
              <td>
                <div>
                  <div class="radio-group">
                    <custom-radio
                      :value="getInsuranceInfoJson('insu_info', 'und_six')"
                      radio-value="0"
                      name="und_six"
                      class="margin-radio"
                      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    >対象外</custom-radio>
                    <custom-radio
                      :value="getInsuranceInfoJson('insu_info', 'und_six')"
                      radio-value="1"
                      name="und_six"
                      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                    >対象</custom-radio>
                  </div>
                </div>
              </td>
            </tr>
            <tr>
              <td>負担率</td>
              <td>
                <div>
                  <label style="line-height: 2; vertical-align: bottom;">外来</label>
                  <custom-input-number
                    :digits="3"
                    :decimal-digits="0"
                    :max-value="100"
                    :min-value="0"
                    :value="getInsuranceInfoJson('insu_info', 'futan-g')"
                    style="width: 55px"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  />
                  <label style="line-height: 2; vertical-align: bottom;">入院</label>
                  <custom-input-number
                    :digits="3"
                    :decimal-digits="0"
                    :max-value="100"
                    :min-value="0"
                    :value="getInsuranceInfoJson('insu_info', 'futan-n')"
                    style="width: 55px"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  />
                </div>
              </td>
            </tr>
            <tr>
              <td>保険メモ１</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo1')"
                  idTextarea="com-textarea-insumemo1"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo1"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
              <td></td>
            </tr>
            <tr>
              <td>保険メモ２</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo2')"
                  idTextarea="com-textarea-insumemo2"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo2"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
          </table>
        </div>

        <!-- 公費 (insu_class == 1) -->
        <div
          id="public-form"
          class="m-form"
          v-if="getDataFromJson(selectedJson,'insu_class').editValue == 1"
        >
          <table class="card-table">
            <tr>
              <td>公費名</td>
              <td class="flex-area">
                <custom-input
                  id="publicexpenseName"
                  :value="getInsuranceInfoJson('insu_pub_info', 'insu_name')"
                  class="input-fix"
                  :is-required="true"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
                <div class="short-name-area">
                  <v-ons-button
                    ref="popoverButton"
                    class="common-style-select-button btn3-normal"
                    @click="showPopover"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  >検索</v-ons-button>
                  略称
                  <custom-input
                    :value="getInsuranceInfoJson('insu_pub_info','insu_name_short')"
                    style="width: 70px"
                    maxlength="4"
                    :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  />
                </div>
              </td>
            </tr>
            <tr>
              <td>負担者名</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_pub_info', 'insu_pub_name')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>負担者番号</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_pub_info', 'insu_pub_no')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>受給者番号</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_pub_info', 'insu_pub_pat_no')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>保険メモ１</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo1')"
                  idTextarea="com-textarea-insumemo1"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo1"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>保険メモ２</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo2')"
                  idTextarea="com-textarea-insumemo2"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo2"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>障害者手帳番号</td>
              <td>
                <custom-input
                  :value="getInsuranceInfoJson('insu_pub_info', 'passbook_no')"
                  class="input-fix"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td class="right">開始日</td>
              <td>
                <custom-input-date
                  :value="getInsuranceInfoJson('insu_pub_info', 'start_date')"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td class="right">終了日</td>
              <td>
                <custom-input-date
                  :value="getInsuranceInfoJson('insu_pub_info', 'end_date')"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td class="right">確認日</td>
              <td>
                <custom-input-date
                  :value="getInsuranceInfoJson('insu_pub_info', 'check_date')"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
                <v-ons-button
                  class="common-style-select-button btn3-normal"
                  @click="onCheckDate"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >確認</v-ons-button>
              </td>
            </tr>
          </table>
        </div>

        <!-- セット (insu_class == 2) -->
        <div
          id="set-form"
          class="m-form"
          v-if="getDataFromJson(selectedJson,'insu_class').editValue == 2"
        >
          <table class="card-table">
            <tr>
              <td>セット名</td>
              <td class="flex-area">
                <custom-input
                  id="setName"
                  :value="getInsuranceInfoJson('insu_set_info', 'insu_name')"
                  class="input-fix"
                  :is-required="true"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              <div class="short-name-area">
                略称
                <custom-input
                  :value="getInsuranceInfoJson('insu_set_info','insu_name_short')"
                  style="width: 70px"
                  maxlength="4"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </div>
              </td>
            </tr>
            <tr>
              <td>保険</td>
              <td>
                <insu-select
                  :value="getInsuranceInfoJson('insu_set_info', 'insu_cd')"
                  name="insu_cd"
                  style="width: 83%"
                  :json="selectedJson"
                  :options="getInsuListByInsuClass(0, getInsuranceInfoJson('insu_set_info', 'insu_cd').editValue)"
                  class="select-style common-style-input"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>公費1</td>
              <td>
                <insu-select
                  :value="getInsuranceInfoJson('insu_set_info', 'insu_pub1_cd')"
                  name="insu_pub1_cd"
                  style="width: 83%"
                  :json="selectedJson"
                  :options="getInsuListByInsuClass(1, getInsuranceInfoJson('insu_set_info', 'insu_pub1_cd').editValue)"
                  class="select-style common-style-input"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>公費2</td>
              <td>
                <insu-select
                  :value="getInsuranceInfoJson('insu_set_info', 'insu_pub2_cd')"
                  name="insu_pub2_cd"
                  style="width: 83%"
                  :json="selectedJson"
                  :options="getInsuListByInsuClass(1, getInsuranceInfoJson('insu_set_info', 'insu_pub2_cd').editValue)"
                  class="select-style common-style-input"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>公費3</td>
              <td>
                <insu-select
                  :value="getInsuranceInfoJson('insu_set_info', 'insu_pub3_cd')"
                  name="insu_pub3_cd"
                  style="width: 83%"
                  :json="selectedJson"
                  :options="getInsuListByInsuClass(1, getInsuranceInfoJson('insu_set_info', 'insu_pub3_cd').editValue)"
                  class="select-style common-style-input"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>公費4</td>
              <td>
                <insu-select
                  :value="getInsuranceInfoJson('insu_set_info', 'insu_pub4_cd')"
                  name="insu_pub4_cd"
                  style="width: 83%"
                  :json="selectedJson"
                  :options="getInsuListByInsuClass(1, getInsuranceInfoJson('insu_set_info', 'insu_pub4_cd').editValue)"
                  class="select-style common-style-input"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>保険メモ１</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo1')"
                  idTextarea="com-textarea-insumemo1"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo1"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>保険メモ２</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo2')"
                  idTextarea="com-textarea-insumemo2"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo2"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
          </table>
        </div>

        <!-- 自費 (insu_class == 3) -->
        <div
          id="self-form"
          class="m-form"
          v-if="getDataFromJson(selectedJson,'insu_class').editValue == 3"
        >
          <table class="card-table">
            <tr>
              <td>名称</td>
              <td>
                <custom-input
                  id="ownexpenseName"
                  :value="getInsuranceInfoJson('insu_self_info', 'insu_self_name')"
                  class="input-fix"
                  :is-required="true"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>保険メモ１</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo1')"
                  idTextarea="com-textarea-insumemo1"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo1"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
            <tr>
              <td>保険メモ２</td>
              <td>
                <com-textarea
                  :content="getDataFromJson(selectedJson, 'memo2')"
                  idTextarea="com-textarea-insumemo2"
                  class="input-fix"
                  @set-content-data="setContentDataInsuMemo2"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                />
              </td>
            </tr>
          </table>
        </div>

        <pop-over
          v-bind="popoverData"
          :target-position-element="$refs.popoverButton"
          @popover-close="closePopover"
          @popover-return="selectedInsurance"
        />
      </div>
    </template>

    <template #footer>
      <v-ons-row class="footer-row">
        <v-ons-col class="left">
          <v-ons-button
            class="btn-cancel common-style-cancel-button btn2-cancel"
            @click="cancel"
          >
            キャンセル
          </v-ons-button>
          <v-ons-button
            class="common-style-cancel-button btn-cancel btn4-alert"
            @click="deleteInsurance"
            v-show="!isCreate"
            :disabled="!isOwnFacility || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
          >削除</v-ons-button>
        </v-ons-col>
        <v-ons-col class="right">
          <v-ons-button
            class="btn-save common-style-ok-button btn1-execute"
            @click="save"
            :disabled="!isOwnFacility || !isChangedByValue || !getItemAuthorized('PatInfo', 'default_authority')"
          >
            保存
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </template>

    <!-- 排他エラー -->
    <message-dialog
      :visible.sync="isHaitaErrDialogVisible"
      :message-cd="22020006"
      type="1"
    />
  </modal-base>
</template>

<script>
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import CommonTextArea from "@/components/common/CommonTextArea";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import moment from "moment";
import { mapGetters, mapActions } from "vuex";
import insuSelect from "@/components/pat-info/insurance-info-card/custom-item/InsuSelect.vue";
import { decodeEditableRecord, extractChangesRecord } from '@/functions/PatInfoFunctions';
import { EventBus } from "@/eventBus.js";
import cloneDeep from "lodash/cloneDeep";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';

const JSON_EMPTY = {
  editValue: null,
  initValue: null
};

export default {
  name: "InsuranceInfoAddEditModal",
  components: {
    ModalBase,
    "message-dialog": messageDialog,
    "pop-over": MasterSelector,
    "insu-select": insuSelect,
    "com-textarea": CommonTextArea
  },
  mixins: [baseCardContent, MultiModalMixin, MasterMaintenanceMixin],
  
  props: {
    // 設定しない
    patRecord: {
      type: Object,
      default: null,
      required: false
    },
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    }
  },
  
  data() {
    return {
      cardDiff: true,
      originJson: null,
      isHaitaErrDialogVisible: false,
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "bottom",
        popoverTitleHeader: "保険選択",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "保険名",
        popoverContentDataset: [],
        popoverSearchQuery: "",
        popoverContentSelected: ""
      }
    };
  },

  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId", "isOwnFacility", "getIsOtherFacility", "getOtherFacilityCd"]),
    ...mapGetters("pat-insurance", [
      "insuranceList",
      "isCreate",
      "selectedInsuranceJson",
      "selectedInsuranceIndex",
      "mstInsurance",
      "popOverInsuranceInfo"
    ]),

    /** 編集対象の保険JSONオブジェクト */
    selectedJson() {
      return this.selectedInsuranceJson;
    },
    /** 選択行インデックス */
    selectedIndex() {
      return this.selectedInsuranceIndex;
    },
    /**
     * @description レコード編集フラグ
     */
    isChangedByValue() {
      if (!this.selectedJson) return false;
      
      // 負担率を数値に変換してモーダルに渡す。そうしないとモーダルの保存ボタン非活性判定が機能しない
      const cloneSelectedJson = cloneDeep(this.selectedJson);
      // 数値に正規化
      // 保険
      this.normalizeNumberFields(
        cloneSelectedJson.insu_info,
        ["futan-g", "futan-n"]
      );
      // セット
      this.normalizeNumberFields(
        cloneSelectedJson.insu_set_info,
        [
          "insu_cd",
          "insu_pub1_cd",
          "insu_pub2_cd",
          "insu_pub3_cd",
          "insu_pub4_cd"
        ]
      );
      const changedSelectJson = extractChangesRecord(cloneSelectedJson);
      const isChange = Object.values(changedSelectJson).find(data => data !== undefined);
      return isChange !== undefined;
    },
    tmpInsuClass() {
      if (this.selectedJson !== null) {
        return this.selectedJson.insu_class.editValue;
      }
      return "";
    },
    insuranceValue() {
      return this.getInsuranceInfoJson('insu_info', 'insu_name').editValue;
    }
  },
  
  created() {
    this.originJson = cloneDeep(this.selectedJson);
  },

  watch: {
    tmpInsuClass(value) {
      if (!this.mstInsurance) return;
      const filteredData = this.mstInsurance.filter(item => {
        return item.insuType === Number(value);
      });
      this.popoverData.popoverContentDataset = filteredData.map(item => {
        return { value: item.code, text: item.name };
      });
    },
    insuranceValue: {
      handler(editValue) {
        this.popoverData.popoverContentSelected =
          cloneDeep(this.popoverData.popoverContentDataset.find(
            value => value.text == editValue
          )) || { value: null, fnValue: {}, text: "" };
      },
      immediate: true
    }
  },
  
  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    ...mapActions("pat-insurance", ["setSelectedInsuranceJson", "setInsuranceList", "setReloadRequired", "setIsCreate"]),
    
    /** Jsonの指定項目を数値に正規化 */
    normalizeNumberFields(targetObject, keys) {
      keys.forEach(key => {
        const target = targetObject?.[key];
  
        if (!target) return;
  
        ["initValue", "editValue"].forEach(prop => {
          if (target[prop] != null) {
            target[prop] = Number(target[prop]);
          }
        });
      });
    },

    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },

    getDataFromJson(json, jsonKey) {
      if (!json) return JSON_EMPTY;
      return json[jsonKey];
    },

    getInsuranceInfoJson(jsonKey, key) {
      if (this.selectedJson) {
        const value = this.getDataFromJson(this.selectedJson[jsonKey], key);
        if (jsonKey === "insu_self_info" && key === "insu_self_name"
            && (!value.initValue || value.initValue === "")) {
          return this.selectedJson.insu_self_info.insu_self_name = {
            initValue: "自費",
            editValue: "自費"
          };
        }
        return value;
      }
      return JSON_EMPTY;
    },

    getInsuListByInsuClass(insuClass, insuranceCode) {
      const list = [];
      if (!this.popOverInsuranceInfo) return list;
      this.popOverInsuranceInfo.forEach(item => {
        if (!item.is_new && item.insu_class.editValue == insuClass
            && (item.is_del.initValue != "1" && item.is_disp.initValue != "0"
                || item.insurance_cd.initValue == insuranceCode)) {
          list.push({
            value: item.insurance_cd.initValue,
            displayValue: item.insu_name.initValue
          });
        }
      });
      return list;
    },

    radioChange() {
      let arr = document.getElementsByClassName("custom-input-required");
      for (let i = 0; i < arr.length; i++) {
        if (arr[i].classList.contains("custom-input-invalid")) {
          arr[i].classList.remove("custom-input-invalid");
        }
      }
    },

    onCheckDate() {
      this.setDataFromJson(
        this.insuranceList[this.selectedIndex],
        "check_date",
        moment().format("YYYYMMDD")
      );
    },

    showPopover() {
      EventBus.$emit("getInsuranceInfo", this.getInsuranceInfoJson('insu_info', 'insu_name'));
      this.popoverData.popoverVisible = true;
    },

    closePopover() {
      this.popoverData.popoverVisible = false;
    },

    selectedInsurance(data) {
      const selectedInsu = this.mstInsurance.find(e => e.code === data.value);
      const json = this.insuranceList[this.selectedIndex];
      if (selectedInsu) {
        this.setDataFromJson(json, "insu_name", selectedInsu.name);
        this.setDataFromJson(json, "insu_name_short", selectedInsu.insuNameShort);
        if (+json.insu_class.editValue == 0) {
          // 保険の場合
          let insuPatObj = this.getInsuranceInfoJson('insu_info', 'insu_pat_name');
          if (null == insuPatObj.editValue || undefined == insuPatObj.editValue) {
            this.setDataFromJson(json["insu_info"], "insu_pat_name", selectedInsu.name);
          }
          this.setDataFromJson(json["insu_info"], "futan-g", selectedInsu.futanG);
          this.setDataFromJson(json["insu_info"], "futan-n", selectedInsu.futanN);
        }
      } else {
        this.setDataFromJson(json["insu_info"], "insu_pat_name", null);
        this.setDataFromJson(json, "insu_name", null);
        this.setDataFromJson(json, "insu_name_short", null);
        if (+json.insu_class.editValue == 0) {
          this.setDataFromJson(json["insu_info"], "futan-g", null);
          this.setDataFromJson(json["insu_info"], "futan-n", null);
        }
      }
    },

    setDataFromJson(json, jsonKey, value) {
      if (!(jsonKey in json)) {
        throw new Error(
          `患者情報レコードのJSON配列要素{ ${Object.keys(json).join(", ")} }にキー[${jsonKey}]は存在しません。`
        );
      }
      switch (jsonKey) {
        case "check_date":
        case "insu_name":
          if (+json.insu_class.editValue == 0) json.insu_info[jsonKey].editValue = value;
          if (+json.insu_class.editValue == 1) json.insu_pub_info[jsonKey].editValue = value;
          break;
        case "insu_name_short":
          if (+json.insu_class.editValue == 0) json.insu_info[jsonKey].editValue = value;
          if (+json.insu_class.editValue == 1) json.insu_pub_info[jsonKey].editValue = value;
          if (+json.insu_class.editValue == 2) json.insu_set_info[jsonKey].editValue = value;
          break;
        default:
          json[jsonKey].editValue = value;
          break;
      }
    },

    setContentDataInsuMemo1(e) {
      this.getDataFromJson(this.selectedJson, 'memo1').editValue = e === '' ? null : e;
    },

    setContentDataInsuMemo2(e) {
      this.getDataFromJson(this.selectedJson, 'memo2').editValue = e === '' ? null : e;
    },

    /**
     * キャンセル
     */
    cancel() {
      if (!this.isChangedByValue) {
        this.closeModal();
        return;
      }

      this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[13000004].title,
        message: messageFormat(DIALOG_MESSAGES[13000004].message),
        callback: answer => {
          if (answer === 1) {
            const customInputRequired = document.getElementsByClassName("custom-input-required");
            for (let i = 0; i < customInputRequired.length; i++) {
              if (customInputRequired[i].classList.contains("custom-input-invalid")) {
                customInputRequired[i].classList.remove("custom-input-invalid");
              }
            }
            this.restoreOriginJson();
            this.closeModal();
          }
        }
      });
    },
    
    /**
     * キャンセル時、元の値に戻す
     */
    restoreOriginJson() {
      const restored = cloneDeep(this.originJson);
      const list = [...this.insuranceList];
      list[this.selectedIndex] = restored;
      this.setInsuranceList(list);
      this.setSelectedInsuranceJson(restored);
    },

    /**
     * モーダルを閉じ、新規追加の場合は末尾要素を削除する
     */
    closeModal() {
      if (this.isCreate) {
        const list = [...this.insuranceList];
        list.splice(-1);
        this.setInsuranceList(list);
      }
      this.hideModal();
    },

    async deleteInsurance() {
      const answer = await this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[13000111].title,
        message: messageFormat(DIALOG_MESSAGES[13000111].message),
      });
      if (answer === 1) {
        if (!this.selectedJson["is_new"]) {
          this.setDataFromJson(this.selectedJson, "is_disp", "0");
          this.setDataFromJson(this.selectedJson, "up_date", moment().format("YYYY-MM-DD HH:mm:ss"));
          const decodeJsonArray = decodeEditableRecord(this.selectedJson);
          
          this.setLoadingScreenVisible(true);
          try {
            await ApiHelper.put(
              `/patInfo/bulkUpdatePatInsu`,
              [decodeJsonArray]
            );

            this.setReloadRequired(true);
            
          } catch (e) {
            getErrorMessage('InsuranceInfoAddEditModal.vue', 'deleteInsurance', "保険情報削除に失敗しました。");
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES[12000191].title,
              message: messageFormat(DIALOG_MESSAGES[12000191].message)
            });
          } finally {
            this.setLoadingScreenVisible(false);
          }
        } else {
          // 新規追加レコードは物理削除
          const list = [...this.insuranceList];
          list.splice(this.selectedIndex, 1);
          this.setInsuranceList(list);
        }
        this.hideModal();
      }
    },

    /** 保存 */
    async save() {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      let step = 1;
      let isValidated = true;
      let variName = "保険名";
      const insuClass = parseInt(this.selectedJson.insu_class.editValue);
      let insuName = this.selectedJson.insu_info.insu_name.editValue;
      let title = "";
      let message = "";
      let startDate = this.selectedJson.insu_info.start_date.editValue;
      let endDate = this.selectedJson.insu_info.end_date.editValue;
      let checkDate = this.selectedJson.insu_info.check_date.editValue;
      let insuNameShort = this.selectedJson.insu_info.insu_name_short.editValue;
      
      // 入力チェック
      switch (insuClass) {
        case 1:
          variName = "公費名";
          insuName = this.selectedJson.insu_pub_info.insu_name.editValue;
          startDate = this.selectedJson.insu_pub_info.start_date.editValue;
          endDate = this.selectedJson.insu_pub_info.end_date.editValue;
          checkDate = this.selectedJson.insu_pub_info.check_date.editValue;
          insuNameShort = this.selectedJson.insu_pub_info.insu_name_short.editValue;
          this.selectedJson.insu_info["futan-g"].editValue = null;
          this.selectedJson.insu_info["futan-n"].editValue = null;
          if (startDate && endDate && endDate < startDate) {
            isValidated = false;
            title = DIALOG_MESSAGES["00200024"].title;
            message = DIALOG_MESSAGES["00200024"].message;
          }
          break;
        case 2:
          variName = "セット名";
          step = 2;
          insuName = this.selectedJson.insu_set_info.insu_name.editValue;
          insuNameShort = this.selectedJson.insu_set_info.insu_name_short.editValue;
          this.selectedJson.insu_info["futan-g"].editValue = null;
          this.selectedJson.insu_info["futan-n"].editValue = null;
          break;
        case 3:
          variName = "名称";
          insuName = this.selectedJson.insu_self_info.insu_self_name.editValue;
          this.selectedJson.insu_info["futan-g"].editValue = null;
          this.selectedJson.insu_info["futan-n"].editValue = null;
          break;
        default:
          variName = "保険名";
          if (startDate && endDate && endDate < startDate) {
            isValidated = false;
            title = DIALOG_MESSAGES["00200024"].title;
            message = DIALOG_MESSAGES["00200024"].message;
          }
          break;
      }

      if (insuName === null || insuName.trim() === "") {
        let arr = null;
        switch (insuClass) {
          case 1: arr = document.getElementById("publicexpenseName"); break;
          case 2: arr = document.getElementById("setName"); break;
          case 3: arr = document.getElementById("ownexpenseName"); break;
          default: arr = document.getElementById("hokenname"); break;
        }
        if (arr) arr.classList.add("custom-input-invalid");
        title = DIALOG_MESSAGES[12000194].title;
        message = messageFormat(DIALOG_MESSAGES[12000194].message, variName);
        isValidated = false;
      }

      this.selectedJson.insu_class.editValue = insuClass;
      this.selectedJson.insu_name.editValue = insuName;
      this.selectedJson.start_date.editValue = startDate;
      this.selectedJson.end_date.editValue = endDate;
      this.selectedJson.check_date.editValue = checkDate;
      this.selectedJson.insu_name_short.editValue = insuNameShort;
      // add FNSI-排他処理 劉
      this.selectedJson.old_up_date = this.selectedJson.up_date;

      if (isValidated) {
        this.selectedJson.is_selected.editValue = this.selectedJson.is_selected.initValue;
        const decodeJsonArray = decodeEditableRecord(this.selectedJson);
        const refinedInsuData = {
          ...decodeJsonArray,
          insu_name: decodeJsonArray.insu_name
            ? decodeJsonArray.insu_name.replace("【削除済みを含む】", "")
            : decodeJsonArray.insu_name
        };

        try {
          if (refinedInsuData.is_new) {
            // 追加
            delete refinedInsuData.is_new;
            await this.insertInsurane(refinedInsuData);
          } else {
            // 更新
            if (step === 2) {
              // セット
              refinedInsuData.is_del = "1";
              await this.updateInsurance(refinedInsuData);
              delete refinedInsuData.insurance_cd;
              refinedInsuData.is_del = "0";
              await this.insertInsurane(refinedInsuData);
            } else {
              // セット以外
              await this.updateInsurance(refinedInsuData);
            }
          }
          this.setReloadRequired(true);
          this.hideModal();
        } catch (e) {
          // updateInsurance / insertInsurane 内でハンドリング済み
        }
        this.setLoadingScreenVisible(false);
      } else {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({ title, message });
      }
    },

    async insertInsurane(decodeJsonArray) {
      await ApiHelper.post(`/patInfo/insertPatInsu`, decodeJsonArray)
        .catch(() => {
          getErrorMessage('InsuranceInfoAddEditModal.vue', 'insertInsurane', "保険作成を失敗しました。");
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000192].title,
            message: messageFormat(DIALOG_MESSAGES[12000192].message)
          });
        });
    },

    async updateInsurance(decodeJsonArray) {
      decodeJsonArray.up_date = moment().format("YYYY-MM-DD HH:mm:ss");
      await ApiHelper.put(`/patInfo/updatePatInsu`, decodeJsonArray)
        .catch(error => {
          getErrorMessage('InsuranceInfoAddEditModal.vue', 'updateInsurance', "保険変更を失敗しました。");
          this.setLoadingScreenVisible(false);
          if (error.response.data == '22020006') {
            this.isHaitaErrDialogVisible = true;
            throw new Error("保険変更を失敗しました。");
          }
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000193].title,
            message: messageFormat(DIALOG_MESSAGES[12000193].message)
          });
          throw error;
        });
    }
  },

  beforeDestroy() {
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style lang="scss" scoped>
.modal-body-content {
  margin: 10px;
  width: calc(100% - 20px);
}
.right {
  text-align: right !important;
}
.flex-area {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px; /* 要素間の余白 */
}
.flex-area .input-fix {
  flex: 1 1 200px;
  min-width: 0;
}
.short-name-area {
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  flex-shrink: 0;
}
.radio-group {
  display: flex;
  flex-wrap: wrap;
  gap: 0px 5px;
}
.m-form table {
  border-collapse: collapse;
  border: 1px solid #a9a9a9;
  width: 100%;
  tr {
    height: 35px;
  }
  td {
    padding: 0.25em 0.15em;
    border-bottom: 1px solid #a9a9a9;
    text-align: left;
  }
  td:first-child {
    white-space: nowrap;
    width: 20%;
  }
  ons-row {
    line-height: 30px;
  }
}
.footer-row {
  width: 100%;
  padding: 10px;
  .left {
    text-align: left;
  }
  .right {
    text-align: right;
  }
}
.btn-cancel {
  margin-right: 0.5em;
}
.custom-label {
  width: 110px;
  display: inline-block;
  margin-right: 10px;
}
.label-input-date {
  line-height: 30px;
  text-align: right;
}
.margin-radio {
  margin-right: 71px;
}
.margin-radio-right {
  margin-right: 22px;
}
.line-height-radio {
  line-height: 30px;
}
@media screen and (max-width: 480px) {
  .btn4-alert {
    width: 80px;
  }
  .btn-save {
    width: 80px;
  }
}
</style>
