/**
 * マスタメンテナンス 送信先グループマスタ（メインコンポーネント）
 */
<template>
  <div id="destination-group-modal-content">
    <!-- 送信先グループ名 -->
    <div id="group-name-form-wrapper">
      <v-ons-row vertical-align="center">
        <v-ons-col class="input-item-name">
          <label for="group-name">送信先グループ名</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            type="text"
            input-id="group-name"
            :value="getValueByField('name')"
            @blur="updateEditRecord('name', $event)"
          ></v-ons-input>
        </v-ons-col>
      </v-ons-row>
    </div>
    <div id="group-notic-wrapper" class="group-notice">
      <div class="group-notice-title">
        <label>メーカー通知</label>
      </div>
      <v-ons-switch style="vertical-align:middle;" v-model="isNotice" @change="updateIsNotice()"></v-ons-switch>
    </div>
    <!-- スタッフ名検索 -->
    <div id="personal-user-search-wrapper">
      <personal-user-search/>
    </div>
    <!-- 一覧 -->
    <div id="staff-list-wrapper" :style="heightStyles">
      <table class="staff-list custom-staff-list">
        <thead>
          <tr>
            <th class="staff-list-header staff-list-header-name" rowspan="2">スタッフ名</th>
            <th class="staff-list-header staff-list-header-email" colspan="2" id="header-email">メールアドレス</th>
          </tr>
          <tr>
            <th class="staff-list-header-email1" :style="topStyles">1</th>
            <th class="staff-list-header-email2" :style="topStyles">2</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(staff, index) in staffList"
            :key="index"
            :class="index%2 === 0 ? 'even-row' : 'odd-row'"
          >
            <td>{{ staff.fullName }}</td>
            <td class="email-send-checkbox">
              <ons-checkbox
                :disabled="!staff.hasEmailAddress1"
                @click="onChange(staff, $event, 1)"
                :checked="staff.beSendEmailAddress1"
              ></ons-checkbox>
            </td>
            <td class="email-send-checkbox">
              <ons-checkbox
                :disabled="!staff.hasEmailAddress2"
                @click="onChange(staff, $event, 2)"
                :checked="staff.beSendEmailAddress2"
              ></ons-checkbox>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import PersonalUserSearchComponent from "@/components/master-maintenance/mst-destination-group/PersonalUserSearchComponent";
// add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 start
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
// add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 end
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
export default {
  name: "MstDestinationGroup",
  components: {
    "personal-user-search": PersonalUserSearchComponent
  },
  data() {
    return {
      staffList: [],
      isNotice: false,
      stickeyTop: 30,
      listHeight: 500,
      // add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 start
      userSelector:[],
      initName:"",
      initIsNotice:"",
      // add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 end
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
      initDestination:"",
      editRecordDefault:null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      editRecord: "getEditRecord",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    ...mapGetters("mst-destination-group", {
      staffsByCondition: "staffsByCondition"
    }),
    ...mapGetters("window-size", {
      windowWidth: "getSplittedWidth",
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    topStyles() {
      // メールアドレスのtop位置をCSS変数を利用して書き換え
      return { "--top": `${this.stickeyTop}px` };
    },
    heightStyles() {
      // リストの高さをCSS変数を利用して書き換え
      return { "--height": `${this.listHeight}px` };
    }
  },
  watch: {
    /**
     * ウィンドウ幅が変更された時
     */
    windowWidth() {
      this.calculateStickyTop();
    },
    /**
      * ウィンドウの高さが変更された時
      */
    windowHeight() {
      this.calculateListHeight();
    },
    getFontSize() {
      this.topStyles = { "--top": `${this.stickeyTop}px` };
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
    editRecord: {
      handler(val) {
        if(!isEqualWith(this.initName,val.name) || !isEqualWith(this.editRecordDefault.isNotice,val.isNotice) 
           || !isEqualWith(JSON.parse(this.editRecordDefault.destinationTarget),JSON.parse(val.destinationTarget))){
          EventBus.$emit("mstHolidayRegistered", false);
        } else { 
          EventBus.$emit("mstHolidayRegistered", true);
        }
      },
      deep:true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-destination-group", [
      "fetchAllStaffs",
      "fetchAllStaffsByFacilityCd",
      "conditionsClear",
      "saveStaff"
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    /**
     * Stickyな一覧のヘッダの高さが変更されたらtop位置を計算する
     */
    calculateStickyTop() {
      const height = getScopedElementById("header-email", this.$el || this)?.clientHeight || 0;
      this.stickeyTop = height + 1;
    },
    calculateListHeight() {
      // 画面の高さ
      const fullHeight = getScopedElementById("destination-group-modal-content", this.$el || this)?.clientHeight || 0;
      // ヘッダーの高さ
      const headHeight = (getScopedElementById("group-name-form-wrapper", this.$el || this)?.clientHeight || 0)
        + (getScopedElementById("group-notic-wrapper", this.$el || this)?.clientHeight || 0)
        + (getScopedElementById("personal-user-search-wrapper", this.$el || this)?.clientHeight || 0);
      // リストの高さを設定
      this.listHeight = fullHeight - headHeight - 10;
    },
    onChange(staff, ev, whichEmail) {
      // ストアの更新
      staff[`beSendEmailAddress${whichEmail}`] = ev.target.checked;
      this.saveStaff(staff);

      // 送信先グループからチェック押下されたユーザーを削除
      const destination = this.convertToDestinationJson();
      const userIndex = destination.users.findIndex(
        _staff => _staff.user_id === staff.userId
      );
      if (userIndex !== -1) {
        destination.users.splice(userIndex, 1);
      }
      // メールアドレス1,2のどちらかがtrueなら送信先グループに追加する
      if (staff.isSendEmailAddress) {
        const user = {
          user_id: staff.userId,
          is_address1_send: staff.beSendEmailAddress1,
          is_address2_send: staff.beSendEmailAddress2
        };
        destination.users.push(user);
      }
      this.editRecord["destinationTarget"] = JSON.stringify(destination);
      this.setEditRecord(this.editRecord);
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
      // EventBus.$emit("mstHolidayRegistered", false);
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
    },
    mappingToSendGroup() {
      const destination = this.convertToDestinationJson();
      // add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 start
      this.staffList.sort((a, b) => {
          let indexA;
          for (indexA = 0; indexA < this.userSelector.length; indexA++) {
            if (this.userSelector[indexA].code === a.userId)
             break;
          }
          let indexB;
          for (indexB = 0; indexB < this.userSelector.length; indexB++) {
            if (this.userSelector[indexB].code=== b.userId)
             break;
          }
          if (indexA > indexB) return 1;
          if (indexB > indexA) return -1;
          return 0;
        })
      // add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 end
      for (let i = 0; i < this.staffList.length; i++) {
        const staff = this.staffList[i];
        const index = destination.users.findIndex(
          u => u.user_id === staff.userId
        );
        if (index !== -1) {
          staff.beSendEmailAddress1 = destination.users[index].is_address1_send;
          staff.beSendEmailAddress2 = destination.users[index].is_address2_send;
          this.saveStaff(staff);
        }
      }
    },
    convertToDestinationJson() {
      const emptyUsers = {
        users: []
      };
      let destination =
        this.editRecord["destinationTarget"] || JSON.stringify(emptyUsers);
      return JSON.parse(destination);
    },
    getValueByField(field) {
      return this.editRecord[field];
    },
    updateEditRecord(key, ev) {
      this.editRecord[key] = ev.target.value;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
      // if (this.editRecord.name!==this.initName) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
      this.setEditRecord(this.editRecord);
    },
    setStaffList() {
      this.staffList = this.staffsByCondition;
    },
    setIsNotice() {
      this.isNotice = this.getValueByField("isNotice") === '1' ? true : false;
    },
    updateIsNotice() {
      this.editRecord["isNotice"] = this.isNotice ? "0" : "1";
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
      // if (this.editRecord.isNotice!==this.initIsNotice) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
      this.setEditRecord(this.editRecord);
    },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
    // changeButton() {
    //   EventBus.$emit("mstHolidayRegistered", false);
    // }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
  },
  async created() {
    this.setLoadingScreenVisible(true);
    // 利用者一覧をAPIで取得
    // await this.fetchAllStaffs();
    await this.fetchAllStaffsByFacilityCd(this.getFacilitySwitch);
    // add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 start
    const tableName = "mst_user";
    const response = await ApiHelper.get(
      `/report_designer/master/${tableName}`
    ).catch(() => {
      getErrorMessage('MasterDestinationGroupComponent.vue', 'created', "利用者の表示順取得失敗");
      throw new Error(
        "[MasterDestinationGroupComponent.vue]created(): 利用者の表示順取得失敗"
      );
    });
    this.userSelector = response.data;
    // add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる 周安寧 end
    this.setStaffList();
    this.mappingToSendGroup();
    this.setIsNotice();
    EventBus.$on("setStaffList", this.setStaffList);
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateStickyTop();
      this.calculateListHeight();
    });
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
    this.initName = this.editRecord.name;
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
    // this.initIsNotice = this.editRecord.isNotice
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 start
    this.editRecord.isNotice = this.editRecord.isNotice ? this.editRecord.isNotice :"0"
    this.editRecord.destinationTarget = this.editRecord.destinationTarget ? this.editRecord.destinationTarget:'{"users":[]}';
    this.editRecordDefault = cloneDeep(this.editRecord);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_送信先グループマスタ 張玲 2024/01/05 end
  },
  beforeUnmount() {
    this.conditionsClear();
    EventBus.$off("setStaffList", this.setStaffList);
  }
};
</script>

<style scoped>
@media print {
  #staff-list-wrapper {
    height: auto !important;
  }
}
#destination-group-modal-content {
  height: 100%;
}
#staff-list-wrapper {
  --height: 500px;
  height: var(--height);
  overflow-y: auto;
}
#group-name-form-wrapper {
  height: 35px;
}
#group-name-form-wrapper :deep(ons-input .text-input) {
  font-size: 1.0em;
}
#personal-user-search-wrapper {
  height: auto;
}
table.staff-list {
  border-collapse: collapse;
}
table.staff-list th,
table.staff-list td {
  border: solid 1px var(--ntss-list-border-color);
  padding: 0 0.75rem;
}
table.staff-list {
  width: 100%;
}
table.staff-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}
table.staff-list thead tr {
  height: 30px;
}
table.staff-list thead tr th.staff-list-header {
  z-index: 1;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
}
table.staff-list thead tr th.staff-list-header-email {
  white-space:nowrap;
  width: 37%;
}
table.staff-list thead tr th.staff-list-header-email1,
table.staff-list thead tr th.staff-list-header-email2 {
  z-index: 1;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  --top: 30px;
  top: var(--top);
}
table.staff-list tbody tr {
  height: 2.5em;
  padding: 0 0.75rem;
  border-color: 1px solid var(--master-maintenance-kgrid-border-color);
}
table.staff-list tbody tr:hover{
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
table.staff-list tbody tr.even-row {
  background-color: var(---ntss-list-item-background-color);
}
table.staff-list tbody tr.odd-row {
  background-color: var(--ntss-list-content-2nd-background-color);
}
table.staff-list tbody tr td.email-send-checkbox {
  text-align: center;
}
.title {
  width: 12em;
}
.group-notice {
  padding: 5px 0px 5px 0;
}
.group-notice-title {
  display: inline-block;
  padding: 10px 15px 10px 0;
}
#group-name-form-wrapper label {
  line-height: 1;
}

.custom-staff-list th {
  box-shadow: 0 0 0 .25px var(--ntss-list-border-color);;
}

.input-item-name {
  max-width: 10%;
}
.input-item-txt {
  max-width: 30%;
}
@media screen and (max-width: 1200px) {
  .input-item-name {
    min-width: 40%;
  }
  .input-item-txt {
    min-width: 55%;
  }
}
</style>
