import Axios from "axios";

/**
 * 使用可能機能取得.
 * @param {string} facilityCd 施設コード
 */
export async function downloadCertificate(facilityCd) {
  let obj = {
    facilityCd: facilityCd
  };
  const response = await Axios.request({
    url: "/ntss-certificate-management/api/cl-download/downloadCertificate",
    method: "get",
    params: obj,
    headers: {
      contentType: "application/octet-stream"
    },
    responseType: "blob"
  });
  const blob = new Blob([response.data], {
    type: "application/octet-stream"
  });
  if (window.navigator.msSaveBlob) {
    window.navigator.msSaveBlob(blob, facilityCd + ".p12");
  } else {
    const downloadUrl = (window.URL || window.webkitURL).createObjectURL(blob);
    const link = document.createElement("a");
    link.href = downloadUrl;
    link.download = facilityCd + ".p12";
    link.click();
    (window.URL || window.webkitURL).revokeObjectURL(blob);
  }
}
