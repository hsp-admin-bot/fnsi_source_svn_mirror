package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.BatchInsert;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;
import jp.co.nikkiso.ntss.core.entity.custom.ChargeStaffFacility;

/**
 * 担当者施設マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstStaffFacilityDao {

  @Select
  List<MstStaffFacility> selectAll();

  @Select
  List<MstStaffFacility> selectByUserId(Long userId);

  @Select
  MstStaffFacility selectByKey(Long userId, String facilityCd);

  @Insert
  int insert(MstStaffFacility mstStaffFacility);

  @Delete
  int delete(MstStaffFacility mstStaffFacility);

  @Update
  int update(MstStaffFacility mstStaffFacility);

  /**
   * ユーザIDに紐づく施設の施設ID・施設名抽出.
   *
   * @param userId ユーザID
   * @return 担当者施設情報
   */
  @Select
  List<ChargeStaffFacility> selectStaffFacilities(Long userId);

  // add FNSI redmine #4243 修正 鄧シン start
  @Select
  List<ChargeStaffFacility> selectStaffFacilitiesOrderByPrefCd(Long userId);
  // add FNSI redmine #4243 修正 鄧シン end

  /**
   * 全施設に対して担当施設マスタ情報を結合した施設情報を取得.
   * @param userId ユーザーID
   * @return 全施設＋担当フラグ
   */
  @Select
  List<ChargeStaffFacility> selectChargeStaffFacilities(Long userId);

  @Select
  List<ChargeStaffFacility> selectChargeStaffSharingFacilities(Long userId);

  /**
   * ユーザーIDに紐付くレコードを削除.
   *
   * @param userId ユーザーID
   * @return 削除件数
   */
  @Delete(sqlFile = true)
  int deleteByUserId(Long userId);

  /**
   * バッチ挿入.
   *
   * @param entities 担当施設マスタEntityのリスト
   * @return 挿入件数の配列
   */
  @BatchInsert
  int[] insert(List<MstStaffFacility> entities);
}
