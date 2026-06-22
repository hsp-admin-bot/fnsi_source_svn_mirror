package jp.co.nikkiso.ntss.core.entity;

import java.util.List;

import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainSharingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;

import lombok.Getter;
import lombok.Setter;

/**
 * 患者名の識別Entity.
 */
@Getter
@Setter
public class PatCalendarEvent {

  //指示リスト
	private List<OrdMainSharingInfo> indInfoList;

	//検査結果リスト
	private List<PatExamMainData> examResultInfoList;

	//検査予定リスト
	private List<PatExamMainData> examRequestInfoList;

	//一般撮影検査予定リスト
	private List<ForecastInforResult> indicationInfoList;

	//処方リスト
  private List<ForecastInforResultForCount> prescriptionInfoList;

  //患者イベントリスト
  private List<ForecastInforResultForPatEventCount> patEventCountInfoList;

  //施設イベントリスト
  private List<BbsInfo> bbsInfoList;

  //add #12462 患者共有情報- 患者カレンダー  by zrx start
  private List<PatMain> patMainList;
  //add #12462 患者共有情報- 患者カレンダー  by zrx end

}
