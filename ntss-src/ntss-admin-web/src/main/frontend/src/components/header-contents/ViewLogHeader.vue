<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
          <v-ons-col class="function-section">
            <div class="function-item-wrapper" style="display: flex; flex-wrap: nowrap; align-items: center;">
              <ons-icon
                class="function-item"
                ref="itemSelector"
                icon="fa-cogs"
                @click="listSelectItem('itemSelector')"
              ></ons-icon>
              <!-- mod Download表示条件 陳 start -->
              <!-- <ons-icon v-if="isMasterUser" class="function-item" icon="fa-download" @click="onClickDownload()"></ons-icon> -->
              <ons-icon class="function-item" icon="fa-download" @click="onClickDownload()"></ons-icon>
              <!-- mod Download表示条件 陳 end -->
              <div v-if="isMasterUser" class="download-button-wrapper function-item">
                <v-ons-button class="button btn3-normal" ref="popoverDownloadTarget" @click="onClickMultiDownload('popoverDownloadTarget')">ログファイルダウンロード</v-ons-button>
              </div>
            </div>
            <!-- mod FNSI-改修内容4429修正 関　start -->
            <!-- <label class="function-item function-item"> -->
            <label class="function-item function-item-style" style="display: flex; align-items: center; white-space: nowrap;">
            <!-- mod FNSI-改修内容4429修正 関　end -->
              <v-ons-checkbox v-model="viewDetail" @click="changeViewDetail()" />
              <span>詳細表示</span>
            </label>
          </v-ons-col>
          <list-selector
            :key="componentKey('表示項目設定')"
            :visible.sync="isItemSelectorPopupVisible"
            v-bind="itemSelectorData"
            v-bind:sort="true"
            :target="selectorTarget"
            @commit="commitItemListSelect($event)"
          />
      </v-ons-row>
    </div>
    <!-- 検索条件：入力エリア -->
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'popover-area']"
      @preshow="popoverPreShowOther"
      @postshow="popoverPostShowOther($event, 'viewLog'), getCurrentValue()"
      @posthide="popoverPosthideOther($event, 'viewLog'), restorePrevValue()"
    >
      <div class="pop-area">
        <div class="pop-main-area">
          <!-- 表示期間 -->
          <v-ons-row class="condition-row">
            <v-ons-col width="25%" class="pop-title">
              <label style="white-space: nowrap;">表示期間</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-row class="center-row" style="flex-wrap: nowrap;">
                <div style="display: flex; min-width: 13em;">
                <!-- add 日付最大値を増やす 馬宇婷 start-->
<!--                <input-->
<!--                  id="startDate"-->
<!--                  class="input-area ntss-custom-input"-->
<!--                  type="date"-->
<!--                  max="9999-12-31"-->
<!--                  v-model="searchCondition.noticeStartDate"-->
<!--                  @input="setNoticeValue($event)"-->
<!--                  @keyup="noticeStartDateChange"-->
<!--                />-->
                  <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
                  <!-- <input
                    id="startDate"
                    class="input-area ntss-custom-input"
                    type="date"
                    max="9999-12-31"
                    v-model="searchCondition.noticeStartDate"
                    @keyup="noticeStartDateChange"
                  /> -->
                  <date-input
                    id="startDate"
                    class="ntss-input-date input-area ntss-custom-input"
                    type="date"
                    max="9999-12-31"
                    v-model="searchCondition.noticeStartDate"
                    @handleClearInput="searchCondition.noticeStartDate = null"
                    @keyup="noticeStartDateChange"
                  />
                  <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
                <!-- add 日付最大値を増やす 馬宇婷 end-->
                  <common-calendar v-model="searchCondition.noticeStartDate" class="calender" />
<!--                <v-ons-input-->
<!--                  id="startTime"-->
<!--                  v-model="searchCondition.noticeStartTime"-->
<!--                  type="time"-->
<!--                  @blur="setNoticeValue($event)"-->
<!--                  @keyup="noticeStartTimeChange"-->
<!--                  ></v-ons-input>-->
<!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
                  <!-- <v-ons-input
                    id="startTime"
                    v-model="searchCondition.noticeStartTime"
                    type="time"
                    @keyup="noticeStartTimeChange"
                  ></v-ons-input> -->
                  <time-input
                    id="startTime"
                    v-model="searchCondition.noticeStartTime"
                    @handleClearInput="searchCondition.noticeStartTime = null"
                    @keyup="noticeStartTimeChange"
                  />
                  <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
                </div>
                <label class="adjust">&nbsp;&nbsp;〜&nbsp;&nbsp;</label>
              </v-ons-row>
              <!-- add 日付check 陳 start-->
              <span class="error-message" v-if="showErrorStartDate || showErrorStartTime">
                {{ errors.first("searchCondition.noticeStartDate") || this.msgDiaLog }}</span>
              <!-- add 日付check 陳 end-->
              <v-ons-row class="center-row" style="flex-wrap: nowrap;">
                <div style="display: flex; min-width: 13em;">
                <!-- add 日付最大値を増やす 馬宇婷 start-->
<!--                <input-->
<!--                  id="endDate"-->
<!--                  class="input-area ntss-custom-input"-->
<!--                  type="date"-->
<!--                  max="9999-12-31"-->
<!--                  v-model="searchCondition.noticeEndDate"-->
<!--                  @input="setNoticeValue($event)"-->
<!--                  @keyup="noticeEndDateChange"-->
<!--                />-->
                  <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
                  <!-- <input
                    id="endDate"
                    class="input-area ntss-custom-input"
                    type="date"
                    max="9999-12-31"
                    v-model="searchCondition.noticeEndDate"
                    @keyup="noticeEndDateChange"
                  /> -->
                  <date-input
                    id="endDate"
                    class="ntss-input-date input-area ntss-custom-input"
                    type="date"
                    max="9999-12-31"
                    v-model="searchCondition.noticeEndDate"
                    @handleClearInput="searchCondition.noticeEndDate = null"
                    @keyup="noticeEndDateChange"
                  />
                  <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
                <!-- add 日付最大値を増やす 馬宇婷 end-->
                  <common-calendar v-model="searchCondition.noticeEndDate" class="calender" />
<!--                <v-ons-input-->
<!--                  id="endTime"-->
<!--                  v-model="searchCondition.noticeEndTime"-->
<!--                  type="time"-->
<!--                  @blur="setNoticeValue($event)"-->
<!--                  @keyup="noticeEndTimeChange"-->
<!--                ></v-ons-input>-->
                  <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
                  <!-- <v-ons-input
                    id="endTime"
                    v-model="searchCondition.noticeEndTime"
                    type="time"
                    @keyup="noticeEndTimeChange"
                  ></v-ons-input> -->
                   <time-input
                    id="endTime"
                    v-model="searchCondition.noticeEndTime"
                    @handleClearInput="searchCondition.noticeEndTime = null"
                    @keyup="noticeEndTimeChange"
                  />
                  <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
               <!-- mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 start -->
                <!-- <v-ons-select
                  v-model="searchCondition.duration"
                  @change="onChangeStartDate()"
                > -->
                </div>
                <v-ons-select
                  v-model="searchCondition.duration"
                  @mouseleave="onChangeStartDate()"
                  @click="changeStartDate()"
                >
                <!-- mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 end -->
                  <option
                    v-for="(item, index) in durationList"
                    :key="index"
                    :value="item.cd"
                  >{{ item.name }}</option>
                </v-ons-select>
              </v-ons-row>
              <!-- add 日付check 陳 start-->
              <span class="error-message" v-if="showErrorEndDate || showErrorEndTime">
                {{ errors.first("searchCondition.noticeStartDate") || this.msgDiaLog }}</span>
              <!-- add 日付check 陳 end-->
            </v-ons-col>
          </v-ons-row>
          <!-- 施設選択 -->
          <v-ons-row
            v-if="isMasterUser"
            class="condition-row"
          >
            <v-ons-col width="25%" vertical-align="center" class="pop-title">
              <label style="white-space: nowrap;">施設選択</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <kendo-multiselect
                style="min-width: 17em;"
                v-model="searchCondition.facilityCd"
                :data-source="facilityInfo"
                data-text-field="facilityName"
                data-value-field="facilityCd"
                @select="onSelectFacility"
                @deselect="onDeselectFacility"
              />
            </v-ons-col>
          </v-ons-row>
          <!-- 利用者 -->
          <v-ons-row class="condition-row">
            <v-ons-col width="25%" vertical-align="center" class="pop-title">
              <label style="white-space: nowrap;">利用者</label>
            </v-ons-col>
            <v-ons-col vertical-align="center" style="white-space: nowrap;">
              <input
                class="custom-input-disabled ntss-custom-input"
                style="min-width: 14em;"
                type="text"
                :value="selectedDisplayText(searchCondition.userId)"
                :disabled="true"
              />
              <v-ons-button
                ref="userSelector"
                class="btn3-normal common-style-select-button"
                @click="listSelectItem('userSelector')"
              >選択</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <!-- 患者 -->
          <v-ons-row class="condition-row">
            <v-ons-col width="25%" vertical-align="center" class="pop-title">
              <label style="white-space: nowrap;">患者</label>
            </v-ons-col>
            <v-ons-col vertical-align="center" style="white-space: nowrap;">
              <input
                class="custom-input-disabled ntss-custom-input"
                style="min-width: 14em;"
                type="text"
                :value="selectedDisplayText(searchCondition.patId)"
                :disabled="true"
              />
              <v-ons-button
                ref="patientSelector"
                class="btn3-normal common-style-select-button"
                @click="listSelectItem('patientSelector')"
              >選択</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <!-- フリーワード -->
          <v-ons-row class="condition-row">
            <v-ons-col width="25%" vertical-align="center" class="pop-title">
              <label style="white-space: nowrap;">フリーワード</label>
            </v-ons-col>
            <v-ons-col vertical-align="center" class="center-row">
              <v-ons-input v-model="searchCondition.keySearch" class="input-area" type="text" style="min-width: 14em;"></v-ons-input>
              <v-ons-select v-model="searchCondition.typeSearch" style="min-width: 5em;">
                <option
                  v-for="(item, index) in typeSearchList"
                  :key="index"
                  :value="item.cd"
                >{{ item.name }}</option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
          <!-- 機能名 -->
          <v-ons-row v-if="isMasterUser" class="condition-row">
            <v-ons-col width="25%" vertical-align="center" class="pop-title">
              <label style="white-space: nowrap;">機能名</label>
            </v-ons-col>
            <v-ons-col vertical-align="center" style="white-space: nowrap;">
              <input
                class="custom-input-disabled ntss-custom-input"
                style="min-width: 14em;"
                type="text"
                :value="selectedDisplayText(searchCondition.serviceName)"
                :disabled="true"
              />
              <v-ons-button
                ref="serviceSelector"
                class="btn3-normal common-style-select-button"
                @click="listSelectItem('serviceSelector')"
              >選択</v-ons-button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>

      <div class="condition-row condition-button-area">
        <div class="clear-button">
          <v-ons-button class="btn2-cancel common-style-cancel-button" @click="dialogClear">クリア</v-ons-button>
        </div>
        <div class="ok-button">
        <!-- mod 日付check 陳 start-->
        <!-- <v-ons-button class="ok" @click="dialogOk">検索</v-ons-button>-->
          <v-ons-button class="btn3-normal common-style-select-button" @click="dialogOk"
            :disabled="showErrorEndDate || showErrorStartDate || showErrorEndTime || showErrorStartTime"
            style="width: 100px !important"
          >OK</v-ons-button>
        <!-- mod 日付check 陳 start-->
        </div>
      </div>
    </v-ons-popover>
    <!-- download popover -->
    <v-ons-popover
      cancelable
      :visible.sync="popoverDownloadVisible"
      :target="downloadTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'download-log-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="onHideDownloadLog(); popoverPosthide($event)"
    >
      <div class="pop-area">
        <div class="pop-main-area">
          <div class="download-wrapper">
            <v-ons-row>
              <div class="download-field">
              <input
                class="download-input"
                v-model="searchDownloadLog"
                @keyup="searchLogList"
                type="text">
              <v-ons-icon icon="fa-search" size="2.0em" style="color:gray;"></v-ons-icon>
              </div>
            </v-ons-row>
            <v-ons-row>
                <!-- PAGING -->
                <v-ons-col class="download-paging">
                  <v-ons-icon
                    @click="navigatePaging(true)"
                    icon="fa-angle-left"
                    size="2.0em"
                    style="color:gray;"
                    :class="{'disable-nagivation': currentLogPage === 0}"></v-ons-icon>
                  <div class="navigation-bar">
                    <span
                      v-for="(page, index) in logItemTotalPage"
                      v-show="isPageShowing(index)"
                      :class="{'current-page': (index == currentLogPage)}"
                      @click="currentLogPage = index"
                      :key="index">
                      {{getPagingContent(index)}}
                    </span>
                  </div>
                  <v-ons-icon
                    @click="navigatePaging(false)"
                    icon="fa-angle-right"
                    size="2.0em"
                    style="color:gray;"
                    :class="{'disable-nagivation': currentLogPage >= logItemTotalPage.length - 1}"></v-ons-icon>
                </v-ons-col>
            </v-ons-row>
            <v-ons-row class="download-nav">
              <!--modify by liuzhibo 2022-11-29[6888][ログ参照の挙動がおかしいの修正 -- start-->
              <!--<v-ons-col class="download-path">-->
              <v-ons-col class="download-path">
              <!--modify by liuzhibo 2022-10-29[6888][ログ参照の挙動がおかしいの修正 -- end-->
                <span class=""> / </span>
                <span v-for="(path, index) in displayPath" :key="index">
                  <span class="clickable-path" @click="openLogFolderByPath(path, index)">{{path}}</span>
                  <span class="">{{path.length > 0 ? ' / ' : ''}}</span>
                </span>
              </v-ons-col>
              <v-ons-col class="download-sort">
                <v-ons-icon
                  @click="sortDownloadLog"
                  :icon="isDownLogAcs ? 'fa-sort-asc' : 'fa-sort-desc'"
                  size="2.0em"
                  style="color:gray; cursor: pointer;"></v-ons-icon>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="download-indicate">
              <v-ons-icon icon="fa-folder-o" size="3.0em" style="color:gray;"></v-ons-icon>
              <v-ons-icon
                @click="backLogFolder(downloadLogPath.currentPath, downloadLogPath.root)"
                class="back-folder-icon"
                icon="fa-level-up"
                size="3.0em"
                style="color:gray; cursor: pointer;"></v-ons-icon>
            </v-ons-row>
            <div class="download-list">
              <v-ons-row
                class="download-item"
                v-for="(item, index) in logItemTotalPage[currentLogPage]"
                :key="index">
                <v-ons-col class="download-item-icon">
                  <v-ons-icon v-if="!item.folder" icon="fa-file-archive-o" size="3.0em" style="color:gray;"></v-ons-icon>
                  <v-ons-icon v-if="item.folder" icon="fa-folder-o" size="3.0em" style="color:gray;"></v-ons-icon>
                </v-ons-col>
                <!-- modify by wangying 2022-11-19[6888]ログ参照の挙動がおかしい[現象3]の修正 -- start -->
                <v-ons-col
                  class="download-item-name"
                  :class="{ 'pointer-cursor': item.folder }"
                  @click="openLogFolder(item, downloadLogPath.currentPath, downloadLogPath.root)">
                  <p>{{item.name}}</p>
                </v-ons-col>
                <!-- modify by wangying 2022-11-19[6888]ログ参照の挙動がおかしい[現象3]の修正 -- end -->
                <v-ons-col
                  class="download-item-icon">
                  <v-ons-icon
                    @click="onDownloadLog(downloadLogPath.currentPath, item)"
                    icon="fa-download"
                    size="3.0em"
                    style="color:gray; cursor: pointer;"></v-ons-icon>
                </v-ons-col>
              </v-ons-row>
            </div>
          </div>
        </div>
      </div>

      <div class="condition-row condition-button-area">
        <div class="download-all-button">
          <v-ons-button class="btn2-cancel common-style-cancel-button" @click="popoverDownloadVisible = false">閉じる</v-ons-button>
        </div>
      </div>
    </v-ons-popover>
    <!-- download popover end -->
    <list-selector
      :key="componentKey('スタッフ')"
      :visible.sync="isItemSelectorVisible"
      v-bind="itemSelectorData"
      v-bind:sort="refName == 'itemSelector'"
      :target="selectorTarget"
      @commit="commitItemListSelect($event)"
    />
  </v-card>
</template>

<script>
  import _ from "underscore";
  import {ApiHelper} from "@/apis/AxiosHelper.js";
  import moment from "moment";
  import {mapActions, mapGetters} from "vuex";
  import listSelector from "@/components/common/list-selector/ListSelector.vue";
  import CommonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import commonSearchArea from "@/components/common/CommonSearchArea";
  import {createItemListData} from "@/functions/for-componet/ListSelector.js";
  import {
    getListModule,
    getSysAllFunction,
    sendRequestGetDownloadLog,
    sendRequestGetDownloadPath,
    sendRequestGetSearchCondition,
    sendRequestUpdateCondition,
  } from "@/apis/log-reference";
  import PopoverMixin from "@/components/PopoverMixin";
  import {EventBus} from "@/eventBus.js";
  // add 日付check 陳 start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  // add 日付check 陳 end
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
  import { popoverPreShowOther, popoverPostShowOther, popoverPosthideOther } from "@/functions/common/CommonPopoverFunctionsOther";
  // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
  //#5590 2023/04/18 ×を常に表示するように修正 張博 start
  import DateInput from "@/components/common/DateInput.vue";
  import TimeInput from "@/components/common/TimeInput.vue";
  //#5590 2023/04/18 ×を常に表示するように修正 張博 end
  // add 利用者表示不正について、修正する。 dengshen start
  import store from "@/stores";
  // add 利用者表示不正について、修正する。 dengshen end

const uriUser = "/master_maintenance/mst_user";
const uriPat = `/patInfo/getPatByFacilityCd`;
const uriFunctionFacility = "/mstInfo/mstFacility/";
const appPropertiesLogging = "1";
const eventPropertiesLogging = "0";
const ITEM_PER_PAGE = 50;
const FIRST_PAGE_NUMBER = 3;
/**
 * @description 患者情報ヘッダ
 */
export default {
  mixins: [PopoverMixin],
  components: {
    "list-selector": listSelector,
    "common-calendar": CommonCalender,
    "common-searcharea": commonSearchArea,
    // #5590 2023/04/18 ×を常に表示するように修正 張博 start
    DateInput,
    TimeInput
    // #5590 2023/04/18 ×を常に表示するように修正 張博 end
  },
  props: {},

  data() {
    return {
// add 日付check 陳 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      showErrorEndDate: false,
      showErrorStartTime: false,
      showErrorEndTime: false,
// add 日付check 陳 end
      dropdownOpenFlag: false,
      // 古い状態
      selectedSavedCondition: null,
      savedConditionList: [],
      savedConditionListString: [],
      // 複数選択
      refName: "",
      selectorTarget: null,
      isItemSelectorVisible: false,
      itemSelectorData: null,

      selectedCondition: null,
      conditionName: "",
      // 施設
      facilityInfo: [],
      // モジュール
      moduleInfo: [],
      // 利用者
      userInfo: [],
      // 患者
      patInfo: [],
      // 機能名
      serviceInfo: [],
      // 検索ポップオーバー
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",

      // del 9826 ログ参照の期間指定の終了日が開始日と連動する 関 start
      // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen start
      // startDataChangeFlg: false,
      // endDataChangeFlg: false,
      // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen end
      // del 9826 ログ参照の期間指定の終了日が開始日と連動する 関 end
      searchConditionList: [],
      searchCondition: {
        noticeStartDate: null,
        noticeEndDate: null,
        noticeStartTime: null,
        noticeEndTime: null,
        duration: 0,
        facilityCd: [],
        moduleName: [],
        logClass: [],
        logType: ["error"],
        userId: [],
        patId: [],
        keySearch: "",
        serviceName: [],
        typeSearch: null
      },
      dataSearchCondition: {
        dateTime: null,
        facilityCd: [],
        logClass: [],
        logType: [],
        user: [],
        patient: [],
        freeWord: null,
        serviceName: [],
        moduleName: []
      },
      logClass: [appPropertiesLogging, eventPropertiesLogging],
      logType: ["error", "warning", "info"],
      selectedSearchCondition: null,
      durationList: [
        {cd: 0, name: "当日"},
        {cd: 1, name: "前日"},
        {cd: 3, name: "過去3日分"},
        {cd: 7, name: "過去7日分"},
        {cd: 14, name: "過去14日分"},
      ],
      typeSearchList: [
        { cd: 0, name: "等しい" },
        { cd: 1, name: "等しくない" },
        { cd: 2, name: "始まる" },
        { cd: 3, name: "終わる" },
        { cd: 4, name: "含む" },
        { cd: 5, name: "含まない" },
      ],
      moduleList: [
        { cd: 0, name: "ntss-admin-web" },
        { cd: 1, name: "ntss-alive-moni" },
        { cd: 2, name: "ntss-api" },
        { cd: 3, name: "ntss-client-comm" },
        { cd: 4, name: "ntss-coop-api" },
        { cd: 5, name: "ntss-core" }
      ],
      viewDetail: false,
      isItemSelectorPopupVisible: false,
      displayItems: [],
      columns: [],
      listSelectedFacility: [],
      tmpListSelectedFacility: [],
      userInfoInit: [],
      patInfoInit: [],
      popoverDownloadVisible: false,
      downloadTarget: null,
      downloadLogPath: null,
      isDownLogAcs: true,
      searchDownloadLog: '',
      downloadLogPathTemp: {},
      logItemTotalPage:[],
      currentLogPage: 0,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      pressedOkFlg: false,
      // mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 start
      changeStartDateFlg: false
      // mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 end
    };
  },

  computed: {
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
      userId: "getUserId",
      lastUserId: 'getLastUserId'
      /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
   }),
    ...mapGetters("account-edit", {
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("view-log", [
      "getLastCondition",
      "getSelectedSavedCondition",
      "getSelectedItemList",
      "getSelectedItem"
    ]),

    loggedUserId() {
      return this.getStateUserAccountInfo.userId;
    },

    isMasterUser() {
      //zhou ONLY for TEST !!!!!!!!!!
      //return this.getStateUserAccountInfo.userType === 1 && this.getStateUserAccountInfo.facilityCd === "nkknkk" ? true : false;
      // return true;
      //zhou ONLY for TEST !!!!!!!!!!
      //add FNSI-7759 劉全航 start
      return this.getStateUserAccountInfo.facilityCd === 'nkknkk';
      //add FNSI-7759 劉全航 end
    },
    footerButton() {
      return {
        Cancel: () => this.confirmNo(),
        Save: () => this.confirmYes(),
      };
    },
    displayPath() {
      if (this.downloadLogPath !== null) {
        let path = 'home' + this.downloadLogPath.currentPath;
        return path.split('/');
      }
      return [];
    },
// add 日付check 陳 start
    noticeStartDate() {
      return this.searchCondition.noticeStartDate;
    },
    noticeStartTime() {
      return this.searchCondition.noticeStartTime;
    },
    noticeEndDate() {
      return this.searchCondition.noticeEndDate;
    },
    noticeEndTime() {
      return this.searchCondition.noticeEndTime;
    }
// add 日付check 陳 end
  },

  watch: {
    getLastCondition() {
      this.searchCondition = Object.assign({}, this.getLastCondition);
    },
// add 日付check 陳 start
    noticeStartDate() {
      this.noticeStartDateChange();
    },
    noticeStartTime() {
      this.noticeStartTimeChange();
    },
    noticeEndDate() {
      this.noticeEndDateChange();
    },
    noticeEndTime() {
      this.noticeEndTimeChange();
    }
// add 日付check 陳 end
  },

  /**
   * @description 検索条件のプルダウンリスト(選択肢)を取得するため選択肢マスタから各データ取得
   */
  async created() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off('getDisplayColumns', this.getDisplayColumns);
    // add 性能改善メモリ不足 shan end
    EventBus.$on('getDisplayColumns', this.getDisplayColumns);
    //add FNSI-7759 劉全航 start
     if(this.facilityCd !== 'nkknkk'){
        var responseUser = ApiHelper.get(`${uriUser}/${this.facilityCd}`);
        var responsePat = ApiHelper.post(uriPat, [this.facilityCd]);
        Promise.all([responseUser, responsePat]).then((results)=>{
          this.listSelectedFacility.push({
          facilityCd: this.facilityCd,
          userInfo: results[0].data.localDataSource.data,
          patInfo: results[1].data});
          // this.getInfoPatAndUser();
        }).catch((error)=>{
          console.log(error);
        })
      }
      //add FNSI-7759 劉全航 end
    await this.getSearchData();
    await this.getSavedConditionList();
  },

  mounted() {
      /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
      if(this.userId != this.lastUserId){
        /* modify by lijingnan 2022-11-18[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
          this.clearCondition();
          this.setCondition(this.searchCondition)
        /* modify by lijingnan 2022-11-18[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
       }
      /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
  },

  beforeDestroy() {
    this.setLastUserId(this.userId);
    this.setCondition(this.searchCondition);
    this.clearCondition();
    EventBus.$off('getDisplayColumns', this.getDisplayColumns);
    this.setQueryParameters({});

    Object.assign(this.$data, this.$options.data.call(this))
  },
  methods: {
    ...mapActions("view-log", [
      "setSearchRequest",
      "setCondition",
      "setDefaultCondition",
      "setSelectedSavedCondition",
      "setSelectedItemList",
      "setSelectedItem",
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
    ...mapActions("user",["setLastUserId"]),
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    popoverPreShowOther,
    popoverPostShowOther,
    popoverPosthideOther,

    // 吹き出し表示時に現在の値を退避する
    getCurrentValue() {
      if (this.isMasterUser) {
        this.tmpListSelectedFacility = Object.assign([], this.listSelectedFacility);
      }
    },
    restorePrevValue() {
      this.$nextTick(() => {
        if (this.pressedOkFlg) {
          // OKボタン押下時は処理を行わない
          this.pressedOkFlg = false;
          return;
        }
        this.searchCondition = Object.assign({}, this.getLastCondition);
        if (this.isMasterUser) {
          this.listSelectedFacility = Object.assign([], this.tmpListSelectedFacility);
          this.getInfoPatAndUser();
        }
      });
    },
// add 日付check 陳 start
    noticeStartDateChange() {
      let startDateDom = document.getElementById("startDate");
      if (this.searchCondition.noticeStartDate === "") {
        this.showErrorStartDate = startDateDom.validationMessage !== "";
      } else {
        this.showErrorStartDate = false;
      }
      // del 9826 ログ参照の期間指定の終了日が開始日と連動する 関 start
      // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen start
      // mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 start
      // if (!this.StartDataChangeFlg){
      // if (!this.startDataChangeFlg){
      // mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 end
      //   this.onChangeEndDate();
      //  }
      // this.startDataChangeFlg = true;
      // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen end
      // del 9826 ログ参照の期間指定の終了日が開始日と連動する 関 end
    },

    noticeStartTimeChange() {
      // #10044 TypeError: Cannot read properties of undefined (reading 'validationMessage') linjunfeng start
      // let startTimeDom = document.getElementById("startTime").children[0];
      let startTimeDom = document.getElementById("startTime");
      // #10044 TypeError: Cannot read properties of undefined (reading 'validationMessage') linjunfeng end
      if (this.searchCondition.noticeStartTime === "") {
        this.showErrorStartTime = startTimeDom.validationMessage !== "";
      } else {
        this.showErrorStartTime = false;
      }
    },

    noticeEndDateChange() {
      let endDateDom = document.getElementById("endDate");
      if (this.searchCondition.noticeEndDate === "") {
        this.showErrorEndDate = endDateDom.validationMessage !== "";
      } else {
        this.showErrorEndDate = false;
      }
      // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen start
      // del 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 start
      // this.onChangeStartDate();
      // del 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 end
      // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen end
    },

    noticeEndTimeChange() {
      // #10044 TypeError: Cannot read properties of undefined (reading 'validationMessage') linjunfeng start
      // let endTimeDom = document.getElementById("endTime").children[0];
      let endTimeDom = document.getElementById("endTime");
      // #10044 TypeError: Cannot read properties of undefined (reading 'validationMessage') linjunfeng end
      if (this.searchCondition.noticeEndTime === "") {
        this.showErrorEndTime = endTimeDom.validationMessage !== "";
      } else {
        this.showErrorEndTime = false;
      }
    },
// add 日付check 陳 end

    async getSavedConditionList() {
      sendRequestGetSearchCondition(this.loggedUserId).then(response => {
        if (response.status === 200) {
          this.savedConditionList = response.data.toString() === "" ? [] : response.data;
          // APIはストアより遅いため、selectedSavedConditionの値を設定するには遅延が必要です。
          setTimeout(() => {
            this.selectedSavedCondition = this.getSelectedSavedCondition;
          }, 1000);
        }
        if (this.getLastCondition) {
          this.searchCondition = Object.assign({}, this.getLastCondition);
        } else {
          this.clearCondition();
        }
        this.fillUpDataSearchCondition("created");
      });
    },

    clearCondition() {
      // 検索条件クリア
      this.setDefaultCondition(Object.assign({}, this.defaultCondition()));
      this.searchCondition = Object.assign({}, this.defaultCondition());
      this.onChangeStartDate();
      // add 障害票一覧_ログ参照 修正 chen start
      if (this.isMasterUser) {
        this.listSelectedFacility.length = 0;
        this.userInfo.length = 0;
        this.patInfo.length = 0;
      }
      // add 障害票一覧_ログ参照 修正 chen end
    },

    defaultCondition() {
      let ret = {
        noticeStartDate: moment().format("YYYY-MM-DD"),
        noticeStartTime: moment().startOf('day').format("HH:mm"),
        noticeEndDate: moment().format("YYYY-MM-DD"),
        noticeEndTime: moment().format("HH:mm"),
        duration: 0,
        facilityCd: [],
        moduleName: [],
        logClass: [],
        logType: [],
        userId: [],
        patId: [],
        keySearch: "",
        serviceName: [],
        typeSearch: 4,
      };
      if (this.isMasterUser) {
        ret.logClass = [appPropertiesLogging, eventPropertiesLogging]
        ret.logType = ["error", "warning", "info"];
      } else {
        ret.logClass = [eventPropertiesLogging]
        ret.logType = ["error", "warning", "info"];
      }
      return ret;
    },

    onSelectCondition(e) {
      if (e.dataItem.idFilter > -1) {
        this.searchCondition = Object.assign(
          {},
          this.savedConditionList.find(saved => saved.idFilter === e.dataItem.idFilter).condition
        );
      }
    },

    /**
     * @description 作成、変更、削除の両方に使用
     */
    async saveSearchCondition() {
      this.conditionName = (this.$refs.dropdown.kendoWidget().filterInput)[0].value.trim();
      if (this.dropdownOpenFlag && this.conditionName !== "") { // 挿入ケース
        if (this.savedConditionList.length < 10) { // 挿入を許可
          const largestId = this.savedConditionList.length > 0
            ? this.savedConditionList[this.savedConditionList.length - 1].idFilter
            : 0;
          const savedCondition = {
            idFilter: largestId + 1,
            nameFilter: this.conditionName,
            condition: Object.assign({}, this.searchCondition)
          };
          this.savedConditionList.push(savedCondition);
          this.selectedSavedCondition = savedCondition.idFilter.toString();
          this.saveToDB("insert");
        } else { // 最大レコードは10です
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "検索条件",
            // message: "検索条件は10行までです。更新に失敗しました。"
            title: DIALOG_MESSAGES['00200027'].title,
            message: messageFormat(DIALOG_MESSAGES['00200027'].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      } else if (this.selectedSavedCondition) { // アップデートケース
        const index = this.savedConditionList.findIndex(saved => saved.idFilter.toString() === this.selectedSavedCondition);
        if (index != -1) {
          this.savedConditionList[index].condition = this.searchCondition;
          this.saveToDB("update");
        }
      }
    },

    /**
     * @description 検索条件を削除
     */
    async removeSearchCondition() {
      const that = this;
      this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "",
        title: DIALOG_MESSAGES[13000043].title,
        // message: "ログファイルをダウンロードします。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000043].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            let index = that.savedConditionList.findIndex(c => c.idFilter.toString() === this.selectedSavedCondition.toString());
            this.savedConditionList.splice(index, 1);
            this.clearCondition();
            this.saveToDB("delete");
            if (this.getSelectedSavedCondition === this.selectedSavedCondition.toString()) {
              this.setSelectedSavedCondition(null);
            }
          }
        }
      });
    },

    /**
     * @description リスト検索条件をデータベースに保存する
     * @param { String } リクエストの種類
     */
    async saveToDB(requestType) {
      const params = {
        userId: this.loggedUserId,
        conditionList: this.savedConditionList
      };
      // add 障害票一覧_ログNo.1 周 start
      sendRequestUpdateCondition(params).then(() => {
       this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "検索条件",
              // message: "更新に完了しました。"
              title: DIALOG_MESSAGES['00100008'].title,
              message: messageFormat(DIALOG_MESSAGES['00100008'].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
      }
      ).catch(() => {
      // add 障害票一覧_ログNo.1 周 end
        switch (requestType) {
          case "insert":
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('ViewLogHeader.vue', 'saveToDB', '登録に失敗しました');
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "検索条件",
              // message: "登録に失敗しました。"
              title: DIALOG_MESSAGES['00200028'].title,
              message: messageFormat(DIALOG_MESSAGES['00200028'].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return;
          case "update":
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('ViewLogHeader.vue', 'saveToDB', '更新に失敗しました');
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "検索条件",
              // message: "更新に失敗しました"
              title: DIALOG_MESSAGES['00200029'].title,
              message: messageFormat(DIALOG_MESSAGES['00200029'].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return;
          default:
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('ViewLogHeader.vue', 'saveToDB', '更新に失敗しました');
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "検索条件",
              // message: "更新に失敗しました"
              title: DIALOG_MESSAGES['00200029'].title,
              message: messageFormat(DIALOG_MESSAGES['00200029'].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return;
        }
      });
      // del 障害票一覧_ログNo.1 周 start
      //this.$ons.notification.alert({
                 //title: "検索条件",
                 //message: "更新に完了しました。"
                 //});
       // del 障害票一覧_ログNo.1 周 end
    },

    /**
     * @description 検索条件ポップアップを表示
     */
    async showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
      /* add by zhaohan 2022-11-11 [6513] 引き継いだ抽出条件での利用者選択・患者選択で内容が表示されない。 --start */
      if (this.searchCondition.facilityCd.length > 0) {
        this.listSelectedFacility.length = 0;
        for (const facilityCd of this.searchCondition.facilityCd) {
          const responseUser = await ApiHelper.get(`${uriUser}/${facilityCd}`);
          const responsePat = await ApiHelper.post(uriPat, [facilityCd]);

          this.listSelectedFacility.push({
            facilityCd: facilityCd,
            userInfo: responseUser.data.localDataSource.data,
            patInfo: responsePat.data
          });
          this.getInfoPatAndUser();
        }
      }
      /* add by zhaohan 2022-11-11 [6513] 引き継いだ抽出条件での利用者選択・患者選択で内容が表示されない。 --end */
    },

    /**
     * @description 検索条件をクリア
     */
    dialogClear() {
      this.clearCondition();
      this.popoverVisible = true;
    },

    /**
     * @description 検索ログの参照をリクエストする
     */
    // mod FNSI-NO578日機装ユーザーでログ検索が実行されない。(施設ユーザでは検索可能) 張岩 start
    // dialogOk() {
    //   if (this.isMasterUser && this.searchCondition.facilityCd.length === 0) {
    //     this.searchCondition.facilityCd = this.facilityInfo;
    //   } else {
    //     this.setCondition(this.searchCondition);
    //     this.setSelectedSavedCondition(this.selectedSavedCondition);
    //     this.setSearchRequest();
    //     this.fillUpDataSearchCondition("confirm");
    //     this.popoverVisible = false;
    //   }
    // },
        dialogOk() {
          this.pressedOkFlg = true;
      /* del 検索体験の最適化 周炜博 start
        if (this.isMasterUser && this.searchCondition.facilityCd.length === 0) {
        this.searchCondition.facilityCd = this.facilityInfo;
         }
          del 検索体験の最適化 周炜博 end  */
        if(this.isMasterUser){
        this.setCondition(this.searchCondition);
        this.setSearchRequest();
        this.fillUpDataSearchCondition("confirm");
        this.popoverVisible = false;
      } else {
        //mod  6518 2023-03-10 抽出条件に施設選択の情報が表示される 張 start
        // this.searchCondition.facilityCd = [{facilityCd:this.getStateUserAccountInfo.facilityCd}]
        this.searchCondition.facilityCd = [this.getStateUserAccountInfo.facilityCd]
        //mod 6518 2023-03-10 抽出条件に施設選択の情報が表示される 張 end
        this.setCondition(this.searchCondition);
        this.setSearchRequest();
        this.fillUpDataSearchCondition("confirm");
        this.popoverVisible = false;
      }
    },
    // mod FNSI-NO578日機装ユーザーでログ検索が実行されない。(施設ユーザでは検索可能) 張岩 end

    /**
     * @description 共通検索エリア部品に表示するデータのリストを作成
     */
    setConditionList() {
      let condList = [];
      const condObj = this.dataSearchCondition;
      // 表示期間
      if (condObj.dateTime) {
        condList.push({ name:"表示期間", text:condObj.dateTime.replace(/-/g, "/") });
      }
      // 施設選択
      // mod  FNSI-NO 7326 ログ参照画面で他施設の内容が表示される  関 start
      // if (condObj.facilityCd.length > 0) {
      //   let strFacility = "";
      //   condObj.facilityCd.forEach(cd => {
      //     strFacility = strFacility + this.getFacilityName(cd) + "、";
      //   });
      //   condList.push({ name:"施設選択", text:strFacility.slice(0, -1) });
      // }
      if (condObj.facilityCd.length > 0 && this.isMasterUser) {
        let strFacility = "";
        condObj.facilityCd.forEach(cd => {
          strFacility = strFacility + this.getFacilityName(cd) + "、";
        });
        condList.push({ name:"施設選択", text:strFacility.slice(0, -1) });
      }
      // mod  FNSI-NO 7326 ログ参照画面で他施設の内容が表示される  関 start
      // 利用者
      if (condObj.user.length > 0) {
        let strUser = "";
        condObj.user.forEach(user => {
          strUser = strUser + user + "、";
        });
        condList.push({ name:"利用者", text:strUser.slice(0, -1) });
      }
      // 患者
      if (condObj.patient.length > 0) {
        let strPat = "";
        condObj.patient.forEach(pat => {
          strPat = strPat + pat + "、";
        });
        condList.push({ name:"患者", text:strPat.slice(0, -1) });
      }
      // フリーワード
      if (condObj.freeWord) {
        condList.push({ name:"フリーワード", text:condObj.freeWord });
      }
      // 機能名
      if (condObj.serviceName.length > 0) {
        let strService = "";
        condObj.serviceName.forEach(service => {
          strService = strService + service + "、";
        });
        condList.push({ name:"機能名", text:strService.slice(0, -1) });
      }
      this.conditionList = condList;
    },

    /**
     * @description リスト機能の取得、患者のリスト、ユーザーのリスト
     */
    async getSearchData() {
      const responseFacility = await ApiHelper.get(uriFunctionFacility);
      // 施設選択
      const facilityInfo = responseFacility.data;
      this.facilityInfo = facilityInfo.map(facility => {
        return {
          facilityCd: facility.facilityCd,
          facilityName: `${facility.facilityCd}_${facility.facilityName}`
        };
      });
      this.initInfoPatAndUser();

      //機能名
      const sysAllFunction = await getSysAllFunction(this.facilityCd);
      this.serviceInfo = sysAllFunction.data.filter(func => !func.adv);

      // モジュール名
      const listModule = await getListModule();
      this.moduleInfo = listModule.data;
    },

    /**
     * @description [サービス名]がサービスの場合は[サービスログ]を返し、そうでない場合は[イベントログ]を返します
     * @param { String }
     * @return { String }
     */
    logClassText(value) {
      return value === appPropertiesLogging ? "サービスログ" : "イベントログ";
    },

    /**
     * @description リストを文字列に変換します
     * @param { Array }
     * @returns { String }
     */
    logTypeText(value) {
      return value.toUpperCase();
    },

    componentKey(str) {
      return `${moment().format("YYYYMMDDHHmmssSSS")}${str}`;
    },

    async listSelectItem(refName) {
      this.refName = refName;
      this.selectorTarget = this.$refs[`${refName}`]
      this.isItemSelectorVisible = true;
      this.itemSelectorData = this.createItemSelectorData();
    },

    createItemSelectorData() {
      const title = "";
      const class1 = null;
      const class2 = null;

      let defaultSelection = [];
      let itemList = [];
      switch (this.refName) {
        case "userSelector":
            defaultSelection = _.isEmpty(this.searchCondition.userId)
            ? []
            : this.searchCondition.userId.map(item => item.cd);
            itemList = createItemListData(this.userInfo, "userId", "userName");
          break;
        case "patientSelector":
            defaultSelection = _.isEmpty(this.searchCondition.patId)
            ? []
            : this.searchCondition.patId.map(item => item.cd);
            itemList = createItemListData(this.patInfo, "pat_id", "pat_first_name", "", "", null, "pat_last_name");
          break;
        case "serviceSelector":
          defaultSelection = _.isEmpty(this.searchCondition.serviceName)
            ? []
            : this.searchCondition.serviceName.map(item => item.cd);
            itemList = createItemListData(this.serviceInfo, "functionCd", "functionName");
          break;
        case "itemSelector":
          // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong start
          if(this.getSelectedItem){
            this.displayItems = this.getSelectedItemList
          }
          // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong end
          defaultSelection = _.isEmpty(this.displayItems)
            ? []
            : this.displayItems.map(item => item.cd);
            itemList = this.columns;
          break;
      }

      return { title, itemList, class1, class2, defaultSelection };
    },

    commitItemListSelect(selectedList) {
      switch (this.refName) {
        case "userSelector":
          this.searchCondition.userId = selectedList;
          break;
        case "patientSelector":
          this.searchCondition.patId = selectedList;
          break;
        case "serviceSelector":
          this.searchCondition.serviceName = selectedList;
          break;
        case "itemSelector": {
          this.displayItems = this.columns
            .filter(item => selectedList.find(i => i.cd === item.cd))
            .sort((a, b) => {
            return selectedList.findIndex(i => i.cd === a.cd) - selectedList.findIndex(i => i.cd === b.cd);
          });
          const unselectColumn = this.columns.filter(i => !this.displayItems.find(d => d.cd === i.cd));
          this.columns = [...this.displayItems, ...unselectColumn];
          // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong start
          this.setSelectedItemList(this.displayItems)
          this.setSelectedItem(true)
          // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong end
          EventBus.$emit('selectDisplayColumns', {
            displayItems: this.displayItems,
            columns: this.columns
          });
          break;
        }
      }
    },

    onChangeStartDate() {
      // mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 start
      // if (!this.searchCondition.noticeEndDate) {
      //   this.searchCondition.noticeEndDate = moment().format("YYYY-MM-DD");
      // }
      // this.searchCondition.noticeStartDate = moment(this.searchCondition.noticeEndDate).subtract(this.searchCondition.duration, 'day').format("YYYY-MM-DD");
      if (this.changeStartDateFlg) {
      if (!this.searchCondition.noticeEndDate) {
        this.searchCondition.noticeEndDate = moment().format("YYYY-MM-DD");
      }
      this.searchCondition.noticeStartDate = moment(this.searchCondition.noticeEndDate).subtract(this.searchCondition.duration, 'day').format("YYYY-MM-DD");
        this.changeStartDateFlg = false;
      }
      // mod 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 end
    },
    // add 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 start
    changeStartDate() {
      this.changeStartDateFlg = true;
    },
    // add 9118 【デグレ】ログ参照の期間指定の開始日と終了日が連動する 関 end
    // del 9826 ログ参照の期間指定の終了日が開始日と連動する 関 start
    // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen start
    // onChangeEndDate() {
    //   this.startDataChangeFlg = false;
    //   if (!this.searchCondition.noticeStartDate) {
    //     this.searchCondition.noticeStartDate = moment().format("YYYY-MM-DD");
    //   }
    //   this.searchCondition.noticeEndDate = moment(this.searchCondition.noticeStartDate).subtract(this.searchCondition.duration * -1, 'day').format("YYYY-MM-DD");
    // },
    // add 表示期間の終了日変更の場合、開始日表示不正を修正する。 dengshen end
    // del 9826 ログ参照の期間指定の終了日が開始日と連動する 関 end

    selectedDisplayText(array) {
      if (array && array.length > 0) {
        return array.map(item => {
          return item.name
        }).join();
      }
    },

    // setNoticeValue() {
    //   if (this.searchCondition.noticeEndDate === "") {
    //     return;
    //   }
    //   // 検証日
    //   if (this.searchCondition.noticeStartDate > this.searchCondition.noticeEndDate) {
    //     this.searchCondition.noticeStartDate = this.searchCondition.noticeEndDate;
    //   }
    //   // 検証時間
    //   if (
    //     this.searchCondition.noticeStartDate === this.searchCondition.noticeEndDate &&
    //     this.searchCondition.noticeStartTime > this.searchCondition.noticeEndTime
    //   ) {
    //     this.searchCondition.noticeStartTime = this.searchCondition.noticeEndTime;
    //   }
    // },

    onOpenDropdown() {
      this.dropdownOpenFlag = true;
    },

    onCloseDropdown() {
      // ユーザーが[作成]ボタンをクリックする前にドロップダウンが閉じられるため、保持dropdownOpenFlagのタイムアウトはtrueです。
      // add 画面パフォーマンス対応 chen start
      this.$nextTick(async () => {
      // setTimeout(() => {
        this.dropdownOpenFlag = false;
        if (this.selectedSavedCondition) {
          this.$refs.dropdown.kendoWidget().value(this.selectedSavedCondition);
        }
      // }, 500);
      });
      // add 画面パフォーマンス対応 chen end
    },

    fillUpDataSearchCondition(paramAction) {
      let conditions = null;
      if (paramAction === "created") {
        conditions = this.searchCondition;
        // 画面遷移パラメータ取得
        const queryParameters = this.getQueryParameters();
        if (queryParameters.DATE) {
          conditions.noticeStartDate = queryParameters.DATE;
          conditions.noticeEndDate = queryParameters.DATE;
          conditions.noticeStartTime = "00:00";
          conditions.noticeEndTime = "23:59";
        }
        this.setQueryParameters({});
        // 検索条件をstoreに保存する
        this.setCondition(conditions);
      }
      if (paramAction === "confirm") {
        conditions = this.searchCondition;
      }
      if (conditions) {
        const durationCondition = this.durationList.filter(itemDuration => itemDuration.cd === conditions.duration);
        const typeSearchCondition = this.typeSearchList.filter(itemType => itemType.cd === conditions.typeSearch);

        this.dataSearchCondition.dateTime =
          durationCondition.length > 0 &&
          conditions.noticeStartDate &&
          conditions.noticeEndDate
            ? `${conditions.noticeStartDate} 〜 ${conditions.noticeEndDate} - ${durationCondition[0].name}`
            : null;
        this.dataSearchCondition.facilityCd = conditions.facilityCd;
        this.dataSearchCondition.logClass = conditions.logClass.map(itemLogClass => itemLogClass === "1" ? "サービスログ" : "イベントログ");
        this.dataSearchCondition.logType = conditions.logType;
        this.dataSearchCondition.user = conditions.userId.map(itemUser => itemUser.name);
        this.dataSearchCondition.patient = conditions.patId.map(itemPatient => itemPatient.name);
        this.dataSearchCondition.freeWord = conditions.keySearch !== "" && typeSearchCondition.length > 0
          ? `${conditions.keySearch} - ${typeSearchCondition[0].name}`
          : null;
        this.dataSearchCondition.serviceName = conditions.serviceName.map(itemService => itemService.name);
        this.dataSearchCondition.moduleName = conditions.moduleName;
      }
      this.setConditionList();
    },
    onListSelectItem() {
      EventBus.$emit('selectListItem')
    },
    onClickDownload() {
      EventBus.$emit('download')
    },
    changeViewDetail() {
      EventBus.$emit('changeViewDetail')
    },
    onClickMultiDownload(refName) {
      this.downloadTarget = this.$refs[`${refName}`];
      this.popoverDownloadVisible = true;
      this.getDownloadLog();
    },
    /**
     * @description 表示項目設定リストセレクターを作成する
     * @returns 項目設定リストを表示する
     */
    listSelectItemPopup() {
      this.isItemSelectorPopupVisible = true;
      this.itemSelectorData = this.createItemSelectorData();
    },
    /**
     * @description リスト選択表示起点
     */
    selectorTargetPopup(refName) {
      return this.$refs[`${refName}`];
    },
    getDisplayColumns({displayItems, columns}) {
      this.displayItems = displayItems;
      this.columns = columns;
    },
    getInfoPatAndUser() {
      this.userInfo.length = 0;
      this.patInfo.length = 0;
      this.listSelectedFacility.forEach(s => {
        this.userInfo.push(...s.userInfo);
        this.patInfo.push(...s.patInfo);
      });
    },
    async initInfoPatAndUser() {
      const requestUser = [];
      const requestPat = [];
      /* mod 内结 4 NKK会社ログインユーザ以外：検索エリアで本施設の利用者、患者だけ表示するように修正。張岩 start */
      //   this.facilityInfo.forEach(facility => {
      //   requestUser.push(ApiHelper.get(`${uriUser}/${facility.facilityCd}`));
      //   requestPat.push(ApiHelper.post(uriPat, [facility.facilityCd]));
      // });
      if(this.isMasterUser){
      this.facilityInfo.forEach(facility => {
        requestUser.push(ApiHelper.get(`${uriUser}/${facility.facilityCd}`));
        requestPat.push(ApiHelper.post(uriPat, [facility.facilityCd]));
      });
      }else{
        requestUser.push(ApiHelper.get(`${uriUser}/${this.getStateUserAccountInfo.facilityCd}`));
        requestPat.push(ApiHelper.post(uriPat, [this.getStateUserAccountInfo.facilityCd]));
      }
      /* mod 内结 4 NKK会社ログインユーザ以外：検索エリアで本施設の利用者、患者だけ表示するように修正。張岩 end */
      let responseUser = await Promise.all(requestUser).catch(e => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ViewLogHeader.vue', 'initInfoPatAndUser', e);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log(e);
      });
      responseUser = responseUser.map(u => u.data.localDataSource.data);
      let responsePat = await Promise.all(requestPat).catch(
        e => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('ViewLogHeader.vue', 'initInfoPatAndUser', e);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          // console.log(e);
        }
      );
      responsePat = responsePat.map(m => m.data);
      this.patInfo.length = 0;
      this.userInfo.length = 0;
      // mod 障害票一覧_ログ参照 修正 chen start
      let userInfo = []
      let patInfo = []
      responseUser.forEach(u => {
        userInfo.push(...u);
      });
      responsePat.forEach(p => {
        patInfo.push(...p);
      });
      this.userInfoInit = [...userInfo];
      this.patInfoInit = [...patInfo];
      if (!this.isMasterUser) {
        responseUser.forEach(u => {
         this.userInfo.push(...u);
        });
        responsePat.forEach(p => {
         this.patInfo.push(...p);
        });
      }
      //responseUser.forEach(u => {
      //  this.userInfo.push(...u);
      //});
      //responsePat.forEach(p => {
      //  this.patInfo.push(...p);
      //});
      //this.userInfoInit = [...this.userInfo];
      //this.patInfoInit = [...this.patInfo];
      // mod 障害票一覧_ログ参照 修正 chen end
    },
    async onSelectFacility(e) {
      // add 利用者表示不正について、修正する。 dengshen start
      store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
      store.dispatch("loading-screen/setLoadingScreenVisible", true);
      // add 利用者表示不正について、修正する。 dengshen end
      const selectedFacility = this.listSelectedFacility.find(f => f.facilityCd === e.dataItem.facilityCd)
      if (!selectedFacility) {
        const responseUser = await ApiHelper.get(`${uriUser}/${e.dataItem.facilityCd}`);
        const responsePat = await ApiHelper.post(uriPat, [e.dataItem.facilityCd]);
        this.listSelectedFacility.push({
          facilityCd: e.dataItem.facilityCd,
          userInfo: responseUser.data.localDataSource.data,
          patInfo: responsePat.data});
        this.getInfoPatAndUser();
      }
      // add 利用者表示不正について、修正する。 dengshen start
      store.dispatch("loading-screen/setLoadingScreenVisible", false);
      // add 利用者表示不正について、修正する。 dengshen end
    },
    async onDeselectFacility(e) {
      const selectedFacilityIndex = this.listSelectedFacility.findIndex(f => f.facilityCd === e.dataItem.facilityCd)
      if (selectedFacilityIndex > -1) {
        this.listSelectedFacility.splice(selectedFacilityIndex, 1);
        this.getInfoPatAndUser();

        /* add by zhaohan 2022-11-11 [6513] 引き継いだ抽出条件での利用者選択・患者選択で内容が表示されない。 --start */
        if (this.searchCondition.userId.length > 0) {
          let userIdInfo = [];
          for (const userId of this.searchCondition.userId) {
            const selectedUser = this.listSelectedFacility.filter(i => i.userInfo.find(d => d.userId === userId.cd));
            if (selectedUser.length > 0) {
              userIdInfo.push(userId);
            }
          }
          this.searchCondition.userId = [];
          this.searchCondition.userId = [...userIdInfo];
        }

        if (this.searchCondition.patId.length > 0) {
          let patIdInfo = [];
          for (const patId of this.searchCondition.patId) {
            const selectedPat = this.listSelectedFacility.filter(i => i.patInfo.find(d => d.pat_id === patId.cd));
            if (selectedPat.length > 0) {
              patIdInfo.push(patId);
            }
          }
          this.searchCondition.patId = [];
          this.searchCondition.patId = [...patIdInfo];
        }
        /* add by zhaohan 2022-11-11 [6513] 引き継いだ抽出条件での利用者選択・患者選択で内容が表示されない。 --end */
      }
      if (this.listSelectedFacility.length === 0) {
        // mod 障害票一覧_ログ参照 修正 chen start
        this.patInfo.length = 0;
        this.userInfo.length = 0;
        // this.userInfo = [...this.userInfoInit];
        // this.patInfo = [...this.patInfoInit];
        // mod 障害票一覧_ログ参照 修正 chen end
        /* add by zhaohan 2022-11-11 [6513] 引き継いだ抽出条件での利用者選択・患者選択で内容が表示されない。 --start */
        this.searchCondition.userId = [];
        this.searchCondition.patId = [];
        /* add by zhaohan 2022-11-11 [6513] 引き継いだ抽出条件での利用者選択・患者選択で内容が表示されない。 --end */
      }
    },
    async getDownloadLog(path = '') {
      const params = { path };
      const requestData = await sendRequestGetDownloadPath(params) || {};
      this.downloadLogPath = requestData ? requestData.data : {};
      // add フォルダ名が順不同 5927 関 start
      this.downloadLogPathTemp.lstFile = [...this.downloadLogPath.lstFile.sort((a, b) => {
        if (a.name > b.name) {
          // mod FNSI5927-フォルダ名が順不同 周 start
          //return  1;
          /** modify by wangying 2022-11-19[6888]ログ参照の挙動がおかしい[現象１]の修正 -- start */
          // return  -1;
          return this.isDownLogAcs ? 1 : -1;
          /** modify by wangying 2022-11-19[6888]ログ参照の挙動がおかしい[現象１]の修正 -- end */
          // mod FNSI5927-フォルダ名が順不同 周 end
        }
        if (a.name < b.name) {
          // mod FNSI5927-フォルダ名が順不同 周 start
          //return -1;
          /** modify by wangying 2022-11-19[6888]ログ参照の挙動がおかしい[現象１]の修正 -- start */
          // return 1;
          return this.isDownLogAcs ? -1 : 1;
          /** modify by wangying 2022-11-19[6888]ログ参照の挙動がおかしい[現象１]の修正 -- end */
          // mod FNSI5927-フォルダ名が順不同 周 end
        }
        return  0;
      })];
    //  add フォルダ名が順不同 5927 関 end
      this.currentLogPage = 0;
      this.pagingLogFile()
    },
    openLogFolder(logItem, currentPath, root) {
      if (!logItem.folder) {
        return;
      }
      const separater = currentPath === root ? '' : '/';
      const itemPath = currentPath + separater + logItem.name;
      this.getDownloadLog(itemPath);
    },
    openLogFolderByPath( currentPath, index) {
      const path = this.downloadLogPath.currentPath.split('/').slice(0, index + 1).join('/');
      // console.log(path);
      //const separater = currentPath === root ? '' : '\\';
      //const itemPath = currentPath + separater + logItem.name;
      this.getDownloadLog(path);
    },
    backLogFolder(currentPath, root) {
      if (currentPath === root) {
        return;
      }
      let pathSplited = currentPath.split('/');
      pathSplited.pop();
      if (pathSplited.length === 1) {
        pathSplited = '';
      } else {
        pathSplited = pathSplited.join('/');
      }
      this.getDownloadLog(pathSplited);
    },
    async downloadLogFile(path) {
     const params = { path };
      // mod 環境によって、パスを修正 劉 start
      // const splitedPath = path.split('\\');
      const splitedPath = path.split('/');
      // mod 環境によって、パスを修正 劉 end
      const requestData = await sendRequestGetDownloadLog(params) || {};
      if (requestData.data) {
        this.downloadBase64File(requestData.data, splitedPath[splitedPath.length - 1].split('.')[0] + '.zip');
      }
    },
    onDownloadLog(currentPath, logItem) {
      // mod 環境によって、パスを修正 劉 start
      // const itemPath = currentPath + '\\' + logItem.name;
      const itemPath = currentPath + '/' + logItem.name;
      // mod 環境によって、パスを修正 劉 end
      this.downloadLogFile(itemPath);
    },
    downloadBase64File(contentBase64, fileName) {
      const linkSource = window.URL.createObjectURL(new Blob([contentBase64]));
      const downloadLink = document.createElement('a');
      document.body.appendChild(downloadLink);

      downloadLink.href = linkSource;
      downloadLink.target = '_self';
      downloadLink.download = fileName;
      downloadLink.click();
    },
    sortDownloadLog() {
      const listItem = [...this.downloadLogPathTemp.lstFile];
      this.isDownLogAcs = !this.isDownLogAcs;
      this.downloadLogPath.lstFile = [...listItem.sort((a, b) => {
        if (a.name > b.name) {
          return this.isDownLogAcs ? 1 : -1;
        }
        if (a.name < b.name) {
          return this.isDownLogAcs ? -1 : 1;
        }
        return  0;
      })];
      this.downloadLogPathTemp.lstFile = [...this.downloadLogPath.lstFile];
      this.pagingLogFile();
    },
    searchLogList() {
      this.downloadLogPath.lstFile = [...this.downloadLogPathTemp.lstFile.filter(file => {
        return file.name.toLowerCase().includes(this.searchDownloadLog.trim().toLowerCase());
      })];
      this.pagingLogFile();
      this.currentLogPage = 0;
    },
    pagingLogFile() {
      if (!this.downloadLogPath.lstFile) {
        this.logItemTotalPage = [];
      }
      this.logItemTotalPage = [...this.downloadLogPath.lstFile.reduce((resultArray, item, index) => {
                                    const chunkIndex = Math.floor(index/ITEM_PER_PAGE);

                                    if(!resultArray[chunkIndex]) {
                                      resultArray[chunkIndex] = [];
                                    }

                                    resultArray[chunkIndex].push(item);

                                    return resultArray;
                                  }, [])]
    },
    isPageShowing(index) {
      let isShow = true;
      const IN_RANGE = index < (this.currentLogPage + (FIRST_PAGE_NUMBER + 1) ) && index > (this.currentLogPage - (FIRST_PAGE_NUMBER + 1) );
      if (!IN_RANGE && index != 0 && index != (this.logItemTotalPage.length - 1)) {
        isShow = false;
      }
      return isShow;
    },
    getPagingContent(index) {
      const IN_RANGE = index < (this.currentLogPage + FIRST_PAGE_NUMBER) && index > (this.currentLogPage - FIRST_PAGE_NUMBER);
      let pagingContent = index + 1;
      if (!IN_RANGE && index != 0 && index != (this.logItemTotalPage.length - 1) ) {
        pagingContent = '...';
      }
      return pagingContent;
    },
    navigatePaging(isPrev) {
      if (isPrev && this.currentLogPage > 0) {
        this.currentLogPage--;
      } else if (!isPrev && ( this.currentLogPage < this.logItemTotalPage.length -1)) {
        this.currentLogPage++;
      }
    },
    onHideDownloadLog() {
      this.currentLogPage = 0;
    },
    getFacilityName(facility) {
      const facilityCd = facility.hasOwnProperty('facilityCd') ? facility.facilityCd: facility;
      const foundFacility = this.facilityInfo.find(facility => facility.facilityCd === facilityCd);
      return foundFacility ? foundFacility.facilityName : '';
    }
  }
};
</script>

<style scoped>
.function-section {
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
  flex-wrap: wrap;
  overflow: auto;
}

.function-item {
  margin-left: 10px;
  font-size: 1.5em;
  /* add 内结 19 详细表示黑夜模式颜色不正确。張岩 start */
  color: var(--ntss-list-body-color);
  /* add 内结 19 详细表示黑夜模式颜色不正确。張岩 end */
}

.leftmost-header {
  margin-left: 2em;
  /* フロートメニュー用のマージン */
  width: calc(100% - 90px);
  flex-wrap: nowrap;
}

.condition-search-col {
  flex: 0 0 55%;
}

.popover-area >>> .popover-mask {
  z-index: 100;
}

.popover-area >>> .popover {
  z-index: 200;
  width: 620px !important;
}

.pop-area {
  margin: 10px;
}

.pop-title {
  flex: 0 0 25%;
  /* add 内结 17 黑夜模式检索项目名称颜色不应该是黑色。張岩 start */
  color: var(--ntss-list-body-color);
  /* add 内结 17 黑夜模式检索项目名称颜色不应该是黑色。張岩 end */
}

.clear-button {
  float: left;
}

.ok-button {
  float: right;
}

.condition-button-area {
  height: 30px;
  margin: 10px;
  text-align: center;
}

.radioButtons {
  display: flex;
  align-items: center;
  font-size: 1em;
}

.radioButtons label {
  margin-right: 1em;
}

.fit-button {
  width: fit-content;
  padding-top: 0;
  padding-bottom: 0;
}

ons-input {
  width: fit-content;
}

ons-input .text-input {
  font-size: unset;
}

.custom-input-disabled {
  color: black;
  cursor: not-allowed;
  border-radius: 3px;
  border: 0;
}

.input-area::-webkit-calendar-picker-indicator {
  display: none;
}

.input-area>>>.text-input {
  padding: 1px 2px;
}

.center-row {
  display: flex;
  align-items: center;
}

.download-wrapper {
  padding: 2px;
}
.download-input {
    width: 100%;
    border: 1px solid black;
    height: 20px;
    margin: 2px;
    padding-left: 1.5em;
    height: 1.6em;
}
.download-nav {
  background-color: #333333;
  color: white;
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  margin: 2px 0;
}
.download-path {
  width: 90%;
  margin-right: 10px;
  overflow: hidden;
  text-overflow: ellipsis;
}
.download-item-name {
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
}
.download-item-icon {
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  max-width: 30px;
}
.download-all-button {
  float: right;
}
.download-list {
  max-height: 300px;
  overflow-y: auto;
}
.back-folder-icon {
  transform: scaleX(-1);
  margin: 0 10px;
}
.download-log-popover >>> .popover-mask--top {
  z-index: 9999;
}
.download-log-popover >>> .popover--top {
  width: auto;
}
.download-log-popover >>> .popover__content {
  width: 30em;
}

.vons-popover >>> .popover--right {
  z-index: 30000;
}
.vons-popover >>> .popover--right__content {
  width: 400px;
}

.download-field {
  position: relative;
}
.download-field >>> ons-icon {
  position: absolute;
  top: 0.3em;
  left: 0.4em;
}
.log-page-show {
  visibility: hidden !important;
}
.pop-area >>> .k-multiselect-wrap {
  max-height: 100px;
  overflow-y: auto;
}
.download-sort {
  max-width: 30px;
}
.download-sort >>> ons-icon{
  font-size: 25px !important;
  color: #eee !important;
}
.current-page {
  font-weight: bold;
  background-color: black;
  color: white;
}
.download-paging {
  display: flex;
}
.download-paging >>> ons-icon {
  border: 1px solid black;
  box-sizing: border-box;
  width: 30px;
  text-align: center;
  border-radius: 2px;
}
.download-paging >>> ons-icon:hover {
  background-color: #eee;
  color: black;
}
.navigation-bar {
  width: fit-content;
  padding: 0 2px;
}
.navigation-bar >>> span {
  border: 1px solid black;
  box-sizing: border-box;
  width: 30px !important;
  text-align: center;
  display: inline-block;
  margin: 0 2px;
  border-radius: 2px;
}
.navigation-bar >>> span:hover{
  background-color: #eee;
  color: black;
}
.disable-nagivation {
  pointer-events: none;
  color: #ccc !important;
  border: 1px solid #ccc !important;
}
.download-button-wrapper {
  display: inline-block;
}
.clickable-path {
  text-decoration: underline;
  cursor: pointer;
}
.pointer-cursor {
  cursor: pointer;
}
@media screen and (max-width:480px) {
  .function-item-wrapper {
    margin-bottom: 5px;
  }

  .function-section {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
    flex-wrap: wrap;
    overflow: auto;
  }

  /*add FNSI-改修内容5054 任 start*/
  .popover-style >>> .popover{
    top: 0;
  }
  /*add FNSI-改修内容5054 任 end*/
}
</style>
