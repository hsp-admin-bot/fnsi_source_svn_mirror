/**
 * デフォルト設定タブ - チェックリスト設定のコンポーネント
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
              <!-- add 不具合 #6265 dou start -->
              <td class="default-setting-content-title"></td>
              <td class="default-setting-content">
                <div>
                  <input
                    type="radio"
                    class="identification"
                    name="defaultInputTreat"
                    value="'1'"
                    id="default-input-treat"
                    @click="changeShowMain('1');"
                    :checked="isShow"
                  />
                  <label for="default-input-treat" class="label first-of-type">治療中</label>
                  <input
                    type="radio"
                    class="identification"
                    name="defaultInputDate"
                    value="'2'"
                    id="default-input-date"
                    @click="changeShowMain('2');"
                    :checked="!isShow"
                  />
                  <label for="default-input-date" class="label last-of-type">指定日</label>
                </div>
              </td>
            </tr>
            <tr v-if="isShow">
            <!-- add 不具合 #6265 dou end -->
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">次患者</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="nextPat">
                  <option v-for='option in nextPatList' :key=option.no :value=option.no>
                    {{ option.name }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <!-- add 不具合 #6265 dou start -->
            <tr v-else>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">クール</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="kur">
                  <option :value="defaultSelect">すべて</option>
                  <option v-for='option in getMstKurSelector' :key=option.length :value=option.code>
                    {{ option.name }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <!-- add 不具合 #6265 dou end -->
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">ベッドグループ</label>-->
                <label id="pc-show-check-list" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <label id="phone-show-check-list" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="bedGroupCd">
                  <option :value="defaultSelect">すべて</option>
                  <option v-for='(option) in getMstBedGroupList' :key=option.length :value=option.roomBedGroupCd>
                    {{ option.roomBedGroupName }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">治療日列表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="viewTreatDate"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">画面自動更新</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="isAutoReload"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">凡例の表示</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="isShowUsageGuide"></v-ons-switch>
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
   import {CHECK_LIST} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   //add FNSI-5687 劉全航 start
   import { EventBus } from "@/eventBus.js";
   //add FNSI-5687 劉全航 end

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
      funcName:"チェックリスト",
      // データ初期値
      initialValue: {},
      // 編集するチェックリスト設定レコード
      editRecord: {},
      nextPatList: [
        { no: 0, name: "表示しない" },
        { no: 1, name: "現クール" },
        { no: 2, name: "次クール" }
      ],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      userInfo: "getStateUserAccountInfo",
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("check-list/list", [
      "getMstBedGroupList",
      // add 不具合 #6265 dou start
      "getMstKurSelector",
      // add 不具合 #6265 dou end
    ]),
    defaultSelect: () => -1,
    // add 不具合 #6265 dou start
    kur: {
      get() {
        return this.editRecord[CHECK_LIST.KEY_NAME_KUR_CD];
      },
      set(value) {
        this.editRecord[CHECK_LIST.KEY_NAME_KUR_CD] = value;
      }
    },
    // add 不具合 #6265 dou end
    // 次患者
    nextPat: {
      get() {
        return this.editRecord[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP];
      },
      set(value) {
        this.editRecord[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP] = value;
      }
    },
    // ベッドグループ
    bedGroupCd: {
      get() {
        return this.editRecord[CHECK_LIST.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[CHECK_LIST.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    // 治療日列表示
    viewTreatDate: {
      get() {
        return this.editRecord[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE];
      },
      set(value) {
        this.editRecord[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE] = value;
      }
    },
    // 画面自動更新
    isAutoReload: {
      get() {
        return this.editRecord[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD];
      },
      set(value) {
        this.editRecord[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD] = value;
      }
    },
    // 凡例の表示
    isShowUsageGuide: {
      get() {
        return this.editRecord[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE];
      },
      set(value) {
        this.editRecord[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE] = value;
      }
    },
    // add 不具合 #6265 dou start
    isShow() {
      return this.editRecord[CHECK_LIST.KEY_NAME_DISP_MODE] === "1" ? true : false;
    }
    // add 不具合 #6265 dou end
  },
  methods: {
    ...mapActions("check-list/list", [
      "fetchKurBedGroup"
    ]),
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: CHECK_LIST.KEY_NAME,
        data: {}
      };
      rtnData.data[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP  ] = this.editRecord[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP  ];
      rtnData.data[CHECK_LIST.KEY_NAME_BED_GROUP_CD    ] = this.editRecord[CHECK_LIST.KEY_NAME_BED_GROUP_CD    ];
      rtnData.data[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE ] = this.editRecord[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE ];
      rtnData.data[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD  ] = this.editRecord[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD  ];
      rtnData.data[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE   ] = this.editRecord[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE   ];
      // add 不具合 #6265 dou start
      rtnData.data[CHECK_LIST.KEY_NAME_DISP_MODE       ] = this.editRecord[CHECK_LIST.KEY_NAME_DISP_MODE       ];
      rtnData.data[CHECK_LIST.KEY_NAME_KUR_CD          ] = this.editRecord[CHECK_LIST.KEY_NAME_KUR_CD          ];
      // add 不具合 #6265 dou end
      return rtnData;
    },
    // add 不具合 #6265 dou start
    // 治療中/指定日
    changeShowMain(modeId) {
      this.editRecord[CHECK_LIST.KEY_NAME_DISP_MODE] = modeId;
    },
    // add 不具合 #6265 dou end
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
            EventBus.$emit("isChanged", {componentName: "checkList", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "checkList", value: false});
      },
      deep: true
    },
   //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP  ] = 0;
    this.initialValue[CHECK_LIST.KEY_NAME_BED_GROUP_CD    ] = -1;
    this.initialValue[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE ] = false;
    this.initialValue[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD  ] = false;
    this.initialValue[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE   ] = false;
    // add 不具合 #6265 dou start
    this.initialValue[CHECK_LIST.KEY_NAME_DISP_MODE       ] = "1";
    this.initialValue[CHECK_LIST.KEY_NAME_KUR_CD          ] = -1;
    // add 不具合 #6265 dou end

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[CHECK_LIST.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP] == null) {
          this.editRecord[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP] = this.initialValue[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP];
        }
        if (this.editRecord[CHECK_LIST.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[CHECK_LIST.KEY_NAME_BED_GROUP_CD] = this.initialValue[CHECK_LIST.KEY_NAME_BED_GROUP_CD];
        }
        if (this.editRecord[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE] == null) {
          this.editRecord[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE] = this.initialValue[CHECK_LIST.KEY_NAME_VIEW_TREAT_DATE];
        }
        if (this.editRecord[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD] == null) {
          this.editRecord[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD] = this.initialValue[CHECK_LIST.KEY_NAME_IS_AUTO_RELOAD];
        }
        if (this.editRecord[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE] == null) {
          this.editRecord[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE] = this.initialValue[CHECK_LIST.KEY_NAME_IS_SHOW_GUIDE];
        }
        // add 不具合 #6265 dou start
        if (this.editRecord[CHECK_LIST.KEY_NAME_DISP_MODE] == null) {
          this.editRecord[CHECK_LIST.KEY_NAME_DISP_MODE] = this.initialValue[CHECK_LIST.KEY_NAME_DISP_MODE];
        }
        if (this.editRecord[CHECK_LIST.KEY_NAME_KUR_CD] == null) {
          this.editRecord[CHECK_LIST.KEY_NAME_KUR_CD] = this.initialValue[CHECK_LIST.KEY_NAME_KUR_CD];
        }
        // add 不具合 #6265 dou end
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-check-list").css("display") === "inline"){
        document.getElementById("phone-show-check-list").innerText =  document.getElementById("phone-show-check-list").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
  async mounted() {
    await this.fetchKurBedGroup(this.facilityCd);
  }
};
</script>

<style scoped>
/* add 不具合 #6265 dou start */
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 6em; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
}
.first-of-type {
  border-radius: 10px 0 0 10px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
}
/* add 不具合 #6265 dou end */
.select-width {
  min-width: 140px;
  width: 12.4em;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-check-list{display:none;}
}
@media (min-width: 501px){
  #phone-show-check-list{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
