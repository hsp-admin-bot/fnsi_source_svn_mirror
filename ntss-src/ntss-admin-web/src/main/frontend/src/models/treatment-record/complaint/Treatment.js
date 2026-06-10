import { CODES } from "@/constants/TreatmentRecord";
import { dateFormat } from "@/functions/common/DateTimeUtils";

/**
 * 愁訴処置、愁訴処置者を表現するクラス.
 */
export class Treatment {
  constructor(rstTreatmentInfo, rstTreatStaffInfo = null, isDummy = false) {
    // 管理番号
    this.ctlNo = rstTreatmentInfo.ctl_no; // 新規の場合は0

    // 発生日時（愁訴処置情報）
    this.occurDate = new Date(rstTreatmentInfo.occur_date);

    const { checkFlag } = rstTreatmentInfo;
    this.checkFlag = checkFlag == 1 || checkFlag === undefined ? 1 : 0;

    // 行番号（愁訴処置情報）
    this.rowNo = rstTreatmentInfo.row_no; // 新規の場合は0

    // 処置（愁訴処置情報.処置コード/処置名）
    this.treat = {
      cd: rstTreatmentInfo.treat_cd,
      name: rstTreatmentInfo.treat_name,
    };

    // 処置者（愁訴処置者情報.処置者名）
    this.treatStaff = rstTreatStaffInfo
      ? {
          ctlNo: rstTreatStaffInfo.ctl_no, // 新規の場合は0
          rowNo: rstTreatStaffInfo.row_no, // 新規の場合は0
          index: rstTreatmentInfo.index,
          inputClass: rstTreatStaffInfo.input_class, // 新規の場合は1
          occurDate: rstTreatStaffInfo.occur_date,
          cd: rstTreatStaffInfo.treat_staff_cd,
          name: rstTreatStaffInfo.treat_staff_name,
          copOrderNo: rstTreatStaffInfo.cop_order_no, // 新規の場合はnull
          isEditable: rstTreatStaffInfo.is_editable, // 新規の場合は1
          isDel: this.is_del,
        }
      : null;

    // 処置区分
    this.treatClass = rstTreatmentInfo.treat_class;

    // 酸素吸入開始日時
    this.oxygenStart = rstTreatmentInfo.oxygen_start;

    // 酸素吸入時間
    this.oxygenTime = rstTreatmentInfo.oxygen_time;

    // 酸素速度
    this.oxygenSpeed = rstTreatmentInfo.oxygen_speed;

    // 酸素吸入量
    this.oxygenAmount = rstTreatmentInfo.oxygen_amount;

    // 薬剤コード（処置薬剤との関連は不明）
    this.medicineCd = rstTreatmentInfo.medicine_cd;

    // 薬剤名（処置薬剤との関連は不明）
    this.medicineName = rstTreatmentInfo.medicine_name;

    // 処置薬剤（愁訴処置情報.処置薬剤コード/処置薬剤名）
    let treatmentMedicineCd = rstTreatmentInfo.treat_medicine_cd;

    if (rstTreatmentInfo.treat_medicine_cd) {
      if (isNaN(rstTreatmentInfo.treat_medicine_cd)) {
        treatmentMedicineCd = Number(
          String(rstTreatmentInfo.treat_medicine_cd).split("$")[0]
        );
        // 薬剤区分
        this.medicineType =
          String(rstTreatmentInfo.treat_medicine_cd).indexOf("$") === -1
            ? CODES.MEDICINE_TYPE.NORMAL.cd
            : CODES.MEDICINE_TYPE.MIX.cd;
      } else {
        treatmentMedicineCd = rstTreatmentInfo.treat_medicine_cd;
        //this.medicineType = rstTreatmentInfo.medicine_type;
        this.medicineType =
          rstTreatmentInfo.medicine_type != null
            ? Number(rstTreatmentInfo.medicine_type)
            : null;
      }
    }
    // 薬剤コードがundefinedの場合、nullを設定
    if (treatmentMedicineCd === undefined) {
      treatmentMedicineCd = null;
    }
    // 薬剤区分がundefinedまたは薬剤コードがnullの場合、nullを設定
    if (rstTreatmentInfo.medicine_type === undefined || !treatmentMedicineCd) {
      this.medicineType = null;
    }
    this.treatMedicine = {
      cd: treatmentMedicineCd,
      name: rstTreatmentInfo.treat_medicine_name,
      decPoint: rstTreatmentInfo.decPoint,
    };

    // 数量（愁訴処置情報.数量）
    this.amount = rstTreatmentInfo.amount;

    // 単位（愁訴処置情報.単位）
    this.unit = rstTreatmentInfo.unit;

    // 手技（愁訴処置情報.手技コード/手技名）
    this.procedure = {
      cd: rstTreatmentInfo.procedure_cd,
      name: rstTreatmentInfo.procedure_name,
    };

    // 入力区分
    this.inputClass = rstTreatmentInfo.input_class; // 新規の場合は1

    // 連携オーダ番号
    this.copOrderNo = rstTreatmentInfo.cop_order_no; // 新規の場合はnull

    // 編集可能フラグ
    this.isEditable = rstTreatmentInfo.is_editable; // 新規の場合は1

    // 心電編集種別
    this.electrocardiogramType = rstTreatmentInfo.electrocardiogram_type; // 新規の場合はnull

    // ダミー(表示する為のみ使用)
    this.isDummy = isDummy;

    // linkStartDate
    this.linkStartDate = rstTreatmentInfo.linkStartDate;

    // 心電図開始日時
    this.electrocardiogramStart = rstTreatmentInfo.electrocardiogram_start;

    this.overTime = rstTreatmentInfo.over_time;

    // 削除フラグ
    this.isDel = rstTreatmentInfo.is_del;

    this.index = rstTreatmentInfo.index;
  }

  /**
   * 処置名を返す.
   */
  get treatName() {
    if (this.isOxygenStart) {
      // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 dengshen start
      // return `酸素吸入開始 ${this.oxygenSpeed ? this.oxygenSpeed.toFixed(2) + "L/min" : ""}`;
      return `酸素吸入開始 ${this.oxygenSpeed ? Number(this.oxygenSpeed).toFixed(2) + "L/min" : ""}`;
      // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 dengshen end
    } else if (this.isOxygenEnd) {
      // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 dengshen start
      // return `酸素吸入終了 ${this.oxygenAmount ? this.oxygenAmount.toFixed(2) + "L" : ""}`;
      return `酸素吸入終了 ${this.oxygenAmount ? Number(this.oxygenAmount).toFixed(2) + "L" : ""}`;
      // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 dengshen end
      // add FNSI-改修内容 心電図追加 房 start
    } else if (this.isElectrocardiogramStart) {
      return `心電図測定開始`;
    } else if (this.isElectrocardiogramEnd){
      return `心電図測定終了`;
      // add FNSI-改修内容 心電図追加 房 end
    } else {
      return this.treat.name;
    }
  }

  /**
   * 処置薬剤名が設定されているかどうか.
   */
  get hasMedicine() {
    return this.treatMedicine.name;
  }

  /**
   * 処置者名を返す.
   */
  get treatStaffName() {
    return this.treatStaff ? this.treatStaff.name : null;
  }

  /**
   * 処置者コードを返す.
   */
  get treatStaffCd() {
    return this.treatStaff ? this.treatStaff.cd : null;
  }

  /**
   * 酸素吸入開始レコードかどうかの判定.
   */
  get isOxygenStart() {
    return (
      this.treatClass === CODES.COMPLAINT_TREAT_CLASS.OXYGEN.cd &&
      this.oxygenStart !== null
    );
  }

  /**
   * 酸素吸入終了レコードかどうかの判定.
   */
  get isOxygenEnd() {
    return (
      this.treatClass === CODES.COMPLAINT_TREAT_CLASS.OXYGEN.cd &&
      this.oxygenStart === null
    );
  }

  // add FNSI-改修内容 心電図追加 房 start
  /**
   * 心電図開始レコードかどうかの判定.
   */
  get isElectrocardiogramStart() {
    return (
      this.treatClass === CODES.COMPLAINT_TREAT_CLASS.ELECTRO.cd &&
      this.electrocardiogramStart !== null
    );
  }

  /**
   * 心電図終了レコードかどうかの判定.
   */
  get isElectrocardiogramEnd() {
    return (
      this.treatClass === CODES.COMPLAINT_TREAT_CLASS.ELECTRO.cd &&
      this.electrocardiogramStart === null
    );
  }
  // add FNSI-改修内容 心電図追加 房 end


  // rowNoを設定する。処置者が選択されていないときは処置者のrowNoは設定しない。
  setRowNo(rowNo) {
    this.rowNo = rowNo;
    if(this.treatStaff !== null) {
      this.treatStaff.rowNo = rowNo;
    }
  }

  /**
   * 処置者情報を設定.
   * 引数がnullの場合には、nullを設定する.
   *
   * @param {TreatmentStaff} treatmentStaff
   */
  setTreatmentStaff(treatmentStaff) {
    this.treatStaff = treatmentStaff
      ? {
          // 管理番号
          ctlNo: treatmentStaff.ctlNo,
          // 行番号
          rowNo: treatmentStaff.rowNo,
          index: treatmentStaff.index,
          // 入力区分
          inputClass: treatmentStaff.inputClass,
          // 発生日時
          occurDate: treatmentStaff.occurDate,
          // 処置者コード
          cd: treatmentStaff.cd,
          // 処置者名
          name: treatmentStaff.name,
          // 連携オーダ番号
          copOrderNo: treatmentStaff.copOrderNo,
          // 編集可否フラグ
          isEditable: treatmentStaff.isEditable,
          // 削除フラグ
          isDel: treatmentStaff.isDel,
        }
      : null;
  }

  // PUTリクエスト用の文字列を返す(愁訴処置).
  treatmentToString() {
    return JSON.stringify({
      //add 治療記録改修7 房 start 2020/08/13
      checkFlag: this.checkFlag,
      //add 治療記録改修7 房 end 2020/08/13
      ctl_no: this.ctlNo,
      row_no: this.rowNo,
      index: this.index,
      occur_date: dateFormat.utc2Jst(this.occurDate),
      treat_class: this.treatClass,
      treat_cd: this.treat.cd,
      treat_name: this.treat.name ? this.treat.name : null,
      medicine_cd: this.medicineCd,
      medicine_name: this.medicineName ? this.medicineName : null,
      amount: this.amount || null,
      unit: this.unit ? this.unit : null,
      procedure_cd: this.procedure.cd,
      procedure_name: this.procedure.name ? this.procedure.name : null,
      medicine_type: this.medicineType,
      treat_medicine_cd: this.treatMedicine.cd,
      treat_medicine_name: this.treatMedicine.name
        ? this.treatMedicine.name
        : null,
      oxygen_start: this.oxygenStart ? this.oxygenStart : null,
      oxygen_time: this.oxygenTime,
      oxygen_amount: this.oxygenAmount,
      oxygen_speed: this.oxygenSpeed,
      input_class: this.inputClass,
      cop_order_no: this.copOrderNo,
      is_editable: this.isEditable,
      electrocardiogram_type: this.electrocardiogramType,
      linkStartDate: this.linkStartDate,
      electrocardiogram_start: this.electrocardiogramStart
        ? this.electrocardiogramStart
        : null,
      over_time: this.overTime ? this.overTime : null,
      is_del: this.isDel || false,
    });
  }

  // PUTリクエスト用の文字列を返す(愁訴処置者).
  treatStaffToString() {
    if (!this.treatStaff || (!this.treatStaff.name && !this.treatStaff.cd)) {
      return null;
    }
    return JSON.stringify(
      {
        ctl_no: this.treatStaff.ctlNo,
        row_no: this.treatStaff.rowNo,
        index: this.treatStaff.index,
        input_class: this.treatStaff.inputClass,
        occur_date: dateFormat.utc2Jst(this.treatStaff.occurDate),
        treat_staff_cd: this.treatStaff.cd,
        treat_staff_name: this.treatStaff.name ? this.treatStaff.name : null,
        cop_order_no: this.treatStaff.copOrderNo,
        is_editable: this.treatStaff.isEditable,
        checkFlag: this.treatStaff.checkFlag,
        is_del: this.isDel || false,
      }
    );
  }

  // ファクトリメソッド
  static of(treatmentInfo, treatStaffInfo, isDummy = false) {
    const getOrElse = (obj, prop, defaultValue) => {
      if (!obj) {
        return defaultValue;
      }
      return obj.hasOwnProperty(prop) ? obj[prop] : defaultValue;
    };

    return new Treatment(
      {
        ctl_no: getOrElse(treatmentInfo, "ctlNo", 0),
        row_no: getOrElse(treatmentInfo, "rowNo", 0),
        index: getOrElse(treatmentInfo, "index", 0),
        occur_date: treatmentInfo.occurDate,
        treat_class: treatmentInfo.treatClass,
        treat_cd: treatmentInfo.treatCd,
        treat_name: treatmentInfo.treatName,
        medicine_cd: getOrElse(treatmentInfo, "medicineCd", null),
        medicine_name: getOrElse(treatmentInfo, "medicineName", null),
        amount: treatmentInfo.amount || null,
        decPoint: treatmentInfo.decPoint,
        unit: treatmentInfo.unit,
        procedure_cd: treatmentInfo.procedureCd,
        procedure_name: treatmentInfo.procedureName,
        medicine_type: treatmentInfo.medicineType,
        treat_medicine_cd: treatmentInfo.treatMedicineCd,
        treat_medicine_name: treatmentInfo.treatMedicineName,
        oxygen_start: getOrElse(treatmentInfo, "oxygenStart", null),
        oxygen_time: getOrElse(treatmentInfo, "oxygenTime", null),
        oxygen_speed: getOrElse(treatmentInfo, "oxygenSpeed", null),
        oxygen_amount: getOrElse(treatmentInfo, "oxygenAmount", null),
        input_class: getOrElse(treatmentInfo, "inputClass", 1),
        cop_order_no: getOrElse(treatmentInfo, "copOrderNo", null),
        is_editable: getOrElse(treatmentInfo, "isEditable", "1"),
        electrocardiogram_type: getOrElse(
          treatmentInfo,
          "electrocardiogramType",
          null
        ),
        linkStartDate: treatmentInfo.linkStartDate,
        electrocardiogram_start: getOrElse(
          treatmentInfo,
          "electrocardiogramStart",
          null
        ),
        over_time: getOrElse(treatmentInfo, "overTime", null),
        is_del: getOrElse(treatmentInfo, "isDel", false),
      },
      treatStaffInfo
        ? {
            ctl_no: getOrElse(treatStaffInfo, "ctlNo", 0),
            row_no: getOrElse(treatStaffInfo, "rowNo", 0),
            index: getOrElse(treatStaffInfo, "index", 0),
            input_class: getOrElse(treatStaffInfo, "inputClass", 1),
            occur_date: treatStaffInfo.occurDate,
            treat_staff_cd: treatStaffInfo.treatStaffCd,
            treat_staff_name: treatStaffInfo.treatStaffName,
            cop_order_no: getOrElse(treatStaffInfo, "copOrderNo", null),
            is_editable: getOrElse(treatStaffInfo, "isEditable", "1"),
            is_del: getOrElse(treatStaffInfo, "isDel", false),
          }
        : null,
      isDummy
    );
  }
}
