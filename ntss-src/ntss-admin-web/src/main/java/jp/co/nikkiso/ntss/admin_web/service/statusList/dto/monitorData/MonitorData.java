package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData;

/**
 *  モニタデータのインターフェース.
 */
public interface MonitorData {

  /**
   * 項目コードを指定して、値を取得します。
   * @param itemCd
   * @return
   */
  MonitorDataItem getByItemCd(int itemCd);

}
