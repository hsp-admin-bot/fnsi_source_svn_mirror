/**
 * 帳票系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import { createApiFormData } from "@/apis/ApiRuntime";
import { dateFormat } from "@/functions/common/DateTimeUtils";

// add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
import store from "@/stores";
// add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
}
/**
 * 帳票HTML取得
 * @param {Record<string, unknown>} reportParam 帳票パラメータ
 */
export function sendRequestCreatingReport(reportParam) {
  return ApiHelper.post(`/report/creating-report`, addPath(reportParam));
}

/**
 * 帳票HTML取得(レポートコード指定)
 * @param {string} reportCd レポートコード
 * @param {Record<string, unknown>} reportParam 帳票パラメータ
 */
export function sendRequestCreatingReportByCd(reportCd, reportParam, selectedPatId) {
  const queryParams = withSelectedPatId(undefined, selectedPatId);
  if (queryParams) {
    return ApiHelper.configPost(
      `/report/creating-report/${reportCd}`,
      addPath(reportParam),
      { params: queryParams }
    );
  }
  return ApiHelper.post(
    `/report/creating-report/${reportCd}`,
    addPath(reportParam)
  );
}

/**
 * BVMS 帳票プレビュー（ordNo 指定）
 * @param {string} graphName グラフ名
 * @param {Record<string, unknown>} param パラメータ
 */
export function sendRequestCreatingReportForBVMS(graphName, param) {
  const ordNo = param.ordNo;
  if (ordNo !== null) {
    return ApiHelper.post(`/bvms/${graphName}/preview-report/${ordNo}`, param);
  }
}

/**
 * BVMS 帳票プレビュー（アップロードファイル）
 * @param {string} graphName グラフ名
 * @param {Record<string, unknown>} param パラメータ
 */
export function sendRequestCreatingReportForBVMSWithUploadFile(graphName, param) {
  const ordNo = param.ordNo;
  if (ordNo !== null) {
    const formData = setFormData(param, graphName, false);
    return ApiHelper.post(`/bvms/${graphName}/preview-report/byUploadFile/${ordNo}`, formData);
  }
}

/**
 * BVMS 帳票印刷
 * @param {string} graphName グラフ名
 * @param {Record<string, unknown>} param パラメータ
 */
export function printReportForBVMS(graphName, param) {
  const ordNo = param.ordNo;
  if (ordNo !== null) {
    return ApiHelper.post(`/bvms/${graphName}/creating-report/${ordNo}`, addPathBVMS(param));
  }
}

/**
 * BVMS 帳票印刷（アップロードファイル）
 * @param {string} graphName グラフ名
 * @param {Record<string, unknown>} param パラメータ
 */
export function printReportForBVMSWithUploadFile(graphName, param) {
  const ordNo = param.ordNo;
  if (ordNo !== null) {
    const formData = setFormData(param, graphName, true);
    return ApiHelper.post(`/bvms/${graphName}/creating-report/byUploadFile/${ordNo}`, formData);
  }
}

/**
 * 帳票マスタ取得
 * @param {string} funcCd 機能コード
 * @param {string} printFlag 印刷フラグ
 * @param {boolean} [autoRefreshFlag] バックグラウンド取得
 */
// mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 start
//export function sendRequestGetMstReport(funcCd) {
  //return ApiHelper.get(`/report/mst-report/${funcCd}`);
export function sendRequestGetMstReport(funcCd, printFlag, autoRefreshFlag, selectedPatId) {
  //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
  // return ApiHelper.get(`/report/mst-report/${funcCd}/${printFlag}`);
  const selPat = store.getters["split-graph/getSelPat"];
  if (selPat != null) {
    const selectPat = store.getters["split-graph/getSelectPat"];
    if (selectPat == null) {
      printFlag = "0";
    } else {
      printFlag = "1";
    }
    const requestUrl = autoRefreshFlag ? `/report/mst-report/${funcCd}/${printFlag}?__background_call__=true` : `/report/mst-report/${funcCd}/${printFlag}`;
    return ApiHelper.get(requestUrl, withSelectedPatId(undefined, selectedPatId));
  } else {
    const requestUrl = autoRefreshFlag ? `/report/mst-report/${funcCd}/${printFlag}?__background_call__=true` : `/report/mst-report/${funcCd}/${printFlag}`;
    return ApiHelper.get(requestUrl, withSelectedPatId(undefined, selectedPatId));
  }
  //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
// mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 end
}

/**
 * PDF/Excelファイル格納先パスを追加
 * ※出力したくない場合は`null`を設定しておくこと
 * @param {Record<string, unknown>} reportParam 帳票パラメータ
 */
function addPath(reportParam) {
  // プレビューの場合は何もしない
  if (reportParam.isPreview) {
    return reportParam;
  }
  // mod 5831 同じ機能帳票データが複数回印刷されることがある  吉 start
  // const suffix = `${reportParam.dataKey.patId}_${reportParam.dataKey.ordNo}_${dateFormat.format(new Date(), "yyyyMMddhhmmss")}`;
  let fileName = "";
  if (reportParam.dataKey.ordNo != null) {
    fileName = `${reportParam.dataKey.patId}_${reportParam.dataKey.ordNo}_${dateFormat.format(new Date(), "yyyyMMddhhmmss")}`;
  }
  if (reportParam.dataKey.ordNo == null) {

    // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
    // // mod 5826 スケジュール画面の機能帳票でスケジュール表を印刷しても正しく印刷ができない  吉 start
    // if (null == reportParam.dataKey.patId) {
    //   fileName = `${dateFormat.format(new Date(), "yyyyMMddhhmmss")}`;
    // }
    // // mod 5826 同じ機能帳票データが複数回印刷されることがある  吉 end
    // if (null != reportParam.dataKey.patId) {
    //   fileName = `${reportParam.dataKey.patId}_${dateFormat.format(new Date(), "yyyyMMddhhmmss")}`;
    // }
    if (reportParam.dataKey.patId != null && (typeof reportParam.dataKey.patId === "string" || typeof reportParam.dataKey.patId === "number")) {
      fileName = `${reportParam.dataKey.patId}_${dateFormat.format(new Date(), "yyyyMMddhhmmss")}`;
    } else {
      fileName = `${dateFormat.format(new Date(), "yyyyMMddhhmmss")}`;
    }
    // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
  }
  const suffix = fileName;
  // mod 5831 同じ機能帳票データが複数回印刷されることがある  吉 end
  // PDF格納先パス(Amazon S3) が未定義の場合は追加
  if (reportParam.pdfPath === undefined) {
    reportParam.pdfPath = `pdf/dialysisReport_${suffix}.pdf`;
  }

  // Excelファイル格納先パス(Amazon S3) が未定義の場合は追加
  if (reportParam.excelPath === undefined) {
    reportParam.excelPath = `excel/dialysisReport_${suffix}.xlsx`;
  }

  return reportParam;
}

/**
 * PDF/Excelファイル格納先パスを追加
 * ※出力したくない場合は`null`を設定しておくこと
 * @param {Record<string, unknown>} reportParam 帳票パラメータ
 */
function addPathBVMS(reportParam) {
  // プレビューの場合は何もしない
  if (reportParam.isPreview) {
    return reportParam;
  }

  const suffix = `${reportParam.ordNo}_${reportParam.selectedChart}_${dateFormat.format(new Date(), "yyyyMMddhhmmss")}`;

  // PDF格納先パス(Amazon S3) が未定義の場合は追加
  if (reportParam.pdfPath === undefined) {
    reportParam.pdfPath = `pdf/dialysisReport_${suffix}.pdf`;
  }

  // Excelファイル格納先パス(Amazon S3) が未定義の場合は追加
  if (reportParam.excelPath === undefined) {
    reportParam.excelPath = `excel/dialysisReport_${suffix}.xlsx`;
  }

  return reportParam;
}

function setFormData(param, graphName, isPrint) {
  const formData = createApiFormData();
  formData.append("files", param.files);
  if (graphName === "rrGraph") {
    formData.append("graphY1From", param.graphY1From);
    formData.append("graphY1To", param.graphY1To);
  } else {
    formData.append("graph1Y1From", param.graph1Y1From);
    formData.append("graph1Y1To", param.graph1Y1To);
    formData.append("graph1Y2From", param.graph1Y2From);
    formData.append("graph1Y2To", param.graph1Y2To);
    formData.append("graph2Y1From", param.graph2Y1From);
    formData.append("graph2Y1To", param.graph2Y1To);
    formData.append("graph2Y2From", param.graph2Y2From);
    formData.append("graph2Y2To", param.graph2Y2To);
  }
  if (isPrint) {
    formData.append("targetPrinter", param.targetPrinter);
    formData.append("pdfPath", addPathBVMS(param).pdfPath);
  }
  return formData;
}
