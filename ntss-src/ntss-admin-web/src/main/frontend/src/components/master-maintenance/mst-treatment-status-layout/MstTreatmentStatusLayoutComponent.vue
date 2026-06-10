<template>
  <div class="main-area">
    <div class="tabs">
      <input id="dcs" type="radio" name="tab_item" checked @click="changeTabSelect(1)" />
      <label class="tab_item" for="dcs">透析装置</label>
      <input id="dab" type="radio" name="tab_item" @click="changeTabSelect(2)" />
      <label class="tab_item" for="dab">供給装置</label>
      <input id="dad" type="radio" name="tab_item" @click="changeTabSelect(3)" />
      <label class="tab_item" for="dad">溶解装置</label>
      <input id="dro" type="radio" name="tab_item" @click="changeTabSelect(4)" />
      <label class="tab_item" for="dro">ＲＯ装置</label>
    </div>
    <div class="disp-item-list" :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div v-show="popoverVisible" id="item-box-list" :style="addListHeightStyles">
          <p id="select-text">表示項目を選択してください:</p>
            <div class="selected-list flex-1 d-flex">
              <div class="selected-item-list flex-1">
                <div class="list-wrapper">
                  <div
                    :class="[
                      'display-list',
                      { selected: selectedSelection.includes(option.value) }
                    ]"
                    v-for="(option, index) in multiSelectList"
                    :key="option.length"
                    :value="option.value"
                    @click.exact="singleSelect(index, option.value)"
                    @click.shift.exact="rangeSelect(index)"
                  >{{ option.text }}
                  </div>
                </div>
              </div>
            </div>
        </div>
        <div v-show="popoverVisible" id="item-box-conf">
          <div id="list-footer">
            <div class="dialog-cancel">
              <ons-button class="nik-btn cancel btn2-cancel" style="color: white" @click="selectCancel">キャンセル</ons-button>
            </div>
            <div class="dialog-conf">
              <ons-button class="nik-btn save btn1-execute" @click="addMultiSelect">確定</ons-button>
            </div>
          </div>
        </div>
        <div v-show="gridVisible">
        <div class="header-btn-area right">
          <v-ons-button
            modifier="outline"
            class="toolbar-btn btn3-normal"
            style="float: left; margin-right: 10px;"
            v-show="true"
            @click="addRow()"
          >追加</v-ons-button>
          <div v-show="isMobileDevice" class="custom-switch-wrapper">
            <label class="fab-font-color">編集</label>
            <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
          </div>
        </div>
        <kendo-grid
          id="grid-font-size"
          ref="grid"
          :class="fontSizeSet"
          :style="ntssListStyles"
          :data-source="dispMachineSetting"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :height="kendoGridHeight"
          :scrollable="true"
          :resizable="true"
          :beforeEdit="editStart"
          :cellClose="editEnd"
          :edit="addInputAssist"
          @save="onSave"
          @databound="onDataBoundKendoGrid"
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
              :minResizableWidth="column.width"
              :format="column.format"
              :values="column.values"
              :attributes="{ style: 'text-align: center;' }"
              :command="{
                name: 'customDelete',
                text: '',
                iconClass: 'fa fa-trash',
                click: deleteRow
              }"
            ></kendo-grid-column>
            <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
<!--        mod 治療状況レイ・アウトマスタ詳細画面における複数の削除列 2023/06/06 ztc start-->
            <kendo-grid-column
              v-else-if="column.field === 'width' || column.field === 'order_no'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :template="column.template"
              :width="column.width"
              :minResizableWidth="column.width"
              :format="column.format"
              :values="column.values"
              @editor="numericEditor"
            ></kendo-grid-column>
<!--         mod 治療状況レイ・アウトマスタ詳細画面における複数の削除列 2023/06/06 ztc start-->
            <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end -->
            <kendo-grid-column
              v-else
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :template="column.template"
              :width="column.width"
              :minResizableWidth="column.width"
              :format="column.format"
              :values="column.values"
            ></kendo-grid-column>
          </template>
        </kendo-grid>
        </div>
      </kendo-grid-toolbar>
    </div>
  </div>
</template>

<script>
import Kendo from "@progress/kendo-ui";
import { mapGetters, mapActions } from "vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import {EventBus} from "@/eventBus";
// add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
import $ from "jquery";
// add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end

/**
 * @description 治療状況レイアウトマスタの装置設定用モーダルコンポーネント
 */
export default {
  mixins: [MasterMaintenanceMixin],
  data() {
    return {
      condition: {
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      isSorted: false,
      dummyDivHeight: 40,
      kendoGridToolbarHeight: 500,
      addListHeight: 400,
      kendoGridHeight: 300,
      kendoGridMinHeight: 300,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      editRecordOnComponent: [],
      refDispItemList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      isAndroid: false,
      isIOS: false,
      popoverVisible: false,
      gridVisible: true,
      multiSelectList: [],
      allMultiSelectList: [],
      selectedSelection: [],
      singleIndex: "",
      groupIndex: [],
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },

  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("master-maintenance", ["getEditRecord"]),
    ...mapGetters("mst-treatment-status-layout", [
      "getSettingDataDcs",
      "getSettingDataDab",
      "getSettingDataDad",
      "getSettingDataDro",
      "getCurrentData",
      "getTabSelectedId",
      "getColumns",
      "getSelectedIndex"
    ]),
    dispMachineSetting() {
      const currentData = this.getCurrentData;
      return new Kendo.data.DataSource({
        data: currentData,
        schema: {
          model: {
            fields: {
              order_no: {
                type: "number",
                // mod redmine 4660 治療状況レイアウトマスタの並び順で1行目に並び替えできない 孔 start
                // validation: { max: 30, min: 1 }
                // #11047 ⑥治療状況レイアウトマスタ＞詳細 全タブ　表示順　入力範囲が不正　30では足りない。 linjunfeng start
                // validation: { max: 30, min: 0 }
                validation: { min: 0 }
                // #11047 ⑥治療状況レイアウトマスタ＞詳細 全タブ　表示順　入力範囲が不正　30では足りない。 linjunfeng  end
                // mod redmine 4660 治療状況レイアウトマスタの並び順で1行目に並び替えできない 孔 end
              },
              width: {
                type: "number",
                validation: { max: 30, min: 1 }
              }
            }
          }
        }
      });
    },
    dispColumns() {
      return this.getColumns;
    },
    tabSelectedId() {
      return this.getTabSelectedId;
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    addListHeightStyles() {
      // main部の高さをCSS変数を利用して書き換え：装置表示項目リスト画面
      return { "--height": `${this.addListHeight}px` };
    },
    ntssListStyles() {
      return { display: "inherit" };
      // return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
    },
  },
  methods: {
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    ...mapActions("mst-treatment-status-layout", [
      "setSettingData",
      "changeCurrentData",
      "setCurrentData",
      "fetchDispItemList",
      "setColumnDispItemList",
      "remountCurrentData",
      "clearData",
      "setComboItemList_Act"
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    singleSelect(index, values) {
      this.selectedSelection.includes(values)
        ? this.selectedSelection.splice(
            this.selectedSelection.indexOf(values),
            1
          )
        : this.selectedSelection.push(values); this.singleIndex = index;
    },
    rangeSelect(index) {
      const firstIndex = this.singleIndex;
      this.groupIndex = [];
      if(index < firstIndex){
        this.groupIndex = Array.from(
          { length: firstIndex - index + 1},
          (v, i) => i + index
        );
      } else {
        this.groupIndex = Array.from(
          { length: index - firstIndex + 1},
          (v, i) => i + firstIndex
        );
      }

      const allList = this.multiSelectList;
      for (let l = 0; l < this.groupIndex.length; l++) {
        let shiftItem = this.groupIndex[l];
        let shiftValue = allList[shiftItem].value;
        // 存在しない場合、配列にpushする
        if(this.selectedSelection.indexOf(shiftValue) == -1) {
          this.selectedSelection.push(shiftValue);
        }
      }
    },
    /**
     * タブ切り替え時、表示内容を切り替える
     */
    changeTabSelect(selectedId) {
      const currentId = this.tabSelectedId;
      this.selectedSelection = [];
      // 選択中のタブがクリックされた場合は処理しない
      if (selectedId != currentId) {
        // 表示データの切り替え
        this.changeCurrentData(selectedId);
        switch (selectedId) {
        case 1:
          this.multiSelectList = this.allMultiSelectList.DCS;
          break;
        case 2:
          this.multiSelectList = this.allMultiSelectList.DAB;
          break;
        case 3:
          this.multiSelectList = this.allMultiSelectList.DAD;
          break;
        case 4:
          this.multiSelectList = this.allMultiSelectList.DRO;
          break;
        }
      }
    },
    /* ストアに登録する */
    setDispSettingData(editRecord) {
      let jsonData = {};
      // JSON文字列を管理用Index付きJSONオブジェクトに変換
      jsonData.dcs = this.createDispJson(editRecord.dcsViewItems);
      jsonData.dab = this.createDispJson(editRecord.dabViewItems);
      jsonData.dad = this.createDispJson(editRecord.dadViewItems);
      jsonData.dro = this.createDispJson(editRecord.droViewItems);

      // JSONオブジェクトを表示順でソート
      jsonData.dcs = this.sortDispDataByDispOrder(jsonData.dcs);
      jsonData.dab = this.sortDispDataByDispOrder(jsonData.dab);
      jsonData.dad = this.sortDispDataByDispOrder(jsonData.dad);
      jsonData.dro = this.sortDispDataByDispOrder(jsonData.dro);

      this.setSettingData(jsonData);
    },
    /**
     * 表示データを表示順で並べ替える
     */
    sortDispDataByDispOrder(jsonData) {
      // 表示順でソート
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      if (jsonData) {
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
        return jsonData.sort((a, b) => a.order_no - b.order_no );
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      } else {
        return [];
      }
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    },
    /**
     * 表示順を振りなおす
     */
    reorderDispOrder( jsonData ) {
      // 表示順を振りなおす
      for( let idx = 0; idx < jsonData.length; idx++ ) {
        jsonData[idx].order_no = idx + 1;
      }
      return jsonData;
    },

    /**
     * 表示するデータを構築
     */
    createDispJson(jsonString) {
      // JSON文字列をJSONオブジェクトに変換
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      if (jsonString) {
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
        const bufJson = JSON.parse(jsonString);
        // キー情報が無いためインデックスを付与
        for (let lop = 0; lop < bufJson.length; lop++) {
          let buf = bufJson[lop];
          buf.index = lop;
        }
        return bufJson;
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou start
      } else {
        return [];
      }
      // add #8382 バイタル・モニタ項目追加マスタで項目を追加すると治療状況レイアウトマスタの表示が不正になる dou end
    },
    onSave(ev) {
      this.editingFlg = false;
      /** Grid内のデータを変更した際の処理 */

      // スクロール位置が先頭でない場合、その位置を保持する
      const scrollTop = ev.sender.content[0].scrollTop;
      const scrollLeft = ev.sender.content[0].scrollLeft;
      if (scrollTop != 0) {
        this.lastScrollTop = scrollTop;
      }
      if (scrollLeft != 0) {
        this.lastScrollLeft = scrollLeft;
      }

      // 編集内容取得
      const editRowInfo = ev.model;
      const editIndex = editRowInfo.index;
      const editObject = ev.values;
      const editKey = Object.keys(editObject)[0];

      // 現在の表示データ取得
      let currentData = this.getCurrentData;

      // 編集箇所判定
      if (editKey == "data_class") {
        // 表示項目選択コンボボックスの場合
        const editData = editObject.data_class;
        let editValue;
        if (typeof editData == "number") {
          // すでにコンボボックスに値がある場合
          editValue = editData;
        }
        if (typeof editData == "object") {
          // 編集前にコンボボックスに値が入っていない場合
          editValue = editData.value;
        }

        // 表示項目一覧から該当のdata_classを探し、各値をセットする
        let dispItem = this.searchDispItem(editValue);
        currentData.forEach(data => {
          if (data.index == editIndex) {
            data.data_class = editValue;
            data.table_name = dispItem.tableName;
            data.column_name = dispItem.fieldName;
            data.key_name = dispItem.jsonKeyName;
            data.vital_monitor_class = dispItem.vitalMonitorClass;
            data.conv_type = dispItem.dataClass;
            data.data_type = dispItem.dataType;
            // 表示名が空の場合はコンボボックスの選択した表示項目をセット
            if (!data.title) {
              data.title = dispItem.itemName;
            }
          }
        });
      } else {
        // 表示項目選択コンボボックス以外の場合
        const editValue = editObject[editKey];
        currentData.forEach(data => {
          if (data.index == editIndex) {
            data[editKey] = editValue;
          }
        });
      }

      // 表示順が変更された場合表示データをソートする
      if (editKey == "order_no") {
        currentData = this.sortDispDataByDispOrder(currentData);

        // JSONオブジェクトの表示順を振り直し
        currentData = this.reorderDispOrder(currentData);
      }

      // カレントデータ更新
      this.setCurrentData(currentData);

      /** コンボボックスの項目で編集前に値がない場合、選択確定後に選択内容が表示されない対策 */
      /// 現在のタブ番号取得
      const selectedIndex = this.getSelectedIndex;
      let dummyIndex = 0;
      /// 仮セットタブ番号生成
      if (selectedIndex < 4) {
        //// 現在のタブ番号が4以下の場合は現在の番号+1
        dummyIndex = selectedIndex + 1;
      }
      if (selectedIndex == 4) {
        //// 現在のタブ番号が4の場合は3
        dummyIndex = 3;
      }
      /// 仮データセット
      this.changeCurrentData(dummyIndex);
      /// 本データセット
      this.changeCurrentData(selectedIndex);

      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
      // this.changeEditColor
      // DB登録時に使用されるストアの情報を更新
      this.createEditedRecord();
      this.setEditRecord(this.editRecordOnComponent);
      this.changeButton();
    },
    /**
     * 表示項目一覧から指定したitemCdの項目情報を取得する
     */
    searchDispItem(itemCd) {
      const itemListMaster = this.refDispItemList;

      const len = itemListMaster.length;
      for (let lop = 0; lop < len; lop++) {
        const item = itemListMaster[lop];
        if (item.itemCd == itemCd) {
          return item;
        }
      }
    },
    createEditedRecord() {
      // 各装置の現在の設定値を取得
      let jsonDcs = JSON.parse(JSON.stringify(this.getSettingDataDcs));
      let jsonDab = JSON.parse(JSON.stringify(this.getSettingDataDab));
      let jsonDad = JSON.parse(JSON.stringify(this.getSettingDataDad));
      let jsonDro = JSON.parse(JSON.stringify(this.getSettingDataDro));
      // 内部処理用のindexを取り除く
      jsonDcs = this.removeIndexForSettingData(jsonDcs);
      jsonDab = this.removeIndexForSettingData(jsonDab);
      jsonDad = this.removeIndexForSettingData(jsonDad);
      jsonDro = this.removeIndexForSettingData(jsonDro);
      // 文字列化
      const stringDcs = JSON.stringify(jsonDcs);
      const stringDab = JSON.stringify(jsonDab);
      const stringDad = JSON.stringify(jsonDad);
      const stringDro = JSON.stringify(jsonDro);
      // 登録用データ作成
      this.editRecordOnComponent.dcsViewItems = stringDcs;
      this.editRecordOnComponent.dabViewItems = stringDab;
      this.editRecordOnComponent.dadViewItems = stringDad;
      this.editRecordOnComponent.droViewItems = stringDro;
    },
    removeIndexForSettingData(jsonData) {
      jsonData.forEach(data => {
        delete data.index;
      });

      return jsonData;
    },
    setDispItemColumnValues() {
      const self = this;
      // 装置設定で選択する表示項目一覧を取得
      this.fetchDispItemList().then(response => {
        const responseData = response.data;
        // コンボボックス表示用データ作成
        let itemLists = { DCS: [], DAB: [], DAD: [], DRO: [] };
        responseData.forEach(data => {
          // コンボボックスにセットするオブジェクト作成
          let buf = {};
          buf.value = data.itemCd;
          buf.text = data.itemName;
          // 機種判定
          switch (data.machineClass) {
            case "0": // 透析装置
              itemLists.DCS.push(buf);
              break;
            case "1": // 供給装置
              itemLists.DAB.push(buf);
              break;
            case "2": // 溶解装置
              itemLists.DAD.push(buf);
              break;
            case "3": // RO装置
              itemLists.DRO.push(buf);
              break;
          }
        });
        // 保存時の参照用に取得データをdataに保持
        self.refDispItemList = responseData;
        // 機種別全コンボボックス表示用データをストアにセット
        this.setComboItemList_Act(itemLists);
        // コンボボックス表示用データをストアにセット
        this.setColumnDispItemList(itemLists.DCS);
        self.multiSelectList = itemLists.DCS;
        self.allMultiSelectList = itemLists;
      });
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    /**
     * 行を追加する
     */
    // 追加ボタンタップ時複数選択画面に切替える
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.popoverVisible = true;
      this.gridVisible = false;
    },
    // gridに複数行追加する
    addMultiSelect() {
      this.popoverVisible = false;
      this.gridVisible = true;
      // カレントデータ取得
      let currentData = this.getCurrentData;

      // カレントデータのindexと表示順の最大値を取得
      let maxIndex = 0;
      let maxDispOrder = 0;
      const len = currentData.length;
      for (let lop = 0; lop < len; lop++) {
        const data = currentData[lop];
        if (data.index > maxIndex) {
          maxIndex = data.index;
        }
        if (data.order_no > maxDispOrder) {
          maxDispOrder = data.order_no;
        }
      }

      const selectLen = this.selectedSelection.length;

      // 複数選択したデータをgridに表示
      for (let i = 0; i < selectLen; i++){
        let dispItem = this.searchDispItem(this.selectedSelection[i]);

        // 追加データ作成
        let multiRowData = {};
        multiRowData.index = maxIndex + (i + 1);
        multiRowData.order_no = maxDispOrder + (i + 1);
        multiRowData.title = dispItem.itemName;
        multiRowData.data_class = dispItem.itemCd;
        multiRowData.width = 11;
        multiRowData.table_name = dispItem.tableName;
        multiRowData.column_name = dispItem.fieldName;
        multiRowData.key_name = dispItem.jsonKeyName;
        multiRowData.vital_monitor_class = dispItem.vitalMonitorClass;
        multiRowData.conv_type = dispItem.dataClass;
        multiRowData.data_type = dispItem.dataType;
        // カレントデータに追加
        currentData.push(multiRowData);
        // カレントデータ更新
        this.setCurrentData(currentData);
      }

      // DB登録時に使用されるストアの情報を更新
      this.createEditedRecord();
      this.setEditRecord(this.editRecordOnComponent);

      // 追加した行を表示するよう、再下部までスクロールする
      this.$nextTick(() => {
        const modal = document.getElementsByClassName("modal-container")[0];
        let scrollArea = modal.getElementsByClassName("k-auto-scrollable")[1];
        scrollArea.scrollTop = scrollArea.scrollHeight;
      });
      this.selectedSelection = [];
      this.changeButton();
    },
    selectCancel() {
      // 複数追加画面を何もしないで閉じる
      // grid画面に戻る
      this.popoverVisible = false;
      this.gridVisible = true;
      this.selectedSelection = []
    },
    /**
     * 行を削除する
     */
    deleteRow(ev) {
      // ボタンを押した行のデータを取得する
      ev.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const rowData = row.dataItem(ev.currentTarget.closest("tr"));
      // 選択された行のデータのデータに付与しているIndexを取得
      const selectedDataIndex = rowData.index;

      // カレントデータ取得
      let currentData = this.getCurrentData;

      // カレントデータから対象のIndexのデータを削除
      const newCurrentData = currentData.filter(
        data => data.index !== selectedDataIndex
      );

      // カレントデータ更新
      this.setCurrentData(newCurrentData);

      // DB登録時に使用されるストアの情報を更新
      this.createEditedRecord();
      this.setEditRecord(this.editRecordOnComponent);
      this.changeButton();
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        /** モーダルを再度開くとヘッダーの要素が取れなくなることへの対応 */
        let gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.classList === undefined) {
          gridHeader = this.$refs.grid.$el.firstElementChild;
        }
        gridHeader?.classList?.add("master-grid-header");
      });
    },
    // モーダルの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const modal = document.getElementsByClassName("modal-container")[0];
        const modalHeight = modal.clientHeight;
        const modalHeaderHeight = modal.firstElementChild.clientHeight;
        const modalFooterHeight = modal.lastElementChild.clientHeight;
        const tabHeight = 66;
        const btnArea = document.querySelector(".modal-body .header-btn-area");
        const btnHeight = btnArea ? btnArea.clientHeight : 45;
        // add GRIDリスト内容がブロックされるのことを対応 劉 start
        const btnToolBar = document.querySelector(".modal-footer .bottom-bar").clientHeight;
        // add GRIDリスト内容がブロックされるのことを対応 劉 end
        const offset = 0;
        const gridHeight =
          modalHeight -
          modalHeaderHeight -
          tabHeight -
          btnHeight -
          modalFooterHeight -
          // add GRIDリスト内容がブロックされるのことを対応 劉 start
          btnToolBar -
          // add GRIDリスト内容がブロックされるのことを対応 劉 end
          offset;

        this.kendoGridToolbarHeight =
          modalHeight -
          modalHeaderHeight -
          tabHeight -
          modalFooterHeight -
          offset;

        this.kendoGridHeight =
          gridHeight > this.kendoGridMinHeight
            ? gridHeight
            : this.kendoGridMinHeight;

        this.addListHeight =
          modalHeight -
          modalHeaderHeight -
          tabHeight -
          modalFooterHeight -
          145 -
          offset;
      }
    },
    editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (this.isAndroid) {
        this.editingFlg = true;
      }
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
    editEnd() {
      this.editingFlg = false;
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 start
    numericEditor(container, options) {
      let strinput= '<input id="myInputNumber" type="number" style="text-align:right" data-bind="value:' + options.field + '"/> ';
      const masterField = this.dispMachineSetting.options.schema.model.fields[options.field];
      let parameterMin = masterField.validation.min
      let parameterMax = masterField.validation.max
      let parameterStep = 1
      let parameter = {step: parameterStep, format: "n0"}
      parameter.spin = ()=> {
        let value = $('#myInputNumber').data('kendoNumericTextBox').value()
        // 数値範囲内かどうかの確認
        if (value > parameterMax) {
          $('#myInputNumber').data('kendoNumericTextBox').value(parameterMin)
        } else if (value <  parameterMin) {
          $('#myInputNumber').data('kendoNumericTextBox').value(parameterMax)
        }
        document.getElementById('grid-font-size').onmousewheel = () => {
          return true
        }
      }
      parameter.change = (e)=> {
        let value = e.sender._value
        // 数値範囲内かどうかの確認
        if (value > parameterMax) {
          options.model.set(options.field, parameterMax);
        } else if (value <  parameterMin) {
          options.model.set(options.field, parameterMin);
        }
        document.getElementById('grid-font-size').onmousewheel = () => {
          return true
        }
      }
      $(strinput).appendTo(container).kendoNumericTextBox(parameter);
      this.$nextTick(() => {
        document.getElementById('grid-font-size').onmousewheel = () => {
          return false
        }
        $('#myInputNumber').prev().attr('type','number')
        $('#myInputNumber').data('kendoNumericTextBox').element.on("mousewheel", (event)=>{
          let delta = (event.originalEvent.wheelDelta && (event.originalEvent.wheelDelta > 0 ? 1 : -1)) ||
                      (event.originalEvent.detail && (event.originalEvent.wheelDelta > 0 ? -1 : 1))
          let value = parseFloat($('#myInputNumber').data('kendoNumericTextBox').value())
          if (!parameterStep) {
            parameterStep = 1
          }
          if (delta > 0) {
            // 滑ります
            value += parameterStep
          } else {
            // 下がります
            value -= parameterStep
          }
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            value = parameterMin
          } else if (value <  parameterMin) {
            value = parameterMax
          }
          $('#myInputNumber').data('kendoNumericTextBox').value(value)
        })
        $('#myInputNumber').data('kendoNumericTextBox').element.on("blur", () => {
          document.getElementById('grid-font-size').onmousewheel = () => {
            return true
          }
          $('#myInputNumber').data('kendoNumericTextBox').trigger('change')
        })
      })
    },
    // add #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 end
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    // 親画面から装置設定JSONデータ取得
    const editRecord = this.getEditRecord;
    this.editRecordOnComponent = editRecord;
    this.setDispSettingData(editRecord);
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.isAndroid = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.isIOS = true;
    }
  },
  beforeMount() {
    // 起動時は透析装置のデータを表示する
    this.changeCurrentData(1);
    // 列定義をセット
    this.setDispItemColumnValues();
  },
  mounted() {
    // Gridの高さをモーダルの大きさによって調整する
    this.calculateGridHeight();
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  beforeDestroy() { },
  destroyed() {
    this.clearData();
  }
};
</script>

<style scoped>
@media print {
  .disp-item-list{
    position: relative;
    top: 5px;
  }
  #grid-font-size .k-grid-content {
    height: auto !important;
  }
}
#grid-font-size {
  font-size: 1em;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: 2.5em;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
  background-color: var(--ntss-base-background-color);
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}

/* [メイン] タブ切り替え全体のスタイル*/
.tabs {
  margin-top: 40px;
  /* background-color: #fff; */
  width: auto;
  margin: 0 auto;
  display: flex;
}
/* [メイン] タブのスタイル*/
.tab_item {
  flex: 1;
  /* width: calc(100% / 4); */
  height: 50px;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 50px;
  text-align: center;
  color: #565656;
  display: block;
  /* float: left; */
  text-align: center;
  font-weight: bold;
  transition: all 0.2s ease;
}
.tab_item:hover {
  opacity: 0.75;
}
/* [メイン] ラジオボタンを全て消す*/
input[name="tab_item"] {
  display: none;
}
/* [メイン] タブ切り替えの中身のスタイル*/
.tab_content {
  display: none;
  padding: 40px 40px 0;
  clear: both;
  overflow-y: auto;
}
/* [メイン] 選択されているタブのスタイルを変える*/
.tabs input:checked + .tab_item {
  background-color: #2a8bc4;
  color: #fff;
}

/* グリッドのスタイル */
.disp-item-list {
  overflow: auto;
  width: calc(100% - 15px);
  border-collapse: collapse;
  margin: 0 auto;
  position: absolute;
  top: 60px;
  background-color: var(--ntss-list-header-backgroud-color);
}

.bed-name-area,
.machine-no-area {
  padding-left: 8px;
}

.main-area {
  margin: 0 5px;
}
.main-area >>> .k-grid {
  background-color: var(--main-background-color);
}
.main-area >>> .k-grid tr {
  height: 2em;
  border-color: var(--master-maintenance-kgrid-border-color);
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
.main-area >>> .k-grid tr.k-alt {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.main-area >>> .k-grid a {
  color: var(--master-maintenance-kgrid-item-color);
}
.main-area >>> .k-grouping-row a {
  color: var(--master-maintenance-kgrid-item-a-color);
}
.main-area >>> .k-grid div.k-grouping-header {
  color: var(--master-maintenance-kgrid-item-a-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
.main-area >>> .k-grid td.k-group-cell {
  text-overflow: clip;
  color: var(--master-maintenance-kgrid-item-a-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
.main-area >>> .k-grid tr.k-state-selected>td {
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-selected-background-color);
}
.main-area >>> .k-grid tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
  color: var(--master-maintenance-kgrid-body-color);
}
.main-area >>> .k-grid th {
  color: #fff;
  background-color: var(--master-maintenance-kgrid-header-background-color);
}
.main-area >>> .k-grid th a {
  color: #fff;
}

.machine-no,
.k-textbox {
  width: 100%;
}

.machine-area {
  width: 100%;
  border-collapse: collapse;
}

.selecting-row {
  background-color: rgba(0, 225, 255, 0.5);
}

.select-input {
  height: 70%;
}

.display-list {
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.display-list:hover {
  background-color: #e4e7eb;
}

.display-list.selected {
  color: #fff;
  background-color: #0076ff;
}

.selected-list {
  height: 93%;
}

.selected-item-list {
  position: relative;
  border: 1px solid var(--ntss-list-border-color);
  overflow: auto;
}

ons-button.cancel {
  color: #333333;
  background-color: #add8e6;
}

#item-box-list{
  --height: 200px;
  height: var(--height);
  border: solid gray;
  padding: 20px;
  border-width: 2px 2px 1px;
  margin: 0px auto;
  width: 50%;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy start */
  min-width: 260px;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy end */
}

#item-box-conf{
  border: solid gray;
  padding: 10px 20px;
  border-width: 1px 2px 2px;
  margin: 0px auto;
  width: 50%;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy start */
  min-width: 260px;
  /* mod redmine 5098 スマホ、詳細モーダル内のプルダウンメニューが見切れる 宋qy end */
}

#select-text{
  margin-bottom: 5px;
  margin-top: 0px;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.dialog-cancel,.dialog-conf{
  background:none;
}

#list-footer{
  display: flex;
  justify-content: space-between;
}

.custom-switch-wrapper {
  display: flex;
  float: left;
  align-items: center;
  min-width: 7em;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
</style>
