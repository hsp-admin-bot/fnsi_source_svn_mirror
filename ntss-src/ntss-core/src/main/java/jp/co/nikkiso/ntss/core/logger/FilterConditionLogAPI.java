package jp.co.nikkiso.ntss.core.logger;

import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonSetter;
import com.fasterxml.jackson.annotation.Nulls;
import lombok.Data;

@Data
public class FilterConditionLogAPI {

	// 日付から
	private String strFromDate;
	// 現在まで
	private String strToDate;
	// 施設コード
	private List<String> facilityCd;
	// ログタイプ
	private String logType;
	// ユーザーID
	private String userId;
	// サービス名
	private String serviceName;
	// 患者ID
	private String patId;
	// 分類
	private String classification;
	// キーワード検索
	private String keySearch;
	// 検索タイプ
	private int typeSearch;
	// モジュール名
	private String moduleName;
	//add FNSI-mongoDBに挿入、検索できることの対応 start
	private int limitTo;
	private String sortKey;
	private Boolean sortOrder;
  @JsonSetter(nulls = Nulls.SKIP)
  private int pageSize;
	//add FNSI-mongoDBに挿入、検索できることの対応　end
  //add FNSI-#6547ログ表示不正の修正。　start
  @JsonSetter(nulls = Nulls.SKIP)
  private int filterTimes;
  //add FNSI-#6547ログ表示不正の修正。　end
  // add #6775 ログの抽出が正しく行われない 鄭爽 start
  private List<Map<String, Object>> displayItems;
  // add #6775 ログの抽出が正しく行われない 鄭爽 end
}
