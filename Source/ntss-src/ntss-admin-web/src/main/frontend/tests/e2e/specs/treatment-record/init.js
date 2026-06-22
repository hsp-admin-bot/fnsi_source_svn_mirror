// For authoring Nightwatch tests, see
// http://nightwatchjs.org/guide#usage

export default {
  "treatment-record init e2e tests": browser => {
    browser
      // サインイン
      .url(
        "http://localhost:8000/ntss-admin-web/#/?key=%242a%2410%24EXWsftyCEL7pYzTVAilGLOJKZ%2fr4l%2fa1JpHsMRbxPWKByjN%2e9sHNq"
      )
      .setValue("input[id='userId']", "e2etest")
      .setValue("input[id='passwd']", "esm")
      .click(".button")
      .pause(10000)
      .assert.elementNotPresent("input[id='userId']")
      // 治療記録画面へ遷移することの確認
      .click("ons-toolbar-button[name='treatment-record']")
      .pause(5000)
      .assert.elementPresent("div[history-key='TREATMENT']")
      // 子機能切り替えの確認
      .click("button[name='treatment-record-result']")
      .pause(1000)
      .assert.elementPresent("#result-component")
      .click("button[name='treatment-record-vital']")
      .pause(1000)
      .assert.elementPresent("#vital-component")
      .click("button[name='treatment-record-monitor']")
      .pause(1000)
      .assert.elementPresent("#monitor-component")
      .click("button[name='treatment-record-complaint']")
      .pause(1000)
      .assert.elementPresent("#complaint-component")
      .click("button[name='treatment-record-weight']")
      .pause(1000)
      .assert.elementPresent("#weight-component")
      .click("button[name='treatment-record-condition']")
      .pause(1000)
      .assert.elementPresent("#condition-component")
      .click("button[name='treatment-record-medicine']")
      .pause(1000)
      .assert.elementPresent("#medicine-component")
      .click("button[name='treatment-record-equipment']")
      .pause(1000)
      .assert.elementPresent("#equipment-component")
      .click("button[name='treatment-record-addition']")
      .pause(1000)
      .assert.elementPresent("#addition-component")
      .click("button[name='treatment-record-setting']")
      .pause(1000)
      .assert.elementPresent("#setting-component")
      .click("button[name='treatment-record-round']")
      .pause(1000)
      .assert.elementPresent("#round-component")
      .click("button[name='treatment-record-observation']")
      .pause(1000)
      .assert.elementPresent("#observation-component")
      .end();
  }
};
