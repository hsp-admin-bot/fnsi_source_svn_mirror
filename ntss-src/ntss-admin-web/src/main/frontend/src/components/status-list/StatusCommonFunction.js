import { ALERT_TYPES } from "@/constants/statusMapConstants";
import { addPatNameSortToList } from "@/functions/SortFunctions";
import {
  ORDER_NAME_FIELDS,
  ORDER_NUMBER_WITHOUT_UNIT_FIELDS,
  ORDER_MAX_BP_FIELDS,
  TREATMENT_ITEM_CD,
} from "@/constants/mstTreatmentStatusDispItemConstants";

const constant = {
  useClass: {
    list: "0",
    map: "1"
  }
};

const getInitializeViewCondition = () => {
  return {
    // クール
    kurGroupIndex: 0,
    kurGroupName: "",
    // ベッドグループ
    bedGroupIndex: 0,
    bedGroupName: "",
    // 治療状況リスト：表示項目
    colItemLayoutNo: "",
    colItemGroupName: "",
    // 次患者表示
    nextPatValue: 0,
    nextpatGroupName: "",
    clearflg: false
  };
};

const buildComboBoxItemsTreatmentLayout = (source, useClass) => {
  let getColItemData = source;
  let setDataList = [];

  for (const iterator of getColItemData) {
    if (iterator.useClass === useClass) {
      let comboSet = {
        layoutName: iterator.layoutName,
        colItemLayoutNo: iterator.layoutNo
      };
      setDataList.push(comboSet);
    }
  }
  // 対象となるレイアウトがない場合、コンボボックスに「-」を表示する
  if (setDataList.length === 0) {
    setDataList.push({ layoutName: "-" });
  }

  return setDataList;
};
/**
 * 装置ステータス、透析番号、装置使用中の透析番号から警報 or 報知 or 空欄 かを判定
 * - 治療状況リスト＞装置一覧 -> 装置一意なリストなので、どのような表示条件でも、警報報知アイコンは表示
 * - 治療状況リスト＞治療状況 -> 同一ベッド全行が出るので、現在装置を使っている治療の行にのみアイコンを表示
 * @param {Boolean} isShowMain true: 治療状況、false: 装置一覧
 * @param {Object} dataItem
 * @return {String} "warn": 警報、"info": 報知、"": 空欄
 */
const judgeWarnInfoBlank = (isShowMain, dataItem) => {
  // 警報 (Bit3が1)
  const isWarn = (dataItem.machineStatus & 0x08) !== 0;
  // 報知 (Bit5が1)
  const isInfo = (dataItem.machineStatus & 0x20) !== 0;
  // 現在装置を使っている治療かどうか
  const usingMachine = dataItem.ordNo === dataItem.machineOrdNo;

  if (isWarn && (!isShowMain || usingMachine)) {
    return ALERT_TYPES.WARN;
  }
  if (isInfo && (!isShowMain || usingMachine)) {
    return ALERT_TYPES.INFO;
  }
  return ALERT_TYPES.NONE;
};

/**
 * sys_monitor_item ソート用field_N_sortに設定（透析装置、RO、溶解、供給）
 * @param {Array} treatSetCol 透析装置、RO、溶解、供給 のカラム情報
 * @param {Array} dataSource 画面表示に使用する各装置のデータソース
 * @param {Array} sysMonitorItems sys_monitor_itemテーブル相当のデータ（this.getSysMonitorItem）
 */
const setSortFieldSysMonitorItem = (treatSetCol, dataSource, sysMonitorItems) => {
  // 変換前のconv_itemのコードをソート用field_N_sortに設定
  // convMapを { field: conv_item } 形式のオブジェクトにする
  const convMap = {};
  treatSetCol.forEach(col => {
    const matchedItem = sysMonitorItems.find(
      item => item.moni_data_no === col.keyName && item.conv_item !== null
    );
    if (matchedItem) {
      const convObj = JSON.parse(matchedItem.conv_item);
      // moni_data_no === "31"治療モード の場合、"9": "特殊血液浄化", "10": "I-HDF" の並びを入れ替える
      if (matchedItem.moni_data_no === "31") {
        const temp = convObj["9"];
        convObj["9"] = convObj["10"];
        convObj["10"] = temp;
      }
      convMap[col.field] = convObj;
    }
  });

  // データソースにソート用field_N_sortを追加
  dataSource.forEach(row => {
    Object.keys(row).forEach(key => {
      if (Object.prototype.hasOwnProperty.call(convMap, key)) {
        const convItem = convMap[key]; // 例: { "1": "プリセット", "2": "洗浄" }
        const value = row[key];        // 既に設定されている value
        const sortKeyStr = Object.keys(convItem).find(k => convItem[k] === value);
        const sortKey = sortKeyStr !== undefined ? parseInt(sortKeyStr, 10) : null;
        row[`${key}_sort`] = sortKey;
      }
    });
  });
};

/**
 * mst_treatment_status_disp_item ソート用 field_N_sort 設定（透析装置）
 * @param {Array} dcsDataSource - データソース（行配列）
 * @param {Object} treatAllColumn - カラム情報（this.treatAllColumn）
 * @param {Array} mstPersonalUser - 利用者マスタ
 */
const setSortFieldMstDispItem = (dcsDataSource, treatAllColumn, mstPersonalUser) => {
  // ソート仕様毎の field 取得
  const nameFields = treatAllColumn.dcsTreatSetCol.filter(item => ORDER_NAME_FIELDS.includes(item.data_class)).map(item => item.field);
  const unitFields = treatAllColumn.dcsTreatSetCol.filter(item => ORDER_NUMBER_WITHOUT_UNIT_FIELDS.includes(item.data_class)).map(item => item.field);
  const maxBpFields = treatAllColumn.dcsTreatSetCol.filter(item => ORDER_MAX_BP_FIELDS.includes(item.data_class)).map(item => item.field);
  // 64: 投与状況
  const dosageStatusField = treatAllColumn.dcsTreatSetCol.find(item => item.data_class === TREATMENT_ITEM_CD.DOSAGE_STATUS)?.field;
  // 109: 指示変更
  const instructionChangeField = treatAllColumn.dcsTreatSetCol.find(item => item.data_class === TREATMENT_ITEM_CD.INSTRUCTION_CHANGE)?.field;
  // 110: 装置自己診断
  const machineSelfMeasureField = treatAllColumn.dcsTreatSetCol.find(item => item.data_class === TREATMENT_ITEM_CD.MACHINE_SELF_MEASURE)?.field;

  // データソースにソート用 field_N_sort を追加
  dcsDataSource.forEach(row => {
    Object.keys(row).forEach(key => {
      let sortValue = null;

      if (nameFields.includes(key)) {
        // スタッフ名をカナ優先文字列でソート
        const staffCd = row[key];
        if (mstPersonalUser) {
          let staff = mstPersonalUser.filter(data => data.userId == +staffCd);
          if (staff.length > 0) {
            staff = addPatNameSortToList(staff, true);
            sortValue = staff[0].userNameSort;
          }
        }
        row[`${key}_sort`] = sortValue;

      } else if (unitFields.includes(key)) {
        const value = row[key];
        const firstPart = value?.trim().split(" ")[0].trim();
        sortValue = firstPart !== "" && !isNaN(firstPart) ? Number(firstPart) : null;
        row[`${key}_sort`] = sortValue;

      } else if (maxBpFields.includes(key)) {
        const value = row[key];
        const firstPart = value?.trim().split("/")[0].trim();
        sortValue = firstPart !== "" && !isNaN(firstPart) ? Number(firstPart) : null;
        row[`${key}_sort`] = sortValue;

      } else if (dosageStatusField === key) {
        const value = row[key];
        if (value) {
          const [chkStr, countStr] = value.trim().split("/");
          const chk = parseInt(chkStr.trim()) || 0;
          const count = parseInt(countStr.trim()) || 0;
          const pending = count - chk;
          const pad = num => String(num).padStart(5, "0");
          const firstKey = pad(99999 - pending);
          const secondKey = pad(99999 - count);
          sortValue = `${firstKey}_${secondKey}`;
          row[`${key}_sort`] = sortValue;
        }

      } else if (instructionChangeField === key) {
        if (row["ordNo"] !== null && row["IsContentChanged"] === "1") {
          sortValue = 2;
        } else if (row["ordNo"] !== null && row["IsContentChanged"] === "2") {
          sortValue = 1;
        } else if (row["patId"] !== null && (row["IsContentChanged"] === "0" || row["IsContentChanged"] === null)) {
          sortValue = 3;
        }
        row[`${key}_sort`] = sortValue;

      } else if (machineSelfMeasureField === key) {
        switch (row["machineRecordCd"]) {
          case "G100": sortValue = 4; break;
          case "G101": sortValue = 1; break;
          case "G102": sortValue = 3; break;
          default: sortValue = 2; break;
        }
        row[`${key}_sort`] = sortValue;
      }
    });
  });
};

export default {
  constant,
  getInitializeViewCondition,
  buildComboBoxItemsTreatmentLayout,
  judgeWarnInfoBlank,
  setSortFieldSysMonitorItem,
  setSortFieldMstDispItem
};
