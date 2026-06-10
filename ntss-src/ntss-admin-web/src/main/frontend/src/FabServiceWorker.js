/**
 * Service Workerの登録・更新時に初期化処理を行う
 * @param event Eventオブジェクト
 */
self.addEventListener('install', (event) => {
  //待機をスキップし、activate状態へ変化
  self.skipWaiting();
});

/**
 * Service Workerのインストール後に表示されたページを制御する
 * @param event Eventオブジェクト
 */
self.addEventListener('activate', (event) => {
  //現在表示されているページをService Workerで制御可能な状態に設定
  event.waitUntil(clients.claim());
});

/**
 * 対象ページでfetchイベント発生時に生成されるHTMLを編集する
 * @param event Eventオブジェクト
 */
self.addEventListener('fetch', (event) => {
  //リクエストのURLを取得する
  const url = new URL(event.request.url);
  //PDFファイルへのリクエストかどうかを判定する
  if (url.pathname.endsWith('.pdf')) {
    let tabTitle = "";
    if(url.pathname.split('/').pop() === "FutureNetWeb+Si%E6%93%8D%E4%BD%9C%E3%83%9E%E3%83%8B%E3%83%A5%E3%82%A2%E3%83%AB.pdf"){
      tabTitle = "FutureNetWeb+Si操作マニュアル.pdf";
    } else if(url.pathname.split('/').pop() === "ReMS%E6%93%8D%E4%BD%9C%E3%83%9E%E3%83%8B%E3%83%A5%E3%82%A2%E3%83%AB.pdf"){
      tabTitle = "ReMS  操作マニュアル";
    }
    //Linkタグの設定
    let extensionLink = "";
    if(navigator.userAgent.indexOf('Chrome') >= 0 && navigator.userAgent.indexOf('Edg') === -1 && navigator.userAgent.indexOf('OPR') === -1){
      extensionLink = '<link rel="stylesheet" href="chrome-extension://mhjfbmdgcfjbbpaeojofohoefgiehjai/pdf_embedder.css">';
    } else if(navigator.userAgent.indexOf('OPR') >= 0){
      extensionLink = '<style type="text/css" id="operaUserStyle"></style>';
    }
    //favicon.icoのURLの取得
    const faviconURL = "/ntss-admin-web/img/login/NIKKISO.ico";
    //仮想的なHTMLラッパーを生成する(favicon.icoの差し替えを実施)
    const htmlWrapper = `
      <!DOCTYPE html>
      <html lang="ja">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width,initial-scale=1.0">
          <title>${tabTitle}</title>
          ${extensionLink}
          <link rel="icon" type="image/png" id="favicon" sizes="32x32" href="${faviconURL}">
        </head>
        <body style="height: 100%;width: 100%;overflow: hidden; margin: 0px;background-color: rgb(230, 230, 230);">
          <embed src="${url.href}" type="application/pdf" id="pdfManual" style="position:absolute; left: 0 ;top: 0;width: 100%;height: 100vh;">
          <script>
            window.onload = function() {
              const pdfManual = document.getElementById("pdfManual");
              pdfManual.height = window.innerHeight;
              const favicon = document.getElementById("favicon");
              if(sessionStorage.getItem('faviconURL')){
                const faviconURL = sessionStorage.getItem("faviconURL");
                favicon.href = faviconURL;
              } else if(!sessionStorage.getItem("faviconURL") && localStorage.getItem("faviconURL")){
                const faviconURL = localStorage.getItem("faviconURL");
                favicon.href = faviconURL;
                sessionStorage.setItem("faviconURL",faviconURL);
              }
            };
          </script>
        </body>
      </html>
    `;
    //画面表示されるHTMLに反映する
    event.respondWith(
      new Response(htmlWrapper, {
        headers: { 'Content-Type': 'text/html' }
      })
    );
  }
});
