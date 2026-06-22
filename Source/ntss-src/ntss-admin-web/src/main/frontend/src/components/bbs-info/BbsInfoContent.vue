<template>
  <div>
    <!--
    delect FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    <div class="main-content-area" style="-webkit-overflow-scrolling:touch; ">
    delect FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    -->
    <!-- add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start -->
    <div
      class="main-content-area"
      style="-webkit-overflow-scrolling: touch"
      @scroll="scrollHandler"
      ref="ntssList"
    >
      <!-- add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end -->
      <table class="ntss-list" style="width: max-content; min-width: 100%;">
        <thead>
        <!-- 項目 -->
        <!-- mod FNSI-改修内容 印刷不正の対応 xie start -->
        <!-- <thead> -->
        <!-- mod FNSI-改修内容 印刷不正の対応 xie end -->
        <tr>
          <!-- delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start -->
          <!-- <th
              v-for="(item, index) in displayItem"
              :key="index"
              class="ntss-list-header-th-sticky"
              :style="{ width: item.width, 'min-width': item.minWidth }"
              @click="setSortKind(item.itemKey)"
            > -->
          <!-- delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end -->
          <th
            v-for="(item, index) in displayItem"
            :key="index"
            class="ntss-list-header-th-sticky manual-width"
            :style="{ width: item.width, 'min-width': item.minWidth }"
          >
            <span @click="setSort(item.itemKey)" :class="sortedClass(item.itemKey)" class="clickable-header-label">{{ item.itemName }}</span>
          </th>
        </tr>
        </thead>
        <!-- mod FNSI-改修内容 印刷不正の対応 xie start -->
        <!-- </thead> -->
        <!-- mod FNSI-改修内容 印刷不正の対応 xie end -->
        <tr
          v-for="(bbs, bbsIndex) in searchedResults"
          :key="bbsIndex"
          class="ntss-list-body-tr"
        >
          <!-- カテゴリ -->
          <!-- mod FNSI-改修内容4193bug修正 関 start -->
          <!-- <td class="ntss-list-body-td" @click="transitionBbsDetailed(bbs)"> -->
          <td
            class="ntss-list-body-td ntss-list-body-td-kindname"
            @click="transitionBbsDetailed(bbs)"
          >
            <!-- mod FNSI-改修内容4193bug修正 関 end -->
            <span>
              {{ bbs.kind_name }}
            </span>
          </td>
          <!-- 患者 -->
          <!-- FNSI-改修内容4193bug修正 関 start -->
          <!-- <td class="ntss-list-body-td" @click="transitionBbsDetailed(bbs)"> -->
          <td
            class="ntss-list-body-td ntss-list-body-td-patname"
            @click="transitionBbsDetailed(bbs)"
          >
            <!-- FNSI-改修内容4193bug修正 関 end -->
            <span v-if="bbs.pat_info&&bbs.pat_info.target === INDIVIDUALLY_USER">
              <span
                v-for="(pat, patIndex) in getPatName(bbs.pat_info.detail)"
                :key="patIndex"
              >
                {{ pat }}<br />
              </span>
            </span>
            <span v-show="bbs.pat_info&&bbs.pat_info.target === ALL_USER">全患者</span>
            <!-- mod FNSI-No.548  患者名の「なし」は記載不要 孫 start-->
            <!--<span v-show="bbs.pat_info.target === NOT_USER">なし</span>-->
            <span v-show="bbs.pat_info&&bbs.pat_info.target === NOT_USER"></span>
            <!-- mod FNSI-No.548  患者名の「なし」は記載不要 孫 end-->
          </td>
          <!-- 内容 -->
          <!-- mod FNSI-改修内容4193bug修正 関 start -->
          <!-- <td class="ntss-list-body-td" @click="transitionBbsDetailed(bbs)"> -->
          <td
            class="ntss-list-body-td ntss-list-body-td-content"
            @click="transitionBbsDetailed(bbs)"
          >
            <!-- FNSI-改修内容4193bug修正 関 end -->
            <span v-if="bbs.title" style="white-space: pre-wrap" v-safe-html="bbs"></span>
            <span v-else style="white-space: pre-wrap" v-safe-html="bbs"></span>
          </td>
          <!-- add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 start -->
          <!-- 掲載期間 -->
          <!-- FNSI-改修内容4192bug修正 関 start -->
          <!-- <td class="ntss-list-body-td" style="text-align:center;" @click="transitionBbsDetailed(bbs)"> -->
          <!-- <td class="ntss-list-body-td" style="text-align:left;" @click="transitionBbsDetailed(bbs)"> -->
          <td
            class="ntss-list-body-td ntss-list-body-td-date"
            style="text-align: left"
            @click="transitionBbsDetailed(bbs)"
          >
            <!-- FNSI-改修内容4192bug修正 関 end -->
            <span v-if="!bbs.notice_start_date">
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </span>
            <span>
              {{ bbs.notice_date }}
            </span>
            <span v-if="!bbs.notice_end_date">
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </span>
          </td>
          <!-- add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 end -->
          <!-- 既読未読状態 -->
          <!--mod FNSI-改修内容redmine4468 任 start-->
          <!--<td class="ntss-list-body-td">-->
          <td class="ntss-list-body-td" style="text-align: center">
            <!--mod FNSI-改修内容redmine4468 任 end-->
            <v-ons-button
              v-if="bbs.staff_info"
              :class="[
                'button-area',
                getReadState(bbs.staff_info.read) === '未読'
                  ? 'ntss-button-un-read'
                  : 'ntss-button-read',
              ]"
              @click="confirmChangeState(bbs.bbs_ctl_no, bbs.staff_info)"
            >
              {{ getReadState(bbs.staff_info.read) }}
            </v-ons-button>
          </td>
          <!-- リンク -->
          <!-- FNSI-改修内容4193bug修正 関 start -->
          <!-- <td
            class="ntss-list-body-td"
            @click="
              transition(bbs.pat_info, $event, bbs.transition_router_path)
            "
          > -->
          <!-- mod 7936 掲示板に連携通知がコンバートされていない 関 start -->
           <!-- <td
            class="ntss-list-body-td ntss-list-body-td-path"
            @click="
              transition(bbs.pat_info, $event, bbs.transition_router_path)
            "
          > -->
<!--          add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start-->
          <td
            class="ntss-list-body-td ntss-list-body-td-path"
            @click="
              transition(bbs.pat_info, $event, bbs.transition_router_path, bbs.notice_start_date, bbs.notice_end_date, bbs.bbs_ctl_no)
            "
          >
<!--            add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end-->
          <!-- mod 7936 掲示板に連携通知がコンバートされていない 関  end -->
            <!-- FNSI-改修内容4193bug修正 関 end -->
            {{ getRouterName(bbs.transition_router_path) }}
          </td>
        </tr>
      </table>
    </div>

    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      direction="left"
      :cover-target="false"
      :class="[
        fontSizeSet,
        'popover-area custom-content-popover',
      ]"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <v-ons-row class="custom-ons-row custom-col-header">
        <v-ons-col class="custom-search-input">
          <v-ons-input v-model="dataSearch"></v-ons-input>
        </v-ons-col>
        <v-ons-col class="custom-ons-button">
          <v-ons-button class="btn3-normal" @click="searchData(dataSearch)">検索</v-ons-button>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="custom-ons-row">
        <div class="grid">
          <table style="position: relative" class="ntss-list custom-ntss-list">
            <thead>
              <tr>
                <th class="ntss-list-header-th-sticky custom-header-width-40">
                  患者ID
                </th>
                <th class="ntss-list-header-th-sticky custom-header-width-60">
                  患者名
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(pat, popIndex) in popPatList"
                :key="`pat_${popIndex}`"
                class="ntss-list-body-tr"
                @click.prevent.stop="setSelectedPat(pat.pat_id)"
              >
                <td class="ntss-list-body-td">{{ pat.hosp_pat_id }}</td>
                <!-- add 入院・同姓同名配布 趙 start -->
                <!-- <td class="ntss-list-body-td">{{pat.pat_last_name}} {{pat.pat_first_name}}</td> -->
                <td
                  :class="
                    pat.in_out_class === 1
                      ? 'pat-name-in-hospital'
                      : 'ntss-list-body-td'
                  "
                >
                  {{ pat.pat_last_name }} {{ pat.pat_first_name }}
                  <img
                    v-if="pat.is_same === '1'"
                    class="same-icon"
                    :src="image_src_same"
                  />
                </td>
                <!-- add 入院・同姓同名配布 趙 end -->
              </tr>
            </tbody>
          </table>
        </div>
      </v-ons-row>
    </v-ons-popover>

    <v-ons-modal :visible="isLoadingBbs">
      <p class="loading-modal">
        {{ message }}
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
  </div>
</template>

<script>
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { updateBbsList } from "@/functions/BbsInfoFunctions.js";
import PopoverMixin from "@/components/PopoverMixin";
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
import { PAGE_SIZE } from "@/constants/PageableConstant";
// 機能コード
import {
  FUNC_BBS_INFO,
  FUNC_BBS_INFO_JPN_NAME,
  FUNC_OBSERVE_RECORD,
  FUNC_OBSERVE_RECORD_JPN_NAME,
} from "@/constants/function-code.js";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { getFunctionCd } from "@/router/routing-helper";
// add FNSI-改修内容 権限関連 趙立強 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-改修内容 権限関連 趙立強 end
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
import { getSortedClass, addPatNameSortToList, sortableCompare } from "@/functions/SortFunctions";
import nameDuplicationImg from "../../assets/name_duplication.png";

// 個人設定
const uriUser = "/user/get_by_id";
// add 入院・同姓同名配布 趙 start
// 同姓同名患者
const uriIsSame = `/bbsInfo/getPatIsSame`;
// add 入院・同姓同名配布 趙 end
// 患者情報
const uriPat = `/patInfo/getPatByIdList`;

// ラジオボタン選択肢
const INDIVIDUALLY_USER = "0";
const ALL_USER = "1";
const NOT_USER = "2";

// 遷移先コード、名称一覧
const ROUTER_LIST = [
  // 患者統合経過ビューア
  { routerName: "pat-viewer", description: "患者経過総合ビューア" },
  // 治療記録
  { routerName: "treatment-record", description: "治療記録" },
  // 患者情報
  { routerName: "pat-info", description: "患者情報" },
  // スケジュール表
  { routerName: "schedule-list", description: "スケジュール表" },
  // 観察記録
  { routerName: "observe-record", description: "観察記録" },
  // 検査結果
  { routerName: "exam-record", description: "検査結果" },
  // add FutreNetWeb+SI課題管理No4114対応 趙 start
  // 検査結果
  { routerName: "exam-record-detail", description: "検査結果" },
  // add FutreNetWeb+SI課題管理No4114対応 趙 end
  // 患者イベント
  { routerName: "pat-event", description: "患者イベント" },
];

export default {
  // mod FNSI-改修内容 権限関連 趙立強 start
  // mixins: [PopoverMixin, UserAuthorityMixin],
  mixins: [PopoverMixin, UserAuthorityMixin, ComponentGuardMixin],
  // mod FNSI-改修内容 権限関連 趙立強 end

  data() {
    return {
      // 一覧表示項目
      displayItem: [
        {
          itemKey: "func_cd",
          itemName: "カテゴリ",
          width: `${10}%`,
          minWidth: `${80}px`,
        },
        {
          itemKey: "pat_info",
          itemName: "患者名",
          width: `${15}%`,
          minWidth: `${80}px`,
        },
        {
          itemKey: "content",
          itemName: "内容",
          // delete FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 start
          // width: `${55}%`,
          // delete FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 end
          // add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 start
          width: `${40}%`,
          // add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 end
          minWidth: `${16}em`
        },
        // add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 start
        {
          itemKey: "notice_date",
          itemName: "掲載期間",
          width: `${15}%`,
          minWidth: `${100}px`,
        },
        // add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 end
        {
          itemKey: "read_state",
          itemName: "既読 / 未読",
          width: `${120}px`,
          minWidth: `${100}px`,
        },
        {
          itemKey: "transition_router_path",
          itemName: "画面遷移",
          width: "auto",
          minWidth: `${90}px`,
        },
      ],

      // リロード
      isLoadingBbs: false,

      // 選択された遷移先パス
      selectedRouterPath: null,

      // 吹き出し表示フラグ
      popoverVisible: false,
      // 吹き出し位置※左右
      popoverTarget: null,

      // 吹き出し用患者名リスト
      popPatList: [],

      // DB利用者マスタ
      settingBbs: { sort_column: null, sort_kind: null },

      settingBbsCd: null,

      isNotEdited: true,

      message: null,

      isReadButton: true,

      tempDataTable: null,

      dataSearch: null,

      // add 入院・同姓同名配布 趙 start
      image_src_same: nameDuplicationImg,
      // add 入院・同姓同名配布 趙 end

      // add FNSI-改修内容 権限関連 趙立強 start
      hasTreatmentRecordAuthority: false,
      authorityCds: [AUTHORITY_CODES.SCHE_MOVE],
      // add FNSI-改修内容 権限関連 趙立強 end
      onIsNotEdited: null
    };
  },

  computed: {
    ...mapGetters("bbs-info", [
      "searchedBbsList",
      "userId",
      "userName",
      "isOnlyUnread",
      "searchedKeepBbsList",
      "selectedCondition",
      "selectCreatedBbs",
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      "isNotRun",
      // "mstBbsKindAll",
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      "isInitialDisp",
    ]),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      dispUserId: "getDispUserId",
    }),
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo"
    ]),

    /**
     * @description 掲示板一覧並び替え結果
     */
    sort() {
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      if (this.sortColumn != "pat_info") {
        // 患者名以外はBbsInfoDao.selectByIdListsqlでソート
        return this.searchedKeepBbsList;
      }
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end

      // 患者名ソート
      return this.getSortKind(this.setSortPat());
    },

    /**
     * @description 並び替え対象項目列
     */
    sortColumn() {
      return this.settingBbs.sort_column;
    },

    /**
     * @description 並び順種類
     */
    sortKind() {
      return this.settingBbs.sort_kind;
    },

    /**
     * @description 掲示板一覧絞り込み結果
     * @summary 全てor未読のみ
     */
    searchedResults() {
      this.computedSearchedBbsList();
      return this.searchedBbsList;
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
  },

  watch: {
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    searchedKeepBbsList() {
      if (this.selectedCondition.limitFrom == 0 && this.$refs.ntssList) {
        this.$refs.ntssList.scrollTop = 0;
      }
    },
    /**
     * @description 吹き出し患者数クリア
     * @summary height(患者数)が確定後、吹き出しを表示する。
     * 確定してないと吹き出し位置が変わる
     */
    popoverVisible(value) {
      if (!value) {
        // 吹き出しを閉じる度にクリア
        this.popPatList = [];
      }
    },

    /**
     * @description 並び順個人設定保存処理
     */
    settingBbs: {
      async handler() {
        if (this.settingBbsCd !== null) {
          // 個人設定が存在する場合
          const responseSettingBbs = await this.getPersonalSettings(
            this.settingBbsCd
          ).catch(() => {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage(
              "BbsInfoContent.vue",
              "settingBbs",
              "個人設定取得失敗"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            console.log(
              `API:"[PatBbsContent.vue]destroyed(): 個人設定取得失敗"`
            );
          });
          const saveSettingBbs = responseSettingBbs.data;
          saveSettingBbs.forEach((item) => {
            if (item.setting_identifier === "sort_column") {
              item.value = this.settingBbs.sort_column;
            } else if (item.setting_identifier === "sort_kind") {
              item.value = this.settingBbs.sort_kind;
            }
          });

          const param = {
            tab_define_cd: this.settingBbsCd,
            values: saveSettingBbs,
          };

          this.updatePersonalSettings(param).catch(() => {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage(
              "BbsInfoContent.vue",
              "settingBbs",
              "個人設定保存失敗"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            console.log(
              `API:"[PatBbsContent.vue]destroyed(): 個人設定保存失敗"`
            );
          });
        }
      },
      deep: true,
    },
  },

  async created() {
    //FNSI-修正 #5407 xugj add start
    // 共通ローダー:表示開始
    this.setLoadingScreenMessage("掲示一覧検索中...");
    this.setLoadingScreenVisible(true);
    //FNSI-修正 #5407 xugj add end
    // 検索条件初期表示設定実行可能へ
    this.setIsSelectedCondition(true);
    // ストアされているスタッフとサインイン中のスタッフが異なっているとき場合は掲示板一覧ストアをクリアする
    // しかしサインイン中のスタッフ取得APIの完了を待つ間一覧が見えてしまうので、先に一覧をクリアする
    // 異なっていればクリアしたままにし、同じスタッフなら一覧を元に戻す
    // add FNSI-改修内容 権限関連 趙立強 start
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // add FNSI-改修内容 権限関連 趙立強 end
    const keptBbs = this.searchedKeepBbsList;
    const ketpSearchCondition = this.selectedCondition;
    this.setSearchedKeepBbsList([]);

    // 掲示板詳細内容の編集有無を取得
    this.onIsNotEdited = (data) => {
      this.isNotEdited = data;
    };
    EventBus.$off("isNotEdited", this.onIsNotEdited);
    EventBus.$off("addNew", this.onAddNew);
    EventBus.$off("search", this.search);
    EventBus.$on("isNotEdited", this.onIsNotEdited);
    EventBus.$on("addNew", this.onAddNew);
    EventBus.$on("search", this.search);

    // 既未読状態を一覧に表示するため、ログインユーザーと掲示板登録情報を紐づける
    const userId = this.getStateUserAccountInfo.userId;
    if (!this.isInitialDisp && userId === this.userId) {
      // ※検索条件初期表示設定実行不可能へ
      this.setIsSelectedCondition(true);
      // サインイン中のスタッフがストアと変わりないなら一覧を復元
      this.setSearchedKeepBbsList(keptBbs);
      this.setSelectedCondition(ketpSearchCondition);
    } else {
      this.setIsInitialDisp(false);
    }

    // 掲示板一覧画面同様、詳細画面でもログインユーザーと掲示板登録情報を紐づけるためstoreに格納
    this.setUserId(userId);

    const userIdList = [userId];
    const responseUserName = await ApiHelper.post(
      "/mstInfo/mstPersonalUserByIdList",
      userIdList
    );
    if (responseUserName && responseUserName.data && responseUserName.data.length > 0) {
      this.setUserName(responseUserName.data[0].userName);
    }

    // 個人設定取得
    this.setUserSettings();

    // this.mstBbsKind = responseBbsKind.data;

    /* add by chamaojia 2023-04-23 [8558] ページ初期化クエリは最初のエントリから開始する必要があります --start */
    this.selectedCondition.limitFrom = 0;
    /* add by chamaojia 2023-04-23 [8558] ページ初期化クエリは最初のエントリから開始する必要があります --end */

    // 検索条件のソート条件をdataプロパティにセット ※正しいソートマークを表示
    this.settingBbs.sort_column = this.selectedCondition.sortColumn || null;
    this.settingBbs.sort_kind = this.selectedCondition.sortKind || null;

    // this.patInfoList = responsePat.data;
    // // add 入院・同姓同名配布 趙 start
    // this.patIsSameList = responseIsSame.data;
    // // add 入院・同姓同名配布 趙 end
    // this.sortPat(this.patInfoList);
    //FNSI-修正 #5407 xugj add start
    this.setLoadingScreenVisible(false);
    //FNSI-修正 #5407 xugj add end
  },

  beforeUnmount() {
    EventBus.$off("isNotEdited", this.onIsNotEdited);
    EventBus.$off("addNew", this.onAddNew);
    EventBus.$off("search", this.search);
    this.setSelectCreatedBbs(null);
    // dataの初期化
    Object.assign(this.$data, this.$options.data.call(this))
  },

  methods: {
     //add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz start
     ...mapActions("schedule-list", {
      setDispUserTime: "setDispUserTime",
    }),
    ...mapActions("bbs-info", [
      "setSelectedBbs",
      "setIsLoadingBbs",
      "setUserId",
      "setUserName",
      "setSearchedBbsList",
      "setSelectedBbsInfo",
      "setSearchedKeepBbsList",
      "setSelectedCondition",
      "setIsSelectedCondition",
      "setSearchedList",
      "setSelectCreatedBbs",
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      "setSortColumn",
      "setSortKind",
      "setIsNotRun",
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      "setIsInitialDisp",
      "setRegFuncClass",
      "setHTMLContent",
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    //FNSI-修正 #5407 xugj add start
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      executeWithLoadingScreen: "executeWithLoadingScreen"
    }),
    //FNSI-修正 #5407 xugj add end
    ...mapMutations("pat-info", {
      setPat: "setSelectedPat",
      setIsLoadingPat: "setIsLoadingPat",
    }),
    ...mapActions("personal-setting", [
      "getPersonalSettings",
      "updatePersonalSettings",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    splitContent(value) {
      const s = value.split("\n");
      return s;
    },
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz end
    onAddNew(data) {
      if (data) {
        this.search();
      }
    },
    /**
     * @description 既読未読状態
     * @param { Object } staffInfo スタッフ情報
     * @returns { String }
     */
    getReadState(read) {
      // スタッフ情報から自身の情報を取得し、状態(既読or未読or対象外)を返す
      if (_.isEmpty(read)) {
        // スタッフ情報がない
        this.isReadButton = true;
        return "未読";
      }
      const readState = read.find((item) => item === this.userId);
      if (readState === undefined) {
        // スタッフ情報に自身が存在しない
        this.isReadButton = true;
        return "未読";
      }
      // 「未読: "0"」,「 既読: "1"」
      if (readState.length !== 0) {
        this.isReadButton = true;
      } else {
        this.isReadButton = false;
      }
      return readState.length === 0 ? "未読" : "既読";
    },

    /**
     * @description 遷移先画面名称取得
     * @param { String } routerPath 遷移先ルートパス
     * @returns { String }
     */
    getRouterName(routerPath) {
      if (routerPath === null) {
        return null;
      }
      // 遷移先一覧からルートパスに一致した名称を返す
      return ROUTER_LIST.find((record) => record.routerName === routerPath)?.description;
    },

    /**
     * @description 掲示板詳細画面遷移
     * @param { Object } bbsInfo 掲示板情報
     */
    transitionBbsDetailed(bbsInfo) {
      this.selectedRouterPath = "bbs-detailed-info";
      // 登録元機能の設定
      this.setRegFuncClass(bbsInfo.reg_func_class);
      // HTMLContentの設定
      this.setHTMLContent(bbsInfo.html_content);
      // 未編集の場合
      if (this.isNotEdited) {
        // 選択した掲示板の情報を設定する
        this.setBbsInfo(bbsInfo.bbs_ctl_no);
        // 掲示板詳細情報画面遷移へ
        this.transitionScreen();
      } else {
        this.confirmEdite(bbsInfo);
      }
    },

    /**
     * @description 画面遷移
     * @param { Object } patInfo 患者情報
     * @param { Object } event 吹き出し表示位置
     * @param { String } routerPath 遷移先パス
     */
    // mod 7936 掲示板に連携通知がコンバートされていない 関 start
    // transition(patInfo, event, routerPath) {
    // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
    async transition(patInfo, event, routerPath, noticeEndDate, noticeStartDate, bbs_ctl_no) {
      // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end
    // mod 7936 掲示板に連携通知がコンバートされていない 関  end
      // 移動する画面の機能コードを取得する
      const functionCd = getFunctionCd(routerPath);
      // 権限チェックを行う
      if (!this.hasNextAuthority(functionCd)) {
        return true;
      }
      // del #10359、#10331 編集権限について、対応する。 dengshen start
      // // add FNSI-改修内容 権限関連 趙立強 start
      // if (!this.hasTreatmentRecordAuthority) {
      //   return true;
      // }
      // // add FNSI-改修内容 権限関連 趙立強 start
      // del #10359、#10331 編集権限について、対応する。 dengshen end
      // mod FutreNetWeb+SI課題管理No4114対応 趙 start
      if (
        patInfo.target === INDIVIDUALLY_USER &&
        patInfo.detail.length >= 1 &&
        routerPath === "exam-record"
      ) {
        this.selectedRouterPath = "exam-record-detail";
      } else {
        this.selectedRouterPath = routerPath;
        // add 7936 掲示板に連携通知がコンバートされていない 関 start
        this.noticeStartDate = noticeEndDate;
        this.noticeEndDate = noticeStartDate;
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
        this.bbsCtlNo = bbs_ctl_no;
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
        // add 7936 掲示板に連携通知がコンバートされていない 関  end
      }
      // mod FutreNetWeb+SI課題管理No4114対応 趙 end
      if (
        patInfo.target === ALL_USER ||
        (patInfo.target === INDIVIDUALLY_USER && patInfo.detail.length > 1)
      ) {
        let patIds = [];
        // 全患者または個別選択かつ複数なら患者を選択
        if (patInfo.target !== ALL_USER) {
          patIds = patInfo.detail.map(item => item.pat_id);
        }

        const responsePat = await ApiHelper.post(
          uriPat,
          patIds
        ).catch(() => {
          getErrorMessage("BbsInfoContent.vue", uriPat, "DB取得失敗");
        });;

        let patList = responsePat.data;
        this.sortPat(patList);
        // mod FutreNetWeb+SI課題管理No4114対応 趙 start
        // this.showPopover(patList, event);
        // mod FutreNetWeb+SI課題管理No4116対応 趙 start
        // if (patInfo.target === ALL_USER && routerPath === "exam-record"){
        if (
          (patInfo.target === ALL_USER && routerPath === "exam-record") ||
          routerPath === "schedule-list"
        ) {
          // mod FutreNetWeb+SI課題管理No4116対応 趙 end
          this.transitionScreen();
        } else {
          this.showPopover(patList, event);
        }
        // mod FutreNetWeb+SI課題管理No4114対応 趙 end
      } else {
        // 患者なし未選択へ
        let patId = null;
        if (patInfo.detail.length === 1) {
          // 患者1人
          patId = patInfo.detail[0].pat_id;
        }
        this.setSelectedPat(patId);
      }
    },

    /**
     * @description 吹き出し表示(画面遷移前の患者選択用)
     */
    showPopover(patInfoDetail, event) {
      // 吹き出し表示位置
      this.popPatList = patInfoDetail;
      this.tempDataTable = patInfoDetail;
      this.dataSearch = null;
      this.popoverTarget = event.target;
      // 吹き出し表示
      this.popoverVisible = true;
    },

    confirmEdite(bbsInfo) {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "内容破棄",
        title: DIALOG_MESSAGES[13000004].title,
        // message: "編集内容が破棄されます。</br>よろしいですか？",
         message: messageFormat(DIALOG_MESSAGES[13000004].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: (answer) => {
          if (answer === 1) {
            // 選択した掲示板の情報を設定する
            this.setBbsInfo(bbsInfo.bbs_ctl_no);
          }
        },
      });
    },

    /**
     * @description 画面遷移
     */
    transitionScreen() {
      // 選択した画面へ遷移する
      if (this.selectedRouterPath !== null) {
        //add 9272 by kangjie 20231121 start
        if (this.selectedRouterPath === "exam-record-detail") {
          this.$router.push({
            name: "exam-record"
          })
        }
        //add 9272 by kangjie 20231121 end
        // mod 7936 掲示板に連携通知がコンバートされていない 関 start
        // this.$router.push({ name: this.selectedRouterPath });
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
        //add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz start
        this.setDispUserTime(this.noticeStartDate);
        //add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz end
        this.$router.push({
          name: this.selectedRouterPath,
          params: {startDate: this.noticeStartDate, endDate: this.noticeEndDate, bbsCtlNoFr: this.bbsCtlNo}
        });
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
        // mod 7936 掲示板に連携通知がコンバートされていない 関  end
        this.popoverTarget = null;
      }
    },

    /**
     * @description 患者選択
     * @summary 選択した患者の患者情報レコードをストアに格納する
     */
    async setSelectedPat(selectedPatId) {
      this.setIsLoadingPat(true);
      this.setPat(null);
      if (selectedPatId !== null) {
        await this.selectPat(selectedPatId).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage(
            "BbsInfoContent.vue",
            "setSelectedPat",
            "患者選択失敗"
          );
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw new Error("[BbsInfoContent.vue]setSelectedPat(): 患者選択失敗");
        });
      }
      this.setIsLoadingPat(false);

      this.transitionScreen();
    },

    /**
     * @description 選択した掲示板情報を詳細画面へ設定
     * @param { Number } bbs_ctl_no 掲示板番号
     */
    async setBbsInfo(bbsCtlNo) {
      // 選択した掲示板番号の詳細情報を設定
      await this.setSelectedBbsInfo(bbsCtlNo);
    },

    /**
     * @description 掲示板一覧から未読のみに絞り込み
     * @param { Array } bbslist 掲示板一覧
     * @returns { Array } 未読のみの掲示板一覧
     */
    getBbsListOnlyUnread(bbslist) {
      return bbslist.filter((bbs) => {
        let userInfo = undefined;
        if (!_.isEmpty(bbs.staff_info.read)) {
          // 各記事のスタッフ情報に自身があるか判定
          userInfo = bbs.staff_info.read.find((staff) => staff === this.userId);
        }

        if (userInfo === undefined) {
          // 情報がなければ(対象外)一覧に表示
          return bbs;
        } else {
          // 自身が未読なら一覧に表示
          return userInfo.read_state === "0";
        }
      });
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      const sort = {
        key: this.sortKind === "normal" ? "" : this.sortColumn,
        isAsc: this.sortKind === "asc"
      }
      return getSortedClass(key, sort);
    },
    /**
     * @description ソート対象列・順序種類設定
     * @param { any } sortColumn ソート対象項目列キー
     */
    // delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    // setSortKind(sortColumn) {
    // delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    setSort(sortColumn) {
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      if (this.sortColumn === sortColumn) {
        // 同じ列をソート対象の場合、順序のみを変更
        switch (this.sortKind) {
          case "normal":
            this.settingBbs.sort_kind = "asc";
            break;
          case "asc":
            this.settingBbs.sort_kind = "desc";
            break;
          case "desc":
            this.settingBbs.sort_kind = "normal";
            break;

          default:
            this.settingBbs.sort_kind = "normal";
            break;
        }
      } else {
        // 別の列をソート対象の場合、対象列と順序(昇順)を設定
        this.settingBbs.sort_column = sortColumn;
        this.settingBbs.sort_kind = "asc";
      }
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      this.setSortColumn(this.settingBbs.sort_column);
      this.setSortKind(this.settingBbs.sort_kind);
      this.sortByCol();
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    },

    /**
     * @description 患者名ソート用に編集した掲示板一覧(第2ソート)
     * @returns { Array }
     */
    setSortPat() {
      // ソート用に編集するため、オリジナルに影響を与えないようディープコピー
      const sortList = this.searchedKeepBbsList.map((item) => ({ ...item }));
      // 事前に五十音順で第1ソートを行う
      const sortedBbs = this.sortName(sortList);
      // 優先順位：なし、全患者, 個別患者
      const condition = [ NOT_USER, ALL_USER, INDIVIDUALLY_USER ];
      // ソートの順序(優先順位)を取得
      for (const bbs of sortedBbs) {
        const index = condition.indexOf(bbs.pat_info.target);
        bbs.index = index;
      }

      return sortList;
    },

    /**
     * @description 第1ソート：患者数、第2ソート：システム共通患者名ソート※1人目の患者名でソート
     * @param { Object } bbsInfoList ソート対象
     * @returns { Array }
     */
    sortName(bbsInfoList) {
      if (this.sortKind === "normal") {
        return bbsInfoList;
      }

      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      bbsInfoList.forEach(bbs => {
        if (Array.isArray(bbs.pat_info.detail)) {
          bbs.pat_info.detail = addPatNameSortToList(bbs.pat_info.detail);
        }
      });

      const isAsc = this.sortKind === "asc";
      bbsInfoList.sort((a, b) => {
        // 患者なしは前へ
        const patA = a.pat_info.detail[0];
        const patB = b.pat_info.detail[0];
        if (!patA && !patB) return 0;
        if (!patA) return -1;
        if (!patB) return 1;

        // 患者数の比較（昇順／降順）
        const lenA = a.pat_info.detail.length;
        const lenB = b.pat_info.detail.length;
        if (lenA !== lenB) {
          return isAsc ? lenA - lenB : lenB - lenA;
        }

        // 患者数が同じ場合、患者名(ソート用文字列)で比較
        return sortableCompare(patA, patB, "patNameSort", isAsc);
      });
      return bbsInfoList;
    },

    /**
     * @description ソート昇降順設定
     * @param { Object } bbsInfoList ソート対象
     * @returns { Array }
     */
    getSortKind(sortData) {
      const sortBbsList = sortData.sort((a, b) => {
        if (this.sortKind === "asc") {
          // 昇順
          return a.index - b.index;
        } else if (this.sortKind === "desc") {
          // 降順
          return b.index - a.index;
        }
      });
      // 登録順
      return sortBbsList;
    },

    /**
     * @description 既読未読状態変更
     * @param { Object } staffInfo スタッフ情報
     * @returns { Array }
     */
    confirmChangeState(bbsCtlNo, staffInfo) {
      if (this.isNotEdited) {
        this.changeState(bbsCtlNo, staffInfo);
      } else {
        this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "内容破棄",
        title: DIALOG_MESSAGES[13000004].title,
        // message: "編集内容が破棄されます。</br>よろしいですか？",
         message: messageFormat(DIALOG_MESSAGES[13000004].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: (answer) => {
            if (answer === 1) {
              this.changeState(bbsCtlNo, staffInfo);
            }
          },
        });
      }
    },

    /**
     * @description 既読未読状態変更
     * @param { Object } staffInfo スタッフ情報
     * @returns { Array }
     */
    async changeState(bbsCtlNo, staffInfo) {
      this.message = "掲示板情報を保存しています";
      this.isLoadingBbs = true;
      if (
        this.selectCreatedBbs &&
        this.selectCreatedBbs.bbs_ctl_no === bbsCtlNo
      ) {
        const bbsInfo = this.searchedKeepBbsList.find(
          (b) => b.bbs_ctl_no === this.selectCreatedBbs.bbs_ctl_no
        );

        if (bbsInfo) {
          staffInfo = bbsInfo.staff_info;
        }
      }
      this.setSelectCreatedBbs(null);

      const hasUserId = staffInfo.read.findIndex(
        (staffInfo) => staffInfo === this.userId
      );

      if (hasUserId === -1) {
        // スタッフ情報が存在しない
        staffInfo.read.push(this.userId);
      } else {
        staffInfo.read.splice(hasUserId, 1);
      }

      // 更新日時
      const nowDate = dayjs().format();
      // DB更新
      await updateBbsList(
        [{ bbs_ctl_no: bbsCtlNo, staff_info: staffInfo }],
        this.userId,
        this.userName,
        nowDate
      );
      // 編集内容を詳細画面へ反映
      this.setBbsInfo(bbsCtlNo);

      this.isLoadingBbs = false;
    },

    getPatName(array) {
      let patNameList = array
        .filter((pat) => !!pat)
        // mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start
        //.map((pat) => `${pat.pat_last_name} ${pat.pat_first_name}`);
        .map((pat) => `${pat.pat_last_name== null ? "" : pat.pat_last_name} ${pat.pat_first_name== null ? "" : pat.pat_first_name}`);
        // mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end
      const maxPatDispNumber = 3;
      if (patNameList.length >= maxPatDispNumber) {
        // 患者が3人以上なら「他◯人」表示へ
        const allPatNumber = patNameList.length;
        const dispPatNumber = 2;
        const otherPatNumber = allPatNumber - dispPatNumber;
        patNameList = [patNameList[0], patNameList[1], `他${otherPatNumber}人`];
      }
      return patNameList;
    },

    async setUserSettings() {
      // 掲示板一覧の並び替え用に個人設定を取得
      const responseUser = await ApiHelper.get(
        `${uriUser}/${this.userId}`
      ).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage("BbsInfoContent.vue", "setSelectedPat", "DB取得失敗");
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log(`API:"[PatBbsContent.vue]created(): DB取得失敗");
      });
      // 個人設定から並び順を取得
      const userSettings = responseUser.data.userAccountInfo.userSettings;
      if (
        Object.prototype.hasOwnProperty.call(userSettings, "personal_settings") &&
        userSettings.personal_settings.length !== 0) {
        // 個人設定存在する場合
        const settings = userSettings.personal_settings;
        const settingBbsItem = [
          "auto_read",
          "search_category",
          "sort_column",
          "sort_kind",
        ];

        const personalSettingsBbs = settings.find((setting) => {
          const bbsItems = setting.values.filter((item) =>
            settingBbsItem.includes(item.setting_identifier)
          );
          return bbsItems.length === 4;
        });

        if (personalSettingsBbs !== undefined) {
          // 掲示板の個人設定があれば参照のちに保存
          this.settingBbsCd = personalSettingsBbs.tab_define_cd;
          const settingBbsList = personalSettingsBbs.values;

          settingBbsList.forEach((item) => {
            if (item.setting_identifier === "sort_column") {
              this.settingBbs.sort_column = item.value;
            } else if (item.setting_identifier === "sort_kind") {
              this.settingBbs.sort_kind = item.value;
            }
          });
        }
      }
    },

    /**
     * @description 患者名ソート
     * @param {Array} patList
     */
    sortPat(patList) {
      patList.sort((a, b) => {
        let nameA, nameB;
        if (a.pat_first_name_kana) {
          // フリガナがあればフリガナ氏名でソート
          nameA = `${a.pat_last_name_kana}${
            a.pat_first_name_kana ? a.pat_first_name_kana : ""
          }`;
        } else {
          // なければ氏名
          nameA = `${a.pat_last_name}${a.pat_first_name}`;
        }

        if (b.pat_first_name_kana) {
          nameB = `${b.pat_last_name_kana}${
            b.pat_first_name_kana ? b.pat_first_name_kana : ""
          }`;
        } else {
          nameB = `${b.pat_last_name}${b.pat_first_name}`;
        }

        if (nameA === nameB) {
          return 0;
        }
        if (nameA < nameB) {
          return -1;
        }
        return 1;
      });
    },

    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    /**
     * @description 掲示板一覧並び替え結果
     */
    async sortByCol() {

      this.executeWithLoadingScreen(async () => { // 共通ローダ表示

        this.selectedCondition.limitFrom = 0;
        this.selectedCondition.limitTo = PAGE_SIZE;
        if (this.isOnlyUnread) {
          // 未読のみフラグON
          this.selectedCondition.userId = this.userId;
        } else {
          this.selectedCondition.userId = null;
        }
        let sortTmp = this.sortKind;
        if (sortTmp != "normal") {
          this.selectedCondition.sortColumn = this.sortColumn;
          this.selectedCondition.sortKind = sortTmp;
        } else {
          this.selectedCondition.sortColumn = null;
          this.selectedCondition.sortKind = null;
        }
        this.setSelectedCondition(this.selectedCondition);

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
          facilityCd: this.facilityCd,
        });
        this.computedSearchedBbsList();
        this.setIsNotRun(true);
      });
    },
    /**
     * @description 検索結果の掲示板をstoreに設定
     * @param { Array } bbsInfoList 掲示板一覧
     * @returns { void }
     */
    computedSearchedBbsList() {
      let bbsInfoList;
      if (this.isOnlyUnread) {
        // 未読のみフラグON
        bbsInfoList = this.getBbsListOnlyUnread(this.sort);
        if (this.selectCreatedBbs) {
          // add FNSI-改修内容 掲示板バグ1 dou start
          if (this.sort.length > 0) {
            let sortFilter = this.sort.filter(
              (x) => x.bbs_ctl_no == this.selectCreatedBbs.bbs_ctl_no
            );
            if (sortFilter.length > 0) {
              let newBbs = this.selectCreatedBbs;
              newBbs.pat_info = sortFilter[0].pat_info;
              this.setSearchedBbsList(newBbs);
            }
          }
          // add FNSI-改修内容 掲示板バグ1 dou end
          // del  FNSI redmine 6185修正 関 start
          // bbsInfoList.push(this.selectCreatedBbs);
          // del  FNSI redmine 6185修正 関　end
        }
      } else {
        // 検索結果全て
        bbsInfoList = this.sort;
      }
      // 詳細画面スワイプで使用するため、storeに設定
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      if (this.selectedCondition.sortColumn == "pat_info") {
        bbsInfoList = this.getSortKind(this.setSortPat()).slice(
          0,
          this.selectedCondition.limitFrom + this.selectedCondition.limitTo
        );
        let keptBbs = this.searchedKeepBbsList;
        keptBbs = keptBbs.slice(
          0,
          this.selectedCondition.limitFrom + this.selectedCondition.limitTo
        );
        this.setSearchedKeepBbsList(keptBbs);
        // add 掲示板外結No20対応 趙 start
        if (this.isOnlyUnread) {
          bbsInfoList = this.getBbsListOnlyUnread(bbsInfoList);
        }
        // add 掲示板外結No20対応 趙 end
      }
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      // add 掲示板外結No20対応 趙 start
      if (bbsInfoList != null && bbsInfoList.length != 0) {
        bbsInfoList[0].count = bbsInfoList.length;
      }
      // add 掲示板外結No20対応 趙 end
      this.setSearchedBbsList(bbsInfoList);
    },
    /**
     * @description スクロールイベント
     */
    async scrollHandler() {
      const e = this.$refs.ntssList;
      const isScrolledBottom =
        Math.abs(e.scrollTop + e.clientHeight - e.scrollHeight) < 4;
      if (isScrolledBottom && this.isNotRun) {
        this.setIsNotRun(false);
        this.selectedCondition.limitFrom = this.searchedKeepBbsList.length;
        this.selectedCondition.limitTo = PAGE_SIZE;
        if (this.isOnlyUnread) {
          // 未読のみフラグON
          this.selectedCondition.userId = this.userId;
        } else {
          this.selectedCondition.userId = null;
        }
        let sortTmp = this.sortKind;
        if (sortTmp != "normal") {
          this.selectedCondition.sortColumn = this.sortColumn;
          this.selectedCondition.sortKind = sortTmp;
        } else {
          this.selectedCondition.sortColumn = null;
          this.selectedCondition.sortKind = null;
        }
        this.setSelectedCondition(this.selectedCondition);

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
          facilityCd: this.facilityCd,
        });
        this.computedSearchedBbsList();
        this.setIsNotRun(true);
      }
    },
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end

    /**
     * @description 検索
     */
    async search() {
      this.message = "掲示一覧検索中...";
      this.isLoadingBbs = true;
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
        facilityCd: this.facilityCd,
      });
      this.computedSearchedBbsList();
      this.isLoadingBbs = false;
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      this.setIsNotRun(true);
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    },
    /**
     * @description 検索用に変更
     */
    formattedDate(date) {
      return date === null || date === ""
        ? null
        : dayjs(date).format("YYYYMMDD");
    },

    searchData(inputData) {
      this.popPatList = this.tempDataTable;
      const textSearchInput = inputData && inputData.toString().trim();
      if (textSearchInput) {
        this.popPatList = this.popPatList.filter((item) =>
          `${item.hosp_pat_id} ${item.pat_last_name} ${item.pat_first_name}`
            .toLowerCase()
            .includes(textSearchInput.toLowerCase())
        );
      }
    },
    // add FNSI-改修内容 権限関連 趙立強 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    // add FNSI-改修内容 権限関連 趙立強 end
  },
};
</script>

<style scoped>
.ntss-list-header-th-sticky {
  /* ESLint機能で行われる改行分が表示内容の余白として画面反映するため */
  white-space: normal;
}

.loading-modal {
  text-align: center;
  font-size: 30px;
}

.button-area {
  width: 6em;
  height: 2em;
  position: initial;
}

.ntss-button-read {
  background-color: #dddddd;
  color: #808080;
  border-radius: 1em;
  background-image: linear-gradient(#fdfcfc 0%,#e0e0e0 50%,#e0e0e0 50%,#d2d2d2 100%);
  box-shadow: unset;
}

.ntss-button-un-read {
  background-color: #3cb371;
  color: #ffffff;
  border-radius: 1em;
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  border-bottom: solid 3px var(--btn-common-border-color);
  box-shadow: unset;
}

.content-area {
  word-break: break-all;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
  overflow: hidden;
}

.pat-name-area {
  margin: 2px;
  text-align: left;
}

.custom-header-width-40 {
  flex: 0 0 40%;
  width: 40%;
}

.custom-header-width-60 {
  flex: 0 0 60%;
  width: 60%;
}

.custom-content-popover .custom-ons-row {
  height: auto;
}

.custom-ons-button :deep(.button) {
  font-size: 1.5em;
}

.main-content-area table td {
  padding: 2px 8px;
}

.custom-ons-row:last-of-type {
  margin-top: 7px;
}

.grid {
  overflow: auto;
  width: 100%;
}

.custom-content-popover .custom-ons-row {
  height: auto;
}

.custom-content-popover :deep(.popover__content) {
  width: 450px;
  height: 350px;
  padding: 7px;
  z-index: 20002;
}

.custom-ntss-list {
  overflow: auto;
  word-break: break-all;
}

.custom-ntss-list .ntss-list-body-td,
.custom-ntss-list .ntss-list-header-th-sticky {
  word-break: break-all;
}

.custom-col-header .custom-search-input {
  max-width: 66.5%;
  flex: 0 0 66.5%;
}

.custom-col-header .custom-ons-button {
  max-width: 31.7%;
  flex: 0 0 31.7%;
  margin-left: 7px;
}

@media screen and (min-height:700px) {
  .custom-content-popover :deep(.popover__content) {
    max-height: 600px !important;
    height: 600px;
  }
}
@media screen and (max-width: 600px) {
  .custom-col-header .custom-search-input {
    max-width: 100%;
    flex: 0 0 100%;
  }

  .custom-col-header .custom-ons-button {
    max-width: 100%;
    flex: 0 0 100%;
    margin-left: 0;
    margin-top: 7px;
  }
  /* add FNSI-改修内容4193bug修正 関 start */
  .ntss-list-body-td-content,
  .ntss-list-body-td-kindname,
  .ntss-list-body-td-patname,
  .ntss-list-body-td-date,
  .ntss-list-body-td-path {
    white-space: nowrap;
  }
  /* add FNSI-改修内容4193bug修正 関 end */
}
/* add 入院・同姓同名配布 趙 start */
.pat-name-in-hospital {
  border: solid 1px var(--ntss-list-border-color);
  padding: 8px;
  color: #A356A3;
}
.same-icon {
  height: 1em;
  display: inline-block;
  margin-left: 0.5em;
}
/* add 入院・同姓同名配布 趙 end */
.manual-width {
  resize: horizontal;
  overflow-x: auto;
}
.clickable-header-label {
  display: block;
  width: 100%;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
}
@media print {
  /** 1枚に収める */
  .ntss-list {
    width: 100% !important;
  }
  .ntss-list-header-th-sticky {
    width: auto !important;
    min-width: 1% !important;
  }
}
</style>
