/**
 * デフォルト設定タブ - 患者検索設定のコンポーネント
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
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
              <!--<td class="default-setting-content-title">ベッドグループ</td>-->
                <label id="pc-show-patient-search" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <label id="phone-show-patient-search" class="default-setting-content-label white-space-nowrap">ベッドグループ</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-select
                  v-if="mstBedGroup"
                  class="select-width"
                  v-model="bedGroupCd"
                >
                <!-- mod 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start -->
                  <!-- <option :value="JSON.stringify([])">全ベッド</option>
                  <option
                    v-for="mst in mstBedGroup"
                    :key="mst.roomBedGroupCd"
                    :value="JSON.stringify(mst.bedList)"
                  >
                    {{ mst.roomBedGroupName }}
                  </option> -->
                  <option
                    v-for="mst in mstBedGroup"
                    :key="mst.roomBedGroupCd"
                    :value="mst.roomBedGroupCd"
                  >
                    {{ mst.roomBedGroupName }}
                  </option>
                  <!-- mod 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end -->
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">患者グループ</label>
              </td>
              <td class="default-setting-content">
                <kendo-multiselect
                  v-if="patGroups && selectedPatGroups"
                  v-model="selectedPatGroups"
                  :data-source="patGroups"
                  data-text-field="patGroupName"
                  data-value-field="patGroupCd"
                  @open="getPatGroups"
                />

                <div class="method">
                  <!-- or -->
                  <label class="radio vertical-align-center">
                     <v-ons-radio
                      value="1"
                      modifier="round"
                      v-model="queryPatGroupsMethod"
                      name="conditions"
                    >
                    </v-ons-radio>
                    <span class="label">含む</span>
                  </label>
                  <!-- / or -->

                  <!-- and -->
                  <label class="radio vertical-align-center">
                    <v-ons-radio
                      modifier="round"
                      value="2"
                      v-model="queryPatGroupsMethod"
                      name="conditions"
                    >
                    </v-ons-radio>
                    <span class="label">一致する</span>
                  </label>
                  <!-- / and -->
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">第1ソート条件</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select
                  v-if="sortConditions"
                  v-model="sortConditions[0].key"
                  @change="changeSortKey"
                >
                  <option
                    v-for="option in sortOptions"
                    :key="option.key"
                    :value="option.key"
                  >
                    {{ option.displayValue }}
                  </option>
                </v-ons-select>
                <v-ons-select v-if="sortConditions" v-model="sortConditions[0].isAsc">
                  <option
                    v-for="option in sortOrder"
                    :key="option.displayValue"
                    :value="option.isAsc"
                  >
                    {{ option.displayValue }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">第2ソート条件</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select
                  v-if="sortConditions"
                  v-model="sortConditions[1].key"
                  :disabled="!sortConditions[0].key"
                  @change="changeSortKey"
                >
                  <option
                    v-for="option in sortOptions"
                    :key="option.key"
                    :value="option.key"
                  >
                    {{ option.displayValue }}
                  </option>
                </v-ons-select>
                <v-ons-select
                  v-if="sortConditions"
                  v-model="sortConditions[1].isAsc"
                  :disabled="!sortConditions[0].key"
                >
                  <option
                    v-for="option in sortOrder"
                    :key="option.displayValue"
                    :value="option.isAsc"
                  >
                    {{ option.displayValue }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">第3ソート条件</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-select
                  v-if="sortConditions"
                  v-model="sortConditions[2].key"
                  :disabled="!sortConditions[0].key || !sortConditions[1].key"
                  @change="changeSortKey"
                >
                  <option
                    v-for="option in sortOptions"
                    :key="option.key"
                    :value="option.key"
                  >
                    {{ option.displayValue }}
                  </option>
                </v-ons-select>
                <v-ons-select
                  v-if="sortConditions"
                  v-model="sortConditions[2].isAsc"
                  :disabled="!sortConditions[0].key || !sortConditions[1].key"
                >
                  <option
                    v-for="option in sortOrder"
                    :key="option.displayValue"
                    :value="option.isAsc"
                  >
                    {{ option.displayValue }}
                  </option>
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
   import {mapGetters, mapMutations, mapActions} from "@/compat/vue/vuex";
   /*add FNSI-改修内容4214 任 start*/

   /*add FNSI-改修内容4214 任 end*/
   import {PATIENT_SEARCH,SORT_OPTIONS} from "@/constants/defaultSettingConstants";
   import {deepCopy} from "@/functions/common/CommonFunctions";
   import {ApiHelper} from "@/apis/AxiosHelper";
   import PatGroup from "@/apis/pat-group";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
   import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
   //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
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
      funcName:"患者検索",
      // データ初期値
      initialValue: {
        [PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST]: 0,
        [PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS]: [],
        [PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD]: "2",
        [PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS]: [
          { key: null, isAsc: 1 },
          { key: null, isAsc: 1 },
          { key: null, isAsc: 1 }
        ]
      },
      // 編集する患者検索設定レコード
      editRecord: {
        [PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST]: 0,
        [PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS]: [],
        [PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD]: "2",
        [PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS]: [
          { key: null, isAsc: 1 },
          { key: null, isAsc: 1 },
          { key: null, isAsc: 1 }
        ]
      },
      mstBedGroup: null,
      patGroups: null,
      sortOptions: SORT_OPTIONS,
      sortOrder: [
        { isAsc: 1, displayValue: "昇順" },
        { isAsc: 0, displayValue: "降順" }
      ],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("pat-info", ["patSearchDetails"]),

    // ベッドグループ
    bedGroupCd: {
      get() {
        return this.editRecord[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST];
      },
      set(value) {
        this.editRecord[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] = value;
      }
    },
    // 患者グループ
    selectedPatGroups: {
      get() {
        return this.editRecord[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
      },
      set(value) {
        this.editRecord[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] = value;
      }
    },
    // 患者グループチェックボックス
    queryPatGroupsMethod: {
      get() {
        return this.editRecord[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD];
      },
      set(value) {
        this.editRecord[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] = value;
      }
    },
    // ソート条件
    sortConditions: {
      get() {
        return this.editRecord[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS];
      },
      set(value) {
        this.editRecord[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS] = value;
      }
    }
  },
  methods: {
    ...mapMutations("pat-info", [
      "setPatSearchDetails",
      "addPatSearchDetail"
    ]),
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: PATIENT_SEARCH.KEY_NAME,
        data: {}
      };
      rtnData.data[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] = this.editRecord[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST];
      rtnData.data[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] = this.editRecord[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
      rtnData.data[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] = this.editRecord[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD];
      rtnData.data[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS] = this.editRecord[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS];
      return rtnData;
    },
    async getPatGroups() {
      const { data } = await PatGroup.list(this.facilityCd);
      this.patGroups = data.patGroupInfo;
    },
    changeSortKey() {
      if (!this.sortConditions[0].key) {
        this.sortConditions[1].key = null;
        this.sortConditions[2].key = null;
        return;
      }
      if (!this.sortConditions[1].key) {
        this.sortConditions[2].key = null;
        return;
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
            EventBus.$emit("isChanged", {componentName: "patientSearch", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "patientSearch", value: false});
      },
      deep: true
    }
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // ベッドグループ、患者グループ取得
    const [responseBedGroup, patGroups] = await Promise.all([
      ApiHelper.get("/mstInfo/mstRoomBedGroup", {
        facilityCd: this.facilityCd
      }),
      PatGroup.list(this.facilityCd)
    ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
      getErrorMessage('patientSearchSettingCard.vue', 'created', 'マスタ取得失敗');
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
      throw new Error("[SearchPatSimple.vue]created(): マスタ取得失敗");
    });
    this.mstBedGroup = responseBedGroup.data;
    this.mstBedGroup.unshift({
      roomBedGroupCd: 0,
      roomBedGroupName: "全ベッド"
    });
    this.patGroups = patGroups.data.patGroupInfo;
    
    // Vueのリアクティブシステムがwatchでオブジェクト内のプロパティの変更を検知できるようにObject.assign で既存のオブジェクトのプロパティを更新する
    this.$nextTick(() => {
      const defaultSetting = this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME];
      if (defaultSetting && Object.keys(defaultSetting).length > 0) {
        Object.assign(this.editRecord, deepCopy(defaultSetting));
      } else {
        // データが空の場合は初期値を適用する
        Object.assign(this.editRecord, deepCopy(this.initialValue));
      }

      if (this.editRecord[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] == null) {
        ((this.editRecord)[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] = this.initialValue[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST]);
      }
      if (this.editRecord[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] == null) {
        ((this.editRecord)[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] = this.initialValue[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS]);
      }
      if (this.editRecord[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] == null) {
        ((this.editRecord)[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] = this.initialValue[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD]);
      }
      if (this.editRecord[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS] == null) {
        ((this.editRecord)[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS] = this.initialValue[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS]);
      }
      
      // ベッドグループがマスタから削除されている場合は初期値にする
      if (!this.mstBedGroup.some(item => item.roomBedGroupCd === this.editRecord[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST])) {
        this.editRecord[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] = 0;
      }
      // 患者グループがマスタから削除されている場合は配列内から対象コードを削除
      const validPatGroupCds = this.patGroups.map(item => item.patGroupCd);
      this.editRecord[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] = 
        this.editRecord[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS].filter(value => validPatGroupCds.includes(value));      
      
      // initialValue を更新
      Object.assign(this.initialValue, deepCopy(this.editRecord));

      /*add FNSI-改修内容4214 任 start*/
      if(isScopedElementDisplayInline("phone-show-patient-search", this.$el || this)){
        const phoneShowElement = getScopedElementById("phone-show-patient-search", this.$el || this);

        if (phoneShowElement) {

          phoneShowElement.innerText = phoneShowElement.innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';

        }
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  }
};
</script>

<style scoped>
.select-width {
  min-width: 140px;
  width: 12.4em;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-patient-search{display:none;}
}
@media (min-width: 501px){
  #phone-show-patient-search{display:none;}
}
/*add FNSI-改修内容4214 任 end*/
</style>
