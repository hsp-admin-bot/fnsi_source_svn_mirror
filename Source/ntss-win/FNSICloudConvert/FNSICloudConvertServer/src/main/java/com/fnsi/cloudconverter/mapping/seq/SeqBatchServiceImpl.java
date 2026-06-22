package com.fnsi.cloudconverter.mapping.seq;

import com.fnsi.cloudconverter.migration.pg.PgTableConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
public class SeqBatchServiceImpl implements SeqBatchService {

    /** ntss_db6 に対応するオンライン JDBC */
    private static final String DB6 = "ntss_db6";

    private final JdbcTemplate onlineDefaultJdbc;
    private final JdbcTemplate onlinePersonalJdbc;

    public SeqBatchServiceImpl(
            @Qualifier("onlineDefaultJdbc")  JdbcTemplate onlineDefaultJdbc,
            @Qualifier("onlinePersonalJdbc") JdbcTemplate onlinePersonalJdbc) {
        this.onlineDefaultJdbc  = onlineDefaultJdbc;
        this.onlinePersonalJdbc = onlinePersonalJdbc;
    }

    @Override
    public List<Long> fetchNextIds(PgTableConfig cfg, int count) {
        // db フィールドで ntss_db6 か否かを判定して適切な在線 JDBC を選択
        JdbcTemplate jdbc = DB6.equals(cfg.getDb()) ? onlinePersonalJdbc : onlineDefaultJdbc;

        // seqName 未指定の場合は {tableName}_{idColumn}_seq を自動導出
        String seqName = cfg.resolveSeqName();

        // シーケンスを実データの MAX に合わせてから nextval を呼ぶ
        // （手動 INSERT でシーケンスが実データより後れている場合の重複 PK を防止）
        try {
            String alignSql = "SELECT setval('ntss." + seqName + "', "
                    + "GREATEST((SELECT last_value FROM ntss." + seqName + "), "
                    + "(SELECT COALESCE(MAX(\"" + cfg.getIdColumn() + "\"), 0) FROM ntss.\""
                    + cfg.getName() + "\")))";
            Long aligned = jdbc.queryForObject(alignSql, Long.class);
            log.info("[SEQ] シーケンス整合: table={}, seq={}, aligned_to={}",
                    cfg.getName(), seqName, aligned);
        } catch (Exception e) {
            log.warn("[SEQ] シーケンス整合スキップ: table={}, seq={}, reason={}",
                    cfg.getName(), seqName, e.getMessage());
        }

        String sql = "SELECT nextval('ntss." + seqName + "') FROM generate_series(1, ?)";
        log.debug("[SEQ] シーケンス取得: table={}, seq={}, db={}, count={}",
                cfg.getName(), seqName, cfg.getDb(), count);
        List<Long> ids = jdbc.queryForList(sql, Long.class, count);
        log.debug("[SEQ] 取得完了: table={}, count={}", cfg.getName(), ids.size());
        return ids;
    }
}
