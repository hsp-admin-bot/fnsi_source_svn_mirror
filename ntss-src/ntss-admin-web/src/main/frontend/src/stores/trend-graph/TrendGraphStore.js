//@ts-check

/**
 * 治療状況リスト:トレンドグラフ用ストア
 */
import {
  sendRequestGetTrendGraphList, // トレンドグラフ情報取得
  sendRequestGetTrendGraphMaster // グラフ設定項目取得
  // @ts-ignore
} from "@/apis/trend-graph";
import {
  sendRequestGetSysMonitorItem
} from "@/apis/treatment-record";
import moment from "moment";
import BigNumber from "bignumber.js";
import Vue from "vue";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { MACHINE_MODEL, NX_MACHINE_ID } from "@/constants/machineModel";

export default {
  namespaced: true,
  state: {
    // 機械室表示情報
    statusDevice: [],
    // 治療状況リストからの装置情報
    machineInfo: {
      // 装置名
      machineName: "",
      // 製造番号
      machineSerial: "",
      // 装置型式
      machineTypeCd: "",
      // 装置種別（機種）
      model: ""
      // mod FNSI-改修内容5702修正 xuty start
      , comFormatCd: ""
      // mod FNSI-改修内容5702修正 xuty end
    },
    // トレンドグラフ：項目セット
    monitorSetList: [],
    // 選択中項目セット情報
    selectedMonitorSetList: null,
    // トレンドグラフ：テンプレートセット
    templateList: [],
    // 選択中テンプレート情報
    selectedTemplate: null,
    // 画面更新指示
    filterSignal: false,
    // トレンドグラフ画面抽出条件
    condition: {
      // 表示期間：開始日
      startDate: moment().format("YYYY-MM-DD"),
      // 表示期間：終了日
      endDate: moment().format("YYYY-MM-DD"),
      // 横軸目盛
      axisScaleIndex: 0,
      // 横軸目盛
      axisScaleName: "",
      // 目盛間隔
      xAxisInterval: 1,
      // 選択テンプレートコード DRO, DAB, DAD
      selectedTemplateCd: {},
      // 選択モニタデータセットコード DRO, DAB, DAD
      selectedMonitorSetCd: {}
    },
    // モニタデータ
    monitorDataList: [],
    // グラフ表示項目データ
    graphItemDataSource: [],
    // モニター一覧表データ
    monitorDataSource: [],
    // 標準モニタデータ一式情報
    sysMonitorItems: []
  },
  actions: {
    // -----------------------------------------
    // グラフ情報取得時に必要な装置情報
    // -----------------------------------------
    /**
     * @param {any} context
     * @param {object} condInfo
     * @param {String} condInfo.machineName
     * @param {String} condInfo.machineSerial
     * @param {String} condInfo.machineTypeCd
     * @param {String} condInfo.model
     * @param {String} condInfo.comFormatCd
     */
    setMachineInfo({ commit }, condInfo) {
      commit("setMachineInfo", condInfo);
    },
    /**
     * 設定項目一覧取得
     * @param {Object} context
     * @param {Object} constValue 機種、通信フォーマット
     */
    // mod FNSI-改修内容5702修正 xuty start
    //fetchTrendGraphMaster(context, model) {
    //  return sendRequestGetTrendGraphMaster(model);
    fetchTrendGraphMaster(context, constValue) {
      return sendRequestGetTrendGraphMaster(constValue.model, constValue.comFormatCd);
    // mod FNSI-改修内容5702修正 xuty end
    },
    /**
     * 設定項目保存
     * @param {Object} param0
     * @param {Object} masterInfo
     * @param {Object} masterInfo.template
     * @param {Object} masterInfo.monitorSet
     */
    setMasterData({ commit }, masterInfo) {
      commit("setMasterData", masterInfo);
    },
    /**
     * トレンドグラフ情報取得
     * @param {Object} context
     * @param {Object} condition Condition情報
     */
    fetchTrendGraphList({ state }, condition) {
      const startDate = condition.startDate
        ? moment(condition.startDate).format("YYYYMMDD")
        : "0";
      const endDate = condition.endDate
        ? moment(condition.endDate).format("YYYYMMDD")
        : "0";
      const typeCd = state.machineInfo.machineTypeCd;
      const serial = state.machineInfo.machineSerial;
      const model = state.machineInfo.model;
      const parameter = {
        startDate: startDate,
        endDate: endDate,
        typeCd: typeCd,
        serial: serial,
        model: model
      };
      return sendRequestGetTrendGraphList(parameter);
    },

    setTrendGraphList({ commit }, monitorInfo) {
      let monitorList = [];
      for (const iterator of monitorInfo) {
        if (iterator.isDel === "1") {
          continue;
        }
        monitorList.push({
          occurDate: new Date(iterator.occur_date),
          monitorData: JSON.parse(iterator.monitor_data)
        });
      }
      if (monitorList.length > 0) {
        // 日付順でソート
        monitorList.sort((a, b) => (a.occurDate < b.occurDate ? 1 : -1));
      }
      commit("setTrendGraphList", monitorList);
    },

    /**
     * 治療状況リスト(トレンドグラフ)：抽出条件セット
     * @param {Object} context
     * @param {Object} filterObj
     */
    setTrendCondition({ commit, state }, filterObj) {
      if (!state.machineInfo) {
        return false;
      }
      // トレンドグラフ抽出条件情報をセットする
      commit("setTrendGraphCondition", {
        model: state.machineInfo.model,
        // トレンドグラフ抽出条件
        condition: filterObj
      });
    },
    /**
     * sysMonitorItemのデータを取得して表示用に成形
     */
    fetchSysMonitorItem: ({commit}) => {
      // モニタ項目
      const sysMonitorItemRequestParamDab = {
        moniDataType: NX_MACHINE_ID.DAB,
        vitalMonitorClass: null
      };
      const sysMonitorItemRequestParamDad = {
        moniDataType: NX_MACHINE_ID.DAD,
        vitalMonitorClass: null
      };
      const sysMonitorItemRequestParamDro = {
        moniDataType: NX_MACHINE_ID.DRO,
        vitalMonitorClass: null
      };
      // add FNSI-改修内容5702修正 xuty start
      const sysMonitorItemRequestParamDaya = {
        moniDataType: NX_MACHINE_ID.DRY_A,
        vitalMonitorClass: null
      };
      const sysMonitorItemRequestParamDayb = {
        moniDataType: NX_MACHINE_ID.DRY_B,
        vitalMonitorClass: null
      };
      // add FNSI-改修内容5702修正 xuty end
      Promise.all([
        sendRequestGetSysMonitorItem(
          sysMonitorItemRequestParamDab
        ),
        sendRequestGetSysMonitorItem(
          sysMonitorItemRequestParamDad
        ),
        sendRequestGetSysMonitorItem(
          sysMonitorItemRequestParamDro
        )
        // add FNSI-改修内容5702修正 xuty start
        ,sendRequestGetSysMonitorItem(
          sysMonitorItemRequestParamDaya
        ),
        sendRequestGetSysMonitorItem(
          sysMonitorItemRequestParamDayb
        )
        // add FNSI-改修内容5702修正 xuty end
      ]).then(response => {
        // モニタ項目：DAB
        const sysMonitorItemDab = response[0].data ? response[0].data : [];
        // モニタ項目：DAD
        const sysMonitorItemDad = response[1].data ? response[1].data : [];
        // モニタ項目：DRO
        const sysMonitorItemDro = response[2].data ? response[2].data : [];
        // add FNSI-改修内容5702修正 xuty start
        // モニタ項目：Day-A
        const sysMonitorItemDaya = response[3].data ? response[3].data : [];
        // モニタ項目：Day-B
        const sysMonitorItemDayb = response[4].data ? response[4].data : [];
        // add FNSI-改修内容5702修正 xuty end
        // モニタ項目の結合
        const sysMonitorItem = sysMonitorItemDab.concat(
          sysMonitorItemDad,
          sysMonitorItemDro
          // add FNSI-改修内容5702修正 xuty start
          , sysMonitorItemDaya
          , sysMonitorItemDayb
          // add FNSI-改修内容5702修正 xuty end
        );
        // 表示用モニタ項目作成
        commit("setSysMonitorItems" ,sysMonitorItem
          .filter(s => s.is_disp === "1")
          .map(s => {
            let model = null;
            let code = "0";
            // add FNSI-改修内容5702修正 xuty start
            let type = null;
            // add FNSI-改修内容5702修正 xuty end
            switch (s.moni_data_type) {
              case NX_MACHINE_ID.DAB:
                //DAB
                model = MACHINE_MODEL.DAB;
                code = s.moni_data_no.replace(NX_MACHINE_ID.DAB, "");
                break;
              case NX_MACHINE_ID.DAD:
                //DAD
                model = MACHINE_MODEL.DAD;
                code = s.moni_data_no.replace(NX_MACHINE_ID.DAD, "");
                //add FNSI redmine 5702 劉祥霖　工程が数値で表示される再改修　start
                type = NX_MACHINE_ID.DAD;
                //add FNSI redmine 5702 劉祥霖　工程が数値で表示される再改修　end
                break;
              case NX_MACHINE_ID.DRO:
                //DRO
                model = MACHINE_MODEL.DRO;
                code = s.moni_data_no.replace(NX_MACHINE_ID.DRO, "");
                break;
              // add FNSI-改修内容5702修正 xuty start
              case NX_MACHINE_ID.DRY_A:
                //DRY_A
                model = MACHINE_MODEL.DAD;
                code = s.moni_data_no.replace(NX_MACHINE_ID.DRY_A, "");
                type = NX_MACHINE_ID.DRY_A;
                break;
              case NX_MACHINE_ID.DRY_B:
                //DRY_B
                model = MACHINE_MODEL.DAD;
                code = s.moni_data_no.replace(NX_MACHINE_ID.DRY_B, "");
                type = NX_MACHINE_ID.DRY_B;
                break;
              // add FNSI-改修内容5702修正 xuty end
              default:
                break;
            }

            let withUnitName = s.moni_data_short_name;
            if (s.unit) {
              withUnitName += "[" + s.unit + "]";
            }

            // 文字列置換設定がある場合は文字扱いで左寄せ、それ以外は右寄せ
            const judgeStr = s.conv_item ? "left" : "right";
            return {
              model: model,
              code: parseInt(code, 10),
              name: s.moni_data_short_name,
              nameWithUnit: withUnitName,
              unit: s.unit,
              strItem: judgeStr,
              convItem: s.conv_item
              // add FNSI-改修内容5702修正 xuty start
              , type: type
              // add FNSI-改修内容5702修正 xuty end
            };
          })
        );
      });
    }
  },
  mutations: {
    // -----------------------------------------
    // グラフ情報取得時に必要な装置情報
    // -----------------------------------------
    setMachineInfo(state, condInfo) {
      state.machineInfo.machineName = condInfo.machineName;
      state.machineInfo.machineSerial = condInfo.machineSerial;
      state.machineInfo.machineTypeCd = condInfo.machineTypeCd;
      state.machineInfo.model = condInfo.model;
      // mod FNSI-改修内容5702修正 xuty start
      state.machineInfo.comFormatCd = condInfo.comFormatCd;
      // mod FNSI-改修内容5702修正 xuty end
    },
    setMasterData(state, masterInfo) {
      state.templateList = masterInfo.template;
      state.monitorSetList = masterInfo.monitorSet;
    },
    setTrendGraphList(state, monitorData) {
      state.monitorDataList = monitorData;
    },
    /**
     * 検索条件セット
     * @param {Object} state
     * @param {Object} payload
     * @param {String} payload.model
     * @param {Object} payload.condition
     */
    setTrendGraphCondition(state, payload) {
      // 表示期間：開始日
      state.condition.startDate = payload.condition.startDate;
      // 表示期間：終了日
      state.condition.endDate = payload.condition.endDate;
      // 横軸目盛
      state.condition.axisScaleIndex = payload.condition.axisScaleIndex;
      state.condition.axisScaleName = payload.condition.axisScaleName;
      // 目盛間隔
      state.condition.xAxisInterval = payload.condition.xAxisInterval;
      // 選択テンプレートコード DRO, DAB, DAD
      Vue.set(
        state.condition.selectedTemplateCd,
        payload.model,
        payload.condition.selectedTemplateCd
      );
      // 選択モニタデータセットコード DRO, DAB, DAD
      Vue.set(
        state.condition.selectedMonitorSetCd,
        payload.model,
        payload.condition.selectedMonitorSetCd
      );
    },
    setSysMonitorItems: (state, payload) => {
      state.sysMonitorItems = payload;
    }
  },
  getters: {
    getMachineInfo: state => state.machineInfo,
    getMonitorSetList: state => state.monitorSetList,
    getTemplateList: state => state.templateList,
    getMachineData: state => state.machineData,
    getConditionInfo: state => state.condition,
    getFilterSignal: state => state.filterSignal,
    getGraphItemList: state => state.graphItemDataSource,
    getMonitorItemDataSource: state => state.monitorDataSource,
    getMonitorDataList: state => state.monitorDataList,
    getSelectedTemplate: state => {
      const selectedTemplate = state.templateList.find(
        v =>
          v.templateCd ==
          state.condition.selectedTemplateCd[state.machineInfo.model]
      );
      if (selectedTemplate === undefined) {
        return null;
      }
      let returnTemplate = deepCopy(selectedTemplate);
      if (typeof returnTemplate.seriesInfo === "string") {
        returnTemplate.seriesInfo = JSON.parse(returnTemplate.seriesInfo);
      }
      for (let series of returnTemplate.seriesInfo) {
        if (series.limit_value_mode === "1") {
          // %指定
          const upperRate = new BigNumber(series.upper_value).div(100).plus(1);
          // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
          // const lowerRate = new BigNumber(series.upper_value)
          const lowerRate = new BigNumber(series.lower_value)
          // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
            .div(100)
            .times(-1)
            .plus(1);
          series.upper_value = new BigNumber(series.target_value)
            .times(upperRate)
            .toNumber();
          series.lower_value = new BigNumber(series.target_value)
            .times(lowerRate)
            .toNumber();
        }
      }
      return returnTemplate;
    },
    getSelectedMonitorSet: state => {
      let selectedMonitorSet = state.monitorSetList.find(
        v =>
          v.monitorSetCd ==
          state.condition.selectedMonitorSetCd[state.machineInfo.model]
      );
      if (selectedMonitorSet === undefined) {
        return null;
      }
      let returnMonitorSet = deepCopy(selectedMonitorSet);
      if (typeof returnMonitorSet.seriesInfo === "string") {
        returnMonitorSet.seriesInfo = JSON.parse(returnMonitorSet.seriesInfo);
      }
      return returnMonitorSet;
    },
    getSysMonitorItems: state => state.sysMonitorItems
  }
};
