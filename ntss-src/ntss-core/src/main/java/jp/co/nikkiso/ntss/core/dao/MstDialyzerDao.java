package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstDialyzer;

@ConfigAutowireable
@Dao
public interface MstDialyzerDao extends MasterDao<Map<String,Object>>{
  @Select
  List<MstDialyzer> selectAll(SelectOptions options, MstDialyzer params);

  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
  @Select
  List<MstDialyzer> selectIncludeDeleted(SelectOptions options, MstDialyzer params);
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

  @Select
  List<MstDialyzer> selectAllByCdList(SelectOptions options, List<Integer> dialyzerList);

  //add 10310 ダイアライザマスタから情報取得 gjn start
  @Select
  List<MstDialyzer> selectAllByCdListCheckList(SelectOptions options, List<Integer> dialyzerList, String facilityCd);
  //add 10310 ダイアライザマスタから情報取得 gjn end

  @Select
  MstDialyzer selectByDialyzerCd(SelectOptions options, Integer dialyzerCd);

// FNSI-修正 マスタ削除の対応 chen add start
  @Select
  List<MstDialyzer> selectAllNoDel(SelectOptions options, MstDialyzer params);
// FNSI-修正 マスタ削除の対応 chen add end

  @Select
  List<MstDialyzer> selectByFacillityCd(String facilityCd);

  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
  @Select
  List<Integer> selectDialyzerCdByFacillityCd(String facilityCd);
  // add 10546 複数集計出力時にサーバが高負荷になる gjn end

  @Select
  List<MstDialyzer> selectAllIncludeDeleted(SelectOptions options, MstDialyzer params);

  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
  @Select
  List<MstDialyzer> selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  @Insert(sqlFile = true)
  int insertMstDialyzer(MstDialyzer mstDialyzer);
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end

  @Override
  @Select
  List<Map<String,Object>> selectAllStatus(Map<String,String> params);
}
