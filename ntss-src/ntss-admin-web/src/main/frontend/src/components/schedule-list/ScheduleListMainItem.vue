<!--
/**
* スケジュール表
*/
-->
<template>
  <div
    id="main-content-area"
    class="main-content-area schedule-list-main"
    style="overflow: hidden;"
    @mousemove="mouseMoveEvent"
  >
    <div v-show="!screenFlag">
      <!--
      <p class="cls-loading-modal-big">
        Loading Data・・・
        <v-ons-icon icon="fa-spinner" spin />
      </p>
  -->
    </div>
    <div v-show="screenFlag">
      <div id="id_coverarea1" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea2" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea3" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea4" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea5" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea6" class="cls-cover">
        <p class="cls-loading-modal-big">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea7" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea8" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea9" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea10" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea11" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>
      <div id="id_coverarea12" class="cls-cover">
        <p class="cls-loading-modal-small">
          Loading Data・・・・
          <v-ons-icon icon="fa-spinner" spin />
        </p>
      </div>

      <!-- area1-8 の枠 -->
      <div style="display: flex;">
        <!-- area1-4 の枠 -->
        <!-- Left part of the schedule -->
        <div>
          <!-- 指示者 -->
          <div id="id_area1" class="cls-area1">
            <div @click="showPopOver">
              <div style="text-align:right;height:calc(1.5em - 1px);">
                {{ dispStartYear }}年
              </div>
              <div height="15">指示者</div>
            </div>
            <div height="25px">
              <!-- mod FutreNetWeb+SI課題管理No4981対応 呉 start -->
                <!-- mod #10359 編集権限について、対応する。 zhangyue start -->
              <kendo-dropdownlist
                id="sijisya"
                ref="sijisyaDropdown"
                v-model="indUser"
                :disabled="!getItemAuthorized('ScheduleList', 'item_schedule')"
                :data-source="userOptions"
                :data-text-field="'fullName'"
                :data-value-field="'user_id'"
                style="width: 96%; height: 2em; margin-left: 2px;"
                class="select-indicator input-style-required"
                @open="addMaxContentStyle($event)"
              />
              <!-- mod #10359 編集権限について、対応する。 zhangyue end -->
              <!-- mod FutreNetWeb+SI課題管理No4981対応 呉 end -->
            </div>
          </div>
          <!-- Left title of the schedule -->
          <div id="area2_4_header" style="overflow: auto;"
            @wheel.passive="syncScrollFromFixed"
            @scroll="syncScrollFromFixed"
            @touchmove.passive="handleTouchMove"
            @touchstart.passive="handleTouchStart">
            <!-- Beds -->
            <div id="id_area2" class="cls-area2">
              <!-- ベッドタイトル -->
              <template v-for="i in titleNum" :key="i + '_bedtitle'">
                <component
                  :is="cmpNameBed"
                 
                  :props-id="'title_' + i"
                  :props-json="propsJ[i]"
                  style="border-right: 0;"
                />
              </template>
            </div>
            <!-- ベッド未登録 -->
            <div id="id_area3" class="cls-area3 cls-bed-title">
              ベッド未登録
            </div>
            <!-- クール未登録 -->
            <div id="id_area4" class="cls-area4 cls-bed-title">
              クール未登録
            </div>
          </div>
        </div>
        <!-- area5-8 の枠 -->
        <!-- The whole right part of the schedule. -->
        <div
          id="id_maindiv"
          @mousemove="moveEvent"
          @mouseleave="moveLeaveEvent"
          @click="clickEvent"
          @mousewheel.passive="mouseWheelEvent"
        >
          <div id="id_area5_cover" class="cls-area5-cover">
          <!-- ドラッグ&ドロップエリア -->
          <div id="id_area5" class="cls-area5" style="overflow: hidden;">
            <div id="id_area5_scrollarea">
              <!-- TODO:ヘッダー移動開放 -->
              <!-- ヘッダー -->
              <!-- 日付ヘッダー -->
              <template v-for="d in dayHeaderNum1st" :key="d + '_dayhead'">
                <component
                  :is="cmpNameDayHeader"
                 
                  :props-id="'-' + d"
                  :props-json="propsJDayHeader[d]"
                  :props-holiday="getDayDispIndex[d - 1]"
                />
              </template>
              <template v-for="d in dayHeaderNum2nd" :key="d + 7 + '_dayhead'">
                <component
                  :is="cmpNameDayHeader"
                 
                  :props-id="'-' + (d + 7)"
                  :props-json="propsJDayHeader[d + 7]"
                  :props-holiday="getDayDispIndex[d + 6]"
                />
              </template>
              <template v-for="d in dayHeaderNum3rd" :key="d + 14 + '_dayhead'">
                <component
                  :is="cmpNameDayHeader"
                 
                  :props-id="'-' + (d + 14)"
                  :props-json="propsJDayHeader[d + 14]"
                  :props-holiday="getDayDispIndex[d + 13]"
                />
              </template>

              <div
                id="kendo_day"
                class="cls-dayheader"
                @dblclick="dblclickEvent"
                @click="clickHeadEvent"
              >
                <kendo-grid
                  ref="ref_kendoDay"
                  :resizable="true"
                  :height="1"
                  style="border-left: 0; border-top-color: silver;"
                  @columnresize="onColumnResizeDay"
                >
                  <template v-for="d in dayHeaderNum1st" :key="d">
                    <kendo-grid-column
                     
                      :field="'ProductName' + d"
                      :title="'index_' + d"
                      :width="getDayColumnWidth(d)"
                      :height="40"
                      :header-attributes="{ class: 'cls-kendo-grid-head' }"
                    />
                  </template>
                  <template v-for="d in dayHeaderNum2nd" :key="d + 7">
                    <kendo-grid-column
                     
                      :field="'ProductName' + (d + 7)"
                      :title="'index_' + (d + 7)"
                      :width="getDayColumnWidth(d + 7)"
                      :height="40"
                      :header-attributes="{ class: 'cls-kendo-grid-head' }"
                    />
                  </template>
                  <template v-for="d in dayHeaderNum2nd" :key="d + 14">
                    <kendo-grid-column
                     
                      :field="'ProductName' + (d + 14)"
                      :title="'index_' + (d + 14)"
                      :width="getDayColumnWidth(d + 14)"
                      :height="40"
                      :header-attributes="{ class: 'cls-kendo-grid-head' }"
                    />
                  </template>
                </kendo-grid>
              </div>
              <!-- クールヘッダー -->
              <template v-for="d in dayHeaderNum1st" :key="`kurhead-row1-${d}`">
                <template v-for="x in kurNum" :key="`kurhead-cell1-${d}-${x}`">
                  <component
                    :is="cmpNameKurHeader"
                                        :props-id="d + '-' + x"
                    :props-json="propsJKurHeader[d][x]"
                    :props-treat-date="propsJDayHeader[d]"
                  />
                </template>
              </template>
              <template v-for="d in dayHeaderNum2nd" :key="`kurhead-row2-${d}`">
                <template v-for="x in kurNum" :key="`kurhead-cell2-${d}-${x}`">
                  <component
                    :is="cmpNameKurHeader"
                                        :props-id="d + 7 + '-' + x"
                    :props-json="propsJKurHeader[d + 7][x]"
                    :props-treat-date="propsJDayHeader[d + 7]"
                  />
                </template>
              </template>
              <template v-for="d in dayHeaderNum3rd" :key="`kurhead-row3-${d}`">
                <template v-for="x in kurNum" :key="`kurhead-cell3-${d}-${x}`">
                  <component
                    :is="cmpNameKurHeader"
                    :props-id="d + 14 + '-' + x"
                    :props-json="propsJKurHeader[d + 14][x]"
                    :props-treat-date="propsJDayHeader[d + 14]"
                  />
                </template>
              </template>
              <div v-if="delayFlag">
                <div
                  id="kendo_kur"
                  class="cls-kurheader"
                  @click="clickHeadEvent"
                >
                  <!-- :height="0" でkendoのスクロールバーを非表示に設定 -->
                  <kendo-grid
                    ref="ref_kendoKur"
                    :resizable="true"
                    :height="0"
                    style="border-left: 0; border-bottom: 0;border-top-width: 1px; border-top-color: white;"
                    @columnresize="onColumnResize"
                  >
                    <template v-for="d in dayHeaderNum1st" :key="`day1-${d}`">
                      <template v-for="x in kurNum" :key="`kur-${d}-${x}`">
                        <kendo-grid-column
                          :field="'ProductName' + d + '-' + x"
                          :title="'index_' + d + '-' + x"
                          :width="getKurColumnWidth(d, x)"
                          :height="40"
                          :header-attributes="{ class: 'cls-kendo-grid-head sub-header' }"
                        />
                      </template>
                    </template>
                    <template v-for="d in dayHeaderNum2nd" :key="`day2-${d}`">
                      <template v-for="x in kurNum" :key="`kur-${d}-${x}`">
                        <kendo-grid-column
                          :field="'ProductName' + (d + 7) + '-' + x"
                          :title="'index_' + (d + 7) + '-' + x"
                          :width="getKurColumnWidth(d + 7, x)"
                          :height="40"
                          :header-attributes="{ class: 'cls-kendo-grid-head sub-header' }"
                        />
                      </template>
                    </template>
                    <template v-for="d in dayHeaderNum2nd" :key="`day3-${d}`">
                      <template v-for="x in kurNum" :key="`kur3-${d}-${x}`">
                        <kendo-grid-column
                          :field="'ProductName' + (d + 14) + '-' + x"
                          :title="'index_' + (d + 14) + '-' + x"
                          :width="getKurColumnWidth(d + 14, x)"
                          :height="40"
                          :header-attributes="{ class: 'cls-kendo-grid-head sub-header' }"
                        />
                      </template>
                    </template>
                  </kendo-grid>
                </div>
              </div>
            </div>
          </div>
          </div>
          <!-- area6-8 のスクロール用div / 項目部分のスクロールは連動させる -->
          <!--mod 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start -->
          <div
            id="scroll_area"
            style="overflow: scroll; -webkit-overflow-scrolling: touch;"  @scroll="scrollWatch"
          >
          <!--mod 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end -->
            <div id="id_area6" class="cls-area6">
              <!-- ベッド表示(クール領域) -->
              <div :style="'width:' + area6Width + 'px;'">
                <!-- FNSI-mod 現行改善対応425 徐天宇 start -->
                <table
                  id="id_area6_tbl"
                  class="cls-table"
                  :width="area6Width + 'px'"
                >
                  <tbody>
                  <!-- FNSI-mod 現行改善対応425 徐天宇 end -->
                  <tr style="border:none;">
                    <template v-for="d in tmp_dayMax" :key="`tmpday-${d}`">
                      <template v-for="x in tmp_kurNum" :key="`tmpkur-${d}-${x}`">
                        <td
                          :id="'id_td_' + d + '_' + x"
                          :style="
                            'width:' +
                              kurDayWidth[d][x] +
                              'px;vertical-align:top;border:none;padding:0px;visibility:' +
                              kurDayVisibility[d][x] +
                              ';'
                          "
                        >
                          <!-- real bed part -->
                          <keep-alive>
                            <component
                              :is="cmpNameKur"
                              :props-id="d + '-' + x"
                              :props-move-data="propsJMoveData[d][x]"
                              :props-dummy-data="propsJDummyData[d][x]"
                              :props-treat-date="propsJDayHeader[d]"
                              :props-is-disp="propsBKurDispFlag[x]"
                            />
                          </keep-alive>
                        </td>
                      </template>
                    </template>
                  </tr>
                
                  </tbody>
                </table>
              </div>

              <div id="id_vline" class="cls-vline"></div>
            </div>

            <!-- ベッド未登録 -->
            <div id="id_area7" class="cls-area7">
              <div :style="'width:' + area6Width + 'px;'">
                <!-- FNSI-mod 現行改善対応425 徐天宇 start -->
                <table
                  id="id_area7_tbl"
                  class="cls-table"
                  :width="area6Width + 'px'"
                >
                  <tbody>
                  <!-- FNSI-mod 現行改善対応425 徐天宇 end -->
                  <tr style="border:none;">
                    <template v-for="d in tmp_dayMax" :key="`tmpday-${d}`">
                      <template v-for="x in tmp_kurNum" :key="`tmpkur-${d}-${x}`">
                        <td
                          :id="'id_tdbednotyet_' + d + '_' + x"
                          :style="
                            'width:' +
                              kurDayWidth[d][x] +
                              'px;vertical-align:top;border:none;padding:0px;visibility:' +
                              kurDayVisibility[d][x] +
                              ';opacity:' +
                              opacityNotYetBed +
                              ';'
                          "
                        >
                          <template v-for="y in dispNumNotYetBed" :key="`bednotyet-y-${d}-${x}-${y}`">
                            <component
                              :is="cmpNameBed"
                              :props-id="'BednotYet' + d + '-' + x + '-' + y"
                              :props-json="propsJBedNotYet[d][x][y]"
                              :props-treat-date="propsJDayHeader[d]"
                              :props-is-disp="propsBKurDispFlag[x]"
                            />
                          </template>
                        </td>
                      </template>
                    </template>
                  </tr>
                
                  </tbody>
                </table>
              </div>

              <div id="id_vlineArea7" class="cls-vline"></div>
            </div>

            <!-- クール未登録 -->
            <div id="id_area8" class="cls-area8">

              <div :style="'width:' + area6Width + 'px;'">
                <!-- FNSI-mod 現行改善対応425 徐天宇 start -->
                <table class="cls-table" :width="area6Width + 'px'">
                  <tbody>
                  <!-- FNSI-mod 現行改善対応425 徐天宇 end -->
                  <tr style="border:none;">
                    <template v-for="d in tmp_dayMax" :key="`tmpday-${d}`">
                      <template v-for="x in tmp_kurNum" :key="`tmpkur-${d}-${x}`">
                        <td
                          :id="'id_tdkurnotyet_' + d + '_' + x"
                          :style="
                            'width:' +
                              kurDayWidth[d][x] +
                              'px;vertical-align:top;border:none;padding:0px;visibility:' +
                              kurDayVisibility[d][x] +
                              ';opacity:' +
                              opacityNotYetKur +
                              ';'
                          "
                        >
                          <template v-for="y in dispNumNotYetKur" :key="`kurnotyet-y-${d}-${x}-${y}`">
                            <component
                              :is="cmpNameBed"
                              :props-id="'KurnotYet' + d + '-' + x + '-' + y"
                              :props-json="propsJKurNotYet[d][x][y]"
                              :props-treat-date="propsJDayHeader[d]"
                              :props-parent-width="kurDayWidth[d][x]"
                            />
                          </template>
                        </td>
                      </template>
                    </template>
                  </tr>
                
                  </tbody>
                </table>
              </div>
              <div id="id_vlineArea8" class="cls-vline"></div>
              <div v-show="false" id="id_template_block">
                <table>
                  <tbody>
                  <tr>
                    <td colspan="3"></td>
                  </tr>
                  <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- スクロールバーエリア -->
      <div
        v-show="false"
        id="id_area9"
        class="cls-scrollbar"
        @scroll="scrollEvent"
      >
        <!-- スクロールエリア9(横) -->
        <div id="id_underbar_content9" style="width:10px;">&nbsp;</div>
      </div>
      <div
        v-show="false"
        id="id_area10"
        class="cls-scrollbar"
        @scroll="scrollEvent"
      >
        <!-- スクロールエリア10(縦) -->
        <div id="id_sidebar_content10" style="width:10px;">&nbsp;</div>
      </div>
      <div
        v-show="false"
        id="id_area11"
        class="cls-scrollbar"
        @scroll="scrollEvent"
      >
        <!-- スクロールエリア11(縦) -->
        <div id="id_sidebar_content11" style="width:10px;">&nbsp;</div>
      </div>
      <div
        v-show="false"
        id="id_area12"
        class="cls-scrollbar"
        @scroll="scrollEvent"
      >
        <!-- スクロールエリア12(縦) -->
        <div id="id_sidebar_content12" style="width:10px;">&nbsp;</div>
      </div>

      <div v-if="popoverVisible">
        <schedule-popover
          ref="schedule_popover"
          v-bind="popoverData"
          :popover-visible="popoverVisible"
          @popover-close="closePopOver"
          @apply-status="applyStatus"
        />
      </div>
    </div>

    <div v-if="isShowUsageGuide" id="area_usage_guide">
      <div class="usage-guide-div">
        <div class="usage-guide-element" style="background-color: white; border: silver solid 1px;"></div>
        ：予定
      </div>
      <div class="usage-guide-div">
        <div class="usage-guide-element" style="background-color: #42CB92; border: #42CB92 solid 1px;"></div>
        ：前体重測定済
      </div>
      <div class="usage-guide-div">
        <div class="usage-guide-element" style="background-color: #2CA06F; border: #2CA06F solid 1px;"></div>
        ：治療中
      </div>
      <div class="usage-guide-div">
        <div class="usage-guide-element" style="background-color: #557769; border: #557769 solid 1px;"></div>
        ：治療終了
      </div>
      <div class="usage-guide-div">
        <div class="usage-guide-element" style="background-color: #808080; border: #808080 solid 1px;"></div>
        ：確定実績
      </div>
      <div class="usage-guide-div">
        <div class="usage-guide-element" style="background-color: #D3D3D3; border: #D3D3D3 solid 1px;"></div>
        ：長時間予約
      </div>
      <div class="usage-guide-div">
        <div style="color: #A356A3;">患者名</div>
        ：入院患者
      </div>
      <div class="usage-guide-div">
        <div>患者名</div>
        ：外来患者
      </div>
      <div style="display: flex;">
        <div>患者名*</div>
        ：同姓同名患者
      </div>
    </div>

    <!-- メニューエリア -->
    <v-ons-popover cancelable
                   v-model:visible="menuPopoverShowFlag"
                   :target="menuPopoverTarget"
                   direction="down up"
                   :cover-target="false"
                   :class="[fontSizeSet, 'schedule-list-header']"
    >
      <div style="margin: 5px;">
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229 -->
            <v-ons-button
              title="患者情報画面に移動します"
              class="btn-scheldule-list btn3-normal"
              @click="changeView('pat-info', true)"
              :disabled="!canToPatInfo">
              <img class="icon" :src="imagePatInfo"/>
              患者情報
            </v-ons-button>
            <!-- add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229 -->
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229 -->
            <v-ons-button
              title="患者経過総合ビューア画面に移動します"
              class="btn-scheldule-list btn3-normal"
              @click="changeView('pat-viewer', true)"
              :disabled="!canToPatViewer">
              <img class="icon" :src="imagePatViewer"/>
              患者経過総合ビューア
            </v-ons-button>
            <!-- add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229 -->
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- ヘッダとボタンの並びを合わせる為の配置 / このポップオーバーが表示される対象では遷移不可 -->
        <v-ons-row v-if="!idHidden()" style="margin-bottom: 5px;">
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <v-ons-button
              title="体重測定画面に移動します"
              class="btn-scheldule-list btn3-normal"
              @click="changeView('send-condition')"
              disabled="disabled">
              <img class="icon" :src="imageWeight"/>
              体重測定
            </v-ons-button>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229 -->
            <v-ons-button
              title="治療記録画面に移動します"
              class="btn-scheldule-list btn3-normal"
              @click="changeView('treatment-record', true)"
              :disabled="!canToTreatmentRecord">
              <img class="icon" :src="imageTreatmentRecord"/>
              治療記録
            </v-ons-button>
            <!-- add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229 -->
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
    <!-- mod 5901  赵 start -->
    <div v-if="messageDialogInfo.isDialogVisible">
      <message-dialog
        v-model:visible="messageDialogInfo.isDialogVisible"
        :message-cd="messageDialogInfo.messageCd"
        :type="messageDialogInfo.type"
        :string-params="messageDialogInfo.stringParams"
        :title="getMessageTitle(messageDialogInfo.messageCd, messageDialogInfo.title)"
        @confirm="confirm"
      />
    </div>
    <div v-if="cancelSendCondVisible">
      <message-dialog
        v-model:visible="cancelSendCondVisible"
        class="cancel-send-message"
        :message-cd="cancelSendCondCd"
        :type="cancelSendCondType"
        :title="getMessageTitle(cancelSendCondCd, messageDialogInfo.title)"
        @confirm="cancelSendCondConfirm"
      />
    </div>
    <!-- mod 5901  赵 end -->
  </div>
</template>

<script>
  //kendo-uiテーブル自動幅合わせ抑制処理用(ダブルクリックの無効化)
  import $$ from "@/compat/jquery";

  import _ from "@/compat/collections/lodash";
  //日付処理用
  import dayjs from "@/compat/date/dayjs";
  import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
  //ベッドコンポーネント
  import BedComponent from "@/components/schedule-list/BedComponent";
  //日付ヘッダーコンポーネント
  import DayHeaderComponent from "@/components/schedule-list/DayHeaderComponent";
  //クールヘッダーコンポーネント
  import KurHeaderComponent from "@/components/schedule-list/KurHeaderComponent";
  //クールコンポーネント
  import KurComponent from "@/components/schedule-list/KurComponent";
  // popoverコンポーネント
  import SchedulePopover from "@/components/schedule-list/SchedulePopover";
  //指示者取得&組み立て用
  import { ApiHelper } from "@/apis/AxiosHelper";
  import axios from "@/compat/http/axios";
  //メッセージダイアログ
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  //定義
  import { AREA_BED, AREA_BEDNOTYET, AREA_KURNOTYET, DEF_BEDTITLE_WIDTH, DEF_BED_NOT_YET_NUM, DEF_CELL_HEIGHT, DEF_CELL_HEIGHT_FONT_SIZE_EXTRA_LARGE, DEF_CELL_HEIGHT_FONT_SIZE_LARGE, DEF_CELL_HEIGHT_FONT_SIZE_MEDIUM, DEF_CELL_HEIGHT_FONT_SIZE_SMALL, DEF_DAY, DEF_DAYMAX, DEF_DIALOG_CANNOTMOVE, DEF_DIALOG_FACILITY_SETTING_1007_4, DEF_DIALOG_FACILITY_SETTING_1007_4_2, DEF_DIALOG_FACILITY_SETTING_1008_4, DEF_DIALOG_FACILITY_SETTING_1008_4_2, DEF_DIALOG_FACILITY_SETTING_2007_4, DEF_DIALOG_FACILITY_SETTING_2008_4, DEF_DIALOG_FACILITY_SETTING_3005_4, DEF_DIALOG_FACILITY_SETTING_3005_4_2, DEF_DIALOG_MSG_1, DEF_DIALOG_MSG_11, DEF_DIALOG_MSG_12, DEF_DIALOG_MSG_16, DEF_DIALOG_MSG_17, DEF_DIALOG_MSG_18, DEF_DIALOG_MSG_19, DEF_DIALOG_MSG_2, DEF_DIALOG_MSG_20, DEF_DIALOG_MSG_29, DEF_DIALOG_MSG_3, DEF_DIALOG_MSG_33, DEF_DIALOG_MSG_4, DEF_DIALOG_MSG_8, DEF_DIALOG_NODATA, DEF_DIALOG_NOUSE, DEF_DIALOG_REPLACE, DEF_DIALOG_REPLACEUNMATCH, DEF_DIALOG_SAMECOND, DEF_DIALOG_UNMATCH, DEF_DISP_WEEK, DEF_ELEMNUM, DEF_HEADER_HEIGHT, DEF_KUR, DEF_KUR_MAX, DEF_KUR_NOT_YET_NUM, DEF_KUR_WIDTH, DEF_LIST_WIDTH_MIN, DEF_MAX_DAY_HEADER, DEF_MSGTYPE_OK, DEF_MSGTYPE_OK_CANCEL, DEF_NOTASSIGNED, DEF_NUM_NOTYETAREA, DEF_OPA_IN_USE, DEF_RET_NG, DEF_RET_NG_RELOAD, DEF_SCROLLBAR_WIDTH, DEF_UNDEFINED, OPE_DEC, OPE_INC } from "@/components/schedule-list/Definitions.js"

  //指示者リスト取得
  import { AUTHORITY_CODES } from "@/constants/userAuthority";
  import { KEY_NAME_SCHEDULE_LIST } from "@/constants/defaultSettingConstants";
  import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
  import { EventBus } from "@/compat/vue/event-bus.js";
  import { deepCopy, getAuthorized } from "@/functions/common/CommonFunctions";
  import { getCurrentFunctionCd, getFunctionCd } from "@/router/routing-helper";

import PopoverMixin from "@/components/PopoverMixin";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import PrintMixin from "@/components/PrintMixin";

import { getMainContentAreaElement, getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { detachKendoPopupEventHandlers, findKendoGridHeaderCells, findKendoGridHeaderColElements, findKendoGridBodyColElements, getKendoGridColumnDomParts, syncKendoGridHeaderBodyTableWidth } from "@/functions/common/KendoFunctions";

import { publicAssetPath } from "@/compat/assets/public-path";
import { getOnsAlertDialogFooterItems, getOnsAlertDialogFromEvent } from "@/functions/common/OnsenFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { isProcSuccess } from "@/functions/common/ApiResponseFunctions";

  export default {
    components: {
      BedComponent,
      DayHeaderComponent,
      KurHeaderComponent,
      "message-dialog": messageDialog,
      KurComponent,
      "schedule-popover": SchedulePopover
    },
    mixins: [IndUserSelectMixin, PopoverMixin, UserAuthorityMixin, PrintMixin],
    data() {
      return {
        // add #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
        showExamDeadlineMsgFlg: false,
        showRadDeadlineMsgFlg: false,
        // add #9273 施設設定マスタのNo105の設定どおり動かない。 dou end
        //メッセージ設定用のJson
        messageDialogInfo: {
          isDialogVisible: false,
          messageCd: DEF_DIALOG_MSG_1,
          type: DEF_MSGTYPE_OK,
          dialogNo: DEF_DIALOG_NOUSE,
          stringParams: []
        },

        msgNo: 0, //メッセージ番号受け渡し用

        msgPopUpFlag: false, //メッセージがポップアップしているかのフラグ true:メッセージポップアップ中

        /**
         * データ取得をVUE側で行う場合の変数群
         */
        dispdata: {}, //データ格納用

        /**
         * 表示抑止用定義
         */
        tmp_titleNum: 0,
        tmp_dayHeaderNum: 0,
        tmp_kurNum: 0,
        tmp_dayMax: 0,
        tmp_dispNumNotYetBed: 0,
        tmp_dispNumNotYetKur: 0,
        delayFlag: false,

        area6Width: 7000,

        disabledFlag: false,

        treatDateDim: [DEF_MAX_DAY_HEADER + 1], //日付配列(yyyymmdd)

        /**
         * ポップオーバー表示関連
         */
        popoverTarget: null,
        popoverDirection: "down",
        popoverCoverTarget: false,
        popoverVisible: false,
        // 操作メニューポップオーバー
        menuPopoverShowFlag: false,
        menuPopoverTarget: null,

        screenFlag: false, //全体表示フラグ
        autoresizeFlag: true, //kendo-gridのオートリサイズのON(true)/OFF(false)
        //コンポーネント名用
        cmpNameKur: "KurComponent",
        cmpNameBed: "BedComponent",
        cmpNameKurHeader: "KurHeaderComponent",
        cmpNameDayHeader: "DayHeaderComponent",

        //クール未登録関連変数
        dispNumNotYetKur: DEF_KUR_NOT_YET_NUM,
        areaMaxNotYetKur: 0,
        propsJKurNotYet: [DEF_DAYMAX + 1],
        opacityNotYetBed: DEF_OPA_IN_USE, //表示透明度

        //ベッド未登録関連変数
        dispNumNotYetBed: DEF_BED_NOT_YET_NUM,
        areaMaxNotYetBed: 0,
        propsJBedNotYet: [DEF_DAYMAX + 1],
        opacityNotYetKur: DEF_OPA_IN_USE, //表示透明度

        kurNum: DEF_KUR_MAX, //クール数
        kurNamesForOption: [], //設定のクールオプション一覧
        propsJKurHeader: [DEF_DAYMAX + 1],

        roomBedGroupNum: 0, //ベッドグループオプション数
        roomBedGroupNamesForOption: [], //設定のベッドグループオプション一覧

        propsJMoveData: [DEF_DAYMAX + 1], //移動通知用
        propsJDummyData: [DEF_DAYMAX + 1], //ダミースケジュール通知用

        dayMax: DEF_DAYMAX, //表示日付の最大値設定
        dayHeaderNum: DEF_MAX_DAY_HEADER,
        propsJDayHeader: [DEF_DAYMAX + 1],

        dayHeaderNum1st: 7, //日付ヘッダー1週目のカウンタ(v-for)
        dayHeaderNum2nd: 7, //日付ヘッダー2週目のカウンタ(v-for)
        dayHeaderNum3rd: 0, //日付ヘッダー3週目のカウンタ(v-for)
        dayHeaderLayoutRafId: 0,
        dayHeaderLayoutTimerId: 0,
        scheduleHeaderResizeRafId: 0,
        scheduleHeaderResizeEndListening: false,

        //幅変更用チップ
        elemsChangeWidthChip: [],
        propsJChangeWidthChip: [],

        titleNum: 0, //ベッド数(タイトル部:縦) デフォルトは一番最初の表示用の仮値
        propsJ: [], //ベッドタイトル列用プロパティ

        //各表パーツの配置情報格納用
        dimX: [], //X座標
        dimY: [], //Y座標
        dimW: [], //幅
        dimH: [], //高さ

        // FNSI-del 現行改善対応425 徐天宇 start
        // tblWidth: 0, //表示部のテーブル幅
        // FNSI-del 現行改善対応425 徐天宇 end

        bedAreaHeight: 0, //確定エリア表示高さ
        notYetAreaHeightBed: 0, //ベッド未登録エリア表示高さ
        notYetAreaHeightKur: 0, //クール未登録エリア表示高さ

        dayHeaderElems: [], //日付ヘッダー要素
        kurHeaderElems: [], //クールヘッダー要素

        //リサイズハンドラの要素ポインタ格納
        resizeElems: [],
        resizeVlineElem: null,
        resizeVlineElemArea7: null,
        resizeVlineElemArea8: null,

        //各ブロックの要素
        areaElems: [],

        //チップ移動時のスクロール設定
        autoScrollX: 0,
        autoScrollY: 0,

        scrollPointer: "default",

        //interval ID
        scrollIntervalId: 0,
        // add FNSI-redmine4272 徐 start
        setArea6Width: 0,
        // add FNSI-redmine4272 徐 end
        intervalKurNumId: 0,
        setArea6Id: 0,
        kurHeadWaitId: 0,
        shutterIntervalId: 0,
        intervalId: 0,
        relocateId: 0,

        resizeTimer: false,

        //ベッド移動用設定
        movingChipElem: null,
        parentElem: null,

        //移動ブロック
        movingBlockElem: null,
        movingBlockInfoFrom: [], //移動ブロック情報From(日付移動、クール移動共通)
        movingBlockInfoFromIndex: [], //移動ブロック情報From(日付index値)
        movingBlockInfoTo: [], //移動ブロック情報To(日付移動、クール移動共通)
        movingBlockInfoToIndex: [], //移動ブロック情報To(日付index値)
        movingBlockKind: "", //移動ブロックの種類 クール or 日付

        moveFromInfo: "", //移動元の識別名称  kurNotYet , bedNotYet
        moveFromIndex: [], //移動元の配列Index
        moveFromData: {}, //移動元データ
        moveToInfo: "", //移動先の識別名称  bed
        moveToIndex: [], //移動先の配列Index
        moveToData: {}, //移動先データ

        //add #10601 スケジュール表動作不正 start
        beforeMoveDataList: [],
        afterMoveDataList: [],
        //add #10601 次患者更新関連全体見直し対応 朴 end

        dispSettingNow: null, //表示条件設定値 保存用Json 開いたときの設定保存用
        dispSettingCommitted: null, //表示条件設定値 保存用Json 設定実行時の設定保依存用
        settingDiffFlag: false, //設定に変更があったかどうかのフラグ true:変更あり

        //表示開始日付
        dispStartDate: "",
        dispStartDateForSetting: "", //表示条件設定のカレンダー用
        dispStartYear: "",

        //表示条件設定:表示週数
        dispWeek: DEF_DISP_WEEK,

        //表示条件設定:未登録エリア表示数
        dispCellNumNotYetArea: DEF_NUM_NOTYETAREA,

        //クールの表示非表示
        kurWidth: [],
        kurDayWidth: [DEF_DAYMAX + 1], //[日][クール]の2次元配列
        kurDayVisibility: [DEF_DAYMAX + 1], //[日][クール]の2次元配列
        propsBKurDispFlag: [], //クール列の表示フラグ(クールコンポーネント制御用)
        //日付ヘッダー幅
        dayWidth: 0,

        //可動領域の横幅
        totalWidth: 20000,

        //現在の選択ベッド情報
        nowSelectedBedInfo: {},

        //ベッド情報取得待ちタイマーフラグ true:取得済み
        bedInfoWaitTimerReleaseFlag: true,

        //左端に本日を表示する際のスクロール開始位置補正
        scrollStartPosX: 0,

        firstReadFlag: true, //初回読み込みを表すフラグ(true:初回)

        //指示者データ	TODO:済 DBからの値の取得
        // 指示者リスト格納
        userOptions: [],
        // リストでの選択された指示者
        indUser: null,
        //不一致チェック結果格納
        unmatchResultJson: {},
        //シャッター要素の透明度
        setShutterOpacityVal: 0,
        //ダミースケジュール関連
        dummyKurIndexFrom: [], //ダミースケジュール移動元 [0]は自分自身のクールindex(1～) ダミーがある時は、配列の大きさが2以上
        dummyKurIndexTo: [], //ダミースケジュール移動先 [0]は自分自身のクールindex(1～) ダミーがある時は、配列の大きさが2以上
        //休日フラグ
        holidayFlag: true,
        //リサイズフラグ true:リサイズ中
        resizingNowFlag: false,
        //クリックイベントフラグ true:クリックイベント処理中
        clickEventNowFlag: false,

        //ベッド表示域の横幅
        listWidth: DEF_LIST_WIDTH_MIN,

        todayStr: "", //本日

        popoverData: null,

        // 未登録エリア※初期値2
        changeNotYetAreaCellNum: 2,

        // 選択したクール※初期値表示されているすべてのクール
        selectedKurIndexList: [],
        // クール初期設定したフラグ
        isSetting: false,

        // 選択肢したベッドグループ※初期値すべてを選択状態
        selectedRoomBedGroupCd: 0,

        // タッチ初期位置
        originPoint: 0,

        cancelSendCondVisible: false,

        // 端末判別
        androidFlg: false,
        iosFlg: false,

        // 複数の患者を移動するフラグ
        isMovePats: false,
        cancelSendCondCd: null,
        cancelSendCondType: "1",
        // 条件送信画面へ渡す
        selectedSendConditonOrdNo: null,
        // 凡例表示フラグ
        isShowUsageGuide: false,

        // 重複した予定のインデックス
        duplicateIndex: [],
        createJournalParam: {},
        isCreateJournal: false,
        // 予定移動時の移動先チェック用に、治療時間の最大(3日)分の予定を余分に取得する
        overFlowDayNum: 3,
        imagePatInfo: publicAssetPath("img/pat-info/pat-info.png"),
        imagePatViewer: publicAssetPath("img/pat-viewer/pat-viewer.png"),
        imageWeight: publicAssetPath("img/weight/weight.png"),
        imageTreatmentRecord: publicAssetPath("img/treatment-record/treatment-record.png"),
        // FNSI-add 現行改善対応425 孫灝 20201118 start
        // 施設設定マスタにNo７の「検査依頼」に選択肢「４」を選択したら、ダイアログが出る
        underElem: '',
        // FNSI-add 現行改善対応425 孫灝 20201118 end
        // add FNSI 1006 No.426 start --孙灏 20201215
        facilitySettingDialogOpenFlg: false,
        // Has dialog for No.1007 of facility setting been opened
        facilitySettingDialog1007OpenedFlg: false,
        // Has dialog for No.1008 of facility setting been opened
        facilitySettingDialog1008OpenedFlg: false,
        // Has dialog for No.3005 of facility setting been opened
        facilitySettingDialog3005OpenedFlg: false,
        // add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
        facilitySettingDialog1000OpenedFlg: false,
        facilitySettingDialog2007OpenedFlg: false,
        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        facilitySettingExamDialog2008OpenedFlg: false,
        facilitySettingRadDialog2008OpenedFlg: false,
        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
        // add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
        // add FNSI 1006 No.426 end --孙灏 20201215
        // FNSI-add 現行改善対応425 徐 start
        headerFlg: false,
        // FNSI-add 現行改善対応425 徐 end
        // FNSI-add redmine、No.3924 徐 start
        kurNumIndex: null,
        // FNSI-add redmine、No.3924 徐 end
        // add FNSI-redMine #4250対応  陳 start
        kurNumCount: 0,
        // add FNSI-redMine #4250対応  陳 end
        // FNSI-add 性能を最適化する 徐 start
        scrollAreaDes: null,
        // FNSI-add 性能を最適化する 徐 end
		// add 7216 【デグレ】患者経過総合ビューア画面で治療開始時刻を変更してもsys_coop_journalにイベントが作成されない zhao start
        initBad:null,
		// add 7216 【デグレ】患者経過総合ビューア画面で治療開始時刻を変更してもsys_coop_journalにイベントが作成されない zhao end
        // del #11004 連携イベント発生部分不正 piao start
        // del #11004 連携イベント発生部分不正 piao end
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
        selfScreenName: "",

        isOneOrSed:"",

        isReplaceSchedulePreProcessing :"",
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        isSamePatId:"0",
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
        //add #10601 スケジュール表動作不正 start
	moveSendConditionData: {},
        examDeadlineSelectedVal: "",
        radDeadlineSelectedVal: "",
        //add #10601 スケジュール表動作不正 end
        // add 10409 メッセージ表示の変更 関  start
        msgCd: "",
        msgCdList: [],
        examDeadlineCancelCheck: "",
        radDeadlineCancelCheck: "",
       // add 10409 メッセージ表示の変更 関  end
        touchStartY: 0,
        scrollQuerySelector: "#scroll_area",
        addClassTargetQuerySelector: [".cls-table","#id_area5_scrollarea"],
      };
    },
    computed: {
      ...mapGetters("app", ["getRefresh"]),
      ...mapGetters("bread-crumb", ["getKeepHistory"]),
      ...mapGetters("schedule-list", [
        "getStatus", //データ読み込み状態の取得用
        "getProgress", //データ読み込み進捗率取得用
        "getBedsData", //指定日付のデータ取得用
        "getDataLoadedFlag", //データ読み込み終了フラグ取得用
        "getBedInfo", //(選択された)ベッド情報取得用
        "getBedInfoKur",
        "getKurNames", //クール名一覧取得用
        "getKurCd", //クールコード取得用
        "getBedCd", //ベッドコード取得用
        "getBedName", //ベッド名取得用
        // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm start
        "getRoomBedGroupData", //ベッドグループ一覧取得用
        // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm end
        "getRoomBedGroupMap", //ベッドグループ名一覧取得用
        "getMaxKurNum", //クール数取得用
        "getPatBedInfo", //ベッド患者情報の取得
        "getHeaderSelection", //ヘッダー領域の操作ボタンの操作状況取得
        "getBedDispCount", //ベッド表示数の取得
        "getUnmatchInfo", //不一致情報の取得
        "getDayDispIndex", //日付表示情報
        "getSystemSettingUnmatchShowMsgFlag", //システム設定:不一致情報の確認メッセージ表示非表示フラグの取得
        "getDummyInfo", //ダミー情報取得用
        "getBedDispState", //ベッドの表示フラグ取得(引数index:0基底)  true:表示
        "getMaxBedNum", //ベッド最大数取得用
        "nameSetting", // 姓名の表示非表示フラグ
        "unmatchSetting", // 不一致の表示非表示フラグ
        "planSetting", // 予定ありの表示非表示フラグ
        "plansettingMainteWater", // 定期点検・水質検査予定ありの表示非表示フラグ
        "getHeaderDispInfo",
        // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
        "getAllBedCds",
        "getSelectKurCds",
        // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
        "getReportParams", // 帳票パラメータ取得用
        // add FNSI-改修内容フィルタ条件設定 房 start
        "getSaveFilterData",// 条件設定データ
        "getExamResult",// 検査結果存在チェック
        // add FNSI-改修内容フィルタ条件設定 房 end
        // add FNSI 1006 No.426 start --孙灏 20201215
        "getFacilitySetting3005", // 透析予定日変更時患者イベント変更機能 の設定値
        "getFacilitySetting1007",
        "getFacilitySetting1008",

        //add #10601 スケジュール表動作不正 start
        "getFacilitySetting1007_4SelectedVal",
        "getFacilitySetting1008_4SelectedVal",
        "getFacilitySetting3005_4SelectedVal",
        //add #10601 スケジュール表動作不正 end

        "getOtherSchedule",
        // add FNSI 1006 No.426 end --孙灏 20201215
        // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
        // FNSI-add 現行改善対応425 徐 start
        // FNSI-add 現行改善対応425 徐 end
		//add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
		//add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
        "checkDeadline",
        // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou end
        //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
        "getScrollLeftWitch",
        "getScrollTopWitch",
        //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        "getExamStatus",
        "getRadStatus"
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      ]),
      // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
      ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
      // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
      //施設コード取得用
      ...mapGetters("user", ["getFacilityCd"]),
      // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe start
      ...mapGetters("schedule-list", {
        dispUserTime: "getDispUserTime",
      }),
      // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe end
      //ユーザID、フォントサイズ取得用
      ...mapGetters("account-edit", [
        "getStateUserAccountInfo",
        "getFontSize",
        "getUserId",
        "getDefaultSetting",
        // add FNSI スケジュール表  権限対応  start -- Sanjingye Sun 20201229
        "getUseFunctions",
        // add FNSI スケジュール表  権限対応  end -- Sanjingye Sun 20201229
        "isDispMenu"
      ]),
      //要素リサイズ用
      ...mapGetters("window-size", {
        // サイドバー幅
        sidebarWidth: "getSidebarWidth"
      }),
      ...mapGetters("facility-calendar", ["scheduleListDayView"]),
      // add 機能帳票パラメータ確認 陳 start
      ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
      // add 機能帳票パラメータ確認 陳 end
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
      ...mapGetters("exam-request/list",{ getExamDeadlineCondition: "getDeadlineCondition" }),
      ...mapGetters("rad-request/list", { getRadDeadlineCondition: "getDeadlineCondition" }),
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
      elemResizeValue() {
        switch (Number(this.getFontSize)) {
          case 0:
            return DEF_CELL_HEIGHT_FONT_SIZE_SMALL;
          case 1:
          default:
            return DEF_CELL_HEIGHT_FONT_SIZE_MEDIUM;
          case 2:
            return DEF_CELL_HEIGHT_FONT_SIZE_LARGE;
          case 3:
            return DEF_CELL_HEIGHT_FONT_SIZE_EXTRA_LARGE;
        }
      },
      // add FNSI-redMine #4250対応 陳 start
      elemKurValue() {
        switch (Number(this.getFontSize)) {
          case 0:
            return 100;
          case 1:
          default:
            return 120;
          case 2:
            return 140;
          case 3:
            return 160;
        }
        // add FNSI-redMine #4250対応 陳 end
      },
      // add FNSI 権限 start -- Sanjingye Sun 20201228
      haveAuthority() {
        // mod #10359 編集権限について、対応する。 zhangyue start
        // 治療指示-代行編集, 治療指示-編集, スケジュール - 移動
        return this.getItemAuthorized('ScheduleList', 'item_schedule');
        // mod #10359 編集権限について、対応する。 zhangyue end
      },
      // add FNSI 権限 end -- Sanjingye Sun 20201228
      // add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229
      canToPatViewer() {
        // mod #10359、#10331 編集権限について、対応する。 dengshen start
        return true;
        // mod #10359、#10331 編集権限について、対応する。 dengshen end
      },
      canToTreatmentRecord() {
        // mod #10359、#10331 編集権限について、対応する。 dengshen start
        return true;
        // mod #10359、#10331 編集権限について、対応する。 dengshen end
      },
      canToPatInfo() {
        // mod #10359、#10331 編集権限について、対応する。 dengshen start
        return true;
        // mod #10359、#10331 編集権限について、対応する。 dengshen end
      }
      // add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229
    },
    watch: {
      elemResizeValue() {
        this.adjustElemSize();
        this.resizeListHeight();
      },
      /**
       * ベッドの表示数変化の監視
       * 監視目的:表示条件設定のベッドグループの設定で表示ベッド数が変化した場合に表の確定領域の高さを変更するため
       */
      getBedDispCount(dispCount) {

        //確定領域の高さの計算
        this.bedAreaHeight = this.calBedAreaHeight(dispCount);

        //枠のサイズ、位置計算
        this.calSizeAndPosition(
          0,
          0,
          DEF_BEDTITLE_WIDTH * this.elemResizeValue,
          DEF_HEADER_HEIGHT,
          this.bedAreaHeight,
          this.notYetAreaHeightBed,
          this.notYetAreaHeightKur,
          DEF_SCROLLBAR_WIDTH,
          this.listWidth,
          DEF_SCROLLBAR_WIDTH
        );
        //各要素への位置＆サイズの設定処理
        this.setElem();

        //縦スクロール高さの設定
        const setHeight = dispCount * DEF_CELL_HEIGHT * this.elemResizeValue;
        this.getScopedElementById(
          "id_sidebar_content10").style.height = `${setHeight}px`;
        this.dispatchScheduleResizeEvent();
      },
      /**
       * 表データ読み込み済みフラグ監視
       * @param newVal true:データの読み込みが終わった
       * 監視目的:データ読み込みを待って後続処理(画面描画)を行うため
       */
      getDataLoadedFlag(newVal,e) {
        if (newVal) {
          //一番最初のみ実行する
          if (this.firstReadFlag) {
            //画面表示開放(表が出ます。ただしこの時はシャッターが閉まった状態です)
            this.screenFlag = true;
            //初期表示シャッターを開ける
            this.openShutter();

            //入外区分の集計処理
            this.aggrigateInOutClass();

            //取得データをストアにセット
            this.setDispDataToStore(this.dispdata);

            //各コンポーネントのデータ設定
            this.procMain();

            //表全体のデータの設定
            this.setListData(null);

            //初めて処理を行ったかのフラグの変更("行った状態(false)"に変更)
            this.firstReadFlag = false;

            //すべて終わったので、臨時変数を書き換える
            this.tmp_kurNum = this.kurNum;
            this.tmp_dispNumNotYetBed = this.dispNumNotYetBed;
            this.tmp_dispNumNotYetKur = this.dispNumNotYetKur;

            //---------------------------------------------------
            //スクロール幅、開始位置などのスクロールの設定

            //指定日スクロール移動の設定監視(表示開始日を左端に設定するための監視:監視していないと表示タイミングによりスクロールの位置設定が適切に行われないことがあるため)
            this.area6Width = this.dispWeek * this.kurNum * DEF_KUR_WIDTH;
            this.areaElems[6].scrollLeft = this.area6Width / 2;
            this.areaElems[7].scrollLeft = this.area6Width / 2;
            this.areaElems[8].scrollLeft = this.area6Width / 2;

            // add FNSI-redmine4272 徐 start
            // mod #6050 スケジュール表の表示条件を変更した時の画面更新に時間がかかる 付 start
            // mod #6050 スケジュール表の表示条件を変更した時の画面更新に時間がかかる 付 end
            // add FNSI-redmine4272 徐 end

            const scrollLeftArea9 = this.areaElems[9].scrollLeft;

            //------------------------------------------------------------------------
            //増加用interval設定
            // タイマーでv-forの上限値を徐々に変更することで、徐々に描画処理が行われるようにする
            clearInterval(this.intervalKurNumId);
            this.intervalKurNumId = setInterval(
              function() {

                //日付の処理
                if (this.tmp_dayMax < this.dayMax) {
                  if (this.tmp_dayMax === 0) {
                    this.tmp_dayMax = 8; //日付を8日分に設定(8は、特に深い意味はない。調整可能項目)
                  } else {
                    ++this.tmp_dayMax;
                  }
                  if (this.tmp_dayMax > this.dayMax) {
                    this.tmp_dayMax = this.dayMax;
                  }
                }
                //クールの処理
                if (this.tmp_kurNum < this.kurNum) {
                  ++this.tmp_kurNum;
                  if (this.tmp_kurNum > this.kurNum) {
                    this.tmp_kurNum = this.kurNum;
                  }
                }
                //終了確認
                if (
                  this.tmp_kurNum === this.kurNum &&
                  this.tmp_dayMax === this.dayMax
                ) {
                  //シャッターの部品は使い終わったので、表示に影響しないサイズ、位置に設定します
                  this.resetShutterElem();
                  //                //出し切ったのでinterval終了
                  clearInterval(this.intervalKurNumId);
                }
              }.bind(this, scrollLeftArea9),
              100
            );

            //クールヘッダーの表示開放
            this.delayFlag = true;

            //------------------------------------------------------------------------
            //クールヘッダーの設定interval
            //幅設定を行うため、クールヘッダーの表示開放が行われて、表示が終わるまで待つ。
            clearInterval(this.kurHeadWaitId);
            this.kurHeadWaitId = setInterval(
              function() {
                //終了を"ref_kendoKur"の有無で判定します。
                if (
                  "ref_kendoKur" in this.$refs &&
                  typeof this.$refs.ref_kendoKur !== DEF_UNDEFINED
                ) {
                  //kendo-gridへのコンポーネントの貼り付け(クールヘッダー)
                  this.relocateKendoHeaders("kur", 0);
                  //幅の変更
                  this.setDayDisplay(this.dispWeek);

                  const targetTHElems = this.$el?.querySelectorAll?.("th[data-field]") || [];

                  for (let i = 0; i < targetTHElems.length; i++) {
                    let attr = targetTHElems[i].getAttribute("data-field");
                    if (null !== attr) {
                      attr = attr.replace("ProductName", "");
                      const distDim = attr.split("-");
                      if (distDim.length === 1) {
                        //日付ヘッダー
                        this.dayHeaderElems[distDim[0]] = targetTHElems[i];
                      } else {
                        //クールヘッダー
                        this.kurHeaderElems[distDim[0]][distDim[1]] =
                          targetTHElems[i];
                      }
                    }
                  }

                  //kendo-grid部分のヘッダーの縦スクロールバーの領域を削る(強制削除)
                  const headElems = this.getScheduleGridHeaderEls();
                  for (let i1 = 0; i1 < headElems.length; i1++) {
                    headElems[i1].style.paddingRight = "0px";
                  }

                  clearInterval(this.kurHeadWaitId);
                  // データ読み込みが終わったら最終リサイズを発火する
                  this.dispatchScheduleResizeEvent();
                }
              }.bind(this),
              100
            );

            // add FNSI-改修内容フィルタ条件設定 房 start
            setTimeout(async () => {
              // del #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou start
              //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
              //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
              // del #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou end
              const saveData = this.getSaveFilterData;
              if (saveData.settingJsonBefore && saveData.settingJsonAfter) {
                // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou start
                //開始日付設定
                //mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
                if((this.$route.query.function_cd ?? this.$route.params.function_cd) == "009" || this.getKeepHistory.length == 1){
                  this.dispStartDateForSetting = dayjs().format("YYYY-MM-DD");
                } else{
                  this.dispStartDateForSetting = this.$route.params.startDate ? dayjs(this.$route.params.startDate).format("YYYY-MM-DD") :this.dispUserTime ? dayjs(this.dispUserTime).format("YYYY-MM-DD") : saveData.settingJsonAfter.startDate;
                }
                //mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
                //del #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
                //del #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
                //表示期間設定
                this.dispWeek = saveData.settingJsonAfter.dispTermNum;
                //休日表示設定
                this.holidayFlag = saveData.settingJsonAfter.dispHolidayFlag;
                //クール表示設定
                await this.changeKurDispState(saveData.settingJsonAfter.dispKurDimStr);
                this.setReportParamKurCd(saveData.settingJsonAfter.dispKurDimStr);
                //ベッドグループ表示設定
                await this.changeBedGroupState(saveData.settingJsonAfter.dispGroupDimStr + "");
                //凡例表示設定
                this.isShowUsageGuide = saveData.settingJsonAfter.dispUsageGuide;
                // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou end
                this.popoverTarget = event;
                this.popoverDirection = "down";
                this.popoverCoverTarget = e;
                if (!this.isSetting) {
                  // 初期値を設定※クールのみ表示している全ての項目を選択状態へ
                  this.setSelectedIndexList();
                }

                this.setPopoverData(e, "down", true);
                this.applyStatus(saveData.settingJsonBefore,saveData.settingJsonAfter);
                /* modify by chamaojia 2024-07-11 [10806] Change judgment parameters --start */
                const bedDispCount = this.getBedDispCount;
                if (bedDispCount > 0) {
                  this.bedAreaHeight = this.calBedAreaHeight(bedDispCount);
                }
                /* modify by chamaojia 2024-07-11 [10806] Change judgment parameters --end */
              } else if (dayjs().format("YYYY-MM-DD") !== dayjs(this.dispStartDateForSetting).format("YYYY-MM-DD")) {
                // saveDataがなく、デフォルト設定もない時に日時指定で遷移したときにapplyStatusを実行

                let initData = this.createInitData();

                // 変更があるデータを作成
                let editData = deepCopy(initData);
                this.applyStatus(initData,editData);
                // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou start
              } else {
                this.defaultSetting();
                // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou end
              }
            }, 400);
            // add FNSI-改修内容フィルタ条件設定 房 end

            setTimeout(() => {
              this.adjustElemSize();
              this.resizeListHeight();
              // 共通ローダー:表示終了
              this.setLoadingScreenVisible(false);
            }, 500);
          }
        }
      },
      /**
       * ベッド情報の取得
       */
      getBedInfo(newJson) {
        this.bedInfoWaitTimerReleaseFlag = true;

        if ( typeof newJson !== DEF_UNDEFINED && newJson) {
          //現在の選択ベッド情報として記録
          this.nowSelectedBedInfo = newJson;
          let patLastName = "";

          if ("patLastName" in newJson) {
            patLastName = newJson.patLastName;
          }

          if (patLastName === "") {
            //名前がないので空きベッド}
            this.setHeaderDispDefaultMode();
          } else {
            this.setHeaderDispPatMode(newJson);
          }
        } else {
          //データがないので空きベッド扱い
          //ヘッダー領域表示を初期表示に設定するように依頼
          this.setHeaderDispDefaultMode();
        }
      },
      // サイドバー開閉時
      sidebarWidth() {
        this.dispatchScheduleResizeEvent();
      },
      /**
       * メニューバー表示／非表示変更時
       */
      isDispMenu() {
        // 表の縦幅サイズ変更を実行
        this.resizeListHeight();
      }
    },
    async created() {
      // 画面名称取得
      this.selfScreenName = this.$route.name;
      // FNSI-add スケジュール - 移動の追加 徐 end
      // 共通ローダー:表示名設定
      this.setLoadingScreenMessage("処理中・・・");
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // 端末判別
      const ua = this.getScheduleOwnerWindow()?.navigator?.userAgent || "";
      if (ua.match(/Android/)) {
        this.androidFlg = true;
      } else if (ua.match(/iPhone|iPad/)) {
        this.iosFlg = true;
      }

      this.setDataLoadFlag(false);

      this.todayStr = this.formatMomentDateYYYYMMDD(dayjs()); //本日の日付 yyyymmdd

      //------------------------------------------------------
      //Windowリサイズ用のイベント登録
      this.getScheduleOwnerWindow().addEventListener("resize", this.loadResizeMethod, false);

      //--------------------------------------------------------------
      //各フラグの初期化

      this.firstReadFlag = true; //初回読み込みフラグ

      //再読込時のインターバルIDのクリア
      clearInterval(this.intervalKurNumId);
      clearInterval(this.setArea6Id);
      clearInterval(this.kurHeadWaitId);
      clearInterval(this.shutterIntervalId);
      clearInterval(this.intervalId);
      clearInterval(this.relocateId);
      clearInterval(this.scrollIntervalId);

      //-----------------------------------------------------
      //  DBデータ 初期読み込み(非同期)
      //  画面初期呼び出し時に以下のデータを読み込みます(同期的に以下の処理順番は確保します)
      //  1.ベッド、クール、ベッドグループの取得
      //  2.日毎のデータ取得
      this.dbProcessing();

      //-----------------------------------------------------
      //バインド変数の初期化
      // バインドされている変数の領域を確保します
      // この際、クール数は取得できていないので、固定値Def.DEF_KUR_MAXを使用します
      this.initBindVals(DEF_KUR_MAX);
      // 指示者リスト作成(非同期)
      if (this.hasAuthorityByCd(AUTHORITY_CODES.SCHE_MOVE) && !this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT) && !this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT)) {
        this.getIndUserListSchedule().then(response => {
          this.userOptions = response.doctorList;
          this.$nextTick(() => {
            this.indUser = response.iniSelectId;
          });
        });
      } else {
        this.getIndUserList(
          AUTHORITY_CODES.IND_EDIT,
          AUTHORITY_CODES.IND_PEDIT).then(response => {
          this.userOptions = response.doctorList;
          this.$nextTick(() => {
            this.indUser = response.iniSelectId;
          });
        });
      }
      await this.setExamDeadline(this.getFacilityCd);
      await this.setRadDeadline(this.getFacilityCd);
      EventBus.$off("refresh", this.refreshData);
      EventBus.$off("requestReportParams", this.requestrReportParams);

      EventBus.$on("refresh", this.refreshData);

      // 印刷パラメータ要求
      EventBus.$on("requestReportParams", this.requestrReportParams);
      window.addEventListener("beforeprint", this.beforePrint);
      this.setLoadingScreenVisible(false);
    },
    mounted() {

      this.$nextTick(() => {
        const inputs = document.querySelectorAll('.k-input-value-text.k-input');
        inputs.forEach(el => {
          el.style.height = 'auto';
          el.style.setProperty('height', 'auto', 'important');
          el.style.fontSize = 'inherit';
        });
      });

      const styleId = 'schedule-list-dialog-style';
      if (!document.getElementById(styleId)) {
        const style = document.createElement('style');
        style.id = styleId;
        style.textContent = `
          .alert-dialog-footer {
            display: flex !important;
          }
        `;
        document.head.appendChild(style);
      }
      //--------------------------------------------------------------
      //一番はじめの表幅調整(ベッド表示域の横幅の決定)
      // 基本的にはWindow幅一杯に表を表示します
      // ただし、ベッド表示域の幅には最小値があり、それ以上、幅は狭くしません
      const mainWidth = this.getScheduleMainContentEl()?.clientWidth || 0;
      if (mainWidth > DEF_LIST_WIDTH_MIN + DEF_BEDTITLE_WIDTH) {
        //Window幅が最小の表全体幅より大きい場合
        // ベッド表示領域幅 = Window幅 - タイトル領域幅
        this.listWidth =
          mainWidth - (DEF_BEDTITLE_WIDTH - DEF_SCROLLBAR_WIDTH);
      } else {
        // Window幅がどうなっても最小の幅は確保します
        this.listWidth = DEF_LIST_WIDTH_MIN;
      }
      //---------------------------------------------------
      //ヘッダー領域(患者情報表示領域)の初期化
      this.setHeaderDispDefaultMode();

      //---------------------------------------------------
      //シャッター設定

      if (this.listWidth > this.totalWidth) {
        //表のトータル幅を超えていた場合は、トータル幅を採用
        this.listWidth = this.totalWidth;
      }

      //枠のサイズ、位置計算
      //usage: cal(x1,y1,w1 ,h1,h2 ,h3 ,h4 ,h9,w5 ,w10)
      this.calSizeAndPosition(
        0,
        0,
        DEF_BEDTITLE_WIDTH * this.elemResizeValue,
        DEF_HEADER_HEIGHT,
        this.bedAreaHeight,
        90,
        0,
        DEF_SCROLLBAR_WIDTH,
        this.listWidth,
        DEF_SCROLLBAR_WIDTH
      );
      //※この段階では表示が隠れているので、実際に数値を適用しない(calSizeAndPosition()のペアの処理this.setElem()を呼ばない)
      //シャッター各要素への位置＆サイズの設定処理
      this.setInitShutterElem();

      this.scrollAreaDes = this.getScopedElementById("scroll_area");
      this.scrollAreaDes.addEventListener(
        "scroll",
        this.handleScroll,
        false
      );
      this.getScheduleOwnerWindow().addEventListener("orientationchange", this.orientationchange);
      this.getScheduleOwnerDocument().addEventListener('preshow', this.preShowCallBack);
    },
    beforeUnmount() {
      if (this.getRefresh && this.getRefresh.status === true) {
        this.setSaveFilterData([]);
        this.changeKey();
      }
      if (this.dayHeaderLayoutRafId) {
        cancelAnimationFrame(this.dayHeaderLayoutRafId);
        this.dayHeaderLayoutRafId = 0;
      }
      if (this.dayHeaderLayoutTimerId) {
        clearTimeout(this.dayHeaderLayoutTimerId);
        this.dayHeaderLayoutTimerId = 0;
      }
      this.detachScheduleHeaderResizeEndListener();
      if (this.scheduleHeaderResizeRafId) {
        cancelAnimationFrame(this.scheduleHeaderResizeRafId);
        this.scheduleHeaderResizeRafId = 0;
      }
      this.clearHolidays(); // storeの休日マスタをクリア
      detachKendoPopupEventHandlers(this.$el?.ownerDocument || null);
      // mod #10601 スケジュール表動作不正 start
      // #8844 スケジュール表画面表示後の画面遷移でスクリプトエラーが大量に発生する 林峻峰 start
      if (this.setArea6Width && this.setArea6Width !== 0) {
        clearInterval(this.setArea6Width);
        this.setArea6Width = null;
      }
      if (this.intervalKurNumId && this.intervalKurNumId !== 0) {
        clearInterval(this.intervalKurNumId);
        this.intervalKurNumId = null;
      }
      if (this.setArea6Id && this.setArea6Id !== 0) {
        clearInterval(this.setArea6Id);
        this.setArea6Id = null;
      }
      if (this.kurHeadWaitId && this.kurHeadWaitId !== 0) {
        clearInterval(this.kurHeadWaitId);
        this.kurHeadWaitId = null;
      }
      if (this.shutterIntervalId && this.shutterIntervalId !== 0) {
        clearInterval(this.shutterIntervalId);
        this.shutterIntervalId = null;
      }
      if (this.intervalId && this.intervalId !== 0) {
        clearInterval(this.intervalId);
        this.intervalId = null;
      }
      if (this.relocateId && this.relocateId !== 0) {
        clearInterval(this.relocateId);
        this.relocateId = null;
      }
      if (this.scrollIntervalId && this.scrollIntervalId !== 0) {
        clearInterval(this.scrollIntervalId);
        this.scrollIntervalId = null;
      }
      // mod #10601 スケジュール表動作不正 end
      // #8844 スケジュール表画面表示後の画面遷移でスクリプトエラーが大量に発生する 林峻峰 end
      // 次回標示時のWatch発火の為、表示ベッド数の初期化を行う
      this.resetBedDispCount();
      this.getScheduleOwnerWindow().removeEventListener("resize", this.loadResizeMethod, false);
      this.getScheduleOwnerWindow().removeEventListener("orientationchange", this.orientationchange);
      // FNSI-add 性能を最適化する 徐 start
      this.scrollAreaDes.removeEventListener(
        "scroll",
        this.handleScroll,
        false
      );
      // FNSI-add 性能を最適化する 徐 end
      EventBus.$off("refresh", this.refreshData);

      // 印刷パラメータ要求
      EventBus.$off("requestReportParams", this.requestrReportParams);
      this.treatDateDim = null;
      this.dayHeaderElems = null;
      this.kurHeaderElems = null;
      this.resizeElems = null;
      this.getScheduleOwnerDocument().removeEventListener('preshow', this.preShowCallBack);
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
      this.setIsPatientEnabled(false)
      window.removeEventListener("beforeprint", this.beforePrint);
    },

    methods: {
    requestViewForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    getScopedElementById(id) {
      return getScopedElementById(id, this);
    },
    getScopedElementsByClassName(className) {
      return getScopedElementsByClassName(className, this);
    },
    getScopedQuery(selector) {
      return queryScopedSelector(selector, this);
    },
    getScopedQueryAll(selector) {
      return queryScopedSelectorAll(selector, this);
    },
    getScheduleOwnerDocument() {
      return this.$el?.ownerDocument || (typeof document !== "undefined" ? document : null);
    },
    getScheduleOwnerWindow() {
      return this.getScheduleOwnerDocument()?.defaultView || (typeof window !== "undefined" ? window : null);
    },
    dispatchScheduleResizeEvent() {
      const ownerWindow = this.getScheduleOwnerWindow();
      ownerWindow.dispatchEvent(new ownerWindow.Event("resize"));
    },
    getScheduleOrientation() {
      return this.getScheduleOwnerWindow()?.orientation;
    },
    createScheduleElement(tagName) {
      return this.getScheduleOwnerDocument().createElement(tagName);
    },
    getScheduleElementFromPoint(clientX, clientY) {
      return this.getScheduleOwnerDocument().elementFromPoint?.(clientX, clientY) || null;
    },

      getDayGridRef() {
        return this.$refs.ref_kendoDay || null;
      },
      getKurGridRef() {
        return this.$refs.ref_kendoKur || null;
      },
      getDayGridWidget() {
        return this.getDayGridRef()?.gridWidget?.() || this.getDayGridRef()?.kendoWidget?.() || null;
      },
      getKurGridWidget() {
        return this.getKurGridRef()?.gridWidget?.() || this.getKurGridRef()?.kendoWidget?.() || null;
      },
      getDayGridHeaderEl() {
        return this.getDayGridRef()?.gridHeaderEl?.() || this.getDayGridWidget()?.wrapper?.find?.('.k-grid-header')?.[0] || null;
      },
      getKurGridHeaderEl() {
        return this.getKurGridRef()?.gridHeaderEl?.() || this.getKurGridWidget()?.wrapper?.find?.('.k-grid-header')?.[0] || null;
      },
      getDayGridContentEl() {
        return this.getDayGridRef()?.gridContentEl?.() || this.getDayGridWidget()?.content?.[0] || null;
      },
      getKurGridContentEl() {
        return this.getKurGridRef()?.gridContentEl?.() || this.getKurGridWidget()?.content?.[0] || null;
      },
      getScheduleGridHeaderEls() {
        return [this.getDayGridHeaderEl(), this.getKurGridHeaderEl()].filter(Boolean);
      },
      getScheduleGridContentEls() {
        return [this.getDayGridContentEl(), this.getKurGridContentEl()].filter(Boolean);
      },
      resetScheduleGridContentHeight() {
        this.getScheduleGridContentEls().forEach((element) => {
          element.style.height = "0px";
        });
      },
      getScheduleGridContentExpanders() {
        return [this.getDayGridRef(), this.getKurGridRef()].flatMap((gridRef) => gridRef?.gridContentExpanderEls?.() || []);
      },
      getScheduleMainContentEl() {
        return this.$el?.querySelector?.('#main-content-area')
          || getMainContentAreaElement(this.$el || this.getScheduleOwnerDocument())
          || null;
      },
      handleScroll: function(e) {
        this.getScopedElementById("id_area5").scrollLeft = e.target.scrollLeft;
        this.getScopedElementById("area2_4_header").scrollTop =
          e.target.scrollTop;
      },
      //add FutreNetWeb+SI課題管理No4221対応 呉 start
      senntakuKaijyou(){
        //trueの時(ボタンが押された)、移動状態だった場合、移動解除を行う
        if (null !== this.movingChipElem) {
          //セル移動中だった場合

          // 選択状態表示（緑枠線）解除
          this.removeCheckClass();
          // チップを削除
          this.movingChipElem.parentNode.removeChild(this.movingChipElem);
          // もう移動が終わったのでポインタを初期化
          this.movingChipElem = null;
        } else if (null !== this.movingBlockElem) {
          //ブロック移動中だった場合
          // ブロックを削除
          if (this.movingBlockElem.parentNode) {
            this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
          }
          // もう移動が終わったのでポインタを初期化
          this.movingBlockElem = null;
        }
        //点滅停止(移動可能範囲の点滅:仕様上、無効になっていて、表示に影響を与えてない場合があります)
        this.setOpaSwitch("off");
      },
      //add FutreNetWeb+SI課題管理No4221対応 呉 end
      ...mapActions("schedule-list", [
        "initStore", //ストアの初期化(スケジュール表用のストアの初期化)
        "setNameSetting", //名前表示設定をストアにセットする(クールコンポーネントへの通知用)
        "setUnmatchSetting", //不一致表示設定をストアにセットする(クールコンポーネントへの通知用)
        "setPlanSetting", //予定表示設定をストアにセットする(クールコンポーネントへの通知用)
        "setPlanSettingMainteWater", //定期点検・水質検査予定表示設定をストアにセットする(クールコンポーネントへの通知用)        
        "checkData", //データ存在チェック処理(指定された日付のデータがストアに存在するかを確認する)
        "setHeaderInfo", //ヘッダ表示情報をセットする(ヘッダー部への受け渡し用)
        "setBedIdDim", //idをストアにセット(あとの処理をクールコンポーネントに委譲する)
        "setBedIdDimBlock", //idをストアにセット(あとの処理をクールコンポーネントに委譲する)
        "setBedIdDimForDelete", //idをストアにセット(クールコンポーネントに委譲する:削除処理)
        "setClearPatInfoOnBed", //ストアから患者情報を削除する処理
        "swapCellInfo", //ストアのベッド確定エリアのセル情報を入れ替える
        "setBedNotYet", //ストアのベッド未登録エリアのデータを設定する
        "setKurNotYet", //ストアのクール未登録エリアのデータを設定する
        "setBedAndKurInfo", //ベッドとクールの取得設定
        // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 start
        "setReportParamKurCd", //選択クールの取得設定
        // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 end
        "setBedDispInfo", //ベッド表示設定情報(ベッドグループ)の受け渡し
        "setOpaSwitch", //点滅処理設定をする
        "setHeaderSelectionFlag", //ヘッダー領域の操作メニューの操作(移動処理時に消すため)
        "updateScheduleInfoOnDB", //スケジュール表データ(ベッド情報)の更新
        "setReportParam", // 帳票用パラメータの設定
        // FNSI-add 現行改善対応425 徐 start
        "getPatExamMain",
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
        "getPatRadMain",
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
        //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
        "setScrollLeftWitch",
        "setScrollTopWitch",
        //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
        // FNSI-add 現行改善対応425 徐 end
        // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
        "setIsPatientEnabled",
        "setIsScheduleEnabled"
        // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
      ]),
      ...mapActions("send-condition/scale", ["setSelectOrdNo", "setInputPatId"]),
      ...mapMutations("schedule-list", [
        "setHolidayDispStateFlag", //表示条件設定の休日表示の状態の設定(true:休日を表示)
        "setDataLoadFlag", //データ読み込みフラグの値設定
        "resetBedIdDimForDelete", //idをストアにセット(クールコンポーネントに委譲する:削除処理)の変数初期化
        "resetBedDispCount", //Watch発火の為、表示ベッド数の初期化を行う
        "setDispDataToStore", //表示条件設定の休日表示の状態の設定(true:休日を表示)
        "setOtherSchedule", //その他の予定データリストを設定
        // add FNSI-改修内容フィルタ条件設定 房 start
        "setSaveFilterData", // フィルタ条件データ
        // add FNSI-改修内容フィルタ条件設定 房 end
        // FNSI-add 現行改善対応425 孫灝 20201118 start
        "setFacilitySetting1007_4SelectedVal",  // 施設設定マスタから 透析予定日変更時検査予定変更機能 の設定値
        "setFacilitySetting1008_4SelectedVal",  // 施設設定マスタから 透析予定日変更時一般撮影検査依頼変更機能 の設定値
        // FNSI-add 現行改善対応425 孫灝 20201118 end

        // add FNSI 1006 No.426 start --孙灏 20201216
        "setFacilitySetting3005_4SelectedVal", // 透析予定日変更時患者イベント変更機能 の設定値
        // add FNSI 1006 No.426 end --孙灏 20201216
        //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
        "setScrollLeftWitch",
        "setScrollTopWitch"
        //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end

      ]),
      ...mapActions("treatment-record/common", ["setOrdNoForSideBarRecord", "setOrd"]),
      ...mapActions("facility-calendar", ["setScheduleListDayView"]),
      // 共通ローダー設定
      ...mapActions("loading-screen", {
        setLoadingScreenVisible: "setLoadingScreenVisible",
        setLoadingScreenMessage: "setLoadingScreenMessage",
        resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
      }),
      ...mapGetters("app", ["getQueryParameters"]),
      ...mapActions("app", ["setQueryParameters"]),
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
      ...mapActions("exam-request/list", ["setExamDeadline"]),
      ...mapActions("rad-request/list", ["setRadDeadline"]),
    	//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
      ...mapActions("mst-holiday", [
        "fetchHolidays",
        "clearHolidays"
      ]),
      preShowCallBack(event) {
        const dialog = getOnsAlertDialogFromEvent(event);
        const buttons = getOnsAlertDialogFooterItems(dialog);
        if (buttons[0]) {
          buttons[0].style.display = 'flex';
        }
      },
      /**
       * 初期設定反映
       */
      defaultSetting() {
        let initData = this.createInitData();
        let editData = deepCopy(initData);

        // デフォルト設定を store から取得
        const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_SCHEDULE_LIST.KEY_NAME]);
        // 初期設定がある場合に処理を実施
        if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
          if (defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION]) {
            editData.dispTermNum = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_DISP_WEEK_DURATION];
          }
          if (typeof defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY] !== "undefined") {
            editData.dispHolidayFlag = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_HOLIDAY];
          }
          // クール
          const selectedKurCds = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_SELECTED_KUR_LIST];
          // デフォルト値：kurCd -> 表示用：indexに変換する
          const convertSelectedKurIndex = selectedKurCds
            .map(cd => this.getSelectKurCds.findIndex(item => item === cd) + 1)
            .filter(v => v !== 0);
          // 表示用変数へ設定する
          let tmpKurList = "";
          convertSelectedKurIndex.forEach((kurNo) => {
            tmpKurList = tmpKurList + String(kurNo) + ":";
          });
          editData.dispKurDimStr = tmpKurList.slice(0, -1);
          //  ベッドグループ
          if (defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD] === "0") {
            editData.dispGroupDimStr = "all";
          } else {
            if (this.roomBedGroupNamesForOption.some(rbr => rbr.bedCd === defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD])) {
              editData.dispGroupDimStr = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_BED_GROUP_CD];
            }
            else{
              editData.dispGroupDimStr = "all";
            }
          }
          if (defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME] != null) {
            editData.dispNameFlag = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_NAME];
          }
          if (defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH] != null) {
            editData.dispUnmatchFlag = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_UNMATCH];
          }
          if (defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN] != null) {
            editData.dispPlanFlag = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN];
          }
          if (defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER] != null) {
            editData.dispPlanMainteWaterFlag = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_CHK_PLAN_MAINTE_WATER];
          }
          if (defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE] != null) {
            editData.dispUsageGuide = defaultCondition[KEY_NAME_SCHEDULE_LIST.KEY_NAME_IS_SHOW_GUIDE];
          }
        }

        // 設定を適用
        this.applyStatus(initData, editData);
      },

      idHidden() {
        if (!this.getHeaderDispInfo) {
          return false;
        }
        return this.getHeaderDispInfo.dialysisState > 2 && this.getHeaderDispInfo.dialysisState < 7;
      },
      //Windowリサイズ用のイベント
      loadResizeMethod() {
        if (this.resizeTimer !== false) {
          clearTimeout(this.resizeTimer);
        }
        this.resizeTimer = setTimeout(() => {
          //表の横幅の変更
          this.resizeList();
        }, 100);
      },
      // add by shiyw for 6119
      getSijisyaDropdownRef() {
        return this.$refs?.sijisyaDropdown || null;
      },
      hasSijisyaPopupScroller() {
        return this.getSijisyaDropdownRef()?.hasPopupScroller?.() || false;
      },
      applySijisyaPopupHeight(height) {
        this.getSijisyaDropdownRef()?.applyPopupHeight?.(height);
      },
      orientationchange(){
        if (this.hasSijisyaPopupScroller()) {
          const orientation = this.getScheduleOrientation();
          if(orientation == 180 || orientation == 0){
            this.applySijisyaPopupHeight("200px");
          }else if(orientation == 90 || orientation == -90){
            this.applySijisyaPopupHeight("150px");
          }
        }
      },
      // dropDownを開いた時にデータに応じて表示枠を広げる
      addMaxContentStyle(event) {
        setTimeout(() => {
          const popups = document.querySelectorAll('.k-list-container.k-popup');
          for (let popup of popups) {
            if (window.getComputedStyle(popup).display !== 'none') {
              popup.style.setProperty('width', 'max-content', 'important');
              popup.style.setProperty('min-width', '96%', 'important');
              break;
            }
          }
        }, 50);
        const orientation = this.getScheduleOrientation();
        if(orientation == 180 || orientation == 0){
          this.applySijisyaPopupHeight("200px");
        }else if(orientation == 90 || orientation == -90){
          this.applySijisyaPopupHeight("150px");
        }
      },
      //治療患者リスト登録用
      ...mapMutations("pat-info", ["updateTreatmentPatList", "setSrcFuncName"]),
      /**
       * 確定領域の高さ計算
       * @param bedCount ベッド数
       * @return 確定領域の高さ
       */
      calBedAreaHeight(bedCount) {
        const bedAreaHeight = bedCount * DEF_CELL_HEIGHT;
        return bedAreaHeight;
      },
      /**
       表の横幅サイズ変更
       */
      resizeList() {
        // 高さの調整
        this.resizeListHeight();

        const mainWidth = this.getScheduleMainContentEl()?.clientWidth || 0;
        if (mainWidth > DEF_LIST_WIDTH_MIN + DEF_BEDTITLE_WIDTH) {
          this.listWidth =
            mainWidth - DEF_BEDTITLE_WIDTH * this.elemResizeValue - 2;
        } else {
          this.listWidth = DEF_LIST_WIDTH_MIN;
        }

        if (this.listWidth > this.totalWidth) {
          //表のトータル幅を超えていた場合は、トータル幅を採用
          this.listWidth = this.totalWidth;
        }

        // スクロールバーが出ているときは、-17する
        // モバイル環境の場合、又は横幅に余裕がある場合は、縦スクロールバーが出ていても除外する
        // -1は、スクロールバー表示から非表示になる時に、-17しないための補正
        if (
          this.getScopedElementById("scroll_area").clientHeight <
          this.getScopedElementById("area2_4_header").scrollHeight - 1 &&
          this.listWidth !== this.totalWidth &&
          !(this.androidFlg || this.iosFlg)
        ) {
          this.listWidth -= DEF_SCROLLBAR_WIDTH;
        }

        //枠のサイズ、位置計算
        this.calSizeAndPosition(
          0,
          0,
          DEF_BEDTITLE_WIDTH * this.elemResizeValue,
          DEF_HEADER_HEIGHT,
          this.bedAreaHeight,
          this.notYetAreaHeightBed,
          this.notYetAreaHeightKur,
          DEF_SCROLLBAR_WIDTH,
          this.listWidth,
          DEF_SCROLLBAR_WIDTH
        );
        //各要素への位置＆サイズの設定処理
        this.setElem();

      },

      /**
       * DBデータ取得処理
       *  画面初期呼び出し時に以下のデータを読み込みます
       *  ・ベッド、クール、ベッドグループの取得
       *  ・日毎のデータ取得
       */
      async dbProcessing() {
        this.setLoadingScreenVisible(true);
        let baseDate = null;
        if (this.scheduleListDayView !== null) {
          baseDate = dayjs(this.scheduleListDayView).format("YYYYMMDD")
        }
        //ベッド、クール、ベッドグループの取得
        await this.getBaseDataFromDB(event);

        // 休日マスタの休日を取得
        await this.fetchHolidays(this.getFacilityCd);

        // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou start
        const saveData = this.getSaveFilterData;
        if (saveData && saveData.settingJsonBefore && saveData.settingJsonAfter) {
          await this.initStore({
            facilityCd: this.getFacilityCd,
            dayNum: this.dayMax,
            overFlowDayNum: this.overFlowDayNum,
            baseDate: this.getSettingStartDate()
          });
        } else {
          // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou end
          //日毎のデータ取得
          await this.loadScheduleData({
            facilityCd: this.getFacilityCd,
            dayNum: this.dayMax,
            overFlowDayNum: this.overFlowDayNum,
            baseDate: baseDate
          });
          //表全体のデータの設定
          this.setListData(baseDate);
        }
        this.setScheduleListDayView(null);
      },

      /**
       * チェックボックスの値の設定
       * @param id 要素ID
       * @param flagValue 設定値 true/false
       */
      setFlagOnCheckBox(id, flagValue) {
        const elem = this.getScopedElementById(id);
        elem.checked = flagValue;
      },

      /**
       * 表示条件設定を適用する
       * @param settingJsonBefore 適用する設定値(前)
       * @param settingJsonAfter 適用する設定値(後)
       */
      // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
      async applyStatus(settingJsonBefore, settingJsonAfter, changeFlg) {
      // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
        // 開始日付、又は表示期間が変更されたかのフラグ
        let dispRangeChangeFlg = false;
        // add #6050 スケジュール表の表示条件を変更した時の画面更新に時間がかかる 付 start
        this.closePopOver()
        // add #6050 スケジュール表の表示条件を変更した時の画面更新に時間がかかる 付 end
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);
        const flagJson = {};

        const keyList = Object.keys(settingJsonBefore);
        for (const key of keyList) {

          flagJson[key] = settingJsonBefore[key] === settingJsonAfter[key];

        }
        const afterData = settingJsonAfter;

        /* modify by chamaojia 2024-07-30 [10601] this part of the code moves forward --start */
        //名前表示設定
        //  姓のみ表示        dispNameFlag      true/false
        if (!flagJson.dispNameFlag) {
          await this.changeNameDispState(afterData.dispNameFlag);
        }
        //不一致表示設定
        //  不一致表示        dispUnmatchFlag   true/false
        if (!flagJson.dispUnmatchFlag) {
          await this.changeUnmatchDispState(afterData.dispUnmatchFlag);
        }
        //予定表示設定
        //  他の予定あり表示  dispPlanFlag      true/false
        if (!flagJson.dispPlanFlag) {
          await this.changePlanDispState(afterData.dispPlanFlag);
        }
        /* modify by chamaojia 2024-07-30 [10601] this part of the code moves forward --end */
        //  定期点検・水質検査予定あり表示  dispPlanMainteWaterFlag      true/false
        if (!flagJson.dispPlanMainteWaterFlag) {
          await this.changePlanMainteWaterDispState(afterData.dispPlanMainteWaterFlag);
        }
        // FNSI-add redmine、No.3924 徐 start
        this.kurNumIndex = afterData.dispKurDimStr;
        // FNSI-add redmine、No.3924 徐 end

        // add FNSI-redMine #4250対応  陳 start
        if (this.kurNumIndex) {
          this.kurNumCount = this.kurNumIndex.split(":").length;
        }
        // add FNSI-redMine #4250対応  陳 end

        //開始日付設定
        //  表示開始日        startDate         yyyy/mm/dd
        // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
        if(!changeFlg && !flagJson.startDate){
          dispRangeChangeFlg = true;
          this.dispStartDateForSetting = dayjs(this.$route.params.startDate).format("YYYY-MM-DD");
          await this.changeStartDate();
        } else if(changeFlg && !flagJson.startDate){
          dispRangeChangeFlg = true;
          this.dispStartDateForSetting = afterData.startDate;
          await this.changeStartDate();
        }
        // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
        //表示期間設定
        //  表示期間          dispTermNum       1 or 2 or 3
        // mod FNSI-改修内容フィルタ条件設定 房 start
        if (!flagJson.dispTermNum) {
          // mod FNSI-改修内容フィルタ条件設定 房 end
          dispRangeChangeFlg = true;
          this.dispWeek = afterData.dispTermNum;
          //※changeStartDateの中で呼んでいるので、changeStartDateが実行される状況では再度呼び出さない
        }
        //休日表示設定
        //  休日表示          dispHolidayFlag   true/false
        // ※表示期間が変更される場合、休日表示設定に変更が無くても、非表示状態の場合は処理を発火させる
        if (!flagJson.dispHolidayFlag || (!afterData.dispHolidayFlag && dispRangeChangeFlg)) {
          this.holidayFlag = afterData.dispHolidayFlag;
          await this.changeHolidayDispState();
        }
        //クール表示設定
        //  クール            dispKurDimStr        選択されているクールのindex(1~)
        //表示条件変更のOKボタン押下時(表示期間、クール、休日表示のいずれかの検索条件を変更)、または、他の画面から画面遷移の場合
        if (
          !flagJson.dispKurDimStr ||
          !flagJson.dispHolidayFlag ||
          (!flagJson.dispTermNum && flagJson.startDate) ||
          !changeFlg
        ) {
          await this.changeKurDispState(settingJsonAfter.dispKurDimStr);
          // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 start
          this.setReportParamKurCd(settingJsonAfter.dispKurDimStr);
          // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 end
        }

        // fix FNSI-bug 孫灝 20201106 start -->
        // 画面更新(データの再取得)
        await this.changeDispTerm(0);
        // fix FNSI-bug 孫灝 20201106 end -->

        //ベッドグループ表示設定
        //  ベッドグループ    dispGroupDimStr      選択されているベッドグループのindex(1~) and "all"
        if (!flagJson.dispGroupDimStr){
          await this.changeBedGroupState(settingJsonAfter.dispGroupDimStr + "");
        }
        //凡例表示設定
        if (!flagJson.dispUsageGuide) {
          this.isShowUsageGuide = afterData.dispUsageGuide;
        }

        // add FNSI-改修内容フィルタ条件設定 房 start
        const nowBadCount = this.getBedDispCount;
        this.setSaveFilterData({settingJsonBefore,settingJsonAfter,nowBadCount});
        // add FNSI-改修内容フィルタ条件設定 房 end

        //開始位置の設定
        this.$nextTick(() => {
          this.adjustElemSize();
          this.setScrollStartPos();
        });

        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);

      },
      /**
       * シャッターを開ける
       *
       */
      openShutter() {
        const scheduleItemThis = this;
        this.setShutterOpacityVal = 0;
        clearInterval(this.shutterIntervalId);
        this.shutterIntervalId = setInterval(
          function() {
            scheduleItemThis.setShutterOpacityVal -= 0.25;
            if (scheduleItemThis.setShutterOpacityVal < 0) {
              //完全に開いたので終了
              scheduleItemThis.setShutterOpacityVal = 0;
              clearInterval(scheduleItemThis.shutterIntervalId);
            }
            for (let i = 0; i < DEF_ELEMNUM; i++) {
              const idStr = `id_coverarea${i + 1}`;
              const elem = this.getScopedElementById(idStr);

              if (null !== elem) {
                elem.style.opacity = scheduleItemThis.setShutterOpacityVal;
                if (scheduleItemThis.setShutterOpacityVal === 0) {
                  //シャッターの役割を終えたので背後に下がらせます
                  elem.style.zIndex = -1;
                }
              }
            }
          }.bind(scheduleItemThis),
          10);
      },

      /**
       * メッセージダイアログを閉じた後に後続処理を実行
       * Vue3 ではダイアログ close と同 tick の click 再実行が重なると、
       * close 完了前に背後のスケジュール click が再入してダイアログが残ったように見えるため、
       * close 完了後に続きの処理を流す。
       * @param {Function|null} action 実行する後続処理
       * @param {Object} options オプション
       * @param {boolean} options.holdFacilityDialogOpenFlg facilitySettingDialogOpenFlg を callback 実行中だけ立てるか
       */
      runAfterMessageDialogClose(action = null, options = {}) {
        const { holdFacilityDialogOpenFlg = false } = options;
        this.messageDialogInfo.isDialogVisible = false;
        this.$nextTick(async () => {
          if (holdFacilityDialogOpenFlg) {
            this.facilitySettingDialogOpenFlg = true;
          }
          try {
            if (typeof action === "function") {
              await action();
            }
          } finally {
            if (holdFacilityDialogOpenFlg) {
              this.facilitySettingDialogOpenFlg = false;
            }
          }
        });
      },

      /**
       * メッセージダイアログの結果イベント
       * @param 押下されたボタン
       */
      confirm(e) {
        if (this.messageDialogInfo.dialogNo === DEF_DIALOG_UNMATCH) {
          //不一致の移動確認の結果
          if (e === "OK") {
            //OKボタンが押された
            //  チップの移動終了処理
            this.runAfterMessageDialogClose(async () => {
              if (this.isReplaceSchedulePreProcessing === "1") {
                await this.replaceSchedulePreProcessing();
                this.isReplaceSchedulePreProcessing = "0";
              } else {
                let ele;
                if (this.headerFlg) {
                  ele = this.getScopedElementById("kendo_day");
                } else {
                  ele = this.getScopedElementById("id_maindiv");
                }
                ele?.click?.();
              }
            }, { holdFacilityDialogOpenFlg: true });
          } else {
            this.restFacilitySettingDialogsOpenedFlg();
            EventBus.$emit("changeMismatchVa", false);
            EventBus.$emit("changeMismatchInfection", false);
            EventBus.$emit("changeMismatchTreatment", false);
          }
          this.clickEventNowFlag = false;
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_REPLACE) {
          if (e === "OK") {
            this.runAfterMessageDialogClose(async () => {
              await this.replaceSchedulePreProcessing();
            });
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_REPLACEUNMATCH) {
          if (e === "OK") {
            this.runAfterMessageDialogClose(async () => {
              await this.replaceSchedule();
            });
          } else {
            this.restFacilitySettingDialogsOpenedFlg();
          }
          this.clickEventNowFlag = false;
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_1007_4 && !this.headerFlg) {
          this.isOneOrSed = e;
          switch(e) {
            case 1:
            case 2:
            case 3: {
              this.setFacilitySetting1007_4SelectedVal(e);
              const ele = this.getScopedElementById("id_maindiv");
              this.runAfterMessageDialogClose(() => ele?.click?.(), { holdFacilityDialogOpenFlg: true });
              break;
            }
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_1008_4 && !this.headerFlg) {
          this.isOneOrSed = e;
          switch(e) {
            case 1:
            case 2:
            case 3: {
              this.setFacilitySetting1008_4SelectedVal(e);
              const ele = this.getScopedElementById("id_maindiv");
              this.runAfterMessageDialogClose(() => ele?.click?.(), { holdFacilityDialogOpenFlg: true });
              break;
            }
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_2007_4 && !this.headerFlg) {
          if (e === "OK") {
            this.runAfterMessageDialogClose(() => {
              const ele = this.getScopedElementById("id_maindiv");
              ele?.click?.();
            }, { holdFacilityDialogOpenFlg: true });
          } else {
            this.restFacilitySettingDialogsOpenedFlg();
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_2008_4 && !this.headerFlg) {
          if (e === "OK") {
            this.runAfterMessageDialogClose(() => {
              const ele = this.getScopedElementById("id_maindiv");
              ele?.click?.();
            }, { holdFacilityDialogOpenFlg: true });
          } else {
            this.restFacilitySettingDialogsOpenedFlg();
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_3005_4 && !this.headerFlg) {
          switch(e) {
            case 1:
            case 2:
            case 3: {
              this.setFacilitySetting3005_4SelectedVal(e);
              const ele = this.getScopedElementById("id_maindiv");
              this.runAfterMessageDialogClose(() => ele?.click?.(), { holdFacilityDialogOpenFlg: true });
              break;
            }
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_1007_4 && this.headerFlg) {
          this.isOneOrSed = e;
          switch(e) {
            case 1:
            case 2:
            case 3: {
              this.setFacilitySetting1007_4SelectedVal(e);
              const ele = this.getScopedElementById("kendo_day");
              this.runAfterMessageDialogClose(() => ele?.click?.(), { holdFacilityDialogOpenFlg: true });
              break;
            }
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_1008_4 && this.headerFlg) {
          this.isOneOrSed = e;
          switch(e) {
            case 1:
            case 2:
            case 3: {
              this.setFacilitySetting1008_4SelectedVal(e);
              const ele = this.getScopedElementById("kendo_day");
              this.runAfterMessageDialogClose(() => ele?.click?.(), { holdFacilityDialogOpenFlg: true });
              break;
            }
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_3005_4 && this.headerFlg) {
          switch(e) {
            case 1:
            case 2:
            case 3: {
              this.setFacilitySetting3005_4SelectedVal(e);
              const ele = this.getScopedElementById("kendo_day");
              this.runAfterMessageDialogClose(() => ele?.click?.(), { holdFacilityDialogOpenFlg: true });
              break;
            }
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_1007_4_2) {
          this.isOneOrSed = e;
          switch(e) {
            case 1:
            case 2:
            case 3:
              this.setFacilitySetting1007_4SelectedVal(e);
              this.runAfterMessageDialogClose(async () => {
                await this.replaceSchedulePreProcessing();
              }, { holdFacilityDialogOpenFlg: true });
              break;
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_1008_4_2) {
          this.isOneOrSed = e;
          switch(e) {
            case 1:
            case 2:
            case 3:
              this.setFacilitySetting1008_4SelectedVal(e);
              this.runAfterMessageDialogClose(async () => {
                await this.replaceSchedulePreProcessing();
              }, { holdFacilityDialogOpenFlg: true });
              break;
            default:
              break;
          }
        } else if (this.messageDialogInfo.dialogNo === DEF_DIALOG_FACILITY_SETTING_3005_4_2) {
          switch(e) {
            case 1:
            case 2:
            case 3:
              this.setFacilitySetting3005_4SelectedVal(e);
              this.runAfterMessageDialogClose(async () => {
                await this.replaceSchedulePreProcessing();
              }, { holdFacilityDialogOpenFlg: true });
              break;
            default:
              break;
          }
        }
        if (this.messageDialogInfo.messageCd === DEF_DIALOG_MSG_33) {
          if (e === "OK") {
            this.examDeadlineSelectedVal = "OK";
            this.radDeadlineSelectedVal = "OK";
          }
        }
      },

      /**
       * 未登録エリアの最大値確認処理
       */
      checkNotYetAreaMax() {
        let areaMaxNotYetBed = 0;
        let areaMaxNotYetKur = 0;

        for (let d = 1; d <= this.dayMax; ++d) {
          // 2週＊7 = 初回は14回
          for (let k = 1; k <= this.kurNum; k++) {
            // 初回は10回
            let setNum = this.propsJBedNotYet[d][k].length - 1;
            //--------------------------------------
            //ベッド未登録領域の確認
            for (let b = 1; b <= this.propsJBedNotYet[d][k].length; b++) {
              if (null === this.propsJBedNotYet[d][k][b]) {
                setNum = b - 1;
                break;
              }
            }
            if (setNum > areaMaxNotYetBed) {
              areaMaxNotYetBed = setNum;
            }
            //--------------------------------------
            //クール未登録領域の確認
            setNum = this.propsJKurNotYet[d][k].length - 1;
            for (let b = 1; b <= this.propsJKurNotYet[d][k].length; b++) {
              if (null === this.propsJKurNotYet[d][k][b]) {
                setNum = b - 1;
                break;
              }
            }
            if (setNum > areaMaxNotYetKur) {
              areaMaxNotYetKur = setNum;
            }
          }
        }

        // mod FNSI-改修内容フィルタ条件設定 孫灝 20201014 start
        // 未登録の行，最小に1行を保留する
        areaMaxNotYetBed = areaMaxNotYetBed == 0 ? 1 : areaMaxNotYetBed;
        areaMaxNotYetKur = areaMaxNotYetKur == 0 ? 1 : areaMaxNotYetKur;
        // mod FNSI-改修内容フィルタ条件設定 孫灝 20201014 end

        this.areaMaxNotYetBed = areaMaxNotYetBed;
        this.areaMaxNotYetKur = areaMaxNotYetKur;
        this.dispNumNotYetBed = areaMaxNotYetBed;
        this.dispNumNotYetKur = areaMaxNotYetKur;

        //未登録エリアの表示高さ変更
        this.changeNotYetAreaCellHeight();
      },
      /**
       * 表示条件設定ポップオーバーの表示処理
       */
      showPopoverSetting(event, direction, coverTarget) {
        this.popoverTarget = event;
        this.popoverDirection = direction;
        this.popoverCoverTarget = coverTarget;
        if (!this.isSetting && this.selectedKurIndexList.length === 0) {
          // 初期値を設定※クールのみ表示している全ての項目を選択状態へ
          this.setSelectedIndexList();
        }

        this.setPopoverData(event, direction, coverTarget);

        this.popoverVisible = true;
      },
      /**
       * 未登録エリアの表示高さ変更
       * 分配ルール:
       *  各エリアに最低1は分配する(設定値が0,1の時はその限りではない)
       *  それぞれに1分配した後の余りを、ベッド未登録エリアから分配していく
       *  ただし、表示にもうそれ以上の行が必要ない場合は分配しない
       */
      async changeNotYetAreaCellHeight() {
        // 一時変数
        let heightBedNotYet = this.areaMaxNotYetBed; //使用行数(ベッド未登録)の一時変数
        let heightKurNotYet = this.areaMaxNotYetKur; //使用行数(クール未登録)の一時変数

        //実際の高さの計算
        heightBedNotYet *= DEF_CELL_HEIGHT;
        heightKurNotYet *= DEF_CELL_HEIGHT;

        //変数に格納
        this.notYetAreaHeightBed = heightBedNotYet;
        this.notYetAreaHeightKur = heightKurNotYet;

        //枠のサイズ、位置計算
        this.calSizeAndPosition(
          0,
          0,
          DEF_BEDTITLE_WIDTH * this.elemResizeValue,
          DEF_HEADER_HEIGHT,
          this.bedAreaHeight,
          this.notYetAreaHeightBed,
          this.notYetAreaHeightKur,
          DEF_SCROLLBAR_WIDTH,
          this.listWidth,
          DEF_SCROLLBAR_WIDTH
        );
        //各要素への位置＆サイズの設定処理
        this.setElem();

        // スクロールバー高さ設定
        this.resizeListHeight();
      },
      /**
       * ダミースケジュールのDB操作
       *@param ord_no オーダー番号
       *@param ope_mode 操作モード 1:生成 2:削除 3:削除&生成
       */
      async operateDummyScheduleOnDB(ord_no, ope_mode) {
        await ApiHelper.get("/scheduleList/operateDummySchedule", {
          ordNo: ord_no,
          opeMode: ope_mode
        })
          .then(response => {
            response;
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'operateDummyScheduleOnDB', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });
      },
      /**
       * 同一患者同一治療日同一クール同一治療方法のチェック
       * @param ordNoList オーダー番号リスト
       * @param treatDateList 治療日番号リスト
       * @param kurCdList クールコードリスト
       * @return true:存在する false:存在しない
       */
      async checkSamePatDayKurMode(ordNoList, treatDateList, kurCdList) {
        let retBool = false;
        const sendArrayStringOrdNo = ordNoList.join("-");
        const sendArrayStringTreatDate = treatDateList.join("-");
        const sendArrayStringKurCd = kurCdList.join("-");
        // FNSI-add redmine 4249 徐 start
        this.setLoadingScreenVisible(true);
        // FNSI-add redmine 4249 徐 end
        await ApiHelper.get("/scheduleList/checkSamePatDayKurMode", {
          ordNoList: sendArrayStringOrdNo,
          treatDateList: sendArrayStringTreatDate,
          kurCdList: sendArrayStringKurCd
        })
          .then(
            function(response) {
              retBool = response.data;
            }.bind(retBool)
          )
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'checkSamePatDayKurMode', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          })
          // FNSI-add redmine 4249 徐 start
          // 共通ローダー：表示終了
          .finally(() => this.setLoadingScreenVisible(false));
        // FNSI-add redmine 4249 徐 end
        return retBool;
      },
      //mod FNSI-7122 劉全航 start
      async checkSamePatAndNoKur(ordNo, treatDate){
        this.setLoadingScreenVisible(true);
        let result = false;
        await ApiHelper.get("/scheduleList/checkSamePatAndNoKur", {
          ordNo: ordNo,
          treatDate: treatDate
        }).then(function(response){
          result = response.data;
        }).catch(error => {
          getErrorMessage('ScheduleListMainItem.vue', 'checkSamePatAndNoKur', error);
          throw error;
        }).finally(() => this.setLoadingScreenVisible(false));
        return result;
      },
      //mod FNSI-7122 劉全航 end
      /**
       * ベッド患者の存在チェック
       * @param jsonObj ベッド患者情報
       *  ordNo オーダー番号
       *  treatDate 治療日
       *  kur_cd クールコード
       *  bed_cd ベッドコード
       * @return true:存在する false:存在しない
       */
      async checkPatExistance(jsonObj) {
        let ret = false;
        await ApiHelper.get("/scheduleList/checkPatExistance", {
          ordNo: jsonObj.ordNo,
          treatDate: jsonObj.treatDate,
          kurCd: jsonObj.kur_cd,
          bedCd: jsonObj.bed_cd,
          // mod #11493 スケジュール表　更新不正 関 start
          dialysisState: jsonObj.dialysisState,
          isDummy: jsonObj.isDummy
          // mod #11493 スケジュール表　更新不正 関 end
        })
          .then(
            function(response) {
              ret = response.data;
            }.bind(ret)
          )
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'checkPatExistance', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });

        if (!ret) {
          //存在しなかったということは、別の処理で書き換えられている可能性があるので
          //データを読み込み直します。

          //読み込み直し通知用のダイアログ表示
          this.messageDialogInfo.stringParams = [];
          this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_11;
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.isDialogVisible = true;
          this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

          this.msgPopUpFlag = true;
          this.clickEventNowFlag = false;

          //ヘッダー表示リセット
          this.setHeaderDispDefaultMode();

          //データ読み込み直し
          // mod 11493 スケジュール表　更新不正 関 start
          this.refreshData();
          // mod 11493 スケジュール表　更新不正 関 end
        }

        return ret;
      },
      /**
       * 不一致情報の取得
       * @param ordNo オーダー番号
       * @return true:存在する false:存在しない
       */
      async getPatInfoForCheck(ordNo) {
        let retJsonDim = null;
        await ApiHelper.get("/scheduleList/getPatInfoForCheck", {
          ordNo
        })
          .then(
            function(response) {
              retJsonDim = response.data.patInfo;
            }.bind(retJsonDim)
          )
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'getPatInfoForCheck', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });
        return retJsonDim[0];
      },
      /**
       * 空きベッド検索の呼び出し処理
       * @param facilityCd 施設コード
       * @param ordNo オーダー番号
       * @param patId 患者ID
       * @param bedCd ベッドコード
       * @param searchStartDate 治療日付(検索開始)
       * @param searchStartKurCd クールコード(検索開始)
       * @param searchStartKurCd クールコード(検索開始)
       * @param isMoveTreatDate 治療日移動フラグ(true:移動あり、false:移動なし) ※nullの場合はデフォルト:falseを使用
       * @return ヒット件数 0:置ける 0以外:置けない
       */
      async selectForSearchReservedBedOnDB(
        ordNo,
        patId,
        bedCd,
        searchStartDate,
        searchStartKurCd,
        isMoveTreatDate
      ) {
        let counter = 0;
        await ApiHelper.get("/scheduleList/selectForSearchReservedBed", {
          facilityCd: this.getFacilityCd,
          ordNo,
          patId,
          bedCd,
          searchStartDate,
          searchStartKurCd,
          isMoveTreatDate
        })
          .then(
            function(response) {
              counter = response.data.length;
            }.bind(counter)
          )
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'selectForSearchReservedBedOnDB', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });
        return counter;
      },
      /**
       * 画面印刷用設定
       */
      setPrintMode() {
        //usage: cal(x1,y1,w1 ,h1,h2 ,h3 ,h4 ,h9,w5 ,w10)
        this.calSizeAndPosition(
          0,
          0,
          DEF_BEDTITLE_WIDTH * this.elemResizeValue,
          DEF_HEADER_HEIGHT,
          3000,
          150,
          150,
          DEF_SCROLLBAR_WIDTH,
          6300,
          DEF_SCROLLBAR_WIDTH
        );
        //各要素への位置＆サイズの設定処理
        this.setElem();
      },
      /**
       * 画面通常設定
       */
      setNormalMode() {
        //usage: cal(x1,y1,w1 ,h1,h2 ,h3 ,h4 ,h9,w5 ,w10)
        this.calSizeAndPosition(
          0,
          0,
          DEF_BEDTITLE_WIDTH * this.elemResizeValue,
          DEF_HEADER_HEIGHT,
          500,
          100,
          100,
          DEF_SCROLLBAR_WIDTH,
          this.listWidth,
          DEF_SCROLLBAR_WIDTH
        );
        //各要素への位置＆サイズの設定処理
        this.setElem();
      },
      /**
       * 指定日スクロール移動の設定監視
       * */
      watchScrollSet() {
        const scheduleItemThis = this;
        clearInterval(this.intervalId);
        // add 10601 スケジュール表動作不正 関  start
        const startTime = Date.now();
        // add 10601 スケジュール表動作不正 関  end
        this.intervalId = setInterval(
          function() {
            const elem = this.getScopedElementById("scroll_area");
            // mod 6049 修正 chen start
            let daysTmp = 0;
            let dateList = [];
            // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
            let flg = false;
            // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
            scheduleItemThis.dayHeaderElems.forEach((item, index) => {
              if (item) {
                // mod bug #7928 修正 chen start
                const col = this.getScopedElementById(item.id);
                if (col && col.style.display !== "none") {
                // mod bug #7928 修正 chen end
                  dateList.push(Object.keys(scheduleItemThis.dispdata)[index - 1]);
                  // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
                  flg = true
                  // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
                }
              }
            });
            let dateTmp = this.dispStartDate.replaceAll("/", "");
            // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
            daysTmp = dateList.findIndex((item) => dateTmp === item)

            // 休日表示がOFF場合、スクロール位置計算用日数を取得する。
            if (!this.holidayFlag) {
              daysTmp = this.getScrollDayNum();
            }

            if (flg && daysTmp === -1 && (!this.holidayFlag && dayjs(scheduleItemThis.dispStartDate).day() === 0)) {
              clearInterval(scheduleItemThis.intervalId);
            }
            // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
            // mod 7928 修正 chen start
            let kurNum = scheduleItemThis.kurNumCount === 0 ? scheduleItemThis.kurNum : scheduleItemThis.kurNumCount;
            scheduleItemThis.scrollStartPosX = Math.floor(
              daysTmp *
              kurNum *
              // mod 10601 スケジュール表動作不正 関  start
              this.elemKurValue
              // mod 10601 スケジュール表動作不正 関  end
              );

            // スクロール位置を設定(指定位置がスクロール可能幅を超える場合、scrollLeftプロパティの仕様で設定可能な最大値(右端)に調整される)
            elem.scrollLeft = scheduleItemThis.scrollStartPosX;

            // スクロール位置が指定位置(scrollStartPosX)または右端に到達したか判定
            if (scheduleItemThis.scrollStartPosX >= 0 &&
                 (Math.abs(elem.scrollLeft - scheduleItemThis.scrollStartPosX) < 2 || this.isScrolledToRight(elem))) {
              if (this.getScrollTopWitch) {
                elem.scrollTop = this.getScrollTopWitch;
              }
              // スクロール位置が指定位置に到達した為、インターバル終了
              clearInterval(scheduleItemThis.intervalId);
            }
            // add 10601 スケジュール表動作不正 関  start
            let currentTime = Date.now();
            let elapsedTime = (currentTime - startTime) / 1000;
            if (elapsedTime >= 10) {
              clearInterval(scheduleItemThis.intervalId);
            }
            // add 10601 スケジュール表動作不正 関  end
          }.bind(scheduleItemThis),
          10
        );
      },

      /**
       * 右端までスクロールされているかを判定する
       * @param {HTMLElement} elem - スクロール対象の要素(例: this.getScopedElementById('scroll_area'))
       * @param {number} tolerance - スクロールの許容誤差(px)
       * @returns {boolean}
       */
      isScrolledToRight(elem, tolerance = 2) {
        if (!elem) return false;

        // スクロールが発生しない場合(コンテンツ幅 <= ブラウザ可視幅)、右端とみなす
        if (elem.scrollWidth <= elem.clientWidth) return true;

        // スクロール位置 + ブラウザ可視幅がコンテンツ幅に近ければ右端到達とみなす(誤差を考慮)
        return elem.scrollLeft + elem.clientWidth >= elem.scrollWidth - tolerance;
      },

      /**
       *  ヘッダーに患者情報を設定する処理
       * @param patJson   患者の情報
       */
      setHeaderDispPatMode(patJson) {
        //ストアにセット
        this.setHeaderInfo(patJson);
      },
      /**
       * ヘッダーにデフォルトメッセージを設定する処理
       *
       */
      setHeaderDispDefaultMode() {
        //ストアにセット
        this.setHeaderInfo(null);
      },

      /**
       * 配列系のバインド変数の初期化
       *@param kurNum クール数
       */
      initBindVals(kurNum) {
        //表示条件設定:クール表示用
        this.propsBKurDispFlag = new Array(kurNum + 1);
        for (let k = 1; k <= kurNum; k++) {
          this.propsBKurDispFlag[k] = true;
        }

        for (let d = 1; d <= DEF_MAX_DAY_HEADER; d++) {
          //クールヘッダー領域
          this.propsJKurHeader[d] = new Array(kurNum + 1);

          //ベッド未登録領域(日付分)
          this.propsJBedNotYet[d] = new Array(kurNum + 1);
          //クール未登録領域(日付分)
          this.propsJKurNotYet[d] = new Array(kurNum + 1);

          for (let k = 0; k <= kurNum; k++) {
            //ベッド未登録領域(クール分)
            this.propsJBedNotYet[d][k] = new Array(this.dispNumNotYetBed + 1);
            //クール未登録領域(クール分)
            this.propsJKurNotYet[d][k] = new Array(this.dispNumNotYetKur + 1);

            //ベッドデータの初期化
            for (let b = 0; b <= this.dispNumNotYetKur; b++) {
              this.propsJBedNotYet[d][k][b] = null;
              this.propsJKurNotYet[d][k][b] = null;
            }
          }

          this.kurDayVisibility[d] = new Array(kurNum + 1);
          this.kurDayWidth[d] = new Array(kurNum + 1);
          this.propsJMoveData[d] = new Array(kurNum + 1);
          this.propsJDummyData[d] = new Array(kurNum + 1);
          for (let k = 1; k <= kurNum; k++) {
            this.propsJKurHeader[d][k] = {};
            this.propsJMoveData[d][k] = {};
            this.propsJDummyData[d][k] = {};
            this.kurDayVisibility[d][k] = "visible";
            this.kurDayWidth[d][k] = DEF_KUR_WIDTH;
          }
        }
      },

      /**
       * 表示条件設定の開始日付の取得
       */
      getSettingStartDate() {
        let dispStartDate = this.dispStartDateForSetting.replace(/-/g, "");
        if (dispStartDate === "") {
          //日付がありえない場合、this.dispStartDateが""になるので、代わりに当日を設定
          dispStartDate = this.formatMomentDateYYYYMMDD(dayjs());
        }
        return dispStartDate;
      },

      /**
       * クール列幅（日付×クール単位）
       */
      getKurColumnWidth(dayIndex, kurIndex) {
        const width = Number(this.kurDayWidth?.[dayIndex]?.[kurIndex]);
        return width > 0 ? width : DEF_KUR_WIDTH;
      },

      /**
       * 日付ヘッダー列幅（配下クール列幅の合計）
       */
      getDayColumnWidth(dayIndex) {
        if (!dayIndex || dayIndex > this.dayMax) {
          return 0;
        }
        let sum = 0;
        for (let k = 1; k <= this.kurNum; k++) {
          if (this.kurDayVisibility?.[dayIndex]?.[k] === "visible") {
            sum += this.getKurColumnWidth(dayIndex, k);
          }
        }
        return sum > 0 ? sum : this.dayWidth;
      },

      /**
       * 状態管理値からスケジュール表全体幅を算出
       */
      getScheduleTotalWidthFromState() {
        let total = 0;
        for (let d = 1; d <= this.dayMax; d++) {
          const dayVisible = this.holidayFlag || this.getDayDispIndex[d - 1];
          if (!dayVisible) {
            continue;
          }
          total += this.getDayColumnWidth(d);
        }
        return Math.round(total);
      },

      /**
       * 状態管理値からヘッダー・明細の列幅を再適用（リサイズ列の左側は幅を変えない）
       */
      syncScheduleHeaderWidthsFromState() {
        for (let dayIndex = 1; dayIndex <= this.dayHeaderNum; dayIndex++) {
          const dayVisible =
            dayIndex <= this.dayMax &&
            (this.holidayFlag || this.getDayDispIndex[dayIndex - 1]);

          for (let kurIndex = 1; kurIndex <= this.kurNum; kurIndex++) {
            const columnIndex = (dayIndex - 1) * this.kurNum + (kurIndex - 1);
            const kurVisible =
              dayVisible &&
              this.kurDayVisibility?.[dayIndex]?.[kurIndex] === "visible";
            const kurWidth = kurVisible
              ? this.getKurColumnWidth(dayIndex, kurIndex)
              : 0;
            this.setKurHeaderColumnDisplay(columnIndex, kurVisible, kurWidth);
            if (kurVisible) {
              this.applyScheduleBodyColumnWidth(dayIndex, kurIndex, kurWidth);
            }
          }

          const dayWidth = dayVisible ? this.getDayColumnWidth(dayIndex) : 0;
          this.setDayHeaderColumnDisplay(
            dayIndex - 1,
            dayVisible && dayWidth > 0,
            dayWidth
          );
        }
      },

      /**
       * 横スクロール位置を維持（列幅変更で左側がずれないようにする）
       */
      restoreScheduleHorizontalScroll(scrollLeft) {
        const left = Math.max(0, Math.round(Number(scrollLeft) || 0));
        const scrollArea = this.getScopedElementById("scroll_area");
        if (scrollArea) {
          scrollArea.scrollLeft = left;
        }
        this.syncHeaderScrollLeft(left);
        if (this.areaElems) {
          [5, 6, 7, 8, 9].forEach((index) => {
            if (this.areaElems[index]) {
              this.areaElems[index].scrollLeft = left;
            }
          });
        }
        this.setScrollLeftWitch(left);
      },

      /**
       * Kendo ヘッダー表をコンテンツ総幅で展開（ビューポート幅に押し潰さない）
       */
      applyScheduleKendoGridContainerWidth(root, totalWidth) {
        if (!root) {
          return;
        }
        const widthText = `${Math.max(0, Math.round(Number(totalWidth) || 0))}px`;
        root.style.width = widthText;
        root.style.removeProperty("min-width");
        const grid = root.querySelector(".k-grid");
        if (grid) {
          grid.style.width = widthText;
          grid.style.removeProperty("min-width");
        }
      },

      /**
       * 列要素の幅を設定（min/max で固定しない＝Kendo リサイズを阻害しない）
       */
      applyScheduleColumnElementWidth(element, widthText, visible) {
        if (!element) {
          return;
        }
        element.style.display = visible ? "" : "none";
        if (visible && widthText) {
          element.style.width = widthText;
          element.style.removeProperty("min-width");
          element.style.removeProperty("max-width");
        } else if (!visible) {
          element.style.width = "0px";
          element.style.removeProperty("min-width");
          element.style.removeProperty("max-width");
        }
      },

      /**
       * 列幅変更後のスクロール領域・ヘッダー表幅同期
       */
      updateScheduleScrollWidth(totalWidth, options = {}) {
        const scrollArea = this.getScopedElementById("scroll_area");
        const savedScrollLeft = scrollArea?.scrollLeft || 0;

        const normalizedWidth = Math.max(
          0,
          Math.round(Number(totalWidth) || 0)
        );
        this.totalWidth = normalizedWidth;
        this.area6Width = normalizedWidth;

        // 各列幅を状態から固定してから表幅を合わせる（左端固定・右端のみ伸縮）
        this.syncScheduleHeaderWidthsFromState();

        const dayRoot = this.getScopedElementById("kendo_day");
        const kurRoot = this.getScopedElementById("kendo_kur");
        if (dayRoot) {
          this.applyScheduleKendoGridContainerWidth(dayRoot, normalizedWidth);
          this.syncHeaderGridTables(dayRoot, normalizedWidth);
        }
        if (kurRoot) {
          this.applyScheduleKendoGridContainerWidth(kurRoot, normalizedWidth);
          this.syncHeaderGridTables(kurRoot, normalizedWidth);
        }

        const area5ScrollArea = this.getScopedElementById("id_area5_scrollarea");
        if (area5ScrollArea) {
          area5ScrollArea.style.width = `${normalizedWidth + 2}px`;
          area5ScrollArea.style.removeProperty("min-width");
        }
        const area6Table = this.getScopedElementById("id_area6_tbl");
        if (area6Table) {
          area6Table.style.width = `${normalizedWidth}px`;
          area6Table.setAttribute("width", `${normalizedWidth}px`);
        }
        const area6Inner = this.getScopedElementById("id_area6")?.firstElementChild;
        if (area6Inner) {
          area6Inner.style.width = `${normalizedWidth}px`;
        }
        const underbar = this.getScopedElementById("id_underbar_content9");
        if (underbar) {
          underbar.style.width = `${normalizedWidth}px`;
        }

        const targetElems = this.getScheduleGridContentEls();
        const contentExpanders = this.getScheduleGridContentExpanders();
        if (contentExpanders[0] && targetElems?.[1]) {
          contentExpanders[0].style.width = `${targetElems[1].scrollWidth || normalizedWidth}px`;
        }

        this.restoreScheduleHorizontalScroll(savedScrollLeft);
        if (options.resizeMode) {
          this.syncDayHeaderWidthWithKur();
        } else {
          this.queueDayHeaderLayoutSync();
        }
      },

      detachScheduleHeaderResizeEndListener() {
        if (!this.scheduleHeaderResizeEndListening) {
          return;
        }
        const doc = this.getScheduleOwnerDocument();
        doc.removeEventListener("mouseup", this.flushScheduleHeaderWidthSync, true);
        doc.removeEventListener("touchend", this.flushScheduleHeaderWidthSync, true);
        this.scheduleHeaderResizeEndListening = false;
      },

      flushScheduleHeaderWidthSync() {
        this.detachScheduleHeaderResizeEndListener();
        if (this.scheduleHeaderResizeRafId) {
          cancelAnimationFrame(this.scheduleHeaderResizeRafId);
          this.scheduleHeaderResizeRafId = 0;
        }
        // Kendo 側の列幅確定後に最終同期する
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            this.updateScheduleScrollWidth(this.getScheduleTotalWidthFromState());
          });
        });
      },

      /**
       * 列幅ドラッグ中は rAF で同期、操作終了時に完全同期する
       */
      requestScheduleHeaderWidthSync() {
        if (!this.scheduleHeaderResizeEndListening) {
          this.scheduleHeaderResizeEndListening = true;
          const doc = this.getScheduleOwnerDocument();
          doc.addEventListener("mouseup", this.flushScheduleHeaderWidthSync, true);
          doc.addEventListener("touchend", this.flushScheduleHeaderWidthSync, true);
        }
        if (this.scheduleHeaderResizeRafId) {
          return;
        }
        this.scheduleHeaderResizeRafId = requestAnimationFrame(() => {
          this.scheduleHeaderResizeRafId = 0;
          this.updateScheduleScrollWidth(this.getScheduleTotalWidthFromState(), {
            resizeMode: true
          });
        });
      },

      /**
       * ベッド系テーブルセルの列幅を更新
       */
      applyScheduleBodyColumnWidth(dayIndex, kurIndex, width) {
        const widthText = `${Math.max(0, Math.round(Number(width) || 0))}px`;
        [
          `id_td_${dayIndex}_${kurIndex}`,
          `id_tdbednotyet_${dayIndex}_${kurIndex}`,
          `id_tdkurnotyet_${dayIndex}_${kurIndex}`
        ].forEach((id) => {
          this.applyScheduleColumnElementWidth(
            this.getScopedElementById(id),
            widthText,
            true
          );
        });
      },
      /**
       * チェックの値の取得
       * @param elemId 取得対象の要素Id
       * @return チェックの値 true/false
       */
      getCheckBoxValue(elemId) {
        let ret = false;
        const elem = this.getScopedElementById(elemId);
        ret = elem !== null ? elem.checked : false;
        return ret;
      },
      /**
       * スケジュールデータの取得
       * payload:
       *  facilityCd:施設コード
       *  dayNum:日付数
       */
      async loadScheduleData(payload) {
        //表示日数
        const dayNum = payload.dayNum;

        //表示の基準日
        const baseDate = payload.baseDate;

        let dt = null === baseDate ? dayjs() : dayjs(baseDate);

        // 帳票受け渡し用のstore設定
        this.setReportParam({
          baseDate: dt.toDate(),
          dayNum: Math.floor(dayNum / 2) - 1 // 表示範囲日数 ÷ 2 - 基準日1日
        });

        //指定日を真ん中にする補正
        //例)14日出す場合、基準日の前が7日、後ろは基準日を含めて7日
        const minusDayNum = -1 * Math.floor(dayNum / 2);
        dt = dt.add(minusDayNum, "days");

        //-----------------------------------------------
        //日付列の作成
        // 表示日数分の日付文字列(yyyymmdd)を作成する
        // add 10601 スケジュール表動作不正 関  start
        let treatDateList = [];
        // add 10601 スケジュール表動作不正 関  end
        for (let d = 1; d <= dayNum + payload.overFlowDayNum; ++d) {
          //yyyymmdd形式に組み立て
          // mod 10601 スケジュール表動作不正 関  start
          treatDateList.push(this.treatDateDim[d - 1] = this.formatMomentDateYYYYMMDD(dt));
          // mod 10601 スケジュール表動作不正 関  end
          //1日進める
          dt = dt.add(1, "days");
        }

        //----------------------------------------------
        //API呼び出しパラメータの組み立て

        //日付列を-で連結してひとつの文字列にする
        // mod 10601 スケジュール表動作不正 関  start
        const treatDateStr = treatDateList.join("-");
        // mod 10601 スケジュール表動作不正 関  end
        const paramA = {
          // ここにクエリパラメータを指定する
          treatDate: treatDateStr,
          facilityCd: this.getFacilityCd
        };

        try {
          // 並列でAPI呼び出し
          const [scheduleResponse] = await Promise.all([
            ApiHelper.get("/scheduleList/getScheduleList/Days", paramA),
            this.getOtherScheduleData() // その他の予定データリスト取得
          ]);

          this.dispdata = {};
          for (let d = 0; d < scheduleResponse.data.length; d++) {
            // ストアに格納(キー:yyyymmdd)
            this.dispdata[this.treatDateDim[d]] = JSON.parse(
              scheduleResponse.data[d].replace(/'/g, '"')
            );
          }
        } catch (err) {
          getErrorMessage('ScheduleListMainItem.vue', 'loadScheduleData', err);
        }

        if (!this.firstReadFlag) {
          //初期以降はここで入外区分集計を行う
          this.aggrigateInOutClass();
        }

        //ストアへデータをセット
        this.setDispDataToStore(this.dispdata);

        //日付データ関連設定(ストア) ※二度手間の実装になっているのは、もともとstoreでDBアクセスしていたものをvue側にDBアクセスのみを持ってきたため
        await this.initStore(payload);
      },
      /**
       * 入外区分集計処理(全日対象)
       */
      aggrigateInOutClass() {
        for (let d = 0; d < Object.keys(this.dispdata).length; d++) {
          //------------------------------------
          //集計(入外患者数)
          //日付データへのポインター
          const daydataDim = this.dispdata[this.treatDateDim[d]];
          //入院患者総数
          let innumTotal = 0;
          //外来患者総数
          let outnumTotal = 0;
          // ベッド・クール未登録患者総数
          let undecidedTotal = 0;
          // add FNSI-集計数の修正 徐 start
          let notOutAndInTotal = 0;
          // add FNSI-集計数の修正 徐 end

          //クール数分ループする
          for (let k = 0; k < this.kurNum; k++) {
            // mod bug #7928 修正 chen start
            if (!daydataDim || typeof daydataDim[k] === DEF_UNDEFINED) {
            // mod bug #7928 修正 chen end
              //ないのでスキップ
              continue;
            }
            const beddataDim = daydataDim[k].beddata;
            //入院患者数
            let innum = 0;
            //外来患者数
            let outnum = 0;
            // ベッド未登録患者数
            let undecidednum = 0;
            // add FNSI-集計数の修正 徐 start
            let notOutAndInNum = 0;
            // add FNSI-集計数の修正 徐 end

            for (let b = 1; b <= this.titleNum; b++) {
              if (typeof beddataDim[b] === "undefined") {
                //Out of bounds
                break;
              }
              if (
                "inOutClass" in beddataDim[b] &&
                beddataDim[b].isDummy === "0"
              ) {
                //入外区分があればそれに従いカウント(ダミースケジュールはカウント対象外)
                const inoutclass = beddataDim[b].inOutClass;
                if (inoutclass === 0) {
                  //外来カウントアップ
                  ++outnum;
                } else if (inoutclass === 1) {
                  //入院カウントアップ
                  ++innum;
                  // add FNSI-集計数の修正 徐 start
                } else {
                  ++notOutAndInNum;
                }
                // add FNSI-集計数の修正 徐 end
              }
            }

            // ベッド未登録患者のカウント
            const arrBedNotYet = daydataDim[k].bedNotYet;
            for (let c = 0; c <= arrBedNotYet.length; c++) {
              if (arrBedNotYet[c]){
                // ベッド未登録カウントアップ
                ++undecidednum;
                if ("inOutClass" in arrBedNotYet[c]) {
                  //入外区分があればそれに従いカウント(ダミースケジュールはカウント対象外)
                  const inoutclass = arrBedNotYet[c].inOutClass;
                  if (inoutclass === 0) {
                    //外来カウントアップ
                    ++outnum;
                  } else if (inoutclass === 1) {
                    //入院カウントアップ
                    ++innum;
                    // add FNSI-集計数の修正 徐 start
                  } else {
                    ++notOutAndInNum;
                  }
                  // add FNSI-集計数の修正 徐 end
                }
              }
            }
            //入院患者数に格納
            daydataDim[k].numIn = innum;
            //外来患者数に格納
            daydataDim[k].numOut = outnum;
            // ベッド未登録患者数に格納
            daydataDim[k].numUndecided = undecidednum;
            // add FNSI-集計数の修正 徐 start
            // 不明患者数に格納
            daydataDim[k].nuMnotOutAndIn = notOutAndInNum;
            // add FNSI-集計数の修正 徐 end
            //各総計に加算
            outnumTotal += outnum;
            innumTotal += innum;
            undecidedTotal += undecidednum;
            // add FNSI-集計数の修正 徐 start
            // 不明患者数に加算
            notOutAndInTotal += notOutAndInNum;
            // add FNSI-集計数の修正 徐 end
          }

          // クール未登録患者数をカウント
          // mod bug #7928 修正 chen start
          if (daydataDim) {
            for (let d = 0; d < daydataDim.length; d++) {
              if (typeof daydataDim[d] !== DEF_UNDEFINED && daydataDim[d].kur === AREA_KURNOTYET) {
                const beddataDim = daydataDim[d].beddata;
                for (let e = 0; e <= beddataDim.length; e++) {
                  if (beddataDim[e]) {
                    // クール・ベッド未登録患者カウントアップ
                    ++undecidedTotal;
                    if ("inOutClass" in beddataDim[e]) {
                      //入外区分があればそれに従いカウント(ダミースケジュールはカウント対象外)
                      const inoutclass = beddataDim[e].inOutClass;
                      if (inoutclass === 0) {
                        //外来カウントアップ
                        ++outnumTotal;
                      } else if (inoutclass === 1) {
                        //入院カウントアップ
                        ++innumTotal;
                        // add FNSI-集計数の修正 徐 start
                      } else {
                        // 不明カウントアップ
                        ++notOutAndInTotal;
                      }
                      // add FNSI-集計数の修正 徐 end
                    }
                  }
                }
              }
            }
            //入院患者総数に格納
            daydataDim.numInTotal = innumTotal;
            //外来患者総数に格納
            daydataDim.numOutTotal = outnumTotal;
            // クール・ベッド未登録患者総数に格納
            daydataDim.numUndecidedTotal = undecidedTotal;
            // add FNSI-集計数の修正 徐 start
            // 不明患者総数に格納
            daydataDim.numNotOutAndInTotal = notOutAndInTotal;
            // add FNSI-集計数の修正 徐 end
          }
          // mod bug #7928 修正 chen end
        }
      },
      /**
       * 名前存在確認
       * @param jsonObj ベッド患者情報Json
       * @return true:名前がある false:名前がない
       */
      checkNameEffective(jsonObj) {
        let ret = false;
        if ("patLastName" in jsonObj) {
          if (jsonObj.patLastName !== null && jsonObj.patLastName.length > 0) {
            //nullでなく、かつ、空文字ではない
            ret = true;
          }
        }

        if ("patFirstName" in jsonObj) {
          if (jsonObj.patFirstName !== null && jsonObj.patFirstName.length > 0) {
            //nullでなく、かつ、空文字ではない
            ret = true;
          }
        }

        return ret;
      },
      /**
       * クールブロック内のベッドの相互比較処理
       * @param fromDimData 移動元クールブロック(配列)
       * @param toDimData 移動先クールブロック(配列)
       * @return 移動可不可 true:可能 false:移動できない
       */
      async compareEachBeds(fromDimData, toDimData) {
        let moveEnable = true;
        //移動元に患者がいる場合 以下のチェックを行い、すべてをクリアすれば移動可能
        //  1.治療状況が移動可能("0")
        //  2.移動先に患者がいない(ダミーも含めて配置可能)
        //  3.同一患者同一治療日同一クール同一治療方法に該当しない

        //mod #10601 スケジュール表動作不正 start
        let retCount = 0;
        let beforeMoveDataList = [];
        let afterMoveDataList = [];
        for (let b = 1; b < fromDimData.length; b++) {
          if (!this.getBedDispState(b - 1)) {
            //非表示状態なので処理しない。
            continue;
          }
          if (this.checkNameEffective(fromDimData[b])) {
            //移動元に患者がいる場合
            if ("dialysisState" in fromDimData[b] && fromDimData[b].dialysisState === "0") {
              const fromData = {
                facilityCd: this.getFacilityCd,
                ordNo: fromDimData[b]?.ordNo,
                indBedCd: fromDimData[b]?.bed_cd,
                indKurCd: fromDimData[b]?.kur_cd,
                treatDate: fromDimData[b]?.treatDate
              };
              const toData = {
                facilityCd: this.getFacilityCd,
                indBedCd: toDimData[b]?.bed_cd,
                indKurCd: toDimData[b]?.kur_cd,
                treatDate: toDimData[b]?.treatDate
              };
              beforeMoveDataList.push(fromData);
              afterMoveDataList.push(toData);
            }
          }
        }

        const param = {
          beforeIndScheduleInfoList: beforeMoveDataList,
          afterIndScheduleInfoList: afterMoveDataList
        };
        if(beforeMoveDataList.length === 0 && afterMoveDataList.length === 0){
          return moveEnable;
        }

        const response = await ApiHelper.post("/scheduleList/selectForSearchReservedBed2", param)
          .catch(error => {
            getErrorMessage('ScheduleListMainItem.vue', 'selectForSearchReservedBedOnDB', error);
            throw error;
          });
        retCount = response.data.length;
        if (retCount !== 0) {
          moveEnable = false;
        }
        //mod #10601 スケジュール表動作不正 end

        return moveEnable;
      },
      /**
       * ヘッダー部分のクリックイベント処理
       * ・日付ブロック、クールブロックの処理を行う
       * ・ブロックの生成
       * ・ブロックの消滅
       */
      async clickHeadEvent(e) {
        // add FNSI 権限 start -- Sanjingye Sun 20201228
        if(!this.haveAuthority) {
          return;
        }
        // add FNSI 権限 end -- Sanjingye Sun 20201228

        // 予定移動中の場合は、処理をせずに抜ける
        if (this.movingChipElem !== null) {
          return;
        }
        // 列幅変更時もこのイベントが発火してしまう為、ターゲットが不正な場合は、処理をせずに抜ける
        if (!e.target.parentNode.id && !e.target.parentNode.parentNode.id) {
          return;
        }
        this.isMovePats = true;
        if (e.target.className === "k-resize-handle") {
          this.isMovePats = false;
          //kendo-uiのリサイズハンドラ上のクリックなので無視
          return;
        }

        //-------------------------------------
        //リサイズ処理中かどうかの確認

        if (this.resizingNowFlag) {
          //リサイズ中だったので何もしない
          this.resizingNowFlag = false;
          this.isMovePats = false;
          return;
        }

        //----------------------------------------------
        //ブロックが存在するかの確認

        this.clickEventNowFlag = true;
        // Block in
        if (this.movingBlockElem !== null) {
          //this.movingBlockElemが使用中(移動中)の場合

          //-------------------------
          // 落とすチェック

          //一瞬チップを消す(理由:チップ上でクリックしたことになるので、一時的に消して下の要素を取得する)
          this.movingBlockElem.style.display = "none";
          // mod FNSI 1006 No.426 start -- Sanjingye Sun 20201224
          if(!this.facilitySettingDialogOpenFlg){
            this.underElem = this.getScheduleElementFromPoint(e.clientX, e.clientY);
          }
          // mod FNSI 1006 No.426 end -- Sanjingye Sun 20201224

          //チップをだす
          this.movingBlockElem.style.display = "inline";

          //-------------------------------------
          //下のセルのチェック(落とし先の確認)

          // mod FNSI 1006 No.426 start -- Sanjingye Sun 20201224
          // クリックした場所によって参照する要素が異なる
          let referenceNode = null;
          if (this.underElem.parentNode.classList.contains("cls-kur-disp") || this.underElem.classList.contains("cls-day-disp")) {
            referenceNode = this.underElem.parentNode
          } else {
            referenceNode = this.underElem
          }
          // mod FNSI 1006 No.426 end -- Sanjingye Sun 20201224

          const nowId = referenceNode.id;

          let flagKurBlock = false; //クールブロックの移動先フラグ trueだと落とし先がクールブロック
          let flagDayBlock = false; //日付ブロックの移動先フラグ trueだと落とし先が日付ブロック

          let paramDim = null;
          if (nowId === "") {
            //IDがない場合、親のIDから状況を確認(クールヘッダーに落とそうとしている状況なのかの確認)
            if (referenceNode.parentNode !== null) {
              const parentId = referenceNode.parentNode.id;
              if (parentId.startsWith("id_kurheader")) {
                //クールヘッダーに落とそうとしている
                flagKurBlock = true;
                const kurNum = parentId.replace("id_kurheader", "");
                const dimKurNum = kurNum.split("-");

                //ブロック情報取得用のパラメータ組み立て(クールブロック用)
                paramDim = [dimKurNum[0], dimKurNum[1]];
              }
            }
          } else if (nowId.startsWith("id_dayheader")) {
            //日付ヘッダーに落とそうとしている
            flagDayBlock = true;
            const dayNum = nowId.replace("id_dayheader-", "");

            //ブロック情報取得用のパラメータ組み立て(日付ブロック用)
            paramDim = [dayNum];
          } else {
            //なにもしない
            this.clickEventNowFlag = false;
            this.isMovePats = false;
            return;
          }

          //移動先Index情報の格納
          this.movingBlockInfoToIndex = paramDim;
          //移動先の情報の取得
          this.movingBlockInfoTo = await this.getPatBedInfo(paramDim);

          if (
            (this.movingBlockKind === DEF_KUR && flagKurBlock) ||
            (this.movingBlockKind === DEF_DAY && flagDayBlock)
          ) {
            //クールブロックを、クールに落とそうとしている
            //または
            //日付ブロックを、日付に落とそうとしている

            //------------------------------------------
            //自分自身に落とそうとしているかのチェック
            // ※自分自身の場合、移動終了(ブロックを消して何もしない)

            if (
              this.movingBlockInfoToIndex[0] === this.movingBlockInfoFromIndex[0]
            ) {
              //日付は一致している
              if (
                flagDayBlock ||
                (flagKurBlock &&
                  this.movingBlockInfoToIndex[1] ===
                  this.movingBlockInfoFromIndex[1])
              ) {
                //日付ブロックの場合、日付が一致した場合、移動終了
                //クールブロックの場合、日付、クールが一致した場合、移動終了

                //ブロックを削除
                if (this.movingBlockElem.parentNode) {
                  this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
                }
                //もう移動が終わったのでポインタを初期化
                this.movingBlockElem = null;

                this.clickEventNowFlag = false;

                this.isMovePats = false;
                return;
              }
            }

            // スケジュール一括移動確認
            const answer = await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000040].title,
              message: messageFormat(DIALOG_MESSAGES[70000040].message),
            });
            // キャンセルなら処理を中断
            if (answer === 0) {
              if (this.movingBlockElem.parentNode) {
                this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
              }
              this.movingBlockElem = null;
              this.clickEventNowFlag = false;
              this.isMovePats = false;
              return; // 以降の処理は行わない
            }

            //------------------------------------------
            //移動可能確認処理

            let moveEnable; //移動可否フラグ true:移動可能

            this.msgNo = DEF_DIALOG_MSG_4; //禁止メッセージ出力の準備(メッセージ番号の初期値の設定)

            //過去日付移動の確認
            if (!this.indUser) {
              // 指示者入力チェック
              this.msgNo = DEF_DIALOG_MSG_16; //指示者未選択メッセージ
              moveEnable = false; //移動不可
            } else {
              if (flagKurBlock) {
                //クールブロックだった場合
                // クールブロックの移動可否確認

                //確定エリアの移動可否確認
                // ブロック内の対応ベッド同士の比較を行う

                moveEnable = await this.compareEachBeds(
                  this.movingBlockInfoFrom.commitAreaData,
                  this.movingBlockInfoTo.commitAreaData
                );
              } else {
                //日付ブロックだった場合

                //mod #10601 スケジュール表動作不正 start
                //確定エリアの確認(日付ブロックに含まれるクールブロック分比較します)
                let beforeMoveDataList = [];
                let afterMoveDataList = [];
                for (let k = 0; k < this.kurNum; k++) {
                  for (let b = 0; b < this.movingBlockInfoFrom[k].commitAreaData.length; b++) {
                    beforeMoveDataList.push(this.movingBlockInfoFrom[k].commitAreaData[b]);
                  }
                  for (let b = 0; b < this.movingBlockInfoTo[k].commitAreaData.length; b++) {
                    afterMoveDataList.push(this.movingBlockInfoTo[k].commitAreaData[b]);
                  }
                }
                moveEnable = await this.compareEachBeds(beforeMoveDataList,afterMoveDataList);
                //mod #10601 スケジュール表動作不正 end
              }
            }
            //移動可否フラグの確認
            if (!moveEnable) {
              let msg = "";
              if (this.msgNo === DEF_DIALOG_MSG_16) {
                msg = "指示者";
              }
              //移動できないメッセージ出力
              this.messageDialogInfo.stringParams = [msg];
              this.messageDialogInfo.messageCd = this.msgNo;
              this.messageDialogInfo.type = DEF_MSGTYPE_OK;
              this.messageDialogInfo.isDialogVisible = true;
              this.messageDialogInfo.dialogNo = DEF_DIALOG_CANNOTMOVE;
              this.msgPopUpFlag = true;
            } else {
              //データの移動処理
              //確定領域の移動
              if (flagKurBlock) {
                // FNSI-add 現行改善対応425 徐 start
                // 移動元 area data
                let commitAreaData = this.movingBlockInfoFrom.commitAreaData;
                let bedNotYetAreaData = this.movingBlockInfoFrom.bedNotYetAreaData;

                let moveToCommitAreaData = this.movingBlockInfoTo.commitAreaData
                  .filter(bedInfo => bedInfo != null)
                  .filter(bedInfo => bedInfo.treatDate != null && bedInfo.treatDate != undefined && bedInfo.treatDate != '');
                //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
                let moveFromCommitAreaData = this.movingBlockInfoFrom.commitAreaData
                  .filter(bedInfo => bedInfo != null)
                  .filter(bedInfo => bedInfo.treatDate != null && bedInfo.treatDate != undefined && bedInfo.treatDate != '');
                //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

                if(!moveToCommitAreaData || moveToCommitAreaData.length == 0) {
                  return;
                }
                let moveToTreatDate = moveToCommitAreaData[0].treatDate;

                //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
                let moveFromTreatDate = moveFromCommitAreaData[0].treatDate;
                //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

                // add #10359 編集権限について、対応する。 zhangyue start
                // 移動スケジュール権限のみの場合にヒントを与える
                if (this.hasAuthorityByCd(AUTHORITY_CODES.SCHE_MOVE)
                  && !(this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT)
                    || this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT))
                  && moveToTreatDate != moveFromTreatDate
                ) {
                  this.clickEventNowFlag = false;
                  this.$ons.notification.alert({
                    title: DIALOG_MESSAGES[12000315].title,
                    message: messageFormat(DIALOG_MESSAGES[12000315].message, "治療指示")
                  });
                  //ブロックを削除
                  if (this.movingBlockElem.parentNode) {
                    this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
                  }
                  //もう移動が終わったのでポインタを初期化
                  this.movingBlockElem = null;

                  this.clickEventNowFlag = false;

                  this.isMovePats = false;
                  return;
                }
                // add #10359 編集権限について、対応する。 zhangyue end
                // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
                // 共通ローダー:表示開始
                this.setLoadingScreenVisible(true);
                // add FNSI 1006 No.426 end -- Sanjingye Sun 20201224

                //クールブロックの移動処理(確定領域＋ベッド未登録領域)
                this.resetBedIdDimForDelete();
                // mod 10601 スケジュール表動作不正 関  start
                await this.moveBlockKur2(
                  this.movingBlockInfoFrom,
                  this.movingBlockInfoFromIndex,
                  this.movingBlockInfoTo,
                  this.movingBlockInfoToIndex
                );
                // mod 10601 スケジュール表動作不正 関  end
              } else {
                // 日付ブロックの処理
                // FNSI-add 現行改善対応425 徐 start
                let moveToCommitAreaDataF = this.movingBlockInfoTo[0].commitAreaData
                  .filter(bedInfo => bedInfo != null)
                  .filter(bedInfo => bedInfo.treatDate != null && bedInfo.treatDate != undefined && bedInfo.treatDate != '');

                if(!moveToCommitAreaDataF || moveToCommitAreaDataF.length == 0) {
                  return;
                }

                // add #10359 編集権限について、対応する。 zhangyue start
                let moveFromCommitAreaDataF = this.movingBlockInfoFrom[0].commitAreaData;
                // 移動スケジュール権限のみの場合にヒントを与える
                if (this.hasAuthorityByCd(AUTHORITY_CODES.SCHE_MOVE)
                  && !(this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT)
                    || this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT))
                  && moveToCommitAreaDataF != moveFromCommitAreaDataF
                ) {
                  this.clickEventNowFlag = false;
                  this.$ons.notification.alert({
                    title: DIALOG_MESSAGES[12000315].title,
                    message: messageFormat(DIALOG_MESSAGES[12000315].message, "治療指示")
                  });
                  //ブロックを削除
                  if (this.movingBlockElem.parentNode) {
                    this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
                  }
                  //もう移動が終わったのでポインタを初期化
                  this.movingBlockElem = null;

                  this.clickEventNowFlag = false;

                  this.isMovePats = false;
                  return;
                }
                // add #10359 編集権限について、対応する。 zhangyue end
                let moveToTreatDateF = moveToCommitAreaDataF[0].treatDate;
                if (!this.facilitySettingDialog1007OpenedFlg) {
                  if(this.getFacilitySetting1007 != 4) {
                    this.setFacilitySetting1007_4SelectedVal(this.getFacilitySetting1007);
                  }
                  // 共通ローダー:表示開始
                  this.setLoadingScreenVisible(true);
                  let showDialogFlgExam = false;
                  //9273 start
                  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
                  let showExam = false;
                  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
                  //9273 end
                  for(let a = 0; a < this.movingBlockInfoFrom.length; a++) {
                    if (this.movingBlockInfoFrom[a].commitAreaData && this.movingBlockInfoFrom[a].bedNotYetAreaData) {
                      for (let b = 0; b < this.movingBlockInfoFrom[a].commitAreaData.length; b++) {
                        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
                        if (!this.getBedDispState(b - 1)) {
                          //非表示状態のものは処理しません。
                          continue;
                        }
                        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
                        if (this.movingBlockInfoFrom[a].commitAreaData[b] && this.movingBlockInfoFrom[a].commitAreaData[b].pat_id) {
                          await this.getPatExamMain({
                            patId: this.movingBlockInfoFrom[a].commitAreaData[b].pat_id,
                            treatDate: this.movingBlockInfoFrom[a].commitAreaData[b].treatDate,
                          });
                          let paramsF = {
                            fromTreatDate: this.movingBlockInfoFrom[a].commitAreaData[b].treatDate,
                            toTreatDate: moveToTreatDateF,
                            checkFlg: "exam"
                          };
                          //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
                          if(this.getExamStatus){
                            showExam = true;
                          }
                          //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
                          // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
                          let examFlgF = this.checkDeadline(paramsF);
                          if (examFlgF) {
                            showDialogFlgExam = true;
                            this.showExamDeadlineMsgFlg = true;
                            // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou end
                          }
                        }
                      }
                      if (!showDialogFlgExam) {
                        for (let j = 0; j < this.movingBlockInfoFrom[a].bedNotYetAreaData.length; j++) {
                          if (this.movingBlockInfoFrom[a].bedNotYetAreaData[j] && this.movingBlockInfoFrom[a].bedNotYetAreaData[j].pat_id) {

                            let paramsN = {
                              fromTreatDate: this.movingBlockInfoFrom[a].bedNotYetAreaData[j].treatDate,
                              toTreatDate: moveToTreatDateF,
                              checkFlg: "exam"
                            };
                            // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
                            let examFlgN = this.checkDeadline(paramsN);
                            if (examFlgN) {
                              showDialogFlgExam = true;
                              this.showExamDeadlineMsgFlg = true;
                              // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou end
                              break;
                            }
                          }
                        }
                      } else {
                        break;
                      }
                    } else {
                      if (!showDialogFlgExam) {
                        for (let c = 0; c < this.movingBlockInfoFrom[a].length; c++) {
                          if (this.movingBlockInfoFrom[a][c] && this.movingBlockInfoFrom[a][c].pat_id) {

                            let paramsW = {
                              fromTreatDate: this.movingBlockInfoFrom[a][c].treatDate,
                              toTreatDate: moveToTreatDateF,
                              checkFlg: "exam"
                            };
                            // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
                            let examFlgW = this.checkDeadline(paramsW);
                            if (examFlgW) {
                              showDialogFlgExam = true;
                              this.showExamDeadlineMsgFlg = true;
                              // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou end
                              break;
                            }
                          }
                        }
                      } else {
                        break;
                      }
                    }
                  }
                  this.setLoadingScreenVisible(false);
                }
                // 共通ローダー:表示開始
                this.setLoadingScreenVisible(true);
                // add FNSI 1006 No.426 end -- Sanjingye Sun 20201224

                //配下のクール数分だけループ
                this.resetBedIdDimForDelete();
                // mod 10601 スケジュール表動作不正 関  start
                for (let k = 1; k <= this.kurNum; k++) {
                  if (
                    this.kurDayWidth[this.movingBlockInfoFromIndex[0]][k] === 0
                  ) {
                    //クールが閉じられていたら処理しない
                    continue;
                  }
                  const fromIndex = this.movingBlockInfoFromIndex;
                  fromIndex[1] = k;
                  const toIndex = this.movingBlockInfoToIndex;
                  toIndex[1] = k;
                  //クールブロックの移動処理(確定領域＋ベッド未登録領域)
                  await this.moveBlockKur2(
                    this.movingBlockInfoFrom[k - 1],
                    fromIndex,
                    this.movingBlockInfoTo[k - 1],
                    toIndex
                  );
                }
                // mod 10601 スケジュール表動作不正 関  end
                //---------------------------------------------
                //クール未登録領域の移動

                const d = this.movingBlockInfoFromIndex[0];
                outlooplabel: for (let b = 1; ; b++) {
                  for (let kk = 1; kk <= this.kurNum; kk++) {
                    if (this.kurDayWidth[d][kk] === 0) {
                      //クールが閉じられていたら処理しない
                      continue;
                    }
                    if (
                      typeof this.propsJKurNotYet[d][kk][b] ===
                      DEF_UNDEFINED ||
                      null === this.propsJKurNotYet[d][kk][b]
                    ) {
                      //  データが無くなったので処理終了(外ループの終了)
                      break outlooplabel;
                    }
                    // ベッド要素の移動
                    await this.moveNotYetKur(
                      this.propsJKurNotYet[d][kk][b],
                      this.movingBlockInfoFromIndex,
                      this.movingBlockInfoToIndex
                    );
                    //もういらないので元をクリア
                    this.propsJKurNotYet[d][kk].splice(b, 1, null);
                  }
                }
              }
              // mod 10601 スケジュール表動作不正 関  start
            this.clearRadAndExamSetting();
            // チェック
            await this.updateScheduleDBInfo2(this.beforeMoveDataList,this.afterMoveDataList);
            //mod #10601 スケジュール表動作不正 関 start
            if (this.msgCd != null || this.examDeadlineCancelCheck.includes("cancel") || this.radDeadlineCancelCheck.includes("cancel")) {
              //mod #10601 スケジュール表動作不正 関 end
              this.clickEventNowFlag = false;
              this.isMovePats = false;
              this.setLoadingScreenVisible(false);
              this.beforeMoveDataList = [];
              this.afterMoveDataList = [];
              return;
            }
            if (flagKurBlock) {
                await this.moveBlockKur(
                  this.movingBlockInfoFrom,
                  this.movingBlockInfoFromIndex,
                  this.movingBlockInfoTo,
                  this.movingBlockInfoToIndex
                );
              }else{
                for (let k = 1; k <= this.kurNum; k++) {
                  if (
                    this.kurDayWidth[this.movingBlockInfoFromIndex[0]][k] === 0
                  ) {
                    //クールが閉じられていたら処理しない
                    continue;
                  }
                  const fromIndex = this.movingBlockInfoFromIndex;
                  fromIndex[1] = k;
                  const toIndex = this.movingBlockInfoToIndex;
                  toIndex[1] = k;
                  //クールブロックの移動処理(確定領域＋ベッド未登録領域)
                  await this.moveBlockKur(
                    this.movingBlockInfoFrom[k - 1],
                    fromIndex,
                    this.movingBlockInfoTo[k - 1],
                    toIndex
                  );
                }
              }
              // mod 10601 スケジュール表動作不正 関  end

              //画面更新(データの再取得)
              await this.changeDispTerm(0);

              // 列幅の再設定処理を実行
              this.$nextTick(() => {
                this.adjustElemSize();
              });
              if (this.movingBlockElem != null) {
                 //イベントハンドラ削除
              this.movingBlockElem.removeEventListener(
                "click",
                this.clickHeadEvent,
                false
              );

              //ブロックを削除
              if (this.movingBlockElem.parentNode) {
                this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
              }
              //もう移動が終わったのでポインタを初期化
              this.movingBlockElem = null;
              }
            }
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            this.clickEventNowFlag = false;

            //add #10601 スケジュール表動作不正 start
            this.beforeMoveDataList = [];
            this.afterMoveDataList = [];
            //add #10601 スケジュール表動作不正 end

            return;
          }

          this.clickEventNowFlag = false;
          this.isMovePats = false;
          return;

          //ここまで、移動終了処理
        }

        //---------------------------------------------------------
        // ここから移動ブロック作成処理(作成可否確認も含む)

        //ヘッダー表示領域の情報のクリア(※ここでいうヘッダーは、メイン領域の上のヘッダー領域のこと)
        this.setHeaderDispDefaultMode();

        //移動ブロックの大元(divブロック)の作成初期化
        this.movingBlockElem = this.createScheduleElement("div");

        // クリックした場所によって参照する要素が異なる
        let referenceNode = null;
        if (e.target.parentNode.classList.contains("cls-kur-disp") || e.target.classList.contains("cls-day-disp")) {
          referenceNode = e.target.parentNode
        } else {
          referenceNode = e.target
        }
        // Block out
        if (referenceNode.id === "") {
          //この場合クールが選択される
          //ベッド確定領域+ベッド未確定領域が移動対象です

          //idが設定されていないので、(2階層上の)親を調べる
          const kurHeaderId = referenceNode.parentNode.id;

          const kurNum = kurHeaderId.replace("id_kurheader", "");
          const kurId = `id_kur${kurNum}`;
          const dimKurNum = kurNum.split("-");

          const paramDim = [dimKurNum[0], dimKurNum[1]];
          //ブロックデータの取得(クール範囲)
          this.movingBlockInfoFrom = await this.getPatBedInfo(paramDim);
          this.movingBlockInfoFromIndex = paramDim;

          //データチェック(そこにデータが存在するかの確認)
          // mod #11493 スケジュール表　更新不正 関 start
          const checkFlag = await this.checkContainData(this.movingBlockInfoFrom, "kur");
          // mod #11493 スケジュール表　更新不正 関 end
          if (
            checkFlag === DEF_RET_NG ||
            checkFlag === DEF_RET_NG_RELOAD
          ) {
            if (checkFlag === DEF_RET_NG) {
              //移動するものがないメッセージ出力
              this.messageDialogInfo.stringParams = [];
              this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_3;
              // add #10601 移動元を選択したタイミングでチェックして、予定無しの場合はメッセージを出す。 linjunfeng start
              this.messageDialogInfo.title = DIALOG_MESSAGES["70000003"].title;
              // add #10601 移動元を選択したタイミングでチェックして、予定無しの場合はメッセージを出す。 linjunfeng end
              this.messageDialogInfo.type = DEF_MSGTYPE_OK;
              this.messageDialogInfo.isDialogVisible = true;
              this.messageDialogInfo.dialogNo = DEF_DIALOG_NODATA;

              this.movingBlockElem = null;
              this.msgPopUpFlag = true;
              this.clickEventNowFlag = false;
            }
            this.isMovePats = false;
            return;
          }

          //TODO:移動可否確認
          this.setBedIdDimBlock(kurNum);

          //------------------------------------------------------
          //クールブロックの生成

          //構造:
          // <div>   外枠
          //  <div>  クール名、入外区分
          //  <div>  ベッドの外枠
          //    <div> ベッド1
          //    <div> ベッド2
          //    <div> ベッド3
          //    ・・・・・
          //    ・・・・・

          const elemCloneWidth = `${DEF_KUR_WIDTH * this.elemResizeValue}px`;

          //クールヘッダーのクローン
          const cloneKurHeader = referenceNode.parentNode.cloneNode(true);
          cloneKurHeader.style.removeProperty("min-width");
          cloneKurHeader.style.removeProperty("max-width");
          cloneKurHeader.style.width = elemCloneWidth;

          //クールのクローン
          const cloneKur = this.getScopedElementById(kurId).cloneNode(true);
          cloneKur.style.width = elemCloneWidth;

          //ダミーの表示(名前)加工
          const bedChildren = cloneKur.getElementsByTagName("div");

          for (
            let childLoop = 1;
            childLoop < this.movingBlockInfoFrom.commitAreaData.length;
            childLoop++
          ) {
            if (
              "isDummy" in this.movingBlockInfoFrom.commitAreaData[childLoop] &&
              this.movingBlockInfoFrom.commitAreaData[childLoop].isDummy === "1"
            ) {
              if (bedChildren[childLoop - 1]) {
                bedChildren[childLoop - 1].innerHTML = `(${
                  bedChildren[childLoop - 1].innerHTML
                })`;
              }
            }
          }

          //ベッド未登録領域のクローン
          const tdElemName = `id_tdbednotyet_${kurNum}`.replace("-", "_");
          const cloneTd = this.getScopedElementById(tdElemName);
          const children = cloneTd.getElementsByTagName("div");

          //組み立て
          //クールヘッダー領域の追加
          this.movingBlockElem.appendChild(cloneKurHeader);
          //クール領域の追加
          // mod 11459 スケジュール表で条件送信済実績をクール一括移動させるとフリーズ発生 関 start
          // cloneKur内のすべてのdivを取得する
          const childDivs = cloneKur.getElementsByTagName("div");
          // 新しいdivをコンテナとして作成
          const newContainerDiv = this.createScheduleElement("div");
          newContainerDiv.style.width = elemCloneWidth;
          for (let childDiv of childDivs) {
            let backgroundColor = childDiv.style.backgroundColor;
            if (backgroundColor !== "white" && backgroundColor !== "") {
              childDiv.innerText = "";
              childDiv.style.backgroundColor = "";
            }
            // 現在のdivをクローンして新しいコンテナに追加
            const clonedChildDiv = childDiv.cloneNode(true);
            newContainerDiv.appendChild(clonedChildDiv);
          }
          this.movingBlockElem.appendChild(newContainerDiv);
          // mod 11459 スケジュール表で条件送信済実績をクール一括移動させるとフリーズ発生 関 end

          const elemBedNotYet = this.createScheduleElement("div");
          elemBedNotYet.style.width = elemCloneWidth;
          //ベッド未登録領域の追加
          for (let i = 0; i < children.length; i++) {
            const cloneChild = children[i].cloneNode(true);
            elemBedNotYet.appendChild(cloneChild);
          }
          this.movingBlockElem.appendChild(elemBedNotYet);

          //画面への追加
          getMainContentAreaElement(this.$el || this.getScheduleOwnerDocument())
            .appendChild(this.movingBlockElem);

          //位置決め
          const scrollX = this.parentElem.scrollLeft;
          const scrollY = this.parentElem.scrollTop;

          const prect = this.parentElem.getBoundingClientRect();

          //移動ブロックの位置設定
          this.movingBlockElem.style.top = `${e.clientY -
          parseInt(prect.top) +
          scrollY}px`;
          this.movingBlockElem.style.left = `${e.clientX -
          parseInt(prect.left) +
          scrollX}px`;

          //移動ブロックのクラス設定
          this.movingBlockElem?.classList?.add("cls_move_block");

          //移動ブロックのid設定
          this.movingBlockElem.id = "id_move_block";

          //移動ブロック種類
          this.movingBlockKind = DEF_KUR;

          //移動するセル情報の収集
        } else {
          //この場合日付が選択される
          //ベッド確定領域+ベッド未確定領域+クール未登録領域が移動対象です

          //Idの組み立て
          const dayId = referenceNode.id;
          const dayNum = dayId.replace("id_dayheader-", "");

          const paramDim = [dayNum];
          //ブロックデータの取得(日付範囲)
          this.movingBlockInfoFrom = this.getPatBedInfo(paramDim);
          this.movingBlockInfoFromIndex = paramDim;

          let checkFlag = false;
          //データ存在チェック
          // mod #11493 スケジュール表　更新不正 関 start
          const ret = await this.checkContainData(this.movingBlockInfoFrom, "day");
          if (ret === DEF_RET_NG) {
            //データをリロードしたので終わり
            this.movingBlockElem = null;
            this.msgPopUpFlag = true;
            this.clickEventNowFlag = false;
            this.isMovePats = false;
          } else {
            checkFlag = true;
          }
          // mod #11493 スケジュール表　更新不正 関 end
          if (!checkFlag) {
            //移動するものがないメッセージ出力
            this.messageDialogInfo.stringParams = [];
            this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_3;
            // add #10601 移動元を選択したタイミングでチェックして、予定無しの場合はメッセージを出す。 linjunfeng start
            this.messageDialogInfo.title = DIALOG_MESSAGES["70000003"].title;
            // add #10601 移動元を選択したタイミングでチェックして、予定無しの場合はメッセージを出す。 linjunfeng end
            this.messageDialogInfo.type = DEF_MSGTYPE_OK;
            this.messageDialogInfo.isDialogVisible = true;
            this.messageDialogInfo.dialogNo = DEF_DIALOG_NODATA;

            this.movingBlockElem = null;
            this.msgPopUpFlag = true;
            this.clickEventNowFlag = false;
            this.isMovePats = false;
            return;
          }

          //移動可否確認
          this.setBedIdDimBlock(dayNum);

          const dimKurHeaderId = new Array(this.kurNum);
          const dimKurId = new Array(this.kurNum);
          const dimNotYetBedId = new Array(this.kurNum);
          const dimNotYetKurId = new Array(this.kurNum);
          for (let k1 = 0; k1 < this.kurNum; k1++) {
            const addNum = `${dayNum}-${k1 + 1}`;
            dimKurHeaderId[k1] = `id_kurheader${addNum}`;
            dimKurId[k1] = `id_kur${addNum}`;
            dimNotYetBedId[k1] = `id_tdbednotyet_${addNum}`.replace("-", "_");
            dimNotYetKurId[k1] = `id_tdkurnotyet_${addNum}`.replace("-", "_");
          }

          //日付ヘッダーのクローン(1個)
          const cloneDayHeader = referenceNode.cloneNode(true);
          cloneDayHeader.style.removeProperty("min-width");
          cloneDayHeader.style.removeProperty("max-width");
          cloneDayHeader.style.removeProperty("width");
          cloneDayHeader.style.boxSizing = "border-box";

          //クールヘッダー&クールのクローン(複数個)
          const dimCloneKurHeader = new Array(this.kurNum);
          const dimCloneKur = new Array(this.kurNum);
          const dimCloneNotYetBed = new Array(this.kurNum);
          const dimCloneNotYetKur = new Array(this.kurNum);

          for (let k = 0; k < this.kurNum; k++) {
            if (this.kurDayWidth[dayNum][k + 1] === 0) {
              //非表示の時は処理しない
              continue;
            }

            const kurHeaderElement = this.getScopedElementById(dimKurHeaderId[k]);
            const kurElement = this.getScopedElementById(dimKurId[k]);
            if (!kurHeaderElement || !kurElement) {
              continue;
            }
            dimCloneKurHeader[k] = kurHeaderElement.cloneNode(true);
            dimCloneKur[k] = kurElement.cloneNode(true);

            const bedChildren = dimCloneKur[k].getElementsByTagName("div");
            for (
              let childLoop2 = 1;
              childLoop2 < this.movingBlockInfoFrom[k].commitAreaData.length;
              childLoop2++
            ) {
              if (
                "isDummy" in
                this.movingBlockInfoFrom[k].commitAreaData[childLoop2] &&
                this.movingBlockInfoFrom[k].commitAreaData[childLoop2].isDummy ===
                "1"
              ) {
                if (bedChildren[childLoop2 - 1]) {
                  bedChildren[childLoop2 - 1].innerHTML = `(${
                    bedChildren[childLoop2 - 1].innerHTML
                  })`;
                }
              }
            }

            //ベッド未登録領域のセル取得
            const cloneTdBed = this.getScopedElementById(dimNotYetBedId[k]);
            dimCloneNotYetBed[k] = cloneTdBed.getElementsByTagName("div");

            //クール未登録領域のセル取得
            const cloneTdKur = this.getScopedElementById(dimNotYetKurId[k]);
            dimCloneNotYetKur[k] = cloneTdKur.getElementsByTagName("div");
          }

          //組み立て(以下のような形)
          //        <div id="id_move_block" >
          //          <table>
          //            <tr><td colspan=3></td></tr>
          //            <tr><td></td><td></td><td></td></tr>
          //          </table>
          //        </div>

          //ベースのテーブル
          const nodeTable = this.createScheduleElement("table");

          //上段のTR(日付)
          //構造:
          //<tr>
          // <td>
          //  日付ヘッダー領域
          // </td>
          //</tr>
          const nodeDayTd = this.createScheduleElement("td");
          nodeDayTd.setAttribute("colspan", this.kurNum);
          nodeDayTd.style.padding = "0px";
          //日付ヘッダー領域の追加
          nodeDayTd.appendChild(cloneDayHeader);
          const nodeTr1 = this.createScheduleElement("tr");
          nodeTr1.appendChild(nodeDayTd);

          //下段のTR(クール)
          //構造:
          //<tr>
          // <td>
          //  クールヘッダー領域
          //  クール領域
          //  ベッド未登録領域
          //  クール未登録領域
          // </td>
          //</tr>

          const nodeTr2 = this.createScheduleElement("tr");
          for (let k = 0; k < this.kurNum; k++) {
            if (this.kurDayWidth[dayNum][k + 1] === 0) {
              //非表示の時は処理しない
              continue;
            }
            const elemCloneWidth = `${DEF_KUR_WIDTH *
            this.elemResizeValue}px`;
            const elemCloneWidth2 = `${DEF_KUR_WIDTH *
            this.elemResizeValue - 1}px`;
            const nodeKurTd = this.createScheduleElement("td");
            nodeKurTd.style.padding = "0px";
            nodeKurTd.style.width = elemCloneWidth;
            dimCloneKurHeader[k].style.removeProperty("min-width");
            dimCloneKurHeader[k].style.removeProperty("max-width");
            //クールヘッダー領域の追加
            dimCloneKurHeader[k].style.width = (k === this.kurNum - 1) ? elemCloneWidth : elemCloneWidth2;
            if (k === 0) {
              dimCloneKurHeader[k].style.borderLeft = "1px solid";
            }
            nodeKurTd.appendChild(dimCloneKurHeader[k]);
            //クール領域の追加
            dimCloneKur[k].style.width = elemCloneWidth;
            // mod 11459 スケジュール表で条件送信済実績をクール一括移動させるとフリーズ発生 関 start
            const childDivs = dimCloneKur[k].getElementsByTagName("div");
            // 新しいdivをコンテナとして作成
            const newContainerDiv = this.createScheduleElement("div");
            newContainerDiv.style.width = elemCloneWidth;
            for (let childDiv of childDivs) {
              let backgroundColor = childDiv.style.backgroundColor;
              if (backgroundColor !== "white" && backgroundColor !== "") {
                childDiv.innerText = "";
                childDiv.style.backgroundColor = "";
              }
            // 現在のdivをクローンして新しいコンテナに追加
            const clonedChildDiv = childDiv.cloneNode(true);
            newContainerDiv.appendChild(clonedChildDiv);
          }
            nodeKurTd.appendChild(newContainerDiv);
            // mod 11459 スケジュール表で条件送信済実績をクール一括移動させるとフリーズ発生 関 end
            //ベッド未登録領域の追加
            for (let i = 0; i < dimCloneNotYetBed[k].length; i++) {
              const cloneChild = dimCloneNotYetBed[k][i].cloneNode(true);
              cloneChild.style.width = elemCloneWidth;
              nodeKurTd.appendChild(cloneChild);
            }
            //クール未登録領域の追加
            for (let i = 0; i < dimCloneNotYetKur[k].length; i++) {
              const cloneChild = dimCloneNotYetKur[k][i].cloneNode(true);
              cloneChild.style.width = elemCloneWidth;
              nodeKurTd.appendChild(cloneChild);
            }
            nodeTr2.appendChild(nodeKurTd);
          }

          //テーブルノードへの組み立てたTRノードの追加
          //上段のTR(日付)
          nodeTable.appendChild(nodeTr1);
          //下段のTR(クール)
          nodeTable.appendChild(nodeTr2);

          //移動ブロックへ追加
          this.movingBlockElem.appendChild(nodeTable);

          //画面への追加
          getMainContentAreaElement(this.$el || this.getScheduleOwnerDocument())
            .appendChild(this.movingBlockElem);

          // //位置決め
          const scrollX = this.parentElem.scrollLeft;
          const scrollY = this.parentElem.scrollTop;

          const prect = this.parentElem.getBoundingClientRect();

          //移動ブロックの位置設定
          this.movingBlockElem.style.top = `${e.clientY -
          parseInt(prect.top) +
          scrollY}px`;
          this.movingBlockElem.style.left = `${e.clientX -
          parseInt(prect.left) +
          scrollX}px`;

          //移動ブロックのクラス設定
          this.movingBlockElem?.classList?.add("cls_move_block");

          //移動ブロックのid設定
          this.movingBlockElem.id = "id_move_block";
          //移動ブロックの種類設定
          this.movingBlockKind = DEF_DAY;
        }

        //ヘッダー領域の表示をデフォルトに設定
        this.setHeaderInfo(null);

        this.clickEventNowFlag = false;

        //イベントリスナーを追加(ブロックの上でクリックした場合もイベントハンドリングするため)
        this.movingBlockElem.addEventListener(
          "click",
          this.clickHeadEvent,
          false
        );
        this.isMovePats = false;
      },
      /**
       * クール未登録領域の移動処理
       * @param bedDataFrom 移動元のベッド患者データ
       * @param bedIndexInfoFrom 移動元のindexデータ [0]日付[1]クール[2]ベッド
       * @param bedIndexInfoTo 移動先のindexデータ [0]日付[1]クール[2]ベッド
       */
      async moveNotYetKur(bedDataFrom, bedIndexInfoFrom, bedIndexInfoTo) {
        //クール未登録領域の移動
        //移動元の日付のクール未登録データを移動先の日付のクール未登録エリアに追加します。
        //クール未登録エリアへのドロップ処理
        //追加先:最後に追加
        //最後に追加できない(エリアが全て埋まっている)と、行を追加
        const targetDim = this.propsJKurNotYet[bedIndexInfoTo[0]][this.kurNum][
          this.dispNumNotYetKur
          ];
        if (targetDim !== null && typeof targetDim !== DEF_UNDEFINED) {
          //行追加
          ++this.dispNumNotYetKur;
        }

        this.propsJKurNotYet[bedIndexInfoTo[0]][this.kurNum][
          this.dispNumNotYetKur
          ] = bedDataFrom;

        //移動先の値の取得(ベッドコード、クールコード、治療日)
        const newBedCd = DEF_NOTASSIGNED;
        const newKurCd = DEF_NOTASSIGNED;
        const newTreatDate = this.propsJDayHeader[bedIndexInfoTo[0]].date;

        //add #10601 スケジュール表動作不正 start
        this.beforeMoveDataList.push(bedDataFrom)
        this.afterMoveDataList.push(this.afterScheduleInfoConvert(bedDataFrom,newTreatDate,newKurCd,newBedCd))
        //add #10601 スケジュール表動作不正 end

        //ベッドコードをクリア
        this.propsJKurNotYet[bedIndexInfoTo[0]][this.kurNum][
          this.dispNumNotYetKur
          ].bed_cd = newBedCd;

        //クールコードを設定
        this.propsJKurNotYet[bedIndexInfoTo[0]][this.kurNum][
          this.dispNumNotYetKur
          ].kur_cd = newKurCd;

        //日付を設定
        this.propsJKurNotYet[bedIndexInfoTo[0]][this.kurNum][
          this.dispNumNotYetKur
          ].treatDate = newTreatDate;

        //当該日付のクール未登録領域の再配置

        this.relocateKurNotYet(bedIndexInfoTo[0]);
        //各未登録領域の最大セル数の確認
        this.checkNotYetAreaMax();
      },
      /**
       * クールブロックの移動処理
       * @param bedDataFrom 移動元のベッド患者データ
       * @param bedIndexInfoFrom 移動元のindexデータ [0]日付[1]クール[2]ベッド
       * @param bedDataTo 移動先のベッド患者データ
       * @param bedIndexInfoTo 移動先のindexデータ [0]日付[1]クール[2]ベッド
       */
      async moveBlockKur(
        bedDataFrom,
        bedIndexInfoFrom,
        bedDataTo,
        bedIndexInfoTo
      ) {

        //クールブロックの処理
        this.resetBedIdDimForDelete();
        //確定エリアの確認&移動
        for (let b = 1; b < bedDataFrom.commitAreaData.length; b++) {
          if (!this.getBedDispState(b - 1)) {
            //非表示状態のものは処理しません。
            continue;
          }
          //mod #10601 スケジュール表動作不正 start
          const fromData = deepCopy(bedDataFrom.commitAreaData[b]);
          const toData = deepCopy(bedDataTo.commitAreaData[b]);
          //mod #10601 スケジュール表動作不正 end

          // add bug 6034 修正 chen start
          if (fromData.dialysisState + "" !== "0") {
            //非表示状態のものは処理しません。
            continue;
          }
          // add bug 6034 修正 chen end
          if (this.checkNameEffective(fromData) && fromData.isDummy === "0") {
            //移動元に患者がいる場合は、個別の移動処理
            if (this.checkBedStatus(fromData)) {

              //add #10601 スケジュール表動作不正 start
              this.beforeMoveDataList.push(fromData)
              this.afterMoveDataList.push(this.afterScheduleInfoConvert(fromData,toData.treatDate,toData.kur_cd,toData.bed_cd))
              //add #10601 スケジュール表動作不正 end
              //データ移動
              //データを入れる
              const tmp = {};
              tmp.index = bedIndexInfoTo; //宛先のIndex配列 [0]日付[1]クール[2]ベッド
              tmp.index[2] = b;
              tmp.data = fromData; //移動元のデータ

              //deep copy
              const tmp2 = JSON.parse(JSON.stringify(tmp));

              //移動先のクールコンポーネントへ知らせる
              this.propsJMoveData[bedIndexInfoTo[0]].splice(
                bedIndexInfoTo[1],
                1,
                tmp2
              );

              //移動元のダミー情報の取得
              const paramJson = {};
              paramJson.treatTime = fromData.treatTime;
              paramJson.kurIndex = Number(bedIndexInfoFrom[1]);
              this.dummyKurIndexFrom = this.getDummyInfo(paramJson);

              //クールコンポーネントに削除を知らせる処理(本体+ダミー)
              const indexDimParam = [];
              //本体分
              const fmIndex = bedIndexInfoFrom;
              fmIndex[2] = b;
              indexDimParam[indexDimParam.length] = fmIndex;
              //ダミー分のIndex配列
              let indexDay = 0;
              let preKurIndex = this.dummyKurIndexFrom[0];
              for (let i = 1; i < this.dummyKurIndexFrom.length; i++) {
                if (preKurIndex > this.dummyKurIndexFrom[i]) {
                  ++indexDay;
                }
                preKurIndex = this.dummyKurIndexFrom[i];
                const targetDayIndex =
                  Number(bedIndexInfoFrom[0]) + Number(indexDay);
                const dummyIndex = [
                  targetDayIndex,
                  this.dummyKurIndexFrom[i],
                  bedIndexInfoFrom[2]
                ];
                indexDimParam[indexDimParam.length] = dummyIndex;
              }

              //クールコンポーネントに削除を知らせる処理
              this.setBedIdDimForDelete(indexDimParam);
              //ストアに削除を知らせる処理
              this.setClearPatInfoOnBed(indexDimParam);

              //ストアのセル情報を入れ替える処理
              const indexJson = {};
              indexJson.From = fmIndex;
              indexJson.To = tmp.index;
              this.swapCellInfo(indexJson);

            }
          }
        }
        //ベッド未登録領域の移動
        const tmpBedNotYetFromData = bedDataFrom.bedNotYetAreaData;
        for (let bbb = 1; bbb < tmpBedNotYetFromData.length; bbb++) {
          //ベッド未登録領域への追加
          const targetDim = this.propsJBedNotYet[bedIndexInfoTo[0]][
            bedIndexInfoTo[1]
            ][this.dispNumNotYetBed];
          if (targetDim !== null && typeof targetDim !== DEF_UNDEFINED) {
            //一行増やす
            ++this.dispNumNotYetBed;
          }
          //最後に追加
          this.propsJBedNotYet[bedIndexInfoTo[0]][bedIndexInfoTo[1]][
            this.dispNumNotYetBed
            ] = tmpBedNotYetFromData[bbb];

          //移動先の値の取得(ベッドコード、クールコード、治療日)
          const newBedCd = 0;
          const newKurCd = this.getKurCd(bedIndexInfoTo[1]);
          const newTreatDate = this.propsJDayHeader[bedIndexInfoTo[0]].date;

          //add #10601 スケジュール表動作不正 start
          this.beforeMoveDataList.push(tmpBedNotYetFromData[bbb])
          this.afterMoveDataList.push(this.afterScheduleInfoConvert(tmpBedNotYetFromData[bbb],newTreatDate,newKurCd,newBedCd))
          //add #10601 スケジュール表動作不正 end
          //ベッドコードをクリア
          this.propsJBedNotYet[bedIndexInfoTo[0]][bedIndexInfoTo[1]][
            this.dispNumNotYetBed
            ].bed_cd = newBedCd;

          //クールコードを設定
          this.propsJBedNotYet[bedIndexInfoTo[0]][bedIndexInfoTo[1]][
            this.dispNumNotYetBed
            ].kur_cd = newKurCd;

          //日付を設定
          this.propsJBedNotYet[bedIndexInfoTo[0]][bedIndexInfoTo[1]][
            this.dispNumNotYetBed
            ].treatDate = newTreatDate;

          //ベッド未登録領域からの削除
          //移動元データの削除
          //削除元のindex
          //this.movingBlockInfoFromIndex
          this.propsJBedNotYet[bedIndexInfoFrom[0]][bedIndexInfoFrom[1]][
            bbb
            ] = null;
        }
        //当該日付&クールのベッド未登録領域の再配置
        this.relocateBedNotYet(bedIndexInfoTo[0], bedIndexInfoTo[1]);
        //ストア情報の更新
        //移動元のベッド未登録エリア
        this.resetBedNotYetInfoOnStore(bedIndexInfoFrom);
        //移動先のベッド未登録エリア
        this.resetBedNotYetInfoOnStore(bedIndexInfoTo);
      },
      // add 10601 スケジュール表動作不正 関  start
      /**
       * クールブロックの移動処理
       * @param bedDataFrom 移動元のベッド患者データ
       * @param bedIndexInfoFrom 移動元のindexデータ [0]日付[1]クール[2]ベッド
       * @param bedDataTo 移動先のベッド患者データ
       * @param bedIndexInfoTo 移動先のindexデータ [0]日付[1]クール[2]ベッド
       */
      async moveBlockKur2(
        bedDataFrom,
        bedIndexInfoFrom,
        bedDataTo,
        bedIndexInfoTo
      ) {
        //クールブロックの処理
        this.resetBedIdDimForDelete();
        //確定エリアの確認&移動
        for (let b = 1; b < bedDataFrom.commitAreaData.length; b++) {
          if (!this.getBedDispState(b - 1)) {
            //非表示状態のものは処理しません。
            continue;
          }
          const fromData = deepCopy(bedDataFrom.commitAreaData[b]);
          const toData = deepCopy(bedDataTo.commitAreaData[b]);

          if (fromData.dialysisState + "" !== "0") {
            //非表示状態のものは処理しません。
            continue;
          }
          if (this.checkNameEffective(fromData) && fromData.isDummy === "0") {
            //移動元に患者がいる場合は、個別の移動処理
            if (this.checkBedStatus(fromData)) {

              this.beforeMoveDataList.push(fromData)
              this.afterMoveDataList.push(this.afterScheduleInfoConvert(fromData,toData.treatDate,toData.kur_cd,toData.bed_cd))

            }
          }
        }
        //ベッド未登録領域の移動
        const tmpBedNotYetFromData = bedDataFrom.bedNotYetAreaData;
        for (let bbb = 1; bbb < tmpBedNotYetFromData.length; bbb++) {
          //ベッド未登録領域への追加
          const targetDim = this.propsJBedNotYet[bedIndexInfoTo[0]][
            bedIndexInfoTo[1]
            ][this.dispNumNotYetBed];
          if (targetDim !== null && typeof targetDim !== DEF_UNDEFINED) {
            //一行増やす
            ++this.dispNumNotYetBed;
          }
          //最後に追加
          this.propsJBedNotYet[bedIndexInfoTo[0]][bedIndexInfoTo[1]][
            this.dispNumNotYetBed
            ] = tmpBedNotYetFromData[bbb];

          //移動先の値の取得(ベッドコード、クールコード、治療日)
          const newBedCd = 0;
          const newKurCd = this.getKurCd(bedIndexInfoTo[1]);
          const newTreatDate = this.propsJDayHeader[bedIndexInfoTo[0]].date;

          this.beforeMoveDataList.push(tmpBedNotYetFromData[bbb])
          this.afterMoveDataList.push(this.afterScheduleInfoConvert(tmpBedNotYetFromData[bbb],newTreatDate,newKurCd,newBedCd))
        }
      },
      // mod 10601 スケジュール表動作不正 関  end
      /**
       * 有効なセルが含まれているかの確認
       *@return 0(DEF_RET_OK):すべて有効なセル -1(DEF_RET_NG):非有効なセルが含まれている -2(DEF_RET_NG_RELOAD):データが不整合なセルがある
       */
      // mod #11493 スケジュール表　更新不正 関 start
      async checkContainData(dataJson, flag) {

         let batchMoveList = [];

        //確定エリアの確認(すべてのベッドを調べる)

        if (flag == "kur") {
          const commitAreaData = dataJson.commitAreaData;
          let commitAreaDataList = [];
           for (let i = 1; i < commitAreaData.length; i++) {
          if (!this.getBedDispState(i - 1)) {
            //非表示状態なので処理しない
            continue;
          }

          //有効(名称が設定されている) && ダミースケジュールではない && 治療状況がOK
          if (
            this.checkNameEffective(commitAreaData[i]) &&
            commitAreaData[i].isDummy === "0" &&
            commitAreaData[i].dialysisState === "0"
          ) {
            commitAreaDataList.push(commitAreaData[i]);
          }
        }

         batchMoveList = [...dataJson.bedNotYetAreaData, ...commitAreaDataList]
          .filter(item => item != null);
        }else if (flag == "day") {
          let commitAreaDataList = [];
          let bedNotYetAreaData = [];
          let kurNotYetAreaData = [];
          for (let index = 0; index < dataJson.length-1; index++) {
            for (let j = 1; j < dataJson[index].commitAreaData.length; j++) {
              if (!this.getBedDispState(j - 1)) {
                //非表示状態なので処理しな
                continue;
              }
              //有効(名称が設定されている) && ダミースケジュールではない && 治療状況がOK
              if (this.checkNameEffective(dataJson[index].commitAreaData[j])
              && dataJson[index].commitAreaData[j].isDummy === "0"
              && dataJson[index].commitAreaData[j].dialysisState === "0") {
                commitAreaDataList.push(dataJson[index].commitAreaData[j]);
              }
            }
            for (let i = 1; i < dataJson[index].bedNotYetAreaData.length; i++) {
              bedNotYetAreaData.push(dataJson[index].bedNotYetAreaData[i]);
            }
          }
          for (let k = dataJson.length-1; k < dataJson.length; k++) {
            for (let index = 1; index < dataJson[k].length; index++) {
              kurNotYetAreaData.push(dataJson[k][index]);
            }
          }
          batchMoveList = [...commitAreaDataList, ...bedNotYetAreaData, ...kurNotYetAreaData]
          .filter(item => item != null);
        }
        if (batchMoveList.length == 0) {
          return DEF_RET_NG;
        }

        let ret = false;
        const uri = "/ntss-admin-web/api/scheduleList/checkBatchMovePatExistance";
        let facilityCd = this.getFacilityCd;

        var response = await axios.post(`${uri}/${facilityCd}`,batchMoveList).then(
            function(response) {
              ret = response.data;
            }.bind(ret)
          )
          .catch(error => {
            getErrorMessage('ScheduleListMainItem.vue', 'checkContainData', error);
            throw error;
          });

        if (!ret) {
          this.messageDialogInfo.stringParams = [];
          this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_11;
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.isDialogVisible = true;
          this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;
          this.msgPopUpFlag = true;
          this.clickEventNowFlag = false;

          //ヘッダー表示リセット
          this.setHeaderDispDefaultMode();
          this.refreshData();
          return DEF_RET_NG_RELOAD;
        }
      },
      // mod #11493 スケジュール表　更新不正 関 end
      /**
       * ホイールイベント
       * 確定エリア、ベッド未登録エリア、クール未登録エリアのスクロール連動を行う
       * @param e イベント変数
       */
      mouseWheelEvent(e) {
        //--------------------------------------------
        //現在のエリア(ポインタの存在するエリア)を確認

        const nowId = e.target.id;

        let areaFlagBed = false;
        let areaFlagNotYetBed = false;
        let areaFlagNotYetKur = false;

        if (nowId.startsWith("id_bedBednotYet") || nowId.startsWith("id_area7")) {
          areaFlagNotYetBed = true;
        } else if (
          nowId.startsWith("id_bedKurnotYet") ||
          nowId.startsWith("id_area8")
        ) {
          areaFlagNotYetKur = true;
        } else if (nowId.startsWith("id_bed") || nowId.startsWith("id_area6")) {
          areaFlagBed = true;
        } else {
          return;
        }

        //--------------------------------------------
        //ホイール情報を確認
        //  e.wheelDelta
        //    +120:上方向へホイールを動かした
        //    -120:下方向へホイールを動かした
        const wheelDirection = -Math.sign(e.wheelDelta);

        //ベッド確定エリア
        const elemArea10 = this.getScopedElementById("id_area10");
        //ベッド未登録エリア
        const elemArea11 = this.getScopedElementById("id_area11");
        //クール未登録エリア
        const elemArea12 = this.getScopedElementById("id_area12");

        //--------------------------------------------
        // スクロール対象エリアを取得
        if (areaFlagBed) {
          //確定エリア上でのスクロール
          this.scrollArea(wheelDirection, elemArea10, elemArea11, elemArea12);
        } else if (areaFlagNotYetBed) {
          //ベッド未登録エリア上でのスクロール
          this.scrollArea(wheelDirection, elemArea11, elemArea12, elemArea10);
        } else if (areaFlagNotYetKur) {
          //クール未登録エリア上でのスクロール
          this.scrollArea(wheelDirection, elemArea12, elemArea11, elemArea10);
        }
      },
      /**
       * 縦スクロール実行
       * メインエリア->2ndエリア->3rdエリアの順にスクロールを伝播させる
       * @param wheelDirection ホイール方向 -1:上 1:下
       * @param areaElem1st スクロールのメインエリア
       * @param areaElem2nd スクロールの2ndエリア(メインエリアが動けなくなった場合に動き出すエリア)
       * @param areaElem3rd スクロールの3rdエリア(2ndエリアが動けなくなった場合に動き出すエリア)
       */
      scrollArea(wheelDirection, areaElem1st, areaElem2nd, areaElem3rd) {
        const beforePosY = areaElem1st.scrollTop;
        areaElem1st.scrollTop += wheelDirection * 10;
        const afterPosY = areaElem1st.scrollTop;
        if (beforePosY === afterPosY) {
          //動かせなかった場合の処理
          //2ndエリアをスクロールさせます
          const beforePosY = areaElem2nd.scrollTop;
          areaElem2nd.scrollTop += wheelDirection * 10;
          const afterPosY = areaElem2nd.scrollTop;
          if (beforePosY === afterPosY) {
            //動かせなかった場合の処理
            //3rdエリアをスクロールさせます
            areaElem3rd.scrollTop += wheelDirection * 10;
          }
        }
      },
      /**
       * 表全体のデータの設定
       * @param startDate 表示開始日付(yyyymmdd) nullの場合は、当日を採用
       */
      setListData(startDate) {
        //---------------------------------------------------------
        //日付ヘッダー&クールヘッダーの設定

        //表示の基準日をmoment化
        let dt = null === startDate ? dayjs() : dayjs(startDate); //指定日付の取得

        //指定日を真ん中にする補正
        //例)14日出す場合、基準日の前が7日、後ろは基準日を含めて7日
        const minusDayNum = -1 * Math.floor(this.dayMax / 2);
        dt = dt.add(minusDayNum, "days");

        //スクロール表示開始位置の計算
        this.scrollStartPosX = Math.floor(
          -1 *
          minusDayNum *
          this.kurNum *
          DEF_KUR_WIDTH *
          this.elemResizeValue
        );

        //日付数分ループする
        for (let d = 1; d <= this.dayMax; ++d) {
          this.propsJDayHeader[d] = {};

          //-----------------------------------------------
          //処理中の日付の文字列化(yyyymmdd)

          const y = dt.year();
          const m = `00${dt.month() + 1}`.slice(-2);
          const day = `00${dt.date()}`.slice(-2);
          const result = `${y}${m}${day}`;

          //日付(yyyymmdd)格納
          this.propsJDayHeader[d].date = result;
          this.propsJDayHeader[d].startDate = null === startDate ? dayjs().format("YYYY/MM/DD") : startDate; //指定日付の取得

          //1日進める
          dt = dt.add(1, "days");

          //ストアから当該日のデータ取得(引数:yyyymmdd)
          const treatDataFromStore = this.getBedsData(result);

          if (treatDataFromStore !== null) {
            //日付ヘッダーの設定
            this.propsJDayHeader[d].inpatnum = treatDataFromStore.numInTotal;
            this.propsJDayHeader[d].outpatnum = treatDataFromStore.numOutTotal;
            this.propsJDayHeader[d].undecidednum = treatDataFromStore.numUndecidedTotal;
            // add FNSI-集計数の修正 徐 start
            this.propsJDayHeader[d].notOutAndInpatnum = treatDataFromStore.numNotOutAndInTotal;
            // add FNSI-集計数の修正 徐 end

            //-----------------------------------------------
            //クールヘッダー&ベッド未登録の設定

            for (let k = 1; k <= this.kurNum; k++) {
              //----------------------------------------------
              // クールヘッダーの処理
              //   クール名、入外区分数を設定します(患者総数はクールヘッダーコンポーネント内で計算)

              const kurDataFromStore = treatDataFromStore[k - 1];

              //クールヘッダー用バインド変数(配列)の取得
              const tmp = JSON.parse(JSON.stringify(this.propsJKurHeader[d][k]));

              //クール名の設定
              tmp.kurname = this.getKurNames[k - 1];

              //入院患者数の設定
              const tmpNumIn =
                typeof kurDataFromStore !== DEF_UNDEFINED &&
                "numIn" in kurDataFromStore
                  ? kurDataFromStore.numIn
                  : 0;
              tmp.inpatnum = tmpNumIn;

              //外来患者数の設定
              const tmpNumOut =
                typeof kurDataFromStore !== DEF_UNDEFINED &&
                "numOut" in kurDataFromStore
                  ? kurDataFromStore.numOut
                  : 0;
              tmp.outpatnum = tmpNumOut;

              // ベッド未登録患者数の設定
              const tmpNumUndecided =
                typeof kurDataFromStore !== DEF_UNDEFINED &&
                "numUndecided" in kurDataFromStore
                  ? kurDataFromStore.numUndecided
                  : 0;
              tmp.undecidednum = tmpNumUndecided;
              // add FNSI-集計数の修正 徐 start
              // 不明患者数の設定
              const tmpNuMnotOutAndIn =
                typeof kurDataFromStore !== DEF_UNDEFINED &&
                "nuMnotOutAndIn" in kurDataFromStore
                  ? kurDataFromStore.nuMnotOutAndIn
                  : 0;
              tmp.notOutAndInpatnum = tmpNuMnotOutAndIn;
              // add FNSI-集計数の修正 徐 end

              //クールヘッダー用バインド変数(配列)に格納
              this.propsJKurHeader[d].splice(k, 1, tmp);

              //ベッド未登録部の設定
              // あれば、バインド変数に設定
              if (
                typeof kurDataFromStore !== DEF_UNDEFINED &&
                AREA_BEDNOTYET in kurDataFromStore
              ) {
                this.propsJBedNotYet[d].splice(k, 1, kurDataFromStore.bedNotYet);
              }
            }

            //クール未登録データがあるかの確認
            //※treatDataFromStoreに「クール数+1」番目の要素がある場合、存在すると定義している
            if (
              treatDataFromStore.length === this.kurNum + 1 &&
              "beddata" in treatDataFromStore[this.kurNum]
            ) {
              //クール未登録があったので処理をおこなう

              //クール未登録データ(ベッド)一覧を取得
              const kurNotYetDataFromStore =
                treatDataFromStore[this.kurNum].beddata;

              //格納先のクリア
              for (let k1 = 1; k1 <= this.kurNum; k1++) {
                for (let b1 = 0; b1 < this.dispNumNotYetKur + 1; b1++) {
                  this.propsJKurNotYet[d][k1].splice(b1, 1, null);
                }
              }

              //データは乙型に格納していく
              // 外ループは、ベッド要素数分
              // 内ループは、クール数分を繰り返す

              let indexNum = 1; //ベッド要素のindex
              const kurDataNum = kurNotYetDataFromStore.length - 1; //クール未登録データ数(要素0はダミーなのでlength-1)

              //mod FNSI-改修内容フィルタ条件設定 房 start
              let disPlayFlg = false;
              for (let k3 = 1; k3 <= this.kurNum; k3++) {
                if (this.kurDayWidth[d][k3] !== 0) {
                  //クールが隠れている場合は、処理対象外
                  disPlayFlg = true;
                  break;
                }
              }
              if (disPlayFlg) {
                outlooplabel: for (let b = 1; ; b++) {
                  if (this.dispNumNotYetKur < b) {
                    ++this.dispNumNotYetKur;
                  }

                  for (let k3 = 1; k3 <= this.kurNum; k3++) {
                    if (indexNum > kurDataNum) {
                      //  データが無くなったので処理終了(外ループの終了)
                      break outlooplabel;
                    }
                    if (this.kurDayWidth[d][k3] === 0) {
                      //クールが隠れている場合は、処理対象外
                      continue;
                    }
                    // ベッド要素の格納
                    this.propsJKurNotYet[d][k3].splice(
                      b,
                      1,
                      kurNotYetDataFromStore[indexNum++]
                    );
                  }
                }
              }
              //mod FNSI-改修内容フィルタ条件設定 房 end
            }
          } else {
            //日付に対応するデータがない場合の処理

            //クールヘッダーのクリア設定

            for (let k4 = 1; k4 <= this.kurNum; k4++) {
              const tmp = JSON.parse(JSON.stringify(this.propsJKurHeader[d][k4]));
              // クール名の設定(クール名一覧から取得)
              tmp.kurname = this.getKurNames[k4 - 1];
              //入院患者数の設定(=0)
              tmp.inpatnum = 0;
              //外来患者数の設定(=0)
              tmp.outpatnum = 0;
              // ベッド未登録患者数の設定(=0)
              tmp.undecidednum = 0;
              //クールヘッダーコンポーネントのPropsに設定
              this.propsJKurHeader[d].splice(k4, 1, tmp);
            }
          }
        }

        // //各未登録領域の最大セル数の確認
        this.checkNotYetAreaMax();

        //強制書き換えイベント
        this.requestViewForceUpdate();
      },

      /**
       * 表示期間(1週,2週 or 3週)の変更
       * @param num 週の指定 0:表示条件設定から取得 1,2,3
       */
      async changeDispTerm(num) {
        //選択期間の取得
        //3週が選ばれた場合で、まだカラム作成がされていなかった場合は、カラム作成し、kendoヘッダー領域へコンポーネント紐付けも行います(1回だけの処理)
        this.dayHeaderNum3rd = 7;

        //日付の計算とバインド変数への格納
        this.dayMax = this.dispWeek * 7;
        this.tmp_dayMax = this.dayMax;

        clearInterval(this.relocateId);
        this.relocateId = setInterval(
          function() {
            const elem = this.getScopedElementById("id_dayheader-21");
            if (elem !== null) {
              //kendo-gridへのコンポーネントの紐付け
              this.relocateKendoHeaders("both", 14);

              //幅初期化
              for (let d0 = 2; d0 <= this.dayMax; d0++) {
                for (let k0 = 1; k0 <= this.kurNum; k0++) {
                  this.kurDayWidth[d0][k0] = this.kurDayWidth[1][k0];
                }
              }

              clearInterval(this.relocateId);
            }
          }.bind(this),
          100
        );
        // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou start
        this.dispStartDate = this.getSettingStartDate();
        // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou end
        //データの再取得
        await this.loadScheduleData({
          facilityCd: this.getFacilityCd,
          dayNum: this.dayMax,
          overFlowDayNum: this.overFlowDayNum,
          baseDate: this.dispStartDate
        });

        //mod FNSI-改修内容フィルタ条件設定 房 start
        //幅の変更
        this.setDayDisplay(this.dispWeek);
        //表全体のデータの設定
        this.setListData(this.dispStartDate);
        //mod FNSI-改修内容フィルタ条件設定 房 end

        // add FNSI-休日表示の修正 徐 start
        if (!this.holidayFlag) {
          await this.changeHolidayDispState();
        }
        // add FNSI-休日表示の修正 徐 end
        this.requestViewForceUpdate();
      },
      /**
       スクロール位置の変更
       */
      async setScrollStartPos() {
        //スクロール位置をずらす
        this.resizeListHeight();

        this.watchScrollSet();
      },
      /**
       * スクロール位置計算用日数取得
       * @return スクロール位置計算用日数
       */
      getScrollDayNum() {
        // 休日表示がOFF かつ 基準日が休日の場合
        // 基準日に近い表示されている過去日を表示での左端となるようにスクロールを調整する。
        const dimDayDispInfo = this.getDayDispIndex;
        let baseDateNum = Math.floor(this.dayMax / 2);
        let daysTmp = baseDateNum;
        // 基準日より前の非表示になっている日数分減算する
        for (let i = 0; i <= baseDateNum; i++) {
          if (!dimDayDispInfo[i]) {
            daysTmp--;
          }
        }

        return daysTmp;
      },
      /**
       * 表示日数変更処理
       *  @param dispWeek 表示週数 1~3
       */
      setDayDisplay(dispWeek) {
        //ベッド・ベッド未登録・クール未登録
        this.dispWeek = dispWeek;
        this.dayMax = dispWeek * 7;
        if (this.tmp_dayMax !== 0) {
          //一番最初(=0の時)は、ここで値を設定しない
          this.tmp_dayMax = this.dayMax;
        }

        let setWidthTotal = 0;

        for (let d = 0; d < this.dayHeaderNum; d++) {
          for (let k = 0; k < this.kurNum; k++) {
            if (this.kurWidth[k + 1] === 0 || d >= this.dayMax) {
              this.kurDayVisibility[d + 1].splice(k + 1, 1, "hidden");
              this.kurDayWidth[d + 1].splice(k + 1, 1, 0);
            } else {
              this.kurDayVisibility[d + 1].splice(k + 1, 1, "visible");
              this.kurDayWidth[d + 1].splice(k + 1, 1, DEF_KUR_WIDTH);
              setWidthTotal += DEF_KUR_WIDTH;
            }
          }
        }

        this.totalWidth = setWidthTotal;

        //最下スクロールバーのスクロールの幅を強制設定
        this.getScopedElementById(
          "id_underbar_content9").style.width = `${setWidthTotal}px`;

        //日付ヘッダ(kendo grid)の表示非表示化
        // Vue3 + Kendo Native bridge では、非表示列の DOM col が既に存在しない場合があり、
        // jQuery Kendo の hideColumn が内部で style を参照して落ちることがある。
        // Vue2 と同じ「表示日数に応じて日付列を表示/非表示にする」語義は維持しつつ、
        // 日付ヘッダは runtime 側で安全に可視状態を同期する。
        for (let d1 = 0; d1 < this.dayHeaderNum; d1++) {
          this.setDayHeaderColumnDisplay(d1, d1 < this.dayMax, this.dayWidth);
        }

        //クールヘッダ(kendo grid)の表示非表示化
        // Vue3 の jQuery Kendo Grid では、列DOMの再生成タイミングにより hideColumn が
        // 内部で存在しない col.style を参照することがあるため、Vue2 の表示語義を
        // ページ側のクール幅・表示状態からDOMへ同期する。
        for (let dd = 0; dd < this.dayHeaderNum; dd++) {
          for (let kk = 0; kk < this.kurNum; kk++) {
            const columnIndex = dd * this.kurNum + kk;
            const visible = !(this.kurWidth[kk + 1] === 0 || dd >= this.dayMax);
            this.setKurHeaderColumnDisplay(columnIndex, visible, visible ? this.kurWidth[kk + 1] : 0);
          }
        }
        this.queueDayHeaderLayoutSync();

        //強制書き換えイベント
        this.requestViewForceUpdate();
      },
      /**
       * 表示開始日付の変更
       */
      async changeStartDate() {
        //設定年の取得
        this.dispStartDate = this.getSettingStartDate();

        //表示年の切り出し&設定
        this.dispStartYear = this.dispStartDate.slice(0, 4);
      },
      /**
       * 日付をyyyymmddに整形する処理
       * @param dt momentオブジェクト
       * @return フォーマット済み文字列 yyyymmdd
       */
      formatMomentDateYYYYMMDD(dt) {
        const y = dt.year();
        const m = `00${dt.month() + 1}`.slice(-2);
        const day = `00${dt.date()}`.slice(-2);
        return y + m + day;
      },
      /**
       * 表示条件設定:ベッドグループの表示状態の変更処理
       * オプションの選択状態に合わせてカラムの表示・非表示をおこなう
       */
      async changeBedGroupState(value) {
        //オプションの要素取得
        let sendBedInfo = "all";
        let selectedRoomBedGroup = 0;
        if (value !== "all") {
          sendBedInfo = Number(value);
          selectedRoomBedGroup = Number(value);
        }

        //ベッドグループ情報設定(ストア)
        this.setBedDispInfo(sendBedInfo);
        this.selectedRoomBedGroupCd = selectedRoomBedGroup;
      },
      /**
       * ターゲットの日付を隠す
       * @param d 隠す日付 index値
       */
      hiddenDay(d) {
        //日付数分のループ
        //クール数分のループ
        for (let k = 0; k < this.kurNum; k++) {
          //プロパティのバインド変数の値をhidden(非表示)へ変更
          this.kurDayVisibility[d + 1].splice(k + 1, 1, "hidden");
          //プロパティのバインド変数の値を0へ変更
          this.kurDayWidth[d + 1].splice(k + 1, 1, 0);
        }

        //kendo grid はバインドせずに地道にメソッドで設定していく

        //クールヘッダーの幅設定
        // Vue2 と同じ日付非表示語義を、Vue3 では列DOMへ直接同期する。
        for (let k2 = 0; k2 < this.kurNum; k2++) {
          const columnIndex = d * this.kurNum + k2;
          this.setKurHeaderColumnDisplay(columnIndex, false, 0);
        }

        //日付ヘッダーの幅の設定
        this.setDayHeaderColumnDisplay(d, false, 0);

        //全体の更新
        this.requestViewForceUpdate();
      },

      /**
       * 表示条件設定:クールカラムの表示状態の変更処理
       * オプションの選択状態に合わせてカラムの表示・非表示をおこなう
       */
      async changeKurDispState(value) {
        //オプションの要素取得
        // sanjingye: 1: 午前 2: 午後
        // sanjingye: 1:kurList[0] 2:kurList[1]...
        const optionElems = value.split(":");

        //クールヘッダ(領域的にはベッド、ベッド未登録、クール未登録)のバインド変数をすべて非表示(hidden&0)で初期化
        for (let i = 1; i <= this.kurNum; i++) {
          this.kurWidth[i] = 0;
        }

        // 1. sanjingye comment start ---
        // sanjingye: Table header(date) change
        //クールヘッダ(領域的にはベッド、ベッド未登録、クール未登録)のバインド変数を初期化状態から選択状態を元に表示化(visible&100)
        this.selectedKurIndexList = [];
        for (const option of optionElems) {
          if (option !== "") {
            this.kurWidth[Number(option)] = DEF_KUR_WIDTH;
            this.selectedKurIndexList = [
              ...this.selectedKurIndexList,
              Number(option)
            ];
          }
        }
        // 1.sanjingye end ---

        //ベッド・ベッド未登録・クール未登録

        //表示幅の計算用変数を初期化
        let setWidthTotal = 0;

        //--------------------------------------------
        //クールコンポーネントの表示・非表示の設定

        // 2. sanjingye comment start ---
        // sanjingye: Bed part shows what the filter do.
        // sanjingye: Kur's counts are shown as much as the filter wants, but it doesn't drop off what the filter does.
        // sanjingye: e.g. It's 20 morning and afternoon Kurs totally include 10 morning and 10 afternoon Kurs alternant, and it shows 5 morning and 5 afternoon Kurs when I select morning only.
        //日付数分のループ
        for (let d = 0; d < this.dayMax; d++) {
          if (!this.holidayFlag && !this.getDayDispIndex[d]) {
            //休日非表示で、該当する日は、スキップ
            continue;
          }

          //クール数分のループ
          for (let k = 0; k < this.kurNum; k++) {
            if (this.kurWidth[k + 1] === 0 || d >= this.dayMax) {
              //プロパティのバインド変数の値をhidden(非表示)へ変更
              this.kurDayVisibility[d + 1].splice(k + 1, 1, "hidden");
              //プロパティのバインド変数の値を0へ変更
              this.kurDayWidth[d + 1].splice(k + 1, 1, 0);
            } else {
              //プロパティのバインド変数の値をvisible(表示)へ変更
              this.kurDayVisibility[d + 1].splice(k + 1, 1, "visible");
              //プロパティのバインド変数の値をDef.DEF_KUR_WIDTHへ変更
              this.kurDayWidth[d + 1].splice(k + 1, 1, DEF_KUR_WIDTH);
              //表示幅に加算
              setWidthTotal += DEF_KUR_WIDTH;
            }
          }
        }
        // 2.sanjingye end

        this.totalWidth = setWidthTotal;

        //--------------------------------------------
        //各クールコンポーネントへの表示通知
        for (let k2 = 0; k2 < this.kurNum; k2++) {
          this.propsBKurDispFlag.splice(k2 + 1, 1, this.kurWidth[k2 + 1] !== 0);
        }

        //--------------------------------------------
        //クール未登録領域の再配置
        // 日付ヘッダー数分ループ
        for (let d2 = 1; d2 <= this.dayMax; d2++) {
          if (!this.holidayFlag && !this.getDayDispIndex[d2 - 1]) {
            //休日非表示で、該当する日は、スキップ
            continue;
          }
          //  当該日付のクール未登録領域の再配置
          this.relocateKurNotYet(d2);
        }
        //各未登録領域の最大セル数の確認
        this.checkNotYetAreaMax();

        //--------------------------------------------
        //最下スクロールバーのスクロールの幅を強制設定
        this.getScopedElementById(
          "id_underbar_content9").style.width = `${setWidthTotal}px`;

        //--------------------------------------------
        //日付ヘッダー幅の計算
        let setDayWidth = 0;
        for (let i2 = 1; i2 <= this.kurNum; i2++) {
          setDayWidth += this.kurWidth[i2];
        }

        //-----------------------------------------
        //クールヘッダーの幅設定
        //kendo grid はバインドせずに地道にメソッドで設定していく

        //※columsのベースindexは、0

        for (let d3 = 0; d3 < this.dayMax; d3++) {
          if (!this.holidayFlag && !this.getDayDispIndex[d3]) {
            //休日非表示で、該当する日は、スキップ
            continue;
          }
          for (let k3 = 0; k3 < this.kurNum; k3++) {
            const columnIndex = d3 * this.kurNum + k3;
            const visible = !(this.kurWidth[k3 + 1] === 0 || d3 >= this.dayMax);
            this.setKurHeaderColumnDisplay(columnIndex, visible, visible ? this.kurWidth[k3 + 1] : 0);
          }
        }

        //-----------------------------------------
        //日付ヘッダーの幅の設定
        //kendo grid はバインドせずに地道にメソッドで設定していく

        //※columsのベースindexは、0

        for (let d4 = 0; d4 < this.dayHeaderNum; d4++) {
          const dayVisible = d4 < this.dayMax && (this.holidayFlag || this.getDayDispIndex[d4]);
          this.setDayHeaderColumnDisplay(d4, dayVisible, dayVisible ? setDayWidth : 0);
        }

        //-----------------------------------------
        //リスト全体横幅の表示変更

        this.resizeList();
        this.queueDayHeaderLayoutSync();

        //-----------------------------------------
        //全体の更新
        this.requestViewForceUpdate();
      },
      /**
       * ベッド未登録データの再配置処理
       * 指定された日付＆クール領域のベッド未登録データを再配置する
       * @param d 日付インデックス
       * @param k クールインデックス
       */
      relocateBedNotYet(d, k) {
        //一旦退避
        let setData = null;

        const stackDim = new Array(this.dispNumNotYetBed + 1);

        //退避配列をnull初期化
        for (let b = 0; b <= this.dispNumNotYetBed; b++) {
          stackDim[b] = null;
        }

        let stackDimIndex = 0;

        //領域をサーチ
        for (let b = 1; b <= this.dispNumNotYetBed; b++) {
          //セット(ただし、入っているデータのみ)
          if (typeof this.propsJBedNotYet[d][k][b] === DEF_UNDEFINED) {
            this.propsJBedNotYet[d][k][b] = null;
          }

          if (this.propsJBedNotYet[d][k][b] !== null) {
            stackDim[stackDimIndex++] = this.propsJBedNotYet[d][k][b];
          }
        }

        //再配置

        stackDimIndex = 0;
        for (let b = 1; b <= this.dispNumNotYetBed; b++) {
          setData = stackDim[stackDimIndex++];
          //値の再セット
          this.propsJBedNotYet[d][k].splice(b, 1, setData);
        }

        //各未登録領域の最大セル数の確認
        this.checkNotYetAreaMax();

        this.requestViewForceUpdate();
      },
      /**
       * クール未登録データの再配置処理
       * 指定された日付領域のクール未登録データを再配置する
       * @param d 日付インデックス
       */
      relocateKurNotYet(d) {
        //一旦退避
        let setData = null;

        const stackDim = new Array(this.kurNum * this.dispNumNotYetKur);
        //スタック領域をnull初期化
        for (let i = 0; i < stackDim.length; i++) {
          stackDim[i] = null;
        }
        let stackDimIndex = 0;

        //領域を乙型にサーチ
        for (let b = 1; b <= this.dispNumNotYetKur; b++) {
          for (let k = 1; k <= this.kurNum; k++) {
            //セット(ただし、入っているデータのみ)
            if (typeof this.propsJKurNotYet[d][k][b] === DEF_UNDEFINED) {
              //未定義だったらnullを代入しておく
              this.propsJKurNotYet[d][k][b] = null;
            }
            if (this.propsJKurNotYet[d][k][b] !== null) {
              stackDim[stackDimIndex++] = this.propsJKurNotYet[d][k][b];
              //スタックしたのでnullクリアしておく
              this.propsJKurNotYet[d][k][b] = null;
            }
          }
        }

        //再配置

        let relocateStackDimIndex = 0;
        outlooplabel: for (let b2 = 1; ; b2++) {
          if (this.dispNumNotYetKur < b2) {
            ++this.dispNumNotYetKur;
          }
          for (let k2 = 1; k2 <= this.kurNum; k2++) {
            if (relocateStackDimIndex >= stackDimIndex) {
              //  データが無くなったので処理終了(外ループの終了)
              break outlooplabel;
            }
            if (this.kurDayWidth[d][k2] === 0) {
              //非表示領域には空データセット
              setData = null;
            } else {
              //表示領域には有効データセット
              setData = stackDim[relocateStackDimIndex++];
            }
            //値の再セット
            this.propsJKurNotYet[d][k2].splice(b2, 1, setData);
          }
        }

        this.requestViewForceUpdate();
      },
      /**
       * 表示条件設定:予定あり表示の更新
       */
      async changePlanDispState(value) {
        this.setPlanSetting(value);
      },
      /**
       * 表示条件設定:定期点検・水質検査予定あり表示の更新
       */
      async changePlanMainteWaterDispState(value) {
        this.setPlanSettingMainteWater(value);
      },
      /**
       * 表示条件設定:不一致表示の更新
       */
      async changeUnmatchDispState(value) {
        this.setUnmatchSetting(value);
      },
      /**
       * 表示条件設定:休日表示の更新
       *   ※この関数を実行した後、クール表示変更this.changeKurDispState()を呼び出すこと
       */
      async changeHolidayDispState() {
        this.setHolidayDispStateFlag(this.holidayFlag);

        // 休日情報を取得
        const dimDayDispInfo = this.getDayDispIndex;
        //休日を隠す
        // mod FNSI-改修内容フィルタ条件設定 房 start
        for (let i = 0; i < dimDayDispInfo.length; i++) {
          if (!dimDayDispInfo[i] && i < this.dayMax) {
            this.hiddenDay(i);
          }
        }
        // mod FNSI-改修内容フィルタ条件設定 房 end
        const kendoDayElement = this.getScopedElementById("kendo_day");
        const kendoElems = kendoDayElement?.getElementsByTagName("table") || [];
        const kendoTable = kendoElems[0];
        if (!kendoTable) {
          return;
        }

        const style = this.getScheduleOwnerWindow().getComputedStyle(kendoTable);
        const underbarContent = this.getScopedElementById("id_underbar_content9");
        if (underbarContent) {
          //最下スクロールバーのスクロールの幅を強制設定
          underbarContent.style.width = style.width;
        }
      },

      /**
       * 表示条件設定:名前表示の更新
       */
      async changeNameDispState(value) {
        this.setNameSetting(value);
      },
      /**
       * 表示条件設定の差分確認
       * @param beforeSetting 設定(変更前)
       * @param afterSetting  設定(変更後)
       * @return true:変更あり false:変更なし
       */
      checkDiffDispSettingInfo(beforeSetting, afterSetting) {
        let ret = false;
        for (const prop in beforeSetting) {
          if (beforeSetting[prop] !== afterSetting[prop]) {
            //不一致が見つかったので終了
            ret = true;
            break;
          }
        }
        return ret;
      },

      /**
       * 表示条件設定用ポップオーバー表示処理
       * @param e イベント変数
       */
      showPopOver(e) {
        //表示抑制処理
        // セル移動、ブロック移動中は表示しない
        if (null !== this.movingChipElem || null !== this.movingBlockElem) {
          return;
        }
        //-----------------------------------------------------
        //現在の設定の取得(変更を検知するために保存する)

        // TODO: popover一旦コメントアウト
        // this.dispSettingNow = this.getDispSettingInfo();

        //-----------------------------------------------------
        //ポップオーバを表示
        this.showPopoverSetting(e, "down", true);
      },
      /**
       * SELECTBOXの選択値の取得
       */
      getSelectBoxIntValue(elemId) {
        return parseInt(this.getScopedElementById(elemId).value);
      },
      closePopOver() {
        this.popoverVisible = false;
      },
      /**
       *	マウスが場外に移動したイベント
       */
      moveLeaveEvent() {
        //なにもしない
        return;

        //上のreturnを無効にして、以下のコメントを外すと、欄外にポインタ移動した場合
        //チップを消します
        //ただし、再び領域内に戻ってきてもチップは復活しません

        //      if (null === this.movingChipElem && null === this.movingBlockElem) {
        //        //移動チップまたは移動ブロックがいないので処理しない
        //        return;
        //      }
        //
        //      if (this.msgPopUpFlag) {
        //        //メッセージポップアップ中も処理しない
        //        return;
        //      }
        //
        //      //チップがあった場合、キャンセル扱いにします
        //      if (null !== this.movingChipElem) {
        //        //移動のキャンセル処理
        //        // チップを削除
        //        this.movingChipElem.parentNode.removeChild(this.movingChipElem);
        //        // もう移動が終わったのでポインタを初期化
        //        this.movingChipElem = null;
        //
        //        //点滅停止
        //        this.setOpaSwitch("off");
        //
        //        //終了
        //        this.clickEventNowFlag = false;
        //        return;
        //      }
      },
      /**
       *	移動イベント(親)
       */
      moveEvent(e) {
        if (null === this.movingChipElem && null === this.movingBlockElem) {
          //移動チップまたは移動ブロックがいないので処理しない
          return;
        }

        if (this.clickEventNowFlag) {
          //クリックイベント処理中は処理しない
          return;
        }

        //移動対象を確認&設定
        const targetElem =
          null !== this.movingChipElem
            ? this.movingChipElem
            : this.movingBlockElem;

        //チップの移動
        targetElem.style.top = `${e.clientY - 100}px`;
        targetElem.style.left = `${e.clientX - this.sidebarWidth}px`;

        //スクロール判定
        const areaElem = this.getScopedElementById("id_area6");
        const areaRect = areaElem.getBoundingClientRect();

        const posX = e.clientX - areaRect.left;
        const posY = e.clientY - areaRect.top;

        //左右の判定
        const scrollWidth = 10;
        const scrollHeight = 10;

        this.autoScrollX = 0;
        this.autoScrollY = 0;

        const defaultVal = 5;

        //左右の判定
        if (posX >= 0 && 0 + scrollWidth >= posX) {
          //左スクロール
          this.autoScrollX = -defaultVal;
        } else if (
          posX <= areaRect.width &&
          0 + (areaRect.width - scrollWidth) <= posX
        ) {
          //右スクロール
          this.autoScrollX = defaultVal;
        }
        //上下の判定
        if (posY >= 0 && 0 + scrollHeight >= posY) {
          //上スクロール
          this.autoScrollY = -defaultVal;
        } else if (
          posY <= areaRect.height &&
          0 + (areaRect.height - scrollHeight) <= posY
        ) {
          //下スクロール
          this.autoScrollY = defaultVal;
        }

        //スクロールの繰り返し処理
        clearInterval(this.scrollIntervalId);

        if (!(this.autoScrollX === 0 && this.autoScrollY === 0)) {
          clearInterval(this.scrollIntervalId);
          this.scrollIntervalId = setInterval(
            function() {
              const areaElem = this.getScopedElementById("id_area6");
              areaElem.scrollTop += this.autoScrollY;
              areaElem.scrollLeft += this.autoScrollX;
              this.autoScrollY *= 1.3;
              if (this.autoScrollY > 20) this.autoScrollY = 20;
              this.autoScrollX *= 1.3;
              if (this.autoScrollX > 20) this.autoScrollX = 20;

              //スクロールの同期
              //                                  this.scrollEvent(e) ;
            }.bind(this),
            100
          );
        }
      },
      /**
       *	移動チップの作成確認
       */
      async createChipCheck(e) {
        //クリックしたセルのIDを取得
        const nowId = e.target.id;
		  // add 7216 【デグレ】患者経過総合ビューア画面で治療開始時刻を変更してもsys_coop_journalにイベントが作成されない zhao start
        this.initBad = nowId;
		  // add 7216 【デグレ】患者経過総合ビューア画面で治療開始時刻を変更してもsys_coop_journalにイベントが作成されない zhao end
        //移動対象かどうかのチェック
        //移動対象は以下(idで判定)
        //  id_bed(ベッド確定エリア)
        //  id_bedBednotYet(ベッド未確定エリア)
        //  id_bedKurnotYet(クール未確定エリア)

        if (!(0 === nowId?.indexOf("id_bed"))) {
          //idで判定。ベッドセル以外は非移動対象、何もしない
          // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
          this.setIsPatientEnabled(false)
          // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
          return;
        }

        //-------------------------------------------------------
        //移動元の確認(idから確認)

        //移動元エリア種別のフラグ化
        const bedNotYetFlag = 0 === nowId?.indexOf("id_bedBednotYet"); //ベッド未登録エリアフラグ
        const kurNotYetFlag = 0 === nowId?.indexOf("id_bedKurnotYet"); //クール未登録エリアフラグ

        //移動元の情報用文字列(移動元がどこのエリアだったかという情報)
        let infoStr = "";
        //移動元のindex配列
        let dimIndex = [];
        //ダミー情報(From)用変数のクリア(空配列)
        this.dummyKurIndexFrom = [];

        //----------------------------------------------
        //移動元による処理

        if (kurNotYetFlag) {
          //--------------------------------------------------------
          //移動元がクール未登録エリアの場合の処理
          //--------------------------------------------------------

          //移動元のデータの確認 Idからindex情報を抜き出します
          //構造は、id_bedKurnotYet + 日付index + "-" + クールindex + "-" + ベッドindex
          dimIndex = nowId.replace("id_bedKurnotYet", "").split("-");
          //セルに設定されている情報を取得
          const item = this.propsJKurNotYet[dimIndex[0]][dimIndex[1]][
            dimIndex[2]
            ];
          if (item === null || typeof item === DEF_UNDEFINED) {
            //データがないセル(クール未登録エリアの場合、=null)は移動対象外
            //ヘッダー表示をクリアするための情報セット
            this.setHeaderDispDefaultMode();
            return;
          }
          //移動元の情報を保持領域に設定
          this.moveFromData = JSON.parse(JSON.stringify(item));

          //患者の存在チェック
          let ret = false;
          await this.checkPatExistance(this.moveFromData)
            .then(
              function(response) {
                ret = response;
              }.bind(ret)
            )
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('ScheduleListMainItem.vue', 'createChipCheck', error);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              throw error;
            });

          if (!ret) {
            //データが無くなっていた
            return;
          }

          //ヘッダー表示を設定するための情報セット
          this.setHeaderDispPatMode(item);

          // add FNSI 権限 start -- Sanjingye Sun 20201231
          if(!this.haveAuthority) {
            return;
          }
          // add FNSI 権限 end -- Sanjingye Sun 20201231

          //移動元の情報用文字列を設定(後でチップに付与する)
          infoStr = AREA_KURNOTYET;

          //点滅指示
          this.setOpaSwitch(`on-${dimIndex[0]}`);
        } else if (bedNotYetFlag) {
          //--------------------------------------------------------
          //移動元がベッド未登録エリアの場合の処理
          //--------------------------------------------------------
          //移動元のデータの確認 Idからindex情報を抜き出します
          //構造は、id_bedBednotYet + 日付index + "-" + クールindex + "-" + ベッドindex
          dimIndex = nowId.replace("id_bedBednotYet", "").split("-");
          //セルに設定されている情報を取得
          const item = this.propsJBedNotYet[dimIndex[0]][dimIndex[1]][
            dimIndex[2]
            ];

          if (item === null || typeof item === DEF_UNDEFINED) {
            //データがないセル(ベッド未登録エリアの場合、=null)は移動対象外
            //ヘッダー表示をクリアするための情報セット
            this.setHeaderDispDefaultMode();
            return;
          }
          //移動元の情報を保持領域に設定
          this.moveFromData = JSON.parse(JSON.stringify(item));
          //患者の存在チェック
          let ret = false;
          await this.checkPatExistance(this.moveFromData)
            .then(
              function(response) {
                ret = response;
              }.bind(ret)
            )
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('ScheduleListMainItem.vue', 'createChipCheck', error);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              throw error;
            });

          if (!ret) {
            //データが無くなっていた
            return;
          }
          //ヘッダー表示を設定するための情報セット
          this.setHeaderDispPatMode(item);

          // add FNSI 権限 start -- Sanjingye Sun 20201231
          if(!this.haveAuthority) {
            return;
          }
          // add FNSI 権限 end -- Sanjingye Sun 20201231

          //移動元の情報用文字列を設定(後でチップに付与する)
          infoStr = AREA_BEDNOTYET;
          //点滅指示
          this.setOpaSwitch(`on-${dimIndex[0]}-${dimIndex[1]}`);
        } else {
          //--------------------------------------------------------
          //移動元が確定エリアの場合の処理
          //--------------------------------------------------------

          //ヘッダー情報の設定処理
          //名前をチェックしてあれば表示、なければデフォルト
          //クールコンポーネント全体でIDをチェック
          //(クールコンポーネント内で)自分自身が対象なら、該当するベッドをチェック
          dimIndex = nowId.replace("id_bed", "").split("-");
          // add FNSI 権限 start -- Sanjingye Sun 20201231
          if(!this.haveAuthority) {
            return;
          }
          // add FNSI 権限 end -- Sanjingye Sun 20201231

          //クリックしたセルの情報の取得
          const mvFm = this.getPatBedInfo(dimIndex);

          // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
          const state = Number(mvFm.dialysisState)
          if (!isNaN(state) && state > 2) {
            this.setIsPatientEnabled(false)
          }
          // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
          infoStr = AREA_BED;
          if (mvFm === null || !this.checkNameEffective(mvFm)) {
            // add 11493 スケジュール表　更新不正 関 start
            this.setBedIdDim(dimIndex);
            // add 11493 スケジュール表　更新不正 関 end
            //データがないセルとデータは有っても未割付のセル(名前が設定されていない)は移動対象外
          } else if ("isDummy" in mvFm && mvFm.isDummy === "1") {
            // add 11493 スケジュール表　更新不正 関 start
            this.setBedIdDim(dimIndex);
            // add 11493 スケジュール表　更新不正 関 end
            //ダミーデータは移動対象外です
            this.messageDialogInfo.stringParams = [];
            this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_12;
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
            this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;
          } else {
            //患者の存在チェック
            const ret = await this.checkPatExistance(mvFm);

            if (!ret) {
              //データが無くなっていた
              return;
            }
            // add 11493 スケジュール表　更新不正 関 start
            this.setBedIdDim(dimIndex);
            // add 11493 スケジュール表　更新不正 関 end
            //-------------------------------------
            //治療状況の確認
            const moveOkFlag = this.checkBedStatus(mvFm);
            if (moveOkFlag) {
              // 条件送信確認済みの場合、クリック時点で移動確認ダイアログを表示する
              if (await this.showMoveCheckDialog(mvFm.dialysisState)){
                // 治療状況がOKでダミースケジュールでなければチップを作成
                this.moveFromData = JSON.parse(JSON.stringify(mvFm));
                //ダミー情報の取得
                const paramJson = {};
                paramJson.treatTime = mvFm.treatTime;
                paramJson.kurIndex = Number(dimIndex[1]);
                this.dummyKurIndexFrom = this.getDummyInfo(paramJson);
                this.createChip(e, infoStr, dimIndex);
              }
            } else {
              // チップは作成しないが、後続処理の為データを格納
              this.moveFromData = JSON.parse(JSON.stringify(mvFm));
              // 操作メニューポップアップを表示する
              this.menuPopoverTarget = e.target;
              this.menuPopoverShowFlag = true;
            }
          }

          return;
        }

        //チップの生成
        this.createChip(e, infoStr, dimIndex);
      },
      // 条件送信確認済みの場合、クリック時点で移動確認ダイアログを表示する(応答を待つ為、別メソッドに)
      async showMoveCheckDialog(state) {
        if (state === "2") {
          let rtn = false;
          await this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            title: DIALOG_MESSAGES[13000122].title,
            message: messageFormat(DIALOG_MESSAGES[13000122].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                rtn = true;
              }
            }
          });
          return rtn;
        } else {
          return true;
        }
      },
      /**
       * 移動しようとするベッドの治療状況ステータスをチェック
       * @param bedInfo ベッド情報
       * @return true:移動可能
       */
      checkBedStatus(bedInfo) {
        let ret = false;
        //参考: dialysisState
        // 0：条件送信前、1：条件送信済、2：条件送信確認済み、3：治療中、4：排液済、5：後体重測定済み(実績未確定)、6：後体重確認済み(過去実績)
        if (
          !("dialysisState" in bedInfo) ||
          bedInfo.dialysisState === "0" ||
          bedInfo.dialysisState === "1" ||
          bedInfo.dialysisState === "2"
        ) {
          //治療状況がない、または0:条件送信前、1：条件送信済、1：条件送信確認済
          ret = true;
        }
        return ret;
      },
      /**
       * プロパティの存在チェック
       * 以下をチェックし、ひとつでも該当すればtrueを返却
       * 1.指定したプロパティが存在しない
       * 2.プロパティの値がnull
       * 2.プロパティの値が空文字
       * @prams body 検査対象(Json)
       * @prams propName プロパティ
       */
      checkPropIsNull(body, propName) {
        const ret =
          !(propName in body) || body[propName] === "" || body[propName] === null;
        return ret;
      },
      /**
       * 移動チップの作成
       * @param e イベント変数
       * @param infoStr 移動元識別文字列 AREA_BED,AREA_BEDNOTYET,AREA_KURNOTYET
       * @param dimIndex 移動元のindex配列 [0]日付[1]クール[2]ベッド
       */
      createChip(e, infoStr, dimIndex) {
        //クリックしたセルのIDの取得
        const nowId = e.target.id;

        //識別名称の格納
        this.moveFromInfo = infoStr;

        //インデックス情報の格納
        this.moveFromIndex = dimIndex;

        //チップの作成(クローン)
        this.movingChipElem = e.target.cloneNode(true);
        const rect = e.target.getBoundingClientRect();

        this.movingChipElem.style.width = `${parseInt(rect.width)}px`;
        this.movingChipElem.style.height = `${parseInt(rect.height)}px`;

        //クラス設定
        this.movingChipElem?.classList?.add("cls_move_chip");

        //id設定
        this.movingChipElem.id = `id_chip_${nowId}`;

        //親要素に追加
        this.parentElem.appendChild(this.movingChipElem);

        this.movingChipElem.style.top = `${parseInt(rect.top) - 100}px`;
        this.movingChipElem.style.left = `${parseInt(rect.left) -
        this.sidebarWidth}px`;
        // 選択セルを枠線に緑する
        e.target.classList.add("item-row-checked");
      },
      /**
       *	治療患者データ1件を作成
       * @param ordInfo 治療情報
       * @return データ1件({ pat_id, pat_last_name, pat_first_name, ord_no, kur_name, bed_name, is_same })
       */
      createTreatmentPatData(ordInfo) {
        // データの入力
        const ret = {
          ord_no: ordInfo.ordNo,
          kur_name: ordInfo.kur_cd === 0 ? "クール未登録" : ordInfo.kur_name, // クール未登録の場合
          pat_id: ordInfo.pat_id,
          pat_last_name: ordInfo.patLastName,
          pat_first_name: ordInfo.patFirstName,
          is_same: ordInfo.isSame,
          in_out_class: ordInfo.inOutClass,
          ...ordInfo
        };
        // ベッド名の検索
        if (ordInfo.bed_cd === 0) {
          ret.bed_name = "ベッド未登録";
        } else {
          for (let idx = 0; idx < this.getMaxBedNum; idx++) {
            if (this.getBedCd(idx + 1) === ordInfo.bed_cd) {
              ret.bed_name = this.getBedName(idx);
              continue;
            }
          }
        }

        return {
          ...ret,
          ...ordInfo
        };
      },
      /**
       * クリックしたセルを含む列のデータを取得
       * @param {Boolean} moveEnd true:移動後 false:移動前
       */
      setSelectedColumn(moveEnd) {

        const selectedColumnData = [];
        const BaseData = moveEnd ? this.moveToData : this.moveFromData;

        // 列のデータを取得
        const selectedDateBedsData = this.getBedsData(BaseData.treatDate);
        if (selectedDateBedsData === null) {
          // 取得失敗の場合、何もしない
          return;
        }

        if (BaseData.kur_cd === 0) {
          // クール未登録を選択した場合
          const FilteredBedsData = selectedDateBedsData.filter(
            data => data.kur === "kurNotYet"
          );
          const bedData = FilteredBedsData[0].beddata;
          for (const ordInfo of bedData) {
            if (
              ordInfo !== null &&
              ordInfo.ordNo &&
              ordInfo.patFirstName !== "" &&
              ordInfo.patLastName !== ""
            ) {
              selectedColumnData.push(this.createTreatmentPatData(ordInfo));
            }
          }
        } else {
          // クール未登録以外を選択した場合
          const FilteredBedsData = selectedDateBedsData.filter(
            data => data.kur === BaseData.kur_name
          );
          // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm start
          let bedData = FilteredBedsData[0].beddata;
          let roomBedCds = [];
          if(this.getRoomBedGroupData && this.selectedRoomBedGroupCd !== 0) {
            let roomBedGroup = this.getRoomBedGroupData.find(rbr => rbr.roomBedGroupCd === this.selectedRoomBedGroupCd);
            if(roomBedGroup) {
              roomBedCds = roomBedCds.concat(
                JSON.parse(roomBedGroup.bedList)
              );
            }
          }
          // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm end
          for (const ordInfo of bedData) {
            if (
              ordInfo !== null &&
              ordInfo.ordNo &&
              ordInfo.patFirstName !== "" &&
              ordInfo.patLastName !== ""
            ) {
              // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm start
              if (0 === roomBedCds.length || roomBedCds.includes(ordInfo.bed_cd)) {
              // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm end
                selectedColumnData.push(this.createTreatmentPatData(ordInfo));
              // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm start
              }
              // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm end
            }
          }
          const bedNotYet = FilteredBedsData[0].bedNotYet;
          for (const ordInfo of bedNotYet) {
            if (
              ordInfo !== null &&
              ordInfo.ordNo &&
              ordInfo.patFirstName !== "" &&
              ordInfo.patLastName !== ""
            ) {
              selectedColumnData.push(this.createTreatmentPatData(ordInfo));
            }
          }
        }
        this.updateTreatmentPatList(selectedColumnData);
      },
      /**
       *	クリックイベント(親)
       *  ※セル移動の開始、終了イベント
       */
      async clickEvent(e) {
        this.setIsScheduleEnabled(false)

        if(!this.facilitySettingDialogOpenFlg){
          this.setIsPatientEnabled(true)

          if (this.movingBlockElem !== null) {
            //ブロック移動中のため、無視
            return;
          } else if (this.clickEventNowFlag) {
            //処理中のため、無視
            return;
          }
        }
        this.setIsPatientEnabled(true)
        this.createJournalParam = {
          facility_cd: this.getFacilityCd,
          hosp_pat_id: this.moveFromData.hospPatId,
          pat_id : this.moveFromData.pat_id,
          ord_no : this.moveFromData.ordNo,
          base_date: this.moveFromData.treatDate,
          user_id: this.getUserId
        };
        this.clickEventNowFlag = true; //クリックイベント中フラグ on ※処理中はセルの移動処理(moveEvent)を抑制するためのフラグです

        this.msgPopUpFlag = false;
        if (null === this.movingChipElem) {
          this.setLoadingScreenVisible(true);
          //-------------------------------------
          //移動チップがいない場合
          //-------------------------------------

          // チップ作成チェック&作成
          this.createChipCheck(e).then(() => {
            this.setSelectedColumn(false);
            this.clickEventNowFlag = false;
          });
        } else {
          this.setIsPatientEnabled(false)
          //-------------------------------------
          //移動チップがいる場合
          //-------------------------------------
          // 落とす処理
          // 下の要素は何かを確認
          if(!this.facilitySettingDialogOpenFlg) {
            this.underElem = this.getScheduleElementFromPoint(e.clientX, e.clientY);
          }
          let initBedCd = null;
          if (Object.prototype.hasOwnProperty.call(this.moveFromData, "bed_cd")) {
            initBedCd = this.moveFromData.bed_cd;
          }

          //一瞬チップを消す(理由:チップ上でクリックしたことになるので、一時的に消して下の要素を取得する)
          this.movingChipElem.style.display = "none";

          //チップをだす
          this.movingChipElem.style.display = "inline";

          //下のセルのチェック
          const nowId = this.underElem.id;
          if (!(0 === nowId?.indexOf("id_bed"))) {
            //非移動対象の場合(idがid_bedで始まらない(つまりベッドセル以外の)セルな)ので)、何もしない
            this.clickEventNowFlag = false;

            return;
          }

          //落とせるかどうかのチェック
          //落とし先の確認
          const kurNotYetFlag = 0 === nowId?.indexOf("id_bedKurnotYet");
          const bedNotYetFlag = 0 === nowId?.indexOf("id_bedBednotYet");

          //移動先情報の文字列とindex([0]日付 [1]クール [2]ベッド)の取得
          this.moveToInfo = AREA_BED;
          this.moveToIndex = nowId.replace("id_bed", "").split("-");
          let initDate;
          let initStr = this.initBad.replace("id_bed", "");
          if (/^[\d]/.test(initStr)) {
            initDate = initStr.split('-')[0];
          } else if (initStr?.indexOf("BednotYet") === 0) {
            initDate = initStr.replace("BednotYet", "").split('-')[0];
          } else if (initStr?.indexOf("KurnotYet") === 0) {
            initDate = initStr.replace("KurnotYet", "").split('-')[0];
          }

          let editDate;
          let editStr = this.moveToIndex[0];
          if (/^[\d]/.test(editStr)) {
            editDate = editStr
          } else if (editStr?.indexOf("BednotYet") === 0) {
            editDate = editStr.replace("BednotYet", "");
          } else if (editStr?.indexOf("KurnotYet") === 0) {
            editDate = editStr.replace("KurnotYet", "");
          }

          if (initDate != editDate) {
            if (this.hasAuthorityByCd(AUTHORITY_CODES.SCHE_MOVE)
              && !(this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT)
                || this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT))) {
              this.clickEventNowFlag = false;
              this.$ons.notification.alert({
                title: DIALOG_MESSAGES[12000315].title,
                message: messageFormat(DIALOG_MESSAGES[12000315].message, "治療指示")
              });
              return;
            }
          }
          let initBad = this.initBad.replace("id_bed", "").split("-")[2];
          let editBad = this.moveToIndex[2];
          let initCur = this.initBad.replace("id_bed", "").split("-")[1];
          let editCur = this.moveToIndex[1];
          this.isCreateJournal = false;
          if (nowId == this.initBad) {
            if (bedNotYetFlag) {
              this.moveToInfo = AREA_BEDNOTYET;
              this.moveToIndex = nowId.replace("id_bedBednotYet", "").split("-");
            } else if (kurNotYetFlag) {
              this.moveToInfo = AREA_KURNOTYET;
              this.moveToIndex = nowId.replace("id_bedKurnotYet", "").split("-");
            }
          } else if (initCur != editCur && initBad != editBad && (0 === this.initBad?.indexOf("id_bedBednotYet")) && !kurNotYetFlag && !bedNotYetFlag) {
            this.createJournalParam.crud = "U";
            this.createJournalParam.ope_cd = "009001";
            this.isCreateJournal = true;
          } else if (bedNotYetFlag && (0 === this.initBad?.indexOf("id_bedBednotYet"))) {
            this.moveToInfo = AREA_BEDNOTYET;
            this.moveToIndex = nowId.replace("id_bedBednotYet", "").split("-");
            this.createJournalParam.crud = "U";
            this.createJournalParam.ope_cd = "009001";
            this.isCreateJournal = true;
          }else if (bedNotYetFlag && (0 === this.initBad?.indexOf("id_bedKurnotYet"))) {
            this.moveToInfo = AREA_BEDNOTYET;
            this.moveToIndex = nowId.replace("id_bedBednotYet", "").split("-");
            this.createJournalParam.crud = "C";
            this.createJournalParam.ope_cd = "009003";
            this.isCreateJournal = true;
          } else if (kurNotYetFlag && (0 === this.initBad?.indexOf("id_bedBednotYet"))) {
            this.moveToInfo = AREA_KURNOTYET;
            this.moveToIndex = nowId.replace("id_bedKurnotYet", "").split("-");
            this.createJournalParam.crud = "D";
            this.createJournalParam.ope_cd = "009002";
            this.isCreateJournal = true;
          } else if (bedNotYetFlag) {
            this.moveToInfo = AREA_BEDNOTYET;
            this.moveToIndex = nowId.replace("id_bedBednotYet", "").split("-");
            this.createJournalParam.crud = "U";
            this.createJournalParam.ope_cd = "009006";
            this.isCreateJournal = true;
          } else if (0 === this.initBad?.indexOf("id_bedBednotYet")) {
            this.createJournalParam.crud = "C";
            this.createJournalParam.ope_cd = "009004";
            this.isCreateJournal = true;
          } else if (kurNotYetFlag) {
            this.moveToInfo = AREA_KURNOTYET;
            this.moveToIndex = nowId.replace("id_bedKurnotYet", "").split("-");
            this.createJournalParam.crud = "D";
            this.createJournalParam.ope_cd = "009002";
            this.isCreateJournal = true;
          } else if (0 === this.initBad?.indexOf("id_bedKurnotYet")) {
            this.createJournalParam.crud = "C";
            this.createJournalParam.ope_cd = "009003";
            this.isCreateJournal = true;
          } else if (initBad != editBad) {
            this.createJournalParam.crud = "U";
            this.createJournalParam.ope_cd = "009005";
            this.isCreateJournal = true;
          } else if (initCur != editCur) {
            this.createJournalParam.crud = "U";
            this.createJournalParam.ope_cd = "009001";
            this.isCreateJournal = true;
          }
          const mvTo = this.getPatBedInfo(this.moveToIndex);
          if (!(kurNotYetFlag || bedNotYetFlag)) {
            if (Object.prototype.hasOwnProperty.call(mvTo, "ordNo")) {
              let ret = false;
              await this.checkPatExistance(mvTo)
                .then(
                  function(response) {
                    ret = response;
                  }.bind(ret)
                )
                .catch(error => {
                  getErrorMessage('ScheduleListMainItem.vue', 'clickEvent', error);
                  throw error;
                });
              if (!ret) {
                //データが無くなっていた
                return;
              }
            }
          }

          //落とし先の配列Indexの確認

          //自分自身に落とそうとした場合は、移動キャンセル扱い
          // 判定:「同じエリア」&&「すべてのインデックス値が一致する」場合
          const areaFlag = this.moveToInfo === this.moveFromInfo;
          const indexFlag = String(this.moveToIndex) === String(this.moveFromIndex);
          if (areaFlag && indexFlag) {
            //------------------------------------------
            //移動のキャンセル処理
            //------------------------------------------
            // 選択状態表示（緑枠線）解除
            this.removeCheckClass();
            // チップを削除
            this.movingChipElem.parentNode.removeChild(this.movingChipElem);
            // もう移動が終わったのでポインタを初期化
            this.movingChipElem = null;

            //点滅停止
            this.setOpaSwitch("off");

            //終了
            this.clickEventNowFlag = false;
            EventBus.$emit("changeMismatchVa", false);
            EventBus.$emit("changeMismatchInfection", false);
            EventBus.$emit("changeMismatchTreatment", false);
            return;
          }

          // 指示者入力チェック
          if (!this.indUser) {
            this.messageDialogInfo.stringParams = ["指示者"];
            this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_16;
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
            this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

            this.msgPopUpFlag = true;
            this.clickEventNowFlag = false;
            return;
          }
            const paramDim = [this.moveToIndex[0], this.moveToIndex[1]];
            const kurBlockInfoTo = this.getPatBedInfo(paramDim);
          //現在の患者情報(不一致チェック用)の取得
            let retJson = null;
            await this.getPatInfoForCheck(this.moveFromData.ordNo)
              .then(
                function(response) {
                  retJson = response;
                }.bind(retJson)
              )
              .catch(error => {
                getErrorMessage('ScheduleListMainItem.vue', 'clickEvent', error);
                throw error;
              });

            //------------------------------------------------------------
            // 不一致チェック

            //チェック用のパラメータ準備
            // TODO:
            const checkTargetJson = {};
            checkTargetJson.kur_cd = this.moveFromData.kur_cd;
            checkTargetJson.bed_cd = this.moveFromData.bed_cd;
            checkTargetJson.target_bed_cd = kurBlockInfoTo.commitAreaData[this.moveToIndex[2]].bed_cd;
            if (kurNotYetFlag || bedNotYetFlag) {
              checkTargetJson.target_bed_cd = "";
            }

            //最新情報に書き換え
            this.moveFromData.vaDirect = retJson.va_direct;
            this.moveFromData.isInfect = retJson.is_infect;
            this.moveFromData.deviceMode = retJson.device_mode;

            checkTargetJson.vaDirect = this.moveFromData.vaDirect;
            checkTargetJson.isInfect = this.moveFromData.isInfect;
            checkTargetJson.deviceMode = this.moveFromData.deviceMode;

            //不一致チェックを実施
            this.unmatchResultJson = this.getUnmatchInfo(checkTargetJson);

            //ダイアログ設定初期化(メッセージを出す場合に備える)
            this.messageDialogInfo.dialogNo = DEF_DIALOG_NOUSE;

            if (this.unmatchResultJson.unmatchFlag) {
              if (this.getSystemSettingUnmatchShowMsgFlag && !this.facilitySettingDialog1000OpenedFlg) {
                this.clickEventNowFlag = false;
                //不一致があり&&システム設定での不一致確認がtrue

                let outMsg = "";
                if (!this.unmatchResultJson.infectionFlag) {
                  outMsg += "感染症";
                  EventBus.$emit("changeMismatchInfection", true);
                } else {
                  EventBus.$emit("changeMismatchInfection", false);
                }
                if (!this.unmatchResultJson.shuntFlag) {
                  if (outMsg !== "") {
                    outMsg += "・";
                  }
                  outMsg += "VA位置";
                  EventBus.$emit("changeMismatchVa", true);
                } else {
                  EventBus.$emit("changeMismatchVa", false);
                }
                if (!this.unmatchResultJson.deviceModeFlag) {
                  if (outMsg !== "") {
                    outMsg += "・";
                  }
                  outMsg += "治療方法";
                  EventBus.$emit("changeMismatchTreatment", true);
                } else {
                  EventBus.$emit("changeMismatchTreatment", false);
                }

                //ダイアログを出力
                const dispStr = outMsg;
                this.facilitySettingDialog1000OpenedFlg = true;
                this.messageDialogInfo.stringParams = [dispStr];
                this.messageDialogInfo.title = "ベッド条件不一致";
                this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_2;
                this.messageDialogInfo.type = DEF_MSGTYPE_OK_CANCEL;
                this.messageDialogInfo.isDialogVisible = true;
                this.messageDialogInfo.dialogNo = DEF_DIALOG_UNMATCH;

                this.msgPopUpFlag = true;
                return;
                //※ダイアログ処理の続きは、this.confirmで行う
              }
            } else {
              EventBus.$emit("changeMismatchVa", false);
              EventBus.$emit("changeMismatchInfection", false);
              EventBus.$emit("changeMismatchTreatment", false);
            }

          //落とし先のエリア確認
          if (kurNotYetFlag || bedNotYetFlag) {
            // 共通ローダー:表示開始
            this.setLoadingScreenVisible(true);

            //移動先の治療日
            const newTreatDate = this.propsJDayHeader[this.moveToIndex[0]].date;

            //移動先のクールコード(基本的には元と同じもの)
            let kurCd = this.moveFromData.kur_cd;
            //移動先のベッドコード(基本的には元と同じもの)
            let bedCd = this.moveFromData.bed_cd;

            //患者ベッドデータの移動元の治療日を移動先の治療日に合わせておく
            // this.moveFromData.treatDate = newTreatDate;
            let destData = Object.assign({}, this.moveFromData);
            destData.treatDate = newTreatDate;

            if (kurNotYetFlag) {
              let retBool = false;
              if (this.getKurCd(this.moveToIndex[1]) + "" !== "0") {
                retBool = await this.checkSamePatAndNoKur(
                  this.moveFromData.ordNo,
                  this.treatDateDim[this.moveToIndex[0] - 1],
                  );
              }

              if (retBool) {
                // 含まれていた場合、ポップアップを出す(チップ移動は継続)
                this.messageDialogInfo.stringParams = [];
                this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_1;
                this.messageDialogInfo.type = "1";
                this.messageDialogInfo.isDialogVisible = true;
                this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;
                this.msgPopUpFlag = true;
                // 共通ローダー:表示終了
                this.setLoadingScreenVisible(false);
                this.clickEventNowFlag = false;
                return;
              }
              //--------------------------------------------------------
              //クール未登録エリアへのドロップ処理
              //--------------------------------------------------------
              //----------------------------------------------

              //クールコードを未配置にする
              kurCd = DEF_NOTASSIGNED;
              //ベッドコードを未配置にする
              bedCd = DEF_NOTASSIGNED;

              //-----------------------------------------------
              //当該日付のクール未登録エリアの最後に追加

              const targetDim = this.propsJKurNotYet[this.moveToIndex[0]][
                this.kurNum
                ][this.dispNumNotYetKur];
              if (targetDim !== null && typeof targetDim !== DEF_UNDEFINED) {
                //領域がいっぱいなので1行追加
                ++this.dispNumNotYetKur;
              }

              //一番うしろに追加
              this.propsJKurNotYet[this.moveToIndex[0]][this.kurNum][
                this.dispNumNotYetKur
                ] = destData;

              //クールコードをクリア
              this.propsJKurNotYet[this.moveToIndex[0]][this.kurNum][
                this.dispNumNotYetKur
                ].kur_cd = kurCd;
              //ベッドコードをクリア
              this.propsJKurNotYet[this.moveToIndex[0]][this.kurNum][
                this.dispNumNotYetKur
                ].bed_cd = bedCd;

            } else if (bedNotYetFlag) {
              //--------------------------------------------------------
              //ベッド未登録エリアへのドロップ処理
              //--------------------------------------------------------

              //移動先に「同一患者、同一治療日、同一クール、同一治療方法」が含まれていないかの確認
              //既存処理だとベッド未登録へ同一患者、同一クールの予定が入ってしまっていたため追加(2019/12/03)
              let retBool = false;
              if (this.getKurCd(this.moveToIndex[1]) + "" !== "0") {
                await this.checkSamePatDayKurMode(
                  [this.moveFromData.ordNo],
                  [this.treatDateDim[this.moveToIndex[0] - 1]],
                  [this.getKurCd(this.moveToIndex[1])]
                )
                  .then(
                    function (response) {
                      retBool = response;
                    }.bind(retBool)
                  )
                  .catch(error => {
                    getErrorMessage('ScheduleListMainItem.vue', 'clickEvent', error);
                    throw error;
                  });
              }

              if (retBool) {
                // 含まれていた場合、ポップアップを出す(チップ移動は継続)

                this.messageDialogInfo.stringParams = [];
                this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_1;
                this.messageDialogInfo.type = "1";
                this.messageDialogInfo.isDialogVisible = true;
                this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

                this.msgPopUpFlag = true;
                // 共通ローダー:表示終了
                this.setLoadingScreenVisible(false);
                this.clickEventNowFlag = false;

                return;
              }

              //ベッドコードを未配置にする
              bedCd = DEF_NOTASSIGNED;
              //クールコードを移動先にする
              kurCd = this.getKurCd(this.moveToIndex[1]);
              //最後に追加できない(エリアが全て埋まっている)と、移動できないのでチェック
              const targetDim = this.propsJBedNotYet[this.moveToIndex[0]][
                this.moveToIndex[1]
                ][this.dispNumNotYetBed];
              if (targetDim !== null && typeof targetDim !== DEF_UNDEFINED) {
                //一行増やす
                ++this.dispNumNotYetBed;
              }

              //最後に追加
              this.propsJBedNotYet[this.moveToIndex[0]][this.moveToIndex[1]][
                this.dispNumNotYetBed
                ] = destData;

              //ベッドコードをクリア
              this.propsJBedNotYet[this.moveToIndex[0]][this.moveToIndex[1]][
                this.dispNumNotYetBed
                ].bed_cd = bedCd;

              //クールコードを設定
              this.propsJBedNotYet[this.moveToIndex[0]][this.moveToIndex[1]][
                this.dispNumNotYetBed
                ].kur_cd = kurCd;

              // add FNSI-改修内容 クール名前を設定 孫灝 20201008 start
              // クール名前を設定
              let kurName = this.getKurNames[this.moveToIndex[1] - 1];
              this.propsJBedNotYet[this.moveToIndex[0]][this.moveToIndex[1]][
                this.dispNumNotYetBed
                ].kur_name = kurName;
              // add FNSI-改修内容 クール名前を設定 孫灝 20201008 end
            }
            // mod 10601 スケジュール表動作不正 関  start
            // add 10409 メッセージ表示の変更 関  start
            this.beforeMoveDataList.push(this.moveFromData)
            this.afterMoveDataList.push(this.afterScheduleInfoConvert(this.moveFromData,newTreatDate,kurCd,bedCd))
            this.clearRadAndExamSetting();
            // チェック
            await this.updateScheduleDBInfo2(this.beforeMoveDataList,this.afterMoveDataList);

            //mod #10601 スケジュール表動作不正 関 start
            if (this.msgCd != null || this.examDeadlineCancelCheck.includes("cancel") || this.radDeadlineCancelCheck.includes("cancel")) {
              //mod #10601 スケジュール表動作不正 関 end
              this.clickEventNowFlag = false;
              this.setLoadingScreenVisible(false);
              this.beforeMoveDataList = [];
              this.afterMoveDataList = [];
              return;
            }
            // add 10409 メッセージ表示の変更 関  end
            // mod 10601 スケジュール表動作不正 関  end

            //ここからはベッド未登録エリア、クール未登録エリアへの移動の共通処理

            // 選択状態表示（緑枠線）解除
            this.removeCheckClass();
            //チップを削除
            this.movingChipElem?.parentNode.removeChild(this.movingChipElem);
            //もう移動が終わったのでポインタを初期化
            this.movingChipElem = null;

            //点滅停止
            this.setOpaSwitch("off");

            if (kurNotYetFlag) {
              //当該日付のクール未登録領域の再配置
              this.relocateKurNotYet(this.moveToIndex[0]);
              //各未登録領域の最大セル数の確認
              this.checkNotYetAreaMax();

              //クール未登録エリアのストア情報の書き換え(移動先日のクール未登録エリア情報)
              this.resetKurNotYetInfoOnStore(this.moveToIndex);
            } else if (bedNotYetFlag) {
              //当該日付&クールのベッド未登録領域の再配置
              this.relocateBedNotYet(this.moveToIndex[0], this.moveToIndex[1]);

              //ベッド未登録エリアのストア情報の書き換え(移動先日のクールのベッド未登録情報)
              this.resetBedNotYetInfoOnStore(this.moveToIndex);
            }

            //-------------------------------------------------------
            //移動元のデータのクリアとダミースケジュールの削除(未登録エリアに入るので、ダミースケジュールはいらなくなる)
            //ord_noを元に削除(is_dummyが1のデータ)

            //DBレコードの削除
            //TODO:既存のAPIの呼び出し

            const indexDimParam = [];
            this.resetBedIdDimForDelete();
            //メイン分のIndex配列
            indexDimParam[indexDimParam.length] = this.moveFromIndex;
            //ダミー分のIndex配列
            let indexDay = 0;
            let preKurIndex = this.dummyKurIndexFrom[0];
            for (let i = 1; i < this.dummyKurIndexFrom.length; i++) {
              if (preKurIndex > this.dummyKurIndexFrom[i]) {
                ++indexDay;
              }
              preKurIndex = this.dummyKurIndexFrom[i];
              const targetDayIndex =
                Number(this.moveFromIndex[0]) + Number(indexDay);
              const dummyIndex = [
                targetDayIndex,
                this.dummyKurIndexFrom[i],
                this.moveFromIndex[2]
              ];
              indexDimParam[indexDimParam.length] = dummyIndex;
            }

            // 削除処理はクールコンポーネントで行っている
            // ベッド未登録/クール未登録はクールコンポーネントが存在しない
            // ここに削除処理を追加する

            if (this.moveFromInfo === AREA_BEDNOTYET) {
              //移動元がベッド未登録エリアの場合 (#949)

              //当該日付の当該クールのベッド未登録領域の再配置
              this.relocateBedNotYet(
                this.moveFromIndex[0],
                this.moveFromIndex[1]
              );

              //当該日付の当該クールのベッド未登録領域ストア情報の更新
              this.resetBedNotYetInfoOnStore(this.moveFromIndex);
            } else if (this.moveFromInfo === AREA_KURNOTYET) {
              //移動元がクール未登録エリアの場合 (#950)

              //当該日付のクール未登録領域の再配置
              this.relocateKurNotYet(this.moveFromIndex[0]);
              //各未登録領域の最大セル数の確認
              this.checkNotYetAreaMax();

              //当該日付のクール未登録領域ストア情報の更新
              this.resetKurNotYetInfoOnStore(this.moveFromIndex);
            } else {
              //クールコンポーネントに削除を知らせる処理
              this.setBedIdDimForDelete(indexDimParam);
              //ストアに削除を知らせる処理
              this.setClearPatInfoOnBed(indexDimParam);
            }

            //日付ヘッダーコンポーネントと、クールヘッダーコンポーネントの入外区分を変更する
            // 移動元(減算)
            this.changeInOutNum(this.moveFromData.inOutClass, OPE_DEC, this.moveFromIndex, this.moveFromInfo === AREA_BEDNOTYET, this.moveFromInfo === AREA_KURNOTYET);
            // 移動先(加算)
            this.changeInOutNum(this.moveFromData.inOutClass, OPE_INC, this.moveToIndex, bedNotYetFlag, kurNotYetFlag);

            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            this.clickEventNowFlag = false;

            //add #10601 スケジュール表動作不正 start
            this.beforeMoveDataList = [];
            this.afterMoveDataList = [];
            //add #10601 スケジュール表動作不正 end

            // FNSI-画面更新(データの再取得) 徐 start
            this.refreshData();
            // FNSI-画面更新(データの再取得) 徐 end

            return;
          }

          //空きベッドかどうかのチェック
          this.setLoadingScreenVisible(true);
          let retCount = 0;
          await this.selectForSearchReservedBedOnDB(
            this.moveFromData.ordNo,
            this.moveFromData.pat_id,
            this.getBedCd(this.moveToIndex[2]),
            this.treatDateDim[this.moveToIndex[0] - 1],
            this.getKurCd(this.moveToIndex[1]),
            this.moveFromIndex[0] !== this.moveToIndex[0]
          )
            .then(
              function(response) {
                retCount = response;
              }.bind(retCount)
            )
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('ScheduleListMainItem.vue', 'clickEvent', error);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              throw error;
            });

          if (retCount !== 0) {
            //移動先の情報取得
            const mvTo = this.getPatBedInfo(this.moveToIndex);

            // 治療中以降の予定が重複しているかフラグ
            let isExistCantMoveData = false;

            // ダミースケジュールチェック変数
            const paramJson = {};
            this.duplicateIndex = [];

            // 移動元ダミースケジュールチェック
            paramJson.treatTime = this.moveFromData.treatTime;
            paramJson.kurIndex = Number(this.moveToIndex[1]);
            const moveFromDummyKurIndexTo = this.getDummyInfo(paramJson);
            let countDay = 0;
            if (1 < moveFromDummyKurIndexTo.length) {
              for (let idx = 1; idx < moveFromDummyKurIndexTo.length; idx++) {
                if (moveFromDummyKurIndexTo[idx] === 1) {
                  // チェック対象の日付を+1する
                  countDay++;
                }
                const dateidx = Number(this.moveToIndex[0]) + countDay;
                // ダミースケジュールがいた場合、移動予定地に治療予定がいるか？
                const searchedIndex = [
                  dateidx.toString(),
                  moveFromDummyKurIndexTo[idx].toString(),
                  this.moveToIndex[2]
                ];
                const searchedInfo = this.getPatBedInfo(searchedIndex);
                if (searchedInfo.hospPatId !== "" && searchedInfo.isDummy !== "1") {
                  this.duplicateIndex.push(searchedIndex);
                  if (this.moveToInfo !== "kurNotYet" && this.moveToInfo !== "bedNotYet") {
                    isExistCantMoveData = true;
                  }
                }
              }
            }

            // 移動先ダミースケジュールチェック
            paramJson.treatTime = mvTo.treatTime;
            paramJson.kurIndex = Number(this.moveFromIndex[1]);
            const moveToDummyKurIndexTo = this.getDummyInfo(paramJson);
            countDay = 0;
            if (1 < moveToDummyKurIndexTo.length) {
              for (let idx = 1; idx < moveToDummyKurIndexTo.length; idx++) {
                if (moveToDummyKurIndexTo[idx] === 1) {
                  // チェック対象の日付を+1する
                  countDay++;
                }
                const dateidx = Number(this.moveFromIndex[0]) + countDay;
                // ダミースケジュールがいた場合、移動予定地に治療予定がいるか？
                const searchedIndex = [
                  dateidx.toString(),
                  moveToDummyKurIndexTo[idx].toString(),
                  this.moveFromIndex[2]
                ];
                const searchedInfo = this.getPatBedInfo(searchedIndex);
                if (searchedInfo.hospPatId !== "" && searchedInfo.isDummy !== "1") {
                  this.duplicateIndex.push(searchedIndex);
                  if (this.moveFromInfo !== "kurNotYet" && this.moveFromInfo !== "bedNotYet") {
                    isExistCantMoveData = true;
                  }
                }
              }
            }

            //add FNSI redmine 6588 劉祥霖 start
            if (mvTo.ordNo && mvTo.ordNo !== this.moveFromData.ordNo && mvTo.isDummy == 1) {
              // 入れ替え先に治療時間と重複する別の予定が存在する
              // メッセージ
              this.messageDialogInfo.stringParams = [];
              this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_29;
              this.messageDialogInfo.type = "1";
              this.messageDialogInfo.isDialogVisible = true;
              this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;
              this.msgPopUpFlag = true;
            } else
              //add FNSI redmine 6588 劉祥霖 end
            if (isExistCantMoveData && mvTo.ordNo && mvTo.ordNo !== this.moveFromData.ordNo) {
              // 入れ替え先に治療時間と重複する別の予定が存在する
              // メッセージ
              this.messageDialogInfo.stringParams = [];
              this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_20;
              this.messageDialogInfo.type = "1";
              this.messageDialogInfo.isDialogVisible = true;
              this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

              this.msgPopUpFlag = true;
            }
            else if (this.checkBedStatus(mvTo) && mvTo.hospPatId !== "" && mvTo.isDummy !== "1") {
              // 入れ替え処理
              // 条件送信確認済みの場合、クリック時点で移動確認ダイアログを表示する
              if (await this.showMoveCheckDialog(mvTo.dialysisState)) {
                // メッセージ
                this.messageDialogInfo.title = null;
                this.messageDialogInfo.stringParams = [];
                this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_17;
                this.messageDialogInfo.type = "2";
                this.messageDialogInfo.isDialogVisible = true;
                this.messageDialogInfo.dialogNo = DEF_DIALOG_REPLACE;

                this.msgPopUpFlag = true;
              }
            } else if (!this.checkBedStatus(mvTo)) {
              // 移動先が治療中以降
              // メッセージ
              this.messageDialogInfo.title = null;
              this.messageDialogInfo.stringParams = [];
              this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_18;
              this.messageDialogInfo.type = "1";
              this.messageDialogInfo.isDialogVisible = true;
              this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

              this.msgPopUpFlag = true;
            } else if (mvTo.isDummy === "1" && mvTo.ordNo !== this.moveFromData.ordNo) {
              // 移動先がダミースケジュール
              // メッセージ
              this.messageDialogInfo.title = null;
              this.messageDialogInfo.stringParams = [];
              this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_19;
              this.messageDialogInfo.type = "1";
              this.messageDialogInfo.isDialogVisible = true;
              this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

              this.msgPopUpFlag = true;
            } else {
              // 移動先に予定を置けない
              // メッセージ
              this.messageDialogInfo.title = null;
              this.messageDialogInfo.stringParams = [];
              this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_8;
              this.messageDialogInfo.type = "1";
              this.messageDialogInfo.isDialogVisible = true;
              this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

              this.msgPopUpFlag = true;
              // add #11493 スケジュール表　更新不正 関 start
              this.refreshData();
              // add #11493 スケジュール表　更新不正 関 end
            }
          } else if (retCount === 0) {
            //ベッドが空いていた場合(患者を置ける場合)の処理
            // mod 10601 スケジュール表動作不正 関  start
            // mod 10409 メッセージ表示の変更 関  start
            let mvTo = this.getPatBedInfo(this.moveToIndex);
            if (mvTo.isDummy === "1") {
              mvTo = {
                facilityCd: this.getFacilityCd,
                bed_cd: mvTo.bed_cd,
                kur_cd: mvTo.kur_cd,
                treatDate: mvTo.treatDate,
              }
            }
            this.moveToData = JSON.parse(JSON.stringify(mvTo));
            this.beforeMoveDataList.push(this.moveFromData)
            this.afterMoveDataList.push(this.moveToData)
            this.clearRadAndExamSetting();
            // チェック
            await this.updateScheduleDBInfo2(this.beforeMoveDataList,this.afterMoveDataList);

            if (this.msgCd != null || this.examDeadlineCancelCheck.includes("cancel") || this.radDeadlineCancelCheck.includes("cancel")) {
              this.clickEventNowFlag = false;
              this.beforeMoveDataList = [];
              this.afterMoveDataList = [];
              this.setLoadingScreenVisible(false);
              return;
            }
            // mod 10601 スケジュール表動作不正 関  end

            // add FNSI 1006 No.426 end --Sanjingye Sun 20201216
            //----------------------------------------------------------
            //ダミースケジュールチェック ※ダミーが必要かどうかの確認(どの治療日のどのクールまで使用するか)

            const paramJson = {};
            paramJson.treatTime = this.moveFromData.treatTime;
            paramJson.kurIndex = Number(this.moveToIndex[1]);
            this.dummyKurIndexTo = this.getDummyInfo(paramJson);
            //----------------------------------------------------------
            //同一患者、同一クール、同一治療方法の登録抑止のためのチェック

            //移動先に「同一患者、同一治療日、同一クール、同一治療方法」が含まれていないかの確認
            let retBool = false;
            // add bug 6034 修正 chen start
            if (this.getKurCd(this.moveToIndex[1]) + "" !== "0") {
              // add bug 6034 修正 chen end
              await this.checkSamePatDayKurMode(
                [this.moveFromData.ordNo],
                [this.treatDateDim[this.moveToIndex[0] - 1]],
                [this.getKurCd(this.moveToIndex[1])]
              )
                .then(
                  function (response) {
                    retBool = response;
                  }.bind(retBool)
                )
                .catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                  getErrorMessage('ScheduleListMainItem.vue', 'clickEvent', error);
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                  throw error;
                });
            }

            if (DEF_DIALOG_NOUSE === this.messageDialogInfo.dialogNo) {
              //this.messageDialogInfo.dialogNoがDef.DEF_DIALOG_NOUSEの場合、
              // メッセージダイアログは呼ばれていないので移動終了処理を行う
              //※DEF_DIALOG_UNMATCHの場合は、confirm呼び出しで処理を行う
              //  チップの移動終了処理
              this.finishMovingChip(false);
            }
          }

          this.clickEventNowFlag = false;
          //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
          EventBus.$emit("changeMismatchVa", false);
          //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
          EventBus.$emit("changeMismatchInfection", false);
          EventBus.$emit("changeMismatchTreatment", false);
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

        }
        // mod #11493 スケジュール表　更新不正 関 start
        // add 9069 【デグレ】スケジュール表で対象指定後のダミー表示で共通ローダーが一瞬外れて操作勘違いを起こす 関 start
        this.setLoadingScreenVisible(false);
        // add 9069 【デグレ】スケジュール表で対象指定後のダミー表示で共通ローダーが一瞬外れて操作勘違いを起こす 関 end
        // mod #11493 スケジュール表　更新不正 関 end
        // add #10359 編集権限について、対応する。 zhangyue start
        if (!this.haveAuthority) {
          this.setMoveAuthrityAlert();
        }
        // add #10359 編集権限について、対応する。 zhangyue end
      },

      fromToObjConvert(fromToObjList){
        const updatedScheduleDataList = fromToObjList.map(item => {
          return {
            facilityCd: this.getFacilityCd,
            ordNo: item.ordNo,
            patId: item.pat_id,
            indBedCd: item.bed_cd,
            indKurCd: item.kur_cd,
            treatDate: item.treatDate
          };
        });
        return updatedScheduleDataList;
      },

      afterScheduleInfoConvert(fromObj,toTreatDate,toKurCd,toBedCd) {
        const afterScheduleInfo = {
          facilityCd: this.getFacilityCd,
          ordNo: null,
          pat_id: null,
          bed_cd: toBedCd,
          kur_cd: toKurCd,
          treatDate: toTreatDate
        };
        return afterScheduleInfo;
      },
      async updateScheduleDBInfo2(beforObjList, afterObjList){
          //ログインユーザIDの取得
        const updUserId = this.getStateUserAccountInfo.userId;
        //指示者ユーザIDの取得
        const indUserId = parseInt(this.indUser);

        const param = {
          facilityCd: this.getFacilityCd,
          indUserId: indUserId,
          updUserId: updUserId,
          beforeIndScheduleInfoList: this.fromToObjConvert(beforObjList),
          afterIndScheduleInfoList:this.fromToObjConvert(afterObjList),
          indscheduleChangeUserSelectedInfo:{
            facilitySetting1007SelectedVal: this.getFacilitySetting1007_4SelectedVal,
            facilitySetting1008SelectedVal: this.getFacilitySetting1008_4SelectedVal,
            facilitySetting3005SelectedVal: this.getFacilitySetting3005_4SelectedVal,
            examDeadlineSelectedVal: this.examDeadlineSelectedVal,
            radDeadlineSelectedVal: this.radDeadlineSelectedVal,
          }
        };
        // mod 10409 メッセージ表示の変更 関  start
       const response = await ApiHelper.put(
          "/scheduleList/updateScheduleListData2",
          param
        ).catch((error) => {
          getErrorMessage(
            "ScheduleListMainItem.vue",
            "updateScheduleDBInfo2",
            error
          );
          throw(error);
        });
        const data = response?.data;
        if (isProcSuccess(data)) {
          // mod 10601 スケジュール表動作不正 関  start
          this.msgCd = data.msgCd;
          this.msgCdList = data.msgCdList;
          // mod 10601 スケジュール表動作不正 関  end
          if (data.hasDoCancel) {
            this.messageDialogInfo.title = null;
            this.selectedSendConditonOrdNo = data.doCancelGoSendordNo;
            const beforOrAfterFlag = data.beforOrAfterFlag;
            if (this.isMovePats) {
              // 複数移動した場合
              this.cancelSendCondCd = 70000017;
              this.cancelSendCondType = "1";
              this.cancelSendCondVisible = true;
            } else {
              this.cancelSendCondCd = 70000016;
              this.cancelSendCondType = "2";
              this.cancelSendCondVisible = true;
              if (beforOrAfterFlag === "1") {
                this.moveSendConditionData = beforObjList[0];
              } else {
                this.moveSendConditionData = afterObjList[0];
              }
            }
          }
        } else {
          this.msgCdList = data?.msgCdList;
          this.msgCd = data?.msgCd;
          if (this.msgCd != null && this.msgCd.includes("70000001")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000001].title,
              message: messageFormat(DIALOG_MESSAGES[70000001].message),
              buttonLabels: ["OK"],
            });
          }
          //mod #10601 スケジュール表動作不正 関 start
          if (this.msgCd != null && this.msgCd.includes("12000212")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[12000212].title,
              message: messageFormat(DIALOG_MESSAGES[12000212].message),
              buttonLabels: ["OK"],
            });
          }
          if (this.msgCd != null && this.msgCd.includes("70000008")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000008].title,
              message: messageFormat(DIALOG_MESSAGES[70000008].message),
              buttonLabels: ["OK"],
            });
             // add #11493 スケジュール表　更新不正 関 start
             this.refreshData();
             // add #11493 スケジュール表　更新不正 関 end
          }
          if (this.msgCd != null && this.msgCd.includes("22020005")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[22020005].title,
              message: messageFormat(DIALOG_MESSAGES[22020005].message),
              buttonLabels: ["OK"],
            });
          }
          // mod #11493 スケジュール表　更新不正 関 start
          if (this.msgCd != null && this.msgCd.includes("12000060")) {
            await this.$ons.notification.confirm({
              title: "",
              message: "複数件の実績あり予定は操作できません。",
              buttonLabels: ["OK"],
            });
            this.refreshData();
          }
          // add #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 start
          if (this.msgCd != null && this.msgCd.includes("70000041")) {

            const patNames = data?.outOfSchedulePatNameList ?? [];
            const honorificPatNames = patNames.map(name => {
              const trimmed = name ? name.trim() : "";
              if (trimmed === "") {
                return "";
              }
              return trimmed.endsWith("様") ? trimmed : `${trimmed}様`;
            });

            const formattedMessage = `<div style="max-height: 60vh; overflow-y: auto;">
                    ${messageFormat(
              DIALOG_MESSAGES["70000041"].message,
              honorificPatNames.join('\n')
            )}
                  </div>`;
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES["70000041"].title,
              message: formattedMessage,
              buttonLabels: ["OK"],
            });
            this.refreshData();
          }
          // add #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 end
          // 移動できない場合は続行しない
            if (this.msgCd == null && this.msgCdList.length == 0) {
              let message = data?.message;
               await this.$ons.notification.confirm({
              title: "",
              message: message,
              buttonLabels: ["OK"],
            });
          }
          if (this.msgCd == null && this.msgCdList.length > 0) {
            if (this.msgCdList.includes("70000030")) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000030].title,
                message: messageFormat(DIALOG_MESSAGES[70000030].message),
                buttonLabels: ["1", "2", "3"],
                callback: (answer) => {
                  if (answer === 0) {
                    this.setFacilitySetting1007_4SelectedVal(1);
                  } else if (answer === 1) {
                    this.setFacilitySetting1007_4SelectedVal(2);
                  } else if (answer === 2) {
                    this.setFacilitySetting1007_4SelectedVal(3);
                  }
                },
              });
            }
            if (this.msgCdList.includes("70000033") &&
              this.getFacilitySetting1007_4SelectedVal != 3
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
            if (this.msgCdList.includes("70000031") &&
              !this.examDeadlineCancelCheck.includes("cancel")
            ) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000031].title,
                message: messageFormat(DIALOG_MESSAGES[70000031].message),
                buttonLabels: ["1", "2", "3"],
                callback: (answer) => {
                  if (answer === 0) {
                    this.setFacilitySetting1008_4SelectedVal(1);
                  } else if (answer === 1) {
                    this.setFacilitySetting1008_4SelectedVal(2);
                  } else if (answer === 2) {
                    this.setFacilitySetting1008_4SelectedVal(3);
                  }
                },
              });
            }
            if (this.msgCdList.includes("70000034") &&
              !this.examDeadlineCancelCheck.includes("cancel") &&
              this.getFacilitySetting1008_4SelectedVal != 3
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
            if (this.msgCdList.includes("70000032") &&
              !this.examDeadlineCancelCheck.includes("cancel") &&
              !this.radDeadlineCancelCheck.includes("cancel")
            ) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000032].title,
                message: messageFormat(DIALOG_MESSAGES[70000032].message),
                buttonLabels: ["1", "2", "3"],
                callback: (answer) => {
                  if (answer === 0) {
                    this.setFacilitySetting3005_4SelectedVal(1);
                  } else if (answer === 1) {
                    this.setFacilitySetting3005_4SelectedVal(2);
                  } else if (answer === 2) {
                    this.setFacilitySetting3005_4SelectedVal(3);
                  }
                },
              });
            }
          }
        }
        this.refreshData();
        // mod #11493 スケジュール表　更新不正 関 end
        // mod 10409 メッセージ表示の変更 関  end
        // mod 10601 スケジュール表動作不正 関  start
        if((this.msgCdList != null && this.msgCdList.length > 0) && !(this.examDeadlineCancelCheck.includes("cancel") || this.radDeadlineCancelCheck.includes("cancel")) && !this.msgCd != null) {
          await this.updateScheduleDBInfo2(this.beforeMoveDataList,this.afterMoveDataList);
        }
        // mod 10601 スケジュール表動作不正 関  end
        await this.getOtherScheduleData();
        this.restFacilitySettingDialogsOpenedFlg();
      },
      /**
       * スケジュールの入替前処理
       */
      async replaceSchedulePreProcessing() {
        // add #10601 スケジュール表動作不正 zhangyue start
        this.setLoadingScreenVisible(true);
        // add #10601 スケジュール表動作不正 zhangyue end
        // add FNSI 1006 No.426 end --Sanjingye Sun 20201216
        //移動先の情報取得
        const mvTo = this.getPatBedInfo(this.moveToIndex);
        this.moveToData = JSON.parse(JSON.stringify(mvTo));

        //----------------------------------------------------------
        //ダミースケジュールチェック ※ダミーが必要かどうかの確認(どの治療日のどのクールまで使用するか)

        const paramJson = {};
        paramJson.treatTime = this.moveFromData.treatTime;
        paramJson.kurIndex = Number(this.moveToIndex[1]);
        this.dummyKurIndexTo = this.getDummyInfo(paramJson);

        //----------------------------------------------------------
        //同一患者、同一クール、同一治療方法の登録抑止のためのチェック

        let retBool = false;
        // 別患者の場合、登録抑止チェックを行う(同一患者であればそのまま入れ替え)
        if (this.moveFromData.pat_id !== this.moveToData.pat_id) {

          // add bug 6034 修正 chen start
          if (this.getKurCd(this.moveToIndex[1]) + "" !== "0") {
            // add bug 6034 修正 chen end
            //移動先に「同一患者、同一治療日、同一クール、同一治療方法」が含まれていないかの確認
            await this.checkSamePatDayKurMode(
              [this.moveFromData.ordNo],
              [this.treatDateDim[this.moveToIndex[0] - 1]],
              [this.getKurCd(this.moveToIndex[1])]
            )
              .then(
                function (response) {
                  retBool = retBool || response;
                }.bind(retBool)
              )
              .catch(error => {
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                getErrorMessage('ScheduleListMainItem.vue', 'replaceSchedulePreProcessing', error);
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                throw error;
              });
          }

          // add bug 6034 修正 chen start
          if (this.getKurCd(this.moveFromIndex[1]) + "" !== "0") {
            // add bug 6034 修正 chen end
            //移動元に「同一患者、同一治療日、同一クール、同一治療方法」が含まれていないかの確認
            await this.checkSamePatDayKurMode(
              [this.moveToData.ordNo],
              [this.treatDateDim[this.moveFromIndex[0] - 1]],
              [this.getKurCd(this.moveFromIndex[1])]
            )
              .then(
                function (response) {
                  retBool = retBool || response;
                }.bind(retBool)
              )
              .catch(error => {
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                getErrorMessage('ScheduleListMainItem.vue', 'replaceSchedulePreProcessing', error);
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                throw error;
              });
          }

        }

        if (retBool) {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);

          // 含まれていた場合、ポップアップを出す(チップ移動は継続)

          this.messageDialogInfo.stringParams = [];
          this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_1;
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.isDialogVisible = true;
          this.messageDialogInfo.dialogNo = DEF_DIALOG_SAMECOND;

          this.msgPopUpFlag = true;
          this.clickEventNowFlag = false;

          return;
        }

        //----------------------------------------------------------
        //不一致の場合の移動するかしないかのチェック

        //現在の患者情報(不一致チェック用)の取得
        let retJson = null;
        await this.getPatInfoForCheck(this.moveFromData.ordNo)
          .then(
            function(response) {
              retJson = response;
            }.bind(retJson)
          )
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'replaceSchedulePreProcessing', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });

        //------------------------------------------------------------
        // 不一致チェック

        //チェック用のパラメータ準備

        // 対象クール(移動先)のデータ一覧の取得
        const paramDim = [this.moveToIndex[0], this.moveToIndex[1]];

        const kurBlockInfoTo = this.getPatBedInfo(paramDim);

        const checkTargetJson = {};
        checkTargetJson.kur_cd = this.moveFromData.kur_cd;
        checkTargetJson.bed_cd = this.moveFromData.bed_cd;

        //mod #10601 スケジュール表動作不正 start
        checkTargetJson.target_bed_cd =
          kurBlockInfoTo.commitAreaData[this.moveToIndex[2]]?.bed_cd;
        //mod #10601 スケジュール表動作不正 end

        //最新情報に書き換え
        this.moveFromData.vaDirect = retJson.va_direct;
        this.moveFromData.isInfect = retJson.is_infect;
        this.moveFromData.deviceMode = retJson.device_mode;

        checkTargetJson.vaDirect = this.moveFromData.vaDirect;
        checkTargetJson.isInfect = this.moveFromData.isInfect;
        checkTargetJson.deviceMode = this.moveFromData.deviceMode;

        //不一致チェックを実施
        this.unmatchResultJson = this.getUnmatchInfo(checkTargetJson);

        //ダイアログ設定初期化(メッセージを出す場合に備える)
        this.messageDialogInfo.dialogNo = DEF_DIALOG_NOUSE;
		  // mod 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
        //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
        if (this.unmatchResultJson.unmatchFlag) {
          if (this.getSystemSettingUnmatchShowMsgFlag && !this.facilitySettingDialog1000OpenedFlg) {
            //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
            // mod 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
            //不一致があり&&システム設定での不一致確認がtrue

            let outMsg = "";
            if (!this.unmatchResultJson.infectionFlag) {
              outMsg += "感染症";
              //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
              EventBus.$emit("changeMismatchInfection", true);
            } else {
              EventBus.$emit("changeMismatchInfection", false);
            }
            //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
            if (!this.unmatchResultJson.shuntFlag) {
              if (outMsg !== "") {
                outMsg += "・";
              }
              // add 5091 赵 start
              outMsg += "VA位置";
              //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
              EventBus.$emit("changeMismatchVa", true);
            } else {
              EventBus.$emit("changeMismatchVa", false);
            }
            //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
            if (!this.unmatchResultJson.deviceModeFlag) {
              if (outMsg !== "") {
                outMsg += "・";
              }
              outMsg += "治療方法";
              //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
              EventBus.$emit("changeMismatchTreatment", true);
            } else {
              EventBus.$emit("changeMismatchTreatment", false);
            }
            //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

            //ダイアログを出力
            const dispStr = outMsg;
            this.facilitySettingDialog1000OpenedFlg = true;
            this.messageDialogInfo.stringParams = [dispStr];
            // add 5091 赵 start
            this.messageDialogInfo.title = "ベッド条件不一致";
            // add 5091 赵 end
            this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_2;
            this.messageDialogInfo.type = DEF_MSGTYPE_OK_CANCEL;
            this.messageDialogInfo.isDialogVisible = true;
            this.messageDialogInfo.dialogNo = DEF_DIALOG_UNMATCH;

            this.msgPopUpFlag = true;
            //※ダイアログ処理の続きは、this.confirmで行う
          }
          //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
        } else {
          EventBus.$emit("changeMismatchVa", false);
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
          EventBus.$emit("changeMismatchInfection", false);
          EventBus.$emit("changeMismatchTreatment", false);
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
        }
        //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end

        if (DEF_DIALOG_NOUSE === this.messageDialogInfo.dialogNo) {
          //this.messageDialogInfo.dialogNoがDef.DEF_DIALOG_NOUSEの場合、
          // メッセージダイアログは呼ばれていないので移動終了処理を行う
          //※DEF_DIALOG_REPLACEUNMATCHの場合は、confirm呼び出しで処理を行う
          //  チップの移動終了処理
          this.replaceSchedule();
        }
        this.setLoadingScreenVisible(false);
      },
      /**
       * スケジュールの入替処理
       */
      async replaceSchedule() {
        this.setLoadingScreenVisible(true);
        const moveToDataBefore = JSON.parse(JSON.stringify(this.moveToData));

        // 左右の入れ替えなどで、入れ替え先がダミースケジュールと重複するかのフラグ
        let isMoveToDuplicate = false;
        //-----------------------------------------------------------------
        //重複した予定をクール未登録に落とす
        if(this.duplicateIndex.length > 0) {
          for await (const index of this.duplicateIndex) {

            // 入れ替え先がダミースケジュールと重複する場合
            if (JSON.stringify(index) === JSON.stringify(this.moveFromIndex)) {
              isMoveToDuplicate = true;
              continue;
            }

            // 重複した予定の情報取得
            const mvDuplicate = this.getPatBedInfo(index);
            const moveDuplicateData = JSON.parse(JSON.stringify(mvDuplicate));

            const paramJson = {};
            paramJson.treatTime = moveDuplicateData.treatTime;
            paramJson.kurIndex = Number(index[1]);
            const dummyKurIndexDuplicate = this.getDummyInfo(paramJson);

            //add #10601 スケジュール表動作不正 start
            this.beforeMoveDataList.push(moveDuplicateData)
            this.afterMoveDataList.push(this.afterScheduleInfoConvert(moveDuplicateData,moveDuplicateData.treatDate,0,0))
            //add #10601 スケジュール表動作不正 end

            const tmp = {};
            tmp.index = index;
            tmp.data = JSON.parse(JSON.stringify(moveDuplicateData));

            //当該日付のクール未登録領域の再配置
            this.relocateKurNotYet(index[0]);
            //各未登録領域の最大セル数の確認
            this.checkNotYetAreaMax();

            //クール未登録エリアのストア情報の書き換え(移動先日のクール未登録エリア情報)
            this.resetKurNotYetInfoOnStore(index);

            const indexDimParam = [];
            this.resetBedIdDimForDelete();
            //メイン分のIndex配列
            indexDimParam[indexDimParam.length] = index;
            //ダミー分のIndex配列
            let indexDay = 0;
            let preKurIndex = dummyKurIndexDuplicate[0];
            for (let i = 1; i < dummyKurIndexDuplicate.length; i++) {
              if (preKurIndex > dummyKurIndexDuplicate[i]) {
                ++indexDay;
              }
              preKurIndex = dummyKurIndexDuplicate[i];
              const targetDayIndex =
                Number(index[0]) + Number(indexDay);
              const dummyIndex = [
                targetDayIndex,
                dummyKurIndexDuplicate[i],
                index[2]
              ];
              indexDimParam[indexDimParam.length] = dummyIndex;
            }

            //クールコンポーネントに削除を知らせる処理
            this.setBedIdDimForDelete(indexDimParam);
            //ストアに削除を知らせる処理
            this.setClearPatInfoOnBed(indexDimParam);

          }
        }
          const mvTo = this.getPatBedInfo(this.moveToIndex);
          this.moveToData = JSON.parse(JSON.stringify(mvTo));
          this.beforeMoveData = [];
          this.afterMoveData = [];
          this.beforeMoveDataList.push(this.moveFromData)
          this.afterMoveDataList.push(this.moveToData)
          this.clearRadAndExamSetting()
          // チェック
          await this.updateScheduleDBInfo2(this.beforeMoveDataList,this.afterMoveDataList);

          if (this.msgCd != null || this.examDeadlineCancelCheck.includes("cancel") || this.radDeadlineCancelCheck.includes("cancel")) {
            this.setLoadingScreenVisible(false);
            this.clickEventNowFlag = false;
            this.beforeMoveDataList = [];
            this.afterMoveDataList = [];
            return;
          }

        //-----------------------------------------------------------------
        //移動先を消す処理
        //移動先は確定エリアのみ

        const tmp = {};
        tmp.index = this.moveToIndex;
        tmp.data = JSON.parse(JSON.stringify(this.moveToData));

        //クールコンポーネントへ知らせる
        this.propsJMoveData[this.moveToIndex[0]].splice(
          this.moveToIndex[1],
          1,
          tmp
        );
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        if(moveToDataBefore.pat_id == this.moveFromData.pat_id){
          this.isSamePatId = "1";
        }
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
        //-----------------------------------------------------------------
        // チップ移動終了処理
        await this.finishMovingChip(true);

        //----------------------------------------------------
        // 移動先の情報を移動元の位置に置く
        // DBの更新
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        if(moveToDataBefore.pat_id == this.moveFromData.pat_id){
          this.isSamePatId = "2";
        }
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

        //移動先のダミースケジュールチェック
        const paramJson = {};
        paramJson.treatTime = this.moveToData.treatTime;
        paramJson.kurIndex = Number(this.moveFromIndex[1]);
        this.dummyKurIndexTo = this.getDummyInfo(paramJson);

        //ダミースケジュールを生成する
        let indexDay = 0;
        let preKurIndex = this.dummyKurIndexTo[0];
        for (let i = 1; i < this.dummyKurIndexTo.length; i++) {
          if (preKurIndex > this.dummyKurIndexTo[i]) {
            ++indexDay;
          }

          preKurIndex = this.dummyKurIndexTo[i];

          const targetDayIndex = Number(this.moveFromIndex[0]) + Number(indexDay);
          const dummyData = JSON.parse(JSON.stringify(this.moveToData)); //deepコピー
          dummyData.isDummy = "1"; //ダミーフラグを立てる
          const makeDummyIndex = [
            targetDayIndex,
            this.dummyKurIndexTo[i],
            this.moveFromIndex[2]
          ];
          //クール情報書き換え
          //ダミーフラグ情報書き換え
          //--------------------------------------
          //クールコンポーネントへ知らせる
          //データを入れる
          const tmp = {};
          tmp.index = makeDummyIndex;
          tmp.data = dummyData;

          //クールコンポーネントへ知らせる(表示領域を超える場合は通知不要)
          if (this.propsJDummyData[targetDayIndex]) {
            this.propsJDummyData[targetDayIndex].splice(
              this.dummyKurIndexTo[i],
              1,
              tmp
            );
          }
        }

        // データ再読み込み
        await this.changeDispTerm(0, 1);

        // 列幅の再設定処理を実行
        this.$nextTick(() => {
          this.adjustElemSize();
        });

        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);

      },
      /**
       * チップの移動終了処理
       * @param isReplace 入れ替え処理フラグ true: 入れ替え処理時 / false: それ以外
       */
      async finishMovingChip(isReplace) {
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);

        //不一致チェック結果を反映
        this.moveFromData.shuntFlag = this.unmatchResultJson.shuntFlag;
        this.moveFromData.infectionFlag = this.unmatchResultJson.infectionFlag;
        this.moveFromData.deviceModeFlag = this.unmatchResultJson.deviceModeFlag;

        //----------------------------------------------
        // 選択状態表示（緑枠線）解除
        this.removeCheckClass();
        //チップを削除
        this.movingChipElem?.parentNode.removeChild(this.movingChipElem);
        //もう移動が終わったのでポインタを初期化
        this.movingChipElem = null;

        //移動先の情報取得
        const mvTo = this.getPatBedInfo(this.moveToIndex);
        this.moveToData = JSON.parse(JSON.stringify(mvTo));

        const tmp = {};
        tmp.index = this.moveToIndex;
        tmp.data = JSON.parse(JSON.stringify(this.moveFromData));

        //クールコンポーネントへ知らせる
        this.propsJMoveData[this.moveToIndex[0]].splice(
          this.moveToIndex[1],
          1,
          tmp
        );

        //-----------------------------------------------------------------
        //元を消す処理

        if (this.moveFromInfo === AREA_BEDNOTYET) {
          //移動元がベッド未登録エリアの場合

          //当該日付の当該クールのベッド未登録領域の再配置
          this.relocateBedNotYet(this.moveFromIndex[0], this.moveFromIndex[1]);

          //当該日付の当該クールのベッド未登録領域ストア情報の更新
          this.resetBedNotYetInfoOnStore(this.moveFromIndex);
        } else if (this.moveFromInfo === AREA_KURNOTYET) {
          //移動元がクール未登録エリアの場合

          //当該日付のクール未登録領域の再配置
          this.relocateKurNotYet(this.moveFromIndex[0]);
          //各未登録領域の最大セル数の確認
          this.checkNotYetAreaMax();

          //当該日付のクール未登録領域ストア情報の更新
          this.resetKurNotYetInfoOnStore(this.moveFromIndex);
        } else {
          //移動元が確定エリアの場合
          //クールコンポーネントに削除を知らせる処理(本体+ダミー)
          const indexDimParam = [];
          this.resetBedIdDimForDelete();
          //本体分
          indexDimParam[indexDimParam.length] = this.moveFromIndex;
          //ダミースケジュール分
          let indexDay = 0;
          let preKurIndex = this.dummyKurIndexFrom[0];

          for (let i = 1; i < this.dummyKurIndexFrom.length; i++) {
            if (preKurIndex > this.dummyKurIndexFrom[i]) {
              ++indexDay;
            }
            preKurIndex = this.dummyKurIndexFrom[i];
            const targetDayIndex =
              Number(this.moveFromIndex[0]) + Number(indexDay);
            const dummyIndex = [
              targetDayIndex,
              this.dummyKurIndexFrom[i],
              this.moveFromIndex[2]
            ];
            indexDimParam[indexDimParam.length] = dummyIndex;
          }
          this.setBedIdDimForDelete(indexDimParam);

          //ストアの情報を入れ替える処理
          const indexJson = {};
          indexJson.From = this.moveFromIndex;
          indexJson.To = this.moveToIndex;
          this.swapCellInfo(indexJson);

        }

        //ダミースケジュールを生成する
        let indexDay = 0;
        let preKurIndex = this.dummyKurIndexTo[0];
        for (let i = 1; i < this.dummyKurIndexTo.length; i++) {
          if (preKurIndex > this.dummyKurIndexTo[i]) {
            ++indexDay;
          }

          preKurIndex = this.dummyKurIndexTo[i];

          const targetDayIndex = Number(this.moveToIndex[0]) + Number(indexDay);
          const dummyData = JSON.parse(JSON.stringify(this.moveFromData)); //deepコピー
          dummyData.isDummy = "1"; //ダミーフラグを立てる
          // FNSI-fix bug ダミーデータ足りない 孫灝 20201104 start
          let dayData = Object.values(this.dispdata)[targetDayIndex - 1];
          let bedData = dayData[this.dummyKurIndexTo[i] - 1].beddata[this.moveToIndex[2]];
          dummyData.treatDate = bedData.treatDate;
          dummyData.kur_cd = bedData.kur_cd;
          dummyData.bed_cd = bedData.bed_cd;
          // FNSI-fix bug ダミーデータ足りない 孫灝 20201104 end

          const makeDummyIndex = [
            targetDayIndex,
            this.dummyKurIndexTo[i],
            this.moveToIndex[2]
          ];
          //クール情報書き換え
          //ダミーフラグ情報書き換え
          //--------------------------------------
          //クールコンポーネントへ知らせる
          //データを入れる
          const tmp = {};
          tmp.index = makeDummyIndex;
          tmp.data = dummyData;

          //クールコンポーネントへ知らせる(表示領域を超える場合は通知不要)
          if (this.propsJDummyData[targetDayIndex]) {
            this.propsJDummyData[targetDayIndex].splice(
              this.dummyKurIndexTo[i],
              1,
              tmp
            );
          }
        }

        //add #10601 スケジュール表動作不正 start
        this.beforeMoveDataList = [];
        this.afterMoveDataList = [];
        //add #10601 スケジュール表動作不正 end

        //点滅停止
        this.setOpaSwitch("off");

        //日付ヘッダーコンポーネントと、クールヘッダーコンポーネントの入外区分を変更する
        // 移動元(減算)
        let isBedNotYet = this.moveFromInfo === AREA_KURNOTYET || this.moveFromInfo === AREA_BEDNOTYET;
        this.changeInOutNum(this.moveFromData.inOutClass, OPE_DEC, this.moveFromIndex, isBedNotYet, this.moveFromInfo === AREA_KURNOTYET);
        // 移動先(加算)
        isBedNotYet = this.moveToInfo === AREA_KURNOTYET || this.moveToInfo === AREA_BEDNOTYET;
        this.changeInOutNum(this.moveFromData.inOutClass, OPE_INC, this.moveToIndex, isBedNotYet, this.moveToInfo === AREA_KURNOTYET);

        // 入れ替え処理以外のときは共通ローダーを終了
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
        this.clickEventNowFlag = false;

        this.requestViewForceUpdate();
        this.$nextTick(() => {
          this.setSelectedColumn(true);
        });
      },
      /**
       * ベッド未登録領域データの書き換え(ストア)
       * @param indexDim インデックス配列 [0]日付 [1]クール
       */
      resetBedNotYetInfoOnStore(indexDim) {
        //ストア情報の書き換え
        const setJson = {};
        //移動後のベッド未登録エリアの設定(ストア)
        setJson.setIndex = indexDim;
        setJson.setBedJson = [null];
        for (
          let i = 1;
          i < this.propsJBedNotYet[indexDim[0]][indexDim[1]].length;
          i++
        ) {
          const cellData = this.propsJBedNotYet[indexDim[0]][indexDim[1]][i];
          if (cellData !== null) {
            setJson.setBedJson[setJson.setBedJson.length] = cellData;
          }
        }
        //データがなかったら(初期化時のnull以外がない)、0要素配列に置き換え
        if (setJson.setBedJson.length === 1) {
          setJson.setBedJson = [];
        }

        //ストアに反映
        this.setBedNotYet(setJson);
      },
      /**
       * クール未登録領域データの書き換え(ストア)
       * @param indexDim インデックス配列 [0]日付
       */
      resetKurNotYetInfoOnStore(indexDim) {
        //ストア情報の書き換え
        const setJson = {};
        //移動後のベッド未登録エリアの設定(ストア)
        setJson.setIndex = indexDim;
        setJson.setKurJson = [null];
        //領域を乙型にサーチ
        const d = indexDim[0];
        outloop: for (let b = 1; b <= this.dispNumNotYetKur; b++) {
          for (let k = 1; k <= this.kurNum; k++) {
            //セット(ただし、入っているデータのみ)
            if (typeof this.propsJKurNotYet[d][k][b] === DEF_UNDEFINED) {
              break outloop;
            }
            if (this.propsJKurNotYet[d][k][b] !== null) {
              setJson.setKurJson[
                setJson.setKurJson.length
                ] = this.propsJKurNotYet[d][k][b];
            }
          }
        }

        //データがなかったら(初期化時のnull以外がない)、0要素配列に置き換え
        if (setJson.setKurJson.length === 1) {
          setJson.setKurJson = [];
        }

        //ストアに反映
        this.setKurNotYet(setJson);
      },

      /**
       * 入外区分数値変更処理
       * 日付ヘッダーおよびクールヘッダーの入外区分数値を更新する。
       *@param  classInOut    入外区分
       *@param  addNumStr:    DEC(減少) or INC(増加)
       *@param  indexObj      インデックス配列 [0]:日付 [1]:クール [2]:ベッド
       *@param  isBedNotYet   ベッド未登録か
       *@param  isKurNotYet   クール未登録か
       */
      changeInOutNum(classInOut, addNumStr, indexObj, isBedNotYet, isKurNotYet) {
        let propStr = null;
        let isInOutUnknown = false;

        if (0 === classInOut) {
          // 外来
          propStr = "outpatnum";
        } else if (1 === classInOut) {
          // 入院
          propStr = "inpatnum";
        } else {
          //入外区分不明
          isInOutUnknown = true;
        }

        const addNum = OPE_DEC === addNumStr ? -1 : 1;
        const dayIndex = indexObj[0];
        const kurIndex = indexObj[1];

        // 日付ヘッダー
        const tmpObjDay = this.propsJDayHeader[dayIndex];
        let num = 0;
        if (! isInOutUnknown) {
          // 入院or外来件数更新
          num = this.propsJDayHeader[dayIndex][propStr];
          num += addNum;
          tmpObjDay[propStr] = num;
        }
        if (isBedNotYet || isKurNotYet) {
          // クール未登録またはベッド未登録の場合は"未"件数の変更を行う
          num = this.propsJDayHeader[dayIndex]["undecidednum"];
          num += addNum;
          tmpObjDay["undecidednum"] = num;
        }
        //deepcopy
        const tmpObjDayDeep = JSON.parse(JSON.stringify(tmpObjDay));
        this.propsJDayHeader.splice(dayIndex, 1, tmpObjDayDeep);

        // クールヘッダー
        if (! isKurNotYet) {
          const tmpObjKur = this.propsJKurHeader[dayIndex][kurIndex];
          if (! isInOutUnknown) {
            // 入院or外来件数更新
            num = this.propsJKurHeader[dayIndex][kurIndex][propStr];
            num += addNum;
            tmpObjKur[propStr] = num;
          }
          if (isBedNotYet) {
            // クール登録済みかつベッド未登録の場合は"未"件数の変更を行う
            num = this.propsJKurHeader[dayIndex][kurIndex]["undecidednum"];
            num += addNum;
            tmpObjKur["undecidednum"] = num;
          }
          //deepcopy
          const tmpObjKurDeep = JSON.parse(JSON.stringify(tmpObjKur));
          this.propsJKurHeader[dayIndex].splice(kurIndex, 1, tmpObjKurDeep);
        }
      },

      dblclickEvent() {
        //TODO:ダブルクリック時の処理
      },
      /**
       * マウス移動時の処理
       */
      mouseMoveEvent() {
        //------------------------------------------------------
        //kendo-gridのダブルクリックの無効化

        const handleElems = this.getScopedElementsByClassName("k-resize-handle");

        for (let i = 0; i < handleElems.length; i++) {
          const handleElem = handleElems[i];
          if (handleElem.__ntssDblclickDisabled) {
            continue;
          }
          $$(handleElem).off("dblclick.kendoGrid");
          handleElem.__ntssDblclickDisabled = true;
        }
      },
      /**
       *クールの幅リサイズ処理
       */
      onColumnResize(e) {
        const indexStr = (e.column?.field || "").replace("ProductName", "");
        const indexDim = indexStr.split("-");
        const dayIndex = Number(indexDim[0]);
        const kurIndex = Number(indexDim[1]);
        if (!dayIndex || !kurIndex) {
          return;
        }

        const newWidth = Math.max(20, Math.round(Number(e.newWidth) || 0));
        if (!this.kurDayWidth[dayIndex]) {
          this.kurDayWidth[dayIndex] = [];
        }
        // 状態は変更列のみ更新。DOM/Kendo は requestScheduleHeaderWidthSync 内で全列を状態から再適用し、
        // Kendo が一時的に縮めた左側列を元に戻す（左端固定・右端のみ変化）
        this.kurDayWidth[dayIndex][kurIndex] = newWidth;
        this.requestScheduleHeaderWidthSync();
      },
      /**
       * 日付ヘッダーの幅リサイズ後処理
       */
      onColumnResizeDay(e) {
        //#9505 スケジュール表のクール列幅を狭くした際に、ヘッダーと内容の表示がずれる不具合を修正しました Ji upd start
        // FNSI-add redmine、No.3924 徐 start
        let afterKurDimStr = null;
        if (this.kurNumIndex) {
          afterKurDimStr = this.kurNumIndex.split(':');
        }
        // FNSI-add redmine、No.3924 徐 end
        this.resizingNowFlag = true;
        //どの日付ヘッダーが動いたのかの確認
        const indexNum = e.column.field.replace("ProductName", "");

        // 日付ヘッダー（大表頭）の最小幅
        const DAY_MIN_WIDTH = 40;

        // 一部クールのみ操作している場合はその数、
        // そうでなければ全クール数を使用
        const childCount = afterKurDimStr
          ? afterKurDimStr.length
          : this.kurNum;

        // Kendo の newWidth を優先（getComputedStyle だと他列連動時に左端がずれる）
        const kendoDayWidth = Math.round(Number(e.newWidth) || 0);
        const finalTotalWidth = Math.max(
          kendoDayWidth > 0 ? kendoDayWidth : this.getDayColumnWidth(indexNum),
          DAY_MIN_WIDTH
        );

        // const dividedWidth = parseFloat(style.width) / (this.kurNum - kurNumCount);
        // 最終的な日付ヘッダー幅をクール数で均等分割
        const dividedWidth = finalTotalWidth / childCount;

        if (afterKurDimStr) {
          for (let k4 = 0; k4 < afterKurDimStr.length; k4++) {
            const kurIndex = Number(afterKurDimStr[k4]);
            if (!this.kurDayWidth[indexNum]) {
              this.kurDayWidth[indexNum] = [];
            }
            this.kurDayWidth[indexNum][kurIndex] = dividedWidth;
          }
        } else {
          for (let k3 = 1; k3 <= this.kurNum; k3++) {
            if (!this.kurDayWidth[indexNum]) {
              this.kurDayWidth[indexNum] = [];
            }
            this.kurDayWidth[indexNum][k3] = dividedWidth;
          }
        }

        this.requestScheduleHeaderWidthSync();
        this.resizingNowFlag = false;
      },

      /**
       * ベッドセルの初期化処理
       **/
      initBedCells(
        elems,
        props,
        maxD,
        maxX,
        maxY,
        width,
        height,
        title,
        idPrefix,
        cmpName
      ) {
        for (let d = 1; d <= maxD; d++) {
          elems[d] = new Array(maxX + 1);
          props[d] = new Array(maxX + 1);
          for (let x = 1; x <= maxX; ++x) {
            elems[d][x] = new Array(maxY + 1);
            props[d][x] = new Array(maxY + 1);
            for (let y = 1; y <= maxY; y++) {
              elems[d][x][y] = cmpName;
              props[d][x][y] = {};
              props[d][x][y].id = `${idPrefix + d}-${x}-${y}`;
              props[d][x][y].width = width;
              props[d][x][y].height = height;
              props[d][x][y].top = (y - 1) * height;
              const basePosX = (d - 1) * maxX * width;
              props[d][x][y].left = basePosX + (x - 1) * width;

              props[d][x][y].title = `${title + d}-${x}-${y}`;
            }
          }
        }
      },
      /**
       * 各要素への位置＆サイズの設定処理
       */
      setElem() {
        for (let i = 0; i < DEF_ELEMNUM; i++) {
          const idStr = `id_area${i + 1}`;
          const elem = this.getScopedElementById(idStr);

          if (null !== elem) {
            elem.style.left = `${this.dimX[i]}px`;
            elem.style.top = `${this.dimY[i] * this.elemResizeValue}px`;
            elem.style.width = `${this.dimW[i]}px`;
            elem.style.height = `${this.dimH[i] * this.elemResizeValue}px`;
          }
        }
      },
      /**
       * 初期表示時の各シャッター要素への位置＆サイズの設定処理
       */
      setInitShutterElem() {
        for (let i = 0; i < DEF_ELEMNUM; i++) {
          const idStr = `id_coverarea${i + 1}`;
          const elem = this.getScopedElementById(idStr);

          if (null !== elem) {
            elem.style.left = `${this.dimX[i]}px`;
            elem.style.top = `${this.dimY[i] * this.elemResizeValue}px`;
            elem.style.width = `${this.dimW[i]}px`;
            elem.style.height = `${this.dimH[i] * this.elemResizeValue}px`;
          }
        }
      },
      /**
       * シャッター使用後の回収(位置、サイズなどのリセット)処理
       */
      resetShutterElem() {
        for (let i = 0; i < DEF_ELEMNUM; i++) {
          const idStr = `id_coverarea${i + 1}`;
          const elem = this.getScopedElementById(idStr);

          if (null !== elem) {
            elem.style.left = "0px";
            elem.style.top = "0px";
            elem.style.width = "0px";
            elem.style.height = "0px";
          }
        }
      },
      /**
       * 各要素の位置＆サイズの設定処理
       **/
      calSizeAndPosition(x1, y1, w1, h1, h2, h3, h4, h9, w5, w10) {
        //要素1
        let indexNum = 0;
        this.dimX[indexNum] = x1;
        this.dimY[indexNum] = y1;
        this.dimW[indexNum] = w1;
        this.dimH[indexNum] = h1 + 3;
        //要素2
        indexNum = 1;
        this.dimX[indexNum] = x1;
        this.dimY[indexNum] = y1 + h1;
        this.dimW[indexNum] = w1;
        this.dimH[indexNum] = h2 - 1;
        //要素3
        indexNum = 2;
        this.dimX[indexNum] = x1;
        this.dimY[indexNum] = y1 + h1 + h2;
        this.dimW[indexNum] = w1 + 1;
        this.dimH[indexNum] = h3;
        //要素4
        indexNum = 3;
        this.dimX[indexNum] = x1;
        this.dimY[indexNum] = y1 + h1 + h2 + h3;
        this.dimW[indexNum] = w1 + 1;
        this.dimH[indexNum] = h4;
        //要素5
        indexNum = 4;
        this.dimX[indexNum] = x1 + w1;
        this.dimY[indexNum] = y1;
        this.dimW[indexNum] = w5;
        this.dimH[indexNum] = h1 + 4;
        //要素6
        indexNum = 5;
        this.dimX[indexNum] = x1 + w1;
        this.dimY[indexNum] = y1 + h1;
        this.dimW[indexNum] = w5;
        this.dimH[indexNum] = h2;
        //要素7
        indexNum = 6;
        this.dimX[indexNum] = x1 + w1;
        this.dimY[indexNum] = y1 + h1 + h2;
        this.dimW[indexNum] = w5;
        this.dimH[indexNum] = h3;
        //要素8
        indexNum = 7;
        this.dimX[indexNum] = x1 + w1;
        this.dimY[indexNum] = y1 + h1 + h2 + h3;
        this.dimW[indexNum] = w5;
        this.dimH[indexNum] = h4;
        //要素9(下のバー)
        indexNum = 8;
        this.dimX[indexNum] = x1 + w1;
        this.dimY[indexNum] = y1 + h1 + h2 + h3 + h4;
        this.dimW[indexNum] = w5 + DEF_SCROLLBAR_WIDTH;
        this.dimH[indexNum] = h9;
        //要素10(縦のバー)
        indexNum = 9;
        this.dimX[indexNum] = x1 + w1 + w5;
        this.dimY[indexNum] = y1 + h1;
        this.dimW[indexNum] = w10;
        this.dimH[indexNum] = h2 + DEF_SCROLLBAR_WIDTH;
        //要素11(縦のバー)
        indexNum = 10;
        this.dimX[indexNum] = x1 + w1 + w5;
        this.dimY[indexNum] = y1 + h1 + h2;
        this.dimW[indexNum] = w10;
        this.dimH[indexNum] = h3 + DEF_SCROLLBAR_WIDTH;
        //要素12(縦のバー)
        indexNum = 11;
        this.dimX[indexNum] = x1 + w1 + w5;
        this.dimY[indexNum] = y1 + h1 + h2 + h3;
        this.dimW[indexNum] = w10;
        this.dimH[indexNum] = h4 + DEF_SCROLLBAR_WIDTH;
      },
      /**
       * 表の縦幅サイズ変更
       */
      resizeListHeight() {
        const setWidth_tbl = this.totalWidth;

        //area5 7の横サイズ(内容)を設定します
        //+2は、スクロール時にずれるための補正(経験値)
        this.getScopedElementById(
          "id_area5_scrollarea").style.width = `${setWidth_tbl + 2}px`;
        // add #6050 スケジュール表の表示条件を変更した時の画面更新に時間がかかる 付 start
        this.area6Width = this.totalWidth;
        // add #6050 スケジュール表の表示条件を変更した時の画面更新に時間がかかる 付 end
        //DIVの数を数える
        let heightCounter = 0;
        // mod bug #7928 修正 chen start
        if (this.areaElems && this.areaElems[2]) {
          const divElems = this.areaElems[2].getElementsByTagName("div");

          for (let iDiv = 0; iDiv < divElems.length; iDiv++) {
            //表示状態のものだけ計算
            if (divElems[iDiv].style.visibility !== "hidden") {
              ++heightCounter;
            }
          }
        }
        // mod bug #7928 修正 chen end

        // スクロールバーの高さを取得
        // 定数を設定すると画面倍率変更時スクロールバー表示不当になるための補正
        let scrollbarHeight = this.getScopedElementById("scroll_area").offsetHeight - this.getScopedElementById("scroll_area").clientHeight;

        let totalHeight = 0;
        // ベッドエリアの高さ設定
        const setHeight =
          heightCounter * DEF_CELL_HEIGHT * this.elemResizeValue;
        totalHeight += setHeight;

        // ベッド未登録エリアの高さ(+ボーダー)
        totalHeight += this.notYetAreaHeightBed * this.elemResizeValue + 1;

        // クール未登録エリアの高さ(+ボーダー)
        totalHeight += this.notYetAreaHeightKur * this.elemResizeValue + 1;

        // スクロールバー分の高さを加算
        totalHeight += scrollbarHeight;

        // 表示領域の高さから、area1(ヘッダ)の高さを除いた高さを算出
        let mainHeight = this.getScheduleMainContentEl()?.clientHeight || 0;
        mainHeight -= this.dimH[0] * this.elemResizeValue;
        if (totalHeight > mainHeight) {
          totalHeight = mainHeight;
        }

        // モバイル環境の場合はスクロールバーが出ないので補正不要
        if (this.androidFlg || this.iosFlg) {
          scrollbarHeight = 0;
        }

        // 凡例の高さを計算
        let usageGuideHeight = 0;
        const guideAreaObj = this.getScopedElementById("area_usage_guide");
        if (this.isShowUsageGuide && guideAreaObj !== null) {
          usageGuideHeight = guideAreaObj.offsetHeight + 5;
          // 画面内に収まる高さの場合は補正を行わない
          const blankSpaceHeight = mainHeight - totalHeight;
          if (blankSpaceHeight > usageGuideHeight) {
            usageGuideHeight = 0;
          } else {
            usageGuideHeight -= blankSpaceHeight;
          }
        }

        // 縦スクロールバーの設定
        this.getScopedElementById("scroll_area").style.height = `${totalHeight - usageGuideHeight}px`;
        this.getScopedElementById("area2_4_header").style.height = `${totalHeight - scrollbarHeight - usageGuideHeight}px`;
        this.queueDayHeaderLayoutSync();
      },
      /**
       *スクロール同期処理
       */
      //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
      scrollWatch(event) {
        const scrollArea = this.getScopedElementById("scroll_area");
        if (!scrollArea) {
          return;
        }

        this.setScrollLeftWitch(scrollArea.scrollLeft);
        this.setScrollTopWitch(scrollArea.scrollTop);
        this.syncHeaderScrollLeft(scrollArea.scrollLeft);
      },
      //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
      scrollEvent(event) {
        const index = event.target.id.replace("id_area", "");
        //area9のスクロール補正
        if (this.areaElems[9].scrollLeft > this.totalWidth - this.listWidth) {
          this.areaElems[9].scrollLeft = this.totalWidth - this.listWidth;
        }

        //6のスクロール位置
        const left6 = this.areaElems[6].scrollLeft;
        //7のスクロール位置
        const left7 = this.areaElems[7].scrollLeft;
        //8のスクロール位置
        const left8 = this.areaElems[8].scrollLeft;

        //縦の変動判定 2と6
        if (index === "10" || index === "11" || index === "12") {
          this.areaElems[index - 4].scrollTop = this.areaElems[index].scrollTop;
          if (index === "10") {
            this.areaElems[2].scrollTop = this.areaElems[index].scrollTop;
          }
        }

        //横の変動判定 6と7と8
        if (index === "6" || index === "7" || index === "8" || index === "9") {
          if (!(left6 === left7 && left6 === left8)) {
            if (index === "6") {
              this.areaElems[7].scrollLeft = this.areaElems[index].scrollLeft;
              this.areaElems[8].scrollLeft = this.areaElems[index].scrollLeft;
            } else if (index === "7") {
              this.areaElems[6].scrollLeft = this.areaElems[index].scrollLeft;
              this.areaElems[8].scrollLeft = this.areaElems[index].scrollLeft;
            } else if (index === "8") {
              this.areaElems[6].scrollLeft = this.areaElems[index].scrollLeft;
              this.areaElems[7].scrollLeft = this.areaElems[index].scrollLeft;
            }
          }
          if (index === "9") {
            this.areaElems[5].scrollLeft = this.areaElems[index].scrollLeft;
            this.areaElems[6].scrollLeft = this.areaElems[index].scrollLeft;

            const vm = this;

            if (this.areaElems[6].scrollLeft !== this.areaElems[9].scrollLeft) {
              clearInterval(this.setArea6Id);
              this.setArea6Id = setInterval(
                function() {
                  vm.areaElems[6].scrollLeft =
                    vm.areaElems[9].scrollLeft;

                  if (
                    vm.areaElems[6].scrollLeft ===
                    vm.areaElems[9].scrollLeft) {
                    clearInterval(vm.setArea6Id);
                  }
                }.bind(vm),
                4);
            }

            this.areaElems[7].scrollLeft = this.areaElems[index].scrollLeft;
            this.areaElems[8].scrollLeft = this.areaElems[index].scrollLeft;
            this.syncHeaderScrollLeft(this.areaElems[index].scrollLeft);
          }
        }
      },
      /**
       * 明細横スクロールに合わせてヘッダー領域を同期します。
       *  {number} scrollLeft 横スクロール位置
       */
      syncHeaderScrollLeft(scrollLeft) {
        const headerArea = this.getScopedElementById("id_area5");
        if (!headerArea) {
          return;
        }
        if (headerArea.scrollLeft !== scrollLeft) {
          headerArea.scrollLeft = scrollLeft;
        }
      },
      /**
       * 初期メイン処理
       * ・枠の設定(値の割当)
       * ・画面表示開放
       * ・ヘッダー部分の設定(kendo-uiの設定)
       * ・表示開始日の設定
       * ・隠しスクロールバー表示領域のサイズ設定処理
       */
      procMain() {
        this.dimX = new Array(DEF_ELEMNUM);
        this.dimY = new Array(DEF_ELEMNUM);
        this.dimW = new Array(DEF_ELEMNUM);
        this.dimH = new Array(DEF_ELEMNUM);
        this.notYetAreaHeightBed = DEF_CELL_HEIGHT;
        this.notYetAreaHeightKur = DEF_CELL_HEIGHT;

        //確定エリアの高さの計算
        this.bedAreaHeight = this.calBedAreaHeight(this.titleNum);

        if (this.listWidth > this.totalWidth) {
          //表のトータル幅を超えていた場合は、トータル幅を採用
          this.listWidth = this.totalWidth;
        }

        //表の各要素への位置＆サイズの設定(変数への値の設定)
        this.calSizeAndPosition(
          0,
          0,
          DEF_BEDTITLE_WIDTH * this.elemResizeValue,
          DEF_HEADER_HEIGHT,
          this.bedAreaHeight,
          this.notYetAreaHeightBed,
          this.notYetAreaHeightKur,
          DEF_SCROLLBAR_WIDTH,
          this.listWidth,
          DEF_SCROLLBAR_WIDTH
        );
        //各要素への位置＆サイズの設定処理(calSizeAndPosition設定の反映のため必ず呼ぶ)
        this.setElem();

        //------------------------------------------------------
        //kendo uiのコンテント部分の高さの調整(不要なため、隠すので0pxを設定)

        this.resetScheduleGridContentHeight();

        //情報収集
        //日付ヘッダーの情報&クールヘッダーの情報の格納先初期化(領域確保))
        this.dayHeaderElems = new Array(this.dayHeaderNum + 1);
        this.kurHeaderElems = new Array(this.dayHeaderNum + 1);
        for (let d = 1; d <= this.dayHeaderNum; d++) {
          this.kurHeaderElems[d] = new Array(this.kurNum + 1);
        }

        //エリア要素の準備(各エリアの要素を事前取得しておく)
        for (let i = 1; i < DEF_ELEMNUM + 1; i++) {
          this.areaElems[i] = this.getScopedElementById(`id_area${i}`);
        }

        //-------------------------------------------------
        //kendo ui gridのダブルクリック自動調整の無効化

        const handleElems = this.getScopedElementsByClassName("k-resize-handle");

        for (let i = 0; i < handleElems.length; i++) {
          handleElems[i].off("dblclick.kendoGrid");
        }

        //kendo-gridへのコンポーネントの貼り付け(日付ヘッダー部分)
        this.relocateKendoHeaders("day", 0);

        //ベッド移動処理の初期化(親要素の取得)
        this.parentElem = this.getScopedElementById("id_maindiv");

        //日付の初期化(表示開始日の初期化)
        const today = dayjs();

        const yyyy = today.year();
        const mm = `0${today.month() + 1}`.slice(-2);
        const dd = `0${today.date()}`.slice(-2);

        // mod 7936 掲示板に連携通知がコンバートされていない 関 start
        if (this.$route.params.startDate != undefined) {
          this.dispStartDate = dayjs(this.$route.params.startDate).format("YYYY/MM/DD");

          this.dispStartDateForSetting = dayjs(this.$route.params.startDate).format("YYYY-MM-DD");
          // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
          this.dispStartYear = dayjs(this.$route.params.startDate).year();
          // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
        } else {
          this.dispStartDate = `${yyyy}/${mm}/${dd}`;

          this.dispStartDateForSetting = `${yyyy}-${mm}-${dd}`;
          // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
          this.dispStartYear = dayjs().year();
          // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
        }
        // mod 7936 掲示板に連携通知がコンバートされていない 関  end
        // 画面遷移パラメータ取得
        const queryParameters = this.getQueryParameters();

        // 日付が指定されて画面遷移した場合、リスト内から対象イベントを表示
        if (queryParameters.DATE) {
          const date = dayjs(queryParameters.DATE);
          if (date.isValid()) {
            this.dispStartDate = date.format("YYYY/MM/DD");
            this.dispStartDateForSetting = date.format("YYYY-MM-DD");
            this.dispStartYear = date.format("YYYY");
          }
        }
        // クエリパラメータをクリアする
        this.setQueryParameters({});

        //表示設定ポップアップの未選択エリアデフォルト選択
        // TODO: popoverで一旦コメントアウト
        // this.getScopedElementById("id_notyetsetting").options[
        //   this.dispCellNumNotYetArea
        // ].selected = true;
      },
      getDayHeaderColumnParts(index) {
        const dayRoot = this.getScopedElementById("kendo_day");
        if (!dayRoot || index < 0) {
          return { dayRoot: null, headerTable: null, bodyTable: null, headerCell: null, headerCol: null, bodyCol: null };
        }
        return {
          dayRoot,
          ...getKendoGridColumnDomParts(dayRoot, {
            field: `ProductName${index + 1}`,
            index
          })
        };
      },

      setDayHeaderColumnDisplay(index, visible, width = null) {
        const dayGrid = this.getDayGridWidget();
        const column = dayGrid?.columns?.[index] || null;
        if (column) {
          column.hidden = !visible;
          if (width != null) {
            column.width = width;
          }
        }

        const { headerCell, headerCol, bodyCol } = this.getDayHeaderColumnParts(index);
        const numericWidth = width == null ? null : Math.max(0, Math.round(Number(width) || 0));
        const widthText = numericWidth == null ? null : `${numericWidth}px`;

        this.applyScheduleColumnElementWidth(headerCell, widthText, visible);
        [headerCol, bodyCol].forEach((col) => {
          this.applyScheduleColumnElementWidth(col, widthText, visible);
        });
      },

      getKurHeaderColumnParts(index) {
        const kurRoot = this.getScopedElementById("kendo_kur");
        if (!kurRoot || index < 0) {
          return { kurRoot: null, headerTable: null, bodyTable: null, headerCell: null, headerCol: null, bodyCol: null };
        }
        const kurNum = Math.max(1, Number(this.kurNum) || 1);
        const dayIndex = Math.floor(index / kurNum) + 1;
        const kurIndex = (index % kurNum) + 1;
        return {
          kurRoot,
          ...getKendoGridColumnDomParts(kurRoot, {
            field: `ProductName${dayIndex}-${kurIndex}`,
            index
          })
        };
      },

      setKurHeaderColumnDisplay(index, visible, width = null) {
        const kurGrid = this.getKurGridWidget();
        const column = kurGrid?.columns?.[index] || null;
        if (column) {
          column.hidden = !visible;
          if (width != null) {
            column.width = width;
          }
        }

        const { headerCell, headerCol, bodyCol } = this.getKurHeaderColumnParts(index);
        const numericWidth = width == null ? null : Math.max(0, Math.round(Number(width) || 0));
        const widthText = numericWidth == null ? null : `${numericWidth}px`;

        this.applyScheduleColumnElementWidth(headerCell, widthText, visible);
        [headerCol, bodyCol].forEach((col) => {
          this.applyScheduleColumnElementWidth(col, widthText, visible);
        });
      },

      resizeDayHeaderColumn(index, width) {
        this.setDayHeaderColumnDisplay(index, true, width);
        this.queueDayHeaderLayoutSync();
      },

      queueDayHeaderLayoutSync(retryCount = 0) {
        if (this.dayHeaderLayoutRafId) {
          cancelAnimationFrame(this.dayHeaderLayoutRafId);
        }
        if (this.dayHeaderLayoutTimerId) {
          clearTimeout(this.dayHeaderLayoutTimerId);
          this.dayHeaderLayoutTimerId = 0;
        }
        this.dayHeaderLayoutRafId = requestAnimationFrame(() => {
          this.dayHeaderLayoutRafId = 0;
          const synced = this.syncDayHeaderWidthWithKur();
          if ((!synced && retryCount < 40) || (synced && retryCount < 4)) {
            this.dayHeaderLayoutTimerId = setTimeout(() => {
              this.dayHeaderLayoutTimerId = 0;
              this.queueDayHeaderLayoutSync(retryCount + 1);
            }, synced ? 16 : 75);
          }
        });
      },

      syncHeaderGridTables(root, totalWidth) {
        syncKendoGridHeaderBodyTableWidth(root, totalWidth, {
          includeContentExpander: true,
          hideHorizontalOverflow: false,
          removeHeaderRightPadding: true
        });
      },

      parseElementWidth(element) {
        if (!element) {
          return 0;
        }
        const styleWidth = parseFloat(element.style?.width || "");
        if (!Number.isNaN(styleWidth) && styleWidth > 0) {
          return styleWidth;
        }
        const attrWidth = parseFloat(element.getAttribute?.("width") || "");
        if (!Number.isNaN(attrWidth) && attrWidth > 0) {
          return attrWidth;
        }
        const rectWidth = element.getBoundingClientRect?.().width || 0;
        if (rectWidth > 0) {
          return rectWidth;
        }
        return 0;
      },

      getScheduleBodyColumnWidth(dayIndex, kurIndex) {
        const bodyCell = this.getScopedElementById(`id_td_${dayIndex}_${kurIndex}`);
        const bodyWidth = this.parseElementWidth(bodyCell);
        if (bodyWidth > 0) {
          return bodyWidth;
        }
        const stateWidth = Number(this.kurDayWidth?.[dayIndex]?.[kurIndex]) || 0;
        if (stateWidth > 0) {
          return stateWidth;
        }
        const kurWidth = Number(this.kurWidth?.[kurIndex]) || 0;
        return kurWidth > 0 ? kurWidth : DEF_KUR_WIDTH;
      },

      applyScheduleColumnWidth(elements, visible, width) {
        const numericWidth = visible ? Math.max(0, Math.round(Number(width) || 0)) : 0;
        const widthText = `${numericWidth}px`;
        elements.forEach((element) => {
          if (!element) {
            return;
          }
          element.style.display = visible && numericWidth > 0 ? "" : "none";
          element.style.width = widthText;
          element.style.removeProperty("min-width");
          element.style.removeProperty("max-width");
        });
      },

      syncDayHeaderWidthWithKur() {
        const dayRoot = this.getScopedElementById("kendo_day");
        const kurRoot = this.getScopedElementById("kendo_kur");
        const bodyTable = this.getScopedElementById("id_area6_tbl");
        if (!dayRoot || !kurRoot || !bodyTable) {
          return false;
        }

        const dayHeaderCols = findKendoGridHeaderColElements(dayRoot);
        const dayBodyCols = findKendoGridBodyColElements(dayRoot);
        const kurHeaderCols = findKendoGridHeaderColElements(kurRoot);
        const kurBodyCols = findKendoGridBodyColElements(kurRoot);
        const dayHeaders = findKendoGridHeaderCells(dayRoot).filter((cell) => cell.classList?.contains("cls-kendo-grid-head"));
        const kurHeaders = findKendoGridHeaderCells(kurRoot).filter((cell) => cell.classList?.contains("cls-kendo-grid-head") && cell.classList?.contains("sub-header"));

        if (!dayHeaders.length || !kurHeaders.length) {
          return false;
        }

        let totalWidth = 0;
        for (let dayIndex = 1; dayIndex <= this.dayHeaderNum; dayIndex++) {
          const dayHeader = dayHeaders[dayIndex - 1];
          if (!dayHeader) {
            continue;
          }

          const dayVisible =
            dayIndex <= this.dayMax &&
            (this.holidayFlag || this.getDayDispIndex[dayIndex - 1]);

          let dayWidth = 0;
          for (let kurIndex = 1; kurIndex <= this.kurNum; kurIndex++) {
            const headerIndex = (dayIndex - 1) * this.kurNum + kurIndex - 1;
            const kurHeader = kurHeaders[headerIndex];
            const headerCol = kurHeaderCols[headerIndex] || null;
            const bodyCol = kurBodyCols[headerIndex] || null;
            const bodyCell = this.getScopedElementById(`id_td_${dayIndex}_${kurIndex}`);
            const kurHeaderComponent = this.getScopedElementById(`id_kurheader${dayIndex}-${kurIndex}`);
            const kurVisible = dayVisible && this.kurDayVisibility?.[dayIndex]?.[kurIndex] === "visible";
            const kurWidth = kurVisible ? this.getScheduleBodyColumnWidth(dayIndex, kurIndex) : 0;

            this.applyScheduleColumnWidth(
              [kurHeader, headerCol, bodyCol, kurHeaderComponent],
              kurVisible,
              kurWidth
            );
            if (bodyCell) {
              this.applyScheduleColumnWidth([bodyCell], kurVisible, kurWidth);
            }
            dayWidth += kurVisible ? kurWidth : 0;
          }

          const targetWidth = Math.round(dayVisible ? dayWidth : 0);
          const headerCol = dayHeaderCols[dayIndex - 1] || null;
          const bodyCol = dayBodyCols[dayIndex - 1] || null;
          const dayHeaderComponent = this.getScopedElementById(`id_dayheader-${dayIndex}`);

          this.applyScheduleColumnWidth(
            [dayHeader, headerCol, bodyCol, dayHeaderComponent],
            dayVisible && targetWidth > 0,
            targetWidth
          );
          if (dayVisible && targetWidth > 0) {
            totalWidth += targetWidth;
          }
        }

        const normalizedWidth = Math.round(totalWidth || this.totalWidth || this.area6Width || 0);
        this.totalWidth = normalizedWidth;
        this.area6Width = normalizedWidth;
        this.resetScheduleGridContentHeight();
        this.syncHeaderGridTables(dayRoot, normalizedWidth);
        this.syncHeaderGridTables(kurRoot, normalizedWidth);
        this.resetScheduleGridContentHeight();
        const scrollArea = this.getScopedElementById("id_area5_scrollarea");
        if (scrollArea) {
          scrollArea.style.width = `${normalizedWidth + 2}px`;
          scrollArea.style.minWidth = `${normalizedWidth + 2}px`;
        }
        const area6Table = this.getScopedElementById("id_area6_tbl");
        if (area6Table) {
          area6Table.style.width = `${normalizedWidth}px`;
          area6Table.setAttribute("width", `${normalizedWidth}px`);
        }
        const area6Inner = this.getScopedElementById("id_area6")?.firstElementChild;
        if (area6Inner) {
          area6Inner.style.width = `${normalizedWidth}px`;
        }
        return true;
      },

      /**
       * kendo-gridへコンポーネントを貼り付ける処理

       * @param setOption "day""kur""both"
       * @param startIndex(0～)
       * */
      relocateKendoHeaders(setOption, startIndex) {
        //ヘッダーテーブルへの日付ヘッダーコンポーネントの配置

        if (setOption === "day" || setOption === "both") {
          const dayElem = this.getScopedElementById("kendo_day");
          const daysE = dayElem.getElementsByTagName("TH");
          for (let d = startIndex; d < daysE.length; d++) {
            const index = daysE[d].dataset.field.replace("ProductName", "");
            const targetId = `id_dayheader-${index}`;
            const targetElem = this.getScopedElementById(targetId);
            if (targetElem !== null) {
              daysE[d].textContent = null;
              daysE[d].appendChild(targetElem);
            }
          }
          this.queueDayHeaderLayoutSync();
        }
        //ヘッダーテーブルへのクールヘッダーコンポーネントの配置

        if (
          (setOption === "kur" || setOption === "both") &&
          "ref_kendoKur" in this.$refs &&
          typeof this.$refs.ref_kendoKur !== DEF_UNDEFINED) {
          //columsのベースindexは、0
          let columnIndex = 0;

          const kurElem = this.getScopedElementById("kendo_kur");
          const kursE = kurElem.getElementsByTagName("TH");
          for (let k = startIndex; k < kursE.length; k++) {
            const index = kursE[k].dataset.field.replace("ProductName", "");
            const targetId = `id_kurheader${index}`;
            const targetElem = this.getScopedElementById(targetId);
            if (null !== targetElem) {
              kursE[k].textContent = null;
              kursE[k].appendChild(targetElem);
            } else {
              //未使用のカラムなので、閉じておきます。
              this.setKurHeaderColumnDisplay(columnIndex, false, 0);
            }
            columnIndex++;
          }
        }
      },

      /**
       * データ取得
       *  ベッド情報取得
       *  クール情報取得
       *  ベッドグループ情報取得
       */
      async getBaseDataFromDB() {
        //ベッドおよびクールの情報取得処理
        const scheduleItemThis = this;
        const facilityCd = this.getFacilityCd;
        await ApiHelper.get("/scheduleList/getBedAndKurInfo", {
          // ここにクエリパラメータを指定する
          facilityCd
        })
          //成功した場合の処理
          .then(response => {
            //ストアにセット
            this.setBedAndKurInfo(response);

            //クール数の設定
            scheduleItemThis.kurNum = scheduleItemThis.getMaxKurNum;

            scheduleItemThis.titleNum = scheduleItemThis.getMaxBedNum;

            //表示条件設定:ベッドグループオプションの取得
            scheduleItemThis.roomBedGroupNamesForOption =
              scheduleItemThis.getRoomBedGroupMap;
            scheduleItemThis.roomBedGroupNum = scheduleItemThis.getRoomBedGroupMap.length;

            //表示条件設定:クールオプションの取得
            scheduleItemThis.kurNamesForOption = scheduleItemThis.getKurNames;

            //表示幅の計算
            scheduleItemThis.totalWidth =
              scheduleItemThis.kurNum * DEF_KUR_WIDTH * scheduleItemThis.dispWeek * 7;

            //ベッドタイトル列の設定(バインド変数)
            scheduleItemThis.propsJ = new Array(scheduleItemThis.titleNum + 1);
            for (let b = 1; b <= scheduleItemThis.titleNum; b++) {
              scheduleItemThis.propsJ[b] = { title: "bedtitle" };
            }

            //クール幅の設定
            scheduleItemThis.dayWidth = 0;
            scheduleItemThis.kurWidth = new Array(scheduleItemThis.kurNum + 1);
            scheduleItemThis.kurWidth[0] = 0; //使わない要素ですが0初期化しておく
            for (let i = 1; i <= scheduleItemThis.kurNum; i++) {
              const setWidth = i > scheduleItemThis.kurNum ? 0 : DEF_KUR_WIDTH;
              scheduleItemThis.kurWidth[i] = setWidth;
              scheduleItemThis.dayWidth += scheduleItemThis.kurWidth[i];
            }
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'getBaseDataFromDB', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });
      },

      setSelectedIndexList() {
        this.selectedKurIndexList = this.kurNamesForOption.map(
          (kur, index) => index + 1
        );
        this.isSetting = true;
      },

      setPopoverData(event, direction, coverTarget) {
        // 編集前データを書き換えない為にディープコピー
        // TODO: リファクタリング必要
        const popoverTarget = event;
        const popoverDirection = direction;
        const popoverCoverTarget = coverTarget;
        const kurNum = this.kurNum;
        const kurNamesForOption = this.kurNamesForOption.map((kur, i) => {
          return { index: i + 1, kurName: kur };
        });
        const roomBedGroupNum = this.roomBedGroupNum;
        const roomBedGroupNamesForOption = this.roomBedGroupNamesForOption;
        const startDateMain = this.dispStartDateForSetting;
        const isCheckedHolidayMain = this.holidayFlag;
        const dispWeekDurationMain = String(this.dispWeek);
        const selectedKurIndexListMain = [...this.selectedKurIndexList];
        const selectedRoomBedGroupCdMain = this.selectedRoomBedGroupCd;
        const isCheckedNameMain = this.nameSetting;
        const notYetLineMain = this.changeNotYetAreaCellNum;
        const isCheckedUnmatchMain = this.unmatchSetting;
        const isCheckedPlanMain = this.planSetting;
        const isCheckedPlanMainteWaterMain = this.plansettingMainteWater;
        const isShowUsageGuideMain = this.isShowUsageGuide;

        this.popoverData = {
          popoverTarget,
          popoverDirection,
          popoverCoverTarget,
          kurNum,
          kurNamesForOption,
          roomBedGroupNum,
          roomBedGroupNamesForOption,
          startDateMain,
          isCheckedHolidayMain,
          // TODOがNumberなぜ？※変更する値は文字列なのに。。。
          dispWeekDurationMain,
          selectedKurIndexListMain,
          selectedRoomBedGroupCdMain,
          isCheckedNameMain,
          notYetLineMain,
          isCheckedUnmatchMain,
          isCheckedPlanMain,
          isCheckedPlanMainteWaterMain,
          isShowUsageGuideMain
        };
      },

      /**
       * フォントサイズ変更に応じて要素の幅を調整
       */
      adjustElemSize() {
        const dayHeader = this.getDayGridWidget();
        const kurHeader = this.getKurGridWidget();
        // 文字サイズおよび画面サイズ倍率に対応するため1桁目の値を必ず0になるように切り上げ
        const newWidth = Math.ceil(DEF_KUR_WIDTH * this.elemResizeValue / 10) * 10;
        // 初回表示時は全クール表示、選択されたものがあればそちらの件数に合わせる
        const selectedKurCount = this.selectedKurIndexList.length || this.kurNum;
        this.totalWidth = 0;

        if (dayHeader && dayHeader.columns && dayHeader.columns.length) {
          dayHeader.columns.forEach(col => {
            if (!col.hidden) {
              dayHeader.resizeColumn(col, newWidth * selectedKurCount);
            }
          });
        }

        kurHeader.columns.forEach(col => {
          if (!col.hidden) {
            kurHeader.resizeColumn(col, newWidth);
          }
        });
        // FNSI-add redmine 3924 start
        let indexTdId = "";
        let elemTd = "";

        for (let d = 1; d <= this.dayMax; d++) {
          for (let k = 1; k <= this.kurNum; k++) {
            if (this.kurDayVisibility[d][k] === "visible") {
              this.kurDayWidth[d][k] = newWidth;
              this.totalWidth += this.kurDayWidth[d][k];
              //ベッド列の幅調整
              indexTdId = `id_td_${d}_${k}`;
              elemTd = this.getScopedElementById(indexTdId);
              elemTd.style.width = `${newWidth}px`;

              //ベッド未登録列の幅調整
              indexTdId = `id_tdbednotyet_${d}_${k}`;
              elemTd = this.getScopedElementById(indexTdId);
              elemTd.style.width = `${newWidth}px`;

              //クール未登録列の幅調整
              indexTdId = `id_tdkurnotyet_${d}_${k}`;
              elemTd = this.getScopedElementById(indexTdId);
              elemTd.style.width = `${newWidth}px`;
            }
          }
        }
        // FNSI-add redmine 3924 end

        this.setElem();
        this.resizeList();
        this.requestViewForceUpdate();
      },

      cancelSendCondConfirm(e) {

        if (e === "OK" && !this.isMovePats) {
          /* add #10601 スケジュール表動作不正  --start */
          if(this.moveSendConditionData.pat_id){
            this.setHeaderDispPatMode(this.moveSendConditionData);
          }
          /* add #10601 スケジュール表動作不正  --end */
          // 選択した患者で条件送信画面画面へ遷移
          this.changeView("send-condition", false);
        }

        /* add #10601 スケジュール表動作不正 start */
        if (e === "Cancel") {
          this.refreshData();
        }
        /* add #10601 スケジュール表動作不正 end */
      },

      changeView(toName, menuFlg) {

        // mod FNSI 条件送信画面へ遷移を判定 start -- Sanjingye Sun 20201229
        let realRouterNm = toName;
        if(toName === "send-condition") {
          realRouterNm = "weight-mode";
        }
        // 移動する画面の機能コードを取得する
        const functionCd = getFunctionCd(realRouterNm);
        // mod FNSI 条件送信画面へ遷移を判定 end -- Sanjingye Sun 20201229

        // 操作メニューポップオーバーを非活性にする
        this.menuPopoverShowFlag = false;
        // 権限チェックを行う
        if (!this.hasNextAuthority(functionCd)) {
          return true;
        }
        if (toName === "send-condition") {
          // 遷移先に必要な情報(患者ID)を渡すorストアにセットする
          this.setInputPatId(this.getHeaderDispInfo.hospPatId);
          let selectedOrdNo = this.getHeaderDispInfo.ordNo;
          if (selectedOrdNo === null || selectedOrdNo === "") {
            selectedOrdNo = this.selectedSendConditonOrdNo;
            this.selectedSendConditonOrdNo = null;
          }

          this.setSelectOrdNo({
            ordNo: selectedOrdNo,
            ordNo2: null
          });
        }
        // add FNSI修正 治療記録画面バッグ 房 start
        if (toName === "treatment-record") {
          this.setOrd({readOnly: false,});
        }
        // add FNSI修正 治療記録画面バッグ 房 end

        //画面遷移
        if (menuFlg) {
          // 選択 ord_no を保持
          this.setOrdNoForSideBarRecord(this.getHeaderDispInfo.ordNo);
          this.setSrcFuncName(this.$route.name);
        }
        this.$router.push({ name: toName });
      },

      async refreshData() {
        if (this.selfScreenName !== this.$route.name) {
          return;
        }
        try {
          // 共通ローダー:表示開始
          this.setLoadingScreenVisible(true);
       await this.changeDispTerm(0);
          this.$nextTick(() => {
            this.adjustElemSize();
          });
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('ScheduleListMainItem.vue', 'refreshData', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          console.error(error);
        }
        this.clickEventNowFlag = false;
        this.isMovePats = false;
        this.beforeMoveDataList = [];
        this.afterMoveDataList = [];
        if (this.movingBlockElem != null && this.movingBlockElem.parentNode) {
            this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
          }
        this.movingBlockElem = null;
        if (this.movingChipElem != null && this.movingChipElem.parentNode) {
          // 選択状態表示（緑枠線）解除
          this.removeCheckClass();
          this.movingChipElem.parentNode.removeChild(this.movingChipElem);
        }
        this.movingChipElem = null;
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
      },
      // add #9558 機能帳票でパラメータが正しく渡されていない 高 start
      getPatIds () {
        var patIdsList = new Array();
        var tmpList = new Array();
        var number = 0;
        // add 11010 スケジュール表出力時の処理が不足している gjn start
        for (let key in this.dispdata) {
          if (key >= this.getSettingStartDate()) {
            for (var ind = 0; ind < this.dispdata[key].length - 1;ind++) {
              tmpList[ind] = this.dispdata[key][ind].beddata;
              for (var indNo = 0; indNo < tmpList[ind].length;indNo++) {
                if (tmpList[ind][indNo] !== null && tmpList[ind][indNo].pat_id !== undefined) {
                  patIdsList[number] = tmpList[ind][indNo].pat_id;
                  number++;
                }
              }
            }
          }
        }
        patIdsList = [...new Set(patIdsList)];
        // add 11010 スケジュール表出力時の処理が不足している gjn end
        return patIdsList;
      },
      // add #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
      getbedCdList () {
        var bedCdList = new Array();
        var number = 0;
        if (this.selectedRoomBedGroupCd == 0) {
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          // for (var ind = 0; ind < this.roomBedGroupNamesForOption.length;ind++) {
          //   bedCdList[number] = this.roomBedGroupNamesForOption[ind].bedCd;
          //   number++;
          // }
          bedCdList = this.getAllBedCds;
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
        } else {
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          // bedCdList[number] = this.selectedRoomBedGroupCd;
          let roomBedGroup = this.getRoomBedGroupData.find(rbr => rbr.roomBedGroupCd === this.selectedRoomBedGroupCd);
          if(roomBedGroup) {
            bedCdList = JSON.parse(roomBedGroup.bedList);
          }
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
        }
        return bedCdList;
      },
      // add #11285 機能帳票の印刷情報対応② 高 start
      getbedNames () {
        var bedNames = "";
        if (this.selectedRoomBedGroupCd == 0) {
          // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
          bedNames = "すべて";
          // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end

        } else {
          for (var ind = 0; ind < this.roomBedGroupNamesForOption.length;ind++) {
            if (this.selectedRoomBedGroupCd == this.roomBedGroupNamesForOption[ind].bedCd) {
              bedNames = this.roomBedGroupNamesForOption[ind].bedName;
            }
          }
        }
        return bedNames;
      },
      getKurNamesNew () {
        var kurNames = "";
        let kurNumArray = this.kurNumIndex == null ? [] : this.kurNumIndex.split(':').map(Number);
        if (kurNumArray.length == 3 || kurNumArray.length == 0) {
          kurNames = "すべて";

        } else {
          for (var indKur = 0; indKur < kurNumArray.length;indKur++) {
            for (var ind = 0; ind < this.kurNamesForOption.length;ind++) {
              if (kurNumArray[indKur] - 1 == ind) {
                kurNames += this.kurNamesForOption[ind] + "・";
              }
            }
          }
          kurNames = kurNames.slice(0,-1);
        }

        return kurNames;
      },
      changeKey() {
        this.dispWeek = 2;
        this.holidayFlag = true;
        this.setNameSetting(false);
        this.changeNotYetAreaCellNum = 2;
        this.setUnmatchSetting(false);
        this.setPlanSetting(false);
        this.setPlanSettingMainteWater(false);
        this.isShowUsageGuide = false;
      },
      // add #11285 機能帳票の印刷情報対応② 高 end
      getToDateMeth () {
        const date = new Date(this.dispStartDateForSetting);
        // mod 11010 スケジュール表出力時の処理が不足している gjn start
        var count = this.dayMax % 2 == 0 ? this.dayMax / 2 - 1 : Math.floor(this.dayMax / 2);
        // mod 11010 スケジュール表出力時の処理が不足している gjn end
        date.setDate(date.getDate() + count);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const newDate = `${year}-${month}-${day}`;
        return newDate;
      },
      // add #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
      // add #9558 機能帳票でパラメータが正しく渡されていない 高 end
      // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
      getSelectPatIds() {
        var patIdsList = new Array();
        var tmpList = new Array();
        var dayIndex = 0;
        var number = 0;
        for (let key in this.dispdata) {
          if(this.dayMax <= dayIndex) continue;
          dayIndex++;
          if(!this.holidayFlag && !this.getDayDispIndex[dayIndex - 1]) continue;
          for (var ind = 0; ind < this.dispdata[key].length - 1; ind++) {
            tmpList[ind] = this.dispdata[key][ind].beddata;
            for (var indNo = 0; indNo < tmpList[ind].length; indNo++) {
              if(tmpList[ind][indNo] === null) continue;
              if(tmpList[ind][indNo].kur_cd === null || this.getSelectKurCds.indexOf(tmpList[ind][indNo].kur_cd) === -1) continue;
              if(tmpList[ind][indNo].bed_cd === null || this.getbedCdList().indexOf(tmpList[ind][indNo].bed_cd) === -1) continue;
              if (tmpList[ind][indNo].pat_id !== undefined) {
                patIdsList[number] = tmpList[ind][indNo].pat_id;
                number++;
              }
            }
          }

        }
        patIdsList = [...new Set(patIdsList)];
        return patIdsList;
      },
      // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
      requestrReportParams(param) {
        // 機能コード判定
        if ( param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
          // 機能一致

          // 印刷パラメータを応答
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          var date = this.getSettingStartDate();
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
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
          // add #11285 機能帳票の印刷情報対応② 高 end
          // add 機能帳票パラメータ確認 陳 start
          const param1 = {
            // mod #9558 機能帳票でパラメータが正しく渡されていない 高 start
            // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //patIds: this.getPatIds(),
            patIds: this.getSelectPatIds(),
            // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            // mod #9558 機能帳票でパラメータが正しく渡されていない 高 end
            //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            functionCd:"00901",
            facilityCd: this.getFacilityCd,
            baseDate:date,
            treatDate:date,
            date:date,
            fromDate:date,
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //dialysisDate: date,
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
            // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
            // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
            kurCdList:this.getStorSimlpSearchQurey.selectedKurName,
            // mod #11285 機能帳票の印刷情報対応② 高 start
            // mod #11285 機能帳票の印刷情報対応② 高 end
            // add #11285 機能帳票の印刷情報対応② 高 start
            bedCdListString:this.getbedNames(),
            patGroups:this.getStorSimlpSearchQurey.selectedPatGroupNames ? this.getStorSimlpSearchQurey.selectedPatGroupNames:"すべて",
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //bedNames:this.getbedNames(),
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            kurNames:this.getKurNamesNew(),
            expressCondCdStr:expressCondCd,
            freeWord:this.getStorSimlpSearchQurey.freeWord,
            // add #11285 機能帳票の印刷情報対応② 高 end
            // add #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //selectKurCd:this.selectedKurIndexList,
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            bedCds:this.getbedCdList(),
            toDate:this.getToDateMeth(),
            // add #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
            // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
            // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
            //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          };
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          var param2 = this.getReportParams;
          for(var key in param2){
            param1[key]=param2[key];
          }
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          EventBus.$emit("sendReportParams", param1);
          // add 機能帳票パラメータ確認 陳 end
        }
      },
      /**
       * add FNSI 1006 No.426 -- Sanjingye Sun 20201224
       */
      restFacilitySettingDialogsOpenedFlg() {
        this.facilitySettingDialog1007OpenedFlg = false;
        this.facilitySettingDialog1008OpenedFlg = false;
        this.facilitySettingDialog3005OpenedFlg = false;
		  // add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
        this.facilitySettingDialog2007OpenedFlg = false;
        this.facilitySettingDialog2008OpenedFlg = false;
		  // add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
        // add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
        this.facilitySettingDialog1000OpenedFlg = false;
        // add 6444【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        this.facilitySettingRadDialog2008OpenedFlg = false;
        this.facilitySettingExamDialog2008OpenedFlg = false;
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      },
      // mod FNSI 1006 No.426 start -- Sanjingye Sun 20201221
      // その他予定の有無(検査依頼、放射線検査依頼、患者イベント)
      async getOtherScheduleData() {
        // その他の予定データリスト取得
        const paramB = {
          startDate: dayjs(this.treatDateDim[0], "YYYYMMDD").format("YYYY/MM/DD"),
          endDate: dayjs(this.treatDateDim[this.treatDateDim.length - 1], "YYYYMMDD").format("YYYY/MM/DD"),
        };
        await ApiHelper.get("/scheduleList/getOtherScheduleList", paramB)
          //成功した場合の処理
          .then(response => {
            //ストアへデータをセット
            this.setOtherSchedule(response.data);
          })
          .catch(err => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ScheduleListMainItem.vue', 'getOtherScheduleData', err);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            err;
          })
      },
      // mod FNSI 1006 No.426 end -- Sanjingye Sun 20201221

      /**
       * add FNSI 1006 No.426 -- Sanjingye Sun 20201223
       * Find if there is a patEventBeginDate in nowadays schedule data according to percificate pat id.
       * If there has none in them, return null.
       * FIXME: There maybe more dates. -- Sanjingye Sun 20201223
       */
      getPatEventBeginDate(searchPatId) {

        let patEventBeginDate = null;
        for(let treatDate in this.getOtherSchedule.eventList) {

          let patId = this.getOtherSchedule.eventList[treatDate].filter(patId => patId == searchPatId)[0];
          if(patId){
            patEventBeginDate = treatDate;
            break;
          }

        }

        return patEventBeginDate;
      },
      //9273 start
      getPatEventFlag(searchPatId,searchTreatDate){
        let hasEventFlag = false
        const patIds = this.getOtherSchedule.eventList[searchTreatDate].filter(patId => patId == searchPatId);
        if(patIds.length>0){
          hasEventFlag = true;
        }
        return hasEventFlag
      },
      //9273 end
      //add FNSI修正 redmine4339 房 start
      async compareEachNotYetKur(fromDimData, toDimData) {
        let moveEnable = true;
        if (fromDimData.length > 1 && toDimData.length > 1) {
          let index = 0;
          if (fromDimData.length > toDimData.length) {
            index = toDimData.length;
          } else {
            index = fromDimData.length;
          }
          for (let b = 1; b < index; b++) {
            if (!this.getBedDispState(b - 1)) {
              //非表示状態なので処理しない。
              continue;
            }
            //同一患者同一治療日同一クール同一治療方法の確認
            let retBool = false;
            // add bug 6034 修正 chen start
            if (toDimData[b].kur_cd + "" !== "0") {
              // add bug 6034 修正 chen end
              const response = await this.checkSamePatDayKurMode(
                [fromDimData[b].ordNo],
                [toDimData[b].treatDate],
                [toDimData[b].kur_cd]).catch(error => {
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                getErrorMessage('ScheduleListMainItem.vue', 'compareEachBeds', error);
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                throw error;
              });
              retBool = response;
              if (retBool) {
                //メッセージを「同一患者同一治療日同一クール同一治療方法」関連に設定
                this.msgNo = DEF_DIALOG_MSG_1;
              }
            }
            moveEnable = !retBool;
            if (!moveEnable) {
              //移動できないものが見つかったのでここで確認終了(全ては見ない)
              break;
            }
          }
        }
        return moveEnable;
      },
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
      showExamDeadlineMsg(headerFlg) {
        this.messageDialogInfo.title = "締切り依頼保存確認";
        this.messageDialogInfo.stringParams = [];
        this.facilitySettingExamDialog2008OpenedFlg = true;
        this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_33;
        this.messageDialogInfo.type = DEF_MSGTYPE_OK_CANCEL;
        this.messageDialogInfo.isDialogVisible = true;
        this.messageDialogInfo.dialogNo = DEF_DIALOG_UNMATCH;
        this.headerFlg = headerFlg;
        this.msgPopUpFlag = true;
        this.showExamDeadlineMsgFlg = false;
        this.showRadDeadlineMsgFlg = false;
      },
      showRadDeadlineMsg(headerFlg) {
        this.messageDialogInfo.title = "締切り依頼保存確認";
        this.messageDialogInfo.stringParams = [];
        this.facilitySettingRadDialog2008OpenedFlg = true;
        this.messageDialogInfo.messageCd = DEF_DIALOG_MSG_33;
        this.messageDialogInfo.type = DEF_MSGTYPE_OK_CANCEL;
        this.messageDialogInfo.isDialogVisible = true;
        this.messageDialogInfo.dialogNo = DEF_DIALOG_UNMATCH;
        this.headerFlg = headerFlg;
        this.msgPopUpFlag = true;
        this.showExamDeadlineMsgFlg = false;
        this.showRadDeadlineMsgFlg = false;
      },
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      //add FNSI修正 redmine4339 房 end

      // add #10359 編集権限について、対応する。 zhangyue start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },

      setMoveAuthrityAlert: _.debounce(function () {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "治療指示")
        });
      }, 1500),

      // add #10359 編集権限について、対応する。 zhangyue end
      // add 10601 スケジュール表動作不正 関  start
      clearRadAndExamSetting () {
        this.setFacilitySetting3005_4SelectedVal("");
        this.setFacilitySetting1007_4SelectedVal("");
        this.setFacilitySetting1008_4SelectedVal("");
        this.radDeadlineSelectedVal = "";
        this.examDeadlineSelectedVal = "";
        this.examDeadlineCancelCheck = "";
        this.radDeadlineCancelCheck = "";
      },
      /**
       * メッセージのtitle取得
       */
      getMessageTitle(messageCd, title) {
        return DIALOG_MESSAGES[messageCd].title || title;
      },
      /**
       * スケジュール選択状態を解除します
       */
      removeCheckClass() {
        // 全ての要素を取得
        const elements = this.getScopedQueryAll('.item-row-checked');
        // 要素から当該クラスの除去
        elements.forEach(element => {
          element.classList.remove('item-row-checked');
        });
      },
      /**
       * 固定列からのスクロールイベントを同期します。
       * wheel, scroll, touchmove イベントに対応。
       * @param {Event} event - スクロール関連のイベントオブジェクト
       */
      syncScrollFromFixed(event) {
        const movableArea = this.getScopedElementById("scroll_area");
        if (!movableArea) return;

        switch (event.type) {
          case "wheel":
            movableArea.scrollTop += event.deltaY;
            break;
          case "touchmove":
          case "scroll":
            movableArea.scrollTop = event.target.scrollTop;
            break;
        }
      },
      /**
       * タッチ開始時のY座標を記録します。
       * @param {TouchEvent} event - タッチ開始イベント
       */
      handleTouchStart(event) {
        this.touchStartY = event.touches[0].clientY;
      },
      /**
       * タッチ移動に応じてスクロール位置を調整します。
       * @param {TouchEvent} event - タッチ移動イベント
       */
      handleTouchMove(event) {
        const touchY = event.touches[0].clientY;
        const deltaY = this.touchStartY - touchY;
        const movableArea = this.getScopedElementById("scroll_area");
        if (movableArea) {
          movableArea.scrollTop += deltaY;
        }
        this.touchStartY = touchY;
      },

      /**
       * 抽出条件の初期データ(initData)を作成して返却します。
       */
      createInitData() {
        const tmpIndexlist = this.kurNamesForOption
          .map((kur, i) => String(i + 1))
          .join(":");

        const initData = {
          startDate: dayjs(this.dispStartDateForSetting).format("YYYY-MM-DD"),
          dispTermNum: String(this.dispWeek),
          dispHolidayFlag: this.holidayFlag,
          dispKurDimStr: tmpIndexlist,
          dispGroupDimStr: "all",
          dispNameFlag: this.nameSetting,
          dispNotYetLineNum: this.changeNotYetAreaCellNum,
          dispUnmatchFlag: this.unmatchSetting,
          dispPlanFlag: this.planSetting,
          dispPlanMainteWaterFlag: this.plansettingMainteWater,
          dispUsageGuide: this.isShowUsageGuide
        };

        return initData;
      },
      beforePrint(){
        // 選択状態を解除
        //trueの時(ボタンが押された)、移動状態だった場合、移動解除を行う
        if (null !== this.movingChipElem) {
          // セル移動中だった場合
          // 選択状態表示（緑枠線）解除
          this.removeCheckClass();
          // チップを削除
          if (this.movingChipElem.parentNode) {
            this.movingChipElem.parentNode.removeChild(this.movingChipElem);
          }
          // もう移動が終わったのでポインタを初期化
          this.movingChipElem = null;

          //終了
          this.clickEventNowFlag = false;
          EventBus.$emit("changeMismatchVa", false);
          EventBus.$emit("changeMismatchInfection", false);
          EventBus.$emit("changeMismatchTreatment", false);
          //点滅停止(移動可能範囲の点滅:仕様上、無効になっていて、表示に影響を与えてない場合があります)
          this.setOpaSwitch("off");
        } else if (null !== this.movingBlockElem) {
          // ブロック移動中だった場合
          // ブロックを削除
          if (this.movingBlockElem.parentNode) {
            this.movingBlockElem.parentNode.removeChild(this.movingBlockElem);
          }
          // もう移動が終わったのでポインタを初期化
          this.movingBlockElem = null;

          //終了
          this.clickEventNowFlag = false;
          this.isMovePats = false;
          //点滅停止(移動可能範囲の点滅:仕様上、無効になっていて、表示に影響を与えてない場合があります)
          this.setOpaSwitch("off");
        }
      },
    }
  };
</script>

<!-- 個別スタイル定義 -->
<style>
  /** 動的追加するクラスだけscopedにすると読み込まれないためscoped外*/

  .cls-kendo-grid-head {
    /*height: calc(4em + 1px) !important; */
    height: calc(2.5em + 1px) !important;
    padding: 0px !important ;
    box-sizing: border-box;
    color: white;
    background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
    background-color: var(--ntss-list-header-background-color) !important;
  }
  .sub-header {
    background-color: #333333 !important;
    background-image: none !important;
  }
  .cls_move_chip {
    position: absolute;
    background: pink;
    border: #595959 solid 1px;
    user-select: none;
    z-index: 6;
    pointer-events: none;
  }
  .cls_move_block {
    position: absolute;
    box-shadow: 5px 5px 10px grey;
    user-select: none;
    z-index: 6;
    opacity: 1;
    background-color: white;
    pointer-events: none;
  }
  .cls_move_block table {
    border-collapse: separate;
    border-spacing: 2px;
  }
  .cls_move_block .cls-cmp-dayheader {
    box-sizing: border-box !important;
    width: 100% !important;
  }
  #area2_4_header {
    overflow-y: scroll;
    scrollbar-width: none; /* Firefox */
    -ms-overflow-style: none; /* IE 10+ */
    -webkit-overflow-scrolling: touch;
  }
  #area2_4_header::-webkit-scrollbar {
    display: none; /* Chrome, Safari */
  }
  @media print {
    body:has(.schedule-list-main) #main-id{
      display: inline-block !important;
    }
  }
</style>

<style scoped>
  .cancel-send-message {
    z-index: 1000 !important;
  }

  /** 文字サイズ変更のためにkendo-uiのCSSの一部を強制書き換え*/

  .k-widget {
    font-size: inherit !important;
  }

  .cls-scrollbar {
    position: absolute;
    background: white;
    border: white solid 1px;
    overflow-x: auto;
    white-space: nowrap;
  }

  /** 幅変更ガイドラインの書式**/

  .cls-pad {
    padding-right: 0px !important;
  }

  .cls-dayheader {
    /* height: calc(4em - 1px); */
    height: calc(2.545em);
    background: #595959;
  }

  .cls-kurheader {
    height: 30px;
    background: #595959;
  }

  .cls-bed-title {
    background: #595959;
    border-left: silver solid 1px !important;
    border-bottom: silver solid 1px !important;
    padding: 0px !important ;
    box-sizing: border-box;
    color: white;
    border-right: 0 !important;
  }

  .cls-col {
    border: white solid 1px;
    background: blue;
    height: 50px;
  }

  .cls-table {
    table-layout: fixed;
    border: #595959 solid 0px !important;
    border-spacing: 0 !important;
    border: none;
  }

  .cls-td {
    width: 100px;
  }
  .cls-tr {
    width: 100px;
  }
  .cls-cover {
    z-index: 10;
    position: absolute;
    border: white solid 1px;
    color: white;
    background: #595959;
  }
  .cls-area1 {
    border: silver solid 1px;
    color: white;
    border-bottom: 0;
    border-right: 0;
    background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
    background-color: var(--ntss-list-header-background-color) !important;
  }
  .cls-area2 {
    overflow-y: hidden;
    overflow-x: hidden;
    border-top: solid 1px silver;
    border-bottom: 0;
    border-left: solid 1px silver;
  }
  .cls-area3 {
    border-top: solid 1px silver;
    background-color: #333333;
  }
  .cls-area4 {
    border: white solid 1px;
    border-top: 0;
    background-color: #333333;
  }
  .cls-area5 {
    border-width: 0 1px 0 0;
    border-style: solid;
    border-color: var(--master-maintenance-kgrid-border-color);
  }
  .cls-area5-cover {
    background: var(--ntss-list-header-background-color);
    background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
    padding-right: 17px;
  }
  .cls-area6 {
    border: silver solid 1px;
    border-top: 0;
    border-right: 0;
    border-bottom: 0;
  }
  .cls-area6-kur {
    position: absolute;
    border: white solid 1px;
    overflow: scroll;
    top: 0px;
    width: 80px;
    height: 1500px;
  }
  .cls-area7 {
    background: white;
    border-left: solid 1px silver;
  }
  .cls-area8 {
    border-left: solid 1px silver;
  }

  .cls-progress {
    position: absolute;
    top: 100px;
    left: 100px;
  }

  .cls-progress2 {
    width: 200px;
    height: 10px;
    z-index: 8;
    opacity: 1;
  }
  .cls-progress-bar {
    opacity: 0.5;
  }

  .circle {
    position: relative;
    width: 60px;
    height: 60px;
    background: #333;
    border-radius: 50%;
    text-align: center;
    overflow: hidden;
    z-index: 1;
  }

  .circle::before {
    content: "";
    display: block;
    position: absolute;
    top: 0;
    left: -30px;
    width: 60px;
    height: 60px;
    background: #999;
    transform-origin: right 30px;
    z-index: 2;
    animation: rotate-circle-left 2s infinite linear forwards;
  }

  .circle::after {
    content: "";
    display: block;
    position: absolute;
    top: 0px;
    left: 30px;
    width: 60px;
    height: 60px;
    background: #999;
    transform-origin: left 30px;
    z-index: 3;
    animation: rotate-circle-right 2s infinite linear forwards;
  }

  .circle .circle-inner {
    position: absolute;
    top: 5px;
    left: 5px;
    width: 50px;
    height: 31px;
    padding-top: 19px;
    background: #fff;
    border-radius: 50%;
    z-index: 4;
    opacity: 0.5;
  }

  .btn-scheldule-list {
    justify-content: left;
    padding: 0;
    margin-right: 5px;
  }

  .btn-scheldule-list .icon {
    height: 1.5em;
    width: 1.5em;
    margin: 0 5px 0 5px;
  }

  .schedule-list-header :deep(.popover--top) {
    width: auto;
  }

  @keyframes rotate-circle-right {
    0% {
      transform: rotate(0deg);
      background: #999;
    }
    50% {
      transform: rotate(180deg);
      background: #999;
    }
    50.01% {
      transform: rotate(360deg);
      background: #333;
    }
    100% {
      transform: rotate(360deg);
      background: #333;
    }
  }

  @keyframes rotate-circle-left {
    0% {
      transform: rotate(0deg);
    }
    50% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(180deg);
    }
  }

  .cls-loading-modal-big {
    text-align: left;
    font-size: 30px;
  }
  .cls-loading-modal {
    text-align: left;
    font-size: 12px;
  }
  .cls_chip {
    position: absolute;
    border: blue solid 1px;
    user-select: none;
    z-index: 6;
  }

  :deep(.cls-cmp-dayheader),
  :deep(.cls-cmp-kurheader) {
    width: 100% !important;
    min-width: 0 !important;
    max-width: none !important;

    display: block;
    box-sizing: content-box;
  }
  .cls_move_block :deep(.cls-cmp-dayheader) {
    box-sizing: border-box !important;
  }
  /** popover設定 **/

  .cls-popovertable {
    color: black;
    font-size: 8px;
    vertical-align: baseline;
  }

  .popover-enter-active,
  .popover-leave-active {
    transition: opacity 1s;
  }

  .popover-enter,
  .popover-leave-to {
    opacity: 0;
  }

  /* Vue3/Kendo: flex ヘッダーだと1列リサイズで行全体が連動するため table レイアウトに戻す */
  #kendo_kur .k-grid-header,
  #kendo_day .k-grid-header {
    display: block !important;
  }

  #kendo_kur :deep(.k-grid-header-wrap table),
  #kendo_kur :deep(.k-grid-header-table),
  #kendo_day :deep(.k-grid-header-wrap table),
  #kendo_day :deep(.k-grid-header-table) {
    table-layout: fixed !important;
  }

  /* 列幅は JS で総幅(px)指定。min-width:100% だとビューポートに合わせて他列が再分配され左端がずれる */
  #kendo_kur,
  #kendo_day {
    width: auto;
    min-width: 0;
  }

  #kendo_kur :deep(.k-grid),
  #kendo_day :deep(.k-grid) {
    width: auto !important;
    min-width: 0 !important;
  }

  #kendo_kur .k-widget {
    line-height: 18px;
    line-height: normal;
  }


  .loader {
    margin: 100px auto;
    font-size: 25px;
    width: 1em;
    height: 1em;
    border-radius: 50%;
    position: relative;
    text-indent: -9999em;
    -webkit-animation: load5 1.1s infinite ease;
    animation: load5 1.1s infinite ease;
    -webkit-transform: translateZ(0);
    -ms-transform: translateZ(0);
    transform: translateZ(0);
  }
  @-webkit-keyframes load5 {
    0%,
    100% {
      box-shadow: 0em -2.6em 0em 0em #ffffff,
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.5),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.7);
    }
    12.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.7),
      1.8em -1.8em 0 0em #ffffff, 2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.5);
    }
    25% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.5),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.7), 2.5em 0em 0 0em #ffffff,
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    37.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.5),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.7), 1.75em 1.75em 0 0em #ffffff,
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    50% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.5),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.7), 0em 2.5em 0 0em #ffffff,
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    62.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.5),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.7), -1.8em 1.8em 0 0em #ffffff,
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    75% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.5),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.7), -2.6em 0em 0 0em #ffffff,
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    87.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.5),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.7), -1.8em -1.8em 0 0em #ffffff;
    }
  }
  @keyframes load5 {
    0%,
    100% {
      box-shadow: 0em -2.6em 0em 0em #ffffff,
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.5),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.7);
    }
    12.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.7),
      1.8em -1.8em 0 0em #ffffff, 2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.5);
    }
    25% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.5),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.7), 2.5em 0em 0 0em #ffffff,
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    37.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.5),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.7), 1.75em 1.75em 0 0em #ffffff,
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    50% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.5),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.7), 0em 2.5em 0 0em #ffffff,
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.2),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    62.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.5),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.7), -1.8em 1.8em 0 0em #ffffff,
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    75% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.5),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.7), -2.6em 0em 0 0em #ffffff,
      -1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2);
    }
    87.5% {
      box-shadow: 0em -2.6em 0em 0em rgba(255, 255, 255, 0.2),
      1.8em -1.8em 0 0em rgba(255, 255, 255, 0.2),
      2.5em 0em 0 0em rgba(255, 255, 255, 0.2),
      1.75em 1.75em 0 0em rgba(255, 255, 255, 0.2),
      0em 2.5em 0 0em rgba(255, 255, 255, 0.2),
      -1.8em 1.8em 0 0em rgba(255, 255, 255, 0.5),
      -2.6em 0em 0 0em rgba(255, 255, 255, 0.7), -1.8em -1.8em 0 0em #ffffff;
    }
  }

  /* 凡例 */
  #area_usage_guide {
    position: absolute;
    bottom: 0;
    width: 100%;
    display: flex;
    flex-wrap: wrap;
    color: var(--ntss-list-body-color);
  }

  .usage-guide-div {
    margin-right: 1em;
    display: flex;
  }

  .usage-guide-element {
    width: 1em;
    height: 1em;
    margin-top: 0.2em;
  }

  /* kendoスクロールデフォルト：有効(hidden)
・不要(全体スクロールとクールスクロールが同期しない)のため初期化 */
  .cls-kurheader :deep(.k-grid-header-wrap) {
    overflow: initial;
  }

  .loading-modal {
    font-size: 30px;
  }

  .schedule-list-main :deep(.k-grid .k-table-th) {
    border-color: white !important;
  }

  #kendo_day :deep(th.cls-kendo-grid-head) {
    padding: 0 !important;
  }
  #kendo_kur :deep(th.cls-kendo-grid-head) {
    padding: 0 !important;
  }
  div[id*="id_bedtitle"] {
    background-color: #333333 !important;
    /* FNSI-add テーマ切替の場合、枠線が見えない 徐 start */
    border-color: gray;
    /* FNSI-add テーマ切替の場合、枠線が見えない 徐 end */
    background-image: none !important;
  }
  /* FNSI 印刷プレビューの文字が重なっているの対応 xie start */
  @media print {
    div :deep(.cls-bed2){
      overflow: hidden !important;
    }
    #scroll_area{
      overflow: hidden !important;
      height: auto !important;
    }
    #id_area1,#area2_4_header{
      position: relative;
      z-index: 1;
    }
    .cls-area5{
      overflow: hidden !important;
    }
    body:has(.scroll-rightmost) .main-content-area {
      margin-left: 0px !important;
    }
    #area_usage_guide {
      position: static !important;
    }
  }
  /* FNSI 印刷プレビューの文字が重なっているの対応 xie end */
</style>
