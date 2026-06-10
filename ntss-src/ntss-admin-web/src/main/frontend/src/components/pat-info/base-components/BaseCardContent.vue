<script>
import { mapMutations, mapGetters } from "vuex";
import { has, isArray } from "underscore";
import vuedraggable from "vuedraggable";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { deepCopy, mstCdToName, mstCdToNameFreeWord, mstCdToNameIncludeDeleted } from "@/functions/common/CommonFunctions";
import {
  deepCopy,
  mstCdToName,
  // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
  mstCdToCountryName,
  // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
  mstCdToNameFreeWord,
  mstCdToNameIncludeDeleted,
  mstCdToNameIncludeExpiredAndDeleted
} from "@/functions/common/CommonFunctions";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
import { encodeEditableRecord } from "@/functions/PatInfoFunctions";
import {
  createPopoverData,
  createPopoverDataFacility,
  showPopover,
  closePopover
} from "@/functions/PopoverFunctions";
import formValidators from "@/components/pat-info/base-components/FormValidators.vue";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customInputDate from "@/components/common/custom-form-tags/CustomInputDate";
import customInputTime from "@/components/common/custom-form-tags/CustomInputTime";
import customRadio from "@/components/common/custom-form-tags/CustomRadio";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox";
import customSelect from "@/components/common/custom-form-tags/CustomSelect";
import customInputCalender from "@/components/common/custom-form-tags/CustomInputCalender.vue";
import customTextareaWithFixedPhrase from "@/components/common/custom-form-tags/CustomTextareaWithFixedPhrase";
import CustomSimpleTextareaTypeA from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeA";
import masterSelector from "@/components/common/master-selector/MasterSelector";
import DiseaMasterSelector from "@/components/common/master-selector/DiseaMasterSelector";
import masterSelectorFacility from "@/components/common/master-selector/MasterSelectorFacility";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import CommonTextArea from "@/components/common/CommonTextArea";
import isEqualWith from "lodash/isEqualWith";
import orderBy from "lodash/orderBy";
import { customComparatorForType } from "@/utils/util.js"

// import { EventBus } from "@/eventBus.js";

export default {
  // 共通タグコンポーネント読み込み]

  components: {
    draggable: vuedraggable,
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-input-date": customInputDate,
    "custom-input-time": customInputTime,
    "custom-radio": customRadio,
    "custom-checkbox": customCheckbox,
    "custom-select": customSelect,
    "custom-textarea": customTextareaWithFixedPhrase,
    "custom-simple-textarea-a": CustomSimpleTextareaTypeA,
    "custom-input-calender": customInputCalender,
    "pop-over": masterSelector,
    "pop-over-disea": DiseaMasterSelector,
    "pop-over-facility": masterSelectorFacility,
    "message-dialog": messageDialog,
    "com-textarea": CommonTextArea
  },
  mixins: [formValidators],

  props: {
    // 患者情報画面から受け取る患者情報レコード
    patRecord: {
      required: true
    }
  },

  computed: {
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
  },
  data() {
    return {
    // 編集する患者情報レコード
      editRecord: null,
      // 並び替えモードフラグ
      actionMode: false,

      // キーごとに編集値を管理する配列
      dummyArray: [],
      // jsonの要素が欠落していた場合に詰め込むオブジェクト
      dummyObj: {},
      initRecord: null,
      initedFlg: false,
      switchingSelectedPatFlg: false
    };
  },

  watch: {
    patRecord: {
      handler(val) {
        this.editRecord = null;
        this.initRecord = null;
        if (!val) return;
        // add 11518 入外区分がnullになる zkm start
        let inOutInitValue = val?.["in_out_class"]?.initValue
        if (val["in_out_class"] && (inOutInitValue === "" || inOutInitValue == null)) {
          val["in_out_class"].initValue = 3;
          val["in_out_class"].editValue = 3;
        }
        // add 11518 入外区分がnullになる zkm end
        // this.editRecord = deepCopy(val);
        // const currentComponent = this.$options.name;
        // if (!["DifficultySeverityTransportCard", "AdditionSettingCard", "VisitHstCard",
        //  "ChargeStaffCard", "OtherContactCard", "MedicalHstCard", "TabooAllergyCard",
        //   "PhysicalInfoCard", "InfectionCard"].includes(currentComponent)) {
        //   this.initRecord = deepCopy(val);
        // }
        const normalize = (record) => {
          if (!Array.isArray(record.pat_additions)) {
            record.pat_additions = [];
          }
          return record;
        };
        const newRecord = normalize(deepCopy(val));
        this.editRecord = newRecord;
        this.initRecord = deepCopy(newRecord);
      },
      immediate: true
    },
    editRecord: {
      handler(record) {
        this.$nextTick(() => {
          if(this.switchingSelectedPatFlg){
            this.initRecord = deepCopy(this.editRecord);
          }
          let isEqual = true;
          if (!this.initRecord || !record || this.$options.name === 'PhysicalInfoCard') return;
          if (this.$options.name === 'AdditionSettingCard') {
            isEqual = !record['addition_info'].some((item) => {
              return Object.values(item).some((i) => {
                // return i.editValue !== i.initValue;
                return JSON.stringify(i.editValue) !== JSON.stringify(i.initValue);
              })
            })
          } else {
            // 性別に合うようにpat_sex，文字列と数値
            if (this.$options.name === 'PatGroupCard') {
              const pat_group_list = record['pat_group_list']?.map((item) => {
                return item.patGroupCd?.editValue;
              })?.sort();
              const init_pat_group_list = this.initRecord['pat_group_list']?.map((item) => {
                return item.patGroupCd?.editValue;
              })?.sort();
              isEqual = isEqualWith(pat_group_list, init_pat_group_list, customComparatorForType);
            }
	    // mod #12462 患者情報共有 Ji start
            // else if (this.$options.name === 'VisitHstCard') {
            //   const visitCur = orderBy(deepCopy(record["in_out_visit_history_info"]), item => Number(item.ctl_no.initValue), ['asc']);
            //   const visitIni = orderBy(deepCopy(this.initRecord["in_out_visit_history_info"]), item => Number(item.ctl_no.initValue), ['asc']);
            //   isEqual = isEqualWith(visitCur, visitIni, customComparatorForType);
            // } 
            else if (this.$options.name === 'VisitHstCard') {
              const normalize = (arr = []) => {
                return orderBy(
                  arr
                    .map(({ in_out_check, from_facility_name, ...rest }) => rest)
                    .filter(item => item?.facility_cd?.initValue === this.getFacilityCd),
                  item => Number(item?.ctl_no?.initValue || 0),
                  ['asc']
                );
              };
              const visitCur = normalize(deepCopy(record["in_out_visit_history_info"]));
              const visitIni = normalize(deepCopy(this.initRecord["in_out_visit_history_info"]));
              isEqual = isEqualWith(visitCur, visitIni, customComparatorForType);
            }
            else if (this.$options.name === 'MedicalHstCard') {
              const bloodChanged = record.is_blood_suger_exam?.editValue !== this.initRecord.is_blood_suger_exam?.editValue;
              const diabetesChanged = record.is_diabetes?.editValue !== this.initRecord.is_diabetes?.editValue;
              if (bloodChanged || diabetesChanged) {
                isEqual = false;
              } else {
                const medicalHstCur = record['medical_hst_info'].filter(item => {
                  return item?.facility_cd?.initValue === this.getFacilityCd;
                });
                const medicalHstIni = this.initRecord['medical_hst_info'].filter(item => {
                  return item?.facility_cd?.initValue === this.getFacilityCd;
                });
                const hasPrimaryDiseaseCd = medicalHstIni.some(
                  item => "primary_disease_cd" in item
                );
                if (!hasPrimaryDiseaseCd) {
                  medicalHstCur.forEach(item => {
                    const val = item.primary_disease_cd;
                    if (
                      val &&
                      val.initValue === null &&
                      val.editValue === null
                    ) {
                      delete item.primary_disease_cd;
                    }
                  });
                }
                isEqual = isEqualWith(
                  medicalHstCur,
                  medicalHstIni,
                  customComparatorForType
                );
              }
            } else if (this.$options.name === 'DifficultySeverityTransportCard') {
              const DifficultySeverityTransportCur = {
                ...record,
                dial_diff_com_info: record.dial_diff_com_info.map(
                  ({ fn_dial_diff_cd, dialysis_difficulty_name, ...rest }) => rest
                )
              };
              const DifficultySeverityTransportIni = {
                ...this.initRecord,
                dial_diff_com_info: this.initRecord.dial_diff_com_info.map(
                  ({ fn_dial_diff_cd, dialysis_difficulty_name, ...rest }) => rest
                )
              };
              isEqual = isEqualWith(
                DifficultySeverityTransportCur,
                DifficultySeverityTransportIni,
                customComparatorForType
              );
	    // mod #12462 患者情報共有 Ji end
            } else {
              isEqual = isEqualWith(record, this.initRecord, customComparatorForType);
            }
          }
          if (!isEqual) {
            this.setEditedComponent(this.$options.name);
          } else {
            this.removeEditedComponent(this.$options.name);
          }
        })
      },
      deep: true
    },
  },

  methods: {
    ...mapMutations("pat-info", ["setEditedComponent", "removeEditedComponent"]),
    // マスタコード ⇒ 名称変換関数
    mstCdToName,
    // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
    mstCdToCountryName,
    // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
    mstCdToNameFreeWord,
    mstCdToNameIncludeDeleted,
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    mstCdToNameIncludeExpiredAndDeleted,
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    // マスタ選択ポップオーバー表示用オブジェクト作成関数
    createPopoverData,
    // マスタ選択ポップオーバー表示用オブジェクト作成関数
    createPopoverDataFacility,
    // マスタ選択ポップオーバー表示用関数
    showPopover,
    // マスタ選択ポップオーバークローズ用関数
    closePopover,

    /**
     * 患者情報レコードデータ取得
     *   hopePatId等の単一カラム取得用
     * @param {string} columnName 患者情報レコードカラム名
     * @return {object} 患者情報レコードデータ { initValue: 初期値, editValue 編集中の値 }
     */
    getPatData(columnName) {
      if (!has(this.editRecord, columnName)) {
        throw new Error(
          `患者情報レコードにカラム[${columnName}]は存在しません。`
        );
      }
      return this.editRecord?.[columnName];
    },
    /**
     * 患者情報レコードデータ編集
     *   hopePatId等の単一カラム編集用
     *   ※共通タグからではなくカードコンテンツ側から直接編集したいとき用
     * @param {string} columnName 患者情報レコードカラム名
     * @param value 値
     */
    setPatData(columnName, value) {
      if (!has(this.editRecord, columnName)) {
        throw new Error(
          `患者情報レコードにカラム[${columnName}]は存在しません。`
        );
      }

      this.editRecord[columnName].editValue = value;
    },

    /**
     * 患者情報レコードデータ取得
     *   patContactInfo等のJSONカラム取得用
     * @param {string} columnName 患者情報レコードカラム名
     * @param {string} jsonKey JSONキー名
     * @return {object} 患者情報レコードデータ { initValue: 初期値, editValue 編集中の値 }
     */
    getPatDataJson(columnName, jsonKey) {
      // mod FNSI-Check Data change 関 start
      // if (!has(this.editRecord, columnName)) {
      //   throw new Error(
      //     `患者情報レコードにカラム[${columnName}]は存在しません。`
      //   );
      // }
      // if (!has(this.editRecord[columnName], jsonKey)) {
      //   throw new Error(
      //     `患者情報レコードのJSONカラム[${columnName}]にキー[${jsonKey}]は存在しません。`
      //   );
      // }
      this.editRecord = this.editRecord ?? {};
      if (!has(this.editRecord, columnName)) {
        this.editRecord[columnName] = [];
      }
      if (!has(this.editRecord[columnName], jsonKey)) {
        this.editRecord[columnName][jsonKey] = "";
      }
      // mod FNSI-Check Data change 関 end

      return this.editRecord?.[columnName][jsonKey];
    },

    // add FNSI-患者通算透析回数 じょはく start
    getPatDataJsonWithoutThrow(columnName, jsonKey) {
      if (!has(this.editRecord, columnName)) {
        this.editRecord[columnName] = [];
      }
      if (!has(this.editRecord[columnName], jsonKey)) {
        this.editRecord[columnName][jsonKey] = 0;
      }

      return this.editRecord?.[columnName][jsonKey];
    },
    // add FNSI-患者通算透析回数 じょはく end

    // add FNSI-患者通算透析回数 じょはく start
    getPatCreateDataJson(columnName, jsonKey) {
      if (!has(this.editRecord, columnName)) {
        return false;
      }
      if (!has(this.editRecord[columnName], jsonKey)) {
        return false;
      }
      return this.editRecord?.[columnName][jsonKey];
    },
    // add FNSI-患者通算透析回数 じょはく end
    /**
     * 患者情報レコードデータ編集
     *   patContactInfo等の単一JSONカラム編集用
     *   ※共通タグからではなくカードコンテンツ側から直接編集したいとき用
     * @param {string} columnName 患者情報レコードカラム名
     * @param {string} jsonKey JSONキー名
     * @param value 値
     */
    setPatDataJson(columnName, jsonKey, value) {
      // mod FNSI-Check Data change 関 start
      // if (!has(this.editRecord, columnName)) {
      //   throw new Error(
      //     `患者情報レコードにカラム[${columnName}]は存在しません。`
      //   );
      // }
      // if (!has(this.editRecord[columnName], jsonKey)) {
      //   throw new Error(
      //     `患者情報レコードのJSONカラム[${columnName}]にキー[${jsonKey}]は存在しません。`
      //   );
      // }
      if (!has(this.editRecord, columnName)) {
        this.editRecord[columnName] = [];
      }
      if (!has(this.editRecord[columnName], jsonKey)) {
        this.editRecord[columnName][jsonKey] = new Object;
      }
      // mod FNSI-Check Data change 関 end
      this.editRecord[columnName][jsonKey].editValue = value;
    },
    // add FNSI-患者通算透析回数 じょはく start
    setPatDataJsonWithoutThrow(columnName, jsonKey, value) {
      if (!has(this.editRecord, columnName)) {
        this.editRecord[columnName] = [];
      }
      if (!has(this.editRecord[columnName], jsonKey)) {
        this.editRecord[columnName][jsonKey] = new Object;
      }

      this.editRecord[columnName][jsonKey].editValue = value;
    },

    // add FNSI-患者通算透析回数 じょはく end
    /**
     * 患者情報レコードデータ取得
     *   otherContactInfo等のJSON配列の値取得用
     * @param {object} json JSON配列要素
     * @param {string} jsonKey JSONキー名
     * @return {object} 患者情報レコードデータ { initValue: 初期値, editValue 編集中の値 }
     */
    getPatDataJsonArray(json, jsonKey) {
      if (!has(json, jsonKey)) {
        // キーごとにダミーのオブジェクト詰め込み
        this.dummyArray[jsonKey] = this.$set(this.dummyObj, jsonKey, {
          initValue: null,
          editValue: null
        });
        json[jsonKey] = this.dummyArray[jsonKey];
      }
      return json[jsonKey];
    },
    /**
     * 患者情報レコードデータ編集
     *   otherContactInfo等のJSON配列の値編集用
     *   ※共通タグからではなくカードコンテンツ側から直接編集したいとき用
     * @param {object} json JSON配列要素
     * @param {string} jsonKey JSONキー名
     * @param value 値
     */
    setPatDataJsonArray(json, jsonKey, value) {
      if (!has(json, jsonKey)) {
        // キーごとにダミーのオブジェクト詰め込み
        this.dummyArray[jsonKey] = this.$set(this.dummyObj, jsonKey, {
          initValue: null,
          editValue: null
        });
        json[jsonKey] = this.dummyArray[jsonKey];
      }
      json[jsonKey].editValue = value;
    },

    getJsonArrayCtlNo(json) {
      return this.getPatDataJsonArray(json, "ctl_no").editValue;
    },

    /**
     * JSON配列カラムの項目追加処理
     * @param {object} newItem 追加項目({ ctl_no: 0, key: value, ... })
     */
    pushJsonArray(columnName, newItem) {
      // 編集用データに変換して追加
      // add #10305 患者共通ヘッダーで編集＞保存をするとコンソールエラーが出力される yangqingzhe start
      if (!this.editRecord?.[columnName]) return
      // add #10305 患者共通ヘッダーで編集＞保存をするとコンソールエラーが出力される yangqingzhe end
      this.editRecord[columnName].push(encodeEditableRecord(newItem));
    },

    /**
     * JSON配列カラムの項目削除処理
     * @param {object} json JSON配列要素の削除対象項目
     * @param {number} index 要素番号
     */
    deleteJsonArray(columnName, json, index) {
      // 削除対象項目のctl_noを取得
      const ctlNo = this.getJsonArrayCtlNo(json);
      if (ctlNo > 0) {
        // 既存項目はctl_noを負数にして論理削除
        this.setPatDataJsonArray(json, "ctl_no", ctlNo * -1);
      } else if (ctlNo === 0) {
        // 新規追加項目は物理削除
        this.editRecord[columnName].splice(index, 1);
      }
      // 削除後に編集モード解除
      this.actionMode = false;
    },

    isDeletedJsonArrayItem(json) {
      return this.getJsonArrayCtlNo(json) < 0;
    },

    classObjectItem(json) {
      return {
        "deleted-item": this.isDeletedJsonArrayItem(json)
      };
    },

    /**
     * @description 編集フラグ
     * @param { Object } editRecord 編集後レコード
     * @param { Object } patRecord 編集前レコード
     * @summary true:編集済み, false：未編集
     */
    isEdited(editRecord, patRecord) {
      const editColumnList = editRecord;
      if (typeof editColumnList !== "object" || Array.isArray(editColumnList)) {
        // objectでないなら判定をしない
        return false;
      }

      const keys = Object.keys(editColumnList);

      // 編集有無を設定
      for (const key of keys) {
        if (isArray(editColumnList[key])) {
          // カラムが配列型なら
          if (this.isEditedArrayColumn(editColumnList[key], key, patRecord)) {
            // 編集済みなら
            return true;
          }
        } else {
          if (this.isEditedObjectColumn(editColumnList[key])) {
            // 編集済みなら
            return true;
          }
        }
      }
      return false;
    },

    /**
     * @description object型編集前後値判定
     * @param { Object } editColumn 編集後カラム
     * @summary true:編集済み, false：未編集
     */
    isEditedObjectColumn(editColumn) {
      if (has(editColumn, "editValue")) {
        // 階層がない場合
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
        if (editColumn.initValue === null && editColumn.editValue === "") {
          editColumn.editValue = null
        }
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
        return editColumn.initValue !== editColumn.editValue;
      } else {
        // さらに階層がある場合
        const columnList = Object.keys(editColumn);
        return columnList.find(key => {
          if (has(editColumn[key], "editValue")) {
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
            if (editColumn[key].initValue === null && editColumn[key].editValue === "") {
              editColumn[key].editValue = null
            }
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
            return editColumn[key].initValue !== editColumn[key].editValue;
          }
        });
      }
    },

    /**
     * @description array型編集前後値判定
     * @param { Array } editColumn 編集後カラム
     * @param { String } key カラムキー
     * @param { Object } patRecord 編集前レコード
     * @summary true:編集済み, false：未編集
     */
    isEditedArrayColumn(editColumn, key, patRecord) {
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
      // const initColumn = patRecord[key];
      // const isDialDiffInfo = key === "dial_diff_com_info";
      // const isInfectInfo = key === "infect_info";

      // if (isDialDiffInfo || isInfectInfo) {
        // 必ず配列要素数に相違がある特殊カードの場合(初期値がマスタデータを取得する)
        // 配列要素数を未チェック
        // mod 患者情報保存できないを修正する。 dengshen end
        // } else if (editColumn.length !== initColumn.length) {
      // } else if ((!!initColumn) && editColumn.length !== initColumn.length) {
        // mod 患者情報保存できないを修正する。 dengshen end
        // 配列要素数が違う場合
        // true:編集済み, false：未編集
        // return true;
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end

      return editColumn.some((json, index) => {
        const jsonKeys = Object.keys(editColumn[index]);

        const editJson = jsonKeys.find(key => {
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
          if (json[key].initValue === null && json[key].editValue === "") {
            json[key].editValue = null
          }
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
          return json[key].initValue !== json[key].editValue;
        });
        if (editJson !== undefined) {
          // 編集済みの場合
          return true;
        }
      });
    }
  },
  beforeDestroy () {
    this.editRecord = null;
    this.initRecord = null;
  }
};
</script>
