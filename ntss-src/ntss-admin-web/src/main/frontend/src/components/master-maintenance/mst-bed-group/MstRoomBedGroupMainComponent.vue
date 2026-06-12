<template>
  <div class="main-area custom-main-area">
    <div class="upper">
    <v-ons-row>
      <v-ons-col class="item-word" width="50%">透析室・ベッドグループ名</v-ons-col>
      <v-ons-col>
        <custom-input
          class="item-input"
          :value="editBedGroupName"
          @blur="setBedName($event.target.value)"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row>
      <v-ons-col class="item-word" width="50%">グループ区分</v-ons-col>
      <v-ons-col>
        <custom-select
          class="item-input select-font-inherit"
          :value="shownBedGroupClass"
          :options="bedGroupClassList"
          @change="setBedGroupClass(shownBedGroupClass.editValue)"
        />
      </v-ons-col>
    </v-ons-row>
    <!-- mod redmine 5349 連携コード1～3の判別不可 宋qy start -->
    <v-ons-row>
      <v-ons-col class="item-word" width="50%">連携コード1</v-ons-col>
      <v-ons-col>
        <custom-input
          class="item-input"
          oninput="if(value.length>1)value=value.slice(0,20)"
          :value="editBedGroupInHospitalCd1"
          @blur="setBedInHospitalCd1($event.target.value)"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row>
      <v-ons-col class="item-word" width="50%">連携コード2</v-ons-col>
      <v-ons-col>
        <custom-input
          class="item-input"
          oninput="if(value.length>1)value=value.slice(0,20)"
          :value="editBedGroupInHospitalCd2"
          @blur="setBedInHospitalCd2($event.target.value)"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row>
      <v-ons-col class="item-word" width="50%">連携コード3</v-ons-col>
      <v-ons-col>
        <custom-input
          class="item-input"
          oninput="if(value.length>1)value=value.slice(0,20)"
          :value="editBedGroupInHospitalCd3"
          @blur="setBedInHospitalCd3($event.target.value)"
        />
      </v-ons-col>
    </v-ons-row>
    <!-- mod redmine 5349 連携コード1～3の判別不可 宋qy end -->
    </div>
    <!-- ベッド選択エリア -->
    <div class="bed-select-area">
      <div class="select-upper">
      <v-ons-row>
        <v-ons-col class="color-header item-word">
          ベッド選択
        </v-ons-col>
      </v-ons-row>

      <!-- フリーワード抽出 -->
      <v-ons-row class="freeword-area">
        <v-ons-col class="item-word">
          フリーワード検索
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="freeword-area">
        <v-ons-input v-model="freeWord" />
      </v-ons-row>
      </div>
      <v-ons-row class="select-area">
        <!-- 未選択リスト -->
        <v-ons-col>
          <selection-list
            class="item-word select-item-list"
            :item-list="unselectedItemList"
            @check="toggleCheckUnselectedList"
          />
        </v-ons-col>
        <!-- 選択ボタン -->
        <v-ons-col class="select-item">
          <div class="select-button-area d-flex flex-column">
            <button
              class="k-button k-button-icon"
              @click="selectAllItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-double-60-right"></span>
            </button>

            <button
              class="k-button k-button-icon"
              @click="selectItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-60-right"></span>
            </button>

            <button
              class="k-button k-button-icon"
              @click="unselectItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-60-left"></span>
            </button>

            <button
              class="k-button k-button-icon"
              @click="unselectAllItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-double-60-left"></span>
            </button>
          </div>
        </v-ons-col>
        <!-- 選択リスト -->
        <v-ons-col>
          <selection-list
            class="item-word select-item-list"
            :item-list="selectedItemList"
            @check="toggleCheckSelectedList"
          />
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import selectionList from "@/components/common/list-selector/SelectionList.vue";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customSelect from "@/components/common/custom-form-tags/CustomSelect";
import { createItemListData } from "@/functions/for-componet/ListSelector.js";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {EventBus} from "@/compat/vue/event-bus.js";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
import { deepCopy } from "@/functions/common/CommonFunctions";
import { getModalContainerElement, getModalBodyElement, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";
// mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
export default {
  components: {
    "selection-list": selectionList,
    "custom-input": customInput,
    "custom-select": customSelect
  },
  data() {
    return {
      //編集中マスタのベッド名
      editBedGroupName: { initValue: "", editValue: "" },
      //編集中マスタのベッドグループ区分
      editBedGroupClass: "",
      //編集中マスタの連携コード1
      editBedGroupInHospitalCd1: { initValue: "", editValue: "" },
      //編集中マスタの連携コード2
      editBedGroupInHospitalCd2: { initValue: "", editValue: "" },
      //編集中マスタの連携コード3
      editBedGroupInHospitalCd3: { initValue: "", editValue: "" },
      //選択中のベッドグループ区分
      selectBedGroupClass: "",
      //マスタベッド一覧
      mstBedList: null,
      //マスタベッド一覧抽出用フリーキーワード
      freeWord: "",
      //表示項目にチエック有無フラグ、選択有無フラグを付与したリスト
      selectionItemList: [],
      //画面に表示される、選択中のベッドグループ区分
      shownBedGroupClass: { initValue: "", editValue: "" },
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
      unselectedItemListDefault: [],
      selectedItemListDefault: [],
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("master-maintenance", ["getColumns", "getEditRecord"]),
    ...mapGetters("user", ["getFacilityCd"]),

    ...mapGetters("master-maintenance", ["getFacilitySwitch"]),
    ...mapGetters("account-edit", {
      getStateUserAccountInfo: "getStateUserAccountInfo",
      getFontSize: "getFontSize",
    }),
    /**
     * @description ベッドグループ区分のリスト
     */
    bedGroupClassList() {
      //ベッドグループ区分と区分名(1：ベッドグループ、2：透析室、3：その他) 取得
      const mstBedGroupClass = this.getColumns.find(
        col => col.field === "groupClass").values;

      //custom-input用の配列を作成
      const customMstBedGroupClass = mstBedGroupClass.map(item => {
        return { value: item.value, displayValue: item.text };
      });

      return customMstBedGroupClass;
    },

    /**
     * @description フリーワードによるフィルタリング済みリスト
     */
    filteredList() {
      // フィルタリング用リストを保持
      let filteredList = this.selectionItemList;

      // フリーワードでフィルタリング
      if (this.freeWord !== "") {
        filteredList = filteredList.filter(item =>
          item.name.includes(this.freeWord)
        );
      }
      return filteredList;
    },

    /**
     * @description 未選択項目リスト
     */
    unselectedItemList() {
      return this.filteredList.filter(item => !item.isSelected);
    },

    /**
     * @description 選択項目リスト
     */
    selectedItemList() {
      return this.selectionItemList.filter(item => item.isSelected);
    }
  },

  async created() {
    /**
     * @description ベッドグループ名の初期表示処理
     */
    //選択中のベッドグループ名、連携コードを画面表示用ローカル変数に保持
    this.editBedGroupName.initValue = this.getEditRecord.name;
    this.editBedGroupName.editValue = this.editBedGroupName.initValue;
    this.editBedGroupInHospitalCd1.initValue = this.getEditRecord.inHospitalCd1;
    this.editBedGroupInHospitalCd1.editValue = this.editBedGroupInHospitalCd1.initValue;
    this.editBedGroupInHospitalCd2.initValue = this.getEditRecord.inHospitalCd2;
    this.editBedGroupInHospitalCd2.editValue = this.editBedGroupInHospitalCd2.initValue;
    this.editBedGroupInHospitalCd3.initValue = this.getEditRecord.inHospitalCd3;
    this.editBedGroupInHospitalCd3.editValue = this.editBedGroupInHospitalCd3.initValue;

    /**
     * @description ベッドグループ区分の初期表示処理
     */
    // 編集中マスタのベッドグループ区分を保持
    this.editBedGroupClass = this.getEditRecord.groupClass;
    // 編集中マスタのベッドグループ区分を初期選択(未登録で保存されたグループ区分は空文字で取得されるのでnullに置き換える)
    this.selectBedGroupClass =
      this.editBedGroupClass === "" ? null : this.editBedGroupClass;

    /**
     * @description リスト表示用ベッド情報を取得
     */
    const params = {
      // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // facility_cd: this.getFacilityCd,
      facility_cd: this.getFacilitySwitch,
      // mod マスタ一覧 1･施設切替を可能とする 孔s end

      //表示フラグ
      is_disp: "1",
      //削除フラグ
      is_del: "0"
    };
    //ベッドマスタ情報を取得
    const mstBedData = await ApiHelper.get("/mstInfo/mstBed", params).catch(
      () => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('MstRoomBedGroupMainComponent.vue', 'created', 'マスタ取得失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw new Error("マスタ取得失敗");
      }
    );
    //リスト表示のため、取得したベッドマスタデータを変換
    this.mstBedList = createItemListData(mstBedData.data, "bedCd", "bedName");

    /**
     * @description 表示項目リストにチェックフラグと選択フラグを付与
     */
    this.selectionItemList = this.mstBedList.map(item => {
      // 初期選択状態判定フラグ
      let isDefaultSelected = false;
      //ベッドグループ所属のベッド一覧(Json)
      const IncludedBedList = this.getEditRecord.bedList;
      //ベッドグループ所属のベッド一覧(配列)
      let parseIncludedBedList = null;

      //選択したベッドグループにベッド一覧が登録されている場合
      if (this.getEditRecord.bedList) {
        //ベッドグループ所属のベッド一覧を配列で保持
        parseIncludedBedList = JSON.parse(IncludedBedList);
        //ベッドグループ所属のベッドに対し、フラグを選択済とする処理
        if (parseIncludedBedList.includes(item.cd)) {
          isDefaultSelected = true;
        }
      }
      return { ...item, isChecked: false, isSelected: isDefaultSelected };
    });

    this.calculateGridHeight(this.getFontSize);
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
    this.$nextTick(()=>{
      this.unselectedItemListDefault = deepCopy(this.unselectedItemList);
      this.selectedItemListDefault = deepCopy(this.selectedItemList);
    })
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
  },

  mounted() {
    /**
     * @description ベッドグループ区分のプルダウンを作成
     */
    //画面に表示するベッドグループ区分をローカル変数に保持(新規登録時は"その他"、編集時は選択したベッドグループ区分を設定)
    this.shownBedGroupClass.initValue =
      this.selectBedGroupClass === null
        ? this.bedGroupClassList.length
        : this.selectBedGroupClass;
    this.shownBedGroupClass.editValue = this.shownBedGroupClass.initValue;

    //新規登録の場合、"その他"を初期表示する処理
    if (this.selectBedGroupClass === null) {
      this.setBedGroupClass(this.shownBedGroupClass.editValue);
    }
    this.calculateGridHeight();
    // mod redmine 5349 連携コード1～3の判別不可 宋qy start
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize", this.calculateGridHeight, false);
    // mod redmine 5349 連携コード1～3の判別不可 宋qy end
   //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },
  beforeUnmount() {
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.calculateGridHeight, false);
  },
  watch: {
    getFontSize(value) {
      this.calculateGridHeight(value);
    },
    // mod マスタ詳細画面がありません破棄メッセージ
    editBedGroupName:{
     handler(){
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
      // if (this.editBedGroupName.initValue!=this.editBedGroupName.editValue) {
      //  this.changeButton();
      // }else{
      //  EventBus.$emit("mstHolidayRegistered", true);
      // }
      this.changeButton();
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
    },
      deep: true
    },
    shownBedGroupClass:{
     handler(){
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
      //   if (this.shownBedGroupClass.initValue!=this.shownBedGroupClass.editValue) {
      //    this.changeButton();
      //   }else{
      //    EventBus.$emit("mstHolidayRegistered", true);
      // }
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
      this.changeButton();
    },
      deep: true
    },
    editBedGroupInHospitalCd1:{
     handler(){
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
      //   if (this.editBedGroupInHospitalCd1.initValue!=this.editBedGroupInHospitalCd1.editValue) {
      //    this.changeButton();
      //   }else{
      //    EventBus.$emit("mstHolidayRegistered", true);
      // }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
      this.changeButton();
    },
      deep: true
    },
    editBedGroupInHospitalCd2:{
     handler(){
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
      //   if (this.editBedGroupInHospitalCd2.initValue!=this.editBedGroupInHospitalCd2.editValue) {
      //    this.changeButton();
      //   }else{
      //    EventBus.$emit("mstHolidayRegistered", true);
      // }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
      this.changeButton();
    },
      deep: true
    },
    editBedGroupInHospitalCd3:{
     handler(){
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
      //   if (this.editBedGroupInHospitalCd3.initValue!=this.editBedGroupInHospitalCd3.editValue) {
      //    this.changeButton();
      //   }else{
      //    EventBus.$emit("mstHolidayRegistered", true);
      // }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
      this.changeButton();
    },
      deep: true
    },
  },
  methods: {
    getCurrentModalContainer() {
      return getModalContainerElement(this.$el) || null;
    },
    getCurrentModalBody() {
      return getModalBodyElement(this.$el) || null;
    },
    getBedGroupElement(selector) {
      return this.getCurrentModalBody()?.querySelector?.(selector) || this.getCurrentModalContainer()?.querySelector?.(selector) || this.$el?.querySelector?.(selector) || queryScopedSelector(selector, this.$el);
    },
    ...mapActions("master-maintenance", ["setEditRecord"]),
    calculateGridHeight(value){
      const multiSelectList = this.getBedGroupElement('.multi-select-list');
      const modalBody = this.getCurrentModalBody();
      const upper = this.getBedGroupElement('.upper');
      const selectUpper = this.getBedGroupElement('.select-upper');
      const selectArea = this.getBedGroupElement('.select-area');
      if (multiSelectList) {
        multiSelectList.style.fontSize = '';
      }
      let newHeight = (modalBody?.clientHeight || 0) - (upper?.clientHeight || 0) - (selectUpper?.clientHeight || 0) - 45;
      if (selectArea) {
        selectArea.style.height = newHeight + 'px';
      }
    },
    /**
     * @description 項目全選択処理
     * @summary 全ての項目を選択状態とする
     */
    selectAllItem() {
      this.unselectedItemList.forEach(item => {
        item.isChecked = false;
        item.isSelected = true;
      });
      //選択状態のベッド一覧をマスタに登録
      this.setIncludedBed(this.selectedItemList);
    },
   //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng start
      if ((this.editBedGroupName.initValue ?? "") === (this.editBedGroupName.editValue ?? "") &&
      this.shownBedGroupClass.initValue == this.shownBedGroupClass.editValue && 
      (this.editBedGroupInHospitalCd1.initValue ?? "") === (this.editBedGroupInHospitalCd1.editValue ?? "") &&
      (this.editBedGroupInHospitalCd2.initValue ?? "") === (this.editBedGroupInHospitalCd2.editValue ?? "") &&
      (this.editBedGroupInHospitalCd3.initValue ?? "") === (this.editBedGroupInHospitalCd3.editValue ?? "") &&
      JSON.stringify(this.unselectedItemListDefault) === JSON.stringify(this.unselectedItemList) && 
      JSON.stringify(this.selectedItemListDefault) === JSON.stringify(this.selectedItemList)
      ) {
        EventBus.$emit("mstHolidayRegistered", true);
      } else{
        EventBus.$emit("mstHolidayRegistered", false);
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240104 linjunfeng end
    },
    /**
     * @description 項目選択処理
     * @summary チェック状態の項目を選択状態とする
     */
    selectItem() {
      this.unselectedItemList
        .filter(item => item.isChecked)
        .forEach(item => {
          item.isChecked = false;
          item.isSelected = true;
        });
      //選択状態のベッド一覧をマスタに登録
      this.setIncludedBed(this.selectedItemList);
    },

    /**
     * @description 項目選択解除処理
     * @summary チェック状態の項目を未選択状態とする
     */
    unselectItem() {
      this.selectedItemList
        .filter(item => item.isChecked)
        .forEach(item => {
          item.isChecked = false;
          item.isSelected = false;
        });
      //選択状態のベッド一覧をマスタに登録
      this.setIncludedBed(this.selectedItemList);
    },

    /**
     * @description 項目全選択解除処理
     * @summary 全ての項目を未選択状態とする
     */
    unselectAllItem() {
      this.selectedItemList.forEach(item => {
        item.isChecked = false;
        item.isSelected = false;
      });
      //選択状態のベッド一覧をマスタに登録
      this.setIncludedBed(this.selectedItemList);
    },

    /**
     * @description 未選択項目リストのチェック切り替え
     * @summary 子のチェックイベントを購読し表示項目リストにチェック状態を反映する
     * @param {Object} { checkedIndex(チェック項目インデックス), isChecked(チェック状態) }
     */
    toggleCheckUnselectedList({ checkedIndex, isChecked }) {
      this.unselectedItemList[checkedIndex].isChecked = isChecked;
    },

    /**
     * @description 選択項目リストのチェック切り替え
     * @summary 子のチェックイベントを購読し表示項目リストにチェック状態を反映する
     * @param {Object} { checkedIndex(チェック項目インデックス), isChecked(チェック状態) }
     */
    toggleCheckSelectedList({ checkedIndex, isChecked }) {
      this.selectedItemList[checkedIndex].isChecked = isChecked;
    },

    /**
     * @description ベッド名更新
     * @param 変更後のベッド名
     */
    setBedName(value) {
      const name = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, name });
    },
    /**
     * @description 連携コード1更新
     * @param 変更後の連携コード1
     */
    setBedInHospitalCd1(value) {
      const inHospitalCd1 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCd1 });
    },

    /**
     * @description 連携コード2更新
     * @param 変更後の連携コード2
     */
    setBedInHospitalCd2(value) {
      const inHospitalCd2 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCd2 });
    },

    /**
     * @description 連携コード3更新
     * @param 変更後の連携コード3
     */
    setBedInHospitalCd3(value) {
      const inHospitalCd3 = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.getEditRecord, inHospitalCd3 });
    },

    /**
     * @description ベッドグループ区分選択
     * @param 変更後のベッドグループ区分
     */
    setBedGroupClass(value) {
      // 選択したベッドグループ区分を保持
      this.selectBedGroupClass = value;
      // 編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        groupClass: this.selectBedGroupClass
      });
    },

    /**
     * @description ベッドグループに含めるベッド一覧情報を更新
     * @param ベッドグループに含めるベッド一覧
     */
    setIncludedBed(value) {
      //ベッドグループに登録するベッドコードリスト
      const cdList = [];

      //ベッド一覧のコードを取得
      value.forEach(item => {
        cdList.push(item.cd);
      });

      //編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        bedList: JSON.stringify(cdList)
      });
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
    }
  }
};
</script>

<style scoped>
.main-area {
  margin: 0 5px;
}

.item-word {
  border: 1px solid #d3d3d3;
}

.item-input {
  width: 100%;
  box-sizing: border-box;
  padding: 0;
}

.freeword-area {
  width: 30.5vw;
}

.freeword-area :deep(.text-input) {
  font-size: unset;
}

.bed-select-area {
  margin-top: 10px;
}

.select-area {
  margin-top: 10px;
}

.select-button-area {
  width: 100%;
  min-width: 60px;
}

.select-button {
  min-width: 106px;
  width: 40%;
  padding: 1px;
  margin-bottom: 2px;
  font-size: unset;
}

.k-button {
  margin: auto;
  box-shadow: none;
  margin-bottom: 0.4em;
}

.select-item {
  display: flex;
  align-items: center;
  text-align: center;
}

.select-item-list {
  height: 100%;
  width: 35vw;
}

.select-item-list :deep(.item-label) {
  padding-top: 0.2em;
  padding-bottom: 0.2em;
}

.custom-main-area .item-word {
  display: block;
  align-items: center;
  padding: 0 2px;
}

@media screen and (max-width: 500px) {
  .bed-select-area {
    margin-top: 10px;
    overflow-x: auto;
    min-width: 499px;
  }
}
</style>
