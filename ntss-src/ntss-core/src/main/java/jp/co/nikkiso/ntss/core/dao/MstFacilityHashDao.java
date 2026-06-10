package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstFacilitySetting;

/**
 * 施設マスタハッシュのDaoインタフェース.
 */
@ConfigAutowireableAuthDb
@Dao
public interface MstFacilityHashDao {
  //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
  /**
   * 登録値を更新.
   * @param facilityCd 施設CODE
   * @param value 値
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateValue(String facilityCd, String value);
  //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
  /**
   * ハッシュ値に紐付くレコードを取得.
   * @param hashValue ハッシュ値
   * @return 施設コードハッシュ情報
   */
  @Select
  MstFacilityHash selectByHashValue(String hashValue);

  /**
   * ハッシュ値に紐付くレコードを取得.
   * (対象がない場合、0の値が返却される)
   * @param hashValue ハッシュ値
   * @return 施設コードハッシュ情報
   */
  @Select
  MstFacilityHash findByHashValue(String hashValue);

  /**
   * ハッシュ値に紐付く施設コードを取得(複数のハッシュ値でまとめて取得).
   * @param hashValueList ハッシュ値
   * @return 施設コードのリスト
   */
  @Select
  List<String> findByHashValueList(List<String> hashValueList);

  /**
   * 施設コードに紐付くレコードを取得.
   * @param facilityCd 施設コード
   * @return 施設コードハッシュ情報
   */
  @Select
  MstFacilityHash selectByFacilityCd(String facilityCd);

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<MstFacilityHash> selectByFacilityCdList(List<String> facilityCdList);
  // Add By HandsomeLin At 2023/02/16 End

  /**
   * 全レコードを取得.
   * @return 施設コードハッシュ情報
   */
  @Select
  List<MstFacilityHash> selectAll();

  @Insert(sqlFile = true)
  int insert(MstFacilityHash mstFacilityHash);

  @Update(sqlFile = true)
  int update(MstFacilityHash mstFacilityHash);

  @Delete(sqlFile = true)
  int deleteByCd(String facilityCd);

  /**
   * サインイン失敗設定の更新 .
   * @param mstFacilitySetting 施設設定情報リスト
   * @param facilityCd 施設コード
   * @param upDate 更新日時
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateByFacilityCd(List<MstFacilitySetting> mstFacilitySettingList, String facilityCd, Timestamp upDate);
  // add 20210824 #61411：施設のリストを取得する  鄭 start
  /**
   * 施設のリストを取得する
   * @return
   */
  @Select
  List<String> selectFacilityCdInfo();
  //add 20210824 #6141 施設のリストを取得する  鄭 start
}
