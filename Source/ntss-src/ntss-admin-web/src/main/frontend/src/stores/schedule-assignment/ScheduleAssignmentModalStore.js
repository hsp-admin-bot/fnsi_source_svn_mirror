/**
 * スケジュール/患者割当モーダル用ストア
 */
import {
  sendRequestGetOrdMainByOrdNo,
  sendRequestGetPatList,
  sendRequestGetScheduleList,
  sendRequestPatAssignment,
  sendRequestScheduleAssignment
} from "@/apis/schedule-assignment";

import { sendRequestPatAssignmentDeviceEdges } from "@/apis/device-edge-order";
import dayjs from "@/compat/date/dayjs";
import { getScopedDocument, setScopedCookie } from "@/functions/common/LayoutMeasureHelper";
import { addPatNameSortToList } from "@/functions/SortFunctions";

export default {
  strict: true,
  namespaced: true,
  state: {
    // スケジュールグリッド用設定
    scheduleColumn: [
      {
        field: "ordNo",
        title: "オーダー番号(内部用)",
        hidden: true
      },
      {
        field: "patId",
        title: "患者ID",
        hidden: true
      },
      {
        field: "hospPatId",
        title: "患者ID",
        width: "6em"
      },
      { field: "patName", title: "患者名", width: "6em" },
      { field: "treatDate", title: "治療日", width: "6em" },
      { field: "kurName", title: "クール", width: "6em", hidden: true },
      { field: "bedName", title: "ベッド名", width: "6em", hidden: true }
    ],
    // 選択中のord_no（ord_main）
    selectOrdNo: null,
    // 選択中のord_main（スケジュール）
    selectOrdMain: null,
    // 対象のスケジュールリスト
    schedulelist: null,
    // 患者一覧
    patlist: null,
    // 患者一覧（フィルター前）
    patlistNoFilter: null,
    // 表示切替フラグ true:患者、false:スケジュール
    assignmentFlag: false,
    // 通信サーバ通知用
    requestdata: null,

    // add FNSI-？？？？患者割り当て 徐 start
    // 編集中のレコード
    structData: {},
    // add FNSI-？？？？患者割り当て 徐 end

    // 「登録」ボタン活性状態
    disabledButton: true
  },
  getters: {
    // スケジュールグリッド用列設定
    getScheduleColumn(state) {
      return state.scheduleColumn;
    },
    getSelectOrdMain(state) {
      return state.selectOrdMain;
    },
    getSchedulelist(state) {
      return state.schedulelist;
    },
    getPatlist(state) {
      return state.patlist;
    },
    getAssignmentFlag(state) {
      return state.assignmentFlag;
    },
    getRequestData(state) {
      return state.requestdata;
    },
    // add FNSI-？？？？患者割り当て 徐 start
    getStructData(state) {
      return state.structData;
    },
    // add FNSI-？？？？患者割り当て 徐 end
    getDisabledButton(state) {
      return state.disabledButton;
    }
  },
  actions: {
    // モーダル呼び出し前に表示用の情報をセット
    setSelectOrdNo({ commit }, ordNo) {
      // 選択したord_main情報をセット
      commit("setSelectOrdNo", { selectOrdNo: ordNo });
      // // 初期表示(患者)
      // commit("changeAssignmentFlag", true);
      // 初期表示(スケジュール)
      commit("changeAssignmentFlag", false);
    },
    // 表示切替フラグ変更
    changeAssignmentFlag({ commit }, flg) {
      commit("changeAssignmentFlag", flg);
    },
    setScheduleColumn({ commit }, columns) {
      // スケジュール項目列セット
      commit("setScheduleColumn", columns);
    },
    // 「登録」ボタン活性制御
    setDisabledButton({ commit }, flag) {
      commit("setDisabledButton", flag);
    },
    // add FNSI-？？？？患者割り当て 徐 start
    setStructData({ commit }, payload) {
      commit("setStructData", payload);
    },
    // add FNSI-？？？？患者割り当て 徐 end
    /**
     * ord_no指定
     * ord_main情報取得
     */
    async getOrderMainListByOrdNo({ state, commit }) {
      // ord_main情報取得
      const response = await sendRequestGetOrdMainByOrdNo(state.selectOrdNo);

      // 取得データの変換
      const data = response.data;
      // 治療日
      let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
      let tDate;
      if (data.rstStartDate !== null) {
        // 治療開始日時
        const start = new Date(data.rstStartDate);
        let weekNo = start.getDay();
        if (weekNo === 0) {
          weekNo = 7;
        }
        tDate
          = dayjs(start).format("YYYY/MM/DD")
          + "("
          + weekList[weekNo]
          + ")";
      } else {
        // 治療予定日
        tDate
          = data.treatDate.substr(0, 4)
          + "/"
          + data.treatDate.substr(4, 2)
          + "/"
          + data.treatDate.substr(6, 2)
          + "("
          + weekList[data.treatWeek]
          + ")";
      }
      data.viewTreatDate = tDate;

      // 透析時間
      let startTime = "";
      let endTime = "";
      if (data.rstStartDate !== null) {
        startTime = new Date(data.rstStartDate);
        startTime = `0${startTime.getHours()}`.slice(-2) + ":" + `0${startTime.getMinutes()}`.slice(-2);
        endTime = "透析中";
      }
      if (data.rstEndDate !== null) {
        endTime = new Date(data.rstEndDate);
        endTime = `0${endTime.getHours()}`.slice(-2) + ":" + `0${endTime.getMinutes()}`.slice(-2);
      }

      data.viewTreatTime = startTime + "～" + endTime;

      // 取得したord_main情報をセット
      commit("setSelectOrdMain", { selectOrdMain: data });
    },

    /**
     * 患者一覧取得
     */
    async requestGetPatList({ commit }) {
      // 患者一覧情報取得
      const response = await sendRequestGetPatList();
      // 取得データの変換
      let dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        array[index].patId = array[index].pat_id;
        array[index].hospPatId = array[index].hosp_pat_id;
        // add 9485 nullを空文字列判定に変換します 張玲 start
        array[index].pat_last_name = array[index].pat_last_name ? array[index].pat_last_name : "";
        array[index].pat_first_name = array[index].pat_first_name ? array[index].pat_first_name : "";
        // add 9485 nullを空文字列判定に変換します 張玲 end
        array[index].patName =
          array[index].pat_last_name + array[index].pat_first_name;
        const patLastNameKana = !array[index].pat_last_name_kana ? "" : array[index].pat_last_name_kana;
        const patFirstNameKana = !array[index].pat_first_name_kana ? "" : array[index].pat_first_name_kana;
        array[index].patNameKana = patLastNameKana + patFirstNameKana;
      });
      
      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      dataList = addPatNameSortToList(dataList);
      // デフォルトソート システム共通患者名ソート仕様 昇順
      dataList = dataList.sort((a, b) => a.patNameSort.localeCompare(b.patNameSort));

      // 取得した患者一覧情報をセット
      commit("setPatlistNoFilter", { patlist: dataList });
      commit("setPatlist", { patlist: dataList });
    },

    /**
     * 患者一覧検索
     */
     async searchPatList({ commit, state }, searchText) {
      // 取得データの変換
      if (searchText && searchText !== "") {
        const dataList = state.patlistNoFilter.filter(data => {
          return data.patName.indexOf(searchText) > -1 || (data.patNameKana && data.patNameKana.indexOf(searchText) > -1) || data.hospPatId.indexOf(searchText) > -1;
        })
        // 取得した患者一覧情報をセット
        commit("setPatlist", { patlist: dataList });
      } else {
        // 取得した患者一覧情報をセット
        commit("setPatlist", { patlist: state.patlistNoFilter });
      }
    },

    /**
     * 該当のスケジュール取得
     */
    async requestGetScheduleList({ state, commit }) {
      // 該当のスケジュール情報取得
      // mod FNSI-？？？？患者割り当て 徐 start
      /* const response = await sendRequestGetScheduleList({
        startDate: dayjs(state.selectOrdMain.rstStartDate).format("YYYYMMDD"),
        endDate: state.selectOrdMain.rstEndDate === null ? dayjs(new Date()).format("YYYYMMDD") : dayjs(state.selectOrdMain.rstEndDate).format("YYYYMMDD"),
        bedCd: state.selectOrdMain.bedCd
      });*/
      var startStartDate = state.selectOrdMain.treatDate;
      var startEndDate = state.selectOrdMain.treatDate;
      const response = await sendRequestGetScheduleList({
        startDate: startStartDate,
        endDate: startEndDate,
        bedCd: state.selectOrdMain.bedCd
      });
      // mod FNSI-？？？？患者割り当て 徐 end
      // 取得したスケジュール情報をセット
      commit("setSchedulelist", { schedulelist: response.data });
    },

    // /**
    //  * 患者割り当て
    //  */
    setPatAssignment({ state, commit }, patid) {

      // 患者割り当て処理
      return sendRequestPatAssignment({
        patId: patid,
        ordNo: state.selectOrdNo
      }).then(response => {
        // 登録成功
        if (response.status == 200) {
          // 登録失敗情報がある場合
          if (response.data.errorMessage != null) {
            // エラーメッセージ表示
            return { result: false, message: response.data.errorMessage };
          }
          // 割り当て成功
          // 通知に必要な情報登録
          commit("setRequestData", response.data.machinedata);

          return { result: true };
        } else {
          // 割り当て失敗
          return { result: false, message: response.errorMessage };
        }
      });
    },

    // /**
    //  * 患者割り当て通知
    //  */
    notificationPatAssignment({ state }) {

      // 通信サーバーへの通知が必要かどうか判定
      if (state.requestdata.isSendable === "1") {
        // 必要

        // 患者割り当て通知処理
        return sendRequestPatAssignmentDeviceEdges(state.requestdata)
          .then(response => {
            // 登録成功
            if (response.status == 200) {
              return { result: true };
            }
          })
          .catch(error => {
            if (error.response.status === 400) {
              return {
                result: false,
                message: "通信サーバーへの通知に失敗しました。"
              };
            }
          });
      } else {
        // 不要

        return { result: true };
      }
    },

    // /**
    //  * スケジュール割り当て
    //  */
    // mod FNSI-？？？？患者割り当て 徐 start
    // setScheduleAssignment({ state, commit }, ordNo) {
    setScheduleAssignment({ state, commit }, edit) {

      // add FNSI-外部連携api呼び出対応 陳 start
      var flg = "map";
      var arr, reg = new RegExp("(^| )flg@@([^;]*)(;|$)");
      const scopedDocument = getScopedDocument();
      arr = (scopedDocument?.cookie || "").match(reg);
      if (arr) {
        if (unescape(arr[2]) == 'list') {
          flg = 'list';
          setScopedCookie("flg@@map; path=/");
        }
      }
      // mod FNSI-外部連携api呼び出対応 陳 end

      // mod FNSI-？？？？患者割り当て 徐 end
      // スケジュール割り当て処理
      return sendRequestScheduleAssignment({
        baseOrdNo: edit.selOrdNo,
        // mod FNSI-？？？？患者割り当て 徐 start
        // ordNo: state.selectOrdNo
        ordNo: state.selectOrdNo,
        rstInputClass: edit.rstInputClass,
        // add FNSI-外部連携api呼び出対応 陳 start
        flg: flg
        // moaddd FNSI-外部連携api呼び出対応 陳 end
        // mod FNSI-？？？？患者割り当て 徐 end
      }).then(response => {
        // 登録成功
        // mod FNSI-？？？？患者割り当て 陳 start
        //if (response.status == 200) {
        if (response.status == 200 && response.data.errorMessage == null) {
        // mod FNSI-？？？？患者割り当て 陳 end
          // 登録失敗情報がある場合
          if (response.data.errorMessage != null) {
            // エラーメッセージ表示
            return { result: false, message: response.data.errorMessage };
          }
          // 割り当て成功
          // 通知に必要な情報登録
          commit("setRequestData", response.data.machinedata);

          return { result: true
            //add FNSI redmine 6706 劉祥霖  追加再修正：？？？？患者予定部分に投薬がないと通知しない start
            ,sendMediNoticeFlag:response.data.sendMediNoticeFlag
            //add FNSI redmine 6706 劉祥霖  追加再修正：？？？？患者予定部分に投薬がないと通知しない end
          };
        }
        // add FNSI-？？？？患者割り当て 陳 start
        else if(response.status == 200 && response.data.errorMessage !== null){

          return { result: true , message: response.data.errorMessage
            //add FNSI redmine 6706 劉祥霖  追加再修正：？？？？患者予定部分に投薬がないと通知しない start
            ,sendMediNoticeFlag:response.data.sendMediNoticeFlag
            //add FNSI redmine 6706 劉祥霖  追加再修正：？？？？患者予定部分に投薬がないと通知しない end
          };

        // add FNSI-？？？？患者割り当て 陳 end
        } else {
          // 割り当て失敗
          return { result: false, message: response.errorMessage };
        }
      });
    }
  },
  mutations: {
    // スケジュール項目列
    setScheduleColumn(state, data) {
      state.scheduleColumn = data;
    },
    // ord_no
    setSelectOrdNo(state, payload) {
      state.selectOrdNo = payload.selectOrdNo;
    },
    // ord_main
    setSelectOrdMain(state, payload) {
      state.selectOrdMain = payload.selectOrdMain;
    },
    // スケジュール一覧
    setSchedulelist(state, payload) {
      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      state.schedulelist = addPatNameSortToList(payload.schedulelist);
    },
    // 患者一覧
    setPatlist(state, payload) {
      state.patlist = payload.patlist;
    },
    // 患者一覧（フィルター前）
    setPatlistNoFilter(state, payload) {
      state.patlistNoFilter = payload.patlist;
    },
    // 表示切替フラグ変更
    changeAssignmentFlag(state, assignmentFlag) {
      state.assignmentFlag = assignmentFlag;
    },
    // 通信サーバ通知用
    setRequestData(state, data) {
      state.requestdata = data;
    },
    // add FNSI-？？？？患者割り当て 徐 start
    setStructData(state, structData) {
      state.structData = structData;
    },
    // add FNSI-？？？？患者割り当て 徐 end
    // 「登録」ボタン活性制御
    setDisabledButton(state, data) {
      state.disabledButton = data;
    }
  }
};
