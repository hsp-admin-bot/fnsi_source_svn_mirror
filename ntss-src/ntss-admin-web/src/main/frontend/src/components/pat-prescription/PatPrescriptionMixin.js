/**
 * @description 処方セットマスタ詳細・処方画面の処方エリア用のMixin
 */
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "../../apis/AxiosHelper";
import { createUuid } from "@/functions/common/uuid";
import BigNumber from "@/compat/number/bignumber";
import { layoutArea } from "@/constants/layoutArea";
import { sendRequestFindRecordListByFacilityCd } from "@/apis/master-maintenance";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { 
  MEDICINE_TYPE,
  TABOO_CLASS_PREFIX,
  ALLERGY_CLASS_PREFIX,
  TABOO_ALLERGY_CLASS_PREFIX
} from "@/constants/patPrescriptionConstants";

export default {
  data() {
    return {
      colorFlag: false,
      arrFlag: false,
      arr: [],
      maxValueInt: 2147483647,
      dataListDefault: [
        "区切",
        "薬剤",
        "内服",
        "ｺﾒﾝﾄ",
        "区切",
        "薬剤",
        "内服",
        "ｺﾒﾝﾄ",
        "区切",
        "薬剤",
        "内服",
        "ｺﾒﾝﾄ",
        "区切",
        "薬剤",
        "内服",
        "ｺﾒﾝﾄ"
      ],
      listButton: [
        "区切",
        "薬剤",
        "内服",
        "外用",
        "頓服内服",
        "頓服外用",
        "用語・コメント",
        "処方セット"
      ],
      timeList: [
        "日分",
        "回分"
      ],
      rowNameMap: {
        "区切": "区切",
        "薬剤": "薬剤",
        "内服": "内服",
        "外用": "外用",
        "頓服内服": "頓内",
        "頓服外用": "頓外",
        "用語・コメント": "ｺﾒﾝﾄ",
      },      
      layoutArea,
      dataList: [],
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      getAction: [],
      dragOptions: {
        animation: 250,
        ghostClass: "ghost",
        dragClass: "drag",
        forceFallback: true,
        fallbackClass: "layout-item-fallback"
      },
      dataSample: {
        Rp: "",
        type: "",
        unchg: "",
        pat_req: "",
        F1: "",
        F2: "",
        F3: "",
        F4: "",
        F5: "",
        F6: "",
        F7: "",
        medicine_type: "",
        medicine_cd: "",
        R: ""
      },
      listTakeMedicine: [],
      mstMedicine: [],
      sysGenericMedicine: [],
      min: 0,
      max: 0,
      blurFlg: false,
      focusFlg: [],
      index: null,
      idx: null,
      indexOld: null,
      formFlg: true,
      // RP単位ドラッグ中の移動対象のindexリスト
      movingIndexes: [],
      // RP単位ドラッグ前のdataList
      prevDataList: [],
      // 並び替えで動かした行のuniqueIdのリスト
      movedUniqueIds: [],
      
      // 処方セット吹き出し表示データ
      prescriptionSetData: [],
      // 処方セット吹き出し
      popoverDataPrescriptionSet: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      // 処方セット吹き出し表示位置
      popoverPrescriptionTarget: null,
      // 禁忌アレルギー確認ダイアログ表示中かのフラグ
      comfirmShowing: false,
    };
  },
  computed: {
    ...mapGetters("pat-prescription", [
      "getEditRecord",
      "getOriginalEditRecord",
      "getPrescriptionDetail",
    ]),
    /**
     * RP単位のドラッグか否か
     */
    isDraggingRp() {
      return this.movingIndexes.length > 0;
    },
  },

  beforeUnmount() {
    // storeクリア
    this.clearStateEdit();
    this.setPrescriptionDetail([]);
  },
  methods: {
    requestViewForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    getPrescriptionScopeRoot() {
      return this.$el || this.$refs?.prescriptionRoot || document;
    },
    getPrescriptionNumberInputFromWheelEvent(e) {
      const target = e?.target;
      const currentTarget = e?.currentTarget;
      return target?.matches?.("input[type='number']")
        ? target
        : target?.querySelector?.("input[type='number']")
          || currentTarget?.querySelector?.("input[type='number']")
          || target?.closest?.("ons-input")?.querySelector?.("input[type='number']")
          || null;
    },
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    ...mapActions("pat-prescription", [
      "clearStateEdit",
      "setPrescriptionDetail",
      "setEditRecord"
    ]),
    
    /**
     * 薬剤＞調剤指示名プルダウン 選択時処理
     */
    onOpen (index) {
      this.indexOld = index
    },
    // #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 start
    handleMousedown(e) {
      this.$nextTick(() => {
        this.formFlg = true;
        if (!getScopedElementById("myInput", this.getPrescriptionScopeRoot())?.contains(e.target) && (((e.target._prevClass !== 'k-icon down-arrow') && (e.target._prevClass !== 'form-ul')) && (e.target._prevClass !== '')  && this.getEditRecord && this.getEditRecord[this.index] && this.getEditRecord[this.index].buttonItems)) {
          if (this.index && this.idx) {
            this.getEditRecord[this.index].buttonItems[this.idx].showSelectFlag = false;
          }
          this.formFlg = true;
        } else if (e.target._prevClass === 'form-ul') {
          this.formFlg = false;
          this.getEditRecord[this.index].buttonItems[this.idx].showSelectFlag = true;
        }
      });
    },
    // #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 end
    // #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 訾浩 start
    mouseover() {
      this.colorFlag = false;
    },
    inputChange(value, arr) {
      if (value) {
        this.arr = arr.filter(item => item.includes(value));
        this.arrFlag = true;
        this.emptyFlag = this.arr.length == 0 ? true : false;
      } else {
        this.arrFlag = false;
        this.emptyFlag = false;
      }
    },
    async changeListInput(index, i, type) {
      if (type === 'mousedown' && !this.getEditRecord[index].buttonItems[i].showSelectFlag) {
        setTimeout(() => {
          getScopedElementById('input-' + index + '-' + i, this.getPrescriptionScopeRoot())?.focus?.();
        }, 0);
      }
      this.index = index;
      this.idx = i;
      this.colorFlag = true;
      this.arrFlag = false;
      this.emptyFlag = false;
      if (type === 'focus') {
        ((this.getEditRecord[index].buttonItems[i])['showSelectFlag'] = true);
      }
      if (type === 'mousedown' && this.getEditRecord[index].buttonItems[i].showSelectFlag === undefined) {
        ((this.getEditRecord[index].buttonItems[i])['showSelectFlag'] = false);
      }
    },
    listBlur(value, index, i) {
      this.formFlg && ((this.getEditRecord[index].buttonItems[i])['showSelectFlag'] = false);
    },
    // #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 訾浩 end
    /** 薬剤詳細項目行を削除 */
    deleteCols(index) {
      this.dataList.splice(index, 1);
      this.refacterDataList();
    },
    /** 薬剤種別を変えるのためにPopoverを表示する */
    showPopoverToChange(event, name, index) {
      this.popoverTarget = event;
      this.popoverVisible = true;
      this.getAction = [name, index];
    },
    /** 薬剤詳細項目行を追加 */
    showPopoverToAdd(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
      this.getAction = [];
    },
    /** 種別変更/処方セットボタン押下時の処理 */
    onClickButton(item, el, facilityCd) {
      if (item === "処方セット") {
        this.createPopoverDataPrescriptionSet(el, facilityCd)
      } else {
        this.getChangeOrAdd(item)
      }
    },
    /** データ行を種別変更またはデータ行を追加 */
    getChangeOrAdd(rowName) {
      if (this.getAction === undefined || this.getAction.length == 0) {
        this.addNewRow(rowName);
      } else {
        this.changeRow(this.getAction, rowName);
      }
    },
    /** 薬剤詳細行を追加 */
    addNewRow(rowName) {
      rowName = this.rowNameMap[rowName];
      for (let index = 0; index < this.layoutArea.length; index++) {
        if (rowName == this.layoutArea[index].dataButtonName) {
          let newLayout = JSON.parse(JSON.stringify(this.layoutArea[index]));
          newLayout.isNew = true;
          this.dataList.push(newLayout);
          break;
        }
      }
      this.refacterDataList();
      this.popoverVisible = false;
      
      // DOM反映後に一番下へスクロール
      this.$nextTick(() => {
        const el = this.$refs.prescriptionWrapper;
        if (el) {
          el.scrollTop = el.scrollHeight;
        }
      });
    },
    /** 薬剤詳細行を変える */
    changeRow(getAction, rowName) {
      rowName = this.rowNameMap[rowName];
      if (getAction[0] != rowName) {
        for (let index = 0; index < this.layoutArea.length; index++) {
          if (rowName == this.layoutArea[index].dataButtonName) {
            let newLayout = JSON.parse(JSON.stringify(this.layoutArea[index]));
            const uniqueId = this.dataList[getAction[1]].uniqueId;
            // 元のレコードの uniqueId を保持
            newLayout.uniqueId = uniqueId;
            // uniqueId に一致するレコードを取得
            let originalRecord = this.getOriginalEditRecord.find(record => record.uniqueId === uniqueId);
            // dataButtonNo が異なる場合のみ isNew を true にする
            if (!originalRecord || originalRecord.dataButtonNo !== newLayout.dataButtonNo) {
              newLayout.isNew = true;
            }
            this.dataList.splice(getAction[1], 1, newLayout);
            break;
          }
        }
      }
      this.refacterDataList();
      this.popoverVisible = false;
    },
    /** 処方エリア＞リストのindex採番とRP単位でのドラッグに対応 */
    refacterDataList(event) {
      
      if (event?.moved) {
      
        // RP単位でドラッグ
        if (this.isDraggingRp) {
          const { oldIndex, newIndex } = event.moved;
          // ドラッグ前のdataList取得
          const prevDataListCopy = JSON.parse(JSON.stringify(this.prevDataList));
          
          // 移動対象の要素取得
          // ** "区切" の前までの要素取得  dataButtonNo -> constants/layoutArea.js 参照 **
          let endIndex = oldIndex + 1;
          while (endIndex < prevDataListCopy.length && prevDataListCopy[endIndex].dataButtonNo !== 1) {
            endIndex++;
          }
          const moveItems = prevDataListCopy.slice(oldIndex, endIndex);
          // 抜き出した要素のindexを保存
          const moveIndexes = moveItems.map(item => item.index);
          
          // this.dataListからindexが一致する要素を削除
          this.dataList = this.dataList.filter(item => !moveIndexes.includes(item.index));       
          // 移動先に抜き出した要素を挿入
          this.dataList.splice(newIndex, 0, ...moveItems);
          
          // 並び替えで動かした行の uniqueId を this.movedUniqueIds に追加 ※編集前未保存スタイル適用のため
          this.movedUniqueIds.push(...moveItems.map(item => item.uniqueId));          
          
        } else {
          // 行単位でドラッグ
          // 並び替えで動かした行の uniqueId を this.movedUniqueIds に追加 ※編集前未保存スタイル適用のため
          this.movedUniqueIds.push(event.moved.element.uniqueId);
        }
      }
      
      // indexの採番
      let value = 0;
      let index = 0;
      this.dataList.forEach(data => {
        data.index = index++;
        const item = data.buttonItems.find(
            button => button.type === "text-readonly"
        );
        if (item) item.itemValue = "" + ++value;
      });
      
      // this.movedUniqueIdsに格納済のデータで元の位置に戻ったらthis.movedUniqueIdsから削除
      this.movedUniqueIds = this.movedUniqueIds.filter(uniqueId => {
        const dataItem = this.dataList.find(item => item.uniqueId === uniqueId);
        const originalItem = this.getOriginalEditRecord.find(record => record.uniqueId === uniqueId);
        // originalItem が存在し、かつ dataItem の index と一致するなら削除
        return !(originalItem && dataItem && originalItem.index === dataItem.index);
      });
      
      // this.dataListにuniqueId設定
      this.setUniqueId();
      this.setEditRecord(this.dataList);
    },
    /** デフォルトレイアウトをロード */
    getDataList() {
      this.dataList = this.dataListDefault.map(data =>
        JSON.parse(
          JSON.stringify(
              this.layoutArea.find(layout => layout.dataButtonName === data)
          )
        )
      );
      // this.dataListにuniqueId設定
      this.setUniqueId();
    },
    /**
     * 処方セット選択の吹き出しを表示する前に、必要なデータを取得して吹き出しに渡す
     * @param {*} el 吹き出しを表示するtarget
     * @param {String} facilityCd
     * @param {Number} index -1: 上部の処方ｾｯﾄ、n: 行の処方セット、3: 追加の処方セット
     */
    async createPopoverDataPrescriptionSet(el, facilityCd, index) {
      // 区分選択吹き出しを閉じる      
      this.popoverVisible = false;
      
      const response = await sendRequestFindRecordListByFacilityCd(
        "mst_prescription_set",
        facilityCd,
        this.selectedPatId
      );
      this.prescriptionSetData = response.data.localDataSource.data.filter(item => item.isDisp === "1");

      const contentArr = this.prescriptionSetData.map(item => {
        return {
          value: item.code,
          text: item.name
        };
      });

      this.popoverDataPrescriptionSet.popoverTitleHeader = "処方セット";
      this.popoverDataPrescriptionSet.popoverContentLabel = "処方セット名";
      this.popoverDataPrescriptionSet.popoverContentDataset = contentArr;
      this.popoverPrescriptionTarget = el.target ? el.target : el;
      // 押下された処方セットボタンの位置をセット
      if (index === -1) {
        this.getAction = ["処方セット", index];
      }
      
      this.showPopoverPrescriptionSet();
    },
    /**
     * 処方セット選択 吹き出し表示
     */
    showPopoverPrescriptionSet() {
      this.popoverDataPrescriptionSet.popoverVisible = true;
    },
    /**
     * 処方セット選択 吹き出し非表示
     */
    closePopoverPrescriptionSet() {
      // 禁忌アレルギー確認ダイアログ表示時は閉じない
      if (this.comfirmShowing) return;
      
      this.popoverDataPrescriptionSet.popoverVisible = false;
      this.popoverPrescriptionTarget = null;
    },
    /**
     * 吹き出しで選択した処方セットを展開
     */
    async updateInputPrescriptionSet(data, fromPatPrescription, facilityCd) {
      let prescriptionSetJson = [];
      
      if (!fromPatPrescription) {
        // マスタ画面
        const prescriptionSetData = this.prescriptionSetData.find(
          item => item.code === data.value
        );
        if (!prescriptionSetData) return;
        
        prescriptionSetJson = JSON.parse(prescriptionSetData.setInfo);
      
      } else {
        // 処方画面
        prescriptionSetJson = data;
      }

      this.setLoadingScreenVisible(true);
      // 最新マスタ取得
      const [ medicineRes, genericMedicineRes ] = await Promise.all([
        ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", { facilityCd: facilityCd }),
        ApiHelper.get("/mstInfo/sysGenericMedicineIncludeDeleted"),
      ]);
      this.mstMedicine = medicineRes.data;
      this.sysGenericMedicine = genericMedicineRes.data;
      this.setLoadingScreenVisible(false);
      
      const clickedIndex =
        !this.getAction || this.getAction.length === 0 ? null : this.getAction[1];
      
      // 元のリスト退避 
      const saveDataList = JSON.parse(JSON.stringify(this.dataList));
        
      // ========= 上部からの展開 =========
      if (clickedIndex === -1) {
        // 処方画面の場合
        if (fromPatPrescription) {
          // 先頭要素のRpが"0"なら、全要素のRpを+1する
          if (
            Array.isArray(prescriptionSetJson) &&
            prescriptionSetJson.length > 0 &&
            prescriptionSetJson[0].Rp === "0"
          ) {
            prescriptionSetJson.forEach(item => {
              item.Rp = String(Number(item.Rp) + 1);
            });
          }
        }
        
        this.setPrescriptionDetail(prescriptionSetJson);
        this.changeFormatData(0, fromPatPrescription);
            
        if (fromPatPrescription) {
          // Rp先頭なしの場合、退避した先頭レコードに置換
          // dataListが空の場合は先頭に追加
          if (this.dataList[0]) {
            this.dataList[0] = saveDataList[0];
          } else {
            this.dataList.unshift(saveDataList[0]);
          }
        }
        
        // 新規展開データを編集未保存状態にする
        this.dataList.forEach(item => (item.isNew = true));
        this.refacterDataList();
        return;
      }
    
      // ========= 途中 / 余白からの展開 =========
      this.setPrescriptionDetail(prescriptionSetJson);
      this.changeFormatData(0, fromPatPrescription);
    
      this.dataList.forEach(item => (item.isNew = true));
    
      // ===== Rp番号 調整 =====
      if (saveDataList.length && this.dataList.length) {
        const lastRp = Number(saveDataList.at(-1)?.Rp || 0);
        const firstRp = this.dataList[0]?.Rp;
    
        this.dataList.forEach((item, index) => {
          const base =
            firstRp === "1"
              ? Number(item.Rp || 0)
              : index === 0
              ? 0
              : Number(item.Rp || 0);
    
          item.Rp = String(base + lastRp);
        });
      }
    
      // ========= 挿入位置の分岐 =========
      if (clickedIndex !== null) {
        // パターン3,4：途中行の次に挿入
        const insertIndex = clickedIndex + 1;
    
        // 下にずれた要素の uniqueId を退避
        saveDataList.slice(insertIndex).forEach(item => {
          if (!this.movedUniqueIds.includes(item.uniqueId)) {
            this.movedUniqueIds.push(item.uniqueId);
          }
        });
    
        this.dataList = [
          ...saveDataList.slice(0, insertIndex),
          ...this.dataList,
          ...saveDataList.slice(insertIndex)
        ];
      } else {
        // パターン5：末尾に追加
        this.dataList = [
          ...saveDataList,
          ...this.dataList
        ];
      }
    
      this.refacterDataList();
    },
    /** 処方セット情報をJSON形式にする */
    convertData(fromPatPrescription) {
      // mod 10291【たくしん会】処方のコンバートが正しくない 関 start
      // let rp = "Rp1";
      let rp = 0;
      // mod 10291【たくしん会】処方のコンバートが正しくない 関 end
      let prevElement = null; // 前のelementを保持
      let result = [];
      // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng start
      let subNo = 1;
      // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng end
      this.getEditRecord.forEach(element => {
        if (element.dataButtonNo == 1) {
          // 区切が連続している場合はrpの番号が飛ばないよう順に採番する
          if (!prevElement || prevElement.dataButtonNo !== 1) {
            rp += 1;
          }
          prevElement = element; // 現在のelementを次のループのために保存        
          // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng start
          subNo = 1;
          // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng end
          return; // RpはDBに登録しない
        }
        // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng start
        if (element.index != 0 &&
            element.dataButtonNo == 2 &&
            element.dataButtonNo != this.getEditRecord[element.index -1].dataButtonNo &&
            this.getEditRecord[element.index -1].dataButtonNo != 1) {
          subNo += 1;
        }
        // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng end
        let F1 = "",
            F2 = "",
            F3 = "",
            F4 = "",
            F5 = "",
            F6 = "";
        element.buttonItems.forEach(item => {
          switch (item.itemName) {
            case "F1":
              F1 = item.itemValue;
              break;
            case "F2":
              F2 = item.itemValue;
              break;
            case "F3":
              F3 = item.itemValue;
              break;
            case "F4":
              F4 = item.itemValue;
              break;
            case "F5":
              F5 = item.itemValue;
              break;
            case "F6":
              F6 = item.itemValue;
              break;
            default:
              break;
          }
        });
        // mod 処方保存時にDBへのデータ登録処理が正しくない 6579 関 start
        const itemNames = element.buttonItems.map(item => item.itemName);
        const withoutF3F4 = !(["F3", "F4"].some(itemName => itemNames.includes(itemName)));
        if (element.dataButtonNo != 1 && withoutF3F4) {
          // add 6725 処方画面でord_material_saveには正しく登録されない 関 start
          let indReceiptFlg = null;
          if (element.buttonItems[6] && element.buttonItems[6].dataList.unitSecond == element.buttonItems[6].itemValue &&
              element.buttonItems[6].dataList.unitSecond != element.buttonItems[6].dataList.unit) {
            indReceiptFlg = "0";
          }else {
            indReceiptFlg = "1";
          }
          // add 6725 処方画面でord_material_saveには正しく登録されない 関 end
          this.dataSample = {
            Rp: rp.toString(),
            type: element.dataButtonNo - 1,
            unchg: element.buttonItems[0].itemValue == false ? "" : "x",
            pat_req: element.buttonItems[1].itemValue == false ? "" : "x",
            F1,
            F2,
            F3,
            F4,
            F5,
            F6,
            // add 6725 処方画面でord_material_saveには正しく登録されない 関 start
            F7: indReceiptFlg,
            // add 6725 処方画面でord_material_saveには正しく登録されない 関 end
            medicine_type: !element.buttonItems[2]
                ? ""
                : element.buttonItems[2].itemValueType,
            medicine_cd: !element.buttonItems[2]
                ? ""
                : element.buttonItems[2].itemValueCd,
            medicine_unit1:
                !element.buttonItems[6] ||
                !element.buttonItems[6].dataList ||
                !element.buttonItems[6].dataList.unit
                    ? ""
                    : element.buttonItems[6].dataList.unit,
            medicine_unit2:
                !element.buttonItems[6] ||
                !element.buttonItems[6].dataList ||
                !element.buttonItems[6].dataList.unitSecond
                    ? ""
                    : element.buttonItems[6].dataList.unitSecond,
            // R: F1 + F2 + F3 + F4
            // 処方の項目が足りない  6346  shan  start
            R: F1 + " " + F2,
            // 処方の項目が足りない  6346  shan  end
            // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng start
            sub_no: subNo.toString()
            // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng end
          };
          result.push(this.dataSample);
        }else {
          this.dataSample = {
            Rp: rp,
            type: element.dataButtonNo - 1,
            unchg: element.buttonItems[0].itemValue == false ? "" : "x",
            pat_req: element.buttonItems[1].itemValue == false ? "" : "x",
            F1,
            F2,
            F3,
            F4,
            F5,
            F6,
            medicine_type: !element.buttonItems[2]
                ? ""
                : element.buttonItems[2].itemValueType,
            medicine_cd: !element.buttonItems[2]
                ? ""
                : element.buttonItems[2].itemValueCd,
            medicine_unit1:
                !element.buttonItems[6] ||
                !element.buttonItems[6].dataList ||
                !element.buttonItems[6].dataList.unit
                    ? ""
                    : element.buttonItems[6].dataList.unit,
            medicine_unit2:
                !element.buttonItems[6] ||
                !element.buttonItems[6].dataList ||
                !element.buttonItems[6].dataList.unitSecond
                    ? ""
                    : element.buttonItems[6].dataList.unitSecond,
            // R: F1 + F2 + F3 + F4
            // 処方の項目が足りない  6346  shan  start
            R: F1 + " " + F2 + " " + F3 + " " + F4,
            // 処方の項目が足りない  6346  shan  end
            // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng start
            sub_no: subNo.toString()
            // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng end
          };
          result.push(this.dataSample);
        }
        // mod 処方保存時にDBへのデータ登録処理が正しくない 6579 関 end
        
        prevElement = element; // 現在のelementを次のループのために保存
      });
      if (fromPatPrescription) {
        let endLine = {
          Rp: "",
          type: "E",
          unchg: "",
          pat_req: "",
          F1: "",
          F2: "",
          F3: "",
          F4: "",
          F5: "",
          F6: "",
          medicine_type: "",
          medicine_cd: "",
          R: "────────以下、余白─────────",
          // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng start
          sub_no: ""
          // add #11557 RP内に服用・コメントが複数存在した場合の仕様調整 linjunfeng end
        };
        result.push(endLine);
      }
      return result;
    },
    /** 処方詳細を取得 */
    listDetailMedicine(listClass) {
      let list;
      for (let index = 0; index < this.listTakeMedicine.length; index++) {
        const element = this.listTakeMedicine[index];
        if (element.listClass == listClass) {
          //mod 10291 【たくしん会】処方のコンバートが正しくない shiyw start
          //list = element.listDetails.split(",");
          list = element.listDetails.split("\r\n");
          //mod 10291 【たくしん会】処方のコンバートが正しくない shiyw end
          break;
        }
      }
      return list;
    },

    /** 指示単位小数部:step制御用パラメータ */
    unitStep(unitDecimalPoint) {
      let num = parseInt(unitDecimalPoint);
      if (isNaN(num)) {
        num = 0;
      }
      let data = BigNumber(10)
          .exponentiatedBy(BigNumber(num).negated())
          .valueOf();
      return data;
    },

    /** セット情報のフォーマットを画面表示用に変換 */
    changeFormatData(minusValue = 1, fromPatPrescription) {
      // mod 10291【たくしん会】処方のコンバートが正しくない 関 start
      // let Rp = "Rp1";
      let Rp = "0";
      // mod 10291【たくしん会】処方のコンバートが正しくない 関 end
      let listDetail = [];
      let newLayout = JSON.parse(JSON.stringify(this.layoutArea));
      for (
          let index = 0;
          index < this.getPrescriptionDetail.length - minusValue;
          index++
      ) {
        const element = this.getPrescriptionDetail[index];
        if (element.Rp != Rp) {
          Rp = element.Rp;
          listDetail.push(JSON.parse(JSON.stringify(newLayout[0])));
        }
        switch (element.type) {
          case 1: {
            // マスタ編集＞処方セット詳細表示、処方セット展開時
            // 薬剤マスタ・一般名処方マスタの名称、単位、数量補正は最新のマスタを参照
            if (!fromPatPrescription || minusValue === 0) {
              this.updateMedicineElement(element);
            }
            
            newLayout[1].buttonItems[0].itemValue =
                element.unchg == "x" ? true : false;
            newLayout[1].buttonItems[1].itemValue = element.pat_req == "x" ? true : false;
            const deleteLabel = this.appendDeleteString(element.medicine_cd, element.medicine_type);
            newLayout[1].buttonItems[2].itemValue =
              deleteLabel && !element.F1.startsWith(deleteLabel)
                ? deleteLabel + (element.F1 ?? "")
                : element.F1; // 薬剤名or一般処方の標準的な記載
            newLayout[1].buttonItems[4].itemValue = element.F2;
            newLayout[1].buttonItems[5].itemValue = element.F5; // 数量
            newLayout[1].buttonItems[6].itemValue = element.F6; // 単位
            newLayout[1].buttonItems[2].itemValueType = element.medicine_type;
            newLayout[1].buttonItems[2].itemValueCd = element.medicine_cd;  // 薬剤コードor一般名コード
            newLayout[1].buttonItems[6].dataList = {
              unit: element.medicine_unit1,
              unitSecond: element.medicine_unit2
            };  // 単位プルダウンリスト
            if (element.F5.toString().split(".")[1]) {
              newLayout[1].buttonItems[5].unitDecimalPoint = element.F5.toString().split(
                  "."
              )[1].length;
            }
            listDetail.push(JSON.parse(JSON.stringify(newLayout[1])));
            break;
          }
          case 2:
            newLayout[2].buttonItems[2].itemValue = element.F1;
            newLayout[2].buttonItems[3].itemValue = element.F2;
            newLayout[2].buttonItems[4].itemValue = element.F5;
            newLayout[2].buttonItems[5].itemValue = element.F6;
            listDetail.push(JSON.parse(JSON.stringify(newLayout[2])));
            break;
          case 3:
            newLayout[3].buttonItems[2].itemValue = element.F1;
            newLayout[3].buttonItems[3].itemValue = element.F2;
            newLayout[3].buttonItems[4].itemValue = element.F3;
            newLayout[3].buttonItems[5].itemValue = element.F4;
            newLayout[3].buttonItems[6].itemValue = element.F5;
            newLayout[3].buttonItems[7].itemValue = element.F6;
            listDetail.push(JSON.parse(JSON.stringify(newLayout[3])));
            break;
          case 4:
            newLayout[4].buttonItems[2].itemValue = element.F1;
            newLayout[4].buttonItems[3].itemValue = element.F2;
            newLayout[4].buttonItems[4].itemValue = element.F5;
            newLayout[4].buttonItems[5].itemValue = element.F6;
            listDetail.push(JSON.parse(JSON.stringify(newLayout[4])));
            break;
          case 5:
            newLayout[5].buttonItems[2].itemValue = element.F1;
            newLayout[5].buttonItems[3].itemValue = element.F2;
            newLayout[5].buttonItems[4].itemValue = element.F3;
            newLayout[5].buttonItems[5].itemValue = element.F4;
            newLayout[5].buttonItems[6].itemValue = element.F5;
            newLayout[5].buttonItems[7].itemValue = element.F6;
            listDetail.push(JSON.parse(JSON.stringify(newLayout[5])));
            break;
          case 6:
            newLayout[6].buttonItems[2].itemValue = element.F1;
            listDetail.push(JSON.parse(JSON.stringify(newLayout[6])));
            break;
          default:
            break;
        }
      }
      if (fromPatPrescription) {
        // 処方画面 初期表示時 type: "E"のみの場合は先頭に区切を追加
        if (listDetail.length === 0 && this.getPrescriptionDetail.length > 0) {
          listDetail.push(JSON.parse(JSON.stringify(newLayout[0])));
        }
      }
      this.dataList = listDetail;
      // this.dataListにuniqueId設定 
      this.setUniqueId();
      this.setEditRecord(this.dataList);
    },
    /** 薬剤行を最新のマスタ情報に更新 */
    updateMedicineElement (element) {
      let mst;
      let decimal;
      
      // 禁忌アレルギーの接頭辞取得
      const tabooAllergyPrefix =
        [TABOO_CLASS_PREFIX, ALLERGY_CLASS_PREFIX, TABOO_ALLERGY_CLASS_PREFIX]
          .find(prefix => element.F1.includes(prefix)) || ""; 
      
      if (element.medicine_type === MEDICINE_TYPE.MEDICINE) {
        // 薬剤マスタ
        mst = this.mstMedicine.find(item =>
          item.medicineCd === Number(element.medicine_cd)
        );
        if (!mst) return;
      
        decimal = mst.unitDecimalPoint;
      
        element.F1 = `${tabooAllergyPrefix}${mst.medicineName}`;
        element.medicine_unit1 = mst.unit;
        element.medicine_unit2 = mst.unitSecond;
      
      } else {
        // 一般名処方マスタ
        mst = this.sysGenericMedicine.find(item =>
          item.genericCd === element.medicine_cd
        );
        if (!mst) return;
      
        element.F1 = `${tabooAllergyPrefix}${mst.genericName}`;
        element.medicine_unit1 = mst.unitFirst;
        element.medicine_unit2 = mst.unitSecond;
      
        // 一般名処方は薬剤マスタから桁数取得
        let searchCodeList = mst.searchCodeList ? JSON.parse(mst.searchCodeList) : [];        
        const medicine = this.mstMedicine.find(m =>
          searchCodeList.some(code =>
            m.standardMedicineCd?.substring(0, 9) === code.cd
          )
        );
        decimal = medicine?.unitDecimalPoint;
      }
      
      // 数量補正（共通処理）
      element.F5 = this.adjustDecimal(element.F5, decimal);
    },
    /** 小数部桁数補正 */
    adjustDecimal(num, decimal) {
      if (decimal == null) return num;
    
      let decStep = BigNumber(10).exponentiatedBy(BigNumber(decimal)).valueOf();
      let setStep = BigNumber(10).exponentiatedBy(BigNumber(decimal).negated()).valueOf();
    
      num = BigNumber(num).multipliedBy(BigNumber(decStep)).valueOf();
      num = num >= 0 ? Math.floor(num) : Math.ceil(num);
    
      const returnVal = BigNumber(num).multipliedBy(BigNumber(setStep)).valueOf();
    
      return BigNumber(returnVal).toFixed(decimal);
    },
    getPrescriptionNumberMax(decimal) {
      const parsedDecimal = Number(decimal);
      if (!Number.isFinite(parsedDecimal) || parsedDecimal <= 0) {
        return 999999;
      }
      return Number(`999999.${"9".repeat(Math.min(parsedDecimal, 9))}`);
    },
    normalizePrescriptionNumberValue(value, decimal) {
      let normalized = Number(value);
      if (!Number.isFinite(normalized)) {
        normalized = 0;
      }
      if (normalized > this.maxValueInt) {
        normalized = this.maxValueInt;
      }
      normalized = this.adjustDecimal(normalized, decimal);
      if (decimal == 0 || decimal == undefined) {
        normalized = parseInt(normalized);
      }
      normalized = Number(normalized);
      return Number.isFinite(normalized) ? normalized : 0;
    },
    applyPrescriptionNumberValue(index, i, value, decimal, eventTarget = null) {
      const min = Number(this.min ?? 0);
      const max = this.getPrescriptionNumberMax(decimal);
      let nextValue = this.normalizePrescriptionNumberValue(value, decimal);
      this.max = max;
      if (nextValue > max) {
        nextValue = min;
        this.blurFlg = true;
      } else if (nextValue < min) {
        nextValue = max;
        this.blurFlg = true;
      } else {
        this.blurFlg = false;
      }
      this.dataList[index].buttonItems[i].itemValue = nextValue;
      if (eventTarget) {
        eventTarget.value = nextValue;
      }
      return nextValue;
    },
    /** 小数点桁を変える */
    changeValuePoint(decimal, index, i, e){
      const input = e?.target;
      this.applyPrescriptionNumberValue(index, i, input?.value, decimal, input);
      this.setEditRecord(this.dataList);
    },
    stopScrollFun(index, i, e){
      const now = e?.timeStamp || Date.now();
      const wheelKey = `${index}-${i}`;
      if (!this.__prescriptionNumberWheelGuard) {
        this.__prescriptionNumberWheelGuard = {};
      }
      const lastWheel = this.__prescriptionNumberWheelGuard[wheelKey];
      if (lastWheel && now - lastWheel.time < 20 && lastWheel.type !== e?.type) {
        return;
      }
      this.__prescriptionNumberWheelGuard[wheelKey] = {
        time: now,
        type: e?.type
      };
      const input = this.getPrescriptionNumberInputFromWheelEvent(e);
      if (!input || input.disabled) {
        return;
      }
      if (input.ownerDocument?.activeElement !== input) {
        return;
      }
      e?.preventDefault?.();
      e?.stopPropagation?.();
      this.focusFlg[i] = true;
      let delta = 0;
      if (typeof e.deltaY === "number" && e.deltaY !== 0) {
        delta = e.deltaY < 0 ? 1 : -1;
      } else {
        delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
            (e.detail && (e.detail < 0 ? 1 : -1));
      }
      if (!input.value) {
        input.value = 0
      }
      let value = parseFloat(input.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 上スクロール
        value += parameterStep
      } else {
        // 下スクロール
        value -= parameterStep
      }
      const decimal = this.dataList?.[index]?.buttonItems?.[i]?.unitDecimalPoint;
      this.applyPrescriptionNumberValue(index, i, value, decimal, input);
      this.requestViewForceUpdate();
    },
    formatValue(index, i, event){
      // 限界値判定
      let value = event.target.value;
      if (value == this.max && this.blurFlg) {
        this.dataList[index].buttonItems[i].itemValue = this.min;
        this.blurFlg = false;
      }else if (value == this.min && this.blurFlg) {
        this.dataList[index].buttonItems[i].itemValue = this.max;
        this.blurFlg = false;
      }
      this.focusFlg[i]=false;
    },
    handleFocus(i){
      this.focusFlg[i]=true;
    },
    // mod #5589 2023/04/12 数値IFのスタイル全不正 張博 end
    /**
     * number-input クラスが付いた入力欄に対して、
     * 数字・カンマ・ドット以外のキー入力をブロックする。
     */
    blockUnecessaryDigit() {
      let x = getScopedElementsByClassName("number-input", this.getPrescriptionScopeRoot())
      for (let i = 0; i < x.length; i++) {
        x[i].addEventListener("keypress", (evt) => {
          if (evt.which != 8 && evt.which != 44 && evt.which != 46  && evt.which < 48 || evt.which > 57)
          {
            evt.preventDefault();
          }
        });
      }
    },
    /** 薬剤名の頭に【削除済み】付与 */
    appendDeleteString(cd, medicineType){
      let isDeleted = false;
      
      if (medicineType == MEDICINE_TYPE.MEDICINE) {
        // 薬剤マスタ
        isDeleted = this.mstMedicine.some(item => 
          item.isDisp === "0" && item.medicineCd === Number(cd)
        );
      } else {
        // 一般名処方マスタ
        isDeleted = this.sysGenericMedicine.some(item => 
          item.isDisp === "0" && item.genericCd === cd
        );
      }
      
      return isDeleted ? MASTER_DELETE_DISPLAY.DELETED : "";
    },
    getUnit(item){
      let unitList = [];
      if(item !== null && item !== undefined){
        if (item.unit == item.unitSecond) {
          unitList.push(item.unit);
        }else {
          unitList.push(item.unit);
          unitList.push(item.unitSecond);
        }
      }
      return unitList;
    },
    /**
     * ドラッグ開始時の処理
     */
    onDragStart(event) {
      // ドラッグ中の要素取得
      const draggedFrom = event.originalEvent.target;
      const dragRpHandle = draggedFrom?.closest?.(".dragg-rp");
      // RP単位のドラッグ時
      if (dragRpHandle || draggedFrom.classList.contains("dragg-rp")) {
        // ドラッグ中の要素とそれに続く dataButtonNo !== 1（次の区切まで）のindexのリスト取得
        this.movingIndexes = this.getMovedRows(event.oldIndex);  
      }
      // ドラッグ前のdataListを保存
      this.prevDataList = JSON.parse(JSON.stringify(this.dataList));
    },
    /**
     * ドラッグ終了時の処理
     */
    onDragEnd() {
      // 値リセット
      this.movingIndexes = [];
      this.prevDataList = [];
      
      const scopeRoot = this.getPrescriptionScopeRoot();
      const ownerDocument = scopeRoot?.ownerDocument || document;
      const clearDragInlineStyle = (el) => {
        if (!el?.style) {
          return;
        }
        el.style.opacity = "";
        el.style.transform = "";
        el.style.transition = "";
        el.style.height = "";
      };

      // onMove() や Sortable fallback で付与された style のみクリア（列幅の style は触らない）
      queryScopedSelectorAll(
        ".draggable-area .sortable-chosen, .draggable-area .sortable-related, .draggable-area .ghost, .layout-item-fallback",
        scopeRoot
      ).forEach(clearDragInlineStyle);
      ownerDocument.querySelectorAll(".layout-item-fallback").forEach(el => el.remove());
    },
    /**
     * ドラッグでの移動時の処理
     */
    onMove(event) {
      
      // RP単位のドラッグの場合は対象行を移動した状態で表示
      if (this.isDraggingRp) {
        // DOM操作でリストの並び替え処理が途中でレンダリングされ一瞬sortable-relatedの要素が消えたり、
        // 並び順がおかしくなったりするのを防ぐためブラウザの次の描画のタイミングで処理する
        this.$nextTick(() => {
          // 対象行を全て取得（ドラッグ中の要素は含まない）
          const relatedRows = Array.from(queryScopedSelectorAll(".sortable-related.ghost", this.getPrescriptionScopeRoot()));
          // ドラッグ中の要素を取得
          const chosenRow = queryScopedSelector(".sortable-chosen.ghost", this.getPrescriptionScopeRoot());
          
          if (!chosenRow || relatedRows.length === 0) return;
          
          // **下方向にドラッグ中にchosenRowがちらつくのを防ぐ**
          chosenRow.style.opacity = "0"; // 一時的に透明にする
          chosenRow.style.transition = "opacity 0.1s";
          
          // **移動後のnextRowを再取得**
          let nextRow = chosenRow.nextElementSibling;
          // nextRow が sortable-related または drag の場合は次の有効な行を探す
          while (nextRow && (nextRow.classList.contains("sortable-related") || nextRow.classList.contains("drag"))) {
            nextRow = nextRow.nextElementSibling;
          }
          
          // **リストが適切に更新されるまで待つ**
          this.$nextTick(() => {
            chosenRow.style.opacity = "0.5"; // 可視化（ghostと同じスタイル適用）
          });
          
          // 移動対象行をドラッグ中の要素の後に挿入
          // **移動先の行の取得がNGだった場合、drag行の前に挿入**
          if (!nextRow) {
            nextRow = queryScopedSelector(".drag", this.getPrescriptionScopeRoot());
          }
          const fragment = (this.getPrescriptionScopeRoot()?.ownerDocument || document).createDocumentFragment();
          relatedRows.forEach(row => fragment.appendChild(row));
          if (nextRow) {
            nextRow.parentNode.insertBefore(fragment, nextRow);
          } else {
            chosenRow.parentNode.appendChild(fragment);
          } 
        });
        
        // RP単位のドラッグは移動制限なし
        return true;
      }
      
      // 行単位のドラッグ newIndex が 0（最上行への移動）禁止
      return event.relatedContext.index !== 0;
    },
    /**
     * ドラッグ中の要素とそれに続く dataButtonNo !== 1 （次の区切まで）のindexのリスト取得
     * @param {number} startIndex RP単位ドラッグ中の要素位置
     */
    getMovedRows(startIndex) {
      const movedIndexList = [startIndex];
      let i = startIndex + 1;
      while (i < this.dataList.length && this.dataList[i].dataButtonNo !== 1) {
        movedIndexList.push(i);
        i++;
      }
      return movedIndexList;
    },
    /**
     * RP単位でドラッグ中のRP行かを判定
     * @param {number} index 画面表示中のdataListの位置
     */
    isDraggItem(index) {
      return this.movingIndexes.length > 0 && this.movingIndexes[0] === index;
    },
    /**
     * RP単位でドラッグ中の関連行かを判定
     * @param {number} index 画面表示中のdataListの位置
     */
    isGhost(index) {
      return this.movingIndexes.includes(index);
    },
    /**
     * dataListに一意となるuniqueIdを設定
     * - ドラッグ行の:keyに設定
     * - :keyに一意となる値を設定しない状態でドラッグするとリストの並び順がおかしくなる
     */
    setUniqueId() {
      this.dataList.forEach(item => {
        if (!item.uniqueId) {
          item.uniqueId = createUuid();
        }
      });
    },
    /**
     * 並び替えした行かを判定
     * @param {String} uniqueId 行に割り振られたユニークid
     */
    isMoved(uniqueId) {
      return this.movedUniqueIds.includes(uniqueId);
    },
  },
};
