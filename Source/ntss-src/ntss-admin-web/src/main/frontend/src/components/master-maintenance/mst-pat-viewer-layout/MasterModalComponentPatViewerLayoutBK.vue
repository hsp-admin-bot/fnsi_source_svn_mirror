<template>
  <div class="main-area">
    <table class="disp-item-area">
      <tr>
        <td class="layout-name-area" height="30">
          レイアウト名
        </td>
        <td>
          <input
            :value="editRecord.name"
            class="k-textbox"
            @blur="setLayoutName($event.target.value)"
          />
        </td>
      </tr>

      <tr>
        <td class="disp-period" height="30">
          <label>表示期間</label>
        </td>
        <td>
          <v-ons-radio
            v-model="selectedPeriod"
            :input-id="'rdoPeriod0'"
            :value="'0'"
            modifier="material"
            @change="setDispPeriod($event.target.value)"
          />
          <label :for="'rdoPeriod0'" class="rdo-period">3日・7日・14日</label>
          <v-ons-radio
            v-model="selectedPeriod"
            :input-id="'rdoPeriod1'"
            :value="'1'"
            modifier="material"
            @change="setDispPeriod($event.target.value)"
          />
          <label :for="'rdoPeriod1'">12週・6ヶ月・1年・3年</label>
        </td>
      </tr>

      <tr>
        <td class="disp-item-name-area">
          表示項目
        </td>
        <td>
          <div class="disp-item-content-area">
            <draggable>
              <draggable
                v-model="dispItemInfo"
                :options="{ ...dragOptions, handle: '.category-handle' }"
                @choose="isDraggingCategory = true"
                @end="isDraggingCategory = false"
              >
                <v-ons-row
                  v-for="category in dispItemInfo"
                  :key="category.categoryNo"
                  :class="{ 'layout-item-dragging': isDraggingCategory }"
                  class="layout-item"
                  @mouseup="isDraggingCategory = false"
                  @touchend="isDraggingCategory = false"
                >
                  <v-ons-col class="color-header" width="20%">
                    <v-ons-checkbox
                      v-model="category.isDisp"
                      class="checkbox-style"
                      @input="checkDispToggle('category', category.categoryNo)"
                    />
                    {{ category.categoryName }}
                    <v-ons-icon icon="fa-bars" class="category-handle" />
                  </v-ons-col>
                  <v-ons-col>
                    <draggable
                      v-model="category.categoryItem"
                      :options="{
                        ...dragOptions,
                        handle: '.sub-category-handle'
                      }"
                      @choose="isDraggingSubCategory = true"
                      @end="isDraggingSubCategory = false"
                    >
                      <v-ons-row
                        v-for="subCategory in category.categoryItem"
                        :key="subCategory.subCategoryNo"
                        :class="{
                          'layout-item-dragging': isDraggingSubCategory
                        }"
                        class="layout-item"
                        @mouseup="isDraggingSubCategory = false"
                        @touchend="isDraggingSubCategory = false"
                      >
                        <v-ons-row class="color-header">
                          <v-ons-col class="layout-item">
                            <v-ons-checkbox
                              v-model="subCategory.isDisp"
                              class="checkbox-style"
                              :disabled="
                                (1 === subCategory.subCategoryNo ||
                                  2 === subCategory.subCategoryNo) &&
                                  isDisabledRequiredItem
                              "
                              @input="
                                checkDispToggle(
                                  'subCategory',
                                  category.categoryNo,
                                  subCategory.subCategoryNo
                                )
                              "
                            />
                            {{ subCategory.subCategoryName }}
                            <span class="sub-category-handle-area">
                              <v-ons-icon
                                :ref="category.categoryNo+'_'+subCategory.subCategoryNo"
                                v-if="
                                  isSelectIcon(
                                    category.categoryNo,
                                    subCategory.subCategoryNo
                                  )
                                "
                                class="item-handle-icon"
                                icon="plus"
                                @click="
                                  showSelector(
                                    $event,
                                    category.categoryNo,
                                    subCategory.subCategoryNo,
                                    subCategory.subCategoryName
                                  )
                                "
                              />
                              <v-ons-icon
                                icon="fa-bars"
                                class="sub-category-handle"
                              />
                            </span>
                          </v-ons-col>
                        </v-ons-row>
                        <v-ons-col>
                          <draggable
                            v-model="subCategory.subCategoryItem"
                            :options="{
                              ...dragOptions,
                              handle: '.sub-category-item-handle'
                            }"
                            @choose="isDraggingSubCategoryItem = true"
                            @end="isDraggingSubCategoryItem = false"
                          >
                            <v-ons-col
                              v-for="subCategoryItem in subCategory.subCategoryItem"
                              :key="subCategoryItem.itemNo"
                              :class="{
                                'layout-item-dragging': isDraggingSubCategoryItem
                              }"
                              class="layout-item"
                              @mouseup="isDraggingSubCategoryItem = false"
                              @touchend="isDraggingSubCategoryItem = false"
                            >
                              <v-ons-checkbox
                                v-model="subCategoryItem.isDisp"
                                class="checkbox-style"
                                :disabled="
                                  (1 === subCategory.subCategoryNo ||
                                    2 === subCategory.subCategoryNo) &&
                                    isDisabledRequiredItem
                                "
                                @input="
                                  checkDispToggle(
                                    'subCategoryItem',
                                    category.categoryNo,
                                    subCategory.subCategoryNo,
                                    subCategoryItem.itemNo
                                  )
                                "
                              />
                              <label>{{ subCategoryItem.itemName }}</label>
                              <v-ons-icon
                                icon="fa-bars"
                                class="sub-category-item-handle sub-category-handle-area"
                              />
                            </v-ons-col>
                          </draggable>
                        </v-ons-col>
                      </v-ons-row>
                    </draggable>
                  </v-ons-col>
                </v-ons-row>
              </draggable>
            </draggable>
          </div>
        </td>
      </tr>
    </table>

    <v-ons-popover
      cancelable
      v-model:visible="popoverInfo.popoverVisible"
      :target="popoverInfo.popoverTarget"
      :direction="popoverInfo.popoverDirection"
      :class="[fontSizeSet, 'popover-style']"
    >
      <h2 class="selector-title">{{ popoverInfo.titleLabel }}</h2>
      <hr />
      <v-ons-row>
        <v-ons-col class="graph-setting">
          <div>
            グラフ縦線 左
          </div>
          <div>
            <label>上限値</label>
            <custom-input-number
              :value="selectedSettingLeft.max"
              :digits="5"
              :min-value="-99999.99"
              :max-value="99999.99"
            />
          </div>
          <div>
            <label>下限値</label>
            <custom-input-number
              :value="selectedSettingLeft.min"
              :digits="5"
              :min-value="-99999.99"
              :max-value="99999.99"
            />
          </div>
          <div>
            選択:
          </div>
          <div class="mult-selector">
            <div
              v-for="(selectedInfo, index) in popoverInfo.selectInfoOptions"
              :key="'left' + index"
              :class="setListClass(selectedInfo.itemNo, 0)"
              class="select-label-style"
              @click="storageInfo(selectedInfo.itemNo, 0)"
            >
              {{ selectedInfo.itemName }}
            </div>
          </div>
        </v-ons-col>
        <v-ons-col class="graph-setting">
          <div>
            グラフ縦線 右
          </div>
          <div>
            <label>上限値</label>
            <custom-input-number
              :value="selectedSettingRight.max"
              :digits="5"
              :min-value="-99999.99"
              :max-value="99999.99"
            />
          </div>
          <div>
            <label>下限値</label>
            <custom-input-number
              :value="selectedSettingRight.min"
              :digits="5"
              :min-value="-99999.99"
              :max-value="99999.99"
            />
          </div>
          <div>
            選択:
          </div>
          <div class="mult-selector">
            <div
              v-for="(selectedInfo, index) in popoverInfo.selectInfoOptions"
              :key="'right' + index"
              :class="setListClass(selectedInfo.itemNo, 1)"
              class="select-label-style"
              @click="storageInfo(selectedInfo.itemNo, 1)"
            >
              {{ selectedInfo.itemName }}
            </div>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-button
        class="common-style-cancel-button button-cancel"
        @click="popoverInfo.popoverVisible = false"
      >
        キャンセル
      </v-ons-button>
      <v-ons-button
        class="common-style-ok-button button-confirm"
        @click="saveChanges"
      >
        OK
      </v-ons-button>
    </v-ons-popover>
    <!-- 薬剤選択ボタンポップオーバー -->
    <pop-over
      v-bind="popMedicineInfo"
      :target-position-element="popoverTargetElement()"
      @popover-return="selectedMedi($event)"
      @popover-close="closeMediPopover()"
    />
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import {
  mstPatViewerLayoutDefine,
  selectInfoOptions
} from "@/constants/mstPatViewerLayoutDefine";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import { ApiHelper } from "@/apis/AxiosHelper";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end

export default {
  mixins: [PopoverMixin],

  components: {
    draggable: VueDraggable,
    "custom-input-number": customInputNumber,
    "pop-over": MasterSelector
  },

  data() {
    return {
      dragOptions: {
        animation: 250,
        ghostClass: "ghost",
        dragClass: "drag",
        forceFallback: true,
        fallbackClass: "layout-item-fallback"
      },
      isDraggingCategory: false,
      isDraggingSubCategory: false,
      isDraggingSubCategoryItem: false,
      /**
       * 表示項目情報
       */
      dispItemInfo: [],
      /**
       * 表示項目情報初期値
       */
      initdispItemInfo: [],
      /**
       * ポップオーバー情報
       */
      popoverInfo: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: null,
        // ポップオーバータイトル
        titleLabel: null,
        // ポップオーバーで選択された情報リスト(グラフ縦線 左)
        selectedListLeft: [],
        // ポップオーバーで選択された情報リスト(グラフ縦線 右)
        selectedListRight: [],
        // 対象となる項目情報
        targetInfo: {
          categoryNo: null,
          subCategoryNo: null
        }
      },
      /**
       * 選択情報リスト(グラフ縦線 左)
       */
      selectedListLeft: [],
      /**
       * モニタグラフ設定(グラフ縦線 左)
       */
      selectedSettingLeft: {
        min: {
          initValue: 0,
          editValue: 0
        },
        max: {
          initValue: 0,
          editValue: 0
        },
        graph: 0
      },
      /**
       * 選択情報リスト(グラフ縦線 右)
       */
      selectedListRight: [],
      /**
       * モニタグラフ設定(グラフ縦線 右)
       */
      selectedSettingRight: {
        min: {
          initValue: 0,
          editValue: 0
        },
        max: {
          initValue: 0,
          editValue: 0
        },
        graph: 1
      },
      /**
       * 必須項目選択不可フラグ
       */
      isDisabledRequiredItem: false,
      /**
       * 必須項目自動設定情報
       * 「治療予定」、「治療方法」を変更した際に格納する
       */
      isAutoSetRequiredItem: [],
      /**
       * 薬剤選択ポップオーバーのパラメータ
       */
      popMedicineInfo: {
        popoverVisible: false,
        popoverDisplayDirection: "left",
        popoverTitleHeader: "薬剤",
        popoverFilter: [],
        popoverContentLabel: "薬剤名",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        targetInfo: {
          categoryNo: null,
          subCategoryNo: null
        }
      },
      //薬剤マスタ
      mstMedicine: null,
      mstMediClass: null,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { editRecord: "getEditRecord" }),
    ...mapGetters("user", ["getFacilityCd"]),

    selectedPeriod: {
      get() {
        return this.editRecord.dispPeriodClass
          ? this.editRecord.dispPeriodClass
          : "0";
      },

      set(value) {
        this.editRecord.dispPeriodClass = value;
      }
    },

    selectedList() {
      const settingLeft = deepCopy(this.selectedSettingLeft);
      const settingRight = deepCopy(this.selectedSettingRight);

      // 編集後の値を格納
      settingLeft.min = settingLeft.min.editValue;
      settingLeft.max = settingLeft.max.editValue;
      settingRight.min = settingRight.min.editValue;
      settingRight.max = settingRight.max.editValue;

      // グラフ縦線左右を1つの配列にまとめ
      const retArr = [
        ...this.selectedListLeft.map(item => {
          return { ...item, ...settingLeft };
        }),
        ...this.selectedListRight.map(item => {
          return { ...item, ...settingRight };
        })
      ];

      return retArr;
    }
  },

  async created() {
    const requestParam = {
      facilityCd: this.getFacilityCd
    };
    // 薬剤マスタ
    await ApiHelper.get("/mstInfo/mstMedicine", requestParam)
      .then(response => {
        this.mstMedicine = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MasterModalComponentPatViewerLayoutBK.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    // 薬剤分類マスタ
    await ApiHelper.get("/mstInfo/mstMedicineClass", requestParam)
      .then(response => {
        this.mstMediClass = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MasterModalComponentPatViewerLayoutBK.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
  },

  watch: {
    /**
     * @description 表示項目並び替えウォッチャー
     */
    dispItemInfo: {
      handler(data) {
        const convData = this.removeIsDispOption(data);
        this.setDispItemInfo(convData);
        // 表示・非表示切替
        this.switchingItemDisp();
      },
      deep: true
    },

    /**
     * 期間が選択された際に項目を入れ替える
     */
    selectedPeriod() {
      // レイアウトデータの取得
      this.changeDispItem();
    }
  },

  mounted() {
    this.$el.parentElement.style.height = "100%";
    this.retrieveMstData();
    // 表示項目を初期値として格納する
    this.initdispItemInfo = deepCopy(this.dispItemInfo);
    // 期間表示クラスのデフォルト値を格納する
    if ("" === this.editRecord.dispPeriodClass) {
      this.setDispPeriod(this.selectedPeriod);
    }
    // 表示期間に対応するレイアウトデータの取得
    this.changeDispItem();
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),

    /**
     * @description レイアウトデータ取得
     */
    retrieveMstData() {
      const temp = this.editRecord.dispItemInfo
        ? JSON.parse(this.editRecord.dispItemInfo)
        : mstPatViewerLayoutDefine;
      this.dispItemInfo = this.insertIsDispOption(temp);
    },

    /**
     * @description レイアウト名更新
     * @param { String } value 編集内容
     */
    setLayoutName(value) {
      const name = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.editRecord, name });
    },

    /**
     * @description 表示期間更新
     * @param { String } dispPeriodClass 0: 3～14日、1: 12週～3年
     */
    setDispPeriod(dispPeriodClass) {
      // 編集中マスタを更新
      this.setEditRecord({ ...this.editRecord, dispPeriodClass });
    },

    /**
     * @description 表示項目変更
     * @param { Array } value 編集内容
     */
    setDispItemInfo(value) {
      const dispItemInfo = JSON.stringify(value);
      // 編集中マスタを更新
      this.setEditRecord({ ...this.editRecord, dispItemInfo });
    },

    /**
     * @description 編集レイアウト項目ごとに内部処理用表示フラグを挿入して、レイアウトマスタ定義を元に
     *              存在しない項目を非表示扱いとする
     * @param { Array } data 編集レイアウト
     */
    insertIsDispOption(data) {
      // 患者経過総合ビューアレイアウトマスタの項目定義
      const src = deepCopy(mstPatViewerLayoutDefine);
      // 編集中マスタ
      const dest = deepCopy(data);

      src.forEach(srcCategory => {
        const destCategory = dest.find(categoryOther => {
          return categoryOther.categoryNo === srcCategory.categoryNo;
        });

        // 編集中マスタに項目が存在しないと非表示にする
        if (!destCategory) {
          srcCategory.isDisp = false;
          srcCategory.categoryItem.forEach(subCat => {
            subCat.isDisp = false;
            subCat.subCategoryItem.forEach(item => {
              item.isDisp = false;
            });
          });
          dest.push(srcCategory);
        } else {
          destCategory.categoryName = srcCategory.categoryName;
          destCategory.isDisp = true;
          srcCategory.categoryItem.forEach(srcSubCategory => {
            const destSubCategory = destCategory.categoryItem.find(
              subCategoryOther => {
                return (
                  subCategoryOther.subCategoryNo ===
                  srcSubCategory.subCategoryNo);
              });

            // 編集中マスタに項目が存在しないと非表示にする
            if (!destSubCategory) {
              srcSubCategory.isDisp = false;
              srcSubCategory.subCategoryItem.forEach(item => {
                item.isDisp = false;
              });
              destCategory.categoryItem.push(srcSubCategory);
            } else {
              destSubCategory.subCategoryName = srcSubCategory.subCategoryName;
              destSubCategory.isDisp = true;
              // 治療情報の場合
              if (1 === srcCategory.categoryNo) {
                // 小項目番号を格納
                const cateNo = destSubCategory.subCategoryNo;
                // バイタル情報の場合、レイアウトマスタ情報に定義がなくても非表示にされない
                if (cateNo >= 58 && 61 >= cateNo) {
                  srcSubCategory.subCategoryItem =
                    destSubCategory.subCategoryItem;
                }
              } else if (
                (2 <= srcCategory.categoryNo && srcCategory.categoryNo <= 11) ||
                (1002 <= srcCategory.categoryNo &&
                  srcCategory.categoryNo <= 1019) // 1012 -> 1019: 投与薬剤グラフ と 処方薬剤グラフ
              ) {
                srcSubCategory.subCategoryItem =
                  destSubCategory.subCategoryItem;
              }
              srcSubCategory.subCategoryItem.forEach(srcItem => {
                const destItem = destSubCategory.subCategoryItem.find(
                  itemOther => {
                    return itemOther.itemNo === srcItem.itemNo;
                  }
                );

                // 編集中マスタに項目が存在しないと非表示にする
                if (!destItem) {
                  srcItem.isDisp = false;
                  destSubCategory.subCategoryItem.push(srcItem);
                } else {
                  destItem.itemName = srcItem.itemName;
                  destItem.isDisp = true;
                }
              });
            }
          });
        }
      });

      return dest;
    },

    /**
     * @description 内部処理用表示フラグを保存データから削除
     * @param { Array } data 編集レイアウト
     */
    removeIsDispOption(data) {
      let res = deepCopy(data);

      // 非表示とした項目を配列から削除
      res = res.filter(category => {
        category.categoryItem = category.categoryItem.filter(subCategory => {
          subCategory.subCategoryItem = subCategory.subCategoryItem.filter(
            item => {
              return item.isDisp;
            }
          );
          return subCategory.isDisp;
        });
        return category.isDisp;
      });

      // 「isDisp」のキーを削除
      res.forEach(category => {
        category.categoryItem.forEach(subCategory => {
          subCategory.subCategoryItem.forEach(item => {
            delete item.isDisp;
          });
          delete subCategory.isDisp;
        });
        delete category.isDisp;
      });

      return res;
    },

    /**
     * @description 表示非表示チェックボックストグル後のコールバック
     *              表示非表示したものによるグループ表示非表示をする
     * @param { String } type イベント発生元 (期待値: category, subCategory, subCategoryItem)
     * @param { Array } path 項目番号
     */
    checkDispToggle(type, ...path) {
      const categoryNo = path[0];
      const subCategoryNo = path[1];
      const itemNo = path[2];

      // 必須項目自動設定情報を初期化
      this.isAutoSetRequiredItem = new Array();
      // 「治療情報」項目でかつ、「治療予定」もしくは「治療方法」が変更された場合
      if (1 === categoryNo && (1 === subCategoryNo || 2 === subCategoryNo)) {
        // 必須自動設定番号を格納
        this.isAutoSetRequiredItem.push(subCategoryNo);
      }

      const category =
        categoryNo &&
        this.dispItemInfo.find(item => {
          return item.categoryNo === categoryNo;
        });
      const subCategory =
        subCategoryNo &&
        category.categoryItem.find(item => {
          return item.subCategoryNo === subCategoryNo;
        });
      const subCategoryItem =
        itemNo &&
        subCategory.subCategoryItem.find(item => {
          return item.itemNo === itemNo;
        });

      switch (type) {
        case "category":
          category.categoryItem.forEach(item => {
            item.subCategoryItem.forEach(i => {
              i.isDisp = !category.isDisp;
            });
            item.isDisp = !category.isDisp;
          });
          break;
        case "subCategory":
          subCategory.subCategoryItem.forEach(
            item => (item.isDisp = !subCategory.isDisp)
          );
          category.isDisp = !subCategory.isDisp || category.isDisp;
          break;
        case "subCategoryItem":
          category.isDisp = !subCategoryItem.isDisp || category.isDisp;
          subCategory.isDisp = !subCategoryItem.isDisp || subCategory.isDisp;
          break;
        default:
          break;
      }

      // 「治療情報」項目が変更された場合、「投与薬剤」の小項目選択を制御
      if (1 === categoryNo) {
        // 大項目が変更された場合、「投与薬剤」の1番目の小項目を選択する
        if (type === "category") {
          const subCategoryMedi = category.categoryItem.find(item => {
            return item.subCategoryNo === 5;
          });
          subCategoryMedi.subCategoryItem[0].isDisp = !category.isDisp;
          subCategoryMedi.subCategoryItem[1].isDisp = false;
        }
        // 中項目が変更された場合、「投与薬剤」の1番目の小項目を選択する
        else if (type === "subCategory" && subCategoryNo === 5) {
          subCategory.subCategoryItem[0].isDisp = !subCategory.isDisp;
          subCategory.subCategoryItem[1].isDisp = false;
        }
        // 小項目が変更された場合、選択された項目のみ選択する(複数選択不可)
        else if (type === "subCategoryItem" && subCategoryNo === 5) {
          subCategory.subCategoryItem[0].isDisp = false;
          subCategory.subCategoryItem[1].isDisp = false;
        }
      }
    },

    /**
     * 期間ごとの表示項目に変更する
     * @param 期間を選択した際に表示項目を入れ替える
     */
    changeDispItem() {
      // 初期表示項目リストが1つも格納されていない場合処理終了
      if (this.initdispItemInfo.length === 0) {
        return;
      }
      this.dispItemInfo = this.initdispItemInfo.filter(item => {
        if (this.selectedPeriod === "0") {
          // 3日・7日・14日選択時はカテゴリNo.1000以下の項目を表示
          return item.categoryNo <= 1000;
        } else if (this.selectedPeriod === "1") {
          // 12週・6ヶ月・1年・3年選択時はカテゴリNo.1001以上の項目を表示
          return item.categoryNo > 1000;
        }
      });
    },

    /**
     * 項目の表示非表示切替
     * @description
     *  小項目が1つも表示状態でない場合、それが属する中項目を非表示に切り替える
     *  中項目が1つも表示状態でない場合、それが属する大項目を非表示に切り替える
     *  「治療情報」の項目のうち、表示するものが1つでもある場合、「治療予定」、「治療方法」を表示にする
     */
    switchingItemDisp() {
      // 大項目情報でループ
      this.dispItemInfo.forEach(categoryInfo => {
        // 大項目表示・非表示切替格納用
        let categoryDisp = false;
        // 中項目情報でループ
        categoryInfo.categoryItem.forEach(subCategoryInfo => {
          // 中項目表示・非表示切替格納用
          let subCategoryDisp = false;
          // 小項目情報でループ
          subCategoryInfo.subCategoryItem.forEach(item => {
            // 中項目表示・非表示切替を設定
            subCategoryDisp = item.isDisp ? item.isDisp : subCategoryDisp;
          });
          // 中項目表示・非表示を切替
          subCategoryInfo.isDisp = subCategoryDisp;
          // 大項目表示・非表示切替を設定
          categoryDisp = subCategoryDisp ? subCategoryDisp : categoryDisp;
        });
        // 大項目表示・非表示切替を格納
        categoryInfo.isDisp = categoryDisp;

        // 「治療情報」項目の場合以下の処理を実行
        if (1 === categoryInfo.categoryNo) {
          // 「治療予定」「治療方法」表示フラグ
          let isDisp = false;
          // 必須項目操作不可フラグ
          this.isDisabledRequiredItem = false;
          isDisp = categoryInfo.isDisp;
          categoryInfo.categoryItem.forEach(subCategoryInfo => {
            const subNo = subCategoryInfo.subCategoryNo;
            // 「治療予定」、「治療方法」の表示フラグを格納する
            if (1 === subNo || 2 === subNo) {
              // 自動設定しないサブカテゴリ番号を取得
              const disSetNo =
                1 === this.isAutoSetRequiredItem.length
                  ? this.isAutoSetRequiredItem[0]
                  : 0;
              // どちらかの項目もしくは、両方の項目を自動設定する
              if (subNo !== disSetNo) {
                subCategoryInfo.subCategoryItem.forEach(item => {
                  item.isDisp = isDisp;
                });
              }
            }
          });
          categoryInfo.categoryItem.forEach(subCategoryInfo => {
            const subNo = subCategoryInfo.subCategoryNo;
            if (1 !== subNo && 2 !== subNo) {
              subCategoryInfo.subCategoryItem.forEach(item => {
                if (item.isDisp) {
                  this.isDisabledRequiredItem = true;
                }
              });
            }
          });
        }
      });
    },

    /**
     * 項目選択アイコン表示・非表示切替
     * @description バイタル・モニタ(グラフ)がアイコン表示対象
     * @param categoryNo    大項目番号
     * @param subCategoryNo 中項目番号
     */
    isSelectIcon(categoryNo, subCategoryNo) {
      // 項目追加・削除アイコン表示フラグ
      let isDispIcon = false;
      // 大項目が治療情報の場合
      if (1 === categoryNo) {
        // 中項目がバイタル情報の場合
        if (subCategoryNo >= 58 && 61 >= subCategoryNo) {
          isDispIcon = true;
        }
        // 大項目がバイタル情報の場合
      } else if (
        (2 <= categoryNo && categoryNo <= 11) ||
        (1002 <= categoryNo && categoryNo <= 1019)
      ) { // 1012 -> 1019: 投与薬剤グラフ と 処方薬剤グラフ
        isDispIcon = true;
      }
      return isDispIcon;
    },

    /**
     * 小項目選択肢ポップオーバー表示
     * @description 小項目選択ポップオーバーを表示するとともに、大項目番号と中項目番号
     *  をもとに選択肢の情報を格納する
     * @param e ポップオーバーターゲット
     * @param categoryNo 大項目番号
     * @param subCategoryNo 中項目番号
     * @param subCategoryTitle 中項目名
     */
    showSelector(e, categoryNo, subCategoryNo, subCategoryTitle) {
      if (1012 <= categoryNo && categoryNo <= 1019) {
        this.popMedicineInfo.targetInfo = {
          categoryNo,
          subCategoryNo
        };
        this.setMediPopover();
        return;
      }
      // 大項目情報でループ
      this.dispItemInfo.forEach(eleCategory => {
        // 大項目番号が一致する場合
        if (eleCategory.categoryNo === categoryNo) {
          // 中項目情報でループ
          eleCategory.categoryItem.forEach(eleSubCategory => {
            // 中項目番号が一致するものを取得
            if (eleSubCategory.subCategoryNo === subCategoryNo) {
              // 対象の中項目の現在表示中の小項目を格納(グラフ縦線 左)
              this.selectedListLeft = eleSubCategory.subCategoryItem.filter(
                item => {
                  return item.graph === 0;
                }
              );
              // モニタグラフ設定を初期化(グラフ縦線 左)
              this.selectedSettingLeft.min.initValue = this.selectedListLeft[0]
                ? this.selectedListLeft[0].min
                : 0;
              this.selectedSettingLeft.max.initValue = this.selectedListLeft[0]
                ? this.selectedListLeft[0].max
                : 0;
              this.selectedSettingLeft.min.editValue = this.selectedSettingLeft.min.initValue;
              this.selectedSettingLeft.max.editValue = this.selectedSettingLeft.max.initValue;
              // 対象の中項目の現在表示中の小項目を格納(グラフ縦線 右)
              this.selectedListRight = eleSubCategory.subCategoryItem.filter(
                item => {
                  return item.graph === 1;
                }
              );
              // モニタグラフ設定を初期化(グラフ縦線 右)
              this.selectedSettingRight.min.initValue = this
                .selectedListRight[0]
                ? this.selectedListRight[0].min
                : 0;
              this.selectedSettingRight.max.initValue = this
                .selectedListRight[0]
                ? this.selectedListRight[0].max
                : 0;
              this.selectedSettingRight.min.editValue = this.selectedSettingRight.min.initValue;
              this.selectedSettingRight.max.editValue = this.selectedSettingRight.max.initValue;
            }
          });
        }
      });
      // ポップオーバー表示ターゲット情報格納
      this.popoverInfo.popoverTarget = e;
      // ポップオーバー表示位置情報格納
      this.popoverInfo.popoverDirection = "left";
      // ポップオーバータイトルを格納
      this.popoverInfo.titleLabel = subCategoryTitle;
      // 選択肢情報を格納
      this.popoverInfo.selectInfoOptions =
        selectInfoOptions[this.getCategoryClass(categoryNo)];
      // 現在選択中のバイタル情報を格納(グラフ縦線 左)
      this.popoverInfo.selectedListLeft = deepCopy(this.selectedListLeft);
      // 現在選択中のバイタル情報を格納(グラフ縦線 右)
      this.popoverInfo.selectedListRight = deepCopy(this.selectedListRight);
      // 対象となる項目の情報を格納
      this.popoverInfo.targetInfo = {
        categoryNo,
        subCategoryNo
      };
      // ポップオーバーを表示
      this.popoverInfo.popoverVisible = true;
    },

    /**
     * 項目区分取得
     */
    getCategoryClass(categoryCd) {
      let categoryClass;
      if (categoryCd === 1) {
        categoryClass = "treatCondInfo";
      } else if (
        (2 <= categoryCd && categoryCd <= 11) ||
        (1002 <= categoryCd && categoryCd <= 1011)
      ) {
        categoryClass = "vitalInfo";
      }
      return categoryClass;
    },

    /**
     * 選択情報を格納
     * @description
     *  小項目選択ポップオーバーで選択した情報を
     *  ポップオーバー内で保持する
     * @param cd 小項目番号
     * @param {Number} graphClass 0: グラフ縦線 左、1: グラフ縦線 右
     */
    storageInfo(cd, graphClass) {
      // 左グラフか右グラフか
      const selectedList =
        graphClass === 0
          ? this.popoverInfo.selectedListLeft
          : this.popoverInfo.selectedListRight;
      // 格納されている選択情報の数(左+右)
      const selectedListTotalCount =
        this.popoverInfo.selectedListLeft.length +
        this.popoverInfo.selectedListRight.length;
      // 要素番号格納用
      let index = null;
      // 選択されたバイタル情報名格納用
      let itemName = null;
      // 選択肢から小項目番号の一致する項目名を取得
      this.popoverInfo.selectInfoOptions.forEach(vaitalInfo => {
        itemName = vaitalInfo.itemNo === cd ? vaitalInfo.itemName : itemName;
      });
      // 選択したものが格納先にすでにあるのかをチェック
      selectedList.forEach((eleInfo, eleIndex) => {
        if (cd === eleInfo.itemNo) {
          index = eleIndex;
        }
      });
      // 格納先にない場合
      if (null === index) {
        // 選択情報を格納
        if (6 > selectedListTotalCount) {
          // 格納されている選択情報(左+右)が5つ以下の場合小項目情報を格納
          selectedList.push({
            isDisp: true,
            itemName,
            itemNo: cd
          });
        }
      } else {
        // すでに格納されている選択情報ある場合削除
        selectedList.splice(index, 1);
      }
    },

    /**
     * 選択肢クラスの設定
     * @description 選択肢の項目を選択状態と未選択状態でクラスを分ける
     * @param cd 小項目番号
     * @param {Number} graphClass 0: グラフ縦線 左、1: グラフ縦線 右
     */
    setListClass(cd, graphClass) {
      // 左グラフか右グラフか
      const selectedList =
        graphClass === 0
          ? this.popoverInfo.selectedListLeft
          : this.popoverInfo.selectedListRight;
      const obj = {
        "selected-color": false,
        "dis-selected-color": false
      };
      // 選択状態フラグを格納
      let isSelected = false;
      // 格納された選択肢情報をループ
      selectedList.forEach(eleInfo => {
        // 格納された選択状態リストと対象のコードが一致した場合true
        isSelected = eleInfo.itemNo === cd ? true : isSelected;
      });
      // 選択中クラスを付与
      obj["selected-color"] = isSelected;
      // 未選択中クラスを付与
      obj["dis-selected-color"] = !isSelected;
      return obj;
    },

    /**
     * ポップオーバーで選択した情報を格納する
     */
    saveChanges() {
      // 選択したバイタル情報を格納する(グラフ縦線 左)
      this.selectedListLeft = deepCopy(this.popoverInfo.selectedListLeft);
      // 選択したバイタル情報を格納する(グラフ縦線 右)
      this.selectedListRight = deepCopy(this.popoverInfo.selectedListRight);
      // 対象の中項目に選択した小項目を設定する
      this.setVitalInfoItem(
        this.popoverInfo.targetInfo.categoryNo,
        this.popoverInfo.targetInfo.subCategoryNo
      );
      // ポップオーバーを閉じる
      this.popoverInfo.popoverVisible = false;
    },

    /**
     * 選択した項目を追加
     * @description 小項目選択ポップオーバーで選択した項目をレイアウトマスタに格納する
     * @param categoryNo 大項目番号
     * @param subCategoryNo 中項目番号
     */
    setVitalInfoItem(categoryNo, subCategoryNo) {
      // 小項目情報格納用
      const subCategoryItem = [];
      // 選択した小項目番号を格納(左+右)
      this.selectedList.forEach(eleInfo => {
        subCategoryItem.push(eleInfo);
      });
      // 大項目情報でループ
      const categoryInfo = this.dispItemInfo.find(eleCategoryInfo => {
        // 大項目番号が一致するものを取得
        return categoryNo === eleCategoryInfo.categoryNo;
      });
      // 中項目情報でループ
      const subCategoryInfo = categoryInfo.categoryItem.find(
        eleSubCategoryInfo => {
          // 中項目番号が一致するものを取得
          return subCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }
      );
      // ポップオーバーで選択した項目情報を格納
      subCategoryInfo.subCategoryItem = subCategoryItem;
      subCategoryInfo.isDisp = 0 === subCategoryItem.length ? false : true;
    },
    /**
     * @description 薬剤選択ボタン押下時のポップオーバー表示位置を取得
     * @param ポップオーバー表示位置
     */
    popoverTargetElement() {
      //ポップオーバーの表示位置を取得(薬剤選択ボタン押下時はそのボタンの位置、それ以外はnull)
      const targetInfo = this.popMedicineInfo.targetInfo;
      const refName = targetInfo.categoryNo+'_'+targetInfo.subCategoryNo;
      const position = targetInfo.categoryNo === null ? null : this.$refs[refName][0];
      return position;
    },
    setMediPopover() {
      // 薬剤分類
      const mediClassList = this.mstMediClass.map(item => {
        return {
          text: item.className,
          value: item.classCd
        };
      });

      mediClassList.unshift({ text: "すべて", value: 0 });

      this.popMedicineInfo.popoverFilter = [
        {
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            { text: "通常薬剤", value: "0" },
            { text: "セット薬剤", value: "1" },
            { text: "調整薬剤", value: "2" }
          ]
        },
        {
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: mediClassList
        }
      ];
      // 薬剤名一覧を作成
      const mediList = this.mstMedicine.map(item => {
        return {
          value: item.medicineCd,
          fnValue: {
            薬剤区分: "0",
            薬剤分類: item.classCd
          },
          text: item.medicineName
        };
      });

      this.popMedicineInfo.popoverContentDataset = mediList;

      this.popMedicineInfo.popoverVisible = true;
    },
    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択した薬剤情報
     */
    selectedMedi(event) {
      const subCategoryItem = [];
      const targetInfo = this.popMedicineInfo.targetInfo;

      const categoryInfo = this.dispItemInfo.find(eleCategoryInfo => {
        return targetInfo.categoryNo === eleCategoryInfo.categoryNo;
      });
      const subCategoryInfo = categoryInfo.categoryItem.find(
        eleSubCategoryInfo => {
          return targetInfo.subCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }
      );
      subCategoryInfo.subCategoryItem.push({
        isDisp: true,
        itemName: event.text,
        itemNo: event.value
      });
      subCategoryInfo.isDisp = 0 === subCategoryItem.length ? false : true;

      this.popMedicineInfo.targetInfo = {
        categoryNo: null,
        subCategoryNo: null
      };
    },
    /**
     * @description ポップオーバー内、キャンセルボタン押下時の処理
     */
    closeMediPopover() {
      this.popMedicineInfo.popoverVisible = false;
    }
  }
};
</script>

<style scoped>
.layout-item {
  border: 1px solid #999;
  transition: max-height 500ms;
  overflow: hidden;
  max-height: 99999px;
}

.layout-item-fallback,
.layout-item.layout-item-dragging {
  max-height: 26px;
}

.checkbox-style {
  margin: 0px;
  vertical-align: middle;
}

.ghost {
  opacity: 0.5;
}

.drag {
  display: none;
}

.layout-name-area,
.disp-period,
.disp-item-name-area {
  padding-left: 8px;
  vertical-align: top;
}

.disp-item-no,
.k-textbox {
  width: 100%;
}

.disp-item-content-area {
  overflow-y: scroll;
  height: 100%;
}

.disp-item-area {
  height: 97%;
  width: 100%;
  border-collapse: collapse;
}

/* .disp-item-area tr {
  height: 30px;
} */

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  border: 1px solid lightgray;
  text-align: left;
}

.disp-item-area tr:nth-child(3) td:nth-child(3) {
  height: 100%;
}

.category-handle {
  cursor: move;
  float: right;
  margin: 2px 5px;
}

.sub-category-handle-area {
  float: right;
  margin-top: 2px;
  margin-right: 5px;
}

.item-handle-icon {
  margin: 4px;
}

.popover-style :deep(.popover__content) {
  width: 500px;
  height: 100%;
  padding: 25px;
}

.selector-title {
  margin: 0;
}

.mult-selector {
  overflow-y: auto;
  max-height: 300px;
  min-height: 300px;
  border: solid 1px #bbbbbb;
  white-space: nowrap;
}

.selected-color {
  background-color: #0076ff !important;
  color: white;
  width: max-content;
  min-width: 100%;
}

:disabled + .checkbox__checkmark {
  opacity: 100;
}

.dis-selected-color:hover {
  background-color: #dddddd;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.rdo-period {
  margin-right: 10px;
}

.graph-setting > div {
  margin-bottom: 5px;
}

.graph-setting:first-child {
  margin-right: 5px;
}

.graph-setting:nth-child(2) {
  margin-left: 5px;
}

.graph-setting :deep(label) {
  margin-right: 5px;
}
</style>
