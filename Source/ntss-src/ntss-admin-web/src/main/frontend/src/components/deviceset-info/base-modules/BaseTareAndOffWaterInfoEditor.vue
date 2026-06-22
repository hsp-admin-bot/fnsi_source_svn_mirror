<!-- 風袋・除水補正 -->
<template>
  <div class="tare-off-water-grid custom-tare-off-water-grid">
    <v-ons-row>
      <v-ons-col style="text-align: start;">
        <v-ons-segment style="width: 120px;" v-model:index="segmentIndex">
          <button value="0" class="segment-button" @click="selectUnit">g
          </button>
          <button value="1" class="segment-button" @click="selectUnit">kg
          </button>
        </v-ons-segment>
      </v-ons-col>
    </v-ons-row>

    <v-touch v-on:swipeleft="selectNextWeek" v-bind:swipe-options="{ direction: 'left', threshold: 70 }">
      <v-touch v-on:swiperight="selectPreWeek" v-bind:swipe-options="{ direction: 'right', threshold: 70 }">
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
        <div
          :key="refreshKey"
          ref="tareAndOffWaterInfoGrid"
          class="tare-off-water-direct-grid ntss-kendo-grid-legacy"
          :class="targetTable === 1 ? 'tare-offwater' : null"
        ></div>
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
      </v-touch>
    </v-touch>
  </div>
</template>
<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
/**
 * 共通処理用
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import { deepCopy } from "@/functions/common/CommonFunctions";
/**
 * jQuery
 */

/**
 * 日時操作
 */
import dayjs from "@/compat/date/dayjs";
/**
 * オブジェクト、配列操作
 */

/**
 * Vue関連
 */
// #8061-装置設定が保存出来ない 周 mod start
//import { mapGetters } from "@/compat/vue/vuex";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
// #8061-装置設定が保存出来ない 周 mod end
import { EventBus } from "@/compat/vue/event-bus.js";

/**
 * 小数点計算
 */
import BigNumber from "@/compat/number/bignumber";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { FUNC_PAT_INFO } from "@/constants/function-code";
import { getScopedWindow, getScopedJQuery, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";
import DeviceSetOwnerMixin from '@/components/deviceset-info/base-modules/DeviceSetOwnerMixin';

function installComponentJQuery() {
  if (typeof window !== "undefined") {
    window.$ = window.$ || $;
    window.jQuery = window.jQuery || $;
  }
  if (typeof globalThis !== "undefined") {
    globalThis.$ = globalThis.$ || $;
    globalThis.jQuery = globalThis.jQuery || $;
  }
  // @progress/kendo-ui import は jQuery plugin 登録の side effect 用。
  return kendo;
}

function mountDirectNumericTextBox(element, options) {
  installComponentJQuery();
  const $element = $(element);
  $element.kendoNumericTextBox(options);
  return $element.data("kendoNumericTextBox");
}

function getDirectKendoWidgetValue(widget) {
  return typeof widget?.value === "function" ? widget.value() : widget?.element?.val?.();
}

function setDirectKendoWidgetValue(widget, value) {
  if (typeof widget?.value === "function") {
    widget.value(value);
  } else {
    widget?.element?.val?.(value);
  }
}
import $ from "@/compat/jquery";
import kendo from "@progress/kendo-ui";
import { bindGridEditorEnterToCloseCell } from "@/compat/kendo/grid-edit";
// add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end

export default {
  mixins: [DeviceSetOwnerMixin],
  props: {
    /**
     * オーダー番号
     */
    propsOrdNo: {
      type: Number,
      default: null
    },
    /**
     * 患者ID
     */
    propsPatId: {
      type: Number,
      default: null
    },
    /**
     * 施設コード
     */
    propsFacilityCd: {
      type: String,
      default: null
    },
    /**
     * テーブルフラグ
     */
    propsTableFlag: {
      type: Number,
      required: true
    },
    /**
     * 風袋・除水補正フラグ
     * 0->風袋、1->除水補正
     */
    propsTareOffWaterInfoFlag: {
      type: Number,
      required: true
    },
    /**
     * モーダル表示データ
     */
    propsModalData: {
      type: Object,
      default: null
    }
  },

  data() {
    return {
      segmentIndex: 0,
      /**
       * Kendo UI内部データ
       */
      localDataSource: {
        schema: {
          model: {
            id: "rowNum",
            fields: {
              rowTitle: { nullable: false }
            }
          }
        },
        data: []
      },
      /**
       * 選択曜日
       * 1->月、2->火、3->水、4->木、5->金、6->土、7->日
       * デフォルト値は月
       */
      selectedWeek: "1",
      /**
       * マルチヘッダー列データ
       */
      multColumnList: [],
      /**
       * 対象テーブル
       * 0->装置設定デフォルトマスタ、1->患者情報、2->治療情報
       */
      targetTable: this.propsTableFlag,
      /**
       * 変更比較(変更前)データ
       */
      initValue: {},
      /**
       * 変更比較(変更後)データ
       */
      editValue: {},
      /**
       * 選択中の単位
       * 0->g, 1->kg
       * ※初期値は「g」
       */
      selectedUnit: 0,
      /**
       * オーダー番号
       */
      ordNo: this.propsOrdNo,
      /**
       * 患者ID
       */
      patId: this.propsPatId,
      /**
       * 施設コード
       */
      facilityCd: this.propsFacilityCd,
      /**
       * 治療情報リスト(対象患者のすべての治療情報)
       */
      ordMainList: [],
      /**
       * 治療情報反映対象リスト
       */
      reflectOrdMainDataList: [],
      /**
       * 警告表示対象リスト
       */
      alertOrdMainList: [],
      /**
       * スクロール位置
       */
      scrollPos: 0,
      /**
       * スワイプ可能フラグ
       */
      swipeFlag: true,
      /***
       * 更新日時
       */
      upDate: null,
      /**
       * 移動可能フラグ
       */
      isMove: true,
      /**
       * 更新対象オーダー番号
       */
      ordNoList: [],
      /**
       * 更新対象情報
       */
      targetUpdateInfo: {},
      /**
       * 編集可・不可切替
       */
      disEdit: this.propsTableFlag === 3,
      /**
       * IOS端末使用フラグ
       */
      iosFlg: false,
      refreshKey: 0,
      // mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false,
      // mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
      // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      editFlag: null,
      directGridWidget: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      /** Grid初期描画: DOM準備完了 */
      isGridDomReady: false,
      /** Grid初期描画: DBデータ読込完了 */
      isGridDataReady: false,
      /** Grid初期描画済み */
      isInitialGridRendered: false,
      // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end
      /**
       * モーダル表示データ
       */
      modalData: this.propsModalData,
    };
  },

  computed: {
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),

    /**
     * 曜日列ヘッダータイトル
     */
    columnHeaderTitle() {
      return this.convertStrWeek(Number(this.selectedWeek));
    },

    /**
     * 曜日列ヘッダークラス
     */
    columnHeaderClass() {
      // 患者情報以外のテーブル参照時
      if (1 !== this.targetTable) {
        return { class: "deviceSetInfo-first-header" };
      } else {
        // 平日列編集時
        return { class: "deviceSetInfo-header-first-name" };
      }
    },

    /**
     * 装置設定デフォルトマスタ等は単行ヘッダー（項目/名称/重さ）で表示
     */
    isFlatHeaderLayout() {
      return 1 !== this.targetTable;
    },

    /**
     * 単位
     */
    unit() {
      if (0 === this.selectedUnit) {
        // 「g」選択中
        return "g";
      } else {
        // 「kg」選択中
        return "kg";
      }
    },

    /**
     * 更新時DBカラム名
     * @description スネークケース
     * 風袋->tare_info, 除水補正->off_water_info
     */
    columnName() {
      return 0 === this.propsTareOffWaterInfoFlag
        ? "tare_info"
        : "off_water_info";
    },

    /**
     * kendoNumericTextBox最小値
     */
    numericMinValue() {
      if (0 === this.selectedUnit) {
        // 「g」選択時
        return 0 === this.propsTareOffWaterInfoFlag ? -300000 : -30000;
      } else {
        // 「kg」選択時
        return 0 === this.propsTareOffWaterInfoFlag ? -300.0 : -30.0;
      }
    },

    /**
     * kendoNumericTextBox最大値
     */
    numericMaxValue() {
      if (0 === this.selectedUnit) {
        // 「g」選択時
        return 0 === this.propsTareOffWaterInfoFlag ? 300000 : 30000;
      } else {
        // 「kg」選択時
        return 0 === this.propsTareOffWaterInfoFlag ? 300.0 : 30.0;
      }
    },

    /**
     * kendoNumericTextBoxステップ
     */
    numericStepValue() {
      if (0 === this.selectedUnit) {
        // 「g」選択時
        return 1;
      } else {
        // 「kg」選択時
        return 0.01;
      }
    },

    /**
     * 有効小数点桁数
     */
    numericDecimalsValue() {
      if (0 === this.selectedUnit) {
        // 「g」選択時
        return 0;
      } else {
        // 「kg」選択時
        return 2;
      }
    }
  },

  watch: {
    /**
     * 曜日選択時処理
     * @description 選択された曜日の一覧情報をKendo UIの内部データに設定する
     */
    selectedWeek(week) {
      // editValueに値が格納されている場合処理を実行
      if (Object.keys(this.editValue).length) {
        // 曜日変更により一覧情報を切り替える
        const obj = {};
        // 選択された曜日のObjectを取得
        obj[week] = this.editValue[week];
        // 取得したObjectをGrid用データに変換
        const gridData = this.convertGridData(obj);
        // 変換したデータを内部データに格納
        this.localDataSource.data = gridData;
        // Grid再描画
        this.gridRefresh();
      }
    }
  },

  async created() {
    // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
    this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //#10500：装置設定デフォルトマスタにて風袋と除水補正の編集ができないStart
    this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    //#10500：装置設定デフォルトマスタにて風袋と除水補正の編集ができないEnd
    // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end
    // マルチカラム情報の設定
    this.setMultColumnInfo();
    // 初期データの設定
    this.localDataSource.data = this.setInitLocalData();
    // DB風袋/除水補正情報取得
    const getData = await this.getTareAndOffWaterInfo();
    // DBデータを内部用データに加工
    this.localDataSource.data = this.convertGridData(getData);
    // 合計・書式のみ先に計算（Grid描画は mounted 後に実施）
    await this.calculateSum();
    await this.changeFormat();
    // 変更比較(変更前)データ作成
    this.initValue = this.adjustmentInitValue(this.setInitValue(getData));
    // 変更比較(変更後)データ作成
    this.editValue = deepCopy(this.initValue);
    // 患者情報編集時処理
    if (1 === this.targetTable) {
      // 対象患者のすべての治療情報を取得
      this.getTargetOrdMain();
      // 警告対象の治療情報を取得
      this.getAlertOrdMain();
    }
    // 端末判別
    const ua = getScopedWindow(this.$el || this)?.navigator?.userAgent || "";
    if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add start
    this._deviceSetRootOwner().isDialogType9_offWater = true;
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add end
    this.isGridDataReady = true;
    await this.scheduleInitialGridRefresh();
  },

  mounted() {
    this.isGridDomReady = true;
    this.$nextTick(() => {
      this.scheduleInitialGridRefresh();
    });
  },

  beforeUnmount() {
    this.destroyDirectGrid();
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    // #8061-装置設定が保存出来ない 周 add start
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      startLoadingScreen: "startLoadingScreen",
      finishLoadingScreen :"finishLoadingScreen"
    }),
    // #8061-装置設定が保存出来ない 周 add end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * 初回描画: API読込(created)とDOM生成(mounted)の両方完了後にGridを描画
     */
    async scheduleInitialGridRefresh() {
      if (!this.isGridDomReady || !this.isGridDataReady || this.isInitialGridRendered) {
        return;
      }
      await this.$nextTick();
      await this.gridRefresh();
      this.isInitialGridRendered = true;
    },
    getTareAndOffWaterInfoGridRef() {
      return this.$refs.tareAndOffWaterInfoGrid || null;
    },
    getTareAndOffWaterInfoGridWidget() {
      return this.directGridWidget || this.getTareAndOffWaterInfoGridRef()?.gridWidget?.() || this.getTareAndOffWaterInfoGridRef()?.kendoWidget?.() || null;
    },
    isDirectGridEditable() {
      return !this.disEdit && !this.editFlag && !this.isOtherFacilityRow() && this.getItemAuthorized('Indication', 'item_base_tare_off_water');
    },
    getDirectGridDataSourceOption() {
      return {
        schema: this.localDataSource.schema,
        data: Array.isArray(this.localDataSource.data) ? this.localDataSource.data : []
      };
    },
    createDirectGridDataSource() {
      installComponentJQuery();
      return new kendo.data.DataSource(this.getDirectGridDataSourceOption());
    },
    buildDirectGridColumns() {
      const editable = this.isDirectGridEditable();
      const rowTitleColumn = {
        field: 'rowTitle',
        title: '項目',
        width: 90,
        attributes: { class: 'deviceSetInfo-row-name' },
        headerAttributes: { class: 'deviceSetInfo-header-row-name' },
        editable: () => false
      };
      const dataColumns = (this.multColumnList || []).map(column => ({
        ...column,
        editor: (container, options) => this.setEditor(container, options),
        editable: () => editable
      }));

      if (this.isFlatHeaderLayout) {
        return [rowTitleColumn, ...dataColumns];
      }

      return [
        rowTitleColumn,
        {
          columns: dataColumns,
          title: this.columnHeaderTitle,
          headerAttributes: this.columnHeaderClass,
          headerTemplate: () => this.headerTemplate()
        }
      ];
    },
    getDirectGridColumnSignature() {
      return JSON.stringify({
        editable: this.isDirectGridEditable(),
        flatHeader: this.isFlatHeaderLayout,
        title: this.columnHeaderTitle,
        headerClass: this.columnHeaderClass,
        columns: (this.multColumnList || []).map(column => ({
          field: column.field,
          title: column.title,
          width: column.width,
          format: column.format,
          attributes: column.attributes,
          headerAttributes: column.headerAttributes
        }))
      });
    },
    installDirectGridFacade() {
      const root = this.getTareAndOffWaterInfoGridRef();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.resizeGrid = () => this.directGridWidget?.resize?.(true);
      root.gridRootEl = () => root;
      root.gridContentEl = () => root.querySelector?.('.k-grid-content');
      root.gridTableEl = () => root.querySelector?.('.k-grid-content table, table');
    },
    initDirectGridIfReady() {
      const root = this.getTareAndOffWaterInfoGridRef();
      if (!root || !Array.isArray(this.multColumnList) || this.multColumnList.length === 0) {
        return;
      }
      installComponentJQuery();
      const $root = $(root);
      const existingGrid = $root.data('kendoGrid');
      if (existingGrid) {
        this.directGridWidget = existingGrid;
        this.installDirectGridFacade();
        this.applyDirectGridColumnsContract();
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      $root.kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        columns: this.buildDirectGridColumns(),
        editable: this.isDirectGridEditable(),
        scrollable: false,
        dataBound: () => {
          this.applyDirectGridStyleContract();
          this.addClickEvent();
        },
        edit: event => this.addInputAssist(event),
        save: event => this.onSave(event),
        cellClose: () => {
          this.swipeFlag = true;
        }
      });
      this.directGridWidget = $root.data('kendoGrid') || null;
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.installDirectGridFacade();
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridColumnsContract() {
      const grid = this.getTareAndOffWaterInfoGridWidget();
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridColumnSignature !== nextSignature) {
        grid.setOptions({
          columns: this.buildDirectGridColumns(),
          editable: this.isDirectGridEditable()
        });
        this.directGridColumnSignature = nextSignature;
      }
    },
    applyDirectGridDataSourceContract() {
      const grid = this.getTareAndOffWaterInfoGridWidget();
      if (!grid) {
        return;
      }
      const dataSource = this.createDirectGridDataSource();
      grid.setDataSource(dataSource);
      if (typeof dataSource.read === "function") {
        dataSource.read();
      } else if (typeof grid.refresh === "function") {
        grid.refresh();
      }
      this.applyDirectGridStyleContract();
    },
    applyDirectGridStyleContract() {
      const root = this.getTareAndOffWaterInfoGridRef();
      if (!root) {
        return;
      }
      root.classList.add('ntss-kendo-grid-legacy', 'k-widget', 'k-grid', 'k-editable', 'k-display-block');
      root.querySelectorAll('.k-grid-header th, .k-grid-header .k-table-th').forEach(th => th.classList.add('k-header'));
      ['.k-grid-content tbody', '.k-grid-content-locked tbody'].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children || []).forEach((tr, index) => {
            tr.classList.add('k-master-row');
            tr.classList.toggle('k-alt', index % 2 === 1);
          });
        });
      });
      root.querySelectorAll('.k-grid-content tbody td, .k-grid-content-locked tbody td').forEach(td => {
        td.classList.add('k-td', 'k-table-td');
      });
      this.applyDirectGridHeaderClassContract(root);
      this.applyDirectGridCellClassContract(root);
    },
    applyDirectGridHeaderClassContract(root) {
      const headerClasses = this.isFlatHeaderLayout
        ? [
            'deviceSetInfo-header-row-name',
            ...(this.multColumnList || []).map(column => column?.headerAttributes?.class || '')
          ]
        : ['deviceSetInfo-header-row-name'];
      const headerRows = root.querySelectorAll('.k-grid-header thead tr');
      const targetRow = headerRows[headerRows.length - 1];
      if (!targetRow) {
        return;
      }
      Array.from(targetRow.children || []).forEach((th, index) => {
        const className = headerClasses[index];
        if (typeof className === 'string' && className) {
          className.split(/\s+/).filter(Boolean).forEach(name => th.classList.add(name));
        }
      });
    },
    /**
     * Vue2 kendo-grid-column の attributes 相当のクラスを DOM に付与
     */
    applyDirectGridCellClassContract(root) {
      const columns = [
        { field: 'rowTitle', attributes: { class: 'deviceSetInfo-row-name' } },
        ...(this.multColumnList || [])
      ];
      root.querySelectorAll('.k-grid-content tbody tr, .k-grid-content-locked tbody tr').forEach(tr => {
        Array.from(tr.children || []).forEach((td, index) => {
          const field = columns[index]?.field || '';
          const attributeClass = columns[index]?.attributes?.class;
          if (typeof attributeClass === 'string') {
            attributeClass.split(/\s+/).filter(Boolean).forEach(className => td.classList.add(className));
          }
          td.classList.toggle('deviceSetInfo-name-content', field === 'name');
          td.classList.toggle('deviceSetInfo-weight-content', field === 'weight');
        });
      });
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.getTareAndOffWaterInfoGridWidget()?.resize?.(true);
        this.applyDirectGridStyleContract();
      });
    },
    destroyDirectGrid() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
        this.directGridLayoutRafId = null;
      }
      const root = this.getTareAndOffWaterInfoGridRef();
      const widget = this.getTareAndOffWaterInfoGridWidget();
      try {
        widget?.destroy?.();
      } catch (_error) {
        // noop
      }
      if (root) {
        root.kendoWidget = undefined;
        root.gridWidget = undefined;
        root.resizeGrid = undefined;
        root.innerHTML = '';
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = '';
    },
    traverseGridColumns(columns, onColumn) {
      if (!Array.isArray(columns) || typeof onColumn !== "function") {
        return;
      }
      columns.forEach((column) => {
        if (!column) {
          return;
        }
        onColumn(column);
        if (Array.isArray(column.columns) && column.columns.length) {
          this.traverseGridColumns(column.columns, onColumn);
        }
      });
    },
    syncGridColumnsToWidget() {
      this.initDirectGridIfReady();
      this.applyDirectGridColumnsContract();
    },
    alignGridLayout() {
      this.scheduleDirectGridLayoutContract();
    },
    /**
     * 単位選択
     */
    selectUnit(event) {
      // 変換前単位を取得
      const preUnit = this.selectedUnit;
      // 単位の格納
      this.selectedUnit = Number(event.target.value);
      // 今回変更した単位が直前の単位と違う場合
      if (preUnit !== this.selectedUnit) {
        // 桁数の変換
        this.changeDigit();
      }
      // Grid再描画
      this.gridRefresh();
    },

    /**
     * マルチ列情報の作成
     * @description 名称列と重さ列の情報を設定
     */
    setMultColumnInfo() {
      for (let i = 0; i < 2; i++) {
        const columnName = 0 === i ? "name" : "weight";
        const obj = {
          field: columnName,
          title: 0 === i ? "名称" : "重さ",
          width: "100px",
          editor: this.setEditor,
          headerAttributes: { class: "deviceSetInfo-header-secound-name" },
          attributes: {
            class: `deviceSetInfo-${columnName}-content ${columnName}-item`
          },
          format: ""
        };
        this.multColumnList.push(obj);
      }
    },

    /**
     * 初期Kendo UI内部データ設定
     * @description
     * 初回DBデータの取得、加工処理が終わる前に
     * 画面の立ち上げが終わるため、空のデータを格納
     */
    setInitLocalData() {
      const setData = [];
      for (let i = 1; i <= 6; i++) {
        const inputSetData = {
          // 項目番号
          rowNum: i,
          // 項目名
          rowTitle: `項目${String(i)}`,
          // 名称項目
          name: "",
          // 重さ項目
          weight: null
        };

        // 6行目は最後の行項目名を変更
        if (6 === i) {
          inputSetData.rowTitle =
            0 === this.propsTareOffWaterInfoFlag
              ? "風袋補正合計量"
              : "除水補正合計量";
        }
        setData.push(inputSetData);
      }
      return setData;
    },

    /**
     * 曜日変換
     * @description 数値から漢字表記文字列に変換
     *
     */
    convertStrWeek(code) {
      switch (code) {
        case 1:
          return "月";

        case 2:
          return "火";

        case 3:
          return "水";

        case 4:
          return "木";

        case 5:
          return "金";

        case 6:
          return "土";

        case 7:
          return "日";

        default:
          // 異常値
          return;
      }
    },

    /**
     * 治療状況変換
     * @description 治療状況を数値から文字列に変換
     */
    convertDialysisState(code) {
      switch (code) {
        case 0:
          return "条件送信済み";

        case 1:
          return "条件送信済み";

        case 2:
          return "条件送信確認済み";

        case 3:
          return "治療中";

        case 4:
          return "排液済み";

        case 5:
          return "後体重測定済み(実績未確定)";

        case 6:
          return "後体重確認済み(過去実績)";

        default:
          // 異常値
          break;
      }
    },

    /**
     * Grid用データに加工処理
     */
    convertGridData(data) {
      // Kendo UI内部データ
      const loacalData = this.localDataSource.data;
      for (let i = 0; i < loacalData.length - 1; i++) {
        if (
          null !== data[this.selectedWeek] &&
          undefined !== data[this.selectedWeek]) {
          if (undefined !== data[this.selectedWeek]) {
            // 名称項目
            loacalData[i].name = data[this.selectedWeek][`name_${i + 1}`];
            // 重さ項目値
            const weightValue = data[this.selectedWeek][`weight_${i + 1}`];
            // 選択中の単位が「kg」で格納する値がnullでなければ
            if (
              1 === this.selectedUnit &&
              null !== weightValue &&
              "" !== weightValue) {
              loacalData[i].weight = this.procDecimal(weightValue);
            } else {
              loacalData[i].weight = weightValue;
            }
          }
        }
      }
      return loacalData;
    },

    /**
     * 内部データをDB用データに加工する
     */
    setInitValue(data) {
      // 患者情報テーブル参照時
      if (1 === this.targetTable && Object.keys(data).length) {
        return data;
      }

      // DBデータ雛形の作成
      const initObj = {};
      // 7日分ループする
      for (let i = 1; i <= 7; i++) {
        // 5項目分ループする
        for (let j = 1; j <= 5; j++) {
          if (String(i) in initObj) {
            initObj[String(i)][`name_${j}`] = "";
            initObj[String(i)][`weight_${j}`] = "";
          } else {
            initObj[String(i)] = {};
            initObj[String(i)][`name_${j}`] = "";
            initObj[String(i)][`weight_${j}`] = "";
          }
        }
      }
      // 取得したデータを書き換える
      if (undefined !== data[this.selectedWeek]) {
        initObj[this.selectedWeek] = data[this.selectedWeek];
      }
      return initObj;
    },

    /**
     * 患者情報に適切なデータが入っていない場合にデータを調整する
     */
    adjustmentInitValue(data) {
      for (let i = 1; i <= 7; i++) {
        // 曜日キーの下に値がなければデータを追加
        if (!data[i.toString()]) {
          data[i.toString()] = {};
        }
        for (let j = 1; j <= 5; j++) {
          // 名称項目キーが存在していなければ空文字を格納
          if (undefined === data[i.toString()][`name_${j}`]) {
            data[i.toString()][`name_${j}`] = "";
          }
          // 重さ項目キーが存在していなければnullを格納
          if (undefined === data[i.toString()][`weight_${j}`]) {
            data[i.toString()][`weight_${j}`] = null;
          }
        }
      }
      return data;
    },

    /**
     * DB風袋・除水補正情報の取得
     */
    async getTareAndOffWaterInfo() {
      let getData = {};
      switch (this.targetTable) {
        // 装置設定デフォルトマスタ
        case 0:
          getData = await this.getMstDeviceSetInfoDefault();
          break;

        // 患者情報
        case 1:
          getData = await this.getPatMain();
          break;

        // 指示
        case 2:
          getData = await this.getOrdMain();
          break;

        // 治療記録
        case 3:
          if (this.modalData) {
            // this.modalDataはJosuiHoseiJouhou型 -> /models/treatment-record/setting/JosuiHoseiJouhou.js
            getData[this.selectedWeek] = this.modalData.getDataForModal();
          }
          break;

        default:
          // 異常値
          break;
      }
      return getData;
    },

    /**
     * 装置設定デフォルトマスタからDBデータ取得
     */
    async getMstDeviceSetInfoDefault() {
      // 施設コードがない場合は空のObjectを返す
      if (!this.facilityCd) {
        return {};
      }
      const url = `deviceSetInfo/getSysTareAndOffWaterById/${this.facilityCd}`;
      // データ取得
      const response = await ApiHelper.get(url, {
        selectedPatId: this.selectedPatId
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'getMstDeviceSetInfoDefault', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });

      const getData = {};
      if (null !== response.data[0]) {
        if (null !== JSON.stringify(response.data[0])[this.columnName]) {
          // 選択曜日のデフォルト値を編集曜日とする
          getData[this.selectedWeek] = JSON.parse(
            JSON.parse(response.data[0])[this.columnName]);
        }
      }
      return getData;
    },

    /**
     * 患者情報からDBデータ取得
     */
    async getPatMain() {
      // 患者IDがない場合は空のObjectを返す
      if (!this.patId) {
        return {};
      }
      const url = `deviceSetInfo/getPatTareAndOffWaterById/${this.patId}`;
      // データ取得
      const response = await ApiHelper.get(url).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'getPatMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      let getData = {};
      if (null !== response.data[0]) {
        if (null !== JSON.parse(response.data[0])[this.columnName]) {
          getData = JSON.parse(JSON.parse(response.data[0])[this.columnName]);
        }
      }
      return getData;
    },

    /**
     * 治療情報からDBデータ取得処理
     */
    async getOrdMain() {
      // オーダー番号がない場合は空のObjectを返す
      if (!this.ordNo) {
        return {};
      }
      const url = `deviceSetInfo/getIndTareAndOffWaterById`;
      // データ取得
      const response = await ApiHelper.configPost(url, {
        ordNo: this.ordNo,
        flgIndRst: 0
      }, {
        params: {
          selectedPatId: this.selectedPatId
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'getOrdMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });

      const getData = {};
      if (null !== response.data[0]) {
        if (null !== JSON.parse(response.data[0])[this.columnName]) {
          // 対象曜日格納
          this.selectedWeek = String(
            JSON.parse(JSON.parse(response.data[0]).treatWeek));
          // 対象曜日列に除水補正情報格納
          getData[this.selectedWeek] = JSON.parse(
            JSON.parse(response.data[0])[this.columnName]);
          // 治療状況
          this.dialysisState = JSON.parse(
            JSON.parse(response.data[0]).rstDialysisState);
          if (
            Number(this.dialysisState) >= 4 &&
            6 >= Number(this.dialysisState)) {
            // 治療予定限定時
            if (this._deviceSetDialogOwner().weekEdit) {
              // 編集不可フラグをtrue
              this.disEdit = true;
              // IndEditBaseの保存ボタンを非活性化
              this._deviceSetDialogOwner().updateDisable = true;
            }
          }
        }
      }
      return getData;
    },

    /**
     * 治療記録取得
     */
    async getOrdMainRst() {
      // 施設コードがない場合は空のObjectを返す
      if (!this.ordNo) {
        return {};
      }
      const url = `deviceSetInfo/getIndTareAndOffWaterById`;
      // データ取得
      const { data } = await ApiHelper.configPost(url, {
        ordNo: this.ordNo,
        flgIndRst: 1
      }, {
        params: {
          selectedPatId: this.selectedPatId
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'getOrdMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      const getData = {};
      if (data) {
        getData[this.selectedWeek] = JSON.parse(
          JSON.parse(data[0])[this.columnName]);
      }
      return getData;
    },

    /**
     * 画面再描画処理
     * @description Kendo UIの要素を再描画する
     */
    async gridRefresh() {
      // 再描画前のスクロール量の取得
      this.getScrollPos();
      // 合計量算出
      await this.calculateSum();
      // フォーマット変更
      await this.changeFormat();
      // Vue2 wrapper と同じ列定義反映タイミングに合わせる
      this.syncGridColumnsToWidget();
      // Gridのリフレッシュ
      await this.refresh();
      await this.$nextTick();
      this.alignGridLayout();
      // スクロール量の設定()
      this.setScrollPos();
      // Grid描画完了後に編集色を反映
      this.setEditColor();
      // クリックイベントの追加
      this.addClickEvent();
      // 移動可能
      this.isMove = true;
    },

    /**
     * スクロール量取得
     */
    getScrollPos() {
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      this.scrollPos = scoped$(".indInfo-style-modal-container").scrollTop();
    },

    /**
     * スクロール量の設定
     */
    setScrollPos() {
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      scoped$(".indInfo-style-modal-container").scrollTop(this.scrollPos);
    },

    /**
     * 合計量算出
     */
    calculateSum() {
      this.localDataSource.data[5].weight = null;
      // 6行目の風袋補正量合計に合計量を格納する
      for (let i = 0; i < this.localDataSource.data.length - 1; i++) {
        // 値が空でなければ合計量を加算する
        if (this.localDataSource.data[i].weight != null && this.localDataSource.data[i].weight !== "") {
          const sumValue = new BigNumber(this.localDataSource.data[5].weight ? this.localDataSource.data[5].weight : 0);
          const plusValue = new BigNumber(this.localDataSource.data[i].weight);
          this.localDataSource.data[5].weight = sumValue.plus(plusValue).toNumber();
        }
      }
    },

    /**
     * フォーマットの変換
     */
    changeFormat() {
      this.multColumnList[1].format =
        0 === this.selectedUnit
          ? `{0:,# ${this.unit}}`
          : `{0:,#.00 ${this.unit}}`;
    },

    /**
     * 桁数変換（editValue の g 基準値から表示用 localDataSource を再構築）
     */
    changeDigit() {
      const weekData = this.editValue[this.selectedWeek];
      if (!weekData) {
        return;
      }
      for (let i = 0; i < this.localDataSource.data.length - 1; i++) {
        this.localDataSource.data[i].weight = this.convertWeightForDisplay(
          weekData[`weight_${i + 1}`]
        );
      }
    },

    /**
     * g 基準の値を現在の表示単位へ変換
     */
    convertWeightForDisplay(gramValue) {
      if (gramValue == null || gramValue === "") {
        return gramValue;
      }
      if (0 === this.selectedUnit) {
        return new BigNumber(gramValue).toNumber();
      }
      return this.procDecimal(gramValue);
    },

    /**
     * 小数点操作
     * @description 風袋->小数点第三位切り捨て、除水補正->小数点第3位切り上げ
     * @param value 小数点操作を行う値（g 基準）
     */
    procDecimal(value) {
      const grams = new BigNumber(value);
      if (!grams.isFinite()) {
        return null;
      }
      // 除水補正
      if (0 !== this.propsTareOffWaterInfoFlag) {
        return grams.div(1000).dp(2, BigNumber.ROUND_UP).toNumber();
      }
      // 風袋: 第三位切捨。0g 超かつ 0.01kg 未満は 0.01kg 表示（升级前同等）
      const kgRounded = grams.div(1000).dp(2, BigNumber.ROUND_DOWN);
      if (!grams.isZero() && kgRounded.isZero()) {
        return 0.01;
      }
      return kgRounded.toNumber();
    },

    /**
     * 画面再描画処理
     */
    refresh() {
      return new Promise(resolve => {
        this.$nextTick(() => {
          this.initDirectGridIfReady();
          this.applyDirectGridColumnsContract();
          this.applyDirectGridDataSourceContract();
          this.scheduleDirectGridLayoutContract();
          this.addClickEvent();
          resolve();
        });
      });
    },

    /**
     * 更新処理
     * @description 親からこの関数を呼んで更新処理を行う
     */
    async updateInfo(structData) {
      this.startLoadingScreen();
      // 更新日時(現在日時)
      this.upDate = dayjs().format("YYYY-MM-DD HH:mm:ss.SSS");
      // 更新情報(初期値と編集値の差分)
      const updateData = this.createDifferenceValue(
        this.initValue,
        this.editValue);
      switch (this.targetTable) {
        // 装置設定デフォルトマスタ更新
        case 0:
          if (!this.checkEdit()) {
            this.showMessage(23020001, "1");
            console.log("IndTreatMethod.vue updateInfo return; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            return;
          }
          await this.updateMstDeviceSetInfoDefault(updateData);
          // 患者情報にも反映をするかのメッセージを表示する
          this.showMessage(
            0 === this.propsTareOffWaterInfoFlag ? 13010003 : 13010004,
            "5");
          break;

        // 患者情報更新
        case 1:
          await this.updatePatMain(updateData);
          // 反映先データの取得
          this.getReflectOrdMain();
          // 今日含む未来の治療情報にも変更内容を反映するのかを表示する
          this.showMessage(
            13010001,
            "2",
            ["今日含む未来の指示情報", ""],
            "FUTURE_ORD_MAIN");
          break;

        // 治療情報更新
        case 2:
          await this.updateOrdMain(structData, updateData);
          // モーダルを閉じる
          this.hideModal();
          break;

        default:
          break;
      }
      console.log("IndTreatMethod.vue updateInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    /**
     * 装置設定デフォルトマスタ更新
     */
    async updateMstDeviceSetInfoDefault(updateData) {
      // 更新情報格納用
      const sendJson = {};
      // 施設コード
      sendJson.facility_cd = this.facilityCd;
      // 更新情報
      sendJson[this.columnName] = JSON.stringify(updateData[this.selectedWeek]);
      // 更新日時
      sendJson.up_date = this.upDate;
      // データ更新
      ApiHelper.post(
        "/deviceSetInfo/updateSysTareOffWaterInfo",
        sendJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'updateMstDeviceSetInfoDefault', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
    },

    /**
     * 患者情報更新
     */
    async updatePatMain(updateData) {
      // 更新情報格納用
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = this.patId;
      // 更新情報
      sendJson[this.columnName] = JSON.stringify(updateData);
      // 更新日時
      sendJson.up_date = this.upDate;
      // データ更新
      await ApiHelper.post(
        "/deviceSetInfo/updatePatTareOffWaterInfo",
        sendJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'updatePatMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
    },

    /**
     * 治療情報更新
     * @param structData IndEditBaseの情報
     */
    async updateOrdMain(structData) {
      // 更新情報格納用
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = structData.patId;
      // 施設コード
      sendJson.facility_cd = structData.facilityCd;
      // 治療開始日
      sendJson.start_date = dayjs(
        structData.indStartDate,
        "YYYY-MM-DD").format("YYYYMMDD");
      // 治療終了日
      sendJson.end_date = dayjs(structData.indEndDate, "YYYY-MM-DD").format(
        "YYYYMMDD");
      // 編集対象曜日
      sendJson.weeks = JSON.stringify(structData.indWeeks);
      // 編集対象治療方法
      sendJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 編集対象クール
      sendJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 風袋・除水更新内容
      //mod 10206 編集箇所のみ保存の修正 zy start
      // sendJson[this.columnName] = JSON.stringify(
      //   this.editValue[this.selectedWeek]
      //);
      const updateData = this.createDifferenceValue(this.initValue,this.editValue)[this.selectedWeek]
      sendJson[this.columnName] = structData.editOnly ? JSON.stringify(updateData) : JSON.stringify(this.editValue[this.selectedWeek]);
      //mod 10206 編集箇所のみ保存の修正 zy end
      // 更新日時
      sendJson.up_date = this.upDate;
      // 終了日格納有無
      sendJson.is_deadline = structData.isDeadline;
      //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
      sendJson.ord_no = structData.ordNo;
      sendJson.hosp_pat_id = structData.hospPatId;
      sendJson.ind_user = structData.indUser;
      sendJson.ope_cd = structData.opeCd;
      sendJson.crud = structData.crud;
      sendJson.base_date = structData.baseDate;

      //add #10266  start
      sendJson.update_flag = structData.update_flag;
      //add #10266  end

      //add by ztc 2023-02-27 [Optimize runtime No.5482] --end
      // データ更新
      await ApiHelper.post(
        "/deviceSetInfo/updateIndTareOffWaterInfo",
        sendJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'updateOrdMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      EventBus.$emit("isRefresh");
      // モーダルを閉じる
      this._hideDeviceSetModal();
    },

    /**
     * 対象患者のすべての治療情報を取得
     * @description
     * 更新対象、警告対象リスト作成
     */
    async getTargetOrdMain() {
      // データ取得条件の格納
      const paramJson = {};
      // 施設コード
      paramJson.facility_cd = this.facilityCd;
      // 患者ID
      paramJson.pat_id = this.patId;
      // 治療開始日
      paramJson.ind_start_date = "0001-01-01";
      // 治療終了日
      paramJson.ind_end_date = "9999-12-31";
      // 曜日パターン
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";
      // データの取得
      const response = await ApiHelper.post(
        `/mainData/TreatDateList`,
        paramJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'getTargetOrdMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });

      // 取得したデータが1件もなければ処理終了
      if (0 === response.data.length) {
        return;
      }
      // 対象患者のすべての治療情報を格納
      this.ordMainList = response.data;
    },

    /**
     * 反映先データの取得
     * @description
     * 治療開始時刻が前日か本日で
     * 治療状況が条件送信後～後体重確認前のもの
     * かつ編集を行った曜日と一致するものを取得する
     */
    getReflectOrdMain() {
      // 本日の日付け
      const day = dayjs().format("YYYYMMDD");
      // 前日の日付け
      const yesterday = dayjs()
        .subtract(1, "days")
        .format("YYYYMMDD");
      // 更新対象を格納(本日または前日の治療状況が条件送信後～後体重確認前)
      this.reflectOrdMainDataList = this.ordMainList.filter(eleObj => {
        return (
          Number(day) >= Number(eleObj.treatDate) &&
          Number(eleObj.treatDate) >= Number(yesterday) &&
          Number(eleObj.rstDialysisState) >= 1 &&
          6 > Number(eleObj.rstDialysisState));
      });
      // 編集対象曜日取得
      const editWeekArr = this.getEditWeekArr();
      // 編集対象曜日と反映対象の曜日が一致したものを格納する
      const arr = [];
      this.reflectOrdMainDataList.forEach(eleItem => {
        editWeekArr.forEach(eleWeek => {
          if (Number(eleWeek) === eleItem.treatWeek) {
            arr.push(eleItem);
          }
        });
      });
      this.reflectOrdMainDataList = arr;
    },

    /**
     * 反映確認メッセージ表示
     * @description
     * 治療開始時刻が前日か本日で
     * 治療状況が条件送信後～後体重確認前のもの
     * かつ編集を行った曜日と一致するものがある場合表示する
     */
    showReflectOrdMainMessage() {
      // 本日もしくは前日の治療状況が条件送信済みから～後体重確認前の治療情報が1件もない場合処理終了
      if (0 === this.reflectOrdMainDataList.length) {
        // 警告メッセージ表示
        this.showAlertOrdMain();
        return;
      }
      // 1つ目に置換する文字列
      const dispStr1 =
        0 === this.propsTareOffWaterInfoFlag ? "風袋" : "除水補正";
      // 2つ目に置換する文字列
      let dispStr2 = "";
      this.reflectOrdMainDataList.forEach(eleItem => {
        // 更新対象オーダー番号リストの格納
        this.ordNoList.push(eleItem.ordNo);
        // 更新対象を曜日ごとに格納
        if (Object.prototype.hasOwnProperty.call(this.targetUpdateInfo, eleItem.treatWeek.toString())) {
          // キーが存在している場合、オーダー番号をpush
          this.targetUpdateInfo[eleItem.treatWeek.toString()].push(
            eleItem.ordNo);
        } else {
          // キーが存在していない場合は直接代入
          this.targetUpdateInfo[eleItem.treatWeek.toString()] = [eleItem.ordNo];
        }
        // 表示文字列格納処理
        dispStr2 = this.createMessageStr(eleItem, dispStr2);
      });
      // 表示する文字列が存在する場合のみ表示する
      const messageCd = 13010001;
      // 親のメッセージ表示処理関数を呼び出す
      this.showMessage(
        messageCd,
        "2",
        [`以下の透析中実績の${dispStr1}情報`, dispStr2],
        "TARGET_ORD_MAIN");
    },

    /**
     * 警告メッセージ情報の取得
     * @description
     * 「透析中」または「排液後～後体重確認前」のとき
     * 「2日以上前」の「版が確定していない透析中以降の実績」
     * が存在するものを取得する
     */
    getAlertOrdMain() {
      // 2日前の日付け
      const dayBeforeYesterday = dayjs()
        .subtract(2, "days")
        .format("YYYYMMDD");
      this.alertOrdMainList = this.ordMainList.filter(eleObj => {
        return (
          Number(dayBeforeYesterday) >= Number(eleObj.treatDate) &&
          Number(eleObj.rstDialysisState) >= 3 &&
          6 > Number(eleObj.rstDialysisState));
      });
    },

    /**
     * 警告メッセージ
     * @description
     * 「透析中」または「排液後～後体重確認前」のとき
     * 「2日以上前」の「版が確定していない透析中以降の実績」
     * が存在する場合に表示する
     */
    showAlertOrdMain() {
      if (0 === this.alertOrdMainList.length) {
        // モーダルを閉じる
        this.hideModal();
        return;
      }
      // 表示用文字列
      let dispStr = "";
      this.alertOrdMainList.forEach(eleItem => {
        dispStr = this.createMessageStr(eleItem, dispStr);
      });
      this.showMessage(23010002, "1", [dispStr]);
    },

    /**
     * 編集対象曜日を取得
     */
    getEditWeekArr() {
      // 変更のあった曜日格納用
      const arr = [];
      // 変更情報を取得
      const differenceValue = this.createDifferenceValue(
        this.initValue,
        this.editValue);
      // 変更のあった曜日を格納
      for (const treatWeek in differenceValue) {
        arr.push(treatWeek);
      }
      return arr;
    },

    /**
     * メッセージ表示用文字列作成
     * @param obj 治療情報Object
     * @param str 前回作成した表示用文字列
     */
    createMessageStr(obj, preDispStr) {
      // 治療日
      const treatDate = dayjs(obj.treatDate, "YYYYMMDD").format("YYYY/MM/DD");
      // 治療曜日
      const treatWeek = this.convertStrWeek(Number(obj.treatWeek));
      // ベッド名
      const indBedName = obj.indBedName;
      // クール名
      const indKurName = obj.indKurName;
      // 治療状況
      const rstDialysisState = this.convertDialysisState(
        Number(obj.rstDialysisState));
      // 表示文字列
      const dispStr = `\n治療日:${treatDate}(${treatWeek})\nベッド:${indBedName}\nクール:${indKurName}\n治療状況:${rstDialysisState}\n`;
      // 前回の表示文字列と結合する
      return preDispStr + dispStr;
    },

    /**
     * 患者情報更新時、反映対象に対して変更内容を反映する
     */
    async reflectOrdMainInfo() {
      // 曜日ごとに反映処理を行う
      for (const treatWeek in this.targetUpdateInfo) {
        const sendJson = {};
        // 更新対象オーダー番号リスト
        sendJson.ord_no = JSON.stringify(this.ordNoList);
        // 風袋・除水補正情報
        sendJson[this.columnName] = JSON.stringify(
          this.editValue[treatWeek.toString()]);
        // 更新日時
        sendJson.up_date = this.upDate;
        await ApiHelper.post(
          `/deviceSetInfo/updateRstTareOffWaterInfo`,
          sendJson).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'reflectOrdMainInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw error;
        });
      }

      // モーダルを閉じる
      this.hideModal();
    },

    /**
     * 未来の治療情報への更新処理
     */
    async updateFutureIndTareAndOffWaterInfo() {
      // 更新情報格納用
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = this.patId;
      // 反映情報
      const updateData = this.createDifferenceValue(
        this.initValue,
        this.editValue);
      // 変更のあった曜日リスト
      const editWeek = [];
      for (const week in updateData) {
        editWeek.push(week);
      }
      sendJson[this.columnName] = JSON.stringify(editWeek);
      // 更新日時
      sendJson.up_date = this.upDate;
      await ApiHelper.post(
        "/deviceSetInfo/updateFutureIndTareOffWaterInfo",
        sendJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'updateFutureIndTareAndOffWaterInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
    },

    /**
     * 装置設定デフォルトマスタで変更した内容を患者情報に反映する
     */
    async updatePatInfoDefault() {
      // #8061-装置設定が保存出来ない 周 add start
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // #8061-装置設定が保存出来ない 周 add end
      const sendJson = {};
      // 施設コード
      sendJson.facility_cd = this.facilityCd;
      // 更新情報
      const updateInfo = {};
      for (let i = 1; i <= 7; i++) {
        // mod 装置設定デフォルトマスタで変更した内容を患者情報に反映するのが不正なことを対応 劉 start
        // updateInfo[i.toString()] = this.editValue[this.selectedWeek];
        updateInfo[i.toString()] = this.createDifferenceValue(
          this.initValue,
          this.editValue)[this.selectedWeek];
        // mod 装置設定デフォルトマスタで変更した内容を患者情報に反映するのが不正なことを対応 劉 end
      }
      sendJson[this.columnName] = JSON.stringify(updateInfo);
      // 更新日時
      sendJson.up_date = this.upDate;
      // 更新APIの呼び出し
      await ApiHelper.post(
        "/deviceSetInfo/updatePatTareOffWaterInfo",
        sendJson).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoEditor.vue', 'updatePatInfoDefault', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      // #8061-装置設定が保存出来ない 周 add start
      this.setLoadingScreenVisible(false);
      // #8061-装置設定が保存出来ない 周 add end
    },

    /**
     * Grid内の値を変更したときの処理
     * @description 内部データを書き換える
     * @param e データの編集を行ったセル情報
     */
    async onSave(e) {
      //6659--------------ljg
      if(e.values.weight==null && e.values.weight!==undefined){
        e.values.weight=0
      }
     //6659---------------ljg  end
      // スワイプ可能フラグをfalseに変更
      this.swipeFlag = true;
      // 内部データの更新処理
      for (const key in e.values) {
        // 変更した値の格納
        this.localDataSource.data[e.model.id - 1][key] = e.values[key];
        // 変更比較データにデータの格納
        let value = e.values[key];
        // 項目が「重さ」で単位がkgの場合、変更比較データにはgベースの値に変更
        if ("weight" === key && 1 === this.selectedUnit && null !== value) {
          value = value * 1000;
        }
        // 変更比較データに変更値を格納
        this.setEditValue(`${key}_${e.model.id}`, value);
      }
      // Grid再描画
      await this.gridRefresh();

      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定デフォルトマスタ_風袋 20240220 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdit());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定デフォルトマスタ_風袋 20240220 ztc end
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    },

    /**
     * 編集値の格納
     */
    setEditValue(key, value) {
      this.editValue[this.selectedWeek][key] = value;
    },

    /**
     * 初期データとの差異のみ取り出す
     * @param initData 初期値
     * @param editData 編集値
     */
    createDifferenceValue(initData, editData) {
      const differenceData = {};
      for (const key in initData) {
        // 初期値と差異のあるものを取り出す
        const difference = Object.keys(editData[key]).filter(
          item => editData[key][item] !== initData[key][item]);
        // 初期データと編集データで際のあったものを格納する
        if (0 !== difference.length) {
          differenceData[key] = {};
          difference.forEach(item => {
            differenceData[key][item] = editData[key][item];
          });
        }
      }
      return differenceData;
    },

    /**
     * 変更有無チェック
     * @return 変更がある場合はtrueを返す
     */
    checkEdit() {
      // 初期値と変更値の差分を取得
      const differenceData = this.createDifferenceValue(
        this.initValue,
        this.editValue);
      // 変更箇所数
      let editCount = 0;
      for (const weekNum in differenceData) {
        if (Object.keys(differenceData[weekNum]).length) {
          editCount++;
        }
      }
      return 0 !== editCount ? true : false;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    /**
     * 変更有無チェック
     * @return 変更がある場合はtrueを返す
     */
    isEdit() {
      // 初期値と変更値の差分を取得
      const differenceData = this.createDifferenceValue(
        this.initValue,
        this.editValue);
      // 変更箇所数
      let editCount = 0;
      for (const weekNum in differenceData) {
        if (Object.keys(differenceData[weekNum]).length) {
          editCount++;
        }
      }
      return 0 !== editCount ? true : false;
    },
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end

    /**
     * 編集色判定（名称は厳密一致、重さは g 基準で等价判定）
     */
    isEquivalentCellValue(itemName, initVal, editVal) {
      if ("name" === itemName) {
        return initVal === editVal;
      }
      if (initVal === editVal) {
        return true;
      }
      const initEmpty = initVal == null || initVal === "";
      const editEmpty = editVal == null || editVal === "";
      if (initEmpty || editEmpty) {
        return initEmpty && editEmpty;
      }
      try {
        const initNum = new BigNumber(initVal);
        const editNum = new BigNumber(editVal);
        if (initNum.isEqualTo(editNum)) {
          return true;
        }
        if (initNum.times(1000).isEqualTo(editNum) || editNum.times(1000).isEqualTo(initNum)) {
          return true;
        }
      } catch (e) {
        return false;
      }
      return false;
    },

    /**
     * 編集色の設定
     */
    setEditColor() {
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      // 初期値 ※each内でthisが使用できないため定数に格納
      const initData = deepCopy(this.initValue[this.selectedWeek]);
      // 編集値
      const editData = deepCopy(this.editValue[this.selectedWeek]);
      setTimeout(() => {
        // 名称項目、重さ項目でループ
        for (let i = 0; i < 2; i++) {
          const itemName = 0 === i ? "name" : "weight";
          // 名称項目編集チェック
          scoped$(`.${itemName}-item`).each((index, elment) => {
            // 合計量行は処理を行わない
            if (5 === index) {
              return;
            }
            const key = `${itemName}_${index + 1}`;
            if (this.isEquivalentCellValue(itemName, initData[key], editData[key])) {
              scoped$(elment).removeClass("grid-edited-cell");
            } else {
              scoped$(elment).addClass("grid-edited-cell");
            }
          });
        }
      }, 0);
    },

    /**
     * 重さセル編集時の入力値を数値に変換（カンマ区切り・全角マイナス対応）
     */
    parseEditorNumericValue(rawValue) {
      if (rawValue === null || rawValue === undefined) {
        return null;
      }
      const text = String(rawValue).replace(/,/g, "").replace(/－/g, "-").trim();
      if (text === "" || text === "-") {
        return null;
      }
      const parsed = Number(text);
      return Number.isFinite(parsed) ? parsed : null;
    },

    /**
     * 重さセル編集時の丸め処理（風袋/除水補正・g/kg）
     */
    applyWeightInputRounding(rawValue, isIntegerStep, isTare) {
      const num = this.parseEditorNumericValue(rawValue);
      if (num === null) {
        return null;
      }
      if (isIntegerStep) {
        return isTare ? Math.floor(num) : Math.ceil(num);
      }
      const valueStr = String(rawValue).replace(/,/g, "");
      const dotIndex = valueStr.indexOf(".");
      const hasThirdDecimal =
        dotIndex >= 0 &&
        valueStr.length > dotIndex + 3 &&
        valueStr[dotIndex + 3] !== "0";
      const factor = 100;
      if (hasThirdDecimal) {
        return isTare
          ? Math.floor(num * factor) / factor
          : Math.ceil(num * factor) / factor;
      }
      return Math.round(num * factor) / factor;
    },

    /**
     * editor用関数(セルクリック時イベント)
     * @description テキストの型をここで決定する
     */
    setEditor(container, data) {
      // kendo UI初回立ち上げ時は引数が渡されないので処理終了
      if (!container || !data) {
        return;
      }

      // 6行目(合計量)をクリック時にテキストボックスではなく、テキストを出す処理
      if (6 === data.model.id) {
        if ("weight" === data.field) {
          // 合計量文字列
          let sumStr = "";
          // 選択したセルの値がnullならば空文字を表示
          if (null !== data.model[data.field]) {
            // 数値を文字列に変換
            const n = data.model[data.field];
            // kg選択中は文字列の数値を小数点第2位まで
            sumStr = n.toFixed(this.numericDecimalsValue);
            // 文字列の数値をカンマ区切り
            sumStr = sumStr.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
            // 単位の結合
            sumStr += ` ${this.unit}`;
          }
          // 文字列を挿入する
          container.text(sumStr);
        }
      } else {
        // 重さ項目列クリック時
        if ("weight" === data.field) {
          this.swipeFlag = false;
          // kendoNumericTextBoxの最大値
          const max = this.numericMaxValue;
          // kendoNumericTextBoxの最小値
          const min = this.numericMinValue;
          // kendoNumericTextBoxのステップ
          const step = this.numericStepValue;
          // kendoNumericTextBoxの有効小数点桁数
          const decimals = this.numericDecimalsValue;
          // Vue2 の editor 初期値承継（name バインドだけでは Vue3 native 側に反映されない）
          const rawEditorValue = data.model[data.field];
          const normalizedEditorValue = rawEditorValue === null || rawEditorValue === undefined || rawEditorValue === ""
            ? null
            : Number(String(rawEditorValue).replace(/,/g, ""));
          // 数値型テキストボックス(kendo UI)
          //区別します風袋とです除水補正
          const propsTareOffWaterInfoFlag = this.propsTareOffWaterInfoFlag;
          const component = this;
          const isIntegerStep = step === 1;
          const isTare = propsTareOffWaterInfoFlag === 0;
          let numericTextBox = null;
          numericTextBox = mountDirectNumericTextBox(
            $(
              `<input class="deviceSetInfo-numbersTextbox" id="Calories" name="${data.field}" />`)
              .appendTo(container)[0],
            {
              // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
              // min,
              // max,
              value: Number.isFinite(normalizedEditorValue) ? normalizedEditorValue : null,
              step,
              decimals,
              spin: () => {
                let value = getDirectKendoWidgetValue(numericTextBox)
                // 数値範囲内かどうかの確認
                if (value > max) {
                  setDirectKendoWidgetValue(numericTextBox, min)
                } else if (value <  min) {
                  setDirectKendoWidgetValue(numericTextBox, max)
                }
              },
              change: (e) => {
                let value = getDirectKendoWidgetValue(numericTextBox);
                if (value === null || value === undefined) {
                  value = component.parseEditorNumericValue(e.sender?._value);
                }
                if (value === null) {
                  component.blurFlg = false;
                  return;
                }
                // 数値範囲内かどうかの確認
                if (value > max) {
                  data.model.set(data.field, max);
                  component.blurFlg = true;
                } else if (value < min) {
                  data.model.set(data.field, min);
                  component.blurFlg = true;
                } else {
                  component.blurFlg = false;
                }
              }
              // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
            });
          // マウスホイールイベントイベント
          numericTextBox.element.on("mousewheel", function(e) {
            const current = component.parseEditorNumericValue(this.value) ?? 0;
            if (e.originalEvent.wheelDelta / 120 > 0) {
              this.value =
                max > current
                  ? current + step
                  : min;
              this.value = Math.round(this.value * 100) / 100;
            } else {
              this.value =
                current > min
                  ? current - step
                  : max;
              this.value = Math.round(Number(this.value) * 100) / 100;
            }
          });
          // 風袋/除水補正の丸め（千位カンマ付き表示値でも正しく数値化）
          numericTextBox.element.on("change", function(e) {
            const rounded = component.applyWeightInputRounding(
              e.target.value,
              isIntegerStep,
              isTare
            );
            if (rounded !== null) {
              this.value = rounded;
            }
          });
          //6659 全角マイナス除去・先頭0の2桁入力補正
          numericTextBox.element.on("input propertychange", function() {
            const inputElement = numericTextBox.element.get(0);
            if (!inputElement) {
              return;
            }
            const sanitized = inputElement.value.replace(/－/g, "");
            if (sanitized !== inputElement.value) {
              inputElement.value = sanitized;
            }
            if (
              sanitized.length === 2 &&
              !isNaN(sanitized) &&
              sanitized[0] === "0" &&
              sanitized[1] !== "."
            ) {
              inputElement.value = String(Number(sanitized) % 10);
            }
          });
          bindGridEditorEnterToCloseCell(this.getTareAndOffWaterInfoGridWidget(), container);
        } else {
          // 名称項目列クリック時
          this.swipeFlag = false;
          $(
            //#10500:装置設定デフォルトマスタにて風袋と除水補正の編集ができない Start
            `<textarea name="${data.field}" rows="1" class="k-valid k-textarea resize-obs-target" style="font-size: 1.0em; width:100%; resize: none; max-height: 30vh; min-height: unset;"/>`
            //#10500:装置設定デフォルトマスタにて風袋と除水補正の編集ができない End
            ).on({
            "input": (e)=>{
              setTimeout(() => {
                e.currentTarget.style.height = "auto";
                e.currentTarget.style.height = ( e.currentTarget.scrollHeight + 5) + "px";
              }, 0);
            },
            "keydown": (e)=>{
              if (e.key === "Enter") {
                return false;
              }
            }
          }).appendTo(container).trigger("input");
        }
      }
    },
    /**
     * 1つ前の曜日に遷移する
     */
    selectPreWeek() {
      // 移動可能フラグがfalseの場合、以降の処理を行わない
      if (!this.isMove) {
        return;
      }
      // スワイプ可能フラグがfalseの場合は処理終了
      if (!this.swipeFlag) {
        return;
      }
      // 患者情報編集時のみ処理
      if (1 === this.targetTable) {
        if (1 === Number(this.selectedWeek)) {
          // 月曜日時の左スワイプは日曜を設定
          this.selectedWeek = "7";
        } else {
          // 現在選択中の曜日から1つ前の曜日を格納する
          this.selectedWeek = String(Number(this.selectedWeek) - 1);
        }
      }
      this.isMove = false;
    },

    /**
     * 1つ後の曜日に遷移する
     */
    selectNextWeek() {
      // 移動可能フラグがfalseの場合、以降の処理を行わない
      if (!this.isMove) {
        return;
      }
      // スワイプ可能フラグがfalseの場合は処理終了
      if (!this.swipeFlag) {
        return;
      }
      // 患者情報編集時のみ処理
      if (1 === this.targetTable) {
        if (7 === Number(this.selectedWeek)) {
          // 日曜選択時は月曜日に移動
          this.selectedWeek = "1";
        } else {
          // 現在選択中の1つ先の曜日を格納する
          this.selectedWeek = String(Number(this.selectedWeek) + 1);
        }
      }
      this.isMove = false;
    },

    /**
     * @description 該当行が他院情報かどうかを判定
     * @returns {Boolean} true = 他施設のデータは参照のみ
     */
    isOtherFacilityRow() {
      const facilityCd = this.settingIndData?.facilityCd;
      return facilityCd ? facilityCd !== this.getFacilityCd : false;
    },

    /**
     * ヘッダーテンプレート
     */
    headerTemplate() {
      // ヘッダー名
      const weekName = this.convertStrWeek(Number(this.selectedWeek));
      // ヘッダー名クラス
      let weekNameStyle = "";
      if ("6" === this.selectedWeek) {
        // 土曜日選択時文字色
        weekNameStyle = "color: var(--ntss-saturday-color);";
      } else if ("7" === this.selectedWeek) {
        // 日曜日選択時文字色
        weekNameStyle = "color: var(--ntss-sunday-color);";
      }
      // ヘッダー一段目に設定するHTML要素
      const template = `<span class="k-icon k-i-arrow-chevron-left" id="left-arrow" ></span><label style="margin: 20%; ${weekNameStyle}">${weekName}</label><span class="k-icon k-i-arrow-chevron-right" id="right-arrow"></span>`;
      return template;
    },

    /**
     * 矢印にクリックイベントの追加
     */
    addClickEvent() {
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      // 左矢印にクリックした際1つ前の曜日に遷移する処理を追加
      scoped$("#left-arrow").off("click").on("click", () => {
        this.selectPreWeek();
      });
      // 右矢印にクリックした際1つ先の曜日に遷移する処理を追加
      scoped$("#right-arrow").off("click").on("click", () => {
        this.selectNextWeek();
      });
    },

    /**
     * 改行イベントの追加
     */
    addIndentionEvent() {},

    /**
     * モーダルを閉じる
     */
    hideModal() {
      this.$emit("hide-modal");
    },

    /**
     * メッセージダイアログ表示
     * @description 引数をもとに親のメッセージ情報を渡す
     * @param messageCd メッセージコード
     * @param type メッセージ表示タイプ
     * @param stringParamsList メッセージ置換文字列リスト
     * @param targetName メッセージ表示対象名
     */
    showMessage(messageCd, type, stringParamsList, targetName) {
      this.$emit("show-message", messageCd, type, stringParamsList, targetName);
    },

    /**
     * iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
     */
    addInputAssist() {
      if (this.iosFlg) {
        const spinnerObj = queryScopedSelector(".k-numerictextbox .k-select", this.$el || this) || null;
        if (spinnerObj) {
          // 編集が終了するとオブジェクトが削除される為、removeEvent処理は不要
          spinnerObj.ontouchend = function(event) {
            event.stopPropagation();
          };
        }
      }
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add start
    async resetComponentIndData(structData){
      if (this.checkEdit()) {
        this._deviceSetRootOwner().messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this._deviceSetRootOwner().messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this._deviceSetRootOwner().messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        return this.getComponentData(structData, 2);
      }
    },
    async getComponentData(structData, answer) {
      if (answer === 1) {
        return;
      }
      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = "";
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(indWeeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/getOrdMainDataInfo",
        paramJson).catch(error => {
        getErrorMessage('IndActionChart.vue', 'resetComponentData', error);
        throw error;
      });
      let ordMainData = response.data;

      let changeColumnName = "";
      // DB風袋/除水補正情報取得
      if (this.columnName == "off_water_info") {
        changeColumnName = "indOffWaterInfo";
      } else if (this.columnName == "tare_info") {
        changeColumnName = "indTareInfo";
      }
      if (ordMainData?.length && changeColumnName != "" && ordMainData[0][changeColumnName] != undefined && ordMainData[0][changeColumnName] != null) {
        const getData = JSON.parse(ordMainData[0][changeColumnName]);
        let tempData = this.convertGridDataForUpdate(getData);

        let newInitData = {
          name_1: tempData[0].name,
          name_2: tempData[1].name,
          name_3: tempData[2].name,
          name_4: tempData[3].name,
          name_5: tempData[4].name,
          weight_1: tempData[0].weight,
          weight_2: tempData[1].weight,
          weight_3: tempData[2].weight,
          weight_4: tempData[3].weight,
          weight_5: tempData[4].weight,
        };

        if (answer == 3) {
          let initData = this.convertGridDataForUpdate(this.initValue[this.selectedWeek]);
          this.editValue[this.selectedWeek] = deepCopy(newInitData);
          for (let index = 0; index < this.localDataSource.data.length - 1; index++) {
            if (this.localDataSource.data[index].name != initData[index].name) {
              tempData[index].name = this.localDataSource.data[index].name;
              this.editValue[this.selectedWeek][`name_${index + 1}`] = this.localDataSource.data[index].name;
            }
            if (this.localDataSource.data[index].weight != initData[index].weight) {
              tempData[index].weight = this.localDataSource.data[index].weight;
              this.editValue[this.selectedWeek][`weight_${index + 1}`] = this.localDataSource.data[index].weight;
            }
          }
        }

        // 初期データの設定
        this.initValue[this.selectedWeek] = newInitData;
        if (answer == 2) {
          this.editValue[this.selectedWeek] = deepCopy(newInitData);
        }
        this.localDataSource.data = this.setInitLocalData();
        this.localDataSource.data = tempData

        await this.gridRefresh();

      }
    },
    /**
     * Grid用データに加工処理
     */
    convertGridDataForUpdate(data) {
      // Kendo UI内部データ
      let loacalData = [];
      let tempData = {};
      for (let i = 0; i < this.localDataSource.data.length; i++) {
        tempData = {};
        Object.assign(tempData, this.localDataSource.data[i]);
        loacalData.push(tempData);
      }

      for (let i = 0; i < loacalData.length - 1; i++) {
        if (
          null !== data &&
          undefined !== data) {
          if (undefined !== data) {
            // 名称項目
            loacalData[i].name = data[`name_${i + 1}`];
            // 重さ項目値
            const weightValue = data[`weight_${i + 1}`];
            // 選択中の単位が「kg」で格納する値がnullでなければ
            if (
              1 === this.selectedUnit &&
              null !== weightValue &&
              "" !== weightValue) {
              loacalData[i].weight = this.procDecimal(weightValue);
            } else {
              loacalData[i].weight = weightValue;
            }
          }
        }
      }
      return loacalData;
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add end
  }
};
</script>

<style scoped>
.tare-off-water-grid :deep(.k-grid td) {
  word-break: break-all;
  white-space: normal;
  padding-left: 5px !important;
  padding-right: 5px !important;
}

.tare-off-water-grid :deep(.k-grid .k-table-td) {
  word-break: break-all;
  white-space: normal;
  padding-left: 5px !important;
  padding-right: 5px !important;
}

@media screen and (min-height: 569px) {
  .tare-offwater :deep(.k-grid-content) {
    height: auto !important;
  }
}

.custom-tare-off-water-grid .segment-button,
.custom-tare-off-water-grid :deep(.segment__button),
.custom-tare-off-water-grid :deep(.segment__input),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-secound-name),
.custom-tare-off-water-grid :deep(.k-widget),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-row-name),
.custom-tare-off-water-grid :deep(.deviceSetInfo-row-name),
.custom-tare-off-water-grid :deep(.deviceSetInfo-name-content),
.custom-tare-off-water-grid :deep(.deviceSetInfo-weight-content) {
  font-size: unset;
  border-radius: 0px;
  box-shadow: unset;
}

/* add redmine 5535 風袋・除水補正のkg/g切替ボタンのスタイル不正 宋qy start */
.custom-tare-off-water-grid :deep(.segment__button) {
  background-color: #72a8de;
  color: #ffffff;
  border: none;
}
.custom-tare-off-water-grid :deep(:checked + .segment__button) {
  background-color: var(--btn1-execute-color);
}
/* add redmine 5535 風袋・除水補正のkg/g切替ボタンのスタイル不正 宋qy end */
.custom-tare-off-water-grid :deep(.resize-obs-target::-webkit-scrollbar) {
  display: none;
}

.custom-tare-off-water-grid :deep(.k-grid table),
.custom-tare-off-water-grid :deep(.k-grid-table) {
  width: 100% !important;
  table-layout: fixed !important;
  border-collapse: collapse;
}

.custom-tare-off-water-grid :deep(.k-grid),
.custom-tare-off-water-grid :deep(.k-grid-container),
.custom-tare-off-water-grid :deep(.k-grid-content),
.custom-tare-off-water-grid :deep(.k-grid-content-locked),
.custom-tare-off-water-grid :deep(.k-grid-footer),
.custom-tare-off-water-grid :deep(.k-grid-footer-locked),
.custom-tare-off-water-grid :deep(.k-grid-footer-wrap) {
  background-color: var(--main-background-color) !important;
}

.custom-tare-off-water-grid :deep(.k-grid-header) {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}

.custom-tare-off-water-grid :deep(.k-grid-header th),
.custom-tare-off-water-grid :deep(.k-grid-header .k-table-th),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-row-name),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-first-name),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-secound-name) {
  color: #ffffff;
  padding-left: 0 !important;
  padding-right: 0 !important;
  text-align: center !important;
  vertical-align: middle !important;
}

.custom-tare-off-water-grid :deep(.deviceSetInfo-header-row-name .k-link),
.custom-tare-off-water-grid :deep(.deviceSetInfo-first-header .k-link),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-secound-name .k-link),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-row-name .k-cell-inner),
.custom-tare-off-water-grid :deep(.deviceSetInfo-first-header .k-cell-inner),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-secound-name .k-cell-inner),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-row-name .k-column-title),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-first-name .k-column-title),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-secound-name .k-column-title) {
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  width: 100% !important;
  height: 100% !important;
  padding: 0 !important;
  margin: 0 !important;
  text-align: center !important;
}

.custom-tare-off-water-grid :deep(th.deviceSetInfo-header-row-name),
.custom-tare-off-water-grid :deep(td.deviceSetInfo-row-name),
.custom-tare-off-water-grid :deep(.k-table-td.deviceSetInfo-row-name) {
  width: 90px !important;
  max-width: 90px !important;
  background-color: var(--ntss-header-background-color) !important;
  color: var(--ntss-header-color) !important;
  text-align: center !important;
  vertical-align: middle !important;
  border-bottom: solid 0.1px var(--ntss-list-border-color) !important;
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.custom-tare-off-water-grid :deep(.deviceSetInfo-row-name .k-cell-inner) {
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  width: 100% !important;
  padding: 0 !important;
  margin: 0 !important;
}

.custom-tare-off-water-grid :deep(.deviceSetInfo-name-content),
.custom-tare-off-water-grid :deep(td.deviceSetInfo-name-content),
.custom-tare-off-water-grid :deep(.k-table-td.deviceSetInfo-name-content) {
  text-align: left !important;
  background-color: var(--ntss-base-background-color) !important;
  color: var(--row-1-color) !important;
  border-left: solid 0.1px var(--ntss-list-border-color) !important;
  border-bottom: solid 0.1px var(--ntss-list-border-color) !important;
}

.custom-tare-off-water-grid :deep(.deviceSetInfo-weight-content),
.custom-tare-off-water-grid :deep(td.deviceSetInfo-weight-content),
.custom-tare-off-water-grid :deep(.k-table-td.deviceSetInfo-weight-content) {
  text-align: right !important;
  background-color: var(--ntss-base-background-color) !important;
  color: var(--row-1-color) !important;
  border-left: solid 0.1px var(--ntss-list-border-color) !important;
  border-bottom: solid 0.1px var(--ntss-list-border-color) !important;
  padding-right: 12px !important;
}

.custom-tare-off-water-grid :deep(.deviceSetInfo-header-first-name),
.custom-tare-off-water-grid :deep(.deviceSetInfo-header-secound-name) {
  border-left: solid 0.1px var(--ntss-list-border-color) !important;
}

.custom-tare-off-water-grid :deep(.k-grid-header),
.custom-tare-off-water-grid :deep(.k-grid-content),
.custom-tare-off-water-grid :deep(.k-table),
.custom-tare-off-water-grid :deep(table),
.custom-tare-off-water-grid :deep(th),
.custom-tare-off-water-grid :deep(td),
.custom-tare-off-water-grid :deep(.k-table-th),
.custom-tare-off-water-grid :deep(.k-table-td) {
  box-sizing: content-box !important;
}

.custom-tare-off-water-grid :deep(.k-table-row) {
  border-bottom: 1px solid #e0e0e0;
}

.custom-tare-off-water-grid :deep(.k-table-thead .k-table-row:nth-child(2) > .deviceSetInfo-header-secound-name:nth-child(1)) {
  border-right: none;
}

.custom-tare-off-water-grid :deep(td.deviceSetInfo-weight-content.k-edit-cell .k-numerictextbox .k-input-inner),
.custom-tare-off-water-grid :deep(td.deviceSetInfo-weight-content .deviceSetInfo-numbersTextbox),
.custom-tare-off-water-grid :deep(.deviceSetInfo-weight-content .k-input-inner) {
  text-align: right !important;
}
</style>
