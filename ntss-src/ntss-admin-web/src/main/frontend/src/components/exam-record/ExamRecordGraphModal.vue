/**
 * 検査結果グラフモーダルPage
 */
 <template>
  <modal-base @onClose="closeExamRecordGraphModal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <!-- グラフ -->
    <div slot="body" id="custom-highchart-body">
      <highcharts :options="options"></highcharts>
    </div>
    <!-- フッター -->
    <div slot="footer" class="flex-container flex-container-footer">
      <div class="denial-btn-area" style="background:none">
        <button class="button btn2-cancel registration-btn" @click="closeExamRecordGraphModal">閉じる</button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "vuex";
import messageDialog from "@/components/common/message-dialog/MessageDialog";

import Vue from "vue";
import VueHighcharts from "vue-highcharts";
import Highcharts from "highcharts";
import Boost from "highcharts/modules/boost";
import {deepCopy} from "@/functions/common/CommonFunctions";
import {DISP_ORDER_RIGHT_PAST} from "@/constants/examRecordConstants";

//add 9403検査結果グラフのレンジが正しく表示されていない 吉 start
import BigNumber from "bignumber.js";
//add 9403検査結果グラフのレンジが正しく表示されていない 吉 end
// add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
import {convertToHalfWidth} from "@/functions/common/CommonFunctions";
// add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start

Vue.use(VueHighcharts);
Boost(Highcharts);

export default {
  name: "ExamRecordGraphModal",
  components: {
    VueHighcharts,
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
          height: 200
        },
        credits: {
          enabled: false
        },
        title: {
          text: "",
        },
        xAxis: [
          {
            tickWidth: 1,
            tickLength: 20,
            categories: []
          },{
            linkedTo: 0,
            tickWidth: 1,
            tickLength: 20,
            lineWidth: 0.1,
            margin: 0,
            categories: []
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
        tooltip: {},
        legend: {
          layout: 'horizontal',
          align: 'center',
          verticalAlign: 'bottom',
          borderWidth: 0
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
      const mh = document.getElementsByClassName("modal-body")[0]
        .clientHeight;
      // モーダルのbodyの高さをグラフの高さに設定
      this.options.chart.height = mh;
      // モーダルのヘッダの高さ
      const hh = document.getElementsByClassName("modal-header")[0]
        .clientHeight;
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
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
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
    this.options.title.text = (this.selectedPat.pat_personal_main.pat_last_name == null ? "": this.selectedPat.pat_personal_main.pat_last_name )+
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
      categories: primaryCategories
    });
    xAxisData.push({
      linkedTo: 0,
      tickWidth: 1,
      tickLength: 20,
      lineWidth: 0.1,
      margin: 0,
      categories: secondaryCategories
    });
    this.options.xAxis = xAxisData;

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
                style: {
                    // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou start
                    //color: Highcharts.getOptions().colors[itemsIdx]
                    color: Highcharts.getOptions().colors[index]
                    // mod 9403 検査結果グラフのレンジが正しく表示されていない zhou end
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
            }
          )
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
  destroyed() { }
};
</script>

<style scoped>
.flex-container-footer {
  justify-content: flex-end;
}

#custom-highchart-body >>> .highcharts-title {
  font-size: 1em !important;
}

#custom-highchart-body >>> .highcharts-root {
  font-size: unset !important;
}
@media print {
  div >>> .modal-wrapper {
    display: inline-block !important;
    width: 100%;
  }
  div >>> .modal-container {
    width: 98%;
  }
  #custom-highchart-body >>> .highcharts-container {
    width: auto !important;
    height: auto !important;
  }
  #custom-highchart-body >>> .highcharts-root {
    width: 100%;
    height: 100%;
  }
}
/* 横向き印刷 */
@media print and (orientation: landscape) {
  #custom-highchart-body >>> .highcharts-root {
    height: 80vh;
  }
}
</style>
