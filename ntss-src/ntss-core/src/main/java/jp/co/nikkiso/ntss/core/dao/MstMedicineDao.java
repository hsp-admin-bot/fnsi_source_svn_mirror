package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;
import java.util.Map;

@ConfigAutowireable
@Dao
public interface MstMedicineDao extends MasterDao<Map<String,Object>>, UnifiedByCodeListDao {
  @Select
  List<MstMedicine> selectAll(SelectOptions options, MstMedicine params);

  // add FNSI-期限切れ削除済みと表示するの修正 start
  @Select
  List<MstMedicine> selectAllDel(SelectOptions options, MstMedicine params);
  @Select
  MstMedicine selectByCdNoDel(String facilityCd, Integer medicineCd);
  // add FNSI-期限切れ削除済みと表示するの修正 end

  @Select
  MstMedicine selectByCd(String facilityCd, Integer medicineCd);

  @Select
  MstMedicine selectByMediCd(Integer medicineCd);

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  @Select
  MstMedicine selectIncludeDelByMediCd(Integer medicineCd);
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
  @Select
  MstMedicine selectAllByMediCd(Integer medicineCd);
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

  @Select
  List<MstMedicine> selectAllByCdList(SelectOptions options, List<Integer> medicineList);

  //add 10310 薬剤マスタから情報取得 gjn start
  @Select
  List<MstMedicine> selectAllByCdListCheckList(SelectOptions options, List<Integer> medicineList, String facilityCd);
  //add 10310 薬剤マスタから情報取得 gjn end

  @Select
  List<MstMedicine> selectAllIncludeDeleted(SelectOptions options, MstMedicine params);

  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
  @Select
  List<MstMedicine> selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  @Insert(sqlFile = true)
  int insertMstMedicine(MstMedicine mstMedicine);
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end

  /*add FNSI-改修内容5204 任 start*/
  @Select
  List<MstMedicine> selectAllMstMedicineUnit(SelectOptions options, MstMedicine params);
  /*add FNSI-改修内容5204 任 end*/

  // add FNSI-改修内容6618修正 xuty start
  // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
  @Select
  List<String> selectByStandardMedicineCd(String facilityCd, List<String> standardMedicineCdList);
  // mod #11718 【#11600持ち越し】データリスト画面不正② fang end
  // add FNSI-改修内容6618修正 xuty end

  @Override
  @Select
  List<Map<String,Object>> selectAllStatus(Map<String,String> params);

  @Override
  @Select
  List<Map<String, Object>> selectAllStatusByCodeList(List<Integer> codeList);
}
