package jp.co.nikkiso.ntss.admin_web.service.ordMainHst;


import java.util.List;

/**
 *
 *指示履歴サービス
 */
public interface OrdMainHstService {

  /**
   * mongoDbに指示を作成
   *
   * @param params
   * @return
   */
  OrdMainHst create(OrdMainHst params);

  /**
   * mongoDbに指示を作成 (batch)
   *
   * @param dataList
   * @return int
   */
  int bulkOpsCreate(List<OrdMainHst> dataList);

}
