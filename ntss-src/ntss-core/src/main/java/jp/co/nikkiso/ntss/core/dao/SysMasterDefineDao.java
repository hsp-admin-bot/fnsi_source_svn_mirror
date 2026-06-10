package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysMedicine;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;

/**
 * マスタ定義のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysMasterDefineDao {

  /**
   * 指定されたマスタの情報を取得.
   * @param masterPhysicalName マスタ物理名
   * @return 指定マスタのマスタ定義エンティティ
   */
  @Select
  SysMasterDefine selectByName(String masterPhysicalName);

  // add #6217 全施設マスタ画面が遅い guanhao start
  /**
   * マスタ情報を取得する.
   * 本メソッドでは取得開始位置(offset)と取得件数(limit)を指定する.
   *
   * @param limit 取得上限件数
   * @param offset 開始位置
   * @return {@link SysMedicine}のリスト
   */
  @Select
  List<SysFacility> selectSysFacilityByLimitAndOffset(Integer limit, Integer offset, String keyword);

  @Select
  List<SysFacility> selectSysFacilityAfterSaveByLimit(Integer limit, String keyword, List<String> medicalInstitutionCds);

  /**
   * マスタを件数取得する
   */
  @Select
  String getTotal();
  // add #6217 全施設マスタ画面が遅い guanhao end

  /**
   * 利用者種別によってマスタ一覧情報を取得.
   *
   * @param userType 利用者種別
   * @return マスタ一覧情報
   */
  @Select
  List<SysMasterDefine> selectByUserType(String userType);
}
