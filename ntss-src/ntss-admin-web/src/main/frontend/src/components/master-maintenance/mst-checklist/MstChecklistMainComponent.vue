/**
 * チェックリスト設定画面
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="mst-checklist-main-content-area">
      <div class="header-btn-area right" :class="{ 'mobile-header': isMobileDevice }">
        <div v-show="isMobileDevice" class="custom-switch-wrapper">
          <label class="fab-font-color">編集</label>
          <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
        </div>
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          v-show="!isSortMode"
          @click="toRankEditBtnClick()"
        >並び順表示</v-ons-button>
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          v-show="isSortMode"
          @click="sortBtnClick()"
        >反映</v-ons-button>
      </div>
      <!-- チェックリスト一覧のグリッド -->
      <!-- <div> -->
        <!-- DEL チェックリストマスタ 詳細列を追加してそこからモーダルを起動する 孔s start-->
        <!-- <kendo-grid
          ref="mstChecklistGrid"
          :class="fontSizeSet"
          :height=kendoGridHeight
          :data-source="checklistSetting"
          :editable="true"
          :selectable="'row'"
          :scrollable="true"
          :change="onClick"
          :beforeEdit="editStart"
          :cellClose="editEnd"
          :edit="addInputAssist"
          @save="onSave"
        >
          <kendo-grid-column
            v-for="category in getMstChecklistColumn"
            :key="category.length"
            :title="category.title"
            :width="category.width"
            :field="category.field"
            :hidden="category.hidden"
            :locked="category.locked"
            :editable="category.editable"
            :template="category.template"
          ></kendo-grid-column>
        </kendo-grid> -->
        <!-- DEL チェックリストマスタ 詳細列を追加してそこからモーダルを起動する 孔s end-->
        <!-- ADD チェックリストマスタ 詳細列を追加してそこからモーダルを起動する 孔s start-->
      <kendo-grid
        ref="mstChecklistGrid"
        :class="fontSizeSet"
        :height=kendoGridHeight
        :data-source="checklistSetting"
        :editable="true"
        :selectable="'row'"
        :scrollable="true"
        :beforeEdit="editStart"
        :cellClose="editEnd"
        :edit="addInputAssist"
        @save="onSave"
        @databound="onDataBoundKendoGrid">
      <template v-for="(category,index) in getMstChecklistColumn">
        <kendo-grid-column
          v-if="category.title === '詳細'"
          :key="index"
          :title="category.title"
          :width="category.width"
          :field="category.field"
          :hidden="category.hidden"
          :locked="category.locked"
          :editable="category.editable"
          :template="category.template"
          :attributes="{ class: 'btn3-kendo-normal' }"
          :command="{ text: '詳細', click: onClick }"
        ></kendo-grid-column>
        <kendo-grid-column
          v-else
          :key="index"
          :title="category.title"
          :width="category.width"
          :field="category.field"
          :hidden="category.hidden"
          :locked="category.locked"
          :editable="category.editable"
          :template="category.template"
          :values="category.values"
        ></kendo-grid-column>
      </template>
      </kendo-grid>
        <!-- ADD チェックリストマスタ 詳細列を追加してそこからモーダルを起動する 孔s end-->
      <!-- </div> -->
    </div>
    <div id="grid-footer" class="btn-area nowrap-block">
      <v-ons-row width="100%" v-show="!isSortMode">
        <v-ons-col width="50%">
          <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" v-show="!isSortMode" @click="cancel()">キャンセル</v-ons-button>
        </v-ons-col>
        <v-ons-col width="50%" class="right">
          <v-ons-button
            class="btn1-execute button registration-btn" style="width: auto;"
            v-show="!isSortMode"
            :disabled="isPreservation"
            @click="registration()"
          >保存</v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import Kendo from "@progress/kendo-ui";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/eventBus.js";
import $$ from "jquery"
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

// ストアについて
// testStateストアの実体は/stores/modules/test-store.jsである。
// この名前と実体ファイルの関連付けは/stores.store.jsに定義されている。

export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  data() {
    return {
      isSortMode: false,
      editingFlg: false,
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      kendoGridHeight: 300,
      // 選択中の施設コード
      facilitylistValue: "",
      isPreservation: true,
      MstChecklistColumn:"",
      errorMessage: "",
      getChecklistSettingOld: null,
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
      dispNoListCd: [],
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      saveFlg: false
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch" }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu"
    }),
    ...mapGetters("mst-checklist", [
      "getChecklistSetting",
      "getMstChecklistColumn",
      "getChangeFlg",
      "getSchema"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    // グリッド表示情報
    checklistSetting() {
      // storeからデータを取得
      return new Kendo.data.DataSource({
        data: this.getChecklistSetting,
        schema: {
          model: {
            fields: this.getSchema
          }
        }
      });
    },
    // 変更フラグ
    isChanged() {
      return this.getChangeFlg;
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
    },
  },
  watch: {
    getChecklistSetting () {
      this.getChecklistSetting && this.getChecklistSetting.forEach((item, index) => {
        item.funclist.forEach((ita, idx) => {
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg = ita.chgflg : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_disp_no = ita.chgflg_disp_no : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_func_class = ita.chgflg_func_class : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_list_name = ita.chgflg_list_name : undefined
         this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].funclist[idx].chgflg_class_cd = ita.chgflg_class_cd : undefined
        })
        this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].dummy_disp_no = item.dummy_disp_no : undefined
        this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].chgflg = item.chgflg : undefined
        this.getChecklistSettingOld && this.getChecklistSettingOld[index] ? this.getChecklistSettingOld[index].chgflg_listname = item.chgflg_listname : undefined
      })
      if (this.getChecklistSettingOld && (JSON.stringify(this.getChecklistSetting) == JSON.stringify(this.getChecklistSettingOld))) {
        this.isPreservation = true;
      } else if (this.getChecklistSettingOld && (JSON.stringify(this.getChecklistSetting) != JSON.stringify(this.getChecklistSettingOld))) {
        this.isPreservation = false;
      }
      this.setisPreservation(this.isPreservation)
      // add #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
      this.getChecklistSetting && this.getChecklistSettingOld &&
      // add #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
      this.getChecklistSetting.forEach((item, index) => {
        if (this.isPreservation && item.chgflg !== undefined) {
          item.chgflg = false
        }
        if ((item.dialysis_prog_name == this.getChecklistSettingOld[index].dialysis_prog_name) && (item.list_name == this.getChecklistSettingOld[index].list_name) && (JSON.stringify(item.funclist) == JSON.stringify(this.getChecklistSettingOld[index].funclist))) {
          item.chgflg = false
        }
      })
    },
    // getChangeFlg(val) {
    //   if(val) this.isPreservation = true;
    // },
    MstChecklistColumn: function(val){
      this.$nextTick(function(){
        if (val)
        this.setLoadingScreenVisible(false);
        this.getChecklistSettingOld = deepCopy(this.getChecklistSetting)
      });
    },
    // add redmine 5005 一覧画面で2重スクロールになる 孔 start
    windowHeight() {
      // this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
    },
    windowWidth() {
      // this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
    },
    isDispMenu() {
      // this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
    },
    getFontSize() {
      // this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
    },
    // add redmine 5005 一覧画面で2重スクロールになる 孔 end
  },
  methods: {
    ...mapActions("multi-modal", ["showChecklistEdit"]),
    ...mapActions("master-maintenance", ["setisPreservation"]),
    //DEL チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
    // ...mapActions("mst-checklist", [
    //   "setChangeFlg",
    //   "setMstCheckListColumn",
    //   "fetchMstEquipClassList",
    //   "fetchCheckSettingList",
    //   "setNewflg",
    //   "setEditChecklist",
    //   "mstChecklistSortData",
    //   "regChecklistSetting",
    //   "getDeviceEdgeNoList",
    //   "mstSyncDeviceEdge"
    // ]),
    //DEL チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
    //ADD チェックリストマスタ 1.データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。2.工程、リスト名を一覧で修正可能とする 孔s start
    ...mapActions("mst-checklist", [
      "getDeviceEdgeNoListByFacilityCd",
      "setChangeFlg",
      "setMstCheckListColumn",
      "fetchMstEquipClassList",
      "fetchCheckSettingList",
      "setNewflg",
      "setEditChecklist",
      "mstChecklistSortData",
      "regChecklistSetting",
      "getDeviceEdgeNoList",
      "mstSyncDeviceEdge",
      "fetchMstMedicineClassList",
      "edit",
      "deleteOrdCheckList",
      "cleanCheckSettingList"
    ]),
    //ADD チェックリストマスタ 1.データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。2.工程、リスト名を一覧で修正可能とする 孔s end
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .pop().clientHeight;
        const fmh =
          this.isDispMenu === 1
            ? document.getElementById("footer-menu").clientHeight
            : 0;
        const tableToolbar = document.getElementsByClassName("header-btn-area")[0].clientHeight
        this.kendoGridToolbarHeight = wh - hh - fmh - 1;

        const gfh = document.getElementById("grid-footer").clientHeight;
        this.kendoGridHeight = this.kendoGridToolbarHeight - gfh - tableToolbar;
        // #8745 表示内容が画面上半分にしか表示されない。 林峻峰 start
        let contentScrollableWidth = (document.getElementsByClassName('k-grid')[0].clientWidth
                                          - document.getElementsByClassName('k-grid-content-locked')[0].clientWidth);
        document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].style.width = `${contentScrollableWidth}px`;
        // #8745 表示内容が画面上半分にしか表示されない。 林峻峰 start
      }
    },
    loadData() {
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue start
      // 医療材料マスタ情報取得
      this.fetchMstEquipClassList(this.facilitylistValue).then(async() => {
        // チェックリスト設定情報取得
        await this.fetchCheckSettingList(this.facilitylistValue);

        this.getChecklistSettingOld = deepCopy(this.getChecklistSetting)
      });
      //ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
      this.fetchMstMedicineClassList(this.facilitylistValue);
      //ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue end
    },
    // 背景色セット
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.mstChecklistGrid.$el.firstChild;
        if (gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");
        const tBody = this.$refs.mstChecklistGrid.$el.lastChild.lastChild.tBodies;
        //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s START
        const tBody2 = this.$refs.mstChecklistGrid.$el.children[1].firstChild.lastChild.children;
        //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s END
        if ( ! tBody || tBody.length !== 1 ) {
          return;
        }
        const tBodyC = tBody[0].children;
        for (let rwCount = 0; rwCount < tBodyC.length; rwCount++) {
          const currentTrc = tBodyC[rwCount].children;

          // 並び順の編集で色を変更する
          let edited = this.getChecklistSetting[rwCount].chgflg_dispno;

          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s START
          // this.changeDispCellColor(currentTrc, edited);
          const currentFrontTrc = tBody2[rwCount]
          // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
          // !this.isPreservation && this.changeDispCellColor(currentTrc, edited,currentFrontTrc);
          !this.isPreservation && this.changeDispCellColor(currentTrc, edited,currentFrontTrc,this.getChecklistSetting[rwCount].list_cd);
          // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
          //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s END

          // モーダルからの編集で色を変更する
          // if (!this.isPreservation) {
          edited = this.getChecklistSetting[rwCount].chgflg;
          // }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          !this.isPreservation && this.changeRowColor(currentTrc, edited);

          // リスト名・工程が変更されていた場合
          !this.isPreservation && this.changeCellFont(currentTrc, this.getChecklistSetting[rwCount]);

          // グリッド高さ再計算
          this.$nextTick(() => {
            !this.isPreservation && this.calculateGridHeight();
            this.MstChecklistColumn = this.getMstChecklistColumn;
          });
        }
      });
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s START
    // changeDispCellColor(currentTrc, edited) {
    // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
    // changeDispCellColor(currentTrc, edited,currentFrontTrc) {
    changeDispCellColor(currentTrc, edited,currentFrontTrc, listCd) {
    // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
    //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s END
      // 並び順のインデックス
      const noIdx = this.getColumnIndex("disp_no");
      const dummyIdx = this.getColumnIndex("dummy_disp_no");
      // 並び順が変更されていれば並び順とダミー項目背景色を変更0
      // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
      // if (this.isEditRow(currentTrc[noIdx]) || edited) {
      if (this.isEditRow(currentTrc[noIdx]) || this.isEditRow(currentTrc[dummyIdx]) || (edited && this.dispNoListCd.includes(listCd))) {
      // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
        currentTrc[noIdx]?.classList?.add("master-sort-edited");
        currentTrc[dummyIdx]?.classList?.add("master-sort-edited");
        //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s START
        currentFrontTrc?.classList?.add("master-sort-edited");
        //ADD チェックリストマスタ 工程名の左のセルのセル色を変更する。 孔s END
      } else if (currentTrc[noIdx].classList.length > 0) {
        currentTrc[noIdx].classList.remove("master-sort-edited");
        currentTrc[dummyIdx].classList.remove("master-sort-edited");
        currentFrontTrc.classList.remove("master-sort-edited");
      }
    },
    changeRowColor(currentTrc, edited) {
      const addClass = "master-edited-row";
      // 並び順より後の項目のインデックス
      const idx = this.getColumnIndex("dummy_disp_no") + 1;
      for (let clCount = idx; clCount < currentTrc.length; clCount++) {
        // 並び順より後の項目の背景色を変更
        if (edited) {
          currentTrc[clCount]?.classList?.add(addClass);
        } else if (currentTrc[clCount].classList.length > 0) {
          currentTrc[clCount].classList.remove(addClass);
        }
      }
    },
    changeCellFont(currentTrc, data) {
      const addClass = "master-edited-cell";

      // 工程名
      const progIdx = this.getColumnIndex("dialysis_prog_name") - 2;
      // 変更ありの場合
      if (data.chgflg_progcd) {
        currentTrc[progIdx]?.classList?.add(addClass);
      } else if (currentTrc[progIdx].classList.length > 0) {
        currentTrc[progIdx].classList.remove(addClass);
      }

      // リスト名
      const listIdx = this.getColumnIndex("list_name") - 2;
      // 変更ありの場合
      if (data.chgflg_listname) {
        currentTrc[listIdx]?.classList?.add(addClass);
      } else if (currentTrc[listIdx].classList.length > 0) {
        currentTrc[listIdx].classList.remove(addClass);
      }
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.getMstChecklistColumn.findIndex(e => e.field === fieldName);
    },
    // グリッドクリック時
    onClick(event) {
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
      const scrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      if (!this.isSortMode) {
        event.preventDefault();
        const selRow = this.$refs.mstChecklistGrid.kendoWidget().dataItem(event.currentTarget.closest("tr"));
        const selectedRowIndex = this.getChecklistSetting.findIndex(e => e.list_cd === selRow.list_cd);

        // 選択された設定の表示順と設定情報をセット
        this.setEditChecklist(selectedRowIndex);
        // チェックリスト設定モーダル画面表示
        // this.showChecklistEdit("チェックリスト設定");
        this.showChecklistEdit("チェックリストマスタ詳細");
      }
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    setScrollPosition(position) {
      $$("div.k-grid-content")
        .scrollTop(position.top)
        .scrollLeft(position.left);
    },
    onSave(ev) {
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = ev.sender.content[0].scrollTop;
      const scrollLeft = ev.sender.content[0].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
      if (Object.keys(ev.values)[0] !== "disp_no") {
          this.editingFlg = false;
          this.edit({ editRecord: ev.model, isSortMode: false, value: ev.values });
          // ev.sender.refresh();
          if (ev.model.operation === 1) {
            ev.model.edited = true;
          }
          this.mstChecklistSortData(this.getChecklistSetting);
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
      } else if (!this.dispNoListCd.includes(ev.model.list_cd)) {
        this.dispNoListCd.push(ev.model.list_cd);
        this.isPreservation = false;
      }
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    onDataBoundKendoGrid(ev) {
      if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          ev.sender.content[0].scrollTop = this.scrollPosition.top;
          ev.sender.content[0].scrollLeft = this.scrollPosition.left;
        });
      }
    },
    // 並び順表示
    toRankEditBtnClick() {
      this.isSortMode = true;
      this.showSortColumn();
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
      this.disableColumns();
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
    },
    showSortColumn() {
      // 並び順列の表示/非表示
      let colSetting = this.getMstChecklistColumn;
      colSetting[0].hidden = this.isSortMode;
      colSetting[1].hidden = !this.isSortMode;
      this.setMstCheckListColumn(colSetting);
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    // 反映
    sortBtnClick() {
      // グリッドデータ取得
      const gridData = this.$refs.mstChecklistGrid.kendoWidget();
      this.mstChecklistSortData(gridData.dataSource.options.data);
      this.isSortMode = false;
      this.showSortColumn();
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
      this.editableColumns();
      //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
    },
    //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
    editableColumns() {
      this.getMstChecklistColumn.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "disp_no"
            ? () => false
            : () => true;
      });
    },
    disableColumns() {
      this.getMstChecklistColumn.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "disp_no"
            ? () => true
            : () => false;
      });
    },
    //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
    // マスタ同期
    syncMaster() {
      this.setLoadingScreenVisible(true);
      // mod マスタ一覧 1･施設切替を可能とする 孔 getDeviceEdgeNoList => getDeviceEdgeNoListByFacilityCd
      // this.getDeviceEdgeNoList().then(res => {
      this.getDeviceEdgeNoListByFacilityCd(this.facilitylistValue).then(res => {
        let array = res.data;
        if (array && array.length > 0) {
          array = array.sort((a,b) => {
            if (a.deviceEdgeNo < b.deviceEdgeNo) return -1;

            if (a.deviceEdgeNo > b.deviceEdgeNo) return 1;

            return 0;
          })
          this.synchroMstToDeviceEdge(array, 0);
        }else {
          /* mod #8666 by zhangruixue 2023-05-24 -- start */
          this.resetLoadingScreenVisibleCount();
          let title = messageFormat(DIALOG_MESSAGES['00100009'].title, 'チェックリストマスタ');
          this.$ons.notification.alert({
            title: title,
            message: 'mst_device_edgeテーブルの中にデータをクエリーできない',
          });
          /* mod #8666 by zhangruixue 2023-05-24 -- end */
        }
      })
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = "チェックリストマスタ同期";
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, 'チェックリストマスタ');
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      let name = "デバイスエッジ：" + this.errorMessage + "</br></br>";

      // マスタ同期
      this.mstSyncDeviceEdge({
        // facilityCd: this.getFacilityCd,
        facilityCd: this.facilitylistValue,
        deviceEdgeNo: info.deviceEdgeNo
      })
          /* upd EOL対応内部 #6976 by ztc 2023-07-08 --start */
        .then((rep) => {
          if(rep.data.isSuccess){
            if (infos.length === idx + 1) {
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
              if (this.errorMessage === "") {
                this.$ons.notification.alert({
                  title: title,
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // message: "マスタ同期が完了しました。"
                  message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                });
              } else {
                this.$ons.notification.alert({
                  title: title,
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // message:
                  //   name +
                  //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                  message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                });
                this.errorMessage = "";
              }
              this.setLoadingScreenVisible(false);
            } else {
              // 次のデバイスエッジ
              this.synchroMstToDeviceEdge(list, idx + 1);
            }
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
            if(list.length === (idx+1)){
              this.refresh();
            }
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
          }else {
            if (this.errorMessage === "") {
              this.errorMessage += "</br>" + info.deviceName + "</br>";
            } else {
              this.errorMessage += info.deviceName + "</br>";
            }
            this.synchroMstToDeviceEdge(list, idx + 1);
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
            if(list.length === (idx+1)){
              this.refresh();
            }
            // add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
            if (infos.length === idx + 1) {
              getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorMessage = "";
              this.setLoadingScreenVisible(false);
            }
          }
          setTimeout(() => {
            this.saveFlg = false;
          }, 1500);
        })
        .catch(error => {
          getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', error);
          return error;
          // if (this.errorMessage === "") {
          //   this.errorMessage += "</br>" + info.deviceName + "</br>";
          // } else {
          //   this.errorMessage += info.deviceName + "</br>";
          // }
          // this.synchroMstToDeviceEdge(list, idx + 1);
          // // add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
          // if(list.length === (idx+1)){
          //     this.refresh();
          // }
          // // add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
          // if (infos.length === idx + 1) {
          //   if (error.response.status === 400) {
          //     getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');
          //
          //     name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
          //     // 共通ローダー：表示終了
          //     this.$ons.notification.alert({
          //       title: title,
          //       // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          //       // message:
          //       //   name +
          //       //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
          //       message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
          //       // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          //     });
          //     this.errorMessage = "";
          //     this.setLoadingScreenVisible(false);
          //   } else {
          //     getErrorMessage('MstChecklistMainComponent.vue', 'synchroMstToDeviceEdge', error);
          //   }
          // }
          /* upd EOL対応内部 #6976 by ztc 2023-07-08 --end */
        });
    },
    // チェックリスト設定登録
    // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
    // registration() {
    //   // 共通ローダー:表示開始
    //   this.setLoadingScreenVisible(true);
    //   // チェックリストマスタ設定登録
    //   this.regChecklistSetting().then(async res => {
    async registration() {
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
      const scrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      this.saveFlg = true;
      // 共通ローダー:表示開始
      await this.setLoadingScreenVisible(true);
      // チェックリストマスタ 未入力チェックがない start zhao
      let messageflag=false;
      const regSetting = deepCopy(this.getChecklistSetting);
      for (let i=0;i<regSetting.length;i++){
          let listName = regSetting[i].list_name
          if(!listName){
            messageflag=true
          }
        }
        if(messageflag){
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
          title: DIALOG_MESSAGES['00200100'].title,
          message: messageFormat(DIALOG_MESSAGES['00200100'].message),
          });
          // チェックリストマスタ 未入力チェックがない zhao start
          return;
          // チェックリストマスタ 未入力チェックがない zhao end
        }
      // チェックリストマスタ 未入力チェックがない end zhao
      // チェックリストマスタ設定登録
      await this.regChecklistSetting().then(async res => {
        // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
        if (res === true) {
          //共通ローダー：表示終了
          // del #8344 【デグレ】チェックリストマスタの保存までが長い dou start
          // this.setLoadingScreenVisible(false);
          // del #8344 【デグレ】チェックリストマスタの保存までが長い dou end

          // ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 START
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue start
          // this.deleteOrdCheckList(this.getFacilityCd);
          // mod 8344【デグレ】チェックリストマスタの保存までが長い zhao start
          // this.deleteOrdCheckList(this.facilitylistValue);
          // del 8344【デグレ】チェックリストマスタの保存までが長い dou start
          // await this.deleteOrdCheckList(this.facilitylistValue);
          // del 8344【デグレ】チェックリストマスタの保存までが長い dou end
          // mod 8344【デグレ】チェックリストマスタの保存までが長い zhao end
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue end
          // ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 END
          // 登録成功
          // this.$ons.notification.alert({
          //   title: "設定完了",
          //   message: "チェックリスト設定を更新しました"
          // });
          // マスタ画面へ戻る
          //this.$router.push({ name: "master-maintenance" });
          // マスタ同期
          await this.syncMaster();
          // リロード
          this.refresh();
        } else {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);

          // 登録失敗
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "登録失敗",
            // message: "チェックリスト設定の登録に失敗しました"
            title: DIALOG_MESSAGES['00200043'].title,
            message: messageFormat(DIALOG_MESSAGES['00200043'].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      });
      // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
      await this.setLoadingScreenVisible(false);
      // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
    },
    /**
     * キャンセル
     */
    cancel() {
      // TODO: 編集破棄確認
      // this.$router.go(-1);
      this.$router.push({ name: "master-maintenance" });
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
      // #9185 マウスが止まるとのtipsが現れました linjunfeng start
      this.$nextTick(()=>{
        if (document.getElementsByClassName('k-textbox') && document.getElementsByClassName('k-textbox')[0]) {
          document.getElementsByClassName('k-textbox')[0].setAttribute('title', '');
        }
      })
      // #9185 マウスが止まるとのtipsが現れました linjunfeng end
    },
    editEnd() {
      this.editingFlg = false;
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
    loadGridData(){
      // 並べ替えクリア
      this.isSortMode = false;
      this.showSortColumn();
      // 変更フラグクリア
      this.setChangeFlg(false);
      // チェックリストマスタ情報取得
      this.loadData();
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.scrollPosition.top = 0;
                this.scrollPosition.left = 0;
                this.loadGridData();
              }
            }
          });
        } else {
          if(!this.saveFlg){
            this.scrollPosition.top = 0;
            this.scrollPosition.left = 0;
          }
          this.loadGridData();
        }
      }
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    this.cleanCheckSettingList();
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.isAndroid = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.isIOS = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.loadGridData();
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
  }
  // add 性能改善メモリ不足 shan end
};
</script>
<style scoped>
.btn-area {
  /* position: absolute; */
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
  padding: 5px 0;
}

.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}

.labelGroup {
  margin-left: auto;
  margin-right: auto;
  font-size: 1.5em;
  margin: 5px 10px;
  width: 230px;
  height: 20px;
  text-align: left;
}

.inputGroup {
  font-size: 1.5em;
  margin: 5px 10px;
  width: 120px;
  height: 25px;
  text-align: left;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}
.right {
  text-align: right;
}
/* 並び順/反映ボタン */
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
  right: 0em;
}

/* キャンセルボタン */
#cancel-button {
  position: absolute;
  left: 0px;
  bottom: 0px;
  width: 160px;
  margin: 10px;
  background-color: crimson;
}

/* 登録ボタン */
#update-button {
  position: absolute;
  right: 10px;
  bottom: 0px;
  width: 160px;
  margin: 10px;
}

.hidden-item {
  display: none;
}

.mst-checklist-main-content-area >>> .k-grid-content > .k-selectable {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
}

.mst-checklist-main-content-area >>> .k-grid-content-locked {
  border-right: 0px solid transparent !important;
}

.mst-checklist-main-content-area >>> .k-grid-header-locked {
  border-right-width: 0px;
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
.mobile-header {
  min-height: 35px; /* モバイル用の高さ */
}
</style>
