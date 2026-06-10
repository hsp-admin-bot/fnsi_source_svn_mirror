package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import com.mongodb.bulk.BulkWriteResult;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Order;
import org.springframework.data.mongodb.core.BulkOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.annotation.JsonInclude.Include;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.google.common.base.Strings;
import com.mongodb.client.result.UpdateResult;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.custom.PatNameId;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class IndHistoryServiceImpl implements IndHistoryService {

	public static final int LOG_DATE = 1;
	public static final int TREATMENT_START_DATE = 2;
	private static final String EMPTY = "";
	private static final String FORMAT_DATE = "yyyyMMddHHmmssSSS";

  @Autowired(required = false)
  MongoTemplate mongoTemplate;

	@Autowired
	private OrdMainDao ordMainDao;
	@Autowired
	private PatPersonalMainDao patPersonalMainDao;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end


  /**
   * MongoDB/DocumentDBを使用GET API
   *
   * @param pageable  ページネーション設定
   * @param params    抽出条件
   * @param options   任意検索パラメータ
   * @return
   */
  @Override
  public Page<IndHistory> findAll(Pageable pageable, IndHistory params, IndHistoryOptions options) {
    // 取得データ
    List<IndHistory> result = new ArrayList<IndHistory>();
    // 取得データ総数
    long resultCount = 0;
    // ページネーション
    int skip = (int) pageable.getOffset();
    // 件数
    int limit = pageable.getPageSize();
    // ソート
    Sort sort = pageable.getSort();
    // 抽出条件
    List<Criteria> filterParams = new ArrayList<Criteria>();
    // フリーワード
    List<Criteria> filterSearchParams = new ArrayList<Criteria>();
    // クエリ
    Query query = new Query();

    /**
     * 開始日・終了日処理
     */
    try {
      filterParams.add(Criteria.where("log_date").gte(options.getLogDateStart().replaceAll("-", "") + "000000000"));
    } catch (Exception e) {}

    try {
      filterParams.add(Criteria.where("log_date").lt(options.getLogDateEnd().replaceAll("-", "") + "999999999"));
    } catch (Exception e) {}

    //#6391修正　投与薬剤の場合、投与薬剤をキーワードとして検索する。ljx start
    // mod redmine-6728「指示履歴にて抽出条件での指定とは異なる内容を抽出してくる」 dou start
    /**
     * 抽出条件の投与薬剤の特別処理
     */
    if(!"".equals(params.getLogTarget()) && params.getLogTarget()!= null){
      if (params.getLogTarget().contains("投与薬剤")) {
        params.setLogTarget("投与薬剤");
      }
    }
    // mod redmine-6728「指示履歴にて抽出条件での指定とは異なる内容を抽出してくる」 dou end
    //#6391修正　投与薬剤の場合、投与薬剤をキーワードとして検索する。ljx end

    /**
     * 抽出条件処理
     * 以下はEntityの非nullフィールドをクエリ条件として処理する
     */
    Iterator<Map.Entry<String, JsonNode>> iter = new ObjectMapper()
      .setSerializationInclusion(Include.NON_NULL)
      .setPropertyNamingStrategy(PropertyNamingStrategy.SNAKE_CASE)
      .valueToTree(params)
      .fields();
    Map.Entry<String, JsonNode> curr = null;

    while (iter.hasNext()) {
      curr = iter.next();
      String key = curr.getKey();
      String value = curr.getValue().textValue();

      if (!StringUtils.isEmpty(value)) {
        //治療日の場合
        if (key.equals("treatment_start_date")) {
          //"開始日< 設定した治療日< 終了日" に該当する指示履歴を抽出
          // mod #6465 ljx start
          //投与薬剤を登録する際に、終了日を選択されない場合がある。よって、治療日＜＝終了日 或は　終了日=""の検索条件にする。
          //filterParams.add(Criteria.where("treatment_start_date").is(value.replaceAll("-", "")));
          filterParams.add(Criteria.where("treatment_start_date").lte(value.replaceAll("-", "")));
          //検索条件が治療日である場合、治療日＜＝終了日 或は　終了日=""にする
          filterParams.add(Criteria.where("treatment_end_date").gte(value.replaceAll("-", "")));
          filterParams.add(Criteria.where("treatment_end_date").is(""));
          // mod #6465 ljx end
        } else {
          filterParams.add(Criteria.where(key).is(value));
        }
      } else if (key.equals("created_user_id") || key.equals("updated_user_id")) {
          Long longValue = curr.getValue().longValue();
        if (longValue != null) {
          filterParams.add(Criteria.where(key).is(longValue));
        }
      }
    }

    /**
     * フリーワード処理
     */
    if(!StringUtils.isEmpty(options.getSearchString())) {
      iter = new ObjectMapper()
        .setPropertyNamingStrategy(PropertyNamingStrategy.SNAKE_CASE)
        .valueToTree(params)
        .fields();
      curr = null;

      while (iter.hasNext()) {
        curr = iter.next();
        String key = curr.getKey();

        filterSearchParams.add(Criteria.where(key).regex(Pattern.quote(options.getSearchString())));
      }
    }

    /**
     * クエリ作成
     */
    if(!StringUtils.isEmpty(options.getSearchString())) {
      /**
       * {
       *   "$and" : [
       *      "$and" : [ ... ],
       *      "$or" : [ ... ],
       *   ]
       * }
       */
      if (filterParams.size() > 0) {
        // mod #6465  ljx start
        Criteria filterParam = new Criteria();
        //元のand条件
        List<Criteria> andFilterParams = new ArrayList<Criteria>();
        //or条件用のリスト
        List<Criteria> orFilterParams = new ArrayList<Criteria>();
        for (int i = 0;i<filterParams.size();i++){
          filterParam = filterParams.get(i);
          if("treatment_end_date".equals(filterParam.getKey())) {
          //treatment_end_dateの場合、治療日＜＝終了日 或は　終了日=""のor条件に追加する。
            orFilterParams.add(filterParam);
          }else{
            andFilterParams.add(filterParam);
          }
        }
        if(orFilterParams.size()>0){
          query.addCriteria(
            new Criteria().andOperator(
              new Criteria().andOperator(andFilterParams.toArray(new Criteria[andFilterParams.size()])),
              new Criteria().orOperator(orFilterParams.toArray(new Criteria[orFilterParams.size()])),
              new Criteria().orOperator(filterSearchParams.toArray(new Criteria[filterSearchParams.size()]))
            )
          );
        }else{
          query.addCriteria(
            new Criteria().andOperator(
              new Criteria().andOperator(filterParams.toArray(new Criteria[filterParams.size()])),
              new Criteria().orOperator(filterSearchParams.toArray(new Criteria[filterSearchParams.size()]))
            )
          );
        }
        // mod #6465  ljx end
      }
      else {
        query.addCriteria(new Criteria().orOperator(filterSearchParams.toArray(new Criteria[filterSearchParams.size()])));
      }
    }
    else if (filterParams.size() > 0) {
      // mod #6465  ljx start
      Criteria filterParam = new Criteria();
      //元のand条件
      List<Criteria> andFilterParams = new ArrayList<Criteria>();
      //or条件用のリスト
      List<Criteria> orFilterParams = new ArrayList<Criteria>();
      for (int i = 0;i<filterParams.size();i++){
        filterParam = filterParams.get(i);
        if("treatment_end_date".equals(filterParam.getKey())) {
        //treatment_end_dateの場合、治療日＜＝終了日 或は　終了日=""のor条件に追加する。
          orFilterParams.add(filterParam);
        }else{
          andFilterParams.add(filterParam);
        }
      }
      if(orFilterParams.size()>0){
        query.addCriteria(
          new Criteria().andOperator(
            new Criteria().andOperator(andFilterParams.toArray(new Criteria[andFilterParams.size()])),
            new Criteria().orOperator(orFilterParams.toArray(new Criteria[orFilterParams.size()]))
          )
        );
      }else{
        query.addCriteria(new Criteria().andOperator(filterParams.toArray(new Criteria[filterParams.size()])));
      }

      //query.addCriteria(new Criteria().andOperator(filterParams.toArray(new Criteria[filterParams.size()])));
      // mod #6465  ljx end
	}

	// 追加ソート条件の固定設定
	  /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --start */
	//sort = sort.and(new Sort(Sort.Direction.ASC, "sort_no"));
	sort = sort.and(Sort.by(Sort.Direction.ASC, "sort_no"));
	  /* modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17 --end */

	/* modify by chamaojia 2023-07-09 指示履歴におけるデータ表示不全は、50件のみ  --start */
//    // ページネーション設定
//	query.with(sort).skip(skip).limit(limit);

    // クエリ実行
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        // ページネーションのため、取得するレコードと該当するレコードの件数は異なる場合がある
        resultCount = mongoTemplate.count(query, IndHistory.class);

        // ページネーション設定
        query.with(sort).skip(skip).limit(limit);
        result = mongoTemplate.find(query, IndHistory.class);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (params != null && !StringUtils.isEmpty(params.getFacilityCd())) {
            eventLogMessage.setFacilityCd(params.getFacilityCd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
    /* modify by chamaojia 2023-07-09 指示履歴におけるデータ表示不全は、50件のみ  --end */

	  return new PageImpl<>(result, pageable, resultCount);
  }

  /**
   * MongoDBを使用POST(CREATE) API
   *
   * @param params 保存データ(Entity型)
   * @return
   */
  @Transactional
  public IndHistory create(IndHistory params) {

    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        mongoTemplate.insert(params);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (params != null && !StringUtils.isEmpty(params.getFacilityCd())) {
            eventLogMessage.setFacilityCd(params.getFacilityCd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
    return params;
  }

  /**
   * MongoDBを使用POST(CREATE) API
   *
   * @param paramsList 保存データ(Entity型)
   * @return
   */
  @Override
  @Transactional
  public int createBatch(List<IndHistory> paramsList) {
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        BulkWriteResult bulkWriteResult = mongoTemplate.bulkOps(BulkOperations.BulkMode.ORDERED, IndHistory.class).insert(paramsList).execute();
        return bulkWriteResult.getInsertedCount();
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return 0;
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
  }

  // add bug #4624 修正 chen start
  /**
   * 施設設定Daoインターフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add bug #4624 修正 chen end

	/**
	 * MongoDBに存在する情報を検索
	 */
	@Override
	public List<IndSearchResult> searchByFilter(IndicationSearch params) {

		Query query = new Query();
		query.with(Sort.by(Sort.Direction.ASC, "pat_id"));
		// 抽出条件に治療予定日が指定されている場合、ord_mainから治療予定日、クール、ベッドに一致する患者idのリストを取得する
		if (!Strings.isNullOrEmpty(params.getTreatmentScheduledDate())) {
			List<String> listExpPatId = ordMainDao.selectPatIdByTreatDate(params.getTreatmentScheduledDate(), params.getKurCode(), params.getBedGroup());
  			if (listExpPatId.isEmpty()) {
  			  // 治療予定日、クールに一致する患者が0件の場合
  			  return Collections.emptyList();
  			} else {
  			  // 治療予定日、クールに一致する患者が存在する場合
  			  // mongodbから患者リストを取得する際は、ord_mainから取得した患者idに一致するリストを取得する
  			  query.addCriteria(Criteria.where("pat_id").in(listExpPatId));
  			}
		}
		if (!Strings.isNullOrEmpty(params.getFacilityCd())) {
			query.addCriteria(Criteria.where("facility_cd").is(params.getFacilityCd()));
		}
		if (!Strings.isNullOrEmpty(params.getTreatmentStartDate())) {
			// 指示発行日・指示開始日デートピッカーの対象切替
			if (LOG_DATE == params.getTreatmentDateOpt()) {
				// 指示発行日を選択
        //mod #11580 指示受け・指示承認の指示単位の複数患者一覧画面が表示まで遅い zrx start
//				query.addCriteria(Criteria.where("log_date").regex("^" + params.getTreatmentStartDate()));
        query.addCriteria(Criteria.where("log_date")
          .gte(params.getTreatmentStartDate() + "000000000")
          .lt(params.getTreatmentStartDate() + "999999999"));
        //mod #11580 指示受け・指示承認の指示単位の複数患者一覧画面が表示まで遅い zrx end
			} else {
				// 指示開始日デートピッカーを選択
        //mod #11580 指示受け・指示承認の指示単位の複数患者一覧画面が表示まで遅い zrx start
//				query.addCriteria(Criteria.where("treatment_start_date").regex("^" + params.getTreatmentStartDate()));
        query.addCriteria(Criteria.where("treatment_start_date")
          .gte(params.getTreatmentStartDate())
          .lt(String.valueOf(Integer.parseInt(params.getTreatmentStartDate()) + 1))
        );

        //mod #11580 指示受け・指示承認の指示単位の複数患者一覧画面が表示まで遅い zrx end
			}
		}
		// チェック1ラジオボタン
		// すべて：条件に入れない
		// 未：mongodbのチェック1が未登録のもの
		// 済：mongodbのチェック1が登録済みのも
		switch (params.getCheck1()) {
		case AdminWebConstant.IndHistory.NOTYET:
			query.addCriteria(Criteria.where("receiver_1").is(null));
			break;
		case AdminWebConstant.IndHistory.ALREADY:
			query.addCriteria(Criteria.where("receiver_1").ne(null));
			break;
		default:
			break;
		}
		// チェック2ラジオボタン
		// すべて：条件に入れない
		// 未：mongodbのチェック2が未登録のもの
		// 済：mongodbのチェック2が登録済みのも
		switch (params.getCheck2()) {
		case AdminWebConstant.IndHistory.NOTYET:
			query.addCriteria(Criteria.where("receiver_2").is(null));
			break;
		case AdminWebConstant.IndHistory.ALREADY:
			query.addCriteria(Criteria.where("receiver_2").ne(null));
			break;
		default:
			break;
		}
		// 承認1ラジオボタン
		// すべて：条件に入れない
		// 未：mongodbの承認1が未登録のもの
		// 済：mongodbの承認1が登録済みのも
		switch (params.getApprover1()) {
		case AdminWebConstant.IndHistory.NOTYET:
			query.addCriteria(Criteria.where("approver_1").is(null));
			break;
		case AdminWebConstant.IndHistory.ALREADY:
			query.addCriteria(Criteria.where("approver_1").ne(null));
			break;
		default:
			break;
		}
		// 承認1ラジオボタン
		// すべて：条件に入れない
		// 未：mongodbの承認2が未登録のもの
		// 済：mongodbの承認2が登録済みのも
		switch (params.getApprover2()) {
		case AdminWebConstant.IndHistory.NOTYET:
			query.addCriteria(Criteria.where("approver_2").is(null));
			break;
		case AdminWebConstant.IndHistory.ALREADY:
			query.addCriteria(Criteria.where("approver_2").ne(null));
			break;
		default:
			break;
		}
		// 指示者プルダウンリスト
		if (!Strings.isNullOrEmpty(params.getCreatedBy())) {
			query.addCriteria(Criteria.where("created_by").is(params.getCreatedBy()));
		}
		// 対象指示
		// すべてチェックボックス：条件に入れない、マルチ選択非活性
		// マルチ選択：指定されている指示対象をmongodbの対象からすべてを取得。
		if (params.getIndicationTarget() != null && params.getIndicationTarget().getIndicationList() != null
				&& !params.getIndicationTarget().getIndicationList().isEmpty()
				&& !params.getIndicationTarget().isIndication()) {
			query.addCriteria(Criteria.where("log_target").in(params.getIndicationTarget().getIndicationList()));
		}

    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    List<IndHistory> listIndHistory = new ArrayList<>();
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        // Find data in MongoDB
        listIndHistory = mongoTemplate.find(query, IndHistory.class);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (params != null && !StringUtils.isEmpty(params.getFacilityCd())) {
            eventLogMessage.setFacilityCd(params.getFacilityCd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
    // add bug #4624 修正 chen start
    final FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(params.getFacilityCd(), "1022");
    String setValue = "0";
    if (settingValue != null) {
      setValue = settingValue.getValue();
    }
    if ("0".equals(setValue)) {
      List<IndHistory> listIndHistoryTmp = new ArrayList<IndHistory>();
      for (IndHistory ind : listIndHistory) {
        if ("ベッド".equals(ind.getLogTarget()) || "クール".equals(ind.getLogTarget())) {
          if ("新規".equals(ind.getLogClass())) {
            listIndHistoryTmp.add(ind);
          }
        } else {
          listIndHistoryTmp.add(ind);
        }
      }
      listIndHistory = listIndHistoryTmp;
    }
    // add bug #4624 修正 chen end
		List<IndSearchResult> results = convertToExpectResult(listIndHistory);
		if(results.isEmpty()) {
			return results;
		}
		List<Long> patIdList = new ArrayList<>();
		for (IndSearchResult result : results) {
			Long patId = Long.valueOf(result.getPatId());
			patIdList.add(patId);
		}
		// Postgreで患者名を取得
		List<PatNameId> patInfo = patPersonalMainDao.selectPatNameById(patIdList);

		//　IndHistoryExtendに変換する
		Map<Long, PatNameId> mapPatId = new HashMap<>();
		for (PatNameId patNameId : patInfo) {
			mapPatId.put(patNameId.getPat_id(), patNameId);
		}

		for (IndSearchResult result : results) {
			PatNameId patNameId = mapPatId.get(Long.valueOf(result.getPatId()));
			String patName = EMPTY;
			String patNameKana = EMPTY;
			String hospPatId = EMPTY;
			if (patNameId != null) {
				patName = (Strings.nullToEmpty(patNameId.getPat_last_name()) + " "
						+ Strings.nullToEmpty(patNameId.getPat_first_name())).trim();
				patNameKana = (Strings.nullToEmpty(patNameId.getPat_last_name_kana()) + " "
						+ Strings.nullToEmpty(patNameId.getPat_first_name_kana())).trim();

				hospPatId = patNameId.getHosp_pat_id();
			}
			result.setPatName(patName);
			result.setPatNameKana(patNameKana);
			result.setHospPatId(hospPatId);
		}
		return results;
	}

	/**
	 * check1,2 approve1,2をカウント
	 *
	 * @param listIndHistory
	 * @return
	 */
	private List<IndSearchResult> convertToExpectResult(List<IndHistory> listIndHistory) {

		List<IndSearchResult> results = new ArrayList<>();
		if (listIndHistory == null || listIndHistory.isEmpty()) {
			return results;
		}
		List<Long> patIdList = new ArrayList<>();

		String patId = null;
		int total = 0;
		int check1 = 0;
		int check2 = 0;
		int approver1 = 0;
		int approver2 = 0;
    // add 7570 ind_dial連携で送信する項目情報部  赵 start
//    String oldOrdNo = "";
//    String newOrdNo = "";
    List<String> ordNoList = new ArrayList<>();
    // add 7570 ind_dial連携で送信する項目情報部  赵 end
		List<String> _ids = new ArrayList<>();
		for (int i = 0; i < listIndHistory.size(); i++) {
			IndHistory indHistoryCur = listIndHistory.get(i);
			// 一番目項目
			if (i == 0) {
				// 一覧が一つ項目だけ
				if (listIndHistory.size() == 1) {
					IndSearchResult result = new IndSearchResult();
          // add 7570 ind_dial連携で送信する項目情報部  赵 start
          //result.setOrdNo(indHistoryCur.getOrdNo());
          // add 7570 ind_dial連携で送信する項目情報部  赵 end
					result.setPatId(indHistoryCur.getPatId());
					if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver1())) {
						result.setCheck1(1);
					}
					if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver2())) {
						result.setCheck2(1);
					}
					if (!Strings.isNullOrEmpty(indHistoryCur.getApprover1())) {
						result.setApprover1(1);
					}
					if (!Strings.isNullOrEmpty(indHistoryCur.getApprover2())) {
						result.setApprover2(1);
					}
					_ids.add(indHistoryCur.get_id());
					result.set_id(_ids);
					result.setTotal(1);
					results.add(result);
					if (!patIdList.contains(Long.valueOf(indHistoryCur.getPatId()))) {
						patIdList.add(Long.valueOf(indHistoryCur.getPatId()));
					}
				} else {
					// 一覧は一つより項目
					patId = indHistoryCur.getPatId();
          // add 7570 ind_dial連携で送信する項目情報部  赵 start
					//ordNoList.add(indHistoryCur.getOrdNo());
          // add 7570 ind_dial連携で送信する項目情報部  赵 end
					total++;
					if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver1())) {
						check1++;
					}
					if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver2())) {
						check2++;
					}
					if (!Strings.isNullOrEmpty(indHistoryCur.getApprover1())) {
						approver1++;
					}
					if (!Strings.isNullOrEmpty(indHistoryCur.getApprover2())) {
						approver2++;
					}
					_ids.add(indHistoryCur.get_id());
				}

			} else if (indHistoryCur.getPatId().equals(patId)) {
        // add 7570 ind_dial連携で送信する項目情報部  赵 start
//        if (!indHistoryCur.getOrdNo().equals(oldOrdNo)) {
//          if (!ordNoList.contains(indHistoryCur.getOrdNo())) {
//            ordNoList.add(indHistoryCur.getOrdNo());
//          }
//        }
//        newOrdNo = org.apache.commons.lang3.StringUtils.join(ordNoList, ",");
        // add 7570 ind_dial連携で送信する項目情報部  赵 start
				// 現行項目と前項目の患者IDは一緒です。
				total++;
				_ids.add(indHistoryCur.get_id());
				if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver1())) {
					check1++;
				}
				if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver2())) {
					check2++;
				}
				if (!Strings.isNullOrEmpty(indHistoryCur.getApprover1())) {
					approver1++;
				}
				if (!Strings.isNullOrEmpty(indHistoryCur.getApprover2())) {
					approver2++;
				}
				// 現行項目は一覧の最後項目です。
				if (i == listIndHistory.size() - 1) {
					IndSearchResult result = new IndSearchResult();
          // add 7570 ind_dial連携で送信する項目情報部  赵 start
          //result.setOrdNo(newOrdNo);
          // add 7570 ind_dial連携で送信する項目情報部  赵 end
					result.setPatId(indHistoryCur.getPatId());
					result.setCheck1(check1);
					result.setCheck2(check2);
					result.setApprover1(approver1);
					result.setApprover2(approver2);
					result.setTotal(total);
					result.set_id(_ids);
					results.add(result);
				}
			} else {
				// 現行項目と前項目の患者IDは一緒じゃない。
				IndSearchResult result = new IndSearchResult();
				IndHistory indHistoryPre = listIndHistory.get(i - 1);
				result.setPatId(indHistoryPre.getPatId());
				result.setCheck1(check1);
				result.setCheck2(check2);
				result.setApprover1(approver1);
				result.setApprover2(approver2);
				result.setTotal(total);
				patId = indHistoryCur.getPatId();
				result.set_id(_ids);
        // add 7570 ind_dial連携で送信する項目情報部  赵 start
        //result.setOrdNo(newOrdNo);
        // add 7570 ind_dial連携で送信する項目情報部  赵 end
				results.add(result);
				// reset
        // add 7570 ind_dial連携で送信する項目情報部  赵 start
//        ordNoList = new ArrayList<>();
//        ordNoList.add(listIndHistory.get(i).getOrdNo());
//        newOrdNo = "";
        // add 7570 ind_dial連携で送信する項目情報部  赵 end
				total = 0;
				check1 = 0;
				check2 = 0;
				approver1 = 0;
				approver2 = 0;
				_ids = new ArrayList<>();
				_ids.add(indHistoryCur.get_id());
				total++;
				if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver1())) {
					check1++;
				}
				if (!Strings.isNullOrEmpty(indHistoryCur.getReceiver2())) {
					check2++;
				}
				if (!Strings.isNullOrEmpty(indHistoryCur.getApprover1())) {
					approver1++;
				}
				if (!Strings.isNullOrEmpty(indHistoryCur.getApprover2())) {
					approver2++;
				}
				// 現行項目は一覧の最後項目です。
				if (i == listIndHistory.size() - 1) {
					result = new IndSearchResult();
          // add 7570 ind_dial連携で送信する項目情報部  赵 start
          //result.setOrdNo(indHistoryCur.getOrdNo());
          // add 7570 ind_dial連携で送信する項目情報部  赵 end
					result.setPatId(indHistoryCur.getPatId());
					result.setCheck1(check1);
					result.setCheck2(check2);
					result.setApprover1(approver1);
					result.setApprover2(approver2);
					result.setTotal(total);
					result.set_id(_ids);
					results.add(result);
				}
			}
      // add 7570 ind_dial連携で送信する項目情報部  赵 start
      //oldOrdNo = indHistoryCur.getOrdNo();
      // add 7570 ind_dial連携で送信する項目情報部  赵 end
		}

		return results;
	}

	@Override
	public List<IndHistory> getIndHistoryDetail(List<String> params) {

		Query query = new Query();
		List<Order> orders = new ArrayList<>();
		Order sortLogDate = new Order(Sort.Direction.ASC, "log_date");
		Order sortStartDate = new Order(Sort.Direction.ASC, "treatment_start_date");
		orders.add(sortLogDate);
		orders.add(sortStartDate);
		query.with(Sort.by(orders));
		/* modify by chamaojia 2023-07-08 指示受け画面：指示単位表示の場合、指示受け画面内容は表示されません  --start */
//		query.addCriteria(Criteria.where("_id").in(params));
		// 元のクエリー方式ではデータをクエリーできず、新しい方法に変更されました
		ObjectId[] ids = new ObjectId[params.size()];
		for(int i = 0; i < params.size(); i++)
		{
			ids[i] = new ObjectId(params.get(i));
		}
		query.addCriteria(Criteria.where("_id").in(ids));
		/* modify by chamaojia 2023-07-08 指示受け画面：指示単位表示の場合、指示受け画面内容は表示されません  --end */
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        return mongoTemplate.find(query, IndHistory.class);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return new ArrayList<>();
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
	}

	/**
	 * MongoDBで指示の受け者又は承認者にユーザーIDを更新する
	 */
	@Override
  @Transactional
	public boolean updateIndHistoryInListScreen(IndListUpdateCondition params) {

		boolean result = true;
		Update update = new Update();

		String keyColumn = "";
		switch (params.getIndicationType()) {
		case AdminWebConstant.IndHistory.RECEIVER_1:
			update.set("receiver_1", params.getUserId());
			keyColumn = "receiver_1";
			break;
		case AdminWebConstant.IndHistory.RECEIVER_2:
			update.set("receiver_2", params.getUserId());
			keyColumn = "receiver_2";
			break;
		case AdminWebConstant.IndHistory.APPROVER_1:
			update.set("approver_1", params.getUserId());
			keyColumn = "approver_1";
			break;
		case AdminWebConstant.IndHistory.APPROVER_2:
			update.set("approver_2", params.getUserId());
			keyColumn = "approver_2";
			break;
		default:
			break;
		}
		Query query = new Query();
		/* modify by chamaojia 2023-07-08 指示受け画面：指示単位表示の場合、指示受け画面内容は表示されません  --start */
//		query.addCriteria(Criteria.where("_id").in(params.get_ids()));
		// 元のクエリー方式ではデータをクエリーできず、新しい方法に変更されました
		ObjectId[] ids = new ObjectId[params.get_ids().size()];
		for(int i = 0; i < params.get_ids().size(); i++)
		{
			ids[i] = new ObjectId(params.get_ids().get(i));
		}
		query.addCriteria(Criteria.where("_id").in(ids));
		/* modify by chamaojia 2023-07-08 指示受け画面：指示単位表示の場合、指示受け画面内容は表示されません  --end */
		query.addCriteria(Criteria.where(keyColumn).in(null, EMPTY));
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        UpdateResult updateResult = mongoTemplate.updateMulti(query, update, IndHistory.class);
        if (!(updateResult.getModifiedCount() > 0)) {  // modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17
          result = false;
        }
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (params != null && !StringUtils.isEmpty(params.getFacility_cd())) {
            eventLogMessage.setFacilityCd(params.getFacility_cd());
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
		return result;
	}

	/**
	 * 指示詳細画面で受け者又は承認者に更新する
	 */
	@Override
  @Transactional
	public boolean updateIndHistoryInDetailScreen(List<IndDetailUpdateCondition> params) {
		Update update;
		Query query;
		boolean result = true;
		/*del #9506 横展開対応、dengjunyi start*/
		/* upd EOL対応内部 #7010 by ztc 2023-07-10 --start */
		//String keyColumn = "";
		for (IndDetailUpdateCondition item : params) {
			update = new Update();
			switch (item.getIndicationType()) {
			case AdminWebConstant.IndHistory.RECEIVER_1:
				update.set("receiver_1", item.getUserId());
				//keyColumn = "receiver_1";
				break;
			case AdminWebConstant.IndHistory.RECEIVER_2:
				update.set("receiver_2", item.getUserId());
				//keyColumn = "receiver_2";
				break;
			case AdminWebConstant.IndHistory.APPROVER_1:
				update.set("approver_1", item.getUserId());
				//keyColumn = "approver_1";
				break;
			case AdminWebConstant.IndHistory.APPROVER_2:
				update.set("approver_2", item.getUserId());
				//keyColumn = "approver_2";
				break;
			default:
				break;
			}
			query = new Query();
			/* modify by chamaojia 2023-07-08 指示受け画面：指示単位表示の場合、指示受け画面内容は表示されません  --start */
//			query.addCriteria(Criteria.where("_id").is(item.get_id()));
			// 元のクエリー方式ではデータをクエリーできず、新しい方法に変更されました
			query.addCriteria(Criteria.where("_id").in(new ObjectId(item.get_id())));
			//query.addCriteria(Criteria.where(keyColumn).in(null, EMPTY));
			/*del #9506 横展開対応、dengjunyi end*/
			/* modify by chamaojia 2023-07-08 指示受け画面：指示単位表示の場合、指示受け画面内容は表示されません  --end */
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
          UpdateResult updateResult = mongoTemplate.updateMulti(query, update, IndHistory.class);
          if (!(updateResult.getModifiedCount() > 0)) {  // modify by shiyw 2023-04-10 [#8271] jdk8->aws jdk17
            result = false;
          }
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
		}
		/* upd EOL対応内部 #7010 by ztc 2023-07-10 --start */
		return result;
	}
}
