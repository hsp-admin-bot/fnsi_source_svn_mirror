<template>
  <div class="main-area">
    <div class="disp-item-area wrap-block">
      <v-ons-button class="btn3-normal button-add" @click="addRow()">フィールド追加</v-ons-button>
    </div>
    <div class="disp-item-content-frame print-height-auto" :style="heightStyles">
      <div class="disp-item-content-area">
        <table class="graph-list">
          <thead class="graph-list-thead">
            <tr>
              <th class="graph-list-th-del">削除</th>
              <th class="graph-list-th-drag"></th>
              <th class="graph-list-th-check">デフォルト</th>
              <th class="graph-list-th-result">結果文字列初期値</th>
            </tr>
          </thead>
          <draggable
            v-model="inputModel"
            animation="250"
            handle=".drag-handle"
            :forceFallback="true"
            @change="onDragOver"
          >
            <tr v-for="(item, index) in inputModel" :index="index" :key="item.code" class="drag-item">
              <!-- 削除 -->
              <td class="graph-list-td-del">
                <ons-toolbar-button class="close-btn manual-close-btn" @click="deleteRow(index)">
                  <ons-icon icon="fa-times"></ons-icon>
                </ons-toolbar-button>
              </td>
              <!-- ドラッグオーバー -->
              <td class="graph-list-td-drag drag-handle">
                <ons-toolbar-button>
                  <ons-icon icon="fa-sort"></ons-icon>
                </ons-toolbar-button>
              </td>
              <!-- デフォルトチェック -->
              <td class="graph-list-td-check">
                <v-ons-radio v-model="item.is_checked" :input-id="'check_' + index" :value="'1'" modifier="round" @change="onChecked($event, index)" />
              </td>
              <!-- 結果文字列初期値 -->
              <td class="graph-list-td-result">
                <input type="text" :value="item.text" style="width: 100%;" @focus="onTextFocus($event)" @change="onTextChange($event, index)" @blur="onTextBlur($event, item.id)"/>
              </td>
            </tr>
          </draggable>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import {EventBus} from "@/compat/vue/event-bus.js";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import { getModalContainerElement, getScopedElement } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "MstTrendGraphTemplateModal",
  components: {
    "draggable": VueDraggable
  },
  data() {
    return {
      inputModel: [],
      //mod マスタ詳細画面がありません破棄メッセージ
      initInputModel:[],
      temporaryItemList: [],
      contentsAreaHeight: 500,
      //add 端末判別 鞠 start
      androidFlg: false,
      iosFlg: false,
      //add 端末判別 鞠 end
    };
  },

  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    //add 字体の変更後に余白 鞠 start
    ...mapGetters("account-edit", {getFontSize: "getFontSize"}),
    //add 字体の変更後に余白 鞠 end
    /**
     * コンテンツの高さをCSS変数を利用して書き換える
     */
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
  },
  watch: {
    /**
     * ウィンドウサイズが変更された時の処理.
     */
    windowHeight() {
      this.calculateGridHeight();
    },
    //add 字体の変更後に余白 鞠 start
    getFontSize() {
      this.calculateGridHeight();
    }
    //add 字体の変更後に余白 鞠 end
  },
  async mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },
  created() {
    this.setLoadingScreenVisible(true);
    const initialString = this.getValueByField("initialString")
    if (initialString && initialString != "") {
      const initialStringJson = this.getInitialStringJson(initialString);
      if (typeof initialStringJson == "object" && initialStringJson.length > 0) {
        this.inputModel = initialStringJson
      }
    }
    //mod マスタ詳細画面がありません破棄メッセージ
    this.initInputModel = JSON.parse(JSON.stringify(this.inputModel));
    // 端末判別 5121add 鞠 start
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
    // add 鞠 end
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    /**
     * フィールド追加ボタンクリックイベント
     */
    addRow() {
      // 行の作成
      const item = this.createInputItem();
      // 行の追加
      this.inputModel.push(item);
      // 「確定ボタン」の活性化
      if (JSON.stringify(this.initInputModel) !== JSON.stringify(this.inputModel)) {
        EventBus.$emit("mstHolidayRegistered", false);
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
      // heightの計算
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    /**
     * 行の作成
     */
    createInputItem() {
      // 既存行無の場合
      if (this.inputModel.length === 0) {
        // 行(チェック有)の作成
        return { id: this.inputModel.length, text: "", checked: true, is_checked: "1", isDefault: false };
      } else {
        // 行(チェック無)の作成
        return { id: this.inputModel.length, text: "", checked: false, is_checked: "0", isDefault: false };
      }
    },
    /**
     * Gridの高さを調整する
     */
    calculateGridHeight() {
      const modal = getModalContainerElement(this.$el || this);
      const modalHeight = modal.clientHeight;
      const modalHeaderHeight = modal.firstElementChild.clientHeight;
      const modalFooterHeight = modal.lastElementChild.clientHeight;
      const contentsHeight1 = getScopedElement(this.$el || this, ".disp-item-area")?.clientHeight || 0;
      this.contentsAreaHeight =
        modalHeight -
        modalHeaderHeight -
        modalFooterHeight -
        contentsHeight1 -
        60;
      //端末判別 5121add 鞠 start
      if (this.androidFlg ===true) {
        switch (parseInt(this.getFontSize) ) {
          case 2:
            this.contentsAreaHeight -= 2;
            break;
          case 3:
            this.contentsAreaHeight -= 3.5;
            break;
        }
      }
      //端末判別 5121add 鞠 end

    },
    /**
     * フィールド削除ボタンクリックイベント
     */
    deleteRow(index) {
      // 行の削除
      this.inputModel.splice(index, 1);
      // 既存行有の場合
      if (this.inputModel.length > 0) {
        // デフォルトチェック有無の取得
        const checkedItem = this.inputModel.filter(item => item.checked === true);
        // デフォルトチェック無の場合
        if (checkedItem.length === 0) {
          // 先頭行へ
          this.inputModel[0].checked = true;
          this.inputModel[0].is_checked = "1";
        }
      }
      // 「確定ボタン」の活性化
      if (JSON.stringify(this.initInputModel) !== JSON.stringify(this.inputModel)) {
        EventBus.$emit("mstHolidayRegistered", false);
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },
    // テキストのフォーカス
    onTextFocus(event) {
      // 編集済
      event.target?.classList?.add("custom-input-edited");
    },
    // テキストの変更
    onTextChange(event, index) {
      this.inputModel[index].text = event.target.value;
      //mod マスタ詳細画面がありません破棄メッセージ
      if (JSON.stringify(this.initInputModel)!==JSON.stringify(this.inputModel)) {
        EventBus.$emit("mstHolidayRegistered", false);
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }

    },
    // テキストのフォーカスアウト
    onTextBlur(event, id) {
      // 初期値 ≠ "NULL"の場合
      if (this.initInputModel[id] != null) {
        // 初期値 ≠ 編集値の場合
        if (this.initInputModel[id].text !== event.target.value) {
          // 編集済
          event.currentTarget?.classList?.add("custom-input-edited");
        } else {
          // 未編集
          event.currentTarget.classList.remove("custom-input-edited");
        }
      } else {
        // 初期値 ≠ 編集値の場合
        if ("" !== event.target.value) {
          // 編集済
          event.currentTarget?.classList?.add("custom-input-edited");
        } else {
          // 未編集
          event.currentTarget.classList.remove("custom-input-edited");
        }
      }
    },
    // デフォルトチェックの変更
    onChecked(event, index) {
      // 初期化処理
      const checkedItem = this.inputModel.filter(item => item.checked === true);
      checkedItem.forEach(item => {
        item.checked = false;
        item.is_checked = "0";
      });
      // v-modelの更新
      this.inputModel[index].checked = event.target.checked;
      this.inputModel[index].is_checked = event.target.value;
      // 「確定ボタン」の活性化
      if (JSON.stringify(this.initInputModel) !== JSON.stringify(this.inputModel)) {
        EventBus.$emit("mstHolidayRegistered", false);
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },
    // ドラッグオーバー
    onDragOver() {
      // 「確定ボタン」の活性化
      if (JSON.stringify(this.initInputModel) !== JSON.stringify(this.inputModel)) {
        EventBus.$emit("mstHolidayRegistered", false);
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },
    // (初期文字列)JSONの取得
    getInitialStringJson(initialString) {
      const initialStringJson = [];
      const json = JSON.parse(initialString);
      for (let i = 0; i < json.length; i++) {
        const item = json[i];
        initialStringJson.push({ id: i, text: item.text, checked: item.checked, is_checked: item.checked ? "1" : "0", isDefault: item.isDefault });
      }
      return initialStringJson;
    },
    /**
     * 入力データの検証
     */
    validateData() {
      let textValid = true
      let checkValid = true
      this.temporaryItemList = this.inputModel
      checkValid = this.inputModel.filter(item => item.checked === true).length <= 1;

      return {
        textValid: textValid,
        checkValid: checkValid
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();

      if (Object.values(validationResult).every(v => v === true)) {
        this.inputModel.forEach(item => {
          delete item.id;
          delete item.is_checked;
        });
        this.updateEditRecord(
          "initialString",
          JSON.stringify(this.inputModel)
        );
        return true;
      }

      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000007].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.textValid
              // add 全マスタメッセージ調整 王 start
              // ? "結果文字列初期値を入力する必要があります。<br>"
              ? DIALOG_MESSAGES[12000007].message + "<br>"
              // add 全マスタメッセージ調整 王 end
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      this.inputModel = this.temporaryItemList;
      return false;
    }
  }
};
</script>

<style scoped>
@media print{
  .disp-item-content-frame{
    height: auto !important;
  }
}
.disp-item-content-area {
  overflow: auto;
  height: 100%;
}

.disp-item-area {
  width: 100%;
  border-collapse: collapse;
}
.disp-item-area tr {
  height: 30px;
}

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr td{
  text-align: left;
}

.disp-item-content-frame {
  width: 100%;
  box-sizing: border-box;
  position: relative;
}
/* ラベル */
.item-title {
  position: relative;
  padding-left: 5px;
  width: 8em;
  min-width: 100px;
}
/* 削除ボタン */
.button-delete {
  position: absolute;
  top: 0;
  right: 0;
  height: 100%;
}
/* 追加ボタン */
.button-add {
  position: relative;
  bottom: 5px;
  width: 180px;
  margin-left: auto;
  font-size: 1em;
}

/* 横並び */
.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.disp-item-content-area table th {
  background-image: none !important;
}
/* テーブル */
.graph-list {
  width: 100%;
}
.graph-list-thead {
  display: block;
}
.graph-list-th-del {
  width: 2em;
  min-width: 2em;
  font-weight: unset;
  text-align: center;
}
.graph-list-th-drag {
  width: 2em;
  min-width: 2em;
  font-weight: unset;
  text-align: center;
}
.graph-list-th-check {
  width: 6em;
  min-width: 6em;
  font-weight: unset;
  text-align: center;
}
.graph-list-th-result {
  width: 100%;
  min-width: 10em;
  font-weight: unset;
  text-align: center;
}
.graph-list-td-del {
  width: 2em;
  min-width: 2em;
  padding-bottom: 3px;
  text-align: center;
}
.graph-list-td-drag {
  width: 2em;
  min-width: 2em;
  padding-bottom: 3px;
  text-align: center;
}
.graph-list-td-check {
  width: 6em;
  min-width: 6em;
  padding-bottom: 3px;
  text-align: center;
}
.graph-list-td-result {
  width: 100%;
  min-width: 10em;
  padding-bottom: 3px;
  text-align: left;
}
/* ドラッグオーバー */
.drag-item {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  flex-wrap: nowrap;
  width: 100%;
}
/* 編集済状態 */
.custom-input-edited {
  border: 2px #008000 solid !important;
  color: #1f1f21 !important;
  outline: 0 !important;
}
</style>
