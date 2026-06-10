package jp.co.nikkiso.ntss.admin_web.service.facilityCalendar;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.FacilityCalendar;

/**
 * 施設カレンダーサービス.
 */
public interface FacilityCalendarService {

	/**
	   * データ機能カレンダーを取得.
	   * @param startDate 開始日
	   * @param endDate 終了日
	   * @param facilityCd 施設コード
	   * @param facCalLayoutCd 施設カレンダーレイアウトコード
	   */
	List<FacilityCalendar> getDataFacilityCalendar(String startDate, String endDate, Long facCalLayoutCd, String facilityCd);
	
	/**
	   * 患者情報を取得する.
	   * @param itemName 施設カレンダーのレイアウト項目
	   * @param date 日付
	   * @param facilityCd 施設コード
	   */
	List<PatPersonalMain> getPatByItemInFacilityCalendar(String itemName,String date, String facilityCd);
}
