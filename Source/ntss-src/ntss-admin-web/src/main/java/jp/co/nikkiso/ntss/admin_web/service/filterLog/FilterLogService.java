package jp.co.nikkiso.ntss.admin_web.service.filterLog;

import java.util.List;

import jp.co.nikkiso.ntss.core.logger.FileInfoModelLog;
import jp.co.nikkiso.ntss.core.logger.EventLogAPI;
import jp.co.nikkiso.ntss.core.logger.FilterConditionLogAPI;
// add 変更履歴画面追加 陳 start
import jp.co.nikkiso.ntss.core.logger.ChangeEventLogAPI;
import jp.co.nikkiso.ntss.core.logger.ChangeConditionLogAPI;
// add 変更履歴画面追加 陳 end
import java.io.File;

/**
 * フィルターログサービス
 *
 */
public interface FilterLogService {
	// 検索条件
	String searchCondition(long userId);
	// ログを読む
	List<EventLogAPI> ReadLog(String folderName, String fileName);
	// フィルターログ
	List<EventLogAPI> filterLog(FilterConditionLogAPI api) throws Exception;
	// 検索条件を更新する
	void saveSearchCondition(long userId, String conditions);
	FileInfoModelLog getFileSysLog(String path);
	FileInfoModelLog getFileSysLog(String path, String filter);
	File downloadFileLog(String path) throws Exception;

  //FNSI-修正 ログ対応 xiebzh add start
  List<EventLogAPI> filterMongoLog(FilterConditionLogAPI api) throws Exception;
// add 変更履歴画面追加 陳 start
  List<ChangeEventLogAPI> changeMongoLog(ChangeConditionLogAPI api) throws Exception;
// add 変更履歴画面追加 陳 end
  //FNSI-修正 ログ対応 xiebzh add end

  // ログ設定再読み込み処理
  String loggerSetFlgUpdate();

}
