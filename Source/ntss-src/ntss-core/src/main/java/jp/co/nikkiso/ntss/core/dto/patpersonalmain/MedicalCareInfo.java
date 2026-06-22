package jp.co.nikkiso.ntss.core.dto.patpersonalmain;
//add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 start
public  class MedicalCareInfo {
  public String facility_cd;            //施設コード
  public String ward_cd;                //病棟コード
  public String main_course_cd;         //診療科主科コード
  public String dialysis_course_cd;     //診療科透析実施科コード
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //public String dialysis_count;         //透析回数
  //public String pat_dialysis_count;     //自施設透析回数
  //public String other_dialysis_count;   //他施設透析回数
  //public String purification_count;     //浄化治療回数
  public Integer dialysis_count;         //透析回数
  public Integer pat_dialysis_count;     //自施設透析回数
  public Integer other_dialysis_count;   //他施設透析回数
  public Integer purification_count;     //浄化治療回数
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  public String dialysis_start_date;    //透析導入日
  public String hospital_start_date;    //当院開始日
}
//add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 end
