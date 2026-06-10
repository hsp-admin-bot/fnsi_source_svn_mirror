<template>
  <modal-base @onClose="cancel" :showFooter="false" class="custom-modal">
    <div slot="body" class="personal-settings-body">
      <table class="table-userInfo">
        <tbody>
          <tr>
            <td class="title">
              <label>ユーザーID：</label>
            </td>
            <td valign="bottom" colspan="10">
              <div class="flex-container">
                <div class="userId">
                  <v-ons-input
                    input-id="dispUserId"
                    type="text"
                    float
                    v-model="inputModel.dispUserId"
                  />
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <td class="title">
              <label>氏名ﾌﾘｶﾞﾅ:</label>
            </td>
            <td colspan="5">
              <v-ons-input
                input-id="userLastNameKana"
                type="text"
                float
                v-model="inputModel.userLastNameKana"
              />
            </td>
            <td colspan="5">
              <v-ons-input
                input-id="userFirstNameKana"
                type="text"
                float
                v-model="inputModel.userFirstNameKana"
              />
            </td>
          </tr>
          <tr>
            <td class="title">
              <label>氏名:</label>
            </td>
            <td colspan="5">
              <v-ons-input
                input-id="userLastName"
                type="text"
                float
                v-model="inputModel.userLastName"
              />
            </td>
            <td colspan="5">
              <v-ons-input
                input-id="userFirstName"
                type="text"
                float
                v-model="inputModel.userFirstName"
              />
            </td>
          </tr>
          <tr>
            <td class="title">
              <label>氏名英字:</label>
            </td>
            <td colspan="5">
              <v-ons-input
                input-id="userLastNameAlpha"
                type="text"
                float
                v-model="inputModel.userLastNameAlpha"
              />
            </td>
            <td colspan="5">
              <v-ons-input
                input-id="userFirstNameAlpha"
                type="text"
                float
                v-model="inputModel.userFirstNameAlpha"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapGetters } from "vuex";

export default {
  name: "accountEdit",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {};
  },
  computed: {
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "getValidationResults"
    ])
  },
  methods: {
    cancel() {
      this.hideModal();
    }
  },
  created() {
    this.inputModel = {
      userId: this.getStateUserAccountInfo.userId,
      dispUserId: this.getStateUserAccountInfo.dispUserId,
      userType: this.getStateUserAccountInfo.userType,
      administrator: this.getStateUserAccountInfo.administrator,
      userLastName: this.getStateUserAccountInfo.userLastName,
      userFirstName: this.getStateUserAccountInfo.userFirstName,
      userLastNameKana: this.getStateUserAccountInfo.userLastNameKana,
      userFirstNameKana: this.getStateUserAccountInfo.userFirstNameKana,
      userLastNameAlpha: this.getStateUserAccountInfo.userLastNameAlpha,
      userFirstNameAlpha: this.getStateUserAccountInfo.userFirstNameAlpha
    };

    this.checkedAuthority = this.getStateUserAccountInfo.userSettings.authorized_authorities;
  },
  mounted() {}
};
</script>

<style scoped>
select {
  border: 0;
  padding: 0;
  border: solid 1px #ccc;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
}
.h1 {
  font-size: 1.5rem;
  margin: 0;
}
p {
  margin: 0;
}
.required {
  font-size: 0.8rem;
  margin: 0px 0px 15px 0px;
}
.table-userInfo {
  width: 100%;
}
.title {
  width: 7em;
  font-size: 1.5em;
}
.form-input {
  font-size: 1rem;
}
/**
   * 切替ボタン.
   */
.btn-switch {
  display: inline;
  text-align: left;
}
/* セレクトボックスのスタイル定義 */
.selectbox {
  height: 2em;
  font-size: 150%;
}
.userId {
  width: 100%;
  margin-right: 5px;
}
</style>
