/* 指示履歴 */

<template>
  <modal-base @onClose="hideModal">
        <template #search-area>
<div class="not-height-auto">
      <v-card>
        <div class='dialog-header-item'>
          <v-ons-row class="condition-search-row">
            <v-ons-col class='condition-search-col'>
              <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showSearchPopover($event)'/>
            </v-ons-col>
          </v-ons-row>
        </div>
        <v-ons-popover
          :target="searchPopoverTarget"
          :visible="searchPopoverVisible"
          :class="[fontSizeSet, 'popover-style']"
          direction="down"
          cancelable
          @preshow="popoverPreShow"
          @postshow="popoverPostShow"
          @posthide="closeSearchPopover(); popoverPosthide($event)"
        >
          <v-ons-row class="popover-content-style">
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                発行日
              </v-ons-col>
              <v-ons-col>
                <v-ons-row>
                  <v-ons-col>
                    <!-- mod FNSI-障害票一覧_指示履歴#1。 周 start -->
                    <!-- <input
                      class="ntss-input-date"
                      v-model="condition.inProgress.logDateStart"
                      type="date"
                      onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                    /> -->
                    <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start -->
                    <!-- <input
                      class="ntss-input-date"
                      v-model="condition.inProgress.logDateStart"
                      type="date"
                      min='1880-01-01'
                      max='2099-12-31'
                      v-rules="'date_format:yyyy-MM-dd'"
                      onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                    /> -->
                    <div class="d-flex flex-column">
                      <div class="flex-align-center">
                        <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                        <!-- <input
                          class="ntss-input-date"
                          id="logDateStart"
                          name="logDateStart"
                          type="date"
                          min='1880-01-01'
                          max='2099-12-31'
                          v-model="condition.inProgress.logDateStart"
                          data-validation-scope="inProgressLogDateStart"
                          v-rules="'required|date_format:yyyy-MM-dd'"
                        /> -->
                        <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                        <!-- <input
                          class="ntss-input-date start-date"
                          id="logDateStart"
                          name="logDateStart"
                          type="date"
                          min='1880-01-01'
                          max='2099-12-31'
                          v-model="condition.inProgress.logDateStart"
                          data-validation-scope="inProgressLogDateStart"
                          v-rules="'required|date_format:yyyy-MM-dd'"
                          @keyup="showStartMsg"
                          @blur="getStartDate"
                        /> -->
                        <date-input
                          :classes="'ntss-input-date start-date'"
                          id="logDateStart"
                          name="logDateStart"
                          min='1880-01-01'
                          max='2099-12-31'
                          v-model="condition.inProgress.logDateStart"
                          @handleClearInput="condition.inProgress.logDateStart = null; showErrorStartDate = false;"
                          data-validation-scope="inProgressLogDateStart"
                          @keyup="showStartMsg"
                          @blur="getStartDate"
                        />
                        <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                         <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                    <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end -->
                    <!-- mod FNSI-障害票一覧_指示履歴#1。 周 end -->
                       <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                       <!-- <custom-calendar v-model="condition.inProgress.logDateStart" /> -->
                       <custom-calendar v-model="condition.inProgress.logDateStart" class="start-date-comment" />
                       <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                       <label>&nbsp;〜</label>
                    <!-- add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start -->
                      </div>
                      <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                      <!-- <span class="error-message">{{
                        getValidationError("inProgressLogDateStart.logDateStart")
                      }}</span> -->
                      <span class="error-message" v-if="showErrorStartDate">{{
                        getValidationError("inProgressLogDateStart.logDateStart")||this.msgDiaLog
                      }}</span>
                       <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                    </div>
                    <!-- add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end -->
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
              </v-ons-col>
              <v-ons-col>
                <v-ons-row>
                  <v-ons-col>
                    <!-- mod FNSI-障害票一覧_指示履歴#1。 周 start -->
                    <!-- <input
                      class="ntss-input-date"
                      v-model="condition.inProgress.logDateEnd"
                      type="date"
                      onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                    /> -->
                    <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start -->
                    <!-- <input
                      class="ntss-input-date"
                      v-model="condition.inProgress.logDateEnd"
                      type="date"
                      min='1880-01-01'
                      max='2099-12-31'
                      v-rules="'date_format:yyyy-MM-dd'"
                      onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                    /> -->
                    <div class="d-flex flex-column">
                      <div class="flex-align-center">
                        <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                        <!-- <input
                          class="ntss-input-date"
                          id="logDateEnd"
                          name="logDateEnd"
                          type="date"
                          min='1880-01-01'
                          max='2099-12-31'
                          v-model="condition.inProgress.logDateEnd"
                          data-validation-scope="inProgressLogDateEnd"
                          v-rules="'required|date_format:yyyy-MM-dd'"
                        /> -->
                        <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                        <!-- <input
                          class="ntss-input-date end-date"
                          id="logDateEnd"
                          name="logDateEnd"
                          type="date"
                          min='1880-01-01'
                          max='2099-12-31'
                          v-model="condition.inProgress.logDateEnd"
                          data-validation-scope="inProgressLogDateEnd"
                          v-rules="'required|date_format:yyyy-MM-dd'"
                          @keyup="showEndMsg"
                          @blur="getEndDate"
                        /> -->
                        <date-input
                          :classes="'ntss-input-date end-date'"
                          id="logDateEnd"
                          name="logDateEnd"
                          min='1880-01-01'
                          max='2099-12-31'
                          v-model="condition.inProgress.logDateEnd"
                          @handleClearInput="condition.inProgress.logDateEnd = null; showErrorEndDate = false;"
                          data-validation-scope="inProgressLogDateEnd"
                          @keyup="showEndMsg"
                          @blur="getEndDate"
                        />
                        <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                        <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                    <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end -->
                    <!-- mod FNSI-障害票一覧_指示履歴#1。 周 end -->
                        <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                        <!-- <custom-calendar v-model="condition.inProgress.logDateEnd" /> -->
                        <custom-calendar v-model="condition.inProgress.logDateEnd" />
                        <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                    <!-- add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start -->
                      </div>
                      <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                      <!-- <span class="error-message">{{
                        getValidationError("inProgressLogDateEnd.logDateEnd")
                      }}</span> -->
                      <span class="error-message" v-if="showErrorEndDate">{{
                        getValidationError("inProgressLogDateEnd.logDateEnd")|| this.msgDiaLog
                    }}</span>
                      <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                    </div>
                    <!-- add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end -->
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                治療日
              </v-ons-col>
              <v-ons-col>
                <!-- mod FNSI-障害票一覧_指示履歴#1。 周 start -->
                <!-- <input
                  class="ntss-input-date"
                  v-model="condition.inProgress.treatmentStartDate"
                  type="date"
                  onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                /> -->
                <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start -->
                <!-- <input
                  class="ntss-input-date"
                  v-model="condition.inProgress.treatmentStartDate"
                  type="date"
                  min='1880-01-01'
                  max='2099-12-31'
                  v-rules="'date_format:yyyy-MM-dd'"
                  onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                /> -->
                <div class="d-flex flex-column">
                  <div class="flex-align-center">
                    <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                    <!-- <input
                      class="ntss-input-date"
                      id="treatmentStartDate"
                      name="treatmentStartDate"
                      type="date"
                      min='1880-01-01'
                      max='2099-12-31'
                      v-model="condition.inProgress.treatmentStartDate"
                      data-validation-scope="inProgressTreatmentStartDate"
                      v-rules="'required|date_format:yyyy-MM-dd'"
                    /> -->
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                    <!-- <input
                      class="ntss-input-date treatment-date"
                      id="treatmentStartDate"
                      name="treatmentStartDate"
                      type="date"
                      min='1880-01-01'
                      max='2099-12-31'
                      v-model="condition.inProgress.treatmentStartDate"
                      data-validation-scope="inProgressTreatmentStartDate"
                      v-rules="'required|date_format:yyyy-MM-dd'"
                      @keyup="showtreatmentMsg"
                      @blur="gettreatmentDate"
                    /> -->
                    <date-input
                      :classes="'ntss-input-date treatment-date'"
                      id="treatmentStartDate"
                      name="treatmentStartDate"
                      min='1880-01-01'
                      max='2099-12-31'
                      v-model="condition.inProgress.treatmentStartDate"
                      @handleClearInput="condition.inProgress.treatmentStartDate = null; showErrortreatmentDate = false;"
                      data-validation-scope="inProgressTreatmentStartDate"
                      @keyup="showtreatmentMsg"
                      @blur="gettreatmentDate"
                    />
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                    <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end -->
                <!-- mod FNSI-障害票一覧_指示履歴#1。 周 end -->
                    <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                    <custom-calendar v-model="condition.inProgress.treatmentStartDate" />
                    <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                <!-- add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start -->
                  </div>
                  <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
                  <!-- <span class="error-message">{{
                    getValidationError("inProgressTreatmentStartDate.treatmentStartDate")
                  }}</span> -->
                  <span class="error-message" v-if="showErrortreatmentDate">{{
                    getValidationError("inProgressTreatmentStartDate.treatmentStartDate")|| this.msgDiaLog
                  }}</span>
                  <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
                </div>
                <!-- add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end -->
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                治療方法
              </v-ons-col>
              <v-ons-col>
                <v-ons-select
                  v-model="condition.inProgress.treatmentMethod"
                  class="select-style"
                  name="treatmentMethodSelect"
                >
                  <option
                    v-for="treatment in treatmentMethodOptions"
                    :key="treatment.treatmentCd"
                    :value="treatment.treatmentName"
                  >
                    {{ treatment.treatmentName }}
                  </option>
                </v-ons-select>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                クール
              </v-ons-col>
              <v-ons-col>
                <v-ons-select
                  v-model="condition.inProgress.treatmentCourse"
                  class="select-style"
                  name="treatmentCourseSelect"
                >
                  <option
                    v-for="course in treatmentCourseOptions"
                    :key="course.kurCd"
                    :value="course.kurName"
                  >
                    {{ course.kurName }}
                  </option>
                </v-ons-select>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                対象
              </v-ons-col>
              <v-ons-col>
                <v-ons-select
                  v-model="condition.inProgress.logTarget"
                  class="select-style"
                  name="logTargetSelect"
                >
                  <option
                    v-for="target in logTargetOptions"
                    :key="target.id"
                    :value="target.name"
                  >
                    {{ target.name }}
                  </option>
                </v-ons-select>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                指示者
              </v-ons-col>
              <v-ons-col>
                <v-ons-select
                  v-model="condition.inProgress.createdUserId"
                  class="select-style"
                  name="createdBySelect"
                >
                  <option
                    v-for="create in createdByOptions"
                    :key="create.id"
                    :value="create.userId"
                  >
                    {{ create.userName }}
                  </option>
                </v-ons-select>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                更新者
              </v-ons-col>
              <v-ons-col>
                <v-ons-select
                  v-model="condition.inProgress.updatedUserId"
                  class="select-style"
                  name="updatedBySelect"
                >
                  <option
                    v-for="update in updatedByOptions"
                    :key="update.id"
                    :value="update.userId"
                  >
                    {{ update.userName }}
                  </option>
                </v-ons-select>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row style="height: unset">
              <v-ons-col width="27%" class="hist-search-col">
                フリーワード
              </v-ons-col>
              <v-ons-col>
                <input
                  v-model="condition.inProgress.searchQuery"
                  class="search-style"
                  type="search"
                />
              </v-ons-col>
            </v-ons-row>
          </v-ons-row>
          <v-ons-row class="popover-footer-style" style="height: unset">
            <v-ons-col>
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
              <!-- <v-ons-button
                class="common-style-cancel-button button-cancel"
                @click="clearSearchOptions"
              >
                クリア
              </v-ons-button> -->
              <v-ons-button
                class="common-style-cancel-button button-cancel btn2-cancel width"
                @click="clearSearchOptions"
              >
                クリア
              </v-ons-button>
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
            </v-ons-col>
            <v-ons-col>
              <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start -->
              <!-- <v-ons-button
                class="common-style-ok-button button-confirm"
                @click="searchFields"
              >
                OK
              </v-ons-button> -->
              <!-- mod FNSI-横展開-日付検索メッセージ 関 start -->
              <!-- <v-ons-button
                class="common-style-ok-button button-confirm"
                @click="searchFields"
                :disabled="!canSave"
              >
                OK
              </v-ons-button> -->
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
              <!-- <v-ons-button
                class="common-style-ok-button button-confirm"
                @click="searchFields"
                :disabled="showErrorEndDate || showErrorStartDate || showErrortreatmentDate"
              >
                OK
              </v-ons-button> -->
              <v-ons-button
                class="common-style-ok-button button-confirm btn3-normal width"
                @click="searchFields"
                :disabled="showErrorEndDate || showErrorStartDate || showErrortreatmentDate"
              >
                OK
              </v-ons-button>
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
              <!-- mod FNSI-横展開-日付検索メッセージ 関 end -->
              <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end -->
            </v-ons-col>
          </v-ons-row>
        </v-ons-popover>
      </v-card>
    </div>
    </template>
        <template #body>
<div class="modal-container-custom" id="modal-indHistory">
      <!-- mod FNSI-FutreNetWeb+SI課題管理No.5635 李 start -->
      <div class="modal-contents master-maintenance-page">
        <v-ons-row>
          <!-- mod 6458 2023-3-17 指示履歴の発行日の情報が正しく表示されない時がある。張 start -->
               <!-- <kendo-grid
            ref="grid"
            :data-source="gridData"
            :columns="gridColumns"
            :sortable="true"
            :resizable="true"
            :reorderable="true"
            :columnReorder ="setColumns"
            :columnResize ="setResize"
            :scrollable-endless="true"
            :pageable-numeric="false"
            :pageable-previous-next="false"
            :pageable-messages-empty="pageableMessageEmpty"
            :height="gridHeightValue"
            @sort="sortGrid"
            :mobile="true"
          /> -->
          <kendo-grid
            ref="grid"
            :data-source="gridData"
            :columns="gridColumns"
            :sortable="true"
            :resizable="true"
            :reorderable="true"
            :columnReorder ="setColumns"
            :columnResize ="setResize"
            :scrollable-endless="true"
            :pageable-numeric="false"
            :pageable-previous-next="false"
            :pageable-messages-empty="pageableMessageEmpty"
            :height="gridHeightValue"
          />
            <!-- mod 6458 2023-3-17 指示履歴の発行日の情報が正しく表示されない時がある。張 end -->
        </v-ons-row>
      </div>
      <!-- <div class="modal-contents">
        <v-ons-row>
          <kendo-grid
            ref="grid"
            :data-source="gridData"
            :columns="gridColumns"
            :sortable="true"
            :resizable="true"
            :reorderable="true"
            :columnReorder ="setColumns"
            :columnResize ="setResize"
            :scrollable-endless="true"
            :pageable-numeric="false"
            :pageable-previous-next="false"
            :pageable-messages-empty="pageableMessageEmpty"
            @sort="sortGrid"
            :height="gridHeightValue"
            :mobile="true"
          />
        </v-ons-row>
      </div> -->
      <!-- mod FNSI-FutreNetWeb+SI課題管理No.5635 李 end -->
      <!-- add FNSI-障害票一覧_指示履歴#1。 周 start -->
      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
        />
      </div>
      <!-- add FNSI-障害票一覧_指示履歴#1。 周 end -->
    </div>
    </template>
        <template #footer>
<div class="modal-footer-custom">
      <v-ons-row>
        <v-ons-col>
          <v-ons-button class="btn2-cancel width-padding" @click="hideModal">
            閉じる
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
    </template>
  </modal-base>
</template>

<script>
// mod FNSI-横展開-日付検索条件 関 start
import { mapGetters, mapActions } from "@/compat/vue/vuex";
// mod FNSI-横展開-日付検索条件 関 end
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { treatment } from "@/functions/mst/MstGetters.js";
import dayjs from "@/compat/date/dayjs";
import { createDataSource, readKendoDataSource, setKendoProgress } from "@/functions/common/KendoFunctions";
import ModalBase from "@/components/modals/ModalBase";
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
// add FNSI-障害票一覧_指示履歴#1。 周 start
import messageDialog from "@/components/common/message-dialog/MessageDialog";
// add FNSI-障害票一覧_指示履歴#1。 周 end
import commonSearchArea from "@/components/common/CommonSearchArea";
import elementResizeDetectorMaker from "@/compat/resize/element-resize-detector";
import { mstPatViewerLayoutDefine } from "@/constants/mstPatViewerLayoutDefine";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { sendRequestGetMstFacilitySettingData as getMstFacitilySettingData } from "@/apis/mst-facility-setting-maintenance";
// mod FNSI-横展開-日付検索メッセージ 関 start
 import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// mod FNSI-横展開-日付検索メッセージ 関 end
import {
  INDICATION_RECEIVE_1,
  INDICATION_RECEIVE_2,
  INDICATION_APPROVE_1,
  INDICATION_APPROVE_2,
  INDICATION_RECEIVE_APPROVE_UNIT
} from "@/constants/facilitySetting";
const erd = elementResizeDetectorMaker({
  strategy: "scroll"
});
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
import { getScopedElementById, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end
import { queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
export default {
  components: {
    "custom-calendar": CustomCalendar,
    // add FNSI-障害票一覧_指示履歴#1。 周 start
    "message-dialog": messageDialog,
    // add FNSI-障害票一覧_指示履歴#1。 周 end
    ModalBase,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },

  mixins: [MultiModalMixin, PopoverMixin],

  data() {
    const defaultCondition = {
      // 検査日FROM-TO
      logDateStart: "",
      logDateEnd: "",
      // 治療日
      treatmentStartDate: "",
      // 治療方法
      treatmentMethod: "",
      treatmentCourse: "",
      logTarget: "",
      // 作成／更新
      createdBy: null,
      updatedBy: null,
      createdUserId: "",
      updatedUserId: "",
      // フリーワード
      searchQuery: ""
    };
    return {
      // mod FNSI-横展開-日付検索メッセージ 関 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      showErrorEndDate: false,
      showErrortreatmentDate: false,
      // mod FNSI-横展開-日付検索メッセージ 関 end
      mstUser: null,
      gridColumns: [],
      saveGridColumns: [],
      pageableMessageEmpty: "データがありません",
      gridData: [],
      searchPopoverVisible: false,
      searchPopoverTarget: null,
      // add FNSI-障害票一覧_指示履歴#1。 周 start
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: "1",
        stringParams: [""]
      },
      // add FNSI-障害票一覧_指示履歴#1。 周 end
      condition: {
        // 入力中の検索条件
        inProgress: {
          ...defaultCondition
        },
        // 実際に検索に使用される条件
        inUsed: {
          ...defaultCondition
        }
      },
      treatmentMethodOptions: [],
      treatmentCourseOptions: [],
      logTargetOptions: [],
      createdByOptions: [],
      updatedByOptions: [],
      gridHeight: 0,
      columnStatus: {},
      indicationUnit: false,
      FACILITY_TYPES: {
        TREATMENT_UNIT: 1,
        INDICATION_UNIT: 2
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
      scroll: null,
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // mod FNSI-横展開-日付検索条件 関 start
     ...mapGetters("pat-viewer",["getCondition"]),
    // mod FNSI-横展開-日付検索条件 関 end
    // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start
    /**
     * OKボタンがクリックできるかどうか.
     */
    canSave() {
      return this.validationErrors.length === 0;
    },
    // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end
    gridHeightValue() {
      return this.gridHeight;
    },
  },

  async mounted() {
    this.mstUser = await this.getUser();
    this.updateGridData();
    erd.listenTo(this.$el, () => {
      this.relayoutGrid();
    });
    this.$nextTick(async () => {
      (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize", this.onResize);
    });
    const scopedWindow = this.$el?.ownerDocument?.defaultView || window;
    scopedWindow.addEventListener("beforeprint", this.handleBeforePrint);
    scopedWindow.addEventListener("afterprint", this.handleAfterPrint);
  },

  methods: {
    getScopedElementByIdSafe(id) {
      return getScopedElementById(id, this.$el || null);
    },
    getScopedClassElementSafe(className) {
      return getScopedElementsByClassName(className, this.$el || null)[0] || null;
    },
    getGridRef() {
      return this.$refs.grid || null;
    },
    getGridWidget() {
      return this.getGridRef()?.gridWidget?.() || this.getGridRef()?.kendoWidget?.() || null;
    },
    getGridElement() {
      return this.getGridRef()?.gridElement?.() || this.getGridWidget()?.element || null;
    },
    relayoutGrid() {
      return this.getGridRef()?.requestGridResize?.()
        || this.getGridWidget()?.resize?.()
        || this.getGridRef()?.refreshGrid?.()
        || this.getGridWidget()?.refresh?.()
        || null;
    },
    getGridContentElement() {
      return this.$refs.grid?.gridContentEl?.() || this.$el.querySelector('.k-grid-content');
    },
    // mod FNSI-横展開-日付検索条件 関 start
    ...mapActions("pat-viewer",["setCondition"]),
    // mod FNSI-横展開-日付検索条件 関 end
    /**
     * @description テーブル内容を取得関数
     *              ★ kendoの既定リクエストAPIはjQueryである
     */
    ...mapGetters("user",{
      getMstPersonalUser:"getMstPersonalUser"
    }),
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 画面印刷前処理
     * 印刷時、全列の幅を収める。列移動可能なため、移動後の位置を取得して動的にスタイル生成
     */
    handleBeforePrint() {
      const grid = this.getGridWidget();
      if (!grid?.columns) return;

      const visibleColumns = grid.columns.filter(col => !col.hidden);
      const styleMap = {
        logDate: { minWidth: "6.4em", width: "13%" },
        treatmentStartDate: { minWidth: "6.4em", width: "7%" },
        treatmentEndDate: { minWidth: "6.4em", width: "7%" },
        treatmentWeekday: { minWidth: "5.7em", width: "7%" },
        treatmentMethod: { minWidth: "4em", width: "8%" },
        treatmentCourse: { minWidth: "4em", width: "8%" },
        logTarget: { minWidth: "4em", width: "10%" },
        logClass: { width: "4%" },
        logContent: { minWidth: "9em", width: "16%" },
        createdBy: { minWidth: "2.5em", width: "9%" },
        updatedBy: { minWidth: "2.5em", width: "9%" },
        receiver1: { minWidth: "2.5em", width: "9%" },
        receiver2: { minWidth: "2.5em", width: "9%" },
        approver1: { minWidth: "2.5em", width: "9%" },
        approver2: { minWidth: "2.5em", width: "9%" },
      };

      let dynamicCss = "";
      visibleColumns.forEach((col, index) => {
        const style = styleMap[col.field];
        if (!style) return;

        const cssProps = [];
        if (style.minWidth) {
          cssProps.push(`min-width: ${style.minWidth} !important;`);
        }
        if (style.width) {
          cssProps.push(`width: ${style.width} !important;`);
        }
        dynamicCss += `
          #modal-indHistory .k-grid colgroup col:nth-child(${index + 1}) {
            ${cssProps.join("\n")}
          }
        `;
      });

      const scopedDocument = this.$el?.ownerDocument || document;
      let styleEl = scopedDocument.getElementById("dynamic-print-style");
      if (!styleEl) {
        styleEl = scopedDocument.createElement("style");
        styleEl.id = "dynamic-print-style";
        scopedDocument.head.appendChild(styleEl);
      }

      styleEl.innerHTML = `
        @media print {
          ${dynamicCss}
        }
      `;
    },
    /**
     * 画面印刷後処理
     */
    handleAfterPrint() {
      this.removeDynamicPrintStyle();
    },
    /**
     * 動的style削除
     */
    removeDynamicPrintStyle() {
      const scopedDocument = this.$el?.ownerDocument || document;
      const styleEl = scopedDocument.getElementById("dynamic-print-style");
      if (styleEl) {
        styleEl.remove();
      }
    },
    async updateGridData() {
      const that = this;
      that.gridColumns = that.saveGridColumns;

      // TODO: APIの実行方法をApiHelperに変更すること
      that.gridData = createDataSource({
        transport: {
          read: {
            url: "api/indHistory",
            dataType: "json"
          },
          parameterMap(data) {
            const params = {
              patId: that.patId,
              logDateStart: that.condition.inUsed.logDateStart,
              logDateEnd: that.condition.inUsed.logDateEnd,
              treatmentStartDate: that.condition.inUsed.treatmentStartDate,
              treatmentMethod: that.condition.inUsed.treatmentMethod,
              treatmentCourse: that.condition.inUsed.treatmentCourse,
              logTarget: that.condition.inUsed.logTarget,
              createdBy: that.condition.inUsed.createdBy,
              updatedBy: that.condition.inUsed.updatedBy,
              searchString: that.condition.inUsed.searchQuery,
              page: data.page - 1, // APIのページは0オリジン
              size: data.pageSize,
              sort:
                data.sort && data.sort[0] && data.sort[0].dir === "asc"
                  ? "logDate,asc"
                  : "logDate,desc"
            };

            // 値がないフィールドを抜く
            Object.keys(params).forEach(
              key => !params[key] && delete params[key]);
            // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
            setKendoProgress(that.getGridElement(), false);
            // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
            return params;
          }
        },
        // kendo内のページごとのデータ件数
        pageSize: 50,
        // ページネーションはサーバーで行うかどうか
        serverPaging: true,
        // 並べ替えはサーバーで行うかどうか
        serverSorting: true,
        // kendo内の取ってくるデータ構成
        schema: {
          // データを取ってきた後のコールバック
          data(response) {
            const responseData = response.content;
            responseData.forEach(item => {
              item.logDate = dayjs(item.logDate, "YYYYMMDDHHmmssSSS").format(
                "YYYY/MM/DD HH:mm");
              item.treatmentStartDate =
                item.treatmentStartDate &&
                dayjs(item.treatmentStartDate, "YYYYMMDD").format(
                  "YYYY/MM/DD");
              item.treatmentEndDate =
                item.treatmentEndDate &&
                dayjs(item.treatmentEndDate, "YYYYMMDD").format("YYYY/MM/DD");
              // del FNSI-指示履歴指示者、更新者修正 李 start
              // item.createdBy = that.getUserName(that.mstUser, item.createdUserId);
              // item.updatedBy = that.getUserName(that.mstUser, item.updatedUserId);
              // del FNSI-指示履歴指示者、更新者修正 李 end
              item.receiver1 = that.getUserName(that.mstUser, +item.receiver1);
              item.receiver2 = that.getUserName(that.mstUser, +item.receiver2);
              item.approver1 = that.getUserName(that.mstUser, +item.approver1);
              item.approver2 = that.getUserName(that.mstUser, +item.approver2);
              if (item.treatmentCourse === null) {
                item.treatmentCourse = "未登録";
              }
            });
            return responseData;
          },
          // データ総数
          total(response) {
            return response.totalElements;
          }
        },
        requestStart(e) {
          // 患者IDがないとリクエストを処理しない
          if (!that.patId) {
            e.preventDefault();
            that.setLoadingScreenVisible(false);
            setKendoProgress(that.getGridElement(), false);
            return;
          }
          setKendoProgress(that.getGridElement(), true);
        },
        requestEnd() {
          // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
          that.setLoadingScreenVisible(false);
          // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
          // ロードアイコンを非表示
          //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start
          if(that.$refs.grid) {
          //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy end
            setKendoProgress(that.getGridElement(), false);
          //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start
          }
          //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy en
        }
      });
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
        const intervalId = setInterval(() => {
         const elem =  queryScopedSelectorAll("tr.k-alt", this.$el || this);
            if (elem.length > 0) {
              this.setLoadingScreenVisible(false);
              clearInterval(intervalId);
            }
        }, 10);
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
    },

    /**
     * @description 指示履歴内容の改行コードを読み込ませる関数
     */
    readingNewLine(content) {
      let text = content.logContent || "";
      //mod #9355 by zhangruixue 2024-1-24 --start
      text = text.replace(/(\r\n|\n)/g, "<br>");
      // text = text.replace(/\r\n/g, "<br>");
      //mod #9355 by zhangruixue 2024-1-24 --end
      return text;
    },

    /**
     * @description 検索バルーンを表示関数
     */
    // mod FNSI-履歴検索のソート 関 start
    // sortGrid(e) {
    //   // if (e.sort.field !== "logDate") {
    //   //   e.preventDefault();
    //   // }
    // },
    // mod FNSI-履歴検索のソート 関 end
    /**
     * @description 検索バルーンを表示関数
     */
    showSearchPopover(event) {
      this.initializeSearchOptions();
      this.searchPopoverTarget = event;
      this.searchPopoverVisible = true;
    },

    /**
     * @description 検索バルーンを非表示関数
     */
    closeSearchPopover() {
      this.searchPopoverTarget = null;
      this.searchPopoverVisible = false;
    },

    /**
     * @description 検索バルーンでの入力フィールドを初期化関数
     */
    clearSearchOptions() {
      this.condition.inProgress.logDateStart = "";
      this.condition.inProgress.logDateEnd = "";
      this.condition.inProgress.treatmentStartDate = "";
      this.condition.inProgress.treatmentMethod = "";
      this.condition.inProgress.treatmentCourse = "";
      this.condition.inProgress.logTarget = "";
      this.condition.inProgress.createdUserId = "";
      this.condition.inProgress.updatedUserId = "";
      this.condition.inProgress.searchQuery = "";
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [];
      // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start
      this.resetValidation("inProgressLogDateStart");
      this.resetValidation("inProgressLogDateEnd");
      this.resetValidation("inProgressTreatmentStartDate");
      // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end

    },

    /**
     * @description 検索処理関数
     */
    searchFields() {
      // 検索条件操作
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
      this.setLoadingScreenMessage("処理中...");
      this.setLoadingScreenVisible(true);
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
      const inProgressStr = JSON.stringify(this.condition.inProgress);
      // add FNSI-障害票一覧_指示履歴#1。 周 start
      let messageCd = null;
      let stringParams = "";
      // 検査日FROM-TO
      if (this.condition.inProgress.logDateStart && this.condition.inProgress.logDateEnd) {
        if (this.condition.inProgress.logDateStart > this.condition.inProgress.logDateEnd) {
          messageCd = 22010002;
          stringParams = "発行日開始≦発行日終了";
        }
      }
      // add FNSI-障害票一覧_指示履歴#1。 周 end
      this.condition.inUsed = JSON.parse(inProgressStr);
      this.condition.inUsed.createdBy = this.getUserName(this.mstUser, this.condition.inUsed.createdUserId);
      this.condition.inUsed.updatedBy = this.getUserName(this.mstUser, this.condition.inUsed.updatedUserId);
      // mod FNSI-障害票一覧_指示履歴#1。 周 start

      if ("" !== stringParams) {
        this.messageDialogInfo.messageCd = messageCd;
        this.messageDialogInfo.type = "1";
        this.messageDialogInfo.stringParams = [stringParams];
        this.messageDialogInfo.isDialogVisible = true;
        // add/ #12521 指示履歴を表示→検索条件を指定して閉じた後に再度開くを繰り返すとフリーズ tianqidong start
        this.setLoadingScreenVisible(false);
        // add/ #12521 指示履歴を表示→検索条件を指定して閉じた後に再度開くを繰り返すとフリーズ tianqidong end
      } else if (this.gridData?.read) {
        this.gridData.page(1);
        readKendoDataSource(this.gridData);
      } else {
        this.updateGridData();
      }
      // mod FNSI-横展開-日付検索条件 関 start
      // 抽出条件登録
      this.setCondition(deepCopy(this.condition));
      // mod FNSI-横展開-日付検索条件 関 end
      // mod FNSI-障害票一覧_指示履歴#1。 周 end
      this.closeSearchPopover();
      // mod FNSI-横展開-日付検索条件 関 star
      this.setConditionList();
      // mod FNSI-横展開-日付検索条件 関 end
      // mod 8126 指示履歴の処理中が共通ローダーでは無い 関 start
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
      // setTimeout(() => {
      // this.setLoadingScreenVisible(false);
      // }, 1000);
      // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
      this.scroll = 1;
      // mod 8126 指示履歴の処理中が共通ローダーでは無い 関  end
    },

    /**
     * @description 検索条件用データの初期化関数
     */
    async initializeSearchOptions() {
      this.treatmentMethodOptions = await treatment(this.facilityCd).catch(
        err => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndHistoryView.vue', 'treatmentMethodOptions', err);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw err;
        });
      // TODO: MstGettersを使用
      // this.treatmentCourseOptions = await kur(this.facilityCd).catch(err => {
      //   throw err;
      // });
      const responseKur = await ApiHelper.get("/mstInfo/mstKur", {
        facility_cd: this.facilityCd,
        is_del: "0"
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndHistoryView.vue', 'initializeSearchOptions', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      this.treatmentCourseOptions = responseKur.data;

      //対象一覧リスト
      const targetList = [];
      //idと対象名称を格納したリスト
      const dispTargetList = [];
      //項目毎に対象を取得
      for (const category of mstPatViewerLayoutDefine[0].categoryItem) {
        //対象をリストに格納
        category.subCategoryItem.forEach(item => {
          targetList.push(item.itemName);
        });

        // 指示コメントまで格納したら、取得処理を終える
        if (category.component === "ind-comment") break;
      }
      //idと対象名称をリストに格納
      for (let i = 0; i < targetList.length; i++) {
        //格納するidと対象名称を作成
        const targetOption = {
          id: i,
          name: targetList[i]
        };
        //リストに格納
        dispTargetList.push(targetOption);
      }
      //画面表示用リストにidと対象名称をのリストを保持
      this.logTargetOptions = dispTargetList;
      //add shan  start
      let mstPersonalUser = this.getMstPersonalUser();
      if(!mstPersonalUser){
        await ApiHelper.get(`/mstInfo/mstPersonalUser`,{
          facility_cd: this.facilityCd,
          is_del: "0"
        }).then(
          response => {
            mstPersonalUser = response.data;
          })
      }
      //add shan  end
      // const responseUser = await ApiHelper.get("/mstInfo/mstPersonalUser", {
      //   facility_cd: this.facilityCd,
      //   is_del: "0"
      // }).catch(error => {
      //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //   getErrorMessage('IndHistoryView.vue', 'initializeSearchOptions', error);
      //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //   throw error;
      // });
      // mod FNSI-改修内容6092修正 xuty start
      // this.createdByOptions = deepCopy(mstPersonalUser.data);
      // this.updatedByOptions = deepCopy(mstPersonalUser.data);
      this.createdByOptions = deepCopy(mstPersonalUser);
      this.updatedByOptions = deepCopy(mstPersonalUser);
      // mod FNSI-改修内容6092修正 xuty end

      // 空白の選択肢を挿入
      this.treatmentMethodOptions.unshift({
        treatmentCd: null,
        treatmentName: ""
      });
      this.treatmentCourseOptions.unshift({ kurCd: null, kurName: "" });
      this.logTargetOptions.unshift({ id: null, name: "" });
      this.createdByOptions.unshift({ id: null, userName: "" });
      this.updatedByOptions.unshift({ id: null, userName: "" });
    },

    async getUser() {
      //add shan  start
      let mstPersonalUser = this.getMstPersonalUser();
      if(!mstPersonalUser){
        await ApiHelper.get(`/mstInfo/mstPersonalUser`,{
          facility_cd: this.facilityCd
        }).then(
          response => {
            mstPersonalUser = response.data;
          })
      }
      return mstPersonalUser;
      //add shan  end
      // const uriPersonalUser = `/mstInfo/mstPersonalUser`;
      // const responseUser = await ApiHelper.get(uriPersonalUser, {
      //   facility_cd: this.facilityCd
      // }).catch(() => {
      //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //   getErrorMessage('IndHistoryView.vue', 'getUser', '[IndHistoryView.vue]: APIエラー');
      //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //   throw new Error("[IndHistoryView.vue]: APIエラー");
      // });
      // return responseUser.data;
    },

    getUserName(userList, userId) {
      if (userId == null || userId === "" || !Array.isArray(userList)) {
        return null;
      }
      const userInfo = userList.find(user => user.userId == userId);
      return userInfo ? userInfo.userName : null;
    },

    onResize() {
      const ele = this.getScopedElementByIdSafe("modal-indHistory");
      this.gridHeight = ele ? ele.offsetHeight - 20 : 0;
    },

    async getColumnsStatus() {
      const facilityDataRes = await getMstFacitilySettingData(this.facilityCd);
      const facilityData = facilityDataRes.data.localDataSource.data;
      this.columnStatus = {
        isShowChecker1: !!+facilityData.find(
          e => e.facilitySettingNo === INDICATION_RECEIVE_1).value,
        isShowChecker2: !!+facilityData.find(
          e => e.facilitySettingNo === INDICATION_RECEIVE_2).value,
        isShowApprover1: !!+facilityData.find(
          e => e.facilitySettingNo === INDICATION_APPROVE_1).value,
        isShowApprover2: !!+facilityData.find(
          e => e.facilitySettingNo === INDICATION_APPROVE_2).value
      };
      this.indicationUnit =
        +facilityData.find(
          e => e.facilitySettingNo === INDICATION_RECEIVE_APPROVE_UNIT).value === this.FACILITY_TYPES.INDICATION_UNIT;
      this.gridColumns =  [
        { field: "logDate", title: "発行日", width: 150 },
        { field: "treatmentStartDate", title: "開始日", width: 100 },
        { field: "treatmentEndDate", title: "終了日", width: 100 },
        { field: "treatmentWeekday", title: "曜日", width: 100 },
        { field: "treatmentMethod", title: "治療方法", width: 100 },
        { field: "treatmentCourse", title: "クール", width: 100 },
        { field: "logTarget", title: "対象", width: 100 },
        { field: "logClass", title: "操作区分", width: 100 },
        {
          field: "logContent",
          title: "内容",
          width: 300,
          template: this.readingNewLine
        },
        { field: "createdBy", title: "指示者", width: 150 },
        { field: "updatedBy", title: "更新者", width: 150 },
        { field: "receiver1", title: "指示受け1", width: 150, hidden: !this.indicationUnit || !this.columnStatus.isShowChecker1},
        { field: "receiver2", title: "指示受け2", width: 150, hidden: !this.indicationUnit || !this.columnStatus.isShowChecker2},
        { field: "approver1", title: "指示承認1", width: 150, hidden: !this.indicationUnit || !this.columnStatus.isShowApprover1 },
        { field: "approver2", title: "指示承認2", width: 150, hidden: !this.indicationUnit || !this.columnStatus.isShowApprover2},
      ];
      this.saveGridColumns = this.gridColumns;
    },
    setColumns(e){
      this.saveGridColumns = e.sender.columns;
    },
    setResize(e){
      this.saveGridColumns = e.sender.columns;
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      // mod FNSI-横展開-日付検索条件 関 start
      const condObj = this.getCondition.inUsed;
      // mod FNSI-横展開-日付検索条件 関 end
       // mod 6465　ljx start condObjの判断を追加する。
      if(condObj){
        // 発行日開始
        if (condObj.logDateStart !== "" && condObj.logDateStart != null) {
          condList.push({ name:"発行日開始", text:condObj.logDateStart.replace(/-/g, "/") });
        }
        // 発行日終了
        if (condObj.logDateEnd !== "" && condObj.logDateEnd != null) {
          condList.push({ name:"発行日終了", text:condObj.logDateEnd.replace(/-/g, "/") });
        }
        // 治療日
        if (condObj.treatmentStartDate !== "" && condObj.treatmentStartDate != null) {
          condList.push({ name:"治療日", text:condObj.treatmentStartDate.replace(/-/g, "/") });
        }
        // 治療方法
        if (condObj.treatmentMethod !== "") {
          condList.push({ name:"治療方法", text:condObj.treatmentMethod });
        }
        // クール
        if (condObj.treatmentCourse !== "") {
          condList.push({ name:"クール", text:condObj.treatmentCourse });
        }
        // 対象
        if (condObj.logTarget !== "") {
          condList.push({ name:"対象", text:condObj.logTarget });
        }
        // 指示者
        if (condObj.createdBy !== null) {
          condList.push({ name:"指示者", text:condObj.createdBy });
        }
        // 更新者
        if (condObj.updatedBy !== null) {
          condList.push({ name:"更新者", text:condObj.updatedBy });
        }
        // フリーワード
        if (condObj.searchQuery !== "") {
          condList.push({ name:"フリーワード", text:condObj.searchQuery });
        }
       // mod 6465　ljx end

      this.conditionList = condList;
      // mod FNSI-横展開-日付検索条件 関 start
      this.condition.inProgress.logDateStart = condObj.logDateStart;
      this.condition.inProgress.logDateEnd = condObj.logDateEnd;
      this.condition.inProgress.treatmentStartDate = condObj.treatmentStartDate;
      this.condition.inProgress.treatmentMethod = condObj.treatmentMethod;
      this.condition.inProgress.treatmentCourse = condObj.treatmentCourse;
      this.condition.inProgress.logTarget = condObj.logTarget;
      this.condition.inProgress.createdUserId = condObj.createdUserId;
      this.condition.inProgress.updatedUserId = condObj.updatedUserId;
      this.condition.inProgress.searchQuery = condObj.searchQuery;
      this.condition.inUsed.logDateStart = condObj.logDateStart;
      this.condition.inUsed.logDateEnd = condObj.logDateEnd;
      this.condition.inUsed.treatmentStartDate = condObj.treatmentStartDate;
      this.condition.inUsed.treatmentMethod = condObj.treatmentMethod;
      this.condition.inUsed.treatmentCourse = condObj.treatmentCourse;
      this.condition.inUsed.logTarget = condObj.logTarget;
      this.condition.inUsed.createdUserId = condObj.createdUserId;
      this.condition.inUsed.updatedUserId = condObj.updatedUserId;
      this.condition.inUsed.searchQuery = condObj.searchQuery;
      }
      // mod FNSI-横展開-日付検索条件 関 endss
    },
    // add FNSI-横展開-日付検索メッセージ 関 start
    showStartMsg(){
      this.showErrorStartDate = this.condition.inProgress.logDateStart ? this.getScopedClassElementSafe("start-date")?.validationMessage !== "" : false;
    },
    showEndMsg(){
      this.showErrorEndDate = this.condition.inProgress.logDateEnd ? this.getScopedClassElementSafe("end-date")?.validationMessage !== "" : false;
    },
    getStartDate(){
      this.showErrorStartDate = this.condition.inProgress.logDateStart ? this.getScopedClassElementSafe("start-date")?.validationMessage !== "" : false;
    },
    getEndDate(){
      this.showErrorEndDate = this.condition.inProgress.logDateEnd ? this.getScopedClassElementSafe("end-date")?.validationMessage !== "" : false;
    },
    showtreatmentMsg(){
      this.showErrortreatmentDate = this.condition.inProgress.treatmentStartDate ? this.getScopedClassElementSafe("treatment-date")?.validationMessage !== "" : false;
    },
    gettreatmentDate(){
      this.showErrortreatmentDate = this.condition.inProgress.treatmentStartDate ? this.getScopedClassElementSafe("treatment-date")?.validationMessage !== "" : false;
    }
    // add FNSI-横展開-日付検索メッセージ 関
  },

  // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 start
  watch:{
    "condition.inProgress.logDateStart": {
      handler() {
        // mod FNSI-性能を最適化する 李 start
        this.$nextTick(() => {
          this.validateField("inProgressLogDateStart.logDateStart");
        });
        // setTimeout(() => {
        //   this.validateField("inProgressLogDateStart.logDateStart");
        // }, 0);
        // mod FNSI-性能を最適化する 李 end
      }
    },
    "condition.inProgress.logDateEnd": {
      handler() {
        // mod FNSI-性能を最適化する 李 start
        this.$nextTick(() => {
          this.validateField("inProgressLogDateEnd.logDateEnd");
        });
        // setTimeout(() => {
        //   this.validateField("inProgressLogDateEnd.logDateEnd");
        // }, 0);
        // mod FNSI-性能を最適化する 李 end
      }
    },
    "condition.inProgress.treatmentStartDate": {
      handler() {
        // mod FNSI-性能を最適化する 李 start
        this.$nextTick(() => {
          this.validateField("inProgressTreatmentStartDate.treatmentStartDate");
        });
        // setTimeout(() => {
        //   this.validateField("inProgressTreatmentStartDate.treatmentStartDate");
        // }, 0);
        // mod FNSI-性能を最適化する 李 end
      }
    },
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
    gridData: {
       handler(newValue) {
        const gridRoot = this.$refs.grid?.gridRootEl?.() || this.$el.querySelector('.k-grid');
        const elem =  Array.from(gridRoot?.querySelectorAll("tr.k-alt") || []);
        const gridContent = this.getGridContentElement();
        if (!gridContent) {
          return;
        }
        const hasScroll = gridContent.scrollHeight > gridContent.clientHeight;
        const elem2 =  gridContent.scrollHeight-gridContent.scrollTop-gridContent.clientHeight;
        const elem3 = newValue;
        // mod 6458 2023-3-20 指示履歴の発行日の情報が正しく表示されない時がある。張 start
        // if (elem2 < 1 && elem.length > 0 ) {
        if (elem2 <= 10 && hasScroll && elem.length > 1) {
        // mod 6458 2023-3-20 指示履歴の発行日の情報が正しく表示されない時がある。張 end
              this.setLoadingScreenMessage("処理中...");
              this.setLoadingScreenVisible(true);
              this.scroll = 2;
            }
        if (
          (elem2 > 10 && elem.length > 0 && gridContent.scrollTop !== 0 && this.scroll === 2) ||
          ((newValue._page * newValue._pageSize >= newValue._pristineTotal) &&
          gridContent.scrollTop !== 0 &&
          this.scroll === 2)) {
          if ((elem2 > 1 && elem.length > 0 && gridContent.scrollTop != 0 && this.scroll === 2) || ((newValue._page * newValue._pageSize >= newValue._pristineTotal) && gridContent.scrollTop != 0 && this.scroll === 2)) {
            this.setLoadingScreenVisible(false);
          }
        }
       },
       // mod/ #12521 指示履歴を表示→検索条件を指定して閉じた後に再度開くを繰り返すとフリーズ tianqidong end
       deep: true
    }
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
  },
  // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「指示履歴」機能分 周 end

  async created() {
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
    // add 6465　ljx start
    //初期ロード時にkendoが2回リクエストをしてるから、条件が付ける場合、2回目の結果が正しいので、それを使う
    this.setConditionList();
    // add 6465　ljx end
    await this.getColumnsStatus();
    this.$nextTick(async () => {
      this.onResize();
    });
    // del 8126 指示履歴の処理中が共通ローダーでは無い 関 start
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関 start
    // setTimeout(() => {
    //   this.setLoadingScreenVisible(false);
    // }, 1000);
    // add 8126 指示履歴の処理中が共通ローダーでは無い 関  end
    // del 8126 指示履歴の処理中が共通ローダーでは無い 関  end
    // mod FNSI-横展開-日付検索条件 関 start
    // del 6465　ljx start 前のところで実行
    //this.setConditionList();
    // del 6465　ljx end
    // mod FNSI-横展開-日付検索条件 関 end
  },

  beforeUnmount() {
    const scopedWindow = this.$el?.ownerDocument?.defaultView || window;
    scopedWindow.removeEventListener("resize", this.onResize);
    scopedWindow.removeEventListener("beforeprint", this.handleBeforePrint);
    scopedWindow.removeEventListener("afterprint", this.handleAfterPrint);
    this.removeDynamicPrintStyle();
  }
};
</script>

<style scoped>
/* モーダル内がくずれるのでdisplay:hiddenではなくnoneにする */
div :deep(.erd_scroll_detection_container) {
  display: none !important;
}

.modal-container-custom :deep(.k-grid) {
  width: 100%;
  font-size: 1em;
}
 
/*mod FNSI-画面部品デザイン じょはく start*/
.modal-container-custom :deep(.k-grid-content) {
  height: 50vh;
  background-color: var(--grid-background-color);
}
/*mod FNSI-画面部品デザイン じょはく end*/

.modal-container-custom {
  height: auto;
  color: black;
}

.modal-header-custom {
  text-align: left;
  color: white;
  background-color: black;
  padding: 3px;
  height: auto;
  width: auto;
  position: initial;
}

.modal-contents {
  padding: 10px;
}

.modal-footer-custom {
  padding: 10px;
  text-align: end;
}

.icon-close {
  float: right;
  padding: 3px;
  cursor: pointer;
}

.popover-style :deep(.popover__content) {
  width: 25em;
  height: 100%;
  padding: 15px;
}

.popover-style :deep(.popover-mask) {
  z-index: 10005;
}

.popover-style :deep(.popover) {
  width: auto;
}

.popover-footer-style {
  margin-top: 15px;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

input::-webkit-calendar-picker-indicator {
  display: none;
}

/* add FNSI-障害票一覧_指示履歴#1。 周 start */
input[type="date"].ntss-input-date:invalid {
  border-color: red;
}
/* add FNSI-障害票一覧_指示履歴#1。 周 end */

.select-style,
.search-style {
  width: 100%;
}

 
/* TODO: 共通スタイル(modal.css)に定義 */
div :deep(.modal-header .toolbar) {
  background-color: var(--ntss-header-background-color);
}

div :deep(.modal-header .toolbar__title.toolbar__left) {
  color: var(--ntss-header-color) !important;
}

 
/*mod FNSI-画面部品デザイン じょはく start*/
div :deep(.modal-search),
div :deep(.modal-body),
div :deep(.modal-footer),
div :deep(.modal-footer .bottom-bar),
div :deep(.k-grid .k-grid-pager) {
  /* TODO モーダルのテーマ切り替え制御によって記載を要修正 */
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
/*mod FNSI-画面部品デザイン じょはく end*/

#modal-indHistory {
  height: 100%;
}

#search-label-font {
  font-size: 17px;
}

/*mod FNSI-画面部品デザイン じょはく start*/
/* TODO モーダルのテーマ切り替え制御によって記載を要修正 */
.header-item {
  /*background-color: #cccccc;*/
  font-size: .667em;
}
/*mod FNSI-画面部品デザイン じょはく end*/

.dialog-header-item {
  /* 文字色：黒テーマ字に灰色になってしまう為、黒で上書きする */
  color:#333333;
  font-size: .667em;
  height: 4.7em;
}
.condition-search-row {
  padding-right: 5px;
  padding-left: 5px;
  margin-top: 5px;
}
.condition-row {
  margin-bottom: 15px;
  width: 100%;
}
.modal-mask :deep(.modal-search) {
  top: 43px;
  height: 7.5em;
}

 
 
/* mod FNSI-FutreNetWeb+SI課題管理No.5635 李 start */
/* .modal-mask :deep(.modal-body-search){
  top: calc(43px + 3.2em);
  height: calc(100% - 70px - 5.2em);
} */
.modal-mask :deep(.modal-body-search) {
  top: calc(43px + 3.2em);
  height: calc(100% - 70px - 5.2em);
  overflow-y: hidden;
}
/* mod FNSI-FutreNetWeb+SI課題管理No.5635 李 end */

/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 80px;
  padding-top: 8px;
}
.width {
  width: 80px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */
.hist-search-col {
  min-width: 6em;
  white-space: nowrap;
}

@media print {
  /** 抽出条件 */
  .modal-mask :deep(.modal-search) {
    top: 3px;
  }
  /** 印刷時、全列の幅を収める */
  .modal-mask :deep(.modal-container) {
    width: 100%;
  }
  .modal-contents,
  .modal-contents > ons-row {
    padding: 0;
  }
  /* ヘッダ、ボディ */
  #modal-indHistory :deep(.k-grid-header) {
    padding-right: 0 !important;
  }
  /* Grid本体を紙幅に収める */
  #modal-indHistory :deep(.k-grid),
  #modal-indHistory :deep(.k-grid table) {
    width: 100% !important;
    table-layout: fixed !important;
  }
  /* KendoがJSで設定した幅を無効化 */
  #modal-indHistory :deep(.k-grid th),
  #modal-indHistory :deep(.k-grid td) {
    width: auto !important;
    max-width: none !important;
  }
  #modal-indHistory :deep(.k-grid colgroup col) {
    max-width: none !important;
  }
  #modal-indHistory :deep(.k-grid th),
  #modal-indHistory :deep(.k-grid td) {
    white-space: normal !important;
    overflow-wrap: anywhere;
    word-break: break-word;
    height: auto !important;
    padding: 2px 1px !important;
  }
  /* Kendoのellipsis解除 */
  #modal-indHistory :deep(.k-grid .k-link),
  #modal-indHistory :deep(.k-grid .k-column-title),
  #modal-indHistory :deep(.k-grid .k-cell-inner) {
    white-space: normal !important;
    text-overflow: unset !important;
    overflow: visible !important;
  }
}
</style>
