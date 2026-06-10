/**
 * 治療記録の子機能 回診記録ページ
 */
<template>
  <submenu-base>
    <div slot="main" id="round-component">
      <div style="padding: 0 5px 0 5px;">
        <v-ons-list class="treatment-record-accordion list scroll-treatment-record">
        <div id="edit-area">
          <!-- 回診日時 -->
          <v-ons-row>
            <v-ons-col class="title">
              <label>回診日時</label>
            </v-ons-col>
            <v-ons-col>
              <!-- add FNSI-改修内容timeの配置 徐 start -->
              <!-- <v-ons-row> -->
              <v-ons-row style="display: flex; align-items:Center; flex-wrap: nowrap;">
                <!-- add FNSI-改修内容timeの配置 徐 end -->
                <v-ons-col class="flex-0">
                  <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
                  <!-- <input
                    class="ntss-input-date ntss-control-size"
                    type="date"
                    v-model="roundDate"
                    :disabled="!rstEditAuthority || !isShared"
                    @blur="onRegDateTimeInput"
                  /> -->
                  <!-- #5590 2023/05/25 ×を常に表示するように修正 張博 start -->
                  <!-- <input
                    :class="roundDateClass"
                    class="ntss-input-date ntss-control-size"
                    type="date"
                    v-model="roundDate"
                    :disabled="!rstEditAuthority || !isShared"
                    @blur="onRegDateTimeInput"
                    id="roundDate"
                    max="9999-12-31"
                    @keyup="showMsg"
                    v-validate="'date_format:yyyy-MM-dd'"
                  /> -->
                  <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start -->
                  <!-- <date-input
                    :class="roundDateClass"
                    class="ntss-input-date ntss-control-size"
                    v-model="roundDate"
                    :disabled="!rstEditAuthority || !isShared"
                    @blur="onRegDateTimeInput"
                    id="roundDate"
                    @keyup="showMsg"
                    @handleClearInput="roundDate = null"
                  /> -->
                  <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
                  <!-- <date-input -->
                  <!--   :classes="roundDateClass" -->
                  <!--   class="ntss-input-date ntss-control-size" -->
                  <!--   v-model="roundDate" -->
                  <!--   :disabled="!rstEditAuthority || !isShared" -->
                  <!--   @blur="onRegDateTimeInput" -->
                  <!--   id="roundDate" -->
                  <!--   @keyup="showMsg" -->
                  <!--   @handleClearInput="roundDate = null" -->
                  <!-- /> -->
                  <date-input
                    :classes="'date-input-required ' +roundDateClass"
                    class="ntss-input-date ntss-control-size"
                    v-model="roundDate"
                    :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
                    @blur="onRegDateTimeInput"
                    id="roundDate"
                    @keyup="showMsg"
                    isRequired
                  />
                  <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
                  <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
                  <!-- #5590 2023/05/25 ×を常に表示するように修正 張博 end -->
                  <span v-if="showErrorDate" class="error-message">{{ this.msgDiaLog }}</span>
                  <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
                </v-ons-col>
                <v-ons-col class="flex-0">
                  <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
                  <!-- <common-calendar v-model="roundDate" @input="onRegDateTimeInput" :disabled="!rstEditAuthority || !isShared"/> -->
                  <common-calendar v-model="roundDate" @input="onRegDateTimeInput"
                    :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"/>
                  <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
                </v-ons-col>
                <v-ons-col class="flex-0">
                   <!-- #5590 2023/05/25 ×を常に表示するように修正 張博 start -->
                  <!-- <v-ons-input
                    :class="roundTimeClass"
                    type="time"
                    v-model="roundTime"
                    @blur="onRegDateTimeInput"
                    :disabled="!rstEditAuthority || !isShared"
                  /> -->
                  <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start -->
                  <!-- <time-input
                    :class="roundTimeClass"
                    type="time"
                    v-model="roundTime"
                    @blur="onRegDateTimeInput"
                    :disabled="!rstEditAuthority || !isShared"
                    @handleClearInput="roundTime = null"
                  /> -->
                  <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
                  <!-- <time-input -->
                  <!--   :classes="roundTimeClass" -->
                  <!--   type="time" -->
                  <!--   v-model="roundTime" -->
                  <!--   @blur="onRegDateTimeInput" -->
                  <!--   :disabled="!rstEditAuthority || !isShared" -->
                  <!--   @handleClearInput="roundTime = null" -->
                  <!-- /> -->
                  <time-input
                    :classes="'time-input-required ' +roundTimeClass"
                    type="time"
                    v-model="roundTime"
                    @blur="onRegDateTimeInput"
                    :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
                    isRequired
                  />
                  <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
                  <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
                  <!-- #5590 2023/05/25 ×を常に表示するように修正 張博 end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>

          <!-- 回診記録タイトル -->
          <v-ons-row>
            <v-ons-col class="title">
              <label>回診記録タイトル</label>
            </v-ons-col>
            <v-ons-col class="d-flex flex-column justify-content-center">
              <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
              <!-- <v-ons-select -->
              <!--   :class="inputClass" -->
              <!--   class="selectbox" -->
              <!--   :disabled="!rstEditAuthority || !isShared" -->
              <!--   v-model="rstRoundsInfo.inProgress.round_type_cd" -->
              <!--   model-event="change" -->
              <!--   @change="onChangeRoundTypeSelect(rstRoundsInfo.inProgress.round_type_cd,$event)"> -->
              <v-ons-select
                :class="inputClass"
                class="selectbox"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
                v-model="rstRoundsInfo.inProgress.round_type_cd"
                model-event="change"
                @change="onChangeRoundTypeSelect(rstRoundsInfo.inProgress.round_type_cd,$event)">
                <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
                <option v-for="(roundType, index) in roundTypes"
                        :key="index"
                        :value="roundType.round_type_cd"
                        :hidden="roundType.hidden">
                  {{ roundType.round_type_name }}
                </option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>

          <!-- 内容(ラベル) -->
          <v-ons-row>
            <v-ons-col class="title">
              <div>
                <label style="display: block;">内容</label>
                <label class="note">2048文字まで入力可能</label>
              </div>
            </v-ons-col>
          </v-ons-row>
          <!-- 内容 -->
          <v-ons-row>
            <v-ons-col>
              <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
              <!-- <com-textarea -->
              <!--   class="com-textarea" -->
              <!--   :content="{ -->
              <!--   initValue: initialContent, -->
              <!--   editValue: content -->
              <!-- }" -->
              <!--   idTextarea="textarea" -->
              <!--   rows="19" -->
              <!--   cols="100" -->
              <!--   propMaxlength="2048" -->
              <!--   :disabled="!rstEditAuthority || isDisabled || !isShared" -->
              <!--   cssClass="textarea-custom-text-font textarea-resize-vertical" -->
              <!--   @set-content-data="setContentData" -->
              <!-- /> -->
              <!-- mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue start -->
              <!-- <com-textarea
                class="com-textarea"
                :content="{
                initValue: initialContent,
                editValue: content
              }"
                idTextarea="textarea"
                rows="19"
                cols="100"
                propMaxlength="2048"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || isDisabled || !isShared"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData"
                :isRisize="false"
              /> -->
              <com-textarea
                :class="textareaClass"
                class="com-textarea"
                :content="{
                  initValue: initialContent,
                  editValue: content
                }"
                idTextarea="textarea"
                rows="19"
                cols="100"
                propMaxlength="2048"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || isDisabled || !isShared"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData"
                :isRisize="false"
              />
              <!-- mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue end -->
              <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <!-- 指示コメント制御 -->
          <v-ons-row>
            <v-ons-col class="title">
              <div style="display: flex; align-items: baseline; flex-flow: nowrap;">
                <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
                <!-- <v-ons-checkbox -->
                <!--   input-id="ind-comment-post-chkbox" -->
                <!--   :disabled="!(indEditAuthority === true && isNewRoundInfo === true) || isDisabled || !isShared" -->
                <!--   v-model="isIndCommentPost" -->
                <!--   @change="onIndCommentPost" -->
                <!-- ></v-ons-checkbox> -->
                <v-ons-checkbox
                  input-id="ind-comment-post-chkbox"
                  :disabled="!(indEditAuthority === true && isNewRoundInfo === true) ||
                   !getItemAuthorized('TreatmentRecord', 'item_round_component') || isDisabled || !isShared"
                  v-model="isIndCommentPost"
                  @change="onIndCommentPost"
                ></v-ons-checkbox>
                <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
                <label
                  for="ind-comment-post-chkbox"
                  :class="!isNewRoundInfo ? 'disabled-label-color' : isIndCommentPost? 'selected-item' : ''"
                >指示コメントに転記</label>
              </div>
            </v-ons-col>
            <v-ons-col style="display: flex; flex-flow: nowrap; max-width: fit-content; margin-right: 1em;">
              <div class="round-posting-chk" style="display: flex; flex-flow: nowrap;">
                <span v-for="item in postingClass.list" :key="item.cd" style="display: flex; align-items: center; white-space: nowrap;">
                  <v-ons-radio
                    name="posting-class"
                    :input-id="'posting-class-' + item.cd"
                    :disabled="!isNewRoundInfo || !isIndCommentPost || isDisabled || !isShared"
                    model-event="change"
                    :value="item.cd"
                    modifier="round"
                    v-model="postingClass.value"
                    @change="onPostingClass"/>
                  <!-- mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start -->
                  <!-- <label
                    :for="'posting-class-' + item.cd"
                    :class="!isNewRoundInfo ? 'disabled-label-color' : ''"
                    >{{ item.text }}</label> -->
                    <label
                    :for="'posting-class-' + item.cd"
                    :class="!isNewRoundInfo ? 'disabled-label-color' :
                      isIndCommentPost && item.cd == postingClass.value? 'selected-item' :
                      isIndCommentPost && item.cd == postingClassValue? 'selected-item' : ''"
                  >{{ item.text }}</label>
                  <!-- mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end -->
                </span>
              </div>
            </v-ons-col>
            <v-ons-col style="display: flex; flex-flow: nowrap; align-items: center;">
              <label style="white-space: nowrap;" :class="!isNewRoundInfo ? 'disabled-label-color' : ''">指示コメント番号</label>
              <div v-if="isNewRoundInfo" id="ind-comment-no-selector" style="width: 100%;">
                <v-ons-select
                  :class="rstRoundsInfo.inProgress.ind_comment_no? 'custom-input-edited' : ''"
                  class="selectbox"
                  style="min-width: 5em; max-width: 7em;"
                  v-model="rstRoundsInfo.inProgress.ind_comment_no"
                  model-event="change"
                  @change="onIndCommentNo"
                  :disabled="!isIndCommentPost || isDisabled || !isShared">
                  <option v-for="(commentNo, index) in unusedRstIndCommentNo"
                          :key="index"
                          :value="commentNo">
                    {{ commentNo }}
                  </option>
                </v-ons-select>
              </div>
              <label v-else class="selected-rst-ind-comment-no disabled-label-color">
                {{ selectedRstIndCommentNo }}
              </label>
            </v-ons-col>
          </v-ons-row>

          <!-- 指示者 -->
          <v-ons-row>
            <v-ons-col class="title">
              <label style="white-space: nowrap; margin-right: 0.5em;">指示者</label>
              <!-- mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start -->
              <!-- mod FNSI 1006 -> 395 指示コメントに転記 制御 --- 孫灝 start 20201214-->
              <!-- <kendo-dropdownlist
                v-model="rstRoundsInfo.inProgress.ind_user_id"
                :data-source="doctorList"
                :data-text-field="'fullName'"
                :data-value-field="'user_id'"
                :disabled="!isNewRoundInfo || !isRstCommentPost || isDisabled || !isShared || !isIndCommentPost"
                @change="onChange($event),onIndUserSelect">
              </kendo-dropdownlist> -->
              <kendo-dropdownlist
                :class="isNewRoundInfo && isIndCommentPost && rstRoundsInfo.inProgress.ind_user_id? 'dropdownlist-select': ''"
                class="input-style-required"
                v-model="rstRoundsInfo.inProgress.ind_user_id"
                :data-source="doctorList"
                :data-text-field="'fullName'"
                :data-value-field="'user_id'"
                :disabled="!isNewRoundInfo || !isRstCommentPost || isDisabled || !isShared || !isIndCommentPost"
                @change="onChange($event),onIndUserSelect">
              </kendo-dropdownlist>
              <!-- mod FNSI 1006 -> 395 指示コメントに転記 制御 --- 孫灝 end 20201214-->
              <!-- mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end -->
            </v-ons-col>
          </v-ons-row>

          <!-- 起票者／更新者 -->
          <v-ons-row>
            <v-ons-col style="display: flex; margin-right: 1em;">
              <label style="white-space: nowrap; margin-right: 0.5em;">起票者</label>
              <label style="white-space: nowrap;">{{ regUserName }}</label>
            </v-ons-col>
            <v-ons-col style="display: flex;">
              <label style="white-space: nowrap; margin-right: 0.5em;">更新者</label>
              <label style="white-space: nowrap;">{{ updateUserName }}</label>
            </v-ons-col>
          </v-ons-row>
        </div>
        </v-ons-list>
      </div>
    </div>
    <div slot="footer" class="flex-container treatment-submenu">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="white-space: nowrap;">
        <v-ons-button class="button denial-btn cancel btn2-cancel" :disabled="!isShared" @click="onCancelClick">キャンセル</v-ons-button>
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
        <!-- <v-ons-button class="button denial-btn delete btn4-alert" :disabled="!rstEditAuthority || !canDelete || isDisabled || !isShared" @click="onDeleteClick">削除</v-ons-button> -->
        <v-ons-button class="button denial-btn delete btn4-alert"
          :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') ||
           !canDelete || isDisabled || !isShared" @click="onDeleteClick">削除</v-ons-button>
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
      </div>
      <div class="registration-btn-area">
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start-->
<!--        <v-ons-button class="button registration-btn btn1-execute" :disabled="!rstEditAuthority || !canSave || isDisabled || !isShared" @click="onSaveClick">保存</v-ons-button>-->
        <v-ons-button class="button registration-btn btn1-execute" :disabled="isEditable" @click="onSaveClick">保存</v-ons-button>
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end-->
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
    </div>
  </submenu-base>
</template>

<script>
// add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen  end
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
import {mapGetters, mapActions, mapMutations} from "vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
// del #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// del #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
import { RstRoundInfo } from "@/models/treatment-record/round/RstRoundInfo";
import moment from "moment";
import { CODES } from "@/constants/TreatmentRecord";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import {
  dateFormat,
  DATE_FORMAT,
  SHORT_TIME_FORMAT,
  parseDate
} from "@/functions/common/DateTimeUtils"
import RoundComponentMixin from "@/components/treatment-record/submenu/round/RoundComponentMixin";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import { EventBus } from "@/eventBus.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import CommonTextArea from "@/components/common/CommonTextArea";
// add FNSI-横展開 日付のチェックの追加 徐 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-横展開 日付のチェックの追加 徐 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#5590 2023/05/25 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
//#5590 2023/05/25 ×を常に表示するように修正 張博 end
import $$ from "jquery";

export default {
  // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
  // mixins: [DiscardConfirmationMixin, RoundComponentMixin, ComponentGuardMixin, IndUserSelectMixin],
  mixins: [DiscardConfirmationMixin, RoundComponentMixin, IndUserSelectMixin],
  // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
  components: {
    "submenu-base": SubmenuBase,
    "common-calendar": commonCalender,
    "com-textarea": CommonTextArea,
    //#5590 2023/05/25 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    "time-input":TimeInput
    //#5590 2023/05/25 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      tapCount: 0,
      // 回診日
      roundDate: null,
      // 回診時間
      roundTime: null,
      // 起票者名
      regUserName: null,
      // 更新者
      updateUserName: null,
      doctorList: [],
      // 内容
      content: null,
      // 選択済の回診記録カテゴリ番号
      selectedRoundTypeCd: -1,
      rstRoundsInfo: {
        toCompare: null,
        inProgress: null
      },
      isIndCommentPost: false,
      // add FNSI-修正 権限関連 トウ start
      isRstCommentPost: false,
      // add FNSI-修正 権限関連 トウ end
      commentInfo: {
        facilityCd: null,
        patId: null,
        rstKurCd: [ ],
        rstTreatmentCd: [ ],
        treatDate: null
      },
      selectedRstIndCommentNo: undefined,
      postingClass: {
        list: CODES.POSTING_CLASS,
        value: null
      },
      // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
      postingClassValue: null,
      // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
      authorityCds: [
        AUTHORITY_CODES.RST_PEDIT,  // 治療記録-代行編集
        AUTHORITY_CODES.RST_EDIT,   // 治療記録-編集
        AUTHORITY_CODES.IND_PEDIT,  // 治療指示-代行編集
        AUTHORITY_CODES.IND_EDIT    // 治療指示-編集
      ],
      // 治療指示権限の有無
      indEditAuthority: false,
      // del #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
      // // add FNSI-修正 権限関連 トウ start
      // rstEditAuthority: false,
      // // add FNSI-修正 権限関連 トウ end
      // del #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
      selfScreenName: "",
      //add メッセージ順番修正 房 start
      alertFlag: true,
      //add メッセージ順番修正 房 end
      // add FNSI-横展開 日付のチェックの追加 徐 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorDate: false,
      // add FNSI-横展開 日付のチェックの追加 徐 end
      initialContent: null,
      initialRoundTime: null,
      initialRoundDate: null,
      //add 9724-⑤ ljx start
      beforeChangeRoundTypeCd:-1,
      //add 9724-⑤ ljx end
      ro: null,
    };
  },
  computed: {
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // ...mapGetters("pat-info", ["selectedPatId", "isNullPat"]),
    ...mapGetters("pat-info", ["selectedPatId", "isNullPat", "isPatInfoChaned"]),
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    ...mapGetters("treatment-record/common", ["getOrdNo"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", {
      accountInfo: "getStateUserAccountInfo",
      fontSize: "getFontSize"
    }),
    // add FNSI-修正 共有設定 トウ start
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getSharedFacilityCd"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    // add FNSI-修正 共有設定 トウ end
    ...mapGetters("treatment-record/roundsInfo", {
      roundTypes: "roundTypes",
      rstRoundsInfoToCompare: "rstRoundsInfoToCompare",
      rstRoundsInfoInProgress: "rstRoundsInfoInProgress",
      isNewRoundInfo: "isNewRoundInfo",
      selectedRoundType: "selectedRoundType",
      unusedRstIndCommentNo: "unusedRstIndCommentNo",
      rstIndComments: "rstIndComments"
    }),
    isChanged() {
      // 比較用
      // 新規入力の場合、nullが設定されているのでモデルの初期値と比較する
      const toCompare = this.rstRoundsInfo.toCompare
        ? this.rstRoundsInfo.toCompare.getCompareProperties()
        : RstRoundInfo.of().getCompareProperties();
      // 入力用
      // 編集モードの場合、 インスタンスがRstRoundInfoに設定される前に評価されてスクリプトエラーが発生するので型チェックをする
      const inProgress = this.rstRoundsInfo.inProgress instanceof RstRoundInfo && this.hasInProgressFlag
        ? this.rstRoundsInfo.inProgress.getCompareProperties()
        : RstRoundInfo.of().getCompareProperties();
      const isDateChanged = this.initialRoundDate !== this.roundDate || this.initialRoundTime !== this.roundTime;
      return JSON.stringify(toCompare) !== JSON.stringify(inProgress) || isDateChanged || this.isNewRoundInfo;
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    isTextareaChanged() {
      if (this.content !== this.initValue) {
        return false;
      }
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    isDoctorMe() {
      return this.doctorList.map(d => d.user_id).includes(this.accountInfo.userId);
    },
    canSave() {
      // add FNSI-横展開 日付のチェックの追加 徐 start
      // return this.isChanged;
      //mod 9724-③ ljx start
      //return this.isChanged && this.$validator.errors.items.length === 0;
      if(this.isNewRoundInfo){
        return this.$validator.errors.items.length === 0;
      }else{
        return this.isChanged && this.$validator.errors.items.length === 0;
      }
      //mod 9724-③ ljx end
      // add FNSI-横展開 日付のチェックの追加 徐 end
    },
    canDelete() {
      return !this.isNewRoundInfo;
    },
    isDisabled() {
      return this.commentInfo.facilityCd !== this.getFacilityCd;
    },
    // add FNSI-修正 共有設定 トウ start
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add FNSI-修正 共有設定 トウ end
    inputClass(){
      if (this.rstRoundsInfo.toCompare != null && this.rstRoundsInfo.toCompare.round_type_cd != this.rstRoundsInfo.inProgress.round_type_cd) {
        return "custom-input-edited";
      }
      // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue start
      if (this.isNewRoundInfo) {
        return "custom-input-edited";
      }
      // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue end
      return "";
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue start
    textareaClass() {
      if (this.isNewRoundInfo) {
        return "custom-textarea-edited";
      } else {
        return "";
      }
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue end
    roundDateClass(){
      if (this.roundDate != this.initialRoundDate) {
        return "time-input-edited";
      } else if (this.isNewRoundInfo) {
        return "time-input-edited";
      }
      return "";
    },
    roundTimeClass(){
      if (this.roundTime != this.initialRoundTime) {
        return "custom-input-edited";
      } else if (this.isNewRoundInfo) {
        return "time-input-edited";
      }
      return "";
    },
    isEditable(){
      let isPatInfoChaned = !this.getItemAuthorized('TreatmentRecord', 'default_authority') ||
        !this.canSave || this.isDisabled || !this.isShared;
      this.setIsPatInfoChaned(!isPatInfoChaned);
      return isPatInfoChaned;
    }
  },
  methods: {
    ...mapActions("treatment-record/roundsInfo", [
      "getDoctorsAtFacility"
      , "getFixedPhrase"
      , "updateTreatmentRecordRstRoundsInfo"
      , "setCreatedAndUpdatedAndIndUserInProgress"
      , "updateIndComment"
      //9724-⑤ add ljx start
      , "setRoundTypes"
      //9724-⑤ add ljx end
    ]),
    ...mapActions("treatment-record/addition", ["updateTreatmentRecordAddition"]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    // add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen  end
    /**
     * 起票者を設定する.
     */
    setRegUserName() {
      this.regUserName = this.isNewRoundInfo
        ? `${this.accountInfo.userLastName || ''} ${this.accountInfo.userFirstName || ''}`
        : (this.rstRoundsInfoInProgress.regUserFullName || '');
      if(!this.isNewRoundInfo) return;

      this.rstRoundsInfo.inProgress.reg_user_id = this.accountInfo.userId ? this.accountInfo.userId : null;
      this.rstRoundsInfo.inProgress.reg_user_last_name = this.accountInfo.userLastName ? this.accountInfo.userLastName : '';
      this.rstRoundsInfo.inProgress.reg_user_first_name = this.accountInfo.userFirstName ? this.accountInfo.userFirstName : '';
      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
    },

    /**
     * 更新者を設定する.
     * 新規登録の場合、空欄を設定する.
     */
    setCreateUserName() {
      this.updateUserName = this.isNewRoundInfo
        ? ""
        : `${this.rstRoundsInfoInProgress.updated_user_last_name || ''} ${this.rstRoundsInfoInProgress.updated_user_first_name || ''}`;
      if(!this.isNewRoundInfo) return;

      this.rstRoundsInfo.inProgress.create_user_id = this.accountInfo.userId ? this.accountInfo.userId : null;
      this.rstRoundsInfo.inProgress.create_user_last_name = this.accountInfo.userLastName ? this.accountInfo.userLastName : '';
      this.rstRoundsInfo.inProgress.create_user_first_name = this.accountInfo.userFirstName ? this.accountInfo.userFirstName : '';
      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
    },

    /**
     * 回診日時を設定する.
     * 新規登録の場合はシステム日時を設定する.
     */
    setRegDateTime() {
      // 新規の場合、回診日にシステム日時を設定
       this.roundDate = this.isNewRoundInfo
        ? dateFormat.format(new Date(), DATE_FORMAT) // システム日付
        : dateFormat.format(new Date(this.rstRoundsInfoInProgress.reg_date_time), DATE_FORMAT);
      // 回診時間
      this.roundTime = this.isNewRoundInfo
        ? dateFormat.format(new Date(), SHORT_TIME_FORMAT) // システム時刻
        : dateFormat.format(new Date(this.rstRoundsInfoInProgress.reg_date_time), SHORT_TIME_FORMAT);

      // 新規の場合はモデルのプロパティも設定する
      if(this.isNewRoundInfo) {
        this.onRegDateTimeInput();
      }
    },

    /**
     * 内容を設定する.
     */
    setContent() {
      if(this.isNewRoundInfo) {
        this.content = this.selectedRoundType ? this.selectedRoundType.content : null;
        //add FNSI修正484改修 房 start
        this.rstRoundsInfo.inProgress.round_type_cd = this.selectedRoundType ? this.selectedRoundType.round_type_cd : null;
        //add FNSI-redmine5998 fang start
        this.rstRoundsInfo.inProgress.round_type_name = this.selectedRoundType ? this.selectedRoundType.round_type_name : null;
        //add FNSI-redmine5998 fang end
        //add FNSI修正484改修 房 end
        // 新規の場合はモデルのプロパティも設定する
        this.onContent();
      } else {
        this.content = this.rstRoundsInfo.inProgress.content;
      }
    },

    /**
     * 指示者を設定する.
     */
    async setIndUser() {
      // 指示者ドロップダウンの設定(治療指示権限で初期選択を設定)
      this.getIndUserList(
        AUTHORITY_CODES.IND_EDIT, // 治療指示-編集
        AUTHORITY_CODES.IND_PEDIT // 治療指示-代行編集
      )
      .then(response => {
        let iniSelectId = response.iniSelectId;
        this.doctorList = response.doctorList;
        // 前回登録した指示者のチェック
        if (this.rstRoundsInfo.inProgress?.ind_user_id) {
          const user = this.doctorList.find(d => d.user_id == this.rstRoundsInfo.inProgress.ind_user_id);
          if (!user) {
            // リストにいなければ含める
            this.doctorList.push({
              user_id: this.rstRoundsInfo.inProgress.ind_user_id,
              user_last_name: this.rstRoundsInfo.inProgress.ind_user_last_name || '',
              user_first_name: this.rstRoundsInfo.inProgress.ind_user_first_name || '',
              fullName:  `${this.rstRoundsInfo.inProgress.ind_user_last_name || ''} ${this.rstRoundsInfo.inProgress.ind_user_first_name || ''}`
            });
          }
          iniSelectId = String(this.rstRoundsInfo.inProgress.ind_user_id);
        }
        if (!this.rstRoundsInfo.inProgress) return;
        // 同じ値の場合、認識されない為、一旦初期化する
        this.rstRoundsInfo.inProgress.ind_user_id = null;
        this.$nextTick(() => {
          this.rstRoundsInfo.inProgress.ind_user_id = iniSelectId;
        // add 6173 治療記録の加算情報および回診記録は、編集していなくても編集破棄のメッセージが表示される 関 start
          this.rstRoundsInfo.toCompare.ind_user_id = iniSelectId;
         // add 6173 治療記録の加算情報および回診記録は、編集していなくても編集破棄のメッセージが表示される 関  end
          //add FNSI-redmine5998 fang start
          const user = this.doctorList.find(d => d.user_id == this.rstRoundsInfo.inProgress.ind_user_id);
          this.rstRoundsInfo.inProgress.ind_user_last_name = user ? user.user_last_name : '';
          this.rstRoundsInfo.inProgress.ind_user_first_name = user ? user.user_first_name : '';
          //add FNSI-redmine5998 fang end
        });
      });
    },

    /**
     * 指示コメントに転記チェックボックスを設定する.
     */
    setIndCommentPost() {
      // 治療指示の代行編集権限以上があるか確認し、権限がない場合はチェックボックスを無効且つオフにする(？？？？患者の場合も同様)
      // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
      // if ((this.getUserAuthorityCds().includes(AUTHORITY_CODES.IND_EDIT) ||
      //     this.getUserAuthorityCds().includes(AUTHORITY_CODES.IND_PEDIT)) &&
      //   !(this.selectedPatId === null && this.isNullPat)
      //     ) {
      //   this.indEditAuthority = true;
      // } else {
      //   this.indEditAuthority = false;
      // }
      this.indEditAuthority = !(this.selectedPatId === null && this.isNullPat);
      // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end

      if(this.isNewRoundInfo) {
        let isIndCommentPost = false;
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
        // if (this.indEditAuthority) {
        if (this.indEditAuthority && this.getItemAuthorized('TreatmentRecord', 'item_round_component')) {
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
          isIndCommentPost = this.selectedRoundType
            ? this.selectedRoundType.comment_post_default === CODES.CHECK.ON.cd
            : false;
        }

        // 新規の場合はモデルのプロパティを設定
        this.isIndCommentPost = isIndCommentPost;
        this.rstRoundsInfo.inProgress.is_ind_comment_post = isIndCommentPost
          ? CODES.CHECK.ON.cd
          : CODES.CHECK.OFF.cd;
        this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
      } else {
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
        // if (this.indEditAuthority) {
        if (this.indEditAuthority && this.getItemAuthorized('TreatmentRecord', 'item_round_component')) {
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
          this.isIndCommentPost = this.rstRoundsInfo.inProgress.is_ind_comment_post === CODES.CHECK.ON.cd;
        } else {
          this.isIndCommentPost = false;
        }
      }
    },
    // add FNSI-修正 権限関連 トウ start
    setRstCommentPost() {
      // 治療記録の代行編集権限以上があるか確認し、権限がない場合はチェックボックスを無効且つオフにする(？？？？患者の場合も同様)
      // mod 9707 未登録患者の回診記録の登録が行えない　吉 start
      // if (this.isNewRoundInfo) {
      //   if ((this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_EDIT) ||
      //   this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_PEDIT))
      //     //del 9707 ljx start
      //   //   &&
      //   // !(this.selectedPatId === null && this.isNullPat)
      //     //del 9707 ljx end
      //   ) {
      //     this.rstEditAuthority = true;
      //   } else {
      //     this.rstEditAuthority = false;
      //   }
      // } else {
      //   if ((this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_EDIT) ||
      //   this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_PEDIT) ||
      //   (this.rstRoundsInfo.inProgress.ind_user_id === this.accountInfo.userId))
      //     //del 9707 ljx start
      //     //   &&
      //   // !(this.selectedPatId === null && this.isNullPat)
      //     //del 9707 ljx end
      //   ) {
      //     this.rstEditAuthority = true;
      //   } else {
      //     this.rstEditAuthority = false;
      //   }
      // }
      // del #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
      // this.rstEditAuthority = (this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_EDIT)
      //   || this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_PEDIT)
      //   || (!this.isNewRoundInfo && this.rstRoundsInfo.inProgress.ind_user_id === this.accountInfo.userId));
      // del #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
      // mod 9707 未登録患者の回診記録の登録が行えない　吉 end
      if(this.isNewRoundInfo) {
        let isRstCommentPost = false;
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
        // if (this.rstEditAuthority) {
        if (this.getItemAuthorized('TreatmentRecord', 'default_authority')) {
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
          isRstCommentPost = this.selectedRoundType
            ? this.selectedRoundType.comment_post_default === CODES.CHECK.ON.cd
            : false;
        }

        // 新規の場合はモデルのプロパティを設定
        this.isRstCommentPost = isRstCommentPost;
        this.rstRoundsInfo.inProgress.is_ind_comment_post = isRstCommentPost
          ? CODES.CHECK.ON.cd
          : CODES.CHECK.OFF.cd;
        this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
      } else {
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
        // if (this.rstEditAuthority) {
        if (this.getItemAuthorized('TreatmentRecord', 'default_authority')) {
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
          this.isRstCommentPost = this.rstRoundsInfo.inProgress.is_ind_comment_post === CODES.CHECK.ON.cd;
        } else {
          this.isRstCommentPost = false;
        }
      }
    },
    // add FNSI-修正 権限関連 トウ end
    /**
     * 指示コメント番号を設定する.
     */
    setRstIndCommentNo() {
      if (this.isNewRoundInfo) {
        this.selectedRstIndCommentNo = null;
        return;
      }
      this.selectedRstIndCommentNo = this.rstRoundsInfo.inProgress.ind_comment_no;
    },

    /**
     * 転記区分を設定する.
     */
    setPostingClass() {
      if(this.isNewRoundInfo) {
        const postingClass = this.selectedRoundType
          ? this.selectedRoundType.posting_class_default
          : null;
        // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
        this.postingClassValue = postingClass;
        // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
        // 新規の場合はモデルのプロパティを設定
        this.postingClass.value = postingClass;
        this.rstRoundsInfo.inProgress.posting_class = postingClass;
        this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
      } else {
        this.postingClass.value = this.rstRoundsInfo.inProgress.posting_class;
      }
      //9707 add ljx start
      //???患者の場合、転記区分をnullで設定。
      // 原因はサーバー側で転記区分を利用して、指示コメントへ転記処理を行う。？？？患者の場合、その処理は実行しない。
      if(this.selectedPatId === null || this.isNullPat){
        this.postingClass.value = null;
        this.rstRoundsInfo.inProgress.posting_class = null;
      }
      //9707 add ljx end
    },
    /**
     * 回診日時変更イベント
     */
    onRegDateTimeInput() {
      // 回診日時
      let roundDateTime = null;
      // 回診日付及び回診時間が未登録
      if (this.roundDate && this.roundTime) {
        roundDateTime = dateFormat.utc2Jst(
          parseDate(
            this.roundDate,
            this.roundTime
          )
        );
      }
      this.rstRoundsInfo.inProgress.reg_date_time = roundDateTime;
      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
    },

    /**
     * 回診記録タイトル変更イベント.
     * @param cd 種別コード
     * @param e イベント オブジェクト
     */
    onChangeRoundTypeSelect(cd,e) {
      //mod 9724-⑤ ljx start
      let newArray = [];
      for(let i = 0;i<e.target.length;i++){
        if(e.target[i].hidden !== true){
          newArray.push(this.roundTypes[i]);
        }
      }
      this.setRoundTypes(newArray);
      if(this.beforeChangeRoundTypeCd === cd){
        return;
      }
      this.beforeChangeRoundTypeCd = cd
      //mod 9724-⑤ ljx end

      const selectRoundType = this.roundTypes
        .find(roundType => roundType.round_type_cd === this.rstRoundsInfo.inProgress.round_type_cd);
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000146].title,
        // message:
        //   "回診記録タイトルが変更されました。<br>内容をテンプレートで上書しますか？",
        message: messageFormat(DIALOG_MESSAGES[13000146].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            // 内容を上書き
            //add FNSI修正484改修 房 start
            this.content = selectRoundType.content === null ? "" : selectRoundType.content;
            //add FNSI修正484改修 房 end
            // モデルへ反映
            this.onContent();
          }
          this.rstRoundsInfo.inProgress.round_type_cd = selectRoundType ? selectRoundType.round_type_cd : null;
          this.rstRoundsInfo.inProgress.round_type_name = selectRoundType ? selectRoundType.round_type_name : null;
          //add FNSI修正484改修 房 start
          // mod 7858 「指示コメントに転記」「転記区分」に変更後の回診記録タイトルの初期値が展開される 房 start
          if (this.isNewRoundInfo) {
            this.postingClass.value = selectRoundType ? selectRoundType.posting_class_default : null;
            // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
            this.postingClassValue = this.postingClass.value;
            // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
            let isIndCommentPost = false;
            // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
            // if (this.indEditAuthority) {
            if (this.indEditAuthority && this.getItemAuthorized('TreatmentRecord', 'item_round_component')) {
            // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
              isIndCommentPost = selectRoundType
                ? selectRoundType.comment_post_default === CODES.CHECK.ON.cd
                : false;
            }

            // 新規の場合はモデルのプロパティを設定
            this.isIndCommentPost = isIndCommentPost
          }
          // mod 7858 「指示コメントに転記」「転記区分」に変更後の回診記録タイトルの初期値が展開される 房 end
          //add FNSI-redmine5529 fang start
          // mod 7858 「指示コメントに転記」「転記区分」に変更後の回診記録タイトルの初期値が展開される 房 start
          if (this.isNewRoundInfo) {
            this.rstRoundsInfo.inProgress.is_ind_comment_post = selectRoundType.comment_post_default;
          }
          // mod 7858 「指示コメントに転記」「転記区分」に変更後の回診記録タイトルの初期値が展開される 房 end
          //add FNSI-redmine5529 fang end
          let isRstCommentPost = false;
          // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
          // if (this.rstEditAuthority) {
          if (this.getItemAuthorized('TreatmentRecord', 'default_authority')) {
          // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
            isRstCommentPost = selectRoundType
              ? selectRoundType.comment_post_default === CODES.CHECK.ON.cd
              : false;
          }

          // 新規の場合はモデルのプロパティを設定
          this.isRstCommentPost = isRstCommentPost;

          //add FNSI-redmine6539 fang start
          // mod 7858 「指示コメントに転記」「転記区分」に変更後の回診記録タイトルの初期値が展開される 房 start
          if (this.isNewRoundInfo) {
            this.rstRoundsInfo.inProgress.posting_class = selectRoundType ? selectRoundType.posting_class_default : null;
          }
          // mod 7858 「指示コメントに転記」「転記区分」に変更後の回診記録タイトルの初期値が展開される 房 end
          //add FNSI-redmine6539 fang end
          // add 9707 ljx start
          //???患者の場合、転記区分をnullで設定。
          // 原因はサーバー側で転記区分を利用して、指示コメントへ転記処理を行う。？？？患者の場合、その処理は実行しない。
          if(this.selectedPatId === null || this.isNullPat){
            this.postingClass.value = null;
            this.rstRoundsInfo.inProgress.posting_class = null;
          }
          // add 9707 ljx end
          //add FNSI修正484改修 房 end
          this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
        }
      });
    },
    /**
     * 指示者変更イベント.
     */
    onIndUserSelect() {
      const user = this.doctorList.find(d => d.user_id == this.rstRoundsInfo.inProgress.ind_user_id);
      this.rstRoundsInfo.inProgress.ind_user_id = user ? user.user_id : null;
      this.rstRoundsInfo.inProgress.ind_user_last_name = user ? user.user_last_name : '';
      this.rstRoundsInfo.inProgress.ind_user_first_name = user ? user.user_first_name : '';
      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
    },
    // add #9311 v-model発効します 張博 start
    onChange(event){
      this.rstRoundsInfo.inProgress.ind_user_id = event.sender._old;
    },
    // add #9311 v-model発効します 張博 end
    /**
     * 内容変更イベント.
     */
    onContent() {
      this.rstRoundsInfo.inProgress.content = this.content;
      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
    },
    /**
     * 指示コメントへの転記チェックボックスのイベント.
     */
    onIndCommentPost(ev) {
      this.$nextTick(() => {
        this.rstRoundsInfo.inProgress.is_ind_comment_post = ev.target.checked
          ? CODES.CHECK.ON.cd
          : CODES.CHECK.OFF.cd;
        this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
        // add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
        this.isRstCommentPost = ev.target.checked;
        // add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
      });
    },
    /**
     * 指示コメント番号の変更イベント.
     */
    onIndCommentNo() {
      this.rstRoundsInfo.inProgress.ind_comment_no =
        this.rstRoundsInfo.inProgress.ind_comment_no
          ? this.rstRoundsInfo.inProgress.ind_comment_no
          : null;
      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
    },
    /**
     * 転記区分の変更イベント.
     */
    onPostingClass(ev) {
      this.$nextTick(() => {
        this.rstRoundsInfo.inProgress.posting_class = ev.target.value;
        this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
      });
    },
    /**
     * 治療記録トップ画面へのルーティング
     */
    routePushToTreatmentRecord() {
      // 治療記録画面を表示
      this.$router.push({ name: "treatment-record" });
    },
    /**
     * バリデーション
     */
    validate() {
      // バリデーションメッセージ用の改行
      const withBr = (columnName) => `</br>&nbsp&nbsp・${columnName}`;
      // チェック結果
      const validateResult = this.rstRoundsInfoInProgress.validation();
      // 指示コメントに転記にチェックがされている場合、内容は必須入力とする.
      const contentErrMessage = this.isIndCommentPost && !validateResult.content
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // ? "指示コメントに転記する場合<br>内容を入力して下さい。"
          ? messageFormat(DIALOG_MESSAGES[12000266].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          : null;
      if (contentErrMessage) {
        this.showAlert(contentErrMessage);
        return false;
      }
      const { title, message } = DIALOG_MESSAGES[22010001];
      const indUserErrMessage = !validateResult.ind_user
          // title: "必須項目未入力",
          // message: "{$1}は必須入力項目です。\n必ず値を入力してください。"
          ? messageFormat(message, "指示者")
          : null;
      if (indUserErrMessage) {
        this.showAlert(indUserErrMessage, title);
        return false;
      }

      //mode 内結バッグNo.58 房 start
      // エラーメッセージ
      let errMessage =
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // (validateResult.reg_date_time ? "" : withBr("回診日時が未入力です。"))
        // + (!validateResult.reg_date_time_future ? "" : withBr("回診日時に未来日は指定できません。"))
        // + (validateResult.ind_comment ? "" : withBr("指示コメント番号が未選択です。"))
        (validateResult.reg_date_time ? "" : withBr(messageFormat(DIALOG_MESSAGES[12000263].message)))
        + (!validateResult.reg_date_time_future ? "" : withBr(messageFormat(DIALOG_MESSAGES[12000264].message)))
        + (validateResult.ind_comment ? "" : withBr(messageFormat(DIALOG_MESSAGES[12000265].message)))
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      ;
      // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
      // if (!validateResult.ind_comment && !this.indEditAuthority) {
      if (!validateResult.ind_comment &&
        !(this.indEditAuthority && this.getItemAuthorized('TreatmentRecord', 'item_round_component'))) {
      // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
        errMessage = "";
      }
      //mode 内結バッグNo.58 房 end
      if(errMessage === "") return true;

      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "チェックエラー",
        title: DIALOG_MESSAGES[12000263].title,
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        message: '<div style="text-align:center;">' + errMessage + "</div>"
      });
      return false;
    },
    /**
     * アラート表示
     */
    showAlert(messege, title) {
      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "チェックエラー",
        title: title ? title : DIALOG_MESSAGES[12000266].title,
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        message: messege
      });
    },
    /**
     * 指示：指示コメント削除
     */
    async deleteIndIndComment() {
      if(!this.rstRoundsInfoInProgress.shouldSaveIndComment()) return;
      //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao start
      // this.updateIndComment(this.createIndCommentParameter(
      //   CODES.COMMENT_FLAG.DELETE.cd,
      //   this.rstRoundsInfo.inProgress.posting_class === CODES.POSTING_CLASS.TODAY.cd));
      //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao start
      this.updateIndComment(this.createIndCommentParameter(
        CODES.COMMENT_FLAG.DELETE.cd,
        true));
      //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao end
    },
    /**
     * 指示：指示コメント更新
     */
    async updateIndIndComment() {
      if(!this.rstRoundsInfoInProgress.shouldSaveIndComment()) return;
      const commentFlg = this.isNewRoundInfo ? CODES.COMMENT_FLAG.NEW : CODES.COMMENT_FLAG.EDIT;
      try {
        this.updateIndComment(this.createIndCommentParameter(commentFlg.cd,
          this.rstRoundsInfo.inProgress.posting_class === CODES.POSTING_CLASS.TODAY.cd));
      } catch (e) {
       console.log(e);
      }
    },
    /**
     * 実績：指示コメント削除
     */
    // async deleteRstIndComment() {
    //   if(!this.rstRoundsInfoInProgress.shouldSaveRstIndComment()) return;
    //   const commentNo = this.rstRoundsInfoInProgress.ind_comment_no;
    //   const indComments = this.rstIndComments.filter(c => c.no !== commentNo);

    //   this.updateTreatmentRecordAddition({
    //     ordNo: this.getOrdNo,
    //     payload: { rst_ind_comment_info: JSON.stringify(indComments) }
    //   })
    //     .catch(error => {
    //       if (error.response.status === 400) {
    //         this.$ons.notification.alert({
    //           title: "登録失敗",
    //           message: "実績の指示コメント登録に失敗しました。"
    //         });
    //       }
    //     });
    // },
    /**
     * 実績:指示コメント更新
     */
    // async updateRstIndComment() {
    //   if(!this.rstRoundsInfoInProgress.shouldSaveRstIndComment()) return;
    //   const commentNo = this.rstRoundsInfoInProgress.ind_comment_no;
    //   const editIndComment = this.rstIndComments.find(c => c.no === commentNo);

    //   let commentInfo = [];
    //   if(!editIndComment) {
    //     // 新規
    //     const commentJson = {
    //       no: commentNo,
    //       content: this.rstRoundsInfoInProgress.content,
    //       ind_user_id: this.rstRoundsInfoInProgress.ind_user_id,
    //       ind_user_last_name: this.rstRoundsInfoInProgress.ind_user_last_name,
    //       ind_user_first_name: this.rstRoundsInfoInProgress.ind_user_first_name,
    //       upd_user_id: this.rstRoundsInfoInProgress.updated_user_id,
    //       upd_user_last_name: this.rstRoundsInfoInProgress.updated_user_last_name,
    //       upd_user_first_name: this.rstRoundsInfoInProgress.updated_user_first_name,
    //       input_class: CODES.COMMENT_INPUT_CLASS.RST.cd,
    //       is_editable: "1",
    //       cop_order_no: ""
    //     };
    //     commentInfo = JSON.stringify(
    //       this.rstIndComments.concat(commentJson)
    //     );
    //   } else {
    //     // 編集
    //     editIndComment.content = this.rstRoundsInfoInProgress.content;
    //     editIndComment.ind_user_id = this.rstRoundsInfoInProgress.ind_user_id;
    //     editIndComment.ind_user_last_name = this.rstRoundsInfoInProgress.ind_user_last_name;
    //     editIndComment.ind_user_first_name = this.rstRoundsInfoInProgress.ind_user_first_name;
    //     editIndComment.upd_user_id = this.rstRoundsInfoInProgress.updated_user_id;
    //     editIndComment.upd_user_last_name = this.rstRoundsInfoInProgress.updated_user_last_name;
    //     editIndComment.upd_user_first_name = this.rstRoundsInfoInProgress.updated_user_first_name;

    //     commentInfo = JSON.stringify(this.rstIndComments);
    //   }

    //   this.updateTreatmentRecordAddition({
    //     ordNo: this.getOrdNo,
    //     payload: { rst_ind_comment_info: commentInfo }
    //   })
    //     .catch(error => {
    //       if (error.response.status === 400) {
    //         this.$ons.notification.alert({
    //           title: "登録失敗",
    //           message: "実績の指示コメント登録に失敗しました。"
    //         });
    //       }
    //     });
    // },
    // mod redmine-6173 「治療記録の加算情報および回診記録は、編集していなくても編集破棄のメッセージが表示される」 房 start
    /**
     * キャンセルボタンクリックイベント.
     */
    async onCancelClick() {
      if (!this.isChanged) {
        this.isDialogOpen = true;
      }
      this.routePushToTreatmentRecord();

    },
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    discardConfirmInner(execFunction) {
      // ダイアログの2重表示防止のためダイアログが閉じている場合のみ表示
      if (!this.isDialogOpen){
        this.$ons.notification.confirm({
         // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              this.setIsPatInfoChaned(false);
              execFunction();
            }
            this.isDialogOpen = false;
          }
        });
      }
    },
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // mod redmine-6173 「治療記録の加算情報および回診記録は、編集していなくても編集破棄のメッセージが表示される」 房 end
    /**
     * 保存ボタンクリックイベント.
     */
    async onSaveClick() {
      if(!this.validate()) return;

      // stateの作成者と更新者を設定.
      this.setCreatedAndUpdatedAndIndUserInProgress({
        userId: this.accountInfo.userId,
        userFirstName: this.accountInfo.userFirstName,
        userLastName: this.accountInfo.userLastName
      });

      // 回診記録の登録.
      await this.updateTreatmentRecordRstRoundsInfo({
        ordNo: this.getOrdNo,
        rstRoundsInfo: this.rstRoundsInfoInProgress.toString()
      });

      // 指示側の指示コメントの更新
      // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 zhao start
      //await this.updateIndIndComment();
      if (this.isIndCommentPost) {
        await this.updateIndIndComment();
      }
      // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 zhao end

      // 実績側の指示コメントの更新
      // await this.updateRstIndComment();

      // 更新した内容をstoreに反映
      await this.getRstRoundsInfoAndSaveToStore();
      this.selectedRstIndCommentNo = this.rstRoundsInfo.inProgress.ind_comment_no;
      this.routePushToTreatmentRecord();
      // 子機能ボタンエリアの更新
      this.$emit("update");
    },
    /**
     * 削除ボタンクリックイベント.
     */
    async onDeleteClick() {
      const deleteRoundsInfo = () => {
        return this.updateTreatmentRecordRstRoundsInfo({
          ordNo: this.getOrdNo,
          rstRoundsInfo: null
        });
      }
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "回診記録削除確認",
        title: DIALOG_MESSAGES[13000147].title,
        // message:
        //   "回診記録を削除し、未回診状態にします。<br>削除すると二度と元に戻せません。削除してもよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000147].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            await deleteRoundsInfo();
            //del 10416治療記録＞回診記録の指示コメント展開バグ start zhao
            //await this.deleteIndIndComment();
            //del 10416治療記録＞回診記録の指示コメント展開バグ start end

            // add 9724 start
	    // mod #12462 患者情報共有 Ji start
            await this.fetchRoundTypes({facilityCd:this.getFacilityCd, patId:this.selectedPatId});
	    // mod #12462 患者情報共有 Ji end
            // add 9724 end

            await this.getRstRoundsInfoAndSaveToStore();
            this.saveRoundType();
            this.routePushToTreatmentRecord();
            // 子機能ボタンエリアの更新
            this.$emit("update");

          }
        }
      });
    },

    /**
     * 内容(テキストエリア)のサイズ変更(min-height)
     */
     resizeTAMinH() {
      const tx = $$("#textarea");

      const LINE_HEIGHT = 1.3;
      const ROW_COUNT = 6;

      // paddingの高さを算出
      const cHeight = tx.height();
      const pHeight = tx.innerHeight();
      const diff = pHeight - cHeight;

      // スタイル設定
      tx.css({
        "line-height" : `${LINE_HEIGHT}`,
        "min-height" : `calc(${(LINE_HEIGHT * ROW_COUNT)}em + ${diff}px)`
      });
    },

    /**
     * 内容(テキストエリア)のサイズ変更(height)
     */
     resizeTAH() {
      const tx = $$("#textarea");

      // 外側要素の高さと、内側要素の高さの差を計算
      const rc = $$("#round-component");
      const ed = $$("#edit-area");
      const diff = rc.innerHeight() - ed.outerHeight(true);

      tx.css({
        "height" : tx.outerHeight(true) + diff + "px",
      });
    },

    /**
     * 内容(テキストエリア)のサイズ変更(メイン)
     */
    resizeTAMain() {
      // min-height設定
      this.resizeTAMinH();
      // height設定
      this.resizeTAH();
    },

    /**
     * 初期処理
     */
    async init() {
      if (!this.getOrdNo) {
        return;
      }
      this.alertFlag = false;
      //add 9724 ljx start typeError修正
      if(!this.rstRoundsInfo.inProgress){
        this.rstRoundsInfo.inProgress = {}
      }
      //add 9724 ljx end typeError修正
      // ストアの編集中の値がnullの場合はストアの再設定を行う
      if (this.rstRoundsInfoInProgress == null) {
        await this.getRstRoundsInfoAndSaveToStore();
      } else {
        this.hasInProgressFlag=true;
      }
      this.rstRoundsInfo.inProgress = this.rstRoundsInfoInProgress;
      //add 9724-⑤ ljx start
      this.beforeChangeRoundTypeCd = this.rstRoundsInfo?.inProgress.round_type_cd;
      //add 9724-⑤ ljx end
      // add #12462 患者情報共有 Ji start
      this.fetchRoundTypes({facilityCd:this.getFacilityCd, patId:this.selectedPatId}),
      // add #12462 患者情報共有 Ji end
      // 起票者
      this.setRegUserName();
      // 回診日時
      //mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      //this.setRegDateTime();
      await this.setRegDateTime();
      //mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      // add #10593 NG マージ後，回診記録タイトル値がありません zhangyue start
      this.saveRoundType();
      // add #10593 NG マージ後，回診記録タイトル値がありません zhangyue end
      // 内容
      this.setContent();
      // 指示者
      this.setIndUser();
      // 指示コメントに転記
      this.setIndCommentPost();
      // 指示コメント番号
      this.setRstIndCommentNo();
      // 転記区分(0:継続、1:当日のみ)
      this.setPostingClass();
      // 更新者
      this.setCreateUserName();
      // add FNSI-修正 権限関連 トウ start
      this.setRstCommentPost();
      // add FNSI-修正 権限関連 トウ end
      // ord_main情報取得
      //add 9724 ljx start コンソールError修正
      if(this.getOrdNo){
        this.getTreatmentRecordAddition(this.getOrdNo).then(response => {
          // 施設コード
          this.commentInfo.facilityCd = response.data.facility_cd;
          // 患者ID
          this.commentInfo.patId = response.data.pat_id;
          // クールコード
          this.commentInfo.rstKurCd = response.data.rst_kur_cd;
          // 治療方法コード
          this.commentInfo.rstTreatmentCd = response.data.rst_treatment_cd;
          // 治療日
          this.commentInfo.treatDate = response.data.treat_date;
        });
      }
      //add 9724 ljx END コンソールError修正
      // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
      const matchingRoundTypes = this.roundTypes.find(item => item.round_type_cd == this.rstRoundsInfo.inProgress.round_type_cd && item.round_type_name !=  this.rstRoundsInfo.inProgress.round_type_name);
      //mod 9724-⑤　ljx start
      if (matchingRoundTypes) {
        this.roundTypes.unshift({
          round_type_cd: this.rstRoundsInfo.inProgress.round_type_cd,
          round_type_name: this.rstRoundsInfo.inProgress.round_type_name,
          content: matchingRoundTypes.content,
          is_content_omission: matchingRoundTypes.is_content_omission,
          comment_post_default: matchingRoundTypes.comment_post_default,
          posting_class_default: matchingRoundTypes.posting_class_default,
          hidden: true
        });
      }
      if(!this.rstRoundsInfo.inProgress.round_type_cd && this.rstRoundsInfo.inProgress.round_type_name){
        this.roundTypes.unshift({
          round_type_cd: this.rstRoundsInfo.inProgress.round_type_cd,
          round_type_name: this.rstRoundsInfo.inProgress.round_type_name,
          content: this.rstRoundsInfo.inProgress.content,
          is_content_omission: this.rstRoundsInfo.inProgress.is_content_omission,
          comment_post_default: this.rstRoundsInfo.inProgress.comment_post_default,
          posting_class_default: this.rstRoundsInfo.inProgress.posting_class_default,
          hidden: true
        });
      }
      //mod 9724-⑤　ljx end
      // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end

      // 初期状態を保持
      this.rstRoundsInfo.toCompare = this.rstRoundsInfo.inProgress.copy();
      // add FNSI-改修内容textareaの高 徐 start
      this.$nextTick(() => {
        this.resizeTAMain();
      });
      // add FNSI-改修内容textareaの高 徐 end
      this.initialContent = this.content;
      this.initialRoundDate = this.roundDate;
      this.initialRoundTime = this.roundTime;
      this.alertFlag = true;
    },
    /**
     * YEDの指示コメント更新APIに渡すパラメータJSONを生成する.
     * @param {Number} commentFlag コメントフラグ(1：新規、2：編集、それ以外：削除) constants/TreatmentRecord#COMMENT_FLAG参照
     * @param {boolean} isDeadline true（期限付き）、false（無期限）
     */
    createIndCommentParameter(commentFlag, isDeadline) {
      const endDate = isDeadline ?
        this.commentInfo.treatDate :
        (() => {
          // 無期限の場合、`本日＋１年－1日`
          const d = moment();
          d.add("years", 1);
          //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao start
          //d.subtract('days', 1);
          d.endOf("month")
          //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao end
          return d.format("YYYYMMDD");
        })();
      return {
        comment_flag: commentFlag,
        pat_id: this.commentInfo.patId,
        facility_cd: this.commentInfo.facilityCd,
        start_date: this.commentInfo.treatDate,
        end_date: endDate,
        num_comment: this.rstRoundsInfo.inProgress.ind_comment_no,
        comment: this.rstRoundsInfo.inProgress.content,
        weeks: '[{"text":"全","done":true,"value":0}]',
        ind_kur_cd: '[' + this.commentInfo.rstKurCd + ']',
        ind_treatment_cd: '[' + this.commentInfo.rstTreatmentCd + ']',
        ind_user_id: this.rstRoundsInfo.inProgress.ind_user_id,
        upd_user_id: this.accountInfo.userId,
        is_deadline: isDeadline,
        //add FNSI修正484改修 房 start
        is_rst_update: true,
        //add FNSI修正484改修 房 end
        //add FNSI-redmine6539 fang start
        ord_no: this.getOrdNo,
        //add FNSI-redmine6539 fang end
        //add FNSI-redmine8338 ljx start
        //指示コメントの更新は共用するため、回診記録から指示コメントへ転記する場合、フラグを追加、実績のみに更新
        ind_rst_flag: "rst"
        //add FNSI-redmine8338 ljx end
      };
    },
    /**
     * 再描画処理
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      this.init();
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    eventBusRefresh() {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      if (this.isChanged && this.alertFlag) {
        this.discardConfirm(this.init);
      } else if (this.isNewRoundInfo && this.alertFlag) {
        this.discardConfirm(this.init);
      } else {
        this.init();
      }
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    setContentData(newValue) {
      this.content = newValue;
      this.onContent();
    },
    //add メッセージ順番修正 房 start
    getChangeStatus(){
      return !this.isEditable;
    },
    updateChangeStatus(){
      this.alertFlag = false;
    },
    //add メッセージ順番修正 房 end
    // add FNSI-横展開 日付のチェックの追加 徐 start
    showMsg() {
        let saveButtonErrorFlg = {
            name: "roundDate",
            id: "roundDate",
            scope: "roundDate"
          };
      if (this.roundDate && document.getElementById("roundDate").validationMessage) {
        this.showErrorDate = true;
        this.$validator.errors.items.push(saveButtonErrorFlg);
      } else {
        this.showErrorDate = false;
        this.$validator.errors.removeById("roundDate");
      }
    }
    // add FNSI-横展開 日付のチェックの追加 徐 end
  },
  async created() {
    await this.init();
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // イベント登録
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // EventBus.$on("refresh", this.refresh);
    EventBus.$on("refresh", this.eventBusRefresh);
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
  },
   mounted() {
    this.ro = new ResizeObserver(this.resizeTAH);
    this.ro.observe(document.getElementById("round-component"));
  },
  beforeDestroy() {
    this.ro.disconnect();
    this.ro = null;
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // EventBus.$off("refresh", this.refresh);
    EventBus.$off("refresh", this.eventBusRefresh);
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    this.setIsPatInfoChaned(false);
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
  },
  // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
  beforeRouteLeave(to, from, next) {
    if (
      this.isNewRoundInfo && this.isPatInfoChaned && this.isTextareaChanged
    ) {
      this.discardConfirmInner(next);
    } else {
      next();
    }
  }
  // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
};
</script>

<style scoped>
.treatment-record-accordion ons-row {
  height: auto;
}
ons-select {
  min-width: 11em;
}
.selectbox {
  width: 50%;
  height: 2em;
}
label {
  color: var(--treatment-record-text-color);
}
#round-component {
  height: inherit;
}
.controll-wrapper {
  height: 100%;
  width: 100%;
}
#content {
  width: 60em;
  height: 60em;
  margin: 0 auto 0 1em;
}
#note-wrapper {
  height: 35em;
}
.note {
  font-size: 0.8em;
}
#reg-date-wrapper {
  height: 8em;
}
#reg-date-time {
  width: 25em;
}
#ind-user-wrapper {
  height: 5em;
}
.ind-user-selector {
  margin-top: 0.5em;
  width: 15em;
}
.ind-user-selector .selectbox {
  width: 100%;
}
#reg-user-wrapper,
#selected-category-wrapper {
  height: 7em;
}
#reg-user, #selected-category {
  font-size: 1.8em;
  color: var(--treatment-record-text-color);
}
#ind-comment-post-controll {
  display: grid;
  width: 100%;
  height: 100%;
  grid-template-columns: 50% 50%;
  grid-template-rows: 50% 50%;
}
#ind-comment-no-selector {
  display: inline;
  margin-left: 1em;
}
.selected-rst-ind-comment-no {
  margin-left: 1em;
}
#posting-class {
  margin-left: 3.0em;
}
#posting-class label {
  margin-left: 0.5em;
  margin-right: 2em;
}
.disabled-label-color {
  color: var(--treatment-record-text-color-disabled) !important;
}
ons-input >>> .text-input {
  color: var(--treatment-record-input-color);
  background-color: var(--treatment-record-input-background-color);
}
.delete {
  margin-left: 2em;
  margin-right: 2em;
}
@media screen and (max-width:450px) {
  .delete {
    margin-left: 0.3em;
    margin-right: 0;
  }
}
label {
  color: var(--treatment-record-text-color);

}
/**
 * 内容部のスタイル定義
 */
.com-textarea {
  font-family: inherit;
}
.scroll-treatment-record {
  overflow-x: auto;
}
/* add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue start */
.custom-textarea-edited >>> textarea {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.selected-item {
  color:green;
}
/* add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 zhangyue end */
.custom-input-edited >>> select {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.custom-input-edited >>> input {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.time-input-edited {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
#round-component {
  overflow: auto;
}
.round-posting-chk span:not(:first-child) {
  margin-left: 1em;
}
@media print {
  /** テキストエリアのページ跨ぎを可能とする */
  .treatment-record-accordion {
    display: inline-block;
  }
  /** テキストエリアは印刷用div表示するので非表示 */
  div >>> .custom-textarea {
    display: none !important;
  }
  /** 印刷用divの高さ調整 */
  div >>> .print-textarea {
    min-height: 40vh;
  }
}
</style>
