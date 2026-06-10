<template>
  <!-- add FNSI-コントロールの削除 徐 start -->
  <!-- <div v-if="!getUpdateMode class="tab-main-content"> -->
  <div v-if="!getUpdateMode && !getPatEventFlg" class="tab-main-content">
    <!--https://ja.onsen.io/v2/api/js/ons-popover.html add FNSI-コントロールの削除 徐 end -->
    <!--新規登録：利用種別：紹介状以外-->
    <div
      class="tabs"
      v-if="
        this.$router.currentRoute.name !== 'pat-intro-letter' &&
        getPatEventRecord.useType !== 3
      "
    >
      <input
        id="check1"
        type="radio"
        name="tab_item"
        checked
        @click="changeTabSelect(1)"
      />
      <label class="tab_item" for="check1">１回限り</label>
      <input
        id="check2"
        type="radio"
        name="tab_item"
        @click="changeTabSelect(2)"
      />
      <label class="tab_item" for="check2">毎日</label>
      <input
        id="check3"
        type="radio"
        name="tab_item"
        @click="changeTabSelect(3)"
      />
      <label class="tab_item" for="check3">毎週</label>
      <input
        id="check4"
        type="radio"
        name="tab_item"
        @click="changeTabSelect(4)"
      />
      <label class="tab_item" for="check4">毎月</label>
      <!-- １回限りタブ -->
      <div class="tab_content" id="tab1_content">
        <div class="flex-wrap-div">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">開始日時</label>
            </div>
            <!-- <div class="flex-align-center"> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.dayStartDate"
                class="input_date ntss-input-date"
              /> -->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.dayStartDate"
                class="input_date ntss-input-date event-start-date"
              /> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
            <!-- <common-calendar v-model="inputModel.dayStartDate" @input="changeCondition(1)" /> -->
            <!-- </div> -->
            <!-- mod No.18 付 start -->
            <!--#10715:日付IF修正Start-->
            <input-datatemp
              :dateMin="dateMin"
              :dateMax="dateMax"
              :data.sync="inputModel.dayStartDate"
              :className="'event-start-date'"
              :functionArgs="1"
              :tempName="'tabTemp'"
              :isRequired="true"
            >
            </input-datatemp>
            <!--#10715:日付IF修正End-->
            <!-- mod No.18 付 end -->
            <div style="margin-left: 1em">
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                v-model="inputModel.dayStartTime"
                class="input_date"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.dayStartTime"
                @handleClearInput="inputModel.dayStartTime = null"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">終了時刻</label>
            </div>
            <div>
              <v-ons-select
                class="select"
                v-model="inputModel.dayDateClass"
                @change="changeCondition(1)"
              >
                <option
                  v-for="(item, index) in selectDays"
                  :key="index"
                  :value="item.code"
                  style="color: black"
                >
                  {{ item.name }}
                </option>
              </v-ons-select>
            </div>
            <div style="margin-left: 1em">
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                class="input_date"
                v-model="inputModel.dayEndTime"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.dayEndTime"
                @handleClearInput="inputModel.dayEndTime = null"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
        </div>
      </div>
      <!-- 毎日タブ -->
      <div class="tab_content" id="tab2_content">
        <div class="flex-wrap-div">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">開始日付</label>
            </div>
            <!-- <div class="flex-align-center"> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.everyStartDate"
                class="input_date ntss-input-date"
              /> -->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.everyStartDate"
                class="input_date ntss-input-date every-start-date"
              /> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
            <!-- <common-calendar v-model="inputModel.everyStartDate" @input="changeCondition(2)" /> -->
            <!-- </div> -->
            <!-- mod No.18 付 start -->
            <!--#10715:日付IF修正Start-->
            <input-datatemp
              :dateMin="dateMin"
              :dateMax="dateMax"
              :data.sync="inputModel.everyStartDate"
              :className="'every-start-date'"
              :functionArgs="2"
              :tempName="'tabTemp'"
              :isRequired="true"
              @blur="invalidchk()"
            >
            </input-datatemp>
            <!--#10715:日付IF修正End-->
            <!-- mod No.18 付 end -->
            <div class="label" style="margin-left: 1em">
              <label class="ntss-pat-event-label">～</label>
            </div>
          </div>
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">終了日付</label>
            </div>
            <!-- <div class="flex-align-center"> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.everyEndDate"
                class="input_date ntss-input-date"
              /> -->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.everyEndDate"
                class="input_date ntss-input-date every-end-date"
              /> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
            <!-- <common-calendar v-model="inputModel.everyEndDate" @input="changeCondition(2)" /> -->
            <!-- </div> -->
            <!-- mod No.18 付 start -->
            <!--#10715:日付IF修正Start-->
            <input-datatemp
              :dateMin="dateMin"
              :dateMax="dateMax"
              :data.sync="inputModel.everyEndDate"
              :className="'every-end-date'"
              :functionArgs="2"
              :tempName="'tabTemp'"
              :isRequired="true"
              @blur="invalidchk()"
            >
            </input-datatemp>
            <!--#10715:日付IF修正End-->
            <!-- mod No.18 付 end -->
          </div>
        </div>
        <div class="flex-wrap-div flex-div-mt">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">開始時刻</label>
            </div>
            <div>
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                v-model="inputModel.everyStartTime"
                class="input_date"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.everyStartTime"
                @handleClearInput="inputModel.everyStartTime = null"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">終了時刻</label>
            </div>
            <div>
              <v-ons-select
                class="select"
                v-model="inputModel.everyDateClass"
                @change="changeCondition(2)"
              >
                <option
                  v-for="(item, index) in selectDays"
                  :key="index"
                  :value="item.code"
                  style="color: black"
                >
                  {{ item.name }}
                </option>
              </v-ons-select>
            </div>
            <div style="margin-left: 1em">
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                class="input_date"
                v-model="inputModel.everyEndTime"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.everyEndTime"
                @handleClearInput="inputModel.everyEndTime = null"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
        </div>
      </div>
      <!-- 毎週タブ -->
      <div class="tab_content" id="tab3_content">
        <div class="flex-wrap-div">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">開始日付</label>
            </div>
            <!-- <div class="flex-align-center"> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!--<input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.weekStartDate"
                class="input_date ntss-input-date"
              />-->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.weekStartDate"
                class="input_date ntss-input-date week-start-date"
              /> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 ebd-->
            <!-- <common-calendar v-model="inputModel.weekStartDate" @input="changeCondition(3)" /> -->
            <!-- </div> -->
            <!-- mod No.18 付 start -->
            <!--#10715:日付IF修正Start-->
            <input-datatemp
              :dateMin="dateMin"
              :dateMax="dateMax"
              :data.sync="inputModel.weekStartDate"
              :className="'week-start-date'"
              :functionArgs="3"
              :tempName="'tabTemp'"
              :isRequired="true"
              @blur="invalidchk()"
            >
            </input-datatemp>
            <!--#10715:日付IF修正End-->
            <!-- mod No.18 付 end -->
            <div class="label" style="margin-left: 1em">
              <label class="ntss-pat-event-label">～</label>
            </div>
          </div>
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">終了日付</label>
            </div>
            <!-- <div class="flex-align-center"> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!--<input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.weekEndDate"
                class="input_date ntss-input-date"
              />-->
            <!-- <input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.weekEndDate"
                class="input_date ntss-input-date week-end-date"
              /> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
            <!-- <common-calendar v-model="inputModel.weekEndDate" @input="changeCondition(3)" /> -->
            <!-- </div> -->
            <!-- mod No.18 付 start -->
            <!--#10715:日付IF修正Start-->
            <input-datatemp
              :dateMin="dateMin"
              :dateMax="dateMax"
              :data.sync="inputModel.weekEndDate"
              :className="'week-end-date'"
              :functionArgs="3"
              :tempName="'tabTemp'"
              :isRequired="true"
              @blur="invalidchk()"
            >
            </input-datatemp>
            <!--#10715:日付IF修正End-->
            <!-- mod No.18 付 end -->
          </div>
        </div>
        <div class="flex-wrap-div flex-div-mt">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">間隔</label>
            </div>
            <div>
              <!--mod FNSI-改修内容6284 任 start-->
              <!-- <input
                :min="timesMin"
                :max="timesMax"
                type="number"
                v-model="inputModel.weekIntervalDay"
                class="input"
              />-->
              <input
                :min="timesMin"
                :max="timesMax"
                type="number"
                oninput="value = value.replace('-','')"
                v-model="inputModel.weekIntervalDay"
                @blur="handleBlur"
                class="input"
              />
              <!--mod FNSI-改修内容6284 任 end-->
            </div>
            <div class="label" style="margin-left: 1em">
              <label class="ntss-pat-event-label">週間空ける</label>
            </div>
          </div>
        </div>
        <div class="flex-nowrap-div flex-div-mt">
          <div>
            <div class="label title">
              <label class="ntss-pat-event-label">曜日</label>
            </div>
          </div>
          <div style="display: flex; flex-wrap: wrap">
            <label class="ntss-pat-event-label" style="margin-right: 1em">
              <v-ons-checkbox
                input-id="check-1"
                class="input"
                v-model="inputModel.week[0]"
                @change="changeWeek(0, $event)"
              ></v-ons-checkbox>
              日曜日
            </label>
            <label class="ntss-pat-event-label" style="margin-right: 1em">
              <v-ons-checkbox
                input-id="check-2"
                class="input"
                v-model="inputModel.week[1]"
                @change="changeWeek(1, $event)"
              ></v-ons-checkbox>
              月曜日
            </label>
            <label class="ntss-pat-event-label" style="margin-right: 1em">
              <v-ons-checkbox
                input-id="check-3"
                class="input"
                v-model="inputModel.week[2]"
                @change="changeWeek(2, $event)"
              ></v-ons-checkbox>
              火曜日
            </label>
            <label class="ntss-pat-event-label" style="margin-right: 1em">
              <v-ons-checkbox
                input-id="check-4"
                class="input"
                v-model="inputModel.week[3]"
                @change="changeWeek(3, $event)"
              ></v-ons-checkbox>
              水曜日
            </label>
            <label class="ntss-pat-event-label" style="margin-right: 1em">
              <v-ons-checkbox
                input-id="check-5"
                class="input"
                v-model="inputModel.week[4]"
                @change="changeWeek(4, $event)"
              ></v-ons-checkbox>
              木曜日
            </label>
            <label class="ntss-pat-event-label" style="margin-right: 1em">
              <v-ons-checkbox
                input-id="check-6"
                class="input"
                v-model="inputModel.week[5]"
                @change="changeWeek(5, $event)"
              ></v-ons-checkbox>
              金曜日
            </label>
            <label class="ntss-pat-event-label" style="margin-right: 1em">
              <v-ons-checkbox
                input-id="check-7"
                class="input"
                v-model="inputModel.week[6]"
                @change="changeWeek(6, $event)"
              ></v-ons-checkbox>
              土曜日
            </label>
          </div>
        </div>
        <div class="flex-wrap-div flex-div-mt">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">開始時刻</label>
            </div>
            <div>
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                v-model="inputModel.weekStartTime"
                class="input_date"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.weekStartTime"
                @handleClearInput="inputModel.weekStartTime = null"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">終了時刻</label>
            </div>
            <div>
              <v-ons-select
                class="select"
                v-model="inputModel.weekDateClass"
                @change="changeCondition(3)"
              >
                <option
                  v-for="(item, index) in selectDays"
                  :key="index"
                  :value="item.code"
                  style="color: black"
                >
                  {{ item.name }}
                </option>
              </v-ons-select>
            </div>
            <div style="margin-left: 1em">
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                class="input_date"
                v-model="inputModel.weekEndTime"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.weekEndTime"
                @handleClearInput="inputModel.weekEndTime = null"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
        </div>
      </div>
      <!-- 毎月タブ -->
      <div class="tab_content" id="tab4_content">
        <div class="flex-wrap-div">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">開始日付</label>
            </div>
            <!-- mod No.18 付 start -->
            <!--#10715:日付IF修正Start-->
            <input-datatemp
              :dateMin="dateMin"
              :dateMax="dateMax"
              :data.sync="inputModel.monthStartDate"
              :className="'month-start-date'"
              :functionArgs="4"
              :tempName="'tabTemp'"
              :isRequired="true"
              @blur="invalidchk()"
            >
            </input-datatemp>
            <!--#10715:日付IF修正End-->
            <!-- mod No.18 付 end -->
            <div class="label" style="margin-left: 1em">
              <label class="title ntss-pat-event-label">～</label>
            </div>
          </div>
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">終了日付</label>
            </div>
            <!-- mod No.18 付 start -->
            <!--#10715:日付IF修正Start-->
            <input-datatemp
              :dateMin="dateMin"
              :dateMax="dateMax"
              :data.sync="inputModel.monthEndDate"
              :className="'month-end-date'"
              :functionArgs="4"
              :tempName="'tabTemp'"
              :isRequired="true"
              @blur="invalidchk()"
            >
            </input-datatemp>
            <!--#10715:日付IF修正End-->
            <!-- mod No.18 付 end -->
          </div>
        </div>
        <div class="flex-nowrap-div flex-div-mt">
          <div>
            <div class="label title">
              <label class="ntss-pat-event-label">月</label>
            </div>
          </div>
          <div style="display: flex; flex-wrap: wrap">
            <label v-for="(month, index) in 12" :key="month" class="ntss-pat-event-label month-label">
              <ons-checkbox
                :input-id="'check-' + month"
                class="input"
                v-model="inputModel.month[index]"
                @change="changeMonth(index, $event)"
              ></ons-checkbox>
              {{ index + 1 }}月
            </label>
          </div>
        </div>
        <div class="flex-wrap-div flex-div-mt">
          <div>
            <div class="label title">
              <label class="ntss-pat-event-label"></label>
            </div>
          </div>
          <div style="display: flex; flex-wrap: wrap">
            <label class="round-label ntss-pat-event-label">
              <v-ons-radio
                value="0"
                input-id="day-week"
                modifier="round"
                v-model="dayAndDateSpecification"
                @change="changeDayAndDateCondition($event)"
              ></v-ons-radio>
              曜日指定
            </label>
            <label class="round-label ntss-pat-event-label">
              <v-ons-radio
                value="1"
                input-id="date-specification"
                modifier="round"
                v-model="dayAndDateSpecification"
                @change="changeDayAndDateCondition($event)"
              ></v-ons-radio>
              日付指定
            </label>
          </div>
        </div>
        <!-- 日付指定 -->
        <div
          class="flex-wrap-div flex-div-mt"
          v-if="dayAndDateSpecification === '1'"
        >
          <!--mod FNSI-改修内容毎月と日付指定パターンで、日も固定文字と入力テキストの位置が逆になってしまう 任 start-->
          <!--<label class="title ntss-pat-event-label">日&emsp;</label>
          <input
            :min="dayMin"
            :max="dayMax"
            type="number"
            v-model="inputModel.monthIntervalDay"
            class="input"
          />-->
          <div>
            <div class="label title">
              <label class="ntss-pat-event-label"></label>
            </div>
          </div>
          <input
            :min="dayMin"
            :max="dayMax"
            type="number"
            @blur="blurInput()"
            v-model="inputModel.monthIntervalDay"
            class="input"
          />
          <label class="ntss-pat-event-label label" style="margin-left: 1em"
            >日</label
          >
          <!--mod FNSI-改修内容毎月と日付指定パターンで、日も固定文字と入力テキストの位置が逆になってしまう 任 end-->
        </div>
        <!-- 曜日指定 -->
        <div class="flex-wrap-div flex-div-mt" v-else>
          <div>
            <div class="label title">
              <label class="ntss-pat-event-label"></label>
            </div>
          </div>
          <label class="ntss-pat-event-label label">第</label>
          <v-ons-select
            class="select"
            style="margin-left: 1em"
            v-model="inputModel.monthIntervalWeek"
            @change="changeCondition(4)"
          >
            <option
              v-for="(item, index) in selectWeek"
              :key="index"
              :value="item.code"
              style="color: black"
            >
              {{ item.name }}
            </option>
          </v-ons-select>
          <v-ons-select
            class="select"
            style="margin-left: 1em"
            v-model="inputModel.monthIntervalDateOfWeek"
            @change="changeCondition(4)"
          >
            <option
              v-for="(item, index) in selectDayOfWeek"
              :key="index"
              :value="item.code"
              style="color: black"
            >
              {{ item.name }}
            </option>
          </v-ons-select>

          <label class="ntss-pat-event-label label" style="margin-left: 1em"
            >曜日</label
          >
        </div>

        <div class="flex-wrap-div flex-div-mt">
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">開始時刻</label>
            </div>
            <div>
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                v-model="inputModel.monthStartTime"
                class="input_date"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.monthStartTime"
                @handleClearInput="inputModel.monthStartTime = null"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
          <div class="flex-div">
            <div class="label title">
              <label class="ntss-pat-event-label">終了時刻</label>
            </div>
            <div>
              <v-ons-select
                class="select"
                v-model="inputModel.monthDateClass"
                @change="changeCondition(4)"
              >
                <option
                  v-for="(item, index) in selectDays"
                  :key="index"
                  :value="item.code"
                  style="color: black"
                >
                  {{ item.name }}
                </option>
              </v-ons-select>
            </div>
            <div style="margin-left: 1em">
              <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
              <!-- <input
                type="time"
                pattern="\d*"
                class="input_date"
                v-model="inputModel.monthEndTime"
              /> -->
              <time-input
                pattern="\d*"
                v-model="inputModel.monthEndTime"
                @handleClearInput="inputModel.monthEndTime = null"
              /><!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- add FNSI-コントロールの削除 徐 start -->
  <!--tab切替以外-->
  <div v-else-if="getPatEventFlg" class="tab-main-content">
    <div class="tab_content_dummy">
      <div class="flex-wrap-div">
        <!--新規登録-->
        <div v-if="!getUpdateMode" class="flex-div">
          <div class="label title">
            <label class="ntss-pat-event-label">開始日時</label>
          </div>
          <div class="flex-align-center">
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!--<input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.dayStartDate"
                class="input_date ntss-input-date"
              />-->
            <!--mod FNSI-改修内容6186 任 start-->
            <!--<input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="inputModel.dayStartDate"
                class="input_date ntss-input-date day-start-date"
              />
              &lt;!&ndash;mod FNSI-改修内容日付のチェックの追加対応。 任 end&ndash;&gt;
              <common-calendar v-model="inputModel.dayStartDate" />-->
            <!--#10715:日付IF修正Start-->
            <date-input
              type="date"
              :min="dateMin"
              :max="dateMax"
              :is-required="true"
              v-model="inputModel.dayStartDate"
              class="input_date ntss-input-date day-start-date"
              :classes="'input-area ntss-input-date ntss-custom-input ntss-input-start-date date-input-required '"
              @focus="onFocusInStartDate"
              @input="onInputStartDate"
              @blur="onFocusOutStartDate(1)"
            />
            <!--#10715:日付IF修正End-->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!--<common-calendar
              v-model="inputModel.dayStartDate"
              @input="changeConditionSee(1)"
            />-->
            <common-calendar
              v-model="inputModel.dayStartDate"
              @input="changeConditionSee(1)"
              :disabled="
                !getItemAuthorized('PatEvent', 'default_authority')
              "
            />
            <!-- mod #10359 編集権限の動作不正 end -->
            <!--mod FNSI-改修内容6186 任 end-->
          </div>
          <div style="margin-left: 1em">
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
            <!-- <input
                type="time"
                pattern="\d*"
                v-model="inputModel.dayStartTime"
                class="input_date"
              /> -->
            <time-input
              pattern="\d*"
              v-model="inputModel.dayStartTime"
              @handleClearInput="inputModel.dayStartTime = null"
              @blur="onFocusOutStartTime"
            />
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
          </div>
        </div>
        <!--編集・削除（利用種別：通常、VA以外で作成したカテゴリ）-->
        <div v-else class="flex-div">
          <div class="label title">
            <label class="ntss-pat-event-label">開始日時</label>
          </div>
          <!-- mod FNSI-共有を追加 王 20200921 start -->
          <div class="flex-align-center">
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!--<input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="eventStartDate"
                :disabled="!isShared"
                class="input_date ntss-input-date"
              />-->
            <!--mod FNSI-改修内容6186 任 start-->
            <!--<input
                type="date"
                :min="dateMin"
                :max="dateMax"
                v-model="eventStartDate"
                :disabled="!isShared"
                class="input_date ntss-input-date event-start-date"
              />
              &lt;!&ndash;mod FNSI-改修内容日付のチェックの追加対応。 任 end&ndash;&gt;
              <common-calendar v-model="eventStartDate" :disabled="!isShared"/>-->
              <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 start -->
              <!-- <input
              type="date"
              :min="dateMin"
              :max="dateMax"
              v-model="eventStartDate"
              :disabled="!isShared"
              class="input_date ntss-input-date event-start-date"
              @focus="onFocusInStartDate"
              @input="onInputStartDate"
              @blur="onFocusOutStartDate(2)"
            /> -->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!-- <input
              type="date"
              :min="dateMin"
              :max="dateMax"
              v-model="eventStartDate"
              :disabled="
                !isShared ||
                getViewMode 
              "
              class="input_date ntss-input-date event-start-date"
              @focus="onFocusInStartDate"
              @input="onInputStartDate"
              @blur="onFocusOutStartDate(2)"
            /> -->
            <!--#10715:日付IF修正Start-->
            <date-input
              type="date"
              :min="dateMin"
              :max="dateMax"
              :is-required="true"
              v-model="eventStartDate"
              :disabled="
                !isShared ||
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority') ||
                getIsOtherFacility ||
                getIsOtherFacilitys
              "
              class="input_date ntss-input-date event-start-date"
              :classes="'input-area ntss-input-date ntss-custom-input ntss-input-start-date date-input-required '"
              @focus="onFocusInStartDate"
              @input="onInputStartDate"
              @blur="onFocusOutStartDate(2)"
            />
            <!--#10715:日付IF修正End-->
            <!-- mod #10359 編集権限の動作不正 end -->
            <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 end -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
            <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 start -->
            <!-- <common-calendar
              v-model="eventStartDate"
              :disabled="!isShared"
              @input="changeConditionSee(2)"
            /> -->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!--<common-calendar
              v-model="eventStartDate"
              :disabled="
                !isShared ||
                getViewMode 
              "
              @input="changeConditionSee(2)"
            /> -->
            <common-calendar
              v-model="eventStartDate"
              :disabled="
                !isShared ||
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority') ||
                getIsOtherFacility ||
                getIsOtherFacilitys
              "
              @input="changeConditionSee(2)"
            />
            <!-- mod #10359 編集権限の動作不正 end -->
            <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 end -->
            <!--mod FNSI-改修内容6186 任 end-->
          </div>
          <!-- mod FNSI-共有を追加 王 20200921 end -->
          <div style="margin-left: 1em">
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
            <!-- mod FNSI-共有を追加 王 20200921 start -->
            <!-- <input
                type="time"
                pattern="\d*"
                v-model="eventStartTime"
                class="input_date"
                :disabled="!isShared"
              /> -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 start -->
            <!-- <time-input
              pattern="\d*"
              v-model="eventStartTime"
              :disabled="!isShared"
              @handleClearInput="eventStartTime = null"
            /> -->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!--<time-input
              pattern="\d*"
              v-model="eventStartTime"
              :disabled="
                !isShared ||
                getViewMode 
              "
              @handleClearInput="eventStartTime = null"
            />-->
            <time-input
              pattern="\d*"
              v-model="eventStartTime"
              :disabled="
                !isShared ||
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority') ||
                getIsOtherFacility ||
                getIsOtherFacilitys
              "
              @handleClearInput="eventStartTime = null"
            />
	    <!-- mod #10359 編集権限の動作不正 end -->
            <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 end -->
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
          </div>
        </div>
      </div>
    </div>
  </div>
  <!-- add FNSI-コントロールの削除 徐 end -->
  <!--上記以外：編集・削除（利用種別：通常、VAで作成したカテゴリ）-->
  <div v-else class="tab-main-content">
    <div class="tab_content_dummy">
      <div class="flex-wrap-div">
        <div class="flex-div">
          <div class="label title">
            <label class="ntss-pat-event-label">開始日時</label>
          </div>
          <div>
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!--<input
              type="date"
              :min="dateMin"
              :max="dateMax"
              v-model="eventStartDate"
              :disabled="getViewMode"
              class="input_date"
            />-->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!-- <input
              type="date"
              :min="dateMin"
              :max="dateMax"
              v-model="eventStartDate"
              :disabled="
                getViewMode 
              "
              class="input_date event-start-date"
              @blur="changeCondition(1)"
            />-->
            <!--#10715:日付IF修正Start-->
            <date-input
              type="date"
              :min="dateMin"
              :max="dateMax"
              :is-required="true"
              v-model="eventStartDate"
              :disabled="
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority')
              "
              class="input_date event-start-date"
              :classes="'input-area ntss-input-date ntss-custom-input ntss-input-start-date date-input-required '"
              @blur="changeCondition(1)"
            />
            <!--#10715:日付IF修正End-->
            <!-- mod #10359 編集権限の動作不正 end -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
          </div>
          <!-- add #11389 患者イベントの編集での不正　V1.1A linjunfeng start -->
          <div>
            <common-calendar
              v-model="eventStartDate"
              :disabled="
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority')
              "
              @blur="changeCondition(1)"
            />
          </div>
          <!-- add #11389 患者イベントの編集での不正　V1.1A linjunfeng end -->
          <div style="margin-left: 1em">
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
            <!-- <input
              type="time"
              pattern="\d*"
              v-model="eventStartTime"
              :disabled="getViewMode"
              class="input_date"
            /> -->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!--<time-input
              pattern="\d*"
              v-model="eventStartTime"
              :disabled="
                getViewMode 
              "
              @handleClearInput="eventStartTime = null"
            /> -->
            <time-input
              pattern="\d*"
              v-model="eventStartTime"
              :disabled="
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority')
              "
              @handleClearInput="eventStartTime = null"
            />
	    <!-- mod #10359 編集権限の動作不正 end -->
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
          </div>
        </div>
        <div class="flex-div">
          <div class="label title">
            <label class="ntss-pat-event-label">終了時刻</label>
          </div>
          <div>
            <!--mod FNSI-改修内容患者event bug 任 start-->
            <!--<v-ons-select class="select" v-model="eventEndDateClass" :disabled="getViewMode">-->
            <!-- mod #10359 編集権限の動作不正 start -->
            <v-ons-select
              class="select"
              v-model="eventEndDateClass"
              :disabled="
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority')
              "
              @change="changeCondition(1)"
            >
            <!--<v-ons-select
              class="select"
              v-model="eventEndDateClass"
              :disabled="
                getViewMode
              "
              @change="changeCondition(1)"
            >-->
              <!--mod FNSI-改修内容患者event bug 任 end-->
              <!--<option
                v-for="(item, index) in selectDays"
                :key="index"
                :value="item.code"
                :disabled="
                  getViewMode
                "
                style="color: black"
              >-->
              <option
                v-for="(item, index) in selectDays"
                :key="index"
                :value="item.code"
                :disabled="
                  getViewMode ||
                  !getItemAuthorized(
                    'PatEvent',
                    'default_authority'
                  )
                "
                style="color: black"
              >
              <!-- mod #10359 編集権限の動作不正 end -->
                {{ item.name }}
              </option>
            </v-ons-select>
          </div>
          <div style="margin-left: 1em">
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start -->
            <!-- <input
              type="time"
              pattern="\d*"
              class="input_date"
              v-model="eventEndTime"
              :disabled="getViewMode"
            /> -->
           <!-- mod #10359 編集権限の動作不正 start -->
           <!--  <time-input
              pattern="\d*"
              v-model="eventEndTime"
              :disabled="
                getViewMode 
              "
              @handleClearInput="eventEndTime = null"
            />-->
            <time-input
              pattern="\d*"
              v-model="eventEndTime"
              :disabled="
                getViewMode ||
                !getItemAuthorized('PatEvent', 'default_authority')
              "
              @handleClearInput="eventEndTime = null"
            />
           <!-- mod #10359 編集権限の動作不正 start -->
            <!-- #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end -->
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { mapActions, mapGetters } from "vuex";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import moment from "moment";
import { deepCopy } from "@/functions/common/CommonFunctions";
// add No.18 付 start
import InputDateTemplate from "@/components/common/custom-form-tags/InputDateTemplate";
// add No.18 付 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
import TimeInput from "@/components/common/TimeInput.vue";
// #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end
//#10715:日付IF修正Start
import DateInput from "@/components/common/DateInput.vue";
//#10715:日付IF修正End
export default {
  props: {
    // 初期日付
    inputStartDate: {
      type: String,
      default: moment().format("YYYY-MM-DD"),
    },
  },
  components: {
    "common-calendar": commonCalender,
    // add No.18 付 start
    "input-datatemp": InputDateTemplate,
    // add No.18 付 end
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "time-input": TimeInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
    //#10715:日付IF修正Start
    "date-input":DateInput,
    //#10715:日付IF修正End
  },
  data() {
    return {
      hasFocusStartDate: false,
      hasInputStartDate: false,
      inProgressChangeConditionSee: false,
      inputModel: {
        week: [],
        month: [],
        //一回限り
        dayStartDate: this.inputStartDate,
        dayStartTime: null,
        dayDateClass: 0,
        dayEndTime: null,
        //毎日
        everyStartDate: this.inputStartDate,
        everyEndDate: this.inputStartDate,
        everyIntervalDay: null,
        everyStartTime: null,
        everyDateClass: 0,
        everyEndTime: null,
        //毎週
        weekStartDate: this.inputStartDate,
        weekEndDate: this.inputStartDate,
        weekIntervalDay: null,
        weekStartTime: null,
        weekDateClass: 0,
        weekEndTime: null,
        //毎月
        monthStartDate: this.inputStartDate,
        monthEndDate: this.inputStartDate,
        monthIntervalDay: null,
        monthStartTime: null,
        monthDateClass: 0,
        monthEndTime: null,
        //
        monthIntervalDateOfWeek: 0,
        monthIntervalWeek: 0,
      },
      selectDays: [
        {
          code: 0,
          name: "当日",
        },
        {
          code: 1,
          name: "翌日",
        },
        {
          code: 2,
          name: "２日後",
        },
        {
          code: 3,
          name: "３日後",
        },
        {
          code: 4,
          name: "４日後",
        },
        {
          code: 5,
          name: "５日後",
        },
        {
          code: 6,
          name: "６日後",
        },
      ],
      selectDayOfWeek: [
        {
          code: 0,
          name: "日",
        },
        {
          code: 1,
          name: "月",
        },
        {
          code: 2,
          name: "火",
        },
        {
          code: 3,
          name: "水",
        },
        {
          code: 4,
          name: "木",
        },
        {
          code: 5,
          name: "金",
        },
        {
          code: 6,
          name: "土",
        },
      ],
      selectWeek: [
        {
          code: 0,
          name: "1",
        },
        {
          code: 1,
          name: "2",
        },
        {
          code: 2,
          name: "3",
        },
        {
          code: 3,
          name: "4",
        },
        {
          code: 4,
          name: "5",
        },
        {
          code: 5,
          name: "6",
        },
      ],
      tabSelectedId: 1,
      weeks: [0, 0, 0, 0, 0, 0, 0],
      months: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      dayAndDateSpecification: "0",
    };
  },
  computed: {
    ...mapGetters("pat-event/detail", [
      "getPatPlansParams",
      "getPatEventRecord",
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRegStaffInfo",
      "getPatEventUpStaffInfo",
      "getViewMode",
    ]),
    // add FNSI-コントロールの削除 徐 start
    // ...mapGetters("pat-event/list", ["getUpdateMode"]),
    ...mapGetters("pat-event/list", ["getUpdateMode", "getPatEventFlg"]),
    // add FNSI-コントロールの削除 徐 end
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    // mod #12462 患者情報共有 20260312 start
    ...mapGetters("pat-event/list", ["getIsEdit", "getUpdateMode", "getIsOtherFacility"]),
    // mod #12462 患者情報共有 20260312 end
    // add #12462 患者情報共有 20260312 start
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add #12462 患者情報共有 20260312 end
    // add FNSI-共有を追加 王 20200921 end
    const() {
      return {
        dateMin: "1880-01-01",
        dateMax: "2099-12-31",
        dayMin: "1",
        dayMax: "31",
        // 内部 患者イベント，間隔 ボタンを おし 押し て うえ 上 にスクロールします さいしょー 最小 0まで start
        timesMin: "1",
        // 内部 患者イベント，間隔 ボタンを おし 押し て うえ 上 にスクロールします さいしょー 最小 0まで end
        timesMax: "99",
      };
    },
    dateMin() {
      return this.const.dateMin;
    },
    dateMax() {
      return this.const.dateMax;
    },
    dayMin() {
      return this.const.dayMin;
    },
    dayMax() {
      return this.const.dayMax;
    },
    timesMin() {
      return this.const.timesMin;
    },
    timesMax() {
      return this.const.timesMax;
    },
    getUpdateDisplay() {
      if (this.getUpdateMode) {
        return "none";
      }
      return "inline";
    },
    eventStartDate: {
      get() {
        return this.getPatEventRecord.eventStartDate;
      },
      set(value) {
        const rec = this.recDataSet();
        rec.eventStartDate = value;
        this.setPatEventRecord(rec);
      },
    },
    eventStartTime: {
      get() {
        return this.getPatEventRecord.eventStartTime;
      },
      set(value) {
        const rec = this.recDataSet();
        rec.eventStartTime = value;
        // 観察記録は終了時刻に開始時刻と同時刻を設定
        if (this.getPatEventFlg) {
          rec.eventEndTime = value;
        }
        this.setPatEventRecord(rec);
      },
    },
    eventEndDateClass: {
      get() {
        const from = moment(this.getPatEventRecord.eventStartDate)
          .hours(0)
          .minutes(0)
          .seconds(0)
          .milliseconds(0);
        const to = moment(this.getPatEventRecord.eventEndDate)
          .hours(0)
          .minutes(0)
          .second(0)
          .milliseconds(0);
        to.add(1, "day");
        to.add(-1, "milliseconds");
        // 経過時間をミリ秒で取得
        const ms = to.diff(from); // 34214400
        // ミリ秒を日付に変換(端数切捨て)
        let ret = Math.floor(ms / (1000 * 60 * 60 * 24));
        // 開始日 > 終了日、または、観察記録の場合は終了日に開始日と同日を設定
        if (ret < 0 || this.getPatEventFlg) {
          ret = 0; // 当日
          const rec = this.recDataSet();
          rec.eventEndDate = this.eventStartDate;
          this.setPatEventRecord(rec);
        }
        return ret;
      },
      set(value) {
        const rec = this.recDataSet();
        const dt = new Date(this.eventStartDate);
        dt.setDate(dt.getDate() + value);
        rec.eventEndDate = this.formatterDate(dt);
        this.setPatEventRecord(rec);
      },
    },
    // add FNSI-共有を追加 王 20200921 start
    isShared() {
      if (this.getPatEventRecord.isComRec) {
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    eventEndTime: {
      get() {
        return this.getPatEventRecord.eventEndTime;
      },
      set(value) {
        const rec = this.recDataSet();
        const dt = new Date(this.eventStartDate);
        dt.setDate(dt.getDate() + this.eventEndDateClass);
        rec.eventEndDate = this.formatterDate(dt);
        rec.eventEndTime = value;
        this.setPatEventRecord(rec);
      },
    },
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  mounted() {
    //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
    if (this.$router.currentRoute.name != "observe-record-detail" && this.$router.currentRoute.name != "treatment-observe-detail") {
      this.changeTabSelect(1);
    }
    //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
  },
  methods: {
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end

    //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
    // blurInput (event, min, max) {
    blurInput () {
      // let value = event.target.value;
      // if(!value) {
      //   return
      // }
      // if (value < min) {
      //   event.target.value = min;
      // } else if (value > max) {
      //   event.target.value = max;
      // }
      this.inputModel.monthIntervalDay = Number(this.inputModel.monthIntervalDay) > Number(this.dayMax) ?
          Number(this.dayMax) : Number(this.inputModel.monthIntervalDay);
      this.inputModel.monthIntervalDay = Number(this.inputModel.monthIntervalDay) < Number(this.dayMin) ?
          Number(this.dayMin) : Number(this.inputModel.monthIntervalDay);
      //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    },
    handleBlur() {
      // 間隔が未入力の場合、補正処理をせずreturn
      if (
        this.inputModel.weekIntervalDay == null ||
        this.inputModel.weekIntervalDay === ""
      ) return;

      //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      this.inputModel.weekIntervalDay = Number(this.inputModel.weekIntervalDay) > Number(this.timesMax) ?
          Number(this.timesMax) : Number(this.inputModel.weekIntervalDay);
      this.inputModel.weekIntervalDay = Number(this.inputModel.weekIntervalDay) < Number(this.timesMin) ?
          Number(this.timesMin) : Number(this.inputModel.weekIntervalDay);
      //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    },
    ...mapActions("pat-event/detail", [
      "setPatPlansParams",
      "setPatEventRecord",
      "fetchOrdMain",
    ]),
    //#10715:日付IF修正Start
    invalidchk(){
      const params = this.getPatPlansParams;
      let startdate = null;
      let enddate = null;
      let startclassnm = null;
      let endclassnm = null;
      if (params.mode === 2) {
        startclassnm = document.getElementsByClassName("every-start-date");
        endclassnm = document.getElementsByClassName("every-end-date");
        startdate = params.startDate;
        enddate = params.endDate;
      } else if (params.mode === 3) {
        startclassnm = document.getElementsByClassName("week-start-date");
        endclassnm = document.getElementsByClassName("week-end-date");
        startdate = params.startDate;
        enddate = params.endDate;
      } else if (params.mode ===5) {
        startclassnm = document.getElementsByClassName("month-start-date");
        endclassnm = document.getElementsByClassName("month-end-date");
        startdate = params.startDate;
        enddate = params.endDate;
      }
      if (startdate < enddate) {
        startclassnm[0].classList.remove("custom-input-date-invalid");
        endclassnm[0].classList.remove("custom-input-date-invalid");
      }
    },
    //#10715:日付IF修正End
    /**
     * タブ切り替え時、表示内容を切り替える
     */
    changeTabSelect(selectedId) {
      // 選択中のタブがクリックされた場合は処理しない
      if (selectedId != this.tabSelectedId) {
        this.tabSelectedId = selectedId;
        this.weeks = [0, 0, 0, 0, 0, 0, 0];
        this.months = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      }
      //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // mod 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関 start
      // this.changeCondition(selectedId);
      // if (this.$router.currentRoute.name != "treatment-observe-detail")
        this.changeCondition(selectedId);
      // mod 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関  end
      //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    },
    formatterDate(value) {
      return moment(value, "YYYY-MM-DD").format("YYYY-MM-DD");
    },
    formatterYMd(value) {
      return moment(value, "YYYY-MM-DD").format("YYYYMMDD");
    },
    /**
     *
     *  毎月タブの日数配列を変更
     */
    async changeMonth(DayNumber, ev) {
      if (ev.target.checked) {
        this.months[DayNumber] = 1;
      } else {
        this.months[DayNumber] = 0;
      }
      let intervalValue = "0";
      let selectedValue = 0;
      if (this.dayAndDateSpecification === "1") {
        intervalValue = this.inputModel.monthIntervalDay;
        selectedValue = 4;
      } else {
        intervalValue =
          this.inputModel.monthIntervalWeek +
          "-" +
          this.inputModel.monthIntervalDateOfWeek;
        selectedValue = 5;
      }
      const params = {
        mode: selectedValue,
        startDate: this.formatterDate(this.inputModel.monthStartDate),
        endDate: this.formatterDate(this.inputModel.monthEndDate),
        interval: intervalValue,
        intervalClass: this.months,
        startTime: this.inputModel.monthStartTime,
        dateClass: this.inputModel.monthDateClass,
        endTime: this.inputModel.monthEndTime,
      };
      await this.setPatPlansParams(params);
    },
    /**
     * 毎週タブの曜日配列を変更
     */
    async changeWeek(DayOfWeek, ev) {
      if (ev.target.checked) {
        this.weeks[DayOfWeek] = 1;
      } else {
        this.weeks[DayOfWeek] = 0;
      }
      const params = {
        mode: this.tabSelectedId,
        startDate: this.formatterDate(this.inputModel.weekStartDate),
        endDate: this.formatterDate(this.inputModel.weekEndDate),
        /*mod FNSI-改修内容6284 任 start*/
        /*interval: this.inputModel.weekIntervalDay,*/
        interval:
          this.inputModel.weekIntervalDay === ""
            ? 0
            : this.inputModel.weekIntervalDay,
        /*mod FNSI-改修内容6284 任 end*/
        intervalClass: this.weeks,
        startTime: this.inputModel.weekStartTime,
        dateClass: this.inputModel.weekDateClass,
        endTime: this.inputModel.weekEndTime,
      };
      await this.setPatPlansParams(params);
    },
    /**
     * 実績作成の指示パラメータ生成
     */
    async changeCondition(selectedId) {
      let params = null;
      let intervalValue = "0";
      let selectedValue = 0;
      switch (selectedId) {
        case 1:
          params = {
            mode: selectedId,
            startDate: this.getUpdateMode
              ? this.formatterDate(this.eventStartDate)
              : this.formatterDate(this.inputModel.dayStartDate),
            endDate: null,
            interval: null,
            intervalClass: null,
            startTime: this.inputModel.dayStartTime,
            /*mod FNSI-改修内容患者event bug 任 start*/
            /*dateClass: this.inputModel.dayDateClass,*/
            dateClass: this.getUpdateMode
              ? this.eventEndDateClass
              : this.inputModel.dayDateClass,
            /*mod FNSI-改修内容患者event bug 任 end*/
            endTime: this.inputModel.dayEndTime,
          };
          break;
        case 2:
          params = {
            mode: selectedId,
            startDate: this.formatterDate(this.inputModel.everyStartDate),
            endDate: this.formatterDate(this.inputModel.everyEndDate),
            interval: this.inputModel.everyIntervalDay,
            intervalClass: null,
            startTime: this.inputModel.everyStartTime,
            dateClass: this.inputModel.everyDateClass,
            endTime: this.inputModel.everyEndTime,
          };
          break;
        case 3:
          params = {
            mode: selectedId,
            startDate: this.formatterDate(this.inputModel.weekStartDate),
            endDate: this.formatterDate(this.inputModel.weekEndDate),
            /*mod FNSI-改修内容6284 任 start*/
            /*interval: this.inputModel.weekIntervalDay,*/
            interval:
              this.inputModel.weekIntervalDay === ""
                ? 0
                : this.inputModel.weekIntervalDay,
            /*mod FNSI-改修内容6284 任 end*/
            intervalClass: this.weeks,
            startTime: this.inputModel.weekStartTime,
            dateClass: this.inputModel.weekDateClass,
            endTime: this.inputModel.weekEndTime,
          };
          // console.log(params)
          break;
        case 4:
          if (this.dayAndDateSpecification === "1") {
            intervalValue = this.inputModel.monthIntervalDay;
            selectedValue = 4;
          } else {
            intervalValue =
              this.inputModel.monthIntervalWeek +
              "-" +
              this.inputModel.monthIntervalDateOfWeek;
            selectedValue = 5;
          }
          params = {
            mode: selectedValue,
            startDate: this.formatterDate(this.inputModel.monthStartDate),
            endDate: this.formatterDate(this.inputModel.monthEndDate),
            interval: intervalValue,
            intervalClass: this.months,
            startTime: this.inputModel.monthStartTime,
            dateClass: this.inputModel.monthDateClass,
            endTime: this.inputModel.monthEndTime,
          };
          break;
        default:
          break;
      }
      await this.setPatPlansParams(params);
      // オーダ検索処理
      if (this.getPatEventRecord.patId) {
        // mod #12462 患者情報共有 20260312 start
        // const patId = this.getPatEventRecord.patId;
        const patId = this.selectedPatId;
        // mod #12462 患者情報共有 20260312 end
        let sdt = new Date(params.startDate);
        /*mod FNSI-改修内容患者event bug 任 start*/
        /*let edt = new Date(params.startDate);*/
        let edt = new Date(
          params.endDate === null ? params.startDate : params.endDate
        );
        /*mod FNSI-改修内容患者event bug 任 end*/
        edt.setDate(edt.getDate() + params.dateClass);
        const endDate = this.formatterYMd(edt);
        const startDate = this.formatterYMd(sdt);
        // add #12462 患者情報共有 20260312 start
        const rec = this.getPatEventRecord;
        const eventCd = rec.patEventCd;
        // add #12462 患者情報共有 20260312 end
        await this.fetchOrdMain({
          patId: patId,
          treatStartDate: startDate,
          treatEndDate: endDate,
          patEventCd: eventCd,
        });
      }
    },
    onFocusInStartDate() {
      this.hasInputStartDate = false;
      this.hasFocusStartDate = true;
    },
    onInputStartDate() {
      if (!this.hasInputStartDate) {
        this.hasInputStartDate = true;
      }
    },
    onFocusOutStartDate(mode) {
      this.hasFocusStartDate = false;
      if (this.hasInputStartDate) {
        this.hasInputStartDate = false;
        this.changeConditionSee(mode);
      }
    },
    onFocusOutStartTime() {
      // 新規登録
      // 観察記録は終了時刻が画面に存在しないため終了時刻に開始時刻と同時刻を設定
      // ※終了日についてはAPI側で開始日「当日」の日付が設定される
      this.inputModel.dayEndTime = this.inputModel.dayStartTime;
    },
    /*add FNSI-改修内容6186 任 start*/
    // 観察記録 新規作成、更新モードで開始日を変更した際の呼出しメソッド
    async changeConditionSee(mode) {
      if (this.hasFocusStartDate) {
        // 直接入力中にv-modelの値が更新されることによるカレンダーコンポーネントのinputイベントからの呼び出しは無効化する
        return;
      }
      if (this.inProgressChangeConditionSee) {
        // カレンダーでの日付変更時に二重にinputイベントが発生するため、既に処理中の場合は無効化する
        return;
      }
      this.inProgressChangeConditionSee = true;
      let params = null;
      params = {
        /*mode: selectedId,*/
        startDate: this.formatterDate(
          mode === 1 ? this.inputModel.dayStartDate : this.eventStartDate
        ),
        endDate: null,
        interval: null,
        intervalClass: null,
        startTime: this.inputModel.dayStartTime,
        dateClass: this.getUpdateMode
          ? this.eventEndDateClass
          : this.inputModel.dayDateClass,
        endTime: this.inputModel.dayEndTime,
      };
      // mod 8147 デフォルト値：当日 の日付の項目が、患者イベント開始日を変更しても更新されない 関 start
      // /*      await this.setPatPlansParams(params);*/
      await this.setPatPlansParams(params);
      // mod 8147 デフォルト値：当日 の日付の項目が、患者イベント開始日を変更しても更新されない 関  end
      if (this.getPatEventRecord.patId) {
        // mod #12462 患者情報共有 20260312 start
        // const patId = this.getPatEventRecord.patId;
        const patId = this.selectedPatId;
        // mod #12462 患者情報共有 20260312 end
        let sdt = new Date(params.startDate);
        // mod FNSI5673-治療実績リンクの選択肢に実績のない日が表示される 周 start
        //let edt = new Date();
        let edt = new Date(
          params.endDate === null ? params.startDate : params.endDate
        );
        // mod FNSI5673-治療実績リンクの選択肢に実績のない日が表示される 周 end
        const endDate = this.formatterYMd(edt);
        const startDate = this.formatterYMd(sdt);
        // add #12462 患者情報共有 20260312 start
        const rec = this.getPatEventRecord;
        const eventCd = rec.patEventCd;
        // add #12462 患者情報共有 20260312 end
        await this.fetchOrdMain({
          patId: patId,
          treatStartDate: startDate,
          treatEndDate: endDate,
          patEventCd: eventCd,
        });
      }
      this.inProgressChangeConditionSee = false;
    },
    /*add FNSI-改修内容6186 任 end*/
    async changeDayAndDateCondition(event) {
      let params = null;
      let intervalValue = "0";
      let selectedValue = 0;
      if (event.target.value === "1") {
        intervalValue = this.inputModel.monthIntervalDay;
        selectedValue = 4;
      } else {
        intervalValue =
          this.inputModel.monthIntervalWeek +
          "-" +
          this.inputModel.monthIntervalDateOfWeek;
        selectedValue = 5;
      }
      params = {
        mode: selectedValue,
        startDate: this.formatterDate(this.inputModel.monthStartDate),
        endDate: this.formatterDate(this.inputModel.monthEndDate),
        interval: intervalValue,
        intervalClass: this.months,
        startTime: this.inputModel.monthStartTime,
        dateClass: this.inputModel.monthDateClass,
        endTime: this.inputModel.monthEndTime,
      };
      await this.setPatPlansParams(params);
      // オーダ検索処理
      if (this.getPatEventRecord.patId) {
        // mod #12462 患者情報共有 20260312 start
        // const patId = this.getPatEventRecord.patId;
        const patId = this.selectedPatId;
        // mod #12462 患者情報共有 20260312 end
        let sdt = new Date(params.startDate);
        /*mod FNSI-改修内容患者event bug 任 start*/
        /*let edt = new Date(params.startDate);*/
        let edt = new Date(
          params.endDate === null ? params.startDate : params.endDate
        );
        /*mod FNSI-改修内容患者event bug 任 end*/
        edt.setDate(edt.getDate() + params.dateClass);
        const endDate = this.formatterYMd(edt);
        const startDate = this.formatterYMd(sdt);
        // add #12462 患者情報共有 20260312 start
        const rec = this.getPatEventRecord;
        const eventCd = rec.patEventCd;
        // add #12462 患者情報共有 20260312 end
        await this.fetchOrdMain({
          patId: patId,
          treatStartDate: startDate,
          treatEndDate: endDate,
          patEventCd: eventCd,
        });
      }
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let startDateIsInput = true;
      let startDateIsValid = true;
      let endDateIsInput = true;
      let endDateIsValid = true;
      let dateIsValid = true;
      let dayOfTheWeekIsValid = true;
      let monthIsValid = true;
      let dayInput = true;
      let timeIsValid = true;
      const params = this.getPatPlansParams;
      // console.log(params)
      if (!this.getUpdateMode) {
        if (params.startDate === null) {
          startDateIsInput = false;
        } else {
          if (!moment(params.startDate, "YYYY-MM-DD", true).isValid()) {
            startDateIsValid = false;
          }
        }
        if (params.mode >= 2) {
          if (params.endDate === null) {
            endDateIsInput = false;
          } else {
            if (!moment(params.endDate, "YYYY-MM-DD", true).isValid()) {
              endDateIsValid = false;
            }
            const from1 = moment(params.startDate);
            const to = moment(params.endDate);
            if (
              params.dateClass === 0 &&
              params.startTime !== null &&
              params.endTime !== null
            ) {
              const fromTime = moment(
                params.startDate + "T" + params.startTime,
                "YYYY-MM-DDTHH:mm"
              );
              const toTime = moment(
                params.endDate + "T" + params.endTime,
                "YYYY-MM-DDTHH:mm"
              );
              if (!(fromTime <= toTime)) {
                timeIsValid = false;
              }
            } else if (!(from1 < to)) {
              //#10715:日付IF修正Start
              if (params.mode === 2) {
                //毎日：every-start-date
                let startclassnm2 = document.getElementsByClassName("every-start-date");
                let endclassnm2 = document.getElementsByClassName("every-end-date");
                if (!startclassnm2[0].classList.contains("custom-input-date-invalid")) startclassnm2[0].classList.add("custom-input-date-invalid");
                if (!endclassnm2[0].classList.contains("custom-input-date-invalid")) endclassnm2[0].classList.add("custom-input-date-invalid");
              } else if (params.mode === 3) {
                //毎週：week-start-date
                let startclassnm3 = document.getElementsByClassName("week-start-date");
                let endclassnm3 = document.getElementsByClassName("week-end-date");
                if (!startclassnm3[0].classList.contains("custom-input-date-invalid")) startclassnm3[0].classList.add("custom-input-date-invalid");
                if (!endclassnm3[0].classList.contains("custom-input-date-invalid")) endclassnm3[0].classList.add("custom-input-date-invalid");
              } else if (params.mode === 5) {
                //毎月：month-start-date
                let startclassnm5 = document.getElementsByClassName("month-start-date");
                let endclassnm5 = document.getElementsByClassName("month-end-date");
                if (!startclassnm5[0].classList.contains("custom-input-date-invalid")) startclassnm5[0].classList.add("custom-input-date-invalid");
                if (!endclassnm5[0].classList.contains("custom-input-date-invalid")) endclassnm5[0].classList.add("custom-input-date-invalid");
              }
              //#10715:日付IF修正End
              dateIsValid = false;
            }
          }
        }
        if (
          params.dateClass === 0 &&
          params.startTime !== null &&
          params.endTime !== null
        ) {
          const fromTime = moment(params.startTime, "HH:mm");
          const toTime = moment(params.endTime, "HH:mm");
          if (!(fromTime <= toTime)) {
            timeIsValid = false;
          }
        }
        switch (params.mode) {
          case 3:
            if (params.intervalClass === null) {
              dayOfTheWeekIsValid = false;
            } else {
              let result = params.intervalClass.some(function (value) {
                return value > 0;
              });
              if (!result) {
                dayOfTheWeekIsValid = false;
              }
            }
            break;
          case 4:
            if (params.interval === null || params.interval === 0) {
              dayInput = false;
            }
            if (params.intervalClass === null) {
              monthIsValid = false;
            } else {
              let result = params.intervalClass.some(function (value) {
                return value > 0;
              });
              if (!result) {
                monthIsValid = false;
              }
            }
            break;
          default:
            break;
        }
      }
      if (this.getUpdateMode) {
        const eventStartDate = this.eventStartDate;
        const eventStartTime = this.eventStartTime;
        const eventEndDateClass = this.eventEndDateClass;
        const eventEndTime = this.eventEndTime;
        if (!moment(eventStartDate, "YYYY-MM-DD", true).isValid()) {
          startDateIsValid = false;
        }
        // add FNSI-コントロールの削除 徐 start
        if (!this.getPatEventFlg) {
          // add FNSI-コントロールの削除 徐 end
          /*mod FNSI-改修内容履歴の内容を編集登録時の時間チェックが新規登録時のチェックと不一致。start*/
          /*if (eventEndDateClass === 0) {*/
          if (
            eventEndDateClass === 0 &&
            eventStartTime !== null &&
            eventEndTime !== null
          ) {
            /*mod FNSI-改修内容履歴の内容を編集登録時の時間チェックが新規登録時のチェックと不一致。end*/
            const fromTime = moment(eventStartTime, "HH:mm");
            const toTime = moment(eventEndTime, "HH:mm");
            if (!(fromTime <= toTime)) {
              timeIsValid = false;
            }
          }
          if (eventEndDateClass > 6) {
            endDateIsValid = false;
          }
        }
      }
      // console.log({
      //     startDateIsInput: startDateIsInput,
      //     startDateIsValid: startDateIsValid,
      //     endDateIsInput: endDateIsInput,
      //     endDateIsValid: endDateIsValid,
      //     dateIsValid: dateIsValid,
      //     dayOfTheWeekIsValid: dayOfTheWeekIsValid,
      //     monthIsValid: monthIsValid,
      //     dayInput: dayInput,
      //     timeIsValid: timeIsValid
      //   })
      return {
        startDateIsInput: startDateIsInput,
        startDateIsValid: startDateIsValid,
        endDateIsInput: endDateIsInput,
        endDateIsValid: endDateIsValid,
        dateIsValid: dateIsValid,
        dayOfTheWeekIsValid: dayOfTheWeekIsValid,
        monthIsValid: monthIsValid,
        dayInput: dayInput,
        timeIsValid: timeIsValid,
      };
    },
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every((v) => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000301].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.startDateIsValid
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "開始日時が未入力です。<br>"
                messageFormat(DIALOG_MESSAGES[12000301].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.startDateIsInput
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "開始日時が正しくありません。<br>"
                messageFormat(DIALOG_MESSAGES[12000302].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.endDateIsValid
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "終了日時が未入力です。<br>"
                messageFormat(DIALOG_MESSAGES[12000303].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.endDateIsInput
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "終了日時が正しくありません。<br>"
                messageFormat(DIALOG_MESSAGES[12000304].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.dateIsValid
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "日付の大小関係が正しくありません。<br>"
                messageFormat(DIALOG_MESSAGES[12000305].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.dayOfTheWeekIsValid
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "曜日が未選択です。<br>"
                messageFormat(DIALOG_MESSAGES[12000306].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.timeIsValid
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "イベント時刻の大小関係が正しくありません。<br>"
                messageFormat(DIALOG_MESSAGES[12000307].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.monthIsValid
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "月が未選択です。<br>"
                messageFormat(DIALOG_MESSAGES[12000308].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
          ${
            !validationResult.dayInput
              ? // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // ? "日が未入力です。<br>"
                messageFormat(DIALOG_MESSAGES[12000309].message)
              : // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message,
      });
      return false;
    },
    recDataSet() {
      const rec = deepCopy(this.getPatEventRecord);
      // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 start
      if (this.getPatEventInputParams) {
        rec.inputParams = JSON.stringify(this.getPatEventInputParams);
      } else {
        rec.inputParams = null;
      }
      // rec.inputParams = JSON.stringify(this.getPatEventInputParams);
      // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 end
      rec.resultParams = JSON.stringify(this.getPatEventResultParams);
      rec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
      rec.upStaffInfo = JSON.stringify(this.getPatEventUpStaffInfo);
      return rec;
    },
  },
  watch: {
    /*add FNSI-改修内容redmain5673 任 start*/
    eventStartDate() {
      this.$parent.editor();
    },
    /*add FNSI-改修内容redmain5673 任 end*/
    //add #9208 患者イベントの実績リンクでの選択肢が不正 関 start
    getPatEventFlg() {
      if(!this.getUpdateMode) {
        if (this.getPatEventFlg) {
          this.changeConditionSee(1);
        }else{
          this.changeCondition(1);
        }
      }
    },
    //add #9208 患者イベントの実績リンクでの選択肢が不正 関 end
  },
  created() {
    //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
    // mod 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関 start
    // this.changeCondition(1);
    // if (this.$router.currentRoute.name != "treatment-observe-detail")
      this.changeCondition(1);
    // mod 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関  end
    //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
  },
  destroyed() {},
};
</script>
<style scoped>
.tab-main-content {
  overflow-y: auto;
  flex: 1;
}
/* [メイン] タブ切り替え全体のスタイル*/
.tabs {
  /*margin-top: 40px; */
  /* background-color: #fff; */
  width: 97%;
}
/* [メイン] タブのスタイル*/
.tab_item {
  width: calc(100% / 4);
  height: 3em;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 3em;
  font-size: 1em;
  text-align: center;
  color: #565656;
  display: block;
  float: left;
  text-align: center;
  font-weight: bold;
  transition: all 0.2s ease;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.tab_item:hover {
  opacity: 0.75;
}
/* [メイン] ラジオボタンを全て消す*/
input[name="tab_item"] {
  display: none;
}
/* [メイン] タブ切り替えの中身のスタイル*/
.tab_content {
  display: none;
  padding: 10px 10px 0;
  clear: both;
  border: 1px solid #c1c1c1;
}
/* [メイン] 選択されているタブのコンテンツのみを表示*/
#check1:checked ~ #tab1_content,
#check2:checked ~ #tab2_content,
#check3:checked ~ #tab3_content,
#check4:checked ~ #tab4_content {
  display: block;
  padding: 5px 5px 5px 5px;
}
/* [メイン] 選択されているタブのスタイルを変える*/
.tabs input:checked + .tab_item {
  background-color: #2a8bc4;
  color: #fff;
}
.input {
  max-width: 20em;
  vertical-align: middle;
}
.input_date {
  max-width: 20em;
  vertical-align: middle;
  background-color: white;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
}
.onscol {
  padding-top: 10px;
}
.disable {
  pointer-events: none;
  opacity: 0.5;
}
.select {
  max-width: 20em;
  vertical-align: middle;
}
.select >>> .select-input {
  opacity: 1;
}
.flex-wrap-div {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
}
.flex-nowrap-div {
  display: flex;
  flex-wrap: nowrap;
  flex-direction: row;
}
.flex-div {
  display: flex;
  margin-right: 1em;
}
.flex-div-mt {
  margin-top: 5px;
}
.label {
  margin-top: 5px;
}
.title {
  width: 5em;
}
.month-label {
  width: 5em;
  margin-right: 1em;
}
.round-label {
  width: 7em;
}
.tab_content_dummy {
  display: block;
  padding: 0.3em;
  clear: both;
  border: 1px solid #c1c1c1;
}
.input_date::-webkit-calendar-picker-indicator {
  display: none;
}
</style>
