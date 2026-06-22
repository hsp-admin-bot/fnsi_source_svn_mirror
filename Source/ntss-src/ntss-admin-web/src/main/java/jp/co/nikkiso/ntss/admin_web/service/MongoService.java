package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.constant.MstToMongoEnum;

import java.util.List;
import java.util.Map;

public interface MongoService {

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi start
  /**
   * insert latest data to mongodb
   * @param data               更新データ
   * @param masterPhysicalName マスタ物理名称
   * @param facilityCd         施設コード
   */
  void savePatDataToMongo(List<Map<String, Object>> data, String masterPhysicalName, String facilityCd);
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi end

  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen start
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  /**
   * mongoデータを更新し、pat_unique_historyに新しいデータを挿入する
   *
   * @param facilityCd     施設コード
   * @param updMasterInfos 更新データ
   * @param tableName      master table
   */
  void updateAndInsertPatUnique(String facilityCd, List<Map<String, Object>> updMasterInfos, MstToMongoEnum tableName);

  /**
   * データを更新し、pat_main_historyに新しいデータを挿入する
   *
   * @param facilityCd          施設コード
   * @param patIdAndDiseaseCds  患者関連病名コード関係
   * @param changeNameOrNot     単一フィールド名フラグの更新
   * @param updMasterInfos      更新データ
   * @param tableName           master table
   */
  void updateAndInsertPatMain(String facilityCd, Map<Long, List<Long>> patIdAndDiseaseCds, Boolean changeNameOrNot,
                                  List<Map<String, Object>> updMasterInfos, MstToMongoEnum tableName);

  /**
   * データを更新し、pat_personal_main_historyに新しいデータを挿入する
   *
   * @param facilityCd          施設コード
   * @param updMasterInfos      更新データ
   * @param tableName           master table
   */
  void updateAndInsertPatPersonalMain(String facilityCd, List<Map<String, Object>> updMasterInfos, MstToMongoEnum tableName);
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen end
}
