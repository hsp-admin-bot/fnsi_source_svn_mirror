package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;

@ConfigAutowireable
@Dao
public interface MstPatEventSubCategoryDao {

  @Select
  List<MstPatEventSubCategory> selectByFacility(String facilityCd);

  @Select
  MstPatEventSubCategory selectByCd(Long subCategoryCd);

  @Select
  List<MstPatEventSubCategory> selectAll(SelectOptions options, String facilityCd);

  @Select
  List<MstPatEventSubCategory> selectAllIncludeDeleted(SelectOptions options, String facilityCd);

  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
  @Select
  List<MstPatEventSubCategory> selectAllByFacility(String facilityCd);
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/

  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start
  /**
   * 患者イベントサブカテゴリマスタに設定している帳票を取得
   * @param facilityCd
   * @return 帳票コード
   */
  @Select
  List<Integer> selectReportCdsByFacilityCd(String facilityCd);
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end
}
