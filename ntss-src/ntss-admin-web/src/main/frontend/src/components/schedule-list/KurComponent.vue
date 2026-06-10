/** * クールコンポーネント サイズ:縦横とも枠に合わせる設定 */
<template>
  <div :id="divId" class="cls-kurbody">
    <template v-for="b in bedMaxCounter">
      <!-- modify by chamaojia 2024-07-29 [10601] add 【props-name】 start -->
      <component
        :is="compNameBed"
        :key="'key' + b"
        :props-id="propsId + '-' + b"
        :props-json="bedJsonData[b]"
        :props-name="bedNameData[b]"
        :props-is-disp="isDispKur"
        keep-alive
      />
      <!-- modify by chamaojia 2024-07-29 [10601] add 【props-name】 end -->
    </template>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";

/* modify by chamaojia 2024-07-30 [10601] page changes referenced --start */
import BedComponent from "@/components/schedule-list/KurBedComponent.vue";
/* modify by chamaojia 2024-07-30 [10601] page changes referenced --end */
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

const DEF_DISP_FIRST_NUM = 1; //はじめに出すベッド数(開始数)
const DEF_DISP_STEP_NUM_1ST = 5; //徐々に出すベッド数(追加数) 一番始めのみ
const DEF_DISP_STEP_NUM_2ND = 50; //徐々に出すベッド数(追加数) 2回目以降
const DEF_LIMIT_BED_NUM = 300; //ベッド数上限

/* add by chamaojia 2024-07-30 [10601] add constant definition --start */
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
const DEF_PLAN_MAINTE_WATER_STR = "■";

//表示条件設定:不一致(全角!)
const DEF_UNMATCH_STR = "！";
/* add by chamaojia 2024-07-30 [10601] add constant definition --end */

export default {
  props: {
    propsJson: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propsId: {
      type: String,
      required: false,
      default: ""
    },
    propsTreatDate: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propsMoveData: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propsDummyData: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propsIsDisp: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  data() {
    return {
      thisElem: null,
      bedMaxCounter: DEF_DISP_FIRST_NUM, //ベッド出力数
      bedMax: DEF_LIMIT_BED_NUM, //ベッドの出力数
      timerId: 0, //インターバルタイマーID
      bedJsonData: [null], //ベッドコンポーネント用データ(Json配列[{},{},{}・・・{}])    基底が1
      /* add by chamaojia 2024-07-30 [10601] add variable definition --start */
      bedNameData: [null], // patient name displayed
      /* add by chamaojia 2024-07-30 [10601] add variable definition --end */
      showflag: false,
      addflag: false,
      myOpacity: 0,
      changeOpaId: null,
      compNameBed: BedComponent,
      isDispKur: true,
      addNum: DEF_DISP_STEP_NUM_1ST
    };
  },
  computed: {
    myKur() {
      //クールの番号1,2,…
      return this.propsId.split("-")[1];
    },
    myDay() {
      //日付の番号1,2,…
      return this.propsId.split("-")[0];
    },
    divId() {
      return `id_kur${this.myDay}-${this.myKur}`;
    },
    ...mapGetters("schedule-list", [
      /* add by chamaojia 2024-07-30 [10601] add method --start */
      "nameSetting", //表示条件設定:姓のみ表示フラグ取得用
      "unmatchSetting", //表示条件設定:不一致表示フラグ取得用
      "planSetting", //表示条件設定:予定あり表示フラグ取得用
      "plansettingMainteWater", //表示条件設定:定期点検・水質検査予定あり表示フラグ取得用
      "getBedUnmatchCheckInfo", //不一致情報取得用
      "getOtherSchedule", //その他の予定データリスト
      /* add by chamaojia 2024-07-30 [10601] add method --end */
      "getConfigJson",
      "getBedsData",
      "getDataLoadedFlag",
      "getBedElemIdInfo",
      "getBedElemIdInfoBlock",
      "getBedElemIdInfoForDelete",
      "getOpaSwitch",
      "getMaxBedNum" //ベッド最大数取得用
    ]),
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"])
  },
  watch: {
    /* add by chamaojia 2024-07-30 [10601] method to add monitoring --start */
    bedJsonData() {
      this.resetDispName();
    },
    /**
     * 表示条件設定の名前表示の監視
     */
    nameSetting(newData) {
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
    /* add by chamaojia 2024-07-30 [10601] method to add monitoring --end */
    /**
     * 表示条件設定の定期点検・水質検査予定あり表示の監視
     */
    plansettingMainteWater() {
      //設定の反映(定期点検・水質検査予定あり設定)
      this.resetDispName();
    },
    /**
     * 点滅処理監視
     * 未登録エリアからの移動可能範囲を点滅で表示する機能のための監視
     * @param switchVal 点滅指定文字列
     *          フォーマット:
     *              日付指定 off/on-日付index 例)on-1-2
     *              クール指定 off/on-日付index-クールindex 例)off-1-2
     * ※2019/07/04現在 未使用な機能。メッセージで移動不可を通知するので復活することはないかもしれないが保留
     **/
    getOpaSwitch(switchVal) {
      switchVal;
      const switchDim = switchVal.split("-");
      //自分が該当するかのチェック
      if (2 === switchDim.length) {
        //日付ヘッダー範囲(日付Indexのみの確認)
        if (switchDim[1] !== this.myDay) {
          return;
        }
      } else if (3 === switchDim.length) {
        //クールヘッダー範囲(日付IndexとクールIndexのみの確認)
        if (switchDim[1] !== this.myDay || switchDim[2] !== this.myKur) {
          return;
        }
      }

      //点滅表示の設定確認
      if ("off" === switchDim[0]) {
        //点滅停止
        this.setOpacityChange(false);
      } else if ("on" === switchDim[0]) {
        //点滅開始
        this.setOpacityChange(true);
      }
    },

    /**
     * 削除ベッド(患者)の監視
     */
    getBedElemIdInfoForDelete(indexDimDim) {
      // console.log("getBedElemIdInfoForDelete called");
      //自分が対象かどうかの確認
      for (let j = 0; j < indexDimDim.length; j++) {
        const indexDim = indexDimDim[j];
        for (let i = 0; i < indexDim.length; i++) {
          const selectedIdDim = indexDim[i];
          if (this.propsId === `${selectedIdDim[0]}-${selectedIdDim[1]}`) {
            //対象だった場合、対象のベッド情報を削除
            //削除は、以下の設定を行う(空きベッドにする)
            //    "patLastName":""
            //    "patFirstName":""
            //    "inOutClass":""
            //    "inOutClass":""
            this.debugPrint("空きベッド化処理");
            this.debugPrint(`selectedIdDim:${selectedIdDim}`);
            // const tmp = this.bedJsonData[selectedIdDim[2]];
            const tmp = JSON.parse(
              JSON.stringify(this.bedJsonData[selectedIdDim[2]])
            ); //deep copy
            tmp.patLastName = "";
            tmp.patFirstName = "";
            tmp.inOutClass = "";
            tmp.dialysisState = "";
            this.bedJsonData.splice(selectedIdDim[2], 1, tmp);
          }
        }
      }
    },
    /**
     * 選択ベッド(患者)の監視
     * @param selectedIdDim [0]日付 [1]クール [2]ベッド
     */
    getBedElemIdInfo(selectedIdDim) {
      //自分が対象かどうかの確認
      if (this.propsId === `${selectedIdDim[0]}-${selectedIdDim[1]}`) {
        //ベッドの情報をストアに送る
        this.setBedInfoForHeader(this.bedJsonData[selectedIdDim[2]]);
      }
    },
    /**
     * 選択ベッド(患者)の監視(ブロック移動)
     * @param selectedIdDim [0]日付 [1]クール
     */
    getBedElemIdInfoBlock(selectedIdDim) {
      //自分が対象かどうかの確認
      // console.log(
      //   `ブロック処理!!${selectedIdDim}:this.propsId:${this.propsId}:`
      // );

      //クールブロック移動の場合のselectedIdDimのフォーマット m-n
      //日付ブロック移動の場合のselectedIdDimのフォーマット m
      //クールブロック移動の場合
      const checkFlag = selectedIdDim?.indexOf("-") >= 0;

      if (
        (checkFlag && this.propsId === selectedIdDim) ||
        (!checkFlag && this.myDay === selectedIdDim)
      ) {
        //対象だったので全ベッド情報設定
        // console.log(`proc!!selectedIdDim:${selectedIdDim}`);
        const sendData = { [this.propsId]: this.bedJsonData };
        this.setBedInfoForBlock(sendData);
      }
    },
    /**
     *表示監視
     */
    propsIsDisp(newValue) {
      this.isDispKur = newValue;
    },
    //ダミースケジュールデータの監視
    propsDummyData(newValue) {
      this.debugPrint("ダミーデータ設定の監視");
      this.debugPrint(`newValue:${newValue}`);
      this.bedJsonData.splice(newValue.index[2], 1, newValue.data);
    },
    //日付の変更の監視
    propsTreatDate(newValue) {
      if (this.getDataLoadedFlag) {
        //データ読み込み済みだったら処理
        //yyyymmdd
        this.settingBedsData(newValue.date.split("/").join(""));
      }
    },
    //移動データの監視
    propsMoveData(newValue) {
      // const indexDim = newValue.index;
      //受け取ったデータでベッドの状況をチェック
      // if (this.bedJsonData[indexDim[2]].patLastName === "") {
      //空きベッドですのでデータをセットします

      // //DBの更新
      // const payload = {
      //   ordNo: newValue.data.ordNo,
      //   condTreatDate: newValue.data.treatDate,
      //   facilityCd: this.getFacilityCd,
      //   newTreatDate: this.bedJsonData[newValue.index[2]].treatDate,
      //   kurCd: this.bedJsonData[newValue.index[2]].kur_cd,
      //   bedCd: this.bedJsonData[newValue.index[2]].bed_cd
      // };
      // this.debugPrint(`payload:${JSON.stringify(payload)}`);

      // //更新
      // this.updateScheduleInfoOnDB(payload);

      //データの確認
      // this.debugPrint("before");
      // this.debugPrint(`newValue.data:${JSON.stringify(newValue.data)}`);
      // this.debugPrint(
      //   `this.bedJsonData[newValue.index[2]]:${JSON.stringify(
      //     this.bedJsonData[newValue.index[2]]
      //   )}`
      // );

      //移動先の固定情報を移動してくるデータに移します
      const propStrDim = ["No", "kur_cd", "bed_cd", "kur_name", "treatDate"];

      for (let i = 0; i < propStrDim.length; i++) {
        newValue.data[propStrDim[i]] = this.bedJsonData[newValue.index[2]][
          propStrDim[i]
        ];
      }

      // this.debugPrint("after");
      // this.debugPrint(`newValue.data:${JSON.stringify(newValue.data)}`);
      // this.debugPrint(
      //   `this.bedJsonData[newValue.index[2]]:${JSON.stringify(
      //     this.bedJsonData[newValue.index[2]]
      //   )}`
      // );
      this.bedJsonData.splice(newValue.index[2], 1, newValue.data);
      // }
    },
    /**
     * データ読み込みフラグの監視
     */
    getDataLoadedFlag(newVal) {
      if (newVal) {
        // console.log("getDataLoadedFlag start!!");
        //ベッドのデータを設定します
        //       const checkStr = typeof this.propsTreatDate.date;
        //        if (checkStr === "undefined") {
        if (!("date" in this.propsTreatDate)) {
          //日付がセットされていないので何もしない(日付設定(propsTreatDate)のWatch側で処理)
          // console.log(
          //   `日付がセットされていないので何もしない(日付設定(propsTreatDate)のWatch側で処理) JSON.stringify(this.propsTreatDate):${JSON.stringify(
          //     this.propsTreatDate
          //   )}`
          // );
          return;
        }

        const idDim = this.divId.replace("id_kur", "").split("-");
        if (idDim[0] <= -1) {
          //1日～3日分を出す
          this.settingBedsData(this.propsTreatDate.date);
        } else {
          //他は遅延させる
          setTimeout(
            function() {
              this.settingBedsData(this.propsTreatDate.date);
            }.bind(this),
            1000
          );
        }
      }
    }
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  created() {
    this.showflag = true;
    this.addflag = true;
    //TODO:固定でMAXを確保(可変対応)
    //const maxBed = 300;
  },
  mounted() {
    //ベッド数が出るまで待つ

    const globalThis = this;
    //例)クールのベッド出力選択のやり方
    //    if(Number(this.myDay) === 8 || Number(this.myDay) === 9 || Number(this.myDay) === 10)
    //    {

    //徐々にベッドを出していくためのInterval
    const waitingBedId = setInterval(
      function() {
        if (globalThis.getMaxBedNum > 0) {
          globalThis.bedMax = globalThis.getMaxBedNum;
          // globalThis.debugPrint("globalThis.bedMax");
          // globalThis.debugPrint(globalThis.bedMax);
          if (
            typeof globalThis.propsTreatDate !== "undefined" &&
            "date" in globalThis.propsTreatDate
          ) {
            //this.propsTreatDateが存在して、dateプロパティが有った場合、ベッド設定処理を行う
            globalThis.settingBedsData(globalThis.propsTreatDate.date);
          }

          //親の要素ポインタ取得&格納
          globalThis.thisElem = document.getElementById(globalThis.divId);

          //ベッドの設定処理
          globalThis.settingBeds();

          //インターバルのクリア
          clearInterval(waitingBedId);
        }
      }.bind(globalThis),
      50
    );
    //    }
  },
  methods: {
    ...mapActions("schedule-list", [
      "setDoneNum",
      "setHeaderInfo",
      "setBedInfoForHeader",
      "setBedInfoForBlock", //全ベッド情報の設定
      "setFlag",
      "updateScheduleInfoOnDB" //スケジュール表データ(ベッド情報)の更新
    ]),
    /* add by chamaojia 2024-07-30 [10601] method for adding processing names --start */
    /**
     * 名前の表示変更
     */
    resetDispName() {
      this.bedJsonData.forEach((data, index) => {
        let dispName = "";
        if (data != null) {
          //titleプロパティの値が空文字の場合は、タイトル列のセルではない
          dispName =
              !("patLastName" in data) ||
              data.patLastName === null
                  ? ""
                  : data.patLastName;

          //名前表示設定
          if (
              "patFirstName" in data &&
              data.patFirstName !== null &&
              data.patFirstName.length > 0
          ) {
            // 姓名or姓のみの確認
            if (!this.nameSetting) {
              //姓名表示用に、名を追加
              dispName += ` ${data.patFirstName}`;
            }

            // 不一致表示の確認
            if (this.unmatchSetting) {
              const unmatchFlag = this.checkUnmatchInfo(data);
              if (unmatchFlag) {
                //不一致だったので不一致記号を追加
                dispName = DEF_UNMATCH_STR + dispName;
              }
            }
            
            // mod FNSI 入院・同姓同名配布 同姓同名患者に文字列「*」を強制付与 start -- Sanjingye Sun 20201228
            if(data.isSame && data.isSame == 1) {
              dispName += "*";
            }
            // mod FNSI 入院・同姓同名配布 同姓同名患者に文字列「*」を強制付与 end -- Sanjingye Sun 20201228
            
            // 予定あり表示の確認
            if (this.planSetting) {
              let rtn = false;
              const patId = data.pat_id;
              // その他の予定データリストが設定済み、且つ患者IDが存在するセルの場合に処理を実施
              if (this.getOtherSchedule && patId) {
                // 表示日付のデータは必ず設定されているものとする
                const dayIndex = Number(data.treatDate);
                if (this.getOtherSchedule.eventList[dayIndex]?.indexOf(patId) >= 0) {
                  rtn = true;
                } else if (this.getOtherSchedule.examList[dayIndex]?.indexOf(patId) >= 0) {
                  rtn = true;
                } else if (this.getOtherSchedule.radList[dayIndex]?.indexOf(patId) >= 0) {
                  rtn = true;
                }
              }

              if (rtn) {
                //予定があったので予定あり記号を追加
                dispName = dispName + DEF_PLAN_STR;
              }
            }
          }
          
          // 定期点検・水質検査予定あり表示の確認
          if (this.plansettingMainteWater) {
            const bedCd = data.bed_cd;
            if (this.getOtherSchedule) {
              // 表示日付のデータは必ず設定されているものとする
              const dayIndex = Number(data.treatDate);
              // 一致するセルに予定あり記号を追加
              if (this.getOtherSchedule.mainteList[dayIndex]?.indexOf(bedCd) >= 0 ||
                  this.getOtherSchedule.waterSurveyList[dayIndex]?.indexOf(bedCd) >= 0) {
                dispName += DEF_PLAN_MAINTE_WATER_STR;
              }
            }
          }
          this.bedNameData[index] = dispName;
        }
      });

    },
    /**
     * 不一致チェック
     * 以下の項目の不一致チェックを行う
     * 1.シャント方向
     * 2.感染症有無
     * 3.治療モード
     * @return true:不一致あり false:不一致なし
     */
    checkUnmatchInfo(data) {
      let shuntFlag = true;
      let infectionFlag = true;
      let deviceModeFlag = true;
      if (
          DEF_NOTASSIGNED !== data.kur_cd &&
          DEF_NOTASSIGNED !== data.bed_cd
      ) {
        //------------------------------------------------
        //不一致チェック
        //不一致チェック用基準データをストアから取得
        const checkBaseJson = this.getBedUnmatchCheckInfo(
            data.bed_cd
        );

        //シャント方向の不一致チェック
        shuntFlag = true; //true:一致

        //undefined対策 undefinedの場合、nullの値を持つキーを作成
        data.vaDirect =
            "vaDirect" in data ? data.vaDirect : null;

        const patVaDirect = data.vaDirect; //患者のシャント方向
        const bedVaDirect = String(checkBaseJson?.shunt_position); //ベッドのシャント方向

        //現行ソースのロジック:SchComparision.cs
        //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx start
        // if (
        //     null === patVaDirect ||
        //     "" === patVaDirect ||
        //     null === bedVaDirect ||
        //     "" === bedVaDirect ||
        //     bedVaDirect === patVaDirect
        // ) {
        //   // ①どちらかあるいは両方null(or空文字)、または一致する場合、一致
        //   shuntFlag = true;
        // } else if (
        //     DEF_SHUNT_NONE === patVaDirect ||
        //     DEF_SHUNT_UNKNOWN === patVaDirect ||
        //     DEF_SHUNT_NONE === bedVaDirect ||
        //     DEF_SHUNT_UNKNOWN === bedVaDirect
        // ) {
        //   // ②どちらかがシャント位置「なし」、「不明」の場合は、不一致
        //   shuntFlag = false;
        // } else if (
        //     DEF_SHUNT_BOTH === patVaDirect ||
        //     DEF_SHUNT_BOTH === bedVaDirect
        // ) {
        //   // ③どちらかがシャント位置「両方」の場合、一致
        //   shuntFlag = true;
        // } else {
        //   // ④その他、不一致
        //   shuntFlag = false;
        // }
        if (null === patVaDirect || "" === patVaDirect || null === bedVaDirect || "" === bedVaDirect) {
          shuntFlag = true;
        }else if (DEF_SHUNT_NONE == patVaDirect || DEF_SHUNT_NONE == bedVaDirect) {
          // 3:無
          shuntFlag = true;
        }else if (DEF_SHUNT_UNKNOWN == patVaDirect) {
          // -:不明
          shuntFlag = false;
        }else if (bedVaDirect != patVaDirect) {
          shuntFlag = false;
        }
        //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx end

        //感染症有無の不一致チェック
        //this.infectionFlag = true; //true:一致

        // mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
        if (checkBaseJson && checkBaseJson.is_infection !== null) {
          infectionFlag = checkBaseJson.is_infection === data.isInfect;
        }
        // mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

        //治療モードの不一致チェック
        deviceModeFlag = true; //true:一致

        if (DEF_DISABLED === checkBaseJson.is_disable) {
          //使用不可なのでチェックする必要なく、不一致
          deviceModeFlag = false;
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
          deviceModeFlag =
              deviceModeSupport[data.deviceMode] === DEF_SUPPORTED;
        }
      }

      return !(shuntFlag && infectionFlag && deviceModeFlag);
    },
    /* add by chamaojia 2024-07-30 [10601] method for adding processing names --end */
    /**
      デバッグログ
    */
    debugPrint(msg) {
      msg;
      // console.log(msg);
    },
    /**
     * 移動可能領域点滅処理
     */
    setOpacityChange(onoffFlag) {
      const globalThis = this;
      if (onoffFlag) {
        //ハイライト点滅処理設定
        clearInterval(this.changeOpaId);
        this.changeOpaId = setInterval(
          function() {
            //opacityの値を徐々に変更(0.5->1を繰り返す)
            globalThis.myOpacity += 0.1;
            if (globalThis.myOpacity > 1) {
              globalThis.myOpacity = 0.5;
            }
            globalThis.thisElem.style.opacity = globalThis.myOpacity;
          }.bind(globalThis),
          100
        );
      } else {
        //ハイライト点滅処理終了
        clearInterval(this.changeOpaId);
        this.myOpacity = 1;
        this.thisElem.style.opacity = this.myOpacity;
      }
    },
    /**
     * ベッドデータの設定処理
     *@param treatDate 治療日付
     */
    settingBedsData(treatDate) {
      try {
        //データ取得(ターゲット日付のデータを取得しベッドのバインド配列に設定する)
        const treatDateData = this.getBedsData(treatDate);

        if (treatDateData === null) {
          //データがなかった場合
          this.debugPrint("kurComponent データがありません");
        } else {
          //取得データから自分自身のクールに該当する要素からベッドデータを取得し、ベッドのpropsのバインド変数にセットする
          this.bedJsonData = treatDateData[this.myKur - 1].beddata;
        }
      } catch (e) {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('KurComponent.vue', 'settingBedsData', e);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        e;
      }
    },
    /**
     *   ベッドコンポーネントの出力処理
     *    以下を設定する
     *    ・ベッドの出力数制御
     *    ・ベッドの生成確認制御
     */
    settingBeds() {
      //インターバル処理を設定

      //ベッドの出力数を上げていく処理
      clearInterval(this.timerId);
      this.timerId = setInterval(this.countUpBedMax, 4);

      //生成状況の監視をする処理
      clearInterval(this.watchId);
      this.watchId = setInterval(this.watchDispState, 500);

      //ベッドを出すだけで以下の処理はなし
      //データ取得(ターゲット日付のデータを取得しベッドのバインド配列に設定する)
      //      let jsonData = this.getDataFromStore(treatDate) ;
      //      this.bedJsonData = jsonData[this.myKur-1].beddata ;
    },
    /**
  	  ベッド数増加処理
  	  ベッド数を増やしていく(あくまでMax値を増やしているのみ。実際にはまだ表示途中。生成確認はwatchDispState()で行う)
  	*/
    countUpBedMax() {
      //ベッド数を増加
      this.bedMaxCounter += this.addNum;
      if (this.bedMaxCounter >= this.bedMax) {
        //      if (this.bedMaxCounter >= 1) {
        //ベッド数が最大値を超えた
        //増加させたベッド数が最大値を超えている場合を考慮してベッド数を最大値にセット
        this.bedMaxCounter = this.bedMax;
        //        this.bedMaxCounter = 1;

        //増加ステップ数を設定
        //※初回と初回以降の増加数を変更する
        //※目的:初回は増加ステップ数が小さいと処理負荷が小さくなり初期表示が早くなるので、その調整用のため2段設定できるようにしている
        this.addNum = DEF_DISP_STEP_NUM_2ND;
        //インターバルタイマーをクリア
        clearInterval(this.timerId);
      }
    },
    /**
     *  定期的にベッドの出力状態(HTMLの組み立て状態)を確認する処理
     *  ・v-forの変更でのタイムラグ吸収を目的とする監視
     *  ・コンポーネントの生成具合を配下のDIVタグの生成具合で代替し確認する。
     *  ・生成終了時にストアに生成の終了を通知する
     *  ・ストア側では、通知を受けて表全体の読み込みが終わったかの統括確認をおこなう。
     */
    watchDispState() {
      //配下のDivタグの数をwatch

      //自分自身の要素が生成されているかの確認
      if (null === this.thisElem) {
        this.thisElem = document.getElementById(this.devId);
        if (null === this.thisElem) {
          //要素が取得できないのでなにもしない
          return;
        }
      }

      //配下の要素の確認
      const children = this.thisElem.children;
      let childrenCounter = 0;

      //Divタグのカウント
      for (const i in children) {
        const tagNameStr = children[i].tagName;
        if (tagNameStr === "DIV") {
          childrenCounter++;
        }
      }

      if (childrenCounter === this.bedMax) {
        //予定数生成されたので終了
        //storeのフラグ更新
        this.setFlag({ id: this.propsId });
        //watch終了
        clearInterval(this.watchId);
      }

      //ストアに現状を報告
      this.setDoneNum({ id: this.propsId, num: childrenCounter });
    }
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.cls-kurbody {
  /**  position:absolute;*/
  background: gray;
  border: black solid 0px;
  /**    box-sizing: border-box;*/
  opacity: 1;
  width: 100%;
  height: 100%;
}
</style>
