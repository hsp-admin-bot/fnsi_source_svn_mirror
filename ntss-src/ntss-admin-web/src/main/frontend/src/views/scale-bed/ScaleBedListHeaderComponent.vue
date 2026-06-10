/** * スケールベッド測定画面（ヘッド画面） MainContent */
<template>
  <div class="header-item">
    <v-ons-row class="mark-leftmost-header">
      <v-ons-col vertical-align="center" width="100%"> </v-ons-col>
      <v-ons-col width="40%" style="height: 100%">
        <common-searcharea
          :conditionList="conditionList"
          @show-popover="showPopover($event)"
        />
      </v-ons-col>
    </v-ons-row>
    <!--  抽出ダイアログ[始]  -->
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="
        dialogClosed();
        popoverPosthide($event);
      "
    >
      <div id="popover" class="fab-font-color">
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>ベッドグループ</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select
              style="width: 100%"
              v-model="localConditionFilter.bedGroupCd"
            >
              <option
                id="selectBedGrp"
                v-for="(option, index) in getBedGroupList"
                :key="index"
                :value="option.bedGroupCd"
              >
                {{ option.bedGroupName }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>クール</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <kendo-multiselect
              v-if="getKurGroupList !== null"
              v-model="localConditionFilter.kurCdList"
              :data-source="getKurGroupList"
              data-text-field="kurGroupName"
              data-value-field="kurCd"
              placeholder="すべて"
            />
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <v-ons-checkbox
              input-id="not-usageGuide"
              float
              v-model="localConditionFilter.notUsageGuide"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <label for="not-usageGuide">凡例を表示しない</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row" style="margin: 0">
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">
              クリア
            </v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center"></v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="ok btn3-normal" @click="dialogOk">
              OK
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/eventBus.js";
import { KEY_NAME_SCALE_BED } from "@/constants/defaultSettingConstants";
import PopoverMixin from "@/components/PopoverMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";

export default {
  components: {
    "common-searcharea": commonSearchArea,
  },
  mixins: [NextTransitionMixin, PopoverMixin],
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null,
  },
  data() {
    return {
      // ポップオーバー表示制御
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",

      localConditionFilter: {
        // ベッドグループコード
        bedGroupCd: 0,
        // クール
        kurCdList: [],
        // 凡例表示
        notUsageGuide: false,
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
    };
  },
  computed: {
    ...mapGetters("scale-bed/list", [
      "getKurGroupList",
      "getBedGroupList",
      "getFilterParam",
      "getFilteredBedGroup",
      "getFilteredKurList",
    ]),
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    // -----------------------------------------
    // デフォルト設定
    // -----------------------------------------
    defaultCondition() {
      // デフォルト設定を store から取得
      const defaultCondition = deepCopy(
        this.getDefaultSetting[KEY_NAME_SCALE_BED.KEY_NAME]
      );
      if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
        // 初期設定がある場合に値を返す
        return defaultCondition;
      } else {
        return null;
      }
    },
  },
  methods: {
    ...mapActions("scale-bed/list", [
      "fetchKurBedGroup",
      "setCondition",
      "clearCondition",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    showPopover(event) {
      if (!this.isLoading) {
        this.popoverTarget = event;
        this.popoverVisible = true;
        // ダイアログでの操作中は、コピーを表示する
        this.localConditionFilter = deepCopy(this.getFilterParam);
      }
    },
    dialogOk() {
      this.popoverVisible = false;
      // 抽出条件の変更チェック
      if (this.conditionChange()) {
        // 抽出条件
        const filter = deepCopy(this.getFilterParam);
        // 凡例表示
        filter.notUsageGuide = this.localConditionFilter.notUsageGuide;
        // クール
        filter.kurCdList = this.localConditionFilter.kurCdList;
        // ベッドグループ
        filter.bedGroupCd = this.localConditionFilter.bedGroupCd;
        // 抽出条件セット
        this.setCondition(filter);
        this.$nextTick(() => {
          this.setConditionList();
        });
        EventBus.$emit("filterSignal");
      }
    },

    // 抽出条件の変更チェック
    conditionChange() {
      const bedGroupCd = this.getFilterParam.bedGroupCd;
      const kurCdList = this.getFilterParam.kurCdList;
      const notUsageGuide = this.getFilterParam.notUsageGuide;
      if (bedGroupCd !== this.localConditionFilter.bedGroupCd) {
        return true;
      }
      if (kurCdList !== this.localConditionFilter.kurCdList) {
        return true;
      }
      if (notUsageGuide !== this.localConditionFilter.notUsageGuide) {
        return true;
      }

      // 抽出条件に変更がない場合
      return false;
    },

    dialogClear() {
      this.popoverVisible = false;
      // 検索条件クリア
      this.clearCondition();
      this.$nextTick(() => {
        this.setConditionList();
      });
      EventBus.$emit("filterSignal");
    },
    dialogClosed() {
      this.localConditionFilter = deepCopy(this.getFilterParam);
    },
    /**
     * @description 初期表示判定
     */
    setInitialStateCondition() {
      // 初期表示判定
      if (!this.getFilterParam.isInitialized) {
        // 初期設定データ作成
        const filter = {
          // ベッドグループコード
          bedGroupCd: 0,
          // クール
          kurCdList: [],
          isInitialized: true,
        };
        if (this.defaultCondition) {
          // デフォルト設定が存在する場合は適用
          if (
            this.defaultCondition[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD] !=
            null
          ) {
            filter.bedGroupCd =
              this.defaultCondition[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD];
            if (
              !this.getBedGroupList.some(
                (bg) => +bg.bedGroupCd === +filter.bedGroupCd
              )
            ) {
              filter.bedGroupCd = 0;
            }
          }

          const tmpDefaultKurCd =
            this.defaultCondition[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST];
          if (tmpDefaultKurCd != null) {
            if (!Array.isArray(tmpDefaultKurCd)) {
              // 1件の場合は配列に変換
              filter.kurCdList = [tmpDefaultKurCd];
            } else {
              filter.kurCdList = tmpDefaultKurCd;
            }
          }
          if (
            this.defaultCondition[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE] !=
            null
          ) {
            filter.notUsageGuide =
              !this.defaultCondition[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE];
          }
        }

        // 抽出条件セット
        this.setCondition(filter);
      }

      this.$nextTick(() => {
        // ベッドグループ
        this.localConditionFilter.bedGroupCd = this.getFilterParam.bedGroupCd;
        // クール
        this.localConditionFilter.kurCdList = this.getFilterParam.kurCdList;

        // 凡例表示
        this.localConditionFilter.notUsageGuide =
          this.getFilterParam.notUsageGuide;

        this.setConditionList();
      });
    },
    setConditionList() {
      // 共通検索エリア部品に表示するデータのリスト設定
      this.conditionList = [];
      if (this.getFilteredBedGroup && this.getFilteredBedGroup.bedGroupCd > 0) {
        this.conditionList.push({
          text: "ベッドグループ:" + this.getFilteredBedGroup.bedGroupName,
        });
      }
      if (this.getFilteredKurList.length > 0) {
        this.conditionList.push({
          text:
            "クール:" +
            this.getFilteredKurList.map((k) => k.kurName).join(", "),
        });
      }
      if (this.getFilterParam.notUsageGuide) {
        this.conditionList.push({
          text: "凡例非表示",
        });
      }
    },
  },
  async created() {
    // クールとベッドグループ一覧情報取得
    await this.fetchKurBedGroup();
    // mod  FNSI-redmine#4277 付 end
    this.setInitialStateCondition();
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style scoped>
#popover {
  margin: 5px 10px 5px 10px;
  position: relative;
}
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
input[type="checkbox"] {
  display: none; /* チェックボックスを非表示にする */
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 100%;
  font-size: 1.5em;
}
.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 35%; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 3px; /* ボックス内左側の余白を指定する */
  padding-right: 3px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
}
/* add FNSI-redmine#3965 付 start */
.phone-type {
  border-radius: 10px 10px 10px 10px !important;
  margin: 0 0 0 25px !important;
  font-size: 0.8em !important;
  width: 50%;
}
.icon-type {
  margin: 14px -30px 0 0;
}
/* add FNSI-redmine#3965 付 end */
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin-left: 4px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
}
.zoom-icon {
  width: 20px;
  margin: 20px 0;
}
.div-zoom {
  text-align: center;
}
/* mod FNSI-dialog表示不全 付 start */
@media screen and (min-width: 1400px) {
  ons-popover >>> .popover__content {
    min-width: 400px;
  }
}
/* mod FNSI-dialog表示不全 付 end */
#change_button {
  font-size: 1.5em;
}
</style>
