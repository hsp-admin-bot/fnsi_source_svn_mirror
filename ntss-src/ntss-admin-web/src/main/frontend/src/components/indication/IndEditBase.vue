/** * 指示ベース画面 */

<template>
  <div>
    <modal-base @onClose="hideModal" class="custom-modal">
            <template #body>
<div ref="modalBodyRoot" class="indInfo-style-modal-container scroll-style">
        <div
          v-if="settingData.showSegment"
          class="div-style"
          style="float: left;"
        >
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <input -->
          <!--   type="radio" -->
          <!--   style="display: none;" -->
          <!--   class="identification" -->
          <!--   name="indEditBaseForCreate" -->
          <!--   value="0" -->
          <!--   id="ind-edit-base-normal" -->
          <!--   :disabled="!(cycleWeek === '0') && isSetedCycleWeek" -->
          <!--   :checked="cycleWeek === '0'" -->
          <!--   @click="changeDialSegment($event.target.value)" -->
          <!-- /> -->
          <input
            type="radio"
            style="display: none;"
            class="identification"
            name="indEditBaseForCreate"
            value="0"
            id="ind-edit-base-normal"
            :disabled="(!(cycleWeek === '0') && isSetedCycleWeek) || !getItemAuthorized()"
            :checked="cycleWeek === '0'"
            @click="changeDialSegment($event.target.value)"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <label for="ind-edit-base-normal" class="group-label first-of-type">{{ settingData.segmentLabel1 }}</label>
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <input -->
          <!--   type="radio" -->
          <!--   style="display: none;" -->
          <!--   class="identification" -->
          <!--   name="indEditBaseForCreate" -->
          <!--   value="1" -->
          <!--   id="ind-edit-base-eoday" -->
          <!--   :disabled="!(cycleWeek === '1') && isSetedCycleWeek" -->
          <!--   :checked="cycleWeek === '1'" -->
          <!--   @click="changeDialSegment($event.target.value)" -->
          <!-- /> -->
          <input
            type="radio"
            style="display: none;"
            class="identification"
            name="indEditBaseForCreate"
            value="1"
            id="ind-edit-base-eoday"
            :disabled="(!(cycleWeek === '1') && isSetedCycleWeek) || !getItemAuthorized()"
            :checked="cycleWeek === '1'"
            @click="changeDialSegment($event.target.value)"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <label for="ind-edit-base-eoday" class="group-label middle-of-type">{{ settingData.segmentLabel2 }}</label>
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <input -->
          <!--   type="radio" -->
          <!--   style="display: none;" -->
          <!--   class="identification" -->
          <!--   name="indEditBaseForCreate" -->
          <!--   value="2" -->
          <!--   id="ind-edit-base-eoweek" -->
          <!--   :disabled="!(cycleWeek === '2') && isSetedCycleWeek" -->
          <!--   :checked="cycleWeek === '2'" -->
          <!--   @click="changeDialSegment($event.target.value)" -->
          <!-- /> -->
          <input
            type="radio"
            style="display: none;"
            class="identification"
            name="indEditBaseForCreate"
            value="2"
            id="ind-edit-base-eoweek"
            :disabled="(!(cycleWeek === '2') && isSetedCycleWeek) || !getItemAuthorized()"
            :checked="cycleWeek === '2'"
            @click="changeDialSegment($event.target.value)"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <label for="ind-edit-base-eoweek" class="group-label last-of-type">{{ settingData.segmentLabel5 }}</label>
        </div>
        <div
          v-if="settingData.showNewEdit"
          class="div-style"
          style="float: left;"
        >
          <input
            type="radio"
            style="display: none;"
            class="identification"
            name="indEditBaseNewEdit"
            value="0"
            id="ind-editBase-newEdit-v0"
            @click="changeSegment($event);"
            :checked="edit === 0"
          />
          <label for="ind-editBase-newEdit-v0" class="group-label first-of-type">{{ settingData.segmentLabel3 }}</label>
          <input
            type="radio"
            style="display: none;"
            class="identification"
            name="indEditBaseNewEdit"
            value="1"
            id="ind-editBase-newEdit-v1"
            @click="changeSegment($event);"
            :checked="edit === 1"
          />
          <label for="ind-editBase-newEdit-v1" class="group-label last-of-type">{{ settingData.segmentLabel4 }}</label>
        </div>
        <div class="IndBaseHeader">
          <div>
            <v-ons-row class="div-style" style="clear: left;">
              <v-ons-col class="indInfo-style-label-position">
                <label>開始日</label>
              </v-ons-col>
              <v-ons-col>
                <!-- mod FNSI-横展開-inputの色 関 start -->
                <!-- <input
                  v-model="structData.indStartDate"
                  type="date"
                  class="date-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indStartDate"
                  :disabled="settingData.startDateEdit"
                  @change="createKurAndTreatmentList"
                /> -->
                <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start -->
                <!--<input
                  v-model="structData.indStartDate"
                  type="date"
                  id="date-start"
                  class="date-start-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indStartDate"
                  :disabled="settingData.startDateEdit"
                  @change="createKurAndTreatmentList"
                  max="9999-12-31"
                  @blur="delFocusCss($event)"
                  @focus="addFocusCss($event)"
                  :class="classObject"
                />-->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒、v-if追加 xugj add start-->
                <!--mod 8560 開始日の日付のキーボード入力が不正 張 start-->
                <!-- <input v-if="!isIOS"
                  v-model="structData.indStartDate"
                  type="date"
                  id="date-start"
                  class="date-start-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indStartDate"
                  :disabled="settingData.startDateEdit"
                  @change="createKurAndTreatmentList();resetComponentData()"
                  max="9999-12-31"
                  @blur="delFocusCss($event)"
                  @focus="addFocusCss($event)"
                  :class="classObject"
                /> -->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  start -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input v-if="!isIOS" -->
                <!--   v-model="structData.indStartDate" -->
                <!--   type="date" -->
                <!--   id="date-start" -->
                <!--   class="date-start-input common-style-input ntss-input-date ntss-custom-input" -->
                <!--   data-target="indStartDate" -->
                <!--   :disabled="settingData.startDateEdit" -->
                <!--   @change="createKurAndTreatmentList(structData.indStartDate)" -->
                <!--   max="9999-12-31" -->
                <!--   @blur="AdjustTreatStartDate(structData.indStartDate,true);delFocusCss($event);resetComponentData()" -->
                <!--   @focus="addFocusCss($event)" -->
                <!--   :class="classObject" -->
                <!-- /> -->
                <date-input v-if="!isIOS"
                  v-model="structData.indStartDate"
                  id="date-start"
                  class="date-start-input common-style-input ntss-input-date ntss-custom-input"
                  classes="date-input-required"
                  data-target="indStartDate"
                  :disabled="settingData.startDateEdit || !getItemAuthorized()"
                  @focus="beforeDate = structData.indStartDate"
                  max="9999-12-31"
                  @blur="onBlurDate(structData.indStartDate, 'indStartDate');"
                  isRequired
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  end -->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒、v-if追加 xugj add end-->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add start-->
                <!-- <input v-if="isIOS"
                  v-model="structData.indStartDate"
                  type="text"
                  id="date-start"
                  disabled = "disabled"
                  class="date-start-input-ios common-style-input ntss-input-date ntss-custom-input"
                  data-target="indStartDate"
                  @change="createKurAndTreatmentList"
                  max="9999-12-31"
                  @blur="delFocusCss($event)"
                  @focus="addFocusCss($event)"
                  :class="classObject"
                /> -->
                <!-- modify by chamaojia 2023-05-04 [8560] イベントは一貫性を保つ  start -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input v-if="isIOS" -->
                <!--   v-model="structData.indStartDate" -->
                <!--   type="text" -->
                <!--   id="date-start" -->
                <!--   :disabled="settingData.startDateEdit" -->
                <!--   class="date-start-input-ios common-style-input ntss-input-date ntss-custom-input" -->
                <!--   data-target="indStartDate" -->
                <!--   @change="createKurAndTreatmentList" -->
                <!--   max="9999-12-31" -->
                <!--   @blur="AdjustTreatStartDate(structData.indStartDate,true);delFocusCss($event);resetComponentData()" -->
                <!--   @focus="addFocusCss($event)" -->
                <!--   :class="classObject" -->
                <!-- /> -->
                <input v-if="isIOS"
                  v-model="structData.indStartDate"
                  type="text"
                  id="date-start"
                  :disabled="settingData.startDateEdit || !getItemAuthorized()"
                  class="date-start-input-ios common-style-input ntss-input-date ntss-custom-input"
                  data-target="indStartDate"
                  @focus="beforeDate = structData.indStartDate"
                  max="9999-12-31"
                  @blur="onBlurDate(structData.indStartDate, 'indStartDate');"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- modify by chamaojia 2023-05-04 [8560] イベントは一貫性を保つ  end -->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add end-->
                <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end -->
                 <!-- mod FNSI-横展開-inputの色 関 end -->
                 <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start -->
                <!--<custom-calendar
                  v-model="structData.indStartDate"
                  :disabled-weekdays="disabledWeekdays"
                  :is-disabled-past-dates="true"
                  :disabled="settingData.startDateEdit"
                  :disable-dates-after="disableDatesAfter"
                  @input="createKurAndTreatmentList"
                />-->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  start -->
                <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
                <!-- <custom-calendar
                  v-model="structData.indStartDate"
                  :disabled-weekdays="disabledWeekdays"
                  :is-disabled-past-dates="true"
                  :disabled="settingData.startDateEdit"
                  :disable-dates-after="disableDatesAfter"
                  @input="createKurAndTreatmentList()"
                  @blur="resetComponentData()"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <custom-calendar -->
                <!--   v-model="structData.indStartDate" -->
                <!--   :disabled-weekdays="disabledWeekdays" -->
                <!--   :disabled="settingData.startDateEdit" -->
                <!--   :disable-dates-after="disableDatesAfter" -->
                <!--   @input="createKurAndTreatmentList()" -->
                <!--   @blur="resetComponentData()" -->
                <!-- /> -->
                <!-- add 9664補液及び透析液仕様修正します yangqingzhe start -->
                <!-- <custom-calendar
                  v-model="structData.indStartDate"
                  :disabled-weekdays="disabledWeekdays"
                  :disabled="settingData.startDateEdit || !getItemAuthorized()"
                  :disable-dates-after="disableDatesAfter"
                  @input="createKurAndTreatmentList()"
                  @blur="resetComponentData()"
                /> -->
                <custom-calendar
                  v-model="calendarIndStartDate"
                  :disabled-weekdays="disabledWeekdays"
                  :disabled="settingData.startDateEdit || !getItemAuthorized()"
                  :disable-dates-after="disableDatesAfter"
                  :to-month="toMonth"
                  @input="onCalendarIndStartDateInput"
                />
                <!-- add 9664補液及び透析液仕様修正します yangqingzhe end -->
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  end -->
                <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end -->
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="div-style" style="">
              <v-ons-col class="indInfo-style-label-position">
                <label>終了日</label>
              </v-ons-col>
              <v-ons-col>
                <!-- mod FNSI-横展開-inputの色 関 start -->
                <!-- <input
                  v-model="structData.indEndDate"
                  type="date"
                  class="date-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :disabled="settingData.endDateEdit"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @change="createKurAndTreatmentList"
                /> -->
                <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
                <!-- <input
                  v-model="structData.indEndDate"
                  type="date"
                  class="date-end-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :disabled="settingData.endDateEdit"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @change="createKurAndTreatmentList"
                /> -->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒、v-if追加 xugj add start-->
                 <!-- <input v-if="!isIOS"
                  v-model="structData.indEndDate"
                  type="date"
                  id="date-end"
                  class="date-end-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :disabled="settingData.endDateEdit"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @change="createKurAndTreatmentList();resetComponentData()"
                  @blur="delFocusCss($event)"
                  @focus="addFocusCss($event)"
                /> -->
                <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                 <!-- <input v-if="!isIOS"
                  v-model="structData.indEndDate"
                  type="date"
                  id="date-end"
                  class="date-end-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :disabled="settingData.endDateEdit"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @blur="AdjustTreatStartDate(structData.indEndDate,false);delFocusCss($event)"
                /> -->
                <!-- #10266 終了日、何も変更せずに、再び焦点が合わなくなります。structData.indEndDate undefined linjunfeng start -->
                <!-- <date-input v-if="!isIOS"
                  v-model="structData.indEndDate"
                  @handleClearInput="structData.indEndDate = ''"
                  id="date-end"
                  class="date-end-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :disabled="settingData.endDateEdit"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @blur="AdjustTreatStartDate(structData.indEndDate,false);delFocusCss($event)"
                /> -->
                <!-- <date-input v-if="!isIOS" -->
                <!--   enabledBlank -->
                <!--   v-model="structData.indEndDate" -->
                <!--   @handleClearInput="structData.indEndDate = '';" -->
                <!--   id="date-end" -->
                <!--   class="date-end-input common-style-input ntss-input-date ntss-custom-input" -->
                <!--   data-target="indEndDate" -->
                <!--   :disabled="settingData.endDateEdit" -->
                <!--   :min="structData.indStartDate" -->
                <!--   :max="maxDate" -->
                <!--   @blur="AdjustTreatStartDate(structData.indEndDate,false);delFocusCss($event)" -->
                <!-- /> -->
                <date-input v-if="!isIOS"
                  enabledBlank
                  v-model="structData.indEndDate"
                  @handleClearInput="structData.indEndDate = '';"
                  id="date-end"
                  class="date-end-input common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :disabled="settingData.endDateEdit || !getItemAuthorized()"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @focus="beforeDate = structData.indEndDate"
                  @blur="onBlurDate(structData.indEndDate, 'indEndDate');"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10266 終了日、何も変更せずに、再び焦点が合わなくなります。structData.indEndDate undefined linjunfeng end -->
                <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒、v-if追加 xugj add end-->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add start-->
                <!--8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start-->
                <!--<input v-if="isIOS"
                  v-model="structData.indEndDate"
                  type="text"
                  id="date-end"
                  disabled = "disabled"
                  class="date-end-input-ios common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @change="createKurAndTreatmentList"
                  @blur="delFocusCss($event)"
                  @focus="addFocusCss($event)"
                />-->
                  <!-- <input v-if="isIOS"
                  v-model="structData.indEndDate"
                  type="text"
                  id="date-end"
                  disabled = "disabled"
                  class="date-end-input-ios common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  @change="createKurAndTreatmentList();resetComponentData()"
                  @blur="delFocusCss($event)"
                  @focus="addFocusCss($event)"
                /> -->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  start -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <input v-if="isIOS" -->
                <!--  v-model="structData.indEndDate" -->
                <!--  type="text" -->
                <!--  id="date-end" -->
                <!--  :disabled="settingData.startDateEdit" -->
                <!--  class="date-end-input-ios common-style-input ntss-input-date ntss-custom-input" -->
                <!--  data-target="indEndDate" -->
                <!--  :min="structData.indStartDate" -->
                <!--  :max="maxDate" -->
                <!--  @change="createKurAndTreatmentList()" -->
                <!--  @blur="AdjustTreatStartDate(structData.indEndDate,false);delFocusCss($event);resetComponentData()" -->
                <!--  @focus="addFocusCss($event)" -->
                <!-- /> -->
                <input v-if="isIOS"
                  v-model="structData.indEndDate"
                  type="text"
                  id="date-end"
                  :disabled="settingData.startDateEdit || !getItemAuthorized()"
                  class="date-end-input-ios common-style-input ntss-input-date ntss-custom-input"
                  data-target="indEndDate"
                  :min="structData.indStartDate"
                  :max="maxDate"
                  max="9999-12-31"
                  @focus="beforeDate = structData.indEndDate"
                  @blur="onBlurDate(structData.indEndDate, 'indEndDate');"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  end -->
                <!--8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end-->
                <!--//FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add end-->
                <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
                <!-- mod FNSI-横展開-inputの色 関 end -->
                <!--8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start-->
                <!--<custom-calendar
                  v-model="structData.indEndDate"
                  :disabled="settingData.endDateEdit"
                  :is-disabled-past-dates="true"
                  :disable-dates-before="disableDatesBefore"
                  :disable-dates-after="disableDatesAfter"
                  :to-month="toMonth"
                  @input="createKurAndTreatmentList"
                />-->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  start -->
                <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start -->
                <!-- <custom-calendar
                 v-model="structData.indEndDate"
                 :disabled="settingData.endDateEdit"
                 :is-disabled-past-dates="true"
                 :disable-dates-before="disableDatesBefore"
                 :disable-dates-after="disableDatesAfter"
                 :to-month="toMonth"
                 @input="onIndDateChange"
                 @blur="delFocusCss($event)"
               /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <custom-calendar -->
                <!--   v-model="structData.indEndDate" -->
                <!--   :disabled="settingData.endDateEdit" -->
                <!--   :disable-dates-before="disableDatesBefore" -->
                <!--   :disable-dates-after="disableDatesAfter" -->
                <!--   :to-month="toMonth" -->
                <!--   @input="createKurAndTreatmentList()" -->
                <!--   @blur="resetComponentData()" -->
                <!-- /> -->
                <custom-calendar
                  v-model="calendarIndEndDate"
                  :disabled="settingData.endDateEdit || !getItemAuthorized()"
                  :disable-dates-before="disableDatesBefore"
                  :disable-dates-after="disableDatesAfter"
                  :to-month="toMonth"
                  @input="onCalendarIndEndDateInput"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end -->
                <!-- modify by chamaojia 2023-05-04 [8560] resetComponentDataの呼び出しが焦点のないイベントに移行  end -->
                 <!--8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end-->
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
                  <!--   class="onColor" -->
                  <!--   type="checkbox" -->
                  <!--   :checked="week.done" -->
                  <!--   style="display: none;" -->
                  <!--   :disabled="weekEdit" -->
                  <!--   :id="'indEditWeekCheck-' + index" -->
                  <!--   @change="chkChange(week)" -->
                  <!-- /> -->
                  <input
                    class="onColor"
                    type="checkbox"
                    :checked="week.done"
                    style="display: none;"
                    :disabled="weekEdit || !getItemAuthorized()"
                    :id="'indEditWeekCheck-' + index"
                    @change="chkChange(week)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <label :for="'indEditWeekCheck-' + index" onclick="null" style="cursor:pointer;" class="indInfo-style-week-button">{{ week.text }}</label>
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
                  <!--   class="onColor" -->
                  <!--   type="checkbox" -->
                  <!--   :checked="week.done" -->
                  <!--   style="display: none;" -->
                  <!--   :disabled="weekEdit" -->
                  <!--   :id="'indEditKakujituWeekCheck-' + index" -->
                  <!--   @change="chkKakujituChange(week)" -->
                  <!-- /> -->
                  <input
                    class="onColor"
                    type="checkbox"
                    :checked="week.done"
                    style="display: none;"
                    :disabled="weekEdit || !getItemAuthorized()"
                    :id="'indEditKakujituWeekCheck-' + index"
                    @change="chkKakujituChange(week)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <label :for="'indEditKakujituWeekCheck-' + index" onclick="null" style="cursor:pointer;" class="indInfo-style-week-button">{{ week.text }}</label>
                </div>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row
              v-if="settingData.showWeeks && structData.cycleWeek == '2'"
              class="div-style"
            >
              <v-ons-col class="indInfo-style-label-position">
                <label>曜日</label>
              </v-ons-col>
              <v-ons-col>
                <div v-for="(week, index) in structData.indWeeks" :key="index">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <input -->
                  <!--   class="onColor" -->
                  <!--   type="checkbox" -->
                  <!--   :checked="week.done" -->
                  <!--   style="display: none;" -->
                  <!--   :disabled="weekEdit" -->
                  <!--   :id="'indEditKakusyuuWeekCheck-' + index" -->
                  <!--   @change="chkChange(week)" -->
                  <!-- /> -->
                  <input
                    class="onColor"
                    type="checkbox"
                    :checked="week.done"
                    style="display: none;"
                    :disabled="weekEdit || !getItemAuthorized()"
                    :id="'indEditKakusyuuWeekCheck-' + index"
                    @change="chkChange(week)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <label :for="'indEditKakusyuuWeekCheck-' + index" onclick="null" style="cursor:pointer;" class="indInfo-style-week-button">{{ week.text }}</label>
                </div>
              </v-ons-col>
            </v-ons-row>

            <v-ons-row v-if="settingData.showTreat" class="div-style">
              <v-ons-col class="indInfo-style-label-position">
                <label>変更対象治療方法</label>
              </v-ons-col>
              <v-ons-col>
                <!--mod FNSI-【1006】最新の改修対象一覧の483対応 韓 start-->
                <!--<kendo-multiselect
                  v-model="structData.selectedTreat"
                  :data-source="structData.treatOptions"
                  :data-text-field="treatText"
                  :data-value-field="treatValue"
                  :max-selected-items="treatMaxSelectedItems"
                  :disabled="treatAndKurEdit"
                  placeholder="すべて"
                  @change="createKurList(dataList);"
                />-->
                <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start -->
                <!--<kendo-multiselect
                  v-model="structData.selectedTreat"
                  :data-source="structData.treatOptions"
                  :data-text-field="treatText"
                  :data-value-field="treatValue"
                  :max-selected-items="treatMaxSelectedItems"
                  :disabled="treatAndKurEdit"
                  placeholder="すべて"
                  @change="createKurList(dataList);
                  showOhdfComment();"
                />-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <kendo-multiselect -->
                <!--   v-model="structData.selectedTreat" -->
                <!--   :data-source="structData.treatOptions" -->
                <!--   :data-text-field="treatText" -->
                <!--   :data-value-field="treatValue" -->
                <!--   :max-selected-items="treatMaxSelectedItems" -->
                <!--   :disabled="treatAndKurEdit" -->
                <!--   placeholder="すべて" -->
                <!--   @change="syncValToSelectedTreat($event);createKurList(dataList); -->
                <!--   showOhdfComment();resetComponentData()" -->
                <!-- /> -->
                <kendo-multiselect
                  v-model="structData.selectedTreat"
                  :data-source="structData.treatOptions"
                  :data-text-field="treatText"
                  :data-value-field="treatValue"
                  :max-selected-items="treatMaxSelectedItems"
                  :disabled="treatAndKurEdit || !getItemAuthorized()"
                  placeholder="すべて"
                  @change="syncValToSelectedTreat($event);createKurList(dataList);
                  showOhdfComment();resetComponentData()"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end -->
                <!--mod FNSI-【1006】最新の改修対象一覧の483対応 韓 end-->
              </v-ons-col>
            </v-ons-row>

            <v-ons-row v-if="settingData.showKur" class="div-style">
              <v-ons-col class="indInfo-style-label-position">
                <label>変更対象クール</label>
              </v-ons-col>
              <v-ons-col>
                <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start -->
                <!-- <kendo-multiselect
                  v-model="structData.selectedKur"
                  :data-source="structData.kurOptions"
                  :data-text-field="kurText"
                  :data-value-field="kurValue"
                  :max-selected-items="kurMaxSelectedItems"
                  :disabled="treatAndKurEdit"
                  placeholder="すべて"
                  @change="createTreatmentList(dataList)"
                />-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <kendo-multiselect -->
                <!--   v-model="structData.selectedKur" -->
                <!--   :data-source="structData.kurOptions" -->
                <!--   :data-text-field="kurText" -->
                <!--   :data-value-field="kurValue" -->
                <!--   :max-selected-items="kurMaxSelectedItems" -->
                <!--   :disabled="treatAndKurEdit" -->
                <!--   placeholder="すべて" -->
                <!--   @change="syncValToSelectedKur($event);createTreatmentList(dataList);resetComponentData()" -->
                <!-- /> -->
                <kendo-multiselect
                  v-model="structData.selectedKur"
                  :data-source="structData.kurOptions"
                  :data-text-field="kurText"
                  :data-value-field="kurValue"
                  :max-selected-items="kurMaxSelectedItems"
                  :disabled="treatAndKurEdit || !getItemAuthorized()"
                  placeholder="すべて"
                  @change="syncValToSelectedKur($event);createTreatmentList(dataList);resetComponentData()"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end -->
              </v-ons-col>
            </v-ons-row>
          </div>
        </div>
        <hr v-if="settingData.hrOnder" class="hr-style" />
        <!-- mod FNSI-【4650】【4646】 fan start -->
        <!--    <div class="slot-style" style="white-space: pre-line;"><slot></slot></div>-->
        <div ref="defaultSlotHost" class="slot-style" style="white-space: pre-line;padding-bottom: 0;"><slot></slot></div>
        <!-- mod FNSI-【4650】【4646】 fan end -->
        <hr v-if="settingData.hrUnder" class="hr-style" />

        <div v-if="messageDialogInfo.isDialogVisible">
          <!--mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start -->
          <!--<message-dialog
            v-model:visible="messageDialogInfo.isDialogVisible"
            :message-cd="messageDialogInfo.messageCd"
            :type="messageDialogInfo.type"
            :string-params="messageDialogInfo.stringParams"
            @confirm="confirmResult"
          />-->
          <message-dialog
            v-model:visible="messageDialogInfo.isDialogVisible"
            :message-cd="messageDialogInfo.messageCd"
            :type="messageDialogInfo.type"
            :string-params="messageDialogInfo.stringParams"
            :title="messageDialogInfo.title"
            @confirm="confirmResult"
          />
          <!--mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end -->
        </div>
      </div>
      </template>

            <template #footer>
<div class="in-ind-dropdown-area">
        <v-ons-row v-show="editIndUser" class="div-style">
          <v-ons-col
            style="text-align: end; padding-right: 10px; margin: auto;"
          >
            <label>指示者</label>
          </v-ons-col>
          <v-ons-col width="170px">
            <!-- mod 画面デザイン改善対応 李 start -->
            <!-- <kendo-dropdownlist
              id="kendo-dropdownlist-select-id"
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
              :disabled="!getItemAuthorized()"
              @open="onIndUserDropdownOpen"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!-- mod 画面デザイン改善対応 李 end -->
          </v-ons-col>
        </v-ons-row>

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
            <v-ons-col v-show="isShowEditOnlyFlag" style="text-align:right;">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-checkbox input-id="editOnly" v-model="structData.editOnly"/> -->
              <v-ons-checkbox input-id="editOnly" v-model="structData.editOnly" :disabled="!getItemAuthorized()"/>
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <label for="editOnly" class="popoverFilterLabel">編集箇所のみ</label>
            </v-ons-col>
            <div v-if="settingData.showDelete">
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
              <!--   style="margin-left: 1.5em;" -->
              <!--   :disabled="updateDisable" -->
              <!--   @click="updateIndInfo(3)" -->
              <!-- > -->
              <v-ons-button
                class="btn4-alert width-padding"
                style="margin-left: 1.5em;"
                :disabled="updateDisable || !getItemAuthorized()"
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
                class="common-style-ok-button"
                style="float: right;"
                :disabled="updateDisable"
                @click="updateIndInfo(1)"
              >
                保存
              </v-ons-button> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-button -->
              <!--   class="btn1-execute width-padding" -->
              <!--   style="margin-left: 1.5em;" -->
              <!--   :disabled="updateDisable || (structData.editOnly && !editFlg)" -->
              <!--   @click="updateIndInfo(1)" -->
              <!-- > -->
              <!-- mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start-->
              <!-- add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 -->
              <!-- スケジュール編集(ind-sch-edit): 保存は OrdMoveCheck 経由（新API）のみ。下記汎用保存と二重表示しない。 -->
              <v-ons-button
                v-if="componentId === 'ind-sch-edit'"
                class="btn1-execute width-padding"
                style="margin-left: 1.5em;"
                :disabled="updateDisable || (structData.editOnly && !editFlg) || !getItemAuthorized()"
                @click="updateIndInfo(1, '', { useOrdMoveCheckApi: true })"
              >
                保存
              </v-ons-button>
              <!-- add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end -->
              <!-- 定作成新規作成-->
              <v-ons-button
                class="btn1-execute width-padding"
                style="margin-left: 1.5em;"
                v-if="'予定作成' === settingData.headerTitle"
                :disabled="updateDisable  || !getItemAuthorized()"
                @click="updateIndInfo(1, 'create')"
              >
                保存
              </v-ons-button>
              <!-- v-if="!condModalTitle.includes(this.settingData.headerTitle) || '0' !== settingData.orderMainData.rstDialysisState"-->
              <v-ons-button
                class="btn1-execute width-padding"
                style="margin-left: 1.5em;"
                v-if="'予定作成' != settingData.headerTitle && '医療材料編集' != settingData.headerTitle && componentId !== 'ind-sch-edit'"
                :disabled="updateDisable || !editFlg || !getItemAuthorized()"
                @click="updateIndInfo(1)"
              >
                保存
              </v-ons-button>
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
              <!-- mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end-->
              <!-- add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start-->
              <v-ons-button
                class="btn1-execute width-padding"
                style="margin-left: 1.5em;"
                v-if="'医療材料編集' === settingData.headerTitle"
                :disabled="updateDisable  || !getItemAuthorized()"
                @click="updateIndInfo(1, 'equip-create')"
              >
                保存
              </v-ons-button>
              <!-- add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end-->
            </div>
            <div v-else>
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
                <!-- mod FNSI-6512 劉全航 start -->
                <!-- <v-ons-button
                  class="btn1-execute width-padding"
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
                <v-ons-button
                  class="btn1-execute width-padding"
                  style="margin-left: 1.5em;"
                  v-if="'医療材料編集' != settingData.headerTitle"
                  :disabled="updateDisable || !editFlg || !getItemAuthorized()"
                  @click="updateIndInfo(2)"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  保存
                </v-ons-button>
                <!-- mod FNSI-6512 劉全航 end -->
                <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
                <!-- add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start-->
                <v-ons-button
                  class="btn1-execute width-padding"
                  style="margin-left: 1.5em;"
                  v-if="'医療材料編集' === settingData.headerTitle"
                  :disabled="updateDisable  || !getItemAuthorized()"
                  @click="updateIndInfo(2, 'equip-update')"
                >
                  保存
                </v-ons-button>
                <!-- add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end-->
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
                <!--   style="margin-left: 1.5em;" -->
                <!--   :disabled="updateDisable" -->
                <!--   @click="updateIndInfo(3)" -->
                <!-- > -->
                <v-ons-button
                  class="btn4-alert width-padding"
                  style="margin-left: 1.5em;"
                  v-if="'医療材料編集' != settingData.headerTitle"
                  :disabled="updateDisable || !getItemAuthorized()"
                  @click="updateIndInfo(3)"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  中止
                </v-ons-button>
                <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
                <!-- add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start-->
                <v-ons-button
                  class="btn4-alert width-padding"
                  style="margin-left: 1.5em;"
                  v-if="'医療材料編集' === settingData.headerTitle"
                  :disabled="updateDisable || !getItemAuthorized()"
                  @click="updateIndInfo(3, 'equip-del')"
                >
                  中止
                </v-ons-button>
                <!-- add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end-->
              </div>
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
      </template>
    </modal-base>
  </div>
</template>

<script>
import { setKendoDropDownListEditedState } from "@/functions/common/KendoFunctions";
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, containsTabooAllergyTag } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { deduplicateObjects } from "@/functions/common/CommonFunctions";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { deepCopy } from "@/functions/common/CommonFunctions";
import dayjs from "@/compat/date/dayjs";
import ModalBase from "@/components/modals/ModalBase";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";

// mod FNSI-濃度プログラムチェックの追加 楊 start
import { EventBus } from "@/compat/vue/event-bus.js";
// mod FNSI-濃度プログラムチェックの追加 楊 end

//add FNSI-No.IES145 権限対応  吉 start
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//add FNSI-No.IES145 権限対応  吉 end
// add 画面デザイン改善対応 李 start

// add 画面デザイン改善対応 李 end
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end
import MODAL_TITLE from "@/components/common/ModalTitleContrast.js";
import { getScopedElementById, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";
import { resolveDefaultSlotComponent } from "@/compat/vue/slots";
import $ from "@/compat/jquery";

export default {
  components: {
    "custom-calendar": CustomCalendar,
    "message-dialog": messageDialog,
    ModalBase,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  //mod FNSI-No.IES145 権限対応  吉 start
  // mixins: [IndUserSelectMixin],
  mixins: [IndUserSelectMixin,ComponentGuardMixin],
  //mod FNSI-No.IES145 権限対応  吉 end
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
        segmentLabel5: {
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
        },
        disIndUserEdit: {
          default: false,
          type: Boolean
        }
      })
    },
    /**
     * モーダル表示フラグ
     */
    modalVisible: {
      type: Boolean,
      default: false
    },
    /**
     * コンポーネントID
     */
    componentId: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      // editFlg: false,
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      editSelectIdFlg: false,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
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
        isDeadline: true,
        // 治療種別を表示フラグ(予定作成で使用)
        isShowTreatType: this.settingData.showSegment,
        // 警告受け入れフラグ(予定作成で使用)
        acceptWarnFlag: false,
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
        // オーダー番号
        ordNo: this.settingData.ordNo,
        // 実績：治療状況
        rstDialysisState: this.settingData.rstDialysisState,
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
      },
      dataList: [],
      edit: 0,
      disabledWeekdays: [],
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: "1",
        stringParams: [""]
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
       * 親コンポーネント変更イベント発火フラグ
       * @summary false設定時は、子コンポーネント
       * 子コンポーネントで有効/無効を設定する
       */
      isWatchParent: false,

      /**
       * クールマルチ選択最大選択数
       * @summary null設定時は、制限なし
       */
      kurMaxSelectedItems: null,

      /**
       * 治療方法&クール選択不可
       */
      // mod FNSI-治療方法&クール選択不可の修正 楊 start
      // treatAndKurEdit: false,
      treatAndKurEdit: true,
      // mod FNSI-治療方法&クール選択不可の修正 楊 end
      /**
       * モーダルスタイル
       */
      styleObj: { "max-width": "370px", width: "370px" },
      /**
       * ボタン
       */
      updateDisable: false,
      /**
       * 保存中フラグ
       */
      isUpdating: false,
      /**
       * strunctDataの複製
       */
      baseData: null,
      // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
      /**
       * 子コンポーネント呼び出し時の API 選択（new/旧保存）を保持する。
       * 確認ダイアログ(例:12010002)経由で再実行されても同じ API を呼べるようにする。
       */
      lastUseOrdMoveCheckApi: false,
      // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end
      /**
       * 指示者選択フラグ
       */
      editIndUser: this.settingData.disIndUserEdit ? false : true,
      // 治療種別設定フラグ
      isSetedCycleWeek: false,
      // 治療予定リスト(同日治療予定含む)
      treatDateListAll: [],
      //add FNSI-No.IES145 権限対応  吉 start
      authorityCds:[],
      flagAuthority:false,
      //add FNSI-No.IES145 権限対応  吉 end
      // add 画面デザイン改善対応 李 start
      firValue: null,
      // add 画面デザイン改善対応 李 end
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
      isIndActionChart: false,
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
      itemMsgCd14Flg: false,
      itemMsgCd18Flg: false,
      itemMsgCd20Flg: false,
      itemMsgCd24Flg: false,
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
      isDialogType9: false,
      // del #10150 piao Start
      // //  redmine 4633 姜  start
      // treatmentSetDayDisplayFlg : true,
      // //  redmine 4633 姜  end
      // del #10150 piao end
      //FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add start
      isIOS: false,
      //FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add end
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add start
      isDialogType9_offWater: false,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add end
      isDialogType9_ihdf: false,
      //FNSI-修正 #5525 横展開対応、xugj add start
      isSendNextPatInfoFlg: false,
      //FNSI-修正 #5525 横展開対応、xugj add end
      //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add start
      isTreatTimeSettingFlg: false,
      //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add end
      setIntervalObj: null,
      // add 8204 周安寧 start
      treatmentConditionSettingSource: [],
      // add 8204 周安寧 end
      // カレンダーインタフェースをクリックして複数回呼び出す start
      count: 0,
      // カレンダーインタフェースをクリックして複数回呼び出す end
      // #風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。start
      newEditFlag: false,
      // #風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。end
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initStructData: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc start
      ihdfChangeFlag: false,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc end
      // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
      doGetBedList: false,
      // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
      /**
       * 治療条件リセット検知用フラグ
       */
      isIndActionChartReset: false,
      // 変更前の開始日・終了日
      beforeDate: "",
      // custom-calendar用 開始日・終了日がカレンダーから選択されたかを判別可能とする
      calendarIndStartDate: this.settingData.startDate || "",
      calendarIndEndDate: this.settingData.endDate || ""
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-info", ["selectedPat"]),
    // modify 10196 by kangjie 20240228 start ordMain No.40 Change to delete treatment, including Change treatment console error
    // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
    // ...mapGetters("pat-viewer", ["getMstTreatmentData"]),
    ...mapGetters("pat-viewer", ["getMstTreatmentData","getMstTreatmentDataIsDel"]),
    // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end
    // modiify 10196 by kangjie 20240228 end
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    ...mapGetters("pat-viewer",["getTabooEquipment","getTabooDialyzer"]),
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
    ...mapGetters("pat-viewer-treat-cond", {checkDisabled: "getCheckDisabled"}),
    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
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
      const day = dayjs().format("YYYYMMDD");
      // 一年後に最大日を設定
      let endMaxDate = this.schExtEndDate
        ? dayjs(this.schExtEndDate, "YYYYMMDD")
        : dayjs(day).add(1, "year");
      // 一年後から1日戻す
      endMaxDate = dayjs(endMaxDate).endOf("month");
      return dayjs(endMaxDate).format("YYYY-MM-DD");
    },

    /**
     * 指定日以降編集不可
     */
    disableDatesAfter() {
      return dayjs(this.maxDate).format("YYYYMMDD");
    },
    //add 6686 スケジュール作成時の日付の初期値について 張 start
    /**
     * 指定日前編集不可
     */
    disableDatesBefore() {
      return dayjs(this.structData.indStartDate).format("YYYYMMDD");
    },
    toMonth() {
      return dayjs(this.structData.indStartDate).format("YYYY-MM-DD");
    },
    //add 6686 スケジュール作成時の日付の初期値について 張 end
    cycleWeek() {
      return this.structData.cycleWeek;
    },

    /**
     * スケジュール自動延長最終日
     */
    schExtEndDate() {
      // TODO: 自動延長の実行タイミングによりデータ不一致が発生する可能性がある
      return this.selectedPat.pat_main.sch_ext_end_date;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    editFlg() {
      // 無変更保存許可モーダルタイトル
      let noChangeSavePermitTitles = [
        "除水プログラム",
        "Na注入プログラム",
        "透析液濃度プログラム",
        "血流量・透析液流量プログラム",
        "Ｉ‐ＨＤＦプログラム",
        "BV‐UFC",
        "透析量プログラム"
      ];
      noChangeSavePermitTitles = noChangeSavePermitTitles.map((title) => {
        return MODAL_TITLE[title];
      })
      // 上記タイトルの場合は無変更でも保存ボタンを押せるようにする
      if (noChangeSavePermitTitles.includes(this.settingData.headerTitle)) {
        return true;
      }
      if (this.structData.indEndDate === null) {
        this.initStructData.indEndDate = null
      }
      if (typeof this.structData.indUser === 'string' && this.initStructData) {
        this.initStructData.indUser = this.initStructData.indUser + '';
      }
      let isEdit = false;
      // 治療条件の中身がリセットされた際はフラグを戻す
      // ※リセットの際、治療条件の子コンポーネントが再作成されるため機能しなくなる。強制的にこのisEditを動かして再度依存関係を作る用として必要
      if(this.isIndActionChart && this.isIndActionChartReset){
        this.isIndActionChartReset = false
      }
      // タイトル
      let titles = [
        "治療方法編集",
        "スケジュール編集",
        "治療条件",
        "治療時間編集",
        "VA編集",
        "DW/目標体重/除水量制限編集",
        "目標体重編集",
        "除水量制限編集",
        "ダイアライザ/吸着カラム編集",
        "1次膜/2次膜編集",
        "穿刺針情報編集",
        "血液回路編集",
        "血流量編集",
        "透析液情報編集",
        "補液情報編集",
        "抗凝固剤情報編集",
        "医療材料編集",
        "指示コメント編集",
        "風袋編集",
        "除水補正編集",
      ];
      titles = titles.map((title) => {
        return MODAL_TITLE[title];
      })
      if (titles.includes(this.settingData.headerTitle)) {
        // 子の変更チェックや非活性チェックより、変更ありか判定
        const slotComponent = this.getDefaultSlotComponent();
        isEdit = (typeof slotComponent?.isEdit === "function" ? slotComponent.isEdit() : false)
          || this.ihdfChangeFlag || this.checkDisabled;
      }
      return this.editSelectIdFlg || isEdit
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    // add start 馬 #10206
    isShowEditOnlyFlag() {
      let titles = [
        "スケジュール編集", "指示コメント編集", "予定作成", "治療方法編集",
        // mod #11311 編集箇所のみ保存の再精査 zkm start
        // "医療材料編集", "除水プログラム", "Na注入プログラム", "透析液濃度プログラム",
        "除水プログラム", "Na注入プログラム", "透析液濃度プログラム",
        // mod #11311 編集箇所のみ保存の再精査 zkm end
        "血流量・透析液流量プログラム", "Ｉ‐ＨＤＦプログラム",
        // add #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start 
        "透析量プログラム"
        // add #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end 
      ];
      titles = titles.map((title) => {
        return MODAL_TITLE[title];
      });
      // mod #11311 編集箇所のみ保存の再精査 zkm start
      // return !titles.includes(this.settingData.headerTitle) &&
      // !this.settingData.showDelete &&
      // (!this.settingData.showNewEdit || this.edit == 0);
      let showTitles = [ "風袋編集", "除水補正編集" ];
      const COND_MODAL_TITLE = [
        "治療条件",
        "治療時間編集",
        "VA編集",
        "DW/目標体重/除水量制限編集",
        "目標体重編集",
        "除水量制限編集",
        "ダイアライザ/吸着カラム編集",
        "1次膜/2次膜編集",
        "穿刺針情報編集",
        "血液回路編集",
        "血流量編集",
        "透析液情報編集",
        "補液情報編集",
        "抗凝固剤情報編集"
      ];
      return !titles.includes(this.settingData.headerTitle) &&
      !this.settingData.showDelete
        && (showTitles.map((title) => MODAL_TITLE[title]).includes(this.settingData.headerTitle)
          || (COND_MODAL_TITLE.includes(this.settingData.headerTitle) && !this.settingData.showNewEdit)
          || (!COND_MODAL_TITLE.includes(this.settingData.headerTitle) && this.settingData.showNewEdit && this.edit === 0));
      // mod #11311 編集箇所のみ保存の再精査 zkm end
    }
    // add end 馬 #10206
  },

  watch: {

    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
    checkDisabled() {
      return this.checkDisabled === true;
    },
    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end

    modalVisible(value) {
      // 治療方法リストとクールリスト作成
      if (value === true) {
        this.createKurAndTreatmentList();
      }
    },
    // add #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
    async doGetBedList(value) {
      if (value) {
        await this.resetComponentData();
        this.doGetBedList = false;
      }
    },
    // add #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
    async "structData.selectedTreat"(value) {
      if (null !== this.treatMaxSelectedItems) {
        const component = await this.getDefaultSlotComponentAfterRender();
        component?.changeMultSelect(value);
      }

      if (true === this.isWatchParent) {
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
        // this.getDefaultSlotComponent().changeParentInfo();
        this.doGetBedList = true;
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
      }
    },
    async calendarIndStartDate(value) {
      this.structData.indStartDate = value;

      if (true === this.isWatchParent) {
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
        // this.getDefaultSlotComponent().changeParentInfo();
        this.doGetBedList = true;
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
      }

      // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start
      // 治療種別を設定
      if (this.settingData.showSegment) {
        await this.setTreatTypeInfo();
      }
      // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 end
    },
    async calendarIndEndDate(value) {
      this.structData.indEndDate = value;

      if (true === this.isWatchParent) {
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
        // this.getDefaultSlotComponent().changeParentInfo();
        this.doGetBedList = true;
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
      }
      // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start
        // 治療種別を設定
        if (this.settingData.showSegment) {
          await this.setTreatTypeInfo();
        }
      // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 end
    },

    "structData.indWeeks": {
      handler() {
        if (true === this.isWatchParent) {
          // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
          // this.getDefaultSlotComponent().changeParentInfo();
          this.doGetBedList = true;
          // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
        }
      },
      deep: true
    },

    "structData.selectedKur": {
      handler() {
        if (true === this.isWatchParent) {
          // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
          // this.getDefaultSlotComponent().changeParentInfo();
          this.doGetBedList = true;
          // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
        }
      },
      deep: true
    },

    "messageDialogInfo.isDialogVisible"(isShow) {
      this.isUpdating = isShow ? false : this.isUpdating;
    },

    // isUpdating(isUpdating) {
    //   this.setLoadingScreenMessage("保存中...");
    //   // this.setLoadingScreenVisible(isUpdating);
    //   // add 患者経過総合ビューア画面で他人の情報が表示されることがあります 5494   shan start
    //   // this.resetLoadingScreenVisibleCount();
    //   // add 患者経過総合ビューア画面で他人の情報が表示されることがあります 5494   shan end
    // },

    // add 画面デザイン改善対応 李 start
    "structData.indUser"(val) {
      // 選択した値と初期値が異なる場合
      if ((val ?? "") != (this.firValue ?? "")) {
        setKendoDropDownListEditedState(this.$el || this, { enabled: true });
      } else {
        setKendoDropDownListEditedState(this.$el || this, { enabled: false });
      }
    }
    // add 画面デザイン改善対応 李 end
  },

  async created() {
    //FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add start
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    const mac = ua.indexOf('mac');
    const os = ua.indexOf('os');
    if(mac > 0 && os > 0){
      this.isIOS = true;
    }
    //FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add end
    //add FNSI-No.IES145 権限対応  吉 start
    this.setLoadingScreenVisible(true);
    //add FNSI-No.IES145 権限対応  吉 end
    // 治療開始日の制御
    // this.AdjustTreatStartDate(this.structData.indStartDate);
    this.AdjustTreatStartDate(this.structData.indStartDate,true);

    // 治療方法、クールリスト設定
    await this.createKurAndTreatmentList();
    //del #10150 piao start
// //  redmine 4633 姜  start
//     let treatmentCdList = [];
//
//     if (this.structData.selectedTreat.length == 0) {
//       for (let i = 0; i < this.dataList.length; i++) {
//         treatmentCdList.push(this.dataList[i].indTreatmentCd);
//       }
//     } else {
//       for (let i = 0; i < this.structData.selectedTreat.length; i++) {
//         treatmentCdList.push(this.structData.selectedTreat[i]);
//       }
//     }
//
//     const param = {
//                 facility_cd: this.structData.facilityCd,
//                 treatmentCdList: treatmentCdList
//               };
//     for (let i = 0; i < treatmentCdList.length; i++) {
//       ApiHelper.post("/mainData/getDeviceModeBytreatmentCd", param).then(response=>{
//             if (0 !== response.data.length) {
//               let flg = true;
//               for (let i = 0; i < response.data.length; i++) {
//                 if (response.data[i].deviceMode != 9) {
//                   this.treatmentSetDayDisplayFlg = false;
//                   flg = false;
//                 }
//                 if (flg) {
//                   this.treatmentSetDayDisplayFlg = true;
//                 }
//               }
//               this.setTreatmentSetDayDisplayFlg(this.treatmentSetDayDisplayFlg);
//             }
//           });
//     }
// //  redmine 4633 姜  end
    //del #10150 piao end
    // 指示者リスト設定
    await this.getIndUserList(
        AUTHORITY_CODES.IND_EDIT,
        AUTHORITY_CODES.IND_PEDIT).then(response => {
      if(MODAL_TITLE["風袋編集"] == this.settingData.headerTitle || MODAL_TITLE["除水補正編集"] == this.settingData.headerTitle){
        this.authorityCds=[AUTHORITY_CODES.PAT_EDIT];
        this.flagAuthority = this.getTreatmentRecordAuthority();
        if(!this.flagAuthority){
          this.updateDisable = true;
        }
      }
      this.structData.userOptions = response.doctorList;
      this.$nextTick(() => {
        this.structData.indUser = response.iniSelectId === undefined ? "" : response.iniSelectId;
        // 初期値を退避
        this.firValue = this.structData.indUser;
      });
    });
    // 治療予定リスト取得
    await this.getTreatDateList();

    // 治療方法・クールデフォルト値設定
    await this.setDefaultTreatmentAndKur(
      this.structData.indStartDate,
      this.structData.indEndDate);
    // add 8204 周安寧 start
    await this.getTreatmentlist();
    // add 8204 周安寧 end
    // 治療種別を設定
    // TODO: 治療種別の選択肢がない場合でも毎回設定が必要か精査中
    if (this.settingData.showSegment) {
      await this.setTreatTypeInfo();
    }
    // add FNSI-治療方法&クール選択不可の修正 楊 start
    if ("" !== this.structData.indEndDate && null !== this.structData.indEndDate) {
      // add FNSI-治療方法&クール選択不可の修正 楊 end
      // add FNSI-濃度プログラムチェックの追加 楊 start
      // 終了日の指定がない場合は、デフォルト値の設定処理終了
      let selectedTreat = this.structData["treatOptions"].find(element => element.value === this.structData.selectedTreat[0]);
      // add undefined error 対応 韓 start
      if (selectedTreat) {
      // add undefined error 対応 韓 end
        let deviceMode;
        // 装置モードをマスタから取得
        // 治療方法マスタ
        let mstRecord = this.getMstTreatmentData.find(mstData => {
          return mstData.treatmentCd === selectedTreat.value;
        });
        if (mstRecord) {
          deviceMode = mstRecord.deviceMode;
        }
        // this.commitSelectedTreat(deviceMode);
        // 6:AFBFの場合、電源をOFFにする
        if (deviceMode === 6) {
          EventBus.$emit("afbf-modal", true);
        }
        // add FNSI-濃度プログラムチェックの追加 楊 end

        // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
        // 10:I-HDFの場合、電源をOFFにする
        if (deviceMode === 10) {
          EventBus.$emit("ihdf-modal", true);
        }
      }
      // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end
      // add FNSI-治療方法&クール選択不可の修正 楊 start
    } else {
      // オーダー番号確定時は治療方法、クール選択可
      this.treatAndKurEdit = false;
    }
    // add FNSI-治療方法&クール選択不可の修正 楊 end

    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
    await this.getDeviceSetInfoInd();
    await this.showOhdfComment();
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
    //add FNSI-No.IES145 権限対応  吉 start
    this.setLoadingScreenVisible(false);
    //add FNSI-No.IES145 権限対応  吉 end
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    // if (this.settingData.headerTitle !== 'スケジュール編集'
    //     && this.settingData.headerTitle !== '指示コメント編集'
    //     && this.settingData.headerTitle !== '予定作成'
    //     //mod FNSI-4882 劉全航 start
    //     && this.settingData.headerTitle !== '治療方法編集'
    //     //mod FNSI-4882 劉全航 end
    //     ) {
    //   this.setIntervalObj = setInterval(() => {
    //     let icount = $("ons-input[class*='-edited']").length;
    //     //mod FNSI-4882 劉全航 start
    //     let ecount = $(".equipment-set-row-style").length;
    //     let twcount = $("td[class*='-edited']").length;
    //     //mod FNSI-4882 劉全航 end
    //     let lcount = $("label[class*='-edited']").length;
    //     let tcount = $("textarea[class*='-edited']").length;
    //     let dcount = $("div.time-span[class*='-edited']").length;
    //     let d2count = $("div.custom-div-show-selected-item[class*='-edited']").length;
    //     dcount = dcount + d2count;
    //     // add FNSI-改修内容6158、6159、6160修正 xuty start
    //     let scount = $("ons-select[class*='-edited']").length;
    //     // add FNSI-改修内容6158、6159、6160修正 xuty end
    //     //mod FNSI-4882 劉全航 start
    //     // mod FNSI-改修内容6158、6159、6160修正 xuty start
    //     // if ((icount + lcount + tcount + dcount) === 0) {
    //     // if ((icount + lcount + tcount + dcount + scount) === 0) {
    //     // if ((icount + ecount + lcount + tcount + dcount + scount) === 0) {
    //     // mod FNSI-改修内容6158、6159、6160修正 xuty end
    //     // #内部 風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。start
    //     // #5841 【設計書作成】医療材料編集画面的编辑按钮点击后变成非选择状态 訾浩 start
    //     if (!this.newEditFlag ? ((icount + ecount + twcount + lcount + tcount + dcount + scount) === 0) : (((icount + ecount + twcount + lcount + tcount + dcount + scount) === 0) || ((icount + ecount + twcount + lcount + tcount + dcount + scount) === 1))) {
    //       // #5841 【設計書作成】医療材料編集画面的编辑按钮点击后变成非选择状态 訾浩 end
    //       // #内部 風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。end
    //       //mod FNSI-4882 劉全航 end
    //
    //       this.editFlg = false;
    //     } else {
    //       this.editFlg = true;
    //     }
    //   }, 200);
    // } else {
    //   this.editFlg = true;
    // }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    await this.setInitStructData();
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },

  beforeUnmount() {
    if (this.setIntervalObj) {
      clearInterval(this.setIntervalObj);
    }
    // #内部 風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。start
    this.newEditFlag = false
    // #内部 風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。end
  },

  methods: {
    getScopedRoot() {
      return this.$refs.modalBodyRoot || this.$el || null;
    },
    getScopedDateMarkerElement(id) {
      return getScopedElementById(id, this.getScopedRoot());
    },
    getScopedDateInput(target) {
      return queryScopedSelector(`input[data-target^="${target}"]`, this.getScopedRoot());
    },
    getScopedDateValidity(target) {
      return this.getScopedDateInput(target)?.validity || { badInput: false };
    },
    getDefaultSlotComponent() {
      const host = this.$refs.defaultSlotHost || null;
      if (host && this.$.subTree) {
        const slotComponent = this.findSlotComponentFromHost(host);
        if (this.isResolvableSlotComponent(slotComponent)) {
          return slotComponent;
        }
      }
      return resolveDefaultSlotComponent(this);
    },
    getTreatMethodSlotComponent() {
      let component = this.getDefaultSlotComponent();
      while (component && component !== this && !component.$data?.displayInputValue) {
        component = component.$parent;
      }
      return component !== this ? component : null;
    },
    isResolvableSlotComponent(component) {
      return !!component && (
        typeof component.updateIndInfo === "function" ||
        typeof component.resetComponentIndData === "function" ||
        typeof component.isEdit === "function"
      );
    },
    collectComponentProxies(vnode) {
      const result = [];
      const visit = (node) => {
        if (!node) {
          return;
        }
        if (Array.isArray(node)) {
          node.forEach(visit);
          return;
        }
        if (node.component?.proxy) {
          result.push(node.component.proxy);
        }
        visit(node.component?.subTree);
        if (Array.isArray(node.children)) {
          node.children.forEach(visit);
        }
        if (Array.isArray(node.dynamicChildren)) {
          node.dynamicChildren.forEach(visit);
        }
      };
      visit(vnode);
      return result;
    },
    findSlotComponentFromHost(host) {
      let fallback = null;
      let slotWithUpdateIndInfo = null;
      let slotWithResetIndData = null;
      let slotWithIsEdit = null;

      const considerProxy = (proxy) => {
        if (!proxy || proxy === this) {
          return false;
        }
        const el = proxy.$el;
        if (!el || typeof host.contains !== "function" || !host.contains(el)) {
          return false;
        }
        if (!slotWithUpdateIndInfo && typeof proxy.updateIndInfo === "function") {
          slotWithUpdateIndInfo = proxy;
          return true;
        }
        if (!slotWithResetIndData && typeof proxy.resetComponentIndData === "function") {
          slotWithResetIndData = proxy;
        }
        if (!slotWithIsEdit && typeof proxy.isEdit === "function") {
          slotWithIsEdit = proxy;
        }
        fallback = proxy;
        return false;
      };

      const visit = (node) => {
        if (!node || slotWithUpdateIndInfo) {
          return;
        }
        if (Array.isArray(node)) {
          node.forEach(visit);
          return;
        }
        if (node.component?.proxy && considerProxy(node.component.proxy)) {
          return;
        }
        visit(node.component?.subTree);
        if (slotWithUpdateIndInfo) {
          return;
        }
        if (Array.isArray(node.children)) {
          for (const child of node.children) {
            visit(child);
            if (slotWithUpdateIndInfo) {
              return;
            }
          }
        }
        if (Array.isArray(node.dynamicChildren)) {
          for (const child of node.dynamicChildren) {
            visit(child);
            if (slotWithUpdateIndInfo) {
              return;
            }
          }
        }
      };

      visit(this.$.subTree);
      return slotWithUpdateIndInfo || slotWithResetIndData || slotWithIsEdit || fallback;
    },
    findFirstComponentProxyInHost(vnode, host) {
      if (!vnode || !host) {
        return null;
      }
      if (Array.isArray(vnode)) {
        for (const child of vnode) {
          const found = this.findFirstComponentProxyInHost(child, host);
          if (found) {
            return found;
          }
        }
        return null;
      }
      if (vnode.component?.proxy && vnode.component.proxy !== this) {
        const componentEl = this.getVNodeHostElement(vnode.component.subTree || vnode);
        if (componentEl && host.contains(componentEl)) {
          return vnode.component.proxy;
        }
      }
      const nested = [
        vnode.component?.subTree,
        vnode.children,
        vnode.dynamicChildren,
        vnode.ssContent,
        vnode.ssFallback
      ];
      for (const child of nested) {
        const found = this.findFirstComponentProxyInHost(child, host);
        if (found) {
          return found;
        }
      }
      return null;
    },
    async getDefaultSlotComponentAfterRender() {
      let component = this.getDefaultSlotComponent();
      if (!component) {
        await this.$nextTick();
        component = this.getDefaultSlotComponent();
      }
      return component;
    },
    getVNodeHostElement(vnode) {
      if (!vnode) {
        return null;
      }
      if (Array.isArray(vnode)) {
        for (const child of vnode) {
          const found = this.getVNodeHostElement(child);
          if (found) {
            return found;
          }
        }
        return null;
      }
      if (vnode.el && typeof vnode.el.nodeType === 'number') {
        return vnode.el;
      }
      if (vnode.component?.subTree) {
        return this.getVNodeHostElement(vnode.component.subTree);
      }
      if (Array.isArray(vnode.children)) {
        return this.getVNodeHostElement(vnode.children);
      }
      return null;
    },
    getRenderedChildren(target) {
      return this.collectComponentProxies(target?.$.subTree);
    },
    getRenderedChild(target, indexes = []) {
      let current = target;
      for (const index of indexes) {
        current = this.getRenderedChildren(current)[index];
        if (!current) {
          return null;
        }
      }
      return current;
    },
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
      "resetLoadingScreenVisibleCount",
      "startLoadingScreen",
      "finishLoadingScreen",
      "executeWithLoadingScreen",
    ]),
    //FNSI-修正 #5525 横展開対応、xugj add start
    // ...mapActions("treatment-record/common",
    //   [
    //     "getMstMachineByOrdNoRst",
    //     "sendNextPatInfoViewer"
    //   ]),
    //FNSI-修正 #5525 横展開対応、xugj add end
    // add FNSI-濃度プログラムチェックの追加 楊 start
    ...mapMutations("pat-viewer-modal", ["commitSelectedTreat"]),
    // add FNSI-濃度プログラムチェックの追加 楊 start
    ...mapMutations("pat-viewer-popover", [
      "setIndStartDate"
    ]),
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    ...mapMutations("pat-viewer", [
      "setIndEndDate",
      "setTabooEquipment"
    ]),
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    // del #10150 piao Start
    // ...mapMutations("indication", {
    //   setTreatmentSetDayDisplayFlg: "setTreatmentSetDayDisplayFlg"
    // }),
    // del #10150 piao end
      // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
    ...mapMutations("pat-viewer-treat-cond", [
      "setIsUseFlagVA" //VA使用フラグを設定
      ,"setIsUseFlagDialyzer"//ダイアライザ使用フラグを設定
      ,"setIsUseFlagColumn"//吸着カラム使用フラグを設定
      ,"setIsUseFlagFirstPass" //1次膜使用フラグを設定
      ,"setIsUseFlagSecondPass"//2次膜使用フラグを設定
      ,"setIsUseFlagTube" //血液回路使用フラグを設定
      ,"setIsUseFlagBloodFlow"//血流量使用フラグを設定
      ,"setIsUseFlagWeight"//体重使用フラグを設定
      ,"setIsUseFlagFilterLimit" //除水量制限使用フラグを設定
      ,"setIsUseFlagNeedleSelection"//シングルニードル使用フラグを設定
      ,"setIsUseFlagNeedleA"//穿刺針(A)使用フラグを設定
      ,"setIsUseFlagNeedleV"//穿刺針(V)使用フラグを設定
      ,"setIsUseFlagNeedleNeedleSN"//穿刺針(SN)使用フラグを設定
      ,"setIsUseFlagDialysate"//透析液使用フラグを設定
      ,"setIsUseFlagDialysateFlowRate"//透析液流量使用フラグを設定
      ,"setIsUseFlagDialysateAmount"//透析液使用数使用フラグを設定
      ,"setIsUseFlagDialysateTemperature"//透析液温度使用フラグを設定
      ,"setIsUseFlagIv"//補液使用フラグを設定
      ,"setIsUseFlagIvAmount"//補液量使用フラグを設定
      ,"setIsUseFlagIvSelection"//補液選択使用フラグを設定
      ,"setIsUseFlagIvCount"//補液使用数使用フラグを設定
      ,"setIsUseFlagIvTemperature"//補液温度使用フラグを設定
      ,"setIsUseFlagIvFlowRate"//補液速度使用フラグを設定
      ,"setIsUseFlagAntiCoaguLant"//抗凝固剤使用フラグを設定
      ,"setIsUseFlagAntiCoagulantOneshotAmount"//抗凝固剤ワンショット量使用フラグを設定
      ,"setIsUseFlagAntiCoagulantFlowRate"//抗凝固剤持続速度使用フラグを設定
      ,"setIsUseFlagAntiCoagulantAmountTotal"//抗凝固剤持続総量使用フラグを設定
      ,"setIsUseFlagIpSelection"//IP使用選択使用フラグを設定
      ,"setIsUseFlagIpStart"//IPスタート使用フラグを設定
      ,"setIsUseFlagIpOneshotAmount"//IPワンショット量使用フラグを設定
      ,"setIsUseFlagIpFlowRate"//IP速度使用フラグを設定
      ,"setIsUseFlagIpFlowRateLimit"//IP速度最大値使用フラグを設定
      ,"setIsUseFlagIpOneshotSelection"//IPワンショットスタート使用フラグを設定
      ,"setIsUseFlagIpAutoOff"//IP電源自動切り使用フラグを設定
      ,"setIsUseFlagIpAutoOffTiming"//IP電源自動切り時間使用フラグを設定
      ,"setIsUseFlagIpMonitorOff"//IP電源OKモニタ切り使用フラグを設定
      ,"setIsUseFlagIpMonitorOffTiming"]),//IP電源OKモニタ切り時間使用フラグを設定
      // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized() {
      if (this.settingData.headerTitle == MODAL_TITLE["風袋編集"] ||
        this.settingData.headerTitle == MODAL_TITLE["除水補正編集"]) {
        return getAuthorized('Indication', 'item_base_tare_off_water');
      } else if (this.settingData.headerTitle == MODAL_TITLE["スケジュール編集"]) {
        return getAuthorized('Indication', 'item_schedule');
      } else {
        return getAuthorized('Indication', 'default_authority');
      }
    },
    // add #10359 編集権限の動作不正 dengshen end
    hideModal() {
      // #5827 【設計書作成】補液量上限チェック的title未消去 訾浩 start
      this.messageDialogInfo.title = DIALOG_MESSAGES[13000004].title
      // #5827 【設計書作成】補液量上限チェック的title未消去 訾浩 end
      // 変更箇所があればメッセージ表示
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      // if (this.getDefaultSlotComponent().checkEdit(1)) {
      //   return;
      // }
      if (this.editFlg || !this.structData.editOnly) {
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
      }else {
        // モーダル閉じる
        this.$emit("hide-modal");
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    },

    changeSegment(event) {
      this.edit = Number(event.target.value);
      if (this.edit === 1) {
        this.structData.editOnly = true;
      } else {
        // #内部 風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。start
        this.newEditFlag = true
        // #内部 風袋編集:「風袋編集」を選択し、「ある項目」を編集した場合、「編集項目の内容」にチェックを入れることを前提に、保存することはできません。end
      }
      this.getDefaultSlotComponent().selectSegment(
        event.target.value);
    },
    changeDialSegment(value) {
      this.structData.cycleWeek = value;
      // this.structData.cycleWeek = event.target.value;
      if ("1" === this.structData.cycleWeek) {
        this.disabledWeekdays = [3, 4, 5, 6, 7];
        const day = dayjs(this.structData.indStartDate, "YYYY-MM-DD");
        if (1 !== day.isoWeekday() && 2 !== day.isoWeekday()) {
          this.structData.indStartDate = "";
        }
      } else {
        this.disabledWeekdays = [];
      }
    },

    //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add start
    messageInfo(messageCd) {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].message;
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;

      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.replace(/\n/g, "<br>");
      return replacedMessage;
    },
    //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add end
// add 8204 周安寧 start
    async getTreatmentlist(){

      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
        // 施設情報
        paramJson.facility_cd = this.structData.facilityCd;
        // 患者情報
        paramJson.pat_id = this.structData.patId;
        // 治療開始日時
        paramJson.start_date = this.structData.indStartDate;
        // 治療終了日時
        paramJson.end_date = "";
        // クール
        paramJson.ind_kur_cd = JSON.stringify(this.structData.selectedKur);
        // 治療方法
        paramJson.ind_treatment_cd = JSON.stringify(this.structData.selectedTreat);
        // 曜日パターン
        paramJson.weeks = JSON.stringify(indWeeks);

        // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
        const response = await ApiHelper.post(
          "/mainData/getTreatmentConditionSetting",
          paramJson).catch(error => {
          getErrorMessage('IndActionChart.vue', 'getTreatmentlist', error);
          throw error;
        });
        this.treatmentConditionSettingSource = [];
        response.data.forEach((dataSource) => {
        const dataSourceJson = {
          treatmentCd: dataSource.treatmentCd,
          treatDate: dataSource.treatDate,
          indKurCd: dataSource.indKurCd,
          treatWeek: dataSource.treatWeek,
          treatmentConditionSetting: dataSource.treatmentConditionSetting
        };
        this.treatmentConditionSettingSource.push(dataSourceJson);

      });
    },
    // add 8204 周安寧 end
    // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
    async updateIndInfo(num, type='', childOptions = {}) {
      // スケジュール編集の new（OrdMoveCheck）/保存（旧）どちらから来たかを保持する。
      this.lastUseOrdMoveCheckApi = childOptions && childOptions.useOrdMoveCheckApi === true;
      // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end

      //add FNSI-6783 劉全航 start
      if(this.settingData.headerTitle === MODAL_TITLE["BV‐UFC"]){
        let BVOutOfLimits = this.getDefaultSlotComponent().BVOutOfLimits;
        if(BVOutOfLimits){
          let ok = await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "固定倍率除水終了条件",
            title: DIALOG_MESSAGES['22010015'].title,
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            message: this.messageInfo('22010015')
          });
          if (!ok) {
            return;
          }
        }
      }
      //add FNSI-6783 劉全航 end
      //add FNSI-6442 劉全航 start
      if(this.settingData.headerTitle === MODAL_TITLE["血流量編集"]){
        let treatmentCdList = [];
        if(this.structData.selectedTreat.length === 0){
          this.structData.treatOptions.forEach(o=>{
            treatmentCdList.push(o.value);
          });
        }else{
          this.structData.selectedTreat.forEach(cd=>{
            treatmentCdList.push(cd);
          })
        }
        let flag = false;
        if(treatmentCdList.length > 0){
          let selectedOption = JSON.parse(this.selectedPat.pat_main.device_set_info).ope.dev.A[389];
          treatmentCdList.forEach(a=>{
            this.getMstTreatmentData.forEach(b=>{
              if(b.treatmentCd === a && (b.deviceMode === 7||b.deviceMode === 8)){
                if(selectedOption === "2"){
                  flag = true;
                return;
                }
              }
            });
          });
        }
        if(flag){
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "血流量、補液速度、補液量変更",
            title: DIALOG_MESSAGES[22010014].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: this.messageInfo('22010014')
          });
        }
      }
      //add FNSI-6442 劉全航 end
      //add FNSI-6924 劉全航 start
      let messageCd = null;
      let stringParams = "";
      if(this.settingData.headerTitle === MODAL_TITLE["治療方法編集"] && this.settingData.ordNo){
        var treatmentCd;
        const treatMethodComp = this.getTreatMethodSlotComponent();
        var selectedNo = treatMethodComp?.$data?.displayInputValue?.editValue;
        if(selectedNo === "1"){
          treatmentCd = treatMethodComp?.$data?.selectedTreat;
        }else{
          const activePlanCreate = treatMethodComp?.$refs?.activePlanCreate;
          treatmentCd = activePlanCreate?.selectedSet?.treatmentCd;
        }
        // 予定内容入力チェック
        if(!treatmentCd){
          messageCd = 22010001;
          stringParams = "予定内容";
        }else{
          var response = await ApiHelper.get("/mainData/getMachineByOrdNo",
            {ordNo: this.settingData.ordNo, newTreatmentCd: treatmentCd}).catch(error => {
              getErrorMessage('IndEditBase.vue', 'updateIndInfo', error);
              throw error;
            });
          if(response.data === false){
            let ok = await this.$ons.notification.confirm({
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
              // title: "",
              title: DIALOG_MESSAGES["22010013"].title,
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
              message: this.messageInfo('22010013')
            })
            if (!ok) {
              return;
            }
          }
        }
      }
      //add FNSI-6924 劉全航 end

      //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add start
      if(this.isTreatTimeSettingFlg && this.getRenderedChild(this.getDefaultSlotComponent(), [0, 0]).displayInputValue) {
        let selectedTreat = this.structData["treatOptions"].find(element => element.value === this.structData.selectedTreat[0]);

        // 装置モード
        let deviceMode;
        if (selectedTreat) {
          // 装置モードをマスタから取得
          // 治療方法マスタ
          let mstRecord = this.getMstTreatmentData.find(mstData => {
            return mstData.treatmentCd === selectedTreat.value;
          });
          if (mstRecord) {
            deviceMode = mstRecord.deviceMode;
          }
        }
        //mod FNSI-6448 劉全航 start
        if(!this.treatAndKurEdit){
          if(this.structData.selectedTreat.length === 0){
            for(let i = 0; i < this.structData["treatOptions"].length; i++){
              let treatmentCd = this.structData["treatOptions"][i].value;
              let mstRecord = this.getMstTreatmentData.find(mstData => {
                return mstData.treatmentCd === treatmentCd;
              });
              // add 10196 by kangjie 20240228 start ordMain No.40 Change to delete treatment, including Change treatment console error
              if (mstRecord) {
                if(mstRecord.deviceMode !== 9){
                  deviceMode = mstRecord.deviceMode;
                  break;
                }else{
                  deviceMode = 9;
                }
              }else {
                let mstRecordIsDel = this.getMstTreatmentDataIsDel.find(mstData => {
                  return mstData.treatmentCd === treatmentCd;
                });
                if(mstRecordIsDel.deviceMode !== 9){
                  deviceMode = mstRecordIsDel.deviceMode;
                  break;
                }else{
                  deviceMode = 9;
                }
              }
              // add 10196 by kangjie 20240228 end

            }
          }else{
            for(let i = 0; i < this.structData.selectedTreat.length; i++){
                let treatmentCd = this.structData.selectedTreat[i];
                let mstRecord = this.getMstTreatmentData.find(mstData => {
                  return mstData.treatmentCd === treatmentCd;
                });
                // add 10196 by kangjie 20240228 start ordMain No.40 Change to delete treatment, including Change treatment console error
                if (mstRecord) {
                  if(mstRecord.deviceMode !== 9){
                    deviceMode = mstRecord.deviceMode;
                    break;
                  }else{
                    deviceMode = 9;
                  }
                }else {
                  let mstRecordIsDel = this.getMstTreatmentDataIsDel.find(mstData => {
                    return mstData.treatmentCd === treatmentCd;
                  });
                  if(mstRecordIsDel.deviceMode !== 9){
                    deviceMode = mstRecordIsDel.deviceMode;
                    break;
                  }else{
                    deviceMode = 9;
                  }
                }
                // add 10196 by kangjie 20240228 end
              }
          }
        }
        //mod FNSI-6448 劉全航 end

        // 治療時間
        let treatTime = this.getRenderedChild(this.getDefaultSlotComponent(), [0, 0]).displayInputValue.editValue;

        //【特殊浄化以外】の治療時間を個別に変更した場合
        if(this.treatAndKurEdit && deviceMode !== 9 && treatTime && treatTime > 600) {
          let ok = await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "治療時間の確認",
            title: DIALOG_MESSAGES['12000068'].title,
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            message: this.messageInfo('12000068')
          })
          if (!ok) {
            return;
          }
        }

        // 【特殊浄化】の治療時間を個別に変更した場合
        if(this.treatAndKurEdit && deviceMode === 9 && treatTime && treatTime > 4320) {
          let ok = await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "治療時間の確認",
            title: DIALOG_MESSAGES['12000069'].title,
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            message: this.messageInfo('12000069')
          })
          if (!ok) {
            return;
          }
        }

        // 複数の治療時間を変更した場合
        if(!this.treatAndKurEdit && deviceMode !== 9 && treatTime && treatTime > 600) {
          let ok = await this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "治療時間の確認",
            title: DIALOG_MESSAGES['12000070'].title,
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            message: this.messageInfo('12000070')
          })
          if (!ok) {
            return;
          }
        }
      }
      //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add end
      // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng start
      if (this.settingData.headerTitle === MODAL_TITLE["医療材料編集"]) {
        const equipmentObj = this.getDefaultSlotComponent();
        // 新規登録時無編集チェック
        if (type === 'equip-create' && !equipmentObj?.listData?.length) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[20010003].title,
            message: DIALOG_MESSAGES[20010003].message
          });
          return;
        }
        if (equipmentObj?.listData && equipmentObj?.$refs) {
          let medicineFlg = false;
          for(let item of equipmentObj.listData) {
            if (item.id && equipmentObj.$refs[item.id]) {
              const value = equipmentObj.$refs[item.id][0]?.amountInputValue?.editValue;
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
        }
        const amountInputValue = this.getRenderedChild(equipmentObj, [0, 1])?.amountInputValue;
        if (amountInputValue && (amountInputValue?.editValue === "" || isNaN(amountInputValue?.editValue) || amountInputValue?.editValue == 0)) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[13000170].title,
            message: DIALOG_MESSAGES[13000170].message
          });
          return;
        }

        // レンダリング完了を待ってから禁忌・アレルギーチェック処理実行
        await this.$nextTick();
        // 医療材料新規登録・編集画面の場合：
        // 選択医療材料に禁忌・アレルギーが存在するかチェックし、ストアに存在可否をセット(後続のチェック処理で参照する)
        this.checkEquipmentTabooAllergy();

      } else {
        // レンダリング完了を待ってから禁忌・アレルギーチェック処理実行
        await this.$nextTick();
        // 医療材料新規登録・編集画面以外の場合：
        // 画面項目（項目は画面によって可変）に禁忌・アレルギーが存在するかチェックし、ストアに存在可否をセット(後続のチェック処理で参照する)
        this.checkTabooAllergy();
      }
      // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng end

      // del #11731_【因島：改良】指示コメント番号の指定方法 (不用なログ) start
      // console.log("IndEditBase.vue updateIndInfo this.startLoadingScreen();");
      // del #11731_【因島：改良】指示コメント番号の指定方法 end
      this.startLoadingScreen();
      // 保存ボタンを非活性
      this.updateDisable = true;
      try {
      this.baseData = deepCopy(this.structData);
      // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
      // deepCopy により動的プロパティは消えるため、保持している値を書き戻す
      this.baseData.useOrdMoveCheckApi = this.lastUseOrdMoveCheckApi === true;
      // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end
      // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
      this.baseData.type = type;
      // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
      const startDateValid = this.getScopedDateValidity("indStartDate");
      const endDateValid = this.getScopedDateValidity("indEndDate");

      // 開始日の不完全入力チェック
      if ("" === this.baseData.indStartDate && startDateValid.badInput){
          messageCd = 22010008;
          stringParams = "開始日";
      }
      // 開始日の必須チェック
      if (null === messageCd &&
        (null === this.baseData.indStartDate || "" === this.baseData.indStartDate)) {
        messageCd = 22010001;
        stringParams = "開始日";
      }
      // 開始日の必須入力スタイル
        if("" === this.baseData.indStartDate){
           if (this.getScopedDateMarkerElement('date-start')) this.getScopedDateMarkerElement('date-start').style.background = "rgba(255, 0, 0, 0.5)";
        }
        if("" !== this.baseData.indStartDate && !this.settingData.startDateEdit){
           if (this.getScopedDateMarkerElement('date-start')) this.getScopedDateMarkerElement('date-start').style.background = "#ffff99";
        }
      // 終了日の不完全入力チェック
      if (null === messageCd && "" === this.baseData.indEndDate && endDateValid.badInput){
          messageCd = 22010008;
          stringParams = "終了日";
      }
      if (
        null === messageCd &&
        null !== this.baseData.indEndDate &&
        "" !== this.baseData.indEndDate) {
        if (this.baseData.indStartDate > this.baseData.indEndDate) {
          messageCd = 22010002;
          stringParams = "開始日≦終了日";
        }

        // 終了日の上限チェック(本日から1年後の昨日まで選択可能)
        if ("" === stringParams) {
          if (
            Number(
              dayjs(this.baseData.indEndDate, "YYYY-MM-DD").format("YYYYMMDD")) > Number(dayjs(this.maxDate, "YYYY-MM-DD").format("YYYYMMDD"))) {
            messageCd = "22010002";
            //mod FNSI-6926 劉全航 start
            // stringParams = `終了日は${dayjs(this.maxDate, "YYYY-MM-DD").format(
            //   "YYYY年M月D日以下"
            //)}`;
            stringParams = `開始日は${dayjs(this.maxDate, "YYYY-MM-DD").format(
              "YYYY/MM/DD(ddd)まで")}`;
            //mod FNSI-6926 劉全航 end
          }
        }
      }

      // 曜日選択のチェック
      if (null === messageCd && true === this.settingData.showWeeks) {
        let week = [];
        if ("1" === this.baseData.cycleWeek) {
          week = this.baseData.kakujituWeeks.filter(obj => obj.done === true);
        } else {
          week = this.baseData.indWeeks.filter(obj => obj.done === true);
        }
        if (null === messageCd && 0 === week.length) {
          messageCd = 22010001;
          stringParams = "曜日";
        }
      }

      // 指示者のチェック
      if (null === messageCd && !this.baseData.indUser && this.editIndUser) {
        messageCd = 22010001;
        stringParams = "指示者";
      }

      // 終了日存在チェックを格納
      this.baseData.isDeadline = true;

      // 終了日のチェック
      const day = this.maxDate;
      if (
        null === this.baseData.indEndDate ||
        "" === this.baseData.indEndDate) {
        // 空の場合、1年後の日を設定
        this.baseData.indEndDate = day;
        // 終了日存在フラグをfalseに設定
        this.baseData.isDeadline = false;
      } else {
        if (this.baseData.indEndDate > day) {
          // 1年より後の日を選択している場合、1年後の日を設定
          this.baseData.indEndDate = day;
        }
      }

      this.baseData.updUser = this.getStateUserAccountInfo.userId;
      // this.startLoadingScreen();
      // 指定した条件に合致する予定があるかどうかの確認（治療方法・クール選択表示時のみ）
      if (this.settingData.showTreat && this.settingData.showKur) {
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

        // 対象日時の治療情報取得(日付・曜日・治療方法・クールで絞り込み)
        const response = await ApiHelper.post(
          "/mainData/treatDateList",
          paramJson).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndEditBase.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          // del #11731_【因島：改良】指示コメント番号の指定方法 (不用なログ) start
          // console.log("IndEditBase.vue updateIndInfo throw error; this.finishLoadingScreen();");
          // del #11731_【因島：改良】指示コメント番号の指定方法 end
          this.finishLoadingScreen();
          throw error;
        });

        if (response.data.length === 0) {
          messageCd = 22010010;
          stringParams = "設定された変更対象治療方法・変更対象クールに該当する治療予定がありません。";
        }
      }
      // #5878 開始日チェック情報修正です 林峻峰 start
      if (!this.baseData.indStartDate || this.baseData.indStartDate === "Invalid date") {
        messageCd = 22010001;
        stringParams = "開始日";
      }
      // #5878 開始日チェック情報修正です 林峻峰 end
      if ("" !== stringParams) {
        this.messageDialogInfo.messageCd = messageCd;
        this.messageDialogInfo.type = "1";
        this.messageDialogInfo.stringParams = [stringParams];
        this.messageDialogInfo.isDialogVisible = true;
      } else {
        this.baseData.flag = num;
        this.isUpdating = true;
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
        this.itemMsgCd14Flg = true;
        this.itemMsgCd18Flg = true;
        this.itemMsgCd20Flg = true;
        this.itemMsgCd24Flg = true;
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
        //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
        if(this.getTabooEquipment === true) {
          const tabooAnswer = await new Promise(resolve => {
            this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[13000056].title,
              message: messageFormat(DIALOG_MESSAGES[13000056].message),
              callback: resolve
            });
          });
          if (tabooAnswer !== 1) {
            this.updateDisable = false;
            return;
          }
          this.setTabooEquipment(false);
        }
        await this.getDefaultSlotComponent().updateIndInfo(this.baseData, childOptions);
        // this.getDefaultSlotComponent().updateIndInfo(this.baseData);
        //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
        // 参照元画面更新フラグをON
        // this.isRefresh = true;
      }
      } finally {
        this.finishLoadingScreen();
      }
    },

    chkChange(week) {
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

      this.createKurAndTreatmentList();
      // add 8204 周安寧 start
      this.createTreatmentListForUseFlag(this.treatmentConditionSettingSource);
      // add 8204 周安寧 end
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
      // 通常曜日パターン情報に格納する(全曜日)
      this.structData.indWeeks[0].done = isDoneAll;
      this.structData.kakujituWeeks.forEach(item => {
        switch (item.value) {
          // 月・火
          case 1:
            // 通常曜日パターンの月曜日、火曜日にフラグを格納
            this.structData.indWeeks[1].done = item.done;
            this.structData.indWeeks[2].done = item.done;
            break;

          // 水・木
          case 2:
            this.structData.indWeeks[3].done = item.done;
            this.structData.indWeeks[4].done = item.done;
            break;

          // 金・土
          case 3:
            this.structData.indWeeks[5].done = item.done;
            this.structData.indWeeks[6].done = item.done;
            break;

          // 日
          case 4:
            this.structData.indWeeks[7].done = item.done;
            break;

          default:
            break;
        }
      });

      this.createKurAndTreatmentList();
      // add 8204 周安寧 start
      this.createTreatmentListForUseFlag(this.treatmentConditionSettingSource);
      // add 8204 周安寧 end
    },

    async onIndDateChange() {
      await this.createKurAndTreatmentList();
      await this.resetComponentData();
    },

    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
    async resetComponentData() {
      const slotComponent = await this.getDefaultSlotComponentAfterRender();
      if (typeof slotComponent?.resetComponentIndData === "function") {
        await this.executeWithLoadingScreen(
          () => slotComponent.resetComponentIndData(this.structData)
        );
      }

      if (this.isDialogType9_offWater) {
        await this.executeWithLoadingScreen(
          () => this.getRenderedChild(slotComponent, [0])?.resetComponentIndData?.(this.structData)
        );
      }
      if (this.isDialogType9_ihdf) {
        await this.executeWithLoadingScreen(
          () => this.getRenderedChild(slotComponent, [2])?.resetComponentIndData?.(this.structData)
        );
      }

    },
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end

    /**
     * 治療方法リストとクールリスト作成
     */
    async createKurAndTreatmentList() {
      this.count++
      //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
      this.setIndEndDate(this.structData.indEndDate);
      //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
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

      if (this.count === 1) this.startLoadingScreen();

      // カレンダーインタフェースをクリックして複数回呼び出す start
      await this.count === 1 && ApiHelper.post("/mainData/KurAndTreatmentList", params)
      // カレンダーインタフェースをクリックして複数回呼び出す end
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
          // カレンダーインタフェースをクリックして複数回呼び出す start
          this.count = 0
          // カレンダーインタフェースをクリックして複数回呼び出す end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndEditBase.vue', 'createKurAndTreatmentList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        })
        .finally(() => {
          this.finishLoadingScreen();
        });
    },
    // add 8204 周安寧 start
    createTreatmentListForUseFlag(treatmentConditionSettingSource) {
      let treatmentlist = treatmentConditionSettingSource;
      if (this.structData.indStartDate) {
        treatmentlist = treatmentlist.filter(item => (item.treatDate >= this.structData.indStartDate.replace(/-/g, '')));
      }
      if (this.structData.indEndDate) {
        treatmentlist = treatmentlist.filter(item => (item.treatDate <= this.structData.indEndDate.replace(/-/g, '')));
      }
      if (this.structData.selectedTreat.length >0){
        treatmentlist = treatmentlist.filter(item => (this.structData.selectedTreat.includes(item.treatmentCd)))
      }
      if (this.structData.selectedKur.length >0){
        treatmentlist = treatmentlist.filter(item => (this.structData.selectedKur.includes(item.indKurCd)))
      }
      let weekList = [];
      this.structData.indWeeks.forEach(eleItem => {
        if (eleItem.done === true) {
          weekList.push(parseInt(eleItem.value));
        }
      });
      if (weekList.length >0){
        treatmentlist = treatmentlist.filter(item => (weekList.includes(item.treatWeek)))
      }
      //del 余分なlogを削除する 周安寧 start
      //console.log(treatmentlist);
      //del 余分なlogを削除する 周安寧 end
      // add 8204 周安寧 start
      let isNoUse = true;
      //穿刺針使用フラグ
      let isNoUseSingleNeedle = true;
      //IP設定使用フラグ
      let isNoUseIPConflg = true;
      //抗凝固剤使用フラグ
      let isNoUseAntiCoaguLant = true;
      //透析液使用フラグ
      let isNoUseDialySisFluid = true;
      //体重使用フラグ
      let isNoUseWeight = true;
      //VA使用フラグ
      let isNoUseVA = true;
      //ダイアライザ使用フラグ
      let isNoUseDialyzer = true;
      //吸着カラム使用フラグ
      let isNoUseColumn = true;
      //1次膜使用フラグ
      let isNoUseFirstPass = true;
      //2次膜使用フラグ
      let isNoUseSecondPass = true;
      //血液回路使用フラグ
      let isNoUseTube = true;
      //血流量使用フラグ
      let isNoUseBloodFlow = true;
      treatmentlist.forEach(everyItem => {
        //VA使用
        const base = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 1);
        if (base[0].items[0].is_use === "1") {
          isNoUseVA = false;
        }
        //ダイアライザ
        if (base[0].items[1].is_use === "1") {
          isNoUseDialyzer = false;
        }
        //吸着カラム
        if (base[0].items[2].is_use === "1") {
          isNoUseColumn = false;
        }
        //1次膜
        if (base[0].items[3].is_use === "1") {
          isNoUseFirstPass = false;
        }
        //2次膜
        if (base[0].items[4].is_use === "1") {
          isNoUseSecondPass = false;
        }
        //血液回路
        if (base[0].items[5].is_use === "1") {
          isNoUseTube = false;
        }
        //血流量
        if (base[0].items[6].is_use === "1") {
          isNoUseBloodFlow = false;
        }
        //体重
        const weight = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 2);
        if (weight[0].items[0].is_use === "1") {
          isNoUseWeight = false;
        }
        //透析液
        const dialySisFluid = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 3);
        if (dialySisFluid[0].items[0].is_use === "1") {
          isNoUseDialySisFluid = false;
        }
        const items = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 4);
        if (items[0].items[0].is_use === "1") {
          isNoUse = false;
        }
        //抗凝固剤
        const antiCoaguLant = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 5);
        if (antiCoaguLant[0].items[0].is_use === "1") {
          isNoUseAntiCoaguLant = false;
        }
        //IP設定
        const iPConflg = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 6);
        if (iPConflg[0].items[0].is_use === "1") {
          isNoUseIPConflg = false;
        }
        //穿刺針
        const singleNeedle = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 7);
        if (singleNeedle[0].items[0].is_use === "1") {
          isNoUseSingleNeedle = false;
        }
      })
      this.setIsUseFlagVA(isNoUseVA); //VA使用フラグを設定
      this.setIsUseFlagDialyzer(isNoUseDialyzer);//ダイアライザ使用フラグを設定
      this.setIsUseFlagColumn(isNoUseColumn);//吸着カラム使用フラグを設定
      this.setIsUseFlagFirstPass(isNoUseFirstPass); //1次膜使用フラグを設定
      this.setIsUseFlagSecondPass(isNoUseSecondPass);//2次膜使用フラグを設定
      this.setIsUseFlagTube(isNoUseTube); //血液回路使用フラグを設定
      this.setIsUseFlagBloodFlow(isNoUseBloodFlow);//血流量使用フラグを設定
      this.setIsUseFlagWeight(isNoUseWeight);//体重使用フラグを設定
      this.setIsUseFlagFilterLimit (isNoUseWeight) //除水量制限使用フラグを設定
      this.setIsUseFlagNeedleSelection(isNoUseSingleNeedle) //シングルニードル使用フラグを設定
      this.setIsUseFlagNeedleA(isNoUseSingleNeedle) //穿刺針(A)使用フラグを設定
      this.setIsUseFlagNeedleV(isNoUseSingleNeedle) //穿刺針(V)使用フラグを設定
      this.setIsUseFlagNeedleNeedleSN(isNoUseSingleNeedle) //穿刺針(SN)使用フラグを設定
      this.setIsUseFlagDialysate(isNoUseDialySisFluid) //透析液使用フラグを設定
      this.setIsUseFlagDialysateFlowRate(isNoUseDialySisFluid) //透析液流量使用フラグを設定
      this.setIsUseFlagDialysateAmount(isNoUseDialySisFluid) //透析液使用数使用フラグを設定
      this.setIsUseFlagDialysateTemperature(isNoUseDialySisFluid) //透析液温度使用フラグを設定
      this.setIsUseFlagIv(isNoUse) //補液使用フラグを設定
      this.setIsUseFlagIvAmount(isNoUse) //補液量使用フラグを設定
      this.setIsUseFlagIvSelection(isNoUse) //補液選択使用フラグを設定
      this.setIsUseFlagIvCount(isNoUse) //補液使用数使用フラグを設定
      this.setIsUseFlagIvTemperature(isNoUse) //補液温度使用フラグを設定
      this.setIsUseFlagIvFlowRate(isNoUse) //補液速度使用フラグを設定
      this.setIsUseFlagAntiCoaguLant(isNoUseAntiCoaguLant) //抗凝固剤使用フラグを設定
      this.setIsUseFlagAntiCoagulantOneshotAmount(isNoUseAntiCoaguLant) //抗凝固剤ワンショット量使用フラグを設定
      this.setIsUseFlagAntiCoagulantFlowRate(isNoUseAntiCoaguLant) //抗凝固剤持続速度使用フラグを設定
      this.setIsUseFlagAntiCoagulantAmountTotal(isNoUseAntiCoaguLant) //抗凝固剤持続総量使用フラグを設定
      this.setIsUseFlagIpSelection(isNoUseIPConflg) //IP使用選択使用フラグを設定
      this.setIsUseFlagIpStart(isNoUseIPConflg) //IPスタート使用フラグを設定
      this.setIsUseFlagIpOneshotAmount(isNoUseIPConflg) //IPワンショット量使用フラグを設定
      this.setIsUseFlagIpFlowRate(isNoUseIPConflg) //IP速度使用フラグを設定
      this.setIsUseFlagIpFlowRateLimit(isNoUseIPConflg) //IP速度最大値使用フラグを設定
      this.setIsUseFlagIpOneshotSelection(isNoUseIPConflg) //IPワンショットスタート使用フラグを設定
      this.setIsUseFlagIpAutoOff(isNoUseIPConflg) //IP電源自動切り使用フラグを設定
      this.setIsUseFlagIpAutoOffTiming(isNoUseIPConflg) //IP電源自動切り時間使用フラグを設定
      this.setIsUseFlagIpMonitorOff(isNoUseIPConflg) //IP電源OKモニタ切り使用フラグを設定
      this.setIsUseFlagIpMonitorOffTiming(isNoUseIPConflg) //IP電源OKモニタ切り時間使用フラグを設定
      // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
    },
     // add 8204 周安寧 end
    /**
     * 治療方法リスト作成
     * @param {object} リスト作成元データ[{},{}...]
     */
    createTreatmentList(dataList) {
      if (0 !== dataList.length) {
        this.createList(dataList, "indTreatmentCd", "indTreatmentName", "treatOptions");
      }
    },
    /**
     * クールリスト作成
     * @param {object} リスト作成元データ[{},{}...]
     */
    createKurList(dataList) {
      if (0 !== dataList.length) {
        // add 8204 周安寧 start
        if (this.structData.selectedTreat.length >0){
          dataList = dataList.filter(item => (this.structData.selectedTreat.includes(item.indTreatmentCd)))
         }
         // add 8204 周安寧 end
        this.createList(dataList, "indKurCd", "indKurName", "kurOptions");
      }

      // del #10150 piao Start
      // //  redmine 4633 姜  start
      // let treatmentCdList = [];
      //
      // if (this.structData.selectedTreat.length == 0) {
      //   for (let i = 0; i < dataList.length; i++) {
      //     treatmentCdList.push(dataList[i].indTreatmentCd);
      //   }
      // } else {
      //   for (let i = 0; i < this.structData.selectedTreat.length; i++) {
      //     treatmentCdList.push(this.structData.selectedTreat[i]);
      //   }
      // }
      // const param = {
      //           facility_cd: this.structData.facilityCd,
      //           treatmentCdList: treatmentCdList
      //         };
      // for (let i = 0; i < treatmentCdList.length; i++) {
      //   ApiHelper.post("/mainData/getDeviceModeBytreatmentCd", param).then(response=>{
      //         if (0 !== response.data.length) {
      //           let aaa = true;
      //           for (let i = 0; i < response.data.length; i++) {
      //             if (response.data[i].deviceMode != 9) {
      //               this.treatmentSetDayDisplayFlg = false;
      //               aaa = false;
      //             }
      //             if (aaa) {
      //               this.treatmentSetDayDisplayFlg = true;
      //             }
      //           }
      //           this.setTreatmentSetDayDisplayFlg(this.treatmentSetDayDisplayFlg);
      //         }
      //       });
      // }
      // //  redmine 4633 姜  end
      // del #10150 piao piao
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
        undefined === this.settingData.ordNo) {
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
        // add FNSI-治療方法&クール選択不可の修正 楊 start
        // オーダー番号確定時は治療方法、クール選択可
        this.treatAndKurEdit = false;
        return;
        // add FNSI-治療方法&クール選択不可の修正 楊 end
      }
      // 曜日パターン
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";

      // オーダー番号確定時は治療方法、クール選択不可
      this.treatAndKurEdit = true;

      // 対象日時の治療情報取得
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndEditBase.vue', 'setDefaultTreatmentAndKur', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      // 処理終了
      if (0 === response.data.length) {
        return;
      }

      // オーダー番号に紐づく治療情報を取得
      //FNSI-6002 劉全航 start
      // response.data = response.data.filter(eleItem => {
      //   return eleItem.ordNo === this.settingData.ordNo;
      // });
      //FNSI-6002 劉全航 end

      response.data.forEach(eleItem => {
        // 重複無しフラグ
        let disDuplicateFlag = true;
        // 治療方法デフォルト値格納
        if (0 === this.structData.selectedTreat.length) {
          //mod FNSI-7116 劉全航 start
          // this.structData.selectedTreat.push(eleItem.indTreatmentCd);
          if(this.settingData.endDateEdit){
            if(this.settingData.ordNo == eleItem.ordNo){
              this.structData.selectedTreat.push(eleItem.indTreatmentCd);
            }
          }else{
            this.structData.selectedTreat.push(eleItem.indTreatmentCd);
          }
          //mod FNSI-7116 劉全航 end
        } else {
          //mod FNSI-7116 劉全航 start
          if(!this.settingData.endDateEdit){
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
          // // 重複チェック処理
          // this.structData.selectedTreat.forEach(item => {
          //   // 重複無しフラグをfalseに変更
          //   if (item === eleItem.indTreatmentCd) {
          //     disDuplicateFlag = false;
          //   }
          // });
          // // 重複がなければ格納
          // if (disDuplicateFlag) {
          //   this.structData.selectedTreat.push(eleItem.indTreatmentCd);
          // }
        }
        //mod FNSI-7116 劉全航 end

        // 重複無しフラグを初期化(true)
        disDuplicateFlag = true;

        // すでに格納されていない場合は、格納する
        if (0 === this.structData.selectedKur.length) {
          //mod FNSI-7116 劉全航 start
          if(this.settingData.endDateEdit){
            if(eleItem.ordNo == this.settingData.ordNo){
              this.structData.selectedKur.push(eleItem.indKurCd);
            }
          }else{
            this.structData.selectedKur.push(eleItem.indKurCd);
          }
          // this.structData.selectedKur.push(eleItem.indKurCd);
          //mod FNSI-7116 劉全航 end
        } else {
          //mod FNSI-7116 劉全航 start
          if(!this.settingData.endDateEdit){
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
          // // 重複チェック処理
          // this.structData.selectedTreat.forEach(item => {
          //   // 重複無しフラグをfalseに変更
          //   if (item === eleItem.indKurCd) {
          //     disDuplicateFlag = false;
          //   }
          // });
          // // 重複がなければ格納
          // if (disDuplicateFlag) {
          //   this.structData.selectedTreat.push(eleItem.indKurCd);
          // }
          //mod FNSI-7116 劉全航 end
        }
      });
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

        // 風袋・除水補正警告ダイアログ
        case 23010002:
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;

        // 風袋・除水補正反映ダイアログ
        case 13010001:
          if ("OK" === answer) {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo();
          }
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;

        case 12010001:
          if (1 !== parseInt(this.messageDialogInfo.type)) {
            if ("OK" === answer) {
              this.baseData.isSkipFlag = true;
              this.updateDisable = true;
              this.isUpdating = true;
              this.getDefaultSlotComponent().updateIndInfo(
                this.baseData
              );
            }
          }
          break;

        case 12010004:
          // 登録する予定内容に禁忌・アレルギーが含まれている場合の警告
          if (1 !== parseInt(this.messageDialogInfo.type)) {
            if ("OK" === answer) {
              this.updateDisable = true;
              this.isUpdating = true;
              this.baseData.acceptWarnFlag = true;
              this.getDefaultSlotComponent().updateIndInfo(
                this.baseData);
            }
          }
          break;
        // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
        case 12000240:
          // 重複双方とも透析状態>=3のため変更不可（12010002 相当の確認ダイアログは出さない）
          break;
        case 12010002:
          // 「対象のベッドに別の予定が存在する日があります。」
          if (1 !== parseInt(this.messageDialogInfo.type)) {
            if ("Yes" === answer) {
              //add 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 start
              this.baseData.showMessageFlg= true;
              //add 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 end
              if (6 === parseInt(this.messageDialogInfo.type)) {
                this.baseData.updateMode = "1";
              } else {
                this.baseData.updateMode = "2";
                this.baseData.isSkipFlag = true;
              }
              this.updateDisable = true;
              this.isUpdating = true;
              const childOptions = this.lastUseOrdMoveCheckApi === true ? { useOrdMoveCheckApi: true } : {};
              this.getDefaultSlotComponent().updateIndInfo(
                this.baseData,
                childOptions
              );
            }
            if ("No" === answer) {
              //add 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 start
              this.baseData.showMessageFlg= true;
              //add 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 end
              // 重複のないところのみ更新を行う
              this.baseData.updateMode = "2";
              this.updateDisable = true;
              this.isUpdating = true;
              const childOptions = this.lastUseOrdMoveCheckApi === true ? { useOrdMoveCheckApi: true } : {};
              this.getDefaultSlotComponent().updateIndInfo(
                this.baseData,
                childOptions
              );

            //add 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 start
            }else if ("Yes" != answer){
              this.baseData.showMessageFlg= false;
           //add 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 end
            }
          }
          break;

        case 12010008:
          // 指定期間に期限切れの項目が含まれていた場合の警告
          if (1 !== parseInt(this.messageDialogInfo.type)) {
            if ("OK" === answer) {
              this.updateDisable = true;
              this.isUpdating = true;
              this.baseData.chkExpiredFlag = true;
              this.getDefaultSlotComponent().updateIndInfo(
                this.baseData);
            }
          }
          break;

        case 22010006:
        case 22010007:
        case 22020003:
        // add #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou start
        // falls through
        case 22020007:
        case 22020008:
        // add #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou end
        // falls through
        case 16010001:
        // add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 start
        // falls through
        case 12000000:
        // add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 end
          this.isRefresh = true;
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
        //case "00400001":
        case 10400001:
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          if ("OK" === answer) {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo1();
          }
          break;
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
        //case "00400002":
        case 10400002:
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          if ("OK" === answer) {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("1",this.messageDialogInfo.messageCd);
          } else {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("0",this.messageDialogInfo.messageCd);
          }
          break;
        // add FNSI redmine 5161劉祥霖 start
        case 10400003:
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          if ("OK" === answer) {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("2",this.messageDialogInfo.messageCd);
          } else {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("3",this.messageDialogInfo.messageCd);
          }
          this.isUpdating = true;
          break;
        case 10400004:
          if ("OK" === answer) {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("4",this.messageDialogInfo.messageCd);
          } else {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("5",this.messageDialogInfo.messageCd);
          }
          this.isUpdating = true;
          break;
        case 10400005:
          if ("OK" === answer) {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("6",this.messageDialogInfo.messageCd);
          } else {
            // 反映処理を行う
            this.getDefaultSlotComponent().reflectIndInfo2("7",this.messageDialogInfo.messageCd);
          }
          this.isUpdating = true;
          break;
        // add FNSI redmine 5161劉祥霖 end
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
        // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
        // case "00400008":
        // case "00400009":
        // case "00400010":
        // case "00400011":
        // case "00400012":
        case 10400008:
        case 10400009:
          if ("OK" === answer) {
            this.itemMsgCd20Flg = false;
            this.getDefaultSlotComponent().updateIndInfo(this.baseData);
          }
          break;
        case 10400010:
          if ("OK" === answer) {
            this.itemMsgCd24Flg = false;
            this.getDefaultSlotComponent().updateIndInfo(this.baseData);
          }
          break;
        case 10400011:
          if ("OK" === answer) {
            this.itemMsgCd14Flg = false;
            this.getDefaultSlotComponent().updateIndInfo(this.baseData);
          }
          break;
        // mod FNSI-FutreNetWeb+SI課題管理No.5528 李 start
        case 10400012:
        // mod FNSI-FutreNetWeb+SI課題管理No.5528 李 end
          if ("OK" === answer) {
            this.itemMsgCd18Flg = false;
            this.getDefaultSlotComponent().updateIndInfo(this.baseData);
          }
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          break;
        // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
        // add FNSI-濃度プログラムチェックの追加 楊 start
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
        //case "00400007":
        case 10400007:
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          this.isRefresh = true;
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;
        // add FNSI-濃度プログラムチェックの追加 楊 end

        // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
        case 70000028:
          // 反映処理を行う
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
          //this.getDefaultSlotComponent().saveIndCondInfo(this.baseData,answer);
          if (this.isDialogType9_offWater) {
            this.getRenderedChild(this.getDefaultSlotComponent(), [0])?.getComponentData(this.structData,answer);
          } else if(this.isDialogType9_ihdf) {
            this.getRenderedChild(this.getDefaultSlotComponent(), [2])?.getComponentData(this.structData,answer);
          } else {
            this.getDefaultSlotComponent().getComponentData(this.structData,answer);
          }
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
          break;
       // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
        default:
          break;
      }
    },

    /**
     * 治療開始日の調整
     */
    // AdjustTreatStartDate(startDate) {
    //   // 期間指定での操作の場合以下の処理を実行
    //   if (!this.weekEdit) {
    //     const date = parseInt(dayjs(startDate).format("YYYYMMDD"));
    //     // 過去日制御
    //     const today = parseInt(dayjs().format("YYYYMMDD"));
    //     if (today > date) {
    //       this.structData.indStartDate = dayjs().format("YYYY-MM-DD");
    //     }
    //     // 最大値の制御
    //     const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
    //     if (date > maxDate) {
    //       this.structData.indStartDate = dayjs(this.maxDate).format(
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
      //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start
      if(treatDate === ""){
        return;
      }
      //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy end
      // 期間指定での操作の場合以下の処理を実行
      if (!this.weekEdit) {
        const date = parseInt(dayjs(treatDate).format("YYYYMMDD"));
        // 過去日制御
        let today;
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
        // if (startDate) {
        //   today = parseInt(dayjs().format("YYYYMMDD"));
        // }else{
        today = parseInt(dayjs(this.structData.indStartDate).format("YYYYMMDD"));
        // }
        // if (today > date) {
        //   if (startDate) {
        //     this.structData.indStartDate = dayjs().format("YYYY-MM-DD");
        //   }else{
        //     this.structData.indEndDate = dayjs(this.structData.indStartDate).format("YYYY-MM-DD");
        //   }
        // }else{
        if (startDate) {
          this.structData.indStartDate = dayjs(treatDate).format("YYYY-MM-DD");
        }else{
          this.structData.indEndDate = dayjs(treatDate).format("YYYY-MM-DD");
        }
        // }
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
        // 最大値の制御
        const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
        if (date > maxDate) {
          if (startDate) {
            this.structData.indStartDate = dayjs(this.maxDate).format("YYYY-MM-DD");
          }else{
            this.structData.indEndDate = dayjs(this.maxDate).format("YYYY-MM-DD");
          }
        }
      }
      // Storeに開始日(初回投与日)を保存
      this.setIndStartDate(this.structData.indStartDate);
    },
      // mod 8560 開始日の日付のキーボード入力が不正 張 end

    /**
     * @description 未来日の治療種別を設定(未来日の治療種別引き継ぐ)
     */
    async setTreatTypeInfo() {
      // データ取得条件の格納
      const ordMainList = await this.ordMainList();

      if (!ordMainList) {
        // add #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng start
        this.isSetedCycleWeek = false;
        if (this.cycleWeek !== "1") {
          this.disabledWeekdays = [];
        }
        // add #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng end
        return;
      }

      const hasTreatTypeOrd = this.getTreatTypeOrd(ordMainList);

      // 治療種別：変更不可へ
      this.isSetedCycleWeek = hasTreatTypeOrd
        // #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng start
        // ? hasTreatTypeOrd.treatType
        ? true
        // #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng end
        : false;

      if (this.isSetedCycleWeek) {
        // #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng start
        // this.setTreatType(hasTreatTypeOrd.treatType);
        this.setTreatType(1);
        this.disabledWeekdays = [];
        // #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng end
      }
    },

    /**
     * @description 指示リスト取得
     */
    async ordMainList() {
      this.startLoadingScreen();

      // データ取得条件の格納
      const paramJson = {
        // 施設コード
        facility_cd: this.structData.facilityCd,
        // 患者ID
        pat_id: this.structData.patId,
        // 治療開始日
        // mod 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start
        // ind_start_date: dayjs().format("YYYY-MM-DD"),
        ind_start_date: dayjs(this.structData.indStartDate).format("YYYY-MM-DD"),
        // 治療終了日
        // ind_end_date:"9999-12-31",
        ind_end_date: dayjs(this.structData.indEndDate).format("YYYY-MM-DD")!="Invalid date"?dayjs(this.structData.indEndDate).format("YYYY-MM-DD"): "9999-12-31",
        // mod 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start
        // 曜日パターン
        week_pattern: "[{'text': '全','done': false,'value': 0}]"
      };
      // データの取得
      const response = await ApiHelper.post(
        `/mainData/TreatDateList`,
        paramJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add startupdateIndInfo
        getErrorMessage('IndEditBase.vue', 'ordMainList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      })
      .finally(() => {
        this.finishLoadingScreen();
      });
      return response.data.length === 0 ? null : response.data;
    },

    /**
     * @description 治療種別が1日以外の指示取得
     */
    getTreatTypeOrd(ordMainList) {
      // del 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start
      //mod FNSI no.5785 劉全航 start
      // let newStartDate = dayjs(this.settingData.startDate);
      // let endDate = dayjs(String(ordMainList[ordMainList.length-1].treatDate));
      // let startDate = dayjs(String(ordMainList[0].treatDate));
      // if(newStartDate.isAfter(endDate)||newStartDate.isBefore(startDate) ){
      //   return;
      // }
      //mod FNSI no.5785 劉全航 end
      // del 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 end
      const ordMain = ordMainList.find(
        // #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng start
        // ord => ord.treatType === 1 || ord.treatType === 2 || ord.treatType === 3
        ord => ord.rstDialysisState === "0"
        // #10266 予定作成モーダルで隔日/隔週のボタンが非活性となる。 linjunfeng end
        );
      return ordMain;
    },

    /**
     * @description 治療種別を設定
     */
    setTreatType(treatType) {
      // TODO: 治療種別「通常・隔日・隔週」差異あり。「画面："0", "1", "2"」「サーバー：1, 2, 3」
      if (treatType === 1) {
        this.structData.cycleWeek = "0";
      } else if (treatType === 2) {
        // 隔日
        this.structData.cycleWeek = "1";
        if (this.settingData.showSegment) {
          // 治療種別が選択できるなら
          // カレンダの日付を制御
          this.changeDialSegment("1");
        }
      } else if (treatType === 3) {
        // 隔週
        this.structData.cycleWeek = "2";
        if (this.settingData.showSegment) {
          this.changeDialSegment("2");
        }
      }
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
        this.structData.selectedTreat);

      // 対象日時の治療情報取得(日付・曜日・治療方法・クールで絞り込み)
      const response = await ApiHelper.post(
        "/mainData/treatDateList",
        paramJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndEditBase.vue', 'getTreatDateList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      this.treatDateListAll = response.data.map(({ treatDate }) => treatDate);
    },
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
    // 装置設定の内容の表示設定
    async showOhdfComment() {
      if (this.isIndActionChart) {
        const component = await this.getDefaultSlotComponentAfterRender();
        component?.reflectCommentShow(this.structData);
      }
    },

    // 装置設定の内容取得
    async getDeviceSetInfoInd() {
      if (this.isIndActionChart) {
        const component = await this.getDefaultSlotComponentAfterRender();
        component?.getDeviceSetInfoPatOrd(this.settingData);
      }
    },
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
    //add FNSI-No.IES145 権限対応  吉 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    //add FNSI-No.IES145 権限対応  吉 end
    //#9311 2023-09-12 shyw : Used to solve the bug of kendo-multiselect about @change  start
    syncValToSelectedTreat(event){
      this.structData.selectedTreat = event.sender._old;
    },
    syncValToSelectedKur(event){
      this.structData.selectedKur = event.sender._old;
    },
    //#9311 2023-09-12 shyw : Used to solve the bug of kendo-multiselect about @change  end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    setInitStructData(){
      this.initStructData = JSON.parse(JSON.stringify(this.structData));
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end

    /**
     * 医療材料新規登録／編集画面の子コンポーネントの入力値に禁忌・アレルギータグが含まれているかを判定し、
     * 判定結果（true/false）をストアのtabooEquipmentに設定する。
     */
    checkEquipmentTabooAllergy() {
      this.setTabooEquipment(false);
      const comp = this.getDefaultSlotComponent();
      if (!comp) {
        return;
      }

      if (Object.prototype.hasOwnProperty.call(comp, 'segmentValue')) {
        // 医療材料編集画面
        if (comp.segmentValue == 0) {
          // 編集時のみ入力値チェックを行い、中止時はチェックを行わない
          const name = comp.$refs.equipEdit?.equipmentInputValue?.editValue;
          const tabooAllergyFlag = containsTabooAllergyTag(name);
          this.setTabooEquipment(tabooAllergyFlag);
        }

      } else {
        // 医療材料新規登録画面
        if (comp.listData) {
          const data = comp.listData;
          let tabooAllergyFlag = false;

          for (let item of data) {
            if (item.id && comp.$refs[item.id]) {
              const name = comp.$refs[item.id][0]?.equipmentInputValue?.editValue;
              tabooAllergyFlag = containsTabooAllergyTag(name);
              if (tabooAllergyFlag) break;
            }
          }
          this.setTabooEquipment(tabooAllergyFlag);
        }
      }
    },

    /** カレンダーから開始日を選択した際の処理 */
    onCalendarIndStartDateInput(date) {
      if (!date) {
        return;
      }
      this.AdjustTreatStartDate(date, true);
      this.createKurAndTreatmentList();
    },

    /** カレンダーから終了日を選択した際の処理 */
    onCalendarIndEndDateInput(date) {
      if (!date) {
        return;
      }
      this.AdjustTreatStartDate(date, false);
      this.createKurAndTreatmentList();
    },

    /** 開始日・終了日フォーカスアウト時の処理 */
    onBlurDate(date, field) {
      // 値変更なし
      if (this.beforeDate === date) {
        return;
      }

      this.createKurAndTreatmentList();

      // calendarIndStartDate・calendarIndEndDate変更時のwatchに処理を任せる
      if (field === "indStartDate") {
        this.AdjustTreatStartDate(date, true);
        this.calendarIndStartDate = date;
      }
      if (field === "indEndDate") {
        this.AdjustTreatStartDate(date, false);
        this.calendarIndEndDate = date;
      }
    },

    /**
     * 子コンポーネントの入力値に禁忌・アレルギータグが含まれているかを判定し、
     * 判定結果（true/false）をストアのtabooEquipmentに設定する。
     * ※コンポーネントが共通利用されている事情により、薬剤か？医療材料か？の判定はせず、tabooEquipmentを利用する。
     */
    checkTabooAllergy() {
      this.setTabooEquipment(false);
      const comp = this.getDefaultSlotComponent();
      if (!comp) {
        return;
      }

      let tabooAllergyFlag = false;

      for (const key of Object.keys(comp.$refs)) {
        if (Array.isArray(comp.$refs[key])) {
          const name = comp.$refs[key][0]?.displayInputValue?.editValue;
          tabooAllergyFlag = containsTabooAllergyTag(name);
          if (tabooAllergyFlag) break;
        }
      }
      this.setTabooEquipment(tabooAllergyFlag);
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

.scroll-style :deep(ons-row) {
  height: auto;
}

.scroll-style :deep(.device-info-content-area) {
  padding: 0;
}

.slot-style {
  padding: 5px 10px;
  overflow-y: auto;
  /* del FNSI-4176 小窓表示の際に縦のスクロールバーが2本になる dou start */
  /* margin-bottom: 10px; */
  /* del FNSI-4176 小窓表示の際に縦のスクロールバーが2本になる dou end */
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

.identification:disabled + .group-label {
  opacity: 0.3;
  cursor: default;
  pointer-events: none;
}

.first-of-type {
  border-radius: 10px 0 0 10px;
}

.last-of-type {
  border-radius: 0 10px 10px 0;
}

/*mod FNSI-画面部品デザイン じょはく start*/
.onColor:checked + label {
  background-color: #9acd32;
  color: black;
}
/*mod FNSI-画面部品デザイン じょはく end*/
.onColor:disabled + span {
  opacity: 0.5;
}

.hr-style {
  margin: 0px 10px;
}
/* mod FNSI-横展開-inputの色 関 start*/
/* 開始日・終了日inputタブ
.date-input {
  width: calc(100% - 32px);
  padding-right: 2px !important;
} */
.date-start-input{
  width: calc(100% - 32px);
  padding-right: 2px !important;
}
.date-start-input[disabled]{
  width: calc(100% - 32px);
  padding-right: 2px !important;
}
.date-end-input{
  width: calc(100% - 32px);
  padding-right: 2px !important;
}
.date-end-input[disabled]{
  width: calc(100% - 32px);
  padding-right: 2px !important;
  color: #999;
}
/*FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add start*/
.date-start-input-ios{
  width: 120px;
  padding-right: 2px !important;
}
.date-end-input-ios{
  width: 120px;
  padding-right: 2px !important;
}
/*FNSI-修正 【患者経過総合ビューア】→【予定作成】iPadの日付コンポ改修、chromeと一緒 xugj add end*/
/* mod FNSI-横展開-inputの色 関 end*/
input::-webkit-calendar-picker-indicator {
  display: none;
}

.update-modal {
  font-size: 30px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 100px;
  padding-top: 8px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */

@media print {
  .slot-style {
    padding: 0px 5px !important;
  }
  .slot-style :deep(.device-info-cell-value) {
    margin: 1px;
  }
}
</style>

<style>
@media print {
  body:has(.modal-mask) .div-style {
    padding: 0px 10px !important;
  }
  body:has(.device-info-content) div .modal-wrapper {
    margin-top: 1vh !important;
  }
}

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
/* add FNSI- 障害票一覧_患者経過総合ビューア.xlsxのNo.82(外結)対応 韓 start */
.select-style-list > span {
  background-color: #ffff99 !important;
}
/* add FNSI- 障害票一覧_患者経過総合ビューア.xlsxのNo.82(外結)対応 韓 end */
</style>
