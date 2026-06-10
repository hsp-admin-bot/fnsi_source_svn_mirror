/**
 * 稼働ビューア系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

function isNkkFacility() {
  return store.getters["account-edit/isNkkFacility"];
}

/**
 * パラメータ付きのAPI(Get)を実行する.
 * パラメータは以下固定とする.
 *  {
 *    isNkkFacility
 *  }
 *
 * @param {String} url リクエストするURL
 * @param 実行した結果
 */
function getWithIsNkkFacility(url) {
  const param = {
    isNkkFacility: isNkkFacility()
  };
  return ApiHelper.get(url, param);
}

/**
 * （稼働ビューア施設一覧）
 * 施設一覧検索.
 * @param {Number} userId ユーザーID
 * @param {Boolean} autoRefreshFlag 自動更新フラグ
 */
export function sendRequestFetchFacilities(userId, autoRefreshFlag) {
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["operation-viewer/facility/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  return getWithIsNkkFacility(autoRefreshFlag ? `/facilities/${userId}${queryParams}` : `/facilities/${userId}`);
}

/**
 * （稼働ビューア）
 * 施設コードに紐づく装置一覧取得
 * @param {*} facilityCd 施設コード
 * @param {*} autoRefreshFlag 自動更新フラグ
 */
export function sendRequestFindMachines(facilityCd, autoRefreshFlag) {
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["operation-viewer/facility/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  return getWithIsNkkFacility(autoRefreshFlag ? `/machines/${facilityCd}${queryParams}` : `/machines/${facilityCd}`);
}

/**
 * （稼働ビューア）
 * 施設コード、型式コード、製造番号に該当する装置情報取得
 * @param {*} params リクエストパラメータ
 */
export function sendRequestGetMachine(params) {
  return ApiHelper.get(
    `/machines/${params.facilityCd}/${params.machineTypeCd}/${
      params.machineSerial
    }`
  );
}

/**
 * （稼働ビューア）
 * 対象装置の自己診断判定情報を取得
 * @param {*} machineTypeCd 型式コード
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetSelfMeasureResult(facilityCd, machineTypeCd) {
  return ApiHelper.get(
    `/machines/${facilityCd}/${machineTypeCd}`);
}

/**
 * （装置記録）
 * 装置記録Store用APIのURL生成
 * @param {*} urlBase ベースURL
 * @param {*} params URLに組み込むパラメータ
 */
function buildRequestUrlForMotionRecord(urlBase, params) {
  let url = urlBase;
  if (params.facilityCd) {
    url = `${url}/${params.facilityCd}`;
  }
  if (params.machineTypeCd) {
    url = `${url}/${params.machineTypeCd}`;
  }
  if (params.machineSerial) {
    url = `${url}/${params.machineSerial}`;
  }
  if (typeof params.userTypeCd !== "undefined") {
    url = `${url}/${params.userTypeCd}`;
  }
  if (params.baseDate) {
    url = `${url}/${params.baseDate}`;
  }
  if (params.startDate) {
    url = `${url}/${params.startDate}`;
  }
  if (params.endDate) {
    url = `${url}/${params.endDate}`;
  }
  if (params.offset !== undefined) {
    url = `${url}/${params.offset}`;
  }
  return url;
}

/**
 * （装置記録）
 * 装置記録Store用APIのクエリパラメータ生成
 * @param {*} params クエリパラメータに組み込むパラメータ
 */
function buildMotionRecordsFilterQuery(params) {
  return {
    dataType: (params.dataType ?? []).join(','),
    freeWord: (params.freeWord ?? '').trim()
  }
}

/**
 * （装置記録）
 * 与えられた緊急発報、予防保守のどちらかの未対処を全て対処済に更新
 * @param {*} params リクエストパラメータ
 */
export function sendRequestUpdateAllCorrection(params) {
  return ApiHelper.put("/motion_record/detail/all_target_corrections/", params);
}

/**
 * （装置記録）
 * 装置記録一覧取得
 * @param {*} params リクエストパラメータ
 */
export function sendRequestFetchMotionRecords(params) {
  return ApiHelper.get(
    buildRequestUrlForMotionRecord("/motion_record", params)
  );
}

/**
 * （装置記録）
 * 指定された期間内の装置記録を取得
 * @param {*} params リクエストパラメータ
 */
export function sendRequestFindMotionRecords(params) {
  const { autoRefreshFlag, ..._params } = params;
  const baseUrl = buildRequestUrlForMotionRecord("/motion_record/period", _params);
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["operation-viewer/facility/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const requestUrl = autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return ApiHelper.get(requestUrl, buildMotionRecordsFilterQuery(_params));
}

/**
 * （装置記録）
 * 指定された期間内の装置記録を取得
 * @param {*} params リクエストパラメータ
 */
export function sendRequestFindMotionRecordsTotal(params) {
  return ApiHelper.get(
    buildRequestUrlForMotionRecord("/motion_record/period/total", params),
    buildMotionRecordsFilterQuery(params)
  );
}


/**
 * （装置記録）
 * 部品の運転/交換時間取得
 * @param {*} params リクエストパラメータ
 */
export function sendRequestGetPartsRunning(params) {
  const { autoRefreshFlag, ..._params } = params;
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["operation-viewer/facility/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const baseUrl = buildRequestUrlForMotionRecord("/machines/parts_running", _params);
  const requestUrl = autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return ApiHelper.get(requestUrl);
}

/**
 * （装置記録）
 * ユーザーID、施設コードに紐付くデータ収集ステータスを取得
 * @param {*} userId ユーザーID（内部）
 * @param {*} facilityCd 施設コード
 */
export function sendRequestFetchGatheringStatus(userId, facilityCd) {
  return ApiHelper.get(
    `/motion_record/gathering_status/${userId}/${facilityCd}`
  );
}

/**
 * （装置記録詳細）
 *
 */
/**
 * （装置記録詳細）
 * 装置記録詳細検索.
 * @param {*} motionRecord 装置記録情報
 */
export function sendRequestFetchMotionRecordDetail(motionRecord) {
  const params = [
    `${motionRecord.motionRecordNo}`,
    `${motionRecord.dataType}`,
    `${motionRecord.facilityCd}`,
    `${motionRecord.machineTypeCd}`,
    `${motionRecord.machineSerial}`,
    `${motionRecord.baseDate}`,
    `${motionRecord.offset}`
  ];

  const baseUrl = `/motion_record/detail/${params.join("/")}`;
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["operation-viewer/facility/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const requestUrl = motionRecord.autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return ApiHelper.get(requestUrl);
}

/**
 * （装置記録詳細）
 * isCorrectionの状態変更.
 * @param {*} request リクエスト情報
 */
export function sendRequestChangeIsCorrection(request) {
  return ApiHelper.put(`/motion_record/detail/correction`, request);
}

/**
 * （装置記録詳細）
 * 自己診断グラフデータ取得
 * @param {*} motionRecord 装置記録情報
 * @param {*} testType テスト種別
 */
export function sendRequestFetchDetailGraphs(motionRecord, testType) {
  const params = [
    `${motionRecord.facilityCd}`,
    `${motionRecord.machineTypeCd}`,
    `${motionRecord.machineSerial}`,
    `${testType}`,
    `${motionRecord.baseDate}`,
    `${motionRecord.weeks}`
  ];

  const baseUrl = `/motion_record/detail/graphs/${params.join("/")}`;
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["operation-viewer/facility/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const requestUrl = motionRecord.autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return ApiHelper.get(requestUrl);
}

/**
 * （装置記録詳細）
 * 溶解記録グラフデータ取得
 * @param {*} motionRecord 装置記録情報
 */
export function sendRequestFetchDetailGraphsDissolution(motionRecord) {
  const params = [
    `${motionRecord.facilityCd}`,
    `${motionRecord.machineTypeCd}`,
    `${motionRecord.machineSerial}`,
    `${motionRecord.baseDate}`,
    `${motionRecord.weeks}`
  ];

  const baseUrl = `/motion_record/detail/graphs/dissolution/${params.join("/")}`;
  // 自動更新サインアウトON/OFFチェック
  const forceSignOutFlag = store.getters["operation-viewer/facility/getForceSignOutFlag"];
  const queryParams = forceSignOutFlag == 0 ? "?__background_call__=true" : "";
  const requestUrl = motionRecord.autoRefreshFlag ? `${baseUrl}${queryParams}` : baseUrl;
  return ApiHelper.get(requestUrl);
}

/**
 * （装置記録詳細）
 * ダウンロードデータ取得
 * @param {*} motionRecord リクエスト情報
 */
export function sendRequestFetchDetailGatheringDownload(request) {
  return ApiHelper.post(`/motion_record/detail/gathering/download`, request);
}

/**
 * （装置記録）
 * 与えらた以下の条件に合致する警報通知又は予防保守のサービス対応区分を更新する.
 *  ・施設コード
 *  ・型式コード
 *  ・製造番号
 *
 * @param {*} params リクエストパラメータ
 * @returns {Boolean} 更新が成功した場合trueを返却する.
 */
export function sendRequestUpdateServiceSupportAll(params) {
  return ApiHelper.put(`/motion_record/detail/all_service_support`, params);
}

/**
 * （装置記録）
 * 特定の警報通知又は予防保守のサービス対応区分を更新する.
 *
 * @param {*} params リクエストパラメータ
 * @returns {Boolean} 更新が成功した場合trueを返却する.
 */
export function sendRequestUpdateServiceSupport(params) {
  return ApiHelper.put(`/motion_record/detail/service_support`, params);
}

/**
 * （装置記録詳細への遷移）
 * 装置情報と装置動作記録番号に該当する装置動作記録を取得する.
 * @param {*} facilityCd 施設コード
 * @param {*} machineTypeCd 型式コード
 * @param {*} machineSerial 製造番号
 * @param {*} motionRecordNo 装置動作記録番号
 * @return 装置情報および装置動作記録番号に該当する装置動作記録
 */
export function sendRequestGetMachineRecordByMachineAndMotionRecordNo(facilityCd, machineTypeCd, machineSerial, motionRecordNo) {
  return ApiHelper.get(`/motion_record/getByMachineAndMotionRecordNo/${facilityCd}/${machineTypeCd}/${machineSerial}/${motionRecordNo}`);
}
