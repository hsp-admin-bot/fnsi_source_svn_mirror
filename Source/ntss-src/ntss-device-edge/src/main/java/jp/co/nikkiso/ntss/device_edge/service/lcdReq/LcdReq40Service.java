package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.DailyReportResponse;

public interface LcdReq40Service {
   /**
   * 仮想端末情報（透析日報）サービス
   */
  DailyReportResponse selectByNo(Long ordNo, Integer deviceEdgeNo);

 }
