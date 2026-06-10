import {CODES} from "@/constants/TreatmentRecord";
import {
  CONDITION_ITEM_NAMES,
  MERGE_ITEM_TYPES,
  ResultMergeItem
} from "@/models/treatment-record/result-merge/ResultMergeItem";
import {DATE_TIME_FORMAT, dateFormat} from "@/functions/common/DateTimeUtils";
import moment from 'moment';
/**
 * 実績マージ画面の実績マージ情報を表現するクラス.
 */
export class ResultMerge {
  constructor(ordMain, mstMedicine, mstEquipment, mstDialyzer) {
    this.ordMain = ordMain;
    this.selected = false;
    this.tareInfo = ordMain.rst_tare_info
      ? JSON.parse(ordMain.rst_tare_info)
      : {};
    this.offWaterInfo = ordMain.rst_off_water_info
      ? JSON.parse(ordMain.rst_off_water_info)
      : {};
    this.mediInfo = ordMain.rst_medi_info
      ? JSON.parse(ordMain.rst_medi_info)
      : [];
    this.equipInfo = ordMain.rst_equip_info
      ? JSON.parse(ordMain.rst_equip_info)
      : [];
    this.punctureUserInfo = ordMain.rst_puncture_user_info
      ? JSON.parse(ordMain.rst_puncture_user_info)
      : {};
    this.returnUserInfo = ordMain.rst_return_user_info
      ? JSON.parse(ordMain.rst_return_user_info)
      : {};
    this.chargeUserInfo = ordMain.rst_charge_user_info
      ? JSON.parse(ordMain.rst_charge_user_info)
      : {};
    //add FNSI修正486改修 房 start
    this.condInfo = ordMain.rst_cond_info
      ? JSON.parse(ordMain.rst_cond_info)
      : {};
    this.commentInfo = ordMain.rst_ind_comment_info
      ? JSON.parse(ordMain.rst_ind_comment_info)
      : {};
    this.weightInfo = ordMain.rst_weight_info
      ? JSON.parse(ordMain.rst_weight_info)
      : {};
    this.rstDw = ordMain.rst_dw;
    //add FNSI修正486改修 房 end
    this.mstMedicine = mstMedicine;
    this.mstEquipment = mstEquipment;
    this.mstDialyzer = mstDialyzer;
  }

  /**
   * オーダ番号.
   */
  get ordNo() {
    return this.ordMain.ord_no;
  }

  /**
   * 治療状況.
   */
  get dialysisState() {
    return this.ordMain.rst_dialysis_state;
  }

  /**
   * 治療方法.
   */
  get treatmentName() {
    return this.ordMain.rst_treatment_name;
  }

  /**
   * ベッド名.
   */
  get bedName() {
    return this.ordMain.rst_bed_name;
  }

  /**
   * 患者ID.
   */
  get patId() {
    return this.ordMain.pat_id;
  }

  /**
   * 院内表示用の患者ID.
   */
  get hospPatId() {
    return this.ordMain.hosp_pat_id;
  }

  /**
   * 患者名.
   */
  get patName() {
    return this.ordMain.pat_name;
  }

  /**
   * 治療開始日時.
   */
  get startDate() {
    return this.getDateTimeString(this.ordMain.rst_start_date);
  }

  /**
   * 治療終了日時.
   */
  get endDate() {
    return this.getDateTimeString(this.ordMain.rst_end_date);
  }

  /**
   * マージ対象アイテム配列を取得する.
   */
  getItems() {
    const indexes = [1, 2, 3, 4, 5];

    // 風袋補正
    const tareInfoItems = indexes
      .map(e => {
        return new ResultMergeItem(
          MERGE_ITEM_TYPES["TARE_INFO_BEFORE_" + e],
          this.getNameAndWeight(this.tareInfo.before, e)
        );
      })
      .concat(
        new ResultMergeItem(
          MERGE_ITEM_TYPES.TARE_INFO_BEFORE_WHEEL_CHAIR,
          this.getWheelCharNameAndWeight(this.tareInfo.before),
          this.tareInfo.before ? this.tareInfo.before.wheel_chair_cd : null
        )
      )
      .concat(
        indexes.map(e => {
          return new ResultMergeItem(
            MERGE_ITEM_TYPES["TARE_INFO_AFTER_" + e],
            this.getNameAndWeight(this.tareInfo.after, e)
          );
        })
      )
      .concat(
        new ResultMergeItem(
          MERGE_ITEM_TYPES.TARE_INFO_AFTER_WHEEL_CHAIR,
          this.getWheelCharNameAndWeight(this.tareInfo.after),
          this.tareInfo.after ? this.tareInfo.after.wheel_chair_cd : null
        )
      );

    // 除水補正
    const offWaterItems = indexes.map(e => {
      return new ResultMergeItem(
        MERGE_ITEM_TYPES["OFF_WATER_INFO_" + e],
        this.getNameAndWeight(this.offWaterInfo, e)
      );
    });

    //mod FNSI修正486改修 房 start
    // 治療条件情報
    let conditionInfoDetails = [];
    for (let i = 0; i < 38; i++) {
      let outText = "";
      let condAvailable = false;
      const condNo = i + 1;
      if (this.condInfo != null && this.condInfo.hasOwnProperty((condNo) + "")) {
        /* modify by chamaojia 2024-02-18 [10196] displayed name and unit processing  --start */
        switch (condNo) {
          case 2:   // VA
          case 5:   // ダイアライザ
          case 6:   // 吸着カラム
          case 7:   // 1次膜
          case 8:   // 2次膜
          case 9:   // 穿刺針(A)
          case 10:  // 穿刺針(V)
          case 11:  // 穿刺針(SN)
          case 12:  // シングルニードル
          case 13:  // 血液回路
          case 15:  // 透析液
          case 19:  // 補液
          case 21:  // 補液選択
          case 25:  // 抗凝固剤
          case 29:  // IP使用選択
          case 30:  // IPスタート
          case 34:  // IPワンショットスタート
          case 35:  // IP電源自動切り
          case 37:  // IP電源OKモニタ切り
            // Translated name needs to be displayed
            if (this.condInfo[condNo].value_name_1 != undefined && this.condInfo[condNo].value_name_1 != null) {
              outText = this.condInfo[condNo].value_name_1
            }
            break;
          case 36:  // IP電源自動切り時間
          case 38:  // IP電源OKモニタ切り時間
            // Additional string prefix needed
            outText = this.condInfo[condNo].value != null ? "透析終了" + this.condInfo[condNo].value + this.condInfo[condNo].unit : "";
            break;
          default:
            outText = `${this.condInfo[condNo].value != null ? this.condInfo[condNo].value : ""}
                ${(this.condInfo[condNo].value != null && this.condInfo[condNo].unit != null) ? this.condInfo[condNo].unit : ""}`
            break;
        }
        /* modify by chamaojia 2024-02-18 [10196] displayed name and unit processing  --end */
      }
      // #10344 condNo doesn't exist means not available in mst
      else {
        condAvailable = true;
      }

      conditionInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "治療条件情報明細",
          displayname: CONDITION_ITEM_NAMES[i],
          properties: null,
          property: `${condNo}`,
        },
        outText,
        i,
        condAvailable,
        [],
        1
      ))
    }
    // 治療条件情報の一部項目の表示順を変更 (#12478対応)
    if (conditionInfoDetails.length >= 34) {
      const ipAmount           = conditionInfoDetails[30]; // IPワンショット量
      const ipFlowRate         = conditionInfoDetails[31]; // IP速度
      const ipFlowRateLimit    = conditionInfoDetails[32]; // IP速度最大値
      const ipOneshotSelection = conditionInfoDetails[33]; // IPワンショットスタート

      // [IP速度, IP速度最大値, IPワンショットスタート, IPワンショット量]の順に並び替え
      conditionInfoDetails.splice(30, 4, ipFlowRate, ipFlowRateLimit, ipOneshotSelection, ipAmount);
    }

    // 投与薬剤情報の明細
    let mediInfoDetails = [];
    if (this.mediInfo != undefined && this.mediInfo.length > 0) {
      mediInfoDetails = this.mediInfo.map((e) => {
        let tempdata = undefined;
        if (this.mstMedicine != undefined) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //tempdata = this.mstMedicine.filter(m => m.medicineType === e.medicine_type && m.medicineCd === e.cd)[0]
          tempdata = this.mstMedicine.filter(m => m.medicineType == e.medicine_type && m.medicineCd === e.cd)[0]
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        }
        let mediName = "";
        if (tempdata != undefined) {
          mediName = tempdata.medicineName;
        }
        return new ResultMergeItem(
          MERGE_ITEM_TYPES.MEDI_INFO_DETAIL,
          `${mediName} ${e.amount} ${e.unit != null ? e.unit : ""}`,
          e.no,
          false,
          [],
          2,
        );
      });
    }

    // 医療材料情報の明細
    let equipInfoDetails = [];
    if (this.equipInfo != undefined && this.equipInfo.length > 0) {
      equipInfoDetails = this.equipInfo.map((e) => {
        let equipName = "";
        let tempdata = undefined;
        if (e.equip_type === 0) {
          // 医療材料
          if (this.mstEquipment != undefined) {
            tempdata = this.mstEquipment.filter(eq => eq.equipmentCd === e.cd)[0];
          }
          if (tempdata != undefined) {
            equipName = tempdata.equipmentName;
          }
        } else if (e.equip_type === 1) {
          // ダイアライザ
          if (this.mstDialyzer != undefined) {
            tempdata = this.mstDialyzer.filter(eq => eq.dialyzerCd === e.cd)[0];
          }
          if (tempdata != undefined) {
            equipName = tempdata.modelNumber;
          }
        }
        return new ResultMergeItem(
          MERGE_ITEM_TYPES.EQUIP_INFO_DETAIL,
          `${equipName} ${e.amount} ${e.unit != null ? e.unit : ""}`,
          e.cd,
          false,
          [],
          2
        );
      });
    }

    // 指示コメントの明細
    let commentInfoDetails = [];
    if (this.commentInfo != undefined && this.commentInfo.length > 0) {
      this.commentInfo.map((e)=>{
        commentInfoDetails.push(new ResultMergeItem(
          MERGE_ITEM_TYPES.IND_COMMENT_INFO_DETAIL,
          `${e.content}`,
          e.no,
          false,
          [],
          2
        ));
      })
    }

    // 体重情報明細
    let weightInfoDetails = [];
    weightInfoDetails.push(new ResultMergeItem(
      {
        subdetail: true,
        name: "体重情報明細",
        displayname: "DW",
        properties: ["rst_dw"]
      },
      `${this.rstDw != null ? this.rstDw + "kg" : ""}`,
      1,
      false,
      []
    ));
    if (this.weightInfo != undefined && this.weightInfo != null) {
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細",
          displayname: "前体重",
          base_property: "rst_weight_info",
          properties: ["weight_measure_before","weight_before","weight_before_date"]
        },
        `${this.weightInfo['weight_before'] != undefined ? this.weightInfo['weight_before'] + "kg" : ""}`,
        0,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        MERGE_ITEM_TYPES.WEIGHT_INFO_CTR_DETAIL,
        `${this.weightInfo['ctr'] != undefined ? this.weightInfo['ctr'] + "%" : ""}`,
        2,
        false,
        [],
        1,
        2
      ));
      weightInfoDetails.push(new ResultMergeItem(
        MERGE_ITEM_TYPES.WEIGHT_INFO_CTR_DETAIL,
        `${this.weightInfo['ctr_measure_date'] != null ? dateFormat.format(new Date(this.weightInfo['ctr_measure_date']), "yyyy/MM/dd") : ''}`,
        3,
        false,
        [],
        1,
        0
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "目標除水量",
          base_property: "rst_weight_info",
          properties: ["water_removal_target"]
        },
        `${this.weightInfo['water_removal_target'] != undefined ? this.weightInfo['water_removal_target'] + "L" : ""}`,
        4,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "実績除水量",
          base_property: "rst_weight_info",
          properties: ["water_removal_rst","add_total"]
        },
        `${this.weightInfo['water_removal_rst'] != undefined ? this.weightInfo['water_removal_rst'] + "L" : ""}`,
        5,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "減少量",
          base_property: "rst_weight_info",
          properties: ["weight_decreased"]
        },
        `${this.weightInfo['weight_decreased'] != undefined ? this.weightInfo['weight_decreased'] + "kg" : ""}`,
        6,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "補液量積算",
          base_property: "rst_weight_info",
          properties: ["add_water_total"]
        },
        `${this.weightInfo['add_water_total'] != undefined ? this.weightInfo['add_water_total'] + "L" : ""}`,
        7,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "I-HDF引き残し",
          base_property: "rst_weight_info",
          properties: ["ihdf_pll"]
        },
        `${this.weightInfo['ihdf_pll'] != undefined ? this.weightInfo['ihdf_pll'] + "L" : ""}`,
        8,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "後体重",
          base_property: "rst_weight_info",
          properties: ["weight_measure_after", "weight_after", "weight_after_date"]
        },
        `${this.weightInfo['weight_after'] != undefined ? this.weightInfo['weight_after'] + "kg" : ""}`,
        9,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "Kt/V測定値",
          base_property: "rst_weight_info",
          properties: ["kt_v_measure"]
        },
        `${this.weightInfo['kt_v_measure'] != undefined ? this.weightInfo['kt_v_measure'] : ""}`,
        10,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細1",
          displayname: "URR",
          base_property: "rst_weight_info",
          properties: ["urr"]
        },
        `${this.weightInfo['urr'] != undefined ? this.weightInfo['urr'] + "%" : ""}`,
        11,
        false,
        []
      ));

      // 再循環率
      let rtInfos = this.weightInfo['recrcl_rt'];
      for (let i = 1; i <= 5; i++) {
        if (rtInfos && rtInfos[i]) {
          let rtInfo = rtInfos[i];
          // 有効な選べアイテム設定
          let checkedFlg = i === rtInfos.valid_no;
          // format Date
          let date = new Date(rtInfo.datetime);
          rtInfo.datetime = date.getFullYear() + "-" +
            (date.getMonth() + 1 < 10 ? "0" + (date.getMonth() + 1) : date.getMonth() + 1) + "-" +
            (date.getDate() < 10 ? "0" + date.getDate() : date.getDate()) + " " +
            (date.getHours() < 10 ? "0" + date.getHours() : date.getHours()) + ":" +
            (date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes());
          // sub comment length
          rtInfo.comment = rtInfo.comment ?
            (rtInfo.comment.length > 10 ? rtInfo.comment.substring(0, 14) + "..." : rtInfo.comment) : "";

          let radioValue = i + "," +  rtInfo.rate + "," + rtInfo.bld_vl;
          // fill in result items.
          weightInfoDetails.push(new ResultMergeItem(
            MERGE_ITEM_TYPES.WEIGHT_INFO_RECRCL_DETAIL,
            // HTML template
            `<table>
              <tr>
                <th width="25%" colspan="2">再循環率</th>
                <th width="75%">血流量:</th>
              </tr>
              <tr>
                <td rowspan="5">
                    ${checkedFlg
                            ? '<input type="radio" name="rt-valid-chk" value="' + radioValue + '" checked />'
                            : '<input type="radio" name="rt-valid-chk" value="' + radioValue + '" />'}
                </td>
                <td rowspan="5">${rtInfo.rate}%</td>
                <td>&emsp;${rtInfo.bld_vl}mL/min</td>
              </tr>
              <tr><th>測定日時:</th></tr>
              <tr><td>&emsp;${rtInfo.datetime}</td></tr>
              <tr><th>コメント:</th></tr>
              <tr><td>&emsp;${rtInfo.comment ?
                            // #10977 インジェクション対応 linjunfeng start
                            // (rtInfo.comment.length > 10 ? rtInfo.comment.substring(0, 14) + "..." : rtInfo.comment) : ""}</td></tr>
                            (rtInfo.comment.length > 10 ? rtInfo.comment.substring(0, 14).replace(/</g, '&lt;').replace(/>/g, '&gt;') + "..." : rtInfo.comment.replace(/</g, '&lt;').replace(/>/g, '&gt;')) : ""}</td></tr>
              </table>`,
                            // #10977 インジェクション対応 linjunfeng end
            "r" + i,
            false,
            [],
            2,
            i === 1 ? 5 : 0
          ));
        } else {
          // 長さが5未満の場合はdummy要素必要
          weightInfoDetails.push(new ResultMergeItem(
            MERGE_ITEM_TYPES.WEIGHT_INFO_RECRCL_DETAIL,
            "",
            "r" + i,
            false,
            [],
            2,
            i === 1 ? 5 : 0
          ));
        }
      }
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細2",
          displayname: "静的静脈圧",
          base_property: "rst_weight_info",
          properties: ["sttc_vns_prssr"]
        },
        `${this.weightInfo['sttc_vns_prssr'] != null ? this.weightInfo['sttc_vns_prssr'] + "mmHg" : ""}`,
        13,
        false,
        []
      ));
      weightInfoDetails.push(new ResultMergeItem(
        {
          subdetail: true,
          name: "体重情報明細2",
          displayname: "IAP Ratio",
          base_property: "rst_weight_info",
          properties: ["iap_rt"]
        },
        `${this.weightInfo['iap_rt'] != null ? this.weightInfo['iap_rt'] + "%" : ""}`,
        14,
        false,
        []
      ));
    }
    //mod FNSI修正486改修 房 end

    return [
      //add FNSI修正486改修 房 start
      // 治療方法
      new ResultMergeItem(
        MERGE_ITEM_TYPES.TREATMENT,
        this.ordMain.rst_treatment_name,
        this.ordMain.rst_treatment_cd
      ),
      //add FNSI修正486改修 房 end
      // クール
      new ResultMergeItem(
        MERGE_ITEM_TYPES.KUR,
        this.ordMain.rst_kur_name,
        this.ordMain.rst_kur_cd
      ),
      // ベッド
      new ResultMergeItem(
        MERGE_ITEM_TYPES.BED,
        this.ordMain.rst_bed_name,
        this.ordMain.rst_bed_cd
      ),
      // 条件送信日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.COND_SEND_DATE,
        this.getDateTimeString(this.ordMain.rst_cond_send_date)
      ),
      // 受付日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.ACCEPT_DATE,
        this.getDateTimeString(this.ordMain.rst_accept_date)
      ),
      // 治療開始日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.START_DATE,
        this.getDateTimeString(this.ordMain.rst_start_date)
      ),
      // 治療終了日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.END_DATE,
        this.getDateTimeString(this.ordMain.rst_end_date)
      ),
      // 帰宅日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.RETURN_HOME_DATE,
        this.getDateTimeString(this.ordMain.rst_return_home_date)
      ),
      // 入外区分
      new ResultMergeItem(
        MERGE_ITEM_TYPES.IN_OUT_CLASS,
        this.getCodeName(this.ordMain.rst_in_out_class, CODES.IN_OUT_CLASS)
      ),
      // 透析回数
      new ResultMergeItem(
        MERGE_ITEM_TYPES.DIALYSIS_CNT,
        this.ordMain.rst_dialysis_cnt
      ),
      // 特殊浄化回数
      new ResultMergeItem(
        MERGE_ITEM_TYPES.PURIFICATION_CNT,
        this.ordMain.rst_purification_cnt
      ),
      // 病棟
      new ResultMergeItem(
        MERGE_ITEM_TYPES.WARD,
        this.ordMain.rst_ward_name,
        this.ordMain.rst_ward_cd
      ),
      // 診療科
      new ResultMergeItem(
        MERGE_ITEM_TYPES.COURSE,
        this.ordMain.rst_course_name,
        this.ordMain.rst_course_cd
      ),
      // 穿刺者名1
      new ResultMergeItem(
        MERGE_ITEM_TYPES.PUNCTURE_USER_NAME_1,
        this.getUserName(this.punctureUserInfo, 1)
      ),
      // 穿刺者名2
      new ResultMergeItem(
        MERGE_ITEM_TYPES.PUNCTURE_USER_NAME_2,
        this.getUserName(this.punctureUserInfo, 2)
      ),
      // 穿刺日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.PUNCTURE_DATE,
        this.getDateTimeString(this.punctureUserInfo.date)
      ),
      // 返血者名1
      new ResultMergeItem(
        MERGE_ITEM_TYPES.RETURN_USER_NAME_1,
        this.getUserName(this.returnUserInfo, 1)
      ),
      // 返血者名2
      new ResultMergeItem(
        MERGE_ITEM_TYPES.RETURN_USER_NAME_2,
        this.getUserName(this.returnUserInfo, 2)
      ),
      // 返血日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.RETURN_DATE,
        this.getDateTimeString(this.returnUserInfo.date)
      ),
      // 担当者名1
      new ResultMergeItem(
        MERGE_ITEM_TYPES.RETURN_CHARGE_NAME_1,
        this.getUserName(this.chargeUserInfo, 1)
      ),
      // 担当者名2
      new ResultMergeItem(
        MERGE_ITEM_TYPES.RETURN_CHARGE_NAME_2,
        this.getUserName(this.chargeUserInfo, 2)
      ),
      // 血液循環積算値
      new ResultMergeItem(
        MERGE_ITEM_TYPES.BLOOD_CIRCULATE_TOTAL,
        this.ordMain.rst_blood_circulate_total
      ),
      // Kt/V
      new ResultMergeItem(MERGE_ITEM_TYPES.KT_V, this.ordMain.rst_kt_v),
      // 透析記録確認日時
      new ResultMergeItem(
        MERGE_ITEM_TYPES.SET_DATE,
        this.getDateTimeString(this.ordMain.rec_set_date)
      ),
      // 送信管理番号
      new ResultMergeItem(
        MERGE_ITEM_TYPES.SEND_CTL_NO,
        this.ordMain.send_ctl_no
      ),
      // 血液浄化装置名称
      new ResultMergeItem(
        MERGE_ITEM_TYPES.BLOOD_PURIFIER_NAME,
        this.ordMain.blood_purifier_name
      ),
      // プログラム補液引き残し量
      new ResultMergeItem(
        MERGE_ITEM_TYPES.PULL_LEAVE_AMOUNT,
        this.ordMain.pull_leave_amount
      ),
      //mod FNSI修正486改修 房 start
      // 治療条件情報
      new ResultMergeItem(MERGE_ITEM_TYPES.COND_INFO, null, null, false, conditionInfoDetails),
      ...conditionInfoDetails,
      // 投与薬剤情報
      new ResultMergeItem(MERGE_ITEM_TYPES.MEDI_INFO, null, null,
        false, mediInfoDetails, 2),
      ...mediInfoDetails,
      // 医療材料情報
      new ResultMergeItem(MERGE_ITEM_TYPES.EQUIP_INFO, null, null,
        false, equipInfoDetails, 2),
      ...equipInfoDetails,
      // 指示コメント情報
      new ResultMergeItem(MERGE_ITEM_TYPES.IND_COMMENT_INFO, null, null,
        false, commentInfoDetails, 2),
      ...commentInfoDetails,
      // 風袋補正
      new ResultMergeItem(MERGE_ITEM_TYPES.TARE_INFO, null, null,
        false, tareInfoItems),
      ...tareInfoItems,
      // 除水補正
      new ResultMergeItem(MERGE_ITEM_TYPES.OFF_WATER_INFO, null, null,
        false, offWaterItems),
      ...offWaterItems,
      // 装置設定情報
      new ResultMergeItem(MERGE_ITEM_TYPES.DEVICE_SET_INFO),
      // 体重測定記録番号
      new ResultMergeItem(
        MERGE_ITEM_TYPES.WEIGHT_SCALE_NO,
        this.ordMain.weight_scale_no
      ),
      // 体重情報
      new ResultMergeItem(MERGE_ITEM_TYPES.WEIGHT_INFO, null, null,
        false, weightInfoDetails),
      ...weightInfoDetails,
      // バイタル情報
      new ResultMergeItem(MERGE_ITEM_TYPES.VITAL_INFO),
      // モニタ情報
      new ResultMergeItem(MERGE_ITEM_TYPES.MONITOR_INFO),
      // 愁訴処置
      new ResultMergeItem(MERGE_ITEM_TYPES.COMPLAINT_INFO),
      // 回診記録情報
      new ResultMergeItem(MERGE_ITEM_TYPES.ROUNDS_INFO),
      // チェックリスト
      new ResultMergeItem(MERGE_ITEM_TYPES.CHECK_LIST_INFO),
      // 装置記録
      new ResultMergeItem(MERGE_ITEM_TYPES.DEVICE_SET_RECORD),
      //add FNSI修正486改修 房 end
    ];
  }

  /**
   * コード値からコード名称を取得する.
   *
   * @param {String} cd コード値
   * @param {Object} define コード定義
   */
  getCodeName(cd, define) {
    const node = Object.values(define).find(e => e.cd == cd);
    return node ? node.text : "";
  }

  /**
   * UTC日時を"yyyy/MM/dd hh:mm"形式で取得する.
   *
   * @param {String} utcDate UTC日時
   */
  getDateTimeString(utcDate) {
    if (!utcDate) return null;
    const isValidDate = moment(utcDate, "YYYY-MM-DDTHH:mm:ss.SSSZ", true).isValid();
    return isValidDate
      ? dateFormat.format(new Date(utcDate), DATE_TIME_FORMAT)
      : utcDate;
  }

  /**
   * 穿刺者名・返血者名・担当者名を取得する.
   *
   * @param {Object} userInfo 穿刺者情報/返血者情報/担当者情報
   * @param {Number} index インデックス(1 or 2)
   */
  getUserName(userInfo, index) {
    if (!userInfo || !userInfo["user_last_name_" + index]) {
      return null;
    }
    return `${userInfo["user_last_name_" + index] != null ? userInfo["user_last_name_" + index] : ""} ${
      userInfo["user_first_name_" + index] != null ? userInfo["user_first_name_" + index] : ""
    }`;
  }

  /**
   * 風袋補正・除水補正の名称と重量を取得する.
   *
   * @param {Object} json 情報が格納されているJSON
   * @param {Number} index インデックス
   */
  getNameAndWeight(json, index) {
    if (!json || !json["name_" + index]) {
      return null;
    }
    return `${json["name_" + index]} ${json["weight_" + index]}g`;
  }

  /**
   * 車いすの名称と重量を取得する.
   *
   * @param {Object} json 情報が格納されているJSON
   */
  getWheelCharNameAndWeight(json) {
    if (!json || !json.wheel_chair_name) {
      return null;
    }
    return `${json.wheel_chair_name} ${json.wheel_chair_weight}g`;
  }
}
