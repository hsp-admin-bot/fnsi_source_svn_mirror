/**
 * 測定チェックマスタ編集tab画面
 */
<template>
  <div class="disp-item-list" :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
    <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style">
      <div class="header-btn-area right" ref="headerBtnArea">
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          style="float: left;"
          v-show="true"
          @click="addRow()"
        >追加</v-ons-button>
      </div>
      <kendo-grid
        ref="grid"
        id="check-grid"
        :class="fontSizeSet"
        :data-source="dispCheckSetting"
        :editable="true"
        :selectable="true"
        :reorderable="false"
        :height="kendoGridHeight"
        :scrollable="true"
        :beforeEdit="editStart"
        :cellClose="editEnd"
        :edit="addInputAssist"
        @save="onSave"
      >
        <template v-for="(column, index) in dispColumns">
          <kendo-grid-column
            v-if="column.field === 'delBtn'"
            :key="index"
            :title="column.title"
            :field="column.field"
            :hidden="column.hidden"
            :editable="column.editable"
            :template="column.template"
            :width="column.width"
            :format="column.format"
            :values="column.values"
            :attributes="{ class: 'text-align: center;' }"
            :command="{
              name: 'customDelete',
              text: '',
              iconClass: 'fa fa-trash',
              click: deleteRow
            }"
          ></kendo-grid-column>
          <kendo-grid-column
            v-else-if="column.field === 'modal'"
            :key="index"
            :title="column.title"
            :field="column.field"
            :hidden="column.hidden"
            :editable="column.editable"
            :template="column.template"
            :width="column.width"
            :format="column.format"
            :values="column.values"
            :attributes="{ class: 'btn3-kendo-normal' }"
            :command="{ text: '詳細', click: showCheckEditModal }"
          ></kendo-grid-column>
          <kendo-grid-column
            v-else
            :key="index"
            :title="column.title"
            :field="column.field"
            :hidden="column.hidden"
            :editable="column.editable"
            :template="column.template"
            :width="column.width"
            :format="column.format"
            :values="column.values"
          ></kendo-grid-column>
        </template>
      </kendo-grid>
    </kendo-grid-toolbar>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";

export default {
  mixins: [MasterMaintenanceMixin],
  data() {
    return {
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      columns: [],
      editCheckContent: "",
      kendoGridHeight: 300,
      gridData: [],
      //Android端末で編集中であることを示すフラグ
      isAndroid: false,
      isIOS: false,
      savedScrollTop: 0,
      savedScrollLeft: 0
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-weight/check", {
      getColumns: "getColumns",
      getCurrentData: "getCurrentData",
      getSettingDataCheck: "getSettingDataCheck"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("mst-weight", {
      getIsGridEditing: "getIsGridEditing"
    }),
    dispColumns() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });

      return this.getColumns;
    },
    dispCheckSetting() {
      return this.getSettingDataCheck;
    },
    ntssListStyles() {
      return { display: "inherit", fontSize: "1em" };
    },
    getGridData() {
      return this.gridData;
    }
  },
  methods: {
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    ...mapActions("multi-modal", ["showMstWeightCheckEdit"]),
    ...mapActions("mst-weight/check", [
      "clearData",
      "setSettingData",
      "setCurrentRowData",
      "setCurrentData",
      "setCurrentNewRowData"
    ]),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    // 測定値チェックグリッドクリック時
    showCheckEditModal(e) {
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));

      // ストアに保存する。
      this.setCurrentRowData(selectedRowItem.toJSON());
      // 測定チェック設定画面表示
      this.showModal();
    },
    // 測定値チェック新規登録
    addRow() {
      const gridElement = this.$refs.grid.$el;
      this.savedScrollTop = gridElement.querySelector('.k-grid-content').scrollTop;
      this.setCurrentNewRowData();
      // 測定チェック設定画面表示
      this.showModal();
    },
    showModal() {
      // モーダル表示
      this.showMstWeightCheckEdit();
    },
    onSave(ev) {
      this.setIsGridEditing(false);
      /** Grid内のデータを変更した際の処理 */

      // 編集内容取得
      const editRowInfo = ev.model;
      const editId = editRowInfo.ctl_no;
      const editObject = ev.values;
      const editKey = Object.keys(editObject)[0];

      // 現在の表示データ取得
      let currentData = this.getSettingDataCheck;

      // 編集箇所判定
      // 表示項目選択コンボボックス以外の場合
      const editValue = editObject[editKey];
      currentData.forEach(data => {
        if (data.ctl_no == editId) {
          data[editKey] = editValue;
        }
      });

      if (editKey == "disp_order") {
        // 表示順が変更された場合表示データをソートする
        currentData = this.sortDispDataByDispOrder(currentData);
      }

      // カレントデータ更新
      this.setCurrentData(currentData);

      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
      // DB登録時に使用されるストアの情報を更新
      this.applyCheckConfigEdit();
    },
    /**
     * 行を削除する
     */
    deleteRow(ev) {
      const gridElement = this.$refs.grid.$el;
      this.savedScrollTop = gridElement.querySelector('.k-grid-content').scrollTop;
      this.savedScrollLeft = gridElement.querySelector('.k-grid-content').scrollLeft;
      // ボタンを押した行のデータを取得する
      ev.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const rowData = row.dataItem(ev.currentTarget.closest("tr"));
      // 選択された行のデータのデータに付与しているidを取得
      const selectedDataId = rowData.ctl_no;

      // カレントデータ取得
      const currentData = this.getSettingDataCheck;

      // カレントデータから対象のidのデータを削除
      const newCurrentData = currentData.filter(
        data => data.ctl_no !== selectedDataId
      );

      // カレントデータ更新
      this.setCurrentData(newCurrentData);

      // DB登録時に使用されるストアの情報を更新
      this.applyCheckConfigEdit();
    },
    createEditedRecord() {
      // 現在の設定値を文字列化して登録用データ作成
      this.editCheckContent = JSON.stringify(this.getSettingDataCheck);
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        let gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.classList === undefined) {
          gridHeader = this.$refs.grid.$el.firstElementChild;
        }
        gridHeader?.classList?.add("master-grid-header");
        //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 start
        this.changeHeaderAndContentWidth()
        //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 end
        const gridElement = this.$refs.grid.$el;
        gridElement.querySelector('.k-grid-content').scrollTop = this.savedScrollTop;
        gridElement.querySelector('.k-grid-content').scrollLeft = this.savedScrollLeft;
      });
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.getIsGridEditing) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .pop().offsetHeight;
        const th = Array.prototype.slice
          .call(document.getElementsByClassName("tab_item"))
          .shift().offsetHeight;
        const fmh =
          this.isDispMenu === 1
            ? document.getElementById("footer-menu").offsetHeight
            : 0;
        const gfh = document.getElementById("detail-footer").offsetHeight;
        const headerBtnAreaHeight = this.$refs.headerBtnArea.offsetHeight;

        // kendoGridの高さ設定(ウィンドウ高さ－ヘッダー高さ－タブ高さ－追加ボタンエリア高さ－メニューバー高さ－確定/キャンセルボタンエリア高さ)
        this.kendoGridHeight = wh - hh - th - headerBtnAreaHeight - fmh - gfh;

        // kendoGridのheader行高とbody行高を取得(ただし、body行高が行毎に可変の場合は対応できない。あくまで目安高。)
        const firstTh = this.$el.querySelector('.k-grid-header tr');
        const thHeight = firstTh ? firstTh.offsetHeight : 0;
        const firstTd = this.$el.querySelector('.k-grid-content tr');
        const tdHeight = firstTd ? firstTd.offsetHeight : 0;
        // kendoGrid最低5行分の高さ(header高さ＋5行分の高さ＋横スクロールの高さ目安17px)
        const gridMinHeight = thHeight + (tdHeight * 5) + 17;

        // kendoGridの高さが最低5行分より小さいか(ウィンドウ高が極端に小さい時や文字サイズ特大の場合等に起こりえる)
        if (this.kendoGridHeight < gridMinHeight) {
          // 最低5行表示されるよう5行分の高さをkendoGridの高さに設定
          this.kendoGridHeight = gridMinHeight;
        }
      }
    },
    //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 start
    changeHeaderAndContentWidth() {
      let colHeader = document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[0].children[0].children[0]
      let colContent = document.getElementsByClassName("k-selectable")[0].children[0]
      for (let i = 0; i < colContent.children.length; i++) {
        switch (parseInt(this.getFontSize)) {
          case 0 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "64px"
              colHeader.children[i].style.width = "64px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "110px"
              colHeader.children[i].style.width = "110px"
            }
            break;
          case 1 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "65px"
              colHeader.children[i].style.width = "65px"
            }
            if (colContent.children[i].style.width == "80px") {
              colContent.children[i].style.width = "87px"
              colHeader.children[i].style.width = "87px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "124px"
              colHeader.children[i].style.width = "124px"
            }
            if (colContent.children[i].style.width == "120px") {
              colContent.children[i].style.width = "130px"
              colHeader.children[i].style.width = "130px"
            }
            break;
          case 2 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "66px"
              colHeader.children[i].style.width = "66px"
            }
            if (colContent.children[i].style.width == "80px") {
              colContent.children[i].style.width = "90px"
              colHeader.children[i].style.width = "90px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "135px"
              colHeader.children[i].style.width = "135px"
            }
            if (colContent.children[i].style.width == "120px") {
              colContent.children[i].style.width = "141px"
              colHeader.children[i].style.width = "141px"
            }
            if (colContent.children[i].style.width == "150px") {
              colContent.children[i].style.width = "158px"
              colHeader.children[i].style.width = "158px"
            }
            break;
          case 3 :
            if (colContent.children[i].style.width == "60px") {
              colContent.children[i].style.width = "69px"
              colHeader.children[i].style.width = "69px"
            }
            if (colContent.children[i].style.width == "80px") {
              colContent.children[i].style.width = "97px"
              colHeader.children[i].style.width = "97px"
            }
            if (colContent.children[i].style.width == "100px") {
              colContent.children[i].style.width = "155px"
              colHeader.children[i].style.width = "155px"
            }
            if (colContent.children[i].style.width == "120px") {
              colContent.children[i].style.width = "163px"
              colHeader.children[i].style.width = "163px"
            }
            if (colContent.children[i].style.width == "150px") {
              colContent.children[i].style.width = "182px"
              colHeader.children[i].style.width = "182px"
            }
            break;
        }
      }
    },
    //add 測定時チェックタブの表で列幅変更できないため、内容全文が確認できない 鞠 4730 end
    async editStart() {
      if (this.isAndroid) {
        await this.setIsGridEditing(true);
      }
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        if (document.getElementsByClassName("k-numerictextbox").length !== 0) {
          let spinnerObj = document.getElementsByClassName("k-numerictextbox")[0].getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    /**
     * 表示データを表示順で並べ替える
     */
    sortDispDataByDispOrder(jsonData) {
      let buf = [];
      let buf_temp = [];
      const cnt = jsonData.length;
      for (let lop = 0; lop < cnt; lop++) {
        const data = jsonData[lop];
        if (lop == 0) {
          // ループの1回目は無条件でバッファに入れる
          buf.push(data);
        } else {
          // ループの2回目以降
          let isPushed = false;
          for (let bufLop = 0; bufLop < buf.length; bufLop++) {
            const bufData = buf[bufLop];
            if (data.disp_order < bufData.disp_order && !isPushed) {
              buf_temp.push(data);
              isPushed = true;
              buf_temp.push(bufData);
            } else {
              buf_temp.push(bufData);
            }
          }
          if (buf_temp.length == buf.length) {
            buf_temp.push(data);
          }

          // 値渡し
          buf = buf_temp.slice();
          // temp初期化
          buf_temp = [];
        }
      }
      return buf;
    },
    /* ストアに登録する */
    setDispSettingData(editRecord) {
      let jsonData = { check: [] };
      // JSON文字列を管理用Index付きJSONオブジェクトに変換
      jsonData.check = JSON.parse(editRecord.checkContent);

      // JSONオブジェクトを表示順でソート
      jsonData.check = this.sortDispDataByDispOrder(jsonData.check);

      this.setSettingData(jsonData);
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    applyCheckConfigEdit() {
      this.createEditedRecord();
      this.updateEditRecord("checkContent", this.editCheckContent);
    },
    updateWidget() {
      this.$nextTick(() => {
        this.calculateGridHeight();
        this.$refs.grid.updateWidget();
        this.editBackgroundColor();
      });
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
  },
  created() {
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    EventBus.$on("applyCheckConfigEdit", this.applyCheckConfigEdit);
    // 親画面から装置設定JSONデータ取得
    this.editCheckContent = this.editRecord.checkContent;
    this.setDispSettingData(this.editRecord);
  },
  mounted() {
    // Gridの高さを調整する
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("applyCheckConfigEdit", this.applyCheckConfigEdit);
  },
  // add 性能改善メモリ不足 shan end
  destroyed() {
    this.clearData();

  }
};
</script>
<style scoped>
/* グリッドのスタイル */
#check-grid {
  margin: 0; /* ライブラリのスタイル打消し */
}
.disp-item-list {
  border-collapse: collapse;
  margin: 0 auto;
  font-size: 1.5em;
  background-color: var(--ntss-list-header-backgroud-color);
}
.right {
  text-align: right;
}
.header-btn-area {
  height: 2em;
  padding: 0.3em 0 0.1em; /* 他タブとボタンの位置合わせ */
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0; /* ライブラリのスタイル打消し */
}
</style>
