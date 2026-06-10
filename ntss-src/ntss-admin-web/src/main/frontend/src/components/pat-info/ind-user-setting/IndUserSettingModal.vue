<template>
  <div class="modal-container">
    <div class="color-header modal-header-custom">
      <label>指示者設定</label>
    </div>
    <div class="text-col">{{title}}</div>
    <div class="text2-col">指示者を選択してください。</div>
    <div class="data-col">
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-select -->
      <!--   input-id="indUser" -->
      <!--   class="selectbox select-data" -->
      <!--   v-model="selectedIndUser" -->
      <!-- > -->
      <v-ons-select
        input-id="indUser"
        class="selectbox select-data custom-select-required"
        v-model="selectedIndUser"
        :disabled="!getItemAuthorized('Indication', 'default_authority')"
      >
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <option
          v-for="(user, userKey) in indUserList"
          :key="userKey"
          :value="user.userId"
        >{{ user.name }}</option>
      </v-ons-select>
    </div>
    <div class="modal-footer-custom">
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="button-cancel btn2-cancel"
            @click="$emit('hide-modal');"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   class="common-style-ok-button btn3-normal button-confirm" -->
          <!--   @click="save();$emit('hide-modal');" -->
          <!-- > -->
          <v-ons-button
            class="common-style-ok-button btn3-normal button-confirm"
            @click="save();"
            :disabled="!getItemAuthorized('Indication', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import ons from "onsenui";
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import {AUTHORITY_CODES} from "@/constants/userAuthority";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapMutations } from "vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";
// del #10359 編集権限の動作不正 dengshen start
// import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
// del #10359 編集権限の動作不正 dengshen end
/**
 * @description // TODO:
 */
export default {
  // add 9664 by kangjie 20240103 start
  props:["title"],
  // add 9664 by kangjie 20240103 end
  // add #10359 編集権限の動作不正 dengshen start
  mixins: [IndUserSelectMixin],
  // add #10359 編集権限の動作不正 dengshen end
  data() {
    return {
      selectedIndUser: ""
    };
  },

  computed: {
    ...mapGetters("pat-info", ["indUserList"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"])
  },

  async created() {
    // mod #10359 編集権限の動作不正 dengshen start
    // // ログインユーザが医師の場合は自身を初期選択とする
    // const userList = this.indUserList
    // const userId = this.getStateUserAccountInfo.userId;
    // // デフォルト指示者取得
    // const defaultDoctor = await sendRequestGetMstFacilitySettingValue(this.getStateUserAccountInfo.facilityCd,"1025");
    // let index = userList.findIndex(e => e.userId === userId);
    // if (index === -1) {
    //   index = userList.findIndex(e => e.userId === defaultDoctor.data);
    // }
    // if (index === -1) {
    //   index = 0
    // }
    // this.selectedIndUser = userList[index].userId;
    this.getIndUserList(
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.IND_PEDIT
    ).then(response => {
      this.$nextTick(() => {
        this.selectedIndUser = response.iniSelectId;
      });
    });
    // mod #10359 編集権限の動作不正 dengshen end
  },

  methods: {
    ...mapMutations("pat-info", ["setIndUserId","setIsIndUserSetting"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    save() {
      // 指示者 必須入力チェック
      if (!this.selectedIndUser) {
        // title: "必須項目未入力",
        // message: "{$1}は必須入力項目です。\n必ず値を入力してください。"
        const { title, message } = DIALOG_MESSAGES[22010001];
        ons.notification.alert({
          title,
          message: messageFormat(message, "指示者"),
        });
        return false;
      }
      
      // 選択された指示者をstoreに格納
      this.setIndUserId(this.selectedIndUser);
      this.setIsIndUserSetting(true);
      
      // 親へ通知
      this.$emit("hide-modal");
    }
  }
};
</script>

<style scoped>
.modal-container {
  font-size: 1.5em;
  height: auto;
  width: 300px;
  color: var(--ntss-base-color);
  transform: none;
}
.modal-header-custom {
  text-align: left;
  color: white;
  background-color: black;
  padding: 3px;
  height: auto;
  width: auto;
  position: initial;
}
.text-col {
  padding-top: 1em;
}
.text2-col {
  padding-bottom: 1em;
}
.data-col {
  width: auto;
  padding-bottom: 1em;
}
.select-data {
  width: 230px;
}
.modal-footer-custom {
  padding: 10px;
}
.button-cancel {
  float: left;
  width: 6em;
}
.button-confirm {
  float: right;
}
</style>
