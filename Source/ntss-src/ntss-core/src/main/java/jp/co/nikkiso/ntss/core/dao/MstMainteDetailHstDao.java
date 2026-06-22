package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMainteDetailHst;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteDetailResult;

/**
 * 日常・定期点検項目マスタ履歴Daoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMainteDetailHstDao {

  @Select
  // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
  List<MstMainteDetailHst> selectByListIdAndEdition(List<CusMenteDetailResult> cusMenteDetailResults);
//  List<MstMainteDetailHst> selectByListIdAndEdition(List<CusMenteDetailResult> cusMenteDetailResults, String facilityCd);
  // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end

  @Insert(sqlFile = true)
  int insertList(List<MstMainteDetailHst> mstMainteDetailHsts);
  // add FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
  @Select
  List<MstMainteDetailHst> selectByListIdAndEditionNew(List<CusMenteDetailResult> cusMenteDetailResults, String facilityCd);
  // add FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end

  // add by ztc 2023-03-07: add trigger logic code  --start
  @Insert
  int insert(MstMainteDetailHst mstMainteDetailHst);

  @Insert(sqlFile = true)
  int insertDetailHst(MstMainteDetailHst mstMainteDetailHst);
  // add by ztc 2023-03-07: add trigger logic code  --end
}
