package jp.co.nikkiso.ntss.core.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import java.util.function.Supplier;

/**
 * 関数化Bean定義ツール
 *
 * @param <T>
 * @author Tao.zhou
 * @since 2024-04-07
 */
public class BeanBuilderUtils<T> {

  // インスタンス
  private final Supplier<T> instantiations;

  // 修飾子リスト
  private final List<Consumer<T>> modifiers = new ArrayList<>();

  public BeanBuilderUtils(Supplier<T> instantiations) { this.instantiations = instantiations; }

  /** 単一例の静的コンストラクタ */
  public static <T> BeanBuilderUtils<T> of(Supplier<T> instantiations) {
    return new BeanBuilderUtils<>(instantiations);
  }

  /** 最後にBeanをBuild */
  public T build() {
    // Consumerとインスタンスを組み立てる
    T value = instantiations.get();
    modifiers.forEach(modifier -> modifier.accept(value));

    // 最後に今回使用したコンテナを空にする
    modifiers.clear();

    return value;
  }

  /** 1引数Consumer */
  @FunctionalInterface
  public interface ConsumerWithOneParam<T, P1> { void accept(T t, P1 p1); }

  /** 1引数Interface */
  public <P1> BeanBuilderUtils<T> with(ConsumerWithOneParam<T, P1> consumer, P1 p1) {
    // Bean定義Consumerを取得
    Consumer<T> c = instance -> consumer.accept(instance, p1);
    // 修飾子リストに追加Bean定義Consumer
    modifiers.add(c);

    return this;
  }

  /** 2引数Consumer */
  @FunctionalInterface
  public interface ConsumerWithTwoParam<T, P1, P2> { void accept(T t, P1 p1, P2 p2); }

  /** 2引数Interface */
  public <P1, P2> BeanBuilderUtils<T> with(ConsumerWithTwoParam<T, P1, P2> consumer, P1 p1, P2 p2) {
    Consumer<T> c = instance -> consumer.accept(instance, p1, p2);
    modifiers.add(c);

    return this;
  }
}
