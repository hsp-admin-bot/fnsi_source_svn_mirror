package jp.co.nikkiso.ntss.coop_api.telegram.helper;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * {@code SharedSysdateStore} は、電文生成におけるシステム日付のキャッシュ管理を行う
 * スレッドセーフなシングルトン・ユーティリティクラスです。
 * <p>
 * 各電文のルート名ごとにシステム日付を保持し、同一出力処理内での一貫性を保証します。
 * また、最終的なキャッシュ日時の取得、キャッシュクリア操作を提供します。
 * </p>
 *
 * <pre>
 * 使用例:
 *   SharedSysdateStore store = SharedSysdateStore.getInstance();
 *   LocalDateTime dateTime = store.getSysdate("rootName");
 * </pre>
 *
 */
public class SharedSysdateStore {

    public static record Key(String rootName, int rowIndex) {
    }

    /** スレッドセーフなシステム日付キャッシュ */
    private final Map<Key, LocalDateTime> cache;

    /** プライベートコンストラクタ（インスタンス化を防止） */
    public SharedSysdateStore() {
        this.cache = new ConcurrentHashMap<>();
    }

    /**
     * 指定ルート名のシステム日付を取得します。
     * キャッシュに存在しない場合、現在日時を生成・登録します。
     *
     * @param rootName 対象のルート名
     * @return 対応するシステム日付
     */
    public LocalDateTime getSysdate(Key key) {
        return cache.computeIfAbsent(key, k -> LocalDateTime.now());
    }

    /**
     * 指定ルート名と行インデックスに対してシステム日付を登録します。
     * <p>
     * 同一の {@code rootName} に対してすでに登録されている日時（秒単位）が
     * {@code sysdate} と同じかそれより後である場合、重複を避けるために
     * 登録する日時に +1 秒加算して調整します。
     * </p>
     *
     * <p>
     * このメソッドはマルチスレッド環境においても日時の一意性が保たれるよう
     * {@code synchronized} により排他制御されています。
     * </p>
     *
     * @param rootName 登録対象のルート名
     * @param rowIndex 行インデックス（ユニークキーの一部）
     * @param sysdate  登録するシステム日付（基準日時）
     */
    public void putSysdate(String rootName, int rowIndex, LocalDateTime sysdate) {
        synchronized (this) {
            // rootName に紐づく現在の日時の最大値を探す
            LocalDateTime latest = cache.entrySet().stream()
                    .filter(e -> e.getKey().rootName().equals(rootName))
                    .map(Map.Entry::getValue)
                    .max(LocalDateTime::compareTo)
                    .orElse(null);

            LocalDateTime adjusted;
            if (Objects.isNull(latest) || latest.truncatedTo(ChronoUnit.SECONDS).isBefore(sysdate.truncatedTo(ChronoUnit.SECONDS))) {
                adjusted = sysdate;
            } else {
                adjusted = latest.plusSeconds(1);
            }

            cache.put(new Key(rootName, rowIndex), adjusted);
        }
    }

    /**
     * キャッシュされているシステム日付のうち、最新の日時を取得します。
     * キャッシュが空の場合は {@code null} を返します。
     *
     * @return 最新のシステム日付、または {@code null}
     */
    public LocalDateTime getLatestCachedSysdate() {
        return cache.values().stream()
                .max(LocalDateTime::compareTo)
                .orElse(null);
    }

    /**
     * キャッシュをクリアします。
     * 全ルート名に紐づくシステム日付が削除されます。
     */
    public void clear() {
        cache.clear();
    }

    /**
     * スリープすべきミリ秒数を取得します。
     * 
     * <p>
     * 同じルート名のキャッシュが存在する場合、プログラム処理で1秒加算してシステム時刻を保存している。
     * そのため、同じルート名のキャッシュが存在する場合は、その数分のスリープが必要。
     * </p>
     * @return スリープすべきミリ秒数
     */
    public long getSleepMillis() {
        // key.rootName が一番多いものをカウント
        Map<String, Long> rootNameCount = cache.keySet().stream()
                .collect(Collectors.groupingBy(Key::rootName, Collectors.counting()));
        Optional<Long> maxCount = rootNameCount.values().stream()
                .max(Long::compareTo);
        return maxCount.orElse(0L) * 1000; // 秒単位をミリ秒に変換
    }

}
