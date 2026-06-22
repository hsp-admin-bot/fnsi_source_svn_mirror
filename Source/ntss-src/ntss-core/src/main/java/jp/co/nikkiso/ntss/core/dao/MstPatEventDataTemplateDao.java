package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstPatEventDataTemplate;
@ConfigAutowireable
@Dao
public interface MstPatEventDataTemplateDao {
	  @Select
	  List<MstPatEventDataTemplate> selectByFacility(String facilityCd);

	  @Select
	  MstPatEventDataTemplate selectByCd(Long templateCd);
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
	  @Select
    List<MstPatEventDataTemplate> selectAllByFacility(String facilityCd);
  /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
}
