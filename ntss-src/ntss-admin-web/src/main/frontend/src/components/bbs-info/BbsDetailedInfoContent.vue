<template>
  <div style="height: 100%;">
    <!-- mod FNSI-改修内容5587修正 関　start -->
    <!-- <div class="main-content-area"> -->
    <div class="main-content-area bbs-button">
    <!-- mod FNSI-改修内容5587修正 関　end -->
      <div class="bbs-detail-main">
        <div class="item-area box_flex_w">
          <span class="category-area box_flex_w">
            <span>カテゴリ</span>
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
            <!--<v-ons-select
              v-model="bbsDetailedInfo.kind_no"
              class="input-select d-inline-flex"
              :disabled="!isCategoryBbs || !isRegFuncClass"
              @change="setCategoryInfo($event.target.value)"
            >
              <option
                v-for="(mst, mstIndex) in getKindList(bbsDetailedInfo.func_cd)"
                :key="mstIndex"
                :value="mst.kindNo"
              >{{ mst.kindName }}</option>
            </v-ons-select> -->
            <v-ons-select
              v-model="bbsDetailedInfo.kind_no"
              class="input-select d-inline-margin"
              :disabled="!isCategoryBbs || !isRegFuncClass || !allowEdit"
              @change="setCategoryInfo($event.target.value)"
            >
              <option
                v-for="(mst, mstIndex) in getKindList(bbsDetailedInfo.func_cd)"
                :key="mstIndex"
                :value="mst.kindNo"
              >
                {{ mst.kindName }}
              </option>
            </v-ons-select>
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
          </span>
          <!-- mod FNSI-549 改修内容 一度詳細を表示したら自動的に「既読」にする 趙立強 start -->
          <!-- <span
            class="switch-area"
            :style="{
              'visibility': bbsDetailedInfo.is_disp_bbs && selectedBbs.bbs_ctl_no
              ? 'visible'
              : 'hidden'
            }"
          > -->
          <span class="switch-area" v-if="isFlg()">
            <v-ons-switch
              v-model="userReadState"
              @change="changeUserReadState($event.value)"
            />
          </span>
          <!-- <span
            @click="showPopover($event)"
            :style="{
              'visibility': bbsDetailedInfo.is_disp_bbs && selectedBbs.bbs_ctl_no
              ? 'visible'
              : 'hidden'
            }"
          > -->
          <span @click="showPopover($event)" v-if="isFlg()">
            <span>既読</span>
            <span>{{ allReadStateRatio }}</span>
          </span>
        </div>
        <!-- mod FNSI-549 改修内容 一度詳細を表示したら自動的に「既読」にする 趙立強 end -->
        <div class="item-area box_flex_w">
          <span style="margin-right: 0.7em;">イベント日時</span>
          <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou start -->
          <!-- <input
            v-model="bbsDetailedInfo.notice_fac_cal_start_date"
            class="input-date ntss-input-date"
            type="date"
            @input="setNoticeCalendarValue($event.target.value)"
            :disabled="!isRegFuncClass"
          /> -->
          <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
          <!--<input
            v-model="bbsDetailedInfo.notice_fac_cal_start_date"
            class="input-date ntss-input-date"
            type="date"
            max="9999-12-31"
            @input="setNoticeCalendarValue($event.target.value)"
            :disabled="!isRegFuncClass"

          />-->
          <!--mod FNSI-改修内容 必須入力項目の背景色は黄色になる 趙立強 start-->
          <!-- <input
            v-model="bbsDetailedInfo.notice_fac_cal_start_date"
            class="input-date ntss-input-date ntss-input-start-date"
            type="date"
            max="9999-12-31"
            @input="setNoticeCalendarValue($event.target.value)"
            :disabled="!isRegFuncClass"
          /> -->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!--<input
            v-model="bbsDetailedInfo.notice_fac_cal_start_date"
            class="input-date ntss-input-date ntss-input-start-date"
            type="date"
            max="9999-12-31"
            @input="setNoticeCalendarValue($event.target.value)"
            :disabled="!isRegFuncClass"
            :style="{
              'background-color':'#ffff99'
            }"
          /> -->
          <div style="display: flex; flex-flow: wrap;">
            <div style="display: flex; flex-flow: nowrap; align-items: center;">
              <date-input
                v-model="bbsDetailedInfo.notice_fac_cal_start_date"
                :classes="'input-area ntss-input-date ntss-custom-input ntss-input-start-date date-input-required ' + isEdited('notice_fac_cal_start_date')"
                :disabled="!isRegFuncClass || !allowEdit"
                isRequired
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <!--mod FNSI-改修内容 必須入力項目の背景色は黄色になる 趙立強 end-->
              <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
              <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou end -->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!-- <common-calendar v-model="bbsDetailedInfo.notice_fac_cal_start_date" class="calender" :disabled="!isRegFuncClass"/>-->
              <common-calendar
              v-model="bbsDetailedInfo.notice_fac_cal_start_date"
              class="calender"
              :disabled="!isRegFuncClass || !allowEdit"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <!-- mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start -->
              <!-- <input v-model="notice_fac_cal_start_time" class="input-date" type="time" /> -->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<input v-model="bbsDetailedInfo.notice_fac_cal_start_time" class="input-date"  type="time" />-->
             <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input
              v-model="bbsDetailedInfo.notice_fac_cal_start_time"
              class="input-date"
              :disabled="!allowEdit"
              type="time"
              /> -->
              <time-input
              v-model="bbsDetailedInfo.notice_fac_cal_start_time"
              @handleClearInput="bbsDetailedInfo.notice_fac_cal_start_time = null"
              :classes="isEdited('notice_fac_cal_start_time')"
              class="input-date"
              :disabled="!allowEdit"
              />
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <!-- mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end -->
              <span>～</span>
            </div>
            <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou start -->
            <!-- <input
              v-model="bbsDetailedInfo.notice_fac_cal_end_date"
              class="input-date"
              type="date"
              :disabled="isEditedFacilityCalendarNoticeStartDate"
            /> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
            <!--<input
            v-model="bbsDetailedInfo.notice_fac_cal_end_date"
            class="input-date"
            type="date"
            max="9999-12-31"
            :disabled="isEditedFacilityCalendarNoticeStartDate"
            />-->
            <!--mod FNSI-改修内容揭示板イベント日時終了日時非活性 趙立強 start-->
            <!-- <input
            v-model="bbsDetailedInfo.notice_fac_cal_end_date"
            class="input-date ntss-input-end-date"
            type="date"
            max="9999-12-31"
            :disabled="isEditedFacilityCalendarNoticeStartDate"
            /> -->
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
            <!-- <input
           v-model="bbsDetailedInfo.notice_fac_cal_end_date"
           class="input-date ntss-input-end-date"
           type="date"
           max="9999-12-31"
           :disabled="isEditedFacilityCalendarNoticeStartDate || !isRegFuncClass"
           />-->
            <div style="margin-right: 0.7em; display: flex; flex-flow: nowrap; align-items: center;">
              <date-input
                v-model="bbsDetailedInfo.notice_fac_cal_end_date"
                :classes="'input-area ntss-input-date ntss-custom-input ntss-input-end-date ' + isEdited('notice_fac_cal_end_date')"
                :disabled="
                  isEditedFacilityCalendarNoticeStartDate ||
                  !isRegFuncClass ||
                  !allowEdit
                "
                @handleClearInput="bbsDetailedInfo.notice_fac_cal_end_date = null"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <!--mod FNSI-改修内容揭示板イベント日時終了日時非活性 趙立強 end-->
              <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
              <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou end -->
              <!--mod FNSI-改修内容揭示板イベント日時終了日時非活性 趙立強 start-->
              <!-- <common-calendar v-model="bbsDetailedInfo.notice_fac_cal_end_date" class="calender" :disabled="isEditedFacilityCalendarNoticeStartDate"/> -->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!-- <common-calendar v-model="bbsDetailedInfo.notice_fac_cal_end_date" class="calender" :disabled="isEditedFacilityCalendarNoticeStartDate || !isRegFuncClass"/>-->
              <common-calendar
                v-model="bbsDetailedInfo.notice_fac_cal_end_date"
                class="calender"
                :disabled="
                  isEditedFacilityCalendarNoticeStartDate ||
                  !isRegFuncClass ||
                  !allowEdit
                "
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <!--mod FNSI-改修内容揭示板イベント日時終了日時非活性 趙立強 end-->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!-- <input v-model="bbsDetailedInfo.notice_fac_cal_end_time" class="input-date" type="time" /> -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input
                v-model="bbsDetailedInfo.notice_fac_cal_end_time"
                class="input-date"
                :disabled="!allowEdit"
                type="time"
              /> -->
              <time-input
                v-model="bbsDetailedInfo.notice_fac_cal_end_time"
                @handleClearInput="bbsDetailedInfo.notice_fac_cal_end_time = null"
                :classes="isEdited('notice_fac_cal_end_time')"
                class="input-date"
                :disabled="!allowEdit"
              />
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
            </div>
          </div>
          <div style="display: flex; flex-flow: nowrap; align-items: center;">
          <!-- add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start -->
          <span style="margin-right: 0.3em;">施設カレンダー掲載</span>
          <!-- 施設カレンダーに表示する -->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!--<v-ons-checkbox v-model=" bbsDetailedInfo.disp_bbs"  />-->
          <v-ons-checkbox
            v-model="disp_bbs"
            :disabled="!allowEdit"
          />
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
          <!-- add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end -->
          </div>
        </div>
        <div class="item-area box_flex_w">
          <span>掲示板掲載</span>
          <!-- 掲示板に表示する -->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!--<v-ons-checkbox v-model=" bbsDetailedInfo.is_disp_bbs"/>-->
          <v-ons-checkbox
            v-model="bbsDetailedInfoIsDispBbsBool"
            :disabled="!allowEdit"
            class="d-inline-margin"
          />
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
          <!-- 掲示板に表示する -->
          <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou start -->
          <!-- <input
            v-model="bbsDetailedInfo.notice_start_date"
            class="input-date"
            type="date"
            @input="setNoticeValue($event.target.value)"
            :disabled="!isRegFuncClass"
          /> -->
          <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
          <!--<input
            v-model="bbsDetailedInfo.notice_start_date"
            class="input-date"
            type="date"
            max="9999-12-31"
            @input="setNoticeValue($event.target.value)"
            :disabled="!isRegFuncClass"
          />-->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!-- <input
             v-model="bbsDetailedInfo.notice_start_date"
             class="input-date notice_input_start_date"
             type="date"
             max="9999-12-31"
             @input="setNoticeValue($event.target.value)"
             :disabled="!isRegFuncClass"
           />-->
          <div style="display: flex; flex-flow: wrap;">
            <div style="display: flex; flex-flow: nowrap; align-items: center;">
              <date-input
                v-model="bbsDetailedInfo.notice_start_date"
                :classes="'input-area ntss-input-date ntss-custom-input notice_input_start_date ' +requiredClass +isEdited('notice_start_date')"
                :disabled="!isRegFuncClass || !allowEdit"
                :is-required="bbsDetailedInfo.is_disp_bbs==true"
                @input="bbsDetailedInfo.is_disp_bbs==false && setNoticeValue($event)"
                @handleClearInput="bbsDetailedInfo.notice_start_date = null; setNoticeValue(null)"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
              <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou end -->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<common-calendar v-model="bbsDetailedInfo.notice_start_date" class="calender" :disabled="!isRegFuncClass/>-->
              <common-calendar
                v-model="bbsDetailedInfo.notice_start_date"
                class="calender"
                :disabled="!isRegFuncClass || !allowEdit"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <span>～</span>
              <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou start -->
              <!-- <input
                v-model="bbsDetailedInfo.notice_end_date"
                class="input-date ntss-input-date"
                type="date"
                :disabled="isEditedNoticeStartDate || !isRegFuncClass"
              /> -->
              <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
              <!--<input
                v-model="bbsDetailedInfo.notice_end_date"
                class="input-date ntss-input-date"
                type="date"
                max="9999-12-31"
                :disabled="isEditedNoticeStartDate || !isRegFuncClass"
              />-->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<input
                v-model="bbsDetailedInfo.notice_end_date"
                class="input-date ntss-input-date notice_input_end_date"
                type="date"
                max="9999-12-31"
                :disabled="isEditedNoticeStartDate || !isRegFuncClass"
              />-->
            </div>
            <div style="display: flex; flex-flow: nowrap; align-items: center;">
              <date-input
                v-model="bbsDetailedInfo.notice_end_date"
                :classes="'input-area ntss-input-date ntss-custom-input notice_input_end_date ' +requiredClass +isEdited('notice_end_date')"
                :disabled="isEditedNoticeStartDate || !isRegFuncClass || !allowEdit"
                :is-required="bbsDetailedInfo.is_disp_bbs==true"
                @handleClearInput="bbsDetailedInfo.notice_end_date = null"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
              <!-- mod FNSI-改修内容 掲示板詳細画面のイベント開始日時と終了日時に無効の日付を入力しても、正常登録できてしまう dou end -->
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<common-calendar
                v-model="bbsDetailedInfo.notice_end_date"
                class="calender"
                :disabled="isEditedNoticeStartDate || !isRegFuncClass"
              />-->
              <common-calendar
                v-model="bbsDetailedInfo.notice_end_date"
                class="calender"
                :disabled="isEditedNoticeStartDate || !isRegFuncClass || !allowEdit"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
            </div>
          </div>
        </div>
        <div class="item-area box_flex_w">
          <span>スタッフ</span>

          <div class="d-flex checkbox-group box_flex_w">
            <div class="d-flex align-items-center">
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<v-ons-checkbox
                input-id="all-user"
                :checked="staffRadioValue === ALL_USER"
                :disabled="!isRegFuncClass"
                @change="changeStaffRadioValue(ALL_USER, $event.target)"
              />-->
              <v-ons-checkbox
                input-id="all-user"
                :checked="staffRadioValue === ALL_USER"
                :disabled="!isRegFuncClass || !allowEdit"
                @change="changeStaffRadioValue(ALL_USER, $event.target)"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <label for="all-user">全</label>
            </div>

            <div class="d-flex align-items-center">
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<v-ons-checkbox
                input-id="individual-user"
                :checked="staffRadioValue === INDIVIDUALLY_USER"
                :disabled="!isRegFuncClass"
                @change="changeStaffRadioValue(INDIVIDUALLY_USER, $event.target)"
              />-->
              <v-ons-checkbox
                input-id="individual-user"
                :checked="staffRadioValue === INDIVIDUALLY_USER"
                :disabled="!isRegFuncClass || !allowEdit"
                @change="
                  changeStaffRadioValue(INDIVIDUALLY_USER, $event.target)
                "
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <label for="individual-user">個別選択</label>
            </div>

            <span v-show="false">
              <span
                v-for="(staff, staffIndex) in selectedStaffList"
                :key="staffIndex"
                >{{ staff.name }}</span
              >
            </span>

            <!-- mod 画面部品デザイン定義 修正 chen start -->
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
            <!--<v-ons-button
              ref="staffSelector"
              class="btn3-normal common-style-select-button"
              :disabled="!isSelectedIndividualStaff ||!isRegFuncClass"
              @click="listSelectStaff()"
            >選択</v-ons-button>-->
            <v-ons-button
              ref="staffSelector"
              class="btn3-normal common-style-select-button"
              :disabled="
                !isSelectedIndividualStaff || !isRegFuncClass || !allowEdit
              "
              @click="listSelectStaff()"
              >選択</v-ons-button
            >
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
            <!-- <v-ons-button -->
            <!--   ref="staffSelector" -->
            <!--   class="common-style-select-button" -->
            <!--   :disabled="!isSelectedIndividualStaff ||!isRegFuncClass" -->
            <!--   @click="listSelectStaff()" -->
            <!-- >選択</v-ons-button> -->
            <!-- mod 画面部品デザイン定義 修正 chen end -->
          </div>
        </div>
        <div class="item-area box_flex_w">
          <span>患者</span>

          <div class="box_flex_w checkbox-group">
            <div class="box_flex_w">
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<v-ons-checkbox
                input-id="not-user"
                :checked="patRadioValue === NOT_USER"
                :disabled="!isCategoryBbs || !isRegFuncClass"
                @change="changePatRadioValue(NOT_USER, $event.target)"
              />-->
              <v-ons-checkbox
                input-id="not-user"
                :checked="patRadioValue === NOT_USER"
                :disabled="!isCategoryBbs || !isRegFuncClass || !allowEdit"
                @change="changePatRadioValue(NOT_USER, $event.target)"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <label for="not-user">なし</label>
            </div>

            <div class="box_flex_w">
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<v-ons-checkbox
                input-id="all-radio-user"
                :checked="patRadioValue === ALL_USER"
                :disabled="!isCategoryBbs || !isRegFuncClass"
                @change="changePatRadioValue(ALL_USER, $event.target)"
              />-->
              <v-ons-checkbox
                input-id="all-radio-user"
                :checked="patRadioValue === ALL_USER"
                :disabled="!isCategoryBbs || !isRegFuncClass || !allowEdit"
                @change="changePatRadioValue(ALL_USER, $event.target)"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <label for="all-radio-user">全</label>
            </div>

            <div class="box_flex_w">
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
              <!--<v-ons-checkbox
                input-id="individual-radio-user"
                :checked="patRadioValue === INDIVIDUALLY_USER"
                :disabled="!isRegFuncClass"
                @change="changePatRadioValue(INDIVIDUALLY_USER, $event.target)"
              />-->
              <v-ons-checkbox
                input-id="individual-radio-user"
                :checked="patRadioValue === INDIVIDUALLY_USER"
                :disabled="!isRegFuncClass || !allowEdit"
                @change="changePatRadioValue(INDIVIDUALLY_USER, $event.target)"
              />
              <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
              <label for="individual-radio-user">個別選択</label>
            </div>

            <span v-show="false">
              <span
                v-for="(pat, patIndex) in selectedPatList"
                :key="patIndex"
                >{{ pat.name }}</span
              >
            </span>

            <!-- mod 画面部品デザイン定義 修正 chen start -->
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
            <!-- <v-ons-button
               ref="patSelector"
               class="btn3-normal common-style-select-button"
               :disabled="!isSelectedIndividualPat || !isRegFuncClass"
               @click="listSelectPat()"
             >選択</v-ons-button>-->
            <v-ons-button
              ref="patSelector"
              class="btn3-normal common-style-select-button"
              :disabled="
                !isSelectedIndividualPat || !isRegFuncClass || !allowEdit
              "
              @click="listSelectPat()"
              >選択</v-ons-button
            >
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
            <!-- <v-ons-button -->
            <!--   ref="patSelector" -->
            <!--   class="common-style-select-button" -->
            <!--   :disabled="!isSelectedIndividualPat || !isRegFuncClass" -->
            <!--   @click="listSelectPat()" -->
            <!-- >選択</v-ons-button> -->
            <!-- mod 画面部品デザイン定義 修正 chen end -->
          </div>
        </div>
        <div class="item-area box_flex_w">
          <!-- <span>通知する</span> -->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!--<v-ons-checkbox style="margin-left:0.5em;" v-model="isNotification"/>-->
          <!-- <v-ons-checkbox
            style="margin-left: 0.5em"
            v-model="isNotification"
            :disabled="!allowEdit"
          /> -->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
        </div>
        <div class="row-title">
          <label style="white-space: nowrap">タイトル </label>
          <custom-simple-textarea-b
            id="input-title"
            class="d-inline-margin title-input"
            @blur="chkChangeText"
            :disabled="!allowEdit"
            v-model="bbsDetailedInfo.title"
          />
        </div>
        <!-- 内容 -->
        <div
          class="item-area box_flex_w"
          id="textarea"
        >
          <com-textarea
            v-show="!isRegFuncClass"
            class="com-textarea"
            :content="bbsDetailedInfo.content"
            :disabled="!isRegFuncClass"
            idTextarea="textarea-content"
            @set-content-data="setContentData($event)"
          />
          <com-textarea
            v-show="isRegFuncClass"
            :key="KeyRefresh"
            :class="keyJudgment == 1 ? 'com-textarea display_none' : 'com-textarea'"
            :content="bbsDetailedInfo.html_content"
            :disabled="!isRegFuncClass"
            idTextarea="editor-input"
            @set-content-data="setContentData($event)"
          />
          <pop-over-fixed-phrase
            v-bind="popoverData"
            :target-position-element="popoverTargetElement()"
            @popover-close="closePopover"
            @popover-return="selectPhrase"
          />
        </div>
        <div class="item-area">
          <span>ファイル添付</span>
          <div>
            <file-uploader
              style="width: 18em"
              ref="fileUploader"
              v-model="bbsDetailedInfo.file_info"
              v-model:is-loading-bbs="isLoadingBbs"
              @deleteFile="deleteFile"
              @search="search"
            />
            <file-downloader
              ref="fileDownloader"
              v-model="bbsDetailedInfo.file_info"
            />
          </div>
        </div>
        <div class="item-area d-flex align-items-center">
          <span style="white-space: nowrap;">画面遷移</span>
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!--<v-ons-select
            v-model="bbsDetailedInfo.transition_router_path"
            class="input-select"
            :disabled="!isRegFuncClass"
          >
            <option
              v-for="(router, index) in routerList"
              :key="index"
              :value="router.routerName"
            >{{ router.description }}</option>
          </v-ons-select>-->
          <v-ons-select
            v-model="bbsDetailedInfo.transition_router_path"
            class="input-select d-inline-margin"
            style="min-width: 9em;"
            :disabled="!isRegFuncClass || !allowEdit"
          >
            <option
              v-for="(router, index) in routerList"
              :key="index"
              :value="router.routerName"
            >
              {{ router.description }}
            </option>
          </v-ons-select>
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
        </div>

        <!-- color -->
        <div class="item-area box_flex_w">
          <div style="display: flex; flex-flow: nowrap; align-items: center;">
            <span style="white-space: nowrap;">施設カレンダ背景色</span>
            <!-- mod FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start -->
            <!-- <span
              :key="0"
              :value="null"
              class="colorSpan"
              :class="classColorSpan(null)"
              @click="colorCheck(null)"
            >なし</span>
            <span
              v-for="(item, index) in colors"
              :key="index+1"
              :value="item"
              v-bind:style="{ backgroundColor: item}"
              :class="classColorSpan(item)"
              @click="colorCheck(item)"
            ></span> -->
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
            <!-- <input
               class="scale-input"
               type="color"
               v-model="backgroundColor"
               @change="changeFormColor"
               @focus="editStart"
               @blur="editEnd"
             />-->
            <input
              class="scale-input"
              :disabled="!allowEdit"
              type="color"
              v-model="backgroundColor"
              @change="changeFormColor"
              @focus="editStart"
              @blur="editEnd"
            />
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
            <!-- mod FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end -->
          </div>
          <div style="display: flex; flex-flow: nowrap; align-items: center;">
            <span style="white-space: nowrap;">文字色</span>
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
            <!-- <input
               class="scale-input"
               type="color"
               v-model="fontColor"
               @change="changeFormFontColor"
               @focus="editStart"
               @blur="editEnd"
             />-->
            <input
              class="scale-input"
              :disabled="!allowEdit"
              type="color"
              v-model="fontColor"
              @change="changeFormFontColor"
              @focus="editStart"
              @blur="editEnd"
            />
            <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
          </div>
          <!-- mod FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end -->
        </div>
      </div>

      <!-- ボタン -->
      <div class="btn-area">
        <div>
          <v-ons-button
            style="margin-right: 1em"
            class="btn2-cancel common-style-cancel-button"
            :disabled="!allowEdit"
            @click="cancel()"
            >キャンセル</v-ons-button
          >
          <!-- mod 画面部品デザイン定義 修正 chen start -->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!--<v-ons-button
            v-if="selectedBbs.bbs_ctl_no !== null"
            class="btn4-alert delete-button"
            :disabled="!isRegFuncClass"
            @click="isDeleteMessage = true"
          >削除</v-ons-button>-->
          <v-ons-button
            v-if="selectedBbs.bbs_ctl_no !== null"
            class="btn4-alert delete-button"
            :disabled="!isRegFuncClass || !allowEdit"
            @click="showDelete"
            >削除</v-ons-button
          >
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->
          <!-- <v-ons-button -->
          <!--   v-if="selectedBbs.bbs_ctl_no !== null" -->
          <!--   class="button delete-button" -->
          <!--   :disabled="!isRegFuncClass" -->
          <!--   @click="isDeleteMessage = true" -->
          <!-- >削除</v-ons-button> -->
          <!-- mod 画面部品デザイン定義 修正 chen end -->
        </div>
        <div class="box_flex_w">
          <!-- mod 画面部品デザイン定義 修正 chen start -->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 start -->
          <!--<v-ons-button class="btn2-cancel common-style-cancel-button"  @click="cancel()">キャンセル</v-ons-button>-->
          <!-- mod FutreNetWeb+SI課題管理No4103対応 于 end -->

          <v-ons-checkbox
            v-model="isNotification"
            :disabled="!allowEdit"
          />
          <span>通知する</span>
          <v-ons-button
            style="margin-left: 0.5em;"
            class="btn1-execute common-style-ok-button"
            @click="saveRecord()"
            :disabled="!allowEdit || !showBtnChanged"
            >保存</v-ons-button
          >
          <!-- <v-ons-button class="button common-style-cancel-button cancel-button" @click="cancel()">キャンセル</v-ons-button> -->
          <!-- <v-ons-button -->
          <!--   class="button common-style-ok-button" -->
          <!--   @click="saveRecord()" -->
          <!--   :disabled="!allowEdit" -->
          <!-- >保存</v-ons-button> -->
          <!-- mod 画面部品デザイン定義 修正 chen end -->
        </div>
      </div>
    </div>
    <!--add FNSI-改修内容日付のチェックの追加対応。 任 start-->
    <message-dialog
      v-if="messageDateInfo.isCheckDialogVisible"
      v-model:visible="messageDateInfo.isCheckDialogVisible"
      :title="messageDateInfo.title"
      :message-cd="messageDateInfo.messageCd"
      :string-params="messageDateInfo.stringParams"
      type="1"
    />
    <!--add FNSI-改修内容日付のチェックの追加対応。 任 end-->
    <message-dialog
      v-if="messageFileInfo.isCheckDialogVisible"
      v-model:visible="messageFileInfo.isCheckDialogVisible"
      :title="messageFileInfo.title"
      :message-cd="messageFileInfo.messageCd"
      :string-params="messageFileInfo.stringParams"
      type="1"
    />
    <!-- スタッフ選択 -->
    <list-selector
      :key="componentKey('スタッフ')"
      v-model:visible="isStaffSelectorVisible"
      v-bind="staffSelectorData"
      :target="selectorTarget('staffSelector')"
      @commit="commitStaffListSelect($event)"
    />
    <!-- 患者選択 -->
    <list-selector
      :key="componentKey('患者')"
      v-model:visible="isPatSelectorVisible"
      v-bind="patSelectorData"
      :target="selectorTarget('patSelector')"
      @commit="commitPatListSelect($event)"
    />

    <message-dialog
      v-model:visible="isDialogVisble"
      v-bind="dialogProps"
      type="1"
      @confirm="confirm"
    />

    <message-dialog
      v-model:visible="isEditedMessage"
      :message-cd="20010001"
      type="2"
      @confirm="confirmEdite"
    />

    <!-- 既読未読状態一覧吹き出し -->
    <v-ons-popover
      cancelable
      v-model:visible="isReadStatePopoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'bbs-staff-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow($event);onPopoverShow()"
      @prehide="onPopoverHide"
      @posthide="popoverPosthide"
    >
      <div class="read-state-popover-container">
        <div class="table-wrapper">
          <div class="table-header">
            <table class="read-state-table">
              <colgroup>
                <col>
                <col>
                <col class="col-scroll">
              </colgroup>
              <thead>
                <tr>
                  <th class="ntss-list-header-th-sticky">スタッフ名</th>
                  <th class="ntss-list-header-th-sticky">既読 / 未読</th>
                  <th class="ntss-list-header-th-sticky"></th>
                </tr>
              </thead>
            </table>
          </div>
          <div class="table-body">
            <table class="read-state-table">
              <tbody>
                <tr
                  v-for="staff in selectedStaffList"
                  :key="staff.cd"
                  class="ntss-list-body-tr"
                >
                  <td class="ntss-list-body-td">{{ staff.name }}</td>
                  <td class="ntss-list-body-td">
                    {{ staff.readState === '0' ? '未読' : '既読' }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="popover-footer">
          <v-ons-button
            class="btn2-cancel common-style-cancel-button close-btn"
            @click="isReadStatePopoverVisible = false"
            >閉じる</v-ons-button
          >
        </div>
      </div>
    </v-ons-popover>

    <v-ons-modal :visible="isLoadingBbs">
      <p class="loading-modal">
        掲示板情報を保存しています
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
  </div>
</template>

<script>
  import _ from "@/compat/collections/lodash";
  import lodash from "@/compat/collections/lodash";
  import dayjs from "@/compat/date/dayjs";
  import { mapActions, mapGetters } from "@/compat/vue/vuex";
  import {EventBus} from "@/compat/vue/event-bus.js";
  import {ApiHelper} from "@/apis/AxiosHelper";
  import {replaceLtGt,customComparator} from "@/utils/util.js";
  import {deepCopy, formatDatetime, serializeJsonColumn,isJsonChanged} from "@/functions/common/CommonFunctions";
  import {DATE_FORMAT, dateFormat } from "@/functions/common/DateTimeUtils.js";
  /*mod FNSI-改修内容掲示板外结No.10 任 start*/
  /*import {createItemListData} from "@/functions/for-componet/ListSelector.js";*/
  import {createItemListDataBbs} from "@/functions/for-componet/ListSelector.js";
  /*mod FNSI-改修内容掲示板外结No.10 任 end*/
  import {createBbs, deleteBbs, updateBbs, updateBbsList} from "@/functions/BbsInfoFunctions.js";
  import PopoverMixin from "@/components/PopoverMixin";
  import ChangeLogBBSInfoMixin from "@/mixins/change-log/bbs-info/ChangeLogBBSInfoMixin";
  // 機能コード
  // 観察記録
  import {FUNC_BBS_INFO} from "@/constants/function-code.js";
  // 共通カレンダーコンポーネント
  /*mod FNSI-改修内容掲示板外结No.10 任 start*/
  /*import listSelector from "@/components/common/list-selector/ListSelector.vue";*/
  import listSelector from "@/components/common/list-selector/ListSelectorBbs.vue";
  /*mod FNSI-改修内容掲示板外结No.10 任 end*/
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  import FileUploader from "@/components/bbs-info/BbsFileUploader";
  import FileDownloader from "@/components/bbs-info/BbsFileDownloader";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";

  import {AUTHORITY_CODES} from "@/constants/userAuthority";
  import CommonTextArea from "@/components/common/CommonTextArea";
  /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
  import $$ from "@/compat/jquery";
  import {
  mountEditor,
  getEditorWidget as getNativeEditorWidget,
  isInsideKendoEditorInteraction,
  getKendoEditorToolbarClearButtons,
  getKendoEditorOwnerDocument,
  getKendoEditorDocumentElement,
  getKendoEditorBody,
  createKendoEditorRange,
  createKendoEditorElement
} from "@/functions/common/KendoFunctions";
  /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
  /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou start*/
  import MasterSelectorFixedPhrase from "@/components/common/master-selector/MasterSelectorFixedPhrase";
  /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou end*/
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
  // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat'
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'
  // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
  //#5590 2023/04/19 ×を常に表示するように修正 張博 start
  import TimeInput from "@/components/common/TimeInput.vue";
  //#5590 2023/04/19 ×を常に表示するように修正 張博 end
  import DateInput from "@/components/common/DateInput";
  import { addPatNameSortToList, sortableCompare } from "@/functions/SortFunctions";
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, getScopedElementsByTagName, getScopedWindow, getScopedUserAgent,
  getScopedJQuery as createScopedJQuery} from "@/functions/common/LayoutMeasureHelper";

  const uriPersonalUser = `/mstInfo/mstPersonalUser`;
  const uriPat = `/patInfo/getPatByIdList`;
  const uriBbsKind = `/mstInfo/mstBbsKind`;
  /*add FNSI-改修内容掲示板外结No.10 任 start*/
  const uriJobName = `/bbsInfo/getJobName`;
  // mod 8220 施設イベント詳細画面の表示が遅い 関 start
  // const uriIsSame = `/bbsInfo/getIsSame`;
  const uriIsSame = `/bbsInfo/getPatIsSame`;
  // mod 8220 施設イベント詳細画面の表示が遅い 関  end
  /*add FNSI-改修内容掲示板外结No.10 任 end*/
  // 個人設定
  const uriUser = "/user/get_by_id";

  // ラジオボタン選択肢
  const INDIVIDUALLY_USER = "0";
  const ALL_USER = "1";
  const NOT_USER = "2";

  const TOOLS = [
    "bold",
    "italic",
    "underline",
    "strikethrough",
    {
      name: "fontName",
      // mod #9504 2023/12/04 拡張書式の動作不正 張玲 start
      // 9504対応 フォントの設定を修正 START
      // items: [
      // { text: "メイリオ", value: "Meiryo" },
      // { text: "ＭＳ ゴシック", value: "ＭＳゴシック" },
      // { text: "ＭＳ Ｐゴシック", value: "ＭＳＰゴシック" },
      // { text: "ＭＳ 明朝", value: "ＭＳ明朝" },
      // { text: "ＭＳ Ｐ明朝", value: "ＭＳＰ明朝" },
      // { text: "MS UI Gothic", value: "MSUIGothic" },
      // { text: "Arial", value: "Arial" },
      // { text: "Osaka", value: "Osaka" },
      // { text: "Helvetica Neue", value: "HelveticaNeue" },
      // { text: "Helvetica", value: "Helvetica" },
      // { text: "sans-serif", value: "sans-serif" },
      // { text: "Times New Roman", value: "TimesNewRoman" }
      // ]
      items: [
      { text: "メイリオ", value: "Meiryo" },
      { text: "ＭＳ ゴシック", value: "MSGothicAlias" },
      { text: "ＭＳ Ｐゴシック", value: "MSPGothicAlias" },
      { text: "ＭＳ 明朝", value: "MSMinchoAlias" },
      { text: "ＭＳ Ｐ明朝", value: "MSPMinchoAlias" },
      { text: "MS UI Gothic", value: "MSUIGothicAlias" },
      { text: "Arial", value: "ArialAlias" },
      { text: "Osaka", value: "OsakaAlias" },
      { text: "Helvetica Neue", value: "HelveticaNeueAlias" },
      { text: "Helvetica", value: "HelveticaAlias" },
      { text: "sans-serif", value: "SansSerifAlias" },
      { text: "Times New Roman", value: "TimesNewRomanAlias" }
      ]
      // 9504対応 フォントの設定を修正 END
      // mod #9504 2023/12/04 拡張書式の動作不正 張玲 end
    },
    // mod #10538 2024/04/22 拡張書式テキストエリアのカラーパレット変更 Thach start
    {
      name: "foreColor",
      palette:[
        "#FFFFFF", "#000000", "#E7E6E6", "#44546A", "#4472C4", "#ED7D31", "#A5A5A5", "#FFC000", "#5B9BD5", "#70AD47",
        "#F2F2F2", "#808080", "#D0CECE", "#D6DCE4", "#D9E1F2", "#FCE4D6", "#EDEDED", "#FFF2CC", "#DDEBF7", "#E2EFDA",
        "#D9D9D9", "#595959", "#AEAAAA", "#ACB9CA", "#B4C6E7", "#F8CBAD", "#DBDBDB", "#FFE699", "#BDD7EE", "#C6E0B4",
        "#BFBFBF", "#404040", "#757171", "#8497B0", "#8EA9DB", "#F4B084", "#C9C9C9", "#FFD966", "#9BC2E6", "#A9D08E",
        "#A6A6A6", "#262626", "#3A3838", "#333F4F", "#305496", "#C65911", "#7B7B7B", "#BF8F00", "#2F75B5", "#548235",
        "#808080", "#0D0D0D", "#161616", "#222B35", "#203764", "#833C0C", "#525252", "#806000", "#1F4E78", "#375623",
        "#C00000", "#FF0000", "#FFC000", "#FFFF00", "#92D050", "#00B050", "#00B0F0", "#0070C0", "#002060", "#7030A0"
      ],
      columns: 10
    },
    {
      name: "backColor",
      palette:[
        "#FFFFFF", "#000000", "#E7E6E6", "#44546A", "#4472C4", "#ED7D31", "#A5A5A5", "#FFC000", "#5B9BD5", "#70AD47",
        "#F2F2F2", "#808080", "#D0CECE", "#D6DCE4", "#D9E1F2", "#FCE4D6", "#EDEDED", "#FFF2CC", "#DDEBF7", "#E2EFDA",
        "#D9D9D9", "#595959", "#AEAAAA", "#ACB9CA", "#B4C6E7", "#F8CBAD", "#DBDBDB", "#FFE699", "#BDD7EE", "#C6E0B4",
        "#BFBFBF", "#404040", "#757171", "#8497B0", "#8EA9DB", "#F4B084", "#C9C9C9", "#FFD966", "#9BC2E6", "#A9D08E",
        "#A6A6A6", "#262626", "#3A3838", "#333F4F", "#305496", "#C65911", "#7B7B7B", "#BF8F00", "#2F75B5", "#548235",
        "#808080", "#0D0D0D", "#161616", "#222B35", "#203764", "#833C0C", "#525252", "#806000", "#1F4E78", "#375623",
        "#C00000", "#FF0000", "#FFC000", "#FFFF00", "#92D050", "#00B050", "#00B0F0", "#0070C0", "#002060", "#7030A0"
      ],
      columns: 10
    },
    // mod #10538 2024/04/22 拡張書式テキストエリアのカラーパレット変更 Thach end
    // #5842 テキストエリアの不正 訾浩 start
    {
      name: "fontSize",
      items: [
        { text: "1 (8pt)", value: "8pt" },
        { text: "2 (10pt)", value: "10pt" },
        { text: "3 (12pt)", value: "12pt" },
        { text: "4 (14pt)", value: "14pt" },
        { text: "5 (18pt)", value: "18pt" },
        { text: "6 (24pt)", value: "24pt" },
        { text: "7 (36pt)", value: "36pt" },
      ]
    }
    // #5842 テキストエリアの不正 訾浩 end
  ];

  export default {
    mixins: [PopoverMixin, ChangeLogBBSInfoMixin],
    components: {
      /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou start*/
      "pop-over-fixed-phrase": MasterSelectorFixedPhrase,
      /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou end*/
      "list-selector": listSelector,
      "message-dialog": messageDialog,
      "common-calendar": commonCalender,
      FileUploader,
      FileDownloader,
      "com-textarea": CommonTextArea,
      "custom-simple-textarea-b": CustomSimpleTextareaTypeB,
      //#5590 2023/04/19 ×を常に表示するように修正 張博 start
      "time-input":TimeInput,
      //#5590 2023/04/19 ×を常に表示するように修正 張博 end
      "date-input":DateInput
    },

    data() {
      const arrayColors = [
        "#EA5532",
        "#F6AD3C",
        "#FFF33F",
        "#00A95F",
        "#187FC4",
        "#A64A97",
        "#EE87B4",
        "#D0CECE"
      ];
      return {
        // Vue3では$refsへの任意プロパティ追加がreadonlyになるため、編集状態はdataで保持する
        isChanged: false,
        /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou start*/
        /**
         * @description 「共通定型文」マスタ選択用タイマー(長押し機能)
         */
        commentTimer: 0,
        // 定型文情報
        popoverData: {
          popoverVisible: false,
          popoverDisplayDirection: "right"
        },
        editor: null,
        /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou end*/
        colors: arrayColors,
        selectedColor: null,
        // 利用者マスタ
        mstPersonalUser: null,
        // 患者情報
        patInfo: null,
        // 掲示板種別マスタ
        mstBbsKind: null,
        // created実行フラグ
        isCreated: false,
        // スタッフ選択肢
        staffInfoList: null,
        // 患者選択肢
        patInfoList: null,
        // デシリアライズ対象のjsonbカラム名
        jsonColumns: ["pat_info", "staff_info", "file_info"],
        // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
        // colorSetting: null,
        backgroundColor: "#ffffff",
        // fontColorSetting:null,
        fontColor: "#cccccc",
        //Android端末で編集中であることを示すフラグ
        androidFlg: false,
        /*add FNSI-改修内容日付のチェックの追加対応。 任 start*/
        messageDateInfo: {
          isCheckDialogVisible: false,
          messageCd: null,
          stringParams: []
        },
        messageFileInfo: {
          isCheckDialogVisible: false,
          messageCd: null,
          stringParams: []
        },
        /*add FNSI-改修内容日付のチェックの追加対応。 任 end*/
        // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
        // 掲示板詳細データ
        bbsDetailedInfo: {
          bbs_ctl_no: null,
          facility_cd: null,
          pat_info: { target: null, detail: [] },
          staff_info: {
            target: [],
            read: []
          },
          func_cd: null,
          kind_no: null,
          fn_seq_id: null, // 内容管理番号(観察記録等)
          content: null,
          file_info: [],
          notice_start_date: null,
          notice_end_date: null,
          reg_staff_id: null,
          reg_staff_name: null,
          upd_staff_id: null,
          upd_staff_name: null,
          transition_router_path: null,
          reg_date: null,
          up_date: null,
          notice_fac_cal_start_date: null,
          notice_fac_cal_end_date: null,
          // add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start
          notice_fac_cal_start_time: null,
          notice_fac_cal_end_time: null,
          // add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end
          title: null,
          // add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start
          is_time_start_flg: true,
          is_time_end_flg: true,
          // add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end
          color: null,
          font_color:null,
          /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
          html_content: null,
          /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
          reg_func_class: null
        },
        // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start
        // this.notice_fac_cal_start_time: null,
        // notice_fac_cal_end_time: null,
        // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end

        // 選択した既読未読状態
        userReadState: false,
        // 選択したスタッフ
        selectedStaffList: [],
        // 選択した患者
        selectedPatList: [],

        // スタッフ選択フラグ
        isStaffSelectorVisible: false,
        // スタッフ選択肢
        staffSelectorData: null,
        // 患者選択フラグ
        isPatSelectorVisible: false,
        // 患者選択肢
        patSelectorData: null,

        // スタッフラジオボタン値
        staffRadioValue: null,
        // 患者ラジオボタン値
        patRadioValue: null,
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        // 施設カレンダー掲載ボタン値
        bbsNotice: null,
        // 通知するボタン値
        bbsIsNotification: null,
        // タイトル値
        bbsTitle: null,
        // 施設カレンダ背景色値
        bbsBackgroundColor: null,
        // 施設カレンダ文字色値
        bbsFontColor: null,
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
        // ロードフラグ
        isLoadingBbs: false,
        // 既読未読状態一覧吹き出し表示フラグ
        isReadStatePopoverVisible: false,

        // 遷移先コード、名称一覧
        routerList: [
          { routerName: null, description: "未登録" },
          // 患者情報
          { routerName: "pat-info", description: "患者情報" },
          // 患者統合経過ビューア
          { routerName: "pat-viewer", description: "患者経過総合ビューア" },
          // 治療記録
          { routerName: "treatment-record", description: "治療記録" },
          // 観察記録
          { routerName: "observe-record", description: "観察記録" },
          // 患者イベント
          { routerName: "pat-event", description: "患者イベント" },
          // 検査結果
          { routerName: "exam-record", description: "検査結果" },
          // スケジュール表
          { routerName: "schedule-list", description: "スケジュール表" }
        ],

        // DB利用者マスタ
        settingBbs: { auto_read: null },

        // バリデーションチェック
        isDialogVisble: false,
        // 未入力項目メッセージ
        dialogProps: null,

        // 吹き出し位置※左右
        popoverTarget: null,
        // 吹き出し位置※下に表示
        popoverDirection: "down",

        isEditedMessage: false,
        // 権限項目
        checkedAuthority: [],
        oldContent:null,
        oldTitle:null,

        // 通知するか
        isNotification:false,

        disp_bbs: false,

        setLoopId: null,

        jobList:null,
        // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
        keyJudgment: 0,
        KeyRefresh: 0,
        // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
        // count: 0,
        // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
        routerName: null,
        abanDoning: 0,
        // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
        //add 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　start
        initialReadState: false,
        //mod 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　end
        copyFontSize: null,
        oldValue: {},
        showBtnChanged: false,
        olddisp_bbs: false,
        oldselectedStaffList: [],
        oldbackgroundColor: "",
        oldfontColor: "",
        oldisNotification: "",
        oldselectedPatList: ""
      };
    },

    computed: {
      ...mapGetters("bbs-info", [
        "selectedBbs",
        "userId",
        "userName",
        "selectedCondition",
        "regFuncClass",
        "htmlContent",
      ]),
      ...mapGetters("user", { facilityCd: "getFacilityCd" }),
      ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
      // add FNSI-改修内容5587修正 関　start
      ...mapGetters("account-edit", ["isDispMenu"]),
      // add FNSI-改修内容5587修正 関　end
      /**
       * @description 掲示板掲載チェックボックスのON/OFF
       * - this.bbsDetailedInfo.is_disp_bbsにbool値以外がコードで設定されコンソールにvueの警告が表示されるのを防止
       */
      bbsDetailedInfoIsDispBbsBool: {
        get() {
          return this.bbsDetailedInfo.is_disp_bbs == 1;
        },
        set(val) {
          this.bbsDetailedInfo.is_disp_bbs = val ? 1 : 0;
        }
      }, 
      /**
       * @description 全体の既未読状態(比率)
       * @returns 既読件数/全体件数
       */
      allReadStateRatio() {
        // 表示している掲載件数を取得
        const staffList = this.selectedStaffList.length;
        // 各スタッフから既読件数を取得
        const readList = this.selectedStaffList.filter(
          // 既読状態: "1"
          item => item.readState === "1").length;
        return `${readList}/${staffList}`;
      },

      /**
       * @description 自身の既読未読状態
       * @returns Boolean true:既読, false:未読
       */
      isUserRead() {
        // 各スタッフから自身のデータを取得
        const state = this.selectedStaffList.find(
          item => item.cd === this.userId
        );

        // 取得したデータから状態を比較「既読: "1", 未読: "0"」
        return state === undefined ? null : state.readState === "1";
      },

      /**
       * @description スタッフ個別選択フラグ
       * @returns { Boolean } true:活性, false:非活性
       */
      isSelectedIndividualStaff() {
        // ラジオボタンの「個別選択:"0"」が選択時、活性
        return this.staffRadioValue === INDIVIDUALLY_USER;
      },

      /**
       * @description 患者個別選択フラグ
       * @returns { Boolean } true:活性, false:非活性
       */
      isSelectedIndividualPat() {
        // ラジオボタンの「個別選択:"0"」が選択時、活性
        return this.patRadioValue === INDIVIDUALLY_USER && this.isCategoryBbs;
      },

      /**
       * @description 掲示板カテゴリフラグ
       * @returns { Boolean } true:活性, false:非活性
       */
      isCategoryBbs() {
        // 掲示板のカテゴリは編集可
        return this.bbsDetailedInfo.func_cd === "020";
      },

      /**
       * @description 掲載日入力フラグ
       * @returns { Boolean } true:未選択, false:選択済み
       */
      // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start
      // isNotNoticeStartDate() {
      //   return (
      //     this.bbsDetailedInfo.notice_start_date === null ||
      //     this.bbsDetailedInfo.notice_start_date === ""
      //   );
      // },
      // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end
      /**
       * @description 掲載日入力フラグ
       * @returns { Boolean } true:未選択, false:選択済み
       */
      isNotNoticeCalendarStartDate() {

        /*mod FNSI-改修内容日付のチェックの追加対応。 任 start*/
        /*return (
          this.bbsDetailedInfo.notice_fac_cal_start_date === null ||
          this.bbsDetailedInfo.notice_fac_cal_start_date === "");*/
        return (
          (this.bbsDetailedInfo.notice_fac_cal_start_date === null && this.getScopedClassElementSafe("ntss-input-start-date").validationMessage === "") ||
          (this.bbsDetailedInfo.notice_fac_cal_start_date === "" && this.getScopedClassElementSafe("ntss-input-start-date").validationMessage === ""));
        /*mod FNSI-改修内容日付のチェックの追加対応。 任 end*/

      },

      /**
       * @description 内容入力フラグ
       * @returns { Boolean } true:未選択, false:選択済み
       */
      isNotContent() {
        /*mod FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
        /*return (
          this.bbsDetailedInfo.content === null ||
          !this.bbsDetailedInfo.content.trim());*/
        return (
          this.bbsDetailedInfo.content === null ||
          !this.bbsDetailedInfo.content.trim()||this.bbsDetailedInfo.html_content === null ||
          !this.bbsDetailedInfo.html_content.trim()
        );
        /*mod FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
      },

      isValidDate() {
        /*mod FNSI-改修内容時刻が指定しなくてもイベントが登録できるようにする 王 start */
        /*if (
          !this.bbsDetailedInfo.notice_fac_cal_start_date ||
          !this.bbsDetailedInfo.notice_fac_cal_end_date ||
          !this.notice_fac_cal_start_time ||
          !this.notice_fac_cal_end_time ||
          !this.bbsDetailedInfo.notice_start_date ||
          !this.bbsDetailedInfo.notice_end_date) {*/
        /*mod FNSI-改修内容掲載の終了日が指定しなくてもイベントが登録できるようにする 王敏 start */
        /*if (
         !this.bbsDetailedInfo.notice_fac_cal_start_date ||
         !this.bbsDetailedInfo.notice_fac_cal_end_date ||
         !this.bbsDetailedInfo.notice_start_date ||
         !this.bbsDetailedInfo.notice_end_date) {*/
        // if (
        //      !this.bbsDetailedInfo.notice_fac_cal_start_date ||
        //      !this.bbsDetailedInfo.notice_fac_cal_end_date ||
        //      !this.bbsDetailedInfo.notice_start_date
        //    ) {
        // /*mod FNSI-改修内容掲載の終了日が指定しなくてもイベントが登録できるようにする 王敏 end */
        // /*mod FNSI-改修内容時刻が指定しなくてもイベントが登録できるようにする 王 end */
        //   return false;
        // }
        // 日時
        /*mod FNSI-改修内容時刻が指定しなくてもイベントが登録できるようにする 王 start */
        /*let facStartDate = dayjs(
          `${this.bbsDetailedInfo.notice_fac_cal_start_date} ${this.notice_fac_cal_start_time}`);
        let facEndDate = dayjs(
          `${this.bbsDetailedInfo.notice_fac_cal_end_date} ${this.notice_fac_cal_end_time}`);*/
        // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start
        // let facStartDate = null;
        // let facEndDate = null;
        // if (this.notice_fac_cal_start_time === null ||this.notice_fac_cal_start_time === ""){
        //   facStartDate = dayjs(this.bbsDetailedInfo.notice_fac_cal_start_date);
        // }else{
        //   facStartDate = dayjs(
        //   `${this.bbsDetailedInfo.notice_fac_cal_start_date} ${this.notice_fac_cal_start_time}`
        //   );
        // }
        // if (this.notice_fac_cal_end_time === null ||this.notice_fac_cal_end_time === "") {
        //   facEndDate = dayjs(this.bbsDetailedInfo.notice_fac_cal_end_date);
        // }else{
        //     facEndDate = dayjs(
        //     `${this.bbsDetailedInfo.notice_fac_cal_end_date} ${this.notice_fac_cal_end_time}`
        //     );
        // }
        /*mod FNSI-改修内容時刻が指定しなくてもイベントが登録できるようにする 王 end */
        // if (facStartDate.isAfter(facEndDate)) {
        //   return false;
        // }
        // 掲示板掲載
        // let noticeStartDate = dayjs(this.bbsDetailedInfo.notice_start_date);
        // let noticeEndDate = dayjs(this.bbsDetailedInfo.notice_end_date);
        // if (noticeStartDate.isAfter(noticeEndDate)) {
        //   return false;
        // }
        // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end
        return true;
      },
      // add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start
      isDispBbs(){

        if(!this.bbsDetailedInfo.is_disp_bbs && !this.disp_bbs){

          return false;
        }
        return true;
      },
      // add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end
      /**
       * @description バリデーションチェック
       * @summary 設定項目のチェックを行う
       */
      validateList() {
        return [
          // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start
          // { name: "掲載日", value: this.isNotNoticeStartDate },
          // del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end
          // mod FNSI-改修内容 掲示板詳細画面の保存ボタンを押下する時のチェックメッセージの内容が不正 dou start
          // { name: "カレンダー掲載日", value: this.isNotNoticeCalendarStartDate },
          { name: "イベント日時", value: this.isNotNoticeCalendarStartDate },
          // mod FNSI-改修内容 掲示板詳細画面の保存ボタンを押下する時のチェックメッセージの内容が不正 dou end
          { name: "内容", value: this.isNotContent }
        ];
      },

      /**
       * @description 掲載日編集フラグ
       * @returns { Boolean } true: 「編集不可」 false: 「編集可」
       */
      isEditedNoticeStartDate() {
        const noticeStartDate = this.bbsDetailedInfo.notice_start_date;
        return noticeStartDate === null || noticeStartDate === "";
      },

      /**
       * @description 掲載日編集フラグ
       * @returns { Boolean } true: 「編集不可」 false: 「編集可」
       */
      isEditedFacilityCalendarNoticeStartDate() {
        const noticeFacilityCalendarStartDate = this.bbsDetailedInfo
          .notice_fac_cal_start_date;
        return (
          noticeFacilityCalendarStartDate === null ||
          noticeFacilityCalendarStartDate === ""
        );
      },

      /**
       * @description 患者情報編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedPatInfo() {
        // 編集前の値
        const patInfo = this.selectedBbs.pat_info;
        // 編集有無フラグ
        let isNotEditPatList = true;
        // 編集後の値
        const editedPatList = this.selectedPatList.map(pat => pat.cd);

        // 編集有無確認
        const detail = editedPatList.find(item => {
          if (patInfo.detail.includes(item)) {
            // 「未編集：undefined」
          } else {
            // 「編集：値を返す」
            return item;
          }
        });
        isNotEditPatList = detail === undefined;

        if (isNotEditPatList) {
          // 編集前から患者を減らした場合、上記では引っかからないので配列要素数で判定
          isNotEditPatList = editedPatList.length === patInfo.detail.length;
        }

        return (
          this.bbsDetailedInfo.pat_info.target === patInfo.target &&
          isNotEditPatList
        );
      },

      /**
       * @description スタッフ情報編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedStaffInfo() {
        if (!this.isCreated) {
          return true;
        }
        // 編集前の値
        const staffInfo = this.selectedBbs.staff_info;
        // 編集前の未読既読値
        let userState = null;
        // 編集後の選択スタッフ値
        const editedStaffList = this.selectedStaffList.map(staff => staff.cd);

        // 編集前の選択スタッフ
        // mod 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        // let staffList = staffInfo.read.map(select => {
        //   if (select === this.userId) {
        //     // 自身の編集前の状態取得
        //     userState = "1";
        //   }
        //   return select;
        // });
        // let staffList = staffInfo.target.map(select => {
        //   if (select === this.userId) {
        //     // 自身の編集前の状態取得
        //     userState = "1";
        //   }
        //   return select;
        // });

        let staffList = staffInfo.target;

        for(const staffId in staffInfo.target) {
          if(staffId === this.userId) {
            console.log("staff matched.");
            userState = "1";
            break;
          }
        }
        // mod 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
        if (staffInfo.target.length === 0) {
          // スタッフ未選択、ラジオボタン「全」(新規登録時)
          const mstSelectUser = [
            ...this.mstPersonalUser.map(mst => ({ ...mst })),
            { userId: this.userId, userName: this.userName }
          ];
          // 初期値全スタッフ
          staffList = mstSelectUser.map(user => user.userId);
          // 初期値「未読」選択
          userState = "0";
        }

        // スタッフ選択編集有無フラグ
        let isNotEditStaffInfo = true;
        // 選択スタッフ編集有無確認
        if (staffList.length === 0) {
          isNotEditStaffInfo = staffList.length === editedStaffList.length;
        } else {
          const detail = editedStaffList.find(item => {
            if (staffList.includes(item)) {
              // 「未編集：undefined」
            } else {
              // 「編集：値を返す」
              return item;
            }
          });
          isNotEditStaffInfo = detail === undefined;

          if (isNotEditStaffInfo) {
            // 編集前から減らした場合、上記では引っかからないので配列要素数で判定
            isNotEditStaffInfo = editedStaffList.length === staffList.length;
          }
        }

        // // 未読既読状態編集有無確認
        // del 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        //mod 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　start
        // let editedUserReadState = this.userReadState ? "1" : "0";
        // if (staffInfo.target === null) {
        //   // 新規登録なら
        //   editedUserReadState = this.userReadState ? editedUserReadState : null;
        // }
        // // 未読既読状態編集有無フラグ
        // const isUserRead = userState === editedUserReadState;
        // let editedUserReadState = this.userReadState ? "1" : "0";
        // if (staffInfo.target === null) {
        //   // 新規登録なら
        //   editedUserReadState = this.userReadState ? editedUserReadState : null;
        // }
        // // 未読既読状態編集有無フラグ
        // const isUserRead = this.initialReadState === this.userReadState;
        // del 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
        //mod 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　end
        let target = "0";
        if (staffInfo.target.length === 0) {
          target = "1";
        }

        return (
          // mod 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
          //mod 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　start
          this.staffRadioValue === target && isNotEditStaffInfo
          // this.staffRadioValue === target && isNotEditStaffInfo && isUserRead
          //mod 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　end
          // mod 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
          );
      },

      /**
       * @description カテゴリ編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedKindNo() {
        let kindNo = this.selectedBbs.kind_no;
        const editedKindNo = this.bbsDetailedInfo.kind_no;
        if (
          this.selectedBbs.func_cd === "020" &&
          kindNo === null &&
          this.mstBbsKind.length !== 0
        ) {
          // カテゴリ初期値設定
          kindNo = this.mstBbsKind[0].kindNo;
        }
        return editedKindNo === kindNo;
      },

      /**
       * @description 内容編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedContent() {
        const content = this.selectedBbs.content;
        const htmlContent = this.selectedBbs.html_content;
        const editedContent = (this.bbsDetailedInfo.content === null ? "" : this.bbsDetailedInfo.content);
        const editedHtmlContent = (this.bbsDetailedInfo.html_content === null ? "" : this.bbsDetailedInfo.html_content);
        return editedContent === content && editedHtmlContent === htmlContent;
      },

      /**
       * @description ファイル添付編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedFileInfo() {
        const fileInfo = this.selectedBbs.file_info;
        const editedFileInfo = this.bbsDetailedInfo.file_info;

        // add 7936 掲示板に連携通知がコンバートされていない 関 start
        if (!fileInfo) {
          return true;
        }
        // add 7936 掲示板に連携通知がコンバートされていない 関  end
        const pathList = fileInfo.map(file => file.path);
        const file = editedFileInfo.find(item => {
          if (pathList.includes(item.path)) {
            // 「未編集：undefined」
          } else {
            // 「編集：値を返す」
            return item;
          }
        });
        let isEditedFileInfo = file === undefined;
        if (isEditedFileInfo) {
          // 編集前から減らした場合、上記では引っかからないので配列要素数で判定
          isEditedFileInfo = editedFileInfo.length === fileInfo.length;
        }

        return isEditedFileInfo;
      },

      /**
       * @description 掲載日編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedNotice() {
        let startDate = this.selectedBbs.notice_start_date;
        let endDate = this.selectedBbs.notice_end_date;
        let editedStartDate = this.bbsDetailedInfo.notice_start_date;
        let editedEndDate = this.bbsDetailedInfo.notice_end_date;

        if (startDate !== null) {
          startDate = dayjs(startDate).format("YYYY-MM-DD");
        }
        if (endDate !== null) {
          endDate = dayjs(endDate).format("YYYY-MM-DD");
        }

        editedStartDate = editedStartDate === "" ? null : editedStartDate;
        editedEndDate = editedEndDate === "" ? null : editedEndDate;

        if (editedStartDate !== null) {
          editedStartDate = dayjs(editedStartDate).format("YYYY-MM-DD");
        }
        if (editedEndDate !== null) {
          editedEndDate = dayjs(editedEndDate).format("YYYY-MM-DD");
        }
        return startDate === editedStartDate && endDate === editedEndDate;
      },

      /**
       * @description 掲載日編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedNoticeCalendar() {
        let startDate = this.selectedBbs.notice_fac_cal_start_date;
        let endDate = this.selectedBbs.notice_fac_cal_end_date;
        let editedStartDate = this.bbsDetailedInfo.notice_fac_cal_start_date;
        let editedEndDate = this.bbsDetailedInfo.notice_fac_cal_end_date;
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        let startTime = this.selectedBbs.is_time_start_flg === "1" ? this.selectedBbs.notice_fac_cal_start_time : null;
        let endTime = this.selectedBbs.is_time_end_flg === "1" ? this.selectedBbs.notice_fac_cal_end_time : null;
        let editedStartTime = this.bbsDetailedInfo.notice_fac_cal_start_time;
        let editedEndTime = this.bbsDetailedInfo.notice_fac_cal_end_time;
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
        if (startDate !== null) {
          startDate = dayjs(startDate).format("YYYY-MM-DD");
        }
        if (endDate !== null) {
          endDate = dayjs(endDate).format("YYYY-MM-DD");
        }
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        if (startTime !== null) {
          startTime = dayjs(startTime,"HHmm").format("HH:mm");
        }
        if (endTime !== null) {
          endTime = dayjs(endTime,"HHmm").format("HH:mm");
        }
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
        editedStartDate = editedStartDate === "" ? null : editedStartDate;
        editedEndDate = editedEndDate === "" ? null : editedEndDate;
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        editedStartTime = editedStartTime === "" ? null : editedStartTime;
        editedEndTime = editedEndTime === "" ? null : editedEndTime;
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
        if (editedStartDate !== null) {
          editedStartDate = dayjs(editedStartDate).format("YYYY-MM-DD");
        }
        if (editedEndDate !== null) {
          editedEndDate = dayjs(editedEndDate).format("YYYY-MM-DD");
        }
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        if (editedStartTime !== null) {
          editedStartTime = dayjs(editedStartTime,"HHmm").format("HH:mm");
        }
        if (editedEndTime !== null) {
          editedEndTime = dayjs(editedEndTime,"HHmm").format("HH:mm");
        }
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
        // mod 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        // return startDate === editedStartDate && endDate === editedEndDate;
        return startDate === editedStartDate && endDate === editedEndDate && startTime === editedStartTime && endTime === editedEndTime;
        // mod 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 end
      },

      /**
       * @description 遷移機能編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedTransition() {
        const routerPath = this.selectedBbs.transition_router_path;
        const editedRouterPath = this.bbsDetailedInfo.transition_router_path;
        return editedRouterPath === routerPath;
      },
      /**
       * @description 施設カレンダー掲載編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedBbsNotice() {
        let editedBbsNotice = null;
        let editedBbsDetailedNotice = null;
        if (this.disp_bbs === undefined || this.disp_bbs === false){
          editedBbsNotice = 0;
        }else{
          editedBbsNotice = 1;
        }
        if (this.bbsDetailedInfo.is_disp_bbs != 1){
          editedBbsDetailedNotice = false;
        }else{
          editedBbsDetailedNotice = true;
        }
        return parseInt(this.bbsNotice) === editedBbsNotice && editedBbsDetailedNotice;
      },
       /**
       * @description 通知編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedIsNotification() {
        return this.bbsIsNotification === this.isNotification;
      },
       /**
       * @description タイトル編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedTitle() {
        return this.bbsTitle === this.bbsDetailedInfo.title
      },
       /**
       * @description 施設カレンダ背景色文字色編集フラグ
       * @returns { Boolean } true: 「未編集」 false: 「編集済み」
       */
      isNotEditedColor() {
        return this.bbsBackgroundColor === this.backgroundColor && this.bbsFontColor === this.fontColor;
      },
      isNotEdited() {
        if (this.getStateUserAccountInfo === null) {
          // サインアウト
          return this.getStateUserAccountInfo === null;
        }
        return (
          this.isNotEditedPatInfo &&
          this.isNotEditedStaffInfo &&
          this.isNotEditedKindNo &&
          this.isNotEditedContent &&
          this.isNotEditedFileInfo &&
          this.isNotEditedNotice &&
          this.isNotEditedNoticeCalendar &&
          this.isNotEditedTransition &&
          this.isNotEditedBbsNotice &&
          this.isNotEditedIsNotification &&
          this.isNotEditedTitle &&
          this.isNotEditedColor
        );
      },

      isRegFuncClass() {
        if (this.selectedBbs.reg_func_class === 1) {
          return false;
        }
        return true;
      },

      INDIVIDUALLY_USER() {
        return INDIVIDUALLY_USER;
      },
      ALL_USER() {
        return ALL_USER;
      },
      NOT_USER() {
        return NOT_USER;
      },
      allowEdit() {
        return this.checkedAuthority.includes(AUTHORITY_CODES.FCL_EDIT);
      },
      requiredClass(){
        if (this.bbsDetailedInfo.is_disp_bbs) {
          return "date-input-required ";
        } else {
          return "";
        }
      },
    },

    watch: {
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      abanDoning (val) {
        if (val > 0) {
          this.keyJudgment && this.initBbsDetailInfo();
        }
      },
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      /**
       * @description 掲示板詳細情報設定
       */
      // add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう dou start
      bbsDetailedInfo: {
        handler() {
          this.isTrueChange();
        },
        deep: true
      },
      disp_bbs(newvalue) {
        this.isTrueChange(newvalue);
      },
      isNotification() {
        this.isTrueChange();
      },
      // add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう dou end
      selectedBbs() {
        // スワイプ等で掲示板を変更したら詳細情報を設定
        if (this.isCreated) {
          // 通知有無の初期化
          this.isNotification = false;
          // createdでマスタデータを取得後、動作
          this.setSelectedBbsInfo();
          // タイトルの取得
          this.oldTitle = this.bbsDetailedInfo.title;
          // HTMLContentの取得
          this.oldContent = this.bbsDetailedInfo.html_content;
          // 登録元機能 = "掲示板"の場合
          if (this.isRegFuncClass) {
            // "editor-input"の取得
            let editor = this.getRichTextEditor();
            // "editor-input"取得可の場合
            if (editor) {
              // HTMLの初期化
              editor.body.innerHTML = "";
              // HTMLの挿入
              editor.exec("insertHTML", {value: this.oldContent});
            }
          }
        }
      },
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      // isNotEdited() {
      //   // 掲示板詳細内容の編集有無を設定
      //   // EventBus.$emit("isNotEdited", this.isNotEdited);
      // },
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
      isNotEdited: {
        handler() {
          // FacilityCalendarDetailView
          this.isChanged = this.showBtnChanged;
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
          EventBus.$emit("isNotEdited", this.isNotEdited);
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
        },
        deep: true
      },
      // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
      'bbsDetailedInfo.is_disp_bbs'(newValue) {
        if (newValue === true) {
          // 掲示板掲載チェックONで開始日が空の場合はsysdateを設定
          if (this.bbsDetailedInfo.notice_start_date === "" || this.bbsDetailedInfo.notice_start_date === null) {
            this.bbsDetailedInfo.notice_start_date = dateFormat.format(new Date(), DATE_FORMAT);
          }
          // 終了日が空の場合はsysdateを設定
          if (this.bbsDetailedInfo.notice_end_date === "" || this.bbsDetailedInfo.notice_end_date === null) {
            this.bbsDetailedInfo.notice_end_date = this.bbsDetailedInfo.notice_start_date;
          }
        }
		    this.isTrueChange();
      },
      'bbsDetailedInfo.kind_no'(newVal, oldVal) {
        const newKind = this.mstBbsKind.find(item => item.kindNo === newVal);
        if (!newKind) {
          this.setCategoryInfo(newVal);
        }
      }
    },

    beforeUnmount () {
      this.clearManagedRuntimeHandlers();
      const editor = this.getRichTextEditor();
      $$(editor?.window || []).off(".ntssBbsDetailEditor");
      $$(getKendoEditorOwnerDocument(editor, null, this.$el) || []).off(".ntssBbsDetailEditor");
      // 掲示板詳細内容の編集有無をクリアへ
      EventBus.$off("abanDoning", this.onAbanDoning);
      EventBus.$off("routerName", this.onRouterName);
      // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
      // EventBus.$off("refresh");
      EventBus.$off("refresh", this.refresh);
      EventBus.$off("initTitle", this.initTitle);
      // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
      EventBus.$emit("isNotEdited", true);
      const ownerWindow = this.getBbsOwnerWindow();
      ownerWindow.checkCommentLongPress = null;
      ownerWindow.onDblTap = null;
      ownerWindow.endLongTouch = null;
      ownerWindow.iframeChange = null;
      ownerWindow.showPopover1 = null;
      if (ownerWindow.setShowPopover) {
        ownerWindow.clearTimeout(ownerWindow.setShowPopover);
        ownerWindow.setShowPopover = null;
      }
      const bbsInfo = {
        bbs_ctl_no: null,
        facility_cd: null,
        pat_info: { target: null, detail: [] },
        staff_info: {
          read: [],
          target: []
        },
        func_cd: null,
        kind_no: null,
        fn_seq_id: null, // 内容管理番号(観察記録等)
        content: null,
        file_info: [],
        notice_start_date: null,
        notice_end_date: null,
        reg_staff_id: null,
        reg_staff_name: null,
        upd_staff_id: null,
        upd_staff_name: null,
        transition_router_path: null,
        reg_date: null,
        up_date: null
      };
      // storeに空を設定
      this.setSelectedBbs(bbsInfo);
      ownerWindow.clearInterval(this.setLoopId);
      Object.assign(this.$data, this.$options.data.call(this))
    },
// add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou start
    mounted(){
      const ownerWindow = this.getBbsOwnerWindow();
      ownerWindow.checkCommentLongPress = this.checkCommentLongPress.bind(this);
      ownerWindow.onDblTap = this.onDblTap.bind(this);
      ownerWindow.endLongTouch = this.endLongTouch.bind(this);
      // add FNSI-改修内容3790bug修正 chen start
      ownerWindow.iframeChange = this.iframeChange.bind(this);
      // add FNSI-改修内容5274bug修正 chen end
      ownerWindow.showPopover1 = this.showPopover1.bind(this);
      // mod FutreNetWeb+SI課題管理No4416対応 趙 start
      // setTimeout(() => {
      ownerWindow.clearInterval(this.setLoopId);
      this.setLoopId  = ownerWindow.setInterval(() => {
      // mod FutreNetWeb+SI課題管理No4416対応 趙 end
        let iframe =  this.getScopedIframes();
        let iframeDocument = null;
        if (iframe.length > 0 && iframe[0] && iframe[0].contentDocument){
          /*add FNSI-改修内容3790 任 start*/
          iframe[0].style.resize = "vertical";
          /*add FNSI-改修内容3790 任 end*/
          iframeDocument = iframe[0].contentDocument;
          iframeDocument.onmousedown = function(){
            ownerWindow.checkCommentLongPress(1);
          }
          iframeDocument.onmouseup = function(){
            ownerWindow.checkCommentLongPress(0);
          }
          iframeDocument.onmousemove = function(){
            // ドラッグ処理が長押し処理と競合する対策
            ownerWindow.checkCommentLongPress(0);
          }
          iframeDocument.onmouseout = function(){
            // ドラッグ処理が長押し処理と競合する対策
            ownerWindow.checkCommentLongPress(0);
          }
          // ダブルクリック処理
          iframeDocument.ondblclick = function(){
            // iOS/Androidでダブルタップのテキスト選択処理の度に発火してしまう為、該当端末の場合は処理をしない
            const ua = getScopedUserAgent(iframeDocument?.documentElement || this.$el);
            if (ua.match(/Android/) || ua.match(/iPhone|iPad/)) {
              return;
            }
            ownerWindow.showPopover1();
          }
          // タップ長押し/ダブルタップ処理
          this.addManagedEventListener(iframeDocument, 'touchstart', ownerWindow.onDblTap, { passive: false });
          this.addManagedEventListener(iframeDocument, 'touchend', ownerWindow.endLongTouch);
        // add FutreNetWeb+SI課題管理No4416対応 趙 start
        // add FNSI-改修内容3790bug修正 chen start
          this.addManagedEventListener(iframeDocument, "keyup", ownerWindow.iframeChange);
          this.addManagedEventListener(iframeDocument, "keydown", ownerWindow.iframeChange);
          iframeDocument.body.style.overflowY = "hidden";
        // add FNSI-改修内容5274bug修正 chen end
        ownerWindow.clearInterval(this.setLoopId);
        // add FutreNetWeb+SI課題管理No4416対応 趙 end
        }
// add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう。 dou start
        this.isChanged = false;
// add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう。 dou end
       });
      // 登録元 = "0"(掲示板)の場合
      if (this.regFuncClass === 0) {
        // HTMLTextInputの設定
        this.setInputHtmlText(this.htmlContent);
      }
      // スクロール位置の初期化
      this.getScopedClassElementSafe("bbs-detail-main").scrollTop = 0;
    },
// add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou end
    async created() {
      // 共通ローダーの表示開始
      this.startLoadingScreen();
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      EventBus.$off("routerName", this.onRouterName);
      EventBus.$off("abanDoning", this.onAbanDoning);
      EventBus.$on("routerName", this.onRouterName);
      EventBus.$on("abanDoning", this.onAbanDoning);
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      EventBus.$on("refresh", this.refresh);
      EventBus.$on("initTitle", this.initTitle);
      await this.initCreated();
      this.isChanged = false;
      // 登録元 = "1"(観察記録)の場合
      if (this.regFuncClass === 1) {
        // HTMLTextInputの設定
        this.setInputHtmlText(this.htmlContent);
      }
      // 端末判別
      if (getScopedUserAgent(this.$el).match(/Android/)) {
        this.androidFlg = true;
      }
      // 共通ローダーの表示終了
      this.finishLoadingScreen();
    },

    methods: {

      onRouterName(data) {
        this.routerName = data;
      },
      onAbanDoning(data) {
        this.abanDoning = data;
      },
      clearManagedRuntimeHandlers() {
        if (Array.isArray(this._managedEventDisposers)) {
          while (this._managedEventDisposers.length) {
            try {
              this._managedEventDisposers.pop()?.();
            } catch (_error) {
              // noop
            }
          }
        }
        if (Array.isArray(this._managedTimeouts)) {
          const ownerWindow = this.getBbsOwnerWindow();
          this._managedTimeouts.forEach((timerId) => ownerWindow.clearTimeout?.(timerId));
          this._managedTimeouts = [];
        }
      },
      addManagedEventListener(target, eventName, handler, options) {
        if (!target?.addEventListener || typeof handler !== "function") {
          return handler;
        }
        this._managedEventDisposers = this._managedEventDisposers || [];
        target.addEventListener(eventName, handler, options);
        this._managedEventDisposers.push(() => target.removeEventListener?.(eventName, handler, options));
        return handler;
      },
      setManagedTimeout(handler, delay = 0) {
        const ownerWindow = this.getBbsOwnerWindow();
        this._managedTimeouts = this._managedTimeouts || [];
        const timerId = ownerWindow.setTimeout?.(() => {
          this._managedTimeouts = (this._managedTimeouts || []).filter((id) => id !== timerId);
          handler?.();
        }, delay);
        if (timerId !== undefined && timerId !== null) {
          this._managedTimeouts.push(timerId);
        }
        return timerId;
      },
      scopedJQuery() {

        return createScopedJQuery(this.$el || this, $$) || $$;

      },
      getBbsOwnerWindow() {
        return getScopedWindow(this.$el) || window;
      },
      getScopedElementByIdSafe(id) {
        return getScopedElementById(id, this.$el || null);
      },
      getScopedClassElementSafe(className) {
        return getScopedElementsByClassName(className, this.$el || null)[0] || null;
      },
      getScopedIframes() {
        return getScopedElementsByTagName("iframe", this.$el || null);
      },
      getScopedSelectorSafe(selector) {
        return queryScopedSelector(selector, this.$el || null);
      },
      getRichTextEditor() {
        return getNativeEditorWidget(this.scopedJQuery()("#editor-input"));
      },

      isEdited(dateField) {
        // selectedBbs: 編集前、bbsDetailedInfo: 編集後
        let beforeVal = this.selectedBbs[dateField];
        let afterVal = this.bbsDetailedInfo[dateField];

        // 日付で値が設定されている場合は"-"を除去して判定する
        if (dateField.includes("date")) {
          beforeVal = beforeVal ? beforeVal.replace(/-/g, "") : null;
          afterVal = afterVal ? afterVal.replace(/-/g, "") : null;
        }
        // 開始時刻、終了時刻で値が設定されている場合は":"を除去して判定する
        if (dateField.includes("time")) {
          beforeVal = this.formatTimeValue(beforeVal);
          afterVal = this.formatTimeValue(afterVal);
        }
        if (beforeVal != afterVal) {
          if (dateField.includes("date")) {
            return "date-input-edited";
          }
          if (dateField.includes("time")) {
            return "time-input-edited";
          }
        }
        return "";
      },
      formatTimeValue(value) {
        const formattedValue = value?.replace(/:/g, "");
        return (formattedValue === "" || formattedValue === "0000" || formattedValue === "2359") ? null : formattedValue;
      },
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      refresh () {
        // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
        // if (this.routerName !== null) {
        //   return
        // }
        // this.count++
        // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
        if (this.isNotEdited) {
          this.keyJudgment = 1
          this.KeyRefresh++
          this.initBbsDetailInfo();
          // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
          // this.count = 0
        // } else if (!this.isNotEdited && this.count == 1 && this.routerName !== 'bbs-info') {
        } else if (!this.isNotEdited && this.routerName !== 'bbs-info') {
          // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
            this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
       // title: "内容破棄",
        title: DIALOG_MESSAGES[13000004].title,
        // message: "編集内容が破棄されます。</br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000004].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            EventBus.$emit("answer", answer);
            EventBus.$emit("initTitle", this.initTitle);
            EventBus.$off("abanDoning", this.onAbanDoning);
            EventBus.$on("abanDoning", this.onAbanDoning);
            this.keyJudgment = 1
            this.KeyRefresh++
            this.abanDoning++
            // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
            // this.count = 0
            // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
          } else {
            // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
            // this.count = 0
            // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
        }
        }
      });
        }
        this.routerName = null
      },
      // タイトルの初期化
      initTitle() {
        // "input-title"の取得
        const inputTitle = this.getScopedElementByIdSafe("input-title");
        // class = "content-change"を含む場合
        if (inputTitle.classList.contains("content-change")) {
          // class = "content-change"の削除
          inputTitle.classList.remove("content-change");
        }
      },
      // 掲示板詳細の初期化
      initBbsDetailInfo() {
        // DOMの更新完了
        this.$nextTick(async () => {
          // 共通ローダーの表示開始
          this.startLoadingScreen();
          // HTMLTextInputの設定
          this.setInputHtmlText(this.oldContent);
          // 初期化処理
          await this.initCreated();
          // 共通ローダーの表示終了
          this.finishLoadingScreen();
        })
      },
      // 共通ローダーの設定
      ...mapActions("loading-screen", [
        "startLoadingScreen",
        "finishLoadingScreen",
      ]),
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      // mod 8220 施設イベント詳細画面の表示が遅い 関 start
      // ...mapActions("bbs-info", ["setSelectedBbs", "setSearchedList", "setSelectCreatedBbs"]),
      ...mapActions("bbs-info", ["setSelectedBbs", "setSearchedList", "setSelectCreatedBbs","setIsLoadingBbs"]),
      // mod 8220 施設イベント詳細画面の表示が遅い 関  end
      ...mapActions("facility-calendar", ["setViewMode"]),
      // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
      ...mapActions("mst-weight", {
        setIsGridEditing: "setIsGridEditing"
      }),
      // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
      popoverPreShow,
      popoverPostShow,
      popoverPosthide,
      updateScrollbarWidth() {
        const tableBody = queryScopedSelector(
          ".disp_target_popover .table-body",
          this.$el || null
        );
        if (!tableBody) {
          return;
        }
        const scrollbarWidth = tableBody.offsetWidth - tableBody.clientWidth;
        const ownerDocument = tableBody.ownerDocument || document;
        ownerDocument.documentElement.style.setProperty(
          "--scrollbar-width",
          `${scrollbarWidth}px`
        );
      },
      onPopoverShow() {
        this.updateScrollbarWidth();
        this.getBbsOwnerWindow().addEventListener("resize", this.updateScrollbarWidth);
      },
      onPopoverHide() {
        this.getBbsOwnerWindow().removeEventListener("resize", this.updateScrollbarWidth);
      },

      /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou start*/
      /**
       * 定型文ポップオーバー表示
       */
      showPopover1() {
        this.popoverData.popoverVisible = true;
      },

      // add 保存の時データ廃棄の提示が出てしまう 陳 start
      async initCreated() {
        // add FNSI7321-スタッフカードでのサインイン時、施設イベント詳細画面が編集できる状態とならない。 周 start
        const accountUserId = this.getStateUserAccountInfo.userId;
        // add FNSI7321-スタッフカードでのサインイン時、施設イベント詳細画面が編集できる状態とならない。 周 end

        // 利用者、患者、掲示板種別マスタ取得
        const [
          responseBbsKind,
          responsePersonalUser,
          responseJobName,
          ,
          responseUser
        ] = await Promise.all([
          ApiHelper.get(uriBbsKind, {
            facilityCd: this.facilityCd
          }),
          ApiHelper.get(uriPersonalUser, {
            facility_cd: this.facilityCd
          }),
          /*add FNSI-改修内容掲示板外结No.10 任 start*/
          ApiHelper.get(uriJobName).catch(() => ({ data: [] })),
          // mod 8220 施設イベント詳細画面の表示が遅い 関 start
          // ApiHelper.get(uriIsSame),
          ApiHelper.post(uriIsSame, [this.facilityCd]),
          // mod 8220 施設イベント詳細画面の表示が遅い 関  end
          /*add FNSI-改修内容掲示板外结No.10 任 end*/
          // mod FNSI7321-スタッフカードでのサインイン時、施設イベント詳細画面が編集できる状態とならない。 周 start
          ApiHelper.get(`${uriUser}/${accountUserId}`)
          // mod FNSI7321-スタッフカードでのサインイン時、施設イベント詳細画面が編集できる状態とならない。 周 end
        ]).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('BbsDetailedInfoContent.vue', 'initCreated', 'DB取得失敗');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

          // console.log(`API:"[PatBbsDetailedContent.vue]created(): DB取得失敗");
          // console.log(error);
        });

        const mstPersonalUser = Array.isArray(responsePersonalUser?.data) ? responsePersonalUser.data : [];
        // スタッフ選択肢
        //const mstPersonalUser = responsePersonalUser.data;
        // xie add メモリにて利用者マスタ一覧取得 End
        /*add FNSI-改修内容掲示板外结No.10 任 start*/
        const jobNameList = Array.isArray(responseJobName?.data) ? responseJobName.data : [];
        mstPersonalUser.forEach(item => {
          jobNameList.forEach(name => {
            if(Number(item.jobCd) === name.jobCd){
              item.jobName = name.jobName;
            }
          })
        })
        /*add FNSI-改修内容掲示板外结No.10 任 end*/
        this.jobList = jobNameList;
        this.jobList.unshift({
          jobCd: null,
          jobName: ""
        })
        // 選択肢から自身を除外、個人設定では常に選択状態へ
        this.mstPersonalUser = mstPersonalUser.filter(
          mst => mst.userId !== this.userId
        );

        /*add FNSI-改修内容掲示板外结No.10 任 end*/
        // 患者の検索結果から必要なカラムのみ取り出す
        /*mod FNSI-改修内容掲示板外结No.10 任 start*/
        /*this.patInfo = patInfo.map(pat => {
            return {
              pat_id: pat.pat_id,
              pat_name: `${pat.pat_last_name} ${pat.pat_first_name}`
            };*/

        // カテゴリ掲示板選択肢

        this.mstBbsKind = responseBbsKind.data;

        // 個人設定から自動既読機能の状態を取得
        const userSettings = responseUser.data.userAccountInfo.userSettings;

        // 通知有無の初期化
        this.isNotification = false;

        // 掲示板詳細初期状態設定
        await this.setSelectedBbsInfo();

        if (
          Object.prototype.hasOwnProperty.call(userSettings, "personal_settings") &&
          userSettings.personal_settings.length !== 0) {
          // 掲示板の個人設定があれば参照
          const settings = userSettings.personal_settings;
          const settingBbsItem = [
            "auto_read",
            "search_category",
            "sort_column",
            "sort_kind"
          ];

          const personalSettingsBbs = settings.find(setting => {
            const bbsItems = setting.values.filter(item =>
              settingBbsItem.includes(item.setting_identifier)
            );
            return bbsItems.length === 4;
          });

          if (personalSettingsBbs !== undefined) {
            const settingBbsList = personalSettingsBbs.values;

            settingBbsList.forEach(item => {
              if (item.setting_identifier === "auto_read") {
                this.settingBbs.auto_read = JSON.parse(item.value);
              }
            });
          }
        }

        if (
          this.mstBbsKind &&
          this.mstBbsKind.length != 0 &&
          !this.bbsDetailedInfo.bbs_ctl_no
        ) {
          // v-modelで数字が文字列になるため、数字変換
          const bbsKind = this.mstBbsKind[0];
          this.bbsDetailedInfo.func_cd = "020";
          this.bbsDetailedInfo.content = bbsKind.defaultContents;
          /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
          this.bbsDetailedInfo.html_content = bbsKind.defaultContents;
          /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
          this.bbsDetailedInfo.title = bbsKind.defaultTitle;
        }
        /*mod FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
        /*this.oldContent = this.bbsDetailedInfo.content;*/
          this.oldContent = this.bbsDetailedInfo.html_content;
        /*mod FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
        this.oldTitle = this.bbsDetailedInfo.title;
        this.checkedAuthority = this.getStateUserAccountInfo.userSettings.authorized_authorities;
        this.isCreated = true;
		    this.oldValue = {};
        this.oldValue = JSON.parse(JSON.stringify(this.bbsDetailedInfo));
        this.isTrueChange();
        /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
        this.setDataHtmlText();
        this.editDataHtmlText();
        /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
        // add 8220 施設イベント詳細画面の表示が遅い 関 start
        this.setIsLoadingBbs(false);
        // add 8220 施設イベント詳細画面の表示が遅い 関  end
      },
      // add 保存の時データ廃棄の提示が出てしまう 陳 end

      /**
       * 定型文ポップオーバー非表示
       */
      closePopover() {
        this.popoverData.popoverVisible = false;
      },
      /**
       * 定型文の挿入
       */
      selectPhrase(data) {
        let editor = this.getRichTextEditor();
        editor.exec("insertHTML", {
          value:
            "<span style='font-family: Meiryo; font-size: 14pt;'>" +
              replaceLtGt(data?.text || '') +
            "</span>"
        });
      },

      // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
      async editStart() {
        if (this.androidFlg) {
          await this.setIsGridEditing(true);
        }
      },
      editEnd() {
        this.setIsGridEditing(false);
      },
      changeFormColor() {
        // this.colorSetting = this.backgroundColor;
        this.isTrueChange();      
      },
      changeFormFontColor() {
        // this.fontColorSetting = this.fontColor;
        this.isTrueChange();
      },
      // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
      popoverTargetElement() {
        let editor = this.scopedJQuery()("#editor-input");
        if (editor.length > 0) {
          return editor[0].previousSibling;
        }
      },
      /**
       * @description 「コメント」テキストエリアの長押しウォッチャー
       */
      checkCommentLongPress(isMouseDown) {
        const ownerWindow = this.getBbsOwnerWindow();
        if (isMouseDown) {
          this.commentTimer = this.setManagedTimeout(() => {
            ownerWindow.showPopover1();
          }, 500);
        } else {
          ownerWindow.clearTimeout(this.commentTimer);
        }
      },
      /*add FNSI-改修内容 掲示板内容を長押して、共通定形文のポップアップが出てこない。 dou end*/
      /**
       * @description 「コメント」テキストエリアのダブルタップ/長押しタップウォッチャー
       */
      onDblTap(event) {
        const ownerWindow = this.getBbsOwnerWindow();
        if (event.touches.length > 1) {
          // 2本以上同時にタップされた場合の処理(長押し処理を発火)
          ownerWindow.setShowPopover = this.setManagedTimeout(() => {
            ownerWindow.showPopover1();
          }, 500);
        }
        if(!this.tapedTwice) {
          this.tapedTwice = true;
          this.setManagedTimeout(() => { this.tapedTwice = false; }, 300);
          return false;
        }
        event.preventDefault();
        ownerWindow.showPopover1();
      },
      endLongTouch(event) {
        if (event.touches.length < 1) {
          // 全ての指が離れたら長押し処理を解除
          this.getBbsOwnerWindow().clearTimeout(this.getBbsOwnerWindow().setShowPopover);
        }
      },
      // add FNSI-改修内容3790bug修正 chen start
      iframeChange() {
        let iframe =  this.getScopedIframes();
        iframe[0].style.height = "150px";
        this.$nextTick(() => {
          if (iframe[0].contentDocument.scrollingElement.scrollHeight > 150) {
            iframe[0].style.height = iframe[0].contentDocument.scrollingElement.scrollHeight + "px";
          }
        });
      },
      // add FNSI-改修内容3790bug修正 chen start
      /**
       * @description 画面に表示する初期状態を設定
       */
      async setSelectedBbsInfo() {
        this.bbsDetailedInfo = deepCopy(this.selectedBbs);

        // DBに登録しているスタッフを選択ボタンの一覧に設定
        if (!this.bbsDetailedInfo.bbs_ctl_no) {
          // 選択していたスタッフ全て初期化
          this.selectedStaffList = [];
          // スタッフ設定
          this.setAllUser();
          // スタッフラジオボタン設定
          this.staffRadioValue = "1";
          // 障害票一覧_NKK No3709 修正 chen start
          this.bbsDetailedInfo.staff_info.read = [];
          // 障害票一覧_NKK No3709 修正 chen end
        } else {
          if (this.bbsDetailedInfo.staff_info.target.length === 0) {
            // スタッフラジオボタン設定
            this.staffRadioValue = "1";
          } else {
            // スタッフラジオボタン設定
            this.staffRadioValue = "0";
          }
          // DBに登録されているスタッフ
          // 選択ボタンの選択肢用にコードと名前を設定
          const staffInfoList = this.bbsDetailedInfo.staff_info.read.map(
            staff => {
              const staffCd = staff;
              const readState = "1";

              // DBの自身の情報を引き継ぎ
              if (staffCd === this.userId) {
                return {
                  cd: staffCd,
                  name: this.userName,
                  // 自動既読機能ONなら詳細画面開いた時点で「既読: "1"」へ
                  readState: this.settingBbs.auto_read ? "1" : readState
                };
              }

              const userName = this.mstPersonalUser.find(
                mst => mst.userId === staffCd
              );
              if (userName) {
                return { cd: staffCd, name: userName.userName, readState };
              }
            }
          );

          // 選択可能スタッフと選択済スタッフをマージ
          for (const target of this.bbsDetailedInfo.staff_info.target) {
            const read = this.bbsDetailedInfo.staff_info.read.find(
              e => e === target
            );
            if (!read) {
              const readState = "0";
              // DBの自身の情報を引き継ぎ
              if (target === this.userId) {
                staffInfoList.push({
                  cd: target,
                  name: this.userName,
                  // 自動既読機能ONなら詳細画面開いた時点で「既読: "1"」へ
                  readState: this.settingBbs.auto_read ? "1" : readState
                });
              }
              const userName = this.mstPersonalUser.find(
                mst => mst.userId === target
              );
              if (userName) {
                staffInfoList.push({
                  cd: target,
                  name: userName.userName,
                  /*mod FNSI-改修内容掲示板外结 任 start*/
                  /*readstate: readState*/
                  readState: readState
                  /*mod FNSI-改修内容掲示板外结 任 end*/
                });
              }
            }
          }

          // 存在しないスタッフ削除
          this.selectedStaffList = staffInfoList.filter(staff => staff);
          if (this.staffRadioValue === ALL_USER) {
            // 新規追加スタッフ設定 ※上記でDB値を引き継ぎ後処理させる
            this.setAllUser();
          }
          this.oldselectedStaffList = JSON.parse(
	        JSON.stringify(this.selectedStaffList)
	      );
        }

        if (
          this.bbsDetailedInfo.func_cd === "020" &&
          this.bbsDetailedInfo.kind_no === null &&
          this.mstBbsKind.length !== 0
        ) {
          // カテゴリ初期値設定
          this.bbsDetailedInfo.kind_no = this.mstBbsKind[0].kindNo;
        }

        // DBに登録している患者を選択ボタンの一覧に設定
        // 選択ボタンの選択肢用にコードと名前を設定
        const patResp = await ApiHelper.post(
          uriPat,
          this.bbsDetailedInfo.pat_info.detail
        ).catch(() => {
          getErrorMessage("BbsDetailInfoContent.vue", uriPat, "DB取得失敗");
        });

        this.selectedPatList = this.bbsDetailedInfo.pat_info.detail.map(patId => {
          // mod 障害票一覧_掲示板 修正 chen start
          let patInfoTmp = patResp.data.find(info => info.pat_id === patId);
          let patName = "";
          if (patInfoTmp) {
            patName = `${patInfoTmp.pat_last_name == null ? "" : patInfoTmp.pat_last_name} ${patInfoTmp.pat_first_name == null ? "" : patInfoTmp.pat_first_name}`;
          }
          // const patName = this.patInfo.find(info => info.pat_id === patId)
          //   .pat_name;
          // mod 障害票一覧_掲示板 修正 chen end
          return { cd: patId, name: patName };
        });
        this.oldselectedPatList = JSON.parse(
          JSON.stringify(this.selectedPatList)
      	);
        // 自身の既未読状態
        /*  add FNSI-549 改修内容 一度詳細を表示したら自動的に「既読」にする 趙立強 start*/
        //mod 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　start
        // this.userReadState = true;
        // this.userReadState = this.isUserRead;
        this.initialReadState = this.isUserRead;
        this.userReadState = true;
        if (!this.initialReadState) {
          this.updStaffInfo("1");
        }
        //mod 掲示板：クリックして詳細ページページに入ると、既読ボタンが不正表示される 関　end
        // this.userReadState = true;
        // add bug #4102 修正 chen start
        // del FNSI-7278 劉全航 start
        //this.updStaffInfo("1");
        // del FNSI-7278 劉全航 end
        // add bug #4102 修正 chen end
        /*add FNSI-改修内容掲示板外结 任 start*/
        this.selectedStaffList.forEach(item => {
          if( this.userId === item.cd){
            item.readState = "1";
          }
        })
        /*add FNSI-改修内容掲示板外结 任 end*/
        /*  add FNSI-549 改修内容 一度詳細を表示したら自動的に「既読」にする 趙立強 end*/

        // 患者の全・個別選択ラジオボタン設定
        this.patRadioValue = this.bbsDetailedInfo.pat_info.target;

        // 掲載期間設定
        this.bbsDetailedInfo.notice_start_date = this.formatDate(
          this.bbsDetailedInfo.notice_start_date
        );
        this.bbsDetailedInfo.notice_end_date = this.formatDate(
          this.bbsDetailedInfo.notice_end_date
        );
        /*  mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
        // 掲載期間設定
        // this.notice_fac_cal_start_time = this.formatTime(
        //   this.bbsDetailedInfo.notice_fac_cal_start_date
        // );
        this.bbsDetailedInfo.notice_fac_cal_start_date = this.formatDate(
          this.bbsDetailedInfo.notice_fac_cal_start_date
        );
        // this.notice_fac_cal_end_time = this.formatTime(
        //   this.bbsDetailedInfo.notice_fac_cal_end_date
        // );
        this.bbsDetailedInfo.notice_fac_cal_end_date = this.formatDate(
          this.bbsDetailedInfo.notice_fac_cal_end_date
        );
        /*  mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
        this.bbsDetailedInfo.is_disp_bbs = this.selectedBbs.is_disp_bbs;
        /*  add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_施設イベント 20240305 ztc start
        // if(this.selectedBbs.is_disp_bbs == 2){
        //   //施設カレンダー掲載
        //   this.disp_bbs = "1";
        // }else if(this.selectedBbs.is_disp_bbs == 3){
        //   //施設カレンダー掲載 + 掲示板掲載(1)
        //   this.disp_bbs = "1";
        //   this.bbsDetailedInfo.is_disp_bbs= "1";
        // }
        if(this.selectedBbs.is_disp_bbs == 2 || this.selectedBbs.is_disp_bbs == 3){
          //1 = 掲示板掲載
          //2 = 施設カレンダー掲載     3 = 施設カレンダー掲載 掲示板掲載
          this.disp_bbs = true;
          this.olddisp_bbs = JSON.parse(JSON.stringify(this.disp_bbs));
          this.bbsDetailedInfo.is_disp_bbs = "1";
        } else {
          this.disp_bbs = false;
          this.olddisp_bbs = JSON.parse(JSON.stringify(this.disp_bbs));
        }
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_施設イベント 20240305 ztc end

        //施設カレンダーイベント開始時刻,施設カレンダーイベント終了時刻判定を表示する
       if(this.selectedBbs.is_time_start_flg == 0){
          this.bbsDetailedInfo.notice_fac_cal_start_time = "";
        }else{
          this.bbsDetailedInfo.notice_fac_cal_start_time = this.selectedBbs?.notice_fac_cal_start_time?.slice(0,2) + ":" + this.selectedBbs?.notice_fac_cal_start_time?.slice(2);
        }
        // console.log( this.bbsDetailedInfo.notice_fac_cal_start_time);
        if(this.selectedBbs.is_time_end_flg == 0){
          this.bbsDetailedInfo.notice_fac_cal_end_time = "";
        }else{
          this.bbsDetailedInfo.notice_fac_cal_end_time = this.selectedBbs?.notice_fac_cal_end_time?.slice(0,2) + ":" + this.selectedBbs?.notice_fac_cal_end_time?.slice(2);
        }
        /*  add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
        this.bbsDetailedInfo.content = this.selectedBbs.content;
        // del FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
        // this.selectedColor = this.bbsDetailedInfo.color;
        // del FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
        // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
        // 親画面から配色設定JSONデータ取得
      this.backgroundColor = this.selectedBbs.color || "#ffffff";
      // if (this.colorSetting === undefined || this.colorSetting === null) {
      //   this.backgroundColor = "#ffffff";
      // } else {
      //   this.backgroundColor = this.colorSetting;
      // }
      this.oldbackgroundColor = JSON.parse(
        JSON.stringify(this.backgroundColor)
      );

      this.fontColor = this.selectedBbs.font_color || "#000000";
      this.oldfontColor = JSON.parse(JSON.stringify(this.fontColor));
      // if (this.fontColorSetting === undefined || this.fontColorSetting === null) {
      //     this.fontColor = "#000000";
      //   } else {
      //     this.fontColor = this.fontColorSetting;
      //   }        // add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
        this.$nextTick(() => {
          // 前に表示していた高さを継承するため高さをリセット
          if (this.getScopedElementByIdSafe("textarea-content")) {
            this.getScopedElementByIdSafe("textarea-content").style.height = "auto";
            const el = this.getScopedElementByIdSafe("textarea-content");
            this.resizeTextarea(el);
          }
        });
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
        this.bbsNotice = this.disp_bbs;
        this.bbsIsNotification = this.isNotification;
        this.oldisNotification = JSON.parse(JSON.stringify(this.isNotification));
        this.bbsTitle = this.bbsDetailedInfo.title
        this.bbsBackgroundColor = this.backgroundColor;
        this.bbsFontColor = this.fontColor;
        if(this.bbsNotice === undefined || this.bbsNotice === false){
          this.bbsNotice = 0;
        } else {
          this.bbsNotice = 1;
        }
        // add 掲示板で登録済みの内容を表示した後キャンセルで元の画面に戻ろうとすると内容破棄のメッセージが表示される 6185  関 start
      },

      /**
       * @description 各カテゴリ種別マスタ
       * @param {String} funcCd カテゴリ機能コード
       * @returns {Object} {code: 一意, name: カテゴリ名}
       */
      getKindList(funcCd) {
        // カテゴリ機能コードに一致した各カテゴリ種別マスタを返す
        // TODO:機能コード一覧(funcList)が追加と伴って追加する必要あり
        let kindList = [];
        switch (funcCd) {
          case FUNC_BBS_INFO:
            kindList = this.mstBbsKind;
            break;
        }

        return kindList;
      },
      /*  del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
      // /**
      //  * @description input内部データへフォーマットを変更
      //  */
      // formatTime(date) {
      //   return date === null ? null : dayjs(date).format("HH:mm");
      // },
      /*  del FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
      /**
       * @description input内部データへフォーマットを変更
       */
      formatDate(date) {
        return date === null ? null : dayjs(date).format("YYYY-MM-DD");
      },

      /**
       * @description コンポーネントを再利用させないためのkey属性値(現在日時+文字列)
       * @summary コンポーネントの再利用によって選択項目やフィルタに設定した値が残ったままになるのを防ぐ
       * @param {String} str 任意の文字列 ※コンポーネントごとに変えること
       * @returns {String} YYYYMMDDHHmmssSSS
       */
      componentKey(str) {
        return `${dayjs().format("YYYYMMDDHHmmssSSS")}${str}`;
      },

      /**
       * @description スタッフ選択処理
       */
      async listSelectStaff() {
        this.staffSelectorData = await this.createStaffSelectorData();
        this.isStaffSelectorVisible = true;
      },

      /**
       * @description 患者選択処理
       */
      async listSelectPat() {
        this.patSelectorData = await this.createPatSelectorData();
        this.isPatSelectorVisible = true;
      },

      /**
       * @description スタッフ選択肢作成
       */
      async createStaffSelectorData() {
        const title = "スタッフ";
        const class1 = null;
        const class2 = null;

        // 既に選択済みならデフォルト選択リストを設定
        const defaultSelection = _.isEmpty(this.selectedStaffList)
          ? []
          : this.selectedStaffList.map(item => item.cd);
        /*mod FNSI-改修内容掲示板外结No.10 任 start*/
      /*const itemList = createItemListData(
          this.mstPersonalUser,
          "userId",
          "userName");*/
        const itemList = createItemListDataBbs(
          this.mstPersonalUser,
          "userId",
          "",
          "userName",
          true,
          "",
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
          "",
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
          "jobName",
          "",
          "",
          "",
          "jobCd"
        );
        /*mod FNSI-改修内容掲示板外结No.10 任 end*/

        // const jobList = this.jobList;
        const jobList = this.jobList;

        return { title, itemList, class1, class2, defaultSelection, jobList };
      },

      /**
       * @description 患者選択肢作成
       */
      async createPatSelectorData() {
        const title = "患者";
        const class1 = null;
        const class2 = null;
        // 既に選択済みならデフォルト選択リストを設定
        const defaultSelection = _.isEmpty(this.selectedPatList)
          ? []
          : this.selectedPatList.map(item => item.cd);
        /*mod FNSI-改修内容掲示板外结No.10 任 start*/
          /*const itemList = createItemListData(this.patInfo, "pat_id", "pat_name");*/

        const responsePat = await ApiHelper.post(
          uriPat,
          []
        ).catch(() => {
          getErrorMessage("BbsDetailInfoContent.vue", uriPat, "DB取得失敗");
        });;

        let patList = responsePat.data;

        patList = this.sortPat(patList);

        patList = patList.map(pat => {
          return {
            pat_id: pat.pat_id,
            pat_name: `${pat.pat_last_name == null ? "" : pat.pat_last_name} ${pat.pat_first_name == null ? "" : pat.pat_first_name}`,
            is_same: pat.is_same,
            in_out_class: pat.in_out_class,
            hosp_pat_id: pat.hosp_pat_id
          };
        });

        const itemList = createItemListDataBbs(patList, "pat_id", "hosp_pat_id", "pat_name", false, "is_same", "in_out_class", "");
        /*mod FNSI-改修内容掲示板外结No.10 任 end*/
        return { title, itemList, class1, class2, defaultSelection };
      },

      /**
       * @description リスト選択表示起点
       */
      selectorTarget(refName) {
        return this.$refs[`${refName}`];
      },

      /**
       * @description スタッフ選択確定
       */
      commitStaffListSelect(selectedList) {
        // 選択されたコードと名称を格納
        const selectedStaffList = selectedList.map(selected => {
          // 以前から選択済みのスタッフ既読未読状態引き継ぎ
          const bbsInfo = this.bbsDetailedInfo.staff_info.read.find(
            bbs => bbs === selected.cd
          );
          return {
            cd: selected.cd,
            name: selected.name,
            // 新規選択したスタッフ未読状態
            // 施設カレンダの既読人数が対象スタッフを減らすと合わなくなる  6200  start
            readState: bbsInfo === undefined ? "0" : "1"
            // 施設カレンダの既読人数が対象スタッフを減らすと合わなくなる  6200  end
          };
        });

        // 自身を常に設定
        const userInfo = {
          cd: this.userId,
          name: this.userName,
          readState: this.isUserRead ? "1" : "0"
        };
        this.selectedStaffList = [userInfo, ...selectedStaffList];
        this.isTrueChange();
      },

      /**
       * @description 患者選択確定
       */
      commitPatListSelect(selectedList) {
        // 選択されたコードと名称を格納
        this.selectedPatList = selectedList;
        this.isTrueChange();
      },

      /**
       * @description DB保存
       */
      async saveRecord() {
        if (this.isRegFuncClass) {
          if (!this.validate()) {
            // 未入力項目あり
            this.showDialog();
            return;
          }
        }
        /*add FNSI-改修内容日付のチェックの追加対応。 任 start*/
        if(this.getScopedClassElementSafe("ntss-input-start-date").validationMessage !== ""){
          this.messageDateInfo.isCheckDialogVisible = true;
          this.messageDateInfo.title = DIALOG_MESSAGES[99999996].title;
          this.messageDateInfo.messageCd = 99999996;
          this.messageDateInfo.stringParams = ["イベント開始日時"];
          return;
        }
        if(this.getScopedClassElementSafe("ntss-input-end-date").validationMessage !== ""){
          this.messageDateInfo.isCheckDialogVisible = true;
          this.messageDateInfo.title = DIALOG_MESSAGES[99999996].title;
          this.messageDateInfo.messageCd = 99999996;
          this.messageDateInfo.stringParams = ["イベント終了日時"];
          return;
        }
        if(this.getScopedClassElementSafe("notice_input_start_date").validationMessage !== ""){
          this.messageDateInfo.isCheckDialogVisible = true;
          this.messageDateInfo.title = DIALOG_MESSAGES[99999996].title;
          this.messageDateInfo.messageCd = 99999996;
          this.messageDateInfo.stringParams = ["掲示板掲載開始日時"];
          return;
        }
        if(this.getScopedClassElementSafe("notice_input_end_date").validationMessage !== ""){
          this.messageDateInfo.isCheckDialogVisible = true;
          this.messageDateInfo.title = DIALOG_MESSAGES[99999996].title;
          this.messageDateInfo.messageCd = 99999996;
          this.messageDateInfo.stringParams = ["掲示板掲載終了日時"];
          return;
        }
        if(this.isRegFuncClass){
          let fileName = await this.$refs.fileUploader.fileExistsCheck();
          // アップロード対象ファイルの存在チェックエラー
          if(fileName){
            this.messageFileInfo.isCheckDialogVisible = true;
            this.messageFileInfo.title = DIALOG_MESSAGES[12000349].title;
            this.messageFileInfo.messageCd = 12000349;
            this.messageFileInfo.stringParams = [fileName];
            return;
          }
        }
        /*add FNSI-改修内容日付のチェックの追加対応。 任 start*/
        this.isLoadingBbs = true;
        // 更新日時
        const nowDate = dayjs().format();

        // 編集した値をレコードに設定
        let editedRecord = { ...this.bbsDetailedInfo };
        const bbsCtlNo = editedRecord.bbs_ctl_no;
        // 掲示板画面にタイトルを表示。タイトル+[改行]＋内容。内容の改行は半角スペースとなっているが、これも改行に修正する。
        editedRecord.title = this.bbsDetailedInfo.title && this.bbsDetailedInfo.title.trim();
        editedRecord.content = this.bbsDetailedInfo.content;
        /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
        editedRecord.html_content = this.bbsDetailedInfo.html_content;
        /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
        // 施設カレンダ背景色
        //mod FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
        //editedRecord.color = this.selectedColor ? this.selectedColor : "#FFFFFF";
        editedRecord.color = this.backgroundColor;
        editedRecord.font_color = this.fontColor;
        //mod FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
        /* mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
        // editedRecord.is_disp_bbs = this.bbsDetailedInfo.is_disp_bbs ? "1" : "0";
        if(this.bbsDetailedInfo.is_disp_bbs && this.disp_bbs){

          delete editedRecord.disp_bbs;
          editedRecord.is_disp_bbs = "3";

        }else if(this.bbsDetailedInfo.is_disp_bbs && !this.disp_bbs){

          delete editedRecord.disp_bbs;
          editedRecord.is_disp_bbs = "1";

        }else if(!this.bbsDetailedInfo.is_disp_bbs && this.disp_bbs){

          delete editedRecord.disp_bbs;
          editedRecord.is_disp_bbs = "2";
        }
        /*  mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
        // 掲載期間
        editedRecord.notice_start_date = this.formattedSaveDate(
          editedRecord.notice_start_date
        );
        editedRecord.notice_end_date = this.formattedSaveDate(
          editedRecord.notice_end_date
        );
        // カレンダー表示時間
        /*mod FNSI-改修内容時刻が指定しなくてもイベントが登録できるようにする 王 start */
        /*editedRecord.notice_fac_cal_start_date = this.formattedSaveDate(
          `${editedRecord.notice_fac_cal_start_date} ${this.notice_fac_cal_start_time}:00`
        );
        editedRecord.notice_fac_cal_end_date = this.formattedSaveDate(
          `${editedRecord.notice_fac_cal_end_date} ${this.notice_fac_cal_end_time}:00`);*/
        /*  mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
        // if (this.notice_fac_cal_start_time === null ||this.notice_fac_cal_start_time === ""){
        //   editedRecord.notice_fac_cal_start_date = this.formattedSaveDate(
        //     `${editedRecord.notice_fac_cal_start_date} 00:00:00`
        //   );
        // }else{
        //   editedRecord.notice_fac_cal_start_date = this.formattedSaveDate(
        //     `${editedRecord.notice_fac_cal_start_date} ${this.notice_fac_cal_start_time}:00`
        //   );
        // }
        // if (this.notice_fac_cal_end_time === null ||this.notice_fac_cal_end_time === ""){
        //   editedRecord.notice_fac_cal_end_date = this.formattedSaveDate(
        //     `${editedRecord.notice_fac_cal_end_date} 00:00:00`
        //   );
        // }else{
        //   editedRecord.notice_fac_cal_end_date = this.formattedSaveDate(
        //     `${editedRecord.notice_fac_cal_end_date} ${this.notice_fac_cal_end_time}:00`
        //   );
        // }
        editedRecord.notice_fac_cal_start_date = this.formattedSaveDate(
          editedRecord.notice_fac_cal_start_date
        );
        editedRecord.notice_fac_cal_end_date = this.formattedSaveDate(
          editedRecord.notice_fac_cal_end_date
        );
        if (this.bbsDetailedInfo.notice_fac_cal_start_time === null ||this.bbsDetailedInfo.notice_fac_cal_start_time === ""){
          editedRecord.notice_fac_cal_start_time = this.formattedSaveTime(
            `00:00`
          );
          editedRecord.is_time_start_flg = "0";
        }else{
          editedRecord.notice_fac_cal_start_time = this.formattedSaveTime(
            this.bbsDetailedInfo.notice_fac_cal_start_time
          );
          editedRecord.is_time_start_flg = "1";
        }
        if (this.bbsDetailedInfo.notice_fac_cal_end_time === null ||this.bbsDetailedInfo.notice_fac_cal_end_time === ""){
          editedRecord.notice_fac_cal_end_time = this.formattedSaveTime(
            `23:59`
          );
          editedRecord.is_time_end_flg = "0";
        }else{
          editedRecord.notice_fac_cal_end_time = this.formattedSaveTime(
            this.bbsDetailedInfo.notice_fac_cal_end_time
          );
          editedRecord.is_time_end_flg = "1";
        }
        /*  mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
        /*mod FNSI-改修内容時刻が指定しなくてもイベントが登録できるようにする 王 end */

        // 選択したスタッフ情報設定
        if (this.staffRadioValue === ALL_USER) {
          // 全スタッフ選択
          // 退職、入社等に対応させるため、更新の度、全スタッフを再設定
          this.setAllUser();
        }

        const staffInfo = this.selectedStaffList
          .filter(item => {
            return item.readState === "1";
          })
          .map(item => {
            return item.cd;
          });
        editedRecord.staff_info.read = staffInfo;
        /*add FNSI-改修内容掲示板外结 任 start*/
        // mod bug #4102 修正 chen start
        let indexUserId = editedRecord.staff_info.read.indexOf(this.userId);
        if(indexUserId === -1 && this.userReadState){
        // mod bug #4102 修正 chen end
          /*add FNSI-改修内容掲示板外结 任 end*/
          editedRecord.staff_info.read.push(this.userId);
          /*add FNSI-改修内容掲示板外结 任 start*/
        }
        /*add FNSI-改修内容掲示板外结 任 end*/
        if (this.staffRadioValue === ALL_USER) {
          editedRecord.staff_info.target = [];
        } else {
          editedRecord.staff_info.target = this.selectedStaffList.map(item => {
            return item.cd;
          });
        }

        // 選択した患者ID設定
        const patInfo = this.selectedPatList.map(pat => pat.cd);
        /*add FNSI-改修内容掲示板外结 chen start*/
        const patInfoTmp = this.selectedPatList.map(pat => ({
          cd: pat.cd,
          pat_last_name: pat.name.split(" ")[0],
          pat_first_name: pat.name.split(" ")[1]
        }));
        /*add FNSI-改修内容掲示板外结 chen end*/

        let patTarget = this.patRadioValue;
        if (patInfo.length === 0 && this.patRadioValue === INDIVIDUALLY_USER) {
          // 個別選択で患者が選択されていない場合は「なし」へ
          patTarget = NOT_USER;
        }

        editedRecord.pat_info.target = patTarget;
        editedRecord.pat_info.detail = patInfo;

        // 最終更新者IDに自身を設定
        editedRecord.upd_staff_id = this.userId;
        // 最終更新者名に自身を設定
        editedRecord.upd_staff_name = this.userName;
        editedRecord.up_date = nowDate;
        editedRecord.reg_func_class = 0;

        if (bbsCtlNo === null) {
          // 掲示板番号がnullなら掲示板を新規として登録
          // 起票者・名、登録日時設定
          editedRecord.reg_staff_id = editedRecord.upd_staff_id;
          editedRecord.reg_staff_name = editedRecord.upd_staff_name;
          editedRecord.reg_date = nowDate;
        }

        // ファイル情報設定
        editedRecord.file_info =
          editedRecord.file_info === null ? [] : editedRecord.file_info;
        const serializedRecord = serializeJsonColumn(
          editedRecord,
          this.jsonColumns
        );

        try {
          if (bbsCtlNo === null) {
            const bbsCtlNo = await createBbs(serializedRecord, this.isNotification);
            // 新規登録から更新対象へ変更;
            editedRecord.bbs_ctl_no = bbsCtlNo;
            if (editedRecord) {
              /*add FNSI-改修内容掲示板外结 chen start*/
              editedRecord.pat_info.detail = patInfoTmp;
              /*add FNSI-改修内容掲示板外结 chen end*/
              this.setSelectCreatedBbs(editedRecord);
            }
          } else {
            await updateBbs(serializedRecord, this.isNotification);
          }
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('BbsDetailedInfoContent.vue', 'saveRecord', '編集権限が必要');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
          // this.$ons.notification.alert({
          //   title: "",
          //   message: "編集権限が必要。"
          // });
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['00100003'].title,
            message: messageFormat(DIALOG_MESSAGES['00100003'].message)
          });
          // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
        }

        if (this.$refs.fileDownloader.removedFiles.length !== 0) {
          await this.$refs.fileDownloader.checkForDeletedFiles(
            editedRecord.bbs_ctl_no
          );
        }
        //mod FutreNetWeb+SI課題管理No4617対応 呉 start
        // this.$refs.fileUploader.upload(editedRecord);
        // mod #9818、「患者イベント」と「観察記録」画面で作成した観察記録は掲示板に編集したい時、コンソールエラーが発生の修正 limf start
        if(this.isRegFuncClass){
          await this.$refs.fileUploader.upload(editedRecord);
        }else{
          await this.setSelectedBbsInfo(this.bbsCtlNo);
          this.search();
          this.isLoadingBbs = false;
          this.$router.go(-1);
        }
        // mod #9818、「患者イベント」と「観察記録」画面で作成した観察記録は掲示板に編集したい時、コンソールエラーが発生の修正 limf start
        //mod FutreNetWeb+SI課題管理No4617対応 呉 end
        if (editedRecord) {
          EventBus.$emit("addNew", true);

          if (this.validate()) {
            /*del FNSI-改修内容redmine4029 任 start*/
            //this.setViewMode(1);
            /*del FNSI-改修内容redmine4029 任 end*/
            EventBus.$emit("customRefreshPage");
          }
        }
        // add 保存の時データ廃棄の提示が出てしまう 陳 start
        this.isChanged = false;
        // add 保存の時データ廃棄の提示が出てしまう 陳 end
      },

      /**
       * @description スタッフラジオボタン値を設定
       * @param {String}
       */
      changeStaffRadioValue(value, e) {
        e.checked = true;
        this.staffRadioValue = value;
        //      this.bbsDetailedInfo.staff_info.target = value;
        if (this.isSelectedIndividualStaff) {
          // 個別選択時
          this.setUser();
        } else {
          this.setAllUser();
        }
      },

      /**
       * @description 患者ラジオボタン値を設定
       * @param {String}
       */
      changePatRadioValue(value, e) {
        e.checked = true;
        this.patRadioValue = value;
        this.bbsDetailedInfo.pat_info.target = value;
        this.selectedPatList = [];
      },

      /**
       * @description 掲示板一覧へ戻る
       */
      cancel() {
        this.$router.go(-1);
      // add FNSI-改修内容6185修正 関 start
        this.isChanged = this.showBtnChanged;
      // add FNSI-改修内容6185修正 関　end
      },

      /**
       * @description トグルの既読未読状態を切り替える
       */
      changeUserReadState(value) {
        const userReadState = value ? "1" : "0";
        // 選択したスタッフから自身の既未読状態を変更
        this.selectedStaffList = this.selectedStaffList.map(item => {
          if (item.cd === this.userId) {
            item.readState = userReadState;
          }
          return item;
        });
        // add bug #4102 修正 chen start
        this.updStaffInfo(userReadState);
        // add bug #4102 修正 chen end
      },

      // add bug #4102 修正 chen start
      updStaffInfo(userReadState) {
        if (this.bbsDetailedInfo && this.bbsDetailedInfo.bbs_ctl_no) {
          let staffInfo = deepCopy(this.bbsDetailedInfo.staff_info);
          const hasUserId = staffInfo.read.findIndex(
            staffInfo => staffInfo === this.userId
          );
          if (hasUserId === -1 && userReadState === "1") {
            // スタッフ情報が存在しない
            staffInfo.read.push(this.userId);
          } else if (hasUserId !== -1 && userReadState === "0") {
            staffInfo.read.splice(hasUserId, 1);
          }

          // 更新日時
          const nowDate = dayjs().format();
          // DB更新
          updateBbsList(
            [{bbs_ctl_no: this.bbsDetailedInfo.bbs_ctl_no, staff_info: staffInfo}],
            this.userId,
            this.userName,
            nowDate
          );
          this.bbsDetailedInfo.staff_info = staffInfo;
          this.bbsDetailedInfo.up_date = nowDate;
          // add FNSI-改修内容5554修正 関　start
          this.setSelectCreatedBbs(this.bbsDetailedInfo);
          // add FNSI-改修内容5554修正 関　end

        }
      },
      // add bug #4102 修正 chen end

      /**
       * @description 検索
       */
      async search() {
        const searchCondition = { ...this.selectedCondition };
        searchCondition.noticeStartDate = this.formattedDate(
          searchCondition.noticeStartDate
        );
        searchCondition.noticeEndDate = this.formattedDate(
          searchCondition.noticeEndDate
        );
        searchCondition.dialysisDate = this.formattedDate(
          searchCondition.dialysisDate
        );

        // 検索結果の掲示板、患者名をstoreに設定
        await this.setSearchedList({
          selectedCondition: searchCondition,
          facilityCd: this.facilityCd
        });
      },

      /**
       * @description フォーマット変更
       */
      formattedDate(value) {
        if (value === null || value === "") {
          return null;
        }
        return formatDatetime(value, "YYYYMMDD");
      },

      /**
       * @description フォーマット変更
       */
      formattedSaveDate(value) {
        if (value === null || value === "") {
          return null;
        }
        /*  mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
        // return dayjs(value).format();
        return dayjs(value).format("YYYYMMDD");
        /*  mod FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
      },
      /*  add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
      /**
       * @description フォーマット変更
       */
      formattedSaveTime(value) {
        if (value === null || value === "") {
          return null;
        }
        var hours = value.slice(0,2);
        var minutes = value.slice(3);
        return hours + "" + minutes;
      },
      /*  add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
      /**
       * @description 機能コードを設定
       */
      setCategoryInfo(kindNo) {
        this.$ons.notification
          .confirm({
            title: DIALOG_MESSAGES[70000035].title,
            message: messageFormat(DIALOG_MESSAGES[70000035].message)
          })
          .then(answer => {
            if (answer === 1) {
              this.oldContent = this.bbsDetailedInfo.content;
              this.oldTitle = this.bbsDetailedInfo.title;
              // はい
              // v-modelで数字が文字列になるため、数字変換
              const bbsKind = this.mstBbsKind.find(
                mst => mst.kindNo === Number(kindNo)
              );
              this.bbsDetailedInfo.func_cd = "020"; 
              this.bbsDetailedInfo.content = bbsKind.defaultContents;
              // add/ #12473 掲示板画面で複数バグ tianqidong start
              this.$nextTick(() => {
              const editor = this.getRichTextEditor();
                if (editor) {
                  editor.body.innerHTML = "";
                  let defaultContents = bbsKind.defaultContents != null ? bbsKind.defaultContents : ''
                  editor.exec("insertHTML", {value: "<p><span style='font-family: Meiryo; font-size: 14pt;'>" + defaultContents + "</span></p>"});
                }
              });

              this.bbsDetailedInfo.title = bbsKind.defaultTitle;
              // add 障害票一覧_掲示板 修正 chen start
              this.bbsDetailedInfo.html_content = bbsKind.defaultContents;
              let iframe =  this.getScopedIframes();
              //if (iframe.length > 0 && iframe[0] && iframe[0].contentDocument){
              if (
                iframe.length > 0 &&
                iframe[0].contentDocument &&
                iframe[0].contentDocument.children[0] &&
                iframe[0].contentDocument.children[0].children[1] &&
                iframe[0].contentDocument.children[0].children[1].children[0]){
                // add/ #12473 掲示板画面で複数バグ tianqidong end
                let parent = iframe[0].contentDocument.children[0].children[1];
                parent.children[0].innerText = bbsKind.defaultContents;
                let pObjs = parent.childNodes;
                for (let i = pObjs.length - 1; i >= 1; i--) {
                  parent.removeChild(pObjs[i]);
                }
                // add #9498 新規登録時に内容欄のフォント、フォントサイズが表示内容と異なる。linjunfeng start
                let editor = this.getRichTextEditor();
                if (editor) {
                  editor.body.innerHTML = "";
                  editor.exec("insertHTML", {value: "<p style='font-size: 14pt; font-family: メイリオ;'></p>"});
                }
                // add #9498 新規登録時に内容欄のフォント、フォントサイズが表示内容と異なる。linjunfeng end
              }
              // add 障害票一覧_掲示板 修正 chen end
            }
          });
      },

      /**
       * @description 削除メッセージ表示処理
       */
      showDelete() {
        this.$ons.notification
          .confirm({
            title: "削除確認",
            message: "削除すると二度と元に戻せません。削除してもよろしいですか？"
          })
          .then((ok) => {
            if (ok) {
              this.deleteBbs();
            }
          });
      },

      confirmEdite(answer) {
        this.isEditedMessage = false;
        if (answer === "OK") {
          // 前画面に戻る
          this.$router.go(-1);
        }
      },

      /**
       * @description レコード削除
       */
      async deleteBbs() {
        await this.deleteS3File();

        // 削除
        await deleteBbs(this.selectedBbs.bbs_ctl_no);

        // 閉じる
        this.$router.go(-1);

        //del FNSI 施設イベント詳細内容无变化的情况下，点击保存，キャンセル，削除出现 内容破棄的窗口 趙立強 start
        // const bbsInfo = {
        //   bbs_ctl_no: null,
        //   facility_cd: null,
        //   pat_info: { target: null, detail: [] },
        //   staff_info: {
        //     read: [],
        //     target: []
        //   },
        //   func_cd: null,
        //   kind_no: null,
        //   fn_seq_id: null, // 内容管理番号(観察記録等)
        //   content: null,
        //   file_info: [],
        //   notice_start_date: null,
        //   notice_end_date: null,
        //   reg_staff_id: null,
        //   reg_staff_name: null,
        //   upd_staff_id: null,
        //   upd_staff_name: null,
        //   transition_router_path: null,
        //   reg_date: null,
        //   up_date: null
        // };
        // // storeに空を設定
        // this.setSelectedBbs(bbsInfo);
        //del FNSI 施設イベント詳細内容无变化的情况下，点击保存，キャンセル，削除出现 内容破棄的窗口 趙立強 end
        // add 保存の時データ廃棄の提示が出てしまう 陳 start
        this.isChanged = false;
        // add 保存の時データ廃棄の提示が出てしまう 陳 end
        this.search();
      },

      /**
       * @description ラジオボタン個別選択時、常に自身を設定
       */
      setUser() {
        // 自身を常に設定
        const userInfo = {
          cd: this.userId,
          name: this.userName,
          readState: this.isUserRead ? "1" : "0"
        };

        this.selectedStaffList = [userInfo];
        this.isTrueChange();
      },

      /**
       * @description ラジオボタン個別選択以外、全スタッフ設定
       */
      setAllUser() {
        const mstSelectUser = [
          ...this.mstPersonalUser.map(mst => ({ ...mst })),
          { userId: this.userId, userName: this.userName }
        ];

        const staffInfo = mstSelectUser.map(user => {
          const wasStaff = this.selectedStaffList.find(
            was => was.cd === user.userId
          );

          // 設定されていたスタッフの状態を引き継ぎ
          const staff_cd = wasStaff === undefined ? user.userId : wasStaff.cd;
          const user_name =
            wasStaff === undefined ? user.userName : wasStaff.name;
          let read_state = wasStaff === undefined ? "0" : wasStaff.readState;

          // DBの自身の情報を引き継ぎ
          if (staff_cd === this.userId) {
            // 自動既読機能ONなら詳細画面開いた時点で「既読: "1"」へ
            read_state = this.settingBbs.auto_read ? "1" : read_state;
          }

          // 保存用に変換
          return {
            cd: staff_cd,
            name: user_name,
            readState: read_state
          };
        });

        this.selectedStaffList = staffInfo;
		    this.isTrueChange();
      },

      /**
       * @description 未入力チェック
       * @returns { Boolean } true:保存OK, false:保存NG
       */
      validate() {
        for (const validate of this.validateList) {
          if (validate.value) {
            // ダイアログに与えるprops作成
            this.dialogProps = {
              messageCd: 22010001,
              title: DIALOG_MESSAGES[22010001].title,
              stringParams: [validate.name]
            };
            return false;
          }
        }
        if (!this.isValidDate) {
          // ダイアログに与えるprops作成
          this.dialogProps = {
            messageCd: 22010009,
            stringParams: []
          };
          return false;
        }
        /*  add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
        if (!this.isDispBbs) {
          // ダイアログに与えるprops作成
          this.dialogProps = {
            messageCd: 11111112,
            stringParams: []
          };
          return false;
        }
        /* add FNSI-434 改修内容 掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
        return true;
      },

      /**
       * @description ダイアログ表示
       * @param {String} messageCd ダイアログメッセージコード
       * @param {Array} stringParams メッセージ引数
       */
      showDialog() {
        this.isDialogVisble = true;
      },

      /**
       * @description 未入力メッセージ表示
       */
      confirm() {
        this.isDialogVisble = false;
      },

      /*  add FNSI-549 改修内容 一度詳細を表示したら自動的に「既読」にする 趙立強 start*/
      isFlg(){

        if(this.selectedBbs.bbs_ctl_no && this.bbsDetailedInfo.is_disp_bbs){

          return true;

        }
        if(this.selectedBbs.bbs_ctl_no && this.disp_bbs){
          return true;
        }
        return false
      },
      /* add FNSI-549 改修内容 一度詳細を表示したら自動的に「既読」にする 趙立強 end*/
      /**
       * @description 吹き出し表示
       */
      showPopover(event) {
        // 吹き出し表示位置
        this.popoverTarget = event;
        // 吹き出し表示
        this.isReadStatePopoverVisible = true;
      },

      /**
       * @description 患者名ソート
       * @param {Array} userList
       */
      sortPat(patList) {
        // システム共通患者名ソート用(フリガナ優先文字列)を追加
        patList = addPatNameSortToList(patList);
        
        // システム共通患者名ソート
        patList.sort((a, b) => {
          return sortableCompare(a, b, "patNameSort", true);
        });
        
        return patList;
      },

      resizeTextarea(el) {
        el.style.height = "auto";
        const contentHeight = 100;
        const scrollHeight = el.scrollHeight;
        if (el.scrollHeight < contentHeight) {
          // 固定値100pxより低い場合は100pxを設定
          el.style.height = `${contentHeight}px`;
        } else {
          // 固定値100pxより高い場合は全体を表示
          el.style.height = `${scrollHeight}px`;
        }
      },

      setNoticeValue(value) {
        if (value === "" || value === null) {
          this.bbsDetailedInfo.notice_end_date = null;
        }
      },

      deleteFile(deleteList) {
        deleteList.forEach(file => this.$refs.fileDownloader.deleteFile(file));
      },

      deleteS3File() {
        const deleteFileInfo = this.bbsDetailedInfo.file_info;
        if (deleteFileInfo.length !== 0) {
          // S3にファイルが存在する場合
          deleteFileInfo.forEach(file =>
            this.$refs.fileDownloader.deleteFile(file)
          );
          if (this.$refs.fileDownloader.removedFiles.length !== 0) {
            const deleteBbsCtlNo = this.bbsDetailedInfo.bbs_ctl_no;
            // レコード削除前にS3からファイルを削除
            this.$refs.fileDownloader.checkForDeletedFiles(deleteBbsCtlNo);
          }
        }
      },

      classColorSpan(value) {
        return [
          "colorSpan",
          {
            active: value === this.selectedColor
          }
        ];
      },

      colorCheck(value) {
        this.selectedColor = value;
      },
      // HTMLTextInputの設定
      setInputHtmlText(htmlContent) {
        let self = this;
        const tools = TOOLS;
        mountEditor(this.scopedJQuery()("#editor-input"), {
          /**
           * @description テキストエリアのPasteイベント
           */
          paste: function(ev) {
            if(self.copyFontSize){
              ev.html = ev.html.replace(/(<span\b[^>]*?font-size:\s*).*?(;[^>]*>)/gi,"$1" + self.copyFontSize + "$2");
            }
          },
          tools,
          stylesheets: ["/ntss-admin-web/css/kendoEditorCustomStyle.css"],
          messages:{
            fontNameInherit:"(デフォルト)",
            fontSizeInherit:"(デフォルト)"
          },
          execute: function(e) {
            self.$nextTick(() => {
              let editor = $$("#editor-input").data("kendoEditor");
              const docEl = editor && editor.document && editor.document.documentElement && editor.document.documentElement.lastElementChild;
              if (docEl) {
                self.bbsDetailedInfo.html_content = docEl.innerHTML;
              } else if (editor && editor.body) {
                self.bbsDetailedInfo.html_content = editor.body.innerHTML;
              }
            });
	        }
        });
        let editor = this.getRichTextEditor();
        if (editor) {
          editor.body.innerHTML = "";
          if (htmlContent !== "スタッフ") {
            if (htmlContent && htmlContent.indexOf('<p') != -1) {
              editor.exec("insertHTML", {value: htmlContent});
            } else {
              const insertContent = htmlContent == null ? "" : htmlContent;
              editor.exec("insertHTML", {value: "<p><span style='font-family: Meiryo; font-size: 14pt;'>" + insertContent + "</span></p>"});
            }
          } else {
            editor.exec("insertHTML", {value: "<p><span style='font-family: Meiryo; font-size: 14pt;'>" + "スタッフ" + "</span></p>"});
            let range = editor.createRange();
            range.selectNodeContents(editor.body);
            editor.selectRange(range);
          }
        }
        this.keyJudgment = this.$options.data().keyJudgment;
      },
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
      setDataHtmlText() {
        let editor = this.getRichTextEditor();
        let styleTabBeforeCaret = "";
        if (editor) {
          let self = this;
          /**
           * @description テキストエリアのフォーカスアウト発生時のイベント
          */
          const editorEventNamespace = ".ntssBbsDetailEditor";
          $$(editor.window).off(`input${editorEventNamespace}`).on(`input${editorEventNamespace}`, function(ev) {
            self.editContent(
              getKendoEditorDocumentElement(editor, ev, self.$el)?.lastElementChild
            );
            /**
             * @description テキストエリアのクリックイベント
            */
            $$(getKendoEditorOwnerDocument(editor, ev, self.$el))
              .off(`click${editorEventNamespace}`)
              .on(`click${editorEventNamespace}`, function(event) {
              if(!isInsideKendoEditorInteraction(event.target)) {
                if(editor.window.getSelection()) {
                  let range = createKendoEditorRange(editor, ev, self.$el);
                  range.selectNodeContents(self.findLastTextNode(getKendoEditorBody(editor, ev, self.$el)));
                  editor.window.getSelection().removeAllRanges();
                  editor.window.getSelection().addRange(range);
                  editor.window.getSelection().collapseToEnd();
                }
              }
            });
            /**
             * @description カレンダーのフォーカス発生時のイベント
            */
            $$(getKendoEditorOwnerDocument(editor, ev, self.$el))
              .off(`focus${editorEventNamespace}`, ".calendar")
              .on(`focus${editorEventNamespace}`, ".calendar", function() {
              if(editor.window.getSelection()) {
                let range = createKendoEditorRange(editor, ev, self.$el);
                range.selectNodeContents(self.findLastTextNode(getKendoEditorBody(editor, ev, self.$el)));
                editor.window.getSelection().removeAllRanges();
                editor.window.getSelection().addRange(range);
                editor.window.getSelection().collapseToEnd();
              }
            });
          });
          /**
           * @description テキストエリアのkeydownイベント
          */
          this.addManagedEventListener(editor.window, 'keydown', (ev) => {
            if(ev.key === "Enter"){
              let beforeRange = editor.window.getSelection();
              let focusNode = beforeRange.focusNode;
              let focusOffset = beforeRange.focusOffset;
              //Enterキー押下前にカーソルの位置にフォーカス可能な要素が存在しない場合
              if(focusNode.nodeName === "BODY") {
                ev.stopPropagation();
                this.setManagedTimeout(() => {
                  //Enterキー押下後にカーソルが置かれた行のHTMLデータが<p><br></p>の場合、<p>&#xFEFF</p>に置き換える
                  const newChild = createKendoEditorElement("p", editor, ev, self.$el);
                  newChild.textContent = "\ufeff";
                  const targetChild = focusNode.childNodes[focusOffset];
                  focusNode.replaceChild(newChild,targetChild);
                }, 0);
              }
            } else if(ev.key === "Backspace" || ev.key === "Delete"){
              let beforeRange = editor.window.getSelection();
              if((beforeRange.type === "Caret" && beforeRange.anchorNode.nodeName !== "P" && beforeRange.anchorNode.data !== "\ufeff" && beforeRange.anchorOffset === 1)
                || (beforeRange.type === "Range" && beforeRange.anchorNode.nodeName !== "P" && beforeRange.anchorNode.data !== "\ufeff" && beforeRange.anchorNode !== beforeRange.focusNode)){
                let currentNode = beforeRange.anchorNode;
                let selectionType = beforeRange.type;
                let previousNodeExistsFlg = false;
                while (currentNode && currentNode.nodeName !== "BODY") {
                  if(currentNode.nodeName === "P"){
                    break;
                  }
                  if(currentNode.previousElementSibling){
                    previousNodeExistsFlg = true;
                  }
                  currentNode = currentNode.parentElement;
                }
                this.setManagedTimeout(() => {
                  let postChangedSelection = editor.window.getSelection();
                  let postChangedAnchorNode = postChangedSelection.anchorNode;
                  let offset = -1;
                  if(selectionType === "Caret" && previousNodeExistsFlg){
                    offset = postChangedAnchorNode.length;
                  } else if(selectionType === "Range"){
                    if(postChangedAnchorNode.data.indexOf("\ufeff") >= 0 && postChangedAnchorNode.data.length !== postChangedAnchorNode.data.split("\ufeff").length - 1){
                      postChangedAnchorNode.data = postChangedAnchorNode.data.replace(/\ufeff/g, '');
                    }
                    offset = postChangedAnchorNode.length;
                  } else {
                    offset = 0;
                  }
                  postChangedSelection.collapse(postChangedAnchorNode, offset);
                }, 0);
              }
              this.setManagedTimeout(() => {
                const docEl = editor && editor.document && editor.document.documentElement && editor.document.documentElement.lastElementChild;
                if (docEl) {
                  self.bbsDetailedInfo.content = docEl.innerText.replace(/\ufeff/g, "");
                  self.bbsDetailedInfo.html_content = docEl.innerHTML;
                } else if (editor && editor.body) {
                  self.bbsDetailedInfo.content = editor.body.innerText.replace(/\ufeff/g, "");
                  self.bbsDetailedInfo.html_content = editor.body.innerHTML;
                }
              }, 0);
              // mod 認証方式の変更 20260205 huanshuai end
            }
            // mod 認証方式の変更 20260205 huanshuai start
            else if (ev.keyCode === 90 || ev.keyCode === 89) {
              this.setManagedTimeout(() => {
                const docEl = editor && editor.document && editor.document.documentElement && editor.document.documentElement.lastElementChild;
                if (docEl) {
                  self.bbsDetailedInfo.content = docEl.innerText.replace(/\ufeff/g, "");
                } else if (editor && editor.body) {
                  self.bbsDetailedInfo.content = editor.body.innerText.replace(/\ufeff/g, "");
                }
              }, 0);
            }            
          }, true);
          /**
           * @description テキストエリアのkeydownイベント
          */
          $$(editor.window).off(`keydown${editorEventNamespace}`).on(`keydown${editorEventNamespace}`, function(ev) {
            if(ev.key === "Backspace" || ev.key === "Delete"){
              let beforeRange = editor.window.getSelection();
              let focusNode = beforeRange.focusNode;
              let focusOffset = beforeRange.focusOffset === 0 ? 0 : beforeRange.focusOffset - 1;
              if(focusNode.nodeName !== "BODY") {
                let targetLastNode = focusNode.nodeName === "#text" ? focusNode : focusNode.childNodes[focusOffset];
                let targetLastTextNode = self.findLastTextNode(targetLastNode);
                styleTabBeforeCaret = self.getStyleTabBefore(targetLastTextNode);
              }
            }
          });
          /**
           * @description テキストエリアのkeyupイベント
          */
          $$(editor.window).off(`keyup${editorEventNamespace}`).on(`keyup${editorEventNamespace}`, function(ev) {
            let selection = editor.window.getSelection();
            let anchorNode = selection.anchorNode;
            let anchorOffset = selection.anchorOffset;
            let styleArray = self.getFontStyle(anchorNode);

            if (ev.key === "Backspace" || ev.key === "Delete") {
              if(Object.keys(styleArray).length === 0 && styleTabBeforeCaret !== "") {
                editor.exec("insertHTML", {
                  value:
                    styleTabBeforeCaret
                });
                let newRange = editor.createRange();
                if(anchorNode.nodeName === "BODY") {
                  newRange.selectNodeContents(self.findFirstTextNode(editor.body));
                } else {
                  if(anchorOffset >= 1){
                    newRange.selectNodeContents(self.findFirstTextNode(anchorNode.childNodes[anchorOffset-1]));
                  } else{
                    newRange.selectNodeContents(self.findFirstTextNode(anchorNode.childNodes[0]));
                  }
                }
                selection.removeAllRanges();
                selection.addRange(newRange);
                selection.collapseToEnd();
                for (let i = anchorNode.childNodes.length - 1; i > 0; i--) {
                  if(anchorNode.childNodes[i] && anchorNode.childNodes[i].innerText === "") {
                    anchorNode.childNodes[i].remove();
                  }else if(anchorNode.childNodes[i] && i >= anchorOffset && anchorNode.childNodes[i].innerText === "\ufeff"){
                    anchorNode.childNodes[i].remove();
                  }
                }
              }else {
                let anchorParentP = self.findParentNode(anchorNode, "P");
                if(anchorParentP) {
                  if(anchorNode.textContent !== ""){
                    for (let i = anchorParentP.childNodes.length - 1; i >= 0; i--) {
                      if(anchorParentP.childNodes[i] && anchorParentP.childNodes[i].textContent === "") {
                        anchorParentP.childNodes[i].remove();
                        if(anchorParentP.childNodes.length === 0){
                          anchorParentP.remove();
                        }
                      }
                    }
                  }else if(anchorParentP.childNodes.length === 1 && anchorParentP.childNodes[0].nodeName === "BR"){
                    anchorParentP.childNodes[0].remove();
                    anchorParentP.textContent = "\ufeff";
                  }
                }
              }
            }
          });
          /**
           * @description テキストエリアのIMEの変換終了時のイベント
          */
          this.addManagedEventListener(editor.window, 'compositionend', (ev) => {
            ev.currentTarget.dispatchEvent(new Event('input'));
          });
          /**
           * @description テキストエリアの入力イベント発生前のイベント
          */
          this.addManagedEventListener(editor.window, 'beforeinput', (ev) => {
            if(ev.inputType === "deleteByCut"){
              let selection = editor.window.getSelection();
              const range = selection.getRangeAt(0);
              const cloneContents = range.cloneContents();
              const container = createKendoEditorElement('div', editor, ev, self.$el);
              container.appendChild(cloneContents);
              self.copyFontSize = null;
              if(container.querySelectorAll('span').length <= 1){
                self.copyFontSize = ev.target.style.fontSize;
              }
              let anchorNode = selection.anchorNode;
              let currentNode = anchorNode;
              let previousNodeExistsFlg = false;
              while (currentNode && currentNode.nodeName !== "BODY") {
                if(currentNode.nodeName === "P"){
                  break;
                }
                if(currentNode.previousElementSibling){
                  previousNodeExistsFlg = true;
                }
                currentNode = currentNode.parentElement;
              }
              if(container.innerHTML.match(/^<p>(.*?)<\/p>/i)){
                this.setManagedTimeout(() => {
                  const newChildNode = createKendoEditorElement("p", editor, ev, self.$el);
                  newChildNode.textContent = "\ufeff";
                  currentNode.parentNode.replaceChild(newChildNode,currentNode);
                }, 0);
              } else if(!container.innerHTML.match(/<p>(.*?)<\/p>/i)){
                if(currentNode.nodeName === "P" && currentNode.innerHTML === container.innerHTML){
                  currentNode.textContent = "\ufeff";
                } else if(currentNode.nodeName === "P" && currentNode.childNodes.length === 1
                  && currentNode.textContent === container.innerHTML){
                  currentNode.textContent = "\ufeff";
                } else if(currentNode.nodeName === "BODY" && currentNode.textContent === container.innerHTML){
                  this.setManagedTimeout(() => {
                    if(currentNode.childNodes.length === 1 && currentNode.childNodes[0].nodeName === "BR"){
                      currentNode.childNodes[0].remove();
                    }
                  }, 0);
                }
                if(selection.anchorOffset === 0){
                  this.setManagedTimeout(() => {
                    let postChangedSelection = editor.window.getSelection();
                    let postChangedAnchorNode = postChangedSelection.anchorNode;
                    let offset = previousNodeExistsFlg ? postChangedAnchorNode.length : 0;
                    postChangedSelection.collapse(postChangedAnchorNode, offset);
                  }, 0);
                }
              }
            }
          });
          /**
           * @description テキストエリアの入力イベント
          */
          this.addManagedEventListener(editor.window, 'input', (ev) => {
            if(!ev.inputType || ev.inputType === "insertText"){
              let selection = editor.window.getSelection();
              let anchorNode = selection.anchorNode;
              let anchorOffset = selection.anchorOffset;
              let text = anchorNode.textContent;
              if(text.indexOf("\ufeff") >= 0 && text.length !== text.split("\ufeff").length - 1){
                let index = text.indexOf("\ufeff");
                while (index !== -1) {
                  if(index < anchorOffset){
                    anchorOffset--;
                  }
                  index = text.indexOf("\ufeff", index + 1);
                }
                anchorNode.textContent = text.replace(/\ufeff/g, '');
                selection.collapse(anchorNode, anchorOffset);
              }
            }
          });
          /**
           * @description テキストエリアのcopyイベント
          */
          this.addManagedEventListener(editor.window, 'copy', (ev) => {
            self.copyFontSize = null;
            let selection = editor.window.getSelection();
            const range = selection.getRangeAt(0);
            const cloneContents = range.cloneContents();
            const container = createKendoEditorElement('div', editor, ev, self.$el);
            container.appendChild(cloneContents);
            if(container.querySelectorAll('span').length <= 1){
              self.copyFontSize = ev.target.style.fontSize;
            }
          });
        }
        // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
        this.keyJudgment = this.$options.data().keyJudgment
        // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
        //書式設定可能なテキストエリア上部のツールバーの要素を取得する
        // add/ #12473 掲示板画面で複数バグ tianqidong start
        this.$nextTick(() => {
          const {
            fontFamilyClearButton: editorToolbarClearFontFamily,
            fontSizeClearButton: editorToolbarClearFontSize
          } = getKendoEditorToolbarClearButtons(this.$el, "editor-input");
          if(editorToolbarClearFontFamily){
            //テキストエリア上部のツールバーのフォント名のクリアボタンのクリックイベントを登録する
            this.addManagedEventListener(editorToolbarClearFontFamily, 'click', (ev) => {
              ev.currentTarget.previousElementSibling.value = "(デフォルト)";
              //フォント名のドロップダウンリストのクリックイベントを呼び出す
              ev.currentTarget.previousElementSibling.focus();
              ev.currentTarget.previousElementSibling.dispatchEvent(new Event('click'));
              editor.exec("fontName", { value: "Meiryo" });
              //子コンポーネントのクリアボタンのクリックイベントをキャンセルする
              ev.stopPropagation();
            }, true);
          }
          if(editorToolbarClearFontSize){
            //テキストエリア上部のツールバーのフォントサイズのクリアボタンのクリックイベントを登録する
            this.addManagedEventListener(editorToolbarClearFontSize, 'click', (ev) => {
              ev.currentTarget.previousElementSibling.value = "(デフォルト)";
              //フォントサイズのドロップダウンリストのクリックイベントを呼び出す
              ev.currentTarget.previousElementSibling.focus();
              ev.currentTarget.previousElementSibling.dispatchEvent(new Event('click'));
              editor.exec("fontSize", { value: "14pt" });
              //子コンポーネントのクリアボタンのクリックイベントをキャンセルする
              ev.stopPropagation();
            }, true);
          }
        });
        // add/ #12473 掲示板画面で複数バグ tianqidong end
      },
      async editContent(value) {
        // 登録元機能 = "掲示板"の場合
        if (this.isRegFuncClass) {
          this.bbsDetailedInfo.content = value.innerText.replace(/\ufeff/g, '');
          this.bbsDetailedInfo.html_content = value.innerHTML;
        }
        //テキストエリアの初期値の取得
        const content = this.selectedBbs.content;
        //テキストエリアのHTMLデータの初期値の取得
        // add #12473 掲示板画面で複数バグ tianqidong start
        //const htmlContent = this.selectedBbs.html_content.replace(/\ufeff/g, '');
        const htmlContent =
          this.selectedBbs?.html_content?.replace(/\ufeff/g, "") || "";
        // add #12473 掲示板画面で複数バグ tianqidong end
        //テキストエリアの現在の入力値の取得
        const editedContent = (this.bbsDetailedInfo.content === null ? "" : this.bbsDetailedInfo.content);
        //テキストエリアのHTMLデータの現在の入力値の取得
        const editedHtmlContent = (this.bbsDetailedInfo.html_content === null ? "" : this.bbsDetailedInfo.html_content.replace(/\ufeff/g, ''));
        
        //ゼロ幅スペースを除くHTMLデータが一致する場合
        if(content && htmlContent && content === editedContent && htmlContent === editedHtmlContent){
          //テキストエリアのHTMLデータの入力値を初期値に更新する
          this.bbsDetailedInfo.html_content = this.selectedBbs.html_content;
        }
        //テキストエリアの入力値に変化なし、かつ、テキストエリアのHTMLデータの入力値に変化なしに変化あり(桁数に変化なし、値に変化あり)の場合
        if(content && htmlContent && content === editedContent && htmlContent.length === editedHtmlContent.length
        && htmlContent !== editedHtmlContent){
          let initHtmlTagList = [];
          let currentHtmlTagList = [];
          //HTMLのタグの種類(スタイルが指定されていないタグも含む)
          const patterns = [
            /<p\b[^>]*>[\s\S]*?<\/p>/gi,
            /<span\b[^>]*>[\s\S]*?<\/span>/gi,
            /<strong>[\s\S]*?<\/strong>/gi,
            /<em>[\s\S]*?<\/em>/gi,
            /<del>[\s\S]*?<\/del>/gi
          ];
          //HTMLのタグ(初期値、現在の入力値)の情報を取得する
          patterns.forEach(regex => {
            let match = null;
            while ((match = regex.exec(htmlContent)) !== null) {
              let startTagEndIndex = -1;
              if(match[0].indexOf(">") >= 0){
                startTagEndIndex = match.index + match[0].indexOf(">");
              }
              initHtmlTagList.push({
                htmlTagType:regex,
                tagStartIndex: match.index,
                startTagEndIndex: startTagEndIndex,
                htmlTagData: match[0]
              });
            }
            while ((match = regex.exec(editedHtmlContent)) !== null) {
              let startTagEndIndex = -1;
              if(match[0].indexOf(">") >= 0){
                startTagEndIndex = match.index + match[0].indexOf(">");
              }
              currentHtmlTagList.push({
                htmlTagType:regex,
                tagStartIndex: match.index,
                startTagEndIndex: startTagEndIndex,
                htmlTagData: match[0]
              });
            }
          })
          //HTMLのタグの個数が一致する場合
          if(initHtmlTagList.length === currentHtmlTagList.length){
            let isEqual = true;
            for(const [index,initHtmlTag] of initHtmlTagList.entries()) {
              //タグの種類、タグの開始位置、開始タグの終了位置、タグの桁数のいずれかが異なる場合
              if(initHtmlTag.htmlTagType !== currentHtmlTagList[index].htmlTagType
              || initHtmlTag.tagStartIndex !== currentHtmlTagList[index].tagStartIndex
              || initHtmlTag.startTagEndIndex !== currentHtmlTagList[index].startTagEndIndex
              || initHtmlTag.htmlTagData.length !== currentHtmlTagList[index].htmlTagData.length){
                isEqual = false;
                break;
              }
              //HTMLのタグが一致する場合
              if(initHtmlTag.htmlTagData === currentHtmlTagList[index].htmlTagData){
                continue;
              }
              //style属性のスタイルの種類
              let styleList = ["font-family","font-size","background-color","color","text-decoration: underline","white-space: break-spaces","white-space-collapse: break-spaces"];
              let initHtmlStyleList = [];
              let currentHtmlStyleList = [];
              //HTMLの開始タグ(初期値)の取得
              let initHtmlStartTag = htmlContent.substring(initHtmlTag.tagStartIndex,initHtmlTag.startTagEndIndex + 1);
              //HTMLの開始タグ(現在の入力値)の取得
              let currentHtmlStartTag = editedHtmlContent.substring(currentHtmlTagList[index].tagStartIndex,currentHtmlTagList[index].startTagEndIndex + 1);
              //HTMLの開始タグが一致する場合
              if(initHtmlStartTag === currentHtmlStartTag){
                continue;
              }
              //HTMLの各タグに指定されたスタイルの種類の取得
              styleList.forEach(style => {
                let initHtmlStyleStartIndex = initHtmlStartTag.indexOf(style);
                let initHtmlStyleData = "";
                if(initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex) >= 0){
                  let initHtmlStyleEndIndex = initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex);
                  initHtmlStyleData = initHtmlStartTag.substring(initHtmlStyleStartIndex,initHtmlStyleEndIndex + 1);
                }
                //タグに指定されたスタイル(初期値)の情報の取得
                if(style !== "color" && initHtmlStyleStartIndex >= 0) {
                  initHtmlStyleList.push({
                    style:style,
                    styleStartIndex:initHtmlTag.tagStartIndex + initHtmlStyleStartIndex,
                    styleData:initHtmlStyleData
                  });
                }else if(style === "color" && initHtmlStyleStartIndex >= 0){
                  let backgroundColorStyle = initHtmlStyleList.filter(initHtmlStyle => initHtmlStyle.style == "background-color");
                  if(backgroundColorStyle && backgroundColorStyle[0].styleStartIndex + backgroundColorStyle[0].style.indexOf("color") !== initHtmlTag.tagStartIndex + initHtmlStyleStartIndex){
                    initHtmlStyleList.push({
                      style:style,
                      styleStartIndex:initHtmlTag.tagStartIndex + initHtmlStyleStartIndex,
                      styleData:initHtmlStyleData
                    });
                  }else {
                    initHtmlStyleStartIndex = initHtmlStartTag.indexOf(style,initHtmlStyleStartIndex + 1);
                    initHtmlStyleData = "";
                    if(initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex) >= 0){
                      let initHtmlStyleEndIndex = initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex);
                      initHtmlStyleData = initHtmlStartTag.substring(initHtmlStyleStartIndex,initHtmlStyleEndIndex + 1);
                    }
                    if(initHtmlStyleStartIndex >= 0){
                      initHtmlStyleList.push({
                        style:style,
                        styleStartIndex:initHtmlTag.tagStartIndex + initHtmlStyleStartIndex,
                        styleData:initHtmlStyleData
                      });
                    }
                  }
                }
                //タグに指定されたスタイル(現在の入力値)の情報の取得
                let currentHtmlStyleStartIndex = currentHtmlStartTag.indexOf(style);
                let currentHtmlStyleData = "";
                if(currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex) >= 0){
                  let currentHtmlStyleEndIndex = currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex);
                  currentHtmlStyleData = currentHtmlStartTag.substring(currentHtmlStyleStartIndex,currentHtmlStyleEndIndex + 1);
                }
                if(style !== "color" && currentHtmlStyleStartIndex >= 0) {
                  currentHtmlStyleList.push({
                    style:style,
                    styleStartIndex:currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex,
                    styleData:currentHtmlStyleData
                  });
                }else if(style === "color" && currentHtmlStyleStartIndex >= 0){
                  let backgroundColorStyle = currentHtmlStyleList.filter(currentHtmlStyle => currentHtmlStyle.style == "background-color");
                  if(backgroundColorStyle && backgroundColorStyle[0].styleStartIndex + backgroundColorStyle[0].style.indexOf("color") !== currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex){
                    currentHtmlStyleList.push({
                      style:style,
                      styleStartIndex:currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex,
                      styleData:currentHtmlStyleData
                    });
                  }else {
                    currentHtmlStyleStartIndex = currentHtmlStartTag.indexOf(style,currentHtmlStyleStartIndex + 1);
                    currentHtmlStyleData = "";
                    if(currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex) >= 0){
                      let currentHtmlStyleEndIndex = currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex);
                      currentHtmlStyleData = currentHtmlStartTag.substring(currentHtmlStyleStartIndex,currentHtmlStyleEndIndex + 1);
                    }
                    if(currentHtmlStyleStartIndex >= 0){
                      currentHtmlStyleList.push({
                        style:style,
                        styleStartIndex:currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex,
                        styleData:currentHtmlStyleData
                      });
                    }
                  }
                }
              });
              //ソートされたスタイル(初期値)の情報の取得
              let sortedInitHtmlStyleList = initHtmlStyleList.map(({style,styleData}) => ({style,styleData})).sort((a, b) => a.style - b.style);
              //ソートされたスタイル(現在の入力値)の情報の取得
              let sortedCurrentHtmlStyleList = currentHtmlStyleList.map(({style,styleData}) => ({style,styleData})).sort((a, b) => a.style - b.style);
              //ソートされたスタイル(初期値)とソートされたスタイル(現在の入力値)が一致しない場合
              if(!lodash.isEqualWith(sortedInitHtmlStyleList,sortedCurrentHtmlStyleList,customComparator)){
                isEqual = false;
                break;
              }
            }
            //ソートされたスタイル(初期値)とソートされたスタイル(現在の入力値)が一致する場合
            if(isEqual){
              //テキストエリアのHTMLデータの入力値を初期値に更新する
              this.bbsDetailedInfo.html_content = this.selectedBbs.html_content;
            }
          }
        }
      },
      editDataHtmlText() {
        // mod #9818、「患者イベント」と「観察記録」画面で作成した観察記録は掲示板に編集したい時、コンソールエラーが発生の修正 limf start
        // if(this.bbsDetailedInfo.content!==null){
        if(this.bbsDetailedInfo.html_content!==null){
          // mod #9818、「患者イベント」と「観察記録」画面で作成した観察記録は掲示板に編集したい時、コンソールエラーが発生の修正 limf end
          let editor = this.getRichTextEditor();
          //add FutreNetWeb+SI課題管理No4103対応 于 start
          if(!this.allowEdit){
            $$(editor.body).attr("contenteditable", false);
          }
          //add FutreNetWeb+SI課題管理No4103対応 于 end
          // add 障害票一覧_掲示板 修正 chen start
          else if (editor) {
          // add 障害票一覧_掲示板 修正 chen end
            $$(editor.body).attr("contenteditable", true);
          }
        }
      },
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
      setContentData(newValue) {
        this.bbsDetailedInfo.content = newValue;
      },
      // タイトルの変更確認
      chkChangeText(e) {
        // 初期値の取得
        const oldTitle = this.oldTitle !== null ? this.oldTitle : "";
        // 初期値 ≠ 入力値の場合
        if (oldTitle !== e.target.value) {
          e.target?.classList?.add("content-change");
        } else {
          e.target.classList.remove("content-change");
        }
      },
      findLastTextNode(node) {
        if(node.nodeName === "#text") {
          return node;
        }
        let returnNode = node;
        while(true) {
          if(!returnNode.lastChild) {
            break;
          }
          returnNode = returnNode.lastChild;
          if(returnNode.nodeName === "#text") {
            break;
          }
        }
        return returnNode;
      },
      findFirstTextNode(node) {
        if(node.nodeName === "#text") {
          return node;
        }
        let returnNode = node;
        while(true) {
          if(!returnNode.firstChild) {
            break;
          }
          returnNode = returnNode.firstChild;
          if(returnNode.nodeName === "#text") {
            break;
          }
        }
        return returnNode;
      },
      findParentNode(node, find) {
        let returnNodes = [];
        while(true) {
          if(node.nodeName === find) {
            returnNodes.push(node);
          } else {
            if(node.nodeName === "BODY") {
              break;
            }
          }
          if(!node.parentElement) {
            break;
          }
          node = node.parentNode;
        }
        if(find === "SPAN") {
          return returnNodes;
        } else if(returnNodes.length !== 0) {
          return returnNodes[0];
        }
        return null;
      },
      getRemainingNode(textNode, offset) {
        let parentPNode = this.findParentNode(textNode, "P");
        if(parentPNode) {
          let cloneNode = parentPNode.cloneNode(true);
          let foundNode = this.findEndContainer(parentPNode, textNode, cloneNode);
          let remainingText = this.removeBeforeOffset(foundNode, offset);
          let remainingNode = this.findParentNode(remainingText, "P");
          return remainingNode;
        }
        return null;
      },
      findEndContainer(originalNode, targetNode, cloneNode) {
        if(originalNode === targetNode) {
          return cloneNode;
        } else if(originalNode.nodeName === "#text") {
          return null;
        } else if(originalNode.childNodes) {
          let removecount = 0;
          for(let i = 0; i < originalNode.childNodes.length; i++) {
            let foundNode = this.findEndContainer(originalNode.childNodes[i], targetNode, cloneNode.childNodes[i - removecount]);
            if(foundNode) {
              return foundNode;
            } else {
              cloneNode.childNodes[i - removecount].remove();
              removecount = removecount + 1;
            }
          }
        }
        return null;
      },
      removeBeforeOffset(node, offset) {
        let remeiningText = node.textContent.substring(offset);
        let newTextNode = (node.ownerDocument || getScopedWindow(this.$el)?.document || document).createTextNode(remeiningText);
        let parentNode = node.parentNode;
        parentNode.replaceChild(newTextNode, node);
        return newTextNode;
      },
      getFontStyle(node) {
        let parentSpanNodes = this.findParentNode(node, "SPAN");
        let parentPNode = this.findParentNode(node, "P");
        let styleArray = {};
        let styleList = ["fontSize", "fontFamily", "color", "backgroundColor", "textDecoration"];

        if(parentSpanNodes) {
          for(let parentSpanNode of parentSpanNodes) {
            for(let styleItem of styleList) {
              if(!styleArray[styleItem] && parentSpanNode.style[styleItem] !== "") {
                styleArray[styleItem] = parentSpanNode.style[styleItem];
              }
            }
          }
        }
        if(parentPNode) {
          for(let styleItem of styleList) {
            if(!styleArray[styleItem] && parentPNode.style[styleItem] !== "") {
              styleArray[styleItem] = parentPNode.style[styleItem];
            }
          }
        }
        return styleArray;
      },
      getStyleTabBefore(node) {
        let styleArray = this.getFontStyle(node);
        let styleStr = "";
        if(Object.keys(styleArray).length !== 0) {
          styleStr = "<span style='";
          if(styleArray.fontFamily && styleArray.fontFamily !== "") {
            styleStr = styleStr + "font-family: " + styleArray.fontFamily + "; ";
          }
          if(styleArray.fontSize && styleArray.fontSize !== "") {
            styleStr = styleStr + "font-size: " + styleArray.fontSize + "; ";
          }
          if(styleArray.color && styleArray.color !== "") {
            styleStr = styleStr + "color: " + styleArray.color + "; ";
          }
          if(styleArray.backgroundColor && styleArray.backgroundColor !== "") {
            styleStr = styleStr + "background-color: " + styleArray.backgroundColor + "; ";
          }
          if(styleArray.textDecoration && styleArray.textDecoration !== "") {
            styleStr = styleStr + "text-decoration: " + styleArray.textDecoration + ";";
          }
          styleStr = styleStr.trimEnd() + "'>";
          let isStrong = this.findParentNode(node, "STRONG") ? true : false;
          let isEm = this.findParentNode(node, "EM") ? true : false;
          let isDel = this.findParentNode(node, "DEL") ? true : false;
          if(isStrong) {
            styleStr = styleStr + "<strong>";
          }
          if(isEm) {
            styleStr = styleStr + "<em>";
          }
          if(isDel) {
            styleStr = styleStr + "<del>";
          }
          styleStr = styleStr + "\ufeff";
          if(isDel) {
            styleStr = styleStr + "</del>";
          }
          if(isEm) {
            styleStr = styleStr + "</em>";
          }
          if(isStrong) {
            styleStr = styleStr + "</strong>";
          }
          styleStr = styleStr + "</span>";
        }
        return styleStr;
      },
      isTrueChange() {
        let newValue = JSON.parse(JSON.stringify(this.bbsDetailedInfo));
        let oldValue = JSON.parse(JSON.stringify(this.oldValue));
        newValue.disp_bbs = this.disp_bbs;
        oldValue.disp_bbs = this.olddisp_bbs;
        newValue.backgroundColor = this.backgroundColor;
        oldValue.backgroundColor = this.oldbackgroundColor;
        newValue.fontColor = this.fontColor;
        oldValue.fontColor = this.oldfontColor;
        newValue.isNotification = this.isNotification;
        oldValue.isNotification = this.oldisNotification;
        newValue.selectedPatList = [];
        this.selectedPatList.forEach(ele => {
          newValue.selectedPatList.push({
            cd: ele.cd,
            name: ele.name
          });
        });
        oldValue.selectedPatList = this.oldselectedPatList;
        delete newValue.up_date;
        delete oldValue.up_date;
        delete newValue.staff_info;
        delete oldValue.staff_info;
        let newList = [];
        let oldList = [];
        this.selectedStaffList.forEach(ele => {
          newList.push(ele.cd);
        });
        this.oldselectedStaffList.forEach(ele => {
          oldList.push(ele.cd);
        });
        newValue.selected = newList;
        oldValue.selected = oldList;
        // add/ #12473 掲示板画面で複数バグ tianqidong start
        if(!this.isRegFuncClass){
          newValue.html_content = null;
          oldValue.html_content = null;
        }
        // add/ #12473 掲示板画面で複数バグ tianqidong end
        let start = isJsonChanged(
          JSON.stringify(newValue),
          JSON.stringify(oldValue)
        );
        this.showBtnChanged = start;
        this.isChanged = start;
      }
    },
  };
</script>

<style scoped>
.loading-modal {
  text-align: center;
  font-size: 30px;
}

.bbs-staff-popover :deep(.popover__content) {
  display: flex;
  flex-direction: column;
  max-height: 80vh;
  overflow: hidden;
}

.read-state-popover-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
}

.table-wrapper {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  padding: 15px;
  box-sizing: border-box;
}

.table-header {
  flex: 0 0 auto;
}

.col-scroll {
  width: var(--scrollbar-width, 0px);
}

.table-body {
  flex: 1;
  min-height: 0;
  overflow-y: scroll;
  scrollbar-gutter: stable;
}

.table-header th:nth-child(1),
.table-body td:nth-child(1) { width: 63%; }

.table-header th:nth-child(2),
.table-body td:nth-child(2) { width: 37%; }

.table-header th,
.table-body td {
  padding: 10px 8px;
  box-sizing: border-box;
}

.table-body td {
  word-break: break-word;
}

.close-btn {
  float: left;
  margin-left: 15px;
}

.popover-footer {
  height: 30px;
  margin-bottom: 15px;
  text-align: center;
}

.read-state-table {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

.com-textarea {
  width: 99%;
  position: relative;
  box-sizing: border-box;
  overflow-y: hidden;
}

.title-input {
  width: 100%;
  font-family: inherit;
  font-size: inherit;
  background-color: rgb(247, 247, 247);
}

.content-change {
  border: 2px green solid;
  outline: 0;
}
/* add FNSI-改修内容5587修正 関　start */
.main-content-area{
  overflow-y: unset;
  /* 一覧の文字色 */
  color: var(--ntss-list-body-color);
}
.bbs-button {
  flex-direction: column;
}
/* add FNSI-改修内容5587修正 関　end */
/* add FNSI-改修内容5587修正 関　start */
/* .btn-area {
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
  width: 97%; */
  /* align-items: flex-end; */
  /* align-items: center;
} */
.btn-area {
  z-index: 2;
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
  /* width: 97%; */
  /* align-items: flex-end; */
  align-items: center;
  height: 2em;
  margin-top: 0.2em;
  overflow-x: auto;
  overflow-y: hidden;
}
/* .bbs-detail-main { */
  /* 一覧の文字色 */
  /* color: var(--ntss-list-body-color);
} */
.bbs-detail-main {
  /* 一覧の文字色 */
  /* color: var(--ntss-list-body-color); */
  z-index: 1;
  overflow-y: auto;
  height: calc(100% - 2.2em);
}
/* add FNSI-改修内容5587修正 関　end */
.input-date::-webkit-calendar-picker-indicator {
  display: none;
}

.item-area {
  padding: 5px 0 5px 0;
}

.category-area {
  padding-right: 10px;
}

.input-date,
.input-select {
  font-size: 1em;
}

.delete-button {
  width: 100px;
  padding: 0;
}

.cancel-button {
  right: 3px;
}

.checkbox-group > * {
  margin-right: 10px;
}

.checkbox-group > *:first-child {
  margin-left: 10px;
}

.checkbox-group > *:last-child {
  margin-right: 0;
}

.checkbox-group ons-checkbox {
  margin-right: 5px;
}

.colorSpan {
  width: 30px;
  height: 30px;
  margin-right: 16px;
  float: left;
  display: flex;
  align-items: center;
  cursor: pointer;
  border: thin solid lightgray;
  font-size: 0.84em;
  white-space: nowrap;
  justify-content: center;
}

.colorSpan.active {
  border: thin solid black;
}

#input-title:focus {
  border: 2px green solid;
  outline: 0;
}
.row-title {
  display: flex;
  align-items: center;
  width: 99%;
}

 
/*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
div :deep(.content-textarea) {
  width: 100%;
  font-family: inherit;
  font-size: 1.5em;
  height: 100px;
}
/*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
/* add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start*/
.scale-input {
  font-size: 1.25em;
  margin: 5px 10px;
  width: 30px;
  height: 20px;
  text-align: left;
}
/* add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end*/
/*add 施設イベント詳細画面のスマホ表示崩れ #4136 shan start*/
.box_flex_w{
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.d-inline-margin{
  margin-left: 10px;
  margin-right: 5px;
}
/*add 施設イベント詳細画面のスマホ表示崩れ #4136 shan end*/
@media screen and (min-height:700px) {
  .bbs-staff-popover :deep(.popover__content) {
    max-height: 600px !important;
  }
}
/* #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start */
.display_none {
  display: none;
}
/* #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end */
@media print {
  .item-area :deep(.k-editor .k-content){
    height: 30vh !important;
  }
  /** ボタン非表示 */
  .btn-area {
    display: none;
  }
}
/* 横向き印刷 */
@media print and (orientation: landscape) {
  .item-area :deep(.k-editor .k-content){
    height: 28vh !important;
  }
}

:deep(.select-input){
  font-family: -apple-system, 'Helvetica Neue', 'Helvetica', 'Arial', 'Lucida Grande', sans-serif !important;
}


</style>
