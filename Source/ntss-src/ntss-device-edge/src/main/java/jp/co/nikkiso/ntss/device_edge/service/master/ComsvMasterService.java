package jp.co.nikkiso.ntss.device_edge.service.master;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstCheckList;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstExamItem;

/**
 * 通信サーバ用マスタサービス
 */
public interface ComsvMasterService {

  /**
   * チェックリストマスタ取得
   * @param facilityCd
   * @return
   */
  List<ComsvMstCheckList> fetchCheckList(String facilityCd);
  /**
   * 検査項目マスタ取得
   * @param facilityCd
   * @return
   */
  List<ComsvMstExamItem> fetchExamItem(String facilityCd);
}
