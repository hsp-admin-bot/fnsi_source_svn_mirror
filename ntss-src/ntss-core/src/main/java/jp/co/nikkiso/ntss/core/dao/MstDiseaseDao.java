package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstDisease;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;

@ConfigAutowireable
@Dao
public interface MstDiseaseDao {

  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
  @Select
  String getTotal(String facilityCd);

  @Select
  List<MstDisease> getMstDiseaseByLimitAndOffset(Integer limit, String facilityCd, Integer offset);
  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end
	// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Select
  MstDisease selectByCd(int diseaseCd);
	// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @Select
  List<MstDisease> selectAll(SelectOptions options, MstDisease params);
  // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<MstDisease> selectAllDisease();
  // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstDisease> selectAllName(List<Integer> diseaseCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  @Select
  List<MstDisease> selectAllIncludeDeleted(SelectOptions options, MstDisease params);

  /* mod #8592 by zhangruixue 2023-05-11 --start */
  @Select
  List<String> selectDiseaseCodeByFacilityCd(String facilityCd);
  /* mod #8592 by zhangruixue 2023-05-11 --end */

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  //No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<MstDisease> getMstDiseaseInfoByFacilityCd(String facilityCd);
  //No.7167 upd Paging Optimization runtime by ztc end

  // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
  @Select
  List<MstDisease> getMstDiseaseByCds(Integer[] diseaseCds);
  // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  @Select
  List<MstDisease> selectByCds(List<Integer> diseaseCds);
  // add 10626 データリストのCTR・DW一括登録修正 房 end
}
