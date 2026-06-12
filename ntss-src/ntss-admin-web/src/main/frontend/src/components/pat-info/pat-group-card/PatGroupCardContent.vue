<template>
  <div id="multiselectDivId" class="pat-group-wrapper" :class="isPatGroupCardEdited ? 'pat-group-wrapper-edited' : ''">
    <!--mod 編集権限の適用 じょはく start-->
    <!-- mod #10359 編集権限の動作不正 dengshen start -->
    <!-- <ntss-multi-select -->
    <!--   v-model="sortedPatGroupsSelectedItems" -->
    <!--   :data-source="patGroupsDataSources" -->
    <!--   data-text-field="patGroupName" -->
    <!--   data-value-field="patGroupCd" -->
    <!--   placeholder="患者グループ" -->
    <!--   @open="getPatGroups" -->
    <!--   :disabled="this.editFlag" -->
    <!--   @deselect="onDeselect($event.dataItem.patGroupCd)" -->
    <!--   @select="onSelect($event.dataItem)" -->
    <!-- /> -->
    <kendo-multiselect
      v-model="sortedPatGroupsSelectedItems"
      :data-source="patGroupsDataSources"
      data-text-field="patGroupName"
      data-value-field="patGroupCd"
      placeholder="患者グループ"
      @open="getPatGroups"
      :disabled="!getItemAuthorized('PatInfo', 'item_pat_group_card') || getIsOtherFacility"
      @deselect="onDeselect($event.dataItem.patGroupCd)"
      @select="onSelect($event.dataItem)"
    />
    <!-- mod #10359 編集権限の動作不正 dengshen end -->
    <!--mod 編集権限の適用 じょはく end-->
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters } from "@/compat/vue/vuex";
import PatGroup from "@/apis/pat-group";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";

export default {
  name: "PatGroupCard",
  mixins: [baseCardContent],
  data() {
    return {
      patGroupsDataSources: [],
      patGroupsSelectedItems: [],
      arrayColName: "pat_group_list",
      // add 編集権限の適用 じょはく start
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      isCreatePatViewAuthorized: null,
      editFlag: null,
      // add 編集権限の適用 じょはく end

    };
  },
  // add 編集権限の適用 じょはく start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 じょはく end
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd", "selectedPatId"]),
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    jsonArray: {
      get() {
        return this.editRecord && this.editRecord[this.arrayColName] && this.editRecord[this.arrayColName].filter(record => {
            return this.dataSourceCd.includes(+record.patGroupCd.initValue)
          }
        );
      },
      set(sortedAry) {
        this.editRecord[this.arrayColName] = sortedAry;
      }
    },
    sortedPatGroupsSelectedItems: {
      get() {
        return this.patGroupsDataSources.reduce((acc, patGroup) => {
          const find = this.patGroupsSelectedItems.find(
              // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
              // cd => patGroup.patGroupCd === cd
              cd => patGroup.patGroupCd == cd
              // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
              );
          if (find) {
            acc.push(find);
          }
          return acc;
        }, []);
      },
      set(value) {
        this.patGroupsSelectedItems = value;
      }
    },
    dataSourceCd() {
      return this.patGroupsDataSources.map(p => p.patGroupCd);
    },
    /**
     * 他のカードに合わせて、編集時に緑枠をつけるための判定を行う
     */
    isPatGroupCardEdited() {
      if (this.patRecord && this.patRecord[this.arrayColName] && this.patRecord[this.arrayColName].length === this.editRecord[this.arrayColName].length) {
        for(let idx = 0; idx < this.patRecord[this.arrayColName].length; idx++) {
          if (this.patRecord[this.arrayColName][idx].patGroupCd.initValue !== this.editRecord[this.arrayColName][idx].patGroupCd.editValue){
            return true;
          }
        }
        return false;
      }
      return true;
    }
  },
  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    initPatGroups() {
      let selectedValue = [];
      this.jsonArray.forEach(item => {
        selectedValue.push(item.patGroupCd.initValue);
      });
      this.patGroupsSelectedItems = selectedValue;
    },

    //#9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-06 卓 start
    async getPatGroups() {
      const facilityCd = this.getIsOtherFacility ? this.getOtherFacilityCd : this.facilityCd;
      await PatGroup.list(facilityCd, this.selectedPatId).then(({data}) =>{
        if (data.patGroupInfo){
          this.patGroupsDataSources = data.patGroupInfo;
        }
      });
    },
    //#9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-06 卓 end
    onDeselect(patGroupCd) {
      const index = this.editRecord[this.arrayColName].findIndex(
          // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
          // item => item.patGroupCd.initValue === patGroupCd
          item => item.patGroupCd.initValue == patGroupCd
          // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
          );
      this.editRecord[this.arrayColName].splice(index, 1);
    },
    onSelect(dataItem) {
      const newItem = {
        patGroupCd: String(dataItem.patGroupCd),
        patGroupName: dataItem.patGroupName
      };
      this.pushJsonArray(this.arrayColName, newItem);
      this.editRecord[this.arrayColName] = this.patGroupsDataSources.reduce(
        (acc, patGroup) => {
          const find = this.editRecord[this.arrayColName].find(
              // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
              // p => p.patGroupCd.initValue === patGroup.patGroupCd
              p => p.patGroupCd.initValue == patGroup.patGroupCd
              // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
              );
          if (find) {
            acc.push(find);
          }
          return acc;
        },
        []
      );
    }
  },
  watch: {
    jsonArray() {
      this.initPatGroups();
    },
    getOtherFacilityCd() {
      this.getPatGroups();
    }
  },
  beforeUnmount() {
  },
  async created() {
    // del #10359 編集権限の動作不正 dengshen start
    // // add 編集権限の適用 じょはく start
    // if ( this.isCreationPat ) {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    // } else {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // }
    // // add 編集権限の適用 じょはく end
    // del #10359 編集権限の動作不正 dengshen end

    //#9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-06 卓 start
    await this.getPatGroups();
    this.initPatGroups();
    //#9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-06 卓 end
  }
};
</script>

<style scoped>
.pat-group-wrapper {
  padding: 0.2em;
}
.pat-group-wrapper :deep(.k-multiselect) {
  font-size: 1em;
}
.pat-group-wrapper :deep(.k-legacy-multiselect .k-input-inner.k-input),
.pat-group-wrapper :deep(.k-legacy-multiselect input.k-input) {
  padding: 0.375rem 0.75rem !important;
}
.pat-group-wrapper-edited :deep(.k-multiselect) {
  border: 2px green solid;
  outline: 0;
}
.pat-group-wrapper :deep(.k-input-inner::placeholder) {
  color: #212529;
  opacity: 1;
}
.pat-group-wrapper :deep(.k-input-values){
  background-color: #fff !important;
}
:deep(.k-legacy-multiselect .k-chip-remove-action .k-icon::before),
:deep(.k-legacy-multiselect .k-chip-remove-action .k-svg-icon::before){
  font-size: 24px !important;
  font-weight: 300 !important;
  margin-top: 5.5px;
}
</style>
