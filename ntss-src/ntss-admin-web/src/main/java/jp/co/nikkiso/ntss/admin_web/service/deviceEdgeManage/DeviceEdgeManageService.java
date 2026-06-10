package jp.co.nikkiso.ntss.admin_web.service.deviceEdgeManage;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage.DeviceEdgeManageResponse;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage.ResponseS3Bucket;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import jp.co.nikkiso.ntss.core.entity.custom.DeviceEdgeStateWithManage;

/**
 * デバイスエッジアップデータ―等指示出しのServiceインタフェース.
 */
public interface DeviceEdgeManageService {

  /**
   * アプリケーションバージョン情報を含むデバイスエッジの状態を取得する
   * @return
   */
  List<DeviceEdgeStateWithManage> getDeviceEdgeState();
  /**
   * アプリケーションバージョン情報を含むデバイスエッジの状態を取得する
   * @param facilityCd 対象施設コード
   * @param DeviceEdgeNo デバイスエッジ番号
   * @return
   */
  DeviceEdgeStateWithManage getDeviceEdgeState(String facilityCd, int deviceEdgeNo);

  /**
   * 指示種別から指示ペイロードを取得
   * @param category
   * @return
   */
  String getTopicString(Short category);

  MntDeviceEdgeManage selectByManageNo(Long manageNo);

  /**
   * デバイスエッジ指示情報を新規登録し、管理番号を返す
   * @param param
   * @return
   */
  Long insertNewRecordManageNo(MntDeviceEdgeManage param);

  /**
   * デバイスエッジ指示内容を更新
   * @param param
   * @return
   */
  Long updateManageOrderInfo(Long manageNo, short responseStatus, String topic, String payload);

  /**
   * デバイスエッジ指示失敗情報を保存
   * @param param
   * @return
   */
  Long updateManageError(Long manageNo, short responseStatus, String errorMessage);

  /**
   * ダウンロードするログファイルの情報を取得
   * @param facilityCd
   * @param deviceEdgeNo
   * @param dateStr
   * @return
   */
  ResponseS3Bucket findLogInfo(String facilityCd, int deviceEdgeNo, String dateStr);

  /**
   * ダウンロードするConfファイルの情報を取得
   * @param s3Bucket
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  ResponseS3Bucket findConfS3Info(String s3Bucket, String facilityCd, int deviceEdgeNo);

  /**
   * アップロードするConfファイル置き場を取得
   * @param s3Bucket
   * @param deviceEdgeNo
   * @return
   */
  ResponseS3Bucket findConfS3UpTarget(String s3Bucket, int deviceEdgeNo);

  /* add by SongJiHao  2023-02-01 [Transaction,Remote]  start */
  /**
   * 指示
   * @return
   */
  DeviceEdgeManageResponse sendOrderToEdge(
    NtssUser ntssUser,
    String targetFacilityCd,
    Integer deviceEdgeNo,
    MntDeviceEdgeManage param,
    MntDeviceEdgeManage.ManageInfo manageInfo,
    Short appType,
    String planDate);

  /**
   * 指示
   * @return
   */
  DeviceEdgeManageResponse sendOrderToEdge(
    NtssUser ntssUser,
    String targetFacilityCd,
    Integer deviceEdgeNo,
    MntDeviceEdgeManage param,
    MntDeviceEdgeManage.ManageInfo manageInfo,
    Short appType);
  /* add by SongJiHao  2023-02-01 [Transaction,Remote]  end */
}
