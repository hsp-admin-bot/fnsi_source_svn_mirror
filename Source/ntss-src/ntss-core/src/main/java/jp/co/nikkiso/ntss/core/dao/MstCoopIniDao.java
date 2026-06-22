package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopIniKey;
import jp.co.nikkiso.ntss.core.entity.custom.MstCoopIniInfo;

@ConfigAutowireable
@Dao
public interface MstCoopIniDao {
  /**
  * 連携設定マスタを取得する
  * @param facilityCd 施設コード
  * @return 連携設定マスタEntity
  */
  @Select
  List<MstCoopIni> selectByFacilityCd(String facilityCd);

  /**
   * コピー元の連携設定マスタを取得する
   * @param key0 ベンダーキー
   * @return 連携設定マスタEntity
   */
  @Select
  List<MstCoopIni> selectSourceByKey0(String key0);

  /**
  * 連携設定マスタを取得する
  * @param coopIniCd 連携設定番号
  * @return 連携設定マスタEntity
  */
  @Select
  MstCoopIni selectByCoopIniCd(Long coopIniCd);

  /**
  * 連携設定マスタを更新する
  * @param mci 連携設定マスタEntity
  * @return 0または1
  */
  @Update(sqlFile = true)
  int update(MstCoopIni mci);

  /**
  * 連携設定マスタを登録する
  * @param mci 連携設定マスタEntity
  * @return 0または1
  */
  @Insert(sqlFile = true)
  int insert(MstCoopIni mci);

  @Select
  String selectByCoopIniCdByFacilityCd(String facilityCd, String key0);
  
  @Select
  String selectByCoopIniDefaultByFacilityCd(String facilityCd, String key0);

  @Select
  List<MstCoopIniKey> selectCoopExtsetting(String facilityCd, String key0);

  @Select
  String selectDoctorTypeByFacilityCd(String facilityCd, String key0);

  @Select
  List<MstCoopIniKey> selectCoopExtsettinginidial(String facilityCd, String key0);

  @Select
  Map<String,Object> selectBedCodeByFacilityCd(String facilityCd, String key0);

  @Select
  MstCoopIniInfo selectCoopIniInfo(String facilityCd, String key0, String key1, String key2);

  @Select
  List<MstCoopIniInfo> selectCoopIniInfoExtends(String facilityCd, String key0, String key1);

  @Select
  List<MstCoopIniInfo> selectCoopIniInfoForNormal(String facilityCd, String key0, String key1, String key2);

  @Select
  String selectCoopIniInfoValue(String facilityCd, String key0, String key1, String key2);

  @Select
  String selectByCoopIniCdBycoop(String facilityCd, String key0,String coopcd);

  @Select
  String selectDefaultcoop(String facilityCd, String key0,String coopcd);
  
  @Select
  List<MstCoopIniInfo> selectCoopIniInfoListSortByKey2(String facilityCd, String key0, String key1);
}
