package jp.co.nikkiso.ntss.admin_web.service.motionRecords;

import java.io.IOException;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.springframework.http.ResponseEntity;

import jp.co.nikkiso.ntss.admin_web.response.GatheringStatusResponse;
import jp.co.nikkiso.ntss.admin_web.response.MotionRecordsResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.DabGraphResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.DissolutionGraphResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.MachineGraphResponse;

/**
 * 装置動作記録のServiceインタフェース.
 */
public interface MotionRecordsService {

  /**
   * 装置動作記録のResponse作成.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param baseDate 基準日
   * @return 装置動作記録のResponse
   */
  MotionRecordsResponse createMotionRecordsResponse(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String userTypeCd,
      String baseDate
      );

  /**
   * 初期表示時に指定された期間内の装置動作記録を取得(createMotionRecordsResponseのオーバーロード).
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録のResponse
   */
  MotionRecordsResponse createMotionRecordsResponse(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String userTypeCd,
      String fromDate,
      String toDate
      );

  /**
   * 初期表示時に指定された期間内の装置動作記録を取得(createMotionRecordsResponseのオーバーロード).
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @param offset 開始位置
   * @return 装置動作記録のResponse
   */
  MotionRecordsResponse createMotionRecordsResponse(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String userTypeCd,
      String fromDate,
      String toDate,
      Integer limit,
      Integer offset
      );

  /**
   * 指定された期間内の装置動作記録のResponse作成.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   */
  MotionRecordsResponse createMotionRecordsResponseWithinPeriod(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String userTypeCd,
      String fromDate,
      String toDate
      );

  /**
   * 指定された期間内の装置動作記録のResponse作成(createMotionRecordsResponseWithinPeriodのオーバーロード).
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @param limit 件数
   * @param offset 開始位置
   * @param dataType データ種別
   * @param freeWord フリーワード
   */
  MotionRecordsResponse createMotionRecordsResponseWithinPeriod(
    String facilityCd,
    String machineTypeCd,
    String machineSerial,
    String userTypeCd,
    String fromDate,
    String toDate,
    Integer limit,
    Integer offset,
    List<Integer> dataType,
    String freeWord
    );


  /**
   * 指定された期間内の装置動作記録の総件数
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @param dataType データ種別
   * @param freeWord フリーワード
   */
  Integer createMotionRecordsTotal(
    String facilityCd,
    String machineTypeCd,
    String machineSerial,
    String userTypeCd,
    String fromDate,
    String toDate,
    List<Integer> dataType,
    String freeWord
    );

  /**
   * 装置動作記録詳細のResponseEntity作成.
   *
   * @param motionRecordNo 装置動作記録番号
   * @param dataType データ種別
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 装置番号
   * @param baseDate 基準日
   * @param offset スキップ行数
   * @return 装置動作記録詳細のRespoonseEntity
   * @throws IOException
   */
  ResponseEntity<?> createDetailResponse(
      Long motionRecordNo,
      Integer dataType,
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String baseDate,
      Integer offset
      ) throws IOException;

  /**
   * 装置動作記録番号に紐づくデータの対処フラグ・対処者を更新.
   *
   * @param motionRecordNo 装置動作記録番号
   * @param userId ユーザID
   * @param isCorrection 対処フラグ
   * @return 正常に更新が行われた場合、<code>true</code>を返す
   */
  boolean updateCorrection(String motionRecordNo, Long userId, String isCorrection);

  /**
   * 引数に紐づくデータの対処フラグ・対処者をすべて更新.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userId 対処者ID
   * @param dataType データ種別
   * @return 正常に更新が行われた場合、<code>true</code>を返す
   */
  boolean updateAllTargetCorrectinos(String facilityCd, String machineTypeCd, String machineSerial, Long userId, Integer dataType);

  /**
   * 一定期間内の、透析装置自己診断のグラフResponse作成.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param baseDate 基準日
   * @param weeks 指定期間(週)
   * @return 透析装置自己診断のグラフResponse
   * @throws IOException
   */
  MachineGraphResponse createMachineGraphResponse(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String baseDate,
      String weeks
      ) throws IOException;

  /**
   * 一定期間内の、DAB自己診断のグラフResponse作成.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param baseDate 基準日
   * @param weeks 指定期間(週)
   * @return DAB自己診断のグラフResponse
   * @throws IOException
   */
  DabGraphResponse createDabGraphResponse(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String baseDate,
      String weeks
      ) throws IOException;

  /**
   * 一定期間内の、溶解記録のグラフResponse作成.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param baseDate 基準日
   * @param weeks 指定期間(週)
   * @return 溶解記録のグラフResponse
   * @throws IOException
   */
  DissolutionGraphResponse createDissolutionGraphResponse(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String baseDate,
      String weeks) throws IOException;

  /**
   * データ収集ステータス取得.
   *
   * @param userId ユーザーID（内部）
   * @param facilityCd 施設コード
   * @return データ収集ステータスのResponse
   */
  GatheringStatusResponse getGatheringStatus(Long userId, String facilityCd);

  /**
   * 装置動作記録番号に該当する装置動作記録情報のサービス対応区分を更新する.
   *
   * @param motionRecordNo 装置動作記録番号
   * @param serviceSupportType 更新するサービス対応区分
   * @param serviceSupportUserId サービス対応区分を更新する利用者ID
   * @return 正常に更新が行われた場合、<code>true</code>を返却する.
   */
  boolean updateServiceSupport(Long motionRecordNo, String serviceSupportType, Long serviceSupportUserId);

  /**
   * 引数に紐づくデータのサービス対応区分及び対応者、更新日時を更新する.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param serviceSupportUserId サービス対応区分を更新する利用者ID
   * @return 正常に更新が行われた場合、<code>true</code>を返却する.
   */
  // mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
  // boolean updateAllServiceSupport(String facilityCd, String machineTypeCd, String machineSerial, Long serviceSupportUserId);
  boolean updateAllServiceSupport(String facilityCd, String machineTypeCd, String machineSerial, Long serviceSupportUserId, Integer dataType);
  // mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end

  /**
   * 与えられた装置情報と装置動作記録番号に該当する装置動作記録を取得する.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param motionRecordNo 装置動作記録番号
   * @return 装置情報および装置動作記録番号に該当する装置動作記録
   */
  MntMotionRecord findByMachineAndMotionRecordNo(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      Long motionRecordNo);


  /** add by SunZelin  2023-02-01 [CodeOptimization]  start */
  /**
   * データ種別に応じたグラフデータを一定期間分取得して返す
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param testType 診断種別
   * @param baseDate 基準日
   * @param weeks 指定期間(週)
   * @return
   * @throws IOException
   */
  ResponseEntity<?> getGraphData(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String testType,
      String baseDate,
      String weeks,
      EventLogMessage eventLogMessage) throws IOException;
  /** add by SunZelin  2023-02-01 [CodeOptimization]  end */
}
