/**
 * 体重画面のモニタを表現するクラス
 */
// add FNSI-体重情報のJSONに四つカラムを追加 徐 start
import { parseDate, dateFormat, DATE_FORMAT, SHORT_TIME_FORMAT, } from "@/functions/common/DateTimeUtils";
import moment from "moment";
// add FNSI-体重情報のJSONに四つカラムを追加 徐 end

export class Monitor {
  constructor(rstWeightInfo = null) {
    if (rstWeightInfo === null) {
      this.ktVMeasure = null;
      this.urr = null;
      this.reLoopRateMain = null;
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      this.sttcVnsPrssr = null;
      this.iapRt = null;
      this.recrclRt = null;
      this.recrclRtList = [];
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
    } else {
      this.ktVMeasure = rstWeightInfo.kt_v_measure;
      this.urr = rstWeightInfo.urr;
      this.reLoopRateMain = rstWeightInfo.re_loop_rate_main;
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      this.sttcVnsPrssr = rstWeightInfo.sttc_vns_prssr;
      this.iapRt = rstWeightInfo.iap_rt;
      this.recrclRt = rstWeightInfo.recrcl_rt;
      let recrclRtListIndex = [];
      for (let i = 1; i < 6; i++) {
        if (this.recrclRt !== null) {
          let recrclRtFlg = true;
          if (this.recrclRt === undefined || this.recrclRt === null) {
            recrclRtFlg = false;
          } else if (this.recrclRt[i] === undefined) {
            recrclRtFlg = false;
          }

          let validFlg = false;
          if (this.recrclRt === undefined || this.recrclRt === null) {
            validFlg = false;
          // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          // } else if (this.recrclRt.valid_no.toString() === i.toString()) {
          } else if (this.recrclRt?.valid_no != null && this.recrclRt.valid_no.toString() === i.toString()) {
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
            validFlg = true;
          }
          if (recrclRtFlg === true && this.recrclRt[i].datetime === null) {
            this.recrclRt[i].datetime = "";
          }
          //#8984 add ljx start
          let timeStr = this.recrclRt[i].datetime;
          //透析装置で測定した再循環率の測定時間の場合、時間を転換処理
          if(this.recrclRt[i].datetime.length  == 14){
            timeStr = moment(this.recrclRt[i].datetime, "YYYY-MM-DD HH:mm:ss");
          }
          //#8984 add ljx end
          let list = {
              validFlg: validFlg,
              rate:recrclRtFlg ? this.recrclRt[i].rate: 0,
              bldVl:recrclRtFlg ? this.recrclRt[i].bld_vl: 0,
              //#8984 mod ljx start
              // date:recrclRtFlg ? dateFormat.format(new Date(this.recrclRt[i].datetime), DATE_FORMAT): "",
              // time:recrclRtFlg ? dateFormat.format(new Date(this.recrclRt[i].datetime), SHORT_TIME_FORMAT): "",
              date:recrclRtFlg && timeStr ? dateFormat.format(new Date(timeStr), DATE_FORMAT): "",
              time:recrclRtFlg && timeStr ? dateFormat.format(new Date(timeStr), SHORT_TIME_FORMAT): "",
              //#8984 mod ljx end
              comment:recrclRtFlg ? this.recrclRt[i].comment: ""
            }
          recrclRtListIndex.push(list);
        }
        this.recrclRtList = recrclRtListIndex;
      }
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
    }
  }

  /**
   * モデルの値をJSONで返す.
   */
  toJson() {
    // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
    if (this.recrclRtList === null || this.recrclRtList === "") {
      return {
        kt_v_measure: this.ktVMeasure,
        urr: this.urr,
        re_loop_rate_main: this.reLoopRateMain,
        sttc_vns_prssr: this.sttcVnsPrssr,
        iap_rt: this.iapRt,
        recrcl_rt: null
      };
    }
    if (this.recrclRtList.length === 0) {
      return {
        kt_v_measure: this.ktVMeasure,
        urr: this.urr,
        re_loop_rate_main: this.reLoopRateMain,
        sttc_vns_prssr: this.sttcVnsPrssr,
        iap_rt: this.iapRt,
        recrcl_rt: null
      };
    }
    let valid = 0;
    for (let i = 0; i < this.recrclRtList.length; i++) {
      if (this.recrclRtList[i].validFlg) {
        valid = i + 1;
      }
      if (this.recrclRtList[i].date !== null && this.recrclRtList[i].time !== null) {
        this.recrclRtList[i].datetime = parseDate(this.recrclRtList[i].date, this.recrclRtList[i].time);
      } else if (this.recrclRtList[i].date !== null && this.recrclRtList[i].time === null) {
        this.recrclRtList[i].datetime = parseDate(this.recrclRtList[i].date, "");
      } else {
        this.recrclRtList[i].datetime = "";
      }
    }
    let recrclRt = {
      valid_no:valid,
      1:{
        rate:this.recrclRtList[0].rate,
        bld_vl:this.recrclRtList[0].bldVl,
        datetime:this.recrclRtList[0].datetime ? dateFormat.utc2Jst(this.recrclRtList[0].datetime) : null,
        comment:this.recrclRtList[0].comment
      },
      2:{
        rate:this.recrclRtList[1].rate,
        bld_vl:this.recrclRtList[1].bldVl,
        datetime:this.recrclRtList[1].datetime ? dateFormat.utc2Jst(this.recrclRtList[1].datetime) : null,
        comment:this.recrclRtList[1].comment
      },
      3:{
        rate:this.recrclRtList[2].rate,
        bld_vl:this.recrclRtList[2].bldVl,
        datetime:this.recrclRtList[2].datetime ? dateFormat.utc2Jst(this.recrclRtList[2].datetime) : null,
        comment:this.recrclRtList[2].comment
      },
      4:{
        rate:this.recrclRtList[3].rate,
        bld_vl:this.recrclRtList[3].bldVl,
        datetime:this.recrclRtList[3].datetime ? dateFormat.utc2Jst(this.recrclRtList[3].datetime) : null,
        comment:this.recrclRtList[3].comment
      },
      5:{
        rate:this.recrclRtList[4].rate,
        bld_vl:this.recrclRtList[4].bldVl,
        datetime:this.recrclRtList[4].datetime ? dateFormat.utc2Jst(this.recrclRtList[4].datetime) : null,
        comment:this.recrclRtList[4].comment
      }
    }
    // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
    return {
      kt_v_measure: this.ktVMeasure,
      urr: this.urr,
      re_loop_rate_main: this.reLoopRateMain,
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      sttc_vns_prssr: this.sttcVnsPrssr,
      iap_rt: this.iapRt,
      recrcl_rt: recrclRt
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
    };
  }
}
