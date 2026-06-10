package jp.co.nikkiso.ntss.web_api.service.component;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelStat;

/**
 * 施設解約および期間外削除の対象テーブルを取得するコンポーネントのインタフェース。
 */
public interface TargetTableComponent {

  /**
   * 処理対象テーブルの統計情報のリストを取得する。
   *
   * @param facilityCd 施設コード
   * @return 統計情報のリスト
   */
  List<MntFacilityCancelStat> getTargetTableList(String facilityCd);

  /**
   * 処理対象テーブルの統計情報のリストを取得する。
   *
   * @param facilityCd 施設コード
   * @param procClass 処理区分
   * @return 統計情報のリスト
   */
  List<MntFacilityCancelStat> getTargetTableList(String facilityCd, String procClass);
}
