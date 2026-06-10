/**
 * 共通部品 医療材料選択(指示有効なマスタからの選択).
 * 
 * <p>治療対象患者の禁忌・アレルギーへの考慮がなされた医療材料(ダイアライザ含む)の一覧生成.
 * <p>選択プルダウンのリスト対象: 削除済み・期限切れを除外した医療材料およびダイアライザ(ともに並び順(mst_selector)の考慮あり)</p>
 * <p>ただし選択状態の(入力フィールドに表示された)医療材料がマスタ上で削除済あるいは期限切れの場合はマスタ選択プルダウンのリストに含める必要がある為<br />
 * DBからのマスタの取得基準は 削除済み・期限切れも含めた医療材料およびダイアライザとする</p>
 * <p>マスタ選択プルダウンのリストに削除済・期限切れの部材を含めた場合には部材名に接頭辞(【削除済】、【期限切れ】)を付与する</p>
 * <p>入力フィールドの医療材料名が削除済、あるいは期限切れの場合は医療材料名に接頭辞(【削除済】、【期限切れ】)を付与する</p>
 *
 *
 * <p>マスタ選択ポップオーバー画面における選択項目一覧、選択項目において医療材料とダイアライザのコード重複を回避するため<br />
 * ダイアライザのコンポーネント内部展開コードはdialyzer{n}とする(例. 10 -> "dialyzer10")。</p>
 *
 */
import { mapMutations, mapGetters } from "vuex";

// 治療開始日の設定
import moment from "moment";
// 部材(医療材料・ダイアライザ)の医療材料区分 equipType に関する共通関数
import { 
  encryptPersistentCodeToInternalCd, 
  decryptDialyzerCdToPersistentCode, 
  detectEquipTypeFromCode 
} from "@/functions/EquipTypeFunctions";

// 指示有効な医療材料の取得
import { ApiHelper } from "@/apis/AxiosHelper";

// 物品系マスタの使用期限の判定
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
// 選択項目の先頭に「すべて」、末尾に「未分類」を追加する.
import { shapeSelectionItem } from "@/functions/for-componet/ListSelector";
// [共通部品] マスタ選択ポップオーバー画面
import MasterSelector from "@/components/common/master-selector/MasterSelector";
// マスタ取得
import { dialyzerTabooAllergyDeleted, equipmentAllergy, equipmentClass } from "@/functions/mst/MstGetters.js";
// エラー時のログ操作
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
// 定数関連(削除済み、期限切れ)
// コンポーネント間イベント送信
import {EventBus} from "@/eventBus";
//【削除済】、【期限切れ】の部材名をプルダウンのリストに追加する際に利用
import { deepCopy } from "@/functions/common/CommonFunctions";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { getPrefix } from "@/functions/common/CommonFunctions";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

export default {
  components: {
    "pop-over": MasterSelector,
  },
  props: {
    /**
     * 医療材料のデフォルトデータ
     */
    fieldsData: {
      type: Object,
      default: () => ({
        cd: null,
        amount: 0,
        unit: null,
        equipType: 0
      })
    },

    /**
     * @description 「すべて」選択を表示
     */
    showAllSelectTag: {
      type: Boolean,
      default: false
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

      /**
       * 指示有効な医療材料
       */
      validIndEquipments: [],

      /** 医療材料とダイアライザの削除・期限切れを含む全てのマスタデータ */
      mstEquipmentDialyzerIncludedDeleted: [],

      /**
       * @description マスタ選択ポップオーバー画面に渡すデータ
       */
      popoverDataValidIndEquipment: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      currentOrdMainData: {},
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("pat-viewer", {getIndEndDate: "getIndEndDate"}),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),

    //変更対象の条件(期間、曜日、治療方法、クールなどの条件)を保持する親コンポーネント.
    // IndEditBase.vue～IndEquipmentSelect.vue間でDOM要素の入れ子の数に変更があった場合に見直すこと。
    indEditBaseComponent() {
      return this.$parent.$parent.$parent.$parent;
    },
    structData() {
      // 編集対象の条件が変更されたタイミングで部材のプルダウンの内容およぴテキストフィールドをリフレッシュするための監視.
      // TODO: return this.indEditBaseComponent.structData;として$parent地獄から抜け出したいが有効とならなかったので見送った
      return this.$parent.$parent.$parent.$parent.structData;
    },
  },

  watch: {
    /**
     * IndEditBase.vueで管理する編集対象となる治療の条件(structData).
     */
    structData: {
      handler(newObject, oldObject) {
        this.getValidIndEquipments();
      },
      deep: true
    },
  },

  /**
   * 初期処理.
   */
  created(){
    // 医療材料分類リストに「すべて」を含める
    this.showAllSelectTag = true;
  },

  async mounted() {
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    if (this.settingIndData.ordNo) {
      this.currentOrdMainData = await ApiHelper.get(`/mainData/getOrdMainByOrdNo/${this.settingIndData.ordNo}`)
    }
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    await this.setUpMaster();
    
    // 初期表示時の材料名をマスタから取得してセット
    if (this.popoverDataValidIndEquipment.popoverContentSelected) {
      this.$nextTick(() => {
        this.equipmentInputValue.editValue = this.setInitialEquipmentInputValue(this.fieldsData.cd, this.fieldsData.equipType);
        this.equipmentInputValue.initValue = this.equipmentInputValue.editValue;
      });
    }
  },

  methods: {
    ...mapMutations("pat-viewer-popover", [
      "setIndStartDate"
    ]),

    // ボタンの状態の変更
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },

    /**
     * 指示有効の物品のみリストの取得.
     */
    async getValidIndEquipments() {      
      // 取得条件の整形
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = this.facilityCd;
      // 患者情報
      paramJson.pat_id = this.selectedPatId;
      // 治療開始日
      paramJson.start_date = this.shapeDateFormat(this.indEditBaseComponent.structData.indStartDate);
      // 治療終了日
      paramJson.end_date = !this.indEditBaseComponent.structData.indEndDate ? "" : this.shapeDateFormat(this.indEditBaseComponent.structData.indEndDate);
      // クール
      paramJson.ind_kur_cd = JSON.stringify(this.indEditBaseComponent.structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(this.indEditBaseComponent.structData.selectedTreat);
      
      // 曜日パターン
      let _weeks = [];
      this.indEditBaseComponent.structData.indWeeks.forEach((elem) => {
        _weeks.push(elem);
      });
      paramJson.weeks = JSON.stringify(_weeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/validIndEquipmentsList",
        paramJson
      ).catch(error => {
        getErrorMessage('IndEquipmentEditBase.vue', 'getValidIndEquipments', error);
        throw error;
      });
      this.validIndEquipments = response.data;
      //ポップオーバーの内容の生成
      this.createPopoverData();
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
        mstDialyzer
      ] = await Promise.all([
        equipmentClass(this.facilityCd),
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // equipmentTabooAllergyIncludeDeleted(this.selectedPatId), // 削除・期限切れ・禁忌・アレルギー含めた医療材料
        // dialyzerTabooAllergyIncludeDeleted(this.selectedPatId) // 削除・期限切れ・禁忌・アレルギー含めたダイアライザ
        equipmentAllergy(this.selectedPatId, true), // 削除・期限切れ・禁忌・アレルギー含めた医療材料
        dialyzerTabooAllergyDeleted(this.selectedPatId)
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      ]).catch(error => {
        getErrorMessage('ValidIndEquipmentSelectMixin.js', 'setUpMaster', error);
        throw new Error(error);
      });
      this.mstEquipmentClass = mstEquipmentClass; 
      this.mstEquipment = mstEquipment;
      this.mstDialyzer = mstDialyzer;

      //プルダウン用リスト(医療材料)へのマッピング
      const contentMapping = item => {
        return {
          value: item.equipmentCd,
          text: item.equipmentName,
          fnValue: {
            医療材料分類: item.classCd
          },
          unit: item.unit,
          isDisp: item.isDisp,
          useStartDate: item.useStartDate,
          useEndDate: item.useEndDate,
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          isTaboo: item.isTaboo,
          isAllergy: item.isAllergy,
          treatDate: this.indEditBaseComponent.structData.indStartDate,
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        };
      };

      // プルダウン用リスト(ダイアライザ)へのマッピング
      const contentDialyzerMapping = item => {
        return {
          value: encryptPersistentCodeToInternalCd(item.dialyzerCd, 1),
          text: item.modelNumber,
          fnValue: {
            医療材料分類: "dialyzer"
          },
          unit: null,
          isDisp: item.isDisp,
          useStartDate: item.useStartDate,
          useEndDate: item.useEndDate,
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          isTaboo: item.isTaboo,
          isAllergy: item.isAllergy,
          treatDate: this.indEditBaseComponent.structData.indStartDate,
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        };
      };

      // 選択済み部材への接頭辞付与のために医療材料とダイアライザの削除・期限切れを含む全てのマスタデータを生成する
      this.mstEquipmentDialyzerIncludedDeleted = this.mstEquipment.map(contentMapping);
      this.mstEquipmentDialyzerIncludedDeleted.push(...this.mstDialyzer.map(contentDialyzerMapping));
  
      let selectedEquipmentCd = this.fieldsData.cd;
      let selectedEuipmentEquipType = this.fieldsData.equipType;
      if(this.selectedEquipment.cd) {
        selectedEquipmentCd = this.selectedEquipment.cd;
        selectedEuipmentEquipType = this.selectedEquipment.equipType;
      }

      // 選択済医療材料の保持
      this.popoverDataValidIndEquipment.popoverContentSelected = this.mstEquipmentDialyzerIncludedDeleted.find(
        // ダイアライザの場合のcdは内部展開したコードで比較(例. 10 -> "dialyzer10")
        equipment => equipment.value == encryptPersistentCodeToInternalCd(selectedEquipmentCd, selectedEuipmentEquipType)
      );
    },

    /**
     * 選択済マスタレコード(削除済み・期限切れ)の一時退避.
     * <p>選択済マスターレコードが削除済み・期限切れの場合はプルダウンリストに追加するために保持する.</p>
     * @return {Object} 削除済み・期限切れのマスターレコード(有効なマスターレコードの場合はnull).
     */
     saveInvalidMasterRecord() {
      let returnRecord = null;
      // セットへ医療材料を追加する時の考慮(一時退避の必要がない為)
      if (this.popoverDataValidIndEquipment.popoverContentSelected == undefined) {return returnRecord;}
      // 選択済みの部材が削除済みまたは期限切れの場合に保持する
      returnRecord = this.mstEquipmentDialyzerIncludedDeleted.filter(item => {
        if (item.value == this.popoverDataValidIndEquipment.popoverContentSelected.value && 
            (item.isDisp == "0" || fitTermCheck(item.useStartDate, item.useEndDate, this.indEditBaseComponent.structData.indStartDate) == false)) {
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
      // 選択済マスタレコード(削除済み・期限切れ)の一時退避.
      const selectedItemRecord = this.saveInvalidMasterRecord();
      // 医療材料分類のフィルタデータを適用
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };
      const filterArr = this.mstEquipmentClass.map(filterMapping);
      // 医療材料データの成形
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let rstName = "";
      if (
        this.currentOrdMainData && 
        this.currentOrdMainData.data && 
        this.currentOrdMainData.data.rstDialysisState != 0
      ) {
        const rstEquipInfo = this.currentOrdMainData.data.indEquipInfo;
        const rstEquipInfoArr = rstEquipInfo ? JSON.parse(rstEquipInfo) : [];
        const rstEquipInfoArrInfo = rstEquipInfoArr.find(item => item.cd == this.fieldsData.cd);
        rstName = rstEquipInfoArrInfo && rstEquipInfoArrInfo.name ? rstEquipInfoArrInfo.name : "";
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      const contentMapping = item => {
        return {
          value: item.equipmentCd,
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item.equipmentName,
          text: rstName && item.equipmentCd == this.fieldsData.cd ? rstName : getPrefix(item) + item.equipmentName,
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          fnValue: {
            医療材料分類: item.classCd
          },
          unit: item.unit,
          isDisp: item.isDisp,
          useStartDate: item.useStartDate,
          useEndDate: item.useEndDate
        };
      };

      // 削除済み・期限切れの医療材料を除外
      let mstEquipmentValidRecords = this.mstEquipment.filter((item)=>{
        if ( item.isDisp === "1" && fitTermCheck(item.useStartDate, item.useEndDate, this.indEditBaseComponent.structData.indStartDate)) {
          return item;
        }
      });
      let contentArr = mstEquipmentValidRecords.map(contentMapping);

      // 削除済み・期限切れのダイアライザを除外
      let mstDialyzerValidRecords = this.mstDialyzer.filter(item => {
        if ( item.isDisp === "1" && fitTermCheck(item.useStartDate, item.useEndDate, this.indEditBaseComponent.structData.indStartDate)) {
          return item;
        }
      });

      // ダイアライザを医療材料分類のフィルタデータに追加
      filterArr.push({
        text: "ダイアライザ",
        value: "dialyzer"
      });
      // プルダウン用リスト(ダイアライザ)へのマッピング
      const contentDialyzerMapping = item => {
        return {
          value: encryptPersistentCodeToInternalCd(item.dialyzerCd, 1),
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item.modelNumber,
          text: rstName && item.equipmentCd == this.fieldsData.cd ? rstName : getPrefix(item) + item.modelNumber,
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          fnValue: {
            医療材料分類: "dialyzer"
          },
          unit: null,
          isDisp: item.isDisp,
          useStartDate: item.useStartDate,
          useEndDate: item.useEndDate
        };
      };
      let contentDialyzer = mstDialyzerValidRecords.map(contentDialyzerMapping);
      // 医療材料区分別の医療材料リストの生成.
      let validIndContentsArr = [];
      let validIndcontentDialyzer = [];
      if(this.validIndEquipments) {
        validIndContentsArr = this.buildValidIndEquipList(this.validIndEquipments, contentArr, 0);
        validIndcontentDialyzer = this.buildValidIndEquipList(this.validIndEquipments, contentDialyzer, 1);
      }

      // 選択済み部材が削除済み・期限切れの場合は接頭辞を付与してマスタ選択プルダウン一覧(医療材料またはダイアライザの)末尾に追加する
      if(selectedItemRecord) {
        let addRecord = deepCopy(selectedItemRecord);
        addRecord.text = this.setPrefixToEquipmentName(addRecord);
        this.equipmentInputValue.editValue = addRecord.text;
        if (detectEquipTypeFromCode(addRecord.value) == 1) {
          validIndcontentDialyzer.push(addRecord);
        } else {
          validIndContentsArr.push(addRecord);
        }
      }
      // 医療材料>ダイアライザの順に結合する
      validIndContentsArr.push(...validIndcontentDialyzer);
      // 既存処理の踏襲
      if (this.showAllSelectTag) {
        // 医療材料分類の選択項目の先頭に「すべて」、末尾に「未分類」を追加する.
        shapeSelectionItem(filterArr);
      }

      // ポップオーバーデータの成形
      this.popoverDataValidIndEquipment.popoverTitleHeader = "医療材料";
      this.popoverDataValidIndEquipment.popoverFilter = [
        {
          popoverFilterLabel: "医療材料分類",
          popoverFilterDataset: filterArr
        }
      ];
      this.popoverDataValidIndEquipment.popoverContentLabel = "医療材料名";
      this.popoverDataValidIndEquipment.popoverContentDataset = validIndContentsArr;
      //#10126:医療材料選択IF追加修正 Start
      this.popoverDataValidIndEquipment.hasUnregisteredOption = false;
      //#10126:医療材料選択IF追加修正 End
    },

    /**
     * 医療材料区分別の医療材料リストの生成.
     * @param {*} cds 医療材料毎の医療材料コードリスト.
     * @param {*} master 医療材料コードで引き当てるマスタ.
     * @param {*} equipType 医療材料区分.
     * @returns プルダウン用の医療材料の配列.
     */
    buildValidIndEquipList(cds, master, equipType) {
      let equipList = [];
      if (cds[equipType]) {
        let validIndEquipment = [];
        cds[equipType].forEach(function(cd){
          let _validIndEquipment = master.find(masterRecord => masterRecord.value === encryptPersistentCodeToInternalCd(cd, equipType));
          if (_validIndEquipment) {
            validIndEquipment.push(_validIndEquipment);
          }
        });
        equipList = validIndEquipment;
      }
      return equipList;
     },

    /**
     * 初期表示時の材料名をマスタから取得してセット.
     */
    setInitialEquipmentInputValue(cd, equipType) {
      if (!cd) {return null;}
      const selectedItem = this.mstEquipmentDialyzerIncludedDeleted.find(
        // ダイアライザの場合のcdは内部展開したコードで比較(例. 10 -> "dialyzer10")
        equipment => equipment.value == encryptPersistentCodeToInternalCd(cd, equipType)
      );
      if (selectedItem) {
        const equipmentName = this.setPrefixToEquipmentName(selectedItem);
        return equipmentName;
      }
    },

    /**
     * 材料名に削除・期限切れの接頭辞を付与する.
     * @param {Object} item 医療材料マスタまたはダイアライザマスタのレコード.
     * @return {String} 接頭辞を考慮した材料名(例: "【期限切れ】【削除済み】{材料名}")、または接頭辞なしの材料名.
     */
    setPrefixToEquipmentName(item) {
      if (item == undefined) {return null;}
      // 接頭辞の二重のセット防止のために接頭辞なしの部材名を取得する
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // let equipmentName = this.getUnmarkedEquipmentName(item);
      // // 削除の判定
      // equipmentName = item.isDisp === "0" ? MASTER_DELETE_DISPLAY.DELETED + equipmentName : equipmentName;

      // // 期限切れの判定
      // // 編集期間 開始日
      // let start_date = this.indEditBaseComponent.structData.indStartDate;
      // // 編集期間 終了日
      // let end_date = !this.indEditBaseComponent.structData.indEndDate ? this.indEditBaseComponent.maxDate : this.indEditBaseComponent.structData.indEndDate;

      // // 基準日 < 編集期間 開始日の場合は編集期間 開始日を基準日とする
      // let indStartDate = this.shapeDateFormat(this.indEditBaseComponent.structData.indStartDate).toString();
      // // 最大日
      // let maxDate = this.shapeDateFormat(this.indEditBaseComponent.maxDate);
      // // 最小日(Dateオブジェクトで表現可能な協定世界時(UTC)の1970年1月1日+1日(前日を求めるケースがあるため)を仮に設定
      // let minDate = moment("19700102").format("YYYYMMDD");

      // if (fitTermCheck(item.useStartDate, item.useEndDate, indStartDate) == false) {
      //     // 部材の使用終了日がnullの場合は日付の大小比較のために最大日を設定する
      //     let useEndDate = item.useEndDate ? item.useEndDate : maxDate;
      //     // 部材の使用開始日がnullの場合は日付の大小比較のために最小日を設定する
      //     let useStartDate = item.useStartDate ? item.useStartDate : minDate;

      //     // ➀編集期間内に部材の使用開始日・使用終了日が含まれる場合
      //     if (
      //       this.shapeDateFormat(start_date) <= useStartDate && 
      //       this.shapeDateFormat(start_date) <= useEndDate && 
      //       this.shapeDateFormat(end_date) >= useStartDate &&
      //       this.shapeDateFormat(end_date) >= useEndDate 
      //     ) {
      //       equipmentName = MASTER_TERM_CUT.CUT_PART +` ${this.formatTreatDate(this.shapeDateFormat(start_date))}～${this.formatTreatDate(useStartDate, -1)}】` + equipmentName;
      //     }

      //     // ➁編集期間内に部材の使用開始日が始まる場合
      //     else if (this.shapeDateFormat(start_date) <= useStartDate && this.shapeDateFormat(end_date) >= useStartDate) {
      //       equipmentName = MASTER_TERM_CUT.CUT_PART +` ${this.formatTreatDate(this.shapeDateFormat(start_date))}～${this.formatTreatDate(useStartDate, -1)}】` + equipmentName;
      //     }
      //     // ➂編集期間より以前に使用終了日を迎えている場合
      //     else if (useEndDate < this.shapeDateFormat(start_date)) {
      //       equipmentName = MASTER_TERM_CUT.CUT + equipmentName;
      //     }
      //     // ➃編集期間以降に使用開始日・使用終了日が存在する
      //     else if (this.shapeDateFormat(start_date) < useStartDate && 
      //              this.shapeDateFormat(start_date) < useEndDate &&
      //              this.shapeDateFormat(end_date) < useStartDate && 
      //              this.shapeDateFormat(end_date) < useEndDate 
      //              ) {
      //               equipmentName = MASTER_TERM_CUT.CUT_PART +` ${this.formatTreatDate(this.shapeDateFormat(start_date))}～${this.formatTreatDate(useStartDate, -1)}】` + equipmentName;
      //     }

      //     try {
      //       if (equipmentName.indexOf(MASTER_TERM_CUT.CUT_PART) === -1) {
      //         throw new Error("接頭辞のセット漏れが発生しました");
      //       }
      //     } catch(error) {
      //       getErrorMessage('ValidIndEquipmentSelectMixin.js', 'setPrefixToEquipmentName', error);
      //       throw new Error(error);
      //     };
      // }
      let rstName = "";
      if (
        this.currentOrdMainData && 
        this.currentOrdMainData.data && 
        this.currentOrdMainData.data.rstDialysisState != 0
      ) {
        const rstEquipInfo = this.currentOrdMainData.data.indEquipInfo;
        const rstEquipInfoArr = rstEquipInfo ? JSON.parse(rstEquipInfo) : [];
        const rstEquipInfoArrInfo = rstEquipInfoArr.find(item => item.cd == this.fieldsData.cd);
        rstName = rstEquipInfoArrInfo && rstEquipInfoArrInfo.name ? rstEquipInfoArrInfo.name : "";
      }
      let equipmentName = rstName && item.equipmentCd == this.fieldsData.cd ? rstName : getPrefix(item) + item.text;
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      return equipmentName;
    },

    /**
     * 接頭辞なしの部材名の取得.
     * @param {*} item 取得したい医療材料(またはダイアライザ)
     * @returns 接頭辞のついていない医療材料名.
     */
    getUnmarkedEquipmentName(item){
      let selectedEquipment = this.mstEquipmentDialyzerIncludedDeleted.find(
        equipment => equipment.value == item.value
      );
      return selectedEquipment.text;
    },

    /**
     * 日付の整形.
     * TODO: 共通部品に移設
     * @param {String} date "yyyy-mm-dd"形式の日付.
     * @return {String} "yyyy-mm-dd"形式の日付.
     */
    shapeDateFormat(date) {
      if (date == null) return null;
      return Number(date.replaceAll("-", ""));
    },

    /**
     * 日付のフォーマット整形.
     * <p>MM/DD形式に整形する。オプションで前日を求める</p>
     * @param {*} yyyymmdd 対象日付.
     * @param {*} adjust 前日(-1指定)、翌日など日付の計算を行う場合に指定する.
     * @returns 
     */
    formatTreatDate(yyyymmdd, adjust = 0) {
      if (adjust == 0) {
        return moment(yyyymmdd.toString()).format('MM/DD');
      } else {
        return moment(yyyymmdd.toString()).add(adjust, 'd').format('MM/DD');
      }
    },

    /**
     * マスター選択ポップオーバー画面を表示.
     */
     showPopover() {
      this.popoverDataValidIndEquipment.popoverVisible = true;
    },

    /**
     * マスター選択ポップオーバー画面を非表示.
     */
    closePopover() {
      if (this.$el != null) {
        this.popoverDataValidIndEquipment.popoverVisible = false;
      }
    },
  }
};
