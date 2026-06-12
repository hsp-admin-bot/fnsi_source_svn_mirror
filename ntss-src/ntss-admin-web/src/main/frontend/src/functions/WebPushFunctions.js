/**
 * WebPush処理
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import { getScopedLocation, getScopedNavigator, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

let publicKey = null;

function getWebPushWindow(root = null) {
  return getScopedWindow(root) || (typeof globalThis !== "undefined" ? globalThis : null);
}

function getWebPushNavigator(root = null) {
  return getScopedNavigator(root) || getWebPushWindow(root)?.navigator || null;
}

function encodeBase64(value, root = null) {
  const scopedWindow = getWebPushWindow(root);
  const encoder = scopedWindow?.btoa || (typeof btoa !== "undefined" ? btoa : null);
  return encoder ? encoder(value) : "";
}

function decodeBase64(value, root = null) {
  const scopedWindow = getWebPushWindow(root);
  const decoder = scopedWindow?.atob || (typeof atob !== "undefined" ? atob : null);
  return decoder ? decoder(value) : "";
}

// サーバから受け取った公開鍵をデコード
function urlB64ToUint8Array(keyStr, root = null) {
  const dec = decodeBase64(keyStr.replace(/-/g, '+').replace(/_/g, '/'), root);
  let outputArray = new Uint8Array(dec.length);
  for(let i = 0 ; i < dec.length ; i++) {
    outputArray[i] = dec.charCodeAt(i);
  }
  return outputArray;
}

// Subscriptioを取得
function getSubscription(sub) {
  if (sub) {
    return sub
  } else {
    return null;
  }
}

// Subscriptioを取得エラー時の処理
function errorSubscription(err) {
  console.log(err);
  return null;
}

// pushManager.subscribe を実施
function requestSubscription(registration) {
  // オプション：https://developer.mozilla.org/ja/docs/Web/API/PushManager/subscribe
  let opt = {
    userVisibleOnly: true,
    applicationServerKey: publicKey
  }
  return registration.pushManager.subscribe(opt).then(getSubscription, errorSubscription);
}

/**
 * WebPush通知のSubscriptionを行う.
 * @param {*} date
 */
export function webPushSubscribe(key, root = null) {
  // TODO★：key が null の場合は処理をしない
  // 引数からkeyを受け取り、デコードして格納
  publicKey = urlB64ToUint8Array(key, root);
  const scopedNavigator = getWebPushNavigator(root);
  return scopedNavigator?.serviceWorker?.ready?.then(requestSubscription) || Promise.resolve(null);
}

/**
 * WebPush通知の宛先情報をサーバに保存.
 * @param facilityCd 施設コード
 * @param userId 利用者ID
 * @param terminalUniqueString 端末固有ID
 * @param subscriptionObj サブスクリプション結果
 */
export async function saveNotificationList(facilityCd, userId, terminalUniqueString, subscriptionObj, root = null) {
  // 送信パラメータ
  let param = {
    // 端末固有ID
    terminalUniqueString: terminalUniqueString,
    // 施設コード
    facilityCd: facilityCd,
    // ログイン者のID
    userId: userId,
    endpoint: subscriptionObj.endpoint,
    key: "",
    contentEncoding: "",
    jwt: "",
    vapidVersion: ""
  };

  if("getKey" in subscriptionObj) {
    const scopedWindow = getWebPushWindow(root);
    const scopedNavigator = getWebPushNavigator(root);
    const userAgent = scopedNavigator?.userAgent || "";
    param.key = encodeBase64(String.fromCharCode.apply(null, new Uint8Array(subscriptionObj.getKey('p256dh'))), root).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
    param.auth = encodeBase64(String.fromCharCode.apply(null, new Uint8Array(subscriptionObj.getKey('auth'))), root).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
    const useAesgcm = userAgent.match(/Firefox\/(\d+)/) ? ((parseInt(RegExp.$1) >= 46) ? 1 : 0) :
      ((userAgent.match(/Chrome\/(\d+)/) ? ((parseInt(RegExp.$1) >= 50) ? 1 : 0) : 0));
    const encodings = (scopedWindow?.PushManager || (typeof PushManager !== "undefined" ? PushManager : null))?.supportedContentEncodings || [];
    const idx = encodings instanceof Array ? encodings.indexOf('aes128gcm') : -1;
    param.contentEncoding = idx >= 0 ? 'aes128gcm' : (useAesgcm ? 'aesgcm' : 'aesgcm128');
  }

  // VAPID (Voluntary Application Server Identification) という仕組みの為の処理
  const UrlConstructor = getWebPushWindow(root)?.URL || (typeof URL !== "undefined" ? URL : null);
  param.jwt = {
    aud: UrlConstructor ? new UrlConstructor(subscriptionObj.endpoint).origin : "",
    sub: getScopedLocation(root)?.href || ""
  };
  // 文字列で受け取るので、文字列に変換
  param.jwt = JSON.stringify(param.jwt);
  // 0: draft-ietf-webpush-vapid-01, 1: RFC 8292
  param.vapidVersion = (param.contentEncoding === 'aes128gcm') ? 1 : 0;
  // Workaround for RFC 8292 support on FCM; see https://github.com/web-push-libs/web-push/issues/278#issuecomment-356783840
  if(param.vapidVersion === 1) {
    param.endpoint = param.endpoint.replace('fcm/send', 'wp');
  }

  // 送信処理
  await ApiHelper.post(
    `/send-push/pushSave`,
    param
  ).catch(error => {
    throw error;
  });
}
