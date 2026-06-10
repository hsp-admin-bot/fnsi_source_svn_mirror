<!-- 風袋・除水補正 -->
<template>
  <div class="tare-off-water-grid">
    <v-ons-row id="selectUnitArea">
      <v-ons-col style="text-align: start;">
        <v-ons-segment style="width: 120px;" :index.sync="segmentIndex">
          <!-- 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin mod start -->
          <!-- mod FNSI-改修内容 権限関連 趙慧敏 start -->
          <!-- <button value="0" class="segment-button" :disabled="!hasDevicesetInfoAuthority" @click="selectUnit">g -->
          <!-- mod FNSI-改修内容 権限関連 趙慧敏 end -->
          <!-- </button> -->
          <!-- mod FNSI-改修内容 権限関連 趙慧敏 start -->
          <!-- <button value="1" class="segment-button" :disabled="!hasDevicesetInfoAuthority" @click="selectUnit">kg -->
          <!-- mod FNSI-改修内容 権限関連 趙慧敏 end -->
          <!-- </button> -->
          <button value="0" class="segment-button" @click="selectUnit">g</button>
          <button value="1" class="segment-button" @click="selectUnit">kg</button>
          <!-- 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin mod end -->
        </v-ons-segment>
      </v-ons-col>
    </v-ons-row>

    <!-- <kendo-grid
      ref="tareAndOffWaterInfoGrid"
      class="tare-offwater"
      :data-source="localDataSource"
      :data-bound="gridSetting"
      :editable="!disEdit"
      :scrollable="true"
      :height="kendoGridHeight"
      :edit="addInputAssist"
      :beforeEdit="editStart"
      :cellClose="editEnd"
      @save="onSave"
      @cellclose="
        () => {
          swipeFlag = true;
        }"
    > -->
    <kendo-grid
      ref="tareAndOffWaterInfoGrid"
      class="tare-offwater"
      :data-source="localDataSource"
      :data-bound="gridSetting"
      :editable="!disEdit && !getIsOtherFacility"
      :scrollable="true"
      :height="kendoGridHeight"
      :edit="addInputAssist"
      :beforeEdit="editStart"
      :cellClose="editEnd"
      @save="onSave"
      @cellclose="
        () => {
          swipeFlag = true;
        }"
    >
      <!-- 項目名 -->
      <kendo-grid-column
        :field="'rowTitle'"
        :title="'項目'"
        :width="90"
        :attributes="{ class: 'deviceSetInfo-row-name' }"
        :header-attributes="{ class: 'deviceSetInfo-header-row-name' }"
        @editable="() => false"
        :locked="true"
      />
      <!-- 全体 -->
      <kendo-grid-column
        :columns="multColumnListAll"
        :title="columnHeaderTitle()"
        :header-attributes="columnHeaderClass"
        :header-template="headerTemplateAll"
      />
      <!-- 月曜～日曜 -->
      <kendo-grid-column v-for="n of 7" :key="n"
        :columns="multColumnListWeek[n - 1]"
        :title="columnHeaderTitle(n)"
        :header-attributes="columnHeaderClass"
        :header-template="headerTemplateWeek(n)"
      />
    </kendo-grid>
  </div>
</template>
<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  /**
   * 共通処理用
   */
  import {ApiHelper} from "@/apis/AxiosHelper";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  /**
   * jQuery
   */
  import $ from "jquery";
  /**
   * 日時操作
   */
  import moment from "moment";
  /**
   * オブジェクト、配列操作
   */
  import _ from "underscore";
  /**
   * Vue関連
   */
  /*mod FNSI-改修内容6025 任 start*/
  /*import {mapGetters} from "vuex";*/
  import {mapActions, mapGetters} from "vuex";
  /*mod FNSI-改修内容6025 任 end*/
  /**
   * 小数点計算
   */
  import BigNumber from "bignumber.js";
  // add FNSI-改修内容 権限関連 趙慧敏 start
  // del #10359 編集権限の動作不正 dengshen start
  // import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  // del #10359 編集権限の動作不正 dengshen end
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
  // add FNSI-改修内容 権限関連 趙慧敏 end
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
  import { EventBus } from "@/eventBus.js";
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

export default {

  props: {
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
     * 風袋・除水補正フラグ
     * 0->風袋、1->除水補正
     */
    propsTareOffWaterInfoFlag: {
      type: Number,
      required: true
    }
  },
  // del #10359 編集権限の動作不正 dengshen start
  // // add FNSI-改修内容 権限関連 趙慧敏 start
  // mixins: [ComponentGuardMixin],
  // // add FNSI-改修内容 権限関連 趙慧敏 end
  // del #10359 編集権限の動作不正 dengshen end

  data() {
    return {
      segmentIndex: 0,
      /**
       * テーブルの高さ
       */
      kendoGridHeight: 300,
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
      // del #10359 編集権限の動作不正 dengshen start
      // // add FNSI-改修内容 権限関連 趙慧敏 start
      // authorityCds: [
      //   AUTHORITY_CODES.PAT_PEDIT,  // 患者情報-代行編集
      //   AUTHORITY_CODES.PAT_EDIT    // 患者情報-編集
      // ],
      // // add FNSI-改修内容 権限関連 趙慧敏 end
      // del #10359 編集権限の動作不正 dengshen end

      /**
       * マルチヘッダー列データ
       */
      multColumnListAll: [],
      multColumnListWeek: [],
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
      disEdit: false,
      /**
       * 全体編集のチェック
       */
      chkAllEditFlg: false,
      /**
       * Android端末で編集中であることを示すフラグ
       */
      editingFlg: false,
      /**
       * Android端末使用フラグ
       */
      androidFlg: false,

      // add FNSI-改修内容 権限関連 趙慧敏 start
      hasDevicesetInfoAuthority: false,
      // add FNSI-改修内容 権限関連 趙慧敏 end

      /**
       * IOS端末使用フラグ
       */
      iosFlg: false
    };
  },

  computed: {
    //施設コード取得用
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
// add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
    /*mod FNSI-改修内容4367 任 start*/
    /*...mapGetters("account-edit", ["getStateUserAccountInfo"]),*/
    ...mapGetters("account-edit", ["getStateUserAccountInfo","getFontSize", "getPatientShareMode", "getPatientShareFacilityCdMode"]),
    /*mod FNSI-改修内容4367 任 end*/
    ...mapGetters("pat-info", ["selectedPat", "getIsOtherFacility", "getOtherFacilityCd"]),
// add FNSI 1006 No.538 外部連携APIを呼び出 陳 end

    /**
     * 曜日列ヘッダークラス
     */
    columnHeaderClass() {
      return { class: "deviceSetInfo-header-first-name" };
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
    /*add FNSI-改修内容4367 任 start*/
    getFontSize() {
      this.gridSetting();
    },
    /*add FNSI-改修内容4367 任 end*/
    /**
     * 画面の高さ変更時の幅調整
     */
    windowHeight() {
      this.calculateGridHeight();
    }
  },

  async created() {
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }

    // マルチカラム情報の設定
    this.setMultColumnInfoAll();
    this.setMultColumnInfoWeek();
    // add FNSI-改修内容 権限関連 趙慧敏 start
    this.hasDevicesetInfoAuthority = this.getDevicesetInfoAuthority();
    // add FNSI-改修内容 権限関連 趙慧敏 end
    // 初期データの設定
    this.localDataSource.data = this.setInitLocalData();
    // DB風袋/除水補正情報取得
    const getData = await this.getPatMain();
    // DBデータを内部用データに加工
    this.localDataSource.data = this.convertGridData(getData);
    // 全曜日が同じ値かをチェックし、同じ値であれば、全チェックフラグにチェックを入れる
    this.chkAllEditFlg = this.checkAllFlg();
    // Grid再描画処理
    await this.gridRefresh();
    // 変更比較(変更前)データ作成
    this.initValue = this.adjustmentInitValue(this.setInitValue(getData));
    // 変更比較(変更後)データ作成
    this.editValue = deepCopy(this.initValue);
    // 患者情報編集時処理 対象患者のすべての治療情報を取得
    this.getTargetOrdMain();
    // 患者情報編集時処理 警告対象の治療情報を取得
    this.getAlertOrdMain();
  },
  
  mounted() {    
    // 画面印刷時のイベント追加
    // gridの固定列設定されたままだと、table構造が複雑で、cssで幅をレスポンシブに設定不可
    this.handleBeforePrint = () => {
      // 1列目の固定解除
      const grid = this.$refs.tareAndOffWaterInfoGrid.kendoWidget();
      const columns = grid.getOptions().columns;
      columns[0].locked = false;
    
      grid.setOptions({ columns }); // マルチヘッダなのでsetOptionsでないと固定列解除不可
      
      // grid.setOptionsで固定列解除すると背景色、ヘッダテンプレートのチェックボックス等が消える為、再設定
      this.setEditColor();
      this.addClickEvent();
    };
  
    this.handleAfterPrint = () => {
      // 1列目を固定に戻す
      const grid = this.$refs.tareAndOffWaterInfoGrid.kendoWidget();
      const columns = grid.getOptions().columns;
      columns[0].locked = true;
    
      grid.setOptions({ columns });
    };
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);    
  },

  beforeDestroy() {
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    /*add FNSI-改修内容6025 任 start*/
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    /*add FNSI-改修内容6025 任 end*/
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * 全曜日が同じ値かをチェック
     * @description 全曜日が同じ値：true、異なる：false を返す
     */
    checkAllFlg() {
      let rtnChkAllEditFlg = true;
      const srcData = this.localDataSource.data;
      for (let i = 0; i <= 4; i++) {
        for (let weekNo = 1; weekNo <= 7; weekNo++) {
          // null、undefined、空("") は同じデータとする
          if (!srcData[i]["nameAll"] && !srcData[i][`name_${weekNo}`]) {
            srcData[i]["nameAll"] = srcData[i][`name_${weekNo}`];
          }
          if (!srcData[i]["weightAll"] && !srcData[i][`weight_${weekNo}`]) {
            srcData[i]["weightAll"] = srcData[i][`weight_${weekNo}`];
          }
          // チェック
          if (
            srcData[i]["nameAll"] !== srcData[i][`name_${weekNo}`] ||
            srcData[i]["weightAll"] !== srcData[i][`weight_${weekNo}`])
          {
            rtnChkAllEditFlg = false;
          }
        }
      }
      return rtnChkAllEditFlg;
    },

    /**
     * Windowの高さからGirdコンポーネント領域の高さを算出
     */
    calculateGridHeight() {
      if (!this.editingFlg) {
        const marginHeigh = 15;
        const selectUnitAreaHeight = document.getElementById("selectUnitArea").clientHeight;
        this.kendoGridHeight = document.getElementsByClassName("modal-body")[0].clientHeight - selectUnitAreaHeight - marginHeigh;
        // リフレッシュで背景色、チェックボックスのイベントが初期化される為、再設定
        this.$nextTick(() => {
          this.setEditColor();
          this.addClickEvent();
        });
      }
    },

    /**
     * Gird編集開始時に、Android端末の場合は高さ変更処理が発生しないようにフラグを立てる
     */
    editStart() {
      if (this.androidFlg) {
        this.editingFlg = true;
      }
    },

    /**
     * Gird編集終了時に、フラグを解除する
     */
    editEnd() {
      this.editingFlg = false;
    },

    /**
     * Databaund (Gridにデータが割り当てられた) 時の処理
     */
    gridSetting(){
      // Grid高さの調整
      this.$nextTick(() => {
        this.calculateGridHeight();
        const headerHeight = document.getElementsByClassName("k-grid-header")[0].offsetHeight + 2;
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        // PCでの表示時のみ、スクロールバー分の不要な高さが発生する為、高さの調整を行う
        if (!this.androidFlg && !this.iosFlg) {
          lockRowHeight -= 17;
        }
        document.getElementsByClassName("k-grid-content-locked")[0].style.height = lockRowHeight + "px";
      });
      // ヘッダーにスタイル適用
      this.$refs.tareAndOffWaterInfoGrid.$el.firstElementChild.style.backgroundColor = "var(--ntss-list-header-background-color)";
      this.$refs.tareAndOffWaterInfoGrid.$el.firstElementChild.firstElementChild.style.borderColor = "var(--ntss-base-background-color)";
      // 慣性スクロール用のクラスを追加
      document.getElementsByClassName("k-auto-scrollable")[1].style.WebkitOverflowScrolling = "touch";
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
     * マルチ列情報の作成(全体項目)
     * @description 名称列と重さ列の情報を設定
     */
    setMultColumnInfoAll() {
      for (let i = 0; i < 2; i++) {
        const columnName = 0 === i ? "name" : "weight";
        const obj = {
          field: `${columnName}All`,
          title: 0 === i ? "名称" : "重さ",
          width: "100px",
          editor: this.setEditor,
          headerAttributes: { class: "deviceSetInfo-header-secound-name" },
          attributes: {
            class: `deviceSetInfo-${columnName}-content ${columnName}All-item`
          },
          format: "",
          editable: () => this.chkAllEditFlg && this.hasDevicesetInfoAuthority
        };
        this.multColumnListAll.push(obj);
      }
    },

    /**
     * マルチ列情報の作成(曜日項目)
     * @description 名称列と重さ列の情報を設定
     */
    setMultColumnInfoWeek() {
      for (let weekNo = 1; weekNo <= 7; weekNo++) {
        let colObj = [];
        for (let i = 0; i < 2; i++) {
          const columnName = 0 === i ? "name" : "weight";
          const obj = {
            field: `${columnName}_${weekNo}`,
            title: 0 === i ? "名称" : "重さ",
            width: "100px",
            editor: this.setEditor,
            headerAttributes: { class: "deviceSetInfo-header-secound-name" },
            attributes: {
              class: `deviceSetInfo-${columnName}-content ${columnName}_${weekNo}-item`
            },
            format: "",
            editable: () => !this.chkAllEditFlg && this.hasDevicesetInfoAuthority
          };
          colObj.push(obj);
        }
        this.multColumnListWeek.push(colObj);
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
          nameAll: "",
          // 重さ項目
          weightAll: ""
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
     * ヘッダータイトル
     */
    columnHeaderTitle(weekNo) {
      return weekNo ? this.convertStrWeek(weekNo) : "全";
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
      // 表に表示できるように整形
      for (let weekNo = 1; weekNo <= 7; weekNo++) {
        if (
          null !== data[weekNo] &&
          undefined !== data[weekNo]
        ) {
          for (let itemNo = 0; itemNo <= 4; itemNo++) {
            // 名称項目
            loacalData[itemNo][`name_${weekNo}`] = data[weekNo][`name_${itemNo + 1}`];
            // 重さ項目値
            const weightValue = data[weekNo][`weight_${itemNo + 1}`];
            // TODO
            let rtn = 0;
            // 選択中の単位が「kg」で格納する値がnullでなければ
            if (
              1 === this.selectedUnit &&
              null !== weightValue &&
              "" !== weightValue
            ) {
              rtn = this.procDecimal(weightValue / 1000);
            } else {
              rtn = weightValue;
            }
            loacalData[itemNo][`weight_${weekNo}`] = rtn;

            // 月曜日のデータを全体項目として定義する
            if (weekNo === 1) {
              loacalData[itemNo]["nameAll"] = data[weekNo][`name_${itemNo + 1}`];
              loacalData[itemNo]["weightAll"] = rtn;
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
      if (Object.keys(data).length) {
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
      // 全体項目の領域を追加(初期値として月曜日のデータを格納)
      data["All"] = {};
      for (let i = 1; i <= 5; i++) {
        data["All"][`name_${i}`] = data["1"][`name_${i}`];
        data["All"][`weight_${i}`] = data["1"][`weight_${i}`];
      }
      return data;
    },

    /**
     * 患者情報からDBデータ取得
     */
    async getPatMain() {
      // 患者IDがない場合は空のObjectを返す
      if (!this.patId) {
        return {};
      }
      // mod #12462 患者情報共有 Ji start
      // const url = `deviceSetInfo/getPatTareAndOffWaterById/${this.patId}`;
      let otherFacilityCd = this.getIsOtherFacility ? `/${this.getOtherFacilityCd}` : '';
      if (this.getPatientShareMode == 0 && this.getPatientShareFacilityCdMode == null) {
        otherFacilityCd = '';
      }
      const url = `deviceSetInfo/getPatTareAndOffWaterById/${this.patId}${otherFacilityCd}`;
      // mod #12462 患者情報共有 Ji end
      // データ取得
      const response = await ApiHelper.get(url).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoForDeviceSet.vue', 'getPatMain', error);
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
      // Gridのリフレッシュ
      await this.refresh();
      // スクロール量の設定()
      this.setScrollPos();
      // 編集色の付与
      this.setEditColor();
      // チェックイベントの追加
      this.addClickEvent();
    },

    /**
     * スクロール量取得
     */
    getScrollPos() {
      this.scrollPos = $(".indInfo-style-modal-container").scrollTop();
    },

    /**
     * スクロール量の設定
     */
    setScrollPos() {
      $(".indInfo-style-modal-container").scrollTop(this.scrollPos);
    },

    /**
     * 合計量算出
     */
    calculateSum() {
      // 全体項目の合計
      const wa = "weightAll";
      this.localDataSource.data[5][wa] = null;
      // 6行目の風袋補正量合計に合計量を格納する
      for (let i = 0; i < this.localDataSource.data.length - 1; i++) {
        // 値が空でなければ合計量を加算する
        if (this.localDataSource.data[i][wa]) {
          const sumValue = new BigNumber(this.localDataSource.data[5][wa] ? this.localDataSource.data[5][wa] : 0);
          const plusValue = new BigNumber(this.localDataSource.data[i][wa]);
          this.localDataSource.data[5][wa] = sumValue.plus(plusValue).toNumber();
        }
      }

      // 曜日項目の合計
      for (let weekNo = 1; weekNo <= 7; weekNo++) {
        this.localDataSource.data[5][`weight_${weekNo}`] = null;
        // 6行目の風袋補正量合計に合計量を格納する
        for (let i = 0; i < this.localDataSource.data.length - 1; i++) {
          // 値が空でなければ合計量を加算する
          if (this.localDataSource.data[i][`weight_${weekNo}`]) {
            const sumValue = new BigNumber(this.localDataSource.data[5][`weight_${weekNo}`] ? this.localDataSource.data[5][`weight_${weekNo}`] : 0);
            const plusValue = new BigNumber(this.localDataSource.data[i][`weight_${weekNo}`]);
            this.localDataSource.data[5][`weight_${weekNo}`] = sumValue.plus(plusValue).toNumber();
          }
        }
      }
    },

    /**
     * フォーマットの変換
     */
    changeFormat() {
      // 全体項目の単位設定
      this.multColumnListAll[1].format =
        0 === this.selectedUnit
          ? `{0:,# ${this.unit}}`
          : `{0:,#.00 ${this.unit}}`;
      // 曜日項目の単位設定
      for (let weekNo = 1; weekNo <= 7; weekNo++) {
        this.multColumnListWeek[weekNo - 1][1].format =
          0 === this.selectedUnit
            ? `{0:,# ${this.unit}}`
            : `{0:,#.00 ${this.unit}}`;
      }
    },

    /**
     * 桁数変換
     */
    changeDigit() {
      for (let i = 0; i < this.localDataSource.data.length - 1; i++) {

        // 全体項目の処理
        let value = this.localDataSource.data[i]["weightAll"];
        // 値がnullでなければ
        if (null !== value && undefined !== value) {
          // 「g」に変換時は1000倍、「kg」に変換時は1000で除算
          value =
            0 === this.selectedUnit
              ? new BigNumber(value).times(1000).toNumber()
              : this.procDecimal(value);
        }
        this.localDataSource.data[i]["weightAll"] = value;

        // 曜日項目
        for (let weekNo = 1; weekNo <= 7; weekNo++) {
          let value = this.localDataSource.data[i][`weight_${weekNo}`];
          // 値がnullでなければ
          if (null !== value && undefined !== value) {
            // 「g」に変換時は1000倍、「kg」に変換時は1000で除算
            value =
              0 === this.selectedUnit
                ? new BigNumber(value).times(1000).toNumber()
                : this.procDecimal(value);
          }
          this.localDataSource.data[i][`weight_${weekNo}`] = value;
        }
      }

      // 単位「g」選択時は以降の処理を行わない
      if (0 === this.selectedUnit) {
        return;
      }

      // 変更比較データに値を格納
      for (const week in this.editValue) {
        for (let i = 1; i <= 5; i++) {
          const value = this.editValue[week][`weight_${i}`];
          // 値がnullでなけれeditValueのデータを変換する
          if (null !== value && "" !== value && undefined !== value) {
            this.editValue[week][`weight_${i}`] =
              new BigNumber(this.procDecimal(value)).times(1000).toNumber();
          }
        }
      }
    },

    /**
     * 小数点操作
     * @description 風袋->小数点第三位切り捨て、除水補正->小数点第3位切り上げ
     * @param value 小数点操作を行う値
     */
    procDecimal(value) {
      // 風袋
      if (0 === this.propsTareOffWaterInfoFlag) {
        return new BigNumber(value).div(1000).dp(2, BigNumber.ROUND_DOWN).toNumber()
      } else {
        return new BigNumber(value).div(1000).dp(2, BigNumber.ROUND_UP).toNumber()
      }
    },

    /**
     * 画面再描画処理
     */
    refresh() {
      // Kendo UIの画面が立ち上がる前に呼び出されている場合は処理終了
      if (!this.$refs.tareAndOffWaterInfoGrid.kendoWidget()) {
        return;
      }
      this.$refs.tareAndOffWaterInfoGrid.kendoWidget().dataSource.read();
    },

    /**
     * 更新処理
     * @description 親からこの関数を呼んで更新処理を行う
     */
    async updateInfo() {
      /*add FNSI-改修内容6025 任 start*/
      // #8061-装置設定が保存出来ない 周 mod start
      //this.setLoadingScreenMessage("保存中・・・");
      this.setLoadingScreenMessage("処理中・・・");
      // #8061-装置設定が保存出来ない 周 mod end
      this.setLoadingScreenVisible(true);
      /*add FNSI-改修内容6025 任 end*/
      // 更新日時(現在日時)
      this.upDate = moment().format("YYYY-MM-DD HH:mm:ss.SSS");
      // 更新情報(初期値と編集値の差分)
      const updateData = this.createDifferenceValue(
        this.initValue,
        this.editValue
      );
      // 患者情報更新
      await this.updatePatMain(updateData);
      // 反映先データの取得
      this.getReflectOrdMain();
      // 今日含む未来の治療情報にも変更内容を反映するのかを表示する
      this.showMessage(
        13010001,
        "2",
        ["今日含む未来の指示情報", ""],
        "FUTURE_ORD_MAIN"
      );
      /*add FNSI-改修内容6025 任 start*/
      this.setLoadingScreenVisible(false);
      /*add FNSI-改修内容6025 任 end*/
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
        "/deviceSetInfo/updatePatTareOffWaterInfo/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoForDeviceSet.vue', 'updatePatMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
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
      // mod #12462 患者情報共有 Ji start
      // paramJson.facility_cd = this.facilityCd;
      paramJson.facility_cd = this.getIsOtherFacility ? this.getOtherFacilityCd : this.facilityCd;
      // mod #12462 患者情報共有 Ji end
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
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoForDeviceSet.vue', 'getTargetOrdMain', error);
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
      const day = moment().format("YYYYMMDD");
      // 前日の日付け
      const yesterday = moment()
        .subtract(1, "days")
        .format("YYYYMMDD");
      // 更新対象を格納(本日または前日の治療状況が条件送信後～後体重確認前)
      this.reflectOrdMainDataList = this.ordMainList.filter(eleObj => {
        return (
          Number(day) >= Number(eleObj.treatDate) &&
          Number(eleObj.treatDate) >= Number(yesterday) &&
          Number(eleObj.rstDialysisState) >= 1 &&
          6 > Number(eleObj.rstDialysisState)
        );
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
      // del FNSI-予定の場合はord_mainを更新する 趙 start
      // const dispStr1 =
      //   0 === this.propsTareOffWaterInfoFlag ? "風袋" : "除水補正";
      // del FNSI-予定の場合はord_mainを更新する 趙 end
      // 2つ目に置換する文字列
      let dispStr2 = "";
      this.reflectOrdMainDataList.forEach(eleItem => {
        // 更新対象オーダー番号リストの格納
        this.ordNoList.push(eleItem.ordNo);
        // 更新対象を曜日ごとに格納
        if (_.has(this.targetUpdateInfo, eleItem.treatWeek.toString())) {
          // キーが存在している場合、オーダー番号をpush
          this.targetUpdateInfo[eleItem.treatWeek.toString()].push(
            eleItem.ordNo
          );
        } else {
          // キーが存在していない場合は直接代入
          this.targetUpdateInfo[eleItem.treatWeek.toString()] = [eleItem.ordNo];
        }
        // 表示文字列格納処理
        dispStr2 = this.createMessageStr(eleItem, dispStr2);
      });
      // del FNSI-予定の場合はord_mainを更新する 趙 start
      // 表示する文字列が存在する場合のみ表示する
      // const messageCd = 13010001;
      // 親のメッセージ表示処理関数を呼び出す
      // this.showMessage(
      //   messageCd,
      //   "2",
      //   [`以下の透析中実績の${dispStr1}情報`, dispStr2],
      //   "TARGET_ORD_MAIN"
      // );
      // del FNSI-予定の場合はord_mainを更新する 趙 end
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
      const dayBeforeYesterday = moment()
        .subtract(2, "days")
        .format("YYYYMMDD");
      this.alertOrdMainList = this.ordMainList.filter(eleObj => {
        return (
          Number(dayBeforeYesterday) >= Number(eleObj.treatDate) &&
          Number(eleObj.rstDialysisState) >= 3 &&
          6 > Number(eleObj.rstDialysisState)
        );
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
        this.editValue
      );
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
      const treatDate = moment(obj.treatDate, "YYYYMMDD").format("YYYY/MM/DD");
      // 治療曜日
      const treatWeek = this.convertStrWeek(Number(obj.treatWeek));
      // ベッド名
      const indBedName = obj.indBedName;
      // クール名
      const indKurName = obj.indKurName;
      // 治療状況
      const rstDialysisState = this.convertDialysisState(
        Number(obj.rstDialysisState)
      );
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
          this.editValue[treatWeek.toString()]
        );
        // 更新日時
        sendJson.up_date = this.upDate;
        await ApiHelper.post(
          `/deviceSetInfo/updateRstTareOffWaterInfo`,
          sendJson
        ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoForDeviceSet.vue', 'reflectOrdMainInfo', error);
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
        this.editValue
      );
      // 変更のあった曜日リスト
      const editWeek = [];
      for (const week in updateData) {
        editWeek.push(week);
      }
      sendJson[this.columnName] = JSON.stringify(editWeek);
      // 更新日時
      sendJson.up_date = this.upDate;
      // DEL  8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou START
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      // const oldOrdMainList = this.ordMainList;
      // sendJson.oldOrdMainList = oldOrdMainList;
      // let opeCd = "";
      // if (0 === this.propsTareOffWaterInfoFlag) {
      //   opeCd = "010001";
      // } else {
      //   opeCd = "010002";
      // }
      // sendJson.ope_cd = opeCd;
      // sendJson.crud = "U";
      // let treatDate = moment(new Date()).format("YYYYMMDD");
      // sendJson.treatDate = treatDate;
      // sendJson.facility_cd = this.getStateUserAccountInfo.facilityCd;
      // sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
      // sendJson.ind_user = this.getStateUserAccountInfo.userId;
      // // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      // DEL  8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      await ApiHelper.post(
        "/deviceSetInfo/updateFutureIndTareOffWaterInfo/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BaseTareAndOffWaterInfoForDeviceSet.vue', 'updateFutureIndTareAndOffWaterInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      // // add FNSI-予定の場合はord_mainを更新する 趙 start
      // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
      // // del by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      // // this.callCreateJournal(editWeek);
      // // del by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      // // add  8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou START
      //  this.callCreateJournal(editWeek);
      // // add  8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
      // // モーダルを閉じる
      // this.hideModal();
      // // add FNSI-予定の場合はord_mainを更新する 趙 end
      // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
    },

    // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
    // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
    // doCreateJournal() {
    //   let opeCd = "";
    //   let treatDate = moment(new Date()).format("YYYYMMDD");
    //   if (0 === this.propsTareOffWaterInfoFlag) {
    //     opeCd = "010001";
    //   } else {
    //     opeCd = "010002";
    //   }
    //   const params = {
    //     ope_cd: opeCd,
    //     crud: "U",
    //     facility_cd: this.getStateUserAccountInfo.facilityCd,
    //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
    //     // add FNSI-外部連携APIパラメータを追加する 趙 start
    //     pat_id: this.patId,
    //     // add FNSI-外部連携APIパラメータを追加する 趙 end
    //     ord_no: "",
    //     base_date: treatDate,
    //     user_id: this.getStateUserAccountInfo.userId
    //   };
    //   createJournal(params);
    // },
    //
    // callCreateJournal(editWeek) {
    //   const oldOrdMainList = this.ordMainList;
    //   let opeCd = "";
    //   let treatDate = moment(new Date()).format("YYYYMMDD");
    //   if (oldOrdMainList) {
    //     if (0 === this.propsTareOffWaterInfoFlag) {
    //       opeCd = "010001";
    //     } else {
    //       opeCd = "010002";
    //     }
    //     // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
    //     //const params = {
    //     //  ope_cd: opeCd,
    //     //  crud: "U",
    //     //  facility_cd: this.getStateUserAccountInfo.facilityCd,
    //     //  hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
    //     //  // add FNSI-外部連携APIパラメータを追加する 趙 start
    //     //  pat_id: this.patId,
    //     // // add FNSI-外部連携APIパラメータを追加する 趙 end
    //     //  ord_no: "",
    //     //  base_date: "",
    //     //  user_id: this.getStateUserAccountInfo.userId
    //     //};
    //     // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
    //     // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
    //     let journalList = [];
    //     // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
    //     oldOrdMainList.forEach(item => {
    //       if (item.rstDialysisState === "0" && item.treatDate > treatDate && editWeek.toString().indexOf(item.treatWeek.toString()) != -1) {
    //         // mod 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
    //         //createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
    //          journalList.push({
    //           ope_cd: opeCd,
    //           crud: "U",
    //           facility_cd: this.getStateUserAccountInfo.facilityCd,
    //           hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
    //           pat_id: this.patId,
    //           ord_no: item.ordNo,
    //           base_date: item.treatDate,
    //           user_id: this.getStateUserAccountInfo.userId
    //         })
    //         // mod 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
    //       }
    //     });
    //     // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
    //     createJournalList(journalList);
    //     // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
    //   }
    // },
    // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
    // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end

    /**
     * Grid内の値を変更したときの処理
     * @description 内部データを書き換える
     * @param e データの編集を行ったセル情報
     */
    async onSave(e) {
      this.editingFlg = false;
      // スワイプ可能フラグをfalseに変更
      this.swipeFlag = true;
      // 内部データの更新処理
      for (const key in e.values) {
        // 変更した値の格納
        this.localDataSource.data[e.model.id - 1][key] = e.values[key];
        // 変更比較データにデータの格納
        let value = e.values[key];
        // 項目が「重さ」で単位がkgの場合、変更比較データにはgベースの値に変更
        if (key.indexOf("weight") > -1 && 1 === this.selectedUnit && null !== value) {
          value = value * 1000;
        }
        // 変更比較データに変更値を格納
        if (key.indexOf("All") > -1) {
          // 全体項目
          this.setEditValue("All", `${key.slice(0, key.indexOf("All"))}_${e.model.id}`, value);
        } else {
          // 曜日項目
          this.setEditValue(key.slice(-1), `${key.slice(0, key.indexOf("_"))}_${e.model.id}`, value);
        }
      }
      // Grid再描画
      await this.gridRefresh();

      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdit());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    },

    /**
     * 編集値の格納
     */
    setEditValue(weekIndex, key, value) {
      this.editValue[weekIndex][key] = value;
    },

    /**
     * 初期データとの差異のみ取り出す
     * @param initData 初期値
     * @param editData 編集値
     */
    createDifferenceValue(initData, editData) {
      // 全体項目がチェックされている場合は、、、
      if (this.chkAllEditFlg) {
        // 全体項目を曜日項目にコピー
        for (let weekNo = 1; weekNo <= 7; weekNo++) {
          for (let i = 1; i <= 5; i++) {
            editData[weekNo][`name_${i}`] = editData["All"][`name_${i}`];
            editData[weekNo][`weight_${i}`] = editData["All"][`weight_${i}`];
          }
        }
        // 全体項目をアップデート対処から除外
        initData["All"] = editData["All"];
      } else {
        // 全チェックがされていない場合は、全体項目除外のみ実施
        initData["All"] = editData["All"];
      }

      const differenceData = {};
      for (const key in initData) {
        // 初期値と差異のあるものを取り出す
        const difference = Object.keys(editData[key]).filter(
          item => editData[key][item] !== initData[key][item]
        );
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
      // 変更箇所数
      const editCount = this.getEditCount(
          this.initValue,
          this.editValue
      );
      return 0 !== editCount;
    },
    /**
     * 保存ボタンの活性or非活性判定
     */
    isEdit() {
      return this.checkEdit();
    },
    /**
     * 変更あり件数を取得
     * @param initData 初期値
     * @param editData 編集値
     */
    getEditCount(initData, editData) {
      let editCount = 0;
      for (const key in initData) {
        if (this.chkAllEditFlg) {
          // 全チェックボックスON -> 各曜日データは変更チェック対象外
          if (key !== "All") continue;
        } else {
          // 全チェックボックスOFF -> 全データは変更チェック対象外
          if (key === "All") continue;
        }
        // 初期値と差異のあるデータを取り出す
        const difference = Object.keys(editData[key]).filter(
          item => editData[key][item] !== initData[key][item]
        );
        // 初期データと編集データで差異があった件数カウント
        if (0 !== difference.length) {
          editCount++;
        }
      }
      return editCount;
    },
    /**
     * 編集色の設定 (データリフレッシュ時に初期化される為、毎回全項目確認する)
     */
    setEditColor() {
      if (this.chkAllEditFlg) {
        // 全体項目チェックオン

        // 初期値 ※each内でthisが使用できないため定数に格納
        const initDataAll = deepCopy(this.initValue["All"]);
        // 編集値
        const editDataAll = deepCopy(this.editValue["All"]);
        // 名称項目、重さ項目でループ
        for (let i = 0; i < 2; i++) {
          const itemName = 0 === i ? "name" : "weight";
          // 名称項目編集チェック
          $(`.${itemName}All-item`).each((index, elment) => {
            // 合計量行は処理を行わない
            if (5 === index) {
              return;
            }
            // 初期値と編集値が異なれば、編集職のクラスを追加
            if (
              initDataAll[`${itemName}_${index + 1}`] !==
              editDataAll[`${itemName}_${index + 1}`]
            ) {
              // 文字色、背景色を変更するクラスを追加(変更箇所あり)
              $(elment).addClass("grid-edited-cell");
            } else {
              // クラスを削除(変更箇所なし)
              $(elment).removeClass("grid-edited-cell");
            }
          });
        }
        // 曜日項目は無効色にする
        for (let weekNo = 1; weekNo <= 7; weekNo++) {
          for (let i = 0; i < 2; i++) {
            const itemName = 0 === i ? "name" : "weight";
            // 名称項目編集チェック
            $(`.${itemName}_${weekNo}-item`).each((index, elment) => {
              $(elment).addClass("grid-column-disabled-color");
            });
          }
        }

      } else {
        // 全体項目チェックオフ

        // 全体項目を無効色にする
        for (let i = 0; i < 2; i++) {
          const itemName = 0 === i ? "name" : "weight";
          // 名称項目編集チェック
          $(`.${itemName}All-item`).each((index, elment) => {
            $(elment).addClass("grid-column-disabled-color");
          });
        }

        // 曜日項目
        for (let weekNo = 1; weekNo <= 7; weekNo++) {
          // 初期値 ※each内でthisが使用できないため定数に格納
          const initData = deepCopy(this.initValue[weekNo]);
          // 編集値
          const editData = deepCopy(this.editValue[weekNo]);
          // 名称項目、重さ項目でループ
          for (let i = 0; i < 2; i++) {
            const itemName = 0 === i ? "name" : "weight";
            // 名称項目編集チェック
            $(`.${itemName}_${weekNo}-item`).each((index, elment) => {
              // 合計量行は処理を行わない
              if (5 === index) {
                return;
              }
              // 初期値と編集値が異なれば、編集職のクラスを追加
              if (
                initData[`${itemName}_${index + 1}`] !==
                editData[`${itemName}_${index + 1}`]
              ) {
                // 文字色、背景色を変更するクラスを追加(変更箇所あり)
                $(elment).addClass("grid-edited-cell");
              } else {
                // クラスを削除(変更箇所なし)
                $(elment).removeClass("grid-edited-cell");
              }
            });
          }
        }
      }
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
        if (data.field.indexOf("weight") > -1) {
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
        if (data.field.indexOf("weight") > -1) {
          this.swipeFlag = false;
          // kendoNumericTextBoxの最大値
          const max = this.numericMaxValue;
          // kendoNumericTextBoxの最小値
          const min = this.numericMinValue;
          // kendoNumericTextBoxのステップ
          const step = this.numericStepValue;
          // kendoNumericTextBoxの有効小数点桁数
          const decimals = this.numericDecimalsValue;
          // 数値型テキストボックス(kendo UI)
          $(
            `<input class="deviceSetInfo-numbersTextbox" id="Calories" name="${data.field}" />`
          )
            .appendTo(container)
            .kendoNumericTextBox({
              min,
              max,
              step,
              decimals
            })
            // マウスホイールイベントイベント
            .on("mousewheel", function(e) {
              if (e.originalEvent.wheelDelta / 120 > 0) {
                this.value =
                  max > Number(this.value)
                    ? Number(this.value) + step
                    : Number(this.value);
                // 小数点第2位で切り上げ
                this.value = Math.round(this.value * 100) / 100;
              } else {
                // 最小値より値が大きければ処理
                this.value =
                  Number(this.value) > min
                    ? Number(this.value) - step
                    : Number(this.value);
                // 小数点第2位で切り上げ
                this.value = Math.round(Number(this.value) * 100) / 100;
              }
            });
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
                e.currentTarget.style.height = ( e.currentTarget.scrollHeight + 5 ) + "px";
              }, 0);
            },
            "keydown": (e)=>{
              if (e.key === "Enter") {
                return false;
              }
            }
          }).appendTo(container).trigger("input");
          // 入力中の高さ追従処理
          const resizeObserver = new ResizeObserver(entries => {
            this.$refs.tareAndOffWaterInfoGrid.kendoWidget().resize(document.getElementsByClassName("k-grid-content-locked"));
          });
          resizeObserver.observe(document.querySelector('.resize-obs-target'));
        }
      }
    },

    /**
     * ヘッダーテンプレート(全体項目)
     */
    headerTemplateAll() {
      // ヘッダー一段目に設定するHTML要素
      // mod FNSI-改修内容 権限関連 趙慧敏 start
      /* const template = `<input type="checkbox" id="chkAllEdit" class="checkbox__input header-checkbox">` +
                       `<span class="checkbox__checkmark"></span><label style="margin-left: 1em;">全</label>`; */
      let template = "";
      if(this.hasDevicesetInfoAuthority){
        template = `<input type="checkbox" id="chkAllEdit" class="checkbox__input header-checkbox">` +
                   `<span class="checkbox__checkmark"></span><label style="margin-left: 1em;">全</label>`;
      } else {
        template = `<input type="checkbox" id="chkAllEdit" class="checkbox__input header-checkbox" disabled>` +
                   `<span class="checkbox__checkmark"></span><label style="margin-left: 1em;">全</label>`;
      }
      // mod FNSI-改修内容 権限関連 趙慧敏 end
      return template;
    },

    /**
     * ヘッダーテンプレート(曜日項目)
     */
    headerTemplateWeek(n) {
      // ヘッダー名
      const weekName = this.convertStrWeek(n);
      // ヘッダー名クラス
      let weekNameStyle = "";
      if (6 === n) {
        // 土曜日選択時文字色
        weekNameStyle = "color: var(--ntss-saturday-color);";
      } else if (7 === n) {
        // 日曜日選択時文字色
        weekNameStyle = "color: var(--ntss-sunday-color);";
      }
      // ヘッダー一段目に設定するHTML要素
      const template = `<label style="margin: 20%; ${weekNameStyle}">${weekName}</label>`;
      return template;
    },

    /**
     * チェックボックスにイベントの追加
     */
    addClickEvent() {
      // 初期チェック状態を設定
      if (this.chkAllEditFlg) {
        $("#chkAllEdit").prop('checked', true);
      } else {
        $("#chkAllEdit").prop('checked', false);
      }

      // CheckBox チェック時のイベントを一旦削除してから付与する(再描画の度にイベントが外れる為、都度設定する)
      $("#chkAllEdit").off('click');
      $("#chkAllEdit").on("click", (e) => {
        if (e.target.checked) {
          this.chkAllEditFlg = true;
          // 全体項目の無効色を解除する
          for (let i = 0; i < 2; i++) {
            const itemName = 0 === i ? "name" : "weight";
            $(`.${itemName}All-item`).each((index, elment) => {
              $(elment).removeClass("grid-column-disabled-color");
            });
          }
          // 曜日項目の編集済み色を解除する
          for (let weekNo = 1; weekNo <= 7; weekNo++) {
            for (let i = 0; i < 2; i++) {
              const itemName = 0 === i ? "name" : "weight";
              $(`.${itemName}_${weekNo}-item`).each((index, elment) => {
                $(elment).removeClass("grid-edited-cell");
              });
            }
          }

        } else {
          this.chkAllEditFlg = false;
          // 全体項目の編集済み色を解除する
          for (let i = 0; i < 2; i++) {
            const itemName = 0 === i ? "name" : "weight";
            $(`.${itemName}All-item`).each((index, elment) => {
              $(elment).removeClass("grid-edited-cell");
            });
          }
          // 曜日枠の無効色を解除する
          for (let weekNo = 1; weekNo <= 7; weekNo++) {
            for (let i = 0; i < 2; i++) {
              const itemName = 0 === i ? "name" : "weight";
              $(`.${itemName}_${weekNo}-item`).each((index, elment) => {
                $(elment).removeClass("grid-column-disabled-color");
              });
            }
          }
        }
        // 編集色の付与処理を実施
        this.setEditColor();
        // 保存ボタン活性or非活性
        EventBus.$emit("deviceSetChanged", this.isEdit());
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
        if (document.getElementsByClassName("k-numerictextbox").length !== 0) {
          let spinnerObj = document.getElementsByClassName('k-numerictextbox')[0].getElementsByClassName('k-select')[0];
          // 編集が終了するとオブジェクトが削除される為、removeEvent処理は不要
          spinnerObj.ontouchend = function(event) {
            event.stopPropagation();
          };
        }
      }
    },
    // add FNSI-改修内容 権限関連 趙慧敏 start
    getDevicesetInfoAuthority() {
      // mod #10359 編集権限の動作不正 dengshen start
      // return this.hasAuthorityByCd(AUTHORITY_CODES.PAT_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.PAT_EDIT);
      return this.getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater');
      // mod #10359 編集権限の動作不正 dengshen end
    }
    // add FNSI-改修内容 権限関連 趙慧敏 end
  }
};
</script>

<style scoped>
.tare-offwater,
.tare-off-water-grid >>> .k-grid th {
  font-size: inherit;
}
.tare-off-water-grid >>> .k-grid td {
  word-break: break-all;
  white-space: normal;
  padding-left: 5px !important;
  padding-right: 5px !important;
  font-size: inherit;
}
.tare-off-water-grid >>> .k-grid td input{
  padding-left: 3px ;
  padding-right: 3px ;
}

@media print {
  .tare-off-water-grid >>> div {
    height: auto !important;
  }
  .tare-off-water-grid >>> .k-grid .k-grid-header {
    padding-right: 0 !important;
  }
  /* 項目列（1列目）幅指定 */
  .tare-off-water-grid >>> .k-grid thead th:first-child {
    width: 0.5% !important;
    min-width: 0.5% !important;
    max-width: 100% !important;
  }
  /* =========================
   * Grid全体
   * ========================= */
  .tare-off-water-grid >>> .k-grid {
    width: 100% !important;
    max-width: 100% !important;
    overflow: hidden !important;
  }
  /* =========================
   * テーブル
   * ========================= */
  .tare-off-water-grid >>> .k-grid table {
    width: 100% !important;
    table-layout: fixed !important;
    border-collapse: collapse;
  }
  /* colgroup辞める */
  .tare-off-water-grid >>> .k-grid col {
    width: auto !important;
  }
  /* =========================
   * セル
   * ========================= */
  .tare-off-water-grid >>> .k-grid th,
  .tare-off-water-grid >>> .k-grid td {
    /* 幅制御 */
    width: 1% !important;
    min-width: 0 !important;
    max-width: 100% !important;
    /* 折り返し */
    white-space: normal !important;
    overflow-wrap: anywhere !important;
    word-break: break-word !important;
    /* 見た目 */
    padding: 2px !important;
    box-sizing: border-box;
  }
  /* ヘッダ */
  .tare-off-water-grid >>> .k-grid th {
    text-align: center;
  }
}
.tare-off-water-grid .segment-button,
.tare-off-water-grid >>> .segment__button,
.tare-off-water-grid >>> .segment__input,
.tare-off-water-grid >>> .deviceSetInfo-header-secound-name,
.tare-off-water-grid >>> .k-widget,
.tare-off-water-grid >>> .deviceSetInfo-header-row-name,
.tare-off-water-grid >>> .deviceSetInfo-row-name,
.tare-off-water-grid >>> .deviceSetInfo-name-content,
.tare-off-water-grid >>> .deviceSetInfo-weight-content {
  font-size: unset;
  border-radius: 0px;
  box-shadow: unset;
}
.tare-off-water-grid >>> .segment__button {
  background-color: #72a8de;
  color: #ffffff;
  border: none;
}
.tare-off-water-grid >>> :checked + .segment__button {
  background-color: var(--btn1-execute-color);
}
.tare-off-water-grid >>> .resize-obs-target::-webkit-scrollbar {
  display: none;
}

.tare-off-water-grid >>> .k-grid-header {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}

</style>
