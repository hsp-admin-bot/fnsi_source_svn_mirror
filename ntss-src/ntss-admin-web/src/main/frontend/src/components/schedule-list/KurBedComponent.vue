/** * ベッドコンポーネント*/
<template>
  <div
      v-if="agentEdgeFlag"
      :id="'id_bed' + propsId"
      :bedUsed="bedUsed"
      class="cls-bed2 show-bed-element"
      :style="'line-height:2.4em;text-align:left;visibility:' +
        visibilityBed +
        ';width:' +
        cellWidth +
        // ';height:' +
        // divHeight +
        // ';border-width:' +
        // divBorderWidth +
        // ';color: ' +
        // divColor +
        // ';background-color:' +
        // divBackgroundColor +
        ';'
    "
  >
    {{ propsName }}
  </div>
  <div
      v-else
      :id="'id_bed' + propsId"
      :bedUsed="bedUsed"
      class="cls-bed2 show-bed-element"
      :style="'line-height:2.4em;text-align:left;visibility:' + 
      visibilityBed + 
      // ';height:' +
      // divHeight +
      // ';border-width:' +
      // divBorderWidth +
      // ';color:' +
      // divColor +
      // ';background-color:' +
      // divBackgroundColor +
      ';'"
  >
    {{ propsName }}
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
//定義
import {
  DEF_KUR_WIDTH,
  BACKGROUND_COLUMN_PAST_DAY, } from "@/components/schedule-list/Definitions.js";
//日付扱い用
import moment from "moment";

//クールコードおよびベッドコードのみ登録時の値(数値)
const DEF_NOTASSIGNED = 0;

//undefined
const DEF_UNDEFINED = "undefined";

const DEF_COLOR_IN = "#A356A3"; //入院患者色
const DEF_COLOR_OUT = "black"; //外来患者色

const DEF_VIS_IN_USE = "visible"; //visibility 表示
const DEF_VIS_NOT_IN_USE = "hidden"; //visibility 非表示

const DEF_CELL_HEIGHT_IN_USE = "2.4em"; //35px(基本フォントサイズは1.5em(15px))
const DEF_CELL_HEIGHT_NOT_IN_USE = "0px";

//シャント位置定義 '0':両方、'1':左、'2':右、'3':なし、'-':不明
const DEF_SHUNT_BOTH = "0";
// const DEF_SHUNT_LEFT = "1";
// const DEF_SHUNT_RIGHT = "2";
const DEF_SHUNT_NONE = "3";
const DEF_SHUNT_UNKNOWN = "-";

//使用不可フラグ定義
const DEF_DISABLED = "1"; //使用不可
//const DEF_ENABLED = "0"; //使用可

//対応可否フラグ定義
const DEF_UNSUPPORTED = "0"; //未対応
const DEF_SUPPORTED = "1"; //対応

//治療モード(device_mode)定義
const DEF_DM_HD = "0"; //HD
const DEF_DM_ECUM = "1"; //ECUM
const DEF_DM_HDF = "2"; //HDF
const DEF_DM_HF = "3"; //HF
const DEF_DM_HD_HO = "4"; //HD+補液
const DEF_DM_ECUM_HO = "5"; //ECUM+補液
const DEF_DM_AFBF = "6"; //AFBF
const DEF_DM_OHDF = "7"; //OHDF
const DEF_DM_OHF = "8"; //OHF
const DEF_DM_PURIFICATION = "9"; //特殊浄化
const DEF_DM_IHDF = "10"; //I-HDF
const DEF_DM_UNKNOWN = "-1"; //不明

// mod FNSI 入院・同姓同名配布 start -- Sanjingye Sun 20201228
//表示条件設定:予定あり(半角*)
// const DEF_PLAN_STR = "*";
const DEF_PLAN_STR = "◆";
// mod FNSI 入院・同姓同名配布 end -- Sanjingye Sun 20201228

//表示条件設定:不一致(全角!)
const DEF_UNMATCH_STR = "！";

//背景テーマスタイル
const DEF_SETTING_STYLE_THEME = "var(--ntss-list-background-color)";

const DEF_AGENT_EDGE =
    window.navigator.userAgent.toLowerCase()?.indexOf("edge") > -1;

export default {
  props: {
    propsId: {
      type: String,
      required: false,
      default: ""
    },
    propsJson: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propsIsDisp: {
      type: Boolean,
      required: false,
      default: true
    },
    propsName: {
      type: String,
      required: false,
      default: ""
    },
    // propsTreatDate: {
    //   type: Object,
    //   required: false,
    //   default: () => ({})
    // }
  },
  data() {
    return {
      thisElem: null, //当コンポーネントのelemポインタ
      // bedUsed: false, //ベッド使用中フラグ
      // unmatchFlag: true, //不一致フラグ true:不一致あり
      // shuntFlag: true, //シャント方向一致フラグ true:一致
      // infectionFlag: true, //感染症一致フラグ true:一致
      // deviceModeFlag: true, //治療モード一致フラグ true:一致
      // visibilityBed: DEF_VIS_NOT_IN_USE, //表示フラグ デフォルト:display
      // myIndex: 0, //自分自身のIndex
      cellWidth: DEF_KUR_WIDTH, //セルの幅
      // bedAreaFlag: true, //確定エリアフラグ true:確定エリアにいる
      // dispName: "", //表示名
      // dispBedGroupFlag: true, //ベッドグループでの表示非表示のフラグ true:表示
      agentEdgeFlag: DEF_AGENT_EDGE,
      unPropsJsonWatch: null
    };
  },
  computed: {
    // divColor() {
    //   let fontcolor = "";
    //   if (this.propsJson != null) {
    //     //入外区分を見て文字色を変える
    //     fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : DEF_COLOR_OUT;
    //
    //     //治療状況で背景を変える
    //     const dialysisState = this.propsJson.dialysisState;
    //     switch (dialysisState) {
    //       case "-1": //未登録
    //         break;
    //       case "0": //条件送信前
    //         fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "black";
    //         break;
    //       case "1": //条件送信済み
    //       case "2": //条件送信確認済み
    //       case "3": //治療中
    //       case "4": //排液済み
    //       case "5": //後体重測定済み(実績未確定)
    //       case "6": //後体重確認済み(過去実績)
    //         fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "white";
    //         break;
    //       default:
    //         break;
    //     }
    //     // ダミー予定の場合は、優先でグレー背景に変更する
    //     if(this.propsJson.isDummy === "1") {
    //       fontcolor = "white";
    //     }
    //   }
    //   return fontcolor;
    // },
    // divBackgroundColor() {
    //   let backgroundColor = DEF_SETTING_STYLE_THEME;
    //   const currentDate = moment(new Date()).format("YYYYMMDD");
    //   if (this.propsJson != null && ("title" in this.propsJson)) {
    //     // 日付取得
    //     const selectedDate = this.propsJson.treatDate;
    //     if (this.propsName !== "") {
    //       //治療状況で背景を変える
    //       const dialysisState = this.propsJson.dialysisState;
    //       switch (dialysisState) {
    //         case "-1": //未登録
    //           backgroundColor = "#d3d3d3";
    //           break;
    //         case "0": //条件送信前
    //           backgroundColor = "white";
    //           break;
    //         case "1": //条件送信済み
    //           backgroundColor = "#42CB92";
    //           break;
    //         case "2": //条件送信確認済み
    //           backgroundColor = "#42CB92";
    //           break;
    //         case "3": //治療中
    //           backgroundColor = "#2CA06F";
    //           break;
    //         case "4": //排液済み
    //           backgroundColor = "#557769";
    //           break;
    //         case "5": //後体重測定済み(実績未確定)
    //           backgroundColor = "#557769";
    //           break;
    //         case "6": //後体重確認済み(過去実績)
    //           backgroundColor = "#808080";
    //           break;
    //         default:
    //           backgroundColor = "white";
    //       }
    //       // ダミー予定の場合は、優先でグレー背景に変更する
    //       if(this.propsJson.isDummy === "1") {
    //         backgroundColor = "#D3D3D3";
    //       }
    //     } else {
    //       if (selectedDate < currentDate) {
    //         backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
    //       } else {
    //         backgroundColor = DEF_SETTING_STYLE_THEME;
    //       }
    //     }
    //   } 
    //   // else {
    //   //   const bedNotYetDate = this.propsTreatDate.date;
    //   //   console.log("!bedNotYetDate : ", bedNotYetDate, this.propsId)
    //   //   if (bedNotYetDate < currentDate) {
    //   //     backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
    //   //   } else {
    //   //     backgroundColor = DEF_SETTING_STYLE_THEME;
    //   //   }
    //   // }
    //   return backgroundColor;
    // },
    // divHeight() {
    //   // const myIndex = this.propsId.split("-")[2];
    //   // const bedDispState = this.getBedDispState(myIndex - 1);
    //   // if (bedDispState && this.propsIsDisp) {
    //   if (this.visibilityBed == 'visible') {
    //     return DEF_CELL_HEIGHT_IN_USE;
    //   } else {
    //     return DEF_CELL_HEIGHT_NOT_IN_USE;
    //   }
    // },
    // divBorderWidth() {
    //   // const myIndex = this.propsId.split("-")[2];
    //   // const bedDispState = this.getBedDispState(myIndex - 1);
    //   // if (bedDispState && this.propsIsDisp) {
    //   if (this.visibilityBed == 'visible') {
    //     return "1px";
    //   } else {
    //     return "0px";
    //   }
    // },
    bedUsed() {
      let bedUsedFlag = false;
      if (this.propsJson != null && this.propsName !== "") {
        bedUsedFlag = true;
      }

      return bedUsedFlag;
    },
    visibilityBed() {
      let dispStatus = DEF_VIS_IN_USE;
      const myIndex = this.propsId.split("-")[2];
      const bedDispState = this.getBedDispState(myIndex - 1);
      if (bedDispState && this.propsIsDisp) {
        dispStatus = DEF_VIS_IN_USE;

        if (this.thisElem) {
          this.thisElem.style.height = DEF_CELL_HEIGHT_IN_USE;
          this.thisElem.style.lineHeight = DEF_CELL_HEIGHT_IN_USE;
          this.thisElem.style.borderWidth = "1px";
        }
      } else {
        dispStatus = DEF_VIS_NOT_IN_USE;

        if (this.thisElem) {
          this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
          this.thisElem.style.borderWidth = "0px";
        }
      }

      return dispStatus;
    },
    // dispName() {
    //   return this.propsJson != null ?  this.propsJson.dispName : "";
    // // },
    // divId() {
    //   return `id_bed${this.propsId}`;
    // },
    ...mapGetters("schedule-list", [
      "nameSetting", //表示条件設定:姓のみ表示フラグ取得用
      "unmatchSetting", //表示条件設定:不一致表示フラグ取得用
      "planSetting", //表示条件設定:予定あり表示フラグ取得用
      "getBedUnmatchCheckInfo", //不一致情報取得用
      "getBedDispState", //ベッドの表示フラグ取得(引数index:0基底)  true:表示
      "getDayDispState", //日付の表示フラグ取得(引数index:0基底)  true:表示
      "getHolidayDispStateFlag", //休日表示フラグ取得(引数なし)  true:表示
      "getBedName", //ベッド名の取得
      "getOtherSchedule" //その他の予定データリスト
    ])
  },
  watch: {},
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    this.unPropsJsonWatch && this.unPropsJsonWatch();
  },
  mounted() {
    //自分自身のIDの取得
    this.thisElem = document.getElementById('id_bed' + this.propsId);

    this.unPropsJsonWatch = this.$watch('propsJson', (newVal, oldVal) => {
      this.resetDisp();
    });

    if (typeof this.propsJson !== DEF_UNDEFINED) {
      //設定があった場合、自分自身の表示設定処理をおこなう
      this.resetDisp();
    }
  },
  methods: {
    ...mapActions("schedule-list", [
      "setHeaderInfo" //ヘッダ表示情報をセットする(ヘッダー部への受け渡し用)
    ]),
    /**
     * ベッドセルの表示処理
     */
    resetDisp() {
      // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
      // this.thisElem.style.height = DEF_CELL_HEIGHT_IN_USE;
      // this.thisElem.style.lineHeight = DEF_CELL_HEIGHT_IN_USE;
      if (this.thisElem) {
        this.thisElem.style.height = DEF_CELL_HEIGHT_IN_USE;
        this.thisElem.style.lineHeight = DEF_CELL_HEIGHT_IN_USE;
      }
      // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end

      // 現在日付を取得する
      const currentDate = moment(new Date()).format("YYYYMMDD");

      if (this.propsJson === null || !("title" in this.propsJson)) {
        //propsJsonの値設定がない、または、titleプロパティが無い時
        // 過去日の背景色設定
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
        // if (bedNotYetDate < currentDate) {
        //     this.thisElem.style.backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
        // } else {
        //     this.thisElem.style.backgroundColor = DEF_SETTING_STYLE_THEME;
        // }
        if (this.thisElem) {
          this.thisElem.style.backgroundColor = DEF_SETTING_STYLE_THEME;
        }
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
        return;
      }

      // 日付取得
      const selectedDate = this.propsJson.treatDate;

      if (this.propsJson.title === "") {
        //titleプロパティの値が空文字の場合は、タイトル列のセルではない

        let replaceStr = "id_bed";
        //ベッドindex
        const myIndex = this.propsId.replace(replaceStr, "").split("-")[2];
        //確認対象のIndexの計算(呼び出しのパラメータは0基底)
        const targetIndex = Number(myIndex) - 1;
        if (!this.getBedDispState(targetIndex)) {
          //非表示かつ確定エリアだったので、隠します
          // this.visibilityBed = DEF_VIS_NOT_IN_USE;
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
          // this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
          // this.thisElem.style.borderWidth = 0;
          if (this.thisElem) {
            this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
            this.thisElem.style.borderWidth = 0;
          }
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
        }

        //名前があるところは入外区分で文字色、治療状況で背景色を変えます
        if (this.propsName !== "") {
          //入外区分を見て文字色を変える
          let fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : DEF_COLOR_OUT;

          //治療状況で背景を変える
          const dialysisState = this.propsJson.dialysisState;
          let backColor = DEF_SETTING_STYLE_THEME;
          switch (dialysisState) {
            case "-1": //未登録
              backColor = "#d3d3d3";
              break;
            case "0": //条件送信前
              // backColor = "#d3d3d3";
              fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "black";
              backColor = "white";
              break;
            case "1": //条件送信済み
              fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "white";
              backColor = "#42CB92";
              break;
            case "2": //条件送信確認済み
              fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "white";
              backColor = "#42CB92";
              break;
            case "3": //治療中
              fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "white";
              backColor = "#2CA06F";
              break;
            case "4": //排液済み
              fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "white";
              backColor = "#557769";
              break;
            case "5": //後体重測定済み(実績未確定)
              fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "white";
              backColor = "#557769";
              break;
            case "6": //後体重確認済み(過去実績)
              // backColor = "#003e00";
              fontcolor = this.propsJson.inOutClass === 1 ? DEF_COLOR_IN : "white";
              backColor = "#808080";
              break;
            default:
              backColor = "white";
          }
          // ダミー予定の場合は、優先でグレー背景に変更する
          if(this.propsJson.isDummy === "1") {
            fontcolor = "white";
            backColor = "#D3D3D3";
          }
          //文字色を設定
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
          // this.thisElem.style.color = fontcolor;
          if (this.thisElem) {
            this.thisElem.style.color = fontcolor;
          }
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end

          if (selectedDate < currentDate) {
            //過去日の背景色設定
            // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
            // this.thisElem.style.backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
            if (this.thisElem) {
              this.thisElem.style.backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
            }
            // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
          }
          // 背景色設定
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
          // this.thisElem.style.backgroundColor = backColor;
          if (this.thisElem) {
            this.thisElem.style.backgroundColor = backColor;
          }
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
        } else {

          if (selectedDate < currentDate) {
            //過去日の背景色設定
            // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
            // this.thisElem.style.backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
            if (this.thisElem) {
              this.thisElem.style.backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
            }
            // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
          } else {
            //背景色にテーマ用の値を設定
            // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
            // this.thisElem.style.backgroundColor = DEF_SETTING_STYLE_THEME;
            if (this.thisElem) {
              this.thisElem.style.backgroundColor = DEF_SETTING_STYLE_THEME;
            }
            // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
          }
        }
      }
    },
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.cls-bed2 {
  background: var(--ntss-list-background-color);
  border: 1px solid var(--ntss-list-border-color);
  color: black;
  box-sizing: border-box;
  width: 100%;
  vertical-align: bottom;
  text-align: center;
  word-break: break-all;
  text-overflow: ellipsis;
  overflow: hidden;
  white-space: nowrap;
}

.show-bed-element {
  border-width: 1px;
  border-top: 0;
  border-left: 0
}

.hide-bed-element {
  border: none;
}
</style>
