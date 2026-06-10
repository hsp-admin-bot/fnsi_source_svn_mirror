<template>
  <div class="vertical-div">
    <div class="borderRight" style="width: calc(100% / 4)">
      <div class="disp-item-area topTitle" style="float: left">
          <label class="title ntss-pat-event-label changeRow"
            >掲載有無&emsp;</label
          >
          <span class="switch-area">
          <!-- mod #12462 患者情報共有 20260312 start -->
          <v-ons-switch
            v-model="inputModel.publishedState"
            @change="changePublishedState($event.value)"
            :disabled="
              getViewMode ||
              !isShared ||
              !hasTreatmentRecordAuthority ||
              !allowEdit ||
              !getItemAuthorized('PatEvent', 'default_authority') ||
              getIsOtherFacilitys
            "
          />
          <!-- mod #12462 患者情報共有 20260312 end -->
        </span>
      </div>
    </div>
    <div class="titleRight">
      <div class="disp-item-area">
        <label class="title ntss-pat-event-label">掲載期間&emsp;</label>
        <div>
          <!-- mod #12462 患者情報共有 20260312 start -->
          <input-datatemp
            :dateMax="'9999-12-31'"
            :data="inputModel.noticeStartDate"
            :className="'notice-start-date'"
            :isRequired="true"
            @blur="invalidchk()"
            :disabled="
              isEditedNoticeDate ||
              getViewMode ||
              !isShared ||
              !getItemAuthorized('PatEvent', 'default_authority') ||
              getIsOtherFacilitys
            "
            :tempName="'bbsTempnoticeStartDate'"
          >
          <!-- mod #12462 患者情報共有 20260312 end -->
            <!-- mod #10359 編集権限の動作不正 end -->
            <!--mod FNSI-改修内容6186 任 end-->
          </input-datatemp>
          <!--#10715:日付IF修正End-->
          <!-- mod No.18 付 end -->
        </div>
        <div class="flex-align-center">
          <label class="title ntss-pat-event-label">～</label>
        </div>
        <div>
          <!-- mod #12462 患者情報共有 20260312 start -->
          <input-datatemp
            :dateMax="'9999-12-31'"
            :data="inputModel.noticeEndDate"
            :className="'notice-end-date'"
            :isRequired="true"
            @blur="invalidchk()"
            :disabled="
              isEditedNoticeDate ||
              getViewMode ||
              !isShared ||
              !getItemAuthorized('PatEvent', 'default_authority') ||
              getIsOtherFacilitys
            "
            :tempName="'bbsTempnoticeEndDate'"
          >
          <!-- mod #12462 患者情報共有 20260312 end -->
            <!-- mod #10359 編集権限の動作不正 end -->
            <!--mod FNSI-改修内容6186 任 end-->
          </input-datatemp>
          <!--#10715:日付IF修正End-->
          <!-- mod No.18 付 end -->
        </div>
      </div>
      <div class="bottomTitle">
        <div class="disp-item-area">
          <div class="d-flex checkbox-group">
            <label class="title ntss-pat-event-label">スタッフ&emsp;</label>
            <div class="d-flex align-items-center">
              <!-- mod #12462 患者情報共有 20260312 start -->
              <v-ons-checkbox
                input-id="all-user"
                :checked="staffRadioValue === ALL_USER"
                @change="changeStaffRadioValue(ALL_USER, $event.target)"
                :disabled="
                  getViewMode ||
                  !isShared ||
                  !getItemAuthorized(
                    'PatEvent',
                    'default_authority'
                  ) ||
                  getIsOtherFacilitys
                "
              />
              <label class="title ntss-pat-event-label" for="all-user"
                >全</label
              >
            </div>
            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="individual-user"
                :checked="staffRadioValue === INDIVIDUALLY_USER"
                @change="
                  changeStaffRadioValue(INDIVIDUALLY_USER, $event.target)
                "
                :disabled="
                  getViewMode ||
                  !isShared ||
                  !getItemAuthorized(
                    'PatEvent',
                    'default_authority'
                  ) ||
                  getIsOtherFacilitys
                "
              />
              <label class="title ntss-pat-event-label" for="individual-user"
                >個別選択</label
              >
            </div>
            <span v-show="false">
              <span
                v-for="(staff, staffIndex) in selectedStaffList"
                :key="staffIndex"
                >{{ staff.name }}</span
              >
            </span>
            <button
              ref="staffSelector"
              class="button btn3-normal"
              :disabled="
                !isSelectedIndividualStaff ||
                getViewMode ||
                !isShared ||
                !getItemAuthorized('PatEvent', 'default_authority') ||
                getIsOtherFacilitys
              "
              @click="listSelectStaff()"
            >
              選択
            </button>
            <!-- mod #12462 患者情報共有 20260312 end -->
          </div>
        </div>
      </div>
    </div>
    <list-selector
      :key="componentKey('スタッフ')"
      :visible.sync="isStaffSelectorVisible"
      v-bind="staffSelectorData"
      :disabled="
        !getItemAuthorized('PatEvent', 'default_authority')
      "
      :target="selectorTarget('staffSelector')"
      @commit="commitStaffListSelect($event)"
    />
  </div>
</template>

<script>
  import _ from "underscore";
  import moment from "moment";
  import {mapActions, mapGetters} from "vuex";
  import {ApiHelper} from "@/apis/AxiosHelper";
  /*mod FNSI-改修内容患者eventbug 任 start*/
  /*import listSelector from "@/components/common/list-selector/ListSelector.vue";*/
  import listSelector from "@/components/common/list-selector/ListSelectorBbs.vue";
  /*mod FNSI-改修内容患者eventbug 任 end*/
  /*mod FNSI-改修内容患者eventbug 任 start*/
  /*import {createItemListData} from "@/functions/for-componet/ListSelector.js";*/
  import {createItemListDataBbs} from "@/functions/for-componet/ListSelector.js";
  /*mod FNSI-改修内容患者eventbug 任 end*/
  /*add FNSI-改修内容患者イベントbug 任 start*/
  import {AUTHORITY_CODES} from "@/constants/userAuthority";
  /*add FNSI-改修内容患者イベントbug 任 end*/
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  // add FNSI-権限関連 王 20200927 start
  import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  // add FNSI-権限関連 王 20200927 end
  import {deepCopy, serializeJsonColumn,} from "@/functions/common/CommonFunctions";
  import {createBbs, deleteBbs, updateBbs, updateBbsFileInfo,} from "@/functions/BbsInfoFunctions.js";
  // add No.18 付 start
  import InputDateTemplate from "@/components/common/custom-form-tags/InputDateTemplate";
  // add No.18 付 end
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

// jQureyを宣言（'$'はvue.jsで使用されているため、'$$'で宣言）
const $$ = require("jquery");
// TODO:SOAP区切り文字
const DELIMITER = "\n";
// ラジオボタン選択肢
const INDIVIDUALLY_USER = "0";
const ALL_USER = "1";
const NOT_USER = "2";

export default {
  // add FNSI-権限関連 王 20200927 start
  mixins: [ComponentGuardMixin],
  // add FNSI-権限関連 王 20200927 end
  name: "PatEventBbs",
  props: ["propsIndex"],
  components: {
    "common-calendar": commonCalender,
    "list-selector": listSelector,
    // add No.18 付 start
    "input-datatemp": InputDateTemplate,
    // add No.18 付 end
  },
  data() {
    return {
      inputModel: {
        publishedState: true,
        noticeStartDate: moment().format("YYYY-MM-DD"),
        noticeEndDate: moment().format("YYYY-MM-DD"),
        staffInfo: {
          target: null,
          detail: [],
        },
        func_cd: null,
        kind_no: null,
      },
      // 利用者マスタ
      mstPersonalUser: null,
      // 掲示板種別マスタ
      mstBbsKind: null,
      // 観察記録種別マスタ
      mstObsKind: null,
      /*add FNSI-改修内容患者イベントbug 任 start*/
      checkedAuthority: [],
      /*add FNSI-改修内容患者イベントbug 任 end*/
      // スタッフ選択フラグ
      isStaffSelectorVisible: false,
      // スタッフラジオボタン値
      staffRadioValue: null,
      // 選択したスタッフ
      selectedStaffList: [],
      // スタッフ選択肢
      staffSelectorData: null,
      // DB利用者マスタ
      settingBbs: { auto_read: "1" },
      // デシリアライズ対象のjsonbカラム名
      jsonColumns: ["pat_info", "staff_info", "file_info"],
      //
      account: {
        userId: null,
        userName: null,
      },
      // add FNSI-権限関連 王 20200927 start
      // 治療記録の権限を有無する
      hasTreatmentRecordAuthority: false,
      // add FNSI-権限関連 王 20200927 end
      selfScreenName: "",
      jobList: null
    };
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("bbs-info", ["selectedBbs", "selectedCondition"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
      "getPatEventList",
      /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
      "getViewMode",
      // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
      "getIsNotificationFlg",
      // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
    ]),
    ...mapGetters("pat-event/list", ["getUpdateMode"]),
    // add #12462 患者情報共有 20260312 start
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    // add #12462 患者情報共有 20260312 end
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    isShared() {
      if (this.getPatEventRecord.isComRec) {
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    ALL_USER() {
      return ALL_USER;
    },
    NOT_USER() {
      return NOT_USER;
    },
    INDIVIDUALLY_USER() {
      return INDIVIDUALLY_USER;
    },
    /**
     * @description 掲載日編集フラグ
     * @returns { Boolean } true: 「編集不可」 false: 「編集可」
     */
    isEditedNoticeDate() {
      const publishedState = this.inputModel.publishedState;
      return publishedState === false;
    },
    /**
     * @description スタッフ個別選択フラグ
     * @returns { Boolean } true:活性, false:非活性
     */
    isSelectedIndividualStaff() {
      // ラジオボタンの「個別選択:"0"」が選択時、活性
      return this.staffRadioValue === INDIVIDUALLY_USER;
    },
    /*add FNSI-改修内容患者イベントbug 任 start*/
    allowEdit() {
      if (!this.checkedAuthority.includes(AUTHORITY_CODES.FCL_EDIT)) {
        this.inputModel.publishedState = false;
      }
      return this.checkedAuthority.includes(AUTHORITY_CODES.FCL_EDIT);
    },
    /*add FNSI-改修内容患者イベントbug 任 end*/
    /**
     * @description 掲載日編集フラグ
     * @returns { Boolean } true: 「未編集」 false: 「編集済み」
     */
    isNotEditedNotice() {
      let editedStartDate = this.inputModel.noticeStartDate;
      let editedEndDate = this.inputModel.noticeEndDate;
      editedStartDate = editedStartDate === "" ? null : editedStartDate;
      editedEndDate = editedEndDate === "" ? null : editedEndDate;

      if (editedStartDate !== null) {
        editedStartDate = moment(editedStartDate).format("YYYY-MM-DD");
      }
      if (editedEndDate !== null) {
        editedEndDate = moment(editedEndDate).format("YYYY-MM-DD");
      }
      return (
        moment().format("YYYY-MM-DD") === editedStartDate &&
        moment().format("YYYY-MM-DD") === editedEndDate
      );
    },
  },

  watch: {},
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  destroyed() { },
  async created() {
    // add #10228 掲載期間 開始日連動～開始日連動 linjunfeng start
    const result = this.getPatEventResultParams[this.propsIndex].result_value;
    if (!result) {
      this.inputModel.noticeStartDate = this.$parent.computedCreatedDate;
      this.inputModel.noticeEndDate = this.$parent.computedCreatedDate;
    }
    // add #10228 掲載期間 開始日連動～開始日連動 linjunfeng end
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    /*add FNSI-改修内容患者イベントbug 任 start*/
    this.checkedAuthority =
      this.getStateUserAccountInfo.userSettings.authorized_authorities;
    /*add FNSI-改修内容患者イベントbug 任 end*/
    this.account.userId = this.getStateUserAccountInfo.userId;
    // 利用者、患者、掲示板種別マスタ取得
    const [
      //responsePersonalUser,
      responseBbsKind,
      responseObsKind,
      /*add FNSI-改修内容患者eventbug 任 start*/
      responseJobName,
      /*add FNSI-改修内容患者eventbug 任 end*/
      responseUser,
    ] = await Promise.all([
      // ApiHelper.get(`/mstInfo/mstPersonalUser`, {
      //   facility_cd: this.facilityCd
      // }),
      ApiHelper.get(`/mstInfo/mstBbsKind`, {
        facilityCd: this.facilityCd,
      }),
      ApiHelper.get(`/mstInfo/mstObsKind`, {
        facilityCd: this.facilityCd,
      }),
      /*add FNSI-改修内容患者eventbug 任 start*/
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw start
      //ApiHelper.get(`/bbsInfo/getJobName/${this.facilityCd}`),
      ApiHelper.get(`/bbsInfo/getJobName`),
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw end
      /*add FNSI-改修内容患者eventbug 任 end*/
      ApiHelper.get(`/user/get_by_id/${this.account.userId}`),
    ]).catch((error) => {
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
      getErrorMessage("PatEventBbs.vue", "created", error);
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
      // console.log(`API:"[PatBbsDetailedContent.vue]created(): DB取得失敗");
      // console.log(error);
    });

    // fan add メモリにて利用者マスタ一覧取得 Start
    const uriPersonalUser = `/mstInfo/mstPersonalUser`;
    let mstPersonalUser = this.getMstPersonalUser();
    // メモリにて利用者マスタ一覧情報がない場合、APIを呼出する
    if (!mstPersonalUser) {
      // スタッフ選択肢
      await ApiHelper.get(uriPersonalUser, {
        facility_cd: this.facilityCd,
      }).then((responsePersonalUser) => {
        mstPersonalUser = responsePersonalUser.data;
      });
    }
    // スタッフ選択肢
    //const mstPersonalUser = responsePersonalUser.data;
    // fan add メモリにて利用者マスタ一覧取得 End
    /*add FNSI-改修内容患者eventbug 任 start*/
    mstPersonalUser.forEach((item) => {
      responseJobName.data.forEach((name) => {
        if (Number(item.jobCd) === name.jobCd) {
          item.jobName = name.jobName;
        }
      });
    });
    /*add FNSI-改修内容患者eventbug 任 end*/
    this.jobList = responseJobName.data;
    this.jobList.unshift({
      jobCd: null,
      jobName: ""
    })
    // 選択肢から自身を除外、個人設定では常に選択状態へ
    this.mstPersonalUser = mstPersonalUser.filter(
      (mst) => mst.userId !== this.account.userId
    );
    this.account.userName = mstPersonalUser.find(
      (mst) => mst.userId === this.account.userId
    ).userName;

    // カテゴリ掲示板選択肢
    this.mstBbsKind = responseBbsKind.data;
    // カテゴリ観察記録選択肢
    this.mstObsKind = responseObsKind.data;
    // 個人設定から自動既読機能の状態を取得
    const userSettings = responseUser.data.userAccountInfo.userSettings;

    // 掲示板のストア情報クリア
    this.clearBbsStore();
    // 掲示板詳細初期状態設定
    this.setBbsInfo();

    // add FNSI-権限関連 王 20200927 start
    // 治療記錄の權限取得
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // add FNSI-権限関連 王 20200927 end

    if (
      _.has(userSettings, "personal_settings") &&
      userSettings.personal_settings.length !== 0
    ) {
      // 掲示板の個人設定があれば参照
      const settings = userSettings.personal_settings;
      const settingBbsItem = [
        "auto_read",
        "search_category",
        "sort_column",
        "sort_kind",
      ];

      const personalSettingsBbs = settings.find((setting) => {
        const bbsItems = setting.values.filter((item) =>
          settingBbsItem.includes(item.setting_identifier)
        );
        return bbsItems.length === 4;
      });

      if (personalSettingsBbs !== undefined) {
        const settingBbsList = personalSettingsBbs.values;

        settingBbsList.forEach((item) => {
          if (item.setting_identifier === "auto_read") {
            this.settingBbs.auto_read = JSON.parse(item.value);
          }
        });
      }
    }
  },
  mounted() {},
  methods: {
    ...mapActions("bbs-info", ["setSelectedBbsInfo", "setSelectedBbs"]),
    /*mod FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
    /*...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),*/
    ...mapActions("pat-event/detail", [
      "setPatEventResultParamsUpdate",
      /*add FNSI-改修内容5570 任 start*/
      "setBbsInfoNew",
      /*add FNSI-改修内容5570 任 end*/
      "setPatEventList",
      // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
      "setIsNotificationFlg",
      // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
    ]),
    /*mod FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
    ...mapGetters("user", {
      getMstPersonalUser: "getMstPersonalUser",
    }),
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end

    // add FNSI-権限関連 王 20200927 start
    // 治療記錄の權限を取得する
    getTreatmentRecordAuthority() {
      if (this.getPatEventRecord.isComRec) {
        return this.hasAuthority();
      }
      return true;
    },
    // add FNSI-権限関連 王 20200927 end

    /**
     * @description 画面に表示する初期状態を設定
     */
    async setBbsInfo() {
      const result = this.getPatEventResultParams[this.propsIndex].result_value;
      if (result) {
        this.inputModel.noticeStartDate = this.formatDate(
          result.notice_start_date
        );
        this.inputModel.noticeEndDate = this.formatDate(result.notice_end_date);
        this.inputModel.staffInfo.target = result.staff_info.target;
        this.inputModel.staffInfo.staffCd = result.staff_info.staff_cd;
      } else {
        this.inputModel.staffInfo.target = ALL_USER;
        this.inputModel.staffInfo.staffCd = [];
      }
      // BBSINFOよりスタッフ情報を設定
      //if (this.getPatEventRecord.bbsCtlNo !== 0) {
      //  await this.setSelectedBbsInfo(this.getPatEventRecord.bbsCtlNo);
      //  let bbsRec = deepCopy(this.selectedBbs);
      //  this.inputModel.staffInfo.target = bbsRec.staff_info.target;
      //  this.inputModel.staffInfo.staffCd = bbsRec.staff_info.detail;
      //}
      // DBに登録しているスタッフを選択ボタンの一覧に設定
      // add nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 start
      //BBSINFOよりスタッフ情報を設定
      let bbsRecRead = [];
      if (this.getPatEventRecord.bbsCtlNo !== 0) {
       await this.setSelectedBbsInfo(this.getPatEventRecord.bbsCtlNo);
       let bbsRec = deepCopy(this.selectedBbs);
       bbsRecRead = bbsRec.staff_info.read;
      }
      // add nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 end
      // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
      if (this.inputModel.staffInfo.staffCd != undefined && this.inputModel.staffInfo.staffCd.length === 0 &&
        this.inputModel.staffInfo.target === ALL_USER
      ) {
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end
        // 新規登録時
        // 選択していたスタッフ全て初期化
        this.selectedStaffList = [];
        // スタッフ設定
        this.setAllUser();
        // スタッフラジオボタン設定
        this.staffRadioValue = this.inputModel.staffInfo.target;
      } else {
        // スタッフラジオボタン設定
        this.staffRadioValue = this.inputModel.staffInfo.target;

        // DBに登録されているスタッフ
        // 選択ボタンの選択肢用にコードと名前を設定
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
        if(this.inputModel.staffInfo.staffCd != undefined){
          const staffInfoList = this.inputModel.staffInfo.staffCd.map((staff) => {
            //mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 start
            //const staffCd = staff.staff_cd;
            const staffCd = staff;
            //mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 end
            //　del nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 start
            //const readState = staff.read_state;
            //　del nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 end
            // DBの自身の情報を引き継ぎ
            if (staffCd === this.account.userId) {
              return {
                cd: staffCd,
                //　mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 start
                //name: this.userName,
                name: this.account.userName,
                //　mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 end
                // 自動既読機能ONなら詳細画面開いた時点で「既読: "1"」へ
                //　mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 start
                //readState: this.settingBbs.auto_read ? "1" : readState,
                readState: this.settingBbs.auto_read ? "1" : bbsRecRead.indexOf(staff) === -1 ? "0" : "1" ,
                //　mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 end
              };
            }

            const userName = this.mstPersonalUser.find(
              (mst) => mst.userId === staffCd
            );
            if (userName) {
              //　mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 start
              //return { cd: staffCd, name: userName.userName, readState };
              return { cd: staffCd, name: userName.userName, readState : bbsRecRead.indexOf(staff) === -1 ? "0" : "1"};
              //　mod nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 end
            }
          });
          // 存在しないスタッフ削除
          this.selectedStaffList = staffInfoList.filter((staff) => staff);
        }
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end
        if (this.staffRadioValue === ALL_USER) {
          // 新規追加スタッフ設定 ※上記でDB値を引き継ぎ後処理させる
          this.setAllUser();
        }
      }
      // 掲載有無状態
      this.userReadState = this.isUserRead;
      if (
        /*mod FNSI-改修内容患者イベントbug 任 start*/
        /*this.inputModel.noticeStartDate === null &&
        this.inputModel.noticeEndDate === null*/
        (this.inputModel.noticeStartDate === null &&
          this.inputModel.noticeEndDate === null) ||
        !this.allowEdit
        /*mod FNSI-改修内容患者イベントbug 任 end*/
      ) {
        this.inputModel.publishedState = false;
      } else {
        this.inputModel.publishedState = true;
      }
      // this.changeJson();
    },
    /**
     * @description ラジオボタン個別選択時、常に自身を設定
     */
    setUser() {
      // 自身を常に設定
      const userInfo = {
        cd: this.account.userId,
        name: this.account.userName,
        readState: this.isUserRead ? "1" : "0",
      };

      this.selectedStaffList = [userInfo];
    },
    /**
     * @description ラジオボタン個別選択以外、全スタッフ設定
     */
    setAllUser() {
      const mstSelectUser = [
        ...this.mstPersonalUser.map((mst) => ({ ...mst })),
        { userId: this.account.userId, userName: this.account.userName },
      ];
      const that = this;
      const staffInfo = mstSelectUser.map((user) => {
        const wasStaff = this.selectedStaffList.find(
          (was) => was.cd === user.userId
        );

        // 設定されていたスタッフの状態を引き継ぎ
        const staff_cd = wasStaff === undefined ? user.userId : wasStaff.cd;
        const user_name =
          wasStaff === undefined ? user.userName : wasStaff.name;
        let read_state = wasStaff === undefined ? "0" : wasStaff.readState;

        // DBの自身の情報を引き継ぎ
        if (staff_cd === that.account.userId) {
          // 自動既読機能ONなら詳細画面開いた時点で「既読: "1"」へ
          read_state = that.settingBbs.auto_read ? "1" : read_state;
        }

        // 保存用に変換
        return {
          cd: staff_cd,
          name: user_name,
          readState: read_state,
        };
      });

      this.selectedStaffList = staffInfo;
    },
    /**
     * @description 自身の既読未読状態
     * @returns Boolean true:既読, false:未読
     */
    isUserRead() {
      // 各スタッフから自身のデータを取得
      const state = this.selectedStaffList.find(
        (item) => item.cd === this.account.userId
      );

      // 取得したデータから状態を比較「既読: "1", 未読: "0"」
      return state === undefined ? null : state.readState === "1";
    },
    /**
     * @description リスト選択表示起点
     */
    selectorTarget(refName) {
      return this.$refs[`${refName}`];
    },
    /**
     * @description 掲載開始日付
     */
    setStartNoticeValue(value) {
      //#10715:日付IF修正StartEnd(value　Null判定2行削除)
      this.inputModel.noticeStartDate = value;
      this.changeJson();
    },
    /**
     * @description 掲載終了日付
     */
    setEndNoticeValue(value) {
      this.inputModel.noticeEndDate = value;
      this.changeJson();
    },

    /**
     * @description トグルの既読未読状態を切り替える
     */
    changePublishedState(value) {
      if (value) {
        this.inputModel.noticeStartDate = moment().format("YYYY-MM-DD");
        this.inputModel.noticeEndDate = moment().format("YYYY-MM-DD");
      } else {
        this.inputModel.noticeStartDate = null;
        this.inputModel.noticeEndDate = null;
      }
      this.changeJson();
    },
    /**
     * @description スタッフ選択処理
     */
    listSelectStaff() {
      this.isStaffSelectorVisible = true;
      this.staffSelectorData = this.createStaffSelectorData();
    },
    /**
     * @description スタッフ選択肢作成
     */
    createStaffSelectorData() {
      const title = "スタッフ";
      const class1 = null;
      const class2 = null;

      // 既に選択済みならデフォルト選択リストを設定
      const defaultSelection = _.isEmpty(this.selectedStaffList)
        ? []
        : this.selectedStaffList.map((item) => item.cd);
      /*mod FNSI-改修内容患者eventbug 任 start*/
      /*const itemList = createItemListData(
        this.mstPersonalUser,
        "userId",
        "userName"
      );*/
      const itemList = createItemListDataBbs(
        this.mstPersonalUser,
        "userId",
        "",
        "userName",
        true,
        "",
        "",
        "jobName",
        "",
        "",
        "",
        "jobCd"
      );
      /*mod FNSI-改修内容患者eventbug 任 end*/

      let jobList = this.jobList;

      return { title, itemList, class1, class2, defaultSelection, jobList };
    },
    /**
     * @description スタッフラジオボタン値を設定
     * @param {String}
     */
    changeStaffRadioValue(value, e) {
      e.checked = true;
      this.staffRadioValue = value;
      this.inputModel.staffInfo.target = value;
      if (this.isSelectedIndividualStaff) {
        // 個別選択時
        this.setUser();
      } else {
        this.setAllUser();
      }
      this.changeJson();
    },
    //#10715:日付IF修正Start
    invalidchk(){
      let startdate =  new Date(this.inputModel.noticeStartDate);
      let enddate = new Date(this.inputModel.noticeEndDate);
      let startclassnm = document.getElementsByClassName("notice-start-date");
      let endclassnm = document.getElementsByClassName("notice-end-date");
      if (startdate <= enddate) {
        startclassnm[0].classList.remove("custom-input-date-invalid");
        endclassnm[0].classList.remove("custom-input-date-invalid");
      }
    },
    //#10715:日付IF修正End
    /**
     * @description スタッフ選択確定
     */
    commitStaffListSelect(selectedList) {
      // 選択されたコードと名称を格納
      const selectedStaffList = selectedList.map((selected) => {
        // 以前から選択済みのスタッフ既読未読状態引き継ぎ
        const bbsInfo = this.inputModel.staffInfo.staffCd.find(
          //　nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 start
          //(bbs) => bbs.staff_cd === selected.cd
          (bbs) => bbs === selected.cd
          //　nikkiso-fnsi不具合.xlsx　「No38」 IES内部試験修正 周安寧 end
        );
        return {
          cd: selected.cd,
          name: selected.name,
          // 新規選択したスタッフ未読状態
          readState: bbsInfo === undefined ? "0" : bbsInfo.read_state,
        };
      });

      // 自身を常に設定
      const userInfo = {
        cd: this.account.userId,
        name: this.account.userName,
        readState: this.isUserRead ? "1" : "0",
      };
      this.selectedStaffList = [userInfo, ...selectedStaffList];
      this.changeJson();
    },
    /**
     * @description コンポーネントを再利用させないためのkey属性値(現在日時+文字列)
     * @summary コンポーネントの再利用によって選択項目やフィルタに設定した値が残ったままになるのを防ぐ
     * @param {String} str 任意の文字列 ※コンポーネントごとに変えること
     * @returns {String} YYYYMMDDHHmmssSSS
     */
    componentKey(str) {
      return `${moment().format("YYYYMMDDHHmmssSSS")}${str}`;
    },
    /**
     * @description input内部データへフォーマットを変更
     */
    formatDate(date) {
      return date === null ? null : moment(date).format("YYYY-MM-DD");
    },
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
    formatTime(date) {
      return date === null ? null : moment(date).format("YYYY-MM-DD HH:mm");
    },
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
    /**
     * @description フォーマット変更
     */
    formattedSaveDate(value) {
      if (value === null || value === "") {
        return null;
      }
      return moment(value).format();
    },
    /**
     * @description JSONの書込み処理
     */
    async changeJson() {
      const result = this.getPatEventResultParams[this.propsIndex];

      // 掲載期間
      const noticeStartDate = this.formattedSaveDate(
        this.inputModel.noticeStartDate
      );
      const noticeEndDate = this.formattedSaveDate(
        this.inputModel.noticeEndDate
      );

      // 選択したスタッフ情報設定
      if (this.staffRadioValue === ALL_USER) {
        // 全スタッフ選択
        // 退職、入社等に対応させるため、更新の度、全スタッフを再設定
        this.setAllUser();
      }
      const selectedStaffInfo = this.selectedStaffList.map((staff) => {
        // 保存用に変換
        return staff.cd;
      });
      const staffInfo = {
        target: null,
        staff_cd: [],
      };
      staffInfo.staff_cd = selectedStaffInfo;
      staffInfo.target = this.staffRadioValue;
      const value = {
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
        format_class: result ? result.format_class : null,
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end
        result_value: {
          // upd #9532 編集しても保存ボタンが活性しない 修正 20230912 ztc start
          // notice_start_date: noticeStartDate,
          // notice_end_date: noticeEndDate,
          staff_info: staffInfo,
          notice_end_date: noticeEndDate,
          notice_start_date: noticeStartDate,
          // upd #9532 編集しても保存ボタンが活性しない 修正 20230912 ztc end
        },
      };
      /*add FNSI-改修内容5570 任 start*/
      // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
      if(!!result && result.result_value === ""){
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end
        this.setBbsInfoNew(value.result_value);
      }
      /*add FNSI-改修内容5570 任 end*/
      await this.setPatEventResultParamsUpdate({
        item: value,
        index: this.propsIndex,
      });
    },
    clearBbsStore() {
      const bbsInfo = {
        bbs_ctl_no: null,
        facility_cd: null,
        pat_info: { target: null, detail: [] },
        staff_info: {
          target: [],
          read: [],
        },
        func_cd: null,
        kind_no: null,
        fn_seq_id: null, // 内容管理番号(観察記録等)
        content: null,
        file_info: [],
        notice_start_date: null,
        notice_end_date: null,
        reg_staff_id: null,
        reg_staff_name: null,
        upd_staff_id: null,
        upd_staff_name: null,
        transition_router_path: null,
        reg_date: null,
        up_date: null,
        title: null,
        notice_fac_cal_start_date: null,
        notice_fac_cal_end_date: null,
        is_disp_bbs: "1",
        color: null,
        reg_func_class: 1,
      };
      // storeに空を設定
      this.setSelectedBbs(bbsInfo);
    },
    /**
     * @description DB保存
     */
    async saveRecord() {
      if (this.getPatEventRecord.bbsCtlNo !== 0) {
        await this.setSelectedBbsInfo(this.getPatEventRecord.bbsCtlNo);
      }
      let bbsRec = deepCopy(this.selectedBbs);
      // 更新日時
      const nowDate = moment().format();

      // 編集した値をレコードに設定

      const bbsCtlNo = bbsRec.bbs_ctl_no;

      // 掲載期間
      /*mod FNSI-改修内容画面でエラーが表示されなくて登録失敗の件 任 start*/
      /*bbsRec.notice_start_date = this.formattedSaveDate(
        this.inputModel.noticeStartDate
      );
      bbsRec.notice_end_date = this.formattedSaveDate(
        this.inputModel.noticeEndDate
      );*/
      if (this.inputModel.noticeStartDate === null) {
        bbsRec.notice_start_date = null;
      } else {
        bbsRec.notice_start_date = moment(
          this.inputModel.noticeStartDate
        ).format("YYYYMMDD");
      }
      if (this.inputModel.noticeEndDate === null) {
        bbsRec.notice_end_date = null;
      } else {
        bbsRec.notice_end_date = moment(this.inputModel.noticeEndDate).format(
          "YYYYMMDD"
        );
      }
      /*mod FNSI-改修内容画面でエラーが表示されなくて登録失敗の件 任 start*/
      bbsRec.facility_cd = this.facilityCd;

      // 選択したスタッフ情報設定
      let target = [];
      if (this.staffRadioValue !== ALL_USER) {
        target = this.selectedStaffList.map((staff) => {
          // 保存用に変換
          return staff.cd;
        });
      }
      const filterParam = (item) => {
        return item.readState === "1";
      };
      const filterMapping = (item) => {
        return item.cd;
      };
      let read = this.selectedStaffList.filter(filterParam).map(filterMapping);
      bbsRec.staff_info.read = read;
      bbsRec.staff_info.target = target;
      bbsRec.pat_info.target = "0";
      bbsRec.pat_info.detail = [];
      bbsRec.pat_info.detail.push(this.selectedPatId);

      bbsRec.content = this.shapingResultParams(this.getPatEventRecord);
      // 最終更新者IDに自身を設定
      bbsRec.upd_staff_id = this.account.userId;
      // 最終更新者名に自身を設定
      bbsRec.upd_staff_name = this.account.userName;
      bbsRec.up_date = nowDate;
      // 掲示板種別
      bbsRec.kind_no =
        this.getPatEventInputParams[this.propsIndex].item_json.kind_no;
      // 機能コード
      bbsRec.func_cd = "020";

      if (bbsCtlNo === null) {
        /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
        if (this.getPatEventList.length > 0) {
          const patParams = this.getPatEventList[0];
          if (patParams.eventStartTime === null) {
            /*mod FNSI-改修内容画面でエラーが表示されなくて登録失敗の件 任 start*/
            /*bbsRec.notice_fac_cal_start_date = this.formattedSaveDate(`${this.formatDate(patParams.eventStartDate)} 00:00:00`);
          }else{
            bbsRec.notice_fac_cal_start_date = this.formattedSaveDate(`${this.formatTime(patParams.eventStartDate+" "+patParams.eventStartTime)}:00`);
          }
          if(patParams.eventEndTime === null){
            bbsRec.notice_fac_cal_end_date = this.formattedSaveDate(`${this.formatDate(patParams.eventEndDate)} 00:00:00`);
          }else{
            bbsRec.notice_fac_cal_end_date = this.formattedSaveDate(`${this.formatTime(patParams.eventEndDate+" "+patParams.eventEndTime)}:00`);*/
            bbsRec.notice_fac_cal_start_date = patParams.eventStartDate;
            bbsRec.notice_fac_cal_start_time = "0000";
            bbsRec.is_time_start_flg = "0";
          } else {
            bbsRec.notice_fac_cal_start_date = patParams.eventStartDate;
            bbsRec.notice_fac_cal_start_time = patParams.eventStartTime;
            bbsRec.is_time_start_flg = "1";
          }
          if (patParams.eventEndTime === null) {
            bbsRec.notice_fac_cal_end_date = patParams.eventEndDate;
            bbsRec.notice_fac_cal_end_time = "2359";
            bbsRec.is_time_end_flg = "0";
          } else {
            bbsRec.notice_fac_cal_end_date = patParams.eventEndDate;
            bbsRec.notice_fac_cal_end_time = patParams.eventEndTime;
            bbsRec.is_time_end_flg = "1";
            /*mod FNSI-改修内容画面でエラーが表示されなくて登録失敗の件 任 start*/
          }
        }
        /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
        // 掲示板番号がnullなら掲示板を新規として登録
        // 起票者・名、登録日時設定
        bbsRec.reg_staff_id = bbsRec.upd_staff_id;
        bbsRec.reg_staff_name = bbsRec.upd_staff_name;
        bbsRec.reg_date = nowDate;
      }
      bbsRec.is_disp = "1";
      if (this.$parent.isObserveDetail) {
        bbsRec.transition_router_path = "observe-record";
      } else {
        bbsRec.transition_router_path = "pat-event";
      }
      bbsRec.reg_func_class = 1;
      // ファイル情報設定
      bbsRec.file_info = [];
      const serializedRecord = serializeJsonColumn(bbsRec, this.jsonColumns);

      if (bbsCtlNo === null) {
        const bbsCtlNo = await createBbs(serializedRecord, false);
        /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
        if (this.getPatEventList.length > 1) {
          this.setPatEventList(
            this.getPatEventList.splice(1, this.getPatEventList.length)
          );
        } else {
          this.setPatEventList([]);
        }
        /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
        // 掲載無しの場合は表示を非表示にする
        if (!this.inputModel.publishedState) {
          await deleteBbs(bbsCtlNo);
        }
        this.clearBbsStore();
        return bbsCtlNo;
      } else {
        // mod 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
        // await updateBbs(serializedRecord);
        if (this.getIsNotificationFlg === null) {
          this.setIsNotificationFlg(false);
        }
        await updateBbs(serializedRecord,this.getIsNotificationFlg);
        // mod 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
        // 掲載無しの場合は表示を非表示にする
        if (!this.inputModel.publishedState) {
          await deleteBbs(bbsCtlNo);
        }
        this.clearBbsStore();
        return bbsCtlNo;
      }
    },
    shapingResultParams(patEventRecord) {
      const resPara = patEventRecord.resultParams;
      const inpPara = patEventRecord.inputParams;
      let result = "";
      if (resPara.length > 0) {
        for (var i = 0; i < resPara.length; i++) {
          const res = resPara[i];
          const inp = inpPara[i];
          //0: テキスト
          if (res.format_class === 0) {
            result = this.getText(inp, res, result);
          }
          //1: テキストエリア
          if (res.format_class === 1) {
            let text = inp.field_name + "：設定なし";
            if (inp.item_json.is_formatting === "1") {
              let areatext = $$("<div>").html(res.result_value).text();
              if (areatext.trim().length !== 0) {
                text = inp.field_name + "：" + areatext;
              }
            } else {
              if (res.result_value.trim().length > 0) {
                text = inp.field_name + "：" + res.result_value;
              } else {
                text = inp.field_name + "：設定なし";
              }
            }
            if (result !== "") {
              result = result + DELIMITER + text;
            } else {
              result = text;
            }
          }
          //3:リスト選択
          if (res.format_class === 3) {
            result = this.getListRaidoText(inp, res, result);
          }
          //4:ラジオボタン
          if (res.format_class === 4) {
            result = this.getListRaidoText(inp, res, result);
          }
          //5:日付
          if (res.format_class === 5) {
            result = this.getText(inp, res, result);
          }
          //6:チェックボックス
          if (res.format_class === 6) {
            let text = inp.field_name + "：設定なし";
            let first = true;
            if (res.result_value.length > 0) {
              text = inp.field_name + "：";

              for (const value of res.result_value) {
                if (first) {
                  text = text + value.name;
                } else {
                  text = text + "，" + value.name;
                }
                first = false;
              }
            }
            if (result !== "") {
              result = result + DELIMITER + text;
            } else {
              result = text;
            }
          }
          //8:スコア計算
          if (res.format_class === 8) {
            const unit = inp.item_json.unit;
            let text =
              inp.field_name +
              "：" +
              this.calcTotalScore(this.getPatEventResultParams) +
              unit;
            if (result !== "") {
              result = result + DELIMITER + text;
            } else {
              result = text;
            }
          }
          //9.治療実績リンク
          //10:掲示板リンク
        }
      }
      return result;
    },
    getText(inp, res, result) {
      let text = inp.field_name + "：設定なし";
      if (res.result_value !== undefined) {
        text = inp.field_name + "：" + res.result_value;
      }
      if (result !== "") {
        result = result + DELIMITER + text;
      } else {
        result = text;
      }
      return result;
    },
    getListRaidoText(inp, res, result) {
      let text = inp.field_name + "：設定なし";
      if (res.result_value.name !== undefined) {
        text = inp.field_name + "：" + res.result_value.name;
      }
      if (result !== "") {
        result = result + DELIMITER + text;
      } else {
        result = text;
      }
      return result;
    },
    calcTotalScore(res) {
      let arScore = [];
      for (const item of res) {
        let value = 0;
        if (item.format_class === 8) {
          // スコア計算項目の結果合計
          value = item.result_value.score;
          arScore.push(value);
        }
      }
      if (arScore.length > 0) {
        let total = 0;
        for (const score of arScore) {
          /*mod FNSI-改修内容NAN修正 任 start*/
          /*total += Number(score);*/
          total += Number(score === undefined ? 0 : score);
          /*mod FNSI-改修内容NAN修正 任 end*/
        }
        return total;
      } else {
        return null;
      }
    },
    /**
     * @description レコード削除
     */
    async deleteRecord() {
      await this.setSelectedBbsInfo(this.getPatEventRecord.bbsCtlNo);
      // 削除
      await deleteBbs(this.selectedBbs.bbs_ctl_no);

      this.clearBbsStore();
      return true;
    },
    /**
     * @description DB保存
     */
    async updateRecord() {
      if (this.getPatEventRecord.bbsCtlNo === 0) {
        return false;
      }
      /*add FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 start*/
      for (let i = 0; i < this.getPatEventRecord.bbsCtlNoList.length; i++) {
        /*add FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 end*/
        await this.setSelectedBbsInfo(this.getPatEventRecord.bbsCtlNoList[i]);
        const bbsRec = deepCopy(this.selectedBbs);
        // ファイル情報設定
        let fileInfo = [];
        const eventRes = this.getPatEventResultParams;
        for (const iterator of eventRes) {
          if (iterator.format_class === 7) {
            for (const iterator1 of iterator.result_value) {
              fileInfo.push({
                name: iterator1.file_name,
                path: iterator1.file_path,
              });
            }
          }
        }
        bbsRec.file_info = fileInfo;
        const serializedRecord = serializeJsonColumn(bbsRec, this.jsonColumns);
        await updateBbsFileInfo(serializedRecord);
        /*add FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 start*/
      }
      /*add FNSI-改修内容一括で複数イベントを登録された時、一括登録された２番目からのデータが削除できない。任 end*/
      this.clearBbsStore();
      return true;
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let dateIsValid = true;
      let sdt = null;
      let edt = null;
      //#10715:日付IF修正Start
      let startclassnm = document.getElementsByClassName("notice-start-date");
      let endclassnm = document.getElementsByClassName("notice-end-date");
      //#10715:日付IF修正End
      if (
        this.formattedSaveDate(this.inputModel.noticeStartDate) &&
        this.formattedSaveDate(this.inputModel.noticeEndDate)
      ) {
        sdt = new Date(this.formattedSaveDate(this.inputModel.noticeStartDate));
        edt = new Date(this.formattedSaveDate(this.inputModel.noticeEndDate));
        if (sdt > edt) {
          dateIsValid = false;
          //#10715:日付IF修正Start
          if (!startclassnm[0].classList.contains("custom-input-date-invalid")) startclassnm[0].classList.add("custom-input-date-invalid");
          if (!endclassnm[0].classList.contains("custom-input-date-invalid")) endclassnm[0].classList.add("custom-input-date-invalid");
          //#10715:日付IF修正End
        }
      }
      return {
        dateIsValid: dateIsValid,
      };
    },
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every((v) => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // メッセージ組み立て
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000188].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
           ${
             !validationResult.dateIsValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              //  ? "日付の大小関係が正しくありません。<br>"
               ? messageFormat(DIALOG_MESSAGES[12000188].message)
               // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
               : ""
           }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message,
      });
      return false;
    },
  },
};
</script>

<style scoped>
/*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
/*.vertical-div {
    display: flex;
    flex-direction: column;
    align-content: flex-start;
  }
  .disp-item-area {
    width: 100%;
    border-collapse: collapse;
    margin-top: 5px;
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    margin-left: 10px;
    margin-top: 10px;
  }*/
.vertical-div {
  display: flex;
  align-content: flex-start;
  border-bottom: #595959 solid 1.5px;
}
.disp-item-area {
  /*width: 100%;*/
  border-collapse: collapse;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  align-items: center;
}
.topTitle {
  /*  border-bottom: black solid;*/
  margin-left: 10px;
  height: 100%;
  /*white-space: nowrap;*/
}
/*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.disp-item-area tr {
  height: 50px;
}
.disp-item-area tr th {
  text-align: left;
}
.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}
.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}
.title {
  padding-top: 5px;
  /* del FNSI 患者イベント画面レイアウト調整 吉 start */
  /*white-space: nowrap;*/
  /* del FNSI 患者イベント画面レイアウト調整 吉 end */
}
/*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
.bottomTitle {
  padding-bottom: 5px;
  padding-top: 5px;
  /*  border-bottom: black solid;*/
}
/*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.checkbox-group > * {
  margin-right: 10px;
}

.checkbox-group > *:last-child {
  margin-right: 0;
}

.checkbox-group ons-checkbox {
  margin-right: 5px;
}
.input-select {
  /*mod FNSI-改修内容患者eventbug 任 start*/
  /*font-size: 150%;*/
  font-size: 90%;
  /*mod FNSI-改修内容患者eventbug 任 end*/
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  min-width: 5em;
}
.input {
  max-width: 9em;
  vertical-align: middle;
  font-size: 1.5em;
}
/*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
.titleRight {
  width: 75%;
  flex-direction: column;
  padding-left: 10px;
}
.borderRight {
  margin-bottom: 10px;
  /*border-right: #595959 solid 1px;*/
  /*padding-right: 10px;*/
  /*padding-left: 10px;*/
}
.changeRow {
  overflow: hidden;
  word-spacing: normal;
  word-break: break-all;
}
/*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
/*#10715:日付IF修正StartEnd */
.custom-input-date-invalid {
    color: black;
    background-color: rgba(255, 0, 0, 0.5);
  }
</style>
