<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import DeviceSetOwnerMixin from "@/components/deviceset-info/base-modules/DeviceSetOwnerMixin";
import dayjs from "@/compat/date/dayjs";
import {
  getDeviceSetInfoMst,
  getDeviceSetInfoPat,
  getDeviceSetInfoOrd,
  updateDeviceSetInfoMst,
  updateDeviceSetInfoPat,
  updateDeviceSetInfoOrd,
  mapDeviceSetInfoEditable,
  mapDeviceSetInfoOrigin,
  getMstJsonKey
} from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
import {
  DATA_SOURCE_TYPE_MST,
  DATA_SOURCE_TYPE_PAT,
  DATA_SOURCE_TYPE_ORD,
  DATA_SOURCE_TYPE_TREAT,
  DATA_SOURCE_TYPE_SENDCOND,
  DATA_SOURCE_TYPE_MST_EDIT_RECORD,
  defaultMstDeviceInfo,
  DEVICE_TYPE_UFR,
  DEVICE_TYPE_NA,
  DEVICE_TYPE_DC,
  DEVICE_TYPE_DIA,
  DEVICE_TYPE_QBQD,
  DEVICE_TYPE_IHDF,
  DEVICE_TYPE_BVUFC,
// add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
  DEVICE_TYPE_BV,
  DEVICE_TYPE_OPE,
  DEVICE_TYPE_ECUM,
  DEVICE_TYPE_WAR,
  DEVICE_TYPE_CPRO,
  DEVICE_TYPE_BP,
  DEVICE_TYPE_PRI,
  DEVICE_TYPE_DFAS,
  DEVICE_TYPE_IAP
// add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import deviceInputNumber from "@/components/deviceset-info/base-modules/DeviceSetInfoInputNumber.vue";
import deviceRadio from "@/components/deviceset-info/base-modules/DeviceSetInfoRadio.vue";
import deviceInputTime from "@/components/deviceset-info/base-modules/DeviceSetInfoInputTime.vue";
import deviceCheckbox from "@/components/deviceset-info/base-modules/DeviceSetInfoCheckbox.vue";
import deviceSelect from "@/components/deviceset-info/base-modules/DeviceSetInfoSelect.vue";
import deviceDate from "@/components/deviceset-info/base-modules/DeviceSetInfoInputDate.vue";
import messageDialog from "@/components/common/message-dialog/MessageDialog.vue";
// add FNSI-改修内容 権限関連 趙慧敏 start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// del #10359 編集権限の動作不正 dengshen end
// add FNSI-改修内容 権限関連 趙慧敏 end
// mod FNSI-連携イベントの登録適正化 楊 start
import { ApiHelper } from "@/apis/AxiosHelper";
import { createJournal } from "@/apis/journal";
// mod FNSI-連携イベントの登録適正化 楊 end
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
import { createJournalList } from "@/apis/journal";
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from "@/functions/common/MessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

// del #11004 連携イベント発生部分不正 piao end

/**
 * @description 装置設定編集画面ベースコンポーネント
 */
export default {
  components: {
    "device-input-number": deviceInputNumber,
    "device-radio": deviceRadio,
    "device-input-time": deviceInputTime,
    "device-checkbox": deviceCheckbox,
    "device-select": deviceSelect,
    "device-date": deviceDate,
    "message-dialog": messageDialog
  },

  props: {
    dataSourceType: {
      type: Number,
      required: true
    },

    facilityCd: {
      type: String,
      default: null
    },

    patId: {
      type: Number,
      default: null
    },

    ordNo: {
      type: Number,
      default: null
    },

    allDeviceInfo: {
      type: Object,
      default: null
    },

    // キャンセル・保存ボタン表示用
    showButton: {
      type: Boolean,
      default: true
    }
  },

  // del #10359 編集権限の動作不正 dengshen start
  // // add FNSI-改修内容 権限関連 趙慧敏 start
  // mixins: [ComponentGuardMixin],
  // // add FNSI-改修内容 権限関連 趙慧敏 end
  // del #10359 編集権限の動作不正 dengshen end
  // Vue3 $parent チェーン代替：祖先owner参照をmixinで提供する
  mixins: [DeviceSetOwnerMixin],

  data() {
    return {
      deviceType: null,
      deviceSetInfoRaw: null,
      // add #11166 I-HDFが保存できない zhangyue start
      deviceSetInfoMst: null,
      // add #11166 I-HDFが保存できない zhangyue end
      deviceSetInfo: null,
      isDialogVisble: false,
      isCancelDialogVisble: false,
      dialogProps: null,
      isUpdateAllPatDialogVisble: false,
      isUpdateAllPat: false,
      // del #11004 連携イベント発生部分不正 piao start
      // objModSendClass: "",
      // del #11004 連携イベント発生部分不正 piao end

      /**
       * 参照元で画面更新を行うかどうかのフラグ
       * @summary 更新を行うかどうかは参照元画面で判断
       */
      isRefresh: false,
      // add FNSI-改修内容 権限関連 趙慧敏 start
      // del #10359 編集権限の動作不正 dengshen start
      // authorityCds: [
      //   AUTHORITY_CODES.PAT_DEVSET_PEDIT,  // 患者別装置設定-代行編集
      //   AUTHORITY_CODES.PAT_DEVSET_EDIT    // 患者別装置設定-編集
      // ],
      // hasDevicesetInfoAuthority: false
      // del #10359 編集権限の動作不正 dengshen end
      // add FNSI-改修内容 権限関連 趙慧敏 end
      //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 start
      showmessage:false
      //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 end
      //add 7810 治療条件・装置設定変更時の動作不備 張 start
       ,closeType:true
      //add 7810 治療条件・装置設定変更時の動作不備 張 end
    };
  },

  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("master-maintenance", ["getEditRecord"]),
    //mod FNSI修正 装置設定バッグ改修 房 start
    ...mapGetters("treatment-record/setting", ["getRstDeviceSetInfo", "getSubParams"]),
    //mod FNSI修正 装置設定バッグ改修 房 end
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-info", ["selectedPat", "getIsOtherFacility", "getOtherFacilityCd", "selectedPatId"]),
    // mod FNSI-連携イベントの登録適正化 楊 end
    /**
     * @description 保存ボタンラベル
     * @returns {String}
     */
    saveButtonLabel() {
      return this.dataSourceType === DATA_SOURCE_TYPE_SENDCOND
        ? "確定"
        : "保存";
    },
    /**
     * @description 保存ボタンラベル
     * @returns {String}
     */
    cancelButtonLabel() {
      return this.isTreatRecord ? "閉じる" : "キャンセル";
    },

    /**
     * @description 入力必須要素
     * @summary refに'required'を含む要素のみを返す
     * @returns {Array} 要素オブジェクトの配列
     */
    requiredElements() {
      const elements = [];
      for (const refKey in this.$refs) {
        if (!refKey.includes("required")) {
          continue;
        }
        const el = this.$refs[refKey];
        if (Array.isArray(el)) {
          // v-forで回したrefは長さ1の配列
          elements.push(el[0]);
        } else {
          elements.push(el);
        }
      }
      return elements;
    },

    patA() {
      return this.deviceSetInfo.pat.A;
    },

    patB() {
      return this.deviceSetInfo.pat.B;
    },

    devA() {
      return this.deviceSetInfo?.dev?.A;
    },

    devB() {
      return this.deviceSetInfo.dev.B;
    },

    devC() {
      return this.deviceSetInfo.dev.C;
    },

    isTreatRecord() {
      return this.dataSourceType === DATA_SOURCE_TYPE_TREAT;
    },

    // add FNSI-改修内容 権限関連 趙慧敏 start
    isPatRecord() {
      return this.dataSourceType === DATA_SOURCE_TYPE_PAT;
    },
    // del #10359 編集権限の動作不正 dengshen start
    // ishasDevicesetInfoAuthority() {
    //   return this.hasDevicesetInfoAuthority;
    // },
    // del #10359 編集権限の動作不正 dengshen end
    // add FNSI-改修内容 権限関連 趙慧敏 end
    // del MC対象のため、一時コメントアウト 趙 start
    // add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 start
    // isMstRecord() {
    //   return this.dataSourceType === DATA_SOURCE_TYPE_MST;
    // },
    // add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 end
    // del MC対象のため、一時コメントアウト 趙 end
  },

  watch: {
    isDialogVisble() {
      // 共通ローダーを非表示
      // modify start #9204
      this.$nextTick(() => {
        this.setLoadingScreenVisible(false);
      })
      // modify end #9204
    },

    isCancelDialogVisble() {
      // 共通ローダーを非表示
      this.setLoadingScreenVisible(false);
    },

    isUpdateAllPatDialogVisble() {
      // 共通ローダーを非表示
      // #8061-装置設定が保存出来ない 周 del start
      //this.setLoadingScreenVisible(false);
      // #8061-装置設定が保存出来ない 周 del end
    }
  },

  async created() {
    // 表示画面に応じたデータをDBから取得する
    switch (this.dataSourceType) {
      case DATA_SOURCE_TYPE_MST:
        if (this.facilityCd === null) {
          throw new Error("施設コードが未指定です");
        }
        this.deviceSetInfoRaw = await getDeviceSetInfoMst(
          this.facilityCd,
          this.selectedPatId
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('BaseDeviceSetInfoEditor.vue', 'created', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw new Error(error);
        });

        if (this.deviceSetInfoRaw === "" || this.deviceSetInfoRaw === null) {
          // 装置設定DB値がnullの場合は定義された初期値を設定
          this.deviceSetInfoRaw = defaultMstDeviceInfo;
        }
        break;

      case DATA_SOURCE_TYPE_PAT:
        // del #10359 編集権限の動作不正 dengshen start
        // // add FNSI-改修内容 権限関連 趙慧敏 start
        // this.hasDevicesetInfoAuthority = this.getDevicesetInfoAuthority();
        // // add FNSI-改修内容 権限関連 趙慧敏 end
        // del #10359 編集権限の動作不正 dengshen end
        if (this.patId === null) {
          throw new Error("患者が未選択です");
        }
        this.deviceSetInfoRaw = await getDeviceSetInfoPat(this.patId, this.getOtherFacilityCd).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('BaseDeviceSetInfoEditor.vue', 'created', error);
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            throw new Error(error);
          }
        );

        if (this.deviceSetInfoRaw === "" || this.deviceSetInfoRaw === null) {
          // 装置設定DB値がnullの場合は定義された初期値を設定
          this.deviceSetInfoRaw = defaultMstDeviceInfo.pat;
        }
        break;

      case DATA_SOURCE_TYPE_ORD:
      // mod #11166 I-HDFが保存できない zhangyue start
        if (this.ordNo === null) {
          throw new Error("指示が未選択です");
        }
        // this.deviceSetInfoRaw = await getDeviceSetInfoOrd(this.ordNo).catch(
        //   error => {
        //     //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        //     getErrorMessage('BaseDeviceSetInfoEditor.vue', 'created', error);
        //     //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        //     throw new Error(error);
        //   }
        // );
        const patId = this.selectedPat.pat_personal_main.pat_id
        if (patId === null) {
          throw new Error("患者が未選択です");
        }
        // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
        let ordNo = this.ordNo;
        const structData = this._deviceSetRootOwner()?.structData || this._deviceSetDialogOwner()?.structData;
        if (structData) {
          const indWeeks = [
              {
              text: "全",
              done: true,
              value: 0
            },
            {
              text: "月",
              done: true,
              value: 1
            },
            {
              text: "火",
              done: true,
              value: 2
            },
            {
              text: "水",
              done: true,
              value: 3
            },
            {
              text: "木",
              done: true,
              value: 4
            },
            {
              text: "金",
              done: true,
              value: 5
            },
            {
              text: "土",
              done: true,
              value: 6
            },
            {
              text: "日",
              done: true,
              value: 7
            }
          ];
          const paramJson = {};
          // 施設情報
          paramJson.facility_cd = structData.facilityCd;
          // 患者情報
          paramJson.pat_id = structData.patId;
          // 治療開始日時
          paramJson.start_date = structData.indStartDate;
          // 治療終了日時
          paramJson.end_date = "";
          // クール
          paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
          // 治療方法
          paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
          // 曜日パターン
          paramJson.weeks = JSON.stringify(indWeeks);
          const response = await ApiHelper.post(
            "/mainData/getOrdMainDataInfo",
            paramJson
          );
          ordNo = response.data[0]?.ordNo ?? this.ordNo;
        }
        // const [resOrd, resPat, resMst] = await Promise.all([getDeviceSetInfoOrd(this.ordNo), getDeviceSetInfoPat(patId), getDeviceSetInfoMst(this.getFacilityCd)])
        const [resOrd, resPat, resMst] = await Promise.all([getDeviceSetInfoOrd(ordNo, this.selectedPatId), getDeviceSetInfoPat(patId, this.getOtherFacilityCd), getDeviceSetInfoMst(this.getFacilityCd, this.selectedPatId)])
        // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
        const deviceSetInfoRawTemp = JSON.parse(JSON.stringify({...resOrd, ...resPat}));
        deviceSetInfoRawTemp.ihdf.dev.A[1001] = resMst?.ord?.ihdf?.dev?.A[1001];
        deviceSetInfoRawTemp.ihdf.dev.A[1002] = resMst?.ord?.ihdf?.dev?.A[1002];
        this.deviceSetInfoRaw = deviceSetInfoRawTemp
        // mod #11166 I-HDFが保存できない zhangyue end
        break;

      case DATA_SOURCE_TYPE_TREAT:
        //mod FNSI修正 装置設定バッグ改修 房 start
        // this.deviceSetInfoRaw = this.getRstDeviceSetInfo;
        this.deviceSetInfoRaw = this.getSubParams;
        //mod FNSI修正 装置設定バッグ改修 房 end
        break;
      case DATA_SOURCE_TYPE_SENDCOND:
        this.deviceSetInfoRaw = this.allDeviceInfo;
        break;
      case DATA_SOURCE_TYPE_MST_EDIT_RECORD:
      // mod #11166 I-HDFが保存できない zhangyue start
        if (this.getEditRecord.indDeviceSetInfo) {
                  this.deviceSetInfoRaw = JSON.parse(
            this.getEditRecord.indDeviceSetInfo
          )
            ? JSON.parse(this.getEditRecord.indDeviceSetInfo)
            : this.getEditRecord.indDeviceSetInfo;
             if (this.facilityCd === null) {
              throw new Error("施設コードが未指定です");
            }
            this.deviceSetInfoMst = await getDeviceSetInfoMst(
              this.facilityCd,
              this.selectedPatId
            ).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
              getErrorMessage('BaseDeviceSetInfoEditor.vue', 'created', error);
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
              throw new Error(error);
            });
        }
        if (!this.deviceSetInfoRaw) {
          // 装置設定値がnullの場合は定義された初期値を設定
          this.deviceSetInfoRaw = defaultMstDeviceInfo.ord;
        }
      // mod #11166 I-HDFが保存できない zhangyue end
        break;
      default:
        throw new Error("データ取得元の指定が不正です");
    }

    // 編集用オブジェクト作成
    if (this.dataSourceType === DATA_SOURCE_TYPE_MST) {
      // マスタは1階層余分なキー(ord/pat)があるのでそのキーに対応する値を変換
      const mstKey = getMstJsonKey(this.deviceType);
      this.deviceSetInfo = mapDeviceSetInfoEditable(
        this.deviceSetInfoRaw[mstKey],
        this.deviceType
      );
    } else {
      this.deviceSetInfo = mapDeviceSetInfoEditable(
        this.deviceSetInfoRaw,
        this.deviceType
      );
      //mod FNSI-5993 劉全航 start
      if(this.dataSourceType === DATA_SOURCE_TYPE_ORD){
        let deviceInfo = await getDeviceSetInfoPat(this.selectedPat.pat_main.pat_id, this.getOtherFacilityCd).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('BaseDeviceSetInfoEditor.vue', 'created', error);
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            throw new Error(error);
          }
        );
        let deviceSetInfo = mapDeviceSetInfoEditable(
          this.deviceSetInfoRaw,
          this.deviceType
        );
        for(let i = 400; i < 409; i ++){
          if(deviceSetInfo.dev.A[i]){
             deviceSetInfo.dev.A[i].maxValue = deviceInfo.ope.dev.A[179];
          }
        }
        this.deviceSetInfo = deviceSetInfo;
      }
      //mod FNSI-5993 劉全航 end
      //mod FNSI-5993 gaoey str
      if(this.dataSourceType === DATA_SOURCE_TYPE_PAT){
        let deviceInfo = await getDeviceSetInfoPat(this.selectedPat.pat_main.pat_id, this.getOtherFacilityCd).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('BaseDeviceSetInfoEditor.vue', 'created', error);
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            throw new Error(error);
          }
        );
        let deviceSetInfo = mapDeviceSetInfoEditable(
          this.deviceSetInfoRaw,
          this.deviceType
        );
        // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
        if(deviceSetInfo && deviceSetInfo.pat && deviceSetInfo.pat.B && deviceSetInfo.pat.B.length > 0) {
        // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
          deviceSetInfo.pat.B[5].maxValue = deviceInfo.ope.dev.A[179];
          deviceSetInfo.pat.B[59].maxValue = deviceInfo.ope.dev.A[179];
          deviceSetInfo.dev.A[333].maxValue = deviceInfo.ope.dev.A[179];
          deviceSetInfo.dev.A[373].maxValue = deviceInfo.ope.dev.A[179];
        }
        this.deviceSetInfo = deviceSetInfo;
      }
      //mod FNSI-5993 gaoey end
    }
  },

  methods: {
    /**
     * 装置設定保存時の注意メッセージ（左寄せ HTML）。messageFormat はタグをエスケープするため当画面専用。
     */
    buildDeviceSetAlertMessageHtml(messageCd) {
      const raw = (DIALOG_MESSAGES[messageCd]?.message || "").replace(/\{\$\d*\}/g, "");
      return `<div style="text-align:left;">${raw}</div>`;
    },
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    ...mapActions("device-set-info-modal", ["setSelectedDeviceSetInfoState"]),
    // del #11004 連携イベント発生部分不正 piao start
    // /**
    //  * @description MODIFY_SEND_CLASS取得
    //  */
    // async getSchModifySendClass() {
    //   let retVal = 0;
    //   const prmfacilityCd = this.getFacilityCd;
    //   this.objModSendClass = sendRequestGetCoopIniSchModifySendClass(prmfacilityCd);
    //
    //   try {
    //     const response = await this.objModSendClass;
    //     retVal = response.data;
    //   } catch (error) {
    //     retVal = 0;
    //   }
    //   return retVal;
    // },
    // del #11004 連携イベント発生部分不正 piao end
    /**
     * @description 保存ボタン処理
     */
    // mod #8052 装置設定デフォルトマスタでプログラムの制限が出来ていない gaoey start
    async save(indEditBaseData = null) {
      console.log("BaseDeviceSetInfoEditor.vue save this.startLoadingScreen();");
      this.startLoadingScreen();
      /* add by chamaojia 2023-11-09 [9414] DeviceSetInfoSubModal.vueから移行した   --start */
      if (this.dataSourceType === DATA_SOURCE_TYPE_MST_EDIT_RECORD) {
        // add #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc start
        await this.setSelectedDeviceSetInfoState({ deviceState: null })
        // add #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc end
        if (this.deviceType === DEVICE_TYPE_UFR) {
          await this.setSelectedDeviceSetInfoState({ deviceState: this.deviceSetInfo.dev.A["290"].value.editValue })
        } else if (this.deviceType === DEVICE_TYPE_NA) {
          await this.setSelectedDeviceSetInfoState({ deviceState: this.deviceSetInfo.dev.A["315"].value.editValue })
        } else if (this.deviceType === DEVICE_TYPE_DC) {
          await this.setSelectedDeviceSetInfoState({ deviceState: this.deviceSetInfo.dev.A["340"].value.editValue })
        } else if (this.deviceType === DEVICE_TYPE_QBQD) {
          await this.setSelectedDeviceSetInfoState(
              { deviceState: { 430: this.deviceSetInfo.dev.A["430"].value.editValue, 431: this.deviceSetInfo.dev.A["431"].value.editValue } }
          )
        } else if (this.deviceType === DEVICE_TYPE_BVUFC) {
          await this.setSelectedDeviceSetInfoState({ deviceState: this.deviceSetInfo.dev.A["196"].value.editValue })
        } else if (this.deviceType === DEVICE_TYPE_DIA) {
          await this.setSelectedDeviceSetInfoState({ deviceState: this.deviceSetInfo.dev.A["282"].value.editValue })
        } else if (this.deviceType === DEVICE_TYPE_IHDF) {
          await this.setSelectedDeviceSetInfoState({ deviceState: this.deviceSetInfo.dev.A["432"].value.editValue })
        }
      }
      /* add by chamaojia 2023-11-09 [9414] DeviceSetInfoSubModal.vueから移行した   --end */

    // #8061-装置設定が保存出来ない 周 add start
      this.setLoadingScreenVisible(true);
      // #8061-装置設定が保存出来ない 周 add end
      if(this.dataSourceType === DATA_SOURCE_TYPE_MST){
        switch (this.deviceType) {
          case DEVICE_TYPE_BVUFC:
            if ((this.deviceSetInfoRaw.ord.ufr.dev.A["290"] == "1" || this.deviceSetInfoRaw.ord.ufr.dev.A["290"] == "2") && this.deviceSetInfo.dev.A["196"].value.editValue == "1") {
              await this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "注意",
                // message: `<div style="text-align:left;">除水プログラムとBV-UFCは両方使用することはできません。<br> </div>`,
                title: DIALOG_MESSAGES[12000085].title,
                messageHTML: this.buildDeviceSetAlertMessageHtml(12000085),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                callback:answer => {
                  if (answer == 0) {
                    //OK
                    // モーダルを閉じる
                    this.saveAfter(indEditBaseData);
                  }
                }
              });
            }else{
              await this.saveAfter(indEditBaseData);
            }
            break;
          case DEVICE_TYPE_UFR:
            if ((this.deviceSetInfo.dev.A["290"].value.editValue  == "1" || this.deviceSetInfo.dev.A["290"].value.editValue  == "2") && this.deviceSetInfoRaw.ord.bvufc.dev.A["196"] == "1") {
              await this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "注意",
                // message: `<div style="text-align:left;">除水プログラムとBV-UFCは両方使用することはできません。<br> </div>`,
                title: DIALOG_MESSAGES[12000085].title,
                messageHTML: this.buildDeviceSetAlertMessageHtml(12000085),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                callback:answer => {
                  if (answer == 0) {
                    //OK
                    // モーダルを閉じる
                    this.saveAfter(indEditBaseData);
                  }
                }
              });
            }else{
               await this.saveAfter(indEditBaseData);
            }
            break;
          case DEVICE_TYPE_DC:
            if ((this.deviceSetInfoRaw.ord.na.dev.A["315"]  == "1" || this.deviceSetInfoRaw.ord.na.dev.A["315"]  == "2") && (this.deviceSetInfo.dev.A["340"].value.editValue  == "3" || this.deviceSetInfo.dev.A["340"].value.editValue  == "2")) {
              await this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "注意",
                // message: `<div style="text-align:left;">Naプログラムと濃度プログラムは両方使用することはできません。<br> </div>`,
                title: DIALOG_MESSAGES[12000086].title,
                messageHTML: this.buildDeviceSetAlertMessageHtml(12000086),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                callback:answer => {
                  if (answer == 0) {
                    //OK
                    // モーダルを閉じる
                    this.saveAfter(indEditBaseData);
                  }
                }
              });
            }else{
              await this.saveAfter(indEditBaseData);
            }
            break;
          case DEVICE_TYPE_NA:
            if ((this.deviceSetInfoRaw.ord.dc.dev.A["340"]  == "3" || this.deviceSetInfoRaw.ord.dc.dev.A["340"]  == "2") && (this.deviceSetInfo.dev.A["315"].value.editValue  == "1" || this.deviceSetInfo.dev.A["315"].value.editValue  == "2")) {
              await this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "注意",
                // message: `<div style="text-align:left;">Naプログラムと濃度プログラムは両方使用することはできません。<br> </div>`,
                title: DIALOG_MESSAGES[12000086].title,
                messageHTML: this.buildDeviceSetAlertMessageHtml(12000086),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                callback:answer => {
                  if (answer == 0) {
                    //OK
                    // モーダルを閉じる
                    this.saveAfter(indEditBaseData);
                  }
                }
              });
            }else{
              await this.saveAfter(indEditBaseData);
            }
            break;
          default:
            await this.saveAfter(indEditBaseData);
            break;
        }
      }else{
        await this.saveAfter(indEditBaseData);
      }
      // #8061-装置設定が保存出来ない 周 add start
      this.setLoadingScreenVisible(false);
      // #8061-装置設定が保存出来ない 周 add end
      console.log("BaseDeviceSetInfoEditor.vue save this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },
    async saveAfter(indEditBaseData){
      console.log("BaseDeviceSetInfoEditor.vue saveAfter this.startLoadingScreen();");
      this.startLoadingScreen();
      if (await this.updateDeviceSetInfo(indEditBaseData)) {
        if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
          this.isRefresh = true;
        }
        // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
        if (this.dataSourceType === DATA_SOURCE_TYPE_PAT) {
          await this.callCreateJournal();
        }
        // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
      // mod 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
      //  this.closeModal();
      if (this.closeType) {
         if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
          this.isRefresh = true;
        }
        this.closeModal();
      }
      // mod 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 end
      }
      console.log("BaseDeviceSetInfoEditor.vue saveAfter this.finishLoadingScreen();");

      //add #10266 start
      this.settingIndData.update_flag = null;
      //add #10266 end

      this.finishLoadingScreen();
    },

    // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
    async callCreateJournal() {
      let treatDate = dayjs(new Date()).format("YYYYMMDD");
      let opeCd = "";
      let w_crud = "";
      // del #10553 ④装置設定 #10429非関連イベント 処理取消 piao start
      // let modSendClass = await this.getSchModifySendClass();
      // del #10553 ④装置設定 #10429非関連イベント 処理取消 piao end
      switch (this.deviceType) {
        case DEVICE_TYPE_OPE:
          opeCd = "010003";
          break;
        case DEVICE_TYPE_ECUM:
          opeCd = "010004";
          break;
        case DEVICE_TYPE_WAR:
          opeCd = "010005";
          break;
        case DEVICE_TYPE_CPRO:
          opeCd = "010006";
          break;
        case DEVICE_TYPE_BP:
          opeCd = "010007";
          break;
        case DEVICE_TYPE_BV:
          opeCd = "010008";
          break;
        case DEVICE_TYPE_PRI:
          opeCd = "010009";
          break;
        case DEVICE_TYPE_DFAS:
          opeCd = "010010";
          break;
        case DEVICE_TYPE_IAP:
          opeCd = "010011";
          break;
        default: break;
      }
      if (opeCd === "") {
        return;
      }
      // del #10553 ④装置設定 #10429非関連イベント 処理取消 piao start
      // if (modSendClass == 2) {
      //   const delparams = {
      //     ope_cd: opeCd,
      //     crud: "D",
      //     facility_cd: this.facilityCd,
      //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //     pat_id: this.selectedPat.pat_personal_main.pat_id,
      //     ord_no: "",
      //     base_date: treatDate,
      //     user_id: this.getStateUserAccountInfo.userId
      //   };
      //   createJournal(delparams);
      // }
      // del #10553 ④装置設定 #10429非関連イベント 処理取消 piao end
      w_crud = "U";
      // del #10553 ④装置設定 #10429非関連イベント 処理取消 piao start
      // if (modSendClass == 2) {
      //   w_crud = "C";
      // }
      // del #10553 ④装置設定 #10429非関連イベント 処理取消 piao end
      const params = {
        ope_cd: opeCd,
        crud: w_crud,
        facility_cd: this.facilityCd,
        hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
        pat_id: this.selectedPat.pat_personal_main.pat_id,
        ord_no: "",
        base_date: treatDate,
        user_id: this.getStateUserAccountInfo.userId
      };
      createJournal(params);
    },
    // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end


    /**
     * @description 保存ボタン処理(指示画面個別更新)
     */
    async ordMainAllSave(indEditBaseData = null) {
      console.log("BaseDeviceSetInfoEditor.vue ordMainAllSave this.startLoadingScreen();");
      this.startLoadingScreen();
      // 編集がされていなければ、警告メッセージを表示し以降の処理を行わない
      // BV-UFCの変更チェックはisEditedとisBVEditedを見る必要がある。BV-UFC以外はisEditedのみを見る
      // BV-UFCの場合、isBVEdited: 固定倍率除水終了条件.ΔBVの変更有無を保持、isEdited: 固定倍率除水終了条件.ΔBV以外の変更有無を保持
      if (!(this.isEdited() || (this.deviceType === DEVICE_TYPE_BVUFC && this.isBVEdited))) {
        this.showNoEditing();
        console.log("BaseDeviceSetInfoEditor.vue ordMainAllSave return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      //mod 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 start
      await this.updateDeviceSetInfo(indEditBaseData)
      // if (await this.updateDeviceSetInfo(indEditBaseData)) {
        // if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
          // this.isRefresh = true;
        // }
        // this.closeModal();
      // }
       //mod 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 end
      //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
      // if (this.closeType) {
      //    if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
      //     this.isRefresh = true;
      //   }
      //   this.closeModal();
      // }
      //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 end
      console.log("BaseDeviceSetInfoEditor.vue ordMainAllSave this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    /**
     * @description 装置設定値更新
     * @returns {Boolean} 成功:true, 失敗:false
     */
    async updateDeviceSetInfo(indEditBaseData = null) {
      console.log("BaseDeviceSetInfoEditor.vue updateDeviceSetInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 未入力項目チェック
      const emptyFormName = this.checkAllRequired();
      if (emptyFormName !== "") {
        // 未入力項目あり
        this.showDialog({ messageCd: 22010001, stringParams: [emptyFormName] });
        console.log("BaseDeviceSetInfoEditor.vue updateDeviceSetInfo return false; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return false;
      }

      // バリデーション
      const validationResult = this.validateBeforeUpdating();
      if (validationResult !== null) {
        // バリデーション失敗
        this.showDialog(validationResult);
        console.log("BaseDeviceSetInfoEditor.vue updateDeviceSetInfo return false; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return false;
      }

      // 装置設定値を原型に戻し更新用オブジェクトを作成する
      const devInfoOrigin = mapDeviceSetInfoOrigin(
        this.deviceSetInfo,
        this.deviceType
      );

      let devInfoUpdate, devInfoUpdatePat;
      if (this.dataSourceType === DATA_SOURCE_TYPE_MST) {
        // マスタの場合は1階層余分なキー(ord/pat)を付与
        const mstKey = getMstJsonKey(this.deviceType);
        // { ord/pat: { 装置種類: { 番号: 値, ... } } }
        devInfoUpdate = {
          [mstKey]: {
            [this.deviceType]: devInfoOrigin
          }
        };
        if (this.isUpdateAllPat) {
          const devInfoOriginEdited = mapDeviceSetInfoOrigin(
            this.deviceSetInfo,
            this.deviceType,
            this.isUpdateAllPat
          );
          devInfoUpdatePat = {
            [mstKey]: {
              [this.deviceType]: devInfoOriginEdited
            }
          };
        }
      } else {
        // { 装置種類: { 番号: 値, ... } } }
        devInfoUpdate = {
          [this.deviceType]: devInfoOrigin
        };
      }
      switch (this.dataSourceType) {
        case DATA_SOURCE_TYPE_MST:
          await updateDeviceSetInfoMst(devInfoUpdate, this.facilityCd).catch(
            error => {
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
              getErrorMessage('BaseDeviceSetInfoEditor.vue', 'updateDeviceSetInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
              console.log("BaseDeviceSetInfoEditor.vue updateDeviceSetInfo throw new Error(error); this.finishLoadingScreen();");
              this.finishLoadingScreen();
              throw new Error(error);
            }
          );
          if (this.isUpdateAllPat) {
            // 全患者装置設定更新
            await updateDeviceSetInfoPat(
              devInfoUpdatePat.pat,
              null,
              this.facilityCd
            ).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
              getErrorMessage('BaseDeviceSetInfoEditor.vue', 'updateDeviceSetInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
              console.log("BaseDeviceSetInfoEditor.vue updateDeviceSetInfo throw new Error(error); this.finishLoadingScreen();");
              this.finishLoadingScreen();
              throw new Error(error);
            });
          }
          break;

        case DATA_SOURCE_TYPE_PAT:
          // mod FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
          //await updateDeviceSetInfoPat(devInfoUpdate, this.patId).catch(
          // #8061-装置設定が保存出来ない 周 mod start
          //const response = await updateDeviceSetInfoPat(devInfoUpdate, this.patId).catch(
          // mod #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou start
          // const response = await updateDeviceSetInfoPat(devInfoUpdate, this.patId, this.facilityCd).catch(
          const devInfoEdited = mapDeviceSetInfoOrigin(
            this.deviceSetInfo,
            this.deviceType,
            true
          );
          let nextPatInfoType = "";
          if ((this.deviceType == "pri" && !!devInfoEdited.pat)
          || (this.deviceType == "dfas" && !!devInfoEdited.pat && !!devInfoEdited.pat.B)){
            nextPatInfoType = "新通信";
          }
          const response = await updateDeviceSetInfoPat(devInfoUpdate, this.patId, this.facilityCd, nextPatInfoType).catch(
          // add #7188 2023/01/14 治療条件，装置設定を変更すると次患者が再送される dou end
          // #8061-装置設定が保存出来ない 周 mod end
          // mod FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end
            error => {
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
              getErrorMessage('BaseDeviceSetInfoEditor.vue', 'updateDeviceSetInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
              console.log("BaseDeviceSetInfoEditor.vue updateDeviceSetInfo throw new Error(error); this.finishLoadingScreen();");
              this.finishLoadingScreen();
              throw new Error(error);
            }
          );
          // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
          if (200 === response.status && 0 !== response.data.length) {
              // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue start
              // response.data.forEach(element => {
              for(let element of response.data) {
              // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue end
              if(element === 'liquidCalPriority') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "補液比率の見直し",
                  // message: "補液比率が変更になりました。<br>登録している治療予定の補液速度と補液量を確認して下さい。",
                  // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 張玲 start
                  // title: DIALOG_MESSAGES[12000087].title,
                  // message: messageFormat(DIALOG_MESSAGES[12000087].message),
                  title: DIALOG_MESSAGES[12000342].title,
                  message: messageFormat(DIALOG_MESSAGES[12000342].message),
                  // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 張玲 end
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }

              if(element === 'replenisherSpeed') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "補液速度の見直し",
                  // message: "補液速度の上限が変更になりました。<br>登録している治療予定の補液速度を確認し、上限を超えている場合、再登録して下さい。",
                  title: DIALOG_MESSAGES[12000088].title,
                  message: messageFormat(DIALOG_MESSAGES[12000088].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }

              if(element === 'replenisherAFBF') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "TMP監視モード",
                  // message: "AFBF予定が存在する場合、TMP監視モード変更自動追従にルは使用出来ません。",
                  title: DIALOG_MESSAGES[12000089].title,
                  message: messageFormat(DIALOG_MESSAGES[12000089].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }
              if(element === 'replenisherSingleNeedleBV') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "BV計",
                  // message: "BVを使用できない治療が変更対象に含まれています。対象はBVを使用できない為、「使用しない」が設定されます。但し設定内容詳細は保持されます。",
                  title: DIALOG_MESSAGES[12000090].title,
                  message: messageFormat(DIALOG_MESSAGES[12000090].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }
              if(element === 'replenisherSingleNeedleCycle') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "アクセス再循環率",
                  // message: "アクセス再循環率を使用できない治療が変更対象に含まれています。対象はアクセス再循環率を使用できない為、「使用しない」が設定されます。但し設定内容詳細は保持されます。",
                  title: DIALOG_MESSAGES[12000091].title,
                  message: messageFormat(DIALOG_MESSAGES[12000091].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }
              if(element === 'liquidCalPriorityChange') {
                // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue start
                if (response.data.includes('liquidCalPriority')) {
                  break;
                } else {
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                    // mod 8490 【デグレ】注意メッセージが不正 関 start
                    // title: "補液計算優先項目",
                    // message: "OHDF・OHFの予定がある場合は補液指示更新を促す。",
                    // title: "補液計算優先項目の見直し",
                    // message: "補液計算優先項目が変更になりました。<br>登録している治療予定の補液速度と補液量を確認してください。",
                    // mod 8490 【デグレ】注意メッセージが不正 関 end
                    // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 張玲 start
                    // title: DIALOG_MESSAGES[12000335].title,
                    // message: messageFormat(DIALOG_MESSAGES[12000335].message),
                    title:DIALOG_MESSAGES[12000342].title,
                    message: messageFormat(DIALOG_MESSAGES[12000342].message),
                    // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 張玲 end
                    // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                    callback: answer => {
                      if (answer == 0) {
                        //OK
                        // モーダルを閉じる
                        this.hideModal();
                      }
                    }
                  });
                }
                // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue end
              }
              if(element === 'auxiliaryLiquid') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "補液量設定",
                  // message: "補液量の上限が変更になりました。<br>登録しているOHDF・OHFの治療予定の補液量を確認し、上限を超えている場合、再登録して下さい。",
                  title: DIALOG_MESSAGES[12000093].title,
                  message: messageFormat(DIALOG_MESSAGES[12000093].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }
              if(element === 'bloodFlow') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "血流量の上限",
                  // message: "血流量の上限が変更になりました。<br>登録している治療予定の血流量を確認し、上限を超えている場合、再登録して下さい。",
                  title: DIALOG_MESSAGES[12000094].title,
                  message: messageFormat(DIALOG_MESSAGES[12000094].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }
              if(element === 'dialysisFluidTemperature') {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "透析液温度の上限，下限",
                  // message: "透析液温度の上限，下限が変更になりました。<br>登録している治療予定の透析液温度を確認し、上限，下限を超えている場合、再登録して下さい。",
                  title: DIALOG_MESSAGES[12000095].title,
                  message: messageFormat(DIALOG_MESSAGES[12000095].message),
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
              }
            // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue start
            // });
            }
            // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue end
           // add 補液速度操作範囲上限を超えて設定できる 6002  関 start
          } else {
            //add 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 start
            let isEdited = false
            //add 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 end
            for (const refKey in this.$refs) {
              if ((
                // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue start
                // refKey.includes("required11") ||
                (refKey.includes("required12") && this.deviceType !== DEVICE_TYPE_PRI) ||
                (refKey.includes("required13") && this.deviceType !== DEVICE_TYPE_PRI) ||
                (refKey.includes("required14") && this.deviceType !== DEVICE_TYPE_PRI) ||
                (refKey.includes("required15") && this.deviceType !== DEVICE_TYPE_PRI) ||
                (refKey.includes("required16") && this.deviceType !== DEVICE_TYPE_PRI) ||
                (refKey.includes("required17") && this.deviceType !== DEVICE_TYPE_PRI) ||
                /* mod #8709 by zhangruixue 2023-05-29 --start */
                (refKey.includes("radio4") && refKey !== "radio470" && refKey !== "radio471" && this.deviceType !== DEVICE_TYPE_DFAS && this.deviceType !== DEVICE_TYPE_PRI) ||
                (refKey.includes("required19") && this.deviceType !== DEVICE_TYPE_PRI) ||
                (refKey.includes("radio5") && this.deviceType !== DEVICE_TYPE_DFAS)

              )
                /* mod #8709 by zhangruixue 2023-05-29 --end */
                // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 zhangyue end
                && this.$refs[refKey].isEdited === true) {
                 //add 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 start
                  isEdited = true;
                  break;
                 //add 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 end
                 //del 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 start
                // del #7866-通信設定>静的静脈圧の設定を変更すると補液設定の見直しの注意喚起メッセージが表示される 徐博 start
                // this.$ons.notification.alert({
                //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                //   // title: "補液設定の見直し",
                //   // message: "補液設定が変更になりました。<br>登録している治療予定の補液速度と補液量を確認し、上限を超えている場合、再登録して下さい。",
                //   title: DIALOG_MESSAGES[12000096].title,
                //   message: messageFormat(DIALOG_MESSAGES[12000096].message),
                //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                //   callback: answer => {
                //     if (answer == 0) {
                //       //OK
                //       // モーダルを閉じる
                //       this.hideModal();
                //     }
                //   }
                // });
                // del #7866-通信設定>静的静脈圧の設定を変更すると補液設定の見直しの注意喚起メッセージが表示される 徐博 end
                //del 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 end
              }
              // mod FNSI7658-装置設定>プライミングにて動脈充填の流量を変更すると血流量の見直しの注意喚起メッセージが表示される 周 start
              // if (refKey === "required1" && this.$refs[refKey].isEdited === true) {
              // if (DEVICE_TYPE_OPE === this.deviceType && refKey === "required1" && this.$refs[refKey].isEdited === true) {
              // // mod FNSI7658-装置設定>プライミングにて動脈充填の流量を変更すると血流量の見直しの注意喚起メッセージが表示される 周 end
              //   this.$ons.notification.alert({
              //     title: "血流量の見直し",
              //     message: "血流量の上限が変更になりました。<br>登録している治療予定の血流量を確認し、上限を超えている場合、再登録して下さい。",
              //     callback: answer => {
              //       if (answer == 0) {
              //         //OK
              //         // モーダルを閉じる
              //         this.hideModal();
              //       }
              //     }
              //   });
              // }
              // add 補液速度操作範囲上限を超えて設定できる 6002  関 end
            }
            //add 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 start
            if(isEdited){
              this.$ons.notification.alert({
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  // title: "補液設定の見直し",
                  // message: "補液設定が変更になりました。<br>登録している治療予定の補液速度と補液量を確認し、上限を超えている場合、再登録して下さい。",
                  // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 張玲 start
                  //title: DIALOG_MESSAGES[12000096].title,
                  //message: messageFormat(DIALOG_MESSAGES[12000096].message),
                  title: DIALOG_MESSAGES[12000342].title,
                  message: messageFormat(DIALOG_MESSAGES[12000342].message),
                  // mod #10951 装置設定を変更時の注意喚起メッセージ動作不良 張玲 end
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                  callback: answer => {
                    if (answer == 0) {
                      //OK
                      // モーダルを閉じる
                      this.hideModal();
                    }
                  }
                });
            }
            //add 10864 装置設定を編集して保存後に表示される注意喚起メッセージのOKを編集箇所の数だけ押下する必要がある 張玲 end
            // mod bug 7810 修正 chen end
          }
          // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end
          break;

        case DATA_SOURCE_TYPE_ORD:
          await this.updateOrdMain(indEditBaseData);
          break;

        case DATA_SOURCE_TYPE_SENDCOND: {
          // 元の装置設定値を編集値で書き換える
          const mergedDevInfo = {
            ...this.deviceSetInfoRaw,
            ...devInfoUpdate
          };
          this.$emit("update:allDeviceInfo", mergedDevInfo);
          break;
        }
        case DATA_SOURCE_TYPE_MST_EDIT_RECORD: {
          // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ start
          if (this.deviceType === DEVICE_TYPE_NA || this.deviceType === DEVICE_TYPE_DC) {
            // Na注入プログラムと透析液プログラムが両方使用する設定にできないようにする。
            // 一方がONの状態でもう一方をOFF→ONするときに、既にONになっているものをを強制的にOFFにする確認メッセージを表示。
            let message = ""
            if (this.deviceType === DEVICE_TYPE_NA) {
              if (this.devA[315].value.editValue !== "0") {
                if (
                  this.devA[315].value.editValue !== "0" &&
                  this.deviceSetInfoRaw[DEVICE_TYPE_DC] &&
                  this.deviceSetInfoRaw[DEVICE_TYPE_DC].dev.A[340] &&
                  "0" !== this.deviceSetInfoRaw[DEVICE_TYPE_DC].dev.A[340]
                ) {
                  // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc start
                  // this.deviceSetInfoRaw[DEVICE_TYPE_DC].dev.A[340] = "0"
                  // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc end
                  message = this.messageInfo(12000054)
                }
              }
            } else if (this.deviceType === DEVICE_TYPE_DC) {
                if (
                  this.devA[340].value.editValue !== "0" &&
                  this.deviceSetInfoRaw[DEVICE_TYPE_NA] &&
                  this.deviceSetInfoRaw[DEVICE_TYPE_NA].dev.A[315] &&
                  "0" !== this.deviceSetInfoRaw[DEVICE_TYPE_NA].dev.A[315]
                ) {
                  // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc start
                  // this.deviceSetInfoRaw[DEVICE_TYPE_NA].dev.A[315] = "0"
                  // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240613 ztc end
                  message = this.messageInfo(12000053)
                }
            }

            if (message.length > 0) {
              await this.$ons.notification.alert({
                // add 7809 表示されるメッセージにタイトルがない。 張start
                // title: "",
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "注意",
                title: DIALOG_MESSAGES[12000053].title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
               // add 7809 表示されるメッセージにタイトルがない。張 end
                message: message

              })
            }
          }
          // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ end
          // add #11166 I-HDFが保存できない zhangyue start
          if (this.deviceSetInfoRaw?.ihdf?.dev?.A[1001]) {
            delete this.deviceSetInfoRaw['ihdf']['dev']['A'][1001];
          }
          if (this.deviceSetInfoRaw?.ihdf?.dev?.A[1002]) {
            delete this.deviceSetInfoRaw['ihdf']['dev']['A'][1002];
          }
          if (devInfoUpdate?.ihdf?.dev?.A[1001]) {
            delete devInfoUpdate['ihdf']['dev']['A'][1001];
          }
          if (devInfoUpdate?.ihdf?.dev?.A[1002]) {
            delete devInfoUpdate['ihdf']['dev']['A'][1002];
          }
          let indDeviceSetInfoTemp = JSON.parse(this.getEditRecord?.indDeviceSetInfo)
          if (indDeviceSetInfoTemp?.ihdf?.dev?.A[1001]) {
            delete indDeviceSetInfoTemp?.ihdf?.dev?.A[1001];
          }
          if (indDeviceSetInfoTemp?.ihdf?.dev?.A[1002]) {
            delete indDeviceSetInfoTemp?.ihdf?.dev?.A[1002];
          }
          this.getEditRecord.indDeviceSetInfo = JSON.stringify(indDeviceSetInfoTemp);
          // add #11166 I-HDFが保存できない zhangyue end
          const indDeviceSetInfo = JSON.stringify({
            ...this.deviceSetInfoRaw,
            ...devInfoUpdate
          });
          this.setEditRecord({ ...this.getEditRecord, indDeviceSetInfo });
          break;
        }
      }

      console.log("BaseDeviceSetInfoEditor.vue updateDeviceSetInfo return true; this.finishLoadingScreen();");
      this.finishLoadingScreen();
      return true;
    },

    /**
     * 治療情報更新
     * @param structData IndEditBaseの情報
     */
    async updateOrdMain(structData) {
      console.log("BaseDeviceSetInfoEditor.vue updateOrdMain this.startLoadingScreen();");
      this.startLoadingScreen();
      // 更新情報格納用
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = structData.patId;
      // 施設コード
      sendJson.facility_cd = structData.facilityCd;
      // 治療開始日
      sendJson.start_date = dayjs(
        structData.indStartDate,
        "YYYY-MM-DD"
      ).format("YYYYMMDD");
      // 治療終了日
      sendJson.end_date = dayjs(structData.indEndDate, "YYYY-MM-DD").format(
        "YYYYMMDD"
      );
      // 編集対象曜日
      sendJson.weeks = JSON.stringify(structData.indWeeks);
      // 編集対象治療方法
      sendJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 編集対象クール
      sendJson.ind_kur_cd = JSON.stringify(structData.selectedKur);

      //add #10266  start
      sendJson.update_flag = this.settingIndData.update_flag;
      //add #10266  end

      // QBQD更新内容
      const devInfoOrigin = mapDeviceSetInfoOrigin(
        this.deviceSetInfo,
        this.deviceType
      );

      // 指示者IDを追加
      devInfoOrigin.ind_user_id = structData.indUser;
      // 更新者IDを追加
      devInfoOrigin.upd_user_id = structData.updUser;

      const devInfoUpdate = {
        [this.deviceType]: devInfoOrigin
      };
      //del FNSI-7129 劉全航 start
      // add FNSI-FutreNetWeb+SI課題管理No.4642 李 start
      // if (devInfoUpdate && devInfoUpdate['ihdf']
      //   && devInfoUpdate['ihdf']['dev']
      //   && devInfoUpdate['ihdf']['dev']['A']
      //   && devInfoUpdate['ihdf']['dev']['A'][201]) {
      //   devInfoUpdate['ihdf']['dev']['A'][201] = devInfoUpdate['ihdf']['dev']['A'][201] * 60 / 1000;
      // }
      // add FNSI-FutreNetWeb+SI課題管理No.4642 李 end
      //del FNSI-7129 劉全航 end
      // add #11166 I-HDFが保存できない zhangyue start
      if (this.dataSourceType !== DATA_SOURCE_TYPE_MST) {
        if (devInfoUpdate?.ihdf?.dev?.A[1001]) {
          delete devInfoUpdate['ihdf']['dev']['A'][1001]
        }
        if (devInfoUpdate?.ihdf?.dev?.A[1002]) {
          delete devInfoUpdate['ihdf']['dev']['A'][1002]
        }
      }
      // add #11166 I-HDFが保存できない zhangyue end
      sendJson.ind_device_set_info = JSON.stringify(devInfoUpdate);

      // 終了日格納有無
      sendJson.is_deadline = structData.isDeadline;
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      switch (this.deviceType) {

        case DEVICE_TYPE_NA:
          sendJson.image_flg = "0";
          break;
        case DEVICE_TYPE_DC:
          sendJson.image_flg = "1";
          break;
        case DEVICE_TYPE_UFR:
          sendJson.image_flg = "2";
          break;
        case DEVICE_TYPE_QBQD:
          sendJson.image_flg = "3";
          break;
        case DEVICE_TYPE_BVUFC:
          sendJson.image_flg = "4";
          break;
        default: break;
      }
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      // データ更新
      //mod FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      //await updateDeviceSetInfoOrd(sendJson);
      // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
      //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
      // let opeCd = "";
      // switch (this.deviceType) {
      //   case DEVICE_TYPE_UFR:
      //     opeCd = "004032";
      //     break;
      //   case DEVICE_TYPE_NA:
      //     opeCd = "004033";
      //     break;
      //   case DEVICE_TYPE_DC:
      //     opeCd = "004034";
      //     break;
      //   case DEVICE_TYPE_QBQD:
      //     opeCd = "004035";
      //     break;
      //   case DEVICE_TYPE_IHDF:
      //     opeCd = "004036";
      //     break;
      //   case DEVICE_TYPE_BVUFC:
      //     opeCd = "004037";
      //     break;
      //   case DEVICE_TYPE_DIA:
      //     opeCd = "004038";
      //     break;
      //   default: break;
      // }
      // sendJson.ope_cd = opeCd;
      // sendJson.crud =  'U';
      // sendJson.hosp_pat_id =  this.selectedPat.pat_personal_main.hosp_pat_id;
      // sendJson.ord_no =  this.settingIndData.ordNo;
      // sendJson.base_date =  '';
      // sendJson.ind_user =  this.getStateUserAccountInfo.userId;
      //add by ztc 2023-02-27 [Optimize runtime No.5482] --end
      // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      const response = await updateDeviceSetInfoOrd(sendJson);
      //mod FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      // #9857 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 linjunfeng start
      // if (200 === response.status && undefined !== response.data.msglist) {
      if (200 === response.status && undefined !== response.data.msglist && response.data.msglist.length > 0) {
      // #9857 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 linjunfeng end
        let msgList = response.data.msglist;
        let messages = "";
        msgList.forEach(item => {
          //add 7810 治療条件・装置設定変更時の動作不備 張 start
          //7810 del 治療条件・装置設定変更時の動作不備（412.xlsx）張 start
          // if (item==12000032) {
          //   this.closeType = false
          // }
          //7810 del 治療条件・装置設定変更時の動作不備（412.xlsx）張 end
          //add 7810 治療条件・装置設定変更時の動作不備 張 end
          messages = messages + this.messageInfo(item) + "<br>";
          return;
        })
        // modify start #9444
        messages && this.$ons.notification.alert({
        // modify end #9444
          // add 7809 表示されるメッセージにタイトルがない。 張start
          // title: "",
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "注意",
          title: DIALOG_MESSAGES["00300014"].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          // add 7809 表示されるメッセージにタイトルがない。張 end
          message: messages,
          callback: answer => {
          if (answer == 0) {
            this.showmessage=false;
            //OK
             // モーダルを閉じる
             //mod 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 start
            //  this.hideModal();
                  //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 start
      if (this.closeType) {
         if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
          this.isRefresh = true;
        }
        this.closeModal();
      }
      //add 7809 濃度プログラムとNa注入プログラムを同時にONにしようとした際の動作不正 張 end
             this._deviceSetDialogOwner().updateDisable = false;
            // this.setLoadingScreenVisible(false);
             //mod 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 end
          }
        }
        });
        //mod 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 start
        if (messages!=="") {
            this.showmessage=true;
        }
        //mod 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 end
      }

      //upd by ztc 2023-02-27 [Optimize runtime No.5482] --start region
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      // mod FNSI-連携イベントの登録適正化 楊 start
      // 古いリスト
      // const startDate = structData.indStartDate.replace(/-/g, '');
      // const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      // const searchData = await ApiHelper.get(
      //   `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      // ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        // getErrorMessage('BaseDeviceSetInfoEditor.vue', 'updateOrdMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // throw error;
      // });

      // const oldOrdMainList = searchData.data;
      // let opeCd = "";
      // switch (this.deviceType) {
      //   case DEVICE_TYPE_UFR:
      //     opeCd = "004032";
      //     break;
      //   case DEVICE_TYPE_NA:
      //     opeCd = "004033";
      //     break;
      //   case DEVICE_TYPE_DC:
      //     opeCd = "004034";
      //     break;
      //   case DEVICE_TYPE_QBQD:
      //     opeCd = "004035";
      //     break;
      //   case DEVICE_TYPE_IHDF:
      //     opeCd = "004036";
      //     break;
      //   case DEVICE_TYPE_BVUFC:
      //     opeCd = "004037";
      //     break;
      //   case DEVICE_TYPE_DIA:
      //     opeCd = "004038";
      //     break;
      //   default: break;
      // }
      // const params = {
      //   ope_cd: opeCd,
      //   crud: "U",
      //   facility_cd: structData.facilityCd,
      //   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //   pat_id: structData.patId,
      //   ord_no: this.settingIndData.ordNo,
      //   base_date: "",
      //   user_id: this.getStateUserAccountInfo.userId
      // };
      // if (this.settingIndData.ordNo) {
        // 変更対象クールが未登録ではないの場合、外部連携APIを呼び出す
        // if (oldOrdMainList[0].indKurCd !== null && oldOrdMainList[0].indKurCd !== 0) {
        //   createJournal({...params, base_date: oldOrdMainList[0].treatDate});
        // }
      // } else {
      //   if (oldOrdMainList) {
      //     oldOrdMainList.forEach(item => {
      //       const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //       const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //       if (structData.selectedKur.length > 0) {
      //         if (isSelectedKur) {
      //           if (item.indKurCd !== null && item.indKurCd !== 0) {
      //             createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
      //           }
      //         }
      //       } else {
      //         if (structData.selectedTreat.length > 0) {
      //           if (isSelectedTreat) {
      //             if (item.indKurCd !== null && item.indKurCd !== 0) {
      //               createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
      //             }
      //           }
      //         } else {
      //           if (item.indKurCd !== null && item.indKurCd !== 0) {
      //             createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
      //           }
      //         }
      //       }
      //     });
      //   }
      // }
      // mod FNSI-連携イベントの登録適正化 楊 end
      //upd by ztc 2023-02-27 [Optimize runtime No.5482] --start endregion
      // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        getErrorMessage('BaseDeviceSetInfoEditor.vue', 'updateOrdMain', error);
        console.log("BaseDeviceSetInfoEditor.vue updateOrdMain throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });

      const oldOrdMainList = searchData.data;
      let opeCd = "";
      let w_crud = "";
      // del #11004 連携イベント発生部分不正 piao start
      // let modSendClass = await this.getSchModifySendClass();
      // del #11004 連携イベント発生部分不正 piao end
      switch (this.deviceType) {
        case DEVICE_TYPE_UFR:
          opeCd = "004032";
          break;
        case DEVICE_TYPE_NA:
          opeCd = "004033";
          break;
        case DEVICE_TYPE_DC:
          opeCd = "004034";
          break;
        case DEVICE_TYPE_QBQD:
          opeCd = "004035";
          break;
        case DEVICE_TYPE_IHDF:
          opeCd = "004036";
          break;
        case DEVICE_TYPE_BVUFC:
          opeCd = "004037";
          break;
        case DEVICE_TYPE_DIA:
          opeCd = "004038";
          break;
        default: break;
      }
      if (oldOrdMainList) {
        let journalList = [];
        if (this.settingIndData.ordNo) {
          //変更対象クールが未登録ではないの場合、外部連携APIを呼び出す
          if (oldOrdMainList[0].indKurCd !== null && oldOrdMainList[0].indKurCd !== 0) {
            // del #11004 連携イベント発生部分不正 piao start
            // if (modSendClass == 2) {
            //   journalList.push({
            //     ope_cd: opeCd,
            //     crud: "D",
            //     facility_cd: structData.facilityCd,
            //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
            //     pat_id: structData.patId,
            //     ord_no: this.settingIndData.ordNo,
            //     base_date: oldOrdMainList[0].treatDate,
            //     user_id: this.getStateUserAccountInfo.userId
            //   });
            // }
            // del #11004 連携イベント発生部分不正 piao end
            w_crud = "U";
            // del #11004 連携イベント発生部分不正 piao start
            // if (modSendClass == 2) {
            //   w_crud = "C";
            // }
            // del #11004 連携イベント発生部分不正 piao end
            journalList.push({
              ope_cd: opeCd,
              crud: w_crud,
              facility_cd: structData.facilityCd,
              hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
              pat_id: structData.patId,
              ord_no: this.settingIndData.ordNo,
              base_date: oldOrdMainList[0].treatDate,
              user_id: this.getStateUserAccountInfo.userId
            });
            createJournalList(journalList);
          }
        } else {
          if (oldOrdMainList) {
            oldOrdMainList.forEach(item => {
              const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
              const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
              if (structData.selectedKur.length > 0) {
                if (isSelectedKur) {
                  if (item.indKurCd !== null && item.indKurCd !== 0) {
                    // del #11004 連携イベント発生部分不正 piao start
                    // if (modSendClass == 2) {
                    //   journalList.push({
                    //     ope_cd: opeCd,
                    //     crud: "D",
                    //     facility_cd: structData.facilityCd,
                    //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                    //     pat_id: structData.patId,
                    //     ord_no: item.ordNo,
                    //     base_date: item.treatDate,
                    //     user_id: this.getStateUserAccountInfo.userId
                    //   });
                    // }
                    // del #11004 連携イベント発生部分不正 piao end
                    w_crud = "U";
                    // del #11004 連携イベント発生部分不正 piao start
                    // if (modSendClass == 2) {
                    //   w_crud = "C";
                    // }
                    // del #11004 連携イベント発生部分不正 piao end
                    journalList.push({
                      ope_cd: opeCd,
                      crud: w_crud,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no: item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                    });
                  }
                }
              } else {
                if (structData.selectedTreat.length > 0) {
                  if (isSelectedTreat) {
                    if (item.indKurCd !== null && item.indKurCd !== 0) {
                      // del #11004 連携イベント発生部分不正 piao start
                      // if (modSendClass == 2) {
                      //   journalList.push({
                      //     ope_cd: opeCd,
                      //     crud: "D",
                      //     facility_cd: structData.facilityCd,
                      //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      //     pat_id: structData.patId,
                      //     ord_no: item.ordNo,
                      //     base_date: item.treatDate,
                      //     user_id: this.getStateUserAccountInfo.userId
                      //   });
                      // }
                      // del #11004 連携イベント発生部分不正 piao end
                      w_crud = "U";
                      // del #11004 連携イベント発生部分不正 piao start
                      // if (modSendClass == 2) {
                      //   w_crud = "C";
                      // }
                      // del #11004 連携イベント発生部分不正 piao end
                      journalList.push({
                        ope_cd: opeCd,
                        crud: w_crud,
                        facility_cd: structData.facilityCd,
                        hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                        pat_id: structData.patId,
                        ord_no: item.ordNo,
                        base_date: item.treatDate,
                        user_id: this.getStateUserAccountInfo.userId
                      });
                    }
                  }
                } else {
                  if (item.indKurCd !== null && item.indKurCd !== 0) {
                    // del #11004 連携イベント発生部分不正 piao start
                    // if (modSendClass == 2) {
                    //   journalList.push({
                    //     ope_cd: opeCd,
                    //     crud: "D",
                    //     facility_cd: structData.facilityCd,
                    //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                    //     pat_id: structData.patId,
                    //     ord_no: item.ordNo,
                    //     base_date: item.treatDate,
                    //     user_id: this.getStateUserAccountInfo.userId
                    //   });
                    // }
                    // del #11004 連携イベント発生部分不正 piao end
                    w_crud = "U";
                    // del #11004 連携イベント発生部分不正 piao start
                    // if (modSendClass == 2) {
                    //   w_crud = "C";
                    // }
                    // del #11004 連携イベント発生部分不正 piao end
                    journalList.push({
                      ope_cd: opeCd,
                      crud: w_crud,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no: item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                    });
                  }
                }
              }
            });
            createJournalList(journalList);
          }
        }
      }
      // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 start
      //  this.hideModal();
      // this.setLoadingScreenVisible(false);
        if (!this.showmessage) {
          if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
            this.isRefresh = true;
          }
           this.closeModal()
        }
      //add 7295除水プログラムONの時にBV-UFCがONにできてしまう 張 end
      console.log("BaseDeviceSetInfoEditor.vue updateOrdMain this.finishLoadingScreen();");

      //add #10266  start
      this.settingIndData.update_flag = null;
      //add #10266  end

      this.finishLoadingScreen();
    },
        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
    /**
     * 定義ファイルから対応するメッセージコードの文字列を取得
     * @param {object} メッセージコード
     */
    messageInfo(messageCd) {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].message;
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;

      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.replace(/\n/g, "<br>");
      return replacedMessage;
    },
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
    /**
     * @description 保存確認
     */
    saveConfirm() {
      console.log("BaseDeviceSetInfoEditor.vue saveConfirm() this.startLoadingScreen();");
      this.startLoadingScreen();
      if (this.dataSourceType === DATA_SOURCE_TYPE_MST) {
        // 編集がされていなければ、警告メッセージを表示し以降の処理を行わない
        // BV-UFCの変更チェックはisEditedとisBVEditedを見る必要がある。BV-UFC以外はisEditedのみを見る
        // BV-UFCの場合、isBVEdited: 固定倍率除水終了条件.ΔBVの変更有無を保持、isEdited: 固定倍率除水終了条件.ΔBV以外の変更有無を保持
        if (!(this.isEdited() || (this.deviceType === DEVICE_TYPE_BVUFC && this.isBVEdited))) {
          this.showNoEditing();
          console.log("BaseDeviceSetInfoEditor.vue saveConfirm() return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        if (
          this.deviceType === DEVICE_TYPE_UFR ||
          this.deviceType === DEVICE_TYPE_NA ||
          this.deviceType === DEVICE_TYPE_DC ||
          this.deviceType === DEVICE_TYPE_DIA ||
          this.deviceType === DEVICE_TYPE_QBQD ||
          this.deviceType === DEVICE_TYPE_IHDF ||
          this.deviceType === DEVICE_TYPE_BVUFC
        ) {
          // UFRプログラム、Na注入プログラム、透析液濃度プログラム、血流量・透析液流量プログラム
          // I-HDF、BV-UFCの場合は保存処理
          this.save();
        } else {
          // 患者情報展開対象の画面の場合は全患者更新確認ダイアログを表示させる
          this.showUpdateAllPatDialog();
        }
      } else {
        // add FNSI-改修内容何も編集されていない場合、保存ボタンを押下した後、メッセージ「何も編集されていません」が表示する 趙 start
        // 編集がされていなければ、警告メッセージを表示し以降の処理を行わない
        // BV-UFCの変更チェックはisEditedとisBVEditedを見る必要がある。BV-UFC以外はisEditedのみを見る
        // BV-UFCの場合、isBVEdited: 固定倍率除水終了条件.ΔBVの変更有無を保持、isEdited: 固定倍率除水終了条件.ΔBV以外の変更有無を保持
        if (!(this.isEdited() || (this.deviceType === DEVICE_TYPE_BVUFC && this.isBVEdited))) {
          this.showNoEditing();
          console.log("BaseDeviceSetInfoEditor.vue saveConfirm() return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        // add FNSI-改修内容何も編集されていない場合、保存ボタンを押下した後、メッセージ「何も編集されていません」が表示する 趙 end
        // その他の場合は即保存
        this.save();
      }
      console.log("BaseDeviceSetInfoEditor.vue saveConfirm() this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    /**
     * @description キャンセル確認
     */
    cancelConfirm() {
      //mod FNSI-6783 劉全航 start
      // if (this.isEdited()) {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240124 ztc start
      // if (this.isEdited() || this.isBVEdited) {
      //mod #11166 I-HDFが保存できない zhangyue start
      // if (this.isEdited() || this.isBVEdited || this.isTMPEdited) {
      if (this.isEdited() || this.isBVEdited) {
      //mod #11166 I-HDFが保存できない zhangyue end
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240124 ztc end
        //mod FNSI-6783 劉全航 end
        // 編集されている場合は装置設定コンポーネントにキャンセル確認ダイアログを表示させる
        this.showCancelDialog();
      } else {
        // 未編集の場合は即閉じる
        this.closeModal();
      }
    },

    /**
     * @description モーダルを閉じる
     */
    closeModal() {
      // 入力ボックスを優先的に隠す
      const cellValues = this._deviceSetElementsByClassName("device-info-cell-value");
      for (let i = 0; i < cellValues.length; i++) {
        cellValues[i].style.display = "none";
      }
      // 装置設定一覧の表示フラグを折る
      this.$emit("close");
    },

    /**
     * @description 保存時のバリデーション処理
     * @summary 必要ならば各装置設定コンポーネントで実装する
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      return null;
    },

    /**
     * @description 全ての数値入力欄の必須チェック
     * @returns {String} 最初に見つかった未入力項目名 ※ない場合は空文字
     */
    checkAllRequired() {
      let firstEmptyFormName = "";
      //mod FNSI-6844 劉全航 start
      if(this.settingIndData.headerTitle === "透析量プログラム"){
        if(this.devA["282"].value.editValue === "0"){
          return firstEmptyFormName;
        }
      }
      //mod FNSI-6844 劉全航 end
      // 各要素の必須チェック実行
      for (const el of this.requiredElements) {
        // add FNSI-UFRプログラムの修正 楊 start
        if (el) {
          // add FNSI-UFRプログラムの修正 楊 end
          if (el.isEmpty() && firstEmptyFormName === "") {
            // 最初の未入力項目名を取得
            firstEmptyFormName = el.formName;
            // 他の未入力項目も赤背景にはするので続行
          }
          // add FNSI-UFRプログラムの修正 楊 start
        }
        // add FNSI-UFRプログラムの修正 楊 end
      }
      return firstEmptyFormName;
    },

    /**
     * @description 編集チェック
     * @summary 編集済みの入力欄があるかチェックする
     * @returns {Boolean}
     */
    // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    //  isEdited() {
    isEdited(name) {
    // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
      for (const refKey in this.$refs) {
        let el;
        // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
        if (name === 'ihdfMain' && refKey === 'radio1') {
          continue;
        }
        // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
        // add #11166 I-HDFが保存できない zhangyue start
        if (this.dataSourceType !== DATA_SOURCE_TYPE_MST) {
          if (refKey === 'required-startTime') {
            continue;
          } else if (refKey === 'required-tmpTime') {
            continue;
          }
        }
        // add #11166 I-HDFが保存できない zhangyue end
        if (Array.isArray(this.$refs[refKey])) {
          // v-forで回したrefは長さ1の配列
          el = this.$refs[refKey][0];
        } else {
          el = this.$refs[refKey];
        }
        // add FNSI-UFRプログラムの修正 楊 start
        if (el) {
          // add FNSI-UFRプログラムの修正 楊 end
          if (el.isEdited) {
            return true;
          }
          // add FNSI-UFRプログラムの修正 楊 start
        }
        // add FNSI-UFRプログラムの修正 楊 end
      }
      return false;
    },

    /**
     * @description 編集キャンセル
     * @summary キャンセル確認に対し「OK」を選択したとき装置設定モーダルを閉じる
     */
    cancelEdit(answer) {
      if (answer === "OK") {
        this.closeModal();
      }
    },

    setUpdateAllPatFlg(answer) {
      this.isUpdateAllPat = answer === "No";
      this.save();
    },

    /**
     * @description ダイアログ表示
     * @param {String} messageCd ダイアログメッセージコード
     * @param {Array} stringParams メッセージ引数
     */
    //mod #10246  message change zrx start
    // showDialog({ messageCd, stringParams }) {
    showDialog({ messageCd, stringParams, title }) {
      //mod #10246  message change zrx end
      //mod FNSI-6844 劉全航 start
      if(this.settingIndData.headerTitle === "透析量プログラム"){
        let diaysisUseable = this.devA["282"].value.editValue === "1";
        if(diaysisUseable){
          this.isDialogVisble = true;
          //mod #10246  message change zrx start
          // this.dialogProps = { messageCd, stringParams };
          this.dialogProps = { messageCd, stringParams, title };
          //mod #10246  message change zrx end
        }
      }
      //mod FNSI-6844 劉全航 end
      this.isDialogVisble = true;
      // ダイアログに与えるprops作成
      //mod #10246  message change zrx start
      // this.dialogProps = { messageCd, stringParams };
      this.dialogProps = { messageCd, stringParams, title };
      //mod #10246  message change zrx end
    },

    /**
     * @description キャンセル確認ダイアログ表示
     * @summary 装置設定モーダルから呼び出される
     */
    showCancelDialog() {
      this.isCancelDialogVisble = true;
      // ダイアログに与えるprops作成
      this.dialogProps = { messageCd: 20010001, title: DIALOG_MESSAGES[20010001].title };
    },

    /**
     * @description 未編集通知ダイアログ表示
     * @summary 装置設定モーダルから呼び出される
     */
    showNoEditing() {
      this.isDialogVisble = true;
      // ダイアログに与えるprops作成
      this.dialogProps = { messageCd: 20010003 };
    },

    /**
     * @description 全患者装置設定更新ダイアログ表示
     */
    showUpdateAllPatDialog() {
      this.isUpdateAllPatDialogVisble = true;
      // ダイアログに与えるprops作成
      this.dialogProps = { messageCd: 20010005 };
    },

    // del #10359 編集権限の動作不正 dengshen start
    // // add FNSI-改修内容 権限関連 趙慧敏 start
    // getDevicesetInfoAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.PAT_DEVSET_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.PAT_DEVSET_EDIT);
    // }
    // // add FNSI-改修内容 権限関連 趙慧敏 end
    // del #10359 編集権限の動作不正 dengshen end
  }
};
</script>
