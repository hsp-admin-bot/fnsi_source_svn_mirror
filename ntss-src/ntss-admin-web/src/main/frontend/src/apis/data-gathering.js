/**
 * データ収集（モーション記録）系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import { encodeApiBase64 } from "@/apis/ApiRuntime";

/**
 * データ収集RestAPI
 * @param {Record<string, unknown>} params リクエストパラメータ
 */
export function sendRequestDataGathering(params) {
  // check
  if (
    !params.facilityCd ||
    !params.deviceEdgeNo ||
    !params.machineTypeCd ||
    !params.comFormatCd ||
    !params.machineSerial
  ) {
    return;
  }
  // RestAPI
  const facilityCd = params.facilityCd.padEnd(6);
  const deviceEdgeNo = params.deviceEdgeNo.toString().padEnd(2);
  const machineTypeCd = params.machineTypeCd.padEnd(3);
  const comFormatCd = params.comFormatCd.padEnd(1);
  const machineSerial = params.machineSerial.padEnd(8);
  const userId = params.userId.toString().padEnd(12);
  const planContent = `${facilityCd}${deviceEdgeNo}${machineTypeCd}${comFormatCd}${machineSerial}${userId}`;
  // string -> base64
  const base64Content = encodeApiBase64(planContent);
  return ApiHelper.post(`motion_record/request/data_gathering`, {
    content: base64Content
  });
}
