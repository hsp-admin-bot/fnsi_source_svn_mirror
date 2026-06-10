<template>
  <modal-base @onClose="closeCheckListModal" class="custom-modal">
    <div slot="body">
      <div class="sub_title">
        <table class="ntss-list-detail">
          <tr>
            <th class="list-header-th-center">点検日</th>
            <th class="list-header-th-center">ベッド</th>
            <th class="list-header-th-center">型式</th>
            <th class="list-header-th-center">製造番号</th>
            <th class="list-header-th-center">装置名</th>
          </tr>
          <tr>
            <td
              class="ntss-list-body-td"
              :class="dateStringStyle"
            >{{ dateString }}</td>
            <td class="ntss-list-body-td">{{ getMachine.bedName }}</td>
            <td class="ntss-list-body-td">{{ getMachine.machineType }}</td>
            <td class="ntss-list-body-td">{{ getMachine.machineSerial }}</td>
            <td class="ntss-list-body-td">{{ getMachine.machineName }}</td>
          </tr>
        </table>
      </div>
      <div
        v-for="layout in getResultMaster"
        :key="getLayoutKey(layout)"
        class="layout-box"
      >
        <table class="layout-detail">
          <tr v-if="layout.layoutTitle != null">
            <th class="list-header-th">{{ layout.layoutTitle }}</th>
          </tr>
          <tr>
            <th
              class="list-header-th list-header-nogradient"
            >{{ layout.groupHeader }}</th>
          </tr>
        </table>
        <table v-if="!!layout.items.length" class="layout-detail">
          <thead>
            <tr>
              <th
                class="list-header-th-center list-header-nogradient col-width-content"
              >点検対象</th>
              <th
                class="list-header-th-center list-header-nogradient col-width-content"
              >点検基準</th>
              <th
                class="list-header-th-center list-header-nogradient col-width-answer"
              >
                結果
                <v-ons-button
                  modifier="quiet"
                  :disabled="!hasDailyCheckAuthority"
                  @click="updateAllResult(layout)"
                >全</v-ons-button>
              </th>
              <th
                class="list-header-th-center list-header-nogradient col-width-comment"
              >検査コメント</th>
              <th
                colspan="2"
                class="list-header-th-center list-header-nogradient"
              >点検者</th>
              <th
                class="list-header-th-center list-header-nogradient col-width-datetime"
              >実施日時</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in layout.items"
              :key="getItemKey(item)"
              :class="evenOddClassNames[index % 2]"
            >
              <td class="ntss-list-body-td col-width-content">{{ item.menteContent1 }}</td>
              <td class="ntss-list-body-td col-width-content">{{ item.menteContent2 }}</td>
              <td class="ntss-list-body-td col-width-answer">
                <label
                  class="ntss-custom-input input-answer"
                  :class="getAnswerClass(item)"
                  style="display: block; height: 30px;"
                  @click="updateAnswer(item)"
                >{{ convertStatus(item.answer) }}</label>
                <template v-if="!!isCmtOn[item.isCmt]">
                  <div
                    class="ntss-custom-input"
                    style="height: 0; padding: 0; border-width: 0;"
                  ><br /></div>
                  <custom-simple-textarea-b
                    v-model="item.iniText"
                    class="ntss-custom-input input-focus input-answer"
                    :class="getSubCommentClass(item)"
                    :disabled="!hasDailyCheckAuthority"
                  />
                </template>
              </td>
              <td class="ntss-list-body-td col-width-comment">
                <custom-simple-textarea-b
                  v-model="item.comment"
                  class="ntss-custom-input input-focus input-comment"
                  :class="getCommentClass(item)"
                  lineBreakabled
                  :disabled="!hasDailyCheckAuthority"
                />
              </td>
              <td class="ntss-list-body-td col-width-checker">
                <show-selected-item
                  class="input-checker"
                  :propEditValue="getFullName(item)"
                  :propInitValue="getKeepItemFullName(item)"
                  propBackgroundColor="#ebebe4"
                />
              </td>
              <td class="ntss-list-body-td col-width-checker-button">
                <master-selector
                  :index="index"
                  :readMasterData="fetchPersonalUserAll"
                  :masterDefine="personalUser"
                  :value="getCheckerUser(layout, item)"
                  @changePersonalUser="userInfo => updateCheckerUser(item, userInfo)"
                  :isDisabled="!hasDailyCheckAuthority"
                />
              </td>
              <td class="ntss-list-body-td col-width-datetime">
                <time-input
                  v-model="item.time"
                  :classes="getTimeClasses(item)"
                  :disabled="!hasDailyCheckAuthority"
                  @blur="updateTime(item)"
                  @handleClearInput="clearTime(item)"
                />
                <common-calendar
                  v-model="item.date"
                  class="calender"
                  :disabled="!hasDailyCheckAuthority"
                  @blur="updateDate(item)"
                  @todayButtonClick="updateDate(item)"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <modal-history v-if="showHistory" />
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background: none;">
        <v-ons-button
          class="btn2-cancel"
          @click="closeCheckListModal"
        >キャンセル</v-ons-button>
      </div>
      <div class="denial-btn-area" style="background: none;">
        <v-ons-button
          class="btn4-alert"
          :disabled="!getDevMenteNo.length || !hasDailyCheckAuthority"
          @click="delDevMenteNo"
        >削除</v-ons-button>
      </div>
      <div class="denial-btn-area close-button" style="background: none;">
        <v-ons-button
          class="btn3-normal"
          @click="openHistoryModal"
        >点検履歴</v-ons-button>
      </div>
      <div class="denial-btn-area close-button" style="background: none;">
        <v-ons-button
          class="btn1-execute"
          :disabled="!hasDailyCheckAuthority || !isEdited"
          @click="updateAllResultSave"
        >保存</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background: none;"></div>
    </div>
  </modal-base>
</template>

<script>
import store from "@/stores";
import { EventBus } from "@/eventBus";
import ModalBase from "@/components/modals/ModalBase";
import moment from "moment";
import { mapActions, mapGetters, mapMutations } from "vuex";
import HistoryModal from "@/components/daily-check/DailyHistoryModal";
import { deepCopy, getHolidayStyle } from "@/functions/common/CommonFunctions";
import CommonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
import TreatmentRecordSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import { personalUser } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { confirmIsOkByKey } from "@/functions/common/OnsenFunctions";
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
import TimeInput from "@/components/common/TimeInput";
import {
  sendRequestUpdateCheckResultList,
  sendRequestDeleteDevMenteNo,
} from "@/apis/daily-check";
import {
  sendRequestGetMstPersonalUser,
  sendRequestMstGetJobs,
} from "@/apis/user-selector-popover";
import { convertStatus } from "@/functions/DailyInspectionFunction";
import { Answer } from "@/constants/mainteConstants";
import { Master } from "@/models/common/master-selector-condition/Master";

// レイアウトを特定するキー文字列を生成する関数
const getLayoutKey = layout => `${layout.menteLayoutCd}`;
// レイアウト内で点検項目を特定するキー文字列を生成する関数
const getItemKey = item => `${item.menteCategoryCd}_${item.menteDetailCd}`;

export default {
  mixins: [ComponentGuardMixin],
  name: "DailyCheckModal",
  components: {
    "modal-base": ModalBase,
    "modal-history": HistoryModal,
    "common-calendar": CommonCalender,
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB,
    "time-input": TimeInput,
    "show-selected-item": CustomDivShowSelectedItem,
    "master-selector": TreatmentRecordSelectorComponent,
  },
  data() {
    return {
      dateInspection: "",
      showHistory: false,
      authorityCds: [
        AUTHORITY_CODES.DEV_PEDIT,  // 機器保守-代行編集
        AUTHORITY_CODES.DEV_EDIT,   // 機器保守-編集
      ],
      hasDailyCheckAuthority: false,
      listResultMasterKeep: [],
      checkerUsersMap: {},
      evenOddClassNames: Object.freeze(["even-row", "odd-row"]),
      isCmtOn: Object.freeze({ "1": true }),
      personalUser,
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("daily-check", [
      "getDailyDateSearch",
      "getResultMaster",
      "getMachine",
      "getIsOpenBySubView",
    ]),
    getDevMenteNo() {
      const listMenteNo = this.getResultMaster.map(
        obj => obj.devMenteNo
      ).filter(menteNo => !!menteNo);
      return listMenteNo;
    },
    dateString() {
      return moment(this.dateInspection).format("YYYY/MM/DD(dd)");
    },
    dateStringStyle() {
      // 休日のスタイル取得
      return getHolidayStyle(this.dateString, true);
    },
    isEdited() {
      const rMKeep = this.listResultMasterKeep;
      return !!rMKeep.length && this.getResultMaster.some(
        (aLayout, i) => !isEqualItemsValue(aLayout, rMKeep[i])
      );
    },
    currentUserId() {
      return this.getStateUserAccountInfo.userId;
    },
    currentUserFullName() {
      const { userLastName, userFirstName } = this.getStateUserAccountInfo;
      return `${userLastName} ${userFirstName}`;
    },
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("daily-check", [
      "sendRequestGetDetail",
      "setSelectedFromHistory",
    ]),
    ...mapActions("loading-screen", ["executeWithLoadingScreen"]),
    ...mapMutations("daily-check", ["setIsOpenBySubView"]),
    convertStatus,
    getLayoutKey,
    getItemKey,

    getKeepItem(item) {
      const layout = this.getLayoutFromItem(item);
      const layoutIndex = this.getResultMaster.indexOf(layout);
      const index = layout.items.indexOf(item);
      const rMKeep = this.listResultMasterKeep;
      return rMKeep.length ? rMKeep[layoutIndex].items[index] : null;
    },
    getAnswerClass(item) {
      const keep = this.getKeepItem(item);
      const edited = !!keep && (item.answer !== keep.answer);
      return edited ? "edit-green" : "";
    },
    getInputTextClass(item, key) {
      const keep = this.getKeepItem(item);
      const edited = !!keep && ((item[key] || "") !== (keep[key] || ""));
      return edited ? "input-edited" : "";
    },
    getSubCommentClass(item) {
      return this.getInputTextClass(item, "iniText");
    },
    getCommentClass(item) {
      return this.getInputTextClass(item, "comment");
    },
    getFullName(item) {
      // CustomDivShowSelectedItem の初期値に関する誤動作を避けるため
      // （getKeepItemFullName の挙動に合わせるように）
      // listResultMasterKeep の内容が有効でない場合は "" を返す
      return this.listResultMasterKeep.length ? item.fullName : "";
    },
    getKeepItemFullName(item) {
      const keep = this.getKeepItem(item);
      return keep?.fullName || "";
    },
    getTimeClasses(item) {
      const keep = this.getKeepItem(item);
      const edited = !!keep && ((item.dateUpdate || "") !== (keep.dateUpdate || ""));
      const classNames = ["time-input-focus"];
      if (edited) {
        classNames.push("time-input-edited");
      }
      const classes = classNames.join(" ");
      return classes;
    },
    fetchPersonalUserAll() {
      return Promise.all([
        sendRequestGetMstPersonalUser(this.getFacilityCd),
        sendRequestMstGetJobs(this.getFacilityCd),
      ]);
    },
    requestReportParams(param) {
      if (!this.getIsOpenBySubView || this.showHistory) return;
      // 機能コード判定
      if (param.substring(0, 3) !== getCurrentFunctionCd().substring(0, 3)) return;

      // 印刷パラメータを応答
      // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
      const date = moment(this.dateString, "YYYY/MM/DD(EE)").format("YYYYMMDD");
      // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
      const reportParams = {
        patId: this.selectedPatId,
        date,
        functionCd: "03401",
        facilityCd: this.getFacilityCd,
        machineNos: [this.getMachine.machineNo],
        mainte_no: this.getDevMenteNo[0],
        fromDate: date,
        toDate: date,
      };
      EventBus.$emit("sendReportParams", reportParams);
    },
    async closeCheckListModal() {
      // 変更が有り、かつ破棄確認でキャンセルした場合にfalseを返す
      const isOk = await this.confirmAllowDiscardChanges();
      // 破棄確認でキャンセルされた場合は点検項目入力画面を閉じずに終わる
      if (!isOk) return;

      // 日常点検画面の再検索を行って点検項目入力画面を閉じる
      EventBus.$emit("filterDailyCheckList");
      this.hideModal();
    },
    updateAllResult(layout) {
      // 対象項目に合否が異なるものがある状態か判定する
      const items = layout.items;
      const devided = (items.length > 1) && items.some((item, index) => (
        ((index + 1) < items.length)
        && (item.answer !== items[index + 1].answer)
      ));
      if (devided) {
        // 対象項目に合否が異なるものがある場合、全て合格にする
        items.forEach(item => {
          // 合格でないものを合格にして点検者と実施日時を更新する
          // （すでに合格の項目は点検者と実施日時がそれぞれ空欄でなければ維持する）
          if (item.answer !== Answer.Good) {
            this.updateAnswerForce(item, Answer.Good);
          } else {
            this.reactionAnswer(item);
          }
        });
        // レイアウトの点検結果を更新する
        layout.menteAns1 = Answer.Good;
      } else if (items.length) {
        // （対象項目が1項目以上存在し）対象項目の合否が全て同じ場合
        // 合否を順に切り替えて点検者と実施日時を更新する
        const nextAnswer = getNextAnswer(items[0].answer);
        if (nextAnswer !== Answer.Dummy) {
          items.forEach(item => {
            this.updateAnswerForce(item, nextAnswer);
          });
          // レイアウトの点検結果を更新する
          layout.menteAns1 = nextAnswer;
        }
      }
    },
    updateAnswerForce(item, answer) {
      item.answer = answer;
      this.reactionAnswer(item, true);
    },
    async updateAllResultSave() {
      await this.executeWithLoadingScreen(async () => {
        // 更新対象のレイアウトに対する更新API用のパラメータを生成する
        const layouts = this.createChangedLayouts();
        // 更新対象のレイアウトについて更新APIを呼ぶ
        await Promise.all(layouts.map(
          aLayout => sendRequestUpdateCheckResultList(aLayout)
        ));

        EventBus.$emit("refreshData");
        await this.$nextTick();
        this.hideModal();
      });
    },
    createChangedLayouts() {
      const rMKeep = this.listResultMasterKeep;
      const layouts = [];
      this.getResultMaster.forEach((aLayout, i) => {
        // detail の更新
        const newDetails = aLayout.items.map(item => {
          // 検索API側でレスポンスに入れる点検項目マスタのEntityに
          // グループマスタ版数の情報を持たせるために
          // 日常点検用では使用しない menteContent3 に文字列として入れている
          const cate_edi = Number(item.menteContent3);
          const date = item.dateUpdate
            ? moment(item.dateUpdate).toISOString()
            : "";
          const newDetail = {
            cate_cd: item.menteCategoryCd,
            cate_edi,
            detail_cd: item.menteDetailCd,
            detail_edi: item.editionNo,
            judge: item.answer,
            comment: item.comment,
            sub_cmt: item.iniText,
            user_id: item.checkerId,
            date,
          };
          return newDetail;
        });
        aLayout.detail = JSON.stringify(newDetails);

        if (!aLayout.mainteCategoryCd) {
          // 点検結果レコードのグループリストの情報がない
          // （≒点検結果レコードがない）場合は
          // グループ名表示用の情報から生成する
          // #9451対応時のメモ：
          // 既存データがある場合のグループリストも
          // 既存データがない場合のグループ名表示用の情報も
          // それぞれ検索APIで取得した値が
          // 型式重複排除処理済みの状態になっている想定
          const mainteCategoryCd = aLayout.categoryList.map((
            { mainteCategoryCd, editionNo }
          ) => (
            { mainteCategoryCd, editionNo }
          ));
          aLayout.mainteCategoryCd = JSON.stringify(mainteCategoryCd);
        }

        // 保存対象かの判定
        // 点検項目が1件以上あり点検結果レコードがない（点検結果コードがnull）、
        // もしくは点検項目ごとの入力値に変化があれば保存対象とする
        if (
          (!aLayout.devMenteNo && aLayout.items.length)
          || !isEqualItemsValue(aLayout, rMKeep[i])
        ) {
          rMKeep[i] = deepCopy(aLayout);
          layouts.push(aLayout);
        }
      });

      return layouts;
    },
    getLayoutFromItem(item) {
      return this.getResultMaster.find(
        layout => layout.items.includes(item)
      );
    },
    changeItemAnswer(item, answer) {
      item.answer = answer;

      // レイアウトの点検結果を判定する
      const layout = this.getLayoutFromItem(item);
      const [
        foundRunning,
        foundNotDate,
        foundGood,
        foundNotGood,
      ] = [
        Answer.Running,
        Answer.NotDateForDb,
        Answer.Good,
        Answer.NotGood,
      ].map(
        anAnswer => layout.items.some(({ answer }) => answer === anAnswer)
      );
      layout.menteAns1 = foundNotGood ? Answer.NotGood : (
        foundRunning ? Answer.Running : (
          (foundNotDate && foundGood) ? Answer.Running : (
            foundGood ? Answer.Good : Answer.NotDateForDb
          )
        )
      );
    },
    updateAnswer(item) {
      // 編集権限がない場合は処理しない
      if (!this.hasDailyCheckAuthority) return;

      // 合否を順に切り替える
      const nextAnswer = getNextAnswer(item.answer);
      if (nextAnswer !== Answer.Dummy) {
        this.changeItemAnswer(item, nextAnswer);
      }

      // 合否変更時の連動処理を行う
      this.reactionAnswer(item);
    },
    // 合否変更時の連動処理を行う
    reactionAnswer(item, force = false) {
      if (item.answer !== Answer.NotDateForDb) {
        // 合否を空欄（未実施）以外に変更した場合
        if (!item.checkerId || force) {
          // 点検者が空欄、もしくは無条件指定の場合はサインイン者に変更する
          this.setCheckerWithCurrentUser(item);
        }
        if (!item.dateUpdate || force) {
          // 実施日時が空欄、もしくは無条件指定の場合は現在日時に変更する
          setDateTimeWithNow(item);
        }
      } else {
        // 合否を空欄（未実施）に変更した場合
        // 点検者と実施日時を空欄に変更する
        this.setCheckerUser(item);
        setDateTimeWithBlank(item);
      }
    },
    getCheckerUser(layout, item) {
      const layoutKey = getLayoutKey(layout);
      const itemKey = getItemKey(item);
      return this.checkerUsersMap[layoutKey]?.[itemKey];
    },
    updateCheckerUser(item, userInfo) {
      const cd = userInfo?.id || null;
      // 入力値が変更されていない場合は処理しない
      if (item.checkerId === cd) return;

      const nameParts = [];
      if (cd) {
        [userInfo.lastName, userInfo.firstName].forEach(part => {
          if (!part) return;
          part = String(part).trim();
          if (!part) return;
          nameParts.push(part);
        });
      }
      const name = nameParts.join(" ");
      this.setCheckerUser(item, cd, name);

      // 点検者変更時の連動処理を行う
      if (item.checkerId) {
        // 点検者を空欄以外に変更した場合
        if (item.answer === Answer.NotDateForDb) {
          // 合否が空欄（未実施）であれば合格に変更する
          this.changeItemAnswer(item, Answer.Good);
        }
        if (!item.dateUpdate) {
          // 実施日時が空欄であれば現在日時に変更する
          setDateTimeWithNow(item);
        }
      }
    },
    setCheckerUser(item, cd = null, name = "") {
      const newMaster = this.createMaster(cd, name);
      const layout = this.getLayoutFromItem(item);
      const layoutKey = getLayoutKey(layout);
      const itemKey = getItemKey(item);
      this.checkerUsersMap[layoutKey][itemKey] = newMaster;
      item.fullName = name;
      item.checkerId = cd;
    },
    setCheckerWithCurrentUser(item) {
      this.setCheckerUser(
        item,
        this.currentUserId,
        this.currentUserFullName
      );
    },
    clearTime(item) {
      // 時刻がクリアされた場合は日付もクリアする
      item.time = "";
      item.date = "";

      // 実施日時変更時の共通処理を行う
      this.reactionDateTime(item);
    },
    updateTime(item) {
      if (!item.time) {
       // 時刻が空欄に変更された場合は日付も空欄にする
        item.date = "";
      } else if (!item.date) {
        // 日付が空欄で時刻が空欄以外に変更された場合は日付をシステム日付にする
        item.date = moment().format("YYYY-MM-DD");
      }

      // 実施日時変更時の共通処理を行う
      this.reactionDateTime(item);
    },
    updateDate(item) {
      if (!item.date) {
       // 日付が空欄に変更された場合は時刻も空欄にする
        item.time = "";
      } else if (!item.time) {
        // 時刻が空欄で日付が空欄以外に変更された場合は時刻をシステム時刻にする
        item.time = moment().format("HH:mm");
      }

      // 実施日時変更時の共通処理を行う
      this.reactionDateTime(item);
    },
    reactionDateTime(item) {
      // 結果的に入力値が変更されていない場合は連動処理は行わない
      const { time, date } = item;
      const dateUpdate = time ? `${date} ${time}` : "";
      if (item.dateUpdate === dateUpdate) return;
      item.dateUpdate = dateUpdate;

      // 実施日時変更時の連動処理を行う
      if (item.dateUpdate) {
        // 実施日時を空欄以外に変更した場合
        if (item.answer === Answer.NotDateForDb) {
          // 合否が空欄（未実施）であれば合格に変更する
          this.changeItemAnswer(item, Answer.Good);
        }
        if (!item.checkerId) {
          // 点検者が空欄であればサインイン者に変更する
          this.setCheckerWithCurrentUser(item);
        }
      } else {
        // 実施日時を空欄に変更した場合
        // 合否と点検者を空欄に変更する
        this.changeItemAnswer(item, Answer.NotDateForDb);
        this.setCheckerUser(item);
      }
    },
    openHistoryModal() {
      this.showHistory = true;
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      store.dispatch("report/getMstReport", { funcCd: "03401", printFlag: 2 });
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    },
    // 変更が有り、かつ破棄確認でキャンセルした場合にfalseを返す
    async confirmAllowDiscardChanges() {
      // 変更がなければtrueを返す
      if (!this.isEdited) return true;

      // title: "内容破棄",
      // message: "編集中の情報が破棄されます\nキャンセルしてよろしいですか？",
      const isOk = await confirmIsOkByKey(13000117);
      return isOk;
    },
    async closeHistoryModal(params) {
      if (params) {
        // 点検履歴から情報取得用パラメータが渡された場合

        // 必要に応じて破棄確認を行う
        const isOk = await this.confirmAllowDiscardChanges();
        // 破棄確認でキャンセルされた場合は再検索処理は行わず点検履歴画面も閉じずに終わる
        if (!isOk) return;

        // 再検索処理を行う
        this.dateInspection = params.date;
        await this.executeWithLoadingScreen(this.requestDetail());
      }
      this.showHistory = false;
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      store.dispatch("report/getMstReport", { funcCd: "03401", printFlag: 1 });
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    },
    // 検索処理を行う
    async requestDetail() {
      // isEdited での誤判定を防ぐため前回の検索時の状態のコピーをクリアしておく
      this.listResultMasterKeep.splice(0);

      await this.sendRequestGetDetail({
        machineNo: this.getMachine.machineNo,
        date: this.dateInspection,
      });

      // 検索時の状態のコピーを保持しておく
      this.listResultMasterKeep = deepCopy(this.getResultMaster);
      // 点検者入力UI用の値を保持するオブジェクトを getResultMaster の内容で初期化する
      this.checkerUsersMap = this.createCheckerUsersMap();
    },
    createCheckerUsersMap() {
      const usersMap = {};
      this.getResultMaster.forEach(layout => {
        const itemsMap = {};
        layout.items.forEach(item => {
          const newMaster = this.createMaster(item.checkerId, item.fullName);
          itemsMap[getItemKey(item)] = newMaster;
        });
        usersMap[getLayoutKey(layout)] = itemsMap;
      });
      return usersMap;
    },
    createMaster(cd, name) {
      // #9451対応時のメモ：
      // 点検者が未選択の場合に利用者選択ポップアップで
      // サインイン者を初期選択させるために
      // 点検者が未選択の状態では利用者選択ポップアップに渡す値としては
      // cd にサインイン者のIDを持つ Master オブジェクトを設定する
      // getResultMaster が持っているDB保存時に使用される点検者の情報は
      // 利用者選択ポップアップで選択確定操作を行った際の
      // updateCheckerUser を起点とした処理でのみ更新されるので
      // checkerUsersMap に持っている情報は影響しない
      return new Master(cd || this.currentUserId, name);
    },
    async delDevMenteNo() {
      const convertListMainNo = { listMainNo: this.getDevMenteNo };

      // title: "削除確認",
      // message: "削除すると二度と元に戻せません。削除してもよろしいですか？",
      const isOk = await confirmIsOkByKey(13000006);
      if (!isOk) return;

      await this.executeWithLoadingScreen(async () => {
        await this.$nextTick();
        await sendRequestDeleteDevMenteNo(convertListMainNo);
        EventBus.$emit("refreshData");
        await this.$nextTick();
        this.hideModal();
      });
    },
    getDailyCheckAuthority() {
      return (
        this.hasAuthorityByCd(AUTHORITY_CODES.DEV_PEDIT)
        || this.hasAuthorityByCd(AUTHORITY_CODES.DEV_EDIT)
      );
    },
  },
  async created() {
    await this.executeWithLoadingScreen(async () => {
      this.dateInspection = this.getDailyDateSearch;
      this.hasDailyCheckAuthority = this.getDailyCheckAuthority();

      // 初期検索処理を行う
      await this.requestDetail();

      EventBus.$on("closeHistory", this.closeHistoryModal);
      EventBus.$on("requestReportParams", this.requestReportParams);

    });
  },
  beforeDestroy() {
    store.dispatch("report/getMstReport", { funcCd: "03401", printFlag: 0 });
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    this.setIsOpenBySubView(false);
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    EventBus.$off("closeHistory", this.closeHistoryModal);
    EventBus.$off("requestReportParams", this.requestReportParams);
  },
};

// 合否を順に切り替える場合の次の値を返す
const getNextAnswer = answer => {
  const AnswerArray = [
    Answer.NotDateForDb,
    Answer.Good,
    Answer.Running,
    Answer.NotGood,
    Answer.NotDateForDb,
  ];
  const current = AnswerArray.indexOf(answer);
  return (current < 0) ? Answer.Dummy : AnswerArray[current + 1];
};
// 実施日時に現在日時を設定する関数
const setDateTimeWithNow = item => {
  const dateTmp = moment().format("YYYY-MM-DD HH:mm");
  item.date = dateTmp.substring(0, 10);
  item.time = dateTmp.substring(11);
  item.dateUpdate = dateTmp;
};
// 実施日時を空欄に変更する関数
const setDateTimeWithBlank = item => {
  item.time = "";
  item.date = "";
  item.dateUpdate = "";
};
// レイアウトが持つ点検項目の入力値が同じか判定する関数
const isEqualItemsValue = (layoutA, layoutB) => layoutA.items.every(
  (itemA, index) => {
    const itemB = layoutB.items[index];
    return (
      (itemA.answer === itemB.answer)
      && ((itemA.comment || "") === (itemB.comment || ""))
      && ((itemA.iniText || "") === (itemB.iniText || ""))
      && (itemA.checkerId === itemB.checkerId)
      && ((itemA.dateUpdate || "") === (itemB.dateUpdate || ""))
    );
  }
);
</script>

<style scoped>
.table-header-check-all {
  color: #fff;
  padding: 4px;
  padding-left: 8px;
  white-space: nowrap;
  border-top: none;
  top: 0;
  position: sticky;
  text-align: left;
  z-index: 2;
  background-color: #333333;
  border: solid 1px #cccccc;
  border-top: none;
}

.table-header-check-all:after {
  vertical-align: center;
  padding-left: 4px;
}

.list-header-th {
  text-align: left;
  background-color: var(--ntss-list-header-background-color);
  height: 20px;
  color: #fff;
  border: solid 1px #cccccc;
  font-weight: normal;
}

.list-header-th-center {
  text-align: center;
  background-color: var(--ntss-list-header-background-color);
  height: 20px;
  color: #fff;
  border: solid 1px #cccccc;
  font-weight: normal;
}

.list-header-nogradient {
  background-image: none;
}

.ntss-list {
  background-color: #fafafa;
}

.ntss-list-detail {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
  top: 0px;
  background-color: var(--ntss-list-background-color);
}

.ntss-list-header-th-sticky {
  background-color: #333333;
  border: solid 1px #cccccc;
  border-top: none;
}

.ntss-list-body-tr {
  border: solid 1px #cccccc;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.ntss-list-body-td {
  border: solid 1px #cccccc;
  word-break: break-all;
}

.layout-box {
  display: flex;
  flex-direction: column;
  min-width: -webkit-fill-available;
  width: fit-content;
  margin: 20px 0;
  padding: 0 20px;
}
.layout-detail {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
  background-color: var(--ntss-list-background-color);
}

/* 点検対象,点検基準：最小10文字　最大なし可変 */
.col-width-content {
  overflow-wrap: anywhere;
  min-width: 10.5em;
  width: -webkit-fill-available;
}
/* 結果：最小7文字　最大10文字　※テキストボックス幅追従 */
.col-width-answer {
  min-width: fit-content;
  width: 11em;
}
.input-answer {
  min-width: 8em;
  max-width: 11em;
  width: 100%;
}
/* 検査コメント：最小10文字　最大16文字　※テキストボックス幅追従 */
.col-width-comment {
  min-width: fit-content;
  width: 17em;
}
.input-comment {
  min-width: 11em;
  max-width: 17em;
  width: 100%;
}
/* 点検者：最小7文字　最大10文字 */
.col-width-checker {
  border-right-width: 0;
  padding-right: 0;
  min-width: 8em;
  max-width: 11em;
  width: 11em;
}
.input-checker {
  min-width: 8em;
  max-width: 11em;
  width: 100%;
}
.col-width-checker-button {
  border-left-width: 0;
  padding-left: 0;
  min-width: fit-content;
  width: 1px;
}
/* 実施日時：固定　時刻IFカレンダーのサイズに合わせる */
.col-width-datetime {
  white-space: nowrap;
  min-width: fit-content;
  width: 1px;
}

.modal-mask>>>.modal-search {
  top: 43px;
  height: 7.5em;
}

.modal-mask>>>.modal-body-search {
  top: calc(43px + 6.3em);
  height: calc(100% - 42px - 6.3em - 5em);
}

/* 削除ボタン */
.delete-button {
  background-color: #FF3366 !important;
  background-image: -webkit-linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%);
  background-image: linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%);
}

.sub_title {
  padding-left: calc(1.2em + 1px);
  padding-right: calc(1.2em + 1px);
  padding-top: 1em;
}

.close-button {
  margin-left: auto;
}

.button--quiet {
  width: 1.8em;
  height: 1.8em;
  border-radius: 50%;
  color: #000;
  font-weight: bold;
  background-color: #fff;
  vertical-align: unset;
  background-image: none;
}

.even-row {
  background-color: var(---ntss-list-item-background-color);
}

.odd-row {
  background-color: var(--ntss-list-content-2nd-background-color);
}

.ntss-td {
  background-color: var(--ntss-list-header-background-color);
  color: #fff;
  text-align: left;
  border: solid 1px #cccccc;
}

.edit-green {
  color: green;
  font-weight: bold;
}
.input-focus:focus {
  border: 2px green solid;
  outline: 0;
}
.input-edited {
  border: 2px green solid;
  outline: 0;
}
.time-input-edited {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}

@media print {
  /* 印刷時、横幅を収める */
  .modal-mask >>> .modal-container {
    width: 99%;
  }
  /* 点検対象,点検基準 */
  .col-width-content {
    min-width: 8em;
  }
}
</style>
