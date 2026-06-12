package com.fnsi.cloudconverter.job;

import com.fnsi.cloudconverter.common.exception.FacilityAlreadyLockedException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.List;

/**
 * 施設排他ロックサービス
 * PostgreSQL の SELECT FOR UPDATE NOWAIT で同一施設の重複実行を防止する
 * 参照: 05_key_tech.md § 8 / 04_database.md § 2.7
 */
@Slf4j
@Service
public class FacilityLockService {

    private final JdbcTemplate converterJdbc;

    public FacilityLockService(@Qualifier("converterJdbc") JdbcTemplate converterJdbc) {
        this.converterJdbc = converterJdbc;
    }

    /**
     * 施設ロックを取得する
     * ロック競合時は即座に FacilityAlreadyLockedException をスロー（NOWAIT）
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void acquireLock(List<String> facilityCodes, long jobId) {
        for (String facilityCode : facilityCodes) {
            try {
                // 行が存在しない場合は INSERT（競合時は何もしない）
                converterJdbc.update(
                        "INSERT INTO facility_lock (facility_cd) VALUES (?) ON CONFLICT DO NOTHING",
                        facilityCode);

                converterJdbc.queryForObject(
                        "SELECT facility_cd FROM facility_lock " +
                        "WHERE facility_cd = ? FOR UPDATE NOWAIT",
                        String.class, facilityCode);

                converterJdbc.update(
                        "UPDATE facility_lock SET locked_by = ?, locked_at = NOW() " +
                        "WHERE facility_cd = ?",
                        jobId, facilityCode);

                log.debug("[LOCK] 施設ロック取得: facilityCode={}, jobId={}", facilityCode, jobId);

            } catch (DataAccessException e) {
                if (isConcurrentLockError(e)) {
                    throw new FacilityAlreadyLockedException(facilityCode);
                }
                throw e;
            }
        }
    }

    /** ロック解放（JOB 完了/失敗時に呼ぶ） */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void releaseLock(List<String> facilityCodes) {
        for (String facilityCode : facilityCodes) {
            converterJdbc.update(
                    "UPDATE facility_lock SET locked_by = NULL, locked_at = NULL " +
                    "WHERE facility_cd = ?",
                    facilityCode);
            log.debug("[LOCK] 施設ロック解放: facilityCode={}", facilityCode);
        }
    }

    // PostgreSQL エラーコード 55P03: lock_not_available
    private boolean isConcurrentLockError(DataAccessException e) {
        Throwable cause = e.getCause();
        return cause instanceof SQLException sqle
               && "55P03".equals(sqle.getSQLState());
    }
}
