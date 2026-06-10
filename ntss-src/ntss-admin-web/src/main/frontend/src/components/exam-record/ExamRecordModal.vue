/**
 * 検査結果モーダルPage
 */
 <template>
  <modal-base @onClose="closeExamRecordModal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <div slot="body" class='kendo-grid-style-page-modal'>
      <!-- mod FNSI-Fixed header 関 start -->
      <!-- <div id="examrecordmodal-header"> -->
      <div id="examrecordmodal-header" style="margin-bottom: 5px;">
      <!-- mod FNSI-Fixed header 関 end -->
        <v-ons-row style="height: auto; ">
          <v-ons-col class="exam-record-head color-header" @click="isExamCondVisible = !isExamCondVisible">
            <label class='label-text'>検査記録</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="height: auto;" v-show="isExamCondVisible">
          <v-ons-col width='7em' vertical-align='center'>
            <label class='label-text'>検査日時</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <!--mod 編集権限の適用 劉全航 start-->
            <!-- <input
              input-id='examDate'
              name='examDate'
              type='date'
              float
              style="width:auto;"
              min='1880-01-01'
              model-event="change"
              v-model='examDate'
              v-validate="'required|date_format:yyyy-MM-dd'"
              :max="calendarToday"
              class ='modalInput ntss-input-date'/> -->
              <!-- <common-calendar v-model="examDate"/> -->
            <div style="display: flex; flex-wrap: nowrap;">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <date-input -->
              <!--   v-model="examDate" -->
              <!--   model-event="change" -->
              <!--   input-id='examDate' -->
              <!--   name='examDate' -->
              <!--   :classes="'ntss-input-date date-input-focus date-input-required ' +isEdited('examDate')" -->
              <!--   :disabled="!editAuthority" -->
              <!--   isRequired -->
              <!--   @change="setDataChanged" -->
              <!-- /> -->
              <!-- <common-calendar v-model="examDate" :disabled="!editAuthority" /> -->
              <date-input
                v-model="examDate"
                model-event="change"
                input-id='examDate'
                name='examDate'
                :classes="'ntss-input-date date-input-focus date-input-required ' +isEdited('examDate')"
                :disabled="!getItemAuthorized('ExamRecord', 'default_authority')"
                isRequired
                @change="setDataChanged"
              />
              <common-calendar v-model="examDate" :disabled="!getItemAuthorized('ExamRecord', 'default_authority')" />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!--mod 編集権限の適用 劉全航 end-->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <time-input -->
              <!--   v-model="examTime" -->
              <!--   model-event="change" -->
              <!--   input-id='examTime' -->
              <!--   name='examTime' -->
              <!--   :classes="'time-input-focus time-input-required ' +isEdited('examTime')" -->
              <!--   :disabled="!editAuthority" -->
              <!--   isRequired -->
              <!--   @change="setDataChanged" -->
              <!-- /> -->
              <time-input
                v-model="examTime"
                model-event="change"
                input-id='examTime'
                name='examTime'
                :classes="'time-input-focus time-input-required ' +isEdited('examTime')"
                :disabled="!getItemAuthorized('ExamRecord', 'default_authority')"
                isRequired
                @change="setDataChanged"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </div>
          </v-ons-col>
        </v-ons-row>
        <!-- del FNSI-remove item  関 start -->
        <!-- <v-ons-row v-if="getModalState !== 1">
          <v-ons-col width='7em' vertical-align='center'>
            <label class='label-text'>透析連動</label>
          </v-ons-col>
          <v-ons-col width='7em' >
            <v-ons-switch input-id='examPatCoop' v-model="examPatCoop" v-bind:disabled="getModalState === 1" @change="patCoopChange">
          </v-ons-switch>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-select input-id='examPatList' v-model="examSelectPat" v-bind:disabled="getModalState === 1 || examPatCoop == false || isDisabled" class = 'modalInput' @change = "selectPatChange">
              <option :value="defaultSelect"></option>
              <option v-for='(option) in getExamPatList' :key=option.ordNo :value=option.ordNo>
                {{ option.rstListName }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row> -->
        <!-- del FNSI-remove item  関 end -->
        <v-ons-row style="height: auto;" v-show="isExamCondVisible">
          <v-ons-col width='7em' vertical-align='center'>
            <label class='label-text'>検査区分</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <!--mod 編集権限の適用 劉全航 start-->
            <!-- <v-ons-select input-id='examDivList' v-model="examSelectDiv" class = 'modalInput'  name="examDivList" v-validate="'required|min:0'">
              <option :value="defaultSelect"></option>
              <option v-for='(option) in getExamDivList' :key=option.examOrderCode :value=option.examOrderCode >
                {{ option.examOrderName }}
              </option>
            </v-ons-select> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-select -->
            <!-- input-id='examDivList' -->
            <!-- v-model="examSelectDiv" -->
            <!-- class = 'modalInput' -->
            <!-- name="examDivList" -->
            <!-- v-validate="'required|min:0'" -->
            <!-- @change="setDataChanged" -->
            <!-- :disabled="!editAuthority"> -->
            <v-ons-select
              input-id='examDivList'
              v-model="examSelectDiv"
              class = 'modalInput'
              name="examDivList"
              v-validate="'required|min:0'"
              @change="setDataChanged"
              :disabled="!getItemAuthorized('ExamRecord', 'default_authority')">
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <option :value="defaultSelect"></option>
              <option v-for='(option) in getExamDivList'
              :key="option.examOrderCode"
              :value="option.examOrderCode">
                {{ option.examOrderName }}
              </option>
            </v-ons-select>
            <!--mod 編集権限の適用 劉全航 end-->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="height: auto;" v-show="isExamCondVisible">
          <v-ons-col vertical-align='center' width='7em'>
            <label class='label-text'>表示セット</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-select input-id='examSetCd' v-model="localCondition.examSetCd" class='modalInput' @change='dialogOkNew'>
                <option :value="defaultSelect">全項目</option>
                <!-- mod FNSI-削除されたグループを隠す 関 start -->
                <!-- <option v-for='(option, index) in getExamSetNameList' :key=option.length :value=index>
                  {{ option.examSetName }}
                </option> -->
                <template  v-for='option in getExamSetNameList'>
                  <option v-if='option.isDisp == 1' :value="option.examSetCd" :key="option.length">
                    {{ option.examSetName }}
                  </option>
                </template>
                <!-- mod FNSI-削除されたグループを隠す 関 start -->
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="height: auto;" v-show="isExamCondVisible">
          <div style="display: flex; justify-content: start; align-items: center; min-width: 11em; width: 18em;">
            <label class='label-text' style="margin-right: 0.5em;">結果なし行表示</label>
            <v-ons-switch input-id="allDataFlg" v-model="localCondition.allDataFlg" @change='checkAll'></v-ons-switch>
          </div>
          <div style="display: flex; justify-content: start; align-items: center; min-width: 11em;">
            <label class='label-text' style="margin-right: 1.5em;">正常範囲表示</label>
            <v-ons-switch input-id="switchPatId" v-model="localCondition.normalRange" @change='changeNormalRange'></v-ons-switch>
          </div>
        </v-ons-row>
      </div>

      <!-- 検査結果のグリッド -->
      <!-- mod #9461  by zhangruixue 2023-08-17 --start -->
      <div id='examrecordgrid' :style="{'overflow-y':'auto','position':'relative','top':'0'}">
        <!-- mod #9461  by zhangruixue 2023-08-17 --end -->
        <!-- mod FNSI-入力欄右側にスピナー表示 関 start -->
        <kendo-grid class='exam-item exam-height-0' style="border: 0px;"
          ref='examrecordgrid'
          :data-source='ExamMainDataSource'
          :editable='true'
          :reorderable='false'
          :resizable='true'
          :selectable='"cell"'
          :height="examrecordGridHeight"
          :scrollable="true"
          :beforeEdit="editStart"
          :cellClose="editEnd"
          :edit="changes"
          :data-bound="setFontColor"
          @save="onSave">
        <div v-for='category in ExamMainColumns' :key="category.title">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <kendo-grid-column -->
          <!--   :headerTemplate='category.headerTemplate' -->
          <!--   :title='category.title' -->
          <!--   :width='category.width' -->
          <!--   :field='category.field' -->
          <!--   :columns='category.columns' -->
          <!--   :hidden='category.hidden' -->
          <!--   :locked='category.locked' -->
          <!--   :editable='category.editable || isDisabled' -->
          <!--   :lockable='category.lockable' -->
          <!--   :editor="category.title === '検査データ' ? editorInputCheckData : editorInputComment" -->
          <!--   > -->
          <kendo-grid-column
            :headerTemplate='category.headerTemplate'
            :title='category.title'
            :width='category.width'
            :field='category.field'
            :columns='category.columns'
            :hidden='category.hidden'
            :locked='category.locked'
            :editable="category.editable || getItemAuthorized('ExamRecord', 'default_authority')"
            :lockable='category.lockable'
            :editor="category.title === '検査データ' ? editorInputCheckData : editorInputComment"
            >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </kendo-grid-column>
          <!-- <kendo-grid-column v-else
            :key="category.length"
            :headerTemplate='category.headerTemplate'
            :title='category.title'
            :width='category.width'
            :field='category.field'
            :columns='category.columns'
            :hidden='category.hidden'
            :locked='category.locked'
            :editable='category.editable || isDisabled'
            :lockable='category.lockable'
            >
          </kendo-grid-column> -->
        </div>
        </kendo-grid>
        <div class="scroll-area" style="width: 100%;">
          <table class="scroll-table-data" style="width: 100%;">
            <thead>
              <tr>
                <template v-for="(value) in ExamMainColumns">
                  <!-- add FNSI-Fixed header 関 start -->
                  <!-- <th v-if="value.hidden == null || value.hidden != true" class="ntss-list-header-th-sticky" :key="value.title"> -->
                  <th v-if="value.hidden == null || value.hidden != true" class="top-fix" :key="value.title">
                  <!-- add FNSI-Fixed header 関 end -->
                    {{value.title}}
                  </th>
                </template>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(value,index) in allTableData._data" :key="value.itemCd">
                <template v-for="col in ExamMainColumns">
                  <td v-if="(col.hidden == null || col.hidden != true) && (localCondition.allDataFlg || changeDataArray[value.itemCd])" :key="col.title" class="exam-table-td">
                    <template v-if="col.title == '検査データ'">
<!--                      #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start-->
<!--                      <input-->
<!--                      v-if="value.type == 1"-->
<!--                      :key="refreshFlag"-->
<!--                      type="number"-->
<!--                      :step="getStep(value.itemCd)"-->
<!--                      inputmode="numberic"-->
<!--                      v-model="dataArray[value.itemCd]"-->
<!--                      :disabled="value.examClass!=0 || !editAuthority"-->
<!--                      class="exam-table-input"-->
<!--                      @focus="handleFocus(index)"-->
<!--                      @mousewheel.prevent="wheelChangeValue($event,value.itemCd, value.examClass!=0 || !editAuthority, index)"-->
<!--                      @change="setDataChanged(value.itemCd)"-->
<!--                      @blur="handleBlur($event, value.itemCd,index)"-->
<!--                      @keydown="preventPlusSymbol"-->
<!--                      :class="is_edit(value.itemCd)"-->
<!--                      >-->
                      <!-- mod #10359 編集権限の動作不正 dengshen start -->
                      <!-- <input -->
                      <!--   v-if="value.type == 1" -->
                      <!--   :key="refreshFlag" -->
                      <!--   type="number" -->
                      <!--   :step="getStep(value.itemCd)" -->
                      <!--   inputmode="numberic" -->
                      <!--   v-model="dataArray[value.itemCd]" -->
                      <!--   :disabled="value.examClass!=0 || !editAuthority" -->
                      <!--   class="exam-table-input" -->
                      <!--   @focus="handleFocus(index)" -->
                      <!--   @click="setDataChanged(value.itemCd)" -->
                      <!--   @mousewheel.prevent="wheelChangeValue($event,value.itemCd, value.examClass!=0 || !editAuthority, index)" -->
                      <!--   @change="setDataChanged(value.itemCd)" -->
                      <!--   @blur="handleBlur($event, value.itemCd,index)" -->
                      <!--   @keydown="preventPlusSymbol" -->
                      <!--   :class="is_edit(value.itemCd)" -->
                      <!-- > -->
                      <input
                        v-if="value.type == 1"
                        :key="refreshFlag"
                        type="number"
                        :step="getStep(value.itemCd)"
                        inputmode="numberic"
                        v-model="dataArray[value.itemCd]"
                        :disabled="value.examClass!=0 || !getItemAuthorized('ExamRecord', 'default_authority')"
                        class="exam-table-input"
                        @focus="handleFocus(index)"
                        @click="setDataChanged(value.itemCd)"
                        @mousewheel.prevent="wheelChangeValue($event,value.itemCd, value.examClass!=0 || !getItemAuthorized('ExamRecord', 'default_authority'), index)"
                        @change="setDataChanged(value.itemCd)"
                        @blur="handleBlur($event, value.itemCd,index)"
                        @keydown="preventPlusSymbol"
                        :class="is_edit(value.itemCd)"
                      >
                      <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                      #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end-->
                      <!-- mod #5589 2023/04/12 数値IFのスタイル全不正 林峻峰 end -->
                      <!-- mod 検査結果入力文字列、保存後は表示されない 商 start -->
                      <!-- <input
                      v-else-if="value.type == 0"
                      :key="refreshFlag"
                      type="text"
                      :value="dataArray[value.itemCd]"
                      :disabled="value.examClass!=0 || !editAuthority"
                      class="exam-table-input exam-table-input-right"
                      @change="setDataChanged"
                      :class="is_edit(value.itemCd)"
                      > -->
                      <!-- mod #10359 編集権限の動作不正 dengshen start -->
                      <!-- <input -->
                      <!-- v-else-if="value.type == 0" -->
                      <!-- :key="refreshFlag" -->
                      <!-- type="text" -->
                      <!-- v-model="dataArray[value.itemCd]" -->
                      <!-- :disabled="value.examClass!=0 || !editAuthority" -->
                      <!-- class="exam-table-input exam-table-input-right" -->
                      <!-- @change="setDataChangedForText(value.itemCd)" -->
                      <!-- :class="is_edit(value.itemCd)" -->
                      <!-- > -->
                      <input
                        v-else-if="value.type == 0"
                        :key="refreshFlag"
                        type="text"
                        v-model="dataArray[value.itemCd]"
                        :disabled="value.examClass!=0 || !getItemAuthorized('ExamRecord', 'default_authority')"
                        class="exam-table-input exam-table-input-right"
                        @change="setDataChangedForText(value.itemCd)"
                        :class="is_edit(value.itemCd)"
                      >
                      <!-- mod #10359 編集権限の動作不正 dengshen end -->
                      <!-- mod 検査結果入力文字列、保存後は表示されない 商 end -->
                      <!--mod 編集権限の適用 劉全航 end-->
                    </template>
                    <template v-else-if="col.title == 'コメント'">
                      <!--mod FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 start-->
                      <!-- <input
                      type="text"
                      v-model="commentArray[value.itemCd]"
                      class="exam-table-input"
                      > -->
                      <!--mod FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 end-->
                      <!--//mod 編集権限の適用 劉全航 start-->
                      <!-- <com-textarea
                      class="exam-commentTextarea"
                      cssClass="textarea textarea--transparent textarea-resize-vertical"
                      propMaxlength="256"
                      :idTextarea="'com-textarea-taboo-allergy-memo'+value.itemCd"
                      :content="commentArray[value.itemCd]"
                      @set-content-data="setContentData($event,value.itemCd)"
                      /> -->
                      <!-- add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi start -->
                      <!-- mod #10359 編集権限の動作不正 dengshen start -->
                      <!-- <com-textarea -->
                      <!-- class="exam-commentTextarea" -->
                      <!-- cssClass="textarea textarea--transparent textarea-resize-vertical" -->
                      <!-- propMaxlength="256" -->
                      <!-- :idTextarea="'com-textarea-taboo-allergy-memo'+value.itemCd" -->
                      <!-- :content="commentArray[value.itemCd]" -->
                      <!-- @change="setDataChanged" -->
                      <!-- @set-content-data="setContentData($event,value.itemCd)" -->
                      <!-- :disabled="!editAuthority" -->
                      <!-- /> -->
                      <com-textarea
                        class="exam-commentTextarea"
                        cssClass="textarea textarea--transparent textarea-resize-vertical"
                        propMaxlength="256"
                        :idTextarea="'com-textarea-taboo-allergy-memo'+value.itemCd"
                        :content="commentArray[value.itemCd]"
                        @change="setDataChanged"
                        @set-content-data="setContentData($event,value.itemCd)"
                        :disabled="!getItemAuthorized('ExamRecord', 'default_authority')"
                      />
                      <!-- mod #10359 編集権限の動作不正 dengshen end -->
                      <!-- add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi end -->
                      <!--mod 編集権限の適用 劉全航 end-->
                    </template>
                    <template v-else>
                      {{ value[col.field] }}
                    </template>
                  </td>
                </template>
              </tr>
            </tbody>
          </table>
        </div>
        <!-- mod FNSI-入力欄右側にスピナー表示 関 end -->
      </div>
    </div>

    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" style="min-width: 4em;" @click="cancelModal" data-non-authorize="true">キャンセル</v-ons-button>
        <!--mod 編集権限の適用 劉全航 start-->
        <!-- <span @click="deleteExamRecord" v-if="getModalState === 1"> -->
          <span v-if="getModalState === 1">
          <!-- <v-ons-button class="button registration-btn"  style="min-width: 4em;margin-left: 0.3em;" :disabled="!canDelete">削除</v-ons-button> -->
        <!-- FNSI6576-職種マスタで削除権限がない時の各画面の対応内容がバラバラ 周 mod start -->
        <!--
        <v-ons-button
        @click="deleteExamRecord"
        class="button registration-btn btn4-alert"
        style="min-width: 4em;margin-left: 0.3em;"
        :disabled="!canDelete || !editAuthority">
        削除
        </v-ons-button>
       -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!-- v-if="canDelete && editAuthority" -->
        <!-- @click="deleteExamRecord" -->
        <!-- class="button registration-btn btn4-alert" -->
        <!-- style="min-width: 4em;margin-left: 0.3em;"> -->
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   v-if="getItemAuthorized('ExamRecord', 'item_delete_btn')" -->
        <!--   @click="deleteExamRecord" -->
        <!--   class="button registration-btn btn4-alert" -->
        <!--   style="min-width: 4em;margin-left: 0.3em;"> -->
        <v-ons-button
          @click="deleteExamRecord"
          class="button registration-btn btn4-alert"
          :style="{ 'opacity': this.getItemAuthorized('ExamRecord', 'item_delete_btn') ? 1 : 0.6}"
          style="min-width: 4em;margin-left: 0.3em;">
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        削除
        </v-ons-button>
        <!-- FNSI6576-職種マスタで削除権限がない時の各画面の対応内容がバラバラ 周 mod end -->
        <!--mod 編集権限の適用 劉全航 end-->
        </span>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!--mod 編集権限の適用 劉全航 start-->
        <!-- mod #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi start -->
        <!-- mod #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220729 zhaoqi start -->
        <!-- <v-ons-button class="button registration-btn" style="min-width: 4em;" @click="saveExamRecordPre" :disabled="!editState || isDisabled">確定</v-ons-button> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!-- class="button registration-btn btn3-normal" -->
        <!-- style="min-width: 4em;" -->
        <!-- @click="saveExamRecordPre" -->
        <!-- :disabled="!editState || !editAuthority"> -->
        <v-ons-button
          class="button registration-btn btn3-normal"
          style="min-width: 4em;"
          @click="saveExamRecordPre"
          :disabled="!editState || !getItemAuthorized('ExamRecord', 'default_authority')">
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--        :disabled="!editState || !editAuthority || !this.isDataChanged">-->
        保存
        </v-ons-button>
        <!-- mod #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220729 zhaoqi end -->
        <!-- mod #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi end -->
        <!--mod 編集権限の適用 劉全航 end-->
      </div>
      <!-- キャンセル確認ダイアログ -->
      <message-dialog
        :visible.sync="dialogVisible"
        :message-cd="20010001"
        type="2"
        @confirm="confirmCancel"
      />
      <!-- マージ確認ダイアログ -->
      <message-dialog
        :visible.sync="mergeDialogVisible"
        :message-cd="74000004"
        type="2"
        @confirm="confirmMerge"
      />
      <message-dialog
        v-if="isCheckDialogVisible"
        :visible.sync="isCheckDialogVisible"
        :message-cd="messageCd"
        :string-params="stringParams"
        type="1"
      />

    </div>
  </modal-base>
</template>

<script>
  import Kendo from "@progress/kendo-ui";
  import ModalBase from "@/components/modals/ModalBase";
  import {mapActions, mapGetters, mapMutations} from "vuex";
  import {EventBus} from "@/eventBus.js";
  import moment from "moment";
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  import $$ from "jquery";
  // mod #10359 編集権限の動作不正 dengshen start
  // import {deepCopy} from "@/functions/common/CommonFunctions";
  import { deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
  // mod #10359 編集権限の動作不正 dengshen end
  // del #10359 編集権限の動作不正 dengshen start
  // import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
  // del #10359 編集権限の動作不正 dengshen end
  // del #10359 編集権限の動作不正 dengshen start
  // import {AUTHORITY_CODES} from "@/constants/userAuthority";
  // del #10359 編集権限の動作不正 dengshen end
  // add FNSI-NO504-冗長なjsonデータを削除する 関 start
  import {
    deleteRefresh,
    sendRequestClearExamResultInfo,
    sendRequestDeletePatExamMain,
    sendRequestGetExistOrder,
    sendRequestGetExistResult,
    sendRequestGetMstExamItemList,
    sendRequestGetPatExamMainByExamMainCd,
    sendRequestGetPatExamMainDetailList
  } from "@/apis/exam-Record";
  // add FNSI-NO504-冗長なjsonデータを削除する 関 end
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  // add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 start
  import CommonTextArea from "@/components/common/CommonTextArea";
  // add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 end
  //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 start
  import {createJournal} from "@/apis/journal";
  //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 end
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
  import { getCurrentFunctionCd } from "@/router/routing-helper";
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 END
  // add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi start
  import store from "@/stores";
  // add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi end
  // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
  import {DISP_ORDER_LEFT_PAST} from "@/constants/examRecordConstants";
  import DateInput from "@/components/common/DateInput";
  import TimeInput from "@/components/common/TimeInput";
  import { findExamSet, getNormalValueKeys } from "@/functions/exam-record/ExamRecordFunctions";

export default {
  // del #10359 編集権限の動作不正 dengshen start
  // mixins: [UserAuthorityMixin],
  // del #10359 編集権限の動作不正 dengshen end
  name: "ExamRecordModal",
  components: {
    "modal-base": ModalBase,
    "message-dialog": messageDialog,
    "common-calendar": commonCalender
    // add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 start
    ,"com-textarea": CommonTextArea,
    // add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 end
    "date-input": DateInput,
    "time-input": TimeInput
  },
  beforeRouteLeave(to, from, next) {
    if(to.fullPath.indexOf("exam-record") > -1){
      // 遷移先が検査結果系画面：初期化しない
    }else{
      // 遷移先が検査結果系画面以外：listを初期化
      this.modalStoreReset();
    }
    next();
  },
  data() {
    return {
      main: "",
      header: "",
      examrecordGridToolbarHeight: 500,
      examrecordGridHeight: 300,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      // 抽出条件
      localCondition: {
        examSetCd: -1,
        normalRange: true,
        allDataFlg: true
      },
      // 登録日付/時刻
      examDate: "",
      today:"",
      examTime: "",
      examDivList: null,
      examSelectDiv: -1,
      comparisonModel: null,
      // 透析実績連動スイッチ
      examPatCoop: false,
      // 過去透析リスト
      examPatList: null,
      examSelectPat:-1,
      dialogVisible: false,
      isCheckDialogVisible: false,
      stringParams: null,
      messageCd: null,
      mergeDialogVisible: false,
      isExistResult: false,
      isExistOrder: false,
      mergeBaseExamResultlist:[{
          mergeTargetExamMainCd: 0,
          mergeBaseExamResult: ""
      }],
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // isDataChanged: false,
      // isInitFinished: false,
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
      // add FNSI-入力欄右側にスピナー表示 関 start
      allTableData: [],
      dataArray: {},
      // add FNSI-Add Edit Style 関 start
      oldDataArray: {},
      // add FNSI-Add Edit Style 関 start
      // add #7697 【デグレ】検査データをdelキーで削除すると項目が非表示になる 鄭爽 start
      changeDataArray: {},
      // add #7697 【デグレ】検査データをdelキーで削除すると項目が非表示になる 鄭爽 end
      // add FNSI-整数ビットと小数ビットの検証 関 start
      classArray: {},
      inputDecimalFigureArray: {},
      inputIntegerFigureArray: {},
      // add FNSI-整数ビットと小数ビットの検証 関 end
      commentArray: {},
      dataArrayMax: {},
      dataArrayMin: {},
      openPageExamDate:null,
      openPageExamTime:null,
      openPageExamSelectDiv:null,
      // add FNSI-入力欄右側にスピナー表示 関 end
      // add FNDI-FIXBUG 最新の小数点以下の桁数を使用 関 start
      examItemMap: {}
      // add FNDI-FIXBUG 最新の小数点以下の桁数を使用 関 end
      // del #10359 編集権限の動作不正 dengshen start
      // //mod 編集権限の適用 劉全航 start
      // ,editAuthority: null
      // //mod 編集権限の適用 劉全航 end
      // del #10359 編集権限の動作不正 dengshen end
      ,isExamCondVisible: true,
      // mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false,
      focusFlg: [],
      // mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
      refreshFlag: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      ignoreCompareData: false,
      initexamSetCd: -1
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPat","selectedPatId","selectedPatSex"]),
    // mod FNSI-NO504-冗長なjsonデータを削除する 関 start
    // ...mapGetters("exam-record/list", ["getExamSetNameList","getExamDefaultSex"]),
    ...mapGetters("exam-record/list", [
      "getExamSetNameList",
      "getExamDefaultSex",
      "getExamRecordColumn",
      "getExamResultDispOrder",
    ]),
    // mod FNSI-NO504-冗長なjsonデータを削除する 関 end
    ...mapGetters("exam-record/modal", [
      "getSelectExamRecordSetting",
      "getSelectExamrecord",
      "getExamDivList",
      "getExamMainDataSource",
      "getExamMainData",
      "getExamMainColumn",
      "getModalState",
      "getExamDate",
      "getExamTime",
      "getExamSelectDiv",
      "getModalCondition",
      "getExamPatList",
      "getExamMainCd",
    ]),
    condition: {
      get() {
        return this.getModalCondition;
      }
    },
    // グリッドの編集状態
    editState() {
      //一つでも項目が編集されていると入力可能
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // let rEdit =
      //   this.$validator.errors.items.length === 0
      //   && this.examDate !== null
      //   && this.examTime !== null
      //   && this.examSelectDiv >= 0
      //   && this.authorized
      // return rEdit;
      let examMainData = [];
      if (!!this.ExamMainDataSource._data) {
        let copyExamMainData = JSON.parse(JSON.stringify(this.ExamMainDataSource._data));
        for (const key in copyExamMainData) {
          if (copyExamMainData.hasOwnProperty(key)) {
            const currentObject = copyExamMainData[key];
            if (currentObject.result !== '' && currentObject.result !== null || currentObject.freememo !== '' && currentObject.freememo !== null) {
              examMainData.push(currentObject);
            }
          }
        }
      }
      let comparisonModelData = [];
      if (!!this.comparisonModel) {
        comparisonModelData = JSON.parse(this.comparisonModel).filter(item => {
          return item.result !== '' && item.result !== null || item.freememo !== '' && item.freememo !== null;
        });
      }
      let rEdit =
          // mod #10359 編集権限の動作不正 dengshen start
          // this.$validator.errors.items.length === 0 && this.authorized && (
          this.$validator.errors.items.length === 0 && this.getItemAuthorized('ExamRecord', 'default_authority') && (
          // mod #10359 編集権限の動作不正 dengshen end
              examMainData && comparisonModelData && JSON.stringify(examMainData) != JSON.stringify(comparisonModelData)
              || this.openPageExamDate != this.examDate || this.openPageExamTime != this.examTime
              || this.openPageExamSelectDiv != this.examSelectDiv || this.initexamSetCd != JSON.stringify(this.localCondition.examSetCd)
          )
      return rEdit;
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    },
    // グリッド表示用検査結果データ
    ExamMainDataSource() {
      // mod FNSI-fix Bug 関 start
      // let dataSource = this.getModalState === 0 ? this.getExamMainDataSource.filter(e => e.facilityCd === this.getFacilityCd) : this.getExamMainDataSource;
      let dataSource = [];
      if (this.getModalState === 0) {
        if (this.getExamMainDataSource) {
          dataSource = this.getExamMainDataSource.filter(e => e.facilityCd === this.getFacilityCd);
        }
      } else {
        dataSource = this.getExamMainDataSource;
      }
      // let dataSource = this.getModalState === 0 && this.getExamMainDataSource ? this.getExamMainDataSource.filter(e => e.facilityCd === this.getFacilityCd) : this.getExamMainDataSource.filter(e => e.facilityCd === this.getFacilityCd);
      // mod FNSI-fix Bug 関 end
      // storeからデータを取得
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      dataSource.forEach(item => {
        if (!item.hasOwnProperty('result')) {
          item.result = '';
        }
        if (!item.hasOwnProperty('freememo')) {
          item.freememo = '';
        }
      });
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      return new Kendo.data.DataSource({
        data: dataSource
      });
    },
    // grid表示用ColumnData
    ExamMainColumns() {
      return this.getExamMainColumn;
    },

    windowWidth(){
      return this.windowWidth;
    },

    // calendar制御用日付
    calendarToday() {
      // storeからデータを取得
      return this.today;
    },

    defaultSelect: () => -1,

    /**
     * データの編集があるかどうか.
     */
    isConditionChanged() {
      return !(
        JSON.stringify(this.localCondition) ===
        JSON.stringify(this.getModalCondition)
      );
    },

    /**
     * OKボタンがクリックできるかどうか.
     */
    canSave() {
      return this.isConditionChanged ;
    },

    isDisabled() {
      // add FNSi6326既存の検査結果を変更して検査結果画面に戻った時、変更前のまま 周 start
      if(undefined === this.getExamMainDataSource || null === this.getExamMainDataSource) {
        return false;
      }
      // add FNSi6326既存の検査結果を変更して検査結果画面に戻った時、変更前のまま 周 end
      return this.getExamMainDataSource.some(e => e.facilityCd !== this.getFacilityCd) && this.getModalState === 1;
    },
    // del #10359 編集権限の動作不正 dengshen start
    // // 結果削除権限チェック
    // canDelete() {
    //   return (
    //     this.getUserAuthorityCds().includes(AUTHORITY_CODES.DEL_EXAM)
    //   );
    // }
    // del #10359 編集権限の動作不正 dengshen end
  },
  methods: {
    // 内部 テスト検査結果Abl入力内容を記録する時、問題が発生しました。start
    preventPlusSymbol(event) {
      let key = event.key;
      if (key === '+') {
        	event.returnValue = false;
      } else {
        	event.returnValue = true;
      }
    },
    // 内部 テスト検査結果Abl入力内容を記録する時、問題が発生しました。end
    ...mapGetters("multi-modal", ["getAuthorityCds"]),
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("exam-record/modal", [
      "setUserAccountInfo",
      "setModalCondition",
      "getMstPersonalUser",
      "getExamRecordSetting",
      "getOrderMainListByOrdNo",
      "insertExamrecord",
      "updateExamrecord",
      "deleteExamrecord",
      "setExamMainDataSource",
      "setExamMainData",
      "setExamModalColumn",
      "setExamMainColumn",
      "setExamModalDataSource",
      "selectExamData",
      "modalStoreReset",
      "setExamDataSet",
      "setExamAllSet",
      "setExamPatList"
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    ...mapMutations("exam-record/modal", ["setModalState", "setIsOpenFlag"]),
    // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    /*add FNSI-改修内容6326 任 start*/
    ...mapActions("exam-record/list", [
      "setExamDetailSelectData"
    ]),
    /*add FNSI-改修内容6326 任 end*/
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    headerTemplate() {
    },
    // add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 start
    // add #11285 機能帳票の印刷情報対応② 高 start
    getExamSelectNameNew () {
      var examSelectName = "";

      if (this.examSelectDiv == -1) {
        examSelectName = "すべて";
      } else {
        for (var ind = 0; ind < this.getExamDivList.length;ind++) {
          if (this.getExamDivList[ind].examOrderCode == this.examSelectDiv) {
            examSelectName += this.getExamDivList[ind].examOrderName + "・";
          }
        }
        examSelectName = examSelectName.slice(0,-1);
      }

      return examSelectName;
    },
    // add #11285 機能帳票の印刷情報対応② 高 end
    // add 画面印刷プレビューと印刷の実現 吉 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // add #11285 機能帳票の印刷情報対応② 高 start
        var expressCondCd="";
        if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
            expressCondCd = "予定・実績";
          } else {
            if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
              expressCondCd = "予定";
            } else {
              expressCondCd = "実績";
            }
          }
        }
        let kurNames = null;
        if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
          kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
        } else {
          kurNames = "すべて";
        }
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // add #11285 機能帳票の印刷情報対応② 高 end
        // 印刷パラメータを応答
        const condition = this.getCondition;
        const param = {
          patId: this.selectedPatId,
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 start
          //patIds: this.searchedPatList != undefined ? this.searchedPatList.map(({ pat_id }) => pat_id) : null,
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 end
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: moment(this.examDate).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          facilityCd: this.getFacilityCd,
          date: moment(this.examDate).format("YYYY/MM/DD"),
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 start
          fromDate: moment(this.examDate).format("YYYY/MM/DD"),
          toDate: moment(this.examDate).format("YYYY/MM/DD"),
          functionCd:"01801",
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 end
          // add #11285 機能帳票の印刷情報対応② 高 start
          inspectionKbn:this.getExamSelectNameNew(),
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:kurNames,
          patGroups:patGroups,
          selectedExamSetName: this.localCondition.examSetCd != -1
            ? (findExamSet(this.localCondition.examSetCd, this.getExamSetNameList) || {}).examSetName || "すべて"
            : "すべて",
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 吉 end
    setContentData(newValue,index) {
      if (newValue != undefined) {
        for (let examIndex = 0; examIndex < this.ExamMainDataSource._data.length; examIndex++) {
          if (this.ExamMainDataSource._data[examIndex].itemCd == index) {
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
            // this.ExamMainDataSource._data[examIndex].freememo = newValue;
            this.ExamMainDataSource._data[examIndex].freememo = newValue !== '' ? newValue : null;
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
          }
        }
      }
    },

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setDataChanged(itemCd) {
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.isDataChanged = true;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
      if (itemCd) {
        this.checkValue(itemCd)
      }
       // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
    },

    // add 検査結果入力文字列、保存後は表示されない 商 start
    setDataChangedForText(itemCd) {
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.isDataChanged = true;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      if (itemCd) {
        this.checkValueForText(itemCd)
      }
    },
    // add 検査結果入力文字列、保存後は表示されない 商 end

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    // add FNSi5934-検査結果記録画面の数値入力不正 周 start
    getStep(itemCd) {
      let step = 1;

      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      //let decimalFigure = this.examItemMap[itemCd].inputDecimalFigure;
      let decimalFigure = (undefined === this.examItemMap[itemCd] || null === this.examItemMap[itemCd]) ? null
                           : this.examItemMap[itemCd].inputDecimalFigure;
      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
      if (decimalFigure == null || decimalFigure < 0) {
        decimalFigure = 2;
      }
      step = step / Math.pow(10, decimalFigure);

      return step;
    },
    // add FNSi5934-検査結果記録画面の数値入力不正 周 end

    // add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 end
    // add FNSI-Add Edit Style 関 start
    is_edit(item_cd) {
      if (this.dataArray[item_cd] != this.oldDataArray[item_cd]) {
        return "is-input-edit";
      }
      else {
        return "";
      }
    },
    // add FNSI-Add Edit Style 関 end
    // -----------------------------------------
    // 透析実績連携スイッチ押下時イベント
    // -----------------------------------------
    patCoopChange(e) {
      if(e.value){
        //連携スイッチ:ON
        this.examDate = null;
        this.examTime = null;
      }else{
        //連携スイッチ:OFF
      let today = moment(new Date());
      this.examDate = today.format("YYYY-MM-DD");
      this.examTime = today.format("HH:mm");
      this.examSelectPat = -1;
      }
    },
    // マウスホイールイベント処理
    wheelChangeValue(e, itemCd, isLock, index) {
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.isDataChanged = true;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      if (!this.focusFlg[index]) {
        return;
      }
      var max = 0;
      var min = 0;
      let inputUpper = this.examItemMap[itemCd].inputUpper;
      let inputLower = this.examItemMap[itemCd].inputLower;
      let integerFigure = this.examItemMap[itemCd].inputIntegerFigure;
      let decimalFigure = this.examItemMap[itemCd].inputDecimalFigure;
      // 整数桁数 = "NULL" もしくは、整数桁数 < "0"の場合
      if (integerFigure == null || integerFigure < 0) {
        integerFigure = 9;
      }
      // 小数桁数 = "NULL" もしくは、小数桁数 < "0"の場合
      if (decimalFigure == null || decimalFigure < 0) {
        decimalFigure = 2;
      }
      // 入力範囲(上限) = "NULL"の場合
      if (inputUpper == null) {
        // 整数桁数 × 10 - 0.1 × 小数桁数乗
        max = Math.pow(10, integerFigure) - (0.1 ** decimalFigure);
      } else {
        // 入力範囲(上限)
        max = inputUpper;
      }
      // 入力範囲(下限) = "NULL"の場合
      if (inputLower == null) {
        // - 整数桁数 × 10 + 0.1 × 小数桁数乗
        min = Math.pow(10, integerFigure) * - 1 + (0.1 ** decimalFigure);
      } else {
        // 入力範囲(下限)
        min = inputLower;
      }
      if (!e.target.value) {
        e.target.value = min - this.getStep(itemCd)
      }
      const parameterStep = this.getStep(itemCd);
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) || (e.detail && (e.wheelDelta > 0 ? -1 : 1));
      let value = Number(e.target.value);
      if (delta > 0) {
        // 上
        value += parameterStep
      } else {
        // 下
        value -= parameterStep
      }
      this.dataArray[itemCd] = value.toFixed(decimalFigure);
      if (max!=0 || min!=0) {
        if (value > max) {
          this.dataArray[itemCd] = Number(min).toFixed(decimalFigure);
        }
        if(value < min) {
          this.dataArray[itemCd] = Number(max).toFixed(decimalFigure);
        }
      }
      this.$forceUpdate();
    },
    // 入力内容チェック処理
    checkValue(itemCd) {
      // 入力内容 = "NULL" もしくは、入力内容 = "undefined"の場合
      if (this.dataArray[itemCd] === null || this.dataArray[itemCd] === undefined) {
        return;
      }
      var max = 0;
      var min = 0;
      const regexp = /^-?([1-9]\d*|0)(\.\d+)?$/;
      let inputUpper = this.examItemMap[itemCd].inputUpper;
      let inputLower = this.examItemMap[itemCd].inputLower;
      let integerFigure = this.examItemMap[itemCd].inputIntegerFigure;
      let decimalFigure = this.examItemMap[itemCd].inputDecimalFigure;
      // 整数桁数 = "NULL" もしくは、整数桁数 < "0"の場合
      if (integerFigure == null || integerFigure < 0) {
        integerFigure = 9;
      }
      // 小数桁数 = "NULL" もしくは、小数桁数 < "0"の場合
      if (decimalFigure == null || decimalFigure < 0) {
        decimalFigure = 2;
      }
      // 入力範囲(上限) = "NULL"の場合
      if (inputUpper == null) {
        // 整数桁数 × 10 - 0.1 × 小数桁数乗
        max = Math.pow(10, integerFigure) - (0.1 ** decimalFigure);
      } else {
        // 入力範囲(上限)
        max = inputUpper;
      }
      // 入力範囲(下限) = "NULL"の場合
      if (inputLower == null) {
        // - 整数桁数 × 10 + 0.1 × 小数桁数乗
        min = Math.pow(10, integerFigure) * - 1 + (0.1 ** decimalFigure);
      } else {
        // 入力範囲(下限)
        min = inputLower;
      }
      if(this.dataArray[itemCd] !== ''){
        // 入力内容 ≠ 数値の場合
        if (!regexp.test(this.dataArray[itemCd])) {
          if (max >= 0 && min <= 0) {
            this.dataArray[itemCd] = "";
          } else {
            this.dataArray[itemCd] = Number(min).toFixed(decimalFigure);
          }
          this.$forceUpdate();
          return;
        }
        // -----入力内容の補正処理-----
        if (this.dataArray[itemCd] > max) {
          // 入力内容 > 最大値の場合
          this.dataArray[itemCd] = Number(min).toFixed(decimalFigure);
          this.blurFlg = true;
        } else if(this.dataArray[itemCd] < min) {
          // 入力内容 < 最小値の場合
          this.dataArray[itemCd] = Number(max).toFixed(decimalFigure);
          this.blurFlg = true;
        } else {
          // 入力内容 = 入力範囲内の場合
          if (this.dataArray[itemCd].includes('.')) {
            const decimalIndex = this.dataArray[itemCd].indexOf('.');
            const decimalSplit = this.dataArray[itemCd].split('.');
            const inputIntegerFigure = decimalSplit[0];
            const inputDecimalFigure = decimalSplit[1];
            const inputDecimalFigureLength = inputDecimalFigure.length;
            if (decimalFigure == 0) {
              this.dataArray[itemCd] = inputIntegerFigure;
            } else {
              if (inputDecimalFigureLength < decimalFigure) {
                this.dataArray[itemCd] = Number(this.dataArray[itemCd]).toFixed(decimalFigure);
              } else {
                this.dataArray[itemCd] = this.dataArray[itemCd].substring(0, decimalIndex + decimalFigure + 1);
              }
            }
          } else {
            this.dataArray[itemCd] = Number(this.dataArray[itemCd]).toFixed(decimalFigure);
          }
          this.blurFlg = false;
        }
      }
      for (let examIndex = 0; examIndex < this.ExamMainDataSource._data.length; examIndex++) {
        if (this.ExamMainDataSource._data[examIndex].itemCd == itemCd) {
          this.ExamMainDataSource._data[examIndex].result = this.dataArray[itemCd];
        }
      }
      this.$forceUpdate();
    },

    // add 検査結果入力文字列、保存後は表示されない 商 start
    checkValueForText(itemCd) {
      // 値がなければ、処理しない
      if (this.dataArray[itemCd] === null || this.dataArray[itemCd] === undefined) {
        return;
      }
      for (let examIndex = 0; examIndex < this.ExamMainDataSource._data.length; examIndex++) {
        if (this.ExamMainDataSource._data[examIndex].itemCd == itemCd) {
          this.ExamMainDataSource._data[examIndex].result = this.dataArray[itemCd];
        }
      }
      this.$forceUpdate();
    },
    // add 検査結果入力文字列、保存後は表示されない 商 end

    // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
    handleFocus(index){
      this.focusFlg.forEach((item, idx)=>{
        this.focusFlg[idx] = false;
      })
      this.focusFlg[index] = true;
    },
    // ブラーイベント処理
    handleBlur(event, itemCd, index){
      this.$nextTick(() => {
        if (this.dataArray[itemCd] == '1') {
          this.refreshFlag++;
          this.dataArray[itemCd] = '1';
          this.$forceUpdate();
        }
      });
      // 入力内容 = "NULL" もしくは、入力内容 = "undefined"の場合
      if (this.dataArray[itemCd] === null || this.dataArray[itemCd] === undefined) {
        return;
      }
      var max = 0;
      var min = 0;
      const regexp = /^-?([1-9]\d*|0)(\.\d+)?$/;
      let inputUpper = this.examItemMap[itemCd].inputUpper;
      let inputLower = this.examItemMap[itemCd].inputLower;
      let integerFigure = this.examItemMap[itemCd].inputIntegerFigure;
      let decimalFigure = this.examItemMap[itemCd].inputDecimalFigure;
      // 整数桁数 = "NULL" もしくは、整数桁数 < "0"の場合
      if (integerFigure == null || integerFigure < 0) {
        integerFigure = 9;
      }
      // 小数桁数 = "NULL" もしくは、小数桁数 < "0"の場合
      if (decimalFigure == null || decimalFigure < 0) {
        decimalFigure = 2;
      }
      // 入力範囲(上限) = "NULL"の場合
      if (inputUpper == null) {
        // 整数桁数 × 10 - 0.1 × 小数桁数乗
        max = Math.pow(10, integerFigure) - (0.1 ** decimalFigure);
      } else {
        // 入力範囲(上限)
        max = inputUpper;
      }
      // 入力範囲(下限) = "NULL"の場合
      if (inputLower == null) {
        // - 整数桁数 × 10 + 0.1 × 小数桁数乗
        min = Math.pow(10, integerFigure) * -1 + (0.1 ** decimalFigure);
      } else {
        // 入力範囲(下限)
        min = inputLower;
      }
      if (this.dataArray[itemCd] == max && this.blurFlg) {
        this.dataArray[itemCd] = Number(min).toFixed(decimalFigure);
        this.blurFlg = false
      }else if (this.dataArray[itemCd] == min && this.blurFlg) {
        this.dataArray[itemCd] = Number(max).toFixed(decimalFigure);
        this.blurFlg = false
      }
      this.focusFlg[index] = false;
      if (!regexp.test(this.dataArray[itemCd])) {
        if(this.dataArray[itemCd] !== ''){
          this.dataArray[itemCd] = this.oldDataArray[itemCd];
        }else{
          delete this.dataArray[itemCd];
        }
        event.target.value =  this.oldDataArray[itemCd] ? this.oldDataArray[itemCd] : '';
      }
      this.$forceUpdate();
    },
     // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
    //add FNSI-5933 フォーカスを失うイベントを削除 高 end

    //add FNSI-fixBug 関 end
    // -----------------------------------------
    // 透析実績連携 対象透析選択select変更時処理
    // -----------------------------------------
    selectPatChange(e) {
      let selIndex = e.srcElement.selectedIndex;
      if(selIndex == 0){
        //未選択
        this.examDate = null;
        this.examTime = null;
      }else{
        //項目選択
        let patList = this.getExamPatList;
          this.examDate = patList[selIndex-1].rstStartDateName.slice(0,4)
          + '-' + patList[selIndex-1].rstStartDateName.slice(4,6)
          + '-' + patList[selIndex-1].rstStartDateName.slice(6,8);
          this.examTime = patList[selIndex-1].rstStartDateName.slice(8,10)
          + ':' + patList[selIndex-1].rstStartDateName.slice(10,12);

      }
    },

    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    dialogOkNew() {
      this.dialogOk();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.isDataChanged = true;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
    async dialogOk() {
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      // 抽出条件登録
      this.setModalCondition(deepCopy(this.localCondition));
      // 画面を閉じる
      this.popoverVisible = false;

      // 検索条件の内容で画面を更新
      EventBus.$emit("filterExamMain");
      // add FNSI-入力欄右側にスピナー表示 関 start
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      await this.copyTableDataFromExamMainDataSource();
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      // add FNSI-入力欄右側にスピナー表示 関 end
    },
    // -----------------------------------------
    // 結果なし行表示チェックイベント
    // -----------------------------------------
    checkAll(e){
      this.localCondition.allDataFlg = e.target.checked;
      // add #7697 【デグレ】検査データをdelキーで削除すると項目が非表示になる 鄭爽 start
      if (!this.localCondition.allDataFlg) {
        this.changeDataArray = JSON.parse(JSON.stringify(this.dataArray));
      }
      // add #7697 【デグレ】検査データをdelキーで削除すると項目が非表示になる 鄭爽 end
      // 一覧項目表示制御イベント呼び出し
      this.dialogOk();
    },

    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight(dispFlg) {
      if (!this.editingFlg) {
        // モーダルのbodyの高さ
        const mh = document.getElementsByClassName("modal-body")[0]
          .clientHeight;

        // モーダルのヘッダの高さ
        const hh = document.getElementById("examrecordmodal-header")
          .clientHeight;
        this.examrecordGridToolbarHeight = mh - hh;
        this.examrecordGridToolbarHeight =
          this.examrecordGridToolbarHeight < 300
            ? 300
            : this.examrecordGridToolbarHeight;
        if(dispFlg){
          //初回表示のみ広めに取得
          this.examrecordGridHeight = this.examrecordGridToolbarHeight - 40;
        }else{
          this.examrecordGridHeight = this.examrecordGridToolbarHeight - 23;
        }
      }
    },
    // add FNSI-入力欄右側にスピナー表示 関 start
    initDataArrayFromExamResult() {
      this.ExamMainDataSource._data.forEach(everyItem => {
        // add FNSI-整数ビットと小数ビットの検証 関 start
        this.classArray[everyItem.itemCd] = everyItem.examClass;
        this.inputDecimalFigureArray[everyItem.itemCd] = everyItem.inputDecimalFigure;
        this.inputIntegerFigureArray[everyItem.itemCd] = everyItem.inputIntegerFigure;
        // add FNSI-整数ビットと小数ビットの検証 関 end
        this.dataArray[everyItem.itemCd] = everyItem.result;
        // mod FNSI-デフォルトで9桁の整数を入力します 関 start
        // var conMin = -99999;
        // var conMax = 99999;
        var conMin = -999999999;
        var conMax = 999999999;
        // mod FNSI-デフォルトで9桁の整数を入力します 関 end
        if (everyItem.inputLower != null) {
          conMin = everyItem.inputLower;
        }
        if (everyItem.inputUpper != null) {
          conMax = everyItem.inputUpper;
        }
        this.dataArrayMax[everyItem.itemCd] = conMax;
        this.dataArrayMin[everyItem.itemCd] = conMin;
      });
      // add FNSI-Add Edit Style 関 start
      // if (this.oldDataArray.length == 0) {
      this.oldDataArray = JSON.parse(JSON.stringify(this.dataArray));
      // }
      // add FNSI-Add Edit Style 関 end
    },
    initCommentArrayFromExamResult() {
      this.ExamMainDataSource._data.forEach(everyItem => {
        this.commentArray[everyItem.itemCd] = everyItem.freememo;
      });
    },
    // mod FNSI-NO504-冗長なjsonデータを削除する 関 start
    // copyTableDataFromExamMainDataSource() {
    //   this.allTableData = this.ExamMainDataSource;
    async copyTableDataFromExamMainDataSource() {
      this.allTableData = this.ExamMainDataSource;
      var examItems = await sendRequestGetMstExamItemList(this.getFacilityCd);
      let examItemMap = new Object;
      examItems.data.forEach(everyItem => {
        if (everyItem.isDisp == 1 && everyItem.facilityCd == this.getFacilityCd) {
          examItemMap[everyItem.examItemCd] = everyItem;
        }
      });
      //add #8000 検査結果を保存できない gaoey start
      this.initCommentArrayFromExamResult()
      //add #8000 検査結果を保存できない gaoey end
      let n = 0;
      this.allTableData._data.forEach((everyTableData,index) => {
        // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc start
        // if (examItemMap[everyTableData.itemCd] != null) {
        //   if (examItemMap[parseInt(everyTableData.itemCd)].normalValueLower != null && examItemMap[parseInt(everyTableData.itemCd)].normalValueUpper != null) {
        let checkValueUpper = null;
        let checkValueLower = null;
        
        // 正常範囲のkey取得
        const { normalValueUpper: upper, normalValueLower: lower } =
          getNormalValueKeys(examItemMap[parseInt(everyTableData.itemCd)]["normalValueClass"], this.selectedPatSex, this.getExamDefaultSex);

        if(!examItemMap[everyTableData.itemCd][lower] && !examItemMap[everyTableData.itemCd][upper]
            && examItemMap[everyTableData.itemCd][lower] !== 0  && examItemMap[everyTableData.itemCd][upper] !== 0) {
          this.allTableData._data[n].normalValue = "";
        }else if(!examItemMap[everyTableData.itemCd][lower] && examItemMap[everyTableData.itemCd][lower] !== 0){
          checkValueUpper = this.formatNumber(examItemMap[everyTableData.itemCd][upper]);
          this.allTableData._data[n].normalValue = '～' + this.formatNumber(examItemMap[everyTableData.itemCd][upper]);
        }else if(!examItemMap[everyTableData.itemCd][upper] && examItemMap[everyTableData.itemCd][upper] !== 0){
          checkValueLower = this.formatNumber(examItemMap[everyTableData.itemCd][lower]) ;
          this.allTableData._data[n].normalValue = this.formatNumber(examItemMap[everyTableData.itemCd][lower]) + '～';
        }else{
          checkValueUpper = this.formatNumber(examItemMap[everyTableData.itemCd][upper]);
          checkValueLower = this.formatNumber(examItemMap[everyTableData.itemCd][lower]);
          this.allTableData._data[n].normalValue = this.formatNumber(examItemMap[everyTableData.itemCd][lower]) + '～' + this.formatNumber(examItemMap[everyTableData.itemCd][upper]);
        }

        this.allTableData._data[n].lower = checkValueLower;
        this.allTableData._data[n].upper = checkValueUpper;
      // }
      this.allTableData._data[n].type = examItemMap[parseInt(everyTableData.itemCd)].dataType;
    // }
    n++;
    // add #5589 2023/04/25 数値IFのスタイル全不正 林峻峰 start
    this.focusFlg[index] = false;
        // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc end
        // add #5589 2023/04/25 数値IFのスタイル全不正 林峻峰 end
      });
    // mod FNSI-NO504-冗長なjsonデータを削除する 関 end
    },
    // add FNSI-入力欄右側にスピナー表示 関 end

// mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc start
    formatNumber(targetFormatNum){
      if(targetFormatNum == null) return targetFormatNum;
      if (targetFormatNum.toString().indexOf('e') > 0)
        targetFormatNum = parseFloat(targetFormatNum).toFixed(9)
      if (targetFormatNum.toString().indexOf('e') > 0 && targetFormatNum.toString().indexOf('-') == 0)
        targetFormatNum = "-" + parseFloat(targetFormatNum.slice(1,targetFormatNum.length)).toFixed(9)
      return targetFormatNum;
    },
// mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc end
    /**
     * @description 編集時、テキストボックスをDB指定の入力フィールドへ変換
     * @summary examClass
     * @param container grid生成情報
     * @param data DB取得値
     */
    editorInputCheckData(container, data) {

      if(data.model.examClass == "0" && data.model.type =="0"){
        // 文字入力
        $$(`<input type="text" class="k-input k-textbox" name="${data.field}"/>`).appendTo(container)
      }else if(data.model.examClass == "0" && data.model.type =="1"){
        // 数値入力
        $$(`<input class="k-numerictextbox" inputmode="numeric" name="${data.field}"/>`)
          .appendTo(container)
          .kendoNumericTextBox({
          });
      }else{
        if(!data.model.result){
          // 対象データ外 処理なし
        }else{
          $$(`<label>${data.model.result}</label>`).appendTo(container);
        }
      }

      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.isDataChanged = true;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    },
    /**
     * @description 編集時、テキストボックスをDB指定の入力フィールドへ変換
     * @summary examClass
     * @param container grid生成情報
     * @param data DB取得値
     */
    editorInputComment(container, data) {
      if(data.model.examClass == "0" || data.model.examClass == "1" || data.model.examClass == "2"){
        $$(`<input type="text" class="k-input k-textbox" name="${data.field}"/>`).appendTo(container)

      }else{
        if(!data.model.freememo){
          // 対象データ外 処理なし
        }else{
          $$(`<label>${data.model.freememo}</label>`).appendTo(container);
        }
      }
    },

    editStart() {
      if (this.androidFlg) {
        this.editingFlg = true;
      }
    },
    editEnd(e) {
      // 文字色設定
      this.setFontColor(e);
      this.editingFlg = false;
    },
    changes(){
    },

    templateData(item) {
      return {
        dataItem: item,
        parentComponent: this
      };
    },
    // 背景色セット
    editBackgroundColor() {
      this.$nextTick(() => {
        let gridHeader = this.$refs.examrecordgrid.$el.firstChild;
        if (gridHeader.classList === undefined) {
          gridHeader = this.$refs.examrecordgrid.$el.firstElementChild;
        }
        gridHeader?.classList?.add("master-grid-header");
      });
    },
    setFontColor(e){
      const lockrows = e.sender.content.find("tr");
      // 検査データセル
      const examresult = e.sender.wrapper
        .find(".k-grid-header [data-field=" + "result" + "]")
        .index();
      // add 9403 検査結果グラフのレンジが正しく表示されていない zhou start
      if (examresult == -1 ){
        return;
      }
      // add 9403 検査結果グラフのレンジが正しく表示されていない zhou end
      // 検査データの文字色を設定
      lockrows.each(function(index, row) {
        const dataItem = e.sender.dataItem(row);
        // 検査データの文字色指定：データタイプが「数値」の時のみ
        if(dataItem.type == "1"){
          if (parseFloat(dataItem.result) > parseFloat(dataItem.upper)) {
            row.children[examresult].style.color = "red";
          } else if (parseFloat(dataItem.result) < parseFloat(dataItem.lower)) {
            row.children[examresult].style.color = "blue";
          } else {
            row.children[examresult].style.color = "black";
          }
        }
      });
    },
    onSave() {
      this.editingFlg = false;
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.isDataChanged = true;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    },
    // 登録完了通知
    gridDataLoad() {
      // 登録完了通知
      EventBus.$emit("detailUpdate");
    },

    /**
     * 検査結果記録データ移動前処理
     * examMainCd: 検査結果ID
     */
    async moveSourceDelete (examMainCd) {
      // <仕様>
      // 予定あり：レコード残す。結果部分を物理削除。
      // 予定なし：マージ先なしの場合は日時、区分を更新。マージ先ありの場合は論理削除。
      // <実装>
      // 予定あり：結果を空にしてupdate。exam_status => 0、result_exam_date => null、exam_result_inf => null にする。
      // 予定なし：マージ先なしの場合は日時、区分を更新してupdate。マージ先ありの場合は論理削除、is_del = '1' にしてupdate。

      // まず編集中のexamMainCdからpatExamMainを取得
      let patExamMain = null;
      try{
        patExamMain = await sendRequestGetPatExamMainByExamMainCd(examMainCd);
      }catch(e){
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ExamRecordModal.vue', 'moveSourceDelete', e);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        console.error(e);
        return {result: false, message: e};
      }

      // 移動チェックフラグ -> true: 予定ありor予定なし＋マージ先あり、false: 予定なし＋マージ先なし
      let movedFlg = true;

      // 予定の有無をチェック
      if (JSON.parse(patExamMain.data.examOrderInfo).length !== 0) {
        // 予定あり。結果を空にしてupdate。
        try{
          await sendRequestClearExamResultInfo(examMainCd);
        }catch(e){
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('ExamRecordModal.vue', 'moveSourceDelete', e);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          console.error(e);
          return {result: false, message: e}
        }
      } else {
        // 予定なし。マージ先ありの場合は論理削除、is_del = '1' にしてupdate。
        if (this.isExistOrder === true || this.isExistResult === true) {
          try{
            await sendRequestDeletePatExamMain(examMainCd);
          }catch(e){
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('ExamRecordModal.vue', 'moveSourceDelete', e);
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            console.error(e);
            return {result: false, message: e}
          }
        } else {
          // 予定なし。マージ先なしの場合はupdateExamRecordで日時、区分を更新してupdate。
          movedFlg = false;
        }
      }
      return { result: true,  movedFlg: movedFlg};
    },

    // 確定ボタン 検査結果保存前処理
    async saveExamRecordPre() {
      // add #9403 ies_7766 zhou start
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // add  #9403  ies_7766 zhou end
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231204 ztc start
      if(this.examSelectDiv < 0){
        this.isCheckDialogVisible = true;
        this.messageCd = 74000007;
        this.stringParams = [""];
        this.setLoadingScreenVisible(false);
        return;
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231204 ztc end
      this.setExamMainDataSource(deepCopy(this.ExamMainDataSource._data));
      await this.selectExamData(this.getExamSetNameList);
      // マージ登録チェック
      // 検査日時(YYYYMMDDhhmm)一致AND検査区分一致
      let existResultData = null;
      const strExamSelectDiv = isNaN(this.examSelectDiv) ? this.examSelectDiv : this.examSelectDiv.toString();
      await sendRequestGetExistResult(
        this.selectedPatId,
        strExamSelectDiv,
        this.examDate + " " + this.examTime + ":00",
        this.getExamMainCd
      ).then(response => {
        existResultData = response.data;
      });
      // await sendRequestGetExistOrder(
      //   this.selectedPatId,
      //   strExamSelectDiv,
      //   this.examDate,
      //   this.examDate + " " + this.examTime + ":00",
      //   this.getExamMainCd
      // ).then(response => {
      //   existResultData = response.data;
      // });

      // 重複したレコードがある場合
      // マージ処理は confirmMerge で行う
      // let date = new Date(existResultData.resultExamDate);
      // let y = date.getFullYear();
      // let MM = date.getMonth() + 1;
      // MM = MM < 10 ? ('0' + MM) : MM;
      // let d = date.getDate();
      // d = d < 10 ? ('0' + d) : d;
      // let h = date.getHours();
      // h = h < 10 ? ('0' + h) : h;
      // let m = date.getMinutes();
      // m = m < 10 ? ('0' + m) : m;
      // let s = date.getSeconds();
      // s = s < 10 ? ('0' + s) : s;
      // let serveDate =  y + '-' + MM + '-' + d + ' ' + h + ':' + m + ':' + s;
      // let pageDate = this.examDate + " " + this.examTime + ":00"
      this.mergeBaseExamResultlist = []
      if (existResultData !== null && existResultData !== "") {
        let existResultDatacopy = {}
        if(this.getModalState === 0||(this.getModalState === 1&&
          (this.openPageExamDate!=this.examDate||this.examTime!=this.openPageExamTime||this.examSelectDiv!=this.openPageExamSelectDiv))){
          // add 透析前後合併問題 5950 gaoey start
          existResultDatacopy.mergeTargetExamMainCd = existResultData.examMainCd;
          existResultDatacopy.mergeBaseExamResult = existResultData.examResultInfo;
          this.mergeBaseExamResultlist.push(existResultDatacopy)
          // add 透析前後合併問題 5950 gaoey end
          this.mergeDialogVisible = true;
          // add  #9403 ies_7766 zhou start
          this.setLoadingScreenVisible(false);
          // add  #9403 ies_7766 zhou end
          return;
        }
      }

      // 紐づけ登録チェック
      // 検査日時(YYYYMMDD)一致AND検査区分一致And結果なし検査依頼
      let existOrderData = null;
      await sendRequestGetExistOrder(
        this.selectedPatId,
        strExamSelectDiv,
        this.examDate,
        this.examDate + " " + this.examTime + ":00",
        this.getExamMainCd
      ).then(response => {
        existOrderData = response.data;
      });

      // 紐づけすべき検査依頼レコードがある場合
      // マージ処理は confirmMerge で行う
      if (existOrderData !== null && existOrderData !== "") {
        // add 透析前後合併問題 5950 gaoey start
        let existOrderDatacopy = {}
        existOrderDatacopy.mergeTargetExamMainCd = existOrderData.examMainCd;
        existOrderDatacopy.mergeBaseExamResult = existOrderData.examResultInfo;
        this.mergeBaseExamResultlist.push(existOrderDatacopy)
        // add 透析前後合併問題 5950 gaoey end
        this.isExistOrder = true;
      }
      // 必須入力チェック
      // del #8000-【デグレ】検査結果を保存できない 徐博 start
      // if (!this.isFilledRequired()) {
      //   //共通ローダー：表示終了
      //   return;
      // }
      // del #8000-【デグレ】検査結果を保存できない 徐博 end
      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
      // // 後処理を行う
      // this.saveExamRecord();
      //
      // /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
      // // 予実リストの更新
      // this.setResultUpdate(new Date());
      // /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
      // const targetData = this.getExamMainData.filter(item => !item["result"] && item["freememo"] && item["examClass"] == "0");
      // mod #8000-【デグレ】検査結果を保存できない 徐博 start
      const targetData = this.getExamMainDataSource.filter(item => item["examClass"] == "0")
      let flag
      let count = 0
      for (const val of targetData) {
        // mod #8000 検査結果を保存できない gaoey start
        if ((val.result == undefined||isNaN(val.result)||val.result == "") && val.freememo != undefined && val.freememo.length > 0) {
          // add  #9403 ies_7766 zhou start
          this.setLoadingScreenVisible(false);
          // add  #9403 ies_7766 zhou end
          this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "保存確認",
            title: DIALOG_MESSAGES[13000026].title,
            // mod #8000 検査結果を保存できない gaoey end
            // message: `コメントのみで検査データ値のない検査結果があります。<br/>このまま保存しますか？`,
            message: messageFormat(DIALOG_MESSAGES[13000026].message),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer == 1) {
                this.saveExamRecord();
                this.setResultUpdate(new Date());
              } else {
                return
              }
            }
          });
          flag = true
          break;
        }
        count += 1;
        if (count == targetData.length) {
          flag = false
        }
      }
      // add  #9403 ies_7766 zhou start
      this.setLoadingScreenVisible(false);
      // add  #9403 ies_7766 zhou end
      if ( flag == false) {
        this.saveExamRecord();
        this.setResultUpdate(new Date());
      }
      // mod #8000-【デグレ】検査結果を保存できない 徐博 end
      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
    },
    async insertExamRecord(isNormal){
      let insertData = {
        patId:this.selectedPatId,
        facilityCd:this.getFacilityCd,
        ordNo:this.examSelectPat,
        examDate:this.examDate + " " +  this.examTime + ":00",
        orderClass:this.examSelectDiv,
        examItemMap: this.examItemMap
      }
      if(isNormal != "isNormal") {
        // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 end
        await this.insertExamrecord(insertData).then(res => {
          if (res.result === false) {
            // エラーメッセージ表示
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "検査結果登録失敗",
              title: DIALOG_MESSAGES["00300015"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: res.message
            });
          }
        });
      }
      // 登録完了通知-一覧画面データ再取得
      if(isNormal == "isNormal") {
        this.gridDataLoad();
        this.modalStoreReset();
        // 選択患者の情報を再取得
        this.selectPat(this.selectedPatId);
        //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 start
        let params = {
          ope_cd: "018001",
          crud: "C",
          facility_cd: this.getFacilityCd,
          // add FNSI zhuhongui starts
          pat_id: this.selectedPat.pat_personal_main.pat_id,
          // add FNSI zhuhongui end
          hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
          ord_no: "",
          base_date: this.examDate.replace("-", ""),
          user_id: this.getStateUserAccountInfo.userId,
        }
        createJournal(params);
        //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 end
      }
    },
    async updateExamRecord(mergeFlg,listLength,isRegOrderClass,examItemCd) {
      // add 透析前後合併問題 5950 gaoey start
      let mergeBaseExamResultcopy = []
      let mergeTargetExamMainCdcopy = ''
      for(let i = 0;i < this.mergeBaseExamResultlist.length;i++){
        //判断是否是第一条数据，直接合并的情况下是没有examItemCd参数的
        if(examItemCd == null || examItemCd == ''||JSON.stringify(examItemCd) == 'undefined'){
          mergeBaseExamResultcopy = this.mergeBaseExamResultlist[i].mergeBaseExamResult
          mergeTargetExamMainCdcopy = this.mergeBaseExamResultlist[i].mergeTargetExamMainCd
        }
        //判断
        if(this.mergeBaseExamResultlist[i].mergeTargetExamMainCd == examItemCd){
          mergeBaseExamResultcopy = this.mergeBaseExamResultlist[i].mergeBaseExamResult
          mergeTargetExamMainCdcopy = this.mergeBaseExamResultlist[i].mergeTargetExamMainCd
        }
      }
      // add 透析前後合併問題  5950 gaoey end
      const params = {
        patId:this.selectedPatId,
        facilityCd:this.getFacilityCd,
        // mod 8144 【デグレ】検査計算結果が検査後にしか反映されない 関 start
        // examDate: this.examDate + " " + ((listLength == "isLast" || listLength == "isHalfway") ? this.$store.getters["exam-record/modal/getExamTime"] : this.examTime + ":00"),
        examDate: this.examDate + " " + ((listLength == "isLast" || listLength == "isHalfway") ? this.$store.getters["exam-record/modal/getExamTime"]+ ":00" : this.examTime + ":00"),
        // mod 8144 【デグレ】検査計算結果が検査後にしか反映されない 関 end
        mergeFlg: mergeFlg,
        target: examItemCd ? examItemCd:mergeTargetExamMainCdcopy,
        examResult: mergeBaseExamResultcopy,
        orderClass: isRegOrderClass ? isRegOrderClass : this.examSelectDiv,
        examItemMap: this.examItemMap
      };
      // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 end
      await this.updateExamrecord(params).then(res => {
        if (res.result === false) {
          // エラーメッセージ表示
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "検査結果登録失敗",
            title: DIALOG_MESSAGES["00300015"].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: res.message
          });
        }

        //感染症情報登録更新API呼び出し

        //自動計算処理API呼び出し

        if(listLength == "isLast") {
          // 登録完了通知-一覧画面データ再取得
          this.gridDataLoad();
          this.modalStoreReset();

          // 選択患者の情報を再取得
          this.selectPat(this.selectedPatId);
          //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 start
          let params = {
            ope_cd: "018002",
            crud: "U",
            facility_cd: this.getFacilityCd,
            // add FNSI zhuhongui starts
            pat_id: this.selectedPat.pat_personal_main.pat_id,
            // add FNSI zhuhongui end
            hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
            ord_no: "",
            base_date: this.examDate.replace("-", ""),
            user_id: this.getStateUserAccountInfo.userId,
          }
          createJournal(params);
        }
      });
      //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 end
    },
    // 確定ボタン 検査結果保存後処理
    async saveExamRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // 移動チェック準備
      // 既存データを編集して移動した場合、結果orレコードを削除。
      const parsedComparisonModel = JSON.parse(this.comparisonModel);
      // 日時移動チェック
      // 編集中データの日時 YYYY-MM-DD hh:mm -> YYYYMMDDhhmm00 に変換
      // なぜか"YYYY-MM-DD"の前のハイフン(UTF-8:22)と後ろのハイフン(UTF-8:2D)の文字が異なるため両方空文字に変換する
      const resultExamDateName = (this.examDate + this.examTime).replace(":","").replace("-","").replace("-","") + "00";
      let isMovedDate = false;
      if (parsedComparisonModel[0].resultExamDateName && parsedComparisonModel[0].resultExamDateName !== resultExamDateName) {
        isMovedDate = true;
      }
      // 区分移動チェック
      let isMovedOrderClass = false;
      if (parsedComparisonModel[0].regOrderClass && parsedComparisonModel[0].regOrderClass !== this.examSelectDiv.toString()) {
        isMovedOrderClass = true;
      }
      // 移動チェックフラグ
      let movedFlg = isMovedDate || isMovedOrderClass;

      // 移動前処理
      if (movedFlg === true) {
        await this.moveSourceDelete(this.getExamMainCd).then(res => {
          if (res.result === false) {
            // エラーメッセージ表示
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "移動前処理失敗",
              title: DIALOG_MESSAGES["00300016"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: res.message
            });
          }
          // 移動チェックフラグ -> true: 予定あり or 予定なし + マージ先あり、false: 予定なし + マージ先なし
          movedFlg = res.movedFlg;
        });
      }

      // insertかupdateどちらを実行するか判定
      let executeUpdateFlg = false;
      let mergeFlg = false;
      if (this.getModalState === 1 && movedFlg === false && this.isExistOrder === false && this.isExistResult === false) {
        // パターン1 既存データの単純な編集。マージは行わずにupdate。
        executeUpdateFlg = true;
        mergeFlg = false;
      } else if ((this.getModalState === 1 && movedFlg === false)||(this.getModalState === 0 && movedFlg === false) || (this.getModalState === 1 && movedFlg === true)) {
        if (this.isExistOrder === false && this.isExistResult === false) {
          // パターン2 新しいデータを作成。新規レコードをinsert。
          executeUpdateFlg = false;
          mergeFlg = false;
        } else if (this.isExistOrder === false && this.isExistResult === true) {
          // パターン3 既存の検査結果データに対してマージ登録を行う。上書きマージしてupdate。
          executeUpdateFlg = true;
          mergeFlg = true;
        } else if (this.isExistOrder === true && this.isExistResult === false) {
          // パターン4 検査依頼データへの紐づけ登録。予定データに検査結果を入れてupdate。exam_statusを1にする。
          executeUpdateFlg = true;
          mergeFlg = true;
        } else {
          // それ以外 基本的にあり得ないはず。
          executeUpdateFlg = false;
          mergeFlg = false;
        }
      }
      // グリッドに表示されているデータを登録
      if (executeUpdateFlg === true) {
        // UPDATE実施
        // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 start
        // const params = {
        //   examDate: this.examDate + " " + this.examTime + ":00",
        //   mergeFlg: mergeFlg,
        //   target: this.mergeTargetExamMainCd,
        //   examResult: this.mergeBaseExamResult,
        //   orderClass: this.examSelectDiv
        // };
        await this.updateExamRecord(mergeFlg,"isNormal");
        // 共通ローダー:表示終了
      }else {
        // INSERT実施
        // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 start
        // let insertData = {
        //     patId:this.selectedPatId,
        //     facilityCd:this.getFacilityCd,
        //     ordNo:this.examSelectPat,
        //     examDate:this.examDate + " " +  this.examTime + ":00",
        //     orderClass:this.examSelectDiv
        //     }
        await this.insertExamRecord();
      }
      let patExamMainDetailList = [];
      await sendRequestGetPatExamMainDetailList(this.selectedPatId, this.examDate,this.examDate).then(
        (response) => {
          response.data.forEach(e => {
            if(this.examDate + " " +  this.examTime + ":00" == moment(e.resultExamDate).format("YYYY-MM-DD HH:mm:ss")){
              if(this.getExamMainCd !== e.examMainCd && this.examSelectDiv != e.regOrderClass){
                // add 透析前後合併問題 5950 gaoey start
                let existOrderDatacopy = {}
                existOrderDatacopy.mergeTargetExamMainCd = e.examMainCd;
                existOrderDatacopy.mergeBaseExamResult = e.examResultInfo;
                this.mergeBaseExamResultlist.push(existOrderDatacopy)
                // add 透析前後合併問題 5950 gaoey end
                /* mod #IES_6602 by zhangruixue 2023-06-29 --start */
                // if(this.isExistResult === false){
                //   patExamMainDetailList.push(e);
                // }
                /* mod #IES_6602 by zhangruixue 2023-06-29 --end */
              }
            }
          })
        }
      )
      for(let n = 0; n < patExamMainDetailList.length;n++ ){
        this.setModalState(1);
        await this.setExamModalDataSource({field:"M"+patExamMainDetailList[n].examMainCd+"Cd",facilityCd:this.getFacilityCd,patId:this.selectedPatId,patSex:this.selectedPatSex,defaultSex:this.getExamDefaultSex}).then(async () => {
          // add gaoey 5950 数据重复修改 start
          if(patExamMainDetailList.length - 1 == n){
            await this.updateExamRecord(mergeFlg,"isLast",patExamMainDetailList[n].regOrderClass,patExamMainDetailList[n].examMainCd);
          }else{
            await this.updateExamRecord(mergeFlg,"isHalfway",patExamMainDetailList[n].regOrderClass,patExamMainDetailList[n].examMainCd);
          }
          // add gaoey 5950 数据重复修改 end
        });
      }
      this.mergeBaseExamResultlist = []
      /*add FNSI-改修内容6326 任 start*/
      const examDateOrder = this.getExamResultDispOrder === DISP_ORDER_LEFT_PAST ? "asc" : "desc";
      await this.setExamDetailSelectData({facilityCd: this.getFacilityCd, examDateOrder: examDateOrder});
      EventBus.$emit("flashData");
      /*add FNSI-改修内容6326 任 end*/
      // if(executeUpdateFlg !== true) {
      //   await this.insertExamRecord("isNormal");
      // }
      // モーダルを非表示に
      this.$nextTick(() => {
        this.hideModal();
      });
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    // 削除処理
    async confirmDelete(answer) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // 検査記録：更新時
      // mod 8467【デグレ】検査結果を削除するとエラー発生 関 start
      // this.deleteExamrecord().then(res => {
      await this.deleteExamrecord().then(res => {
      // mod 8467【デグレ】検査結果を削除するとエラー発生 関 end
        if (res.result === false) {
          if(res.message.response.status === 409) {
            // 排他制御エラー:AxiosHelperで処理されるため処理実装しない
          }else{
            // その他エラーメッセージ表示
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "検査結果削除失敗",
              // message: "検査結果の削除に失敗しました。"
              title: DIALOG_MESSAGES['00200021'].title,
              message: messageFormat(DIALOG_MESSAGES['00200021'].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
        }
        // 登録完了通知-一覧画面データ再取得
        this.gridDataLoad();
        // モーダルを非表示に
        this.hideModal();
        this.modalStoreReset();
        // 選択患者の情報を再取得
        this.selectPat(this.selectedPatId);
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
      });
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
      // 予実リストの更新
      this.setResultUpdate(new Date());
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
      //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 start
      let params =  {
          ope_cd:"018003",
          crud: "D",
          facility_cd: this.getFacilityCd,
          // add FNSI zhuhongui starts
          pat_id:this.selectedPat.pat_personal_main.pat_id,
          // add FNSI zhuhongui end
          hosp_pat_id : this.selectedPat.pat_personal_main.hosp_pat_id,
          ord_no : "",
          base_date:this.examDate.replace("-",""),
          user_id : this.getStateUserAccountInfo.userId,
        }
        createJournal(params);
        //mod 外部連携api呼び出しタイミング一覧r6_20201102_不足分追加 劉全航 end
    },

    /**
     * @description 必須項目チェック
     * @summary コメントに値があるのに対応する数値項目に値が無い場合にエラー通知
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {

      //01.明細行が0件の場合は検査項目0件エラー
      if(this.getExamMainData.length == 0 ){
        this.isCheckDialogVisible = true;
        this.messageCd = 74000002;
        this.stringParams = [""];
        return false;
      }

      //02.自動計算を除く結果値が入っている項目が0件の場合：検索項目0件エラー
      if(this.getExamMainData.filter(item => item["result"]  && item["examClass"] == "0").length == 0){
        this.isCheckDialogVisible = true;
        this.messageCd = 74000002;
        this.stringParams = [""];
        return false;
      }

      //03.検査項目が手動入力用のものでコメントが入っているものは値が必須
      //関test
      const targetData =
      this.getExamMainData.filter(item =>
        !item["result"]
        && item["freememo"]
        && item["examClass"] == "0");

      let targetNames = "";
      for(let n = 0; n < targetData.length;n++){
        if(n === targetData.length-1){
          targetNames = targetNames + targetData[n].itemName;
        }else{
          targetNames = targetNames + targetData[n].itemName + ',';
        }
      }
      // del #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
      // //未入力項目が5件以上は項目名コメントなし
      // if(targetData.length >= 6){
      //   this.isCheckDialogVisible = true;
      //   this.messageCd = 74000001;
      //   this.stringParams = [""];
      //   return false;
      // }
      // //5件以下1件以上は未入力項目名コメント付き
      // if(targetData.length >= 1){
      //   this.isCheckDialogVisible = true;
      //   this.messageCd = 74000001;
      //   this.stringParams = ["[" + targetNames + "]"];
      //   return false;
      // }
      // del #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
      return true;
    },

    /**
       ■■■未使用処理■■■
     * @description 数値項目有効チェック
     * @summary 各入力項目ごとの数値に有効外の値があればダイアログを表示する
     * @returns {Boolean} true: 有効外なし, false: 有効外あり
    */
    isNumericErrCheck(){
      let checkData = this.ExamMainDataSource.options.data;
      for(let n = 0; n < checkData.length;n++){
        if(checkData[n].type == "1"){
          //1.入力値：数値チェック
          if(!this.isNumber(checkData[n].result)){
              //数値変換できない場合
              return false;
          }
          //2.入力値：入力範囲内チェック
          if(Number(checkData[n].result) > Number(checkData[n].inputUpper)
            || Number(checkData[n].result) < Number(checkData[n].inputLower) ){
              //upperを超えるかlowerより低い場合
              return false;
          }
          //3.入力値：小数点分解チェック
          let splitResult = checkData[n].result.split('.');
          //文字列の整数部を数値変換して絶対値取得をし、String変換で桁数を取得し、それが整数部制限値以内であること
          if(String(Math.abs(Number(splitResult[0]))).length > Number(checkData[n].inputIntegerFigure)){
              //整数部の制限エラー
              return false;
          }
          if(splitResult[1] && splitResult[1].length > Number(checkData[n].inputDecimalFigure)){
              //小数部の制限エラー
              return false;
          }
        }
      }
      return true;
    },

    /**
     * 数値チェック関数
     * 入力値が数値 (符号あり小数 (- のみ許容)) であることをチェックする
     * [引数]   numVal: 入力値
     * [返却値] true:  数値
     *          false: 数値以外
     */
    isNumber(numVal){
      // チェック条件パターン
      var pattern = /^[-]?([1-9]\d*|0)(\.\d+)?$/;
      // 数値チェック
      return pattern.test(numVal);
    },

    // 抽出条件変更イベント
    setFilterCondition() {
      // 治療日列の表示/非表示
      let colsetting = this.getExamMainColumn;
      colsetting[4].hidden = !this.localCondition.normalRange;
      this.setExamMainDataSource(deepCopy(this.ExamMainDataSource._data));

      this.selectExamData(this.getExamSetNameList);

    },
    // 正常範囲表示切り替えイベント
    // 抽出条件変更イベント
    changeNormalRange(e){
      this.localCondition.normalRange = e.target.checked;
      // 治療日列の表示/非表示
      let colsetting = this.getExamMainColumn;
      colsetting[4].hidden = !this.localCondition.normalRange;
    },

    // キャンセルボタン
    cancelModal() {
      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      //if(JSON.stringify(this.ExamMainDataSource._data) == this.comparisonModel || this.isDisabled){
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      if(this.isDisabled || this.editState){
      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
        // モーダルを非表示に
        this.dialogVisible = true;
      }else{
        this.hideModal();
        this.modalStoreReset();
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end

    },
    // 削除ボタン
    deleteExamRecord() {
      // add #10359_NG対応 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('ExamRecord', 'item_delete_btn')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "検査結果削除")
        });
        return;
      }
      // add #10359_NG対応 編集権限の動作不正 dengshen end
      // mod #10553 連携イベント発生部分不正 dengshen start
      // if(this.canDelete){
      //   //削除権限あり
      //   this.dispDeleteMessage();
      // }else{
      //   //削除権限無し:
      //   this.isCheckDialogVisible = true;
      //   this.messageCd = 20010008;
      //   this.stringParams = [""];
      // }
      this.dispDeleteMessage();
      // mod #10553 連携イベント発生部分不正 dengshen end
    },

    async dispDeleteMessage() {
      let deleteFlg = false;
      let dialogDispFlg = false;
      await this.$ons.notification.confirm({
        modifier: "warn",
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "検査結果削除警告",
        title: DIALOG_MESSAGES[13000027].title,
        // message: "検査結果を削除します。<br>削除すると二度と元に戻せません。削除してもよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000027].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer == 1) {
            deleteFlg = true;
            dialogDispFlg = true;
          }
        }
      });
      if (dialogDispFlg) {
        await this.$ons.notification.confirm({
          modifier: "warn",
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "検査削除最終確認",
          title: DIALOG_MESSAGES[13000028].title,
          // message: "検査結果を削除します。本当によろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000028].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 0) {
              deleteFlg = false;
            }
          }
        });
      }
      if (!deleteFlg) {
        // キャンセルされた場合は処理を中断
        return;
      }
      await this.confirmDelete();
      await deleteRefresh(this.selectedPatId).then(res => {
        if (res.result === false) {
          // エラーメッセージ表示
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "検査結果登録失敗",
            title: DIALOG_MESSAGES["00300015"].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: res.message
          });
        }
      });
    },

    // 閉じるボタン
    closeExamRecordModal() {
      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      // if(JSON.stringify(this.ExamMainDataSource._data) == this.comparisonModel){
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // if(JSON.stringify(this.ExamMainDataSource._data) == this.comparisonModel || !this.isDataChanged){
      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
        // モーダルを非表示に
      if(this.isDisabled || this.editState){
        // this.hideModal();
        // this.modalStoreReset();
        this.dialogVisible = true;
      }else{
        // this.dialogVisible = true;
        this.hideModal();
        this.modalStoreReset();
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    },
    confirmCancel(answer) {
      if (answer === "OK") {
        // モーダルを非表示に
        this.hideModal();
        this.modalStoreReset();
      }
    },
    confirmMerge(answer) {
      if (answer === "OK") {
        // フラグ設定
        this.isExistResult = true;
        // 後処理を行う
        this.saveExamRecord();
      }
    },
    isEdited(dateField) {
      let beforeVal = null;
      let afterVal = null;

      // 検査日時(日付)
      if (dateField === "examDate") {
        beforeVal = this.openPageExamDate;
        afterVal = this.examDate;
      }
      // 検査日時(時刻)
      if (dateField === "examTime") {
        beforeVal = this.openPageExamTime;
        afterVal = this.examTime;
      }
      if (beforeVal != afterVal) {
        if (dateField === "examDate") {
          return "date-input-edited";
        }
        if (dateField === "examTime") {
          return "time-input-edited";
        }
      }
      return "";
    }
  },
  watch: {
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
    // examDate: {
    //   handler() {
    //     if(this.isInitFinished) {
    //       this.isDataChanged = true;
    //     }
    //   }
    // },
    //
    // examTime: {
    //   handler() {
    //     if(this.isInitFinished) {
    //       this.isDataChanged = true;
    //     }
    //   }
    // },
    //
    // examSelectDiv: {
    //   handler() {
    //     if(this.isInitFinished) {
    //     this.isDataChanged = true;
    //   }}
    // },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    // del FNSI-fixBug 関 start
    // add FNSI-入力欄右側にスピナー表示 関 start
    dataArray: {
      handler(newValue) {
        // add FNSI-Fix Bug 関 start
        for (let index in newValue) {
          if (newValue[index] != null && newValue[index] != undefined) {
            for (let examIndex = 0; examIndex < this.ExamMainDataSource._data.length; examIndex++) {
              if (this.ExamMainDataSource._data[examIndex].itemCd == index) {
                this.ExamMainDataSource._data[examIndex].result = this.dataArray[index];
              }
            }
          }
        }
        // add FNSI-Fix Bug 関 end
      },
      deep: true
    },
    // del FNSI-fixBug 関 end
    commentArray: {
      handler(newValue) {
        for (let index in newValue) {
          if (newValue[index] != null && newValue[index] != undefined) {
            for (let examIndex = 0; examIndex < this.ExamMainDataSource._data.length; examIndex++) {
              if (this.ExamMainDataSource._data[examIndex].itemCd == index) {
                this.ExamMainDataSource._data[examIndex].freememo = this.commentArray[index];
              }
            }
          }
        }
      }
    },
    // add FNSI-入力欄右側にスピナー表示 関 end
    windowHeight() {
      this.calculateGridHeight(false);
    },
    isDispMenu() {
      this.calculateGridHeight(false);
    },
    getFontSize() {
      this.calculateGridHeight(false);
    }
  },
  async created() {
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    this.setIsOpenFlag(true);
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
    //add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi start
    store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
    store.dispatch("loading-screen/setLoadingScreenVisible", true);
    //add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi end
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
    // 利用権限がない場合入力部品を操作不可にする
    this.authorityCds = this.getAuthorityCds();

    // 抽出条件セット
    //this.setModalCondition(deepCopy(this.localCondition));
    this.localCondition = deepCopy(this.getModalCondition);

    // 明細情報Columnセット
    this.setExamModalColumn();
    // 透析実績リスト作成
    await this.setExamPatList({patId:this.selectedPatId, facilityCd:this.getFacilityCd});
    // add 性能改善メモリ不足 shan end
    EventBus.$on("filterExamMain", this.setFilterCondition);
    // 共通ローダー:表示名設定
    // del #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi start
    //this.setLoadingScreenMessage("処理中・・・");
    // del #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi end
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
    EventBus.$on("requestReportParams", this.requestrReportParams);
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
    // add FNDI-FIXBUG 最新の小数点以下の桁数を使用 関 start
    var examItems = await sendRequestGetMstExamItemList(this.getFacilityCd);
    examItems.data.forEach(everyItem => {
      if (everyItem.isDisp == 1 && everyItem.facilityCd == this.getFacilityCd) {
        this.examItemMap[everyItem.examItemCd] = everyItem;
      }
    });
    // add FNDI-FIXBUG 最新の小数点以下の桁数を使用 関 end
    // del #10359 編集権限の動作不正 dengshen start
    // //mod 編集権限の適用 劉全航 start
    // this.editAuthority = this.getStateUserAccountInfo
    // .userSettings
    // .authorized_authorities
    // .includes(AUTHORITY_CODES.RST_EXAM_EDIT);
    // //mod 編集権限の適用 劉全航 end
    // del #10359 編集権限の動作不正 dengshen end

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
    // this.isInitFinished = true;
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    //add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi start
    store.dispatch("loading-screen/setLoadingScreenVisible", false);
    //add #7851 exam_rst連携で受信した検査データの編集後保存ができない 20220727 zhaoqi end
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  async mounted() {
    // ログインアカウントセット
    this.setUserAccountInfo(this.getStateUserAccountInfo);
    // add FNSI-入力欄右側にスピナー表示 関 start
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
    await this.copyTableDataFromExamMainDataSource();
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    this.initDataArrayFromExamResult();
    this.initCommentArrayFromExamResult();
    // ExamMainDataSource();
    let dataSource = this.getModalState === 0 ? this.getExamMainDataSource.filter(e => e.facilityCd === this.getFacilityCd) : this.getExamMainDataSource;
    // storeからデータを取得
    new Kendo.data.DataSource({
      data: dataSource
    })
    // add FNSI-入力欄右側にスピナー表示 関 end
    // this.$nextTick(() => {
    //   this.calculateGridHeight(true);
    // });

    this.comparisonModel = JSON.stringify(this.ExamMainDataSource._data);
    let today = moment(new Date());
    this.today =  today.format("YYYY-MM-DD");
    if (this.getModalState === 1) {
      this.examDate = this.getExamDate;
      this.examTime = this.getExamTime;
      this.examSelectDiv = this.getExamSelectDiv;
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.openPageExamDate = this.examDate;
      // this.openPageExamTime = this.examTime;
      // this.openPageExamSelectDiv = this.examSelectDiv;
      this.openPageExamDate = JSON.parse(JSON.stringify(this.examDate));
      this.openPageExamTime = JSON.parse(JSON.stringify(this.examTime));
      this.openPageExamSelectDiv = JSON.parse(JSON.stringify(this.examSelectDiv));
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    } else {
      this.examDate = today.format("YYYY-MM-DD");
      this.examTime = today.format("HH:mm");
      this.examSelectDiv = -1;
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
      // this.openPageExamDate = this.examDate;
      // this.openPageExamTime = this.examTime;
      // this.openPageExamSelectDiv = this.examSelectDiv;
      this.openPageExamDate = JSON.parse(JSON.stringify(this.examDate));
      this.openPageExamTime = JSON.parse(JSON.stringify(this.examTime));
      this.openPageExamSelectDiv = JSON.parse(JSON.stringify(this.examSelectDiv));
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
    }
    //mod FNSI-障害票一覧_検査結果 NO.19 劉全航 start
    var nodeList = document.getElementsByName("examDivList");
    nodeList[1].style.backgroundColor = "#ffff99";
    //mod FNSI-障害票一覧_検査結果 NO.19 劉全航 end
    // add #7697 【デグレ】検査データをdelキーで削除すると項目が非表示になる 鄭爽 start
    // if (this.changeDataArray.length == 0) {
    this.changeDataArray = JSON.parse(JSON.stringify(this.dataArray));
    // }
    // add #7697 【デグレ】検査データをdelキーで削除すると項目が非表示になる 鄭爽 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc start
    this.initexamSetCd = JSON.stringify(this.localCondition.examSetCd);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_検査結果（↓） 20231128 ztc end
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("filterExamMain");
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    this.setIsOpenFlag(false);
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
.kendo-grid-style-page-modal {
  display: flex;
  flex-flow: column;
  flex-wrap: nowrap;
  height: 100%;
  margin: 0 5px;
}
.exam-record-head {
  color: white;
  background-color: #333333;
  width: 100%;
}
.modalInput{
  font-size:1em;
  width: 16em;
  vertical-align:center;
}
.select-input{
  font-size: 1.0em;
  border:1px;
}
.custom-ons-input >>> .text-input {
  font-size: inherit;
}
/* add FutreNetWeb+SI課題管理No6464 趙 start */
table.scroll-table-data,
table.scroll-table-data th,
table.scroll-table-data td {
  border: 1px solid var(--ntss-border-color);
}
/* add FutreNetWeb+SI課題管理No6464 趙 end */
</style>
<!--add FNSI-入力欄右側にスピナー表示 関 start -->
<style>
.scroll-area {
  width: auto;
  /* height: 100%; */
}
/* del FutreNetWeb+SI課題管理No6464 趙 start */
/*table.scroll-table-data,*/
/*table.scroll-table-data th,*/
/*table.scroll-table-data td {*/
/*  border: 1px solid var(--ntss-border-color);*/
/*}*/
/* del FutreNetWeb+SI課題管理No6464 趙 end */
table.scroll-table-data td > * {
  vertical-align: middle;
}

.scroll-table-data {
  border-collapse: collapse;
  /* min-width: 800px; */
}
/* add FNSI-Fixed header 関 start */
.top-fix {
  top: 0px;
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: unset;
  text-align: left;
  position: sticky;
}
/* add FNSI-Fixed header 関 end */
/* mod FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 start */
/* .exam-table-input {
  border: 0px!important;
  width: 100%;
  text-align: left!important;
  background-color: #fafafa!important;
} */
.exam-table-input {
  border: 1px solid var(--ntss-border-color);
  width: 100%;
  background-color: transparent;
}
/* mod FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 end */
/* add FNSI-Add Edit Style 関 start */
.exam-table-input:focus {
  border: 2px green solid !important;
}
/* add FNSI-Add Edit Style 関 end */
/* add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 start */
.exam-commentTextarea{
  border: 0.5px solid var(--ntss-border-color);
  width: 100%;
  background-color: transparent;
  border-radius: 6px;
}
/* add FNSI-改修内容「テキストエリアの動作」を「追加」に変更 江 end */
.exam-table-td {
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 12px;
  padding-right: 12px;
}
.exam-height-0 {
  height: 0px!important;
  overflow:hidden;
  visibility: hidden;
}
.exam-table-input-right{
  text-align: right;
}
.is-input-edit {
  border: 2px green solid !important;
}
/* ボタン部 モバイル対応 */
@media screen and (max-width: 420px) {
  .registration-btn-area {
    margin-right: unset !important;
  }
  .denial-btn-area {
    margin-left: unset !important;
  }
}
/* add #9461  by zhangruixue 2023-08-17 --start */
.modal-body {
  margin: 0px 0;
  position: absolute;
  top: 50px;
  width: 100%;
  height: calc(100% - 70px - 2em);
  color: var(--ntss-base-color);
}
/* add #9461  by zhangruixue 2023-08-17 --end */
</style>
<!--add FNSI-入力欄右側にスピナー表示 関 end -->

