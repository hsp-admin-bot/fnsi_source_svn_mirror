package jp.co.nikkiso.ntss.device_edge.util.MedicalCareInfo;

import lombok.Getter;
import lombok.Setter;

/**
 *  共通診療情報クラス.
 */
@Getter
@Setter
public class MedicalCareInfo {

  /** 主科コード **/
  int mainCourseCd;
  /** 主科名 **/
  String mainCourseName;
  /** 透析実施科コード **/
  int dialysisCourseCd;
  /** 透析実施科名 **/
  String dialysisCourseName;
  /** 病棟コード **/
  int wardCd;
  /** 病棟名 */
  String wardName;
  /** 透析回数 **/
  int dialysisCount;
  /** 浄化治療回数 **/
  int purificationCount;
  /** 他施設透析回数 **/
  int otherDialysisCount;
  /** 導入施設コード **/
  String facilityCd;
  /** 透析導入日 **/
  String dialysisStartDate;
  /** 当院開始日 **/
  String hospitalStartDate;

}
