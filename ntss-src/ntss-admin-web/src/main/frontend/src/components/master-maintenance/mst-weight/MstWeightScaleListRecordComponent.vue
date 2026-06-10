/**
 * 体重計マスタ（上部の一覧）ページ  MainContent
 */
<template>
  <div class="ntss-list weight-scale-grid" :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
    <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
      <kendo-grid ref="grid" :class="fontSizeSet"
          :data-source="masterRecords"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :scrollable="true"
          :beforeEdit=editStart
          :cellClose=editEnd
          :edit=addInputAssist
          @save="onSave"
          @databound="onDataBoundKendoGrid">
          <template v-for="(column, index) in columns" >
            <kendo-grid-column v-if="column.field === '$modalType'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :command="{ text: '詳細', click: showMasterEditModal }">
            </kendo-grid-column>
            <!-- add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng start -->
            <kendo-grid-column v-else-if="column.field === 'doubleCheckTolerance'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="numericEditor">
              </kendo-grid-column>
            <!-- add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng end -->
            <kendo-grid-column v-else
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values">
            </kendo-grid-column>
          </template>
      </kendo-grid>
    </kendo-grid-toolbar>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import $$ from "jquery"
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng start
import $ from "jquery";
// add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng end

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  props: {
    /**
     * 親コンポーネントから渡される編集モードのフラグ。
     * true の場合は編集可能、false の場合は閲覧モードとして編集を禁止する。
     * モバイル端末での誤操作防止のため、editStart イベントで使用。
     */
    allowEdit: {
      type: Boolean,
      default: true
    },
    /**
     * モバイル端末かどうかの判定（true: モバイル、false: PC）
     */
    isMobileDevice: {
      type: Boolean,
      default: false
    },
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  data() {
    return {
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      //Android端末で編集中であることを示すフラグ
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      facilitylistValue: ""
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return {
        "--height": "auto",
        "padding-left": 0
      };
    },
    ntssListStyles() {
      return {
        display: this.columns.length == 1 ? "none" : "inherit",
        fontSize: "1em",
        padding: "0 0 0 0.375rem"
      };
    },
    ...mapGetters("mst-weight-scale", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified"
    }),
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isRecordModified || !this.kendoValidator.validate())
      );
    }
  },
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("mst-weight-scale", [
      "setMasterName",
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "findRecordListByFacilityCd",
      "updateRecordListByFacilityCd"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    // add #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng start
    numericEditor(container, options) {
      let strinput= '<input id="myInputNumber" type="number" style="text-align:right" data-bind="value:' + options.field + '"/> ';
      const masterField = this.getMasterRecordList.schema.model.fields[options.field];
      const decimalPlaces = options.format.slice(4, options.format.length - 1);
      let parameterMin = masterField.validation.min
      let parameterMax = masterField.validation.max
      let parameterStep = Math.pow(10, -decimalPlaces);
      let parameter = {step: parameterStep, format: "n"+decimalPlaces}
      parameter.spin = ()=> {
        let value = $('#myInputNumber').data('kendoNumericTextBox').value()
        // 数値範囲内かどうかの確認
        let newValue = value;
        if (value > parameterMax) {
          newValue = parameterMin;
        } else if (value <  parameterMin) {
          newValue = parameterMax;
        }
        if ($('#myInputNumber').data('kendoNumericTextBox')?.element[0]?.value != null) {
          $('#myInputNumber').data('kendoNumericTextBox').element[0].value = newValue.toFixed(decimalPlaces);
        } else {
          $('#myInputNumber').data('kendoNumericTextBox').value(newValue);
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
      }
      $(strinput).appendTo(container).kendoNumericTextBox(parameter);
      this.$nextTick(() => {
        let value = options.model[options.field];
        if ($('#myInputNumber').data('kendoNumericTextBox')?.element[0]?.value != null) {
          $('#myInputNumber').data('kendoNumericTextBox').element[0].value = value.toFixed(decimalPlaces);
        }
        $('#myInputNumber').prev().attr('type','number')
        $('#myInputNumber').data('kendoNumericTextBox').element.on("mousewheel", (event)=>{
          let delta = (event.originalEvent.wheelDelta && (event.originalEvent.wheelDelta > 0 ? 1 : -1)) ||
                      (event.originalEvent.detail && (event.originalEvent.wheelDelta > 0 ? -1 : 1))
          let value = parseFloat(event.target.value)
          if (isNaN(value)) {
            value = 0;
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
          if ($('#myInputNumber').data('kendoNumericTextBox')?.element[0]?.value != null) {
            $('#myInputNumber').data('kendoNumericTextBox').element[0].value = value.toFixed(decimalPlaces);
          } else {
            $('#myInputNumber').data('kendoNumericTextBox').value(value);
          }
        })
        $('#myInputNumber').data('kendoNumericTextBox').element.on("blur", () => {
          if ($('#myInputNumber').data('kendoNumericTextBox')) {
            $('#myInputNumber').data('kendoNumericTextBox').trigger('change');
          }
        })
      })
    },
    // #11515 体重計マスタ>2回測定チェック許容範囲値でスピナーでは小数点が入力できない linjunfeng end
    async editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        e.preventDefault();
        return;
      }
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
    // マスタ一覧のデータを取得
    findList() {
      this.setMasterName("mst_weight_scale");
      // apiをコールして値を取得
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.findRecordList => this.findRecordListByFacilityCd
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(response => {
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // add FNSI-redmine3987 徐 start
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : "14em";
            column.width = column.field === "isDisp" ? "9em" : "15em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // add FNSI-redmine3987 徐 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // カラム幅等初期調整
          this.showSortColumn();
          // 初期データ内容を保存
          this.setComparisonRecordModel();

          // 初期データが1件もなければ追加
          if (this.getMasterRecordList.data.length === 0) {
            this.addRow();
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightScaleListRecordComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return {
          response: -2,
          message: "不正な値があります"
        };
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      if (validateMessage.length !== 0) {
        message = "以下の列に未入力項目が存在します。" + validateMessage;
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          message + "以下の列の選択を見直してください。" + validateComboMessage;
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        return {
          response: -1,
          message: message
        };
      }

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 孔 start
      const params = {
        request: this.getUpdateRecordList,
        facilityCd: this.facilitylistValue
      }
      // add マスタ一覧 1･施設切替を可能とする 孔 start
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.updateRecordList => this.updateRecordListByFacilityCd
      // return this.updateRecordList(this.getUpdateRecordList)
      return this.updateRecordListByFacilityCd(params)
        .then(response => {
          this.updateResponse = response.data;

          this.findList();
          return {
            response: 1,
            message: response.data
          };
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightScaleListRecordComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            return {
              response: 0,
              message: error.response.data.errorMessage
            };
          }
        });
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const validation =
            gridData.schema.model.fields[keys[keyCount]].validation;
          if (typeof validation !== "undefined" && validation.required) {
            if (
              gridData.data[idx][keys[keyCount]] !== null &&
              gridData.data[idx][keys[keyCount]] === ""
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount]
              );
              // 項目名が重複していなければ、メッセージに追加
              validateMessageArr.push(columnInfo.title);
            }
          }
        }
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
          values: column.values
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data.filter(row => row.isDisp !== "0");
      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue
          );
          if (index < 0 && (columnValue !== null && columnValue !== "")) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return "";

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    sort() {
      const compare = (a, b) =>
        a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      //グリッドデータの並び替え
      this.getMasterRecordList.data.sort(compare);
    },
    onSave(ev) {
      this.setIsGridEditing(false);
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model["edited"] = true;
      }
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $$("div.k-grid-content")[0];
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
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;

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
      }, 1000);
    },
    setScrollPosition(position) {
      $$("div.k-grid-content")
        .scrollTop(position.top)
        .scrollLeft(position.left);
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else {
          d[k] = null;
        }

        if (k === "patIdDigit") {
          d[k] = 12;
        } else if (k === "isDoubleCheck" || k === "isDuringDialysisView") {
          d[k] = "0";
        } else if (
          k === "name" ||
          k === "defaultScreenClass" ||
          k === "tareUnitClass" ||
          k === "waterUnitClass" ||
          k === "previousWeightSourceClass"
        ) {
          d[k] = 0;
        }
      });
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      // 変更とする
      d["edited"] = true;
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === "sortRank"
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
    },
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "sortRank"
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }
        const tbodyc = this.$refs.grid.$el.lastChild.lastChild.tBodies[0]
          .children;
        // add #9863 編集時背景色表示異常の横展開 蔡 start
        const lockTbodyc = this.$refs.grid.$el.children[1].lastChild.tBodies[0].children;
        // add #9863 編集時背景色表示異常の横展開 蔡 end 
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          // add #9863 編集時背景色表示異常の横展開 蔡 start
          const currentLockTrc = lockTbodyc[rwCount].children;
          // add #9863 編集時背景色表示異常の横展開 蔡 end
          // 並び順の色変更
          this.changeSortColor(currentTrc);
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);

          // モーダルからの編集も色を変更する
          if (
            this.isEdited(currentTrc[this.getColumnIndex("code")].textContent)
          ) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, edited, deleted);
          // データ参照エラーコンボの背景色を変更
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // this.changeRefErrorComboColor(currentTrc, deleted);
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
        }
      });
    },
    changeSortColor(currentTrc) {
      // 並び順が変更されていれば並び順とダミー項目背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount === this.getColumnIndex("sortRank")
        ) {
          currentTrc[clCount]?.classList?.add("master-sort-edited");
          const dummyIndex = this.getColumnIndex("dummy");
          if (dummyIndex > -1) {
            currentTrc[dummyIndex]?.classList?.add("master-sort-edited");
          }
        }
      }
    },
    changeEditColor(currentTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount !== this.getColumnIndex("sortRank")
        ) {
          currentTrc[clCount]?.classList?.add("master-edited-cell");
          edited = true;
        }
      }
      return edited;
    },
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount !== this.getColumnIndex("sortRank")
        ) {
          if (
            currentTrc[clCount].children[0].nextSibling &&
            currentTrc[clCount].children[0].nextSibling.data === "削除" &&
            this.getColumnIndex("isDisp") === clCount
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    changeRowColor(currentTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? "master-deleted-row" : "master-edited-row";

        for (
          let clCount = this.getColumnIndex("sortRank") + 1;
          clCount < currentTrc.length;
          clCount++
        ) {
          currentTrc[clCount]?.classList?.add(addClass);
        }
      }
    },
    // mod #9863 編集時背景色表示異常の横展開 蔡 start
    // changeRefErrorComboColor(currentTrc, rowDeleted) {
    // currentLockTrc：左gridのリストを取得する
    changeRefErrorComboColor(currentUnLockTrc, rowDeleted, currentLockTrc) {
    // mod #9863 編集時背景色表示異常の横展開 蔡 end
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 start
      let currentTrc = [];
      for (let clCount = 0; clCount < currentLockTrc.length; clCount++) {
        currentTrc.push(currentLockTrc[clCount]);
      }
      for (let clCount = 0; clCount < currentUnLockTrc.length; clCount++) {
        currentTrc.push(currentUnLockTrc[clCount]);
      }
      if (currentTrc.length !== this.columns.length) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 end
      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          currentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field
        );
        if (
          columnInfo.values !== null &&
          hasValueColumn &&
          currentTrc[clCount].textContent === ""
        ) {
          currentTrc[clCount]?.classList?.add("master-deleted-combo");
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key))
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
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
                this.loadGridData();
              }
            }
          });
        } else {
          this.loadGridData();
        }
      }
    }
  },
  created() {
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    this.loadGridData();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
  }
  // add 性能改善メモリ不足 shan start
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.ntss-list{
  position: relative;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: 2.5em;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.k-grid-toolbar {
  padding: 0;
}
.weight-scale-grid >>> .k-grid .k-grid-content.k-auto-scrollable {
  max-height: 120px;
}
</style>
