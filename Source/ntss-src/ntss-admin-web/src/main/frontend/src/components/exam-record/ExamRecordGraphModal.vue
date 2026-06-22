/**
 * 検査結果グラフモーダルPage
 */
 <template>
  <modal-base @onClose="closeExamRecordGraphModal">
    <template #header>
      <div>
        <component :is="header"></component>
      </div>
    </template>
    <!-- グラフ -->
    <template #body>
      <div id="custom-highchart-body">
        <highcharts :options="options"></highcharts>
      </div>
    </template>
    <!-- フッター -->
    <template #footer>
      <div class="flex-container flex-container-footer">
        <div class="denial-btn-area" style="background:none">
          <button class="button btn2-cancel registration-btn" @click="closeExamRecordGraphModal">閉じる</button>
        </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import messageDialog from "@/components/common/message-dialog/MessageDialog";

import { Chart } from "@/compat/charts/highcharts";
import Highcharts from "@/compat/charts/highcharts";
import { Boost } from "@/compat/charts/highcharts";
import {deepCopy} from "@/functions/common/CommonFunctions";
import {DISP_ORDER_RIGHT_PAST} from "@/constants/examRecordConstants";
import { getModalBodyElement, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";

//add 9403検査結果グラフのレンジが正しく表示されていない 吉 start
import BigNumber from "@/compat/number/bignumber";
//add 9403検査結果グラフのレンジが正しく表示されていない 吉 end
// add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
import {convertToHalfWidth} from "@/functions/common/CommonFunctions";
// add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start

Boost(Highcharts);

function formatGraphAxisLabelValue(value) {
  const thousandsSep = Math.abs(Number(value)) >= 10000 ? " " : "";
  return Highcharts.numberFormat(value, -1, ".", thousandsSep);
}

function formatGraphTooltipValue(value) {
  return Highcharts.numberFormat(value, -1, ".", " ");
}

export default {
  name: "ExamRecordGraphModal",
  components: {
    highcharts: Chart,
    "modal-base": ModalBase,
    "message-dialog": messageDialog
  },
  data() {
    return {
      main: "",
      header: "",
      examrecordGridToolbarHeight: 500,
      examrecordGridHeight: 300,

      options: {
        // add FNSI-delete Hchart Button 関 start
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        // add FNSI-delete Hchart Button 関 end
        chart: {
          height: 200,
          plotBorderWidth: 1,
          plotBorderColor: '#e6e6e6',
          spacingLeft: 10,
          spacingRight: 10,
          spacingTop: 22,
          spacingBottom: 15,
          events: {
            load() {
              const chart = this;
              Highcharts.addEvent(chart.tooltip, 'refresh', function () {
                const point = chart.hoverPoint;
                const label = chart.tooltip?.label;
                if (!point || !label || chart.styledMode) {
                  return;
                }
                label.attr({
                  stroke: point.color || point.series.color,
                  'stroke-width': chart.options.tooltip?.borderWidth ?? 1
                });
                label.css({
                  minWidth: '300px',
                  whiteSpace: 'normal'
                });
              });
            },
            render() {
              const chart = this;
              requestAnimationFrame(() => {
                chart.container
                  .querySelectorAll('.highcharts-tick')
                  .forEach(el => {
                    el.setAttribute('stroke', '#ccd6eb');
                  });

                const yAxisLabelsGroups = chart.container.querySelectorAll('.highcharts-yaxis-labels');
                const labelsCount = yAxisLabelsGroups.length;
                const drawnBorderKeys = new Set();
                yAxisLabelsGroups.forEach((labelsGroup, index) => {
                    labelsGroup
                      .querySelectorAll('.exam-record-yaxis-labels-border')
                      .forEach(el => el.remove());

                    if (labelsCount <= 1 || index === labelsCount - 1) {
                      return;
                    }

                    let bbox;
                    try {
                      bbox = labelsGroup.getBBox();
                    } catch (e) {
                      return;
                    }
                    if (!bbox.height) {
                      return;
                    }

                    const insetTop = 8;
                    const insetBottom = 8;
                    const y1 = bbox.y + insetTop;
                    const y2 = bbox.y + bbox.height - insetBottom;
                    if (y2 <= y1) {
                      return;
                    }

                    const borderKey = `${Math.round(bbox.x)}-${Math.round(y1)}-${Math.round(y2)}`;
                    if (drawnBorderKeys.has(borderKey)) {
                      return;
                    }
                    drawnBorderKeys.add(borderKey);

                    const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
                    line.setAttribute('class', 'exam-record-yaxis-labels-border');
                    line.setAttribute('x1', String(bbox.x));
                    line.setAttribute('x2', String(bbox.x));
                    line.setAttribute('y1', String(y1));
                    line.setAttribute('y2', String(y2));
                    line.setAttribute('stroke', '#ccc');
                    line.setAttribute('stroke-width', '1');
                    line.setAttribute('pointer-events', 'none');
                    labelsGroup.insertBefore(line, labelsGroup.firstChild);
                  });
              });
            }
          }
        },
        credits: {
          enabled: false
        },
        title: {
          text: "",
          margin: 6,
          // 患者名标题目标位置 x=845, y=24
          x: -14,
          y: 2
        },
        xAxis: [
          {
            tickWidth: 1,
            tickLength: 20,
            categories: [],
            labels: {
              distance: 6
            }
          },{
            linkedTo: 0,
            tickWidth: 1,
            tickLength: 20,
            lineWidth: 0.1,
            margin: 0,
            categories: [],
            labels: {
              distance: 5
            }
          }
        ],
        // mod FNSI-6102 劉全航 start
        // yAxis: {
        //   title: {
        //     text: "",
        //     x: -20
        //   },
        //   max: 300,
        //   min: 0,
        //   plotLines: [{
        //     value: 0,
        //     width: 1,
        //     color: '#808080'
        //   }]
        // },
        yAxis: [],
        // mod FNSI-6102 劉全航 end
        tooltip: {
          // 边框色在 refresh 时设为当前系列色（与折线/● 一致）；不设 borderColor 避免固定灰色
          borderWidth: 1,
          padding: 12,
          style: {
            minWidth: '300px',
            whiteSpace: 'normal'
          },
          pointFormatter: function () {
            const value = formatGraphTooltipValue(this.y);
            return `<span style="color:${this.color}">\u25CF</span> ${this.series.name}: <b>${value}</b><br/>`;
          }
        },
        legend: {
          layout: 'horizontal',
          align: 'center',
          verticalAlign: 'bottom',
          borderWidth: 0,
          margin: 6,
          y: -5,
          itemHiddenStyle: {
            color: '#cccccc',
            textDecoration: 'line-through'
          }
        },
        series: []
      },
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("exam-record/list", [
      // "getDetailCondition",
      "getExamRecordDetailColumn",
      "getExamDetailDataSource",
      // "getExamSetNameList",
      "getExamDataSource",
      "getDetailSelectItems",
      "getExamResultDispOrder"
    ]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPat"]),
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      // モーダルのbodyの高さ
      const mh = getModalBodyElement(this.$el || this)?.clientHeight || 0;
      // モーダルのbodyの高さをグラフの高さに設定
      this.options.chart.height = mh;
      // モーダルのヘッダの高さ
      const hh = queryScopedSelector(".modal-header", this.$el || this)?.clientHeight || 0;
      this.examrecordGridToolbarHeight = mh - hh;
      this.examrecordGridToolbarHeight =
        this.examrecordGridToolbarHeight < 300
          ? 300
          : this.examrecordGridToolbarHeight;
      this.examrecordGridHeight = this.examrecordGridToolbarHeight - 10;
    },
    //add 9403検査結果グラフのレンジが正しく表示されていない zhao start
    //del 9403検査結果グラフのレンジが正しく表示されていない 吉 start
    // strip(num, precision) {
    //   if (precision === void 0) {
    //     precision = 12;
    //   }
    //   return +parseFloat(num);
    // },
    //del 9403検査結果グラフのレンジが正しく表示されていない 吉 end
    //add 9403検査結果グラフのレンジが正しく表示されていない zhao end
    // 閉じるボタン
    closeExamRecordGraphModal() {
      // モーダルを非表示に
      this.hideModal();
    },
    convertStringToFloat(data) {
      // 文字列の場合、数字を除外して何もなければ変換して登録
      // ("123"など純粋な数値の文字列は対象、"10日"などはダメ)
      if (typeof data != "string") {
        // 文字列以外はnull
        return null;
      }
      // add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
      data = convertToHalfWidth(data);
      // add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
      // 文字列から数字および小数点を除外したもの
      //mod 9403検査結果グラフのレンジが正しく表示されていない 吉 start
      //let exclusionNumber = data.replace(/[0-9.]/g, '');
      let exclusionNumber = data.replace(/^-?\d+(\.\d+)?$/, '');
      //mod 9403検査結果グラフのレンジが正しく表示されていない 吉 end
      if (exclusionNumber === "") {
        return parseFloat(data);
      } else {
        console.log("<null判定>検査値 数字除外: " + exclusionNumber);
        return null;
      }
    },
    // 検査結果画面表示順が2：画面左未来、画面右過去の場合、検査日時が同じデータは左から'その他', '透析後', '透析前'の順にソートする
    regOrderClassSort(data) {
      const SORT_LIST = ['その他', '透析後', '透析前'];
      data.sort(function(a,b){
        if(a.columns === undefined || b.columns === undefined || a.columns[0].title === undefined || b.columns[0].title === undefined) return 0;
        if(a.title !== b.title) return 0;
        const aRegOrder = a.columns[0].title;
        const bRegOrder = b.columns[0].title;
        return SORT_LIST.indexOf(aRegOrder) - SORT_LIST.indexOf(bRegOrder);
      });
      return data;
    },

  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
  },
  created() {
    // ------------------------------------------------
    // グラフ作成
    // ★必要なもの
    //   ・(OK)患者名
    //   ・(OK)X軸 日付と透析前後 日付は「01/01(月)00:00」の形式が前提
    //   ・(OK)データ
    //      ・name: '検査項目'
    //      ・connectNulls: true (欠損部分を補正してくれる)
    //      ・data: 実データのCSV
    // ★デザインについて
    //   ・タイトル(患者名)のフォントサイズは変更不可
    //      ・ntss.cssで指定されてる(Important)
    //   ・スマホで見るとX軸の文字が傾く
    // ------------------------------------------------

    // 患者名の取得
    // const selPatId = this.selectedPatId.toString();
    // const DataSource = this.getExamDataSource;
    // let patIndex = DataSource.findIndex(({patId}) => patId === selPatId);
    // this.options.title.text = DataSource[patIndex].patName;
    // console.log("selectedPat");
    // console.log(this.selectedPat);
    //mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start
    //this.options.title.text = this.selectedPat.pat_personal_main.pat_last_name + this.selectedPat.pat_personal_main.pat_first_name;
    this.options.title.text = (this.selectedPat.pat_personal_main.pat_last_name == null ? "": this.selectedPat.pat_personal_main.pat_last_name)+
     (this.selectedPat.pat_personal_main.pat_first_name == null ? "": this.selectedPat.pat_personal_main.pat_first_name);
    //mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end
    // カラムシリアル一覧の作成と横軸の設定
    let DetailColumn = this.getExamRecordDetailColumn;
    if(this.getExamResultDispOrder === DISP_ORDER_RIGHT_PAST){
      DetailColumn = this.regOrderClassSort(deepCopy(DetailColumn));
    }
    let xAxisData = [];         // X軸に入れるデータ
    let primaryCategories = [];    // 上側のラベル
    let secondaryCategories = [];  // 下側のラベル
    let serial_list = [];
    // 画面は日時が降順だがグラフは昇順にしたいので逆方向に検索
    for (let i = 1; i < DetailColumn.length; i++) {
      if (DetailColumn[i].columns) {
        // 透析前・透析後・その他 のラベルを持つキーが存在する場合
        // → 日時カラム（横軸）を判別
        if (DetailColumn[i].title != "A" && DetailColumn[i].columns[0].title != "A") {
          // 上下のタイトルが両方"A"のものは除外
          serial_list.push(DetailColumn[i].field);
          primaryCategories.push(DetailColumn[i].columns[0].title);
          secondaryCategories.push(DetailColumn[i].title.slice(0, 8));
        }
      }
    }
    xAxisData.push({
      tickWidth: 1,
      tickLength: 20,
      categories: primaryCategories,
      labels: {
        distance: 6
      }
    });
    xAxisData.push({
      linkedTo: 0,
      tickWidth: 1,
      tickLength: 20,
      lineWidth: 0.1,
      margin: 0,
      categories: secondaryCategories,
      labels: {
        distance: 5
      }
    });
    this.options.xAxis = xAxisData;
    this.options.xAxis[0].gridLineWidth = 1;
    // test データをカウントする
    // let testDataCount = 0;

    // データの設定
    const DetailDataSource = this.getExamDetailDataSource;
    const selectItems = this.getDetailSelectItems;
    // console.log("データの設定");
    // console.log(selectItems);
    let DetailSeries = [];
    // del FNSI-6102 劉全航 start
    // let maxGraphUpper = 0;
    // let minGraphLower = 99999;
    // del FNSI-6102 劉全航 end
    // console.log(DetailDataSource);
    // add 9403 検査結果グラフのレンジが正しく表示されていない zhou start
    let index = 0 ;
    // add 9403 検査結果グラフのレンジが正しく表示されていない zhou end
    for (let dataIdx = 0; dataIdx < DetailDataSource.length; dataIdx++) {
      let seriesName = DetailDataSource[dataIdx].examItemName;
      let seriesCd = DetailDataSource[dataIdx].examItemCd;
      let seriesData = [];

      // グラフデータの作成
      // selectItemsにある項目コード以外は除外
      for (let itemsIdx = 0; itemsIdx < selectItems.length; itemsIdx++) {
        if (selectItems[itemsIdx] == seriesCd) {
          // console.log("selectItems[itemsIdx]: " + selectItems[itemsIdx] + " <--> seriesCd: " + seriesCd);
          // 列ごとの検査値の追加
          for (let k = 0; k < serial_list.length; k++) {
            let search_serial = serial_list[k];
            if (DetailDataSource[dataIdx][search_serial]) {
              let pointData = DetailDataSource[dataIdx][search_serial];
              // console.log("検査値: " + pointData);
              if (typeof pointData == "string") {
                seriesData.push(this.convertStringToFloat(pointData));
              } else if (typeof pointData == "number") {
                // 数値の場合、そのまま登録
                seriesData.push(pointData);
              } else {
                // 文字列や数値以外の場合、nullを登録
                seriesData.push(null);
              }
            } else {
              // 検査値がない場合、nullを登録
              seriesData.push(null);
            }
          }
          // 検査値をグラフデータに追加
          DetailSeries.push({
            name: seriesName,
            data: seriesData,
            connectNulls: true,
            // add FNSI-6102 劉全航 start
            yAxis: DetailSeries.length,
            // add FNSI-6102 劉全航 end
          });
          // グラフ下限値の保存
          // console.log(DetailDataSource[dataIdx].graphLower);
          const graphLower = DetailDataSource[dataIdx].graphLower;
          //console.log(graphLower);
          // del FNSI-6102 劉全航 start
          // if (graphLower != null && graphLower < minGraphLower) {
          //   minGraphLower = graphLower;
          // }
          // del FNSI-6102 劉全航 end
          // グラフ上限値の保存
          const graphUpper = DetailDataSource[dataIdx].graphUpper;
          //console.log(graphUpper);
          // del FNSI-6102 劉全航 start
          // if (graphUpper > maxGraphUpper) {
          //   maxGraphUpper = graphUpper;
          // }
          // del FNSI-6102 劉全航 end
          // add FNSI-6102 劉全航 start
          // 検査結果グラフの縦軸の数字は小数でした linjunfeng start
          let min,max;
          if (DetailSeries[DetailSeries.length - 1].data[0] > DetailSeries[DetailSeries.length - 1].data[1]) {
            // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
            // min = DetailSeries[DetailSeries.length - 1].data[1] - 10;
            // max = DetailSeries[DetailSeries.length - 1].data[0] + 10;
            min = Math.min(...DetailSeries[DetailSeries.length - 1].data) - 10;
            max = Math.max(...DetailSeries[DetailSeries.length - 1].data) + 10;
          } else {
            // min = DetailSeries[DetailSeries.length - 1].data[0] - 10;
            // max = DetailSeries[DetailSeries.length - 1].data[1] + 10;
            min = Math.min(...DetailSeries[DetailSeries.length - 1].data) - 10;
            max = Math.max(...DetailSeries[DetailSeries.length - 1].data) + 10;
            // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
          }
          // add 9403 検査結果グラフのレンジが正しく表示されていない zkm start
          // modify start 馬 #10342
          let yMin = graphLower ?? min;
          let yMax = graphUpper ?? max;
          if (yMin > yMax) {
            let temp = yMin;
            yMin = yMax;
            yMax = temp;
          }
          // modify end 馬 #10342
          let yAxisTickPositions = new Set();
          yAxisTickPositions.add(yMin);
          for (let tickPosition = 1; tickPosition < 10; tickPosition++) {
            //mod 9403検査結果グラフのレンジが正しく表示されていない zhao start
            // yAxisTickPositions.add(Number(yMin)+ Number(tickPosition * (yMax - yMin) / 10));
            //mod 9403検査結果グラフのレンジが正しく表示されていない 吉 start
            //yAxisTickPositions.add(this.strip(Number(yMin) + Number(tickPosition * (yMax - yMin) / 10)));
            const result = (BigNumber(yMin).plus(BigNumber(tickPosition).times(BigNumber(yMax).minus(BigNumber(yMin))).dividedBy(10))).toNumber();
            yAxisTickPositions.add(result);
            //mod 9403検査結果グラフのレンジが正しく表示されていない 吉 end
            //mod 9403検査結果グラフのレンジが正しく表示されていない zhao end
          }
          yAxisTickPositions.add(yMax);
          // add 9403 検査結果グラフのレンジが正しく表示されていない zkm end
          // 検査結果グラフの縦軸の数字は小数でした linjunfeng end
          this.options.yAxis.push(
            {
              title: {
                text: "",
                x: -20
              },
              labels: {
                distance: 16,
                style: {
                    // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou start
                    //color: Highcharts.getOptions().colors[itemsIdx]
                    color: Highcharts.getOptions().colors[index]
                    // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou end
                },
                formatter: function () {
                  return formatGraphAxisLabelValue(this.value);
                }
              },
              // 検査結果グラフの縦軸の数字は小数でした linjunfeng start
              // max: graphUpper,
              // min: graphLower,
              // add 9403 検査結果グラフのレンジが正しく表示されていない zkm start
              // max: graphUpper ?? max,
              // min: graphLower ?? min,
              // // 検査結果グラフの縦軸の数字は小数でした linjunfeng end
              // tickInterval: graphUpper/10,
              tickPositions: [...yAxisTickPositions],
              // add 9403 検査結果グラフのレンジが正しく表示されていない zkm end
              alignTicks: false,
              plotLines: [{
                value: 0,
                width: 1,
                // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou start
                //color: Highcharts.getOptions().colors[itemsIdx]
                color: Highcharts.getOptions().colors[index]
                // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou end
              }]
            })
          // add FNSI-6102 劉全航 end
          // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou start
          index++;
          // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou end
        }
      }

    }
    // グラフデータの設定
    this.options.series = DetailSeries;

    //上限値と下限値の設定
    // del FNSI-6102 劉全航 start
    // this.options.yAxis.min = minGraphLower;
    // this.options.yAxis.max = maxGraphUpper;
    // this.options.yAxis.tickInterval = 10;
    //console.log("グラフ表示範囲：" + minGraphLower + " ～ " + maxGraphUpper)
    // del FNSI-6102 劉全航 end
  },
  updated() {},
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
};
</script>

<style scoped>
.flex-container-footer {
  justify-content: flex-end;
}

#custom-highchart-body :deep(.highcharts-title) {
  font-size: 1em !important;
}

#custom-highchart-body :deep(.highcharts-root) {
  font-size: unset !important;
}
@media print {
  div :deep(.modal-wrapper){
    display: inline-block !important;
    width: 100%;
  }
  div :deep(.modal-container){
    width: 98%;
  }
  #custom-highchart-body :deep(.highcharts-container){
    width: auto !important;
    height: auto !important;
  }
  #custom-highchart-body :deep(.highcharts-root){
    width: 100%;
    height: 100%;
  }
}
/* 横向き印刷 */
@media print and (orientation: landscape) {
  #custom-highchart-body :deep(.highcharts-root){
    height: 80vh;
  }
}
#custom-highchart-body :deep(.highcharts-axis-labels){
  font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif!important;
  font-size: 11px!important;
}

#custom-highchart-body :deep(.highcharts-xaxis-labels text){
  color: #666666!important;
  cursor: default;
  font-size: 11px!important;
  fill: #666666!important;
}

#custom-highchart-body :deep(.highcharts-yaxis-labels text){
  font-size: 11px!important;
}

#custom-highchart-body :deep(.highcharts-legend-item-hidden .highcharts-graph),
#custom-highchart-body :deep(.highcharts-legend-item-hidden .highcharts-point) {
  stroke: #cccccc !important;
}

#custom-highchart-body :deep(.highcharts-legend-item-hidden .highcharts-point) {
  fill: #cccccc !important;
}

/* #custom-highchart-body :deep(.highcharts-legend-item-hidden text) {
  fill: #666666 !important;
} */

#custom-highchart-body :deep(.highcharts-tooltip) {
  white-space: normal !important;
}

#custom-highchart-body :deep(.highcharts-tooltip span) {
  min-width: 300px;
  display: inline-block;
  box-sizing: border-box;
  line-height: 1.4;
  font-size: 12px !important;
}

#custom-highchart-body :deep(.highcharts-no-tooltip text){
  text-decoration:none!important;
  color:#000000!important;
}

</style>
