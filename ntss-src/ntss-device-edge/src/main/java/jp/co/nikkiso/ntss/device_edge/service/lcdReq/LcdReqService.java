package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import java.sql.Timestamp;
import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;

import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq32;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq36;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq38;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq41;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq42;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq44;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq45;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq51;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq52;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq53;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.DailyReportResponse;
import jp.co.nikkiso.ntss.device_edge.response.lcdReq.LcdReqExamResponse;

public interface LcdReqService {
  /**
   * 仮想端末情報（酸素吸入）サービス
   */
  List<LcdReq32> lcdReq32SelectByNo(Long ordNo);

  /**
   * 仮想端末情報（ログ）サービス
   */
  List<LcdReq36> lcdReq36SelectMachineRecordMessage(String facilityCd, String machineTypeCd, String machineSerial, Timestamp fromDate, Long ordNo, Integer offset);

  /**
   * 仮想端末情報（体重トレンド）サービス
   */
  List<LcdReq38> lcdReq38SelectWeightAll(Long patId);

  /**
   * 仮想端末情報（透析日報）サービス
   */
  DailyReportResponse lcdReq40selectByNo(Long ordNo, Integer deviceEdgeNo);

  /**
   * 仮想端末情報（投与薬剤）サービス
   */
  List<LcdReq41> lcdReq41selectByNo(Long ordNo);

  /**
   * 仮想端末情報（抗凝固剤）サービス
   */
  LcdReq42 lcdReq42selectByNo(Long ordNo);

  /**
   * 仮想端末情報（禁忌）サービス
   */
  List<LcdReq44> lcdReq44SelectById(Long patId);

  /**
   * 仮想端末情報（メモ）サービス
   */
  List<LcdReq45> lcdReq45SelectById(Long patId);

  /**
   * 仮想端末情報（検査結果・検査グラフ）サービス
   * @throws JsonProcessingException
   */
  List<LcdReqExamResponse> lcdReqExamResult(Long patId) throws JsonProcessingException;

  /**
   * 仮想端末情報（穿刺／回収／担当）サービス
   */
  LcdReq51 lcdReq51SelectByNo(Long ordNo);

  /**
   * 仮想端末情報（指示／特記）サービス
   */
  List<LcdReq52> lcdReq52SelectByNo(Long ordNo);

  /**
   * 仮想端末情報（CTRトレンド）サービス
   */
  List<LcdReq53> lcdReq53SelectWeightAll(Long patId);
}
