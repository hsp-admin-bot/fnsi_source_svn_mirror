<template>
  <div class="vertical-div" style="border-bottom: #595959 solid 1.5px;">
    <div class="field-name-con">
      <label class="title label-font ntss-pat-event-label" :class="{'vertical-middle': !getViewMode}">{{getInputFieldName}}</label>
      <div class="imagetop" v-if="isGetUseVa">
        <com-master-selector
          :readMasterData="requestApis.va"
          :masterDefine="masterDefs.va"
          v-model="vaNameObj"
          @input="handleSelector"
        />
      </div>
    </div>
    <div class="disp-item-area vertical-div scroll-setting">
      <div v-for="(row, rowIndex) in getImageGrid" :key="rowIndex" class="horizontal-div" style="width: calc(100% - 10px); padding-left: 10px; padding-bottom: 0.5em;">
        <div v-for="(item, index) in row" :key="rowIndex + '-' + index" style="width: 100%; min-width: 14em; border-bottom: rgb(89, 89, 89) dashed 1.5px; padding-right: 10px;">
          <!-- item.dummy(ダミーデータ)は縦をそろえる為の枠を確保する為のデータです -->
          <div v-if="typeof item.dummy === 'undefined'">
            <div class="image-area" v-if="showNameDispLine(row)">
              <label
                class="title ntss-pat-event-label"
              >{{ item.name }}</label>
            </div>
            <div class="horizontal-div" style="align-items: center; min-height: 1.5em;">
              <label
                class="button btn3-normal"
                :class="{
                  'btn3-normal-disabled': !getItemAuthorized(
                    'PatEvent',
                    'default_authority'
                  ),
                }"
                :id="'label' + propsIndex + '-' + imageIndex(rowIndex, index)"
                style="display: inline-flex"
              >
                ＋画像選択
                <input
                  :id="'input' + propsIndex + '-' + imageIndex(rowIndex, index)"
                  type="file"
                  accept="image/*, image/heic"
                  style="display: none"
                  @change="onLoadImgFile($event, imageIndex(rowIndex, index))"
                  :disabled="
                    !isShared ||
                    !getItemAuthorized(
                      'PatEvent',
                      'default_authority'
                    )
                  "
                />
              </label>
              <label
                class="labelFileName ntss-pat-event-label text-hidden"
                :id="'labelFileName' + propsIndex + '-' + imageIndex(rowIndex, index)"
              >{{innerHTML}}</label>
              <!-- #10977 インジェクション対応 linjunfeng end -->
              <!-- mod FNSI-4387。 fan end -->
              <!-- mod #10359 編集権限の動作不正 start -->
              <!-- <v-ons-button class="button btn3-normal" v-show="!getViewMode" id="editor-button"> -->
              <v-ons-button
                v-if="!getIsOtherFacilitys"
                class="button btn3-normal"
                :class="{
                  'btn3-normal-disabled': !getItemAuthorized(
                    'PatEvent',
                    'default_authority'
                  ),
                }"
                v-show="!getViewMode"
                id="editor-button"
              >
                <!-- mod #10359 編集権限の動作不正 end -->
                <!-- mod FNSI-共有を追加 王 20200921 start -->
                <!-- mod #10359 編集権限の動作不正 start -->
                <!-- <img
                  :src="patEventAsset('editor.png')"
                  id="editor-button-icon"
                  class="edit-icon"
                  @click="onImageEditClick(imageIndex(rowIndex, index))"
                  :disabled="!isShared"
                />  -->
                <img
                  :src="patEventAsset('editor.png')"
                  id="editor-button-icon"
                  class="edit-icon"
                  @click="onImageEditClick(imageIndex(rowIndex, index))"
                  :disabled="
                    !isShared ||
                    !getItemAuthorized(
                      'PatEvent',
                      'default_authority'
                    )
                  "
                />
                <!-- mod #10359 編集権限の動作不正 end -->
                <!-- mod FNSI-共有を追加 王 20200921 end -->
              </v-ons-button>
              <div v-else></div>
              <!-- mod #10359 編集権限の動作不正 start -->

              <!-- <label
                class="button btn3-normal"
                :class="{ 'btn3-normal-disabled': disabled }"
                :id="
                  'label-del' + propsIndex + '-' + imageIndex(rowIndex, index)
                "
                style="display: inline-flex"
              > -->
              <label
                v-if="!getIsOtherFacilitys"
                class="button btn3-normal"
                :class="{
                  'btn3-normal-disabled': !getItemAuthorized(
                    'PatEvent',
                    'default_authority'
                  ),
                }"
                :id="
                  'label-del' + propsIndex + '-' + imageIndex(rowIndex, index)
                "
                style="display: inline-flex"
              >
                <!-- mod #10359 編集権限の動作不正 end -->
                画像削除
                <!-- mod FNSI-共有を追加 王 20200921 start -->
                <input
                  :id="'input' + propsIndex + '-' + imageIndex(rowIndex, index)"
                  type="button"
                  style="display:none"
                  @click="removeImg(imageIndex(rowIndex, index))"
                  :disabled="!isShared"
                />
                <!-- mod FNSI-共有を追加 王 20200921 end -->
              </label>
              <div v-else></div>
            </div>
            <div class="horizontal-div" style="align-items: center;">
              <label
                class="title ntss-pat-event-label"
                style="margin-left: 20px;"
                v-show="isGetUseVa2 && (!getViewMode || inputModel.isSendVa[imageIndex(rowIndex, index)])"
                :for="
              getViewMode ? '' : 'check'+ propsIndex + '-' + imageIndex(rowIndex, index)"
              >透析装置表示</label>
              <!-- mod #10359 編集権限の動作不正 start -->
              <!-- <ons-checkbox
                :id="'check' + propsIndex + '-' + imageIndex(rowIndex, index)"
                :input-id="
                  'check' + propsIndex + '-' + imageIndex(rowIndex, index)
                "
                class="checkbox-va"
                :checked="inputModel.isSendVa[imageIndex(rowIndex, index)]"
                :disabled="inputModel.isDisable[imageIndex(rowIndex, index)]"
                v-show="!getViewMode && isGetUseVa2"
                @change="changeVa(imageIndex(rowIndex, index), $event)"
              ></ons-checkbox>  -->
              <ons-checkbox
                :id="'check' + propsIndex + '-' + imageIndex(rowIndex, index)"
                :input-id="
                  'check' + propsIndex + '-' + imageIndex(rowIndex, index)
                "
                class="checkbox-va"
                v-if="!getViewMode && isGetUseVa2"
                v-ons-checkbox-state="{
                  checked: inputModel.isSendVa[imageIndex(rowIndex, index)],
                  disabled:
                    inputModel.isDisable[imageIndex(rowIndex, index)] ||
                    !getItemAuthorized(
                      'PatEvent',
                      'default_authority'
                    )
                }"
                @change="changeVa(imageIndex(rowIndex, index), $event)"
              ></ons-checkbox>
              <!-- mod #10359 編集権限の動作不正 end -->
              <div class="title2" v-show="getViewMode || getIsOtherFacility || getIsOtherFacilitys">
                <label
                  class="ntss-pat-event-label"
                  :for="'compare-viewer-' + propsIndex + '-' + imageIndex(rowIndex, index)"
                >比較</label>
                <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 start -->
                <!-- <ons-checkbox
                  :id="'checkComp'+ propsIndex + '-' + imageIndex(rowIndex, index)"
                  class="checkbox-comp"
                  :checked="getCheckComp[imageIndex(rowIndex, index)]"
                  @change="changeComp(imageIndex(rowIndex, index), $event)"
                  :input-id="'compare-viewer-' + propsIndex + '-' + imageIndex(rowIndex, index)"
                ></ons-checkbox> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                <ons-checkbox
                  :id="'checkComp'+ propsIndex + '-' + imageIndex(rowIndex, index)"
                  class="checkbox-comp"
                  v-ons-checkbox-state="{
                    checked: getCheckComp[imageIndex(rowIndex, index)],
                    disabled: !getItemAuthorized(
                      'PatEvent',
                      'default_authority') || getIsOtherFacility || getIsOtherFacilitys
                  }"
                  @change="changeComp(imageIndex(rowIndex, index), $event)"
                  :input-id="'compare-viewer-' + propsIndex + '-' + imageIndex(rowIndex, index)"
                ></ons-checkbox>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                <!-- mod 9821 利用者マスタの患者イベント編集権限がOFFなのに観察記録の新規作成/編集ができてしまう 関 end -->
              </div>
            </div>
            <div
              :id="'preview' + propsIndex + '-' + imageIndex(rowIndex, index)"
              class="img_outer"
              @dblclick="onImageViewerClick(imageIndex(rowIndex, index))"
              @touchstart="onDblTap($event, imageIndex(rowIndex, index))"
            ></div>
          </div>
        </div>
      </div>
    </div>
    <v-ons-modal :visible="isShowEditorModal" @deviceBackButton="onDeviceBackButton" class="image-editor-modal">
      <pat-event-image-editor
        ref="imageEditor"
        @cancelEditor="onCancelEditor"
        @successEditor="onSuccessEditor"
      />
    </v-ons-modal>
    <v-ons-modal
      :visible="isShowViewer"
      @deviceBackButton="onDeviceBackButton"
      @click="isShowViewer=false"
    >
      <div class="viewer-frame">
        <img class="viewer-frame-img" ref="imageViewer" />
      </div>
    </v-ons-modal>
  </div>
</template>

<script>
import { publicAssetPath } from "@/compat/assets/public-path";
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import {sendRequestGetImageDownload, sendRequestPostImageDelete, sendRequestPostImageUpload} from "@/apis/pat-event";
  import PatEventVaMasterSelector from "@/components/pat-event/sub-item/PatEventVaMasterSelector";
  import PatEventImageEditor from "@/components/pat-event/image-editor/PatEventImageEditor";
  import {sendRequestGetMstVa} from "@/apis/treatment-record";
  import {va} from "@/components/common/master-selector/MasterSelectorDefinitions";
  import {Master} from "@/models/common/master-selector-condition/Master";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  import heic2any from "@/compat/media/heic2any";
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end
  import { dateFormat } from "@/functions/common/DateTimeUtils.js";
const setOnsCheckboxState = (el, state = {}) => {
  if (!el) {
    return;
  }
  const apply = () => {
    const input = el.querySelector?.("input") || el._input;
    if (!input) {
      requestAnimationFrame(apply);
      return;
    }
    const checked = !!state.checked;
    const disabled = !!state.disabled;
    input.checked = checked;
    input.disabled = disabled;
    el.toggleAttribute?.("checked", checked);
    el.toggleAttribute?.("disabled", disabled);
    el.classList?.toggle("checkbox--checked", checked);
    el.classList?.toggle("checkbox--disabled", disabled);
  };
  apply();
  requestAnimationFrame(apply);
};

export default {
  name: "PatEventImage",
  props: ["propsIndex", "propsIsva"],
  components: {
    "com-master-selector": PatEventVaMasterSelector,
    "pat-event-image-editor": PatEventImageEditor
  },
  directives: {
    onsCheckboxState: {
      mounted(el, binding) {
        setOnsCheckboxState(el, binding.value);
      },
      updated(el, binding) {
        setOnsCheckboxState(el, binding.value);
      }
    }
  },
  data() {
    return {
      inputModel: {
        isSendVa: [],
        isComp: [],
        isDisable: []
      },
      // add FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 start
      innerHTML: "",
      // add FNSI5791-患者イベントが２件に分かれて患者カレンダーに表示される 周 end
      removeImageList: [],
      uploadImageList: [],
      uploadFiles: [],
      sendVaList: [],
      isUseVaType: false,
      masterDefs: {
        va: va
      },
      requestApis: {
        va: sendRequestGetMstVa
      },
      /*add FNSI-改修内容图像bug 任 start*/
      imageNameList: [],
      rowCount: 0,
      /*add FNSI-改修内容图像bug 任 end*/
      // vaNameList: [],
      isShowEditorModal: false,
      editTargetImage: null,
      editTargetFileName: "",
      isShowViewer: false,
      fileExtensionList: ["jpeg", "JPEG", "jpg", "JPG", "png", "PNG", "bmp", "BMP", "heic", "HEIC"],
      tapedTwice: false,
      vaNameObj: new Master(),
      hasImageChanged: false
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatName", "selectedHospPatId"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      "getViewMode"
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("pat-event/viewer", ["getCompareViewImgs"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("pat-event/list", ["getIsEdit", "getUpdateMode", "getIsOtherFacility"]),
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    getImageGrid() {
      let rows = [];
      const img = this.getInputImage;
      const colCount = Number(this.getInputImageColNum);
      /*add FNSI-改修内容图像bug 任 start*/
      this.rowCount = colCount;
      /*add FNSI-改修内容图像bug 任 end*/
      for (let idx = 0; idx < img.length;) {
        let clm = [];
        for (
          let colIdx = 0;
          colIdx < colCount && idx < img.length;
          colIdx++, idx++
        ) {
          clm.push(img[idx]);
        }
        rows.push(clm);
      }
      // 最後の行が画像表示の最大件数に満たないのならばダミーデータを付ける
      const lastIndex = rows.length - 1;
      if (rows[lastIndex].length < colCount) {
        const nokoricount = colCount - rows[lastIndex].length;
        for (let i = 0; i < nokoricount; i += 1) {
          rows[lastIndex].push({"dummy":""});
        }
      }
      return rows;
    },
    getInputImage() {
      return this.getPatEventInputParams[this.propsIndex].item_json.values;
    },
    getInputImageColNum() {
      return this.getPatEventInputParams[this.propsIndex].item_json
        .image_col_num;
    },
    getInputFieldName() {
      const flag = this.getPatEventInputParams[this.propsIndex]
        .is_field_display;
      if (flag === "1") {
        return this.getPatEventInputParams[this.propsIndex].field_name;
      } else {
        return "";
      }
    },
    isGetUseVa() {
      return this.isUseVaType || this.propsIsva;
    },
    isGetUseVa2() {
      if (this.isUseVaType) {
        return true;
      } else {
        if (this.propsIsva) {
          return true;
        }
      }
      return false;
    },
    isNotGetUseVa() {
      if (this.isUseVaType) {
        return "none";
      } else {
        if (this.propsIsva) {
          return "none";
        }
      }
      return "inline-flex";
    },
    getCheckComp() {
      let value = [];
      //チェックボックスのチェック確認設定
      for (let index = 0; index < this.getInputImage.length; index++) {
        let filteredList = deepCopy(this.getCompareViewImgs);
        const patEventCd = this.getPatEventRecord.patEventCd;
        const targetId = "preview" + this.propsIndex + "-" + index;
        filteredList = filteredList.filter(
          item => item.patEventCd === patEventCd && item.targetId === targetId
        );
        if (filteredList.length > 0) {
          value.push(true);
        } else {
          value.push(false);
        }
      }
      return value;
    }
  },
  watch: {
    windowHeight() {
      this.calculateImgMargin();
    },
    getViewMode() {
      this.setDisplay();
    },
    uploadImageList: {
      handler(newVal, oldVal) {
        if (JSON.stringify(newVal) !== JSON.stringify(oldVal)) {
          this.hasImageChanged = true;
          this.updateParentData();
        }
      },
      deep: true
    },
    sendVaList: {
      handler(newVal, oldVal) {
        if (JSON.stringify(newVal) !== JSON.stringify(oldVal)) {
          this.updateParentData();
        }
      },
      deep: true
    }
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  mounted() {
    //画像の枠を設定
    for (let idx = 0; idx < this.getInputImage.length; idx++) {
      this.setImageBorder(idx);
      this.uploadImageList.push({ file_name: "", file_path: "", file_time: "", file_modified_time: "" });
      this.uploadFiles.push("");
      this.sendVaList.push("0");
      this.inputModel.isSendVa.push(false);
      this.inputModel.isDisable.push(true);
      this.inputModel.isComp.push(false);
      /*mod FNSI-改修内容图像bug 任 start*/
      /*this.vaNameList.push(new Master("0", this.getInputImage[idx].name));*/
      // this.vaNameList.push(new Master("0", ""));
      this.imageNameList.push(this.getInputImage[idx].name);
      /*mod FNSI-改修内容图像bug 任 end*/
    }
    //ストアより画像取得
    this.initImage();
    //チェックボックスのチェック確認設定
    this.setChecked();
  },
  methods: {
    patEventAsset(fileName) {
      return publicAssetPath(`img/pat-event/${fileName}`);
    },
    getScopedElementById(id) {
      return getScopedElementById(id, this);
    },
    getScopedElementsByClassName(className) {
      return getScopedElementsByClassName(className, this);
    },
    getScopedQuery(selector) {
      return queryScopedSelector(selector, this);
    },
    getScopedQueryAll(selector) {
      return queryScopedSelectorAll(selector, this);
    },

    ...mapActions("multi-modal", ["showPatEventImageEditor"]),
    ...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),
    ...mapActions("pat-event/viewer", [
      "setCompareViewImgs",
      /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
      "setTarget",
      "setCompareViewImgsRemove",
      /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
      "clearCompareViewImgs"
    ]),
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    // add #11389 患者イベントの編集での不正　V1.1A linjunfeng start
    handleSelector() {
      const imageList = this.createJsonData();
      const formatClass = this.getPatEventResultParams[this.propsIndex]
        .format_class;
      const values = {
        format_class: formatClass,
        result_value: imageList
      };
      if (this.isGetUseVa) {
        values.va_name = this.vaNameObj.name || null;
        values.va_cd = this.vaNameObj.cd || null;
      }
      this.setPatEventResultParamsUpdate({
        item: values,
        index: this.propsIndex
      });
    },
    // add #11389 患者イベントの編集での不正　V1.1A linjunfeng end

    // 行の中で表示する名称があれば、枠を保持します。
    showNameDispLine(row) {
      let strLen = 0;
      if (row.length > 0) {
        for (let i = 0; i < row.length; i += 1) {
          if (row[i] && row[i].name) {
            strLen += row[i].name.length;
          }
        }
      }
      return strLen > 0 ? true : false;
    },
    setChecked() {
      //チェックボックスのチェック確認設定
      for (let index = 0; index < this.getInputImage.length; index++) {
        let filteredList = deepCopy(this.getCompareViewImgs);
        const patEventCd = this.getPatEventRecord.patEventCd;
        const targetId = "preview" + this.propsIndex + "-" + index;
        filteredList = filteredList.filter(
          item => item.patEventCd === patEventCd && item.targetId === targetId
        );
        if (filteredList.length > 0) {
          this.inputModel.isComp.splice(index, 1, true);
        } else {
          this.inputModel.isComp.splice(index, 1, false);
        }
      }
    },
    imageIndex(rowIndex, columnIndex) {
      const colCount = Number(this.getInputImageColNum);
      return rowIndex * colCount + columnIndex;
    },
    setImageBorder(idx) {
      const targetId = "preview" + this.propsIndex + "-" + idx;
      let preview = this.getScopedElementById(targetId);
      const ownerDocument = preview?.ownerDocument || this.$el?.ownerDocument || document;
      let img = ownerDocument.createElement("img");
      img.setAttribute("id", "previewImage-" + targetId);
      img.setAttribute("class", "inner_photo");
      preview.appendChild(img);
    },
    setDisplay() {
      const result = this.getPatEventResultParams[this.propsIndex];
      for (let index = 0; index < this.getInputImage.length; index++) {
        const para = this.propsIndex + "-" + index;
        if (this.getViewMode) {
          this.getScopedElementById("label" + para).style.display = "none";
          const labelDel = this.getScopedElementById("label-del" + para);
          if (labelDel) {
            labelDel.style.display = "none";
          }
          this.getScopedElementById("labelFileName" + para).style.maxWidth = "unset";
        } else {
          this.getScopedElementById("labelFileName" + para).style.maxWidth = "";
          if (result.result_value[index] !== undefined) {
            if (result.result_value[index].file_name !== "") {
              this.getScopedElementById("label" + para).style.display = "none";
              const labelDel = this.getScopedElementById("label-del" + para);
              if (labelDel) {
                labelDel.style.display = "inline-flex";
              }
              continue;
            }
          }
          this.getScopedElementById("label" + para).style.display = "inline-flex";
          const labelDel = this.getScopedElementById("label-del" + para);
          if (labelDel) {
            labelDel.style.display = "inline-flex";
          }
        }
      }
      // 編集モードかチェック
      if (this.getIsEdit && this.getUpdateMode) {
        this.inputModel.isDisable.length = 0;
        for (let idx = 0; idx < this.getInputImage.length; idx++) {
          let para = this.propsIndex + "-" + idx;
          // 編集モードで、ファイル選択されていれば、チェックボックスを編集可とする
          this.inputModel.isDisable.push(!this.getScopedElementById("labelFileName" + para).innerHTML);
        }
      }
    },
    async initImage() {
      let idx = 0;
      const result = this.getPatEventResultParams[this.propsIndex];
      if (result.result_value.length !== 0) {
        this.uploadImageList = result.result_value;
        for (const res of result.result_value) {
          if (res.file_name !== "") {
            this.downloadFile(res, idx);
          }
          if (res.is_send_va !== undefined) {
            this.sendVaList[idx] = res.is_send_va;
            if (res.is_send_va === "1") {
              this.inputModel.isSendVa[idx] = true;
            }
            this.isComp = false;
            this.isUseVaType = true;
          }
          idx++;
        }
        this.vaNameObj.cd = result.va_cd || null;
        this.vaNameObj.name = result.va_name || '';
      }
      this.setDisplay();
    },
    changeVa(index, event) {
      if (event.target.checked) {
        ((this.sendVaList)[index] = "1");
        ((this.inputModel.isSendVa)[index] = true);
      } else {
        ((this.sendVaList)[index] = "0");
        ((this.inputModel.isSendVa)[index] = false);
      }
      const imageList = this.createJsonData();
      const formatClass = this.getPatEventResultParams[this.propsIndex]
        .format_class;
      const values = {
        format_class: formatClass,
        result_value: imageList
      };
      if (this.isGetUseVa) {
        values.va_name = this.vaNameObj.name || null;
        values.va_cd = this.vaNameObj.cd || null;
      }
      this.setPatEventResultParamsUpdate({
        item: values,
        index: this.propsIndex
      });
    },
    changeComp(index, event) {
      const targetId = "preview" + this.propsIndex + "-" + index;
      if (event.target.checked) {
        this.inputModel.isComp.splice(index, 1, true);
        const elm = this.getScopedElementById("previewImage-" + targetId);
        if (elm && elm.src) {
          this.editTargetImage = elm.src;
          this.setCompareViewImgs({
            hospPatId: this.selectedHospPatId,
            patName: this.selectedPatName,
            patEventCd: this.getPatEventRecord.patEventCd,
            targetId: targetId,
            data: this.editTargetImage,
            categoryName: this.getPatEventRecord.categoryName,
            subCategoryName: this.getPatEventRecord.subCategoryName,
            /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start*/
            /*eventDate: this.getPatEventRecord.eventDate,*/
            eventStartDate: this.getPatEventRecord.eventStartDate,
            eventEndTime: this.getPatEventRecord.eventEndTime === null ? " 00:00" : " "+this.getPatEventRecord.eventEndTime,
            eventStartTime: this.getPatEventRecord.eventStartTime === null ? " 00:00" : " "+this.getPatEventRecord.eventStartTime,
            /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end*/
            /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
            isEdit: false,
            isDel: false,
            /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
            eventEndDate: this.getPatEventRecord.eventEndDate
          });
        }
      } else {
        this.inputModel.isComp.splice(index, 1, false);
        let viewImagesAll = deepCopy(this.getCompareViewImgs);
        this.clearCompareViewImgs();
        for (let index = 0; index < viewImagesAll.length; index++) {
          if (
            viewImagesAll[index].patEventCd ===
              this.getPatEventRecord.patEventCd &&
            viewImagesAll[index].targetId === targetId
          ) {
            //TODO:
          } else {
            this.setCompareViewImgs(viewImagesAll[index]);
          }
        }
      }
    },
    /**
     * 画像クリア
     */
    removeImg(index) {
      // 画像削除
      const targetId = "preview" + this.propsIndex + "-" + index;
      const labelId = "label" + this.propsIndex + "-" + index;
      const labelFileName = "labelFileName" + this.propsIndex + "-" + index;
      let preview = this.getScopedElementById(targetId);
      let previewImage = this.getScopedElementById("previewImage-" + targetId);
        this.setTarget(targetId);
      if (previewImage != null) {
        preview.removeChild(previewImage);
      }
      this.innerHTML = "";
      this.getScopedElementById(labelFileName).style.display = "none";
      this.getScopedElementById(labelId).style.display = "inline-flex";
      // 画像枠の再設定
      this.setImageBorder(index);
      // ファイル選択メッセージの初期化
      let inputButton = this.getScopedElementById(
        "input" + this.propsIndex + "-" + index);
      inputButton.value = "";
      // アップロードリストから削除
      const value = this.uploadImageList[index];
      //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      ((this.uploadImageList)[index] = this.isGetUseVa ?
          { file_name: "", file_path: "", is_send_va: "0", file_modified_time: "" } : { file_name: "", file_path: "", file_modified_time: "" });
      const formatClass = this.getPatEventResultParams[this.propsIndex]
          .format_class;
      const values = {
        format_class: formatClass,
        result_value: this.uploadImageList
      };
      if (this.isGetUseVa) {
        values.va_name = this.vaNameObj.name || null;
        values.va_cd = this.vaNameObj.cd || null;
      }
      this.setPatEventResultParamsUpdate({
        item: values,
        index: this.propsIndex
      });
      //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      ((this.inputModel.isComp)[index] = false);
      // 削除ファイルリストに追加
      this.removeImageList.push(value);
      // 画像ファイルの削除
      ((this.uploadFiles)[index] = "");
      ((this.inputModel.isSendVa)[index] = false);
      ((this.inputModel.isDisable)[index] = true);
      ((this.sendVaList)[index] = "0");
      /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
      this.getCompareViewImgs.forEach((item,index) => {
        if(item.patEventCd === this.getPatEventRecord.patEventCd && item.targetId === targetId){
          this.setCompareViewImgsRemove(index);
        }
      })
      /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/

      this.hasImageChanged = true;

      this.updateParentData();
    },
    onLoadImgFile(event, targetIndex) {
      const targetId = "preview" + this.propsIndex + "-" + targetIndex;
      const file = event.target.files[0];
      // #8609 患者イベント画面にて、exe形式がアップロードされてしまう 訾浩 start
      const arr = file.name.split('.')
      const filetype = arr[arr.length - 1]
      if (this.fileExtensionList.indexOf(filetype) === -1) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['13000161'].title,
          message: messageFormat(DIALOG_MESSAGES['13000161'].message),
        });
        event.target.value = null
        return
      }
      ((this.inputModel.isDisable)[targetIndex] = false);
      ((this.inputModel.isSendVa)[targetIndex] = true);
      ((this.sendVaList)[targetIndex] = "1");
      //拡張子がheicの場合、jpegへ変換
      let extension = file.name.toLowerCase();
      if (extension.split(".").pop() === "heic") {
        heic2any({
          blob: file,
          toType: "image/jpeg",
          quality: 0.5,
          multiple: true
        }).then(resultBlob => {
          let reader = new FileReader();
          reader.onload = async () => {
            const blob = this.getBlobEditImage({ img: reader.result });
            const cfile = this.blobToFile(
              blob,
              file.name/* .replace(".heic", ".jpeg") */
            );
            this.preViewImg(cfile, targetIndex);
          };
          reader.readAsDataURL(resultBlob[0]);
        });
      } else {
        this.preViewImg(file, targetIndex);
      }
      this.setTarget(targetId);

      this.hasImageChanged = true;
    },
    /**
     * 画像読込と表示
     */
    async preViewImg(file, targetIndex) {
      const MAXSIZE = 5500000;
      const inputId = "input" + this.propsIndex + "-" + targetIndex;
      const targetId = "preview" + this.propsIndex + "-" + targetIndex;
      const labelId = "label" + this.propsIndex + "-" + targetIndex;
      const labelFileName =
        "labelFileName" + this.propsIndex + "-" + targetIndex;
      let preview = this.getScopedElementById(targetId);
      let previewImage = this.getScopedElementById("previewImage-" + targetId);
      let inputButton = this.getScopedElementById(inputId);
      if (file.size > MAXSIZE) {
        await this.$ons.notification
          .alert({
            title: "エラー",
            message: "ファイルサイズを超えてます。"
          })
          .then(() => {
            if (previewImage != null) {
              preview.removeChild(previewImage);
            }
            inputButton.value = "";
            const ownerDocument = preview?.ownerDocument || this.$el?.ownerDocument || document;
            let img = ownerDocument.createElement("img");
            img.setAttribute("id", "previewImage-" + targetId);
            img.setAttribute("class", "inner_photo");
            preview.appendChild(img);
            return;
          });
      }
	  this.addFile(file, targetIndex);
      
      if (previewImage != null) {
        preview.removeChild(previewImage);
      }
      this.getScopedElementById(labelFileName).innerHTML = file.name;
       // add FNSI-4387。 fan start
      this.getScopedElementById(labelFileName).title = file.name;
      // add FNSI-4387。 fan end
      this.getScopedElementById(labelFileName).style.display = "block";
      this.getScopedElementById(labelId).style.display = "none";
      this.readerOnload(targetId, preview, file);

      ((this.uploadFiles)[targetIndex] = file);

      this.updateParentData();
    },
    // 画像モーダルのマージン(中央よせ)調整処理
    async calculateImgMargin(imgHeight = 0) {
      const viewImgModalObj = this.getScopedElementsByClassName("viewer-frame-img");
      for (let idx = 0; idx < viewImgModalObj.length; idx++) {
        const imgOffsetHeight = imgHeight !== 0 ? imgHeight : viewImgModalObj[idx].offsetHeight;
        if (!imgOffsetHeight) {
          // 非表示
          continue;
        }
        let topPx = this.windowHeight - ( imgOffsetHeight + 40);
        if (topPx <= 0) {
          viewImgModalObj[idx].style.marginTop = "0px"
        } else {
          viewImgModalObj[idx].style.marginTop = (topPx / 2) + "px"
        }
      }
    },
    /**
     * アップロード対象の画像ファイルの存在チェック
     */
    async uploadImageFileExistsCheck() {
      for (const file of this.uploadFiles) {
        if (file !== "") {
          try {
            await this.readFileAsync(file);
          } catch(error) {
            return file.name;
          }
        }
      }
      return "";
    },
    /**
     * @description アップロード対象ファイルの読込
     */
    readFileAsync(file) {
      return new Promise((resolve, reject) => {
        let fileReader = new FileReader();
        fileReader.onload = () => resolve(fileReader.result);
        fileReader.onerror = () => reject(fileReader.error);
        fileReader.readAsDataURL(file);
      });
    },
    /**
     * 画像ファイルのアップロード
     */
    async uploadS3File() {
      const patId = this.getPatEventRecord.patId;
      if (this.removeImageList.length !== 0) {
        // 削除
        await this.deleteImage({
          facilityCd: this.facilityCd,
          patId: patId,
          removedFiles: this.removeImageList
        });
      }
      // アップロード
      return await this.uploadImage({
        facilityCd: this.facilityCd,
        patId: patId
      });
    },
    /**
     * 画像ファイルの削除
     */
    async deleteS3File() {
      const patId = this.getPatEventRecord.patId;
      if (this.removeImageList.length !== 0) {
        // 削除
        await this.deleteImage({
          facilityCd: this.facilityCd,
          patId: patId,
          removedFiles: this.removeImageList
        });
      }
      if (this.uploadImageList.length !== 0) {
        // 削除
        await this.deleteImage({
          facilityCd: this.facilityCd,
          patId: patId,
          removedFiles: this.uploadImageList
        });
      }
      return true;
    },
    /**
     * API画像ファイルの削除
     */
    async deleteImage(params) {
      await sendRequestPostImageDelete({
        facilityCd: params.facilityCd,
        patId: params.patId,
        removedFiles: params.removedFiles
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatEventImage.vue', 'deleteImage', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        return false;
      });
      return true;
    },
    /**
     * API画像ファイルをアップロード
     */
    async uploadImage(params) {
      const rec = this.getPatEventRecord;
      let dt = new Date(rec.eventDate);
      let count = 0;
      for (const file of this.uploadFiles) {
        if (file !== "") {
          let fieldName = this.propsIndex;
          let eventDate =
            dt.getFullYear() +
            ("00" + (dt.getMonth() + 1)).slice(-2) +
            ("00" + dt.getDate()).slice(-2);
          const formData = new FormData();
          formData.append("files", file);
          const res = await sendRequestPostImageUpload(
            {
              facilityCd: params.facilityCd,
              patId: params.patId,
              eventDate: eventDate,
              patEventCd: rec.patEventCd,
              fieldName: fieldName,
              imageNo: count
            },
            formData).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
            getErrorMessage('PatEventImage.vue', 'uploadImage', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
            return false;
          });
          if (res.status !== 200) {
            return false;
          }
        }
        count++;
      }

      this.updateStoreData();

      this.hasImageChanged = false;

      return true;
    },
    createJsonData() {
      const rec = this.getPatEventRecord;
      let path =
        rec?.patId +
        "/" +
        rec?.patEventCd +
        "/" +
        "image" +
        "/";
      let vaList = this.sendVaList;
      let imageList = [];
      let index = 0;
      for (const image of this.uploadImageList) {
        if (this.isGetUseVa) {
          if (image.file_name.trim() !== "") {
            imageList.push({
              file_name: image.file_name,
              file_path: image.file_path,
              is_send_va: vaList[index],
              file_modified_time: image.file_modified_time
            });
          } else {
            imageList.push({
              file_name: "",
              file_path: "",
              is_send_va: vaList[index],
              file_modified_time: ""
            });
          }
        } else {
          if (image.file_name.trim() !== "") {
            imageList.push({
              file_name: image.file_name,
              file_path: image.file_path,
              file_modified_time: image.file_modified_time
            });
          } else {
            imageList.push({ file_name: "", file_path: "", file_modified_time: "" });
          }
        }
        index++;
      }
      return imageList;
    },
    uploadS3List() {
      const imageList = this.createJsonData();
      const formatClass = this.propsIndex && this.getPatEventResultParams && this.getPatEventResultParams[this.propsIndex] && this.getPatEventResultParams[this.propsIndex]
        .format_class ? this.getPatEventResultParams[this.propsIndex]
        .format_class : null;

      this.hasImageChanged = false;

      return {
        index: this.propsIndex,
        format_class: formatClass,
        result_value: imageList
      };
    },
    /**
     * ストアへ画像ファイル情報の格納
     */
    addFile(file, index) {
      const rec = this.getPatEventRecord;
      let path =
        rec.patId +
        "/" +
        rec.patEventCd +
        "/" +
        "image" +
        "/";

      const newItem = {
        file_name: file.name,
        file_path: path + this.propsIndex + "-" + index + "/" + file.name,
        is_send_va: '0',
        name: '',
        file_modified_time: dateFormat.format(new Date(), "yyyyMMddhhmmss")
      };

      ((this.uploadImageList)[index] = newItem);
    },
    /**
     * @description 拡張子取得
     *
     */
    getImageMimeObj(fileName) {
      // 拡張子取得
      const fineNameSplit = fileName.split(".")
      let typeObj = {};
      switch (fineNameSplit[fineNameSplit.length - 1]) {
        case "png":
          typeObj = {
            type: "image/png"
          };
          break;
        case "jpg":
        case "jpeg":
          typeObj = {
            type: "image/jpeg"
          };
          break;
        case "bmp":
          typeObj = {
            type: "image/bmp"
          };
          break;
        case "gif":
          typeObj = {
            type: "image/gif"
          };
          break;
        case "svg":
          typeObj = {
            type: "image/svg+xml"
          };
          break;
        default:
          typeObj = {
            type: "image/png"
          };
          break;
      }
      return typeObj;
    },
    /**
     * @description ファイルをダウンロード
     * @param {Object} file
     * @param {String} file.file_path
     * @param {String} file.file_name
     */
    async downloadFile(file, targetIndex) {
      const filepath = file.file_path;
      const filename = file.file_name;
      const labelId = "label" + this.propsIndex + "-" + targetIndex;
      const labelFileName =
        "labelFileName" + this.propsIndex + "-" + targetIndex;
      const response = await sendRequestGetImageDownload(filepath);
      const downloadData = response.request.response;

      // 拡張子取得
      let typeObj = this.getImageMimeObj(filename);
      const blob = new File(
        [this.hexStringToArrayBuffer(downloadData)],
        filename,
        typeObj
      );
      //読込処理
      const targetId = "preview" + this.propsIndex + "-" + targetIndex;
      let preview = this.getScopedElementById(targetId);
      let previewImage = this.getScopedElementById("previewImage-" + targetId);
      if (previewImage != null) {
        preview.removeChild(previewImage);
      }
      this.getScopedElementById(labelFileName).innerHTML = file.file_name;
      this.getScopedElementById(labelFileName).style.display = "block";
      this.getScopedElementById(labelId).style.display = "none";
      this.readerOnload(targetId, preview, blob);
    },
    readerOnload(targetId, preview, blob) {
      let reader = new FileReader();
      reader.onload = async () => {
        const ownerDocument = preview?.ownerDocument || this.$el?.ownerDocument || document;
        let img = ownerDocument.createElement("img");
        img.setAttribute("src", reader.result);
        img.setAttribute("id", "previewImage-" + targetId);
        img.setAttribute("class", "inner_photo");
        await preview.appendChild(img);
      };
      reader.readAsDataURL(blob);
    },
    /**
     * @description 16進文字列をバイト配列に変換
     * @param {String} hexStr 16進文字列
     */
    hexStringToArrayBuffer(hexStr) {
      const bytes = [];
      // 受け取った16進数文字列を符号付バイト配列に変換
      for (let i = 0; i < hexStr.length; i += 2) {
        bytes.push(this.hexToDecimalNumber(hexStr.substr(i, 2)));
      }
      // バイト配列をArrayBuffer型に変換
      const arrayBuffer = new Uint8Array(bytes);
      return arrayBuffer;
    },
    /**
     * @description 16進文字列をバイト値に変換
     * @param {String} hexStr 16進文字列
     */
    hexToDecimalNumber(hexStr) {
      let decimalNumber = "";
      // 受け取った16進数値を2進数値に変換
      const binaryNumber = parseInt(hexStr, 16).toString(2);
      // 変換した2進数値のサイズが8未満の場合、正数であるため10進数値に変換
      if (binaryNumber.length < 8) {
        decimalNumber = parseInt(hexStr, 16);
        // 変換した2進数値のサイズが8の場合、負数であるため符号付10進数値に独自変換
      } else {
        // 2進数値のサイズ分(8サイズ)回り、ビット値を入れ替える
        const binaryNumberStr = binaryNumber.toString();
        for (let i = 0; i < binaryNumberStr.length; i++) {
          if (parseInt(binaryNumberStr.substr(i, 1), 10) === 0) {
            decimalNumber += "1";
          } else if (parseInt(binaryNumberStr.substr(i, 1), 10) === 1) {
            decimalNumber += "0";
          }
        }
        // ビット値を入れ替えた2進数値を10進数値に変換し、1を足して負数に変換する
        decimalNumber = -(parseInt(decimalNumber, 2) + 1);
      }
      return decimalNumber;
    },
    /** 画像編集ボタンクリック */
    onImageEditClick(idx) {
      const targetId = "preview" + this.propsIndex + "-" + idx;
      const elm = this.getScopedElementById("previewImage-" + targetId);
      const labelFileName =
        "labelFileName" + this.propsIndex + "-" + idx;
      if (elm && elm.src) {
        this.isShowEditorModal = true;
        /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
        this.setTarget(targetId);
        /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
        this.editTargetImage = elm.src;
        const fNameElm = this.getScopedElementById(labelFileName);
        if (fNameElm.innerHTML) {
          this.editTargetFileName = fNameElm.innerHTML;
        } else {
          this.editTargetFileName = "edited.png";
        }
        this.$refs.imageEditor.init(this.editTargetImage, this.editTargetFileName, idx);
      }
    },
    /** 画像編集キャンセル */
    onCancelEditor() {
      this.isShowEditorModal = false;
    },
    onDeviceBackButton(event) {
      event.preventDefault();
      this.isShowEditorModal = false;
    },
    /** 画像編集結果取得 */
    onSuccessEditor(payload) {
      this.isShowEditorModal = false;
      const blob = this.getBlobEditImage(payload);
      const file = this.blobToFile(blob, payload.name);
      this.$nextTick(() => {
        this.preViewImg(file, payload.idx);

        this.hasImageChanged = true;

        this.updateParentData();
      });
    },
    /** Blogオブジェクトを取得 */
    getBlobEditImage(payload) {
      // base64を取得
      const base64 = payload.img;
      // base64からバイナリへ変換
      const bin = atob(base64.replace(/^.*,/, ""));
      // バイナリ配列を作成
      let buffer = new Uint8Array(bin.length);
      for (let i = 0; i < bin.length; i++) {
        buffer[i] = bin.charCodeAt(i);
      }
      // 拡張子取得
      let typeObj = { type: "image/" + payload.mimeType };
      // Blobを作成
      const blob = new Blob([buffer.buffer], typeObj);
      return blob;
    },
    /** blobからFileに変換する */
    blobToFile(theBlob, fileName) {
      //A Blob() is almost a File() - it's just missing the two properties below which we will add
      // theBlob.lastModifiedDate = new Date();
      let file = new File([theBlob], fileName);
      return file;
    },
    onImageViewerClick(idx) {
      // iOS/Androidでダブルタップの処理の度に発火しないように対策
      const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
      if (ua.match(/Android/) || ua.match(/iPhone|iPad/)) {
        return;
      }
      const targetId = "preview" + this.propsIndex + "-" + idx;

      const elm = this.getScopedElementById("previewImage-" + targetId);
      if (elm && elm.src) {
        var image = new Image();
        image.src = elm.src;
        this.isShowViewer = true;
        this.$refs.imageViewer.src = elm.src;
        this.$refs.imageViewer.style.height = image.height + "px";
        this.$refs.imageViewer.style.width = image.width + "px";
        this.calculateImgMargin(image.height);
      }
    },
    // ダブルタップの処理
    onDblTap(event, idx) {
      if(!this.tapedTwice) {
        this.tapedTwice = true;
        setTimeout( () => { this.tapedTwice = false; }, 300);
        return false;
      }
      event.preventDefault();
      this.onImageViewerClick(idx);
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let imageValid = true;
      let index = 0;
      for (const image of this.uploadImageList) {
        if (this.sendVaList[index] === "1") {
          if (image.file_name) {
            let fileName = image.file_name.toLowerCase();
            let fileExtension = fileName.split(".").pop();
            const result = this.fileExtensionList.find(
              v => v === fileExtension
            );
            if (!result) {
              imageValid = false;
            }
          }
        }
        index++;
      }
      return {
        textValid: imageValid
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
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000300].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.imageValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "VA画像に設定する画像は .jpg, .png, .bmp .heic のいずれかにしてください。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000300].message)
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

    updateParentData() {

      this.updateStoreData();

      this.$emit('image-changed', {
        index: this.propsIndex,
        hasChanged: this.hasImageChanged
      });
    },

    updateStoreData() {
      const imageList = this.createJsonData();
      const formatClass = this.getPatEventResultParams[this.propsIndex].format_class;
      const values = {
        format_class: formatClass,
        result_value: imageList
      };

      if (this.isGetUseVa) {
        values.va_name = this.vaNameObj.name || null;
        values.va_cd = this.vaNameObj.cd || null;
      }

      this.setPatEventResultParamsUpdate({
        item: values,
        index: this.propsIndex
      });
    }
  }
};
</script>

<style lang="scss" scoped>
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
  font-size: 1em;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
}
.disp-item-area {
  width: 100%;
  border-collapse: collapse;
  display: flex;
  flex-wrap: wrap;
}
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
.title {
  margin-left: 10px;
  width: fit-content;
/*<!-- add FNSI 患者イベント画面レイアウト調整 吉 start -->*/
  border-bottom: var(--ntss-base-color) solid 1.5px;
/*<!-- add FNSI 患者イベント画面レイアウト調整 吉 end -->*/
}
/* 画像の見出しが2重表示している 5338 shan start */
.title2 {
  margin-left: 20px;
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
}
/* 画像の見出しが2重表示している 5338 shan end */
.labelFileName {
  margin-left: 1em;
  display: none;
}
.checkbox-va {
  margin-left: 5px;
}
.checkbox-comp {
  margin-left: 5px;
}
.img_outer {
  position: relative;
  margin-top: 0.5em;
  margin-bottom: 0.5em;
  border: 1px solid #333;
  width: 100%;
  height: auto;
  min-height: 1.2em;
}
:deep(.img_outer img){
  vertical-align: top;
  width: 100%;
}
.inner_photo {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  width: inherit !important;
}
.image-area {
  margin: 5px 0;
}
#editor-button {
  width: 2.5em;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-left: 2px;
  margin-right: 2px;
}
#editor-button-icon {
  width: 1.5em;
  display: block;
}
.viewer-frame {
  overflow: auto;
  height: 100vh;
  width: 100vw;
}
.viewer-frame-img {
  padding: 20px;
}
.button {
  font-size: 100%;
}
.scroll-setting {
  overflow-x: auto;
}
.text-input {
  height: 1.2em;
}
/*add FNSI-4387。 fan start*/
.text-hidden{
  overflow:hidden;
  text-overflow:ellipsis;
  white-space:nowrap;
  max-width: 50%;
}
 /*add FNSI-4387。 fan end*/
.field-name-con {
  display: flex;
  flex-direction: column;
  .imagetop{
    margin-top: 5px;
    margin-left: 10px;
  }
}
.field-name-con .title{
  &.vertical-middle{
    vertical-align: -webkit-baseline-middle;
  }
}
/* mod #10359 編集権限の動作不正 start */
.btn3-normal-disabled {
  color: #bfbfbf !important;
  background-color: #dfdfdf;
  background-image: none !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
  opacity: 0.6;
}
/* mod #10359 編集権限の動作不正 end  */
</style>
