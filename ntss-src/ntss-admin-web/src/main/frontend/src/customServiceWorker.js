/**
 * Welcome to your Workbox-powered service worker!
 *
 * You'll need to register this file in your web app and you should
 * disable HTTP caching for this file too.
 * See https://goo.gl/nhQhGp
 *
 * The rest of the code is auto-generated. Please don't update this file
 * directly; instead, make changes to your Workbox build configuration
 * and re-run your build process.
 * See https://goo.gl/2aRDsh
 */

/* add by chamaojia 2023-08-30 [9599] バージョンアップ後は手動でjsを導入する必要があります  --start */
// package.jsonのworkbox-webpack-pluginバージョンに対応
importScripts("https://storage.googleapis.com/workbox-cdn/releases/6.6.0/workbox-sw.js");
/* add by chamaojia 2023-08-30 [9599] バージョンアップ後は手動でjsを導入する必要があります  --end */

// Force production builds
workbox.setConfig({ debug: true });

workbox.core.setCacheNameDetails({prefix: "ReMS"});

//workbox.skipWaiting();
//workbox.clientsClaim();

/**
 * The workboxSW.precacheAndRoute() method efficiently caches and responds to
 * requests for URLs in the manifest.
 * See https://goo.gl/S9QRab
 */
self.__precacheManifest = [].concat(self.__precacheManifest || self.__WB_MANIFEST || []);
/* del by chamaojia 2023-08-30 [9599] 呼び出し関数が存在しません  --start */
// workbox.precaching.suppressWarnings();
/* del by chamaojia 2023-08-30 [9599] 呼び出し関数が存在しません  --end */
workbox.precaching.precacheAndRoute(self.__precacheManifest, {});


// SWスクリプトのinstall イベント
self.addEventListener('install', function(event) {
    // console.log("addEventListener[install]");
    // SWスクリプトの強制入れ替えを行う場合
    event.waitUntil(self.skipWaiting());
});

// SWスクリプトのactivat イベント
self.addEventListener('activate', function(event) {
    // console.log("addEventListener[activate]");
    // SWスクリプトの強制入れ替えを行う場合
    event.waitUntil(self.clients.claim());
});

// SWスクリプトのfetch イベント
self.addEventListener('fetch', (e) => {
  // console.log("addEventListener[fetch]", e.request.url);

  if (e.request.mode === 'navigate' || (e.request.method == 'GET' && e.request.headers.get('accept').includes('text/html'))) {
    e.respondWith(
      fetch(e.request)
        .then((response) => {
          // レスポンスステータス判定
          // console.log(response.status);
          // セッションタイムアウトによりリダイレクトされてきた場合はそのままreturnする
          if (response.type === 'opaqueredirect') {
            return response;
          }
          if (!response.ok) throw new Error("offline!!");
          // オンライン処理
          // console.log("addEventListener[fetch] online!!");
          return response;
        })
        .catch((err) => {
          // console.log("addEventListener[fetch] offline!!");
          
          // メンテナンス画面のレスポンス生成
          return new Response(
            '<style type="text/css">'
            +'.container{'
            +'text-align:center;'
            +'}'
            +'</style>'
            +'<!DOCTYPE html>'
            +'<html lang="ja">'
            +'<head>'
            +'<meta charset="UTF-8">'
            +'<meta http-equiv="Pragma" content="no-cache">'
            +'<meta http-equiv="Cache-Control" content="no-cache">'
            +'<meta http-equiv="Expires" content="0">'
            +'<title>メンテナンス</title>'
            +'</head>'
            +'<body>'
            +'<div  class="container">'
            +'<span>'
            +'<br>'
            +'<br>'
            +'<br>'
            +'<img src="/ntss-admin-web/img/nkk_mark.png" />'
            +'<br>'
            +'<br>'
            +'<br>'
            +'<br>'
            +'<font size="7">'
            +'サイトにアクセスできません'
            +'</font>'
            +'<hr color="#191970"></hr>'
            +'<br>'
            +'<font>'
            +'ネットワークを確認して、再読み込みしてください。<br>'
            +'</font>'
            +'</span>'
            +'</div>'
            +'</body>'
            +'</html>'
            , {"status" : 408, "headers" : {"Content-Type" : "text/html"}}
             );
            
        })
    );
  }
});

// Push通知受信時の処理
self.addEventListener('push', ev => {
  const payload = JSON.parse(ev.data.text());
  ev.waitUntil(
    self.registration.showNotification(payload.title, {
      body: payload.message,
      icon: payload.icon
    })
    .then(() => {
      return;
    })
    .catch(err => {
      return;
    })
  );
});
