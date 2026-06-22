package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;
import org.seasar.doma.BatchInsert;

import jp.co.nikkiso.ntss.core.entity.MstPatMemo;

@ConfigAutowireable
@Dao
public interface MstPatMemoDao {
  @Select
  List<MstPatMemo> selectAll(SelectOptions options, MstPatMemo params);

  @Select
  MstPatMemo selectByContent(String facilityCd, String content);

  /**
  * 対象施設の患者メモ情報を登録
  * @param facilityCdList 施設コード
  * @return 更新件数
  */
  @BatchInsert(sqlFile = true)
  int[] insertInitMstForFacility(List<String> facilityCdList);
// add FNSI-No196 透析前後の判断の最適化 関 start
  @Select
  MstPatMemo selectByFacilityCdAndPatMemoNo(String facilityCd, Short patMemoNo);
// add FNSI-No196 透析前後の判断の最適化 関 end
}
