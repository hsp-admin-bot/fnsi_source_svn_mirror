
package jp.co.nikkiso.ntss.admin_web.service.master.machine;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntFindMachine;

public interface MntFindMachineService {

  /**
   * 施設コードに該当にする装置自動登録ワークテーブル情報の削除
   *
   * @param facilityCd 施設コード
   * @return
   */
  int deleteByFacilityCd(String facilityCd);

  /**
   * 施設コードに該当にする装置自動登録ワークテーブル情報の取得
   *
   * @param facilityCd 施設コード
   * @return
   */
  List<MntFindMachine> selectByFacilityCd(String facilityCd);

  /**
   * 装置自動登録ワークテーブル情報の取得
   *
   * @return
   */
  List<MntFindMachine> selectAll();

  /**
   * 装置検索処理.
   *
   * @param facilityCd 施設コード
   * @param procMode 動作モード（0：通常モード 1:装置登録モード）
   * @param deviceEdgeNo デバイスエッジ番号
   * @return
   */
  boolean deviceSearch(String facilityCd, Integer procMode, Integer deviceEdgeNo);

}
