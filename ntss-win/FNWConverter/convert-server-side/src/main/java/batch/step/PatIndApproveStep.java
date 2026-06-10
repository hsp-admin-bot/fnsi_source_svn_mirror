package batch.step;

import batch.ApplicationConst;
import batch.listener.JobStartEndLIstener;
import batch.part.ProgressManagement;
import batch.part.StreamThread;
import batch.part.TableNameToDbType;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.support.TransactionTemplate;
import utils.GlobalContext;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;
import javax.sql.DataSource;

/**
 * pat_ind_approve
 */
@Component
public class PatIndApproveStep  implements Tasklet {

    public static final String STEP_NAME = "PatIndApproveStep";
    @Autowired
    private StepBuilderFactory stepBuilderFactory;
    @Autowired
    ProgressManagement progressManagement;
    @Autowired
    private EventLoggerUtil eventLoggerUtil;
    @Autowired
    private ApplicationContext appContext;
    @Autowired
    private Environment environment;
    @Autowired
    private PlatformTransactionManager transactionManager;

    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {
        String facilityCd = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobParameters().getString(ApplicationConst.JobParameterKeys.FACILITY_CD);
        String inputFilePath = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobParameters().getString(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH);
        TransactionTemplate template = new TransactionTemplate(transactionManager);
        template.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);

        DataSource machineDsConvert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbccon = new JdbcTemplate(machineDsConvert);
        try {
            progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(), "pat_ind_approve 処理 開始 0%");

            delConvPatIndApprove(template, jdbccon, facilityCd);

            int count = insertConvPatIndApprove(template, jdbccon, facilityCd);

            if (count > 0) {
                template.execute(status -> {
                    try {
                        addPatIndDpprove(facilityCd);
                    } catch (Exception e) {
                        throw new RuntimeException("addPatIndDpprove:", e);
                    }
                    return null;
                });

                template.execute(status -> {
                    try {
                        copyPatIndApprove(inputFilePath,false, facilityCd);
                    } catch (Exception e) {
                        throw new RuntimeException("copyPatIndApprove:", e);
                    }
                    return null;
                });
            }
            delConvPatIndApprove(template, jdbccon, facilityCd);
            int count_update = updateConvPatIndApprove(template, jdbccon, facilityCd);

            if (count_update > 0) {
                template.execute(status -> {
                    try {
                        updateContentForMapControl(facilityCd);
                    } catch (Exception e) {
                        throw new RuntimeException("addPatIndDpprove:", e);
                    }
                    return null;
                });

                template.execute(status -> {
                    try {
                        copyPatIndApprove(inputFilePath,true, facilityCd);
                    } catch (Exception e) {
                        throw new RuntimeException("copyPatIndApprove:", e);
                    }
                    return null;
                });
            }

            progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(), "pat_ind_approve 処理 終了100%:  処理 " + (count+count_update) + " 件");
        } catch (Exception e) {
            eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage(EventLoggerUtil.excetionStackTraceToString(e),
                    facilityCd, "PatIndApproveStep失敗"), LogLevel.ERROR);
        }
        return RepeatStatus.FINISHED;
    }

    private void delConvPatIndApprove(TransactionTemplate template, JdbcTemplate jdbccon, String facilityCd) {

        StringBuilder deleteSql = new StringBuilder();
        deleteSql.append("delete from convert_pat_ind_approve_ord_no where facility_cd= ?");

        template.execute(status -> {
            int resultCount = jdbccon.update(deleteSql.toString(), new Object[]{facilityCd});
            return resultCount;
        });
    }

    private int insertConvPatIndApprove(TransactionTemplate template, JdbcTemplate jdbccon, String facilityCd) {

        StringBuilder insertOrdNo = new StringBuilder();
        insertOrdNo.append("""
               insert into convert_pat_ind_approve_ord_no(ord_no,facility_cd)
               SELECT ord.ord_no, ord.facility_cd
               FROM ord_main ord
               left join pat_ind_approve pat
               on ord.ord_no = pat.ord_no and pat.facility_cd = ord.facility_cd
               where ord.ind_cond_info is not null and pat.ord_no IS NULL AND ord.facility_cd = ?
               """);

        return template.execute(status -> {
            int resultCount = jdbccon.update(insertOrdNo.toString(), new Object[]{facilityCd});
            return resultCount;
        });
    }

    private int updateConvPatIndApprove(TransactionTemplate template, JdbcTemplate jdbccon, String facilityCd) {

        StringBuilder insertOrdNo = new StringBuilder();
        insertOrdNo.append("""
               insert into convert_pat_ind_approve_ord_no(ord_no,facility_cd)
               SELECT ord.ord_no, ord.facility_cd
               FROM ord_main ord
               left join pat_ind_approve pat
               on ord.ord_no = pat.ord_no and pat.facility_cd = ord.facility_cd
               where ord.ind_cond_info is not null and ord.rst_dialysis_state='6' AND content_for_map IS NULL AND ord.facility_cd = ?
               """);

        return template.execute(status -> {
            int resultCount = jdbccon.update(insertOrdNo.toString(), new Object[]{facilityCd});
            return resultCount;
        });
    }

    private void addPatIndDpprove(String facilityCd) {

        EventLogMessage eventLogMessage = new EventLogMessage();
        try{
            DataSource convertDbDs = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            StringBuilder ind_Pat_Ind_Approve = new StringBuilder();
            ind_Pat_Ind_Approve.append("""
                           WITH medi_info AS (
                             SELECT
                               ord_no,
                               jsonb_agg(
                                jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                      'itemName', COALESCE(substring(json_data->>'name' FROM '】([^】]*)$'),json_data->>'name'),
                                      'itemNo', (json_data->>'no')::int,
                                      'itemCd', (json_data->>'cd')::int,
                                      'itemType', (json_data->>'medicine_type')::int,
                                      'date',jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(json_data->>'name' FROM '^(.*】)'),'dispVal', json_data->>'amount', 'unit', COALESCE(json_data->>'unit', null)),
                                        'updater', COALESCE(json_data->>'upd_user_last_name', '') || COALESCE(json_data->>'upd_user_first_name', ''),
                                        'instructor', COALESCE(json_data->>'ind_user_last_name', '') || COALESCE(json_data->>'ind_user_first_name', '')
                                      )
                                     )
                                )
                            ) AS medi_json
                             FROM
                               ord_main,
                               jsonb_array_elements(ind_medi_info) AS json_data
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                             GROUP BY
                               ord_no
                           ),
                           comment_info AS (
                             SELECT
                               ord_no,
                                jsonb_agg(
                                    jsonb_build_object(
                                       'itemInfo',jsonb_build_object(
                                           'itemName', 'コメント'||(comment_info->>'no')::text,
                                           'itemNo', (comment_info->>'no')::int,
                                           'itemCd',null,
                                           'itemType',null,
                                           'date', jsonb_build_object(
                                            'value', jsonb_build_object( 'unit', null,'prefix',null,'dispVal', comment_info->>'content'),
                                            'updater', COALESCE(comment_info->>'upd_user_last_name', '') || COALESCE(comment_info->>'upd_user_first_name', ''),
                                            'instructor', COALESCE(comment_info->>'ind_user_last_name', '') || COALESCE(comment_info->>'ind_user_first_name', '')
                                           )
                                          )
                                    )
                                ) AS comment_info_json
                             FROM
                               ord_main, 
                               jsonb_array_elements(ind_ind_comment_info) AS comment_info
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                             GROUP BY
                               ord_no
                           ),
                           equip_info AS (
                             SELECT
                               ord_no,
                               jsonb_agg(
                                 jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                        'itemName', COALESCE(substring(json_data->>'name' FROM '】([^】]*)$'),json_data->>'name'),
                                        'itemNo', null,
                                        'itemCd', (json_data->>'cd')::int,
                                        'itemType', (json_data->>'equip_type')::int,
                                        'date', jsonb_build_object(
                                          'value', jsonb_build_object('prefix',substring(json_data->>'name' FROM '^(.*】)'),'dispVal', json_data->>'amount', 'unit', COALESCE(json_data->>'unit', null)),
                                          'updater', COALESCE(json_data->>'upd_user_last_name', '') || COALESCE(json_data->>'upd_user_first_name', ''),
                                          'instructor', COALESCE(json_data->>'ind_user_last_name', '') || COALESCE(json_data->>'ind_user_first_name', '')
                                         )                             									
                                        )												
                                  ) 
                                ) AS equip_json
                             FROM
                               ord_main,
                               jsonb_array_elements(ind_equip_info) AS json_data
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                             GROUP BY
                               ord_no
                           ),
                           cond_info AS (
                             	 SELECT
                               ord_no,
                               jsonb_build_object(
                               'component', 'treat-cond',
                               'subCategoryNo', 4,
                               'subCategoryItem', json_build_array(
                               jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                     'itemName', '治療時間',
                                     'itemNo', 1,
                                     'itemCd',null,
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                          'value',jsonb_build_object('prefix',null,'dispVal',COALESCE (
                                                             RIGHT ( '00' || TRUNC( TO_NUMBER(ind_cond_info -> '1' ->> 'value', '999999' ) / 60, 0 ), 2 ) || ':' || RIGHT ( '00' || MOD ( TO_NUMBER( ind_cond_info -> '1' ->> 'value', '999999' ), 60 ), 2 ),
                                                             '未登録'
                                                           ), 'unit', null),
                                         'updater', COALESCE(ind_cond_info -> '1' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '1' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '1' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '1' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '1' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                       'itemInfo',jsonb_build_object(
                                           'itemName', 'VA',
                                           'itemNo', 2,
                                           'itemCd',(ind_cond_info -> '2' ->> 'value')::int,
                                           'itemType',null,
                                           'date', jsonb_build_object(
                                           'value',jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '2' ->> 'value_name_1','未登録' ),'unit', null),
                                             'updater', COALESCE(ind_cond_info -> '2' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '2' ->> 'upd_user_first_name','') ,
                                             'instructor', COALESCE(ind_cond_info -> '2' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '2' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '2' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                       )
                                 ), jsonb_build_object(
                                       'itemInfo',jsonb_build_object(
                                           'itemName', '目標体重',
                                           'itemNo', 3,
                                           'itemCd',null,
                                           'itemType',null,
                                           'date', jsonb_build_object(
                                             'value',jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '3' ->> 'value','未登録' ),'unit', COALESCE(ind_cond_info -> '3' ->> 'unit',null)),
                                             'updater', COALESCE(ind_cond_info -> '3' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'upd_user_first_name','') ,
                                             'instructor', COALESCE(ind_cond_info -> '3' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '3' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                      )
                                 ), jsonb_build_object(
                                     'itemInfo',jsonb_build_object(
                                         'itemName', '除水量制限',
                                         'itemNo', 4,
                                         'itemCd',null,
                                         'itemType',null,
                                         'date', jsonb_build_object(
                                             'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '4' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '4' ->> 'unit',null)),
                                             'updater', COALESCE(ind_cond_info -> '4' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'upd_user_first_name','') ,
                                             'instructor', COALESCE(ind_cond_info -> '4' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '4' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                          )
                                 ), jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                        'itemName', 'ダイアライザ',
                                        'itemNo', 5,
                                        'itemCd',(ind_cond_info -> '5' ->> 'value')::int,
                                        'itemType',null,
                                        'date', jsonb_build_object(
                                          'value',  jsonb_build_object('prefix',substring(ind_cond_info -> '5' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE('['||COALESCE(substring(ind_cond_info -> '5' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '5' ->> 'value_name_1')||']', '未登録'),'unit',COALESCE(ind_cond_info -> '5' ->> 'unit', null)),
                                          'updater', COALESCE(ind_cond_info -> '5' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '5' ->> 'upd_user_first_name','') ,
                                          'instructor', COALESCE(ind_cond_info -> '5' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '5' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '5' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object(
                                       'itemName', '吸着カラム',
                                       'itemNo', 6,
                                       'itemCd',(ind_cond_info -> '6' ->> 'value')::int,
                                       'itemType',null,
                                       'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '6' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '6' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '6' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '6' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '6' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '6' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '6' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '6' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '6' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )                              
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                       'itemName', '1次膜',
                                       'itemNo', 7,
                                       'itemCd',(ind_cond_info -> '7' ->> 'value')::int,
                                       'itemType',null,   
                                       'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '7' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '7' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '7' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '7' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '7' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '7' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '7' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '7' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '7' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                   )
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object( 
                                        'itemName', '2次膜',
                                        'itemNo', 8,
                                        'itemCd',(ind_cond_info -> '8' ->> 'value')::int,
                                        'itemType',null,
                                        'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '8' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '8' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '8' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '8' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '8' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '8' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '8' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '8' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '8' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                    )
                                 ), jsonb_build_object(
                                      'itemInfo',jsonb_build_object( 
                                      'itemName', '穿刺針(A針)',
                                      'itemNo', 9, 
                                      'itemCd',(ind_cond_info -> '9' ->> 'value')::int,  
                                      'itemType',null,  
                                      'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '9' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '9' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '9' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '9' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '9' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '9' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '9' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '9' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '12'->> 'value'::text='1' THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                    )                            
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object( 
                                      'itemName', '穿刺針(V針)',
                                      'itemNo', 10,
                                      'itemCd',(ind_cond_info -> '10' ->> 'value')::int,
                                      'itemType',null, 
                                      'date', jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(ind_cond_info -> '10' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '10' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '10' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '10' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '10' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '10' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '10' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '10' ->> 'ind_user_first_name',''))||
                                    CASE
                                     WHEN ind_cond_info -> '12'->> 'value'::text='1' THEN jsonb_build_object('isDisable', true)
                                     ELSE jsonb_build_object()
                                    END
                                    )
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object(
                                      'itemName', '穿刺針(SN)',
                                      'itemNo', 11,
                                      'itemCd',(ind_cond_info -> '11' ->> 'value')::int,
                                      'itemType',null,  
                                      'date', jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(ind_cond_info -> '11' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '11' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '11' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '11' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '11' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '11' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '11' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '11' ->> 'ind_user_first_name',''))||
                                   CASE
                                      WHEN ind_cond_info -> '12'->> 'value'::text='0' THEN jsonb_build_object('isDisable', true)
                                      ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(   
                                     'itemName', 'シングルニードル使用',
                                     'itemNo', 12,
                                     'itemCd',null, 
                                     'itemType',null,  
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '12' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '12' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '12' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '12' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '12' ->> 'ind_user_first_name',''))
                                     )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object( 
                                   'itemNo', 13,      
                                   'itemName', '血液回路', 
                                   'itemCd',(ind_cond_info -> '13' ->> 'value')::int,  
                                   'itemType',null,  
                                   'date', jsonb_build_object(
                                     'value', jsonb_build_object('prefix',substring(ind_cond_info -> '13' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '13' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '13' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '13' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '13' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '13' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '13' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '13' ->> 'ind_user_first_name',''))||
                                     CASE
                                      WHEN ind_cond_info -> '13' IS NULL THEN jsonb_build_object('isDisable', true) 
                                       ELSE jsonb_build_object()
                                       END
                                    )      
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object( 
                                      'itemName', '血流量',
                                      'itemNo', 14,
                                      'itemCd',null,
                                      'itemType',null,
                                      'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '14' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '14' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '14' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '14' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '14' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '14' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '14' IS NULL THEN jsonb_build_object('isDisable', true)
                                       ELSE jsonb_build_object()
                                      END
                                    )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                       'itemName', '透析液',
                                       'itemNo', 15, 
                                       'itemCd',(ind_cond_info -> '15' ->> 'value')::int, 
                                       'itemType',(ind_cond_info -> '15' ->> 'medicine_type')::int, 
                                       'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '15' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '15' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '15' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '15' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '15' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '15' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '15' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '15' ->> 'ind_user_first_name',''))||
                                       CASE
                                     WHEN ind_cond_info -> '15' IS NULL THEN jsonb_build_object('isDisable', true)
                                     ELSE jsonb_build_object()
                                   END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                       'itemName', '透析液流量',
                                       'itemNo', 16,
                                       'itemCd',null,
                                       'itemType',null,
                                       'date', jsonb_build_object(
                                         'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '16' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '16' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '16' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '16' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '16' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '16' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '16' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                       'itemName', '透析液使用数',
                                       'itemNo', 17, 
                                       'itemCd',null,  
                                       'itemType',null,
                                       'date', jsonb_build_object(
                                         'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '17' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '17' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '17' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '17' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '17' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '17' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '17' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                   )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object( 
                                    'itemName', '透析液温度',
                                    'itemNo', 18,
                                    'itemCd',null,
                                    'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '18' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '18' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '18' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '18' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '18' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '18' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '18' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object( 
                                      'itemName', '補液',
                                      'itemNo', 19,
                                      'itemCd',(ind_cond_info -> '19' ->> 'value')::int,  
                                      'itemType',(ind_cond_info -> '19' ->> 'medicine_type')::int,                                      
                                      'date', jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(ind_cond_info -> '19' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '19' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '19' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '19' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '19' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '19' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '19' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '19' ->> 'ind_user_first_name',''))||
                                       CASE
                                         WHEN ind_cond_info -> '19' IS NULL THEN jsonb_build_object('isDisable', true)
                                         ELSE jsonb_build_object()
                                       END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object( 
                                      'itemName', '補液量',
                                      'itemNo', 20,
                                      'itemCd',null,  
                                      'itemType',null,                                       
                                      'date', jsonb_build_object(
                                          'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '20' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '20' ->> 'unit',null)),
                                          'updater', COALESCE(ind_cond_info -> '20' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '20' ->> 'upd_user_first_name','') ,
                                          'instructor', COALESCE(ind_cond_info -> '20' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '20' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '20' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                   'itemName', '補液選択',
                                   'itemNo', 21,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '21' ->> 'value_name_1','未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '21' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '21' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '21' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '21' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '21' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                    'itemName', '補液使用数',
                                    'itemNo', 22,
                                    'itemCd',null,
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '22' ->> 'value','未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '22' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '22' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '22' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '22' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '22' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                   )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object( 
                                   'itemName', '補液温度',
                                   'itemNo', 23,
                                   'itemCd',null,    
                                   'itemType',null,  
                                   'date', jsonb_build_object(
                                      'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '23' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '23' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '23' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '23' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '23' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '23' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '23' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )  
                                 ), jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                      'itemName', '補液速度',
                                      'itemNo', 24,
                                      'itemCd',null,    
                                      'itemType',null,  
                                      'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '24' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '24' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '24' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '24' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '24' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '24' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '24' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                   )
                                 ), jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                     'itemName', '抗凝固剤',
                                     'itemNo', 25,
                                     'itemCd',(ind_cond_info -> '25' ->> 'value')::int,
                                     'itemType',(ind_cond_info -> '25' ->> 'medicine_type')::int, 
                                     'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '25' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '25' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '25' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '25' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '25' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '25' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '25' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '25' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '25' IS NULL THEN jsonb_build_object('isDisable', true)
                                      ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                    'itemName', '抗凝固剤ワンショット量',
                                    'itemNo', 26,
                                    'itemCd',null,
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '26' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '26' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '26' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '26' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '26' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '26' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '26' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                     'itemName', '抗凝固剤持続速度',
                                     'itemNo', 27,
                                     'itemCd',null,  
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                       'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '27' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '27' ->> 'unit',null)),
                                       'updater', COALESCE(ind_cond_info -> '27' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '27' ->> 'upd_user_first_name','') ,
                                       'instructor', COALESCE(ind_cond_info -> '27' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '27' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '27' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                      )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', '抗凝固剤持続総量',
                                   'itemNo', 28,
                                   'itemCd',null,   
                                   'itemType',null, 
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '28' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '28' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '28' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '28' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '28' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '28' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '28' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP使用選択',
                                   'itemNo', 29,
                                   'itemCd',null,  
                                   'itemType',null, 
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '29' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '29' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '29' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '29' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '29' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '29' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )  
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object(
                                     'itemName', 'IPスタート',
                                     'itemNo', 30,
                                     'itemCd',null,  
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '30' ->> 'value_name_1', '未登録'),'unit',null),
                                        'updater', COALESCE(ind_cond_info -> '30' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '30' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '30' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '30' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '30' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IPワンショット量',
                                   'itemNo', 31,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '31' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '31' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '31' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '31' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '31' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '31' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '31' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP速度',
                                   'itemNo', 32,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '32' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '32' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '32' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '32' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '32' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '32' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '32' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )  
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                     'itemName', 'IP速度最大値',
                                     'itemNo', 33,
                                     'itemCd',null,  
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '33' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '33' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '33' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '33' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '33' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '33' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '33' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                    'itemName', '自動ワンショット',
                                    'itemNo', 34,
                                    'itemCd',null,  
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '34' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '34' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '34' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '34' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '34' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '34' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP電源自動切り',
                                   'itemNo', 35,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '35' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '35' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '35' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '35' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '35' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '35' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                    'itemName', 'IP電源自動切り時間',
                                    'itemNo', 36, 
                                    'itemCd',null,  
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                      'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '36' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '36' ->> 'unit',null)),
                                      'updater', COALESCE(ind_cond_info -> '36' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '36' ->> 'upd_user_first_name','') ,
                                      'instructor', COALESCE(ind_cond_info -> '36' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '36' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '36' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP電源OKモニタ切り',
                                    'itemNo', 37,
                                    'itemCd',null,  
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                      'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '37' ->> 'value_name_1', '未登録'),'unit',null),
                                      'updater', COALESCE(ind_cond_info -> '37' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '37' ->> 'upd_user_first_name','') ,
                                      'instructor', COALESCE(ind_cond_info -> '37' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '37' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '37' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP電源OKモニタ切り時間',
                                   'itemNo', 38,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '38' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '38' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '38' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '38' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '38' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                   'itemName', 'DW', 
                                   'itemNo', -1,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value', jsonb_build_object('prefix',null,'dispVal',(case when ind_dw is null then '未登録' else ind_dw::TEXT end ),'unit',(case when ind_dw is null then null else 'kg' end )),
                                     'updater', COALESCE(ind_cond_info -> '38' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '38' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'ind_user_first_name',''))
                                 )
                                 )
                               ),
                               'subCategoryName', '治療条件'
                             ) AS cond_json
                             FROM
                               ord_main
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                           ),  content_map as(
                           SELECT
                           	 ord_main.ord_no,
                           	  jsonb_build_object(
                                   'component', 'treat-method',
                                   'subCategoryNo', 2,
                                   'subCategoryItem','[]'::jsonb,
                                   'itemInfo',jsonb_build_object(
                                   'itemName',null,
                                   'itemNo',1,
                                   'itemCd',ind_treatment_cd,
                                   'itemType',null,
                                   'data',jsonb_build_object(
                                         'value',jsonb_build_object('unit',null,'prefix',null,'dispVal',ind_treatment_name),
                                         'updater',null,
                                         'instructor',null
                                     )
                                 ),
                                 'subCategoryName', '治療方法'
                                ) as  treat_method,
                           jsonb_build_object('component', 'schedule',
                               'subCategoryNo', 3,
                               'subCategoryItem', json_build_array(
                                  jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                  'itemName', 'クール',
                                  'itemNo', 1,
                                  'itemCd', ind_kur_cd,
                                  'itemType', null,
                                   'date', jsonb_build_object(
                                     'value',jsonb_build_object('unit',null,'prefix',null, 'dispVal',ind_kur_name),
                                     'updater', personal_info_decrypt ( up.user_last_name ) || personal_info_decrypt ( up.user_first_name ),
                                     'instructor', personal_info_decrypt ( ind.user_last_name ) || personal_info_decrypt ( ind.user_first_name )
                                   )                         
                                  )
                                 ),jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                  'itemName', '治療開始時刻',
                                  'itemNo', 2,
                                  'itemCd', null,
                                  'itemType', null,
                                   'date', jsonb_build_object(
                                    'value',jsonb_build_object('unit',null,'prefix',to_char(to_date(treat_date, 'YYYYMMDD'), 'YYYY/MM/DD')||' ', 'dispVal',substr(ind_treat_start_time, 1, 2) || ':' || substr(ind_treat_start_time, 3, 2)),
                                     'updater', personal_info_decrypt ( up.user_last_name ) || personal_info_decrypt ( up.user_first_name ),
                                     'instructor', personal_info_decrypt ( ind.user_last_name ) || personal_info_decrypt ( ind.user_first_name )
                                   )
                                  )
                                 ),jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                 'itemName', 'ベッド',
                                  'itemNo', 3,
                                  'itemCd', ind_bed_cd,
                                  'itemType', null,
                                   'date', jsonb_build_object(
                                     'value',jsonb_build_object('unit',null,'prefix',null, 'dispVal',ind_bed_name),
                                     'updater', personal_info_decrypt ( up.user_last_name ) || personal_info_decrypt ( up.user_first_name ),
                                     'instructor', personal_info_decrypt ( ind.user_last_name ) || personal_info_decrypt ( ind.user_first_name )
                                   )
                                   )
                                 )
                               ),
                               'subCategoryName', 'スケジュール'
                             ) as  schedule,
                           	 cond_json,
                           	 jsonb_build_object(
                           		'component','medicine',	
                           		'subCategoryNo',5,	
                           		'subCategoryItem',case  when medi_json is not null then  medi_json::jsonb else '[]'::jsonb end,
                           		'subCategoryName','投与薬剤'
                                 )
                           	 as ind_medi_info,
                           	 jsonb_build_object(
                           		'component','equipment',	
                           		'subCategoryNo',6,	
                           		'subCategoryItem',case  when equip_json is not null then  equip_json::jsonb else '[]'::jsonb end,
                           		'subCategoryName','医療材料'
                                 )
                           			as ind_equip_info,
                           	 jsonb_build_object(
                           		'component','ind-comment',	
                           		'subCategoryNo',7,	
                           		'subCategoryItem',case  when comment_info_json is not null then  comment_info_json::jsonb else '[]'::jsonb end,
                           		'subCategoryName','指示コメント'
                                 )
                             as	ind_ind_comment_info,
                           	ind_dw
                           FROM
                           	ord_main
                           	LEFT JOIN mst_personal_user up ON up.user_id = ord_main.up_user_id
                           	AND up.facility_cd =:facility_cd
                           	LEFT JOIN mst_personal_user ind ON ind.user_id = ord_main.up_user_id
                           	AND ind.facility_cd =:facility_cd
                           		LEFT JOIN medi_info medi ON medi.ord_no = ord_main.ord_no
                           	LEFT JOIN comment_info comment ON comment.ord_no = ord_main.ord_no
                           	LEFT JOIN equip_info equip ON equip.ord_no = ord_main.ord_no
                           	LEFT JOIN cond_info cond ON cond.ord_no = ord_main.ord_no
                           WHERE
                           	rst_dialysis_state = '6'
                           	AND ord_main.facility_cd = :facility_cd
                           	AND ind_cond_info IS NOT NULL),  contentformap  as (     	
                           	select ord_no,json_build_array(treat_method,schedule,cond_json,ind_medi_info,ind_equip_info,ind_ind_comment_info) as content_for_map           
                           		from content_map)
                           		INSERT INTO pat_ind_approve (
                                                              ord_no,
                                                              check_user1_cd,
                                                              check_user2_cd,
                                                              approve_user1_cd,
                                                              approve_user2_cd,
                                                              check_user1_time,
                                                              check_user2_time,
                                                              approve_user1_time,
                                                              approve_user2_time,
                                                              reg_date,
                                                              up_date,
                                                              is_content_changed,
                                                              is_content_appd_changed,
                                                              check_content,
                                                              approve_content,
                                                              is_user1_checked,
                                                              is_user2_checked,
                                                              is_user1_approved,
                                                              is_user2_approved,
                                                              facility_cd,content_for_map)
                           		                            SELECT
                                                              ord.ord_no,
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              to_timestamp(to_char(CURRENT_DATE, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                                                              to_timestamp(NULL, 'YYYY-MM-DD HH24:MI:SS'),
                                                              '1',
                                                              '1',
                                                              '{}',
                                                              '{}',
                                                              '0',
                                                              '0',
                                                              '0',
                                                              '0',
                                                               ord.facility_cd,
                           									 case when ord.rst_dialysis_state = '6'  then	cmap.content_for_map else null end
                                                               FROM ord_main ord  left join  pat_ind_approve pat  on ord.ord_no=pat.ord_no and  pat.facility_cd= ord.facility_cd
                                                               left join  contentformap cmap  on ord.ord_no=cmap.ord_no 
                                                               where ord.ind_cond_info is not null and   pat.ord_no IS NULL AND ord.facility_cd=:facility_cd
                    """);
            MapSqlParameterSource params = new MapSqlParameterSource();
            params.addValue("facility_cd", facilityCd);
            NamedParameterJdbcTemplate machineJdbcTemplate = new NamedParameterJdbcTemplate(convertDbDs);
            int count = machineJdbcTemplate.update(ind_Pat_Ind_Approve.toString(), params);
            eventLogMessage = eventLoggerUtil.getEventLogMessage(String.format("pat_ind_approve更新成功%d件", count),
                    facilityCd, "addPatIndDpprove()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        } catch (Exception e) {
            //ログ
            eventLogMessage = eventLoggerUtil.getEventLogMessage("pat_ind_approve更新に失敗しました！ " + e.getMessage(),
                    facilityCd, "addPatIndDpprove()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
        }
    }

    private void copyPatIndApprove(String inputFilePath,boolean isDel, String facilityCd) throws Exception {
        String tableName = "pat_ind_approve";
        // 本番DBのDBTypeの取得（テーブルが存在するDBを検索して取得）
        TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
        String productionDbType = tableNameToDbType.getDbTypeByTableName(tableName);
        // 実行するコピーコマンドの組み立て
        String[] command = createCopyCommand(inputFilePath,tableName, ApplicationConst.DbType.CONVERT, productionDbType, facilityCd, isDel);
        // システムコール
        Runtime runtime = Runtime.getRuntime();
        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("pat_ind_approveコピーコマンド実行：" + command[2],
                facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        Process p = runtime.exec(command);
        // 子プロセスの標準出力および標準エラー出力を入力するスレッドを起動
        StreamThread it = new StreamThread(p.getInputStream());
        StreamThread et = new StreamThread(p.getErrorStream());
        it.start();
        et.start();
        int returnCode = p.waitFor(); // 子プロセスの終了を待つ
        // スレッドの終了を待つ
        it.join();
        et.join();
        // ストリームを一応明示的にクローズしておく
        p.getInputStream().close();
        p.getOutputStream().close();
        p.getErrorStream().close();
        p.destroy(); // 子プロセスを明示的に終了
        if (returnCode != 0) {
            // テーブル毎の進捗更新
            String errorMsg = "pat_ind_approveCopyコマンド異常終了\n" + et.getOutputString();
            eventLogMessage = eventLoggerUtil.getEventLogMessage("pat_ind_approveCopyコマンド異常終了：処理テーブル：" + tableName,
                    facilityCd, "addPatIndDpprove()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            throw new RuntimeException(errorMsg);
        } else {
            eventLogMessage = eventLoggerUtil.getEventLogMessage("pat_ind_approveCopyコマンド正常終了：処理テーブル：" + tableName,
                    facilityCd, "addPatIndDpprove()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);

        }

    }
    public String[] createCopyCommand(
            String inputFilePath,
            String tableName,
            String fromDbType,
            String toDbType,
            String facilityCd,boolean isDel) {
        String jdbcUrl = environment.getProperty("datasource." + fromDbType + ".jdbc-url");
        String userName = environment.getProperty("datasource." + fromDbType + ".username");
        String jdbcUrlConvert = environment.getProperty("datasource." + toDbType + ".jdbc-url");
        String userNameConvert = environment.getProperty("datasource." + toDbType + ".username");
        // 登録元DB接続情報を取得
        String fromHostIp = jdbcUrl.split("/")[2].split(":")[0];
        String fromDbUser = userName;
        String fromDbName = jdbcUrl.split("/")[3];
        // 登録先DB接続情報を取得
        String toHostIp = jdbcUrlConvert.split("/")[2].split(":")[0];
        String toDbUser = userNameConvert;
        String toDbName = jdbcUrlConvert.split("/")[3];
        String sqlDelete = "";
        if(isDel){
            String  sqlDel= " delete from pat_ind_approve " +
                    "where  ord_no in ( SELECT ord.ord_no FROM ord_main ord left join pat_ind_approve pat" +
                    " on ord.ord_no = pat.ord_no and pat.facility_cd = ord.facility_cd" +
                    " where ord.ind_cond_info is not null and ord.rst_dialysis_state='6' AND content_for_map IS NULL AND ord.facility_cd ='" + facilityCd + "')" +
                    " and  facility_cd ='" + facilityCd + "'";
            sqlDelete = " -c \"" + sqlDel + "\"";
        }
        // 登録先DBスキーマを取得
        String toDb_table_prefix = environment.getProperty(toDbUser+ "_prefix");
        toDb_table_prefix = toDb_table_prefix == null ? "" : toDb_table_prefix;

        // 登録列名リストをカンマ区切りに変換
        String registColumnNames ="ord_no,check_user1_cd, check_user2_cd,approve_user1_cd,approve_user2_cd,check_user1_time,check_user2_time,approve_user1_time,approve_user2_time," +
                "reg_date,up_date,is_content_changed,is_content_appd_changed,check_content,approve_content,is_user1_checked,is_user2_checked,is_user1_approved," +
                "is_user2_approved,facility_cd,content_for_map";
        // データ取得SQL生成
        String sql ="SELECT ind.ord_no ,NULL,NULL,NULL, NULL,NULL,NULL,NULL,NULL,to_timestamp(to_char(CURRENT_DATE, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')," +
                "to_timestamp(NULL, 'YYYY-MM-DD HH24:MI:SS'), '1','1','{}', '{}','0','0','0','0'," +
                "ind.facility_cd,content_for_map  FROM pat_ind_approve ind  INNER JOIN  convert_pat_ind_approve_ord_no ordno ON ordno.ord_no = ind.ord_no AND ordno.facility_cd = ind.facility_cd " +
                " where  ind.facility_cd='" + facilityCd + "' ";

        if(isDel){
            sql ="SELECT ind.ord_no ,check_user1_cd,check_user2_cd,approve_user1_cd, approve_user2_cd,check_user1_time,check_user2_time,approve_user1_time,approve_user2_time,reg_date," +
                    "up_date, is_content_changed,is_content_appd_changed,check_content, approve_content,is_user1_checked,is_user2_checked,is_user1_approved,is_user2_approved," +
                    "ind.facility_cd,content_for_map  FROM pat_ind_approve ind  INNER JOIN  convert_pat_ind_approve_ord_no ordno ON ordno.ord_no = ind.ord_no AND ordno.facility_cd = ind.facility_cd " +
                    " where  ind.facility_cd='" + facilityCd + "' ";
        }
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tmpCopyCsvFile = inputFilePath + globalContext.tmpCopyCsvDir + tableName + ".csv";
        // 実行するコピーコマンドの組み立て
        String copyCommand = "psql"
                + " -h "
                + fromHostIp
                + " -U "
                + fromDbUser
                + " -d "
                + fromDbName
                + " -c \"\\copy "
                + "("
                + sql
                + ") TO " + tmpCopyCsvFile + " WITH CSV HEADER\""
                + " && "
                + "psql"
                + " -h "
                + toHostIp
                + " -U "
                + toDbUser
                + " -d "
                + toDbName
                + " -1 "
                + sqlDelete
                + " -c \"\\copy " + toDb_table_prefix
                + tableName
                + "("
                + registColumnNames
                + ") FROM " + tmpCopyCsvFile + " WITH CSV HEADER\"";
        // Windows、その他で実行方法を変更する
        String[] command = new String[3];
        if( "\\".equals(System.getProperty("file.separator")) ) {
            command[0] = "cmd.exe";
            command[1] = "/c";
        }else{
            command[0] = "sh";
            command[1] = "-c";
        }
        command[2] = copyCommand;
        return command;
    }


    private void updateContentForMapControl(String facilityCd) {
        DataSource convertDbDs = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        StringBuilder ind_Pat_Ind_Approve = new StringBuilder();
        ind_Pat_Ind_Approve.append("""  
			   WITH medi_info AS (
                             SELECT
                               ord_no,
                               jsonb_agg(
                                jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                      'itemName', COALESCE(substring(json_data->>'name' FROM '】([^】]*)$'),json_data->>'name'),
                                      'itemNo', (json_data->>'no')::int,
                                      'itemCd', (json_data->>'cd')::int,
                                      'itemType', (json_data->>'medicine_type')::int,
                                      'date',jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(json_data->>'name' FROM '^(.*】)'),'dispVal', json_data->>'amount', 'unit', COALESCE(json_data->>'unit', null)),
                                        'updater', COALESCE(json_data->>'upd_user_last_name', '') || COALESCE(json_data->>'upd_user_first_name', ''),
                                        'instructor', COALESCE(json_data->>'ind_user_last_name', '') || COALESCE(json_data->>'ind_user_first_name', '')
                                      )
                                     )
                                )
                            ) AS medi_json
                             FROM
                               ord_main,
                               jsonb_array_elements(ind_medi_info) AS json_data
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                             GROUP BY
                               ord_no
                           ),
                           comment_info AS (
                             SELECT
                               ord_no,
                                jsonb_agg(
                                    jsonb_build_object(
                                       'itemInfo',jsonb_build_object(
                                           'itemName', 'コメント'||(comment_info->>'no')::text,
                                           'itemNo', (comment_info->>'no')::int,
                                           'itemCd',null,
                                           'itemType',null,
                                           'date', jsonb_build_object(
                                            'value', jsonb_build_object( 'unit', null,'prefix',null,'dispVal', comment_info->>'content'),
                                            'updater', COALESCE(comment_info->>'upd_user_last_name', '') || COALESCE(comment_info->>'upd_user_first_name', ''),
                                            'instructor', COALESCE(comment_info->>'ind_user_last_name', '') || COALESCE(comment_info->>'ind_user_first_name', '')
                                           )
                                          )
                                    )
                                ) AS comment_info_json
                             FROM
                               ord_main,
                               jsonb_array_elements(ind_ind_comment_info) AS comment_info
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                             GROUP BY
                               ord_no
                           ),
                           equip_info AS (
                             SELECT
                               ord_no,
                               jsonb_agg(
                                 jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                        'itemName', COALESCE(substring(json_data->>'name' FROM '】([^】]*)$'),json_data->>'name'),
                                        'itemNo', null,
                                        'itemCd', (json_data->>'cd')::int,
                                        'itemType', (json_data->>'equip_type')::int,
                                        'date', jsonb_build_object(
                                          'value', jsonb_build_object('prefix',substring(json_data->>'name' FROM '^(.*】)'),'dispVal', json_data->>'amount', 'unit', COALESCE(json_data->>'unit', null)),
                                          'updater', COALESCE(json_data->>'upd_user_last_name', '') || COALESCE(json_data->>'upd_user_first_name', ''),
                                          'instructor', COALESCE(json_data->>'ind_user_last_name', '') || COALESCE(json_data->>'ind_user_first_name', '')
                                         )
                                        )
                                  ) 
                                ) AS equip_json
                             FROM
                               ord_main,
                               jsonb_array_elements(ind_equip_info) AS json_data
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                             GROUP BY
                               ord_no
                           ),
                           cond_info AS (
                             	 SELECT
                               ord_no,
                               jsonb_build_object(
                               'component', 'treat-cond',
                               'subCategoryNo', 4,
                               'subCategoryItem', json_build_array(
                               jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                     'itemName', '治療時間',
                                     'itemNo', 1,
                                     'itemCd',null,
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                          'value',jsonb_build_object('prefix',null,'dispVal',COALESCE (
                                                             RIGHT ( '00' || TRUNC( TO_NUMBER(ind_cond_info -> '1' ->> 'value', '999999' ) / 60, 0 ), 2 ) || ':' || RIGHT ( '00' || MOD ( TO_NUMBER( ind_cond_info -> '1' ->> 'value', '999999' ), 60 ), 2 ),
                                                             '未登録'
                                                           ), 'unit', null),
                                         'updater', COALESCE(ind_cond_info -> '1' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '1' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '1' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '1' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '1' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                       'itemInfo',jsonb_build_object(
                                           'itemName', 'VA',
                                           'itemNo', 2,
                                           'itemCd',(ind_cond_info -> '2' ->> 'value')::int,
                                           'itemType',null,
                                           'date', jsonb_build_object(
                                           'value',jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '2' ->> 'value_name_1','未登録' ),'unit', null),
                                             'updater', COALESCE(ind_cond_info -> '2' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '2' ->> 'upd_user_first_name','') ,
                                             'instructor', COALESCE(ind_cond_info -> '2' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '2' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '2' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                       )
                                 ), jsonb_build_object(
                                       'itemInfo',jsonb_build_object(
                                           'itemName', '目標体重',
                                           'itemNo', 3,
                                           'itemCd',null,
                                           'itemType',null,
                                           'date', jsonb_build_object(
                                             'value',jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '3' ->> 'value','未登録' ),'unit', COALESCE(ind_cond_info -> '3' ->> 'unit',null)),
                                             'updater', COALESCE(ind_cond_info -> '3' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'upd_user_first_name','') ,
                                             'instructor', COALESCE(ind_cond_info -> '3' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '3' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                      )
                                 ), jsonb_build_object(
                                     'itemInfo',jsonb_build_object(
                                         'itemName', '除水量制限',
                                         'itemNo', 4,
                                         'itemCd',null,
                                         'itemType',null,
                                         'date', jsonb_build_object(
                                             'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '4' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '4' ->> 'unit',null)),
                                             'updater', COALESCE(ind_cond_info -> '4' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'upd_user_first_name','') ,
                                             'instructor', COALESCE(ind_cond_info -> '4' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '3' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '4' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                          )
                                 ), jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                        'itemName', 'ダイアライザ',
                                        'itemNo', 5,
                                        'itemCd',(ind_cond_info -> '5' ->> 'value')::int,
                                        'itemType',null,
                                        'date', jsonb_build_object(
                                         'value',  jsonb_build_object('prefix',substring(ind_cond_info -> '5' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE('['||COALESCE(substring(ind_cond_info -> '5' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '5' ->> 'value_name_1')||']', '未登録'),'unit',COALESCE(ind_cond_info -> '5' ->> 'unit', null)),
                                          'updater', COALESCE(ind_cond_info -> '5' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '5' ->> 'upd_user_first_name','') ,
                                          'instructor', COALESCE(ind_cond_info -> '5' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '5' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '5' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object(
                                       'itemName', '吸着カラム',
                                       'itemNo', 6,
                                       'itemCd',(ind_cond_info -> '6' ->> 'value')::int,
                                       'itemType',null,
                                       'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '6' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '6' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '6' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '6' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '6' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '6' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '6' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '6' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '6' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )                              
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                       'itemName', '1次膜',
                                       'itemNo', 7,
                                       'itemCd',(ind_cond_info -> '7' ->> 'value')::int,
                                       'itemType',null,   
                                       'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '7' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '7' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '7' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '7' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '7' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '7' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '7' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '7' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '7' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                   )
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object( 
                                        'itemName', '2次膜',
                                        'itemNo', 8,
                                        'itemCd',(ind_cond_info -> '8' ->> 'value')::int,
                                        'itemType',null,
                                        'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '8' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '8' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '8' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '8' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '8' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '8' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '8' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '8' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '8' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                    )
                                 ), jsonb_build_object(
                                      'itemInfo',jsonb_build_object( 
                                      'itemName', '穿刺針(A針)',
                                      'itemNo', 9, 
                                      'itemCd',(ind_cond_info -> '9' ->> 'value')::int,  
                                      'itemType',null,  
                                      'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '9' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '9' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '9' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '9' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '9' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '9' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '9' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '9' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '12'->> 'value'::text='1' THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                    )                            
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object( 
                                      'itemName', '穿刺針(V針)',
                                      'itemNo', 10,
                                      'itemCd',(ind_cond_info -> '10' ->> 'value')::int,
                                      'itemType',null, 
                                      'date', jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(ind_cond_info -> '10' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '10' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '10' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '10' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '10' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '10' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '10' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '10' ->> 'ind_user_first_name',''))||
                                    CASE
                                     WHEN ind_cond_info -> '12'->> 'value'::text='1' THEN jsonb_build_object('isDisable', true)
                                     ELSE jsonb_build_object()
                                    END
                                    )
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object(
                                      'itemName', '穿刺針(SN)',
                                      'itemNo', 11,
                                      'itemCd',(ind_cond_info -> '11' ->> 'value')::int,
                                      'itemType',null,  
                                      'date', jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(ind_cond_info -> '11' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '11' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '11' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '11' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '11' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '11' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '11' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '11' ->> 'ind_user_first_name',''))||
                                   CASE
                                      WHEN ind_cond_info -> '12'->> 'value'::text='0' THEN jsonb_build_object('isDisable', true)
                                      ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(   
                                     'itemName', 'シングルニードル使用',
                                     'itemNo', 12,
                                     'itemCd',null, 
                                     'itemType',null,  
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '12' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '12' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '12' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '12' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '12' ->> 'ind_user_first_name',''))
                                     )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object( 
                                   'itemNo', 13,      
                                   'itemName', '血液回路', 
                                   'itemCd',(ind_cond_info -> '13' ->> 'value')::int,  
                                   'itemType',null,  
                                   'date', jsonb_build_object(
                                     'value', jsonb_build_object('prefix',substring(ind_cond_info -> '13' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '13' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '13' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '13' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '13' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '13' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '13' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '13' ->> 'ind_user_first_name',''))||
                                     CASE
                                      WHEN ind_cond_info -> '13' IS NULL THEN jsonb_build_object('isDisable', true) 
                                       ELSE jsonb_build_object()
                                       END
                                    )      
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object( 
                                      'itemName', '血流量',
                                      'itemNo', 14,
                                      'itemCd',null,
                                      'itemType',null,
                                      'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '14' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '14' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '14' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '14' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '14' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '14' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '14' IS NULL THEN jsonb_build_object('isDisable', true)
                                       ELSE jsonb_build_object()
                                      END
                                    )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                       'itemName', '透析液',
                                       'itemNo', 15, 
                                       'itemCd',(ind_cond_info -> '15' ->> 'value')::int, 
                                       'itemType',(ind_cond_info -> '15' ->> 'medicine_type')::int,    
                                       'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '15' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '15' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '15' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '15' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '15' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '15' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '15' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '15' ->> 'ind_user_first_name',''))||
                                       CASE
                                     WHEN ind_cond_info -> '15' IS NULL THEN jsonb_build_object('isDisable', true)
                                     ELSE jsonb_build_object()
                                   END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                       'itemName', '透析液流量',
                                       'itemNo', 16,
                                       'itemCd',null,
                                       'itemType',null,
                                       'date', jsonb_build_object(
                                         'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '16' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '16' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '16' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '16' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '16' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '16' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '16' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                       'itemName', '透析液使用数',
                                       'itemNo', 17, 
                                       'itemCd',null,  
                                       'itemType',null,
                                       'date', jsonb_build_object(
                                         'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '17' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '17' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '17' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '17' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '17' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '17' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '17' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                   )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object( 
                                    'itemName', '透析液温度',
                                    'itemNo', 18,
                                    'itemCd',null,
                                    'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '18' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '18' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '18' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '18' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '18' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '18' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '18' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object( 
                                      'itemName', '補液',
                                      'itemNo', 19,
                                      'itemCd',(ind_cond_info -> '19' ->> 'value')::int,  
                                      'itemType',(ind_cond_info -> '19' ->> 'medicine_type')::int,                                      
                                      'date', jsonb_build_object(
                                        'value', jsonb_build_object('prefix',substring(ind_cond_info -> '19' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '19' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '19' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '19' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '19' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '19' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '19' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '19' ->> 'ind_user_first_name',''))||
                                       CASE
                                         WHEN ind_cond_info -> '19' IS NULL THEN jsonb_build_object('isDisable', true)
                                         ELSE jsonb_build_object()
                                       END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object( 
                                      'itemName', '補液量',
                                      'itemNo', 20,
                                      'itemCd',null,  
                                      'itemType',null,                                       
                                      'date', jsonb_build_object(
                                          'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '20' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '20' ->> 'unit',null)),
                                          'updater', COALESCE(ind_cond_info -> '20' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '20' ->> 'upd_user_first_name','') ,
                                          'instructor', COALESCE(ind_cond_info -> '20' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '20' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '20' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                   'itemName', '補液選択',
                                   'itemNo', 21,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '21' ->> 'value_name_1','未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '21' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '21' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '21' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '21' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '21' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                   )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                    'itemName', '補液使用数',
                                    'itemNo', 22,
                                    'itemCd',null,
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '22' ->> 'value','未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '22' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '22' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '22' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '22' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '22' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                   )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object( 
                                   'itemName', '補液温度',
                                   'itemNo', 23,
                                   'itemCd',null,    
                                   'itemType',null,  
                                   'date', jsonb_build_object(
                                      'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '23' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '23' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '23' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '23' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '23' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '23' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '23' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )  
                                 ), jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                      'itemName', '補液速度',
                                      'itemNo', 24,
                                      'itemCd',null,    
                                      'itemType',null,  
                                      'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '24' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '24' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '24' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '24' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '24' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '24' ->> 'ind_user_first_name',''))||
                                          CASE
                                            WHEN ind_cond_info -> '24' IS NULL THEN jsonb_build_object('isDisable', true)
                                            ELSE jsonb_build_object()
                                          END
                                   )
                                 ), jsonb_build_object(
                                    'itemInfo',jsonb_build_object(
                                     'itemName', '抗凝固剤',
                                     'itemNo', 25,
                                     'itemCd',(ind_cond_info -> '25' ->> 'value')::int,
                                     'itemType',(ind_cond_info -> '25' ->> 'medicine_type')::int, 
                                     'date', jsonb_build_object(
                                         'value', jsonb_build_object('prefix',substring(ind_cond_info -> '25' ->> 'value_name_1' FROM '^(.*】)'),'dispVal',COALESCE(COALESCE(substring(ind_cond_info -> '25' ->> 'value_name_1' FROM '】([^】]*)$'),ind_cond_info -> '25' ->> 'value_name_1'), '未登録'),'unit',COALESCE(ind_cond_info -> '25' ->> 'unit',null)),
                                         'updater', COALESCE(ind_cond_info -> '25' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '25' ->> 'upd_user_first_name','') ,
                                         'instructor', COALESCE(ind_cond_info -> '25' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '25' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '25' IS NULL THEN jsonb_build_object('isDisable', true)
                                      ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                    'itemName', '抗凝固剤ワンショット量',
                                    'itemNo', 26,
                                    'itemCd',null,
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '26' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '26' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '26' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '26' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '26' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '26' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '26' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                     'itemName', '抗凝固剤持続速度',
                                     'itemNo', 27,
                                     'itemCd',null,  
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                       'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '27' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '27' ->> 'unit',null)),
                                       'updater', COALESCE(ind_cond_info -> '27' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '27' ->> 'upd_user_first_name','') ,
                                       'instructor', COALESCE(ind_cond_info -> '27' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '27' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '27' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                      )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', '抗凝固剤持続総量',
                                   'itemNo', 28,
                                   'itemCd',null,   
                                   'itemType',null, 
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '28' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '28' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '28' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '28' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '28' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '28' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '28' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP使用選択',
                                   'itemNo', 29,
                                   'itemCd',null,  
                                   'itemType',null, 
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '29' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '29' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '29' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '29' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '29' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '29' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )  
                                 ), jsonb_build_object(
                                   'itemInfo',jsonb_build_object(
                                     'itemName', 'IPスタート',
                                     'itemNo', 30,
                                     'itemCd',null,  
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '30' ->> 'value_name_1', '未登録'),'unit',null),
                                        'updater', COALESCE(ind_cond_info -> '30' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '30' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '30' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '30' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '30' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IPワンショット量',
                                   'itemNo', 31,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '31' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '31' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '31' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '31' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '31' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '31' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '31' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP速度',
                                   'itemNo', 32,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '32' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '32' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '32' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '32' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '32' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '32' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '32' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )  
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                     'itemName', 'IP速度最大値',
                                     'itemNo', 33,
                                     'itemCd',null,  
                                     'itemType',null,
                                     'date', jsonb_build_object(
                                        'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '33' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '33' ->> 'unit',null)),
                                        'updater', COALESCE(ind_cond_info -> '33' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '33' ->> 'upd_user_first_name','') ,
                                        'instructor', COALESCE(ind_cond_info -> '33' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '33' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '33' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                    'itemName', '自動ワンショット',
                                    'itemNo', 34,
                                    'itemCd',null,  
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '34' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '34' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '34' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '34' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '34' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '34' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP電源自動切り',
                                   'itemNo', 35,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '35' ->> 'value_name_1', '未登録'),'unit',null),
                                     'updater', COALESCE(ind_cond_info -> '35' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '35' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '35' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '35' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '35' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                    'itemName', 'IP電源自動切り時間',
                                    'itemNo', 36, 
                                    'itemCd',null,  
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                      'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '36' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '36' ->> 'unit',null)),
                                      'updater', COALESCE(ind_cond_info -> '36' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '36' ->> 'upd_user_first_name','') ,
                                      'instructor', COALESCE(ind_cond_info -> '36' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '36' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '36' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP電源OKモニタ切り',
                                    'itemNo', 37,
                                    'itemCd',null,  
                                    'itemType',null,
                                    'date', jsonb_build_object(
                                      'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '37' ->> 'value_name_1', '未登録'),'unit',null),
                                      'updater', COALESCE(ind_cond_info -> '37' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '37' ->> 'upd_user_first_name','') ,
                                      'instructor', COALESCE(ind_cond_info -> '37' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '37' ->> 'ind_user_first_name',''))||
                                      CASE
                                        WHEN ind_cond_info -> '37' IS NULL THEN jsonb_build_object('isDisable', true)
                                        ELSE jsonb_build_object()
                                      END
                                  )
                                 ), jsonb_build_object(
                                 'itemInfo',jsonb_build_object(
                                   'itemName', 'IP電源OKモニタ切り時間',
                                   'itemNo', 38,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value',  jsonb_build_object('prefix',null,'dispVal',COALESCE(ind_cond_info -> '38' ->> 'value', '未登録'),'unit',COALESCE(ind_cond_info -> '38' ->> 'unit',null)),
                                     'updater', COALESCE(ind_cond_info -> '38' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '38' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'ind_user_first_name',''))||
                                  CASE
                                    WHEN ind_cond_info -> '38' IS NULL THEN jsonb_build_object('isDisable', true)
                                    ELSE jsonb_build_object()
                                  END
                                  )
                                 ), jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                   'itemName', 'DW', 
                                   'itemNo', -1,
                                   'itemCd',null,  
                                   'itemType',null,
                                   'date', jsonb_build_object(
                                     'value', jsonb_build_object('prefix',null,'dispVal',(case when ind_dw is null then '未登録' else ind_dw::TEXT end ),'unit',(case when ind_dw is null then null else 'kg' end )),
                                     'updater', COALESCE(ind_cond_info -> '38' ->> 'upd_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'upd_user_first_name','') ,
                                     'instructor', COALESCE(ind_cond_info -> '38' ->> 'ind_user_last_name','')||COALESCE(ind_cond_info -> '38' ->> 'ind_user_first_name',''))
                                 )
                                 )
                               ),
                               'subCategoryName', '治療条件'
                             ) AS cond_json
                             FROM
                               ord_main
                             WHERE
                               rst_dialysis_state = '6'
                               AND ord_main.facility_cd = :facility_cd
                               AND ind_cond_info IS NOT NULL
                           ),  content_map as(
                           SELECT
                           	 ord_main.ord_no,
                           	  jsonb_build_object(
                                   'component', 'treat-method',
                                   'subCategoryNo', 2,
                                   'subCategoryItem','[]'::jsonb,
                                   'itemInfo',jsonb_build_object(
                                   'itemName',null,
                                   'itemNo',1,
                                   'itemCd',ind_treatment_cd,
                                   'itemType',null,
                                   'data',jsonb_build_object(
                                         'value',jsonb_build_object('unit',null,'prefix',null,'dispVal',ind_treatment_name),
                                         'updater',null,
                                         'instructor',null
                                     )
                                 ),
                                 'subCategoryName', '治療方法'
                                ) as  treat_method,
                           jsonb_build_object('component', 'schedule',
                               'subCategoryNo', 3,
                               'subCategoryItem', json_build_array(
                                  jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                  'itemName', 'クール',
                                  'itemNo', 1,
                                  'itemCd', ind_kur_cd,
                                  'itemType', null,
                                   'date', jsonb_build_object(
                                     'value',jsonb_build_object('unit',null,'prefix',null, 'dispVal',ind_kur_name),
                                     'updater', personal_info_decrypt ( up.user_last_name ) || personal_info_decrypt ( up.user_first_name ),
                                     'instructor', personal_info_decrypt ( ind.user_last_name ) || personal_info_decrypt ( ind.user_first_name )
                                   )                         
                                  )
                                 ),jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                  'itemName', '治療開始時刻',
                                  'itemNo', 2,
                                  'itemCd', null,
                                  'itemType', null,
                                   'date', jsonb_build_object(
                                    'value',jsonb_build_object('unit',null,'prefix',to_char(to_date(treat_date, 'YYYYMMDD'), 'YYYY/MM/DD')||' ', 'dispVal', substr(ind_treat_start_time, 1, 2) || ':' || substr(ind_treat_start_time, 3, 2)),
                                     'updater', personal_info_decrypt ( up.user_last_name ) || personal_info_decrypt ( up.user_first_name ),
                                     'instructor', personal_info_decrypt ( ind.user_last_name ) || personal_info_decrypt ( ind.user_first_name )
                                   )
                                  )
                                 ),jsonb_build_object(
                                  'itemInfo',jsonb_build_object(
                                 'itemName', 'ベッド',
                                  'itemNo', 3,
                                  'itemCd', ind_bed_cd,
                                  'itemType', null,
                                   'date', jsonb_build_object(
                                     'value',jsonb_build_object('unit',null,'prefix',null, 'dispVal',ind_bed_name),
                                     'updater', personal_info_decrypt ( up.user_last_name ) || personal_info_decrypt ( up.user_first_name ),
                                     'instructor', personal_info_decrypt ( ind.user_last_name ) || personal_info_decrypt ( ind.user_first_name )
                                   )
                                   )
                                 )
                               ),
                               'subCategoryName', 'スケジュール'
                             ) as  schedule,
                           	 cond_json,
                           	 jsonb_build_object(
                           		'component','medicine',	
                           		'subCategoryNo',5,	
                           		'subCategoryItem',case  when medi_json is not null then  medi_json::jsonb else '[]'::jsonb end,
                           		'subCategoryName','投与薬剤'
                                 )
                           	 as ind_medi_info,
                           	 jsonb_build_object(
                           		'component','equipment',	
                           		'subCategoryNo',6,	
                           		'subCategoryItem',case  when equip_json is not null then  equip_json::jsonb else '[]'::jsonb end,
                           		'subCategoryName','医療材料'
                                 )
                           			as ind_equip_info,
                           	 jsonb_build_object(
                           		'component','ind-comment',	
                           		'subCategoryNo',7,	
                           		'subCategoryItem',case  when comment_info_json is not null then  comment_info_json::jsonb else '[]'::jsonb end,
                           		'subCategoryName','指示コメント'
                                 )
                             as	ind_ind_comment_info,
                           	ind_dw
                           FROM
                           	ord_main
                           	LEFT JOIN mst_personal_user up ON up.user_id = ord_main.up_user_id
                           	AND up.facility_cd =:facility_cd
                           	LEFT JOIN mst_personal_user ind ON ind.user_id = ord_main.up_user_id
                           	AND ind.facility_cd =:facility_cd
                           		LEFT JOIN medi_info medi ON medi.ord_no = ord_main.ord_no
                           	LEFT JOIN comment_info comment ON comment.ord_no = ord_main.ord_no
                           	LEFT JOIN equip_info equip ON equip.ord_no = ord_main.ord_no
                           	LEFT JOIN cond_info cond ON cond.ord_no = ord_main.ord_no
                           WHERE
                           	rst_dialysis_state = '6'
                           	AND ord_main.facility_cd = :facility_cd
                           	AND ind_cond_info IS NOT NULL),  contentformap  as (     	
                           	select ord_no,json_build_array(treat_method,schedule,cond_json,ind_medi_info,ind_equip_info,ind_ind_comment_info) as content_for_map           
                           		from content_map)
					   update   pat_ind_approve set  content_for_map=cmap.content_for_map
						 FROM  contentformap  cmap	
				 		where	pat_ind_approve.content_for_map is  null and   pat_ind_approve.ord_no=cmap.ord_no
							and	pat_ind_approve.facility_cd=:facility_cd
								
				""");
        EventLogMessage eventLogMessage = new EventLogMessage();
        try {
            MapSqlParameterSource parameters = new MapSqlParameterSource()
                    .addValue("facility_cd", facilityCd);
            NamedParameterJdbcTemplate machineJdbcTemplate = new NamedParameterJdbcTemplate(convertDbDs);
            int count = machineJdbcTemplate.update(ind_Pat_Ind_Approve.toString(), parameters);
            //ログ
            eventLogMessage = eventLoggerUtil.getEventLogMessage(String.format("pat_ind_approve変更成功%d件", count),
                    facilityCd, "updateContentForMapControl()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        } catch (Exception e) {
            //ログ
            eventLogMessage = eventLoggerUtil.getEventLogMessage("pat_ind_approve変更に失敗しました！ " + e.getMessage(),
                    facilityCd, "updateContentForMapControl()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
        }
    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return stepBuilderFactory.get(STEP_NAME)
                .tasklet(this)
                .build();
    }
}
