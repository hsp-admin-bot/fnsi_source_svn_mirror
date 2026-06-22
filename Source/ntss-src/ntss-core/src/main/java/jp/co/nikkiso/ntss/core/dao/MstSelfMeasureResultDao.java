package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstSelfMeasureResult;
import java.util.List;

/**
 * 装置の自己診断結果のDao.
 */
@ConfigAutowireable
@Dao
public interface MstSelfMeasureResultDao {

  /**
   * 対象機種情報カラム内に、指定した型式コード情報を含むデータ一覧を取得
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @return 自己診断判定マスタ情報
   */
  @Select
  public List<MstSelfMeasureResult> selectByMachineTypeCd(String facilityCd, String machineTypeCd);

  /**
   * 装置の自己診断結果を抽出
   *
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<MstSelfMeasureResult> selectByFacilityCd(String facilityCd);
}
