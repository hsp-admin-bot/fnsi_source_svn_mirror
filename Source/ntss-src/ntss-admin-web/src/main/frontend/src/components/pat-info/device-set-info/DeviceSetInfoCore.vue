<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { getPatById } from "@/functions/PatInfoFunctions";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { changeJsonArray } from "@/functions/DeviceSetInfoFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

export default {
  // 共通タグコンポーネント読み込み


  data() {
    return {
      /**
       * 装置設定タグ
       * clauseName   項目名
       * unitName     単位(ない場合は空文字)
       * min          最小値(ない場合は空文字)
       * max          最大値(ない場合は空文字)
       * initValue     変更前データ
       * editValue     変更後データ
       * DBcode       データベースに更新用コード
       * 初期値の設定はeditValueで行う(DBに登録されていない場合、editValueをそのままDBに登録する)
       * 新通信データ詳細仕様_改訂33__DCS-100NX_2018_対応_20181101_YSK追記.xls
       */
      deviceSetInfo: {
        dev_A_0179: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "179",
          clauseName: "血流量操作範囲上限",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0181: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "181",
          clauseName: "除水速度操作範囲上限",
          unitName: "L/h",
          min: 0.0,
          max: 4.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0038: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "38",
          clauseName: "クリップ式気泡検出器切りＳＷ",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0021: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "21",
          clauseName: "除水計算選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0022: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "22",
          clauseName: "除水計算優先項目選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0039: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "39",
          clauseName: "除水開始遅延時間",
          unitName: "分",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_A_0182: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "182",
          clauseName: "透析液温度操作範囲上限",
          unitName: "℃",
          min: 33.0,
          max: 40.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0183: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "183",
          clauseName: "透析液温度操作範囲下限",
          unitName: "℃",
          min: 33.0,
          max: 40.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0268: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "268",
          clauseName: "透析液流量　設定方法",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0269: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "269",
          clauseName: "透析液流量　比率設定",
          unitName: "",
          min: 1.0,
          max: 3.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0024: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "24",
          clauseName: "シングルニードル切替圧上限",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0025: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "25",
          clauseName: "シングルニードル切替圧下限",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0241: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "241",
          clauseName: "ＴＭＰゼロ補正の選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0168: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "168",
          clauseName: "ＴＭＰゼロ補正警報上限HD",
          unitName: "mmHg",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0169: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "169",
          clauseName: "ＴＭＰゼロ補正警報下限HD",
          unitName: "mmHg",
          min: -100,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0171: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "171",
          clauseName: "ＴＭＰゼロ補正警報上限ECUM",
          unitName: "mmHg",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0172: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "172",
          clauseName: "ＴＭＰゼロ補正警報下限ECUM",
          unitName: "mmHg",
          min: -100,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0174: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "174",
          clauseName: "ＴＭＰゼロ補正警報上限HDF",
          unitName: "mmHg",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0175: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "175",
          clauseName: "ＴＭＰゼロ補正警報下限HDF",
          unitName: "mmHg",
          min: -100,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0177: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "177",
          clauseName: "ＴＭＰゼロ補正警報上限HF",
          unitName: "mmHg",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0178: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "178",
          clauseName: "ＴＭＰゼロ補正警報下限HF",
          unitName: "mmHg",
          min: -100,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_B_0037: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "37",
          clauseName: "ＴＭＰゼロ補正警報上限（HD+補液）",
          unitName: "mmHg",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_B_0038: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "38",
          clauseName: "ＴＭＰゼロ補正警報下限（HD+補液）",
          unitName: "mmHg",
          min: -100,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0391: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "391",
          clauseName: "ＴＭＰゼロ補正警報上限OHDF",
          unitName: "mmHg",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0392: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "392",
          clauseName: "ＴＭＰゼロ補正警報下限OHDF",
          unitName: "mmHg",
          min: -100,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0394: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "394",
          clauseName: "ＴＭＰゼロ補正警報上限OHF",
          unitName: "mmHg",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0395: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "395",
          clauseName: "ＴＭＰゼロ補正警報下限OHF",
          unitName: "mmHg",
          min: -100,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0383: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "383",
          clauseName: "補液量設定値制限（OHDF・OHF用）",
          unitName: "L",
          min: 0,
          max: 240.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0389: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "389",
          clauseName: "OHDF/OHF補液計算優先項目選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0379: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "379",
          clauseName: "前補液　OHDF/OHF　補液速度比率",
          unitName: "%",
          min: 0,
          max: 999,
          initValue: "",
          editValue: ""
        },
        dev_B_0039: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "39",
          clauseName: "後補液　OHDF/OHF　補液速度比率",
          unitName: "%",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0398: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "398",
          clauseName: "補液開始遅延時間",
          unitName: "分",
          min: 0,
          max: 60,
          initValue: "",
          editValue: ""
        },
        dev_A_0369: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "369",
          clauseName: "DP=Qd+Qs(補液速度加算)",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0090: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "90",
          clauseName: "前補液　濾過率",
          unitName: "%",
          min: 0,
          max: 70,
          initValue: "",
          editValue: ""
        },
        dev_B_0040: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "40",
          clauseName: "後補液　濾過率",
          unitName: "%",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0091: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "91",
          clauseName: "ヘマトクリット（Ht）",
          unitName: "%",
          min: 0,
          max: 60,
          initValue: "",
          editValue: ""
        },
        dev_C_0091: {
          screenKey: "ope",
          key1: "dev",
          key2: "C",
          key3: "91",
          clauseName: "検査日時(ヘマトクリット（Ht）)",
          unitName: "%",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0092: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "92",
          clauseName: "総タンパク(TP)",
          unitName: "g/dL",
          min: 0.0,
          max: 9.0,
          initValue: "",
          editValue: ""
        },
        dev_C_0092: {
          screenKey: "ope",
          key1: "dev",
          key2: "C",
          key3: "92",
          clauseName: "検査日時(総タンパク(TP))",
          unitName: "g/dL",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0336: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "336",
          clauseName: "補液速度",
          unitName: "mL/min",
          min: 40,
          max: 300,
          initValue: "",
          editValue: ""
        },
        dev_A_0337: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "337",
          clauseName: "補液量",
          unitName: "mL",
          min: 10,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0185: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "185",
          clauseName: "補液速度操作範囲上限（HDF）",
          unitName: "L/h",
          min: 0.1,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0186: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "186",
          clauseName: "補液速度操作範囲上限（HF）",
          unitName: "L/h",
          min: 0.1,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0030: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "30",
          clauseName: "前補液 補液速度操作範囲上限（HD+補液）",
          unitName: "L/h",
          min: 0.1,
          max: 18.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0396: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "396",
          clauseName: "補液速度操作範囲上限（OHDF）",
          unitName: "L/h",
          min: 0.1,
          max: 24.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0397: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "397",
          clauseName: "補液速度操作範囲上限（OHF）",
          unitName: "L/h",
          min: 0.1,
          max: 24.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0031: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "31",
          clauseName: "後補液　補液速度操作範囲上限（HDF）",
          unitName: "L/h",
          min: 0.1,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0032: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "32",
          clauseName: "後補液　補液速度操作範囲上限（HF）",
          unitName: "L/h",
          min: 0.1,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0033: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "33",
          clauseName: "後補液　補液速度操作範囲上限（HD+補液）",
          unitName: "L/h",
          min: 0.1,
          max: 18.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0034: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "34",
          clauseName: "後補液　補液速度操作範囲上限（OHDF）",
          unitName: "L/h",
          min: 0.1,
          max: 12.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0035: {
          screenKey: "ope",
          key1: "dev",
          key2: "B",
          key3: "35",
          clauseName: "後補液　補液速度操作範囲上限（OHF）",
          unitName: "L/h",
          min: 0.1,
          max: 12.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0384: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "384",
          clauseName: "AFBF　補液比率使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0385: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "385",
          clauseName: "AFBF　補液比率",
          unitName: "%",
          min: 10.0,
          max: 20.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0386: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "386",
          clauseName: "補液速度設定範囲上限（AFBF）",
          unitName: "L/h",
          min: 0.0,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0387: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "387",
          clauseName: "補液速度設定範囲下限（AFBF）",
          unitName: "L/h",
          min: 0.0,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0472: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "472",
          clauseName: "TMP閾値 速度低下",
          unitName: "mmHg",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0473: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "473",
          clauseName: "TMP閾値 速度復帰",
          unitName: "mmHg",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0474: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "474",
          clauseName: "補液量 速度低下",
          unitName: "%",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0475: {
          screenKey: "ope",
          key1: "dev",
          key2: "A",
          key3: "475",
          clauseName: "補液量 速度復帰",
          unitName: "%",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0211: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "211",
          clauseName: "最高血圧上限",
          unitName: "mmHg",
          min: 40,
          max: 250,
          initValue: "",
          editValue: ""
        },
        dev_A_0212: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "212",
          clauseName: "最高血圧下限",
          unitName: "mmHg",
          min: 40,
          max: 250,
          initValue: "",
          editValue: ""
        },
        dev_A_0213: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "213",
          clauseName: "最低血圧上限",
          unitName: "mmHg",
          min: 20,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0214: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "214",
          clauseName: "最低血圧下限",
          unitName: "mmHg",
          min: 20,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0215: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "215",
          clauseName: "平均血圧上限",
          unitName: "mmHg",
          min: 30,
          max: 235,
          initValue: "",
          editValue: ""
        },
        dev_A_0216: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "216",
          clauseName: "平均血圧下限",
          unitName: "mmHg",
          min: 30,
          max: 235,
          initValue: "",
          editValue: ""
        },
        dev_A_0217: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "217",
          clauseName: "脈拍数上限",
          unitName: "bpm",
          min: 40,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0218: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "218",
          clauseName: "脈拍数下限",
          unitName: "bpm",
          min: 40,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0227: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "227",
          clauseName: "最高血圧上限警報　BP　速度",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0219: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "219",
          clauseName: "最高血圧上限警報　BP　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0228: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "228",
          clauseName: "最高血圧下限警報　BP　速度",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0220: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "220",
          clauseName: "最高血圧下限警報　BP　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0229: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "229",
          clauseName: "最高血圧上限警報　除水　速度",
          unitName: "L/h",
          min: 0.0,
          max: 4.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0221: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "221",
          clauseName: "最高血圧上限警報　除水　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0230: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "230",
          clauseName: "最高血圧下限警報　除水　速度",
          unitName: "L/h",
          min: 0.0,
          max: 4.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0222: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "222",
          clauseName: "最高血圧下限警報　除水　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0231: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "231",
          clauseName: "最高血圧上限警報　Na注入　速度",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0223: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "223",
          clauseName: "最高血圧上限警報　Na注入　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0232: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "232",
          clauseName: "最高血圧下限警報　Na注入　速度",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0224: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "224",
          clauseName: "最高血圧下限警報　Na注入　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0233: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "233",
          clauseName: "最高血圧上限警報　補液　速度",
          unitName: "L/h",
          min: 0.0,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0225: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "225",
          clauseName: "最高血圧上限警報　補液　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0234: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "234",
          clauseName: "最高血圧下限警報　補液　速度",
          unitName: "L/h",
          min: 0.0,
          max: 6.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0226: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "226",
          clauseName: "最高血圧下限警報　補液　動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0191: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "191",
          clauseName: "血圧ｶﾌ選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0190: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "190",
          clauseName: "血圧自動測定間隔",
          unitName: "min",
          min: 2,
          max: 180,
          initValue: "",
          editValue: ""
        },
        dev_A_0192: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "192",
          clauseName: "昇圧値",
          unitName: "mmHg",
          min: 80,
          max: 220,
          initValue: "",
          editValue: ""
        },
        dev_A_0193: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "193",
          clauseName: "昇圧方法選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0195: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "195",
          clauseName: "血圧測定方法選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0239: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "239",
          clauseName: "高速測定選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0194: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "194",
          clauseName: "血圧連続測定動作選択",
          unitName: "min",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0235: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "235",
          clauseName: "警報連動測定開始時刻",
          unitName: "min",
          min: 0,
          max: 120,
          initValue: "",
          editValue: ""
        },
        dev_A_0236: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "236",
          clauseName: "治療条件連動測定時刻",
          unitName: "min",
          min: 0,
          max: 120,
          initValue: "",
          editValue: ""
        },
        dev_A_0237: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "237",
          clauseName: "血圧測定自動停止(警報発生)",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0238: {
          screenKey: "bp",
          key1: "dev",
          key2: "A",
          key3: "238",
          clauseName: "血圧測定自動停止(条件変更)",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0240: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "240",
          clauseName: "ＴＭＰ監視モード",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0100: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "100",
          clauseName: "静脈圧自動設定警報幅上限HD/ECUM",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0101: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "101",
          clauseName: "静脈圧自動設定警報幅下限HD/ECUM",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0102: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "102",
          clauseName: "静脈圧自動設定警報限界上限",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0103: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "103",
          clauseName: "静脈圧自動設定警報限界下限",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0104: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "104",
          clauseName: "静脈圧固定警報上限",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0105: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "105",
          clauseName: "静脈圧固定警報下限",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0152: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "152",
          clauseName: "ダイアライザー入口圧自動設定警報幅上限HD/ECUM",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0153: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "153",
          clauseName: "ダイアライザー入口圧自動設定警報幅下限HD/ECUM",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0154: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "154",
          clauseName: "ダイアライザー入口圧自動設定警報限界上限",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0155: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "155",
          clauseName: "ダイアライザー入口圧自動設定警報限界下限",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0156: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "156",
          clauseName: "ダイアライザー入口圧固定警報上限",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0157: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "157",
          clauseName: "ダイアライザー入口圧固定警報下限",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0112: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "112",
          clauseName: "液圧自動設定警報幅上限HD/ECUM",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0113: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "113",
          clauseName: "液圧自動設定警報幅下限HD/ECUM",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0114: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "114",
          clauseName: "液圧自動設定警報限界上限",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0115: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "115",
          clauseName: "液圧自動設定警報限界下限",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0116: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "116",
          clauseName: "液圧固定警報上限",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0117: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "117",
          clauseName: "液圧固定警報下限",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0128: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "128",
          clauseName: "ＴＭＰ自動設定警報幅上限HD/ECUM",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0129: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "129",
          clauseName: "ＴＭＰ自動設定警報幅下限HD/ECUM",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0130: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "130",
          clauseName: "ＴＭＰ自動設定警報限界上限",
          unitName: "mmHg",
          min: -100,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0131: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "131",
          clauseName: "ＴＭＰ自動設定警報限界下限",
          unitName: "mmHg",
          min: -100,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0132: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "132",
          clauseName: "ＴＭＰ固定警報上限",
          unitName: "mmHg",
          min: -30,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0133: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "133",
          clauseName: "ＴＭＰ固定警報下限",
          unitName: "mmHg",
          min: -30,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0126: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "126",
          clauseName: "ＴＭＰ自動追従警報幅上限HD/ECUM",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0127: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "127",
          clauseName: "ＴＭＰ自動追従警報幅下限HD/ECUM",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0146: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "146",
          clauseName: "ダイアライザー差圧自動設定警報幅上限HD/ECUM",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0147: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "147",
          clauseName: "ダイアライザー差圧自動設定警報幅下限HD/ECUM",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0148: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "148",
          clauseName: "ダイアライザー差圧固定警報上限",
          unitName: "mmHg",
          min: -200,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0149: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "149",
          clauseName: "ダイアライザー差圧固定警報下限",
          unitName: "mmHg",
          min: -200,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0106: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "106",
          clauseName: "静脈圧自動設定警報幅上限HDF/HF",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0107: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "107",
          clauseName: "静脈圧自動設定警報幅下限HDF/HF",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0158: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "158",
          clauseName: "ダイアライザー入口圧自動設定警報幅上限HDF/HF",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0159: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "159",
          clauseName: "ダイアライザー入口圧自動設定警報幅下限HDF/HF",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0118: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "118",
          clauseName: "液圧自動設定警報幅上限HDF/HF",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0119: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "119",
          clauseName: "液圧自動設定警報幅下限HDF/HF",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0136: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "136",
          clauseName: "ＴＭＰ自動設定警報幅上限HDF/HF",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0137: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "137",
          clauseName: "ＴＭＰ自動設定警報幅下限HDF/HF",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0134: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "134",
          clauseName: "ＴＭＰ自動追従警報幅上限HDF/HF",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0135: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "135",
          clauseName: "ＴＭＰ自動追従警報幅下限HDF/HF",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0150: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "150",
          clauseName: "ダイアライザー差圧自動設定警報幅上限HDF/HF",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0151: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "151",
          clauseName: "ダイアライザー差圧自動設定警報幅下限HDF/HF",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0110: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "110",
          clauseName: "静脈圧固定警報上限ＳＮ",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0111: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "111",
          clauseName: "静脈圧固定警報下限ＳＮ",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0162: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "162",
          clauseName: "ダイアライザー入口圧固定警報上限ＳＮ",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0163: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "163",
          clauseName: "ダイアライザー入口圧固定警報下限ＳＮ",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0120: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "120",
          clauseName: "液圧自動設定警報幅上限ＳＮ",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0121: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "121",
          clauseName: "液圧自動設定警報幅下限ＳＮ",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0122: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "122",
          clauseName: "液圧自動設定警報限界上限ＳＮ",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0123: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "123",
          clauseName: "液圧自動設定警報限界下限ＳＮ",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0124: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "124",
          clauseName: "液圧固定警報上限ＳＮ",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0125: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "125",
          clauseName: "液圧固定警報下限ＳＮ",
          unitName: "mmHg",
          min: -400,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0140: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "140",
          clauseName: "ＴＭＰ自動設定警報幅上限ＳＮ",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0141: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "141",
          clauseName: "ＴＭＰ自動設定警報幅下限ＳＮ",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0142: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "142",
          clauseName: "ＴＭＰ自動設定警報限界上限ＳＮ",
          unitName: "mmHg",
          min: -100,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0143: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "143",
          clauseName: "ＴＭＰ自動設定警報限界下限ＳＮ",
          unitName: "mmHg",
          min: -100,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0144: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "144",
          clauseName: "ＴＭＰ固定警報上限ＳＮ",
          unitName: "mmHg",
          min: -100,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0145: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "145",
          clauseName: "ＴＭＰ固定警報下限ＳＮ",
          unitName: "mmHg",
          min: -100,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0138: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "138",
          clauseName: "ＴＭＰ自動追従警報幅上限ＳＮ",
          unitName: "mmHg",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0139: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "139",
          clauseName: "ＴＭＰ自動追従警報幅下限ＳＮ",
          unitName: "mmHg",
          min: -400,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0108: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "108",
          clauseName: "静脈圧固定警報上限透析準備",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0109: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "109",
          clauseName: "静脈圧固定警報下限透析準備",
          unitName: "mmHg",
          min: -200,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0160: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "160",
          clauseName: "ダイアライザー入口圧固定警報上限透析準備",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0161: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "161",
          clauseName: "ダイアライザー入口圧固定警報下限透析準備",
          unitName: "mmHg",
          min: -200,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0254: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "254",
          clauseName: "Ｎａ濃度自動設定警報幅上限",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0255: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "255",
          clauseName: "Ｎａ濃度自動設定警報幅下限",
          unitName: "mEq/L",
          min: -50,
          max: 0,
          initValue: "",
          editValue: ""
        },
        dev_A_0256: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "256",
          clauseName: "Ｎａ濃度固定警報上限",
          unitName: "mEq/L",
          min: 100,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0257: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "257",
          clauseName: "Ｎａ濃度固定警報下限",
          unitName: "mEq/L",
          min: 100,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0242: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "242",
          clauseName: "静脈圧自動設定警報監視有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0243: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "243",
          clauseName: "ダイアライザー血液入口圧自動設定警報監視有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0244: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "244",
          clauseName: "透析液圧自動設定警報監視有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0245: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "245",
          clauseName: "ＴＭＰ自動設定警報監視有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0246: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "246",
          clauseName: "差圧自動設定警報監視有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0247: {
          screenKey: "war",
          key1: "dev",
          key2: "A",
          key3: "247",
          clauseName: "Ｎａ濃度自動設定警報監視有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0267: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "267",
          clauseName: "ブラッドボリューム計使用の選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0260: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "260",
          clauseName: "ΔＢＶ低下警報点１",
          unitName: "%",
          min: -100.0,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0261: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "261",
          clauseName: "ΔＢＶ低下警報点２",
          unitName: "%",
          min: -100.0,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0262: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "262",
          clauseName: "ΔＢＶ変化率警報点",
          unitName: "%/min",
          min: -50.0,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0277: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "277",
          clauseName: "ΔＢＶ除水低下速度",
          unitName: "L/h",
          min: 0.0,
          max: 2.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0278: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "278",
          clauseName: "ΔＢＶ除水低下遅延時間",
          unitName: "分",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
        dev_A_0476: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "476",
          clauseName: "ΔSO2低下報知点",
          unitName: "%",
          min: -30.0,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
        dev_A_0258: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "258",
          clauseName: "アクセス再循環測定使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0259: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "259",
          clauseName: "自動測定1",
          unitName: "分",
          min: 0,
          max: 599,
          initValue: "",
          editValue: ""
        },
        dev_A_0263: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "263",
          clauseName: "自動測定2",
          unitName: "分",
          min: 0,
          max: 599,
          initValue: "",
          editValue: ""
        },
        dev_A_0264: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "264",
          clauseName: "自動測定3",
          unitName: "分",
          min: 0,
          max: 599,
          initValue: "",
          editValue: ""
        },
        dev_A_0265: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "265",
          clauseName: "自動測定4",
          unitName: "分",
          min: 0,
          max: 599,
          initValue: "",
          editValue: ""
        },
        dev_A_0266: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "266",
          clauseName: "自動測定5",
          unitName: "分",
          min: 0,
          max: 599,
          initValue: "",
          editValue: ""
        },
        dev_A_0281: {
          screenKey: "bv",
          key1: "dev",
          key2: "A",
          key3: "281",
          clauseName: "再循環率報知",
          unitName: "%",
          min: 0,
          max: 100,
          initValue: "",
          editValue: ""
        },
        pat_A_0009: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "219",
          clauseName: "プライミング補助動脈充填液量",
          unitName: "mL",
          min: 0,
          max: 2000,
          initValue: "",
          editValue: ""
        },
        pat_A_0011: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "220",
          clauseName: "プライミング補助動脈充填流速",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_A_0010: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "225",
          clauseName: "プライミング補助動脈充填後継続の有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        pat_A_0006: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "221",
          clauseName: "プライミング補助静脈充填液量",
          unitName: "mL",
          min: 0,
          max: 2000,
          initValue: "",
          editValue: ""
        },
        pat_A_0008: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "222",
          clauseName: "プライミング補助静脈充填流速",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_A_0007: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "226",
          clauseName: "プライミング補助静脈充填後継続の有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        pat_A_0003: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "223",
          clauseName: "プライミング補助気泡抜き液量",
          unitName: "mL",
          min: 0,
          max: 2000,
          initValue: "",
          editValue: ""
        },
        pat_A_0005: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "224",
          clauseName: "プライミング補助気泡抜き流速",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_A_0004: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "227",
          clauseName: "プライミング補助気泡抜き間欠動作選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        pat_A_0000: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "228",
          clauseName: "プライミング補助液交換量",
          unitName: "mL",
          min: 0,
          max: 2000,
          initValue: "",
          editValue: ""
        },
        pat_A_0002: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "229",
          clauseName: "プライミング補助間欠動作動作時間",
          unitName: "sec",
          min: 0.5,
          max: 9.9,
          initValue: "",
          editValue: ""
        },
        pat_A_0001: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "230",
          clauseName: "プライミング補助間欠動作停止時間",
          unitName: "sec",
          min: 0.5,
          max: 9.9,
          initValue: "",
          editValue: ""
        },
        pat_A_0019: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "232",
          clauseName: "自動プライミング落差時間",
          unitName: "sec",
          min: 0,
          max: 999,
          initValue: "",
          editValue: ""
        },
        pat_A_0015: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "238",
          clauseName: "自動プライミング総量",
          unitName: "mL",
          min: 0,
          max: 2000,
          initValue: "",
          editValue: ""
        },
        pat_A_0012: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "231",
          clauseName: "自動プライミング開始時間",
          unitName: "min",
          min: 0,
          max: 1439,
          initValue: "",
          editValue: ""
        },
        pat_A_0016: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "233",
          clauseName: "自動プライミング送液液量",
          unitName: "mL",
          min: 0,
          max: 999,
          initValue: "",
          editValue: ""
        },
        pat_A_0017: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "234",
          clauseName: "自動プライミング送液流速1回目",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_A_0018: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "235",
          clauseName: "自動プライミング送液流速2回目以降",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_A_0014: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "236",
          clauseName: "自動プライミング循環流速",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_A_0013: {
          screenKey: "pri",
          key1: "pat",
          key2: "A",
          key3: "237",
          clauseName: "自動プライミング循環時間",
          unitName: "sec",
          min: 0,
          max: 999,
          initValue: "",
          editValue: ""
        },
        dev_A_0370: {
          screenKey: "pri",
          key1: "dev",
          key2: "A",
          key3: "370",
          clauseName: "自動回収　使用液量",
          unitName: "mL",
          min: 10,
          max: 999,
          initValue: "",
          editValue: ""
        },
        dev_A_0371: {
          screenKey: "pri",
          key1: "dev",
          key2: "A",
          key3: "371",
          clauseName: "自動回収　流速",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0372: {
          screenKey: "pri",
          key1: "dev",
          key2: "A",
          key3: "372",
          clauseName: "自動回収　血液判別器による終了選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        pat_B_0031: {
          screenKey: "pri",
          key1: "pat",
          key2: "B",
          key3: "31",
          clauseName: "ダイアライザー気泡抜き時間",
          unitName: "min",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        pat_B_0051: {
          screenKey: "pri",
          key1: "pat",
          key2: "B",
          key3: "51",
          clauseName: "後補液　ダイアライザー気泡抜き時間",
          unitName: "min",
          min: 2,
          max: 10,
          initValue: "",
          editValue: ""
        },
        pat_B_0032: {
          screenKey: "pri",
          key1: "pat",
          key2: "B",
          key3: "32",
          clauseName: "動脈チャンバ液面作成時間",
          unitName: "sec",
          min: 90,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_B_0052: {
          screenKey: "pri",
          key1: "pat",
          key2: "B",
          key3: "52",
          clauseName: "後補液　動脈チャンバ液面作成時間",
          unitName: "sec",
          min: 60,
          max: 120,
          initValue: "",
          editValue: ""
        },
        pat_B_0033: {
          screenKey: "pri",
          key1: "pat",
          key2: "B",
          key3: "33",
          clauseName: "循環洗浄時間",
          unitName: "min",
          min: 3,
          max: 10,
          initValue: "",
          editValue: ""
        },
        pat_B_0053: {
          screenKey: "pri",
          key1: "pat",
          key2: "B",
          key3: "53",
          clauseName: "後補液　循環洗浄時間",
          unitName: "min",
          min: 3,
          max: 10,
          initValue: "",
          editValue: ""
        },
        pat_B_0001: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "1",
          clauseName: "IPラインプライミング使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        pat_B_0005: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "5",
          clauseName: "プライミング時のBP速度",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_B_0007: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "7",
          clauseName: "送液最大時間",
          unitName: "sec",
          min: 15,
          max: 120,
          initValue: "",
          editValue: ""
        },
        pat_B_0008: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "8",
          clauseName: "回路洗浄送液量",
          unitName: "mL",
          min: 200,
          max: 1500,
          initValue: "",
          editValue: ""
        },
        pat_B_0009: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "9",
          clauseName: "気泡抜き実行回数",
          unitName: "回",
          min: 0,
          max: 5,
          initValue: "",
          editValue: ""
        },
        pat_B_0010: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "10",
          clauseName: "気泡抜き圧力上限",
          unitName: "mmHg",
          min: 50,
          max: 200,
          initValue: "",
          editValue: ""
        },
        pat_B_0011: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "11",
          clauseName: "除水ポンプ速度",
          unitName: "mmHg",
          min: 0.2,
          max: 0.2,
          initValue: "",
          editValue: ""
        },
        pat_B_0059: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "59",
          clauseName: "積層 プライミング時のBP速度",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        pat_B_0054: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "54",
          clauseName: "積層 送液最大時間",
          unitName: "sec",
          min: 15,
          max: 120,
          initValue: "",
          editValue: ""
        },
        pat_B_0055: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "55",
          clauseName: "積層 回路内洗浄送液量",
          unitName: "mL",
          min: 200,
          max: 1500,
          initValue: "",
          editValue: ""
        },
        pat_B_0056: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "56",
          clauseName: "積層 気泡抜き動作実行回数",
          unitName: "回",
          min: 0,
          max: 5,
          initValue: "",
          editValue: ""
        },
        pat_B_0057: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "57",
          clauseName: "積層 気泡抜き圧力上限",
          unitName: "mmHg",
          min: 50,
          max: 200,
          initValue: "",
          editValue: ""
        },
        pat_B_0058: {
          screenKey: "dfas",
          key1: "pat",
          key2: "B",
          key3: "58",
          clauseName: "積層 除水ポンプ速度",
          unitName: "L/h",
          min: 0.05,
          max: 0.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0339: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "339",
          clauseName: "脱血方法選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0333: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "333",
          clauseName: "脱血速度",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0331: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "331",
          clauseName: "同時脱血　脱血量",
          unitName: "mL",
          min: 30,
          max: 300,
          initValue: "",
          editValue: ""
        },
        dev_A_0334: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "334",
          clauseName: "片側脱血(除水なし) 脱血量",
          unitName: "mL",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0338: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "338",
          clauseName: "片側脱血（除水あり）　脱血量",
          unitName: "mL",
          min: 0,
          max: 150,
          initValue: "",
          editValue: ""
        },
        dev_A_0332: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "332",
          clauseName: "片側脱血への切替え透析液圧",
          unitName: "mmHg",
          min: -250,
          max: -50,
          initValue: "",
          editValue: ""
        },
        dev_B_0036: {
          screenKey: "dfas",
          key1: "dev",
          key2: "B",
          key3: "36",
          clauseName: "治療開始時血流量使用有無",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0373: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "373",
          clauseName: "静脈側返血速度",
          unitName: "mL/min",
          min: 0,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0374: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "374",
          clauseName: "静脈側最大返血量",
          unitName: "mL",
          min: 50,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0377: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "377",
          clauseName: "静脈側返血　血液判別器使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0270: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "270",
          clauseName: "D-FAS 返血 動脈側返血使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0376: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "376",
          clauseName: "動脈側最大返血量",
          unitName: "mL",
          min: 10,
          max: 100,
          initValue: "",
          editValue: ""
        },
        dev_A_0378: {
          screenKey: "dfas",
          key1: "dev",
          key2: "A",
          key3: "378",
          clauseName: "動脈側返血　血液判別器使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0290: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "290",
          clauseName: "除水プログラム電源ＳＷ",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0311: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "311",
          clauseName: "除水プログラム最終位置",
          unitName: "",
          min: 1,
          max: 10,
          initValue: "",
          editValue: ""
        },
        dev_A_0312: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "312",
          clauseName: "除水プログラムコース",
          unitName: "",
          min: 0.0,
          max: 2.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0291: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "291",
          clauseName: "治療モード１",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0292: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "292",
          clauseName: "治療モード２",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0293: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "293",
          clauseName: "治療モード３",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0294: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "294",
          clauseName: "治療モード４",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0295: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "295",
          clauseName: "治療モード５",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0296: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "296",
          clauseName: "治療モード６",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0297: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "297",
          clauseName: "治療モード７",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0298: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "298",
          clauseName: "治療モード８",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0299: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "299",
          clauseName: "治療モード９",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0300: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "300",
          clauseName: "治療モード１０",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0000: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "0",
          clauseName: "除水プログラム工程1の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0001: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "1",
          clauseName: "除水プログラム工程2の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0002: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "2",
          clauseName: "除水プログラム工程3の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0003: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "3",
          clauseName: "除水プログラム工程4の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0004: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "4",
          clauseName: "除水プログラム工程5の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0005: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "5",
          clauseName: "除水プログラム工程6の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0006: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "6",
          clauseName: "除水プログラム工程7の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0007: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "7",
          clauseName: "除水プログラム工程8の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0008: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "8",
          clauseName: "除水プログラム工程9の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_B_0009: {
          screenKey: "ufr",
          key1: "dev",
          key2: "B",
          key3: "9",
          clauseName: "除水プログラム工程10の指数",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0301: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "301",
          clauseName: "除水プログラム指数１",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0302: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "302",
          clauseName: "除水プログラム指数２",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0303: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "303",
          clauseName: "除水プログラム指数３",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0304: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "304",
          clauseName: "除水プログラム指数４",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0305: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "305",
          clauseName: "除水プログラム指数５",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0306: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "306",
          clauseName: "除水プログラム指数６",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0307: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "307",
          clauseName: "除水プログラム指数７",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0308: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "308",
          clauseName: "除水プログラム指数８",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0309: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "309",
          clauseName: "除水プログラム指数９",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0310: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "310",
          clauseName: "除水プログラム指数１０",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0313: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "313",
          clauseName: "除水プログラム開始数値",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0314: {
          screenKey: "ufr",
          key1: "dev",
          key2: "A",
          key3: "314",
          clauseName: "除水プログラム終了数値",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0315: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "315",
          clauseName: "Ｎａ注入プログラム電源ＳＷ",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0326: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "326",
          clauseName: "Ｎａ注入プログラム切替時間",
          unitName: "分",
          min: 1,
          max: 99,
          initValue: "",
          editValue: ""
        },
        dev_A_0328: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "328",
          clauseName: "Ｎａ注入プログラムコース",
          unitName: "",
          min: 0.0,
          max: 2.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0327: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "327",
          clauseName: "Ｎａ注入プログラム　除水プロとの連動選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0316: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "316",
          clauseName: "Ｎａ注入プログラム設定１",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0317: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "317",
          clauseName: "Ｎａ注入プログラム設定２",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0318: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "318",
          clauseName: "Ｎａ注入プログラム設定３",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0319: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "319",
          clauseName: "Ｎａ注入プログラム設定４",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0320: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "320",
          clauseName: "Ｎａ注入プログラム設定５",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0321: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "321",
          clauseName: "Ｎａ注入プログラム設定６",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0322: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "322",
          clauseName: "Ｎａ注入プログラム設定７",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0323: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "323",
          clauseName: "Ｎａ注入プログラム設定８",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0324: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "324",
          clauseName: "Ｎａ注入プログラム設定９",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0325: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "325",
          clauseName: "Ｎａ注入プログラム設定１０",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0329: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "329",
          clauseName: "Ｎａ注入プログラム開始数値",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0330: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "330",
          clauseName: "Ｎａ注入プログラム終了数値",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0184: {
          screenKey: "na",
          key1: "dev",
          key2: "A",
          key3: "184",
          clauseName: "Ｎａ注入濃度操作範囲上限",
          unitName: "mEq/L",
          min: 0,
          max: 50,
          initValue: "",
          editValue: ""
        },
        dev_A_0340: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "340",
          clauseName: "濃度プログラム電源ＳＷ",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0368: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "368",
          clauseName: "濃度プログラム　除水プロとの連動選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0367: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "367",
          clauseName: "濃度プログラム切替時間",
          unitName: "分",
          min: 1,
          max: 99,
          initValue: "",
          editValue: ""
        },
        dev_A_0361: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "361",
          clauseName: "透析液濃度プログラムステップ切替無し　コース",
          unitName: "",
          min: 0.0,
          max: 2.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0020: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "20",
          clauseName: "A液濃度プログラム工程1のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0021: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "21",
          clauseName: "A液濃度プログラム工程2のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0022: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "22",
          clauseName: "A液濃度プログラム工程3のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0023: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "23",
          clauseName: "A液濃度プログラム工程4のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0024: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "24",
          clauseName: "A液濃度プログラム工程5のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0025: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "25",
          clauseName: "A液濃度プログラム工程6のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0026: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "26",
          clauseName: "A液濃度プログラム工程7のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0027: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "27",
          clauseName: "A液濃度プログラム工程8のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0028: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "28",
          clauseName: "A液濃度プログラム工程9のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0029: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "29",
          clauseName: "A液濃度プログラム工程10のA液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_A_0341: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "341",
          clauseName: "透析液濃度プログラム設定１",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0342: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "342",
          clauseName: "透析液濃度プログラム設定２",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0343: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "343",
          clauseName: "透析液濃度プログラム設定３",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0344: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "344",
          clauseName: "透析液濃度プログラム設定４",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0345: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "345",
          clauseName: "透析液濃度プログラム設定５",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0346: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "346",
          clauseName: "透析液濃度プログラム設定６",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0347: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "347",
          clauseName: "透析液濃度プログラム設定７",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0348: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "348",
          clauseName: "透析液濃度プログラム設定８",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0349: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "349",
          clauseName: "透析液濃度プログラム設定９",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0350: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "350",
          clauseName: "透析液濃度プログラム設定１０",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0362: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "362",
          clauseName: "透析液濃度プログラム開始数値",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0363: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "363",
          clauseName: "透析液濃度プログラム終了数値",
          unitName: "mS/cm",
          min: 12.5,
          max: 15.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0364: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "364",
          clauseName: "Ｂ液濃度プログラムステップ切替無し　コース",
          unitName: "",
          min: 0.0,
          max: 2.0,
          initValue: "",
          editValue: ""
        },
        dev_B_0010: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "10",
          clauseName: "B液濃度プログラム工程1のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0011: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "11",
          clauseName: "B液濃度プログラム工程2のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0012: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "12",
          clauseName: "B液濃度プログラム工程3のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0013: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "13",
          clauseName: "B液濃度プログラム工程4のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0014: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "14",
          clauseName: "B液濃度プログラム工程5のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0015: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "15",
          clauseName: "B液濃度プログラム工程6のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0016: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "16",
          clauseName: "B液濃度プログラム工程7のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0017: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "17",
          clauseName: "B液濃度プログラム工程8のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0018: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "18",
          clauseName: "B液濃度プログラム工程9のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_B_0019: {
          screenKey: "dc",
          key1: "dev",
          key2: "B",
          key3: "19",
          clauseName: "B液濃度プログラム工程10のB液濃度",
          unitName: "%",
          min: 0,
          max: 30,
          initValue: "",
          editValue: ""
        },
        dev_A_0351: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "351",
          clauseName: "Ｂ液濃度プログラム設定１",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0352: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "352",
          clauseName: "Ｂ液濃度プログラム設定２",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0353: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "353",
          clauseName: "Ｂ液濃度プログラム設定３",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0354: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "354",
          clauseName: "Ｂ液濃度プログラム設定４",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0355: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "355",
          clauseName: "Ｂ液濃度プログラム設定５",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0356: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "356",
          clauseName: "Ｂ液濃度プログラム設定６",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0357: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "357",
          clauseName: "Ｂ液濃度プログラム設定７",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0358: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "358",
          clauseName: "Ｂ液濃度プログラム設定８",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0359: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "359",
          clauseName: "Ｂ液濃度プログラム設定９",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0360: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "360",
          clauseName: "Ｂ液濃度プログラム設定１０",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0365: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "365",
          clauseName: "Ｂ液濃度プログラム開始数値",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0366: {
          screenKey: "dc",
          key1: "dev",
          key2: "A",
          key3: "366",
          clauseName: "Ｂ液濃度プログラム終了数値",
          unitName: "mS/cm",
          min: 1.5,
          max: 7.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0016: {
          screenKey: "ecum",
          key1: "dev",
          key2: "A",
          key3: "16",
          clauseName: "ＥＣＵＭ選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0017: {
          screenKey: "ecum",
          key1: "dev",
          key2: "A",
          key3: "17",
          clauseName: "ＥＣＵＭ量",
          unitName: "L",
          min: 0.0,
          max: 31.93,
          initValue: "",
          editValue: ""
        },
        dev_A_0018: {
          screenKey: "ecum",
          key1: "dev",
          key2: "A",
          key3: "18",
          clauseName: "ＥＣＵＭ時間",
          unitName: "分",
          min: 0,
          max: 479,
          initValue: "",
          editValue: ""
        },
        dev_A_0019: {
          screenKey: "ecum",
          key1: "dev",
          key2: "A",
          key3: "19",
          clauseName: "ＥＣＵＭ時間カウント選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0252: {
          screenKey: "cpro",
          key1: "dev",
          key2: "A",
          key3: "252",
          clauseName: "Ｂ液濃度プログラム自動設定警報幅上限",
          unitName: "%",
          min: 0.0,
          max: 9.9,
          initValue: "",
          editValue: ""
        },
        dev_A_0253: {
          screenKey: "cpro",
          key1: "dev",
          key2: "A",
          key3: "253",
          clauseName: "Ｂ液濃度プログラム自動設定警報幅下限",
          unitName: "%",
          min: -9.9,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0250: {
          screenKey: "cpro",
          key1: "dev",
          key2: "A",
          key3: "250",
          clauseName: "透析液濃度プログラム自動設定警報幅上限",
          unitName: "%",
          min: 0.0,
          max: 9.9,
          initValue: "",
          editValue: ""
        },
        dev_A_0251: {
          screenKey: "cpro",
          key1: "dev",
          key2: "A",
          key3: "251",
          clauseName: "透析液濃度プログラム自動設定警報幅下限",
          unitName: "%",
          min: -9.9,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0430: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "430",
          clauseName: "QBプログラム電源",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0429: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "429",
          clauseName: "QB、QDプログラム最大ステップ数",
          unitName: "",
          min: 2,
          max: 10,
          initValue: "",
          editValue: ""
        },
        dev_A_0400: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "400",
          clauseName: "QBプログラム血流量1",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0401: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "401",
          clauseName: "QBプログラム血流量2",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0402: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "402",
          clauseName: "QBプログラム血流量3",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0403: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "403",
          clauseName: "QBプログラム血流量4",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0404: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "404",
          clauseName: "QBプログラム血流量5",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0405: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "405",
          clauseName: "QBプログラム血流量6",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0406: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "406",
          clauseName: "QBプログラム血流量7",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0407: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "407",
          clauseName: "QBプログラム血流量8",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0408: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "408",
          clauseName: "QBプログラム血流量9",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0409: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "409",
          clauseName: "QBプログラム血流量10",
          unitName: "mL/min",
          min: 40,
          max: 600,
          initValue: "",
          editValue: ""
        },
        dev_A_0431: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "431",
          clauseName: "QDプログラム電源",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0410: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "410",
          clauseName: "QDプログラム透析液流量1",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0411: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "411",
          clauseName: "QDプログラム透析液流量2",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0412: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "412",
          clauseName: "QDプログラム透析液流量3",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0413: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "413",
          clauseName: "QDプログラム透析液流量4",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0414: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "414",
          clauseName: "QDプログラム透析液流量5",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0415: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "415",
          clauseName: "QDプログラム透析液流量6",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0416: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "416",
          clauseName: "QDプログラム透析液流量7",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0417: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "417",
          clauseName: "QDプログラム透析液流量8",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0418: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "418",
          clauseName: "QDプログラム透析液流量9",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0419: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "419",
          clauseName: "QDプログラム透析液流量10",
          unitName: "mL/min",
          min: 100,
          max: 700,
          initValue: "",
          editValue: ""
        },
        dev_A_0420: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "420",
          clauseName: "QB、QDプログラム切替時間1",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0421: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "421",
          clauseName: "QB、QDプログラム切替時間2",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0422: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "422",
          clauseName: "QB、QDプログラム切替時間3",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0423: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "423",
          clauseName: "QB、QDプログラム切替時間4",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0424: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "424",
          clauseName: "QB、QDプログラム切替時間5",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0425: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "425",
          clauseName: "QB、QDプログラム切替時間6",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0426: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "426",
          clauseName: "QB、QDプログラム切替時間7",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0427: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "427",
          clauseName: "QB、QDプログラム切替時間8",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0428: {
          screenKey: "qbqd",
          key1: "dev",
          key2: "A",
          key3: "428",
          clauseName: "QB、QDプログラム切替時間9",
          unitName: "分",
          min: 1,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0201: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "201",
          clauseName: "I-HDF 補液速度",
          unitName: "mL/min",
          min: 40,
          max: 300,
          initValue: "",
          editValue: ""
        },
        dev_A_0203: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "203",
          clauseName: "I-HDF 補液開始時間",
          unitName: "分",
          min: 0,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0200: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "200",
          clauseName: "I-HDF 補液量設定",
          unitName: "mL",
          min: 10,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0204: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "204",
          clauseName: "I-HDF 除水再開時間",
          unitName: "分",
          min: 0,
          max: 10,
          initValue: "",
          editValue: ""
        },
        dev_A_0202: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "202",
          clauseName: "I-HDF 補液周期",
          unitName: "分",
          min: 15,
          max: 60,
          initValue: "",
          editValue: ""
        },
        dev_A_0205: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "205",
          clauseName: "I-HDF 総補液量上限",
          unitName: "L",
          min: 1.0,
          max: 2.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0432: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "432",
          clauseName: "I-HDFプログラム使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0433: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "433",
          clauseName: "予定補液回数",
          unitName: "",
          min: 1,
          max: 16,
          initValue: "",
          editValue: ""
        },
        dev_A_0434: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "434",
          clauseName: "補液バランス制限",
          unitName: "mL",
          min: 0,
          max: 400,
          initValue: "",
          editValue: ""
        },
        dev_A_0435: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "435",
          clauseName: "補液量01",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0436: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "436",
          clauseName: "補液量02",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0437: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "437",
          clauseName: "補液量03",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0438: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "438",
          clauseName: "補液量04",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0439: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "439",
          clauseName: "補液量05",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0440: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "440",
          clauseName: "補液量06",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0441: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "441",
          clauseName: "補液量07",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0442: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "442",
          clauseName: "補液量08",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0443: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "443",
          clauseName: "補液量09",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0444: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "444",
          clauseName: "補液量10",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0445: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "445",
          clauseName: "補液量11",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0446: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "446",
          clauseName: "補液量12",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0447: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "447",
          clauseName: "補液量13",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0448: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "448",
          clauseName: "補液量14",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0449: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "449",
          clauseName: "補液量15",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0450: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "450",
          clauseName: "補液量16",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0451: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "451",
          clauseName: "回収量01",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0452: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "452",
          clauseName: "回収量02",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0453: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "453",
          clauseName: "回収量03",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0454: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "454",
          clauseName: "回収量04",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0455: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "455",
          clauseName: "回収量05",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0456: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "456",
          clauseName: "回収量06",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0457: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "457",
          clauseName: "回収量07",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0458: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "458",
          clauseName: "回収量08",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0459: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "459",
          clauseName: "回収量09",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0460: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "460",
          clauseName: "回収量10",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0461: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "461",
          clauseName: "回収量11",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0462: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "462",
          clauseName: "回収量12",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0463: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "463",
          clauseName: "回収量13",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0464: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "464",
          clauseName: "回収量14",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0465: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "465",
          clauseName: "回収量15",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0466: {
          screenKey: "ihdf",
          key1: "dev",
          key2: "A",
          key3: "466",
          clauseName: "回収量16",
          unitName: "mL",
          min: 0,
          max: 500,
          initValue: "",
          editValue: ""
        },
        dev_A_0196: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "196",
          clauseName: "BV-UFC使用選択",
          unitName: "",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0197: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "197",
          clauseName: "UFC期間除水速度上限",
          unitName: "L/h",
          min: 0,
          max: 4.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0198: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "198",
          clauseName: "UFC期間除水速度下限",
          unitName: "L/h",
          min: 0,
          max: 4.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0199: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "199",
          clauseName: "開始期間 時間",
          unitName: "分",
          min: 5,
          max: 60,
          initValue: "",
          editValue: ""
        },
        dev_A_0206: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "206",
          clauseName: "開始期間 除水速度倍率",
          unitName: "",
          min: 0.0,
          max: 2.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0207: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "207",
          clauseName: "固定倍率除水期間 時間",
          unitName: "分",
          min: 0,
          max: 240,
          initValue: "",
          editValue: ""
        },
        dev_A_0208: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "208",
          clauseName: "固定倍率除水期間 除水速度倍率",
          unitName: "",
          min: 0.0,
          max: 2.5,
          initValue: "",
          editValue: ""
        },
        dev_A_0209: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "209",
          clauseName: "固定倍率除水終了条件　最高血圧",
          unitName: "mmHg",
          min: 0,
          max: 250,
          initValue: "",
          editValue: ""
        },
        dev_A_0210: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "210",
          clauseName: "固定倍率除水終了条件　脈拍",
          unitName: "bpm",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0248: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "248",
          clauseName: "固定倍率除水終了条件　ΔBV",
          unitName: "%",
          min: -30.0,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0249: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "249",
          clauseName: "終了前期間 時間",
          unitName: "分",
          min: 0,
          max: 180,
          initValue: "",
          editValue: ""
        },
        dev_A_0271: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "271",
          clauseName: "開始時ΔBV基準値 ",
          unitName: "%",
          min: -10.0,
          max: 10.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0272: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "272",
          clauseName: "ΔBV基準線　指数1",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0273: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "273",
          clauseName: "ΔBV基準線　指数2",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0274: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "274",
          clauseName: "ΔBV基準線　指数3",
          unitName: "",
          min: 0,
          max: 200,
          initValue: "",
          editValue: ""
        },
        dev_A_0275: {
          screenKey: "bvufc",
          key1: "dev",
          key2: "A",
          key3: "275",
          clauseName: "終了時ΔBV基準値 ",
          unitName: "%",
          min: -30.0,
          max: 0.0,
          initValue: "",
          editValue: ""
        },
        dev_A_0282: {
          screenKey: "dia",
          key1: "dev",
          key2: "A",
          key3: "282",
          clauseName: "透析量プログラム使用選択",
          unitName: "K",
          min: "",
          max: "",
          initValue: "",
          editValue: ""
        },
        dev_A_0288: {
          screenKey: "dia",
          key1: "dev",
          key2: "A",
          key3: "288",
          clauseName: "目標Kt/V",
          unitName: "",
          min: 0.01,
          max: 3.0,
          initValue: "",
          editValue: ""
        }
      },
      exchangeCount: 0,
      timeData: ""
    };
  },

  methods: {
    /**
     * DBデータ取得
     * @param       table_flag  テーブル区分(0 -> システム, 1 -> 患者情報, 2 -> 治療情報)
     * @param       screen_key  画面キー
     * @return      getData     取得したデータ
     * @description 装置設定のカラムのみを返す
     * @summary
     *   画面キー(screen_key)を引数で渡すとそれ以降のJsonデータをを取得する
     *   選択しない場合はそれより1つ上の階層で取得する
     *   システム(mst_device_set_info_default),患者情報(pat_main)テーブルを参照する場合Objectを返す
     *   治療情報(ord_main)のテーブルをord_noがnullで参照された場合は配列で返す
     * @summary(変数  引数になるかも??)
     *   faclity_cd   施設コード(mst_device_set_info_default,pat_main,ord_mainで必須)
     *   pat_id       患者ID(pat_main,ord_mainで必須)
     *   ord_no       Ord番号(ord_mainで必須ではないが、なければ以下のデータが必要)
     *   start_date   治療開始日(ord_mainでord_noが無いとき必須)
     *   end_date     治療終了日(なくてもOK)
     *   week         曜日パターン(配列  なくてもOK)
     *   treat_method 治療予定パターン(配列  なくてもOK)
     *   kur_cd       クールコード(配列  なくてもOK)
     */
    async getDevideSetInfo(table_flag, screen_key) {
      let getData = {};
      const params = {};
      if (this.ordNo === "") {
        this.ordNo = null;
      }
      if (this.patId === "") {
        this.patId = null;
      }
      // テーブルフラグ
      params.table_flag = table_flag;
      // 画面キー
      params.screen_key = screen_key;
      // 患者ID
      params.pat_id = this.patId;
      // Ord番号
      params.ord_no = this.ordNo;
      // 施設コード
      params.facility_cd = this.facilityCd;
      // 治療開始日
      params.start_date = this.startDate;
      // 治療終了日
      params.end_date = this.endDate;
      // 曜日パターン
      params.week = changeJsonArray(this.week);
      // 治療方法コード
      params.treat_method = changeJsonArray(this.treatMethod);
      // クールコード
      params.kur_cd = changeJsonArray(this.kurCd);
      await ApiHelper.post("/deviceSetInfo/getDeviceData", params)
        .then(response => {
          if (this.table_flag === 2 && params.ord_no === null) {
            // TODO: 指示テーブルのデータ取得時でord_noの指定がない場合は配列で渡す
            getData = JSON.parse(response.data[0]);
          } else {
            if (params.screen_key === null || params.screen_key === "") {
              if (JSON.parse(response.data[0]).length !== 0) {
                getData = JSON.parse(
                  JSON.parse(response.data[0])[0].deviceInfo
                );
              }
            } else {
              if (JSON.parse(response.data[0]).length !== 0) {
                getData[params.screen_key] = JSON.parse(
                  JSON.parse(response.data[0])[0].deviceInfo
                );
              }
            }
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('DeviceSetInfoCore.vue', 'getDevideSetInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw error;
        });
      // TODO:取得データがない場合は、空のデータを渡す
      return getData;
    },

    // TODO:テーブルごとのdeviceSetInfo(screen_keyがnullの場合すべて取得)
    filterArray(screen_key) {
      let filteredArray = {};
      const baseData = deepCopy(this.deviceSetInfo);
      if (screen_key !== null) {
        for (const key in baseData) {
          if (baseData[key].screenKey === screen_key) {
            filteredArray[key] = baseData[key];
          }
        }
      } else {
        filteredArray = baseData;
      }
      return filteredArray;
    },

    // 一覧用データ取得
    // DBから取得したJSONデータと、deviceSetInfo定義データの突き合わせを行う
    async getData(table_flag, screen_key) {
      const dbData = await this.getDevideSetInfo(table_flag, screen_key);
      const deviceData = await this.filterArray(screen_key);
      for (const scKey in dbData) {
        if (dbData[scKey] !== null) {
          for (const deviceClassKey in dbData[scKey]) {
            for (const alphabetClassKey in dbData[scKey][deviceClassKey]) {
              for (const addressKey in dbData[scKey][deviceClassKey][
                alphabetClassKey
              ]) {
                for (const flontKey in deviceData) {
                  if (
                    deviceData[flontKey].screenKey === scKey &&
                    deviceData[flontKey].key1 === deviceClassKey &&
                    deviceData[flontKey].key2 === alphabetClassKey &&
                    deviceData[flontKey].key3 === addressKey
                  ) {
                    deviceData[flontKey].initValue =
                      dbData[scKey][deviceClassKey][alphabetClassKey][
                        addressKey
                      ];
                    deviceData[flontKey].editValue =
                      dbData[scKey][deviceClassKey][alphabetClassKey][
                        addressKey
                      ];
                  }
                }
              }
            }
          }
        }
      }
      return deviceData;
    },

    // データの整形
    shapingData(data, num, flag) {
      let jsonData = {};
      let columnName = "";
      let shapedData = {};
      jsonData = JSON.parse(data);
      if (num === 0) {
        columnName = "dev";
      } else {
        columnName = "pat";
      }
      if (columnName in jsonData) {
        shapedData = jsonData[columnName][flag];
      }
      return shapedData;
    },

    // データの更新処理
    createUpdateData(data, table_flag) {
      const updateData = {};
      let screen_key = "";
      let first_key = "";
      let second_key = "";
      let third_key = "";
      for (const key in data) {
        screen_key = data[key].screenKey;
        first_key = data[key].key1;
        second_key = data[key].key2;
        third_key = data[key].key3;
        if (data[key].initValue !== data[key].editValue) {
          this.changeCount++;
          if (screen_key in updateData) {
            if (first_key in updateData[screen_key]) {
              if (second_key in updateData[screen_key][first_key]) {
                updateData[screen_key][first_key][second_key][third_key] =
                  data[key].editValue;
              } else {
                updateData[screen_key][first_key][second_key] = {};
                updateData[screen_key][first_key][second_key][third_key] =
                  data[key].editValue;
              }
            } else {
              updateData[screen_key][first_key] = {};
              updateData[screen_key][first_key][second_key] = {};
              updateData[screen_key][first_key][second_key][third_key] =
                data[key].editValue;
            }
          } else {
            updateData[screen_key] = {};
            updateData[screen_key][first_key] = {};
            updateData[screen_key][first_key][second_key] = {};
            updateData[screen_key][first_key][second_key][third_key] =
              data[key].editValue;
          }
        }
      }
      return updateData;
    },

    // データバインド
    dataInlay(flag, ABflag, data) {
      let ObjectKey = "";
      let ObjectValue = "";
      let frontKey = "";
      let ABFlag = "";
      for (const key in data) {
        ObjectKey = key;
        ObjectValue = data[key];
        if (flag === 1) {
          for (const keyName in this.deviceSetInfo) {
            ABFlag = keyName.slice(0, -5);
            if (ABflag === ABFlag) {
              frontKey = this.deviceSetInfo[keyName].DBcode;
              if (frontKey === ObjectKey) {
                this.deviceSetInfo[keyName].initValue = ObjectValue;
                this.deviceSetInfo[keyName].editValue = this.deviceSetInfo[
                  keyName
                ].initValue;
              }
            }
          }
        } else {
          for (const keyName in this.nextPatientInfo) {
            ABFlag = keyName.slice(0, -5);
            if (ABflag === ABFlag) {
              frontKey = this.nextPatientInfo[keyName].DBcode;
              if (frontKey === ObjectKey) {
                this.nextPatientInfo[keyName].initValue = ObjectValue;
                this.nextPatientInfo[keyName].editValue = this.nextPatientInfo[
                  keyName
                ].initValue;
              }
            }
          }
        }
      }
    },

    // 変更データのチェック
    checkUpdateData(data, num) {
      let editedCheck = false;
      let dbName = "";
      if (num === 0 || num === 1) {
        editedCheck =
          this.deviceSetInfo[data].initValue !==
          this.deviceSetInfo[data].editValue;
        dbName = this.deviceSetInfo[data].DBcode;
      } else {
        editedCheck =
          this.nextPatientInfo[data].initValue !==
          this.nextPatientInfo[data].editValue;
        dbName = this.nextPatientInfo[data].DBcode;
      }
      if (editedCheck === true) {
        this.exchangeCount++;
        if (num === 0 || num === 1) {
          this.addData[num][dbName] = String(
            this.deviceSetInfo[data].editValue
          );
        } else {
          this.addData[num][dbName] = String(
            this.nextPatientInfo[data].editValue
          );
        }
      }
    },

    // 一括でJsonデータを更新する(Jsonデータ一部更新ではない)
    async updateBulkInfo(patId) {
      // 一時的にJsonデータを取得する
      const patInfo = await getPatById(this.patData).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('DeviceSetInfoCore.vue', 'updateBulkInfo', "患者取得失敗");
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        throw new Error(
          "[DeviceSetInfoCore.vue]getDeviceSettingData(): 患者取得失敗"
        );
      });
      const acquisitionData = JSON.parse(patInfo.pat_main.device_set_info);
      let keyName = "";
      let ABName = "";
      let code = "";
      for (const key in this.deviceSetInfo) {
        keyName = key;
        ABName = keyName.slice(0, -5);
        code = this.deviceSetInfo[keyName].DBcode;
        if (
          this.deviceSetInfo[keyName].intiData !==
          this.deviceSetInfo[keyName].editValue
        ) {
          if ("dev" in acquisitionData) {
            if (ABName in acquisitionData.dev) {
              acquisitionData.dev[ABName][code] = String(
                this.deviceSetInfo[keyName].editValue
              );
            } else {
              acquisitionData.dev[ABName] = {};
              acquisitionData.dev[ABName][code] = String(
                this.deviceSetInfo[keyName].editValue
              );
            }
          } else {
            acquisitionData.dev = {};
            acquisitionData.dev[ABName] = {};
            acquisitionData.dev[ABName][code] = String(
              this.deviceSetInfo[keyName].editValue
            );
          }
        }
      }
      for (const key in this.nextPatientInfo) {
        keyName = key;
        ABName = keyName.slice(0, -5);
        code = this.nextPatientInfo[keyName].DBcode;
        if (
          this.nextPatientInfo[keyName].intiData !==
          this.nextPatientInfo[keyName].editValue
        ) {
          if ("pat" in acquisitionData) {
            if (ABName in acquisitionData.pat) {
              acquisitionData.pat[ABName][code] = String(
                this.nextPatientInfo[keyName].editValue
              );
            } else {
              acquisitionData.pat[ABName] = {};
              acquisitionData.pat[ABName][code] = String(
                this.nextPatientInfo[keyName].editValue
              );
            }
          } else {
            acquisitionData.pat = {};
            acquisitionData.pat[ABName] = {};
            acquisitionData.pat[ABName][code] = String(
              this.nextPatientInfo[keyName].editValue
            );
          }
        }
      }
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = patId;
      // 更新するJsonデータ
      sendJson.update_data = JSON.stringify(acquisitionData);
      // データの送信
      ApiHelper.post("/patInfo/updateDeviceSetInfoAll", sendJson);
    },

    // 整数値チェック
    checkInterger(num) {
      // 整数チェック
      const pattern = /^[-]?\d*$/;
      if (pattern.test(num.editValue) === false && num.editValue < 0) {
        num.editValue = Math.floor(num.editValue);
        num.editValue = num.editValue + 1;
      } else {
        num.editValue = Math.floor(num.editValue);
      }
      this.MaxMinCheck(num);
    },

    // 上限・下限チェック
    MaxMinCheck(num) {
      //最小値・最大値チェック
      if (num.editValue > num.max) {
        num.editValue = num.max;
      } else if (num.min > num.editValue) {
        num.editValue = num.min;
      }
    },

    /**
     * 小数点チェック
     * 小数点第 num 桁まで有効 ***それ以下は切り捨て***
     */
    DecimalCheck(data, num) {
      data.editValue =
        Math.floor(data.editValue * Math.pow(10, num)) / Math.pow(10, num);
      this.MaxMinCheck(data);
    },

    // 時間データの変換(装置設定A_0018)
    changeTimeData(num) {
      let hour = "";
      let min = "";
      if (num === 1) {
        // editValue --> timeData
        hour = `0${Math.floor(
          Number(this.deviceSetInfo.A_0018.editValue) / 60
        )}`;
        min = String(Number(this.deviceSetInfo.A_0018.editValue) % 60);
        if (min.length === 1) {
          min = `0${min}`;
        }
        this.timeData = `${hour}:${min}`;
      } else {
        // timeData --> editValue
        hour = Number(this.timeData.slice(0, -3));
        min = Number(this.timeData.slice(3));
        this.deviceSetInfo.A_0018.editValue = hour * 60 + min;
      }
    }
  }
};
</script>
