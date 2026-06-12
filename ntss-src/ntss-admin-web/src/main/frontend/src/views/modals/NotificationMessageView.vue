/**
 * 通知一覧ページ
 */
<template>
  <modal-base @onClose="onClose">
    <template #body>
      <div class="notification-message-list">
      <div class="list-condition" style="height: 4em;line-height:4em;">
        <v-ons-row>
          <v-ons-col style="max-width: 12em;">
            <label>既読の通知を表示する</label>
          </v-ons-col>
          <v-ons-col style="max-width: 4em;">
            <v-ons-switch v-model="displayAll"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
      </div>
      <!-- mod FNSI-通知表示が遅いを修正 江 start -->
      <!-- <div class="message-list"> -->
      <!-- mod #10110 通知一覧から既読にした通知以外も消える dengshen start -->
      <!-- <div class="message-list" ref="ntssList" @scroll="this.handleScroll"> -->
      <div class="message-list" ref="ntssList">
      <!-- mod #10110 通知一覧から既読にした通知以外も消える dengshen end -->
      <!-- mod FNSI-通知表示が遅いを修正 江 end -->
        <template v-for="(message, index) in messages" :key="message.no">
          <transition name="message-area">
            <v-ons-row
              v-if="displayAll || !message.isRead"
            >
              <v-ons-col
                :class="message.isRead ? 'read-background' : message.isImportant ? 'read-important' :null"
                class = "content-area" @click="onChangeReadStatus(message, index)">
                <p>
                  {{ message.displayRegDate}}
                  <i v-if="message.isImportant" class="important-i">重要</i>
                  <img v-if="message.isSame" class='same-icon' style="position: relative;top: 2px;" :src="image_src_same" />
                </p>
                <p>{{ message.content }}</p>
              </v-ons-col>
              <v-ons-col
                :class="message.isRead ? 'read-background' : message.isImportant ? 'read-important' :null"
                class="button-area">
                <div>
                  <div v-if="!message.isRead" @click="onChangeReadStatus(message, index)" class="unread-button green-btn" style="background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);">未読</div>
                  <div v-else class="read-button white-btn">既読</div>
                </div>
                <div
                  class="jump-button"
                  v-show="message.additionalInfo"
                  @click="onForward(message)"
                >
                  <i class="icon ion-ios-redo"></i>
                </div>
              </v-ons-col>
              <!-- mod FNSI-重要通知設定の追加 江 end -->
            </v-ons-row>
          </transition>
        </template>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod FNSI-コードをマージ 江 start -->
        <!-- <v-ons-button
          class="button registration-btn all-read-btn"
          :disabled="!hasUnread"
          @click="onReadAll"
        >全て既読</v-ons-button> -->
        <v-ons-button
          class="button btn1-execute registration-btn all-read-btn"
          :disabled="!hasUnread"
          @click="onReadAll"
        >全て既読</v-ons-button>
        <!-- mod FNSI-コードをマージ 江 end -->
        <!-- mod FNSI-コードをマージ 江 start -->
        <!-- <v-ons-button
          class="button registration-btn all-read-btn"
          @click="showMakerNotice()"
          v-if="isDispMakerNotice"
        >メーカー通知登録</v-ons-button> -->
        <v-ons-button
          class="button btn3-normal registration-btn all-read-btn"
          @click="showMakerNotice()"
          v-if="isDispMakerNotice"
        >メーカー通知登録</v-ons-button>
        <!-- mod FNSI-コードをマージ 江 end -->
      </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <!-- mod FNSI-コードをマージ 江 start -->
      <!-- <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn" @click="onClose">閉じる</v-ons-button>
      </div> -->
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="onClose">閉じる</v-ons-button>
      </div>
      <!-- mod FNSI-コードをマージ 江 end -->
      </div>
    </template>
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import NotificationMessageMixin from "@/components/common/notification-message/NotificationMessageMixin";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
import sortBy from "@/compat/collections/lodash/sortBy";
import partition from "@/compat/collections/lodash/partition";
import orderBy from "@/compat/collections/lodash/orderBy";
import nameDuplication3Img from "@/assets/name_duplication3.png";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "notificationMessage",
  mixins: [MultiModalMixin, NotificationMessageMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      displayAll: false,
      messages: [],
      isDispMakerNotice: false,
      offset: 0,
      // 同姓同名アイコン
      image_src_same: nameDuplication3Img,
      allDataList: []
    };
  },
  // add start 馬 #10110
  watch: {
    displayAll() {
      this.$refs.ntssList.scrollTop = 0;
      this.offset = 0;
      this.initDataList();
    }
  },
  // add end 馬 #10110
  computed: {
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo"
    ]),
    //add 横展開管理台帳_日機装FNSI NO.15 劉全航 start
    ...mapGetters("pat-prescription",["getIsChanged"]),
    //add 横展開管理台帳_日機装FNSI NO.15 劉全航 end
    /**
     * 未読通知が存在するか.
     */
    hasUnread() {
      if (this.allDataList?.length > 0) {
        return this.allDataList.some(e => !e.isRead);
      }
      return false;
    }
  },
  methods: {
    ...mapActions("notification-message", [
      "getNotificationMessageAll",
      "updateNotificationMessageStatus",
      // add FNSI-通知既読更新を修正 江 start
      "updateAllNotificationMessageisRead"
      // add FNSI-通知既読更新を修正 江 end
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    ...mapActions("multi-modal", {
      showMakerNotice: "showMakerNotice"
    }),
    /**
     * 未読/既読ボタンクリックイベントハンドラ.
     */
    onChangeReadStatus(message, index) {
      if(!message.isRead){
        this.changeReadStatus([message], !message.isRead, index);
      }
    },
    /**
     * 「全て既読」ボタンクリックイベントハンドラ.
     */
    onReadAll() {
      // mod FNSI-通知既読更新を修正 江 start
      this.updateAllNotificationMessageisRead().finally(() => {
        // modify start 馬 #10110
        this.allDataList.forEach(e => (e.isRead = true));
        this.allDataList = sortBy(this.allDataList, 'displayRegDate').reverse();
        this.$refs.ntssList.scrollTop = 0;
        this.offset = 0;
        this.initDataList();
        // modify end 馬 #10110
      });
      // mod FNSI-通知既読更新を修正 江 end
    },
    /**
     * 未読/既読の切り替え.
     * @param {Array} messages 切り替えるメッセージのリスト
     * @param {Boolean} isRead true:既読にする false:未読にする
     */
    changeReadStatus(messages, isRead, index) {
      this.updateNotificationMessageStatus({
        notification_message_nos: messages.map(e => e.no),
        is_read: isRead ? "1" : "0"
      }).finally(() => {
        // modify start 馬 #10110
        this.messages[index].isRead = isRead;
        this.allDataList[index].isRead = isRead;
        if (messages[0].isImportant) {
          const splitArr = partition(this.allDataList, message => message.isImportant && !message.isRead);
          const sortedTrue = orderBy(splitArr[0], ['displayRegDate'], ['desc']);
          const sortedFalse = orderBy(splitArr[1], ['displayRegDate'], ['desc']);
          const result = [...sortedTrue, ...sortedFalse];
          this.allDataList = result;
          this.messages.splice(index, 1);
          const insertIndex = this.allDataList.findIndex((item) => {
            return item.no === messages[0].no;
          });
          if (insertIndex <= this.messages.length) {
            this.messages.splice(insertIndex, 0, this.allDataList[insertIndex]);
          }
        }
        // modify end 馬 #10110
      });
    },
    /**
     * ジャンプボタンクリックイベントハンドラ.
     * @param {Object} message 通知メッセージ情報
     */
    //mod 横展開管理台帳_日機装FNSI NO.15 劉全航 start
    // onForward(message) {
    //   if (this.jump(message)) {
    //     this.hideModal();
    //   }
    // },
    onForward(message) {
      if(this.getIsChanged){
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄11",
          title: DIALOG_MESSAGES[13000159].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000159].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if(answer !== 1){
              return;
            }
            if (this.jump(message)) {
                this.hideModal();
              }
          }
        });
      }else{
        if (this.jump(message)) {
          this.hideModal();
        }
      }
    },
    //mod 横展開管理台帳_日機装FNSI NO.15 劉全航 end
    // add start 馬 #10110
    onScroll (e) {
      const { scrollHeight, clientHeight, scrollTop } = e.target;
      if (scrollTop + clientHeight >= scrollHeight) {
        this.loadMoreItems();
      }
    },
    loadMoreItems () {
      this.offset += 1;
      const addList = (this.displayAll ? this.allDataList : this.isNotRead).slice(this.messages.length, 100*(this.offset + 1));
      this.messages.push(...addList);
    },
    // add end 馬 #10110
    /**
     * 初期処理.
     */
    init() {
      // 通知メッセージ取得
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      this.getNotificationMessageAll(this.offset)
        .then(messages => {
          // modify start 馬 #10110
          this.allDataList = messages;
          this.initDataList();
          // modify end 馬 #10110
        })
        .finally(() => this.setLoadingScreenVisible(false));
      // mod FNSI-通知表示が遅いを修正 江 end
      // メーカー通知登録ボタン表示判定
      const userType = this.getStateUserAccountInfo.userType;
      const administrator = this.getStateUserAccountInfo.administrator;
      if (userType === 1 && administrator === 1) {
        this.isDispMakerNotice = true;
      }
    },
    // add start 馬 #10110
    initDataList () {
      const isNotRead = this.allDataList.filter((message) => {
        return message.isRead === false;
      });
      this.isNotRead = isNotRead;
      this.messages = [];
      this.messages = (this.displayAll ? this.allDataList : isNotRead).slice(0, 100 * (this.offset + 1));
    },
    // add start 馬 #10110
    /**
     * 閉じるボタン処理
     */
    onClose() {
      this.hideModal();
    }
  },
  created() {
    this.init();
  },
  // add start 馬 #10110
  mounted() {
    const list = this.$refs.ntssList;
    if (list) {
      list.addEventListener('scroll', this.onScroll);
    }
  },
  beforeUnmount() {
    const list = this.$refs.ntssList;
    if (list) {
      list.removeEventListener('scroll', this.onScroll);
    }
  },
  // add end 馬 #10110
};
</script>
<style scoped lang="scss">
.notification-message-list {
  height: calc(100% - 1em);
}
.list-condition {
  margin: 0px 8px;
  vertical-align: middle;

  ons-col {
    display: flex;
    align-items: center;
  }
}
.message-list {
  height: calc(100% - (28px + 5em));
  overflow-y: auto;

  ons-row {
    padding: 4px 8px;
    height: unset;
  }
}
.message-area-enter-active,
.message-area-leave-active {
  transition: opacity 0.4s;
}

.message-area-enter,
.message-area-leave-to {
  opacity: 0;
}

.content-area {
  padding: 8px;
  background-color: #e8f9f0;
  // add FNSI-コードをマージ 江 start
  color: #050505;
  // add FNSI-コードをマージ 江 end
  white-space: pre-wrap;
  cursor: pointer;

  p {
    margin: 4px 0px;
    // add FNSI-重要通知設定の追加 江 start
    i{
      background-color: #ff0000;
      color: #ffffff;
      padding: 4px;
      margin-left: 8px;
    }
    // add FNSI-重要通知設定の追加 江 end
  }
}
.button-area {
  max-width: 6em;
  padding: 8px 0px;
  background-color: #e8f9f0;
  display: flex;
  flex-direction: column;
  justify-content: space-between;

  & > div {
    flex: 0 1 auto;
  }

  .jump-button {
    text-align: center;
  }

  i {
    font-size: 3em;
    cursor: pointer;
  }

  .unread-button,
  .read-button {
    border-radius: 1em;
    padding: 4px;
    text-align: center;
    cursor: pointer;
  }

  .unread-button {
    background-color: #3cb371;
    color: #ffffff;
  }

  .read-button {
    background-color: #dddddd;
    color: #808080;
  }
}
.all-read-btn {
  margin: 4px 8px;
}
.flex-container {
  justify-content: flex-end;
}
.read-background {
  background-color: #f2f2f2;
}
// add FNSI-重要通知設定の追加 江 start
.read-important{
  background-color: #f9e8e8;
}
// add FNSI-重要通知設定の追加 江 end
// add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
.same-icon{
  height: 1.0em;
  display: inline-block;
  margin-left: 0.5em;
}
// add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end
</style>
