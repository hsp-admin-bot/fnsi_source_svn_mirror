/**
 * テストページ
 */
<template>
  <div class='main-content-area'>
    <div>
      <v-ons-button class="btn3-normal" style="margin-top: 0.5em; margin-bottom: 0.5em; width: 10em;"  @click="reSetLoggerSetting">ログ設定反映</v-ons-button>
      <!-- チェックリスト一覧のグリッド -->
      <table border="1px" style="font-size: 12pt;" >
        <tbody>
          <tr>
          <th>ファイル種別</th>
          <th>観点</th>
          <th>確認エリア</th>
        </tr>
        <tr>
          <td>vue</td>
          <td>template部分</td>
          <td>
            template内テキスト変更
          </td>
        </tr>
        <tr>
          <td>vue</td>
          <td>script部分</td>
          <td>
            <v-ons-button width="100px" @click="DialogDisp">ダイアログ表示
            </v-ons-button>
          </td>
        </tr>
        <tr>
          <td>vue</td>
          <td>style部分</td>
          <td id="style-test">
            style変更確認
          </td>
        </tr>
        <tr>
          <td>js</td>
          <td>モジュール化対象</td>
          <td>
            パディング確認<br>
            <input id="js-input"
               maxlength="12"
               @blur="paddingText($event.target.value)"
            />
          </td>
        </tr>
        <tr>
          <td>js</td>
          <td>モジュール化非対象</td>
          <td>
            -
          </td>
        </tr>
        <tr>
          <td>css</td>
          <td>モジュール化対象</td>
          <td>
            <p id='css-test-module' :src='css_src_test_module'>css変更確認(モジュール化)</p>
          </td>
        </tr>
        <tr>
          <td>css</td>
          <td>モジュール化非対象</td>
          <td>
            <p id='css-test-no-module'>css変更確認(非モジュール化)</p>
          </td>
        </tr>
        <tr>
          <td>img</td>
          <td>base64エンコード</td>
          <td>
            <img class='img-icon none-event' :src='image_src_test_module' width="48" height="48" />
          </td>
        </tr>
        <tr>
          <td>img</td>
          <td>モジュール化非対象</td>
          <td>
            <img class='img-icon none-event' src='img/img_sample/test_no_module.png' width="48" height="48" />
          </td>
        </tr>
        <tr>
          <td>audio</td>
          <td>モジュール化対象</td>
          <td>
            <v-ons-button class="file-button" @click="moduleHowl">再生(モジュール化)
            </v-ons-button>
          </td>
        </tr>
        <tr>
          <td>audio</td>
          <td>モジュール化非対象</td>
          <td>
            <v-ons-button class="file-button" @click="noModuleHowl">再生(非モジュール化)
            </v-ons-button>
          </td>
        </tr>
        <tr>
          <td>pdf</td>
          <td>モジュール化対象</td>
          <td>
            <v-ons-button class="file-button" @click="showHelpModule">PDF表示(モジュール化)
            </v-ons-button>
          </td>
        </tr>
        <tr>
          <td>pdf</td>
          <td>モジュール化非対象</td>
          <td>
            <v-ons-button class="file-button" @click="showHelpNoModule">PDF表示(非モジュール化)
            </v-ons-button>
          </td>
        </tr>
      
        </tbody>
      </table>

      <!-- 入力時の入力モード設定確認用 -->
      <label style="display: block; margin-top: 2em; font-size: 2em;">入力時の入力モード設定確認用 (typeタグ、inputmodeタグ)</label>
      <table border="1px" style="font-size: 12pt;" >
        <tbody>
          <tr>
          <th>項目</th>
          <th>既存</th>
          <th>inputmodeタグ併用</th>
        </tr>
        <tr>
          <td>装置設定デフォルトマスタ：BV等で使用されている入力部品</td>
          <td>
            <label style="display: block;">custom-input-number(type="text")</label>
            <custom-input-number
              :value="{ initValue, editValue }"
              :max-value="1000"
              :min-value="0"
              :decimal-digits="0"
              :digits="4"
              is-required="true"
            />
          </td>
          <td>
            <label style="display: block;"> + inputmode="numeric"</label>
            <custom-input-number
              :value="{ initValue, editValue }"
              :max-value="1000"
              :min-value="0"
              :decimal-digits="0"
              :digits="4"
              is-required="true"
              inputmode="numeric"
            />
          </td>
        </tr>
        <tr>
          <td>kendo-grid数値入力</td>
          <td style="width: 300px;">
            <label style="display: block; line-height: 3em;">通常の数値入力欄</label>
            <div
              ref="normalNumberGrid"
              class="cache-test-direct-grid"
            ></div>
          </td>
          <td style="width: 300px;">
            <label style="display: block;">inputmodeタグをつけるには、@editorを使用する必要があります。</label>
            <div
              ref="inputmodeNumberGrid"
              class="cache-test-direct-grid"
            ></div>
          </td>
        </tr>
        <tr>
          <td>
            <span style="display: block;">onsen-ui 数値入力 pt01</span>
            <span>(inputタグも同様です)</span>
          </td>
          <td>
            <label style="display: block;">type="text"</label>
            <v-ons-input type="text"></v-ons-input>
          </td>
          <td>
            <label style="display: block;"> + inputmode="numeric"</label>
            <v-ons-input type="text" inputmode="numeric"></v-ons-input>
          </td>
        </tr>
        <tr>
          <td>onsen-ui 数値入力 pt02</td>
          <td>
            <label style="display: block;">type="number"</label>
            <v-ons-input type="number"></v-ons-input>
          </td>
          <td>
            <label style="display: block;"> + inputmode="numeric"</label>
            <v-ons-input type="number" inputmode="numeric"></v-ons-input>
          </td>
        </tr>
        <tr>
          <td>onsen-ui 数値入力 pt03</td>
          <td>
            <label style="display: block;">type="tel"</label>
            <v-ons-input type="tel"></v-ons-input>
          </td>
          <td>
            <label style="display: block;"> + inputmode="numeric"</label>
            <v-ons-input type="tel" inputmode="numeric"></v-ons-input>
          </td>
        </tr>
        <tr>
          <td>onsen-ui 日付入力</td>
          <td>
            <label style="display: block;">type="date"</label>
            <v-ons-input type="date"></v-ons-input>
          </td>
          <td>
            <label style="display: block;"> + inputmode="numeric"</label>
            <v-ons-input type="date" inputmode="numeric"></v-ons-input>
          </td>
        </tr>
        <tr>
          <td>onsen-ui 時刻入力</td>
          <td>
            <label style="display: block;">type="time"</label>
            <v-ons-input type="time"></v-ons-input>
          </td>
          <td>
            <label style="display: block;"> + inputmode="numeric"</label>
            <v-ons-input type="time" inputmode="numeric"></v-ons-input>
          </td>
        </tr>
      
        </tbody>
      </table>

      <!-- プッシュ通知確認用 -->
      <label style="display: block; margin-top: 2em; font-size: 2em;">プッシュ通知確認用</label>
      <label style="display: block; font-size: 2em;">([01]～[05]：通知登録を行う初回処理、[07]～[08]：通知解除処理)</label>
      <table border="1px" style="font-size: 12pt;" >
        <tbody>
          <tr>
          <th>ボタン</th>
          <th>説明</th>
          <th>Data</th>
        </tr>
        <tr>
          <td>
            <v-ons-button @click="testBtn_01">[01] 共通鍵取得</v-ons-button></td>
          <td>
            <div>サーバから共通鍵を取得します。</div>
            <div>サーバ側に鍵が存在しない場合は生成し、sys_system_define - ctl_no：100 に保存します。</div>
          </td>
          <td>
            <label style="display: block;">共通鍵：</label>
            <div>{{ publicKey }}</div>
          </td>
        </tr>
        <tr>
          <td>
            <v-ons-button @click="testBtn_02">[02] 通知許可</v-ons-button></td>
          <td>
            <div>ブラウザの通知設定を行います。</div>
            <div>初期化する場合は 設定->サイトの設定->通知</div>
          </td>
          <td>
            <label style="display: block;">ブラウザの通知許可状態：</label>
            <div>{{ permissionStr }}</div>
          </td>
        </tr>
        <tr>
          <td>
            <v-ons-button @click="testBtn_03" :disabled="publicKey === '' || permission !== 'granted'">[03] Subscription</v-ons-button></td>
          <td>
            <div>pushManager.subscribe</div>
            <div>endpoint等を生成します。</div>
          </td>
          <td>
            <label style="display: block;">endpoint：</label>
            <div>{{ endpoint }}</div>
          </td>
        </tr>
        <tr>
          <td>
            <v-ons-button @click="testBtn_04" :disabled="terminalUniqueString !== null">[04] 端末固有IDの生成</v-ons-button></td>
          <td>
            <div>端末固有IDを生成</div>
            <div>LocalStorageに保存を行います。</div>
          </td>
          <td>
            <label style="display: block;">端末固有ID：</label>
            <div>{{ terminalUniqueString }}</div>
          </td>
        </tr>
        <tr>
          <td>
            <v-ons-button @click="testBtn_05" :disabled="subscriptionObj === null || terminalUniqueString === null">[05] 宛先情報をサーバに保存</v-ons-button></td>
          <td>
            <div>サーバに宛先情報を保存します。</div>
            <div>端末固有IDが同じ場合は上書き保存します。</div>
          </td>
          <td></td>
        </tr>
        <tr>
          <td>
            <v-ons-button disabled>[06] Push通知</v-ons-button></td>
          <td>
            <div>ログイン者が宛先情報を保存した端末にPush通知を行います。</div>
            <div>Push通知はweb-api経由で行うため機能停止中</div>
            <label style="display: block;">通知メッセージ：</label>
            <v-ons-input type="text" v-model="pushMessage"></v-ons-input>
          </td>
          <td></td>
        </tr>
        <tr>
          <td>
            <v-ons-button @click="testBtn_07">[07] 通知解除</v-ons-button></td>
          <td>
            <div>ブラウザの通知解除(unSubscribe)を行います。</div>
          </td>
          <td>
            <div>(この処理で通知を受け取らなくなります)</div>
          </td>
        </tr>
        <tr>
          <td>
            <v-ons-button @click="testBtn_08">[08] 宛先情報削除</v-ons-button></td>
          <td>
            <div>DBに登録されている宛先情報の削除を行います。</div>
          </td>
          <td></td>
        </tr>
      
        </tbody>
      </table>

      <!-- Script変更確認用ダイアログ -->
      <message-dialog
        v-model:visible="isCacheTestDialog"
        :message-cd="22010001"
        :string-params="stringParams"
        type="1"
        @confirm="confirmOK"
      />
      <div id="manualPdfArea" v-show="isShowManual">
        <a href="help/test_no_module.pdf" class="manual-download-btn control-z-index" download="test_no_module.pdf" v-if="device != 'iOS'">
          <ons-icon icon="fa-download"></ons-icon>
        </a>
        <div v-else class="manual-not-download control-z-index" id="hideText">
                  お使いの端末ではダウンロードできません。
        </div>
        <ons-toolbar-button class="close-btn manual-close-btn" @click="closeManual()">
          <ons-icon icon="fa-times"></ons-icon>
        </ons-toolbar-button>
        <div id="pdf-container" style="width:100%;height:100%;overflow-y:scroll;-webkit-overflow-scrolling: touch;">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { paddingInput } from "@/functions/CacheTestFunction.js";
import { webPushSubscribe } from "@/functions/WebPushFunctions";
import { Howl } from "@/compat/media/howler";
import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestLoggerSetFlgUpddate } from "@/apis/log-reference";
import { mapGetters } from "@/compat/vue/vuex";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber.vue";

import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getScopedElementById, getScopedDocument, getScopedWindow, getScopedLocalStorage, getScopedUserAgent, createScopedImageElement } from "@/functions/common/LayoutMeasureHelper";
import { ensureViewportContent } from "@/compat/assets/head";

import testModuleAudio from "./audio_sample/test_module.wav";

//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat'

import $ from "@/compat/jquery";
import kendo from "@progress/kendo-ui";
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'

import testModuleImg from "./img_sample/test_module.png";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

const PDF_SRC_TEST_MODULE = "help/pdf_sample/test_no_module.pdf";
const MANUAL_DIR_URL = "help/operation_manual";
const PDF_SRC_TEST_NO_MODULE = "help/pdf_sample/test_no_module.txt"
const AUDIO_SRC_TEST_MODULE = "audio/audio_sample/test_no_module.wav";

export default {
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  components: {
    "message-dialog": messageDialog,
    "custom-input-number": customInputNumber
  },
  data() {
    return {
      isCacheTestDialog: false,
      stringParams: [],
      css_src_test_module: "",
      image_src_test_module: testModuleImg,
      audio_src_test_module: testModuleAudio,
      /* modify by #10977 2024-10-29 start */
      // pdf_src_test_module: require("file-loader!./pdf_sample/test_module.pdf"),
      // txt_src_test_module: require("file-loader!./pdf_sample/test_module.txt"),
      pdf_src_test_module: "",
      txt_src_test_module: "",
      /* modify by #10977 2024-10-29 end */
      isShowManual: false,
      manualPdf: null,
      device: null,
      lstManualImg: [],
      manualImgPageCnt: 0,
      dispManualPageCnt: 0,
      initValue: 300,
      editValue: 300,
      columns: [
        {
          "editable": true,
          "field": "code",
          "format": "",
          "hidden": false,
          "title": "数値入力",
          "width": "10px"
        }
      ],
      masterRecords: {
              data: [{"code": 1}],
              schema: {
                model: {
                  fields: {
                    code: { type: "number" }
                  },
                  id: ""
                }
              }
      },
      // 共通鍵
      publicKey: "",
      // ブラウザの通知許可状態
      permission: undefined,
      // Subscription処理の戻り値
      subscriptionObj: null,
      // 端末固有ID
      terminalUniqueString: null,
      // Push通知に乗せるメッセージ
      pushMessage: "",
      directGridWidgets: []
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),

    // 認証状態
    permissionStr() {
      if (this.permission === "denied") {
        return "拒否";
      } else if (this.permission === "granted") {
        return "許可済み";
      } else if (this.permission === "default") {
        return "未設定";
      } else {
        return "通知非対応ブラウザ";
      }
    },
    // endpoint
    endpoint() {
      let rtnStr = "";
      if (this.subscriptionObj !== null && this.subscriptionObj.endpoint) {
        rtnStr = this.subscriptionObj.endpoint;
      }
      return rtnStr;
    }
  },
  methods: {
    createManualImage(viewer, src) {
      const img = createScopedImageElement(viewer || this.$el || this);
      if (!img) {
        return null;
      }
      img.src = src;
      img.style.width = "100%";
      return img;
    },
    appendManualImage(viewer, src) {
      const img = this.createManualImage(viewer, src);
      if (img) {
        viewer?.appendChild?.(img);
      }
      return img;
    },
    // VueファイルScript部分確認用
    DialogDisp(){
      this.stringParams = ["Script内テキスト変更"];
      this.isCacheTestDialog = true;
      return;
    },
    confirmOK(answer){
      if ("OK" === answer) {
        // モーダルを閉じる
        this.$emit("hide-modal");
      }
    },

    paddingInput,

    paddingText(input){
      getScopedElementById("js-input", this.$el || this).value = this.paddingInput(input);
    },

    // 非モジュール化CSS適用
    readCss() {
      const ownerDocument = getScopedDocument(this.$el);
      let testNoModule = ownerDocument.createElement("link");
      testNoModule.rel = "stylesheet";
      testNoModule.href = "css/css_sample/test_no_module.css";
      ownerDocument.head.appendChild(testNoModule);
    },

    // モジュール化audio確認用
    moduleHowl(){
      const moduleHowl = new Howl({
        src: [this.audio_src_test_module]
      });
      moduleHowl.play();
    },

    // モジュール化audio確認用
    noModuleHowl(){
      const noModuleHowl = new Howl({
        src: [AUDIO_SRC_TEST_MODULE]
      });
      noModuleHowl.play();
    },

    // モジュール化PDF確認用
    async showHelpModule() {
      if (this.device == "notMobile") {
        const helpWindow = (getScopedWindow(this.$el) || window).open("about:blank");
        helpWindow.location.href = this.pdf_src_test_module;
      } else {
        const viewer = getScopedElementById("pdf-container", this.$el || this);
        ensureViewportContent('"width=device-width, initial-scale=1.0, user-scalable=yes', this.$el || this);
        if (viewer.hasChildNodes()) {
          this.isShowManual = true;
        } else {
          // 初期表示なのでスクロール監視イベント付与
          viewer.addEventListener("scroll", this.scrollPdfContainer);

          // 画像ファイルのリストを取得
          var xhr = new XMLHttpRequest();
          await xhr.open("GET", this.txt_src_test_module);
          await xhr.send();
          xhr.onload = ()=> {
            var text = xhr.response;
            var arr = text.split(/\r\n|\r|\n/);
            for(var i = 0; i < arr.length; i++){
              if (arr[i] !== ""){
                this.lstManualImg.push(arr[i]);
              }
            }

            this.manualImgPageCnt = this.lstManualImg.length;
            // 読み込んだ画像をイメージとして書き出す(まずは5ページ分書き出し)
            for(let idx = 0; idx < 5; idx++){
              this.appendManualImage(viewer, MANUAL_DIR_URL + "/" + this.lstManualImg[idx]);
              this.dispManualPageCnt += 1;
            }
            this.isShowManual = true;
          };
        }
      }
    },

    // 非モジュール化PDF確認用
    async showHelpNoModule() {
      if (this.device == "notMobile") {
        const helpWindow = (getScopedWindow(this.$el) || window).open("about:blank");
        helpWindow.location.href = PDF_SRC_TEST_MODULE;
      } else {
        const viewer = getScopedElementById("pdf-container", this.$el || this);
        ensureViewportContent('"width=device-width, initial-scale=1.0, user-scalable=yes', this.$el || this);
        if (viewer.hasChildNodes()) {
          this.isShowManual = true;
        } else {
          // 初期表示なのでスクロール監視イベント付与
          viewer.addEventListener("scroll", this.scrollPdfContainer);

          // 画像ファイルのリストを取得
          var xhr = new XMLHttpRequest();
          await xhr.open("GET", PDF_SRC_TEST_NO_MODULE);
          await xhr.send();
          xhr.onload = ()=> {
            var text = xhr.response;
            var arr = text.split(/\r\n|\r|\n/);
            for(var i = 0; i < arr.length; i++){
              if (arr[i] !== ""){
                this.lstManualImg.push(arr[i]);
              }
            }

            this.manualImgPageCnt = this.lstManualImg.length;
            // 読み込んだ画像をイメージとして書き出す(まずは5ページ分書き出し)
            for(let idx = 0; idx < 5; idx++){
              this.appendManualImage(viewer, MANUAL_DIR_URL + "/" + this.lstManualImg[idx]);
              this.dispManualPageCnt += 1;
            }
            this.isShowManual = true;
          };
        }
      }
    },
    scrollPdfContainer(e) {
      const target = e.target;
      if((target.scrollHeight - (target.offsetHeight + target.scrollTop)) / target.scrollHeight <= 0){
        // スクロール最下部に来ていた場合最大2ページ分追加読込する
        if (this.dispManualPageCnt < this.manualImgPageCnt) {
          const viewer = getScopedElementById("pdf-container", this.$el || this);
          for(let i = 0; i < 2; i++){
            this.appendManualImage(viewer, MANUAL_DIR_URL + "/" + this.lstManualImg[this.dispManualPageCnt]);
            this.dispManualPageCnt += 1;
            if (this.dispManualPageCnt === this.manualImgPageCnt){
              break;
            }
          }
        }
      }
    },
    // kendo-grid カスタム数値入力
    customNoEditor(container, data) {
      $(`<input inputmode="numeric" name="${data.field}"/>`)
        .appendTo(container)
        .kendoNumericTextBox({
          min: 1,
          max: 1000
        });
    },
    buildDirectGridColumns(useInputmodeEditor = false) {
      return (this.columns || []).map(column => ({
        title: column.title,
        field: column.field,
        hidden: column.hidden,
        width: column.width,
        format: column.format,
        editor: useInputmodeEditor ? this.customNoEditor : undefined
      }));
    },
    createDirectGridDataSource() {
      return new kendo.data.DataSource({
        ...this.masterRecords,
        data: Array.isArray(this.masterRecords?.data) ? this.masterRecords.data : []
      });
    },
    initDirectGrid(root, useInputmodeEditor = false) {
      if (!root) {
        return null;
      }
      const $root = $(root);
      const existingGrid = $root.data("kendoGrid");
      if (existingGrid) {
        existingGrid.setDataSource(this.createDirectGridDataSource());
        this.applyDirectGridStyleContract(root);
        return existingGrid;
      }
      $root.kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        columns: this.buildDirectGridColumns(useInputmodeEditor),
        editable: true,
        selectable: true,
        reorderable: false,
        scrollable: true,
        height: "100px",
        dataBound: () => this.applyDirectGridStyleContract(root)
      });
      const grid = $root.data("kendoGrid") || null;
      this.applyDirectGridStyleContract(root);
      return grid;
    },
    initDirectGrids() {
      this.destroyDirectGrids();
      this.directGridWidgets = [
        this.initDirectGrid(this.$refs.normalNumberGrid, false),
        this.initDirectGrid(this.$refs.inputmodeNumberGrid, true)
      ].filter(Boolean);
    },
    applyDirectGridStyleContract(root) {
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll(".k-grid-content tbody tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        tr.classList.toggle("k-alt", index % 2 === 1);
      });
      root.querySelectorAll(".k-grid-content tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    destroyDirectGrids() {
      (this.directGridWidgets || []).forEach(grid => {
        try {
          grid?.destroy?.();
        } catch (_error) {
          // noop
        }
      });
      this.directGridWidgets = [];
      [this.$refs.normalNumberGrid, this.$refs.inputmodeNumberGrid].forEach(root => {
        if (root?.nodeType === 1) {
          root.innerHTML = "";
        }
      });
    },
    // [01] 共通鍵取得
    testBtn_01() {
      ApiHelper.get( `/send-push/publicKey`)
      .then(response => {
        // console.log("get publicKey", response);
        this.publicKey = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('CacheTestComponent.vue', 'testBtn_01', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log(error);
        throw error;
      });
    },
    // [02] 通知許可
    testBtn_02() {
      const ownerWindow = getScopedWindow(this.$el) || window;
      if ("Notification" in ownerWindow) {
        // Chrome の 設定 -> 詳細設定 -> プライバシーとセキュリティ -> サイトの設定 -> 通知 から初期化する
        const permission = ownerWindow.Notification.permission;
        if (permission === "denied" || permission === "granted") {
          // console.log("既に許可処理済みです。");
          return;
        } else {
          // 承認処理
          let thisObj = this;
          ownerWindow.Notification.requestPermission(function(response) {
            // console.log("認証結果 %o", response);
            thisObj.permission = response;
          });
        }
      } else {
        // console.log("ブラウザが通知非対応です。");
      }
    },
    // [03] Subscription
    testBtn_03() {
      let thisObj = this;
      webPushSubscribe(this.publicKey, this.$el)
      .then(response => {
        // console.log("サブスクリプション結果 %o", response);
        thisObj.subscriptionObj = response;
      });
    },
    // [04] 端末固有IDの生成
    testBtn_04() {
      if (this.terminalUniqueString === null) {
        this.terminalUniqueString = new Date().getTime().toString(16) + Math.floor(1000 * Math.random()).toString(16);
        getScopedLocalStorage(this.$el).setItem('terminalUniqueString', this.terminalUniqueString);
      }
    },
    // [05] 宛先情報をサーバに保存
    testBtn_05() {
      // 送信パラメータ
      let param = {
        // 端末固有ID
        terminalUniqueString: this.terminalUniqueString,
        // 施設コード
        facilityCd: this.getFacilityCd,
        // ログイン者のID
        userId: this.getStateUserAccountInfo.userId,
        endpoint: this.subscriptionObj.endpoint,
        key: "",
        contentEncoding: "",
        jwt: "",
        vapidVersion: ""
      };
      // console.log("[05]宛先情報をサーバに保存01： %o", param);

      if("getKey" in this.subscriptionObj) {
        param.key = btoa(String.fromCharCode.apply(null, new Uint8Array(this.subscriptionObj.getKey('p256dh')))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
        try {
          param.auth = btoa(String.fromCharCode.apply(null, new Uint8Array(this.subscriptionObj.getKey('auth')))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
          const ua = getScopedUserAgent(this.$el);
          const useAesgcm = ua.match(/Firefox\/(\d+)/) ? ((parseInt(RegExp.$1) >= 46) ? 1 : 0) :
            ((ua.match(/Chrome\/(\d+)/) ? ((parseInt(RegExp.$1) >= 50) ? 1 : 0) : 0));
          const encodings = PushManager.supportedContentEncodings;
          const idx = encodings instanceof Array ? encodings.indexOf('aes128gcm') : -1;
          param.contentEncoding = idx >= 0 ? 'aes128gcm' : (useAesgcm ? 'aesgcm' : 'aesgcm128');
        } catch (e) {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('CacheTestComponent.vue', 'testBtn_05', e);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          // console.log("エラーしました。 %o", e);
        }
      }
      // console.log("[05]宛先情報をサーバに保存02： %o", param);

      // VAPID (Voluntary Application Server Identification) という仕組みの為の処理
      param.jwt = {
        aud: new URL(this.subscriptionObj.endpoint).origin,
        sub: location.href
      };
      // 文字列で受け取るので、文字列に変換
      param.jwt = JSON.stringify(param.jwt);
      // 0: draft-ietf-webpush-vapid-01, 1: RFC 8292
      param.vapidVersion = (param.contentEncoding === 'aes128gcm') ? 1 : 0;
      // Workaround for RFC 8292 support on FCM; see https://github.com/web-push-libs/web-push/issues/278#issuecomment-356783840
      if(param.vapidVersion === 1) {
        param.endpoint = param.endpoint.replace('fcm/send', 'wp');
      }
      // console.log("[05]宛先情報をサーバに保存03： %o", param);

      // 送信処理
      ApiHelper.post(
        `/send-push/pushSave`,
        param).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('CacheTestComponent.vue', 'testBtn_05', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log("エラーしました。");
        throw error;
      });
    },
    // [06] Push通知
    testBtn_06() {
      // sendMessage含め機能削除
    },
    // [07] 通知解除
    testBtn_07() {
      // ブラウザの通知解除(unSubscribe)
      (getScopedWindow(this.$el) || window).navigator.serviceWorker.ready.then(function(reg) {
        reg.pushManager.getSubscription().then(function(subscription) {
          subscription.unsubscribe()
          .then(function(successful) {
            // 登録解除が成功
            // console.log("ブラウザの通知解除に成功しました。 %o", successful);
          })
          .catch(function(e) {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('CacheTestComponent.vue', 'testBtn_07', 'ブラウザの通知解除に失敗しました');
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            // 登録解除が失敗
            // console.log("ブラウザの通知解除に失敗しました。 %o", e);
          })
        })
      });
    },
    // [08] 宛先情報削除
    testBtn_08() {
      // console.log("[08]宛先情報削除：%o", this.terminalUniqueString);
      // 施設コード、ログイン者のIDに該当する送信先を削除する
      ApiHelper.put(`/send-push/pushDelete/${this.terminalUniqueString}`)
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('CacheTestComponent.vue', 'testBtn_08', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log("エラーしました。");
        throw error;
      });
    },
    // ログ設定反映ボタン処理
    reSetLoggerSetting() {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "ログ出力設定更新",
        title: DIALOG_MESSAGES[13000005].title,
        // message: "<div style='max-height: 60vh; overflow-y: auto;'>ロガー設定の再読み込みを、各モジュールに行わせます。</br>実施対象のモジュール数や状態により、実施完了まで時間がかかる場合がございます。</br>よろしいですか？</div>",
        message: messageFormat(DIALOG_MESSAGES[13000005].message, "<div style='max-height: 60vh; overflow-y: auto;'>", "</div>"),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        callback: async answer => {
          if (answer === 1) {
            sendRequestLoggerSetFlgUpddate()
              .then(response => {
                const result = JSON.parse(response.data.errorList);
                if (!response.data.readSetting) {
                  // sys_system_define：ロガー設定更新対象モジュールリスト の設定が正常に読み込みできなかった場合
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                    // title: "ログ出力設定更新",
                    // message: "ロガー設定更新対象モジュールリストが正常に読み込めませんでした。"
                    title: DIALOG_MESSAGES[12000317].title,
                    message: messageFormat(DIALOG_MESSAGES[12000317].message)
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  });
                } else if (result.length > 0) {
                  // ログ設定反映処理でエラーになったモジュールが存在する場合
                  let mdNames = "";
                  result.forEach(name => {
                    mdNames = mdNames + name + "</br>";
                  });
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                    // title: "ログ出力設定更新",
                    // message: "<div style='max-height: 60vh; overflow-y: auto;'>下記のモジュールの更新処理に失敗しました。</br>" + mdNames + "</div>"
                    title: DIALOG_MESSAGES[12000318].title,
                    message: messageFormat(DIALOG_MESSAGES[12000318].message, "<div style='max-height: 60vh; overflow-y: auto;'>", mdNames + "</div>")
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  });
                } else {
                  // 処理が全て正常に終了した場合
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                    // title: "ログ出力設定更新",
                    // message: "処理が正常に終了しました。"
                    title: DIALOG_MESSAGES[12000319].title,
                    message: messageFormat(DIALOG_MESSAGES[12000319].message)
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  });
                }
              })
              .catch(error => {
                getErrorMessage("CacheTestComponent.vue", "reSetLoggerSetting", error);
                throw error;
              });
          }
        }
      });
    }
  },
  created() {
    this.readCss();

    // マニュアル用デバイス判断
    const ua = getScopedUserAgent(this.$el);
    if (ua.match(/iPhone|iPad/)) {
      this.device = "iOS";
    } else if (!ua.match(/Android/)) {
      this.device = "notMobile";
    }

  },
  mounted() {
    // 通知の認証状態を取得
    this.permission = (getScopedWindow(this.$el) || window).Notification?.permission;
    // localStorage から端末固有IDを取得(未保存の場合はnull)
    this.terminalUniqueString = getScopedLocalStorage(this.$el).getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);
    this.$nextTick(() => this.initDirectGrids());
  },
  beforeUnmount() {
    this.destroyDirectGrids();
  },

};
</script>
<style scoped>
th {
  width: 300px;
  align: center;
}
#style-test{
  color: #FF00FF !important;
}
.cache-test-direct-grid {
  height: 100px;
}
</style>
