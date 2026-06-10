<template>
  <!-- 表示項目設定 -->
  <div class="disp-item-area">
    <draggable
      v-model="displayItemList"
      :options="{
            ...dragOptions, // ドラッグ方法設定
            handle: '.category-handle' // 結びつけた要素クリック時にdragする
          }"
      @change="changeButton"
      @start="startDragging"
      @end="finishDragging"
    >
      <v-ons-row
        v-for="(column) in displayItemList"
        :key="column.categoryCd"
        class="reset-size category-border"
        :class="{ 'layout-category-dragging': isDraggingCategory }"
      >
        <v-ons-col class="word-border" valign="top" width="40%">
          <!-- カテゴリ名のチェックボックス -->
          <label>
            <v-ons-checkbox v-model="column.isChecked" @input="checkAllItems(column)" @change="changeButton"/>
            <!-- カテゴリ名 -->
            {{ column.categoryTitle }}
          </label>
          <!-- ドラッグ用アイコン -->
          <v-ons-icon icon="fa-bars" class="category-handle" />
        </v-ons-col>
        <!-- 項目名 -->
        <v-ons-col style="border-right: 1px solid #d3d3d3">
          <draggable
            v-model="column.categoryItem"
            @change="changeButton"
            :options="{
                  ...dragOptions,
                  handle: '.column-handle'
                }"
          >
            <v-ons-row
              v-for="(item, index) in column.categoryItem"
              :key="item.categoryCd + '|' + item.dataListDetailCd + '|' + item.id + '|' + index"
              class="reset-size word-border word-border-item"
              :class="{ 'layout-column-dragging': isDraggingCategory }"
            >
              <v-ons-col>
                <!-- アイコンを右寄せにするため、colで囲う -->
                <!-- チェックボックス -->
                <label>
                  <v-ons-checkbox v-model="item.isChecked" @change="changeButton"/>
                  <!-- 項目名 -->
                  {{ item.name }}
                </label>
                <!-- ドラッグ用アイコン -->
                <v-ons-icon icon="fa-bars" class="column-handle" />
              </v-ons-col>
            </v-ons-row>
          </draggable>

        </v-ons-col>
        <!-- 項目名ここまで -->
      </v-ons-row>
    </draggable>
  </div>
</template>

<script>
import _ from "underscore";
import { EventBus } from "@/eventBus.js";
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { PAT_INFO_TEMPLATE_CD, VITAL_MONITORS_COMPLAINTS_CD, TREATMENT_PLAN_TREATMENT_RECORD } from "@/constants/dataListConstant";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import vuedraggable from "vuedraggable";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    draggable: vuedraggable,
  },

  props: {
    templateCd: {
      type: Number,
      default: 4
    },
    cateStyle: {
      type: String,
      default: ""
    },
    // dragOptions: {
    //   type: Object,
    //   default: () => {}
    // }
  },

  data() {
    return {
      templateCdcopy:0,
      templateCdcount:0,
      displayItemListcopy: [],// //カテゴリの並び替えができない修正  xmj
      displayItemList: [],
      oriList: [], // add チェックするときに応答が遅いことを対応 劉
      isInitialState: 0,
      mstMainteLayoutData: [],
      mstMainteLayoutGroupData: [],
      //カテゴリをドラッグしているかのフラグ
      isDraggingCategory: false,
      dragOptions: {
        animation: 250, //drag時の速度
        forceFallback: true, //trueにすると、draggable用のDnDが作動するようになる
        dragClass: "drag", //ドラッグ時のクラス名
        ghostClass: "ghost" //ドロップ時のクラス名
      },
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      initDisplayItemList: [],
      initDisplayItemFlag: true,
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
    };
  },

  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("master-maintenance", { editRecord: "getEditRecord" }),
    ...mapGetters("pat-list-layout", ["getPrevEditRecord", "getOriginalList"])
  },
  watch: {
    templateCd: {
      immediate: true,
      handler(id) {
        this.initTemplateList(id);
      }
    },
    displayItemList: {
      handler(categories) {
        // カテゴリ名・項目名のチェックボックスを対応させる
        this.connectingItemDisp();
        // ストアにチェックを入れた項目を格納
        this.setDispItemInfo(categories)
        //テンプレートを装置情報（点検（日常・定期））を選択すると 自動的に選択されない処理 #6405 xiemj start
        //if (this.templateCd === 12) {
         // this.initialState(categories)
        //}
        //テンプレートを装置情報（点検（日常・定期））を選択すると 自動的に選択されない処理 #6405 xiemj end
      },
      deep: true
    }
  },

  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("pat-list-layout", ["setPrevEditRecord", "setOriginalList"]),

    /**
     * @description ドラッグを始めた際と終えた際の処理
     */
    startDragging() {
      //項目を非表示にする
      this.isDraggingCategory = true;
    },
    finishDragging() {
      //項目を表示する
      this.isDraggingCategory = false;
    },

    initialState(categories) {
      let inspectionTotal = 0;
      for (let i = 0; i < categories[1].categoryItem.length; i++) {
        if (categories[1].categoryItem[i].isChecked) {
          inspectionTotal ++;
          this.isInitialState ++;
        }
      }
      for (let i = 0; i < categories[2].categoryItem.length; i++) {
        if (categories[2].categoryItem[i].isChecked) {
          inspectionTotal ++;
          this.isInitialState ++;
        }
      }
      if (inspectionTotal === 0 && this.isInitialState === 0) {
        if (Math.floor(Math.random() * 5) % 2 === 1) {
          if (this.mstMainteLayoutData.length > 0) {
            this.setDaily(categories);
          } else {
            this.setRegular(categories);
          }
        } else {
          if (this.mstMainteLayoutData.length > 0) {
            this.setRegular(categories);
          } else {
            this.setDaily(categories);
          }
        }
      }
    },
    setDaily(categories) {
      this.displayItemList[1].isChecked = true
      this.displayItemList[1].categoryItem[Math.floor(Math.random() * categories[1].categoryItem.length)].isChecked = true;
    },
    setRegular(categories) {
      this.displayItemList[2].isChecked = true;
      this.displayItemList[2].categoryItem[Math.floor(Math.random() * categories[2].categoryItem.length)].isChecked = true;
      this.displayItemList[4].isChecked = true;
      this.displayItemList[4].categoryItem[Math.floor(Math.random() * 5) % 2 === 1 ? 0 : 1].isChecked = true;
    },

    // add チェックするときに応答が遅いことを対応 劉 start
    setStoreValue(){
      this.setOriginalList(deepCopy(this.displayItemList));
      this.oriList = deepCopy(this.getOriginalList);
      this.setOriginalList(this.oriList);
    },
    // add チェックするときに応答が遅いことを対応 劉 end
    checkAllItems(column) {
      //チェックボックスをクリックする前の状態を取得
      const categoryDisp = column.isChecked;

      //チェックを入れたなら、属する項目全てにチェックを入れる。外したなら全て外す
      column.categoryItem.forEach(item => {
        item.isChecked = !categoryDisp;
      });
    },

    /**
     * @description カテゴリと項目のチェックボックスを関連させる処理
     *  カテゴリの表示が1つもない場合、それが属するカテゴリを非表示に切り替える
     */
    connectingItemDisp() {
      this.displayItemList.forEach(category => {
        //項目が1つでも選択されているかの判定フラグ
        let categoryCheck = false;
        const categoryCd = category.categoryCd;
        category.categoryItem.forEach(item => {
          //項目のチェックボックス
          const itemCheck = item.isChecked;
          //項目が1つでもチェックされていれば、カテゴリにチェックを付ける
          categoryCheck = itemCheck ? itemCheck : categoryCheck;
          this.mappingOriginalList(categoryCd, item);
        });
        // カテゴリのチェック有無を保持
        category.isChecked = categoryCheck;
      });
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      if(this.initDisplayItemFlag){
        this.initDisplayItemList = JSON.parse(JSON.stringify(this.displayItemList));
        this.initDisplayItemFlag = false;
      }
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
    },
    setDispItemInfo(categories) {
      let listDataListItem = [];
      const saveInfo = [];
      categories.forEach(column => {
        listDataListItem.push(column.categoryItem);
      });
      listDataListItem = _.flatten(listDataListItem);

      // 全てのチェックした項目をフィルタする。
      const listDataListItemChecked = listDataListItem.filter(l => l.isChecked);

      const listDataListDetailCd = [];
      if (listDataListItemChecked.length > 0) {
        listDataListItemChecked.forEach(item => {
          const dataListDetailCd = item.dataListDetailCd;
          if (listDataListDetailCd.includes(dataListDetailCd)) {
            return;
          }
          listDataListDetailCd.push(dataListDetailCd);
          // 指定されたデータリスト詳細コードに該当する項目をフィルタする。
          const listItems = listDataListItemChecked.filter(
            i => i.dataListDetailCd === dataListDetailCd
          );
          if (!listItems || listItems.length === 0) {
            return;
          }
          let items = [];
          listItems.forEach(itemDetail => {
            items.push(itemDetail.id);
          });
          items = Array.from(new Set(items));
          const dispInfo = {
            items,
            data_list_detail_cd: dataListDetailCd
          };
          saveInfo.push(dispInfo);
        });
      }

      const saveInfoJson = JSON.stringify(saveInfo);
      const prevEditRecord = this.getPrevEditRecord.find(
        ele => ele.templateCd == this.editRecord.templateCd
      );
      if (prevEditRecord) {
        prevEditRecord.dispItemInfo = saveInfoJson;
        this.setPrevEditRecord([...this.getPrevEditRecord]);
      } else {
        const editObj = {
          templateCd: this.editRecord.templateCd,
          dispItemInfo: saveInfoJson
        };
        this.getPrevEditRecord.push(editObj);
        this.setPrevEditRecord([...this.getPrevEditRecord]);
      }
      this.setEditRecord({ ...this.editRecord, dispItemInfo: saveInfoJson });
      this.originalList = deepCopy(this.displayItemList);
    },

    async getTemplateData(templateCd) {
      if (templateCd === PAT_INFO_TEMPLATE_CD) {
        return;
      }
      // 共通ローダー表示
      this.setLoadingScreenVisible(true);
      // add マスタ一覧 施設切替を可能とする 王 start
      // const url = `/sysDataListDetail/getByTemplate/${templateCd}`;
      const url = `/sysDataListDetail/getByTemplate/${templateCd}/temp/${this.getFacilitySwitch}`;
      // add マスタ一覧 施設切替を可能とする 王 end
      let response;
      try {
        response = await ApiHelper.get(url);
        if (templateCd === VITAL_MONITORS_COMPLAINTS_CD) {
          let tempData;
          await ApiHelper.get(
            `/master_maintenance/mst_add_monitor/data/${this.getFacilitySwitch}`
          ).then(response => {
            tempData = response.data.localDataSource.data
          });
          for (let i = 0; i < response.data.length; i++) {
            if (response.data[i].dataListDetailCd === 1095) {
              response.data[i].items = tempData.filter(item => item.isDisp === "1" && item.vitalMonitorClass === "1").map((item) => {
                return {
                  categoryCd: 83,
                  dataListDetailCd: 1095,
                  dispOrder: 2,
                  id: item.code,
                  isChecked: false,
                  name: item.name
                };
              });
            }
            if (response.data[i].dataListDetailCd === 1097) {
              response.data[i].items = tempData.filter(item => item.isDisp === "1" && item.vitalMonitorClass === "2").map((item) => {
                return {
                  categoryCd: 84,
                  dataListDetailCd: 1097,
                  dispOrder: 2,
                  id: item.code,
                  isChecked: false,
                  name: item.name
                };
              });
            }
          }
        }
        // 共通ローダー非表示
        this.setLoadingScreenVisible(false);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('DynamicTemplateMasterComponent.vue', 'getTemplateData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        // 共通ローダー非表示
        this.setLoadingScreenVisible(false);
        this.internalServerError(error);
      }
      if (templateCd === TREATMENT_PLAN_TREATMENT_RECORD) {
        for (let i = 0; i < response.data.length; i++) {
          if (response.data[i].dataListDetailCd === 316) {
            for (let j = 0; j < 20; j++) {
              const temp1 = response.data[i].dispOrder;
              const temp2 = response.data[i + 1].dispOrder;
              const temp3 = response.data[i + 2].dispOrder;
              const temp4 = response.data[i + 3].dispOrder;
              const temp5 = response.data[i + 4].dispOrder;
              response.data[i].dispOrder = temp4;
              response.data[i + 1].dispOrder = temp5;
              response.data[i + 2].dispOrder = temp1;
              response.data[i + 3].dispOrder = temp2;
              response.data[i + 4].dispOrder = temp3;
              i += 6;
            }
          }
          if (response.data[i].dataListDetailCd === 832) {
            for (let j = 0; j < 20; j++) {
              const temp1 = response.data[i].dispOrder;
              const temp2 = response.data[i + 1].dispOrder;
              const temp3 = response.data[i + 2].dispOrder;
              const temp4 = response.data[i + 3].dispOrder;
              const temp5 = response.data[i + 4].dispOrder;
              response.data[i].dispOrder = temp4;
              response.data[i + 1].dispOrder = temp5;
              response.data[i + 2].dispOrder = temp1;
              response.data[i + 3].dispOrder = temp2;
              response.data[i + 4].dispOrder = temp3;
              i += 6;
            }
          }
        }
      }
      return response.data;
    },

    async initTemplateList(id) {
      let templateData = await this.getTemplateData(id);
      const listInfoCategory = await this.getListInfoCategory(id);
      this.displayItemList = [];

      if (!templateData || templateData.length === 0) {
        this.displayItemList = [];
        return;
      }

      // 現在のレコードの表示項目情報を取得する。
      const dispItemInfo = JSON.parse(this.editRecord.dispItemInfo);
      // prevEditRecordにdispItemInfoを格納
      if (this.editRecord.templateCd !== PAT_INFO_TEMPLATE_CD && dispItemInfo.length > 0) {
        const editObj = {
          templateCd: this.editRecord.templateCd,
          dispItemInfo: this.editRecord.dispItemInfo
        };
        this.getPrevEditRecord.push(editObj);
        this.setPrevEditRecord([...this.getPrevEditRecord]);
      }

      const listCategoryCd = [];
      let dispCategoryList = [];
      if (this.getPrevEditRecord && this.getPrevEditRecord.length) {
        const findItem = this.getPrevEditRecord.find(
          ele => ele.templateCd === this.editRecord.templateCd
        );
        if (findItem) {
          dispCategoryList = JSON.parse(findItem.dispItemInfo);
        }
      }
      templateData.forEach(data => {
        const categoryCd = data.categoryCd;
        if (listCategoryCd.includes(categoryCd)) {
          return;
        }
        listCategoryCd.push(categoryCd);

        // 指定されたカテゴリーコードに該当する項目をフィルタする。
        const listItems = templateData.filter(t => t.categoryCd === categoryCd);
        const listItemsOfCategory = [];
        if (listItems && listItems.length) {
          listItems.forEach(l => {
            const displayName = !l.displayName ? "" : l.displayName.trim();
            let items = l.items;
            items.forEach(i => {
              i.name = this.formatName(i, displayName);
              i.dataListDetailCd = l.dataListDetailCd;
              i.dispOrder = l.dispOrder;
              i.categoryCd = categoryCd;
              i.isChecked = false;
            });
            this.setCheckedItem(dispCategoryList, items);
            listItemsOfCategory.push(items);
          });
          const categoryInfo = listInfoCategory.find(
            c => c.categoryCd === categoryCd
          );
          let categoryItem = _.flatten(listItemsOfCategory);
          categoryItem.sort((a, b) => {
            if (a.categoryCd > b.categoryCd) return 1;
            if (a.categoryCd < b.categoryCd) return -1;

            if (a.dispOrder > b.dispOrder) return 1;
            if (a.dispOrder < b.dispOrder) return -1;
          });
          let obj = {
            categoryItem,
            categoryTitle: categoryInfo ? categoryInfo.categoryName : "",
            dispCategoryOrder: categoryInfo ? categoryInfo.dispOrder : 0,
            categoryCd,
            isChecked: false
          };
          this.displayItemList.push(obj);
          this.displayItemList.sort((a, b) => {
            if (a.dispCategoryOrder < b.dispCategoryOrder) return -1;
            if (a.dispCategoryOrder > b.dispCategoryOrder) return 1;
          });
          this.setOriginalList(deepCopy(this.displayItemList));
          this.oriList = deepCopy(this.getOriginalList); // add チェックするときに応答が遅いことを対応 劉
        }
      });
      //カテゴリの並び替えができない修正  xmj start
      if(this.templateCdcopy == this.editRecord.templateCd && this.templateCdcount == 0){
      this.dispItemInfo= JSON.parse(this.editRecord.dispItemInfo);
      for(let i=0;i<this.dispItemInfo.length;i++){
      for(let j=0;j<this.displayItemList.length;j++){
      for(let z=0;z<this.displayItemList[j].categoryItem.length;z++){
      if(this.dispItemInfo[i].data_list_detail_cd ==this.displayItemList[j].categoryItem[z].dataListDetailCd){
         this.displayItemListcopy.push(this.displayItemList[j]);
         this.displayItemList = this.displayItemList.filter(i => i!=this.displayItemList[j]);
         this.templateCdcount = this.templateCdcount+1;
         break;
            }
          }
       }
    }
      this.displayItemList= this.displayItemListcopy.concat(this.displayItemList);
    }
       //カテゴリの並び替えができない修正  xmj end
      this.sortSelect();
      this.setSort();
    },
    sortSelect() {
      let dispInfo = JSON.parse(this.editRecord.dispItemInfo);
      let dispList = deepCopy(this.displayItemList);
      dispList.map(item => {
        let categoryItem = item.categoryItem;
        let select = [];
        let unSelect = deepCopy(item.categoryItem);
        dispInfo.forEach(info => {
          categoryItem.forEach(e => {
            if (categoryItem.findIndex(x => x.dataListDetailCd === info.data_list_detail_cd) > 0) {
              if (info.data_list_detail_cd === e.dataListDetailCd && select.findIndex(i => i.id === info.id) === -1) {
                select.push(e);
              }
              unSelect = unSelect.filter(i => i.dataListDetailCd !== info.data_list_detail_cd);
            }
          });
        });
        item.categoryItem = select.concat(unSelect);
      })
      dispInfo = dispInfo.filter(item => item.items[0] !== 0);
      dispList.map(item => {
        let categoryItem = item.categoryItem;
        let select = [];
        let unSelect = deepCopy(item.categoryItem);
        dispInfo.forEach(info => {
            if (
            //#6792 リマスターは別のcategoryItemで同じid,dataListDetailCdが違っても保存可能     ljg start
            categoryItem.findIndex(e =>e.dataListDetailCd === info.data_list_detail_cd) > -1 &&
            //#6792 リマスターは別のcategoryItemで同じid,dataListDetailCdが違っても保存可能     ljg  end
            categoryItem.findIndex(e => e.id === info.items[0]) > -1) {
            let dyItem = deepCopy(info.items);
            categoryItem.forEach(e => {
              let index = dyItem.findIndex(a => a === e.id);
              if (index > -1) {
                dyItem[index] = e;
              }
            });
            select = dyItem;
            info.items.forEach(t => {
              unSelect = unSelect.filter(i => i.id !== t);
            });
          }
        });
        item.categoryItem = select.concat(unSelect);
      });
      this.displayItemList = dispList;
    },
    formatName(item, displayName) {
      let strName = "";
      if (!displayName && item.id !== 0) {
        return strName;
      }
      if (item.id === 0) {
        return (strName = item.name);
      }

      strName = displayName;
      Object.keys(item).forEach(key => {
        if (!displayName.includes(key)) return;

        strName = strName.split(`[${key}]`).join(item[key]);
      });
      return strName.trim();
    },

    setCheckedItem(dispCategoryList, listItems) {
      listItems.forEach(item => {
        dispCategoryList.forEach(category => {
          // mod redmine バイタル・モニタ項目追加マスタ改修成name 宋qy start
          if (category.data_list_detail_cd == "1095" || category.data_list_detail_cd == "1097") {
            // mod #10077 by zhangruixue 2024-01-04 --start
            // if (
            //   category.items.includes(item.name) &&
            //   category.data_list_detail_cd === item.dataListDetailCd
            // )
              if (
              category.items.includes(item.id + 10000 + '') &&
              category.data_list_detail_cd === item.dataListDetailCd
            ) {
              item.isChecked = true;
            }
            // mod #10077 by zhangruixue 2024-01-04 --end
          } else {
            if (
              category.items.includes(item.id) &&
              category.data_list_detail_cd === item.dataListDetailCd
            ) {
              item.isChecked = true;
            }
          }
          // mod redmine バイタル・モニタ項目追加マスタ改修成name 宋qy end
        });
      });
    },

    async getListInfoCategory(templateCd) {
      let url = `mstInfo/sysDataListCategory/getByTemplate/${templateCd}`;
      let response;
      // 共通ローダー表示
      this.setLoadingScreenVisible(true);
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('DynamicTemplateMasterComponent.vue', 'getListInfoCategory', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.setLoadingScreenVisible(false);
        this.internalServerError(error);
      }
      return response.data;
    },

    onFilterItems(text) {
      let copyList = deepCopy(this.getOriginalList);
      if (!text) {
        this.displayItemList = deepCopy(copyList);
        return;
      }
      copyList.forEach(category => {
        category.categoryItem = category.categoryItem.filter(item =>
          item.name.toLowerCase().includes(text)
        );
      });
      copyList = copyList.filter(category => {
        if (
          category.categoryTitle.toLowerCase().includes(text) ||
          category.categoryItem.length > 0
        ) {
          return true;
        }
        return false;
      });
      this.displayItemList = deepCopy(copyList);
    },

    mappingOriginalList(categoryCd,item) {
      // mod add チェックするときに応答が遅いことを対応 劉 start
      // let oriList = this.getOriginalList;
      //
      // if (oriList.length === 0) return;
      //
      // const oriCategoryIndex = oriList.findIndex(
      //   oriCategory => oriCategory.categoryCd === categoryCd
      // );
      //
      // if (oriCategoryIndex === -1) return;
      //
      // const oriItemIndex = oriList[
      //   oriCategoryIndex
      //   ].categoryItem.findIndex(oriItem => _.isEqual(oriItem, item));
      // if (oriItemIndex >= 0) {
      //   oriList[oriCategoryIndex].isChecked = true;
      //   oriList[oriCategoryIndex].categoryItem[oriItemIndex] = item;
      // }
      // this.setOriginalList(oriList);

      if (this.oriList.length === 0) return;

      const oriCategoryIndex = this.oriList.findIndex(
        oriCategory => oriCategory.categoryCd === categoryCd
      );

      if (oriCategoryIndex === -1) return;


      const oriItemIndex = this.oriList[
        oriCategoryIndex
        ].categoryItem.findIndex(oriItem => _.isEqual(oriItem, item));
      if (oriItemIndex >= 0) {
        this.oriList[oriCategoryIndex].isChecked = true;
        this.oriList[oriCategoryIndex].categoryItem[oriItemIndex] = item;
      }
      // mod チェックするときに応答が遅いことを対応 劉 end
    },

    internalServerError(error) {
      console.log(error);
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー"
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
    },

    removeCheck() {
      //マルチ患者一覧の設定項目を定義ファイルから取得(全ての項目を取得)
      // this.displayItemList = mstPatListLayoutDefine;

      //すべての項目のチェックボックスを外す
      this.displayItemList.forEach(category => {
        category.categoryItem = category.categoryItem.map(item => {
          return { ...item, isChecked: false };
        });
      });

      this.originalList = deepCopy(this.displayItemList);
    },
    setSort() {
      if (!this.editRecord.dispItemInfo || this.editRecord.dispItemInfo.length === 0) {
        //全ての項目のチェックを外す
        this.removeCheck();
      } else {
        //ストアに格納してある、表示項目リストを取得(各カテゴリと表示する項目のみ格納されている)
        const dispCategoryList = JSON.parse(this.editRecord.dispItemInfo);
        /*ストアの表示項目リストが存在しているか判定*/
        if (dispCategoryList.length === 0) {
          //全ての項目のチェックを外す
          this.removeCheck();
        } else {
          const sortCheckedItemList = [];
          const uncheckedItemList = [];
          let list = deepCopy(this.displayItemList)
          for (const multiPatDefine of list) {
            const categoryItem = multiPatDefine.categoryItem;
            for (const category of categoryItem) {
              let exist = false;
              for (const dispCategory of dispCategoryList) {
                if (category.dataListDetailCd === dispCategory.data_list_detail_cd) {
                  exist = !exist;
                  break;
                }
              }
              if (exist) {
                let checkItem = [];
                let uncheckItem = [];
                for (const dispCategory of dispCategoryList) {
                  for (const item of categoryItem) {
                    if (item.dataListDetailCd === dispCategory.data_list_detail_cd) {
                      checkItem.push(item);
                      // del redmine 障害票一覧_マスタNo43データリストレイアウトマスタ詳細画面全选bug對應 宋qy start
                      // item.isChecked = true;
                      // del redmine 障害票一覧_マスタNo43データリストレイアウトマスタ詳細画面全选bug對應 宋qy end
                    }
                  }
                }
                uncheckItem = this.getArrDifference(categoryItem, checkItem);
                uncheckItem.forEach(i => i.isChecked = false);
                multiPatDefine.categoryItem = checkItem.concat(uncheckItem);
                sortCheckedItemList.push(multiPatDefine);
                break;
              } else {
                uncheckedItemList.push(multiPatDefine);
                break;
              }
            }
          }
          this.displayItemList = sortCheckedItemList.concat(uncheckedItemList);
          this.originalList = deepCopy(this.displayItemList);
        }
      }
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      this.initDisplayItemList = JSON.parse(JSON.stringify(this.displayItemList));
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
    },
    getArrDifference(arr1, arr2) {
      return arr1.concat(arr2).filter(function(v, i, arr) {
        return arr.indexOf(v) === arr.lastIndexOf(v);
      });
    },
    changeButton() {
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      if (JSON.stringify(this.displayItemList) !== JSON.stringify(this.initDisplayItemList)) {
        EventBus.$emit("mstHolidayRegistered", false);
      } else {
        EventBus.$emit("mstHolidayRegistered", true);
      }
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
    }
  },

  async created() {
    this.templateCdcopy=this.editRecord.templateCd;
    await ApiHelper.get(
      `/master_maintenance/${'mst_mainte_layout'}/data/${this.getFacilitySwitch}`
    ).then(response => {
      this.mstMainteLayoutData = response.data.localDataSource.data
    });

    await ApiHelper.get(
      `/master_maintenance/${'mst_mainte_layout_group'}/data/${this.getFacilitySwitch}`
    ).then(response => {
      this.mstMainteLayoutGroupData = response.data.localDataSource.data
    });

    this.mstMainteLayoutData = this.mstMainteLayoutData.filter(data => data.layoutClass === "1");
    EventBus.$on("filterItems", this.onFilterItems);
  },

  beforeDestroy() {
    EventBus.$off("filterItems", this.onFilterItems);
  }
};
</script>
<style scoped>
.disp-item-area {
  display: block;
  overflow-y: hidden;
}
.category-handle,
.column-handle {
  cursor: move;
  float: right;
}
/* カテゴリをドラック時、カテゴリの欄を小さくする*/
.layout-category-dragging {
  height: 30px;
}
.word-border {
  border: 1px solid #d3d3d3;
  padding: 2px;
  margin-bottom: -1px;
}
.word-border-item {
  border-left: unset;
  border-right: unset;
}
.reset-size {
  width: unset;
  height: unset;
}
.category-border:last-child {
  border-bottom: 1px solid #d3d3d3;
}
.category-handle,
.column-handle {
  cursor: move;
  float: right;
}
/* カテゴリをドラック時、カテゴリの欄を小さくする*/
.layout-category-dragging {
  height: 30px;
}
/* カテゴリをドラック時、項目を見えなくする*/
.layout-column-dragging {
  display: none;
}
ons-row {
  height: auto;
}
/* ドロップしている要素 */
.ghost {
  opacity: 0.5;
}
/* ドラッグしている要素*/
.drag {
  display: none;
}
</style>
