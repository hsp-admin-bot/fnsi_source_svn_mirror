<template>
  <modal-base @onClose="onClickClose">
    <template #body>
      <div class="main-content">
      <div class="expandable-content">
        <table class="ntss-list">
          <thead>
            <tr>
              <th class="ntss-list-header-th">有効</th>
              <th class="ntss-list-header-th">No</th>
              <th class="ntss-list-header-th" style="width: 160px;">測定日時</th>
              <th class="ntss-list-header-th" style="width: 100px;">再循環率</th>
              <th class="ntss-list-header-th" style="width: 100px;">血流量</th>
              <th class="ntss-list-header-th">コメント</th>
            </tr>
          </thead>
          <tr v-for="(item, index) in re_loop_info" :key="index" class="ntss-list-body-tr">
            <td class="ntss-list-body-td">
              <v-ons-checkbox
                type="checkbox"
                :input-id="'checkbox-' + index"
                :value="item.bio_moni_ctl_no"
                @click="check(item.bio_moni_ctl_no)"
                v-model="item.is_check"
              ></v-ons-checkbox>
            </td>
            <td class="ntss-list-body-td text-right">{{ ++index }}</td>
            <td class="ntss-list-body-td text-right">{{ formatDate(item.date) }}</td>
            <td class="ntss-list-body-td text-right">{{ item.recirculation_rate }}%</td>
            <td class="ntss-list-body-td text-right">{{ item.blood_flow }}</td>
            <td class="ntss-list-body-td">
              <input type="text" class="input-comment" v-model="item.reloop_comment" />
            </td>
          </tr>
        </table>
      </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="onClickClose">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!isChanged" @click="onClickReflect">確認</v-ons-button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import { mapActions } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  DATE_TIME_FORMAT,
  dateFormat
} from "@/functions/common/DateTimeUtils.js";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [DiscardConfirmationMixin, MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      oldDatas: {},
      newDatas: {},
      re_loop_info: {}
    };
  },
  async created() {
    if (this.getOrdNo) {
      const response = await ApiHelper.get(
        `/re-loop-rate-main-comments/${this.getOrdNo}`).catch(error => {
        // console.log(error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('BvmsGraphCommentCreateModalComponent.vue','created',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
      });
      this.oldDatas = { ...response.data };
      Array(this.oldDatas).forEach(old => {
        let weightInfo = old.weightInfo;
        let comments = old.comments;
        weightInfo.reloop_info = JSON.parse(weightInfo.reloop_info);
        Object.values(weightInfo.reloop_info).forEach(rel => {
          rel.is_check =
            weightInfo.re_loop_rate_main === rel.bio_moni_ctl_no ? true : false;
          Object.values(comments).forEach(cm => {
            rel.date = cm.date;
            rel.recirculation_rate = cm.recirculation_rate;
            rel.blood_flow = cm.blood_flow;
          });
        });
      });
      this.newDatas = JSON.parse(JSON.stringify(this.oldDatas));
      this.re_loop_info = this.newDatas.weightInfo.reloop_info;
    }
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  computed: {
    isChanged() {
      return JSON.stringify(this.newDatas) !== JSON.stringify(this.oldDatas);
    }
  },
  methods: {
    ...mapActions("treatment-record/bvms", ["updateListComment"]),
    check(id) {
      Array(this.newDatas.weightInfo).forEach(n => {
        Object.values(n.reloop_info).forEach(rel => {
          if (rel.bio_moni_ctl_no !== id) rel.is_check = false;
          else rel.is_check = true;
        });
      });
    },
    onClickClose() {
      if (this.isChanged) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "更新確認",
          title: DIALOG_MESSAGES[13000035].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000035].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              this.hideModal();
            }
          }
        });
      } else {
        this.hideModal();
      }
    },
    formatDate(date) {
      return dateFormat.format(new Date(date), DATE_TIME_FORMAT);
    },
    async onClickReflect() {
      const requestDatas = Array(this.newDatas.weightInfo).map(w => {
        let rateMain = null;
        Object.values(w.reloop_info).forEach((rel, index) => {
          if (rel.is_check) {
            rateMain = rel.bio_moni_ctl_no;
          } else {
            rel.reloop_comment = this.oldDatas.weightInfo.reloop_info[
              index
            ].reloop_comment;
          }
        });

        const reloopInfo = Object.values(w.reloop_info).map(re => {
          return {
            bio_moni_ctl_no: re.bio_moni_ctl_no,
            reloop_comment: re.reloop_comment
          };
        });

        return {
          weight_measure_before: w.weight_measure_before,
          weight_before: w.weight_before,
          weight_before_date: w.weight_before_date,
          weight_measure_after: w.weight_measure_after,
          weight_after: w.weight_after,
          weight_after_date: w.weight_after_date,
          ctr: w.ctr,
          ctr_measure_date: w.ctr_measure_date,
          ctr_weight: w.ctr_weight,
          water_removal_target: w.water_removal_target,
          water_removal_rst: w.water_removal_rst,
          add_total: w.add_total,
          add_water_total: w.add_water_total,
          kt_v_measure: w.kt_v_measure,
          urr: w.urr,
          weight_decreased: w.weight_decreased,
          re_loop_rate_main: rateMain,
          reloop_info: JSON.stringify(reloopInfo)
        };
      });

      requestDatas.ordNo = this.getOrdNo;
      const response = await this.updateListComment({ ...requestDatas });
      if (response.status === 200) {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "成功",
          // message: "更新しました。"
          title: DIALOG_MESSAGES['00100017'].title,
          message: messageFormat(DIALOG_MESSAGES['00100017'].message)  
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        this.hideModal();
      } else {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "失敗",
          // message: `指示失敗\nエラーコード:${response.status}`
          title: DIALOG_MESSAGES['00200045'].title,
          message: messageFormat(DIALOG_MESSAGES['00200045'].message, response.status)  
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
    }
  }
};
</script>

<style scoped>
.input-comment {
  width: 100%;
  border: none;
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color) !important;
}
.expandable-content {
  padding: 1em;
}
.ntss-list {
  width: 98%;
}
.ntss-list-header-th {
  background-color: var(--ntss-header-background-color);
}
.ntss-list-body-td {
  background-color: var(--ntss-base-background-color);
}
div :deep(.modal-header .toolbar) {
  background-color: var(--ntss-header-background-color);
}
div :deep(.modal-header .toolbar__title.toolbar__left) {
  color: var(--ntss-header-color) !important;
}
div :deep(.modal-search),
div :deep(.modal-body),
div :deep(.modal-footer),
div :deep(.modal-footer .bottom-bar) {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
.text-right {
  text-align: right;
}
</style>
