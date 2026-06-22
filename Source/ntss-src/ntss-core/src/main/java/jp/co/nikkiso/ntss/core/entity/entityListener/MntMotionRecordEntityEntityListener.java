package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecordEntity;
import lombok.NoArgsConstructor;
import org.seasar.doma.jdbc.entity.PreInsertContext;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * mnt_motion_record(装置動作記録)のエンティティリスナークラス.
 */
@Component
@NoArgsConstructor
public class MntMotionRecordEntityEntityListener extends AbstractEntityListener<MntMotionRecordEntity> {
  @Override
  public void preInsert(MntMotionRecordEntity mntMotionRecord, PreInsertContext<MntMotionRecordEntity> context) {
    LocalDateTime now = LocalDateTime.now(this.getTime());
    Timestamp currentDate = Timestamp.valueOf(now);
    mntMotionRecord.setRegDate(currentDate);
    mntMotionRecord.setUpDate(currentDate);
  }
}
