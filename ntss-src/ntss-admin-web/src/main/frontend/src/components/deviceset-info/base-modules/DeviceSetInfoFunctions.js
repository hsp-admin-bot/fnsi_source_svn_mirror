import _ from "underscore";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { DEVICE_TYPE_BP, DEVICE_TYPE_BV, DEVICE_TYPE_BVUFC, DEVICE_TYPE_CPRO, DEVICE_TYPE_DC, DEVICE_TYPE_DFAS, DEVICE_TYPE_DIA, DEVICE_TYPE_ECUM, DEVICE_TYPE_IAP, DEVICE_TYPE_IHDF, DEVICE_TYPE_NA, DEVICE_TYPE_OPE, DEVICE_TYPE_PRI, DEVICE_TYPE_QBQD, DEVICE_TYPE_UFR, DEVICE_TYPE_WAR, defaultDeviceInfo, valueInfoBp, valueInfoBv, valueInfoBvufc, valueInfoCpro, valueInfoDc, valueInfoDfas, valueInfoDia, valueInfoEcum, valueInfoIap, valueInfoIhdf, valueInfoNa, valueInfoOpe, valueInfoPri, valueInfoQbqd, valueInfoUfr, valueInfoWar } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";

/**
 * @description 装置設定値(マスタ)取得
 * @param {String} facilityCd 施設コード
 * @returns {Object} 装置設定値オブジェクト
 */
export const getDeviceSetInfoMst = async facilityCd => {
  const response = await ApiHelper.get(
    `/deviceSetInfo/getDeviceSetInfoMst/${facilityCd}`
  ).catch(error => {
    throw new Error(error);
  });
  return response.data;
};

/**
 * @description 装置設定値(患者情報)取得
 * @param {Number} patId 患者ID
 * @param {String} facilityCd 施設コード
 * @returns {Object} 装置設定値オブジェクト
 */
// mod #12462 患者情報共有 Ji start
export const getDeviceSetInfoPat = async (patId, facilityCd) => {
  const url = facilityCd
    ? `/deviceSetInfo/getDeviceSetInfoPat/${patId}/${facilityCd}`
    : `/deviceSetInfo/getDeviceSetInfoPat/${patId}`;
  // const response = await ApiHelper.get(
  //   `/deviceSetInfo/getDeviceSetInfoPat/${patId}/${facilityCd}`
  // ).catch(error => {
  //   throw new Error(error);
  // });
  const response = await ApiHelper.get(url).catch(error => {
    throw new Error(error);
  });
  return response.data;
};
// mod #12462 患者情報共有 Ji end

/**
 * @description 装置設定値(指示)取得
 * @param {Number} ordNo
 * @returns {Object} 装置設定値オブジェクト
 */
export const getDeviceSetInfoOrd = async ordNo => {
  const response = await ApiHelper.get(
    `/deviceSetInfo/getDeviceSetInfoOrd/${ordNo}`
  ).catch(error => {
    throw new Error(error);
  });
  //mod FNSI-FutreNetWeb+SI課題管理 no.6042 劉全航 start
  // add FNSI-FutreNetWeb+SI課題管理No.4642 李 start
  // if (response.data && response.data['ihdf']
  //   && response.data['ihdf']['dev']
  //   && response.data['ihdf']['dev']['A']
  //   && response.data['ihdf']['dev']['A'][201]) {
  //   response.data['ihdf']['dev']['A'][201] = response.data['ihdf']['dev']['A'][201] * 1000 / 60;
  // }
  // add FNSI-FutreNetWeb+SI課題管理No.4642 李 end
  //mod FNSI-FutreNetWeb+SI課題管理 no.6042 劉全航 end

  return response.data;
};

/**
 * @description 装置設定値(マスタ)更新
 * @param {Object} devInfo 装置設定値オブジェクト
 * @param {String} facilityCd 施設コード
 */
export const updateDeviceSetInfoMst = async (devInfo, facilityCd) => {
  const deviceSetInfo = JSON.stringify(devInfo);
  await ApiHelper.post(`/deviceSetInfo/updateDeviceSetInfoMst/${facilityCd}`, {
    deviceSetInfo
  }).catch(error => {
    throw new Error(error);
  });
};

/**
 * @description 装置設定値(患者情報)更新
 * @param {Object} devInfo 装置設定値オブジェクト
 * @param {Number} patId 患者ID
 * @param {String} facilityCd 施設コード ※全患者装置設定更新時に指定
 * @param {Boolean} nextPatInfoType 次患者情報送信区分
 */
export const updateDeviceSetInfoPat = async (
  devInfo,
  patId,
  facilityCd = null,
  // add #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
  nextPatInfoType
  // add #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end
) => {
  const deviceSetInfo = JSON.stringify(devInfo);
  // mod FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
  //await ApiHelper.post(`/deviceSetInfo/updateDeviceSetInfoPat`, {
  // mod #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
  // const result = await ApiHelper.post(`/deviceSetInfo/updateDeviceSetInfoPat`, {
  // // mod FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end
  // patId,
  // facilityCd,
  // deviceSetInfo
  // }).catch(error => {
  let params;
  if (nextPatInfoType) {
    params = {
      patId,
      facilityCd,
      deviceSetInfo,
      nextPatInfoType
    }
  } else {
    params = {
      patId,
      facilityCd,
      deviceSetInfo
    }
  }

  const result = await ApiHelper.post(`/deviceSetInfo/updateDeviceSetInfoPat`, params).catch(error => {
  // add #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end
    throw new Error(error);
  });

  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
  return result;
  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end
};

/**
 * @description 装置設定値(指示)更新
 * @param {Object} devInfo 装置設定値オブジェクト
 */
export const updateDeviceSetInfoOrd = async devInfo => {
 // MOD FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
   //await ApiHelper.post(`/deviceSetInfo/updateDeviceSetInfoOrd/`, devInfo).catch(
    // error => {
      // throw new Error(error);
     //}
   //);

  const response  =await ApiHelper.post(`/deviceSetInfo/updateDeviceSetInfoOrd/`, devInfo).catch(
    error => {
      throw new Error(error);
    }
  );
  return response
// MOD FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
};

/**
 * @description 装置設定値変換用内部関数
 * @param {Object} devInfo 装置設定値オブジェクト
 * @param {Object} devInfoDef 装置設定値定義オブジェクト
 * @param {String} key1 装置設定キー1 ※pat/dev
 * @param {String} key2List 装置設定キー2 ※A/B/C(複数指定可)
 * @returns {Object}
 */
const mapEditable = (devInfo, devInfoDef, key1, ...key2List) => {
  const key2Objects = {};
  for (const key2 of key2List) {
    // key1.key2.整数キーの値を定義に従って全て変換
    key2Objects[key2] = {
      ..._.mapObject(devInfo[key1][key2], (value, key3) => {
        const initValue =
          // DB値が存在しない場合は定義された初期値を設定
          value === null ? devInfoDef[key1][key2][key3].initValue : value;
          //add FNSI改修 不明の表示を追加 房 start
          if (key1 === "dev" && key2 === "A" && ((key3>=290 && key3 <=300) || key3 == 339)) {
            // mod bug 7687 修正 chen start
            let tempList = devInfoDef[key1][key2][key3].options.filter(e=>e.value + "" === initValue + "");
            // let tempList = devInfoDef[key1][key2][key3].options.filter(e=>e.value === initValue);
            // mod bug 7687 修正 chen end
            if (tempList.length === 0) {
              devInfoDef[key1][key2][key3].options.push({
                displayValue:"不明",
                value:value
              });
            }
          }
        //add FNSI改修 不明の表示を追加 房 end
        return {
          ..._.omit(devInfoDef[key1][key2][key3], "initValue"),
          value: { initValue, editValue: initValue }
        };
      })
    };
  }
  return {
    [key1]: { ...key2Objects }
  };
};

/**
 * @description 装置設定値を画面に表示・編集できる形に変換
 * @param {Object} devInfoRaw 全装置設定値オブジェクト { dfas, dc, ... }
 * @param {String} devType 装置の種類
 * @returns {Object}
 *   {
 *     装置設定キー1(pat/dev): {
 *       装置設定キー2(A/B/C): {
 *         装置設定キー3(整数): {
 *           formName: 名称,
 *           formLabel: 表示項目名,
 *           (各入力形式に応じた定義),
 *           value: {
 *             initValue: 装置設定DB値,
 *             editValue: 装置設定編集値,
 *           },
 *         }
 *       }
 *     },
 *     ...
 *   }
 */
export const mapDeviceSetInfoEditable = (devInfoRaw, devType) => {
  // 指定した種類の装置設定値
  let devInfo;
  if (devInfoRaw) {
  let tempData = typeof devInfoRaw == "object" ? devInfoRaw : JSON.parse(devInfoRaw);
    if (tempData[devType]) {
    // 装置設定DB値がnullだったり指定した装置のJSONキーがなかったりキーはあるけどnullだったりしない
    devInfo = tempData[devType];
    }
  } else {
    // 装置設定DB値が参照できない場合は定義された初期値を設定
    devInfo = defaultDeviceInfo[devType];
  }
  let mappedDevInfo;

  switch (devType) {
    case DEVICE_TYPE_DFAS: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoDfas, "pat", "B"),
        ...mapEditable(devInfo, valueInfoDfas, "dev", "A", "B")
      };
      break;
    }
    case DEVICE_TYPE_DC: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoDc, "dev", "A", "B")
      };
      break;
    }
    case DEVICE_TYPE_NA: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoNa, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_DIA: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoDia, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_UFR: {
      console.log(2);
      console.log(valueInfoUfr);
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoUfr, "dev", "A", "B")
      };
      break;
    }
    case DEVICE_TYPE_IHDF: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoIhdf, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_QBQD: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoQbqd, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_BVUFC: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoBvufc, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_BP: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoBp, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_BV: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoBv, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_OPE: {
      mappedDevInfo = {
        ...mapEditable(
          devInfo,
          valueInfoOpe,
          "dev",
          "A",
          "B",
          "C"
        )
      };
      break;
    }
    case DEVICE_TYPE_PRI: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoPri, "pat", "A", "B"),
        ...mapEditable(devInfo, valueInfoPri, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_WAR: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoWar, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_CPRO: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoCpro, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_ECUM: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoEcum, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_IAP: {
      mappedDevInfo = {
        ...mapEditable(devInfo, valueInfoIap, "dev", "A")
      };
      break;
    }
    default:
      throw new Error("不正な装置設定種別");
  }

  return mappedDevInfo;
};

/**
 * @description 装置設定値原型変換用内部関数
 * @param {Object} devInfo 装置設定値オブジェクト
 * @param {String} devType 装置の種類
 * @param {String} key1 装置設定キー1 ※pat/dev
 * @param {String} key2List 装置設定キー2 ※A/B/C(複数指定可)
 * @returns {Object}
 */
const mapOrigin = (devInfo, key1, ...key2List) => {
  const key2Objects = {};
  for (const key2 of key2List) {
    // key1.key2.整数キーの値を編集値のみにする
    key2Objects[key2] = {
      //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start
      // ..._.mapObject(devInfo[key1][key2], key3Obj => key3Obj.value.editValue)
      ..._.mapObject(devInfo[key1][key2], key3Obj => {
        if (key3Obj.hasOwnProperty("step")){
          return Number(key3Obj.value.editValue);
        } else {
          return key3Obj.value.editValue;
        } 
      })
      //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end
    };
  }
  return {
    [key1]: { ...key2Objects }
  };
};

/**
 * @description 装置設定値を原型に戻す
 * @param {Object} devInfo 装置設定値オブジェクト
 * @param {String} devType 装置の種類
 * @param {Boolean} isEditedOnly 未編集項目の除外フラグ
 * @returns {Object}
 *   {
 *     装置設定キー1(pat/dev): {
 *       装置設定キー2(A/B/C): {
 *         装置設定キー3(整数): 装置設定編集値
 *       }
 *     },
 *     ...
 *   }
 */
export const mapDeviceSetInfoOrigin = (devInfo, devType, isEditedOnly) => {
  let mappedDevInfo;
  switch (devType) {
    case DEVICE_TYPE_DFAS: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "pat", "B"),
        ...mapOrigin(devInfo, "dev", "A", "B")
      };
      break;
    }
    case DEVICE_TYPE_DC: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A", "B")
      };
      break;
    }
    case DEVICE_TYPE_NA: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_DIA: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_UFR: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A", "B")
      };
      break;
    }
    case DEVICE_TYPE_IHDF: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_QBQD: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_BVUFC: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_BP: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_BV: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_OPE: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A", "B", "C")
      };
      break;
    }
    case DEVICE_TYPE_PRI: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "pat", "A", "B"),
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_WAR: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_CPRO: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_ECUM: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    case DEVICE_TYPE_IAP: {
      mappedDevInfo = {
        ...mapOrigin(devInfo, "dev", "A")
      };
      break;
    }
    default:
      throw new Error("不正な装置設定種別");
  }

  if (isEditedOnly) {
    mappedDevInfo = getDeviceSetInfoEdited(devInfo, mappedDevInfo);
  }

  return mappedDevInfo;
};

/**
 * @description 編集済装置設定値を取得
 * @param {Object} devInfoEditable 詳細： {@link mapDeviceSetInfoEditable}
 * @param {Object} devInfoOrigin 詳細： {@link mapDeviceSetInfoOrigin}
 * @returns {Object}
 */
const getDeviceSetInfoEdited = (devInfoEditable, devInfoOrigin) => {
  // 階層化JSONの取得
  const devInfo = _.mapObject(devInfoOrigin, (editValue, key) =>
    typeof editValue === "object"
      ? getDeviceSetInfoEdited(devInfoEditable[key], editValue)
      : editValue
  );

  // 未編集項目を取り除く
  const devEdited = _.omit(devInfo, (editValue, key) =>
    typeof editValue === "object"
      ? _.isEmpty(editValue)
      : editValue === devInfoEditable[key].value.initValue
  );

  return devEdited;
};

/**
 * @description 装置の種類に応じたマスタ装置設定キー(ord/pat)を取得
 * @param {String} devType 装置の種類
 * @returns {String}
 */
export const getMstJsonKey = devType => {
  let key = "";
  switch (devType) {
    case DEVICE_TYPE_DC:
    case DEVICE_TYPE_NA:
    case DEVICE_TYPE_DIA:
    case DEVICE_TYPE_IHDF:
    case DEVICE_TYPE_QBQD:
    case DEVICE_TYPE_BVUFC:
    case DEVICE_TYPE_UFR:
      key = "ord";
      break;

    case DEVICE_TYPE_BP:
    case DEVICE_TYPE_BV:
    case DEVICE_TYPE_OPE:
    case DEVICE_TYPE_PRI:
    case DEVICE_TYPE_WAR:
    case DEVICE_TYPE_CPRO:
    case DEVICE_TYPE_DFAS:
    case DEVICE_TYPE_ECUM:
    case DEVICE_TYPE_IAP:
      key = "pat";
      break;
  }
  return key;
};

/**
 * @description 装置設定のチャート用スイッチ値を取得
 * @param {String} devType 装置の種類
 * @param {Object} devInfo 装置設定値オブジェクト
 * @returns {String}
 */
export const getChartMode = (devType, devInfo) => {
  switch (devType) {
    case DEVICE_TYPE_UFR:
      if (devInfo.dev.A[290] === null || devInfo.dev.A[290] === undefined) {
        return null;
      } else if (Number(devInfo.dev.A[290]) === 0) {
        return "off";
      } else if (Number(devInfo.dev.A[290]) === 1) {
        return "ufr-step";
      } else if (Number(devInfo.dev.A[290]) === 2) {
        return "ufr-course";
      } else {
        return null;
      }
    case DEVICE_TYPE_NA:
      if (devInfo.dev.A[315] === null || devInfo.dev.A[315] === undefined) {
        return null;
      } else if (Number(devInfo.dev.A[315]) === 0) {
        return "off";
      } else if (Number(devInfo.dev.A[315]) === 1) {
        return "na-step";
      } else if (Number(devInfo.dev.A[315]) === 2) {
        return "na-course";
      } else {
        return null;
      }
    case DEVICE_TYPE_DC:
      if (devInfo.dev.A[340] === null || devInfo.dev.A[340] === undefined) {
        return null;
      } else if (Number(devInfo.dev.A[340]) === 0) {
        return "off";
      } else if (
        // mod FNSI-濃度プログラムの修正 楊 start
        // Number(devInfo.dev.A[340]) === 1 ||
        // Number(devInfo.dev.A[340]) === 2
        Number(devInfo.dev.A[340]) === 2
        // mod FNSI-濃度プログラムの修正 楊 end
      ) {
        return ["b-fluid-conc-step", "dialysate-conc-step"];
        // mod FNSI-濃度プログラムの修正 楊 start
      // } else if (Number(devInfo.dev.A[340]) === 3) {
      } else if (Number(devInfo.dev.A[340]) === 3) {
        // mod FNSI-濃度プログラムの修正 楊 end
        return ["b-fluid-conc-course", "dialysate-conc-course"];
      } else {
        return null;
      }
    case DEVICE_TYPE_QBQD:
      if (
        (devInfo.dev.A[430] === null || devInfo.dev.A[430] === undefined) &&
        (devInfo.dev.A[431] === null || devInfo.dev.A[431] === undefined)
      ) {
        return null;
      } else if (
        Number(devInfo.dev.A[430]) === 0 &&
        Number(devInfo.dev.A[431]) === 0
      ) {
        return "off";
      } else if (
        Number(devInfo.dev.A[430]) === 1 ||
        Number(devInfo.dev.A[431]) === 1
      ) {
        return "qbqd-step";
      } else {
        return null;
      }
    case DEVICE_TYPE_IHDF:
      return "ihdf-step";
    case DEVICE_TYPE_BVUFC:
      if (devInfo.dev.A[196] === null || devInfo.dev.A[196] === undefined) {
        return null;
      } else if (Number(devInfo.dev.A[196]) === 0) {
        return "off";
      } else if (Number(devInfo.dev.A[196]) === 1) {
        return "bvufc-text";
      } else {
        return null;
      }
    case DEVICE_TYPE_DIA:
      if (devInfo.dev.A[282] === null || devInfo.dev.A[282] === undefined) {
        return null;
      } else if (Number(devInfo.dev.A[282]) === 0) {
        return "off";
      } else if (Number(devInfo.dev.A[282]) === 1) {
        return "dia-text";
      } else {
        return null;
      }
    default:
      break;
  }
};

/**
 * @description チャート表示用データを作成
 * @param {String} devType 装置の種類
 * @param {Object} devInfo 装置設定値オブジェクト
 * @param {Object} condInfo 治療条件値オブジェクト
 * @returns {Object}
 */
export const createChartData = (devType, devInfo, condInfo) => {
  const createQbqdData = (chartData, flowArray, changeoverTime, xAxisMax) => {
    // グラフx軸設定
    if (!condInfo["1"].value) {
      // 「透析時間："00:00"」x軸を"04:00"まで表示
      for (let i = 0; i < 5; i++) {
        // ※5固定値："04:00"までグラフ空で表示
        chartData.push(null);
      }
    } else {
      // x軸
      let xAxis = 0;
      // 次のx軸：※階段グラフ用
      let stepsXAxis = 0;

      let isLastFlow = false;

      // グラフ値設定
      flowArray.forEach((item, index) => {
        // y軸：流量値
        let setData = parseInt(item);

        // ステップ数：ステップ数は1から連番、配列要素数は0から連番
        const stepNumber = devInfo.dev.A[429] - 1;

        // グラフ表示用y軸値設定：ステップ数以降の流量値をステップ数の流量値に設定
        if (index >= stepNumber) {
          // ステップ数以降の流量値
          setData = parseInt(flowArray[stepNumber]);
        }

        // x軸値設定：切替時間を設定※経過を表示するため次のx軸を設定
        xAxis = stepsXAxis;

        // 次のx軸(階段グラフ用)を設定：切替時間値を設定
        if (index < changeoverTime.length) {
          // 配列要素数がある場合
          const changeoverTimeConv = changeoverTime[index] / 60;
          // 次のx軸：※階段グラフ用を設定
          stepsXAxis += changeoverTimeConv;
        } else {
          // 配列要素数がない場合
          const maxDialysisDisplayTime = 10;
          // x軸を最大10時間になるよう値を設定
          if (stepsXAxis <= maxDialysisDisplayTime) {
            // x軸値が最大10時間を超えていない場合
            stepsXAxis = maxDialysisDisplayTime;
          }
          isLastFlow = true;
        }

        // 階段グラフ表示用データ
        const stepsChartData = flowArray.map(() => [stepsXAxis, setData]);

        chartData.push([xAxis, setData], stepsChartData[index]);

        const maxDialysisTime = 10;
        if (xAxisMax > maxDialysisTime && isLastFlow) {
          // 10時間以降：＋1ずつ設定
          for (let i = 10; i < xAxisMax; i++) {
            chartData.push([i + 1, setData]);
          }
          isLastFlow = false;
        }
      });
    }
  };

  if (devType === DEVICE_TYPE_UFR) {
    const stepNumber = devInfo.dev.A[311];
    let stepValues = Object.values(devInfo.dev.B);
    stepValues = stepValues.map((device, index) => {
      return index < stepNumber ? device : null;
    });

    return {
      mode: getChartMode(devType, devInfo),
      courseValue: devInfo.dev.A[312],
      courseStartValue: devInfo.dev.A[313],
      courseEndValue: devInfo.dev.A[314],
      stepValues
    };
  } else if (devType === DEVICE_TYPE_NA) {
    return {
      mode: getChartMode(devType, devInfo),
      courseValue: devInfo.dev.A[328],
      courseStartValue: devInfo.dev.A[329],
      courseEndValue: devInfo.dev.A[330],
      stepValues: [
        devInfo.dev.A[316],
        devInfo.dev.A[317],
        devInfo.dev.A[318],
        devInfo.dev.A[319],
        devInfo.dev.A[320],
        devInfo.dev.A[321],
        devInfo.dev.A[322],
        devInfo.dev.A[323],
        devInfo.dev.A[324],
        devInfo.dev.A[325]
      ]
    };
  } else if (devType === DEVICE_TYPE_DC) {
    const stepValueA = [
      devInfo.dev.B[10],
      devInfo.dev.B[11],
      devInfo.dev.B[12],
      devInfo.dev.B[13],
      devInfo.dev.B[14],
      devInfo.dev.B[15],
      devInfo.dev.B[16],
      devInfo.dev.B[17],
      devInfo.dev.B[18],
      devInfo.dev.B[19]
    ];

    const stepValueB = [
      devInfo.dev.B[20],
      devInfo.dev.B[21],
      devInfo.dev.B[22],
      devInfo.dev.B[23],
      devInfo.dev.B[24],
      devInfo.dev.B[25],
      devInfo.dev.B[26],
      devInfo.dev.B[27],
      devInfo.dev.B[28],
      devInfo.dev.B[29]
    ];

    const chartType = devInfo.dev.A[340] === "1";
    const chartMode = getChartMode(devType, devInfo);

    return [
      {
        mode: chartMode && chartMode[0],
        courseValue: devInfo.dev.A[364],
        courseStartValue: devInfo.dev.A[365],
        courseEndValue: devInfo.dev.A[366],
        stepValues: [
          stepValueA,
          [
            devInfo.dev.A[351],
            devInfo.dev.A[352],
            devInfo.dev.A[353],
            devInfo.dev.A[354],
            devInfo.dev.A[355],
            devInfo.dev.A[356],
            devInfo.dev.A[357],
            devInfo.dev.A[358],
            devInfo.dev.A[359],
            devInfo.dev.A[360]
          ]
        ]
      },
      {
        mode: chartMode && chartMode[1],
        courseValue: devInfo.dev.A[361],
        courseStartValue: devInfo.dev.A[362],
        courseEndValue: devInfo.dev.A[363],
        stepValues: [
          chartType ? stepValueA : stepValueB,
          [
            devInfo.dev.A[341],
            devInfo.dev.A[342],
            devInfo.dev.A[343],
            devInfo.dev.A[344],
            devInfo.dev.A[345],
            devInfo.dev.A[346],
            devInfo.dev.A[347],
            devInfo.dev.A[348],
            devInfo.dev.A[349],
            devInfo.dev.A[350]
          ]
        ]
      }
    ];
  } else if (devType === DEVICE_TYPE_QBQD) {
    const qdSwitch = parseInt(devInfo.dev.A[431]);
    const qbSwitch = parseInt(devInfo.dev.A[430]);
    const changeoverTime = [
      devInfo.dev.A[420],
      devInfo.dev.A[421],
      devInfo.dev.A[422],
      devInfo.dev.A[423],
      devInfo.dev.A[424],
      devInfo.dev.A[425],
      devInfo.dev.A[426],
      devInfo.dev.A[427],
      devInfo.dev.A[428]
    ];
    const dialysisfluidFlow = [
      devInfo.dev.A[410],
      devInfo.dev.A[411],
      devInfo.dev.A[412],
      devInfo.dev.A[413],
      devInfo.dev.A[414],
      devInfo.dev.A[415],
      devInfo.dev.A[416],
      devInfo.dev.A[417],
      devInfo.dev.A[418],
      devInfo.dev.A[419]
    ];
    const bloodFlow = [
      devInfo.dev.A[400],
      devInfo.dev.A[401],
      devInfo.dev.A[402],
      devInfo.dev.A[403],
      devInfo.dev.A[404],
      devInfo.dev.A[405],
      devInfo.dev.A[406],
      devInfo.dev.A[407],
      devInfo.dev.A[408],
      devInfo.dev.A[409]
    ];
    const qbStepValues = [];
    const qdStepValues = [];
    const xAxisMax = condInfo["1"].value ? condInfo["1"].value / 60 : 0;
    const chartValues = [];

    if (parseInt(qdSwitch)) {
      createQbqdData(qdStepValues, dialysisfluidFlow, changeoverTime, xAxisMax);
      chartValues.push(qdStepValues);
    } else {
      // グラフの色を配列要素数で指定しているため、データがない場合でもnullを設定する
      chartValues.push(null);
    }

    if (parseInt(qbSwitch)) {
      createQbqdData(qbStepValues, bloodFlow, changeoverTime, xAxisMax);
      chartValues.push(qbStepValues);
    } else {
      // グラフの色を配列要素数で指定しているため、データがない場合でもnullを設定する
      chartValues.push(null);
    }
    return {
      mode: getChartMode(devType, devInfo),
      stepValues: chartValues,
      xAxisMax
    };
  } else if (devType === DEVICE_TYPE_IHDF) {
    let supplyLiquid = [
      devInfo.dev.A[435],
      devInfo.dev.A[436],
      devInfo.dev.A[437],
      devInfo.dev.A[438],
      devInfo.dev.A[439],
      devInfo.dev.A[440],
      devInfo.dev.A[441],
      devInfo.dev.A[442],
      devInfo.dev.A[443],
      devInfo.dev.A[444],
      devInfo.dev.A[445],
      devInfo.dev.A[446],
      devInfo.dev.A[447],
      devInfo.dev.A[448],
      devInfo.dev.A[449],
      devInfo.dev.A[450]
    ];
    let recoveredAmount = [
      devInfo.dev.A[451] * -1,
      devInfo.dev.A[452] * -1,
      devInfo.dev.A[453] * -1,
      devInfo.dev.A[454] * -1,
      devInfo.dev.A[455] * -1,
      devInfo.dev.A[456] * -1,
      devInfo.dev.A[457] * -1,
      devInfo.dev.A[458] * -1,
      devInfo.dev.A[459] * -1,
      devInfo.dev.A[460] * -1,
      devInfo.dev.A[461] * -1,
      devInfo.dev.A[462] * -1,
      devInfo.dev.A[463] * -1,
      devInfo.dev.A[464] * -1,
      devInfo.dev.A[465] * -1,
      devInfo.dev.A[466] * -1
    ];

    const stepNumber = devInfo.dev.A[433];
    const isUseProgram = Number(devInfo.dev.A[432]);

    // UFRプログラムを使用しない場合、「I-HDF 補液量設定」の値を与える
    if (!isUseProgram) {
      supplyLiquid = supplyLiquid.map(() => devInfo.dev.A[200]);
      recoveredAmount = recoveredAmount.map(() => devInfo.dev.A[200] * -1);
    }

    supplyLiquid = supplyLiquid.map((item, index) =>
      index < stepNumber ? item : null
    );

    recoveredAmount = recoveredAmount.map((item, index) =>
      index < stepNumber ? item : null
    );

    return {
      mode: getChartMode(devType, devInfo),
      stepValues: [supplyLiquid, recoveredAmount],
      title: isUseProgram ? "I-HDFプログラム" : "I-HDF"
    };
  }
};
