package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.springframework.http.HttpStatus;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.LongStream;

@Getter
@Setter
public class OrdMainForJournal {

  /**
   * for csv
   */
  List<String> csvList;

  /**
   * for journal
   */
  List<OrdMain> journalList;


  /* #10282 Create a new interface to synchronize processing progress. START */

  Integer errorCode = HttpStatus.OK.value();

  Float processing = 0.0f;

  /** タイマー */
  private Instant instantTimer;

  /** Time spent */
  List<Long> spentTime;

  /** The time interval for the next hop */
  private Long nextHBBlanking;

  /** Overall estimated time */
  private Long supposedTotalCost;

  /** Processing progress now */
  private int hasProcessedSize;

  /** The processing progress since the last screen request */
  private int lastProcessedCnt;

  private static float kpAvg = 3.1469f;
  private static float kqAvg = 1.0415f;

  private static Float SPEED_THRESHOLD = 0.75f;

  public OrdMainForJournal() {
    new OrdMainForJournal(0f);
  }

  public OrdMainForJournal(int n1Size, int n2Size, int n3Size) {
    n2Size = n2Size == 0 ? 1 : n2Size;
    n3Size = n3Size == 0 ? 1 : n3Size;
    // Calculate total amount
    long totalSize = n1Size + (long) n2Size * n3Size;
    // Inferred time unit ms
    this.supposedTotalCost = BigDecimal
      .valueOf(kpAvg * SPEED_THRESHOLD)
      .multiply(BigDecimal.valueOf(totalSize))
      .longValue();

    // Determine the average number of entries based on the order of magnitude of the total processing amount
    int spentCnt = (totalSize > 10000 || this.supposedTotalCost > 100000) ? 16 : 4;
    // Time per jump
    this.nextHBBlanking = this.supposedTotalCost / spentCnt;

    //　This is an arithmetic sequence of equal parts, used to compare actual running time to determine processing progress
    // And the duration of the first frame represents the unit time
    this.spentTime = LongStream.range(0, spentCnt)
      .map(i -> (i + 1) * this.nextHBBlanking)
      .boxed().toList();

    // 初始化?理?度
    this.hasProcessedSize = 0;
    this.lastProcessedCnt = 0;

    this.instantTimer = Instant.now();
  }

  public OrdMainForJournal(float f) {
    this.processing = f;
    this.instantTimer = Instant.now();
    this.spentTime = new ArrayList<>();
    this.spentTime.add(instantTimer.toEpochMilli());

  }

  /**
   * Update processing progress
   *
   * @param hasProcessedSize  Update processing progress
   */
  public void updateHasProcessedSize(int hasProcessedSize) {
//    if (hasProcessedSize != 0
//      && !CollectionUtils.isEmpty(this.spentTime)
//      && this.spentTime.size() == 4) {
//      this.hasProcessedSize = hasProcessedSize / 4;
//    } else {
//      this.hasProcessedSize = hasProcessedSize;
//    }
    this.hasProcessedSize = hasProcessedSize;
  }

  /**
   * Get current processing status
   *
   * @return  The duration of the next jump requires the screen to reassign
   *              the refresh rate of the progress based on that duration.
   */
  public OrdMainForJournal synchronizeProcessed() {
    // Determine whether there is a delay based on the difference between the current processing progress and the access progress
    int shortfall = this.hasProcessedSize - this.lastProcessedCnt;
    // Estimated time for unit progress
    long unitSpent = this.spentTime.get(0);

    unitSpent = unitSpent == 0 ? 1 : unitSpent;

    // Current progress estimated time
    long conjectureSpent = this.spentTime.get(this.hasProcessedSize <= 0 ? 0 : this.hasProcessedSize - 1);
    // Actual time spent
    long actualSpent = this.instantTimer.getEpochSecond() - Instant.now().getEpochSecond();
    // Adjusting the rate
    this.nextHBBlanking +=
      BigDecimal
        .valueOf(conjectureSpent - actualSpent)
        .divide(BigDecimal.valueOf(unitSpent), 2, RoundingMode.HALF_UP)
        .multiply(BigDecimal.valueOf(SPEED_THRESHOLD))
        .longValue();

    // If there is no progress yet, it means there has been a delay and further delays need to be made to meet the schedule for the next hop.
    if (shortfall == 0) {
      this.nextHBBlanking = BigDecimal
        .valueOf(this.nextHBBlanking)
        .divide(BigDecimal.valueOf(SPEED_THRESHOLD), 2, RoundingMode.HALF_UP)
        .longValue() ;
    }
    // Normal processing of next hop
    else if (shortfall == 1) {
      // Synchronize the progress
      this.lastProcessedCnt = this.hasProcessedSize;
    }
    // Perhaps the progress has been exceeded, and the speed needs to be further adjusted
    else {
      this.nextHBBlanking = BigDecimal
        .valueOf(this.nextHBBlanking)
        .multiply(BigDecimal.valueOf(SPEED_THRESHOLD))
        .longValue() ;
      // Synchronize the progress
      this.lastProcessedCnt = this.hasProcessedSize;
    }


    // Finally, make reasonable revisions
    if (this.nextHBBlanking < 0) {
      this.nextHBBlanking = (long) (42 * 10);   // Min 1000ms / 24Hz * 10Bit
    }

    if (this.nextHBBlanking > (long) (1000 * 10)) {
      this.nextHBBlanking = (long) (1000 * 10); // Max beat spent was 10s
    }

    return this;
  }

  /* #10282 Create a new interface to synchronize processing progress. END */
}
