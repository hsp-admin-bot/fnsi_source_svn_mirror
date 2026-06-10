// For authoring Nightwatch tests, see
// http://nightwatchjs.org/guide#usage

module.exports = {
  "treatment-record/result initial e2e tests": browser => {
    browser
      // サインイン
      .url(
        "http://localhost:8000/ntss-admin-web/#/?key=%242a%2410%24EXWsftyCEL7pYzTVAilGLOJKZ%2fr4l%2fa1JpHsMRbxPWKByjN%2e9sHNq"
      )
      .setValue("input[id='userId']", "e2etest")
      .setValue("input[id='passwd']", "esm")
      .click(".button")
      .pause(5000)
      .assert.elementNotPresent("input[id='userId']")
      // 治療記録画面へ遷移することの確認
      .click("ons-toolbar-button[name='treatment-record']")
      .pause(5000)
      .assert.elementPresent("div[history-key='TREATMENT']")
      // 実績情報子画面へ遷移
      .click("button[name='treatment-record-result']")
      .pause(5000)
      .assert.elementPresent("div#result-component")
      // アコーディオンが全て閉じていることの確認
      .assert.elementNotPresent("ons-list-item#result-sub.expanded")
      .assert.elementNotPresent("ons-list-item#puncture-user-sub.expanded")
      .assert.elementNotPresent("ons-list-item#return-user-sub.expanded")
      .assert.elementNotPresent("ons-list-item#charge-user-sub.expanded")
      // 実績情報のアコーディオンが開くことの確認
      .click("#result-sub")
      .pause(1000)
      .assert.elementPresent("ons-list-item#result-sub.expanded")
      // 穿刺者のアコーディオンが開くことの確認
      .click("ons-list-item#puncture-user-sub")
      .pause(1000)
      .assert.elementPresent("ons-list-item#puncture-user-sub.expanded")
      // 返血者のアコーディオンが開くことの確認
      .click("ons-list-item#return-user-sub")
      .pause(1000)
      .assert.elementPresent("ons-list-item#return-user-sub.expanded")
      // 担当者のアコーディオンが開くことの確認
      .click("ons-list-item#charge-user-sub")
      .pause(1000)
      .assert.elementPresent("ons-list-item#charge-user-sub.expanded")
      // データ項目のラベルの確認
      .pause(5000)
      .assert.containsText("tr.in-out-class td.title label", "入外区分")
      .assert.containsText("tr.dialysis-cnt td.title label", "透析回数")
      .assert.containsText("tr.dialysis-time td.title label", "透析時間")
      .assert.containsText(
        "tr.dialysis-start-datetime td.title label",
        "透析開始日時"
      )
      .assert.containsText(
        "tr.dialysis-end-datetime td.title label",
        "透析終了日時"
      )
      .assert.containsText("tr.kur td.title label", "クール")
      .assert.containsText("tr.bed td.title label", "ベッド")
      .assert.containsText("tr.ward td.title label", "病棟名")
      .assert.containsText("tr.course td.title label", "診療科")
      .assert.containsText(
        "ons-list-item#puncture-user-sub tr.user-name-1 td.title label",
        "穿刺者1"
      )
      .assert.containsText(
        "ons-list-item#puncture-user-sub tr.user-name-2 td.title label",
        "穿刺者2"
      )
      .assert.containsText(
        "ons-list-item#puncture-user-sub tr.input-time td.title label",
        "穿刺時刻"
      )
      .assert.containsText(
        "ons-list-item#return-user-sub tr.user-name-1 td.title label",
        "返血者1"
      )
      .assert.containsText(
        "ons-list-item#return-user-sub tr.user-name-2 td.title label",
        "返血者2"
      )
      .assert.containsText(
        "ons-list-item#return-user-sub tr.input-time td.title label",
        "返血時刻"
      )
      .assert.containsText(
        "ons-list-item#charge-user-sub tr.user-name-1 td.title label",
        "担当者1"
      )
      .assert.containsText(
        "ons-list-item#charge-user-sub tr.user-name-2 td.title label",
        "担当者2"
      )
      // 実績情報の値表示確認
      .assert.value("tr.dialysis-cnt input[type='text']", "2")
      .assert.containsText("tr.dialysis-time td#dialysis-time-td label", "6:00")
      .assert.value(
        "tr.dialysis-start-datetime input[type='date']",
        "2019-02-13"
      )
      .assert.value("tr.dialysis-start-datetime input[type='time']", "12:00")
      .assert.value("tr.dialysis-end-datetime input[type='date']", "2019-02-13")
      .assert.value("tr.dialysis-end-datetime input[type='time']", "18:00")
      .assert.value("tr.kur select", "1")
      .assert.containsText("tr.kur option:checked", "午前")
      .assert.value("tr.bed select", "2")
      .assert.containsText("tr.bed option:checked", "101号室2")
      .assert.value("tr.ward select", "2")
      .assert.containsText("tr.ward option:checked", "腎センター")
      .assert.value("tr.course select", "10")
      .assert.containsText("tr.course option:checked", "【削除】糖尿内科")
      // 穿刺者の値表示確認
      .assert.containsText(
        "ons-list-item#puncture-user-sub tr.user-name-1 td.value label",
        "穿刺1 太郎"
      )
      .assert.containsText(
        "ons-list-item#puncture-user-sub tr.user-name-2 td.value label",
        "穿刺2 次郎"
      )
      .assert.value(
        "ons-list-item#puncture-user-sub input[type='date']",
        "2019-02-13"
      )
      .assert.value(
        "ons-list-item#puncture-user-sub input[type='time']",
        "13:00"
      )
      // 返血者の値表示確認
      .assert.containsText(
        "ons-list-item#return-user-sub tr.user-name-1 td.value label",
        "返血1 太郎"
      )
      .assert.containsText(
        "ons-list-item#return-user-sub tr.user-name-2 td.value label",
        "返血2 次郎"
      )
      .assert.value(
        "ons-list-item#return-user-sub input[type='date']",
        "2019-02-13"
      )
      .assert.value("ons-list-item#return-user-sub input[type='time']", "13:30")
      // 担当者の値表示確認
      .assert.containsText(
        "ons-list-item#charge-user-sub tr.user-name-1 td.value label",
        "担当1 太郎"
      )
      .assert.containsText(
        "ons-list-item#charge-user-sub tr.user-name-2 td.value label",
        "担当2 次郎"
      )
      // 保存ボタンが非活性であることの確認
      .assert.elementPresent(".submenu-footer .registration-btn:disabled")
      .end();
  },

  "treatment-record/result update e2e tests": browser => {
    const disabledButtonSelector = ".submenu-footer .registration-btn:disabled";
    const enabledButtonSelector =
      ".submenu-footer .registration-btn:not([disabled])";

    const checkValueChanging = function(browser, selector, oldValue, newValue) {
      browser
        // 値を変更して保存ボタンが活性になることを確認
        .click(selector)
        .clearValue(selector)
        .setValue(selector, newValue)
        .click("tr.in-out-class td.title label")
        .pause(1000)
        .assert.elementPresent(enabledButtonSelector)
        // 値を戻して保存ボタンが非活性になることを確認
        .click(selector)
        .clearValue(selector)
        .setValue(selector, oldValue)
        .click("tr.in-out-class td.title label")
        .pause(1000)
        .assert.elementPresent(disabledButtonSelector);
    };

    browser
      // サインイン
      .url(
        "http://localhost:8000/ntss-admin-web/#/?key=%242a%2410%24EXWsftyCEL7pYzTVAilGLOJKZ%2fr4l%2fa1JpHsMRbxPWKByjN%2e9sHNq"
      )
      .setValue("input[id='userId']", "e2etest")
      .setValue("input[id='passwd']", "esm")
      .click(".button")
      .pause(5000)
      .assert.elementNotPresent("input[id='userId']")
      // 治療記録画面へ遷移することの確認
      .click("ons-toolbar-button[name='treatment-record']")
      .pause(5000)
      .assert.elementPresent("div[history-key='TREATMENT']")
      // 実績情報子画面へ遷移
      .click("button[name='treatment-record-result']")
      .pause(5000)
      .assert.elementPresent("div#result-component")
      .click("ons-list-item#result-sub")
      .pause(1000)
      .click("ons-list-item#puncture-user-sub")
      .pause(1000)
      .click("ons-list-item#return-user-sub")
      .pause(1000)
      .click("ons-list-item#charge-user-sub")
      .pause(1000);

    // 値変更での保存ボタン制御確認
    browser
      .click("#in-out-class-0")
      .assert.elementPresent(enabledButtonSelector)
      .click("#in-out-class-1")
      .assert.elementPresent(disabledButtonSelector);

    checkValueChanging(browser, "tr.dialysis-cnt input[type='text']", "2", "3");

    browser.end();
  }
};
