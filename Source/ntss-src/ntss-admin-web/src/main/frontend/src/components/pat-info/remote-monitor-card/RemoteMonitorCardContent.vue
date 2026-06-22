<template>
  <table class="card-table">
      <tbody>
    <tr>
      <td class="item-title">サービス業者</td>
      <td class="item-data">
        <custom-select
          :value="getPatData('remote_monitor_service')"
          :options="optionTypeService"
          :disabled="editFlag"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">ID</td>
      <td class="item-data">
        <custom-input
        ref="remote_monitor_user_id"
        :value="getPatData('remote_monitor_user_id')"
        :disabled="editFlag"
        />
      </td>
    </tr>
    <tr>
      <td class="item-title">パスワード</td>
      <td class="item-data">
      </td>
    </tr>
  
      </tbody></table>
</template>

<script>
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
// add 編集権限の適用 じょはく start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { FUNC_PAT_INFO } from "@/constants/function-code";
import {mapGetters} from "@/compat/vue/vuex";
// add 編集権限の適用 じょはく end

export default {
  name: "RemoteMonitorCard",
  mixins: [baseCardContent],

  data() {
    return {
      // add 編集権限の適用 じょはく start
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      editFlag: null,
      // add 編集権限の適用 じょはく end
      // TODO マスタが存在しないため仮データを投入
      optionTypeService: [
        { value: 0, displayValue: "未選択" },
        { value: 1, displayValue: "セコム" }
      ],

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
  },
  created() {
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // add 編集権限の適用 じょはく end
  },
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/* カード個別のスタイルはここ */
</style>
