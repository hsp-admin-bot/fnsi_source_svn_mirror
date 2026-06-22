package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstImplant;

@ConfigAutowireable
@Dao
public interface MstImplantDao extends MasterDao<Map<String, Object>> {
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);

  @Select
  List<MstImplant> selectAll(SelectOptions options, MstImplant params);
  /*add FNSI-改修内容5237 任 start*/
  @Select
  List<MstImplant> selectDelAll(SelectOptions options, MstImplant params);
  /*add FNSI-改修内容5237 任 end*/

  /**
   * master 数据取得，包含删除
   * @param options
   * @param params
   * @return
   */
  @Select
  List<MstImplant> selectAllIncludeDel(SelectOptions options, MstImplant params);

  @Select
  List<MstImplant> selectImplantByCdList(List<Integer> implantCdList);

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<MstImplant> selectAllImplant();
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end

  //No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<MstImplant> getMstImplantInfoByFacilityCd(String facilityCd);
  //No.7167 upd Paging Optimization runtime by ztc end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstImplant> selectAllName(List<Integer> implantCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  // add #10724 インプラントマスタのデフォルト。 本田 start
  /**
   * 対象施設のインプラント情報を登録
   * @param facilityCd
   * @return 登録件数
   */
  @Insert(sqlFile = true)
  int insertInitMstForFacility(String facilityCd);
  // add #10724 インプラントマスタのデフォルト。 本田 end

  //add #12462 患者共有情報- 患者カレンダー  by zrx start
  @Select
  MstImplant selectByCd(Integer implantCd);
  //add #12462 患者共有情報- 患者カレンダー  by zrx end
}
