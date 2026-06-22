package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstRadSet;


@ConfigAutowireable
@Dao
public interface MstRadSetDao {

  /**
   * 放射線検査セットマスタ：対象施設の放射線検査セット取得用
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @return 放射線検査セット情報のリスト
   */
  @Select
  List<MstRadSet> selectRadSetList(String facilityCd);

  /**
   * 放射線検査セットマスタ：放射線検査セットコード指定取得
   * 放射線検査セットコード：必須
   * @param radSetCd 検査セットコード
   * @return 検査セットマスタ(0～1件)
   */
  @Select
  MstRadSet selectRadSetByCd(Long radSetCd);

}
