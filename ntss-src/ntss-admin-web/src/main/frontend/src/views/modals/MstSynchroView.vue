/**
 * マスタ同期Page
 */
<template>
  <modal-base @onClose="close">
    <div slot="body" class="div-mst-synchro">
      <div class="div-list">
        <p>マスタ選択</p>
        <hr>
        <v-ons-select v-model="selectMstTable">
          <option v-for="mstSynchro in mstSynchroList" :key="mstSynchro.code" :value="mstSynchro.code">
            {{ mstSynchro.code }}
          </option>
        </v-ons-select>
      </div>
      <div class="div-list">
        <p>施設選択</p>
        <hr>
        <v-ons-select v-model="selectFacility" @change="changeFacility">
          <option v-for="facility in facilityList" :key="facility.facilityCd" :value="facility.facilityCd">
            {{ facility.facilityName }}
          </option>
        </v-ons-select>
      </div>
      <div class="div-list">
        <p>デバイスエッジ選択</p>
        <hr>
        <v-ons-select v-model="selectDeviceEdge" :disabled="isDeviceEdgeList">
          <option v-for="deviceEdge in deviceEdgeList" :key="deviceEdge.deviceEdgeNo" :value="deviceEdge.deviceEdgeNo">
            {{ deviceEdge.deviceName }}
          </option>
        </v-ons-select>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="button btn2-cancel denial-btn" @click="close">閉じる</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="button btn3-normal registration-btn" width="120px" @click="MoveCacheTest">テストページへ
        </button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="button btn1-execute registration-btn" @click="startSynchro">同期開始</button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
export default {
  name: "mstSynchro",
  mixins: [MultiModalMixin, NextTransitionMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      // 選択マスタ
      selectMstTable: "",
      // 選択施設コード
      selectFacility: "",
      // 選択デバイスエッジ番号
      selectDeviceEdge: -999,
      // デバイスエッジ一覧を非活性にするマスタ
      isDisabledDeviceEdgeList: ["mst_m_notice"]
    };
  },
  computed: {
    ...mapGetters("mst-synchro", [
      "getMstSynchroList",
      "getFacilityList",
      "getDeviceEdgeList"
    ]),
    /**
     * 同期対象マスタ一覧
     */
    mstSynchroList() {
      return this.getMstSynchroList;
    },
    /**
     * 施設一覧
     */
    facilityList() {
      return this.getFacilityList;
    },
    /**
     * 選択施設のデバイスエッジ一覧
     */
    deviceEdgeList() {
      return this.getDeviceEdgeList;
    },
    /**
     * 選択マスタによってデバイスエッジ一覧の活性・非活性を切替(true:非活性、false:活性)
     */
    isDeviceEdgeList() {
      return (
        -1 !==
        this.isDisabledDeviceEdgeList.findIndex(e => e === this.selectMstTable)
      );
    }
  },
  methods: {
    ...mapActions("mst-synchro", [
      "getMstFacilityList",
      "getMstDeviceEdgeList",
      "startMstSynchroProc"
    ]),

    /**
     * 施設選択時処理
     */
    changeFacility() {
      // 選択デバイスエッジ番号の初期化
      this.selectDeviceEdge = -1;

      // 選択施設のデバイスエッジマスタ情報を取得
      this.getMstDeviceEdgeList(this.selectFacility);
    },
    /**
     * 同期開始処理
     */
    startSynchro() {
      // 同期開始(画面は閉じない)
      this.startMstSynchroProc({
        mstTable: this.selectMstTable,
        facilityCd: this.selectFacility,
        deviceEdgeNo: this.selectDeviceEdge
      })
        .then(() => {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "同期要求成功",
            // message: "同期要求処理に成功しました。"
            title: DIALOG_MESSAGES[12000295].title,
            message: messageFormat(DIALOG_MESSAGES[12000295].message)  
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MstSynchroView.vue','startSynchro','同期要求失敗');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (400 === error.response.status) {
            this.$ons.notification.alert({
              class: "alert-style",
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "同期要求失敗",
              title: DIALOG_MESSAGES[12000296].title, 
              messageHTML:
                // "同期要求処理に失敗しました。<br/>以下の理由が考えられます。" +
                messageFormat(DIALOG_MESSAGES[12000296].message) +
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                '<div style="display: flex; text-align: left;"><div style="white-space: nowrap;">理由１：</div><div style="white-space: normal;">同期対象マスタのデータが0件</div></div>' +
                '<div style="display: flex; text-align: left;"><div style="white-space: nowrap;">理由２：</div><div style="white-space: normal;">デバイスエッジとの接続に失敗</div></div>' +
                '<div style="display: flex; text-align: left;"><div style="white-space: nowrap;">理由３：</div><div style="white-space: normal;">対象施設にデバイスエッジが存在しない</div></div>'
            });
          }
        });
    },
    /**
     * テストページへの遷移処理
     */
    MoveCacheTest(){
      this.close();
      this.goSpecifiedView("cache-test");
    },
    /**
     * 閉じる処理
     */
    close() {
      // 画面を閉じる
      this.hideModal();
    }
  },
  async created() {
    // 施設マスタ情報を取得
    await this.getMstFacilityList().catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
      getErrorMessage('MstSynchroView.vue','created','施設マスタ情報の取得に失敗しました。');
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
      if (400 === error.response.status) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "取得失敗",
          // message: "施設マスタ情報の取得に失敗しました。"
          title: DIALOG_MESSAGES[12000297].title,
          message: messageFormat(DIALOG_MESSAGES[12000297].message)  
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
    });

    // デバイスエッジマスタ情報を取得
    if (0 < this.facilityList.length) {
      await this.getMstDeviceEdgeList(this.facilityList[0].facilityCd).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MstSynchroView.vue','created','デバイスエッジマスタ情報の取得に失敗しました。');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (400 === error.response.status) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "デバイスエッジマスタ情報の取得に失敗しました。"
              title: DIALOG_MESSAGES[12000298].title,
              message: messageFormat(DIALOG_MESSAGES[12000298].message)  
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        }
      );
    }

    // 初期選択
    this.selectMstTable = this.mstSynchroList[0].code;
    this.selectFacility = this.facilityList[0].facilityCd;
    this.selectDeviceEdge = this.deviceEdgeList[0].deviceEdgeNo;
  }
};
</script>

<style scoped>
.div-mst-synchro {
  display: -webkit-flex;
  display: flex;
}
.div-list {
  padding: 0px 10px 0px 10px;
}
.alert-style {
  width: auto;
}
.div-mst-synchro>>>.select-input {
  font-size: 1em;
  line-height: 1em;
}
</style>
