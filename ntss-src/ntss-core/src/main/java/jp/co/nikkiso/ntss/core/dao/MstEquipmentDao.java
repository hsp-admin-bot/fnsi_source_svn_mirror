package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.custom.Equipment;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;
import java.util.Map;

@ConfigAutowireable
@Dao
public interface MstEquipmentDao extends MasterDao<Map<String,Object>> {
  @Select
  List<MstEquipment> selectAll(SelectOptions options, MstEquipment params);

  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
  @Select
  List<MstEquipment> selectIncludeDeleted(SelectOptions options, MstEquipment params);
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
// FNSI-修正 マスタ削除の対応 chen add start
  @Select
  List<MstEquipment> selectAllNoDel(SelectOptions options, MstEquipment params);
// FNSI-修正 マスタ削除の対応 chen add end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  @Select
  List<MstEquipment> selectEquipmentAllergy(SelectOptions options, MstEquipment params);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

  @Select
  List<MstEquipment> selectByClassType(SelectOptions options, MstEquipment params, List<Integer> typeCdList);

  @Select
  List<MstEquipment> selectByCdList(SelectOptions options, List<Integer> equipList);

  //add 10310 医療材料マスタから情報取得 gjn start
  @Select
  List<MstEquipment> selectByCdListCheckList(SelectOptions options, List<Integer> equipList, String facilityCd);
  //add 10310 医療材料マスタから情報取得 gjn end

  @Select
  MstEquipment selectByEquipmentCd(Integer equipCd);

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  @Select
  MstEquipment selectByEquipmentIncludeDelByCd(Integer equipCd);
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  /**
   * 帳票レイアウトデザイナーの医材フィルタの項目を返す.
   * @param facilityCd 施設コード
   * @return 薬剤リスト
   */
  @Select
  List<Equipment> selectByFacilityCd(String facilityCd);

  // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe start
  @Select
  List<Equipment> selectAllByFacilityCd(String facilityCd, String is_disp, String is_del);
  // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe end

  @Select
  List<MstEquipment> selectAllIncludeDeleted(SelectOptions options, MstEquipment params);

  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
  @Select
  List<MstEquipment> selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  @Insert(sqlFile = true)
  int insertMstEquipment(MstEquipment mstEquipment);
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  @Select
  String selectIsDisp(int cd);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.5678 李 start
  @Select
  String selectUnitValue(int cd);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.5678 李 end

  /*add FNSI-改修内容5204 任 start*/
  @Select
  List<MstEquipment> selectAllMstEquipmentUnit(SelectOptions options, MstEquipment params);
  /*add FNSI-改修内容5204 任 end*/

  @Override
  @Select
  List<Map<String,Object>> selectAllStatus(Map<String,String> params);
}
