/**
 * 治療状況リスト用ヘッダ
 */
<template>
  <div class="header-item">
    <v-ons-row class="mark-leftmost-header">
      <v-ons-col vertical-align="center" width="50%">
        <div id="change_button">
          <input
            type="radio"
            class="identification"
            name="identification"
            value="1"
            id="input-bed-name"
            @click="changeShowMain(true);"
            :checked="isShow"
          />
          <!-- mod FNSI-redmine#3965 付 start -->
          <!-- <label for="input-bed-name" class="label first-of-type">治療状況</label> -->
          <label for="input-bed-name" class="label first-of-type" :class="startGaMenWidth < 500? 'phone-type' : ''">治療状況</label>
          <!-- mod FNSI-redmine#3965 付 end -->
          <input
            type="radio"
            class="identification"
            name="identification"
            value="2"
            id="input-machine-name"
            @click="changeShowMain(false);"
            :checked="!isShow"
          />
          <!-- mod FNSI-redmine#3965 付 start -->
          <!-- <label for="input-machine-name" class="label last-of-type">装置一覧</label> -->
          <label for="input-machine-name" class="label last-of-type" :class="startGaMenWidth < 500? 'phone-type' : ''">装置一覧</label>
          <!-- mod FNSI-redmine#3965 付 end -->
        </div>
        <div class="div-zoom">
          <!-- mod FNSI-redmine#3965 付 start -->
          <!-- <img
            @click="moveLargeScreenDisplay"
            v-show="enableZoom"
            src="img/status-list/zoom.png"
            class="zoom-icon"
          /> -->
          <img
            @click="moveLargeScreenDisplay"
            v-show="enableZoom"
            src="img/status-list/zoom.png"
            class="zoom-icon"
            :class="startGaMenWidth < 500? 'icon-type' : ''"
          />
          <!-- mod FNSI-redmine#3965 付 end -->
        </div>
      </v-ons-col>
      <v-ons-col width="40%" style="height: 100%;">
        <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
      </v-ons-col>
    </v-ons-row>
    <!-- 抽出ダイアログ[始] -->
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="dialogClosed(); popoverPosthide($event)"
    >
      <!--mod FNSI-画面部品デザイン じょはく start-->
      <!--<div id="popover">-->
      <div id="popover" class="fab-font-color">
        <!--mod FNSI-画面部品デザイン じょはく end-->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>次患者表示</label>
          </v-ons-col>
          <v-ons-col width="40%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.nextPatValue" v-if="isShow">
              <option
                id="nextpatgrp"
                v-for="option in nextPatGroupListGetter"
                :key="option.nextPatValue"
                :value="option.nextPatValue"
              >{{ option.nextPatGroupName }}</option>
            </v-ons-select>
            <v-ons-select style="width: 100%" v-model="viewCondition.deviceNextValue" v-else>
              <option
                id="nextpatgrp"
                v-for="option in nextPatGroupListGetter"
                :key="option.nextPatValue"
                :value="option.nextPatValue"
              >{{ option.nextPatGroupName }}</option>
            </v-ons-select>
          </v-ons-col>

          <v-ons-col width="10%" vertical-align="center" style="height: 22px;"></v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>表示項目</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.colItemLayoutNo">
              <option
                id="colitemgrp"
                v-for="option in comboLayoutItemListGetter"
                :key="option.colItemLayoutNo"
                :value="option.colItemLayoutNo"
              >{{ option.layoutName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center" v-if="isShow">
            <label>クール</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center" v-if="isShow">
            <kendo-multiselect
              v-if="getKurGroupList !== null"
              v-model="viewCondition.kurGroupList"
              :data-source="getKurGroupList"
              data-text-field="kurGroupName"
              data-value-field="kurCd"
              placeholder="すべて"
            />
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>ベッドグループ</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.bedGroupCd">
              <option
                id="selectbedgrp"
                v-for="(option, index) in getBedGroupList"
                :key="index"
                :value="option.bedGroupCd"
              >{{ option.bedGroupName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <v-ons-checkbox input-id="not-usageGuide" float v-model="viewCondition.notUsageGuide"></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <label for="not-usageGuide">凡例を表示しない</label>
          </v-ons-col>
        </v-ons-row>
        <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
        <v-ons-row class="condition-row" style="margin: 0;">
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">クリア</v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center"></v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="ok btn3-normal" @click="dialogOk">OK</v-ons-button>
          </v-ons-col>
        </v-ons-row>
        <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
      </div>
    </v-ons-popover>
    <!-- 抽出ダイアログ[終] -->
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/eventBus.js";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { KEY_NAME_STATUS_LIST } from "@/constants/defaultSettingConstants";
import PopoverMixin from "@/components/PopoverMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [NextTransitionMixin, PopoverMixin],
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      isShow: true,
      viewCondition: {},
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
      // add FNSI-redmine#3965 付 start
      ,startGaMenWidth: 0,
      // add FNSI-redmine#3965 付 end
    };
  },
  computed: {
    ...mapGetters("status-list/list", [
      "getKurGroupList",
      "getBedGroupList",
      "conditionFilter",
      "nextPatGroupListGetter",
      "comboLayoutItemListGetter"
    ]),
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    // -----------------------------------------
    // デフォルト設定
    // -----------------------------------------
    defaultCondition() {
      // デフォルト設定を store から取得
      const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_STATUS_LIST.KEY_NAME]);
      if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
        // 初期設定がある場合に値を返す
        return defaultCondition;
      } else {
        return null;
      }
    },
    enableZoom() {
      return this.getAdvancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.ENABLE_ZOOM
      );
    }
  },
  methods: {
    ...mapActions("status-list/list", [
      "fetchKur",
      "fetchBedMachine",
      "fetchKurBedGroup",
      "conditionSet",
      "clearCondition",
      "setIsShowMain",
    ]),
    ...mapActions("account-edit", [
      "setIsDispFloatMenu",
      "setIsDispSidebarBtn"
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    // add FNSI-redmine#4277 付 start
    ...mapGetters("status-list/list", ["getIsShowMain"]),
    // add FNSI-redmine#4277 付 end
    ...mapActions("app", ["setQueryParameters"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    findNextPatOption(nextPatValue) {
      return this.nextPatGroupListGetter.find(
        option => `${option.nextPatValue}` === `${nextPatValue}`
      );
    },
    loadData() {
      // クール詳細一覧情報取得
      this.fetchKur(this.getFacilityCd);
      // ベッド＋装置情報取得
      this.fetchBedMachine();
    },
    showPopover(event) {
      if (!this.isLoading) {
        this.popoverTarget = event;
        this.popoverVisible = true;
        // ダイアログでの操作中は、コピーを表示する
        this.viewCondition = deepCopy(this.conditionFilter);

        // console.log(" kurGroupList:" + this.viewCondition.kurGroupList);
      }
    },
    dialogOk() {
      this.popoverVisible = false;
      // 抽出条件の変更チェック
      if (this.conditionChange()) {
        // 抽出条件
        const filter = deepCopy(this.conditionFilter);
        // 治療状況リストと装置一覧で次患者表示を別々に登録する
        // 治療状況リスト：次患者表示
        filter.nextPatValue = this.viewCondition.nextPatValue;
        // 装置一覧：次患者表示
        filter.deviceNextValue = this.viewCondition.deviceNextValue;
        // 凡例表示
        filter.notUsageGuide = this.viewCondition.notUsageGuide;
        // 治療状況リスト：表示項目
        filter.colItemLayoutNo = this.viewCondition.colItemLayoutNo;
        const selectedLayout = this.comboLayoutItemListGetter.find(
          layout =>
            `${layout.colItemLayoutNo}` === `${this.viewCondition.colItemLayoutNo}`
        );
        filter.layoutName = selectedLayout ? selectedLayout.layoutName : "";
        // 表示項目変更チェック
        const statusLayoutNo = this.conditionFilter.colItemLayoutNo;
        if (`${statusLayoutNo}` !== `${this.viewCondition.colItemLayoutNo}`) {
          filter.colListChange = true;
        } else {
          filter.colListChange = false;
        }
        // 装置一覧：表示項目
        filter.deviceColIndex = this.viewCondition.deviceColIndex;
        // クール
        filter.kurGroupList = this.viewCondition.kurGroupList;
        let kurGroupData = this.viewCondition.kurGroupList;
        filter.kurGroupName = [];
        // マスタ分
        for (let idx = 0; idx < this.getKurGroupList.length; idx++) {
          let kurNameData = this.getKurGroupList[idx].kurCd;
          if (kurNameData !== undefined && kurNameData !== null) {
            // 選択項目分
            for (let i = 0; i < kurGroupData.length; i++) {
              if (kurNameData == kurGroupData[i]) {
                let kurNames = this.getKurGroupList[idx].kurGroupName;
                filter.kurGroupName.push(kurNames);
              }
            }
          }
        }
        this.viewCondition.kurGroupName = filter.kurGroupName;
        // ベッドグループ
        filter.bedGroupCd = this.viewCondition.bedGroupCd;
        const bedGroup = this.getBedGroupList.find(bg => +bg.bedGroupCd === +this.viewCondition.bedGroupCd);
        filter.bedGroupName = bedGroup
          ? bedGroup.bedGroupName
          : "";
        // 変更内容の判断処理
        const beforeConditon = this.conditionFilter;
        if (
          beforeConditon.colItemLayoutNo !== filter.colItemLayoutNo ||
          beforeConditon.deviceColIndex !== filter.deviceColIndex
        ) {
          filter.isClear = true;
        } else {
          filter.isClear = false;
        }
        // 抽出条件セット
        this.conditionSet(filter);
        this.$nextTick(() => {
          this.setConditionList();
        });
        EventBus.$emit("filterSignal");
      }
    },

    // 抽出条件の変更チェック
    conditionChange() {
      const bedGroupCd = this.conditionFilter.bedGroupCd;
      const statusLayoutNo = this.conditionFilter.colItemLayoutNo;
      const deviceGroupIdx = this.conditionFilter.deviceColIndex;
      const kurGroup = this.conditionFilter.kurGroupList;
      const kurGroupName = this.conditionFilter.kurGroupName;
      const nextPatValue = this.conditionFilter.nextPatValue;
      const deviceNextValue = this.conditionFilter.deviceNextValue;
      const notUsageGuide = this.conditionFilter.notUsageGuide;
      if (bedGroupCd !== this.viewCondition.bedGroupCd) {
        return true;
      }
      if (`${statusLayoutNo}` !== `${this.viewCondition.colItemLayoutNo}`) {
        return true;
      }
      if (deviceGroupIdx !== this.viewCondition.deviceColIndex) {
        return true;
      }
      if (kurGroup !== this.viewCondition.kurGroupList) {
        return true;
      }
      if (kurGroupName !== this.viewCondition.kurGroupName) {
        return true;
      }
      if (nextPatValue !== this.viewCondition.nextPatValue ) {
        return true;
      }
      if (deviceNextValue !== this.viewCondition.deviceNextValue) {
        return true;
      }
      if (notUsageGuide !== this.viewCondition.notUsageGuide) {
        return true;
      }

      // 抽出条件に変更がない場合
      return false;
    },

    changeShowMain(isShowMain) {
      this.isShow = isShowMain;
      this.setIsShowMain(isShowMain);
      /* add by chamaojia 2022-11-26 [6746] データ更新の呼び出し  --start */
      EventBus.$emit("refresh");
      /* add by chamaojia 2022-11-26 [6746] データ更新の呼び出し  --end */
    },
    dialogClear() {
      const filter = deepCopy(this.conditionFilter);
      const defaultLayoutNo = this.comboLayoutItemListGetter[0]
        ? this.comboLayoutItemListGetter[0].colItemLayoutNo
        : "";
      // 治療状況リスト抽出条件クリア
      const beforeConditon = this.conditionFilter;
      if (
        beforeConditon.colItemLayoutNo !== defaultLayoutNo ||
        beforeConditon.deviceColIndex !== 0
      ) {
        filter.isClear = true;
      } else {
        filter.isClear = false;
      }
      // ベッドグループ
      /* add #8872 by zhangruixue 2023-06-21 --start */
      this.conditionFilter.kurCd = null;
      filter.kurCd = null;
      /* add #8872 by zhangruixue 2023-06-21 --start */
      filter.bedGroupCd = 0;
      filter.colItemLayoutNo = defaultLayoutNo;
      filter.kurGroupList = [];
      filter.kurGroupName = [];
      filter.nextPatValue = 0;
      filter.deviceNextValue = 2;
      filter.notUsageGuide = false;
      this.popoverVisible = false;
      // 検索条件クリア
      this.clearCondition(filter);
      this.setConditionList();
      EventBus.$emit("filterSignal");
    },
    dialogClosed() {
      this.viewCondition = deepCopy(this.conditionFilter);
    },
    moveLargeScreenDisplay() {
      // フロートメニューを非表示化
      this.setIsDispFloatMenu(false);
      // サイドメニュー、サイドメニュー開閉ボタンを非表示化
      this.setIsDispSidebarBtn(false);
      // 大画面表示へ遷移
      this.goSpecifiedView("status-list-largedisp");
    },
    // -----------------------------------------
    // stateから取得したconditionを変数に設定する
    // -----------------------------------------
    setStateCondition() {
      // 初期表示判定
      if (!this.conditionFilter.isInitialized) {
        // 初期設定データ作成
        let filter = {
          // ベッドグループコード
          bedGroupCd: 0,
          // 表示項目：治療状況リスト
          colItemGroupName: "",
          colItemLayoutNo: this.comboLayoutItemListGetter[0]
            ? this.comboLayoutItemListGetter[0].colItemLayoutNo
            : "",
          // 表示項目：装置一覧
          deviceColIndex: 0,
          // クール
          kurCd: [],
          // クール名
          kurGroupName: [],
          kurGroupList: [],
          // 次患者表示：治療状況リスト
          nextPatValue: 0,
          // 次患者表示：装置一覧
          deviceNextValue: 2,
          colListChange: false,
          isClear: false,
          notUsageGuide: false,
          isInitialized: true
        };
        if (this.defaultCondition) {
          // デフォルト設定が存在する場合は適用
          if (this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD] != null) {
            filter.bedGroupCd = this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD];
            if(!this.getBedGroupList.some(bg => +bg.bedGroupCd === +filter.bedGroupCd)) {
              filter.bedGroupCd = 0;
            }
          }
          if (this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP] != null) {
            filter.colItemLayoutNo =
              this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP];
          }
          if (this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE] != null) {
            filter.deviceNextValue = this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE];
          }
          if (
            this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST] &&
            this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST].length !== 0
          ) {
            filter.kurGroupList = this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST];
          }
          if (this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP] != null) {
            filter.nextPatValue = this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP];
          }
          if (this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE]) {
            filter.notUsageGuide = this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE];
          }
        }

        // 画面遷移パラメータ取得
        const queryParameters = this.getQueryParameters();

        if (queryParameters.colItemLayoutNo > 0) {
          // 表示項目：治療状況リスト
          filter.colItemLayoutNo = queryParameters.colItemLayoutNo;
          // クエリパラメータのcolItemLayoutNoをクリア
          queryParameters.colItemLayoutNo = null;
          this.setQueryParameters(queryParameters);
        }
        // 抽出条件セット
        this.conditionSet(filter);
      }

      this.$nextTick(() => {
        // ベッドグループ
        this.viewCondition.bedGroupCd = this.conditionFilter.bedGroupCd;
        // 表示項目：治療状況リスト
        this.viewCondition.colItemLayoutNo = this.conditionFilter.colItemLayoutNo;
        // 表示項目：装置一覧
        this.viewCondition.deviceColIndex = this.conditionFilter.deviceColIndex;
        // クール
        this.viewCondition.kurGroupList = this.conditionFilter.kurGroupList;
        // クール名
        this.viewCondition.kurGroupName = this.conditionFilter.kurGroupName;
        // 次患者表示：治療状況リスト
        this.viewCondition.nextPatValue = this.conditionFilter.nextPatValue;
        // 次患者表示：装置一覧
        this.viewCondition.deviceNextValue = this.conditionFilter.deviceNextValue;
        // 凡例表示
        this.viewCondition.notUsageGuide = this.conditionFilter.notUsageGuide;
        this.setConditionList();
      });
      EventBus.$emit("initSignal");
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.conditionFilter;
      // 次患者表示
      if (this.viewCondition.nextPatValue !== undefined && this.isShow) {
        const nextPatOption = this.findNextPatOption(condObj.nextPatValue);
        condList.push({ name:"次患者表示", text:nextPatOption ? nextPatOption.nextPatGroupName : "" });
      } else if (this.viewCondition.deviceNextValue !== undefined && !this.isShow) {
        const nextPatOption = this.findNextPatOption(condObj.deviceNextValue);
        condList.push({ name:"次患者表示", text:nextPatOption ? nextPatOption.nextPatGroupName : "" });
      }
      // 表示項目：治療状況リスト
      const selectedLayout = this.comboLayoutItemListGetter.find(
        layout => `${layout.colItemLayoutNo}` === `${condObj.colItemLayoutNo}`
      );
      if (selectedLayout) {
        condList.push({ name:"表示項目", text:selectedLayout.layoutName });
      }
      // クール
      if (Number(condObj.kurGroupList) !== 0 && this.isShow) {
        let str = "";
        if (Number(condObj.kurGroupName) !== 0) {
          for (const index in condObj.kurGroupName) {
            str = str + condObj.kurGroupName[index] + "、";
          }
        } else if (Number(condObj.kurGroupName) === 0 && this.getKurGroupList.length !== 0) {
          this.getKurGroupList.filter(kur => {
            return condObj.kurGroupList.indexOf(kur.kurCd) > -1;
          }).forEach(kur => {
            str = str + kur.kurGroupName + "、";
          });
        }
        condList.push({ name:"クール", text:str.slice(0, -1) });
      }
      // add #11285 機能帳票の印刷情報対応② 高 start
      else {
        condList.push({ name:"クール", text:"すべて" });
      }
      // add #11285 機能帳票の印刷情報対応② 高 end
      // ベッドグループ
      if (condObj.bedGroupCd !== 0) {
        const bedGroup = this.getBedGroupList.find(bg => +bg.bedGroupCd === +condObj.bedGroupCd);
        if(bedGroup)
        {
          condList.push({ name:"ベッドグループ",  text: bedGroup.bedGroupName});
        }
        else
        {
          condList.push({ name:"ベッドグループ",  text: "すべて"});
        }
      }
      else {
      	condList.push({ name:"ベッドグループ",  text: "すべて"});
      }

      // add #11285 機能帳票の印刷情報対応② 高 start
      sessionStorage.setItem('roomBedGroupNameStatusList', JSON.stringify(condList.find(item => item.name === "ベッドグループ").text));
      sessionStorage.setItem('kurGroupNameStatusList', JSON.stringify(condList.find(item => item.name === "クール").text));
      // add #11285 機能帳票の印刷情報対応② 高 end

      // 凡例
      if (condObj.notUsageGuide) {
        condList.push({ text:"凡例を表示しない" });
      }
      this.conditionList = condList;
    }
  },
  async created() {
    // ベッドグループ一覧情報取得
    await this.fetchKurBedGroup();
    // mod FNSI-redmine#4277 付 start
    // 治療状況/装置一覧の初期表示設定
    // if (this.defaultCondition && this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE]) {
    if (this.defaultCondition && this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] && this.getIsShowMain() == null) {
      this.changeShowMain(this.defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] === "1");
    } else {
      // this.setIsShowMain(true);
      if (this.getIsShowMain() != null) {
        this.changeShowMain(this.getIsShowMain());
      } else {
        this.changeShowMain(true);
      }
    }
    // mod  FNSI-redmine#4277 付 end
    this.setStateCondition();

    EventBus.$off("dataUpdateNextPatMode");

    // 次患者選択更新通知イベントをセット
    EventBus.$on("dataUpdateNextPatMode", this.setStateCondition);
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
    // 情報取得
    this.loadData();
    // add FNSI-redmine#3965 付 start
    this.startGaMenWidth = document.body.clientWidth;
    // add FNSI-redmine#3965 付 end
  },
  beforeDestroy() {
    // 次患者選択更新通知イベントを解除
    EventBus.$off("dataUpdateNextPatMode");

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  watch: {
    // FNSI-add redmine5168 徐 start
    // popoverVisible(val) {
    //   if (val) {
    //     EventBus.$emit("endPolling");
    //   } else {
    //     EventBus.$emit("startPolling");
    //   }
    // },
    // FNSI-add redmine5168 徐 end
    comboLayoutItemListGetter() {
      // 初期表示に必要なデータがない為の対策
      this.setConditionList();
    }
  }
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


