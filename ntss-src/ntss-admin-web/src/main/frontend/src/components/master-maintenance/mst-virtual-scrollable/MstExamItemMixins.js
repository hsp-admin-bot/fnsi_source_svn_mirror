import { mapActions } from "@/compat/vue/vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { messageFormat } from "@/functions/common/MessageFormat";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
export default {
  data() {
    return {
      errorMessage: '',
    }
  },
  methods: {
    ...mapActions("master-maintenance", [
      "mstSyncDeviceEdge",
      "getMasterDeviceEdgeNoListByFacilityCd"
    ]),
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen"]),
    // マスタ同期（検査項目マスタ）
    masterSynchroOrder() {
      this.startLoadingScreen();
      this.getMasterDeviceEdgeNoListByFacilityCd(this.facilityCd).then(res => {
        let array = res.data;
        if (array && array.length > 0) {
          array =  array.sort((a,b) => {
            if (a.deviceEdgeNo < b.deviceEdgeNo) return -1;
            if (a.deviceEdgeNo > b.deviceEdgeNo) return 1;
            return 0;
          })
          this.synchroMstToDeviceEdge(array, 0);
        }
      }).finally(() => {
        this.finishLoadingScreen();
      });
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstToDeviceEdge(list, idx) {
      // let title = `検査項目マスタ同期`;
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, "検査項目マスタ");
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      let name = "デバイスエッジ：" + this.errorMessage + "</br></br>";

      // マスタ同期
      this.startLoadingScreen();
      this.mstSyncDeviceEdge({
        facilityCd: null,
        deviceEdgeNo: info.deviceEdgeNo
      })
        .then(() => {
          if (infos.length === idx + 1) {
            name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
            // 共通ローダー：表示終了
            if (this.errorMessage === "") {
              this.$ons.notification.alert({
                title: title,
                // message: "マスタ同期が完了しました。
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
              });
            } else {
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
              });
            }
            this.errorMessage = "";
          } else {
            // 次のデバイスエッジ
            this.synchroMstToDeviceEdge(list, idx + 1);
          }
        })
        .catch(error => {
          if (this.errorMessage === "") {
            this.errorMessage += "</br>" + info.deviceName + "</br>";
          } else {
            this.errorMessage += info.deviceName + "</br>";
          }
          this.synchroMstToDeviceEdge(list, idx + 1);
          if (infos.length === idx + 1) {
            getErrorMessage('MasterRecordComponent.vue', 'synchroMstToDeviceEdge' , error);
            if (error.response.status === 400) {
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
              });
              this.errorMessage = "";
            }
          }
        }).finally(() => {
          this.finishLoadingScreen();
        });
    },
  }
}
