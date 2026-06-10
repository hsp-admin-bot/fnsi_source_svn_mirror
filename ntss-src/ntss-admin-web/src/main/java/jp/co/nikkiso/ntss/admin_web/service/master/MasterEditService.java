package jp.co.nikkiso.ntss.admin_web.service.master;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;

/**
 * マスタ編集のServiceインタフェース.
 */
public interface MasterEditService {

  /**
   * マスタデータの取得.
   *
   * @param facilityCd 施設コード
   * @param            masterName(マスタ名称(物理名))
   * @return マスタデータ情報.
   */
  MasterDataResponse getMasterData(String masterName, String facilityCd);

  // add #6217 全施設マスタ画面が遅い guanhao start
  /**
   * 標準医薬品マスタを取得します.分页
   */
  List<SysFacility> getSysFacilityByLimitAndOffset(Integer limit, Integer offset,String recordName);

  /**
   * 標準医薬品マスタを取得します.分页
   */
  List<SysFacility> getSysFacilityAfterSaveByLimit(Integer limit, String keyword, List<String> medicalInstitutionCds);

  /**
   * マスタを件数取得する
   */
  String getTotal();
  // add #6217 全施設マスタ画面が遅い guanhao end
  /**
   * マスタデータの取得(SQL指定).
   *
   * @param facilityCd 施設コード
   * @param            masterName(マスタ名称(物理名))
   * @return マスタデータ情報.
   */
  MasterDataResponse getMasterDataWithSql(String masterName, String facilityCd);

  /**
   * マスタデータの更新.
   *
   * @param masterPhysicalName マスタ物理名称
   * @param facilityCd         施設コード
   * @param updateData         画面で編集したマスタデータ
   * @return マスタデータ更新結果(成功フラグとエラーメッセージ)
   */
  MasterUpdateResponse updateMasterData(String masterPhysicalName, String facilityCd,
      List<Map<String, Object>> updateData);

  /**
   * マスタ定義情報の取得.
   *
   * @param masterName マスタ名称（物理名）
   * @return マスタ定義情報.
   */
  SysMasterDefine.ColumnInfo getColumnInfo(String masterName);

  /**
   * マスタセレクタ作成.
   *
   * @param facilityCd         施設コード
   * @param string マスタ名
   * @param data               画面で編集したデータ
   */
  void createMstSelector(String facilityCd, String string, List<Map<String, Object>> data);


  // add 7686 修正 chen start
  List<String> getMstComsvBed(List<String> deviceEdgeNoList, String facilityCd);
  // add 7686 修正 chen end

}
