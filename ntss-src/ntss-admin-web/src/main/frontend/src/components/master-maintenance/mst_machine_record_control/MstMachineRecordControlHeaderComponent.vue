/**
 * マスタメンテナンスレコードページ用ヘッダ
 */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <div class='condition-search-area' @click='showPopover($event)'>
            <div class='condition-search-icon-area'>
              <v-ons-icon icon='fa-search' size='2.0em' style="color:gray;"></v-ons-icon>
            </div>
            <div class='condition-items-area'>
              <label class='condition-label' v-if='condition.inUsed.recordCode!=""'>
                {{ condition.inUsed.recordCode }}
              </label>
              <label class='condition-label' v-if='condition.inUsed.recordMessage!=""'>
                {{ condition.inUsed.recordMessage }}
              </label>
              <label class='condition-label' v-if='condition.inUsed.dispFlg!=""'>
                {{ dispFlgList[parseInt(condition.inUsed.dispFlg) + 1].text }}
              </label>
              <!-- <br v-if='condition.inUsed.recordName!=""'/>
              <label class='condition-label' v-if='condition.inUsed.includeDeleted'>
                削除を表示
              </label> -->
            </div>
          </div>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                   v-model:visible='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="[fontSizeSet, 'master-search']"
                   width="370px"
                   >
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>装置記録コード</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input input-id='recordCode' type='text' float  v-model='condition.inProgress.recordCode' @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>装置記録メッセージ</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input input-id='recordMessage' type='text' float  v-model='condition.inProgress.recordMessage' @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row' v-if="this.sysUseSetNo !== '1'">
          <v-ons-col width='40%' vertical-align='center'>
            <label>表示設定</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-select input-id='dispFlg'  v-model='condition.inProgress.dispFlg' @keydown.enter='onSearchEnter'>
              <option v-for="(item, index) in dispFlgList" :key="index" :value="item.value">
                {{ item.text }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <!-- <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <v-ons-checkbox input-id='includeDeleted' float  v-model='condition.inProgress.includeDeleted'></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <label for="includeDeleted">削除を表示する</label>
          </v-ons-col>
        </v-ons-row> -->
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='btn2-cancel clear button' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='btn3-normal ok button' @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";

export default {
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      recordCode: "",
      recordMessage: "",
      recordName: "",
      dispFlg: "",
      includeDeleted: false
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      condition: {
        // 入力中の検索条件
        inProgress: {
          ...defaultCondition
        },
        // 実際に検索に使用される条件
        inUsed: {
          ...defaultCondition
        }
      },
      isSortMode: false
    }
  },
  computed: {
    ...mapGetters("master-maintenance", ["getFacilityList", "getFacilitySwitch"]),
    ...mapGetters("user", ["getSystemUseSetting"]),
    dispFlgList() {
      let dispFlgList = [ {"text": "","value": ""},
                          {"text": "0：表示しない","value": "0"},
                          {"text": "1：愁訴処置画面のみ表示する","value": "1" },
                          {"text": "2：愁訴処置画面+帳票表示する","value": "2"}
                        ];
      return dispFlgList
    },
    sysUseSetNo() {
      const myFacility = this.getFacilityList.filter(
        e => e.facilityCd === this.getFacilitySwitch
      );
      return myFacility.length > 0 ? myFacility[0].systemUseSetting : this.getSystemUseSetting;
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setCondition"]),
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // ソートモード時は表示しない
      if (this.isSortMode) {
        return;
      }
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.inProgress.recordCode = this.defaultCondition.recordCode;
      this.condition.inProgress.recordMessage = this.defaultCondition.recordMessage;
      this.condition.inProgress.dispFlg = this.defaultCondition.dispFlg;
      this.condition.inProgress.recordName = this.defaultCondition.recordName;
      this.condition.inProgress.includeDeleted = this.defaultCondition.includeDeleted;
      this.condition.inUsed.recordCode = this.defaultCondition.recordCode;
      this.condition.inUsed.recordMessage = this.defaultCondition.recordMessage;
      this.condition.inUsed.dispFlg = this.defaultCondition.dispFlg;
      this.condition.inUsed.recordName = this.defaultCondition.recordName;
      this.condition.inUsed.includeDeleted = this.defaultCondition.includeDeleted;
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // 抽出条件Enter押下時イベント
    // -----------------------------------------
    onSearchEnter : function(){
        this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      //スクロールバーの位置をクリア
      EventBus.$emit("clearScrollPosition");
      this.copyConditionInProgressToInUsed();
      // 検索条件の内容で画面を更新
      // this.setCondition(JSON.parse(JSON.stringify(this.condition.inUsed)));
      EventBus.$emit("setMchineRecordColntrolcondition",this.condition.inUsed);
    },
    setSortMode(isSortMode) {
      // 検索条件の内容で画面を更新
      this.isSortMode = isSortMode;
      if (this.isSortMode) {
        // ソートモード時は条件クリア
        this.dialogClear();
      }
    },
    copyConditionInProgressToInUsed() {
      this.condition.inUsed.recordCode = this.condition.inProgress.recordCode;
      this.condition.inUsed.recordMessage = this.condition.inProgress.recordMessage;
      this.condition.inUsed.dispFlg = this.condition.inProgress.dispFlg;
      this.condition.inUsed.recordName = this.condition.inProgress.recordName;
      this.condition.inUsed.includeDeleted = this.condition.inProgress.includeDeleted;
    },
    copyConditionInUsedToInProgress() {
      this.condition.inProgress.recordCode = this.condition.inUsed.recordCode;
      this.condition.inProgress.recordMessage = this.condition.inUsed.recordMessage;
      this.condition.inProgress.dispFlg = this.condition.inUsed.dispFlg;
      this.condition.inProgress.recordName = this.condition.inUsed.recordName;
      this.condition.inProgress.includeDeleted = this.condition.inUsed.includeDeleted;
    }
  },
  created() {
    this.dialogClear();
    EventBus.$on("setSortMode", this.setSortMode);
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("setSortMode", this.setSortMode);
  }
  // add 性能改善メモリ不足 shan end
};
</script>
