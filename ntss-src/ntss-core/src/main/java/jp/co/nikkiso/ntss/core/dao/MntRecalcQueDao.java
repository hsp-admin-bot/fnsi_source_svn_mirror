package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MntRecalcQue;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

@ConfigAutowireable
@Dao
public interface MntRecalcQueDao {

  /**
   * 検査再計算依頼キューテーブル取得用
   * @param facility_cd 施設コード
   * @return 検査再計算依頼キューテーブルリスト
   */
  @Select
  List<MntRecalcQue> selectByFacilityCd(String facilityCd);

  /**
   * 検査再計算依頼キューテーブル取得用
   * @return 検査再計算依頼キューテーブルリスト
   */
  @Select
  List<MntRecalcQue> selectAll();

  /**
   * 検査再計算依頼キューテーブル取得用
   * @param statusList ステータスリスト
   * @return 検査再計算依頼キューテーブルリスト
   */
  @Select
  List<MntRecalcQue> selectByStatusList(List<String> statusList);

  /**
   * 検査再計算依頼キューテーブル追加
   * @param MntRecalcQue 検査再計算依頼キューテーブル
   */
  @Insert(sqlFile = true)
  int insertWithSeq(MntRecalcQue entity);

  /**
   * 検査再計算依頼キューテーブル更新
   * @param MntRecalcQue 検査再計算依頼キューテーブル
   */
  @Update(sqlFile = true)
  int update(MntRecalcQue params);
}
