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
              <v-ons-button
                :ref="'btnSelectMst' + index"
                class="common-style-select-button btn3-normal"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                @click="selectImplant(index)"
              >
                選択
              </v-ons-button>
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
        </table>
      </div>
    </draggable>
    <!-- インプラント選択ポップオーバー -->
    <pop-over
      v-bind="popoverData"
      :target-position-element="popoverTargetElement"
      @popover-close="closePopover(popoverData)"
      @popover-return="setImplantCd($event.value)"
    />
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { mapGetters, mapActions } from "vuex"; //施設コード取得のために追加
import moment from "moment";
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
  name: "ImplantCard",
  mixins: [baseCardContent],

  data() {
    return {
      arrayColName: "implant_info",
      popoverData: {},
      mstImplant: null,
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      delMstImplants: null,
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      deleteMstImplant: null,// add by maxueqiang
      selectedIndex: null,
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

    // マスタ選択ポップオーバーの表示位置とする対象コンポーネント
    popoverTargetElement() {
      // 初期表示時は未選択なのでnull
      return this.selectedIndex === null
        ? null
        : this.$refs[`btnSelectMst${this.selectedIndex}`][0];
    },

    /**
     * @description インプラント有無フラグ
     */
    hasImplant() {
      // add bug 5389 修正 chen start
      let momentTd = moment().format("YYYYMMDD");
      // add bug 5389 修正 chen end
      if (
        // mod FNSI-改修内容 バグ対応 趙 start
        // this.jsonArray.length > 0 &&
        // this.jsonArray.some(json => this.getJsonArrayCtlNo(json) >= 0) &&
        // this.jsonArray.some(json => this.getPatDataJsonArray(json, "remove_date").editValue == null)
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
        this.jsonArray.length > 0 &&
        this.jsonArray.some(json => this.getJsonArrayCtlNo(json) >= 0) &&
        this.jsonArray.some(json => this.getPatDataJsonArray(json, "implant_cd").editValue !== null) &&
        (this.jsonArray.some(json => this.getPatDataJsonArray(json, "remove_date").editValue == null) ||
        this.jsonArray.some(json => this.getPatDataJsonArray(json, "remove_date").editValue === "") ||
        // add bug 5389 修正 chen start
          this.jsonArray.some(json => this.getPatDataJsonArray(json, "remove_date").editValue >= momentTd))
        // add bug 5389 修正 chen end
        // mod FNSI-改修内容 バグ対応 趙 end
      ) {
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
        return true;
      }
      return false;
    },

    /**
     * 当日以前の日付を無効化
     */
    disableDatesAfter() {
      return moment().format("YYYYMMDD");
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
    mstImplant() {
      this.popoverData = this.createPopoverData(
        "インプラント",
        null,
        null,
        "内容",
        this.mstImplant,
        "implantCd",
        "implantName",
        null
      );
    },

    /**
     * @description インプラント有無監視
     */
    hasImplant() {
      const isImplant = this.hasImplant ? "1" : "0";
      this.setPatData("is_implant", isImplant);
    },
    // add #12462 患者情報共有 Ji start
    getOtherFacilityCd() {
      this.refreshData();
    },
    // add #12462 患者情報共有 Ji end
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
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add bug #7125 修正 chen end

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
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
          // facilityCd: this.getFacilityCd
          facilityCd: this.getIsOtherFacility ? (this.getOtherFacilityCd ?? this.getFacilityCd) : this.getFacilityCd
        };
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
        const implantCds = this.editRecord[this.arrayColName]
            .filter(value => value !== undefined)
            .map(item => item?.implant_cd?.editValue);
        await ApiHelper.get("/mstInfo/mstImplantIncludeDel", requestParam)
          .then(response => {
            this.deleteMstImplant = response.data;
            this.mstImplant = response.data.filter(item =>{
              return item.isDisp !== "0" && item.isDel !== "1"
            })
            this.delMstImplants = (Array.isArray(this.deleteMstImplant) ? this.deleteMstImplant : [])
                .filter(item => (item.isDisp === "0" || item.isDel === "1")
                    && implantCds.includes(item.implantCd))
                .map(item => ({
                  ...item,
                  implantName: (item.isDisp === "0" || item.isDel === "1")
                      ? `【削除済み】${item.implantName}`
                      : item.implantName,
                }));
          // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
          })
          .catch(error => {
            getErrorMessage('ImplantCardContent.vue', 'created', error);
            throw error;
          });
          // add 6283 マスタ選択のダイアログが選択ボタン位置ではなく画面左上に表示される 周安寧 start
          this.selectedIndex = null;
          // add 6283 マスタ選択のダイアログが選択ボタン位置ではなく画面左上に表示される 周安寧 end
      } catch (error) {
        this.setLoadingScreenVisible(false);
      }
      // this.initRecord = deepCopy(this.editRecord);
      this.setLoadingScreenVisible(false);
    },
    // add bug #7125 修正 chen end

    selectImplant(index) {
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      this.popoverData.popoverContentDataset = this.popoverData.popoverContentDataset.filter(
          item => !item.text.includes("【削除済み】")
      );
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      // selectedIndexを初期化することでgetPopoverTargetElement()で再計算を行い
      // マスタ選択のダイアログが正しい位置に表示されるようにする
      this.selectedIndex = null;

      // 選択ボタンを押した位置を保持
      this.selectedIndex = index;
      const implantCd = this.getPatDataJsonArray(this.jsonArray[this.selectedIndex], "implant_cd").editValue;
      this.popoverData.popoverContentSelected.value = implantCd;
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      if (this.jsonArray[index]) {
        const matchedRelations  = this.delMstImplants.filter(item => item.implantCd === implantCd);
        if (matchedRelations.length > 0) {
          this.popoverData.popoverContentDataset.push({
            value: matchedRelations[0].implantCd,
            text: matchedRelations[0].implantName,
            fnValue: "",
          })
        }
      }
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      // ポップオーバーを表示
      this.showPopover(this.popoverData);
    },

    // ポップオーバー確定イベントハンドラ
    setImplantCd(selectedCd) {
      // 選択ボタンを押した項目にインプラント内容を設定
      this.setPatDataJsonArray(
        this.jsonArray[this.selectedIndex],
        "implant_cd",
        selectedCd
      );
    },

    implantName(json) {
      // modify by maxueqiang
      // mod FNSI7516-profile連携（XML）で受信した詳細情報（インプラント） 周 start
      //return this.mstCdToNameIncludeDeleted(this.deleteMstImplant, this.getPatDataJsonArray(json, 'implant_cd').editValue, 'implantCd', 'implantName')
      let implantCd = this.getPatDataJsonArray(json, 'implant_cd').editValue - 0;
      // implantCd = "0"(新規行追加)の場合
      if (implantCd === 0) { implantCd = null }
      return this.mstCdToNameIncludeDeleted(this.deleteMstImplant, implantCd, 'implantCd', 'implantName');
      // mod FNSI7516-profile連携（XML）で受信した詳細情報（インプラント） 周 end
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
</style>
