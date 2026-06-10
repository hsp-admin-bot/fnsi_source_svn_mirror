/** 加算情報 */
<template>
  <submenu-base v-if="hasOrdNo">
    <div slot="main" id="addition-component">
      <div>
        <div>
          <table class="addition-record-list">
            <thead>
              <tr>
                <!-- add FNSI-改修内容自動算定の修正 徐 start -->
                <th class="ntss-list-header-th-sticky header-checkbox fit-content">
                  有効
                </th>
                <!-- add FNSI-改修内容自動算定の修正 徐 end -->
                <th class="ntss-list-header-th-sticky">
                  加算・管理料
                </th>
                <th class="ntss-list-header-th-sticky header-last-date">
                  前回算定日
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                class="ntss-list-body-tr"
                v-for="(item, index) in mstAdditionList"
                :key="item.additionCd"
              >
                <!-- add FNSI-修正 権限関連 周雨晴 2020/09/27 start -->
                <td class="align-center ntss-list-body-td round">
                  <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- <v-ons-checkbox
                    input-id="includeNotAccepted"
                    v-model="item.is_enable"
                    :disabled="!isShared || !hasTreatmentRecordAuthority"
                    @click="callManualEvent(item)"
                  ></v-ons-checkbox> -->
                  <v-ons-checkbox
                    input-id="includeNotAccepted"
                    v-model="item.is_enable"
                    :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                    @click="callManualEvent(item)"
                  ></v-ons-checkbox>
                  <!-- mod #10359 編集権限の動作不正 end -->
                </td>
                <!-- add FNSI-修正 権限関連 周雨晴 2020/09/27 end -->
                <td class="align-left ntss-list-body-td">
                  {{ getDispName(item) }}
                  <div style="display: flex; flex-wrap: nowrap;" v-if="item.additionClass === '12' && item.additionSpan === '4'">
                    <!-- 開始日：チェックが無効の時、入力欄を無効化 -->
                  <!-- mod #10359 編集権限の動作不正 start -->
                    <!-- <date-input
                      v-model="item.start_date"
                      :classes="'ntss-input-date ntss-control-size start-date-edit-column ' +isStartDateEdited(index)"
                      :disabled="!isShared || !hasTreatmentRecordAuthority || !item.is_enable"
                      @handleClearInput="item.start_date = null"
                    />
                    <common-calendar v-model="item.start_date" :disabled="!isShared || !hasTreatmentRecordAuthority || !item.is_enable"/> -->
		    <date-input
                      v-model="item.start_date"
                      :classes="'ntss-input-date ntss-control-size start-date-edit-column ' +isStartDateEdited(index)"
                      :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority') || !item.is_enable"
                      @handleClearInput="item.start_date = null"
                    />
                    <common-calendar v-model="item.start_date" :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority') || !item.is_enable"/>
                  <!-- mod #10359 編集権限の動作不正 end -->
                  </div>
                </td>
                <td class="align-left ntss-list-body-td last-date">
                  {{ formatDate(item.last_date) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container" v-if="mstAdditionList.length > 0">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area">
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <v-ons-button class="button denial-btn btn2-cancel" @click="onClickCancel" :disabled="!isShared||!getItemAuthorized('TreatmentRecord', 'default_authority')">
          キャンセル
        </v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      </div>
      <div class="new-btn-area">
        <!-- add FNSI-修正 権限関連 周雨晴 2020/09/27 start -->
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start-->
<!--        <v-ons-button-->
<!--            class="button registration-btn btn1-execute"-->
<!--            :disabled="!isChanged || !isShared || !hasTreatmentRecordAuthority"-->
<!--            @click="onClickSave"-->
<!--        >-->
        <!-- mod #10359 編集権限の動作不正 start -->
        <!-- <v-ons-button
          class="button registration-btn btn1-execute"
          :disabled="isEditable"
          @click="onClickSave"
        > -->
        <v-ons-button
          class="button registration-btn btn1-execute"
          :disabled="isEditable||!getItemAuthorized('TreatmentRecord', 'default_authority')"
          @click="onClickSave"
        >
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end-->
          保存
        </v-ons-button>
        <!-- mod #10359 編集権限の動作不正 end -->
        <!-- add FNSI-修正 権限関連 周雨晴 2020/09/27 end -->
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
    </div>
  </submenu-base>
</template>

<script>
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
import { mapActions, mapGetters, mapMutations } from "vuex";
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import { formatDatetime } from "@/functions/common/CommonFunctions";
import moment from "moment";
import { EventBus } from "@/eventBus.js";
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
import DateInput from "@/components/common/DateInput";
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

export default {
  //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // /**
  //  *
  //  */
  // mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
  mixins: [DiscardConfirmationMixin],
  //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  /**
   *
   */
  components: {
    "submenu-base": SubmenuBase,
    "common-calendar": commonCalender,
    "date-input": DateInput,
  },

  /**
   *
   */
  data() {
    return {
      isChanged: false,

      // add FNSI-修正 権限関連 周雨晴 2020/09/27 start
      // del #10359 編集権限の動作不正 start
      // hasTreatmentRecordAuthority: false,
      // del #10359 編集権限の動作不正 end
       // add FNSI-修正 権限関連 周雨晴 2020/09/27 end
      //add FNSI修正 結合バッグ 房 start
      compareSelected:[],
      //add FNSI修正 結合バッグ 房 end
      compareStartDate: [],
      selfScreenName: "",
      alertFlag: true,
    };
  },

  /**
   *
   */
  computed: {
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", [
      "getOrdNo",
      "getTreatDate",
      // add 孫 svn72
      "getSharedFacilityCd"
      // add 孫 svn72 end
      ]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPat"]),
    ...mapGetters("ord-addition", [
      "mstAdditionList",
      "getOrdAdditionList",
      "selectedMstAdditionList",
      "unselectedMstAdditionList",
      "getPatAdditionList"
    ]),

    // add 孫 svn72
    ...mapGetters("user", ["getFacilityCd"]),

    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    isEditable(){
      // mod #10359 編集権限の動作不正 start
      // this.setIsPatInfoChaned(!(!this.isChanged || !this.isShared || !this.hasTreatmentRecordAuthority))
      // return !this.isChanged || !this.isShared || !this.hasTreatmentRecordAuthority;
      this.setIsPatInfoChaned(!(!this.isChanged || !this.isShared ))
      return !this.isChanged || !this.isShared ;
      // mod #10359 編集権限の動作不正 end
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
  },

  /**
   *
   */
  watch: {
    unselectedMstAdditionList() {
      this.unselectedMstAdditionList.sort(this.sortByProperty('additionClass'));
    },
    selectedMstAdditionList() {
      this.selectedMstAdditionList.sort(this.sortByProperty('additionClass'));
    },
    // add FNSI修正 結合バッグ 房 start
    mstAdditionList: {
      handler(val) {
        this.isChanged = false;
        if (val.length > 0 && this.compareSelected.length > 0) {
          for (let i = 0; i < val.length; i++) {
            if (val[i].is_enable != this.compareSelected[i]) {
              this.isChanged = true;
              break;
            }
          }
        }
        // 開始日が変更されていたら、変更済みとする
        if (!this.isChanged && val.length > 0 && this.compareStartDate.length > 0) {
          for (let i = 0; i < val.length; i++) {
            const valDate = typeof val[i].start_date === "undefined" ? "" : val[i].start_date;
            if (valDate != this.compareStartDate[i]) {
              this.isChanged = true;
              break;
            }
          }
        }
      },
      deep: true
    }
    // add FNSI修正 結合バッグ 房 end
  },

  /**
   *
   */
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // EventBus.$on("refresh", this.refresh);
    EventBus.$on("refresh", this.eventBusRefresh);
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    //mod FNSI修正 結合バッグ 房 start
    await this.refresh();
    //mod FNSI修正 結合バッグ 房 end
    //add FNSI修正 結合バッグ 房 start
    this.compareSelected = [];
    this.compareStartDate = [];
    this.mstAdditionList.forEach(element=>{
      this.compareSelected.push(element.is_enable);
      this.compareStartDate.push(typeof element.start_date === "undefined" ? "" : element.start_date);
    })
    //add FNSI修正 結合バッグ 房 end
    // add FNSI-修正 権限関連 周雨晴 2020/09/27 start
    // del #10359 編集権限の動作不正 start
    // this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // del #10359 編集権限の動作不正 end
    // add FNSI-修正 権限関連 周雨晴 2020/09/27 end
  },
  /**
   *
   */
  beforeDestroy() {
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // EventBus.$off("refresh", this.refresh);
    EventBus.$off("refresh", this.eventBusRefresh);
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  /**
   *
   */
  methods: {
    ...mapMutations("ord-addition", {
      setMode: "setMode"
    }),
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("ord-addition", [
      "sendRequestGetOrdAdditionList",
      "sendRequestGetMstAddition",
      "updateRecordList",
      "sendRequestGetByPatInfo"
    ]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    // add FNSI-修正 権限関連 周雨晴 2020/09/27 start
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // getTreatmentRecordAuthority() {
    //  return this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT) && this.hasAuthorityByCd(AUTHORITY_CODES.PAT_EDIT);
    // },
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    // add FNSI-修正 権限関連 周雨晴 2020/09/27 end

    async refresh(){
      this.setMode("TREATMENT-RECORD");

      if (this.selfScreenName !== this.$router.currentRoute.name || !this.getOrdNo) {
        return;
      }
      const requestParam = {
        // mod #12462 患者情報共有 Ji start
        facilityCd: this.getSharedFacilityCd,
        patId: this.selectedPatId,
        ordNo: this.getOrdNo,
        treatDate: this.getTreatDate,
        ownFacility: this.isShared ? '1' : '0',
	// mod #12462 患者情報共有 Ji end
      };
      await Promise.all([
        this.sendRequestGetByPatInfo({
          facilityCd: this.getFacilityCd,
          patId: this.selectedPatId
        }),
        this.sendRequestGetMstAddition(requestParam)
      ]);
      this.sortAdditionList();
      //  add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
      this.compareSelected = [];
      this.compareStartDate = [];
      this.mstAdditionList.forEach(element=>{
        this.compareSelected.push(element.is_enable);
        this.compareStartDate.push(typeof element.start_date === "undefined" ? "" : element.start_date);
      });
      //  add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    },
     // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
     eventBusRefresh() {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      if (this.isChanged && this.alertFlag) {
        this.discardConfirm(this.refresh);
      } else {
        this.refresh();
      }
      this.alertFlag = true;
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    /**
     * Generic array sorting
     *
     * @param property
     * @returns {Function}
     */
    sortByProperty(property) {
      return function (x, y) {
        return ((x[property] === y[property]) ? 0 : ((parseInt(x[property]) > parseInt(y[property])) ? 1 : -1));
      };
    },

    /**
     * 治療記録のトップ画面に遷移.
     */
    backTreatmentRecord() {
      this.eventBusRefresh();
      // this.$nextTick(() => {
      //   this.$router.push({ name: "treatment-record" });
      // });
    },

    /**
     *
     */
    onClickCancel() {
      this.backTreatmentRecord();
    },

    /**
     * 保存
     */
    async onClickSave() {
      let updateList = [];
      // is_enableがtrueのものを集めてリスト化する
      Object.assign(updateList, this.mstAdditionList.filter(item => item.is_enable));
      let params = {
        ordNo: this.getOrdNo,
        patId: this.selectedPatId,
        facilityCd: this.getFacilityCd,
        updateList: updateList
      };
      if (updateList) {
        // 加算情報の保存（治療記録画面で編集した内容）
        await this.updateRecordList(params, this);
        // 子機能ボタンエリアの更新
        this.$emit("update");
      }
      //mod FNSI修正 結合バッグ 房 start
      await this.refresh();
      //mod FNSI修正 結合バッグ 房 end
      //add FNSI修正 結合バッグ 房 start
      this.compareSelected = [];
      this.compareStartDate = [];
      this.mstAdditionList.forEach(element=>{
        this.compareSelected.push(element.is_enable);
      })
      this.mstAdditionList.forEach(element=>{
        this.compareStartDate.push(element.start_date);
      })
      this.isChanged = false;
      //add FNSI修正 結合バッグ 房 end
    },

    /**
     *
     */
    sortAdditionList() {
      // 加算マスタの内容をソート
      this.mstAdditionList.sort((a, b) => {
          // 1. ON > OFF
          if (a.is_enable < b.is_enable) return 1;
          if (a.is_enable > b.is_enable) return -1;
          // 2. 加算マスタ表示順
          if (a.sort_order_mst < b.sort_order_mst) return -1;
          if (a.sort_order_mst > b.sort_order_mst) return 1;
          // 3. ONデータ配列順
          if (a.sort_order_ord < b.sort_order_ord) return -1;
          if (a.sort_order_ord > b.sort_order_ord) return 1;
        });
    },

    /**
     * @description フォーマット変更
     */
    formatDate(value) {
      if (value === null || value === "" || value == undefined) {
        return null;
      }
      return formatDatetime(value, "YYYY/MM/DD");
    },

    callManualEvent(item, eventName) {
      if (item.is_enable) {
        // チェックオフ→オン
        item.start_date = "";
      }
      item.is_enable = eventName == "un-tick" ? false : true;
      item.isDel = eventName == "un-tick" ? '1' : '0';
      item.kind = '0';
      this.isChanged = true;
    },

    getNowDate(){
      return moment().format();
    },

    // JSONの名前(orditem_name)または加算マスタの名前(additionName)を返す
    getDispName(item) {
      return item.orditem_name ? item.orditem_name : item.additionName;
    },

    isStartDateEdited(index) {
      // 編集前の値を取得
      const beforeVal = this.compareStartDate[index];
      // 編集後の値を取得
      const afterVal = this.mstAdditionList[index]["start_date"];
      if (beforeVal != afterVal) {
        return "date-input-edited";
      }
      return "";
    },
    getChangeStatus() {
      return this.isChanged;
    },
    updateChangeStatus() {
      // NOTE: 破棄確認表示フラグを無効化
      this.alertFlag = false;
    },
  }
};
</script>

<style scoped>
.ntss-list-header-th-sticky {
  white-space: inherit;
  z-index: 1;
  height: 2em;
  padding: 4px 8px;
}
/* add FNSI-改修内容自動算定の修正 徐 start */
.fit-content {
  text-align: center;
}
/* add FNSI-改修内容自動算定の修正 徐 end */
.header-checkbox {
  width: 4em;
  max-width: fit-content;
  white-space: nowrap;
}
.new-btn-area {
  margin-left: 1em;
  margin-bottom: 1em;
  position: sticky;
  z-index: 1;
  top: 0;
  margin: 0;
  background-color: var(--main-background-color);
}
.align-center {
  text-align: center;
}
.align-left {
  text-align: left;
}
tbody tr {
  height: 3.5em;
}
.addition-record-list {
  border-collapse: collapse;
  width: 100%;
  margin: 0 auto;
  background-color: var(--ntss-list-background-color);
}
.round {
  position: relative;
}
ons-checkbox  {
  margin: 0px !important;
}
.last-date {
  width: 1%;
  white-space: nowrap;
}
th.header-last-date {
  white-space: nowrap;
}
/* 時刻入力欄の不要なマージンを除去 */
.start-date-edit-column::-webkit-calendar-picker-indicator {
  display: none;
}
</style>
