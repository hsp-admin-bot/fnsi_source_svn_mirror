package jp.co.nikkiso.ntss.coop_api.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.Stack;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.custom.MstCoopIniInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class ConvertDocumentContentService {
	private static final String DOUBLE_BYTE_SPACE = "　"; // 全角スペース

	/// <summary>[セクション]カルテ記載連携-内容</summary>
	private static final String SEC_MEDI_REC_SEND_CONTENTS = "MEDI_REC_SEND_CONTENTS";

	private static final String PAT_EVENT_TEMPLATE_SETTING = "PAT_EVENT_TEMPLATE_SETTING";

	/// <summary>テーブル定義文字</summary>
	private static final String TABLE_MARK = "$";
	/// <summary>前回情報定義文字</summary>
	private static final String TXT_PRE = "#PRE#";
	/// <summary>内部変換後前回情報定義文字</summary>
	private static final String TXT_TRANS_PRE = "PRE/";
	/// <summary>終端文字</summary>
	private static final String TXT_EOF = "#EOF#";
	/// <summary>加算定義文字</summary>
	private static final String TXT_ADD = "ADD";
	/// <summary>減算定義文字</summary>
	private static final String TXT_SUB = "SUB";
	/// <summary>乗算定義文字</summary>
	private static final String TXT_MUL = "MUL";
	/// <summary>除算定義文字</summary>
	private static final String TXT_DIV = "DIV";
	/// <summary>条件分岐定義文字</summary>
	private static final String TXT_IF = "IF";

	/// <summary>[テーブル名]患者情報</summary>
	private static final String TBL_PAT_PERSONAL_MAIN = "pat_personal_main";
	/// <summary>[テーブル名]治療情報</summary>
	private static final String TBL_ORD_MAIN = "ord_main";
	/// <summary>[テーブル名]装置モニタデータ</summary>
	private static final String TBL_MNI_MONITOR = "mni_monitor";
	/// <summary>[テーブル名]薬剤情報</summary>
	private static final String TBL_MST_TREATMENT = "mst_treatment";
	/// <summary>[テーブル名]治療イベント</summary>
	private static final String TBL_PAT_EVENT = "pat_event";
	/// <summary>[テーブル名]患者基本情報</summary>
	private static final String TBL_PAT_MAIN = "pat_main";

	@Autowired
	private LogService logService;

	// キャッシュ
	private static class CacheContext {
		Map<String, List<MstCoopIniInfo>> mstCoopIniInfoValueCache = new HashMap<>();
		Map<String, PatPersonalMain> patPersonalMainCache = new HashMap<>();
		Map<String, OrdMain> ordMainCache = new HashMap<>();
		Map<String, MstTreatment> mstTreatmentCache = new HashMap<>();
		Map<String, MstDialyzer> mstDialyzerCache = new HashMap<>();
		Map<String, MstEquipment> mstEquipmentCache = new HashMap<>();
		Map<String, MstMedicine> mstMedicineCache = new HashMap<>();
		Map<String, MstMedicineMix> mstMedicineMixCache = new HashMap<>();
		Map<String, MniMonitor> mniMonitorCache = new HashMap<>();
		Map<String, List<PatEvent>> patEventCache = new HashMap<>();
		Map<String, List<OrdMain>> lastOrdMainCache = new HashMap<>();
		Map<String, MstVa> mstVaCache = new HashMap<>();
		Map<String, MstPersonalUser> mstPersonalUserCache = new HashMap<>();
		Map<String, MstDialysisDifficulty> mstDialysisDifficultyCache = new HashMap<>();
		Map<String, PatMain> patMainCache = new HashMap<>();

	}

	@Autowired
	MstCoopIniDao mstCoopIniDao;

	@Autowired
	PatPersonalMainDao patPersonalMainDao;

	@Autowired
	OrdMainDao ordMainDao;

	@Autowired
	MstTreatmentDao mstTreatmentDao;

	@Autowired
	MstDialyzerDao mstDialyzerDao;

	@Autowired
	MstEquipmentDao mstEquipmentDao;

	@Autowired
	MstMedicineDao mstMedicineDao;

	@Autowired
	MstMedicineMixDao mstMedicineMixDao;

	@Autowired
	MniMonitorDao mniMonitorDao;

	@Autowired
	PatEventDao patEventDao;

	@Autowired
	MstVaDao mstVaDao;

	@Autowired
	MstPersonalUserDao mstPersonalUserDao;

	@Autowired
	MstDialysisDifficultyDao mstDialysisDifficultyDao;

	@Autowired
	PatMainDao patMainDao;

	/**
	 * 指定された SysCoopJournal の情報と設定値から連携内容を生成し、最終的なドキュメント内容文字列を作成します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @return 生成されたドキュメント内容の文字列
	 */
	public String createContents(SysCoopJournal journal) {
		CacheContext cache = new CacheContext();
		List<MstCoopIniInfo> mstCoopIniInfoList = getMstCoopIniInfoList(journal, cache);
		StringBuilder resultString = new StringBuilder();
		for (MstCoopIniInfo mstCoopIniInfo : mstCoopIniInfoList) {
			String contentLine = mstCoopIniInfo.getVal();
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "contentLine:[" + contentLine + "] key2:[" + mstCoopIniInfo.getKey2() + "]");
			if (contentLine.contains(TXT_EOF)) {
				// 最終的な出力結果から残った $ 記号を除去
				String finalResult = resultString.toString();
				// $記号と、それに隣接する空白を除去（$ の前後どちらにある空白も除去）
				finalResult = finalResult.replaceAll("\\$ ", "").replaceAll(" \\$", "").replaceAll("\\$", "");
				return finalResult;
			}
			if (contentLine.trim().isEmpty()) {
				resultString.append(DOUBLE_BYTE_SPACE).append("\n");
				continue;
			}
			if (contentLine.contains(TXT_PRE)) {
				contentLine = contentLine.replace(TXT_PRE, TXT_TRANS_PRE);
			}

			String[] tokens = divideString(contentLine);
			StringBuilder tokenResult = new StringBuilder();
			boolean skipEntireLine = false;

			for (String token : tokens) {
				if (token.isEmpty())
					continue;
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "token:" + token);

				if (token.contains(TXT_IF + "(")) {
					String ifResult = processIf(journal, token, cache);
					if (ifResult == null) {
						// IF構文によりスキップ指示 - contentLine全体をスキップ
						skipEntireLine = true;
						break;
					}
					tokenResult.append(ifResult);
				} else if (token.contains(TXT_ADD + "(") || token.contains(TXT_SUB + "(") || token.contains(TXT_MUL + "(")
						|| token.contains(TXT_DIV + "(")) {
					String calcResult = calc(journal, token, cache);
					if (calcResult == null) {
						// 計算式によりスキップ指示 - contentLine全体をスキップ
						skipEntireLine = true;
						break;
					}
					tokenResult.append(calcResult);
				} else {
					String[] subtokens = token.split("\\" + TABLE_MARK);
					for (String subtoken : subtokens) {
						if (!subtoken.isEmpty()) {
							String data = processControlCommand(journal, subtoken, cache);
							outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "subtoken:" + subtoken);
							outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "data:" + data);
							if (data == null) {
								// 制御コマンドによりスキップ指示 - contentLine全体をスキップ
								skipEntireLine = true;
								break;
							}
							tokenResult.append(data);
						}
					}
					// 制御コマンドでスキップ指示があった場合は処理を中断
					if (skipEntireLine) {
						break;
					}
				}
			}

			// contentLine全体をスキップする場合は次のmstCoopIniInfoに進む
			if (skipEntireLine) {
				continue;
			}

			if (resultString.length() > 0) {
				resultString.append("\n");
			}
			resultString.append(tokenResult);
		}

		// 最終的な出力結果から残った $ 記号を除去
		String finalResult = resultString.toString();
		// $記号と、それに隣接する空白を除去（$ の前後どちらにある空白も除去）
		finalResult = finalResult.replaceAll("\\$ ", "").replaceAll(" \\$", "").replaceAll("\\$", "");

		return finalResult;
	}

	/**
	 * 設定情報テーブルから、対象の連携設定値を取得します。キャッシュに存在する場合はキャッシュ値を返します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @return 設定値の文字列
	 */
	private List<MstCoopIniInfo> getMstCoopIniInfoList(SysCoopJournal journal, CacheContext cache) {
		String cacheKey = "MstCoopIniInfoValue:" + SEC_MEDI_REC_SEND_CONTENTS + journal.getFacilityCd() + "-"
				+ journal.getKey0();

		return cache.mstCoopIniInfoValueCache.computeIfAbsent(cacheKey,
				key -> mstCoopIniDao.selectCoopIniInfoListSortByKey2(journal.getFacilityCd(), journal.getKey0(),
						SEC_MEDI_REC_SEND_CONTENTS));
	}

	/**
	 * 設定情報テーブルから、対象のPatEvent連携設定値を取得します。キャッシュに存在する場合はキャッシュ値を返します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @return 設定値の文字列
	 */
	private List<MstCoopIniInfo> getMstCoopIniInfoListByParEventTemplateSetting(SysCoopJournal journal, CacheContext cache) {
		String cacheKey = "MstCoopIniInfoValue:" + PAT_EVENT_TEMPLATE_SETTING + journal.getFacilityCd() + "-"
				+ journal.getKey0();

		return cache.mstCoopIniInfoValueCache.computeIfAbsent(cacheKey,
				key -> mstCoopIniDao.selectCoopIniInfoListSortByKey2(journal.getFacilityCd(), journal.getKey0(),
						PAT_EVENT_TEMPLATE_SETTING));
	}

	/**
	 * 入力文字列を解析し、'#'文字を区切り文字としてトークンに分割します。括弧内の'#'は区切らずに残します。
	 *
	 * @param value 分割対象の文字列
	 * @return 分割された文字列配列
	 */
	private String[] divideString(String value) {
		List<String> resultList = new ArrayList<>();
		StringBuilder strBuf = new StringBuilder();
		int bracketCount = 0; // 括弧カウンター

		for (char c : value.toCharArray()) {
			if (c == '#') {
				if (bracketCount == 0 && strBuf.length() > 0) {
					resultList.add(strBuf.toString());
					strBuf.setLength(0);
				} else {
					strBuf.append(c);
				}
			} else {
				strBuf.append(c);
				if (c == '(') {
					bracketCount++;
				} else if (c == ')') {
					bracketCount--;
				}
			}
		}

		if (strBuf.length() > 0) {
			resultList.add(strBuf.toString());
		}

		return resultList.toArray(new String[0]);
	}

	/**
	 * 指定された文字列内の算術演算（ADD, SUB, MUL, DIV）を評価し、結果の文字列を返します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @param value   算術演算式を含む文字列
	 * @return 算術計算結果をフォーマットした文字列（計算エラーの場合は全角スペース）
	 */
	private String calc(SysCoopJournal journal, String value, CacheContext cache) {
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "calc-b:" + value);
		value = value.replace("ADD", "+").replace("SUB", "-").replace("MUL", "*").replace("DIV", "÷").replace("#", "")
				.replace(")", "");
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "calc-a:" + value);
		String[] parts = value.split("\\(");
		List<String> tokens = new ArrayList<>();

		for (String part : parts) {
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "calc-part:" + part);
			String[] subParts = part.split(",");
			tokens.addAll(Arrays.asList(subParts));
		}

		for (int i = 0; i < tokens.size(); i++) {
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "calc-token:" + tokens.get(i));
			if (tokens.get(i).contains("$")) {
				String data = selectData(journal, tokens.get(i).replace("$", ""), cache);
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), tokens.get(i).replace("$", "") + ":" + data);
				tokens.set(i, data);
			}
		}

		return evaluateExpression(journal, tokens);
	}

	/**
	 * トークンリストから算術演算を評価し、計算結果を小数点以下2桁でフォーマットして返します。
	 *
	 * @param tokens 算術演算の各要素（数値および演算子）のリスト
	 * @return 計算結果をフォーマットした文字列。エラー時は全角スペースを返す。
	 */
	private String evaluateExpression(SysCoopJournal journal, List<String> tokens) {
		Stack<String> numStack = new Stack<>();
		Stack<String> opStack = new Stack<>();
		// 数値と単位を抽出する正規表現
		Pattern pattern = Pattern.compile("([-+]?\\d*\\.?\\d+(?:[eE][-+]?\\d+)?)(\\D+)?");
		for (String token : tokens) {
			// 演算子の場合はそのまま opStack にプッシュ
			if ("+".equals(token) || "-".equals(token) || "*".equals(token) || "÷".equals(token)) {
				opStack.push(token);
				continue;
			}

			// 正規表現で数値部分と単位部分を抽出
			Matcher matcher = pattern.matcher(token);
			if (matcher.find()) {
				String numberStr = matcher.group(1);
				numStack.push(numberStr);
			} else {
				outputLog(LogLevel.ERROR, journal.getFacilityCd(), "evaluateExpression-token: 数値が見つかりませんでした");
				return DOUBLE_BYTE_SPACE; // 数値抽出失敗
			}

			// スタックに2つ以上の数値があり、演算子もある場合は演算実行
			if (numStack.size() >= 2 && !opStack.isEmpty()) {
				String b = numStack.pop();
				String a = numStack.pop();

				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "evaluateExpression-operate-a:" + a);
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "evaluateExpression-operate-b:" + b);

				String operator = opStack.pop();
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "evaluateExpression-operate-operator:" + operator);
				String result = operate(a, b, operator);
				if (result == null) {
					outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "evaluateExpression:" + "0除算のため全角スペースを返します");
					return DOUBLE_BYTE_SPACE; //
				}
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "evaluateExpression-result:" + result);

				numStack.push(result);
			}
		}

		if (numStack.isEmpty()) {
			return DOUBLE_BYTE_SPACE;
		}
		return numStack.pop();
	}

	/**
	 * 2つの数値に対して、指定された演算子（+,-,*,/）の演算結果を返します。
	 *
	 * @param a1       オペランド1
	 * @param b2       オペランド2
	 * @param operator 演算子（"+"、"-"、"*"、"/"）
	 * @return 演算結果。除算時にb2が0の場合はnullを返す。
	 */
	private String operate(String a1, String b2, String operator) {
		BigDecimal a = new BigDecimal(a1);
		BigDecimal b = new BigDecimal(b2);
		switch (operator) {
			case "+":
				return a.add(b).toPlainString();
			case "-":
				return a.subtract(b).toPlainString();
			case "*":
				return a.multiply(b).toPlainString();
			case "÷":
				if ("0".equals(b2)) { // ゼロ除算対策
					return null;
				}
				return a.divide(b, 2, RoundingMode.HALF_UP).toPlainString();
			default:
				return null;
		}
	}

	/**
	 * 指定された文字列に含まれるテーブル名・カラム名の記述に基づき、対象のデータを取得します。
	 * 該当するテーブル名が含まれていない場合は、元の文字列をそのまま返します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @param value   取得対象の文字列（例："PAT_BASIC_INFO/NAME" など）
	 * @return 取得されたデータ、または変換できなかった場合は全角スペース
	 */
	private String selectData(SysCoopJournal journal, String value, CacheContext cache) {
		try {
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectData:value:" + value);
			// 指定文字列にテーブル名.カラム名が含まれている場合は、そのテーブル名.カラム名の値を取得する。
			// 含まれていない場合は取得文字列としてそのまま返す。

			// 指定文字列に"#"が含まれている場合(設定不備)は削除する(XmlNode.selectSingleNodeで落ちる)
			if (value.contains("#")) {
				value = value.replace("#", "");
			}

			if (value.contains(TABLE_MARK)) {
				value = value.replace(TABLE_MARK, "");
			}

			// 前回実績情報
			Boolean preFlg = false;
			if (value.contains(TXT_TRANS_PRE)) {
				value = value.replace(TXT_TRANS_PRE, "");
				preFlg = true;
			}

			// '/'で文字列を分割
			String[] tokens = value.split("\\/");
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectData:tokens-length:" + tokens.length);
			for (String token : tokens) {
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectData:tokens:" + token);
			}
			if (tokens.length == 0) {
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectData:トークンが見つかりませんでした。");
				return value;
			}

			// 最初のトークンでメインの分岐
			switch (tokens[0]) {
				case TBL_PAT_PERSONAL_MAIN:
					if (tokens.length > 1) {
						return selectPatPersonalMain(journal, tokens, cache);
					} else {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectData:pat_personal_mainのフィールドが不足しています。:" + value);
					}
					break;
				case TBL_ORD_MAIN:
					if (tokens.length > 1) {
						return selectOrdMain(journal, tokens, cache, preFlg);
					} else {
					outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectData:ord_mainのフィールドが不足しています。:" + value);
					}
					break;
				case TBL_MNI_MONITOR:
					if (tokens.length > 1) {
						return selectMniMonitor(journal, tokens, cache, preFlg);
					} else {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectData:mni_monitorのフィールドが不足しています。:" + value);
					}
					break;
				case TBL_MST_TREATMENT:
					if (tokens.length > 1) {
						return selectMstTreament(journal, tokens, cache, preFlg);
					} else {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectData:mst_treatmentのフィールドが不足しています。:" + value);
					}
					break;
				case TBL_PAT_EVENT:
					return selectPatEvent(journal, cache, preFlg);
				case TBL_PAT_MAIN:
					return selectPatMain(journal, tokens, cache);
				default:
					break;
			}
			return value;
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectData:" + e.getMessage());
			return value;
		}
	}

	/**
	 * 患者イベント（PAT_EVENT）を取得します。
	 * 各項目のラベルはデバッグ用として"[DEBUG]"マーカーを付与しているので、 将来的に削除可能です。
	 */
	private String selectPatEvent(SysCoopJournal journal, CacheContext cache, Boolean preFlg) {
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectPatEvent: 処理開始");
		List<MstCoopIniInfo> mstCoopIniInfoList = getMstCoopIniInfoListByParEventTemplateSetting(journal, cache);

		// 該当患者・透析日の取得：OrdMainから透析日（treatDate）を取得
		OrdMain ordMain = null;
		try {
			ordMain = getOrdMain(journal, cache, preFlg);
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectPatEvent: オーダー情報取得エラー: " + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}
		if (ordMain == null || ordMain.getTreatDate() == null) {
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectPatEvent: オーダー情報なし");
			return DOUBLE_BYTE_SPACE;
		}
		Long ordNo = ordMain.getOrdNo();

		// patEventDaoから、ordNoで紐づく観察記録を取得
		List<PatEvent> events = null;
		try {
			events = cache.patEventCache.computeIfAbsent("PatEvent:" + journal.getOrdNo(), key -> patEventDao
					.selectByOrdNoForKarteOrd(ordNo, journal.getFacilityCd(), journal.getKey0()));
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectPatEvent: イベント取得エラー: " + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}
		if (events == null || events.isEmpty()) {
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectPatEvent: 該当イベントなし");
			return DOUBLE_BYTE_SPACE;
		}

		// 記票日時で昇順にソート
		try {
			Collections.sort(events, new Comparator<PatEvent>() {
				@Override
				public int compare(PatEvent e1, PatEvent e2) {
					// event_start_dateは"yyyyMMdd"、event_start_timeは"HHmm"（なければ"0000"）
					String d1 = e1.getEventStartDate();
					String t1 = (e1.getEventStartTime() != null && e1.getEventStartTime().length() == 5)
							? e1.getEventStartTime()
							: "0000";
					String d2 = e2.getEventStartDate();
					String t2 = (e2.getEventStartTime() != null && e2.getEventStartTime().length() == 5)
							? e2.getEventStartTime()
							: "0000";
					return (d1 + t1).compareTo(d2 + t2);
				}
			});
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectPatEvent: ソート処理エラー: " + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}

		StringBuilder sb = new StringBuilder();
		// 各イベントごとに出力ブロックを生成（複数イベントが存在する場合は改行で区切る）
		for (PatEvent event : events) {
			try {
				if (event.getUseType() != 2) {
					continue;
				}
				// ① 日時時刻の整形：変換 "yyyyMMdd" -> "yyyy/MM/dd" および "HHmm" -> "HH:mm"
				String dateStr = event.getEventStartDate();
				String timeStr = event.getEventStartTime();
				String formattedDate = (dateStr != null && dateStr.length() == 10)
						? dateStr.replace("-", "/")
						: DOUBLE_BYTE_SPACE;
				String formattedTime = (timeStr != null && timeStr.length() == 5)
						? timeStr
						: "00:00";
				String datetime = formattedDate + " " + formattedTime;

				// ② 患者イベント名（サブカテゴリ）の取得
				String category = event.getSubCategoryName();
				if (category == null || category.trim().isEmpty()) {
					category = DOUBLE_BYTE_SPACE;
				}

				// ヘッダー出力
				sb.append(datetime).append(DOUBLE_BYTE_SPACE).append(category).append("\n");

				// ③ 内容の取得
				String resultParams = removeAllBOM(event.getResultParams());
				List<String> detailLines = processResultParams(resultParams, event.getInputParams(),
						journal.getFacilityCd(), mstCoopIniInfoList);
				// 非SOAPの場合、processResultParamsで各項目のラベル付き文字列リストを取得
				if (!detailLines.isEmpty()) {
					for (String line : detailLines) {
						sb.append(line).append("\n");
					}
				}

				// ④ 起票者の取得（up_staff_infoからup_staff_name）
				String upStaffInfo = removeAllBOM(event.getUpStaffInfo());
				String writer = "";
				if (upStaffInfo != null && !upStaffInfo.trim().isEmpty()) {
					try {
						JSONObject upObj = new JSONObject(upStaffInfo);
						writer = upObj.optString("up_staff_name", "");
					} catch (JSONException e) {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectPatEvent: upStaffInfo JSON解析エラー: " + e.getMessage());
						writer = "";
					}
				}
				if (writer.isEmpty()) {
					writer = DOUBLE_BYTE_SPACE;
				}
				// 起票者を最終行に出力（インデントなし）
				sb.append(writer).append("\n");
			} catch (Exception e) {
				outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectPatEvent: イベント処理エラー: " + e.getMessage());
				// 1イベントの処理で例外が発生しても、以降の処理を継続
				continue;
			}
		}
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectPatEvent: 処理終了");
		return sb.toString().trim();
	}

	/**
	 * result_params（JSON配列）内の各項目を、施設コード facilityCd に応じた加工処理を行い、
	 * フォーマット別に整形した文字列のリストを返します。 ※各項目のラベルはデバッグ用として"[DEBUG]"を付与しています。
	 *
	 * @param resultParams JSON文字列。各要素は result_value が空の場合は出力対象外。
	 * @param inputParams  JSON文字列。
	 * @param facilityCd   施設コード。日付変換処理に利用。
	 * @return 加工済みフィールド文字列のリスト
	 */
	private List<String> processResultParams(String resultParams, String inputParams, String facilityCd,
			List<MstCoopIniInfo> mstCoopIniInfoList) {
		List<String> resultList = new ArrayList<>();
		if (resultParams == null || resultParams.trim().isEmpty()) {
			return resultList;
		}

		// PAT_EVENT_TEMPLATE_SETTINGの各設定値を変数に格納
		String textbox = "1";
		String textarea = "1";
		String image = "1";
		String listbox = "1";
		String radiobutton = "1";
		String checkbox = "1";
		String date = "1";
		String fileAttachment = "1";
		String scoreCalculation = "1";
		String treatmentLink = "1";
		String bulletinLink = "1";
		
		String textboxNullDisp = "0";
		String textareaNullDisp = "0";

		// mstCoopIniInfoListから各設定値を取得
		if (mstCoopIniInfoList != null) {
			for (MstCoopIniInfo info : mstCoopIniInfoList) {
				if (info.getKey2() != null) {
					switch (info.getKey2()) {
						case "TEXTBOX":
							textbox = info.getVal() != null ? info.getVal() : "1";
							break;
						case "TEXTAREA":
							textarea = info.getVal() != null ? info.getVal() : "1";
							break;
						case "IMAGE":
							image = info.getVal() != null ? info.getVal() : "1";
							break;
						case "LISTBOX":
							listbox = info.getVal() != null ? info.getVal() : "1";
							break;
						case "RADIOBUTTON":
							radiobutton = info.getVal() != null ? info.getVal() : "1";
							break;
						case "CHECKBOX":
							checkbox = info.getVal() != null ? info.getVal() : "1";
							break;
						case "DATE":
							date = info.getVal() != null ? info.getVal() : "1";
							break;
						case "FILE_ATTACHMENT":
							fileAttachment = info.getVal() != null ? info.getVal() : "1";
							break;
						case "SCORE_CALCULATION":
							scoreCalculation = info.getVal() != null ? info.getVal() : "1";
							break;
						case "TREATMENT_LINK":
							treatmentLink = info.getVal() != null ? info.getVal() : "1";
							break;
						case "BULLETIN_LINK":
							bulletinLink = info.getVal() != null ? info.getVal() : "1";
							break;
						case "TEXTBOX_NULL_DISP":
							textboxNullDisp = info.getVal() != null ? info.getVal() : "1";
							break;
						case "TEXTAREA_NULL_DISP":
							textareaNullDisp = info.getVal() != null ? info.getVal() : "1";
							break;
					}
				}
			}
		}

		try {
			JSONArray resultArr = new JSONArray(resultParams);
			JSONArray inputArr = new JSONArray(inputParams);

			for (int i = 0; i < inputArr.length(); i++) {
				JSONObject resultObj = resultArr.getJSONObject(i);
				int formatClass = resultObj.optInt("format_class", -1);
				// result_value が存在しない場合はスキップ
				if (!resultObj.has("result_value")) {
					continue;
				}
				// result_value が空かつテキスト以外の場合はスキップ
				if (isEmpty(resultObj.get("result_value")) && !(formatClass == 0 || formatClass == 1)) {
					continue;
				}
				Object valueObj = resultObj.get("result_value");
				String fieldName = inputArr.getJSONObject(i).getString("field_name");

				switch (formatClass) {
					case 0:
						// シングルラインテキスト（テキストボックス）
						if (!"1".equals(textbox)) {
							break; // テキストボックス出力が無効の場合はスキップ
						}
						try {
							String text = valueObj.toString();
							 if (text.trim().isEmpty() && "0".equals(textboxNullDisp)) {
							 	continue;
							 }
							String processed = processTextBox(text);
							resultList.add(fieldName + "：" + processed);

							// // 万が一HTMLタグが含まれていた場合はテキストエリアとして処理
							// if (!text.trim().startsWith("<")) {
							// String processed = processTextBox(text);
							// resultList.add(fieldName + "：" + processed);
							// } else {
							// String processed = processTextArea(text);
							// resultList.add(fieldName + "：" + processed);
							// }
						} catch (Exception e) {
						outputLog(LogLevel.ERROR, facilityCd, "processResultParams: テキストボックス処理エラー: " + e.getMessage());
						}
						break;
					case 1:
						// テキストエリア
						if (!"1".equals(textarea)) {
							break; // テキストエリア出力が無効の場合はスキップ
						}
						String isFormatting = "1";
						try {
							String text = valueObj.toString();
							 if (text.trim().isEmpty() && "0".equals(textareaNullDisp)) {
							 	continue;
							 }
						if(inputArr.getJSONObject(i).has("item_json") && inputArr.getJSONObject(i).getJSONObject("item_json").has("is_formatting")) {
							isFormatting = inputArr.getJSONObject(i).getJSONObject("item_json").getString("is_formatting");
							}
							String processed = processTextArea(text, isFormatting);
							// if (processed.isEmpty()) {
							// 	continue;
							// }
							resultList.add(fieldName + "：" + processed);
						} catch (Exception e) {
						outputLog(LogLevel.ERROR, facilityCd, "processResultParams: テキストエリア処理エラー: " + e.getMessage());
						}
						break;
					case 2:
						// 画像
						if (!"1".equals(image)) {
							break; // 画像出力が無効の場合はスキップ
						}
						try {
							JSONArray imgArr = new JSONArray(valueObj.toString());
							for (int j = 0; j < imgArr.length(); j++) {
								JSONObject imgObj = imgArr.getJSONObject(j);
								String fileName = imgObj.optString("file_name", "").trim();
								if (!fileName.isEmpty()) {
									resultList.add(fieldName + "：" + fileName);
								}
							}
						} catch (JSONException e) {
						outputLog(LogLevel.ERROR, facilityCd, "processResultParams: 画像JSON解析エラー: " + e.getMessage());
						}
						break;
					case 3:
						// リストボックス
						if (!"1".equals(listbox)) {
							break; // リストボックス出力が無効の場合はスキップ
						}
						try {
							JSONObject listObj = new JSONObject(valueObj.toString());
							String name = listObj.optString("name", "").trim();
							if (!name.isEmpty()) {
								resultList.add(fieldName + "：" + name);
							}
						} catch (JSONException e) {
							outputLog(LogLevel.ERROR, facilityCd,
									"processResultParams: リストボックスJSON解析エラー: " + e.getMessage());
						}
						break;
					case 4:
						// ラジオボタン
						if (!"1".equals(radiobutton)) {
							break; // ラジオボタン出力が無効の場合はスキップ
						}
						try {
							JSONObject radioObj = new JSONObject(valueObj.toString());
							String name = radioObj.optString("name", "").trim();
							if (!name.isEmpty()) {
								resultList.add(fieldName + "：" + name);
							}
						} catch (JSONException e) {
							outputLog(LogLevel.ERROR, facilityCd,
									"processResultParams: ラジオボタンJSON解析エラー: " + e.getMessage());
						}
						break;
					case 5:
						// 日付
						if (!"1".equals(date)) {
							break; // 日付出力が無効の場合はスキップ
						}
						try {
							String dateStr = valueObj.toString().trim();
							if (!dateStr.isEmpty()) {
								String formatted = formatDate(dateStr, facilityCd);
								if (formatted.equals(DOUBLE_BYTE_SPACE)) {
									continue;
								}
								resultList.add(fieldName + "：" + formatted);
							}
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, facilityCd, "processResultParams: 日付処理エラー: " + e.getMessage());
						}
						break;
					case 6:
						// チェックボックス
						if (!"1".equals(checkbox)) {
							break; // チェックボックス出力が無効の場合はスキップ
						}
						try {
							JSONArray checkArr = new JSONArray(valueObj.toString());
							List<String> names = new ArrayList<>();
							for (int j = 0; j < checkArr.length(); j++) {
								JSONObject chkObj = checkArr.getJSONObject(j);
								String name = chkObj.optString("name", "").trim();
								if (!name.isEmpty()) {
									names.add(name);
								}
							}
							if (!names.isEmpty()) {
								resultList.add(fieldName + "：" + String.join(",", names));
							}
						} catch (JSONException e) {
							outputLog(LogLevel.ERROR, facilityCd,
									"processResultParams: チェックボックスJSON解析エラー: " + e.getMessage());
						}
						break;
					case 7:
						// ファイル添付（添付ファイル）
						if (!"1".equals(fileAttachment)) {
							break; // ファイル添付出力が無効の場合はスキップ
						}
						try {
							JSONArray attachArr = new JSONArray(valueObj.toString());
							for (int j = 0; j < attachArr.length(); j++) {
								JSONObject attachObj = attachArr.getJSONObject(j);
								String fileName = attachObj.optString("file_name", "").trim();
								if (!fileName.isEmpty()) {
									resultList.add(fieldName + "：" + fileName);
								}
							}
						} catch (JSONException e) {
							outputLog(LogLevel.ERROR, facilityCd,
									"processResultParams: 添付ファイルJSON解析エラー: " + e.getMessage());
						}
						break;
					case 8:
						// スコア計算
						if (!"1".equals(scoreCalculation)) {
							break; // スコア計算出力が無効の場合はスキップ
						}
						try {
							JSONObject scoreObj = new JSONObject(valueObj.toString());
							String score = scoreObj.optString("score", "").trim();
							String unit = scoreObj.optString("unit", "").trim();
							if (!score.isEmpty()) {
								resultList.add(fieldName + "：" + score + unit);
							}
						} catch (JSONException e) {
						outputLog(LogLevel.ERROR, facilityCd, "processResultParams: スコア計算JSON解析エラー: " + e.getMessage());
						}
						break;
					case 9:
						// 透析データリンク（治療実績リンク）
						if (!"1".equals(treatmentLink)) {
							break; // 治療実績リンク出力が無効の場合はスキップ
						}
						// 現状は出力しない仕様のためスキップ
						break;
					case 10:
						// 掲示板リンク
						if (!"1".equals(bulletinLink)) {
							break; // 掲示板リンク出力が無効の場合はスキップ
						}
						try {
							JSONObject bulletinObj = new JSONObject(valueObj.toString());
							String noticeStart = bulletinObj.optString("notice_start_date", "").trim();
							String noticeEnd = bulletinObj.optString("notice_end_date", "").trim();
							if (noticeStart.isEmpty() || "null".equals(noticeStart)) {
								resultList.add("掲示板リンク：掲載無し");
							} else {
								String formattedStart = formatDate(noticeStart, facilityCd);
								String formattedEnd = formatDate(noticeEnd, facilityCd);
								resultList.add("掲示板リンク：掲載有り");
								resultList.add("期間：" + formattedStart + " - " + formattedEnd);
							}
						} catch (JSONException e) {
							outputLog(LogLevel.ERROR, facilityCd,
									"processResultParams: 掲示板リンクJSON解析エラー: " + e.getMessage());
						}
						break;
					default:
						// 未定義の format_class は無視
						break;
				}

			}
		} catch (JSONException e) {
			outputLog(LogLevel.ERROR, facilityCd, "processResultParams: 全体JSON解析エラー: " + e.getMessage());
			return new ArrayList<>();
		}
		return resultList;
	}

	/**
	 * 入力文字列からすべてのBOM（Byte Order Mark）を削除するメソッド
	 *
	 * @param text 入力文字列
	 * @return BOMがすべて除去された文字列
	 */
	private String removeAllBOM(String text) {
		if (text == null) {
			return null;
		}
		return text.replace("\uFEFF", "");
	}

	/**
	 * テキストボックスの加工（必要に応じてトリムなど）
	 */
	private String processTextBox(String text) {
		return decodeHtmlEntities(text).trim();
	}

	/**
	 * テキストエリアの加工：HTMLタグを除去し、HTMLエンティティをデコードして、
	 * 改行およびHTML内の改行タグを全角スペースに変換した文字列を返す
	 */
	private String processTextArea(String html, String isFormatting) {
		if (html == null) {
			return "";
		}

		if ("0".equals(isFormatting)) {
			return html.replaceAll("\\r?\\n", DOUBLE_BYTE_SPACE);
		} else if ("1".equals(isFormatting)) {
			String preprocessedHtml = html.replaceAll("\\r?\\n", DOUBLE_BYTE_SPACE);
			preprocessedHtml = preprocessedHtml.replaceAll("(?i)<br\\s*/?>", DOUBLE_BYTE_SPACE);
			preprocessedHtml = preprocessedHtml.replaceAll("(?i)</p>\\s*<p>", DOUBLE_BYTE_SPACE);
			preprocessedHtml = preprocessedHtml.replaceAll("(?i)<p>", "");
			preprocessedHtml = preprocessedHtml.replaceAll("(?i)</p>", "");
			String plainText = Jsoup.parse(preprocessedHtml).wholeText();
			plainText = plainText.replaceAll("[ 　]+", DOUBLE_BYTE_SPACE);

			return plainText.trim();
		}

		return "";
	}

	/**
	 * HTMLエンティティをデコードするヘルパーメソッド
	 */
	private String decodeHtmlEntities(String input) {
		return input
				.replaceAll("&amp;", "&")
				.replaceAll("&lt;", "<")
				.replaceAll("&gt;", ">")
				.replaceAll("&quot;", "\"")
				.replaceAll("&apos;", "'")
				.replaceAll("&nbsp;", " ");
	}

	/**
	 * オブジェクトがnullまたは空文字かを判定
	 */
	private boolean isEmpty(Object o) {
		if (o == null) {
			return true;
		}
		if (o instanceof String) {
			return ((String) o).trim().isEmpty();
		}
		return false;
	}

	/**
	 * 透析実績除水量補正履歴（RST_DIALYSIS_WATER_REMOVE_HST）のデータを取得します。
	 * データはord_mainのrst_off_water_infoフィールド（JSON形式）から取得し、 キーが "weight_"
	 * で始まるすべての項目の値の合計を算出して返します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @return "weight_" の合計値を小数点以下2桁でフォーマットした文字列。取得できなければ全角スペース。
	 */
	private String selectRstDialysisWaterRemoveHst(SysCoopJournal journal, CacheContext cache, Boolean preFlg) {
		OrdMain ordMain = getOrdMain(journal, cache, preFlg);

		if (ordMain == null) {
			return DOUBLE_BYTE_SPACE;
		}
		String jsonStr = ordMain.getRstOffWaterInfo();
		if (jsonStr == null || jsonStr.trim().isEmpty()) {
			return DOUBLE_BYTE_SPACE;
		}
		try {
			JSONObject json = new JSONObject(jsonStr);
			double sum = 0.0;
			Iterator<String> keys = json.keys();
			while (keys.hasNext()) {
				String key = keys.next();
				if (key.startsWith("weight_")) {
					double weight = json.optDouble(key, 0.0);
					sum += weight;
				}
			}
			return String.format("%.2f", sum);
		} catch (JSONException e) {
			return DOUBLE_BYTE_SPACE;
		}
	}

	private OrdMain getOrdMain(SysCoopJournal journal, CacheContext cache, Boolean preFlg) {
		String cacheKey = "OrdMain:" + journal.getOrdNo();
		OrdMain ordMain = null;
		try {
			if (preFlg) {
				OrdMain ordMainNew = cache.ordMainCache.computeIfAbsent(cacheKey,
						k -> ordMainDao.selectByOrdNo(journal.getOrdNo()));
				List<OrdMain> lastOrdMains = cache.lastOrdMainCache.computeIfAbsent("Last" + cacheKey,
						k -> ordMainDao.selectPatOrdMainLastTreatDate(journal.getPatId(), journal.getFacilityCd(),
								ordMainNew.getTreatDate()));
				if (lastOrdMains == null || lastOrdMains.isEmpty()) {
					outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "selectOrdMain: PRE情報が見つかりません。");
					return null;
				}
				ordMain = lastOrdMains.get(0);
			} else {
				ordMain = cache.ordMainCache.computeIfAbsent(cacheKey,
						k -> ordMainDao.selectByOrdNo(journal.getOrdNo()));
			}
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectOrdMain: オーダー情報取得エラー: " + e.getMessage());
			return null;
		}
		return ordMain;
	}

	/**
	 * ジャーナル情報とキー文字列に基づき、患者基本情報（pat_main系）をフォーマットして返却する。
	 *
	 * @param journal ジャーナル情報
	 * @param tokens  連携設定文字列を"/"で分割した配列。
	 * @param cache   キャッシュコンテキスト
	 * @return 指定項目のフォーマット済み文字列。
	 */
	private String selectPatMain(SysCoopJournal journal, String[] tokens, CacheContext cache) {
		try {
			// tokensが不正な場合は全角スペースを返す
			if (tokens.length < 3) {
				return DOUBLE_BYTE_SPACE;
			}

			String key = tokens[1];
			// PatMain取得
			PatMain patMain = cache.patMainCache.computeIfAbsent(
					"PatMain:" + journal.getFacilityCd() + ":" + journal.getPatId(),
					k -> patMainDao.selectMedicalCareInfoByIdAndFacilityCd(journal.getFacilityCd(),
							journal.getPatId()));

			if (patMain == null) {
				return DOUBLE_BYTE_SPACE;
			}

			if ("medical_care_info".equals(key)) {
				// JSON項目取得
				String jsonStr = patMain.getMedical_care_info();
				if (jsonStr == null || jsonStr.trim().isEmpty()) {
					return DOUBLE_BYTE_SPACE;
				}
				try {
					JSONObject json = new JSONObject(jsonStr);
					String targetKey = tokens[2];
					if (!json.has(targetKey)) {
						return DOUBLE_BYTE_SPACE;
					}
					Object val = json.opt(targetKey);
					if (val == null || JSONObject.NULL.equals(val)) {
						return DOUBLE_BYTE_SPACE;
					}
					String result = val.toString();

					// dialysis_start_date の場合は日付フォーマット変換を行う
					if ("dialysis_start_date".equals(targetKey)) {
						String formatted = formatDate(result, journal.getFacilityCd());
						if (!DOUBLE_BYTE_SPACE.equals(formatted)) {
							return formatted;
						}
					}

					return result.isEmpty() ? DOUBLE_BYTE_SPACE : result;
				} catch (JSONException e) {
					outputLog(LogLevel.ERROR, journal.getFacilityCd(),
							"selectPatMain: medical_care_info JSON parse error: " + e.getMessage());
					return DOUBLE_BYTE_SPACE;
				}
			}

			return DOUBLE_BYTE_SPACE;
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectPatMain: エラー: " + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * ジャーナル情報とキー文字列に基づき、治療情報（ord_main系）をフォーマットして返却する。
	 * <p>
	 * 連携設定（例："ord_main/xxx"または"ord_main/xxx/yyy"）をスラッシュで分割し、
	 * 1番目（システム名）が"ord_main"であることを確認後、2番目の物理名に基づいて処理を実施する。
	 * さらに3番目以降が存在する場合は、ケース内でさらにswitch等により処理を分岐する。
	 * </p>
	 *
	 * @param journal ジャーナル情報（オーダー番号等を含む）
	 * @param tokens  連携設定文字列を"/"で分割した配列。例：{"ord_main", "rst_cond_info", "value",
	 *                "1"}
	 * @return 指定項目のフォーマット済み文字列。該当情報がない、または処理内容が不明な場合は全角スペースを返す。
	 */
	private String selectOrdMain(SysCoopJournal journal, String[] tokens, CacheContext cache, Boolean preFlg) {
		try {
			// tokensが不正な場合は全角スペースを返す
			if (tokens.length < 2) {
				return DOUBLE_BYTE_SPACE;
			}

			String key = tokens[1];
			String cacheKey = "OrdMain:" + journal.getOrdNo();

			// キャッシュまたはDBからオーダー情報を取得
			OrdMain ordMain = getOrdMain(journal, cache, preFlg);

			if (ordMain == null) {
				return DOUBLE_BYTE_SPACE;
			}

			// 「rst_cond_info[ctl_no='数字']」の形式の場合の分岐を先に処理
			if (key.startsWith("rst_cond_info") && key.contains("[ctl_no=")) {
				try {
					Pattern pattern = Pattern.compile("rst_cond_info\\[ctl_no='(\\d+)'\\]");
					Matcher matcher = pattern.matcher(tokens[1]);
					if (matcher.find()) {
						int ctlNo = Integer.parseInt(matcher.group(1));
						if (tokens.length >= 3) {
							// tokens[2]がJSON内のキーとして利用される
							final String value;
							try {
								value = getDataFromJson(ordMain.getRstCondInfo(), ctlNo, tokens[2]);
							} catch (Exception e) {
								outputLog(LogLevel.ERROR, journal.getFacilityCd(),
										"selectOrdMain: JSON処理エラー: " + e.getMessage());
								return DOUBLE_BYTE_SPACE;
							}

							if (value == DOUBLE_BYTE_SPACE && !tokens[2].equals("value_2")) {
								return DOUBLE_BYTE_SPACE;
							}
							outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
									"selectOrdMain-rst_cond_info-value:" + ctlNo + ":" + value);

							// tokens[3]が定義されている場合は自己呼び出しで値をチェック
							if (tokens.length >= 4 && tokens[3] != null && !tokens[3].trim().isEmpty()) {
								try {
									int referenceCtlNo = Integer.parseInt(tokens[3].trim());
									// 自己呼び出しで参照先のデータを取得
									String[] referenceTokens = new String[3];
									referenceTokens[0] = tokens[0]; // "ord_main"
									referenceTokens[1] = "rst_cond_info[ctl_no='" + referenceCtlNo + "']";
									referenceTokens[2] = tokens[2]; // "value" など

									String referenceValue = selectOrdMain(journal, referenceTokens, cache, preFlg);

									// 参照先の値が取れない場合はnullを返す
									if (referenceValue == null || referenceValue.equals(DOUBLE_BYTE_SPACE)) {
										outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
											"selectOrdMain: tokens[3]参照先(ctlNo=" + referenceCtlNo + ")の値が空のためnullを返します");
										return null;
									}

									outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
										"selectOrdMain: tokens[3]参照先(ctlNo=" + referenceCtlNo + ")の値: " + referenceValue);
								} catch (NumberFormatException e) {
									outputLog(LogLevel.WARN, journal.getFacilityCd(),
											"selectOrdMain: tokens[3]が数字ではありません: " + tokens[3]);
								} catch (Exception e) {
									outputLog(LogLevel.ERROR, journal.getFacilityCd(),
											"selectOrdMain: tokens[3]参照処理エラー: " + e.getMessage());
								}
							}

							// ctlNo により後処理を実施
							try {
								switch (ctlNo) {
									case 1:
										if (tokens[2].equals("value")) {
											return value;
										} else if (tokens[2].equals("value_2")) {
											return formatTime(
												Integer.parseInt(getDataFromJson(ordMain.getRstCondInfo(), 1, "value")),
													journal.getFacilityCd());
										}
										return DOUBLE_BYTE_SPACE;
									case 2:
										try {
											MstVa mstVa = cache.mstVaCache.computeIfAbsent(
													cacheKey + ":mstVa:" + ctlNo + ":" + value,
													k -> mstVaDao.selectByCd(Integer.parseInt(value)));
											if (mstVa == null) {
												return DOUBLE_BYTE_SPACE;
											}
											return mstVa.getVaName();
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
													"selectOrdMain: MstVa取得エラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									case 5:
										try {
											MstDialyzer mstDialyzer = cache.mstDialyzerCache.computeIfAbsent(
													cacheKey + ":mstDialyzer:" + ctlNo + ":" + value,
													k -> mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(),
															Integer.parseInt(value)));
											if (mstDialyzer == null) {
												return DOUBLE_BYTE_SPACE;
											}
											return mstDialyzer.getModelNumber();
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
													"selectOrdMain: MstDialyzer取得エラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									case 6:
									case 7:
									case 8:
										try {
											MstEquipment mstEquipment = cache.mstEquipmentCache.computeIfAbsent(
													cacheKey + ":mstEquipment:" + ctlNo + ":" + value,
													k -> mstEquipmentDao.selectByEquipmentCd(Integer.parseInt(value)));
											if (mstEquipment == null) {
												return DOUBLE_BYTE_SPACE;
											}
											return mstEquipment.getEquipmentName();
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
													"selectOrdMain: MstEquipment取得エラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									case 15:
									case 19:
									case 25:
										try {
											String medicine_type = getDataFromJson(ordMain.getRstCondInfo(), ctlNo,
													"medicine_type");
											int medicine_value = Integer
												.parseInt(getDataFromJson(ordMain.getRstCondInfo(), ctlNo, "value"));
											outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
													"selectOrdMain: rst_cond_info:medicine_type:" + medicine_type);
											outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
													"selectOrdMain: rst_cond_info:medicine_value:" + medicine_value);
											if (medicine_type.equals("2")) {
												try {
													MstMedicineMix mstMedicineMix = cache.mstMedicineMixCache
														.computeIfAbsent(cacheKey + ":mstMedicineMix:" + medicine_value,
																	k -> mstMedicineMixDao.selectByCd(
																			journal.getFacilityCd(), medicine_value));
													if (mstMedicineMix == null) {
														return DOUBLE_BYTE_SPACE;
													}
													return mstMedicineMix.getMedicineMixName();
												} catch (Exception e) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: MstMedicineMix取得エラー: " + e.getMessage());
													return DOUBLE_BYTE_SPACE;
												}
											} else {
												try {
													MstMedicine mstMedicine = cache.mstMedicineCache.computeIfAbsent(
														cacheKey + ":mstMedicine:" + medicine_value, k -> mstMedicineDao
																.selectByCd(journal.getFacilityCd(), medicine_value));
													if (mstMedicine == null) {
														return DOUBLE_BYTE_SPACE;
													}
													return mstMedicine.getMedicineName();
												} catch (Exception e) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: MstMedicine取得エラー: " + e.getMessage());
													return DOUBLE_BYTE_SPACE;
												}
											}
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
													"selectOrdMain: MstMedicine取得エラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									case 26:
									case 27:
									case 28:
										try {
											String medicine_type = getDataFromJson(ordMain.getRstCondInfo(), 25,
													"medicine_type");
											int medicine_value = Integer
													.parseInt(getDataFromJson(ordMain.getRstCondInfo(), 25, "value"));
											outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
													"selectOrdMain: rst_cond_info:medicine_type;" + medicine_type);
											outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
													"selectOrdMain: rst_cond_info:medicine_value:" + medicine_value);
											if (medicine_type.equals("2")) {
												try {
													MstMedicineMix mstMedicineMix = cache.mstMedicineMixCache
														.computeIfAbsent(cacheKey + ":mstMedicineMix:" + medicine_value,
																	k -> mstMedicineMixDao.selectByCd(
																			journal.getFacilityCd(), medicine_value));
													if (mstMedicineMix == null || mstMedicineMix.getUnit() == null) {
														if (ctlNo == 27) {
															return value + "/h";
														} else {
															return value;
														}
													}
													if (ctlNo == 27) {
														return value + mstMedicineMix.getUnit() + "/h";
													} else {
														return value + mstMedicineMix.getUnit();
													}
												} catch (Exception e) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: MstMedicineMix取得エラー: " + e.getMessage());
													if (ctlNo == 27) {
														return value + "/h";
													} else {
														return value;
													}
												}
											} else {
												try {
													MstMedicine mstMedicine25 = cache.mstMedicineCache.computeIfAbsent(
														cacheKey + ":mstMedicine:" + medicine_value, k -> mstMedicineDao
																.selectByCd(journal.getFacilityCd(), medicine_value));
													if (mstMedicine25 == null || mstMedicine25.getUnit() == null) {
														if (ctlNo == 27) {
															return value + "/h";
														} else {
															return value;
														}
													}
													if (ctlNo == 27) {
														return value + mstMedicine25.getUnit() + "/h";
													} else {
														return value + mstMedicine25.getUnit();
													}
												} catch (Exception e) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: MstMedicine取得エラー: " + e.getMessage());
													if (ctlNo == 27) {
														return value + "/h";
													} else {
														return value;
													}
												}
											}
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
													"selectOrdMain: 薬剤情報処理エラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									case 17:
									case 22:
										try {
											int mediCtrlNo = 0;
											if (ctlNo == 17) {
												mediCtrlNo = 15;
											} else if (ctlNo == 22) {
												mediCtrlNo = 19;
											}

											String medicine_type = getDataFromJson(ordMain.getRstCondInfo(), mediCtrlNo,
													"medicine_type");
											int medicine_value = Integer.parseInt(
													getDataFromJson(ordMain.getRstCondInfo(), mediCtrlNo, "value"));
											outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
													"selectOrdMain: rst_cond_info:medicine_type;" + medicine_type);
											outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
													"selectOrdMain: rst_cond_info:medicine_value:" + medicine_value);
											if (medicine_type.equals("2")) {
												try {
													MstMedicineMix mstMedicineMix = cache.mstMedicineMixCache
														.computeIfAbsent(cacheKey + ":mstMedicineMix:" + medicine_value,
																	k -> mstMedicineMixDao.selectByCd(
																			journal.getFacilityCd(), medicine_value));
													if (mstMedicineMix == null || mstMedicineMix.getUnit() == null) {
														return value;
													}
													return value + mstMedicineMix.getUnit();
												} catch (Exception e) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: MstMedicineMix取得エラー: " + e.getMessage());
													return value;
												}
											} else {
												try {
													MstMedicine mstMedicine = cache.mstMedicineCache.computeIfAbsent(
														cacheKey + ":mstMedicine:" + medicine_value, k -> mstMedicineDao
																.selectByCd(journal.getFacilityCd(), medicine_value));
													if (mstMedicine == null || mstMedicine.getUnit() == null) {
														return value;
													}
													return value + mstMedicine.getUnit();
												} catch (Exception e) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: MstMedicine取得エラー: " + e.getMessage());
													return value;
												}
											}
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
													"selectOrdMain: 薬剤情報処理エラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									case 29:
										if (value.equals("0")) {
											return "使用しない";
										} else if (value.equals("1")) {
											return "使用する";
										}
										return DOUBLE_BYTE_SPACE;
									case 21:
										if (value.equals("0")) {
											return "後補液";
										} else if (value.equals("1")) {
											return "前補液";
										}
										return DOUBLE_BYTE_SPACE;
									case 12:
										if (value.equals("0")) {
											return "無し";
										} else if (value.equals("1")) {
											return "有り";
										}
										return DOUBLE_BYTE_SPACE;
									case 30:
										if (value.equals("0")) {
											return "手動";
										} else if (value.equals("1")) {
											return "自動";
										}
										return DOUBLE_BYTE_SPACE;
									case 34:
										if (value.equals("0")) {
											return "使用しない";
										} else if (value.equals("1")) {
											return "使用する";
										}
										return DOUBLE_BYTE_SPACE;
									case 35:
									case 37:
										if (value.equals("0")) {
											return "切";
										} else if (value.equals("1")) {
											return "入";
										}
										return DOUBLE_BYTE_SPACE;
									default:
										break;
								}
								return value;
							} catch (Exception e) {
								outputLog(LogLevel.ERROR, journal.getFacilityCd(),
										"selectOrdMain: 分岐処理エラー: " + e.getMessage());
								return DOUBLE_BYTE_SPACE;
							}
						} else {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_cond_info[ctl_no] のキーが不足しています。");
							return DOUBLE_BYTE_SPACE;
						}
					} else {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectOrdMain: rst_cond_infoのctl_no指定の形式が不正です。:" + tokens[1]);
						return DOUBLE_BYTE_SPACE;
					}
				} catch (Exception e) {
					outputLog(LogLevel.ERROR, journal.getFacilityCd(),
							"selectOrdMain: rst_cond_info処理エラー: " + e.getMessage());
					return DOUBLE_BYTE_SPACE;
				}
			}

			try {
				switch (key) {
					// ---------------------------
					// 【基本情報】
					// ---------------------------
					case "rst_cond_info": // (Row 5) 予定透析時間[分]
						try {
							return getDataFromJson(ordMain.getRstCondInfo(), 1, "value");
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_cond_info 取得エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_cond_info_2": // (Row 6) 予定透析時間（HH:mm形式）
						try {
							return formatTime(Integer.parseInt(getDataFromJson(ordMain.getRstCondInfo(), 1, "value")),
									journal.getFacilityCd());
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_cond_info_2 変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "ind_user_name": // (Row 3) 指示者
						try {
							long upUserId = ordMain.getUpIndUserId();
							MstPersonalUser mstPersonalUser = cache.mstPersonalUserCache.computeIfAbsent(
									cacheKey + ":mstPersonalUser:" + upUserId,
									k -> mstPersonalUserDao.selectById(upUserId));
							if (mstPersonalUser == null) {
								return DOUBLE_BYTE_SPACE;
							}
							return mstPersonalUser.getUserName();
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: ind_user_name取得エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_start_date": // (Row 4,10) 透析日／透析開始時刻
						try {
							if (ordMain.getRstStartDate() == null) {
								return DOUBLE_BYTE_SPACE;
							}
							if (tokens.length >= 3) {
								String formatType = tokens[2];
								if ("full".equals(formatType)) { // "full"で指定された場合、YYYY/MM/DD HH:mm形式
								return formatDateTime(ordMain.getRstStartDate().toString(), journal.getFacilityCd());
								} else if ("time".equals(formatType)) { // "time"で指定された場合、HH:mm形式
								return formatDateToHHmm(ordMain.getRstStartDate().toString(), journal.getFacilityCd());
								} else if ("time_jp".equals(formatType)) { // "time_jp"で指定された場合、HH時mm分形式
								return formatDateToHHmmJapanese(ordMain.getRstStartDate().toString(), journal.getFacilityCd());
								}
							}
							// デフォルトはYYYY年MM月DD日(曜日)形式
							return formatDialysisDate(ordMain.getRstStartDate().toString(), journal.getFacilityCd());
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_start_date変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_end_date": // (Row 11) 透析終了時刻
						try {
							if (ordMain.getRstEndDate() == null) {
								return DOUBLE_BYTE_SPACE;
							}
							if (tokens.length >= 3) {
								String formatType = tokens[2];
								if ("time".equals(formatType)) { // "time"で指定された場合、HH:mm形式
								return formatDateToHHmm(ordMain.getRstEndDate().toString(), journal.getFacilityCd());
								} else if ("time_jp".equals(formatType)) { // "time_jp"で指定された場合、HH時mm分形式
								return formatDateToHHmmJapanese(ordMain.getRstEndDate().toString(), journal.getFacilityCd());
								}
							}
							// デフォルトはYYYY/MM/DD HH:mm形式
							return formatDateTime(ordMain.getRstEndDate().toString(), journal.getFacilityCd());
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_end_date変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_in_out_class": // (Row 7) 入外区分
						try {
							return convertInOutFlg(ordMain.getRstInOutClass());
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_in_out_class変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_dialysis_cnt": // (Row 8) 透析回数[回]
						try {
							return String.valueOf(ordMain.getRstDialysisCnt());
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_dialysis_cnt変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_running_time": // (Row 9) 透析時間（）
						try {
							// 開始日時または終了日時がnullの場合は全角スペースを返す
							if (ordMain.getRstStartDate() == null || ordMain.getRstEndDate() == null) {
								return DOUBLE_BYTE_SPACE;
							}
							long startSeconds = ordMain.getRstStartDate().getTime() / 1000;
							long endSeconds = ordMain.getRstEndDate().getTime() / 1000;
							// 切り捨てた秒数同士の差分を分単位に変換（小数点以下切り捨て）
							int diffMinutes = (int) (endSeconds / 60) - (int) (startSeconds / 60);

							if (tokens.length >= 3) {
								String formatType = tokens[2];
								if ("minute".equals(formatType)) { // "minute"で指定された場合、mm形式
									return formatTimeMinute(diffMinutes, journal.getFacilityCd());
								}
							}							
							return formatTime(diffMinutes, journal.getFacilityCd()); // HH:mm形式
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_running_time変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}

						// ---------------------------
						// 【設備・場所情報】
						// ---------------------------
					case "rst_kur_name": // (Row 12) クール
						return ordMain.getRstKurName() != null ? ordMain.getRstKurName() : DOUBLE_BYTE_SPACE;
					case "rst_bed_name": // (Row 13) ベッド
						return ordMain.getRstBedName() != null ? ordMain.getRstBedName() : DOUBLE_BYTE_SPACE;
					case "rst_ward_name": // (Row 14) 病棟名
						return (ordMain.getRstWardName() != null) ? ordMain.getRstWardName() : DOUBLE_BYTE_SPACE;
					case "rst_course_name": // (Row 15) 診療科
						return (ordMain.getRstCourseName() != null) ? ordMain.getRstCourseName() : DOUBLE_BYTE_SPACE;

					// ---------------------------
					// 【担当者情報】
					// ---------------------------
					case "rst_charge_user_info": // (Row 16,17) 担当者１／２
						try {
							if (tokens.length >= 3) {
								String subKey = tokens[2];
								if ("user_name_1".equals(subKey)) {
									return getChargeUserName(ordMain.getRstChargeUserInfo(), 1);
								} else if ("user_name_2".equals(subKey)) {
									return getChargeUserName(ordMain.getRstChargeUserInfo(), 2);
								}
							}
							return DOUBLE_BYTE_SPACE;
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_charge_user_info取得エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_puncture_user_info": // (Row 18～21) 穿刺者情報
						try {
							if (tokens.length >= 3) {
								String subKey = tokens[2];
								switch (subKey) {
									case "user_name_1":
										return getPunctureUser(ordMain.getRstPunctureUserInfo(), 1, 1);
									case "date_1":
										return formatDateTime(getPunctureUser(ordMain.getRstPunctureUserInfo(), 1, 2),
												journal.getFacilityCd());
									case "user_name_2":
										return getPunctureUser(ordMain.getRstPunctureUserInfo(), 2, 1);
									case "date_2":
										return formatDateTime(getPunctureUser(ordMain.getRstPunctureUserInfo(), 2, 2),
												journal.getFacilityCd());
									case "date":
										return formatDateTime(getPunctureUser(ordMain.getRstPunctureUserInfo(), 0, 2),
												journal.getFacilityCd());
									default:
										return DOUBLE_BYTE_SPACE;
								}
							}
							return DOUBLE_BYTE_SPACE;
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_puncture_user_info取得エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_return_user_info": // (Row 22～25) 回収者情報
						try {
							if (tokens.length >= 3) {
								String subKey = tokens[2];
								switch (subKey) {
									case "user_name_1":
										return getCollectUser(ordMain.getRstReturnUserInfo(), 1, 1);
									case "date_1":
										return formatDateTime(getCollectUser(ordMain.getRstReturnUserInfo(), 1, 2),
												journal.getFacilityCd());
									case "user_name_2":
										return getCollectUser(ordMain.getRstReturnUserInfo(), 2, 1);
									case "date_2":
										return formatDateTime(getCollectUser(ordMain.getRstReturnUserInfo(), 2, 2),
												journal.getFacilityCd());
									case "date":
										return formatDateTime(getCollectUser(ordMain.getRstReturnUserInfo(), 0, 2),
												journal.getFacilityCd());
									default:
										return DOUBLE_BYTE_SPACE;
								}
							}
							return DOUBLE_BYTE_SPACE;
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_return_user_info取得エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}

						// ---------------------------
						// 【体重・除水情報】
						// ---------------------------
					case "rst_weight_info": // (Row 26～40) 体重情報各項目
						try {
							if (tokens.length >= 3) {
								String subKey = tokens[2];
								// tokens[3]が存在する場合は桁数として扱う
								Integer decimalPlaces = null;
								if (tokens.length >= 4) {
									try {
										decimalPlaces = Integer.parseInt(tokens[3]);
									} catch (NumberFormatException e) {
										outputLog(LogLevel.WARN, journal.getFacilityCd(),
												"rst_weight_info: tokens[3]が数値ではありません: " + tokens[3]);
									}
								}
								switch (subKey) {
									case "weight_after": // Row 26（前回後体重）
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "weight_after", journal, decimalPlaces);
										}
								return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "weight_after", journal);
									case "weight_before": // (Row 27) 透析前体重[kg]
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "weight_before", journal, decimalPlaces);
										}
								return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "weight_before", journal);
									case "weight_before_date": // (Row 28) 透析前体重測定日時（YYYY/MM/DD HH:mm形式）
										return formatDateTime(getRstWeightInfoValue(ordMain.getRstWeightInfo(),
												"weight_before_date", journal), journal.getFacilityCd());
									case "ctr": // (Row 29) CTR[%]
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "ctr", journal, decimalPlaces);
										}
										return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "ctr", journal);
									case "ctr_weight": // (Row 30) CTR測定時体重[kg]
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "ctr_weight", journal, decimalPlaces);
										}
										return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "ctr_weight", journal);
									case "ctr_measure_date": // (Row 31) CTR測定日（YYYY/MM/DD形式）
										return formatDate(
										getRstWeightInfoValue(ordMain.getRstWeightInfo(), "ctr_measure_date", journal),
												journal.getFacilityCd());
									case "water_removal_target": // (Row 33) 目標除水量[L]
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "water_removal_target",
													journal, decimalPlaces);
										}
										return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "water_removal_target",
												journal);
									case "weight": // (Row 34) 除水補正値[g]
										try {
											return selectRstDialysisWaterRemoveHst(journal, cache, preFlg);
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
											"selectOrdMain: selectRstDialysisWaterRemoveHst呼び出しエラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									case "water_removal_rst": // (Row 35) 除水実績[L]
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "water_removal_rst", journal, decimalPlaces);
										}
								return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "water_removal_rst", journal);
									case "add_total": // (Row 35) 除水実績[L] ※おそらく使用しない
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "add_total", journal, decimalPlaces);
										}
										return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "add_total", journal);
									case "kt_v_measure": // (Row 36) Kt/V測定値
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "kt_v_measure", journal, decimalPlaces);
										}
								return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "kt_v_measure", journal);
									case "urr": // (Row 37) URR[%]
										if (decimalPlaces != null) {
									return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "urr", journal, decimalPlaces);
										}
										return getRstWeightInfoValue(ordMain.getRstWeightInfo(), "urr", journal);
									case "recrcl_rt": // (Row 38) 再循環率[%] の処理
									{
										try {
											// まず、RstWeightInfo内の "recrcl_rt" のJSON文字列を取得する
											String recrclRtJsonStr = getRstWeightInfoValue(ordMain.getRstWeightInfo(),
													"recrcl_rt", journal);
											if (recrclRtJsonStr == null || recrclRtJsonStr.trim().isEmpty()
													|| recrclRtJsonStr.equals(DOUBLE_BYTE_SPACE)) {
												return DOUBLE_BYTE_SPACE;
											}
											try {
												JSONObject recrclObj = new JSONObject(recrclRtJsonStr);
												// valid_noで指定された番号を取得（例: 1）
												int validNo = recrclObj.optInt("valid_no", -1);
												if (validNo == -1) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: recrcl_rt - valid_noが見つかりません。");
													return DOUBLE_BYTE_SPACE;
												}
												// validNoで指定された番号をキーとして、そのオブジェクトを取得する（キーは文字列として扱う）
										JSONObject validEntry = recrclObj.optJSONObject(String.valueOf(validNo));
												if (validEntry == null) {
													outputLog(LogLevel.ERROR, journal.getFacilityCd(),
															"selectOrdMain: recrcl_rt - 指定されたvalid_no(" + validNo
																	+ ")のエントリが存在しません。");
													return DOUBLE_BYTE_SPACE;
												}
												// 指定エントリ内の "rate" の値を取得して返す
												String rate = validEntry.optString("rate", "");
												return rate.isEmpty() ? DOUBLE_BYTE_SPACE : rate;
											} catch (JSONException e) {
												outputLog(LogLevel.ERROR, journal.getFacilityCd(),
														"selectOrdMain: recrcl_rt JSON parse error: " + e.getMessage());
												return DOUBLE_BYTE_SPACE;
											}
										} catch (Exception e) {
											outputLog(LogLevel.ERROR, journal.getFacilityCd(),
													"selectOrdMain: recrcl_rt処理エラー: " + e.getMessage());
											return DOUBLE_BYTE_SPACE;
										}
									}

									case "weight_after_date": // (Row 40) 透析後体重測定日時（YYYY/MM/DD HH:mm形式）
										return formatDateTime(
										getRstWeightInfoValue(ordMain.getRstWeightInfo(), "weight_after_date", journal),
												journal.getFacilityCd());
									default:
										return DOUBLE_BYTE_SPACE;
								}
							}
							return DOUBLE_BYTE_SPACE;
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_weight_info処理エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}

						// ---------------------------
						// 【その他の項目】
						// ---------------------------
					case "rst_dw": // (Row 58) DW[kg]
						try {
							if (ordMain.getRstDw() == null) {
								return DOUBLE_BYTE_SPACE;
							}
							// tokens[2]が存在する場合は桁数として扱う
							if (tokens.length >= 3) {
								try {
									int decimalPlaces = Integer.parseInt(tokens[2]);
									double value = ordMain.getRstDw().doubleValue();
									String formatPattern = "%." + decimalPlaces + "f";
									return String.format(formatPattern, value);
								} catch (NumberFormatException e) {
									outputLog(LogLevel.WARN, journal.getFacilityCd(),
											"rst_dw: tokens[2]が数値ではありません: " + tokens[2]);
									return ordMain.getRstDw().toString();
								}
							}
							return ordMain.getRstDw().toString();
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_dw変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "ind_treat_start_time": // (Row 54) 001：透析開始時刻（HH:mm形式）
						try {
							return formatTime4(ordMain.getIndTreatStartTime());
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: ind_treat_start_time変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
						// 以下は複数行出力や特別なロジックが必要な項目（表のRow 92～95）：
					case "rst_equip_info": // (Row 92) 医療材料
						try {
							return formatDialysisEquip(ordMain.getRstEquipInfo(), journal.getFacilityCd());
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_equip_info変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_ind_comment_info": // (Row 93) 指示簿指示
						try {
							// ※取得対象フィールドはord_main.rst_ind_comment_info（JSON配列文字列）
							String commentJson = ordMain.getRstIndCommentInfo();
							if (commentJson == null || commentJson.trim().isEmpty()) {
								return DOUBLE_BYTE_SPACE;
							}
							try {
								JSONArray jsonArray = new JSONArray(commentJson);
								List<JSONObject> commentList = new ArrayList<>();
								for (int i = 0; i < jsonArray.length(); i++) {
									commentList.add(jsonArray.getJSONObject(i));
								}
								// 項目番号(no)の昇順にソート
								Collections.sort(commentList, new Comparator<JSONObject>() {
									@Override
									public int compare(JSONObject o1, JSONObject o2) {
										int n1 = o1.optInt("no", 0);
										int n2 = o2.optInt("no", 0);
										return Integer.compare(n1, n2);
									}
								});
								// 各レコードの"content"を取得し、改行コードを全角スペースに置換して連結
								StringBuilder sb = new StringBuilder();
								for (JSONObject obj : commentList) {
									String content = obj.optString("content", "");
									// 改行コード "\n" を全角スペースに変換
									content = content.replace("\n", DOUBLE_BYTE_SPACE);
									sb.append(content).append("\n");
								}
								return sb.toString().trim();
							} catch (JSONException e) {
								outputLog(LogLevel.ERROR, journal.getFacilityCd(),
										"selectOrdMain: ind_ind_comment_info JSON解析エラー: " + e.getMessage());
								return DOUBLE_BYTE_SPACE;
							}
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: ind_ind_comment_info処理エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_medi_info": // (Row 94) 投与薬剤
						try {
							String type = null;
							if (tokens.length >= 3) {
								type = tokens[2];
							}
							// type=1の場合は愁訴の処置薬剤情報も含める
							String treatmentInfoJson = null;
							if ("1".equals(type)) {
								treatmentInfoJson = ordMain.getRstTreatmentInfo();
							}
						return formatMedicationAdministration(ordMain.getRstMediInfo(), type, journal.getFacilityCd(), treatmentInfoJson);
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_medi_info変換エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					case "rst_treatment_info": // (Row 95) 愁訴処置・処置詳細
						try {
							String type = null;
							if (tokens.length >= 3) {
								type = tokens[2];
							}
							// 内部クラス Record：各レコードの情報を保持
							class Record {
								String formattedDate = "";
								String complaint = ""; // 愁訴
								String treatment = ""; // 処置
								String medicine = ""; // 処置薬剤
								String quantityUnit = ""; // 数量単位
								String technique = ""; // 手技
								String operator = ""; // 処置者
								int regOrder; // 登録順（row_no 等）
								int ctlNo; // ctl_no
							}

							List<Record> records = new ArrayList<>();
							// 日時パース・フォーマット用
							SimpleDateFormat isoParser = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
							SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd HH:mm");

							// ① 透析開始イベント（毎回出力）
							String startDateStr = ordMain.getRstStartDate().toString();
							String startFormatted = formatDateTime(startDateStr, journal.getFacilityCd());
							Record startRecord = new Record();
							startRecord.formattedDate = startFormatted;
							startRecord.complaint = "透析開始";
							startRecord.regOrder = 0; // 同日時の場合、先頭に出力
							// 透析開始イベントには ctl_no は設定しない（もしくは特定値）
							records.add(startRecord);

							// ② 愁訴情報と処置詳細情報の統合
							// マージ用の Map：キーは "ctl_no_row_no" という複合キーを利用
							Map<String, Record> mergedRecords = new HashMap<>();

							// (a) 愁訴情報（ordMain.getRstComplaintInfo()）
							String complaintJson = ordMain.getRstComplaintInfo();
							if (complaintJson != null && !complaintJson.trim().isEmpty()) {
								JSONArray complaintArray = new JSONArray(complaintJson);
								for (int i = 0; i < complaintArray.length(); i++) {
									JSONObject obj = complaintArray.getJSONObject(i);
									int rowNo = obj.optInt("row_no", i + 1);
									int ctlNo = obj.optInt("ctl_no", 0);
									// 複合キー生成
									String key_a = ctlNo + "_" + rowNo;
									Record rec = mergedRecords.getOrDefault(key_a, new Record());
									rec.complaint = obj.optString("complaint", "");
									rec.ctlNo = ctlNo;
									// 発生日時
									String occurDateStr = obj.optString("occur_date", "");
									if (!occurDateStr.isEmpty()) {
										try {
											Date occurDate = isoParser.parse(occurDateStr);
											rec.formattedDate = formatter.format(occurDate);
										} catch (ParseException e) {
											rec.formattedDate = occurDateStr;
										}
									}
									rec.regOrder = rowNo;
									mergedRecords.put(key_a, rec);
								}
							}

							// (b) 処置詳細情報（ordMain.getRstTreatmentInfo()）
							String treatmentJson = ordMain.getRstTreatmentInfo();
							if (treatmentJson != null && !treatmentJson.trim().isEmpty()) {
								JSONArray treatmentArray = new JSONArray(treatmentJson);
								for (int i = 0; i < treatmentArray.length(); i++) {
									JSONObject obj = treatmentArray.getJSONObject(i);
									int rowNo = obj.optInt("row_no", i + 1);
									int ctlNo = obj.optInt("ctl_no", 0);
									String key_b = ctlNo + "_" + rowNo;
									Record rec = mergedRecords.getOrDefault(key_b, new Record());
									if ("3".equals(obj.optString("treat_class", ""))) {
										// 酸素吸入
										if ("".equals(obj.optString("linkStartDate", ""))) {
											// 酸素吸入開始
											rec.treatment = "酸素吸入開始 " + obj.optString("oxygen_speed", "") + "L/min";
										} else {
											// 酸素吸入終了
											rec.treatment = "酸素吸入終了 " + obj.optString("oxygen_amount", "") + "L";
										}
									} else if ("4".equals(obj.optString("treat_class", ""))) {
										// 心電図
										if ("".equals(obj.optString("linkStartDate", ""))) {
											// 心電図測定開始
											rec.treatment = "心電図測定開始";
										} else {
											// 心電図測定終了
											rec.treatment = "心電図測定終了";
										}
									} else {
										rec.treatment = obj.optString("treat_name", "");
										rec.medicine = obj.optString("treat_medicine_name", "");
										int amount = obj.optInt("amount", 0);
										String unit = obj.optString("unit", "");
										rec.quantityUnit = (amount != 0 ? String.valueOf(amount) : "") + unit;
										rec.technique = obj.optString("procedure_name", "");
									}

									rec.ctlNo = ctlNo;
									// 発生日時補完（既に設定済みの場合はそのまま）
									String occurDateStr = obj.optString("occur_date", "");
									if (!occurDateStr.isEmpty()) {
										try {
											Date occurDate = isoParser.parse(occurDateStr);
											rec.formattedDate = formatter.format(occurDate);
										} catch (ParseException e) {
											rec.formattedDate = occurDateStr;
										}
									}
									if (rec.regOrder == 0) {
										rec.regOrder = rowNo;
									}
									mergedRecords.put(key_b, rec);
								}
							}

							// マージ結果をリストに追加
							records.addAll(mergedRecords.values());

							// ③ 透析終了イベント（毎回出力）
							String endDateStr = ordMain.getRstEndDate().toString();
							String endFormatted = formatDateTime(endDateStr, journal.getFacilityCd());
							Record endRecord = new Record();
							endRecord.formattedDate = endFormatted;
							endRecord.complaint = "透析終了";
							endRecord.regOrder = 9999; // 同日時の場合、最後に出力
							records.add(endRecord);

							// ④ 処置者情報（rst_treat_staff_info）の取得とマージ
							String treatStaffJson = ordMain.getRstTreatStaffInfo();
							if (treatStaffJson != null && !treatStaffJson.trim().isEmpty()) {
								JSONArray staffArray = new JSONArray(treatStaffJson);
								// Map: key = ctl_no, value = TreeMap<row_no, staffName>
								Map<Integer, SortedMap<Integer, String>> staffMap = new HashMap<>();
								for (int i = 0; i < staffArray.length(); i++) {
									JSONObject obj = staffArray.getJSONObject(i);
									int ctlNo = obj.optInt("ctl_no", 0);
									int rowNo = obj.optInt("row_no", 0);
									String staffName = obj.optString("treat_staff_name", "");
									if (ctlNo != 0) {
										SortedMap<Integer, String> map = staffMap.get(ctlNo);
										if (map == null) {
											map = new TreeMap<>();
											staffMap.put(ctlNo, map);
										}
										map.put(rowNo, staffName);
									}
								}
								// マージ：各レコードに対して、ctl_no と regOrder（row_no）の組み合わせで処置者を設定
								for (Record rec : records) {
									if (rec.ctlNo != 0) {
										SortedMap<Integer, String> map = staffMap.get(rec.ctlNo);
										if (map != null && !map.isEmpty()) {
											// 一致する row_no があればその処置者、なければ同一 ctl_no の最後の row_no の処置者を使用
											if (map.containsKey(rec.regOrder)) {
												rec.operator = map.get(rec.regOrder);
											} else {
												rec.operator = map.get(map.lastKey());
											}
										}
									}
								}
							}

							// ⑤ ソート：日時昇順、同日時の場合は regOrder 昇順
							Collections.sort(records, new Comparator<Record>() {
								@Override
								public int compare(Record r1, Record r2) {
									if (r1.formattedDate == null)
										return -1;
									if (r2.formattedDate == null)
										return 1;
									int cmp = r1.formattedDate.compareTo(r2.formattedDate);
									if (cmp == 0) {
										return Integer.compare(r1.regOrder, r2.regOrder);
									}
									return cmp;
								}
							});

							// ⑥ 出力：type=1の場合は時間ごとにグループ化、それ以外は既存フォーマット
							StringBuilder sb = new StringBuilder();
							if ("1".equals(type)) {
								// type=1: 時間ごとにグループ化したフォーマット
								// 日付を跨ぐ可能性があるため、完全な日時文字列をキーにする
								Map<String, List<String>> timeGroupedStartEnd = new LinkedHashMap<>();
								Map<String, List<String>> timeGroupedComplaints = new LinkedHashMap<>();
								Map<String, List<String>> timeGroupedTreatments = new LinkedHashMap<>();

								for (Record rec : records) {
									// 完全な日時文字列をキーとして使用（yyyy/MM/dd HH:mm形式）
									String fullDateTime = rec.formattedDate != null ? rec.formattedDate : "";

									if (rec.regOrder == 0 || rec.regOrder == 9999) {
										// 透析開始/終了は別に格納（ラベルなし）
										if (!rec.complaint.isEmpty()) {
										timeGroupedStartEnd.computeIfAbsent(fullDateTime, k -> new ArrayList<>()).add(rec.complaint);
										}
									} else {
										// 愁訴と処置を分けて格納
										if (!rec.complaint.isEmpty()) {
										timeGroupedComplaints.computeIfAbsent(fullDateTime, k -> new ArrayList<>()).add(rec.complaint);
										}
										if (!rec.treatment.isEmpty()) {
											// 処置情報を構築（処置名のみ。薬剤情報は投与薬剤セクションに表示される）
										timeGroupedTreatments.computeIfAbsent(fullDateTime, k -> new ArrayList<>()).add(rec.treatment);
										}
									}
								}

								// 日時順に出力（TreeSetで完全な日時文字列をソート）
								// 透析開始/終了のみの時刻は除外する
								Set<String> allDateTimes = new TreeSet<>();
								// allDateTimes.addAll(timeGroupedStartEnd.keySet());
								allDateTimes.addAll(timeGroupedComplaints.keySet());
								allDateTimes.addAll(timeGroupedTreatments.keySet());

								for (String fullDateTime : allDateTimes) {
									// 表示は時刻のみ（HH:mm形式）
									String timeOnly = "";
									if (fullDateTime != null && fullDateTime.length() >= 16) {
									timeOnly = fullDateTime.substring(11).trim(); // "yyyy/MM/dd HH:mm" から "HH:mm" を取得
									}
									sb.append(timeOnly).append("\n");

									// 透析開始/終了を出力（ラベルなし）Type＝１の場合は出力しない
									// List<String> startEnds = timeGroupedStartEnd.get(fullDateTime);
									// if (startEnds != null && !startEnds.isEmpty()) {
//									sb.append("　").append(String.join("、", startEnds)).append("\n");
									// }

									// 愁訴を出力
									List<String> complaints = timeGroupedComplaints.get(fullDateTime);
									if (complaints != null && !complaints.isEmpty()) {
										sb.append("　愁訴:").append(String.join("、", complaints)).append("\n");
									}

									// 処置を出力
									List<String> treatments = timeGroupedTreatments.get(fullDateTime);
									if (treatments != null && !treatments.isEmpty()) {
										sb.append("　処置:").append(String.join("、", treatments)).append("\n");
									}
								}
							} else {
								// type=1以外: 既存フォーマット
								String prevFormattedDate = "";
								for (Record rec : records) {
									String datePart = "                ";
									if (!rec.formattedDate.equals(prevFormattedDate)) {
										datePart = rec.formattedDate;
										prevFormattedDate = rec.formattedDate;
									}
									if (rec.regOrder == 0 || rec.regOrder == 9999) {
										// 各フィールドを全角スペース「 」で連結 先頭行と末尾は時刻と「透析開始」「透析終了」文言のみ
										sb.append(datePart).append("　").append(rec.complaint).append("\n");
									} else {
										// 各フィールドを全角スペース「 」で連結
									sb.append(datePart).append("　").append(rec.complaint).append("　").append(rec.treatment)
												.append("　").append(rec.medicine).append("　").append(rec.quantityUnit)
												.append("　").append(rec.technique).append("　").append(rec.operator)
												.append("\n");
									}
								}
							}
							return sb.toString().trim();
						} catch (JSONException e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_treatment_info JSON解析エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectOrdMain: rst_treatment_info処理エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					default:
						return DOUBLE_BYTE_SPACE;
				}
			} catch (Exception e) {
				outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectOrdMain: switch処理エラー: " + e.getMessage());
				return DOUBLE_BYTE_SPACE;
			}
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectOrdMain: 予期しないエラー: " + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 患者情報テーブルから、指定されたカラムの値（例：患者ID、氏名等）を取得します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @param tokens  取得対象の文字列（例："PAT_BASIC_INFO/NAME"）
	 * @return 対象データが存在すればその値、存在しない場合は全角スペース
	 */
	private String selectPatPersonalMain(SysCoopJournal journal, String[] tokens, CacheContext cache) {
		String cacheKey = "PatPersonalMain:" + journal.getPatId();

		PatPersonalMain patPersonalMain = cache.patPersonalMainCache.computeIfAbsent(cacheKey,
				key -> patPersonalMainDao.selectById(journal.getPatId()));
		if (patPersonalMain == null || tokens == null) {
			return DOUBLE_BYTE_SPACE;
		}

		if (tokens.length < 2) {
			return DOUBLE_BYTE_SPACE;
		}

		String key = tokens[1];
		switch (key) {
			case "hosp_pat_id":
				return patPersonalMain.getHosp_pat_id();
			case "pat_name":
				return patPersonalMain.getPat_last_name() + " " + patPersonalMain.getPat_first_name();
			case "dial_diff_com_info":
				try {
					String dialDiffComInfoJson = patPersonalMain.getDial_diff_com_info();

					List<String> dialDiffCdList = new ArrayList<>();

					if (dialDiffComInfoJson != null && !dialDiffComInfoJson.isEmpty()) {
						try {
							JSONArray array = new JSONArray(dialDiffComInfoJson);

							// JSONObjectのリストに変換してソート
							List<JSONObject> jsonObjectList = new ArrayList<>();
							for (int i = 0; i < array.length(); i++) {
								JSONObject obj = array.getJSONObject(i);
								String isDialDiff = obj.optString("is_dial_diff", "0");
								if ("1".equals(isDialDiff)) {
									jsonObjectList.add(obj);
								}
							}

							// is_main=1を先に、その後reg_date昇順でソート
							jsonObjectList.sort((obj1, obj2) -> {
								String isMain1 = obj1.optString("is_main", "0");
								String isMain2 = obj2.optString("is_main", "0");

								// is_main=1が先
								if ("1".equals(isMain1) && !"1".equals(isMain2)) {
									return -1;
								}
								if (!"1".equals(isMain1) && "1".equals(isMain2)) {
									return 1;
								}

								// 同じis_mainの場合はreg_date昇順
								String regDate1 = obj1.optString("reg_date", "");
								String regDate2 = obj2.optString("reg_date", "");
								return regDate1.compareTo(regDate2);
							});

							// ソート済みリストからdial_diff_cdを抽出
							for (JSONObject obj : jsonObjectList) {
								String dialDiffCd = obj.optString("dial_diff_cd", "");
								if (!dialDiffCd.isEmpty()) {
									dialDiffCdList.add(dialDiffCd);
								}
							}
						} catch (Exception parseEx) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"dial_diff_com_info JSONパースエラー: " + parseEx.getMessage());
						}
					}

					if (!dialDiffCdList.isEmpty()) {
						List<String> dialysisDifficultyNames = new ArrayList<>();

						for (String dialDiffCd : dialDiffCdList) {
			            String cacheKeyDialDiffCd = "MstDialysisDifficulty:" + journal.getFacilityCd() + ":" + dialDiffCd;

			            MstDialysisDifficulty difficulty = cache.mstDialysisDifficultyCache.computeIfAbsent(cacheKeyDialDiffCd,
									keyDialDiffCd -> mstDialysisDifficultyDao.selectByCd(Integer.parseInt(dialDiffCd)));

							if (difficulty != null && difficulty.getDialysisDifficultyName() != null) {
								dialysisDifficultyNames.add(difficulty.getDialysisDifficultyName());
							}
						}

						if (!dialysisDifficultyNames.isEmpty()) {
							return "有り/" + String.join(",", dialysisDifficultyNames);
						} else {
							return "有り";
						}
					}
					return DOUBLE_BYTE_SPACE;

				} catch (Exception e) {
					outputLog(LogLevel.ERROR, journal.getFacilityCd(),
							"selectByFacilitySettingNo: システム設定取得エラー: " + e.getMessage());
					return DOUBLE_BYTE_SPACE;
				}
			default:
				return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 指定された文字列に含まれるモニタ情報（mni_monitor）の記述に基づき、対象のデータを取得します。 トークンは"/"で分割され、例として
	 * "mni_monitor/monitor_data/BP_BEFORE_MAX" や "mni_monitor/BP_AFTER_DATE"
	 * を想定します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @param tokens  連携設定文字列を "/" で分割した配列
	 * @param cache   キャッシュコンテキスト
	 * @return 取得されたデータ、または取得できなかった場合は全角スペース
	 */
	private String selectMniMonitor(SysCoopJournal journal, String[] tokens, CacheContext cache, Boolean preFlg) {
		try {
			// tokensが不正な場合は全角スペースを返す
			if (tokens == null || tokens.length < 2) {
				outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMniMonitor: トークンが不足しています。");
				return DOUBLE_BYTE_SPACE;
			}

			final long ordNo;
			try {
				if (preFlg) {
					OrdMain ordMain = getOrdMain(journal, cache, preFlg);
					if (ordMain == null) {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMniMonitor: OrdMainがnullです。");
						return DOUBLE_BYTE_SPACE;
					}
					ordNo = ordMain.getOrdNo();
				} else {
					ordNo = journal.getOrdNo();
				}
			} catch (Exception e) {
				outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMniMonitor: ordNo取得エラー: " + e.getMessage());
				return DOUBLE_BYTE_SPACE;
			}

			// tokens[0]は "mni_monitor" である前提
			// tokens[1]が "monitor_data" の場合はさらに tokens[2] でフィールドを指定するケース
			String field;
			try {
				if ("monitor_data".equalsIgnoreCase(tokens[1])) {
					if (tokens.length < 3) {
						// tokensが "mni_monitor/monitor_data" のみの場合は、最新の体温を返す
						try {
							MniMonitor mniMonitor = cache.mniMonitorCache.computeIfAbsent("MniMonitor:new:" + ordNo,
									key -> mniMonitorDao.selectMonitorByFacilityCdAndPatIdAndOrdNo(
											journal.getFacilityCd(), journal.getPatId(), ordNo));
							return (mniMonitor == null) ? DOUBLE_BYTE_SPACE
									: getDataFromJson(mniMonitor.getMonitorData(), 94);
						} catch (Exception e) {
							outputLog(LogLevel.ERROR, journal.getFacilityCd(),
									"selectMniMonitor: monitor_data単体処理エラー: " + e.getMessage());
							return DOUBLE_BYTE_SPACE;
						}
					} else {
						field = tokens[2].toUpperCase();
					}
				} else {
					// tokens[1]自体がフィールド名の場合
					field = tokens[1].toUpperCase();
				}
			} catch (Exception e) {
				outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMniMonitor: フィールド名処理エラー: " + e.getMessage());
				return DOUBLE_BYTE_SPACE;
			}

			// 前血圧系の情報（データタイプ5）: BP_BEFORE_XXX, PULSE_BEFORE, BP_BEFORE_DATE など
			try {
				if (field.startsWith("BP_BEFORE") || field.startsWith("PULSE_BEFORE")) {
					MniMonitor mniMonitor = null;
					try {
						mniMonitor = cache.mniMonitorCache.computeIfAbsent("MniMonitor:5:" + ordNo, key -> mniMonitorDao
								.selectByOrdNoDataTypeLast(journal.getFacilityCd(), ordNo, (short) 5));
					} catch (Exception e) {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectMniMonitor: 前血圧系データ取得エラー: " + e.getMessage());
						return DOUBLE_BYTE_SPACE;
					}

					if (mniMonitor == null) {
						return DOUBLE_BYTE_SPACE;
					}

					try {
						switch (field) {
							case "BP_BEFORE_MAX":
								return getDataFromJson(mniMonitor.getMonitorData(), 90);
							case "BP_BEFORE_MIN":
								return getDataFromJson(mniMonitor.getMonitorData(), 91);
							case "BP_BEFORE_AVE":
								return getDataFromJson(mniMonitor.getMonitorData(), 92);
							case "PULSE_BEFORE":
								return getDataFromJson(mniMonitor.getMonitorData(), 93);
							case "BP_BEFORE_DATE":
								return formatDateTime(
										mniMonitor.getOccurDate() != null ? mniMonitor.getOccurDate().toString() : "",
										journal.getFacilityCd());
							default:
								outputLog(LogLevel.ERROR, journal.getFacilityCd(),
										"selectMniMonitor: 未定義の前血圧系フィールド:" + field);
								return DOUBLE_BYTE_SPACE;
						}
					} catch (Exception e) {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectMniMonitor: 前血圧系データ処理エラー(" + field + "): " + e.getMessage());
						return DOUBLE_BYTE_SPACE;
					}
				}
				// 後血圧系の情報（データタイプ6）: BP_AFTER_XXX, PULSE_AFTER, TEMPERATURE, BP_AFTER_DATE など
				else if (field.startsWith("BP_AFTER") || field.startsWith("PULSE_AFTER")
						|| "TEMPERATURE".equals(field)) {
					MniMonitor mniMonitor = null;
					try {
						mniMonitor = cache.mniMonitorCache.computeIfAbsent("MniMonitor:6:" + ordNo, key -> mniMonitorDao
								.selectByOrdNoDataTypeLast(journal.getFacilityCd(), ordNo, (short) 6));
					} catch (Exception e) {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectMniMonitor: 後血圧系データ取得エラー: " + e.getMessage());
						return DOUBLE_BYTE_SPACE;
					}

					if (mniMonitor == null) {
						return DOUBLE_BYTE_SPACE;
					}

					try {
						switch (field) {
							case "BP_AFTER_MAX":
								return getDataFromJson(mniMonitor.getMonitorData(), 90);
							case "BP_AFTER_MIN":
								return getDataFromJson(mniMonitor.getMonitorData(), 91);
							case "BP_AFTER_AVE":
								return getDataFromJson(mniMonitor.getMonitorData(), 92);
							case "PULSE_AFTER":
								return getDataFromJson(mniMonitor.getMonitorData(), 93);
							case "BP_AFTER_DATE":
								return formatDateTime(
										mniMonitor.getOccurDate() != null ? mniMonitor.getOccurDate().toString() : "",
										journal.getFacilityCd());
							default:
								outputLog(LogLevel.ERROR, journal.getFacilityCd(),
										"selectMniMonitor: 未定義の後血圧系フィールド:" + field);
								return DOUBLE_BYTE_SPACE;
						}
					} catch (Exception e) {
						outputLog(LogLevel.ERROR, journal.getFacilityCd(),
								"selectMniMonitor: 後血圧系データ処理エラー(" + field + "): " + e.getMessage());
						return DOUBLE_BYTE_SPACE;
					}
				}
				// 想定外のフィールド
				else {
					outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMniMonitor: 不明なフィールド:" + field);
					return DOUBLE_BYTE_SPACE;
				}
			} catch (Exception e) {
				outputLog(LogLevel.ERROR, journal.getFacilityCd(),
						"selectMniMonitor: データタイプ判別処理エラー: " + e.getMessage());
				return DOUBLE_BYTE_SPACE;
			}
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMniMonitor: 予期しないエラー: " + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 患者・指示情報以外の補助情報として、治療情報（mst_treatment）のデータを取得します。 連携設定文字列は
	 * "$mst_treatment/treatment_name$" のような形式を想定しています。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @param tokens  連携設定文字列を "/" で分割した配列（例：{"mst_treatment", "treatment_name"}）
	 * @param cache   キャッシュコンテキスト
	 * @return 取得した治療情報。取得できない場合は全角スペースを返す。
	 */
	private String selectMstTreament(SysCoopJournal journal, String[] tokens, CacheContext cache, Boolean preFlg) {
		// tokensが不正な場合は全角スペースを返す
		if (tokens == null || tokens.length < 2) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMstTreament: トークンが不足しています。");
			return DOUBLE_BYTE_SPACE;
		}
		OrdMain ordMain = getOrdMain(journal, cache, preFlg);
		if (ordMain == null || ordMain.getTreatDate() == null) {
			return DOUBLE_BYTE_SPACE;
		}

		int treatmentCd = ordMain.getIndTreatmentCd();
		MstTreatment mstTreatment = cache.mstTreatmentCache.computeIfAbsent("MstTreatment:" + treatmentCd,
				key -> mstTreatmentDao.selectByCd(treatmentCd));
		if (mstTreatment == null) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(),
					"selectMstTreament: mst_treatmentレコードが見つかりません。キー=" + treatmentCd);
			return DOUBLE_BYTE_SPACE;
		}

		// tokens[1]により、取得対象のフィールドを切り分ける
		String field = tokens[1].toLowerCase();
		switch (field) {
			case "treatment_name":
				return mstTreatment.getTreatmentName();
			default:
				outputLog(LogLevel.ERROR, journal.getFacilityCd(), "selectMstTreament: 未定義のフィールド:" + field);
				return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 透析日を「YYYY年MM月DD日(曜日)」形式にフォーマットします。<br>
	 * 例: 2025年02月20日(木)
	 *
	 * @param string     対象の日付文字列（Date型）
	 * @param facilityCd ログ出力用の施設コード
	 * @return フォーマット済み日付文字列。入力がnullやパースに失敗した場合は全角スペースを返す。
	 */
	private String formatDialysisDate(String string, String facilityCd) {
		if (string == null) {
			return DOUBLE_BYTE_SPACE;
		}

		OffsetDateTime odt = null;

		// ① タイムゾーン情報付き (ISO-8601形式) の場合
		try {
			odt = OffsetDateTime.parse(string);
		} catch (DateTimeParseException e) {
			// ② タイムゾーンが無い場合のフォーマット "yyyy-MM-dd HH:mm:ss.S"
			try {
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.S");
				LocalDateTime ldt = LocalDateTime.parse(string, formatter);
				odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
			} catch (DateTimeParseException e2) {
				// ③ 別のパターン "yyyy/MM/dd HH:mm:ss" の場合
				try {
					DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
					LocalDateTime ldt = LocalDateTime.parse(string, formatter);
					odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
				} catch (DateTimeParseException e3) {
					outputLog(LogLevel.ERROR, facilityCd, "formatDialysisDate parse error: " + string);
					return DOUBLE_BYTE_SPACE;
				}
			}
		}

		// 出力形式の設定
		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy年MM月dd日(E)", Locale.JAPANESE);
		return odt.format(outputFormatter);
	}

	/**
	 * 日付を「HH:mm」形式にフォーマットします。<br>
	 * 例: 14:30
	 *
	 * @param string     対象の日付文字列（Date型）
	 * @param facilityCd ログ出力用の施設コード
	 * @return フォーマット済み時刻文字列。入力がnull、またはパースに失敗した場合は全角スペースを返す。
	 */
	private String formatDateToHHmm(String string, String facilityCd) {
		if (string == null) {
			return DOUBLE_BYTE_SPACE;
		}

		OffsetDateTime odt = null;

		// ① ISO-8601形式 (タイムゾーン付き) でのパース
		try {
			odt = OffsetDateTime.parse(string);
		} catch (DateTimeParseException e) {
			// ② タイムゾーン無しの場合のパターン "yyyy-MM-dd HH:mm:ss.S"
			try {
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.S");
				LocalDateTime ldt = LocalDateTime.parse(string, formatter);
				odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
			} catch (DateTimeParseException e1) {
				// ③ パターン "yyyy/MM/dd HH:mm:ss"
				try {
					DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
					LocalDateTime ldt = LocalDateTime.parse(string, formatter);
					odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
				} catch (DateTimeParseException e2) {
					// ④ パターン "yyyy/MM/dd HH:mm" （秒がない場合）
					try {
						DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
						LocalDateTime ldt = LocalDateTime.parse(string, formatter);
						odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
					} catch (DateTimeParseException e3) {
						outputLog(LogLevel.ERROR, facilityCd, "formatDateToHHmm:" + string);
						return DOUBLE_BYTE_SPACE;
					}
				}
			}
		}

		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("HH:mm");
		return odt.format(outputFormatter);
	}

	/**
	 * 日付文字列をHH時mm分形式の文字列に変換します。<br>
	 * 例: "2025-01-15T09:30:00" -> "09時30分"
	 *
	 * @param string     日付文字列
	 * @param facilityCd 施設コード
	 * @return HH時mm分形式の文字列
	 */
	private String formatDateToHHmmJapanese(String string, String facilityCd) {
		if (string == null) {
			return DOUBLE_BYTE_SPACE;
		}

		OffsetDateTime odt = null;

		// ① ISO-8601形式 (タイムゾーン付き) でのパース
		try {
			odt = OffsetDateTime.parse(string);
		} catch (DateTimeParseException e) {
			// ② タイムゾーン無しの場合のパターン "yyyy-MM-dd HH:mm:ss.S"
			try {
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.S");
				LocalDateTime ldt = LocalDateTime.parse(string, formatter);
				odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
			} catch (DateTimeParseException e1) {
				// ③ パターン "yyyy/MM/dd HH:mm:ss"
				try {
					DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
					LocalDateTime ldt = LocalDateTime.parse(string, formatter);
					odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
				} catch (DateTimeParseException e2) {
					// ④ パターン "yyyy/MM/dd HH:mm" （秒がない場合）
					try {
						DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
						LocalDateTime ldt = LocalDateTime.parse(string, formatter);
						odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
					} catch (DateTimeParseException e3) {
						outputLog(LogLevel.ERROR, facilityCd, "formatDateToHHmmJapanese:" + string);
						return DOUBLE_BYTE_SPACE;
					}
				}
			}
		}

		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("HH時mm分");
		return odt.format(outputFormatter);
	}

	/**
	 * 分単位の整数値をHH:mm形式の文字列に変換します。<br>
	 * 例: 90 -> "01:30"
	 *
	 * @param totalMinutes 分単位の時間
	 * @return HH:mm形式の文字列。エラー時は空文字または適宜変更してください。
	 */
	private String formatTime(int totalMinutes, String facilityCd) {
		try {
			int hours = totalMinutes / 60;
			int minutes = totalMinutes % 60;
			return String.format("%02d:%02d", hours, minutes);
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, facilityCd, "totalMinutes:" + totalMinutes);
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 分単位の整数値をmm形式の文字列に変換します。<br>
	 *
	 * @param totalMinutes 分単位の時間
	 * @return mm形式の文字列。エラー時は空文字または適宜変更してください。
	 */
	private String formatTimeMinute(int totalMinutes, String facilityCd) {
		try {
			return String.format("%d", totalMinutes);
		} catch (Exception e) {
			outputLog(LogLevel.ERROR, facilityCd, "totalMinutes:" + totalMinutes);
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 4桁の時刻文字列(例: "0930")を "HH:MM" 形式に変換するメソッド
	 *
	 * @param timeStr 4桁の時刻文字列
	 * @return "HH:MM" 形式に変換された文字列
	 */
	public static String formatTime4(String timeStr) {
		if (timeStr == null || timeStr.length() != 4) {
			return DOUBLE_BYTE_SPACE;
		}
		// 先頭2文字を時間、3文字目以降2文字を分として抽出
		String hours = timeStr.substring(0, 2);
		String minutes = timeStr.substring(2, 4);

		// コロンで連結して "HH:MM" 形式にする
		return hours + ":" + minutes;
	}

	/**
	 * 日付と時刻を「YYYY/MM/DD HH:mm」形式に変換します。<br>
	 * 例: 2025/02/20 14:30
	 *
	 * @param date       日時文字列（ISO-8601など）
	 * @param facilityCd ログ出力用の施設コード
	 * @return フォーマット済み日付時刻文字列。入力がnullの場合、またはエラーの場合は全角スペースを返す。
	 */
	private String formatDateTime(String date, String facilityCd) {
		if (date == null) {
			return DOUBLE_BYTE_SPACE;
		}

		OffsetDateTime odt = null;

		// ① ISO-8601形式（タイムゾーン付き）でのパース
		try {
			odt = OffsetDateTime.parse(date);
		} catch (DateTimeParseException e) {
			// ② パターン "yyyy-MM-dd HH:mm:ss.S" でのパース（タイムゾーンなしの場合）
			try {
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.S");
				LocalDateTime ldt = LocalDateTime.parse(date, formatter);
				odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
			} catch (DateTimeParseException e2) {
				// ③ パターン "yyyy/MM/dd HH:mm:ss" でのパース
				try {
					DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
					LocalDateTime ldt = LocalDateTime.parse(date, formatter);
					odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
				} catch (DateTimeParseException e3) {
					// ④ パターン "yyyy/MM/dd HH:mm" でのパース（秒がない場合）
					try {
						DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
						LocalDateTime ldt = LocalDateTime.parse(date, formatter);
						odt = ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
					} catch (DateTimeParseException e4) {
						outputLog(LogLevel.ERROR, facilityCd, "formatDateTime:" + date);
						return DOUBLE_BYTE_SPACE;
					}
				}
			}
		}

		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
		return odt.format(outputFormatter);
	}

	/**
	 * 日付を「YYYY/MM/DD」形式に変換します。<br>
	 * 例: 2025/02/20
	 *
	 * @param date       対象の日付
	 * @param facilityCd ログ出力用の施設コード
	 * @return フォーマット済み日付文字列。入力がnullの場合、またはエラーの場合は全角スペースを返す。
	 */
	private String formatDate(String date, String facilityCd) {
		if (date == null) {
			return DOUBLE_BYTE_SPACE;
		}

		OffsetDateTime odt = null;
		// ① ISO-8601形式（タイムゾーン付き）のパースを試行
		try {
			odt = OffsetDateTime.parse(date);
		} catch (DateTimeParseException e) {
			// ② パターン "yyyy-MM-dd" でのパース（タイムゾーンなしの場合）
			try {
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
				LocalDate localDate = LocalDate.parse(date, formatter);
				odt = localDate.atStartOfDay(ZoneId.systemDefault()).toOffsetDateTime();
			} catch (DateTimeParseException e2) {
				// ④ パターン "yyyyMMdd" でのパース（タイムゾーンなしの場合）
				try {
					DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
					LocalDate localDate = LocalDate.parse(date, formatter);
					odt = localDate.atStartOfDay(ZoneId.systemDefault()).toOffsetDateTime();
				} catch (DateTimeParseException e4) {
					outputLog(LogLevel.ERROR, facilityCd, "formatDate:" + date);
					return DOUBLE_BYTE_SPACE;
				}
			}
		}

		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy/MM/dd");
		return odt.format(outputFormatter);
	}

	/**
	 * 入外区分コードを「外来」または「入院」に変換します。<br>
	 * 入力がnullの場合は全角スペースを返す。
	 *
	 * @param short1 入外区分のコード（0または1）
	 * @return 変換後の文字列
	 */
	private static String convertInOutFlg(Short short1) {
		if (short1 == null) {
			return DOUBLE_BYTE_SPACE;
		}
		switch (short1) {
			case 0:
				return "外来";
			case 1:
				return "入院";
			default:
				return "外来";
		}
	}

	/**
	 * JSON文字列から、指定された担当者番号に対応する担当者の氏名（姓＋名）を取得します。
	 *
	 * @param jsonStr      JSON形式の文字列（例: {"user_last_name_1": "山田",
	 *                     "user_first_name_1": "太郎", ...}）
	 * @param chargeNumber 担当者番号（例: 1 または 2）
	 * @return 取得した氏名。取得できない場合は全角スペースを返す。
	 */
	private String getChargeUserName(String jsonStr, int chargeNumber) {
		if (jsonStr == null || jsonStr.isEmpty()) {
			return "";
		}
		try {
			JSONObject json = new JSONObject(jsonStr);
			String lastName = json.optString("user_last_name_" + chargeNumber, "");
			String firstName = json.optString("user_first_name_" + chargeNumber, "");
			return getuserName(lastName, firstName);
		} catch (JSONException e) {
			// 必要に応じてログ出力する
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * JSON文字列から、指定された刺突者番号に対応する氏名または日付情報を取得します。<br>
	 * typeが1の場合は氏名（姓＋名）を、2の場合は日付情報（"date_○"）を返します。
	 *
	 * @param jsonStr      JSON形式の文字列（例: {"user_last_name_1": "山田",
	 *                     "user_first_name_1": "太郎", "date_1": "2025/02/20 14:30",
	 *                     ...}）
	 * @param chargeNumber 刺突者番号（例: 1 または 2）
	 * @param type         取得する情報の種別（1:氏名、2:日付）
	 * @return 取得した情報。取得できない場合は全角スペースを返す。
	 */
	private String getPunctureUser(String jsonStr, int chargeNumber, int type) {
		if (jsonStr == null || jsonStr.isEmpty()) {
			return "";
		}
		try {
			JSONObject json = new JSONObject(jsonStr);
			if (type == 1) { // 担当者情報を取得
				String lastName = json.optString("user_last_name_" + chargeNumber, "");
				String firstName = json.optString("user_first_name_" + chargeNumber, "");
				return getuserName(lastName, firstName);
			} else if (type == 2) { // 日付情報を取得
				String optString = chargeNumber == 0 ? "date" : "date_" + chargeNumber;
				String dateValue = json.optString(optString, "");
				if (!dateValue.isEmpty()) {
					return dateValue;
				}
				return DOUBLE_BYTE_SPACE;
			} else {
				return DOUBLE_BYTE_SPACE;
			}
		} catch (JSONException e) {
			// 必要に応じてログ出力等のエラーハンドリングを実施
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * JSON文字列から、指定された回収者番号に対応する氏名または日付情報を取得します。<br>
	 * typeが1の場合は氏名（姓＋名）を、2の場合は日付情報（"date_○"）を返します。
	 *
	 * @param jsonStr      JSON形式の文字列
	 * @param chargeNumber 回収者番号（例: 1 または 2）
	 * @param type         取得する情報の種別（1:氏名、2:日付）
	 * @return 取得した情報。取得できない場合は全角スペースを返す。
	 */
	private String getCollectUser(String jsonStr, int chargeNumber, int type) {
		if (jsonStr == null || jsonStr.isEmpty()) {
			return "";
		}
		try {
			JSONObject json = new JSONObject(jsonStr);
			if (type == 1) { // 担当者情報を取得
				String lastName = json.optString("user_last_name_" + chargeNumber, "");
				String firstName = json.optString("user_first_name_" + chargeNumber, "");
				return getuserName(lastName, firstName);
			} else if (type == 2) { // 日付情報を取得
				String optString = chargeNumber == 0 ? "date" : "date_" + chargeNumber;
				String dateValue = json.optString(optString, "");
				if (!dateValue.isEmpty()) {
					return dateValue;
				}
				return DOUBLE_BYTE_SPACE;
			} else {
				return DOUBLE_BYTE_SPACE;
			}
		} catch (JSONException e) {
			// 必要に応じてログ出力等のエラーハンドリングを実施
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 姓名から氏名を取得します。<br>
	 * 姓名どちらも値がある場合は姓＋半角スペース + 名を、どちらかのみ値がある場合は値があるもの、どちらも値が無い場合は全角スペースを返します。
	 *
	 * @param lastName  姓
	 * @param firstName 名
	 * @return 取得した情報。取得できない場合は全角スペースを返す。
	 */
	private String getuserName(String lastName, String firstName) {
		if (!lastName.isEmpty() && !firstName.isEmpty()) {
			return lastName + " " + firstName;
		} else if (!lastName.isEmpty() && firstName.isEmpty()) {
			return lastName;
		} else if (lastName.isEmpty() && !firstName.isEmpty()) {
			return firstName;
		}
		return DOUBLE_BYTE_SPACE;
	}

	/**
	 * RstWeightInfo の JSON 文字列から、指定のキーに対応する値を取得します。<br>
	 * 値が存在しない、null、もしくは空文字の場合は全角スペースを返します。
	 *
	 * @param jsonStr RstWeightInfo の JSON 文字列
	 * @param key     取得対象のキー（例："ctr", "weight_after", "recrcl_rt" 等）
	 * @return キーに対応する値。取得できない場合は全角スペースを返す。
	 */
	private String getRstWeightInfoValue(String jsonStr, String key, SysCoopJournal journal) {
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "getRstWeightInfoValue-jsonStr:" + jsonStr);
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "getRstWeightInfoValue-key:" + key);
		if (jsonStr == null || jsonStr.isEmpty() || key == null || key.isEmpty()) {
			return DOUBLE_BYTE_SPACE;
		}
		try {
			JSONObject json = new JSONObject(jsonStr);
			if (!json.has(key)) {
				return DOUBLE_BYTE_SPACE;
			}
			Object value = json.opt(key);
			// 値が null または JSONObject.NULL の場合
			if (value == null || JSONObject.NULL.equals(value)) {
				return DOUBLE_BYTE_SPACE;
			}
			String result = value.toString();
			// 空文字の場合も全角スペースを返す
			if (result.trim().isEmpty() || "null".equals(result)) {
				return DOUBLE_BYTE_SPACE;
			}
			return result;
		} catch (JSONException e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "getRstWeightInfoValue:" + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * JSON文字列から指定キーの値を取得し、指定された小数桁数でフォーマットします。<br>
	 * 例: decimalPlaces=2の場合、"1" -> "1.00", "1.5" -> "1.50"
	 *
	 * @param jsonStr       JSON形式の文字列
	 * @param key           取得対象のキー
	 * @param journal       ジャーナル情報
	 * @param decimalPlaces 小数点以下の桁数
	 * @return フォーマットされた値。取得できない場合は全角スペースを返す。
	 */
	private String getRstWeightInfoValue(String jsonStr, String key, SysCoopJournal journal, int decimalPlaces) {
		String value = getRstWeightInfoValue(jsonStr, key, journal);
		if (DOUBLE_BYTE_SPACE.equals(value)) {
			return DOUBLE_BYTE_SPACE;
		}
		try {
			double numValue = Double.parseDouble(value);
			String formatPattern = "%." + decimalPlaces + "f";
			return String.format(formatPattern, numValue);
		} catch (NumberFormatException e) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(),
					"getRstWeightInfoValue(桁数指定): 数値変換エラー: " + value);
			return value; // 数値変換できない場合は元の値を返す
		}
	}

	/**
	 * JSON文字列から、指定された番号のオブジェクト内の指定キーの値を取得します。<br>
	 * キーが存在しない、null、または空の場合は全角スペースを返します。
	 *
	 * @param jsonStr JSON形式の文字列
	 * @param number  番号（例：1, 2, ...）※JSONのキーは文字列（"1", "2", ...）として存在する前提
	 * @param key     取得対象のキー（例："unit", "value", "ind_user_last_name" など）
	 * @return 指定キーに対応する値。取得できない場合は全角スペースを返す。
	 */
	private static String getDataFromJson(String jsonStr, int number, String key) {
		if (jsonStr == null || jsonStr.isEmpty() || key == null || key.isEmpty()) {
			return DOUBLE_BYTE_SPACE;
		}

		String index = String.valueOf(number);
		try {
			JSONObject json = new JSONObject(jsonStr);
			if (!json.has(index)) {
				return DOUBLE_BYTE_SPACE;
			}
			JSONObject subObj = json.optJSONObject(index);
			if (subObj == null || !subObj.has(key)) {
				return DOUBLE_BYTE_SPACE;
			}
			Object value = subObj.opt(key);
			if (value == null || JSONObject.NULL.equals(value)) {
				return DOUBLE_BYTE_SPACE;
			}
			String result = value.toString();
			if (result.trim().isEmpty() || "null".equals(result)) {
				return DOUBLE_BYTE_SPACE;
			}
			return result;
		} catch (JSONException e) {
			// 必要に応じてログ出力等のエラーハンドリングを実施
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * JSON文字列から、指定された番号の値を取得します。<br>
	 * キーが存在しない、null、または空の場合は全角スペースを返します。
	 *
	 * @param jsonStr JSON形式の文字列
	 * @param number  番号（例：1, 2, ...）
	 * @return 指定番号に対応する値。取得できない場合は全角スペースを返す。
	 */
	private static String getDataFromJson(String jsonStr, int number) {
		if (jsonStr == null || jsonStr.isEmpty()) {
			return DOUBLE_BYTE_SPACE;
		}

		String index = String.valueOf(number);
		try {
			JSONObject json = new JSONObject(jsonStr);
			if (!json.has(index)) {
				return DOUBLE_BYTE_SPACE;
			}

			Object value = json.opt(index);
			if (value == null || JSONObject.NULL.equals(value)) {
				return DOUBLE_BYTE_SPACE;
			}

			String result = value.toString();
			if (result.trim().isEmpty() || "null".equals(result)) {
				return DOUBLE_BYTE_SPACE;
			}
			return result;
		} catch (JSONException e) {
			// 必要に応じてログ出力等のエラーハンドリングを実施
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * 透析実績の医療材料情報（JSON配列）から、各項目を指定のフォーマットで作成します。<br>
	 * 【出力フォーマット】<br>
	 * 医療材料名（全角スペース）数量単位<br>
	 * 例: name + " " + amount + unit<br>
	 * 【ソート順】<br>
	 * JSON内の各オブジェクトの "no" の昇順（登録順）
	 *
	 * @param jsonArrayStr 医療材料の情報が格納されたJSON配列の文字列
	 * @return 各項目を1行ずつ連結した文字列。入力が不正な場合は全角スペースを返す。
	 */
	private String formatDialysisEquip(String jsonArrayStr, String facilityCd) {
		if (jsonArrayStr == null || jsonArrayStr.isEmpty()) {
			return DOUBLE_BYTE_SPACE;
		}
		try {
			JSONArray jsonArray = new JSONArray(jsonArrayStr);
			// JSONArrayの各要素をリストに格納
			List<JSONObject> materialList = new ArrayList<>();
			for (int i = 0; i < jsonArray.length(); i++) {
				materialList.add(jsonArray.getJSONObject(i));
			}
			// "no" の昇順でソート
			Collections.sort(materialList, new Comparator<JSONObject>() {
				@Override
				public int compare(JSONObject a, JSONObject b) {
					int noA = a.optInt("no", 0);
					int noB = b.optInt("no", 0);
					return Integer.compare(noA, noB);
				}
			});
			// 各項目を指定フォーマットで出力
			StringBuilder sb = new StringBuilder();
			for (JSONObject obj : materialList) {
				// 各キーの値が取得できなかった場合は全角スペースを返す
				String name = obj.optString("name", "").trim();
				if (name.isEmpty()) {
					name = DOUBLE_BYTE_SPACE;
				}
				String amount = obj.optString("amount", "").trim();
				if (amount.isEmpty()) {
					amount = DOUBLE_BYTE_SPACE;
				}
				String unit = obj.optString("unit", "").trim();
				if (unit.isEmpty()) {
					unit = DOUBLE_BYTE_SPACE;
				}
				// 出力フォーマット: 医療材料名 数量単位
				String line = name + DOUBLE_BYTE_SPACE + amount + unit;
				sb.append(line).append(System.lineSeparator());
			}
			return sb.toString().trim();
		} catch (JSONException e) {
			outputLog(LogLevel.ERROR, facilityCd, "formatDialysisEquip:" + e.getMessage());
			// JSON パースに失敗した場合は全角スペースを返す
			return DOUBLE_BYTE_SPACE;
		}
	}

	// 未実施時のパディング用（半角スペース10桁）
	private static final String PAD_10_HALF_WIDTH = "          ";

	/**
	 * 投与薬剤情報のJSON配列から、指定のフォーマットの文字列を作成します。<br>
	 * 【出力フォーマット】<br>
	 * 実施状況（全角スペース）薬剤名（全角スペース）数量単位（全角スペース）手技（全角スペース）実施者<br>
	 * ※未実施の場合は「未実施」＋半角スペース10桁、実施済の場合は effect_date を "yyyy/MM/dd HH:mm"
	 * 形式に変換し半角スペースを付加します。<br>
	 * 【ソート順】<br>
	 * 1. 未実施項目（effect_flg ≠ 1）を先頭に（未実施が複数の場合は no の昇順）<br>
	 * 2. 実施済項目（effect_flg == 1）は effect_date の昇順
	 *
	 * @param jsonArrayStr 投与薬剤情報が格納されたJSON配列の文字列
	 * @param type         処理タイプを指定するパラメータ（nullの場合はデフォルト処理）
	 * @param facilityCd   施設コード
	 * @return 各項目を1行ずつ連結した文字列。入力が不正な場合は全角スペースを返す。
	 */
	public String formatMedicationAdministration(String jsonArrayStr, String type, String facilityCd, String treatmentInfoJson) {
		// ログ出力（開始）
		outputLog(LogLevel.DEBUG, facilityCd, "Entered formatMedicationAdministration. jsonArrayStr length: "
				+ (jsonArrayStr != null ? jsonArrayStr.length() : "null") + ", type: " + type);

		if (jsonArrayStr == null || jsonArrayStr.isEmpty()) {
			outputLog(LogLevel.DEBUG, facilityCd,
					"formatMedicationAdministration: Input jsonArrayStr is null or empty. Returning DOUBLE_BYTE_SPACE.");
			return DOUBLE_BYTE_SPACE;
		}

		// type分岐処理
		// type=1: 簡易形式（薬剤名 + 全角スペース + 数量 + 単位）
		// type=null: デフォルト処理（従来の詳細形式）

		try {
			JSONArray jsonArray = new JSONArray(jsonArrayStr);
			outputLog(LogLevel.DEBUG, facilityCd, "Parsed JSON array. Length: " + jsonArray.length());

			// 未実施／実施済みリストの作成
			List<JSONObject> notExecutedList = new ArrayList<>();
			List<JSONObject> executedList = new ArrayList<>();

			// effect_flg による振り分け
			for (int i = 0; i < jsonArray.length(); i++) {
				JSONObject obj = jsonArray.getJSONObject(i);
				int effectFlg = obj.optInt("effect_flg", 0);
				if (effectFlg == 1) {
					executedList.add(obj);
				} else {
					notExecutedList.add(obj);
				}
			}
			outputLog(LogLevel.DEBUG, facilityCd, "Split lists: notExecutedList size = " + notExecutedList.size()
					+ ", executedList size = " + executedList.size());

			// 未実施：no の昇順ソート
			Collections.sort(notExecutedList, new Comparator<JSONObject>() {
				@Override
				public int compare(JSONObject a, JSONObject b) {
					int noA = a.optInt("no", 0);
					int noB = b.optInt("no", 0);
					return Integer.compare(noA, noB);
				}
			});
			outputLog(LogLevel.DEBUG, facilityCd, "Sorted notExecutedList by 'no' ascending.");

			// 実施済：effect_date の昇順ソート
			Collections.sort(executedList, new Comparator<JSONObject>() {
				@Override
				public int compare(JSONObject a, JSONObject b) {
					String dateA = a.optString("effect_date", "");
					String dateB = b.optString("effect_date", "");
					OffsetDateTime dA = parseEffectDate(dateA, facilityCd);
					OffsetDateTime dB = parseEffectDate(dateB, facilityCd);
					if (dA == null && dB == null)
						return 0;
					if (dA == null)
						return -1;
					if (dB == null)
						return 1;
					return dA.compareTo(dB);
				}
			});
			outputLog(LogLevel.DEBUG, facilityCd, "Sorted executedList by 'effect_date' ascending.");

			// リスト結合
			List<JSONObject> resultList = new ArrayList<>();
			if ("1".equals(type)) {
				// 第一優先: 元の投与薬剤（executedList）を先に追加
				resultList.addAll(executedList);

				// 第二優先: 愁訴の処置情報から薬剤情報を別リストに追加
				List<JSONObject> treatmentMedicineList = new ArrayList<>();
				if (treatmentInfoJson != null && !treatmentInfoJson.trim().isEmpty()) {
					try {
						JSONArray treatmentArray = new JSONArray(treatmentInfoJson);
						for (int i = 0; i < treatmentArray.length(); i++) {
							JSONObject treatObj = treatmentArray.getJSONObject(i);
							// treat_medicine_nameが存在する場合のみ追加
							String medicineName = treatObj.optString("treat_medicine_name", "").trim();
							if (!medicineName.isEmpty()) {
								// 投与薬剤と同じフォーマットのJSONObjectを作成
								JSONObject medicineObj = new JSONObject();
								medicineObj.put("name", medicineName);

								int amount = treatObj.optInt("amount", 0);
								String unit = treatObj.optString("unit", "").trim();
								if (amount != 0) {
									medicineObj.put("amount", String.valueOf(amount));
								} else {
									medicineObj.put("amount", "");
								}
								medicineObj.put("unit", unit);

								// occur_dateを使用してソート用のeffect_dateを設定
								String occurDate = treatObj.optString("occur_date", "");
								if (!occurDate.isEmpty()) {
									medicineObj.put("effect_date", occurDate);
								}

								treatmentMedicineList.add(medicineObj);
							}
						}

						// 愁訴由来の薬剤をoccur_date（effect_date）でソート
						Collections.sort(treatmentMedicineList, new Comparator<JSONObject>() {
							@Override
							public int compare(JSONObject a, JSONObject b) {
								String dateA = a.optString("effect_date", "");
								String dateB = b.optString("effect_date", "");
								if (dateA.isEmpty() && dateB.isEmpty()) return 0;
								if (dateA.isEmpty()) return -1;
								if (dateB.isEmpty()) return 1;
								return dateA.compareTo(dateB);
							}
						});

						// 愁訴由来の薬剤を元の投与薬剤の後に追加
						resultList.addAll(treatmentMedicineList);
					} catch (JSONException e) {
						outputLog(LogLevel.ERROR, facilityCd,
								"formatMedicationAdministration: treatmentInfoJson parse error: " + e.getMessage());
					}
				}
			} else {
				resultList.addAll(notExecutedList);
				resultList.addAll(executedList);
			}

			// 出力文字列生成
			StringBuilder sb = new StringBuilder();
			for (JSONObject obj : resultList) {
				StringBuilder line = new StringBuilder();

				// type=1の場合は簡易形式（薬剤名 + 全角スペース + 数量 + 単位）
				if ("1".equals(type)) {
					String name = obj.optString("name", "").trim();
					if (name.isEmpty()) {
						name = DOUBLE_BYTE_SPACE;
					}
					String amount = obj.optString("amount", "").trim();
					String unit = obj.optString("unit", "").trim();
					String quantityUnit = (amount + unit).isEmpty() ? DOUBLE_BYTE_SPACE : amount + unit;

					line.append(name).append(DOUBLE_BYTE_SPACE).append(quantityUnit);
				} else {
					// デフォルト処理（従来の形式）
					int effectFlg = obj.optInt("effect_flg", 0);
					String status;
					if (effectFlg == 1) {
						String effectDateStr = obj.optString("effect_date", "").trim();
						String formattedDate = formatEffectDate(effectDateStr, facilityCd);
						status = formattedDate + " ";
					} else {
						status = "未実施" + PAD_10_HALF_WIDTH;
					}
					String name = obj.optString("name", "").trim();
					if (name.isEmpty()) {
						name = DOUBLE_BYTE_SPACE;
					}
					String amount = obj.optString("amount", "").trim();
					String unit = obj.optString("unit", "").trim();
					String quantityUnit = (amount + unit).isEmpty() ? DOUBLE_BYTE_SPACE : amount + unit;
					String procedure = obj.optString("procedure_name", "").trim();
					if (procedure.isEmpty()) {
						procedure = DOUBLE_BYTE_SPACE;
					}
					String executor = "";
					if (effectFlg == 1) {
						String lastName = obj.optString("effect_user_last_name", "").trim();
						String firstName = obj.optString("effect_user_first_name", "").trim();
						executor = getuserName(lastName, firstName);
					}
					line.append(status).append(DOUBLE_BYTE_SPACE).append(name).append(DOUBLE_BYTE_SPACE)
							.append(quantityUnit).append(DOUBLE_BYTE_SPACE).append(procedure);
					if (effectFlg == 1) {
						line.append(DOUBLE_BYTE_SPACE).append(executor);
					}
				}
				sb.append(line.toString()).append(System.lineSeparator());
			}
			String result = sb.toString().trim();
			outputLog(LogLevel.DEBUG, facilityCd,
					"formatMedicationAdministration finished processing. Result length: " + result.length());
			return result;
		} catch (JSONException e) {
			outputLog(LogLevel.ERROR, facilityCd,
					"formatMedicationAdministration: JSONException occurred: " + e.getMessage());
			return DOUBLE_BYTE_SPACE;
		}
	}

	/**
	 * effect_date（ISO形式: yyyy-MM-dd'T'HH:mm:ssZ）の文字列を "yyyy/MM/dd HH:mm" 形式に変換します。
	 *
	 * @param dateStr    effect_date の文字列
	 * @param facilityCd 施設コード
	 * @return フォーマット済みの日付文字列。変換できない場合は全角スペースを返す。
	 */
	private String formatEffectDate(String dateStr, String facilityCd) {
		outputLog(LogLevel.DEBUG, facilityCd, "Entered formatEffectDate. dateStr: " + dateStr);
		OffsetDateTime dateTime = parseEffectDate(dateStr, facilityCd);
		if (dateTime == null || dateStr == null) {
			outputLog(LogLevel.DEBUG, facilityCd, "formatEffectDate: dateTime is null. Returning DOUBLE_BYTE_SPACE.");
			return DOUBLE_BYTE_SPACE;
		}
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
		String formattedDate = dateTime.format(formatter);
		outputLog(LogLevel.DEBUG, facilityCd, "formatEffectDate: Formatted date: " + formattedDate);
		return formattedDate;
	}

	/**
	 * effect_date の文字列（ISO形式）を OffsetDateTime オブジェクトに変換します。<br>
	 * 例: "2024-12-11T16:59:38+0900"
	 *
	 * @param dateStr    effect_date の文字列
	 * @param facilityCd 施設コード
	 * @return 変換された OffsetDateTime オブジェクト。変換できない場合は null を返す。
	 */
	private OffsetDateTime parseEffectDate(String dateStr, String facilityCd) {
		outputLog(LogLevel.DEBUG, facilityCd, "Entered parseEffectDate. dateStr: " + dateStr);
		if (dateStr == null || dateStr.isEmpty()) {
			outputLog(LogLevel.DEBUG, facilityCd, "parseEffectDate: dateStr is null or empty. Returning null.");
			return null;
		}
		try {
			// まずは標準パースを試みる
			return OffsetDateTime.parse(dateStr);
		} catch (Exception e) {
			outputLog(LogLevel.DEBUG, facilityCd,
					"Standard parsing failed for dateStr: " + dateStr + ". Trying to insert colon in timezone.");
			try {
				// タイムゾーンがコロンなしの場合、最後の4桁にマッチしていればコロンを挿入
				if (dateStr.matches(".*[+-]\\d{4}$")) {
					dateStr = dateStr.substring(0, dateStr.length() - 2) + ":"
							+ dateStr.substring(dateStr.length() - 2);
					outputLog(LogLevel.DEBUG, facilityCd, "Modified dateStr: " + dateStr);
				}
				return OffsetDateTime.parse(dateStr);
			} catch (Exception ex) {
				outputLog(LogLevel.ERROR, facilityCd,
						"parseEffectDate: Exception during parsing after modification: " + ex.getMessage());
				return null;
			}
		}
	}

	/**
	 * ログ出力
	 *
	 * @param level      {@link LogLevel} ログレベル
	 * @param facilityCd 施設コード
	 * @param message    ログメッセージ
	 */
	private void outputLog(LogLevel level, String facilityCd, String message) {
		EventLogMessage elm = new EventLogMessage();
		elm.setFacilityCd(facilityCd);
		elm.setLogMessage(message);
		elm.setInvokeClass(this.getClass().getName());
		logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
	}

	/**
	 * 値が一般的に空（ブランク）とみなされるかを判定します。
	 *
	 * @param value 判定対象の値
	 * @return 空とみなされる場合はtrue
	 */
	private boolean isBlankValue(String value) {
		if (value == null) {
			return true;
		}

		// 文字列として評価する前にtrimして前後の空白を除去
		String trimmedValue = value.trim();

		// 一般的に空とみなされる値をチェック
		return trimmedValue.isEmpty() || // 空文字列
				DOUBLE_BYTE_SPACE.equals(value) || // 全角スペース（システム定数）
				"null".equalsIgnoreCase(trimmedValue) || // "null"文字列（大文字小文字無視）
				"NULL".equals(trimmedValue) || // "NULL"文字列
				"　".equals(trimmedValue) || // 全角スペース（直接指定）
				"\u3000".equals(trimmedValue) || // 全角スペース（Unicode）
				"-".equals(trimmedValue) || // ハイフン（データなしを示すことがある）
				"N/A".equalsIgnoreCase(trimmedValue) || // N/A
				"n/a".equals(trimmedValue) || // n/a
				"undefined".equalsIgnoreCase(trimmedValue) || // undefined
				"".equals(trimmedValue); // 空文字列（念のため再チェック）
	}

	/**
	 * 制御コマンド付きのサブトークンを処理します。
	 *
	 * 対応する制御コマンド:
	 * - HIDE_IF_EMPTY: 値がnull、空文字列、全角スペースの場合に行をスキップ
	 * - SKIP_IF_NULL: 値がnullの場合に行をスキップ
	 * - HIDE_IF_BLANK: 値が一般的に空とみなされる値の場合に行をスキップ
	 * (null, 空文字列、全角スペース、"null"、"NULL"、"N/A"、"undefined"、"-" など)
	 *
	 * @param journal  システム連携ジャーナル情報
	 * @param subtoken 制御コマンドを含む可能性があるサブトークン
	 * @param cache    キャッシュコンテキスト
	 * @return 処理結果。制御コマンドによりスキップする場合はnullを返す
	 */
	private String processControlCommand(SysCoopJournal journal, String subtoken, CacheContext cache) {
		// $変数$が含まれている場合は変数展開
		if (subtoken.contains("$")) {
			StringBuilder result = new StringBuilder();
			int pos = 0;
			while (pos < subtoken.length()) {
				int startIdx = subtoken.indexOf('$', pos);
				if (startIdx == -1) {
					result.append(subtoken.substring(pos));
					break;
				}
				result.append(subtoken.substring(pos, startIdx));

				int endIdx = subtoken.indexOf('$', startIdx + 1);
				if (endIdx == -1) {
					// 閉じ$がない場合はそのまま追加
					result.append(subtoken.substring(startIdx));
					break;
				}

				String varContent = subtoken.substring(startIdx + 1, endIdx);

				// $IF(...)$ の形式をチェック
				if (varContent.startsWith("IF(")) {
					String ifResult = processIf(journal, varContent, cache);
					result.append(ifResult != null ? ifResult : "");
				}
				// $HIDE_IF_BLANK:...$ などの制御コマンドをチェック
				else if (varContent.contains(":") &&
						(varContent.startsWith("HIDE_IF_BLANK") ||
								varContent.startsWith("SKIP_IF_NULL") ||
								varContent.startsWith("HIDE_IF_EMPTY"))) {
					String commandResult = processControlCommandInner(journal, varContent, cache);
					if (commandResult == null) {
						// 制御コマンドがnullを返した場合は行全体をスキップ
						return null;
					}
					result.append(commandResult);
				}
				// 通常の変数展開
				else {
					String data = selectData(journal, varContent, cache);
					result.append(data != null ? data : "");
				}
				pos = endIdx + 1;
			}
			return result.toString();
		}

		// 制御コマンドの形式: COMMAND:データパス
		return processControlCommandInner(journal, subtoken, cache);
	}

	/**
	 * 制御コマンド（COMMAND:データパス形式）を処理します。
	 *
	 * @param journal  システム連携ジャーナル情報
	 * @param subtoken 制御コマンド文字列
	 * @param cache    キャッシュコンテキスト
	 * @return 処理結果。制御コマンドによりスキップする場合はnullを返す
	 */
	private String processControlCommandInner(SysCoopJournal journal, String subtoken, CacheContext cache) {
		if (subtoken.contains(":")) {
			String[] parts = subtoken.split(":", 2);
			if (parts.length == 2) {
				String command = parts[0].trim();
				String dataPath = parts[1].trim();

				// データを取得
				String data = selectData(journal, dataPath, cache);
				outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
					"processControlCommandInner - command:" + command + ", dataPath:" + dataPath + ", data:" + data);

				// 制御コマンドに応じた処理
				switch (command) {
					case "HIDE_IF_EMPTY":
						if (data == null || data.trim().isEmpty() || DOUBLE_BYTE_SPACE.equals(data)) {
							outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
									"HIDE_IF_EMPTY: Skipping empty data for path: " + dataPath);
							return null; // この行全体をスキップ
						}
						return data;

					case "SKIP_IF_NULL":
						if (data == null) {
							outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
									"SKIP_IF_NULL: Skipping null data for path: " + dataPath);
							return null; // この行全体をスキップ
						}
						return data;

					case "HIDE_IF_BLANK":
						if (isBlankValue(data)) {
							outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
									"HIDE_IF_BLANK: Skipping blank data for path: " + dataPath);
							return null; // この行全体をスキップ
						}
						return data;

					default:
						// 不明なコマンドの場合は通常処理
						outputLog(LogLevel.WARN, journal.getFacilityCd(),
								"Unknown control command: " + command + ". Processing as normal data.");
						return selectData(journal, subtoken, cache);
				}
			}
		}

		// 制御コマンドではない場合は通常処理
		return selectData(journal, subtoken, cache);
	}

	/**
	 * IF条件分岐を処理します。
	 *
	 * 構文: IF(条件式, 真の値, 偽の値)
	 *
	 * 対応する比較演算子:
	 * - == : 等しい
	 * - != : 等しくない
	 * - > : より大きい
	 * - >= : 以上
	 * - < : より小さい
	 * - <= : 以下
	 * - IS_NULL : nullチェック
	 * - IS_EMPTY : 空チェック
	 * - IS_BLANK : ブランクチェック
	 *
	 * 例: IF($ord_main/rst_weight_info/weight_before > 50, 重い, 軽い)
	 *
	 * @param journal システム連携ジャーナル情報
	 * @param value   IF式を含む文字列
	 * @param cache   キャッシュコンテキスト
	 * @return 条件評価結果に応じた値
	 */
	private String processIf(SysCoopJournal journal, String value, CacheContext cache) {
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf-before:" + value);

		// IF( から ) までを抽出
		int startIdx = value.indexOf("IF(");
		if (startIdx == -1) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "processIf: IF( が見つかりません");
			return DOUBLE_BYTE_SPACE;
		}

		int endIdx = findMatchingParenthesis(value, startIdx + 2);
		if (endIdx == -1) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(), "processIf: 対応する ) が見つかりません");
			return DOUBLE_BYTE_SPACE;
		}

		// IF文の前後のテキストを保持
		String beforeText = value.substring(0, startIdx);
		String afterText = value.substring(endIdx + 1);

		// IF(xxx) の xxx 部分を取得
		String content = value.substring(startIdx + 3, endIdx);
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf-content:" + content);

		// カンマで分割（ただし括弧内のカンマは無視）
		List<String> parts = splitByComma(content);

		if (parts.size() != 3) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(),
					"processIf: IF構文エラー。3つのパラメータが必要です。実際: " + parts.size());
			return DOUBLE_BYTE_SPACE;
		}

		// 条件式はtrimするが、値はtrimしない（位置調整用のスペースを保持するため）
		String conditionExpr = parts.get(0).trim();
		String trueValue = parts.get(1);
		String falseValue = parts.get(2);

		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf-condition:" + conditionExpr);
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf-trueValue:" + trueValue);
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf-falseValue:" + falseValue);

		// 条件式を評価
		boolean conditionResult = evaluateCondition(journal, conditionExpr, cache);
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf-result:" + conditionResult);

		// 結果に応じた値を返す
		String resultValue = conditionResult ? trueValue : falseValue;

		// nullキーワードの場合はnullを返す（行全体をスキップ）
		// 注: 前後の空白を除去してnullチェック
		if ("null".equalsIgnoreCase(resultValue.trim())) {
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf: null指定のため行をスキップします");
			return null;
		}

		// 結果値を評価（制御コマンド、$変数、計算式に対応）
		String evaluatedResult = evaluateResultValue(journal, resultValue, cache);

		// 評価結果がnullの場合はnullを返す（ネストされたIF文でnullが返された場合）
		if (evaluatedResult == null) {
			outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "processIf: 評価結果がnullのため行をスキップします");
			return null;
		}

		// 前後のテキストと結合して返す
		return beforeText + evaluatedResult + afterText;
	}

	/**
	 * IF文の結果値を評価します。制御コマンド、$変数、計算式、IF文（1レベルのネストのみ）に対応します。
	 *
	 * @param journal     システム連携ジャーナル情報
	 * @param resultValue 評価する結果値
	 * @param cache       キャッシュコンテキスト
	 * @return 評価後の値
	 */
	private String evaluateResultValue(SysCoopJournal journal, String resultValue, CacheContext cache) {
		if (resultValue == null) {
			return null;
		}

		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "evaluateResultValue:" + resultValue);

		// IF文の場合（1レベルのネストに対応）
		if (resultValue.contains("IF(")) {
			return processIf(journal, resultValue, cache);
		}

		// 制御コマンド（HIDE_IF_BLANK, SKIP_IF_NULL, HIDE_IF_EMPTY）の場合
		if (resultValue.contains(":") &&
				(resultValue.startsWith("HIDE_IF_BLANK") ||
						resultValue.startsWith("SKIP_IF_NULL") ||
						resultValue.startsWith("HIDE_IF_EMPTY"))) {
			return processControlCommand(journal, resultValue, cache);
		}

		// ADD/SUB/MUL/DIV計算式の場合
		if (resultValue.contains(TXT_ADD + "(") || resultValue.contains(TXT_SUB + "(") ||
				resultValue.contains(TXT_MUL + "(") || resultValue.contains(TXT_DIV + "(")) {
			return calc(journal, resultValue, cache);
		}

		// $変数が含まれている場合は展開（単純な変数展開のみ）
		if (resultValue.contains("$")) {
			StringBuilder result = new StringBuilder();
			int pos = 0;
			while (pos < resultValue.length()) {
				int startIdx = resultValue.indexOf('$', pos);
				if (startIdx == -1) {
					result.append(resultValue.substring(pos));
					break;
				}
				result.append(resultValue.substring(pos, startIdx));

				int endIdx = resultValue.indexOf('$', startIdx + 1);
				if (endIdx == -1) {
					result.append(resultValue.substring(startIdx));
					break;
				}

				String varPath = resultValue.substring(startIdx + 1, endIdx);
				String data = selectData(journal, varPath, cache);
				result.append(data != null ? data : "");
				pos = endIdx + 1;
			}
			return result.toString();
		}

		// 通常の文字列リテラル
		return resultValue;
	}

	/**
	 * 条件式内の変数を評価します。
	 * $...$で囲まれている場合と囲まれていない場合の両方に対応します。
	 *
	 * @param journal システム連携ジャーナル情報
	 * @param varPart 変数部分（例: "$ord_main/value$" または "ord_main/value"）
	 * @param cache   キャッシュコンテキスト
	 * @return 評価された値
	 */
	private String evaluateVariableInCondition(SysCoopJournal journal, String varPart, CacheContext cache) {
		// $...$ で囲まれている場合
		if (varPart.startsWith("$") && varPart.endsWith("$")) {
			String innerContent = varPart.substring(1, varPart.length() - 1);
			return selectData(journal, innerContent, cache);
		}
		// $ で始まるが $ で終わらない場合（旧形式）
		else if (varPart.startsWith("$")) {
			return selectData(journal, varPart.substring(1), cache);
		}
		// $ がない場合（既に展開済みか、パス指定）
		else {
			return selectData(journal, varPart, cache);
		}
	}

	/**
	 * 条件式を評価します。
	 *
	 * @param journal   システム連携ジャーナル情報
	 * @param condition 条件式（例: "$age >= 65" または "$data IS_NULL"）
	 * @param cache     キャッシュコンテキスト
	 * @return 条件評価結果
	 */
	private boolean evaluateCondition(SysCoopJournal journal, String condition, CacheContext cache) {
		outputLog(LogLevel.DEBUG, journal.getFacilityCd(), "evaluateCondition:" + condition);

		// 特殊条件: IS_NULL, IS_EMPTY, IS_BLANK
		// 注意: 単純なsplitではなく、最初の出現位置で分割する
		if (condition.contains("IS_NULL")) {
			int idx = condition.indexOf("IS_NULL");
			String varPart = condition.substring(0, idx).trim();
			String data = evaluateVariableInCondition(journal, varPart, cache);
			return data == null;
		}

		if (condition.contains("IS_EMPTY")) {
			int idx = condition.indexOf("IS_EMPTY");
			String varPart = condition.substring(0, idx).trim();
			String data = evaluateVariableInCondition(journal, varPart, cache);
			return data == null || data.trim().isEmpty() || DOUBLE_BYTE_SPACE.equals(data);
		}

		if (condition.contains("IS_BLANK")) {
			int idx = condition.indexOf("IS_BLANK");
			String varPart = condition.substring(0, idx).trim();
			String data = evaluateVariableInCondition(journal, varPart, cache);
			return isBlankValue(data);
		}

		// 比較演算子を検出（長い順にチェック）
		String operator = null;
		String[] operatorList = { ">=", "<=", "==", "!=", ">", "<" };

		for (String op : operatorList) {
			if (condition.contains(op)) {
				operator = op;
				break;
			}
		}

		if (operator == null) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(),
					"evaluateCondition: 比較演算子が見つかりません - " + condition);
			return false;
		}

		// 演算子で分割
		String[] parts = condition.split(operator, 2);
		if (parts.length != 2) {
			outputLog(LogLevel.ERROR, journal.getFacilityCd(),
					"evaluateCondition: 条件式の形式が不正です - " + condition);
			return false;
		}

		String leftExpr = parts[0].trim();
		String rightExpr = parts[1].trim();

		// $変数を実際の値に置換
		String leftValue = leftExpr.contains("$")
				? evaluateVariableInCondition(journal, leftExpr, cache)
				: leftExpr;
		String rightValue = rightExpr.contains("$")
				? evaluateVariableInCondition(journal, rightExpr, cache)
				: rightExpr;

		outputLog(LogLevel.DEBUG, journal.getFacilityCd(),
				"evaluateCondition - left:" + leftValue + ", operator:" + operator + ", right:" + rightValue);

		// 比較実行
		return compareValues(journal, leftValue, operator, rightValue);
	}

	/**
	 * 2つの値を比較します。
	 *
	 * @param leftValue  左辺値
	 * @param operator   比較演算子
	 * @param rightValue 右辺値
	 * @return 比較結果
	 */
	private boolean compareValues(SysCoopJournal journal, String leftValue, String operator, String rightValue) {
		// nullチェック
		if (leftValue == null || rightValue == null) {
			if (operator.equals("==")) {
				return leftValue == rightValue;
			} else if (operator.equals("!=")) {
				return leftValue != rightValue;
			}
			return false;
		}

		// 数値として比較を試みる
		try {
			double left = Double.parseDouble(leftValue);
			double right = Double.parseDouble(rightValue);

			switch (operator) {
				case "==":
					return Math.abs(left - right) < 0.0001;
				case "!=":
					return Math.abs(left - right) >= 0.0001;
				case ">":
					return left > right;
				case ">=":
					return left >= right;
				case "<":
					return left < right;
				case "<=":
					return left <= right;
				default:
					outputLog(LogLevel.ERROR, journal.getFacilityCd(),
							"compareValues: 未知の演算子 - " + operator);
					return false;
			}
		} catch (NumberFormatException e) {
			// 数値でない場合は文字列として比較
			switch (operator) {
				case "==":
					return leftValue.equals(rightValue);
				case "!=":
					return !leftValue.equals(rightValue);
				case ">":
					return leftValue.compareTo(rightValue) > 0;
				case ">=":
					return leftValue.compareTo(rightValue) >= 0;
				case "<":
					return leftValue.compareTo(rightValue) < 0;
				case "<=":
					return leftValue.compareTo(rightValue) <= 0;
				default:
					outputLog(LogLevel.ERROR, journal.getFacilityCd(),
							"compareValues: 未知の演算子 - " + operator);
					return false;
			}
		}
	}

	/**
	 * 対応する閉じ括弧の位置を見つけます。
	 *
	 * @param str      検索対象文字列
	 * @param startPos 開始位置（開き括弧の位置）
	 * @return 対応する閉じ括弧の位置。見つからない場合は-1
	 */
	private int findMatchingParenthesis(String str, int startPos) {
		int depth = 1;
		for (int i = startPos + 1; i < str.length(); i++) {
			if (str.charAt(i) == '(') {
				depth++;
			} else if (str.charAt(i) == ')') {
				depth--;
				if (depth == 0) {
					return i;
				}
			}
		}
		return -1;
	}

	/**
	 * カンマで文字列を分割します（括弧内のカンマは無視）。
	 *
	 * @param str 分割対象文字列
	 * @return 分割された文字列リスト
	 */
	private List<String> splitByComma(String str) {
		List<String> result = new ArrayList<>();
		StringBuilder current = new StringBuilder();
		int depth = 0;

		for (char c : str.toCharArray()) {
			if (c == '(') {
				depth++;
				current.append(c);
			} else if (c == ')') {
				depth--;
				current.append(c);
			} else if (c == ',' && depth == 0) {
				result.add(current.toString());
				current.setLength(0);
			} else {
				current.append(c);
			}
		}

		if (current.length() > 0) {
			result.add(current.toString());
		}

		return result;
	}
}
