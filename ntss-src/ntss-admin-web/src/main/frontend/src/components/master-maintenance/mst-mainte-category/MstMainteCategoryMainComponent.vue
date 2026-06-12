/**
 * 日常・定期点検項目グループマスタ詳細
 */
<template>
  <div ref="mainArea" class="main-area">
    <v-ons-row class="item-head">
      <v-ons-col class="item-title">グループ名</v-ons-col>
      <v-ons-col class="item-data list-input">
        <input
          type="text"
          v-model="getEditRecord.name"
          class="custom-input-number drug-group-name"
          style="width: 30%; vertical-align: inherit; margin-bottom: 4px;"
          @input="isCheckAll"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="item-head">
      <v-ons-col class="item-title">用途</v-ons-col>
      <v-ons-col class="item-data list-input">
        <v-ons-select
          v-model="mainteClass"
          style="width: 30%;"
          @change="isCheckAll"
        >
          <option
            v-for="(item, index) in mainteClassList"
            :key="index"
            :value="item.value"
          >{{ item.text }}</option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row v-show="isMainteClassDaily" class="item-head">
      <v-ons-col class="item-title">装置型式</v-ons-col>
      <v-ons-col class="item-data list-input">
        <kendo-multiselect
          v-if="isMachineDataReady"
          :data-source="listMachineData"
          data-text-field="textMachine"
          data-value-field="valueMachine"
          v-model="typeInfo"
          placeholder="すべて"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="setInfo-list print-height-auto">
      <v-ons-col class="item-title">グループ情報</v-ons-col>
      <v-ons-col class="item-data list-input data-table">
        <div
          class="disp-item-content-area print-height-auto"
          style="overflow: auto;"
          :style="heightStyles"
        >
          <table
            class="ntss-list sticky_table"
            style="position: relative; table-layout: fixed;"
          >
            <thead display="block">
              <tr>
                <th
                  style="z-index: 5; white-space: normal; text-align: center; width: 5%;"
                  class="ntss-list-header-th-sticky"
                >
                  <v-ons-checkbox
                    v-if="isMainteClassDaily"
                    v-model="checkAll"
                    @change="checkAllItem"
                  />
                  <v-ons-checkbox
                    v-if="isMainteClassPeriodic"
                    v-model="checkAll2"
                    @change="checkAllItem"
                  />
                </th>
                <th class="ntss-list-header-th-sticky">内容1</th>
                <th class="ntss-list-header-th-sticky">内容2</th>
                <th class="ntss-list-header-th-sticky">内容3</th>
              </tr>
            </thead>
            <draggable
              v-model="detailList"
              tag="tbody"
              :animation="250"
              :forceFallback="true"
              dragClass="drag"
              ghostClass="ghost"
              handle=".column-handle"
              @change="isCheckAll"
            >
              <template v-for="(item, index) in detailList" :key="index">
                <tr
                  v-if="item.mainteClass === mainteClass"
                 
                  class="layout-item"
                >
                  <td class="ntss-list-body-td td-select">
                    <ons-checkbox
                      ref="checkboxlist"
                      :checked="isDispOn(item.isDisp)"
                      v-model="item.isDisp"
                      @change="onCheck($event, item)"
                    />
                  </td>
                  <td class="ntss-list-body-td"><span>{{ item.mainteContent1 }}</span></td>
                  <td class="ntss-list-body-td"><span>{{ item.mainteContent2 }}</span></td>
                  <td class="ntss-list-body-td">
                    <v-ons-row>
                      <v-ons-col style="max-width: 95%;">
                        <span>{{ item.mainteContent3 }}</span>
                      </v-ons-col>
                      <v-ons-col style="max-width: 5%; text-align: right;">
                        <v-ons-icon icon="fa-bars" class="column-handle" />
                      </v-ons-col>
                    </v-ons-row>
                  </td>
                </tr>
              </template>
            </draggable>
          </table>
        </div>
      </v-ons-col>
    </v-ons-row>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import { sendRequestFindRecordListByFacilityCd } from "@/apis/master-maintenance";
import { sendRequestGetLayoutWithCategoryCd } from "@/apis/daily-check";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { alertByKey } from "@/functions/common/OnsenFunctions";
import { EventBus } from "@/compat/vue/event-bus.js";
import { cloneDeep, isEqual } from "@/compat/collections/lodash";
import {
  MainteClass,
  MainteClassList,
} from "@/constants/mainteConstants";
import { getModalBodyElement, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";

// isDispの値
const IsDisp = Object.freeze({
  Off: "0",
  On: "1",
});

export default {
  components: {
    draggable: VueDraggable,
  },
  data() {
    return {
      listHeight: 710,
      detailList: [],
      detailListOrg: [],
      editRecordNameOrg: "",
      mainteClassList: MainteClassList,
      mainteClass: MainteClass.Daily,
      mainteClassOrg: MainteClass.Daily,
      listMachineData: [],
      isMachineDataReady: false,
      typeInfo: [],
      typeInfoOrg: [],
      checkAll: false,
      checkAll2: false,
      layoutList: [],
      androidFlg: false,
      iosFlg: false,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      "getFacilitySwitch",
      "getMasterRecordList",
    ]),
    ...mapGetters("mst-layout", ["getMachineTypeList"]),
    ...mapGetters("window-size", ["getWindowHeight"]),
    ...mapGetters("account-edit", ["getFontSize"]),

    heightStyles() {
      // リストの高さをCSS変数を利用して書き換え
      return { height: `${this.listHeight}px` };
    },
    isMainteClassDaily() {
      return this.mainteClass === MainteClass.Daily;
    },
    isMainteClassPeriodic() {
      return this.mainteClass === MainteClass.Periodic;
    },
    detailListForDaily() {
      return this.detailList.filter(item => item.mainteClass === MainteClass.Daily);
    },
    detailListForPeriodic() {
      return this.detailList.filter(item => item.mainteClass === MainteClass.Periodic);
    },
    detailListForMainteClass() {
      if (this.isMainteClassDaily) return this.detailListForDaily;
      if (this.isMainteClassPeriodic) return this.detailListForPeriodic;
      return [];
    },
  },
  watch: {
    // ウィンドウの高さが変更された時
    getWindowHeight() {
      this.calculateListHeight();
    },
    getFontSize() {
      this.calculateListHeight();
    },
    isMainteClassDaily() {
      // 装置型式行の表示有無が切り替わった際にグループ情報行の高さを設定しなおす
      this.$nextTick(() => {
        this.calculateListHeight();
      });
    },
    typeInfo() {
      // #9451対応時のメモ：
      // kendo-multiselect の change イベント発生の時点では
      // v-model に指定している this.typeInfo 値が更新されていないため
      // watch:typeInfo で isCheckAll を呼ぶ
      this.isCheckAll();
    },
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-layout", ["sendRequestGetMachineTypeList"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),

    calculateListHeight() {
      const mainArea = this.$refs.mainArea;
      if (mainArea) {
        // 画面の高さ
        const modalBody = getModalBodyElement(this.$el || this);
        const bodyHeight = modalBody?.clientHeight || 0;
        // ヘッダーの高さ
        const headerElements = mainArea.getElementsByClassName("item-head");
        const headHeight = Array.from(headerElements).reduce(
          (totalHeight, element) => totalHeight + element.clientHeight,
          0
        );
        // リストの高さを設定
        this.listHeight = Math.floor(bodyHeight) - Math.ceil(headHeight) - 15;
        const listElements = mainArea.getElementsByClassName("setInfo-list");
        listElements[0].style.height = `${this.listHeight + 5}px`;
      }

      if (this.androidFlg) {
        const stickyHeaders = getScopedElementsByClassName("ntss-list-header-th-sticky", this.$el || this);
        const selectElements = getScopedElementsByClassName("select", this.$el || this);
        if (stickyHeaders[0]) {
          stickyHeaders[0].style.width = "15%";
        }
        if (selectElements[2]) {
          selectElements[2].style.width = "59%";
        }
      }
    },
    isDispOn(isDisp) {
      return isDisp === IsDisp.On;
    },
    onCheck(event, targetItem) {
      this.detailList.forEach(item => {
        if (item.code === targetItem.code) {
          item.isDisp = event.target.checked ? IsDisp.On : IsDisp.Off;
        }
      });
      this.isCheckAll();
    },
    checkAllItem() {
      this.detailList = this.detailList.map(item => {
        const res = { ...item };
        if (item.mainteClass === this.mainteClass) {
          if (this.isMainteClassDaily) {
            res.isDisp = this.checkAll ? IsDisp.Off : IsDisp.On;
          } else if (this.isMainteClassPeriodic) {
            res.isDisp = this.checkAll2 ? IsDisp.Off : IsDisp.On;
          }
        }
        return res;
      });
      this.isCheckAll();
    },
    isCheckAll() {
      // 全選択チェックボックスのチェック状態更新
      [this.checkAll, this.checkAll2] = [
        this.detailListForDaily,
        this.detailListForPeriodic
      ].map(detailList => detailList.every(
        item => this.isDispOn(item.isDisp)));

      // 変更有無判定
      const allFlag = (
        this.editRecordNameOrg === this.getEditRecord.name
        && this.mainteClassOrg === this.mainteClass
        && isEqual(this.detailListOrg, this.detailListForMainteClass)
        && (
          this.isMainteClassPeriodic
          || isEqual(this.typeInfoOrg, this.makeTypeInfo())));
      EventBus.$emit("mstHolidayRegistered", allFlag);
    },
    isTypeOverlapped() {
      // 日常点検用でない場合は対象型式の重複判定対象外
      if (!this.isMainteClassDaily) return false;
      // 編集中のグループマスタが新規レコードである、もしくは
      // 編集中のグループを持つレイアウトマスタが存在しないために
      // レイアウトマスタ情報のリストが0件の場合は対象型式の重複はない
      if (!this.layoutList.length) return false;

      // 各レイアウトマスタ内のグループ間で対象型式の重複が発生しているか判定する
      const { code } = this.getEditRecord;
      const typeOverlapped = this.layoutList.some(layout => {
        if (!layout.detailInfo1) return false;
        // レイアウトが持つグループのリストから編集中のグルーㇷ゚以外のコードを取得
        const detailInfo = JSON.parse(layout.detailInfo1);
        const otherCategoryCdList = [];
        detailInfo.forEach(({ isDisp, cd }) => {
          if (isDisp && cd !== code) {
            otherCategoryCdList.push(cd);
          }
        });
        // 他のグループと編集中のグルーㇷ゚の対象型式で重なるものが存在するか判定する
        return otherCategoryCdList.some(cd => {
          // 他のグループの対象型式の情報もマスタメンテで編集中の状態を使用する
          const otherCategory = this.getMasterRecordList.data.find(
            record => (
              record.code === cd
              && record.mainteClass === MainteClass.Daily));
          if (!otherCategory?.detail) return false;
          const detailObject = JSON.parse(otherCategory.detail);
          // グループの detail に type_info がない、もしくは
          // 空配列の場合は「すべて」として処理する
          const otherTypeInfo = Array.isArray(detailObject) ? null : detailObject.type_info;
          return (
            !otherTypeInfo?.length
            || !this.typeInfo.length
            || otherTypeInfo.some(typeCd => this.typeInfo.includes(typeCd))
          );
        });
      });
      return typeOverlapped;
    },
    validateOnRegistration() {
      // （日常点検用の場合に）各レイアウトマスタ内のグループ間で
      // 対象型式の重複が発生しているか判定する
      if (this.isTypeOverlapped()) {
        // title: "装置型式重複",
        // message: "編集した装置型式が、日常・定期点検レイアウトマスタで重複しています。\n重複した場合は後に編集したものが優先されます。\n装置型式または日常・定期点検レイアウトマスタを見直してください。\n",
        alertByKey("00200166");
        // #9451対応時のメモ：
        // validateOnRegistration の仕組みは非同期処理に対応していないため
        // 確定処理自体はキャンセルしない場合は
        // アラートダイアログを表示してもそのまま確定処理が進行してリスト画面に戻ることになるが、
        // 対象型式の重複チェックについてはその動作でよいことは確認済
      }

      const detailList = this.detailListForMainteClass.map(item => {
        const { code, isDisp, mainteClass } = item;
        return { code, isDisp, mainteClass };
      });
      // #9451対応時のメモ：
      // mainteClass に応じて日常点検なら detailList から作った配列と
      // typeInfo から作ったオブジェクト、
      // 定期点検なら従来通り detailList から作った配列のJSONを
      // detail に入れる値として生成する
      const detail = JSON.stringify(this.isMainteClassDaily ? {
        detail_list: detailList,
        type_info: this.makeTypeInfo(),
      } : detailList);
      this.setEditRecord({
        ...this.getEditRecord,
        mainteClass: this.mainteClass,
        detail,
      });
      return true;
    },
    applyEditRecord(detailMstData) {
      this.mainteClass = this.getEditRecord.mainteClass || MainteClass.Daily;

      this.detailList = [];
      this.typeInfo = [];
      if (detailMstData && this.getEditRecord.detail) {
        // #9451対応時のメモ：
        // this.getEditRecord.detail が配列かオブジェクトかを判定する
        // 配列なら従来通り detailList として使用し typeInfo は [] とする
        // オブジェクトならその中の detail_list と type_info を それぞれ
        // detailList と typeInfo として使用する
        const detailObject = JSON.parse(this.getEditRecord.detail);
        const [detailList, typeInfo] = Array.isArray(detailObject)
          // 点検項目の配列のみが入っている場合
          ? [detailObject, []]
          // 点検項目の配列と対象型式の配列が入っている場合
          : [detailObject.detail_list, detailObject.type_info];
        detailList.forEach(item => {
          const { code, isDisp } = item;
          const detailMstItem = detailMstData.find(
            mstItem => mstItem.code === code
          );
          if (!detailMstItem) return;
          const {
            mainteContent1,
            mainteContent2,
            mainteContent3,
            mainteClass,
          } = detailMstItem;
          this.detailList.push({
            code,
            mainteContent1,
            mainteContent2,
            mainteContent3,
            mainteClass,
            isDisp,
          });
        });
        detailMstData.forEach(mstItem => {
          if (this.detailList.some(detail => detail.code === mstItem.code)) return;
          const {
            code,
            mainteContent1,
            mainteContent2,
            mainteContent3,
            mainteClass,
          } = mstItem;
          this.detailList.push({
            code,
            mainteContent1,
            mainteContent2,
            mainteContent3,
            mainteClass,
            isDisp: IsDisp.Off,
          });
        });

        this.typeInfo.push(...this.makeTypeInfo(typeInfo));
      }

      // 編集前の状態を記録
      this.editRecordNameOrg = this.getEditRecord.name
      this.mainteClassOrg = this.mainteClass
      this.detailListOrg = cloneDeep(this.detailListForMainteClass);
      this.typeInfoOrg = [...this.typeInfo];

      // #9451対応時のメモ：
      // この関数では各種入力状態を持つdata項目の値を更新するので
      // 本来は最後に isCheckAll も実行する必要があるが
      // この関数で this.typeInfo が設定されなおすことで
      // その後 watch:typeInfo によって isCheckAll が呼ばれる
    },
    // 型式配列を型式の選択肢順に並べなおした配列を生成する
    makeTypeInfo(typeInfo = this.typeInfo) {
      const result = [];
      this.listMachineData.forEach(({ valueMachine }) => {
        if (typeInfo.includes(valueMachine)) {
          result.push(valueMachine);
        }
      });
      return result;
    },
    // 編集対象のグループを持つ日常点検用の点検レイアウトマスタのリストを取得する
    async getLayoutWithCategoryCd() {
      this.layoutList.splice(0);
      const { code, isAddRow } = this.getEditRecord;
      // 編集対象のグループマスタが新規レコードの場合はレイアウトリストの取得は不要
      if (isAddRow) return;
      // 点検グループマスタの用途は変更可能なので
      // 画面開始時の用途によらず、対象のグループコードを持つ
      // 日常点検用の点検レイアウトマスタ情報を取得しておく
      const response = await sendRequestGetLayoutWithCategoryCd(code);
      this.layoutList = response.data;
    },
  },
  async created() {
    this.setLoadingScreenVisible(true);

    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }

    // マスタデータを取得
    const [response] = await Promise.all([
      sendRequestFindRecordListByFacilityCd(
        "mst_mainte_detail",
        this.getFacilitySwitch
      ),
      this.getLayoutWithCategoryCd(),
      this.sendRequestGetMachineTypeList(),
    ]).catch(error => {
      getErrorMessage("MstMainteCategoryMainComponent.vue", "created", error);
      this.setLoadingScreenVisible(false);
      throw error;
    });
    // 取得したマスタデータを加工
    const detailMstData = response.data?.localDataSource.data.filter(
      mstItem => this.isDispOn(mstItem.isDisp)
    );
    this.listMachineData = this.getMachineTypeList.map(item => ({
      textMachine: item.machineType,
      valueMachine: item.machineTypeCd,
    }));
    this.isMachineDataReady = true;

    // #9451対応時のメモ：
    // kendo-multiselect の data-source に指定している
    // this.listMachineData の内容を作成した後、
    // nextTick を待ってから v-model に指定している this.typeInfo の値を設定しないと
    // 画面上未選択のままになるため applyEditRecord を呼ぶ前に nextTick を待つ
    await this.$nextTick();
    // 編集対象データから入力状態を初期化する
    this.applyEditRecord(detailMstData);

    this.setLoadingScreenVisible(false);
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateListHeight();
    });
  },
};
</script>

<style scoped>
@media print {
  .setInfo-list, .disp-item-content-area {
    height: auto !important;
  }
  .print-height-auto {
    height: auto !important;
  }
}
.setInfo-list {
  height: 74vh;
  border: 1px solid;
}
.category-handle,
.column-handle {
  cursor: move;
}
.ghost {
  opacity: 0.5;
}
.main-area {
  overflow: hidden;
}
.drag {
  display: none;
}
table {
  border-collapse: collapse;
}
.list-input {
  flex: 0 0 83%;
}
.list-input input {
  width: 70%;
}
.item-button {
  width: 60px;
  padding: 0;
  margin-left: 2px;
}
.layout-item-fallback {
  max-height: 26px;
}
.layout-item {
  border-bottom: 1px solid #999;
  transition: max-height 500ms;
  overflow: hidden;
  max-height: 99999px;
}
.select-button {
  width: 50px;
  padding: 1px;
  margin: 2px 0 0 2px;
  margin: auto 5px;
  max-height: 34px;
}
.flex-container {
  padding: 2px 5px;
  height: auto;
  align-items: flex-start;
}
.ntss-list-body-td span {
  display: block;
	word-break: keep-all;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	-o-text-overflow: ellipsis;
	-icab-text-overflow: ellipsis;
	-khtml-text-overflow: ellipsis;
	-moz-text-overflow: ellipsis;
	-webkit-text-overflow: ellipsis;
}

/* 項目名 */
.item-title {
  width: 10%;
  max-width: 17%;
  margin-left: 5px;
}
.data-table {
  display: block;
  overflow-x: auto;
}
.data-table :deep(ons-row ons-col) {
  white-space: normal;
}
.drug-group-name {
  max-width: 440px;
  min-width: 140px;
}
@media screen and (min-width: 376px) and (max-width: 667px) {
  .setInfo-list {
    height: 35vh;
  }
}
@media screen and (max-width: 667px) {
  .item-title {
    width: 10%;
    max-width: 33%;
    margin-left: 5px;
  }
  .list-input {
    flex: 0 0 67%;
  }
}
#destination-group-modal-content {
  height: 100%;
}
#sys-facility-search-wrapper {
  font-size: 1.4em;
}
.sticky_table {
  overflow: auto;
}
.td-select {
  text-align: center;
  z-index: 2;
  background-color: var(--ntss-list-background-color);
}
</style>
