/**
 * 帳票グラフ設定モーダル
 */
<template>
  <modal-base @onClose="cancel">
        <template #body>
<div class="main-content">
      <div class="list-content">
        <div class="scroll-table">
          <table id="sys-medicine-list" class="ntss-list" style="position: inherit;">
            <thead>
              <tr>
                <th class="ntss-list-header-th-sticky" style="max-width:20px" rowspan="2">No</th>
                <th class="ntss-list-header-th-sticky" style="min-width:200px" colspan="2" rowspan="2">表示対象</th>
                <th class="ntss-list-header-th-sticky" colspan="2">グラフ</th>
                <th class="ntss-list-header-th-sticky" colspan="3">プロット</th>
                <th class="ntss-list-header-th-sticky" colspan="3">線</th>
              </tr>
              <tr>
                <th class="ntss-list-header-th-sticky report-graph-header" style="width:100px;">上限</th>
                <th class="ntss-list-header-th-sticky report-graph-header" style="width:100px;">下限</th>
                <th class="ntss-list-header-th-sticky report-graph-header" style="width:80px;">形状</th>
                <th class="ntss-list-header-th-sticky report-graph-header" style="width:80px;">色</th>
                <th class="ntss-list-header-th-sticky report-graph-header" style="width:80px;">サイズ</th>
                <th class="ntss-list-header-th-sticky report-graph-header" style="min-width:100px;">種類</th>
                <th class="ntss-list-header-th-sticky report-graph-header" style="width:80px;">色</th>
                <th class="ntss-list-header-th-sticky report-graph-header" style="width:80px;">太さ(px)</th>
              </tr>
            </thead>
            <tbody>
              <!-- 血圧情報を表示 -->
              <tr class="ntss-list-body-tr" v-for="(e, index) in reportGraphBpItemEdit" :key="`bp_${index}`">
                <!-- 表示対象 -->
                <td class="ntss-list-body-td" rowspan="3" v-if="index === 0">1</td>
                <td class="ntss-list-body-td" rowspan="3" v-if="index === 0">血圧</td>
                <td class="ntss-list-body-td">
                  <!-- mod 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start-->
<!--                  <td class="ntss-list-body-td">{{ e.moniItemName }} </td>-->
                  <v-ons-checkbox v-model="e.show_check" />{{ e.moniItemName }}
                </td>
                  <!-- mod 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end-->
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td" rowspan="3" v-if="index === 0">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="graphMax"
                    v-model="e.graphMax"
                    name="graphMax"
                    :step=1
                    :min=0
                    :max=300 /> -->
                  <com-number-input
                    input-id="graphMax"
                    v-model="e.graphMax"
                    name="graphMax"
                    :inputType='"number"'
                    :step=1
                    :inputMin=0
                    :inputMax=300
                    @blur="handleBlur($event, index, 'graphMax')"
                    @getChildData="getChildData"
                    />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td" rowspan="3" v-if="index === 0">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="graphMin"
                    v-model="e.graphMin"
                    name="graphMin"
                    :step=1
                    :min=0
                    :max=300 /> -->
                   <com-number-input
                    input-id="graphMin"
                    v-model="e.graphMin"
                    name="graphMin"
                    :step=1
                    :inputType='"number"'
                    :inputMin=0
                    :inputMax=300
                    @blur="handleBlur($event, index, 'graphMin')"
                    @getChildData="getChildData"
                    />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
                <td class="ntss-list-body-td" style="font-family: Osaka,'ＭＳ Ｐゴシック','MS PGothic',Sans-Serif;">{{ getPlotTypeText(e.plotType) }}</td>
                <td class="ntss-list-body-td">
                  <input
                    class="graph-color"
                    type="color"
                    v-model="e.plotColor"
                    @change="onChangeColor($event, 'plot', e.isBp, index)"
                  />
                </td>
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="plotSize"
                    v-model="e.plotSize"
                    name="plotSize"
                    :step=1
                    :min=1
                    :max=10 /> -->
                  <com-number-input
                    input-id="plotSize"
                    v-model="e.plotSize"
                    name="plotSize"
                    :step=1
                    :inputType='"number"'
                    :inputMin=1
                    :inputMax=10
                    @blur="handleBlur($event, index, 'plotSize')"
                    @getChildData="getChildData"
                  />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
                <td class="ntss-list-body-td">
                  <kendo-dropdownlist
                    v-model="e.lineType"
                    :data-source="getLineType()"
                    :data-text-field="'text'"
                    :data-value-field="'value'"
                    style="width: 100%;z-index:1;font-size: inherit;"
                    class="common-style-input" />
                </td>
                <td class="ntss-list-body-td">
                  <input
                    class="graph-color"
                    type="color"
                    v-model="e.lineColor"
                    @change="onChangeColor($event, 'line', e.isBp, index)"
                  />
                </td>
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="lineThickness"
                    v-model="e.lineThickness"
                    name="lineThickness"
                    :step=1
                    :min=1
                    :max=10 /> -->
                    <com-number-input
                      input-id="lineThickness"
                      v-model="e.lineThickness"
                      name="lineThickness"
                      :step=1
                      :inputType='"number"'
                      :inputMin=1
                      :inputMax=10
                      @blur="handleBlur($event, index, 'lineThickness')"
                      @getChildData="getChildData"
                    />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
              </tr>

              <!--
                血圧以外の情報を表示
               -->
              <tr
                class="ntss-list-body-tr"
                v-for="(e, index) in reportGraphEdit" :key=index>
                <!--
                  No
                  ※'1'は血圧で使用している為、'2'始まりとする.
                -->
                <td class="ntss-list-body-td">{{ index + 2 }}</td>
                <!-- 表示対象 -->
                <td class="ntss-list-body-td" colspan="2">
                  <kendo-dropdownlist
                    v-model="e.monitorItemCd"
                    :data-source="selectMonitorItemList"
                    :data-text-field="'text'"
                    :data-value-field="'value'"
                    :filter="'contains'"
                    style="width: 100%;z-index:1;font-size: inherit;"
                    class="common-style-input"
                    @select="onSelectMonitorItem($event.dataItem, index)" />
                </td>
                <!-- グラフ上限 -->
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="graphMax"
                    v-model="e.graphMax"
                    name="graphMax"
                    :step="e.step"
                    :min="e.min"
                    :max="e.max" /> -->
                  <com-number-input
                    input-id="graphMax"
                    v-model="e.graphMax"
                    name="graphMax"
                    :step="e.step"
                    :inputType='"number"'
                    :inputMin="e.min"
                    :inputMax="e.max"
                    @blur="handleBlur($event, index, 'graphMaxD')"
                    @getChildData="getChildData"
                    />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
                <!-- グラフ下限 -->
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="graphMin"
                    v-model="e.graphMin"
                    name="graphMin"
                    :step="e.step"
                    :min="e.min"
                    :max="e.max" /> -->
                  <com-number-input
                    input-id="graphMin"
                    v-model="e.graphMin"
                    name="graphMin"
                    :step="e.step"
                    :inputType='"number"'
                    :inputMin="e.min"
                    :inputMax="e.max"
                    @blur="handleBlur($event, index, 'graphMinD')"
                    @getChildData="getChildData"
                    />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
                <!-- プロット形状 -->
                <td class="ntss-list-body-td plot-type-td">
                  <kendo-dropdownlist
                    v-model="e.plotType"
                    :data-source="getPlotType()"
                    :data-text-field="'text'"
                    :data-value-field="'value'"
                    style="width: 100%;z-index:1;font-size: inherit;"
                    class="common-style-input report-graph-plot-type-dropdown"
                    @open="applyPlotTypeDropdownStyle" />
                </td>
                <!-- プロット色 -->
                <td class="ntss-list-body-td">
                  <input
                    class="graph-color"
                    type="color"
                    v-model="e.plotColor"
                    @change="onChangeColor($event, 'plot', e.isBp, index)"
                  />
                </td>
                <!-- プロットサイズ -->
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="plotSize"
                    v-model="e.plotSize"
                    name="plotSize"
                    :step=1
                    :min=1
                    :max=10 /> -->
                  <com-number-input
                    input-id="plotSize"
                    v-model="e.plotSize"
                    name="plotSize"
                    :step=1
                    :inputType='"number"'
                    :inputMin=1
                    :inputMax=10
                    @blur="handleBlur($event, index, 'plotSizeD')"
                    @getChildData="getChildData"
                    />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
                <!-- 線種 -->
                <td class="ntss-list-body-td">
                  <kendo-dropdownlist
                    v-model="e.lineType"
                    :data-source="getLineType()"
                    :data-text-field="'text'"
                    :data-value-field="'value'"
                    style="width: 100%;z-index:1;font-size: inherit;"
                    class="common-style-input" />
                </td>
                <!-- 線色 -->
                <td class="ntss-list-body-td">
                  <input
                    class="graph-color"
                    type="color"
                    v-model="e.lineColor"
                    @change="onChangeColor($event, 'line', e.isBp, index)"
                  />
                </td>
                <!-- 線太さ(px) -->
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy start -->
                <td class="ntss-list-body-td">
                <!-- mod redmine 6537 帳票グラフ設定の数値入力エリアのフォントサイズが小さい 宋qy end -->
                <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input
                    input-id="lineThickness"
                    v-model="e.lineThickness"
                    name="lineThickness"
                    :step=1
                    :min=1
                    :max=10 /> -->
                  <com-number-input
                    input-id="lineThickness"
                    v-model="e.lineThickness"
                    name="lineThickness"
                    :step=1
                    :inputType='"number"'
                    :inputMin=1
                    :inputMax=10
                    @blur="handleBlur($event, index, 'lineThicknessD')"
                    @getChildData="getChildData"
                    />
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    </template>
        <template #footer>
<div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="btn2-cancel button denial-btn" @click="cancel">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="btn1-execute button registration-btn" :disabled="!isChanged" @click="reflect">確定</button>
      </div>
    </div>
    </template>
  </modal-base>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import SubModalBase from "@/components/modals/SubModalBase";
import MultiSubModalMixin from "@/components/modals/MultiSubModalMixin";
// 1つの帳票グラフ設定を保持するモデル
import { ReportGraph } from "@/models/master-maintenance/mst-treatment/ReportGraphModel"
// 数値入力共通コンポーネント
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
// ApiHelper
import { ApiHelper } from "@/apis/AxiosHelper.js";
import {
  REPORT_GRAPH
} from "@/constants/mstTreatmentDefine.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  // mixinの読込
  mixins: [MultiSubModalMixin],
  components: {
    "modal-base": SubModalBase,
    "com-number-input": CommonNumberInputComponent
  },
  data() {
    return {
      /**
       * 初期表示時の情報
       */
      comparisonData: "",
      /**
       * 初期表示時の情報(血圧以外)
       */
      reportGraphEdit: [],
      /**
       * 初期表示時の情報(血圧)
       */
      reportGraphBpItemEdit: [],
      /**
       * 表示項目の選択肢
       */
      selectMonitorItemList: [],
      /**
       * sys_monitor_itemの全データ
       */
      sysMonitorItem: [],
      childData: null
    };
  },
  methods: {
    // 内部 治療法マスタ:フォーカスアウト時初期値設定不正です start
    getChildData (val) {
      this.childData = val
    },
    handleBlur (event, index, type) {
    this.$nextTick(() => {
      if (type === 'lineThickness') {
        if (this.childData === '10' && event.target.value === '1') {
          this.reportGraphBpItemEdit[index].lineThickness = null
        }
      } else if (type === 'plotSize') {
        if (this.childData === '10' && event.target.value === '1') {
          this.reportGraphBpItemEdit[index].plotSize = null
        }
      } else if (type === 'graphMax') {
        if (this.childData === '10' && event.target.value === '1') {
          this.reportGraphBpItemEdit[index].graphMax = null
        }
      } else if (type === 'graphMin') {
        if (this.childData === '10' && event.target.value === '1') {
          this.reportGraphBpItemEdit[index].graphMin = null
        }
      } else if (type === 'graphMinD') {
        if ((this.childData === '10' || this.childData === '999') && event.target.value === '1') {
          this.reportGraphEdit[index].graphMin = null
        }
      } else if (type === 'graphMaxD') {
        if ((this.childData === '10' || this.childData === '999') && event.target.value === '1') {
          this.reportGraphEdit[index].graphMax = null
        }
      } else if (type === 'plotSizeD') {
        if (this.childData === '10' && event.target.value === '1') {
          this.reportGraphEdit[index].plotSize = null
        }
      } else if (type === 'lineThicknessD') {
        if (this.childData === '10' && event.target.value === '1') {
          this.reportGraphEdit[index].lineThickness = null
        }
      }
    });
    },
    // 内部 治療法マスタ:フォーカスアウト時初期値設定不正です end
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    /**
     * マスタメンテナンス画面のアクション
     */
    ...mapActions("master-maintenance", ["setEditRecord", "findRecordList"]),
    /**
     * 初期処理
     */
    async init() {
      // モニタ項目取得
      await this.getMonitorItem();
    },
    /**
     * 血圧の帳票グラフ設定を取得する.
     *
     * @returns 血圧の帳票グラフ設定のリスト
     */
    getBloodPressure() {
      const reportGraphData = this.getReportGraph();
      // 帳票グラフのデータから血圧の情報を取得
      const bpItemInfoList = reportGraphData.filter(r => r.is_bp);
      const bpItemList = [];
      bpItemInfoList.forEach(bpItemInfo => {
        const reportGraph = new ReportGraph(
          true,
          bpItemInfo.cd,
          bpItemInfo.type,
          bpItemInfo.max,
          bpItemInfo.min,
          bpItemInfo.plot_type,
          bpItemInfo.plot_color,
          bpItemInfo.plot_size,
          bpItemInfo.line_type,
          bpItemInfo.line_color,
          bpItemInfo.line_thickness,
          // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
          bpItemInfo.show_check,
          // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
          );
        // #9312 Mod Start
        // 血圧の名称を取得する
        // const item = this.getSysMonitorItem(bpItemInfo.cd);
        // reportGraph.moniItemName = item ? item.moni_data_short_name : "";
        switch (bpItemInfo.cd) {
          case "90" : { reportGraph.moniItemName = "最高血圧"; break; }
          case "91" : { reportGraph.moniItemName = "最低血圧"; break; }
          case "92" : { reportGraph.moniItemName = "平均血圧"; break; }
          default: { reportGraph.moniItemName = ""; break; }
        }
        // #9312 Mod End
        bpItemList.push(reportGraph);
      });
      this.reportGraphBpItemEdit = bpItemList;
      return this.reportGraphBpItemEdit;
    },
    /**
     * 血圧情報以外の帳票グラフ設定を取得する.
     *
     * @returns 血圧情報以外の帳票グラフ設定
     */
    getItem() {
      const reportGraphData = this.getReportGraph();
      // モデルを格納するリスト
      let itemList = [];
      // 血圧以外の情報を取得
      // 帳票グラフのデータから血圧の情報を取得
      const itemInfoList = reportGraphData.filter(r => !r.is_bp);
      // 取得したデータをモデルに設定
      itemInfoList.forEach(e => {
        // mst_add_monitorの項目が選択されている場合には、コードの頭に
        // REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX を付与する.
        let monitorItemCd = e.cd;
        const monitorType = e.type;
        // mst_add_monitorの項目
        if (monitorType === 2) {
          monitorItemCd = `${ REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX + String(monitorItemCd) }`;
        }

        let plotType = e.plot_type;
        if (plotType === "-") {
          plotType = "triangle";
        }
        let lineType = e.line_type;
        if (lineType === "-") {
          lineType = "Solid";
        }

        const reportGraph = new ReportGraph(
          false,
          monitorItemCd,
          monitorType,
          e.max,
          e.min,
          plotType,
          e.plot_color,
          e.plot_size,
          lineType,
          e.line_color,
          e.line_thickness,
          // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
          e.show_check
          // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
          );
          // monitor_type = 1の場合はグラフの最大、最小を設定する.
          const sysMonitorItem = this.getSysMonitorItem(monitorItemCd);
          if (sysMonitorItem) {
            // 最大、最小値を取得
            const step = 1 / 10 ** sysMonitorItem.decimal_figure;
            reportGraph.step = step;
            reportGraph.max = sysMonitorItem.upper * step;
            reportGraph.min = sysMonitorItem.lower * step;
          }
          itemList.push(reportGraph);
        }
      );
      // 入力可能件数に満たない場合、不足件数分の空要素をリストに設定する.
      const shortage = REPORT_GRAPH.MAX_ITEM_COUNT - itemList.length;
      if (shortage > 0) {
        for (let index = 0; index < shortage; index++) {
          itemList.push(new ReportGraph().createEmpty());
        }
      }
      return itemList;
    },
    /**
     * 治療方法に登録されている帳票グラフ設定をStoreから取得する.
     * 未登録の場合にはREPORT_GRAPH.DEFAULT_JSON_DATAを返却する.
     *
     *
     * @returns 帳票グラフ設定
     */
    getReportGraph() {
      // storeに格納されている編集中のマスタ情報を取得
      const reportGraphSetting = this.getEditRecord.reportGraphSetting;
      if (!reportGraphSetting) {
        return REPORT_GRAPH.DEFAULT_JSON_DATA;
      }
      // jsonに変換
      return JSON.parse(reportGraphSetting);
    },
    /**
     * 表示項目に表示するモニタ項目一覧を取得する.
     */
    async getMonitorItem() {

      /* #9312 MOD Start */

      // モニタ項目
      const sysMonitorItemRequestParam = {
        moniDataType: null,
      }
      // バイタル・モニタ追加項目マスタ
      const mstAddMonitorRequestParam = {
        facility_cd: this.getFacilitySwitch
      }
      // 特殊浄化：モニタ項目
      const sysMonitorItemRequestParam2 = {
        moniDataType: 'Z'
      }
      // mod マスタ一覧 1･施設切替を可能とする 孔s end
      await Promise.all([
        ApiHelper.get("/treatment-record/sys_monitor_item", sysMonitorItemRequestParam),
        ApiHelper.get("/mstInfo/mstAddMonitorByFacilityCd", mstAddMonitorRequestParam),
        ApiHelper.get("/treatment-record/sys_monitor_item", sysMonitorItemRequestParam2),
      ]).then(response => {
        // 透析：モニタ項目
        // mod/ #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong start
        const sysMonitorItem = response[0].data ? response[0].data.filter(item => item.moni_data_no != 0 && item.moni_data_no != 31) : [];
        // mod/ #11250 治療方法マスタ＞トレンドグラフモニタ設定・帳票グラフ設定不適合 tianqidong start
        this.sysMonitorItem = sysMonitorItem;
        // 施設固有：バイタル・モニタ個別項目
        const mstAddMonitor = response[1].data ? response[1].data : [];
        // 特殊浄化：モニタ項目
        const sysMonitorItem2 = response[2].data ? response[2].data : [];

        // 表示用モニタ項目作成
        // キーとなる値がsys_monitore_itemとmst_add_monitorで重複する可能性がある為、
        // データとは別に個別のキーを作成する.※画面表示時のみ
        // モニタータイプ(1 : モニタ項目、2 : バイタルモニタ項目追加マスタ)
        //
        // const monitorItemList = sysMonitorItem
        //   .filter(
        //     s => s.is_disp === '1'
        //     && !REPORT_GRAPH.BP_MONITOR_ITEM.includes(s.moni_data_no)
        //     && !REPORT_GRAPH.EXCLUSION_MONITOR_DATA_TYPE.includes(s.data_type)
        //   )
        //   .map(s => {
        //       return {
        //         value: s.moni_data_no,
        //         text: s.moni_data_name
        //       }
        //     }
        //   );
        // const _tmpMstAddMonitor = mstAddMonitor.filter(
        //   m => m.is_disp === "1"
        // ).map(
        //   m => {
        //     return {
        //       // mod #10077 by zhangruixue 2024-1-5 --start
        //       // value: `${ REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX + String(m.vital_monitor_item_cd) }`,
        //       value: `${ REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX + String(m.vital_monitor_item_cd + 10000) }`,
        //       // mod #10077 by zhangruixue 2024-1-5 --end
        //       text: m.vital_monitor_item_name
        //     }
        //   }
        // );
        // monitorItemList.push(..._tmpMstAddMonitor);

        const expItemNosForDLR = ["52","53","82","83","84","87"];

        let sysMIL = sysMonitorItem.filter( s => s.is_disp === '1' && !expItemNosForDLR.includes(s.moni_data_no) )
          .map( item => {
            return {
              value: item.moni_data_no,
              text: item.moni_data_name
            }
          });
        let sysMonitorListZ = sysMonitorItem2.filter( s => s.is_disp === '1' )
          .map(
            item => {
              return {
                value: item.moni_data_no,
                text: item.moni_data_name
              }
            }
          );

        let monitorItemList = mstAddMonitor.filter( m => m.is_disp === "1" )
          .map(
            m => {
              return {
                value: `${REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX + String(m.vital_monitor_item_cd + 10000)}`,
                text: m.vital_monitor_item_name
              }
            }
          );

        // 未選択項目を先頭に追加
        this.selectMonitorItemList = [...sysMIL, ...monitorItemList, ...sysMonitorListZ];
        this.selectMonitorItemList.unshift(REPORT_GRAPH.UN_SELECT_ITEM);
        /* #9312 MOD End */

        // 登録されているデータ(血圧以外)
        this.reportGraphEdit = this.getItem();
        // 血圧データ
        this.getBloodPressure();
        // 比較用のデータに設定する
        this.comparisonData = this.getSaveData();
      });
    },
    /**
     * sys_monitor_itemからモニタ項目コードのモニタ項目情報を取得する.
     * この関数を使用する前にgetMonitorItem()でsys_monitor_itemのデータ取得されている事を前提とする.
     *
     * @param {String} monitorItemCd モニタ項目コード
     * @returns モニタ項目
     */
    getSysMonitorItem(monitorItemCd) {
      const item = this.sysMonitorItem.find(s =>
          s.moni_data_no === monitorItemCd
        );
      if (!item) {
        return "";
      }
      return item;
    },
    /**
     * プロットタイプの値から表示するプロット形状を取得する.
     *
     * @param {String} プロット形状を識別する文字列
     *                 REPORT_GRAPH.SELECT_ITEM_PLOT_TYPEのvalueの値
     * @returns {String} プロット形状
     *                   REPORT_GRAPH.SELECT_ITEM_PLOT_TYPEのtextの値
     */
    getPlotTypeText(plotTypeValue) {
      const plotType = REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE.find(e => e.value === plotTypeValue);
      return plotType ? plotType.text : "";
    },
    applyPlotTypeDropdownStyle(e) {
      const sender = e?.sender;
      const applyStyle = () => {
        const popup = sender?.popup?.element?.[0]
          || sender?.popup?.wrapper?.[0]
          || null;
        if (!popup) {
          return;
        }
        const legacyFont = "\"Osaka,'ＭＳ Ｐゴシック','MS PGothic',Sans-Serif\"";
        [popup, popup.querySelector(".k-popup"), popup.querySelector(".k-list-container")]
          .filter(Boolean)
          .forEach(element => {
            element.style.setProperty("width", "49.7812px", "important");
            element.style.setProperty("min-width", "49.7812px", "important");
            element.style.setProperty("font-family", legacyFont, "important");
            element.style.setProperty("font-size", "16.5px", "important");
            element.style.setProperty("font-stretch", "100%", "important");
            element.style.setProperty("font-style", "normal", "important");
            element.style.setProperty("font-weight", "400", "important");
            element.style.setProperty("line-height", "24.75px", "important");
            element.style.setProperty("white-space", "normal", "important");
          });
        popup.querySelectorAll(".k-item, .k-list-item, .k-list-item-text, [role='option']").forEach(element => {
          element.style.setProperty("font-family", legacyFont, "important");
          element.style.setProperty("font-size", "16.5px", "important");
          element.style.setProperty("font-stretch", "100%", "important");
          element.style.setProperty("font-style", "normal", "important");
          element.style.setProperty("font-weight", "400", "important");
          element.style.setProperty("line-height", "24.75px", "important");
        });
      };
      applyStyle();
      requestAnimationFrame(applyStyle);
    },
    /**
     * 表示項目が変更された場合のイベントハンドラ
     * 未選択が選択された場合にそれ以外の項目を初期化する.
     *
     * @param {*} dataItem 選択されたモニタ項目
     *                     以下の項目が格納されている.
     *                     moni_data_name,moni_data_no,monitor_type
     * @param {Number} index 変更された行
     */
    onSelectMonitorItem(dataItem, index) {
      // 変更された値が未選択の場合
      const selectedMonitorItemCd = dataItem.value;
      if (selectedMonitorItemCd === REPORT_GRAPH.UN_SELECT_ITEM.value) {
        // this.reportGraphEdit[index] = new ReportGraph().createEmpty();
        return;
      }

      // モニタ項目が選択された場合
      // mst_add_monitorの場合は何もしない.
      if (String(selectedMonitorItemCd).startsWith(REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX)) {
        this.reportGraphEdit[index].monitorType = REPORT_GRAPH.MONITOR_TYPE.MST_ADD_MONITOR;
        this.reportGraphEdit[index].step = null;
        this.reportGraphEdit[index].graphMax = null;
        this.reportGraphEdit[index].max = null;
        this.reportGraphEdit[index].graphMin = null;
        this.reportGraphEdit[index].min = null;
        return;
      }
      // モニタ取得
      const item = this.getSysMonitorItem(selectedMonitorItemCd);
      if (!item) {
        return;
      }
      this.reportGraphEdit[index].monitorType = REPORT_GRAPH.MONITOR_TYPE.SYS_MONITOR_ITEM;
      // 最大、最小値を取得
      const step = 1 / 10 ** item.decimal_figure;
      this.reportGraphEdit[index].step = step;
      this.reportGraphEdit[index].graphMax = item.upper * step;
      this.reportGraphEdit[index].max = item.upper * step;
      this.reportGraphEdit[index].graphMin = item.lower * step;
      this.reportGraphEdit[index].min = item.lower * step;
    },
    /**
     * 色を変更された場合のイベントハンドラ.
     * typeが"plot" or "line" 以外の場合には何もしない.
     *
     * @param {Event} event イベントオブジェクト
     * @param {String} type 選択された種別("plot" or "line")
     * @param {Boolean} isBp 血圧情報か否か(血圧の場合はtrueを指定)
     * @param {Number} index 変更された行数
     *                       血圧情報とそれ以外の情報ではそれぞれのインデックスが渡される.
     *                       例えば、血圧の任意の項目が変更されて場合には、0 ~ 2 のインデックスが渡される.
     *                       血圧以外の項目が変更された場合には、0 ~ 5 のインデックスが渡される.
     */
    onChangeColor(event, type, isBp, index) {
      if (type !== "plot" && type !== "line") {
        return;
      }
      const typeString = type === "plot" ? "線" : "プロット";
      // 色が変更された場合
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "変更確認",
        title: DIALOG_MESSAGES[13000098].title,
        // message: `${ typeString }色も同じ色に変更しますか？`,
        message: messageFormat(DIALOG_MESSAGES[13000098].message,typeString),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            // 色を変更する.
            if (isBp) {
              type === "plot"
                ? this.reportGraphBpItemEdit[index].lineColor = event.target.value
                : this.reportGraphBpItemEdit[index].plotColor = event.target.value
            } else {
              type === "plot"
                ? this.reportGraphEdit[index].lineColor = event.target.value
                : this.reportGraphEdit[index].plotColor = event.target.value
            }
          }
        }
      });
    },
    /**
     * 線種の選択肢を取得する.
     *
     * @see REPORT_GRAPH.SELECT_ITEM_LINE_TYPE を返す.
     * @returns 線種の選択肢
     */
    getLineType() {
      return REPORT_GRAPH.SELECT_ITEM_LINE_TYPE;
    },
    /**
     * プロット形状の選択肢を取得する.
     *
     * @see REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE を返す.
     * @returns プロット形状の選択肢
     */
    getPlotType() {
      return REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE;
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      // モーダルを閉じる.
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240104 linjunfeng start
      // this.hideModal();
      if (this.isChanged) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: ok => {
            if (ok) {
              this.hideModal();
            } 
          }
        });
      } else {
        this.hideModal();
      }
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240104 linjunfeng end
    },
    /**
     * 確定ボタン押下時イベント処理
     * ※呼出元の`applyReportGraphSubModal`を呼びだします.
     */
    async reflect() {
      // 同じモニタ項目が指定されていないか
      // 指定されていない場合、falseが返却される為、falseの場合に処理を行う.
      if (!await this.hasSameMonitorItem()) {
        // 確定ボタン押下時の処理はモーダルを閉じるのみ.
        const saveData = this.getSaveData();
        // add #8071 治療方法のグラフ設定が反映されない dou start
        let maxValidate = false;
        let minValidate = false;
        let extentValidate = false;
        let max = null;
        let min = null;
        JSON.parse(saveData, function (key, value) {
          if (key == "max" && value == null) {
            maxValidate = true;
          } else if (key == "min" && value == null) {
            minValidate = true;
          } else if (key == "max"){
            max = value;
          } else if (key == "min") {
            min = value;
            if (max < min) {
              extentValidate = true;
            }
            max = null;
            min = null;
          }
        });
        if (maxValidate || minValidate || extentValidate) {
          if (maxValidate && minValidate) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "必須項目未入力",
              // message: "グラフ上限とグラフ下限" + "は必須入力項目です。</br>値を入力してください。",
              title: DIALOG_MESSAGES['00200094'].title,
              message: messageFormat(DIALOG_MESSAGES['00200094'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          } else if (maxValidate) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "必須項目未入力",
              // message: "グラフ上限" + "は必須入力項目です。</br>値を入力してください。",
              title: DIALOG_MESSAGES['00200095'].title,
              message: messageFormat(DIALOG_MESSAGES['00200095'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          } else if (minValidate){
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "必須項目未入力",
              // message: "グラフ下限" + "は必須入力項目です。</br>値を入力してください。",
              title: DIALOG_MESSAGES['00200096'].title,
              message: messageFormat(DIALOG_MESSAGES['00200096'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          } else {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "大小不正",
              // message: "グラフ上限とグラフ下限の大小関係が正しくありません",
              title: DIALOG_MESSAGES['00200097'].title,
              message: messageFormat(DIALOG_MESSAGES['00200097'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
          return;
        }
        // add #8071 治療方法のグラフ設定が反映されない dou end
        // storeから取得
        const editRecord = this.getEditRecord;
        editRecord.reportGraphSetting = saveData;
        this.setEditRecord(editRecord);
        this.hideModal();
      }
    },
    /**
     * 同じ項目コードが選択されていないかのチェック
     * 同じ項目コードが選択されている場合、確認メッセージを表示する.
     * 確認メッセージで[Cancel]がクリックされた場合、falseを返却する.
     *
     * @returns 含まれている場合には、trueを返却する.
     */
    async hasSameMonitorItem() {
      // 未登録情報を取り除いたリストを取得
      const checkList = this.reportGraphEdit
        .filter(e => e.monitorItemCd !== REPORT_GRAPH.UN_SELECT_ITEM.value)
        .map(e => `${ e.monitorType }-${ e.monitorItemCd }`);
      // ファイル名リストをSetオブジェクトに(重複排除)
      const set = new Set(checkList);
      if (checkList.length === set.size) {
        return false;
      }
      // 元のリストと重複排除リストの長さが違うなら重複あり
      return await this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "重複確認",
        title: DIALOG_MESSAGES[13000099].title,
        // message: `同じモニタ項目が指定されています。<br>よろしいですか？`,
        message: messageFormat(DIALOG_MESSAGES[13000099].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          return answer;
        }
      }) === 0 ? true : false;
    },
    /**
     * 保存するjson文字列を取得する.
     *
     * @returns 保存するデータ(json文字列)
     */
    getSaveData() {
      const saveDataList = [...this.reportGraphBpItemEdit, ...this.reportGraphEdit]
        // 未登録のデータは除外する.
        .filter(e => e.monitorItemCd !== REPORT_GRAPH.UN_SELECT_ITEM.value)
        .map(e => {
          return e.getSaveData();
        });
      return JSON.stringify(saveDataList);
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240112 linjunfeng start
    compareObjects(obj1, obj2) {
      // 基本型(文字列、数字など)の場合は、そのまま等価比較をします。
      if (!this.isObject(obj1)) {
        return obj1 == obj2;
      }
      // 1つ目のオブジェクトの属性名を全て取得します
      const keys = Object.keys(obj1);
      // 属性を横断して深さを比較します
      for (let key of keys) {
        if (key === "plot_color" || key === "line_color") {
          obj1[key] = obj1[key].toUpperCase();
          obj2[key] = obj2[key].toUpperCase();
        }
        if (!this.compareObjects(obj1[key], obj2[key])) {
          return false;
        }
      }
      return true;
    },

    isObject(value) {
      return value && typeof value === 'object';
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240112 linjunfeng end
  },
  /**
   * computed
   */
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("master-maintenance", [
      "getFacilitySwitch",
      "getEditRecord"
    ]),
    /**
     * 変更されているか否か
     *
     * @returns 変更されている場合はtrueを返却する.
     */
    isChanged() {
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240112 linjunfeng start
      const obj1 = this.comparisonData ? JSON.parse(this.comparisonData) : "";
      const obj2 = this.getSaveData() ? JSON.parse(this.getSaveData()) : "";
      if (obj1.length !== obj2.length) {
        return true;
      }
      return !(this.compareObjects(obj1, obj2));
      // return !(this.comparisonData === this.getSaveData());
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240112 linjunfeng endd
    }
  },
  /**
   * created
   */
  async created() {
    try {
      // 共通ローダー:表示名設定
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // 初期処理
      await this.init();
    } catch (error) {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('ReportGraphSettingSubModalComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      console.log(error);
    } finally {
      this.setLoadingScreenVisible(false);
    }
  }
}
</script>

<style scoped>
/**
 * メインエリアのスタイル
 */
.main-content {
  height: calc(100% - 5px);
  overflow: hidden;
}
/**
 * 一覧部の大枠のスタイル
 */
.list-content {
  height: calc(100% - 5px);
}
/**
 * 一覧部のスタイル
 */
.scroll-table {
  overflow: auto;
  width: calc(100% - 20px);
  margin: 10px;
  height: calc(100% - 10px);
}
/**
 * 選択行のスタイル
 * ※選択行の色はマスタメンテナンス画面で選択された時の色に合わせる.
 */
.selected-row {
  background-color: var(--master-maintenance-kgrid-selected-background-color) !important;
}
/**
 * 偶数行の背景色の設定
 */
tr:nth-child(2n){
  background-color: var(--ntss-list-content-2nd-background-color);
  color: var(--ntss-list-body-color);
}
.report-graph-header,
.ntss-list-header-th-sticky {
  z-index: 2;
}
.report-graph-header {
  text-align:center;
  top:calc(2em + 8px);
}
ons-input .text-input {
  font-size: 1.5em;
}

ons-input :deep(.text-input) {
  font-size: 1.5em;
}
.graph-color {
  font-size: 1.25em;
  margin: 5px 10px;
  width: 80px;
  height: 25px;
  text-align: left;
}
/**
 * プロット形状のセルのフォント
 * font-familiyを指定しているのは、プロット形状で記号を使用しているが、
 * GoogleChromeの場合だと小さく表示されてしまう事象を解決する為です.
 */
.plot-type-td {
  font-family: "Osaka,'ＭＳ Ｐゴシック','MS PGothic',Sans-Serif", Osaka, 'ＭＳ Ｐゴシック', 'MS PGothic', sans-serif;
}

.plot-type-td :deep(.report-graph-plot-type-dropdown),
.plot-type-td :deep(.report-graph-plot-type-dropdown .k-input-value-text),
.plot-type-td :deep(.report-graph-plot-type-dropdown .k-input-inner) {
  font-family: "Osaka,'ＭＳ Ｐゴシック','MS PGothic',Sans-Serif", Osaka, 'ＭＳ Ｐゴシック', 'MS PGothic', sans-serif;
  font-size: 16.5px;
  line-height: 24.75px;
}

</style>
