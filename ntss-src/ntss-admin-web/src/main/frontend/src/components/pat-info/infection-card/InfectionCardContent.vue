<template>
  <div>
    <custom-checkbox
      v-if="!displayMode"
      :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
      :value="getPatData('is_infect')"
      checked-value="1"
      unchecked-value="0"
    >
      感染症患者として扱う
    </custom-checkbox>
    <table>
      <tr>
        <th class="item-area">項目</th>
        <th class="infect-area">結果</th>
        <th class="date-area">検査日</th>
        <th class="update-area">更新日</th>
      </tr>
      <template v-if="mstInfection !== null">
        <infection-item
          v-for="(json, index) in infectInfo"
          :key="index"
          :update="formatDate(getPatDataJsonArray(json, 'up_date').editValue)"
          :infection-name="
            mstCdToName(
              mstInfection,
              getPatDataJsonArray(json, 'infection_cd').initValue,
              'infectionCd',
              'infectionName'
            )
          "
          :infection="getPatDataJsonArray(json, 'infect')"
          :examdate="getPatDataJsonArray(json, 'exam_date')"
          :display-mode="displayMode"
          :edit-flag="!getItemAuthorized('PatInfo', 'default_authority')"
          :other-facility="getIsOtherFacility"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </template>
    </table>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import moment from "moment";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import infectionItem from "@/components/pat-info/infection-card/InfectionItem.vue";
import { mapGetters, mapActions } from "vuex"; //施設コード取得のために追加
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

export default {
  name: "InfectionCard",
  components: {
    "infection-item": infectionItem
  },

  mixins: [baseCardContent],

  props: {
    displayMode: {
      type: Boolean,
      default: false
    },
    // add 編集権限の適用 じょはく start
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
    // add 編集権限の適用 じょはく end
  },

  data() {
    return {
      mstInfection: null,
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

  computed: {
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    // add FNSI-修復施設切換Bug 関 start
    ...mapGetters("pat-info", [
      "selectedFacilityCd",
      //#【EOL対応】6835 zhou add start
      "selectedPatId",
       //#【EOL対応】6835 zhou add end
       // add #12462 患者情報共有 Ji start
      "getIsOtherFacility",
      "getOtherFacilityCd"
      // add #12462 患者情報共有 Ji end
    ]),
    // add FNSI-修復施設切換Bug 関 end
    /**
     * 感染症情報 setter/getter
     */
    infectInfo: {
      get() {
        return this.editRecord.infect_info;
      },

      set(value) {
        this.editRecord.infect_info = value;
      }
    },

    /**
     * @description 結果のある感染症の件数
     */
    infectionNum() {
      return this.infectInfo.filter(
        infection => infection.infect.editValue === "2"
      ).length;
    }
  },
  //#【EOL対応】6835 zhou add start
  watch: {
    selectedPatId() {
      this.switchingSelectedPatFlg = true;
      this.refreshData();
      this.$nextTick(() => {
        this.switchingSelectedPatFlg = false;
      });
    },
    // add #12462 患者情報共有 Ji start
    getOtherFacilityCd() {
      this.refreshData();
    },
    // add #12462 患者情報共有 Ji end
  },
  //#【EOL対応】6835 zhou add end
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
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    this.isInitFinished = true;
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
  },

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // 更新日をセット
    // ※保存時に呼び出す
    setRegDate() {
      const regdate = moment().format("YYYYMMDD");
      // 全ての感染症情報をループ
      this.infectInfo.forEach(infection => {
        if (
          infection.infect.initValue !== infection.infect.editValue ||
          infection.exam_date.initValue !== infection.exam_date.editValue
        ) {
          // 結果または検査日が変更されているなら更新日を変更
          this.setPatDataJsonArray(infection, "up_date", regdate);
        }
      });
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      try {
        const requestParam = {
          // mod FNSI-修復施設切換Bug 関 start
          // facilityCd: this.getFacilityCd
	  // mod #12462 患者情報共有 Ji start
          // facilityCd: this.selectedFacilityCd == "" ? this.getFacilityCd : this.selectedFacilityCd
          // mod FNSI-修復施設切換Bug 関 end
          facilityCd: this.getIsOtherFacility ? (this.getOtherFacilityCd ?? this.getFacilityCd) : this.getFacilityCd
	  // add #12462 患者情報共有 Ji end
        };
        const response = await ApiHelper.get(
          "/mstInfo/mstInfection",
          requestParam
        ).catch(() => {
          getErrorMessage('InfectionCardContent.vue', 'created', "感染症マスタ取得失敗");
          throw new Error(
            "[InfectionCardContent.vue]created(): 感染症マスタ取得失敗"
          );
        });
        this.mstInfection = response.data;
      // add 8331 患者情報の感染症で削除済みの項目がSi側で表示される 関 start
      // infectInfoをマスタ基準で作り変える
      // ※マスタ表示順切り替え対応
      const infectInfoOrg = this.infectInfo;
      this.infectInfo = [];
      // TODO: 感染症マスタを表示順でループ
      // ⇒ mst_selector(?)から取れば表示順になるなはず
      for (const mst of this.mstInfection) {
        // infectInfoから一致するコードを探す
        const targetInfection = infectInfoOrg.find(infection => {
          return infection.infection_cd.initValue === mst.infectionCd;
        });
        let infection_cd;
        let infect;
        let exam_date;
        let up_date;
        if (targetInfection === undefined) {
          // infectInfoにないコード(患者新規登録時、または新規追加されたマスタ)の場合は結果不明で追加
          infection_cd = mst.infectionCd;
          infect = "0";
          exam_date = null;
          up_date = null;
        } else {
          // 存在するコードはそのまま追加
          infection_cd = targetInfection.infection_cd.initValue;
          infect = targetInfection.infect.initValue;
          exam_date = targetInfection.exam_date.initValue;
          up_date = targetInfection.up_date.initValue;
        }
        const infection = {
          infection_cd,
          infect,
          exam_date,
          up_date
        };
        this.pushJsonArray("infect_info", infection);
        }
        // add 8331 患者情報の感染症で削除済みの項目がSi側で表示される 関  end
      } catch (error) {
        this.setLoadingScreenVisible(false);
      }
      this.initRecord = deepCopy(this.editRecord);
      this.setLoadingScreenVisible(false);
    },
    // add bug #7125 修正 chen end

    formatDate(date) {
      return date === null ? null : moment(date).format("YYYY/MM/DD");
    }
  }
};
</script>

<style scoped>
table {
  border-collapse: collapse;
  width: 100%;
}
table th,
table td {
  border: solid 1px;
}

.update-area {
  width: 10%;
}

.item-area {
  width: 50%;
}

.infect-area {
  width: 15%;
}

.date-area {
  width: 25%;
}
</style>
