package jp.co.nikkiso.ntss.web_api.service;

import java.util.List;

/**
 * 入外・転入出情報のServiceインタフェース.
 */
public abstract interface InOutInfoUtilService {

  /**
   * 日付を指定して入外区分・確定転入出状態を更新する
   * @param targetDt 更新対象日
   */
  public void updateInOutStateByDate(String targetDt, List<Long> patIdList);

// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  public void insertPatMainHistorybyIDList(List<String> patIdList);
// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
}
