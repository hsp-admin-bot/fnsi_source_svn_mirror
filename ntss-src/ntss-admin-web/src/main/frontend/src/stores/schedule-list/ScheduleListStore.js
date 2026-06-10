import { ApiHelper } from "@/apis/AxiosHelper";
import {
  sendRequestGetPatEventRecordList
} from "@/apis/pat-event";
import {
  sendRequestPatExamMain
} from "@/apis/exam-request";
import {
  sendRequestPatRadMain
} from "@/apis/rad-request";
import moment from "moment";
// add FNSI-6947 Deprecation warningの抑止 ljx start
moment.suppressDeprecationWarnings = true;
// add FNSI-6947 Deprecation warningの抑止 ljx end
import store from "@/stores";

export const HEADER_DEFAULT_MSG =
  "クリック&クリックでスケジュール移動ができます."; //ヘッダーデフォルトメッセージ
export const HEADER_MODE_DEFAULT = 2; //ヘッダーの表示モード	デフォルト
export const HEADER_MODE_DISPPAT = 1; //ヘッダーの表示モード	患者情報
export const DEF_KUR_MAX = 10; //クール最大値
export const DEF_DAY_MAX = 21; //日付最大値

//シャント位置定義 '0':両方、'1':左、'2':右、'3':なし、'-':不明
export const DEF_SHUNT_BOTH = "0";
// const DEF_SHUNT_LEFT = "1";
// const DEF_SHUNT_RIGHT = "2";
export const DEF_SHUNT_NONE = "3";
export const DEF_SHUNT_UNKNOWN = "-";

//使用不可フラグ定義
export const DEF_DISABLED = "1"; //使用不可
//const DEF_ENABLED = "0"; //使用可

//対応可否フラグ定義
export const DEF_UNSUPPORTED = "0"; //未対応
export const DEF_SUPPORTED = "1"; //対応

//治療モード(device_mode)定義
export const DEF_DM_HD = "0"; //HD
export const DEF_DM_ECUM = "1"; //ECUM
export const DEF_DM_HDF = "2"; //HDF
export const DEF_DM_HF = "3"; //HF
export const DEF_DM_HD_HO = "4"; //HD+補液
export const DEF_DM_ECUM_HO = "5"; //ECUM+補液
export const DEF_DM_AFBF = "6"; //AFBF
export const DEF_DM_OHDF = "7"; //OHDF
export const DEF_DM_OHF = "8"; //OHF
export const DEF_DM_PURIFICATION = "9"; //特殊浄化
export const DEF_DM_IHDF = "10"; //I-HDF
export const DEF_DM_UNKNOWN = "-1"; //不明
// export const TMPKURNUM = (async function() {
//   const gstate = {};
//   await ApiHelper.get("/scheduleList/getKurData", {
//     // ここにクエリパラメータを指定する
//     facilityCd: 900001
//   })
//     //成功した場合の処理
//     .then(response => {
//       // console.log(`response.data.length:${response.data.length}`);
//       //クール一覧の取得
//       gstate.dimKurData = response.data;
//       //クール数の取得
//       gstate.kurNum = response.data.length;
//       //クール名配列の作成
//       gstate.dimKurName = new Array(gstate.kurNum);
//       for (let k = 0; k < gstate.kurNum; k++) {
//         gstate.dimKurName[k] = response.data[k].kurName;
//       }
//       // for (let index = 0; index < response.data.length; index++) {
//       //   //console.log("state.dimKurName["+index+"]:" + state.dimKurName[index]) ;
//       // }

//       // catchでエラー時の挙動を定義する
//       // console.log(`gstate.kurNum:${gstate.kurNum}`);
//     })
//     .catch(() => {
//       //	        console.log('err:', err);
//     });
//   console.log(`gstate.kurNum:${gstate.kurNum}`);
//   return gstate.kurNum;
// })();

export default {
  namespaced: true,
  strict: false,

  state: {
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe start
    dispUserTime: null,
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe end
    readFlags: [DEF_DAY_MAX + 1], //読み込み済みフラグ(2次元配列[day][kur])
    readDoneCounter: 0, //読み込み済みカウンター ひとつのクールコンポーネントがベッドコンポーネントをすべて読み込んだらカウントアップ
    readDoneFlag: false, //読み込み済みフラグ すべてのクールコンポーネントがベッドコンポーネントをすべて読み込んだらTrue
    maxBedNum: -1, //最大ベッド数
    kurNum: 0, //クール数
    dayNum: 0, //日付数
    progressratio: 0, //画面表示進捗率 (単位:%)
    namesetting: false, //表示条件設定:姓名の表示非表示フラグ(true:姓のみ表示 false:姓名表示)
    unmatchsetting: false, //表示条件設定:不一致の表示非表示フラグ(true:不一致表示(名前の前に全角!) false:不一致表示しない)
    plansetting: false, //表示条件設定:予定ありの表示非表示フラグ(true:予定あり表示(名前の後ろに半角*) false:予定あり表示しない)
    plansettingMainteWater: false, //表示条件設定:定期点検・水質検査予定ありの表示非表示フラグ(true:予定あり表示(名前の後ろに■) false:予定あり表示しない)
    dispdata: {}, //表示ベッドデータJson key:yyyymmdd
    numJson: {}, //最大ベッド数、クール数、日付数の格納用
    startTime: null, //内部的評価用:処理時間測定用 開始時間
    endTime: null, //内部的評価用:処理時間測定用 終了時間
    dataload: false, //Store初期化時のデータ読み込み済みフラグ(true:全データ読み込み済み)
    dataloadFinishedCount: 0, //Store初期化時のデータ読み込み済みカウンター
    makeDoneFlag: false, //オール空きベッドデータを作成したかのフラグ(true:作成済み)
    moveStatus: "", //ベッドへの移動(割当)ステータス
    moveDataJson: {}, //移動データ
    dimKurData: [], //クールデータ一覧
    dimKurName: [], //クール名一覧
    dimRoomBedGroupData: [], //ベッドグループ一覧
    dimRoomBedGroupMap: [], //ベッドグループ名一覧
    defaultMsg: HEADER_DEFAULT_MSG, //ヘッダーのデフォルト表示文字列
    headerDispMode: HEADER_MODE_DEFAULT, //ヘッダーの表示モード	1:患者情報 2:デフォルトメッセージ
    selectedPatInfo: {}, //選択された患者の情報
    facilityCd: "", //施設コード
    bedElemIdInfo: [], //ベッドの要素ID(配列。ヘッダー情報変更判定用) [0]日付[1]クール [2]ベッド
    bedElemIdInfoBlock: [], //ベッドの要素ID(配列。ヘッダー情報変更判定用) [0]日付[1]クール
    bedElemIdInfoForDelete: [], //ベッドの要素ID(配列。削除用) [0]日付 [1]クール [2]ベッド
    bedInfo: {}, //selected bed information
    bedInfoKur: {},
    bedInfoDim: {}, //各ベッドの不一致判定用の情報 キー:ベッドコード
    bedInfoIndex: {}, //各ベッドの順番情報 キー:ベッドコード 順番:0
    bedNamesDim: [], //各ベッドの名称情報 ベッドindex順に格納
    bedCdDim: [], //各ベッドのコード情報 ベッドindex順に格納
    bedDispDim: [], //各ベッドの表示非表示情報 ベッドindex順に格納 配列内容: true:表示
    bedDispNum: 0, //各ベッドの表示非表示情報 ベッドindex順に格納 配列内容: true:表示
    dayDispDim: [], //各日付の表示非表示情報 日付index順に格納 配列内容: true:表示
    bedDispCount: 0, //表示ベッド数
    waitFlag: false, //ベッド最大値取得待ちフラグ
    opaSwitch: "",
    treatDateDim: [], //日付格納用 基底0 ※日付コンポーネントのIDの基底は1なので、参照時注意
    kurMaxWaitFlag: false, //クール最大値取得待ちフラグ
    headerSelectionFlag: false, //ヘッダー領域の操作ボタンの操作状態フラグ true:ボタンが押された
    holidayDispStateFlag: true, //休日表示フラグ
    systemFlagShowMsgAtUnmatch: true, //システムのフラグ:不一致時のメッセージ表示フラグ true:表示
    // その他予定の有無(検査依頼、放射線検査依頼、患者イベント)
    otherSchedule: null,
    /** 帳票に渡すパラメータ */
    reportParam: {
      fromDate: null,
      toDate: null
    },
    patEvents: [],
    examRequests: [],
    // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 start
    selectKurCd: "",  //選択のクールCD
    dimKurCd: [], //クールCD
    // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 end
    radRequests: [],
    // tmpKurNum: TMPKURNUM
    // tmpKurNum: function() {
    //   const gstate = this.state;
    //   ApiHelper.get("/scheduleList/getKurData", {
    //     // ここにクエリパラメータを指定する
    //     facilityCd: 900001
    //   })
    //     //成功した場合の処理
    //     .then(response => {
    //       console.log(`response.data.length:${response.data.length}`);
    //       //クール一覧の取得
    //       gstate.dimKurData = response.data;
    //       //クール数の取得
    //       gstate.kurNum = response.data.length;
    //       //クール名配列の作成
    //       gstate.dimKurName = new Array(gstate.kurNum);
    //       for (let k = 0; k < gstate.kurNum; k++) {
    //         gstate.dimKurName[k] = response.data[k].kurName;
    //       }
    //       // for (let index = 0; index < response.data.length; index++) {
    //       //   //console.log("state.dimKurName["+index+"]:" + state.dimKurName[index]) ;
    //       // }

    //       // catchでエラー時の挙動を定義する
    //       console.log(`gstate.kurNum:${gstate.kurNum}`);
    //       return gstate.kurNum;
    //     })
    //     .catch(() => {
    //       //	        console.log('err:', err);
    //     });
    // }.bind(this)()
    // add FNSI-改修内容フィルタ条件設定 房 start
    savefilter: [],
    // add FNSI-改修内容フィルタ条件設定 房 end
    // FNSI-add 現行改善対応425 孫灝 20201117 start
    facilitySetting1007: "",
    // 施設設定マスタにNo７の「検査依頼」に選択肢「４」を選択して、手動選択した値
    facilitySetting1007_4SelectedVal: 1,
    facilitySetting1008: "",
    // 施設設定マスタにNo8の「一般撮影検査依頼」に選択肢「４」を選択して、手動選択した値
    facilitySetting1008_4SelectedVal: 1,
    // 検査依頼変更締切り有無 1015
    facilitySettingExamChangeOnOffWithOrder: "",
    // 検査依頼変更締切り日数 1011
    facilitySettingExamScheduleChangeLimitDay: "",
    // 検査依頼変更締切り時間 1012
    facilitySettingExamScheduleChangeLimitTime: "",
    // 一般撮影検査依頼変更締切り有無 1016
    facilitySettingRadChangeOnOffWithOrder: "",
    // 放射線検査依頼変更締切り日数 1013
    facilitySettingRadScheduleChangeLimitDay: "",
    // 放射線検査依頼変更締切り時間 1014
    facilitySettingRadScheduleChangeLimitTime: "",
    // FNSI-add 現行改善対応425 孫灝 20201117 end

    // add FNSI 1006 No.426 start --孙灏 20201215
    facilitySetting3005: "",
    // 施設設定マスタにNo105の「患者イベント変更機能」に選択肢「４」を選択して、手動選択した値
    facilitySetting3005_4SelectedVal: 2,
    // add FNSI 1006 No.426 end --孙灏 20201215
    // FNSI-add 現行改善対応425 徐 start
    examStatus: false,
    //9273 start
    examResult: false,
    //9273 end
    //add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
    radStatus: false,
    //add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
    // FNSI-add 現行改善対応425 徐 end
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
    scrollLeftWitch: null,
    scrollTopWitch: null,
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
    isPatientEnabled:false,
    isScheduleEnabled:false,
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end

  },

  mutations: {
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe start
    setDispUserTime(state, dispUserTime) {
      state.dispUserTime = dispUserTime;
    },
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe end
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
    setScrollLeftWitch: (state, scrollLeftWitch) => {
      state.scrollLeftWitch = scrollLeftWitch;
    },
    setScrollTopWitch: (state, scrollTopWitch) => {
      state.scrollTopWitch = scrollTopWitch;
    },
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
    setFlag: (state, indexJson) => {
      //		console.log("in store indexJson:" + JSON.stringify(indexJson)) ;
      const dimIndex = indexJson.id.split("-");
      state.readFlags[dimIndex[0]][dimIndex[1]] = true;
      ++state.readDoneCounter;
      //		console.log("in store state.readDoneCounter:" + state.readDoneCounter) ;
      if (state.readDoneCounter === state.kurNum * state.dayNum) {
        //						console.log("display finished!!");
        state.endTime = performance.now();

        //						console.log("time:"+ (state.endTime - state.startTime) + "msec")
        state.readDoneFlag = true;
        //次に備えて初期化
        state.readDoneCounter = 0;
        for (let d = 1; d <= DEF_DAY_MAX; d++) {
          state.readFlags[d] = new Array(DEF_KUR_MAX + 1);
          for (let k = 0; k <= DEF_KUR_MAX; k++) {
            state.readFlags[d][k] = false;
          }
        }
      }
    },
    setDoneNum: (state, jsonStr) => {
      //		console.log("in store jsonStr.:" + jsonStr) ;

      if (state.startTime === null) {
        state.startTime = performance.now();
      }
      //const indexDim = jsonStr.id.split("-");
      //		console.log("in store indexDim[0]:" + indexDim[0] + " indexDim[1]:" + indexDim[1]) ;
      const nowNum = jsonStr.num;
      //		console.log("in store nowNum:" + nowNum) ;
      state.progressratio = Math.floor((nowNum * 100) / state.maxBedNum);
      //		console.log("in store %:" + state.progressratio +"%") ;
    },
    /**
     * ベッド情報設定処理
     * @param ベッド情報(Json)
     */
    setDispDataToStore: (state, setJson) => {
      //		console.log("setNameSetting called!!") ;
      state.dispdata = setJson;
    },
    /**
     * 表示条件設定:予定あり表示フラグ設定処理
     * @param 設定値 true:予定あり(名前の後ろに半角*)表示
     */
    setPlanSetting: (state, setting) => {
      //		console.log("setNameSetting called!!") ;
      state.plansetting = setting;
    },
    /**
     * 表示条件設定:定期点検・水質検査予定あり表示フラグ設定処理
     * @param 設定値 true:予定あり(名前の後ろに■)表示
     */
    setPlanSettingMainteWater: (state, setting) => {
      state.plansettingMainteWater = setting;
    },
    /**
     * 表示条件設定:不一致表示フラグ設定処理
     * @param 設定値 true:不一致記号(名前の前に全角!)表示
     */
    setUnmatchSetting: (state, setting) => {
      //		console.log("setNameSetting called!!") ;
      state.unmatchsetting = setting;
    },
    /**
     * 点滅設定処理
     * @param 設定値 "on/off-日付index-クールindex"(日付indexのみの場合あり)
     */
    setOpaSwitch: (state, setting) => {
      state; //未使用変数の書式チェック回避行(特に何もしない)。機能復帰時には念の為コメントアウトする
      setting; //未使用変数の書式チェック回避行(特に何もしない)。機能復帰時には念の為コメントアウトする
      //コメントアウト 5/22 一時的に機能OFF
      //開放する時は、下の行を開放 stateとsettingをコメントアウト(そのままでも問題ない)
      // state.opaSwitch = setting;
    },
    /**
     * データ読み込みフラグの設定
     * @param value true:読み込み済み false:未読込
     */
    setDataLoadFlag: (state, value) => {
      state.dataload = value;
    },
    /**
     * 表示条件設定:名前(姓のみ)表示フラグ設定処理
     * @param 設定値 true:姓のみ表示
     */
    setNameSetting: (state, setting) => {
      //		console.log("setNameSetting called!!") ;
      state.namesetting = setting;
    },
    /**
     * 表示条件設定:休日表示フラグ設定処理
     * @param 設定値 true:休日を表示
     */
    setHolidayDispStateFlag: (state, setting) => {
      // console.log("setHolidayDispStateFlag called");
      state.holidayDispStateFlag = setting;
    },
    checkData: (state, treatDate) => {
      const checkStr = typeof state.dispdata[treatDate];
      //		console.log("checkData called!! checkStr:<" + checkStr + ">") ;
      if (checkStr === "undefined") {
        //			console.log('データがない!!') ;
      }
    },
    /**
     * ヘッダー情報の設定
     */
    setHeaderInfo: (state, jsonStr) => {
      //this.dbgPrint("store:setHeaderInfo called!!");

      state.selectedPatInfo = jsonStr; //患者情報の設定

      //ヘッダーの表示モード	1:患者情報 2:デフォルトメッセージ
      state.headerDispMode =
        jsonStr === null ? HEADER_MODE_DEFAULT : HEADER_MODE_DISPPAT;
    },
    /**
     * ベッド情報の設定
     */
    setBedIdDim: (state, dimStr) => {
      state.bedElemIdInfo = dimStr; //ベッドID(要素のID)のセットの配列
    },
    /**
     * ヘッダー領域の操作ボタンのON/OFF状態の設定
     */
    setHeaderSelectionFlag: (state, boolVal) => {
      state.headerSelectionFlag = boolVal; //ヘッダー領域の操作ボタンフラグを設定
    },
    /**
     * ベッド情報の設定
     */
    setBedIdDimBlock: (state, dimStr) => {
      // console.log(`store:setBedIdDimBlock called!! dimStr:${dimStr}`);

      state.bedElemIdInfoBlock = dimStr; //クールID(要素のID)のセットの配列
    },
    /**
     * ベッド情報の設定(削除用)
     */
    setBedIdDimForDelete: (state, dimStr) => {
      const bedIdex = state.bedElemIdInfoForDelete.length;
      const tmpDimStr = JSON.parse(JSON.stringify(dimStr));
      state.bedElemIdInfoForDelete.splice(bedIdex, 1, tmpDimStr); //ベッドID(要素のID)のセット
    },
    /**
     * ベッド情報の設定(削除用)
     */
    resetBedIdDimForDelete: state => {
      state.bedElemIdInfoForDelete = []; //ベッドID(要素のID)のリセット
    },
    /**
     * Watch発火の為、表示ベッド数の初期化を行う
     */
    resetBedDispCount: state => {
      state.bedDispCount = 0;
    },
    /**
     * ベッド情報の設定(表示用)
     * @param dimStr ベッドグループindex配列
     */
    setBedDispInfo: (state, dimStr) => {
      //表示フラグの初期化
      for (let i = 0; i < state.bedDispDim.length; i++) {
        state.bedDispDim.splice(i, 1, false);
      }

      let dimBedCd = [];
      //ベッドグループ情報からbed_cd情報一覧を作成
      if (dimStr === "all") {
        //すべてのベッドグループ
        // for (let k = 0; k < state.dimRoomBedGroupData.length; k++) {
        //   dimBedCd = dimBedCd.concat(
        //     JSON.parse(state.dimRoomBedGroupData[k].bedList)
        //   );
        // }
      } else {
        //含まれるグループ
        //すべてのベッドグループ
        let roomBedGroup = state.dimRoomBedGroupData.find(rbr => rbr.roomBedGroupCd === dimStr);
        if (roomBedGroup) {
          dimBedCd = dimBedCd.concat(
            JSON.parse(roomBedGroup.bedList)
          );
        }
      }

      if (dimStr !== "all") {
        //表示フラグの設定
        for (let i = 0; i < dimBedCd.length; i++) {
          //mod 7837 ベッドグループに接続装置が登録していないベッドが含まれていると別のベッドを抽出する20221111 赵 start
          //state.bedDispDim.splice(state.bedInfoIndex[dimBedCd[i]], 1, true);
          if (state.bedInfoIndex[dimBedCd[i]] != null) {
            state.bedDispDim.splice(state.bedInfoIndex[dimBedCd[i]], 1, true);
          }
          //mod 7837 ベッドグループに接続装置が登録していないベッドが含まれていると別のベッドを抽出する20221111 赵 end
        }
      } else {
        for (let i = 0; i < state.bedDispDim.length; i++) {
          state.bedDispDim.splice(i, 1, true);
        }
      }

      //trueに設定されている要素の数を最終的に確認
      let dispCounter = 0;
      for (let i = 0; i < state.bedDispDim.length; i++) {
        if (state.bedDispDim[i]) {
          ++dispCounter;
        }
      }
      state.bedDispCount = dispCounter;
    },
    /**
     *セル情報のクリア処理
     *@param dimIndex   [0]日付index [1]クールindex [2]ベッドindex
     */
    setClearPatInfoOnBed: (state, dimIndexCells) => {
      for (let i = 0; i < dimIndexCells.length; i++) {
        const dimIndex = dimIndexCells[i];
        const targetDate = state.treatDateDim[dimIndex[0] - 1];
        const targetJson =
          state.dispdata[targetDate][dimIndex[1] - 1].beddata[dimIndex[2]];

        //以下の項目情報以外を空文字にする
        //"No"
        //"kur_cd"
        //"bed_cd"
        //"kur_name"
        //"treatDate"

        //処理対象外のプロパティ文字列一覧
        const excludeKeys = ["No", "kur_cd", "bed_cd", "kur_name", "treatDate"];

        for (const key in targetJson) {
          if (excludeKeys.indexOf(key) === -1) {
            targetJson[key] = "";
          }
        }
      }
    },
    /**
     *セル情報の入れ替え処理(ベッド確定領域同士)
     *@param indexJson
     *キー:From [0]日付index [1]クールindex [2]ベッドindex
     *キー:To   [0]日付index [1]クールindex [2]ベッドindex
     */
    swapCellInfo: (state, indexJson) => {
      const dimIndexFrom = indexJson.From;
      const dimIndexTo = indexJson.To;
      //一時退避(deep copy)
      const treatDateTo = state.treatDateDim[dimIndexTo[0] - 1];
      let tmpTo =
        state.dispdata[treatDateTo][dimIndexTo[1] - 1].beddata[dimIndexTo[2]];
      tmpTo = JSON.parse(JSON.stringify(tmpTo));
      const treatDateFrom = state.treatDateDim[dimIndexFrom[0] - 1];
      let tmpFrom =
        state.dispdata[treatDateFrom][dimIndexFrom[1] - 1].beddata[
        dimIndexFrom[2]
        ];
      tmpFrom = JSON.parse(JSON.stringify(tmpFrom));

      //元のままの(入れ替えない)情報を設定
      //"No"
      //"kur_cd"
      //"bed_cd"
      //"kur_name"
      //"treatDate"

      //Toの情報を退避
      const tmpTo_No = tmpTo.No;
      const tmpTo_kur_cd = tmpTo.kur_cd;
      const tmpTo_bed_cd = tmpTo.bed_cd;
      const tmpTo_kur_name = tmpTo.kur_name;
      const tmpTo_treatDate = tmpTo.treatDate;
      //Fromの情報をToに設定
      tmpTo.No = tmpFrom.No;
      tmpTo.kur_cd = tmpFrom.kur_cd;
      tmpTo.kur_name = tmpFrom.kur_name;
      tmpTo.bed_cd = tmpFrom.bed_cd;
      tmpTo.treatDate = tmpFrom.treatDate;
      //退避していたToの情報をFromに設定
      tmpFrom.No = tmpTo_No;
      tmpFrom.kur_cd = tmpTo_kur_cd;
      tmpFrom.kur_name = tmpTo_kur_name;
      tmpFrom.bed_cd = tmpTo_bed_cd;
      tmpFrom.treatDate = tmpTo_treatDate;
      if (tmpTo.isDummy === "1" && tmpTo.pat_id === tmpFrom.pat_id) {
        tmpTo = {
          No: tmpFrom.No,
          bed_cd: tmpFrom.bed_cd,
          hospPatId: "",
          inOutClass: "",
          kur_cd: tmpTo.kur_cd,
          kur_name: tmpTo.kur_name,
          patFirstName: "",
          patLastName: "",
          title: "",
          treatDate: tmpFrom.treatDate
        }
      }
      //データ入れ替え
      state.dispdata[treatDateTo][dimIndexTo[1] - 1].beddata[
        dimIndexTo[2]
      ] = tmpFrom;
      state.dispdata[treatDateFrom][dimIndexFrom[1] - 1].beddata[
        dimIndexFrom[2]
      ] = tmpTo;
    },
    /**
     *ベッド未登録領域への値のセット
     *@param setJson
     *  setIndex [0]日付index [1]クールindex
     *  setBedJson ベッドJson配列 [null,{},{}・・・{}]
     */
    setBedNotYet: (state, setJson) => {
      const dayIndex = setJson.setIndex[0];
      const kurIndex = setJson.setIndex[1];
      const targetTreatDate = state.treatDateDim[dayIndex - 1];
      //deep copy
      state.dispdata[targetTreatDate][kurIndex - 1].bedNotYet = JSON.parse(
        JSON.stringify(setJson.setBedJson)
      );
    },
    /**
     *クール未領域への値のセット
     *@param setJson
     *  setIndex [0]日付index
     *  setKurJson ベッドJson配列 [null,{},{}・・・{}]
     */
    setKurNotYet: (state, setJson) => {
      const dayIndex = setJson.setIndex[0];
      const targetTreatDate = state.treatDateDim[dayIndex - 1];
      //deep copy
      state.dispdata[targetTreatDate][state.kurNum].beddata = JSON.parse(
        JSON.stringify(setJson.setKurJson)
      );
    },
    /**
     * ヘッダー情報の設定
     */
    setBedInfoForBlock: (state, jsonStr) => {
      // console.log(`setBedInfoForBlock called!! jsonStr:${jsonStr}`);

      for (const key in jsonStr) {
        // console.log(`${key}:${jsonStr[key]}`);
        state.bedInfoKur[key] = jsonStr[key];
        state.bedInfoKur = JSON.parse(JSON.stringify(state.bedInfoKur));
      }
    },
    /**
     * ヘッダー情報の設定
     */
    setBedInfoForHeader: (state, jsonStr) => {
      //this.dbgPrint("store:setBedInfoForHeader called!!");

      if (state.bedInfo !== jsonStr) {
        state.bedInfo = jsonStr; //ベッドの患者の設定
      } else {
        //同じだったら作り直して代入(watchが反応するようにするため)
        state.bedInfo = JSON.parse(JSON.stringify(jsonStr));
      }
    },
    /**
     * その他の予定データリストの設定
     */
    setOtherSchedule: (state, listData) => {
      state.otherSchedule = listData;
    },
    /** 帳票用パラメータの設定 */
    setReportParam: (state, json) => {
      state.reportParam = json;
    },
    setPatEvents: (state, list) => {
      state.patEvents = list;
    },
    setExamRequests: (state, list) => {
      state.examRequests = list;
    },
    setRadRequests: (state, list) => {
      state.radRequests = list;
    },
    // add FNSI-改修内容フィルタ条件設定 房 start
    setSaveFilterData: (state, list) => {
      state.savefilter = list;
    },
    // add FNSI-改修内容フィルタ条件設定 房 end
    // FNSI-add 現行改善対応425 孫灝 20201118 start
    setFacilitySetting1007_4SelectedVal: (state, newVal) => {
      state.facilitySetting1007_4SelectedVal = newVal;
    },
    setFacilitySetting1008_4SelectedVal: (state, newVal) => {
      state.facilitySetting1008_4SelectedVal = newVal;
    },
    // FNSI-add 現行改善対応425 孫灝 20201118 end
    // add FNSI 1006 No.426 start --孙灏 20201215
    setFacilitySetting3005_4SelectedVal: (state, newVal) => {
      state.facilitySetting3005_4SelectedVal = newVal;
    },
    // add FNSI 1006 No.426 end --孙灏 20201215
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
    setIsPatientEnabled: (state, newVal) => {
      state.isPatientEnabled = newVal;
    },
    setIsScheduleEnabled: (state, newVal) => {
      state.isScheduleEnabled = newVal;
    }
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
  },
  /**********************************************************************************************
   * GETTERS
   ********************************************************************************************* */
  getters: {
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe start
    getDispUserTime(state) {
      return state.dispUserTime;
    },
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe end
    /**
     * ダミー作成情報
     * @param paramJson
     *      kurIndex  確認対象のクールのindex(1～)
     *      treatTime 治療時間(分)
     */
    getDummyInfo: state => paramJson => {
      const retDimIndex = [];
      let indexCounter = 0;
      const kurIndex = paramJson.kurIndex;
      const treatTime = paramJson.treatTime;

      retDimIndex[indexCounter++] = paramJson.kurIndex;

      //治療開始時刻(クールの標準治療開始時刻を採用)
      const kurStandardStartTime =
        state.dimKurData[kurIndex - 1].kurStandardStartTime;

      //治療開始時刻(秒)
      const startFromSecond =
        Number(kurStandardStartTime.substring(0, 2) * 3600) +
        Number(kurStandardStartTime.substring(2, 4) * 60) +
        Number(kurStandardStartTime.substring(4, 6));

      //治療終了時刻(秒)
      const endTreatTimeSecond = Number(startFromSecond) + treatTime * 60;

      //メインスケジュールのクールの次のクールから確認
      let baseTimeSec = 0;
      let continueFlag = true;
      for (let i = kurIndex + 1; i <= state.kurNum; i++) {
        //クールの開始時刻
        const startTime = state.dimKurData[i - 1].kurStartTime;
        //クールの開始時刻(秒)
        const startSecond =
          Number(startTime.substring(0, 2) * 3600) +
          Number(startTime.substring(2, 4) * 60) +
          Number(startTime.substring(4, 6));
        //クールの終了時刻
        const endTime = state.dimKurData[i - 1].kurEndTime;
        //クールの終了時刻(秒)
        const endSecond =
          Number(endTime.substring(0, 2) * 3600) +
          Number(endTime.substring(2, 4) * 60) +
          Number(endTime.substring(4, 6));

        if (startFromSecond <= startSecond && endSecond <= endTreatTimeSecond) {
          //クールが範囲に入っているのでダミーが発生します
          retDimIndex[indexCounter++] = i;
        } else {
          //処理終了
          continueFlag = false;
          break;
        }
      }

      while (continueFlag) {
        baseTimeSec += 24 * 3600;

        for (let i = 1; i <= state.kurNum; i++) {
          //クールの開始時刻
          const startTime = state.dimKurData[i - 1].kurStartTime;
          //クールの開始時刻(秒)
          const startSecond =
            Number(baseTimeSec) +
            Number(startTime.substring(0, 2) * 3600) +
            Number(startTime.substring(2, 4) * 60) +
            Number(startTime.substring(4, 6));
          //クールの終了時刻
          const endTime = state.dimKurData[i - 1].kurEndTime;
          //クールの終了時刻(秒)
          const endSecond =
            Number(baseTimeSec) +
            Number(endTime.substring(0, 2) * 3600) +
            Number(endTime.substring(2, 4) * 60) +
            Number(endTime.substring(4, 6));

          if (
            startFromSecond <= startSecond &&
            endSecond <= endTreatTimeSecond
          ) {
            //クールが範囲に入っているのでダミーが発生します
            retDimIndex[indexCounter++] = i;
          } else {
            //処理終了
            continueFlag = false;
            break;
          }
        }
      }

      return retDimIndex;
    },
    /**
     * 表示条件設定:休日表示フラグ取得
     */
    getHolidayDispStateFlag: state => state.holidayDispStateFlag,
    /**
     * システム設定:不一致時の確認メッセージの表示非表示のフラグ取得
     */
    getSystemSettingUnmatchShowMsgFlag: state =>
      state.systemFlagShowMsgAtUnmatch,
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    getExamStatus: state =>
      state.examStatus,
    getRadStatus: state =>
      state.radStatus,
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    /**
     * クール数の取得
     */
    getOpaSwitch: state => state.opaSwitch,
    /**
     * クールコードの取得
     * @index クールのindex(1～)
     */
    getKurCd: state => index => {
      return state.dimKurData[index - 1].kurCd;
    },
    /**
     * 表示ベッド数の取得
     */
    getBedDispCount: state => state.bedDispCount,
    /**
     * クール数の取得
     */
    getMaxKurNum: state => state.kurNum,
    /**
     * ベッド数の取得
     */
    getMaxBedNum: state => state.maxBedNum,
    /**
     * データ読み込み状態の取得
     */
    getStatus: state => state.readDoneFlag,
    /**
     * ヘッダー領域の操作状態の取得
     */
    getHeaderSelection: state => state.headerSelectionFlag,
    /**
     * データ読み込み進捗率の取得
     */
    getProgress: state => state.progressratio,
    /**
     * 不一致表示フラグ取得処理
     * @return	true:不一致表示 false:不一致非表示
     */
    unmatchSetting: state => state.unmatchsetting,
    /**
     * 予定あり表示フラグ取得処理
     * @return	true:予定あり表示 false:予定あり非表示
     */
    planSetting: state => state.plansetting,
    /**
     * 定期点検・水質検査予定あり表示フラグ取得処理
     * @return  true:予定あり表示 false:予定あり非表示
     */
    plansettingMainteWater: state => state.plansettingMainteWater,
    /**
     * 姓名表示フラグ取得処理
     * @return	true:姓のみ表示 false:姓名表示
     */
    nameSetting: state => state.namesetting,
    /**
     * 不一致チェック
     * 以下の項目の不一致チェックを行う
     * 1.シャント方向
     * 2.感染症有無
     * 3.治療モード
     * @param jsonData
     *    kur_cd
     *    bed_cd
     *    target_bed_cd 移動予定先のbed_cd
     *    vaDirect
     *    isInfect
     *    deviceMode
     * @return true:不一致あり false:不一致なし
     */
    getUnmatchInfo: state => jsonData => {
      // console.log(`kur_cd:${jsonData.kur_cd}`);
      // console.log(`bed_cd:${jsonData.bed_cd}`);
      // console.log(`target_bed_cd:${jsonData.target_bed_cd}`);
      // console.log(`vaDirect:${jsonData.vaDirect}`);
      // console.log(`isInfect:${jsonData.isInfect}`);
      // console.log(`deviceMode:${jsonData.deviceMode}`);

      const checkBaseJson = state.bedInfoDim[jsonData.target_bed_cd];

      const retJson = {};

      //シャント方向の不一致チェック
      retJson.shuntFlag = true; //true:一致

      const patVaDirect = jsonData.vaDirect; //患者のシャント方向

      //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx start
      // const bedVaDirect = String(checkBaseJson.shunt_position ? checkBaseJson.shunt_position : ""); //ベッドのシャント方向
      const bedVaDirect = String(checkBaseJson?.shunt_position); //ベッドのシャント方向

      //現行ソースのロジック:SchComparision.cs
      // if (
      //   null === patVaDirect ||
      //   "" === patVaDirect ||
      //   null === bedVaDirect ||
      //   "" === bedVaDirect ||
      //   bedVaDirect === patVaDirect
      // ) {
      //   // ①どちらかあるいは両方null(or空文字)、または一致する場合、一致
      //   retJson.shuntFlag = true;
      // }
      // else if (
      //   DEF_SHUNT_NONE === patVaDirect ||
      //   DEF_SHUNT_UNKNOWN === patVaDirect ||
      //   DEF_SHUNT_NONE === bedVaDirect ||
      //   DEF_SHUNT_UNKNOWN === bedVaDirect
      // ) {
      //   // ②どちらかがシャント位置「なし」、「不明」の場合は、不一致
      //   retJson.shuntFlag = false;
      // } else if (
      //   DEF_SHUNT_BOTH === patVaDirect ||
      //   DEF_SHUNT_BOTH === bedVaDirect
      // ) {
      //   // ③どちらかがシャント位置「両方」の場合、一致
      //   retJson.shuntFlag = true;
      // } else {
      //   // ④その他、不一致
      //   retJson.shuntFlag = false;
      // }
      if (!patVaDirect || patVaDirect === "undefined" || !bedVaDirect || bedVaDirect === "undefined") {
        retJson.shuntFlag = true;
      }else if (DEF_SHUNT_NONE == patVaDirect || DEF_SHUNT_NONE == bedVaDirect) {
        // 3:無
        retJson.shuntFlag = true;
      }else if (DEF_SHUNT_UNKNOWN == patVaDirect) {
        // -:不明
        retJson.shuntFlag = false;
      }else if (bedVaDirect != patVaDirect) {
        retJson.shuntFlag = false;
      }
      //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx end

      //感染症有無の不一致チェック
      //this.infectionFlag = true; //true:一致

      //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx start
      // retJson.infectionFlag = checkBaseJson.is_infection === jsonData?.isInfect;
      // retJson.infectionFlag = checkBaseJson?.is_infection === jsonData?.isInfect;
      //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx end
      //mod #11923 スケジュール表でベッド未登録に移動すると、感染症＆治療方法不一致メッセージが表示される zrx start
      retJson.infectionFlag = !checkBaseJson?.is_infection ? true : checkBaseJson.is_infection === jsonData?.isInfect;
      //mod #11923 スケジュール表でベッド未登録に移動すると、感染症＆治療方法不一致メッセージが表示される zrx end

      //治療モードの不一致チェック
      retJson.deviceModeFlag = true; //true:一致

      // if (DEF_DISABLED === checkBaseJson.is_disable) {
      if (!checkBaseJson || DEF_DISABLED === checkBaseJson.is_disable) {
        //使用不可なのでチェックする必要なく、不一致
        retJson.deviceModeFlag = false;
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
        retJson.deviceModeFlag =
          deviceModeSupport[jsonData.deviceMode] === DEF_SUPPORTED;
      }
      //add #11923 スケジュール表でベッド未登録に移動すると、感染症＆治療方法不一致メッセージが表示される zrx start
      if(!jsonData.target_bed_cd) {
        retJson.infectionFlag = true
        retJson.deviceModeFlag = true
      }
      //add #11923 スケジュール表でベッド未登録に移動すると、感染症＆治療方法不一致メッセージが表示される zrx end
      // retJson.shuntFlag = true;
      // retJson.infectionFlag = true;
      // retJson.deviceModeFlag = true;
      retJson.unmatchFlag = !(
        retJson.shuntFlag &&
        retJson.infectionFlag &&
        retJson.deviceModeFlag
      );
      return retJson;
    },
    /**
     *セル情報の取得処理
     *1.セル情報(単独) 全index値がある場合(length=3)
     *2.クール情報(クールブロック) ベッドindex値以外がある場合(length=2)
     *3.日付情報(日付ブロック) 日付index値のみがある場合(length=1)
     *@param dimIndex   [0]日付index [1]クールindex [2]ベッドindex
     */
    getPatBedInfo: state => dimIndex => {
      //日付indexから日付文字列を取得(基底は0,日付indexの基底は1)
      // const treatDate = state.treatDateDim[dimIndex[0] - 1];

      //該当日付のデータを取得
      // const dispdata = state.dispdata[treatDate];

      //該当クールデータ(ベッド一覧)を取得(基底は0,クールindexの基底は1)
      // const dispdataKur = dispdata[dimIndex[1] - 1].beddata;

      //ベッドデータ(患者情報込み)を取得(基底は1,ベッドindexの基底は1)
      //const dispdataBedwzPat = dispdataKur[dimIndex[2]]

      let dispdataBedwzPat = null;
      //まとめると
      if (3 === dimIndex.length) {
        //1セル分のデータ
        dispdataBedwzPat =
          state.dispdata[state.treatDateDim[dimIndex[0] - 1]][dimIndex[1] - 1]
            .beddata[dimIndex[2]];
      } else if (2 === dimIndex.length) {
        //1クール分のデータ(ベッドデータの配列) 確定領域+ベッド未登録領域
        dispdataBedwzPat = {};
        dispdataBedwzPat.commitAreaData =
          state.dispdata[state.treatDateDim[dimIndex[0] - 1]][
            dimIndex[1] - 1
          ].beddata;
        dispdataBedwzPat.bedNotYetAreaData =
          state.dispdata[state.treatDateDim[dimIndex[0] - 1]][
            dimIndex[1] - 1
          ].bedNotYet;
      } else if (1 === dimIndex.length) {
        //1日付分のデータ(クールデータの配列) 確定領域+ベッド未登録領域+クール未登録領域
        const kurnum =
          state.dispdata[state.treatDateDim[dimIndex[0] - 1]].length - 1;

        dispdataBedwzPat = new Array(kurnum + 1);
        for (let i = 0; i < kurnum; i++) {
          const tmp = {};
          tmp.commitAreaData =
            state.dispdata[state.treatDateDim[dimIndex[0] - 1]][i].beddata;
          tmp.bedNotYetAreaData =
            state.dispdata[state.treatDateDim[dimIndex[0] - 1]][i].bedNotYet;
          dispdataBedwzPat[i] = tmp;
        }
        dispdataBedwzPat[kurnum] =
          state.dispdata[state.treatDateDim[dimIndex[0] - 1]][kurnum].beddata;
      }
      return dispdataBedwzPat;
    },
    /**
     * 指定した日付のデータの取得
     * treatdate: yyyymmdd
     */
    getBedsData: state => treatdate => {
      //console.log("getData called!! param treatdate:<" + treatdate + ">") ;
      const checkStr = typeof state.dispdata[treatdate];
      //console.log("getData called!! checkStr:<" + checkStr + ">") ;
      if (checkStr === "undefined") {
        if (state.makeDoneFlag) {
          //読み込み終了で、データがないので、空きデータを返却します
          //TODO:設定変更で過去分を参照した場合、DBアクセスは未なので、あらたに取得を試みる
          // console.log(
          //   `空きデータ返却:${treatdate}:${JSON.stringify(
          //     state.dispdata.allspacebedsdata
          //   )}`
          // );
          state.dispdata[treatdate] = state.dispdata.allspacebedsdata;
        } else {
          //データがない状態(この状態はないが、ハンドリングしておく)
          return null;
        }
      }
      //指定日付のデータ返却
      return state.dispdata[treatdate];
    },
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
    getScrollLeftWitch: state => {
      return state.scrollLeftWitch
    },
    getScrollTopWitch: state => {
      return state.scrollTopWitch
    },
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
    /**
     * 指定したベッドの不一致チェック用情報取得
     * bedCd: ベッドコード
     */
    getBedUnmatchCheckInfo: state => bedCd => {
      //仮実装:返却データ構造決定のため

      // if (!([bedCd] in state.bedInfoDim)) {
      //   //デフォルト
      //   const retJson = {};
      //   retJson.vaDirect = "3"; //シャント方向  mst_bedから取得
      //   retJson.isInfection = "0"; //感染症フラグ  mst_bedから取得
      //   retJson.isDisable = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportHd = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportEcum = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportHdf = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportHf = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportHdHo = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportEcumHo = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportAfbf = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportOhdf = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportOhf = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得
      //   retJson.isSupportIHdf = "1"; //使用不可フラグ  mst_bed経由でmst_machineから取得

      //   //格納
      //   state.bedInfoDim[bedCd] = retJson;
      // }
      return state.bedInfoDim[bedCd];
    },
    /**
     * 指定したベッドindexのベッド名を取得
     * index: ベッドindex(0基底)
     */
    getBedName: state => index => {
      return state.bedNamesDim[index];
    },
    /**
     * 指定したベッドindexのベッドコードを取得
     * index: ベッドindex(1基底)
     */
    getBedCd: state => index => {
      return state.bedCdDim[index - 1];
    },
    /**
     * 指定した日付indexの日付表示状態を取得
     * index: 日付index(0基底)
     */
    getDayDispState: state => index => {
      if (index < 0) {
        return true;
      } else {
        return state.dayDispDim[index];
      }
    },
    /**
     * 日付表示状態を取得
     */
    getDayDispIndex: state => {
      // for (let i = 0; i < state.dayDispDim.length; i++) {
      //   state.dayDispDim.splice(i, 1, false);
      // }

      return state.dayDispDim;
    },
    /**
     * 指定したベッドindexの表示状態を取得
     * index: ベッドindex(0基底)
     */
    getBedDispState: state => index => {
      return state.bedDispDim[index];
    },
    /**
     * 最大ベッド数、クール数、日付数の取得
     */
    getConfigJson: state => state.numJson,
    /**
     * データ読み込みフラグの取得
     */
    getDataLoadedFlag: state => state.dataload,
    /**
     * クール名の取得
     */
    getKurNames: state => state.dimKurName,
    /**
     * ベッドグループ名の取得
     */
    getRoomBedGroupMap: state => state.dimRoomBedGroupMap,
    // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm start
    /**
     * ベッドグループ一覧の取得
     */
    getRoomBedGroupData: state => state.dimRoomBedGroupData,
    // add 9972 ベッドの条件を絞った状態のスケジュール表から治療記録画面を表示させると患者検索には全ベッドで抽出される zkm end
    /**
     * ヘッダーのデフォルトメッセージの取得
     */
    getHeaderDefaultMsg: state => state.defaultMsg,
    /**
     * ヘッダーの表示モードの取得
     */
    getHeaderDispMode: state => state.headerDispMode,
    /**
     * 選択された患者の情報の取得
     */
    getHeaderDispInfo: state => state.selectedPatInfo,
    /**
     * 選択されたベッド要素のIdの取得(要素数値配列)
     */
    getBedElemIdInfo: state => state.bedElemIdInfo,
    /**
     * 選択されたベッド要素のIdの取得(要素数値配列)
     */
    getBedElemIdInfoBlock: state => state.bedElemIdInfoBlock,
    /**
     * 選択されたベッドの情報の取得(Json)
     */
    getBedInfo: state => state.bedInfo,
    /**
     * 選択されたベッドの情報の取得(Json)
     */
    getBedInfoKur: state => state.bedInfoKur,
    /**
     * 選択されたベッドの情報(削除対象)の取得(Json)
     */
    getBedElemIdInfoForDelete: state => state.bedElemIdInfoForDelete,
    /**
     * その他の予定データリストの取得
     */
    getOtherSchedule: state => state.otherSchedule,

    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
    /**
     * 「全部」ベッドのIDの取得(Json)
     */
    getAllBedCds: state => state.bedCdDim,

    getSelectKurCds: state => state.dimKurCd,
    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end

    /** 帳票用パラメータの取得 */
    getReportParamFromDate: state => state.reportParam.fromDate,
    /** 帳票用パラメータの取得 */
    getReportParamToDate: state => state.reportParam.toDate,
    /** 帳票用パラメータの取得 */
    getReportParams: state => {
      return {
        // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 start
        selectKurCd: state.dimKurCd,
        // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 end
        // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        //facilityCd: state.facilityCd,
        //fromDate: moment(state.treatDateDim[0]).format("YYYY/MM/DD"),
        // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
        // toDate: moment(state.treatDateDim[state.treatDateDim.length - 1]).format("YYYY/MM/DD"),
        // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
        //date: moment(state.treatDateDim[0]).format("YYYY/MM/DD")
        // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
      };
    },
    getExamRequests: state => state.examRequests,
    getRadRequests: state => state.radRequests,
    getPatEvents: state => state.patEvents,
    hasExamRequests: state => strDate => {
      let exam = false;
      for (const item of state.examRequests) {
        if (moment(item.regExamDate).format('YYYYMMDD') === strDate) {
          exam = true;
          break;
        }
      }

      return exam;
    },
    hasRadRequests: state => strDate => {
      let rad = false;
      for (const item of state.radRequests) {
        if (moment(item.regRadDate).format('YYYYMMDD') === strDate) {
          rad = true;
          break;
        }
      }

      return rad;
    },
    hasPatEvents: state => strDate => {
      let startDate, endDate;
      const treatDate = moment(strDate, "YYYYMMDD");
      return state.patEvents.some(item => {
        startDate = moment(item.eventStartDate)
          .hours(0)
          .minutes(0)
          .seconds(0)
          .milliseconds(0);
        endDate = moment(item.eventEndDate)
          .add(1, "d")
          .hours(0)
          .minutes(0)
          .seconds(0)
          .milliseconds(0);

        return (
          treatDate.isSameOrAfter(startDate) &&
          (treatDate.isBefore(endDate) || item.eventEndDate === null)
        );
      });
    },
    // add FNSI-改修内容フィルタ条件設定 房 start
    getSaveFilterData: state => state.savefilter,
    // add FNSI-改修内容フィルタ条件設定 房 end
    //9273 start
    getExamResult: state => state.examResult,
    //9273 end
    // FNSI-add 現行改善対応425 孫灝 20201117 start
    getFacilitySetting1007: state => state.facilitySetting1007,
    getFacilitySetting1007_4SelectedVal: state => state.facilitySetting1007_4SelectedVal,
    getFacilitySetting1008: state => state.facilitySetting1008,
    getFacilitySetting1008_4SelectedVal: state => state.facilitySetting1008_4SelectedVal,

    // 検査依頼変更締切り有無 1015
    getFacilitySettingExamChangeOnOffWithOrder: state => state.facilitySettingExamChangeOnOffWithOrder,
    // 検査依頼変更締切り日数 1011
    getFacilitySettingExamScheduleChangeLimitDay: state => state.facilitySettingExamScheduleChangeLimitDay,
    // 検査依頼変更締切り時間 1012
    getFacilitySettingExamScheduleChangeLimitTime: state => state.facilitySettingExamScheduleChangeLimitTime,
    // 一般撮影検査依頼変更締切り有無 1016
    getFacilitySettingRadChangeOnOffWithOrder: state => state.facilitySettingRadChangeOnOffWithOrder,
    // 放射線検査依頼変更締切り日数 1013
    getFacilitySettingRadScheduleChangeLimitDay: state => state.facilitySettingRadScheduleChangeLimitDay,
    // 放射線検査依頼変更締切り時間 1014
    getFacilitySettingRadScheduleChangeLimitTime: state => state.facilitySettingRadScheduleChangeLimitTime,
    // FNSI-add 現行改善対応425 孫灝 20201117 end

    // add FNSI 1006 No.426 start ---孙灏 20201215
    getFacilitySetting3005: state => state.facilitySetting3005,
    getFacilitySetting3005_4SelectedVal: state => state.facilitySetting3005_4SelectedVal,
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
    getIsPatientEnabled: state => state.isPatientEnabled,
    getIsScheduleEnabled: state => state.isScheduleEnabled,
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
    // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
    // add FNSI 1006 No.426 end ---孙灏 20201215
    // FNSI-add 現行改善対応425 徐 start
    // checkExamAndRad: state => params => {
    //   if (params.checkFlg === "exam") {
    //     if (state.facilitySetting1007 == 4
    //       && params.fromTreatDate != params.toTreatDate) {
    //         return true;
    //      } else if (state.facilitySetting1007 != 4
    //       && state.facilitySettingExamChangeOnOffWithOrder === "1"
    //       && params.fromTreatDate != params.toTreatDate) {
    //         if (Number(params.fromTreatDate) < Number(moment().add(state.facilitySettingExamScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //           return true;
    //         } else if (Number(params.fromTreatDate) === Number(moment().add(state.facilitySettingExamScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //           const newDate = new Date();
    //           const hour = newDate.getHours();
    //           const minutes = newDate.getMinutes();
    //           const formatTime = String(hour) + String(minutes);
    //           if (Number(state.facilitySettingExamScheduleChangeLimitTime.replace(":", "")) <= Number(formatTime)) {
    //             return true;
    //           } else {
    //             if (state.examStatus) {
    //               return true;
    //             }
    //           }
    //         } else {
    //           if (state.examStatus) {
    //             return true;
    //           }
    //         }
    //       } else if (state.facilitySetting1007 != 4
    //       && state.facilitySettingExamChangeOnOffWithOrder !== "1"
    //       && params.fromTreatDate != params.toTreatDate) {
    //         if (state.examStatus) {
    //           return true;
    //         }
    //       }
    //   }
    //
    //   if (params.checkFlg === "rad") {
    //     if (state.facilitySetting1008 == 4
    //     && params.fromTreatDate != params.toTreatDate) {
    //       return true;
    //     } else if (state.facilitySetting1008 != 4
    //     && params.fromTreatDate != params.toTreatDate
    //     && state.facilitySettingRadChangeOnOffWithOrder === "1") {
    //       if (Number(params.fromTreatDate) < Number(moment().add(state.facilitySettingRadScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //         return true;
    //       } else if (Number(params.fromTreatDate) === Number(moment().add(state.facilitySettingRadScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //         const newDate = new Date();
    //           const hour = newDate.getHours();
    //           const minutes = newDate.getMinutes();
    //           const formatTime = String(hour) + String(minutes);
    //         if (Number(state.facilitySettingRadScheduleChangeLimitTime.replace(":", "")) <= Number(formatTime)) {
    //           return true;
    //         }
    //       }
    //     }
    //   }
    //   return false;
    // },
    // // FNSI-add 現行改善対応425 徐 end
    //add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
    // checkExamAndRadHas: state => params => {
    //   //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。start zhao
    //   if(params.fromTreatDate != params.toTreatDate){
    //     //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。end zhao
    //     if (params.checkFlg === "exam") {
    //       if (state.examStatus) {
    //         if (state.facilitySetting1007 == 4
    //           && params.fromTreatDate != params.toTreatDate) {
    //           return true;
    //         }
    //       }
    //     }
    //
    //     if (params.checkFlg === "rad") {
    //       if (state.radStatus) {
    //         if (state.facilitySetting1008 == 4
    //           && params.fromTreatDate != params.toTreatDate) {
    //           return true;
    //         }
    //       }
    //     }
    //     //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。start zhao
    //   }
    //   //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。end zhao
    //   return false;
    // },
    //
    // checkExamAndRadEndHas: state => params => {
    //   //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。start zhao
    //   if(params.fromTreatDate != params.toTreatDate){
    //     //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。end zhao
    //     if (params.checkFlg === "exam") {
    //       if (state.examStatus) {
    //         if (Number(params.fromTreatDate) < Number(moment().add(state.facilitySettingExamScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //           return true;
    //         } else if (Number(params.fromTreatDate) === Number(moment().add(state.facilitySettingExamScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //           const newDate = new Date();
    //           const hour = newDate.getHours();
    //           const minutes = newDate.getMinutes();
    //           const formatTime = String(hour) + String(minutes);
    //           if (Number(state.facilitySettingExamScheduleChangeLimitTime.replace(":", "")) <= Number(formatTime)) {
    //             return true;
    //           }
    //         }
    //       }
    //
    //     }
    //     if (params.checkFlg === "rad") {
    //       if (state.radStatus) {
    //         if (Number(params.fromTreatDate) < Number(moment().add(state.facilitySettingRadScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //           return true;
    //         } else if (Number(params.fromTreatDate) === Number(moment().add(state.facilitySettingRadScheduleChangeLimitDay, "days").format("YYYYMMDD"))) {
    //           const newDate = new Date();
    //           const hour = newDate.getHours();
    //           const minutes = newDate.getMinutes();
    //           const formatTime = String(hour) + String(minutes);
    //           if (Number(state.facilitySettingRadScheduleChangeLimitTime.replace(":", "")) <= Number(formatTime)) {
    //             return true;
    //           }
    //         }
    //       }
    //     }
    //     //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。start zhao
    //   }
    //   //add 7646 ????患者で透析を行った後、そのベッドは条件送信済みの状態になる。end zhao
    //   return false;
    // },
    //add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
    checkDeadline: state => params => {
      if (params.checkFlg == "exam" && state.examStatus
        && state.facilitySettingExamChangeOnOffWithOrder == "1"
        && params.fromTreatDate != params.toTreatDate) {
        let deadline = Number(moment().add(state.facilitySettingExamScheduleChangeLimitDay, "days").format("YYYYMMDD"));
        if (Number(params.fromTreatDate) < deadline || Number(params.toTreatDate) < deadline) {
          return true;
        } else if (Number(params.fromTreatDate) == deadline || Number(params.toTreatDate) == deadline) {
          const newDate = new Date();
          const hour = newDate.getHours();
          const minutes = newDate.getMinutes();
          const formatTime = String(hour) + String(minutes);
          if (Number(state.facilitySettingExamScheduleChangeLimitTime.replace(":", "")) <= Number(formatTime)) {
            //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
            deadline = Number(moment().add(state.facilitySettingExamScheduleChangeLimitDay + 1, "days").format("YYYYMMDD"));
            if (Number(params.fromTreatDate) < deadline || Number(params.toTreatDate) < deadline) {
              return true;
            }
          } else {
            deadline = Number(moment().add(state.facilitySettingExamScheduleChangeLimitDay, "days").format("YYYYMMDD"));
            if (Number(params.fromTreatDate) < deadline || Number(params.toTreatDate) < deadline) {
              return true;
            }
          }
        }
      }
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      if (params.checkFlg == "rad" && state.radStatus
        && state.facilitySettingRadChangeOnOffWithOrder == "1"
        && params.fromTreatDate != params.toTreatDate) {
        let deadline = Number(moment().add(state.facilitySettingRadScheduleChangeLimitDay, "days").format("YYYYMMDD"));
        if (Number(params.fromTreatDate) < deadline || Number(params.toTreatDate) < deadline) {
          return true;
        } else if (Number(params.fromTreatDate) == deadline || Number(params.toTreatDate) == deadline) {
          const newDate = new Date();
          const hour = newDate.getHours();
          const minutes = newDate.getMinutes();
          const formatTime = String(hour) + String(minutes);
          if (Number(state.facilitySettingRadScheduleChangeLimitTime.replace(":", "")) <= Number(formatTime)) {
            //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
            deadline = Number(moment().add(state.facilitySettingRadScheduleChangeLimitDay + 1, "days").format("YYYYMMDD"));
            if (Number(params.fromTreatDate) < deadline || Number(params.toTreatDate) < deadline) {
              return true;
            }
          } else {
            deadline = Number(moment().add(state.facilitySettingRadScheduleChangeLimitDay, "days").format("YYYYMMDD"));
            if (Number(params.fromTreatDate) < deadline || Number(params.toTreatDate) < deadline) {
              return true;
            }
          }
        }
      }
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    },


  },
  /**********************************************************************************************
   * ACTIONS
   ********************************************************************************************* */
  actions: {
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe start
    setDispUserTime({ commit }, dispUserTime) {
      commit("setDispUserTime", dispUserTime);
    },
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe end
    // FNSI-add 現行改善対応425 徐 start
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    async getPatExamMain({ state }, { patId, treatDate }) {
      let examStatus = false;
      store.dispatch("loading-screen/setLoadingScreenVisible", true);
      let response = await ApiHelper.post(
        `/exam/TreatDateListByIsOrder/${patId}/${treatDate}/${treatDate}`
      )
      store.dispatch("loading-screen/setLoadingScreenVisible", false);
      if (response.data.length > 0) {
        examStatus = true;
      }
      state.examStatus = examStatus;
    },
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    // //9273 start
    // async getPatExamMainResult ({ state }, {patId, fromTreatDate, toTreatDate}) {
    //   let examResult = false
    //   store.dispatch("loading-screen/setLoadingScreenVisible", true);
    //   let response = await ApiHelper.post(
    //     `/exam/TreatDateList/${patId}/${fromTreatDate}/${toTreatDate}`
    //   )
    //   store.dispatch("loading-screen/setLoadingScreenVisible", false);
    //   if (response.data) {
    //     response.data.forEach((items) => {
    //       if (items.examStatus == "1") {
    //         examResult = true;
    //       }
    //     });
    //   }
    //   state.examResult = examResult;
    // },
    // //9273 end
    //add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    async getPatRadMain({ state }, { patId, treatDate }) {
      let radStatus = false;
      store.dispatch("loading-screen/setLoadingScreenVisible", true);
      let response = await ApiHelper.post(
        `/rad/TreatDateListByIsOrder/${patId}/${treatDate}/${treatDate}`
      )
      store.dispatch("loading-screen/setLoadingScreenVisible", false);
      if (response.data.length > 0) {
        radStatus = true;
      }
      state.radStatus = radStatus;
    },
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    //add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
    // mod #9273 施設設定マスタのNo105の設定どおり動かない。 dou end

    // FNSI-add 現行改善対応425 徐 end
    setHeaderSelectionFlag({ commit }, boolVal) {
      commit("setHeaderSelectionFlag", boolVal);
    },
    setBedIdDim({ commit }, dimStr) {
      commit("setBedIdDim", dimStr);
    },
    setBedDispInfo({ commit }, dimStr) {
      commit("setBedDispInfo", dimStr);
    },
    setBedIdDimBlock({ commit }, dimStr) {
      commit("setBedIdDimBlock", dimStr);
    },
    setBedIdDimForDelete({ commit }, dimStr) {
      commit("setBedIdDimForDelete", dimStr);
    },
    setClearPatInfoOnBed({ commit }, dimIndex) {
      commit("setClearPatInfoOnBed", dimIndex);
    },
    swapCellInfo({ commit }, dimIndexJson) {
      commit("swapCellInfo", dimIndexJson);
    },
    setBedNotYet({ commit }, dimIndexJson) {
      commit("setBedNotYet", dimIndexJson);
    },
    setKurNotYet({ commit }, dimIndexJson) {
      commit("setKurNotYet", dimIndexJson);
    },
    setFlag({ commit }, index) {
      commit("setFlag", index);
    },
    setHeaderInfo({ commit }, jsonStr) {
      commit("setHeaderInfo", jsonStr);
    },
    setDoneNum({ commit }, jsonStr) {
      commit("setDoneNum", jsonStr);
    },
    setUnmatchSetting({ commit }, str) {
      commit("setUnmatchSetting", str);
    },
    setPlanSetting({ commit }, str) {
      commit("setPlanSetting", str);
    },
    setPlanSettingMainteWater({ commit }, str) {
      commit("setPlanSettingMainteWater", str);
    },    
    setNameSetting({ commit }, str) {
      commit("setNameSetting", str);
    },
    setOpaSwitch({ commit }, str) {
      commit("setOpaSwitch", str);
    },
    setBedInfoForBlock({ commit }, jsonStr) {
      commit("setBedInfoForBlock", jsonStr);
    },
    setBedInfoForHeader({ commit }, jsonStr) {
      commit("setBedInfoForHeader", jsonStr);
    },
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao start
    setScrollLeftWitch({ commit }, scrollLeftWitch) {
      commit("setScrollLeftWitch", scrollLeftWitch);
    },
    setScrollTopWitch({ commit }, scrollTopWitch) {
      commit("setScrollTopWitch", scrollTopWitch);
    },
    //add 6441 スケジュール表のベッドグループ，スクロール位置がデフォルト設定の位置に戻る zhao end
    /**
     * 帳票パラメータのクールの設定処理
     */
    // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 start
    async setReportParamKurCd({ state }, value) {
      const optionElems = value.split(":");
      state.dimKurCd = new Array(optionElems.length);
      let i = 0;
      for (const option of optionElems) {
        state.dimKurCd[i] = state.dimKurData[option - 1].kurCd;
        i = i + 1;
      }
    },


    // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 end
    /**
     * ベッドとクールとベッドグループの設定処理
     */
    async setBedAndKurInfo({ state }, response) {
      //クール一覧の取得
      state.dimKurData = response.data.kur;
      //クール数の取得
      state.kurNum = response.data.kur.length;
      // console.log(`state.kurNum:${state.kurNum}`);
      //クール名配列の作成
      state.dimKurName = new Array(state.kurNum);
      // FNSI-add 現行改善対応425 孫灝 20201117 start TODO:
      state.facilitySetting1007 = response.data.setting1007;
      state.facilitySetting1008 = response.data.setting1008;

      // 検査依頼変更締切り有無 1015
      state.facilitySettingExamChangeOnOffWithOrder = response.data.examChangeOnOffWithOrder;
      // 検査依頼変更締切り日数 1011
      state.facilitySettingExamScheduleChangeLimitDay = response.data.examScheduleChangeLimitDay;
      // 検査依頼変更締切り時間 1012
      state.facilitySettingExamScheduleChangeLimitTime = response.data.examScheduleChangeLimitTime;
      // 一般撮影検査依頼変更締切り有無 1016
      state.facilitySettingRadChangeOnOffWithOrder = response.data.radChangeOnOffWithOrder;
      // 放射線検査依頼変更締切り日数 1013
      state.facilitySettingRadScheduleChangeLimitDay = response.data.radScheduleChangeLimitDay;
      // 放射線検査依頼変更締切り時間 1014
      state.facilitySettingRadScheduleChangeLimitTime = response.data.radScheduleChangeLimitTime;
      // FNSI-add 現行改善対応425 孫灝 20201117 end

      // add FNSI 1006 No.426 start --孙灏 20201215
      state.facilitySetting3005 = response.data.setting3005;
      // add FNSI 1006 No.426 end --孙灏 20201215

      for (let k = 0; k < state.kurNum; k++) {
        state.dimKurName[k] = state.dimKurData[k].kurName;
      }
      // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 start
      //クールCD配列の作成
      state.dimKurCd = new Array(state.kurNum);
      for (let k = 0; k < state.kurNum; k++) {
        state.dimKurCd[k] = state.dimKurData[k].kurCd;
      }
      // add FNSI-仕様追加 画面の表示条件の通り帳票出力 夏 end
      //-------------------------------------------
      //ベッド数最大値を格納
      state.maxBedNum = response.data.bed.length;

      //ベッド名配列の初期化
      state.bedNamesDim = new Array(state.maxBedNum);
      //ベッド名配列の初期化
      state.bedCdDim = new Array(state.maxBedNum);
      //ベッド表示フラグ配列の初期化
      state.bedDispDim = new Array(state.maxBedNum);

      //取得情報の格納
      //add 7837 スケジュール表, ベッドグループ・透析室マスタ 20221019 赵 start
      state.bedInfoIndex = {};
      //add 7837 スケジュール表, ベッドグループ・透析室マスタ 20221019 赵 end
      for (let i = 0; i < state.maxBedNum; i++) {
        const bedData = response.data.bed[i];
        const key = bedData.bed_cd;
        //ベッドデータの格納
        state.bedInfoDim[key] = bedData;
        //ベッドデータの格納
        state.bedInfoIndex[key] = i;
        //ベッド名の格納
        state.bedNamesDim[i] = bedData.bed_name;
        //ベッド名の格納
        state.bedCdDim[i] = bedData.bed_cd;
        //ベッド表示情報の設定
        state.bedDispDim[i] = true;
      }

      //ベッドグループ一覧の取得
      state.dimRoomBedGroupData = response.data.roombedgroup;
      //ベッドグループ名配列の作成
      state.dimRoomBedGroupMap = new Array(state.dimRoomBedGroupData.length);
      for (let k = 0; k < state.dimRoomBedGroupData.length; k++) {
        state.dimRoomBedGroupMap[k] = { bedCd: state.dimRoomBedGroupData[k].roomBedGroupCd, bedName: state.dimRoomBedGroupData[k].roomBedGroupName };
      }
    },
    /**
     * スケジュール情報の更新
     * ord_scheduleの該当レコードを更新する
     * @param payload Json
     *    ordNo         :オーダー番号(絞り込み条件)
     *    patId         :患者ID
     *    condTreatDate :治療日(絞り込み条件)
     *    facilityCd    :施設コード(絞り込み条件)
     *    newTreatDate  :治療日(更新項目)
     *    kurCd         :クールコード(更新項目)
     *    bedCd         :ベッドコード(更新項目)
     */
    async updateScheduleInfoOnDB({ state }, payload) {

      const param = {
        // ここにクエリパラメータを指定する
        ordNo: payload.ordNo,
        patId: payload.patId,
        condTreatDate: payload.condTreatDate,
        facilityCd: payload.facilityCd,
        newTreatDate: payload.newTreatDate,
        kurCd: payload.kurCd,
        bedCd: payload.bedCd,
        indUserId: payload.indUserId,
        updUserId: payload.updUserId,
        // FNSI-add 現行改善対応425 孫灝 20201118 start
        facilitySetting1007SelectedVal: state.facilitySetting1007_4SelectedVal,
        facilitySetting1008SelectedVal: state.facilitySetting1008_4SelectedVal,
        // FNSI-add 現行改善対応425 孫灝 20201118 end
        // add FNSI 1006 No.426 start --孙灏 20201215
        facilitySetting3005SelectedVal: state.facilitySetting3005_4SelectedVal,
        // add FNSI 1006 No.426 end --孙灏 20201215
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        isSamePatId: payload.isSamePatId
        //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

      };

      await ApiHelper.put("/scheduleList/updateScheduleListData", param)
        //成功した場合の処理
        .then(response => {
          state.isError = 1 !== response.data.length;
          if (state.selectedPatInfo.ordNo
            && state.selectedPatInfo.ordNo === param.ordNo
            && state.selectedPatInfo.treatDate !== param.newTreatDate
          ) {
            const tmp = Object.assign({}, state.selectedPatInfo);
            tmp.treatDate = param.newTreatDate;
            state.selectedPatInfo = Object.assign({}, tmp);
          }
        })
        .catch(err => {
          err;
          state.isError = true;
        });
    },

    /**
     * ストアの初期化
     * payload:
     *  facilityCd:施設コード
     *  dayNum:日付数
     */
    async initStore({ state, dispatch, rootGetters }, payload) {
      //時間計測開始
      // const startTime = performance.now();
      // console.log(`initStore start:${startTime}`);
      state.facilityCd = payload.facilityCd;

      //API経由でデータを取得

      //データ取得フラグの初期化(各日付の各クールごとの読み取り終了確認フラグ)
      for (let d = 1; d <= DEF_DAY_MAX; d++) {
        state.readFlags[d] = new Array(DEF_KUR_MAX + 1);
        for (let k = 0; k <= DEF_KUR_MAX; k++) {
          state.readFlags[d][k] = false;
        }
      }

      //データ読み込み済みフラグ(全体) リセット(未済状態:false)
      state.dataload = false;

      //データ読み込み済み数カウンターのリセット
      state.dataloadFinishedCount = 0;

      //表示日数
      state.dayNum = payload.dayNum;

      //日付表示フラグ配列の初期化
      state.dayDispDim = new Array(state.dayNum);
      for (let i = 0; i < state.dayNum; i++) {
        state.dayDispDim[i] = true;
      }

      //表示の基準日
      let baseDate = payload.baseDate;

      //表示の基準日をmoment化
      if (!moment(baseDate).isValid()) {
        //日付が不正だったら当日からに設定
        baseDate = null;
      }
      const dt = null === baseDate ? moment() : moment(baseDate);
      //指定日を真ん中にする補正
      //例)14日出す場合、基準日の前が7日、後ろは基準日を含めて7日
      const minusDayNum = -1 * Math.floor(state.dayNum / 2);
      dt.add(minusDayNum, "days");

      // const daynum = state.dayNum;

      //-----------------------------------------------
      //日付列の作成
      // 表示日数分の日付文字列(yyyymmdd)を作成する

      // データ移動の為、余分に治療時間分のデータを保持する
      state.treatDateDim = new Array(state.dayNum + payload.overFlowDayNum);
      // 休日マスタをストアから取得
      const holidays = rootGetters["mst-holiday/getHolidays"];
      
      for (let d = 1; d <= state.dayNum + payload.overFlowDayNum; ++d) {
        //yyyymmdd形式に組み立て
        const y = dt.year();
        const m = `00${dt.month() + 1}`.slice(-2);
        const day = `00${dt.date()}`.slice(-2);
        const treatDate = y + m + day;

        state.treatDateDim[d - 1] = treatDate;

        //休日判定(moment.js 0(日)-6(土))
        // FNSI-add redmine 3898 start
        // if (0 === dt.day()) {
        //   state.dayDispDim[d - 1] = false;
        // }
        if (0 === dt.day()) {
          state.dayDispDim[d - 1] = false;
        } else {
          // 日機装施設祝日、自施設固有日、自施設祝日を休日とする
          if (holidays[moment(treatDate).format("YYYY-MM-DD")]) {
            state.dayDispDim[d - 1] = false;
          }
        }
        // FNSI-add redmine 3898 end
        //1日進める
        dt.add(1, "days");
      }

      //データ読み込み->済
      state.dataload = true;

      //設定取得用の変数に格納
      state.numJson.bed = state.maxBedNum;
      state.numJson.day = state.dayNum;
      state.numJson.kur = state.kurNum;

      //クールコンポーネントの処理済み数を0にセット
      state.readDoneCounter = 0;
      //クールコンポーネントの処理済みフラグを未済にセット
      state.readDoneFlag = false;

      //時間計測終了
      // const endTime = performance.now();
      // console.log(`initStore ed minus st time:${endTime - startTime} msec`);
    },
    /**
     * 空きベッドデータの作成処理
     */
    makeAllSpaceBedsData({ state }, jsonData) {
      //console.log('makeAllSpaceBedsData start!');
      for (let k = 0; k < jsonData.length; k++) {
        jsonData[k].numIn = 0;
        jsonData[k].numOut = 0;
        const jsonBedData = jsonData[k].beddata;

        for (let b = 1; b < jsonBedData.length; b++) {
          //				  console.log('JSON.stringify(jsonBedData['+b+']):' + JSON.stringify(jsonBedData[b]));

          jsonBedData[b].patLastName = "";
          jsonBedData[b].patFirstName = "";
          jsonBedData[b].inOutClass = "-1";
          jsonBedData[b].dialysisState = "-1";
          jsonBedData[b].treatDate = "--------";
        }

        if (typeof jsonData[k].bedNotYet !== "undefined") {
          const jsonBedNotYetData = jsonData[k].bedNotYet;
          for (let b = 1; b < jsonBedNotYetData.length; b++) {
            //					  console.log('JSON.stringify(jsonBedNotYetData['+b+']):' + JSON.stringify(jsonBedNotYetData[b]));

            jsonBedNotYetData[b].patLastName = "";
            jsonBedNotYetData[b].patFirstName = "";
            jsonBedNotYetData[b].inOutClass = "-1";
            jsonBedNotYetData[b].dialysisState = "-1";
            jsonBedNotYetData[b].treatDate = "--------";
          }
        }
      }
      state.dispdata.allspacebedsdata = jsonData;
      //console.log('makeAllSpaceBedsData finished!');
    },
    /**
     * データ存在チェック(返却)処理
     * 指定された日付のデータがストアに存在するかを確認する
     * データが存在しない場合、DBから取得する
     * @params	treatDate日付文字列(yyyymmdd)
     * @return	指定日付のデータ
     */
    async checkData({ state, dispatch }, treatDate) {
      //console.log("async checkData") ;
      const checkStr = typeof state.dispdata[treatDate];
      //console.log("checkData called checkStr:<" + checkStr + ">") ;
      if (checkStr === "undefined") {
        //データがない場合、取得(取得したものは、state.dispdata[treatDate]にセットされる)。ただし同期する(取得処理終了まで待つ)
        await dispatch("getDataFomDB", treatDate);
      }
      //最後は取得して返却
      return state.dispdata[treatDate];
      //		  return Promise.resolve(state.dispdata[treatdate]);
    },
    /**
     * デバッグ用出力
     */
    dbgPrint(msg) {
      msg;
      // console.log(msg);
    },
    /** 機能帳票受け渡し用パラメータの登録 */
    setReportParam({ commit, getters }, param) {
      let info = {
        fromDate: getters.getReportParamFromDate,
        toDate: getters.getReportParamToDate
      };
      if (param.baseDate) {
        info.fromDate = moment(param.baseDate).format("YYYYMMDD");
        if (param.dayNum) {
          let toDate = moment(param.baseDate).add(Number(param.dayNum), 'd');
          info.toDate = toDate.format("YYYYMMDD");
        }
      }
      commit("setReportParam", info);
    },
    async initPatEvents({ commit }, info) {
      store.dispatch("loading-screen/setLoadingScreenVisible", true);
      const response = await sendRequestGetPatEventRecordList(info);
      store.dispatch("loading-screen/setLoadingScreenVisible", false);
      if (response.data) {
        commit("setPatEvents", response.data);
      }
    },
    async initExamRequests({ commit }, info) {
      store.dispatch("loading-screen/setLoadingScreenVisible", true);
      const response = await sendRequestPatExamMain(info);
      store.dispatch("loading-screen/setLoadingScreenVisible", false);
      if (response.data.patExamMains) {
        commit("setExamRequests", response.data.patExamMains);
      }
    },
    async initRadRequests({ commit }, info) {
      store.dispatch("loading-screen/setLoadingScreenVisible", true);
      const response = await sendRequestPatRadMain(info);
      store.dispatch("loading-screen/setLoadingScreenVisible", false);
      if (response.data.patRadMains) {
        commit("setRadRequests", response.data.patRadMains);
      }
    },
    async setIsPatientEnabled ({ commit }, value) {
      commit("setIsPatientEnabled", value);
    },
    async setIsScheduleEnabled ({ commit }, value) {
      commit("setIsScheduleEnabled", value);
    }
  }
};
