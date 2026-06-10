/**
 * デフォルト設定タブ - 掲示板設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable :expanded.sync="isExpanded">
      <div class="top"><!-- OnsenUI挙動制御：自動挿入されるラッパー用divを予め書いておき適用されるスタイルを制御 -->
        <div class="center card-header color-header">
          {{ funcName }}
        </div>
        <div class="right"><!-- OnsenUI挙動制御：空にすることで矢印を抑制 --></div>
      </div>
      <div class="expandable-content card-contents">
        <table>
          <tbody>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">カテゴリ</label>
              </td>
              <td class="default-setting-content">
                <kendo-multiselect
                  :data-source="mstBbsKind"
                  v-model="categoryKindList"
                  data-text-field="kindName"
                  data-value-field="kindNo"
                  :filter="'contains'"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">掲載日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstNoticeDate"
                  v-model="noticeDateType"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">治療日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDialysisDate"
                  v-model="dialysisDate"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">クール</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="mstKur"
                  v-model="kur"
                  data-text-field="name"
                  data-value-field="code"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">ベッドグループ・透析室</label>-->
                <label class="default-setting-content-label white-space-nowrap">ベッドグループ・透析室</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="mstRoomBedGroup"
                  v-model="bedGroupCd"
                  data-text-field="roomBedGroupName"
                  data-value-field="roomBedGroupCd"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">未読のみ</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="showOnlyUnread"></v-ons-switch>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

 <script>
   import {mapGetters, mapActions} from "vuex";
   import {BBS_INFO, DATE_CHOICES} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {ApiHelper} from "@/apis/AxiosHelper";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/eventBus.js";
   //add FNSI-5687 劉全航 end

   // 掲載日の選択肢
const NONE = "1";
const TODAY = "2";
const TODAY_TOMORROW = "3";
const THIS_WEEK = "4";
const WITHIN_ONE_WEEK = "5";
// URI
const uriKur = "/mstInfo/mst_kur/mstSelector";
const uriRoomBedGroup = "/mstInfo/mstRoomBedGroup";
const uriBbsKind = "/mstInfo/mstBbsKind";

export default {
  components: {
  },
  props: {
    // カード開閉初期状態
    defaultExpanded: {
      type: Boolean,
      default: true
    }
  },
  data() {
    // 治療日：未指定
    const unspecified = {
      title: "未指定",
      value: ""
    };
    return {
      // 対象の画面名
      funcName:"掲示板",
      // データ初期値
      initialValue: {},
      // 編集する掲示板設定レコード
      editRecord: {},
      // 掲載日・選択肢
      lstNoticeDate: [
        {
          title: "未指定",
          value: NONE
        },
        {
          title: "本日のみ",
          value: TODAY
        },
        {
          title: "本日+翌日",
          value: TODAY_TOMORROW
        },
        {
          title: "今週(本日週)",
          value: THIS_WEEK
        },
        {
          title: "本日+前後1週間",
          value: WITHIN_ONE_WEEK
        },
      ],
      // 治療日・選択肢
      lstDialysisDate: [
        unspecified,
        DATE_CHOICES.TODAY
      ],
      // 掲示板種別
      mstBbsKind: [],
      // クール
      mstKur: [],
      // ベッドグループ
      mstRoomBedGroup: [],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: BBS_INFO.KEY_NAME,
        data: {}
      };
      rtnData.data[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST] = this.editRecord[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST];
      rtnData.data[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE] = this.editRecord[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE];
      rtnData.data[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE];
      rtnData.data[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE];
      rtnData.data[BBS_INFO.KEY_NAME_DIALYSIS_DATE] = this.editRecord[BBS_INFO.KEY_NAME_DIALYSIS_DATE];
      rtnData.data[BBS_INFO.KEY_NAME_KUR] = this.editRecord[BBS_INFO.KEY_NAME_KUR];
      rtnData.data[BBS_INFO.KEY_NAME_BED_GROUP_CD] = this.editRecord[BBS_INFO.KEY_NAME_BED_GROUP_CD];
      rtnData.data[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD] = this.editRecord[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD];
      return rtnData;
    }
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    categoryKindList: {
      get() {
        return this.editRecord[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST];
      },
      set(value) {
        this.editRecord[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST] = value;
      }
    },
    noticeDateType: {
      get() {
        return this.editRecord[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE];
      },
      set(value) {
        this.editRecord[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE] = value;
        switch (value) {
          case NONE:
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = "";
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = "";
            break;
          case TODAY:
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = DATE_CHOICES.TODAY.value;
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = DATE_CHOICES.TODAY.value;
            break;
          case TODAY_TOMORROW:
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = DATE_CHOICES.TODAY.value;
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = DATE_CHOICES.TOMMOROW.value;
            break;
          case THIS_WEEK:
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = DATE_CHOICES.FIRSTDAY_OF_WEEK.value;
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = DATE_CHOICES.LASTDAY_OF_WEEK.value;
            break;
          case WITHIN_ONE_WEEK:
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = DATE_CHOICES.BEFORE_ONE_WEEK.value;
            this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = DATE_CHOICES.AFTER_ONE_WEEK.value;
            break;
          default:
            break;
        }
      }
    },
    dialysisDate: {
      get() {
        return this.editRecord[BBS_INFO.KEY_NAME_DIALYSIS_DATE];
      },
      set(value) {
        this.editRecord[BBS_INFO.KEY_NAME_DIALYSIS_DATE] = value;
      }
    },
    kur: {
      get() {
        return this.editRecord[BBS_INFO.KEY_NAME_KUR];
      },
      set(value) {
        this.editRecord[BBS_INFO.KEY_NAME_KUR] = value;
      }
    },
    bedGroupCd: {
      get() {
        return this.editRecord[BBS_INFO.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[BBS_INFO.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    showOnlyUnread: {
      get() {
        return this.editRecord[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD];
      },
      set(value) {
        this.editRecord[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD] = value;
      }
    },
  },
  watch: {
    //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "bbsInfo", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "bbsInfo", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST] = [];
    this.initialValue[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE] = TODAY;
    this.initialValue[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = DATE_CHOICES.TODAY.value; // 本日
    this.initialValue[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = DATE_CHOICES.TODAY.value; // 本日
    this.initialValue[BBS_INFO.KEY_NAME_DIALYSIS_DATE] = "";
    this.initialValue[BBS_INFO.KEY_NAME_KUR] = "";
    this.initialValue[BBS_INFO.KEY_NAME_BED_GROUP_CD] = "";
    this.initialValue[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD] = true;

    // 掲示板種別マスタ、クールマスタ、透析室・ベッドグループマスタを取得
    const [
      responseBbsKind,
      responseKur,
      responseRoomBedGroup
    ] = await Promise.all([
      ApiHelper.get(uriBbsKind, {
        facilityCd: this.getFacilityCd
      }),
      ApiHelper.get(uriKur, {
        facilityCd: this.getFacilityCd
      }),
      ApiHelper.get(uriRoomBedGroup, {
        facilityCd: this.getFacilityCd
      })
    ]);

    this.mstBbsKind = responseBbsKind.data;
    this.mstKur = responseKur.data?.orderSettings?.items || [];
    this.mstRoomBedGroup = responseRoomBedGroup.data;

    // マスタの選択肢に全てを追加
    const allSearchKur = { code: "", name: "すべて" };
    const allSearchRoomBedGroup = {
      roomBedGroupCd: "",
      roomBedGroupName: "すべて"
    };
    this.mstKur = [allSearchKur, ...this.mstKur];
    this.mstRoomBedGroup = [allSearchRoomBedGroup, ...this.mstRoomBedGroup];

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[BBS_INFO.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST] = this.initialValue[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST];
        }
        if (this.editRecord[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE] = this.initialValue[BBS_INFO.KEY_NAME_NOTICE_DATE_TYPE];
        }
        if (this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_NOTICE_START_DATE] = this.initialValue[BBS_INFO.KEY_NAME_NOTICE_START_DATE];
        }
        if (this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_NOTICE_END_DATE] = this.initialValue[BBS_INFO.KEY_NAME_NOTICE_END_DATE];
        }
        if (this.editRecord[BBS_INFO.KEY_NAME_DIALYSIS_DATE] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_DIALYSIS_DATE] = this.initialValue[BBS_INFO.KEY_NAME_DIALYSIS_DATE];
        }
        if (this.editRecord[BBS_INFO.KEY_NAME_KUR] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_KUR] = this.initialValue[BBS_INFO.KEY_NAME_KUR];
        }
        if (this.editRecord[BBS_INFO.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_BED_GROUP_CD] = this.initialValue[BBS_INFO.KEY_NAME_BED_GROUP_CD];
        }
        if (this.editRecord[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD] == null) {
          this.editRecord[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD] = this.initialValue[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
  mounted() {
  }
};
</script>

<style scoped>
</style>
