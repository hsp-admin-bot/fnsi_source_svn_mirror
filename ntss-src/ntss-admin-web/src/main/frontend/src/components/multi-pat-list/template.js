import {
  ORD_NO,
  COMPLAINT_CD,
  TREAT_CD,
  MEDICINE_TYPE_CD,
  TREAT_MEDICINE_CLASS_CD,
  TREAT_MEDICINE_CD,
  AMOUNT_CD,
  UNIT,
  PROCEDURE_CD,
  TREAT_STAFF_CD,
  VITAL_1_CD,
  VITAL_2_CD,
  MONITOR_1_CD,
  MONITOR_2_CD,
} from './TemplateConstant';
import moment from "moment";

export function getVitalMonitorsData(that, data) {
  // バイタル・モニタ・愁訴処置のコード
  let templateOrdMains = data.templateOrdMains;
  let templateMachines = data.templateMachines;
  let templateMonitors = data.templateMonitors;
  let templateMedicines = data.templateMedicines;
  let templateMedicineMixs = data.templateMedicineMixs;
  let patInfo = data.patInfo;
  patInfo = that.setPatInfo(patInfo);
  that.patInfoList = patInfo;
  let complaints = [];
  templateOrdMains.forEach(x => {
    let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
    let hosp_pat_id = '';
    let pat_name = '';
    if (nameList.length > 0) {
      hosp_pat_id = nameList[0].hosp_pat_id;
      pat_name = nameList[0].pat_name;
    }
    // add bug 7578 修正 chen start
    let ind_date = x.treat_date;
    // add bug 7578 修正 chen end
    // オーダー番号
    complaints = that.setComplaintsDatahasNo(
      ORD_NO,
      x.ord_no,
      "",
      "",
      hosp_pat_id,
      pat_name,
      `${x.treat_date.slice(0, 4)}-${x.treat_date.slice(4, 6)}-${x.treat_date.slice(6, 8)}`,
      complaints,
      ind_date
    );
    // 実績：愁訴情報
    if (x.rst_complaint_info) {
      let rst_complaint_info = JSON.parse(x.rst_complaint_info);
      rst_complaint_info.forEach(y => {
        let date = '';
        if (y.occur_date) {
          date = y.occur_date;
        }
        // 愁訴
        complaints = that.setComplaintsDatahasNo(
          COMPLAINT_CD,
          y.complaint,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          y.ctl_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          y.row_no,
          hosp_pat_id,
          pat_name,
          date,
          complaints,
          // add bug 7578 修正 chen start
          ind_date
          // add bug 7578 修正 chen end
        );
      });
    }
    // 実績：愁訴処置情報
    if (x.rst_treatment_info) {
      let rst_treatment_info = JSON.parse(x.rst_treatment_info);
      rst_treatment_info.forEach(y => {
        let date = '';
        if (y.occur_date) {
          date = y.occur_date;
        }
        // 処置
        if (y.treat_class) {
          let text = '';
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (y.treat_class + '' == '3') {
          if (y.treat_class == 3) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            if (y.oxygen_start !== null) {
              let textTmp = "酸素吸入開始";
              if (y.oxygen_speed) {
                textTmp = textTmp + " " + y.oxygen_speed.toFixed(2) + "L/min";
              }
              text = textTmp;
            } else {
              let textTmp = "酸素吸入終了";
              if (y.oxygen_amount) {
                textTmp = textTmp + " " + y.oxygen_amount.toFixed(2) + "L";
              }
              text = textTmp;
            }
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //} else if (y.treat_class + '' == '4') {
          } else if (y.treat_class == 4) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            if (y.electrocardiogram_start !== null) {
              text = '心電図測定開始';
            } else {
              text = '心電図測定終了';
            }
          } else {
            text = y.treat_name;
          }
          complaints = that.setComplaintsDatahasNo(
            TREAT_CD,
            text,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
            y.ctl_no,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
            y.row_no,
            hosp_pat_id,
            pat_name,
            date,
            complaints,
            // add bug 7578 修正 chen start
            ind_date
            // add bug 7578 修正 chen end
          );
        } else {
          complaints = that.setComplaintsDatahasNo(
            TREAT_CD,
            y.treat_name,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
            y.ctl_no,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
            y.row_no,
            hosp_pat_id,
            pat_name,
            date,
            complaints,
            // add bug 7578 修正 chen start
            ind_date
            // add bug 7578 修正 chen end
          );
        }
        // 薬剤区分
        if (y.medicine_type) {
          let text = '';
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (y.medicine_type + '' == '1') {
          if (y.medicine_type  == 1) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            text = '通常薬剤';
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //} else if (y.medicine_type + '' == '2') {
          } else if (y.medicine_type == 2) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            text = '調製薬剤';
          }
          complaints = that.setComplaintsDatahasNo(
            MEDICINE_TYPE_CD,
            text,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
            y.ctl_no,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
            y.row_no,
            hosp_pat_id,
            pat_name,
            date,
            complaints,
            // add bug 7578 修正 chen start
            ind_date
            // add bug 7578 修正 chen end
          );
        }
        // 処置薬剤分類
        if (y.treat_medicine_cd) {
          let list = [];
          let text = '';
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (y.medicine_type + '' == '1') {
          if (y.medicine_type == 1) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            list = templateMedicines.filter(
              z => z.medicine_cd + '' == y.treat_medicine_cd + ''
            );
            if (list.length > 0) {
              text = list[0].class_name;
            }
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //} else if (y.medicine_type + '' == '2') {
          } else if (y.medicine_type == 2) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            list = templateMedicineMixs.filter(
              z => z.medicine_cd + '' == y.treat_medicine_cd + ''
            );
            if (list.length > 0) {
              text = list[0].class_name;
            }
          }
          complaints = that.setComplaintsDatahasNo(
            TREAT_MEDICINE_CLASS_CD,
            text,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
            y.ctl_no,
            // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
            y.row_no,
            hosp_pat_id,
            pat_name,
            date,
            complaints,
          // add bug 7578 修正 chen start
            ind_date
          // add bug 7578 修正 chen end
          );
        }
        // 処置薬剤
        complaints = that.setComplaintsDatahasNo(
          TREAT_MEDICINE_CD,
          y.treat_medicine_name,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          y.ctl_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          y.row_no,
          hosp_pat_id,
          pat_name,
          date,
          complaints,
          // add bug 7578 修正 chen start
          ind_date
          // add bug 7578 修正 chen end
        );
        // 数量
        complaints = that.setComplaintsDatahasNo(
          AMOUNT_CD,
          that.getDecimalValue(y.amount, 2),
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          y.ctl_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          y.row_no,
          hosp_pat_id,
          pat_name,
          date,
          complaints,
          // add bug 7578 修正 chen start
          ind_date
          // add bug 7578 修正 chen end
        );
        // 単位
        complaints = that.setComplaintsDatahasNo(
          UNIT,
          y.unit,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          y.ctl_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          y.row_no,
          hosp_pat_id,
          pat_name,
          date,
          complaints,
          // add bug 7578 修正 chen start
          ind_date
          // add bug 7578 修正 chen end
        );
        // 手技
        complaints = that.setComplaintsDatahasNo(
          PROCEDURE_CD,
          y.procedure_name,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          y.ctl_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          y.row_no,
          hosp_pat_id,
          pat_name,
          date,
          complaints,
          // add bug 7578 修正 chen start
          ind_date
          // add bug 7578 修正 chen start
        );
      });
    }
    // 実績：愁訴処置者情報
    if (x.rst_treat_staff_info) {
      let rst_treat_staff_info = JSON.parse(x.rst_treat_staff_info);
      rst_treat_staff_info.forEach(y => {
        let date = '';
        if (y.occur_date) {
          date = y.occur_date;
        }
        // 処置者
        complaints = that.setComplaintsDatahasNo(
          TREAT_STAFF_CD,
          y.treat_staff_name,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          y.ctl_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          y.row_no,
          hosp_pat_id,
          pat_name,
          date,
          complaints,
          // add bug 7578 修正 chen start
          ind_date
          // add bug 7578 修正 chen end
        );
      });
    }
  });
  templateOrdMains = _.flatten(templateOrdMains);
  templateMachines.forEach(x => {
    let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
    let hosp_pat_id = '';
    let pat_name = '';
    if (nameList.length > 0) {
      hosp_pat_id = nameList[0].hosp_pat_id;
      pat_name = nameList[0].pat_name;
    }
    let date = '';
    if (x.event_reg_date) {
      date = x.event_reg_date;
    }
    // 処置
    complaints = that.setComplaintsDatahasNo(
      TREAT_CD,
      x.machine_record_message,
      "",
      // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
      "",
      // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
      hosp_pat_id,
      pat_name,
      date,
      complaints,
      // add bug 7578 修正 chen start
      x.treat_date
      // add bug 7578 修正 chen end
    );
  });
  templateMonitors.forEach(x => {
    let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
    let hosp_pat_id = '';
    let pat_name = '';
    if (nameList.length > 0) {
      hosp_pat_id = nameList[0].hosp_pat_id;
      pat_name = nameList[0].pat_name;
    }
    let date = '';
    if (x.occur_date) {
      date = x.occur_date;
    }
    if (x.monitor_data) {
      // mod bug 7578 修正 chen start
      // バイタル
      complaints = that.setDataMonitor(
        VITAL_1_CD,
        complaints,
        x.monitor_data,
        hosp_pat_id,
        pat_name,
        date,
        "",
        x.treat_date
      );
      // バイタル2
      complaints = that.setDataMonitor(
        VITAL_2_CD,
        complaints,
        x.monitor_data,
        hosp_pat_id,
        pat_name,
        date,
        "",
        x.treat_date
      );
      // モニタ
      complaints = that.setDataMonitor(
        MONITOR_1_CD,
        complaints,
        x.monitor_data,
        hosp_pat_id,
        pat_name,
        date,
        "",
        x.treat_date
      );
      // モニタ2
      complaints = that.setDataMonitor(
        MONITOR_2_CD,
        complaints,
        x.monitor_data,
        hosp_pat_id,
        pat_name,
        date,
        "",
        x.treat_date
      );
      // mod bug 7578 修正 chen end
    }
  });
  return sortModel(complaints);
}
function sortModel(list) {
  return list.length <= 1 ? list : list
    .sort((a, b) => {
      if (moment(a.datetime).format('YYYY/MM/DD HH:mm') < moment(b.datetime).format('YYYY/MM/DD HH:mm')) {
        return -1;
      }
      if (moment(a.datetime).format('YYYY/MM/DD HH:mm') > moment(b.datetime).format('YYYY/MM/DD HH:mm')) {
        return 1;
      }
      if (a.ctl_no < b.ctl_no) {
        return -1;
      }
      if (a.ctl_no > b.ctl_no) {
        return 1;
      }
      return 0;
    });
}
