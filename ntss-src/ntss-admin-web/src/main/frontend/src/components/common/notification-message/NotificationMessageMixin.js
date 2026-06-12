/**
 * 通知メッセージ用共通コンポーネント
 */
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import dayjs from "@/compat/date/dayjs";
import commonFunctions from "@/components/status-list/StatusCommonFunction";
import { INDICATION } from "@/constants/defaultSettingConstants";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat'

import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  computed: {
    ...mapGetters("user", {
      getUserId: "getUserId",
      getFacilityCd: "getFacilityCd"
    }),
    ...mapGetters("pat-viewer", [
      "getSelectedCondition"
    ]),
    ...mapGetters("status-map/map", [
      "comboLayoutItemListGetter",
      "getBedLayoutList"
    ]),
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "getDefaultSetting"
    ]),
    ...mapGetters("staff-facility", [
      "getStaffFacilities"
    ]),
    ...mapGetters("device-edge-operation", ["getDeviceEdges"]),
    ...mapGetters("bbs-info", ["isExistBbsInfo"]),
    ...mapGetters("observe-record/list", ["getObserveRecordForUrlDirect"]),
    ...mapGetters("pat-event/list", ["getPatEventRecord", "getPatIntroLetter"]),
    ...mapGetters("indication", ["isTreatmentUnit","initSortedIndicationList"]),
    ...mapGetters("pat-prescription", ["getOrdPrescriptionNo","getOrdPrescriptionPatId"]),
  },
  methods: {
    // mapActions
    ...mapActions("app", ["setQueryParameters"]),
    ...mapActions("notification-message", ["updateNotificationMessageStatus"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("pat-info", ["selectPat", "clearSelectedPat"]),
    ...mapActions("treatment-record/common", ["setTreatDate", "setOrdNo", "setOrdNoForSideBarRecord"]),
    ...mapActions("bbs-info", ["setUserId", "setSelectedBbsInfo", "checkExistBbsInfo"]),
    ...mapActions("pat-viewer", ["setTreatBaseDate", "setSelectedCondition", "getOrdMainByOrdNo"]),
    ...mapActions("status-list/list", ["fetchStatusLayoutList"]),
    ...mapActions("status-map/map", {
      fetchStatusLayoutListStatusMap: "fetchStatusLayoutList",
      fetchBedLayoutList: "fetchBedLayoutList"
    }),
    ...mapActions("operation-viewer/motion-record", ["setHeaderInfo"]),
    ...mapActions("operation-viewer/machine", ["getMachine", "setFacilityInfo", "setFacilityCd"]),
    ...mapActions("operation-viewer/motion-record-detail", ["setMotionRecord", "getMachineRecordByMachineAndMotionRecordNo"]),
    ...mapActions("staff-facility", ["fetchStaffFacilities"]),
    ...mapActions("device-edge-operation", ["findDeviceEdges"]),
    ...mapActions("device-edge-manage", ["setDeviceEdgeInfo"]),
    ...mapActions("master-maintenance", ["setMasterName", "setLogicalMasterName"]),
    ...mapActions("observe-record/list", {
      findObserveRecordByCd: "findPatEventByCdForUrlDirect"
    }),
    ...mapActions("pat-event/detail", ["setPatEventRecord", "setViewMode"]),
    ...mapActions("pat-event/list", ["fetchPatEventMaster", "setConditionDate", "setUpdateMode", "setPatEventFlg", "findPatEventByCd", "findPatIntroLetterByCd"]),
    ...mapActions("indication", ["checkFacilitySetting", "getIndications", "setIndicationSearchCondition"]),
    ...mapActions("pat-prescription", ["findOrderPrescription"]),
    ...mapActions("daily-check", ["setDailyDateSearch"]),
    ...mapActions("sharing-patient-information", ["setIsDisclosureTab"]),
    ...mapActions("trend-graph", ["setMachineInfo"]),
    // mapGetters
    ...mapGetters("notification-message", ["isReadOnJump"]),
    ...mapGetters("operation-viewer/machine", ["getSelectMachine"]),
    // add 9583 by kangjie 20240401 start
    ...mapActions("external-coop", [
      "setJumpCoopCondition",
      "clearJumpCoopCondition"
    ]),
    // add 9583 by kangjie 20240401 end
    ...mapActions("treatment-record/roundsInfo", [
      "setRstRoundsInfoToCompare",
      "setRstRoundsInfoInProgress",
      "setSelectedRoundType",
    ]),
    ...mapActions("exam-request/list", ["setSelectedPatId"]),
    /**
     * 通知メッセージからのジャンプ処理.
     * @param {*} message 通知メッセージ情報
     */
    async jump(message) {
      try {
        this.setLoadingScreenVisible(true);

        if (await this.moveTo(message.additionalInfo)) {
          if (!message.isRead && this.isReadOnJump()) {
            // 既読にする
            this.updateNotificationMessageStatus({
              notification_message_nos: [message.no],
              is_read: "1"
            }).finally(() => {
              message.isRead = true;
            });
          }

          // ユーザーメニューを閉じる
          EventBus.$emit("closeUserMenu");
          // フッターのリストを閉じる
          EventBus.$emit("closeFooterList");

          return true;
        }
      } finally {
        this.setLoadingScreenVisible(false);
      }

      // 遷移に失敗した
      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "エラー",
        // message: "遷移に失敗しました。"
        title: DIALOG_MESSAGES['00200127'].title,
        message: messageFormat(DIALOG_MESSAGES['00200127'].message)
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      });

      return false;
    },
    /**
     * 画面遷移する.
     * @param {*} parameters 遷移パラメータ
     */
    async moveTo(parameters) {
      // URLダイレクトおよび通知からの遷移の共通処理
      // ほかの画面内遷移では通らない
      // console.log("NotificationMessageMixin - moveTo : %o", parameters);
      // modify 9583 by kangjie 20240401 start
      // const funcCdHead = parameters.FUNC.slice(0, 3);
      const funcCdHead = parameters.FUNC?.slice(0, 3);
      // modify 9583 by kangjie 20240401 end

      // ログイン画面から実行時、ユーザーの権限チェックに失敗したときfalseを返す
      if (typeof parameters.hasAuth !== 'undefined' && parameters.hasAuth === false) {
        return false;
      }

      switch(funcCdHead) {
        case "001":
          // 遠隔監視
          return await this.transitionMotionRecord(parameters);
        case "003":
          // デバイスエッジ遠隔監視
          return await this.transitionDeviceEdgeOperation(parameters);
        case "004":
          // 患者経過総合ビューア
          return await this.transitionPatViewer(parameters);
        case "006":
          // 治療記録
          return await this.transitionTreatmentRecord(parameters);
        case "011":
          // 治療状況リスト
          return await this.transitionStatusList(parameters);
        case "012":
          // 治療状況マップ
          return await this.transitionStatusMap(parameters);
        case "013":
          // 体重計・条件送信
          return await this.transitionWeightMode(parameters);
        case "016":
          // 観察記録
          return await this.transitionObserveRecord(parameters);
        case "018":
          // 検査結果
          return await this.transitionExamRecord(parameters);
        case "020":
          // 掲示板
          return await this.transitionBbsInfo(parameters);
        case "021":
          // 検査依頼
          return await this.transitionExamRequest(parameters, "exam-request");
        case "022":
          // 一般撮影検査依頼
          return await this.transitionExamRequest(parameters, "rad-request");
        case "023":
          //mode 9546 by kangjie 20230830 start
          // 患者グループ
          // return await this.transitionPatGroup();
          return await this.transitionPatGroup(parameters);
          //mode 9546 by kangjie 20230830 end
        case "027":
          // 患者イベント
          return await this.transitionPatEvent(parameters);
        case "028":
          // 指示受け・承認
          return await this.transitionIndication(parameters);
        case "029":
          // 処方
          return await this.transitionPrescription(parameters);
        case "030":
          // 紹介状
          return await this.transitionPatIntroLetter(parameters);
        case "034":
          // 日常点検
          return await this.transitionDailyCheck(parameters);
        case "037":
          // 施設カレンダー
          return await this.transitionFacilityCalender(parameters);
        case "009":
        case "014":
        case "015":
        case "035":
          // 日付指定遷移
          return await this.transitionWithDate(parameters);
        case "007":
        case "010":
        case "024":
          // 患者ID指定遷移
          return this.transitionWithPatId(parameters);
        // add 9583 by kangjie 20240403 start
        case "031":
          return await this.transitionExternalCoop(parameters);
        // add 9583 by kangjie 20240403 end
        case "005":
        case "008":
        case "017":
        case "019":
        case "032":
        case "033":
        case "038":
        case "039":
        default:
          // パラメータ無し
          return await this.transitionNoParam(parameters);
      }
    },

    // add 9583 by kangjie 20240329 start 通知一覧の連携エラー通知の遷移不正
    async transitionExternalCoop(parameters) {
      let jumpChangeCoopState =
        {
          "ctlNo":parameters.CTLNO,
          "ordNo":parameters.ORDNO,
          "baseDate":parameters.TARGET_DATE,
          "coopCd":parameters.COOP_CD
        };
      this.clearJumpCoopCondition();
      this.setJumpCoopCondition(jumpChangeCoopState);
      let transitionList = ["external-coop"];
      await this.setRouter(transitionList);
      return true;
    },
    // add 9583 by kangjie 20240329 end 通知一覧の連携エラー通知の遷移不正

    /**
     * 遷移処理(汎用)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionWithPatId(parameters) {
      const patId = parameters.PATID;

      if (patId) {
        // 患者情報の読み込み
        this.setLoadingScreenVisible(true);
        this.clearSelectedPat()
          .then(this.selectPat(patId))
          .finally(() => {
            this.setLoadingScreenVisible(false);
          });
      }

      if (parameters.routerName) {
        this.$router.push({
          name: parameters.routerName,
          params: { footer: null }
        });
        return true;
      }
      return false;
    },

    /**
     * 遷移処理(日付指定)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionWithDate(parameters) {

      if (parameters.DATE) {
        parameters.DATE = this.formatDate(parameters.DATE, "YYYY-MM-DD");
      }

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["DATE"]);
      this.setQueryParameters(useParameters);

      if (parameters.routerName) {
        this.$router.push({
          name: parameters.routerName
        });
        return true;
      }
      return false;
    },

    /**
     * 遷移処理(パラメータ無し)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionNoParam(parameters) {
      if (parameters.routerName) {
        this.$router.push({
          name: parameters.routerName
        });
        return true;
      }
      return false;
    },



    /**
     * 遷移処理(装置記録)
     * @param {*} parameters 遷移パラメータ
     */
    async transitionMotionRecord(parameters) {

      // 遷移リスト 初期値は親画面のみ(nkk施設かどうかで異なる)
      let transitionList = [];
      if (this.getFacilityCd === "nkknkk") {
        transitionList.push("operation-viewer-admin-facilities");
      } else {
        transitionList.push("operation-viewer-general-machines");
      }

      let availableRequiredFlg; // 必須パラメータあり
      let requiredKeys = []; // 必須パラメータの一覧

      // 子画面ごとの処理分岐
      // 機能コードが同じでも日機装ユーザーかどうかで処理が異なるため、routerNameで判断する
      switch(parameters.routerName) {
        case "operation-viewer-admin-machines":
          // 00102 遠隔監視 日機装ユーザー向け
          requiredKeys = ["FACILITYCD"];
          availableRequiredFlg = await this.checkRequired(parameters, requiredKeys);
          if (availableRequiredFlg) {
            const facilityInfo = await this.getFacilityInfoInCharge(parameters.FACILITYCD);
            if (facilityInfo !== null) {
              this.setFacilityInfo(facilityInfo);
              transitionList.push("operation-viewer-admin-machines");
            }
          }

          break;
        case "operation-viewer-admin-motion-record":
          // 00103 装置記録 日機装ユーザー向け
          requiredKeys = ["FACILITYCD", "MACHINETYPECD", "MACHINESERIAL"];
          availableRequiredFlg = await this.checkRequired(parameters, requiredKeys);
          if (availableRequiredFlg) {
            const facilityInfo = await this.getFacilityInfoInCharge(parameters.FACILITYCD);
            if (facilityInfo !== null) {
              this.setFacilityInfo(facilityInfo);
              const machine = await this.checkMachine(parameters);
              if (machine) {
                await this.setHeaderInfo(machine);
                transitionList.push("operation-viewer-admin-machines");
                transitionList.push("operation-viewer-admin-motion-record");
              } else {
                transitionList.push("operation-viewer-admin-machines");
              }
            }
          }
          break;
        case "operation-viewer-admin-motion-record-detail":
          // 00104 装置記録詳細 日機装ユーザー向け
          requiredKeys = ["FACILITYCD", "MACHINETYPECD", "MACHINESERIAL", "MOTIONRECORDNO"];
          availableRequiredFlg = await this.checkRequired(parameters, requiredKeys);
          if (availableRequiredFlg) {
            const facilityInfo = await this.getFacilityInfoInCharge(parameters.FACILITYCD);
            if (facilityInfo !== null) {
              this.setFacilityInfo(facilityInfo);
              const machine = await this.checkMachine(parameters);
              if (machine) {
                await this.setHeaderInfo(machine);
                // 詳細情報が取得できるかチェック
                const machineRecord = await this.checkMotionRecord(parameters);
                if (machineRecord !== "") {
                  // 装置+装置記録詳細を特定 → 装置記録詳細画面へ
                  this.setMotionRecordToStore(machineRecord);
                  transitionList.push("operation-viewer-admin-machines");
                  transitionList.push("operation-viewer-admin-motion-record");
                  transitionList.push("operation-viewer-admin-motion-record-detail");
                } else {
                  // 装置のみ特定 → 該当装置の装置記録一覧画面へ
                  transitionList.push("operation-viewer-admin-machines");
                  transitionList.push("operation-viewer-admin-motion-record");
                }
              } else {
                transitionList.push("operation-viewer-admin-machines");
              }
            }
          }
          break;
        case "operation-viewer-general-motion-record":
          // 00103 装置記録 一般ユーザー向け
          requiredKeys = ["MACHINETYPECD", "MACHINESERIAL"];
          availableRequiredFlg = await this.checkRequired(parameters, requiredKeys);
          if (availableRequiredFlg) {
            parameters.FACILITYCD = this.getFacilityCd;
            this.setFacilityCd(this.getFacilityCd);
            const machine = await this.checkMachine(parameters);
            if (machine) {
              await this.setHeaderInfo(machine);
              transitionList.push("operation-viewer-general-motion-record");
            }
          }
          break;
        case "operation-viewer-general-motion-record-detail":
          // 00104 装置記録詳細 一般ユーザー向け
          requiredKeys = ["MACHINETYPECD", "MACHINESERIAL", "MOTIONRECORDNO"];
          availableRequiredFlg = await this.checkRequired(parameters, requiredKeys);
          if (availableRequiredFlg) {
            parameters.FACILITYCD = this.getFacilityCd;
            this.setFacilityCd(this.getFacilityCd);
            const machine = await this.checkMachine(parameters);
            if (machine) {
              await this.setHeaderInfo(machine);
              // 詳細情報が取得できるかチェック
              const machineRecord = await this.checkMotionRecord(parameters);
              if (machineRecord !== "") {
                // 装置+装置記録詳細を特定 → 装置記録詳細画面へ
                this.setMotionRecordToStore(machineRecord);
                transitionList.push("operation-viewer-general-motion-record");
                transitionList.push("operation-viewer-general-motion-record-detail");
              } else {
                // 装置のみ特定 → 該当装置の装置記録一覧画面へ
                transitionList.push("operation-viewer-general-motion-record");
              }
            }
          }
          break;
        default:
          break;
      }

      // パラメータを保存
      const requiredParams = await this.removeParametersNotUsed(parameters, requiredKeys);
      this.setQueryParameters(requiredParams);

      // 遷移処理
      await this.setRouter(transitionList);

      return true;
    },

    /**
     * 遷移処理(デバイスエッジ遠隔監視)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionDeviceEdgeOperation(parameters) {

      // 遷移リスト
      let transitionList = [];
      transitionList.push("device-edge-operation");

      let availableRequiredFlg; // 必須パラメータあり
      let requiredKeys;

      if (parameters.routerName === "device-edge-manage") {
        // 子画面(デバイスエッジ遠隔保守)の場合
        // 必須パラメータチェック
        requiredKeys = ["FACILITYCD", "DEVICEEDGENO"];
        availableRequiredFlg = await this.checkRequired(parameters, requiredKeys);
        if (availableRequiredFlg) {
          await this.findDeviceEdges(this.getStateUserAccountInfo.userId);
          const targetDeviceEdge = this.getDeviceEdges.filter(edge => {
            return edge.facilityCd === parameters.FACILITYCD && edge.deviceEdgeNo === parseInt(parameters.DEVICEEDGENO);
          })
          if (targetDeviceEdge.length > 0) {
            // 整合性チェックに合格したら遷移リストに子画面追加
            this.setDeviceEdgeInfo(targetDeviceEdge[0]);
            transitionList.push("device-edge-manage");
          }
        }
      }

      // 遷移処理
      await this.setRouter(transitionList);

      return true;
    },

    /**
     * 遷移処理(患者経過総合ビューア)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionPatViewer(parameters) {
      // 患者経過総合ビューア

      // 各パラメータ初期値
      let patId = parameters.PATID;
      let baseDate = null;
      let ordNo = parameters.ORDNO;

      if (parameters.DATE) {
        baseDate = this.formatDate(parameters.DATE, "YYYY-MM-DD");
      }

      // ord_main取得
      let ordMain = null;
      if (ordNo) {
        ordMain = await this.getOrdMainByOrdNo(ordNo);
      }

      // パラメータ修正処理
      if (patId) {
        // PATIDあり
        if (ordMain) {
          // 有効なORDNOあり
          // PATIDがord_mainと一致すればDATEを取ってくる
          if (ordMain.patId === patId) {
            baseDate = this.formatDate(ordMain.treatDate, "YYYY-MM-DD");
          }
        }
      } else {
        // PATIDなし
        if (ordMain) {
          // 有効なORDNOあり
          // PATID,DATEをord_mainから取ってくる
          patId = ordMain.patId;
          baseDate = this.formatDate(ordMain.treatDate, "YYYY-MM-DD");
        }
      }

      if (patId) {
        // 患者情報の読み込み
        this.setLoadingScreenVisible(true);
        this.clearSelectedPat()
          .then(this.selectPat(patId))
          .finally(() => {
            this.setLoadingScreenVisible(false);
          });
      }

      if (ordNo) {
        this.setOrdNo(ordNo);
      }

      if (baseDate) {
        this.setTreatBaseDate(baseDate);
      }

      if (parameters.routerName) {
        this.$router.push({
          name: parameters.routerName,
          params: { footer: null }
        });
        return true;
      }
      return false;
    },

    /**
     * 遷移処理(治療記録)
     * @param {*} parameters 遷移パラメータ
     */
    async transitionTreatmentRecord(parameters) {
      // 患者情報セット後にオーダー番号をセットして遷移する必要がある。
      // 子画面の場合、一旦親画面に遷移した後で子画面に遷移する。
      let patId = Number(parameters.PATID);
      let treatDate = null;
      let ordNo = Number(parameters.ORDNO);

      if (parameters.DATE) {
        treatDate = this.formatDate(parameters.DATE, "YYYYMMDD");
      }

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["PATID", "ORDNO", "DATE"]);
      this.setQueryParameters(useParameters);

      // ord_main取得
      let ordMain = null;
      if (ordNo) {
        ordMain = await this.getOrdMainByOrdNo(ordNo);
      }

      // パラメータ修正処理
      if (patId) {
        // PATIDあり
        if (ordMain) {
          // 有効なORDNOあり
          // patIdがord_mainと一致すればdateを取ってくる
          if (ordMain.patId === patId) {
            treatDate = this.formatDate(ordMain.treatDate, "YYYYMMDD");
          }
        }
      } else {
        // PATIDなし
        if (ordMain) {
          // 有効なORDNOあり
          // PATID,DATEをord_mainから取ってくる
          patId = ordMain.patId;
          treatDate = this.formatDate(ordMain.treatDate, "YYYYMMDD");
        }
      }

      if (patId) {
        // 患者情報の読み込み
        this.setLoadingScreenVisible(true);
        await this.selectPat(patId);

        // 遷移リスト
        let transitionList = [
          "treatment-record"
        ];

        // 有効なORDNOあり→ORDNOをセットする
        if (ordMain && ordMain.patId === patId) {
          this.setOrdNo(ordNo);
          // 有効なORDNOで再設定させるため、回診記録をクリア
          await this.setRstRoundsInfoToCompare(null);
          await this.setRstRoundsInfoInProgress(null);
          await this.setSelectedRoundType(-1);
        }

        if (treatDate) {
          this.setTreatDate(treatDate);
        }

        if (parameters.routerName !== "treatment-record") {
          // 子画面の場合→遷移リストに子画面を追加
          transitionList.push(parameters.routerName);
        }

        // 遷移処理
        await this.setRouter(transitionList);

        this.setLoadingScreenVisible(false);
        return true;

      } else {
        await this.clearSelectedPat();
        // patIdが特定できない場合は親画面へ遷移
        if (parameters.routerName) {
          this.$router.push({
            name: "treatment-record",
            params: { footer: null }
          });
          return true;
        }
      }
      return false;
    },

    /**
     * 遷移処理(治療状況リスト)
     * @param {*} parameters 遷移パラメータ
     * MODE: 大画面表示の表示種別 1: 1段組み / 2: 2段組み
     * LAYOUTNO: 治療情報レイアウトマスタシーケンス
     */
    async transitionStatusList(parameters) {
      const funcCdTail = parameters.FUNC.slice(3, 5);
      this.setLoadingScreenVisible(true);

      if (funcCdTail === "04") {
        // トレンドグラフの場合→装置の判別と遷移処理
        // 必須パラメータチェック
        const availableRequiredFlg = await this.checkRequired(parameters, ["MACHINETYPECD", "MACHINESERIAL"]);
        if (availableRequiredFlg) {
          // 整合性チェック
          parameters.FACILITYCD = this.getFacilityCd;
          const machine = await this.checkMachine(parameters);
          if (machine !== "" && (machine.model === "001" || machine.model === "002" || machine.model === "003")) {
            // 装置が RO/供給装置/溶解装置 の場合
            const machineInfo = {
              machineName: machine.machineName,
              machineSerial: machine.machineSerial,
              machineTypeCd: machine.machineTypeCd,
              model: machine.model
            };
            await this.setMachineInfo(machineInfo);
            // 画面幅に応じてサイドバーを閉じる
            EventBus.$emit("sidebarCloseByWidth");
            // 一旦、自画面へ
            await this.$router.push({ name: "status-list" });

            // その後、指定画面へ
            if (parameters.routerName !== "") {
              await this.$router.push({ name: parameters.routerName });
            }
          } else this.$router.push({ name: "status-list" }); // 透析装置または不明な装置
        } else this.$router.push({ name: "status-list" }); // 必須パラメータなし
      } else {
        // 遷移リスト
        let transitionList = [
          "status-list"
        ];

        if (funcCdTail !== "01") {
          // トレンドグラフ以外の子画面の場合→遷移リストに子画面を追加
          transitionList.push(parameters.routerName);
        }

        // レイアウト番号のチェック
        parameters.colItemLayoutNo = await this.checkLayoutNo(parameters.LAYOUTNO,"0");

        // パラメータを保存
        const useParameters = await this.removeParametersNotUsed(parameters, ["MODE", "LAYOUTNO", "colItemLayoutNo"]);
        this.setQueryParameters(useParameters);
        // mod #10371 使用許可機能権限OFF時に動作不正 20240528 ztc start
        let transitionUniqueList = [...new Set(transitionList)];
        // 遷移処理
        // this.setRouter(transitionList);
        await this.setRouter(transitionUniqueList);
        // mod #10371 使用許可機能権限OFF時に動作不正 20240528 ztc end
      }

      this.setLoadingScreenVisible(false);
      return true;
    },

    /**
     * 遷移処理(治療状況マップ)
     * @param {*} parameters 遷移パラメータ
     * LAYOUTNO: 治療情報レイアウトマスタシーケンス
     * BEDLAYOUTNO: 治療情報ベッドレイアウトマスタシーケンス
     */
    async transitionStatusMap(parameters) {
      this.setLoadingScreenVisible(true);

      // 遷移リスト
      let transitionList = [
        "status-map"
      ];

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["LAYOUTNO", "BEDLAYOUTNO"]);
      this.setQueryParameters(useParameters);

      // 遷移処理
      await this.setRouter(transitionList);

      this.setLoadingScreenVisible(false);
      return true;
    },

    /**
     * 遷移処理(体重計・条件送信)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionWeightMode(parameters) {
      const funcCdTail = parameters.FUNC.slice(3, 5);

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["WEIGHTNO", "MODE"]);
      this.setQueryParameters(useParameters);

      // 遷移
      await this.$router.push({
        name: "weight-mode",
        params: { footer: null }
      });
      if (funcCdTail === "04") {
        this.setMasterName("mst_wheel_chair");
        this.setLogicalMasterName("mst_wheel_chair");
        await this.$router.push({
          name: parameters.routerName,
          params: { footer: null }
        });
      }
      return true;
    },

    /**
     * 遷移処理(観察記録)
     * @param {*} parameters 遷移パラメータ
     */
    async transitionObserveRecord(parameters) {
      const funcCdTail = parameters.FUNC.slice(3, 5);
      this.setLoadingScreenVisible(true);

      // 遷移リスト
      let transitionList = ["observe-record"];

      if (funcCdTail === "01") {
        // 親画面の場合
        if (parameters.PATID && parameters.PATID !== null) {
          // 患者情報の読み込み
          await this.clearSelectedPat();
          await this.selectPat(parameters.PATID);
        }
      } else if (funcCdTail === "02") {
        // 子画面の場合
        if (parameters.PATEVENTNO && parameters.PATEVENTNO !== null) {
          await this.findObserveRecordByCd([{
            patEventCd: parameters.PATEVENTNO
          }])
          if(this.getObserveRecordForUrlDirect !== null && Object.prototype.hasOwnProperty.call(this.getObserveRecordForUrlDirect, "patId")) {
            const selectedPatEvent = this.getObserveRecordForUrlDirect;
            // 患者情報の読み込み
            await this.clearSelectedPat();
            await this.selectPat(selectedPatEvent.patId);

            // 患者イベント関連のマスタ取得
            await this.fetchPatEventMaster();

            // 観察記録のセット
            await this.setPatEventRecord({
              selfScreenName: "observe-record",
              bbsCtlNo: selectedPatEvent.bbsCtlNo,
              categoryCd: selectedPatEvent.categoryCd,
              categoryName: selectedPatEvent.categoryName,
              eventEndDate: selectedPatEvent.eventEndDate,
              eventEndTime: selectedPatEvent.eventEndTime,
              eventStartDate: selectedPatEvent.eventStartDate,
              eventStartTime: selectedPatEvent.eventStartTime,
              eventStatus: selectedPatEvent.eventStatus,
              facilityCd: selectedPatEvent.facilityCd,
              fnCtlNo: selectedPatEvent.fnCtlNo,
              inputParams: selectedPatEvent.inputParams,
              isDel: selectedPatEvent.isDel,
              isNewest: selectedPatEvent.isNewest,
              letterInfo: selectedPatEvent.letterInfo,
              operatorId: selectedPatEvent.operatorId,
              ordNo: selectedPatEvent.ordNo,
              patEventCd: selectedPatEvent.patEventCd,
              patId: selectedPatEvent.patId,
              regDate: selectedPatEvent.regDate,
              regStaffInfo: selectedPatEvent.regStaffInfo,
              resultParams: selectedPatEvent.resultParams,
              scoreTotal: selectedPatEvent.scoreTotal,
              subCategoryCd: selectedPatEvent.subCategoryCd,
              subCategoryName: selectedPatEvent.subCategoryName,
              targetFacilityCd: selectedPatEvent.targetFacilityCd,
              templateCd: selectedPatEvent.templateCd,
              templateName: selectedPatEvent.templateName,
              upDate: selectedPatEvent.upDate,
              upStaffInfo: selectedPatEvent.upStaffInfo,
              useType: selectedPatEvent.useType,
              isComRec: true
            });
            // 表示モードの設定
            this.setPatEventFlg(true);
            this.setViewMode(false);
            this.setUpdateMode(true);
            // 遷移リストに追加
            transitionList.push("observe-record-detail");
          }
        }
      }

      // 遷移処理
      await this.setRouter(transitionList);

      this.setLoadingScreenVisible(false);

      return true;
    },

    /**
     * 遷移処理(検査結果)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionExamRecord(parameters) {
      const funcCdTail = parameters.FUNC.slice(3, 5);
      this.setLoadingScreenVisible(true);

      // 遷移リスト
      let transitionList = [
        "exam-record"
      ];

      if (funcCdTail === "02") {
        // 子画面の場合 必須パラメータチェック
        if (parameters.PATID && parameters.PATID !== null) {
          // 患者情報の読み込み
          await this.clearSelectedPat();
          await this.selectPat(parameters.PATID);
          transitionList.push(parameters.routerName);
          await this.setRouter(transitionList);
          this.setLoadingScreenVisible(false);
          return true;
        }
      }

      // 遷移処理
      await this.setRouter(transitionList);

      this.setLoadingScreenVisible(false);
      return true;
    },

    /**
     * 遷移処理(掲示板)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionBbsInfo(parameters) {
      const funcCdTail = parameters.FUNC.slice(3, 5);
      this.setLoadingScreenVisible(true);

      // 遷移リスト
      let transitionList = [
        "bbs-info"
      ];

      if (funcCdTail === "01") {
        // 親画面の場合
        if (parameters.DATE && parameters.DATE !== null) {
          // 日付フォーマットチェック&整形
          parameters.DATE = this.formatDate(parameters.DATE, "YYYY-MM-DD");
        }
      }

      if (funcCdTail === "02") {
        // 子画面の場合 必須パラメータチェック
        if (parameters.BBSCTLNO && parameters.BBSCTLNO !== null) {
          // サインイン中のユーザーIDをStoreにセット
          this.setUserId(this.getUserId);
          await this.checkExistBbsInfo(parameters.BBSCTLNO);
          if (this.isExistBbsInfo) {
            // 掲示板情報のセット
            await this.setSelectedBbsInfo(parameters.BBSCTLNO);
            transitionList.push(parameters.routerName);
            await this.setRouter(transitionList);
            this.setLoadingScreenVisible(false);
            return true;
          }
        }
      }

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["DATE"]);
      this.setQueryParameters(useParameters);

      // 遷移処理
      await this.setRouter(transitionList);

      this.setLoadingScreenVisible(false);
      return true;
    },

    /**
     * 遷移処理(施設カレンダー)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionFacilityCalender(parameters) {
      const funcCdTail = parameters.FUNC.slice(3, 5);
      this.setLoadingScreenVisible(true);

      // 遷移リスト
      let transitionList = [
        "facility-calendar"
      ];

      if (funcCdTail === "02") {
        // 子画面の場合 必須パラメータチェック
        if (parameters.BBSCTLNO && parameters.BBSCTLNO !== null) {
          // サインイン中のユーザーIDをStoreにセット
          this.setUserId(this.getUserId);
          await this.checkExistBbsInfo(parameters.BBSCTLNO);
          if (this.isExistBbsInfo) {
            // 掲示板情報のセット
            await this.setSelectedBbsInfo(parameters.BBSCTLNO);
            transitionList.push(parameters.routerName);
            await this.setRouter(transitionList);
            this.setLoadingScreenVisible(false);
            return true;
          }
        }
      }

      // 遷移処理
      await this.setRouter(transitionList);

      this.setLoadingScreenVisible(false);
      return true;
    },

    /**
     * 遷移処理(検査依頼/一般撮影検査依頼)
     * @param {*} parameters 遷移パラメータ
     * @param parentName 親画面のrouter名
     */
     async transitionExamRequest(parameters, parentName) {
      const funcCdTail = parameters.FUNC.slice(3, 5);
      this.setLoadingScreenVisible(true);

      // 遷移リスト
      let transitionList = [
        parentName
      ];

      if (funcCdTail === "02") {
        // 子画面の場合 必須パラメータチェック
        if (parameters.PATID && parameters.PATID !== null) {
          if (parameters.DATE && parameters.DATE !== null) {
            // 日付フォーマットチェック&整形
            parameters.DATE = this.formatDate(parameters.DATE, "YYYY-MM-DD");
          }
          // 患者情報の読み込み
          await this.clearSelectedPat();
          await this.selectPat(parameters.PATID);
          this.setSelectedPatId(parameters.PATID); // NOTE: 検査依頼のstoreにも選択した患者IDを設定

          // パラメータを保存
          const useParameters = await this.removeParametersNotUsed(parameters, ["DATE"]);
          this.setQueryParameters(useParameters);

          transitionList.push(parameters.routerName);
          await this.setRouter(transitionList);
          this.setLoadingScreenVisible(false);
          return true;
        }
      }

      // 遷移処理
      await this.setRouter(transitionList);

      this.setLoadingScreenVisible(false);
      return true;
    },

    /**
     * 遷移処理(患者グループ)
     */
    // mode 9546 by kangjie 20230830 start
    //  async transitionPatGroup() {
    //
    //   // 必ず親画面に遷移
    //   this.$router.push({
    //     name: "pat-group",
    //     params: { footer: null}
    //   });
    //   return true;
    // },
     async transitionPatGroup(parameters) {
      await this.$router.push({
              name: "pat-group",
              params: { footer: null}
            });
      // 必ず親画面に遷移
      await this.$router.push({
        name: parameters.routerName,
        params: { footer: null, patGroupCd: parameters.PATGROUPCD }
      });
      return true;
    },
    // mode 9546 by kangjie 20230830 end

    /**
     * 遷移処理(患者イベント)
     * @param {*} parameters 遷移パラメータ
     */
    async transitionPatEvent(parameters) {
      this.setLoadingScreenVisible(true);
      let patId = null;
      let paramPatEventCd = null;

      // PATID指定時
      if (parameters.PATID && parameters.PATID !== null) {
        // 患者IDの設定
        patId = parameters.PATID;
      }

      // 患者イベントコードの設定 PATEVENTNO指定時
      if (parameters.PATEVENTNO && parameters.PATEVENTNO !== null) {
        paramPatEventCd = parameters.PATEVENTNO;
      }

      // 患者イベントコードの設定 PATEVENTCD指定時
      if (parameters.PATEVENTCD && parameters.PATEVENTCD !== null) {
        paramPatEventCd = parameters.PATEVENTCD;
      }

      // 患者イベントコードに該当するレコードの存在判断
      if (paramPatEventCd !== null) {
        // 指定されたPATEVENTNOを持つ患者イベントを取得
        await this.findPatEventByCd([{
          patEventCd: paramPatEventCd
        }])
        if (this.getPatEventRecord.length > 0) {
          // 指定されたPATEVENTNOを持つ患者イベントがある
          parameters.PATEVENTCD = paramPatEventCd;
          const selectedPatEvent = this.getPatEventRecord[0];
          if(selectedPatEvent !== null) {
            if (selectedPatEvent.patId) {
              // 患者IDの設定(該当患者イベントに紐付くIDで上書き)
              patId = selectedPatEvent.patId;
            }
            if (selectedPatEvent.eventStartDate) {
              // 開始日の設定
              parameters.eventStartDate = selectedPatEvent.eventStartDate;
            }
            if (selectedPatEvent.eventEndDate) {
              // 終了日の設定
              parameters.eventEndDate = selectedPatEvent.eventEndDate;
            }
          }
        } else {
          // 指定されたPATEVENTNOを持つ患者イベントがない
          parameters.PATEVENTCD = null;
        }
      }

      // 患者情報のセット
      if (patId !== null) {
        await this.clearSelectedPat();
        await this.selectPat(patId);
      }

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["PATEVENTCD", "eventStartDate", "eventEndDate"]);
      this.setQueryParameters(useParameters);

      this.$router.push({
        name: "pat-event",
        params: { footer: null }
      });

      this.setLoadingScreenVisible(false);

      return true;
    },

    /**
     * 遷移処理(指示受け・指示承認)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionIndication(parameters) {
      const funcCdTail = parameters.FUNC.slice(3, 5);

      if (funcCdTail !== "01") {
        // 子画面の場合
        // 例外的に、子画面遷移処理は親画面側から実施(サイドバー表示など複雑になるため)

        // 施設設定マスタの情報取得
        await this.checkFacilitySetting();

        let method = null;
        if (funcCdTail === "02") {
          // 指示受け
          method = "receive";
        } else if (funcCdTail === "03") {
          // 指示承認
          method = "approve";
        }

        if (method) {
          if (this.isTreatmentUnit) {
            // 治療単位
            // 指定したORDNOの治療情報があれば遷移
            if (parameters.ORDNO && parameters.ORDNO !== null) {
              const ordMain = await this.getOrdMainByOrdNo(parameters.ORDNO);
              if (ordMain) {
                parameters.isGotoDetail = true;
                parameters.method = method;
                parameters.PATID = ordMain.patId;
              }
            }
          } else {
            // 指示単位
            // 指定した日付・モードで検索した中に指定したPATIDのデータがあれば遷移
            if (parameters.PATID && parameters.PATID !== null) {
              this.setIndicationSearchCondition(this.createIndicationSearchCondition(parameters));
              await this.getIndications();
              if (this.initSortedIndicationList) {
                const indication = this.initSortedIndicationList.find(item => {
                  return item.patId === parameters.PATID.toString();
                })
                if (indication) {
                  parameters.isGotoDetails = true;
                  parameters.indication = indication;
                  parameters.method = method;
                }
              }
            }
          }
        }
      }

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, [
        "ORDNO", "PATID", "isGotoDetail", "isGotoDetails", "indication", "method"
      ]);
      this.setQueryParameters(useParameters);

      this.$router.push({
        name: "indication",
        params: { footer: null }
      });

      return true;
    },

    /**
     * 遷移処理(処方)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionPrescription(parameters) {
      this.setLoadingScreenVisible(true);
      let patId = null;
      let ordPrescriptionNo = null;

      // PATID指定時
      if (parameters.PATID && parameters.PATID !== null) {
        // 患者IDの設定
        patId = parameters.PATID;
      }

      // 処方オーダー番号の設定 RPNO指定時
      if (parameters.RPNO && parameters.RPNO !== null) {
        ordPrescriptionNo = parameters.RPNO;
      }

      // 処方オーダー番号に該当するレコードの存在判断
      if (ordPrescriptionNo !== null) {
        // 指定されたRPNOを持つ処方情報を取得
        await this.findOrderPrescription(
          patId !== null
            ? { ordPrescriptionNo, selectedPatId: patId }
            : ordPrescriptionNo
        );

        if (this.getOrdPrescriptionNo > 0) {
          // 指定されたRPNOを持つ処方情報がある
          parameters.RPNO = ordPrescriptionNo;
          if (this.getOrdPrescriptionPatId > 0 && patId === null) {
            // 患者ID未設定時のみ、患者IDの設定 (PATIDパラメータを優先する)
            patId = this.getOrdPrescriptionPatId;
          }
        } else {
          // 指定されたPATEVENTNOを持つ患者イベントがない
          parameters.RPNO = null;
        }
      }

      // 患者情報のセット
      if (patId !== null) {
        await this.clearSelectedPat();
        await this.selectPat(patId);
      }

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["PATID", "RPNO", "DATE"]);
      this.setQueryParameters(useParameters);

      // 遷移
      if (parameters.routerName) {
        this.$router.push({
          name: parameters.routerName,
          params: { footer: null }
        });
        return true;
      }

      this.setLoadingScreenVisible(false);

      return false;
    },

    /**
     * 遷移処理(紹介状)
     * @param {*} parameters 遷移パラメータ
     */
    async transitionPatIntroLetter(parameters) {
      this.setLoadingScreenVisible(true);
      let patId = null;
      let paramPatEventCd = null;

      // PATID指定時
      if (parameters.PATID && parameters.PATID !== null) {
        // 患者IDの設定
        patId = parameters.PATID;
      }

      // 患者イベントコードの設定 PATEVENTNO指定時
      if (parameters.PATEVENTNO && parameters.PATEVENTNO !== null) {
        paramPatEventCd = parameters.PATEVENTNO;
      }

      // 患者イベントコードに該当するレコードの存在判断
      if (paramPatEventCd !== null) {
        // console.log("paramPatEventCd: %o", paramPatEventCd);

        // 指定されたPATEVENTNOを持つ患者イベントを取得
        await this.findPatIntroLetterByCd(paramPatEventCd);
        if (this.getPatIntroLetter.length > 0) {
          // 指定されたPATEVENTNOを持つ患者イベントがある
          parameters.PATEVENTCD = paramPatEventCd;
          const selectedPatEvent = this.getPatIntroLetter[0];
          if(selectedPatEvent !== null) {
            if (selectedPatEvent.patId) {
              // 患者IDの設定(該当患者イベントに紐付くIDで上書き)
              patId = selectedPatEvent.patId;
            }
            if (selectedPatEvent.eventStartDate) {
              // 開始日の設定
              parameters.eventStartDate = selectedPatEvent.eventStartDate;
            }
            if (selectedPatEvent.eventEndDate) {
              // 終了日の設定
              parameters.eventEndDate = selectedPatEvent.eventEndDate;
            }
          }
        } else {
          // 指定されたPATEVENTNOを持つ患者イベントがない
          parameters.PATEVENTCD = null;
        }
      }

      // 患者情報のセット
      if (patId !== null) {
        await this.clearSelectedPat();
        await this.selectPat(patId);
      }

      // パラメータを保存
      const useParameters = await this.removeParametersNotUsed(parameters, ["PATEVENTCD", "eventStartDate", "eventEndDate"]);
      this.setQueryParameters(useParameters);

      this.$router.push({
        name: "pat-intro-letter",
        params: { footer: null }
      });

      this.setLoadingScreenVisible(false);

      return true;
    },

    /**
     * 遷移処理(日常点検)
     * @param {*} parameters 遷移パラメータ
     */
     async transitionDailyCheck(parameters) {

      if (parameters.DATE) {
        const date = this.formatDate(parameters.DATE, "YYYY-MM-DD");
        if (date !== null) {
          this.setDailyDateSearch(date);
        }
      }

      if (parameters.routerName) {
        this.$router.push({
          name: parameters.routerName
        });
        return true;
      }
      return false;
    },




    /**
     * 画面遷移(多段)
     * @param transitionList 遷移情報リスト
     */
    async setRouter(transitionList) {
      // 遷移情報リスト分画面遷移する
      for (const name of transitionList) {
        await this.$router.push({
          name,
          params: { footer: null }
        });
      }
    },

    /**
     * 日付パラメータの整形
     * @param dateStr 日付
     * @param format 日付フォーマット
     * @return 正常なデータの場合は引数formatに即した日付文字列 不正データの場合はnull
     */
    formatDate(dateStr, format) {
      if (!dateStr) {
        return null;
      }
       const date = dayjs(dateStr);
       if (date.isValid()) {
         return date.format(format);
       }
       return null;
    },

    /**
     * 治療状況レイアウト番号のチェック
     * @param strLayoutNo レイアウト番号
     * @param useClass 使用区分 "0":リスト / "1":マップ
     * @return 正常なデータの場合はレイアウト番号を数値化したものを返す 不正データの場合はnull
     */
    async checkLayoutNo(strLayoutNo, useClass) {
      const numLayoutNo = Number.parseInt(strLayoutNo);
      const response = await this.fetchStatusLayoutList();
      // 表示項目一覧(コンボボックス)を取得
      let getColItemData = response.data;
      const comboLayoutItemList = commonFunctions.buildComboBoxItemsTreatmentLayout(
        getColItemData,
        useClass
      );
      // レイアウト番号が取得したリストに含まれる場合、インデックスを返す
      return comboLayoutItemList.findIndex(({colItemLayoutNo}) => colItemLayoutNo === numLayoutNo);
    },

    /**
     * 必須パラメータチェック
     * @param {*} parameters 遷移パラメータ
     * @param keys 必須パラメータのキー(FACILITYCD 等)の文字列配列
     * @return keysにて指定したパラメータが全て存在すればtrue 1つでも存在しなければfalse
     */
    async checkRequired(parameters, keys) {
      for (const key of keys) {
        const result = Object.prototype.hasOwnProperty.call(parameters, key);
        if (!result) return false;
      }
      return true;
    },

    /**
     * 装置の存在チェック
     * @param {*} parameters 遷移パラメータ
     * @return 対応する装置情報を返す
     */
    async checkMachine(parameters) {
      const condition = {
        facilityCd: parameters.FACILITYCD,
        machineTypeCd: parameters.MACHINETYPECD,
        machineSerial: parameters.MACHINESERIAL
      }

      await this.getMachine(condition);
      const machine = this.getSelectMachine();

      return machine;
    },

    /**
     * 装置記録の存在チェック
     * @param {*} parameters 遷移パラメータ
     * @return 対応する装置記録を返す
     */
    async checkMotionRecord(parameters) {
      return await this.getMachineRecordByMachineAndMotionRecordNo({
        facilityCd: parameters.FACILITYCD,
        machineTypeCd: parameters.MACHINETYPECD,
        machineSerial: parameters.MACHINESERIAL,
        motionRecordNo: parameters.MOTIONRECORDNO
      });
    },

    /**
     * 装置記録の情報をStoreにセット
     * @param {*} parameters 遷移パラメータ
     * @return 対応する装置記録を返す
     */
    async setMotionRecordToStore(machineRecord) {
      const eventRegDateTime = dayjs(machineRecord.eventRegDate);
      const motionRecord = {
        eventRegDate: eventRegDateTime.format("YYYY/MM/DD"),
        eventRegTime: eventRegDateTime.format("HH:mm:ss"),
        machineRecordMessage: machineRecord.machineRecordMessage,
        dataType: machineRecord.dataType,
        testType: machineRecord.testType,
        headerFlag: false,
        motionRecordNo: machineRecord.motionRecordNo,
        isCorrection: machineRecord.isCorrection,
        userId: machineRecord.userId,
        maxRecodeFlag: false,
        isCorrectionUpDate: machineRecord.isCorrectionUpDate,
        serviceSupportType: machineRecord.serviceSupportType,
        serviceSupportUserId: machineRecord.serviceSupportUpDate,
        serviceSupportUpDate: machineRecord.serviceSupportUserId
      }

      // 詳細情報をStoreにセット
      this.setMotionRecord(motionRecord);
    },

    /**
     * 担当施設の情報を取得
     * @param {*} facilityCd 施設コード
     * @return 該当施設が担当施設であれば施設情報を返す、担当施設でなければnullを返す
     */
    async getFacilityInfoInCharge(facilityCd) {
      await this.fetchStaffFacilities(this.getStateUserAccountInfo.userId);
      const staffFacilities = this.getStaffFacilities.filter(facility => {
        return facility.facilityCd === facilityCd && facility.isCharge === true;
      });
      if (staffFacilities.length > 0) {
        return {
          departmentCd: staffFacilities[0].departmentCd,
          facilityCd: staffFacilities[0].facilityCd,
          facilityName: staffFacilities[0].facilityName
        };
      }
      return null;
    },

    /**
     * 指示承認検索条件の設定
     * @param indication 患者ごとの指示データ
     * @param method "receive": 指示受け / "approve": 指示承認
     */
    createIndicationSearchCondition(parameters) {
      const defaultIndication = this.getDefaultSetting[INDICATION.KEY_NAME];
      const ALL = "1";
      const ISSUE_DATE = "1";

      let defIndSearchCond = {
        treatmentDateOpt: ISSUE_DATE,
        treatmentStartDate: dayjs().format("YYYY-MM-DD"),
        treatmentScheduledDate: null,
        check1: ALL,
        check2: ALL,
        approver1: ALL,
        approver2: ALL,
        createdBy: "0",
        userId: "0",
        indication: false,
        indicationList: []
      };

      // サインインユーザのデフォルト設定を設定
      if (defaultIndication) {
        // 治療日
        if (defaultIndication[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] !== undefined && defaultIndication[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] !== "") {
          defIndSearchCond.treatmentScheduledDate = calcTargetDate(defaultIndication[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE])
        }
        // 指示受け1
        if (defaultIndication[INDICATION.KEY_NAME_CHECK1] !== undefined) {
          defIndSearchCond.check1 = defaultIndication[INDICATION.KEY_NAME_CHECK1];
        }
        // 指示受け2
        if (defaultIndication[INDICATION.KEY_NAME_CHECK2] !== undefined) {
          defIndSearchCond.check2 = defaultIndication[INDICATION.KEY_NAME_CHECK2];
        }
        // 指示承認1
        if (defaultIndication[INDICATION.KEY_NAME_APPROVER1] !== undefined) {
          defIndSearchCond.approver1 = defaultIndication[INDICATION.KEY_NAME_APPROVER1];
        }
        // 指示承認2
        if (defaultIndication[INDICATION.KEY_NAME_APPROVER2] !== undefined) {
          defIndSearchCond.approver2 = defaultIndication[INDICATION.KEY_NAME_APPROVER2];
        }
        // 指示者
        if (defaultIndication[INDICATION.KEY_NAME_INSTRUCTOR_ID] !== undefined) {
          defIndSearchCond.userId = String(defaultIndication[INDICATION.KEY_NAME_USER_ID]);
        }
        // 対象指示
        if (defaultIndication[INDICATION.KEY_NAME_INDICATION_LIST] !== undefined) {
          defIndSearchCond.indicationList = defaultIndication[INDICATION.KEY_NAME_INDICATION_LIST];
        }
      }

      // パラメータよりMODE,DATEの設定
      if (parameters.DATE && parameters.DATE !== null) {
        const startDate = this.formatDate(parameters.DATE, "YYYY-MM-DD");
        if (startDate !== null) {
          defIndSearchCond.treatmentStartDate = startDate;
        }
      }

      if (parameters.MODE && parameters.MODE !== null) {
        defIndSearchCond.treatmentDateOpt = parameters.MODE;
      }

      return defIndSearchCond;
    },

    /**
     * 使用するパラメータ以外を削除
     * @param {*} parameters 遷移パラメータ
     * @param UseKeys 使用するパラメータのキー(FACILITYCD 等)の文字列配列
     * @return keys で指定したキーと以下の4つのキーを含むオブジェクトを返す
     *    FUNC, USERID, key, routerName
     */
    async removeParametersNotUsed(parameters, UseKeys) {
      let retVal = {};
      // 汎用キー
      const generalKeys = [
        "FUNC",
        "USERID",
        "key",
        "routerName"
      ];
      // 汎用キーを追加
      for (const key of generalKeys) {
        retVal[key] = parameters[key];
      }
      // 各機能で使うキーを追加
      for (const key of UseKeys) {
        retVal[key] = parameters[key];
      }
      return retVal;
    }
  }
};
