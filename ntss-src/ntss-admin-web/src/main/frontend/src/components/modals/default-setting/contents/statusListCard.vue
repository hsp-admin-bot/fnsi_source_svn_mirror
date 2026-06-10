/**
 * デフォルト設定タブ - 治療状況リスト設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable :expanded.sync="isExpanded">
      <div class="top"><!-- OnsenUI挙動制御：自動挿入されるラッパー用divを予め書いておき適用されるスタイルを制御 -->
        <div class="center card-header color-header">
          {{ funcName }}
        </div>
        <div class="right"><!-- OnsenUI挙動制御：空にすることで矢印を抑制 --></div>
      </div>
      <div class="expandable-content card-contents">
        <table>
          <tbody>
            <tr>
              <td class="default-setting-content-title"></td>
              <td class="default-setting-content">
                <div>
                  <input
                    type="radio"
                    class="identification"
                    name="defaultInputName"
                    value="1"
                    id="default-bed-name"
                    @click="changeShowMain('1');"
                    :checked="isShow"
                  />
                  <label for="default-bed-name" class="label first-of-type">治療状況</label>
                  <input
                    type="radio"
                    class="identification"
                    name="defaultInputName"
                    value="2"
                    id="default-machine-name"
                    @click="changeShowMain('2');"
                    :checked="!isShow"
                  />
                  <label for="default-machine-name" class="label last-of-type">装置一覧</label>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">次患者表示</td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="nextPatValue" v-if="isShow">
                  <option
                    v-for="option in nextPatGroupListGetter"
                    :key="option.nextPatValue"
                    :value="option.nextPatValue"
                  >{{ option.nextPatGroupName }}</option>
                </v-ons-select>
                <v-ons-select class="select-width" v-model="deviceNextValue" v-else>
                  <option
                    v-for="option in nextPatGroupListGetter"
                    :key="option.nextPatValue"
                    :value="option.nextPatValue"
                  >{{ option.nextPatGroupName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">表示項目</td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="colItemLayoutNo">
                  <option
                    v-for="option in comboLayoutItemList"
                    :key="option.length"
                    :value="option.colItemLayoutNo"
                  >{{ option.layoutName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr v-if="isShow">
              <td class="default-setting-content-title">クール</td>
              <td class="default-setting-content">
                <kendo-multiselect
                  v-if="selectKurGroup !== null"
                  v-model="kurGroupList"
                  style="width: 12.4em;"
                  :data-source="selectKurGroup"
                  data-text-field="kurGroupName"
                  data-value-field="kurCd"
                  placeholder="すべて"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
              <!--<td class="default-setting-content-title">ベッドグループ</td>-->
                <label id="pc-show-status-list" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <label id="phone-show-status-list" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="bedGroupCd">
                  <option :value="defaultSelect">すべて</option>
                  <option
                    v-for="(option) in selectBedGroup"
                    :key="option.length"
                    :value="option.roomBedGroupCd"
                  >{{ option.roomBedGroupName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <v-ons-checkbox input-id="default-not-usageGuide" float v-model="notUsageGuide"></v-ons-checkbox>
              </td>
              <td class="default-setting-content">
                <label for="default-not-usageGuide">凡例を表示しない</label>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">RO装置表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="dispDro"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">溶解装置表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="dispDad"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">供給装置表示</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="dispDab"></v-ons-switch>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

 <script>
   import {mapActions, mapGetters} from "vuex";
   /*add FNSI-改修内容4214 任 start*/
   import $ from "jquery";
   /*add FNSI-改修内容4214 任 end*/
   import {sendRequestGetKurSelector} from "@/apis/send-condition";
   import commonFunctions from "@/components/status-list/StatusCommonFunction";
   import {KEY_NAME_STATUS_LIST} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/eventBus.js";
   //add FNSI-5687 劉全航 end
   import {sendRequestGetStatusLayout} from "@/apis/status-list";
   export default {
  components: {
  },
  props: {
    // カード開閉初期状態
    defaultExpanded: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      // 対象の画面名
      funcName:"治療状況リスト",
      // データ初期値
      initialValue: {},
      // 編集する治療状況リスト設定レコード
      editRecord: {},
      // 表示項目コンボ用
      comboLayoutItemList: [],
      // クール項目コンボ用
      selectKurGroup: [],
      // ベッド項目コンボ用
      selectBedGroup: [],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("status-list/list", [
      "nextPatGroupListGetter"
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    defaultSelect: () => 0,
    nextPatValue: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP] = value;
      }
    },
    deviceNextValue: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE] = value;
      }
    },
    colItemLayoutNo: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP] = value;
      }
    },
    kurGroupList: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST] = value;
      }
    },
    bedGroupCd: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    notUsageGuide: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE] = value;
      }
    },
    dispDro: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO] = value;
      }
    },
    dispDad: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD] = value;
      }
    },
    dispDab: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB] = value;
      }
    },
    isShow() {
      return this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] === "1" ? true : false;
    }
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    // 治療状況/装置一覧切替
    changeShowMain(modeId) {
      this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] = modeId;
    },
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_STATUS_LIST.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD];
      rtnData.data[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB] = this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB];
      return rtnData;
    }
  },
  watch: {
   //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "statusList", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "statusList", value: false});
      },
      deep: true
    },
   //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 治療状況リストレイアウト情報取得
    await sendRequestGetStatusLayout(this.facilityCd).then(response => {
      // 表示項目コンボ用
      let getColItemData = response.data;
      this.comboLayoutItemList = commonFunctions.buildComboBoxItemsTreatmentLayout(
        getColItemData,
        commonFunctions.constant.useClass.list
      );
    });
    // クール、ベッド設定取得
    await sendRequestGetKurSelector(undefined,this.facilityCd).then(response => {
      // 取得したクール一覧情報をセット
      const kurSelector = response.data.kurSelector;
      this.selectKurGroup = [];
      kurSelector.forEach((value, index, array) => {
        let groupset = {
          kurGroupName: array[index].name,
          kurCd: array[index].code
        };
        this.selectKurGroup.push(groupset);
      });
      // 取得したベッド一覧情報をセット
      this.selectBedGroup = response.data.bedGroupList;
    });

    // 初期値未設定の場合のデフォルト値を設定
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] = "1";
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP] = 0;
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE] = 2;
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP] = this.comboLayoutItemList[0]
      ? this.comboLayoutItemList[0].colItemLayoutNo
      : "";
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST] = [];
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD] = 0;
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE] = false;
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO] = false;
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD] = false;
    this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB] = false;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_STATUS_LIST.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_MODE];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_PAT_GROUP];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_NEXT_DEVICE];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_COL_ITEM_GROUP];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_KUR_GROUP_LIST];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_BED_GROUP_CD];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_NOT_USAGE_GUIDE];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD];
        }
        if (this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB] == null) {
          this.editRecord[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB] = this.initialValue[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-status-list").css("display") === "inline"){
        document.getElementById("phone-show-status-list").innerText =  document.getElementById("phone-show-status-list").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
  mounted() {}
};
</script>

<style scoped>
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
/* 個人設定＞デフォルト設定＞治療状況マップのボタンの見切れ  5783   shan   start */
.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  /*mod FNSI-改修内容4214 任 start*/
  /*width: 6em; !* ボックスの横幅を指定する *!*/
  width: 6em; /* ボックスの横幅を指定する */
  /*mod FNSI-改修内容4214 任 end*/
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
}
/* 個人設定＞デフォルト設定＞治療状況マップのボタンの見切れ  5783   shan   end */
.first-of-type {
  border-radius: 10px 0 0 10px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
}
.select-width {
  min-width: 140px;
  width: 12.4em;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-status-list{display:none;}
}
@media (min-width: 501px){
  #phone-show-status-list{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
