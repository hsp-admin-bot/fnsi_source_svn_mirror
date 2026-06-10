<!-- 身体情報カード -->

<template>
    <div border="2">
      <table class="table-area">
        <tr>
          <th class="date-time-area">検査日時</th>
          <th class="dw-area">DW<br />[kg]</th>
          <th class="ctr-area">CTR<br />[%]</th>
          <th class="ctr_weight-area">検査時体重<br />[kg]</th>
          <th class="height-area">身長<br />[cm]</th>
          <th class="edit-area"></th>
        </tr>
        <tr
          v-for="(json, index) in sortedJsonArray"
          v-show="showIndex(index)"
          :key="index"
          :class="classObjectItem(json)"
        >
          <!-- 検査日時 -->
          <td class="date-time-area">
            {{ displayDateValue(json) }}
            {{ displayTimeValue(json) }}
          </td>
          <!-- DW -->
          <td class="dw-area">
            {{ displayValue(json, "dw", 2) }}
          </td>
          <!-- CTR -->
          <td class="ctr-area">
            {{ displayValue(json, "ctr", 2) }}
          </td>
          <!-- 検査時体重 -->
          <td class="ctr_weight-area">
            {{ displayValue(json, "ctr_weight", 2) }}
          </td>
          <!-- 身長 -->
          <td class="height-area">
            {{ displayValue(json, "height", 1) }}
          </td>
          <!-- 編集ボタン -->
          <td
            v-if="getPatDataJsonArray(json, 'ctl_no').editValue >= 0"
            class="edit-area"
          >
            <!-- <v-ons-button
              v-if="getItemAuthorized('PatInfo', 'default_authority')"
              class="common-style-select-button ntss-custom-button-table btn3-normal"
              @click="editItem(json, index)"
            >
              編集
            </v-ons-button> -->
            <v-ons-button
              v-if="getItemAuthorized('PatInfo', 'default_authority')"
              class="common-style-select-button ntss-custom-button-table btn3-normal"
              @click="editItem(json, index)"
            >
              {{ isOtherFacilityRow(json) ? '表示' : '編集' }}
            </v-ons-button>
            <v-ons-button
              v-if="!getItemAuthorized('PatInfo', 'default_authority')"
              class="common-style-select-button ntss-custom-button-table btn3-normal"
              @click="editItem(json, index)"
            >
              詳細
            </v-ons-button>
          </td>
        </tr>
      </table>

      <div>
        <button class="ntss-btn-outset" @click="onPrePage()">＜</button>
        ({{ showMinNumber + 1 }}-{{ showMaxPageNumber }} /{{
          totalNumber
        }})
        <button class="ntss-btn-outset" @click="onNextPage()">＞</button>
      </div>
    </div>
</template>

<script>
import _ from "underscore";
import moment from "moment";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { mapGetters, mapMutations, mapActions } from "vuex";
import {deepCopy, getAuthorized} from "@/functions/common/CommonFunctions";
import { toFixed } from "@/functions/common/NumberFunctions.js";
// del #10359 編集権限の動作不正 dengshen start
// import {FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE} from "@/constants/function-code";
// import {AUTHORITY_CODES} from "@/constants/userAuthority";
// del #10359 編集権限の動作不正 dengshen end
export default {
  name: "PhysicalInfoCard",
  mixins: [baseCardContent],

  data() {
    return {
      showNumber: 10,
      showMinNumber: 0,
      showMaxNumber: 9,
      beforeTotalNumber: null,
      arrayColName: "physical_info",
      physicalInfoVisible: false,
      physicalInfoData: {
        ctl_no: 0,
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
        inspect_date:null,
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang end
        exam_date: null,
        exam_day: null,
        exam_time: null,
        order_class: null,
        height: null,
        ctr_weight: null,
        breast_dia: null,
        chest_dia: null,
        ctr: null,
        dw: null,
        pre_scale_upper: null,
        pre_scale_lower: null,
        indicator_cd: null,
        indicator_start_date: null,
        memo: null,
        facility_cd: null
      },
      selectedJson: "",
      selectedIndex: "",
      addEditC: "0",
      // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓 start
      // add 編集権限の適用 じょはく start
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      isCreatePatViewAuthorized: null,
      // del #10359 編集権限の動作不正 dengshen start
      // editFlag: null,
      // del #10359 編集権限の動作不正 dengshen end
      // add 編集権限の適用 じょはく end
      // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓  end
    };
  },
  // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓 start
  // add 編集権限の適用 じょはく start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 じょはく end
  // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓  end

  computed: {
    // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓 start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓  end
    ...mapGetters("pat-info", [
      "selectedPatId",
      "selectedPhysicalInfoData"
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("multi-modal", ["isModalOpened"]),

    jsonArray: {
      get() {
        return this.editRecord[this.arrayColName];
      },

      set(sortedAry) {
        this.editRecord[this.arrayColName] = sortedAry;
      }
    },

    sortedJsonArray() {
      const array = this.jsonArray;
      return array.sort((a, b) => {
        const dateA = this.formatterDay(a);
        const timeA =
          this.formatterTime(a) === null ? "0000" : this.formatterTime(a);
        const dateB = this.formatterDay(b);
        const timeB =
          this.formatterTime(b) === null ? "0000" : this.formatterTime(b);

        return `${dateB}${timeB}` - `${dateA}${timeA}`;
      });
    },

    /**
     * @description ページ数
     * @returns { Number }
     */
    totalNumber() {
      return this.jsonArray.length;
    },
    showMaxPageNumber(){
      if(this.jsonArray.length-(this.showMinNumber+1)>9){
        // console.log(">>>>>>>>>>>>>>>>>>>>>>>>>>>")
        return this.showMaxNumber+1;
      }else{
        // console.log("<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        return this.jsonArray.length;
      }
    },
    /**
     * @description DW最新日付フラグ
     * @returns { Boolean }
     */
    isDwMaxDate() {
      return this.physicalInfoData.exam_date === null
        ? false
        : this.dwMaxDate === this.physicalInfoData.exam_date.editValue;
    },

    /**
     * @description 一覧からDWの最新日付を返す
     * @returns { String }
     */
    dwMaxDate() {
      if (this.jsonArray.length === 0) {
        return null;
      }

      const dwList = this.jsonArray.filter(json => json.dw.editValue !== null);
      if (dwList.length === 0) {
        return null;
      }

      const json = _.max(dwList, el => {
        if (this.formatterTime(el) === null) {
          return this.formatterDay(el);
        }
        return this.formatterDay(el) + this.formatterTime(el);
      });
      return json.exam_date.editValue;
    }
  },

  watch: {
    isModalOpened(isModalOpened) {
      if (!isModalOpened && this.physicalInfoVisible) {
        this.jsonArray = deepCopy(this.selectedPhysicalInfoData.jsonArray);
        this.physicalInfoVisible = false;
      }
    },
    patRecord: {
      handler(val) {
        if (!val) return;
        this.initRecord = {
          [this.arrayColName]: deepCopy(this.sortedJsonArray) || []
        };
      },
      immediate: true
    },
  },

  async created() {
    this.beforeTotalNumber = this.totalNumber;
    // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓 start
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
    // // #9819 add 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓  end
    // del #10359 編集権限の動作不正 dengshen end

  },

  methods: {
    ...mapMutations("pat-info", [
      "setIsUpdate",
      "setOperation",
      "setSelectedPat",
      "setSelectedPhysicalInfoData"
    ]),
    ...mapActions("multi-modal", ["showPhysicalInfoAddEditForPatInfo"]),

    addItem() {
      // PatInfoCardList.vue: addItem()
      this.addEditC = "1";
      this.setSelectedPhysicalInfoData({
        addEditC: this.addEditC,
        isLatestDW: this.isDwMaxDate,
        physicalInfo: null,
        jsonArray: this.jsonArray
      });
      this.showPhysicalInfoAddEditForPatInfo();
      this.physicalInfoVisible = true;
    },

    /**
     * @description 日付フォーマット
     * @param {Object} json
     * @returns {String}
     */
    formatterDay(json) {
      return moment(
        json.exam_date.editValue,
        "YYYY-MM-DDTHH:mm:ss.SSSZ"
      ).format("YYYYMMDD");
    },

    /**
     * @description 時間フォーマット
     * @param {Object} json
     * @returns {String}
     */
    formatterTime(json) {
      const date = json.exam_date.editValue;
      const time = date.match(/T/);

      if (time === null) {
        return null;
      }
      return moment(date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format("HHmm");
    },

    editItem(json, index) {
      this.setOperation(index);
      this.setIsUpdate(true);
      let day = null;
      let time = null;
      const nullObj = {
        initValue: null,
        editValue: null
      };
      if (json.exam_date.editValue !== null) {
        day = this.formatterDay(json);
        time = this.formatterTime(json);
      }
      const exam_day = {
        initValue: day,
        editValue: day
      };
      const exam_time = {
        initValue: time,
        editValue: time
      };

      let facility_cd = null;
      if (json.facility_cd === null || json.facility_cd === undefined) {
        facility_cd = {
          initValue: null,
          editValue: null
        };
      } else {
        facility_cd = json.facility_cd;
      }
    // add FNSI-改修内容5661修正 chen　start
      let inspect_date = null;
      if (json.inspect_date === null || json.inspect_date === undefined) {
        inspect_date = {
          initValue: null,
          editValue: null
        };
      } else {
        inspect_date = json.inspect_date;
      }
    // add FNSI-改修内容5661修正 chen　end
      let target_weight = null;
      if (json.target_weight === null || json.target_weight === undefined) {
        target_weight = {
          initValue: null,
          editValue: null
        };
      } else {
        target_weight = json.target_weight;
      }
      this.addEditC = "2";
      this.physicalInfoData = {
        ctl_no: json.ctl_no,
        exam_date: json.exam_date,
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
        inspect_date: inspect_date,
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang end
        exam_day,
        exam_time,
        order_class: json.order_class,
        height: json.height,
        ctr_weight: json.ctr_weight,
        breast_dia: json.breast_dia,
        chest_dia: json.chest_dia,
        ctr: json.ctr,
        dw: json.dw,
        pre_scale_upper: json.pre_scale_upper,
        pre_scale_lower: json.pre_scale_lower,
        target_weight: target_weight,
        indicator_cd: json.indicator_cd || nullObj,
	// add #12462 患者情報共有 Ji start
        indicator_name: json.indicator_name || nullObj,
	// add #12462 患者情報共有 Ji end
        indicator_start_date: json.indicator_start_date || nullObj,
        memo: json.memo,
        facility_cd: facility_cd
      };
      this.selectedJson = json;
      this.selectedIndex = index;

      this.setSelectedPhysicalInfoData({
        addEditC: this.addEditC,
        isLatestDW: this.isDwMaxDate,
        physicalInfo: this.physicalInfoData,
        jsonArray: this.jsonArray
      });
      this.showPhysicalInfoAddEditForPatInfo();
      this.physicalInfoVisible = true;
    },

    onNextPage() {
      if (this.showMaxNumber < this.jsonArray.length - 1) {
        this.showMinNumber += this.showNumber;
        this.showMaxNumber += this.showNumber;
      }
    },

    onPrePage() {
      if (this.showMinNumber > 0) {
        this.showMinNumber -= this.showNumber;
        this.showMaxNumber -= this.showNumber;
      }
    },

    displayDateValue(json) {
      const date = this.getPatDataJsonArray(json, "exam_date").initValue;

      return date === null
        ? null
        : moment(date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format("YYYY/MM/DD");
    },

    displayTimeValue(json) {
      const date = this.getPatDataJsonArray(json, "exam_date").initValue;
      const time = date.match(/T/);
      if (time === null) {
        return null;
      }
      return date === null
        ? null
        : moment(date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format("HH:mm");
    },

    // 表示用に変換
    displayValue(json, key, decimalDigits) {
      const value = this.getPatDataJsonArray(json, key).initValue;
      // return value === null ? null : toFixed(value, decimalDigits);
      return value ? toFixed(value, decimalDigits) : null;
    },

    /**
     * @description 表示箇所
     * @param {int} index 配列要素番号
     */
    showIndex(index) {
      if (this.totalNumber < this.beforeTotalNumber) {
        // 件数が減少時、強制的に表示箇所を変更
        if (
          this.showMinNumber > this.jsonArray.length &&
          this.showMinNumber > 0
        ) {
          // 最小表示番号より全体が少ない場合、最小番号を変更また、
          // 0より低い場合は表示できなくなるため、減算しない
          this.showMinNumber -= this.showNumber;
          this.showMaxNumber -= this.showNumber;
          this.beforeTotalNumber = this.totalNumber;
        }
      } else if (this.totalNumber > this.beforeTotalNumber) {
        // 件数増加時
        this.beforeTotalNumber = this.totalNumber;
      }
      return this.showMinNumber <= index && index <= this.showMaxNumber;
    },


    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #12462 患者情報共有 Ji start
    /**
     * @description 該当行が他院情報かどうかを判定
     * @param {Object} json - 患者情報
     * @returns {Boolean} true = 他施設のデータは参照のみ
     */
    isOtherFacilityRow(json) {
      return json.facility_cd?.initValue !== this.facilityCd;
    }
    // add #12462 患者情報共有 Ji end
  }
};
</script>

<style scoped>
.table-area {
  border-collapse: collapse;
  width: 100%;
}
th,
td {
  border: 1px solid;
  text-align: center;
}

.date-time-area {
  width: 20%;
}

.ctr_weight-area {
  width: 20%;
}

.dw-area,
.ctr-area,
.height-area,
.edit-area {
  width: 15%;
}

@media screen and (max-width: 540px) {
  .ntss-custom-button-table {
    width: 100% !important;
    padding: 0.1em 0.1em 0 0.1em !important;
    min-width: auto !important;
  }
}
</style>
