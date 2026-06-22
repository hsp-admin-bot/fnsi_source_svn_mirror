/**
 * 日常・定期点検レイアウトマスタ詳細
 */
<template>
  <div>
    <div class="main-area">
      <v-ons-row>
        <v-ons-col
          class="word-border custom-word-border"
          :style="cateStyle"
        >レイアウト名</v-ons-col>
        <v-ons-col>
          <v-ons-input
            ref="nameInput"
            :value="getEditRecord.layoutName"
            class="custom-input-area custom-input-required"
            @change="limitNameLength($event, 265)"
            @input="setCss($event.target.value)"
            @blur="setLayoutName($event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col
          class="word-border custom-word-border"
          :style="cateStyle"
        >レイアウトヘッダー</v-ons-col>
        <v-ons-col>
          <v-ons-input
            :value="getEditRecord.layoutHeader"
            class="custom-input-area"
            @change="limitNameLength($event, 40)"
            @blur="setLayoutHeader($event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col
          class="word-border custom-word-border"
          :style="cateStyle"
        >用途</v-ons-col>
        <v-ons-col>
          <v-ons-select
            v-model="getEditRecord.layoutClass"
            class="custom-select-input-area"
            @change="changeLayoutClass"
          >
            <option
              v-for="item in mainteClassList"
              :key="item.value"
              :value="item.value"
            >{{ item.text }}</option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-show="isLayoutClassPeriodic">
        <v-ons-col class="word-border" :style="cateStyle">装置型式</v-ons-col>
        <v-ons-col>
          <kendo-multiselect
            v-if="isMachineDataReady"
            v-model="listMachineSelected"
            :data-source="listMachineData"
            data-text-field="textMachine"
            data-value-field="valueMachine"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row id="header" ref="headerRow">
        <v-ons-col class="color-header" :style="cateStyle">{{ colNames[0] }}</v-ons-col>
        <v-ons-col class="color-header">{{ colNames[1] }}</v-ons-col>
      </v-ons-row>

      <!-- 表示項目設定 -->
      <div ref="itemAreaDiv" class="disp-item-area">
        <!-- disp-item-area の height を v-ons-row に影響させないため、divで囲う -->
        <div v-if="isLayoutClassDaily">
          <v-ons-row
            v-for="item in dailyData.categories"
            :key="`${item.mainteCategoryCd}`"
          >
            <!-- 項目名 -->
            <v-ons-col
              ref="categoryCols"
              class="word-border"
              width="40%"
            >
              <!-- チェックボックス -->
              <label class="vertical-middle-flex">
                <v-ons-checkbox
                  v-model="item.isDisp"
                  :disabled="item.disabled"
                  @input="checkItem(null, item, item.isDisp)"
                />
                <!-- 項目名 -->
                {{ item.categoryName }}
              </label>
            </v-ons-col>
            <!-- 装置型式 -->
            <v-ons-col class="word-border vertical-middle-flex">
              <label>{{ item.typeName }}</label>
            </v-ons-col>
          </v-ons-row>
        </div>
        <div v-if="isLayoutClassPeriodic">
          <v-ons-row
            v-for="aData in periodicData"
            :key="aData.text"
          >
            <!-- カテゴリ名 -->
            <v-ons-col
              ref="categoryCols"
              class="word-border"
              valign="top"
              width="40%"
            >
              <!-- カテゴリ名のチェックボックス -->
              <label class="vertical-middle-flex">
                <v-ons-checkbox
                  v-model="aData.isDisp"
                  @input="checkAllItem(aData)"
                />
                <!-- カテゴリ名 -->
                {{ aData.text }}
              </label>
            </v-ons-col>
            <!-- 項目名 -->
            <v-ons-col>
              <draggable
                v-model="aData.categories"
                :animation="250"
                :forceFallback="true"
                dragClass="drag"
                ghostClass="ghost"
                handle=".column-handle"
                @change="checkChanged"
              >
                <v-ons-row
                  v-for="item in aData.categories"
                  :key="`${aData.text}-${item.mainteCategoryCd}`"
                  class="word-border"
                >
                  <v-ons-col>
                    <!-- アイコンを右寄せにするため、colで囲う -->
                    <!-- チェックボックス -->
                    <label class="vertical-middle-flex">
                      <v-ons-checkbox
                        v-model="item.isDisp"
                        @input="checkItem(aData, item)"
                      />
                      <!-- 項目名 -->
                      {{ item.categoryName }}
                    </label>
                  </v-ons-col>
                  <!-- ドラッグ用アイコン -->
                  <v-ons-icon icon="fa-bars" class="column-handle" />
                </v-ons-row>
              </draggable>
            </v-ons-col>
            <!-- 項目名ここまで -->
          </v-ons-row>
        </div>
      </div>
      <!-- 表示項目設定ここまで -->
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import { cloneDeep, isEqual } from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {
  MainteClass,
  MainteClassList,
} from "@/constants/mainteConstants";
import { getScopedElement } from "@/functions/common/LayoutMeasureHelper";

export default {
  components: {
    draggable: VueDraggable,
  },
  data() {
    const periodicInspectionData = {
      text: "定期点検記録簿",
      isDisp: false,
      categories: [],
    };
    const periodicReplaceData = {
      text: "定期交換部品記録簿",
      isDisp: false,
      categories: [],
    };
    return {
      initLayoutName: "",
      initLayoutHeader: "",
      initLayoutClass: "",
      initTypeInfo: [],
      initDetailInfoArray: [],
      mainteClassList: MainteClassList,
      listMachineData: [],
      listMachineSelected: [],
      isMachineDataReady: false,
      // 日常点検用点検項目グループ選択情報
      dailyData: {
        categories: [],
      },
      periodicInspectionData,
      periodicReplaceData,
      // 定期点検用点検項目グループ選択情報
      periodicData:[
        periodicInspectionData,
        periodicReplaceData,
      ],
      // 見出し列の幅設定用style文字列
      cateStyle: "",
      resizeObserver: null,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      "getFacilitySwitch",
    ]),
    ...mapGetters("mst-layout", [
      "getMachineTypeList",
      "getListMachine",
      "getCategoryList",
    ]),

    isLayoutClassDaily() {
      return this.getEditRecord.layoutClass === MainteClass.Daily;
    },
    isLayoutClassPeriodic() {
      return this.getEditRecord.layoutClass === MainteClass.Periodic;
    },
    colNames() {
      return this.isLayoutClassDaily ? ["項目名", "装置型式"] : ["", "項目名"];
    },
    dailyCategoryList() {
      const result = [];
      this.getCategoryList.forEach(item => {
        if (item.mainteClass !== MainteClass.Daily) return;
        const detailObj = (item.detail && JSON.parse(item.detail)) || null;
        const typeCdList = [];
        if (detailObj?.type_info) {
          typeCdList.push(...detailObj.type_info);
        }
        const typeNames = [];
        if (typeCdList.length) {
          typeCdList.forEach(typeCd => {
            const typeMst = this.getMachineTypeList.find(type => type.machineTypeCd === typeCd);
            if (!typeMst) return;
            typeNames.push(typeMst.machineType);
          });
        } else {
          // 装置型式が未指定の場合は「すべて」扱いとする
          typeCdList.push(...this.getMachineTypeList.map(type => type.machineTypeCd));
          typeNames.push("すべて");
        }
        result.push({
          ...item,
          typeCdList,
          typeName: typeNames.join(","),
        });
      });
      return result;
    },
    periodicCategoryList() {
      return this.getCategoryList.filter(
        item => item.mainteClass === MainteClass.Periodic
      );
    },
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-layout", [
      "sendRequestGetMachineTypeList",
      "sendRequestGetAllMachineByFacilityCd",
      "sendRequestGetAllCategoryByFacilityCd",
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),

    async initData() {
      // 用途選択状態の正規化
      this.getEditRecord.layoutClass = `${this.getEditRecord.layoutClass}`;
      if (!this.isLayoutClassDaily && !this.isLayoutClassPeriodic) {
        this.getEditRecord.layoutClass = MainteClass.Daily;
      }

      const convertInfo1 = (
        this.getEditRecord.detailInfo1
        && JSON.parse(this.getEditRecord.detailInfo1)) || [];
      const convertInfo2 = (
        this.getEditRecord.detailInfo2
        && JSON.parse(this.getEditRecord.detailInfo2)) || [];
      if (this.isLayoutClassDaily) {
        // 日常点検用の場合は点検項目グループの並び替え操作がないので
        // 単に点検項目グループマスタの並び順でリストを作成し、
        // detailInfo1の内容を選択状態に反映する
        this.dailyData.categories = this.dailyCategoryList.map(category => ({
          ...category,
          isDisp: false,
          disabled: false,
        }));
        convertInfo1.forEach(info => {
          if (!info.isDisp) return;
          const category = this.dailyData.categories.find(
            item => item.mainteCategoryCd === info.cd
          );
          if (!category) return;
          category.isDisp = true;
        });
        setDisabledByTypeInfo(this.dailyData);
      } else if (this.isLayoutClassPeriodic) {
        const typeInfo = (
          this.getEditRecord.typeInfo
          && JSON.parse(this.getEditRecord.typeInfo)) || [];
        this.listMachineSelected = typeInfo;

        // 定期点検用の場合は点検項目グループの並び替え操作があるので
        // detailInfo1,detailInfo2の並び順で点検項目グループマスタに
        // 含まれているもののリストを作成し、その後に
        // detailInfo1,detailInfo2に含まれていない
        // 点検項目グループマスタ項目を追加する
        [
          [convertInfo1, this.periodicInspectionData],
          [convertInfo2, this.periodicReplaceData],
        ].forEach(([convertInfo, aData]) => {
          convertInfo.forEach(info => {
            const category = this.periodicCategoryList.find(
              item => item.mainteCategoryCd === info.cd
            );
            if (!category) return;
            aData.categories.push({
              ...category,
              isDisp: info.isDisp,
            });
          });
          this.periodicCategoryList.forEach(category => {
            const exists = aData.categories.some(
              item => category.mainteCategoryCd === item.mainteCategoryCd
            );
            if (!exists) {
              aData.categories.push({
                ...category,
                isDisp: false,
              });
            }
          });
          aData.isDisp = aData.categories.every(item => item.isDisp);
        });
      }

      // 編集前の状態を記録
      this.initLayoutName = this.getEditRecord.layoutName || "";
      this.initLayoutHeader = this.getEditRecord.layoutHeader || "";
      this.initLayoutClass = this.getEditRecord.layoutClass;
      this.initTypeInfo = [];
      this.initDetailInfoArray = [];
      if (this.isLayoutClassDaily) {
        this.initDetailInfoArray = makeDetailInfoArray(this.dailyData);
      } else if (this.isLayoutClassPeriodic) {
        this.initTypeInfo = cloneDeep(this.listMachineSelected);
        this.initDetailInfoArray = makeDetailInfoArray(...this.periodicData);
      }

      // 日常点検用の場合はグループ間の対象型式重複があれば自動補正する
      if (this.isLayoutClassDaily) {
        // 選択されているグループのリストを作成
        const dispList = [];
        this.dailyData.categories.forEach(category => {
           if (!category.isDisp) return;
           dispList.push({
            category,
            upDateValue: dayjs(category.upDate).valueOf(),
           });
        });
        // グループマスタの更新日時降順＞コード降順の優先度順でソートする
        dispList.sort((a, b) => {
          const upDateDiff = b.upDateValue - a.upDateValue;
          if (upDateDiff) {
            return upDateDiff;
          }
          return b.category.mainteCategoryCd - a.category.mainteCategoryCd
        });
        // 優先度が高いものから順にそれより優先度が低いものに
        // 対象型式が重複するものがあるか判定し、
        // 重複している場合は優先度が低いものの選択を外す
        dispList.forEach((item, index) => {
          if (!item.category.isDisp) return;
          dispList.slice(index + 1).forEach(({ category }) => {
            if (!category.isDisp) return;
            if (item.category.typeCdList.some(
              type => category.typeCdList.includes(type))) {
              category.isDisp = false;
            }
          });
        });
        // チェックボックスの非活性状態を更新
        setDisabledByTypeInfo(this.dailyData);
      }

      this.checkChanged();
    },
    // 編集有無判定結果に従って確定ボタンのdisabledを設定する
    checkChanged() {
      let changed = false;

      if (
        (this.initLayoutName !== (this.getEditRecord.layoutName || ""))
        || (this.initLayoutHeader !== (this.getEditRecord.layoutHeader || ""))
        || (this.initLayoutClass !== this.getEditRecord.layoutClass)
      ) {
        changed = true;
      } else if (this.isLayoutClassDaily) {
        const detailInfoArray = makeDetailInfoArray(this.dailyData);
        if (!isEqual(this.initDetailInfoArray, detailInfoArray)) {
          changed = true;
        }
      } else if (this.isLayoutClassPeriodic) {
        if (!isEqual(this.initTypeInfo, this.listMachineSelected)) {
          changed = true;
        } else {
          const detailInfoArray = makeDetailInfoArray(...this.periodicData);
          if (!isEqual(this.initDetailInfoArray, detailInfoArray)) {
            changed = true;
          }
        }
      }

      EventBus.$emit("mstHolidayRegistered", !changed);
    },
    limitNameLength(event, maxLength) {
      const value = event.target.value = String(event.target.value);
      if (value.length > maxLength) {
        event.target.value = value.substring(0, maxLength);
      }
    },
    setLayoutName(value) {
      this.setEditRecord({ ...this.getEditRecord, layoutName: value });
      this.checkChanged();
    },
    setCss(value) {
      if (!value) return;
      const classList = this.$refs.nameInput?.$el.classList;
      if (classList?.contains("custom-input-invalid")) {
        classList.remove("custom-input-invalid");
      }
    },
    setLayoutHeader(value) {
      this.setEditRecord({ ...this.getEditRecord, layoutHeader: value });
      this.checkChanged();
    },
    changeLayoutClass() {
      if (this.isLayoutClassDaily) {
        if (this.dailyData.categories.length) {
          // すでにリストが作成済みの場合
          // 日常点検用の場合はリスト項目の並び替えがないので
          // 既存のリストのまま選択状態を初期化する
          this.dailyData.categories.forEach(item => {
            if (item.isDisp) {
              item.isDisp = false;
              item.disabled = false;
            }
          });
        } else {
          // まだリストが作成済みでない場合
          // 日常点検用の点検項目グループの選択リストを作成
          this.dailyData.categories = this.dailyCategoryList.map(category => ({
            ...category,
            isDisp: false,
            disabled: false,
          }));
        }
        setDisabledByTypeInfo(this.dailyData);
      } else if (this.isLayoutClassPeriodic) {
        // 定期点検用の点検項目グループの選択状態を初期化
        // （定期点検用の場合はリスト項目の並び替えがあるので常にリストを作り直す）
        this.periodicData.forEach(aData => {
          aData.categories = this.periodicCategoryList.map(category => ({
            ...category,
            isDisp: false,
          }));
          aData.isDisp = false;
        });
      }
      this.checkChanged();
    },
    checkAllItem(obj) {
      obj.categories.forEach(i => {
        i.isDisp = !obj.isDisp;
      });
      // #9451対応時のメモ：
      // checkAllItem は定期点検用でのみ使用される処理のため
      // 日常点検用にのみ関係する setDisabledByTypeInfo の呼び出しは行わない
      this.checkChanged();
    },
    checkItem(parent, category) {
      category.isDisp = !category.isDisp;
      if (parent) {
        parent.isDisp = parent.categories.every(item => item.isDisp);
      }
      if (this.isLayoutClassDaily) {
        setDisabledByTypeInfo(this.dailyData);
      }
      this.checkChanged();
    },
    validateData() {
      const result = {
        nameValid: true,
        machineValid: true,
        detailInfo: true,
        detailTypeInfo: true,
      };

      // 必須チェック：レイアウト名
      if (!this.getEditRecord.layoutName) {
        result.nameValid = false;
      }

      if (this.isLayoutClassDaily) {
        const [detailInfo1] = makeDetailInfoArray(this.dailyData);
        // 必須チェック：点検項目グループ選択
        result.detailInfo = isDetailInfoArrayDisp(detailInfo1);

        if (result.detailInfo) {
          // 型式重複チェック
          result.detailTypeInfo = isNotTypeInfoOverlapped(this.dailyData);
        }

        if (result.detailInfo && result.detailTypeInfo) {
          this.setEditRecord({
            ...this.getEditRecord,
            detailInfo1: JSON.stringify(detailInfo1),
            detailInfo2: null,
          });
        }
      } else if (this.isLayoutClassPeriodic) {
        // 必須チェック：装置型式選択
        if (!this.listMachineSelected.length) {
          result.machineValid = false;
        }

        // 必須チェック：点検項目グループ選択
        const [detailInfo1, detailInfo2] = makeDetailInfoArray(...this.periodicData);
        result.detailInfo = isDetailInfoArrayDisp(detailInfo1, detailInfo2);
        if (result.detailInfo) {
          this.setEditRecord({
            ...this.getEditRecord,
            detailInfo1: JSON.stringify(detailInfo1),
            detailInfo2: JSON.stringify(detailInfo2),
          });
        }
      }

      return result;
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(isValid => isValid)) {
        // 入力エラーがない場合
        return true;
      }

      if (!validationResult.nameValid) {
        this.$refs.nameInput?.$el.classList.add("custom-input-invalid");
      }

      // メッセージ組み立て
      // "チェックエラー"
      const title = DIALOG_MESSAGES["00200061"].title;
      const messages = [];
      if (!validationResult.nameValid) {
        // "レイアウト名を入力する必要があります。<br>"
        messages.push(messageFormat(DIALOG_MESSAGES["00200061"].message));
      }
      if (!validationResult.machineValid) {
        // "適用型式を入力する必要があります。<br>"
        messages.push(messageFormat(DIALOG_MESSAGES["00200062"].message));
      }
      if (!validationResult.detailInfo) {
        // "グループを選択する必要があります。<br>"
        messages.push(messageFormat(DIALOG_MESSAGES["00200063"].message));
      }
      if (!validationResult.detailTypeInfo) {
        // "選択項目間で型式が重複しています。型式が重複しないように選択を解除してください。<br>"
        messages.push(messageFormat(DIALOG_MESSAGES["00200165"].message));
      }
      const message = messages.join("");
      // ダイアログ表示
      this.$ons.notification.alert({ title, message });

      return false;
    },

    resizeWidth() {
      // 表示項目設定画面のカテゴリの幅を取得
      const categoryElement = this.$refs.categoryCols?.[0]?.$el;
      if (!categoryElement) return;

      // 表示項目設定画面のカテゴリ+項目の幅を取得
      const headerElement = this.$refs.headerRow?.$el;
      if (!headerElement) return;

      // 指定するwidthの%を計算(カテゴリの幅/カテゴリと項目の幅)
      const dispWidth = categoryElement.getBoundingClientRect().width;
      const headWidth = headerElement.getBoundingClientRect().width;
      const width = (dispWidth / headWidth) * 100;
      // widthを設定
      this.cateStyle = `flex: 0 0 ${width}%; max-width: ${width}%;`;
    },
    resizeDispItemArea() {
      const iaElement = this.$refs.itemAreaDiv;
      if (!iaElement) return;

      const mainteLayout = getScopedElement(this.$el || this, ".mst_mainte_layout");
      if (!mainteLayout) return;
      const mr = mainteLayout.getBoundingClientRect();
      const ir = iaElement.getBoundingClientRect();

      // 一覧部とモーダルの下部を比較し高さの計算値を取得
      let calcAdd = 0;
      if (mr.bottom < ir.bottom) {
        calcAdd = (ir.bottom - mr.bottom) * -1;
      } else {
        calcAdd = mr.bottom - ir.bottom;
      }
      const height = ir.height + calcAdd;

      // 高さの反映
      iaElement.style.height = `${height}px`;
    },
    resizeMstMainteLayout() {
      // 横幅調整
      this.resizeWidth();
      // disp-item-areaの高さ調整
      this.resizeDispItemArea();
    },
  },
  watch: {
    listMachineSelected() {
      // #9451対応時のメモ：
      // listMachineSelected は定期点検用でのみ使用される項目のため
      // 定期点検用であることを前提として処理する
      this.getEditRecord.typeInfo = JSON.stringify(this.listMachineSelected);
      this.checkChanged();
    },
  },
  async created() {
    this.setLoadingScreenVisible(true);

    // マスタデータを取得
    await Promise.all([
      this.sendRequestGetMachineTypeList(),
      this.sendRequestGetAllMachineByFacilityCd(this.getFacilitySwitch),
      this.sendRequestGetAllCategoryByFacilityCd(this.getFacilitySwitch),
    ]);
    // 取得したマスタデータを加工
    this.listMachineData = this.getListMachine.map(item => ({
      textMachine: item.machineType,
      valueMachine: item.machineTypeCd,
    }));
    this.isMachineDataReady = true;

    // #9451対応時のメモ：
    // kendo-multiselect の data-source に指定している
    // this.listMachineData の内容を作成した後、
    // nextTick を待ってから v-model に指定している
    // this.listMachineSelected の値を設定しないと
    // 画面上未選択のままになるため initData を呼ぶ前に nextTick を待つ
    await this.$nextTick();
    await this.initData();

    // ここまでにmountedのタイミングを過ぎている場合を考慮して改めてリサイズ処理
    // （もしまだDOM要素が生成されていなくてもリサイズ処理されないだけで終わる実装にしている）
    this.resizeMstMainteLayout();

    this.setLoadingScreenVisible(false);
  },
  mounted() {
    // モーダル要素のリサイズ監視
    this.resizeObserver = new ResizeObserver(this.resizeMstMainteLayout);
    const mainteLayout = getScopedElement(this.$el || this, ".mst_mainte_layout");
    if (mainteLayout) {
      this.resizeObserver.observe(mainteLayout);
    }

    // 画面生成が完了後、リサイズ処理
    this.resizeMstMainteLayout();
  },
  beforeUnmount() {
    // モーダル要素のリサイズ監視解除
    this.resizeObserver.disconnect();
    this.resizeObserver = null;
  },
};

const makeDetailInfoArray = (...dataArray) => dataArray.map(
  aData => aData.categories.map(item => ({
    cd: item.mainteCategoryCd,
    isDisp: item.isDisp,
  }))
);
const isDetailInfoArrayDisp = (...detailInfoArray) => detailInfoArray.some(
  info => info.some(item => item.isDisp)
);
const isNotTypeInfoOverlapped = aData => {
  const types = [];
  for (const item of aData.categories) {
    if (!item.isDisp) continue;
    if (item.typeCdList.some(type => types.includes(type))) {
      return false;
    }
    types.push(...item.typeCdList);
  }
  return true;
};
const setDisabledByTypeInfo = aData => {
  aData.categories.forEach(item => {
    if (item.isDisp) return;
    item.disabled = aData.categories.some(subItem => {
      if ((subItem === item) || !subItem.isDisp) return false;
      return (item.typeCdList.some(type => subItem.typeCdList.includes(type)));
    });
  });
};
</script>

<style scoped>
.main-area {
  padding-bottom: 0px;
}

.left-area {
  flex: 0 0 40%;
  max-width: 40%;
}

.input-area {
  padding: 2px 0;
  width: 99.5%;
}

.word-border {
  border: 1px solid #d3d3d3;
  padding: 2px;
}
.vertical-middle-flex {
  display: flex;
  align-items: center;
  vertical-align: middle;
}

/* ドロップしている要素 */
.ghost {
  opacity: 0.5;
}
/* ドラッグしている要素*/
.drag {
  display: none;
}

.column-handle {
  cursor: move;
  float: right;
}

.disp-item-area {
  display: block;
  overflow-y: auto;
  min-height: 100px;
}

.custom-input-required {
  color: black;
  background-color: #ffff99;
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}

.custom-input-area :deep(.text-input) {
  padding: 2px;
  color: #333333;
}

.custom-word-border {
  line-height: 26px;
}

.custom-select-input-area {
  border: 0.8px solid lightgray;
  background: #ffffff;
  width: 100%;
  line-height: 27px;
}

.custom-select-input-area :deep(.select-input) {
  color: #333333;
  font-family: Arial, Helvetica, sans-serif;
  padding: 2px;
}
</style>
