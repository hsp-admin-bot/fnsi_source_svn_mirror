package jp.co.nikkiso.ntss.admin_web.service.master;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;

/**
 * 透析困難リスト取得インタフェース.
 *
 */
public interface MstDialysisDifficultyService {

  /**
   * 透析困難リストを取得する.
   * @param facilityCd 施設コード
   * @return 透析困難リスト
   */
  List<MstDialysisDifficulty> selectAll(String facilityCd);

}
