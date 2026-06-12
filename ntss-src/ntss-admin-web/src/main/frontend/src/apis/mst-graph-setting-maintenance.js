/**
 * P-Ca9分割グラフ設定マスタ系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL
 */
const URL_BASE = "/master_maintenance/mst_graph_setting";

/**
 * P-Ca9分割グラフ一覧の取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstGraphSettingData(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/${facilityCd}`);
}

/**
 * P-Ca9分割グラフ設定データ取得
 */
export function sendRequestGetMstGraph() {
  return ApiHelper.get(`${URL_BASE}/mst_facility`);
}
// FNSI-修正 設定値の大小チェック対応 Huangxl add start
/**
 * 施設別サインイン用設定値取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetValueSignInByFacilityCd(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/get_value_signin/${facilityCd}`);
}

/**
 * API から取得したグラフ設定を画面用に数値へ展開する（setting[0] を参照してプロパティを付与）
 * @param {object} setting ミューテート対象
 */
export function formatGraphSettings(setting) {
  setting.limitLowerThresholdX = parseFloat(setting[0].limitLowerThresholdX);
  setting.limitLowerThresholdY = parseFloat(setting[0].limitLowerThresholdY);
  setting.limitLowerX = parseFloat(setting[0].limitLowerX);
  setting.limitLowerY = parseFloat(setting[0].limitLowerY);
  setting.limitUpperThresholdX = parseFloat(setting[0].limitUpperThresholdX);
  setting.limitUpperThresholdY = parseFloat(setting[0].limitUpperThresholdY);
  setting.limitUpperX = parseFloat(setting[0].limitUpperX);
  setting.limitUpperY = parseFloat(setting[0].limitUpperY);
}
/**
 * 設定不備メッセージ（HTML 断片）を組み立てる
 * @param {Array<Record<string, string>>} graphSetting グラフ設定行（先頭行を使用）
 * @returns {string}
 */
export function settingErrorMessage(setting) {
  let missingSettingStatus = "";

  // ①X軸グラフ閾値上限 ≦ X軸グラフ閾値下限
  if (parseFloat(setting[0].limitUpperThresholdX) < parseFloat(setting[0].limitLowerThresholdX)) {
    missingSettingStatus += "<br>X軸グラフ閾値上限 ＜ X軸グラフ閾値下限";
  }

  // ①Y軸グラフ閾値上限 ≦ Y軸グラフ閾値下限
  if (parseFloat(setting[0].limitUpperThresholdY) < parseFloat(setting[0].limitLowerThresholdY)) {
    missingSettingStatus += "<br>Y軸グラフ閾値上限 ＜ Y軸グラフ閾値下限";
  }

  // ②X軸グラフ閾値下限 ＜ X軸グラフ下限値
  if (parseFloat(setting[0].limitLowerThresholdX) < parseFloat(setting[0].limitLowerX)) {
    missingSettingStatus += "<br>X軸グラフ閾値下限 ＜ X軸グラフ下限値";
  }
  // ②Y軸グラフ閾値下限 ＜ Y軸グラフ下限値
  if (parseFloat(setting[0].limitLowerThresholdY) < parseFloat(setting[0].limitLowerY)) {
    missingSettingStatus += "<br>Y軸グラフ閾値下限 ＜ Y軸グラフ下限値";
  }

  // ③X軸グラフ上限値 ＜ X軸グラフ閾値上限
  if (parseFloat(setting[0].limitUpperX) < parseFloat(setting[0].limitUpperThresholdX)) {
    missingSettingStatus += "<br>X軸グラフ上限値 ＜ X軸グラフ閾値上限";
  }
  // ③Y軸グラフ上限値 ＜ Y軸グラフ閾値上限
  if (parseFloat(setting[0].limitUpperY) < parseFloat(setting[0].limitUpperThresholdY)) {
    missingSettingStatus += "<br>Y軸グラフ上限値 ＜ Y軸グラフ閾値上限";
  }

  // ④X軸グラフ上限値 ≦ X軸グラフ下限値
  if (parseFloat(setting[0].limitUpperX) <= parseFloat(setting[0].limitLowerX)) {
    missingSettingStatus += "<br>X軸グラフ上限値 ≦ X軸グラフ下限値";
  }
  // ④Y軸グラフ上限値 ≦ Y軸グラフ下限値
  if (parseFloat(setting[0].limitUpperY) <= parseFloat(setting[0].limitLowerY)) {
    missingSettingStatus += "<br>Y軸グラフ上限値 ≦ Y軸グラフ下限値";
  }
  return missingSettingStatus;
}
// FNSI-修正 設定値の大小チェック対応 Huangxl add end