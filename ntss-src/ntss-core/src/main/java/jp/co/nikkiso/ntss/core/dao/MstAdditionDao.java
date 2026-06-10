package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstAddition;


@ConfigAutowireable
@Dao
public interface MstAdditionDao {

  /**
   * 加算マスタトマスタ：対象施設の加算ト取得用
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @return 加算ト情報のリスト
   */
  @Select
  List<MstAddition> selectByFacilityCd(String facilityCd);

  /**
   *
   */
  @Select
  List<MstAddition> getByAdditionCdList(String facilityCd, List<String> additionClass);

  /**
   *
   */
  @Select
  MstAddition selectByAdditionCd(Long additionCd);
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Select
  List<MstAddition> selectAllName(List<Integer> additionCds);
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
}
