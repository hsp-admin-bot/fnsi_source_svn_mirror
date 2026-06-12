/**
 * 実績情報アコーディオン内部
 */
<template>
  <div class="expandable-content">
    <div>
      <!--- 入外区分 -->
      <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <com-radio name="in-out-class" labelName="入外区分" :disabled="!isShared" :radioItems=inOutClassList v-model="inputModel.rst_in_out_class"/> -->
      <com-radio
        name="in-out-class"
        labelName="入外区分"
        :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
        :radioItems=inOutClassList
        v-model="inputModel.rst_in_out_class"/>
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
      <!-- 治療方法 -->
      <v-ons-row class="treatment">
        <v-ons-col class="title">
          <label>治療方法</label>
        </v-ons-col>
        <v-ons-col id="treatment-td" class="d-flex flex-column justify-content-center treatment-record-selectbox">
        <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
          <!-- mod #10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select -->
          <!--   :class="inputClass('rst_treatment_cd')" -->
          <!--   class="selectbox" -->
          <!--   input-id="treatment-cd" -->
          <!--   model-event="change" -->
          <!--   v-model="inputModel.rst_treatment_cd" -->
          <!--   name="treatment-cd" -->
          <!--   :disabled="!isShared" -->
          <!-- > -->
          <!-- <v-ons-select
            :class="inputClass('rst_treatment_cd')"
            class="selectbox"
            input-id="treatment-cd"
            model-event="change"
            v-model="inputModel.rst_treatment_cd"
            name="treatment-cd"
            :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
          > -->
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <v-ons-select
          :class="inputClass('rst_treatment_cd')"
          class="selectbox"
          input-id="treatment-cd"
          model-event="change"
          v-model="inputModel.rst_treatment_cd"
          name="treatment-cd"
          :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
          @change="changeTreatmentCd"
        >
          <!-- mod #10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end -->
        <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
            <option v-if="!isTreatmentCdExist" :value="inputModel.rst_treatment_cd">
              {{ inputModel.rst_treatment_name }}
            </option>
            <option
              v-for="(item, index) in comboList.treatment"
              :key="index"
              :value="item.cd"
              :hidden="item.hidden"
              :disabled="item.hidden"
            >{{ item.text }}</option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <!-- 透析回数 -->
      <!--- mod FNSI-最大長度 :min=0 => :min=1 孫灝 2020/10/26 start -->
      <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!--- <com-number-input -->
      <!---   :inputType='"number"' -->
      <!---   labelName="透析回数" -->
      <!---   unitName="回" -->
      <!---   input-min-width="10em" -->
      <!---   :step=1 -->
      <!---   :inputMin=1 -->
      <!---   :inputMax=99999 -->
      <!---   v-show="!isPurification" -->
      <!---   :disabled="!isShared" -->
      <!---   :initValue="initData.rst_dialysis_cnt" -->
      <!---   v-model="inputModel.rst_dialysis_cnt" /> -->
      <com-number-input
        :inputType='"number"'
        labelName="透析回数"
        unitName="回"
        input-min-width="10em"
        :step=1
        :inputMin=1
        :inputMax=99999
        v-show="!isPurification"
        :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
        :initValue="initData.rst_dialysis_cnt"
        v-model="inputModel.rst_dialysis_cnt" />
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
      <!--- mod FNSI-最大長度 :min=0 => :min=1 孫灝 2020/10/26 end -->
      <!-- 特殊浄化回数 -->
      <!--- mod FNSI-最大長度 :min=0 => :min=1 孫灝 2020/10/26 start -->
      <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <com-number-input -->
      <!-- :inputType='"number"' -->
      <!--   labelName="特殊浄化回数" -->
      <!--   unitName="回" -->
      <!--   input-min-width="10em" -->
      <!--   :step=1 -->
      <!--   :inputMin=1 -->
      <!--   :inputMax=99999 -->
      <!--   v-show="isPurification" -->
      <!--   :disabled="!isShared" -->
      <!--   :initValue="initData.rst_purification_cnt" -->
      <!--   v-model="inputModel.rst_purification_cnt" /> -->
      <com-number-input
      :inputType='"number"'
        labelName="特殊浄化回数"
        unitName="回"
        input-min-width="10em"
        :step=1
        :inputMin=1
        :inputMax=99999
        v-show="isPurification"
        :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
        :initValue="initData.rst_purification_cnt"
        v-model="inputModel.rst_purification_cnt" />
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
      <!--- mod FNSI-最大長度 :min=0 => :min=1 孫灝 2020/10/26 end -->
      <v-ons-row class="dialysis-time">
        <v-ons-col class="title" >
          <label>治療時間</label>
        </v-ons-col>
        <v-ons-col id="dialysis-time-td" class="d-flex align-items-center">
          <label>{{ inputModel.rst_dialysis_time }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="dialysis-start-datetime">
        <v-ons-col class="title">
          <label>治療開始日時</label>
        </v-ons-col>

        <v-ons-col id="dialysis-start-datetime-td" >
          <div>
            <div style="display: flex; flex-wrap: nowrap; min-width: 16em;">
              <!-- 透析時間を自動で計算をしており、validate用にmodel-event="blur"にすると干渉してしまうため、changeにした -->
              <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
              <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
              <!-- <input
                class="ntss-input-date ntss-control-size"
                type="date"
                id="dialysis-start-date"
                model-event="change"
                v-model="inputModel.rst_dialysis_start_date"
                @blur="recalcDialysisTime"
                name="dialysis-start-date"
                v-rules="'date_format:yyyy-MM-dd'"
                :disabled="!isShared"
              /> -->
              <!-- mod FNSI修正 redmine3913 房 start -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                :class="timeClass('rst_dialysis_start_date')"
                class="ntss-input-date ntss-control-size start-date"
                type="date"
                id="dialysis-start-date"
                model-event="change"
                v-model="inputModel.rst_dialysis_start_date"
                @blur="recalcDialysisTime"
                name="dialysis-start-date"
                max="9999-12-31"
                v-rules="'date_format:yyyy-MM-dd'"
                :disabled="!isShared"
                @keyup="showStartMsg"
                @change="changeStartFlag()"
              /> -->
              <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start  -->
              <!-- <date-input
                v-model="inputModel.rst_dialysis_start_date"
                id="dialysis-start-date"
                name="dialysis-start-date"
                :class="timeClass('rst_dialysis_start_date')"
                :classes="'ntss-input-date ntss-control-size start-date'"
                :disabled="!isShared"
                model-event="change"
                max="9999-12-31"
                v-rules="'date_format:yyyy-MM-dd'"
                @keyup="showStartMsg"
                @blur="recalcDialysisTime"
                @change="changeStartFlag()"
                @handleClearInput="inputModel.rst_dialysis_start_date = null"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <date-input -->
              <!--   v-model="inputModel.rst_dialysis_start_date" -->
              <!--   id="dialysis-start-date" -->
              <!--   name="dialysis-start-date" -->
              <!--   :classes="'ntss-input-date ntss-control-size start-date ' + timeClass('rst_dialysis_start_date')" -->
              <!--   :disabled="!isShared" -->
              <!--   model-event="change" -->
              <!--   max="9999-12-31" -->
              <!--   v-rules="'date_format:yyyy-MM-dd'" -->
              <!--   @keyup="showStartMsg" -->
              <!--   @blur="recalcDialysisTime" -->
              <!--   @change="changeStartFlag()" -->
              <!--   @handleClearInput="inputModel.rst_dialysis_start_date = null" -->
              <!-- /> -->
              <date-input
                v-model="inputModel.rst_dialysis_start_date"
                id="dialysis-start-date"
                name="dialysis-start-date"
                :classes="'ntss-input-date ntss-control-size start-date ' + timeClass('rst_dialysis_start_date')"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                model-event="change"
                max="9999-12-31"
                v-rules="'date_format:yyyy-MM-dd'"
                @keyup="showStartMsg"
                @blur="recalcDialysisTime"
                @change="changeStartFlag()"
                @handleClearInput="inputModel.rst_dialysis_start_date = null"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end  -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <!-- mod FNSI修正 redmine3913 房 end -->
              <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
              <!-- <p
                v-show="hasValidationError('dialysis-start-date')"
                class="error-message"
              >{{ getValidationError('dialysis-start-date') }}</p> -->
              <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
            <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <common-calendar :disabled="!isShared" v-model="inputModel.rst_dialysis_start_date" @input="changeStartFlag(1)" /> -->
              <common-calendar
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                v-model="inputModel.rst_dialysis_start_date"
                @input="changeStartFlag(1)" />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!-- mod FNSI修正 redmine3913 房 start -->
            <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
            <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
            <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <v-ons-input
                :class="inputClass('rst_dialysis_start_time')"
                type="time"
                input-id="dialysis-start-time"
                model-event="change"
                v-model="inputModel.rst_dialysis_start_time"
                @blur="recalcDialysisTime"
                name="dialysis-start-time"
                v-rules="'date_format:HH:mm'"
                :disabled="!isShared"
                @change="changeStartFlag()"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <time-input -->
              <!--   :classes="inputClass('rst_dialysis_start_time')" -->
              <!--   input-id="dialysis-start-time" -->
              <!--   model-event="change" -->
              <!--   name="dialysis-start-time" -->
              <!--   v-model="inputModel.rst_dialysis_start_time" -->
              <!--   @blur="recalcDialysisTime" -->
              <!--   :disabled="!isShared" -->
              <!--   @change="changeStartFlag" -->
              <!--   @handleClearInput="inputModel.rst_dialysis_start_time = null" -->
              <!-- /> -->
              <time-input
                :classes="inputClass('rst_dialysis_start_time')"
                input-id="dialysis-start-time"
                model-event="change"
                name="dialysis-start-time"
                v-model="inputModel.rst_dialysis_start_time"
                @blur="recalcDialysisTime"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                @change="changeStartFlag"
                @handleClearInput="inputModel.rst_dialysis_start_time = null"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
            <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
              <p
                v-show="hasValidationError('dialysis-start-time')"
                class="error-message"
              >{{ getValidationError('dialysis-start-time') }}</p>
            </div>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <span v-if="showErrorStartDate" class="error-message">{{ this.msgDiaLog }}</span>
            <span v-if="hasDialysisDateError && !showErrorStartDate" class="error-message">{{ startDialysisDateErrorMessage }}</span>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
            <!-- mod FNSI修正 redmine3913 房 end -->
          </div>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="dialysis-end-datetime">
        <v-ons-col class="title">
          <label>治療終了日時</label>
        </v-ons-col>

        <v-ons-col id="dialysis-end-datetime-td">
          <div>
            <div style="display: flex; flex-wrap: nowrap; min-width: 16em;">
              <!-- 透析時間を自動で計算をしており、validate用にmodel-event="blur"にすると干渉してしまうため、changeにした -->
              <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
              <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
              <!-- <input
                class="ntss-input-date ntss-control-size"
                type="date"
                id="dialysis-end-date"
                model-event="change"
                v-model="inputModel.rst_dialysis_end_date"
                @blur="recalcDialysisTime"
                name="dialysis-end-date"
                v-rules="'date_format:yyyy-MM-dd'"
                :disabled="!isShared"
              /> -->
              <!-- mod FNSI修正 redmine3913 房 start -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                :class="timeClass('rst_dialysis_end_date')"
                class="ntss-input-date ntss-control-size"
                type="date"
                id="dialysis-end-date"
                model-event="change"
                v-model="inputModel.rst_dialysis_end_date"
                @blur="recalcDialysisTime"
                name="dialysis-end-date"
                v-rules="'date_format:yyyy-MM-dd'"
                max="9999-12-31"
                :disabled="!isShared"
                @keyup="showEndMsg"
                @change="changeEndFlag()"
              /> -->
              <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start -->
              <!-- <date-input
                :class="timeClass('rst_dialysis_end_date')"
                :classes="'ntss-input-date ntss-control-size'"
                id="dialysis-end-date"
                model-event="change"
                v-model="inputModel.rst_dialysis_end_date"
                @blur="recalcDialysisTime"
                name="dialysis-end-date"
                v-rules="'date_format:yyyy-MM-dd'"
                :disabled="!isShared"
                @keyup="showEndMsg"
                @change="changeEndFlag()"
                @handleClearInput="inputModel.rst_dialysis_end_date = null"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <date-input -->
              <!--   :classes="'ntss-input-date ntss-control-size ' + timeClass('rst_dialysis_end_date')" -->
              <!--   id="dialysis-end-date" -->
              <!--   model-event="change" -->
              <!--   v-model="inputModel.rst_dialysis_end_date" -->
              <!--   @blur="recalcDialysisTime" -->
              <!--   name="dialysis-end-date" -->
              <!--   v-rules="'date_format:yyyy-MM-dd'" -->
              <!--   :disabled="!isShared" -->
              <!--   @keyup="showEndMsg" -->
              <!--   @change="changeEndFlag()" -->
              <!--   @handleClearInput="inputModel.rst_dialysis_end_date = null" -->
              <!-- /> -->
              <date-input
                :classes="'ntss-input-date ntss-control-size ' + timeClass('rst_dialysis_end_date')"
                id="dialysis-end-date"
                model-event="change"
                v-model="inputModel.rst_dialysis_end_date"
                @blur="recalcDialysisTime"
                name="dialysis-end-date"
                v-rules="'date_format:yyyy-MM-dd'"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                @keyup="showEndMsg"
                @change="changeEndFlag()"
                @handleClearInput="inputModel.rst_dialysis_end_date = null"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <!-- mod FNSI修正 redmine3913 房 end -->
             <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
              <!-- <p
                v-show="hasValidationError('dialysis-end-date')"
                class="error-message"
              >{{ getValidationError('dialysis-end-date') }}</p> -->
              <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
             <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <common-calendar :disabled="!isShared" v-model="inputModel.rst_dialysis_end_date" @input="changeEndFlag(1)" /> -->
              <common-calendar
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                v-model="inputModel.rst_dialysis_end_date"
                @input="changeEndFlag(1)" />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!-- mod FNSI修正 redmine3913 房 start -->
             <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
             <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
             <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <v-ons-input
                :class="inputClass('rst_dialysis_end_time')"
                type="time"
                input-id="dialysis-end-time"
                model-event="change"
                v-model="inputModel.rst_dialysis_end_time"
                @blur="recalcDialysisTime"
                name="dialysis-end-time"
                v-rules="'date_format:HH:mm'"
                :disabled="!isShared"
                @change="changeEndFlag()"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <time-input -->
              <!--   :classes="inputClass('rst_dialysis_end_time')" -->
              <!--   input-id="dialysis-end-time" -->
              <!--   model-event="change" -->
              <!--   v-model="inputModel.rst_dialysis_end_time" -->
              <!--   @blur="recalcDialysisTime" -->
              <!--   name="dialysis-end-time" -->
              <!--   v-rules="'date_format:HH:mm'" -->
              <!--   :disabled="!isShared" -->
              <!--   @change="changeEndFlag()" -->
              <!--   @handleClearInput="inputModel.rst_dialysis_end_time = null" -->
              <!-- /> -->
              <time-input
                :classes="inputClass('rst_dialysis_end_time')"
                input-id="dialysis-end-time"
                model-event="change"
                v-model="inputModel.rst_dialysis_end_time"
                @blur="recalcDialysisTime"
                name="dialysis-end-time"
                v-rules="'date_format:HH:mm'"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                @change="changeEndFlag()"
                @handleClearInput="inputModel.rst_dialysis_end_time = null"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- //#5590 2023/04/20 ×を常に表示するように修正 張博 end -->
             <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
              <p
                v-show="hasValidationError('dialysis-end-time')"
                class="error-message"
              >{{ getValidationError('dialysis-end-time') }}</p>
            </div>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <span v-if="showErrorEndDate" class="error-message">{{ this.msgDiaLog }}</span>
            <span v-if="hasDialysisDateError && !showErrorEndDate" class="error-message">{{ endDialysisDateErrorMessage }}</span>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
            <!-- mod FNSI修正 redmine3913 房 end -->
          </div>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="kur">
        <v-ons-col class="title">
          <label>クール</label>
        </v-ons-col>

        <v-ons-col id="kur-td" class="d-flex flex-column justify-content-center treatment-record-selectbox">
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select -->
          <!--   :class="inputClass('rst_kur_cd')" -->
          <!--   class="selectbox" -->
          <!--   input-id="kur-cd" -->
          <!--   model-event="change" -->
          <!--   v-model="inputModel.rst_kur_cd" -->
          <!--   name="kur-cd" -->
          <!--   :disabled="!canChange || !isShared" -->
          <!-- > -->
          <v-ons-select
            :class="inputClass('rst_kur_cd')"
            class="selectbox"
            input-id="kur-cd"
            model-event="change"
            v-model="inputModel.rst_kur_cd"
            name="kur-cd"
            :disabled="!canChange || !isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
            <option
              v-for="(item, index) in kurOptions"
              :key="index"
              :value="item.cd"
              :hidden="item.hidden"
              :disabled="item.hidden"
            >{{ item.text }}</option>
          </v-ons-select>
          <p v-show="hasValidationError('kur-cd')" class="error-message">{{ getValidationError('kur-cd') }}</p>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="bed">
        <v-ons-col class="title">
          <label>ベッド</label>
        </v-ons-col>

        <v-ons-col id="bed-td" class="d-flex flex-column justify-content-center treatment-record-selectbox">
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select -->
          <!--   :class="inputClass('rst_bed_cd')" -->
          <!--   class="selectbox" -->
          <!--   input-id="bed-cd" -->
          <!--   model-event="change" -->
          <!--   v-model="inputModel.rst_bed_cd" -->
          <!--   name="bed-cd" -->
          <!--   :disabled="!canChange || !isShared" -->
          <!--   @change="changeBedName(inputModel.rst_bed_cd, $event.target)" -->
          <!-- > -->
          <v-ons-select
            :class="inputClass('rst_bed_cd')"
            class="selectbox"
            input-id="bed-cd"
            model-event="change"
            v-model="inputModel.rst_bed_cd"
            name="bed-cd"
            :disabled="!canChange || !isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
            @change="changeBedName(inputModel.rst_bed_cd, $event.target)"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
            <option
              v-for="(item, index) in bedOptions"
              :key="index"
              :value="item.cd"
              :hidden="item.hidden"
              :disabled="item.hidden"
            >{{ item.text }}</option>
          </v-ons-select>
          <p v-show="hasValidationError('bed-cd')" class="error-message">{{ getValidationError('bed-cd') }}</p>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="ward">
        <v-ons-col class="title">
          <label>病棟名</label>
        </v-ons-col>

        <v-ons-col id="ward-td" class="d-flex flex-column justify-content-center treatment-record-selectbox">
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select -->
          <!--   :class="inputClass('rst_ward_cd')" -->
          <!--   class="selectbox" -->
          <!--   input-id="ward-cd" -->
          <!--   model-event="change" -->
          <!--   v-model="inputModel.rst_ward_cd" -->
          <!--   :disabled="!isShared" -->
          <!-- > -->
          <v-ons-select
            :class="inputClass('rst_ward_cd')"
            class="selectbox"
            input-id="ward-cd"
            model-event="change"
            v-model="inputModel.rst_ward_cd"
            :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
            <option
              v-for="(item, index) in wardOptions"
              :key="index"
              :value="item.cd"
              :hidden="item.hidden"
              :disabled="item.hidden"
            >{{ item.text }}</option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="course">
        <v-ons-col class="title">
          <label>診療科</label>
        </v-ons-col>

        <v-ons-col id="course-td" class="d-flex align-items-center treatment-record-selectbox">
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 start -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select -->
          <!--   :class="inputClass('rst_course_cd')" -->
          <!--   class="selectbox" -->
          <!--   input-id="course-cd" -->
          <!--   model-event="change" -->
          <!--   v-model="inputModel.rst_course_cd" -->
          <!--   :disabled="!isShared" -->
          <!-- > -->
          <v-ons-select
            :class="inputClass('rst_course_cd')"
            class="selectbox"
            input-id="course-cd"
            model-event="change"
            v-model="inputModel.rst_course_cd"
            :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
         <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
            <option
              v-for="(item, index) in courseOptions"
              :key="index"
              :value="item.cd"
              :hidden="item.hidden"
              :disabled="item.hidden"
            >{{ item.text }}</option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import {
  DATE_FORMAT,
  SHORT_TIME_FORMAT,
  dateFormat,
  parseDate
} from "@/functions/common/DateTimeUtils.js";
// add FNSI-8347 ljx start
// add FNSI-8347 ljx end
import { MSG_DIALYSIS_DATE_OPPOSITE } from "@/components/treatment-record/constants/messages";
import { CODES } from "@/constants/TreatmentRecord.js";
//mod 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
//import { mapGetters} from "@/compat/vue/vuex";
import { mapGetters ,mapActions} from "@/compat/vue/vuex";
//mod 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
// del #10359 編集権限の動作不正 dengshen start
// 権限コード定数
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// del #10359 編集権限の動作不正 dengshen end

// ラジオボタンの共通コンポーネント
import CommonRadio from "@/components/treatment-record/submenu/common/CommonRadioComponent";
// 数値入力の共通コンポーネント
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
// add FNSI-横展開 日付のチェックの追加 徐 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-横展開 日付のチェックの追加 徐 end

export default {
  components: {
    "common-calendar": commonCalender,
    "com-number-input": CommonNumberInputComponent,
    "com-radio": CommonRadio,
    DateInput,
    TimeInput
  },
  // 親 ResultComponent が `:value` / `@input` の明示バインディングで使用しているため
  // Vue2 と同じ props/event 形式を維持する。
  emits: ["input"],
  props: ["value", "comboData", "isPurification" ,
  //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
  "initDeviceMode" , "newDeviceMode"
  //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
],
  data() {
    return {
      initialValue: null,
      inputModel: {
        rst_in_out_class: undefined,
        rst_dialysis_cnt: 0,
        rst_start_date: "",
        rst_end_date: "",
        rst_kur_cd: "",
        rst_kur_name: "",
        rst_bed_cd: "",
        rst_bed_name: "",
        rst_ward_cd: "",
        rst_ward_name: "",
        rst_course_cd: "",
        rst_course_name: "",
        rst_dialysis_time: "",
        rst_dialysis_start_date: "",
        rst_dialysis_start_time: "",
        rst_dialysis_end_date: "",
        rst_dialysis_end_time: "",
        rst_dialysis_state: "",
        rst_treatment_cd: "",
        rst_treatment_name: "",
        rst_purification_cnt: 0
      },
      inOutClassList: CODES.IN_OUT_CLASS,
      comboList: {
        kur: undefined,
        bed: undefined,
        ward: undefined,
        course: undefined,
        treatment: undefined
      },
      // 治療方法切り替え時にセットする透析回数・特殊浄化回数
      onSwitchDialysisCountValue: 0,
      onSwitchPurificationCountValue: 0,
      // FNSI-修正、#6484 NG再対応、xugj del start
      // // inputModelの変更回数
      // numberOfInputModelChanges: 0,
      // FNSI-修正、#6484 NG再対応、 xugj del end
      // FNSI-修正、#6484 NG再対応、xugj add start
      // 治療方法変更フラッグ
      isTreatMethodChanged: false,
      // FNSI-修正、#6484 NG再対応、 xugj add end
      // クールとベッドが変更可能な治療状況
      canChangeKurAndBed: [
        // 条件送信前
        CODES.DIALYSIS_STATE.BEFORE_SEND_CONDITION.cd,
        // 後体重測定済み(実績未確定)
        CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.cd,
        // 後体重確認済み(過去実績)
        CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd,
      ],
      // add FNSI-横展開 日付のチェックの追加 徐 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      showErrorEndDate: false,
      // add FNSI-横展開 日付のチェックの追加 徐 end
      //add FNSI修正 redmine3913 房 start
      startChangeFlag: false,
      endChangeFlag: false,
      initData:{
        rst_in_out_class: undefined,
        rst_dialysis_cnt: 0,
        rst_start_date: "",
        rst_end_date: "",
        rst_kur_cd: "",
        rst_kur_name: "",
        rst_bed_cd: "",
        rst_bed_name: "",
        rst_ward_cd: "",
        rst_ward_name: "",
        rst_course_cd: "",
        rst_course_name: "",
        rst_dialysis_time: "",
        rst_dialysis_start_date: "",
        rst_dialysis_start_time: "",
        rst_dialysis_end_date: "",
        rst_dialysis_end_time: "",
        rst_dialysis_state: "",
        rst_treatment_cd: "",
        rst_treatment_name: "",
        rst_purification_cnt: 0
      },
      //add FNSI修正 redmine3913 房 end
      //add FNSI-redmine5858 fang start
      treatmentCheckFlg: false,
      //add FNSI-redmine5858 fang end
    };
  },
  watch: {
    value(val) {
      Object.assign(this.inputModel, this.value);
      this.inputModel.rst_in_out_class = (this.value.rst_in_out_class || this.value.rst_in_out_class === 0) ? String(this.value.rst_in_out_class) : null;
      this.inputModel.rst_dialysis_start_date = this.value.rst_start_date
        ? dateFormat.format(this.value.rst_start_date, DATE_FORMAT)
        : null;
      this.inputModel.rst_dialysis_start_time = this.value.rst_start_date
        ? dateFormat.format(this.value.rst_start_date, SHORT_TIME_FORMAT)
        : null;
      this.inputModel.rst_dialysis_end_date = this.value.rst_end_date
        ? dateFormat.format(this.value.rst_end_date, DATE_FORMAT)
        : null;
      this.inputModel.rst_dialysis_end_time = this.value.rst_end_date
        ? dateFormat.format(this.value.rst_end_date, SHORT_TIME_FORMAT)
        : null;
     //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
      this.inputModel.rst_dialysis_cnt = this.value.rst_dialysis_cnt
      ?  Number(this.value.rst_dialysis_cnt)
      : null;
      this.inputModel.rst_purification_cnt = this.value.rst_purification_cnt
      ?  Number(this.value.rst_purification_cnt)
      : null;
      //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
      Object.assign(this.initData, this.value);
      this.initData.rst_in_out_class = (this.value.rst_in_out_class || this.value.rst_in_out_class === 0) ? String(this.value.rst_in_out_class) : null;
      this.initData.rst_dialysis_start_date = this.value.rst_start_date
        ? dateFormat.format(this.value.rst_start_date, DATE_FORMAT)
        : null;
      this.initData.rst_dialysis_start_time = this.value.rst_start_date
        ? dateFormat.format(this.value.rst_start_date, SHORT_TIME_FORMAT)
        : null;
      this.initData.rst_dialysis_end_date = this.value.rst_end_date
        ? dateFormat.format(this.value.rst_end_date, DATE_FORMAT)
        : null;
      this.initData.rst_dialysis_end_time = this.value.rst_end_date
        ? dateFormat.format(this.value.rst_end_date, SHORT_TIME_FORMAT)
        : null;
      //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
      this.initData.rst_dialysis_cnt = this.value.rst_dialysis_cnt
      ?  Number(this.value.rst_dialysis_cnt)
      : null;
      this.initData.rst_purification_cnt = this.value.rst_purification_cnt
      ?  Number(this.value.rst_purification_cnt)
      : null;
      //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
      this.recalcDialysisTime();
    },
    comboData: {
      handler(newVal) {
        Object.assign(this.comboList, newVal);
      },
      deep: true,
      immediate: true
    },
    inputModel: {
      handler(newVal) {
        //add FNSI-6777 ljx start
        //バックグラウンドでベットのコードが特別処理されるので、保存する際に元の値を戻す。
     /*   if(newVal.toString().includes("000000000")){
          newVal.rst_bed_cd = newVal.rst_bed_cd/1000000000;
        }*/
        //add FNSI-6777 ljx end
        const value = {
          rst_kur_cd: newVal.rst_kur_cd,
          rst_kur_name: this.getComboDisplayName("kur"),
          rst_bed_cd: newVal.rst_bed_cd,
          //mod FNSI-8347 ljx start
          //rst_bed_name: this.getComboDisplayName("bed"),
          rst_bed_name: newVal.rst_bed_name,
          //add FNSI-8347 ljx end
          rst_start_date: parseDate(
            newVal.rst_dialysis_start_date,
            newVal.rst_dialysis_start_time
          ),
          rst_end_date: parseDate(
            newVal.rst_dialysis_end_date,
            newVal.rst_dialysis_end_time
          ),
          rst_in_out_class: (newVal.rst_in_out_class || newVal.rst_in_out_class === 0) ? Number(newVal.rst_in_out_class) : null,
          rst_dialysis_cnt: newVal.rst_dialysis_cnt ? Number(newVal.rst_dialysis_cnt) : null,
          rst_ward_cd: newVal.rst_ward_cd,
          rst_ward_name: this.getComboDisplayName("ward"),
          rst_course_cd: newVal.rst_course_cd,
          rst_course_name: this.getComboDisplayName("course"),
          // 治療方法
          rst_treatment_cd: newVal.rst_treatment_cd,
          rst_treatment_name: this.getComboDisplayName("treatment"),
          rst_purification_cnt: newVal.rst_purification_cnt ? Number(newVal.rst_purification_cnt) : null
        };
        this.$emit("input", value);
        //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
        // FNSI-修正、#6484 NG再対応、xugj add start
        // 治療方法を変更する場合
        // if(this.initData.rst_treatment_cd != newVal.rst_treatment_cd) {
        //   this.isTreatMethodChanged = true;
        // }
        // FNSI-修正、#6484 NG再対応、xugj add end
        //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
      },
      deep: true
    },
    // 透析開始・終了日時の監視
    dialysisDate(value) {
      // 透析開始・終了日時の変更をトリガとして、大小バリデーション実施
      this.validateField("dialysisDate", value);
    },
    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    // isPurification(value,old) {
    //   // FNSI-修正、#6484 NG再対応、xugj modify start
    //   let rstPurificationCnt = 0;
    //   let rstDialysisCnt = 0;
    //   if (this.isTreatMethodChanged) {
    //     rstPurificationCnt = this.onSwitchPurificationCountValue;
    //     rstDialysisCnt = this.onSwitchDialysisCountValue;
    //   } else {
    //     rstPurificationCnt = this.onSwitchPurificationCountValue - 1;
    //     rstDialysisCnt = this.onSwitchDialysisCountValue - 1;
    //   }

    //   if (value) {
    //     // 特殊浄化
    //     this.inputModel.rst_purification_cnt = rstPurificationCnt;
    //   } else {
    //     // 透析
    //     this.inputModel.rst_dialysis_cnt = rstDialysisCnt;
    //   }
    //   // FNSI-修正、#6484 NG再対応、xugj modify end
    // }
    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
  },
  computed: {
    ...mapGetters("pat-info", [
      "selectedPat",
    ]),
    // add FNSI-共有設定の追加 周雨晴 start
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getSharedFacilityCd",
       //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
      "getOrdNo",
       //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
    ]),
    // add FNSI-権限がない場合の追加 周雨晴 start
    ...mapGetters("pat-info", { patId: "selectedPatId", isNullPat: "isNullPat" }),
    // add FNSI-権限がない場合の追加 周雨晴 end
    ...mapGetters("user", ["getFacilityCd"]),
    // 利用者関連のGetter
    ...mapGetters("user", ["getUserAuthorityCds"]),
    // 透析開始・終了日時の取りまとめオブジェクト（`watch`による監視対象）
    dialysisDate() {
      return {
        start: this.getDialysisStartDatetime(),
        end: this.getDialysisEndDatetime()
      };
    },
    // 透析開始・終了時間の大小逆エラー有無
    hasDialysisDateError() {
      return this.getDialysisDateError();
    },
    //mod FNSI修正 redmine3913 房 start
    // 透析開始・終了時間の大小逆エラーメッセージ取得
    startDialysisDateErrorMessage() {
      if (this.startChangeFlag) {
        const error = this.getDialysisDateError();
        return error ? error.msg : "";
      }
      return "";
    },
    endDialysisDateErrorMessage() {
      if (this.endChangeFlag) {
        const error = this.getDialysisDateError();
        return error ? error.msg : "";
      }
      return "";
    },
    //mod FNSI修正 redmine3913 房 end

    /**
     * クール及びベッドが変更可能か否かを判断する.
     * 変更可否の判断は、rst_dialysis_stateが条件送信後～排液済までととする.
     * ユーザーに治療記録の操作権限がない場合には編集不可とする.
     * ※権限用のMixinで非活性にしているが、非活性後にこの処理が行われる為、
     *   権限で判定しないと活性化してしまう.
     *   その為、ここで権限チェックを行っている.
     *
     * @returns {Boolean} 変更可能な場合、trueを返す.
     */
    canChange() {
      // 編集権限がない場合
      // mod #10359 編集権限の動作不正 dengshen start
      // if (!(this.getUserAuthorityCds.includes(AUTHORITY_CODES.RST_EDIT) ||
      //       this.getUserAuthorityCds.includes(AUTHORITY_CODES.RST_PEDIT)) ||
      //       (this.patId === null && this.isNullPat)) {
      if (this.patId === null && this.isNullPat) {
      // mod #10359 編集権限の動作不正 dengshen end
        return false;
      }
      return this.canChangeKurAndBed.includes(this.inputModel.rst_dialysis_state);
    },
     // add FNSI-共有設定の追加 周雨晴 start
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    isTreatmentCdExist() {
      if (!this.inputModel.rst_treatment_cd) {
        return true;
      }
      return (this.comboList.treatment || []).some(item => item.cd === this.inputModel.rst_treatment_cd);
    },
    kurOptions() {
      return this.buildOptions(this.comboList.kur, this.inputModel.rst_kur_cd, this.inputModel.rst_kur_name);
    },
    bedOptions() {
      return this.buildOptions(this.comboList.bed, this.inputModel.rst_bed_cd, this.inputModel.rst_bed_name);
    },
    wardOptions() {
      return this.buildOptions(this.comboList.ward, this.inputModel.rst_ward_cd, this.inputModel.rst_ward_name);
    },
    courseOptions() {
      return this.buildOptions(this.comboList.course, this.inputModel.rst_course_cd, this.inputModel.rst_course_name);
    }
     // add FNSI-共有設定の追加 周雨晴 end
  },
  methods: {
     //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
    ...mapActions("treatment-record/result", [
      "getTreatmentRecordResult",
      //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      "getMedicalCareInfo"
      //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    ]),
     //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    buildOptions(list, cd, name) {
      const options = list || [];
      if (cd && !options.some(item => item.cd === cd)) {
        return [{ cd, text: name, hidden: false }, ...options];
      }
      return options;
    },
    // add #10359 編集権限の動作不正 dengshen end
    //add FNSI-redmine8347 ljx start
    //マスタのベット名が変更された場合、新名を使う
    changeBedName(cd, e) {
      let options = e._vOptions;
      let selectedOption = options.filter(x => x == cd);
      let bedNames = e.innerText.split("\n");
      let index  = options.lastIndexOf(cd);
      let selectedBadName = bedNames[index];
      this.inputModel.rst_bed_name = selectedBadName
      if (selectedOption.length > 1) {
        e.remove(0);
        this.$emit("input", this.inputModel);
      }
      //add FNSI-redmine8347 ljx end
    },
    // 透析開始・終了時間の大小逆エラー情報取得
    getDialysisDateError() {
      const errors = this.validationErrors.filter(
        value => value.field === "dialysisDate");
      return errors.length > 0 ? errors[0] : null;
    },
    // 透析開始日時
    getDialysisStartDatetime() {
      return parseDate(
        this.inputModel.rst_dialysis_start_date,
        this.inputModel.rst_dialysis_start_time
      );
    },
    // 透析終了日時
    getDialysisEndDatetime() {
      return parseDate(
        this.inputModel.rst_dialysis_end_date,
        this.inputModel.rst_dialysis_end_time
      );
    },
    // 透析時間の再計算
    recalcDialysisTime() {
      // 治療記録：実績情報画面の「治療終了日」の表示枠が間違っています 林峻峰 start
      this.inputModel.rst_dialysis_start_time = this.inputModel.rst_dialysis_start_time ? this.inputModel.rst_dialysis_start_time : null
      this.inputModel.rst_dialysis_end_time = this.inputModel.rst_dialysis_end_time ? this.inputModel.rst_dialysis_end_time : null
      // 治療記録：実績情報画面の「治療終了日」の表示枠が間違っています 林峻峰 end
      setTimeout(()=>{
        this.inputModel.rst_dialysis_time = "";
        const start = this.getDialysisStartDatetime();
        const end = this.getDialysisEndDatetime();
        if (start && end) {
          const diff = end.getTime() - start.getTime();
          const sign = diff >= 0 ? "" : "-";
          const diffMinutes = diff / (1000 * 60);
          const hours = Math.floor(Math.abs(diffMinutes) / 60);
          const minutes = ("00" + Math.abs(diffMinutes % 60)).slice(-2);
          //add FNSI-redmine5858 fang start
          if (sign == "" && hours >= 72) {
            if (hours > 72) {
              this.treatmentCheckFlg = true;
            } else if (minutes > 0) {
              this.treatmentCheckFlg = true;
            } else {
              this.treatmentCheckFlg = false;
            }
          } else {
            this.treatmentCheckFlg = false;
          }
          //add FNSI-redmine5858 fang end
          this.inputModel.rst_dialysis_time = `${sign}${hours}:${minutes}`;
        }
      }, 100);
    },
    // コンボから最新の名称を取得
    getComboDisplayName: function(name) {
      const isPast =
        this.inputModel.rst_dialysis_state ===
        CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd;

      if (this.comboList[name] !== undefined) {
        const cd = this.inputModel[`rst_${name}_cd`];
        const node = this.comboList[name].find(
          elem => (isPast || !elem.hidden) && elem.cd === cd
        );
        if (node !== undefined) {
          return node.text;
        }
      }
      return this.inputModel[`rst_${name}_name`];
    },

  // add FNSI-横展開 日付のチェックの追加 徐 start
  showStartMsg() {
    let saveButtonErrorFlg = {
          name: "rst_dialysis_start_date",
          id: "rst_dialysis_start_date",
          scope: "rst_dialysis_start_date"
        };
    if (this.inputModel.rst_dialysis_start_date && getScopedElementById("dialysis-start-date", this.$el || null)?.validationMessage) {
      this.showErrorStartDate = true;
      this.pushValidationError(saveButtonErrorFlg);
    } else {
      this.showErrorStartDate = false;
      this.removeValidationErrorById("rst_dialysis_start_date");
    }
  },
  showEndMsg() {
    let saveButtonErrorFlg = {
          name: "rst_dialysis_end_date",
          id: "rst_dialysis_end_date",
          scope: "rst_dialysis_end_date"
        };
    if (this.inputModel.rst_dialysis_end_date && getScopedElementById("dialysis-end-date", this.$el || null)?.validationMessage) {
      this.showErrorEndDate = true;
      this.pushValidationError(saveButtonErrorFlg);
    } else {
      this.showErrorEndDate = false;
      this.removeValidationErrorById("rst_dialysis_end_date");
    }
  },
  // add FNSI-横展開 日付のチェックの追加 徐 end
    //add FNSI修正 redmine3913 房 start
    changeEndFlag(flag){
      this.startChangeFlag = false;
      this.endChangeFlag = true;
      if (flag) {
        this.recalcDialysisTime();
      }
    },
    changeStartFlag(flag){
      this.endChangeFlag = false;
      this.startChangeFlag = true;
      if (flag) {
        this.recalcDialysisTime();
      }
    },
    //add FNSI修正 redmine3913 房 start
    inputClass(element){
      if (this.initData[element] != this.inputModel[element]) {
        return "custom-input-edited";
      } else {
        return "";
      }
    },
    timeClass(element){
      if (this.initData[element] == null && this.inputModel[element] == "") {
        return "";
      } else if (this.initData[element] != this.inputModel[element]) {
        return "time-input-edited";
      } else {
        return "";
      }
    },
    initValueEdit(){
      Object.assign(this.initData, this.inputModel);
    },
    //add FNSI-redmine5858 fang start
    checkTreatmentTime(){
      return this.treatmentCheckFlg;
    },
    //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    //治療方法変更
    changeTreatmentCd() {
      //変更後：特殊浄化かどうか
      let isPurificationNew = this.newDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd ? true : false;
      //初期値：特殊浄化かどうか
      let isPurificationInit = this.initDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd ? true : false;
      // mod 11454 時間外加算自動処理が機能していない zkm start
      if (this.patId === null && this.isNullPat) {
        //非特殊浄化->特殊浄化
        if (!isPurificationInit && isPurificationNew) {
          this.inputModel.rst_dialysis_cnt = null;
          this.inputModel.rst_purification_cnt = 1;
          //特殊浄化->非特殊浄化
        } else if (isPurificationInit && !isPurificationNew) {
          this.inputModel.rst_dialysis_cnt = 1;
          this.inputModel.rst_purification_cnt = null;
        } else {
          this.inputModel.rst_dialysis_cnt = this.initData.rst_dialysis_cnt;
          this.inputModel.rst_purification_cnt = this.initData.rst_purification_cnt;
        }
      } else {
        this.getMedicalCareInfo({ facilityCd: this.getFacilityCd, patId: this.patId }).then(res => {
          //非特殊浄化->特殊浄化
          if (!isPurificationInit && isPurificationNew) {
            this.inputModel.rst_dialysis_cnt = null;
            this.inputModel.rst_purification_cnt = Number(res.data.purificationCount) + 1;
            //特殊浄化->非特殊浄化
          } else if (isPurificationInit && !isPurificationNew) {
            this.inputModel.rst_dialysis_cnt = Number(res.data.dialysisCount) + 1;
            this.inputModel.rst_purification_cnt = null;
          } else {
            this.inputModel.rst_dialysis_cnt = this.initData.rst_dialysis_cnt;
            this.inputModel.rst_purification_cnt = this.initData.rst_purification_cnt;
          }
        })
      }
      // mod 11454 時間外加算自動処理が機能していない zkm end
    }
    //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    //add FNSI-redmine5858 fang end
  },
  //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
  async created() {
    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    // await this.getTreatmentRecordResult(this.getOrdNo).then( response => {
    //     const purificationCount = response.data.rst_purification_cnt === null ? 0 : Number(response.data.rst_purification_cnt);
    //     this.onSwitchPurificationCountValue = purificationCount + 1;
    //     const dialysisCount = response.data.dialysis_count === null ? 0 : Number(response.data.dialysis_count);
    //     this.onSwitchDialysisCountValue = dialysisCount + 1;
    //   })
    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
  },
  //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
   mounted() {
    let medicalCareInfo;
    // ？？？？患者(patId=null)表示対応
    if (this.selectedPat === null) {
      medicalCareInfo = {
        main_course_cd: null,
        dialysis_course_cd: null,
        ward_cd: null,
        dialysis_count: null,
        purification_count: null,
        other_dialysis_count: null,
        facility_cd: null,
        dialysis_start_date: null,
        hospital_start_date: null
      };
    } else {
      medicalCareInfo = JSON.parse(this.selectedPat.pat_main["medical_care_info"]);
    }
    //del 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
    // //FNSI-修正 #6484、初期化回数表示不正、再修正 xugj modify start
     //const dialysisCount = medicalCareInfo.dialysis_count === null ? 0 : Number(medicalCareInfo.dialysis_count);
    // const purificationCount = medicalCareInfo.purification_count === null ? 0 : Number(medicalCareInfo.purification_count);
    // //const purificationCount = initData.rst_purification_cnt === null ? 0 : Number(medicalCareInfo.purification_count);
    // //FNSI-修正 #6484、初期化回数表示不正、再修正 xugj modify end
     //this.onSwitchDialysisCountValue = dialysisCount + 1;
    // this.onSwitchPurificationCountValue = purificationCount + 1;
    //del 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
    // 透析開始・終了日時の大小カスタムバリデーション
    this.registerValidationRule("dialysisDate", (value) => {
      if (value && value.start && value.end) {
        return value.end.getTime() - value.start.getTime() >= 0 || MSG_DIALYSIS_DATE_OPPOSITE;
      }
      return true;
    });
    this.registerValidationField({
      id: "dialysisDate",
      fieldName: "dialysisDate",
      fullName: "dialysisDate",
      label: "透析日時",
      rules: "dialysisDate",
      getter: () => this.dialysisDate
    });
  }
};
</script>

<style scoped>
label {
  color: var(--treatment-record-text-color);
}
#dialysis-cnt-td label {
  margin-left: 0.5em;
}
#in-out-class-td label {
  margin-left: 0.5em;
  margin-right: 2em;
  white-space: nowrap;
}
ons-input[input-id="dialysis-cnt"] {
  width: 5em;
}
ons-select {
  min-width: 10em;
}
.selectbox {
  width: 25%;
  height: 2em;
}
.error-message {
  white-space: nowrap;
}
@media only screen and (max-width: 576px) {
  #in-out-class-td label {
    margin-right: 1em;
  }
}
.treatment-record-selectbox {
  width: 10em;
}
.custom-input-edited :deep(select) {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.custom-input-edited :deep(input) {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.time-input-edited {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.expandable-content {
  overflow: auto;
  padding: 0.2em 0px 0.2em 0;
}
</style>
