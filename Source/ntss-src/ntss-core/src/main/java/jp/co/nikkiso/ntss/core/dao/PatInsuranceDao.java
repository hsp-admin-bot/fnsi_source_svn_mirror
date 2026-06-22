package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatInsuranceConditions;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.custom.InsuInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuranceName;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;

import java.util.List;


@ConfigAutowireablePersonalDb
@Dao
public interface PatInsuranceDao {
  @Select
  List<PatInsurance> getListPatInsuranceById(Long patId);

  @Select
  List<PatInsuranceName> getListPatInsuranceNameByIdAndCd(Long patId, String facilityCd, int insuClass);

  @Select
  PatInsuranceName getPatInsuranceNameById(Long ordPrescriptionNo);

  @Select
  InsuInfo getInsuInfoByCd(Long insuranceCd);

  @Insert(sqlFile = true)
  int insert(PatInsuInfo patInsurance);

  @Update(sqlFile = true)
  int updateById(PatInsuInfo patInsurance);

  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
  @Update(sqlFile = true)
  int updateByIdDel(PatInsuInfo patInsurance);
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end

  @Select
  PatInsurance selectById(Long insuCd);
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Select
  PatInsurance selectByCd(Long insuCd);
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @Select
  Long selectNextSeqInsuCd();

  @Select
  List<PatInsurance> selectByPatId(Long patId, String facilityCd);

  @Insert
  int insert(PatInsurance patInsurance);

  @Update(excludeNull = true)
  int update(PatInsurance patInsurance);

  @Select
  PatInsurance selectForCoop(Long patId, String facilityCd, Integer insuClass, String coopCode);

  // add FNSI-保険選択の変更 関 start
  @Update(sqlFile = true)
  int clearSelectByPatId(Long patId);

  @Update(sqlFile = true)
  int updateSelectByCd(Long insurancdCd , Integer isSelected);

  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
  @Update(sqlFile = true)
  int clearSelectByPatIdFacilityCd(Long patId, String facilityCd);

  @Update(sqlFile = true)
  int updateSelectByCdFacilityCd(Long insurancdCd, Integer isSelected, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
  // add FNSI-保険選択の変更 関 end
  @Select
  List<Long> selectByDetailedSearchCondition(PatInsuranceConditions conditions, List<Long> patIdList, List<String> facilityCdList);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<PatInsurance> selectByIdListFacilityCd(List<Long> patIdList, String facilityCd);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi start
  @Select
  List<PatInsurance> selectAllByClass(List<Long> patIdList, String facilityCd, Integer insuClass);

  @Select
  List<PatInsurance> selectAllByUsedInsuranceCd(List<String> insuranceCdList, String facilityCd);
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi end

  @Select
  PatInsurance selectByIdNoDecrypt(Long insuCd);
}

