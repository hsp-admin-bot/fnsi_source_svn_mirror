package jp.co.nikkiso.ntss.api.service.conditionSend;

/**
 * 状態変更のServiceインタフェース.
 */
public abstract interface OperateStatusUtilService {

  /**
   * ord_mainの状態変更用
   * @param ord_no オーダー番号
   * @param status ステータス
   * @param updateDateFlag   条件送信日時変更フラグ(true:変更)
   * @return update件数
   * @throws Exception
   */
  int updateOrdMainStatus(
          long  ord_no,
          String status,
          boolean updateDateFlag
      );
  /**
   * pat_mainの状態変更用
   * @param ord_no オーダー番号
   * @param status ステータス
   * @param clearStatusFlag   状態クリアフラグ(true:クリア)
   * @param updateValueFlag   進捗計算用値変更フラグ(true:変更)
   * @return update件数
   * @throws Exception
   */
  int updatePatMainStatus(
          long  ord_no,
          String status,
          boolean clearStatusFlag,
          boolean updateValueFlag
      );
}
