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
          <!-- mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 start -->
          <button
            v-show="actionMode"
            class="button-delete ntss-btn-outset"
            @click="setJsonIndex(json, index)"
          >
            <v-ons-icon icon="fa-trash"/>
          </button>
          <!-- mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 end -->
          <br />
          <tr>
            <td class="item-title">担当者名</td>
            <td class="item-data">
              <custom-simple-textarea-a
                :value="getPatDataJsonArray(json, 'staff_cd')"
                :display-string="staffName(json)"
                :disabled="true"
                ref="user_name"
                :is-required="json.ctl_no.editValue >= 0"
                form-name="担当者名"
                style="vertical-align: middle; color: #1f1f21;"
              />
            </td>
            <td class="item-data choice-button-area">
              <v-ons-button
                :ref="'btnSelectMst' + index"
                class="common-style-select-button btn3-normal"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                @click="selectStaff(index)"
              >
                選択
              </v-ons-button>
            </td>
          </tr>
          <tr>
            <td></td>
            <td class="item-data charge-staff-check-area" style="display: flex; flex-flow: wrap;">
              <custom-checkbox
                :value="getPatDataJsonArray(json, 'is_main')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority')|| getIsOtherFacility"
                checked-value="1"
                unchecked-value="0"
              >
                主治医
              </custom-checkbox>
              <custom-checkbox
                :value="getPatDataJsonArray(json, 'is_charge')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority')|| getIsOtherFacility"
                checked-value="1"
                unchecked-value="0"
              >
                担当
              </custom-checkbox>
              <custom-checkbox
                :value="getPatDataJsonArray(json, 'is_puncture')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority')|| getIsOtherFacility"
                checked-value="1"
                unchecked-value="0"
              >
                穿刺
              </custom-checkbox>
            </td>
          </tr>
        </table>
      </div>
    </draggable>
    <!-- 担当者選択ポップオーバー -->
    <pop-over
      v-bind="popoverData"
      :target-position-element="popoverTargetElement"
      @popover-close="closePopover(popoverData)"
      @popover-return="setStaff"
    />
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

export default {
  name: "ChargeStaffCard",
  mixins: [baseCardContent],

  data() {
    return {
      arrayColName: "charge_staff_info",
      popoverData: {},
      staffNameMap: {},
      mstUserNameQueue: [],
      selectedIndex: null,
      mstJob: null,
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 じょはく start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 じょはく end
      // del #10359 編集権限の動作不正 dengshen end

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
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", [
      "selectedPatId",
      "getIsOtherFacility"
    ]),
    jsonArray: {
      get() {
        // mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 start
        let arrVendorContact = [];
        for (var VendorInf of this.editRecord[this.arrayColName]) {
          arrVendorContact.push(VendorInf);
        }
        return arrVendorContact;
        // mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 end
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

    popoverJobFilter() {
      // ポップオーバのフィルタデータを取りまとめる
      const all = { text: "すべて", value: 0 };
      const filterArr = [
        all,
        ...this.mstJob.map(item => ({
          text: item.jobName,
          value: String(item.jobCd)
        }))
      ];

      // ドロップダウン選択肢設定
      const popoverFilter = [
        {
          popoverFilterLabel: "職種",
          popoverFilterDataset: filterArr
        }
      ];

      return popoverFilter;
    },
  },

  created() {
    this.refreshData();
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
        staff_cd: null,
        is_main: "0",
        is_charge: "0",
        is_puncture: "0"
      };
      this.pushJsonArray(this.arrayColName, newItem);
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      try {
        const staffCdList = [];
        this.jsonArray.forEach(json => {
          const staffCd = this.getPatDataJsonArray(json, "staff_cd").editValue;
          if (staffCd !== null) {
            staffCdList.push(staffCd);
          }
        });
        const facility_cd = this.getFacilityCd;
        const [
          responseJob,
        ] = await Promise.all([
          ApiHelper.get(`/master_maintenance/mst_user/mst_job/${facility_cd}`),
          this.addMstUserNameQueue(staffCdList),
        ]).catch(error => {
          getErrorMessage("ChargeStaffCardContent.vue", "refreshData", error);
          throw error;
        });
        this.mstJob = responseJob.data;
      } catch (error) {
      } finally {
        this.setLoadingScreenVisible(false);
      }
      this.initRecord = deepCopy(this.editRecord);
    },
    // add bug #7125 修正 chen end
    async addMstUserNameQueue(staffCdOrList) {
      // コード単体を渡された場合は配列に入れる
      // すでにAPI処理対象となっているコードは除外する
      const staffCdList = (
        (staffCdOrList instanceof Array) ? staffCdOrList : [staffCdOrList]
      ).filter(staffCd => !this.mstUserNameQueue.includes(staffCd));
      if (!staffCdList.length) return;

      const already = this.mstUserNameQueue.length;
      this.mstUserNameQueue.push(...staffCdList);
      // すでにAPI処理中だった場合はキューに追加するのみで終了する
      if (already) return;

      // 非同期処理開始
      this.setLoadingScreenVisible(true);
      // APIの呼び出しの分断を抑えるため
      // レンダリング時のjsonArrayのループが一旦終わるのを待つ
      await this.$nextTick();
      while (this.mstUserNameQueue.length) {
        const targetCount = this.mstUserNameQueue.length;
        // ApiHelper.post のパラメータとして this.mstUserNameQueue を直接使用すると
        // ApiHelper.post 呼び出しの直後に this.mstUserNameQueue の内容が変化した際に
        // ApiHelper.post 処理内の非同期処理の影響なのか
        // 変化した後の this.mstUserNameQueue の内容が使われる場合があるようなので
        // ApiHelper.post 呼び出し専用にクローンしておく
        const userIdList = [...this.mstUserNameQueue];
        const responseUserName = await ApiHelper.post(
          "/mstInfo/mstPersonalUserByIdList",
          userIdList
        );
        if (responseUserName) {
          responseUserName.data.forEach(this.setStaffNameMap);
        }
        // API処理し終わった部分をキューから削除する
        this.mstUserNameQueue.splice(0, targetCount);
      }
      this.setLoadingScreenVisible(false);
    },
    setStaffNameMap(user) {
      if (user?.userId) {
        // 利用者マスタデータから姓名取得する
        this.$set(this.staffNameMap, "" + user.userId, this.mstUserToName(user));
      } else if (user?.value) {
        // 担当者選択の選択肢データから名称取得する
        this.$set(this.staffNameMap, "" + user.value, user.text);
      }
    },
    mstUserToName(user) {
      const mstUser = [user];
      const idField = "userId";
      const staffCd = user[idField];
      const lastName = this.mstCdToNameIncludeDeleted(mstUser, staffCd, idField, "userLastName");
      const firstName = this.mstCdToNameFreeWord(mstUser, staffCd, idField, "userFirstName");
      return (lastName == null || firstName == null) ? null : `${lastName} ${firstName}`;
    },

    async selectStaff(index) {
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      this.selectedIndex = null;
      // 選択ボタンを押した位置を保持
      this.selectedIndex = index;
      // mod 11872 利用者指定IFのデフォルト選択状態 zkm start
      // const staffCd = this.getPatDataJsonArray(this.jsonArray[this.selectedIndex], "staff_cd").editValue;
      let staffCd = this.getPatDataJsonArray(this.jsonArray[this.selectedIndex], "staff_cd").editValue;

      //liyanze-z add flag is used userID  
      let isUsedUserInfoID = false;
      if ('' === staffCd || null == staffCd) {
        staffCd = this.getStateUserAccountInfo.userId;
        isUsedUserInfoID = true
      }
      // mod 11872 利用者指定IFのデフォルト選択状態 zkm end
      // const mstPersonalUserResponse = await ApiHelper.get("/mstInfo/mstPersonalUser", { facility_cd: this.getFacilityCd });
      const mstPersonalUserResponse = await ApiHelper.get("/mstInfo/mstPersonalUserIncludeDel", { facility_cd: this.getFacilityCd });
      const mstUser = mstPersonalUserResponse?.data.filter(item => {
        return item.isDisp == '1' || item.userId == staffCd
      }).map(item => ({
        ...item,
        userLastName: item.isDisp === "0"
            ? `【削除済み】${item.userLastName}`
            : item.userLastName,
      })) || [];
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      this.popoverData = this.createPopoverData(
        "担当者",
        null,
        null,
        "担当者名",
        mstUser,
        "userId",
        "userLastName",
        // 絞り込みデータ
        "jobCd",
        // 名前表示用
        "userFirstName"
      );
      // ドロップダウン選択肢設定
      this.popoverData.popoverFilter = this.popoverJobFilter;
      // ドロップダウン選択肢に紐づけるvalueを設定
      this.popoverData.popoverContentDataset.forEach(
        item => item.fnValue = { "職種": item.fnValue }
      );
      this.popoverData.popoverContentSelected.value = staffCd;

      // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  start 
      this.popoverData.isUsedUserInfoID = isUsedUserInfoID;
      // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  end 

      // ポップオーバーを表示
      this.showPopover(this.popoverData);
    },

    // ポップオーバー確定イベントハンドラ
    setStaff(selectedData) {
      const selectedCd = selectedData.value;
      // 選択ボタンを押した項目に担当者を設定
      this.setPatDataJsonArray(
        this.jsonArray[this.selectedIndex],
        "staff_cd",
        selectedCd
      );
      if (selectedCd) {
        this.setStaffNameMap(selectedData);
      }
    },

    // スタッフコードを名字と名前に変換する
    staffName(json) {
      const staffCd = this.getPatDataJsonArray(json, "staff_cd").editValue;
      // 未選択の場合はnullを返す
      if (!staffCd) return null;
      const key = "" + staffCd;
      if (!this.staffNameMap.hasOwnProperty(key)) {
        // まだstaffNameMapに存在しないコードの場合はAPIで取得する処理を非同期に開始しておく
        this.addMstUserNameQueue(staffCd);
      }
      return this.staffNameMap[key] || null;
    },
    getMainStaff() {
      for (const json of this.jsonArray) {
        if (this.getPatDataJsonArray(json, "is_main").editValue === "1") {
          return this.getPatDataJsonArray(json, "staff_cd").editValue;
        }
      }
      // 条件式でfalseになるとundefinedを返し、DB内でエラーになるためnullを返す
      return null;
    },
    setJsonIndex(json, index) {
      this.selectJson = json;
      this.selectIndex = index;
      this.deleteJsonArray( this.arrayColName, this.selectJson, this.selectIndex );
    },
  },
  watch: {
    selectedPatId() {
      this.switchingSelectedPatFlg = true;
      this.refreshData();
      this.$nextTick(() => {
        this.switchingSelectedPatFlg = false;
      });
    },
  }
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/* カード個別のスタイルはここ */
.charge-staff-check-area label {
  display: flex;
  flex-flow: nowrap;
  align-items: center;
  margin-right: 0.5em;
}
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
