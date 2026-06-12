/**
 * WebSocket認証系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * WebSocket認証用URL
 */
const URL_BASE_WEBSOCKET_CERT = "/websocketcertification";

/**
 * 接続先情報取得
 * @param {string} facilityCdValue 施設コード
 */
export function sendRequestGetWebsocketUrl(facilityCdValue) {
  // UPD #8224 2023/02/05 BY HandsomeLin Start
  // This API is called in the background, it should not refresh session access time.
  // Add a parameter to the request header to indicate that this is a background call.
  return ApiHelper.get(`${URL_BASE_WEBSOCKET_CERT}/target_url?__background_call__=true`, {
    facilityCd: facilityCdValue
  });
  // UPD #8224 2023/02/05 BY HandsomeLin End
}

/**
 * 認証情報取得
 * @param {Record<string, unknown>} params リクエストボディ
 * @param {string|number} params.facilityCd 施設コード
 */
export function sendRequestGetWebsocketCert(params) {
  // UPD #8224 2023/02/11 BY HandsomeLin Start
  // This API is called in the background, it should not refresh session access time.
  // Add a parameter to the request header to indicate that this is a background call.
  return ApiHelper.post(`${URL_BASE_WEBSOCKET_CERT}?__background_call__=true`, {
    facilityCd: params.facilityCd
  });
  // UPD #8224 2023/02/11 BY HandsomeLin End
}
