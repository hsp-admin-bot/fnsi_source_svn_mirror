/**
 * デフォルト設定タブ - 治療状況マップ設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable v-model:expanded="isExpanded">
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
                    name="statusMapDefaultInput"
                    value="1"
                    id="status-map-default-bed"
                    @click="changeShowMain('1');"
                    :checked="isShow"
                  />
                  <!--mod FNSI-改修内容4214 任 start-->
                 <!-- <label for="status-map-default-bed" style="width: 7em;" class="label first-of-type">治療状況</label>-->
                  <label for="status-map-default-bed" style="width: 6em;" class="label first-of-type">治療状況</label>
                  <!--mod FNSI-改修内容4214 任 end-->
                  <input
                    type="radio"
                    class="identification"
                    name="statusMapDefaultInput"
                    value="2"
                    id="status-map-default-schedule"
                    @click="changeShowMain('2');"
                    :checked="!isShow"
                  />
                  <!--mod FNSI-改修内容4214 任 start-->
                  <!--<label for="status-map-default-schedule" style="width: 7em;" class="label last-of-type">スケジュール</label>-->
                  <label for="status-map-default-schedule" style="width: 6em;" class="label last-of-type">スケジュール</label>
                  <!--mod FNSI-改修内容4214 任 end-->
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
              <!--<td class="default-setting-content-title">ベッドレイアウト</td>-->
                <label id="pc-show-status-map" class="default-setting-content-label white-space-nowrap">ベッドレイアウト</label>
                <label id="phone-show-status-map" class="default-setting-content-label white-space-nowrap">ベッドレイアウト</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="bedLayoutId">
                  <option
                    v-for="option in bedLayoutList"
                    :key="option.layoutId"
                    :value="option.layoutId"
                  >{{ option.layoutName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr v-if="isShow">
              <td class="default-setting-content-title">次患者表示</td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="nextPatValue">
                  <option
                    v-for="option in selectNextPatGroup"
                    :key="option.nextPatValue"
                    :value="option.nextPatValue"
                  >{{ option.nextPatGroupName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">表示項目</td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="statusLayoutNo">
                  <option
                  id="colitemgrp"
                  v-for="option in statusLayoutList"
                  :key="option.length"
                  :value="option.layoutNo"
                >{{ option.layoutName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr v-if="!isShow">
              <td class="default-setting-content-title">クール</td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="kurCd">
                  <option
                    v-for="option in comboKurItemList"
                    :key="option.kurCd"
                    :value="option.kurCd"
                  >{{ option.kurName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">ベッドグループ</td>
              <td class="default-setting-content-last-row">
                <v-ons-select class="select-width" v-model="bedGroupCd">
                  <option
                    v-for="(option) in comboBedGroupList"
                    :key="option.length"
                    :value="option.roomBedGroupCd"
                  >{{ option.roomBedGroupName }}</option>
                </v-ons-select>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

 <script>
   import {mapGetters, mapActions} from "@/compat/vue/vuex";
   /*add FNSI-改修内容4214 任 start*/

   /*add FNSI-改修内容4214 任 end*/
   import {sendRequestGetBedLayoutList} from "@/apis/mst-bedLayout";
   import {sendRequestGetStatusLayout} from "@/apis/status-list";
   import {sendRequestGetKurSelector} from "@/apis/send-condition";
   import {KEY_NAME_STATUS_MAP} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import statusCommonFunctions from "@/components/status-list/StatusCommonFunction";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/compat/vue/event-bus.js";
import { getScopedElementById, isScopedElementDisplayInline } from "@/functions/common/LayoutMeasureHelper";
   //add FNSI-5687 劉全航 end

   export default {
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
      funcName:"治療状況マップ",
      // データ初期値
      initialValue: {},
      // 編集する治療状況マップ設定レコード
      editRecord: {},
      // 表示項目コンボ用
      comboLayoutItemList: [],
      // クール項目コンボ用
      selectKurGroup: [],
      // ベッド項目コンボ用
      selectBedGroup: [],
      // ベッドレイアウトのリスト
      bedLayoutList: [],
      // 次患表示のリスト
      selectNextPatGroup: [
        { nextPatGroupName: "表示しない", nextPatValue: 0 },
        { nextPatGroupName: "現クール", nextPatValue: 1 },
        { nextPatGroupName: "次クール", nextPatValue: 2 }
      ],
      // 治療状況レイアウトのリスト
      statusLayoutList: [],
      // クールのリスト
      comboKurItemList: [],
      // ベッドグループのリスト
      comboBedGroupList: [],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),

    bedLayoutId: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID] = value;
      }
    },
    nextPatValue: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE] = value;
      }
    },
    statusLayoutNo: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO] = value;
      }
    },
    kurCd: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD] = value;
      }
    },
    bedGroupCd: {
      get() {
        return this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    isShow() {
      return this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] === "1" ? true : false;
    }
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    // 治療状況/装置一覧切替
    changeShowMain(modeId) {
      this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] = modeId;
    },
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_STATUS_MAP.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] = this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE];
      rtnData.data[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID] = this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID];
      rtnData.data[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE] = this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE];
      rtnData.data[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO] = this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO];
      rtnData.data[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD] = this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD];
      rtnData.data[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD] = this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD];
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
            EventBus.$emit("isChanged", {componentName: "statusMap", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "statusMap", value: false});
      },
      deep: true
    },
   //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // ベッドレイアウト取得
    const layoutResponse = await sendRequestGetBedLayoutList(this.facilityCd);
    if (layoutResponse.status === 200) {
      // bedLayoutを展開
      const tmpBedLayoutList = layoutResponse.data.map(dat => {
        dat.bedLayout = JSON.parse(dat.bedLayout);
        return dat;
      });
      this.bedLayoutList = tmpBedLayoutList
        .filter(dat => dat.isDel !== "1" && dat.isDisp !== "0")
        .map(dat => {
          dat.bedLayout.obj_list = dat.bedLayout.obj_list.filter(
            obj =>
              // 装置区分、シリアル番号のある装置のみを対象とする
              obj.machine_serial && obj.machine_type_cd
          );
          return dat;
        });
    }
    // 表示項目取得
    const response = await sendRequestGetStatusLayout(this.facilityCd);
    if (response.status === 200) {
      const tmpStatusLayoutList = response.data.filter(
        dat => dat.useClass === statusCommonFunctions.constant.useClass.map
      );
      if (tmpStatusLayoutList.length > 0) {
        this.statusLayoutList = tmpStatusLayoutList.map(dat => ({
          layoutName: dat.layoutName,
          layoutNo: dat.layoutNo
        }));
      } else {
        this.statusLayoutList = [];
      }
    }
    // クールとベッドの一覧取得
    const kurBedGroupResponse = await sendRequestGetKurSelector(
      undefined,
      this.facilityCd
    );
    if (kurBedGroupResponse.data.kurSelector.length > 0) {
      this.comboKurItemList = kurBedGroupResponse.data.kurSelector.map(dat => {
        return {
          kurName: dat.name,
          kurCd: dat.code
        };
      });
    }
    const allBed = {
      roomBedGroupName: "すべて",
      roomBedGroupCd: 0
    };
    if (kurBedGroupResponse.data.bedGroupList.length > 0) {
      const comboList = kurBedGroupResponse.data.bedGroupList.map(dat => {
        return {
          roomBedGroupName: dat.roomBedGroupName,
          roomBedGroupCd: dat.roomBedGroupCd
        };
      });
      comboList.unshift(allBed);
      this.comboBedGroupList = comboList;
    } else {
      this.comboBedGroupList = [allBed];
    }

    // 初期値未設定の場合のデフォルト値を設定
    this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] = "1";
    this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID] = this.bedLayoutList[0]
      ? this.bedLayoutList[0].layoutId
      : "";
    this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE] = 2;
    this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO] = this.statusLayoutList[0]
      ? this.statusLayoutList[0].layoutNo
      : "";
    this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD] = this.comboKurItemList[0]
      ? this.comboKurItemList[0].kurCd
      : "";
    this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD] = 0;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_STATUS_MAP.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] == null) {
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] = this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE];
        }
        if (this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID] == null) {
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID] = this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID];
        } else if (!this.bedLayoutList.some(bl => +bl.layoutId === +this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID])) {
          // NOTE: マスタ削除された場合、リスト先頭を再設定
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID] = this.bedLayoutList[0] ? this.bedLayoutList[0].layoutId : "";
        }
        if (this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE] == null) {
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE] = this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE];
        }
        if (this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO] == null) {
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO] = this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO];
        } else if (!this.statusLayoutList.some(sl => +sl.layoutNo === +this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO])) {
          // NOTE: マスタ削除された場合、リスト先頭を再設定
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO] = this.statusLayoutList[0] ? this.statusLayoutList[0].layoutNo : "";
        }
        if (this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD] == null) {
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD] = this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD];
        } else if (!this.comboKurItemList.some(kur => +kur.kurCd === +this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD])) {
          // NOTE: マスタ削除された場合、リスト先頭を再設定
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD] = this.comboKurItemList[0] ? this.comboKurItemList[0].kurCd : "";
        }
        if (this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD] = this.initialValue[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD];
        } else if (!this.comboBedGroupList.some(bg => +bg.roomBedGroupCd === +this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD])) {
          // NOTE: マスタ削除された場合、「0 : すべて」を再設定
          this.editRecord[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD] = 0;
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-status-map", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-status-map", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
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
  width: 6em !important; /* ボックスの横幅を指定する */
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
  #pc-show-status-map{display:none;}
}
@media (min-width: 501px){
  #phone-show-status-map{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
