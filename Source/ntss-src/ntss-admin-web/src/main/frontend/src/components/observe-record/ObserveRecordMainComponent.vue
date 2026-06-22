/**
 * 観察記録 MainContent
 */
<template>
  <div>
    <div style="display: flex; flex-wrap: nowrap; align-items: center;">
      <div style="width: 100%; height: 4.7em; font-size: 0.667em;">
        <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showPopover($event)' v-if="!isTreatmentRecord"/>
      </div>
      <!-- redmine4783 修正 姜 mod start -->
      <!-- <v-ons-button class="btn3-normal" :disabled="hasTreatmentRecordAuthority" style="width: 6em; min-width: 6em; margin-left: 0.5em; margin-right: 0.5em;" @click="clickAddButton">新規追加</v-ons-button> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
<!--      <v-ons-button class="btn3-normal" :disabled="!hasTreatmentRecordAuthority" style="width: 6em; min-width: 6em; margin-left: 0.5em; margin-right: 0.5em;" @click="clickAddButton">新規登録</v-ons-button>-->
      <v-ons-button class="btn3-normal" :disabled="!getItemAuthorized('PatEvent', 'default_authority') || !isShared" style="width: 6em; min-width: 6em; margin-left: 0.5em; margin-right: 0.5em;" @click="clickAddButton">新規登録</v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- redmine4783 修正 姜 mod end -->
    </div>
    <div id="scrollArea" class="main-content-area" style="-webkit-overflow-scrolling:touch; top: 3.5em;" @scroll="scrollHandler" ref="scrollArea">
      <table class="ntss-list">
        <thead>
          <tr>
            <!-- mod 6685 横展開、タイトルが調整できるようにする 黄 start -->
              <!-- <th
              v-for="column in columns"
              :key="column.key"
              :class="sortedClass(column.key)"
              class="ntss-list-header-th-sticky"
              :style="{ width:column.width + '%' }"
              @click="clickHeader(column.key)"
            >{{ column.colName }}</th> -->
            <!-- mod 6685 横展開、タイトルが調整できるようにする 関 start -->
            <!-- <th
              v-for="column in columns"
              :key="column.key"
              :class="sortedClass(column.key)"
              class="ntss-list-header-th-sticky manual-width"
              :style="{ width:column.width + '%' }"
              @click="clickHeader(column.key)"
            >{{ column.colName }}</th> -->
            <th
              v-for="column in columns"
              :key="column.key"
              :class="sortedClass(column.key)"
              class="ntss-list-header-th-sticky manual-width"
            ><span  @click="clickHeader(column.key)">{{ column.colName }}</span></th>
            <!-- mod 6685 横展開、タイトルが調整できるようにする 関  end -->
            <!-- mod 6685 横展開、タイトルが調整できるようにする 黄 end -->
          </tr>
          <!-- （仮）オーダ番号入力
          <tr>
            <v-ons-col vertical-align='center'>
              <v-ons-input float type='text' v-model="tmpOrdno" @click='onInOrdno'></v-ons-input>
            </v-ons-col>
          </tr>
          -->
        </thead>
        <tbody>
        <tr
          v-for="(observeRecord, observeRecordKey) in convertList(filterObserveRecords(sortedItems))"
          :key="observeRecordKey"
          :class="[
            'ntss-list-body-tr',
            {
              'data-row-stripe': observeRecord.dataRowStripe,
              'table-disabled': !isShared
            }
          ]"
          @click="isShared && editPatObsRec(observeRecord.headerFlag, observeRecord)"
          style="height: 1.1rem;"
        >
          <td
            v-if="observeRecord.headerFlag"
            colspan="5"
            :class="'ntss-list-body-td-header ' + observeRecord.className + ' ntss-list-body-td'"
          >{{ observeRecord.viewRecDate }}</td>
          <td
            v-if="!observeRecord.headerFlag"
            class="ntss-list-body-td"
            :class="columns[0].className"
            style="text-align: center;"
            :style="{ width:columns[0].bodyWidth + 'px'}"
          >{{ observeRecord.viewEventRegTime }}</td>
          <td
            v-if="!observeRecord.headerFlag"
            class="ntss-list-body-td"
            :class="columns[1].className"
            style="text-align: left;"
            :style="{ width:columns[1].bodyWidth + 'px'}"
          >{{ observeRecord.categoly }}</td>
          <!-- mod FNSI-改修内容4388。 fan start -->
          <!-- <td
            v-if="!observeRecord.headerFlag"
            class="ntss-list-body-td"
            :class="columns[2].className"
            style="text-align: left; display: flex; flex-wrap: wrap;"
            :style="{ width:columns[2].bodyWidth + 'px'}"
          >-->
           <!-- mod 6685 横展開、タイトルが調整できるようにする 関 start -->
          <!-- <td
            v-if="!observeRecord.headerFlag"
            class="ntss-list-body-td"
            :class="columns[2].className"
            style="text-align: left; display: flex; flex-wrap: wrap;border:none;"
            :style="{ width:columns[2].bodyWidth + 'px'}"
          > -->
          <td
            v-if="!observeRecord.headerFlag"
            class="ntss-list-body-td"
            :class="columns[2].className"
            style="text-align: left; flex-wrap: wrap;border:none;"
            :style="{ width:columns[2].bodyWidth + 'px'}"
          >
          <!-- mod 6685 横展開、タイトルが調整できるようにする 関  end -->
            <!-- mod FNSI-改修内容4388。 fan end -->
            <span v-for="(message, index) in observeRecord.observeRecordMessage" :key="index" class="ptag-margin-setter">
              <p
                v-if="message.isFormatting === '1'"
                v-safe-html="message.titile + '：' + message.resultValue + '&nbsp;'"
              ></p>
              <p v-else v-safe-html="message.resultValue + '&nbsp;'"></p>
            </span>
          </td>
          <td
            v-if="!observeRecord.headerFlag"
            class="ntss-list-body-td"
            :class="columns[3].className"
            colspan="2"
            style="text-align: left;"
            :style="{ width:columns[3].bodyWidth + 'px'}"
          >
            <span
              style="overflow-y: hidden; display: block; max-height: 4rem;"
            >{{ observeRecord.staff }}</span>
          </td>
        </tr>
        <tr style="height: 1.1rem;"></tr>
        </tbody>
      </table>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet]"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin:5px;">
        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label style="font-size:1.6em;">起票日</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center">
            <div class="flex-align-center">
              <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 start -->
              <!-- <input
                class="observeRecordPopover ntss-input-date ntss-control-size w-100"
                type="date"
                v-model="findCondition.startDateView"
                v-on:blur="popoverBlur('startDate', $event.target.value)"
              /> -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                class="observeRecordPopover ntss-input-date ntss-control-size w-100 start-time"
                type="date"
                max="9999-12-31"
                v-model="findCondition.startDateView"
                @keyup="showStartMsg"
                @blur="getStartDate"
              /> -->
              <date-input
                :classes="'observeRecordPopover ntss-input-date ntss-control-size w-100 start-time'"
                v-model="findCondition.startDateView"
                @handleClearInput="findCondition.startDateView = null"
                style="width:100%"
                @keyup="showStartMsg"
                @blur="getStartDate"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <common-calendar class="start-date-comment" v-model="findCondition.startDateView" />

              <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 end -->
            </div>
            <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 start -->
            <span class="error-message" v-if="showErrorStartDate">
              {{ this.msgDiaLog }}
            </span>
            <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label style="font-size:1.6em;float:right;">～</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center">
            <div class="flex-align-center">
              <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 start -->
              <!-- <input
                class="observeRecordPopover ntss-input-date ntss-control-size w-100"
                type="date"
                v-model="findCondition.endDateView"
                v-on:blur="popoverBlur('endDate' ,$event.target.value)"
              /> -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <date-input
                :classes="'observeRecordPopover ntss-input-date ntss-control-size w-100 end-time'"
                v-model="findCondition.endDateView"
                @handleClearInput="findCondition.endDateView = null"
                style="width:100%"
                @keyup="showEndMsg"
                @blur="getEndDate"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <common-calendar class="end-date-comment" v-model="findCondition.endDateView" />
              <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 end -->
            </div>
            <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 start -->
            <span class="error-message" v-if="showErrorEndDate">
              {{ this.msgDiaLog }}
            </span>
            <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
		  <v-ons-col width="30%" vertical-align="center">
		    <label style="font-size:1.6em;">カテゴリ</label>
		  </v-ons-col>
		  <v-ons-col width='100%' vertical-align='center'>
		    <div class="pat-list flex-1 d-flex">
		      <div class="unselected-pat-list flex-1" ref="scrollDiv">
		        <div class="list-wrapper ntss-pat-event-label">
		          <div
		            v-for="(item, index) in categorySelection"
		            :class="['pat-display', { selected: item.selected }]"
		            :id="`pat-display${index}`"
		            :key="item.code"
		            @click.exact="singleSelect(index)"
		          >
		          {{ `${item.name}` }}
		          </div>
		        </div>
		      </div>
	        </div>
		  </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="50%" vertical-align="center">
            <!-- mod FNSI-権限関連 王 20200927 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <ons-checkbox input-id="print-check1" :disabled="!getItemAuthorized('PatEvent', 'default_authority')" :checked="dispIsDraft" @click="onIsDraftChange($event)"></ons-checkbox>
            <!-- mod FNSI-権限関連 王 20200927 end -->
            <label style="font-size:1.6em;" for="print-check1">自分が新規作成</label>
          </v-ons-col>
          <v-ons-col width="50%" vertical-align="center">
            <!-- mod FNSI-権限関連 王 20200927 start -->
            <ons-checkbox input-id="print-check2" :disabled="!getItemAuthorized('PatEvent', 'default_authority')" :checked="dispIsEdit" @click="onIsEditChange($event)"></ons-checkbox>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!-- mod FNSI-権限関連 王 20200927 end -->
            <label style="font-size:1.6em;" for="print-check2">自分が最終更新</label>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row" style="height:30px;">
          <div style="float:left;">
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <!--mod FNSI-改修内容日付のチェックの追加対応。 付 start-->
            <!-- <v-ons-button class="ok" @click="dialogOk">OK</v-ons-button> -->
            <v-ons-button class="ok btn3-normal" @click="dialogOk" :disabled="showErrorStartDate || showErrorEndDate">OK</v-ons-button>
            <!--mod FNSI-改修内容日付のチェックの追加対応。 付 end-->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import $$ from "@/compat/jquery";
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import NextTransitionMixin from "@/components/NextTransitionMixin";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import {EventBus} from "@/compat/vue/event-bus.js";
  import dayjs from "@/compat/date/dayjs";
  import {getCurrentFunctionCd} from "@/router/routing-helper";
  import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
  import PopoverMixin from "@/components/PopoverMixin";
  // add FNSI-権限関連 王 20200927 start
  import {AUTHORITY_CODES} from "@/constants/userAuthority";
  import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  // add FNSI-権限関連 王 20200927 end
  import commonSearchArea from "@/components/common/CommonSearchArea";
  // add FNSI-改修内容日付のチェックの追加対応。 付 start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  // add FNSI-改修内容日付のチェックの追加対応。 付 end
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
  import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
  //#5590 2023/04/20 ×を常に表示するように修正 張博 start
  import DateInput from "@/components/common/DateInput.vue";
  //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  // add #10359 編集権限の動作不正 start
  import {deepCopy, getAuthorized} from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 end
  import {OBSERVE_RECORD} from "@/constants/defaultSettingConstants";
  import {calcTargetDate} from "@/functions/modals/default-setting/defaultSettingUtils"

  // jQureyを宣言（'$'はvue.jsで使用されているため、'$$'で宣言）

import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getMainContentAreaElement, getScopedElementsByClassName, getScopedDocument, getScopedWindow,
  getScopedJQuery as createScopedJQuery} from "@/functions/common/LayoutMeasureHelper";

  const AnyCategoryCd = "0";
  const AnySubCategoryCd = "0";
  const CategoryCdDelimiter = "-";
  const joinCategoryCd = (subCategoryCd, categoryCd) => `${subCategoryCd}${CategoryCdDelimiter}${categoryCd}`;
  const joinCategoryName = (categoryName, subCategoryName) => `${categoryName} ＞ ${subCategoryName}`;
  const AllCategoryCd = joinCategoryCd(AnySubCategoryCd, AnyCategoryCd);
  const AllCategoryTemplete = {
    code: AllCategoryCd,
    name: "全カテゴリ"
  };

  const toDate = (dateString) => dayjs(dateString).toDate();

export default {
  // add FNSI-権限関連 王 20200927 start
  mixins: [NextTransitionMixin, PopoverMixin ,ComponentGuardMixin],
  // add FNSI-権限関連 王 20200927 end
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      isRedrawing: false,
      authorityCds: [
        AUTHORITY_CODES.PAT_EVENT_PEDIT,  // 治療記録-代行編集
        AUTHORITY_CODES.PAT_EVENT_EDIT    // 治療指示-編集
      ],
      columns: [
        {
          key: "sortKey",
          colName: "起票日時",
          className: "eventRegTimeBody",
          width: 10,
          bodyWidth: ""
        },
        {
          key: "kindInfo",
          colName: "カテゴリ",
          className: "categolyBody",
          width: 10,
          bodyWidth: ""
        },
        {
          key: "observeRecordMessage",
          colName: "内容",
          className: "observeRecordMessageBody",
          width: 67,
          bodyWidth: ""
        },
        {
          key: "staff",
          colName: "起票者",
          className: "staffNameBody",
          width: 17,
          bodyWidth: ""
        }
      ],
      /**
       * 類表示名
       */
      dataTypeName: {
        1: {
          shortName: "他",
          className: "other-row"
        },
        2: {
          shortName: "SOAP",
          className: "soap-row"
        },
        3: {
          shortName: "FDAR",
          className: "fdar-row"
        }
      },
      /**
       * 抽出項目
       */
      findCondition: {
        startDate: "",
        startDateView: "",
        endDate: "",
        endDateView: "",
        obsKindList: []
      },
      /**
       * 抽出条件
       */
      condition: {
        startDate: "",
        startDateView: "",
        endDate: "",
        endDateView: "",
        obsKindList: []
      },
      /**
       * 検索条件
       */
      fetchCondition: {
        startDate: "",
        endDate: ""
      },
      /**
       * ソート条件
       */
      sort: {
        key: "sortKey",
        isAsc: false
      },
      /**
       * 起票者・編集者
       */
      dispIsDraft: false,
      dispIsEdit: false,
      mstObsKind: null,
      tmpOrdno: 0,
      // add FNSI-権限関連 王 20200927 start
      // 治療記録の権限を有無する
      //#10359 del 編集権限の動作不正 2024-06-05 卓 start
      // hasTreatmentRecordAuthority: false,
      //#10359 del 編集権限の動作不正 2024-06-05 卓 end
      // add FNSI-権限関連 王 20200927 end
      //自画面の名称
      selfScreenName: "",
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
      /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
      ,msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      showErrorEndDate: false,
      /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
      offset: 0,  // スクロールした際の追加読込で使用
      total: 0,   // 抽出条件の表示期間に一致するデータ件数
      fromOtherWithParams: false, // 他画面からパラメータ指定での遷移
	  categorySelection: []
    };
  },
  computed: {
    ...mapGetters("app", ["getRefresh"]),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("observe-record/list", [
      // mod FNSI-観察記録を追加 楊 start
      "getStartToEndDate",
      // mod FNSI-観察記録を追加 楊 end
      "getObserveRecords",
      "getReloadSignal",
      "getOrdNo",
      "getObserveRecord",
      //add FNSI redmine4055修正 房 start
      "getConditionList"
      //add FNSI redmine4055修正 房 end
    ]),
    ...mapGetters("pat-event/list", ["getMstCategoryRecords","getMstSubCategoryRecords", "getSystemDefaultConditionDate"]),
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "getDefaultSetting",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode"
    ]),
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    // add FNSI-共有を追加 王 20200921 end
    isShared() {
      return !this.isTreatmentRecord ||
        !this.getSharedFacilityCd ||
        this.facilityCd === this.getSharedFacilityCd;
    },
    subCategoryObserveList() {
      let list = this.getMstSubCategoryRecords;
      if (list) {
        list = list.filter(item => item.useType === 2);
		list = list.filter(obj1 => this.getMstCategoryRecords.some(obj2 => obj1.categoryCd === obj2.categoryCd));
      } else {
        list = [];
      }
      return list;
    },
    sortedItems() {
      const list = this.getObserveRecords.slice();
      // mod FNSI-3792 fu start
      // if (this.sort.key) {
      //   list.sort((a, b) => {
      //     //console.log(a);
      //     a = a[this.sort.key];
      //     b = b[this.sort.key];
      //     //console.log(`a:${a}/b:${b}`);
      //     let sortItem1 = 0;
      //     let sortItem2 = 0;

      //     if (a === b) {
      //       sortItem1 = 0;
      //     } else if (a > b) {
      //       sortItem1 = 1;
      //     } else {
      //       sortItem1 = -1;
      //     }
      //     if (this.sort.isAsc) {
      //       sortItem2 = 1;
      //     } else {
      //       sortItem2 = -1;
      //     }
      //     return sortItem1 * sortItem2;
      //   });
      // }
      if (this.sort.key) {
        list.sort((a, b) => {
          if (a["eventStartTime"] != null && a["eventStartTime"] != "") {
            a = a[this.sort.key].replaceAll("-", "") + a["eventStartTime"].replaceAll(":", "");
          } else {
            a = a[this.sort.key].replaceAll("-", "") + "0000";
          }
          if (b["eventStartTime"] != null && b["eventStartTime"] != "") {
            b = b[this.sort.key].replaceAll("-", "") + b["eventStartTime"].replaceAll(":", "");
          } else {
            b = b[this.sort.key].replaceAll("-", "") + "0000";
          }
          let sortItem1 = 0;
          let sortItem2 = 0;

          if (a === b) {
            sortItem1 = 0;
          } else if (a > b) {
            sortItem1 = 1;
          } else {
            sortItem1 = -1;
          }
          if (this.sort.isAsc) {
            sortItem2 = 1;
          } else {
            sortItem2 = -1;
          }
          return sortItem1 * sortItem2;
        });
      // add FNSI-6764 ljx start
      }else{
        /*
        初期化の際に、ソート順は下記：
        ①起票日時（イベント開始日時）の降順（新しい順）
        ②同じ日付の場合、起票時刻の昇順（早い時刻順）→空白の順
        ③同じ時刻、同じ空白だった場合は登録順（登録時シーケンスの早い順）
        */
        let sortKeyObj = [];
        // 起票日時（イベント開始日時）の降順（新しい順）
        sortKeyObj['eventStartDate'] = "descending";
        // 同じ日付の場合、起票時刻の昇順（早い時刻順）→空白の順
        sortKeyObj['eventStartTime'] = "ascending";
        // 同じ時刻、同じ空白だった場合は登録順（登録時シーケンスの早い順）
        sortKeyObj['regDate'] = "ascending";
        // ソート処理
        list.sort((frontValue, nextValue) => {
          // eventStartTime が空の場合のみ比較用の値を作る
          const frontTmp = {
            ...frontValue,
            eventStartTime:
              frontValue.eventStartTime || "6000"
          };
          const nextTmp = {
            ...nextValue,
            eventStartTime:
              nextValue.eventStartTime || "6000"
          };
          return this.sortByProps(
            frontTmp,
            nextTmp,
            sortKeyObj
          );
        });
      }
      // add FNSI-6764 ljx end
      // mod FNSI-3792 fu end
      return list;
    },
    /**
     * 検索IFの初期値取得
     * - 個人設定＞デフォルト設定が登録済の場合はデフォルト設定を検索IFの初期値とする
     * - startDate、endDateはDateオブジェクト
     */
    defaultSetting() {
      // 検索IF 初期値
      const result = {
        obsKindList: null, // カテゴリ
        startDate: this.getSystemDefaultConditionDate.startDate,  // 起票日 開始日
        endDate: this.getSystemDefaultConditionDate.endDate,      // 起票日 終了日
        dispIsDraft: false, // 自分が新規作成
        dispIsEdit: false,  // 自分が最終更新
      };
      
      const defaultCondition = this.getDefaultSetting[OBSERVE_RECORD.KEY_NAME];
      if (defaultCondition) {
		const normalizeCategoryCd = (value) => (value != null) ? [value] : null;
		const categoryData = defaultCondition[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST];
		if(categoryData && categoryData.indexOf("-") > 0){
		  const subCategoryCd = categoryData.substring(0,categoryData.indexOf("-"));
		  const categoryCd = categoryData.substring(categoryData.indexOf("-") + 1);
	      let categoryExistFlg = true;
		  let subCategoryExistFlg = true;
		  if(categoryCd !== AnyCategoryCd){
		    categoryExistFlg = (this.getMstCategoryRecords.filter(rec => rec.categoryCd == categoryCd).length > 0) ? true:false;
		  }
		  if(subCategoryCd !== AnySubCategoryCd){
			subCategoryExistFlg = (this.subCategoryObserveList.filter(rec => rec.subCategoryCd == subCategoryCd).length > 0) ? true:false;
		  }
		  if(categoryCd !== AnyCategoryCd && subCategoryCd === AnySubCategoryCd){
		    subCategoryExistFlg = (this.subCategoryObserveList.filter(rec => rec.categoryCd == categoryCd).length > 0) ? true:false;
		  }
		  if(categoryExistFlg && subCategoryExistFlg){
		    result.obsKindList = normalizeCategoryCd(defaultCondition[OBSERVE_RECORD.KEY_NAME_OBS_KIND_LIST]);
		  }
		}
        
        const normalizeDate = (value) => (value != null) ? toDate(calcTargetDate(value)) : null;
        result.startDate = normalizeDate(defaultCondition[OBSERVE_RECORD.KEY_NAME_START_DATE]) || result.startDate;
        result.endDate = normalizeDate(defaultCondition[OBSERVE_RECORD.KEY_NAME_END_DATE]) || result.endDate;
        
        result.dispIsDraft = defaultCondition[OBSERVE_RECORD.KEY_NAME_DISP_IS_DRAFT];
        result.dispIsEdit = defaultCondition[OBSERVE_RECORD.KEY_NAME_DISP_IS_EDIT];
      }
	  if (!result.obsKindList) {
	    // カテゴリについて個人設定のデフォルト設定がない場合
	    result.obsKindList = [AllCategoryCd];
	  }
      return result;
    },
    ...mapGetters("pat-info", ["selectedPatId", "selectedPatName"]),
    classOther() {
      return 0;
    },
    classSoap() {
      return 1;
    },
    classFdar() {
      return 2;
    },
	selectTemplates() {
	  const dataTable = [AllCategoryTemplete];
	  let subCategories = deepCopy(this.subCategoryObserveList);
	  const categories = this.getMstCategoryRecords;
	  subCategories = this.sortDispData(categories,subCategories);
	  let category = null;
	  for (const subCategory of subCategories) {
	    if (
	      category === null ||
	      category.categoryCd !== subCategory.categoryCd
	    ) {
	      category = categories.find(item => {
	        return item.categoryCd === subCategory.categoryCd;
	      });
	      dataTable.push({
	        code: joinCategoryCd(AnySubCategoryCd, category.categoryCd),
	        name: category.categoryName,
	      });
	    }
	    dataTable.push({
	      code: joinCategoryCd(subCategory.subCategoryCd, category.categoryCd),
	      name: joinCategoryName(category.categoryName, subCategory.subCategoryName),
	    });
	  }
	  return dataTable;
	},
    isViewScore() {
      return this.getAdvancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
      );
    },
    isTreatmentRecord() {
      return this.$route.path.indexOf("treatment-record") > 0;
    }
  },
  watch: {
    getReloadSignal(value, oldValue) {
      //console.log("getReloadSignal");
      if (value && oldValue === false) {
        this.updateObserveRecords(true);
        this.setReloadSignal(false);
      }
    },
    selectedPatId: function() {
      if (this.selectedPatId) {
        this.fetchCondition.startDate = this.condition.startDate;
        this.fetchCondition.endDate = this.condition.endDate;
        // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
        if(this.$route.name !== 'treatment-record-observation'){
          this.updateObserveRecords(true);
        }
        // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      }
    },
    getOrdNo(value, oldValue) {
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
      let ignoreWatchGetOrdNo = true;
      if(this.$route.params && !!this.$route.params.ignoreWatchGetOrdNo){
        ignoreWatchGetOrdNo = this.$route.params.ignoreWatchGetOrdNo != '1';
        delete this.$route.params.ignoreWatchGetOrdNo;
      }
      if (value && value != oldValue && ignoreWatchGetOrdNo) {
        this.updateObserveRecords(true);
      }
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
    'findCondition.startDateView'() {
      if(this.getObserveRecordElementByClassName("start-time").validationMessage !== ""){
        this.showErrorStartDate = !(this.getObserveRecordElementByClassName("start-time").value === "" && this.getObserveRecordElementByClassName("start-date-comment").value !== "");
      }else{
        this.showErrorStartDate = false;
      }
    },
    'findCondition.endDateView'() {
      if(this.getObserveRecordElementByClassName("end-time").validationMessage !== ""){
        this.showErrorEndDate = !(this.getObserveRecordElementByClassName("end-time").value === "" && this.getObserveRecordElementByClassName("end-date-comment").value !== "");
      }else{
        this.showErrorEndDate = false;
      }
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
  },
  methods: {
    scopedJQuery() {
      return createScopedJQuery(this.$el || this, $$) || $$;
    },
    getObserveRecordElementByClassName(className) {
      return getScopedElementsByClassName(className, this.popoverTarget || this.$el || null)?.[0] || null;
    },

    ...mapActions("patient", {
      getPatient: "getPatient"
    }),
    ...mapActions("observe-record/list", [
      // mod FNSI-観察記録を追加 楊 start
      "updateStartToEndDate",
      // mod FNSI-観察記録を追加 楊 end
      "fetchObserveRecords",
      "clearObserveRecords",
      "setReloadSignal",
      "fetchObserveRecordsByOrdNo",
      "setOrdNo",
      "setEditingOrdNo",
      "findPatEventByCd",
      //add FNSI redmine4055修正 房 start
      "setConditionListForSave",
      //add FNSI redmine4055修正 房 end
      "resetIsOtherFacilitys"
    ]),
    ...mapActions("pat-event/detail", ["setPatEventRecord", "setViewMode"]),
    // add FNSI-コントロールの削除 徐 start
    // ...mapActions("pat-event/list", [
    //   "fetchPatEventMaster",
    //   "setConditionDate",
    //   "setUpdateMode"
    // ]),
    ...mapActions("pat-event/list", [
      "fetchPatEventMaster",
      "setConditionDate",
      "setUpdateMode",
      "setPatEventFlg",
      "resetIsOtherFacility"
    ]),
    // add FNSI-コントロールの削除 徐 end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 指定された患者情報データを詳細ストアが取得、詳細画面を開く
     */
    async editPatObsRec(headerFlag, observeRecord) {
      await this.resetIsOtherFacility();
      await this.resetIsOtherFacilitys();
      if (headerFlag === false) {
        const info = [];
        info.push({
          patId: this.selectedPatId,
          isClear: true,
          startDate: this.getSeirekiDateString(this.condition.startDate, ""),
          endDate: this.getSeirekiDateString(this.condition.endDate, "")
        });
        this.setEditingOrdNo(this.getOrdNo).then(() => {
          this.goNext(observeRecord);
        });
      }
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
    showStartMsg(){
      this.showErrorStartDate = this.getObserveRecordElementByClassName("start-time").validationMessage !== "";
    },
    showEndMsg(){
      this.showErrorEndDate = this.getObserveRecordElementByClassName("end-time").validationMessage !== "";
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
    async goNext(observeRecord) {
      if (observeRecord === null) {
        // 観察記録データを新規に作成
        //this.resetSelectedData();
        // Mixinで定義したメソッドで次画面へ遷移
        const user = this.getStateUserAccountInfo;
        const regStaffInfo = JSON.stringify({
          reg_staff_cd: user.userId,
          reg_staff_name: user.userLastName + user.userFirstName
        });
        const upStaffInfo = JSON.stringify({
          up_staff_cd: user.userId,
          up_staff_name: user.userLastName + user.userFirstName
        });
        this.setPatEventRecord({
          // add FNSI-観察記録に移る 徐 start
          selfScreenName:this.selfScreenName,
          // add FNSI-観察記録に移る 徐 end
          patEventCd: 0,
          patId: this.selectedPatId,
          facilityCd: this.facilityCd,
          fnCtlNo: 0,
          eventStatus: null,
          templateCd: 0,
          templateName: null,
          categoryCd: 0,
          categoryName: null,
          useType: 0,
          //mod FNSI-改修内容:オーダ番号を追加しまいました。 房 start
          //ordNo: 0,
          ordNo: this.getOrdNo,
          //mod FNSI-改修内容:オーダ番号を追加しまいました。 房 end
          inputParams: "[]",
          eventStartDate: null,
          eventEndDate: null,
          subCategoryCd: 0,
          subCategoryName: null,
          resultParams: "[]",
          scoreTotal: null,
          regStaffInfo: regStaffInfo,
          upStaffInfo: upStaffInfo,
          bbsCtlNo: 0,
          isNewest: "1",
          isDel: "0",
          regDate: null,
          upDate: null
        });
        // add FNSI-コントロールの削除 徐 start
        this.setPatEventFlg(true);
        // add FNSI-コントロールの削除 徐 end
        this.setViewMode(false);
        this.setUpdateMode(false);
        /*modify FNSI-bug6119 観察記録画面Out of memoryの問題 史 start*/
        if(this.selfScreenName === 'observe-record'){
          this.goSpecifiedView("observe-record-detail");
        }else {
          this.goSpecifiedView("treatment-observe-detail");
        }
        /*modify FNSI-bug6119 観察記録画面Out of memoryの問題 史 end*/
      } else {
        const info = [];
        info.push({
          patId: this.selectedPatId,
          patEventCd: observeRecord.obsRecNo
        });
        await this.findPatEventByCd(info);
        const selectedPatEvent = this.getObserveRecord;
        // add FNSI-観察記録に移る 徐 start
        // await this.setPatEventRecord(selectedPatEvent);
        await this.setPatEventRecord({
          selfScreenName:this.selfScreenName,
          bbsCtlNo: selectedPatEvent.bbsCtlNo,
          categoryCd: selectedPatEvent.categoryCd,
          categoryName: selectedPatEvent.categoryName,
          eventEndDate: selectedPatEvent.eventEndDate,
          eventEndTime: selectedPatEvent.eventEndTime,
          eventStartDate: selectedPatEvent.eventStartDate,
          eventStartTime: selectedPatEvent.eventStartTime,
          eventStatus: selectedPatEvent.eventStatus,
          facilityCd: selectedPatEvent.facilityCd,
          fnCtlNo: selectedPatEvent.fnCtlNo,
          inputParams: selectedPatEvent.inputParams,
          isDel: selectedPatEvent.isDel,
          isNewest: selectedPatEvent.isNewest,
          letterInfo: selectedPatEvent.letterInfo,
          operatorId: selectedPatEvent.operatorId,
          ordNo: selectedPatEvent.ordNo,
          patEventCd: selectedPatEvent.patEventCd,
          patId: selectedPatEvent.patId,
          regDate: selectedPatEvent.regDate,
          regStaffInfo: selectedPatEvent.regStaffInfo,
          resultParams: selectedPatEvent.resultParams,
          scoreTotal: selectedPatEvent.scoreTotal,
          subCategoryCd: selectedPatEvent.subCategoryCd,
          subCategoryName: selectedPatEvent.subCategoryName,
          targetFacilityCd: selectedPatEvent.targetFacilityCd,
          templateCd: selectedPatEvent.templateCd,
          templateName: selectedPatEvent.templateName,
          upDate: selectedPatEvent.upDate,
          upStaffInfo: selectedPatEvent.upStaffInfo,
          useType: selectedPatEvent.useType,
          // mod FNSI-共有を追加 王 20200921 start
          isComRec: true
          // mod FNSI-共有を追加 王 20200921 end
        });
        // add FNSI-観察記録に移る 徐 end
        // add FNSI-コントロールの削除 徐 start
        this.setPatEventFlg(true);
        // add FNSI-コントロールの削除 徐 end
        // Mixinで定義したメソッドで次画面へ遷移
        // mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 start
        // this.setViewMode(false);
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
        // if(!this.hasTreatmentRecordAuthority) {
        if(!this.getItemAuthorized('PatEvent', 'default_authority')) {
          this.setViewMode(true);
        } else {
          this.setViewMode(false);
        }
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
        // mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 end
        this.setUpdateMode(true);
        /*modify FNSI-bug6119 観察記録画面Out of memoryの問題 史 start*/
        if(this.selfScreenName === 'observe-record'){
          this.goSpecifiedView("observe-record-detail");
        }else {
          this.goSpecifiedView("treatment-observe-detail");
        }
        /*modify FNSI-bug6119 観察記録画面Out of memoryの問題 史 end*/
      }
    },
    /**
     * stateに登録されたレコードを画面に表示する用に成形
     */
    convertList(ObserveRecords) {
      const rtnList = [];
      let rtnEventRegDate = "";
      let dataRowIndex = -1;

      for (let i = 0; i < ObserveRecords.length; i++) {
        //console.log("i is %o. ",  i );
        let rtnObsRecNo = "";
        let rtnHeaderFlag = true;
        let rtnEventRegTime = "";
        let rtnViewEventRegTime = "";
        let rtnEventCategoly = "";
        let rtnEventStaff = "";
        let rtnEventObserveRecordMessage = {
          resultValue: "",
          formatClass: "",
          isFormatting: 0
        };
        if (rtnEventRegDate === ObserveRecords[i].viewRecDate) {
          const regStaffInfo = JSON.parse(ObserveRecords[i].regStaffInfo);
          const shapingResult = this.shapingResultParams(ObserveRecords[i]);
          rtnEventObserveRecordMessage = shapingResult;
          rtnObsRecNo = ObserveRecords[i].patEventCd;
          rtnHeaderFlag = false;
          // add FNSI-起票日時は観察記録詳細画面に入力した開始時刻 徐 start
          // rtnEventRegTime = ObserveRecords[i].viewRecTime;
          // rtnViewEventRegTime = rtnEventRegTime.slice(0, 5);
          rtnEventRegTime = ObserveRecords[i].eventStartTime;
          if (rtnEventRegTime === ":" || rtnEventRegTime === null || rtnEventRegTime === "") {
            rtnEventRegTime = "";
          }
          rtnViewEventRegTime = rtnEventRegTime;
          // add FNSI-起票日時は観察記録詳細画面に入力した開始時刻 徐 end
          rtnEventCategoly = ObserveRecords[i].subCategoryName;
          rtnEventStaff = regStaffInfo.reg_staff_name;
        } else {
          rtnEventRegDate = ObserveRecords[i].viewRecDate;
          i--;
        }
        if (!rtnHeaderFlag) {
          dataRowIndex++;
        }
        rtnList.push({
          obsRecNo: rtnObsRecNo,
          viewRecDate: rtnEventRegDate,
          viewRecTime: rtnEventRegTime,
          viewEventRegTime: rtnViewEventRegTime,
          categoly: rtnEventCategoly,
          staff: rtnEventStaff,
          observeRecordMessage: rtnEventObserveRecordMessage,
          headerFlag: rtnHeaderFlag,
          dataRowStripe: !rtnHeaderFlag && dataRowIndex % 2 === 1
        });
      }
      // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
      // 【観察記録】 観察記録画面日期显示不正 by zihao start
      // rtnList.forEach(item => {
      //   (item.observeRecordMessage.constructor === Array) && item.observeRecordMessage.forEach(ita => {
      //     if (ita.resultValue.includes('null')) {
      //       ita.resultValue = ita.resultValue.replace("null", "1970-01-01")
      //     }
      //   })
      // })
      // 【観察記録】 観察記録画面日期显示不正 by zihao end
      // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
      return rtnList;
    },
    shapingResultParams(observeRecord) {
      const resPara = JSON.parse(observeRecord.resultParams || "[]");
      const inpPara = JSON.parse(observeRecord.inputParams || "[]");
      let result = [];
      if (resPara.length > 0) {
        for (var i = 0; i < resPara.length; i++) {
          const res = resPara[i];
          const inp = inpPara[i];
          if (!res || !inp) {
            // Vue3ではstore更新直後の描画で resultParams/inputParams の片側だけ先に反映される場合がある。
            // Vue2同様、対応する入力定義が揃ってから表示成形する。
            continue;
          }
          inp.item_json = inp.item_json || {};
          if (inp.item_json.default_value === undefined || inp.item_json.default_value === null) {
            inp.item_json.default_value = "";
          }
          //0: テキスト
          if (res.format_class === 0) {
            let text = inp.field_name + "：なし";
            if (res.result_value !== "") {
              text = inp.field_name + "：" + res.result_value;
            }else{
              if(inp.item_json.default_value.length>0){
                text = inp.field_name + "：" + inp.item_json.default_value;
              }else{
                text = inp.field_name + "：なし";
              }
            }
            result.push({
              resultValue: text,
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //1: テキストエリア
          if (res.format_class === 1) {
            let text = "";
            if (inp.item_json.is_formatting === "1") {
              text = "なし";
              let areatext = res.result_value.replace(/<[^>]+>/g, "").trim();
              if (areatext.length !== 0) {
                text = res.result_value;
              }
            } else {
              if (res.result_value.trim().length > 0) {
                text = inp.field_name + "：" + res.result_value;
              } else {
                if(inp.item_json.default_value.length>0){
                  text = inp.field_name + "：" + inp.item_json.default_value;
                }else{
                  text = inp.field_name + "：なし";
                }
              }
            }
            result.push({
              resultValue: text,
              formatClass: res.format_class,
              isFormatting: inp.item_json.is_formatting,
              titile: inp.field_name
            });
          }
          //2: 画像
          if (res.format_class === 2) {
            let text = inp.field_name + "：なし";
            for (const value of res.result_value) {
              if (value.file_name !== "") {
                // mod IES_7085【試験T】【結合テスト】観察記録：観察記録の詳細に画像追加が表示され、観察記録に画像追加が表示されない】 関 start
                // text = inp.field_name + "：なし";
                text = inp.field_name + "：あり";
                // mod IES_7085【試験T】【結合テスト】観察記録：観察記録の詳細に画像追加が表示され、観察記録に画像追加が表示されない】 関 end
                break;
              }
            }
            result.push({
              resultValue: text,
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //3:リスト選択
          if (res.format_class === 3) {
            let value = inp.field_name + "：なし";
            if (res.result_value.name !== undefined) {
              value = inp.field_name + "：" + res.result_value.name;
            }
            result.push({
              resultValue: value,
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //4:ラジオボタン
          if (res.format_class === 4) {
            let value = inp.field_name + "：なし";
            if (res.result_value.name !== undefined) {
              value = inp.field_name + "：" + res.result_value.name;
            }
            result.push({
              resultValue: value,
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //5:日付
          if (res.format_class === 5) {
            result.push({
              // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
              // resultValue: inp.field_name + "：" + res.result_value,
              resultValue: inp.field_name + "：" + (res.result_value ? res.result_value : ""),
              // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //6:チェックボックス
          if (res.format_class === 6) {
            let text = inp.field_name + "：なし";
            let first = true;
            if (res.result_value.length > 0) {
              text = inp.field_name + "：";

              for (const value of res.result_value) {
                if (first) {
                  text = text + value.name;
                } else {
                  text = text + "，" + value.name;
                }
                first = false;
              }
            }
            result.push({
              resultValue: text,
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //7:添付ファイル
          if (res.format_class === 7) {
            let text = inp.field_name + "：なし";
            for (const value of res.result_value) {
              if (value.file_name !== "") {
                //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
                text = inp.field_name + "：" + value.file_name;
                //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
                break;
              }
            }
            result.push({
              resultValue: text,
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //8:スコア計算
          if (res.format_class === 8 && this.isViewScore) {
            let text = "スコア計算なし";
            if (observeRecord.scoreTotal !== null) {
              const unit = inp.item_json.unit;
              text = inp.field_name + "：" + observeRecord.scoreTotal + unit;
            }
            result.push({
              resultValue: text,
              formatClass: res.format_class,
              isFormatting: "0",
              titile: inp.field_name
            });
          }
          //9.治療実績リンク

          //10:掲示板リンク
        }
      }
      return result;
    },
    /**
     * 起動時から1週間分の情報を取得してstateに登録
     */
    fetchObserveRecordsFirst() {
      // mod FNSI-観察記録を追加 楊 start
      // this.condition.startDate = new Date();
      // this.condition.startDate.setDate(this.condition.startDate.getDate() - 7);
      // this.condition.endDate = new Date();

      // 患者経過総合ビューア用日付の設定
      if (this.selfScreenName === "observe-record" && this.getStartToEndDate.startDate && this.getStartToEndDate.endDate) {
        this.condition.startDate = this.getStartToEndDate.startDate;
        this.condition.endDate = this.getStartToEndDate.endDate;
      // 他画面から遷移した場合
      } else if(this.$route.params.startDate && this.$route.params.endDate && !this.fromOtherWithParams){
        // 他画面から遷移フラグON
        this.fromOtherWithParams = true;
        this.condition.startDate = dayjs(this.$route.params.startDate).format("YYYY/MM/DD");
        this.condition.endDate = dayjs(this.$route.params.endDate).format("YYYY/MM/DD");
      } else if(this.getConditionList !== null && this.getConditionList.condition){
        // ストアに検索条件が存在する場合、ストアから条件を復元
        this.condition = this.getConditionList.condition;
      } else {
        // サインイン後の初回画面表示の場合、検索条件を初期化
        if (this.condition.startDate === "" && this.condition.endDate === "") {
          this.initCondition();
        }
        
        // ※パンくずリスト押下時は現在の条件で再検索する
      }
      this.updateStartToEndDate({"startDate": "", "endDate": ""});
      // mod FNSI-観察記録を追加 楊 end

      this.fetchCondition.startDate = this.condition.startDate;
      this.fetchCondition.endDate = this.condition.endDate;

      // 検索条件を表示
      this.setConditionList();

      const info = [];
      if (this.getOrdNo) {
        info.push({
          ordNo: this.getOrdNo,
          isClear: true,
          facilityCd: this.getSharedFacilityCd
        });
        this.fetchObserveRecordsByOrdNo(info)
          .then(() => {
            this.setTableBodyWidth();
            this.scopedJQuery()("#scrollArea").scrollTop(1);
            this.isRedrawing = false;
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('ObserveRecordMainComponent.vue', 'fetchObserveRecordsFirst', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            if (error.response?.status === 400) {
              // TODO 必要に応じて、適切な業務エラー処理を実装すること。
            }
          });
      } else if (this.selectedPatId != null) {
		let categoryDataCondition = {categoryCondition:"",subCategoryCondition:""};
		// カンマ区切りで指定
		if(this.condition.obsKindList.length > 0){
		  this.condition.obsKindList.forEach(obsKind => {
		    if (obsKind.substring(0,obsKind.indexOf("-")) !== AnySubCategoryCd) {
			  if(categoryDataCondition.categoryCondition){
				categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + ",";
				categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + ",";
			  }
			  categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + obsKind.substring(obsKind.indexOf("-") + 1);
			  categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + obsKind.substring(0,obsKind.indexOf("-"));
			}
			if (obsKind.substring(obsKind.indexOf("-") + 1) !== AnyCategoryCd
			&& obsKind.substring(0,obsKind.indexOf("-")) === AnySubCategoryCd) {
			  this.selectTemplates.forEach(templete => {
				if (templete.code.substring(templete.code.indexOf("-") + 1) === obsKind.substring(obsKind.indexOf("-") + 1) 
				&& templete.code.substring(0,templete.code.indexOf("-")) !== AnySubCategoryCd) {
				  if(categoryDataCondition.categoryCondition){
					categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + ",";
					categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + ",";
				  }
				  categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + templete.code.substring(templete.code.indexOf("-") + 1);
				  categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + templete.code.substring(0,templete.code.indexOf("-"));
				}
			  });
			}
		  });
		}
        const val = this.getPatientShareMode;
        const otherFacilityCd =
          val === 1 ? this.getFacilityCd : this.getPatientShareFacilityCdMode;
        info.push({
          patId: this.selectedPatId,
          isClear: true,
          startDate: this.getSeirekiDateString(this.condition.startDate, ""),
          endDate: this.getSeirekiDateString(this.condition.endDate, ""),
		  categoryCd: categoryDataCondition.categoryCondition.length > 0 ? categoryDataCondition.categoryCondition:null,
          subCategoryCd: categoryDataCondition.subCategoryCondition.length > 0 ? categoryDataCondition.subCategoryCondition:null,
          regStaffCd: this.dispIsDraft ? this.getStateUserAccountInfo.userId : null,
          upStaffCd: this.dispIsEdit ? this.getStateUserAccountInfo.userId : null,
          offset: 0,
          patShareMode: val,
          otherFacilityCd: otherFacilityCd,
        });
        this.fetchObserveRecords(info)
          .then(() => {
            this.setTableBodyWidth();
            this.scopedJQuery()("#scrollArea").scrollTop(1);
            this.setTotal();
            this.isRedrawing = false;
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('ObserveRecordMainComponent.vue', 'fetchObserveRecordsFirst', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            if (error.response?.status === 400) {
              // TODO 必要に応じて、適切な業務エラー処理を実装すること。
            }
          });
      }
    },
    updateObserveRecords(isRecordClear) {
      this.isRedrawing = true;
      const info = [];
      if (this.getOrdNo) {
        info.push({
          ordNo: this.getOrdNo,
          isClear: isRecordClear,
          facilityCd: this.getSharedFacilityCd
        });
        this.fetchObserveRecordsByOrdNo(info)
          .then(() => {
            this.isRedrawing = false;
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('ObserveRecordMainComponent.vue', 'updateObserveRecords', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            if (error.response?.status === 400) {
              // TODO 必要に応じて、適切な業務エラー処理を実装すること。
            }
          });
      } else {
        
        // 追加読込の場合はapiで取得済みのリストの件数をoffsetにセット
        this.offset = !isRecordClear ? this.getObserveRecords.length : 0;
		let categoryDataCondition = {categoryCondition:"",subCategoryCondition:""};
		// カンマ区切りで指定
		if(this.condition.obsKindList.length > 0){
		  this.condition.obsKindList.forEach(obsKind => {
		    if (obsKind.substring(0,obsKind.indexOf("-")) !== AnySubCategoryCd) {
			  if(categoryDataCondition.categoryCondition){
				categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + ",";
				categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + ",";
			  }
			  categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + obsKind.substring(obsKind.indexOf("-") + 1);
			  categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + obsKind.substring(0,obsKind.indexOf("-"));
			}
			if (obsKind.substring(obsKind.indexOf("-") + 1) !== AnyCategoryCd
			&& obsKind.substring(0,obsKind.indexOf("-")) === AnySubCategoryCd) {
			  this.selectTemplates.forEach(templete => {
			    if (templete.code.substring(templete.code.indexOf("-") + 1) === obsKind.substring(obsKind.indexOf("-") + 1) 
				&& templete.code.substring(0,templete.code.indexOf("-")) !== AnySubCategoryCd) {
				  if(categoryDataCondition.categoryCondition){
					categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + ",";
					categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + ",";
				  }
				  categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + templete.code.substring(templete.code.indexOf("-") + 1);
				  categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + templete.code.substring(0,templete.code.indexOf("-"));
				}
			  });
			}
		  });
		}
        const val = this.getPatientShareMode;
        const otherFacilityCd =
          val === 1 ? this.getFacilityCd : this.getPatientShareFacilityCdMode;
        info.push({
          patId: this.selectedPatId,
          isClear: isRecordClear,
          startDate: this.getSeirekiDateString(this.fetchCondition.startDate, ""),
          endDate: this.getSeirekiDateString(this.fetchCondition.endDate, ""),
		  categoryCd: categoryDataCondition.categoryCondition.length > 0 ? categoryDataCondition.categoryCondition:null,
		  subCategoryCd: categoryDataCondition.subCategoryCondition.length > 0 ? categoryDataCondition.subCategoryCondition:null,
          regStaffCd: this.dispIsDraft ? this.getStateUserAccountInfo.userId : null,
          upStaffCd: this.dispIsEdit ? this.getStateUserAccountInfo.userId : null,
          offset: this.offset,
          patShareMode: val,
          otherFacilityCd: otherFacilityCd,
        });
        /*add FNSI-改修内容6010 任 start*/
        this.conditionList.forEach(item => {
          if(item.name === "起票日"){
            const startStr = this.condition.startDate !== null ? dayjs(new Date(this.condition.startDate)).format("YYYY/MM/DD") : "";
            const endStr = this.condition.endDate !== null ? dayjs(new Date(this.condition.endDate)).format("YYYY/MM/DD") : "";
            if (startStr !== "" || endStr !== "") {
              item.text = startStr + "～" + endStr;
            }
          }
        })
        /*add FNSI-改修内容6010 任 end*/
        this.fetchObserveRecords(info)
          .then(() => {
            this.setTotal();
            this.isRedrawing = false;
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('ObserveRecordMainComponent.vue', 'updateObserveRecords', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            if (error.response?.status === 400) {
              // TODO 必要に応じて、適切な業務エラー処理を実装すること。
            }
          });
      }
    },
    /**
     * 検索条件の日付文字列(yyyyMMdd)を作る
     * @param dt 元の日付(Date型)
     */
    getSeirekiDateString(dt, delimiter) {
      // console.log(new Date(dt));
      if (typeof dt == 'string') {
        /*add FNSI-改修内容6120 任 start*/
        if(dt === ""){
          return `${new Date().getFullYear()}${delimiter}${`0${new Date().getMonth() + 1}`.slice(
            -2)}${delimiter}${`0${new Date().getDate()}`.slice(-2)}`;
        }else{
          /*add FNSI-改修内容6120 任 end*/
          return `${new Date(dt).getFullYear()}${delimiter}${`0${new Date(dt).getMonth() + 1}`.slice(
            -2)}${delimiter}${`0${new Date(dt).getDate()}`.slice(-2)}`;
          /*add FNSI-改修内容6120 任 start*/
        }
        /*add FNSI-改修内容6120 任 end*/
      }
      return dt !== null ? `${dt.getFullYear()}${delimiter}${`0${dt.getMonth() + 1}`.slice(
        -2)}${delimiter}${`0${dt.getDate()}`.slice(-2)}` : null;
    },
    /**
     * 日付を日単位で足す
     * @param dt 元の日付
     * @param days 日数
     */
    addDate(dt, days) {
      return dt.setDate(dt.getDate() + days);
    },
    /**
     * フィルタリング処理
     * 観察記録の場合はapi側で利用種別: 2「観察記録」、削除フラグ: 0 で抽出しているが、
     * 治療記録＞観察記録の場合はord_noのみを条件にapi側でデータ取得するため、利用種別: 2「観察記録」、削除フラグ: 0 でのフィルタが必要
     */
    filterObserveRecords(observeRecords) {
      return observeRecords
        .filter(dat => {
          return (
            dat.useType === 2 &&
            dat.isDel === "0"
          );
        })
        .slice();
    },
    /**
     * 新規追加ボタンクリック時の処理
     */
    clickAddButton() {
      // 患者IDチェック処理
      if (this.selectedPatId !== null) {
        // mod FNSI-共有を追加 王 20200921 start
        // 権限を有の場合
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
        // if(this.hasTreatmentRecordAuthority){
        if(this.getItemAuthorized('PatEvent', 'default_authority')){
          // 共有の場合
          //共有callback 連協確認要
          // if (this.getFacilityCd === this.getSharedFacilityCd) {
            // 患者が選択されている場合
            this.editPatObsRec(false, null);
          // }
        }
        //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
        // mod FNSI-共有を追加 王 20200921 end
      }
    },
    /**
     * ヘッダークリック時の処理
     */
    async clickHeader(key) {
      await this.resetIsOtherFacility();
      await this.resetIsOtherFacilitys();
      switch (key) {
        case this.columns[0].key: {
          //console.log(key);
          this.sortBy(key);
          break;
        }
        default: {
          break;
        }
      }
    },
    /**
     * 昇順/降順のclassを作成
     */
    sortedClass(key) {
      return this.sort.key === key
        ? `sorted-${this.sort.isAsc ? "desc" : "asc"}`
        : "";
    },
    /**
     * ソートするキーを設定する
     */
    sortBy(key) {
      if (key === this.sort.key && !this.sort.isAsc) {
        // ソートをクリア
        this.sort.key = "";
        this.sort.isAsc = true;
        return;
      }
      this.sort.isAsc = this.sort.key === key ? !this.sort.isAsc : true;
      this.sort.key = key;
    },
    makeCategorySelection() {
      // カテゴリ選択リスト用の情報を作成する
      this.categorySelection = this.selectTemplates.map(templete => {
      const categoryCodes = templete.code.split(CategoryCdDelimiter);
      return {
        ...templete,
        subCategoryCd: categoryCodes[0],
        categoryCd: categoryCodes[1],
        selected: this.condition.obsKindList.some(cd => cd === templete.code),
      };
      });
    },
    /**
     * ポップアップメニューを表示
     */
    showPopover(event) {
      // mod 7936 掲示板に連携通知がコンバートされていない 関 start
      // this.condition.startDateView = this.getSeirekiDateString(
      //   this.condition.startDate,
      //   "-"
      // );
      // this.condition.endDateView = this.getSeirekiDateString(
      //   this.condition.endDate,
      //   "-"
      // );
      if ((this.$route.params.startDate === undefined && this.$route.params.endDate === undefined) || (this.condition.startDateView != '' && this.condition.endDateView != '')) {
        this.condition.startDateView = this.getSeirekiDateString(
        this.condition.startDate,
        "-"
        );
        this.condition.endDateView = this.getSeirekiDateString(
        this.condition.endDate,
        "-"
        );
      } else {
        if (this.$route.params.startDate === null && this.$route.params.endDate ===null) {
          this.condition.startDateView = dayjs().subtract(7, 'days').format("YYYY/MM/DD");
          this.condition.endDateView = dayjs(Date.now()).format("YYYY/MM/DD");
        }else if(this.$route.params.startDate != null && this.$route.params.endDate === null) {
          this.condition.startDateView = dayjs(this.$route.params.startDate).format("YYYY-MM-DD");
          this.condition.endDateView = dayjs(this.$route.params.startDate).add(7, 'days').format("YYYY-MM-DD");
        }else if (this.condition.startDateView === '' && this.condition.endDateView === ''){
          this.condition.startDateView = dayjs(this.$route.params.startDate).format("YYYY-MM-DD");
           this.condition.endDateView = dayjs(this.$route.params.endDate).format("YYYY-MM-DD");
        }
      }
      // mod 7936 掲示板に連携通知がコンバートされていない 関  end
      // 抽出条件コピー
      this.findCondition = JSON.parse(JSON.stringify(this.condition));

      //
      this.popoverTarget = event;
      this.popoverVisible = true;
      /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
      this.showErrorStartDate = false;
      this.showErrorEndDate = false;
      this.getObserveRecordElementByClassName("start-date-comment").value = this.condition.startDateView;
      this.getObserveRecordElementByClassName("end-date-comment").value = this.condition.endDateView;
      /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
	  this.makeCategorySelection();
    },
    /**
     * 検索ダイアログの初期化
     */
    dialogClear() {
      // 検索IFの条件初期化
      this.initCondition();
	  this.makeCategorySelection();
      /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
      this.showErrorStartDate = false;
      this.showErrorEndDate = false;
      /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/

      // 画面閉じる
      this.popoverVisible = false;
      // 検索処理の実行
      this.fetchObserveRecordsFirst();
    },
    dialogOk() {
      // 抽出条件を設定
      this.condition = JSON.parse(JSON.stringify(this.findCondition));
	  
	  this.condition.obsKindList.length = 0;
	  this.condition.obsKindList.push(
	   	...this.categorySelection.reduce((result, item) => {
	   	  if (item.selected) {
	   	    result.push(item.code);
	   	  }
	   	  return result;
	    }, [])
	  );
	  if (this.condition.obsKindList.length === 0) { 
	   	this.condition.obsKindList.push(AllCategoryCd); 
	  }

      this.popoverBlur("startDate", this.condition.startDateView);
      this.popoverBlur("endDate", this.condition.endDateView);
      this.popoverVisible = false;
      this.search();
      this.setConditionList();
    },
    // mod FNSI-改修内容日付のチェックの追加対応。 付 start
    popoverBlur(itemName, value) {
      // valueは表示期間をクリアするとnullが設定されるためnullの場合も考慮する
      const newDate = value !== null ? new Date(`${value.replace(/-/g, "/")} 00:00:00`) : null;
      const newFetchDate = value !== null ? new Date(`${value.replace(/-/g, "/")} 00:00:00`) : null;
      if (newDate === null || newDate.toString() !== "Invalid Date") {
        if (itemName === "startDate") {
          this.condition.startDate = newDate;           // 抽出条件
          this.fetchCondition.startDate = newFetchDate; // apiリクエストパラメータ
        } else if (itemName === "endDate") {
          this.condition.endDate = newDate;
          this.fetchCondition.endDate = newFetchDate;
        }
      }
    },
    getStartDate() {
      this.showErrorStartDate = this.getObserveRecordElementByClassName("start-time").validationMessage !== "";
    },
    getEndDate() {
      this.showErrorEndDate = this.getObserveRecordElementByClassName("end-time").validationMessage !== "";
    },
    // mod FNSI-改修内容日付のチェックの追加対応。 付 end
    /**
     * 共通検索エリア部品に表示するデータのリストを作成
     */
    setConditionList() {
      let condList = [];
      const condObj = this.condition;
      // 起票日
      // mod 7936 掲示板に連携通知がコンバートされていない 関 start
      // let startStr = "";
      // if (typeof condObj.startDate === "object") {
      //   startStr = dayjs(condObj.startDate).format("YYYY/MM/DD");
      // }
      // let endStr = "";
      // if (typeof condObj.endDate === "object") {
      //   endStr = dayjs(condObj.endDate).format("YYYY/MM/DD");
      // }
      let startStr = "";
      if (typeof condObj.startDate === "object" && this.$route.params.startDate === undefined) {
        startStr = condObj.startDate !== null ? dayjs(condObj.startDate).format("YYYY/MM/DD") : "";
      }else {
        if (this.$route.params.startDate === null && this.$route.params.endDate === null) {
          startStr = dayjs().subtract(7, 'days').format("YYYY/MM/DD");
        }else if (this.condition.startDateView === '') {
          startStr = dayjs(this.$route.params.startDate).format("YYYY/MM/DD");
        }else {
          startStr = condObj.startDate !== null ? dayjs(condObj.startDate).format("YYYY/MM/DD") : "";
        }
      }
      let endStr = "";
      if (typeof condObj.endDate === "object"  && this.$route.params.endDate === undefined) {
        endStr = condObj.endDate !== null ? dayjs(condObj.endDate).format("YYYY/MM/DD") : "";
      }else {
        if (this.$route.params.startDate === null && this.$route.params.endDate === null) {
          endStr = dayjs(Date.now()).format("YYYY/MM/DD");
        }else if (this.$route.params.startDate != null && this.$route.params.endDate === null && this.condition.endDateView === '') {
          endStr = dayjs(this.$route.params.startDate).add(7, 'days').format("YYYY/MM/DD");
        }else if (this.condition.endDateView === '') {
          endStr = dayjs(this.$route.params.endDate).format("YYYY/MM/DD");
        }else {
          endStr = condObj.endDate !== null ? dayjs(condObj.endDate).format("YYYY/MM/DD") : "";
        }
      }
      // mod 7936 掲示板に連携通知がコンバートされていない 関  end
      if (startStr !== "" || endStr !== "") {
        condList.push({ name:"起票日", text:startStr + "～" + endStr });
      }
	  // カテゴリ
	  const categoryText = this.selectTemplates.reduce((result, template) => {
	    if (condObj.obsKindList.some(cd => cd === template.code)) {
	      result.push(template.name);
	    }
	    return result;
	  }, []).join("、");
	  if (categoryText.length > 0) {
		condList.push({ name:"カテゴリ", text:categoryText});
	  }
      // 自分が新規作成
      if (this.dispIsDraft) {
        condList.push({ text:"自分起票" });
      }
      // 自分が最終更新
      if (this.dispIsEdit) {
        condList.push({ text:"自分編集" });
      }
      //mod FNSI redmine4055修正 房 start
      // mod 7936 掲示板に連携通知がコンバートされていない 関 start
      // if (this.getConditionList != null) {
      if (this.getConditionList != null && (this.$route.params.startDate === undefined && this.$route.params.endDate === undefined)) {
      // mod 7936 掲示板に連携通知がコンバートされていない 関  end
        /*add FNSI-改修内容6010 任 start*/
        if(this.getConditionList.conditionList.length > 0){
          /*add FNSI-改修内容6010 任 end*/
          this.conditionList = this.getConditionList.conditionList;
          this.condition = this.getConditionList.condition;
          let dispIsEditFLag = this.getConditionList.conditionList.find(el=>el.text == "自分編集");
          if (dispIsEditFLag) {
            this.dispIsEdit = true;
          }
          let dispIsDraftFlag = this.getConditionList.conditionList.find(el=>el.text == "自分起票");
          if (dispIsDraftFlag) {
            this.dispIsDraft = true;
          }
          /*add FNSI-改修内容6010 任 start*/
        }else{
          this.conditionList = condList;
        }
        /*add FNSI-改修内容6010 任 end*/
      } else {
        this.conditionList = condList;
      }
      //mod FNSI redmine4055修正 房 end
      
      // ストアに保存してある検索条件をクリア
      this.setConditionListForSave(null);
    },
    /**
     * 検索条件に一致するレコードを取得してstateに登録
     */
    search() {
      this.updateObserveRecords(true);
    },
    /**
     * tableのbodyサイズをヘッダーのサイズに揃える
     */
    setTableBodyWidth() {
      //
      this.scopedJQuery()(`.${this.columns[0].className}`).width(
        this.scopedJQuery()(`#${this.columns[0].key}`).width()
      );
      //
      this.scopedJQuery()(`.${this.columns[1].className}`).width(
        this.scopedJQuery()(`#${this.columns[1].key}`).width()
      );
      //
      this.scopedJQuery()(`.${this.columns[2].className}`).width(
        this.scopedJQuery()(`#${this.columns[2].key}`).width()
      );
      //
      this.scopedJQuery()(`.${this.columns[3].className}`).width(
        this.scopedJQuery()(`#${this.columns[3].key}`).width() + 16
      );
    },
    onIsDraftChange(ev) {
      if (ev.target.checked) {
        this.dispIsDraft = true;
      } else {
        this.dispIsDraft = false;
      }
    },
    onIsEditChange(ev) {
      if (ev.target.checked) {
        this.dispIsEdit = true;
      } else {
        this.dispIsEdit = false;
      }
    },
    onInOrdno() {
      this.setOrdNo(this.tmpOrdno);
    },
    setObserveRecord(chgflg) {
	  let categoryDataCondition = {categoryCondition:"",subCategoryCondition:""};
	  // カンマ区切りで指定
	  if(this.condition.obsKindList.length > 0){
	    this.condition.obsKindList.forEach(obsKind => {
	      if (obsKind.substring(0,obsKind.indexOf("-")) !== AnySubCategoryCd) {
	  	  if(categoryDataCondition.categoryCondition){
	  		categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + ",";
	  		categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + ",";
	  	  }
	  	  categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + obsKind.substring(obsKind.indexOf("-") + 1);
	  	  categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + obsKind.substring(0,obsKind.indexOf("-"));
	  	}
	  	if (obsKind.substring(obsKind.indexOf("-") + 1) !== AnyCategoryCd
	  	&& obsKind.substring(0,obsKind.indexOf("-")) === AnySubCategoryCd) {
	  	  this.selectTemplates.forEach(templete => {
			if (templete.code.substring(templete.code.indexOf("-") + 1) === obsKind.substring(obsKind.indexOf("-") + 1) 
			&& templete.code.substring(0,templete.code.indexOf("-")) !== AnySubCategoryCd) {
	  		  if(categoryDataCondition.categoryCondition){
	  			categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + ",";
	  			categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + ",";
	  		  }
	  		  categoryDataCondition.categoryCondition = categoryDataCondition.categoryCondition + templete.code.substring(templete.code.indexOf("-") + 1);
	  		  categoryDataCondition.subCategoryCondition  = categoryDataCondition.subCategoryCondition + templete.code.substring(0,templete.code.indexOf("-"));
	  		}
	  	  });
	  	}
	    });
	  }
      if (chgflg) {
        const info = [];
        const val = this.getPatientShareMode;
        const otherFacilityCd =
          val === 1 ? this.getFacilityCd : this.getPatientShareFacilityCdMode;
        info.push({
          patId: this.selectedPatId,
          isClear: true,
          startDate: this.getSeirekiDateString(this.condition.startDate, ""),
          endDate: this.getSeirekiDateString(this.condition.endDate, ""),
		  categoryCd: categoryDataCondition.categoryCondition.length > 0 ? categoryDataCondition.categoryCondition:null,
		  subCategoryCd: categoryDataCondition.subCategoryCondition.length > 0 ? categoryDataCondition.subCategoryCondition:null,
          regStaffCd: this.dispIsDraft ? this.getStateUserAccountInfo.userId : null,
          upStaffCd: this.dispIsEdit ? this.getStateUserAccountInfo.userId : null,
          offset: 0,
          patShareMode: val,
          otherFacilityCd: otherFacilityCd,
        });
        this.fetchCondition.startDate = this.condition.startDate;
        this.fetchCondition.endDate = this.condition.endDate;
        this.fetchObserveRecords(info)
          .then(() => {
            this.setTotal();
            this.isRedrawing = false;
          })
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('ObserveRecordMainComponent.vue', 'setObserveRecord', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            if (error.response?.status === 400) {
              // TODO 必要に応じて、適切な業務エラー処理を実装すること。
            }
          });
      }
    },
    async loadData() {
      
      this.clearObserveRecords();
      
      this.isRedrawing = true;
      
      //患者イベント関連のマスタ取得
      await this.fetchPatEventMaster();
      //タブ入力情報の初期化
      this.setConditionDate({ startDate: null, endDate: null });

      // 初期データ取得
      this.fetchObserveRecordsFirst();
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name) {
        this.loadData();
      }
    },
    // add FNSI-権限関連 王 20200927 start
    // 治療記錄の權限を取得する
    // mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 start
    // getTreatmentRecordAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
    // },
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // getTreatmentRecordAuthority() {
    //   if (this.$route.path.indexOf("treatment-record") > 0) {
        // return this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
      // } else {
      //   return this.hasAuthority();
      // }
    // },
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    // mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 end
    // add FNSI-権限関連 王 20200927 end
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // 印刷パラメータを応答
        const param = {
          facilityCd: this.getFacilityCd,
          patId: this.selectedPatId,
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"01601",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // mod #9558 機能帳票でパラメータが正しく渡されていない limingzhe start
          // add #9558 機能帳票でパラメータが正しく渡されていない 房 start
          //date: this.condition.startDate !== null ? dayjs(this.condition.startDate).format("YYYY/MM/DD") : null,
          // add #9558 機能帳票でパラメータが正しく渡されていない 房 end
          //fromDate: this.condition.startDate !== null ? dayjs(this.condition.startDate).format("YYYY/MM/DD") : null,
          //toDate: this.condition.endDate !== null ? dayjs(this.condition.endDate).format("YYYY/MM/DD") : null
          // date: this.condition.startDate !== null ? dayjs(this.condition.startDate).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD"),
          // fromDate: this.condition.startDate !== null ? dayjs(this.condition.startDate).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD"),
          // toDate: this.condition.endDate !== null ? dayjs(this.condition.endDate).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD"),
          date: this.condition.startDate !== null ? dayjs(this.condition.startDate).format("YYYYMMDD") : (this.condition.endDate !== null ? dayjs(this.condition.endDate).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          fromDate: this.condition.startDate !== null ? dayjs(this.condition.startDate).format("YYYYMMDD") : (this.condition.endDate !== null ? dayjs(this.condition.endDate).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          toDate: this.condition.endDate !== null ? dayjs(this.condition.endDate).format("YYYYMMDD") : (this.condition.startDate !== null ? dayjs(this.condition.startDate).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          // mod #9558 機能帳票でパラメータが正しく渡されていない limingzhe end
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add FNSI-6764 ljx start
    //リストのソート処理
    sortByProps(item1,item2,obj){
      var props = [];
      if(obj){
        props.push(obj)
      }
      var cps = [];
      var asc;
      if (props.length < 1) {
        for (var p in item1) {
          if (item1[p] > item2[p]) {
            cps.push(1);
            break;
          } else if (item1[p] === item2[p]) {
            cps.push(0);
          } else {
            cps.push(-1);
            break;
          }
        }
      }
      else {
        for (var i = 0; i < props.length; i++) {
          var prop = props[i];
          for (var o in prop) {
            asc = prop[o] === "ascending";
            if (item1[o] > item2[o]) {
              cps.push(asc ? 1 : -1);
              break;
            } else if (item1[o] === item2[o]) {
              cps.push(0);
            } else {
              cps.push(asc ? -1 : 1);
              break;
            }
          }
        }
      }
      for (var j = 0; j < cps.length; j++) {
        if (cps[j] === 1 || cps[j] === -1) {
          return cps[j];
        }
      }
      return false;
    },
    // add FNSI-6764 ljx end
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    /**
     * スクロールが最後尾に達した時に追加読み込みを行う
     */
    async scrollHandler() {
      
      // api呼出し中の場合は追加読込しない
      if (this.isRedrawing === true) {
        return;
      }
      // トータル件数に達した場合は追加読込しない
      if (this.getObserveRecords.length >= this.total) {
        return;
      }
      const e = this.$refs.scrollArea;
      // スクロールの位置がピクセル単位であるため、場合によっては非常に小さなずれが生じるため誤差許容範囲を設定
      const tolerance = 4; // 誤差許容範囲を4ピクセルに設定
      const isScrolledBottom = Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) <= tolerance;
      if (isScrolledBottom && e.scrollTop > 0) {
        this.isRedrawing = true;
        this.updateObserveRecords(false);
      } 
    },
    /**
     * 観察記録リストのトータル件数を設定
     */
    setTotal() {
      if (this.getObserveRecords.length > 0 && this.getObserveRecords[0].total !== null) {
        this.total = this.getObserveRecords[0].total;
      }
    },
    /**
     * 検索IFの条件初期化
     */
    initCondition() {
      // ストアに保存してある検索条件をクリア
      this.setConditionListForSave(null);
      
      this.condition.startDate = this.defaultSetting.startDate;
      this.condition.endDate = this.defaultSetting.endDate;
      this.condition.obsKindList = [...this.defaultSetting.obsKindList];
      this.dispIsDraft = this.defaultSetting.dispIsDraft;
      this.dispIsEdit = this.defaultSetting.dispIsEdit;
    },
	singleSelect(index) {
	  const targetCategorySelection = this.categorySelection[index];
	  if (targetCategorySelection.selected) {
	    // 選択解除する場合
	    targetCategorySelection.selected = false;
	    if (!this.categorySelection.some(aCategorySelection => aCategorySelection.selected)) {
	      // 何も選択されていない状態になったら「全カテゴリ」を選択する
	      this.categorySelection[0].selected = true;
	    }
	  } else {
	    // 選択する場合
	    const unselectCondition = (index === 0) ? aCategorySelection => (
	    // 「全カテゴリ」を選択した場合は「全カテゴリ」以外の項目の選択を解除する
	    aCategorySelection.categoryCd !== AnyCategoryCd
	    || aCategorySelection.subCategoryCd !== AnySubCategoryCd) : (targetCategorySelection.subCategoryCd === AnySubCategoryCd) ? aCategorySelection => (
	    // サブカテゴリでない項目を選択した場合はそれが含むサブカテゴリと「全カテゴリ」の選択を解除する
	    aCategorySelection.categoryCd === AnyCategoryCd
	    || (
	      aCategorySelection.categoryCd === targetCategorySelection.categoryCd
	      && aCategorySelection.subCategoryCd !== AnySubCategoryCd)) : aCategorySelection => (
	      // サブカテゴリ項目を選択した場合はそれを含むサブカテゴリでない項目の選択を解除する
	      aCategorySelection.categoryCd === AnyCategoryCd
	      || (
	        aCategorySelection.categoryCd === targetCategorySelection.categoryCd
	        && aCategorySelection.subCategoryCd === AnySubCategoryCd));
	    this.categorySelection.forEach(aCategorySelection => {
	      if (
	        aCategorySelection.selected
	        && unselectCondition(aCategorySelection)
	      ) {
	        aCategorySelection.selected = false;
	      }
	    });
	    targetCategorySelection.selected = true;
	  }
    },
	sortDispData(categories,subCategories) {
	  let sortedSubCategories = [];
	  categories.forEach(category => {
	    subCategories.forEach(subCategory => {
	      if(category.categoryCd === subCategory.categoryCd){
		    sortedSubCategories.push(subCategory);
		  }
	    })
	  })
	  return sortedSubCategories;
	}
  },
  created() {
    
    // storeに保持されているリストデータクリア
    this.clearObserveRecords();
    
    // 外部結合テスト No1 姜 start
    this.sort.key = "";
    this.sort.isAsc = true;
    // 外部結合テスト No1 姜 end
    EventBus.$on("reloadObserveRecord", this.setObserveRecord);
    EventBus.$on("refreshObserveList", this.fetchObserveRecordsFirst);
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);

    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);

    // データ取得
    this.loadData();

    // add FNSI-権限関連 王 20200927 start
    // 治療記錄の權限取得
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    // add FNSI-権限関連 王 20200927 end
  },
  // add FNSI-redmine#4199 付 start
  mounted() {
    // 治療記録画面でない場合に実施
    if (!this.isTreatmentRecord) {
      const ownerDocument = getScopedDocument(this.$el);
      const bodyHeight = (ownerDocument?.body || ownerDocument?.documentElement)?.offsetHeight || 0;
      const header = getHeaderHeight(getLatestHeaderElement(this.$el || ownerDocument), 0);
      const footer = getFooterMenuClientHeight(this.$el || null);
      const mainContainer = this.$el?.closest?.(".main") || getMainContentAreaElement(this.$el || null)?.closest?.(".main") || null;
      if (mainContainer) {
        mainContainer.setAttribute("style", "height:" + (bodyHeight - header - footer) + "px");
      }
    }
    // リサイズ時にtableBodyのサイズを再計算
    (getScopedWindow(this.$el) || window).addEventListener('resize', this.setTableBodyWidth);
  },
  // add FNSI-redmine#4199 付 end
  updated() {
    this.setTableBodyWidth();
  },
  beforeUnmount() {
    //add FNSI redmine4055修正 房 start
    if (!(this.getRefresh && this.getRefresh.status === true)) {
      this.setConditionListForSave({
        conditionList: this.conditionList,
        condition: this.condition
      });
    }
    (getScopedWindow(this.$el) || window).removeEventListener('resize', this.setTableBodyWidth);
    //add FNSI redmine4055修正 房 end
    EventBus.$off("reloadObserveRecord", this.setObserveRecord);
    EventBus.$off("refreshObserveList", this.fetchObserveRecordsFirst);
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // EventBus.$off("refresh");
    EventBus.$off("refresh", this.refresh);
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    // 抽出オーダー番号削除
    this.setOrdNo(0);

    // 印刷パラメータ要求
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.popoverFilterLabel {
  margin-left: -5px;
  margin-right: 7px;
  font-size: 1.6em;
}

.obs-rec-header-sticky {
  position: sticky;
}

.main-font .main-font {
  font-size: 1em;
}
.main-font .header {
  font-size: 0.667em;
}
/* FNSI-改修内容5481bug修正 関 start */
.ntss-list tr {
    border-color: var(--ntss-list-border-color);
}

.ntss-list tbody tr.ntss-list-body-tr {
  background-color: var(--ntss-list-item-background-color);
}
.ntss-list tbody tr.ntss-list-body-tr.data-row-stripe {
  background-color: var(--ntss-list-content-2nd-background-color);
}

/* FNSI-改修内容5481bug修正 関 end */
.master-search :deep(.popover) {
  width: 29em;
}
.ptag-margin-setter :deep(p) {
  margin: 0.2em 0;
}
/* add 6685 横展開、タイトルが調整できるようにする 黄 start */
.manual-width {
  resize: horizontal;
  overflow-x: auto;
}
/* add 6685 横展開、タイトルが調整できるようにする 黄  end */
/* add 6685 横展開、タイトルが調整できるようにする 関 start */
.ntss-list {
  width: max-content;
  min-width: 100%;
}
/* add 6685 横展開、タイトルが調整できるようにする 関  end */
.pat-list {
  height: 110px;
}
.pat-list .unselected-pat-list{
  position: relative;
  border: 1px solid var(--ntss-list-border-color);
  overflow: auto;
}
.pat-display {
  padding: 0.05em 0.3em;
}
.pat-display:hover {
  background-color: #e4e7eb;
}
.pat-display.selected {
  color: #fff;
  background-color: #0076ff;
}

.table-disabled {
  pointer-events: none;
  opacity: 0.6;
}
</style>
