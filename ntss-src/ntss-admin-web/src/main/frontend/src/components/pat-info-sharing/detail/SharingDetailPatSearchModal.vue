<template>
  <modal-base
    @onClose="closePatSearchModal"
    class="send-condition-pat-modal-base"
  >
    <div slot="header">
      <component :is="header"></component>
    </div>
    <div slot="body" class="modal-body-wrapper">
      <div id="send-condition-pat-modal-search-area">
        <div class="filter-content date-value search-input-group">
          <label class="input-label">フリーワード</label>
          <v-ons-input
            type="text"
            v-model.lazy="searchCondition.freeWord"
            float
          ></v-ons-input>
        </div>
        <div class="filter-content flex-align-center search-input-group">
          <label class="input-label">性別</label>
          <v-ons-select v-model.lazy="searchCondition.gender">
            <option :value="null">すべて</option>
            <option
              v-for="(option, index) in genderList"
              :key="index"
              :value="option.value"
            >
              {{ option.displayValue }}
            </option>
          </v-ons-select>
        </div>
        <div class="filter-content flex-align-center search-input-group">
          <label class="input-label">血液型</label>
          <v-ons-select v-model.lazy="searchCondition.bloodType">
            <option :value="null">すべて</option>
            <option
              v-for="(option, index) in bloodTypeList"
              :key="index"
              :value="option.value"
            >
              {{ option.displayValue }}
            </option>
          </v-ons-select>
        </div>
        <div class="filter-content flex-align-center search-input-group">
          <label class="input-label">生年月日（開始）</label>
          <div>
            <date-input
              id="birthdayFrom"
              class="ntss-input-date ntss-control-size"
              v-model.lazy="searchCondition.birthdayFrom"
              @handleClearInput="searchCondition.birthdayFrom = null"
            />
            <common-calendar v-model="searchCondition.birthdayFrom" />
          </div>
        </div>
        <div class="filter-content flex-align-center search-input-group">
          <label class="input-label">生年月日（終了）</label>
          <div>
            <date-input
              id="birthdayTo"
              class="ntss-input-date ntss-control-size"
              v-model.lazy="searchCondition.birthdayTo"
              @handleClearInput="searchCondition.birthdayTo = null"
            />
            <common-calendar v-model="searchCondition.birthdayTo" />
          </div>
        </div>
        <div class="filter-content flex-align-center search-input-group">
          <label class="input-label">住所</label>
          <v-ons-input
            type="text"
            float
            v-model.lazy="searchCondition.address"
          ></v-ons-input>
        </div>
      </div>
      <div class="table-scroll-container">
        <div v-if="filteredPatInfoList.length === 0" class="no-data-msg">
          該当する患者情報が見つかりません。
        </div>
        <table class="send-condition-pat-modal-list" :style="{ top: 0 + 'px' }">
          <thead>
            <tr>
              <th
                v-for="column in columns"
                :key="column.key"
                class="ntss-list-header-th-sticky"
                :style="{ width: column.width + 'em' }"
              >
                <div class="resizable-header">
                  <span
                    @click="sortBy(column.key)"
                    class="clickable-header-label"
                    :class="sortedClass(column.key)"
                  >
                    {{ column.colName }}
                  </span>
                </div>
              </th>
            </tr>
          </thead>
          <tr
            v-for="(patInfo, idx) in sortedPatInfoList"
            :key="idx"
            :id="'pat-modal-row-' + idx"
            class="pat-modal-row"
            :class="{ 'pat-modal-selected-row': selectedRowIndex === idx }"
            @click="onClickRow(patInfo, idx)"
            style="height: 1.1rem"
          >
            <td
              v-for="column in columns"
              :class="'ntss-list-body-td-pat-serch-selected-row'"
              :key="column.className"
            >
              {{ column.text(patInfo) }}
              <template v-if="column.key === 'patName'">
                <img
                  v-if="patInfo.isSame === '1'"
                  class="same-icon"
                  :src="image_src_same"
                  style="vertical-align: middle; margin-left: 4px"
                />
              </template>
            </td>
          </tr>
        </table>
      </div>
    </div>

    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background: none">
        <v-ons-button
          class="btn2-cancel common-style-cancel-button"
          @click="closePatSearchModal"
        >
          キャンセル
        </v-ons-button>
      </div>
      <div class="registration-btn-area" style="background: none">
        <v-ons-button
          class="button btn1-execute registration-btn btn-save"
          @click="savePatSearchModal"
          :disabled="this.selectedRowIndex === null"
        >
          保存
        </v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions, mapMutations } from "vuex";
import {
  PAT_BLOOD_TYPE_ABO_OPTIONS,
  PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS,
} from "@/constants/PatInfo.js";
import { EventBus } from "@/eventBus.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import DateInput from "@/components/common/DateInput.vue";
import {
  updateSort,
  getSortedClass,
  sortableCompare,
} from "@/functions/SortFunctions";

export default {
  name: "sharingDetailPatSearchModal",
  components: {
    "common-calendar": commonCalender,
    "modal-base": ModalBase,
    "date-input": DateInput,
  },
  data() {
    return {
      header: "",
      originalTitle: "",
      searchCondition: {
        freeWord: "",
        gender: null,
        bloodType: null,
        birthdayFrom: "",
        birthdayTo: "",
        address: "",
      },
      selectedRowIndex: null,
      genderList: [...PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS],
      bloodTypeList: [...PAT_BLOOD_TYPE_ABO_OPTIONS],
      bloodTypeAbo: { 0: "不明", 1: "A型", 2: "B型", 3: "O型", 4: "AB型" },
      bloodTypesRh: { 0: "不明", 1: "(Rh+)", 2: "(Rh−)" },
      gender: { 0: "不明", 1: "男性", 2: "女性" },
      sort: {
        key: "",
        isAsc: true,
      },
      checkedOrdValue: [],
      initialized: false,
      image_src_same: require("../../../assets/name_duplication.png"),
    };
  },
  computed: {
    ...mapGetters("send-condition/weight", ["getSelectedMstWeight"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    ...mapGetters("pat-info-sharing", ["getOurPatList"]),
    columns() {
      return [
        {
          key: "hospPatId",
          colName: "患者ID",
          className: "hospPatIdBody",
          width: 2,
          text: (src) => src.hospPatId,
        },
        {
          key: "patName",
          colName: "患者名(同姓同名アイコン)",
          className: "patLastNameBody",
          width: 3,
          text: (src) => src.patName,
        },
        {
          key: "gender",
          colName: "性別",
          className: "patGender",
          width: 2,
          text: (src) => src.genderName,
        },
        {
          key: "bloodTypeAbo",
          colName: "血液型",
          className: "patBloodType",
          width: 2,
          text: (src) => src.bloodTypeName,
        },
        {
          key: "birthday",
          colName: "生年月日",
          className: "patBirthdayBody",
          width: 2,
          text: (src) => src.birthday,
        },
        {
          key: "address",
          colName: "住所",
          className: "patAddressCls",
          width: 4,
          text: (src) => src.address,
        },
      ];
    },
    filteredPatInfoList() {
      let shrInfoList = this.mapPatientList(this.getOurPatList);
      const cond = this.searchCondition;
      return shrInfoList.filter((item) => {
        const filterFrom = cond.birthdayFrom
          ? cond.birthdayFrom.replace(/-/g, "")
          : "";
        const filterTo = cond.birthdayTo
          ? cond.birthdayTo.replace(/-/g, "")
          : "";
        const patBirth = item.compareBirthday || "";
        const matchesFreeWord =
          !cond.freeWord ||
          (item.hospPatId && item.hospPatId.includes(cond.freeWord)) ||
          (item.patName && item.patName.includes(cond.freeWord));
        const matchesGender =
          cond.gender === null || item.gender === cond.gender;
        const matchesBlood =
          cond.bloodType === null || item.bloodTypeAbo === cond.bloodType;
        const matchesBirthFrom =
          !filterFrom || (patBirth !== "" && patBirth >= filterFrom);
        const matchesBirthTo =
          !filterTo || (patBirth !== "" && patBirth <= filterTo);
        const matchesAddress =
          !cond.address ||
          (item.address && item.address.includes(cond.address));
        return (
          matchesFreeWord &&
          matchesGender &&
          matchesBlood &&
          matchesBirthFrom &&
          matchesBirthTo &&
          matchesAddress
        );
      });
    },
    sortedPatInfoList() {
      const list = this.filteredPatInfoList.slice();
      const sortField = this.sort.key;
      if (this.sort.key) {
        list.sort((a, b) => {
          let options = {};
          if (sortField === "patName") {
            options.notUseSortKeyMap = true;
          }
          if (sortField === "bloodTypeName") {
            return this.compareBloodType(a, b);
          }
          options.reverseFields = ["isSame"];
          return sortableCompare(a, b, sortField, this.sort.isAsc, options);
        });
      }
      return list;
    },
  },
  methods: {
    ...mapActions("multi-sub-modal", ["hideModal"]),
    ...mapActions("send-condition/weight", ["setFocus"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapMutations("multi-modal", ["setTitle"]),
    /**
     * 患者リストマッピング処理
     */
    mapPatientList(rawList) {
      return rawList.map((item) => {
        return {
          hospPatId: item.hosp_pat_id,
          patId: item.patId,
          patName: (item.pat_last_name + " " + item.pat_first_name).trim(),
          isSame: item.is_same,
          gender: item.pat_sex,
          genderName: this.gender[item.pat_sex] || "",
          bloodTypeAbo: item.pat_blood_type_abo,
          bloodTypesRh: item.pat_blood_type_rh,
          bloodTypeName:
            (this.bloodTypeAbo[item.pat_blood_type_abo] || "") +
            (this.bloodTypesRh[item.pat_blood_type_rh] || ""),
          birthday: item.pat_birthday,
          compareBirthday: item.birthday,
          facilityCdTo: String(item.shareToCount),
          facilityCdFrom: String(item.shareFromCount),
          shrPending: String(item.pendingCount),
          address: item.address,
          prohibitedCount: String(item.prohibitedCount),
        };
      });
    },
    /**
     * ソート状態クラス取得処理
     */
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    /**
     * カラムソート処理
     */
    sortBy(key) {
      updateSort(key, this.sort);
    },
    /**
     * 行クリック処理
     */
    onClickRow(src, idx) {
      this.selectedRowIndex = idx;
    },
    /**
     * 血液型比較処理
     */
    compareBloodType(a, b) {
      const aboOrder = {
        1: 0, // A
        2: 1, // B
        3: 2, // O
        4: 3, // AB
        0: 4, // 不明
      };
      const rhOrder = {
        1: 0, // Rh+
        2: 1, // Rh−
        0: 2, // 不明
      };
      const main =
        (aboOrder[a.bloodTypeAbo] ?? 4) - (aboOrder[b.bloodTypeAbo] ?? 4);
      if (main !== 0) return main;
      return (rhOrder[a.bloodTypesRh] ?? 2) - (rhOrder[b.bloodTypesRh] ?? 2);
    },
    /**
     * 患者検索モーダルクローズ処理
     */
    closePatSearchModal() {
      EventBus.$emit("shrPatSearchCancelEvent");
      this.hideModal();
    },
    /**
     * 患者検索モーダル保存処理
     */
    async savePatSearchModal() {
      if (this.selectedRowIndex != null) {
        await this.setLoadingScreenVisible(true);
        const selectedPatient = this.sortedPatInfoList[this.selectedRowIndex];
        const selectedPatId = selectedPatient.patId;
        EventBus.$emit("shrPatSearchSaveEvent", selectedPatId);
        this.hideModal();
        await this.setLoadingScreenVisible(false);
      }
    },
  },
  created() {
    this.originalTitle = this.$store.state["multi-modal"].modalTitle;
    this.setTitle("患者選択");
  },
  beforeDestroy() {
    this.setTitle(this.originalTitle);
    this.initialized = false;
  },
};
</script>

<style scoped>
.send-condition-pat-modal-list {
  table-layout: fixed;
  width: 100%;
}
.send-condition-pat-modal-list tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
.pat-modal-row {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-list-body-color);
}
#send-condition-pat-modal-search-area {
  padding: 3px 5px 8px 2px !important;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}
.filter-content {
  margin-left: 12px;
}
.date-value {
  flex: 0 0 11em;
  white-space: nowrap;
  display: flex;
  align-items: center;
}
.clickable-header-label {
  display: block;
  width: 100%;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
  cursor: pointer;
}
.send-condition-pat-modal-list tr:hover {
  background-color: rgba(0, 0, 0, 0.1) !important;
}
.pat-modal-selected-row {
  background-color: rgba(0, 123, 255, 0.25) !important;
  color: #333 !important;
}
.ntss-list-body-td-pat-serch-selected-row {
  border: solid 1px var(--ntss-list-border-color);
  padding: 8px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  background-color: transparent;
}
.no-data-msg {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 100%;
  text-align: center;
  color: #888;
  font-size: 1.1rem;
  pointer-events: none;
  z-index: 10;
}
.search-input-group {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}
.input-label {
  font-size: 15px !important;
  margin-bottom: 4px;
  line-height: 1;
}
.date-value {
  display: flex !important;
  flex-direction: column !important;
  align-items: flex-start !important;
  height: auto !important;
}
::v-deep .same-icon {
  flex-shrink: 0;
  width: 16px;
  height: 16px;
  margin-left: 4px;
  vertical-align: middle;
  object-fit: contain;
  padding-bottom: 4px;
}
.common-style-cancel-button {
  width: 100px;
}
.modal-body-wrapper {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}
.table-scroll-container {
  flex: 1;
  overflow-y: auto;
  position: relative;
}
</style>
