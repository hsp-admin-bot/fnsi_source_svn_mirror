/**
 * P-Ca9分割グラフ用ヘッダ
 */
<template>
  <v-card>
    <div ref="draggable" class="custom-header-item header-item">
      <v-ons-row class="custom-mark-leftmost-header mark-leftmost-header leftmost-header">
        <v-ons-col class="custom-ons-col custom-identify">
          <div class="custom-ntss-btn ntss-button-group">
            <input
              type="radio"
              class="identification"
              name="identification"
              id="input-distribution"
              @click="switchGraphType(GRAPH_TYPE.DISTRIBUTION);"
              :checked="graphType === GRAPH_TYPE.DISTRIBUTION ? 'checked': ''"
              :disabled="!validGraphSetting"
            />
            <label ref="distribution" for="input-distribution" class="label first-of-type">分布</label>
            <input
              type="radio"
              class="identification"
              name="identification"
              id="input-progress"
              @click="switchGraphType(GRAPH_TYPE.PROGRESS);"
              :checked="graphType === GRAPH_TYPE.PROGRESS ? 'checked': ''"
              :disabled="!validGraphSetting"
            />
            <label for="input-progress" class="label last-of-type">経過</label>
          </div>
        </v-ons-col>
        <v-ons-col class="custom-ons-col custom-search">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col class="custom-ons-col custom-pull-down">
          <div class="pat-id">
            <label :style="{
              'visibility': patient ? 'visible' : 'hidden'}">
              <span>ID：</span>
              <span v-if="patient">{{ patient.hosp_pat_id }}</span>
              <!-- add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 start -->
              <img v-if="isNameFlg" class='same-icon' :src="image_src_same" />
              <!-- add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 end -->
            </label>
          </div>
          <!-- mod FNSI-4829 同姓同名、入院患者表示形式 liumx start -->
          <v-ons-select
            v-model="selPatId"
            data-non-authorize="true"
            class="mid-height"
            :disabled="!validGraphSetting"
            id="setColorPurle"
          >
          <!-- mod FNSI-4829 同姓同名、入院患者表示形式 liumx end -->
            <option :key="'pat_0'" :value="null"></option>
            <!-- mod FNSI-4829 同姓同名、入院患者表示形式 liumx start -->
            <!-- mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start -->
            <option
              v-for="(pat, index) in filterPatIdList"
              :key="`pat_${index+1}`"
              :value="pat.pat_id"
              :class="getColorPurple(pat)"
            >{{ `${pat.pat_last_name == null ? "" : pat.pat_last_name} ${pat.pat_first_name == null ? "" : pat.pat_first_name}` }}</option>
            <!-- mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end-->
            <!-- mod FNSI-4829 同姓同名、入院患者表示形式 liumx end -->
          </v-ons-select>
        </v-ons-col>

        <v-ons-col class="custom-ons-col custom-patient-group">
          <div class="custom-box-button">
            <!-- mod FNSI-画面デザイン対応 李 start -->
            <!-- <v-ons-button
              class="button"
              :disabled="
                graphType !== GRAPH_TYPE.DISTRIBUTION ||
                isShowTotalInfo ||
                !validGraphSetting
              "
              @click="updatePatientGroup"
            >
              <span>患者グループ更新</span>
            </v-ons-button> -->
            <!-- mod #11065 【03】編集権限バグ修正 関 start -->
            <v-ons-button
              class="btn1-execute"
              :disabled="
                graphType !== GRAPH_TYPE.DISTRIBUTION ||
                isShowTotalInfo ||
                !validGraphSetting ||
                !getItemAuthorized('PatInfo', 'default_authority')
              "
              @click="updatePatientGroup"
            >
            <!-- mod #11065 【03】編集権限バグ修正 関 end -->
              <span>患者グループ更新</span>
            </v-ons-button>
            <!-- <v-ons-button
              :class="{
                'button': true,
                'common-style-cancel-button': isShowTotalInfo
              }"
              @click="setSumaryArea"
              :disabled="!validGraphSetting"
            >%</v-ons-button> -->
            <v-ons-button
              :class="{
                'button': true,
                'common-style-cancel-button': isShowTotalInfo,
                'btn2-cancel': isShowTotalInfo,
                'btn3-normal': !isShowTotalInfo
              }"
              @click="setSumaryArea"
              :disabled="!validGraphSetting"
            >集計</v-ons-button>
            <!-- mod FNSI-画面デザイン対応 李 end -->
          </div>
        </v-ons-col>
        <v-ons-col class="custom-ons-col custom-spacer"></v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet,'popover-area']"
    >
      <div style="margin:10px;">
        <!-- 日付選択1 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>検査日開始</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
            <!-- <input
              input-id="startDate"
              class="input-area input-search-date"
              type="date"
              max="9999-12-31"
              float
              v-model="condition.inProgress.startDate"
              @click="hideArrowDate"
              @input="setStartDateValue($event.target.value)"
            /> -->
            <date-input
              input-id="startDate"
              :classes="'input-area input-search-date ntss-input-date'"
              float
              v-model="condition.inProgress.startDate"
              @handleClearInput="condition.inProgress.startDate = null"
              @click="hideArrowDate"
              @input="setStartDateValue($event)"
            />
            <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.inProgress.startDate" class="calender" />
          </v-ons-col>
        </v-ons-row>
        <!-- 日付選択2 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>検査日終了</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
            <!-- <input
              input-id="endDate"
              class="input-area input-search-date"
              type="date"
              max="9999-12-31"
              float
              v-model="condition.inProgress.endDate"
              @click="hideArrowDate"
              @input="setEndDateValue($event.target.value)"
            /> -->
            <date-input
              input-id="endDate"
              :classes="'input-area input-search-date ntss-input-date'"
              float
              v-model="condition.inProgress.endDate"
              @handleClearInput="condition.inProgress.endDate = null"
              @click="hideArrowDate"
              @input="setEndDateValue($event)"
            />
            <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.inProgress.endDate" class="calender" />
          </v-ons-col>
        </v-ons-row>

        <div class="condition-row" style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <!-- mod FNSI-画面デザイン対応 李 start -->
            <!-- <v-ons-button class="clear" @click="dialogClear">クリア</v-ons-button> -->
            <v-ons-button class="btn2-cancel width-padding" @click="dialogClear">クリア</v-ons-button>
            <!-- mod FNSI-画面デザイン対応 李 end -->
          </div>
          <div style="float:right;">
            <!-- mod FNSI-画面デザイン対応 李 start -->
            <!-- <v-ons-button
              class="ok"
              @click="search"
              :disabled="!condition.inProgress.startDate && !condition.inProgress.endDate"
            >OK2</v-ons-button> -->
            <v-ons-button
              class="btn3-normal width-padding"
              @click="search"
              :disabled="!condition.inProgress.startDate && !condition.inProgress.endDate"
            >OK</v-ons-button>
            <!-- mod FNSI-画面デザイン対応 李 end -->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters } from "vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { EventBus } from "@/eventBus.js";
import moment from "moment";
import PopoverMixin from "@/components/PopoverMixin";
import store from "@/stores";
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end
// add #11065 【03】編集権限バグ修正 関 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #11065 【03】編集権限バグ修正 関 end

export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  name: "SplitGraphHeader",

  data() {
    const defaultCondition = {
      startDate: moment()
        .subtract(3, "months")
        .format("YYYY-MM-DD"),
      endDate: moment().format("YYYY-MM-DD")
    };

    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      // グラフタイプ：分布／経過
      typeflag:'',
      // 抽出条件
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
      selPatId: null,  // ← 患者選択プルダウンリストv-modelとバインド
      patient: null,
      GRAPH_TYPE: {
        PROGRESS: "line",
        DISTRIBUTION: "scatter",
        BLANK: "blank"
      },
      fontSize: [0.8, 1, 1.1, 1.3],
      // mod FNSI-選択している患者での表示とする 楊 start
      befSelectedPatId: null,
      // mod FNSI-選択している患者での表示とする 楊 end
      patientIdWithExamList: [],
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 start
      // 同姓同名アイコン
      image_src_same: require('../../assets/name_duplication3.png'),
      isNameFlg: false,
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 end
      destroyDragHandler: null
    };
  },
  computed: {
    // mod FNSI-選択している患者での表示とする 楊 start
    ...mapGetters("pat-info", ["selectedPatId"]),
    // mod FNSI-選択している患者での表示とする 楊 end
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("split-graph", {
      graphType: "getGraphType",
      isShowTotalInfo: "sumaryArea",
      selectedAreas: "getSelectedAreas",
      validGraphSetting: "getValidGraphSettingStatus",
      //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
      selectedPatient: "getSelectedPatient",
      selPatient: "getSelPatient",
      selType: "getSelType",
      selCondition: "getCondition",
      //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    }),
    ...mapGetters("pat-info", {
      searchedPatList: "searchedPatList",
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 start
      selectedPat: "selectedPat"
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 end
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    filterPatIdList() {
      let reList = this.searchedPatList.filter(x => {
        return this.patientIdWithExamList.includes(x.pat_id.toString());
      });
      if (reList && reList.length === 0) {
        this.setBefPat(null);
      }
      
      // 選択中患者が患者検索＞患者リストから消えた場合は選択状態解除
      // ID欄の表示が残らないようにthis.patientをクリア
      if (this.patient && !reList.some(item => item.pat_id === this.patient.pat_id)) {
        this.patient = null;
      } 
      
      //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
      this.setRestPat(reList.length);
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
      this.setSelPat(reList);
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
      //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
      return reList;
    }
  },
  watch: {
    // 検索患者リストの更新契機でグラフデータを取得するイベントを通知する
    searchedPatList() {
      if (Array.isArray(this.searchedPatList)) {
        // 検索患者リストが１件以上の場合は更新が２回発生する
        if (this.searchedPatList.length) {
          // 検索患者リストの２回目の更新で変更が終了する（'pat_name_sort' プロパティを含む）
          if (!('pat_name_sort' in this.searchedPatList[0])) {
            // 検索患者リストの１回目の更新は無視する
            return;
          }
        }
        // 検索患者リストが０件または１件で'pat_name_sort' プロパティを含む場合
        EventBus.$emit("searchExam");
      }
    },
    patient() {
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 start
      if (this.patient && this.patient['is_same'] == '1') this.isNameFlg = true;
      else this.isNameFlg = false;
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 end

      // add FNSI-4829 同姓同名、入院患者表示形式 liumx start
      if(this.patient && this.patient.in_out_class == '1'){
        document.getElementById("setColorPurle").getElementsByTagName("select")[0].style.color="#A356A3";
      }
      else {
        document.getElementById("setColorPurle").getElementsByTagName("select")[0].style.color="black";
      }

      // 患者選択プルダウンリスト 選択値設定
      this.selPatId = this.patient ? this.patient.pat_id : null;
      
      // add FNSI-4829 同姓同名、入院患者表示形式 liumx end
      this.setSelectedPatient(this.patient);
      if (!this.patient) {
        this.switchGraphType(this.GRAPH_TYPE.DISTRIBUTION);
      }
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
      this.setSelectPat(this.patient);
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
    },
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 start
    selectedPat() {
      if (this.selectedPat && this.selectedPat.pat_main['is_same'] == '1') this.isNameFlg = true;
      else this.isNameFlg = false;
      // add FNSI-4829 同姓同名、入院患者表示形式 liumx start
      if (this.selectedPat && this.selectedPat.pat_personal_main.in_out_class == '1') {
        document.getElementById("setColorPurle").getElementsByTagName("select")[0].style.color="#A356A3";
      }
      else {
        document.getElementById("setColorPurle").getElementsByTagName("select")[0].style.color="black";
      }
      // add FNSI-4829 同姓同名、入院患者表示形式 liumx end
    },
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 end
    selPatId(patId) {
      // 患者選択時に選択患者Object（ストア保持）を設定
      this.patient = this.filterPatIdList.find(p => p.pat_id === patId) || null;
    }
  },
  methods: {
    ...mapActions("split-graph", [
      "setCondition",
      "setGraphType",
      "setSumaryArea",
      "setSelectedPatient",
      //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
      "setSelPatient",
      "setSelType",
      //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
      "setSelPat",
      "setSelectPat",
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
    ]),
    // add FNSI-4829 同姓同名、入院患者表示形式 liumx start
    getColorPurple(str){
      const funcCd = getCurrentFunctionCd();
      if (this.typeflag == "scatter") { // 分布
        this.printFlag = 0;
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 0});
      } else if (this.typeflag == "line" && this.printFlag == 1) { // 経過
        this.printFlag = 1;
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 1});
      }
      if(str && str.in_out_class == '1'){
        return "color-purple";
      }else{
        return "color-black";
      }
    },
    // add FNSI-4829 同姓同名、入院患者表示形式 liumx end
    switchGraphType(type) {
      this.typeflag= type;
      const funcCd = getCurrentFunctionCd();
      this.printFlag = this.selectedPat;
      if ( this.selectedPat === null ) {
        this.printFlag = 0;
      } else if ( this.selectedPat !== null ) {
        this.printFlag = 1;
      }
      if (type == "scatter") { // 分布
        this.printFlag = 0;
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 0});
      } else if (type == "line" && this.printFlag == 1) { // 経過
        this.printFlag = 1;
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 1});
      }
      if (type === this.GRAPH_TYPE.PROGRESS && !this.patient) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "患者を選択してください。"
          title: DIALOG_MESSAGES[50000008].title,
          message: messageFormat(DIALOG_MESSAGES[50000008].message),
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        this.$refs.distribution.click();
        return;
      }
      this.setGraphType(type);
      if (this.isShowTotalInfo) {
        this.setSumaryArea();
      }
    },
    /**
     * 開始日設定
     */
    setStartDateValue(value) {
      if (value === "" || value === null) {
        this.condition.inProgress.startDate = "";
      }
    },
    /**
     * 終了日設定
     */
    setEndDateValue(value) {
      if (value === "" || value === null) {
        this.condition.inProgress.endDate = "";
      }
    },
    /**
     * ポップオーバー表示
     */
    showPopover(event) {
      if (!this.validGraphSetting) {
        return;
      }
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    /**
     * クリアする。
     */
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.inUsed = deepCopy(this.defaultCondition);
      this.copyConditionInUsedToInProgress();
      // 画面を閉じる
      this.search();
    },
    /**
     * 検索する
     */
    search() {
      if (
        moment(this.condition.inProgress.startDate) >
        moment(this.condition.inProgress.endDate)
      ) {
        const tempDate = this.condition.inProgress.startDate;
        this.condition.inProgress.startDate = this.condition.inProgress.endDate;
        this.condition.inProgress.endDate = tempDate;
      }
      this.copyConditionInProgressToInUsed();
      this.setConditionList();
      this.setCondition(deepCopy(this.condition.inUsed));
      this.popoverVisible = false;
      EventBus.$emit("searchExam");
    },
    /**
     * 実際検索条件に入力中条件をコードする。
     */
    copyConditionInProgressToInUsed() {
      this.condition.inUsed = deepCopy(this.condition.inProgress);
    },
    /**
     * 入力中条件に実際検索条件をコードする。
     */
    copyConditionInUsedToInProgress() {
      this.condition.inProgress = deepCopy(this.condition.inUsed);
    },
    /**
     * 共通検索エリア部品に表示するデータのリストを作成
     */
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;

      // 検査日開始
      if (condObj.startDate) {
        condList.push({ name:"検査日開始", text:condObj.startDate.replace(/-/g, "/") });
      }
      // 検査日終了
      if (condObj.endDate) {
        condList.push({ name:"検査日終了", text:condObj.endDate.replace(/-/g, "/") });
      }
      this.conditionList = condList;
    },
    /**
     * 患者グループ更新
     */
    updatePatientGroup() {
      EventBus.$emit("updatePatientGroup");
    },

    /**
     * ヘッダー情報設定
     */
    setHeaderInfo(plot) {
      if (plot.patInfo && plot.patInfo.patId) {
        let patientId = plot.patInfo.patId;
        this.patient = this.searchedPatList.find(
          pat => pat.pat_id.toString() === patientId
        );
      }
      this.switchGraphType(plot.graphType);
    },
    hideArrowDate() {
      const getInputDateClass = document.getElementsByClassName("input-search-date");
      getInputDateClass[0].addEventListener('keydown', (event) => {
          if (event.key == "ArrowDown" || event.key == "ArrowUp") {
            event.preventDefault();
          }
      }, false);
      getInputDateClass[1].addEventListener('keydown', (event) => {
          if (event.key == "ArrowDown" || event.key == "ArrowUp") {
            event.preventDefault();
          }
      }, false);
    },
    setPatList(patList) {
      this.patientIdWithExamList = patList;
    },
    // mod FNSI-選択している患者での表示とする 楊 start
    setBefPat(befSelected) {
      this.befSelectedId = befSelected;
    },
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    setRestPat(patSize){
      if (this.selType&&patSize>0) {
          this.patient = this.selPatient;
          this.switchGraphType(this.selType);
          this.setSelType(null);
          this.setSelPatient(null);
          }
    },
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end

    setPatient(patient) {
      this.patient = patient;
    },
    // mod FNSI-選択している患者での表示とする 楊 end
    initDragHandler() {
      const target = this.$refs.draggable;
      if (!target) return;

      const scrollState = {
        down: false,
        startX: 0,
        startScrollLeft: 0,
      };
      let handleMouseDown = (event) => {
        scrollState.down = true;
        scrollState.startX = event.clientX;
        scrollState.startScrollLeft = target.scrollLeft;
        event.stopPropagation();
      };
      let handleMouseMove = (event) => {
        if (!scrollState.down) return;
        event.preventDefault();
        // スマホのスワイプと方向を合わせた計算にする
        const scrolled = target.scrollLeft - scrollState.startScrollLeft;
        const moveX = event.clientX + scrolled - scrollState.startX;
        target.scrollLeft = scrollState.startScrollLeft - moveX;
        event.stopPropagation();
      };
      let handleMouseUp = (event) => {
        if (!scrollState.down) return;
        scrollState.down = false;
        event.stopPropagation();
      };
      this.destroyDragHandler = () => {
        if (target) {
          target.removeEventListener("mousedown", handleMouseDown);
          document.removeEventListener("mousemove", handleMouseMove);
          document.removeEventListener("mouseup", handleMouseUp);
        }
        handleMouseDown = null;
        handleMouseMove = null;
        handleMouseUp = null;
        this.destroyDragHandler = null;
      };
      target.addEventListener("mousedown", handleMouseDown);
      document.addEventListener("mousemove", handleMouseMove);
      document.addEventListener("mouseup", handleMouseUp);
    },
    // add #11065 【03】編集権限バグ修正 関 start
    getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
    },
    // add #11065 【03】編集権限バグ修正 関 end
  },
  created() {
    this.switchGraphType(this.GRAPH_TYPE.DISTRIBUTION);
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    if (this.selType) {
        this.condition.inProgress = this.selCondition;
    }
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    this.search();
    this.setSelectedPatient(null);
    // add 性能改善メモリ不足 shan start
    EventBus.$off("setHeaderInfo");
    //mod 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    //EventBus.$off("setPatList");
    EventBus.$off("setPatList", data => this.setPatList(data));
    //mod 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    // add 性能改善メモリ不足 shan end

    EventBus.$on("setHeaderInfo", data => this.setHeaderInfo(data));
    EventBus.$on("setPatList", data => this.setPatList(data));
  },
  mounted() {
    this.initDragHandler();
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    this.destroyDragHandler?.();
    EventBus.$off("setHeaderInfo");
    //mod 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    //EventBus.$off("setPatList");
    EventBus.$off("setPatList", data => this.setPatList(data));
    //mod 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    // dataの初期化
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    this.setSelType(this.typeflag);
    this.setSelPatient(this.patient);
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
    this.setSelPat(null);
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    Object.assign(this.$data, this.$options.data());
  }
  // add 性能改善メモリ不足 shan end
};
</script>
<style scoped>
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 100%;
  display: flex;
  justify-content: center;
}

.label {
  display: block;
  float: left;
  width: fit-content;
  white-space: nowrap;
  height: 30px;
  padding-left: 1em;
  padding-right: 1em;
  color: #ffffff;
  text-align: center;
  line-height: 30px;
  cursor: pointer;
  font-size: 1.5em;
}
.first-of-type {
  margin-left: 4px;
  border-radius: 10px 0 0 10px;
  /* add FNSI-4458 文字サイズ：特大の際の遷移先表示の不正 liumx start */
  width: 45%;
  /* add FNSI-4458 文字サイズ：特大の際の遷移先表示の不正 liumx end */
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  /* add FNSI-4458 文字サイズ：特大の際の遷移先表示の不正 liumx start */
  width: 45%;
  /* add FNSI-4458 文字サイズ：特大の際の遷移先表示の不正 liumx end */
}
.input-area::-webkit-inner-spin-button,
.input-area::-webkit-calendar-picker-indicator {
  display: none;
  -webkit-appearance: none;
}

.popover-area >>> .popover-mask {
  z-index: 100 !important;
}
.popover-area >>> .popover {
  z-index: 200 !important;
}
ons-popover >>> .popover--top {
  width: 30em;
}
.button {
  width: auto;
  margin-left: 4px;
}
.mid-height {
  width: 100%;
  margin-top: 4px;
}
.pat-id {
  font-size: 1.5em;
  color: var(--ntss-header-color);
  margin-top: 2px;
}
.text-center {
  text-align: center;
}
.custom-ons-col {
  height: 100%;
}
.custom-identify {
  flex: 0 0 fit-content;
  min-width: 15%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.custom-search {
  flex: 1 1 auto;
  min-width: 30em;
}
.custom-search >>> .condition-search-icon-area {
  position: inherit;
}
.custom-pull-down {
  flex: 0 0 fit-content;
  min-width: 20em;
}
.custom-patient-group {
  flex: 0 0 fit-content;
}
.custom-box-button {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  font-size: 1.5em;
}
.custom-box-button > .button {
  width: auto;
  height: auto;
  padding: 0 10px;
}
.custom-spacer {
  flex: 0 0 70px;
}
.custom-mark-leftmost-header {
  width: auto;
  flex-wrap: nowrap;
}
.custom-header-item {
  overflow-x: auto;
  overflow-y: hidden;
}
.custom-header-item::-webkit-scrollbar {
  display: none;
}
ons-select >>> .select-input {
  font-size: 1.5em;
  line-height: 1.1em;
}
/* add FNSI-画面デザイン対応 李 start */
.width-padding {
  width: 80px;
  padding-top: 7px;
}
/* add FNSI-画面デザイン対応 李 end */
/* add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 start */
.same-icon{
  height: 1.0em;
  display: inline-block;
  margin-left: 0.5em;
}
/* add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 李 end */
/* add FNSI-4829 同姓同名、入院患者表示形式 liumx start */
.color-purple{
  color: #A356A3;
}
.color-black{
  color: black;
}
/* add FNSI-4829 同姓同名、入院患者表示形式 liumx end */
</style>
