package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMainteLayoutHst;

/**
 * 日常・定期点検レイアウトマスタ履歴Daoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMainteLayoutHstDao {

  @Select
  MstMainteLayoutHst selectByIdAndEdition(String facilityCd, Long mainteLayoutCd, Integer editionNo);

  @Insert(sqlFile = true)
  int insertList(List<MstMainteLayoutHst> mstMainteLayoutHsts);

  @Select
  List<MstMainteLayoutHst> selectLayoutHstByClass(String facilityCd, String layoutClass);

  @Insert
  int insert(MstMainteLayoutHst mstMainteLayoutHst);

  @Insert(sqlFile = true)
  int insertLayoutHst(MstMainteLayoutHst mstMainteLayoutHst);
}
