/**
 * 共通マスタ編集画面共通コンポーネント.
 */
import { mapGetters, mapActions } from 'vuex';
import $ from 'jquery';
import { EventBus } from '@/eventBus.js';
import {deepCopy} from '@/functions/common/CommonFunctions';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end

export default {
  computed: {
    ...mapGetters('account-edit', {
      getFontSize: 'getFontSize',
    }),
    // 内部 背景色と保存ボタンの状態が異常です start
    ...mapGetters("master-maintenance", {
      isRecordModified: "isRecordModified",
    }),
    // 内部 背景色と保存ボタンの状態が異常です end
    /**
     * フォントサイズに応じたCSSセレクタを返す.
     */
    fontSizeSet() {
      const names = ['small', 'medium', 'large', 'x-large'];
      return `font-size-set-${names[this.getFontSize]}`;
    },
  },
  // #8745 表示内容が画面上半分にしか表示されない。 林峻峰 start
  mounted() {
    // add #9590 start
    if (!["machine-record-search",
          "personal-user-search",
          "mst-treatment-status-layout"].includes(this.$options?._componentTag)) {
      this.condition && this.setCondition(this.condition || {})
    }
    // add #9590 end
    document.addEventListener("click", this.handleAddValidateArrow);
  },
  updated () {
    if (!this.isRecordModified) {
      const kDirtyCell = document.getElementsByClassName('k-dirty');
      if (kDirtyCell.length > 0) {
        for(let i=0; i<kDirtyCell.length; i++){
          kDirtyCell[i].setAttribute('class', '');
        }
      }
    }
  },
  beforeDestroy() {
    document.removeEventListener("click", this.handleAddValidateArrow);
  },
  // #8745 表示内容が画面上半分にしか表示されない。 林峻峰 end
  methods: {
    // add #9590 start
    ...mapActions("master-maintenance", [
      "setCondition"]),
    // add #9590 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
    ...mapActions("pat-info", {
      selectPatToHeader: "selectPat",
      clearSelectedPatToHeader: "clearSelectedPat",
      setIsNullPat: "setIsNullPat"
    }),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
    handleAddValidateArrow() {
      if (document.getElementsByClassName('k-invalid-msg') && document.getElementsByClassName('k-invalid-msg')[0]) {
        this.$nextTick(()=>{
          document.getElementsByClassName('k-invalid-msg')[0].innerHTML = document.getElementsByClassName('k-invalid-msg')[0].innerHTML + '<div class="k-callout k-callout-n"></div>'
        })
      }
    },
    // 全レコードの並び順の最大値を取得
    getMaxSortRank() {
      if (this.getFilteredMasterRecordList.data.length > 0) {
        return this.getFilteredMasterRecordList.data.reduce(
          (a, b) => Math.max(a, +b.sortRank),
          0,
        );
      }
      return 0;
    },
    calculateColumnsWidth() {
      // mod redmine 4529 小窓表示にすると設定項目が見切れる 宋qy start
      // mod redmine 4530 小窓時に並び順表示ボタンを押下するとレイアウトが崩れる 宋qy start
      if (this.masterPhysicalName == 'mst_taboo_allergy' || this.masterPhysicalName == 'mst_transport' ) {
        this.columnWidth = 12;
      // mod redmine 4530 小窓時に並び順表示ボタンを押下するとレイアウトが崩れる 宋qy end
      // mod redmine 4552 並び順を表示するとレイアウトが崩れる 宋qy start
      } else if (this.masterPhysicalName == 'mst_medicine') {
        this.columnWidth = 13;
      // mod redmine 4552 並び順を表示するとレイアウトが崩れる 宋qy end
      } else {
        this.columnWidth = parseFloat(
          window
            .getComputedStyle(document.getElementById('app'), null)
            .getPropertyValue('width'),
        ) > 1000 ? 14 : 9;
      }
      // mod redmine 4529 小窓表示にすると設定項目が見切れる 宋qy end
      // add redmine 4562 小窓時にマスタ画面を開くと一部の項目が見切れる 孔 start
      // 最大7文字
      if (
        this.masterPhysicalName === 'sys_facility'
        || this.masterPhysicalName === 'mst_wheel_chair'
        || this.masterPhysicalName === 'mst_insurance'
        || this.masterPhysicalName === 'mst_pat_event_sub_category'
        || this.masterPhysicalName === 'mst_pat_event_data_template'
        || this.masterPhysicalName === 'mst_medicine_mix'
        || this.masterPhysicalName === 'mst_medicine_group'
        || this.masterPhysicalName === 'mst_spitz'
        || this.masterPhysicalName === 'mst_trend_graph_template'
        || this.masterPhysicalName === 'mst_water_survey_point'
      ) {
        this.columnWidth = this.columnWidth > 10 ? this.columnWidth : 10
      }
      // 最大8文字
      if (
        this.masterPhysicalName === 'mst_user'
        || this.masterPhysicalName === 'mst_machine'
        || this.masterPhysicalName === 'mst_infection'
        || this.masterPhysicalName === 'mst_course'
        || this.masterPhysicalName === 'mst_treatment_set'
        || this.masterPhysicalName === 'mst_medicine_set'
        || this.masterPhysicalName === 'mst_monitor_graph'
        || this.masterPhysicalName === 'mst_vital_graph'
        || this.masterPhysicalName === 'mst_exam_set'
        || this.masterPhysicalName === 'mst_destination_group'
        || this.masterPhysicalName === 'mst_mainte_detail'
        || this.masterPhysicalName === 'mst_water_survey_type'
      ) {
        this.columnWidth = this.columnWidth > 11 ? this.columnWidth : 11
      }
      // 最大9文字
      if (
        this.masterPhysicalName === 'mst_device_edge'
        || this.masterPhysicalName === 'mst_medicine_support'
        || this.masterPhysicalName === 'mst_equipment'
        || this.masterPhysicalName === 'mst_rad_set'
        || this.masterPhysicalName === 'mst_bbs_kind'
      ) {
        this.columnWidth = this.columnWidth > 12 ? this.columnWidth : 12
      }
      // 最大10文字
      if (
        this.masterPhysicalName === 'mst_disease'
        || this.masterPhysicalName === 'mst_dialyzer'
        || this.masterPhysicalName === 'mst_equipment_set'
      ) {
        this.columnWidth = this.columnWidth > 13 ? this.columnWidth : 13
      }
      // 最大11文字
      if (
        this.masterPhysicalName === 'mst_facility'
        || this.masterPhysicalName === 'mst_job'
        || this.masterPhysicalName === 'mst_implant'
        || this.masterPhysicalName === 'mst_medicate_timing'
        || this.masterPhysicalName === 'mst_round_type'
        || this.masterPhysicalName === 'mst_add_monitor'
      ) {
        this.columnWidth = 14
      }
      // 最大12文字
      if (this.masterPhysicalName === 'mst_room_bed_group') {
        this.columnWidth = 15
      }
      // 最大18文字
      if (this.masterPhysicalName === 'sys_medicine') {
        this.columnWidth = 19
      }
      // add redmine 4562 小窓時にマスタ画面を開くと一部の項目が見切れる 孔 start
    },
    calculateGridWidth() {
      // 描画後に実行
      if (document.getElementsByClassName('k-grid-content-locked').length !== 0) {
        // 固定列数のカウント
        const lockedColumns = this.columns
          .filter(col => col.locked === true && col.hidden === false).length;

        // 固定列幅算出
        // ソートモード以外では -1 する(ダミー列)
        const sortColumn = this.isSortMode ? 0 : 1;
        let lockedColumnWidth = (lockedColumns - sortColumn) * this.columnWidth;
        if (this.lockedColumnsWidth) {
          lockedColumnWidth = this.lockedColumnsWidth;
        }
        // リサイズする前のscroll値を取得する
        let tmpScrollLeft = 0;
        let tmpScrollTop = 0;
        if (this.editFlg) {
          tmpScrollLeft = this.scrollLeft;
          tmpScrollTop = this.scrollTop;
          this.editFlg = false;
        } else {
          tmpScrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
          tmpScrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
        }

        // スマートフォン以外で固定行有：空白行幅の調整値
        const targetWidth = ((this.androidFlg || this.iosFlg) || lockedColumnWidth == 0) ? 0 : 14;
        // kendoGridのリサイズを呼び出して自動リサイズがされないケースがある問題に対応
        if (this.$refs.grid != null) {
          const index = this.$refs.grid.kendoWidget()?.columns?.findIndex((item) => {
            return item.hidden === false && item.field !== 'dummy';
          });
          const setWidth = parseInt(this.$refs.grid.kendoWidget().columns[index].width) + 'em';
          this.$refs.grid.kendoWidget().resizeColumn(this.$refs.grid.kendoWidget().columns[index], setWidth);
        }
        // 固定列の幅確保
        if (!this.isSortMode) {
          document.getElementsByClassName('k-grid-header-locked')[0].style.width = `calc(${lockedColumnWidth}em + 10px)`;
          document.getElementsByClassName('k-grid-content-locked')[0].style.width = `calc(${lockedColumnWidth}em + 10px)`;
        } else {
          document.getElementsByClassName('k-grid-header-locked')[0].style.width = `${lockedColumnWidth}em`;
          document.getElementsByClassName('k-grid-content-locked')[0].style.width = `${lockedColumnWidth}em`;
        }

        if(lockedColumnWidth == 0 ){
          document.getElementsByClassName('k-grid-header-locked')[0].style.width = '10px';
          document.getElementsByClassName('k-grid-content-locked')[0].style.width = '10px';
        }
        // 画面幅よりも固定列の幅が大きくなった場合、可変列のヘッダが見切れるため
        // グリッドサイズを画面幅以上に拡張する
        if (document.getElementsByClassName('k-grid')[0].clientWidth
          < document.getElementsByClassName('k-grid-header-locked')[0].clientWidth
        ) {
          // グリッドサイズ拡張
          document.getElementsByClassName('k-grid')[0].style.width = `${document.getElementsByClassName('k-grid-header-locked')[0].clientWidth
              + 100 + targetWidth}px`;
          // 拡張分の幅で可変列のヘッダ幅定義
          document.getElementsByClassName('k-grid-header-wrap k-auto-scrollable')[0].style.width = `${100 + targetWidth}px`;
        } else {
          document.getElementsByClassName('k-grid')[0].style.width = 'auto';
          const headerLockWidth = (document.getElementsByClassName('k-grid')[0].clientWidth
                                   - document.getElementsByClassName('k-grid-header-locked')[0].clientWidth) + targetWidth;
          // 固定列の幅を確保
          document.getElementsByClassName('k-grid-header-wrap k-auto-scrollable')[0].style.width = `${headerLockWidth}px`;
          let contentScrollableWidth = (document.getElementsByClassName('k-grid')[0].clientWidth
          - document.getElementsByClassName('k-grid-content-locked')[0].clientWidth);
          const arr = ['sys_facility', 'mst_facility', 'mst_favorite_facility'];
          let mstArr = ['mst_user', 'mst_dialyzer', 'mst_medicine', 'mst_equipment', 'mst_obs_kind', 'mst_procedure',
                        'mst_water_survey_type', 'mst_water_survey_point', 'mst_pat_memo', 'mst_pat_list_layout'];
          if (arr.includes(this.masterPhysicalName) && !this.androidFlg && !this.iosFlg && lockedColumnWidth !== 0 ||
              ((lockedColumns === 1 && this.isSortMode) || mstArr.includes(this.masterPhysicalName))
            ) {
            contentScrollableWidth += 17;
          }
          document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].style.width = `${contentScrollableWidth}px`;
        }

        if (document.getElementsByClassName('k-grid-content').length !== 0
          && document.getElementsByClassName('k-grid-content-locked')[0].clientHeight
          !== document.getElementsByClassName('k-grid-content')[0].clientHeight
          && !this.androidFlg && !this.iosFlg
        ) {
          document.getElementsByClassName('k-grid-content-locked')[0].style.height = `${document.getElementsByClassName('k-grid-content')[0].offsetHeight - 17}px`;
          }
        // add 医療材料セットマスタ スクロール位置を取得 start 鞠
        if (this.masterPhysicalName == 'mst_equipment') {
          this.setScrollPositionLeft(this.scrollPosition);
        }
        // add 医療材料セットマスタ スクロール位置を取得 end 鞠
        // 固定列の幅確保後、リサイズする前のscroll値を設定
        setTimeout(() => {
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft = tmpScrollLeft;
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop = tmpScrollTop;
        });
        // 施設マスタ 並び順の行と行がずれる 宋qy start
        if (this.masterPhysicalName == 'mst_facility') {
          var table0 = document.getElementsByClassName('k-selectable')[0];// 固定列table
          var rows0 = table0.rows;
          var table1 = document.getElementsByClassName('k-selectable')[1];// 左右移動列table
          var rows1 = table1.rows;
          for(var i=0; i < rows0.length; i++){
            var row0 = rows0[i];
            var row1 = rows1[i];
            if (row0.clientHeight < 65 && row1.clientHeight >= 65) {
              row0.style.height = `${65}px`;
            }
          }
        }
        // 施設マスタ 並び順の行と行がずれる 宋qy end
      }
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName('header'))
          .pop().clientHeight;
        // フッターメニューの高さ
        // const fmh =
        //   this.isDispMenu === 1
        //     ? document.getElementById("footer-menu").clientHeight
        //     : 0;
        const fmh = (this.isDispMenu === 1
          ? document.getElementById('footer-menu').clientHeight
          : 0) + 5;
        const kendoToolbarHeight = wh - hh - fmh;
        this.kendoGridToolbarHeight = kendoToolbarHeight > 100 ? kendoToolbarHeight : 100;
        // 追加ボタンや並び替えボタンエリアの高さ
        let ghd = 45;
        if (document.getElementById('grid-header')) {
          ghd = document.getElementById('grid-header').clientHeight;
        }
        // キャンセルボタンや保存ボタンエリアの高さ
        let gfh = 0;
        if (document.getElementById('grid-footer')) { gfh = document.getElementById('grid-footer').clientHeight; }
        // グリッドの高さ
        // add 鞠 start 患者メモの一覧と保存ボタンの間に無駄な余白がある 4550
        let tableToolbar = 0
        if (document.getElementsByClassName('header-btn-area') && document.getElementsByClassName('header-btn-area').length) {
          tableToolbar = document.getElementsByClassName('header-btn-area')[0].clientHeight
        }
        if (this.masterPhysicalName == 'mst_pat_memo') {
          /** 
           * NOTE: 患者メモマスタ
           * 本画面は、一覧上部に追加などのボタンが無いため、そのエリアの高さ分の調整をここで実施
           * ただし、モバイルでアクセスした場合、トグルが表示されるため、その考慮も含めて調整している
           * (let ghd = 45)
           */
          const headerHeight = document.getElementById('grid-header') ? 0 : 45;
          this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + ghd) + headerHeight;
        }else{
        // add 鞠 end 患者メモの一覧と保存ボタンの間に無駄な余白がある 4550
          // this.kendoGridHeight = this.kendoGridToolbarHeight - gfh;
          this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + tableToolbar);
        }
        // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
        if((this.masterPhysicalName == 'mst_medicine' || this.masterPhysicalName == 'mst_disease') && document.getElementsByClassName('k-virtual-scrollable-wrap')[0]){
        // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
          document.getElementsByClassName('k-virtual-scrollable-wrap')[0].scrollTop = 0;
        }
        // add 鞠 start 外スクロールを隠す 4559文字サイズ：特大の際にレイアウトが崩れる
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 start
        // if (this.masterPhysicalName == 'mst_medicine_set' || this.masterPhysicalName == 'mst_treatment') {
        const masterPhysicalNameGroup = ['mst_medicine_set', 'mst_device_edge', 'mst_treatment', 'mst_job', 'mst_machine', 'mst_bed', 'mst_room_bed_group', 'mst_wheel_chair', 'mst_relationship', 'mst_taboo_allergy', 'mst_infection', 'mst_implant', 'mst_severity', 'mst_transport', 'mst_dialysis_difficulty', 'mst_course', 'mst_ward', 'mst_disease', 'mst_insurance', 'mst_va', 'mst_medicate_timing', 'mst_medicine_class', 'mst_equipment_class', 'mst_equipment_set', 'mst_round_type', 'mst_add_monitor', 'mst_bbs_kind', 'mst_pat_viewer_layout', 'mst_treatment_status_layout', 'mst_com_fixed_phrase', 'mst_destination_group'];
        if (masterPhysicalNameGroup.includes(this.masterPhysicalName)) {
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 end
          if (document.getElementsByClassName('main-content-area') && document.getElementsByClassName('main-content-area')[0]) {
            document.getElementsByClassName('main-content-area')[0].style.overflowY = 'hidden'
            document.getElementsByClassName('main-content-area')[0].style.overflowX = 'hidden'
          }
        }
        // add 鞠 end 外スクロールを隠す 4559文字サイズ：特大の際にレイアウトが崩れる
        if((this.masterPhysicalName == 'mst_machine_record_control') && this.iosFlg) {
          document.getElementsByClassName('k-scrollbar k-scrollbar-vertical')[0].style.width = '100%';
          document.getElementsByClassName('k-scrollbar k-scrollbar-vertical')[0].style.zIndex = '-1';
        }
      }
    },
    changeEditColor(currentTrc, currentLockTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更(固定列と可変列の行数は一致)
      for (let lockClCount = 0; lockClCount < currentLockTrc.length; lockClCount++) {
        // 固定列セル:並び順以外の編集列
        if (
          this.isEditRow(currentLockTrc[lockClCount])
          && lockClCount !== this.getColumnIndex('sortRank')
        ) {
          currentLockTrc[lockClCount]?.classList?.add('master-edited-cell');
          edited = true;
        }
      }

      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        // 可変列セル
        if (
          this.isEditRow(currentTrc[clCount])
        ) {
          currentTrc[clCount]?.classList?.add('master-edited-cell');
          edited = true;
        }
      }
      return edited;
    },
    editBackgroundColor(masterName = null) {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.grid?.$el?.firstChild;
        // gridを使用していないマスタ(e.g.愁訴処置マスタ)があるため、gridHeaderの存在有無もチェックする
        if (!gridHeader || gridHeader.textContent === ' ') {
          return;
        }
        gridHeader?.classList?.add('master-grid-header');

        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }
        // 固定列、可変列、データソースの取得
        const tbodyc = this.$refs.grid.$el.lastChild.lastChild
          .tBodies[0].children;
        const lockTbodyc = this.$refs.grid.$el.children[1].lastChild
          .tBodies[0].children;
        const gridData = this.$refs.grid.dataSource;
        const dataItem = this.masterPhysicalName === 'mst_exam_item' ? gridData._data : gridData.data
        // 列の行数は固定・可変で同一なため可変列の行数を使用
        let newArr = this.getMasterRecordList?.data?.filter(item => {
          return item.isDisp === "1"
        })
        // newArr.forEach(item => {
        //   item.wheelChairWeight = Number(item.wheelChairWeight).toFixed(2)
        // })
        let oldArr = this.getMasterRecordListOld && this.getMasterRecordListOld.filter(item => {
          return item.isDisp === "1"
        })
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = lockTbodyc[rwCount].children;
          // 並び順の色変更
          this.changeSortColor(currentLockTrc);
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);

          // モーダルからの編集も色を変更する
          if (
            dataItem[rwCount] && this.isEdited(dataItem[rwCount].code)
          ) {
            edited = true;
          }
          // 対応範囲のテーブルのみ、operation = 1 (新規) の行に、k-dirty-cell" を入れる
          if (masterName != null
              && masterName === 'mst_alarm_notification'
              && dataItem[rwCount].operation
              && dataItem[rwCount].operation === 1) {
            edited = true;
          }
          // mod #9605 2023/08/30 EOL対応 朴 start
          // if (this.pageTypeName === 'MstWheelChairMainComponent') {
          if (this.pageTypeName === 'MstWheelChairMainComponent' && oldArr && newArr) {
          // mod #9605 2023/08/30 EOL対応 朴 end
            const gridLock = this.$refs.grid.$el.children[1].children[0].children[1];
            // #9863 vue.esm.js:1906 TypeError: Cannot read properties of undefined (reading 'upDate') 横展開2 linjunfeng start
            // if (oldArr && oldArr[rwCount] && oldArr[rwCount].upDate && !newArr[rwCount].upDate) {
              if (oldArr && oldArr[rwCount] && oldArr[rwCount].upDate && newArr[rwCount] && !newArr[rwCount].upDate) {
            // #9863 vue.esm.js:1906 TypeError: Cannot read properties of undefined (reading 'upDate') 横展開2 linjunfeng end
              delete oldArr[rwCount].upDate
            }
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleDate')" 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].scaleDate) {
              if (newArr && newArr[rwCount] && newArr[rwCount].scaleDate && oldArr[rwCount]) {
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleDate')" 横展開2 linjunfeng end 
              oldArr[rwCount].scaleDate = newArr[rwCount].scaleDate
            }
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].scaleUserId) {
              if (newArr && newArr[rwCount] && newArr[rwCount].scaleUserId && oldArr[rwCount]) {
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng end
              oldArr[rwCount].scaleUserId = newArr[rwCount].scaleUserId
            }
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].patId) {
              if (newArr && newArr[rwCount] && newArr[rwCount].patId && oldArr[rwCount]) {
            // #9863 Error in nextTick: "TypeError: Cannot set properties of undefined (setting 'scaleUserId')" 横展開2 linjunfeng end
              oldArr[rwCount].patId = newArr[rwCount].patId
            }
            // #9863 Cannot set properties of undefined (setting 'operation') 横展開2 linjunfeng start
            // if (newArr && newArr[rwCount] && newArr[rwCount].operation) {
              if (newArr && newArr[rwCount] && newArr[rwCount].operation && oldArr[rwCount] && oldArr[rwCount].operation) {
            // #9863 Cannot set properties of undefined (setting 'operation') 横展開2 linjunfeng end
              oldArr[rwCount].operation = newArr[rwCount].operation
            }
            if (JSON.stringify(oldArr[rwCount]) === JSON.stringify(newArr[rwCount])) {
              edited = false;
              if (gridLock.children[rwCount].children[3].children[0]) {
                gridLock.children[rwCount].children[3].children[0].remove();
                gridLock.children[rwCount].children[3].setAttribute('class', '');
              }
            }
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          // add FNSI-8131 劉全航 start
          if(dataItem[rwCount] && dataItem[rwCount].operation && dataItem[rwCount].operation == 1){
            continue;
          }
          // add FNSI-8131 劉全航 end
          // データ参照エラーコンボの背景色を変更
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
        }
      });
    },
    /* add スクロール位置を保存 楊 start */
    setLastScroll() {
      if(this.scrollTop !== 0) {
        this.lastScrollTop = this.scrollTop;
      }
      if(this.scrollLeft !== 0) {
        this.lastScrollLeft = this.scrollLeft;
      }
    },
    /* add スクロール位置を保存 楊 end */
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable = column.field == 'sortRank'
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
      // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません start
      if (this.masterPhysicalName == 'mst_vital_graph') {
        this.columns.filter(column => (column.field=='name' || column.field=='isDisp'))
        .forEach(column => {
          const temp = this.getMasterRecordList.data.filter(item => item.isDisp == '1').sort((a, b) => a.code-b.code);
          const maxCode = temp.length>6 ? temp[5].code : temp[temp.length-1].code;
          column.editable = (e) => e.code > maxCode;
        });
      }
      // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません end
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable = column.field == 'sortRank'
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === 'sortRank',
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === 'dummy');
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
    },
    setScrollPosition(position) {
      $('div.k-grid-content')
        .scrollTop(position.top)
        .scrollLeft(position.left);
    },
    // add 医療材料セットマスタ スクロール位置を取得 start 鞠
    setScrollPositionLeft(position) {
      $('div.k-grid-content')
      .scrollLeft(position.left);
    },
    // add 医療材料セットマスタ スクロール位置を取得 end 鞠
    changeSortColor(currentTrc) {
      // 並び順が変更されていれば並び順とダミー項目背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount])
          && clCount === this.getColumnIndex('sortRank')
        ) {
          currentTrc[clCount]?.classList?.add('master-sort-edited');
          const dummyIndex = this.getColumnIndex('dummy');
          if (dummyIndex > -1) {
            currentTrc[dummyIndex]?.classList?.add('master-sort-edited');
          }
        }
      }
    },
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? 'master-deleted-row' : 'master-edited-row';

        // 固定列（ソート順付）：ソート順後のみ
        for (
          let lockClCount = this.getColumnIndex('sortRank') + 1;
          lockClCount < currentLockTrc.length;
          lockClCount++
        ) {
          currentLockTrc[lockClCount]?.classList?.add(addClass);
        }
        // 可変列：全列対象
        for (
          let clCount = 0;
          clCount < currentTrc.length;
          clCount++
        ) {
          currentTrc[clCount]?.classList?.add(addClass);
        }
      }
      //// add kang 9074 start
      else {
        const removeClass = deleted ? 'master-deleted-row' : 'master-edited-row';

        const removeEditCellClass = "master-edited-cell";
        const removeDirtyCellClass = "k-dirty-cell";
        // 固定列（ソート順付）：ソート順後のみ
        for (
            let lockClCount = this.getColumnIndex('sortRank') + 1;
            lockClCount < currentLockTrc.length;
            lockClCount++
        ) {
          currentLockTrc[lockClCount]?.classList?.remove(removeClass);
          currentLockTrc[lockClCount]?.classList?.remove(removeEditCellClass);
          currentLockTrc[lockClCount]?.classList?.remove(removeDirtyCellClass);
        }
        // 可変列：全列対象
        for (
            let clCount = 0;
            clCount < currentTrc.length;
            clCount++
        ) {
          currentTrc[clCount]?.classList?.remove(removeClass);
          currentTrc[clCount]?.classList?.remove(removeEditCellClass);
          currentTrc[clCount]?.classList?.remove(removeDirtyCellClass);
        }
      }
      // add kang 9074 end
    },
    changeRefErrorComboColor(currentTrc, rowDeleted, ...[currentLockTrc]) {
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }

      let mergedCurrentTrc = currentTrc;
      if (currentLockTrc) {
          // 固定例、可変列のカラムをマージする
          // データ参照エラーコンボの背景色を変更でstate.columnsを元にチェックを実施しているためstate.columnsと合わせる必要がある
          mergedCurrentTrc = [...currentLockTrc, ...currentTrc];
      }
      // 固定例、可変列のDOMのカラム数とapiから取得したカラム数が違う場合は処理しない
      if (mergedCurrentTrc.length != this.columns.length) {
        console.log("プルダウンチェックskip -> DOM column数:::" + mergedCurrentTrc.length + ":::API取得 column数:::" + this.columns.length);
        return;
      }

      // DOMのcodeの位置取得
      // state.columnsでcodeより後ろの項目が固定列に設定されている場合、codeも固定列に設定されていないとDOMとstate.columnsでcodeの位置に差異が生じる
      // DOMでは固定列が可変列よりも前に表示されるのを考慮してcodeの位置を取得する
      let indexColCode = this.getColumnIndex('code');
      if (indexColCode == -1) {
        return;
      }

      const colCode = this.columns[this.getColumnIndex('code')];
      if (!colCode.locked) {
        // codeより後ろの項目が固定列に指定されている場合はDOMのcodeの位置を後ろにずらす
        for (let clCount = this.getColumnIndex('code')+1; clCount < this.columns.length; clCount++) {
          let colCodeNext = this.columns[clCount];
          if (colCodeNext.locked) {
            indexColCode++;
          }
        }
      }

      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < mergedCurrentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // #9863 加算マスタ詳細を開くとtypeエラーが発生する linjunfeng start
          // mergedCurrentTrc[indexColCode].textContent,
          mergedCurrentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // #9863 加算マスタ詳細を開くとtypeエラーが発生する linjunfeng end
          columnInfo.field,
        );
        if (
          columnInfo.values !== null
          && hasValueColumn
          && mergedCurrentTrc[clCount].textContent === ''
        ) {
          mergedCurrentTrc[clCount]?.classList?.add('master-deleted-combo');
        }
      }
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains('k-dirty-cell');
    },
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key) || key == 'isAddRow')
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return '';

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = '</br>&nbsp&nbsp・';
      return prefix + unique.join(prefix);
    },
    toRankEditBtnClick() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $('div.k-grid-content')[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;
      EventBus.$emit('onCloseMasterEditModal', this.onCloseMasterEditModal);

      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit('setSortMode', this.isSortMode);
    },
    sort() {
      const compare = (a, b) => a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      // グリッドデータの並び替え
      this.getMasterRecordList.data.sort(compare);
      // 並び順を採番しなおす
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        if(this.getMasterRecordList.data[i].isDisp === '1' ) { this.getMasterRecordList.data[i].sortRank = i + 1; }
      }
    },
    sortBtnClick() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $('div.k-grid-content')[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;
      EventBus.$emit('onCloseMasterEditModal', this.onCloseMasterEditModal);

      const tempData = deepCopy(this.getMasterRecordList.data);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      EventBus.$emit('setSortMode', this.isSortMode);
    },
    sortChange(tempData){
      let flag = false;
      this.getMasterRecordList.data.forEach( item => {
        tempData.forEach( tempItem => {
          if(item.code === tempItem.code && item.sortRank !== tempItem.sortRank) { flag = true; }
        })
      })
      return flag;
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    // 共同マスターBUG修正 Du start
    getisChanged() {
      const {data} = this.getMasterRecordList;
      return (
        this.getStateUserAccountInfo !== null
        && data !== undefined
        && (this.$store.getters['master-maintenance/isRecordModified'] || !this.kendoValidator.validate())
      );
    },
    // 共同マスターBUG修正 Du end
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
        && document.getElementsByTagName('ons-alert-dialog').length === 0) {
        if (this.getisChanged()) {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.findList();
              }
            },
          });
        }
        else {
          this.findList();
        }
      }
    },
    editStart(e) {
      if (this.androidFlg) {
        this.editingFlg = true;
      }
      let dirtyNum = document.getElementsByClassName('k-dirty-cell').length;
      if (dirtyNum > 0) {
         let count = 0;
          while(dirtyNum > count){
            // document.getElementsByClassName('k-dirty-cell')[count].style.overflow = 'hidden';
            count++;
          }
      }
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 start
      this.$nextTick(()=>{
        // add start #9185
        if (e.sender?.editable?.options?.fields?.field === 'isDisp') {
          const element = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0];
          element.scrollTo({
            left: element.scrollWidth - element.clientWidth,
            behavior: 'smooth'
          });
        }
        // add end #9185
        if (document.getElementsByClassName('k-input k-textbox') && document.getElementsByClassName('k-input k-textbox')[0]) {
          document.getElementsByClassName('k-input k-textbox')[0].setAttribute('title', '');
        }
        // #9185 マウスが止まるとのtipsが現れました linjunfeng start
        if (document.getElementsByClassName('k-edit-cell')[0]?.children[0]?.title) {
          document.getElementsByClassName('k-edit-cell')[0].children[0].title = ""
        }
        // #9185 マウスが止まるとのtipsが現れました linjunfeng end
      })
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 end
    },
    editEnd() {
      this.editingFlg = false;
    },
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (this.isEditRow(currentTrc[clCount])) {
          if (
            currentTrc[clCount].children[0].nextSibling
            && currentTrc[clCount].children[0].nextSibling.data === '削除'
            && this.getColumnIndex('isDisp') === clCount
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // add マスタ障害対応 No274 王 start
      let rows = null;
      if (this.masterPhysicalName === 'mst_medicate_timing') {
        rows = gridData.data.filter(row => row.isDisp !== '0' && row.isDel !== '1');
      } else {
        rows = gridData.data.filter(row => row.isDisp !== '0');
      }
      // add マスタ障害対応 No274 王 end
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < rows.length; idx++) {
        if(this.masterPhysicalName =='mst_mainte_layout_group' && !rows[idx].layoutList) {
          validateMessageArr.push(this.columns.find( e => e.field == 'layoutList').title);
        }
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const {validation} = gridData.schema.model.fields[keys[keyCount]];
          if (typeof validation !== 'undefined' && validation.required) {
            if (
              rows[idx][keys[keyCount]] !== null
              && rows[idx][keys[keyCount]] === ''
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount],
              );
              if (keys[keyCount] === 'additionKind') {
                validateMessageArr.push('加算種別');
              } else {
                // 項目名が重複していなければ、メッセージに追加
                validateMessageArr.push(columnInfo.title);
              }
            }
          }
        }
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy start
        if(this.masterPhysicalName == 'mst_function_report' && !rows[idx].reportCd){
          validateMessageArr.push(this.columns.find( e => e.field == 'reportCd').title);
        }
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy end
        // add ＃9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない dou start
        if (this.masterPhysicalName === "mst_monitor_graph") {
          if (validateMessageArr.includes("左項目") && !validateMessageArr.includes("右項目")) {
            validateMessageArr = validateMessageArr.filter(x => x.includes("右"));
          }
          if (validateMessageArr.includes("右項目") && !validateMessageArr.includes("左項目")) {
            validateMessageArr = validateMessageArr.filter(x => x.includes("左"));
          }
          if (validateMessageArr.includes("右項目") && validateMessageArr.includes("左項目")) {
            validateMessageArr = ["左項目または右項目"];
          }
        }
        // add ＃9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない dou end
      }
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      // コンボ項目のfieldを取り出す
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({
          field: column.field,
          title: column.title,
          values: column.values,
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      // mod 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
      // let rows = gridData.data.filter(row => row.isDisp !== "0");
      let rows = gridData.data.filter(row => row.isDisp !== '0' && row.isDel === '0');
      // mod 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
      // add  No4355 患者イベントカテゴリマスタでカテゴリ名を削除すると患者イベントサブカテゴリマスタで削除できなくなる 鞠 start
      if (this.masterPhysicalName === 'mst_pat_event_sub_category'){
        rows = gridData.data.filter(row => row.isDel !== '0' && row.categoryCd);
      }
      // add  No4355 鞠 end

      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue,
          );
          if (this.masterPhysicalName == 'mst_wheel_chair' && rows[rowIdx].isPersonal == '0' && comboFields[comboIdx].field == 'patId') {
            continue;
          }
          //EOL対応内部 6951 add start ljx
          //別のマスタを用いる場合がある。利用する別のマスタが削除される場合、全チェックのため、編集行以外は保存不可の制御がある。
          //今回の修正としては、全チェックではなく、編集行のみにチェックを行うことにする。
          //編集行の場合、operationは値がある。1（追加）・2（編集）
          if(rows[rowIdx].operation == undefined){
            continue;
          }
          //EOL対応内部 6951 add end ljx
          if (index < 0 && (columnValue !== null && columnValue !== '')) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    onSave(ev) {
      // スクロールの位置を維持
      this.scrollLeft = ev.sender._scrollLeft;
      this.scrollTop = ev.sender.wrapper[0].children[2].scrollTop;
      this.editFlg = true;

      this.editingFlg = false;
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      // 状態に合わせて背景色を変更
      // 内部 背景色と保存ボタンの状態が異常です start
      !this.isRecordModified && this.editBackgroundColor();
      // 内部 背景色と保存ボタンの状態が異常です end
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $('div.k-grid-content')[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;

      // モーダルを表示
      this.showMasterEdit();

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      let selectedRowItem = row.dataItem(e.currentTarget.closest('tr'));
      let {code} = selectedRowItem;
      // add start #9301
      if (this.masterPhysicalName === 'mst_medicine_mix') {
        if (selectedRowItem.isAddRow) {
          selectedRowItem.medicateTimingCd = this.defaultMedicateTimingDataCd;
          selectedRowItem.procedureCd = this.defaultProcedureCd
        }
      }
      // add end #9301
      let newHoliday = [];
      if(this.masterPhysicalName == 'mst_holiday') {
        let editMstHoliday = this.getMasterRecordList.data.filter(e => e.code == selectedRowItem.code+1);
        if (editMstHoliday.length > 0 && editMstHoliday[0].holiday){
          JSON.parse(selectedRowItem.holiday).forEach(e => {
            if(!e.class) e.class = selectedRowItem.class;
            if(e.class == selectedRowItem.class) { newHoliday.push(e); }
          })
          JSON.parse(editMstHoliday[0].holiday).forEach(e => {
            if(!e.class) e.class = editMstHoliday[0].class;
            newHoliday.push(e);
          })
        }
      }
      if (newHoliday.length > 0) {
        selectedRowItem.holiday = JSON.stringify(newHoliday);
      }
      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = this.getMasterRecordList.data[0].code;
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
        // #9863 Error in nextTick: "TypeError: Cannot read properties of undefined (reading '$el')" 横展開2 linjunfeng start
        // this.editBackgroundColor()
        // #9863 Error in nextTick: "TypeError: Cannot read properties of undefined (reading '$el')" 横展開2 linjunfeng end
      }, 1000);
    },
    importCsv() {
      // グリッドでエラーが発生している場合は処理を中断
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }

      this.masterCsvTarget = event.target;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.editBackgroundColor();
    },
    addInputAssist() {
      /* add スクロール位置を保存 楊 start */
      this.lastInputScrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].firstChild.scrollLeft;
      /* add スクロール位置を保存 楊 end */
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.iosFlg) {
        if (document.getElementsByClassName('k-numerictextbox').length !== 0) {
          let spinnerObj = document
            .getElementsByClassName('k-numerictextbox')[0]
            .getElementsByClassName('k-select')[0];
          // 編集が終了するとオブジェクトが削除される為、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
    /**
     * @description 患者選択
     * @summary 選択した患者の患者情報レコードをストアに格納する
     * @param {Number} selectedPatId 患者ＩＤ
     */
    async setSelectedPatHeader(selectedPatId) {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      try {
        await this.clearSelectedPatToHeader();
        if (selectedPatId === null) {
          // ？？？？患者
          await this.setIsNullPat(true);
        } else {
          await this.selectPatToHeader(selectedPatId);
        }
      } catch {
        // TODO: エラー処理ちゃんと考える
        throw new Error("[PatHeader.vue]setSelectedPat(): 患者選択失敗");
      } finally {
        this.setLoadingScreenVisible(false);
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
    /**
     * コピー追加ボタン押下時処理
     */
    copyAdd(e) {
      // グリッドでエラーが発生している場合は処理を中断
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }
      this.masterCopyAddTarget = e.target;
      this.masterCopyAddVisible = true;
    },
    prehideCopyAddPopover() {
      this.masterCopyAddVisible = false;
      this.editBackgroundColor();
    },
  },
}
