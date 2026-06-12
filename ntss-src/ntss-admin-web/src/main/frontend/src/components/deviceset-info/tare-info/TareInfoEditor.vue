<!-- 風袋 -->
<template>
  <div>
    <base-editor v-if="propsTableFlag != 1"
      ref="baseEditor"
      v-bind="settingData"
      @show-message="showMessage"
      @hide-modal="hideModal"
    />
    <base-editor-for-device-set v-else
      ref="baseEditor"
      v-bind="settingData"
      @show-message="showMessage"
      @hide-modal="hideModal"
    />
  </div>
</template>
<script>
import BaseTareAndOffWaterInfoEditor from "@/components/deviceset-info/base-modules/BaseTareAndOffWaterInfoEditor";
import BaseTareForDeviceSet from "@/components/deviceset-info/base-modules/BaseTareAndOffWaterInfoForDeviceSet";
import DeviceSetOwnerMixin from "@/components/deviceset-info/base-modules/DeviceSetOwnerMixin";
// mod FNSI-連携イベントの登録適正化 楊 start
import {mapActions, mapGetters} from "@/compat/vue/vuex";

// del #11004 連携イベント発生部分不正 piao end

export default {
  mixins: [DeviceSetOwnerMixin],
  components: {
    "base-editor": BaseTareAndOffWaterInfoEditor,
    "base-editor-for-device-set": BaseTareForDeviceSet
  },

  props: {
    /**
     * オーダー番号
     */
    propsOrdNo: {
      type: Number,
      default: null
    },
    /**
     * 患者ID
     */
    propsPatId: {
      type: Number,
      default: null
    },
    /**
     * 施設コード
     */
    propsFacilityCd: {
      type: String,
      default: null
    },
    /**
     * テーブルフラグ
     */
    propsTableFlag: {
      type: Number,
      required: true
    }
  },

  data() {
    return {
      // del #11004 連携イベント発生部分不正 piao start
      // objModSendClass: "",
      // del #11004 連携イベント発生部分不正 piao end
      settingData: {
        propsOrdNo: this.propsOrdNo,
        propsPatId: this.propsPatId,
        propsFacilityCd: this.propsFacilityCd,
        propsTableFlag: this.propsTableFlag,
        propsTareOffWaterInfoFlag: 0
      }
    };
  },

  created() {
    // 親のスタイル修正
    this._deviceSetDialogOwner().styleObj = { "max-width": "500px", width: "100%" };
  },
  // mod FNSI-連携イベントの登録適正化 楊 start
  computed: {
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-info", ["selectedPat"]),
  },
  // mod FNSI-連携イベントの登録適正化 楊 end
  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // del #11004 連携イベント発生部分不正 piao start
    // /**
    //  * @description MODIFY_SEND_CLASS取得
    //  */
    // async getSchModifySendClass() {
    //   let retVal = 0;
    //   const prmfacilityCd = this.propsFacilityCd;
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
     * 変更チェック
     */
    checkEdit(num) {
      // キャンセルボタンクリック時チェック
      if (1 === num) {
        // 変更箇所があれば変更を破棄するか確認メッセージを表示
        if (this.$refs.baseEditor.checkEdit()) {
          this.showMessage(20010001, "2");
          return true;
        }
      } else {
        // 保存ボタンクリック時チェック
        // 変更箇所がなければ警告メッセージを表示
        if (!this.$refs.baseEditor.checkEdit()) {
          this.showMessage(23020001, "1");
          return true;
        }
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isEdit() {
      return this.$refs.baseEditor?.isEdit() ?? false;
    },
    async resetComponentIndData(structData) {
      await this.$refs.baseEditor?.resetComponentIndData(structData);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    /**
     * 更新処理(指示)
     */
    async updateIndInfo(structData) {
      //add #10266  start
      structData.update_flag = this.settingIndData.update_flag;
      //add #10266  end
      // 1つの治療予定限定時に未編集チェックを実施
      if (
        this._deviceSetDialogOwner().settingData.startDateEdit &&
        this._deviceSetDialogOwner().settingData.endDateEdit
      ) {
        if (this.checkEdit()) {
          return;
        }
      }
      console.log("TareInfoEditor.vue.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 子で更新用関数を呼ぶ
      // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
      //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
      // this._compatSet(structData, "opeCd", "004030");
      // this._compatSet(structData, "crud", "U");
      // this._compatSet(structData, "facilityCd", this.propsFacilityCd);
      // this._compatSet(structData, "hospPatId", this.selectedPat.pat_personal_main.hosp_pat_id);
      // this._compatSet(structData, "patId", this.selectedPat.pat_personal_main.pat_id);
      // this._compatSet(structData, "ordNo", this.settingIndData.ordNo);
      // this._compatSet(structData, "baseDate", "");
      // this._compatSet(structData, "indUser", this.getStateUserAccountInfo.userId);
      //add by ztc 2023-02-27 [Optimize runtime No.5482] --end
      // del 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      await this.$refs.baseEditor.updateInfo(structData);

      //upd by ztc 2023-02-27 [Optimize runtime No.5482] --start region
      // mod FNSI-連携イベントの登録適正化 楊 start
      // 古いリスト
      // const startDate = structData.indStartDate.replace(/-/g, '');
      // const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      // const searchData = await ApiHelper.get(
      //   `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      // ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        // getErrorMessage('TareInfoEditor.vue', 'updateIndInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // throw error;
      // });
      // this.oldOrdMainList = searchData.data;

      // const params = {
      //   ope_cd: "004030",
      //   crud: "U",
        // mod FNSI-連携イベントの登録適正化 李 start
        // facility_cd: this.facilityCd,
        // facility_cd: this.propsFacilityCd,
        // mod FNSI-連携イベントの登録適正化 李 end
        // hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
        // pat_id: this.selectedPat.pat_personal_main.pat_id,
        // ord_no: this.settingIndData.ordNo,
        // base_date: "",
        // user_id: this.getStateUserAccountInfo.userId
      // };
      // if (this.settingIndData.ordNo) {
        // 変更対象クールが未登録ではないの場合、外部連携APIを呼び出す
        // if (this.oldOrdMainList[0].indKurCd !== null && this.oldOrdMainList[0].indKurCd !== 0) {
        //   createJournal({...params, base_date: this.oldOrdMainList[0].treatDate});
        // }
      // } else {
      //   if (this.oldOrdMainList) {
      //     this.oldOrdMainList.forEach(item => {
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
      //upd by ztc 2023-02-27 [Optimize runtime No.5482] --end endregion
      // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      // // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
      // const startDate = structData.indStartDate.replace(/-/g, '');
      // const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      // const searchData = await ApiHelper.get(
      //   `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      // ).catch(error => {
      //   getErrorMessage('TareInfoEditor.vue', 'updateIndInfo', error);
      //   console.log("TareInfoEditor.vue updateIndInfo throw error; this.finishLoadingScreen();");
      //   this.finishLoadingScreen();
      //   throw error;
      // });
      // this.oldOrdMainList = searchData.data;
      //
      // let modSendClass = await this.getSchModifySendClass();
      //
      // if (this.oldOrdMainList) {
      //   let journalList = [];
      //   if (this.settingIndData.ordNo) {
      //     //変更対象クールが未登録ではないの場合、外部連携APIを呼び出す
      //     if (this.oldOrdMainList[0].indKurCd !== null && this.oldOrdMainList[0].indKurCd !== 0) {
      //       if (modSendClass == 2) {
      //         //MODIFY_SEND_CLASS=2 削除、新規
      //         journalList.push({
      //           ope_cd: "004030",
      //           crud: "D",
      //           facility_cd: this.propsFacilityCd,
      //           hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //           pat_id: this.selectedPat.pat_personal_main.pat_id,
      //           ord_no: this.settingIndData.ordNo,
      //           base_date: this.oldOrdMainList[0].treatDate,
      //           user_id: this.getStateUserAccountInfo.userId
      //         });
      //         journalList.push({
      //           ope_cd: "004030",
      //           crud: "C",
      //           facility_cd: this.propsFacilityCd,
      //           hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //           pat_id: this.selectedPat.pat_personal_main.pat_id,
      //           ord_no: this.settingIndData.ordNo,
      //           base_date: this.oldOrdMainList[0].treatDate,
      //           user_id: this.getStateUserAccountInfo.userId
      //         });
      //         createJournalList(journalList);
      //       } else {
      //         //MODIFY_SEND_CLASS=0 or 1 更新
      //         journalList.push({
      //           ope_cd: "004030",
      //           crud: "U",
      //           facility_cd: this.propsFacilityCd,
      //           hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //           pat_id: this.selectedPat.pat_personal_main.pat_id,
      //           ord_no: this.settingIndData.ordNo,
      //           base_date: this.oldOrdMainList[0].treatDate,
      //           user_id: this.getStateUserAccountInfo.userId
      //         });
      //         createJournalList(journalList);
      //       }
      //     }
      //   } else {
      //     if (this.oldOrdMainList) {
      //       this.oldOrdMainList.forEach(item => {
      //         const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //         const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //         if (structData.selectedKur.length > 0) {
      //           if (isSelectedKur) {
      //             if (item.indKurCd !== null && item.indKurCd !== 0) {
      //               if (modSendClass == 2) {
      //                 //MODIFY_SEND_CLASS=2 削除、新規
      //                 journalList.push({
      //                   ope_cd: "004030",
      //                   crud: "D",
      //                   facility_cd: this.propsFacilityCd,
      //                   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                   pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                   ord_no: item.ordNo,
      //                   base_date: item.treatDate,
      //                   user_id: this.getStateUserAccountInfo.userId
      //                 });
      //                 journalList.push({
      //                   ope_cd: "004030",
      //                   crud: "C",
      //                   facility_cd: this.propsFacilityCd,
      //                   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                   pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                   ord_no: item.ordNo,
      //                   base_date: item.treatDate,
      //                   user_id: this.getStateUserAccountInfo.userId
      //                 });
      //               } else {
      //                 //MODIFY_SEND_CLASS=0 or 1 更新
      //                 journalList.push({
      //                   ope_cd: "004030",
      //                   crud: "U",
      //                   facility_cd: this.propsFacilityCd,
      //                   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                   pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                   ord_no: item.ordNo,
      //                   base_date: item.treatDate,
      //                   user_id: this.getStateUserAccountInfo.userId
      //                 });
      //               }
      //             }
      //           }
      //         } else {
      //           if (structData.selectedTreat.length > 0) {
      //             if (isSelectedTreat) {
      //               if (item.indKurCd !== null && item.indKurCd !== 0) {
      //                 if (modSendClass == 2) {
      //                   //MODIFY_SEND_CLASS=2 削除、新規
      //                   journalList.push({
      //                     ope_cd: "004030",
      //                     crud: "D",
      //                     facility_cd: this.propsFacilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                   journalList.push({
      //                     ope_cd: "004030",
      //                     crud: "C",
      //                     facility_cd: this.propsFacilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                 } else {
      //                   //MODIFY_SEND_CLASS=0 or 1 更新
      //                   journalList.push({
      //                     ope_cd: "004030",
      //                     crud: "U",
      //                     facility_cd: this.propsFacilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                 }
      //               }
      //             }
      //           } else {
      //             if (item.indKurCd !== null && item.indKurCd !== 0) {
      //               if (modSendClass == 2) {
      //                 //MODIFY_SEND_CLASS=2 削除、新規
      //                 journalList.push({
      //                   ope_cd: "004030",
      //                   crud: "D",
      //                   facility_cd: this.propsFacilityCd,
      //                   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                   pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                   ord_no: item.ordNo,
      //                   base_date: item.treatDate,
      //                   user_id: this.getStateUserAccountInfo.userId
      //                 });
      //                 journalList.push({
      //                   ope_cd: "004030",
      //                   crud: "C",
      //                   facility_cd: this.propsFacilityCd,
      //                   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                   pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                   ord_no: item.ordNo,
      //                   base_date: item.treatDate,
      //                   user_id: this.getStateUserAccountInfo.userId
      //                 });
      //               } else {
      //                 //MODIFY_SEND_CLASS=0 or 1 更新
      //                 journalList.push({
      //                   ope_cd: "004030",
      //                   crud: "U",
      //                   facility_cd: this.propsFacilityCd,
      //                   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                   pat_id: this.selectedPat.pat_personal_main.pat_id,
      //                   ord_no: item.ordNo,
      //                   base_date: item.treatDate,
      //                   user_id: this.getStateUserAccountInfo.userId
      //                 });
      //               }
      //             }
      //           }
      //         }
      //       });
      //       createJournalList(journalList);
      //     }
      //   }
      // }
      // // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
      console.log("TareInfoEditor.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    /**
     * 更新処理(装置設定デフォルトマスタ、患者情報)
     */
    async updateInfo() {
      // 編集がされていなければ、警告メッセージを表示し以降の処理を行わない
      // mod FNSI-改修内容何も編集されていない場合、保存ボタンを押下した後、メッセージ「何も編集されていません」が表示する 趙 start
      // if (this.checkEdit()) {
      //   return;
      // }
      if (this.checkEdit()) {
        return;
      }
      // mod FNSI-改修内容何も編集されていない場合、保存ボタンを押下した後、メッセージ「何も編集されていません」が表示する 趙 end
      // 子で更新用関数を呼ぶ
      await this.$refs.baseEditor.updateInfo();
    },

    /**
     * 指示:反映対象に更新処理
     */
    reflectIndInfo() {
      this.$refs.baseEditor.reflectOrdMainInfo();
    },

    /**
     * 患者情報に装置設定デフォルトマスタで編集した内容を反映
     */
    async reflectPatInfo() {
      await this.$refs.baseEditor.updatePatInfoDefault();
    },

    /**
     * 指示情報に患者情報で編集した内容を反映
     */
    async reflectFutureOrdMain() {
      await this.$refs.baseEditor.updateFutureIndTareAndOffWaterInfo();
    },

    // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
    // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
    // async doCreateJournal() {
    //   await this.$refs.baseEditor.doCreateJournal();
    // },
    // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
    // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end

    /**
     * 指示:反映対象に更新をするかメッセージ表示
     */
    showReflectIndInfoMessage() {
      this.$refs.baseEditor.showReflectOrdMainMessage();
    },

    /**
     * 警告メッセージ表示
     */
    showAlertIndInfoMessage() {
      this.$refs.baseEditor.showAlertOrdMain();
    },

    /**
     * 親でメッセージ表示を行う
     * @param code メッセージコード
     * @param type メッセージタイプ
     * @param stringParamsList メッセージ置換文字列
     * @param targetName メッセージ表示対象名 ex.FUTURE_ORD_MAIN(未来指示)
     */
    showMessage(code, type, stringParams, targetName) {
      // メッセージコードを格納
      this._deviceSetDialogOwner().messageDialogInfo.messageCd = code;
      // メッセージタイプを格納
      this._deviceSetDialogOwner().messageDialogInfo.type = type;
      // メッセージ置換文字列を格納
      this._deviceSetDialogOwner().messageDialogInfo.stringParams =
        undefined !== stringParams ? stringParams : [];
      // メッセージ表示対象名を格納
      this._deviceSetDialogOwner().messageDialogInfo.targetName = targetName;
      // メッセージを表示
      setTimeout(() => {
        this._deviceSetDialogOwner().messageDialogInfo.isDialogVisible = true;
      }, 10);
    },

    /**
     * モーダルを閉じる
     */
    hideModal() {
      this._hideDeviceSetModal();
    }
  }
};
</script>

<style></style>
