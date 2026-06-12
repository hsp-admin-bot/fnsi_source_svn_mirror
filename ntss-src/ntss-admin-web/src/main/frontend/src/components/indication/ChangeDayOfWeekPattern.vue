/** 患者経過総合ビューア 曜日パターン変更 */
<template>
<!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start-->
<!--  <modal-base @onClose="hideModal" class="custom-modal">-->
  <modal-base @onClose="hideModal('hide-modal')" class="custom-modal change-day-of-Week-pattern">
    <template #body>
<!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end-->
    <div id="div-parent" ref="modalBodyRoot" class="indInfo-style-modal-container">
      <canvas id="arrowCanvasDummy" class="canvas-style"></canvas>
      <div class="IndBaseHeader">
        <div>
          <v-ons-row class="div-style">
            <v-ons-col width="100%" style="text-align: start; white-space: normal;">
              期間内の
              <font size="4" style="color:red;">
                {{ treatmethodDispValue }}
              </font>
              <!-- mod FNSI-改修内容 曜日説明文変更する 李 start -->
              <!-- の予定をすべて中止し、<br />
              新たな曜日パターンで治療予定を作成します。 -->
              の治療予定を新たな曜日パターンに変更します。<br />
              <!-- mod FNSI-改修内容 曜日説明文変更する 李 end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="div-style">
            <v-ons-col class="indInfo-style-label-position">
              <label>治療方法</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod 画面デザイン改善対応 李 start -->
              <!-- <v-ons-select
                v-model="selectedTreatmentCd"
                class="common-style-input select-tab"
                :disabled="updateDisable"
              >
                <option
                  v-for="(treatmentInfo, index) in weekPerTreatList"
                  :key="index"
                  :value="treatmentInfo.treatmentCd"
                >
                  {{ treatmentInfo.treatmentName }}
                </option>
              </v-ons-select> -->
              <v-ons-select
                id="v-ons-select-id"
                v-model="selectedTreatmentCd"
                class="common-style-input select-tab"
                :disabled="updateDisable"
              >
                <option
                  v-for="(treatmentInfo, index) in weekPerTreatList"
                  :key="index"
                  :value="treatmentInfo.treatmentCd"
                >
                  {{ treatmentInfo.treatmentName }}
                </option>
              </v-ons-select>
              <!-- mod 画面デザイン改善対応 李 end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="div-style">
            <v-ons-col class="indInfo-style-label-position">
              <label>開始日</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
              <!-- <input
                v-model="indTreatStartDate"
                type="date"
                class="date-input common-style-input ntss-input-date ntss-custom-input"
                data-target="indTreatStartDate"
                @focus="focusStartEditing(indTreatStartDate)"
                @blur="blurUpdate(indTreatStartDate)"
              /> -->
              <!-- mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao start -->
              <!-- <input
                v-model="indTreatStartDate"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date ntss-custom-input"
                data-target="indTreatStartDate"
                @focus="focusStartEditing(indTreatStartDate)"
                @blur="blurUpdate(indTreatStartDate)"
              /> -->
                <!-- mod 8560 開始日の日付のキーボード入力が不正 張 start-->
              <!-- <input
                v-model="indTreatStartDate"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date ntss-custom-input"
                data-target="indTreatStartDate"
                @focus="focusStartEditing(indTreatStartDate,1)"
                @blur="blurUpdate(indTreatStartDate,1)"
              /> -->
              <!--mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start-->
              <!--<input
                v-model="indTreatStartDate"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date ntss-custom-input"
                data-target="indTreatStartDate"
                max="9999-12-31"
                @focus="focusStartEditing(indTreatStartDate,1)"
                @blur="AdjustTreatStartDate(indTreatStartDate,true);blurUpdate(indTreatStartDate,1)"
              />-->
              <!-- #10196 曜日変更過去日は手入力できません linjunfeng start -->
              <!-- <input
                v-model="indTreatStartDate"
                type="date"
                id="date-start"
                class="date-input common-style-input ntss-input-date ntss-custom-input "
                data-target="indTreatStartDate"
                max="9999-12-31"
                @focus="focusStartEditing(indTreatStartDate,1)"
                @blur="AdjustTreatStartDate(indTreatStartDate,true);blurUpdate(indTreatStartDate,1)"
              /> -->
              <date-input
                v-model="indTreatInputStartDate"
                id="date-start"
                :class="[isIOS ? 'date-input-ios' : 'date-input-other', 'common-style-input', 'ntss-input-date', 'ntss-custom-input']"
                classes="date-input-required"
                data-target="indTreatStartDate"
                max="9999-12-31"
                @focus="focusStartEditing(indTreatInputStartDate,1)"
                @blur="AdjustTreatStartDate(indTreatInputStartDate,true);blurUpdate(indTreatInputStartDate,1)"
                isRequired
              />
              <!-- #10196 曜日変更過去日は手入力できません linjunfeng end -->
              <!-- mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao end -->
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 end -->
              <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.40 李 start -->
              <!-- <custom-calendar
                v-model="indTreatStartDate"
                :is-disabled-past-dates="true"
                :disable-dates-after="disableDatesAfter"
              /> -->
              <!-- mod 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start -->
              <!-- <custom-calendar
                v-model="indTreatStartDate"
                :disable-dates-after="disableDatesAfter"
              /> -->
              <!--<custom-calendar
                v-model="indTreatStartDate"
                :is-disabled-past-dates="true"
                :disable-dates-after="disableDatesAfter"
              />-->
              <custom-calendar
                v-model="indTreatStartDate"
                :disable-dates-after="disableDatesAfter"
              />
              <!-- mod 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy end -->
              <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.40 李 end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="div-style">
            <v-ons-col class="indInfo-style-label-position">
              <label>終了日</label>
            </v-ons-col>
            <v-ons-col>
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 start -->
              <!-- <input
                v-model="indTreatEndDate"
                type="date"
                class="date-input common-style-input ntss-custom-input"
                data-target="indTreatEndDate"
                :min="indTreatStartDate"
                :max="maxDate"
                @focus="focusStartEditing(indTreatEndDate)"
                @blur="blurUpdate(indTreatEndDate)"
              /> -->
              <!-- mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao start -->
              <!-- <input
                v-model="indTreatEndDate"
                type="date"
                id="date-end"
                class="date-input common-style-input ntss-custom-input"
                data-target="indTreatEndDate"
                :min="indTreatStartDate"
                :max="maxDate"
                @focus="focusStartEditing(indTreatEndDate)"
                @blur="blurUpdate(indTreatEndDate)"
              /> -->
              <!-- <input
                v-model="indTreatEndDate"
                type="date"
                id="date-end"
                class="date-input common-style-input ntss-custom-input"
                data-target="indTreatEndDate"
                :min="indTreatStartDate"
                :max="maxDate"
                @focus="focusStartEditing(indTreatEndDate,2)"
                @blur="blurUpdate(indTreatEndDate,2)"
              /> -->
              <!-- mod 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start -->
              <!-- <input
                v-model="indTreatEndDate"
                type="date"
                id="date-end"
                class="date-input common-style-input ntss-custom-input"
                data-target="indTreatEndDate"
                :min="indTreatStartDate"
                :max="maxDate"
                @focus="focusStartEditing(indTreatEndDate,2)"
                @blur="AdjustTreatStartDate(indTreatEndDate,false);blurUpdate(indTreatEndDate,2)"
              /> -->
              <!-- #10196投与薬品行ヘッター親、初回投与日選択可開始日前、操作卓誤選択済 yangqingzhe start   -->
              <!-- <date-input
                v-model="indTreatEndDate"
                @handleClearInput="indTreatEndDate = null"
                id="date-end"
                class="date-input common-style-input ntss-custom-input"
                data-target="indTreatEndDate"
                :min="indTreatStartDate"
                :max="maxDate"
                @focus="focusStartEditing(indTreatEndDate,2)"
                @blur="AdjustTreatStartDate(indTreatEndDate,false);blurUpdate(indTreatEndDate,2)"
              /> -->
              <!-- #10196 曜日変更過去日は手入力できません linjunfeng start -->
              <!-- <date-input
                v-model="indTreatEndDate"
                @handleClearInput="indTreatEndDate = ''"
                id="date-end"
                class="date-input common-style-input ntss-custom-input"
                data-target="indTreatEndDate"
                :min="indTreatStartDate"
                :max="maxDate"
                @focus="focusStartEditing(indTreatEndDate,2)"
                @blur="AdjustTreatStartDate(indTreatEndDate,false);blurUpdate(indTreatEndDate,2)"
              /> -->
              <date-input
                v-model="indTreatInputEndDate"
                @handleClearInput="indTreatInputEndDate = '';AdjustTreatStartDate(indTreatInputEndDate,false);blurUpdate(indTreatInputEndDate,2)"
                id="date-end"
                :class="[isIOS ? 'date-input-ios' : 'date-input-other', 'common-style-input', 'ntss-input-date', 'ntss-custom-input']"
                data-target="indTreatEndDate"
                :min="indTreatStartDate"
                :max="maxDate"
                @focus="focusStartEditing(indTreatInputEndDate,2)"
                @blur="AdjustTreatStartDate(indTreatInputEndDate,false);blurUpdate(indTreatInputEndDate,2)"
              />
              <!-- #10196 曜日変更過去日は手入力できません linjunfeng end -->
              <!-- #10196投与薬品行ヘッター親、初回投与日選択可開始日前、操作卓誤選択済 yangqingzhe end   -->
              <!-- mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao end -->
              <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「デートピッカー削除なし」 周 end -->
              <!-- <custom-calendar
                v-model="indTreatEndDate"
                :is-disabled-past-dates="true"
                :disable-dates-after="disableDatesAfter"
              /> -->
              <!--<custom-calendar
                v-model="indTreatEndDate"
                :is-disabled-past-dates="true"
                :disable-dates-before="disableDatesBefore"
                :to-month="toMonth"
                :disable-dates-after="disableDatesAfter"
              />-->
              <custom-calendar
                v-model="indTreatEndDate"
                :disable-dates-before="disableDatesBefore"
                :to-month="toMonth"
                :disable-dates-after="disableDatesAfter"
              />
              <!-- mod 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy end -->
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
      <div class="slot-style">
        <!-- 内部remine 5840  mod ljx start-->
<!--        <div
          v-if="showCurrentWeekPatternDetail"
          id="detail-list"
          class="div-style"
        >
          &lt;!&ndash; add FNSI-FutreNetWeb+SI課題管理No.4362 李 start &ndash;&gt;
          <change-list :change-flg="false" :to-pattern-week="toTreatPatternWeekInfo"/>
          &lt;!&ndash; add FNSI-FutreNetWeb+SI課題管理No.4362 李 end &ndash;&gt;

          <detail-info
            :disp-info="dispInfo"
            :disp-treatment="treatmethodDispValue"
            :mst-info="mstInfo"
            :disp-type="0"
          />
        </div>-->

        <v-ons-row class="canvas-div-style week-div-style">
<!--          <v-ons-col
            class="indInfo-style-label-position"
            id="currentDetail"
            @click="showCurrentDetail"
          >
            変更前▲
          </v-ons-col>-->
          <v-ons-col
            class="indInfo-style-label-position"
            id="currentDetail"
          >
            変更前
          </v-ons-col>
          <!-- 内部remine 5840  mod ljx end-->
          <v-ons-col id="currentWeekList">
            <div
              v-for="(weekInfo, index) in treatPatternWeekInfo"
              :key="index"
              class="week-box"
              :style="currentWeekStyle"
            >
              {{ weekInfo.text }}
            </div>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="canvas-div-style">
          <v-ons-col class="indInfo-style-label-position" />
          <v-ons-col class="canvas-size">
            <canvas
              id="arrowCanvas"
              width="250px"
              height="48px"
            ></canvas>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="canvas-div-style">
          <!-- 内部remine 5840  mod ljx start-->
<!--          <v-ons-col
            class="indInfo-style-label-position"
            @click="showNewDetail"
          >
            変更後▼
          </v-ons-col>-->
          <v-ons-col
            class="indInfo-style-label-position"
          >
            変更後
          </v-ons-col>
          <!-- 内部remine 5840  mod ljx end-->
          <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「曜日グループボタン」 周 start -->
          <!-- <v-ons-col> -->
          <v-ons-col id="currentWeekListTo">
          <!-- mod FNSI-画面デザイン修正_患者経過総合ビューア「曜日グループボタン」 周 end -->
            <div
              v-for="(toWeekInfo, index) in toTreatPatternWeekInfo"
              :key="index"
              class="to-week-box"
              :style="newPatternWeek(toWeekInfo.fromWeek)"
              @click="setSelection($event, toWeekInfo, index)"
              @touchend="setSelection($event, toWeekInfo, index)"
            >
              {{ toWeekInfo.text }}
            </div>
          </v-ons-col>
        </v-ons-row>
        <!-- 内部remine 5840  mod ljx start-->
<!--        <div v-if="showNewWeekPatternDetail" class="div-style">-->
          <div  class="div-style">
          <!-- add FNSI-FutreNetWeb+SI課題管理No.4362 李 start -->
          <div style="height: 1em" class="not-height-auto"></div>
          <!--<change-list :change-flg="true" :to-pattern-week="toTreatPatternWeekInfo"/>-->
            <!-- mod #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 start-->
            <change-list
              ref="changeListModal"
              :change-flg="true"
                         :arrow-info="arrowInfo"
              :maxdate="maxDate"
              :indTreatStartDate="indTreatStartDate"
            />
            <!-- mod #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 end -->
            <!-- 内部remine 5840  mod ljx end-->
            <div style="height: 2em" class="not-height-auto"></div>
          <!-- add FNSI-FutreNetWeb+SI課題管理No.4362 李 end -->
          <detail-info
            ref="detailModal"
            :disp-info="newDispInfo"
            :disp-treatment="treatmethodDispValue"
            :mst-info="mstInfo"
            :disp-type="1"
          />
        </div>

        <!-- del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start -->
        <!-- <div id="popChip" class="pop-chip">
          <div
            v-for="(fromInfo, index) in fromWeekInfo"
            :key="index"
            class="menu-chip"
            :style="setListStyle(selectionInfo.toWeekInfo, fromInfo)"
            @click="selectFromWeek(fromInfo)"
          >
            {{ fromInfo.text }}
          </div>
        </div> -->
        <!-- del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end -->
      </div>

      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          :overflowY="messageDialogInfo.overflowY"
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          @confirm="confirmResult"
        />
      </div>
      <!--425 姜 start-->
      <div v-if="facilitySettingExamValue == 4">
        <!--mod redmine#7185 centOS7サポート切れ zkq start -->
        <!-- <v-ons-alert-dialog modifier="rowfooter"
          :footer="{
            1: () => numberExam1(),
            2: () => numberExam2(),
            3: () => numberExam3()
          }"
          :visible="diaViewExam"> -->
        <v-ons-alert-dialog modifier="rowfooter"
          :visible="diaViewExam">
<!--          add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy start-->
        <template #title><span>{{ messageExamTitle }}</span></template>
<!--          add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy end-->
          <p>
            <template v-for="(item, index) in messageExam" :key="index">
              <span>{{ item }}<br></span>
            </template>
          </p>
          <template #footer>
            <v-ons-alert-dialog-button @click="numberExam1()">1</v-ons-alert-dialog-button>
            <v-ons-alert-dialog-button @click="numberExam2()">2</v-ons-alert-dialog-button>
            <v-ons-alert-dialog-button @click="numberExam3()">3</v-ons-alert-dialog-button>
          </template>
        </v-ons-alert-dialog>

        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
    </div>
      <div v-if="facilitySettingRadValue == 4">
        <!--mod redmine#7185 centOS7サポート切れ zkq start -->
        <!-- <v-ons-alert-dialog modifier="rowfooter"
          :footer="{
            1: () => numberRad1(),
            2: () => numberRad2(),
            3: () => numberRad3()
          }"
          :visible="diaViewRad"> -->
        <v-ons-alert-dialog modifier="rowfooter"
          :visible="diaViewRad">
<!--          add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy start-->
          <template #title><span>{{ messageRadTitle }}</span></template>
<!--          add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy end-->
          <p>
            <template v-for="(item, index) in messageRad" :key="index">
              <span>{{ item }}<br></span>
            </template>
          </p>
          <template #footer>
            <v-ons-alert-dialog-button @click="numberRad1()">1</v-ons-alert-dialog-button>
            <v-ons-alert-dialog-button @click="numberRad2()">2</v-ons-alert-dialog-button>
            <v-ons-alert-dialog-button @click="numberRad3()">3</v-ons-alert-dialog-button>
          </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        </v-ons-alert-dialog>
      </div>
      <!--425 姜 end-->
      <!--426 姜 start-->
      <div v-if="facilitySettingEventValue == 4">
        <!--mod redmine#7185 centOS7サポート切れ zkq start -->
        <!-- <v-ons-alert-dialog modifier="rowfooter"
          :footer="{
            1: () => numberEvent1(),
            2: () => numberEvent2(),
            3: () => numberEvent3()
          }"
          :visible="diaViewEven"> -->

        <v-ons-alert-dialog modifier="rowfooter"
          :visible="diaViewEven">
<!--          add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy start-->
          <template #title><span>{{ messageEvendTitle }}</span></template>
<!--          add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy end-->
          <p>
            <template v-for="(item, index) in messageEvend" :key="index">
              <span>{{ item }}<br></span>
            </template>
          </p>
          <template #footer>
            <v-ons-alert-dialog-button @click="numberEvent1()">1</v-ons-alert-dialog-button>
            <v-ons-alert-dialog-button @click="numberEvent2()">2</v-ons-alert-dialog-button>
            <v-ons-alert-dialog-button @click="numberEvent3()">3</v-ons-alert-dialog-button>
          </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        </v-ons-alert-dialog>
      </div>
      <!--426 姜 end-->
    </div>
    </template>

    <template #footer><div class="in-ind-dropdown-area">
      <v-ons-row class="div-style">
        <v-ons-col style="text-align: end; padding-right: 10px; margin: auto;">
          <label>指示者</label>
        </v-ons-col>
        <v-ons-col width="170px">
          <!-- mod 画面デザイン改善対応 李 start -->
          <!-- <kendo-dropdownlist
            v-model="selectedIndUser"
            :data-source="indUserOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            :disabled="updateDisable"
            style="width: 100%;"
            class="common-style-input"
          /> -->
          <!-- mod 7397デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao start -->
          <!-- <kendo-dropdownlist
            id="kendo-dropdownlist-select-id"
            v-model="selectedIndUser"
            :data-source="indUserOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            :disabled="updateDisable"
            style="width: 100%;"
            class="common-style-input select-style-list"
          /> -->
          <kendo-dropdownlist
            id="kendo-dropdownlist-select-id"
            v-model="selectedIndUser"
            :data-source="indUserOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            style="width: 100%;"
            class="common-style-input select-style-list"
            @open="onIndUserDropdownOpen"
          />
          <!-- mod 画面デザイン改善対応 李 end -->
          <!-- mod 7397デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao end -->
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="div-style footer-style">
        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button
            class="common-style-cancel-button"
            style="float: left;"
            @click="hideModal"
          >
            キャンセル
          </v-ons-button> -->
<!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start-->
<!--          <v-ons-button-->
<!--              class="btn2-cancel width-padding"-->
<!--              style="float: left;"-->
<!--              @click="hideModal"-->
<!--          >-->
          <v-ons-button
            class="btn2-cancel width-padding"
            style="float: left;"
            @click="hideModal('hide-modal')"
          >
<!--            mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end-->
            キャンセル
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
        </v-ons-col>
        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button
            class="common-style-ok-button"
            style="float: right;"
            :disabled="updateDisable"
            @click="updateInfo"
          >
            保存
          </v-ons-button> -->
            <!-- mod 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start -->
          <!-- <v-ons-button
            class="btn1-execute width-padding"
            style="float: right;"
            :disabled="updateDisable"
            @click="updateInfo"
          > -->
<!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start-->
<!--          <v-ons-button-->
<!--            class="btn1-execute width-padding"-->
<!--            style="float: right;"-->
<!--            :disabled="updateDisable || !isChanged"-->
<!--            @click="beforeupdateInfo()"-->
<!--          >-->
        <!-- mod #11716 曜日パターン変更の不正 関 start -->
          <!-- <v-ons-button
            class="btn1-execute width-padding"
            style="float: right;margin-left: 1.5em;"
            :disabled="updateDisable || !isChanged"
            @click="beforeupdateInfo()"
          > -->
<!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end-->
            <!-- mod 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 start -->
            <!-- 保存
          </v-ons-button> -->
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          <v-ons-button
            class="btn1-execute width-padding"
            style="float: right; margin-left: 1.5em;"
            :disabled="updateDisable"
            @click="beforeupdateInfo2()"
          >
            保存
          </v-ons-button>
          <!-- mod #11716 曜日パターン変更の不正 関 end -->
        </v-ons-col>
      </v-ons-row>
    </div>
      </template>
</modal-base>
</template>

<script>
import { setKendoDropDownListEditedState } from "@/functions/common/KendoFunctions";
import $ from "@/compat/jquery";
import _ from "@/compat/collections/lodash";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
import IndDetailInfo from "@/components/indication/IndDetailInfo";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import ModalBase from "@/components/modals/ModalBase";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
//内部remine 5840  add ljx start
import {EventBus} from "@/compat/vue/event-bus.js";
//内部remine 5840  add ljx end
/**
 * 日付操作
 */
import dayjs from "@/compat/date/dayjs";
// 426 姜 start
/**
 * 施設設定番号
 */
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import {FACILITY_NO_SETTING} from "@/constants/facilitySetting";

import {EXAM_SCHEDULE_CHANGE} from "@/constants/facilitySetting";

import {RAD_SCHEDULE_CHANGE} from "@/constants/facilitySetting";

import {EXAM_DEADLINE} from "@/constants/facilitySetting";

import {EXAM_DEADLINE_TIME_COUNT} from "@/constants/facilitySetting";

import {EXAM_DEADLINE_DATE_COUNT} from "@/constants/facilitySetting";

import {RAD_DEADLINE_DATE_COUNT} from "@/constants/facilitySetting";

import {RAD_DEADLINE_TIME_COUNT} from "@/constants/facilitySetting";

import {RAD_DEADLINE} from "@/constants/facilitySetting";

import { DEF_DIALOG_MSG_30, DEF_DIALOG_MSG_31, DEF_DIALOG_MSG_32 } from "@/components/schedule-list/Definitions.js";

import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// 426 姜 end
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { isProcSuccess } from "@/functions/common/ApiResponseFunctions";

/**
 * jQuery
 */

// add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
import ChangeDayOfWeekList from "@/components/indication/ChangeDayOfWeekList";
// add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//9273 start
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
//9273 end
const weekWidth = 34;
// add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 start
// const messageInfo = "投与間隔月１のものが月を跨いだ、ご確認ください。"
// add 投与間隔月１のものが月を跨いだ場合、メッセージを出す。 李 end
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
const messageInfo = messageFormat(DIALOG_MESSAGES[13000044].message);
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
//add #9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。 zy start
import DateInput from "@/components/common/DateInput.vue";
//add #9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。 zy end
// add 10409 曜日パターン変更の患者イベント修正 関  start
import {sendRequestGetLinkageMessageConfirm} from "@/apis/pat-event";
import { getScopedDocument, getScopedElementById, getScopedElementsByClassName, getScopedJQuery, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";
import { getOnsAlertDialogFooterItems, getOnsAlertDialogFromEvent } from "@/functions/common/OnsenFunctions";
// add 10409 曜日パターン変更の患者イベント修正 関  end
export default {
  components: {
    "custom-calendar": CustomCalendar,
    "detail-info": IndDetailInfo,
    "message-dialog": messageDialog,
    ModalBase,
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    "change-list": ChangeDayOfWeekList
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    //add #9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。 zy start
    ,"date-input":DateInput,
    //add #9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。 zy end
  },
  mixins: [IndUserSelectMixin],

  props: {
    facilityCd: {
      type: String,
      required: true
    },
    patId: {
      type: Number,
      required: true
    },
    dateFrom: {
      type: String,
      default: "2019-06-10"
    },
    indClass: {
      type: String,
      default: "0"
    },
    // add FNSI-曜日パターン変更の開始日に基準日を変更する 李 start
    startDate: {
      type: String,
      required: true
    }
    // add FNSI-曜日パターン変更の開始日に基準日を変更する 李 end
  },

  data() {
    return {
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
      showMessageFlag: false,
      moveWeek: [],
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
      /**
       * メッセージダイアログ情報
       */
      messageDialogInfo: {
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
        overflowY:false,
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
        isDialogVisible: false,
        messageCd: null,
        type: null,
        stringParams: []
      },
      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
      /**
       * 治療情報を保持する用
       */
      targetOrdMainList: [],
      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
      /**
       * 治療方法と曜日のリスト
       */
      weekPerTreatList: [],
      /**
       * 治療方法コード選択値
       */
      selectedTreatmentCd: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectedTreatmentCd: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * 治療方法マスタリスト
       */
      mstTreatmentList: [],
      /**
       * 指示者選択値
       */
      selectedIndUser: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectedIndUser: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * 指示者情報リスト
       */
      indUserOptions: [],
      /**
       * 治療方法表示用
       */
      //内部remine 5840  mod ljx start
      treatmethodDispValue: "",
      dispMoveDateInfo:"",
      //内部remine 5840  mod ljx end
      /**
       * 開始日
       */
      // add FNSI-曜日パターン変更の開始日に基準日を変更する 李 start
      // indTreatStartDate: this.dateFrom,
      indTreatStartDate: this.startDate,
      // add FNSI-曜日パターン変更の開始日に基準日を変更する 李 end
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initIndTreatStartDate: this.startDate,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * 終了日
       */
      indTreatEndDate: "",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initIndTreatEndDate: "",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * 治療パターン曜日情報
       */
      treatPatternWeekInfo: [],
      /**
       * 変更先治療パターン曜日情報
       */
      toTreatPatternWeekInfo: [],
      /**
       * 変更前曜日数
       */
      currentWeekNum: 0,
      /**
       * 曜日情報の要素
       */
      weekElements: null,
      /**
       * 変更先の曜日情報要素
       */
      toWeekElements: null,
      /**
       * 移動中の曜日要素
       */
      moveWeekElement: null,
      x: 0,
      /**
       * 要素内のクリックされた縦情報(横)
       */
      y: 0,
      /**
       * 各曜日要素のサイズ
       */
      distWidth: 0,
      distHeight: 0,
      fromWidth: 0,
      fromHeight: 0,

      /**
       * 矢印の始点のX座標
       */
      arrowStartX: 0,
      /**
       * キャンバスid
       */
      canvasId: "arrowCanvas",
      /**
       * キャンバスの配置(上から)
       */
      canvasPosTop: 0,
      /**
       * キャンバスの配置(左から)
       */
      canvasPosLeft: 0,
      /**
       * 矢印情報
       */
      arrowInfo: [],
      /**
       * 矢印情報数
       */
      arrowInfoLength: 0,
      /**
       * 現在ポップチップを出している要素
       */
      nowToWeekElement: null,
      /**
       * 選択チップの非表示、非表示
       */
      isShowChip: false,
      /**
       * チップ用のタイマーID
       */
      timerId: null,
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
      // /**
      //  * 変更先の曜日選択情報
      //  */
      // selectionInfo: {
      //   target: null,
      //   direction: "up",
      //   visible: false,
      //   fromWeekInfo: [],
      //   toWeekInfo: {
      //     value: null,
      //     text: null,
      //     fromWeek: 0
      //   }
      // },
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end
      /**
       * 現在の曜日パターンの指示詳細情報表示・非表示切り替え
       */
      showCurrentWeekPatternDetail: false,
      /**
       * 変更後の曜日パターンの指示詳細情報表示・非表示切り替え
       */
      showNewWeekPatternDetail: false,
      /**
       * 現在の曜日
       */
      currentWeek: [],
      /**
       * 現在選択中の新規曜日
       */
      currentSelectWeek: null,
      /**
       * 表示情報
       */
      dispInfo: [],
      /**
       * 新規表示情報
       */
      newDispInfo: [],
      /**
       * タイマー
       */
      timer: null,
      /**
       * 参照元で画面更新を行うかどうかのフラグ
       * @summary 更新を行うかどうかは参照元画面で判断
       */
      isRefresh: false,
      /**
       * モーダルスタイル
       */
      styleObj: { "max-width": "375px", width: "375px" },
      /**
       * マスタ情報
       */
      mstInfo: {},
      /**
       * マスタ取得フラグ
       */
      isGetMstInfo: false,
      /**
       * 保存ボタン非活性フラグ
       */
      updateDisable: false,
      /**
       * 操作不可フラグ
       */
      procDisable: false,
      /**
       * 編集中フラグ(初期値は初期表示対策)
       */
      editing: true,
      /**
       * 編集前の値を保持する用
       */
      initDataValue: null,
      // add 画面デザイン改善対応 李 start
      callsNumberIntervalFlg: false,
      firIntervalValue: null,
      // add 画面デザイン改善対応 李 end
      // 425、426 姜 start
      structData: null,
      patExamFlg: false,
      patExamCd: null,
      diaViewExam: false,
      messageExam: null,
      facilitySettingExamValue: null,
      facilitySettingExamFlg: false,
      patRadFlg: false,
      patRadCd: null,
      diaViewRad: false,
      messageRad: null,
      facilitySettingExamScheduleChangeLimitDay: 0,
      facilitySettingRadScheduleChangeLimitDay: 0,
      facilitySettingExamScheduleChangeLimitTime: 0,
      facilitySettingRadScheduleChangeLimitTime: 0,
      facilitySettingRadValue: null,
      facilitySettingRadFlg: false,
      examStatus: false,
      radStatus: false,
      patEventFlg: false,
      patEventCd: null,
      diaViewEven: false,
      messageEvend: null,
      facilitySettingEventValue: null,
      examFLG: false,
      radFLG: false,
      allExam: null,
      allRad: null,
      sendJsonData: {},
      facilitySettingExamChangeOnOffWithOrder: null,
      facilitySettingRadChangeOnOffWithOrder: null,
      paramsfacilitySettingRadValue: null,
      paramsfacilitySettingExamValue: null,
      idos: [],
      // 425、426 姜 end
      //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
      cover:true,
      skip:false,
      //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
      //内部remine 5840  mod ljx start
      maxTreatDate:"",
      firstDayOfCurrentWeek:"",
      lastDayOfNextWeek:"",
      beforeAfterFlag:"",
      selectedDate:"",
      //内部remine 5840  mod ljx end
      delDateList: [],
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc start
      missingDateList: [],
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc end
      // #10196 曜日変更過去日は手入力できません linjunfeng start
      indTreatInputStartDate: this.startDate,
      indTreatInputEndDate: this.endDate,
      // #10196 曜日変更過去日は手入力できません linjunfeng end
      // add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy start
      messageExamTitle:null,
      messageRadTitle: null,
      messageEvendTitle:null,
      // add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy end
      // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
      linkageFlag: null,
      msgCdList: [],
      examDeadlineSelectedVal: "",
      radDeadlineSelectedVal: "",
      examDeadlineCancelCheck: "",
      radDeadlineCancelCheck: "",
      msgCd: null,
      // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      dateInfoArrayForSave: [],
      // add #11717【因島】曜日パターン変更の動作が遅い fang end
      isDragging: false,
      isIOS: false,
    };
  },
  // 425 姜 start
  mounted() {
    //9273 start
    // this.messageEvend = this.messageInfo(DEF_DIALOG_MSG_23);
    // this.messageExam = this.messageInfo(DEF_DIALOG_MSG_21);
    // this.messageRad = this.messageInfo(DEF_DIALOG_MSG_22);
    // add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy start
    this.messageExamTitle = this.messageTitle(DEF_DIALOG_MSG_30);
    this.messageRadTitle = this.messageTitle(DEF_DIALOG_MSG_31);
    this.messageEvendTitle = this.messageTitle(DEF_DIALOG_MSG_32);
    // add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy end
    this.messageExam = this.messageInfo(DEF_DIALOG_MSG_30);
    this.messageRad = this.messageInfo(DEF_DIALOG_MSG_31);
    this.messageEvend = this.messageInfo(DEF_DIALOG_MSG_32);
    //9273 end
    // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
    const ownerDocument = this.getScopedOwnerDocument();
    ownerDocument.addEventListener('preshow', function(event) {
      const dialog = getOnsAlertDialogFromEvent(event);
      const buttons = getOnsAlertDialogFooterItems(dialog);
      if (buttons[0]) {
        buttons[0].style.display = 'flex';
      }
    });
    // add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
    // drag中の矢印描画用canvasの縦、横サイズをdiv-parentに合わせる
    this.setCanvasSize();
    this.getScopedOwnerWindow()?.addEventListener("resize", this.setCanvasSize);
    // iPadでドラッグ中にスクロールが起きないようにする
    const parent = this.getScopedElementByIdSafe('div-parent');
    parent?.addEventListener?.('touchmove', (e) => {
      if (this.isDragging) {
        e.preventDefault();
      }
    }, { passive: false });
  },
  // 425 姜 end
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getFontSize"]),
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    //患者ID取得用
    ...mapGetters("pat-info", ["selectedPatId", "selectedPat"]),
    //内部remine 5840  mod ljx start
    ...mapGetters("pat-viewer", ["getPriorToChangeList","getAfterToChangeList","getTreatmentDataOfPeriod","getTreatmentDataOfPeriodTmp"]),
    //内部remine 5840  mod ljx end
    ...mapGetters("pat-viewer", { getExamMainData : "getExamMainData", getRadMainData : "getRadMainData"}),
    //9273 start
    ...mapGetters("exam-request/list", ["getDeadlineCondition"]),
    ...mapGetters("rad-request/list", { getRadDeadlineCondition: "getDeadlineCondition" }),
    //9273 end
    currentWeekStyle() {
      let w = weekWidth;
      if (this.currentWeekNum > 0) {
        w = (w * 7) / this.currentWeekNum + (7 - this.currentWeekNum);
      }
      return { width: `${w}px` };
    },

    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
    // /**
    //  * 現在の曜日情報
    //  */
    // fromWeekInfo() {
    //   return this.selectionInfo.fromWeekInfo;
    // },
    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end

    /**
     * 終了日の最大日(本日から一年未満)
     */
    maxDate() {
      // スケジュール延長最終日
      const schExtEndDate = this.selectedPat.pat_main.sch_ext_end_date;
      const day = dayjs().format("YYYYMMDD");
      // データが無ければ、一年後に最大日を設定
      let endMaxDate = schExtEndDate
        ? dayjs(schExtEndDate, "YYYYMMDD")
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
    }
    //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start
    /**
     * 指定日前編集不可
     */
    ,disableDatesBefore() {
      return dayjs(this.indTreatStartDate).format("YYYYMMDD");
    },
    toMonth() {
      return dayjs(this.indTreatStartDate).format("YYYY-MM-DD");
    },
    //add 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isChanged(){
      if(this.indTreatEndDate === null){
        this.initIndTreatEndDate = null
      }
      return this.arrowInfoLength !== 0;
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },

  watch: {
    // 治療方法選択の監視
    selectedTreatmentCd(value) {
      // 曜日パターンの設定
      this.setPatternWeek(value);
      // 治療方法名を取得
      const selObj = this.weekPerTreatList.find(item => {
        // 選択した治療方法コードのオブジェクトを格納
        return item.treatmentCd === value;
      });
      if (selObj) {
        this.treatmethodDispValue = selObj.treatmentName;
      }
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
      // // 曜日選択情報の作成
      // this.createSelection();
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end
      // canvasイベントの追加
      this.$nextTick(() => {
        this.canvasProc();
      });
      // 矢印情報を初期化
      this.clearArrows();

      // add FNSI-障害票一覧_患者経過総合ビューアNo.62 李 start
      // 初回ロード時、初期状態が記録され、初期値が保存される
      if (!this.callsNumberIntervalFlg) {
        this.callsNumberIntervalFlg = true;
        this.firIntervalValue = value;
      }

      // add FNSI-障害票一覧_患者経過総合ビューアNo.62 李 end
      //内部remine 5840  mod ljx start
      this.clearAfterFormat(null);
      this.filterTreatmentDataOfPeroid();
      this.clearTreatmentDetail();
      this.clearSelectedDate();
      this.clearClickClass();
      //内部remine 5840  mod ljx end
    },

    // add FNSI-画面デザイン修正_患者経過総合ビューア「曜日グループボタン」 周 start
    procDisable (value) {
      if (value) {
        // 操作不可
        this.getScopedElementByIdSafe('currentWeekList')?.classList?.add("custom-week-disabled");
        this.getScopedElementByIdSafe('currentWeekListTo')?.classList?.add("custom-week-disabled");
      } else {
        // 操作可
        this.getScopedElementByIdSafe('currentWeekList').classList.remove("custom-week-disabled");
        this.getScopedElementByIdSafe('currentWeekListTo').classList.remove("custom-week-disabled");
      }
    },
    // add FNSI-画面デザイン修正_患者経過総合ビューア「曜日グループボタン」 周 end

    // 開始日変更の監視(カレンダーからの変更を取得する為の処理)
    indTreatStartDate(inputDate) {
      // // 入力日付の制限
      // const date = parseInt(dayjs(inputDate).format("YYYYMMDD"));
      // // 過去日制御
      // const today = parseInt(dayjs().format("YYYYMMDD"));
      // if(!date){
      //   return;
      // }
      // if (today > date) {
      //   this.indTreatStartDate = dayjs().format("YYYY-MM-DD");
      // }
      // // 最大値の制御
      // const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
      // if (date > maxDate) {
      //   this.indTreatStartDate = dayjs(this.maxDate).format("YYYY-MM-DD");
      // }
      // #10196 曜日変更過去日は手入力できません linjunfeng start
      const endDate = this.indTreatEndDate ? this.indTreatEndDate : "";
      if (endDate === "") {
        let threeYearAgo = dayjs().subtract(3, 'years').format("YYYY-MM-DD");
        if (inputDate < threeYearAgo) {
          this.indTreatStartDate = threeYearAgo;
        } else {
          this.indTreatStartDate = inputDate;
        }
      } else {
        if (dayjs(inputDate).add(3, 'years').format("YYYYMMDD") < endDate) {
          this.indTreatStartDate = dayjs(endDate).subtract(3, 'years').format("YYYY-MM-DD");
        } else {
          this.indTreatStartDate = inputDate;
        }
      }
      if (inputDate === "") {
        this.indTreatStartDate = "";
      }
      // #10196 曜日変更過去日は手入力できません linjunfeng end
      // 治療方法、曜日の更新
      this.updateWeekPerTreatCdList();
      //内部remine 5840  add ljx start
      this.setTreatmentDataOfPeroid();
      this.updatePriorToChangeList();
      this.clearAfterFormat(null);
      //内部remine 5840  add ljx end
      // #10196 曜日変更過去日は手入力できません linjunfeng start
      this.indTreatInputStartDate = this.indTreatStartDate;
      // #10196 曜日変更過去日は手入力できません linjunfeng end
    },

    // 終了日変更の監視(カレンダーからの変更を取得する為の処理)
    indTreatEndDate(inputDate) {
      // // 入力日付の制限
      // const date = parseInt(dayjs(inputDate).format("YYYYMMDD"));
      // // 過去日制御
      // const startday = parseInt(dayjs(this.indTreatStartDate).format("YYYYMMDD"));
      // if (startday > date) {
      //   this.indTreatEndDate = dayjs(this.indTreatStartDate).format("YYYY-MM-DD");
      // }
      // // 最大値の制御
      // const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
      // if (date > maxDate) {
      //   this.indTreatEndDate = dayjs(this.maxDate).format("YYYY-MM-DD");
      // }
      // 治療方法、曜日の更新
      this.updateWeekPerTreatCdList();
      //内部remine 5840  add ljx start
      this.updatePriorToChangeList();
      this.setTreatmentDataOfPeroid();
      this.clearAfterFormat(null);
      //内部remine 5840  add ljx end
      // #10196 曜日変更過去日は手入力できません linjunfeng start
      this.indTreatInputEndDate = this.indTreatEndDate;
      // #10196 曜日変更過去日は手入力できません linjunfeng end
    },

    // add 画面デザイン改善対応 李 start
    // del FNSI-障害票一覧_患者経過総合ビューアNo.62 李 start
    // selectedTreatmentCd(val) {
    //   // 初回ロード時、初期状態が記録され、初期値が保存される
    //   if (!this.callsNumberIntervalFlg) {
    //     this.callsNumberIntervalFlg = true;
    //     this.firIntervalValue = val;
    //   }

    //   // 選択した値と初期値が異なる場合
    //   if (val != this.firIntervalValue) {
    //     this.scopedJQuery('#v-ons-select-id').addClass('custom-select-edited');
    //   } else {
    //     this.scopedJQuery('#v-ons-select-id').removeClass('custom-select-edited');
    //   }
    // },
    // del FNSI-障害票一覧_患者経過総合ビューアNo.62 李 end

    selectedIndUser(val) {
      // 選択した値と初期値が異なる場合
      if ((val ?? "") != (this.initSelectedIndUser ?? "")) {
        setKendoDropDownListEditedState(this.getScopedRoot(), { enabled: true });
      } else {
        setKendoDropDownListEditedState(this.getScopedRoot(), { enabled: false });
      }
    }
    // add 画面デザイン改善対応 李 end
  },

  async created() {
    const ua = ((this.getScopedOwnerWindow()?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    const mac = ua.indexOf('mac');
    const os = ua.indexOf('os');
    if(mac > 0 && os > 0){
      this.isIOS = true;
    }
    //内部remine 5840  add ljx start
    EventBus.$on("showBeforeTreatmentDetail", this.showBeforeTreatmentDetail);
    EventBus.$on("showAfterTreatmentDetail", this.showAfterTreatmentDetail);
    //内部remine 5840  add ljx end
    //add FNSI-No.IES145 権限対応  吉 start
    this.setLoadingScreenVisible(true);
    //add FNSI-No.IES145 権限対応  吉 end
    // mod FNSI-曜日パターン変更の開始日に基準日を変更する 李 start
    if (this.startDate) {
      this.indTreatStartDate = this.startDate;
    } else {
      this.indTreatStartDate = dayjs().format("YYYY-MM-DD");
    }
    // mod FNSI-曜日パターン変更の開始日に基準日を変更する 李 end

    // 曜日パターンの設定
    this.setPatternWeek();
    // 変更先の曜日パターンの設定
    this.setToPatternWeek();
    // 治療方法マスタの取得
    await this.getMstTreatment();
    // 治療予定から、治療方法、曜日のリストを取得
    await this.getWeekPerTreatCdList();
    // 指示者情報作成
    this.getIndUserList(
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.IND_PEDIT).then(response => {
      this.indUserOptions = response.doctorList;
      this.$nextTick(() => {
        this.selectedIndUser = response.iniSelectId;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
        this.initSelectedIndUser = this.selectedIndUser;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
        // 表示領域の調整
        this.getScopedElementsByClassNameSafe(
          "in-ind-dropdown-area")[0].parentElement.parentElement.style.height = "calc(5rem + 1em)";
      });
    });
    // マスタ情報取得
    await this.getMstInfo();
    this.editing = false;
    //add FNSI-No.IES145 権限対応  吉 start
    this.setLoadingScreenVisible(false);
    //add FNSI-No.IES145 権限対応  吉 end
    // 425 姜 start
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    // 変更前の日付を取得します
    const newDetailInfo = this.toTreatPatternWeekInfo.filter(item => {
      return null !== item.fromWeek;
    });
    if (newDetailInfo) {
      //内部remine 5840  mod ljx start
      // del #9273 施設設定マスタのNo105の設定どおり動かない。張玲 start
      // this.filterTreatmentDataOfPeroid();
      // del #9273 施設設定マスタのNo105の設定どおり動かない。張玲 end
      // 最大の治療日を取得します
      const patId = this.patId;
      const facilityCd = this.facilityCd;
      ApiHelper.get("mainData/changeDay/maxTreatmentDate", {patId, facilityCd}).then(response => {
        if (response && response.data) {
          this.maxTreatDate = String(response.data);
          // 変更前の日付を設定する（#10196 と同様 dayjs で日付を1日ずつ加算）
          this.updatePriorToChangeList();
          // add #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 start
          this.setTreatmentDataOfPeroid('init');
          // add #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 end
          //内部remine 5840  mod ljx end
        }
      })
    }
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    this.initSelectedTreatmentCd = JSON.stringify(this.selectedTreatmentCd);
    this.initIndTreatStartDate = JSON.stringify(this.indTreatStartDate);
    this.initIndTreatEndDate = JSON.stringify(this.indTreatEndDate);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },
  beforeUnmount() {
      //内部remine 5840  add ljx start
      EventBus.$off("showBeforeTreatmentDetail", this.showBeforeTreatmentDetail);
      EventBus.$off("showAfterTreatmentDetail", this.showAfterTreatmentDetail);
      //内部remine 5840  add ljx start
  },

  methods: {
    getScopedRoot() {
      return this.$refs?.modalBodyRoot || this.$el || this;
    },
    getScopedOwnerDocument() {
      return getScopedDocument(this.getScopedRoot());
    },
    getScopedOwnerWindow() {
      return this.getScopedOwnerDocument()?.defaultView || globalThis?.window || null;
    },
    getScopedOwnerBody() {
      return this.getScopedOwnerDocument()?.body || globalThis?.document?.body || null;
    },
    getScopedElementByIdSafe(id) {
      return getScopedElementById(id, this.getScopedRoot()) || this.getScopedOwnerDocument()?.getElementById?.(id) || null;
    },
    getScopedElementsByClassNameSafe(className) {
      const scoped = getScopedElementsByClassName(className, this.getScopedRoot());
      return scoped.length ? scoped : Array.from(this.getScopedOwnerDocument()?.getElementsByClassName?.(className) || []);
    },
    queryScopedSelectorSafe(selector) {
      return queryScopedSelector(selector, this.getScopedRoot()) || this.getScopedOwnerDocument()?.querySelector?.(selector) || null;
    },
    scopedJQuery(selector, context) {
      const jq = getScopedJQuery(this.getScopedRoot(), $);
      return (jq || $)(selector, context);
    },
    //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapActions("notification-message", [
      "registerNotificationMessage"
    ]),
    // mod FNSI-連携イベントの登録適正化 楊 end
    // add 障害票一覧_患者経過総合ビューア_治療予定(曜日パターン変更)No.1 李 start
    ...mapGetters("pat-viewer", [
      "getMstKurData"
    ]),
    // add 障害票一覧_患者経過総合ビューア_治療予定(曜日パターン変更)No.1 李 end
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    ...mapActions("pat-viewer", [
      "setPriorToChangeList",
      //内部remine 5840  add ljx start
      "setAfterToChangeList",
      "getOrdMainOfPeriod",
      "setTreatmentDataOfPeriodTmp",
      //内部remine 5840  add ljx end
    ]),
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    //FNSI-修正 #5525 横展開対応、xugj add start
    ...mapActions("treatment-record/common",
      [
        "getMstMachineByOrdNoRst",
        "sendNextPatInfoViewer"
      ]),
    //9273 start
    ...mapActions("exam-request/list", ["setExamDeadline"]),
    ...mapActions("rad-request/list", ["setRadDeadline"]),
    //9273 end
    /**
     * 治療日の調整
     */
    AdjustTreatStartDate(treatDate,startDate) {
      if(treatDate == ""){
        return;
      }
      // 期間指定での操作の場合以下の処理を実行
        const date = parseInt(dayjs(treatDate).format("YYYYMMDD"));
        // 過去日制御
        let today;
        if (startDate) {
          today = parseInt(dayjs().format("YYYYMMDD"));
        }else{
          today = parseInt(dayjs(this.indTreatStartDate).format("YYYYMMDD"));
        }
        if (today > date) {
          if (startDate) {
            this.indTreatStartDate = dayjs().format("YYYY-MM-DD");
          }else{
            this.indTreatEndDate = dayjs(this.indTreatStartDate).format("YYYY-MM-DD");
          }
        }else{
          if (startDate) {
            this.indTreatStartDate = dayjs(treatDate).format("YYYY-MM-DD");
          }else{
            this.indTreatEndDate = dayjs(treatDate).format("YYYY-MM-DD");
          }
        }
        // 最大値の制御
        const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
        if (date > maxDate) {
          if (startDate) {
            this.indTreatStartDate = dayjs(this.maxDate).format("YYYY-MM-DD");
          }else{
            this.indTreatEndDate = dayjs(this.maxDate).format("YYYY-MM-DD");
          }
        }
    },
    // mod 8560 開始日の日付のキーボード入力が不正 張
    //FNSI-修正 #5525 横展開対応、xugj add end
    /**
     * 治療方法と曜日のリストの更新
     */
    updateWeekPerTreatCdList() {
      if (this.editing) {
        // 編集中は処理を行わない
        return;
      }
      this.startLoadingScreen();

      // 治療予定から、治療方法、曜日のリストを取得
      this.getWeekPerTreatCdList().then(() => {
        const value = this.weekPerTreatList.length > 0 ? this.selectedTreatmentCd : null;
        // 曜日パターンの設定
        this.setPatternWeek(value);
        if (this.weekPerTreatList.length > 0) {
          // 治療方法名を取得
          const selObj = this.weekPerTreatList.find(item => {
            // 選択した治療方法コードのオブジェクトを格納
            return item.treatmentCd === value;
          });
          if (selObj) {
            this.treatmethodDispValue = selObj.treatmentName;
          }
          // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
          // // 曜日選択情報の作成
          // this.createSelection();
          // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end
          // canvasイベントの追加
          this.$nextTick(() => {
            this.canvasProc();
          });
        }
        // 矢印情報を初期化
        this.clearArrows();
        //内部remine 5840  add ljx start
        this.clearTreatmentDetail();
        this.clearSelectedDate();
        this.clearClickClass();
        //内部remine 5840  add ljx end
      }).finally(() => {
        this.finishLoadingScreen();
      });
    },
    //内部remine 5840  add ljx start
    updatePriorToChangeList(){
      let startDateYMD = dayjs(this.indTreatStartDate).format('YYYYMMDD');
      let endDateYMD = this.indTreatEndDate
        ? dayjs(this.indTreatEndDate).format('YYYYMMDD')
        : String(this.maxTreatDate);
      let priorToChangeList = [];
      if (startDateYMD && endDateYMD && startDateYMD !== 'Invalid Date') {
        const endDateParsed = dayjs(endDateYMD, 'YYYYMMDD');
        if (!endDateParsed.isValid()) {
          this.setPriorToChangeList(priorToChangeList);
          return;
        }
        const weekOfDay = endDateParsed.day();
        // #10196 曜日変更過去日は手入力できません linjunfeng start
        const endDate = endDateParsed.add(14 - weekOfDay, 'days').format('YYYYMMDD');
        // #10196 曜日変更過去日は手入力できません linjunfeng end
        if(dayjs(this.indTreatStartDate).day() === 0){
          startDateYMD = dayjs(this.indTreatStartDate).subtract(1, 'days').format('YYYYMMDD');
        }
        // #10196 曜日変更過去日は手入力できません linjunfeng start
        const startDate = dayjs(startDateYMD, 'YYYYMMDD').startOf("week").add(1, 'days').format("YYYYMMDD");
        // #10196 曜日変更過去日は手入力できません linjunfeng end
        this.firstDayOfCurrentWeek = dayjs(startDateYMD, 'YYYYMMDD').startOf("week").add(1, 'days').format("YYYYMMDD");
        this.lastDayOfNextWeek = endDate;
        if (dayjs(startDate, 'YYYYMMDD').isValid() && dayjs(endDate, 'YYYYMMDD').isValid() && startDate <= endDate) {
          let currentDate = startDate;
          while (currentDate <= endDate) {
            priorToChangeList.push(currentDate.toString());
            currentDate = dayjs(currentDate, 'YYYYMMDD').add(1, 'days').format("YYYYMMDD");
          }
        }
      }
      this.setPriorToChangeList(priorToChangeList);
    },
    //mod #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 start
    async setTreatmentDataOfPeroid(string){
       let newStartDate = dayjs(this.indTreatStartDate).format('YYYYMMDD');
       if(dayjs(this.indTreatStartDate).day() === 0){
         newStartDate = dayjs(this.indTreatStartDate, 'YYYYMMDD').subtract(1, 'days').format('YYYYMMDD');
       }
       let newFirstDayOfCurrentWeek = dayjs(newStartDate).startOf("week").add(1, 'days').format("YYYYMMDD");
       let oldStartDate = dayjs(this.firstDayOfCurrentWeek).format('YYYYMMDD');
       if (string || dayjs(newFirstDayOfCurrentWeek).isBefore(dayjs(oldStartDate))) {
        await this.getOrdMainOfPeriod({
          facilityCd: this.facilityCd,
          patId: this.patId,
          startDay: newFirstDayOfCurrentWeek,
          endDay: this.lastDayOfNextWeek,
          weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`
        }).then((res)=>{
          //add #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 start
          this.filterTreatmentDataOfPeroid()
          //add #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 end
        }).catch(err => {
          getErrorMessage('PatViewer.vue', 'setTreatmentData', err);
          alert(err);
        });
       }else{
         let newEndDate =this.indTreatEndDate ==""? dayjs(this.maxTreatDate,'YYYY-MM-DD'):dayjs(this.indTreatEndDate).format('YYYY-MM-DD');
         let treatmentDataTmp = {};
         let treatmentData;
         for(var i = 0;i<this.getTreatmentDataOfPeriod.length;i++){
           treatmentData = this.getTreatmentDataOfPeriod[i];
           for(const treatment in treatmentData){
             if(treatmentData[treatment]){
               if(!dayjs(treatment).isAfter(dayjs(newEndDate))&&treatmentData[treatment].indTreatmentCd === this.selectedTreatmentCd){
                 treatmentDataTmp[treatment]=treatmentData[treatment];
               }
             }
           }
         }
         this.setTreatmentDataOfPeriodTmp(treatmentDataTmp);
       }

    },
    // mod #9273 施設設定マスタのNo105の設定どおり動かない。 張玲 end
    filterTreatmentDataOfPeroid() {
      let treatmentData;
      let treatmentDataTmp = {};
      for (let i = 0; i < this.getTreatmentDataOfPeriod.length; i++) {
        const rowData = this.getTreatmentDataOfPeriod[i];
        for (const date in rowData) {
          const treatment = rowData[date];
          if (treatment && treatment.indTreatmentCd === this.selectedTreatmentCd) {
            treatmentDataTmp[date] = treatment;
          }
        }
      }
      const currentData = this.getTreatmentDataOfPeriodTmp;
      if (Object.keys(treatmentDataTmp).length === 0 && currentData && Object.keys(currentData).length > 0) {
        return;
      }
      this.setTreatmentDataOfPeriodTmp(treatmentDataTmp);
    },
    //内部remine 5840  add ljx end

    /**
     * フォーカス時、変更前の値を保持し、編集中フラグをオンにする
     */
    //mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao start
    // focusStartEditing(value,isStratTime) {
    //   this.editing = true;
    //   this.initDataValue = value;
    // },
    focusStartEditing(value,isStratTime) {
      this.editing = true;
      if(isStratTime==1){
        if(!value){
          this.editing = true;
        }
      }
      this.initDataValue = value;
    },
    //mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao end

    /**
     * ブラー時、編集中フラグをオフにし、変更されていれば治療方法、曜日の更新を行う
     */
    //mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao start
    // blurUpdate(value,isStartTime) {
    //   this.editing = false;
    //   // 変更された場合のみ実施
    //   if (this.initDataValue !== value) {
    //     this.updateWeekPerTreatCdList();
    //   }
    // },
    blurUpdate(value,isStartTime) {
      this.editing = false;
      if(isStartTime==1){
        if(!value){
          this.editing = true;
        }
      }
      // 変更された場合のみ実施
      if (this.initDataValue !== value) {
        this.updateWeekPerTreatCdList();
      }
      // #10196 曜日変更過去日は手入力できません linjunfeng start
      if (isStartTime == 1) {
        this.indTreatStartDate = value;
      }
      if (isStartTime == 2) {
        this.indTreatEndDate = dayjs(value, "YYYY-MM-DD", true).isValid() ? value : "";
      }
      // #10196 曜日変更過去日は手入力できません linjunfeng end
    },
    //mod 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao end

    /**
     * マスタ情報を取得
     * @description 詳細画面にわたすマスタ情報の取得
     */
    async getMstInfo() {
      await this.getMstBed();
      await this.getMstKur();
      await this.getMstVa();
      await this.getMstDialyzer();
      await this.getMstMedicine();
      await this.getMstMedicineMix();
      await this.getMstProcedure();
      await this.getMstMedicateTiming();
      await this.getMstEquipment();
      await this.getMstDialyzerTabooAllergy();
      await this.getMstMedicineTabooAllergy();
      await this.getMstMedicineMixTabooAllergy();
      await this.getMstEquipmentTabooAllergy();
      this.isGetMstInfo = true;
    },

    /**
     * VAマスタを取得する
     */
    async getMstVa() {
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      this.mstVaInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstVa",
        requestParam).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstVa', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstVaInfo = response.data;
    },

    /**
     * ダイアライザマスタを取得する
     */
    async getMstDialyzer() {
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      this.mstDialyzerInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstDialyzer",
        requestParam).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstDialyzer', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstDialyzerInfo = response.data;
    },

    /**
     * ダイアライザマスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstDialyzerTabooAllergy() {
      this.mstDialyzerTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstDialyzer/${this.selectedPatId}`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstDialyzerTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstDialyzerTabooAllergyInfo = response.data;
    },

    /**
     * 薬剤マスタを取得する
     */
    async getMstMedicine() {
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      this.mstMedicineInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstMedicine",
        requestParam).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstMedicine', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstMedicineInfo = response.data;
    },

    /**
     * 薬剤マスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstMedicineTabooAllergy() {
      this.mstMedicineTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstMedicine/${this.selectedPatId}`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstMedicineTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstMedicineTabooAllergyInfo = response.data;
    },

    /**
     * 調製薬剤マスタを取得する
     */
    async getMstMedicineMix() {
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      this.mstMedicineMixInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstMedicineMix",
        requestParam).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstMedicineMix', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstMedicineMixInfo = response.data;
    },

    /**
     * 調製薬剤マスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstMedicineMixTabooAllergy() {
      this.mstMedicineMixTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstMedicineMix/${this.selectedPatId}`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstMedicineMixTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstMedicineMixTabooAllergyInfo = response.data;
    },

    /**
     * 手技マスタを取得する
     */
    async getMstProcedure() {
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      this.mstProcedureInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstProcedure",
        requestParam).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstProcedure', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstProcedureInfo = response.data;
    },

    /**
     * 投与タイミングマスタを取得する
     */
    async getMstMedicateTiming() {
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      this.mstMedicateTimingInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstMedicateTiming",
        requestParam).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstMedicateTiming', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstMedicateTimingInfo = response.data;
    },

    /**
     * 医療材料マスタを取得する
     */
    async getMstEquipment() {
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      this.mstEquipmentInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstEquipment",
        requestParam).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstEquipment', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstEquipmentInfo = response.data;
    },

    /**
     * 医療材料マスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstEquipmentTabooAllergy() {
      this.mstEquipmentTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstEquipment/${this.selectedPatId}`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstEquipmentTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      this.mstInfo.mstEquipmentTabooAllergyInfo = response.data;
    },

    /**
     * 治療予定から、治療方法、曜日のリストを取得
     */
    async getWeekPerTreatCdList() {
      this.weekPerTreatList = [];
      // リスト取得用URL
      const url = "/mainData/WeekPerTreatCdList";
      // 検索条件
      const params = {
        pat_id: this.patId,
        facility_cd: this.facilityCd,
        start_date: this.indTreatStartDate.replace(/-/g, ""),
        end_date: this.indTreatEndDate.replace(/-/g, "")
      };
      // 患者治療パターン検索API呼び出し
      const response = await ApiHelper.post(url, params).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getWeekPerTreatCdList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      // データが取得できてている場合、以下の処理を実行
      if (0 !== response.data.length) {
        response.data.forEach(row => {
          const jsonObj = JSON.parse(row);
          this.weekPerTreatList.push({
            treatmentCd: Number(jsonObj.ind_treatment_cd),
            treatmentName: this.translateCd(
              this.mstTreatmentList,
              jsonObj.ind_treatment_cd,
              "treatment"),
            week: jsonObj.treat_week
          });
        });

        // 治療方法リストに情報が格納されている場合、先頭を選択済みとする
        this.selectedTreatmentCd =
        0 !== this.weekPerTreatList.length
          ? this.weekPerTreatList[0].treatmentCd
          : this.selectedTreatmentCd;

        // 操作不可解除
        this.procDisable = false;
        // 保存ボタン非活性解除
        this.updateDisable = false;
      } else {
        // 操作不可
        this.procDisable = true;
        // 保存ボタン非活性
        this.updateDisable = true;
        // メッセージの表示
        this.showMessage(22910001);
      }
    },

    /**
     * 治療方法マスタの取得
     */
    async getMstTreatment() {
      const response = await ApiHelper.get("/mstInfo/mstTreatment").catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstTreatment', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw error;
        });
      // データが存在する場合以下の処理を実行
      if (0 !== response.data.length) {
        this.mstTreatmentList = response.data.filter(item => {
          return (
            // 施設コードが一致しかつ、表示フラグが1のもののみ取得
            item.facilityCd === this.facilityCd && "1" === item.isDisp);
        });
      }
    },

    /**
     * ベッドマスタ取得
     */
    async getMstBed() {
      const response = await ApiHelper.get("/mstInfo/mstBed", {
        facility_cd: this.facilityCd,
        is_disp: "1",
        is_del: "0"
      }).catch(err => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstBed', err);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw err;
      });
      // ベッドマスタを格納
      this.mstInfo.mstBedInfo = response.data;
    },
    /**
     * クールマスタ取得
     */
    async getMstKur() {
      const response = await ApiHelper.get("/mstInfo/mstKur", {
        facility_cd: this.facilityCd,
        is_disp: "1",
        is_del: "0"
      }).catch(err => {
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getMstKur', err);
        throw err;
      });
      // クールマスタを格納
      this.mstInfo.mstKurInfo = response.data;
    },

    /**
     * マスタ翻訳
     * @description コードをマスタの名称に翻訳する
     * @param mstList マスタリスト
     * @param cd 翻訳前コード
     * @param mstName マスタ名
     * @return value 翻訳後の値
     */
    translateCd(mstList, cd, mstName) {
      let value = "未登録";
      const o = mstList.find(item => {
        return Number(cd) === item[`${mstName}Cd`];
      });
      // 一致するものがある場合、以下の翻訳処理を実施
      if (o) {
        value = o[`${mstName}Name`];
      }
      return value;
    },

    /**
     * 変更先曜日パターン情報を設定
     */
    setToPatternWeek() {
      this.toTreatPatternWeekInfo = [];
      for (let i = 1; i <= 7; i++) {
        const o = {
          value: i,
          text: this.convertWeekName(i),
          fromWeek: null
        };
        this.toTreatPatternWeekInfo.push(o);
      }
    },

    /**
     * 曜日パターンを設定
     */
    setPatternWeek(value) {
      // 治療パターン曜日情報を格納用
      const arr = [];
      let rowStyle = "unset";
      if (!value) {
        for (let i = 1; i <= 7; i++) {
          const o = {
            value: i,
            text: this.convertWeekName(i)
          };
          arr.push(o);
        }
        rowStyle = "hidden";
      } else {
        const findObj = this.weekPerTreatList.find(item => {
          return item.treatmentCd === value;
        });
        if (findObj) {
          // 選択された治療方法の曜日数を格納
          this.currentWeekNum = findObj.week.length;
          findObj.week.forEach(weekNum => {
            const o = {
              value: weekNum,
              text: this.convertWeekName(weekNum)
            };
            arr.push(o);
          });
        }
      }
      // 治療パターン曜日情報を格納
      this.treatPatternWeekInfo = arr;
      // 曜日データが存在しない場合は非表示にする
      const obj = this.getScopedElementByIdSafe("currentWeekList");
      if (obj) {
        obj.style.visibility = rowStyle;
      }
    },

    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
    // createSelection() {
    //   const arr = [{ value: null, text: "解除" }];
    //   const findObj = this.weekPerTreatList.find(item => {
    //     return item.treatmentCd === this.selectedTreatmentCd;
    //   });
    //   findObj.week.forEach(weekNum => {
    //     const obj = {
    //       value: weekNum,
    //       text: this.convertWeekName(weekNum)
    //     };
    //     arr.push(obj);
    //   });
    //   this.selectionInfo.fromWeekInfo = arr;
    // },
    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end

    /**
     * 曜日選択情報の設定
     */
    setSelection(e, toWeekInfo, index) {
      const ownerWindow = this.getScopedOwnerWindow() || window;
      if (e.type === 'click' && 'ontouchstart' in ownerWindow) {
        // iOSではtouchend後にclickが来るので、無視する
        return;
      }

      // タップ時の選択・解除処理
      if (this.toTreatPatternWeekInfo[index].fromWeek === null) {
        this.toTreatPatternWeekInfo[index].fromWeek = this.moveWeekElement;
      } else if (this.toTreatPatternWeekInfo[index].fromWeek === this.moveWeekElement) {
        this.toTreatPatternWeekInfo[index].fromWeek = null;
      }
      // 現在曜日がない時は開かない
      if (this.weekPerTreatList.length === 0) {
        return;
      }
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
      // // 変更先曜日情報の格納
      // this.selectionInfo.toWeekInfo = toWeekInfo;
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end
      // 現在選択した曜日情報を格納
      this.currentSelectWeek = index;
      // add FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
      for (let i = this.arrowInfo.length - 1; i >= 0; i--) {
        if (this.arrowInfo[i].index_to === this.currentSelectWeek) {
          this.arrowInfo.splice(i, 1);
          this.arrowInfoLength--;
        }
      }
      // 矢印情報が格納されている場合
      if (0 !== this.arrowInfo.length) {
        // 矢印を描画
        this.drowArrowLines(this.arrowInfo, true, true);
      } else {
        // 矢印をすべてクリア
        this.clearArrows();
        //内部remine 5840  add ljx start
        this.clearTreatmentDetail();
      }
      //5840 変更後の日付をクリア。
      this.clearAfterFormat(toWeekInfo);
      this.createMoveInfo(this.selectedDate,this.beforeAfterFlag)
      //mod 曜日パターン変更删掉又恢复后，日期的高亮显示有问题 张博 start
      // if(this.arrowInfo.length == 0){
      if(this.arrowInfo.length >= 0){
      //mod 曜日パターン変更删掉又恢复后，日期的高亮显示有问题 张博 end
        this.clearClickClass();
        this.clearMoveInfo();
        this.clearSelectedDate();
      }
      //内部remine 5840  add ljx end
      //5840 変更後の日付をクリア。
      this.clearAfterFormat(toWeekInfo);
      this.createMoveInfo(this.selectedDate,this.beforeAfterFlag)
      if(this.arrowInfo.length == 0){
        this.clearClickClass();
        this.clearMoveInfo();
        this.clearSelectedDate();
      }
      //内部remine 5840  add ljx end
      this.toTreatPatternWeekInfo[index].fromWeek = null;
      // 現在の展開情報を表示中の場合
      if (this.showNewWeekPatternDetail) {
        // 新規曜日パターン詳細情報を子コンポーネントに送る
        this.sendNewDetailInfo();
      }
      // add FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
      // // 選択肢要素の取得
      // const elem = this.getScopedElementByIdSafe("popChip");
      // const elemHeader = this.getScopedElementsByClassNameSafe("modal-header")[0];
      // // 表示位置の格納
      // elem.style.top = `${e.target.getBoundingClientRect().top - elemHeader.getBoundingClientRect().top -50}px`;
      // elem.style.left = `${e.target.getBoundingClientRect().left - elemHeader.getBoundingClientRect().left}px`;

      // // 選択メニューの表示
      // elem.style.display = "block";
      // // イベントの登録
      // elem.addEventListener("mouseout", this.offSelect, false);
      // elem.addEventListener("mouseover", this.onSelect, false);
      // // スマホで選択肢以外の場所をクリックした際の処理追加
      // document.body.addEventListener("touchstart", this.offClick, false);
      // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end
    },

    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
    // /**
    //  * 曜日選択情報以外をクリックした時の処理
    //  */
    // offClick(e) {
    //   const elem = this.getScopedElementByIdSafe("popChip");
    //   // 選択肢以外の場所をクリックした際に選択肢を消す
    //   if (!$(e.target).closest("#popChip").length) {
    //     elem.style.display = "none";
    //   }
    // },

    // /**
    //  * カーソルが範囲外に行った場合の処理
    //  */
    // offSelect() {
    //   this.timer = setTimeout(function() {
    //     // 表示OFF
    //     this.getScopedElementByIdSafe("popChip").style.display = "none";
    //     // 現在選択中の曜日を空に設定
    //     this.currentSelectWeek = null;
    //   }, 500);
    //   // this.getScopedElementByIdSafe("popChip").style.display = "none";
    // },

    // /**
    //  * 要素内に入ってきた時の処理
    //  */
    // onSelect() {
    //   clearTimeout(this.timer);
    // },

    // /**
    //  * 選択肢による曜日元選択
    //  */
    // selectFromWeek(selectValue) {
    //   let isExistence = false;
    //   for (let i = 0; i < this.arrowInfo.length; i++) {
    //     if (this.arrowInfo[i].index_to === this.currentSelectWeek) {
    //       isExistence = true;
    //       if (null !== selectValue.value) {
    //         this.arrowInfo[i].index_from = selectValue.value;
    //       } else {
    //         this.arrowInfo.splice(i, 1);
    //         this.arrowInfoLength--;
    //       }
    //     }
    //   }
    //   if (!isExistence && null !== selectValue.value) {
    //     // 矢印要素数を1増やす
    //     this.arrowInfoLength++;
    //     let w = weekWidth;
    //     if (this.currentWeekNum > 0) {
    //       w = (w * 7) / this.currentWeekNum + (7 - this.currentWeekNum);
    //     }
    //     const canvas = this.scopedJQuery("#arrowCanvas")[0];
    //     const endArrow =
    //       this.scopedJQuery(canvas).width() - (w + 1) * this.treatPatternWeekInfo.length;
    //     const width =
    //       weekWidth * 0.5 + (weekWidth + 1) * this.currentSelectWeek;
    //     const o = {
    //       index_from: selectValue.value,
    //       index_to: this.currentSelectWeek,
    //       st_y: "0",
    //       ed_x: endArrow + width,
    //       ed_y: 42
    //     };
    //     this.arrowInfo.push(o);
    //   }

    //   this._compatSet(this.selectionInfo.toWeekInfo, "fromWeek", selectValue.value);
    //   // 矢印情報が格納されている場合
    //   if (0 !== this.arrowInfo.length) {
    //     // 矢印を描画
    //     this.drowArrowLines(this.arrowInfo, true);
    //   } else {
    //     // 矢印をすべてクリア
    //     this.clearArrows();
    //   }
    //   const elem = this.getScopedElementByIdSafe("popChip");
    //   // 選択メニューの非表示
    //   elem.style.display = "none";
    //   // 現在の展開情報を表示中の場合
    //   if (this.showNewWeekPatternDetail) {
    //     // 新規曜日パターン詳細情報を子コンポーネントに送る
    //     this.sendNewDetailInfo();
    //   }
    // },
    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end

    /**
     * canvas操作
     * @description 対象の曜日にイベントの追加
     */
    canvasProc() {
      // 現在の曜日パターン要素の取得
      // #10266 曜日変更、同じ曜日選択、開始終了期間変更、再度同じ曜日選択、操作卓エラー linjunfeng start
      // const element = this.scopedJQuery(".week-box");
      const element = this.scopedJQuery(".week-box").not('.drag');
      // #10266 曜日変更、同じ曜日選択、開始終了期間変更、再度同じ曜日選択、操作卓エラー linjunfeng end
      this.weekElements = element;
      // 新規の曜日パターン要素の取得
      const toElement = this.scopedJQuery(".to-week-box");
      this.toWeekElements = toElement;
      // 現在の曜日boxにイベントを追加
      for (let i = 0; i < element.length; i++) {
        element[i].addEventListener("mousedown", this.mouseDown, false);
        element[i].addEventListener("touchstart", this.mouseDown, false);
      }

      // キャンバスの配置位置
      const canvasElement = this.scopedJQuery("#arrowCanvas")[0];
      const elementRect = canvasElement.getBoundingClientRect();
      this.canvasPosTop = parseInt(elementRect.top);
      this.canvasPosLeft = parseInt(elementRect.left);

      // 各曜日要素のサイズの半分
      const styleFrom = element[0].getBoundingClientRect();
      const styleTo = toElement[0].getBoundingClientRect();

      this.fromHeight = parseInt(styleFrom.height) / 2;
      this.distHeight = parseInt(styleTo.height) / 2;
      this.fromWidth = parseInt(styleFrom.width) / 2;
      this.distWidth = parseInt(styleTo.width) / 2 - 3;
    },
    //内部remine 5840  add ljx start
    clearAfterFormat(toWeekInfo){
      let afterToChangeList = [];
      if(toWeekInfo){
        //5840 変更後の日付をクリア。
        afterToChangeList = this.getAfterToChangeList;
        let toWeekInfoValue = toWeekInfo.value === 7?0:toWeekInfo.value;
        afterToChangeList= afterToChangeList.filter(t => {
          return dayjs(t).day() !== toWeekInfoValue;
        });
      }
      this.setAfterToChangeList(afterToChangeList);
    },
    /**
     * 矢印情報から変更後日付リスト（change-list 変更後行の〇）を生成
     * @description 月水金など間欠曜日でも、期間内の全ての移動対象日を列挙する
     */
    buildAfterToChangeListFromArrows() {
      const afterToChangeList = [];
      if (!this.getPriorToChangeList || this.arrowInfo.length === 0) {
        return afterToChangeList;
      }
      const treatmentData = this.getTreatmentDataOfPeriodTmp || {};
      const dateCurrent = dayjs(this.indTreatStartDate).format("YYYYMMDD");
      let compareEnd = "";
      if (this.indTreatEndDate) {
        compareEnd = dayjs(this.indTreatEndDate).format("YYYYMMDD");
      }
      for (let i = this.arrowInfo.length - 1; i >= 0; i--) {
        const indexFrom = Number(this.arrowInfo[i].index_from);
        const weekDay = this.arrowInfo[i].index_to + 1 - indexFrom;
        for (let j = 0; j < this.getPriorToChangeList.length; j++) {
          const itemTestList = this.getPriorToChangeList[j];
          const beforeWeekCd =
            dayjs(itemTestList).day() === 0 ? 7 : dayjs(itemTestList).day();
          if (indexFrom !== beforeWeekCd) {
            continue;
          }
          const treatment = treatmentData[itemTestList];
          if (
            !treatment ||
            treatment.indTreatmentCd !== this.selectedTreatmentCd
          ) {
            continue;
          }
          if (dayjs(itemTestList).isBefore(dayjs(this.indTreatStartDate))) {
            continue;
          }
          const afterToDate =
            weekDay === 0
              ? itemTestList
              : dayjs(itemTestList).add(weekDay, "days").format("YYYYMMDD");
          if (afterToDate >= dateCurrent) {
            if (!compareEnd || afterToDate <= compareEnd) {
              if (!afterToChangeList.includes(afterToDate)) {
                afterToChangeList.push(afterToDate);
              }
            }
          }
        }
      }
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc start
      // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
      const lEndDate =
        this.indTreatEndDate == "" ? dayjs(this.maxDate, "YYYY-MM-DD") : "";
      if (this.indTreatEndDate == "" && this.arrowInfo.length > 0) {
        const toWeeks = this.arrowInfo.map(aio =>
          aio.index_to + 1 > 6 ? 0 : aio.index_to + 1
        );
        for (let k = 0; k < 7; k++) {
          const subtractDate = lEndDate.clone().subtract(k, "days");
          const subtractDateStr = subtractDate.format("YYYYMMDD");
          if (
            toWeeks.includes(subtractDate.day()) &&
            !afterToChangeList.includes(subtractDateStr)
          ) {
            afterToChangeList.push(subtractDateStr);
            if (!this.missingDateList.includes(subtractDateStr)) {
              this.missingDateList.push(subtractDateStr);
            }
          }
        }
      }
      // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc end
      return afterToChangeList;
    },
    //内部remine 5840  add ljx end

    /**
     * 変更元曜日でマウスがおされた際のイベント
     */
    mouseDown(e) {
      if (this.queryScopedSelectorSafe('.drag')) {
        // NOTE: すでに選択中曜日要素が存在したら何もしない
        return;
      }
      this.isDragging = true;
      // キャンバスの位置を取得
      const canvasElement = this.scopedJQuery("#arrowCanvas")[0];
      const elementRect = canvasElement.getBoundingClientRect();
      this.canvasPosTop = parseInt(elementRect.top);
      this.canvasPosLeft = parseInt(elementRect.left);

      const target = e.target;

      // どの要素が選ばれたのかを確認
      for (let i = 0; i < this.weekElements.length; i++) {
        if (target === this.weekElements[i]) {
          this.moveWeekElement = this.treatPatternWeekInfo[i].value;
        }
      }

      // クローンの作成
      const weekClone = target.cloneNode(true);
      weekClone.addEventListener("mousedown", this.mouseDown, false);
      weekClone.addEventListener("touchstart", this.mouseDown, false);

      // クローンのスタイルを設定
      weekClone.style.position = "absolute";
      weekClone.style.width = `${this.weekWidth / 2}px`;

      // 画面上に出ないように、一時的に表示がに移動させておく
      weekClone.style.top = "-100px";
      weekClone.style.left = "-100px";

      // dragのクラスを柄
      weekClone?.classList?.add("drag");

      // 曜日パターンモーダル内にクローンを生成
      this.getScopedElementByIdSafe("div-parent").appendChild(weekClone);
      // タッチイベントとマウスイベントの差異を吸収
      let event;
      if ("mousedown" === e.type) {
        event = e;
      } else {
        event = e.changedTouches[0];
      }

      // 要素内の相対座標を取得
      this.x = event.pageX - target.offsetLeft;

      this.y = event.pageY - target.offsetTop;

      // 矢印の横軸を格納
      this.arrowStartX = target.offsetLeft;

      // ムーブイベントにコールバック
      this.getScopedOwnerBody().addEventListener("mousemove", this.mouseMove, false);
      this.getScopedOwnerBody().addEventListener("touchmove", this.mouseMove, false);
      weekClone.addEventListener("mouseup", this.mouseUp, false);
      weekClone.addEventListener("touchend", this.mouseUp, false);
    },

    /**
     * マウスムーブイベント
     */
    mouseMove(e) {
      // ドラッグしている要素を取得
      const drag = this.scopedJQuery(".drag")[0];

      // 同様にマウスとタッチの差異を吸収
      let event;
      if ("mousemove" === e.type) {
        event = e;
      } else {
        event = e.changedTouches[0];
      }

      // モーダル内のスクロール量を取得
      const divParent = this.getScopedElementByIdSafe("div-parent");
      const scrollPos = divParent.scrollTop;

      // マウスが動いた位置に要素を動かす(共通のモーダルのtransform: scale(1.0)を戻す)
      const parentRect = this.getScopedElementByIdSafe("div-parent")
        .getBoundingClientRect();
      const dragRect = drag.getBoundingClientRect();
      drag.style.top = `${(event.pageY - parentRect.y - dragRect.height / 2) /
        1.0}px`;
      drag.style.left = `${(event.pageX - parentRect.x - dragRect.width / 2) /
        1.0}px`;

      // 位置の計算
      const st_x_add = this.arrowStartX - this.canvasPosLeft + this.fromWidth;
      const arX = event.pageX - this.canvasPosLeft;
      // マウスが動いたy座標位置にドラッグ中の矢印の先を表示する。このとき矢印の先が動かした要素の上に表示されるようにする。
      // 20 = drag中要素の高さの半分（※要素の高さ = 25) + 8
      const arY = event.pageY - this.canvasPosTop - (this.distHeight + 8);
      // 矢印データの登録
      this.arrowInfo[this.arrowInfoLength] = {
        index_from: this.moveWeekElement,
        index_to: "",
        st_x: st_x_add,
        st_y: 0,
        ed_x: arX,
        ed_y: arY // 矢印の先のキャンバス上のY座標
      };

      // 矢印の描画
      this.drowArrowLines(this.arrowInfo, true);

      for (let i = 0; i < this.toWeekElements.length; i++) {
        const rect = this.toWeekElements[i].getBoundingClientRect();
        const xStart = parseInt(rect.left);
        const yStart = parseInt(rect.top);
        const xEnd = parseInt(rect.left) + parseInt(rect.width);
        const yEnd = parseInt(rect.top) + parseInt(rect.height);

        // 範囲内だった場合の処理
        if (
          event.pageX >= xStart &&
          event.pageX <= xEnd &&
          event.pageY >= yStart &&
          event.pageY <= yEnd) {
          break;
        }
      }

      // カーソルスタイルを追加
      drag.style.cursor = "move";

      // マウスボタンが上げられたとき、またはカーソルが外れた時発火
      drag.addEventListener("mouseup", this.mouseUp, false);
      drag.addEventListener("touchend", this.mouseUp, false);
      this.getScopedOwnerBody().addEventListener("mouseleave", this.mouseUp, false);
      this.getScopedOwnerBody().addEventListener("touchend", this.mouseUp, false);
    },

    /**
     * マウスが上がったタイミングのイベント
     */
    mouseUp(e) {
      this.isDragging = false;
      // ドラッグ不可フラグ
      let noDragFlag = true;

      // 現在動かしている要素の取得
      const drag = this.scopedJQuery(".drag")[0];

      //ムーブベントハンドラの消去
      this.getScopedOwnerBody().removeEventListener("mousemove", this.mouseMove, false);
      this.getScopedOwnerBody().removeEventListener("touchmove", this.mouseMove, false);
      // 現在動かしている要素が存在すれば、処理を行う
      if (undefined !== drag) {
        drag.removeEventListener("mouseup", this.mouseUp, false);
        drag.removeEventListener("touchend", this.mouseUp, false);
      }
      this.getScopedOwnerBody().removeEventListener("mouseleave", this.mouseUp, false);
      this.getScopedOwnerBody().removeEventListener("touchend", this.mouseUp, false);

      // マウスタッチの差を吸収
      let event;
      if ("mouseup" === e.type) {
        event = e;
      } else {
        event = e.changedTouches && e.changedTouches.length > 0 ? e.changedTouches[0] : null;
      }

      // drop範囲のチェック
      for (let i = 0; i < this.toWeekElements.length; i++) {
        const rect = this.toWeekElements[i].getBoundingClientRect();
        const xStart = parseInt(rect.left);
        const yStart = parseInt(rect.top);
        const xEnd = parseInt(rect.left) + parseInt(rect.width);
        const yEnd = parseInt(rect.top) + parseInt(rect.height);

        // 新規曜日内の場合:矢印を追加して改めて全体の描画をします
        if (
          event?.pageX >= xStart &&
          event?.pageX <= xEnd &&
          event?.pageY >= yStart &&
          event?.pageY <= yEnd) {
          // 矢印の根元ののキャンバス上のX座標
          const st_x_add =
            this.arrowStartX - this.canvasPosLeft + this.fromWidth;

          // 矢印の根元のキャンパス上のY座標(Y座標は0)
          const st_y_add = 0;

          // 矢印の先のキャンパス上のX座標
          const arX = parseInt(rect.left) - this.canvasPosLeft + this.distWidth;

          // 矢印の先のキャンバス上のY座標(キャンバスの高さ-2pxを指定。キャンバスの高さと同じ値だと描画した矢印が少し見切れるため)
          const arY = 45;

          // del FNSI-改修内容 元ある予定に、違う曜日の予定をマージさせる機能 穆 start
          // // 矢印データの検索
          // for (let j = 0; j < this.arrowInfo.length; j++) {
          //   if (i === this.arrowInfo[j].index_to) {
          //     this.arrowInfo.splice(j, 1);
          //     // データ数を1減らす
          //     --this.arrowInfoLength;
          //     break;
          //   }
          // }
          // del FNSI-改修内容 元ある予定に、違う曜日の予定をマージさせる機能 穆 end
          // add FNSI-改修内容 元ある予定に、違う曜日の予定をマージさせる機能 穆 start
          // 矢印データの検索
          // 同じ変更先治療パターン曜日数
          let cont = 0;
          let index = 0;
          // 同じ変更先治療パターン曜日タグ(true:同じ, false:違う)
          let weekFlg = false;
          let formIndex = 0;
          for (let j = 0; j < this.arrowInfo.length; j++) {
            if (i === this.arrowInfo[j].index_to) {
              cont++;
              index = j;
              if (i === (this.arrowInfo[j].index_from - 1)) {
                weekFlg = true;
                formIndex = this.arrowInfo[j].index_from;
                break;
              }
            }
          }
          // 違う２つの曜日の場合
          //mod 内部redmine-5873 ljx start
          //既存では、多数の変更元は同じ変更先を選択できる。変更先は一つ変更元のみから選択できるように修正。
          //例：月→木が選択された場合、月以外の曜日から木に変更すると、月→木の変更は破棄し、他の曜日（一つのみ）→木に変更される。
          // #11716 曜日パターン変更の不正 関 start
          // if (cont > 0 && !weekFlg && i !== (this.arrowInfo[this.arrowInfo.length - 1].index_from - 1)) {
          //   this.arrowInfo.splice(index, 1);
          //   // データ数を1減らす
          //   --this.arrowInfoLength;
          // }
          // if (cont > 0) {
          //   this.arrowInfo.splice(index, 1);
          //   // データ数を1減らす
          //   --this.arrowInfoLength;
          // }
          // mod #11716 曜日パターン変更の不正 関 end
          //mod 内部redmine-5873 ljx end
          // add FNSI-改修内容 元ある予定に、違う曜日の予定をマージさせる機能 穆 end

          // 矢印データの登録
          this.arrowInfo[this.arrowInfoLength] = {
            index_from: this.moveWeekElement,
            index_to: i,
            st_x: st_x_add,
            st_y: st_y_add,
            ed_x: arX,
            ed_y: arY
          };
          // データ数を1増やす
          ++this.arrowInfoLength;
          // データの紐づけ
          // mod FNSI-改修内容 元ある予定に、違う曜日の予定をマージさせる機能 穆 start
          // mod #11716 曜日パターン変更の不正 関 start
          let sameTarget = false;
          for (let index = 0; index < this.toTreatPatternWeekInfo.length; index++) {
            if (this.toTreatPatternWeekInfo[index].value == i+1) {
              sameTarget = true;
              break;
            }
          }
          if (this.toTreatPatternWeekInfo[i].fromWeek != null && cont > 0 && sameTarget) {
            let moveWeek = this.toTreatPatternWeekInfo[i].fromWeek;
            moveWeek.push(this.moveWeekElement);
            this.toTreatPatternWeekInfo[i].fromWeek = moveWeek;
          } else {
            let moveWeek = [];
            moveWeek.push(this.moveWeekElement);
            this.toTreatPatternWeekInfo[i].fromWeek = moveWeek;
          }

          // if (cont > 0 && weekFlg) {
          //   this.toTreatPatternWeekInfo[i].fromWeek = formIndex;
          // } else {
          //   this.toTreatPatternWeekInfo[i].fromWeek = this.moveWeekElement;
          // }
          // mod #11716 曜日パターン変更の不正 関 end

          // mod FNSI-改修内容 元ある予定に、違う曜日の予定をマージさせる機能 穆 end

          // 現在の展開情報を表示中の場合
          if (this.showNewWeekPatternDetail) {
            // 新規曜日パターン詳細情報を子コンポーネントに送る
            this.sendNewDetailInfo();
          }

          // 蓄積してある矢印の描画
          this.drowArrowLines(this.arrowInfo, true, true);

          noDragFlag = false;
          // add 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao start
          this.updateDisable=false;
          // add 7397 デフォルト医師が未登録の状態で曜日パターン変更をすると指示者のリストが表示されない zhao end
          break;
        }
      }

      if (noDragFlag) {
        // ドロップ先が対象エリア外のため矢印クリア
        this.arrowInfo.pop();
        // 蓄積してある矢印の再描画
        this.drowArrowLines(this.arrowInfo, true, true);
      }

      if (drag) {
        // 動かしていた要素を削除
        drag.parentNode.removeChild(drag);
      }

      // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
      // 前後の日付を変更して取得します
      const newDetailInfo = this.toTreatPatternWeekInfo.filter(item => {
        return null !== item.fromWeek;
      });
      if (this.getPriorToChangeList && newDetailInfo) {
        //内部remine 5840  mod ljx start
        const afterToChangeList = this.buildAfterToChangeListFromArrows();
        //内部remine 5840  mod ljx end
        this.setAfterToChangeList(afterToChangeList);
        this.createMoveInfo(this.selectedDate,this.beforeAfterFlag);
      }
      // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    },

    /**
     * 矢印を描画
     */
    drowArrowLines(jsonDim, clearFlag, dropFlag) {
      if (clearFlag === true) {
        // キャンバスのクリア
        const canvas = this.scopedJQuery("#arrowCanvas")[0];
        const context = canvas.getContext("2d");
        context.clearRect(0, 0, canvas.width, canvas.height);
        // 移動中矢印のクリア
        const canvasDummy = this.scopedJQuery("#arrowCanvasDummy")[0];
        const contextDummy = canvasDummy.getContext("2d");
        contextDummy.clearRect(0, 0, canvasDummy.width, canvasDummy.height);
      }

      const canvas = this.queryScopedSelectorSafe('#arrowCanvas');
      const currentDetail = this.queryScopedSelectorSafe('#currentDetail');
      const labelWidth = currentDetail.offsetWidth; // 変更前ラベルの横幅
      const fix = this.getFontSize > 1 ? 1 : 0; // フォントサイズ大、特大は微調整

      for (let i = 0; i < jsonDim.length; i++) {
        // 現在の曜日パターンの要素番号を取得
        let fromIndex = 0;
        for (let j = 0; j < this.treatPatternWeekInfo.length; j++) {
          if (this.treatPatternWeekInfo[j].value === jsonDim[i].index_from) {
            fromIndex = j;
          }
 }

        let st_x = this.canvasStartArrow(fromIndex);
        let st_y = jsonDim[i].st_y;
        let ed_x = jsonDim[i].ed_x;
        let ed_y = jsonDim[i].ed_y - fix;

        // 描画位置を調整
        if (!dropFlag) {
          // drag中の場合はarrowCanvasDummyに矢印描画
          // arrowCanvasを基準に描画位置を取得しているのでarrowCanvasDummyとの位置の差分を調整する
          // x位置は変更前ラベルの横幅を加算して固定値（20px=左側padding値）で調整
          // y位置は#arrowCanvasのtop位置で調整
          st_x += labelWidth + 20;
          st_y = canvas.offsetTop - fix;
          ed_x += labelWidth + 20;
          ed_y += canvas.offsetTop - fix;
        }

        // 現在移動中の矢印を
        this.movingDrowArrow(7, 2, st_x, st_y, ed_x, ed_y, "yellowgreen", "2", dropFlag);
      }
    },

    /**
     * 移動中の矢印を描画
     */
    movingDrowArrow(h, w, start_x, start_y, end_x, end_y, color_cd, widthval, dropFlag) {
      start_x = parseInt(start_x);
      start_y = parseInt(start_y);
      end_x = parseInt(end_x);
      end_y = parseInt(end_y);

      const canvas = dropFlag ? this.scopedJQuery("#arrowCanvas")[0] : this.scopedJQuery("#arrowCanvasDummy")[0];
      const context = canvas.getContext("2d");

      //矢の棒の描画
      context.beginPath();
      context.moveTo(start_x, start_y); // 始点
      context.lineTo(end_x, end_y); // 終点
      context.strokeStyle = color_cd; // 色
      context.lineWidth = widthval; // 太さ
      context.stroke();

      //矢じりの描画計算

      const Vx = end_x - start_x;
      const Vy = end_y - start_y;
      const v = Math.sqrt(Vx * Vx + Vy * Vy);

      const Ux = Vx / v;
      const Uy = Vy / v;

      const lx = end_x - Uy * w - Ux * h;
      const ly = end_y + Ux * w - Uy * h;

      const rx = end_x + Uy * w - Ux * h;
      const ry = end_y - Ux * w - Uy * h;
      //矢じりの描画
      context.beginPath();
      context.moveTo(end_x, end_y); // 始点
      context.lineTo(lx, ly); // 終点
      context.strokeStyle = color_cd; // 色
      context.lineWidth = widthval; // 太さ
      context.stroke();

      context.beginPath();
      context.moveTo(end_x, end_y); // 始点
      context.lineTo(rx, ry); // 終点
      context.strokeStyle = color_cd; // 色
      context.lineWidth = widthval; // 太さ
      context.stroke();
    },

    /**
     * 矢印をリセット
     */
    clearArrows() {
      //矢印情報クリア
      this.arrowInfoLength = 0;
      this.arrowInfo = [];
      //キャンバスクリア
      this.drowArrowLines(this.arrowInfo, true);

      //紐付けデータのクリア
      for (let i = 0; i < this.toTreatPatternWeekInfo.length; i++) {
        this.toTreatPatternWeekInfo[i].fromWeek = null;
      }
    },

    /**
     * キャンバス矢印の描画開始位置の設定
     */
    canvasStartArrow(index) {
      let w = weekWidth;
      if (this.currentWeekNum > 0) {
        w = (w * 7) / this.currentWeekNum + (7 - this.currentWeekNum);
      }
      // 描画開始位置の設定
      const canvas = this.scopedJQuery("#arrowCanvas")[0];
      const startArrow =
        this.scopedJQuery(canvas).width() - (w + 1) * this.treatPatternWeekInfo.length;
      const width = w * 0.5 + (w + 1) * index;

      return startArrow + width;
    },

    /**
     * 曜日日本語表記
     */
    convertWeekName(weekCd) {
      switch (Number(weekCd)) {
        case 1:
          return "月";
        case 2:
          return "火";
        case 3:
          return "水";
        case 4:
          return "木";
        case 5:
          return "金";
        case 6:
          return "土";
        case 7:
          return "日";
        default:
          break;
      }
    },

    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 start
    // /**
    //  * 選択肢情報スタイルの設定
    //  */
    // setListStyle(selectedInfo, data) {
    //   if (selectedInfo.fromWeek === data.value && null !== data.value) {
    //     return { "background-color": "#0076ff" };
    //   } else {
    //     return { "background-color": "white" };
    //   }
    // },
    // del FNSI-改修内容 変更後の曜日をクリックで変更の解除を可能 穆 end

    /**
     * 詳細の表示
     */
    showCurrentDetail() {
      // マスタが取得できていない場合、以降の処理を行わない
      if (!this.isGetMstInfo) {
        return;
      }
      // 表示・非表示を切り替える
      this.showCurrentWeekPatternDetail = !this.showCurrentWeekPatternDetail;
    },

    /**
     * 新規曜日パターン詳細情報作成
     */
    createNewDetailInfo() {
      const newDetailInfo = this.toTreatPatternWeekInfo.filter(item => {
        return null !== item.fromWeek;
      });
      // 表示データの作成し直し
      const arr = new Array();
      newDetailInfo.forEach(item => {
        this.dispInfo.forEach(eleItem => {
          if (item.fromWeek === eleItem.treatWeek) {
            const obj = deepCopy(eleItem);
            obj.treatWeek = item.value;
            // クールを未登録に設定
            obj.indKurCd = 0;
            const indSchInfo = JSON.parse(obj.indSchInfo);
            // ベッドを未登録に設定
            indSchInfo.ind_bed_cd = "0";
            // 治療開始時刻を未登録に設定
            indSchInfo.ind_treat_start_time = null;
            // スケジュール情報を格納
            obj.indSchInfo = JSON.stringify(indSchInfo);
            // 投与薬剤を空で設定
            obj.indMediInfo = "[]";
            arr.push(obj);
          }
        });
      });
      // 新規曜日詳細用データの格納
      this.newDispInfo = arr;
    },

    /**
     * 新規詳細情報を作り直し
     * @description 子に新しく作成し直した詳細情報をおくる
     */
    sendNewDetailInfo() {
      this.createNewDetailInfo();
      // 詳細情報作り直し
      this.$refs.detailModal.createInfoDetailProc(this.newDispInfo);
    },

    /**
     * 新規の曜日情報の表示
     */
    showNewDetail() {
      // マスタが取得できていない場合、以降の処理を行わない
      if (!this.isGetMstInfo) {
        return;
      }
      const newDetailInfo = this.toTreatPatternWeekInfo.filter(item => {
        return null !== item.fromWeek;
      });
      if (0 === newDetailInfo.length) {
        this.messageDialogInfo.overflowY =false;
        this.messageDialogInfo.messageCd = 22010001;
        this.messageDialogInfo.type = "1";
        this.messageDialogInfo.stringParams = ["新規曜日パターン"];
        this.messageDialogInfo.isDialogVisible = true;
      } else {
        // 新規詳細情報の作成
        this.createNewDetailInfo();
        // 表示・非表示を切り替える
        this.showNewWeekPatternDetail = !this.showNewWeekPatternDetail;
      }
    },
    //内部remine 5840  add ljx start
    showBeforeTreatmentDetail(date){
      this.selectedDate = date;
      this.beforeAfterFlag = "before";
      let treatmentData = this.getTreatmentDataOfPeriodTmp;
      let newDispInfo = treatmentData[date];
      const arr = new Array();
      arr.push(newDispInfo);
      this.newDispInfo = arr;
      // mod 10443 身体情報・DW・目標体重バグ 関  start
      // this.$refs.detailModal.createInfoDetailProc(this.newDispInfo);
      this.$refs.detailModal.createInfoDetailProc(this.newDispInfo, this.selectedDate);
      // mod 10443 身体情報・DW・目標体重バグ 関  end
      this.createMoveInfo(date,this.beforeAfterFlag);
    },
    showAfterTreatmentDetail(date){
      this.selectedDate = date;
      this.beforeAfterFlag = "after";
      let toWeek = dayjs(date).day() === 0?7:dayjs(date).day();
      let fromWeek;
      let arrowInfo = this.arrowInfo;
      for (let i = this.arrowInfo.length - 1; i >= 0; i--) {
        if (this.arrowInfo[i].index_to === toWeek - 1) {
          fromWeek = this.arrowInfo[i].index_from;
        }
      }
      const arr = new Array();
      if(fromWeek){
        let treatmentData = this.getTreatmentDataOfPeriodTmp;
        for(const treatment in treatmentData){
          if(treatmentData[treatment]){
            fromWeek = fromWeek === 7?0:fromWeek;
            if(dayjs(treatment).day() ===fromWeek && treatmentData[treatment].indTreatmentCd === this.selectedTreatmentCd){
              arr.push(treatmentData[treatment]);
              break;
            }
          }
        }
      }
      this.newDispInfo = arr;
      // mod 10443 身体情報・DW・目標体重バグ 関  start
      // this.$refs.detailModal.createInfoDetailProc(this.newDispInfo);
      this.$refs.detailModal.createInfoDetailProc(this.newDispInfo, this.selectedDate);
      // mod 10443 身体情報・DW・目標体重バグ 関  end
      this.createMoveInfo(date,this.beforeAfterFlag);
    },
    clearTreatmentDetail(){
      this.$refs.detailModal.clearDetailInfo();
    },
    clearSelectedDate(){
      this.selectedDate = "";
      this.beforeAfterFlag = "";
    },
    createMoveInfo(date,flag){
      let moveDateInfo;
      let convDtFmt = function (strDt) {
        return `${strDt.slice(0, 4)}/${strDt.slice(4, 6)}/${strDt.slice(6, 8)}`;
      }

      const dateInfo = this.createDateInfo();
      if(date !== ""){
        let afterFlag = dateInfo.some(item => item.toDate === date);
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc start
        let missingDateInfo = dateInfo.filter(item => item.toDate === date);
        let toWeekNameDel = " 削除";
        if(!!missingDateInfo && !missingDateInfo[0]?.isMissingDate){
          // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc end
          if(flag === 'before'){
            let toWeekName = "";
            let fromWeekName = this.convertWeekName(dayjs(date).day() === 0?7:dayjs(date).day());
            if(this.arrowInfo.length > 0){
              for(let i = 0;i<dateInfo.length;i++){
                if(dateInfo[i].fromDate ===date){
                  toWeekName += convDtFmt(dateInfo[i].toDate) + " (" + this.convertWeekName(dateInfo[i].toWeekCd)+')、';
                  fromWeekName = this.convertWeekName(dateInfo[i].fromWeekCd);
                }
              }
            }else{
              toWeekNameDel = "";
            }
            if(toWeekName.indexOf('、') !=-1){
              toWeekName = toWeekName.substring(0, toWeekName.lastIndexOf('、'));
              moveDateInfo = convDtFmt(date)+" ("+fromWeekName+") → "+toWeekName;
            }else if(toWeekNameDel != ""){
              moveDateInfo = convDtFmt(date)+" ("+fromWeekName+") → "+toWeekNameDel;
            }else{
              moveDateInfo = convDtFmt(date)+" ("+fromWeekName+")";
            }
          }else{
            let toWeekName = "";
            let fromWeekName = "";
            let fromDate = "";
            for(let i = 0;i<dateInfo.length;i++){
              if(dateInfo[i].toDate ===date){
                toWeekName = this.convertWeekName(dateInfo[i].toWeekCd);
                fromWeekName = this.convertWeekName(dateInfo[i].fromWeekCd);
                fromDate = dateInfo[i].fromDate;
                break;
              }
            }
            moveDateInfo = convDtFmt(fromDate)+" ("+fromWeekName+")" +" → "+convDtFmt(date)+" ("+toWeekName+")";
            if(!afterFlag){
              moveDateInfo = "";
              this.clearTreatmentDetail();
            }
          }
          if(dayjs(date).isBefore(dayjs(this.indTreatStartDate))){
            moveDateInfo = convDtFmt(date);
          }
          // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc start
        }else{
          if (flag === 'before') {
            moveDateInfo = convDtFmt(date)+" ("+this.convertWeekName(dayjs(date).day() === 0?7:dayjs(date).day())+") → "+toWeekNameDel;
          } else {
            moveDateInfo = convDtFmt(date) + " (" + this.convertWeekName(dayjs(date).day() == 0 ? 7 : dayjs(date).day()) + ")";
          }
        }
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc end
        this.$refs.detailModal.showMoveInfo(moveDateInfo);
        this.clearClickClass();
        this.createClickClass(flag,date);
      }
    },
    clearMoveInfo(){
      this.$refs.detailModal.showMoveInfo("");
    },
    clearClickClass(){
      this.$refs.changeListModal.clearClickClass();
    },
    createClickClass(flag,date){
      const dateInfo = this.createDateInfo();
      let afterIndexArray = [];
      let beforeIndexArray = [];
      const dateCurrent = dayjs(new Date()).format("YYYYMMDD");
      if (date !== "") {
        if (flag === 'before') {
          for(let i = 0;i<dateInfo.length;i++){
            if(dateInfo[i].fromDate ===date){
              let beforeIndex = this.getPriorToChangeList.findIndex(item => {
                return item === date;
              });
              let afterIndex = this.getPriorToChangeList.findIndex(item => {
                return item === dateInfo[i].toDate;
              });
              beforeIndexArray.push(beforeIndex);
              afterIndexArray.push(afterIndex);
            }
          }
          if(beforeIndexArray.length === 0){
            let beforeIndex = this.getPriorToChangeList.findIndex(item => {
              return item === date;
            });
            beforeIndexArray.push(beforeIndex);
          }
        } else {
          for(let i = 0;i<dateInfo.length;i++){
            if(dateInfo[i].toDate ===date){
              let beforeIndex = this.getPriorToChangeList.findIndex(item => {
                return item === dateInfo[i].fromDate;
              });
              let afterIndex = this.getPriorToChangeList.findIndex(item => {
                return item === date;
              });
              beforeIndexArray.push(beforeIndex);
              afterIndexArray.push(afterIndex);
            }
          }
        }
        beforeIndexArray = Array.from(new Set(beforeIndexArray))
      }
      this.$refs.changeListModal.addClickClass("before",beforeIndexArray);
      this.$refs.changeListModal.addClickClass("after",afterIndexArray)
    },
    //9273 mod ljx start
    // createDateInfo(){
    //   let dateInfoArray = [];
    //   let beforeList = this.getTreatmentDataOfPeriodTmp;
    //   let afterList = this.getAfterToChangeList;
    //   for(const beforeDate in beforeList){
    //     if(beforeList[beforeDate]){
    //       let beforeWeekCd = dayjs(beforeDate).day() === 0 ? 7 : dayjs(beforeDate).day();
    //       for (let i = this.arrowInfo.length - 1; i >= 0; i--) {
    //         if (this.arrowInfo[i].index_from === beforeWeekCd) {
    //           let afterToDate;
    //           if (!dayjs(beforeDate).isBefore(dayjs(this.indTreatStartDate))) {
    //               const weekDay =(this.arrowInfo[i].index_to+1 -this.arrowInfo[i].index_from) < 0?8+this.arrowInfo[i].index_to -this.arrowInfo[i].index_from:(this.arrowInfo[i].index_to+1 -this.arrowInfo[i].index_from);
    //               if((this.arrowInfo[i].index_to+1-dayjs().day()) >= 0){
    //                 if((this.arrowInfo[i].index_to+1 -this.arrowInfo[i].index_from) < 0){
    //                   afterToDate = dayjs(beforeDate).subtract(this.arrowInfo[i].index_from-this.arrowInfo[i].index_to-1, 'days').format('YYYYMMDD')
    //                 }else{
    //                   afterToDate = dayjs(beforeDate).add(this.arrowInfo[i].index_to+1 -this.arrowInfo[i].index_from, 'days').format('YYYYMMDD')
    //                 }
    //               }else{
    //                 afterToDate = dayjs(beforeDate).add(weekDay, 'days').format('YYYYMMDD');
    //               }
    //             const toDate = afterList.find(item => {
    //               return  item === afterToDate;
    //             });
    //             if(toDate){
    //               let dateInfo = {};
    //               dateInfo.fromDate = beforeDate;
    //               dateInfo.toDate = toDate;
    //               dateInfo.fromWeekCd = beforeWeekCd;
    //               dateInfo.toWeekCd = this.arrowInfo[i].index_to+1;
    //               dateInfoArray.push(dateInfo);
    //             }
    //           }
    //         }
    //       }
    //     }
    //   }
    //   return dateInfoArray;
    // },
    /**
     * 変更前後の日付情報を作成する
     *＠return 変更前後の日付情報
     * 作成された日付情報が下記の形である
     * 0: {fromDate: '20231206', toDate: '20231202', fromWeekCd: 3, toWeekCd: 6}
       1: {fromDate: '20231213', toDate: '20231209', fromWeekCd: 3, toWeekCd: 6}
       2: {fromDate: '20231206', toDate: '20231204', fromWeekCd: 3, toWeekCd: 1}
     */
    createDateInfo(){
      let dateInfoArray = [];
      let fromDateArray = [];
      //変更前の日付
      let treatmentData = this.getTreatmentDataOfPeriodTmp;
      const treatmentDataArr = [];
      for(const moveDateBefore in treatmentData){
        //arrayの形に一旦作成
        // mod #11888【因島】曜日パターン変更の画面操作が重い fang start
        // treatmentDataArr.push(moveDateBefore);
        const isoStr = `${moveDateBefore.substring(0, 4)}-${moveDateBefore.substring(4, 6)}-${moveDateBefore.substring(6, 8)}`;
        const date = new Date(isoStr);
        treatmentDataArr.push({
          date: moveDateBefore,
          week: date.getDay()
        });
        // mod #11888【因島】曜日パターン変更の画面操作が重い fang end
      }
      //変更後の日付
      let afterList = this.getAfterToChangeList;
      // mod #9273(10277) 仕様変更:開始日より前の日付に○が付く事がある、以下の処理は開始日を比較する 張玲 start
      //システム日時
      // const dateCurrent = dayjs(new Date()).format("YYYYMMDD");
      let dateCurrent = dayjs(this.indTreatStartDate).format("YYYYMMDD");
      // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
      let compareEnd = ""
      if(this.indTreatEndDate) {
        compareEnd = dayjs(this.indTreatEndDate).format("YYYYMMDD")
      }
      // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
      // mod #9273(10277) 仕様変更:開始日より前の日付に○が付く事がある、以下の処理は開始日を比較する 張玲 end
      for (let i = this.arrowInfo.length - 1; i >= 0; i--) {
        //変更の方向（past：過去の日付、future：将来の日付）
        //仕様：仮に前に移動して、変更後の日付がシステム日時の前である場合、後ろに移動する、でないと、前に移動する。
        // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
        // let moveDirection = "past"
        //変更前後日付の間隔天数
        // const weekDay =(this.arrowInfo[i].index_to+1 -this.arrowInfo[i].index_from) < 0?8+this.arrowInfo[i].index_to -this.arrowInfo[i].index_from:(this.arrowInfo[i].index_to+1 -this.arrowInfo[i].index_from);
        const indexFrom = Number(this.arrowInfo[i].index_from);
        const weekDay = this.arrowInfo[i].index_to + 1 - indexFrom;
        const priorList = this.getPriorToChangeList || [];
        for (let j = 0; j < priorList.length; j++) {
          const moveDateBefore = priorList[j];
          if (!treatmentData[moveDateBefore]) {
            continue;
          }
          let beforeWeekCd =
            dayjs(moveDateBefore).day() === 0 ? 7 : dayjs(moveDateBefore).day();
          if (indexFrom === beforeWeekCd) {
              //選択された曜日に合う日付リストから、一番の日付で変更の方向を決める
              // if (moveDateBefore == fileterItemList[0]) {
              //   let afterToDateSubtract = dayjs(moveDateBefore).subtract(7 - weekDay, 'days').format('YYYYMMDD')
              //   if (dayjs(afterToDateSubtract).isBefore(dateCurrent)) {//変更後の日付がシステム日時の前である場合、後ろに移動する
              //     moveDirection = "future";
              //   }
              // }
              let afterToDate;
              if (!dayjs(moveDateBefore).isBefore(dayjs(this.indTreatStartDate))) {
                // if (moveDirection == "future") {//後ろに移動する場合、変更後の日付＝変更前の日付+間隔天数
                //   afterToDate = dayjs(moveDateBefore).add(weekDay, 'days').format('YYYYMMDD')
                // } else {//前に移動する場合、変更後の日付＝変更前の日付-（７－間隔天数）
                //   // #10266 曜日パターンの変更後,同じ曜日を指し、○は不正を表します。 linjunfeng start
                //   // afterToDate = dayjs(moveDateBefore).subtract(7 - weekDay, 'days').format('YYYYMMDD')
                //   afterToDate = weekDay === 0 ? moveDateBefore : dayjs(moveDateBefore).subtract(7 - weekDay, 'days').format('YYYYMMDD');
                //   // #10266 曜日パターンの変更後,同じ曜日を指し、○は不正を表します。 linjunfeng end
                // }
                afterToDate = dayjs(moveDateBefore).add(weekDay, 'days').format('YYYYMMDD');
                let addFlag = false;
                if(afterToDate >= dateCurrent) {
                  if(compareEnd) {
                    if(afterToDate <= compareEnd) {
                      addFlag = true;
                    }
                  } else {
                    addFlag = true;
                  }
                }
                if(addFlag) {
                  const toDate = afterList.find(item => {
                    return  item === afterToDate;
                  });
                  if(toDate){//変更前後日付の情報を作成する。
                    let dateInfo = {};
                    dateInfo.fromDate = moveDateBefore;
                    dateInfo.toDate = toDate;
                    dateInfo.fromWeekCd = beforeWeekCd;
                    dateInfo.toWeekCd = this.arrowInfo[i].index_to+1;
                    // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc start
                    dateInfo.isMissingDate = false;
                    // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc end
                    dateInfoArray.push(dateInfo);
                    fromDateArray.push(dateInfo.fromDate);
                  }
                }
              }
            }
            // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
        }
      }
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc start
      if(this.missingDateList){
        for(let m = 0; m < this.missingDateList.length; m++){
          let missDateInfo = {};
          missDateInfo.toDate = this.missingDateList[m];
          missDateInfo.toWeekCd = dayjs(this.missingDateList[m]).day() == 0 ? 7 : dayjs(this.missingDateList[m]).day();
          missDateInfo.isMissingDate = true;
          dateInfoArray.push(missDateInfo);
        }
      }
      // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240307 ztc end
      // mod #11888【因島】曜日パターン変更の画面操作が重い fang start
      // this.delDateList = _.difference(treatmentDataArr, fromDateArray);
      this.delDateList = _.difference(treatmentDataArr.map(el => el.date), fromDateArray);
      // mod #11888【因島】曜日パターン変更の画面操作が重い fang end
      this.delDateList = this.delDateList.filter(x => x >= this.indTreatStartDate.replace(/-/g, ""))
        .filter(y => this.indTreatEndDate != "" ? y <= this.indTreatEndDate.replace(/-/g, "") : true);
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      this.dateInfoArrayForSave = dateInfoArray;
      // add #11717【因島】曜日パターン変更の動作が遅い fang end
      return dateInfoArray;
    },
    //9273 mod ljx end
    //内部remine 5840  add ljx end

    /**
     * 新規の曜日の背景色を変更
     * @description
     *  新規の曜日パターンで引き継ぐ元が決まっている曜日は黄緑に変更する
     */
    newPatternWeek(isSelected) {
      const o = new Object();
      if (null !== isSelected) {
        ((o)["background-color"] = "yellowgreen");
      }
      return o;
    },

    /**
     * メッセージ返答処理
     */
    // del FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
    // confirmResult() {
    //   // 保存ボタンを活性にする
    //   if (!this.procDisable) {
    //     this.updateDisable = false;
    //   }
    // },
    // del FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
    // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
    confirmResult(answer) {
      switch (this.messageDialogInfo.messageCd) {
        case "00400015":
          if ("Yes" === answer) {
            // 反映処理を行う
            this.reflectIndInfo("1", "old");
          }
          if ("No" === answer) {
            // 反映処理を行う
            this.reflectIndInfo("2", "old");
          } else {
            // 保存ボタンを活性にする
            if (!this.procDisable) {
              this.updateDisable = false;
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
              this.setLoadingScreenVisible(false);
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
            }
          }
          break;
        default:
          // 保存ボタンを活性にする
          if (!this.procDisable) {
            this.updateDisable = false;
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
            this.setLoadingScreenVisible(false);
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
          }
          break;
      }
    },
    // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end

    /**
     * 保存処理
     */
    // add #11716 曜日パターン変更の不正 関 start
    async updateInfo2(updateCd) {
      this.startLoadingScreen();
      // 保存ボタンを非活性にする
      this.updateDisable = true;
      let weekFromToFlg = false;
      // 更新情報を取得
      const updateInfo = this.toTreatPatternWeekInfo.filter(item => {
        if (item.fromWeek !== null && item.fromWeek !== item.value) {
          weekFromToFlg = true;
        }
        return item.fromWeek !== null;
      });

      let cancelFlg = false;

      // 移動対象曜日リストを取得
      const weekPerTreatObj = this.weekPerTreatList.find(item => {
        return item.treatmentCd === this.selectedTreatmentCd;
      });
      let response = null;
      // 移動する予定で上書き
      if (updateCd === "1") {
        this.cover = true;
        this.skip = false;
      } else if (updateCd === "2") {
        this.cover = false;
        this.skip = false;
      } else {
        this.cover = true;
        this.skip = true;
        updateCd = null;
      }

      response = await this.updateWeekPatternInfo2(updateInfo, weekPerTreatObj, updateCd);

      const data = response?.data;
      this.msgCdList = data?.msgCdList;
      const hasMsgCdList = Array.isArray(this.msgCdList) && this.msgCdList.length > 0;

      if (hasMsgCdList && this.msgCdList.includes("00400017")) {

        const conflictMessage = data?.conflictMessage ?? "";

        const formattedMessage = `<div style="max-height: 60vh; overflow-y: auto;">
                ${messageFormat(
                  DIALOG_MESSAGES["00400017"].message,
                  conflictMessage)}
              </div>`;
          await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES["00400017"].title,
          message: formattedMessage,
          buttonLabels: ["OK"],
        });
        this.isRefresh = true;
        // モーダルを閉じる
        this.hideModal();
        this.finishLoadingScreen();
      }
      // 投与間隔月１のものが月を跨いだ、ご確認ください。
      if (hasMsgCdList && this.msgCdList.includes("13000044")) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES["13000044"].title,
          message: messageFormat(DIALOG_MESSAGES["13000044"].message),
          buttonLabels: ["Cancel", "OK"],
          callback: (answer) => {
            if (answer === 1) {
              this.isRefresh = true;
              // モーダルを閉じる
              this.hideModal();
              this.finishLoadingScreen();
            }else{
              this.updateDisable = false;
              cancelFlg = true;
            }}
        });
      }
      if (hasMsgCdList && this.msgCdList.includes("00200030")) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES["00200030"].title,
          message: messageFormat(DIALOG_MESSAGES["00200030"].message),
          buttonLabels: ["OK"],
          callback: (answer) => {
            if (answer === 1) {
              this.isRefresh = true;
              // モーダルを閉じる
              this.hideModal();
              this.finishLoadingScreen();
            }}
        });
      }
      if (isProcSuccess(data)) {
        this.isRefresh = true;
        this.hideModal();
        this.finishLoadingScreen();
        return;
      }else{
        this.msgCd = data?.msgCd;
        this.examDeadlineSelectedVal = "";
        this.examDeadlineCancelCheck = "";
        this.radDeadlineSelectedVal = "";
        this.radDeadlineCancelCheck = "";

        const hasMsgCd = !!this.msgCd;

        // 同日、同クール、同治療方法の予定が存在するため登録できません。
        if (hasMsgCd && this.msgCd.includes("00400016") && !cancelFlg) {
          await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES["00400016"].title,
          message: messageFormat(DIALOG_MESSAGES["00400016"].message),
          buttonLabels: ["OK"],
          });
          cancelFlg = true;
        }
        // ordmain pattern変更外競合
        if (hasMsgCdList && this.msgCdList.includes("00400015") && !cancelFlg) {

          const formattedMessage = `<div style="max-height: 60vh; overflow-y: auto;">
                  ${messageFormat(
                    DIALOG_MESSAGES["00400015"].message)}
                </div>`;
            await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES["00400015"].title,
            message: formattedMessage,
            buttonLabels: ["上書き優先", "既存優先", "キャンセル"],
            callback: (answer) => {
              if (answer === 0) {
                updateCd = "1";
              } else if (answer === 1) {
                updateCd = "2";
              } else {
                cancelFlg = true;
              }
            },
          });
        }
        if (hasMsgCd && (this.msgCdList == null || this.msgCdList.length == 0)&& !cancelFlg) {
          let message = data?.message;
          await this.$ons.notification.confirm({
          title: "",
          message: message,
          buttonLabels: ["OK"],
          });
        }
        // 一般検査の処理を選択してください
        if (hasMsgCdList && this.msgCdList.includes("70000030") && !cancelFlg) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[70000030].title,
            message: messageFormat(DIALOG_MESSAGES[70000030].message),
            buttonLabels: ["1", "2", "3"],
            callback: (answer) => {
              if (answer === 0) {
                this.facilitySettingExamValue = "1";
              } else if (answer === 1) {
                this.facilitySettingExamValue = "2";
              } else if (answer === 2) {
                this.facilitySettingExamValue = "3";
              }
            },
          });
        }
        // 一般検査の締切日が過ぎている予定移動があります
        if (hasMsgCdList && this.msgCdList.includes("70000033")
            && this.getFacilitySetting1007_4SelectedVal != 3
            && this.facilitySettingExamValue != "3"
            && !cancelFlg) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[70000033].title,
            message: messageFormat(DIALOG_MESSAGES[70000033].message),
            callback: (answer) => {
              if (answer === 1) {
                this.examDeadlineSelectedVal = "OK";
              } else {
                cancelFlg = true;
              }
            },
          });
        }
        // X線検査の処理を選択してください
        if (hasMsgCdList && this.msgCdList.includes("70000031") && !cancelFlg) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[70000031].title,
            message: messageFormat(DIALOG_MESSAGES[70000031].message),
            buttonLabels: ["1", "2", "3"],
            callback: (answer) => {
              if (answer === 0) {
                this.facilitySettingRadValue = "1";
              } else if (answer === 1) {
                this.facilitySettingRadValue = "2";
              } else if (answer === 2) {
                this.facilitySettingRadValue = "3";
              }
            },
          });
        }
        // 放射線検査の締切日が過ぎている予定移動があります
        if (hasMsgCdList && this.msgCdList.includes("70000034")
            && this.getFacilitySetting1008_4SelectedVal != 3
            && this.facilitySettingRadValue != "3"
            && !cancelFlg) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[70000033].title,
            message: messageFormat(DIALOG_MESSAGES[70000033].message),
            callback: (answer) => {
              if (answer === 1) {
                this.radDeadlineSelectedVal = "OK";
              } else {
                this.radDeadlineCancelCheck = "cancel";
                cancelFlg = true;
              }
            },
          });
        }
        // 患者イベントの処理を選択してください
        if (hasMsgCdList && this.msgCdList.includes("70000032") && !cancelFlg) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[70000032].title,
            message: messageFormat(DIALOG_MESSAGES[70000032].message),
            buttonLabels: ["1", "2", "3"],
            callback: (answer) => {
              if (answer === 0) {
                this.facilitySettingEventValue = "1";
              } else if (answer === 1) {
                this.facilitySettingEventValue = "2";
              } else if (answer === 2) {
                this.facilitySettingEventValue = "3";
              }
            },
          });
        }
        if ((this.msgCdList != null && this.msgCdList.length > 0) && !cancelFlg) {
          await this.updateInfo2(updateCd === "1" || updateCd === "2" ? updateCd : null);
        }
      }
      if (cancelFlg) {
        this.facilitySettingExamValue = null;
        this.facilitySettingRadValue = null;
        this.facilitySettingEventValue = null;
        this.updateDisable = false;
        this.setLoadingScreenVisible(false);
      } else {
        this.isRefresh = true;
        this.hideModal();
        this.finishLoadingScreen();
      }
    },
    // add #11716 曜日パターン変更の不正 関 end
    /**
     * 保存処理
     */
    async updateInfo() {
      console.log("ChangeDayOfWeekPattern.vue updateInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // del #11717【因島】曜日パターン変更の動作が遅い fang start
      // let targetOrdMain = await this.getTargetOrdMain();
      // this.backArrs = targetOrdMain.data.map(e => {
      //   return e.ordNo + "_" + e.treatDate;
      // });
      // del #11717【因島】曜日パターン変更の動作が遅い fang end
      // 保存ボタンを非活性にする
      this.updateDisable = true;
      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
      let weekFromToFlg = false;
      // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
      // 更新情報を取得
      // add #11716 曜日パターン変更の不正 関 start
      this.toTreatPatternWeekInfo.forEach(item => {
        let { fromWeek, value } = item;

        if (fromWeek !== null && Array.isArray(fromWeek)) {
          if (fromWeek.includes(value)) {
            const filtered = fromWeek.filter(v => v !== value);

            if (filtered.length > 0) {
              item.fromWeek = parseInt(filtered[0], 10);
            } else {
              item.fromWeek = null;
            }
          } else {
            item.fromWeek = parseInt(fromWeek[0], 10);
          }
        }
      });
      // add #11716 曜日パターン変更の不正 関 start
      const updateInfo = this.toTreatPatternWeekInfo.filter(item => {
        // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
        if (item.fromWeek !== null && item.fromWeek !== item.value) {
          weekFromToFlg = true;
        }
        // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
        return item.fromWeek !== null;
      });

      // 移動対象曜日リストを取得
      const weekPerTreatObj = this.weekPerTreatList.find(item => {
        return item.treatmentCd === this.selectedTreatmentCd;
      });
      this.cover=true;
      this.skip=true;
      const response = await this.updateWeekPatternInfo(updateInfo, weekPerTreatObj, null);
      // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
      if(response === null) {
        return;
      } else if (200 === response.status && undefined !== response.data.msgCd) {
        // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
        // メッセージ表示
        this.showMessage(response.data.msgCd, "曜日パターン変更");
        console.log("ChangeDayOfWeekPattern.vue updateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
        // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
      } else if(200 === response.status&&response.data.nobedlist&&response.data.nobedlist.length>0){
        // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
        const responseScheduleInfo = await ApiHelper.post(
        `/mainData/getProcessOrdSchedule/${this.facilityCd}/3`,
        response.data.nobedlist).catch(error => {
          getErrorMessage('IndSchEdit.vue', 'updateIndInfo', error);
          console.log("ChangeDayOfWeekPattern.vue updateInfo throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
        if (responseScheduleInfo.data.length > 0) {
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
          let infoList = ""
          responseScheduleInfo.data.forEach((item) => {
            infoList = infoList + item + "<br>"
          })
          this.messageDialogInfo.overflowY =true;
//add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
          this.messageDialogInfo.messageCd = "00400015";
          this.messageDialogInfo.type = "7";
          this.messageDialogInfo.isDialogVisible = true;
          this.messageDialogInfo.stringParams = [infoList];
          console.log("ChangeDayOfWeekPattern.vue updateInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
      } else if(200 === response.status&&response.data.nobedlist&&response.data.nobedlist.length==0){
        // mod #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
      } else {
        this.cover=true;
        this.skip=false;
        await this.updateWeekPatternInfo(updateInfo, weekPerTreatObj, null);
      }
      // del 10409 曜日パターン変更の患者イベント修正 関  start
      // 425 426 姜 start
      // let tempOrdMain = await this.getTargetOrdMain();
      // if(tempOrdMain != null){
      //   let tempArrs = tempOrdMain.data.map(e => {
      //     return e.ordNo + "_" + e.treatDate;
      //   });
      //   //this.idos = [];
      //   tempArrs.forEach(el=>{
      //     this.backArrs.forEach(e=>{
      //       let beforeArrs = e.split("_");
      //       let afterArrs = el.split("_");
      //       if (beforeArrs[0] === afterArrs[0] && beforeArrs[1] !== afterArrs[1]) {
      //         this.idos.push({
      //           before_ord_no: beforeArrs[0],
      //           before_treat_date: beforeArrs[1],
      //           // afterOrdNo: afterArrs[0],
      //           after_treat_date: afterArrs[1],
      //           pat_id: this.patId,
      //           facility_cd: this.facilityCd,
      //           facility_setting_exam_value: null,
      //           facility_setting_rad_value: null,
      //         });
      //       }
      //     });
      //   })
      // }
      // const sendJson = {};
      // for(let i = 0;i<this.idos.length;i++){
      //   const el = this.idos[i];
      //   sendJson.facilityCd = this.facilityCd;
      //   sendJson.patId = this.patId;
      //   sendJson.eventStartDate = el.before_treat_date;
      //   await ApiHelper.post(`/pat_event/mainData/selectDateByCd/${sendJson.facilityCd}/${sendJson.patId}/${sendJson.eventStartDate}`)
      //     .then(response => {
      //       if (response.data.length > 0) {
      //         this.patEventFlg = true;
      //         this.patEventCd = response.data;
      //         el.patEventCd = response.data;
      //         //this.patEventCds.push(response.data[0].patEventCd);
      //       }
      //     })
      //     .catch(err => {
      //       getErrorMessage('ChangeDayOfWeekPattern.vue', 'updateInfo', err);
      //       console.log("ChangeDayOfWeekPattern.vue updateInfo throw err; this.finishLoadingScreen();");
      //       this.finishLoadingScreen();
      //       throw err;
      //     });
      //   // 426 姜 end
      //   sendJson.patEventCd = this.patEventCd;
      //   const dataNumber =  (this.stringToDate(el.after_treat_date) - this.stringToDate(el.before_treat_date)) / (24*60*60*1000);
      //   sendJson.dataNumber = dataNumber;
      //   if (sendJson.patEventCd !== undefined && sendJson.patEventCd !== null){
      //     if (this.facilitySettingEventValue == "1") {
      //       this.idoEventNumber_1(sendJson);
      //     }
      //     if (this.facilitySettingEventValue == "2") {
      //       this.idoEventNumber_2(sendJson);
      //     }
      //   }
      //   if (this.patEventFlg) {
      //     if (this.facilitySettingEventValue == "4") {
      //       this.diaViewEven = true;
      //       console.log("ChangeDayOfWeekPattern.vue updateInfo this.finishLoadingScreen();");
      //       this.finishLoadingScreen();
      //       return;
      //     }
      //   }
      // }
      // del 10409 曜日パターン変更の患者イベント修正 関  end
      // 参照元画面更新フラグをON
      this.isRefresh = true;
      // モーダルを閉じる
      this.hideModal();
      // 425 426 姜 end
      console.log("ChangeDayOfWeekPattern.vue updateInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
     // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 end
   /**
     * 保存前処理
     */
    async beforeupdateInfo() {
     // 検査依頼
    getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
          .then(response => {
            this.facilitySettingExamValue = response.data;
          });
    // 一般撮影検査依頼
    getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
          .then(response => {
            this.facilitySettingRadValue = response.data;
          });
    // 検査依頼変更締切り有無
    getMstFacilitySettingValue(this.facilityCd, EXAM_DEADLINE)
          .then(response => {
            this.facilitySettingExamChangeOnOffWithOrder = response.data;
          });
    // 放射線検査依頼変更締切り有無
    getMstFacilitySettingValue(this.facilityCd, RAD_DEADLINE)
          .then(response => {
            this.facilitySettingRadChangeOnOffWithOrder = response.data;
          });
    // 放射線検査依頼変更締切り日数
    getMstFacilitySettingValue(this.facilityCd, RAD_DEADLINE_DATE_COUNT)
          .then(response => {
            this.facilitySettingRadScheduleChangeLimitDay = response.data;
          });
    // 放射線検査依頼変更締切り時間
    getMstFacilitySettingValue(this.facilityCd, RAD_DEADLINE_TIME_COUNT)
          .then(response => {
            this.facilitySettingRadScheduleChangeLimitTime = response.data;
          });
    // 検査依頼変更締切り日数
    getMstFacilitySettingValue(this.facilityCd, EXAM_DEADLINE_DATE_COUNT)
          .then(response => {
            this.facilitySettingExamScheduleChangeLimitDay = response.data;
          });
    // 検査依頼変更締切り時間
    getMstFacilitySettingValue(this.facilityCd, EXAM_DEADLINE_TIME_COUNT)
          .then(response => {
            this.facilitySettingExamScheduleChangeLimitTime = response.data;
          });
    // 患者イベント
    getMstFacilitySettingValue(this.facilityCd, FACILITY_NO_SETTING)
          .then(response => {
            this.facilitySettingEventValue = response.data;
          });
    // 245 姜  end
    //9273 start
    this.setExamDeadline(this.getFacilityCd);
    this.setRadDeadline(this.getFacilityCd);
    //9273 end
     console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo this.startLoadingScreen();");
     this.startLoadingScreen();
      const startDateValid = this.queryScopedSelectorSafe('input[data-target^="indTreatStartDate"]').validity;
      const endDateValid = this.queryScopedSelectorSafe('input[data-target^="indTreatEndDate"]').validity;
      let targetOrdMain = await this.getTargetOrdMain();
      // 開始日の不完全入力チェック
      if ("" === this.indTreatStartDate && startDateValid.badInput) {
        this.showMessage(22010008, "開始日");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 開始日のチェック
      if (null === this.indTreatStartDate || "" === this.indTreatStartDate) {
        this.showMessage(22010001, "開始日");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 終了日の不完全入力チェック
      if ("" === this.indTreatEndDate && endDateValid.badInput) {
        this.showMessage(22010008, "終了日");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 指示者入力チェック
      if (!this.selectedIndUser) {
        this.showMessage(22010001, "指示者");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 更新情報を取得
      const updateInfo = this.toTreatPatternWeekInfo.filter(item => {
        return item.fromWeek !== null;
      });

     // 曜日パターンが選択されているかのチェック処理
     if (0 === updateInfo.length) {
       this.showMessage(22010001, "新規曜日パターン");
       console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
       this.finishLoadingScreen();
       return;
      }
     //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
     let setmap = new Map();
     let keys = new Set();
     updateInfo.forEach(item => {
       let key = item.fromWeek;
       if (!setmap.has(key)) {
         let valueTmp = [];
         valueTmp.push(item.value);
         setmap.set(key, valueTmp);
         keys.add(key);
       } else {
         setmap.get(key).push(item.value);
       }
     })
     if (this.treatPatternWeekInfo.length !== updateInfo.length) {
       this.showMessageFlag = true;
     }
     keys.forEach(item => {
       let lisrTmp = setmap.get(item);
       if (!lisrTmp.includes(item)) {
         this.moveWeek.push(item);
         this.showMessageFlag = true;
       }
     })
     //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
     //9273 add ljx start
     //ここから検査依頼などのチェック
     const paramJson = {};
     paramJson.facility_cd = this.facilityCd;
     paramJson.pat_id = this.patId;
     paramJson.start_date = this.indTreatStartDate;
     paramJson.end_date = this.indTreatEndDate;
     paramJson.ind_kur_cd = JSON.stringify([]);
     paramJson.weeks = JSON.stringify(
       [{'text': '全', 'done': true, 'value': 0}]);
     paramJson.ind_treatment_cd = JSON.stringify(Array.of(this.selectedTreatmentCd));
     const treatDateResponse = await ApiHelper.post(
       "/mainData/treatDateList",
       paramJson).catch(error => {
       getErrorMessage('IndEditBase.vue', 'getTreatDateList', error);
       console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo throw error; this.finishLoadingScreen();");
       this.finishLoadingScreen();
       throw error;
     });
     //すべての治療日を取得
     const ordMainDateList = treatDateResponse.data.map(({treatDate}) => treatDate);
     var firstTreatDate = this.indTreatStartDate.replaceAll("-", "");
     var lastTreatDate = ordMainDateList[ordMainDateList.length - 1];
     //この間で検査依頼を取得
     const examDateResponse = await ApiHelper.post(
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
        // `/exam/TreatDateList/${this.patId}/${firstTreatDate}/${lastTreatDate}`
        `/exam/TreatDateListByIsOrder/${this.patId}/${firstTreatDate}/${lastTreatDate}`
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
        ).catch(err => {
       console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo throw err; this.finishLoadingScreen();");
       this.finishLoadingScreen();
       throw err;
     });
     //この間で一般撮影検査依頼を取得
     const radDataResponse = await ApiHelper.post(
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
        // `/rad/TreatDateList/${this.patId}/${firstTreatDate}/${lastTreatDate}`
        `/rad/TreatDateListByIsOrder/${this.patId}/${firstTreatDate}/${lastTreatDate}`
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
        ).catch(err => {
       console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo throw err; this.finishLoadingScreen();");
       this.finishLoadingScreen();
       throw err;
     });

     // add 10409 曜日パターン変更の患者イベント修正 関  start
     this.linkageFlag = await sendRequestGetLinkageMessageConfirm(
        {
          facility: this.facilityCd,
          pat: this.patId,
          to: lastTreatDate,
          from: firstTreatDate
        },).catch(error => {
            getErrorMessage('ChangeDayOfWeekPattern.vue', 'beforeupdateInfo', error);
            return false;
          });
      // add 10409 曜日パターン変更の患者イベント修正 関  end
      const examBaseData = examDateResponse.data;
      const radBaseData = radDataResponse.data;
      let examOrdMainDate = [];
      let examOrdMainDateHasResult = [];
      let radOrdMainDate = [];
      let radOrdMainDateHasResult = [];

     // 日付リスト分ループ
     // 対象日付の検査結果を抽出し、表示用リストに格納
     ordMainDateList.forEach(element => {
       // pat_exam_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
       examBaseData.forEach(item => {
         // 一致する治療日のデータを抽出
         const date = new Date(item.regExamDate);
          //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
          // const dateStr = dayjs(date, "YYYYMMDD").format("YYYYMMDD");
          const dateStr = dayjs(date, "YYYYMMDD").local().format("YYYYMMDD");
          //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
         if (dateStr === element) {
           if (item.examStatus == "0") {
             examOrdMainDate.push(dateStr);
           }
        //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
            // if (item.examStatus == "1") {
            //   examOrdMainDateHasResult.push(dateStr);
            // }
        //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
         }
       });
       // pat_rad_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
       radBaseData.forEach(item => {
         // 一致する治療日のデータを抽出
         const date = new Date(item.regRadDate);
          //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
          // const dateStr = dayjs(date, "YYYYMMDD").format("YYYYMMDD");
          const dateStr = dayjs(date, "YYYYMMDD").local().format("YYYYMMDD");
          //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
         if (dateStr === element) {
           if (item.radStatus == "0") {
             radOrdMainDate.push(dateStr);
           }
        //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
            // if (item.radStatus == "1") {
            //   radOrdMainDateHasResult.push(dateStr);
            // }
        //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
         }
       });
      });
     //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
      // examOrdMainDate = _.difference(examOrdMainDate, examOrdMainDateHasResult);
      // radOrdMainDate = _.difference(radOrdMainDate, radOrdMainDateHasResult);
     //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

     // mod #11717【因島】曜日パターン変更の動作が遅い fang start
     // let targetDateList = this.createDateInfo();
     let targetDateList = this.dateInfoArrayForSave;
     // mod #11717【因島】曜日パターン変更の動作が遅い fang end
     let delDate = [];
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
      let delDateTmp = [];
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
     this.delDateList.forEach(x => {
       let dateInfo = {};
       dateInfo.fromDate = x;
       dateInfo.toDate = x;
       delDate.push(dateInfo);
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
        delDateTmp.push(dateInfo.fromDate);
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
     })
     targetDateList = [...targetDateList, ...delDate];
     let examDeadlineOverFlg = false;
     const examDeadlineDate = this.getDeadlineCondition.deadlineFlg ? dayjs(getDeadlineDate(this.getDeadlineCondition)) : null;
     let radDeadlineOverFlg = false;
     // mod 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 start
     const radDeadlineDate = this.getRadDeadlineCondition.deadlineFlg ? dayjs(getDeadlineDate(this.getRadDeadlineCondition)) : null;
     // mod 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 end
     for (let targetDateInfo of targetDateList) {
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240311 ztc start
        if(targetDateInfo?.isMissingDate){
          continue
        }
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240311 ztc end
       let fromDate = targetDateInfo.fromDate;
       let toDate = targetDateInfo.toDate;
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
        if (examOrdMainDate.includes(fromDate)&&!targetDateInfo.fromWeekCd && delDateTmp.includes(fromDate)) {
         this.patExamFlg = true;
       }
        if (examOrdMainDate.includes(fromDate)&&this.moveWeek.includes(targetDateInfo.fromWeekCd)) {
          this.patExamFlg = true;
        }
        if (radOrdMainDate.includes(fromDate)&&!targetDateInfo.fromWeekCd && delDateTmp.includes(fromDate)) {
         this.patRadFlg = true;
       }
        if (radOrdMainDate.includes(fromDate)&&this.moveWeek.includes(targetDateInfo.fromWeekCd)) {
          this.patRadFlg = true;
          this.radStatus = true;
        }
       //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
       const targetExamFromDate = dayjs(new Date(fromDate.slice(0, 4) + '/' + fromDate.slice(4, 6) + '/' + fromDate.slice(6, 8)));
       const targetExamToDate = dayjs(new Date(toDate.slice(0, 4) + '/' + toDate.slice(4, 6) + '/' + toDate.slice(6, 8)));
       if (examDeadlineDate && this.patExamFlg
         && (examDeadlineDate.isAfter(targetExamFromDate) || examDeadlineDate.isAfter(targetExamToDate))) {
         examDeadlineOverFlg = true;
          //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
          // break;
          //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
       }
       if (radDeadlineDate && this.patRadFlg
         && (radDeadlineDate.isAfter(targetExamFromDate) || radDeadlineDate.isAfter(targetExamToDate))) {
         radDeadlineOverFlg = true;
          //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
          // break;
          //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
       }
     }
     // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  start
     //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
        // if(this.showMessageFlag) {
        //   if (this.facilitySettingExamValue == 4 && this.patExamFlg) {
        //     this.diaViewExam = true;
        //     console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        //     this.finishLoadingScreen();
        //     return;
        //   }
        //   if (this.facilitySettingRadValue == 4 && this.patRadFlg) {
        //     this.diaViewRad = true;
        //     console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        //     this.finishLoadingScreen();
        //     return;
        //   }
        // }else {
        //   await this.updateInfo();
        // }
        if (targetOrdMain != null) {
          const hasTreatTypeOrd = this.getTreatType(targetOrdMain.data)
          if (hasTreatTypeOrd.size > 1) {
            this.$ons.notification.alert({
           // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
           // title: "警告",
           // message: "指定期間が複数の透析パターンの予定が含まれています。曜日変更はできません!",
           title: DIALOG_MESSAGES['00200030'].title,
           message: messageFormat(DIALOG_MESSAGES['00200030'].message),
           // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
           });
          }
        }

        if (this.facilitySettingExamValue == 4 && this.patExamFlg) {
          this.msgCdList.push("70000030");
        }
        if (this.facilitySettingRadValue == 4 && this.patRadFlg) {
          this.msgCdList.push("70000031");
        }
        if (this.facilitySettingEventValue == 4 && this.linkageFlag.data) {
          this.msgCdList.push("70000032");
        }
        if ((examDeadlineOverFlg && (this.facilitySettingExamValue == "1" || this.facilitySettingExamValue == "2"))
        || examDeadlineOverFlg && this.msgCdList.includes("70000030")) {
          this.msgCdList.push("70000033");
        }
        // mod 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 start
        if (radDeadlineOverFlg && this.facilitySettingRadValue != "3") {
          // mod 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 end
          this.msgCdList.push("70000034");
        }
        // add 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 start
        this.examDeadlineSelectedVal = "";
        this.examDeadlineCancelCheck = "";
        this.radDeadlineSelectedVal = "";
        this.radDeadlineCancelCheck = "";
        // add 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 end
        if (this.msgCdList != null && this.msgCdList.includes("70000030")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000030].title,
              message: messageFormat(DIALOG_MESSAGES[70000030].message),
              buttonLabels: ["1", "2", "3"],
              callback: (answer) => {
                if (answer === 0) {
                  this.facilitySettingExamValue = "1";
                } else if (answer === 1) {
                  this.facilitySettingExamValue = "2";
                } else if (answer === 2) {
                  this.facilitySettingExamValue = "3";
                }
              },
            });
          }
          if (this.msgCdList != null &&
            this.msgCdList.includes("70000033") &&
            this.getFacilitySetting1007_4SelectedVal != 3 &&
            // add 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 start
            this.facilitySettingExamValue != "3"
            // add 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 end
            ) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000033].title,
              message: messageFormat(DIALOG_MESSAGES[70000033].message),
              callback: (answer) => {
                if (answer === 1) {
                  this.examDeadlineSelectedVal = "OK";
                } else {
                  this.examDeadlineCancelCheck = "cancel";
                }
              },
            });
          }
          if (this.msgCdList != null &&
            this.msgCdList.includes("70000031") &&
            !this.examDeadlineCancelCheck.includes("cancel")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000031].title,
              message: messageFormat(DIALOG_MESSAGES[70000031].message),
              buttonLabels: ["1", "2", "3"],
              callback: (answer) => {
                if (answer === 0) {
                  this.facilitySettingRadValue = "1";
                } else if (answer === 1) {
                  this.facilitySettingRadValue = "2";
                } else if (answer === 2) {
                  this.facilitySettingRadValue = "3";
                }
              },
            });
          }
          if (this.msgCdList != null &&
            this.msgCdList.includes("70000034") &&
            !this.examDeadlineCancelCheck.includes("cancel") &&
            this.getFacilitySetting1008_4SelectedVal != 3 &&
            // add 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 start
            this.facilitySettingRadValue != "3"
            // add 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 end
            ) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000033].title,
              message: messageFormat(DIALOG_MESSAGES[70000033].message),
              callback: (answer) => {
                if (answer === 1) {
                  this.radDeadlineSelectedVal = "OK";
                } else {
                  this.radDeadlineCancelCheck = "cancel";
                }
              },
            });
          }
          if (this.msgCdList != null &&
            this.msgCdList.includes("70000032") &&
            !this.examDeadlineCancelCheck.includes("cancel") &&
            !this.radDeadlineCancelCheck.includes("cancel")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000032].title,
              message: messageFormat(DIALOG_MESSAGES[70000032].message),
              buttonLabels: ["1", "2", "3"],
              callback: (answer) => {
                if (answer === 0) {
                 this.facilitySettingEventValue = "1";
                } else if (answer === 1) {
                  this.facilitySettingEventValue = "2";
                } else if (answer === 2) {
                  this.facilitySettingEventValue = "3";
                }
              },
            });
          }
          // mod 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 start
          if (!(this.examDeadlineCancelCheck.includes("cancel") || this.radDeadlineCancelCheck.includes("cancel"))) {
            await this.updateInfo();
          }
          // mod 11244 一般撮影検査依頼＋治療予定連動が正常動作しない 関 end
    //     if ((examDeadlineOverFlg && (this.facilitySettingExamValue == "1" || this.facilitySettingExamValue == "2"))) {
    //        this.$ons.notification.confirm({
    //          title: DIALOG_MESSAGES[70000033].title,
    //          message: messageFormat(DIALOG_MESSAGES[70000033].message),
    //          callback: answer => {
    //            if (answer === 1) {
    //              if (this.facilitySettingRadValue == 4 && this.patRadFlg) {
    //                this.diaViewRad = true;
    //                console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
    //                this.finishLoadingScreen();
    //                return;
    //              }
    //  //9273 add ljx end
    //  // データ取得条件の格納
    //  if (targetOrdMain != null) {
    //    const hasTreatTypeOrd = this.getTreatType(targetOrdMain.data)
    //    if (hasTreatTypeOrd.size > 1) {
    //      this.$ons.notification.alert({
    //        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
    //        // title: "警告",
    //        // message: "指定期間が複数の透析パターンの予定が含まれています。曜日変更はできません!",
    //        title: DIALOG_MESSAGES['00200030'].title,
    //        message: messageFormat(DIALOG_MESSAGES['00200030'].message),
    //        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
    //      });
    //    } else {
    //      //9273 mod ljx start
    //      //await this.updateInfo();
    //                  if ((examDeadlineOverFlg && (this.facilitySettingExamValue == "1" || this.facilitySettingExamValue == "2"))) {
    //                    this.$ons.notification.confirm({
    //                      title: DIALOG_MESSAGES[70000033].title,
    //                      message: messageFormat(DIALOG_MESSAGES[70000033].message),
    //                      callback: answer => {
    //                        if (answer === 1) {
    //                          this.updateInfo();
    //                        } else {
    //                          getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
    //                            .then(response => {
    //                              this.facilitySettingExamValue = response.data;
    //                            });
    //                          // 一般撮影検査依頼
    //                          getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
    //                            .then(response => {
    //                              this.facilitySettingRadValue = response.data;
    //                            });
    //                        }
    //                      }
    //                    });
    //                  } else {
    //                     this.updateInfo();
    //                  }
    //                  //9273 mod ljx end
    //                }
    //              } else {
    //                if ((examDeadlineOverFlg && (this.facilitySettingExamValue == "1" || this.facilitySettingExamValue == "2"))) {
    //                  this.$ons.notification.confirm({
    //                    title: DIALOG_MESSAGES[70000033].title,
    //                    message: messageFormat(DIALOG_MESSAGES[70000033].message),
    //                    callback: answer => {
    //                      if (answer === 1) {
    //                        this.updateInfo();
    //                      } else {
    //                        getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
    //                          .then(response => {
    //                            this.facilitySettingExamValue = response.data;
    //                          });
    //                        // 一般撮影検査依頼
    //                        getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
    //                          .then(response => {
    //                            this.facilitySettingRadValue = response.data;
    //                          });
    //                      }
    //                    }
    //                  });
    //                } else {
    //                   this.updateInfo();
    //                }
    //              }
    //            } else {
    //              getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
    //                .then(response => {
    //                  this.facilitySettingExamValue = response.data;
    //                });
    //              // 一般撮影検査依頼
    //              getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
    //                .then(response => {
    //                  this.facilitySettingRadValue = response.data;
    //                });
    //            }
    //          }
    //        });
    //      } else {
    //        if (this.facilitySettingRadValue == 4 && this.patRadFlg) {
    //          this.diaViewRad = true;
    //          console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
    //          this.finishLoadingScreen();
    //          return;
    //        }
    //        //9273 add ljx end
    //        // データ取得条件の格納
    //        if (targetOrdMain != null) {
    //          const hasTreatTypeOrd = this.getTreatType(targetOrdMain.data)
    //          if (hasTreatTypeOrd.size > 1) {
    //            this.$ons.notification.alert({
    //              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
    //              // title: "警告",
    //              // message: "指定期間が複数の透析パターンの予定が含まれています。曜日変更はできません!",
    //              title: DIALOG_MESSAGES['00200030'].title,
    //              message: messageFormat(DIALOG_MESSAGES['00200030'].message),
    //              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
    //            });
    //          } else {
    //            //9273 mod ljx start
    //            //await this.updateInfo();
    //            if ((radDeadlineOverFlg && (this.facilitySettingRadValue == "1" || this.facilitySettingRadValue == "2"))) {
    //        this.$ons.notification.confirm({
    //          title: DIALOG_MESSAGES[70000033].title,
    //          message: messageFormat(DIALOG_MESSAGES[70000033].message),
    //          callback: answer => {
    //            if (answer === 1) {
    //              this.updateInfo();
    //            } else {
    //                    getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
    //                      .then(response => {
    //                        this.facilitySettingExamValue = response.data;
    //                      });
    //                    // 一般撮影検査依頼
    //                    getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
    //                      .then(response => {
    //                        this.facilitySettingRadValue = response.data;
    //                      });
    //            }
    //          }
    //        });
    //      } else {
    //        await this.updateInfo();
    //      }
    //    //9273 add ljx end
    //    }
    //  } else {
    //          if ((radDeadlineOverFlg && (this.facilitySettingRadValue == "1" || this.facilitySettingRadValue == "2"))) {
    //            this.$ons.notification.confirm({
    //              title: DIALOG_MESSAGES[70000033].title,
    //              message: messageFormat(DIALOG_MESSAGES[70000033].message),
    //              callback: answer => {
    //                if (answer === 1) {
    //                  this.updateInfo();
    //                } else {
    //                  getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
    //                    .then(response => {
    //                      this.facilitySettingExamValue = response.data;
    //                    });
    //                  // 一般撮影検査依頼
    //                  getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
    //                    .then(response => {
    //                      this.facilitySettingRadValue = response.data;
    //                    });
    //                }
    //              }
    //            });
    //          } else {
    //            await this.updateInfo();
    //          }
    //        }
    //      }
      // this.finishLoadingScreen(false);
     //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
     // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
     console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo this.finishLoadingScreen();");
     this.finishLoadingScreen();
    },
    // add #11716 曜日パターン変更の不正 関 start
    async beforeupdateInfo2() {
     console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo this.startLoadingScreen();");
     this.startLoadingScreen();
      const startDateValid = this.queryScopedSelectorSafe('input[data-target^="indTreatStartDate"]').validity;
      const endDateValid = this.queryScopedSelectorSafe('input[data-target^="indTreatEndDate"]').validity;
      // 開始日の不完全入力チェック
      if ("" === this.indTreatStartDate && startDateValid.badInput) {
        this.showMessage(22010008, "開始日");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 開始日のチェック
      if (null === this.indTreatStartDate || "" === this.indTreatStartDate) {
        this.showMessage(22010001, "開始日");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 終了日の不完全入力チェック
      if ("" === this.indTreatEndDate && endDateValid.badInput) {
        this.showMessage(22010008, "終了日");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 指示者入力チェック
      if (!this.selectedIndUser) {
        this.showMessage(22010001, "指示者");
        console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 更新情報を取得
      const updateInfo = this.toTreatPatternWeekInfo.filter(item => {
        return item.fromWeek !== null;
      });

     // 曜日パターンが選択されているかのチェック処理
     if (0 === updateInfo.length) {
       this.showMessage(22010001, "新規曜日パターン");
       console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo return; this.finishLoadingScreen();");
       this.finishLoadingScreen();
       return;
      }
      this.updateInfo2(null);
     console.log("ChangeDayOfWeekPattern.vue beforeupdateInfo this.finishLoadingScreen();");
     this.finishLoadingScreen();
    },
    // add #11716 曜日パターン変更の不正 関 end
     //9273 start
    updatePatEvent(facilitySettingEventValue){
      this.facilitySettingEventValue = facilitySettingEventValue;
      // mod 10409 曜日パターン変更の患者イベント修正 関  start
      // for(let i = 0;i<this.idos.length;i++){
      //   const el = this.idos[i];
      //   if(el.patEventCd){
      //     const sendJson = {};
      //     const dataNumber =  (this.stringToDate(el.after_treat_date) - this.stringToDate(el.before_treat_date)) / (24*60*60*1000);
      //     sendJson.patEventCd = el.patEventCd;
      //     sendJson.dataNumber = dataNumber;
      //     if (this.facilitySettingEventValue == "1") {
      //       this.idoEventNumber_1(sendJson);
      //     }
      //     if (this.facilitySettingEventValue == "2") {
      //       this.idoEventNumber_2(sendJson);
      //     }
      //   }
      // }
      this.updateInfo();
      // mod 10409 曜日パターン変更の患者イベント修正 関  end
    },
    //9273 end
    /**
     * @description 治療種別が1日以外の指示取得
     */
    getTreatType(ordMainList) {
      if (ordMainList==null) {
        return [];
      }
      const ordMain = new Set(ordMainList.filter(
        ord => ord.treatType === 1 || ord.treatType === 2 || ord.treatType === 3).map(item=>item.treatType));
      return ordMain;
    },
    // add 5785 追加で隔日，隔週のスケジュールが作成出来ない 張 end
    /**
     * 対象患者のすべての治療情報を取得
     * @description
     * 更新対象、警告対象リスト作成
     */
    async getTargetOrdMain() {
      this.startLoadingScreen();
      // データ取得条件の格納
      const paramJson = {};
      // 施設コード
      paramJson.facility_cd = this.facilityCd;
      // 患者ID
      paramJson.pat_id = this.patId;
      // 抽出開始日
      paramJson.ind_start_date = this.indTreatStartDate;
      // 抽出終了日
      paramJson.ind_end_date = this.indTreatEndDate;
      // 曜日パターン
      paramJson.week_pattern = "[{'text': '全','done': true,'value': 0}]";
      // add #11716 曜日パターン変更の不正 関 start
      // 治療方法コード
      paramJson.ind_treatment_cd = this.selectedTreatmentCd;
      // add #11716 曜日パターン変更の不正 関 end

      // データの取得
      const response = await ApiHelper.post(
        "/mainData/changeDay/TreatDateList",
        paramJson).catch(err => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'getTargetOrdMain', err);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw err;
      }).finally(() => {
        this.finishLoadingScreen();
      });

      // 取得したデータが1件もなければ処理終了
      if (0 === response.data.length) {
        return null;
      }
      return response;
    },

    async reflectIndInfo(updateCd, flag) {
      //add 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx start
      this.startLoadingScreen();
      //add 10807 曜日パターン変更で、他のスケジュールとスケジュール枠がかぶった場合の処理でエラーが発生する。 zrx end
      // 更新情報を取得
      const updateInfo = this.toTreatPatternWeekInfo.filter(item => {
        return item.fromWeek !== null;
      });
      // 移動対象曜日リストを取得
      const weekPerTreatObj = this.weekPerTreatList.find(item => {
        return item.treatmentCd === this.selectedTreatmentCd;
      });
      // 移動する予定で上書き
      if (updateCd === '1') {
          this.cover=true;
          this.skip=false;
       let response = null;
       if (flag == "old") {
        response = await this.updateWeekPatternInfo(updateInfo, weekPerTreatObj, updateCd);
       } else if (flag == "new") {
        response = await this.updateWeekPatternInfo2(updateInfo, weekPerTreatObj, updateCd);
       }
        // 既存の予定を残す
      } else {
          this.cover=false;
          this.skip=false;
            let response = null;
          if (flag == "old") {
            response = await this.updateWeekPatternInfo(updateInfo, weekPerTreatObj, updateCd);
          } else if (flag == "new") {
            response = await this.updateWeekPatternInfo2(updateInfo, weekPerTreatObj, updateCd);
          }
      }

      this.setLoadingScreenVisible(false);
      this.finishLoadingScreen();
      // 参照元画面更新フラグをON
      this.isRefresh = true;
      // モーダルを閉じる
      this.hideModal();
    },
    /**
     * 更新API呼び出し
     */
    // add #11716 曜日パターン変更の不正 関 start
    async updateWeekPatternInfo2(updateInfo, weekPerTreatObj, updateCd) {

      const params = new Object();
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      let updList = [];
      let copyList = [];
      let delList = [];
      this.treatPatternWeekInfo.forEach(el => {
        let moveList = this.toTreatPatternWeekInfo.filter(toEl => Array.isArray(toEl.fromWeek)
        && toEl.fromWeek.includes(el.value));
        if(moveList.length > 0) {
          for(let m = 0; m < moveList.length; m++) {
            let moveObj = {
              patId: this.patId,
              indTreatmentCd: this.selectedTreatmentCd,
              oldTreatWeek: el.value,
              newTreatWeek: moveList[m].value
            }
            if(m == 0) {
              // update
              updList.push(moveObj)
            } else {
              // copy
              copyList.push(moveObj)
            }
          }
        } else {
          // delete
          delList.push({
            patId: this.patId,
            indTreatmentCd: this.selectedTreatmentCd,
            treatWeek: el.value
          })
        }
      });
      ((params)["updateList"] = updList);
      ((params)["copyList"] = copyList);
      ((params)["delList"] = delList);
      // 施設コード
      ((params)["facility_cd"] = this.facilityCd);
      // 患者ID
      ((params)["pat_id"] = this.patId);
      // 治療方法コード
      ((params)["ind_treatment_cd"] = this.selectedTreatmentCd);
      // 指示者ID
      ((params)["ind_user"] = this.selectedIndUser);
      // 更新者ID
      ((params)["upd_user"] = this.getStateUserAccountInfo.userId);
      // 適用開始日
      ((params)["ind_treat_start_date"] = this.indTreatStartDate);
      // 曜日パターン情報
      ((params)["week_pattern_info"] = JSON.stringify(updateInfo));
      // 移動対象曜日リスト
      ((params)["move_target_week_list"] = JSON.stringify(weekPerTreatObj.week));
      // 更新日時
      ((params)["up_date"] = dayjs().format("YYYY-MM-DD HH:mm:ss.SSS"));
      // 終了日
      ((params)["end_date"] = this.indTreatEndDate===""? dayjs(this.maxDate).format("YYYY-MM-DD"):this.indTreatEndDate);
      ((params)["max_date"] = dayjs(this.maxDate).format("YYYY-MM-DD"));
      // 更新フラグ
      ((params)["update_flg"] = false);
      ((params)["cover"] = this.cover);
      ((params)["skip"] = this.skip);
      // footer
      ((params)["footer_flg"] = updateCd);
      ((params)["hosp_pat_id"] = this.selectedPat.pat_personal_main.hosp_pat_id);
      ((params)["facilitySettingExamValue"] = this.facilitySettingExamValue);
      ((params)["facilitySettingRadValue"] = this.facilitySettingRadValue);
      ((params)["facilitySettingEventValue"] = this.facilitySettingEventValue);
      ((params)["examDeadlineSelectedVal"] = this.examDeadlineSelectedVal);
      ((params)["radDeadlineSelectedVal"] = this.radDeadlineSelectedVal);
      ((params)["is_deadline"] = this.indTreatEndDate===""? false:true);
      this.startLoadingScreen();

      const response = await ApiHelper.post("/mainData/updateWeekPatternInfo2", params)
        .catch((error) => {
          getErrorMessage(
            "TreatPlanMove.vue",
            "updateDBInfo",
            error);
          throw(error);
        });
      this.finishLoadingScreen();
      return response;
    },
    // add #11716 曜日パターン変更の不正 関 end
    async updateWeekPatternInfo(updateInfo, weekPerTreatObj, updateCd) {

      const params = new Object();
      // add #11717【因島】曜日パターン変更の動作が遅い fang start
      let updList = [];
      let copyList = [];
      let delList = [];
      this.treatPatternWeekInfo.forEach(el => {
        let moveList = this.toTreatPatternWeekInfo.filter(toEl => toEl.fromWeek === el.value);
        if(moveList.length > 0) {
          for(let m = 0; m < moveList.length; m++) {
            let moveObj = {
              patId: this.patId,
              indTreatmentCd: this.selectedTreatmentCd,
              oldTreatWeek: el.value,
              newTreatWeek: moveList[m].value
            }
            if(m == 0) {
              // update
              updList.push(moveObj)
            } else {
              // copy
              copyList.push(moveObj)
            }
          }
        } else {
          // delete
          delList.push({
            patId: this.patId,
            indTreatmentCd: this.selectedTreatmentCd,
            treatWeek: el.value
          })
        }
      });
      ((params)["updateList"] = updList);
      ((params)["copyList"] = copyList);
      ((params)["delList"] = delList);
      // add #11717【因島】曜日パターン変更の動作が遅い fang end
      // 施設コード
      ((params)["facility_cd"] = this.facilityCd);
      // 患者ID
      ((params)["pat_id"] = this.patId);
      // 治療方法コード
      ((params)["ind_treatment_cd"] = this.selectedTreatmentCd);
      // 指示者ID
      ((params)["ind_user"] = this.selectedIndUser);
      // 更新者ID
      ((params)["upd_user"] = this.getStateUserAccountInfo.userId);
      // 適用開始日
      ((params)["ind_treat_start_date"] = this.indTreatStartDate);
      // 曜日パターン情報
      ((params)["week_pattern_info"] = JSON.stringify(updateInfo));
      // 移動対象曜日リスト
      ((params)["move_target_week_list"] = JSON.stringify(weekPerTreatObj.week));
      // 更新日時
      ((params)["up_date"] = dayjs().format("YYYY-MM-DD HH:mm:ss.SSS"));
      // 終了日
      //add 7240 曜日パターン変更の変更前に表示される曜日が正しく表示されない 張 start
      // this._compatSet(params, "end_date", this.indTreatEndDate);
      ((params)["end_date"] = this.indTreatEndDate===""? dayjs(this.maxDate).format("YYYY-MM-DD"):this.indTreatEndDate);
      //add 7240 曜日パターン変更の変更前に表示される曜日が正しく表示されない 張 end
      // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
      ((params)["max_date"] = dayjs(this.maxDate).format("YYYY-MM-DD"));
      // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
      // 更新フラグ
      ((params)["update_flg"] = false);
      //add 7307 曜日変更bug 張 start
      ((params)["cover"] = this.cover);
      //add 7307 曜日変更bug 張 end
      //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
      ((params)["skip"] = this.skip);
       //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
      // footer
      ((params)["footer_flg"] = updateCd);
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない start
      ((params)["hosp_pat_id"] = this.selectedPat.pat_personal_main.hosp_pat_id);
      //add 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない end
      //9273 start
      ((params)["facilitySettingExamValue"] = this.facilitySettingExamValue);
      ((params)["facilitySettingRadValue"] = this.facilitySettingRadValue);
      ((params)["facilitySettingEventValue"] = this.facilitySettingEventValue);
      //9273 end
      // add 10284 by kangjie 20240301 start 終了日存在フラグ
      ((params)["is_deadline"] = this.indTreatEndDate===""? false:true);
      // add 10284 by kangjie 20240301 end
      this.startLoadingScreen();

      // 更新API呼び出し
      const response = await ApiHelper.post(
        "/mainData/updateWeekPatternInfo",
        params).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'updateWeekPatternInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      //FNSI-修正 #5525 横展開対応、xugj add start
      const paramJsonOrd = {};
      // 施設情報
      paramJsonOrd.facility_cd = this.facilityCd;
      // 患者情報
      paramJsonOrd.pat_id = this.patId;
      // 治療開始日時
      paramJsonOrd.start_date = this.indTreatStartDate;
      // 治療終了日時
      paramJsonOrd.end_date = this.indTreatEndDate;
      // 治療方法
      paramJsonOrd.ind_treatment_cd = "[" + this.selectedTreatmentCd + "]";
      // クール
      paramJsonOrd.ind_kur_cd = "[]";
      // 曜日パターン
      let weeks = [];
      for (let week of this.treatPatternWeekInfo) {
        week.done = true;
        weeks.push(week);
      }
      paramJsonOrd.weeks = JSON.stringify(weeks);

      // データの取得
      const responseOrdMain = await ApiHelper.post(
        `/mainData/getOrdMainDataInfo`,
        paramJsonOrd).catch(error => {
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'updateIndInfo', error);
        throw error;
      });

      //del #10553 start
      const ordMainList = responseOrdMain.data;
      // ordMainList.forEach(async ordMain => {
      //   // 実績：治療状況は「条件送信後」以外の場合、次患者情報も更新する。
      //   if(ordMain.rstDialysisState !== "0") {
      //     const tempOrdNo = ordMain.ordNo;
      //     // 装置マスタの取得
      //     this.getMstMachineByOrdNoRst(tempOrdNo).then(machineRes => {
      //       let mstMachine = machineRes.data;
      //       if (mstMachine.length > 0){
      //         try {
      //           const params = {
      //             ordNo: tempOrdNo, //オーダー番号
      //             machineNo: mstMachine[0].machineNo, //装置マスタ.装置番号
      //             deviceEdgeNo: mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
      //             facilityCd: this.facilityCd //施設コード
      //           };
      //           this.sendNextPatInfoViewer(params);
      //         } catch (e) {
      //           getErrorMessage('ChangeDayOfWeekPattern.vue','updateIndInfo','送信失敗しました。');
      //           this.$ons.notification.alert({
      //             modifier: "warn",
      //             // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      //             // title: "送信失敗",
      //             // message: `送信失敗しました。\n${e}`
      //             title: DIALOG_MESSAGES['00200034'].title,
      //             message: messageFormat(DIALOG_MESSAGES['00200034'].message, e),
      //             // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      //           });
      //         }
      //       }
      //     });
      //   }
      // });
      //FNSI-修正 #5525 横展開対応、xugj add end
      //del #10553 end

      // 投与間隔月１のものが月を跨いだ場合
      if (messageInfo === response.data) {
        // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
       this.finishLoadingScreen();
        // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
        // メッセージ表示
        this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000044].title,
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          message: messageInfo,
          callback: async ok => {
            // ok押下の場合、更新処理を呼び出す
            if (ok === 1) {
              // 更新フラグ
              ((params)["update_flg"] = true);
              // 更新API呼び出し
              const updateResponse = await ApiHelper.post(
                "/mainData/updateWeekPatternInfo",
                params).catch(error => {
                //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
                getErrorMessage('ChangeDayOfWeekPattern.vue', 'updateWeekPatternInfo', error);
                //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
                throw error;
              });

              if (200 === updateResponse.status
                && undefined !== updateResponse.data.msgCd) {
                // メッセージ表示
                this.showMessage(response.data.msgCd, "曜日パターン変更");
                this.finishLoadingScreen();
                return;
              }

              // 参照元画面更新フラグをON
              this.isRefresh = true;
              // モーダルを閉じる
              this.hideModal();
              // add FNSI-障害票一覧_患者経過総合ビューア_治療予定(曜日パターン変更)No.3 李 end
              // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
              this.finishLoadingScreen();
              // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
            } else {
              // 保存ボタン非活性解除
              this.updateDisable = false;
              // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
              this.finishLoadingScreen();
              // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
            }
          }
        });
        // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang start
        return null;
        // add #11966 【因島】実績を含む週の曜日パターン変更が不正 fang end
      // add FNSI-障害票一覧_患者経過総合ビューア_治療予定(曜日パターン変更)No.3 李 start
      }
      //del #10553 start
      // add #8548 修正 ljx start
     // if(200 === response.status && undefined !==response.data.jouralList &&response.data.jouralList.length>0){
     //    //全ての処理が終わると、必要であれば。電文作成。電文リストをバックグラウンドから返す。
     //    //連携処理を行う。
     //      let journalParams = [];
     //      //電文作成用のパラメータを必要の方で作成。
     //      response.data.jouralList.forEach( journal => {
     //        const param = {
     //          ope_cd: journal.opeCd,
     //          crud: journal.crud,
     //          facility_cd: journal.facilityCd,
     //          hosp_pat_id: journal.hospPatId,
     //          pat_id: journal.patId,
     //          ord_no: journal.ordNo,
     //          base_date: journal.baseDate,
     //          user_id: journal.userId
     //        };
     //        journalParams.push(param)
     //      });
     //      //電文リスト作成のAPIを呼び出し。
     //      createJournalList(journalParams);
     //  }
      // add #8548 修正 ljx end
      //del #10553 end
      // add FNSI-障害票一覧_患者経過総合ビューア_治療予定(曜日パターン変更)No.3 李 end
      this.finishLoadingScreen();
      return response;
    },
    // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
    /**
     * モーダルを閉じる
     */
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    // hideModal() {
    hideModal(type) {
      if (this.isChanged && type === 'hide-modal') {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              //内部remine 5840  add ljx start
              this.clearAfterFormat(null);
              //内部remine 5840  add ljx end
              this.$emit("hide-modal");
            }
          }
        });
      }else {
        //内部remine 5840  add ljx start
        this.clearAfterFormat(null);
        //内部remine 5840  add ljx end
        this.$emit("hide-modal");
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    },

    async idoEventNumber_1(sendJson){
      console.log("ChangeDayOfWeekPattern.vue idoEventNumber_1 this.startLoadingScreen();");
      this.startLoadingScreen();
      //9273 mod ljx start
      // await ApiHelper.post(`/pat_event/mainData/updateDateByCd/${sendJson.patEventCd}/${sendJson.dataNumber}`
      //       ).catch(error => {
      //         //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
      //         getErrorMessage('ChangeDayOfWeekPattern.vue', 'idoEventNumber_1', error);
      //         //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
      //         throw error;
      //       });
      let patEventCdList = [];
      sendJson.patEventCd.forEach(item => {
        patEventCdList.push(item.patEventCd);
      });
      await ApiHelper.post(`/pat_event/mainData/updateDateByCd/${patEventCdList}/${sendJson.dataNumber}`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ChangeDayOfWeekPattern.vue', 'idoEventNumber_1', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        console.log("ChangeDayOfWeekPattern.vue idoEventNumber_1 throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      // this.setLoadingScreenVisible(false);
      this.isRefresh = true;
      console.log("IndTreatMethod.vue idoEventNumber_1 this.hideModal(); this.finishLoadingScreen();");
      this.finishLoadingScreen();
      this.hideModal();
      //9273 mod ljx end
    },
    async idoEventNumber_3(sendJson){
      await ApiHelper.post(`/pat_event/mainData/deletePaEventRec/${sendJson.patEventCd}`).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
              getErrorMessage('ChangeDayOfWeekPattern.vue', 'idoEventNumber_3', error);
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
              throw error;
            });
    },
    //9273 add ljx start
    async idoEventNumber_2(sendJson){
      console.log("ChangeDayOfWeekPattern.vue idoEventNumber_2 this.startLoadingScreen();");
      this.startLoadingScreen();
      sendJson.patEventCd.forEach(item => {
        ApiHelper.post(`/pat_event/mainData/deletePaEventRec/${item.patEventCd}`).catch(error => {
          getErrorMessage('ChangeDayOfWeekPattern.vue', 'idoEventNumber_2', error);
          console.log("ChangeDayOfWeekPattern.vue idoEventNumber_2 throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
      });
      // this.setLoadingScreenVisible(false);
      this.isRefresh = true;
      console.log("ChangeDayOfWeekPattern.vue idoEventNumber_2 throw error; this.finishLoadingScreen();");
      this.finishLoadingScreen();
      this.hideModal();
    },
    //9273 add ljx end
    //del FNSI-7230 劉全航 start
    // async updateInfoExam() {
    //   if (!this.radFLG) {
    //     this.updateInfoRad();
    //     return;
    //   } else {
    //     this.diaViewRad = true;
    //     return;
    //   }
    // },
    //del FNSI-7230 劉全航 end
    //9273 add ljx start
    async updateInfoExam() {
      if (this.facilitySettingRadValue == "1" || this.facilitySettingRadValue == "2" || this.facilitySettingRadValue == "3") {
        //this.updateInfoRad();
        this.updateInfo();
        return;
      }
      //9273 mod ljx start
      if (this.facilitySettingRadValue == "4") {
        //9273 mod ljx end
        //mod FNSI-redmine bug #3979 劉xl start

        if(this.patRadFlg&& this.radStatus){
          this.diaViewRad = true;
          return;
        }else{
          // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
          // this.updateInfoAfter();
          this.updateInfo();
          return;
          // add #9273 施設設定マスタのNo105の設定どおり動かない。  end
        }
      }
    },
    //9273 add ljx end
    numberEvent1() {
      this.diaViewEven = false;
      this.updatePatEvent("1");
    },

    numberEvent2() {
      this.diaViewEven = false;
      this.updatePatEvent("2");
    },

    numberEvent3() {
      this.diaViewEven = false;
      this.updatePatEvent("3");
    },
    //9273 add ljx end
    numberExam1() {
      this.diaViewExam = false;
      this.updateInfoAfterExam("1");
    },
    numberExam2() {
      this.diaViewExam = false;
      this.updateInfoAfterExam("2");
    },
    numberExam3() {
      this.diaViewExam = false;
      this.updateInfoAfterExam("3");
    },
    numberRad1() {
      this.diaViewRad = false;
      this.updateInfoAfterRad("1");
    },
    numberRad2() {
      this.diaViewRad = false;
      this.updateInfoAfterRad("2");
    },
    numberRad3() {
      this.diaViewRad = false;
      this.updateInfoAfterRad("3");
    },
    async updateInfoAfterExam (facilitySettingExamValue) {
      //9273 mod ljx start
      // this.allExam = facilitySettingExamValue;
      // //mod FNSI-7230 劉全航 start
      // // if (!this.radFLG) {
      // //   this.updateInfoExam();
      // // } else {
      // //   this.diaViewRad = true;
      // // }
      // if (this.radFLG && this.patRadFlg) {
      //   this.diaViewRad = true;
      // } else {
      //   this.updateInfoRad();
      // }
      //  //mod FNSI-7230 劉全航 end
      this.facilitySettingExamValue = facilitySettingExamValue;
      // mod #11717【因島】曜日パターン変更の動作が遅い fang start
      // let targetDateList = this.createDateInfo();
      let targetDateList = this.dateInfoArrayForSave;
      // mod #11717【因島】曜日パターン変更の動作が遅い fang end
      let delDate = [];
      this.delDateList.forEach(x => {
        let dateInfo = {};
        dateInfo.fromDate = x;
        dateInfo.toDate = x;
        delDate.push(dateInfo);
      })
      targetDateList = [...targetDateList, ...delDate];
      let examDeadlineOverFlg = false;
      const examDeadlineDate = this.getDeadlineCondition.deadlineFlg ? dayjs(getDeadlineDate(this.getDeadlineCondition)) : null;
      let radDeadlineOverFlg = false;
      const radDeadlineDate = this.getRadDeadlineCondition.deadlineFlg ? dayjs(getDeadlineDate(this.getDeadlineCondition)) : null;
      for (let targetDateInfo of targetDateList) {
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240311 ztc start
        if(targetDateInfo?.isMissingDate){
          continue
        }
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240311 ztc end
        let fromDate = targetDateInfo.fromDate;
        let toDate = targetDateInfo.toDate;
        const targetExamFromDate = dayjs(new Date(fromDate.slice(0,4) + '/' + fromDate.slice(4,6) + '/' + fromDate.slice(6,8)));
        const targetExamToDate = dayjs(new Date(toDate.slice(0,4) + '/' + toDate.slice(4,6) + '/' + toDate.slice(6,8)));
        if (examDeadlineDate&&examDeadlineDate.isAfter(targetExamFromDate) || examDeadlineDate&&examDeadlineDate.isAfter(targetExamToDate)) {
          examDeadlineOverFlg = true;
        }
        if (radDeadlineDate&&radDeadlineDate.isAfter(targetExamFromDate) || radDeadlineDate&&radDeadlineDate.isAfter(targetExamToDate)) {
          radDeadlineOverFlg = true;
        }
      }
      if (
        (examDeadlineOverFlg&&(this.facilitySettingExamValue == "1"||this.facilitySettingExamValue == "2"))||
        (radDeadlineOverFlg&&(this.facilitySettingRadValue == "1"||this.facilitySettingRadValue == "2"))) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[70000033].title,
          message: messageFormat(DIALOG_MESSAGES[70000033].message),
          callback: answer => {
            if (answer === 1) {
              this.updateInfoExam();
            }else{
              this.setLoadingScreenVisible(false);
              //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
              getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
                .then(response => {
                  this.facilitySettingExamValue = response.data;
                });
              // 一般撮影検査依頼
              getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
                .then(response => {
                  this.facilitySettingRadValue = response.data;
                });
              // this.facilitySettingExamValue = "4";
              //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
            }
          }
        });
      }else{
        await this.updateInfoExam();
      }
      //9273 mod ljx end
    },
    async updateInfoAfterRad (facilitySettingRadValue) {
      //mod 9273 ljx start
      // this.allRad = facilitySettingRadValue;
      // this.updateInfoRad();
      this.facilitySettingRadValue = facilitySettingRadValue;
      // mod #11717【因島】曜日パターン変更の動作が遅い fang start
      // let targetDateList = this.createDateInfo();
      let targetDateList = this.dateInfoArrayForSave;
      // mod #11717【因島】曜日パターン変更の動作が遅い fang end
      let delDate = [];
      this.delDateList.forEach(x => {
        let dateInfo = {};
        dateInfo.fromDate = x;
        dateInfo.toDate = x;
        delDate.push(dateInfo);
      })
      targetDateList = [...targetDateList, ...delDate];
      let examDeadlineOverFlg = false;
      const examDeadlineDate = this.getDeadlineCondition.deadlineFlg ? dayjs(getDeadlineDate(this.getDeadlineCondition)) : null;
      let radDeadlineOverFlg = false;
      const radDeadlineDate = this.getRadDeadlineCondition.deadlineFlg ? dayjs(getDeadlineDate(this.getDeadlineCondition)) : null;
      for (let targetDateInfo of targetDateList) {
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240311 ztc start
        if(targetDateInfo?.isMissingDate){
          continue
        }
        // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240311 ztc end
        let fromDate = targetDateInfo.fromDate;
        let toDate = targetDateInfo.toDate;
        const targetExamFromDate = dayjs(new Date(fromDate.slice(0,4) + '/' + fromDate.slice(4,6) + '/' + fromDate.slice(6,8)));
        const targetExamToDate = dayjs(new Date(toDate.slice(0,4) + '/' + toDate.slice(4,6) + '/' + toDate.slice(6,8)));
        if (examDeadlineDate&&examDeadlineDate.isAfter(targetExamFromDate) || examDeadlineDate&&examDeadlineDate.isAfter(targetExamToDate)) {
          examDeadlineOverFlg = true;
        }
        if (radDeadlineDate&&radDeadlineDate.isAfter(targetExamFromDate) || radDeadlineDate&&radDeadlineDate.isAfter(targetExamToDate)) {
          radDeadlineOverFlg = true;
        }
      }
      if (
        (examDeadlineOverFlg&&(this.facilitySettingExamValue == "1"||this.facilitySettingExamValue == "2"))||
        (radDeadlineOverFlg&&(this.facilitySettingRadValue == "1"||this.facilitySettingRadValue == "2"))) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[70000033].title,
          message: messageFormat(DIALOG_MESSAGES[70000033].message),
          callback: answer => {
            if (answer === 1) {
              this.updateInfo();
            }else{
              this.setLoadingScreenVisible(false);
              //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
              getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
                .then(response => {
                  this.facilitySettingExamValue = response.data;
                });
              // 一般撮影検査依頼
              getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
                .then(response => {
                  this.facilitySettingRadValue = response.data;
                });
              // this.facilitySettingRadValue = "4";
              //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
            }
          }
        });
      }else{
        await this.updateInfo();
      }
      //mod 9273 ljx end
    },
    async updateInfoRad() {
      this.idos.forEach(el => {
        el.facility_setting_exam_value = this.facilitySettingExamValue;
        el.facility_setting_rad_value = this.facilitySettingRadValue;
      })
      const sendJson = {};
      this.idos.forEach(async el => {

        if (this.patEventFlg) {
          sendJson.facilityCd = this.facilityCd;
          sendJson.patId = this.patId;
          sendJson.eventStartDate = el.beforeTreatDate;
          await ApiHelper.post(`/pat_event/mainData/selectDateByCd/${sendJson.facilityCd}/${sendJson.patId}/${sendJson.eventStartDate}`)
              //成功した場合の処理
              .then(response => {
                //ストアへデータをセット
                if (response.data.length > 0) {
                  this.patEventFlg = true;
                  //9273 start
                  this.patEventCd = response.data;
                  //9273 end
                }
              })
              .catch(err => {
                //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
                getErrorMessage('ChangeDayOfWeekPattern.vue', 'updateInfoRad', err);
                //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
                err;
              });
          // 426 姜 end
          sendJson.patEventCd = this.patEventCd;
          //9273 start
          const dataNumber =  (this.stringToDate(el.after_treat_date) - this.stringToDate(el.before_treat_date)) / (24*60*60*1000);
          sendJson.dataNumber = dataNumber;
          //9273 end
          if (sendJson.patEventCd !== undefined && sendJson.patEventCd !== null){
            if (this.facilitySettingEventValue == "1") {
              this.idoEventNumber_1(sendJson);
            }
            //9273 start
            // if (this.facilitySettingEventValue == "3") {
            //   this.idoEventNumber_3(sendJson);
            // }
            if (this.facilitySettingEventValue == "2") {
              this.idoEventNumber_2(sendJson);
            }
            // 9273 end
          }
        }
        if (this.allExam) {
          if (el.facility_setting_exam_value == 4) {
            el.facility_setting_exam_value = this.allExam;
          }
        }
        if (this.allRad) {
          if (el.facility_setting_rad_value == 4) {
            el.facility_setting_rad_value = this.allRad;
          }
        }
      })

      await ApiHelper.post(`/mainData/updateRadExam`, this.idos).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
              getErrorMessage('ChangeDayOfWeekPattern.vue', 'updateInfoRad', error);
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
              throw error;
            });
      // 参照元画面更新フラグをON
      this.isRefresh = true;
      // モーダルを閉じる
      this.hideModal();
      // 425 426 姜 end
    },
    async diaLogFlg (startDelDate) {
      const newDate = new Date();
      const hour = newDate.getHours();
      const minutes = newDate.getMinutes();
      const formatTime = String(hour) + String(minutes);
      if (this.facilitySettingRadChangeOnOffWithOrder == 1) {
        if  (Number(dayjs(startDelDate).format("YYYYMMDD")) > Number(dayjs().add(this.facilitySettingRadScheduleChangeLimitDay, 'days').format("YYYYMMDD")))  {
          this.facilitySettingRadFlg = true;
        } else if (Number(dayjs(startDelDate).format("YYYYMMDD")) == Number(dayjs().add(this.facilitySettingRadScheduleChangeLimitDay, 'days').format("YYYYMMDD"))) {
          if (Number(formatTime) < Number(String(this.facilitySettingRadScheduleChangeLimitTime).replace(":", ""))) {
            this.facilitySettingRadFlg = true;
          }
        }
      }else{
        this.facilitySettingRadFlg = true;
      }
      if (this.facilitySettingExamChangeOnOffWithOrder == 1) {
        if  (Number(dayjs(startDelDate).format("YYYYMMDD")) > Number(dayjs().add(this.facilitySettingExamScheduleChangeLimitDay, 'days').format("YYYYMMDD")))  {
          this.facilitySettingExamFlg = true;
        } else if (Number(dayjs(startDelDate).format("YYYYMMDD")) == Number(dayjs().add(this.facilitySettingExamScheduleChangeLimitDay, 'days').format("YYYYMMDD"))) {
          if (Number(formatTime) < Number(String(this.facilitySettingExamScheduleChangeLimitTime).replace(":", ""))) {
            this.facilitySettingExamFlg = true;
          }
        }
      }else{
        this.facilitySettingExamFlg = true;
      }
    },
    messageInfo(messageCd) {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].message;
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;

      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.trim().split("\n");
      return replacedMessage;
    },
    // add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy start
    messageTitle(messageCd){
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].title;
      if (message === undefined) {
        return "";
      }
      return message;
    },
    // add #10408 施設設定マスタNo7,8,105を4に設定した際のメッセージのタイトルと内容の不正 zy end
    //9273 start
    stringToDate(str){
      // var strDatepart = str.split("-");
      // var dtDate = new Date(strDatepart[0],strDatepart[1],strDatepart[2]);
      // return dtDate;
      var dtDate = new Date(str.slice(0,4) + '/' + str.slice(4,6) + '/' + str.slice(6,8));
      return dtDate;
    },
    dateFormat(str){
      let formatDate =str.slice(0,4) + '-' + str.slice(4,6) + '-' + str.slice(6,8);
      return formatDate;
    },
    //9273 end
    // 425、426 姜 end
    showMessage(cd, strParam) {
      // メッセージの表示
      this.messageDialogInfo.overflowY =false;
      this.messageDialogInfo.messageCd = parseInt(cd);
      this.messageDialogInfo.type = "1";
      this.messageDialogInfo.stringParams = [strParam];
      this.messageDialogInfo.isDialogVisible = true;
    },
    // 矢印描画用のcanvasの縦、横サイズをdiv-parentに合わせる
    setCanvasSize() {
      const parent = this.queryScopedSelectorSafe('#div-parent');
      const canvas = this.queryScopedSelectorSafe('#arrowCanvasDummy');
      if (parent && canvas) {
        canvas.width = parent.offsetWidth;
        canvas.height = parent.offsetHeight;
      }
    }
  },
  // add FNSI-性能を最適化する 李 start
  unmounted() {
    const element = this.scopedJQuery(".week-box");
    for (let i = 0; i < element.length; i++) {
      element[i].removeEventListener("mousedown", this.mouseDown, false);
      element[i].removeEventListener("touchstart", this.mouseDown, false);
    }
    const drag = this.scopedJQuery(".drag")[0];
    if (drag) {
      drag.removeEventListener("mouseup", this.mouseUp, false);
      drag.removeEventListener("touchend", this.mouseUp, false);
      this.getScopedOwnerBody().removeEventListener("mouseleave", this.mouseUp, false);
      this.getScopedOwnerBody().removeEventListener("touchend", this.mouseUp, false);
    }

    this.getScopedOwnerWindow()?.removeEventListener("resize", this.setCanvasSize);
  }
  // add FNSI-性能を最適化する 李 end
};
</script>

<style scoped>
.div-style {
  padding: 5px 10px;
}

.canvas-div-style {
  padding: 0px 10px;
}
.week-div-style {
  height: 25px !important;
}

.week-box {
  background-color: yellowgreen;
  color: #050505;
  float: left;
  height: 25px;
  text-align: center;
  border-style: solid;
  border-color: white;
  border-width: 0px 1px;
}

.to-week-box {
  background-color: #f0f8ff;
  color: #050505;
  float: left;
  width: 34px;
  height: 25px;
  text-align: center;
  border-style: solid;
  border-color: white;
  border-width: 0px 1px;
}

.select-tab {
  width: 100%;
  height: 30px;
}

.drag {
  z-index: 1001;
  opacity: 0.5;
  max-width: 34px;
}

.pop-chip {
  display: none;
  position: absolute;
  z-index: 1010;
  border: #cccccc solid 1px;
}

.menu-chip {
  margin: auto;
  text-align: center;
}

.footer-style {
  position: sticky;
  bottom: 0;
  background-color: var(--ntss-base-background-color);
}

/* 開始日・終了日inputタブ */
.date-input-other {
  width: calc(100% - 32px);
  padding-right: 2px !important;
}
.date-input-ios {
  width: 120px;
  padding-right: 2px !important;
}

input::-webkit-calendar-picker-indicator {
  display: none;
}

#div-parent {
  display: flex;
  flex-direction: column;
  height: 100%;
}

#div-parent :deep(ons-row) {
  height: auto;
}

.slot-style {
  overflow-y: auto;
  margin-bottom: 1.4em;
  padding:5px 10px;
}

/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .slot-style {
    overflow-y: visible;
    margin-bottom: 1.4em;
    padding:5px 10px;
  }
}
/* add FNSI-画面デザイン修正_患者経過総合ビューア「曜日グループボタン」 周 start */
.custom-week-disabled > .week-box,
.custom-week-disabled > .to-week-box {
  /* 非選択時の背景色：#b9b9b9 */
  background-color: #b9b9b9;
  /* 枠線：#c0c0c0*/
  border-color: #c0c0c0;
  /* 非選択時の文字色：#050505 */
  color: #050505;
}
.custom-week-disabled > .week-box:checked,
.custom-week-disabled > .to-week-box:checked {
  /* 選択時の背景色：#848484 */
  background-color: #848484;
  /* 選択時の文字色：#050505 */
  color: #050505;
}
/* add FNSI-画面デザイン修正_患者経過総合ビューア「曜日グループボタン」 周 end */
/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 100px;
  padding-top: 8px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */
.week-box, .to-week-box {
  touch-action: none;
}
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
/* mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end */
.canvas-style {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 10; /* 最前面に表示 */
  pointer-events: none; /* クリックなどのイベントを無視 */
}
</style>
