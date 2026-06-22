package jp.co.nikkiso.ntss.web_api.service;

import java.util.List;

public interface ExamRecordInfectInfoUtilService {

  /**
   * 検査結果から感染症の検査結果を登録
   * @param examMainCd 検査結果コード
   */
  void updateInfectinfo(List<Long> examMainCd);
  
}
