/**
* デフォルト設定タブ - スケールベッド設定のコンポーネント
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
                <label id="pc-show-scale-bed" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <label id="phone-show-scale-bed" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select class="select-width" v-model="bedGroupCd">
                  <option :value="defaultSelect">すべて</option>
                  <option v-for="(option) in selectBedGroup" :key="option.length" :value="option.roomBedGroupCd">
                    {{ option.roomBedGroupName }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
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
import { mapGetters, mapActions } from "vuex";
import $ from "jquery";
import { KEY_NAME_SCALE_BED } from "@/constants/defaultSettingConstants";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { sendRequestGetKurSelector } from "@/apis/send-condition";
import { EventBus } from "@/eventBus.js";

export default {
  name: 'defScaleBedSet',
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
      funcName: "スケールベッド",
      // データ初期値
      initialValue: {},
      // 編集するスケールベッド設定レコード
      editRecord: {},
      // クール項目コンボ用
      selectKurGroup: [],
      // ベッド項目コンボ用
      selectBedGroup: [],
      // カード開閉状態(初期値をfalseにすることでOnsen UI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    defaultSelect: () => 0,
    // クール
    kurGroupList: {
      get() {
        return this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST] = value;
      }
    },
    // ベッドグループ
    bedGroupCd: {
      get() {
        return this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD];
      },
      set(value) {
        this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD] = value;
      }
    },
    // 凡例の表示
    isShowUsageGuide: {
      get() {
        return this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE];
      },
      set(val) {
        this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE] = val;
      }
    }
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen", "finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: KEY_NAME_SCALE_BED.KEY_NAME,
        data: {}
      };
      rtnData.data[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST] = this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST];
      rtnData.data[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD] = this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD];
      rtnData.data[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE] = this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE];
      return rtnData;
    }
  },
  watch: {
    editRecord: {
      handler(newValue, oldValue) {
        var keySet = Object.keys(this.initialValue);
        for (let key of keySet) {
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if (JSON.stringify(initialValue) !== JSON.stringify(editValue)) {
            EventBus.$emit("isChanged", { componentName: "scaleBed", value: true });
            return;
          }
        }
        EventBus.$emit("isChanged", { componentName: "scaleBed", value: false });
      },
      deep: true
    },
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // クール、ベッド設定取得
    await sendRequestGetKurSelector(undefined, this.facilityCd).then(response => {
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

    // 初期値未設定の場合のデフォルト値
    this.initialValue[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST] = [];
    this.initialValue[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD] = 0;
    this.initialValue[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE] = false;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[KEY_NAME_SCALE_BED.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST] == null) {
          this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST] = this.initialValue[KEY_NAME_SCALE_BED.KEY_NAME_KUR_GROUP_LIST];
        }
        if (this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD] == null) {
          this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD] = this.initialValue[KEY_NAME_SCALE_BED.KEY_NAME_BED_GROUP_CD];
        }
        if (this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE] == null) {
          this.editRecord[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE] = this.initialValue[KEY_NAME_SCALE_BED.KEY_NAME_IS_SHOW_GUIDE];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      if ($("#phone-show-scale-bed").css("display") === "inline") {
        document.getElementById("phone-show-scale-bed").innerText = document.getElementById("phone-show-scale-bed").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
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

<style scoped>
.select-width {
  min-width: 140px;
  width: 12.4em;
}

@media (max-width: 500px) {
  #pc-show-scale-bed {
    display: none;
  }
}

@media (min-width: 501px) {
  #phone-show-scale-bed {
    display: none;
  }
}
</style>
