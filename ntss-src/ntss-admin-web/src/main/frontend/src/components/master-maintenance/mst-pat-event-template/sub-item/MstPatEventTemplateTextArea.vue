<template>
  <div>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">最大文字数</td>
        <td style="width: 70px;">
          <custom-input-number
            :value="textMaxValueRecord"
            :step="1"
            :min-value="min"
            :max-value="max"
            :digits="4"
            :loop-flg="true"
            :initial-value-lock="true"
            :class="'pat-event-input textMaxValue'+propsIndex"
            :name="'textMaxValue'+propsIndex"
            @change="setTextMaxValueCss($event)"
            @blur="checkTextMaxValue($event)"
            @focus="handleFocus"
          />
        </td>
        <td class="disp-period">
          <label>文字</label>
        </td>
      </tr>
    </table>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">デフォルト値</td>
        <td v-show="isFormatting" style="width: 60%;">
          <com-textarea
            class="com-textarea"
            :content="ediText.html_value"
            :idTextarea="'editor-input-' + propsIndex"
            @set-content-data="test"
          />
          <pop-over-fixed-phrase
            v-bind="popoverData"
            :target-position-element="popoverTargetElement()"
            @popover-close="closePopover"
            @popover-return="selectPhrase"
          />
        </td>
        <td v-show="!isFormatting" style="width: 60%;">
          <com-textarea
            class="com-textarea"
            :content="ediText.default_value"
            :idTextarea="'com-textarea-dafault-' + propsIndex"
            @blur="editDefaultValue($event.target.value)"
            @set-content-data="test"
          />
        </td>
        <td></td>
      </tr>
    </table>
    <table class="disp-item-area">
      <tr>
        <td class="item-title"></td>
        <td style="width: 60%;">
          <v-ons-checkbox v-model="isFormatting" :input-id="'check-formatting-' + propsIndex" />
          <label class="item-title" :for="'check-formatting-' + propsIndex" >書式設定可能</label>
        </td>
        <td></td>
      </tr>
    </table>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">データ取得元</td>
        <td class="import-area">
          <v-ons-select v-model="selectSourceName">
            <option v-for="(item, idx) in groupSelector" :key="idx" :value="item.cd">{{ item.name }}</option>
          </v-ons-select>
          <label>&nbsp;</label>
          <v-ons-select v-model="selectSourceField">
            <option
              v-for="(item, idx) in itemSelector"
              :key="idx"
              :value="item.field"
            >{{ item.name }}</option>
          </v-ons-select>
        </td>
      </tr>
    </table>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import $$ from "@/compat/jquery";
import {replaceLtGt} from "@/utils/util.js";
import {
  mountEditor,
  getEditorWidget as getNativeEditorWidget,
  getKendoEditorToolbarClearButtons,
  getKendoEditorOwnerDocument,
  getKendoEditorDocumentElement,
  getKendoEditorBody,
  createKendoEditorRange as createKendoCompatEditorRange,
  createKendoEditorElement as createKendoCompatEditorElement
} from "@/functions/common/KendoFunctions";
import { deepCopy } from "@/functions/common/CommonFunctions";
import CommonTextArea from "@/components/common/CommonTextArea";

import { isInsideKendoEditorInteraction } from "@/functions/common/KendoFunctions";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import CustomInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import { getScopedElementsByClassName, getScopedElementsByTagName, getScopedUserAgent, getScopedWindow, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { customComparator } from "@/utils/util.js";

import MasterSelectorFixedPhrase from "@/components/common/master-selector/MasterSelectorFixedPhrase";
import { messageFormat } from "@/functions/common/MessageFormat";
import _ from "@/compat/collections/lodash";
export default {
  name: "MstPatEventTemplateTextArea",
  props: ["propsIndex"],
  components: {
    "com-textarea": CommonTextArea,
    "pop-over-fixed-phrase": MasterSelectorFixedPhrase,
    "custom-input-number": CustomInputNumber
  },
  data() {
    return {
      inputModel: {
        sql_cd: null,
        max_length: 0,
        source_field: null,
        default_value: "",
        is_formatting: "0",
        html_value: ""
      },
      ediText: {
        default_value: "",
        html_value: ""
      },
      selectSourceNameValue: null,
       // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start
      min:0,
      max:9999,
      blurFlg:false,
      focusFlg:false,
      // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end
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
        },
        // #5842 テキストエリアの不正 訾浩 end
      ],
      textMaxValueRecord: { initValue: null, editValue: null },
      copyFontSize: null,
      commentTimer: 0,
      tapedTwice: false,
      setLoopId: null,
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "right"
      }
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-pat-event-template", {
      getInitInputParams: "getInitInputParams",
      getInputParams: "getInputParams",
      getSysDataSet: "getSysDataSet"
    }),
    groupSelector() {
      const defaultSelector = { name: "未指定", cd: null };
      if (this.getSysDataSet.text.groupList) {
        return [defaultSelector].concat(
          deepCopy(this.getSysDataSet.text).groupList
        );
      } else {
        return [defaultSelector];
      }
    },
    itemSelector() {
      if (this.getSysDataSet.text.itemList) {
        return deepCopy(this.getSysDataSet.text).itemList.filter(
          item => item.group === this.selectSourceNameValue
        );
      } else {
        return [];
      }
    },
    selectSourceName: {
      get() {
        if (this.getInputParams[this.propsIndex].item_json === undefined || this.getInputParams[this.propsIndex].item_json.sql_cd === undefined) {
          return null;
        }
        const sqlCd = this.getInputParams[this.propsIndex].item_json.sql_cd;
        if (this.getSysDataSet.text.itemList) {
          const items = deepCopy(this.getSysDataSet.text).itemList.filter(
            m => m.cd === sqlCd && m.field === this.selectSourceField
          );
          if (items && items.length > 0) {
            return items[0].group;
          } else {
            return this.groupSelector.length > 0
              ? this.groupSelector[0].cd
              : null;
          }
        } else {
          return null;
        }
      },
      set(value) {
        this.selectSourceNameValue = value;
        const items = deepCopy(this.getSysDataSet.text).itemList.filter(
          item => item.group === value
        );
        if (items.length > 0) {
          this.selectSourceField = items[0].field;
        } else {
          this.selectSourceField = null;
        }
      }
    },
    selectSourceField: {
      get() {
        if (this.getInputParams[this.propsIndex].item_json === undefined || this.getInputParams[this.propsIndex].item_json.source_field === undefined) {
          return null;
        }
        return this.getInputParams[this.propsIndex].item_json.source_field;
      },
      set(value) {
        const contact = this.getInputParams[this.propsIndex].item_json;
        this.inputModel.default_value = contact.default_value;
        this.inputModel.max_length = contact.max_length;
        const item = this.itemSelector.find(m => m.field === value);
        this.inputModel.source_field = item ? item.field : null;
        this.inputModel.sql_cd = item ? item.cd : null;
        this.updateStore();
      }
    },
    textMaxValue: {
      get() {
        if (this.getInputParams[this.propsIndex].item_json === undefined || this.getInputParams[this.propsIndex].item_json.max_length === undefined) {
          return null;
        }
        return this.getInputParams[this.propsIndex].item_json.max_length;
      },
      set(value) {
        const contact = this.getInputParams[this.propsIndex].item_json;
        if (!isNaN(value)) {
          this.inputModel.max_length = value;
        } else {
          this.inputModel.max_length = 0;
        }
        this.inputModel.default_value = contact.default_value;
        this.inputModel.is_formatting = contact.is_formatting;
        this.inputModel.sql_cd = contact.sql_cd;
        this.inputModel.source_field = contact.source_field;
        this.updateStore();
      }
    },
    textDefaultValue: {
      get() {
        if (this.getInputParams[this.propsIndex].item_json === undefined || this.getInputParams[this.propsIndex].item_json.default_value === undefined) {
          return null;
        }
        return this.getInputParams[this.propsIndex].item_json.default_value;
      },
      set(value) {
        const contact = this.getInputParams[this.propsIndex].item_json;
        this.inputModel.max_length = contact.max_length;
        this.inputModel.is_formatting = contact.is_formatting;
        this.inputModel.default_value = value;
        this.inputModel.sql_cd = contact.sql_cd;
        this.inputModel.source_field = contact.source_field;
        this.updateStore();
      }
    },
    isFormatting: {
      get() {
        if (this.getInputParams[this.propsIndex].item_json === undefined || this.getInputParams[this.propsIndex].item_json.is_formatting === undefined) {
          return false;
        }
        const value = this.getInputParams[this.propsIndex].item_json
          .is_formatting;
        if (value === "1") {
          return true;
        }
        return false;
      },
      set(value) {
        const contact = this.getInputParams[this.propsIndex].item_json;
        this.inputModel.max_length = contact.max_length;
        this.inputModel.default_value = contact.default_value;
        this.inputModel.sql_cd = contact.sql_cd;
        this.inputModel.source_field = contact.source_field;
        this.inputModel.html_value = contact.html_value;
        if (value) {
          this.inputModel.is_formatting = "1";
        } else {
          this.inputModel.is_formatting = "0";
        }
        this.updateStore();
      }
    }
  },
  watch: {
    selectSourceName(value) {
      this.selectSourceNameValue = value;
    },
  },
  created() {
    //フィールド追加時にcreatedイベントが起動
    if (this.getInputParams[this.propsIndex].item_json.default_value !== undefined) {
      this.ediText.default_value = this.getInputParams[this.propsIndex].item_json.default_value
    } else {
      this.getInputParams[this.propsIndex].item_json.default_value = "";
      this.ediText.default_value = "";
    }

    //モーダルウィンドウ起動時の入力値を取得
    const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
    //最大文字数の値の設定(初期値:モーダルウィンドウ起動時の入力値、編集後の値:現在の入力値)
    if(initInputParam && initInputParam.length === 1){
      this.textMaxValueRecord.initValue = initInputParam[0].item_json.max_length;
      this.textMaxValueRecord.editValue = this.textMaxValue;
    } else {
      //最大文字数の値の設定(初期値:null、編集後の値:現在の入力値)
      if(this.textMaxValue){
        this.textMaxValueRecord.initValue = null;
        this.textMaxValueRecord.editValue = this.textMaxValue;
      } else {
        this.textMaxValueRecord.initValue = null;
        this.textMaxValueRecord.editValue = null;
      }
    }
  },
  mounted() {
    let self = this;
    this.$nextTick(() => {
      this.selectSourceNameValue = this.selectSourceName;
    });
    const tools = this.tools;
    mountEditor($$("#editor-input-" + this.propsIndex), {
      /**
       * @description テキストエリアのPasteイベント
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
      // add #9504 2023/12/06 拡張書式の動作不正 張玲 end
    });
    let editor = this.getRichTextEditor();
    let styleTabBeforeCaret = "";
    // 患者イベントテンプレートマスタに登録されたhtml_valueにタグが存在する場合
    if(this.getInputParams[this.propsIndex].item_json.html_value){
      //テキストエリアのHTMLのタグが空タグの場合、ゼロ幅スペースを設定する
      let htmlValue = this.getInputParams[this.propsIndex].item_json.html_value.replace(/(<span\b[^>]*>)(<\/span>)/gi, "$1\ufeff$2");
      htmlValue = htmlValue.replace(/(<strong\b[^>]*>)(<\/strong>)/gi, "$1\ufeff$2");
      htmlValue = htmlValue.replace(/(<em\b[^>]*>)(<\/em>)/gi, "$1\ufeff$2");
      htmlValue = htmlValue.replace(/(<del\b[^>]*>)(<\/del>)/gi, "$1\ufeff$2");
      //テキストエリア内の入力値の書式をエディタのツールバーの書式設定に適用する
      editor.exec("insertHTML", { value: htmlValue });
      this.ediText.html_value = htmlValue;
    // テキストエリアのフィールドの新規追加またはHTMLデータがブランクの場合
    } else {
      // 空タグを1行目の先頭に作成し、テキストエリア上部のツールバーの書式設定のデフォルト値(フォント名:Meiryo、フォントサイズ:14pt)を選択する
      editor.exec("fontName", { value: "Meiryo" });
      editor.exec("fontSize", { value: "14pt" });
    }
    /**
     * @description テキストエリアのフォーカスアウト発生時のイベント
     */
    const editorEventNamespace = `.ntssMstPatEventTemplateEditor${this.propsIndex}`;
    $$(editor.window).off(`blur${editorEventNamespace}`).on(`blur${editorEventNamespace}`, function (ev) {
      self.editContent(
        getKendoEditorDocumentElement(editor, ev, self.$el)?.lastElementChild
      );
      /**
       * @description テキストエリアのクリックイベント
       */
      $$(getKendoEditorOwnerDocument(editor, ev, self.$el))
        .off(`click.ntssMstPatEventTemplateEditor${self.propsIndex}`)
        .on(`click.ntssMstPatEventTemplateEditor${self.propsIndex}`, function(event) {
        if(!isInsideKendoEditorInteraction(event.target)) {
          if(editor.window.getSelection()) {
            let range = self.createEditorRange(editor, ev);
            range.selectNodeContents(self.findLastTextNode(getKendoEditorBody(editor, ev, self.$el)));
            editor.window.getSelection().removeAllRanges();
            editor.window.getSelection().addRange(range);
            editor.window.getSelection().collapseToEnd();
          }
        }
      });
      /**
       * @description カレンダーのフォーカス発生時のイベント
       */
      $$(getKendoEditorOwnerDocument(editor, ev, self.$el))
        .off(`focus.ntssMstPatEventTemplateEditor${self.propsIndex}`, ".calendar")
        .on(`focus.ntssMstPatEventTemplateEditor${self.propsIndex}`, ".calendar", function() {
        if(editor.window.getSelection()) {
          let range = self.createEditorRange(editor, ev);
          range.selectNodeContents(self.findLastTextNode(getKendoEditorBody(editor, ev, self.$el)));
          editor.window.getSelection().removeAllRanges();
          editor.window.getSelection().addRange(range);
          editor.window.getSelection().collapseToEnd();
        }
      });
    });
    /**
     * @description テキストエリアのkeydownイベント
    */
    this.addManagedEventListener(editor.window, 'keydown', (ev) => {
      if(ev.key === "Enter"){
        let beforeRange = editor.window.getSelection();
        let focusNode = beforeRange.focusNode;
        let focusOffset = beforeRange.focusOffset;
        //Enterキー押下前にカーソルの位置にフォーカス可能な要素が存在しない場合
        if(focusNode.nodeName === "BODY") {
          ev.stopPropagation();
          this.setManagedTimeout(() => {
            //Enterキー押下後にカーソルが置かれた行のHTMLデータが<p><br></p>の場合、<p>&#xFEFF</p>に置き換える
            const newChild = this.createEditorElement("p", editor, ev);
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
          this.setManagedTimeout(() => {
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
    }, true);
    /**
     * @description テキストエリアのkeydownイベント
    */
    $$(editor.window).off(`keydown${editorEventNamespace}`).on(`keydown${editorEventNamespace}`, function(ev) {
      if(ev.key === "Backspace" || ev.key === "Delete"){
        let beforeRange = editor.window.getSelection();
        let focusNode = beforeRange.focusNode;
        let focusOffset = beforeRange.focusOffset === 0 ? 0 : beforeRange.focusOffset - 1;
        if(focusNode.nodeName !== "BODY") {
          let targetLastNode = focusNode.nodeName === "#text" ? focusNode : focusNode.childNodes[focusOffset];
          let targetLastTextNode = self.findLastTextNode(targetLastNode);
          styleTabBeforeCaret = self.getStyleTabBefore(targetLastTextNode);
        }
      }
    });
    /**
     * @description テキストエリアのkeyupイベント
    */
    $$(editor.window).off(`keyup${editorEventNamespace}`).on(`keyup${editorEventNamespace}`, function(ev) {
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
    this.addManagedEventListener(editor.window, 'compositionend', (ev) => {
      ev.currentTarget.dispatchEvent(new Event('input'));
    });
    /**
     * @description テキストエリアの入力イベント発生前のイベント
    */
    this.addManagedEventListener(editor.window, 'beforeinput', (ev) => {
      if(ev.inputType === "deleteByCut"){
        let selection = editor.window.getSelection();
        const range = selection.getRangeAt(0);
        const cloneContents = range.cloneContents();
        const container = this.createEditorElement('div', editor, ev);
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
          this.setManagedTimeout(() => {
            const newChildNode = this.createEditorElement("p", editor, ev);
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
            this.setManagedTimeout(() => {
              if(currentNode.childNodes.length === 1 && currentNode.childNodes[0].nodeName === "BR"){
                currentNode.childNodes[0].remove();
              }
            }, 0);
          }
          if(selection.anchorOffset === 0){
            this.setManagedTimeout(() => {
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
    this.addManagedEventListener(editor.window, 'input', (ev) => {
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
    this.addManagedEventListener(editor.window, 'copy', (ev) => {
      self.copyFontSize = null;
      let selection = editor.window.getSelection();
      const range = selection.getRangeAt(0);
      const cloneContents = range.cloneContents();
      const container = this.createEditorElement('div', editor, ev);
      container.appendChild(cloneContents);
      if(container.querySelectorAll('span').length <= 1){
        self.copyFontSize = ev.target.style.fontSize;
      }
    });
    //書式設定可能なテキストエリア上部のツールバーのクリアボタンを取得する
    const {
      fontFamilyClearButton: editorToolbarClearFontFamily,
      fontSizeClearButton: editorToolbarClearFontSize
    } = getKendoEditorToolbarClearButtons(this.$el, "editor-input-" + this.propsIndex);
    if(editorToolbarClearFontFamily){
      /**
       * @description テキストエリア上部のツールバーのフォント名のクリアボタンのクリックイベント
       */
      this.addManagedEventListener(editorToolbarClearFontFamily, 'click', (ev) => {
        ev.currentTarget.previousElementSibling.value = "(デフォルト)";
        //フォント名のドロップダウンリストのクリックイベントを呼び出す
        ev.currentTarget.previousElementSibling.focus();
        ev.currentTarget.previousElementSibling.dispatchEvent(new Event('click'));
        editor.exec("fontName", { value: "inherit" });

        //子コンポーネントのクリアボタンのクリックイベントをキャンセルする
        ev.stopPropagation();
      }, true);
    }
    if(editorToolbarClearFontSize){
      /**
       * @description テキストエリア上部のツールバーのフォントサイズのクリアボタンのクリックイベント
       */
      this.addManagedEventListener(editorToolbarClearFontSize, 'click', (ev) => {
        ev.currentTarget.previousElementSibling.value = "(デフォルト)";
        ev.currentTarget.previousElementSibling.focus();
        ev.currentTarget.previousElementSibling.dispatchEvent(new Event('click'));
        editor.exec("fontSize", { value: "inherit" });
        //子コンポーネントのクリアボタンのクリックイベントをキャンセルする
        ev.stopPropagation();
      }, true);
    }
    const ownerWindow = this.getOwnerWindow();
    ownerWindow.checkCommentLongPress = this.checkCommentLongPress.bind(this);
    ownerWindow.onDblTap = this.onDblTap.bind(this);
    ownerWindow.endLongTouch = this.endLongTouch.bind(this);
    ownerWindow.showPopover1 = this.showPopover1.bind(this);
    ownerWindow.clearInterval(this.setLoopId);
    this.setLoopId = ownerWindow.setInterval(() => {
      const iframe = this.getEditorIframes();
      if (iframe.length > 0 && iframe[0]?.contentDocument) {
        this.bindEditorPopoverInteractionEvents(iframe[0].contentDocument, ownerWindow);
        ownerWindow.clearInterval(this.setLoopId);
      }
    });
  },
  unmounted() {
    const ownerWindow = this.getOwnerWindow();
    ownerWindow.clearInterval(this.setLoopId);
    this.clearManagedRuntimeHandlers();
    const editor = this.getRichTextEditor();
    $$(editor?.window || []).off(`.ntssMstPatEventTemplateEditor${this.propsIndex}`);
    const ownerDocument = this.getEditorOwnerDocument(this.getRichTextEditor());
    $$(ownerDocument).off(`.ntssMstPatEventTemplateEditor${this.propsIndex}`);
    ownerWindow.checkCommentLongPress = null;
    ownerWindow.onDblTap = null;
    ownerWindow.endLongTouch = null;
    ownerWindow.showPopover1 = null;
  },
  methods: {
    clearManagedRuntimeHandlers() {
      if (Array.isArray(this._managedEventDisposers)) {
        while (this._managedEventDisposers.length) {
          try {
            this._managedEventDisposers.pop()?.();
          } catch (_error) {
            // noop
          }
        }
      }
      if (Array.isArray(this._managedTimeouts)) {
        const ownerWindow = this.getOwnerWindow();
        this._managedTimeouts.forEach((timerId) => ownerWindow.clearTimeout?.(timerId));
        this._managedTimeouts = [];
      }
    },
    addManagedEventListener(target, eventName, handler, options) {
      if (!target?.addEventListener || typeof handler !== "function") {
        return handler;
      }
      this._managedEventDisposers = this._managedEventDisposers || [];
      target.addEventListener(eventName, handler, options);
      this._managedEventDisposers.push(() => target.removeEventListener?.(eventName, handler, options));
      return handler;
    },
    setManagedTimeout(handler, delay = 0) {
      const ownerWindow = this.getOwnerWindow();
      this._managedTimeouts = this._managedTimeouts || [];
      const timerId = ownerWindow.setTimeout?.(() => {
        this._managedTimeouts = (this._managedTimeouts || []).filter((id) => id !== timerId);
        handler?.();
      }, delay);
      if (timerId !== undefined && timerId !== null) {
        this._managedTimeouts.push(timerId);
      }
      return timerId;
    },
    getOwnerWindow() {
      return getScopedWindow(this.$el || this) || window;
    },
    getOwnerSessionStorage() {
      return this.getOwnerWindow()?.sessionStorage || globalThis?.sessionStorage || null;
    },
    getEditorOwnerDocument(editor = null, event = null) {
      return getKendoEditorOwnerDocument(editor, event, this.$el);
    },
    createEditorRange(editor = null, event = null) {
      return createKendoCompatEditorRange(editor, event, this.$el);
    },
    createEditorElement(tagName, editor = null, event = null) {
      return createKendoCompatEditorElement(tagName, editor, event, this.$el);
    },
    createEditorTextNode(text, node = null) {
      const ownerDocument = node?.ownerDocument || this.getEditorOwnerDocument(this.getRichTextEditor());
      return ownerDocument.createTextNode(text);
    },
    getEditorIframes() {
      return getScopedElementsByTagName("iframe", this.$el || null);
    },
    getTemplateElementsByClassName(className) {
      return getScopedElementsByClassName(className, this.$el || this);
    },
    queryTemplateSelector(selector) {
      return queryScopedSelector(selector, this.$el || this);
    },
    queryTemplateSelectorAll(selector) {
      return queryScopedSelectorAll(selector, this.$el || this);
    },
    requestViewForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    getRichTextEditor(targetIndex = this.propsIndex) {
      return getNativeEditorWidget($$("#editor-input-" + targetIndex));
    },
    bindEditorPopoverInteractionEvents(iframeDocument, ownerWindow) {
      if (!iframeDocument || !ownerWindow) {
        return;
      }
      const targetId = String(this.propsIndex);
      const componentEl = this.$el;
      iframeDocument.id = targetId;
      const storeTargetIndex = () => {
        ownerWindow.sessionStorage?.setItem("currentTargetIndex", targetId);
      };
      iframeDocument.onmousedown = function() {
        ownerWindow.checkCommentLongPress(1);
        storeTargetIndex();
      };
      iframeDocument.onmouseup = function() {
        ownerWindow.checkCommentLongPress(0);
      };
      iframeDocument.onmousemove = function() {
        ownerWindow.checkCommentLongPress(0);
      };
      iframeDocument.onmouseout = function() {
        ownerWindow.checkCommentLongPress(0);
      };
      iframeDocument.ondblclick = function() {
        const ua = getScopedUserAgent(iframeDocument?.documentElement || componentEl);
        if (ua.match(/Android/) || ua.match(/iPhone|iPad/)) {
          return;
        }
        storeTargetIndex();
        ownerWindow.showPopover1();
      };
      this.addManagedEventListener(iframeDocument, 'touchstart', (ev) => {
        storeTargetIndex();
        ownerWindow.onDblTap(ev);
      }, { passive: false });
      this.addManagedEventListener(iframeDocument, 'touchend', ownerWindow.endLongTouch);
    },

    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-pat-event-template", [
      "setInputParams",
      "setInputParamsUpdate"
    ]),
    limitText(){
      let value = $$(this.getRichTextEditor())[0].body;
      let editorValue = value.innerHTML;
      let text = value.innerText.replace(/\n\n/g, '\n');
      // &#xFEFFを除く
      if (text.indexOf('\ufeff') !== -1) {
        text = text.replace(/\ufeff/g, '');
      }

      if (text.length > parseInt(this.textMaxValue)) {
        let delStr = text.slice(parseInt(this.textMaxValue), text.length);
        let delLength = delStr.length - 1;

        let delIndex = [];
        let isHtml = true;
        for (let i = editorValue.length - 1; i >= 0; i--) {
          if (delLength >= 0) {
            let s = editorValue.charAt(i)

            // HTMLのタグだったら無視にする
            if (">" === s) {
              isHtml = false;
            }
            if ("<" === s) {
              let sec = editorValue.charAt(i + 1);
              if (sec === "s" || sec === "e" || sec === "d" || sec === "/") {
                isHtml = true;
              }
            }

            // 内容だったら処理する
            if (isHtml) {
              if(delStr.charAt(delLength) === '\n')
              {
                // 改行文字だったら-1を除くリストに追加する
                delLength --;
                delIndex.push(-1);
              }
              else if (s === delStr.charAt(delLength))
              {
                // 改行文字ではなかったら削除位置を除くリストに追加する
                delLength --;
                delIndex.push(i);
              }
            }
          }
        }
        delIndex.forEach((e, i) => {
          if(e != -1)
          {
            // 改行文字ではない時
            if(i === delIndex.length - 1)
            {
              // 最後の文字だったら行を残らせるように&#xFEFFを追加する
              editorValue = editorValue.substr(0, e) + "&#xFEFF;" + editorValue.substr(e + 1,editorValue.length - 1);
            }
            else
            {
              // 最後の文字ではなかったら文字を除くだけ
              editorValue = editorValue.substr(0, e) + editorValue.substr(e + 1,editorValue.length - 1)
            }
          }
          else
          {
            // 改行文字
            if(editorValue.charAt(editorValue.length - 1) === '>')
            {
              // タグだったら<p>を除く
              let pElements = value.getElementsByTagName('p');
              if (pElements.length > 0) {
                let pElement = pElements[pElements.length - 1];
                pElement.remove();
              }
            }
            else
            {
              // タグではなかったら最後の文字を除く（最後の文字は&#xFEFF;はずです）
              editorValue = editorValue.substr(0, editorValue.length - 2);
            }
          }
        });
        this.ediText.default_value = text;
      }
      this.inputModel.default_value = text;
      this.inputModel.html_value = editorValue;
      this.updateStore();
    },
    editContent(value) {
      // 通常のテキストエリアに反映する
      this.ediText.default_value = "";
      let defaultValue = value.innerText.replace(/\n\n/g, '\n');
      defaultValue = defaultValue.replace(/\ufeff/g, '');
      this.$nextTick(() => {
        this.ediText.default_value = defaultValue;
      });

      // ストアーに保存する
      const contact = this.getInputParams[this.propsIndex].item_json;
      this.inputModel.max_length = contact.max_length;
      this.inputModel.is_formatting = contact.is_formatting;
      this.inputModel.default_value = defaultValue;
      this.inputModel.sql_cd = contact.sql_cd;
      this.inputModel.source_field = contact.source_field;
      this.inputModel.html_value = value.innerHTML;
      this.updateStore();

      this.limitText();
      
      //モーダルウィンドウ起動時の入力値を取得
      const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
      const initItemJson = initInputParam?.[0]?.item_json;
      let initDefaultValue = null;
      let initHtmlValue = null;
      if(initItemJson){
        //デフォルト値(プロパティ名:default_value)の取得
        initDefaultValue = initItemJson.default_value;
        //デフォルト値(プロパティ名:html_value)の取得
        initHtmlValue = initItemJson.html_value.replace(/\ufeff/g, '');
      }
      let currentHtmlValue = this.inputModel.html_value.replace(/\ufeff/g, '');
      //ゼロ幅スペースを除くHTMLデータが一致する場合
      if(initItemJson && initDefaultValue === this.inputModel.default_value && initHtmlValue === currentHtmlValue){
        //デフォルト値(プロパティ名:html_value)の値を初期値に更新する
        this.inputModel.html_value = initItemJson.html_value;
        this.updateStore();
      }
      //デフォルト値(プロパティ名:default_value)に変化なし、かつ、デフォルト値(プロパティ名:html_value)に変化あり(桁数に変化なし、値に変化あり)の場合
      if(initItemJson && initDefaultValue === this.inputModel.default_value && initHtmlValue.length === currentHtmlValue.length
      && initHtmlValue !== currentHtmlValue){
        let initHtmlTagList = [];
        let currentHtmlTagList = [];
        //HTMLのタグの種類(スタイルが指定されていないタグも含む)
        const patterns = [
          /<p\b[^>]*>[\s\S]*?<\/p>/gi,
          /<span\b[^>]*>[\s\S]*?<\/span>/gi,
          /<strong>[\s\S]*?<\/strong>/gi,
          /<em>[\s\S]*?<\/em>/gi,
          /<del>[\s\S]*?<\/del>/gi
        ];
        //HTMLのタグ(初期値、現在の入力値)の情報を取得する
        patterns.forEach(regex => {
          let match = null;
          while ((match = regex.exec(initHtmlValue)) !== null) {
            let startTagEndIndex = -1;
            if(match[0].indexOf(">") >= 0){
              startTagEndIndex = match.index + match[0].indexOf(">");
            }
            initHtmlTagList.push({
              htmlTagType:regex,
              tagStartIndex: match.index,
              startTagEndIndex: startTagEndIndex,
              htmlTagData: match[0]
            });
          }
          while ((match = regex.exec(currentHtmlValue)) !== null) {
            let startTagEndIndex = -1;
            if(match[0].indexOf(">") >= 0){
              startTagEndIndex = match.index + match[0].indexOf(">");
            }
            currentHtmlTagList.push({
              htmlTagType:regex,
              tagStartIndex: match.index,
              startTagEndIndex: startTagEndIndex,
              htmlTagData: match[0]
            });
          }
        })
        //HTMLのタグの個数が一致する場合
        if(initHtmlTagList.length === currentHtmlTagList.length){
          let isEqual = true;
          for(const [index,initHtmlTag] of initHtmlTagList.entries()) {
            //タグの種類、タグの開始位置、開始タグの終了位置、タグの桁数のいずれかが異なる場合
            if(initHtmlTag.htmlTagType !== currentHtmlTagList[index].htmlTagType
            || initHtmlTag.tagStartIndex !== currentHtmlTagList[index].tagStartIndex
            || initHtmlTag.startTagEndIndex !== currentHtmlTagList[index].startTagEndIndex
            || initHtmlTag.htmlTagData.length !== currentHtmlTagList[index].htmlTagData.length){
              isEqual = false;
              break;
            }
            //HTMLのタグが一致する場合
            if(initHtmlTag.htmlTagData === currentHtmlTagList[index].htmlTagData){
              continue;
            }
            //style属性のスタイルの種類
            let styleList = ["font-family","font-size","background-color","color","text-decoration: underline","white-space: break-spaces","white-space-collapse: break-spaces"];
            let initHtmlStyleList = [];
            let currentHtmlStyleList = [];
            //HTMLの開始タグ(初期値)の取得
            let initHtmlStartTag = initHtmlValue.substring(initHtmlTag.tagStartIndex,initHtmlTag.startTagEndIndex + 1);
            //HTMLの開始タグ(現在の入力値)の取得
            let currentHtmlStartTag = currentHtmlValue.substring(currentHtmlTagList[index].tagStartIndex,currentHtmlTagList[index].startTagEndIndex + 1);
            //HTMLの開始タグが一致する場合
            if(initHtmlStartTag === currentHtmlStartTag){
              continue;
            }
            //HTMLの各タグに指定されたスタイルの種類の取得
            styleList.forEach(style => {
              let initHtmlStyleStartIndex = initHtmlStartTag.indexOf(style);
              let initHtmlStyleData = "";
              if(initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex) >= 0){
                let initHtmlStyleEndIndex = initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex);
                initHtmlStyleData = initHtmlStartTag.substring(initHtmlStyleStartIndex,initHtmlStyleEndIndex + 1);
              }
              //タグに指定されたスタイル(初期値)の情報の取得
              if(style !== "color" && initHtmlStyleStartIndex >= 0) {
                initHtmlStyleList.push({
                  style:style,
                  styleStartIndex:initHtmlTag.tagStartIndex + initHtmlStyleStartIndex,
                  styleData:initHtmlStyleData
                });
              }else if(style === "color" && initHtmlStyleStartIndex >= 0){
                let backgroundColorStyle = initHtmlStyleList.filter(initHtmlStyle => initHtmlStyle.style == "background-color");
                if(backgroundColorStyle && backgroundColorStyle[0].styleStartIndex + backgroundColorStyle[0].style.indexOf("color") !== initHtmlTag.tagStartIndex + initHtmlStyleStartIndex){
                  initHtmlStyleList.push({
                    style:style,
                    styleStartIndex:initHtmlTag.tagStartIndex + initHtmlStyleStartIndex,
                    styleData:initHtmlStyleData
                  });
                }else {
                  initHtmlStyleStartIndex = initHtmlStartTag.indexOf(style,initHtmlStyleStartIndex + 1);
                  initHtmlStyleData = "";
                  if(initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex) >= 0){
                    let initHtmlStyleEndIndex = initHtmlStartTag.indexOf(";",initHtmlStyleStartIndex);
                    initHtmlStyleData = initHtmlStartTag.substring(initHtmlStyleStartIndex,initHtmlStyleEndIndex + 1);
                  }
                  if(initHtmlStyleStartIndex >= 0){
                    initHtmlStyleList.push({
                      style:style,
                      styleStartIndex:initHtmlTag.tagStartIndex + initHtmlStyleStartIndex,
                      styleData:initHtmlStyleData
                    });
                  }
                }
              }
              //タグに指定されたスタイル(現在の入力値)の情報の取得
              let currentHtmlStyleStartIndex = currentHtmlStartTag.indexOf(style);
              let currentHtmlStyleData = "";
              if(currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex) >= 0){
                let currentHtmlStyleEndIndex = currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex);
                currentHtmlStyleData = currentHtmlStartTag.substring(currentHtmlStyleStartIndex,currentHtmlStyleEndIndex + 1);
              }
              if(style !== "color" && currentHtmlStyleStartIndex >= 0) {
                currentHtmlStyleList.push({
                  style:style,
                  styleStartIndex:currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex,
                  styleData:currentHtmlStyleData
                });
              }else if(style === "color" && currentHtmlStyleStartIndex >= 0){
                let backgroundColorStyle = currentHtmlStyleList.filter(currentHtmlStyle => currentHtmlStyle.style == "background-color");
                if(backgroundColorStyle && backgroundColorStyle[0].styleStartIndex + backgroundColorStyle[0].style.indexOf("color") !== currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex){
                  currentHtmlStyleList.push({
                    style:style,
                    styleStartIndex:currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex,
                    styleData:currentHtmlStyleData
                  });
                }else {
                  currentHtmlStyleStartIndex = currentHtmlStartTag.indexOf(style,currentHtmlStyleStartIndex + 1);
                  currentHtmlStyleData = "";
                  if(currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex) >= 0){
                    let currentHtmlStyleEndIndex = currentHtmlStartTag.indexOf(";",currentHtmlStyleStartIndex);
                    currentHtmlStyleData = currentHtmlStartTag.substring(currentHtmlStyleStartIndex,currentHtmlStyleEndIndex + 1);
                  }
                  if(currentHtmlStyleStartIndex >= 0){
                    currentHtmlStyleList.push({
                      style:style,
                      styleStartIndex:currentHtmlTagList[index].tagStartIndex + currentHtmlStyleStartIndex,
                      styleData:currentHtmlStyleData
                    });
                  }
                }
              }
            });
            //ソートされたスタイル(初期値)の情報の取得
            let sortedInitHtmlStyleList = initHtmlStyleList.map(({style,styleData}) => ({style,styleData})).sort((a, b) => a.style - b.style);
            //ソートされたスタイル(現在の入力値)の情報の取得
            let sortedCurrentHtmlStyleList = currentHtmlStyleList.map(({style,styleData}) => ({style,styleData})).sort((a, b) => a.style - b.style);
            //ソートされたスタイル(初期値)とソートされたスタイル(現在の入力値)が一致しない場合
            if(!_.isEqualWith(sortedInitHtmlStyleList,sortedCurrentHtmlStyleList,customComparator)){
              isEqual = false;
              break;
            }
          }
          //ソートされたスタイル(初期値)とソートされたスタイル(現在の入力値)が一致する場合
          if(isEqual){
            //デフォルト値(プロパティ名:html_value)の値を初期値に更新する
            this.inputModel.html_value = initItemJson.html_value;
            this.updateStore();
          }
        }
      }
    },
    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
     //[確認]ボタンの状態の変更をトリガーします
     this.changeButton();
    },
    updateStore() {
      const item = JSON.stringify(this.inputModel);
      this.setInputParamsUpdate({
        item: item,
        index: this.propsIndex
      });
      const inputParams = this.getInputParams;
      this.updateEditRecord("inputParams", JSON.stringify(inputParams));
    },
    checkTextMaxValue(event) {
      let value = event.target.value;
      this.textDefaultValue  = this.textDefaultValue ? this.textDefaultValue.toString().substring(0,value) : null;
      this.focusFlg=false;
      this.limitText();
      this.requestViewForceUpdate();
    },
    setTextMaxValueCss(e) {
      if(e.target.value && this.getTemplateElementsByClassName(e.target.name)[0])
      this.getTemplateElementsByClassName(e.target.name)[0].classList.remove("input-invalid");
      this.textMaxValue = e.target.value;
      this.textMaxValueRecord.editValue = this.textMaxValue;
    },
    onMouseWheel(e){
      if (!this.focusFlg) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      e.target.value = value;
      if (value > this.max) {
        e.target.value = this.min;
      }
      if(value < this.min) {
        e.target.value = this.max;
      }
      this.textMaxValue = e.target.value;
    },
    handleFocus(){
      this.focusFlg=true;
    },
    // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end
    /**
     *
     */
    validateData() {
      let fieldNameValid = true;
      const contact = this.getInputParams[this.propsIndex].item_json;
      if (contact.default_value === undefined) {
        this.inputModel.default_value = "";
      } else {
        this.inputModel.default_value = contact.default_value;
      }
      if (contact.is_formatting === undefined) {
        this.inputModel.is_formatting = "0";
      } else {
        this.inputModel.is_formatting = contact.is_formatting;
      }
      if (contact.max_length === undefined) {
        this.inputModel.max_length = 0;
      } else {
        this.inputModel.max_length = contact.max_length;
      }
      if (contact.html_value === undefined) {
        this.inputModel.html_value = "";
      } else {
        this.inputModel.html_value = contact.html_value;
      }
      if (contact.sql_cd === undefined) {
        this.inputModel.sql_cd = "";
      } else {
        this.inputModel.sql_cd = contact.sql_cd;
      }
      if (contact.source_field === undefined) {
        this.inputModel.source_field = 0;
      } else {
        this.inputModel.source_field = contact.source_field;
      }
      this.updateStore();

      const formatClass = this.getInputParams[this.propsIndex].format_class;
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      return {
        formatClassValid: 0 <= formatClass,
        fieldNameValid: fieldNameValid
      };
    },
    /**
     *
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      if(!validationResult.fieldNameValid) {
        this.getTemplateElementsByClassName("required"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "テキストエリアのチェックエラー";
      const title = DIALOG_MESSAGES['00200138'].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.formatClassValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "形式名を選択する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200078'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.fieldNameValid
             // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "フィールド名を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200138'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
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

    test(){
      return this.ediText;
    },
    editDefaultValue(newValue){
      // &#xFEFFを除く
      if (newValue.indexOf('\ufeff') !== -1) {
        newValue = newValue.replace(/\ufeff/g, '');
      }

      // 最大文字になったら短くする
      if (newValue.length > parseInt(this.textMaxValue))
      {
        newValue = newValue.slice(0, this.textMaxValue);
      }

      // 書式のテキストエリアに反映する
      // let h = $$(this.getRichTextEditor())[0].body;
      let editorValue;
      editorValue = "<p>" + newValue.replace(/\n/g, "</p><p>") + "</p>"; // 改行文字は<p>に変換する
      editorValue = editorValue.replace(/<p><\/p>/g, "<p>&#xFEFF;</p>"); // 文字がない行は&#xFEFFで埋める
      this.getRichTextEditor().value(editorValue);
      // 通常のテキストエリアに反映する
      if (this.ediText.default_value !== newValue) {
        this.ediText.default_value = "";
        this.$nextTick(() => {
          this.ediText.default_value = newValue;
        });
      }

      // ストアーに保存する
      const contact = this.getInputParams[this.propsIndex].item_json;
      this.inputModel.max_length = contact.max_length;
      this.inputModel.is_formatting = contact.is_formatting;
      this.inputModel.default_value = newValue;
      this.inputModel.sql_cd = contact.sql_cd;
      this.inputModel.source_field = contact.source_field;
      this.inputModel.html_value = editorValue;
      this.updateStore();
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
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
      let newTextNode = this.createEditorTextNode(remeiningText, node);
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
      this.getOwnerSessionStorage()?.removeItem("currentTargetIndex");
      this.popoverData.popoverVisible = false;
    },
    /**
     * 定型文モーダルウィンドウでOKボタン押下時の選択項目の取得
     */
    selectPhrase(data) {
      //処理対象のテキストエリアフィールドのインデックスを取得する
      let currentTargetIndex = this.getOwnerSessionStorage()?.getItem("currentTargetIndex");
      let editor = this.getRichTextEditor(currentTargetIndex);
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
      let currentTargetIndex = this.getOwnerSessionStorage()?.getItem("currentTargetIndex");
      let editor = $$("#editor-input-" + currentTargetIndex);
      if (editor.length > 0) {
        return editor[0].previousSibling;
      }
    },
    /**
     * マウスボタンの長押しの判定処理
     */
    checkCommentLongPress(isMouseDown) {
      const ownerWindow = this.getOwnerWindow();
      if (isMouseDown) {
        this.commentTimer = this.setManagedTimeout(() => {
          ownerWindow.showPopover1();
        }, 500);
      } else {
        clearTimeout(this.commentTimer);
      }
    },
    /**
     * ダブルタップした際に発生するイベント
     */
    onDblTap(event) {
      const ownerWindow = this.getOwnerWindow();
      if (event.touches.length > 1) {
        // 2本以上同時にタップされた場合の処理(長押し処理を発火)
        ownerWindow.setShowPopover = this.setManagedTimeout(() => {
          ownerWindow.showPopover1();
        }, 500);
      }
      if(!this.tapedTwice) {
        this.tapedTwice = true;
        this.setManagedTimeout(() => { this.tapedTwice = false; }, 300);
        return false;
      }
      event.preventDefault();
      ownerWindow.showPopover1();
    },
    /**
     * タップが終了した際に発生するイベント
     */
    endLongTouch(event) {
      if (event.touches.length < 1) {
        // 全ての指が離れたら長押し処理を解除
        this.getOwnerWindow().clearTimeout(this.getOwnerWindow().setShowPopover);
      }
    }
  }
};
</script>

<style scoped>
.disp-period {
  vertical-align: middle;
}

.disp-item-area {
  width: 100%;
  border-collapse: collapse;
}

.disp-item-area tr {
  height: 2em;
}

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}
.input-required :deep(input){
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input){
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}

.pat-event-input {
  width: 100%;
}

.item-title {
  padding-left: 5px;
  width: 12em;
}

.item-label {
  white-space: nowrap;
}

.com-textarea {
  width: 94.6%;
  position: relative;
  box-sizing: border-box;
  overflow-y: hidden;
}
</style>
