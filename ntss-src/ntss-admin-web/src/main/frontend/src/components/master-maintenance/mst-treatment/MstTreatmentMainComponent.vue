<template>
  <div class="main-area">
    <div id="treatment-area-div" class="print-height-auto">
      <table class="treatment-area custom-treatment-area">
        <tr>
          <td class="item-area">
            治療方法名
          </td>
          <td>
            <input
              class="k-textbox"
              :value="getEditRecord.name"
              @blur="setTreatName($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            装置モード
          </td>
          <td>
            <input class="device-mode" style="width: 100%;" />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            グラフ時間幅
          </td>
          <td>
            <input class="graph-time-scale" style="width: 100%;" />
          </td>
        </tr>
        <tr>
          <!--4644治療条件設定を上寄せにする add style 鞠-->
          <td class="item-area" style="vertical-align: text-top;padding-top: 9px">
            <!--      mod 治療方法マスタ 再依赖 「透析条件設定」の文言不正、「治療条件設定」に変更 孔 start-->
            <!--透析条件設定-->
            治療条件設定
            <!--      mod 治療方法マスタ 再依赖 「透析条件設定」の文言不正、「治療条件設定」に変更 孔 end-->
          </td>
          <td>
            <div class="disp-item-content-area">
              <div>
                <v-ons-row
                  v-for="category in treatmentConditionSetting"
                  :key="category.category_no"
                >
                  <v-ons-row class="color-header layout-item">
                    <v-ons-col>
                      <div v-if="category.category_no !== 1" class="header-category-title">
                        <v-ons-checkbox
                          class="checkbox-style"
                          :checked="getCheckBoxState(category.is_use)"
                          v-if="category.is_disabled"
                          @click.stop.prevent
                        />
                        <v-ons-checkbox
                          class="checkbox-style"
                          :checked="getCheckBoxState(category.is_use)"
                          v-if="!category.is_disabled"
                          @click="onChange(category, $event)"
                        />
                        {{ category.category_name }}
                      </div>
                      <div v-else class="header-category-title">
                        {{ category.category_name }}
                      </div>
                    </v-ons-col>
                  </v-ons-row>
                  <v-ons-col>
                    <v-ons-col v-for="item in category.items" :key="item.ctl_no">
                      <div v-if="category.category_no === 1" class="item-wrapper">
                        <v-ons-checkbox
                          class="checkbox-style"
                          :checked="getCheckBoxState(item.is_use)"
                          :disabled="item.is_disabled"
                          @click="onChangeItem(item, $event)"
                        />
                        {{ item.name }}
                      </div>
                      <div v-else>
                        {{ item.name }}
                      </div>
                    </v-ons-col>
                  </v-ons-col>
                </v-ons-row>
              </div>
            </div>
          </td>
        </tr>
        <tr>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 start -->
          <!-- <td class="item-area">治療経過表ID</td> -->
          <td class="item-area">治療経過表</td>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 end -->
          <td>
            <input class="report-item" style="width: 100%;" id="report"/>
          </td>
        </tr>
        <tr>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 start -->
          <!-- <td class="item-area">治療経過表ID（手書き）</td> -->
          <td class="item-area">治療経過表（手書き）</td>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 end -->
          <td>
            <input class="report-item" style="width: 100%;" id="reportHw"/>
          </td>
        </tr>
        <tr>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 start -->
          <!-- <td class="item-area">治療経過表ID（前体重）</td> -->
          <td class="item-area">治療経過表（前体重）</td>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 end -->
          <td>
            <input class="report-item" style="width: 100%;" id="reportBw"/>
          </td>
        </tr>
        <tr>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 start -->
          <!-- <td class="item-area">治療経過表ID（後体重）</td> -->
          <td class="item-area">治療経過表（後体重）</td>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 end -->
          <td>
            <input class="report-item" style="width: 100%;" id="reportAw"/>
          </td>
        </tr>
        <tr>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 start -->
          <!-- <td class="item-area">治療経過表ID（装置画像転送用）</td> -->
          <td class="item-area">治療経過表（装置画像転送用）</td>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 end -->
          <td>
            <input class="report-item" style="width: 100%;" id="reportDev"/>
          </td>
        </tr>
        <!-- add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s start -->
        <tr>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 end -->
          <!-- <td class="item-area">治療経過表ID（実績確定）</td> -->
          <td class="item-area">治療経過表（実績確定）</td>
          <!-- mod 治療方法マスタ 再依頼 治療経過表ID => 治療経過表 孔 end -->
          <td>
            <input class="report-item" style="width: 100%;" id="reportAct"/>
          </td>
        </tr>
        <!-- add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s end -->
        <tr>
          <td class="item-area">
            利用開始日A
          </td>
          <td>
            <div class="d-flex align-items-center">
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
              <!-- <input
                class="k-textbox ntss-input-date"
                v-model="inHospAStartdate"
                type="date"
                @blur="setTreatInHospAStartdate"
              /> -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start -->
               <!-- <date-input
                :classes="'k-textbox ntss-input-date'"
                v-model="inHospAStartdate"
                max="9999-12-31"
                style="width:100%"
                @handleClearInput="inHospAStartdate = null"
                @blur="setTreatInHospAStartdate"
              /> -->
              <date-input
                :classes="'k-textbox ntss-input-date'"
                v-model="inHospAStartdate"
                max="9999-12-31"
                style="width:100%"
                @handleClearInput="inHospAStartdate = null;setTreatInHospAStartdate()"
                @blur="setTreatInHospAStartdate"
              />
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end -->
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="inHospAStartdate" @input="setTreatInHospAStartdate" />
            </div>
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードA-1
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdA1"
              @blur="setTreatInHospitalCdA1($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードA-2
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdA2"
              @blur="setTreatInHospitalCdA2($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードA-3
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdA3"
              @blur="setTreatInHospitalCdA3($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードA-4
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdA4"
              @blur="setTreatInHospitalCdA4($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            利用開始日B
          </td>
          <td>
            <div class="d-flex align-items-center">
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
              <!-- <input
                class="k-textbox ntss-input-date"
                v-model="inHospBStartdate"
                type="date"
                @blur="setTreatInHospBStartdate"
              /> -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start -->
              <!-- <date-input
                :classes="'k-textbox ntss-input-date'"
                v-model="inHospBStartdate"
                max="9999-12-31"
                style="width:100%"
                @handleClearInput="inHospBStartdate = null"
                @blur="setTreatInHospBStartdate"
              /> -->
               <date-input
                :classes="'k-textbox ntss-input-date'"
                v-model="inHospBStartdate"
                max="9999-12-31"
                style="width:100%"
                @handleClearInput="inHospBStartdate = null;setTreatInHospBStartdate()"
                @blur="setTreatInHospBStartdate"
              />
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end -->
              <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="inHospBStartdate" @input="setTreatInHospBStartdate" />
            </div>
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードB-1
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdB1"
              @blur="setTreatInHospitalCdB1($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードB-2
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdB2"
              @blur="setTreatInHospitalCdB2($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードB-3
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdB3"
              @blur="setTreatInHospitalCdB3($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td class="item-area">
            連携コードB-4
          </td>
          <td>
            <input
              class="k-textbox"
              maxlength="20"
              :value="getEditRecord.inHospitalCdB4"
              @blur="setTreatInHospitalCdB4($event.target.value)"
            />
          </td>
        </tr>
      </table>
    </div>
    <!-- ボタンエリア -->
    <div class="treatment-button-area custom-treatment-button-area">
      <v-ons-button
        ref="monitorItemSelector"
        class="btn3-normal treatment-button-area-button"
        @click="listSelectMonitor()">モニタ表示設定</v-ons-button>
      <v-ons-button
        ref="treandGraphMonitorItemSelector"
        class="btn3-normal treatment-button-area-button"
        @click="listSelectTrendGraphMonitor()">トレンドグラフモニタ設定</v-ons-button>
      <!-- 帳票グラフ設定 -->
      <v-ons-button
        class="btn3-normal treatment-button-area-button"
        @click="showReportGraphSetting()"
        style="margin-right: 0px;">帳票グラフ設定</v-ons-button>
    </div>
    <!-- モニタ表示設定 -->
    <list-selector
      :key="componentKey('モニタ表示設定')"
      :visible.sync="isDispMonitorItemVisible"
      v-bind="dispMonitorItemSelectorData"
      :target="selectorTarget('monitorItemSelector')"
      :sort="true"
      @commit="commitDispMonitorItem($event)"
    />
    <!-- トレンドグラフモニタ設定 -->
    <list-selector
      :key="componentKey('トレンドグラフモニタ設定')"
      :visible.sync="isTrendGraphMonitorItemVisible"
      v-bind="treandGraphMonitorItemSelectorData"
      :target="selectorTarget('treandGraphMonitorItemSelector')"
      :sort="true"
      @commit="commitTrendGraphMonitorItem($event)"
    />
  </div>
</template>

<!-- スクリプト処理 -->
<script>
import $$ from "jquery";
import {EventBus} from "@/eventBus";
import { mapGetters, mapActions } from "vuex";
import {
  // 定数
  DIAL_COND_ID,
  DIAL_COND_ITEMS
} from "@/components/side-contents/SearchDefinitions.js";
import {
  DEVICEMODE,
  CATEGORY_NO,
  categoryNameList,
  mstTreatmentCondSettingDefine
} from "@/constants/mstTreatmentDefine.js";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import moment from "moment";
import { createItemListData } from "@/functions/for-componet/ListSelector.js";
// 共通コンポーネント
import listSelector from "@/components/common/list-selector/ListSelector.vue";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
//#5590 2023/04/18 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/18 ×を常に表示するように修正 張博 end
import isEqual from "lodash/isEqual";
export default {
  components: {
    "list-selector": listSelector,
    "common-calendar": commonCalender,
    //#5590 2023/04/18 ×を常に表示するように修正 張博 start
    DateInput,
    //#5590 2023/04/18 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      //編集中マスタの装置モード
      editDeviceMode: "",
      //選択中マスタの装置モード
      selectDeviceMode: "",
      //編集中マスタのグラフ時間幅
      editGraphTimeScale: "",
      //選択中マスタのグラフ時間幅
      selectGraphTimeScale: "",
      //透析条件設定
      treatmentConditionSetting: [],
      //createdが終了したかのフラグ(getCheckBoxState関数の動作条件)
      endCreate: false,
      // 編集中マスタの治療経過表ID
      editReportId: "",
      // 選択中マスタの治療経過表ID
      selectReportId: "",
      // 編集中マスタの治療経過表ID(手書き用)
      editReportIdHw: "",
      // 選択中マスタの治療経過表ID(手書き用)
      selectReportIdHw: "",
      // 編集中マスタの治療経過表ID(前体重)
      editReportIdBw: "",
      // 選択中マスタの治療経過表ID(前体重)
      selectReportIdBw: "",
      // 編集中マスタの治療経過表ID(後体重)
      editReportIdAw: "",
      // 選択中マスタの治療経過表ID(後体重)
      selectReportIdAw: "",
      // 編集中マスタの治療経過表ID(装置画像転送用)
      editReportIdDev: "",
      // 選択中マスタの治療経過表ID(装置画像転送用)
      selectReportIdDev: "",
      // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s start
      // 編集中マスタの治療経過表ID(実績確定)
      editReportIdAct: "",
      // 選択中マスタの治療経過表ID(実績確定)
      selectReportIdAct: "",
      // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s end
      // モニタ表示項目フラグ
      isDispMonitorItemVisible: false,
      // トレンドグラフモニタ設定フラグ
      isTrendGraphMonitorItemVisible: false,
      // モニタ表示項目の選択肢データ
      dispMonitorItemSelectorData: null,
      // トレンドグラフモニタ設定選択肢データ
      treandGraphMonitorItemSelectorData: null,
      // 選択中のモニタ表示項目
      dispMonitorItemSelectedData: null,
      // 選択中のトレンドグラフモニタ設定
      trendGraphMonitorItemSelectedData: null,
      // 選択肢に表示するモニタ項目一覧
      dispMonitorItemList: [],

      // 選択肢に表示するモニタ項目一覧
      dispDLGraphItemList: [],

      inHospAStartdate: "",
      initHospAStartdate: "",
      inHospBStartdate: "",
      initHospBStartdate:"",
      initGetEditRecord:"",
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getFacilitySwitch",
      "getColumns",
      "getEditRecord",
      "getMasterRecordList",
      "getFilteredMasterRecordList"
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth",
      windowHeight: "getWindowHeight"
    }),
    // add 字体を変更すると 詳細画面のスタイルの変化 鞠 start
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    // add 字体を変更すると 詳細画面のスタイルの変化 鞠 end
    /**
     * @description 装置モードのリスト
     */
    deviceModeList() {
      // mod 障害No.175 治療方法マスタ 王 start
      //装置モード選択リスト 取得
      let mstDeviceMode = this.getColumns.find(
        col => col.field === "deviceMode"
      ).values;

      mstDeviceMode = mstDeviceMode.filter((item)=>
       item.value !== 4 && item.value !== 5
      )
      // mod 障害No.175 治療方法マスタ 王 end
      return mstDeviceMode;
    },
    /**
     * @description グラフ時間幅のリスト
     */
    graphTimeScaleList() {
      //グラフ時間幅選択リスト 取得
      const graphTimeScaleList = this.getColumns.find(
        col => col.field === "graphTimeScale"
      ).values;

      return graphTimeScaleList;
    },
  },
  watch: {
    /**
     * ウィンドウ幅が変更された時
     */
    //mod マスタ詳細画面がありません破棄メッセージ
    getEditRecord:{
      handler(newVal){
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
        // if (JSON.stringify(this.initGetEditRecord)!==JSON.stringify(newVal)) {
        //   this.changeButton();
        // }else{
        //   EventBus.$emit("mstHolidayRegistered", true);
        // }
        if (this.compareObjects(this.initGetEditRecord, newVal)) {
          EventBus.$emit("mstHolidayRegistered", true);
        }else{
          this.changeButton();
        }
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
      },
      deep:true
    },
    windowWidth() {
      this.calculateWindowsSize();
    },
    /**
      * ウィンドウの高さが変更された時
      */
    windowHeight() {
      this.calculateWindowsSize();
    },
    /**
     * add 字体を変更すると 詳細画面のスタイルの変化 鞠
     */
    getFontSize() {
      this.calculateWindowsSize();
    },
  },
  created() {
    this.inHospAStartdate = this.getEditRecord.inHospAStartdate ? moment(this.getEditRecord.inHospAStartdate).format("YYYY-MM-DD") : "";
    this.inHospBStartdate = this.getEditRecord.inHospBStartdate ? moment(this.getEditRecord.inHospBStartdate).format("YYYY-MM-DD") : "";
    this.initHospAStartdate = this.inHospAStartdate;
    this.initHospBStartdate = this.inHospBStartdate;
    // 透析条件データを取得
    this.treatmentConditionSetting = this.getEditRecord
      .treatmentConditionSetting
      ? JSON.parse(this.getEditRecord.treatmentConditionSetting)
      : mstTreatmentCondSettingDefine;

    /**
     * @description 装置モードの初期表示処理
     */
    // 編集中マスタの装置モードを保持
    this.editDeviceMode = this.getEditRecord.deviceMode;
    // 編集中マスタの装置モードを初期選択(未登録で保存された装置モードは空文字で取得されるのでnullに置き換える)
    this.selectDeviceMode =
      this.editDeviceMode === "" ? null : this.editDeviceMode;
    /**
     * @description グラフ時間幅の初期表示処理
     */
    // 編集中マスタのグラフ時間幅を保持
    this.editGraphTimeScale = this.getEditRecord.graphTimeScale;
    // 編集中マスタのグラフ時間幅を初期選択(未登録で保存された装置モードは空文字で取得されるのでnullに置き換える)
    this.selectGraphTimeScale =
      this.editGraphTimeScale === "" ? null : this.editGraphTimeScale;

    /**
     * @description 各治療経過表IDの初期表示処理
     */
    // 治療経過表ID
    this.editReportId = this.getEditRecord.reportId;
    this.selectReportId = this.editReportId === "" ? null : this.editReportId;
    // 治療経過表ID(手書き)
    this.editReportIdHw = this.getEditRecord.reportIdHw;
    this.selectReportIdHw = this.editReportIdHw === "" ? null : this.editReportIdHw;
    // 治療経過表ID(前体重)
    this.editReportIdBw = this.getEditRecord.reportIdBw;
    this.selectReportIdBw = this.editReportIdBw === "" ? null : this.editReportIdBw;
    // 治療経過表ID(後体重)
    this.editReportIdAw = this.getEditRecord.reportIdAw;
    this.selectReportIdAw = this.editReportIdAw === "" ? null : this.editReportIdAw;
    // 治療経過表ID(装置画像転送用)
    this.editReportIdDev = this.getEditRecord.reportIdDev;
    this.selectReportIdDev = this.editReportIdDev === "" ? null : this.editReportIdDev;
    // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s start
    // 治療経過表ID(装置画像転送用)
    this.editReportIdAct = this.getEditRecord.reportIdAct;
    this.selectReportIdAct = this.editReportIdAct === "" ? null : this.editReportIdAct;
    // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s end

    // モニタ表示項目
    this.dispMonitorItemSelectedData = this.getEditRecord.monitorDataItemScreen
        ? JSON.parse(this.getEditRecord.monitorDataItemScreen)
        : [];
    // トレンドグラフ
    this.trendGraphMonitorItemSelectedData = this.getEditRecord.monitorDataItemPrint
      ? JSON.parse(this.getEditRecord.monitorDataItemPrint)
      : [];
    setTimeout(() => {
      // リサイズ
      this.calculateWindowsSize();
    },100);
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
    // this.initGetEditRecord =JSON.parse(JSON.stringify(this.getEditRecord));
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
  },
  mounted() {
    // createdが終わった後でフラグをtrueに(チェックボックスを付ける関数が動くよう変更、this.retrieveMstData()でチェックが付く)
    this.endCreate = true;

    const vue = this;
    /**
     * @description 装置モードのプルダウンを作成
     */

    //画面に表示する装置モードを保持(新規登録時は"不明"、編集時は選択した装置モードを設定)
    const shownDeviceMode =
      this.selectDeviceMode === null ? "-1" : this.selectDeviceMode;

    //新規登録の場合、"その他"を初期表示する処理
    if (null === this.selectDeviceMode) {
      this.setDeviceMode(shownDeviceMode);
    }

    $$(".device-mode").kendoDropDownList({
      //使用する値をそれぞれ設定
      dataSource: this.deviceModeList,
      dataTextField: "text",
      dataValueField: "value",
      //画面に表示する値を設定
      value: shownDeviceMode,
      //選択した装置モードをマスタに登録
      change() {
        vue.changeDeviceMode(this.value());
      }
    });

    /**
     * @description グラフ時間幅のプルダウンを作成
     */

    //画面に表示するグラフ時間幅を保持(新規登録時は「6」、編集時は選択したグラフ時間幅を設定)
    const shownGraphTimeScale =
      this.selectGraphTimeScale === null ? 6 : this.selectGraphTimeScale;

    //新規登録の場合
    if (null === this.selectGraphTimeScale) {
      this.setGraphTimeScale(shownGraphTimeScale);
    }

    $$(".graph-time-scale").kendoDropDownList({
      //使用する値をそれぞれ設定
      dataSource: this.graphTimeScaleList,
      dataTextField: "text",
      dataValueField: "value",
      //画面に表示する値を設定
      value: shownGraphTimeScale,
      //選択したグラフ時間幅をマスタに登録
      change() {
        vue.changeGraphTimeScale(this.value());
      }
    });

    /**
     * @description 透析条件設定データ
     */
    // 画面表示用データの作成
    this.retrieveMstData();
    // 透析条件設定チェック編集可能項目切替
    this.disabledCondItem(shownDeviceMode);
    if ("" === this.getEditRecord.treatmentConditionSetting) {
      // 透析条件設定変更(新規登録時は内容反映のため実施)
      this.setDispItemInfo(this.treatmentConditionSetting);
    }

    /**
     * @description 治療経過表のプルダウンを作成.
     */
    Promise.all([
        // mod マスタ一覧 1･施設切替を可能とする 孔s start
        // ApiHelper.get(`/report/getMstReportByFacilityCd/${this.facilityCd}`)
        // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
        // ApiHelper.get(`/report/getMstReportByFacilityCd/${this.getFacilitySwitch}`)
        ApiHelper.get(`/report/getMstReportByFacilityCdNoIsDisp/${this.getFacilitySwitch}`)
        // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
        // mod マスタ一覧 1･施設切替を可能とする 孔s end
    ]).then(response => {
      // mod 治療方法マスタ 障害対応 孔s start
      // const mstReportList =
      //   // 透析レポートに絞り込む
      //   response[0].data.filter(m => m.reportClass === 1)
      //   .sort(function (a, b) {
      //     if (a.reportCd < b.reportCd) {
      //       return -1;
      //     }
      //     if (a.reportCd > b.reportCd) {
      //       return 1;
      //     }
      //     return 0;
      //   });
      const mstReportList =
        // 透析レポートに絞り込む
        response[0].data.length > 0 ?
        response[0].data.filter(m => m.reportClass === 1)
        .sort(function (a, b) {
          if (a.reportCd < b.reportCd) {
            return -1;
          }
          if (a.reportCd > b.reportCd) {
            return 1;
          }
          return 0;
        })
        :[];
      // mod 治療方法マスタ 障害対応 孔s end
      // 空の選択肢を追加
      mstReportList.unshift({reportCd: null, reportName: ""});
      // プルダウン生成処理
      const setupReportDropDownList =
        /**
         * @description 各治療経過表のプルダウン生成.
         *
         * @param {String} elementId 設定する要素ID
         * @param {Integer} 初期選択済のレポートコード
         */
        (elementId, selectedValue) => {
          $$("#" + elementId).kendoDropDownList({
            dataSource: mstReportList,
            dataTextField: "reportName",
            dataValueField: "reportCd",
            value: selectedValue,
            change: function(e) {
              const changeElementId = e.sender.element[0].id;
              //add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定("reportAct") 孔s
              switch (changeElementId) {
                case "report" :
                case "reportHw" :
                case "reportBw" :
                case "reportAw" :
                case "reportDev" :
                case "reportAct" :
                  vue.changeReportId(changeElementId, this.value());
                  break;
                default:
                  // console.log("期待したい要素の変更を受け付けました.", changeElementId);
              }
            }
          });
        };
      // 治療経過表ID
      setupReportDropDownList("report", this.selectReportId);
      // 治療経過表ID(手書き)
      setupReportDropDownList("reportHw", this.selectReportIdHw);
      // 治療経過表ID(前体重)
      setupReportDropDownList("reportBw", this.selectReportIdBw);
      // 治療経過表ID(後体重)
      setupReportDropDownList("reportAw", this.selectReportIdAw);
      // 治療経過表ID(装置画像転送用)
      setupReportDropDownList("reportDev", this.selectReportIdDev);
      // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s start
      // 治療経過表ID(実績確定)
      setupReportDropDownList("reportAct", this.selectReportIdAct);
      // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s end
    });

    /* #9312 MOD START */
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    const sysMonitorItemRequestParamMonitor = {
      moniDataType: null,
      vitalMonitorClass: "2"
    }
    // add/ #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong start
    const mstAddMonitorRequestParam = {
      facility_cd: this.getFacilitySwitch,
      vital_monitor_class: ''
    } 
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    const sysMonitorItemRequestParam2 = {
      moniDataType: 'Z',
      vitalMonitorClass: "2"
    }
    const sysMonitorItemRequestParam3 = {
      moniDataType: null,
      vitalMonitorClass: "1"
    }
    Promise.all([
      ApiHelper.get("/treatment-record/sys_monitor_item", sysMonitorItemRequestParamMonitor),
      ApiHelper.get("/mstInfo/mstAddMonitorByClass", mstAddMonitorRequestParam),
      ApiHelper.get("/treatment-record/sys_monitor_item", sysMonitorItemRequestParam2),
      ApiHelper.get("/treatment-record/sys_monitor_item", sysMonitorItemRequestParam3),
    ]).then(response => {
      // 透析：モニタ項目
      const sysMonitorMonitorItem = response[0].data ? response[0].data : [];
      // 施設固有：バイタル・モニタ個別項目
      const mstAddMonitor = response[1].data ? response[1].data : [];
      // 特殊浄化：モニタ項目
      const sysMonitorItem2 = response[2].data ? response[2].data : [];
      const sysMonitorItem3 = response[3].data ? response[3].data : [];

      // 表示用モニタ項目作成
      // const monitorItemList = sysMonitorItem
      //   .filter(
      //     s => s.is_disp === '1'
      //   )
      //   .map(s =>
      //     {
      //       return {
      //         moni_data_no: s.moni_data_no,
      //         moni_data_name: s.moni_data_name
      //       }
      //     }
      //   );
      // mstAddMonitor.forEach(m => {
      //   if (m.is_disp === "0") {
      //     return;
      //   }
      //   monitorItemList.push({
      //     // mod #10077 by zhangruixue 2024-01-04 --start
      //     // moni_data_no: m.vital_monitor_item_name,
      //     moni_data_no: m.vital_monitor_item_cd + 10000 + '',
      //     // mod #10077 by zhangruixue 2024-01-04 --start
      //     moni_data_name: m.vital_monitor_item_name
      //   });
      // });
      // sysMonitorItem2.forEach(m => {
      //   if (m.is_disp === "0") {
      //     return;
      //   }
      //   monitorItemList.push({
      //     moni_data_no: m.moni_data_no,
      //     moni_data_name: m.moni_data_name
      //   });
      // });

      // モニタ表示項目
      const expItemNos = ["52","53","82","83","84","87","89","90","91","92","93","94"];
      let sysMonitorList = sysMonitorMonitorItem.filter( s => s.is_disp === '1' && !expItemNos.includes(s.moni_data_no) )
        .map( item => {
            return {
                moni_data_no: item.moni_data_no,
                moni_data_name: item.moni_data_name
            }
        });
      // 追加モニタ表示項目
      mstAddMonitor.forEach(
        mst => {
          // mod/ #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong start
          //if (mst.is_disp === '1' && mst.vital_monitor_class === '2') {
          if (mst.is_disp === '1') {
          // mod/ #11520 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong end
            sysMonitorList.push({
              moni_data_no: mst.vital_monitor_item_cd + 10000 + '',
              moni_data_name: mst.vital_monitor_item_name
            })
          }
        }
      );
      let sysMonitorListZ = sysMonitorItem2.filter( s => s.is_disp === '1' )
        .map(
          item => {
            return {
              moni_data_no: item.moni_data_no,
              moni_data_name: item.moni_data_name
            }
          }
        );
      // add/ #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong start
      let sysMonitorList3 = sysMonitorItem3.filter( s => s.is_disp === '1' )
        .map(
          item => {
            return {
              moni_data_no: item.moni_data_no,
              moni_data_name: item.moni_data_name
            }
          }
        );
      // add/ #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong end
      // 表示用モニタ項目作成
      let monitorItemList = [...sysMonitorList, ...sysMonitorListZ, ...sysMonitorList3];
      // add/ #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong end
      // モニタ設定項目
      this.dispMonitorItemList = createItemListData(
        monitorItemList,
        "moni_data_no",
        "moni_data_name"
      );
      // トレンドモニタ表示設定項目
      this.dispDLGraphItemList = createItemListData(
        monitorItemList,
        "moni_data_no",
        "moni_data_name"
      );
      /* #9312 MOD END */
    });
     //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
    this.initGetEditRecord =JSON.parse(JSON.stringify(this.getEditRecord));
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord", "findRecordList"]),
    /**
     * SubModalのアクション
     */
    ...mapActions("multi-sub-modal", ["showReportGraphSettingSubModal"]),
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
    compareObjects(obj1, obj2) {
      const keys1 = Object.keys(obj1);
      for (let i = 0; i < keys1.length; i++) {
        const key = keys1[i];
        if (typeof obj1[key] === 'string') {
          obj1[key] = obj1[key].replaceAll(/\s/g, "")
        }
        if (typeof obj2[key] === 'string') {
          obj2[key] = obj2[key].replaceAll(/\s/g, "")
        }
        if (key === "inHospAStartdate" || key === "inHospBStartdate") {
          if (moment(obj1[key]).format('YYYYMMDD') !== moment(obj2[key]).format('YYYYMMDD')) {
            return false;
          }
        } else if (key === "monitorDataItemScreen" || key === "monitorDataItemPrint") {
          let obj1Arr = obj1[key] ? JSON.parse(obj1[key]) : obj1[key];
          let obj2Arr = obj2[key] ? JSON.parse(obj2[key]) : obj2[key];
          if (!obj1Arr && obj2Arr) {
            return false;
          }
          for(let keys in obj2Arr) {
            if (obj1Arr && obj2Arr && ((obj2Arr[keys]?.disp_order !== obj1Arr[keys]?.disp_order) || (obj2Arr[keys]?.moni_data_no !== obj1Arr[keys]?.moni_data_no))) {
              return false
            }
          }
        } else if (key === "reportGraphSetting") {
          let obj1Arr = obj1[key] ? JSON.parse(obj1[key]) : obj1[key];
          let obj2Arr = obj2[key] ? JSON.parse(obj2[key]) : obj2[key];
          if (!isEqual(obj1Arr, obj2Arr)) {
            return false;
          }
        } else {
          const inHospitalCdArr = ['inHospitalCdA1', 'inHospitalCdA2', 'inHospitalCdA3', 'inHospitalCdA4', 'inHospitalCdB1', 'inHospitalCdB2', 'inHospitalCdB3', 'inHospitalCdB4'];
          if (inHospitalCdArr.includes(key) && obj1[key] === null && obj2[key] === "") {
            obj1[key] = "";
          }
          if (obj1[key] != obj2[key]) {
            return false;
          }
        }
      }
      return true;
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    /**
     * @description 治療方法名更新
     */
    setTreatName(value) {
      const name = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, name });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の利用開始日A更新
     */
    setTreatInHospAStartdate() {
      const inHospAStartdate = this.inHospAStartdate;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospAStartdate });
            //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // if (this.inHospAStartdate === this.initHospAStartdate) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の利用開始日A更新
     */
    setTreatInHospBStartdate() {
      const inHospBStartdate = this.inHospBStartdate;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospBStartdate });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // if (inHospBStartdate === this.initHospBStartdate) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードA-1更新
     */
    setTreatInHospitalCdA1(value) {
      const inHospitalCdA1 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdA1 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードA-2更新
     */
    setTreatInHospitalCdA2(value) {
      const inHospitalCdA2 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdA2 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードA-3更新
     */
    setTreatInHospitalCdA3(value) {
      const inHospitalCdA3 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdA3 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードA-4更新
     */
    setTreatInHospitalCdA4(value) {
      const inHospitalCdA4 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdA4 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードB-1更新
     */
    setTreatInHospitalCdB1(value) {
      const inHospitalCdB1 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdB1 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードB-2更新
     */
    setTreatInHospitalCdB2(value) {
      const inHospitalCdB2 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdB2 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードB-3更新
     */
    setTreatInHospitalCdB3(value) {
      const inHospitalCdB3 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdB3 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療方法の連携コードB-4更新
     */
    setTreatInHospitalCdB4(value) {
      const inHospitalCdB4 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCdB4 });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 装置モード更新
     * @param 変更後の装置モード
     */
    setDeviceMode(value) {
      // 選択した装置モードを保持
      this.selectDeviceMode = value;
      // 編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        deviceMode: this.selectDeviceMode
      });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
      //DEL 下記の修正をキャンセル 孔 start
        //ADD モーダル画面の「装置モード」項目が「不明」と選択されている場合は登録できない様にする 孔s START
        // const tbodyc = document.getElementsByClassName("registration-btn");
        // if ( tbodyc.length > 1 ) {
        //   if (value == "-1") {
        //     tbodyc[1].setAttribute("disabled", "disabled");
        //   }else{
        //     tbodyc[1].removeAttribute("disabled");
        //   }
        // }
        //ADD モーダル画面の「装置モード」項目が「不明」と選択されている場合は登録できない様にする 孔s END
      //DEL 上記の修正をキャンセル 孔 end
    },
    /**
     * @description グラフ時間幅更新選択
     * @param 変更後のグラフ時間幅
     */
    setGraphTimeScale(value) {
      // 選択したグラフ時間幅を保持
      this.selectGraphTimeScale = value;
      // 編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        graphTimeScale: this.selectGraphTimeScale
      });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療経過表ID選択
     * @param {Integer} value 選択されたレポートコード
     */
    setReportId(value) {
      this.selectReportId = value;
      // 編集中マスタを更新
      this.setEditRecord({...this.getEditRecord, reportId: this.selectReportId});
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療経過表ID(手書き)選択
     * @param {Integer} value 選択されたレポートコード
     */
    setReportIdHw(value) {
      this.selectReportIdHw = value;
      // 編集中マスタを更新
      this.setEditRecord({...this.getEditRecord, reportIdHw: this.selectReportIdHw});
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療経過表ID(前体重)選択
     * @param {Integer} value 選択されたレポートコード
     */
    setReportIdBw(value) {
      this.selectReportIdBw = value;
      // 編集中マスタを更新
      this.setEditRecord({...this.getEditRecord, reportIdBw: this.selectReportIdBw});
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療経過表ID(後体重)選択
     * @param {Integer} value 選択されたレポートコード
     */
    setReportIdAw(value) {
      this.selectReportIdAw = value;
      // 編集中マスタを更新
      this.setEditRecord({...this.getEditRecord, reportIdAw: this.selectReportIdAw});
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 治療経過表ID(装置画像転送用)選択
     * @param {Integer} value 選択されたレポートコード
     */
    setReportIdDev(value) {
      this.selectReportIdDev = value;
      // 編集中マスタを更新
      this.setEditRecord({...this.getEditRecord, reportIdDev: this.selectReportIdDev});
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s start
    /**
     * @description 治療経過表ID(実績確定)選択
     * @param {Integer} value 選択されたレポートコード
     */
    setReportIdAct(value) {
      this.selectReportIdAct = value;
      // 編集中マスタを更新
      this.setEditRecord({...this.getEditRecord, reportIdAct: this.selectReportIdAct});
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s start
    /**
     * @description 透析条件項目オブジェクト
     */
    selectingDialCondItem(ctlNo) {
      const dialCondItem = DIAL_COND_ITEMS.find(item => item.id === ctlNo);
      return dialCondItem === undefined ? null : dialCondItem;
    },
    /**
     * @description 透析条件項目名称
     */
    selectingDialCondName(ctlNo) {
      const dialCondItem = this.selectingDialCondItem(ctlNo);
      return dialCondItem === null ? null : dialCondItem.name;
    },
    /**
     * @description カテゴリ名
     */
    selectingCategoryName(categoryNo) {
      const category = categoryNameList.find(
        element => element.no === categoryNo
      );
      return category === null ? null : category.name;
    },
    /**
     * @description 透析条件設定取得
     */
    retrieveMstData() {
      // 画面表示処理用キー情報追加
      this.treatmentConditionSetting.forEach(category => {
        //---------------
        // カテゴリ
        //---------------
        // カテゴリNo
        category.category_name = this.selectingCategoryName(
          category.category_no
        );
        // カテゴリ使用
        if (CATEGORY_NO.COND_BASE === category.category_no) {
          // 基本条件は「1」固定
          category.is_use = "1";
        } else {
          if (1 <= category.items.length) {
            // 項目が存在する場合は1件目の状態を反映
            category.is_use = category.items[0].is_use === "0" ? "0" : "1";
          } else {
            // 項目が存在しない場合は「0」固定
            category.is_use = "0";
          }
        }
        // カテゴリ編集可否
        category.is_disabled = true;
        category.items.forEach(item => {
          //---------------
          // 項目
          //---------------
          // 項目編集可否
          item.is_disabled = true;
          // 項目名
          item.name = this.selectingDialCondName(item.ctl_no);
        });
      });
    },
    /**
     * @description 透析条件設定変更
     */
    setDispItemInfo(value) {
      // valueを参照渡しではなくコピーし、登録に不要なキーを削除
      const condSetting = JSON.parse(JSON.stringify(value));
      // 画面表示処理用キー情報削除
      condSetting.forEach(category => {
        //---------------
        // カテゴリ
        //---------------
        // カテゴリNo
        delete category.category_name;
        // カテゴリ使用
        delete category.is_use;
        // カテゴリ編集可否
        delete category.is_disabled;
        category.items.forEach(item => {
          //---------------
          // 項目
          //---------------
          // 項目編集可否
          delete item.is_disabled;
          // 項目名
          delete item.name;
        });
      });

      const treatmentConditionSetting = JSON.stringify(condSetting);
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, treatmentConditionSetting });
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 装置モード別編集状態切替
     * @param 装置モード
     */
    disabledCondItem(deviceMode) {
      // 装置モードに合わせて編集可否を切り替える
      this.treatmentConditionSetting.forEach(category => {
        //-----------------------------
        // カデゴリ
        //-----------------------------
        // カテゴリを無効に切替
        category.is_disabled = true;
        // 基本条件以外のカテゴリ切替
        switch (Number(deviceMode)) {
          // del 9664補液及び透析液仕様修正します yangqingzhe start
          // case DEVICEMODE.AFBF: // AFBF
          // // case DEVICEMODE.UNKNOWN: // 不明  --del 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正 孔
          //   // 補液のみ有効
          //   if (CATEGORY_NO.REPLENISHER === category.category_no) {
          //     category.is_disabled = false;
          //   }
          //   break;
          // del 9664補液及び透析液仕様修正します yangqingzhe end
          case DEVICEMODE.SPECIAL: // 特殊浄化
          case DEVICEMODE.UNKNOWN: // 不明  --add 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正 孔
            // 全カテゴリ有効
            category.is_disabled = false;
            break;
        }

        //-----------------------------
        // 項目
        //-----------------------------
        // 基本条件以外は項目の切替は不要
        if (CATEGORY_NO.COND_BASE !== category.category_no) {
          return;
        }
        // 基本条件は項目の切替(基本情報以外はカテゴリの切替)
        category.items.forEach(item => {
          // 項目を無効に切替
          item.is_disabled = true;
          switch (Number(deviceMode)) {
            case DEVICEMODE.SPECIAL: // 特殊浄化
            case DEVICEMODE.UNKNOWN: // 不明  --add 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正
              // 全項目有効
              item.is_disabled = false;
              break;
            default:
              // ダイアライザ、血流量以外すべて有効
              if (
                DIAL_COND_ID.DIALYEZER !== item.ctl_no &&
                DIAL_COND_ID.BLOODFLOW !== item.ctl_no
              ) {
                item.is_disabled = false;
              }
              break;
          }
        });
      });
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * @description 装置モード別チェック状態切替
     * @param 装置モード
     */
    checkCondItem(deviceMode) {
      // 装置モード別の透析条件切替
      this.treatmentConditionSetting.forEach(category => {
        //-----------------------------
        // カデゴリ
        //-----------------------------
        // カテゴリチェックON
        category.is_use = "1";
        // 装置モード別チェック状態切替
        switch (Number(deviceMode)) {
          case DEVICEMODE.HD: // HD
          case DEVICEMODE.ECUM: // ECUM
          // case DEVICEMODE.UNKNOWN: // 不明  --del 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正
            if (CATEGORY_NO.REPLENISHER === category.category_no) {
              // 補液は【0】固定
              category.is_use = "0";
            }
            break;
          // add 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正 孔 start
          case DEVICEMODE.SPECIAL: // 特殊浄化
            if (
              CATEGORY_NO.REPLENISHER === category.category_no ||
              CATEGORY_NO.DIALYSISFLUID === category.category_no ||
              CATEGORY_NO.WEIGHT === category.category_no
            ) {
              // 体重,透析液,補液は【0】固定
              category.is_use = "0";
            }
            break;
          // add 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正 孔 end
        }
        //-----------------------------
        // 項目
        //-----------------------------
        category.items.forEach(item => {
          // カテゴリの使用有無を項目に反映
          item.is_use = category.is_use === "0" ? "0" : "1";
          // add 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正 孔 start
          switch (Number(deviceMode)) {
            case DEVICEMODE.UNKNOWN: // 不明
              break;
            case DEVICEMODE.SPECIAL: // 特殊浄化
              if (
                DIAL_COND_ID.DIALYEZER === item.ctl_no ||
                DIAL_COND_ID.ADSORPTIONCOLUMN === item.ctl_no
              ) {
                // ダイアライザ
                // 吸着カラム
                item.is_use = "0";
              }
              break;
            default:
              if (
                // 1次膜
                // 2次膜
                DIAL_COND_ID.FILM1 === item.ctl_no ||
                DIAL_COND_ID.FILM2 === item.ctl_no
              ) {
                item.is_use = "0";
              }
              break;
          }
          // add 治療方法マスタ 再依赖 装置モードごとの治療条件設定のデフォルト不正 孔 end
        });
      });
    },
    /**
     * @description 透析条件設定(カテゴリ)変更
     */
    onChange(category, ev) {
      // カテゴリのチェック状態を設定
      category.is_use = ev.currentTarget.checked === true ? "1" : "0";

      // カテゴリ内の項目にチェック状態を設定
      category.items.forEach(item => {
        item.is_use = category.is_use;
      });

      // 変更内容を反映
      this.setDispItemInfo(this.treatmentConditionSetting);
    },
    /**
     * @description 透析条件設定(項目)変更
     */
    onChangeItem(item, ev) {
      // 項目のチェック状態を反映
      item.is_use = ev.currentTarget.checked === true ? "1" : "0";

      // 変更内容を反映
      this.setDispItemInfo(this.treatmentConditionSetting);
    },
    /**
     * @description 装置モード更新選択
     * @param 変更後の装置モード
     */
    changeDeviceMode(value) {
      this.setDeviceMode(value);

      // 透析条件設定チェック編集可能項目切替
      this.disabledCondItem(value);
      // 透析条件設定チェック状態変更
      this.checkCondItem(value);
      // 透析条件設定変更
      this.setDispItemInfo(this.treatmentConditionSetting);
    },
    /**
     * @description グラフ時間幅更新選択
     * @param 変更後のグラフ時間幅
     */
    changeGraphTimeScale(value) {
      // グラフ時間幅更新
      this.setGraphTimeScale(value);
    },
    /**
     * @description 各治療経過表の更新選択
     * @param {String} elementId 更新された治療経過表の要素ID
     * @param {Integer} value 選択されたレポートコード
     */
    changeReportId(elementId, value) {
      switch(elementId) {
        case "report":
          this.setReportId(value);
          break;
        case "reportHw":
          this.setReportIdHw(value);
          break;
        case "reportBw":
          this.setReportIdBw(value);
          break;
        case "reportAw":
          this.setReportIdAw(value);
          break;
        case "reportDev":
          this.setReportIdDev(value);
          break;
        // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s start
        case "reportAct":
          this.setReportIdAct(value);
          break;
        // add 治療方法マスタ 2・実績確定時自動印刷用帳票の指定 孔s end
      }
    },
    /**
     * チェックボックス状態への変換(true or false)
     * @param val 変換前("1"/"0")
     */
    getCheckBoxState(val) {
      // Createが終了前はチェックを付けない
      // (v-ons-checkboxが画面描画時にストアの情報を反映しない。フラグを付けて画面描画後に再度チェックを付ける処理を入れる)
      if (!this.endCreate) return false;

      val = val === "1";
      return val;
    },
    /**
     * @description コンポーネントを再利用させないためのkey属性値(現在日時+文字列)
     * @summary コンポーネントの再利用によって選択項目やフィルタに設定した値が残ったままになるのを防ぐ
     * @param {String} str 任意の文字列 ※コンポーネントごとに変えること
     * @returns {String} YYYYMMDDHHmmssSSS
     */
    componentKey(str) {
      return `${moment().format("YYYYMMDDHHmmssSSS")}${str}`;
    },
    /**
     * @description 選択されたモニタ表示項目を確定する.
     * @param {Array} selectedList 選択されたモニタ項目
     */
    commitDispMonitorItem(selectedList) {
      this.dispMonitorItemSelectedData =
        selectedList.map(s => {
          return {
            moni_data_no: s.cd,
            disp_order: s.dispOrder
          }
        });
      // 編集中マスタを更新
      this.setEditRecord(
        {
          ...this.getEditRecord,
          monitorDataItemScreen: JSON.stringify(this.dispMonitorItemSelectedData)
        }
      );
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description 選択されたトレンドグラフモニタ項目を確定する.
     * @param {Array} selectedList 選択されたモニタ項目
     */
    commitTrendGraphMonitorItem(selectedList) {
      this.trendGraphMonitorItemSelectedData =
      selectedList.map(s => {
        return {
          moni_data_no: s.cd,
          disp_order: s.dispOrder
        }
      });
      // 編集中マスタを更新
      this.setEditRecord(
        {
          ...this.getEditRecord,
          monitorDataItemPrint: JSON.stringify(this.trendGraphMonitorItemSelectedData)
        }
      );
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description モニタ表示項目選択処理
     */
    listSelectMonitor() {
      this.isDispMonitorItemVisible = true;
      this.dispMonitorItemSelectorData = this.createDispMonitorSelectorData();
    },
    /**
     * @description トレンドグラフモニタ表示項目選択処理
     */
    listSelectTrendGraphMonitor() {
      this.isTrendGraphMonitorItemVisible = true;
      this.treandGraphMonitorItemSelectorData = this.createTrendGraphMonitorSelectorData();
    },
    /**
     * @description 帳票グラフ設定
     */
    showReportGraphSetting() {
      this.showReportGraphSettingSubModal();
      // add redmine 5077 スマホ、帳票グラフ設定モーダルの下部に余白が生じる 孔 start
      this.$nextTick(() => {
        const body = $$(".sub-modal-body")[0]
        const container = $$(".sub-modal-container")[0]
        const header = $$(".sub-modal-header")[0]
        const footer = $$(".sub-modal-footer")[0]
        body.style.height = (container.offsetHeight - header.offsetHeight - footer.offsetHeight) + "px"
      });
      // add redmine 5077 スマホ、帳票グラフ設定モーダルの下部に余白が生じる 孔 end
      //[確認]ボタンの状態の変更をトリガーします
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240105 linjunfeng end
    },
    /**
     * @description リスト選択表示起点
     */
    selectorTarget(refName) {
      return this.$refs[`${refName}`];
    },
    /**
     * @description モニタ表示設定の選択肢データ作成
     * @return モニタ表示設定選択肢データ
     */
    createDispMonitorSelectorData() {
      const title = "モニタ表示設定";
      const class1 = null;
      const class2 = null;
      const itemList = this.dispMonitorItemList;
      const defaultSelection = this.dispMonitorItemSelectedData.map(i => i.moni_data_no);
      return {
        title,
        itemList,
        class1,
        class2,
        defaultSelection
      }
    },
    /**
     * @description トレンドグラフモニタ設定の選択肢データ作成
     * @return トレンドグラフモニタ設定選択肢データ
     */
    createTrendGraphMonitorSelectorData() {
      const title = "トレンドグラフモニタ設定";
      const class1 = null;
      const class2 = null;
      const itemList = this.dispDLGraphItemList;
      const defaultSelection = this.trendGraphMonitorItemSelectedData.map(i => i.moni_data_no);
      return {
        title,
        itemList,
        class1,
        class2,
        defaultSelection
      }
    },
    /**
     * @description モーダルメインエリアのサイズ調整.
     */
    calculateWindowsSize() {
      // モーダルのメインエリアの要素取得.
      const elmModalBody = document.getElementsByClassName("modal-body")[0];
      // モニタ表示設定、トレンドグラフ表示設定ボタンを表示しているエリアの要素取得.
      const elmTreatmentButtonArea = document.getElementsByClassName("treatment-button-area")[0];
      // テーブルエリアの要素取得
      const elmTreatmentArea = document.getElementById("treatment-area-div");
      // テーブルエリアの高さを調整
      elmTreatmentArea.style.height = (elmModalBody.offsetHeight - elmTreatmentButtonArea.offsetHeight - 10) + "px";
    },
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.layout-item {
  border: 1px solid #999;
  transition: max-height 200ms;
  overflow: hidden;
  max-height: 2500px;
}
.color-header.layout-item .checkbox-style {
  margin-top: 2px;
}
.header-category-title {
  line-height: 1.8em;
}

.item-area {
  padding-left: 8px;
}
.k-textbox {
  width: 100%;
}
.main-area {
  margin: 0 5px;
}
.treatment-area {
  width: 100%;
  border-collapse: collapse;
}
.treatment-area tr {
  height: 30px;
}

.treatment-area tr th {
  text-align: left;
}

.treatment-area tr th:first-child {
  width: 30%;
}

.treatment-area tr td:first-child {
  border: 1px solid lightgray;
  text-align: left;
}

.treatment-area tr td:nth-child(2) {
  border: 1px solid lightgray;
  text-align: left;
}
.selecting-row {
  background-color: rgba(0, 225, 255, 0.5);
}
.disp-item-content-area {
  /* del redmine 5257 活性化しないスクロールバーが表示される 宋qy start */
  /*overflow-y: scroll;*/
  /* del redmine 5257 活性化しないスクロールバーが表示される 宋qy end */
  /* del 治療方法マスタ 1・モーダルの2重スクロールを主末井 孔s start */
  /* height: 300px; */
  /* del 治療方法マスタ 1・モーダルの2重スクロールを主末井 孔s end */
}
.device-mode,
.graph-time-scale,
.report-item,
.k-textbox {
  width: 100%;
}
/*
 * 治療方法のテーブル部分全体のdiv要素
 */
#treatment-area-div {
  overflow-y: auto;
  overflow-x: hidden;
}
ons-col .item-wrapper {
  padding-left: 4px
}

.custom-treatment-area .k-textbox,
.custom-treatment-area >>> .k-input,
.custom-treatment-area >>> .k-widget,
.custom-treatment-button-area >>> ons-button{
  font-size: unset;
}
.treatment-button-area-button {
  width: 15em;
  margin-top: 10px;
  margin-right:10px;
}
@media screen and (max-width: 869px) {
  .custom-treatment-button-area >>> ons-button{
    width: 30%;
    min-width: 12em;
  }
}
</style>
