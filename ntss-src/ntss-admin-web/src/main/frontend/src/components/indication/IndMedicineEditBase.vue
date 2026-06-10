/** * 指示ベース画面 */

<template>
  <!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start-->
  <!--  <modal-base @onClose="hideModal">-->
  <modal-base @onClose="hideModal(true)">
    <!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end-->
    <div slot="body" class="indInfo-style-modal-container">
      <div class="div-style" style="float: left;">
        <input
          type="radio"
          style="display: none;"
          class="identification"
          name="indMedicineEdit"
          value="0"
          id="ind-medicine-modal-edit"
          @click="changeSegment($event);"
          :checked="edit === 0"
        />
        <label for="ind-medicine-modal-edit" class="group-label first-of-type">編集</label>
        <input
          type="radio"
          style="display: none;"
          class="identification"
          name="indMedicineEdit"
          value="1"
          id="ind-medicine-modal-delete"
          @click="changeSegment($event);"
          :checked="edit === 1"
        />
        <label for="ind-medicine-modal-delete" class="group-label last-of-type">中止</label>
      </div>
      <div class="IndBaseHeader">
        <div>
          <v-ons-row class="div-style" style="clear: left;">
            <v-ons-col class="indInfo-style-label-position label-padding-top5">
              <label>開始日</label>
            </v-ons-col>
            <v-ons-col>
              <!-- add FNSI-投与薬剤編集の修正 楊 start -->
              <!-- <input
                v-model="structData.indStartDate"
                :disabled="settingData.startDateEdit"
                type="date"
                class="date-input common-style-input ntss-input-date"
                data-target="indStartDate"
                onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                @focus="focusStartEditing()"
                @blur="createNumDaysList($event)"
              />
              <custom-calendar
                v-model="structData.indStartDate"
                :disabled-weekdays="disabledWeekdays"
                :is-disabled-past-dates="true"
                :disabled="settingData.startDateEdit"
                :disable-dates-after="disableDatesAfter"
                @input="createNumDaysList($event)"
              />-->
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
                createNumDaysList($event); "
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
                createNumDaysList($event);"
                @change="resetComponentData()"
              />-->
              <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
              <!--<input
                v-model="structData.indStartDate"
                :disabled="settingData.startDateEdit"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date"
                data-target="indStartDate"
                onkeydown="(function(event){if(event.altKey && event.key=='ArrowDown'){event.preventDefault();}})(event)"
                @focus="focusStartEditing()"
                max="9999-12-31"
                @blur="AdjustTreatStartDate(structData.indStartDate,true);
                createKurAndTreatmentList($event);
                createNumDaysList($event);"
                @change="resetComponentData()"
              />-->
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
              <!--   createKurAndTreatmentList($event); -->
              <!--   createNumDaysList($event,'indStartDate');" -->
              <!--   @change="resetComponentData()" -->
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
                createNumDaysList($event,'indStartDate');"
                @change="resetComponentData()"
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
                resetComponentData()
                "
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <custom-calendar -->
              <!--   v-model="structData.indStartDate" -->
              <!--   :disabled-weekdays="disabledWeekdays" -->
              <!--   :disabled="settingData.startDateEdit" -->
              <!--   :disable-dates-after="disableDatesAfter" -->
              <!--   @input=" -->
              <!--   createKurAndTreatmentList($event); -->
              <!--   createNumDaysList($event,'indStartDate'); -->
              <!--   resetComponentData() -->
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
                resetComponentData()
                "
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
              <!-- add FNSI-投与薬剤編集の修正 楊 end -->
            </v-ons-col>
            <v-ons-col class="sub-label">
              <label></label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="div-style">
            <v-ons-col class="indInfo-style-label-position label-padding-top5">
              <label class="vertical-align-center">
                <input type="radio" @change="changeEndDateLabel" v-model="picked" value="1" :disabled="settingData.endDateEdit">
                終了日
              </label>
              <label class="vertical-align-center">
                <input type="radio" @change="changeEndDateLabel" v-model="picked" value="2" :disabled="settingData.endDateEdit">
                回数
              </label>
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <!-- mod #5589 数値IFのスタイル全不正 林峻峰 start -->
                <!-- <v-ons-col style="display: inline-block;"> -->
                <v-ons-col style="display: inline-block;position:relative">
                  <!-- mod #5589 数値IFのスタイル全不正 林峻峰 end -->
                  <!-- add FNSI-投与薬剤編集の修正 楊 start -->
                  <!--
                      <input
                        v-show="endDateLabel === '終了日'"
                        v-model="structData.indEndDate"
                        :disabled="settingData.endDateEdit"
                        :min="structData.indStartDate"
                        :max="maxDate"
                        type="date"
                        class="date-input common-style-input ntss-input-date"
                        data-target="indEndDate"
                        @focus="focusStartEditing()"
                        @blur="createNumDaysList($event)"
                      />
                      <custom-calendar
                        v-show="endDateLabel === '終了日'"
                        v-model="structData.indEndDate"
                        :is-disabled-past-dates="true"
                        :disabled="settingData.endDateEdit"
                        :disable-dates-after="disableDatesAfter"
                        @input="createNumDaysList($event)"
                      /> -->
                  <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
                  <!-- <input
                    v-show="endDateLabel === '終了日'"
                    v-model="structData.indEndDate"
                    :disabled="settingData.endDateEdit"
                    :min="structData.indStartDate"
                    :max="maxDate"
                    type="date"
                    class="date-input common-style-input ntss-input-date"
                    data-target="indEndDate"
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
                     class="date-input common-style-input ntss-input-date"
                     data-target="indEndDate"
                     @focus="focusStartEditing()"
                     @blur="
                     createKurAndTreatmentList($event);
                     createNumDaysList($event);
                     "
                   />-->
                   <!-- #10196 中止、終了日を選択して過去日、再びxをクリックして、回数が表示されません linjunfeng start -->
                   <!-- <date-input
                    v-show="endDateLabel === '終了日'"
                    @handleClearInput="structData.indEndDate = ''"
                    v-model="structData.indEndDate"
                    :disabled="settingData.endDateEdit"
                    :min="structData.indStartDate"
                    :max="maxDate"
                    type="date"
                    id="date-end"
                    class="date-input common-style-input ntss-input-date"
                    data-target="indEndDate"
                    @focus="focusStartEditing()"
                    @blur="AdjustTreatStartDate(structData.indEndDate,false);
                    createKurAndTreatmentList($event);
                    createNumDaysList($event);
                    "
                  />  -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <date-input -->
                  <!--   v-show="endDateLabel === '終了日'" -->
                  <!--   @handleClearInput="structData.indEndDate = '';structData.indNumDays.edit = null" -->
                  <!--   v-model="structData.indEndDate" -->
                  <!--   :disabled="settingData.endDateEdit" -->
                  <!--   :min="structData.indStartDate" -->
                  <!--   :max="maxDate" -->
                  <!--   type="date" -->
                  <!--   id="date-end" -->
                  <!--   class="date-input common-style-input ntss-input-date" -->
                  <!--   data-target="indEndDate" -->
                  <!--   @focus="focusStartEditing()" -->
                  <!--   @blur="AdjustTreatStartDate(structData.indEndDate,false); -->
                  <!--   createKurAndTreatmentList($event); -->
                  <!--   createNumDaysList($event); -->
                  <!--   " -->
                  <!-- /> -->
                  <date-input
                    v-show="endDateLabel === '終了日'"
                    @handleClearInput="structData.indEndDate = '';structData.indNumDays.edit = null"
                    v-model="structData.indEndDate"
                    :disabled="settingData.endDateEdit || !getItemAuthorized('Indication', 'default_authority')"
                    :min="structData.indStartDate"
                    :max="maxDate"
                    type="date"
                    id="date-end"
                    class="date-input common-style-input ntss-input-date"
                    data-target="indEndDate"
                    @focus="focusStartEditing()"
                    @blur="AdjustTreatStartDate(structData.indEndDate,false);
                    createKurAndTreatmentList($event);
                    createNumDaysList($event);
                    "
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #10196 中止、終了日を選択して過去日、再びxをクリックして、回数が表示されません linjunfeng end -->
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
                  <!-- add FNSI-投与薬剤編集の修正 楊 end -->
                  <!-- mod #5589 数値IFのスタイル全不正 林峻峰 start -->
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
                  /> --><!-- add FNSI-投与薬剤編集の修正 楊 end -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <input -->
                  <!--   id="iputIndNumDays" -->
                  <!--   v-show="endDateLabel === '回数'" -->
                  <!--   v-model="structData.indNumDays.edit" -->
                  <!--   type="number" -->
                  <!--   class="date-input common-style-input" -->
                  <!--   @change="inputNumber($event)" -->
                  <!--   @mousewheel.prevent="onMouseWheel($event)" -->
                  <!--   @blur="createNumDaysList($event)" -->
                  <!--   @focus="handleFocus" -->
                  <!-- /> -->
                  <input
                    id="iputIndNumDays"
                    v-show="endDateLabel === '回数'"
                    v-model="structData.indNumDays.edit"
                    type="number"
                    class="date-input common-style-input"
                    @change="inputNumber($event)"
                    @mousewheel.prevent="onMouseWheel($event)"
                    @blur="createNumDaysList($event)"
                    @focus="handleFocus"
                    :disabled="!getItemAuthorized('Indication', 'default_authority')"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod #5589 数値IFのスタイル全不正 林峻峰 end -->
                  <span v-show="endDateLabel === '回数'"> 回</span>
                </v-ons-col>
                <v-ons-col align="center" class="sub-label">
                  <label>{{ endDateSublabel }}</label>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- add FNSI-投与薬剤編集の修正 楊 start -->
          <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
          <!-- <v-ons-row class="div-style" v-if="settingData.isTitleCk"> -->
          <v-ons-row class="div-style" v-show="settingData.isTitleCk&edit == 0">
            <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
            <v-ons-checkbox
              v-model="isShowIndDayInterval"
              @click="showIndDayInterval"
              class="checkbox"></v-ons-checkbox>
            <label>投与間隔を変更する</label>
          </v-ons-row>

          <div
            v-if="showCurrentWeekPatternDetail"
          >
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
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <v-ons-select -->
                <!--   id="v-ons-select-id" -->
                <!--   v-model="structData.indDayIntervalSelected" -->
                <!--   class="date-input" -->
                <!--   @change=" -->
                <!--   refreshWeeks(); -->
                <!--   createKurAndTreatmentList($event); -->
                <!--   createNumDaysList($event); -->
                <!-- " -->
                <!-- > -->
                <v-ons-select
                  id="v-ons-select-id"
                  v-model="structData.indDayIntervalSelected"
                  class="date-input"
                  @change="
                  refreshWeeks();
                  createKurAndTreatmentList($event);
                  createNumDaysList($event);
                "
                  :disabled="!getItemAuthorized('Indication', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
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
                <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
                <!-- <input
                  v-model="structData.indDayIntervalStartDate"
                  type="date"
                  id="date-first"
                  onkeypress="function()"
                  class="date-input common-style-input ntss-input-date"
                  @input="createNumDaysList($event)"
                  ref="startDate"
                /> -->
                <!-- #10196 初回投与日  数字の手動入力はできません linjunfeng start-->
                <!-- <date-input
                  v-model="structData.indDayIntervalStartDate"
                  type="date"
                  :disabled="true"
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
                <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 end -->
                <!-- <custom-calendar
                  v-model="structData.indDayIntervalStartDate"
                  :disable-dates-after="disableDatesAfter"
                  @input="createNumDaysList($event)"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <custom-calendar -->
                <!--   v-model="structData.indDayIntervalStartDate" -->
                <!--   :disable-dates-after="disableDatesAfter" -->
                <!--   @input="createNumDaysList($event)" -->
                <!--   :selected-dates="dateList" -->
                <!--   :disabled-dates="disabledDateList" -->
                <!-- /> -->
<!--                modify 10266 by kangjie 20240712 start-->
<!--                <custom-calendar-->
<!--                  v-model="structData.indDayIntervalStartDate"-->
<!--                  :disable-dates-after="disableDatesAfter"-->
<!--                  @input="createNumDaysList($event)"-->
<!--                  :selected-dates="dateList"-->
<!--                  :disabled-dates="disabledDateList"-->
<!--                  :disabled="!getItemAuthorized('Indication', 'default_authority')"-->
<!--                />-->
                <!-- #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start -->
                <!-- <custom-calendar
                  v-model="structData.indDayIntervalStartDate"
                  :disable-dates-after="disableDatesAfter"
                  @input="createNumDaysList($event)"
                  :selected-dates="firstTurnTreatDateList"
                  :disabled="!getItemAuthorized('Indication', 'default_authority')"
                  :active-date="true"
                /> -->
                <custom-calendar
                  v-model="structData.indDayIntervalStartDate"
                  :disable-dates-after="disableDatesAfter"
                  @blur="createNumDaysList($event, 'indDayIntervalStartDate')"
                  @todayButtonClick="createNumDaysList($event, 'indDayIntervalStartDate')"
                  :selected-dates="firstTurnTreatDateList"
                  :disabled="!getItemAuthorized('Indication', 'default_authority')"
                  :active-date="true"
                />
                <!-- #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end -->
                <!--                modify 10266 by kangjie 20240712 end-->
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
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
                <!--   selectedTreatChange($event); -->
                <!--   createKurList(dataList); -->
                <!--   createNumDaysList($event); -->
                <!--   resetComponentData() -->
                <!-- " -->
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
                  selectedTreatChange($event);
                  createKurList(dataList);
                  createNumDaysList($event);
                  resetComponentData()
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
                <!--   selectedKurChange($event); -->
                <!--   createTreatmentList(dataList); -->
                <!--   createNumDaysList($event); -->
                <!--   resetComponentData() -->
                <!-- " -->
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
                  selectedKurChange($event);
                  createTreatmentList(dataList);
                  createNumDaysList($event);
                  resetComponentData()
                "
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
              </v-ons-col>
            </v-ons-row>
          </div>
          <!-- add FNSI-投与薬剤編集の修正 楊 end -->
        </div>
      </div>
      <hr class="hr-style" />

      <div class="slot-style" style="white-space: pre-line;">
        <!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start-->
        <!--        <ind-medicine-edit-->
        <!--          v-if="edit == 0"-->
        <!--          ref="mediEdit"-->
        <!--          :fields-data="settingData.fieldsData"-->
        <!--          v-on:changeFlag="changeEditFlag"-->
        <!--        />-->
        <ind-medicine-edit
          v-if="edit == 0"
          ref="mediEdit"
          :fields-data="settingData.fieldsData"
        />
        <!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end-->
        <ind-medicine-edit
          v-else-if="edit == 1"
          ref="mediEdit"
          :show-medicine-field-only="true"
          :fields-data="settingData.fieldsData"
        />
      </div>
      <hr class="hr-style" />
      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          :visible.sync="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          :title="messageDialogInfo.title"
          @confirm="confirmResult"
        />
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
              @click="hideModal(true)"
            >
              キャンセル
            </v-ons-button> -->
            <v-ons-button
              class="btn2-cancel width-padding"
              style="float: left;"
              @click="hideModal(true)"
            >
              キャンセル
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
          <v-ons-col style="display: flex; justify-content: flex-end; align-items: center; flex-flow: wrap;">
            <!-- add #11311 編集箇所のみ保存の再精査 zkm start -->
            <div v-show="edit == 0">
              <v-ons-checkbox :disabled="isShowIndDayInterval" input-id="editOnly" v-model="structData.editOnly"/>
              <label for="editOnly" class="popoverFilterLabel">編集箇所のみ</label>
            </div>
            <!-- add #11311 編集箇所のみ保存の再精査 zkm end -->
            <div v-if="edit == 0">
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
              <!-- <v-ons-button
                class="common-style-ok-button"
                style="float: right;"
                :disabled="updateDisable"
                @click="updateIndInfo(2)"
              >
                保存
              </v-ons-button> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-button -->
              <!--   class="btn1-execute width-padding" -->
              <!--   style="margin-left: 1.5em;" -->
              <!--   :disabled="updateDisable || !editFlg" -->
              <!--   @click="updateIndInfo(2)" -->
              <!-- > -->
              <!-- add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start -->
              <v-ons-button
                class="btn1-execute width-padding"
                style="margin-left: 1.5em"
                :disabled="
                  updateDisable ||
                  !getItemAuthorized('Indication', 'default_authority')
                "
                @click="updateIndInfo(2, 'upd')"
              >
                保存
              </v-ons-button>
              <!-- add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end -->
<!--              <v-ons-button-->
<!--                class="btn1-execute width-padding"-->
<!--                style="margin-left: 1.5em"-->
<!--                :disabled="-->
<!--                  updateDisable ||-->
<!--                  !editFlg ||-->
<!--                  !getItemAuthorized('Indication', 'default_authority')-->
<!--                "-->
<!--                @click="updateIndInfo(2)"-->
<!--              >-->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                保存-->
<!--              </v-ons-button>-->
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
            </div>
            <div v-else>
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
              <!-- <v-ons-button
                class="common-style-ok-button"
                style="float: right;"
                :disabled="updateDisable"
                @click="updateIndInfo(3)"
              >
                中止
              </v-ons-button> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-button -->
              <!--   class="btn4-alert width-padding" -->
              <!--   style="float: right;" -->
              <!--   :disabled="updateDisable" -->
              <!--   @click="updateIndInfo(3)" -->
              <!-- > -->
<!--              <v-ons-button-->
<!--                class="btn4-alert width-padding"-->
<!--                style="float: right;"-->
<!--                :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"-->
<!--                @click="updateIndInfo(3)"-->
<!--              >-->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                中止-->
<!--              </v-ons-button>-->
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
              <!-- add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start -->
              <v-ons-button
                class="btn4-alert width-padding"
                style="float: right;margin-right: 8px;"
                :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"
                @click="updateIndInfo(3, 'del')"
              >
                中止
              </v-ons-button>
              <!-- add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end -->
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
  import { AUTHORITY_CODES } from "@/constants/userAuthority";
  import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  import { deepCopy } from "@/functions/common/CommonFunctions";
  import { dateFormat, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";
  import moment from "moment";
  import IndMedicineEdit from "@/components/indication/IndMedicineEdit";
  import ModalBase from "@/components/modals/ModalBase";
  import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
  // add FNSI-投与薬剤編集の修正 楊 start
  import { deduplicateObjects } from "@/functions/common/CommonFunctions";
  // add FNSI-投与薬剤編集の修正 楊 end
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
  // add #5589 2023/03/29 数値IFのスタイル全不正 林峻峰 start
  import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
  // add #5589 2023/03/29 数値IFのスタイル全不正 林峻峰 end
//add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
  import DateInput from "@/components/common/DateInput.vue";
//add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end

  export default {
    components: {
      "custom-calendar": CustomCalendar,
      "message-dialog": messageDialog,
      "ind-medicine-edit": IndMedicineEdit,
      // add #5589 2023/03/29 数値IFのスタイル全不正 林峻峰 start
      "custom-input-number": customInputNumber,
      // add #5589 2023/03/29 数値IFのスタイル全不正 林峻峰 end
    //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      "date-input":DateInput,
    //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
      ModalBase
    },
    mixins: [IndUserSelectMixin],
    props: {
      settingData: {
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
        fieldsData: {
          type: Object,
          default: () => ({
            equipmentFieldData: {},
            amountFieldData: null,
            unitFieldData: null
          })
        },
        startDateEdit: {
          type: Boolean,
          default: false
        },
        endDateEdit: {
          type: Boolean,
          default: false
        }
      },

      modalVisible: {
        type: Boolean,
        default: false
      }
    },
    data() {
      return {
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
        // editFlg: false,
        // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
        editAddFlg: false,
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
            init: 1,
            edit: 1
          }
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
         * モーダルスタイル
         */
        styleObj: { "max-width": "370px", width: "370px" },
        endDateLabel: "終了日",
        indDayIntervalStartDate: this.settingData.startDate,
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
        treatDates: [],
        /**
         * 更新不可フラグ
         */
        updateDisable: false,

        treatDateList: [],
        selectedTndMediNo: null,
        treatDatesAll: [],
        // 本日日付からの最大範囲の治療日リストを格納
        treatDateListFixedAll: [],
        // 開始日付からの最大範囲の治療日リストを格納
        tmpTreatDateListAll: [],
        isChangedIndNumDays: false,
        picked: 1,
        // 編集中フラグ
        startEditFlg: true,
        // add FNSI-投与薬剤編集の修正 楊 start
        showCurrentWeekPatternDetail: false,
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
        isShowIndDayInterval: false,
        // add FNSI-投与薬剤編集の修正 楊 end
        // 回数の最大値
        maxNumDays: 1,
        // add 画面デザイン改善対応 李 start
        callsNumberIntervalFlg: false,
        firIntervalValue: null,
        // add 画面デザイン改善対応 李 end
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
        /**
         * 治療日しリスト
         */
        dateList: [],
        /**
         * 治療日無しリスト
         */
        disabledDateList: [],
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
        isSendNextPatInfoFlg: false,
        setIntervalObj: null,
        // mod #5589 2023/04/24 数値IFのスタイル全不正 林峻峰 start
        blurFlg: false,
        focusFlg: false,
        // mod #5589 2023/04/24 数値IFのスタイル全不正 林峻峰 end
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
        initStructData: null,
        initIndUser: null,
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
        // add 10266 by kangjie 20240716 start
        firstTurnTreatDateList:[],
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

      // add FNSI-投与薬剤編集の修正 楊 start
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
      // add FNSI-投与薬剤編集の修正 楊 end
      endDateSublabel() {
        if (this.endDateLabel === "終了日") {
          if (
            (this.structData.indEndDate && this.structData.indNumDays.edit) ||
            this.structData.indNumDays.edit === 0
          ) {
            return `回数: ${this.structData.indNumDays.edit}回`;
          } else {
            return;
          }
        } else if (this.endDateLabel === "回数") {
          return `終了日: ${this.displayEndDate}`;
        }

        return null;
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
    // add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      /**
       * 指定日前編集不可
       */
      disableDatesBefore() {
        return moment(this.structData.indStartDate).format("YYYYMMDD");
      },
      toMonth() {
        return moment(this.structData.indStartDate).format("YYYY-MM-DD");
      },
    // add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end

      selectedDates() {
        // add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
        this.getDisTreatDateList(this.dateList);
        // add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
        return {
          default: this.treatDates,
          // mod FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 start
          // custom: this.treatDatesAll
          custom: this.treatDateListFixedAll
          // mod FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 end
        };
      },

      displayEndDate() {
        if (
          this.structData.indEndDate === null ||
          this.structData.indEndDate === ""
        ) {
          return "";
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
      },
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
      editFlg(){
        let editCount = 0;
      if(this.initStructData){
          if(JSON.stringify(this.initStructData.indStartDate) != JSON.stringify(this.structData.indStartDate)){
            editCount++;
          }
          const copyIndEndDate = this.structData.indEndDate === null ? "" : this.structData.indEndDate;
          if(JSON.stringify(this.initStructData.indEndDate) != JSON.stringify(copyIndEndDate)){
            editCount++;
          }
          if(JSON.stringify(this.initStructData.indNumDays.edit) != JSON.stringify(this.structData.indNumDays.edit)){
            editCount++;
          }
          if(JSON.stringify(this.initStructData.indDayIntervalSelected) != JSON.stringify(this.structData.indDayIntervalSelected)){
            editCount++;
          }
          if(JSON.stringify(this.initStructData.indWeeks) != JSON.stringify(this.structData.indWeeks)){
            editCount++;
          }
          if ((this.initIndUser ?? "") != (this.structData.indUser ?? "")) {
            editCount++;
          }
        }
        return editCount > 0 || this.$refs.mediEdit?.checkEdit();
      }
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
    },

    watch: {
      // add FNSI-投与薬剤編集の修正 楊 start
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

      "structData.indDayIntervalStartDate"(newVal, oldVal) {
        // #10196 初回投与日  数字の手動入力はできません linjunfeng start
        this.indDayIntervalStartDateInput = newVal;
        // #10196 初回投与日  数字の手動入力はできません linjunfeng end
      },
      // add FNSI-投与薬剤編集の修正 楊 end

      // 回数の入力
      "structData.indNumDays.edit"(value) {
        // mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 start
        // if (!value || value < 0) {
        //   // 0以下、不正な入力の場合は空欄に
        //   this.structData.indNumDays.edit = "";
        // }
        //  else if (value > this.maxNumDays) {
        //   // 最大値を超えないように制限
        //   this.structData.indNumDays.edit = this.maxNumDays;
        // }
        // mod #5589 2023/04/13 数値IFのスタイル全不正 林峻峰 end
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
        if ((val ?? "") != (this.initIndUser ?? "")) {
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
      await this.setLoadingScreenMessage("処理中...");
      await this.setLoadingScreenVisible(true);
      //FutureNetWeb+Si no.5448 劉全航 start
      // mod 10787 投与薬剤の数量を変更すると薬剤が消える。 start
      // let url = `mainData/getIndMediInfoHistory/${this.settingData.patId}/${this.settingData.facilityCd}/${this.settingData.fieldsData.seqNo}`;
      let url = `mainData/getAllIndMediInfo/${this.settingData.patId}/${this.settingData.facilityCd}/${this.settingData.fieldsData.seqNo}`;
      // ApiHelper.get(url).then(response => {
      await ApiHelper.get(url).then(response => {
      // mod 10787 投与薬剤の数量を変更すると薬剤が消える。 end
        // 曜日
        this.structData.indDayIntervalSelected = this.settingData.dateInterval;
        var week = response.data.dow;
        var dayList = week.split(",");
        // #10266 薬剤を編集し、日曜全選初期化した場合、全ボタンは起動しません。linjunfeng start
        // this.structData.indWeeks[0].done = false;
        this.structData.indWeeks[0].done = dayList.length === 7 ? true : false;
        // #10266 薬剤を編集し、日曜全選初期化した場合、全ボタンは起動しません。linjunfeng end
        this.structData.indWeeks[1].done = dayList.includes("1");
        this.structData.indWeeks[2].done = dayList.includes("2");
        this.structData.indWeeks[3].done = dayList.includes("3");
        this.structData.indWeeks[4].done = dayList.includes("4");
        this.structData.indWeeks[5].done = dayList.includes("5");
        this.structData.indWeeks[6].done = dayList.includes("6");
        this.structData.indWeeks[7].done = dayList.includes("0");

      }).catch(error => {
        throw error;
      });
      //FutureNetWeb+Si no.5448 劉全航 end
      // 治療開始日の制御
      // await this.AdjustTreatStartDate(this.structData.indStartDate);
      await this.AdjustTreatStartDate(this.structData.indStartDate,true);

      // add FNSI-投与薬剤編集の修正 楊 start
      if (this.settingData.isTitleCk) {
        // 治療方法、クールリスト設定
        await this.createKurAndTreatmentList();
      }
      // add FNSI-投与薬剤編集の修正 楊 end

      // 指示者リスト設定
      this.getIndUserList(
        AUTHORITY_CODES.IND_EDIT,
        AUTHORITY_CODES.IND_PEDIT
      ).then(response => {
        this.structData.userOptions = response.doctorList;
        this.$nextTick(() => {
          this.structData.indUser = response.iniSelectId;
          this.initIndUser = this.structData.indUser;
        });
      });
      const isMaxDate = true;
      const isNowStart = true;

      // add FNSI-投与薬剤編集の修正 楊 start
      // 治療方法・クールデフォルト値設定
      await this.setDefaultTreatmentAndKur(
        this.structData.indStartDate,
        this.structData.indEndDate
      );
      if (!this.settingData.isTitleCk) {
        // add FNSI-投与薬剤編集の修正 楊 end
        // 本日日付からの最大範囲のデータを保持
        let ordMainList = await this.getTreatDateList(isMaxDate, isNowStart);
        await this.setTreatDateListFixedAll(ordMainList);
        // 回数デフォルト値設定
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // await this.createNumDaysList();
        await this.createNumDaysList(null, 'created');
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end

        ordMainList = [];
        if (this.selectedTndMediNo === null && this.treatDateList.length === 0) {
          ordMainList = await this.getTreatDateList(isMaxDate);
          this.setTreatDateList(ordMainList);
        }
        // add FNSI-投与薬剤編集の修正 楊 start
      } else {
        // 治療予定リスト取得
        await this.getTreatDateListAll();
        // 回数デフォルト値設定
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // await this.createNumDaysList();
        await this.createNumDaysList(null, 'created');
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
        // 曜日選択初期化
        //FutureNetWeb+Si no.5448 劉全航 start
        //this.refreshWeeks();
        //FutureNetWeb+Si no.5448 劉全航 end
        // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng start
        // if (this.structData.indDayIntervalSelected === 0 || this.structData.indDayIntervalSelected === 10) {
        //   this.structData.indWeeks.forEach(item => {
        //     item.done = true;
        //     item.disabled = true;
        //   });
        // }
        // add #10196 投・間隔の変更曜日ごとに選択曜日後は不正表示となります。 linjunfeng end
        // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
      }
      // add FNSI-投与薬剤編集の修正 楊 end

      // 初期処理中に発火したイベント処理をスキップ
      this.startEditFlg = false;
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
      this.initStructData = JSON.parse(JSON.stringify(this.structData));
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
      await this.setLoadingScreenVisible(false);
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
      // this.setIntervalObj = setInterval(() => {
      //   let icount = $("ons-input[class*='-edited']").length;
      //   let lcount = $("label[class*='-edited']").length;
      //   let tcount = $("textarea[class*='-edited']").length;
      //   let spcount = $("span[class*='-edited']").length;
      //   let dpcount = $("input[class*='custom-input-changed']").length;
      //   //mod FNSI-4882 劉全航 start
      //   let scount = $("ons-select[class*='-edited']").length;
      //   //mod FNSI-4882 劉全航 end
      //   let dcount = $("div.custom-div-show-selected-item[class*='-edited']").length;
      //   if ((icount + lcount + tcount + scount + dcount + spcount + dpcount) === 0 && !this.editAddFlg) {
      //     this.editFlg = false;
      //   } else {
      //     this.editFlg = true;
      //   }
      // }, 200);
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
    },

    beforeDestroy() {
      if (this.setIntervalObj) {
        clearInterval(this.setIntervalObj);
      }
    },

    methods: {
      ...mapActions("loading-screen", [
        "setLoadingScreenVisible",
        "setLoadingScreenMessage",
        "startLoadingScreen",
        "finishLoadingScreen",
      ]),
      //FNSI-修正 #5525 横展開対応、xugj add start
      ...mapActions("treatment-record/common",
        [
          "getMstMachineByOrdNoRst",
          "sendNextPatInfoViewer"
        ]),
      //FNSI-修正 #5525 横展開対応、xugj add end
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
      changeEndDateLabel() {
        this.endDateLabel = this.endDateLabel === "終了日" ? "回数" : "終了日";
      },

      hideModal(isCancel = false) {
        // 変更箇所があればメッセージ表示
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
        // if (isCancel && this.$refs.mediEdit.checkEdit()) {
        //   this.messageDialogInfo.messageCd = 20010001;
        //   this.messageDialogInfo.type = "2";
        //   this.messageDialogInfo.isDialogVisible = true;
        //   return;
        // }
      if(isCancel && this.editFlg){
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[20010001].title,
            message: messageFormat(DIALOG_MESSAGES[20010001].message),
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
      // mod #5589 2023/04/24 数値IFのスタイル全不正 林峻峰 start
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
      handleFocus(){
        this.focusFlg=true;
      },
      // mod #5589 2023/04/24 数値IFのスタイル全不正 林峻峰 end
      changeSegment(event) {
        // add FNSI-投与薬剤編集の修正 楊 start
        this.isShowIndDayInterval = false;
        this.showCurrentWeekPatternDetail = false;
        // add FNSI-投与薬剤編集の修正 楊 end
        this.edit = event.target.value;
      // if (this.edit === 1) {
      //   this.structData.editOnly = true;
      // }
        // this.$slots.default[0].componentInstance.selectSegment(
        //   event.target.value
        // );
        // add #10266 薬剤編集と投薬、編集画面で薬剤に変化が生じ、操作を中止した場合、薬剤はリセットされません。 linjunfeng start
        this.$refs.mediEdit.selectSegment();
        // add #10266 薬剤編集と投薬、編集画面で薬剤に変化が生じ、操作を中止した場合、薬剤はリセットされません。 linjunfeng end
      },

      // mod #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
      /// async updateIndInfo(num) {
      async updateIndInfo(num, type = "") {
        // mod #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
        // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng start
        const amount = this.$refs.mediEdit?.amountInputValue?.editValue;
        if (amount === "" || isNaN(amount) || amount == 0) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[13000170].title,
            message: DIALOG_MESSAGES[13000170].message
          });
          return;
        }
        console.log("IndMedicineEditBase.vue updateIndInfo this.startLoadingScreen();");
        this.startLoadingScreen();
        // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng end
        // 更新不可フラグをtrueに
        this.updateDisable = true;
        let messageCd = null;
        let stringParams = "";

        const baseData = deepCopy(this.structData);
        // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
        baseData.type = type;
        // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
        // add FNSI内容修正 バグ284、286 姜 start
        baseData.ordNo = this.structData.ordNo;
        // add FNSI内容修正 バグ284、286 姜 end
        // add FNSI-FutreNetWeb+SI課題管理No.3848 李 start
        baseData.intervalFlg = this.isShowIndDayInterval;
        // add FNSI-FutreNetWeb+SI課題管理No.3848 李 end
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
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // if (null === messageCd && true === this.settingData.showWeeks) {
        if (null === messageCd && true === this.settingData.showWeeks && num != 3) {
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end  
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
        if (null === messageCd && !baseData.indDayIntervalStartDate && num != 3) {
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
        } else {
          if (baseData.indEndDate > day) {
            // 1年より後の日を選択している場合、1年後の日を設定
            baseData.indEndDate = day;
          }
        }

        if (!this.$refs.mediEdit.medicineInputValue.editValue) {
          messageCd = 22010001;
          stringParams = "薬剤";
        }

        //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
        // レンダリング完了を待ってから禁忌・アレルギーチェック処理実行
        await this.$nextTick();
        // 薬剤が禁忌・アレルギーかチェックし、ストアに可否をセット(後続のチェック処理で参照する)
        this.checkMedicineTabooAllergy();

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
                //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
                this.setTabooMedicine(false);
                //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
                this.updateIndInfo2(num, baseData, stringParams, messageCd);
              } else {
                this.updateDisable = false;
                console.log("IndMedicineEditBase.vue updateIndInfo return; this.finishLoadingScreen();");
                this.finishLoadingScreen();
                return;
              }
            }
          });
        } else {
          this.updateIndInfo2(num, baseData, stringParams, messageCd);
        }
        //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
        console.log("IndMedicineEditBase.vue updateIndInfo this.finishLoadingScreen();");
        this.finishLoadingScreen();
      },
      //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
      async updateIndInfo2(num, baseData, stringParams, messageCd) {
        console.log("IndMedicineEditBase.vue updateIndInfo2 this.startLoadingScreen();");
        this.startLoadingScreen();

        baseData.updUser = this.getStateUserAccountInfo.userId;

        // add FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 start
        // 変更投薬の治療日
        baseData.treatDates = this.treatDates;
        // 画面のすべての治療日
        baseData.treatDateListAll = this.selectedDates.custom;
        // add FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 end
        //add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
        baseData.number_of_doses = this.endDateLabel === "回数";
        //add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        // サーバ処理結果格納用
        let response = {};

        if ("" !== stringParams) {
          this.messageDialogInfo.messageCd = messageCd;
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.stringParams = [stringParams];
          this.messageDialogInfo.isDialogVisible = true;
          // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
          this.messageDialogInfo.title = DIALOG_MESSAGES[messageCd].title;
          // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
          console.log("IndMedicineEditBase.vue updateIndInfo2 return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        } else {
          baseData.flag = num;
          // 使用期限のチェック(中止処理以外)
          if (baseData.flag !== 3 && !await this.chkInExpiryDate(this.$refs.mediEdit, baseData.indStartDate, baseData.indEndDate)) {
            console.log("IndMedicineEditBase.vue updateIndInfo2 return; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            // キャンセルの場合処理終了
            return;
          }
          // this.startLoadingScreen("保存中...");
          response = await this.$refs.mediEdit.updateIndInfo(baseData);
        }

        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
        if (200 === response.status && 22020004 === response.data.msgCd) {
          this.messageDialogInfo.messageCd = response.data.msgCd;
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.stringParams = [""];
          this.messageDialogInfo.isDialogVisible = true;
          console.log("IndMedicineEditBase.vue updateIndInfo return true; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          // 処理終了
          return;
        }
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

        if (200 === response.status && undefined !== response.data.msgCd) {
          //FNSI-修正 #5525 横展開対応、xugj add start
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
          paramJson.ind_treatment_cd = JSON.stringify(this.structData.selectedTreat);

          // データの取得
          const responseOrdMain = await ApiHelper.post(
            `/mainData/getOrdMainDataInfo`,
            paramJson
          ).catch(error => {
            getErrorMessage('IndMedicineEditBase.vue', 'updateIndInfo', error);
            console.log("IndMedicineEditBase.vue updateIndInfo2 throw error; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            throw error;
          });

          const ordMainList = responseOrdMain.data;
          if(this.isSendNextPatInfoFlg) {
            ordMainList.forEach(async ordMain => {
              // 実績：治療状況は「条件送信後」以外の場合、次患者情報も更新する。
              if(ordMain.rstDialysisState !== "0") {
                const tempOrdNo = ordMain.ordNo;
                // 装置マスタの取得
                this.getMstMachineByOrdNoRst(tempOrdNo).then(machineRes => {
                  let mstMachine = machineRes.data;
                  if (mstMachine.length > 0){
                    try {
                      const params = {
                        ordNo: tempOrdNo, //オーダー番号
                        machineNo: mstMachine[0].machineNo, //装置マスタ.装置番号
                        deviceEdgeNo: mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
                        facilityCd: this.structData.facilityCd //施設コード
                      };
                      this.sendNextPatInfoViewer(params);
                    } catch (e) {
                      getErrorMessage('IndMedicineEditBase.vue','updateIndInfo','送信失敗しました。');
                      this.$ons.notification.alert({
                        modifier: "warn",
                        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                        // title: "送信失敗",
                        // message: `送信失敗しました。\n${e}`
                        title: DIALOG_MESSAGES['00200034'].title,
                        message: messageFormat(DIALOG_MESSAGES['00200034'].message, e),
                        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                      });
                    }
                  }
                });
              }
            });
          }
          //FNSI-修正 #5525 横展開対応、xugj add end
          //mod 6027 治療中に投与薬剤を追加した時 プロンプトなし 張 start
          // this.messageDialogInfo.messageCd = response.data.msgCd;
          // this.messageDialogInfo.type = "1";
          // this.messageDialogInfo.stringParams = [""];
          // this.messageDialogInfo.isDialogVisible = true;
          // 処理終了
          // return;
          //mod 6027 治療中に投与薬剤を追加した時 プロンプトなし 張 end
        }
        // this.finishLoadingScreen();
        // 参照元画面更新フラグをON
        this.isRefresh = true;
        console.log("IndMedicineEditBase.vue updateIndInfo2 hideModal() this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // モーダルを閉じる処理
        this.hideModal();
      },
      //add FutreNetWeb+SI課題管理 no.6422 劉全航 end

      /**
       * 使用期限のチェック処理
       */
      async chkInExpiryDate(medicineSetItem, indStartDate, indEndDate) {
        let msg = "";
        const selectedCd = medicineSetItem.medicinePopoverData.popoverContentSelected.value;
        // 薬剤/調製薬剤項目
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //if (medicineSetItem.medicineType === "1") {
        if (medicineSetItem.medicineType == 1) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          // 薬剤の場合
          const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineData"].filter(medi => medi.medicineCd === selectedCd);
          if (tmpMediObj.length > 0) {
            const mediObj = tmpMediObj[0];
            if (!fitTermCheckForUpdate(mediObj.useStartDate, mediObj.useEndDate, indStartDate, indEndDate)) {
              msg += "</br>" + mediObj.medicineName + "："
                + dateFormat.normalDateWithCheck(mediObj.useStartDate)
                + "～" + dateFormat.normalDateWithCheck(mediObj.useEndDate);
            }
          }
        } else {
          // 調製薬剤の場合
          const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineMixTabooAllergyData"].filter(medi => medi.medicineMixCd === selectedCd);
          if (tmpMediObj.length > 0) {
            const mediObj = tmpMediObj[0];
            if (!fitTermCheckForUpdate(mediObj.maxUseStartDate, mediObj.minUseEndDate, indStartDate, indEndDate)) {
              msg += "</br>" + mediObj.medicineMixName + "："
                + dateFormat.normalDateWithCheck(mediObj.maxUseStartDate)
                + "～" + dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
            }
          }
        }
        if (msg) {
          let rtn = false;
          await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "",
            title: DIALOG_MESSAGES[13000059].title,
            // message: "指示期間に使用期間外となる薬剤が含まれています。" + msg + "</br>登録してよろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000059].message, msg),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                // 処理を続行
                rtn = true;
              } else {
                // 処理を中止するので保存ボタン無効を解除
                this.updateDisable = false;
              }
            }
          });
          return rtn;
        } else {
          // チェック対象項目なし / 期限切れ項目なしの場合
          return true;
        }
      },
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
       * @description 初回オーダー番号指定時のみ行う
       */
      // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      // async createNumDaysList(event) {
      async createNumDaysList(event,type) {
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        if (this.edit == 1) {
          return;
        }
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end  
        // 回数項目が編集されたかのフラグ
        let isInitializeNumDays = false;
        this.focusFlg= false;
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
              // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
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
            const editEndDate = setEndDate ? moment(setEndDate, "YYYYMMDD").format("YYYY-MM-DD") : "";
            //mod 5448投与薬剤で回数を入力すると終了日が計算できない  end
            this.structData.indEndDate = editEndDate;
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
        // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
        // add 10266 by kangjie 20240716 end
        // add FNSI-投与薬剤編集の修正 楊 start
        if(!this.settingData.isTitleCk) {
          // add FNSI-投与薬剤編集の修正 楊 end
          // 対象日時の治療情報取得
          const ordMainList = await this.getTreatDateList();
          if (this.selectedTndMediNo === null && this.treatDateList.length === 0) {
            this.setTreatDateList(ordMainList);
          }

          this.treatDates = [];
          for (const ordMain of ordMainList) {
            if (ordMain.indMediInfo) {
              const indMediInfo = JSON.parse(ordMain.indMediInfo);
              const isSelectedTndMediNo = indMediInfo.find(
                indMedi => indMedi.no === this.selectedTndMediNo
              );
              if (isSelectedTndMediNo) {
                this.treatDates.push(ordMain.treatDate);
              }
            }
          }
          // 回数項目以外が変更された時の、回数項目の補正
          if (!isInitializeNumDays) {
            // 開始日が変更された場合、回数の入力範囲を更新
            if (this.treatDates || this.treatDates.length != 0) {
              this.tmpTreatDateListAll = this.treatDateListFixedAll.slice(this.treatDateListFixedAll.indexOf(this.treatDates[0]));
            } else {
              this.tmpTreatDateListAll = [];
            }
            // 回数の最大値を設定
            this.maxNumDays = this.tmpTreatDateListAll && this.tmpTreatDateListAll.length > 0 ? this.tmpTreatDateListAll.length : 1;
            // 回数値を補正
            const endDate = this.structData.indEndDate;
            const indNumDays = endDate && endDate !== "" ? this.treatDates.length : null;
            this.structData.indNumDays.init = indNumDays;
            this.structData.indNumDays.edit = indNumDays;
          }

          if (
            this.structData.indNumDays.edit &&
            this.structData.indNumDays.edit !== ""
          ) {
            // 指定されている回数により治療日をフィルタ
            this.treatDates = this.treatDates.splice(
              0,
              this.structData.indNumDays.edit
            );
          }
          // add FNSI-投与薬剤編集の修正 楊 start
        } else {
          // add FNSI-投与薬剤編集の修正 楊 end
          // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
          // mod 12273 投与薬剤編集にて「投与間隔を変更する」で曜日パターンを変更すると来週以降は変更前の指示が残る zkm start
          // if (type != "week" && type != "created") {
          if (type != "week" && type != "created" && this.showCurrentWeekPatternDetail) {
            // mod 12273 投与薬剤編集にて「投与間隔を変更する」で曜日パターンを変更すると来週以降は変更前の指示が残る zkm end
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
                  item.done = [0, 10].includes(this.structData.indDayIntervalSelected) || type === "indDayIntervalStartDate" || !this.isShowIndDayInterval ? true : false;
                } else {
                  item.done = false;
                }
              })
            } else {
              this.structData.indWeeks.forEach((item) => {
                item.done = [0, 10].includes(this.structData.indDayIntervalSelected) || type === "indDayIntervalStartDate" || !this.isShowIndDayInterval ? true : false;
              })
            }
          }
          // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
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
            getErrorMessage('IndMedicineEditBase.vue', 'createNumDaysList', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          });

          this.treatDates = response.data.map(item => {
            return item.treatDate;
          });
          // add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
          this.dateList = response.data.map(item => {
            return item.treatDate;
          });
          // add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
          // 開始日、終了日の範囲は上記取得処理で区切られている為、最大範囲でフィルタを作成する
          // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
          // const startDate = moment(this.structData.indDayIntervalStartDate);
          let startDate = moment(this.structData.indStartDate);
          const endDate = moment(this.maxDate.replace(/-/g, ""));
          // 1回／2週 1回／3週 1回／4週
          if ([2,3,4].includes(this.structData.indDayIntervalSelected)) {
            if (this.treatDates && this.treatDates[0]) {
              startDate = moment(this.treatDates[0]);
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
            startDate = moment(this.treatDates[0]);
          }
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
            // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
            //this.structData.indDayIntervalStartDate = moment(treatDatesFilterInterval[0], "YYYYMMDD").format("YYYY-MM-DD")
            let startDateFlg = false;
            // #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
            // this.treatDates.find(item => {
            //   if (item == moment(this.structData.indDayIntervalStartDate).format("YYYYMMDD")) startDateFlg = true;
            // });
            // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
            // if (type === 'indDayIntervalStartDate' && this.structData.indDayIntervalSelected != 10) {
            if (type === 'indDayIntervalStartDate') {
              // this.treatDates.find(item => {
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
                if (this.treatDates.includes(this.indDayIntervalStartDateManual)) {
                  this.structData.indDayIntervalStartDate = moment(this.indDayIntervalStartDateManual, "YYYYMMDD").format("YYYY-MM-DD");
                  startDateFlg = true;
                } else {
                  this.indDayIntervalStartDateManual = "";
                }
                if (this.treatDates && this.treatDates.length > 0 && treatDatesFilterInterval) {
                  const commonValues = this.treatDates.filter(item => treatDatesFilterInterval.includes(item));
                  treatDatesFilterInterval[0] = commonValues ? this.treatDates[0] : treatDatesFilterInterval[0];
                }
              }
            } else if ([5, 6, 7, 8].includes(this.structData.indDayIntervalSelected)) {
              if (this.treatDates && this.treatDates.length > 0 && treatDatesFilterInterval) {
                const commonValues = this.treatDates.filter(item => treatDatesFilterInterval.includes(item));
                if (commonValues && commonValues.length > 0) {
                  treatDatesFilterInterval[0] = commonValues[0];
                }
              }
            } else if (this.structData.indDayIntervalSelected != 1 || !startDateFlg) {
              this.indDayIntervalStartDateManual = "";
            }
            // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
            const indContent = this.firstTurnTreatDateList.find(item => treatDatesFilterInterval.includes(item));
            let weekDone = false;
            this.structData.indWeeks.forEach((item) => {
              if (item.done) {
                weekDone = true;
              }
            });
            if (![9, 10].includes(this.structData.indDayIntervalSelected) && (!indContent || !weekDone)) {
              this.structData.indDayIntervalStartDate = null;
              startDateFlg = true;
            }
            // add #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
            // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
            if (!startDateFlg) this.structData.indDayIntervalStartDate = moment(treatDatesFilterInterval[0], "YYYYMMDD").format("YYYY-MM-DD");
            startDateFlg = false;
            // del #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
            // if (type === 'indStartDate') {
            //   this.structData.indDayIntervalStartDate = this.treatDates ?  moment(this.treatDates[0], "YYYYMMDD").format("YYYY-MM-DD") : null;
            // }
            // del #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
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
          // add FNSI-【1006】最新の改修対象一覧の678対応 韓 end
          // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng start
          // 選択されている投与間隔により治療日をフィルタ
          const treatDatesFilter = await this.filterDates(
            moment(this.structData.indDayIntervalStartDate),
            endDate,
            this.structData.indDayIntervalSelected,
            this.structData.indWeeks
          );
          // add #11350 【たくしん会】投与薬剤追加・編集の初回投与日に正しい値が入らない　V1.0B linjunfeng end
          // フィルタを適用
          this.treatDates = await this.treatDates.filter(item => {
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
            // 回数値を補正
            const endDate = this.structData.indEndDate;
            const indNumDays = endDate && endDate !== "" ? this.treatDates.length : null;
            this.structData.indNumDays.init = indNumDays;
            this.structData.indNumDays.edit = indNumDays;
          }

          if (
            this.structData.indNumDays.edit &&
            this.structData.indNumDays.edit !== ""
          ) {
            // 指定されている回数により治療日をフィルタ
            this.treatDates = this.treatDates.splice(
              0,
              this.structData.indNumDays.edit
            );
          }
          // add FNSI-投与薬剤編集の修正 楊 start
        }
        // add FNSI-投与薬剤編集の修正 楊 end
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
              //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
              this.setTabooMedicine(false);
              //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
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

          //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
          case 70000028:
            // 反映処理を行う
            this.$refs.mediEdit.getComponentData(this.structData, answer);
            break;
          //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
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
      //   // Storeに開始日(初回投与日)を保存
      //   this.setIndStartDate(this.structData.indStartDate);
      // },
      /**
       * 治療日の調整
       */
      AdjustTreatStartDate(treatDate,startDate) {
      //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
        if(treatDate === ""){
          return;
        }
      //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
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
          // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy
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

      async getTreatDateList(isMaxDate = false, isNowStart = false) {
        const paramJson = {};
        // 施設情報
        paramJson.facility_cd = this.structData.facilityCd;
        // 患者情報
        paramJson.pat_id = this.structData.patId;
        // 治療開始日時
        paramJson.ind_start_date = isNowStart ? moment(new Date()).format("YYYY-MM-DD") : this.structData.indStartDate;
        /*
        if (isNowStart) {
          // 本日日付からのデータを取得
          paramJson.ind_start_date = moment(new Date()).format("YYYY-MM-DD");
        } else {
          paramJson.ind_start_date = this.structData.indStartDate;
        }
        */
        // 治療終了日時
        paramJson.ind_end_date =
          "" === this.structData.indEndDate || isMaxDate
            ? this.maxDate
            : this.structData.indEndDate;
        // 曜日パターン
        paramJson.week_pattern = JSON.stringify(this.structData.indWeeks);

        // 対象日時の治療情報取得
        const response = await ApiHelper.post(
          "/mainData/TreatDateList",
          paramJson
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndMedicineEditBase.vue', 'getTreatDateList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
        return response.data;
      },

      setTreatDateList(ordMainList) {
        this.treatDateList = [];
        this.selectedTndMediNo = this.settingData.fieldsData.seqNo;
        for (const ordMain of ordMainList) {
          if (ordMain.indMediInfo) {
            const indMediInfo = JSON.parse(ordMain.indMediInfo);
            const isSelectedTndMediNo = indMediInfo.find(
              indMedi => indMedi.no === this.selectedTndMediNo
            );
            if (isSelectedTndMediNo) {
              this.treatDateList.push(ordMain.treatDate);
            }
          }
        }
      },

      setTreatDateListFixedAll(ordMainList) {
        this.treatDateListFixedAll = [];
        this.selectedTndMediNo = this.settingData.fieldsData.seqNo;
        for (const ordMain of ordMainList) {
          if (ordMain.indMediInfo) {
            const indMediInfo = JSON.parse(ordMain.indMediInfo);
            const isSelectedTndMediNo = indMediInfo.find(
              indMedi => indMedi.no === this.selectedTndMediNo
            );
            if (isSelectedTndMediNo) {
              this.treatDateListFixedAll.push(ordMain.treatDate);
            }
          }
        }
      },

      /**
       * 項目編集中のフラグをオンにする
       */
      focusStartEditing() {
        this.startEditFlg = true;
      },

      // add FNSI-投与薬剤編集の修正 楊 start

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
          getErrorMessage('IndMedicineEditBase.vue', 'setDefaultTreatmentAndKur', error);
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
              getErrorMessage('IndMedicineEditBase.vue', 'setMonthLastTreatDate', error);
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
       * 投与間隔の表示
       */
      showIndDayInterval() {
        // 表示・非表示を切り替える
        this.showCurrentWeekPatternDetail = !this.showCurrentWeekPatternDetail;
        if (!this.showCurrentWeekPatternDetail) {
          // add #11311 編集箇所のみ保存の再精査 zkm start
          this.structData.editOnly = true;
        } else {
          this.structData.editOnly = false;
          // add #11311 編集箇所のみ保存の再精査 zkm end
        }
      },

      chkChange(week) {
        switch (this.structData.indDayIntervalSelected) {
          // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
          // case 0:
          // case 10:
          //   this.structData.indWeeks.forEach(item => {
          //     item.done = true;
          //     item.disabled = true;
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
        this.structData.indWeeks.forEach(item => {
          item.done = false;
        });

        switch (this.structData.indDayIntervalSelected) {
          // del #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
          // case 0:
          // case 10:
          //   this.structData.indWeeks.forEach(item => {
          //     item.done = true;
          //     item.disabled = true;
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

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      async resetComponentData() {
        if(this.isDialogType9) {
          this.$refs.mediEdit.resetComponentIndData(this.structData);
        }
      },
      //add #9311 v-model発効します 張博 start
      selectedKurChange(event){
        this.structData.selectedKur = event.sender._old
      },
      selectedTreatChange(event){
        this.structData.selectedTreat = event.sender._old
      },
      //add #9311 v-model発効します 張博 end
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

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
            getErrorMessage('IndMedicineEditBase.vue', 'createKurAndTreatmentList', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          });
      },

      /**
       * クールリスト作成
       * @param {object} リスト作成元データ[{},{}...]
       */
      createKurList(dataList) {
        // mod FNSI-性能を最適化する 李 start
        this.$nextTick(() => {
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
        });
        // setTimeout(() => {
        //   if (0 !== dataList.length) {
        //     // 選択中の治療方法に紐づくクールリストを作成
        //     let extractList = dataList;
        //     if (0 < this.structData.selectedTreat.length) {
        //       extractList = dataList.filter(item => {
        //         if (this.structData.selectedTreat.includes(item.indTreatmentCd)) {
        //           return true;
        //         }
        //       });
        //     }

        //     this.createList(extractList, "indKurCd", "indKurName", "kurOptions");
        //   }
        // }, 100);
        // mod FNSI-性能を最適化する 李 end
      },

      /**
       * 治療方法リスト作成
       * @param {object} リスト作成元データ[{},{}...]
       */
      createTreatmentList(dataList) {
        // mod FNSI-性能を最適化する 李 start
        this.$nextTick(() => {
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
        });
        // setTimeout(() => {
        //   if (0 !== dataList.length) {
        //     let extractList = dataList;
        //     // 選択中のクールに紐づく治療方法リストを作成
        //     if (0 < this.structData.selectedKur.length) {
        //       extractList = dataList.filter(item => {
        //         if (this.structData.selectedKur.includes(item.indKurCd)) {
        //           return true;
        //         }
        //       });
        //     }

        //     this.createList(
        //       extractList,
        //       "indTreatmentCd",
        //       "indTreatmentName",
        //       "treatOptions"
        //     );
        //   }
        // }, 100);
        // mod FNSI-性能を最適化する 李 end
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
       * 治療予定リスト取得
       */
      async getTreatDateListAll() {
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
          getErrorMessage('IndMedicineEditBase.vue', 'getTreatDateListAll', error);
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
          getErrorMessage('IndMedicineEditBase.vue', 'responseFixed', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
        this.treatDateListFixedAll = responseFixed.data.map(({ treatDate }) => treatDate);
      },
      // add FNSI-投与薬剤編集の修正 楊 end
      // mod FNSI-4882 劉全航 start
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
      // changeEditFlag:function(flag){
      //   this.editFlg = flag;
      // },
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
      // mod FNSI-4882 劉全航 end
      /**
       * すべての治療予定を取得
       */
      async getTreatDates() {
        const paramJson = {};
        // 施設情報
        paramJson.facility_cd = this.structData.facilityCd;
        // 患者情報
        paramJson.pat_id = this.structData.patId;
        // 治療開始日時
        paramJson.ind_start_date = "0001-01-01";
        // 治療終了日時
        paramJson.ind_end_date = "9999-12-31";
        // 曜日パターン
        paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";
        // 対象日時の治療情報取得
        const response = await ApiHelper.post(
          "/mainData/TreatDateList",
          paramJson
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndMedicineEditBase.vue', 'getTreatDates', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });

        this.treatDatesAll = response.data.map(({ treatDate }) => treatDate);
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      },
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
        //mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
      },
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
        if (this.edit == 1) {
          // 中止時はチェックを行わない
          this.setTabooMedicine(false);
          return;
        }
        const name = this.$refs.mediEdit?.medicineInputValue?.editValue;
        const tabooAllergyFlag = containsTabooAllergyTag(name);
        this.setTabooMedicine(tabooAllergyFlag);
      },
    }
  };
</script>

/** * スタイル定義 */
<style scoped>
  .slot-style {
    padding: 5px 10px;
  }

  .div-style {
    padding: 5px 10px;
  }

  .group-label {
    display: block; /* ブロックレベル要素化する */
    float: left; /* 要素の左寄せ・回り込を指定する */
    min-width: 4em; /* ボックスの横幅を指定する */
    height: 2em; /* ボックスの高さを指定する */
    padding-left: 5px; /* ボックス内左側の余白を指定する */
    padding-right: 5px; /* ボックス内御右側の余白を指定する */
    color: #ffffff; /* フォントの色を指定する */
    text-align: center; /* テキストのセンタリングを指定する */
    line-height: 2em; /* 行の高さを指定する */
    cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
    background-color: #72a8de;
    border-bottom: solid 3px #72a8de;
  }

  .first-of-type {
    border-radius: 10px 0 0 10px;
  }

  .last-of-type {
    border-radius: 0 10px 10px 0;
  }

  /* add FNSI-投与薬剤編集の修正 楊 start */
  /* .onColor:checked + span {*/
  /* add FNSI-投与薬剤編集の修正 楊 end */
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
  .date-input[disabled]{
    width: calc(100% - 32px);
    padding-right: 2px !important;
    color: #999;
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
  /* add #5589 2023/03/29 数値IFのスタイル全不正 林峻峰 start */
  .label-padding-top5{
    padding-top: 5px;
  }
  /* add #5589 2023/03/29 数値IFのスタイル全不正 林峻峰 end */
  /* add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start */
  .date-start-input {
    background-color: #ffff99 !important;
  }
  .date-first-input input{
    background-color: #ffff99 !important;
  }
  /* add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end */
</style>
