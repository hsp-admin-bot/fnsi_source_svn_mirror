package jp.co.nikkiso.ntss.admin_web.service.mstSynchro;

import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstDeviceEdgeResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstFacilityResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.SynchroMstMNoticeResponse;


/**
 * マスタ同期のServiceインタフェース.
 */
public interface MstSynchroService {

  /**
   * 施設マスタ情報の取得.
   *
   * @return 施設マスタ情報
   */
  MstFacilityResponse getMstFacilityList();

  /**
   * デバイスエッジマスタ情報の取得.
   *
   * @param facilityCd 施設コード
   * @return デバイスエッジマスタ情報
   */
  MstDeviceEdgeResponse getMstDeviceEdgeList(String facilityCd);

  /**
   * マスタ同期開始処理.
   *
   * @param facilityCd 施設コード
   * @param mstTable 対象テーブル
   * @param deviceEdgeNo デバイスエッジ番号
   * @return
   */
  boolean startMstSynchro(String facilityCd, String mstTable, Integer deviceEdgeNo);

  /**
   * 緊急発報マスタ同期処理.
   *
   * @param facilityCd
   * @return
   */
  SynchroMstMNoticeResponse synchroMstMNotice(String facilityCd);
  //8104   心電図スイッチ      ljd Start

  Integer selectAllSysFunctionAdvanceds(String func_advcd,String facilityCd);
  //8104   心電図スイッチ      ljd Start
}
