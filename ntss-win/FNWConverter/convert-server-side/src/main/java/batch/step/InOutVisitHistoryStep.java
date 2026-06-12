package batch.step;

import batch.ApplicationConst;
import batch.entity.InOutVisitHistoryInfoEntity;
import batch.mapper.PatIoVisitHistoryRowMapper;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.StepContribution;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.constant.CommonConstants;
import web.logger.EventLogMessage;
import web.logger.LogLevel;
import javax.sql.DataSource;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
/**
 *入外区分の変換手順
 */
// add #11357 【たくしん会】患者の入外区分が「－」でコンバートされる houyulong start
@Component
public class InOutVisitHistoryStep implements Tasklet {

    public   static  final  String STEP_NAME ="InOutVisitHistoryStep";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");
    @Autowired
    Utils utils;
    @Autowired
    private JobRepository jobRepository;
    @Autowired
    private EventLoggerUtil eventLoggerUtil;
    @Autowired
    private ApplicationContext appContext;


    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {
        // 施設コードを取得
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.FACILITY_CD).toString();
        DataSource machineDsNkk5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        JdbcTemplate jdbc5 = new JdbcTemplate(machineDsNkk5);
        try {
            String selectPatIOSql = "SELECT pat_id, in_out_visit_history_info " +
                    "FROM pat_unique " +
                    "WHERE facility_cd = ? " +
                    "AND is_del = '0'";

            List<Map.Entry<String, List<InOutVisitHistoryInfoEntity>>> entries = jdbc5.query(
                    selectPatIOSql,
                    new Object[]{facilityCd},
                    new PatIoVisitHistoryRowMapper()
            );

            Map<String, List<InOutVisitHistoryInfoEntity>> resultMap = Optional.ofNullable(entries).orElse(Collections.emptyList()).stream()
                    .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));

            String today = LocalDate.now().format(DATE_FORMATTER);

            for (Map.Entry<String, List<InOutVisitHistoryInfoEntity>> entry : resultMap.entrySet()) {
                processEntry(facilityCd, entry.getKey(), entry.getValue(), today);
            }

        } catch (Exception e) {

            eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage(Arrays.toString(e.getStackTrace()),
                    facilityCd, " pat-in_out-info 更新失敗"), LogLevel.ERROR);
        }
        return RepeatStatus.FINISHED;
    }

    public void processEntry(String facilityCd, String patId, List<InOutVisitHistoryInfoEntity> list, String today) {
        if (list == null || list.isEmpty()) return;

        // today を LocalDate オブジェクトに変換して比較できるようにする
        LocalDate todayDate = LocalDate.parse(today, DATE_FORMATTER);

        Optional<InOutVisitHistoryInfoEntity> beforeTodayMaxCtlNo = findBeforeTodayMaxCtlNo(list, todayDate);
        Optional<InOutVisitHistoryInfoEntity> todayEnabledCtlNo = findTodayEnabledMaxCtlNo(list, todayDate);
        Optional<InOutVisitHistoryInfoEntity> todayMaxCtlNo = findTodayMaxCtlNo(list, todayDate);
        Optional<InOutVisitHistoryInfoEntity> afterTodayMinCtlNo = findAfterTodayMinCtlNo(list, todayDate);

        StateHolder stateHolder = createInitialStateHolder();

        applyBeforeTodayEntityToState(beforeTodayMaxCtlNo, stateHolder);
        applyTodayEnabledEntityToState(todayEnabledCtlNo, stateHolder);
        applyTodayMaxEntityToState(todayMaxCtlNo, stateHolder);
        applyAfterTodayEntityToState(afterTodayMinCtlNo, stateHolder);

        updatePatInfo(facilityCd, patId, stateHolder);
    }

    /**
     * 当日より前の期間開始日を持つ履歴のうち、期間開始日・ctl_no が最大のエンティティを取得する
     */
    private Optional<InOutVisitHistoryInfoEntity> findBeforeTodayMaxCtlNo(
            List<InOutVisitHistoryInfoEntity> list, LocalDate todayDate) {
        return list.stream()
                .filter(e -> {
                    LocalDate periodStartDate = e.getPeriodStartDate();
                    return periodStartDate != null && periodStartDate.isBefore(todayDate);
                })
                .reduce((a, b) -> {
                    LocalDate aDate = a.getPeriodStartDate();
                    LocalDate bDate = b.getPeriodStartDate();
                    // まず日付で比較する
                    int dateComparison = aDate.compareTo(bDate);

                    if (dateComparison != 0) {
                        return dateComparison > 0 ? a : b;
                    } else {
                        // 日付が同じ場合は、ctl_no で比較する
                        // null を最小値として扱い、一方が null の場合、その値はもう一方より小さいと見なす
                        Comparator<InOutVisitHistoryInfoEntity> ctlNoComparator =
                                Comparator.comparing(InOutVisitHistoryInfoEntity::getCtl_no,
                                        Comparator.nullsFirst(Comparator.naturalOrder()));

                        return ctlNoComparator.compare(a, b) > 0 ? a : b;
                    }
                });
    }

    /**
     * 当日の期間開始日かつ有効な移動区分を持つ履歴のうち、ctl_no が最大のエンティティを取得する
     */
    private Optional<InOutVisitHistoryInfoEntity> findTodayEnabledMaxCtlNo(
            List<InOutVisitHistoryInfoEntity> list, LocalDate todayDate) {
        return list.stream()
                .filter(e -> {
                    LocalDate periodStartDate = e.getPeriodStartDate();
                    String moveInOut = e.getMove_in_out();

                    boolean isEnabled = switch (moveInOut) {
                        case CommonConstants.STRING_THREE,
                             CommonConstants.STRING_SEVEN,
                             CommonConstants.STRING_EIGHT,
                             CommonConstants.STRING_NINE -> false;
                        default -> true;
                    };

                    return periodStartDate != null && periodStartDate.isEqual(todayDate) && isEnabled;
                })
                .reduce((a, b) -> {
                    // ctl_no で比較する
                    // null を最小値として扱い、一方が null の場合、その値はもう一方より小さいと見なす
                    Comparator<InOutVisitHistoryInfoEntity> ctlNoComparator =
                            Comparator.comparing(InOutVisitHistoryInfoEntity::getCtl_no,
                                    Comparator.nullsFirst(Comparator.naturalOrder()));

                    return ctlNoComparator.compare(a, b) > 0 ? a : b;
                });
    }

    /**
     * 当日の期間開始日を持つ履歴のうち、ctl_no が最大のエンティティを取得する
     */
    private Optional<InOutVisitHistoryInfoEntity> findTodayMaxCtlNo(
            List<InOutVisitHistoryInfoEntity> list, LocalDate todayDate) {
        return list.stream()
                .filter(e -> {
                    LocalDate periodStartDate = e.getPeriodStartDate();
                    return periodStartDate != null && periodStartDate.isEqual(todayDate);
                })
                .reduce((a, b) -> {
                    // ctl_no で比較する
                    // null を最小値として扱い、一方が null の場合、その値はもう一方より小さいと見なす
                    Comparator<InOutVisitHistoryInfoEntity> ctlNoComparator =
                            Comparator.comparing(InOutVisitHistoryInfoEntity::getCtl_no,
                                    Comparator.nullsFirst(Comparator.naturalOrder()));

                    return ctlNoComparator.compare(a, b) > 0 ? a : b;
                });
    }

    /**
     * 当日より後の期間開始日を持つ履歴のうち、期間開始日・ctl_no が最小のエンティティを取得する
     */
    private Optional<InOutVisitHistoryInfoEntity> findAfterTodayMinCtlNo(
            List<InOutVisitHistoryInfoEntity> list, LocalDate todayDate) {
        return list.stream()
                .filter(e -> {
                    LocalDate periodStartDate = e.getPeriodStartDate();
                    return periodStartDate != null && periodStartDate.isAfter(todayDate);
                })
                .reduce((a, b) -> {
                    LocalDate aDate = a.getPeriodStartDate();
                    LocalDate bDate = b.getPeriodStartDate();
                    // まず日付で比較する
                    int dateComparison = aDate.compareTo(bDate);

                    if (dateComparison != 0) {
                        // 最小の日付を取る
                        return dateComparison < 0 ? a : b;
                    } else {
                        // 日付が同じ場合は、ctl_no で比較する
                        // null を最大値として扱い、一方が null の場合、その値はもう一方より大きいと見なす
                        Comparator<InOutVisitHistoryInfoEntity> ctlNoComparator =
                                Comparator.comparing(InOutVisitHistoryInfoEntity::getCtl_no,
                                        Comparator.nullsLast(Comparator.naturalOrder()));

                        return ctlNoComparator.compare(a, b) < 0 ? a : b;
                    }
                });
    }

    /**
     * 入外状態を保持するオブジェクトを初期化して返す
     */
    private StateHolder createInitialStateHolder() {
        StateHolder stateHolder = new StateHolder();
        stateHolder.inOutCurrentState = null;
        stateHolder.inOutPlanState = null;
        stateHolder.inOutPlanDate = null;
        return stateHolder;
    }

    /**
     * 当日より前の履歴エンティティから入外現状態を設定する
     */
    private void applyBeforeTodayEntityToState(
            Optional<InOutVisitHistoryInfoEntity> beforeTodayMaxCtlNo, StateHolder stateHolder) {
        beforeTodayMaxCtlNo.ifPresent(entity -> {
            if (CommonConstants.STRING_THREE.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_SEVEN.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_EIGHT.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_NINE.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_TEN.equals(entity.getMove_in_out())) {
                stateHolder.inOutCurrentState = entity.getMove_in_out();
            } else {
                stateHolder.inOutCurrentState = CommonConstants.STRING_ZERO;
            }
        });
    }

    /**
     * 当日有効な履歴エンティティから入外現状態・予定状態を設定する
     */
    private void applyTodayEnabledEntityToState(
            Optional<InOutVisitHistoryInfoEntity> todayEnabledCtlNo, StateHolder stateHolder) {
        todayEnabledCtlNo.ifPresent(entity -> {
            if (CommonConstants.STRING_THREE.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_SEVEN.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_EIGHT.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_NINE.equals(entity.getMove_in_out())) {
                stateHolder.inOutPlanState = entity.getMove_in_out();
                stateHolder.inOutPlanDate = LocalDate.parse(entity.getPeriod_start_date(), DATE_FORMATTER);
            } else if (CommonConstants.STRING_TEN.equals(entity.getMove_in_out())){
                stateHolder.inOutCurrentState = CommonConstants.STRING_TEN;
            } else {
                stateHolder.inOutCurrentState = CommonConstants.STRING_ZERO;
            }
        });
    }

    /**
     * 当日最大 ctl_no の履歴エンティティから入外現状態・予定状態を設定する
     */
    private void applyTodayMaxEntityToState(
            Optional<InOutVisitHistoryInfoEntity> todayMaxCtlNo, StateHolder stateHolder) {
        todayMaxCtlNo.ifPresent(entity -> {
            if (CommonConstants.STRING_THREE.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_SEVEN.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_EIGHT.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_NINE.equals(entity.getMove_in_out())) {
                stateHolder.inOutPlanState = entity.getMove_in_out();
                stateHolder.inOutPlanDate = LocalDate.parse(entity.getPeriod_start_date(), DATE_FORMATTER);
            } else if (CommonConstants.STRING_TEN.equals(entity.getMove_in_out())){
                stateHolder.inOutCurrentState = CommonConstants.STRING_TEN;
            } else {
                stateHolder.inOutCurrentState = CommonConstants.STRING_ZERO;
            }
        });
    }

    /**
     * 当日より後の履歴エンティティから入外現状態・予定状態・予定日を設定する
     */
    private void applyAfterTodayEntityToState(
            Optional<InOutVisitHistoryInfoEntity> afterTodayMinCtlNo, StateHolder stateHolder) {
        afterTodayMinCtlNo.ifPresent(entity -> {
            if (CommonConstants.STRING_ONE.equals(entity.getMove_in_out())
                    || CommonConstants.STRING_TWO.equals(entity.getMove_in_out()))  {
                stateHolder.inOutCurrentState = entity.getMove_in_out();

                stateHolder.inOutPlanState = Objects.requireNonNullElse(
                        stateHolder.inOutPlanState,
                        CommonConstants.STRING_ZERO);
            } else {
                if (CommonConstants.STRING_FOUR.equals(entity.getMove_in_out())
                        || CommonConstants.STRING_FIVE.equals(entity.getMove_in_out())
                        || CommonConstants.STRING_SIX.equals(entity.getMove_in_out())){

                    stateHolder.inOutPlanState = Objects.requireNonNullElse(
                            stateHolder.inOutPlanState,
                            CommonConstants.STRING_ZERO);
                }else {
                    stateHolder.inOutPlanState = Objects.requireNonNullElse(
                            stateHolder.inOutPlanState,
                            entity.getMove_in_out());
                }
            }

            stateHolder.inOutPlanDate = Objects.requireNonNullElse(
                    stateHolder.inOutPlanDate,
                    LocalDate.parse(entity.getPeriod_start_date(), DATE_FORMATTER));
        });
    }

    private void updatePatInfo(String facilityCd, String patIdStr, StateHolder stateHolder) {

        DataSource dataSource5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);

        EventLogMessage eventLogMessage = new EventLogMessage();

        Integer patId = Optional.ofNullable(patIdStr)
                .map(Integer::parseInt)
                .orElse(null);

        try {
            JdbcTemplate jdbc5 = new JdbcTemplate(dataSource5);
            String updatePatMainSql = "UPDATE pat_main" +
                    " SET in_out_current_state = ?," +
                    " in_out_plan_state = ?," +
                    " in_out_plan_date = ?" +
                    " WHERE pat_id = ? AND facility_cd = ?";

            int rowsAffected5 = jdbc5.update(updatePatMainSql, stateHolder.inOutCurrentState,
                    stateHolder.inOutPlanState,
                    stateHolder.inOutPlanDate,
                    patId,
                    facilityCd);

            if (rowsAffected5 == CommonConstants.NUMBER_ZERO) {
                eventLogMessage = eventLoggerUtil.getEventLogMessage("NKK5.pat_main in_out_current_state, " +
                                "in_out_plan_state," +
                                "in_out_plan_date 本患者の情報は更新されていません。",
                        facilityCd, "InOutVisitHistoryStep.updatePatInfo: PatId:" + patId);
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.WARN);
            }
        } catch (Exception e) {
            eventLogMessage = eventLoggerUtil.getEventLogMessage(e.getMessage(),
                    facilityCd, "InOutVisitHistoryStep.updatePatInfo: PatId:" + patId);
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
        }
    }


    private static class StateHolder {
        String inOutCurrentState;
        String inOutPlanState;
        LocalDate inOutPlanDate;
    }

 @Bean(name = STEP_NAME)
   public Step step(){
     return new StepBuilder(STEP_NAME, jobRepository).tasklet(this).build();
 }
}
// add #11357 【たくしん会】患者の入外区分が「－」でコンバートされる houyulong end