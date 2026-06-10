/* eslint-disable no-console */

import { register } from "register-service-worker";

if (process.env.NODE_ENV === "production") {
  register(`${process.env.BASE_URL}service-worker.js`, {
    ready() {
      console.log(
        "App is being served from cache by a service worker.\n" +
          "For more details, visit https://goo.gl/AFskqB"
      );
      // 初回通信で失敗する為、先に下記通信をダミー処理として行い、失敗させておく(正常なJSESSIONID取得の為)
      var xmlhttp = new XMLHttpRequest();
      xmlhttp.open("GET", "/ntss-admin-web/api/sign-in/check/sessiontimeout");
      xmlhttp.send();
    },
    cached() {
      // console.log("Content has been cached for offline use.");
    },
    updated() {
      // console.log("New content is available; please refresh.");
    },
    offline() {
      // console.log(
      //   "No internet connection found. App is running in offline mode."
      // );
    },
    error(error) {
      console.error("Error during service worker registration:", error);
    }
  });
}
