package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;

@ConfigAutowireable
@Dao
public interface MstPatEventCategoryDao {

  @Select
  List<MstPatEventCategory> selectByFacility(String facilityCd);

  @Select
  MstPatEventCategory selectByCd(Long categoryCd);

  @Select
  List<MstPatEventCategory> selectAll(SelectOptions options, String facilityCd);
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
  @Select
  List<MstPatEventCategory> selectAllByFacility(String facilityCd);
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/

}
