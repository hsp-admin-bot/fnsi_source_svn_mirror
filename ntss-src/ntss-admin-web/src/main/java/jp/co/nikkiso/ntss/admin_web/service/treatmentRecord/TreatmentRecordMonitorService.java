package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;

/**
 * 治療記録画面（モニタ機能）のServiceインタフェース.
 *
 * モニタ機能だけを別クラスにしたのは、updateTreatmentRecordRstMonitorメソッドに@Transactionalアノテーションを付けていると、
 * テストクラスで他のメソッドのテストが失敗するようになったため。
 */
public interface TreatmentRecordMonitorService {

  /**
   * 治療記録（装置モニタデータ(モニタ)情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、空リストを返却する.
   * </p>
   * @param ordNo オーダ番号
   * @return 治療記録（装置モニタデータ(モニタ)情報）
   */
  List<TreatmentRecordMonitor> getTreatmentRecordMonitors(Long ordNo);
}
