/**
 * 治療記録の子機能 バイタルページ
 */
<template>
  <submenu-base>
    <div slot="main" id="vital-component">
      <div class="chart-area">
        <div class="chart-selection-area">
          <div>
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
              <label :for="'chart-scale-' + item.cd">{{ item.text }}</label>
            </span>
          </div>
        </div>
        <div>
        <!-- mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start -->
          <!-- <chart-component
            v-model="vitalDataForGraph"
            :start-date="rstStartDate"
            :end-date="rstEndDate"
            :chart-scale="chartScale"
            :graphDefine="graphDefine"
            ref="chartComponent"
          /> -->
          <chart-component
            v-model="vitalDataForGraph"
            :start-date="rstStartDate"
            :end-date="rstEndDate"
            :chart-scale="chartScale"
            :graphDefine="graphDefine"
            :graph-time="graphTimeScale"
            :rst-dialysis-state="rstDialysisState"
            ref="chartComponent"
          />
        <!-- mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end -->
        </div>
      </div>
      <div class="grid-area" :style="{ height: gridHeight }">
        <!-- mod FNSI修正 NKK3827 房 start -->
        <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <grid-component v-model="vitalData"  @modifiedValue="setModified" @updateVitalData="updateVitalData"
          :displayVitalItem="dispVitalItemList" :ordNo="getOrdNo" :treatEndDate="rstEndDate"
          ref="gridComponent" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
        <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end -->
        <!-- mod FNSI修正 NKK3827 房 end -->
      </div>
    </div>
    <div slot="footer" class="flex-container justify-content-flex-end">
      <div class="registration-btn-area" style="background:none">
        <!-- 画面スタイル(ボタン)対応 姜 start -->
        <!-- <v-ons-button class="button registration-btn" :disabled="!canSave || isReadOnly" @click="onClickSave">保存</v-ons-button> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!canSave || isReadOnly" @click="onClickSave">保存</v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
        <!-- 画面スタイル(ボタン)対応 姜 end -->
      </div>
    </div>
  </submenu-base>
</template>

<script>
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
import {mapActions, mapGetters, mapMutations, mapState} from "vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
// del #10359 編集権限の動作不正 dengshen start
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// del #10359 編集権限の動作不正 dengshen end
import {
  Vital,
  createDispVitalItem,
  createDispAddMonitorItem, cloneVitalForGraph
} from "@/models/treatment-record/vital/Vital";
import { CODES } from "@/constants/TreatmentRecord";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ChartComponent from "@/components/treatment-record/submenu/vital/VitalGraphComponent";
import GridComponent from "@/components/treatment-record/submenu/vital/VitalGridComponent";
import { EventBus } from "@/eventBus.js";
//add FNSI-改修内容 グラフ様式修正 房 start
import { VitalGraphDefine } from "@/models/treatment-record/vital/VitalGraphDefine";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
//#10359 add 編集権限の動作不正 2024-06-05 卓 start
import { getAuthorized } from "@/functions/common/CommonFunctions";
//#10359 add 編集権限の動作不正 2024-06-05 卓 end
import PrintMixin from "@/components/PrintMixin";

const GRAPH_DEFINE_DEFAULT = [new VitalGraphDefine(
  1,
  "最高血圧",
  "#99FFFF",
  1,
  "Solid",
  "#99FFFF",
  4,
  "triangle-down"
),new VitalGraphDefine(
  2,
  "最低血圧",
  "#FF9933",
  1,
  "Solid",
  "#FF9933",
  4,
  "triangle"
),new VitalGraphDefine(
  3,
  "平均血圧",
  "#FF3333",
  1,
  "Solid",
  "#FF3333",
  4,
  "circle"
),new VitalGraphDefine(
  4,
  "脈拍",
  "#99FF33",
  1,
  "Solid",
  "#99FF33",
  4,
  "square"
),new VitalGraphDefine(
  5,
  "体温",
  "#0000A0",
  1,
  "Solid",
  "#0000A0",
  4,
  "diamond"
),new VitalGraphDefine(
  6,
  "血糖値",
  "#6666FF",
  1,
  "Solid",
  "#6666FF",
  4,
  "circle"
)];
//add FNSI-改修内容 グラフ様式修正 房 end

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
      gridDataSource: {},
      chartScaleList: CODES.CHART_SCALE,
      chartScale: CODES.CHART_SCALE.TIME.cd,
      vitalData: [],
      vitalDataForGraph: [],
      rstStartDate: null,
      // 治療終了日時
      rstEndDate: null,
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
      graphTimeScale: null,
      rstDialysisState:null,
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
      isModified: false,
      authorityCds: [AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT],
      gridHeight: "auto",
      selfScreenName: "",
      // 表示バイタル項目
      dispVitalItemList: [],
      //add メッセージ順番修正 房 start
      alertFlag: true,
      //add FNSI-改修内容 グラフ様式修正 房 start
      graphDefine: GRAPH_DEFINE_DEFAULT,
      //add FNSI-改修内容 グラフ様式修正 房 end
      //add メッセージ順番修正 房 end
      //add FNSI-改修内容 新規ボタン追加 房 start
      noDeleteData: [],
      //add FNSI-改修内容 新規ボタン追加 房 end
      scrollQuerySelector: ".grid-area", // スクロールコンテナ
      addClassTargetQuerySelector: ["table.vital-grid"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  computed: {
    ...mapGetters("window-size", { windowHeight: "getWindowHeight", windowWidth: "getWindowWidth" }),
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getTreatDate",
      "getSharedFacilityCd"
    ]),
    //add FNSI-改修内容 グラフ様式修正 房 start
    ...mapGetters("user", ["getFacilityCd"]),
    //add FNSI-改修内容 グラフ様式修正 房 end
    ...mapState("treatment-record/common", ["ordNoDataSourcesState"]),
    /**
     * 保存できるかを返す
     */
    canSave() {
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      this.setIsPatInfoChaned(this.isModified || this.vitalData.some(e => e.isNew === true || e.isDel === true))
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      return this.isModified || this.vitalData.some(e => e.isNew === true || e.isDel === true);
    },
    /**
     * 削除できるかを返す
     */
    canDelete() {
      return this.vitalData.some(e => e.selected);
    },
    /**
     * データの編集があるかどうか.
     */
    isChanged() {
      return this.canSave || this.canDelete;
    },

    isReadOnly() {
      return this.getOrd.readOnly;
    }
  },
  methods: {
    ...mapActions("treatment-record/vital", [
      "getTreatmentRecordVitalMonitor",
      "getTreatmentRecordResult",
      "updateTreatmentRecordVitalForMniMonitor",
      //add FNSI-改修内容 グラフ様式修正 房 start
      "getVitalGraphDefine"
      //add FNSI-改修内容 グラフ様式修正 房 end
    ]),
    ...mapActions("treatment-record/monitor", [
      "getSysMonitorItem",
      "getMstAddMonitor"
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
     * `保存`ボタンクリック
     */
    onClickSave() {
      if(this.isReadOnly) {
        return;
      }
      // バリデーション
      if (this.validate() === false) {
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
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
    },
    /**
     * 保存用JSONを生成.
     */
    createJsonForSave() {
      return this.vitalData
        .filter(element => element.isSaveRequired())
        .map(element => element.toJsonForSave(this.selectedPatId(), this.getOrdNo));
    },
    /**
     * 保存ボタンクリック時のバリデーション.
     */
    validate() {
      // 時刻が入力されていたら、時刻と血圧区分以外の項目のいずれかが入力されていること
      if (this.vitalData.some(e => !e.validateRequiredBlood())) {
        this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES[12000269].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message: this.createCheckErrorMessage(
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // "以下の列のいずれかに入力が必要です。",
            messageFormat(DIALOG_MESSAGES[12000269].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            ["最高血圧", "最低血圧", "平均血圧", "脈拍", "体温", "血糖値"]
          )
        });
        return false;
      }
      // 時刻以外のいずれかの項目が入力されていたら、時刻が入力されていること
      if (this.vitalData.some(e => !e.validateRequiredTime())) {
        this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES[12000270].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message: this.createCheckErrorMessage(
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // "以下の列に未入力項目が存在します。",
            messageFormat(DIALOG_MESSAGES[12000270].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            ["時刻"]
          )
        });
        return false;
      }

      // 前血圧/後血圧の設定が逆転していないこと
      const bpBeforeList = this.vitalData.filter(e => e.isBpBefore);
      const bpAfterList = this.vitalData.filter(e => e.isBpAfter);
      const bpBeforeError = bpBeforeList
        .filter(e => e.isModified())
        .some(e => {
          return bpAfterList.some(after => after.occurTime <= e.occurTime);
        });
      const bpAfterError = bpAfterList
        .filter(e => e.isModified())
        .some(e => {
          return bpBeforeList.some(before => before.occurTime >= e.occurTime);
        });

      if (bpBeforeError) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "バイタル測定日時(前血圧設定)が入力可能な範囲にありません。"
          title: DIALOG_MESSAGES[12000329].title,
          message: messageFormat(DIALOG_MESSAGES[12000329].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }

      if (bpAfterError) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "バイタル測定日時(後血圧設定)が入力可能な範囲にありません。"
          title: DIALOG_MESSAGES[12000330].title,
          message: messageFormat(DIALOG_MESSAGES[12000330].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }

      return true;
    },
    /**
     * エラーメッセージの生成.
     */
    createCheckErrorMessage(message, items) {
      return (
        '<div style="text-align:left;">' +
        message +
        items.map(item => "<br>&nbsp;&nbsp;・" + item).join("") +
        "</div>"
      );
    },
    /**
     * 装置モニタデータ（バイタル）を取得する.
     */
    //mod FNSI-改修内容 グラフ様式修正 房 start
    async init() {
      if (!this.getOrdNo) {
        return;
      }
      //mod FNSI-改修内容 グラフ様式修正 房 end
      // 保存ボタンを非活性にする
      this.isModified = false;

      //add FNSI-改修内容 グラフ様式修正 房 start
      await this.getVitalGraphDefine(this.getFacilityCd).then(response => {
        // モニタグラフ設定をModel化
        const vitalGraphDefine = response.data;
        if (vitalGraphDefine.length > 0) {
          this.graphDefine = vitalGraphDefine.map(e => {
            return new VitalGraphDefine(
              e.vital_graph_cd,
              e.vital_graph_name,
              e.vital_line_color,
              e.vital_line_size,
              e.vital_line_type_value,
              e.vital_point_color,
              e.vital_point_size,
              e.vital_point_type_value
            );
          });
        }
      });
      //add FNSI-改修内容 グラフ様式修正 房 end

      // モニタ項目取得用パラメータ
      const sysMonitorItemSerachCondition = {
        // モニタデータ種別
        moniDataType: CODES.MONI_DATA_TYPE.MACHINE.cd,
        // バイタルモニタ区分
        vitalMonitorClass: CODES.VITAL_MONITOR_CLASS.VITAL.cd
      };

      // mod #12462 患者情報共有 Ji start
      // const treatmentRecordParam = {
      //   facilityCd: this.getFacilityCd,
      //   ordNo: this.getOrdNo
      // }
      const matchedRecord = this.ordNoDataSourcesState.find(
        item => item.treatDate === this.getTreatDate
      );
      const treatmentRecordParam = {
        ordNo: this.getOrdNo,
        facilityCd: matchedRecord?.facilityCd ?? null
      };
      // mod #12462 患者情報共有 Ji end
      // 表示する為の必要なデータ取得.
      // ・sys_monitor_item からバイタル項目の取得
      // ・mst_add_monitor からバイタル項目の取得
      // ・表示バイタルデータの取得
      // ・実績情報の取得
      Promise.all([
        this.getSysMonitorItem(sysMonitorItemSerachCondition),
	// mod #12462 患者情報共有 Ji start
        // this.getMstAddMonitor(CODES.VITAL_MONITOR_CLASS.VITAL.cd),
        this.getMstAddMonitor({
          vitalMonitorClass: CODES.VITAL_MONITOR_CLASS.VITAL.cd,
          facilityCd: this.getSharedFacilityCd
        }),
	// mod #12462 患者情報共有 Ji end
        this.getTreatmentRecordVitalMonitor(treatmentRecordParam),
        this.getTreatmentRecordResult(this.getOrdNo),
      ]).then(response => {

        // sys_monitor_itemから取得したデータ
        let dispSysVitalItemList = [];
        if (response[0].data) {
          dispSysVitalItemList = createDispVitalItem(response[0].data);
        }
        // 個別表示モニタ項目
        let dispAddMonitorItemList = [];
        if (response[1].data) {
          dispAddMonitorItemList = createDispAddMonitorItem(response[1].data);
        }
        // sys_monitor_itemとadd_monitor_itemの項目を管理するリストを統合
        this.dispVitalItemList = [
          ...dispSysVitalItemList,
          ...dispAddMonitorItemList
        ];

        // 装置モニタデータ（バイタル）をModel化
        const mniMonitors = response[2].data.map(e => {
          const monitorData = JSON.parse(e.monitor_data);
          return new Vital(
            e.bio_moni_ctl_no,
            e.data_type,
            null,
            new Date(e.occur_date),
            e.upd_staff_id,
            e.user_last_name,
            e.user_first_name,
            monitorData,
            this.dispVitalItemList
          );
        });

        // 治療開始日時
        if (response[3].data.rst_start_date) {
          this.rstStartDate = new Date(response[3].data.rst_start_date);
        }
        // 治療終了日時
        if (response[3].data.rst_end_date) {
          this.rstEndDate = new Date(response[3].data.rst_end_date);
        }
        //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
        if (response[3].data.graph_time_scale) {
          this.graphTimeScale = response[3].data.graph_time_scale;
        }
        if (response[3].data.rst_dialysis_state) {
          this.rstDialysisState = response[3].data.rst_dialysis_state;
        }
        //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end

        // 前血圧、後血圧の整理
        this.vitalData = this.organizeVitalData(mniMonitors);
        //mod FNSI-改修内容 新規ボタン追加 房 start
        // this.vitalData.unshift(new Vital());
        if (this.noDeleteData.length !== 0) {
          this.noDeleteData.forEach(e=>{
            this.vitalData.push(e);
          });
        }
        this.noDeleteData = [];
        //mod FNSI-改修内容 新規ボタン追加 房 end

        // 初期表示の際は日時昇順ソートされるのでソート指定を▲に設定
        if (this.vitalData.length > 0) {
          this.vitalData[0].sortOrder = 1;
        }

        // グラフ用のバイタルデータを生成
        this.vitalDataForGraph = this.vitalData.map(e => {
          // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
          // const v = new Vital();
          // Object.assign(v, e);
          // return v;
          return cloneVitalForGraph(e);
          // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
        });
      });
    },

    /**
     * 数字の文字列を数値に変換.
     */
    toNumber(value) {
      return value ? Number(value) : null;
    },

    /**
     * mni_monitorから取得したデータを表示する為に整理する.
     * 前血圧、後血圧の最新レコードを取得
     * ※前血圧、後血圧のそれぞれのデータで更新日が最新のデータを前血圧、後血圧情報とする。
     *   尚、削除データ（mni_monitor#is_del=1）のデータはapiの時点で除外されている。
     *   それ以外のデータを血圧区分は未設定とする。
     * @param {*} mniMonitors モニタデータ配列
     */
    organizeVitalData(mniMonitors) {
      // 前血圧の最新データ取得
      const before = this.getLatestMonitorData(
        mniMonitors,
        CODES.BP_CLASS.BEFORE.cd
      );
      // 後血圧の最新データ取得
      const after = this.getLatestMonitorData(
        mniMonitors,
        CODES.BP_CLASS.AFTER.cd
      );
      // 上記で取得した最新レコード以外の血圧区分を未設定にする
      // 削除データを除去し、発生日時の昇順でソート
      return mniMonitors
        .map(e => {
          if (!e.isBpNone && ![before, after].includes(e)) {
            e.resetBpClass();
          }
          return e;
        })
        .sort((a, b) => a.occurDate - b.occurDate);
    },

    /**
     * バイタルモデル配列から、指定された血圧区分の最新データを取得
     * @param {*} models バイタルモデル配列
     * @param {*} bpClass 血圧区分
     */
    getLatestMonitorData(models, bpClass) {
      const dummy = new Vital();
      dummy.isDel = true;
      let filteredData = models.filter(e => e.bpClass === bpClass && !e.isDel);
      return filteredData.reduce(
        (a, b) => (a.occurDate > b.occurDate ? a : b),
        dummy
      );
    },
    setGridHeight() {
      this.$nextTick(function() {
        const mainHeight = document.querySelector(".submenu-main").clientHeight;
        const chartHeight = document.querySelector(".chart-area").clientHeight;
        let gridHeight = mainHeight - chartHeight - 10;
        gridHeight = gridHeight < 205 ? "auto" : `${gridHeight}px`;
        this.gridHeight = gridHeight;
      });
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
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      //mod メッセージ順番修正 房 start
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      // if (this.isChanged && this.alertFlag) {
      //   this.discardConfirm(this.init);
      // } else {
      //   this.init();
      // }
      this.init();
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
    }
    //add メッセージ順番修正 房 end
    //#10359 add 編集権限の動作不正 2024-06-05 卓 start
    ,getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    //#10359 add 編集権限の動作不正 2024-06-05 卓 end
    updateVitalData(newData) {
      this.vitalData = newData;
    }
  },
  watch: {
    windowHeight() {
      this.setGridHeight();
    },
    windowWidth() {
      this.setGridHeight();
    },
    getFontSize() {
      this.setGridHeight();
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
    this.setGridHeight();
  },
  updated() {
    this.setGridHeight();
  },
  /**
   * コンポーネント破棄
   */
  beforeDestroy() {
    // イベント解除
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
    // EventBus.$off("refresh", this.refresh);
    EventBus.$off("refresh", this.eventBusRefresh);
    //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.chart-area {
  margin: 0 0 5px;
  display: flex;
  align-content: flex-start;
  flex-direction: column;
}
.chart-selection-area {
  display: flex;
  justify-content: flex-end;
}
.chart-selection-area > div {
  display: flex;
  align-items: center;
  margin: 2px 10px 2px;
}
.chart-selection-area > div > label {
  margin: 0 5px 0;
}
.grid-area {
  margin: 10px 0 0;
  overflow: auto;
}
.chart-scale {
  margin-left: 20px;
}
.chart-scale ons-radio {
  margin-right: 4px;
}
.chart-selection-area label {
  color: var(--ntss-list-body-color);
}
#vital-component {
  min-height: 400px !important;
}
@media print {
  /** グラフ */
  .chart-area >>> .vitalGraphView {
    width: 100% !important;
  }
  .chart-area >>> .highcharts-container {
    width: auto !important;
    height: auto !important;
  }
  .chart-area >>> .highcharts-root {
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
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  .grid-area >>> table.scroll-rightmost {
    position: relative !important;
    float: right !important;
  }
}
</style>
