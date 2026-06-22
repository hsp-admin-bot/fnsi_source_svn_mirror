package jp.co.nikkiso.ntss.api.service.ordChecklistService;

import java.io.IOException;
import java.util.List;

public interface OrdCheckListService {
  /**
   * ord_checklist作成共通方法
   *
   * @param insOrdNoList
   */
  void syncOrdChecklistForResult(List<Long> insOrdNoList) throws IOException;

}
