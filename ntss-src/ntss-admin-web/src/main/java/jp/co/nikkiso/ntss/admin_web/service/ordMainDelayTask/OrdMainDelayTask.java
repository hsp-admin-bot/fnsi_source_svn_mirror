package jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask;

import java.util.Date;
import java.util.concurrent.Delayed;
import java.util.concurrent.TimeUnit;
// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start

/*
* ordMain 遅延タスク
* */
public class OrdMainDelayTask implements Delayed {
  final private OrdMainJournalRequest data;
  final private long expire;

  /**
   * 遅延タスク
   *
   * @param data-{@link OrdMainJournalRequest}
   * @param expire-有効期限
   */
  public OrdMainDelayTask(OrdMainJournalRequest data, long expire) {
    super();
    this.data = data;

    this.expire = expire + System.currentTimeMillis();
  }

  public OrdMainJournalRequest getData() {
    return data;
  }

  public long getExpire() {
    return expire;
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof OrdMainDelayTask) {
      OrdMainJournalRequest taskData = ((OrdMainDelayTask) obj).getData();
      return taskData.getUri().equals(data.getUri()) &&
        taskData.getOrdNo().equals(data.getOrdNo()) &&
        taskData.getCrud().equals(data.getCrud());
    }
    return false;
  }

  @Override
  public String toString() {
    return "{" + "data:" + data.toString() + "," + "expire:" + new Date(expire) + "}";
  }

  @Override
  public long getDelay(TimeUnit unit) {
    return unit.convert(this.expire - System.currentTimeMillis(), unit);
  }

  @Override
  public int compareTo(Delayed o) {
    long delta = getDelay(TimeUnit.NANOSECONDS) - o.getDelay(TimeUnit.NANOSECONDS);
    return (int) delta;
  }
}
// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
