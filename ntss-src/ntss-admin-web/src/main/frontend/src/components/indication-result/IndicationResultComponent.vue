/**
 * 予実リストの親コンポーネント
 */
<template>
  <div>
    <div class="filter-area">
      <div @click="isConditonVisible = !isConditonVisible">
        <div class="color-header search-header">表示条件</div>
      </div>
      <div class="filter-content-area" v-show="isConditonVisible">
        <!-- mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start -->
        <!-- <condition-component @search="onSearch" @filter="onFilter" @switch="onSwitch" :pattern="this.switchOrder" /> -->
        <condition-component
          @search="onSearch"
          @filter="onFilter"
          @switch="onSwitch"
          @screenSizeChanges="onScreenSizeChanges"
          :pattern="this.switchOrder"
        />
        <!-- mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end -->
      </div>
    </div>
    <div class="tree-view-area">
      <div class="color-header tree-view-header-area">
        <div style="margin-right: 0.5em;"> {{ hospPatId }} </div>
        <div>
          <div :class="inOutClass == '1' ? 'pat-name-in-hospital' : ''" style="margin-right: 0.5em; word-break: break-all;">
            {{ patName }}
            <img class='same-icon' v-show="isSame === '1'" :src="image_src_same" />
          </div>
        </div>
      </div>
      <order-list-component class="tree-view-content-area" :order-list="this.indRstList" :filter="this.filter" :pattern="this.switchOrder" />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";

import { IndicationResult } from "@/models/indication-result/IndicationResult";
import { PatientEventResult } from "@/models/indication-result/PatientEventResult";
import { InspectionScheduleResult } from "@/models/indication-result/InspectionScheduleResult";
import { InspectionResult } from "@/models/indication-result/InspectionResult";
import { PrescriptionResult } from "@/models/indication-result/PrescriptionResult";
import ConditionComponent from "@/components/indication-result/IndicationConditionComponent";
import OrderListComponent from "@/components/indication-result/OrderListComponent";
//add nkk-3760検査依頼の個別登録、削除をした際に画面に表示される患者が1人になる 張岩 start
import {sendRequestPatExamMain } from "@/apis/exam-request";
//add nkk-3760検査依頼の個別登録、削除をした際に画面に表示される患者が1人になる 張岩 end
// add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
// import { ApiHelper } from "@/apis/AxiosHelper";
// import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
import {deepCopy} from "@/functions/common/CommonFunctions";
import {getDeadlineDate} from "@/functions/common/DateTimeUtils";
import {SAVED} from "@/constants/examRequestConstants";
import dayjs from "@/compat/date/dayjs";
// mod FNSI-7217 バッチ操作インターフェイスを追加します 查 start
// import {sendRequestGetMstFacilitySettingValue} from "@/apis/facility-setting";
import {sendRequestGetMstFacilitySettingValueMap} from "@/apis/facility-setting";
// mod FNSI-7217 バッチ操作インターフェイスを追加します 查 end
import {EXAM_DEADLINE, EXAM_DEADLINE_DATE_COUNT, EXAM_DEADLINE_TIME_COUNT} from "@/constants/facilitySetting";
import nameDuplicationImg from "@/assets/name_duplication.png";
import { getFooterMenuClientHeight, queryElementBySelectors } from "@/functions/common/LayoutMeasureHelper";

// add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end
import {toSlashDate} from "@/functions/exam-request/ExamRequestFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";

export default {
  components: {
    "condition-component": ConditionComponent,
    "order-list-component": OrderListComponent
  },

  data() {
    return {
      indRstList: [],
      filter: {
        result: true,
        indication: true,
        pastIndication: false,
        // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
        // マルチコントロールコントロールで選択する値(true: 選択、false: 選択しない)
        // 患者イベント
        patEvent: false,
        // 検査結果
        inspectionResult: false,
        // 検査予定
        inspectionSchedule: false,
        // 一般撮影検査予定
        genPhoto: false,
        // 処方
        prescription: false
        // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
      },
      switchOrder: 1,
      isConditonVisible: true,
      //同姓同名アイコン
      image_src_same: nameDuplicationImg,
      patId: ""
    }
  },

  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("indication-result", ["getDispPattern"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu"
    }),
    ...mapGetters("pat-info", [
      "selectedPat",
      "selectedPatName"
    ]),

    /**
     * @description 患者選択フラグ
     */
    isPatSelected() {
      return this.selectedPat !== null;
    },
    /**
     * @description 病院内患者ID
     */
    hospPatId() {
      return this.isPatSelected
        ? this.selectedPat.pat_personal_main["hosp_pat_id"]
        : "";
    },
    /**
     * @description 表示する患者名
     */
    patName() {
      return this.isPatSelected
        ? this.selectedPatName
        : "";
    },
    /**
     * @description 同姓同名
     */
    isSame() {
      return this.isPatSelected
        ? this.selectedPat.pat_main["is_same"]
        : "0";
    },
    /**
     * @description 院内フラグ
     */
    inOutClass() {
      return this.isPatSelected
        ? this.selectedPat.pat_personal_main["in_out_class"]
        : "0";
    }
  },

  methods: {
    ...mapActions("indication-result", [
      "getIndicationResultList",
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // 患者イベント画面集計のデータ
      "getPatientEventResultList",
      // 検査セットIDで、検査項目取得
      "getObtainedInspectionItems",
      // 検査結果画面集計のデータ
      "getInspectionResultList",
      // 一般撮影検査予定画面集計のデータ
      "getGenPhotoInsResultList",
      // 処方画面集計のデータ
      "getPrescriptionResultList"
    ]),
    //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen", "resetLoadingScreenVisibleCount"]),
    //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

    /**
     * 予実リストを検索する.
     */
    async onSearch(param) {
      if (!param.patId) {
        this.indRstList = [];
        return;
      }
      // mod 7196【デグレ】予実リストの日付を変更しても変更した期間で再抽出が行われない 周安寧 start
      // if (this.patId === param.patId) {
      //   return;
      // } else {
      //   this.patId = param.patId;
      // }
      if (this.patId !== param.patId) {
        this.patId = param.patId;
      }
      // mod 7196【デグレ】予実リストの日付を変更しても変更した期間で再抽出が行われない 周安寧 end
      const condition = {
        "treat_date_from": param.treatDateFrom,
        "treat_date_to": param.treatDateTo
      };

      // del FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // Promise.all([
      //   this.getIndicationResultList({ patId: param.patId, condition: condition })
      // ]).then(responses => {
      //   const tmpList = [];

      //   // 血液浄化情報取得
      //   Array.prototype.push.apply(tmpList, responses[0].data.map(e => {
      //     return this.createIndicationResult(e);
      //   }));

      //   // 予実リスト設定
      //   this.indRstList = tmpList;
      // });
      // del FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // すべての画面が集計されたデータ
      let applyTreeData = [];

      // 画面集計情報検索条件
      const searchCondition = {
        // 治療日FROM
        'treat_date_from': param.treatDateFrom,
        // 治療日TO
        'treat_date_to': param.treatDateTo,
        // 患者ID
        'pat_id': param.patId
      };

      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --start */
      const settingNos = [EXAM_DEADLINE, EXAM_DEADLINE_DATE_COUNT, EXAM_DEADLINE_TIME_COUNT];
      // 患者経過総合ビューア画面集計のデータ
      // const patViewResponsesData = await this.getIndicationResultList({patId: param.patId, condition: condition});
      this.startLoadingScreen();
      //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
      try {
        const [
        patViewResponsesData,
        patEventResponsesData,
        response,
        facilitySettingValueResponseData,
        inspectionResponsesData,
        genPhotoResponsesData,
        prescriptionResponsesData
      ] = await Promise.all([
        this.getIndicationResultList({patId: param.patId, condition: condition}),
        this.getPatientEventResultList({condition: searchCondition}),
        sendRequestPatExamMain({
          //mod nkk-3760検査依頼の個別登録、削除をした際に画面に表示される患者が1人になる 張岩 end
          "patIdList": [param.patId],
          "startDate": "",
          "endDate": toSlashDate(param.treatDateTo)
        }),
        sendRequestGetMstFacilitySettingValueMap(this.getFacilityCd, settingNos),
        this.getInspectionResultList({condition: searchCondition}),
        this.getGenPhotoInsResultList({condition: searchCondition}),
        this.getPrescriptionResultList({condition: searchCondition})
      ]);
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --end */
      // 患者経過総合ビューアデータがあるの場合
      if (patViewResponsesData && patViewResponsesData.data) {
        const tmpList = [];

        // 血液浄化情報取得
        Array.prototype.push.apply(tmpList, patViewResponsesData.data.map(e => {
          return this.createIndicationResult(e);
        }));

        // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
        tmpList.forEach(item => {
            if (item.treatmentName === "治療方法削除済み") {
              item.treatmentName = item.treatmentNameMst;
              // ApiHelper.get("/mainData/getMstTreatmentNameByCd/" + item.treatmentCd).then(
              //   response => {
              //     if (response.data) {
              //       if (item.indRstTypeName === "【予定】") {
              //         // 削除の治療方法名取得するの場合、【削除済み】＋ 倫理削除されたマスタの表示内容を表示
              //         item.treatmentName = MASTER_DELETE_DISPLAY.DELETED + response.data;
              //       } else if (item.indRstTypeName === "【実績】") {
              //         // 削除の治療方法名取得するの場合、倫理削除されたマスタの表示内容を表示
              //         item.treatmentName = response.data;
              //       }
              //     }
              //   }
              // );
            }

            if (item.bedName === "ベッド削除済み") {
              item.bedName = item.bedNameMst;
              // ApiHelper.get("/mainData/getMstBedNameByCd/" + item.bedCd).then(
              //   response => {
              //     if (response.data) {
              //       if (item.indRstTypeName === "【予定】") {
              //         // 削除のベッド名取得するの場合、【削除済み】＋ 倫理削除されたマスタの表示内容を表示
              //         item.bedName = MASTER_DELETE_DISPLAY.DELETED + response.data;
              //       } else if (item.indRstTypeName === "【実績】") {
              //         // 削除のベッド名取得するの場合、倫理削除されたマスタの表示内容を表示
              //         item.bedName = response.data;
              //       }
              //     }
              //   }
              // );
            }

            if (item.kurName === "クール削除済み") {
              item.kurName = item.kurNameMst;
              // ApiHelper.get("/mainData/getMstKurNameByCd/" + item.kurCd).then(
              //   response => {
              //     if (response.data) {
              //       if (item.indRstTypeName === "【予定】") {
              //         // 削除のクール名取得するの場合、【削除済み】＋ 倫理削除されたマスタの表示内容を表示
              //         item.kurName = MASTER_DELETE_DISPLAY.DELETED + response.data;
              //       } else if (item.indRstTypeName === "【実績】") {
              //         // 削除のクール名取得するの場合、倫理削除されたマスタの表示内容を表示
              //         item.kurName = response.data;
              //       }
              //     }
              //   }
              // );
            }
          }
        )
        // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end

        // 予実リスト設定
        Array.prototype.push.apply(applyTreeData, tmpList);
      }

      // 患者イベント画面集計
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --start */
      // const patEventResponsesData = await this.getPatientEventResultList({condition: searchCondition});
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --end */
      // 患者イベント画面集計データがあるの場合
      if (patEventResponsesData && patEventResponsesData.data) {
        // データクラス対象化する
        const patientEventList = patEventResponsesData.data.map(e => {
          return this.createPatientEventResult(e);
        })

        // 予実リスト設定(患者イベント)
        patientEventList.forEach(item => {
          // 患者イベント集計データ判断用
          item.type = 'pat_event';

          // イベント開始日とイベント終了同じ日場合
          if (item.event_start_date == item.event_end_date) {
            // 日付フォーマット
            item.eventStartTime = this.insertStr(item.eventStartTime, 2, null, ':');
            item.eventEndTime = this.insertStr(item.eventEndTime, 2, null, ':');
            // イベント開始日とイベント終了同じ日ではない場合
          } else {
            // 日付フォーマット
            item.eventStartTime = this.insertStr(item.eventStartTime, 2, null, ':');
            // イベント終了時刻をNull設定する
            item.eventEndTime = null;
          }
          // イベント開始日フォーマット
          item.treatDate = this.insertStr(item.eventStartDate, 4, 6, '/');

          // 予実リスト設定
          Array.prototype.push.apply(applyTreeData, [item]);
        });
      }

      // 横軸の日付リスト
      let dateList = {};
      response.data.examDateList.forEach(function (examDate) {
        dateList[examDate] = 0;
      });

      // 編集状態の日付リスト
      let editDateList = {};
      response.data.examDateList.forEach(function (examDate) {
        editDateList[examDate] = 1;
      });

      // 検査依頼リスト(データ操作用JSON配列)作成
      let ListObj = [];
      [param.patId].forEach(function (id) {
        ListObj.push({
          "patId": id,
          // ディープコピーで日付リストを追加
          "data": JSON.parse(JSON.stringify(dateList)),
          "editStatus": JSON.parse(JSON.stringify(editDateList)),
          // 検査セットのリスト
          // 1:透析前 2:透析後 0:その他 の順で表示
          "examItemSet": {
            "1": {},
            "2": {},
            "0": {}
          }
        });
      });

      let deadlineCondition = {
        deadlineFlg: false,
        deadlineDateCount: 0,
        deadlineTimeCount: ""
      };

      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --start */
      // mod FNSI-7217 バッチ操作インターフェイスを追加します 查 start
      // const settingNos = [EXAM_DEADLINE, EXAM_DEADLINE_DATE_COUNT, EXAM_DEADLINE_TIME_COUNT];
      // await sendRequestGetMstFacilitySettingValueMap(this.getFacilityCd, settingNos).then(response => {
      if (facilitySettingValueResponseData && facilitySettingValueResponseData.data) {
        // 検査締切有無
        deadlineCondition.deadlineFlg = response.data[EXAM_DEADLINE] === 1 ? true : false;

        // 検査依頼変更締切り日数
        deadlineCondition.deadlineDateCount = response.data[EXAM_DEADLINE_DATE_COUNT];

        // 検査依頼変更締切り時間
        let rtnTime = '00:00';
        const chkStr = "^(?:(?:[0-2][0-3])|(?:[0-1][0-9])):[0-5][0-9]$";
        const strResponse = String(response.data[EXAM_DEADLINE_TIME_COUNT]);
        if (strResponse.match(chkStr)) {
          rtnTime = strResponse.slice(0, 2) + ':' + strResponse.slice(2, 4);
        }
        deadlineCondition.deadlineTimeCount = rtnTime;
      }
      // });
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --end */

      /*
      // 検査締切有無
      await sendRequestGetMstFacilitySettingValue(this.getFacilityCd, EXAM_DEADLINE).then(response => {
        deadlineCondition.deadlineFlg = response.data === 1 ? true : false;
      });
      // 検査依頼変更締切り日数
      await sendRequestGetMstFacilitySettingValue(this.getFacilityCd, EXAM_DEADLINE_DATE_COUNT).then(response => {
        deadlineCondition.deadlineDateCount = response.data;
      });
      // 検査依頼変更締切り時間
      await sendRequestGetMstFacilitySettingValue(this.getFacilityCd, EXAM_DEADLINE_TIME_COUNT).then(response => {
        let rtnTime = '00:00';
        const chkStr = "^(?:(?:[0-2][0-3])|(?:[0-1][0-9])):[0-5][0-9]$";
        const strResponse = String(response.data);
        if (strResponse.match(chkStr)) {
          rtnTime = strResponse.slice(0, 2) + ':' + strResponse.slice(2, 4);
        }
        deadlineCondition.deadlineTimeCount = rtnTime;
      });
      */
      // mod FNSI-7217 バッチ操作インターフェイスを追加します 查 end

      // 締切が有効な場合、締め切り日を取得する
      let deadlineDate = null;
      if (deadlineCondition.deadlineFlg) {
        deadlineDate = getDeadlineDate(deadlineCondition);
      }
      var selectSetCd = [];
      // データを集計
      response.data.patExamMains.forEach(function (data) {
        const jsonObj = JSON.parse(data.orderExamSetInfo);
        let targetObj = ListObj.filter(function (item) {
          if (item.patId == data.patId) return true;
        })[0];
        // 日付の合計
        var unSelectNum = 0;
        jsonObj.forEach(function (obj) {
          if (selectSetCd[data.strExamDate + "+" + data.regOrderClass + "+" + data.patId] == undefined) {
            selectSetCd[data.strExamDate + "+" + data.regOrderClass + "+" + data.patId] = [];
          }
          if (selectSetCd[data.strExamDate + "+" + data.regOrderClass + "+" + data.patId][obj.set_cd] == undefined) {
            selectSetCd[data.strExamDate + "+" + data.regOrderClass + "+" + data.patId][obj.set_cd] = true;
            unSelectNum += 1;
          }
        });
        targetObj["data"][data.strExamDate] += unSelectNum;
        // 検査セットを追加
        jsonObj.forEach(function (obj) {
          if (targetObj["examItemSet"][data.regOrderClass][obj.set_cd] === void 0) {
            targetObj["examItemSet"][data.regOrderClass][obj.set_cd] = {
              "name": obj.set_name,
              "data": {},
              "status": {},
              "isLock": {}
            };
          }
          // フラグを入れる
          targetObj["examItemSet"][data.regOrderClass][obj.set_cd]["data"][data.strExamDate] = SAVED;
          targetObj["examItemSet"][data.regOrderClass][obj.set_cd]["status"][data.strExamDate] = data.examStatus;
          // 締切フラグ
          if (deadlineCondition.deadlineFlg) {
            if (dayjs(deadlineDate).isAfter(dayjs(data.strExamDate))) {
              // 締切を過ぎている
              targetObj["examItemSet"][data.regOrderClass][obj.set_cd]["isLock"][data.strExamDate] = "1";
            } else {
              // 締切を過ぎていない
              targetObj["examItemSet"][data.regOrderClass][obj.set_cd]["isLock"][data.strExamDate] = "0";
            }
          } else {
            // 締切が無効な場合は取得データを入れる
            targetObj["examItemSet"][data.regOrderClass][obj.set_cd]["isLock"][data.strExamDate] = data.isLock;
          }
        });
      });
      let showDataObj = [];
      ListObj.forEach(function (obj) {
        // ヘッダ(患者名)
        showDataObj.push({
          "headerflg": true,
          "patId": obj.patId,
          // examItemSet(前、後、その他)毎の数の合計 + 1
          "rowspan": Object.keys(obj.examItemSet[0]).length + Object.keys(obj.examItemSet[1]).length + Object.keys(obj.examItemSet[2]).length + 1,
          "examData": obj.data,
          "editStatus": obj.editStatus,
        });
        let maeKeyList = null;
        // 検査セット分(前)
        maeKeyList = Object.keys(obj.examItemSet[1]);
        maeKeyList.forEach(function (key) {
          showDataObj.push({
            "headerflg": false,
            "patId": obj.patId,
            "examSetCd": key,
            "examSetName": obj.examItemSet[1][key]["name"],
            "regOrderClass": "1",
            "examData": obj.examItemSet[1][key]["data"],
            "examStatus": obj.examItemSet[1][key]["status"],
            "nowIsLock": obj.examItemSet[1][key]["isLock"]
          });
        });
        // 検査セット分(後)
        maeKeyList = Object.keys(obj.examItemSet[2]);
        maeKeyList.forEach(function (key) {
          showDataObj.push({
            "headerflg": false,
            "patId": obj.patId,
            "examSetCd": key,
            "examSetName": obj.examItemSet[2][key]["name"],
            "regOrderClass": "2",
            "examData": obj.examItemSet[2][key]["data"],
            "examStatus": obj.examItemSet[2][key]["status"],
            "nowIsLock": obj.examItemSet[2][key]["isLock"]
          });
        });
        // 検査セット分(他)
        maeKeyList = Object.keys(obj.examItemSet[0]);
        maeKeyList.forEach(function (key) {
          showDataObj.push({
            "headerflg": false,
            "patId": obj.patId,
            "examSetCd": key,
            "examSetName": obj.examItemSet[0][key]["name"],
            "regOrderClass": "0",
            "examData": obj.examItemSet[0][key]["data"],
            "examStatus": obj.examItemSet[0][key]["status"],
            "nowIsLock": obj.examItemSet[0][key]["isLock"]
          });
        });
      });
      // 検査予定画面情報があるの場合
      if (showDataObj && showDataObj.length > 0) {
        let inspectionScheduleList = null;
        // 患者IDによるデータスクリーニング
        inspectionScheduleList = showDataObj.filter(element =>
          element.patId == param.patId && !element.headerflg
        );
      // mod 6057 修正 chen end
        //  患者IDによるデータスクリーニングデータがあるの場合
        if (inspectionScheduleList && inspectionScheduleList.length > 0) {
          let examSetCd = [];
          inspectionScheduleList.forEach(item => {
            // 検査セットID取得
            examSetCd.push(item.examSetCd);
          });

          // 検査セットIDで、項目数取得
          const responsesData = await this.getObtainedInspectionItems({condition: examSetCd});

          // 項目数があるの場合
          if (responsesData && responsesData.data) {
            // 予定項目の取得
            let examStatistics = {};

            // mod bug 6277 修正 chen start
            await this.inspectionScheduleListChange(inspectionScheduleList, responsesData, param, examStatistics);
            // mod bug 6277 修正 chen end

            // 時間順に並べる
            let sortExamStatistics = [];
            Object.keys(examStatistics).sort((firValue, secValue) => {
              return secValue - firValue
            }).forEach(key => {
              let pushObj = {treatDate: key, count: examStatistics[key]};
              sortExamStatistics.push(pushObj);
            });

            // 日付フォーマット
            sortExamStatistics.forEach(item => {
              item.treatDate = this.insertStr(item.treatDate, 4, 6, '/');
              item.type = 'in_schedule';
            });

            // データクラス対象化する
            const examStatisticsData = sortExamStatistics.map(e => {
              return this.createInspectionScheduleResult(e)
            });

            // 予実リスト設定
            Array.prototype.push.apply(applyTreeData, examStatisticsData);
          }
        }
      }
      // 検査結果画面集計
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --start */
      // const inspectionResponsesData = await this.getInspectionResultList({condition: searchCondition})
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --end */
      // 検査結果画面集計データがあるの場合
      if (inspectionResponsesData && inspectionResponsesData.data) {
        // 検査結果数量と日付取得
        let inspectionResultList = [];
        // 検査時間に合わせて重くする
        Array.from(new Set(inspectionResponsesData.data.map(eo => eo.event_start_date))).forEach(et => {
          // その日のデータを洗い出す
          let dataFilterList = inspectionResponsesData.data.filter(es => es.event_start_date == et);
          // 検査情報取得
          let jsonList = [];
          dataFilterList.forEach(e => {
            Array.prototype.push.apply(jsonList, JSON.parse(e.json_value));
          })
          // bug 4063 add by maxueqaing begin
          jsonList = jsonList.filter(item => {
            return null != item.result && '' != item.result
          })
          // bug 4063 add by maxueqaing end
          // console.log("jsonList is :",JSON.stringify(jsonList));
          const checkNum = Array.from(new Set(jsonList.map(item => item.item_cd))).length;
          if (checkNum > 0) {
            inspectionResultList.push({
              // 日付フォーマット
              'treatDate': this.insertStr(et, 4, 6, '/'),
              // 検査結果数量
              'count': checkNum,
              'type': 'in_result'
            });
          }
        })

        // データクラス対象化する
        const inspectionResultData = inspectionResultList.map(e => {
          return this.createInspectionResult(e);
        });

        // 予実リスト設定
        Array.prototype.push.apply(applyTreeData, inspectionResultData);
      }

      // 一般撮影検査予定画面集計
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --start */
      // const genPhotoResponsesData = await this.getGenPhotoInsResultList({condition: searchCondition})
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --end */
      // 一般撮影検査予定画面情報があるの場合
      if (genPhotoResponsesData && genPhotoResponsesData.data) {
        let photoResultList = [];
        // 予実リスト(一般撮影検査予定)情報取得
        genPhotoResponsesData.data.forEach(item => {
          let filterResultList = JSON.parse(item.json_value);
          photoResultList.push({
            // 日付フォーマット
            'treatDate': this.insertStr(item.event_start_date, 4, 6, '/'),
            // 検査結果数量
            'count': filterResultList.length,
            'type': 'in_photo'
          });
        })

        // データクラス対象化する
        const photoResultData = photoResultList.map(e => {
          return this.createInspectionResult(e);
        });

        // 予実リスト設定
        Array.prototype.push.apply(applyTreeData, photoResultData);
      }

      // 処方画面集計
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --start */
      // const prescriptionResponsesData = await this.getPrescriptionResultList({condition: searchCondition})
      /* modify by chamaojia 2022-10-26 [7217] 一括要求に変更  --end */
      let prescriptionResultList = [];
      // 一般撮影検査予定画面情報があるの場合
      if (prescriptionResponsesData && prescriptionResponsesData.data) {
        // 予実リスト(一般撮影検査予定)情報取得
        prescriptionResponsesData.data.forEach(itemo => {
          let filterResultList = [];
          if (itemo.json_value) {
            filterResultList = JSON.parse(itemo.json_value).filter(itemt =>
              itemt.type == '1' && itemt.F1
            );
          }

          prescriptionResultList.push({
            'ordPrescriptionNo': itemo.unique_serial,
            'prescriptionDetail': filterResultList,
            'prescriptionType': itemo.prescription_type == '1' ? '院外' : '院内',
            'issueState': itemo.issue_state == '0' ? '未交付' : '交付済',
            // 日付フォーマット
            'treatDate': this.insertStr(itemo.event_start_date, 4, 6, '/'),
            // 検査結果数量
            'count': filterResultList.length,
            'type': 'prescription'
          });
        })

        // データクラス対象化する
        const prescriptionResultData = prescriptionResultList.map(e => {
          return this.createPrescriptionResult(e);
        });

        // 予実リスト設定
        Array.prototype.push.apply(applyTreeData, prescriptionResultData);
      }

        // データバインディング
        this.indRstList = applyTreeData;
        // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
      } catch (error) {
        getErrorMessage('IndicationResultComponent.vue','onSearch',error);
        // カウント不整合で閉じないケースを強制収束
        this.resetLoadingScreenVisibleCount();
        this.internalServerError(error);
        return;
      } finally {
        this.finishLoadingScreen();
      }
      //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end
    },
    //add #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
    internalServerError(error) {
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
    },
    //add #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end

    // add bug 6277 修正 chen start
    /**
     * 検査項目に対応する項目数を検査情報に加えます
     */
    inspectionScheduleListChange(inspectionScheduleList, responsesData, param, examStatistics) {
      // 検査項目に対応する項目数を検査情報に加えます
      inspectionScheduleList.forEach(item => {
        for (let key in responsesData.data) {
          if (key == item.examSetCd) {
            let inspectionSchedules = JSON.parse(responsesData.data[key]);
            let items = [];
            item.checkNmm = inspectionSchedules.length;
            inspectionSchedules.forEach(inspectionSchedule => {
              items.push(inspectionSchedule.exam_item_cd + "," + item.regOrderClass);
            });
            item.values = items;
            break;
          }
        }
      });

      // 検査大項目に対応する検査詳細項目集計
      inspectionScheduleList.forEach(item => {
        for (let key in item.examData) {
          if (key >= param.treatDateFrom && key <= param.treatDateTo) {
            if (examStatistics[key]) {
              // examStatistics[key] += item.checkNmm;
              item.values.forEach(inspectionSchedule => {
                if (!examStatistics[key].includes(inspectionSchedule)) {
                  examStatistics[key].push(inspectionSchedule);
                }
              });
            } else {
              // examStatistics[key] = item.checkNmm;
              examStatistics[key] = deepCopy(item.values);
            }
          }
        }
      });

      for (let key in examStatistics) {
        examStatistics[key] = examStatistics[key].length;
      }
    },
    // add bug 6277 修正 chen end

    /**
     * 予実リストをフィルタする.
     */
    onFilter(param) {
      this.filter = param;
    },

    getTreeViewContentAreaElement() {
      return queryElementBySelectors(['.tree-view-content-area'], this.$el || null);
    },
    applyTreeViewContentHeight(offset = 19) {
      const treeViewContentArea = this.getTreeViewContentAreaElement();
      if (!treeViewContentArea) {
        return;
      }
      const wh = this.windowHeight;
      const tableTop = treeViewContentArea.getBoundingClientRect().top;
      const fmh = (this.isDispMenu === 1 ? getFooterMenuClientHeight(this.$el || null) : 0);
      treeViewContentArea.style.height = (wh - tableTop - fmh - offset) + 'px';
    },
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    // 画面サイズ計算が変化する
    onScreenSizeChanges() {
      // mod FNSI-性能を最適化する 李 start
      this.$nextTick(() => {
        this.applyTreeViewContentHeight(19);
        // mod FNSI-FutreNetWeb+SI課題管理No.3823 李 end
      });

      // setTimeout(() => {
      //   const wh = this.windowHeight;
      //   const tableTop = document.getElementsByClassName("tree-view-area")[0].getBoundingClientRect().top;
      //   const fmh =
      //     (this.isDispMenu === 1
      //       ? getFooterMenuClientHeight(this.$el || null)
      //       : 0);

      //   document.getElementsByClassName("tree-view-area")[0].style.height = (wh - tableTop - fmh - 25) + "px";
      // }, 100);
      // mod FNSI-性能を最適化する 李 end
    },
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

    /**
     * オーダー一覧を切り替える.
     */
    onSwitch(param) {
      this.switchOrder = param;
    },

    /**
     * 予実データモデル生成.
     */
    createIndicationResult(e) {
      return new IndicationResult(
        e.ord_no,
        e.category,
        e.ind_rst_type,
        e.treatment_cd,
        e.treatment_date,
        e.treatment_name,
        e.kur_cd,
        e.kur_name,
        e.kur_start_time,
        e.start_date,
        e.end_date,
        e.bed_name
        // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
        , e.bed_cd
        , e.treatment_name_mst
        , e.bed_name_mst
        , e.kur_name_mst
        // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end
      );
    },

    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    // 患者イベント(データクラス対象化する用)
    createPatientEventResult(e) {
      return new PatientEventResult(
        e.unique_serial,
        e.category_name,
        e.event_end_date,
        e.event_end_time,
        e.event_start_date,
        e.event_start_time,
        e.sub_category_name
      );
    },

    // 検査予定(データクラス対象化する用)
    createInspectionScheduleResult(e) {
      return new InspectionScheduleResult(
        e.title,
        e.count,
        e.pattern,
        e.treatDate,
        e.type
      );
    },

    // 検査結果、一般撮影検査予定(データクラス対象化する用)
    createInspectionResult(e) {
      return new InspectionResult(
        e.count,
        e.pattern,
        e.treatDate,
        e.type
      );
    },

    // 処方(データクラス対象化する用)
    createPrescriptionResult(e) {
      return new PrescriptionResult(
        e.ordPrescriptionNo,
        e.prescriptionDetail,
        e.count,
        e.issueState,
        e.prescriptionType,
        e.treatDate,
        e.type
      );
    },

    /**
     * 文字列に文字を挿入する
     * @param {*} oldStr 元の文字列
     * @param {*} startIndex キャラクターが挿入される位置1
     * @param {*} endIndexTwo キャラクターが挿入される位置2
     * @param {*} insertStr 挿入する文字
     */
    insertStr(oldStr, startIndex, endIndexTwo, insertStr) {
      if (!oldStr) return '';
      if (endIndexTwo)
        return oldStr.slice(0, startIndex) +
          insertStr +
          oldStr.slice(startIndex, endIndexTwo) +
          insertStr +
          oldStr.slice(endIndexTwo);
      else
        return oldStr.slice(0, startIndex) + insertStr + oldStr.slice(startIndex);
    }
  },
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

  watch: {
    isConditonVisible() {
      // mod FNSI-性能を最適化する 李 start
      this.$nextTick(() => {
        this.applyTreeViewContentHeight(25);
      });

      // setTimeout(() => {
      //   const wh = this.windowHeight;
      //   const tableTop = document.getElementsByClassName("tree-view-area")[0].getBoundingClientRect().top;
      //   const fmh =
      //     (this.isDispMenu === 1
      //       ? getFooterMenuClientHeight(this.$el || null)
      //       : 0);
      //   document.getElementsByClassName("tree-view-area")[0].style.height = (wh - tableTop - fmh - 25) + "px";
      // }, 100);
      // mod FNSI-性能を最適化する 李 end
    },

    selectedPatId(){
      if (this.selectedPatId === null) {
        this.clearSearchedPatList();
        this.search();
      }
    }
  },

};
</script>

<style scoped>
.filter-area {
  display: block;
  margin: 0;
}

.filter-content-area,
.tree-view-content-area {
  display: flex;
  width: inherit;
  /* add FNSI-FutreNetWeb+SI課題管理No.3823 李 start */
  /* padding: .5em 1.0em .7em; */
  padding: .5em 1.0em .2em;
  /* add FNSI-FutreNetWeb+SI課題管理No.3823 李 start */
  border: solid 1px rgb(138, 138, 138);
  border-radius: 5px;
}
/***#9846 start */
.filter-content-area .condition{
  max-width: 100%;
}
.filter-content-area :deep(.grid-container){
  max-width: 100%;
}
/***#9846 end */

.filter-content-area {
  margin-bottom: 0.5em;
/* del 6463 文字サイズ：特大の際にレイアウトが崩れる 周安寧 start */
/* overflow-x: auto;*/
/* del 6463 文字サイズ：特大の際にレイアウトが崩れる 周安寧 end */
  border-radius: 0px 0px 5px 5px;
}
.tree-view-content-area {
  overflow: auto;
  border-radius: 0px 0px 5px 5px;
}

.tree-view-header-area {
  display: flex;
  flex-wrap: wrap;
  height: fit-content;
}

.search-header {
  text-align: left;
}

.same-icon{
  position: relative;
  top: 0.25em;
  height: 1.3em;
}
:deep(.k-legacy-multiselect input.k-input) {
  width: 49px !important;
}
</style>
