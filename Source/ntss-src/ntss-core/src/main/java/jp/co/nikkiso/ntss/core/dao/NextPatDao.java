package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.dto.nextpat.NextPatByBedInfo;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

@ConfigAutowireable
@Dao
//add #10412 次患者更新関連全体見直し対応 朴 start
public interface NextPatDao {

  /**
   * 対象ベッドの現患者・次患者・並んでいる患者情報取得
   * @param facilityCd
   * @param searchStartDate
   * @param bedCdList
   * @param ordNoList
   * @return
   */
  @Select
  List<NextPatByBedInfo> selectOrdNoListForNextPatByBedList(String facilityCd, String searchStartDate, List<Integer> bedCdList, List<Long> ordNoList);

}
//add #10412 次患者更新関連全体見直し対応 朴 end
