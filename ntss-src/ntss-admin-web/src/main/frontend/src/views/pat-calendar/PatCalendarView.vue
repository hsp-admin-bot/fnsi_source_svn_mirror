<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/pat-calendar/PatCalendar";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_PAT_CALENDAR } from "@/router/pat-calendar/HistoryKeyConstants";
// add #10053 �j���m�F�E�ۑ�����(�����ύX�܂�)�E�폜�Ή�_���ҏ�� 20231218 ztc start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import {mapGetters, mapMutations} from "@/compat/vue/vuex";
// add #10053 �j���m�F�E�ۑ�����(�����ύX�܂�)�E�폜�Ή�_���ҏ�� 20231218 ztc end

export default {
  name: "PatCalendarView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  // add #10053 �j���m�F�E�ۑ�����(�����ύX�܂�)�E�폜�Ή�_���ҏ�� 20231218 ztc start
  async beforeRouteLeave(to, from, next) {
    try {
      if (to.name != "signin" && !!this.isPatInfoChaned) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.setIsPatInfoChaned(false);
              next();
            }
          }
        });
      } else {
        next();
      }
    } catch (error) {
      getErrorMessage('PatCalendarView.vue', 'beforeRouteLeave', error);
      next();
    }
  },
  // add #10053 �j���m�F�E�ۑ�����(�����ύX�܂�)�E�폜�Ή�_���ҏ�� 20231218 ztc end
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_CALENDAR
    };
  },
  // add #10053 �j���m�F�E�ۑ�����(�����ύX�܂�)�E�폜�Ή�_���ҏ�� 20231218 ztc start
  computed: {
    ...mapGetters("pat-info", ["isPatInfoChaned"]),
  },
  methods: {
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
  }
  // add #10053 �j���m�F�E�ۑ�����(�����ύX�܂�)�E�폜�Ή�_���ҏ�� 20231218 ztc end
};
</script>
