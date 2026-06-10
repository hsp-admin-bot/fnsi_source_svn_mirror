/**
 * デフォルト設定タブ - 日常点検設定のコンポーネント
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
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">ベッドグループ</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select input-id="bedGroupCd" v-model="bedGroupCd">
                  <option
                    v-for="option in mstBedGroup"
                    :key="option.length"
                    :value="option.roomBedGroupCd"
                  >{{ option.roomBedGroupName }}</option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">型式</label>
              </td>
              <td class="default-setting-content">
                <kendo-multiselect
                  :data-source="machineInspection"
                  :data-text-field="'machineType'"
                  :data-value-field="'machineTypeCd'"
                  :filter="'contains'"
                  v-model="machineTypeList"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">未実施</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model='isNon'></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">点検途中</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model='isFail'></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">不合格</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model='isUnpass'></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">全件合格</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model='isPass'></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">フリーワード</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-input
                  input-id="keyWord"
                  type="text"
                  v-model="keyWord"
                ></v-ons-input>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

 <script>
   import {mapGetters, mapActions} from "vuex";
   import {DAILY_CHECK} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {ApiHelper} from "@/apis/AxiosHelper";
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
      funcName:"日常点検",
      // データ初期値
      initialValue: {},
      // 編集する日常点検設定レコード
      editRecord: {},
      // ベッドグループ一覧
      mstBedGroup: [],
      // 型式一覧
      machineInspection: null,
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: DAILY_CHECK.KEY_NAME,
        data: {}
      };
      rtnData.data[DAILY_CHECK.KEY_NAME_BED_GROUP_CD] = this.editRecord[DAILY_CHECK.KEY_NAME_BED_GROUP_CD];
      rtnData.data[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST] = this.editRecord[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST];
      rtnData.data[DAILY_CHECK.KEY_NAME_IS_NON] = this.editRecord[DAILY_CHECK.KEY_NAME_IS_NON];
      rtnData.data[DAILY_CHECK.KEY_NAME_IS_FAIL] = this.editRecord[DAILY_CHECK.KEY_NAME_IS_FAIL];
      rtnData.data[DAILY_CHECK.KEY_NAME_IS_UNPASS] = this.editRecord[DAILY_CHECK.KEY_NAME_IS_UNPASS];
      rtnData.data[DAILY_CHECK.KEY_NAME_IS_PASS] = this.editRecord[DAILY_CHECK.KEY_NAME_IS_PASS];
      rtnData.data[DAILY_CHECK.KEY_NAME_KEYWORD] = this.editRecord[DAILY_CHECK.KEY_NAME_KEYWORD];
      return rtnData;
    }
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    bedGroupCd: {
      get() {
        return this.editRecord[DAILY_CHECK.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[DAILY_CHECK.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    machineTypeList: {
      get() {
        return this.editRecord[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST];
      },
      set(value) {
        this.editRecord[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST] = value;
      }
    },
    isNon: {
      get() {
        return this.editRecord[DAILY_CHECK.KEY_NAME_IS_NON];
      },
      set(value) {
        this.editRecord[DAILY_CHECK.KEY_NAME_IS_NON] = value;
      }
    },
    isFail: {
      get() {
        return this.editRecord[DAILY_CHECK.KEY_NAME_IS_FAIL];
      },
      set(value) {
        this.editRecord[DAILY_CHECK.KEY_NAME_IS_FAIL] = value;
      }
    },
    isUnpass: {
      get() {
        return this.editRecord[DAILY_CHECK.KEY_NAME_IS_UNPASS];
      },
      set(value) {
        this.editRecord[DAILY_CHECK.KEY_NAME_IS_UNPASS] = value;
      }
    },
    isPass: {
      get() {
        return this.editRecord[DAILY_CHECK.KEY_NAME_IS_PASS];
      },
      set(value) {
        this.editRecord[DAILY_CHECK.KEY_NAME_IS_PASS] = value;
      }
    },
    keyWord: {
      get() {
        return this.editRecord[DAILY_CHECK.KEY_NAME_KEYWORD];
      },
      set(value) {
        this.editRecord[DAILY_CHECK.KEY_NAME_KEYWORD] = value;
      }
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
            EventBus.$emit("isChanged", {componentName: "dailyCheck", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "dailyCheck", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[DAILY_CHECK.KEY_NAME_BED_GROUP_CD] = null;
    this.initialValue[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST] = [];
    this.initialValue[DAILY_CHECK.KEY_NAME_IS_NON] = true;
    this.initialValue[DAILY_CHECK.KEY_NAME_IS_FAIL] = true;
    this.initialValue[DAILY_CHECK.KEY_NAME_IS_UNPASS] = true;
    this.initialValue[DAILY_CHECK.KEY_NAME_IS_PASS] = true;
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc start
    //this.initialValue[DAILY_CHECK.KEY_NAME_KEYWORD] = null;
    this.initialValue[DAILY_CHECK.KEY_NAME_KEYWORD] = '';
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_個別設定 20231117 ztc end

    // 水質検査マスタ、透析室・ベッドグループマスタを取得
    const [
      responseMachineTypeList,
      responseBedGroup
    ] = await Promise.all([
      ApiHelper.get("/mente-main/getMachineTypeList"),
      ApiHelper.get("/mstInfo/mstRoomBedGroup", {
        facilityCd: this.getFacilityCd
      })
    ]);

    this.machineInspection = responseMachineTypeList.data;
    this.mstBedGroup = responseBedGroup.data;
    this.mstBedGroup.unshift({
      roomBedGroupCd: null,
      // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている Start
      // roomBedGroupName: ""
      roomBedGroupName: "すべて"
      // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている End
    });

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[DAILY_CHECK.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[DAILY_CHECK.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[DAILY_CHECK.KEY_NAME_BED_GROUP_CD] = this.initialValue[DAILY_CHECK.KEY_NAME_BED_GROUP_CD];
        }
        if (this.editRecord[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST] == null) {
          this.editRecord[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST] = this.initialValue[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST];
        }
        if (this.editRecord[DAILY_CHECK.KEY_NAME_IS_NON] == null) {
          this.editRecord[DAILY_CHECK.KEY_NAME_IS_NON] = this.initialValue[DAILY_CHECK.KEY_NAME_IS_NON];
        }
        if (this.editRecord[DAILY_CHECK.KEY_NAME_IS_FAIL] == null) {
          this.editRecord[DAILY_CHECK.KEY_NAME_IS_FAIL] = this.initialValue[DAILY_CHECK.KEY_NAME_IS_FAIL];
        }
        if (this.editRecord[DAILY_CHECK.KEY_NAME_IS_UNPASS] == null) {
          this.editRecord[DAILY_CHECK.KEY_NAME_IS_UNPASS] = this.initialValue[DAILY_CHECK.KEY_NAME_IS_UNPASS];
        }
        if (this.editRecord[DAILY_CHECK.KEY_NAME_IS_PASS] == null) {
          this.editRecord[DAILY_CHECK.KEY_NAME_IS_PASS] = this.initialValue[DAILY_CHECK.KEY_NAME_IS_PASS];
        }
        if (this.editRecord[DAILY_CHECK.KEY_NAME_KEYWORD] == null) {
          this.editRecord[DAILY_CHECK.KEY_NAME_KEYWORD] = this.initialValue[DAILY_CHECK.KEY_NAME_KEYWORD];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
  mounted() {
  }
};
</script>
