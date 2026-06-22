/**
 * 観察記録詳細 MainContent
 */
<template>
  <div class="main-content-area">
    <div class="obs-rec-det-main-area">
      <div class="obs-rec-det-main-content-area">
        <form>
          <div class="obs-rec-label" v-if="getUpdatemode">更新モード</div>
          <div class="vertical-div">
            <div class="wrap-block">
              <div class="nowrap-block kihyoubi">
                <div class="title-col obs-rec-label">
                  <div>起票日時</div>
                </div>
                <div class="data-col1 obs-rec-label">
                  <v-ons-input
                    class="data-datetime"
                    type="date"
                    input-id="rec-date-date"
                    v-model="inputData.recDateDate"
                    name="dialysis-start-date"
                    v-rules="'required|date_format:yyyy-MM-dd'"
                    @blur="resetCombo()"
                    @change="onChangeInputData"
                  />
                  <v-ons-input
                    class="data-datetime"
                    type="time"
                    input-id="rec-date-time"
                    v-model="inputData.recDateTime"
                    name="dialysis-start-time"
                    v-rules="'required|date_format:HH:mm'"
                    @change="onChangeInputData"
                  />
                </div>
              </div>
            </div>
            <div class="wrap-block">
              <div class="nowrap-block kihyousya">
                <div class="title-col obs-rec-label">
                  <div>起票者</div>
                </div>
                <div class="data-col1 obs-rec-label data-bold">{{ inputData.regStaffName }}</div>
              </div>
            </div>
            <div class="wrap-block">
              <div class="nowrap-block henkousya">
                <div class="title-col obs-rec-label">
                  <div>変更者</div>
                </div>
                <div class="data-col1 obs-rec-label data-bold">{{ inputData.upStaffName }}</div>
              </div>
              <div class="nowrap-block henkoukaisu">
                <div class="title-col obs-rec-label">
                  <div>変更回数</div>
                </div>
                <div class="data-col1 obs-rec-label data-bold">{{ inputData.upCnt }} 回</div>
              </div>
            </div>
            <div class="wrap-block">
              <div class="kousinbi"></div>
              <div class="nowrap-block kousinbi">
                <div class="title-col obs-rec-label">
                  <div>最終更新日時</div>
                </div>
                <div class="data-col1 obs-rec-label data-bold">{{ inputData.viewUpDate }}</div>
              </div>
            </div>
            <div class="nowrap-block">
              <div class="title-col obs-rec-label">
                <div>カテゴリ</div>
              </div>
              <div class="data-col1 obs-rec-label">
                <select
                  id="kind"
                  class="selectbox select-data"
                  v-bind:disabled="getUpdatemode"
                  v-model="inputData.kindNo"
                  @change="changeObserveKind()"
                >
                  <option
                    v-for="(kind, kindKey) in getObserveKinds"
                    :key="kindKey"
                    :value="kind.kindNo"
                  >{{ kind.kindName }}</option>
                </select>
              </div>
            </div>
            <div class="vertical-div">
              <div class="nowrap-block">
                <div class="title-col obs-rec-label">
                  <div>内容</div>
                </div>
                <div
                  class="data-col-full"
                  v-if="inputData.kindNo !== getSoapKindNo && inputData.kindNo !== getFdarKindNo"
                >
                  <div class="nowrap-block">
                    <div class="data-col1 data-col4">
                      <textarea
                        class="naiyou-detail-col"
                        v-model="inputData.obsRecInfo[0]"
                        @change="onChangeInputData"
                      ></textarea>
                    </div>
                  </div>
                </div>
                <div class="data-col-full" v-if="inputData.kindNo === getSoapKindNo">
                  <div
                    class="nowrap-block"
                    v-for="(detail, idx) in ['S','O','A','P']"
                    :key="detail"
                  >
                    <div class="naiyou-detail-title-col obs-rec-label">
                      <div>{{ detail }}</div>
                    </div>
                    <div class="data-col1 data-col4">
                      <textarea
                        class="naiyou-detail-col"
                        v-model="inputData.obsRecInfo[idx]"
                        @change="onChangeInputData"
                      ></textarea>
                    </div>
                  </div>
                </div>
                <div class="data-col-full" v-if="inputData.kindNo === getFdarKindNo">
                  <div
                    class="nowrap-block"
                    v-for="(detail, idx) in ['F','D','A','R']"
                    :key="detail"
                  >
                    <div class="naiyou-detail-title-col obs-rec-label">
                      <div>{{ detail }}</div>
                    </div>
                    <div class="data-col1 data-col4">
                      <textarea
                        class="naiyou-detail-col"
                        v-model="inputData.obsRecInfo[idx]"
                        style="height: 8rem; width: 100%; resize: vertical;"
                        @change="onChangeInputData"
                      ></textarea>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="nowrap-block">
              <div class="title-col title2-col obs-rec-label">
                <div>透析実績とリンク</div>
              </div>
              <div class="data-col1 data-col2">
                <div class="data-center">
                  <v-ons-switch
                    v-model="inputData.dialysisDataLinkFlag"
                    @change="onChangeInputData"
                  ></v-ons-switch>
                </div>
              </div>
            </div>
            <div class="nowrap-block">
              <div class="data-col1 data-col3">
                <div class="data-right">
                  <v-ons-select
                    id="kind"
                    class="result_ord select-data"
                    v-model="inputData.selectedOrdNo"
                    :disabled="!inputData.dialysisDataLinkFlag"
                    @change="onChangeInputData"
                  >
                    <option :value="0">(透析実績未選択)</option>
                    <option
                      v-for="(ordMain, idxOrdMain) in getComboOrdMain"
                      :key="idxOrdMain"
                      :value="ordMain.ordNo"
                    >{{ makeOrdMainComboText(ordMain) }}</option>
                  </v-ons-select>
                </div>
              </div>
            </div>
          </div>
        </form>
      </div>
      <div class="btn-area nowrap-block" style="width: 97%; ">
        <div class="denial-btn-area">
          <button class="button denial-btn" @click="cancel()">キャンセル</button>
        </div>
        <div class="registration-btn-area">
          <button class="button registration-btn" @click="registration()" :disabled="isRegistIng">登録</button>
          <button
            class="button registration-btn"
            @click="deleteData()"
            :disabled="isRegistIng || !getUpdatemode"
            style="margin-left: 0.5em;"
          >削除</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
//import { dateFormat } from "@/functions/common/DateTimeUtils.js";
import { EventBus } from "@/compat/vue/event-bus.js";
import {
  DATE_FORMAT,
  SHORT_TIME_FORMAT,
  dateFormat,
  parseDate
} from "@/functions/common/DateTimeUtils.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export const DATETIME_FORMAT = "yyyy-MM-ddThh:mm";

export default {
  data() {
    return {
      publishRanges: ["all", "individual"],
      inputData: {
        recDate: dateFormat.format(new Date(), DATETIME_FORMAT),
        recDateDate: dateFormat.format(new Date(), DATE_FORMAT),
        recDateTime: dateFormat.format(new Date(), SHORT_TIME_FORMAT),
        regStaffIdx: 0,
        regStaffName: "",
        upStaffName: "aaa",
        upCnt: 10,
        kindNo: 2,
        kind: null,
        kindClass: 2,
        obsRecInfo: ["a", "b", "c", "d"],
        kindNoBackup: 2,
        obsRecInfoBackup: ["a", "b", "c", "d"],
        bbsPublishFlag: false,
        publishDay: 3,
        selectedPublishRange: "individual",
        publishList: "linkonlinkoon",
        bbsCtlNo: 1,
        dialysisDataLinkFlag: false,
        ordNo: 1,
        selectedOrdNo: 1,
        viewUpDate: ""
      },
      errorMessage: "",
      isRegistIng: false,
      isChanged: false,
      //自画面の名称
      selfScreenName: "",
      isMovePageDialogShow: false
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("observe-record/list", [
      "getObserveRecords",
      "getObserveKinds",
      "getSoapKindNo",
      "getFdarKindNo"
    ]),
    ...mapGetters("observe-record/detail", [
      "getUpdatemode",
      "getSelectedData",
      "getRefreshCondition",
      "getComboOrdMain"
    ]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPatName"])
  },
  watch: {
    selectedPatId: function() {
      // TODO:治療実績のリストを再抽出
    }
  },
  methods: {
    ...mapActions("observe-record/list", [
      "fetchObserveRecords",
      "checkIsKindNoSoap",
      "checkIsKindNoFdar",
      "checkIsKindNoOtherKind",
      "findObserveKind",
      "setReloadSignal"
    ]),
    ...mapActions("observe-record/detail", [
      "insertPatObsRec",
      "updatePatObsRec",
      "deletePatObsRec",
      "insertBBS",
      "updateBBS",
      "fetchOrdMain",
      "resetComboOrdMain"
    ]),
    ...mapActions("account-edit", ["setIsDispSidebarBtn"]),
    isKindNoSoap(no) {
      return this.checkIsKindNoSoap(no);
    },
    isKindNoFdar(no) {
      return this.checkIsKindNoFdar(no);
    },
    isKindNoOtherKind(no) {
      return this.checkIsKindNoOtherKind(no);
    },
    changeIsMovePageDialogShow(bool) {
      this.isMovePageDialogShow = bool;
    },
    clearInputData() {
      this.inputData.recDate = dateFormat.format(new Date(), DATETIME_FORMAT);
      this.inputData.recDateDate = dateFormat.format(new Date(), DATE_FORMAT);
      this.inputData.recDateTime = dateFormat.format(
        new Date(),
        SHORT_TIME_FORMAT
      );
      this.inputData.regStaffName =
        this.getStateUserAccountInfo.userLastName +
        " " +
        this.getStateUserAccountInfo.userFirstName;
      this.inputData.upStaffName = "";
      this.inputData.upCnt = 0;
      this.inputData.kindNo = 0;
      this.inputData.kindClass = 0;
      this.inputData.obsRecInfo[0] = "";
      this.inputData.obsRecInfo[1] = "";
      this.inputData.obsRecInfo[2] = "";
      this.inputData.obsRecInfo[3] = "";
      this.inputData.kindClassBackup = 0;
      this.inputData.obsRecInfoBackup[0] = "";
      this.inputData.obsRecInfoBackup[1] = "";
      this.inputData.obsRecInfoBackup[2] = "";
      this.inputData.obsRecInfoBackup[3] = "";
      this.inputData.bbsPublishFlag = false;
      this.inputData.publishDay = 3;
      this.inputData.selectedPublishRange = "individual";
      this.inputData.publishList = "";
      this.inputData.bbsCtlNo = null;
      this.inputData.dialysisDataLinkFlag = false;
      this.inputData.ordNo = 0;
      this.inputData.selectedOrdNo = -1;
      this.inputData.viewUpDate = "";

      // 編集中フラグＯＦＦ
      this.isChanged = false;
    },
    onChangeInputData() {
      // 編集中フラグＯＮ
      this.isChanged = true;
    },
    setInputData(patObsRec) {
      this.inputData.recDate = dateFormat.format(
        new Date(patObsRec.recDate),
        DATETIME_FORMAT
      );
      this.inputData.recDateDate = dateFormat.format(
        new Date(patObsRec.recDate),
        DATE_FORMAT
      );
      this.inputData.recDateTime = dateFormat.format(
        new Date(patObsRec.recDate),
        SHORT_TIME_FORMAT
      );
      if (patObsRec.regStaffInfo != null) {
        this.inputData.regStaffName = JSON.parse(
          patObsRec.regStaffInfo
        ).reg_staff_name;
      }
      // 更新判定
      if (this.getUpdatemode === true) {
        if (patObsRec.upStaffInfo != null) {
          this.inputData.upStaffName = JSON.parse(
            patObsRec.upStaffInfo
          ).up_staff_name;
        }
      }
      this.inputData.upCnt = patObsRec.upCnt;
      this.inputData.kindNo = JSON.parse(patObsRec.kindInfo).kind_no;
      this.inputData.kindClass = JSON.parse(patObsRec.kindInfo).kind_class;
      const parsedDetail = JSON.parse(patObsRec.obsRecInfo);
      this.inputData.obsRecInfo[0] = parsedDetail.detail1;
      this.inputData.obsRecInfo[1] = parsedDetail.detail2;
      this.inputData.obsRecInfo[2] = parsedDetail.detail3;
      this.inputData.obsRecInfo[3] = parsedDetail.detail4;
      this.inputData.kindClassBackup = JSON.parse(
        patObsRec.kindInfo
      ).kind_class;
      this.inputData.obsRecInfoBackup[0] = parsedDetail.detail1;
      this.inputData.obsRecInfoBackup[1] = parsedDetail.detail2;
      this.inputData.obsRecInfoBackup[2] = parsedDetail.detail3;
      this.inputData.obsRecInfoBackup[3] = parsedDetail.detail4;
      this.inputData.bbsCtlNo = patObsRec.bbsCtlNo;
      this.inputData.ordNo = patObsRec.ordNo;
      this.inputData.selectedOrdNo = patObsRec.ordNo;
      if (0 < patObsRec.ordNo) {
        this.inputData.dialysisDataLinkFlag = true;
      }
      if (0 < patObsRec.upCnt) {
        this.inputData.viewUpDate = patObsRec.viewUpDate;
      }
    },
    /**
     * カテゴリ設定
     */
    async setObserveKind() {
      const selectedKind = await this.findObserveKind(this.inputData.kindNo);
      // 区分
      this.inputData.kindClass = selectedKind.kindClass;
      // 透析実績とのリンク
      this.inputData.dialysisDataLinkFlag = selectedKind.isLinkOrdNo === "1";
    },
    /**
     * カテゴリ変更時
     */
    async changeObserveKind() {
      // 編集中フラグＯＮ
      this.isChanged = true;
      // カテゴリ設定
      await this.setObserveKind();
    },
    async validateInputData() {
      // 登録前チェック
      // 患者IDチェック処理
      if (this.selectedPatId === null) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // this.errorMessage = "患者が未選択です";
        this.errorMessage = DIALOG_MESSAGES[12000161].message;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        return false;
      }
      // 起票日チェック処理
      //const regdate = new Date(this.inputData.recDate);
      const regdate = parseDate(
        this.inputData.recDateDate,
        this.inputData.recDateTime
      );

      if (isNaN(regdate.getTime())) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // this.errorMessage = "起票日時が不正です";
        this.errorMessage =  DIALOG_MESSAGES[12000162].message;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        return false;
      }

      if (this.inputData.dialysisDataLinkFlag) {
        if (this.inputData.selectedOrdNo <= 0) {
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // this.errorMessage = "透析実績が選択されていません";
          this.errorMessage = DIALOG_MESSAGES[12000163].message;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          return false;
        }
      }

      // スイッチが有効な場合は選択無効か登録されているオーダ番号であるチェック
      //if (this.inputData.dialysisDataLinkFlag) {
      //  if (this.inputData.ordNo > 0) {
      //    if (this.inputData.ordNo != this.inputData.selectedOrdNo) {
      //      this.errorMessage =
      //        "透析実績とリンクしたオーダ番号は変更出来ません";
      //      return false;
      //    }
      //  }
      // }

      const selectedKind = await this.findObserveKind(this.inputData.kindNo);
      // console.log(selectedKind.kindClass);
      // console.log(this.inputData.obsRecInfo[0]);
      if (selectedKind.kindClass === 0) {
        if (this.inputData.obsRecInfo[0] === "") {
          this.errorMessage = `${selectedKind.kindName}が入力されていません`;
          return false;
        }
      } else {
        if (
          this.inputData.obsRecInfo[0] === "" ||
          this.inputData.obsRecInfo[1] === "" ||
          this.inputData.obsRecInfo[2] === "" ||
          this.inputData.obsRecInfo[3] === ""
        ) {
          this.errorMessage = `${selectedKind.kindName}の一部項目が入力されていません`;
          return false;
        }
      }
      return true;
    },
    /**
     * 登録
     */
    async registration() {
      this.isRegistIng = true;

      // データチェック
      if ((await this.validateInputData()) === false) {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "確認",
          title: DIALOG_MESSAGES[12000161].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: this.errorMessage
        });
        this.isRegistIng = false;
        return false;
      }

      // 実績とのリンク判定
      let inputOrdNo = 0;
      if (this.inputData.dialysisDataLinkFlag === true) {
        // 実績番号を取得
        inputOrdNo = this.inputData.selectedOrdNo;
      }
      // 実績が変更された場合、確認のダイアログを表示する
      if (this.inputData.ordNo > 0 && this.inputData.ordNo !== inputOrdNo) {
        let checkResult = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "確認",
          title: DIALOG_MESSAGES[13000106].title,
          // message:
          //   "リンク先の透析実績が変更されています。<br>このまま登録してよろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000106].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 0) {
              checkResult = true;
            }
          }
        });
        // キャンセルの場合登録処理中断
        if (checkResult) {
          this.isRegistIng = false;
          return;
        }
      }
      this.inputData.ordNo = inputOrdNo;
      const selectedKind = await this.findObserveKind(this.inputData.kindNo);

      //const regDateText1 = this.inputData.recDate + "+09:00";
      const regDateText = parseDate(
        this.inputData.recDateDate,
        this.inputData.recDateTime
      );

      //console.log("recDate:" + this.inputData.recDate );
      // console.log("regDateText:" + regDateText);
      let chgFlg = false;

      if (this.getUpdatemode === false) {
        // 観察記録区分がその他(内容1のみ)の場合
        if (selectedKind.kindClass === 0) {
          // 内容2～4を初期化
          this.inputData.obsRecInfo[1] = "";
          this.inputData.obsRecInfo[2] = "";
          this.inputData.obsRecInfo[3] = "";
        }
        // 患者情報データを新規登録
        // 掲示板データを新規登録
        // 登録したデータを取得
        await this.insertPatObsRec({
          obsRecNo: null,
          patId: this.selectedPatId,
          facilityCd: this.getFacilityCd,
          recDate: regDateText,
          upCnt: 0,
          kindInfo: JSON.stringify({
            kind_no: selectedKind.kindNo,
            kind_name: selectedKind.kindName,
            kind_class: selectedKind.kindClass,
            kind_update: dateFormat.utc2Jst(selectedKind.upDate)
          }),
          regStaffInfo: JSON.stringify({
            reg_staff_cd: this.getStateUserAccountInfo.userId
          }),
          upStaffInfo: null,
          obsRecInfo: JSON.stringify({
            detail1: this.inputData.obsRecInfo[0],
            detail2: this.inputData.obsRecInfo[1],
            detail3: this.inputData.obsRecInfo[2],
            detail4: this.inputData.obsRecInfo[3]
          }),
          bbsCtlNo: this.inputData.bbsCtlNo,
          ordNo: this.inputData.ordNo,
          isNewest: "1",
          isDel: "0",
          fnSeqId: null
        });
      } else {
        const selectedData = this.getSelectedData;

        // 更新用に起票者名を削除する
        const regStaffInfo = JSON.parse(selectedData.patObsRec.regStaffInfo);
        delete regStaffInfo.reg_staff_name;
        selectedData.patObsRec.regStaffInfo = JSON.stringify(regStaffInfo);

        // 更新用に更新者名を削除する
        const upStaffInfo = JSON.parse(selectedData.patObsRec.upStaffInfo);
        if (upStaffInfo != null) {
          delete upStaffInfo.up_staff_name;
          selectedData.patObsRec.upStaffInfo = JSON.stringify(upStaffInfo);
        }

        const updateResult = await this.updatePatObsRec({
          obsRecNo: null,
          patId: selectedData.patObsRec.patId,
          facilityCd: selectedData.patObsRec.facilityCd,
          recDate: regDateText,
          upCnt: selectedData.patObsRec.upCnt + 1,
          kindInfo: JSON.stringify({
            kind_no: selectedKind.kindNo,
            kind_name: selectedKind.kindName,
            kind_class: selectedKind.kindClass,
            kind_update: dateFormat.utc2Jst(selectedKind.upDate)
          }),
          regStaffInfo: selectedData.patObsRec.regStaffInfo,
          upStaffInfo: JSON.stringify({
            up_staff_cd: this.getStateUserAccountInfo.userId
          }),
          obsRecInfo: JSON.stringify({
            detail1: this.inputData.obsRecInfo[0],
            detail2: this.inputData.obsRecInfo[1],
            detail3: this.inputData.obsRecInfo[2],
            detail4: this.inputData.obsRecInfo[3]
          }),
          bbsCtlNo: this.inputData.bbsCtlNo,
          ordNo: this.inputData.ordNo,
          isNewest: "1",
          isDel: "0",
          fnSeqId: this.inputData.fnSeqId,
          regDate: selectedData.patObsRec.regDate
        });
        if (updateResult < 0) {
          this.setReloadSignal(true);

          if (updateResult === -2) {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message:
              //   "他のユーザーによって既に更新されています。</br>観察記録情報を登録できませんでした。"
              title: DIALOG_MESSAGES[12000164].title,
              message: messageFormat(DIALOG_MESSAGES[12000164].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          } else {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message: "観察記録情報を登録できませんでした。"
              title: DIALOG_MESSAGES[12000165].title,
              message: messageFormat(DIALOG_MESSAGES[12000165].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
          this.isRegistIng = false;
          return;
        }
      }
      this.setReloadSignal(true);

      // 成功なので、アラート表示
      await this.$ons.notification.alert({
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // title: "登録成功",
        // message: "観察記録情報が</br>正常に登録されました。"
        title: DIALOG_MESSAGES[12000166].title,
        message: messageFormat(DIALOG_MESSAGES[12000166].message)
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      });
      // 編集中フラグＯＦＦ
      this.isChanged = false;

      this.isRegistIng = false;
      this.$router.go(-1);

      chgFlg = true;
      // 登録完了の通知更新
      EventBus.$emit("reloadObserveRecord", chgFlg);
    },
    /**
     * 削除
     */
    async deleteData() {
      this.isRegistIng = true;
      let deleteResult;
      let chgFlg = false;
      const selectedData = this.getSelectedData;
      // 更新用に起票者名を削除する
      const regStaffInfo = JSON.parse(selectedData.patObsRec.regStaffInfo);
      delete regStaffInfo.reg_staff_name;
      selectedData.patObsRec.regStaffInfo = JSON.stringify(regStaffInfo);
      // 更新用に更新者名を削除する
      const upStaffInfo = JSON.parse(selectedData.patObsRec.upStaffInfo);
      if (upStaffInfo != null) {
        delete upStaffInfo.up_staff_name;
        selectedData.patObsRec.upStaffInfo = JSON.stringify(upStaffInfo);
      }

      // TODO: 確認メッセージを表示

      // 確認のダイアログを表示する
      await this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "削除",
        title: DIALOG_MESSAGES[13000107].title,
        // message: "観察記録情報を削除します。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000107].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer == 1) {
            //OK
            deleteResult = this.deletePatObsRec();
          } else {
            // 観察記録を削除しない
            deleteResult = -3;
          }
        }
      });

      if (deleteResult < 0) {
        if (deleteResult === -2) {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "削除失敗",
            // message:
            //   "他のユーザーによって既に更新されています。</br>観察記録情報を削除できませんでした。"
            title: DIALOG_MESSAGES[12000167].title,
            message: messageFormat(DIALOG_MESSAGES[12000167].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        } else if (deleteResult !== -3) {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "削除失敗",
            // message: "観察記録情報を削除できませんでした。"
            title: DIALOG_MESSAGES[12000168].title,
            message: messageFormat(DIALOG_MESSAGES[12000168].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
        this.isRegistIng = false;
        return;
      }
      this.setReloadSignal(true);

      // 成功なので、アラート表示
      await this.$ons.notification.alert({
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // title: "削除成功",
        // message: "観察記録情報が</br>削除されました。"
        title: DIALOG_MESSAGES[12000322].title,
        message: messageFormat(DIALOG_MESSAGES[12000322].message)
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      });

      this.isRegistIng = false;
      // 編集中フラグＯＦＦ
      this.isChanged = false;
      this.$router.go(-1);

      chgFlg = true;
      // 登録完了の通知更新
      EventBus.$emit("reloadObserveRecord", chgFlg);
    },
    /**
     * コンボボックスの再設定
     */
    async resetCombo() {
      // スイッチが有効な場合は選択無効か登録されているオーダ番号であるチェック
      if (this.inputData.recDateDate !== "") {
        this.inputData.selectedOrdNo = 0;
        const regdate = parseDate(this.inputData.recDateDate, "00:00");
        if (isNaN(regdate.getDate())) {
          return;
        }
        await this.fetchOrdMain({
          patId: this.selectedPatId,
          treatDate: `${regdate.getFullYear()}${(
            "00" + (regdate.getMonth() + 1).toString()
          ).slice(-2)}${("00" + regdate.getDate().toString()).slice(-2)}`,
          ordNo: this.inputData.ordNo
        });
        this.inputData.selectedOrdNo = this.inputData.ordNo;
        // 編集中フラグＯＮ
        this.isChanged = true;
      }
    },
    /**
     * キャンセル
     */
    cancel() {
      // TODO: 編集破棄確認
      this.$router.go(-1);
    },
    makeOrdMainComboText(ordMain) {
      let ret = "";
      if (ordMain.rstDialysisState === "0") {
        ret =
          `${ordMain.viewTreatDate}` +
          " 予定 " +
          `${ordMain.indKurName} ${ordMain.indBedName} ${ordMain.indTreatmentName}`;
      } else {
        ret =
          `${ordMain.viewTreatDate}` +
          " 実績 " +
          `${ordMain.rstKurName} ${ordMain.rstBedName} ${ordMain.rstTreatmentName}`;
      }
      return ret;
    },
    dataLoad() {
      this.clearInputData();

      if (this.getUpdatemode === true) {
        this.setInputData(this.getSelectedData.patObsRec);
      } else {
        // カテゴリ初期選択
        const kinds = this.getObserveKinds;
        if (kinds != null) {
          this.inputData.kindNo = kinds[0].kindNo;
          this.inputData.kindClass = kinds[0].kindClass;
          this.inputData.kindNoBackup = kinds[0].kindNo;
        }
        // 観察記録区分設定
        this.setObserveKind();
      }
      //console.log("patid:" + this.patId + "/recDate:" + this.inputData.recDate);
      //this.fetchOrdMain(this.patId, this.inputData.recDate);
      const dt = new Date(this.inputData.recDate);
      // 患者番号と治療日付にて検索
      this.fetchOrdMain({
        patId: this.selectedPatId,
        treatDate: `${dt.getFullYear()}${(
          "00" + (dt.getMonth() + 1).toString()
        ).slice(-2)}${("00" + dt.getDate().toString()).slice(-2)}`,
        ordNo: this.inputData.ordNo
      });
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する

      if (
        this.selfScreenName === this.$route.name &&
        !this.isMovePageDialogShow
      ) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
             // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.dataLoad();
              }
            }
          });
        } else {
          this.dataLoad();
        }
      }
    }
  },
  created() {
    this.dataLoad();

    // 画面名称取得
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    // サイドメニューを閉じる
    EventBus.$emit("forceCloseSideBar");
    // サイドメニュー、サイドメニュー開閉ボタンを非表示化
    this.setIsDispSidebarBtn(false);
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);

    // サイドメニュー展開ボタン表示
    this.setIsDispSidebarBtn(true);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.obs-rec-det-main-area {
  height: calc(100% - 5px);
}
.popoverFilterLabel {
  margin-left: -5px;
  margin-right: 7px;
  font-size: 1.6em;
}
.obs-rec-det-main-content-area {
  overflow: hidden;
  height: calc(100% - 35px);
  overflow-y: auto;
}
.btn-area {
  /* position: absolute; */
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
}
.cancel-button {
  margin-right: 1rem;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
  flex-basis: 100%;
}
.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}
.title-col {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  width: 8rem;
  margin-right: 0.2rem;
  margin-bottom: 0.3rem;
  font-size: 1.6em;
}
.title2-col {
  width: 12rem;
}
.data-bold {
  font-weight: bold;
}
.data-datetime {
  font-size: 0.6em;
}
.naiyou-detail-title-col {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-right: 0.2rem;
  margin-bottom: 0.3rem;
  width: 1rem;
  font-size: 1.5em;
}
.naiyou-detail-col {
  font-size: 1.1em;
  height: 8rem;
  width: 100%;
  resize: vertical;
}
.data-col1 {
  font-size: 1.6em;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  flex-basis: auto;
  width: auto;
  margin-left: 0.5rem;
  margin-right: 0.2rem;
  margin-bottom: 0.3rem;
}
.data-col2 {
  width: 16rem;
}
.data-col3 {
  width: 25rem;
}
.data-col4 {
  width: 100%;
}
.data-col-full {
  width: 80%;
}
.data-center {
  margin-left: auto;
  margin-right: auto;
}
.data-right {
  margin-left: auto;
  margin-right: 0;
}
.radio-col {
  border: solid 1px #999;
  width: auto;
}
.kihyoubi,
.kihyousya,
.henkousya,
.henkoukaisu,
.kousinbi {
  flex-basis: 20rem;
  /* flex-basis: 40%; */
}
.select-data {
  font-size: 1em;
}

input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
input[type="checkbox"] {
  display: none; /* チェックボックスを非表示にする */
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 100%;
  font-size: 1.5em;
}
.label:hover {
  background-color: #0076ff; /* マウスオーバー時の背景色を指定する */
}
/* 周知先の「全体」「個別」部分の選択した時の背景色 */
.syuutisaki:checked + label {
  background: #0076ff;
}
.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 3.5rem; /* ボックスの横幅を指定する */
  height: 2em;   /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  background-color: #76b3f9; /* 背景色を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
}
.first-of-type {
  border-radius: 1.6rem 0 0 1.6rem;
  margin-left: 0.5rem;
}
.last-of-type {
  border-radius: 0 1.6rem 1.6rem 0;
  margin-right: 0.5rem;
}
</style>
