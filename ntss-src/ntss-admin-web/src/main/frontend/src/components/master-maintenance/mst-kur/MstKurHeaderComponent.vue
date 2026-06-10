/**
* クールマスタメンテナンスページ用ヘッダ
*/
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="button btn3-normal doctor-shift-style"
            @click="showDoctorMessage"
          >
            医師シフト設定
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import PopoverMixin from "@/components/PopoverMixin";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [PopoverMixin],
  data() {
    return {
      popoverTarget: null,
      popoverDirection: "down",
      condition: {
        recordName: "",
        includeDeleted: false
      },
      isSortMode: false
    };
  },
  computed: {
    ...mapGetters("mst-kur", {
      isChanged:"getIsChanged"
    })
  },
  methods: {
    ...mapActions("multi-modal", [
      "showKurDoctorComponent"
    ]),
    showDoctorMessage(){
      if (this.isChanged) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "常勤医設定編集不可",
          // message: "未保存のデータがあるため常勤医設定は編集できません。\n編集内容を保存するか、破棄してから操作してください。"
          title: DIALOG_MESSAGES['00200067'].title,
          message: messageFormat(DIALOG_MESSAGES['00200067'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // this.setEditKurList(this.kurList)
      // 跳转到选择医师的弹窗
      this.showKurDoctorComponent();

    },
  },
  created() {
  },
  destroyed() {
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<style scoped>
.doctor-shift-style {
  position: absolute;
  right: 70px;
  top: 50%;
  transform: translateY(-50%);
  line-height: 1.5em;
  font-size: 1.5em;
  width: auto;
  margin-right: 3px;
}
</style>
