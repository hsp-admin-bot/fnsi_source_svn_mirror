/** * ベッドコンポーネント*/
<template>
  <div
    v-if="agentEdgeFlag"
    :id="divId"
    :bedUsed="bedUsed"
    class="cls-bed2"
    :class="propsParentWidth === 0 ? 'hide-bed-element': 'show-bed-element'"
    :style="
      'text-align:left;visibility:' +
        visibilityBed +
        ';width:' +
        cellWidth +
        ';'
    "
  >
    {{ dispName }}
  </div>
  <div
    v-else
    :id="divId"
    :bedUsed="bedUsed"
    class="cls-bed2"
    :class="propsParentWidth === 0 ? 'hide-bed-element': 'show-bed-element'"
    :style="'text-align:left;visibility:' + visibilityBed + ';'"
  >
    {{ dispName }}
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

//シャント位置定義 '0':両方、'1':左、'2':右、'3':なし、'-':不明
const DEF_SHUNT_BOTH = "0";
// const DEF_SHUNT_LEFT = "1";
// const DEF_SHUNT_RIGHT = "2";
const DEF_SHUNT_NONE = "3";
const DEF_SHUNT_UNKNOWN = "-";

//使用不可フラグ定義
const DEF_DISABLED = "1"; //使用不可
//const DEF_ENABLED = "0"; //使用可

//クールコードおよびベッドコードのみ登録時の値(数値)
const DEF_NOTASSIGNED = 0;

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

//undefined
const DEF_UNDEFINED = "undefined";

// mod FNSI 入院・同姓同名配布 start -- Sanjingye Sun 20201228
//表示条件設定:予定あり(半角*)
// const DEF_PLAN_STR = "*";
const DEF_PLAN_STR = "◆";
// mod FNSI 入院・同姓同名配布 end -- Sanjingye Sun 20201228

//表示条件設定:不一致(全角!)
const DEF_UNMATCH_STR = "！";

const DEF_COLOR_IN = "#A356A3"; //入院患者色
const DEF_COLOR_OUT = "black"; //外来患者色

const DEF_VIS_IN_USE = "visible"; //visibility 表示
const DEF_VIS_NOT_IN_USE = "hidden"; //visibility 非表示

const DEF_CELL_HEIGHT_IN_USE = "2.4em"; //35px(基本フォントサイズは1.5em(15px))
const DEF_CELL_HEIGHT_NOT_IN_USE = "0px";

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
    propsParentWidth: {
      type: Number,
      required: false,
      default: 1
    },
    propsTreatDate: {
      type: Object,
      required: false,
      default: () => ({})
    }
  },
  data() {
    return {
      thisElem: null, //当コンポーネントのelemポインタ
      bedUsed: false, //ベッド使用中フラグ
      unmatchFlag: true, //不一致フラグ true:不一致あり
      shuntFlag: true, //シャント方向一致フラグ true:一致
      infectionFlag: true, //感染症一致フラグ true:一致
      deviceModeFlag: true, //治療モード一致フラグ true:一致
      visibilityBed: DEF_VIS_IN_USE, //表示フラグ デフォルト:display
      myIndex: 0, //自分自身のIndex
      myDayIndex: -1, //自分自身の日付Index
      cellWidth: DEF_KUR_WIDTH, //セルの幅
      bedAreaFlag: true, //確定エリアフラグ true:確定エリアにいる
      dispName: "", //表示名
      dispBedGroupFlag: true, //ベッドグループでの表示非表示のフラグ true:表示
      agentEdgeFlag: DEF_AGENT_EDGE
    };
  },
  computed: {
    divId() {
      //    console.log("this.propsId:" + this.propsId) ;
      return `id_bed${this.propsId}`;
    },
    /**
     * ベッド表示非表示フラグ
     *  ベッド(自分自身)の表示非表示設定の変更をWatch(ストア)し、変更をフラグとして反映する
     *  ※watch対象をindex指定するので直接watchにかけないための橋渡し処理
     */
    dispFlag() {
      // console.log("dispFlag called!!");
      return this.getBedDispState(this.myIndex - 1);
    },
    // 予定ありフラグ true:予定あり
    planFlag() {
      let rtn = false;
      const patId = this.propsJson.pat_id;
      // その他の予定データリストが設定済み、且つ患者IDが存在するセルの場合に処理を実施
      if (this.getOtherSchedule && patId) {
        // 表示日付のデータは必ず設定されているものとする
        const dayIndex = Number(this.propsJson.treatDate);
        if (this.getOtherSchedule.eventList[dayIndex]?.indexOf(patId) >= 0) {
          rtn = true;
        } else if (this.getOtherSchedule.examList[dayIndex]?.indexOf(patId) >= 0) {
          rtn = true;
        } else if (this.getOtherSchedule.radList[dayIndex]?.indexOf(patId) >= 0) {
          rtn = true;
        }
      }
      return rtn;
    },
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
  watch: {
    /**
     * 個別の非表示の監視
     *   ベッドグループに合わせた表示非表示
     *@param newFlag true:表示 false:非表示
     */
    dispFlag(newFlag) {
      //確定エリアのみ対象
      if (this.bedAreaFlag) {
        //ベッドグループでの表示非表示の格納
        this.dispBedGroupFlag = newFlag;
        //自分自身の表示非表示設定
        this.setDispStatus(newFlag);
      }
    },
    /**
     * 所属するクール全体が非表示かどうかの監視
     *@param newFlag true:表示 false:非表示
     */
    propsIsDisp(newFlag) {
      //自分自身の表示非表示設定
      this.setDispStatus(newFlag);
    },
    /**
     * 表示条件設定の名前表示の監視
     */
    nameSetting() {
      //設定の反映(名前の表示のみ)
      this.resetDispName();
    },
    /**
     * 表示条件設定の不一致表示の監視
     */
    unmatchSetting() {
      //設定の反映(不一致設定)
      this.resetDispName();
    },
    /**
     * 表示条件設定の予定あり表示の監視
     */
    planSetting() {
      //設定の反映(予定あり設定)
      this.resetDispName();
    },
    /**
     * プロパティの監視(ベッド情報の更新)
     */
    propsJson() {
      this.debugPrint("BED propsJson has changed!!");
      //処理遅延(非同期)化
      setTimeout(
        function() {
          this.resetDisp();
        }.bind(this),
        4
      );
    },
    /**
     * プロパティの監視(表示基準日情報の更新)
     */
    propsTreatDate() {
      this.resetDisp();
    }
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  mounted() {
    //自分自身のIDの取得
    this.thisElem = document.getElementById(this.divId);

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
     * 自分自身の表示非表示設定
     * @param dispFlag true:表示 false:非表示
     */
    setDispStatus(dispFlag) {
      if (dispFlag) {
        //表示
        this.visibilityBed = DEF_VIS_IN_USE;
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
        // this.thisElem.style.height = DEF_CELL_HEIGHT_IN_USE;
        // this.thisElem.style.lineHeight = DEF_CELL_HEIGHT_IN_USE;
        // this.thisElem.style.borderWidth = "1px";
        if (this.thisElem) {
          this.thisElem.style.height = DEF_CELL_HEIGHT_IN_USE;
          this.thisElem.style.lineHeight = DEF_CELL_HEIGHT_IN_USE;
          this.thisElem.style.borderWidth = "1px";
        }
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
      } else {
        //非表示
        this.visibilityBed = DEF_VIS_NOT_IN_USE;
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
        // this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
        // this.thisElem.style.borderWidth = "0px";
        if (this.thisElem) {
          this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
          this.thisElem.style.borderWidth = "0px";
        }
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
      }
    },

    /**
     * 名前の表示変更
     */
    resetDispName() {
      if (
        this.propsJson !== null &&
        "title" in this.propsJson &&
        this.propsJson.title === ""
      ) {
        //タイトル列以外を変更します

        //titleプロパティの値が空文字の場合は、タイトル列のセルではない
        this.dispName =
          !("patLastName" in this.propsJson) ||
          this.propsJson.patLastName === null
            ? ""
            : this.propsJson.patLastName;

        //名前表示設定
        if (
          "patFirstName" in this.propsJson &&
          this.propsJson.patFirstName !== null &&
          this.propsJson.patFirstName.length > 0
        ) {
          // 姓名or姓のみの確認
          if (!this.nameSetting) {
            //姓名表示用に、名を追加
            this.dispName += ` ${this.propsJson.patFirstName}`;
          }

          //ダミー表示
          //          if(this.propsJson.isDummy === '1')
          //          {
          //            this.dispName = '(' + this.dispName + ')';
          //          }

          // 不一致表示の確認
          if (this.unmatchSetting) {
            if (this.unmatchFlag) {
              //不一致だったので不一致記号を追加
              this.dispName = DEF_UNMATCH_STR + this.dispName;
            }
          }
          // mod FNSI 入院・同姓同名配布 同姓同名患者に文字列「*」を強制付与 start -- Sanjingye Sun 20201228
          if(this.propsJson.isSame && this.propsJson.isSame == 1) {
            this.dispName += "*";
          }
          // mod FNSI 入院・同姓同名配布 同姓同名患者に文字列「*」を強制付与 end -- Sanjingye Sun 20201228
          // 予定あり表示の確認
          if (this.planSetting) {
            if (this.planFlag) {
              //予定があったので予定あり記号を追加
              this.dispName = this.dispName + DEF_PLAN_STR;
            }
          }
        }
      }
      this.debugPrint("resetDispName() end!!");
    },
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
        //表示だけクリア
        this.dispName = "";
        // 未登録エリアの日付を取得する
        const bedNotYetDate = this.propsTreatDate.date;
        // 過去日の背景色設定
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
        // if (bedNotYetDate < currentDate) {
        //     this.thisElem.style.backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
        // } else {
        //     this.thisElem.style.backgroundColor = DEF_SETTING_STYLE_THEME;
        // }
        if (this.thisElem) {
          if (bedNotYetDate < currentDate) {
            this.thisElem.style.backgroundColor = BACKGROUND_COLUMN_PAST_DAY;
          } else {
              this.thisElem.style.backgroundColor = DEF_SETTING_STYLE_THEME;
          }
        }   
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
        return;
      }

      // 日付取得
      const selectedDate = this.propsJson.treatDate;

      if (this.propsJson.title === "") {
        //titleプロパティの値が空文字の場合は、タイトル列のセルではない

        let replaceStr = "id_bed";
        this.bedAreaFlag = true; //確定エリアにいる、で初期化
        if (this.divId.startsWith("id_bedBednotYet")) {
          //ベッド未登録エリアだった場合
          replaceStr = "id_bedBednotYet";
          this.bedAreaFlag = false; //確定エリアではない
        } else if (this.divId.startsWith("id_bedKurnotYet")) {
          //クール未登録エリアだった場合
          replaceStr = "id_bedKurnotYet";
          this.bedAreaFlag = false; //確定エリアではない
        }

        //ベッドindex
        this.myIndex = this.divId.replace(replaceStr, "").split("-")[2];
        //日付index
        this.myDayIndex = this.divId.replace(replaceStr, "").split("-")[0];
        //確認対象のIndexの計算(呼び出しのパラメータは0基底)
        const targetIndex = Number(this.myIndex) - 1;
        if (!this.getBedDispState(targetIndex) && this.bedAreaFlag) {
          //非表示かつ確定エリアだったので、隠します
          this.visibilityBed = DEF_VIS_NOT_IN_USE;
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
          // this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
          // this.thisElem.style.borderWidth = 0;
          if (this.thisElem) {
            this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
            this.thisElem.style.borderWidth = 0;
          }
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
        }

        //不一致確認
        // ベッド未登録およびクール未登録エリアのものはチェックしない
        this.unmatchFlag = this.checkUnmatchInfo();

        //名前表示設定
        this.resetDispName();

        //名前があるところは入外区分で文字色、治療状況で背景色を変えます
        if (this.dispName !== "") {
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

          //使用中ベッド設定
          this.bedUsed = true;

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
          //空きベッド設定
          this.bedUsed = false;

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
      } else {
        //タイトル列のセルの処理

        //ベッドヘッダタイトルの処理

        this.myIndex = this.divId.replace("id_bedtitle_", "");
        this.myDayIndex = -1;
        const targetIndex = Number(this.myIndex) - 1;

        //ベッドの表示設定確認
        if (!this.getBedDispState(targetIndex)) {
          //非表示処理
          this.visibilityBed = DEF_VIS_NOT_IN_USE;
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
          // this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
          // this.thisElem.style.borderWidth = 0;
          if (this.thisElem) {
            this.thisElem.style.height = DEF_CELL_HEIGHT_NOT_IN_USE;
            this.thisElem.style.borderWidth = 0;
          }
          // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
        }

        //ベッド名の設定
        // ※初期表示時にはタイミングによって名前が取得できない場合(DB取得処理が終わっていない)を考慮してintervalで名前が取得できるまでリトライします
        const intervalId = setInterval(
          function() {
            const setStr = this.getBedName(targetIndex);
            if (typeof setStr !== DEF_UNDEFINED) {
              //名前の設定
              this.dispName = setStr;
              clearInterval(intervalId);
            }
          }.bind(this, targetIndex),
          100
        );

        this.bedUsed = false;
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
        // this.thisElem.style.backgroundColor = "#595959";
        // this.thisElem.style.color = "white";
        if (this.thisElem) {
          this.thisElem.style.backgroundColor = "#595959";
          this.thisElem.style.color = "white";
        }
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
        return;
      }
    },
    /**
     * OverText設定
     * 表示文字列長を考慮したスタイル設定
     *@param strName 表示文字列
     **/
    setOverTextStyle(strName) {
      if (strName.length <= 14) {
        //全角半角含めて14文字以下だとそのまま
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
        // this.thisElem.style.overFlow = "auto";
        // this.thisElem.style.whiteSpace = "normal";
        if (this.thisElem) {
          this.thisElem.style.overFlow = "auto";
          this.thisElem.style.whiteSpace = "normal";
        }
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
      } else {
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 start
        //全角半角含めて15文字以上だと1行で…表示
        // this.thisElem.style.overFlow = "hidden";
        // this.thisElem.style.whiteSpace = "nowrap";
        if (this.thisElem) {
          this.thisElem.style.overFlow = "hidden";
          this.thisElem.style.whiteSpace = "nowrap";
        }
        // mod #8844 Uncaught TypeError: Cannot read properties of null (reading 'style') 修正 林峻峰 end
      }
    },
    /**
     * 不一致チェック
     * 以下の項目の不一致チェックを行う
     * 1.シャント方向
     * 2.感染症有無
     * 3.治療モード
     * @return true:不一致あり false:不一致なし
     */
    checkUnmatchInfo() {
      if (
        DEF_NOTASSIGNED !== this.propsJson.kur_cd &&
        DEF_NOTASSIGNED !== this.propsJson.bed_cd
      ) {
        //------------------------------------------------
        //不一致チェック
        //不一致チェック用基準データをストアから取得
        const checkBaseJson = this.getBedUnmatchCheckInfo(
          this.propsJson.bed_cd
        );

        //シャント方向の不一致チェック
        this.shuntFlag = true; //true:一致

        //undefined対策 undefinedの場合、nullの値を持つキーを作成
        this.propsJson.vaDirect =
          "vaDirect" in this.propsJson ? this.propsJson.vaDirect : null;

        const patVaDirect = this.propsJson.vaDirect; //患者のシャント方向
        const bedVaDirect = String(checkBaseJson.shunt_position); //ベッドのシャント方向

        //現行ソースのロジック:SchComparision.cs
        if (
          null === patVaDirect ||
          "" === patVaDirect ||
          null === bedVaDirect ||
          "" === bedVaDirect ||
          bedVaDirect === patVaDirect
        ) {
          // ①どちらかあるいは両方null(or空文字)、または一致する場合、一致
          this.shuntFlag = true;
        } else if (
          DEF_SHUNT_NONE === patVaDirect ||
          DEF_SHUNT_UNKNOWN === patVaDirect ||
          DEF_SHUNT_NONE === bedVaDirect ||
          DEF_SHUNT_UNKNOWN === bedVaDirect
        ) {
          // ②どちらかがシャント位置「なし」、「不明」の場合は、不一致
          this.shuntFlag = false;
        } else if (
          DEF_SHUNT_BOTH === patVaDirect ||
          DEF_SHUNT_BOTH === bedVaDirect
        ) {
          // ③どちらかがシャント位置「両方」の場合、一致
          this.shuntFlag = true;
        } else {
          // ④その他、不一致
          this.shuntFlag = false;
        }

        //感染症有無の不一致チェック
        //this.infectionFlag = true; //true:一致

        this.infectionFlag =
          checkBaseJson.is_infection === this.propsJson.isInfect;
        // console.log(`checkBaseJson.is_infection:${checkBaseJson.isInfection}`);
        // console.log(`this.propsJson.isInfect:${this.propsJson.isInfect}`);
        // console.log(`this.infectionFlag:${this.infectionFlag}`);

        //治療モードの不一致チェック
        this.deviceModeFlag = true; //true:一致

        if (DEF_DISABLED === checkBaseJson.is_disable) {
          //使用不可なのでチェックする必要なく、不一致
          this.deviceModeFlag = false;
        } else {
          //装置モード:-1:不明、0:HD、1:ECUM,2:HDF、3:HF、4:HD+補液、5:ECUM+補液、6:AFBF、7:OHDF、8:OHF、9:特殊浄化、10:I-HDF
          const deviceModeSupport = {
            [DEF_DM_HD]: checkBaseJson.is_support_hd,
            [DEF_DM_ECUM]: checkBaseJson.is_support_ecum,
            [DEF_DM_HDF]: checkBaseJson.is_support_hdf,
            [DEF_DM_HF]: checkBaseJson.is_support_hf,
            [DEF_DM_HD_HO]: checkBaseJson.is_support_hd_ho,
            [DEF_DM_ECUM_HO]: checkBaseJson.is_support_ecum_ho,
            [DEF_DM_AFBF]: checkBaseJson.is_support_afbf,
            [DEF_DM_OHDF]: checkBaseJson.is_support_ohdf,
            [DEF_DM_OHF]: checkBaseJson.is_support_ohf,
            [DEF_DM_IHDF]: checkBaseJson.is_support_i_hdf,
            [DEF_DM_PURIFICATION]: checkBaseJson.is_support_blood_purify,
            [DEF_DM_UNKNOWN]: DEF_UNSUPPORTED
          };
          this.deviceModeFlag =
            deviceModeSupport[this.propsJson.deviceMode] === DEF_SUPPORTED;
        }
      } else {
        //ベッド確定エリア以外では、チェックを初期化(すべて一致)
        this.shuntFlag = true;
        this.infectionFlag = true;
        this.deviceModeFlag = true;
      }

      //チェック結果を付加する
      this.propsJson.shuntFlag = this.shuntFlag;
      this.propsJson.infectionFlag = this.infectionFlag;
      this.propsJson.deviceModeFlag = this.deviceModeFlag;

      return !(this.shuntFlag && this.infectionFlag && this.deviceModeFlag);
    },
    /**
      デバッグログ
    */
    debugPrint(msg) {
      msg;
      //      console.log(msg);
    }
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
