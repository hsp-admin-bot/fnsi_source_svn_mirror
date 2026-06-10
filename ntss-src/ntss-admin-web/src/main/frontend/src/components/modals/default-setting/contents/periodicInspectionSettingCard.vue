/**
 * デフォルト設定タブ - 定期点検設定のコンポーネント
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
                <label class="default-setting-content-label">開始日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermStart"
                  v-model="fromDate"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">終了日</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermEnd"
                  v-model="toDate"
                  data-text-field="title"
                  data-value-field="value"
                />
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
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">ベッドグループ</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-select input-id="bedGroupCd" v-model="bedGroupCd">
                  <option
                    v-for="option in mstBedGroup"
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
   import {mapGetters, mapActions} from "vuex";
   import {DATE_CHOICES, PERIODIC_INSPECTION} from "@/constants/defaultSettingConstants";
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
      funcName:"定期点検",
      // データ初期値
      initialValue: {},
      // 編集する定期点検設定レコード
      editRecord: {},
      // 表示期間開始日・選択肢
      lstDispTermStart: [
        DATE_CHOICES.BEFORE_TEN_YEAR,
        DATE_CHOICES.BEFORE_FIVE_YEAR,
        DATE_CHOICES.BEFORE_THREE_YEAR,
        DATE_CHOICES.BEFORE_ONE_YEAR,
        DATE_CHOICES.BEFORE_SIX_MONTH,
        DATE_CHOICES.TODAY
      ],
      // 表示期間終了日・選択肢
      lstDispTermEnd: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.AFTER_SIX_MONTH,
        DATE_CHOICES.AFTER_ONE_YEAR,
        DATE_CHOICES.AFTER_THREE_YEAR,
        DATE_CHOICES.AFTER_FIVE_YEAR,
        DATE_CHOICES.AFTER_TEN_YEAR
      ],
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
        name: PERIODIC_INSPECTION.KEY_NAME,
        data: {}
      };
      rtnData.data[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE] = this.editRecord[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE];
      rtnData.data[PERIODIC_INSPECTION.KEY_NAME_TO_DATE] = this.editRecord[PERIODIC_INSPECTION.KEY_NAME_TO_DATE];
      rtnData.data[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD] = this.editRecord[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD];
      rtnData.data[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST] = this.editRecord[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST];
      return rtnData;
    }
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    fromDate: {
      get() {
        return this.editRecord[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE];
      },
      set(value) {
        this.editRecord[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE] = value;
      }
    },
    toDate: {
      get() {
        return this.editRecord[PERIODIC_INSPECTION.KEY_NAME_TO_DATE];
      },
      set(value) {
        this.editRecord[PERIODIC_INSPECTION.KEY_NAME_TO_DATE] = value;
      }
    },
    bedGroupCd: {
      get() {
        return this.editRecord[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    machineTypeList: {
      get() {
        return this.editRecord[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST];
      },
      set(value) {
        this.editRecord[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST] = value;
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
            EventBus.$emit("isChanged", {componentName: "periodic", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "periodic", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 初期値未設定の場合のデフォルト値
    this.initialValue[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE] = DATE_CHOICES.BEFORE_ONE_YEAR.value; // 1年前
    this.initialValue[PERIODIC_INSPECTION.KEY_NAME_TO_DATE] = DATE_CHOICES.AFTER_ONE_YEAR.value; // 1年後
    this.initialValue[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD] = null;
    this.initialValue[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST] = [];

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
      this.editRecord = deepCopy(this.getDefaultSetting[PERIODIC_INSPECTION.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE] == null) {
          this.editRecord[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE] = this.initialValue[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE];
        }
        if (this.editRecord[PERIODIC_INSPECTION.KEY_NAME_TO_DATE] == null) {
          this.editRecord[PERIODIC_INSPECTION.KEY_NAME_TO_DATE] = this.initialValue[PERIODIC_INSPECTION.KEY_NAME_TO_DATE];
        }
        if (this.editRecord[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD] = this.initialValue[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD];
        }
        if (this.editRecord[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST] == null) {
          this.editRecord[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST] = this.initialValue[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST];
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
