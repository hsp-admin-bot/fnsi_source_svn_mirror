<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'popover-area']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div v-bind:style="[popoverStyles]">
        <!-- 日付選択1 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label style="font-size:initial;">申込日</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <!-- <input
              input-id="startDate"
              class="input-area ntss-custom-input"
              type="date"
              float
              v-model="condition.inProgress.startDate"
              @input="setStartDateValue($event.target.value)"
            /> -->
            <input
              input-id="startDate"
              id="startDate"
              class="input-area ntss-custom-input"
              type="date"
              float
              max="9999-12-31"
              v-validate="'date_format:yyyy-MM-dd'"
              v-model="condition.inProgress.startDate"
              @input="setStartDateValue($event.target.value)"
              @keyup="showMsg(1)"
            />
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
            <common-calendar v-model="condition.inProgress.startDate" class="calender" />
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <span class="error-message" v-if="showStartError">{{ this.msgDiaLog }}</span>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- 日付選択2 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label style="margin-right: 5px; font-size: x-large; float: right;">~</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <!-- <input
              input-id="endDate"
              class="input-area ntss-custom-input"
              type="date"
              float
              v-model="condition.inProgress.endDate"
              @input="setEndDateValue($event.target.value)"
            /> -->
            <input
              input-id="endDate"
              class="input-area ntss-custom-input"
              type="date"
              float
              id="endDate"
              v-model="condition.inProgress.endDate"
              max="9999-12-31"
              v-validate="'date_format:yyyy-MM-dd'"
              @input="setEndDateValue($event.target.value)"
              @keyup="showMsg(2)"
            />
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
            <common-calendar v-model="condition.inProgress.endDate" class="calender" />
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <span class="error-message" v-if="showEndError">{{ this.msgDiaLog }}</span>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- セレクション1 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label style="font-size:initial;">都道府県</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select float v-model="condition.inProgress.prefecturesCd" style="display:">
              <option>すべて</option>
              <option
                v-for="prefecture in prefectures"
                :value="prefecture[0]"
                :key="prefecture[0]"
              >{{ prefecture[1] }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <!-- セレクション2 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label style="font-size:initial;">部署符号</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select float v-model="condition.inProgress.departmentCd" style="display:">
              <option>すべて</option>
              <option
                v-for="(departmentCd, idxDepartmentCd) in departmentCds"
                :value="departmentCd"
                :key="idxDepartmentCd"
              >{{ departmentCd }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <!-- テキストボックス -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label style="font-size:initial;">フリーワード</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-input
              input-id="freeWord"
              type="text"
              float
              v-model="condition.inProgress.freeWord"
              @keydown.enter="onSearchEnter"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <!-- チェックボックス1 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <v-ons-checkbox
              input-id="includeNotAccepted"
              float
              :value="0"
              v-model="condition.inProgress.subscriptionStatusList"
            ></v-ons-checkbox>
            <label style="font-size:initial; margin-left: 8px" for="includeNotAccepted">未受付</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-checkbox
              input-id="includeAccepted"
              float
              :value="1"
              v-model="condition.inProgress.subscriptionStatusList"
            ></v-ons-checkbox>
            <label style="font-size:initial; margin-left: 8px" for="includeAccepted">受付済み</label>
          </v-ons-col>
        </v-ons-row>
        <!-- チェックボックス2 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <v-ons-checkbox
              input-id="includeCompleted"
              float
              :value="2"
              v-model="condition.inProgress.subscriptionStatusList"
            ></v-ons-checkbox>
            <label style="font-size:initial; margin-left: 8px" for="includeCompleted">完了済み</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-checkbox
              input-id="includeCancel"
              float
              :value="9"
              v-model="condition.inProgress.subscriptionStatusList"
            ></v-ons-checkbox>
            <label style="font-size:initial; margin-left: 8px" for="includeCancel">キャンセル</label>
          </v-ons-col>
        </v-ons-row>
        <!-- スイッチ制御 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="100%" vertical-align="center">
            <label style="font-size:initial; margin-right: 10px;">自身が受付した申込のみ表示</label>
            <v-ons-switch v-model="condition.inProgress.myAccepted"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <!-- ボタン -->
        <div class="condition-row" style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class="btn2-cancel clear" @click="dialogClear">クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <!-- <v-ons-button class="btn1-execute ok" @click="dialogOk">OK</v-ons-button> -->
            <v-ons-button class="btn3-normal ok" :disabled="showStartError || showEndError" @click="dialogOk">OK</v-ons-button>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/eventBus.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
// add FNSI-横展開 日付のチェックの追加 徐 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-横展開 日付のチェックの追加 徐 end
// add FNSI-redmine#4244 付 start
import { prefectures } from "@/components/master-maintenance/mst-device-edge/Prefectures.js";
// add FNSI-redmine#4244 付 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea
  },
  name: "ApplicationListHeaderComponent",
  data() {
    const defaultCondition = {
      startDate: "",
      endDate: "",
      departmentCd: "すべて",
      prefecturesCd: "すべて",
      freeWord: "",
      subscriptionStatusList: ["0", "1"],
      myAccepted: false
    };
    return {
      popoverStyles: {
        'overflow-y': 'auto',
        'max-height': (screen.height - 100) + 'px',
        'margin': '10px'
      },
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
      isSortMode: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      // add FNSI-横展開 日付のチェックの追加 徐 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showStartError: false,
      showEndError: false
      // add FNSI-横展開 日付のチェックの追加 徐 end
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    // add FNSI-横展開No.7追加 徐 start
    // ...mapGetters("application-list", ["getCandidates"]),
    ...mapGetters("application-list", ["getCandidates", "getCondition"]),
    // add FNSI-横展開No.7追加 徐 end

    /**
     * 部署符号の選択肢リスト取得
     */
    departmentCds() {
      // mod FNSI-redmine#4244 付 start
      // return this.getCandidates.departmentCds;
      return this.getCandidates.departmentCds.filter(e => e != null);
      // mod FNSI-redmine#4244 付 end
    },
    /**
     * 都道府県の選択肢リスト取得
     */
    prefectures() {
      // mod FNSI-redmine#4244 付 start
      // return this.getCandidates.prefectures;
      let pre = this.getCandidates.prefectures.filter(e => e[0] != null);
      let preCdList = [];
      prefectures.forEach(e => {
        pre.forEach(element => {
          if (e.prefCd == element[0]) {
            preCdList.push(element);
            return false;
          }
        });
      });
      return preCdList;
      // mod FNSI-redmine#4244 付 end
    }
  },
  watch: {},
  async created() {
    this.fetchFacilities(this.getStateUserAccountInfo.userId);
    // add FNSI-横展開No.7追加 徐 start
    // this.dialogOk();
    this.condition.inUsed = deepCopy(this.getCondition);
    this.setConditionList();
    this.search();
    // add FNSI-横展開No.7追加 徐 end
  },
  methods: {
    ...mapActions("application-list", [
      "setCondition",
      "setFilterApplication",
      "fetchFacilities"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     *
     */
    setStartDateValue(value) {
      if (value === "" || value === null) {
        this.condition.inProgress.startDate = "";
      }
    },
    /**
     *
     */
    setEndDateValue(value) {
      if (value === "" || value === null) {
        this.condition.inProgress.endDate = "";
      }
    },
    /**
     *
     */
    findPrefecName(prefecturesCd) {
      if (prefecturesCd === "すべて") return "すべて";
      return this.prefectures.filter(pre => pre[0] === prefecturesCd)[0][1];
    },
    /**
     *
     */
    onSearchEnter() {
      this.dialogOk();
    },
    /**
     *
     */
    showPopover(event) {
      // add FNSI-横展開No.7追加 徐 start
      this.condition.inUsed = deepCopy(this.getCondition);
      // add FNSI-横展開No.7追加 徐 end
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    /**
     *
     */
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.inUsed = deepCopy(this.defaultCondition);
      this.copyConditionInUsedToInProgress();
      this.setCondition(deepCopy(this.condition.inUsed));
      this.setConditionList();
      // 画面を閉じる
      this.search();
    },
    /**
     *
     */
    dialogOk() {
      this.copyConditionInProgressToInUsed();
      this.setCondition(deepCopy(this.condition.inUsed));
      this.setConditionList();
      this.search();
    },
    /**
     *
     */
    search() {
      this.setFilterApplication(true).then(() => {
        EventBus.$emit(
          "filterApplicationList",
          deepCopy(this.condition.inUsed)
        );
      });
      this.popoverVisible = false;
    },
    /**
     *
     */
    copyConditionInProgressToInUsed() {
      this.condition.inUsed = deepCopy(this.condition.inProgress);
    },
    /**
     *
     */
    copyConditionInUsedToInProgress() {
      this.condition.inProgress = deepCopy(this.condition.inUsed);
    },
    /**
     * 共通検索エリア部品に表示するデータのリストを作成.
     */
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // 申込日
      let displayDate = "";
      if (condObj.startDate !== "" && condObj.endDate !== "") {
        displayDate = condObj.startDate.replace(/-/g, "/") + "～" + condObj.endDate.replace(/-/g, "/");
      } else if (condObj.startDate !== "" && condObj.endDate === "") {
        displayDate = condObj.startDate.replace(/-/g, "/") + "～";
      } else if (condObj.startDate === "" && condObj.endDate !== "") {
        displayDate = "～" + condObj.endDate.replace(/-/g, "/");
      }
      if (displayDate !== "") {
        condList.push({ name:"申込日", text:displayDate });
      }
      // 都道府県
      condList.push({ name:"都道府県", text:this.findPrefecName(condObj.prefecturesCd) });
      // 部署符号
      condList.push({ name:"部署符号", text:condObj.departmentCd });
      // フリーワード
      if (condObj.freeWord != "") {
        condList.push({ name:"フリーワード", text:condObj.freeWord });
      }
      // 未受付
      if (condObj.subscriptionStatusList.includes("0")) {
        condList.push({ text:"未受付" });
      }
      // 受付済み
      if (condObj.subscriptionStatusList.includes("1")) {
        condList.push({ text:"受付済み" });
      }
      // 完了済み
      if (condObj.subscriptionStatusList.includes("2")) {
        condList.push({ text:"完了済み" });
      }
      // キャンセル
      if (condObj.subscriptionStatusList.includes("9")) {
        condList.push({ text:"キャンセル" });
      }
      // 自身が受付した申込のみ表示
      if (condObj.myAccepted) {
        condList.push({ text:"自身が受付した申込のみ表示" });
      }
      this.conditionList = condList;
    },
    // add FNSI-横展開 日付のチェックの追加 徐 start
    showMsg(e) {
      if (e === 1) {
        if (document.getElementById("startDate").validationMessage) {
          this.showStartError = true;
        } else {
          this.showStartError = false;
        }
      }
      if (e === 2) {
        if (document.getElementById("endDate").validationMessage) {
          this.showEndError = true;
        } else {
          this.showEndError = false;
        }
      }
    }
    // add FNSI-横展開 日付のチェックの追加 徐 end
  }
};
</script>
<style scoped>
.mark-leftmost-header {
  overflow: hidden;
}
.input-area::-webkit-calendar-picker-indicator {
  display: none;
}
.popover-area >>> .popover-mask {
  z-index: 100 !important;
}
.popover-area >>> .popover {
  z-index: 200 !important;
  min-width: 355px;
}
</style>
