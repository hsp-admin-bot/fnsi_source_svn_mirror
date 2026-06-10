/**
 * 装置記録詳細用ストア
 */
import {
  sendRequestFetchMotionRecordDetail,
  sendRequestChangeIsCorrection,
  sendRequestFetchDetailGraphs,
  sendRequestFetchDetailGraphsDissolution,
  sendRequestFetchDetailGatheringDownload,
  sendRequestUpdateServiceSupport,
  sendRequestGetMachineRecordByMachineAndMotionRecordNo
} from "@/apis/operation-viewer.js";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 装置記録
    motionRecord: [],
    // 装置記録詳細
    motionRecordDetail: [],
    // 自己診断画面切り替え用testType
    testType: 1,
    // イベント発生日
    eventRegDate: "",
    // 自己診断結果：配管データ
    ufrc: [],
    // 自己診断結果：漏血データ
    bloodLeakage: [],
    // 自己診断結果：透析液流量データ
    dialysateFlowRate: [],
    // 自己診断結果：濃度データ
    concentration: [],
    // 自己診断結果：配管テストデータ
    piping: [],
    // 自己診断結果：希釈テストデータ
    hemodilution: [],
    // 溶解記録データ
    dissolutions: [],
    // add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
    selftList: [],
    // add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
    // 表/グラフの切り替えフラグ
    isTable: true,
    // DABデータかどうかのフラグ
    isDab: true,
    // 配管漏れグラフデータ
    ufrcLeakageGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        // tickInterval: 1,
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: {
        // 1番目のy軸
        title: {
          text: "配管漏れ(mmHg)",
          x: -20
        },
        min: -30.0,
        max: 30.0,
        tickInterval: 15,
        labels: {
          align: "left",
          x: -26
        }
      },
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "配管漏れ(陰圧)",
          color: "#c08e47",
          data: []
        },
        {
          name: "配管漏れ(陽圧)",
          color: "#f8e352",
          data: []
        },
        {
          name: "ＣＦ漏れ",
          color: "#d5848b",
          data: []
        },
        {
          name: "ＣＦ２漏れ",
          color: "#ae8dbc",
          data: []
        }
      ]
    },
    // 配管(除水、バランス)グラフデータ
    otherUfrcGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸
          title: {
            text: "除水/バランス(mmHg)",
            x: -20
          },
          min: -300,
          max: -100,
          alignTicks: false,
          tickInterval: 50,
          labels: {
            align: "left",
            x: -28,
            style: {
              textOverflow: "none"
            }
          }
        },
        {
          // 2番目のy軸
          title: false,
          min: -100,
          max: 100,
          alignTicks: false,
          tickInterval: 50,
          opposite: true, // 右側のy軸とする
          labels: {
            align: "right",
            x: 25
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "除水",
          color: "#66b7ec",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        },
        {
          name: "バランス",
          color: "#7b9ad0",
          data: [],
          yAxis: 1 // 2番目のy軸を利用する
        }
      ]
    },
    // 漏血グラフデータ
    bloodLeakageGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: {
        // 1番目のy軸
        title: {
          text: "漏血(V)",
          x: -20
        },
        min: 1.0,
        max: 6.0,
        alignTicks: false,
        tickInterval: 1,
        labels: {
          align: "left",
          x: -26
        }
      },
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "赤電圧",
          color: "#d5848b",
          data: []
        },
        {
          name: "緑電圧",
          color: "#c3cfa9",
          data: []
        }
      ]
    },
    // 透析液流量グラフデータ
    dialysateFlowRateGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: {
        // 1番目のy軸
        title: {
          text: "透析液流量(mL/min)",
          x: -20
        },
        min: 300,
        max: 700,
        alignTicks: false,
        tickInterval: 100,
        labels: {
          align: "left",
          x: -26
        }
      },
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "透析液流量",
          color: "#b1d7e4",
          data: []
        }
      ]
    },
    // 濃度グラフデータ
    selfDiagnosisConcentrationGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        // tickInterval: 1,
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸
          title: {
            text: "濃度(％)",
            x: -20
          },
          min: -10.0,
          max: 10.0,
          alignTicks: false,
          tickInterval: 5,
          labels: {
            align: "left",
            x: -26
          }
        },
        {
          // 2番目のy軸
          title: false,
          min: -10.0,
          max: 10.0,
          alignTicks: false,
          tickInterval: 5,
          opposite: true, // 右側のy軸とする
          labels: {
            align: "right",
            x: 25
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "Ｂ原液",
          color: "#7b9ad0",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        },
        {
          name: "透析液",
          color: "#d5848b",
          data: [],
          yAxis: 1 // 2番目のy軸を利用する
        }
      ]
    },
    // 配管テスト圧力グラフデータ
    pipingTestPressureGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 20,
        marginLeft: 40
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸
          title: {
            text: "圧力(kPa)",
            x: -15
          },
          min: 30,
          max: 150,
          alignTicks: false,
          tickInterval: 30,
          labels: {
            align: "left",
            x: -21
          }
        },
        {
          // 2番目のy軸
          title: false,
          min: -10,
          max: 30,
          alignTicks: false,
          tickInterval: 10,
          opposite: true, // 右側のy軸とする
          labels: {
            align: "right",
            x: 15
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "給水圧",
          color: "#e5ab47",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        },
        {
          name: "送液圧低",
          color: "#f8e352",
          data: [],
          yAxis: 1 // 2番目のy軸を利用する
        },
        {
          name: "送液圧高",
          color: "#c08e47",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        }
      ]
    },
    // 配管テスト濃度セルグラフデータ
    pipingTestConcentrationCellGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 20,
        marginLeft: 40
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸
          title: {
            text: "濃度セル(mS/cm)",
            x: -15
          },
          min: 0.0,
          max: 5.0,
          alignTicks: false,
          tickInterval: 1,
          lineWidth: 1,
          labels: {
            align: "left",
            x: -21
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "濃度セル３",
          color: "#b1d7e4",
          data: []
        },
        {
          name: "濃度セル４",
          color: "#c3cfa9",
          data: []
        }
      ]
    },
    // 配管テスト判定時間グラフデータ
    judgementTermGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 20,
        marginLeft: 40
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸
          title: {
            text: "判定時間(秒)",
            x: -15
          },
          min: 0,
          max: 180,
          alignTicks: false,
          tickInterval: 45,
          labels: {
            align: "left",
            x: -21
          }
        },
        {
          // 2番目のy軸
          title: false,
          min: 0,
          max: 65,
          alignTicks: false,
          tickInterval: 65,
          opposite: true, // 右側のy軸とする
          labels: {
            align: "right",
            x: 15
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "注水判定時間",
          color: "#7b9ad0",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        },
        {
          name: "排液判定時間",
          color: "#66b7ec",
          data: [],
          yAxis: 1 // 2番目のy軸を利用する
        }
      ]
    },
    // 希釈テストグラフデータ
    hemodilutionTestGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 20,
        marginLeft: 40
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸
          title: {
            text: "希釈テスト(mS/cm)",
            x: -15
          },
          min: 2.0,
          max: 5.0,
          alignTicks: false,
          tickInterval: 1,
          labels: {
            align: "left",
            x: -21
          }
        },
        {
          // 2番目のy軸
          title: false,
          min: 12.0,
          max: 16.0,
          alignTicks: false,
          tickInterval: 2,
          opposite: true, // 右側のy軸とする
          labels: {
            align: "right",
            x: 15
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      plotOptions: {
        // 点の設定
        series: {
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "Ｂ液濃度",
          color: "#7b9ad0",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        },
        {
          name: "透析液濃度",
          color: "#b1d7e4",
          data: [],
          yAxis: 1 // 2番目のy軸を利用する
        }
      ]
    },
    // 原液濃度グラフデータ
    concentrationGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸
          title: {
            text: "原液濃度(mS/cm)",
            x: -20
          },
          min: 30,
          max: 60,
          alignTicks: false,
          tickInterval: 7.5,
          labels: {
            align: "left",
            x: -26
          }
        },
        {
          // 2番目のy軸
          title: false,
          min: 160.0,
          max: 200.0,
          alignTicks: false,
          tickInterval: 10,
          opposite: true, // 右側のy軸とする
          labels: {
            align: "right",
            x: 25
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      boost: {
        useGPUTranslations: true,
        usePreAllocated: true
      },
      plotOptions: {
        // 点の設定
        series: {
          turboThreshold: 0,
          boostThreshold: 0,
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "Ｂ原液濃度",
          color: "#7b9ad0",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        },
        {
          name: "Ａ原液濃度",
          color: "#d5848b",
          data: [],
          yAxis: 1 // 2番目のy軸を利用する
        }
      ]
    },
    // 原液温度グラフデータ
    temperatureGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: {
        // 1番目のy軸
        title: {
          text: "原液温度(℃)",
          x: -20
        },
        min: 10.0,
        max: 40.0,
        tickInterval: 10,
        labels: {
          align: "left",
          x: -26
        }
      },
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      boost: {
        useGPUTranslations: true,
        usePreAllocated: true
      },
      plotOptions: {
        // 点の設定
        series: {
          turboThreshold: 0,
          boostThreshold: 0,
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "Ｂ原液温度",
          color: "#7b9ad0",
          data: []
        },
        {
          name: "Ａ原液温度",
          color: "#d5848b",
          data: []
        }
      ]
    },
    // 溶解時間グラフデータ
    dissolutionTimeGraphData: {
      chart: {
        height: 200,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: {
        // 1番目のy軸
        title: {
          text: "溶解時間(秒)",
          x: -20
        },
        min: 100,
        max: 300,
        alignTicks: false,
        tickInterval: 50,
        labels: {
          align: "left",
          x: -26
        }
      },
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      boost: {
        useGPUTranslations: true,
        usePreAllocated: true
      },
      plotOptions: {
        // 点の設定
        series: {
          turboThreshold: 0,
          boostThreshold: 0,
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "Ｂ原液溶解時間",
          color: "#7b9ad0",
          data: []
        },
        {
          name: "Ａ原液溶解時間",
          color: "#d5848b",
          data: []
        }
      ]
    },
    // DRY-50A溶解記録グラフデータ
    dry50AGraphData: {
      chart: {
        height: 300,
        type: "line",
        marginRight: 25,
        marginLeft: 45
      },
      credits: {
        enabled: false
      },
      //add FNSI-highchartsのボタンを削除 江 start
      navigation:{
        buttonOptions:{
          enabled: false
        }
      },
      //add FNSI-highchartsのボタンを削除 江 end
      title: false,
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          // don't display the dummy year
          minute: "%Y-%m-%d<br/>%H:%M",
          hour: "%Y-%m-%d<br/>%H:%M",
          day: "%Y<br/>%m-%d",
          week: "%Y<br/>%m-%d",
          month: "%Y-%m",
          year: "%Y"
        }
      },
      yAxis: [
        {
          // 1番目のy軸(濃度 mS/cm)
          title: false,
          min: 150.0,
          max: 250.0,
          alignTicks: false,
          tickInterval: 10,
          labels: {
            align: "left",
            x: -26
          }
        },
        {
          // 2番目のy軸(液温度 ℃)
          gridLineWidth: "0",
          title: false,
          min: 10.0,
          max: 40.0,
          alignTicks: false,
          tickInterval: 5,
          opposite: true, // 右側のy軸とする
          labels: {
            align: "right",
            x: 25
          }
        }
      ],
      legend: {
        // グラフの凡例
        layout: "vertical", // 縦方向に並べる
        align: "left", // グラフの右に表示（左右中央）
        verticalAlign: "top", // グラフの中央に表示（上下中央）
        floating: true, // 凡例をプロット部分に表示
        x: 30,
        y: -5
      },
      boost: {
        useGPUTranslations: true,
        usePreAllocated: true
      },
      plotOptions: {
        // 点の設定
        series: {
          turboThreshold: 0,
          boostThreshold: 0,
          marker: {
            enabled: false // データプロット(●、▲、■)を非表示
          }
        }
      },
      tooltip: {
        xDateFormat: "%Y-%b-%e %H:%M"
      },
      series: [
        {
          // グラフの中身（データの設定）
          name: "濃度 mS/cm",
          color: "#7b9ad0",
          data: [],
          yAxis: 0 // 1番目のy軸を利用する
        },
        {
          name: "液温度 ℃",
          color: "#d5848b",
          data: [],
          yAxis: 1 // 2番目のy軸を利用する
        }
      ]
    },
    // 表示機関(単位：週)
    displayPeriod: 0,
    // グラフに表示する終了日
    endGraphDate: "",
    // ダウンロードファイルの中身
    downloadData: "",
    // スキップ行数
    offset: 0
  },
  mutations: {
    // 装置記録セット
    setMotionRecord(state, motionRecord) {
      state.motionRecord = motionRecord;
    },
    // 装置記録クリア
    clearMotionRecord(state) {
      state.motionRecord = [];
    },
    // 装置記録詳細セット
    setMotionRecordDetail(state) {
      state.motionRecordDetail = state.motionRecord;
      state.endGraphDate = state.motionRecordDetail.eventRegDate.replace(
        /\//g,
        ""
      );
    },
    // 装置記録詳細クリア
    clearMotionRecordDetail(state) {
      state.motionRecordDetail = [];
    },
    // 装置記録詳細マージ
    assignMotionRecordDetail(state, motionRecordDetail) {
      // 対処フラグがassignで上書きされてしまうため、退避
      const _isCorrection = motionRecordDetail.isCorrection;
      const isCorrectionUpDate = motionRecordDetail.isCorrectionUpDate;
      const serviceSupportType = motionRecordDetail.serviceSupportType;
      const serviceSupportUpDate = motionRecordDetail.serviceSupportUpDate;
      const serviceSupportUserId = motionRecordDetail.serviceSupportUserId;
      Object.assign(motionRecordDetail, state.motionRecord);
      // マージ後のデータに対処フラグを設定し直す
      motionRecordDetail.isCorrection = _isCorrection;
      motionRecordDetail.isCorrectionUpDate = isCorrectionUpDate;
      motionRecordDetail.serviceSupportType = serviceSupportType;
      motionRecordDetail.serviceSupportUpDate = serviceSupportUpDate;
      motionRecordDetail.serviceSupportUserId = serviceSupportUserId;
      state.motionRecordDetail = motionRecordDetail;
    },
    setEventRegDate(state, baseDate) {
      baseDate = baseDate.replace(/\//g, "");
      const eventRegDate = new Date(
        baseDate.slice(0, 4),
        baseDate.slice(4, 6) - 1,
        baseDate.slice(6)
      );
      eventRegDate.setDate(eventRegDate.getDate());
      state.eventRegDate = eventRegDate;
    },
    // 実地/未実地の表示切替
    changeIsCorrection(state, isCorrection) {
      state.motionRecord.isCorrection = isCorrection;
      state.motionRecordDetail.isCorrection = isCorrection;
    },
    /**
     * stateのサービス対応区分を更新
     * @param {*} state stateオブジェクト
     * @param {*} type サービス対応区分
     */
    changeServiceSupportInfo(state, type) {
      state.motionRecord.serviceSupportType = type;
      state.motionRecordDetail.serviceSupportType = type;
    },
    // 自己診断画面切り替え用testTypeセット
    setTestType(state, testType) {
      state.testType = 1;
      state.testType = testType;
    },
    // 自己診断データセット
    setTestResults(state, testResults) {
      const waitLoop = setInterval(function(){
        if (state.selftList.hasOwnProperty("selftList")) {
          clearInterval(waitLoop);
          if (testResults.ufrc) {
            // 配管の表のみ使う
            testResults.ufrc.forEach(e => {
              const selftData = state.selftList.selftList.find(data => 
                data.motionRecordNo === e.recordNo
              );
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
              // e.testResultData = JSON.parse(selftData.testResultData);
              // state.ufrc.push(e);
              if(selftData){
              e.testResultData = JSON.parse(selftData.testResultData);
              state.ufrc.push(e);
              }
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
            });
          }
          if (testResults.bloodLeakage) {
            testResults.bloodLeakage.forEach(e => {
              const selftData = state.selftList.selftList.find(data => 
                data.motionRecordNo === e.recordNo
              );
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
              // e.testResultData = JSON.parse(selftData.testResultData);
              // state.bloodLeakage.push(e);
              if(selftData){
              e.testResultData = JSON.parse(selftData.testResultData);
              state.bloodLeakage.push(e);
              }
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
            });
          }
          if (testResults.dialysateFlowRate) {
            testResults.dialysateFlowRate.forEach(e => {
              const selftData = state.selftList.selftList.find(data => 
                data.motionRecordNo === e.recordNo
              );
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
              // e.testResultData = JSON.parse(selftData.testResultData);
              // state.dialysateFlowRate.push(e);
              if(selftData){
              e.testResultData = JSON.parse(selftData.testResultData);
              state.dialysateFlowRate.push(e);
              }
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
            });
          }
          if (testResults.concentration) {
            testResults.concentration.forEach(e => {
              const selftData = state.selftList.selftList.find(data => 
                data.motionRecordNo === e.recordNo
              );
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
              // e.testResultData = JSON.parse(selftData.testResultData);
              // state.concentration.push(e);
              if(selftData){
              e.testResultData = JSON.parse(selftData.testResultData);
              state.concentration.push(e);
              }
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
            });
          }
          if (testResults.piping) {
            testResults.piping.forEach(e => {
              const selftData = state.selftList.selftList.find(data => 
                data.motionRecordNo === e.recordNo
              );
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
              // e.testResultData = JSON.parse(selftData.testResultData);
              // state.piping.push(e);
              if(selftData){
              e.testResultData = JSON.parse(selftData.testResultData);
              state.piping.push(e);
              }
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
            });
          }
          if (testResults.hemodilution) {
            testResults.hemodilution.forEach(e => {
              const selftData = state.selftList.selftList.find(data => 
                data.motionRecordNo === e.recordNo
              );
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
              // e.testResultData = JSON.parse(selftData.testResultData);
              // state.hemodilution.push(e);
              if(selftData){
              e.testResultData = JSON.parse(selftData.testResultData);
              state.hemodilution.push(e);
              }
              // mod 8306 【デグレ】自己診断結果の値が表示されない zhao end
            });
          }
        }
      },100);
    },
    // 自己診断データクリア
    clearTestResults(state) {
      state.ufrc.splice(0, state.ufrc.length);
      state.bloodLeakage.splice(0, state.bloodLeakage.length);
      state.dialysateFlowRate.splice(0, state.dialysateFlowRate.length);
      state.concentration.splice(0, state.concentration.length);
      state.piping.splice(0, state.piping.length);
      state.hemodilution.splice(0, state.hemodilution.length);
    },
    // 溶解記録データセット
    setDissolutions(state, dissolutions) {
      dissolutions.forEach(e => {
        state.dissolutions.push(e);
      });
    },
    // 溶解記録データクリア
    clearDissolutions(state) {
      state.dissolutions.splice(0, state.dissolutions.length);
    },
    // 表/グラフの表示切替
    changeIsTable(state, isTable) {
      state.isTable = isTable;
    },
    // グラフデータセット
    setGraphData(state, contents) {
      // APIから取得したグラフデータ
      const graphData = contents.graphData;
      const responseGraphName = contents.responseGraphName;

      // グラフデータをクリア
      Object.keys(responseGraphName).forEach(graphNameKey => {
        // データをクリアする配列名を取得
        const graphName = responseGraphName[graphNameKey];
        for (let i = 0; i < state[graphName].series.length; i++) {
          state[graphName].series[i].data.splice(
            0,
            state[graphName].series[i].data.length
          );
        }
      }, responseGraphName);

      // レスポンスの基準日を元にDate型インスタンスを作成
      const baseDate = new Date(
        graphData.baseDate.slice(0, 4),
        graphData.baseDate.slice(4, 6) - 1,
        graphData.baseDate.slice(6)
      );
      // 終了日のDate型インスタンスを作成
      const endDate = new Date(baseDate);
      endDate.setDate(endDate.getDate() + (state.displayPeriod * 7 + 1));

      // グラフデータをセット
      Object.keys(responseGraphName).forEach(graphNameKey => {
        // データをクリアする配列名を取得
        const graphName = responseGraphName[graphNameKey];
        // SQLではデータを降順で取得しているため、昇順に入れ替える
        const reverseGraph = graphData[graphNameKey].reverse();
        for (let i = 0; i < reverseGraph.length; i++) {
          let year = 0; // 取得したデータ年
          let month = 0; // 取得したデータ月
          let day = 0; // 取得したデータ日
          let hour = 0; // 取得したデータ時間
          let min = 0; // 取得したデータ分
          let sec = 0; // 取得したデータ秒
          let seriesCount = 0; // データをpushするグラフの配列番号
          Object.keys(reverseGraph[i]).forEach(key => {
            if (key !== "evenetRegDate" && key !== "evenetRegTime") {
              if (i === 0) {
                // 一番最初はグラフ開始日となる基準日をpush(※nullを入れることでプロットを表示させない)
                let date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate(), 0, 0, 0);
                state[graphName].series[seriesCount].data.push([
                  date.getTime(),
                  null
                ]);
              }

              // 取得したデータをpush
              // mod 8341自己診断の値がnullの時にグラフ表示が「0」で描画される zhao start
              // state[graphName].series[seriesCount].data.push([
              //   Date.UTC(
              //     year,
              //     Number(month) - 1,
              //     Number(day),
              //     Number(hour),
              //     Number(min),
              //     Number(sec)
              //   ),
              //   Number(reverseGraph[i][key])
              // ]);
              if(reverseGraph[i][key]){
                let date = new Date(year, Number(month) - 1, Number(day), Number(hour), Number(min), Number(sec));
                state[graphName].series[seriesCount].data.push([
                  date.getTime(), 
                  Number(reverseGraph[i][key])
                ]);
              }
              // mod 8341自己診断の値がnullの時にグラフ表示が「0」で描画される zhao end

              // 一番最後はグラフ終了日となる日付をpush(※nullを入れることでプロットを表示させない)
              if (i === reverseGraph.length - 1) {
                let date = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate(), 23, 59, 59);
                state[graphName].series[seriesCount].data.push([
                  date.getTime(), 
                  null
                ]);
              }
              seriesCount += 1;
            } else if (key === "evenetRegDate") {
              // レスポンスのevenetRegDateから年、月、日を取得
              // ※evenetRegDateは各データの連想配列の一番最初に設定されているため、グラフ作成のデータを処理する前に年月日を取得できる
              year = reverseGraph[i][key].slice(0, 4);
              month = reverseGraph[i][key].slice(5, 7);
              day = reverseGraph[i][key].slice(8);
            } else if (key === "evenetRegTime") {
              // レスポンスのevenetRegTimeから時間、分、秒を取得
              // ※evenetRegTimeは各データの連想配列の二番目に設定されているため、グラフ作成のデータを処理する前に時分秒を取得できる
              hour = reverseGraph[i][key].slice(0, 2);
              min = reverseGraph[i][key].slice(3, 5);
              sec = reverseGraph[i][key].slice(6);
            }
          }, reverseGraph[i]);
        }
      }, responseGraphName);
    },
    // 各グラフの終了日時を設定
    setEndGraphDate(state, baseDate) {
      state.endGraphDate = baseDate;
    },
    // 表示機関(単位：週)を設定
    setDisplayPeriod(state, displayPeriod) {
      state.displayPeriod = 0;
      state.displayPeriod = displayPeriod;
    },
    setDownloadData(state, downloadData) {
      state.downloadData = "";
      state.downloadData = downloadData;
    },
    // 取得データのスキップ行数を設定
    setOffset(state, offset) {
      state.offset = offset;
    },
    // 取得データのスキップ行数をリセット
    resetOffset(state) {
      state.offset = 0;
    },
    // add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
    setSelftList(state, selftList) {
      state.selftList = selftList;
    },
    // add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
  },
  actions: {
    /**
     * パラメータに装置動作設定番号に該当するサービス対応区分を更新する.
     * 
     * @param {*} param リクエストパラメータ
     * @param {Boolean} 成功した場合trueを返却する.
     */
    /* eslint-disable no-unused-vars */
    updateServiceSupport({ commit }, param) {
      return sendRequestUpdateServiceSupport(param).then(() =>{
        commit("changeServiceSupportInfo", param.serviceSupportType);
      });
    },
    // 装置記録詳細セット
    setMotionRecord({ commit }, motionRecord) {
      commit("clearMotionRecord");
      commit("setMotionRecord", motionRecord);
    },
    // 初期表示時
    fetchMotionRecordDetail({ commit, state }, info) {
      if (info[0].isClear) {
        commit("clearMotionRecordDetail");
        commit("resetOffset");
      }

      return sendRequestFetchMotionRecordDetail(info[0]).then(response => {
        let motionRecordDetail;
        // Response振り分け
        if (info[0].dataType === 1) {
          // 装置記録
          motionRecordDetail = response.data.machineRecordDetail;
          commit("assignMotionRecordDetail", motionRecordDetail);
        } else if (info[0].dataType === 2) {
          // 緊急発報
          motionRecordDetail = response.data.mNoticeDetail;
          commit("assignMotionRecordDetail", motionRecordDetail);
        } else if (info[0].dataType === 3) {
          // 予防保守/故障予知
          motionRecordDetail = response.data.preventiveDetail;
          commit("assignMotionRecordDetail", motionRecordDetail);
        } else if (info[0].dataType === 4) {
          // 自己診断の中身
          let ufrc = [];
          let bloodLeakage = [];
          let dialysateFlowRate = [];
          let concentration = [];
          let piping = [];
          let hemodilution = [];

          let testResults;
          // 自己診断dabかどうか
          if (response.data.dabTestResults) {
            state.isDab = true;
            testResults = response.data.dabTestResults;
            piping = testResults.piping;
            hemodilution = testResults.hemodilution;
          } else {
            state.isDab = false;
            testResults = response.data.dialyzerTestResults;
            ufrc = testResults.ufrc;
            bloodLeakage = testResults.bloodLeakage;
            dialysateFlowRate = testResults.dialysateFlowRate;
            concentration = testResults.concentration;
          }
          console.log("ufrc: %o", JSON.parse(JSON.stringify(ufrc)));

          if (info[0].isClear) {
            commit("setMotionRecordDetail");
            commit("clearTestResults");
            commit("resetOffset");
            // 対象データによって、testTypeの初期値を設定
            state.testType = info[0].testType;
          }
          // 追加読み込みのための基準日、自己診断記録結果、スキップ行数などを設定
          if (
            ufrc.length > 0 ||
            bloodLeakage.length > 0 ||
            dialysateFlowRate.length > 0 ||
            concentration.length > 0 ||
            piping.length > 0 ||
            hemodilution.length > 0
          ) {
            commit("setEventRegDate", response.data.baseDateForTestResult);
            commit("setTestResults", testResults);
            commit("setOffset", response.data.offset);
          }
        } else if (info[0].dataType === 5) {
          // 溶解記録
          const dissolutions = response.data.dissolutions;
          if (info[0].isClear) {
            commit("setMotionRecordDetail");
            commit("clearDissolutions");
            commit("resetOffset");
          }
          if (dissolutions.length > 0) {
            commit("setEventRegDate", response.data.baseDateForDissolution);
            commit("setDissolutions", dissolutions);
            commit("setOffset", response.data.offset);
          }
        } else if (info[0].dataType === 6) {
          // データ収集
          motionRecordDetail = response.data;
          commit("assignMotionRecordDetail", motionRecordDetail);
        }
      });
    },
    // isCorrectionの状態変更
    changeIsCorrection({ commit }, request) {
      return sendRequestChangeIsCorrection(request).then(() => {
        commit("changeIsCorrection", request.isCorrection);
      });
    },
    // testTypeの設定
    setTestType({ commit }, testType) {
      commit("setTestType", testType);
    },
    changeIsTable({ commit }, isTable) {
      commit("changeIsTable", isTable);
    },
    // 自己診断グラフデータ設定
    setSelfDiagnosisGraphData({ commit }, info) {
      // APIに渡す用のtestType
      // testType=1～4を渡した場合、同じレスポンスが帰ってくる
      // testType=5,6を渡した場合、同じレスポンスが帰ってくる
      let testType = "1";
      sendRequestFetchDetailGraphs(info[0], testType).then(response => {
        const machineGraphData = response.data;
        const machineResponseGraphName = {
          graph1s: "ufrcLeakageGraphData",
          graph2s: "otherUfrcGraphData",
          graph3s: "bloodLeakageGraphData",
          graph4s: "dialysateFlowRateGraphData",
          graph5s: "selfDiagnosisConcentrationGraphData"
        };
        commit("setEndGraphDate", info[0].baseDate);
        commit("setGraphData", {
          graphData: machineGraphData,
          responseGraphName: machineResponseGraphName
        });
        // add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
        commit("setSelftList", machineGraphData);
        // add 7801【デグレ】自己診断結果の集計が不正_再発 関  end
        console.log("setSelftList 実施");
      });

      testType = "5";
      sendRequestFetchDetailGraphs(info[0], testType).then(response => {
        const dabGraphData = response.data;
        const dabResponseGraphName = {
          graph1s: "pipingTestPressureGraphData",
          graph2s: "pipingTestConcentrationCellGraphData",
          graph3s: "judgementTermGraphData",
          graph4s: "hemodilutionTestGraphData"
        };
        commit("setGraphData", {
          graphData: dabGraphData,
          responseGraphName: dabResponseGraphName
        });
        // add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
        commit("setSelftList", dabGraphData);
        // add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
      });
    },
    // 溶解記録グラフデータ設定
    setDissolutionGraphData({ commit }, info) {
      return sendRequestFetchDetailGraphsDissolution(info[0]).then(response => {
        const graphData = response.data;
        const responseGraphName = {
          graph1s: "concentrationGraphData",
          graph2s: "temperatureGraphData",
          graph3s: "dissolutionTimeGraphData",
          graph4s: "dry50AGraphData",
        };
        commit("setEndGraphDate", info[0].baseDate);
        commit("setGraphData", { graphData, responseGraphName });
      });
    },
    // 表示機関(単位：週)設定
    setDisplayPeriod({ commit }, displayPeriod) {
      commit("setDisplayPeriod", displayPeriod);
    },
    // ダウンロードデータ設定
    setDownloadData({ commit }, request) {
      return sendRequestFetchDetailGatheringDownload(request).then(response => {
        // ファイルデータ
        const downloadData = response.request.response;
        commit("setDownloadData", downloadData);
      });
    },
    resetOffset({ commit }) {
      commit("resetOffset");
    },
    getMachineRecordByMachineAndMotionRecordNo(context, {facilityCd, machineTypeCd, machineSerial, motionRecordNo}) {
      return sendRequestGetMachineRecordByMachineAndMotionRecordNo(facilityCd, machineTypeCd, machineSerial, motionRecordNo).then(response => {
        return Promise.resolve(response.data);
      });
    },
  },
  getters: {
    getMotionRecordDetail(state) {
      return state.motionRecordDetail;
    },
    getUfrc(state) {
      return state.ufrc;
    },
    getBloodLeakage(state) {
      return state.bloodLeakage;
    },
    getDialysateFlowRate(state) {
      return state.dialysateFlowRate;
    },
    getConcentration(state) {
      return state.concentration;
    },
    getPiping(state) {
      return state.piping;
    },
    getHemodilution(state) {
      return state.hemodilution;
    },
    getDissolutions(state) {
      return state.dissolutions;
    },
    getTestType(state) {
      return state.testType;
    },
    isTable(state) {
      return state.isTable;
    },
    getUfrcLeakageGraphData(state) {
      return state.ufrcLeakageGraphData;
    },
    getOtherUfrcGraphData(state) {
      return state.otherUfrcGraphData;
    },
    getBloodLeakageGraphData(state) {
      return state.bloodLeakageGraphData;
    },
    getDialysateFlowRateGraphData(state) {
      return state.dialysateFlowRateGraphData;
    },
    getSelfDiagnosisConcentrationGraphData(state) {
      return state.selfDiagnosisConcentrationGraphData;
    },
    getPipingTestPressureGraphData(state) {
      return state.pipingTestPressureGraphData;
    },
    getPipingTestConcentrationCellGraphData(state) {
      return state.pipingTestConcentrationCellGraphData;
    },
    getJudgementTermGraphData(state) {
      return state.judgementTermGraphData;
    },
    getHemodilutionTestGraphData(state) {
      return state.hemodilutionTestGraphData;
    },
    getConcentrationGraphData(state) {
      return state.concentrationGraphData;
    },
    getTemperatureGraphData(state) {
      return state.temperatureGraphData;
    },
    getDissolutionTimeGraphData(state) {
      return state.dissolutionTimeGraphData;
    },
    getDry50AGraphData(state) {
      return state.dry50AGraphData;
    },
    getDisplayPeriod(state) {
      return state.displayPeriod;
    },
    isDab(state) {
      return state.isDab;
    },
    getMotionRecord(state) {
      return state.motionRecord;
    },
    getEventRegDate(state) {
      return state.eventRegDate;
    },
    getEndGraphDate(state) {
      return state.endGraphDate;
    },
    getDownloadData(state) {
      return state.downloadData;
    },
    getOffset(state) {
      return state.offset;
    },
    // add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
    getSelftList(state) {
      return state.selftList;
    }
    // add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
  }
};
