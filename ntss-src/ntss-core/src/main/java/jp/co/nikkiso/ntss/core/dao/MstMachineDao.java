package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachineDatalist;
import jp.co.nikkiso.ntss.core.entity.MstMachineDatalistInit;
import jp.co.nikkiso.ntss.core.entity.MstMachineDatalistMainte;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.custom.MstMachineWithState;
import jp.co.nikkiso.ntss.core.entity.custom.ComTypeAndFormatCd;
import jp.co.nikkiso.ntss.core.entity.custom.MachineKeyInfo;

/**
 * 装置マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMachineDao {

  @Select
  List<MstMachine> selectAll();

  @Select
  MstMachine selectByCd(String machineTypeCd, String machineSerial, String facilityCd);

  @Insert
  int insert(MstMachine mstMachine);

  @Delete
  int delete(MstMachine mstMachine);

  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);

  @Update
  int update(MstMachine mstMachine);

  /**
   * 生体モニタリング用、状態付き装置取得
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Select
  List<MstMachineWithState> selectWithState(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 施設内装置一覧取得
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<MstMachine> selectByFacility(String facilityCd);

  @Select
  List<MstMachine> selectByFacilityAndDeviceEdgeNoAndMachineNo(String facilityCd,Integer deviceEdgeNo,Long machineNo);

  //add 7071 【デグレ】通知がされない 関俊楠 start
  @Select
  List<MstMachine> selectByFacilityAndIp(String facilityCd, String ip);
  //add 7071 【デグレ】通知がされない 関俊楠 end
  /**
   * 装置の通信種別と通信フォーマットを取得.
   *
   * @param facilityCd 施設コード.
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   */
  @Select
  ComTypeAndFormatCd selectComTypeAndFormatCd(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 指定条件の装置情報一覧(ip_addressが空以外)を取得する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号(-1で全デバイスエッジを取得)
   * @return
   */
  @Select
  List<MstMachine> selectByFacilityAndDeviceEdgeNo(String facilityCd, int deviceEdgeNo);

  /**
  * 指定条件の装置情報一覧(ip_addressが空も含む)を取得する
  * @param facilityCd 施設コード
  * @param deviceEdgeNo デバイスエッジ番号(-1で全デバイスエッジを取得)
  * @return
  */
 @Select
 List<MstMachine> selectByFacilityAndDeviceEdgeNoAndNullIpAddress(String facilityCd, int deviceEdgeNo);

  /**
   * 装置オプションを更新
   * @param param 装置情報
   */
  @Update(sqlFile = true)
  int updateMachineOption(MstMachine param);

  /**
   * オーダー番号から関連付けられている装置の情報を取得する
   * オーダー番号→指示ベッド→関連付けられている装置
   * @param ordNo 指示番号
   * @return
   */
  @Select
  List<MstMachine> selectByOrdNoInd(Long ordNo);

  /**
   * オーダー番号から関連付けられている装置の情報を取得する
   * オーダー番号→実績装置番号→関連付けられている装置
   * @param ordNo 指示番号
   * @return
   */
  @Select
  List<MstMachine> selectByOrdNoRst(Long ordNo);

  /**
   * オーダー番号から関連付けられている装置の情報を取得する
   * オーダー番号→実績ベッドCd→関連付けられている装置
   * @param ordNo 指示番号
   * @return
   */
  @Select
  List<MstMachine> selectByOrdNoAndRstBedCd(Long ordNo);

  /**
   * 装置番号から装置情報を取得
   * @param machineNo
   * @return
   */
  @Select
  MstMachine selectByMachineNo(Long machineNo);

  /**
   * 装置番号から装置識別に必要な情報を取得
   * @param machineNo
   * @param isDisp
   * @param isDel
   * @return
   */
  @Select
  MachineKeyInfo selectKeyWithModelByMachineNo(String facilityCd, Long machineNo, String isDisp, String isDel);

  /**
   * ベッド番号から関連付けられている装置の情報を取得する
   * @param bedCd ベッド番号
   * @return
   */
  @Select
  List<MstMachine> selectByBedCd(String facilityCd, Long bedCd);

  /**
   * 施設内装置一覧取得
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<MstMachine> selectByFacilityMappingSelector(String facilityCd);

  /**
   * 患者が条件送信済み～治療中の装置一覧取得
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<MstMachine> selectDialysisEntryMachines(String facilityCd);

  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  @Select
  String selectIsDisp(int cd);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

  // add FNSI-新規 装置情報（自己診断） dou start
  @Select
  List<MstMachineDatalist> selectDatalist(String startDate, String endDate, String facilityCd);

  @Select
  List<MstMachineDatalistInit> selectDatalistInitSelf(String facilityCd);

  @Select
  List<MstMachineDatalistInit> selectDatalistInit(String facilityCd);

  @Select
  List<MstMachineDatalistMainte> selectDatalistMainte(String startDate, String endDate, String facilityCd);

  @Select
  List<MstMachineDatalistMainte> selectDatalistMainteInit(String startDate, String endDate, String facilityCd);
  // add FNSI-新規 装置情報（自己診断） dou end

  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
  @Select
  Long selectByFacilitySo2Count(String facilityCd);
  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end

  // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
  // 装置マスタの表示順を取得する
  @Select
  String selectIndexNoFromMstMachine(String facilityCd,String machineTypeCd, String machineSerial);
  // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  @Select
  List<Long> selectByMachineTypeCd(String facilityCd, String machineTypeCd);
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
}
