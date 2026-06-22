package com.fnsi.cloudconverter.clear.online.pg;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.BadSqlGrammarException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class OnlinePgClearServiceImpl implements OnlinePgClearService {

    /** ntss_db5 対象テーブル */
    private static final List<String> CLEAR_TABLES_DB5 = List.of(
            "pat_group_detail", "ord_material_save", "ord_weight_scale", "ord_main",
            "pat_event", "pat_main", "pat_unique");

    /** ntss_db6 対象テーブル */
    private static final List<String> CLEAR_TABLES_DB6 = List.of(
            "pat_personal_main");

    @Autowired @Qualifier("onlineDefaultJdbc")  private JdbcTemplate onlineDefaultJdbc;
    @Autowired @Qualifier("onlinePersonalJdbc") private JdbcTemplate onlinePersonalJdbc;

    @Override
    public void clearFacilityData(List<String> facilityCodes) {
        clearTables(CLEAR_TABLES_DB5, onlineDefaultJdbc, facilityCodes);
        clearTables(CLEAR_TABLES_DB6, onlinePersonalJdbc, facilityCodes);
    }

    private void clearTables(List<String> tables, JdbcTemplate jdbc, List<String> facilityCodes) {
        String in = facilityCodes.stream().map(c -> "?").collect(Collectors.joining(","));
        Object[] params = facilityCodes.toArray();
        for (String table : tables) {
            try {
                int deleted = jdbc.update(
                        "DELETE FROM ntss.\"" + table + "\" WHERE facility_cd IN (" + in + ")", params);
                log.info("[CLEAR_ONLINE_PG] table={}, deleted={}", table, deleted);
            } catch (BadSqlGrammarException e) {
                log.debug("[CLEAR_ONLINE_PG] table={} は存在しないためスキップ", table);
            }
        }
    }
}
