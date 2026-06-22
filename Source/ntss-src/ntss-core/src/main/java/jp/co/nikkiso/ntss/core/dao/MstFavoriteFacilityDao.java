package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityDataT;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstFavoriteFacility;
import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityData;

@ConfigAutowireable
@Dao
public interface MstFavoriteFacilityDao {

  /**
   * 対象のすべてのカラムを取得
   * @param facilityCd 取得対象の施設コード
   * @return
   */
  @Select
  List<MstFavoriteFacility> selectAll(SelectOptions options, String facilityCd);

  /**
   * 全施設マスタと紐づくデータ一覧を取得
   * @param facilityCd 取得対象の施設コード
   * @return
   */
  @Select
  List<MstFavoriteFacilityData> selectAllJoinSysFacility(String facilityCd);

  // add FNSI-よく使う施設の変更 関 start
  @Select
  List<MstFavoriteFacilityDataT> selectAllByFacilityCd(String facilityCd);
  // add FNSI-よく使う施設の変更 関 end

  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstFavoriteFacilityData> selectAllName(List<String> medicalinstitutioncds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
}
