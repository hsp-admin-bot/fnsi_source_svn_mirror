//@ts-check
/**
 * 治療状況リスト用ストア
 */
import {
  sendRequestGetKur,
  sendRequestGetBedMachine,
  sendRequestGetStatusLayout,
  sendRequestGetMntMachineState,
  sendRequestGetTreatmentStatusList,
  sendRequestGetAlarmList,
  sendRequestUpdateCheckAfterWeight,
  sendRequestCheckMediDone,
  sendRequestGetMstPersonalUser,
  sendRequestUpdateTreatmentStatus,
  sendRequestDeleteUnknownPatRecord,
  sendRequestGetMstMachineByOrdNoRst,
  // add FNSI-画面で外部連携APIを呼び出すさい-538 付 start
  getPatPersonMainData,
  // add FNSI-画面で外部連携APIを呼び出すさい-538 付 end
  sendRequestGetMstTreatmentStatusDispItem
} from "@/apis/status-list";
import {
  sendRequestGetSysMonitorItem
} from "@/apis/treatment-record";
import { sendRequestGetKurSelector } from "@/apis/send-condition";
import { EventBus } from "@/compat/vue/event-bus.js";
import dayjs from "@/compat/date/dayjs";
import { markRaw } from "@/compat/vue/runtime";
import { getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import patNameCellTemplateSource from "@/components/status-list/sub-item/PatNameCellTemplate.vue";
import bedNameCellTemplateSource from "@/components/status-list/sub-item/BedNameCellTemplate.vue";
import dialysisStateCellTemplateSource from "@/components/status-list/sub-item/DialysisStateCellTemplate.vue";
import selectorStaffCellTemplateSource from "@/components/status-list/sub-item/SelectorStaffCellTemplate.vue";
import changeInstructionTemplateSource from "@/components/status-list/sub-item/ChangeInstructionTemplate.vue";
// add FNSI-装置自己診断の追加 徐 start
import machineRecordCdTemplateSource from "@/components/status-list/sub-item/MachineRecordCdTemplate.vue";
// add FNSI-装置自己診断の追加 徐 end
// add FNSI-警報・報知の追加 徐 start
import machineRecordValueTemplateSource from "@/components/status-list/sub-item/MachineRecordValueTemplate.vue";
// add FNSI-警報・報知の追加 徐 end
// add FNSI-患者名の追加 付 start
import PatIdCellTemplateSource from "@/components/status-list/sub-item/PatIdCellTemplate.vue";
// add FNSI-患者名の追加 徐 end
// add FNSI-項目表示制御の修正 徐 start
import useCheckTemplateSource from "@/components/status-list/sub-item/useCheckTemplate.vue";
// add FNSI-項目表示制御の修正 徐 end
import MachineNameCellTemplateSource from "@/components/status-list/sub-item/MachineNameCellTemplate.vue";
import { isDisp } from "@/components/status-list/list-map-common/listMapCommonFunction";
import { addPatNameSortToList } from "@/functions/SortFunctions";
import roundStateTemplateSource from "@/components/status-list/sub-item/RoundStateTemplate.vue"
import { getAppComputedStyle } from "@/functions/common/LayoutMeasureHelper";

const markNativeGridCell = (component) => markRaw(component?.default || component);
const patNameCellTemplate = markNativeGridCell(patNameCellTemplateSource);
const bedNameCellTemplate = markNativeGridCell(bedNameCellTemplateSource);
const dialysisStateCellTemplate = markNativeGridCell(dialysisStateCellTemplateSource);
const selectorStaffCellTemplate = markNativeGridCell(selectorStaffCellTemplateSource);
const changeInstructionTemplate = markNativeGridCell(changeInstructionTemplateSource);
const machineRecordCdTemplate = markNativeGridCell(machineRecordCdTemplateSource);
const machineRecordValueTemplate = markNativeGridCell(machineRecordValueTemplateSource);
const PatIdCellTemplate = markNativeGridCell(PatIdCellTemplateSource);
const useCheckTemplate = markNativeGridCell(useCheckTemplateSource);
const MachineNameCellTemplate = markNativeGridCell(MachineNameCellTemplateSource);
const roundStateTemplate = markNativeGridCell(roundStateTemplateSource);
const state = {
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
  firstInit: true,
  dispDab: false,
  dispDad: false,
  dispDro: false,
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
  // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
  RODeviceStatus: false,
  DABDeviceStatus: false,
  DADDeviceStatus: false,
  // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
  // mod FNSI-redmine#4277 付 start
  // isShowMain: true,
  isShowMain: null,
  // mod FNSI-redmine#4277 付 end
  goAlarmPage: false,
  statusGrid: null,
  gridCount: null,
  facilityCd: "",

  //利用者情報一覧
  cmbStaffList: [],

  // クール一覧情報
  kurGroupList: [],
  kurListData: [],

  // クール詳細一覧(時間が必要な場合の処理用)
  mstKurList: [],

  // ベッド+装置一覧
  bedMachineList: [],

  // ベッドグループ一覧情報
  bedListData: [],
  bedGroupList: [],

  // 次患者一覧情報（固定）
  nextPatGroupList: [
    { nextPatGroupName: "表示しない", nextPatValue: 0 },
    { nextPatGroupName: "現クール", nextPatValue: 1 },
    { nextPatGroupName: "次クール", nextPatValue: 2 }
  ],

  // 表示項目一覧情報：治療状況リスト
  allColItemList: [],

  // 表示項目コンボ用
  comboLayoutItemList: [],

  // 機械室表示情報
  statusDevice: [],
  statusDevicedata: [],

  newsetcolumns: [],
  // 治療状況リスト抽出条件
  conditionTreatList: {
    // ベッドグループコード
    bedGroupCd: 0,
    // 表示項目：治療状況リスト
    colItemGroupName: "",
    colItemLayoutNo: "",
    // 表示項目：装置一覧
    deviceColIndex: 0,
    // クール
    kurCd: [],
    // クール名
    kurGroupName: [],
    kurGroupList: [],
    // 次患者表示：治療状況リスト
    nextPatValue: 0,
    // 次患者表示：装置一覧
    deviceNextValue: 2,
    colListChange: false,
    isClear: false,
    notUsageGuide: false,
    isInitialized: false
  },

  // 検索条件（フィルタリング用）
  condition: {
    // 発生日時(グリッドデータに日付が含まれる場合）
    occurDate: "",
    // 警報
    deviceEdgeEmergency: false,
    // 報知
    deviceEdgeDefect: false,
    // 全選択
    deviceEdgeAll: true
  },

  // 装置治療状況
  machineStatusList: [],

  // 取得情報
  alarmListSettings: [],

  // 初期グリッドデータ：治療状況リスト
  defaultMainListDataSource: [],

  // 治療状況リスト(dcs,dab,dad,dro)dataSource
  deviceDataSource: {
    dcs: [],
    dab: [],
    dad: [],
    dro: [],
  },
  // 治療状況リスト(dcs,dab,dad,dro)column
  treatAllColumn: {
    // 透析液調製装置columns:DCS
    dcsTreatSetCol: [],
    // 透析液調製装置columns:DAB
    dabTreatSetCol: [],
    // 透析液調製装置columns:DAD
    dadTreatSetCol: [],
    // 透析液調製装置columns:DRO
    droTreatSetCol: []
  },

  // 警報報知データ
  dateFilterDataSource: [],
  // 画面更新指示
  filterSignal: false,

  // 画面横幅
  clientWidth: getViewportWidth(),

  // 編集中フィールド
  editingField: null,

  // 治療状況画面状態（初回表示フラグ）
  isFirstTreatment: true,
  // 装置一覧画面状態（初回表示フラグ）
  isFirstMachine: true,
  // ソート状態保持
  columnSort: {
    dcs: [],
    dro: [],
    dab: [],
    dad: []
  },
  isAlarmDisplay: false,
  // add FNSI-警報・報知追加 徐 start
  statusFlg: 0,
  statusList: [],
  filterListCount: 0,
  // add FNSI-警報・報知追加 徐 end
  // add FNSI-実績確定修正 徐 start
  createColumnCount: 0
  // add FNSI-実績確定修正 徐 end
  // add FNSI-redmine#4252 付 start
  ,columnResizeData: null,
  // add FNSI-redmine#4252 付 end
  // add FNSI-redmine#5747 高 start
  droColumnResizeData: null,
  dadColumnResizeData: null,
  dabColumnResizeData: null,
  // add FNSI-redmine#5747 高 end
  // モニタ項目
  sysMonitorItem: [],
  // 治療状況レイアウト表示項目マスタ
  mstTreatmentStatusDispItem: [],
  // 強制サインアウトフラグ (0:自動サインアウトする、1:自動サインアウトしない)
  forceSignOutFlag: 0,
};

const actions = {
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
  setFirstInit({ commit }, firstInit) {
    commit("setFirstInit", firstInit);
  },
  setDispDab({ commit }, dispDab) {
    commit("setDispDab", dispDab);
  },
  setDispDad({ commit }, dispDad) {
    commit("setDispDad", dispDad);
  },
  setDispDro({ commit }, dispDro) {
    commit("setDispDro", dispDro);
  },
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
  // -----------------------------------------
  // 抽出条件設定:警報履歴
  // -----------------------------------------
  setCondition({ commit }, condition) {
    commit("setCondition", condition);
  },
  // -----------------------------------------
  // 抽出条件クリア
  // -----------------------------------------
  clearCondition({ commit }, condition) {
    commit("clearCondition", condition);
  },
  // -----------------------------------------
  // ソート条件設定
  // -----------------------------------------
  setColumnSort({ commit }, sort) {
    commit("setColumnSort", sort);
  },
  // -----------------------------------------
  // ソート条件クリア
  // -----------------------------------------
  clearColumnSort({ commit }) {
    commit("clearColumnSort");
  },
  // mod FNSI-実績確定修正 徐 start
  /*
   * 治療状況リストの画面終了時に不要になる情報をクリア
   */
  clearDisplayData({ commit, getters }) {
    // 画面開始時や検索時に都度実行されるactionsで保持され、
    // 画面終了時に保持しておく必要がない項目をクリアする
    // "fetchKur"
    commit("setMstKurList", []);
    // "fetchBedMachine"
    commit("setBedMachineList", []);
    // "fetchKurBedGroup"
    commit("setkurlist", { kurGroupList: [], kurListData: [] });
    commit("RECEIVE_TREATBEDGROUPLIST", { bedGroupList: [], bedListData: [] });
    // "setColItemGroupList"
    commit("setColItemGroupList", { comboLayoutItemList: [], allColItemList: [] });
    // "setStatusGridColumn"
    commit("dcsTreatSetCol", []);
    commit("dadTreatSetCol", []);
    commit("dabTreatSetCol", []);
    commit("droTreatSetCol", []);
    // "setTreatSettingList"
    commit("RECEIVE_TREATSETTINGLIST", {
      dataSource: { dcs: [], dab: [], dad: [], dro: [] }
    });
    // "getMstPersonalUser"
    commit("setCmbStaffList", { cmbStaffList: [] });

    // getters(computed)のキャッシュを更新するために値を参照する
    // （stateに持っている値とgettersのキャッシュで
    //  別個のオブジェクトを保持している状態を解消する）
    getters.getBedMachineList;
    getters.getKurGroupList;
    getters.getKurListData;
    getters.getBedGroupList;
    getters.getBedListData;
    getters.comboLayoutItemListGetter;
    getters.getColItemList;
    getters.treatAllColumn;
    getters.getDeviceDataSource;
    getters.getCmbStaffList;
  },
  // -----------------------------------------
  // 強制サインアウトフラグ設定
  // -----------------------------------------
  setForceSignOutFlag({ commit }, forceSignOutFlag) {
    commit("setForceSignOutFlag", forceSignOutFlag);
  },
  /*
   * 治療状況リスト情報取得
   */
  // fetchTreatSettingList(context, info) {
  fetchTreatSettingList({ state }, info) {
    if (info.isShowMain === null || info.isShowMain === undefined) {
      info.isShowMain = false;
    }
    return sendRequestGetTreatmentStatusList(info, state.createColumnCount);
  },
  // mod FNSI-実績確定修正 徐 end
  setTreatSettingList({ commit }, param) {
    commit("RECEIVE_TREATSETTINGLIST", {
      // 治療状況一覧情報
      dataSource: param.dataSet
    });
  },
  // 治療状況リスト：grid列項目作成
  setStatusGridColumn({ state, commit }, colItemCd) {
    // ベース要素のフォントサイズを取得
    let fontSize = parseFloat(
      getAppComputedStyle()?.getPropertyValue("font-size")
    );

    // 表示画面横幅が500px以下の場合は患者名以降の固定化を解除する
    let locked1flag = true;
    if (state.clientWidth <= 500) {
      locked1flag = false;
    }

    // NOTE: クールの扱い如何では復活
    // 表示画面横幅が700px以下の場合はクール名以降の固定化を解除する
    // let locked2flag = true;
    // if (state.clientWidth <= 700) {
    //   locked2flag = false;
    // }

    // dcs固定列
    let dcsColItems = [
      {
        field: "confirm",
        sortable: false,
        editable: false,
        locked: true,
        headerAttributes: {
          id: "conf-header"
        },
        cell: dialysisStateCellTemplate,
        title: "実績",
        width: fontSize * 9 + "px",
        minResizableWidth: fontSize * 9,
        className: "dialysis-state-td-",
        reorderable: true,
        orderIndex: 0
        // add FNSI-redmine#4252 付 start
        ,resizable: false,
        // add FNSI-redmine#4252 付 end
      },
      {
        field: "bedName",
        title: "ベッド名",
        editable: false,
        locked: true,
        // lock対象に対してカラム幅はpx指定でないと有効にならない
        width: fontSize * 12 + "px",
        cell: bedNameCellTemplate,
        className: "locked-td",
        reorderable: true,
        orderIndex: 1,
      },
      {
        field: "patName",
        title: "患者名",
        editable: false,
        locked: locked1flag,
        // lock対象に対してカラム幅はpx指定でないと有効にならない
        width: fontSize * 12 + "px",
        cell: patNameCellTemplate,
        className: locked1flag ? "locked-td" : null,
        reorderable: true,
        orderIndex: locked1flag ? 2 : 3,
      },
      // NOTE: クールの扱い如何では復活
      // {
      //   field: "kurName",
      //   title: "クール名",
      //   editable: () => false,
      //   // locked: true,
      //   locked: locked2flag,
      //   lockable: false,
      //   //              hidden: true,
      //   // lock対象に対してカラム幅はpx指定でないと有効にならない
      //   //              width: "8em"
      //   width: fontSize * 12 + "px"
      // },
      {
        field: "dummyColumn",
        title: "ダミー列",
        editable: false,
        // add FNSI-redmine#4252 付 start
        // width: "1px",
        width: "0px",
        // add FNSI-redmine#4252 付 end
        hidden: false,
        locked: true,
        reorderable: false,
        orderIndex: locked1flag ? 3 : 2
      }
    ];

    // dab固定列
    let dabColItems = [
      {
        field: "machineName",
        title: "装置名",
        width: "100px",
        cell: MachineNameCellTemplate,
        locked: true,
        lockable: false,
        hidden: false,
        className: "locked-machine-td",
        reorderable: true,
        orderIndex: 0
      },
      {
        field: "machineSerial",
        title: "製造番号",
        width: "120px",
        locked: true,
        lockable: false,
        hidden: false,
        className: "locked-machine-td",
        reorderable: true,
        orderIndex: 1
      },
      {
        field: "dummyColumn",
        title: "ダミー列",
        width: "50px",
        hidden: true,
        locked: false,
        reorderable: false,
        orderIndex: 2
      }
    ];

    // dad固定列
    let dadColItems = [
      {
        field: "machineName",
        title: "装置名",
        width: "100px",
        cell: MachineNameCellTemplate,
        locked: true,
        lockable: false,
        hidden: false,
        className: "locked-machine-td",
        reorderable: true,
        orderIndex: 0
      },
      {
        field: "machineSerial",
        title: "製造番号",
        width: "120px",
        locked: true,
        lockable: false,
        hidden: false,
        className: "locked-machine-td",
        reorderable: true,
        orderIndex: 1
      },
      {
        field: "dummyColumn",
        title: "ダミー列",
        width: "50px",
        hidden: true,
        locked: false,
        reorderable: false,
        orderIndex: 2
      }
    ];

    // dro固定列
    let droColItems = [
      {
        field: "machineName",
        title: "装置名",
        width: "100px",
        cell: MachineNameCellTemplate,
        locked: true,
        lockable: false,
        hidden: false,
        className: "locked-machine-td",
        reorderable: true,
        orderIndex: 0
      },
      {
        field: "machineSerial",
        title: "製造番号",
        width: "120px",
        locked: true,
        lockable: false,
        hidden: false,
        className: "locked-machine-td",
        reorderable: true,
        orderIndex: 1
      },
      {
        field: "dummyColumn",
        title: "ダミー列",
        width: "50px",
        hidden: true,
        locked: false,
        reorderable: false,
        orderIndex: 2
      }
    ];

    // 変動列
    let allLayout = state.allColItemList;
    let gridColItems = {};
    if (allLayout !== undefined) {
      for (const layout of allLayout) {
        if (colItemCd === layout.layoutNo) {
          gridColItems = layout;
          break;
        }
      }
      if (gridColItems !== "" && Object.keys(gridColItems).length !== 0) {
        let dcsColumns = JSON.parse(gridColItems.dcsViewItems);
        let dabColumns = JSON.parse(gridColItems.dabViewItems);
        let dadColumns = JSON.parse(gridColItems.dadViewItems);
        let droColumns = JSON.parse(gridColItems.droViewItems);
        
        // 単位取得で使用するモニタ項目をmapに変換
        const sysMonitorItemMap = {};
        state.sysMonitorItem.forEach(item => {
          sysMonitorItemMap[item.moni_data_no] = item;
        });
        // 単位取得で使用する治療状況レイアウト表示項目をmapに変換
        const mstTreatmentStatusDispItemMap = {};
        state.mstTreatmentStatusDispItem.forEach(item => {
          mstTreatmentStatusDispItemMap[item.itemCd] = item;
        });
        
        // 単位取得関数
        const getUnit = (dataClass, keyName) => {
          // 治療状況レイアウト表示項目からunitを取得
          const unitFromMst = mstTreatmentStatusDispItemMap[dataClass]?.unit;
          // 治療状況レイアウト表示項目のレコードが存在する場合[unit]形式、nullの場合は空文字を返す
          if (unitFromMst !== undefined) {
            return unitFromMst !== null ? `[${unitFromMst}]` : "";
          }
          // モニタ項目からunitを取得
          const unitFromSysMonitor = sysMonitorItemMap[keyName]?.unit;
          // モニタ項目が存在する場合は[unit]形式、nullの場合は空文字を返す
          return unitFromSysMonitor ? `[${unitFromSysMonitor}]` : "";
        };

        // dcs変動列
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
        // if (dcsColumns.length !== 0) {
        if (!!dcsColumns && dcsColumns.length !== 0) {
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
          let orderIdx = 3; // dcsColItems固定列最終列のorderIndex
          for (const dcsColumn of dcsColumns) {
            // 単位取得
            const unit = getUnit(dcsColumn.data_class, dcsColumn.key_name);
            let addColumn = {
              field: "field_" + dcsColumn.order_no.toString(10),
              title: `${dcsColumn.title}${unit}`,
              width: fontSize * dcsColumn.width + "px",
              data_class: dcsColumn.data_class,
              values: null,
              Control: null,
              editable: false,
              format: null,
              hidden: false,
              locked: false,
              reorderable: true,
              orderIndex: ++orderIdx,
              keyName: dcsColumn.key_name
            };
            switch (addColumn.data_class) {
              // add FNSI-項目表示制御の修正 徐 start
              case 6: // 目標体重
              addColumn.cell = useCheckTemplate;
              addColumn.format = "6";
              break;
              // add FNSI-項目表示制御の修正 徐 end
              case 23: // 担当者1
              case 25: // 担当者2
              case 28: // 穿刺者1
              case 30: // 穿刺者2
              case 33: // 返血者1
              case 35: // 返血者2
                addColumn.editable = true;
                addColumn.width = (fontSize * dcsColumn.width) + 150 + "px";
                addColumn.cell = selectorStaffCellTemplate;
                break;
              case 62: // 回診状態
                addColumn.cell = roundStateTemplate;
                break;
              case 66: // 最新愁訴
              case 67: // 最新処置
                addColumn.className = "comp-treat-td";
                break;
              // add FNSI-項目表示制御の修正 徐 start
              case 73: // VA
              addColumn.cell = useCheckTemplate;
              addColumn.format = "73";
              break;
              case 74: // 除水量制限
              addColumn.cell = useCheckTemplate;
              addColumn.format = "74";
              break;
              case 75: // ダイアライザ
              addColumn.cell = useCheckTemplate;
              addColumn.format = "75";
              break;
              case 76: // 吸着カラム
              addColumn.cell = useCheckTemplate;
              addColumn.format = "76";
              break;
              case 77: // 1次膜
              addColumn.cell = useCheckTemplate;
              addColumn.format = "77";
              break;
              case 78: // 2次膜
              addColumn.cell = useCheckTemplate;
              addColumn.format = "78";
              break;
              case 79: // 穿刺針(A針)
              addColumn.cell = useCheckTemplate;
              addColumn.format = "79";
              break;
              case 80: // 穿刺針(V針)
              addColumn.cell = useCheckTemplate;
              addColumn.format = "80";
              break;
              case 81: // 穿刺針(SN)
              addColumn.cell = useCheckTemplate;
              addColumn.format = "81";
              break;
              case 82: // シングルニードル使用
              addColumn.cell = useCheckTemplate;
              addColumn.format = "82";
              break;
              case 83: // 血液回路
              addColumn.cell = useCheckTemplate;
              addColumn.format = "83";
              break;
              case 84: // 血流量
              addColumn.cell = useCheckTemplate;
              addColumn.format = "84";
              break;
              case 85: // 透析液
              addColumn.cell = useCheckTemplate;
              addColumn.format = "85";
              break;
              case 86: // 透析液流量
              addColumn.cell = useCheckTemplate;
              addColumn.format = "86";
              break;
              case 87: // 透析液量
              addColumn.cell = useCheckTemplate;
              addColumn.format = "87";
              break;
              case 88: // 透析液温度
              addColumn.cell = useCheckTemplate;
              addColumn.format = "88";
              break;
              case 89: // 補液
              addColumn.cell = useCheckTemplate;
              addColumn.format = "89";
              break;
              case 90: // 補液量
              addColumn.cell = useCheckTemplate;
              addColumn.format = "90";
              break;
              case 91: // 補液選択
              addColumn.cell = useCheckTemplate;
              addColumn.format = "91";
              break;
              case 92: // 補液使用数
              addColumn.cell = useCheckTemplate;
              addColumn.format = "92";
              break;
              case 93: // 補液温度
              addColumn.cell = useCheckTemplate;
              addColumn.format = "93";
              break;
              case 94: // 補液速度
              addColumn.cell = useCheckTemplate;
              addColumn.format = "94";
              break;
              case 95: // 抗凝固剤
              addColumn.cell = useCheckTemplate;
              addColumn.format = "95";
              break;
              case 96: // 抗凝固剤ワンショット量
              addColumn.cell = useCheckTemplate;
              addColumn.format = "96";
              break;
              case 97: // 抗凝固剤持続速度
              addColumn.cell = useCheckTemplate;
              addColumn.format = "97";
              break;
              case 98: // 抗凝固剤持続総量
              addColumn.cell = useCheckTemplate;
              addColumn.format = "98";
              break;
              case 99: // IP使用選択
              addColumn.cell = useCheckTemplate;
              addColumn.format = "99";
              break;
              case 100: // IPスタート
              addColumn.cell = useCheckTemplate;
              addColumn.format = "100";
              break;
              case 101: // IPワンショット量
              addColumn.cell = useCheckTemplate;
              addColumn.format = "101";
              break;
              case 102: // IP速度
              addColumn.cell = useCheckTemplate;
              addColumn.format = "102";
              break;
              case 103: // IP速度最大値
              addColumn.cell = useCheckTemplate;
              addColumn.format = "103";
              break;
              case 104: // IPワンショットスタート
              addColumn.cell = useCheckTemplate;
              addColumn.format = "104";
              break;
              case 105: // IP電源自動切り
              addColumn.cell = useCheckTemplate;
              addColumn.format = "105";
              break;
              case 106: // IP電源自動切り時間
              addColumn.cell = useCheckTemplate;
              addColumn.format = "106";
              break;
              case 107: // IP電源OKモニタ切り
              addColumn.cell = useCheckTemplate;
              addColumn.format = "107";
              break;
              case 108: // IP電源OKモニタ切り時間
              addColumn.cell = useCheckTemplate;
              addColumn.format = "108";
              break;
              // add FNSI-項目表示制御の修正 徐 end
              case 109: // 指示変更
                addColumn.cell = changeInstructionTemplate;
                addColumn.className = "change-fontcolor-td-";
                break;
              // add FNSI-装置自己診断の追加 徐 start
              case 110: // 装置自己診断
                addColumn.cell = machineRecordCdTemplate;
                break;
              // add FNSI-装置自己診断の追加 徐 end
              // add FNSI-画面リロードの修正 徐 start
              case 111: // 警報・報知
                addColumn.cell = machineRecordValueTemplate;
                break;
              // add FNSI-画面リロードの修正 徐 end
              // add FNSI-患者名の追加 付 start
              case 2: // 患者名
                addColumn.cell = PatIdCellTemplate;
                break;
              // add FNSI-患者名の追加 付 end
              default:
                addColumn.Control = "text";
                addColumn.editable = false;
                break;
            }
            dcsColItems.push(addColumn);
          }
        }

        // dad変動列
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
        // if (dabColumns.length !== 0) {
        if (!!dabColumns && dabColumns.length !== 0) {
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
          let orderIdx = 2; // dcsColItems固定列最終列のorderIndex
          for (const dabColumn of dabColumns) {
            // 単位取得
            const unit = getUnit(dabColumn.data_class, dabColumn.key_name);
            let addColumn = {
              field: "field_" + dabColumn.order_no.toString(10),
              title: `${dabColumn.title}${unit}`,
              // width: dabColumns[i].width + "em"
              width: fontSize * dabColumn.width + "px",
              hidden: false,
              locked: false,
              reorderable: true,
              orderIndex: ++orderIdx,
              data_class: dabColumn.data_class,
              keyName: dabColumn.key_name
            };
            // add FNSI-画面リロードの修正 徐 start
            if (dabColumn.key_name == 'A99') {
              addColumn.cell = machineRecordValueTemplate;
            }
            // add FNSI-画面リロードの修正 徐 end
            dabColItems.push(addColumn);
          }
        }

        // dad変動列
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
        // if (dadColumns.length !== 0) {
        if (!!dadColumns && dadColumns.length !== 0) {
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
          let orderIdx = 2; // dcsColItems固定列最終列のorderIndex
          for (const dadColumn of dadColumns) {
            // 単位取得
            const unit = getUnit(dadColumn.data_class, dadColumn.key_name);
            let addColumn = {
              field: "field_" + dadColumn.order_no.toString(10),
              title: `${dadColumn.title}${unit}`,
              // width: dadColumns[i].width + "em"
              width: fontSize * dadColumn.width + "px",
              hidden: false,
              locked: false,
              reorderable: true,
              orderIndex: ++orderIdx,
              data_class: dadColumn.data_class,
              keyName: dadColumn.key_name
            };
            // add FNSI-画面リロードの修正 徐 start
            if (dadColumn.key_name == 'D99') {
              addColumn.cell = machineRecordValueTemplate;
            }
            // add FNSI-画面リロードの修正 徐 end
            dadColItems.push(addColumn);
          }
        }

        // dro変動列
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
        // if (droColumns.length !== 0) {
        if (!!droColumns && droColumns.length !== 0) {
        // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
          let orderIdx = 2; // dcsColItems固定列最終列のorderIndex
          for (const droColumn of droColumns) {
            // 単位取得
            const unit = getUnit(droColumn.data_class, droColumn.key_name);
            let addColumn = {
              field: "field_" + droColumn.order_no.toString(10),
              title: `${droColumn.title}${unit}`,
              // width: droColumns[i].width + "em"
              width: fontSize * droColumn.width + "px",
              hidden: false,
              locked: false,
              reorderable: true,
              orderIndex: ++orderIdx,
              data_class: droColumn.data_class,
              keyName: droColumn.key_name
            };
            // add FNSI-画面リロードの修正 徐 start
            if (droColumn.key_name == 'R99') {
              addColumn.cell = machineRecordValueTemplate;
            }
            // add FNSI-画面リロードの修正 徐 end
            droColItems.push(addColumn);
          }
        }
      }
    }

    commit("dcsTreatSetCol", dcsColItems);
    commit("dadTreatSetCol", dadColItems);
    commit("dabTreatSetCol", dabColItems);
    commit("droTreatSetCol", droColItems);
  },

  /*
   * 治療状況リスト：機械室の表示情報取得
   */

  /*
   * 治療状況警報注意履歴情報取得
   */
  async fetchAlarmSettingList({ commit }, info) {
    return sendRequestGetAlarmList(info).then(response => {
      const dataList = response.data;
      let alarmSettings = [];
      dataList.forEach((value, index, array) => {
        let selectDate = dayjs(array[index].occurDate).format(
          "YYYY/MM/DD HH:mm:ss"
        );
        let alarmCol = {
          occurDate: selectDate,
          bedName: array[index].bedName,
          PatientName: array[index].patName,
          historyType: array[index].historyType,
          Contents: array[index].contents,
          // add FNSI-警報報知修正 付 start
          machineTypeCd: array[index].machineTypeCd,
          machineSerial: array[index].machineSerial
          // add FNSI-警報報知修正 付 end
        };
        alarmSettings.push(alarmCol);
      });

      state.gridCount = alarmSettings.length;

      // grid設定一覧情報をセットする
      commit("RECEIVE_ALARMSETTINGLIST", {
        // grid設定情報
        alarmListSettings: alarmSettings
      });
    });
  },

  /*
   * 穿刺者・返血者・担当者一覧情報取得
   */
  async getMstPersonalUser({ commit }) {
    // スタッフ一覧情報取得
    const response = await sendRequestGetMstPersonalUser();

    // 取得データ
    const data = response.data;
    let list = [];

    data.forEach((value, index, array) => {
      list.push({ text: array[index].userName, value: array[index].userId });
    });
    // グリッドコンボボックス用スタッフ情報をセット
    commit("setCmbStaffList", { cmbStaffList: list });
  },

  /**
   * クール詳細情報一覧の取得
   */
  async fetchKur({ commit }, facilityCd) {
    // 一覧取得
    sendRequestGetKur(facilityCd)
      .then(response => {
        // 取得したクール一覧情報をセット
        commit("setMstKurList", response.data);
      })
      .catch(err => {
        console.error(err);
      });
  },

  /**
   *
   * @param {*} param0
   */
  async fetchBedMachine({ commit }) {
    // 一覧取得
    sendRequestGetBedMachine()
      .then(response => {
        // 取得したベッド＋装置一覧情報をセット
        commit("setBedMachineList", response.data);
      })
      .catch(err => {
        console.error(err);
      });
  },
  /**
   * クールとベッドの一覧取得
   */
  async fetchKurBedGroup({ commit }) {
    // クールとベッドの一覧取得
    try{
      const response = await sendRequestGetKurSelector();
      // 取得したクール一覧情報をセット
      let kurSelector = response.data.kurSelector;
      // let setdataList = [{ kurGroupName: "すべて", kurCd: 0 }];
      let setdataList = [];
      kurSelector.forEach((value, index, array) => {
        let groupset = {
          kurGroupName: array[index].name,
          kurCd: array[index].code
        };
        setdataList.push(groupset);
      });
      // ヘッダー抽出コンボボックス用
      const kurGroupList = setdataList;
      // クール抽出用
      const kurListData = response.data.kurSelector.map(dat => {
        return {
          kurName: dat.name,
          kurCd: dat.code
        };
      });
      // クール一覧情報をセットする
      commit("setkurlist", { kurGroupList, kurListData });

      // コンボボックスにセットする情報を作成
      let comboItemList = [{ bedGroupName: "すべて", bedGroupCd: 0 }];
      response.data.bedGroupList.forEach((value, index, array) => {
        let buf = {
          bedGroupName: array[index].roomBedGroupName,
          bedGroupCd: array[index].roomBedGroupCd
        };
        comboItemList.push(buf);
      });

      // ベッドグループ一覧情報をセットする
      commit("RECEIVE_TREATBEDGROUPLIST", {
        // ヘッダー抽出コンボボックス用
        bedGroupList: comboItemList,
        // ベッドグループ抽出用
        bedListData: response.data.bedGroupList
      });
    }
    catch(err) {
      console.error(err);
    }
  },

  /**
   * 装置治療状況情報取得
   */
  fetchMachineStatusList({ commit }, facilityCd) {
    sendRequestGetMntMachineState(facilityCd)
      .then(response => {
        // 一覧情報をセットする
        commit("RECIEVE_MACHINESTATUSLIST", {
          machineStatusList: response.data
        });
      })
      .catch(r => {
        if (r.response.status === 400) {
          // 400エラー
        }
      });
  },
  /*
   * 治療状況リストレイアウト情報取得
   * ヘッダー抽出条件：表示項目（機械室の表示項目も同時取得）
   */
  async fetchStatusLayoutList() {
    return sendRequestGetStatusLayout();
  },
  /*
   * 全てのモニタ項目取得
   */
  async fetchSysMonitorItem({ commit }) {
    const param = {
      moniDataType: "all",
      vitalMonitorClass: null
    };
    const response = await sendRequestGetSysMonitorItem(param);
    commit("setSysMonitorItem", response.data);
    return response;
  },
  /*
   * 全て（未削除）の治療状況レイアウト表示項目マスタ取得
   */
  async fetchMstTreatmentStatusDispItem({ commit }) {
    const response = await sendRequestGetMstTreatmentStatusDispItem();
    commit("setMstTreatmentStatusDispItem", response.data);
    return response;
  },
  setColItemGroupList({ commit }, param) {
    // 一覧情報をセットする
    commit("setColItemGroupList", {
      comboLayoutItemList: param.layoutItemList,
      // 治療状況マップ表示項目
      allColItemList: param.allColItemList
    });
  },

  /**
   * 治療状況リスト：抽出条件セット
   */
  async conditionSet({ state, commit }, filterObj) {
    // 引数のフィルターをディープコピー
    let filter = JSON.parse(JSON.stringify(filterObj));
    // 引数のフィルター項目に追加していく
    // 抽出条件
    // 治療状況リスト：表示項目
    filter.colItemLayoutNo = filterObj.colItemLayoutNo;
    // クール
    filter.kurCd = filterObj.kurGroupList;
    // 次患者表示
    filter.isClear = filterObj.isClear;
    // 次患者表示：治療状況リスト
    filter.nextPatValue = filterObj.nextPatValue;
    // 次患者表示：装置一覧
    filter.deviceNextValue = filterObj.deviceNextValue;

    // リストグラフ抽出条件情報をセットする
    commit("SET_TREATCONDITION", {
      // リストグラフ抽出条件
      conditionTreatList: filter
    });
  },
  // 表示切替フラグ変更
  setIsShowMain({ commit }, isShowMain) {
    commit("setIsShowMain", isShowMain);
  },
  // 警報報知履歴表示切替フラグ変更
  setIsGoAlarmPage({ commit }, goflag) {
    commit("setIsGoAlarmPage", goflag);
  },
  // 警報報知日付変更
  changeOccurDate({ commit }, goflag) {
    commit("changeOccurDate", { treatmentStatusHeaderDate: goflag });
  },
  // 表示切替フラグset
  setGridCount({ commit }, gridCount) {
    commit("setGridCount", gridCount);
  },
  edit({ commit }, editInfo) {
    commit("edit", editInfo);
  },
  /**
   * 更新指示
   * @param {*} state state
   * @param {boolean} signal 更新する際にシグナルを立てる
   */
  setFilterSignal({ commit }, signal) {
    commit("setFilterSignal", signal);
  },
  /**
   * 警報一覧表示有無
   * @param {*} param0
   * @param {*} value
   */
  setIsAlarmDisplay({ commit }, value) {
    commit("setIsAlarmDisplay", value);
  },
  // -----------------------------------------
  // 検索条件に対応する警報・報知一覧情報取得
  // -----------------------------------------
  fetchHistoryList({ state, commit }, condition) {
    let dataSource = state.alarmListSettings;
    // 抽出条件のフィルタ
    // 選択されている発生日付
    let targetOccurDate = condition.searchOccurDate;
    // 警報
    let isEmergency = state.condition.deviceEdgeEmergency;
    // 報知
    let isDefect = state.condition.deviceEdgeDefect;
    // 全情報
    let isAll = state.condition.deviceEdgeAll;
    // 抽出条件で絞り込んだ結果を格納する変数
    let filterDataSource = [];
    // 抽出条件が未入力の場合
    if ((!targetOccurDate || targetOccurDate === "") && isAll) {
      filterDataSource = dataSource;
    } else {
      // -----------------------------------------
      // 抽出条件が入力されている場合
      // -----------------------------------------
      for (let idx = 0; idx < dataSource.length; idx++) {
        // 抽出条件対象フラグ
        let isFilter = true;
        if (targetOccurDate && targetOccurDate !== "") {
          let selectDate = dayjs(dataSource[idx].occurDate).format(
            "YYYY-MM-DD"
          );
          if (selectDate === targetOccurDate) {
            isFilter = true;
          } else {
            isFilter = false;
          }
        }
        if (isFilter) {
          let historyType = dataSource[idx].historyType;
          if (isAll) {
            filterDataSource.push(dataSource[idx]);
          } else if (
            isEmergency &&
            (historyType == 3 ||
              historyType == 4 ||
              historyType == 7 ||
              historyType == 8)
          ) {
            filterDataSource.push(dataSource[idx]);
          } else if (
            isDefect &&
            (historyType == 1 ||
              historyType == 2 ||
              historyType == 5 ||
              historyType == 6)
          ) {
            filterDataSource.push(dataSource[idx]);
          }
        }
      }
    }

    commit("RECEIVE_ALERMLISTTTING", {
      dateFilterDataSource: filterDataSource
    });

    state.gridCount = filterDataSource.length;
  },
  // -----------------------------------------
  // 発生日付に対応する警報・報知一覧情報取得
  // -----------------------------------------
  async findHistoryList({ state, commit, dispatch }, occurDate) {
    let facilityCd = state.facilityCd;

    commit("changeOccurDate", {
      treatmentStatusHeaderDate: occurDate
    });
    try {
      await dispatch("fetchDataMonitorList", { facilityCd, occurDate });

      // 成功
      return true;
    } catch (e) {
      // 失敗
      return false;
    }
  },
  /*
   * 確認処理前の投薬未実施チェック
   */
  getCheckMediDone(context, info) {
    return sendRequestCheckMediDone(info);
  },
  // add FNSI-画面で外部連携APIを呼び出すさい-538 付 start
  /**
   * facilityCdより全患者の習得
   */
  getPatPersonMain(context, info) {
    return getPatPersonMainData(info);
  },
  // add FNSI-画面で外部連携APIを呼び出すさい-538 付 end
  /*
   * 後体重測定後の確認時のDB更新
   */
  putCheckAfterWeight(context, info) {
    return sendRequestUpdateCheckAfterWeight(info);
  },
  setCurrentData(commit, jsonData) {
    commit("setCurrentSettingData", jsonData);
    commit("setSettingDataDcs", jsonData);
  },
  // -----------------------------------------
  // データ一覧を更新
  // -----------------------------------------
  async updateTreatmentStatus(contents, data) {
    return sendRequestUpdateTreatmentStatus(data);
  },
  /**
   * 表示画面幅設定
   * @param {object} param0
   * @param {*} width
   */
  setClientWidth({ commit }, width) {
    commit("setClientWidth", width);
  },
  /**
   * ？？？？患者実績削除
   * @param {object} context
   * @param {number} ordNo
   */
  deleteUnknownPatRecord(context, ordNo) {
    return sendRequestDeleteUnknownPatRecord(ordNo);
  },
  setEditingField({ commit }, field) {
    commit("setEditingField", field);
  },
  /**
   * 指定されたオーダ番号から装置マスタを取得する.
   * @param {*} commit COMMITオブジェクト
   * @param {*} ordNo オーダ番号
   */
  getMstMachineByOrdNoRst({ commit }, ordNo) {
    return sendRequestGetMstMachineByOrdNoRst(ordNo);
  },
  // add FNSI-redmine#4252 付 start
  setColumnResizeData({ commit }, data) {
    commit("setColumnResizeData", data);
  },
  // add FNSI-redmine#4252 付 end
  // add FNSI-redmine#5747 高 start
  setDroColumnResizeData({ commit }, data) {
    commit("setDroColumnResizeData", data);
  },
  setDadColumnResizeData({ commit }, data) {
    commit("setDadColumnResizeData", data);
  },
  setDabColumnResizeData({ commit }, data) {
    commit("setDabColumnResizeData", data);
  },
  // add FNSI-redmine#5747 高 end
};

// mutations
const mutations = {
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
  setFirstInit(state, firstInit) {
    state.firstInit = firstInit;
  },
  setDispDab(state, dispDab) {
    state.dispDab = dispDab;
  },
  setDispDad(state, dispDad) {
    state.dispDad = dispDad;
  },
  setDispDro(state, dispDro) {
    state.dispDro = dispDro;
  },
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
  // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
  setRODeviceStatus(state, RODeviceStatus) {
    state.RODeviceStatus = RODeviceStatus;
  },
  setDABDeviceStatus(state, DABDeviceStatus) {
    state.DABDeviceStatus = DABDeviceStatus;
  },
  setDADDeviceStatus(state, DADDeviceStatus) {
    state.DADDeviceStatus = DADDeviceStatus;
  },
  // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
//add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 start
  clearConditionTreatList(state) {
    state.conditionTreatList = null;
  },
  clearConditionAll(state, condition) {
    state.conditionTreatList.bedGroupCd = 0;
    state.conditionTreatList.colItemGroupIndex = 0;
    state.conditionTreatList.colItemGroupName = "";
    state.conditionTreatList.colItemLayoutNo = "";
    state.conditionTreatList.deviceColIndex = 0;
    state.conditionTreatList.kurCd = [];
    state.conditionTreatList.kurGroupName = [];
    state.conditionTreatList.kurGroupList = [];
    state.conditionTreatList.nextPatGroupIndex = 0;
    state.conditionTreatList.deviceNextIndex = 2;
    state.conditionTreatList.colListChange = false;
    state.conditionTreatList.isClear = condition.isClear;
    state.conditionTreatList.notUsageGuide = false;
    state.conditionTreatList.isInitialized = false;
    state.conditionTreatList.bedGroupIndex = 0;
  },
//add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 end
  // 表示切替フラグ変更
  setIsShowMain(state, isShowMain) {
    state.isShowMain = isShowMain;
    // 次患者選択変更を通知
    EventBus.$emit("dataUpdateNextPatMode");
  },
  setIsGoAlarmPage(state, goAlarmPage) {
    state.goAlarmPage = goAlarmPage;
  },
  setGridCount(state, setGridCount) {
    state.gridCount = setGridCount;
  },
  // Grid列項目
  dcsTreatSetCol(state, param) {
    state.treatAllColumn.dcsTreatSetCol = param;
  },
  dabTreatSetCol(state, param) {
    state.treatAllColumn.dabTreatSetCol = param;
  },
  dadTreatSetCol(state, param) {
    state.treatAllColumn.dadTreatSetCol = param;
  },
  droTreatSetCol(state, param) {
    state.treatAllColumn.droTreatSetCol = param;
  },
  setCmbStaffList(state, payload) {
    state.cmbStaffList = payload.cmbStaffList;
  },
  /**
   * 機械室表示設定
   */
  setStatusDevice(state, statusDevice) {
    state.statusDevice = statusDevice;
  },
  /**
   * クール設定
   */
  setkurlist(state, kurlist) {
    // ヘッダー抽出コンボボックス用
    state.kurGroupList = kurlist.kurGroupList;
    // クール抽出用
    state.kurListData = kurlist.kurListData;
  },
  /**
   * 更新指示
   * @param {*} state state
   * @param {boolean} signal 更新する際にシグナルを立てる
   */
  setFilterSignal(state, signal) {
    state.filterSignal = signal;
  },
  /**
   *  警報一覧表示有無
   * @param {*} state
   * @param {*} value
   */
  setIsAlarmDisplay(state, value) {
    state.isAlarmDisplay = value;
  },
  // -----------------------------------------
  // 警報履歴：抽出条件設定
  // -----------------------------------------
  setCondition(state, condition) {
    state.condition.deviceEdgeEmergency = condition.deviceEdgeEmergency;
    state.condition.deviceEdgeDefect = condition.deviceEdgeDefect;
    state.condition.deviceEdgeAll = condition.deviceEdgeAll;
  },
  // -----------------------------------------
  // 抽出条件クリア
  // -----------------------------------------
  clearCondition(state, condition) {
    state.conditionTreatList.bedGroupCd = 0;
    state.conditionTreatList.colItemLayoutNo = "";
    state.conditionTreatList.deviceColIndex = 0;
    state.conditionTreatList.kurGroupList = [];
    state.conditionTreatList.kurGroupName = [];
    state.conditionTreatList.nextPatValue = 0;
    state.conditionTreatList.deviceNextValue = 2;
    state.conditionTreatList.isClear = condition.isClear;
  },

  // -----------------------------------------
  // ソート設定
  // -----------------------------------------
  setColumnSort(state, sort) {
    state.columnSort.dcs = sort.dcs;
    state.columnSort.dro = sort.dro;
    state.columnSort.dab = sort.dab;
    state.columnSort.dad = sort.dad;
  },
  // -----------------------------------------
  // ソートクリア
  // -----------------------------------------
  clearColumnSort(state) {
    state.columnSort.dcs = [];
    state.columnSort.dro = [];
    state.columnSort.dab = [];
    state.columnSort.dad = [];
  },
  setForceSignOutFlag(state, forceSignOutFlag) {
    state.forceSignOutFlag = forceSignOutFlag;
  },
  RECEIVE_ALERMLISTTTING(state, payload) {
    state.dateFilterDataSource = payload.dateFilterDataSource;
  },
  changeOccurDate(state, payload) {
    state.condition.occurDate = payload.treatmentStatusHeaderDate;
  },
  LOAD_STATUSGRID(state, payload) {
    state.statusGrid = payload.statusGrid;
  },
  RECEIVE_TREATBEDGROUPLIST(state, payload) {
    state.bedGroupList = payload.bedGroupList;
    state.bedListData = payload.bedListData;
  },
  RECIEVE_MACHINESTATUSLIST(state, payload) {
    state.machineStatusList = payload.machineStatusList;
  },
  setColItemGroupList(state, payload) {
    let isChangeLayoutItem = true;
    if (
      state.comboLayoutItemList &&
      payload.comboLayoutItemList &&
      state.comboLayoutItemList.length === payload.comboLayoutItemList.length
    ) {
      // サイズが同じ場合は内容を精査して異なる点がある場合のみ更新フラグをtrueにする
      isChangeLayoutItem = false;
      for (let i = 0; i < payload.comboLayoutItemList.length; i++) {
        const stateItem = state.comboLayoutItemList[i];
        const payloadItem = payload.comboLayoutItemList[i];
        if (
          stateItem.colItemLayoutNo !== payloadItem.colItemLayoutNo ||
          stateItem.layoutName !== payloadItem.layoutName
        ) {
          isChangeLayoutItem = true;
          break;
        }
      }
    }
    if (isChangeLayoutItem) {
      state.comboLayoutItemList = payload.comboLayoutItemList;
      // 表示項目設定に合わせて、治療状況リスト抽出条件も更新
      if (state.conditionTreatList != null && state.comboLayoutItemList.length !== 0) {
        const selectedLayout = state.comboLayoutItemList.find(
          item => `${item.colItemLayoutNo}` === `${state.conditionTreatList.colItemLayoutNo}`
        );
        if (!selectedLayout) {
          state.conditionTreatList.colItemLayoutNo = state.comboLayoutItemList[0].colItemLayoutNo;
        }
      }
    }
    let isChangeColItem = true;
    if (
      state.allColItemList &&
      payload.allColItemList &&
      state.allColItemList.length === payload.allColItemList.length
    ) {
      // サイズが同じ場合は内容を精査して更新日付か順序が異なる場合のみ更新フラグをtrueにする
      isChangeColItem = false;
      for (let i = 0; i < payload.allColItemList.length; i++) {
        const stateItem = state.allColItemList[i];
        const payloadItem = payload.allColItemList[i];
        if (
          stateItem.layoutNo !== payloadItem.layoutNo ||
          stateItem.upDate !== payloadItem.upDate
        ) {
          isChangeColItem = true;
          break;
        }
      }
    }
    if (isChangeColItem) {
      state.allColItemList = payload.allColItemList;
    }
  },
  RECEIVE_ALARMSETTINGLIST(state, payload) {
    state.alarmListSettings = payload.alarmListSettings;
  },
  RECEIVE_TREATSETTINGLIST(state, payload) {
    if (Array.isArray(payload.dataSource.dcs) && payload.dataSource.dcs.length > 0) {
      const updatedData = {
        ...payload.dataSource,
        dcs: addPatNameSortToList(payload.dataSource.dcs)
      };
      state.deviceDataSource = updatedData;
    } else {
      state.deviceDataSource = payload.dataSource;
    }
  },
  RECEIVE_MONIITEMLIST(state, payload) {
    state.monitemsettings = payload.monitemsettings;
  },
  SET_TREATCONDITION(state, payload) {
    state.conditionTreatList = payload.conditionTreatList;
  },
  setSettingDataDcs(state, jsonData) {
    state.settingDataDcs = jsonData;
  },
  setCurrentSettingData(state, jsonData) {
    state.currentData = jsonData;
  },
  // -----------------------------------------
  // 画面編集内容をstoreに反映
  // -----------------------------------------
  edit(state, editInfo) {
    let editRecord = editInfo.editRecord;

    // 該当レコードがあれば内容を更新、なければ追加
    let foundData = state.deviceDataSource.dcs.find(e => {
      return e.ordNo === editRecord.ordNo;
    });
    let index = state.deviceDataSource.dcs.indexOf(foundData);
    if (index >= 0) {
      state.deviceDataSource.dcs.splice(index, 1, editRecord);
    }
  },
  /**
   * 表示画面幅設定
   * @param {*} state
   * @param {*} width
   */
  setClientWidth(state, width) {
    state.clientWidth = width;
  },
  /**
   * クール詳細リストをセット
   * @param {*} state
   * @param {*} mstKurList
   */
  setMstKurList(state, mstKurList) {
    let kurList = mstKurList.map(dat => {
      return {
        kurName: dat.kurName,
        kurCd: dat.kurCd,
        kurStartTime: dat.kurStartTime,
        kurEndTime: dat.kurEndTime,
        kurStandardStartTime: dat.kurStandardStartTime
      };
    });
    // クール開始時刻でソート
    kurList.sort(function(a, b) {
      return a.kurStartTime < b.kurStartTime
        ? -1
        : a.kurStartTime === b.kurStartTime
        ? 0
        : 1;
    });
    state.mstKurList = kurList;
  },
  /**
   * ベッド＋装置リストをセット
   * @param {*} state
   * @param {*} list
   */
  setBedMachineList(state, list) {
    state.bedMachineList = list;
  },
  setEditingField(state, value) {
    state.editingField = value;
  },
  // add FNSI-警報・報知追加 徐 start
  setStatusFlg(state, flg) {
    state.statusFlg = flg;
  },
  setStatusList(state, statusList) {
    state.statusList = statusList;
  },
  setFilterListCount(state, filterListCount) {
    state.filterListCount = filterListCount;
  },
  setCreateColumn(state, createColumnCount) {
    state.createColumnCount = createColumnCount;
  }
  // add FNSI-警報・報知追加 徐 end
  // add FNSI-redmine#4252 付 start
  ,setColumnResizeData(state, data) {
    state.columnResizeData = data;
  },
  // add FNSI-redmine#4252 付 end
  // add FNSI-redmine#5747 高 start
  setDroColumnResizeData(state, data) {
    state.droColumnResizeData = data;
  },
  setDadColumnResizeData(state, data) {
    state.dadColumnResizeData = data;
  },
  setDabColumnResizeData(state, data) {
    state.dabColumnResizeData = data;
  },
  // add FNSI-redmine#5747 高 end
  setSysMonitorItem(state, payload) {
    state.sysMonitorItem = payload;
  },
  setMstTreatmentStatusDispItem(state, payload) {
    state.mstTreatmentStatusDispItem = payload;
  }
};

// getters
const getters = {
  // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
  getOccurDate: state => {
    return state.condition.occurDate
  },
  // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
  getFirstInit: state => {
    return state.firstInit;
  },
  getDispDab: state => {
    return state.dispDab;
  },
  getDispDad: state => {
    return state.dispDad;
  },
  getDispDro: state => {
    return state.dispDro;
  },
  // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
  // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
  getRODeviceStatus: state => {
    return state.RODeviceStatus;
  },
  getDABDeviceStatus: state => {
    return state.DABDeviceStatus;
  },
  getDADDeviceStatus: state => {
    return state.DADDeviceStatus;
  },
  // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
  getColumnSort: state => {
    return state.columnSort;
  },
  getCondition: state => {
    return state.condition;
  },
  defaultMainList: state => {
    return state.defaultMainListDataSource;
  },
  treatAllColumn: state => {
    return state.treatAllColumn;
  },
  getStatusDevice: state => {
    return state.statusDevice;
  },
  getIsShowMain: state => {
    return state.isShowMain;
  },
  getIsGoAlarmPage: state => {
    return state.goAlarmPage;
  },
  getDeviceDataSource: state => {
    return state.deviceDataSource;
  },
  getColItemList: state => {
    return state.allColItemList;
  },
  alarmListSettings: state => {
    return state.alarmListSettings;
  },
  getBedMachineList: state => {
    return state.bedMachineList;
  },
  getKurGroupList: state => {
    return state.kurGroupList;
  },
  getKurListData: state => {
    return state.kurListData;
  },
  getBedGroupList: state => {
    return state.bedGroupList;
  },
  getBedListData: state => {
    return state.bedListData;
  },
  conditionFilter: state => {
    return state.conditionTreatList;
  },
  nextPatGroupListGetter: state => {
    return state.nextPatGroupList;
  },
  comboLayoutItemListGetter: state => {
    return state.comboLayoutItemList;
  },
  gridCount: state => {
    return state.gridCount;
  },
  dateFilterDataSource: state => {
    return state.dateFilterDataSource;
  },
  getFilterSignal: state => {
    return state.filterSignal;
  },
  getIsAlarmDisplay: state => {
    return state.isAlarmDisplay;
  },
  getCmbStaffList(state) {
    return state.cmbStaffList;
  },
  getUpdateTreatmentStatus: state => ordNo => {
    let foundData = state.deviceDataSource.dcs.find(e => {
      return e.ordNo === ordNo;
    });
    let index = state.deviceDataSource.dcs.indexOf(foundData);
    return state.deviceDataSource.dcs[index];
  },
  getForceSignOutFlag: state => {
    return state.forceSignOutFlag;
  },
  /**
   * 治療状況更新情報作成
   */
  makeUpdateTreatmentStatus: state => param => {
    let ret = {};

    const dcsColumns = state.treatAllColumn.dcsTreatSetCol;
    const srcArray = state.deviceDataSource.dcs;
    const foundData = srcArray.find(
      srcData => srcData.ordNo === param.srcJson.ordNo
    );

    //
    ret.ordNo = param.srcJson.ordNo;

    // 編集対象検索
    // 編集対象のデータ種類を取得
    for (const dcsColumn of dcsColumns) {
      if (dcsColumn.field === param.key) {
        ret.old = foundData[param.key];
        ret.new = param.newValue;
        ret.dataClass = dcsColumn.data_class;
        // 変更対象が穿刺日付、返血日付の場合
        if (ret.dataClass == 27 || ret.dataClass == 32) {
          // 日付をISO8601形式に変換
          ret.new = dayjs(new Date(ret.new)).format();
          ret.old = dayjs(new Date(ret.old)).format();
        }
        break;
      }
    }

    return ret;
  },

  /**
   * 情報表示判定処理
   */
  isDispTreatData(state, getters) {
    return treatData => {
      // mod #7138 【デグレ】治療状況リスト、マップの表示条件と対象実績表示内容の不正 dou start
      // let ret = false;
      //
      // // 現クール/次クール開始日付時刻を取得
      // const currentKurStartDateTime = getCurrentKurStartDateTime(
      //   state.mstKurList
      // );
      // const nextKurStartDateTime = getNextKurStartDateTime(state.mstKurList);
      // //add #6818 2022-08-11 【デグレ】次患者表示が不正_治療状況リスト dou start
      // const todayStartDateTime = getCurrentDate() + "000000";
      // //add #6818 2022-08-11 【デグレ】次患者表示が不正_治療状況リスト dou end
      //
      // // 現在治療中の治療データである
      // let isDialysis =
      //   treatData.machineEntry === MACHINE_ENTRY_STATE.NOW_PATIENT;
      // // 次患者の治療データである
      // const isNextDialysis =
      //   !isDialysis &&
      //   treatData.machineEntry === MACHINE_ENTRY_STATE.NEXT_PATIENT;
      // // 次患者である場合
      // let checkKurDateTime = "";
      // if (isNextDialysis) {
      //   // チェック対象日時(治療日+クール開始時刻)を作成
      //   checkKurDateTime =
      //     treatData.treatDate +
      //     getKurStartTime(state.mstKurList, treatData.kurCd);
      // }
      //
      // // 表示画面判定
      // if (getters.getIsShowMain) {
      //   // 治療状況画面が表示されている場合
      //   // 治療状態が後体重測定待ち、版確定待ちの場合
      //   if (
      //     treatData.rstDialysisState === DIALISYS_STATE.AFTER_DRAINAGE ||
      //     treatData.rstDialysisState === DIALISYS_STATE.AFTER_WEIGHT_MEASURING
      //   ) {
      //     // 治療中とする
      //     isDialysis = true;
      //   }
      // } else {
      //   // 装置一覧画面が表示されている場合
      //
      //   // 装置エントリー状態判定
      //   if (treatData.machineEntry === MACHINE_ENTRY_STATE.NON_PATIENT) {
      //     // 空きベッドの場合治療中とする
      //     isDialysis = true;
      //   }
      // }
      // if (isDialysis) {
      //   // 治療中のデータは表示する
      //   ret = true;
      // } else {
      //   // 条件別次患者表示
      //   //mod FNSI redmine 5760 劉祥霖 start
      //   let nextPat=0;
      //   if(getters.getIsShowMain){
      //     nextPat = getters.conditionFilter.nextPatValue;
      //   }else {
      //     nextPat = getters.conditionFilter.deviceNextValue;
      //   }
      //   switch (nextPat) {
      //     //mod FNSI redmine 5760 劉祥霖 end
      //     case 0: {
      //       // 表示しない
      //       break;
      //     }
      //     case 1: {
      //       // 現クール
      //       if (isNextDialysis) {
      //         // 現クール判定
      //         // mod #6818 2022-08-11 【デグレ】次患者表示が不正_治療状況リスト dou start
      //         // if (checkKurDateTime <= currentKurStartDateTime)  {
      //         if (checkKurDateTime <= currentKurStartDateTime && checkKurDateTime >= todayStartDateTime) {
      //           // mod #6818 2022-08-11 【デグレ】次患者表示が不正_治療状況リスト dou end
      //           ret = true;
      //         }
      //       }
      //       break;
      //     }
      //     default: {
      //       // 次クール
      //       if (isNextDialysis) {
      //         // 次クール判定
      //         // mod #6818 2022-08-11 【デグレ】次患者表示が不正_治療状況リスト dou start
      //         // if (checkKurDateTime <= nextKurStartDateTime) {
      //         if (checkKurDateTime <= nextKurStartDateTime && checkKurDateTime >= todayStartDateTime) {
      //           // mod #6818 2022-08-11 【デグレ】次患者表示が不正_治療状況リスト dou end
      //           ret = true;
      //         }
      //       }
      //       break;
      //     }
      //   }
      // }
      // // 表示判定
      // if (ret) {
      //   // 表示対象の場合
      //
      //   // 表示画面判定2
      //   if (getters.getIsShowMain) {
      //     // 治療状況画面が表示されている場合
      //
      //     // 版確定後の場合
      //     if (
      //       treatData.rstDialysisState ===
      //       DIALISYS_STATE.CONFIRMED_WEIGHT_MEASURING
      //     ) {
      //       // 治療中以外とする
      //       ret = false;
      //     }
      //   } else {
      //     // 装置一覧画面が表示されている場合
      //
      //     // ベッド番号確認
      //     if (treatData.bedCd === null) {
      //       // ベッド番号がない場合は治療中以外とする
      //       ret = false;
      //     }
      //
      //     // 治療状態が後体重測定待ち、版確定待ち、版確定後の場合
      //     if (
      //       treatData.rstDialysisState === DIALISYS_STATE.AFTER_DRAINAGE ||
      //       treatData.rstDialysisState ===
      //       DIALISYS_STATE.AFTER_WEIGHT_MEASURING ||
      //       treatData.rstDialysisState ===
      //       DIALISYS_STATE.CONFIRMED_WEIGHT_MEASURING
      //     ) {
      //       // 治療中以外とする
      //       ret = false;
      //     }
      //   }
      // }
      // return ret;
      return isDisp(treatData, state, getters);
      // mod #7138 【デグレ】治療状況リスト、マップの表示条件と対象実績表示内容の不正 dou end
    };
  },
  /**
   * 装置治療状態取得
   */
  getMachineStatus(state) {
    return (machineTypeCd, machineSerial) => {
      const list = state.machineStatusList;

      return list.find(
        data =>
          data.machineTypeCd === machineTypeCd &&
          data.machineSerial === machineSerial
      );
    };
  },
  getEditingField: state => state.editingField,
  // add FNSI-警報・報知追加 徐 start
  getStatusFlg(state) {
    return state.statusFlg;
  },
  getStatusList(state) {
    return state.statusList;
  },
  getFilterListCount(state) {
    return state.filterListCount;
  }
  // add FNSI-警報・報知追加 徐 end
  // add FNSI-redmine#4252 付 start
  ,getColumnResizeData(state) {
    return state.columnResizeData;
  },
  // add FNSI-redmine#4252 付 end
  // add FNSI-redmine#5747 高 start
  getDroColumnResizeData(state) {
    return state.droColumnResizeData;
  },
  getDadColumnResizeData(state) {
    return state.dadColumnResizeData;
  },
  getDabColumnResizeData(state) {
    return state.dabColumnResizeData;
  },
  // add FNSI-redmine#5747 高 end
  getSysMonitorItem: state => state.sysMonitorItem,
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
  getters
};
// del #7138 【デグレ】治療状況リスト、マップの表示条件と対象実績表示内容の不正 dou start
// function getCurrentDate() {
//   return dayjs(new Date()).format("YYYYMMDD");
// }
// function getCurrentTime() {
//   return dayjs(new Date()).format("HHmmss");
// }
// /**
//  * 現在クール
//  */
// function getCurrentKur(kurList) {
//   return kurList.find(
//     dat =>
//       dat.kurStartTime <= getCurrentTime() && dat.kurEndTime >= getCurrentTime()
//   );
// }
// /**
//  * 指定クールの開始時刻を取得
//  */
// function getKurStartTime(kurList, kurCd) {
//   let ret = "000000";
//   if (kurCd != null) {
//     const kur = kurList.find(dat => dat.kurCd.toString() === kurCd.toString());
//     if (kur !== undefined) {
//       ret = kur.kurStartTime;
//     }
//   }
//   return ret;
// }
// /**
//  *  現クール開始日付時刻を取得
//  */
// function getCurrentKurStartDateTime(kurList) {
//   let ret = getCurrentDate();
//   // 現在クール取得
//   const kur = getCurrentKur(kurList);
//   if (kur !== undefined) {
//     ret += kur.kurStartTime;
//   }
//   return ret;
// }
// /**
//  *  次クール開始日付時刻を取得
//  */
// function getNextKurStartDateTime(kurList) {
//   let ret = "";
//   // 現在日付取得
//   const now = new Date();
//   let checkDate = dayjs(now).format("YYYYMMDD");
//
//   // 現クール開始時刻を取得
//   const currentKurStartDateTime = getCurrentKurStartDateTime(kurList);
//
//   // クール情報リスト
//   let lop = 0;
//   for (; lop < kurList.length; lop++) {
//     // 対象クールの開始日付時刻を作成
//     let checkDateTime =
//       checkDate + getKurStartTime(kurList, kurList[lop].kurCd);
//
//     // 現クール開始時刻と比較
//     if (currentKurStartDateTime < checkDateTime) {
//       // 現クール開始時刻より大きい
//       ret = checkDateTime;
//       break;
//     }
//   }
//
//   // 最後クール判定
//   if (lop !== 0 && lop === kurList.length) {
//     // 翌日判定
//     now.setDate(now.getDate() + 1);
//     ret =
//       dayjs(now).format("YYYYMMDD") +
//       getKurStartTime(kurList, kurList[0].kurCd);
//   }
//
//   return ret;
// }
// del #7138 【デグレ】治療状況リスト、マップの表示条件と対象実績表示内容の不正 dou end
