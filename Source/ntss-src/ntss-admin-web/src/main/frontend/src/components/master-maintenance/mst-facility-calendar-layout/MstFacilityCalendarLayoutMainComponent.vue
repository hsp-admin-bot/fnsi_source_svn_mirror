<template>
  <div class="main-area">
    <table class="disp-item-area">
      <tr>
        <td class="layout-name-area" height="30">レイアウト名</td>
        <td>
          <input
            :value="editRecord.name"
            class="k-textbox custom-k-textbox"
            @blur="setLayoutName($event.target.value)"
          />
        </td>
      </tr>
      <!-- add 施設カレンダーレイアウトマスタ モーダルの見た目修正 孔s start -->
      <tr>
        <td height="30">
          <v-ons-col class="color-header">
          </v-ons-col>
        </td>
        <td>
          <v-ons-col class="color-header">
              項目名
            </v-ons-col>
        </td>
      </tr>
      <!-- add 施設カレンダーレイアウトマスタ モーダルの見た目修正 孔s end -->
      <tr>
        <td class="disp-item-name-area">
          <label>
            <v-ons-checkbox
              @change="checkAllItem"
              v-model="checkAll"
            />
            表示項目
          </label>
        </td>
        <td>
          <div class="disp-item-content-area">
            <draggable
              v-model="displayItemList"
              :options="{ ...dragOptions, handle: '.column-handle' }"
              @change="editListData"
            >
              <v-ons-row
                v-for="(item, index) in displayItemList"
                :key="index"
                :class="{ 'layout-item-dragging': isDraggingCategory }"
                class="layout-item"
                @change="editListData"
              >
                <v-ons-col class="flex-container">
                  <label>
                    <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start-->
                    <!-- <v-ons-checkbox
                      @change="changeButton"
                      v-model="item.isDisp"
                    /> -->
                    <v-ons-checkbox
                      v-model="item.isDisp"
                    />
                    <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end-->
                    {{ item.title }}
                  </label>
                  <v-ons-icon icon="fa-bars" class="column-handle" />
                </v-ons-col>
              </v-ons-row>
            </draggable>
          </div>
        </td>
      </tr>
    </table>
  </div>
</template>

<script>
import { mstFacilityCalendarLayoutDefine } from "@/constants/mstFacilityCalendarLayoutDefine";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
// mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end

export default {
  components: {
    draggable: VueDraggable
  },

  data() {
    return {
      //患者カレンダー一覧の設定項目
      displayItemList: [],
      initName:"",
      // ドラッグ時の詳細設定
      dragOptions: {
        animation: 250, //drag時の速度
        forceFallback: true, //trueにすると、draggable用のDnDが作動するようになる
        dragClass: "drag", //ドラッグ時のクラス名
        ghostClass: "ghost" //ドロップ時のクラス名
      },
      //カテゴリをドラッグしているかのフラグ
      isDraggingCategory: false,
      dataMst: [],
      checkAll: false,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
      displayItemListDefault:[],
      displayItemListNew:[]
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end
    };
  },

  computed: {
    ...mapGetters("master-maintenance", {editRecord: "getEditRecord", getFacilitySwitch: "getFacilitySwitch"})
  },

  async created() {
    this.setLoadingScreenVisible(true);
    await this.getDataMst();
    /**
     * @description 患者カレンダー一覧の設定項目に表示フラグを付与し、表示設定された項目はストアに格納された順番で画面に表示
     */
    /*新規登録か否か確認*/
    if (
      !this.editRecord.dispItemInfo ||
      JSON.parse(this.editRecord.dispItemInfo).length === 0 ||
      typeof JSON.parse(this.editRecord.dispItemInfo)[0] !== "object"
    ) {
      this.displayItemList.push(
        ...mstFacilityCalendarLayoutDefine,
        ...this.dataMst
      );
      this.displayItemList.forEach(i => {
        i.isDisp = false
      });
    } else {
      // mod 施設カレンダーレイアウトマスタ No.11 No.12 障害対応 start
      // const removeItems = JSON.parse(this.editRecord.dispItemInfo)
      //   .filter(i => i.cd)
      //   .filter(i =>
      //     !this.dataMst.some(
      //       j => i.cd === j.cd &&
      //       i.key === j.key)
      //   );
      // const listCd = new Set(JSON.parse(this.editRecord.dispItemInfo).map(i => i.cd));
      // this.displayItemList = [
      //   ...JSON.parse(this.editRecord.dispItemInfo),
      //   ...this.dataMst.filter(d => !listCd.has(d.cd))
      // ].filter(i =>
      //   !removeItems.some(
      //     j => i.cd === j.cd &&
      //     i.key === j.key
      //   )
      // );
      const deletedItems = JSON.parse(this.editRecord.dispItemInfo)
        .filter(i => i.cd && i.isDisp === true)
        .filter(i =>
          !this.dataMst.some(
            j => i.cd === j.cd &&
            i.key === j.key)
        );
      this.displayItemList = [
        ...JSON.parse(this.editRecord.dispItemInfo).filter(i => !i.cd),
        ...this.dataMst.map(i =>{
            return {
              isDisp: this.checkdSelected(i.key, i.cd),
              key: i.key,
              shortTitle: i.shortTitle,
              title: i.title,
              cd: i.cd,
            }
          }
        ),
        ...deletedItems
      ]
      // mod 施設カレンダーレイアウトマスタ No.11 No.12 障害対応 end
    }
    this.checkAll = this.displayItemList.filter(i => i.isDisp === true).length === this.displayItemList.length;
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
    this.displayItemListDefault = cloneDeep(this.displayItemList)
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end
  },

  mounted() {
    this.$el.parentElement.style.height = "100%";
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
    this.initName = this.editRecord.name;
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),

    // add 施設カレンダーレイアウトマスタ No.11 No.12 障害対応 start
    checkdSelected(paramKey, paramCode){
      if (!paramKey || !paramCode || !this.editRecord.dispItemInfo) return false;
      return JSON.parse(this.editRecord.dispItemInfo)
        .some(i =>
          i.key === paramKey && i.cd === paramCode && i.isDisp
        );
    },
    // add 施設カレンダーレイアウトマスタ No.11 No.12 障害対応 end

    checkDefaultData(paramKey, paramCode) {
      if (!paramKey || !paramCode || !this.editRecord.dispItemInfo) return false;
      return JSON.parse(this.editRecord.dispItemInfo)
        .some(i =>
          i.key === paramKey && i.cd === paramCode
        );
    },

    async getDataMst() {
      const [
        dataPatientEventCategoryMst,
        dataPatientSubEventCategoryMst,
        // add #9552 日常点検の個別選択ができない 商 start
        dataMainteLayoutMst,
        // add #9552 日常点検の個別選択ができない 商 end
        dataFacilityEventCategoryMst,
      ] = await Promise.all([
          // add マスタ一覧 施設切替を可能とする 王 start
          ApiHelper.get(`/master_maintenance/mst_pat_event_category/data/${this.getFacilitySwitch}`),
          ApiHelper.get(`/master_maintenance/mst_pat_event_sub_category/data/${this.getFacilitySwitch}`),
        // add #9552 日常点検の個別選択ができない 商 start
        ApiHelper.get(`/master_maintenance/mst_mainte_layout/data/${this.getFacilitySwitch}`),
        // add #9552 日常点検の個別選択ができない 商 end
          ApiHelper.get(`/master_maintenance/mst_bbs_kind/data/${this.getFacilitySwitch}`),
        // ApiHelper.get('/master_maintenance/mst_pat_event_category/data'),
        // ApiHelper.get('/master_maintenance/mst_pat_event_sub_category/data'),
        // ApiHelper.get('/master_maintenance/mst_bbs_kind/data'),
        // add マスタ一覧 施設切替を可能とする 王 end
      ]).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstFacilityCalendarLayoutMainComponent.vue', 'getDataMst', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      this.dataMst.push(
        ...dataPatientEventCategoryMst.data.localDataSource.data
          .filter(i => i.isDisp === "1")
          .map(i => {
            return {
              isDisp: this.checkDefaultData("repeat_pat_event_category", i.code),
              key: "repeat_pat_event_category",
              shortTitle: i.name,
              title: `${i.name}集計(患者イベントカテゴリ)`,
              cd: i.code,
            }
          }),
        ...dataPatientSubEventCategoryMst.data.localDataSource.data
          .filter(i => i.isDisp === "1")
          .map(i => {
            return {
              isDisp: this.checkDefaultData("repeat_pat_event_subcategory", i.code),
              key: "repeat_pat_event_subcategory",
              shortTitle: i.name,
              title: `${i.name}集計(患者イベントサブカテゴリ)`,
              cd: i.code,
            }
          }),
        // add #9552 日常点検の個別選択ができない 商 start
        ...dataMainteLayoutMst.data.localDataSource.data
          .filter(i => i.isDisp === "1" && i.layoutClass === "1" )
          .map(i => {
            return {
              isDisp: this.checkDefaultData("repeat_mainte_layout", i.code),
              key: "repeat_mainte_layout",
              shortTitle: i.layoutName,
              title: `${i.layoutName}(日常点検レイアウト)`,
              cd: i.code,
            }
          }),
        // add #9552 日常点検の個別選択ができない 商 end
        ...dataFacilityEventCategoryMst.data.localDataSource.data
          .filter(i => i.isDisp === "1")
          .map(i => {
            return {
              isDisp: this.checkDefaultData("repeat_facility_event_categories", i.code),
              key: "repeat_facility_event_categories",
              shortTitle: i.name,
              title: `${i.name}(施設イベント)`,
              cd: i.code,
            }
          })
      );
    },

    clearStore() {
      this.setEditRecord(null);
    },
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

    /**
     * @description レイアウト名変更の処理
     * @param 変更後のレイアウト名
     */
    setLayoutName(value) {
      //変更後のレイアウト名をストアに格納
      const layoutName = value;
      this.setEditRecord({ ...this.editRecord, name: layoutName });
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
      // if (layoutName!==this.initName) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end
    },

    /**
     * @description チェックを入れた項目をストアに格納する処理
     * @param 患者カレンダー一覧の設定項目
     */
    editListData() {
      this.checkAll = this.displayItemList.filter(i => i.isDisp === true).length === this.displayItemList.length;
      this.setEditRecord({
        ...this.editRecord,
        dispItemInfo: JSON.stringify(
          this.displayItemList
        )
      });
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end
    },

    validateOnRegistration() {
      const validationResult = this.displayItemList.filter(i => i.isDisp).length > 0;
      if (validationResult) {
        return true;
      }
      let message = "";
      if (!validationResult) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "項目を選んでください。";
        message = messageFormat(DIALOG_MESSAGES['00200059'].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      this.$ons.notification.alert({
        title: DIALOG_MESSAGES['00200059'].title,
        message: message
      });
      return false;
    },

    checkAllItem() {
      this.displayItemList = this.displayItemList.map(i => {
        return {...i, isDisp: !this.checkAll};
      });
      this.setEditRecord({
        ...this.editRecord,
        dispItemInfo: JSON.stringify(
          this.displayItemList
        )
      });
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end
    },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
    // changeButton() {
    //   EventBus.$emit("mstHolidayRegistered", false);
    // }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end
  },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 start
  watch:{
    editRecord:{
      handler(val){
        EventBus.$emit("mstHolidayRegistered",
        isEqualWith(JSON.stringify(this.displayItemListNew),JSON.stringify(this.displayItemListDefault))
        && isEqualWith(this.initName,val.name));
      },
      deep:true
    },
    displayItemList:{
      handler(val){
        this.displayItemListNew = val;
        EventBus.$emit("mstHolidayRegistered", isEqualWith(JSON.stringify(val),JSON.stringify(this.displayItemListDefault))
        && isEqualWith(this.initName,this.editRecord.name));
      },
      deep:true
    }
  }
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_施設カレンダーレイアウトマスタ 張玲 2024/01/04 end
};
</script>

<style scoped>
.category-handle,
.column-handle {
  cursor: move;
}

.layout-item {
  border-bottom: 1px solid #999;
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
.disp-item-name-area {
  padding-left: 8px;
  vertical-align: top;
}

.disp-item-no,
.k-textbox {
  width: 100%;
}
/* del 施設カレンダーレイアウトマスタ モーダルの見た目修正 孔s start */
/* .custom-k-textbox {
  font-size: 1.5em;
} */
/* del 施設カレンダーレイアウトマスタ モーダルの見た目修正 孔s end */

.disp-item-content-area {
  overflow-y: scroll;
  height: 100%;
}

.disp-item-area {
  height: 97%;
  width: 100%;
  border-collapse: collapse;
}

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2) {
  border: 1px solid lightgray;
  text-align: left;
}

.flex-container {
  padding: 2px 5px;
  height: auto;
  align-items: flex-start;
}
</style>
