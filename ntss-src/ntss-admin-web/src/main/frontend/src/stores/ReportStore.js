/**
 * 帳票ストア
 */
import {
  sendRequestCreatingReport,
  sendRequestCreatingReportByCd,
  sendRequestCreatingReportForBVMS,
  sendRequestCreatingReportForBVMSWithUploadFile,
  sendRequestGetMstReport,
  printReportForBVMS,
  printReportForBVMSWithUploadFile
} from "@/apis/report";
import { MstReport } from "@/models/report/MstReport";
import { MstPrinter } from "@/models/report/MstPrinter";
import store from "@/stores";
import ReportParameterDefs from "@/stores/report-parameter-defs.json";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import ons from "onsenui";
// add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
import {ApiHelper} from "@/apis/AxiosHelper";
import {
  extractFontsFromSVG,
  isFontAvailable,
  replaceUnavailableFonts,
  findFirstAvailableFont
} from "@/stores/fontUtils";
// add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
const REPORT_PARAMETER_ITEMS =
  ReportParameterDefs.report_parameter_defs.report_parameter_items;
const PRINT_ERROR_MESSAGE = "帳票の出力に失敗しました。";

const param = [
  //bvGraph
  {
    "graph1Y1From": -7.5,
    "graph1Y1To": 2.5,
    "graph1Y2From": 0,
    "graph1Y2To": 200,
    "graph2Y1From": 0,
    "graph2Y1To": 2,
    "graph2Y2From": 12,
    "graph2Y2To": 16,
    "selectedChart": "bvGraph"
  },
  //ddmGraph
  {
    "graph1Y1From": 0,
    "graph1Y1To": 2,
    "graph1Y2From": 0,
    "graph1Y2To": 100,
    "graph2Y1From": 0,
    "graph2Y1To": 2,
    "graph2Y2From": 0,
    "graph2Y2To": 800,
    "selectedChart": "ddmGraph"
  },
  //htGraph
  {
    "graph1Y1From": 10,
    "graph1Y1To": 30,
    "graph1Y2From": 0,
    "graph1Y2To": 200,
    "graph2Y1From": 0,
    "graph2Y1To": 2,
    "graph2Y2From": 12,
    "graph2Y2To": 16,
    "selectedChart": "htGraph"
  },
  //rrGraph
  {
    "graphY1From": 0,
    "graphY1To": 50,
    "selectedChart": "rrGraph"
  }
];

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 帳票マスタ
     */
    mstReports: [],
    /**
     * プリンタマスタ
     */
    mstPrinters: [],
    /**
     * プレビュー有無
     * true : プレビュー表示する.
     * false : プレビュー表示しない.
     */
    isPreview: true,
    /**
     * 帳票生成パラメータ
     */
    createReportParam: null,
    /**
     * 選択されたプリンタ情報
     */
    targetPrinter: null
  },
  mutations: {
    /**
     * 帳票マスタ情報を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} mstReports 帳票マスタ情報のリスト
     */
    setMstReports(state, mstReports) {
      state.mstReports = mstReports;
    },
    /**
     * プリンターマスタ情報を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} mstReports プリンターマスタ情報のリスト
     */
    setMstPrinters(state, mstPrinters) {
      state.mstPrinters = mstPrinters;
    },
    /**
     * プレビューフラグを設定する.
     * @param {*} state stateオブジェクト
     * @param {*} isPreview プレビューフラグ
     */
    setIsPreview(state, isPreview) {
      state.isPreview = isPreview;
    },
    /**
     * 帳票生成パラメータを設定する.
     * @param {*} state stateオブジェクト
     * @param {*} createReportParam 帳票生成パラメータ
     */
    setCreateReportParam(state, createReportParam) {
      state.createReportParam = createReportParam;
    },
    /**
     * 出力プリンタを設定する.
     *
     * @param {*} state stateオブジェクト
     * @param {*} targetPrinter 出力プリンタ(プリンタコード)
     */
    setTargetPrinter(state, targetPrinter) {
      // stateに設定
      state.targetPrinter = targetPrinter;
      // 帳票生成パラメータ内の出力プリンタも更新
      state.createReportParam.reportParam.targetPrinter = targetPrinter;
    }
  },
  actions: {
    /**
     * 帳票HTMLを取得する.
     * @param {*} commit commitオブジェクト
     * @param {*} reportParam 帳票パラメータオブジェクト
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getReportHTML({ commit }, reportParam) {
      return sendRequestCreatingReport(reportParam)
        .catch(error => {
          if (error.response.status === 400) {
            ons.notification.alert({
              title: null,
              message: PRINT_ERROR_MESSAGE
            });
            return Promise.reject(error);
          }
        });
    },
    /**
     * 帳票HTMLを取得する(レポートコード指定).
     * パラメータはあらかじめsetCreateReportParamアクションでセットしておくこと
     * @param {*} commit commitオブジェクト
     * @param {*} state stateオブジェクト
     * @param {Boolean} previewFlg プレビューフラグ
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getReportHTMLByReportCd({ commit, state }, previewFlg) {
      const reportParam = {
        ...state.createReportParam.reportParam,
        isPreview: previewFlg
      };
      return sendRequestCreatingReportByCd(
        state.createReportParam.reportCd,
        reportParam
      )
        // add #9558 機能帳票で正しく変数が引き渡されていない 高 start
        // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
        // .then(response => {
        .then(async response => {
          // mod #10633 【たくしん会】【因島】帳票のフォント問題 高 end
          // Check if response status is 200 and data is 'レイアウトがありません'
          if (response.status === 200 && response.data === 'レイアウトがありません') {
            store.dispatch("multi-modal/hideModal");
            ons.notification.alert({
              title: "エラー",
              message: response.data
            });
          }
          else if (response.status === 200 && response.data === '選択中のレイアウト用ではありません') {
            store.dispatch("multi-modal/hideModal");
            ons.notification.alert({
              title: "帳票選択エラー",
              message: response.data
            });
          }
          // add 10546 複数集計出力時にページ数の制限 gjn start
          else if (response.status === 200 && /ExceedingMaxPageSetting/.test(response.data)) {
            store.dispatch("multi-modal/hideModal");
            let mes = response.data;
            // del #12107 帳票印刷失敗通知が行われない limingzhe start
            //console.log(mes);
            // del #12107 帳票印刷失敗通知が行われない limingzhe end
            let substringAfterComma = "";
            const commaIndex = mes.indexOf(',');
            if (commaIndex !== -1) {
              substringAfterComma = mes.substring(commaIndex + 1).trim();
            }
            ons.notification.alert({
              title: "エラー",
              message: "指定の条件では帳票の最大出力ページ数を超えるため出力できません（"+ substringAfterComma +"／100 ページ）"
            });
          }
          // add 10546 複数集計出力時にページ数の制限 gjn end
          // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
          if (response.status === 200 && response.data === 'テンプレートがない') {
            store.dispatch("multi-modal/hideModal");
            ons.notification.alert({
              title: "エラー",
              message: "テンプレートが見つかりません、ご確認ください。"
            });
          }
          // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
          let responseFonts = await ApiHelper.post("/report_menu/getSysFontsConfig");
          const fontFallbackRules = responseFonts.data;
          const fonts = extractFontsFromSVG(response.data?.reportHtml)
          const fallbackMap = {}
          fonts.forEach(font => {
            if (!isFontAvailable(font) && fontFallbackRules[font]) {
              const fallbackFont = findFirstAvailableFont(fontFallbackRules[font])
              if (fallbackFont) {
                fallbackMap[font] = fallbackFont
              }
            }
          })
          if(response.data && response.data.reportHtml){
            response.data.reportHtml = replaceUnavailableFonts(response.data.reportHtml, fallbackMap);
          }
          // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
          // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
          return response; // Ensure the response is returned for further processing if needed
        })
        // add #9558 機能帳票で正しく変数が引き渡されていない 高 end
        .catch(error => {
          if (error.response.status === 400) {
            //del FSNI修正外結バッグ35 房 start
            // ons.notification.alert({
            //   title: null,
            //   message: PRINT_ERROR_MESSAGE
            // });
            //del FSNI修正外結バッグ35 房 end
            // add #12107 帳票印刷失敗通知が行われない limingzhe start
            ons.notification.alert({
              title: DIALOG_MESSAGES[12000207].title,
              message: DIALOG_MESSAGES[12000207].message
            });
            // add #12107 帳票印刷失敗通知が行われない limingzhe end
            return Promise.reject(error);
          }
          // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start
          else if (error.response.status === 500 && reportParam.dataKey.functionCd != null) {
            ons.notification.alert({
              title: DIALOG_MESSAGES["00200002"].title,
              message: DIALOG_MESSAGES["00200002"].message
            });
            return Promise.reject(error);
          }
          // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end
          //add #9113 【IES起票】データ画面にて機能帳票でブレビューを押下するとエラーがでる liuc start
          else if (error.response.status === 501) {
            store.dispatch("multi-modal/hideModal");
            ons.notification.alert({
              title: "帳票選択エラー",
              message: error.response.data
            });
          }
          //add #9113 【IES起票】データ画面にて機能帳票でブレビューを押下するとエラーがでる liuc end
        })

    },
    /**
     * getReportHTMLForBVMS
     * @param {*} state stateオブジェクト
     */
    getReportHTMLForBVMS({ state }, ordNo) {
      var reportParam = state.createReportParam;
      var dataChart = param[reportParam.selectedChart - 1];
      dataChart.ordNo = ordNo;
      dataChart.files = reportParam.files;
      dataChart.isUpload = reportParam.isUpload;

      return dataChart.isUpload
        ? sendRequestCreatingReportForBVMSWithUploadFile(dataChart["selectedChart"], dataChart)
        : sendRequestCreatingReportForBVMS(dataChart["selectedChart"], dataChart);
    },
    /**
     * printReportForBVMS
     * @param {*} state stateオブジェクト
     * @param {*} previewFlg
     */
    printReportForBVMS({ state }, previewFlg) {
      const reportParam = {
        ...state.createReportParam,
        isPreview: previewFlg
      };

      var dataChart = param[reportParam.selectedChart - 1];
      dataChart.files = reportParam.files;
      dataChart.isUpload = reportParam.isUpload;
      dataChart.targetPrinter = state.targetPrinter;

      if (dataChart.isUpload) {
        return printReportForBVMSWithUploadFile(dataChart["selectedChart"],
          {
            ...dataChart,
            ...reportParam
          }).catch(error => {
            if (error.response.status === 400) {
              ons.notification.alert({
                title: null,
                message: PRINT_ERROR_MESSAGE
              });
              return Promise.reject(error);
            }
          });
      }
      else {
        return printReportForBVMS(dataChart["selectedChart"],
          {
            ...dataChart,
            ...reportParam
          }).catch(error => {
            if (error.response.status === 400) {
              ons.notification.alert({
                title: null,
                message: PRINT_ERROR_MESSAGE
              });
              return Promise.reject(error);
            }
          });
      }
    },
    /**
     * 帳票マスタ情報を取得する.
     * @param {*} commit commitオブジェクト
     * @param {*} funcCd 機能コード
     * @param {*} autoRefreshFlag 自動更新フラグ
     */
    // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 start
    //getMstReport({ commit }, funcCd) {
      //return sendRequestGetMstReport(funcCd).then(response => {
    getMstReport({ commit }, {funcCd, printFlag, autoRefreshFlag}) {
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      if(funcCd!="01301") {
        if(funcCd == "02301"){
          // mod #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
          //printFlag = "0";
          printFlag = "1";
          // mod #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
           funcCd = "02303"
        }
     // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      return sendRequestGetMstReport(funcCd, printFlag, autoRefreshFlag).then(response => {
    // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 end
        commit(
          "setMstReports",
          response.data.mstReports.map(e => new MstReport(e))
        );
        commit(
          "setMstPrinters",
          response.data.printerInfos.map(e => new MstPrinter(e))
        );
        commit(
          "setIsPreview",
          response.data.isPreview === "1"
        )
      });
      }
    },
    /**
     * 帳票生成パラメータを設定する.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} createReportParam 帳票生成パラメータ
     */
    setCreateReportParam({ commit }, createReportParam) {
      commit("setCreateReportParam", createReportParam);
    },
    /**
     * 出力プリンタを設定する.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} targetPrinter 選択されたプリンタ情報
     */
    setTargetPrinter({ commit }, targetPrinter) {
      commit("setTargetPrinter", targetPrinter);
    },
    /**
     * プレビュー表示を設定する.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} isPreview プレビュー有無
     */
    setIsPreview({ commit }, isPreview) {
      commit("setIsPreview", isPreview);
    }
  },
  getters: {
    /**
     * 帳票マスタ情報を取得する.
     * @param {*} state stateオブジェクト
     */
    getMstReports(state) {
      return state.mstReports;
    },
    /**
     * プリンターマスタ情報を取得する.
     * @param {*} state stateオブジェクト
     */
    getMstPrinters(state) {
      return state.mstPrinters;
    },
    /**
     * プレビューフラグを取得する.
     * @param {*} state stateオブジェクト
     */
    isPreview(state) {
      // プリンターが存在しない場合はプレビューのみ
      return state.isPreview || state.mstPrinters.length === 0;
    },
    /**
     * 指定の抽出条件を取得します.
     * @param {*} state stateオブジェクト
     * @param {*} params.funcCd 機能コード
     * @param {*} params.extractionCondition 抽出条件
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getDataKey: state => params => {
      let dataKey = {};
      // dataKeyの設定 設定できる項目はすべて設定
      for (let e of Object.keys(REPORT_PARAMETER_ITEMS)) {
        const def = REPORT_PARAMETER_ITEMS[e];
        if (def && def[params.funcCd]) {
          dataKey[e] = store.getters[def[params.funcCd]];
        }
      }
      // TODO: mst_reportに指定してある引数が渡されていない場合に警告を出す
      if (params.extractionCondition) {
        params.extractionCondition.forEach((e) => {
          const def = dataKey[e];
          if (def === undefined) {
            // TODO: 警告
          }
        });
      }
      return dataKey;
    },
    /**
     * 選択されたプリンタ情報を取得する.
     *
     * @param {*} state stateオブジェクト
     * @returns プリンタ情報
     *          選択されていない場合はnullを返す.
     */
    getTargetPrinter(state) {
      return state.targetPrinter;
    },
  }
};
