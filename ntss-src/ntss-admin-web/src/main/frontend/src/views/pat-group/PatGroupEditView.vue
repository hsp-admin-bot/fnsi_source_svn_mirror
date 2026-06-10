<template>
  <ntss-layout-split>
    <header-component slot="header-content" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      @refresh="handleRefresh"
    /> -->
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
    />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
  </ntss-layout-split>
</template>

<script>
import _ from "underscore";
import HeaderComponent from "@/components/pat-group/PatGroupEditHeaderComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import MainComponent from "@/components/pat-group/PatGroupEditComponent";
import {
  HISTORY_KEY_PAT_GROUP_NEW,
  HISTORY_KEY_PAT_GROUP_EDIT
} from "@/router/pat-group/HistoryKeyConstants";
import { mapGetters } from "vuex";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "PatGroupEditView",
  components: {
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
    "main-component": MainComponent
  },
  data() {
    return {
      historyKey:
        this.$route.name === "pat-group-new"
          ? HISTORY_KEY_PAT_GROUP_NEW
          : HISTORY_KEY_PAT_GROUP_EDIT
    };
  },
  computed: {
    ...mapGetters("pat-group", ["selectedPatGroup", "editedPatGroup"])
  },
  methods: {
    // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    // add #8029 パン屑初期化対応コンポーネントをクリック start
    // handleRefresh () {
    //   if (this.isContentChanged()) {
    //     this.$ons.notification.confirm({
    //       title: DIALOG_MESSAGES[13000004].title,
    //       message: messageFormat(DIALOG_MESSAGES[13000004].message),
    //       callback: answer => {
    //         if (answer == 1) {
    //           this.refreshScreen();
    //         }
    //       }
    //     });
    //   } else {
    //     this.refreshScreen();
    //   }
    // },
    // // リフレッシュ処理の本処理
    // refreshScreen() {
    //   this.$refs.mainComponent.initData(this.$route.name);
    //   this.$refs.mainComponent.initPatGroupName();
    // },
    // del #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    // add #8029 パン屑初期化対応コンポーネントをクリック end
    isContentChanged() {
      // add FNSI-4788 范 start
      const isAdd=this.$refs.mainComponent.isAdd;
      if("0" == isAdd){
        this.$refs.mainComponent.isAdd = null;
        return false;
      }
      // add FNSI-4788 范 end
      // 新規登録時は無条件で変更有とする
      if(this.$route.name === "pat-group-new"){
        return true;
      }
      const initEditedPatGroup=this.$refs.mainComponent.initEditedPatGroup;
      return !_.isEqual(initEditedPatGroup, this.editedPatGroup);
    },
    async discardContentConfirm(next) {
      const confirmed = await this.$ons.notification.confirm(
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // "編集内容が破棄されます。</br>よろしいですか？",
        messageFormat(DIALOG_MESSAGES[13000004].message),
        // { title: "内容破棄" }
        {title: DIALOG_MESSAGES[13000004].title}
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      );

      next(!!confirmed);
    }
  },
  async beforeRouteUpdate(to, from, next) {
    if (this.isContentChanged()) {
      this.discardContentConfirm(next);
      return;
    }

    next();
  },
  async beforeRouteLeave(to, from, next) {
    // #10053 dou start
    // if (this.isContentChanged()) {
    if (to.name != "signin" && this.isContentChanged()) {
      // #10053 dou end
      const confirmed = await this.$ons.notification.confirm(
        messageFormat(DIALOG_MESSAGES[13000004].message),
        {title: DIALOG_MESSAGES[13000004].title}
      );
      if (confirmed != 1) {
        next(false);
        return;
      }
    }
    if (this.$refs.mainComponent.isButtonClicked) {
      this.$refs.mainComponent.clearCondition();
    }
    next();
  }
};
</script>
