/**
 * 治療記録の子機能 モニタページ
 */
<template>
  <submenu-base>
    <div slot="main" id="monitor-component">
      <div class="monitor-chart-area">
        <div class="chart-selection-area">
          <span v-for="item in chartScaleList" :key="item.cd" class="chart-scale">
            <v-ons-radio
              name="chart-scale"
              :input-id="'chart-scale-' + item.cd"
              v-model="chartScale"
              :value="item.cd"
              model-event="change"
              modifier="round"
              data-non-authorize="true"
            />
            <label style="white-space: nowrap;" :for="'chart-scale-' + item.cd">{{ item.text }}</label>
          </span>
          <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 start -->
          <!-- <v-ons-select v-model="selectedChartType" :disabled="!isShared" data-non-authorize="true" class="chart-type-selection">
            <option v-for="item in graphDefine" :key="item.cd" :value="item.cd">{{ item.name }}</option>
          </v-ons-select> -->
          <v-ons-select v-model="selectedChartType" data-non-authorize="true" class="chart-type-selection">
            <option v-for="item in graphDefine" :key="item.cd" :value="item.cd">{{ item.name }}</option>
          </v-ons-select>
          <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 end -->
        </div>
        <div>
          <!-- mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start -->
          <!-- <chart-component
            v-model="monitorData"
            :start-date="rstStartDate"
            :end-date="rstEndDate"
            :chart-scale="chartScale"
            :graph-define="currentGraphDefine"
            :monitor-item="monitorItemList"
            ref="chartComponent"
          /> -->
          <chart-component
            v-model="monitorData"
            :start-date="rstStartDate"
            :end-date="rstEndDate"
            :chart-scale="chartScale"
            :graph-define="currentGraphDefine"
            :monitor-item="monitorItemList"
            :graph-time="graphTimeScale"
            :rst-dialysis-state="rstDialysisState"
            ref="chartComponent"
          />
          <!-- mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end -->
        </div>
      </div>
      <div class="grid-area" :style="heightStyles">
        <!-- mod FNSI修正 NKK3827 房 start -->
        <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <grid-component v-model="monitorData"  @modifiedValue="setModified" @updateMonitorData="updateMonitorData"
          :monitor-disp-format="monitorDispFormat"
          :displayMonitorItem="dispMonitorItemList"
          :displayAllMonitorItem="dispMonitorItemAllList"
          :ordNo="this.getOrdNo" :treatEndDate="rstEndDate"
          ref = "gridComponent"/>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
        <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end -->
        <!-- mod FNSI修正 NKK3827 房 end -->
      </div>
    </div>
    <div slot="footer" class="flex-container justify-content-flex-end">
      <div class="registration-btn-area" style="background:none">
        <!-- 画面スタイル(ボタン)対応 姜 start -->
        <!-- <v-ons-button class="button registration-btn" :disabled="!canSave" @click="onClickSave">保存</v-ons-button> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!canSave" @click="onClickSave">保存</v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
        <!-- 画面スタイル(ボタン)対応 姜 end -->
      </div>
    </div>
  </submenu-base>
</template>

<script>
/* eslint-disable no-console */
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
import {mapActions, mapGetters, mapMutations} from "vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import ChartComponent from "@/components/treatment-record/submenu/monitor/MonitorGraphComponent";
import GridComponent from "@/components/treatment-record/submenu/monitor/MonitorGridComponent";
import {
  Monitor,
  createDispMonitorItem,
  createDispAddMonitorItem,
  createDispAddMonitorItemToItemCd
} from "@/models/treatment-record/monitor/Monitor";
import { MonitorGraphDefine } from "@/models/treatment-record/monitor/MonitorGraphDefine";
import { CODES } from "@/constants/TreatmentRecord";
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { EventBus } from "@/eventBus.js";
import {
  sendRequestGetMstTreatment
} from "@/apis/treatment-record";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
//#10359 add 編集権限の動作不正 2024-06-05 卓 start
import { getAuthorized } from "@/functions/common/CommonFunctions";
//#10359 add 編集権限の動作不正 2024-06-05 卓 end
import PrintMixin from "@/components/PrintMixin";
// モニタグラフ設定のデフォルト値
const GRAPH_DEFINE_DEFAULT = new MonitorGraphDefine(
  1,
  "グラフ１",
  17,
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
  "",
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
  "#0099FF",
  //add FNSI-改修内容 グラフ様式修正 房 start
  1,
  "Solid",
  "#0099FF",
  4,
  "circle",
  //add FNSI-改修内容 グラフ様式修正 房 end
  88,
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
  "",
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
  //add FNSI-改修内容 グラフ様式修正 房 start
  "#FF9933",
  1,
  "Solid",
  "#FF9933",
  4,
  "circle",
  //add FNSI-改修内容 グラフ様式修正 房 end
);

export default {
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  mixins: [DiscardConfirmationMixin, PrintMixin],
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  components: {
    "submenu-base": SubmenuBase,
    "chart-component": ChartComponent,
    "grid-component": GridComponent
  },
  data() {
    return {
      chartScaleList: CODES.CHART_SCALE,
      chartScale: CODES.CHART_SCALE.TIME.cd,
      monitorData: [],
      graphDefine: [GRAPH_DEFINE_DEFAULT],
      selectedChartType: GRAPH_DEFINE_DEFAULT.cd,
      deletedData: [],
      rstStartDate: null,
      rstEndDate: null,
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
      graphTimeScale:null,
      rstDialysisState:null,
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
      componentAreaHeight: "auto",
      isModified: false,
//#10359 del 編集権限の動作不正 2024-06-05 卓 start
//       authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
//#10359 del 編集権限の動作不正 2024-06-05 卓 end
      // 初期表示時の表示形式(一部)
      monitorDispFormat: CODES.MONITOR_DISP_FORMAT.PART.cd,
      // モニタ項目(システム設定)
      // データベースから取得した結果(表示用に変換はされていない状態)：透析装置用
      sysMonitorItemList: [],
      // データベースから取得した結果(表示用に変換はされていない状態)：特殊浄化装置用
      sysMonitorItemList2: [],
      // 個別表示モニタ項目
      // データベースから取得した結果(表示用に変換はされていない状態)
      mstAddMonitorItemList: [],
      // 治療方法マスタ
      mstTreatment: [],
      // 実績に登録されている治療方法コード
      treatmentCd: null,
      // 表示モニタ項目
      dispMonitorItemList: [],
      // 全ての表示モニタ項目
      dispMonitorItemAllList: [],
      //add メッセージ順番修正 房 start
      alertFlag: true,
      //add メッセージ順番修正 房 end
      //add FNSI-改修内容 新規ボタン追加 房 start
      noDeleteData: [],
      //add FNSI-改修内容 新規ボタン追加 房 end
      selfScreenName: "",
      scrollQuerySelector: ".grid-area", // スクロールコンテナ
      addClassTargetQuerySelector: ["table.monitor-grid"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  computed: {
    ...mapGetters("window-size", { windowHeight: "getWindowHeight", windowWidth: "getWindowWidth" }),
    ...mapGetters("account-edit", ["getFontSize"]),
    // add 共有設定の追加 周雨晴  2020/09/22  start
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getSharedFacilityCd"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    // add 共有設定の追加 周雨晴  2020/09/22  end

    /**
     * main部の高さをCSS変数を利用して書き換える
     */
    heightStyles() {
      return { height: this.componentAreaHeight };
    },
    /**
     * 保存できるかを返す
     */
    canSave() {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      this.setIsPatInfoChaned((this.isModified || this.monitorData.some(e => e.isNew === true || e.isDel === true)) && !this.getOrd.readOnly)
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      return (this.isModified || this.monitorData.some(e => e.isNew === true || e.isDel === true)) && !this.getOrd.readOnly;
    },
    /**
     * 削除できるかを返す
     */
    canDelete() {
      return this.monitorData.some(e => e.selected) && !this.getOrd.readOnly;
    },
    /**
     * データの編集があるかどうか.
     */
    isChanged() {
      return this.canSave || this.canDelete;
    },
    isReadOnly() {
      return this.getOrd.readOnly;
    },
    /**
     * 現在のグラフ設定を返す.
     */
    currentGraphDefine() {
      return this.graphDefine.find(e => e.cd === this.selectedChartType);
    },
    /**
     * すべてのモニタ項目一覧を返す
     */
    monitorItemList() {
      return [
        ...createDispMonitorItem(this.sysMonitorItemList),
        ...createDispMonitorItem(this.sysMonitorItemList2),
        /* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
        ...createDispAddMonitorItemToItemCd(this.mstAddMonitorItemList)
        /* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */
      ];
    },
     // add 共有設定の追加 周雨晴 2020/09/22 start
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    }
     // add 共有設定の追加 周雨晴 2020/09/22 end
  },
  methods: {
    ...mapActions("treatment-record/monitor", [
      "getTreatmentRecordMonitor",
      "getMonitorGraphDefine",
      "updateTreatmentRecordRstMonitor",
      "getSysMonitorItem",
      //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
      "getMstAddMonitorAll",
      //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
      "getMstAddMonitor"
    ]),
    ...mapActions("treatment-record/vital", [
      "getTreatmentRecordResult",
      "updateTreatmentRecordVitalForMniMonitor"
    ]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    /**
     * 編集済みにする.
     */
    setModified(isValid) {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      // this.isModified |= true;
      this.isModified = isValid;
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    },
    /**
     * 高さを調整する
     */
    adjustHeight() {
      this.$nextTick(function() {
        const submenuMainHeight = document.getElementsByClassName(
          "submenu-main"
        )[0].clientHeight;
        const chartHeight = document.querySelector(".monitor-chart-area").clientHeight;
        let gridHeight = submenuMainHeight - chartHeight - 10;
        gridHeight = gridHeight < 107 ? "auto" : `${gridHeight}px`;
        this.componentAreaHeight = gridHeight;
      });
    },
    /**
     * `保存`ボタンクリック
     */
    onClickSave() {
      if(this.isReadOnly) {
        return;
      }
      // バリデーション
      if (!this.validateForSave()) {
        return;
      }

      // 保存用JSONを生成
      const param = {
        ordNo: this.getOrdNo,
        payload: this.createJsonForSave()
      };

      this.updateTreatmentRecordVitalForMniMonitor(param).then(() => {
        // 初期化処理を実行
        this.init();
        // 子機能ボタンエリアの更新
        this.$emit("update");
      });
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
      let elements = document.getElementsByClassName("custom-input-edited");
      for (let i = elements.length-1; i >= 0; i--) {
        elements[i].classList.remove("custom-input-edited");
      }
      this.$refs["gridComponent"].initTimeComponent();
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
    },
    /**
     * 保存ボタンクリック時のバリデーション.
     */
    validateForSave() {
      // 新規行の項目のいずれか（時刻以外）が入力されている場合は、時刻が必須
      if (this.monitorData.some(item => !item.validateRequiredTime())) {
        // mod #6107 2023/03/24 メッセージボックス全調整 張博 start
        // const message =
        //   '<div style="text-align:left;">' +
        //   "以下の列に未入力項目が存在します。" +
        //   "<br>&nbsp;&nbsp;・時刻</div>";
        const message = '<div style="text-align:left;">' +messageFormat(DIALOG_MESSAGES[12000005].message)+"<br>&nbsp;&nbsp;・時刻</div>";
        this.$ons.notification.alert({
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          message: message
        });
        return false;
      }
      return true;
    },
    /**
     * 保存用JSONを生成.
     */
    createJsonForSave() {
      return this.monitorData
        .filter(element => element.isSaveRequired())
        .map(element => element.toJsonForSave(this.selectedPatId(), this.getOrdNo));
    },
    /**
     * モニタデータと実積モニタデータを取得する.
     */
    init() {
      if (!this.getOrdNo) {
        return;
      }
      // 保存ボタンを非活性にする
      this.isModified = false;

      this.getMonitorGraphDefine().then(response => {
        // モニタグラフ設定をModel化
        const monitorGraphDefine = response.data;
        if (monitorGraphDefine.length > 0) {
          this.graphDefine = monitorGraphDefine.map(e => {
            return new MonitorGraphDefine(
              e.monitor_graph_cd,
              e.monitor_graph_name,
              e.left_data_index,
              //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
              e.left_name,
              //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
              e.left_color,
              //add FNSI-改修内容 グラフ様式修正 房 start
              e.left_line_size,
              e.left_line_type_value,
              e.left_point_color,
              e.left_point_size,
              e.left_point_type_value,
              //add FNSI-改修内容 グラフ様式修正 房 end
              e.right_data_index,
              //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
              e.right_name,
              //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
              e.right_color,
              //add FNSI-改修内容 グラフ様式修正 房 start
              e.right_line_size,
              e.right_line_type_value,
              e.right_point_color,
              e.right_point_size,
              e.right_point_type_value,
              //add FNSI-改修内容 グラフ様式修正 房 end
              //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 start
              e.left_graph_upper_limit,
              e.left_graph_lower_limit,
              e.right_graph_upper_limit,
              e.right_graph_lower_limit,
              //add FNSI-9858-改修内容 グラフ様式追加最大値と最小値 杜天成 end
            );
          });

          // 先頭のグラフ設定を選択
          /* modify by chamaojia 2023-07-09 治療記録ページモニタ別Type error  --start */
          // mod FNSI-redmine5513 fang start
          if (this.selectedChartType == GRAPH_DEFINE_DEFAULT.cd) {
            this.selectedChartType = this.graphDefine[0].cd;
          }
          // mod FNSI-redmine5513 fang end
          /* modify by chamaojia 2023-07-09 治療記録ページモニタ別Type error  --end */
        }
      });

      // 透析装置用モニタ項目取得用パラメータ
      const sysMonitorItemSerachCondition = {
        // モニタデータ種別
        moniDataType: CODES.MONI_DATA_TYPE.MACHINE.cd,
        // バイタルモニタ区分
        vitalMonitorClass: CODES.VITAL_MONITOR_CLASS.MONITOR.cd
      };
      // 特殊浄化装置用モニタ項目取得用パラメータ
      const sysMonitorItemSerachCondition2 = {
        // モニタデータ種別
        moniDataType: CODES.MONI_DATA_TYPE.PURIFICATION.cd,
        // バイタルモニタ区分
        vitalMonitorClass: CODES.VITAL_MONITOR_CLASS.MONITOR.cd
      };

      Promise.all([
        this.getTreatmentRecordMonitor(this.getOrdNo),
        this.getTreatmentRecordResult(this.getOrdNo),
        this.getSysMonitorItem(sysMonitorItemSerachCondition),
	// mod #12462 患者情報共有 Ji start
        sendRequestGetMstTreatment(this.getSharedFacilityCd),
	// mod #12462 患者情報共有 Ji end
        //mod 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
        // this.getMstAddMonitor(CODES.VITAL_MONITOR_CLASS.MONITOR.cd),
	// mod #12462 患者情報共有 Ji start
        this.getMstAddMonitorAll(this.getSharedFacilityCd),
	// mod #12462 患者情報共有 Ji end
        //mod 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
        this.getSysMonitorItem(sysMonitorItemSerachCondition2),
      ]).then(response => {
        // モニタデータをModel化
        const mniMonitors = response[0].data.map(e => {
          return new Monitor(
            e.bio_moni_ctl_no,
            new Date(e.occur_date),
            false,
            JSON.parse(e.monitor_data),
            e.upd_staff_id,
            e.user_last_name,
            e.user_first_name
          );
        });

        // 治療開始日時
        if (response[1].data.rst_start_date) {
          this.rstStartDate = new Date(response[1].data.rst_start_date);
        }
        // 治療終了日時
        if (response[1].data.rst_end_date) {
          this.rstEndDate = new Date(response[1].data.rst_end_date);
        }
        //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
        if (response[1].data.graph_time_scale) {
          this.graphTimeScale = response[1].data.graph_time_scale;
        }
        if (response[1].data.rst_dialysis_state) {
          this.rstDialysisState = response[1].data.rst_dialysis_state;
        }
        //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
        // 治療方法コード取得
        /* modify by chamaojia 2025-02-28 [11471] variable value modification --start */
        const rstTreatmentCd = response[1].data.rst_treatment_cd;
        const rstDeviceMode = response[1].data.rst_device_mode;
        this.createMonitorItem(response[2].data, response[5].data, response[4].data, response[3].data, rstTreatmentCd, rstDeviceMode);
        /* modify by chamaojia 2025-02-28 [11471] variable value modification --end */

        // マージ処理
        this.monitorData = this.organizeMonitorData(mniMonitors);
        //mod FNSI-改修内容 新規ボタン追加 房 start
        // this.monitorData.unshift(new Monitor());
        if (this.noDeleteData.length !== 0) {
          this.noDeleteData.forEach(e=>{
            this.monitorData.push(e);
          });
        }
        this.noDeleteData = [];
        //mod FNSI-改修内容 新規ボタン追加 房 end

        // 初期表示の際は日時昇順ソートされるのでソート指定を▲に設定
        if (this.monitorData.length > 0) {
          this.monitorData[0].sortOrder = 1;
        }
      });
    },

    /**
     * 表示モニタ項目の列情報を作成.
     * ※治療方法コードが未指定の場合、個別表示モニタ項目とする.
     *
     * @param {*} responseSysMonitor 透析装置用モニタ項目(システム設定)のレスポンスデータ
     * @param {*} responseSysMonitor2 特殊浄化装置用モニタ項目(システム設定)のレスポンスデータ
     * @param {*} responseMstAddMonitor 個別表示モニタ項目のレスポンスデータ
     * @param {*} responseMstTreatment 治療方法マスタのレスポンスデータ
     * @param {Integer} rstTreatmentCd 実績に登録されている治療方法コード
     * @param {Integer} rstDeviceMode 装置モード(実績)
     */
    /* modify by chamaojia 2025-02-28 [11471] parameter changes of methods --start */
    // createMonitorItem(responseSysMonitor, responseSysMonitor2, responseMstAddMonitor, responseMstTreatment, rstTreatmentCd) {
    createMonitorItem(responseSysMonitor, responseSysMonitor2, responseMstAddMonitor, responseMstTreatment, rstTreatmentCd, rstDeviceMode) {
    /* modify by chamaojia 2025-02-28 [11471] parameter changes of methods --end */
      // モニタ項目（システム設定）
      if (responseSysMonitor) {

        const escapeItemNos = ["52","53","82","83","84","87","89"];


        this.sysMonitorItemList = responseSysMonitor.filter(e =>
          e.is_disp ===  CODES.IS_DISP.DISPLAY.cd && !escapeItemNos.includes(e.moni_data_no)
        );
      }
      // モニタ項目（システム設定）
      if (responseSysMonitor2) {
        this.sysMonitorItemList2 =
            responseSysMonitor2.filter(e => e.is_disp === CODES.IS_DISP.DISPLAY.cd);
      }
      // 個別表示モニタ項目
      if (responseMstAddMonitor) {
        this.mstAddMonitorItemList =
          // #9312 Mod Start
            // responseMstAddMonitor.filter(e => e.is_disp === CODES.IS_DISP.DISPLAY.cd);
          responseMstAddMonitor.filter(e => e.is_disp === CODES.IS_DISP.DISPLAY.cd && e.vital_monitor_class === "2");
          // #9312 Mod End
      }

      // モニタ項目及び個別表示モニタ項目で「すべて」を選択された場合の情報を生成.
      let dispSysMonitorItemList = this.sysMonitorItemList;
      this.dispMonitorItemAllList =
        [...createDispMonitorItem(this.sysMonitorItemList), ...createDispAddMonitorItem(this.mstAddMonitorItemList)];
      // 治療方法コードが未指定の場合、何も表示しない.
      /* modify by chamaojia 2025-02-28 [11471] processing and modification of 【device_mode】 --start */
      // mod 11776 HDにて治療記録>モニタの表示項目がなにも表示されない zkm start
      // if (!rstDeviceMode) {
      if (null == rstDeviceMode) {
        // mod 11776 HDにて治療記録>モニタの表示項目がなにも表示されない zkm end
        // console.log("[治療記録]-[モニタ] 治療方法コードが未指定です.");
        this.dispMonitorItemList = [];
        return;
      }
      // 治療方法マスタが見つからない場合
      // ※表示するモニタ項目の設定が取得出来ない為、何も表示しない.
      if (!responseMstTreatment || responseMstTreatment.length === 0) {
        // console.log("[治療記録]-[モニタ] 治療方法マスタが取得できませんでした.");
        this.dispMonitorItemList = [];
        return;
      }

      // 治療方法コードに該当する治療方法マスタを取得.
      const mstTreat = responseMstTreatment.find(
        mst => mst.treatmentCd === rstTreatmentCd
      );
      if (!mstTreat) {
        // console.log("[治療記録]-[モニタ] 治療方法コードに該当する治療方法マスタがありません.治療方法コード:", rstTreatmentCd);
        this.dispMonitorItemList = [];
        return;
      }

      // 治療方法コード判定
      if ( rstDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd ) {
        // 特殊浄化

        dispSysMonitorItemList = this.sysMonitorItemList2;
        // モニタ項目及び個別表示モニタ項目で「すべて」を選択された場合の情報を生成.
        this.dispMonitorItemAllList =
        [...createDispAddMonitorItem(this.mstAddMonitorItemList), ...createDispMonitorItem(this.sysMonitorItemList2)];
      }
      /* modify by chamaojia 2025-02-28 [11471] processing and modification of 【device_mode】 --end */
      // ここまで来たら、必要なデータが全て揃っている.
      // 治療方法マスタから表示するモニタ項目データを取得.
      // 表示するモニタ項目
      const mstTreatDispMonitorItem = mstTreat.monitorDataItemScreen
        ? JSON.parse(mstTreat.monitorDataItemScreen)
        : JSON.parse("[]");
      // 非表示項目が治療方法マスタに登録されている場合に間引く
      const dispSysMonitorItemListByTreatment = mstTreatDispMonitorItem.map(e => {
          return dispSysMonitorItemList.find(sys => {
                  return sys.moni_data_no === e.moni_data_no;
                });
        }).filter(val => Boolean(val));
      this.dispMonitorItemList = createDispMonitorItem(dispSysMonitorItemListByTreatment);
      // 個別表示モニタ項目
      const dispAddMonitorItemListByTreatment = mstTreatDispMonitorItem.map(e => {
          return this.mstAddMonitorItemList.find(add => {
            // mod #10077 by zhangruixue 2023-1-4 --start
                  return add.vital_monitor_item_cd + 10000 == e.moni_data_no;
            // return add.vital_monitor_item_name === e.moni_data_no;
            // mod #10077 by zhangruixue 2024-1-4 --end
                });
        }).filter(val => Boolean(val));
      this.dispMonitorItemList = [
        ...createDispMonitorItem(dispSysMonitorItemListByTreatment),
        ...createDispAddMonitorItem(dispAddMonitorItemListByTreatment)
      ];
      return;
    },

    /**
     * モニタデータを表示する為に整理する.
     * @param {*} mniMonitors モニタデータ配列
     */
    organizeMonitorData(mniMonitors) {
      // 削除ずみデータを待避
      this.deletedData = mniMonitors.filter(e => e.isDel);
      // 削除データを除去し、発生日時の昇順でソート
      return mniMonitors
        .filter(e => !e.isDel)
        .sort((a, b) => a.occurDate - b.occurDate);
    },
    /**
     * グラフエリアのリサイズ
     */
    graphResize() {
      this.$refs.chartComponent.graphResize();
    },
    /**
     * 再描画処理
     */
    refresh() {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      // 子機能ボタンエリアの更新
      this.$emit("update");
      //mod メッセージ順番修正 房 start
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      // if (this.isChanged && this.alertFlag) {
      //   this.discardConfirm(this.init);
      // } else {
      //   this.init();
      // }
      this.init()
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      this.alertFlag = true;
      //mod メッセージ順番修正 房 end
    },
    //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
    eventBusRefresh() {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      if (this.isChanged && this.alertFlag) {
        this.discardConfirm(this.init);
      } else {
        this.init();
      }
      this.alertFlag = true;
    },
    //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
    //add メッセージ順番修正 房 start
    getChangeStatus(){
      return this.canSave || this.canDelete;
    },
    updateChangeStatus(){
      this.alertFlag = false;
    },
    //add メッセージ順番修正 房 end
//#10359 add 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
//#10359 add 編集権限の動作不正 2024-06-05 卓 end
    updateMonitorData(newData) {
      this.monitorData = newData;
    }
  },
  watch: {
    windowHeight() {
      this.adjustHeight();
    },
    windowWidth() {
      this.adjustHeight();
    },
    getFontSize() {
      this.adjustHeight();
    }
  },
  created() {
    this.init();
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // イベント登録
    //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
    // EventBus.$on("refresh", this.refresh);
    EventBus.$on("refresh", this.eventBusRefresh);
    //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
  },
  mounted() {
    this.$nextTick(() => {
      this.adjustHeight();
    });
  },
  updated() {
    this.$nextTick(() => {
      this.adjustHeight();
    });
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
    // EventBus.$off("refresh", this.refresh);
    EventBus.$off("refresh", this.eventBusRefresh);
    //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
  }
};
</script>

<style scoped>
.monitor-chart-area {
  margin: 0 0 5px;
  display: flex;
  align-content: flex-start;
  flex-direction: column;
}
.chart-selection-area {
  display: flex;
  flex-flow: wrap;
  justify-content: flex-end;
  align-items: center;
  margin: 0 5px 0;
  color: var(--ntss-list-body-color);
}
.grid-area {
  margin: 5px 0 0;
  overflow: auto;
}
.chart-scale {
  margin-left: 20px;
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
}
.chart-scale ons-radio {
  margin-right: 4px;
}
.chart-selection-area ons-select {
  margin-left: 16px;
}
.chart-type-selection >>> .select-input {
  color: var(--treatment-record-input-color);
}
@media print {
  /** グラフ */
  .monitor-chart-area >>> .monitorGraphView {
    width: 100% !important;
  }
  .monitor-chart-area >>> .highcharts-container {
    width: auto !important;
    height: auto !important;
  }
  .monitor-chart-area >>> .highcharts-root {
    width: 100%;
    height: 100%;
  }
  
  /** grid */
  .grid-area {
    overflow: hidden !important;
    width: auto !important;
    height: auto !important;
  }
  .grid-area >>> .scroll-table {
    width: 100% !important;
  }
  /* 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  .grid-area >>> table.scroll-rightmost {
    position: relative !important;
    float: right !important;
  }
}
</style>
