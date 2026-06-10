<template>
  <div class="vertical-div">
    <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
    <!--<div class="disp-item-area">-->
    <div class="disp-item-area" style="float: left;width: calc(100% / 4)">
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
      <label class="title ntss-pat-event-label changeRow">{{ getInputFieldName }}&emsp;</label>
    </div>
    <div class="disp-item-area text-area text-area-view" v-show="isSelectedFormatting && !getViewMode && !getIsOtherFacilitys">
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <v-ons-button class="button-import" @click="dataImport" v-if="isSelectSourceField">取得</v-ons-button>
      <com-textarea
        cssClass="content-textarea textarea-custom-text-font comment-textarea-style textarea-resize-vertical"
        :idTextarea="'editor-input-' + propsIndex"
        @set-content-data="setContentData"
      /> -->
      <v-ons-button
        class="button-import"
        @click="dataImport"
        v-if="isSelectSourceField"
        :disabled="
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        >取得</v-ons-button
      >
      <com-textarea
        cssClass="content-textarea textarea-custom-text-font comment-textarea-style textarea-resize-vertical"
        :disabled="
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        :idTextarea="'editor-input-' + propsIndex"
        @set-content-data="setContentData"
      />
      <!-- mod #10359 編集権限の動作不正 end -->
      <pop-over-fixed-phrase
        v-bind="popoverData"
        :target-position-element="popoverTargetElement()"
        @popover-close="closePopover"
        :disabled="
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        @popover-return="selectPhrase"
      />
    </div>
    <!--mod FNSI-改修内容リッチテキストのスタイルが表示されない。 任 start-->
    <!--<div class="disp-item-area text-area" v-show="isSelectedFormatting && getViewMode">
      <p v-html="$sanitize(getResultHtmlText)" class="text-area-view"></p>-->
    <div class="disp-item-area text-area text-area-view ex-text-view-area" v-show="(isSelectedFormatting && getViewMode) || getIsOtherFacilitys" v-html="getResultHtmlText">
    <!--mod FNSI-改修内容リッチテキストのスタイルが表示されない。 任 end-->
    </div>
    <div class="disp-item-area text-area text-area-view" v-show="!isSelectedFormatting && !getViewMode && !this.getIsOtherFacilitys">
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <v-ons-button class="button-import" @click="dataImport" v-if="isSelectSourceField">取得</v-ons-button> -->
      <v-ons-button
        class="button-import"
        :disabled="
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        @click="dataImport"
        v-if="isSelectSourceField"
        >取得</v-ons-button
      >
      <!-- mod #10359 編集権限の動作不正 end -->
      <!-- mod #10359 編集権限の動作不正 start -->

      <!-- <com-textarea
        :content="inputText"
        cssClass="content-input content-textarea textarea-custom-text-font comment-textarea-style textarea-resize-vertical"
        :idTextarea="'com-textarea-pat-event' + getNextIndex()"
        @set-content-data="setContentData"
      /> -->
      <com-textarea
        :content="inputText"
        :disabled="
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        cssClass="content-input content-textarea textarea-custom-text-font comment-textarea-style textarea-resize-vertical"
        :idTextarea="'com-textarea-pat-event' + getNextIndex()"
        @set-content-data="setContentData"
      />
      <!-- mod #10359 編集権限の動作不正 end -->
    </div>
    <div class="disp-item-area text-area text-area-view" v-show="!isSelectedFormatting && getViewMode">
      <span class="text-area-view ntss-pat-event-label">{{getResultContentText}}&nbsp;</span>
    </div>
  </div>
</template>

<script>
  import {mapActions, mapGetters} from "vuex";
  import $$ from "jquery";
  import {replaceLtGt} from "@/utils/util.js";
  import CommonTextArea from "@/components/common/CommonTextArea";
  // add FNSI-権限関連 王 20200927 start
  import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  // add FNSI-権限関連 王 20200927 end
  /*add FNSI-改修内容redmain4416 任 start*/
  import MasterSelectorFixedPhrase from "@/components/common/master-selector/MasterSelectorFixedPhrase";
  /*add FNSI-改修内容redmain4416 任 end*/
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end
export default {
  // add FNSI-権限関連 王 20200927 start
  mixins: [ComponentGuardMixin],
  // add FNSI-権限関連 王 20200927 end
  name: "PatEventTextArea",
  // add FNSI-権限関連 王 20200927 start
  props: ["propsIndex"],
  // add FNSI-権限関連 王 20200927 end
  components: {
    /*add FNSI-改修内容redmain4416 任 start*/
    "pop-over-fixed-phrase": MasterSelectorFixedPhrase,
    /*add FNSI-改修内容redmain4416 任 end*/
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      /*add FNSI-改修内容redmain4416 任 start*/
      commentTimer: 0,
      tapedTwice: false,
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "right"
      },
      editor: null,
      /*add FNSI-改修内容redmain4416 任 end*/
      inputText: "",
      tools: [
        "bold",
        "italic",
        "underline",
        "strikethrough",
        {
          name: "fontName",
          // mod #9504 2023/12/04 拡張書式の動作不正 張玲 start
          // 9504対応 フォントの設定を修正 START
          // items: [
          // { text: "メイリオ", value: "Meiryo" },
          // { text: "ＭＳ ゴシック", value: "ＭＳゴシック" },
          // { text: "ＭＳ Ｐゴシック", value: "ＭＳＰゴシック" },
          // { text: "ＭＳ 明朝", value: "ＭＳ明朝" },
          // { text: "ＭＳ Ｐ明朝", value: "ＭＳＰ明朝" },
          // { text: "MS UI Gothic", value: "MSUIGothic" },
          // { text: "Arial", value: "Arial" },
          // { text: "Osaka", value: "Osaka" },
          // { text: "Helvetica Neue", value: "HelveticaNeue" },
          // { text: "Helvetica", value: "Helvetica" },
          // { text: "sans-serif", value: "sans-serif" },
          // { text: "Times New Roman", value: "TimesNewRoman" }
          // ]
          items: [
          { text: "メイリオ", value: "Meiryo" },
          { text: "ＭＳ ゴシック", value: "MSGothicAlias" },
          { text: "ＭＳ Ｐゴシック", value: "MSPGothicAlias" },
          { text: "ＭＳ 明朝", value: "MSMinchoAlias" },
          { text: "ＭＳ Ｐ明朝", value: "MSPMinchoAlias" },
          { text: "MS UI Gothic", value: "MSUIGothicAlias" },
          { text: "Arial", value: "ArialAlias" },
          { text: "Osaka", value: "OsakaAlias" },
          { text: "Helvetica Neue", value: "HelveticaNeueAlias" },
          { text: "Helvetica", value: "HelveticaAlias" },
          { text: "sans-serif", value: "SansSerifAlias" },
          { text: "Times New Roman", value: "TimesNewRomanAlias" }
          ]
          // 9504対応 フォントの設定を修正 END
          // mod #9504 2023/12/04 拡張書式の動作不正 張玲 end
        },
        // mod #10538 2024/04/22 拡張書式テキストエリアのカラーパレット変更 Thach start
        {
          name: "foreColor",
          palette:[
            "#FFFFFF", "#000000", "#E7E6E6", "#44546A", "#4472C4", "#ED7D31", "#A5A5A5", "#FFC000", "#5B9BD5", "#70AD47",
            "#F2F2F2", "#808080", "#D0CECE", "#D6DCE4", "#D9E1F2", "#FCE4D6", "#EDEDED", "#FFF2CC", "#DDEBF7", "#E2EFDA",
            "#D9D9D9", "#595959", "#AEAAAA", "#ACB9CA", "#B4C6E7", "#F8CBAD", "#DBDBDB", "#FFE699", "#BDD7EE", "#C6E0B4",
            "#BFBFBF", "#404040", "#757171", "#8497B0", "#8EA9DB", "#F4B084", "#C9C9C9", "#FFD966", "#9BC2E6", "#A9D08E",
            "#A6A6A6", "#262626", "#3A3838", "#333F4F", "#305496", "#C65911", "#7B7B7B", "#BF8F00", "#2F75B5", "#548235",
            "#808080", "#0D0D0D", "#161616", "#222B35", "#203764", "#833C0C", "#525252", "#806000", "#1F4E78", "#375623",
            "#C00000", "#FF0000", "#FFC000", "#FFFF00", "#92D050", "#00B050", "#00B0F0", "#0070C0", "#002060", "#7030A0"
          ],
          columns: 10
        },
        {
          name: "backColor",
          palette:[
            "#FFFFFF", "#000000", "#E7E6E6", "#44546A", "#4472C4", "#ED7D31", "#A5A5A5", "#FFC000", "#5B9BD5", "#70AD47",
            "#F2F2F2", "#808080", "#D0CECE", "#D6DCE4", "#D9E1F2", "#FCE4D6", "#EDEDED", "#FFF2CC", "#DDEBF7", "#E2EFDA",
            "#D9D9D9", "#595959", "#AEAAAA", "#ACB9CA", "#B4C6E7", "#F8CBAD", "#DBDBDB", "#FFE699", "#BDD7EE", "#C6E0B4",
            "#BFBFBF", "#404040", "#757171", "#8497B0", "#8EA9DB", "#F4B084", "#C9C9C9", "#FFD966", "#9BC2E6", "#A9D08E",
            "#A6A6A6", "#262626", "#3A3838", "#333F4F", "#305496", "#C65911", "#7B7B7B", "#BF8F00", "#2F75B5", "#548235",
            "#808080", "#0D0D0D", "#161616", "#222B35", "#203764", "#833C0C", "#525252", "#806000", "#1F4E78", "#375623",
            "#C00000", "#FF0000", "#FFC000", "#FFFF00", "#92D050", "#00B050", "#00B0F0", "#0070C0", "#002060", "#7030A0"
          ],
          columns: 10
        },
        // mod #10538 2024/04/22 拡張書式テキストエリアのカラーパレット変更 Thach end
        // #5842 テキストエリアの不正 訾浩 start
        {
          name: "fontSize",
          items: [
            { text: "1 (8pt)", value: "8pt" },
            { text: "2 (10pt)", value: "10pt" },
            { text: "3 (12pt)", value: "12pt" },
            { text: "4 (14pt)", value: "14pt" },
            { text: "5 (18pt)", value: "18pt" },
            { text: "6 (24pt)", value: "24pt" },
            { text: "7 (36pt)", value: "36pt" },
          ]
        }
        // #5842 テキストエリアの不正 訾浩 end
      ],
      textAreaIdIndex: 0,
      windowWidth: window.innerWidth,
      copyFontSize: null
    };
  },

  computed: {
    // mod FNSI-共有を追加 王 20200921 start
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      "getViewMode"
    ]),
    // mod FNSI-共有を追加 王 20200921 end
    ...mapGetters("pat-event/list", ["getUpdateMode"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("mst-user", {getSharedFlag: "getIsRegisteredShared"}),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    // add FNSI-共有を追加 王 20200921 end
    // add #12462 患者情報共有 20260312 start
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    // add #12462 患者情報共有 20260312 end
    isSelectSourceField() {
      const input = this.getPatEventInputParams[this.propsIndex].item_json;
      return input.sql_cd && String(input.sql_cd).length > 0;
    },
    getInputFieldName() {
      const flag = this.getPatEventInputParams[this.propsIndex]
        .is_field_display;
      // add 6850 テキストエリアのデフォルト表示に直前に開いたテンプレートの内容が表示される。 関 start
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // let editor = $$("#editor-input-" + this.propsIndex).data("kendoEditor");
      // if (editor && this.getInputHtmltValue != undefined && this.getInputHtmltValue != null && this.getInputHtmltValue.trim() != "") {
      //    editor.body.innerText ='';
      //    editor.exec("insertHTML", { value: this.getInputHtmltValue });
      // }
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      // add 6850 テキストエリアのデフォルト表示に直前に開いたテンプレートの内容が表示される。 関 end
      if (flag === "1") {
        return this.getPatEventInputParams[this.propsIndex].field_name;
      } else {
        return "";
      }
    },
    getInputDefaultValue() {
      // mod 患者イベント表示不正を対応する。 dengshen start
      // const input = this.getPatEventInputParams[this.propsIndex].item_json;
      // return input.default_value;
      const input = !this.getPatEventInputParams ? "" : this.getPatEventInputParams[this.propsIndex].item_json;
      return !input ? "" : input.default_value;
      // mod 患者イベント表示不正を対応する。 dengshen end
    },
     getInputHtmltValue() {
     // mod 患者イベント表示不正を対応する。 dengshen start
     // const input = this.getPatEventInputParams[this.propsIndex].item_json;
     // return input.html_value;
     const input = !this.getPatEventInputParams ? "" : this.getPatEventInputParams[this.propsIndex].item_json;
     return !input ? "" : input.html_value;
     // mod 患者イベント表示不正を対応する。 dengshen end
    },
    getInputMaxLength() {
      // mod 患者イベント表示不正を対応する。 dengshen start
      // const input = this.getPatEventInputParams[this.propsIndex].item_json;
      // return input.max_length;
      const input = !this.getPatEventInputParams ? "" : this.getPatEventInputParams[this.propsIndex].item_json;
      return !input ? "" : input.max_length;
      // mod 患者イベント表示不正を対応する。 dengshen end
    },
    getResultHtmlText() {
      // mod 患者イベント表示不正を対応する。 dengshen start
      // const result = this.getPatEventResultParams[this.propsIndex].result_value;
      // return result;
      // add #10839 観察記録のテキストエリアでゴミが出る linjunfeng start
      let result = !this.getPatEventInputParams ? "" : this.getPatEventResultParams[this.propsIndex].result_value;
      if (this.getInputIsFormatting === "1" && result.indexOf("<p") != 0) {
        result = `<p>${result}</p>`
      }
      // add #10839 観察記録のテキストエリアでゴミが出る linjunfeng end
      return !result ? "" : result;
      // mod 患者イベント表示不正を対応する。 dengshen end
    },
    getInputIsFormatting() {
      // mod 患者イベント表示不正を対応する。 dengshen start
      // const input = this.getPatEventInputParams[this.propsIndex].item_json;
      // return input.is_formatting;
      const input = !this.getPatEventInputParams ? "" : this.getPatEventInputParams[this.propsIndex].item_json;
      return !input ? "" : input.is_formatting;
      // mod 患者イベント表示不正を対応する。 dengshen end
    },
    isSelectedFormatting() {
      return this.getInputIsFormatting === "1";
    },
    getResultContentText() {
      if (this.getResultHtmlText !== "") {
        return this.getResultHtmlText;
      } else {
        if (this.getInputDefaultValue !== "") {
          return this.getInputDefaultValue;
        }
      }
      return "";
    }
  },

  watch: {},

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  destroyed() {
    window.checkCommentLongPress = null;
    window.onDblTap = null;
    window.endLongTouch = null;
    window.showPopover1 = null;
  },

  created() {},
  mounted() {
    //リッチテキストエディタの設定
    this.setDataHtmlText();
    window.checkCommentLongPress = this.checkCommentLongPress;
    window.onDblTap = this.onDblTap;
    window.endLongTouch = this.endLongTouch;
    window.showPopover1 = this.showPopover1;
    //インラインフレームのタグの取得
    let iframe =  document.getElementsByTagName("iframe");
    let iframeDocument = null;
    let textareaIndex = -1;
    //処理対象のテキストエリアの要素に対応するインラインフレームの要素のインデックスを取得する
    for(let index = 0;index <= iframe.length - 1;index++){
      //インラインフレームの次に位置する要素のIDが処理対象のテキストエリアのIDの場合
      if(iframe[index].contentDocument && iframe[index].nextElementSibling
      && iframe[index].nextElementSibling.id === 'editor-input-' + this.propsIndex){
        textareaIndex = index;
        break;
      }
    }
    //処理対象のテキストエリアの要素に対応するインラインフレームの要素が存在する場合
    if (textareaIndex >= 0){
      iframeDocument = iframe[textareaIndex].contentDocument;
      iframeDocument.id = this.propsIndex;
      //マウスのボタンの長押しで発生する処理
      iframeDocument.onmousedown = function(ev){
        window.checkCommentLongPress(1);
        //処理対象のテキストエリアフィールドのインデックスをセッションで保持する
        sessionStorage.setItem("currentTargetIndex", ev.currentTarget.id);
      }
      //マウスのボタンを離した際に発生する処理
      iframeDocument.onmouseup = function(){
        window.checkCommentLongPress(0);
      }
      //マウスのカーソルを動かした際に発生する処理
      iframeDocument.onmousemove = function(){
        // ドラッグ処理が長押し処理と競合する対策
        window.checkCommentLongPress(0);
      }
      //マウスのカーソルが外れた際に発生する処理
      iframeDocument.onmouseout = function(){
        // ドラッグ処理が長押し処理と競合する対策
        window.checkCommentLongPress(0);
      }
      //ダブルクリック処理
      iframeDocument.ondblclick = function(ev){
        // iOS/Androidでダブルタップのテキスト選択処理の度に発火してしまう為、該当端末の場合は処理をしない
        const ua = navigator.userAgent;
        if (ua.match(/Android/) || ua.match(/iPhone|iPad/)) {
          return;
        }
        window.showPopover1();
        //処理対象のテキストエリアフィールドのインデックスをセッションで保持する
        sessionStorage.setItem("currentTargetIndex", ev.currentTarget.id);
      }
      //タップ長押し/ダブルタップ処理
      iframeDocument.addEventListener('touchstart',(ev) => {
        window.onDblTap;
        //処理対象のテキストエリアフィールドのインデックスをセッションで保持する
        sessionStorage.setItem("currentTargetIndex", ev.currentTarget.id);
      },{passive: false});
      //タップ終了時の処理
      iframeDocument.addEventListener('touchend', window.endLongTouch);
    }
    this.editDataHtmlText();
    this.inputText = this.getResultContentText;

    // add FNSI-共有を追加 王 20200921 start
    let editor = $$("#editor-input-" + this.propsIndex).data("kendoEditor");
    if (typeof editor !== "undefined") {
      if (this.getSharedFacilityCd !== undefined && this.getSharedFacilityCd != null) {
        if (this.getSharedFlag === 1 && this.facilityCd !== this.getSharedFacilityCd) {
          $$(editor.body).attr("contenteditable", false);
        } else {
          $$(editor.body).attr("contenteditable", true);
        }
      } else {
        $$(editor.body).attr("contenteditable", true);
      }
      if(!this.getTreatmentRecordAuthority()){
        $$(editor.body).attr("contenteditable", false);
      }
    }
    // add FNSI-共有を追加 王 20200921 end

    // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 start
    //document.getElementsByClassName("k-selected-color")[0].style.backgroundColor = 'black';
    if(document.getElementsByClassName("k-selected-color").length > 0
       && null !== document.getElementsByClassName("k-selected-color")[0]) {
         document.getElementsByClassName("k-selected-color")[0].style.backgroundColor = 'black';
       }
    // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 end
  },

  methods: {
    ...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end

    // add FNSI-権限関連 王 20200927 start
    // 治療記錄の權限を取得する
    getTreatmentRecordAuthority() {
      if(this.getPatEventRecord.isComRec){
        return this.hasAuthority();
      }
      return true;
    },
    // add FNSI-権限関連 王 20200927 end
    //TODO:
    returnDataHtmlText() {
      // console.log("returnDataHtmlText");
      // 書式設定可能の有場合
      // 改行付きデフォルトが改行なしになる   6130  shan   start
      if (this.getInputIsFormatting === "1") {
        let editor = $$("#editor-input-" + this.propsIndex).data("kendoEditor");
        editor.value("");
        // 文字セット
        // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 start
        //if (this.getResultHtmlText.trim() !== "") {
        if (undefined !== this.getResultHtmlText && null !== this.getResultHtmlText && this.getResultHtmlText.trim() !== "") {
        // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 end
          editor.exec("insertHTML", { value: this.getResultHtmlText });
        } else {
          // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 start
          //if (this.getInputDefaultValue.trim() !== "") {
          if (undefined !== this.getInputDefaultValue && null !== this.getInputDefaultValue && this.getInputDefaultValue.trim() !== "") {
          // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 end
            editor.exec("insertHTML", {
              value:
              // mod 改修内容redmain fan 4758 start
              // "<span style='font-size: 14pt; font-family: メイリオ;'>" +
                "<span style='font-family: Meiryo; font-size: 12pt; white-space: break-spaces;'>" +
                // mod 改修内容redmain fan 4758 end
                this.getInputDefaultValue +
                "</span>"
            });
            let range = editor.createRange();
            range.selectNodeContents(editor.body);
            editor.selectRange(range);
          }
        }
      }
      // 改行付きデフォルトが改行なしになる   6130  shan   end
    },
    /**
     * 定型文モーダルウィンドウの表示処理
     */
    showPopover1() {
      this.popoverData.popoverVisible = true;
    },
    /**
     * 定型文モーダルウィンドウが閉じた際に発生するイベント
     */
    closePopover() {
      //処理対象のテキストエリアフィールドのインデックスのセッションを除去する
      sessionStorage.removeItem("currentTargetIndex");
      this.popoverData.popoverVisible = false;
    },
    /**
     * 定型文モーダルウィンドウでOKボタン押下時の選択項目の取得
     */
    selectPhrase(data) {
      //処理対象のテキストエリアフィールドのインデックスを取得する
      let currentTargetIndex = sessionStorage.getItem("currentTargetIndex");
      let editor = $$("#editor-input-" + currentTargetIndex).data("kendoEditor");
      editor.exec("insertHTML", {
        value:
          "<span style='font-family: Meiryo; font-size: 12pt; white-space: break-spaces;'>" +
          replaceLtGt(data?.text || '') +
          "</span>"
      });
    },
    /**
     * 定型文モーダルウィンドウ表示の対象要素の取得
     */
    popoverTargetElement() {
      //処理対象のテキストエリアフィールドのインデックスを取得する
      let currentTargetIndex = sessionStorage.getItem("currentTargetIndex");
      let editor = $$("#editor-input-" + currentTargetIndex);
      if (editor.length > 0) {
        return editor[0].previousSibling;
      }
    },
    /**
     * マウスボタンの長押しの判定処理
     */
    checkCommentLongPress(isMouseDown) {
      if (isMouseDown) {
        this.commentTimer = setTimeout(() => {
          window.showPopover1();
        }, 500);
      } else {
        clearTimeout(this.commentTimer);
      }
    },
    /**
     * ダブルタップした際に発生するイベント
     */
    onDblTap(event) {
      if (event.touches.length > 1) {
        // 2本以上同時にタップされた場合の処理(長押し処理を発火)
        window.setShowPopover = setTimeout(function() {
          window.showPopover1();
        }, 500);
      }
      if(!this.tapedTwice) {
        this.tapedTwice = true;
        setTimeout( () => { this.tapedTwice = false; }, 300 );
        return false;
      }
      event.preventDefault();
      window.showPopover1();
    },
    /**
     * タップが終了した際に発生するイベント
     */
    endLongTouch(event) {
      if (event.touches.length < 1) {
        // 全ての指が離れたら長押し処理を解除
        clearTimeout(window.setShowPopover);
      }
    },
    editDataHtmlText() {
      // console.log("editorDataHtmlText");
      if (this.getInputIsFormatting === "1") {
        // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 start
        //if (this.getResultHtmlText.trim() !== "") {
        if (undefined !== this.getResultHtmlText && null !== this.getResultHtmlText && this.getResultHtmlText.trim() !== "") {
        // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 end
          let editor = $$("#editor-input-" + this.propsIndex).data(
            "kendoEditor"
          );
          // add #12462 患者情報共有 start
          if(!this.getIsOtherFacilitys){
            // add #12462 患者情報共有 end
            if (this.getViewMode) {
              $$(editor.body).attr("contenteditable", false);
            } else {
              $$(editor.body).attr("contenteditable", true);
            }
          }
        }
      }
    },
    setDataHtmlText() {
      let self = this;
      // 書式設定可能の有場合
      if (this.getInputIsFormatting === "1") {
        // フォントプロパティ設定
        const tools = this.tools;
        $$("#editor-input-" + this.propsIndex).kendoEditor({
          /**
           *  @description テキストエリアのPasteイベント
           */
          paste: function(ev) {
            if(self.copyFontSize){
              ev.html = ev.html.replace(/(<span\b[^>]*?font-size:\s*).*?(;[^>]*>)/gi,"$1" + self.copyFontSize + "$2");
            }
          },
          tools,
          stylesheets: ["/ntss-admin-web/css/kendoEditorCustomStyle.css"],
          // add #9504 2023/12/06 拡張書式の動作不正 張玲 start
          messages:{
            fontNameInherit:"(デフォルト)",
            fontSizeInherit:"(デフォルト)"
          },
        // add #9504 2023/12/06 拡張書式の動作不正 張玲 bend
        });
        let editor = $$("#editor-input-" + this.propsIndex).data("kendoEditor");
        let styleTabBeforeCaret = "";
        if (undefined !== this.getResultHtmlText && null !== this.getResultHtmlText && this.getResultHtmlText.trim() !== "") {
          editor.exec("insertHTML", { value: this.getResultHtmlText });
        // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 start
        //}else if (null !== this.getInputHtmltValue && this.getInputHtmltValue.trim() !== "") {
        }else if (undefined !== this.getInputHtmltValue && null !== this.getInputHtmltValue && this.getInputHtmltValue.trim() !== "") {
        // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 end
          editor.exec("insertHTML", { value: this.getInputHtmltValue });
        } else {
          // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 start
          //if (null !== this.getInputDefaultValue && this.getInputDefaultValue.trim() !== "") {
          if (undefined !== this.getInputDefaultValue && null !== this.getInputDefaultValue && this.getInputDefaultValue.trim() !== "") {
          // mod FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 end
            editor.exec("insertHTML", {
              value:
              // mod 改修内容redmain fan 4758 start
              //"<span style='font-size: 14pt; font-family: メイリオ;'>" +
                "<span style='font-family: Meiryo; font-size: 12pt; white-space: break-spaces;'>" +
                // mod 改修内容redmain fan 4758 end
                this.getInputDefaultValue +
                "</span>"
            });
            /*del FNSI-改修内容redmain6353 任 start*/
            //let range = editor.createRange();
            //range.selectNodeContents(editor.body);
            // editor.selectRange(range);
            /*del FNSI-改修内容redmain6353 任 end*/
          }
        }
        /**
         * @description テキストエリアのフォーカスアウト発生時のイベント
        */
        $$(editor.window).blur(function(ev) {
          // mod bug 7611 修正 chen start
          self.editContent(
            //editor.value()
            ev.currentTarget.document.documentElement.lastElementChild.innerHTML
          );
          // mod bug 7611 修正 chen end
          /**
           * @description テキストエリアのクリックイベント
           */
          $$(document).click(function(event) {
            if(!($$(event.target).closest(".k-editor").length || $$(event.target).closest(".k-state-selected").length || $$(event.target).closest(".popover__content").length)) {
              if(editor.window.getSelection()) {
                let range = document.createRange();
                range.selectNodeContents(self.findLastTextNode(ev.currentTarget.document.body));
                editor.window.getSelection().removeAllRanges();
                editor.window.getSelection().addRange(range);
                editor.window.getSelection().collapseToEnd();
              }
            }
          });
          /**
           * @description カレンダーのフォーカス発生時のイベント
           */
          $$(document).on("focus", ".calendar", function() {
            if(editor.window.getSelection()) {
              let range = document.createRange();
              range.selectNodeContents(self.findLastTextNode(ev.currentTarget.document.body));
              editor.window.getSelection().removeAllRanges();
              editor.window.getSelection().addRange(range);
              editor.window.getSelection().collapseToEnd();
            }
          });
        });
        /**
         * @description テキストエリアのkeydownイベント
        */
        editor.window.addEventListener('keydown',  (ev) => {
          if(ev.key === "Enter"){
            let beforeRange = editor.window.getSelection();
            let focusNode = beforeRange.focusNode;
            let focusOffset = beforeRange.focusOffset;
            //Enterキー押下前にカーソルの位置にフォーカス可能な要素が存在しない場合
            if(focusNode.nodeName === "BODY") {
              ev.stopPropagation();
              setTimeout(() => {
                //Enterキー押下後にカーソルが置かれた行のHTMLデータが<p><br></p>の場合、<p>&#xFEFF</p>に置き換える
                const newChild = document.createElement("p");
                newChild.textContent = "\ufeff";
                const targetChild = focusNode.childNodes[focusOffset];
                focusNode.replaceChild(newChild,targetChild);
              }, 0);
            }
          } else if(ev.key === "Backspace" || ev.key === "Delete"){
            let beforeRange = editor.window.getSelection();
            if((beforeRange.type === "Caret" && beforeRange.anchorNode.nodeName !== "P" && beforeRange.anchorNode.data !== "\ufeff" && beforeRange.anchorOffset === 1)
              || (beforeRange.type === "Range" && beforeRange.anchorNode.nodeName !== "P" && beforeRange.anchorNode.data !== "\ufeff" && beforeRange.anchorNode !== beforeRange.focusNode)){
              let currentNode = beforeRange.anchorNode;
              let selectionType = beforeRange.type;
              let previousNodeExistsFlg = false;
              while (currentNode && currentNode.nodeName !== "BODY") {
                if(currentNode.nodeName === "P"){
                  break;
                }
                if(currentNode.previousElementSibling){
                  previousNodeExistsFlg = true;
                }
                currentNode = currentNode.parentElement;
              }
              setTimeout(() => {
                let postChangedSelection = editor.window.getSelection();
                let postChangedAnchorNode = postChangedSelection.anchorNode;
                let offset = -1;
                if(selectionType === "Caret" && previousNodeExistsFlg){
                  offset = postChangedAnchorNode.length;
                } else if(selectionType === "Range"){
                  if(postChangedAnchorNode.data.indexOf("\ufeff") >= 0 && postChangedAnchorNode.data.length !== postChangedAnchorNode.data.split("\ufeff").length - 1){
                    postChangedAnchorNode.data = postChangedAnchorNode.data.replace(/\ufeff/g, '');
                  }
                  offset = postChangedAnchorNode.length;
                } else {
                  offset = 0;
                }
                postChangedSelection.collapse(postChangedAnchorNode, offset);
              }, 0);
            }
          }
        },true);
        /**
         * @description テキストエリアのkeydownイベント
        */
        $$(editor.window).keydown(function(ev) {
          if(ev.key === "Backspace" || ev.key === "Delete"){
            let beforeRange = editor.window.getSelection();
            let focusNode = beforeRange.focusNode;
            let focusOffset = beforeRange.focusOffset === 0 ? 0 : beforeRange.focusOffset - 1;
            if(focusNode.nodeName !== "BODY") {
              let targetLastNode = focusNode.nodeName === "#text" ? focusNode : focusNode.childNodes[focusOffset];
              let targetLastTextNode = self.findLastTextNode(targetLastNode);
              if (focusNode.data === "") {
                styleTabBeforeCaret = self.getStyleTabRootBefore(targetLastTextNode)
              } else {
                styleTabBeforeCaret = self.getStyleTabBefore(targetLastTextNode);
              }
            }
          }
        });
        /**
         * @description テキストエリアのkeyupイベント
        */
        $$(editor.window).keyup(function(ev) {
          let selection = editor.window.getSelection();
          let anchorNode = selection.anchorNode;
          let anchorOffset = selection.anchorOffset;
          let styleArray = self.getFontStyle(anchorNode);

          if (ev.key === "Backspace" || ev.key === "Delete") {
            if(Object.keys(styleArray).length === 0 && styleTabBeforeCaret !== "") {
              editor.exec("insertHTML", {
                value:
                  styleTabBeforeCaret
              });
              let newRange = editor.createRange();
              if(anchorNode.nodeName === "BODY") {
                newRange.selectNodeContents(self.findFirstTextNode(editor.body));
              } else {
                if(anchorOffset >= 1){
                  newRange.selectNodeContents(self.findFirstTextNode(anchorNode.childNodes[anchorOffset-1]));
                } else{
                  newRange.selectNodeContents(self.findFirstTextNode(anchorNode.childNodes[0]));
                }
              }
              selection.removeAllRanges();
              selection.addRange(newRange);
              selection.collapseToEnd();
              for (let i = anchorNode.childNodes.length - 1; i > 0; i--) {
                if(anchorNode.childNodes[i] && anchorNode.childNodes[i].innerText === "") {
                  anchorNode.childNodes[i].remove();
                }else if(anchorNode.childNodes[i] && i >= anchorOffset && anchorNode.childNodes[i].innerText === "\ufeff"){
                  anchorNode.childNodes[i].remove();
                }
              }
            }else {
              let anchorParentP = self.findParentNode(anchorNode, "P");
              if(anchorParentP) {
                if(anchorNode.textContent !== ""){
                  for (let i = anchorParentP.childNodes.length - 1; i >= 0; i--) {
                    if(anchorParentP.childNodes[i] && anchorParentP.childNodes[i].textContent === "") {
                      anchorParentP.childNodes[i].remove();
                      if(anchorParentP.childNodes.length === 0){
                        anchorParentP.remove();
                      }
                    }
                  }
                }else if(anchorParentP.childNodes.length === 1 && anchorParentP.childNodes[0].nodeName === "BR"){
                  anchorParentP.childNodes[0].remove();
                  anchorParentP.textContent = "\ufeff";
                }
              }
            }
          }
        });
        /**
         * @description テキストエリアのIMEの変換終了時のイベント
        */
        editor.window.addEventListener('compositionend',  (ev) => {
          ev.currentTarget.dispatchEvent(new Event('input'));
        });
        /**
         * @description テキストエリアの入力イベント発生前のイベント
        */
        editor.window.addEventListener('beforeinput',  (ev) => {
          if(ev.inputType === "deleteByCut"){
            let selection = editor.window.getSelection();
            const range = selection.getRangeAt(0);
            const cloneContents = range.cloneContents();
            const container = document.createElement('div');
            container.appendChild(cloneContents);
            self.copyFontSize = null;
            if(container.querySelectorAll('span').length <= 1){
              self.copyFontSize = ev.target.style.fontSize;
            }
            let anchorNode = selection.anchorNode;
            let currentNode = anchorNode;
            let previousNodeExistsFlg = false;
            while (currentNode && currentNode.nodeName !== "BODY") {
              if(currentNode.nodeName === "P"){
                break;
              }
              if(currentNode.previousElementSibling){
                previousNodeExistsFlg = true;
              }
              currentNode = currentNode.parentElement;
            }
            if(container.innerHTML.match(/^<p>(.*?)<\/p>/i)){
              setTimeout(() => {
                const newChildNode = document.createElement("p");
                newChildNode.textContent = "\ufeff";
                currentNode.parentNode.replaceChild(newChildNode,currentNode);
              }, 0);
            } else if(!container.innerHTML.match(/<p>(.*?)<\/p>/i)){
              if(currentNode.nodeName === "P" && currentNode.innerHTML === container.innerHTML){
                currentNode.textContent = "\ufeff";
              } else if(currentNode.nodeName === "P" && currentNode.childNodes.length === 1
                && currentNode.textContent === container.innerHTML){
                currentNode.textContent = "\ufeff";
              } else if(currentNode.nodeName === "BODY" && currentNode.textContent === container.innerHTML){
                setTimeout(() => {
                  if(currentNode.childNodes.length === 1 && currentNode.childNodes[0].nodeName === "BR"){
                    currentNode.childNodes[0].remove();
                  }
                }, 0);
              }
              if(selection.anchorOffset === 0){
                setTimeout(() => {
                  let postChangedSelection = editor.window.getSelection();
                  let postChangedAnchorNode = postChangedSelection.anchorNode;
                  let offset = previousNodeExistsFlg ? postChangedAnchorNode.length : 0;
                  postChangedSelection.collapse(postChangedAnchorNode, offset);
                }, 0);
              }
            }
          }
        });
        /**
         * @description テキストエリアの入力イベント
        */
        editor.window.addEventListener('input',  (ev) => {
          if(!ev.inputType || ev.inputType === "insertText"){
            let selection = editor.window.getSelection();
            let anchorNode = selection.anchorNode;
            let anchorOffset = selection.anchorOffset;
            let text = anchorNode.textContent;
            if(text.indexOf("\ufeff") >= 0 && text.length !== text.split("\ufeff").length - 1){
              let index = text.indexOf("\ufeff");
              while (index !== -1) {
                if(index < anchorOffset){
                  anchorOffset--;
                }
                index = text.indexOf("\ufeff", index + 1);
              }
              anchorNode.textContent = text.replace(/\ufeff/g, '');
              selection.collapse(anchorNode, anchorOffset);
            }
          }
        });
        /**
         * @description テキストエリアのcopyイベント
        */
        editor.window.addEventListener('copy',  (ev) => {
          self.copyFontSize = null;
          let selection = editor.window.getSelection();
          const range = selection.getRangeAt(0);
          const cloneContents = range.cloneContents();
          const container = document.createElement('div');
          container.appendChild(cloneContents);
          if(container.querySelectorAll('span').length <= 1){
            self.copyFontSize = ev.target.style.fontSize;
          }
        });
        //書式設定可能なテキストエリア上部のツールバーの要素を取得する
        let editorToolbarElement = document.querySelector("ul[aria-controls='editor-input-" + this.propsIndex + "']");
        if(editorToolbarElement){
          //テキストエリア上部のツールバーのフォント名のクリアボタンの要素の取得
          let editorToolbarClearFontFamily = editorToolbarElement.children[1].children[0].children[0].firstChild.nextElementSibling;
          //テキストエリア上部のツールバーのフォントサイズのクリアボタンの要素の取得
          let editorToolbarClearFontSize = editorToolbarElement.children[3].children[0].children[0].firstChild.nextElementSibling;
          /**
           * @description テキストエリア上部のツールバーのフォント名のクリアボタンのクリックイベント
           */
          editorToolbarClearFontFamily.addEventListener('click',  (ev) => {
            ev.currentTarget.previousElementSibling.value = "(デフォルト)";
            //フォント名のドロップダウンリストのクリックイベントを呼び出す
            ev.currentTarget.previousElementSibling.parentElement.parentElement.dispatchEvent(new Event('click'));
            //子コンポーネントのクリアボタンのクリックイベントをキャンセルする
            ev.stopPropagation();
          }, true);
          /**
           * @description テキストエリア上部のツールバーのフォントサイズのクリアボタンのクリックイベント
           */
          editorToolbarClearFontSize.addEventListener('click',  (ev) => {
            ev.currentTarget.previousElementSibling.value = "(デフォルト)";
            //フォントサイズのドロップダウンリストのクリックイベントを呼び出す
            ev.currentTarget.previousElementSibling.parentElement.parentElement.dispatchEvent(new Event('click'));
            //子コンポーネントのクリアボタンのクリックイベントをキャンセルする
            ev.stopPropagation();
          }, true);
        }
        /*add FNSI-改修内容redmain6353 任 start*/
        this.$parent.$refs.tbl.scrollTop = 0;
        /*add FNSI-改修内容redmain6353 任 end*/
      } else {
        if(!this.getPatEventResultParams[this.propsIndex].result_value){
          this.getPatEventResultParams[this.propsIndex].result_value = this.getInputDefaultValue;
        }
      }
    },
    async editContent(value) {
      const result = this.getPatEventResultParams[this.propsIndex];
      value = value.replace(/<br>/g, '\ufeff'); // <br>が<p>の中の時、表示は一行だがinnerTextは二行という状態になるので、<br>を&#xFEFF;に変える
      const values = {
        format_class: result.format_class,
        result_value: value
      };
      await this.setPatEventResultParamsUpdate({
        item: values,
        index: this.propsIndex
      });
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      const input = this.getPatEventInputParams[this.propsIndex];
      const result = this.getPatEventResultParams[this.propsIndex];
      let textValid = true;
      let count = 0;
      if (this.getInputIsFormatting === "1") {
        // JQUERY で直接文字列を取得
        let editor = $$($$("#editor-input-" + this.propsIndex).data("kendoEditor"))[0].body;
        let text = editor.innerText.replace(/\n\n/g, 'o'); // 表示の一行は\n\nになるので一桁にする
        text = text.replace(/\ufeff/g, ''); // 書式を追加した後に&#xFEFF;が入ったので除く
        text = text.replace(/\n/g, ''); // <br>が<p>の中の時、表示は一行だがinnerTextは二行という状態になるので、最後の行を除く

        count = Number(input.item_json.max_length);
        if (text.length > count) {
          textValid = false;
        }
      } else {
        count = Number(input.item_json.max_length);
        if (result.result_value.length > count) {
          textValid = false;
        }
      }
      return {
        textValid: textValid
      };
    },
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000310].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.textValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "文字数が入力可能文字数を超えてます。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000310].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },
    dataImport() {
      const input = this.getPatEventInputParams[this.propsIndex].item_json;
      this.$emit("patEventImport", {
        index: this.propsIndex,
        sqlCd: input.sql_cd
      });
    },
    dataImportResult(dataList) {
      const field = this.getPatEventInputParams[this.propsIndex].item_json
        .source_field;
      let values = [];
      for (const data of dataList) {
        values.push(data[field]);
      }
      if (this.getInputIsFormatting === "1") {
        // 書式設定あり
        // フォントプロパティ設定
        let editor = $$("#editor-input-" + this.propsIndex).data("kendoEditor");
        // mod 改修内容redmain fan 4758 start
        // editor.exec("fontSize", { value: "14pt" });
        editor.exec("fontName", { value: "Meiryo" });
        editor.exec("fontSize", { value: "12pt" });
        // 文字セット
        const value =
          //"<span style='font-size: 14pt; font-family: メイリオ;'>" +
          "<span style='font-family: Meiryo; font-size: 12pt; white-space: break-spaces;'>" +
          // mod 改修内容redmain fan 4758 end
          values.join("\n") +
          "</span>";
        editor.exec("insertHTML", {
          value: value
        });
        let range = editor.createRange();
        range.selectNodeContents(editor.body);
        editor.selectRange(range);

        this.editContent(value);
      } else {
        // 書式設定なし
        this.editContent(values.join("\n"));
        this.inputText = values.join("\n");
      }
    },
    getNextIndex() {
      const element = document.getElementById("com-textarea-pat-event" + this.textAreaIdIndex);
      if (element) {
        this.textAreaIdIndex = this.textAreaIdIndex + 1;
      }
      return this.textAreaIdIndex;
    },
    setContentData(newValue) {
      this.editContent(newValue);
    },
    findLastTextNode(node) {
      if(node.nodeName === "#text") {
        return node;
      }
      let returnNode = node;
      while(true) {
        if(!returnNode.lastChild) {
          break;
        }
        returnNode = returnNode.lastChild;
        if(returnNode.nodeName === "#text") {
          break;
        }
      }
      return returnNode;
    },
    findFirstTextNode(node) {
      if(node.nodeName === "#text") {
        return node;
      }
      let returnNode = node;
      while(true) {
        if(!returnNode.firstChild) {
          break;
        }
        returnNode = returnNode.firstChild;
        if(returnNode.nodeName === "#text") {
          break;
        }
      }
      return returnNode;
    },
    findParentNode(node, find) {
      let returnNodes = [];
      while(true) {
        if(node.nodeName === find) {
          returnNodes.push(node);
        } else {
          if(node.nodeName === "BODY") {
            break;
          }
        }
        if(!node.parentElement) {
          break;
        }
        node = node.parentNode;
      }
      if(find === "SPAN") {
        return returnNodes;
      } else if(returnNodes.length !== 0) {
        return returnNodes[0];
      }
      return null;
    },
    getRemainingNode(textNode, offset) {
      let parentPNode = this.findParentNode(textNode, "P");
      if(parentPNode) {
        let cloneNode = parentPNode.cloneNode(true);
        let foundNode = this.findEndContainer(parentPNode, textNode, cloneNode);
        let remainingText = this.removeBeforeOffset(foundNode, offset);
        let remainingNode = this.findParentNode(remainingText, "P");
        return remainingNode;
      }
      return null;
    },
    findEndContainer(originalNode, targetNode, cloneNode) {
      if(originalNode === targetNode) {
        return cloneNode;
      } else if(originalNode.nodeName === "#text") {
        return null;
      } else if(originalNode.childNodes) {
        let removecount = 0;
        for(let i = 0; i < originalNode.childNodes.length; i++) {
          let foundNode = this.findEndContainer(originalNode.childNodes[i], targetNode, cloneNode.childNodes[i - removecount]);
          if(foundNode) {
            return foundNode;
          } else {
            cloneNode.childNodes[i - removecount].remove();
            removecount = removecount + 1;
          }
        }
      }
      return null;
    },
    removeBeforeOffset(node, offset) {
      let remeiningText = node.textContent.substring(offset);
      let newTextNode = document.createTextNode(remeiningText);
      let parentNode = node.parentNode;
      parentNode.replaceChild(newTextNode, node);
      return newTextNode;
    },
    getFontStyle(node) {
      let parentSpanNodes = this.findParentNode(node, "SPAN");
      let parentPNode = this.findParentNode(node, "P");
      let styleArray = {};
      let styleList = ["fontSize", "fontFamily", "color", "backgroundColor", "textDecoration"];

      if(parentSpanNodes) {
        for(let parentSpanNode of parentSpanNodes) {
          for(let styleItem of styleList) {
            if(!styleArray[styleItem] && parentSpanNode.style[styleItem] !== "") {
              styleArray[styleItem] = parentSpanNode.style[styleItem];
            }
          }
        }
      }
      if(parentPNode) {
        for(let styleItem of styleList) {
          if(!styleArray[styleItem] && parentPNode.style[styleItem] !== "") {
            styleArray[styleItem] = parentPNode.style[styleItem];
          }
        }
      }
      return styleArray;
    },
    getStyleTabBefore(node) {
      let styleArray = this.getFontStyle(node);
      let styleStr = "";
      if(Object.keys(styleArray).length !== 0) {
        styleStr = "<span style='";
        if(styleArray.fontFamily && styleArray.fontFamily !== "") {
          styleStr = styleStr + "font-family: " + styleArray.fontFamily + "; ";
        }
        if(styleArray.fontSize && styleArray.fontSize !== "") {
          styleStr = styleStr + "font-size: " + styleArray.fontSize + "; ";
        }
        if(styleArray.color && styleArray.color !== "") {
          styleStr = styleStr + "color: " + styleArray.color + "; ";
        }
        if(styleArray.backgroundColor && styleArray.backgroundColor !== "") {
          styleStr = styleStr + "background-color: " + styleArray.backgroundColor + "; ";
        }
        if(styleArray.textDecoration && styleArray.textDecoration !== "") {
          styleStr = styleStr + "text-decoration: " + styleArray.textDecoration + ";";
        }
        styleStr = styleStr.trimEnd() + "'>";
        let isStrong = this.findParentNode(node, "STRONG") ? true : false;
        let isEm = this.findParentNode(node, "EM") ? true : false;
        let isDel = this.findParentNode(node, "DEL") ? true : false;
        if(isStrong) {
          styleStr = styleStr + "<strong>";
        }
        if(isEm) {
          styleStr = styleStr + "<em>";
        }
        if(isDel) {
          styleStr = styleStr + "<del>";
        }
        styleStr = styleStr + "\ufeff";
        if(isDel) {
          styleStr = styleStr + "</del>";
        }
        if(isEm) {
          styleStr = styleStr + "</em>";
        }
        if(isStrong) {
          styleStr = styleStr + "</strong>";
        }
        styleStr = styleStr + "</span>";
      }
      return styleStr;
    },
    // add #10839 観察記録のテキストエリアでゴミが出る linjunfeng start
    getStyleTabRootBefore(node) {
      let styleArray = this.getFontStyle(node);
      let styleStr = "";
      if(Object.keys(styleArray).length !== 0) {
        styleStr = "<p><span style='";
        if(styleArray.fontFamily && styleArray.fontFamily !== "") {
          styleStr = styleStr + "font-family: " + styleArray.fontFamily + "; ";
        }
        if(styleArray.fontSize && styleArray.fontSize !== "") {
          styleStr = styleStr + "font-size: " + styleArray.fontSize + "; ";
        }
        if(styleArray.color && styleArray.color !== "") {
          styleStr = styleStr + "color: " + styleArray.color + "; ";
        }
        if(styleArray.backgroundColor && styleArray.backgroundColor !== "") {
          styleStr = styleStr + "background-color: " + styleArray.backgroundColor + "; ";
        }
        if(styleArray.textDecoration && styleArray.textDecoration !== "") {
          styleStr = styleStr + "text-decoration: " + styleArray.textDecoration + ";";
        }
        styleStr = styleStr + "'>";
        let isStrong = this.findParentNode(node, "STRONG") ? true : false;
        let isEm = this.findParentNode(node, "EM") ? true : false;
        let isDel = this.findParentNode(node, "DEL") ? true : false;
        if(isStrong) {
          styleStr = styleStr + "<strong>";
        }
        if(isEm) {
          styleStr = styleStr + "<em>";
        }
        if(isDel) {
          styleStr = styleStr + "<del>";
        }
        styleStr = styleStr + "\ufeff";
        if(isDel) {
          styleStr = styleStr + "</del>";
        }
        if(isEm) {
          styleStr = styleStr + "</em>";
        }
        if(isStrong) {
          styleStr = styleStr + "</strong>";
        }
        styleStr = styleStr + "</span></p>";
      }
      return styleStr;
    }
    // add #10839 観察記録のテキストエリアでゴミが出る linjunfeng end
  },

  updated() {
    this.$nextTick(() => {
      const elements = document.getElementsByClassName("content-input");
      for(let i = 0; i < elements.length; i++) {
        const element = elements[i];
        element.style.height = `${element.scrollHeight - 10}px`;
      }
    });
  }
};
</script>

<style scoped>
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.vertical-div {
    display: flex;
    flex-direction: column;
    align-content: flex-start;
    font-size: 1em;
  }
  .disp-item-area {
    width: 100%;
    border-collapse: collapse;
  }*/
.vertical-div {
  display: flex;
  align-content: flex-start;
  font-size: 1em;
  border-bottom: #595959 solid 1.5px;
  align-items: center;
  padding-bottom: 10px;
}
/*.disp-item-area {*/
/*  border-collapse: collapse;*/
/*}*/
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.disp-item-area tr {
  height: 50px;
}
.disp-item-area tr th {
  text-align: left;
}
.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}
.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}
.ex-text-view-area >>> p {
  margin: 0;
}
.ex-text-view-area >>> span {
  color: var(--ntss-base-color);
}
.onscol {
  padding-top: 10px;
}
.title {
  padding: 10px;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.text-area {*/
  /*  padding: 10px;*/
  /*}*/
.text-area {
  width: 75%;
  padding: 10px;
  /*border-left: #595959 solid 1px;*/
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
/* mod FNSI-改修内容5682修正 関 start */
/* .text-area-view {
  background-color: white;
  font-size: 1.5em;
  word-break: break-all;
  display: block;
} */
.text-area-view {
  font-size: 1em;
  word-break: break-all;
  display: block;
}
/* mod FNSI-改修内容5682修正 関　end */
div >>> .content-textarea {
  width: 100%;
  font-family: inherit;
  font-size: 1em;
  height: 100px;
}
/* 取得ボタン */
.button-import {
  width: 4em;
}
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
/*.topTitle {*/
/*  white-space: nowrap;*/
/*}*/
  .changeRow {
    overflow: hidden;
    word-spacing: normal;
    word-break: break-all;
  }
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
  .text-area span{
    white-space: break-spaces;
  }
</style>
