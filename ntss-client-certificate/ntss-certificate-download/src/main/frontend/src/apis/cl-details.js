import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 使用可能機能取得.
 * @param {string} facilityCd 施設コード
 */

export async function downloadCertificate(facilityCd, facility) {
  let manyFacilityCd = facility.manyFacilityCd
  manyFacilityCd = manyFacilityCd.replace(" ", ";");
  const url = "/ntss-certificate-download/api/cl-download/downloadCertificate?facilityCd=" +  facilityCd + "&manyFacilityCd=" + manyFacilityCd;
  window.open(url);
  await ApiHelper.post("/cl-details/updateCurDownload", facility);
}
