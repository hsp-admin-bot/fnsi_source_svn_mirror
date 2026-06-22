/**
 * 共通部品 医療材料選択(有効なマスタからの選択).
 * 
 * <p>マスタメンテナンス機能、および患者経過総合ビューア 医療材料編集機能の両方から呼び出される。<br />
 * 呼び出し元により医療材料の内容は出し分けする。<br />
 *
 * マスタメンテナンス: 削除済み・期限切れを除外した医療材料およびダイアライザ(ともに並び順(mst_selector)の考慮あり)<br />
 * 患者経過総合ビューア 医療材料編集機能: 対象患者の禁忌・アレルギー情報を考慮し、削除済み・期限切れを除外した医療材料およびダイアライザ(ともに並び順(mst_selector)の考慮あり)</p>
 * 
 * <p>ただし選択状態の(入力フィールドに表示された)部材がマスタ上で削除済あるいは期限切れの場合はマスタ選択プルダウンのリストに含める必要がある為<br />
 * DBからのマスタの取得基準は 削除済み・期限切れも含めた医療材料およびダイアライザとする</p>
 *
 * <p>マスタ選択プルダウンのリストに削除済・期限切れの部材を含めた場合には部材名に接頭辞(【削除済】、【期限切れ】)を付与する</p>
 * <p>入力フィールドの部材名が削除済、あるいは期限切れの場合は医療材料名に接頭辞(【削除済】、【期限切れ】)を付与する</p>
 *
 * <p>マスタ選択ポップオーバー画面における選択項目一覧、選択項目において医療材料とダイアライザのコード重複を回避するため<br />
 * ダイアライザのコンポーネント内部展開コードはdialyzer{n}とする(例. 10 -> "dialyzer10")。</p>
 *
 */
import { mapMutations, mapGetters } from "@/compat/vue/vuex";

// 治療開始日の設定
import dayjs from "@/compat/date/dayjs";
// 部材(医療材料・ダイアライザ)の医療材料区分 equipType に関する共通関数
import { 
  encryptPersistentCodeToInternalCd, 
  decryptDialyzerCdToPersistentCode, 
  detectEquipTypeFromCode 
} from "@/functions/EquipTypeFunctions";

// 物品系マスタの使用期限の判定
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
// 選択項目の先頭に「すべて」、末尾に「未分類」を追加する.
import { shapeSelectionItem } from "@/functions/for-componet/ListSelector";
// [共通部品] マスタ選択ポップオーバー画面
import MasterSelector from "@/components/common/master-selector/MasterSelector";
// マスタ取得
import { dialyzerIncludeDeleted, equipmentClass, equipmentIncludeDeleted } from "@/functions/mst/MstGetters.js";
// エラー時のログ操作
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
// 定数関連(削除済み、期限切れ)
import { MASTER_DELETE_DISPLAY, MASTER_TERM_CUT } from "@/constants/TreatmentRecord";
// コンポーネント間イベント送信
import { EventBus } from "@/compat/vue/event-bus.js";
//【削除済】、【期限切れ】の部材名をプルダウンのリストに追加する際に利用
import { deepCopy } from "@/functions/common/CommonFunctions";

export default {
  components: {
    "pop-over": MasterSelector,
  },
  props: {
    /**
     * @description 入力フィールドの初期値
     */
    fieldsData: {
      type: Object,
      default: () => ({
        cd: null, // 共通部品の呼び出し元から渡される部材コードはDB永続化用コード(ダイアライザの場合もコードに接頭辞dialyzerが付与されない形式).
      })
    },

    /**
     * @description 「すべて」選択を表示
     */
    showAllSelectTag: {
      type: Boolean,
      default: true
    },
  },

  data() {
    return {
      /**
       * @description 「医療材料分類」マスターデータ
       */
       mstEquipmentClass: [],

      /**
       * @description 「医療材料」マスターデータ
       */
       mstEquipment: [],

      /**
       * @description 「ダイアライザ」マスターデータ
       */
      mstDialyzer: [],

      /** 医療材料とダイアライザの削除・期限切れを含む全てのマスタデータ */
      mstEquipmentDialyzerIncludedDeleted: [],

      /**
       * @description マスタ選択ポップオーバー画面に渡すデータ
       */
      popoverDataValidEquipment: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
      },
    };
  },

  computed: {
    ...mapGetters("pat-viewer", ["getIndEndDate"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),

    /** 
     * マスタレコードの選択状態を監視するフィールド.
     */
    fieldsComputed() {
      // 関連するマスタの取得ができていたらコード情報を持つオブジェクトを返す
      const selected = this.popoverDataValidEquipment.popoverContentSelected;
      if (selected) {
        return {
          // ダイアライザの場合内部展開したコード表現をDB永続化用のコードに戻す
          cd: decryptDialyzerCdToPersistentCode(selected.value)
        };
      }
    },
  },

  watch: {
    fieldsComputed(data) {
      this.$emit("input", data);
    },
    getIndStartDate() {
      this.createPopoverData();
    },
    getIndEndDate() {
      this.createPopoverData();
    },
  },

  /**
   * 初期処理.
   */
  created() {
    // 部材の期限切れ判定のために、治療開始日(=マスタメンテナンス画面を開いている日)をセット
    this.setIndStartDate(dayjs().format("YYYY-MM-DD"));
    // ポップオーバー画面の表示・非表示の初期化
    this.closePopover();
  },

  async mounted() {
    // マスタの取得
    await this.setUpMaster();
  },

  methods: {
    ...mapMutations("pat-viewer-popover", ["setIndStartDate"]),

    // ボタンの状態の変更
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },

    /**
     * マスタの取得.
     * <ol>
     * <li>医療材料分類マスタ
     * <li>削除済み・期限切れも含めた医療材料(並び順(mst_selector)の考慮あり)
     * <li>削除済み・期限切れも含めたダイアライザ(並び順(mst_selector)の考慮あり)
     * </ol>
     */
    async setUpMaster() {
      const [
        mstEquipmentClass, 
        mstEquipment,
        mstDialyzer,
      ] = await Promise.all([
        equipmentClass(this.facilityCd),
        equipmentIncludeDeleted(this.facilityCd),
        dialyzerIncludeDeleted(this.facilityCd),
      ]).catch(error => {
        getErrorMessage("ValidEquipmentSelectMixin.js", "setUpMaster", error);
        throw new Error(error);
      });
      this.mstEquipmentClass = mstEquipmentClass; 
      this.mstEquipment = mstEquipment;
      this.mstDialyzer = mstDialyzer;

      // 選択済み部材への接頭辞付与のために医療材料とダイアライザの削除・期限切れを含む全てのマスタデータを生成する
      this.mstEquipmentDialyzerIncludedDeleted = this.mstEquipment.map(contentMapping);
      this.mstEquipmentDialyzerIncludedDeleted.push(...this.mstDialyzer.map(contentDialyzerMapping));
    },

    /**
     * 選択済マスタレコード(削除済み・期限切れ)の一時退避.
     * <p>選択済マスターレコードが削除済み・期限切れの場合はプルダウンリストに追加するために保持する.</p>
     * @return {Object} 削除済み・期限切れのマスターレコード(有効なマスターレコードの場合はnull).
     */
    saveInvalidMasterRecord() {
      let returnRecord = null;
      // セットへ医療材料を追加する時の考慮(一時退避の必要がない為)
      if (this.popoverDataValidEquipment.popoverContentSelected == undefined) {return returnRecord;}
      // 選択済みの部材が削除済みまたは期限切れの場合に保持する
      returnRecord = this.mstEquipmentDialyzerIncludedDeleted.filter(item => {
        if (item.value == this.popoverDataValidEquipment.popoverContentSelected.value && 
            (item.isDisp == "0" || fitTermCheck(item.useStartDate, item.useEndDate, this.getIndStartDate) == false)) {
          return item;
        }
      });
      // filterにより該当レコードが配列で引き当てられるが仕様的に(医療材料一覧の一行で指定できるのは1部材)のため
      // 配列の先頭の要素を退避する
      return returnRecord.length > 0 ? returnRecord[0] : null;
    },

    /**
     * 共通部品 マスタ選択ポップオーバー用のデータを生成する.
     * プルダウンの一覧の対象は期限切れ・削除済ではない有効な部材および選択済みの部材(無効な部材の場合は接頭辞付き部材名)
     */
    async createPopoverData() {
      const selectedItemRecord = this.saveInvalidMasterRecord();

      // 医療材料分類のフィルタデータを適用
      const filterArr = this.mstEquipmentClass.map(item => ({
        text: item.className,
        value: item.classCd,
      }));
      // ダイアライザを医療材料分類のフィルタデータに追加
      filterArr.push({
        text: "ダイアライザ",
        value: "dialyzer"
      });
      // 既存処理の踏襲
      if (this.showAllSelectTag) {
        // 医療材料分類の選択項目の先頭に「すべて」、末尾に「未分類」を追加する.
        shapeSelectionItem(filterArr);
      }

      // 医療材料データの成形
      const isValidRecord = item => (
        item.isDisp === "1"
        && fitTermCheck(item.useStartDate, item.useEndDate, this.getIndStartDate)
      );
      // 削除済み・期限切れの医療材料を除外
      const mstEquipmentValidRecords = this.mstEquipment.filter(isValidRecord);
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // const contentArr = mstEquipmentValidRecords.map(contentMapping);
      let contentArr = mstEquipmentValidRecords.map(contentMapping);
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // 削除済み・期限切れのダイアライザを除外
      const mstDialyzerValidRecords = this.mstDialyzer.filter(isValidRecord);
      const contentDialyzer = mstDialyzerValidRecords.map(contentDialyzerMapping);

      // 選択済み部材が削除済み・期限切れの場合は接頭辞を付与してマスタ選択プルダウン一覧(医療材料またはダイアライザの)末尾に追加する
      if (selectedItemRecord != null) {
        const addRecord = deepCopy(selectedItemRecord);
        addRecord.text = this.setPrefixToEquipmentName(addRecord, detectEquipTypeFromCode(addRecord.value));
        if (detectEquipTypeFromCode(addRecord.value) === 1) {
          contentDialyzer.push(addRecord);
        } else {
          contentArr.push(addRecord);
        }
      }

      // 医療材料>ダイアライザの順に結合する
      contentArr.push(...contentDialyzer);

      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      contentArr = contentArr.sort(function (a, b) {
        return b.isDisp - a.isDisp;
      });
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      
      // ポップオーバーデータの成形
      this.popoverDataValidEquipment.popoverTitleHeader = "医療材料";
      this.popoverDataValidEquipment.popoverFilter = [
        {
          popoverFilterLabel: "医療材料分類",
          popoverFilterDataset: filterArr,
        },
      ];
      this.popoverDataValidEquipment.popoverContentLabel = "医療材料名";
      this.popoverDataValidEquipment.popoverContentDataset = contentArr;

      // ポップオーバー表示を指示
      this.showPopover();
    },

    /**
     * 初期表示時の材料名をマスタから取得してセット.
     */
    setInitialEquipmentInputValue(cd, equipType) {
      const retVal = { name: "", unit: "" };

      // 材料が未選択の場合はそれぞれのフィールドの初期値とする
      if (cd == null || this.mstEquipmentDialyzerIncludedDeleted == null) return retVal;

      //#8484 医療材料選択IFのリスト不正(#9896対応) Start 
      // TODO:医療材料区分カラムが追加されていない過去の治療方法セットマスタの考慮
      // 医療材料区分カラムがNull又は空白の場合は医療材料とみなす（医療材料区分コード：0にてマスタの存在チェックを行う）
      const chk_equipType = (equipType == null || equipType === "") ? 0 : equipType;

      const selectedRecord = this.mstEquipmentDialyzerIncludedDeleted.find(item => (
        // ダイアライザの場合のcdは内部展開したコードで比較(例. 10 -> "dialyzer10")
        item.value === encryptPersistentCodeToInternalCd(cd, chk_equipType)
      ));
      if (selectedRecord == null) return retVal;

      // 接頭辞(【期限切れ】【削除済】)を考慮した医療材料名をセットする
      return {
        name: this.setPrefixToEquipmentName(selectedRecord, chk_equipType),
        unit: selectedRecord.unit,
      };
      //#8484 医療材料選択IFのリスト不正(#9896対応) End
    },

    /**
     * 材料名に削除・期限切れの接頭辞を付与する.
     * @param {Object} item 医療材料マスタまたはダイアライザマスタのレコード.
     * @param {Number} equipType 医療材料区分(0:医療材料, 1:ダイアライザ).
     * @return {String} 接頭辞を考慮した材料名(例: "【期限切れ】【削除済み】{材料名}")、または接頭辞なしの材料名.
     */
    setPrefixToEquipmentName(item, equipType) {
      if (item == null || equipType == null) return null;
      let equipmentName = item.text;
      // 削除の判定
      if (item.isDisp === "0") {
        equipmentName = MASTER_DELETE_DISPLAY.DELETED + equipmentName;
      }
      // 期限切れの判定
      if (!fitTermCheck(item.useStartDate, item.useEndDate, this.getIndStartDate)) {
        equipmentName = MASTER_TERM_CUT.CUT + equipmentName;
      }
      return equipmentName;
    },

    /**
     * マスター選択ポップオーバー画面を表示.
     */
     showPopover() {
      //#10126:医療材料選択IF追加修正 Start
      this.popoverDataValidEquipment.hasUnregisteredOption = false;
      //#10126:医療材料選択IF追加修正 End
      this.popoverDataValidEquipment.popoverVisible = true;
    },

    /**
     * マスター選択ポップオーバー画面を非表示.
     */
    closePopover() {
      if (this.$el != null) {
        this.popoverDataValidEquipment.popoverVisible = false;
      }
    },
  }
};

// プルダウン用リスト(医療材料)へのマッピング
const contentMapping = item => ({
  value: item.equipmentCd,
  text: item.equipmentName,
  fnValue: { "医療材料分類": item.classCd },
  unit: item.unit,
  isDisp: item.isDisp,
  useStartDate: item.useStartDate,
  useEndDate: item.useEndDate,
});

// プルダウン用リスト(ダイアライザ)へのマッピング
const contentDialyzerMapping = item => ({
  value: encryptPersistentCodeToInternalCd(item.dialyzerCd, 1),
  text: item.modelNumber,
  fnValue: { "医療材料分類": "dialyzer" },
  unit: null,
  isDisp: item.isDisp,
  useStartDate: item.useStartDate,
  useEndDate: item.useEndDate,
});
