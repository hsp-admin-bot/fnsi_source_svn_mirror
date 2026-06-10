<!-- 投与薬剤新規登録モーダルベース画面 -->

<template>
  <modal-base @onClose="hideModal">
    <div slot="body" class="indInfo-style-modal-container scroll-style">
      <div
        v-if="settingData.showSegment"
        class="div-style"
        style="float: left;"
      >
        <v-ons-segment style="width: 120px;">
          <button value="0" @change="changeDialSegment">
            {{ settingData.segmentLabel1 }}
          </button>
          <button value="1" @change="changeDialSegment">
            {{ settingData.segmentLabel2 }}
          </button>
        </v-ons-segment>
      </div>
      <div
        v-if="settingData.showNewEdit"
        class="div-style"
        style="float: left;"
      >
        <v-ons-segment style="width: 120px;">
          <button value="0" @change="changeSegment">
            {{ settingData.segmentLabel3 }}
          </button>
          <button value="1" @change="changeSegment">
            {{ settingData.segmentLabel4 }}
          </button>
        </v-ons-segment>
      </div>
      <div class="IndBaseHeader">
        <div>
          <v-ons-row class="div-style" style="clear: left;">
            <v-ons-col class="indInfo-style-label-position">
              <label>開始日</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
              <!-- <input
                v-model="structData.indStartDate"
                :disabled="settingData.startDateEdit"
                type="date"
                class="date-input common-style-input ntss-input-date"
                data-target="indStartDate"
                onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                @focus="focusStartEditing()"
                @blur="
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
              /> -->
<!--              mod 8560 開始日の日付のキーボード入力が不正 張 start-->
              <!--<input
                v-model="structData.indStartDate"
                :disabled="settingData.startDateEdit"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date"
                data-target="indStartDate"
                onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                @focus="focusStartEditing()"
                @blur="
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
              />-->
              <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
              <!-- <input
                v-model="structData.indStartDate"
                :disabled="settingData.startDateEdit"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date date-start-input"
                data-target="indStartDate"
                onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                @focus="focusStartEditing()"
                max="9999-12-31"
                @blur="AdjustTreatStartDate(structData.indStartDate,true);
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <input -->
              <!--   v-model="structData.indStartDate" -->
              <!--   :disabled="settingData.startDateEdit" -->
              <!--   type="date" -->
              <!--   id="date-start" -->
              <!--   class="date-input common-style-input ntss-input-date date-start-input" -->
              <!--   data-target="indStartDate" -->
              <!--   onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)" -->
              <!--   @focus="focusStartEditing()" -->
              <!--   max="9999-12-31" -->
              <!--   @blur="AdjustTreatStartDate(structData.indStartDate,true); -->
              <!--     createKurAndTreatmentList($event); -->
              <!--     createNumDaysList($event,'indStartDate'); -->
              <!--   " -->
              <!-- /> -->
              <input
                v-model="structData.indStartDate"
                :disabled="settingData.startDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date date-start-input"
                data-target="indStartDate"
                onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                @focus="focusStartEditing()"
                max="9999-12-31"
                @blur="AdjustTreatStartDate(structData.indStartDate,true);
                  createKurAndTreatmentList($event);
                  createNumDaysList($event,'indStartDate');
                "
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 end -->
              <!-- <custom-calendar
                v-model="structData.indStartDate"
                :disabled-weekdays="disabledWeekdays"
                :is-disabled-past-dates="true"
                :disabled="settingData.startDateEdit"
                :disable-dates-after="disableDatesAfter"
                @input="
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <custom-calendar -->
              <!--   v-model="structData.indStartDate" -->
              <!--   :disabled-weekdays="disabledWeekdays" -->
              <!--   :disabled="settingData.startDateEdit" -->
              <!--   :disable-dates-after="disableDatesAfter" -->
              <!--   @input=" -->
              <!--     createKurAndTreatmentList($event); -->
              <!--     createNumDaysList($event,'indStartDate'); -->
              <!--   " -->
              <!-- /> -->
              <custom-calendar
                v-model="structData.indStartDate"
                :disabled-weekdays="disabledWeekdays"
                :disabled="settingData.startDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                :disable-dates-after="disableDatesAfter"
                @input="
                  createKurAndTreatmentList($event);
                  createNumDaysList($event,'indStartDate');
                "
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
            </v-ons-col>
            <v-ons-col class="sub-label">
              <label></label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="div-style">
            <v-ons-col class="indInfo-style-label-position">
              <label class="vertical-align-center">
                <!-- mod FNSI-5448 劉全航 start -->
                <!-- <input type="radio" @change="changeEndDateLabel" v-model="picked" value="1" > -->
                <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
                <!-- <input type="radio" @change="changeEndDateLabel(1)" v-model="picked" value="1" > -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input type="radio" @change="changeEndDateLabel(1)" v-model="picked" value="1" :disabled="settingData.endDateEdit"> -->
                <input
                  type="radio"
                  @change="changeEndDateLabel(1)"
                  v-model="picked"
                  value="1"
                  :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end -->
                <!-- mod FNSI-5448 劉全航 end -->
                終了日
              </label>
              <label class="vertical-align-center">
                <!-- mod FNSI-5448 劉全航 start -->
                <!-- <input type="radio" @change="changeEndDateLabel" v-model="picked" value="2"> -->
                <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
                <!-- <input type="radio" @change="changeEndDateLabel(2)" v-model="picked" value="2"> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input type="radio" @change="changeEndDateLabel(2)" v-model="picked" value="2" :disabled="settingData.endDateEdit"> -->
                <input
                  type="radio"
                  @change="changeEndDateLabel(2)"
                  v-model="picked"
                  value="2"
                  :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end -->
                <!-- mod FNSI-5448 劉全航 end -->
                回数
              </label>
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <v-ons-col>
                  <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
                  <!-- <input
                    v-show="endDateLabel === '終了日'"
                    v-model="structData.indEndDate"
                    :disabled="settingData.endDateEdit"
                    :min="structData.indStartDate"
                    :max="maxDate"
                    type="date"
                    data-target="indEndDate"
                    class="date-input common-style-input ntss-input-date"
                    @focus="focusStartEditing()"
                    @blur="
                      createKurAndTreatmentList($event);
                      createNumDaysList($event);
                    "
                  /> -->
                 <!-- <input
                    v-show="endDateLabel === '終了日'"
                    v-model="structData.indEndDate"
                    :disabled="settingData.endDateEdit"
                    :min="structData.indStartDate"
                    :max="maxDate"
                    type="date"
                    id="date-end"
                    data-target="indEndDate"
                    class="date-input common-style-input ntss-input-date"
                    @focus="focusStartEditing()"
                    @blur="
                      createKurAndTreatmentList($event);
                      createNumDaysList($event);
                    "
                  />-->
                  <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                  <!-- <input
                    v-show="endDateLabel === '終了日'"
                    v-model="structData.indEndDate"
                    :disabled="settingData.endDateEdit"
                    :min="structData.indStartDate"
                    :max="maxDate"
                    type="date"
                    id="date-end"
                    data-target="indEndDate"
                    class="date-input common-style-input ntss-input-date"
                    @focus="focusStartEditing()"
                    @blur="AdjustTreatStartDate(structData.indEndDate,false);
                      createKurAndTreatmentList($event);
                      createNumDaysList($event);
                    "
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <date-input -->
                  <!--   v-show="endDateLabel === '終了日'" -->
                  <!--   v-model="structData.indEndDate" -->
                  <!--   @handleClearInput="structData.indEndDate = ''; -->
                  <!--     AdjustTreatStartDate(structData.indEndDate,false); -->
                  <!--     createKurAndTreatmentList($event); -->
                  <!--     createNumDaysList($event);" -->
                  <!--   :disabled="settingData.endDateEdit" -->
                  <!--   :min="structData.indStartDate" -->
                  <!--   :max="maxDate" -->
                  <!--   id="date-end" -->
                  <!--   data-target="indEndDate" -->
                  <!--   class="date-input common-style-input ntss-input-date" -->
                  <!--   @focus="focusStartEditing()" -->
                  <!--   @blur="AdjustTreatStartDate(structData.indEndDate,false); -->
                  <!--     createKurAndTreatmentList($event); -->
                  <!--     createNumDaysList($event); -->
                  <!--   " -->
                  <!-- /> -->
                  <date-input
                    v-show="endDateLabel === '終了日'"
                    v-model="structData.indEndDate"
                    @handleClearInput="structData.indEndDate = '';
                      AdjustTreatStartDate(structData.indEndDate,false);
                      createKurAndTreatmentList($event);
                      createNumDaysList($event);"
                    :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                    :min="structData.indStartDate"
                    :max="maxDate"
                    id="date-end"
                    data-target="indEndDate"
                    class="date-input common-style-input ntss-input-date"
                    @focus="focusStartEditing()"
                    @blur="AdjustTreatStartDate(structData.indEndDate,false);
                      createKurAndTreatmentList($event);
                      createNumDaysList($event);
                    "
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                  <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 end -->
                  <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
                  <!-- <custom-calendar
                    v-show="endDateLabel === '終了日'"
                    v-model="structData.indEndDate"
                    :is-disabled-past-dates="true"
                    :disabled="settingData.endDateEdit"
                    :disable-dates-after="disableDatesAfter"
                    @input="
                      createKurAndTreatmentList($event);
                      createNumDaysList($event);
                    "
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <custom-calendar -->
                  <!--   v-show="endDateLabel === '終了日'" -->
                  <!--   v-model="structData.indEndDate" -->
                  <!--   :disabled="settingData.endDateEdit" -->
                  <!--   :disable-dates-before="disableDatesBefore" -->
                  <!--   :to-month="toMonth" -->
                  <!--   :disable-dates-after="disableDatesAfter" -->
                  <!--   @input=" -->
                  <!--     createKurAndTreatmentList($event); -->
                  <!--     createNumDaysList($event); -->
                  <!--   " -->
                  <!-- /> -->
                  <custom-calendar
                    v-show="endDateLabel === '終了日'"
                    v-model="structData.indEndDate"
                    :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                    :disable-dates-before="disableDatesBefore"
                    :to-month="toMonth"
                    :disable-dates-after="disableDatesAfter"
                    @input="
                      createKurAndTreatmentList($event);
                      createNumDaysList($event);
                    "
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
                  <!-- mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 start -->
                  <!-- <input
                    id="iputIndNumDays"
                    v-show="endDateLabel === '回数'"
                    v-model="structData.indNumDays.edit"
                    min="1"
                    :max="maxNumDays"
                    type="number"
                    class="date-input common-style-input"
                    @focus="focusStartEditing()"
                    @blur="createNumDaysList($event)"
                  /> -->
                   <input
                    id="iputIndNumDays"
                    v-show="endDateLabel === '回数'"
                    v-model="structData.indNumDays.edit"
                    type="number"
                    class="date-input common-style-input"
                    @focus="focusStartEditing()"
                    @change="inputNumber($event)"
                    @mousewheel.prevent="onMouseWheel($event)"
                    @blur="createNumDaysList($event)"
                  />
                  <!-- mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 end -->
                  <span v-show="endDateLabel === '回数'"> 回</span>
                </v-ons-col>
                <v-ons-col align="center" class="sub-label">
                  <label>{{ endDateSublabel }}</label>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="div-style" style="clear: left;">
            <v-ons-col class="indInfo-style-label-position">
              <label>投与間隔</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod 画面デザイン改善対応 李 start -->
              <!-- <v-ons-select
                v-model="structData.indDayIntervalSelected"
                class="date-input"
                @change="
                  refreshWeeks();
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
              >
                <option
                  v-for="(interval, index) in indDayIntervalOptions"
                  :key="index"
                  :value="interval.value"
                >
                  {{ interval.text }}
                </option>
              </v-ons-select> -->
              <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
              <!-- <v-ons-select
                id="v-ons-select-id"
                v-model="structData.indDayIntervalSelected"
                class="date-input"
                @change="
                  refreshWeeks();
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
              > -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-select -->
              <!--   id="v-ons-select-id" -->
              <!--   v-model="structData.indDayIntervalSelected" -->
              <!--   :disabled="settingData.endDateEdit" -->
              <!--   class="date-input" -->
              <!--   @change=" -->
              <!--     refreshWeeks(); -->
              <!--     createKurAndTreatmentList($event); -->
              <!--     createNumDaysList($event); -->
              <!--   " -->
              <!-- > -->
              <v-ons-select
                id="v-ons-select-id"
                v-model="structData.indDayIntervalSelected"
                :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                class="date-input"
                @change="
                  refreshWeeks();
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end -->
                <option
                  v-for="(interval, index) in indDayIntervalOptions"
                  :key="index"
                  :value="interval.value"
                >
                  {{ interval.text }}
                </option>
              </v-ons-select>
              <!-- mod 画面デザイン改善対応 李 end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row
            v-if="settingData.showWeeks && structData.cycleWeek == '0'"
            class="div-style"
          >
            <v-ons-col class="indInfo-style-label-position">
              <label>曜日</label>
            </v-ons-col>
            <v-ons-col>
              <div v-for="(week, index) in structData.indWeeks" :key="index">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input -->
                <!--   :checked="week.done" -->
                <!--   :disabled="weekEdit || week.disabled" -->
                <!--   :id="'indMediWeekCheck-' + index" -->
                <!--   class="onColor" -->
                <!--   type="checkbox" -->
                <!--   style="display: none;" -->
                <!--   @change="chkChange(week)" -->
                <!-- /> -->
                <input
                  :checked="week.done"
                  :disabled="weekEdit || week.disabled || !getItemAuthorized('Indication', 'default_authority')"
                  :id="'indMediWeekCheck-' + index"
                  class="onColor"
                  type="checkbox"
                  style="display: none;"
                  @change="chkChange(week)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <label :for="'indMediWeekCheck-' + index" onclick="null" style="cursor:pointer;" class="indInfo-style-week-button">{{ week.text }}</label>
              </div>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row
            v-if="settingData.showWeeks && structData.cycleWeek == '1'"
            class="div-style"
          >
            <v-ons-col class="indInfo-style-label-position">
              <label>曜日</label>
            </v-ons-col>
            <v-ons-col>
              <div v-for="(week, index) in structData.kakujituWeeks" :key="index">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input -->
                <!--   :checked="week.done" -->
                <!--   :disabled="weekEdit" -->
                <!--   :id="'indMediKakujituWeekCheck-' + index" -->
                <!--   class="onColor" -->
                <!--   type="checkbox" -->
                <!--   style="display: none;" -->
                <!--   @change="chkKakujituChange(week)" -->
                <!-- /> -->
                <input
                  :checked="week.done"
                  :disabled="weekEdit || !getItemAuthorized('Indication', 'default_authority')"
                  :id="'indMediKakujituWeekCheck-' + index"
                  class="onColor"
                  type="checkbox"
                  style="display: none;"
                  @change="chkKakujituChange(week)"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <label :for="'indMediKakujituWeekCheck-' + index" onclick="null" style="cursor:pointer;" class="indInfo-style-week-button">{{ week.text }}</label>
              </div>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="div-style">
            <v-ons-col class="indInfo-style-label-position">
              <label>初回投与日</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
              <!-- <input
                v-model="structData.indDayIntervalStartDate"
                type="date"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date"
                @input="createNumDaysList($event)"
                ref="startDate"
              /> -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                v-model="structData.indDayIntervalStartDate"
                type="date"
                id="date-first"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date"
                @input="createNumDaysList($event)"
                ref="startDate"
              /> -->
              <!-- <input
                v-model="structData.indDayIntervalStartDate"
                type="date"
                max="9999-12-31"
                id="date-first"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date"
                @input="createNumDaysList($event)"
                ref="startDate"
              /> -->
              <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
              <!-- <date-input
                v-model="structData.indDayIntervalStartDate"
                @handleClearInput="structData.indDayIntervalStartDate = null"
                id="date-first"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date"
                @input="createNumDaysList($event)"
                ref="startDate"
              /> -->
              <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
              <!-- <date-input
                v-model="structData.indDayIntervalStartDate"
                :disabled="true"
                id="date-first"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date date-first-input"
                @input="createNumDaysList($event)"
                ref="startDate"
              /> -->
              <!-- #10196 初回投与日  数字の手動入力はできません linjunfeng start-->
              <!-- <date-input
                v-model="structData.indDayIntervalStartDate"
                :disabled="settingData.endDateEdit"
                id="date-first"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date date-first-input"
                @input="createNumDaysList($event)"
                ref="startDate"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <input -->
              <!--   v-model="indDayIntervalStartDateInput" -->
              <!--   type="date" -->
              <!--   max="9999-12-31" -->
              <!--   id="date-first" -->
              <!--   onkeypress="function()" -->
              <!--   class="date-input common-style-input ntss-input-date" -->
              <!--   @blur="createNumDaysList($event);handleIndDayIntervalStartDateBlur($event)" -->
              <!--   ref="startDate" -->
              <!-- /> -->
              <!-- #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start -->
              <!-- <input
                v-model="indDayIntervalStartDateInput"
                type="date"
                max="9999-12-31"
                id="date-first"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date"
                @blur="createNumDaysList($event);handleIndDayIntervalStartDateBlur($event)"
                ref="startDate"
                :disabled="!getItemAuthorized('Indication', 'default_authority')"
              /> -->
              <input
                v-model="indDayIntervalStartDateInput"
                type="date"
                max="9999-12-31"
                id="date-first"
                onkeypress="function()"
                class="date-input common-style-input ntss-input-date"
                @blur="createNumDaysList($event, 'indDayIntervalStartDate');handleIndDayIntervalStartDateBlur($event)"
                ref="startDate"
                :disabled="!getItemAuthorized('Indication', 'default_authority')"
              />
              <!-- #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end -->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10196 初回投与日  数字の手動入力はできません linjunfeng end-->
              <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end -->
              <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 end -->
              <!-- add FNSI-FutreNetWeb+SI課題管理No.3993 李 start -->
              <!-- <custom-calendar
                v-model="structData.indDayIntervalStartDate"
                :disable-dates-after="disableDatesAfter"
                @input="createNumDaysList($event)"
              /> -->
              <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
              <!-- <custom-calendar
                :disabled="settingData.endDateEdit"
                v-model="structData.indDayIntervalStartDate"
                @input="createNumDaysList($event)"
                :is-disabled-past-dates="true"
                :selected-dates="dateList"
                :disabled-dates="disabledDateList"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <custom-calendar -->
              <!--   :disabled="settingData.endDateEdit" -->
              <!--   v-model="structData.indDayIntervalStartDate" -->
              <!--   :disable-dates-after="disableDatesAfter" -->
              <!--   @input="createNumDaysList($event)" -->
              <!--   :selected-dates="dateList" -->
              <!--   :disabled-dates="disabledDateList" -->
              <!-- /> -->
              <!-- modify 10266 by kangjie 20240712 start -->
<!--              <custom-calendar-->
<!--                :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"-->
<!--                v-model="structData.indDayIntervalStartDate"-->
<!--                :disable-dates-after="disableDatesAfter"-->
<!--                @input="createNumDaysList($event)"-->
<!--                :selected-dates="dateList"-->
<!--                :disabled-dates="disabledDateList"-->
<!--              />-->
              <!-- #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start -->
              <!-- <custom-calendar
                :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                v-model="structData.indDayIntervalStartDate"
                :disable-dates-after="disableDatesAfter"
                @input="createNumDaysList($event)"
                :selected-dates="firstTurnTreatDateList"
                :active-date="true"
              /> -->
              <custom-calendar
                :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                v-model="structData.indDayIntervalStartDate"
                :disable-dates-after="disableDatesAfter"
                @blur="createNumDaysList($event, 'indDayIntervalStartDate')"
                @todayButtonClick="createNumDaysList($event, 'indDayIntervalStartDate')"
                :selected-dates="firstTurnTreatDateList"
                :active-date="true"
              />
              <!-- #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end -->
              <!--modify 10266 by kangjie 20240712 end-->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end -->
              <!-- add FNSI-FutreNetWeb+SI課題管理No.3993 李 end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row v-if="settingData.showTreat" class="div-style">
            <v-ons-col class="indInfo-style-label-position">
              <label>変更対象治療方法</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <kendo-multiselect -->
              <!--   v-model="structData.selectedTreat" -->
              <!--   :data-source="structData.treatOptions" -->
              <!--   :data-text-field="treatText" -->
              <!--   :data-value-field="treatValue" -->
              <!--   :max-selected-items="treatMaxSelectedItems" -->
              <!--   :disabled="treatAndKurEdit" -->
              <!--   placeholder="すべて" -->
              <!--   @change=" -->
              <!--     createSelectedTreat($event); -->
              <!--     createKurList(dataList); -->
              <!--     createNumDaysList($event); -->
              <!--   " -->
              <!-- /> -->
              <kendo-multiselect
                v-model="structData.selectedTreat"
                :data-source="structData.treatOptions"
                :data-text-field="treatText"
                :data-value-field="treatValue"
                :max-selected-items="treatMaxSelectedItems"
                :disabled="treatAndKurEdit || !getItemAuthorized('Indication', 'default_authority')"
                placeholder="すべて"
                @change="
                  createSelectedTreat($event);
                  createKurList(dataList);
                  createNumDaysList($event);
                "
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row v-if="settingData.showKur" class="div-style">
            <v-ons-col class="indInfo-style-label-position">
              <label>変更対象クール</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <kendo-multiselect -->
              <!--   v-model="structData.selectedKur" -->
              <!--   :data-source="structData.kurOptions" -->
              <!--   :data-text-field="kurText" -->
              <!--   :data-value-field="kurValue" -->
              <!--   :max-selected-items="kurMaxSelectedItems" -->
              <!--   :disabled="treatAndKurEdit" -->
              <!--   placeholder="すべて" -->
              <!--   @change=" -->
              <!--     createSelectedKur($event); -->
              <!--     createTreatmentList(dataList); -->
              <!--     createNumDaysList($event); -->
              <!--   " -->
              <!-- /> -->
              <kendo-multiselect
                v-model="structData.selectedKur"
                :data-source="structData.kurOptions"
                :data-text-field="kurText"
                :data-value-field="kurValue"
                :max-selected-items="kurMaxSelectedItems"
                :disabled="treatAndKurEdit || !getItemAuthorized('Indication', 'default_authority')"
                placeholder="すべて"
                @change="
                  createSelectedKur($event);
                  createTreatmentList(dataList);
                  createNumDaysList($event);
                "
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
      <hr v-if="settingData.hrOnder" class="hr-style" />
      <div class="slot-style" style="white-space: pre-line;"><slot></slot></div>
      <hr v-if="settingData.hrUnder" class="hr-style" />

      <div v-if="messageDialogInfo.isDialogVisible">
        <!-- #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start -->
        <!-- <message-dialog
          :visible.sync="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          @confirm="confirmResult"
        /> -->
        <message-dialog
          :visible.sync="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :title="messageDialogInfo.title"
          :string-params="messageDialogInfo.stringParams"
          @confirm="confirmResult"
        />
        <!-- #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end -->
      </div>
    </div>
    <div slot="footer" class="in-ind-dropdown-area">
      <v-ons-row class="div-style">
        <v-ons-col>
          <custom-calendar :selected-dates="selectedDates" :view-mode="true" />
        </v-ons-col>
        <v-ons-col style="text-align: end; padding-right: 10px; margin: auto;">
          <label>指示者</label>
        </v-ons-col>
        <v-ons-col width="170px">
          <!-- mod 画面デザイン改善対応 李 start -->
          <!-- <kendo-dropdownlist
            v-model="structData.indUser"
            :data-source="structData.userOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            style="width: 100%;"
            class="common-style-input"
          /> -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <kendo-dropdownlist -->
          <!--   id="kendo-dropdownlist-select-id" -->
          <!--   v-model="structData.indUser" -->
          <!--   :data-source="structData.userOptions" -->
          <!--   :data-text-field="'fullName'" -->
          <!--   :data-value-field="'user_id'" -->
          <!--   style="width: 100%;" -->
          <!--   class="common-style-input select-style-list" -->
          <!-- /> -->
          <kendo-dropdownlist
            id="kendo-dropdownlist-select-id"
            v-model="structData.indUser"
            :data-source="structData.userOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            style="width: 100%;"
            class="common-style-input select-style-list"
            :disabled="!getItemAuthorized('Indication', 'default_authority')"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- mod 画面デザイン改善対応 李 end -->
        </v-ons-col>
      </v-ons-row>
      <div>
        <v-ons-row class="div-style">
          <v-ons-col align="bottom" width="120px">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              class="common-style-cancel-button"
              style="float: left;"
              @click="hideModal"
            >
              キャンセル
            </v-ons-button> -->
            <v-ons-button
              class="btn2-cancel width-padding"
              style="float: left;"
              @click="hideModal"
            >
              キャンセル
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
          <v-ons-col style="display: flex; justify-content: flex-end; align-items: center; flex-flow: wrap;">
            <!-- del #10206 馬 start -->
            <!-- <v-ons-col style="text-align:right;" v-show="((!settingData.showDelete && !settingData.showNewEdit) || (!settingData.showDelete && settingData.showNewEdit && edit == 0))">
              <v-ons-checkbox input-id="editOnly" v-model="structData.editOnly"/>
              <label for="editOnly" class="popoverFilterLabel">編集箇所のみ</label>
            </v-ons-col> -->
            <!-- del #10206 馬 end -->
            <div v-if="settingData.showDelete">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              :disabled="updateDisable"
              class="common-style-ok-button"
              style="float: right;"
              @click="updateIndInfo(3)"
            >
              中止
            </v-ons-button> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-button -->
              <!--   :disabled="updateDisable" -->
              <!--   class="btn4-alert width-padding" -->
              <!--   style="margin-left: 1.5em;" -->
              <!--   @click="updateIndInfo(3)" -->
              <!-- > -->
              <v-ons-button
                :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"
                class="btn4-alert width-padding"
                style="margin-left: 1.5em;"
                @click="updateIndInfo(3)"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                中止
              </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
            </div>
            <div v-else-if="settingData.showNewEdit == false">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              :disabled="updateDisable"
              class="common-style-ok-button"
              style="float: right;"
              @click="updateIndInfo(1)"
            >
              保存
            </v-ons-button> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-button -->
              <!--   :disabled="updateDisable || !editFlg" -->
              <!--   class="btn1-execute width-padding" -->
              <!--   style="margin-left: 1.5em;" -->
              <!--   @click="updateIndInfo(1)" -->
              <!-- > -->
              <!-- add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start -->
              <v-ons-button
                :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"
                class="btn1-execute width-padding"
                style="margin-left: 1.5em;"
                @click="updateIndInfo(1, 'add')"
              >
                保存
              </v-ons-button>
              <!-- add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end -->
<!--              <v-ons-button-->
<!--                :disabled="updateDisable || !editFlg || !getItemAuthorized('Indication', 'default_authority')"-->
<!--                class="btn1-execute width-padding"-->
<!--                style="margin-left: 1.5em;"-->
<!--                @click="updateIndInfo(1)"-->
<!--              >-->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                保存-->
<!--              </v-ons-button>-->
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
            </div>
            <div v-else>
              <div v-if="edit == 0">
                <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
                <!-- <v-ons-button
                  :disabled="updateDisable"
                  class="common-style-ok-button"
                  style="float: right;"
                  @click="updateIndInfo(2)"
                >
                  保存
                </v-ons-button> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <v-ons-button -->
                <!--   :disabled="updateDisable || !editFlg" -->
                <!--   class="btn1-execute width-padding" -->
                <!--   style="margin-left: 1.5em;" -->
                <!--   @click="updateIndInfo(2)" -->
                <!-- > -->
                <v-ons-button
                  :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"
                  class="btn1-execute width-padding"
                  style="margin-left: 1.5em;"
                  @click="updateIndInfo(2)"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  保存
                </v-ons-button>
                <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
              </div>
              <div v-else>
                <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
                <!-- <v-ons-button
                  :disabled="updateDisable"
                  class="common-style-ok-button"
                  style="float: right;"
                  @click="updateIndInfo(3)"
                >
                  中止
                </v-ons-button> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <v-ons-button -->
                <!--   :disabled="updateDisable" -->
                <!--   class="btn4-alert width-padding" -->
                <!--   style="margin-left: 1.5em;" -->
                <!--   @click="updateIndInfo(3)" -->
                <!-- > -->
                <v-ons-button
                  :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"
                  class="btn4-alert width-padding"
                  style="margin-left: 1.5em;"
                  @click="updateIndInfo(3)"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  中止
                </v-ons-button>
                <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
              </div>
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
  </modal-base>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, containsTabooAllergyTag } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapActions, mapMutations } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { deduplicateObjects } from "@/functions/common/CommonFunctions";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { deepCopy } from "@/functions/common/CommonFunctions";
import moment from "moment";
import ModalBase from "@/components/modals/ModalBase";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
// add 画面デザイン改善対応 李 start
import $ from "jquery";
// add 画面デザイン改善対応 李 end
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end

export default {
  components: {
    "custom-calendar": CustomCalendar,
    "message-dialog": messageDialog,
    ModalBase,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  mixins: [IndUserSelectMixin],
  props: {
    settingData: {
      type: Object,
      default: () => ({
        headerTitle: {
          type: String
        },
        segmentLabel1: {
          type: String
        },
        segmentLabel2: {
          type: String
        },
        segmentLabel3: {
          type: String
        },
        segmentLabel4: {
          type: String
        },
        facilityCd: {
          type: String,
          required: true
        },
        ordNo: {
          type: String,
          default: null
        },
        patId: {
          type: String,
          required: true
        },
        startDate: {
          type: String,
          default: "2018-01-01"
        },
        endDate: {
          type: String,
          default: ""
        },
        showSegment: {
          type: Boolean,
          default: true
        },
        showNewEdit: {
          type: Boolean
        },
        showDelete: {
          type: Boolean,
          default: false
        },
        showWeeks: {
          type: Boolean,
          default: true
        },
        showKur: {
          type: Boolean,
          default: false
        },
        showTreat: {
          type: Boolean,
          default: false
        },
        allWeek: {
          type: Boolean,
          default: false
        },
        monday: {
          type: Boolean,
          default: false
        },
        tuesday: {
          type: Boolean,
          default: false
        },
        wednesday: {
          type: Boolean,
          default: false
        },
        thursday: {
          type: Boolean,
          default: false
        },
        friday: {
          type: Boolean,
          default: false
        },
        saturday: {
          type: Boolean,
          default: false
        },
        sunday: {
          type: Boolean,
          default: false
        },
        hrOnder: {
          type: Boolean,
          default: true
        },
        hrUnder: {
          type: Boolean,
          default: true
        },
        startDateEdit: {
          type: Boolean,
          default: false
        },
        endDateEdit: {
          type: Boolean,
          default: false
        }
      })
    },
    /**
     * モーダル表示フラグ
     */
    modalVisible: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      structData: {
        patId: this.settingData.patId,
        editOnly: true,
        indStartDate: this.settingData.startDate,
        indEndDate: this.settingData.endDate,
        indWeeks: [
          {
            text: "全",
            done: this.settingData.allWeek,
            value: 0
          },
          {
            text: "月",
            done: this.settingData.monday,
            value: 1
          },
          {
            text: "火",
            done: this.settingData.tuesday,
            value: 2
          },
          {
            text: "水",
            done: this.settingData.wednesday,
            value: 3
          },
          {
            text: "木",
            done: this.settingData.thursday,
            value: 4
          },
          {
            text: "金",
            done: this.settingData.friday,
            value: 5
          },
          {
            text: "土",
            done: this.settingData.saturday,
            value: 6
          },
          {
            text: "日",
            done: this.settingData.sunday,
            value: 7
          }
        ],
        facilityCd: this.settingData.facilityCd,
        selectedKur: [],
        kurOptions: [],
        selectedTreat: [],
        treatOptions: [],
        /**
         * 治療方法リストの初期値
         */
        initTreatOptions: [],
        indUser: null,
        userOptions: [],
        kakujituWeeks: [
          {
            text: "全",
            done: false,
            value: 0
          },
          {
            text: "月・火",
            done: false,
            value: 1
          },
          {
            text: "水・木",
            done: false,
            value: 2
          },
          {
            text: "金・土",
            done: false,
            value: 3
          },
          {
            text: "日",
            done: false,
            value: 4
          }
        ],
        cycleWeek: "0",
        indDayIntervalStartDate: this.settingData.startDate,
        indDayIntervalSelected: 0,
        indNumDays: {
          init: null,
          edit: null
        },
        treatDates: []
      },
      // #10196 初回投与日  数字の手動入力はできません linjunfeng start
      indDayIntervalStartDateInput: this.settingData.startDate,
      // #10196 初回投与日  数字の手動入力はできません linjunfeng end
      dataList: [],
      edit: 0,
      disabledWeekdays: [],
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: "1",
        stringParams: [""],
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        title: "",
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
      },

      /**
       * 参照元で画面更新を行うかどうかのフラグ
       * @summary 更新を行うかどうかは参照元画面で判断
       */
      isRefresh: false,

      /**
       * 治療方法マルチ選択最大選択数
       * @summary null設定時は、制限なし
       * 子の画面で設定する
       */
      treatMaxSelectedItems: null,

      /**
       * クールマルチ選択最大選択数
       * @summary null設定時は、制限なし
       */
      kurMaxSelectedItems: null,

      /**
       * 治療方法&クール選択不可
       */
      treatAndKurEdit: false,
      /**
       * モーダルスタイル
       */
      styleObj: { "max-width": "370px", width: "370px" },
      endDateLabel: "終了日",
      indDayIntervalOptions: [
        { value: 0, text: "毎回" },
        { value: 1, text: "毎週" },
        { value: 2, text: "1回／2週" },
        { value: 3, text: "1回／3週" },
        { value: 4, text: "1回／4週" },
        { value: 5, text: "1回／月：第1曜日" },
        { value: 6, text: "1回／月：第2曜日" },
        { value: 7, text: "1回／月：第3曜日" },
        { value: 8, text: "1回／月：第4曜日" },
        { value: 9, text: "1回／月：最終曜日" },
        { value: 10, text: "1回／月：最終治療日" }
      ],
      /**
       * 更新不可フラグ
       */
      updateDisable: false,
      treatDateListAll: [],
      // 本日日付からの最大範囲のデータを格納
      treatDateListFixedAll: [],
      // treatDateListFixedAll にフィルタ処理済みのデータを格納
      tmpTreatDateListAll: [],
      picked: 1,
      // 編集中フラグ
      startEditFlg: true,
      editAddFlg: false,
      editFlg: false,
      // 回数の最大値
      maxNumDays: 1,
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
      // 実績変更フラグ
      isRstUpdateFlg: false,
      // 実績の変更をするか確認するメッセージフラグ
      isShowedMessage: false,
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
      // add 画面デザイン改善対応 李 start
      callsNumberIntervalFlg: false,
      firIntervalValue: null,
      firDesignatorValue: null,
      // add 画面デザイン改善対応 李 end
      // add FNSI-FutreNetWeb+SI課題管理No.3993 李 start
      /**
       * 治療日しリスト
       */
      dateList: [],
      /**
       * 治療日無しリスト
       */
      disabledDateList: []
      // add FNSI-FutreNetWeb+SI課題管理No.3993 李 end
      //mod FNSI-5448 劉全航 start
      ,endDateSublabel: null
      //mod FNSI-5448 劉全航 end
      , setIntervalObj: null,
      // mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false,
      focusFlg:false,
      // mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
      // #5884 薬剤追加时，开始日为空并且点击保存按钮后，没有弹出错误信息 訾浩 start
      messageChange: '開始日'
      // #5884 薬剤追加时，开始日为空并且点击保存按钮后，没有弹出错误信息 訾浩 end
      // add 10266 by kangjie 20240716 start
      ,firstTurnTreatDateList:[],
      // add 10266 by kangjie 20240716 end
      // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
      indDayIntervalStartDateManual: "",
      // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
      initWeeks: [],
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-info", ["selectedPat"]),
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    ...mapGetters("pat-viewer",["getTabooMedicine"]),
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 end

    treatText() {
      if (this.structData.treatOptions.length !== null) {
        return "text";
      } else {
        return null;
      }
    },

    treatValue() {
      if (this.structData.treatOptions.length !== null) {
        return "value";
      } else {
        return null;
      }
    },

    kurText() {
      if (this.structData.kurOptions.length !== null) {
        return "text";
      } else {
        return null;
      }
    },

    kurValue() {
      if (this.structData.kurOptions.length !== null) {
        return "value";
      } else {
        return null;
      }
    },

    weekEdit() {
      // 開始日、終了日がともに編集不可の場合は曜日も編集不可とする
      if (this.settingData.startDateEdit && this.settingData.endDateEdit) {
        return true;
      } else {
        return false;
      }
    },

    /**
     * 終了日の最大日(本日から一年未満)
     */
    maxDate() {
      const day = moment().format("YYYYMMDD");
      // 一年後に最大日を設定
      let endMaxDate = this.schExtEndDate
        ? moment(this.schExtEndDate, "YYYYMMDD")
        : moment(day).add(1, "year");
      // 一年後から1日戻す
      endMaxDate = moment(endMaxDate).endOf("month");
      return moment(endMaxDate).format("YYYY-MM-DD");
    },

    /**
     * 指定日以降編集不可
     */
    disableDatesAfter() {
      return moment(this.maxDate).format("YYYYMMDD");
    },
    //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start
    /**
     * 指定日前編集不可
     */
    disableDatesBefore() {
      return moment(this.structData.indStartDate).format("YYYYMMDD");
    },
    toMonth() {
      return moment(this.structData.indStartDate).format("YYYY-MM-DD");
    },
    //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy end
    //mod FNSI-5448 劉全航 start
    // endDateSublabel() {
    //   if (this.endDateLabel === "終了日") {
    //     if (
    //       (this.structData.indEndDate && this.structData.indNumDays.edit) ||
    //       this.structData.indNumDays.edit === 0
    //     ) {
    //       return `回数: ${this.structData.indNumDays.edit}回`;
    //     } else {
    //       //mod FNSI-5448 劉全航 start
    //       // return;
    //       return `回数: ${this.structData.treatDates.length}回`;
    //       //mod FNSI-5448 劉全航 end
    //     }
    //   } else if (this.endDateLabel === "回数") {
    //     //mod FNSI-5448 劉全航 start
    //     // if (
    //     //   (this.structData.indEndDate && this.structData.indNumDays.edit) ||
    //     //   this.structData.indNumDays.edit === 0
    //     // ) {
    //     //   return `終了日: ${this.displayEndDate}`;
    //     // } else {
    //     //   return;
    //     // }
    //     let indDayIntervalSelected = this.structData.indDayIntervalSelected;
    //       if(indDayIntervalSelected === 0 || indDayIntervalSelected === 10){
    //         if(this.structData.indNumDays.edit){
    //           return `終了日: ${this.displayEndDate}`;
    //         }
    //       }else{
    //         if(this.structData.indNumDays.edit && this.selectedWeek){
    //            return `終了日: ${this.displayEndDate}`;
    //         }
    //       }
    //       //mod FNSI-5448 劉全航 end
    //   }

    //   return null;
    // },
    //mod FNSI-5448 劉全航 end

    //mod FNSI-5448 劉全航 start
    selectedWeek(){
      let selectedWeek = this.structData.indWeeks.find((o)=> o.done === true);
      if(selectedWeek){
        return true;
      }else{
        return false;
      }
    },
    //mod FNSI-5448 劉全航 end

    selectedDates() {
      // add FNSI-FutreNetWeb+SI課題管理No.3993 李 start
      this.getDisTreatDateList(this.dateList);
      // add FNSI-FutreNetWeb+SI課題管理No.3993 李 end

      return {
        default: this.structData.treatDates,
        custom: this.treatDateListAll
      };
    },

    displayEndDate() {
      if (
        this.structData.indEndDate === null ||
        this.structData.indEndDate === ""
      ) {
        //mod FNSI-5448 劉全航 start
        // return;
        return moment(this.structData.treatDates[this.structData.treatDates.length-1]).format(
        "YYYY/MM/DD"
      );
      //mod FNSI-5448 劉全航 end
      }
      return moment(this.structData.indEndDate, "YYYY-MM-DD").format(
        "YYYY/MM/DD"
      );
    },

    /**
     * 同日に複数治療予定があるかどうか
     */
    hasSameDateTreat() {
      return (
        new Set(this.treatDateListAll).size !== this.treatDateListAll.length
      );
    },

    /**
     * スケジュール自動延長最終日
     */
    schExtEndDate() {
      // TODO: 自動延長の実行タイミングによりデータ不一致が発生する可能性がある
      return this.selectedPat.pat_main.sch_ext_end_date;
    }
  },

  watch: {
    modalVisible(value) {
      // 治療方法リストとクールリスト作成
      if (value === true) {
        this.createKurAndTreatmentList();
      }
    },

    // 治療方法
    "structData.selectedTreat"(value) {
      if (null !== this.treatMaxSelectedItems) {
        this.$slots.default[0].componentInstance.changeMultSelect(value);
      }
    },
    // 回数の入力
    // "structData.indNumDays.edit"(value) {
    //   if (!value || value < 0) {
    //     // 0以下、不正な入力の場合は空欄に
    //     this.structData.indNumDays.edit = "";
    //   } else if (value > this.maxNumDays) {
    //     // 最大値を超えないように制限
    //     this.structData.indNumDays.edit = this.maxNumDays;
    //   }
    // },

    "structData.indDayIntervalStartDate"(newVal, oldVal) {
      // #10196 初回投与日  数字の手動入力はできません linjunfeng start
      this.indDayIntervalStartDateInput = newVal;
      // #10196 初回投与日  数字の手動入力はできません linjunfeng end
    },

    // add 画面デザイン改善対応 李 start
    "structData.indDayIntervalSelected"(val, oldVal) {
      // 初回ロード時、初期状態が記録され、初期値が保存される
      if (!this.callsNumberIntervalFlg) {
        this.callsNumberIntervalFlg = true;
        this.firIntervalValue = oldVal;
      }
    },

    "structData.indUser"(val) {
      // 選択した値と初期値が異なる場合
      if ((val ?? "") != (this.firDesignatorValue ?? "")) {
        $('#kendo-dropdownlist-select-id').addClass('kendo-dropdownlist-select-edited');
        $('#kendo-dropdownlist-select-id_listbox').addClass('kendo-dropdownlist-listbox');
      } else {
        $('#kendo-dropdownlist-select-id').removeClass('kendo-dropdownlist-select-edited');
        $('#kendo-dropdownlist-select-id_listbox').removeClass('kendo-dropdownlist-listbox');
      }
    }
    // add 画面デザイン改善対応 李 end
  },

  async created() {
    // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
    this.structData.indWeeks.forEach((item) => {
      this.initWeeks.push({...item, disabled: false})
    })
    // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
    // 治療開始日の制御
    // this.AdjustTreatStartDate(this.structData.indStartDate);
    // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng start
    // 曜日選択初期化
    this.refreshWeeks();
    // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng end
    this.AdjustTreatStartDate(this.structData.indStartDate,true);
    // 治療方法、クールリスト設定
    await this.createKurAndTreatmentList();
    // 指示者リスト設定
    this.getIndUserList(
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.IND_PEDIT
    ).then(response => {
      this.structData.userOptions = response.doctorList;
      this.$nextTick(() => {
        this.structData.indUser = response.iniSelectId;
        // 初期値を退避
        this.firDesignatorValue = this.structData.indUser;
      });
    });
    // 治療方法・クールデフォルト値設定
    await this.setDefaultTreatmentAndKur(
      this.structData.indStartDate,
      this.structData.indEndDate
    );
    // 治療予定リスト取得
    await this.getTreatDateList();
    // 回数デフォルト値設定
    // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
    // await this.createNumDaysList();
    await this.createNumDaysList(null, 'indStartDate');
    // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
    // 曜日選択初期化
    // del #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng start
    // this.refreshWeeks();
    // del #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng end
    // 初期処理中に発火したイベント処理をスキップ
    this.startEditFlg = false;

    this.setIntervalObj = setInterval(() => {
      // 薬剤が未追加の場合保存ボタン非活性
      if (!this.editAddFlg) {
        this.editFlg = false;
      } else {
        this.editFlg = true;
      }
    }, 200);
  },

  beforeDestroy() {
    if (this.setIntervalObj) {
      clearInterval(this.setIntervalObj);
    }
  },

  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    ...mapMutations("pat-viewer-popover", [
      "setIndStartDate"
    ]),
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    ...mapActions("pat-viewer",["setTabooMedicine"]),
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    //mod FNSI-5448 劉全航 start
    // changeEndDateLabel() {
    //   this.endDateLabel = this.endDateLabel === "終了日" ? "回数" : "終了日";
    // },
    // mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 start
    inputNumber(e){
      // 数値範囲内かどうかの確認
      const min = 1
      if (e.target.value > this.maxNumDays) {
        this.structData.indNumDays.edit = min;
        this.blurFlg = true
      } else if (e.target.value < min) {
        this.structData.indNumDays.edit = this.maxNumDays;
        this.blurFlg = true;
      } else {
        this.blurFlg = false;
      }
    },
    onMouseWheel(e){
      if (!this.focusFlg) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      let value = parseFloat(e.target.value);
      const min = 1
      if (!e.target.value) {
        value = 0
      }
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      if (value > this.maxNumDays) {
        value = min;
      }
      if(value < min) {
        value = this.maxNumDays;
      }
      this.structData.indNumDays.edit = parseFloat(value)
    },

    // mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 end
    changeEndDateLabel(value) {
      if(value === 1){
        this.endDateLabel = "終了日";
        //mod FNSI-5448 劉全航 start
        this.endDateSublabel = "";
        //mod FNSI-5448 劉全航 end
      }else{
        this.endDateLabel = "回数";
        //mod FNSI-5448 劉全航 start
        this.endDateSublabel = "";
        //mod FNSI-5448 劉全航 end
      }
    },
    //mod FNSI-5448 劉全航 end

    hideModal() {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
      // 変更箇所があればメッセージ表示
      // if (this.$slots.default[0].componentInstance.checkEdit(1)) {
      //   return;
      // }
      // モーダル閉じる
      if(this.editFlg){
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              // モーダル閉じる
              this.$emit("hide-modal");
            }
          }
        });
      }else{
      this.$emit("hide-modal");
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
    },

    changeSegment(event) {
      this.edit = event.target.value;
      if (this.edit === 1) {
        this.structData.editOnly = true;
      }
      this.$slots.default[0].componentInstance.selectSegment(
        event.target.value
      );
    },
    changeDialSegment(event) {
      this.structData.cycleWeek = event.target.value;
      if ("1" === this.structData.cycleWeek) {
        this.disabledWeekdays = [3, 4, 5, 6, 7];
        const day = moment(this.structData.indStartDate, "YYYY-MM-DD");
        if (1 !== day.isoWeekday() && 2 !== day.isoWeekday()) {
          this.structData.indStartDate = "";
        }
      } else {
        this.disabledWeekdays = [];
      }
    },


    // mod #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
    // async updateIndInfo(num) {
    async updateIndInfo(num, type='') {
      // mod #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
      // #5884 薬剤追加时，开始日为空并且点击保存按钮后，没有弹出错误信息 訾浩 start
      if (num === 1 && this.structData.indStartDate == 'Invalid date') {
        this.$ons.notification.alert({
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
            // title: "",
            // message: "実行失敗"
            title: DIALOG_MESSAGES['22010001'].title,
            message: messageFormat(DIALOG_MESSAGES['22010001'].message, this.messageChange)
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
          });
          return false
      }
      // #5884 薬剤追加时，开始日为空并且点击保存按钮后，没有弹出错误信息 訾浩 end
      // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng start
      const data = this.$slots.default[0].componentInstance.listData;
      const medicineEle = this.$slots.default[0].componentInstance.$refs;
      let medicineFlg = false;
      // 新規登録時無編集チェック
      if (!data?.length) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[20010003].title,
          message: DIALOG_MESSAGES[20010003].message
        });
        return;
      }
      for (let item of data) {
        if (item.id && medicineEle && medicineEle[item.id]) {
          const value = medicineEle[item.id][0]?.amountInputValue?.editValue;
          if (value === "" || isNaN(value) || value == 0) {
            medicineFlg = true;
            break;
          }
        }
      }
      if (medicineFlg) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[13000170].title,
          message: DIALOG_MESSAGES[13000170].message
        });
        return;
      }
      console.log("IndMedicineCreateBase.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng end
      // 保存ボタンを非活性
      this.updateDisable = true;
      let messageCd = null;
      let stringParams = "";
      const baseData = deepCopy(this.structData);
      // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
      baseData.type = type;
      // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
      const startDateValid = this.$el.querySelector('input[data-target^="indStartDate"]').validity;
      const endDateValid = this.$el.querySelector('input[data-target^="indEndDate"]').validity;

      // 開始日の不完全入力チェック
      if ("" === baseData.indStartDate && startDateValid.badInput){
          messageCd = 22010008;
          stringParams = "開始日";
      }
      // 開始日のチェック
      if (null === messageCd &&
      (null === baseData.indStartDate || "" === baseData.indStartDate)) {
        messageCd = 22010001;
        stringParams = "開始日";
      }
      // 終了日の不完全入力チェック
      if (null === messageCd && "" === baseData.indEndDate && endDateValid.badInput){
          messageCd = 22010008;
          stringParams = "終了日";
      }
      if (
        null === messageCd &&
        null !== baseData.indEndDate &&
        "" !== baseData.indEndDate
      ) {
        if (baseData.indStartDate > baseData.indEndDate) {
          messageCd = 22010002;
          stringParams = "開始日≦終了日";
        }

        // 終了日の上限チェック(本日から1年後の昨日まで選択可能)
        if ("" === stringParams) {
          if (
            Number(
              moment(baseData.indEndDate, "YYYY-MM-DD").format("YYYYMMDD")
            ) > Number(moment(this.maxDate, "YYYY-MM-DD").format("YYYYMMDD"))
          ) {
            messageCd = "22010002";
            stringParams = `終了日は${moment(this.maxDate, "YYYY-MM-DD").format(
              "YYYY年M月D日以下"
            )}`;
          }
        }
      }

      // 曜日選択のチェック
      if (null === messageCd && true === this.settingData.showWeeks) {
        let week = [];
        if ("1" === baseData.cycleWeek) {
          week = baseData.kakujituWeeks.filter(obj => obj.done === true);
        } else {
          week = baseData.indWeeks.filter(obj => obj.done === true);
        }
        if (null === messageCd && 0 === week.length) {
          messageCd = 22010001;
          stringParams = "曜日";
        }
      }
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
      // 初回投与日のチェック
      if (null === messageCd && !baseData.indDayIntervalStartDate) {
        messageCd = 22010001;
        stringParams = "初回投与日";
      }
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end

      // 指示者のチェック
      if (null === messageCd && !baseData.indUser) {
        messageCd = 22010001;
        stringParams = "指示者";
      }

      // 終了日存在チェックを格納
      baseData.isDeadline = true;

      // 終了日のチェック
      const day = this.maxDate;
      if (null === baseData.indEndDate || "" === baseData.indEndDate) {
        // 空の場合、1年後の日を設定
        baseData.indEndDate = day;
        // 終了日存在フラグをfalseに設定
        baseData.isDeadline = false;
        if(this.endDateLabel === "回数"){
          baseData.indEndDate = this.displayEndDate.replaceAll("/","-");
        baseData.isDeadline = true;
        }
      } else {
        if (baseData.indEndDate > day) {
          // 1年より後の日を選択している場合、1年後の日を設定
          baseData.indEndDate = day;
        }
      }

      // レンダリング完了を待ってから禁忌・アレルギーチェック処理実行
      await this.$nextTick();
      // 選択薬剤に禁忌・アレルギーが存在するかチェックし、ストアに存在可否をセット(後続のチェック処理で参照する)
      this.checkMedicineTabooAllergy();

      // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start
      // データ取得条件の格納
      const ordMainList = await this.ordMainList();
      const hasTreatTypeOrd= this.getTreatType(ordMainList)
      if(hasTreatTypeOrd.size>1) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "警告",
          title: DIALOG_MESSAGES[13000058].title,
          // message: "指定期間が複数の透析パターンにまたがった指示です。保存後指示内容をご確認ください!",
          message: messageFormat(DIALOG_MESSAGES[13000058].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if(answer === 1){
              //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
                if(this.getTabooMedicine === true) {
                  this.$ons.notification.confirm({
                    // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
                    // title: "禁忌アレルギー警告",
                    title: DIALOG_MESSAGES[13000056].title,
                    // message: "禁忌、アレルギーに指定されている物品が指示に含まれています。登録してよろしいですか？",
                    message: messageFormat(DIALOG_MESSAGES[13000056].message),
                    // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
                    callback: answer => {
                      if(answer === 1){
                        this.setTabooMedicine(false);
                        this.updateIndInfo2(num, baseData, stringParams, messageCd);
                      } else {
                        this.updateDisable = false;
                        console.log("IndMedicineCreateBase.vue updateIndInfo return; this.finishLoadingScreen();");
                        this.finishLoadingScreen();
                        return;
                      }
                    }
                  });
                } else {
                  this.updateIndInfo2(num, baseData, stringParams, messageCd);
                }
                //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
            } else {
              this.updateDisable = false;
              console.log("IndMedicineCreateBase.vue updateIndInfo return; this.finishLoadingScreen();");
              this.finishLoadingScreen();
              return;
            }
          }
        });
      }else{
      // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 end
        //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
        if(this.getTabooMedicine === true) {
          this.$ons.notification.confirm({
           // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
           // title: "禁忌アレルギー警告",
           title: DIALOG_MESSAGES[13000056].title,
           // message: "禁忌、アレルギーに指定されている物品が指示に含まれています。登録してよろしいですか？",
           message: messageFormat(DIALOG_MESSAGES[13000056].message),
           // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if(answer === 1){
                this.setTabooMedicine(false);
                this.updateIndInfo2(num, baseData, stringParams, messageCd);
              } else {
                this.updateDisable = false;
                console.log("IndMedicineCreateBase.vue updateIndInfo return; this.finishLoadingScreen();");
                this.finishLoadingScreen();
                return;
              }
            }
          });
        } else {
          this.updateIndInfo2(num, baseData, stringParams, messageCd);
        }
        //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
    // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start
      }
      console.log("IndMedicineCreateBase.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    /**
     * @description 治療種別が1日以外の指示取得
     */
    getTreatType(ordMainList) {
      if (ordMainList==null) {
        return [];
      }
      const ordMain = new Set(ordMainList.filter(
        ord => ord.treatType === 1 || ord.treatType === 2 || ord.treatType === 3
      ).map(item=>item.treatType));
      return ordMain;
    },
    /**
     * @description 指示リスト取得
     */
    async ordMainList() {
      // データ取得条件の格納
      const paramJson = {
        // 施設コード
        facility_cd: this.structData.facilityCd,
        // 患者ID
        pat_id: this.structData.patId,
        // 治療開始日
        ind_start_date: moment(this.structData.indStartDate).format("YYYY-MM-DD"),
        // 治療終了日
        ind_end_date: moment(this.structData.indEndDate).format("YYYY-MM-DD")!="Invalid date"?moment(this.structData.indEndDate).format("YYYY-MM-DD"): "9999-12-31",
        // 曜日パターン
        week_pattern: "[{'text': '全','done': false,'value': 0}]"
      };
      // データの取得
      const response = await ApiHelper.post(
        `/mainData/TreatDateList`,
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add startupdateIndInfo
        getErrorMessage('IndEditBase.vue', 'ordMainList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      return response.data.length === 0 ? null : response.data;
    },
    // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 end
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    async updateIndInfo2(num, baseData, stringParams, messageCd) {
      console.log("IndMedicineCreateBase.vue updateIndInfo2 this.startLoadingScreen();");
      this.startLoadingScreen();

      baseData.updUser = this.getStateUserAccountInfo.userId;

      //add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
      baseData.number_of_doses = this.endDateLabel === "回数";
      //add 11555 指示履歴への記録の残り方が仕様と異なる zkm end

      if ("" !== stringParams) {
        this.messageDialogInfo.messageCd = messageCd;
        this.messageDialogInfo.type = "1";
        this.messageDialogInfo.stringParams = [stringParams];
        this.messageDialogInfo.isDialogVisible = true;
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        this.messageDialogInfo.title = DIALOG_MESSAGES[messageCd].title;
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
      } else {
        baseData.flag = num;
        this.startLoadingScreen();
        const hasError = await this.$slots.default[0].componentInstance.updateIndInfo(
          baseData
        ).finally(() => {
          this.finishLoadingScreen();
        });
        if (!hasError) {
          // 参照元画面更新フラグをON
          this.isRefresh = true;
          // モーダル閉じる
          this.$emit("hide-modal");
        }
      }
      console.log("IndMedicineCreateBase.vue updateIndInfo2 this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 end

    chkChange(week) {
      switch (this.structData.indDayIntervalSelected) {
        // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // case 0:
        // case 10:
        //   this.structData.indWeeks.forEach(item => {
        //     item.done = false;
        //     item.disabled = false;
        //   });
        //   break;
        // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        case 10:
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
          this.structData.indWeeks.forEach(item => {
            if (item.value !== week.value) {
              item.done = false;
            }
          });
          week.done = !week.done;
          break;
        default: {
          let isDoneAll = true;

          week.done = !week.done;

          if (week.value === 0) {
            this.structData.indWeeks.forEach(item => {
              if (item.value !== 0) {
                item.done = week.done;
              }
            });
          } else {
            this.structData.indWeeks.forEach(item => {
              if (item.value !== 0 && !item.done) {
                isDoneAll = false;
              }
            });
            this.structData.indWeeks[0].done = isDoneAll;
          }
        }
      }

      this.createKurAndTreatmentList();
      // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
      // this.createNumDaysList();
      this.createNumDaysList(null, 'week');
      // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
    },

    chkKakujituChange(week) {
      let isDoneAll = true;

      week.done = !week.done;

      if (week.value === 0) {
        this.structData.kakujituWeeks.forEach(item => {
          if (item.value !== 0) {
            item.done = week.done;
          }
        });
      } else {
        this.structData.kakujituWeeks.forEach(item => {
          if (item.value !== 0 && !item.done) {
            isDoneAll = false;
          }
        });
        this.structData.kakujituWeeks[0].done = isDoneAll;
      }

      this.createKurAndTreatmentList();
    },

    refreshWeeks() {
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      // this.structData.indWeeks.forEach(item => {
      //   item.done = false;
      // });
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
      // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng start
      this.structData.indWeeks.forEach(item => {
        item.done = false;
      });
      // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng end
      switch (this.structData.indDayIntervalSelected) {
        // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // case 0:
        // case 10:
        //   this.structData.indWeeks.forEach(item => {
        //     // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
        //     // item.done = true;
        //     // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
        //     // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng start
        //     item.done = false;
        //     // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng end
        //     item.disabled = false;
        //   });
        //   break;
        // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        case 10:
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
          this.structData.indWeeks.forEach(item => {
            item.disabled = false;
          });
          this.structData.indWeeks[0].disabled = true;
          break;
        default:
          this.structData.indWeeks.forEach(item => {
            item.disabled = false;
          });
      }
    },

    /**
     * 治療方法リストとクールリスト作成
     */
    async createKurAndTreatmentList(event) {
      // イベントからの発火の場合、編集フラグの確認を行う
      if (event != null) {
        if (event.type === "blur") {
          // blurイベントの場合は編集中フラグをオフ
          this.startEditFlg = false;
        } else if (this.startEditFlg) {
          // 編集中の場合は処理をスキップ
          return;
        }
      }
      // リスト情報リセット
      this.structData.selectedKur = [];
      this.structData.kurOptions = [];
      this.structData.selectedTreat = [];
      this.structData.treatOptions = [];
      this.dataList = [];
      // リスト情報取得
      const params = {
        facility_cd: this.structData.facilityCd,
        pat_id: this.structData.patId,
        ind_start_date: this.structData.indStartDate,
        ind_end_date: this.structData.indEndDate,
        week_pattern: JSON.stringify(this.structData.indWeeks)
      };
      await ApiHelper.post("/mainData/KurAndTreatmentList", params)
        .then(response => {
          if (0 !== response.data.length) {
            // 取得データを格納
            this.dataList = response.data;
            // 治療方法リスト作成
            this.createTreatmentList(this.dataList);
            // クールリスト作成
            this.createKurList(this.dataList);
            // 治療方法リスト初期値格納
            this.structData.initTreatOptions = this.structData.treatOptions;
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndMedicineCreateBase.vue', 'createKurAndTreatmentList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
    },
    /**
     * 治療方法リスト作成
     * @param {object} リスト作成元データ[{},{}...]
     */
    createTreatmentList(dataList) {
      if (0 !== dataList.length) {
        let extractList = dataList;
        // 選択中のクールに紐づく治療方法リストを作成
        if (0 < this.structData.selectedKur.length) {
          extractList = dataList.filter(item => {
            if (this.structData.selectedKur.includes(item.indKurCd)) {
              return true;
            }
          });
        }

        this.createList(
          extractList,
          "indTreatmentCd",
          "indTreatmentName",
          "treatOptions"
        );
      }
    },
    /**
     * クールリスト作成
     * @param {object} リスト作成元データ[{},{}...]
     */
    createKurList(dataList) {
      if (0 !== dataList.length) {
        // 選択中の治療方法に紐づくクールリストを作成
        let extractList = dataList;
        if (0 < this.structData.selectedTreat.length) {
          extractList = dataList.filter(item => {
            if (this.structData.selectedTreat.includes(item.indTreatmentCd)) {
              return true;
            }
          });
        }

        this.createList(extractList, "indKurCd", "indKurName", "kurOptions");
      }
    },
    /**
     * リスト作成
     * @param {object} リスト作成元データ[{},{}...]
     * @param {string} コードのカラム名
     * @param {string} 名称のカラム名
     * @param {string} プルダウンリスト名
     */
    createList(dataList, columnCode, columnName, srcList) {
      if (0 !== dataList.length) {
        // リストをdistinctした一覧を作成
        const procList = deduplicateObjects(dataList, columnCode);
        const createList = [];
        // コードと名称のリストを作成
        for (let i = 0; i < procList.length; i++) {
          const jsonData = {};
          jsonData.text = procList[i][columnName];
          jsonData.value = procList[i][columnCode];
          createList.push(jsonData);
        }
        this.structData[srcList] = createList;
      }
    },

    /**
     * 治療方法、クールデフォルト値設定
     * @description 初回オーダー番号指定時のみ行う
     * @param startDate 治療開始日
     * @param endDate   治療終了日
     */
    async setDefaultTreatmentAndKur(startDate, endDate) {
      // オーダー番号の指定がなければ、デフォルト値の設定処理終了
      if (
        null === this.settingData.ordNo ||
        undefined === this.settingData.ordNo
      ) {
        return;
      }

      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = this.structData.facilityCd;
      // 患者情報
      paramJson.pat_id = this.structData.patId;
      // 治療開始日時
      paramJson.ind_start_date = startDate;
      // 治療終了日時
      if ("" !== endDate && null !== endDate) {
        paramJson.ind_end_date = endDate;
        // 終了日の指定がない場合は、デフォルト値の設定処理終了
      } else {
        return;
      }
      // 曜日パターン
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";

      // オーダー番号確定時は治療方法、クール選択不可
      this.treatAndKurEdit = true;

      // 対象日時の治療情報取得
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndMedicineCreateBase.vue', 'setDefaultTreatmentAndKur', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      // 処理終了
      if (0 === response.data.length) {
        return;
      }

      // オーダー番号に紐づく治療情報を取得
      response.data = response.data.filter(eleItem => {
        return eleItem.ordNo === this.settingData.ordNo;
      });

      response.data.forEach(eleItem => {
        // 重複無しフラグ
        let disDuplicateFlag = true;
        // 治療方法デフォルト値格納
        if (0 === this.structData.selectedTreat.length) {
          this.structData.selectedTreat.push(eleItem.indTreatmentCd);
        } else {
          // 重複チェック処理
          this.structData.selectedTreat.forEach(item => {
            // 重複無しフラグをfalseに変更
            if (item === eleItem.indTreatmentCd) {
              disDuplicateFlag = false;
            }
          });
          // 重複がなければ格納
          if (disDuplicateFlag) {
            this.structData.selectedTreat.push(eleItem.indTreatmentCd);
          }
        }

        // 重複無しフラグを初期化(true)
        disDuplicateFlag = true;

        // すでに格納されていない場合は、格納する
        if (0 === this.structData.selectedKur.length) {
          this.structData.selectedKur.push(eleItem.indKurCd);
        } else {
          // 重複チェック処理
          this.structData.selectedTreat.forEach(item => {
            // 重複無しフラグをfalseに変更
            if (item === eleItem.indKurCd) {
              disDuplicateFlag = false;
            }
          });
          // 重複がなければ格納
          if (disDuplicateFlag) {
            this.structData.selectedTreat.push(eleItem.indKurCd);
          }
        }
      });
    },
    //add #9311 v-model発効します 張博 start
    createSelectedKur(event){
      this.structData.selectedKur = event.sender._old
    },
    createSelectedTreat(event){
      this.structData.selectedTreat = event.sender._old
    },
    //add #9311 v-model発効します 張博 end
    // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
    getNthWeekDates(startDate, endDate, n) {
      const result = [];
      const start = moment(startDate);
      const end = moment(endDate);
      while (start.isBefore(end)) {
          const firstDayOfMonth = moment(start).startOf('month');
          const startRange = firstDayOfMonth.add((n - 1) * 7, 'days');
          const endRange = moment(startRange).add(6, 'days');
          if (startRange.isBetween(startDate, endDate, null, '[]') || endRange.isBetween(startDate, endDate, null, '[]')) {
              let currentDate = moment(startRange);
              while (currentDate.isSameOrBefore(endRange)) {
                  if (currentDate.isBetween(startDate, endDate, null, '[]')) {
                      result.push(currentDate.format('YYYYMMDD'));
                  }
                  currentDate.add(1, 'day');
              }
          }
          start.add(1, 'month').startOf('month');
      }
      return result;
    },
    getLastDaysOfMonths(dateArray) {
      const monthLastDays = {};
      dateArray.forEach(date => {
          const mDate = moment(date);
          const monthKey = mDate.format('YYYY-MM');
          if (!monthLastDays[monthKey] || mDate.isAfter(monthLastDays[monthKey])) {
              monthLastDays[monthKey] = mDate;
          }
      });
      return Object.values(monthLastDays)
          .map(day => day.format('YYYYMMDD')); 
    },
    // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
    /**
     * 日付配列から、各月の最終週(月末日から遡って7日間)に含まれる日付を抽出して返却。
     * 
     * @param {string[]} dateArray - 日付文字列の配列。
     * @returns {string[]} - 元の配列のうち、各月の最終週(月末日から遡って7日間)に該当する日付のみ含む配列。
     * @note
     * - dateArrayの要素は、'YYYYMMDD'形式であることが前提。
     */
    getLastWeekDatesOfEachMonth(dateArray) {
      const uniqueMonths = new Set(dateArray.map(date => moment(date).format('YYYYMM')));
      const lastWeekDates = new Set();
    
      uniqueMonths.forEach(month => {
        const endOfMonth = moment(month, 'YYYYMM').endOf('month');
        for (let i = 0; i < 7; i++) {
          lastWeekDates.add(endOfMonth.clone().subtract(i, 'days').format('YYYYMMDD'));
        }
      });
      return dateArray.filter(date => lastWeekDates.has(date));
    },
    /**
     * @description 開始日や終了日を基に登録対象となる治療の回数を算出
     */
    // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
    // async createNumDaysList(event) {
    async createNumDaysList(event,type) {
      // 回数項目が編集されたかのフラグ
      let isInitializeNumDays = false;
      this.focusFlg=false;
      // イベントからの発火の場合、編集フラグの確認を行う
      if (event != null) {
        if (event.type === "blur") {
          if (event.target.id === "iputIndNumDays") {
            // 以降の処理でinputイベントによりで多重発火してしまう為、編集中フラグを立てたままにしておく
            isInitializeNumDays = true;
            // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
            if (this.structData.indNumDays.edit == this.maxNumDays && this.blurFlg) {
              this.structData.indNumDays.edit = 1;
              this.blurFlg = false
            }else if (this.structData.indNumDays.edit == 1 && this.blurFlg) {
              this.structData.indNumDays.edit = this.maxNumDays;
              this.blurFlg = false
            }
            // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
          } else {
            // 編集中フラグをオフ
            this.startEditFlg = false;
          }
        } else if (this.startEditFlg) {
          // 編集中の場合は処理をスキップ
          return;
        }
      }
      // 回数項目編集時の処理(回数、終了日の補正)
      if (isInitializeNumDays) {
        const indNumDays = Number(this.structData.indNumDays.edit);
        if (!indNumDays || indNumDays < 0) {
          // 入力がない、または不正な場合は初期化して処理を抜ける
          this.structData.indNumDays.edit = "";
          this.structData.indEndDate = "";
        } else {
          const selectDay = indNumDays - 1;
          const setEndDate = this.tmpTreatDateListAll[selectDay];
          // 同日に複数件の予定があるかチェック
          let sameDayCount = 0;
          for (let i = selectDay; i < this.tmpTreatDateListAll.length - 1; i++) {
            if (setEndDate === this.tmpTreatDateListAll[i]) {
              sameDayCount += 1;
            } else {
              // ソートされているので、結果が合わなくなったら抜ける
              break;
            }
          }
          if (sameDayCount > 1) {
            // 同日に複数件予定がある場合は、その分回数を加算する
            this.structData.indNumDays.edit = String(Number(this.structData.indNumDays.edit) + sameDayCount - 1);
          }
          //mod 5448投与薬剤で回数を入力すると終了日が計算できない  start
          // const editEndDate = moment(setEndDate, "YYYYMMDD").format("YYYY-MM-DD");
          //mod FNSI-5448 劉全航 start
          // const editEndDate = setEndDate ? moment(setEndDate, "YYYYMMDD").format("YYYY-MM-DD") : "";
          //mod FNSI-5448 劉全航 end
          //mod 5448投与薬剤で回数を入力すると終了日が計算できない  end
          //mod FNSI-5448 劉全航 start
          //this.structData.indEndDate = editEndDate;
          //mod FNSI-5448 劉全航 end
        }
        this.$nextTick(() => {
          // 上記 this.structData.indEndDate の変更処理により、createNumDaysList イベントが発火してしまう為、遅延させて編集フラグを解除
          this.startEditFlg = false;
        });
      }
      // add 10266 by kangjie 20240716 start
      const treatDateParamJson = {};
      treatDateParamJson.facility_cd = this.structData.facilityCd;
      treatDateParamJson.pat_id = this.structData.patId;
      // 曜日パターン
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
      // treatDateParamJson.weeks = JSON.stringify(this.structData.indWeeks);
      treatDateParamJson.weeks = JSON.stringify(this.initWeeks);
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
      const allPlantData = await ApiHelper.post(
        "/mainData/treatDateList/calendarFirstTrun",
        treatDateParamJson
      ).catch(error => {
        getErrorMessage('IndMedicineCreateBase.vue', 'createNumDaysList', error);
        throw error;
      });
      this.firstTurnTreatDateList = allPlantData.data.map(item => {
        return item.treatDate;
      });
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
      const startDates = moment(this.structData.indStartDate).format("YYYYMMDD");
      let endDates = "";
      if (this.structData.indEndDate) {
        endDates = moment(this.structData.indEndDate).format("YYYYMMDD");
      }
      this.firstTurnTreatDateList = this.firstTurnTreatDateList.filter(item => item >= startDates);
      if (endDates) {
        this.firstTurnTreatDateList = this.firstTurnTreatDateList.filter(item => item <= endDates);
      }
      if ([5, 6, 7, 8, 10].includes(this.structData.indDayIntervalSelected)) {
        const endDates = this.structData.indEndDate ? this.structData.indEndDate : this.firstTurnTreatDateList[this.firstTurnTreatDateList.length - 1];
        let dates = [];
        if (this.structData.indDayIntervalSelected == 10) {
          this.firstTurnTreatDateList = this.getLastDaysOfMonths(this.firstTurnTreatDateList);
        } else {
          dates = this.getNthWeekDates(this.structData.indStartDate, endDates, this.structData.indDayIntervalSelected - 4);
          this.firstTurnTreatDateList = this.firstTurnTreatDateList.filter(item => dates.includes(item));
        }
      } else if (this.structData.indDayIntervalSelected == 9) {
        // 投与間隔「1回／月：最終曜日」の時、各月の最終週(月末日から遡って7日間)に含まれる日付を抽出
        this.firstTurnTreatDateList = this.getLastWeekDatesOfEachMonth(this.firstTurnTreatDateList);
      }

      let indWeeksArr = [];
      this.firstTurnTreatDateList.forEach((item) => {
        if (!indWeeksArr.includes(moment(item).isoWeekday())) {
          indWeeksArr.push(moment(item).isoWeekday());
        }
      });
      this.structData.indWeeks.forEach((item) => {
        item.disabled = indWeeksArr.includes(item.value) ? false : true;
        if (this.structData.indDayIntervalSelected == 10) {
          item.disabled = true;
        }
      });
      if (type != "week") {
        let weeks = [];
        if (type === "indDayIntervalStartDate" && event?.target?.value && this.structData.indDayIntervalSelected != 10) {
          if ([0, 1].includes(this.structData.indDayIntervalSelected)) {
            weeks = this.structData.indWeeks.filter(item => item.done == true).map((item) => {
              return item.value;
            });
          }
          if (!weeks.includes(moment(event.target.value).isoWeekday()) && this.firstTurnTreatDateList.includes(moment(event.target.value).format("YYYYMMDD"))) {
            weeks.push(moment(event.target.value).isoWeekday());
          }
        } else if ([2,3,4,5,6,7,8].includes(this.structData.indDayIntervalSelected)) {
          let dateArr = this.firstTurnTreatDateList.filter(item => item >= moment(event).format("YYYYMMDD"));
          if (dateArr && dateArr[0]) {
            weeks.push(moment(dateArr[0]).isoWeekday());
          }
        } else if (this.structData.indDayIntervalSelected == 9) {
          // 投与間隔「1回／月：最終曜日」の時、「初回投与日の変更」以外の場合は、治療日リストの全曜日をweeksにpush
          // (投与間隔「1回／月：最終曜日」かつ「初回投与日の変更」の時、この分岐に入るのはevent?.target?.valueが不正な入力値の場合の為、weeksは空のままで後続処理へ進む。)
          if (type !== "indDayIntervalStartDate") {
            this.firstTurnTreatDateList.forEach((item) => {
              if (!weeks.includes(moment(item).isoWeekday())) {
                weeks.push(moment(item).isoWeekday());
              }
            });
          }
        } else {
          this.firstTurnTreatDateList.forEach((item) => {
            if (!weeks.includes(moment(item).isoWeekday())) {
              weeks.push(moment(item).isoWeekday());
            }
          })
        }
        if (weeks.length < 7) {
          this.structData.indWeeks.forEach((item) => {
            if (weeks.includes(item.value)) {
              item.done = [0, 10].includes(this.structData.indDayIntervalSelected) || type === "indDayIntervalStartDate" ? true : false;
            } else {
              item.done = false;
            }
          })
        } else {
          this.structData.indWeeks.forEach((item) => {
            item.done = [0, 10].includes(this.structData.indDayIntervalSelected) || type === "indDayIntervalStartDate" ? true : false;
          })
        }
      }
      // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
      // add 10266 by kangjie 20240716 end

      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = this.structData.facilityCd;
      // 患者情報
      paramJson.pat_id = this.structData.patId;
      // 治療開始日時
      paramJson.start_date = this.structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = this.structData.indEndDate;
      // 曜日パターン
      paramJson.weeks = JSON.stringify(this.structData.indWeeks);
      // クール
      paramJson.ind_kur_cd = JSON.stringify(this.structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(
        this.structData.selectedTreat
      );
      // 対象日時の治療情報取得(日付・曜日・治療方法・クールで絞り込み)
      const response = await ApiHelper.post(
        "/mainData/treatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndMedicineCreateBase.vue', 'createNumDaysList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      this.structData.treatDates = response.data.map(item => {
        return item.treatDate;
      });

      // add FNSI-FutreNetWeb+SI課題管理No.3993 李 start
      this.dateList = response.data.map(item => {
        return item.treatDate;
      });
      // add FNSI-FutreNetWeb+SI課題管理No.3993 李 end

      // 開始日、終了日の範囲は上記取得処理で区切られている為、最大範囲でフィルタを作成する
      // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
      // const startDate = moment(this.structData.indDayIntervalStartDate);
      let startDate = moment(this.structData.indStartDate);
      const endDate = moment(this.maxDate.replace(/-/g, ""));
      // 1回／2週 1回／3週 1回／4週
      if ([2,3,4].includes(this.structData.indDayIntervalSelected)) {
        if (this.structData.treatDates && this.structData.treatDates[0]) {
          startDate = moment(this.structData.treatDates[0]);
        } else {
          this.structData.indWeeks.forEach(item => {
            if (item.done) {
              startDate = moment(startDate).weekday(item.value);
            }
          });
        }
      }
      // 每回
      if (this.structData.indDayIntervalSelected == 0) {
        startDate = moment(this.structData.treatDates[0]);
      }
      // 選択されている投与間隔により治療日をフィルタ
      // const treatDatesFilter = await this.filterDates(
      //   startDate,
      //   endDate,
      //   this.structData.indDayIntervalSelected,
      //   this.structData.indWeeks
      // );
      // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
      // add FNSI-【1006】最新の改修対象一覧の678対応 韓 start
      const treatDatesFilterInterval = await this.filterDates(
        // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
        // moment(this.structData.indStartDate),
        startDate,
        // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
        endDate,
        this.structData.indDayIntervalSelected,
        this.structData.indWeeks
      );

      if (treatDatesFilterInterval.length > 0) {
        // mod FNSI-FutreNetWeb+SI課題管理No.3993 李 start
        // this.structData.indDayIntervalStartDate = moment(treatDatesFilterInterval[0], "YYYYMMDD").format("YYYY-MM-DD");
        let startDateFlg = false;
        //mod FNSI-5448 劉全航 start
        // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
        // this.structData.treatDates.find(item => {
        //   if (item == moment(this.structData.indDayIntervalStartDate).format("YYYYMMDD")) startDateFlg = true;
        // });
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // if (type === 'indDayIntervalStartDate' && this.structData.indDayIntervalSelected != 10) {
        if (type === 'indDayIntervalStartDate') {
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
          // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
          // this.structData.treatDates.find(item => {
          this.firstTurnTreatDateList.find(item => {
          // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
            if (item == moment(this.structData.indDayIntervalStartDate).format("YYYYMMDD")) startDateFlg = true;
          });
        }
        // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
        // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // if (this.structData.indDayIntervalSelected == 1) {
        if (this.structData.indDayIntervalSelected == 1 || this.structData.indDayIntervalSelected == 0) {
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
          if (type === 'indDayIntervalStartDate') {
            this.indDayIntervalStartDateManual = moment(this.structData.indDayIntervalStartDate).format("YYYYMMDD")
          } else {
            if (this.structData.treatDates.includes(this.indDayIntervalStartDateManual)) {
              this.structData.indDayIntervalStartDate = moment(this.indDayIntervalStartDateManual, "YYYYMMDD").format("YYYY-MM-DD");
              startDateFlg = true;
            } else {
              this.indDayIntervalStartDateManual = "";
            }
            if (this.structData.treatDates && this.structData.treatDates.length > 0 && treatDatesFilterInterval) {
              const commonValues = this.structData.treatDates.filter(item => treatDatesFilterInterval.includes(item));
              treatDatesFilterInterval[0] = commonValues ? this.structData.treatDates[0] : treatDatesFilterInterval[0];
            }
          }
        } else if ([5, 6, 7, 8].includes(this.structData.indDayIntervalSelected)) {
          if (this.structData.treatDates && this.structData.treatDates.length > 0 && treatDatesFilterInterval) {
            const commonValues = this.structData.treatDates.filter(item => treatDatesFilterInterval.includes(item));
            if (commonValues && commonValues.length > 0) {
              treatDatesFilterInterval[0] = commonValues[0];
            }
          }
        } else if (this.structData.indDayIntervalSelected != 1 || !startDateFlg) {
          this.indDayIntervalStartDateManual = "";
        }
        // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        const indContent = this.firstTurnTreatDateList.find(item => treatDatesFilterInterval.includes(item));
        let weekDone = false;
        this.structData.indWeeks.forEach((item) => {
          if (item.done) {
            weekDone = true;
          }
        });
        if (![9, 10].includes(this.structData.indDayIntervalSelected)&& (!indContent || !weekDone)) {
          this.structData.indDayIntervalStartDate = null;
          startDateFlg = true;
        }
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
        // if(this.structData.treatDates[0] === moment(this.structData.indDayIntervalStartDate).format("YYYYMMDD")){
        //   startDateFlg = true;
        // }
        //mod FNSI-5448 劉全航 end

        if (!startDateFlg) this.structData.indDayIntervalStartDate = moment(treatDatesFilterInterval[0], "YYYYMMDD").format("YYYY-MM-DD");
        startDateFlg = false;
        // mod FNSI-FutreNetWeb+SI課題管理No.3993 李 end
        // del #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
        // if (type === 'indStartDate') {
        //   this.structData.indDayIntervalStartDate = this.structData.treatDates ?  moment(this.structData.treatDates[0], "YYYYMMDD").format("YYYY-MM-DD") : null;
        // }
        // del #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
      } else {
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // this.structData.indDayIntervalStartDate = this.structData.indStartDate;
        this.structData.indDayIntervalStartDate = null;
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
        // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
        this.indDayIntervalStartDateManual = "";
        // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
      }
      // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
      // 選択されている投与間隔により治療日をフィルタ
      const treatDatesFilter = await this.filterDates(
        moment(this.structData.indDayIntervalStartDate),
        endDate,
        this.structData.indDayIntervalSelected,
        this.structData.indWeeks
      );
      // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
      // add FNSI-【1006】最新の改修対象一覧の678対応 韓 end
      // フィルタを適用
      this.structData.treatDates = await this.structData.treatDates.filter(item => {
        const isSearchDateExists = treatDatesFilter.find(i => {
          return i === item;
        });

        return isSearchDateExists;
      });

      // 回数項目以外が変更された時の、回数項目の補正
      if (!isInitializeNumDays) {
        // 本日日付から指定可能な範囲の全日付から、投与間隔等でフィルタリングしたものを保持する
        this.tmpTreatDateListAll = await this.treatDateListFixedAll.filter(item => {
          const isSearchDateExists = treatDatesFilter.find(i => {
            return i === item;
          });
          return isSearchDateExists;
        });
        // 回数の最大値を設定
        this.maxNumDays = this.tmpTreatDateListAll && this.tmpTreatDateListAll.length > 0 ? this.tmpTreatDateListAll.length : 1;
        //mod FNSI-5448 劉全航 start
        if(this.endDateLabel !== "回数"){
          // 回数値を補正
          const endDate = this.structData.indEndDate;
          const indNumDays = endDate && endDate !== "" ? this.structData.treatDates.length : null;
          this.structData.indNumDays.init = indNumDays;
          this.structData.indNumDays.edit = indNumDays;
          if (this.structData.indNumDays.edit && this.structData.indNumDays.edit !== "") {
        // 指定されている回数により治療日をフィルタ
            this.structData.treatDates =
            this.structData.treatDates.splice(0, this.structData.indNumDays.edit);
          }
        }
        //mod FNSI-5448 劉全航 end
        // 回数値を補正
        //mod FNSI-5448 劉全航 start
        // const endDate = this.structData.indEndDate;
        // const indNumDays = endDate && endDate !== "" ? this.structData.treatDates.length : null;
        // this.structData.indNumDays.init = indNumDays;
        // this.structData.indNumDays.edit = indNumDays;
        //mod FNSI-5448 劉全航 end
      }

      if (
        this.structData.indNumDays.edit &&
        this.structData.indNumDays.edit !== ""
      ) {
        // 指定されている回数により治療日をフィルタ
        this.structData.treatDates = this.structData.treatDates.splice(
          0,
          this.structData.indNumDays.edit
        );
      }
      //mod FNSI-5448 劉全航 start
      if (this.endDateLabel === "終了日") {
        if (
          (this.structData.indEndDate && this.structData.indNumDays.edit) ||
          this.structData.indNumDays.edit === 0
           ) {
          this.endDateSublabel = `回数: ${this.structData.indNumDays.edit}回`;
          } else {
          this.endDateSublabel = `回数: ${this.structData.treatDates.length}回`;
        }
      } else if (this.endDateLabel === "回数") {
        let indDayIntervalSelected = this.structData.indDayIntervalSelected;
        if(indDayIntervalSelected === 0 || indDayIntervalSelected === 10){
          if(this.structData.indNumDays.edit){
            this.endDateSublabel = `終了日: ${this.displayEndDate}`;
          }
        }else{
          if(this.structData.indNumDays.edit && this.selectedWeek){
            this.endDateSublabel = `終了日: ${this.displayEndDate}`;
          }
        }
      }
      //mod FNSI-5448 劉全航 end
    },

    /**
     * @description 「投与間隔」による治療日の絞り込関数
     * @param {String} startDate 開始日
     * @param {String} endDate 終了日
     * @param {Number} pattern 投薬パターン
     * @param {Array} weeks 曜日
     */
    async filterDates(startDate, endDate, pattern, weeks) {
      // TODO: 初回投与日と終了日の長い期間を指定すると処理は随分時間かかってしまって
      //       画面が動かなくなる。以下の条件でほぼ1年間を制限する
      // del #10196 開始日の過去1年前に薬剤の新規修正に成功することはできません 20240311 ztc start
      // if (Math.round(moment.duration(endDate.diff(startDate)).asYears()) > 1) {
      //   return [];
      // }
      // del #10196 開始日の過去1年前に薬剤の新規修正に成功することはできません 20240311 ztc end
      const retArr = [];
      const currentDate = startDate.clone();
      // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
      // let currentWeek = currentDate.clone().week();
      let currentWeek = currentDate.clone().isoWeek();
      // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
      let nextUpdateWeek = currentWeek;
      let treatDateList = [];

      /**
       * 月の第○曜日を抽出
       * @param {Number} weekday 曜日
       * @param {Number} ordinal 第○曜日
       * @returns {Object}
       */
      const getWeekOfMonthDate = (weekday, ordinal) => {
        const wd = moment()
          .year(currentDate.year())
          .month(currentDate.month())
          .date(1);

        while (wd.isoWeekday() !== weekday) {
          wd.add(1, "d");
        }

        return wd.add(ordinal, "w");
      };

      /**
       * 月の最週を抽出
       * @param {Object} momentオブジェクト
       * @returns {Array}
       */
      const getMonthLastWeek = date => {
        const d = date.clone().endOf("M");
        const retArr = [];

        // 一週間分
        for (let i = 0; i < 7; i++) {
          retArr.push(d.clone());
          d.subtract(1, "d");
        }

        return retArr;
      };

      /**
       * 1回／○週処理
       * @param {Object} momentオブジェクト
       */
      const setWeeklyDates = (formattedDate, numWeeksToAdd) => {
        // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
        // currentWeek = currentDate.clone().week();
        currentWeek = currentDate.clone().isoWeek();
        // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end

        if (currentWeek === nextUpdateWeek + 1) {
          nextUpdateWeek = currentWeek + numWeeksToAdd;
        }
        const isNextUpdateWeek = currentWeek === nextUpdateWeek;

        if (isNextUpdateWeek) {
          weeks.forEach(item => {
            const isSelectedDay = currentDate.isoWeekday() === item.value;
            const isDayInWeekSelected = item.done;

            if (isSelectedDay && isDayInWeekSelected) {
              retArr.push(formattedDate);
            }
          });
        }
      };

      /**
       * 1回／月：第○曜日処理
       * @param {Object} formattedDate momentオブジェクト
       * @param {Number} ordinal 第○曜日
       */
      const setWeekOfMonthDates = (formattedDate, ordinal) => {
        const selectedWeekday = weeks.find(item => {
          return item.done;
        });
        const isSelectedDay =
          selectedWeekday &&
          currentDate.format("YYYYMMDD") ===
            getWeekOfMonthDate(selectedWeekday.value, ordinal).format(
              "YYYYMMDD"
            );

        if (isSelectedDay) {
          retArr.push(formattedDate);
        }
      };

      /**
       * 1回／月：最終曜日
       * @param {Object} momentオブジェクト
       */
      const setMonthLastWeekDates = formattedDate => {
        const monthLastWeek = getMonthLastWeek(currentDate);
        const inMonthLastWeek = monthLastWeek.find(item => {
          return currentDate.format("YYYYMMDD") === item.format("YYYYMMDD");
        });

        if (inMonthLastWeek) {
          weeks.forEach(item => {
            const isSelectedDay = currentDate.isoWeekday() === item.value;
            const isDayInWeekSelected = item.done;

            if (isSelectedDay && isDayInWeekSelected) {
              retArr.push(formattedDate);
            }
          });
        }
      };

      /**
       * 1回／月：最終治療日
       */
      const setMonthLastTreatDate = async () => {
        if (treatDateList.length === 0) {
          const paramJson = {};
          // 施設情報
          paramJson.facility_cd = this.structData.facilityCd;
          // 患者情報
          paramJson.pat_id = this.structData.patId;
          // 治療開始日時
          paramJson.ind_start_date = startDate;
          // 治療終了日時
          paramJson.ind_end_date = endDate;
          // 曜日パターン
          paramJson.week_pattern = JSON.stringify(weeks);

          // 対象日時の治療情報取得
          const response = await ApiHelper.post(
            "/mainData/TreatDateList",
            paramJson
          ).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndMedicineCreateBase.vue', 'setMonthLastTreatDate', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          });

          treatDateList = response.data.map(({ treatDate }) => treatDate);
        }

        // 今月分の日付リストを作成
        const currentMonthDates = treatDateList.filter(treatDate => {
          const date = moment(treatDate, "YYYYMMDD");

          return (
            date.year() === currentDate.year() &&
            date.month() === currentDate.month()
          );
        });

        // 今月分の日付リストに最低1件の治療予定がある場合、最終治療日を取得
        if (currentMonthDates.length > 0) {
          const lastTreatDate = currentMonthDates.reduce((prevDate, currDate) =>
            prevDate > currDate ? prevDate : currDate
          );

          retArr.push(lastTreatDate);
        }
      };

      let isNextYear = false;
      // 指定期間で日毎にパターンチェックをする
      while (currentDate <= endDate) {
        const formattedDate = currentDate.format("YYYYMMDD");

        switch (pattern) {
          // 毎回
          case 0:
            retArr.push(formattedDate);
            break;
          // 毎週
          case 1:
            setWeeklyDates(formattedDate, 0);
            break;
          // 1回／2週
          case 2:
            setWeeklyDates(formattedDate, 1);
            break;
          // 1回／3週
          case 3:
            setWeeklyDates(formattedDate, 2);
            break;
          // 1回／4週
          case 4:
            setWeeklyDates(formattedDate, 3);
            break;
          // 1回／月：第1曜日
          case 5:
            setWeekOfMonthDates(formattedDate, 0);
            break;
          // 1回／月：第2曜日
          case 6:
            setWeekOfMonthDates(formattedDate, 1);
            break;
          // 1回／月：第3曜日
          case 7:
            setWeekOfMonthDates(formattedDate, 2);
            break;
          // 1回／月：第4曜日
          case 8:
            setWeekOfMonthDates(formattedDate, 3);
            break;
          // 1回／月：最終曜日
          case 9:
            setMonthLastWeekDates(formattedDate);
            break;
          // 1回／月：最終治療日
          case 10:
            await setMonthLastTreatDate();
            break;
          default:
            break;
        }

        if (pattern === 10) {
          currentDate.add(1, "M");
        } else {
          currentDate.add(1, "d");

          // 次年になった場合の補正処理
          // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
          // const startWeek = startDate.clone().week();
          // const currentWeek = currentDate.clone().week();
          const startWeek = startDate.clone().isoWeek();
          const currentWeek = currentDate.clone().isoWeek();
          // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
          // currentWeek減算分、nextUpdateWeekも減算
          if (currentWeek < startWeek && !isNextYear) {
            // 次年になった場合(currentWeek(週目数)がリセット(減算)された場合※「週目：1月から数えて現在◯週目か」)
            isNextYear = true;
            const maxSubtractDate = currentDate.clone().subtract(1, "day");
            // currentWeekリセット分を取得
            // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
            // const subtract = maxSubtractDate.week();
            const subtract = maxSubtractDate.isoWeek();
            // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
            // nextUpdateWeek(週目数)をリセットする
            nextUpdateWeek -= subtract;
          }
        }
      }

      return retArr;
    },

    /**
     * メッセージダイアログ返答処理
     */
    confirmResult(answer) {
      // メッセージを出した場合、ボタン活性
      this.updateDisable = false;
      switch (this.messageDialogInfo.messageCd) {
        // 「編集中の情報が破棄されます キャンセルしてよろしいですか？」
        case 20010001:
          if ("OK" === answer) {
            // モーダルを閉じる
            this.$emit("hide-modal");
          }
          break;

        // 「現在体重測定を終了し、透析開始前の患者の指示が変更されました。 指示を確認して、必要があれば処置してください。」
        case 22020003:
          // 参照元画面更新フラグをON
          this.isRefresh = true;
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;

        default:
          break;
      }
    },

    // /**
    //  * 治療開始日の調整
    //  */
    // AdjustTreatStartDate(startDate) {
    //   // 期間指定での操作の場合以下の処理を実行
    //   if (!this.weekEdit) {
    //     const date = parseInt(moment(startDate).format("YYYYMMDD"));
    //     // 過去日制御
    //     const today = parseInt(moment().format("YYYYMMDD"));
    //     if (today > date) {
    //       this.structData.indStartDate = moment().format("YYYY-MM-DD");
    //     }
    //     // 最大値の制御
    //     const maxDate = parseInt(moment(this.maxDate).format("YYYYMMDD"));
    //     if (date > maxDate) {
    //       this.structData.indStartDate = moment(this.maxDate).format(
    //         "YYYY-MM-DD"
    //       );
    //     }
    //   }

    //   if (moment(startDate) > moment(this.structData.indDayIntervalStartDate)) {
    //     this.structData.indDayIntervalStartDate = startDate;
    //   }
    //   // Storeに開始日(初回投与日)を保存
    //   this.setIndStartDate(this.structData.indDayIntervalStartDate);
    // },
    /**
     * 治療日の調整
     */
    AdjustTreatStartDate(treatDate,startDate) {
      //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start
      if(treatDate === ""){
        return;
      }
      //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy end
      // 期間指定での操作の場合以下の処理を実行
      if (!this.weekEdit) {
        const date = parseInt(moment(treatDate).format("YYYYMMDD"));
        // 過去日制御
        let today;
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
        // if (startDate) {
        //   today = parseInt(moment().format("YYYYMMDD"));
        // }else{
        today = parseInt(moment(this.structData.indStartDate).format("YYYYMMDD"));
        // }
        // if (today > date) {
        //   if (startDate) {
        //     this.structData.indStartDate = moment().format("YYYY-MM-DD");
        //   }else{
        //     this.structData.indEndDate = moment(this.structData.indStartDate).format("YYYY-MM-DD");
        //   }
        // }else{
        if (startDate) {
          this.structData.indStartDate = moment(treatDate).format("YYYY-MM-DD");
        }else{
          this.structData.indEndDate = moment(treatDate).format("YYYY-MM-DD");
        }
        // }
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
        // 最大値の制御
        const maxDate = parseInt(moment(this.maxDate).format("YYYYMMDD"));
        if (date > maxDate) {
          if (startDate) {
            this.structData.indStartDate = moment(this.maxDate).format("YYYY-MM-DD");
          }else{
            this.structData.indEndDate = moment(this.maxDate).format("YYYY-MM-DD");
          }
        }
      }
      // Storeに開始日(初回投与日)を保存
      this.setIndStartDate(this.structData.indStartDate);
    },
      // mod 8560 開始日の日付のキーボード入力が不正 張 end

    /**
     * 項目編集中のフラグをオンにする
     */
    focusStartEditing() {
      this.startEditFlg = true;
      this.focusFlg= true;
    },

    /**
     * 治療予定リスト取得
     */
    async getTreatDateList() {
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = this.structData.facilityCd;
      // 患者情報
      paramJson.pat_id = this.structData.patId;
      // 治療開始日時
      paramJson.start_date = this.structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = this.structData.indEndDate;
      // 曜日パターン
      paramJson.weeks = JSON.stringify(this.structData.indWeeks);
      // クール
      paramJson.ind_kur_cd = JSON.stringify(this.structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(
        this.structData.selectedTreat
      );

      // 対象日時の治療情報取得(日付・曜日・治療方法・クールで絞り込み)
      const response = await ApiHelper.post(
        "/mainData/treatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndMedicineCreateBase.vue', 'getTreatDateList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      this.treatDateListAll = response.data.map(({ treatDate }) => treatDate);

      // 本日日付からの最大範囲のデータを取得し、保持する
      paramJson.start_date = moment(new Date()).format("YYYY-MM-DD");
      const responseFixed = await ApiHelper.post(
        "/mainData/treatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndMedicineCreateBase.vue', 'responseFixed', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      this.treatDateListFixedAll = responseFixed.data.map(({ treatDate }) => treatDate);
    },

    // add FNSI-FutreNetWeb+SI課題管理No.3993 李 start
    /**
     * 治療がない日付の取得
     * @param dataList 治療日リスト
     */
    getDisTreatDateList(dataList) {
      // 治療日無しリスト初期化
      this.disabledDateList = [];
      // 対象期間のすべての日時リスト
      const targetPeriodDateList = [];

      // 本日の日付を取得
      const startDate = moment();
      const endDate = moment(this.disableDatesAfter).add(1, "days");

      // 今日から来年の昨日までの日時をリストで取得
      while (startDate.diff(endDate) <= 0) {
        targetPeriodDateList.push(moment(startDate).format("YYYYMMDD"));
        startDate.add(1, "days");
      }

      // 今日から来年の昨日までの日付をループ
      targetPeriodDateList.forEach(eleDate => {
        // 重複無しフラグ
        let disDuplicateFlag = true;
        // 治療日の日をループ
        dataList.forEach(date => {
          // 重複があれば重複無しフラグをfalseに変更
          if (eleDate === date) {
            disDuplicateFlag = false;
          }
        });
        // 重複が無い場合、格納する
        if (disDuplicateFlag) {
          this.disabledDateList.push(eleDate);
        }
      });
    },
    // add FNSI-FutreNetWeb+SI課題管理No.3993 李 end
    // #10196 初回投与日  数字の手動入力はできません linjunfeng start
    handleIndDayIntervalStartDateBlur(event) {
      this.structData.indDayIntervalStartDate = event.target.value;
    },
    // #10196 初回投与日  数字の手動入力はできません linjunfeng end

    /**
     * 子コンポーネントの入力値に禁忌・アレルギータグが含まれているかを判定し、
     * 判定結果（true/false）をストアのtabooMedicineに設定する。
     */
    checkMedicineTabooAllergy() {
      this.setTabooMedicine(false);
      const comp = this.$slots.default?.[0]?.componentInstance;
      if (!comp) {
        return;
      }

      if (comp.listData) {
        const data = comp.listData;
        let tabooAllergyFlag = false;

        for (let item of data) {
          if (item.id && comp.$refs[item.id]) {
            const name = comp.$refs[item.id][0]?.medicineInputValue?.editValue;
            tabooAllergyFlag = containsTabooAllergyTag(name);
            if (tabooAllergyFlag) break;
          }
        }
        this.setTabooMedicine(tabooAllergyFlag);
      }
    },
  }
};
</script>

/** * スタイル定義 */
<style scoped>
.scroll-style {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.scroll-style >>> * {
  font-size: inherit;
}

.slot-style {
  padding: 5px 10px;
  overflow-y: auto;
  margin-bottom: 10px;
  height: 80%;
}
/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .slot-style {
    padding: 5px 10px;
    overflow-y: visible;
    margin-bottom: 10px;
    height: 80%;
  }
}
/** pc */
/** Device height:<530         */
@media only screen and (max-height:530px) {
  .slot-style {
    padding: 5px 10px;
    overflow-y: visible;
    margin-bottom: 10px;
    height: 80%;
  }
}

.div-style {
  padding: 5px 10px;
}

.onColor:checked + label {
  background-color: #9acd32;
}

.hr-style {
  margin: 0px 10px;
}

/* 開始日・終了日inputタブ */
.date-input {
  width: calc(100% - 32px);
  padding-right: 2px !important;
}

.sub-label {
  text-align: center;
}

@media screen and (min-width: 481px) {
  .sub-label {
    flex: 0 0 10em;
  }
}

input::-webkit-calendar-picker-indicator {
  display: none;
}
/* add FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start */
.custom-input-changed {
  border: 2px #008000 solid;
  outline: 0;
}
/* add FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 end */
/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 100px;
  padding-top: 8px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */
</style>

<style>
/* add 画面デザイン改善対応 李 start */
.kendo-dropdownlist-select-edited {
  color: green !important;
  font-weight: bold;
  border: 2px green solid !important;
}
.kendo-dropdownlist-select-edited > span {
  color: green !important;
}

.kendo-dropdownlist-listbox > .k-item {
  color: green !important;
  font-weight: normal;
}
/* add 画面デザイン改善対応 李 end */
  /* add 7952 必須項目にも関わらず背景色が黄色になっていない 張 start */
.select-style-list > span {
  background-color: #ffff99 !important;
}
  /* add 7952 必須項目にも関わらず背景色が黄色になっていない 張 end */
  /* #5884 薬剤追加时，开始日为空并且点击保存按钮后，没有弹出错误信息 訾浩 start */
.date-start-input {
  background-color: #ffff99 !important;
}
/* #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start */
.date-start-input[disabled]{
  color: #999;
}
/* #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end */
/* #5884 薬剤追加时，开始日为空并且点击保存按钮后，没有弹出错误信息 訾浩 end */
/* add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start */
.date-first-input input{
  background-color: #ffff99 !important;
}
/* add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end */
</style>
