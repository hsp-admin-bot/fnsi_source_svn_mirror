<template>
  <div class="main-area">
    <div class="upper">
      <v-ons-row>
        <v-ons-col class="item-title">メニューグループ名</v-ons-col>
        <v-ons-col class="item-data item-input">
          <custom-input
            :value="menuGroupName"
            :is-required="true"
            maxlength="256"
            @change="onNameChange()"
            @input="warningCancel"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="item-row">
        <v-ons-col class="item-title-icon">アイコン</v-ons-col>
        <v-ons-col class="item-data item-input">
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
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-row class="item-row select-area">
      <v-ons-col class="item-title-icon">メニューグループ</v-ons-col>
      <v-ons-col class="item-data item-input">
        <list-selector-no-popover
          v-if="selectionMenuData"
          v-bind="selectionMenuData"
          :sort="true"
          @update:selected-items="setMenuList($event)"
        />
      </v-ons-col>
    </v-ons-row>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { FUNC_DEVICE_EDGE_OPERATION } from "@/constants/function-code";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getMstUrlLinkRegister } from "@/functions/mst/MstGetters";
import { messageFormat } from '@/functions/common/MessageFormat'
import { createItemListData } from "@/functions/for-componet/ListSelector";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import listSelectorNoPopover from "@/components/common/list-selector/ListSelectorNoPopover.vue";
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { MST_DEFAULT_VALUE } from "@/constants/masterDefineDetail";
import { EventBus } from "@/eventBus";

const uriFunctionAll = "/mstInfo/sysFunction";
const uriFunctionFacility = "/mstInfo/mstFacility/";
// アイコン情報 初期値
const DefaultValues = JSON.parse(JSON.stringify(MST_DEFAULT_VALUE.mst_menu_group.iconInfo));

export default {
  mixins: [MasterMaintenanceMixin],
  components: {
    "custom-input": customInput,
    "list-selector-no-popover": listSelectorNoPopover,
  },
  data() {
    return {
      // メニューグループ名
      menuGroupName: {
        initValue: "",
        editValue: "",
      },
      // アイコン情報
      imageIcon: DefaultValues.image,
      textIcon: DefaultValues.textIcon,
      colorTextIcon: DefaultValues.textColor,
      initialValues: { ...DefaultValues },
      editRecordIconInfo: { ...DefaultValues },
      // メニューリスト
      menuList: {
        initValue: [],
        editValue: [],
      },
      // メニューリスト選択IFデータ
      selectionMenuData: null,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord", 
      "getFacilitySwitch"
    ]),
    ...mapGetters("account-edit", [
      "getAuthorizedFunctions",
      "getIsNkkAdmin"
    ]),
  },
  async created() {
    
    this.setLoadingScreenVisible(true);
    
    // メニューグループ名
    this.menuGroupName.initValue = this.menuGroupName.editValue = this.getEditRecord.name !== null ? this.getEditRecord.name : "";
    // アイコン情報
    if (this.getEditRecord.iconInfo && this.getEditRecord.iconInfo !== "{}") {
      const IconInfo = JSON.parse(this.getEditRecord.iconInfo);
      this.initialValues.function_icon = IconInfo.function_icon;
      this.imageIcon = this.initialValues.image = IconInfo.image;
      this.textIcon = this.initialValues.textIcon = IconInfo.textIcon;
      this.colorTextIcon = this.initialValues.textColor = IconInfo.textColor;
      this.editRecordIconInfo = { ...this.initialValues };
    }
    // メニューグループ
    if (this.getEditRecord.menuList) {
      const menuList = JSON.parse(this.getEditRecord.menuList);
      this.menuList.initValue = this.menuList.editValue = menuList;
    }

    // 選択IF用データ生成
    const itemList = await this.generateItemList();
    const defaultSelection = this.generateDefaultSelectionList(itemList);
    this.selectionMenuData = {
      itemList: itemList,
      defaultSelection: defaultSelection,
    };
    
    // モーダル画面の高さ調整
    this.calculateGridHeight();
    
    this.setLoadingScreenVisible(false);
  },
  mounted() {
    window.addEventListener("resize", this.calculateGridHeight, false);
    this.previewImages();
    this.emitNotChangedState(true);
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.calculateGridHeight, false);
  },
  watch: {
    textIcon() {
      this.updateImage();
    },
    colorTextIcon() {
      this.updateImage();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    
    /**
     * 選択メニューリスト生成
     * - 施設マスタから許可された機能のみリストに追加
     */
    async generateItemList() {
      try {
        // sys_function、mst_facility取得
        const [sysResponse, facilityResponse] = await Promise.all([
          ApiHelper.get(uriFunctionAll),
          ApiHelper.get(uriFunctionFacility + this.getFacilitySwitch)
        ]);
        const sysFunctions = sysResponse.data;
      
        // 施設マスタから許可された機能リストに追加
        const authFuncFacilityjson = JSON.parse(facilityResponse.data.useFunction);
        const itemList = [];
      
        authFuncFacilityjson.func_cds.forEach(({ func_cd }) => {
          const editFuncInfo = sysFunctions.find(item => item.functionCd === func_cd);
          if (editFuncInfo) {
            itemList.push({
              code: `${editFuncInfo.functionCd}`,
              label: `${editFuncInfo.functionName}`
            });
          }
        });
      
        // 「デバイスエッジ稼働監視」機能（FUNC_DEVICE_EDGE_OPERATION）の表示は、管理者のみ
        itemList.splice(0, itemList.length, ...itemList.filter(i =>
          i.code !== FUNC_DEVICE_EDGE_OPERATION || this.getIsNkkAdmin
        ));
      
        // 外部リンク登録マスタの取得
        const mstUrlLink = await getMstUrlLinkRegister(this.getFacilitySwitch);
        mstUrlLink.forEach(({ urlCd, functionName }) => {
          itemList.push({
            code: `url-${urlCd}`,
            label: functionName
          });
        });
      
        // メニューバー設定で指定された順番に並べ替え
        itemList.forEach(menuItem => {
          menuItem.order = this.getAuthorizedFunctions.indexOf(menuItem.code);
          if (menuItem.order < 0) {
            menuItem.order = Number.MAX_VALUE;
          }
        });
        itemList.sort((a, b) => a.order - b.order);
        
        return createItemListData(itemList, "code", "label");
        
      } catch (error) {
        getErrorMessage("MstUserFunctionModal.vue", "generateItemList", error);
        throw error;
      }
    },
    /**
     * 選択済メニューリスト生成
     */
    generateDefaultSelectionList(itemList) {
      const defaultSelectionList = this.menuList.editValue.map(value => {
        const itemFunction = itemList.find(item => item.cd === value);
        if (itemFunction) {
          return {
            code: itemFunction.cd,
            label: itemFunction.name
          };
        }
        return null;
      }).filter(item => item !== null);
      
      // this.menuList.editValue、initValue から 施設マスタで使用許可されていないメニューを削除
      this.menuList.editValue = this.menuList.editValue.filter(value =>
        defaultSelectionList.some(item => item.code === value)
      );
      this.menuList.initValue = this.menuList.initValue.filter(value =>
        defaultSelectionList.some(item => item.code === value)
      );

      return createItemListData(defaultSelectionList, "code", "label");      
    },
    /**
     * モーダル画面の高さ調整
     */
    calculateGridHeight(){
      const newHeight = document.getElementsByClassName("modal-body")[0].clientHeight - document.getElementsByClassName("upper")[0].clientHeight - 45;
      document.getElementsByClassName("select-area")[0].style.height = newHeight + "px"
    },

    // 未編集状態を送信する
    // （確定ボタンのdisabled状態や破棄確認の有無に反映される）
    emitNotChangedState(state) {
      EventBus.$emit("mstHolidayRegistered", state);
    },
    onNameChange() {
      this.menuGroupName.editValue = this.menuGroupName.editValue !== null ? this.menuGroupName.editValue : "";
      this.updateEditRecord("name", this.menuGroupName);
    },    
    setEditRecordIconInfo() {
      const IconInfoObj = this.editRecordIconInfo = {
        function_icon: this.$refs.canvasIcon.toDataURL(),
        image: this.imageIcon,
        textIcon: this.textIcon,
        textColor: this.colorTextIcon
      };
      this.updateEditRecord("iconInfo", IconInfoObj);
    },
    updateEditRecord(key, value) {
      let isNotChanged = false;
      if (key === "iconInfo") {
        // アイコン情報
        isNotChanged = Object.keys(value).every(
          key => value[key] === this.initialValues[key]
        );
        this.getEditRecord[key] = JSON.stringify(value);
      } else if (key === "menuList") {
        // メニューリスト
        isNotChanged = JSON.stringify(value) === JSON.stringify(this.menuList.initValue);
        this.getEditRecord[key] = JSON.stringify(value);
      } else {
        // メニューグループ名
        isNotChanged = value.initValue === value.editValue;
        this.getEditRecord[key] = value.editValue;
      }
      // 確定ボタンの活性or非活性
      this.emitNotChangedState(isNotChanged);
      
      // 編集レコード更新
      this.setEditRecord(this.getEditRecord);
    },
    /**
     * 入力チェック
     */
    validateData() {
      // メニューグループ名
      const name = this.menuGroupName.editValue;
      return {
        nameValid: name !== null && name !== "", // メニューグループ名：必須チェック
        iconValid: this.imageIcon !== "" || this.textIcon !== "", // アイコン画像、アイコン内文字列：いずれか必須 
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        // 全てチェックOK
        return true;
      }
      
      const message = `
          ${
            !validationResult.nameValid
              ? messageFormat(messageFormat(DIALOG_MESSAGES["00200162"].message, "メニューグループ名", "メニューグループ名"))
              : ""
          }
          ${
            !validationResult.iconValid
              ? messageFormat(DIALOG_MESSAGES["00200162"].message, "アイコン画像またはアイコン文字列", "画像または文字")
              : ""
          }
        `;

      if(!validationResult.nameValid) {
        document.getElementsByClassName("custom-input-required")[0]?.classList?.add("custom-input-invalid");
      }
      // ダイアログ表示
      this.$ons.notification.alert({
        title: DIALOG_MESSAGES["00200162"].title,
        message: message
      });
      return false;
    },
    // メニューグループ名称のエラースタイルを解除する
    warningCancel() {
      document.getElementsByClassName("custom-input-required")[0].classList.remove("custom-input-invalid");
    },
    /**
     * @description 選択されたメニューを編集レコードに設定する
     * @param {Array} selectedMenuList 選択されたメニューのリスト
     */
    setMenuList(selectionList) { 
      const selectionFunctionCdList = selectionList.map(item => item.cd);
      this.updateEditRecord("menuList", selectionFunctionCdList);
    },  
    
    /**
     * アイコン プレビュー表示
     * @param {*} isUploadImage 
     */
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
    /**
     * 参照ボタン押下時
     */
    selectImage() {
      this.$refs.inputFile.click();
    },
    /**
     * 参照による画像選択時
     */
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
      this.setEditRecordIconInfo();
    },
    /**
     * アイコン画像 更新
     */
    async updateImage() {
      if (
        (this.textIcon === this.editRecordIconInfo.textIcon)
        && (this.colorTextIcon === this.editRecordIconInfo.textColor)
      ) {
        return;
      }
      await this.previewImages();
      this.setEditRecordIconInfo();
    },  
  }
};
</script>

<style scoped>
.main-contain {
  padding: 20px;
  box-sizing: border-box;
  max-height: 100%;
  overflow-y: auto;
}
.item-input {
  flex: 0 0 78%;
}
.item-row {
  margin-top: 15px;
}
.item-title {
  min-width: 200px;
  max-width: 20%;
  margin-left: 5px;
  align-content: center;
}
.item-title-icon{
  min-width: 200px;
  max-width: 20%;
  margin-left: 5px;
}
.item-data {
  padding: 3px;
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
.style-color-picker {
  width: 30px;
}
.custom-main-contain .ntss-text-icon {
  font-size: unset;
}
.custom-input {
  min-width: 200px !important;
  max-width: 100% !important;
}
.item-row >>> .multi-select-list {
  height: 45vh;  
}
</style>
