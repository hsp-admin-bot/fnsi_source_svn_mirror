<template>
  <div class="main-contain custom-main-contain">
    <div class="input-url">
      <label class="no-flex-shrink">URL:</label>
      <com-textarea
        ref="urlComTextarea"
        :class="comTextareaClassList"
        :content="strUrl"
        idTextarea="textarea-url"
        defaultHeight="36px"
        cssClass="resize-fit-content textarea-custom-text-font textarea-resize-vertical"
        @input="resetCss"
        @set-content-data="setContentDataForURL"
        @blur="commitText"
      />
      <button
        class="k-button k-button-icontext btn3-normal no-flex-shrink"
        :disabled="isUrlInvalid"
        @click="showPopover"
      >テスト</button>
    </div>
    <div class="error-msg" v-if="urlErrorShown">URLの入力形式に誤りがあります。</div>
    <div class="d-flex flex-wrap">
      <div class="param-contain enable-flex-grow">
        <label>パラメータ:</label>
        <div :class="wrapperClassList">
          <template v-for="item in parameters">
            <button
              :key="item.name"
              class="k-button k-button-icontext params btn3-normal"
              @click="addParams(item.text)"
            >{{ item.name }}</button>
          </template>
        </div>
      </div>

      <div class="param-contain">
        <label>アイコン:</label>
        <div class="d-flex flex-wrap distance-column">
          <canvas
            id="canvas-icon-footer"
            ref="canvasIcon"
            class="style-icon-canvas distance-items"
            width="100px"
            height="100px"
          />
          <div class="d-flex distance-items">
            <input
              id="input-icon-text"
              class="ntss-text-icon"
              maxlength="4"
              v-model="textIcon"
            >
            <input
              type="color"
              id="input-icon-color"
              class="style-color-picker"
              v-model="colorTextIcon"
            >
          </div>
        </div>
        <div class="distance-column">
          <v-ons-button
            class="toolbar-btn button ntss-button-url-icon btn3-normal"
            @click="selectImage"
          >参照</v-ons-button>
          <input
            type="file"
            id="input-file"
            ref="inputFile"
            class="hide-select-file"
            multiple
            accept="image/*"
            @change="changeImage"
          >
        </div>
      </div>
    </div>
    <v-ons-popover
      cancelable
      :direction="popoverDirection"
      :cover-target="false"
      :target="popoverTarget"
      :visible.sync="isDisplay"
      :class="popoverClassList"
    >
      <div class="popover-content">
        <custom-textarea
          ref="urlTestComTextarea"
          id="textarea-url-cp"
          :value="strUrlcp"
          rows="5"
          readonly
          class="com-textare-url-cp textarea-custom-text-font textarea-resize-vertical"
        />
        <div class="footer">
          <v-ons-button
            class="clear-button common-style-cancel-button button btn2-cancel"
            @click="isDisplay = false"
          >キャンセル</v-ons-button>
          <v-ons-button
            class="button btn-ok btn1-execute"
            @click="testUrl"
          >OK</v-ons-button>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { mapGetters, mapActions } from "vuex";
import CommonTextArea from "@/components/common/CommonTextArea";
import CustomTextarea from "@/components/common/custom-form-tags/CustomTextarea";
import {EventBus} from "@/eventBus";
import { UrlLinkParameters, replacePrameters, openUrlLinkTest } from '@/functions/UrlLinkFunctions';
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { MST_DEFAULT_VALUE } from "@/constants/masterDefineDetail";

const DefaultValues = JSON.parse(JSON.stringify(MST_DEFAULT_VALUE.mst_url_link_register.urlInfo));

const UrlPattern = /^(ftp|http|https):\/\/./;
const isUrl = (str) => UrlPattern.test(str);

export default {
  mixins: [MasterMaintenanceMixin],
  components: {
    "com-textarea": CommonTextArea,
    "custom-textarea": CustomTextarea,
  },
  data() {
    return {
      strUrl: DefaultValues.text,
      imageIcon: DefaultValues.image,
      textIcon: DefaultValues.textIcon,
      colorTextIcon: DefaultValues.textColor,
      isInputInvalid: false,
      urlErrorShown: false,
      popoverTarget: null,
      popoverDirection: "down",
      isDisplay: false,
      strUrlcp: {
        initValue: "",
        editValue: "",
      },
      initialValues: { ...DefaultValues },
      editRecordUrlInfo: { ...DefaultValues },
    };
  },
  computed: {
    ...mapGetters("master-maintenance", ["getEditRecord"]),
    ...mapGetters("account-edit", ["getTheme"]),
    comTextareaClassList() {
      const classList = ["comTextarea", "input-required", "enable-flex-grow"];
      if (this.isInputInvalid) {
        classList.push("input-invalid");
      }
      return classList;
    },
    wrapperClassList() {
      const classList = ["wrapper"];
      if (this.getTheme === 1) {
        classList.push("wasd");
      }
      return classList;
    },
    popoverClassList() {
      return [this.fontSizeSet, "test-url-popover", "popover-style"];
    },
    parameters() {
      return UrlLinkParameters;
    },
    isUrlInvalid() {
      return !isUrl(this.strUrl);
    },
  },
  created() {
    if (this.getEditRecord.urlInfo && this.getEditRecord.urlInfo !== "{}") {
      const urlData = JSON.parse(this.getEditRecord.urlInfo);
      this.strUrlcp.initValue = this.strUrlcp.editValue
        = this.strUrl = this.initialValues.text = urlData.text;
      this.initialValues.function_icon = urlData.function_icon;
      this.imageIcon = this.initialValues.image = urlData.image;
      this.textIcon = this.initialValues.textIcon = urlData.textIcon;
      this.colorTextIcon = this.initialValues.textColor = urlData.textColor;
      this.editRecordUrlInfo = { ...this.initialValues };
    }
  },
  mounted() {
    this.previewImages();
    this.emitNotChangedState(true);
  },
  watch: {
    textIcon() {
      this.updateImage();
    },
    colorTextIcon() {
      this.updateImage();
    },
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),

    // 未編集状態を送信する
    // （確定ボタンのdisabled状態や破棄確認の有無に反映される）
    emitNotChangedState(state) {
      EventBus.$emit("mstHolidayRegistered", state);
    },

    addParams(key) {
      const textarea = this.$refs.urlComTextarea.$el.querySelector("#textarea-url");
      const cursorPosition = textarea.selectionStart;
      this.strUrl = this.strUrl.slice(0, cursorPosition) + key + this.strUrl.slice(cursorPosition);
      this.commitText();
      // value の変更によって selectionStart がゼロに変化するのを待ってから設定しなおす
      setTimeout(() => {
        textarea.selectionEnd = textarea.selectionStart = cursorPosition + key.length;
      }, 0);
    },
    commitText() {
      this.strUrl = this.strUrl.trim();
      this.urlErrorShown = this.strUrl.length > 0 && this.isUrlInvalid;
      this.setEditRecordUrlInfo();
    },
    setEditRecordUrlInfo() {
      const urlInfoObj = this.editRecordUrlInfo = {
        text: this.strUrl,
        function_icon: this.$refs.canvasIcon.toDataURL(),
        image: this.imageIcon,
        textIcon: this.textIcon,
        textColor: this.colorTextIcon
      };
      this.emitNotChangedState(Object.keys(urlInfoObj).every(
        key => urlInfoObj[key] === this.initialValues[key]
      ));
      this.setEditRecord({
        ...this.getEditRecord,
        urlInfo: JSON.stringify(urlInfoObj),
      });
    },
    resetCss() {
      if (this.isInputInvalid) {
        this.isInputInvalid = false;
      }
    },
    async showPopover(event) {
      this.strUrlcp.initValue = this.strUrlcp.editValue = await replacePrameters(this.strUrl);
      this.popoverTarget = event;
      this.isDisplay = true;
      await this.resizeTextarea();
    },
    testUrl() {
      openUrlLinkTest(this.strUrlcp.initValue);
      this.isDisplay = false;
    },
    /**
     * 入力チェック
     */
    validateData() {
      const isUrlEmpty = this.strUrl.length === 0;
      const hasUrl = !isUrlEmpty; // URLが入力されているか
      return {
        urlRequiredValid: !(this.isUrlInvalid && isUrlEmpty), // URL必須入力チェック
        urlFormatValid: !(this.isUrlInvalid && hasUrl), // URL形式チェック
        iconValid: this.imageIcon !== "" || this.textIcon !== "", // アイコン画像、アイコン内文字列：いずれか必須 
      };
    },
    validateOnRegistration() {
      if (this.isUrlInvalid) {
        this.isInputInvalid = true; // エラー時に背景色を赤にするためのフラグON
      }
      
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        // 全てチェックOK
        return true;
      }
      
      const message = `
          ${
            !validationResult.urlRequiredValid
              ? messageFormat(DIALOG_MESSAGES["00200158"].message)
              : ""
          }
          ${
            !validationResult.urlFormatValid
              ? messageFormat(DIALOG_MESSAGES["00200092"].message)
              : ""
          }
          ${
            !validationResult.iconValid
              ? messageFormat(DIALOG_MESSAGES["00200162"].message, "アイコン画像またはアイコン文字列", "画像または文字")
              : ""
          }
        `;
        
      let title = "";
      if (!validationResult.urlFormatValid && (!validationResult.urlRequiredValid || !validationResult.iconValid)) {
        title = "チェックエラー";
      } else if (!validationResult.urlRequiredValid || !validationResult.iconValid) {
        title = DIALOG_MESSAGES["00200162"].title;
      } else if (!validationResult.urlFormatValid) {
        title = DIALOG_MESSAGES["00200092"].title;
      }
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },

    async previewImages(isUploadImage) {
      const canvas = this.$refs.canvasIcon;
      const context = canvas.getContext("2d");
      const canvasWidth = canvas.width;
      const canvasHeight = canvas.height;
      context.clearRect(0, 0, canvas.width, canvas.height);
      context.beginPath();

      if (isUploadImage) {
        this.imageIcon = canvas.src;
      }
          
      // 画像エリア（上半分）
      const imageAreaHeight = canvasHeight / 2;
      
      if (this.imageIcon.length > 0) {
        // アイコン画像を描画
        await new Promise((resolve) => {
          const imageObj = new Image();
          imageObj.crossOrigin = "Anonymous";
          imageObj.onload = () => {
            
            // 元の画像のアスペクト比を維持しながらエリア内に収めるため調整
            const imageAspectRatio = imageObj.width / imageObj.height;
            const areaAspectRatio = canvasWidth / imageAreaHeight;
    
            let drawWidth, drawHeight, offsetX, offsetY;
    
            if (imageAspectRatio > areaAspectRatio) {
              // 画像が横長（幅をエリアに合わせ、高さを自動調整）
              drawWidth = canvasWidth;
              drawHeight = canvasWidth / imageAspectRatio;
              offsetX = 0;
              offsetY = (imageAreaHeight - drawHeight) / 2; // 中央揃え
            } else {
              // 画像が縦長 or 正方形（高さをエリアに合わせ、幅を自動調整）
              drawHeight = imageAreaHeight;
              drawWidth = drawHeight * imageAspectRatio;
              offsetX = (canvasWidth - drawWidth) / 2; // 中央揃え
              offsetY = 0;
            }
    
            // 画像描画（エリア内にぴったり収める）
            context.drawImage(imageObj, offsetX, offsetY, drawWidth, drawHeight);
            resolve();
          };
          imageObj.src = this.imageIcon;
        });
      }
      
      // テキストエリア（下半分）
      if (this.textIcon.length > 0) {
        // アイコンテキストを描画
        context.font = "900 50px Arial";
        context.textAlign = "center";
        context.fillStyle = this.colorTextIcon;
        context.fillText(this.textIcon, 50, 96, canvasWidth);
      }
    },

    selectImage() {
      this.$refs.inputFile.click();
    },
    async changeImage() {
      const file = this.$refs.inputFile.files[0];
      if (!file) return;

      await new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = (event) => {
          this.$refs.canvasIcon.src = event.target.result;
          resolve();
          reader.onload = null;
        }
        reader.readAsDataURL(file);
      });
      await this.previewImages(true);
      this.setEditRecordUrlInfo();
    },
    async updateImage() {
      if (
        (this.textIcon === this.editRecordUrlInfo.textIcon)
        && (this.colorTextIcon === this.editRecordUrlInfo.textColor)
      ) {
        return;
      }
      await this.previewImages();
      this.setEditRecordUrlInfo();
    },

    setContentDataForURL(newValue) {
      this.strUrl = newValue;
    },

    async resizeTextarea() {
      // textaraeの非表示状態が解除されてscrollHeightが有効な値になってから
      // heightの設定処理を行う
      await this.$nextTick();
      const el = this.$refs.urlTestComTextarea.$el;
      el.style.height = `${el.scrollHeight + 5}px`;
    }
  }
};
</script>

<style scoped>
.test-url-popover >>> .popover__content {
  width: auto;
  padding: 10px;
}
.main-contain {
  padding: 20px;
  box-sizing: border-box;
  max-height: 100%;
  overflow-y: auto;
}
.enable-flex-grow {
  flex-grow: 1;
}
.input-url {
  display: flex;
  justify-content: flex-start;
  align-items: center;
}
.input-url label {
  margin-right: 5px;
}
.input-required >>> textarea {
  color: black;
  background-color: #ffff99;
}
.input-invalid >>> textarea {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.btn-ok {
  width: 5em;
  color: #fafafa;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
}
.param-contain label {
  padding-right: 5px;
}
button.params {
  margin-right: 5px;
  white-space: nowrap;
}
.error-msg {
  margin-top: 2px;
  padding-left: 38px;
  color: red;
}
.wrapper {
  box-sizing: border-box;
  width: calc(100% - 39px);
  height: 147.12px;
  border: 2px solid black;
  padding: 5px 0px 0px 5px;
  margin: 0 0 25px 39px;
  overflow-y: auto;
}
.wasd {
  border-color: white;
}

.popover-content {
  display: flex;
  justify-content: center;
  flex-direction: column;
  height: 100%;
  width: 100%;
}

.popover-content textarea {
  margin: 0;
}

.popover-content .footer {
  padding: 10px 10px 0px 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
  padding-top: 10px;
}

.height-label {
  height: 25px;
}

.style-icon-canvas {
  background-color: var(--ntss-footer-background-color);
  border: solid 1px var(--ntss-footer-border-color);
}

.hide-select-file {
  display: none;
}

.distance-left-color-picker {
  margin-left: 5px;
}

.distance-items {
  margin: 0 20px 25px 0;
}

.ntss-button-url-icon {
  width: 45px;
  margin-right: 12px;
}
.ntss-text-icon {
  height: 21px;
  margin-right: 5px;
}

.distance-column {
  margin-left: 25px;
}

.style-color-picker {
  width: 30px;
}

.custom-main-contain .k-button {
  font-size: unset;
}

.custom-main-contain .ntss-text-icon {
  font-size: unset;
}

.comTextarea {
  margin-right: 5px;
}

.com-textare-url-cp {
  box-sizing: border-box;
  max-height: 30em;
  width: 100%;
}
</style>
