package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;


@ConfigAutowireable
@Dao
public interface MstDialysisDifficultyDao {

  /**
   * 透析困難リストを取得する.
   *
   * @param options 検索オプション
   * @param params 施設コードを指定するパラメータ
   * @return 透析困難リスト
   */
  @Select
  List<MstDialysisDifficulty> selectAll(SelectOptions options, MstDialysisDifficulty params);

  /**
   * 透析困難リストを取得する.
   * @param facilityCd 施設コード
   * @return 透析困難リスト
   */
  @Select
  List<MstDialysisDifficulty> selectDisp(String facilityCd);

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  @Select
  MstDialysisDifficulty selectByCd(Integer dialysisDifficultyCd);

  /*
  @Select
  MstDialysisDifficulty selectByCd(String pat_id);

  @Insert
  int insert(MstDialysisDifficulty mstDialysisDifficulty);

  @Delete
  int delete(MstDialysisDifficulty mstDialysisDifficulty);

  @Update(sqlFile = true)
  int updateByCd(MstDialysisDifficulty param);
  */
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstDialysisDifficulty> selectAllName(List<Integer> dialysisDifficultyCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  @Select
  List<MstDialysisDifficulty> selectByCds(List<Integer> dialysisDifficultyCds);
  // add 10626 データリストのCTR・DW一括登録修正 房 end
}
