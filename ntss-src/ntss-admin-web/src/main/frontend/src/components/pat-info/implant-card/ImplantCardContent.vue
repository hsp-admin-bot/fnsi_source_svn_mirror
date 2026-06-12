<template>
  <div>
    <draggable
      v-model="jsonArray"
      v-bind="{
        animation: 200,
        delay: 10,
        disabled: !actionMode,
        forceFallback: true
      }"
    >
      <div
        v-for="(json, index) in jsonArray"
        :key="index"
        :class="classObjectItem(json)"
      >
        <table class="card-table">
          <tbody>
          <tr class="card-index-row">
            <td colspan="3">
              {{
                index + 1
              }}
              <button
                v-show="actionMode"
                class="button-delete ntss-btn-outset"
                @click="deleteJsonArray(arrayColName, json, index)"
              >
                <v-ons-icon icon="fa-trash"/>
              </button>
              <br />
            </td>
          </tr>
          <tr>
            <td class="item-title">内容</td>
            <td class="item-data">
              <custom-simple-textarea-a
                ref="implant_cd"
                :value="getPatDataJsonArray(json, 'implant_cd')"
                :display-string="implantName(json)"
                :is-required="json.ctl_no.editValue >= 0"
                form-name="内容"
                :disabled="true"
                style="vertical-align: middle; color: #1f1f21;"
              />
            </td>
            <td class="choice-button-area">
              <common-master-selector
                :masterType="MasterType.IMPLANT_PAT_INFO"
                :facilityCd="getIsOtherFacility ? (getOtherFacilityCd ?? getFacilityCd) : getFacilityCd"
                :initItem="{ value: getPatDataJsonArray(json, 'implant_cd').initValue }"
                :editItem="{ value: getPatDataJsonArray(json, 'implant_cd').editValue }"
                :btnName="'選択'"
                :isVisible="false"
                :btnClass="'common-style-select-button btn3-normal'"
                :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                @popover-return="setImplantCd($event, index)"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">導入日</td>
            <td colspan="2" class="item-data">
              <custom-input-date
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :value="getPatDataJsonArray(json, 'reg_date')"
                form-name="導入日"
              />
            </td>
          </tr>
          <tr>
          <td class="item-title">除去日</td>
            <td colspan="2" class="item-data">
              <custom-input-date
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :value="getPatDataJsonArray(json, 'remove_date')"
                form-name="終了日"
              />
            </td>
          </tr>
          
          </tbody>
        </table>
      </div>
    </draggable>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { mapGetters, mapActions } from "@/compat/vue/vuex"; //施設コード取得のために追加
import dayjs from "@/compat/date/dayjs";
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

export default {
  name: "ImplantCard",
  components: {
    "common-master-selector": commonMasterSelector
  },
  mixins: [baseCardContent],

  data() {
    return {
      arrayColName: "implant_info",
      MasterType,
      deleteMstImplant: null,// add by maxueqiang
      // implantData: [],
      // add 編集権限の適用 じょはく start
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      isCreatePatViewAuthorized: null,
      editFlag: null,
      // add 編集権限の適用 じょはく end
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      isInitFinished: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

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
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId", "getIsOtherFacility", "getOtherFacilityCd"]),
    jsonArray: {
      get() {
        return this.editRecord[this.arrayColName];
      },

      set(sortedAry) {
        this.editRecord[this.arrayColName] = sortedAry;
      }
    },
    /**
     * @description インプラント有無フラグ（期間内の有効レコードが1件以上あるか）
     */
    hasImplant() {
      const todayYmd = dayjs().format("YYYYMMDD");
      return (
        this.jsonArray.length > 0 &&
        this.jsonArray.some(json => this.isImplantRecordInPeriod(json, todayYmd))
      );
    },

    /**
     * 当日以前の日付を無効化
     */
    disableDatesAfter() {
      return dayjs().format("YYYYMMDD");
    },

    implantArray() {
      return this.implantData;
    }
  },

  // マスタ取得完了後にポップオーバーオブジェクトを作成
  watch: {
    selectedPatId() {
      this.refreshData();
    },
    getOtherFacilityCd() {
      this.refreshData();
    },

    /**
     * @description インプラント有無監視（初回表示時も is_implant を同期）
     */
    hasImplant: {
      handler() {
        this.syncIsImplantFlag();
      },
      immediate: true
    }
  },

  async created() {
    this.refreshData()
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
    this.implantData = [];
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    this.isInitFinished = true;
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
  },
  // add bug #7125 修正 chen start
  beforeUnmount() {
  },
  // add bug #7125 修正 chen end

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    /** 日付を YYYYMMDD 形式に正規化（比較用） */
    normalizeImplantDateYmd(value) {
      if (value == null || value === "") {
        return null;
      }
      const ymd = String(value).replace(/-/g, "");
      return ymd.length >= 8 ? ymd.substring(0, 8) : ymd;
    },
    /**
     * 1件のインプラントが期間内か（導入日≦今日≦除去日、除去日未設定は継続中）
     */
    isImplantRecordInPeriod(json, todayYmd) {
      if (this.getJsonArrayCtlNo(json) < 0) {
        return false;
      }
      if (this.getPatDataJsonArray(json, "implant_cd").editValue == null) {
        return false;
      }
      const regDate = this.normalizeImplantDateYmd(
        this.getPatDataJsonArray(json, "reg_date").editValue
      );
      if (regDate == null || regDate > todayYmd) {
        return false;
      }
      const removeDate = this.normalizeImplantDateYmd(
        this.getPatDataJsonArray(json, "remove_date").editValue
      );
      if (removeDate == null) {
        return true;
      }
      return removeDate >= todayYmd;
    },
    /** pat_main.is_implant を hasImplant の結果で更新 */
    syncIsImplantFlag() {
      const isImplant = this.hasImplant ? "1" : "0";
      this.setPatData("is_implant", isImplant);
    },
    // 項目追加処理
    addItem() {
      // 新規項目作成
      const newItem = {
        ctl_no: 0,
        disp_order: 0,
        implant_cd: null,
        reg_date: null,
        remove_date: null
      };
      this.pushJsonArray(this.arrayColName, newItem);
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      try {
        const requestParam = {
          facilityCd: this.getIsOtherFacility ? (this.getOtherFacilityCd ?? this.getFacilityCd) : this.getFacilityCd,
          selectedPatId: this.selectedPatId
        };
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
        await ApiHelper.get("/mstInfo/mstImplantIncludeDel", requestParam)
          .then(response => {
            this.deleteMstImplant = response.data;
            // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
          })
          .catch(error => {
            getErrorMessage('ImplantCardContent.vue', 'created', error);
            throw error;
          });
      } catch (error) {
        this.setLoadingScreenVisible(false);
      }
      // this.initRecord = deepCopy(this.editRecord);
      this.setLoadingScreenVisible(false);
    },
    // add bug #7125 修正 chen end

    // ポップオーバー確定イベントハンドラ
    setImplantCd(selected, index) {
      // 選択ボタンを押した項目にインプラント内容を設定
      this.setPatDataJsonArray(
        this.jsonArray[index],
        "implant_cd",
        selected?.value
      );
      this.setPatDataJsonArray(
        this.jsonArray[index],
        "implant_name",
        selected?.text
      );
    },

    implantName(json) {
      let implantCd = this.getPatDataJsonArray(json, 'implant_cd').editValue - 0;
      // implantCd = "0"(新規行追加)の場合
      if (implantCd === 0) { implantCd = null }
      return this.mstCdToNameIncludeDeleted(
        this.deleteMstImplant,
        implantCd,
        'implantCd',
        'implantName'
      );
    }
  }
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/* カード個別のスタイルはここ */
/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
td .custom-textarea-edited {
  border: 2px green solid;
}
td .custom-textarea-required {
  background-color: #ffff99;
}
td .custom-textarea-invalid {
  background-color: rgba(255, 0, 0, 0.5);
}
.card-table .card-index-row td {
  padding: 0;
}
</style>
