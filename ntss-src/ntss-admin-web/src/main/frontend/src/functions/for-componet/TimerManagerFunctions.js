/**
 * @description setTimeout制御用オブジェクトを生成する
 * コンポーネント内でwindow.setTimeoutを直接使用した場合に
 * コンポーネントのdestroy後にthisを参照する処理が実行されると
 * コンポーネントが破棄されずGC後も残るメモリリークになるようなので、
 * その対策してこのオブジェクトを経由してsetTimeoutを設定し、
 * beforeDestory時にこのオブジェクトのdestroyを呼ぶことで
 * その時点で残留しているsetTimeout処理をまとめてclearTimeoutすることができる
 * @returns {{
 *   setTimeout: (task: Function, delayMs: number) => number,
 *   destroy: () => void,
 * }} setTimeout制御用オブジェクト
 */
export const createTimerManager = () => {
  let timerIdMap = {};
  let manager = {};
  let setTimeout = (task, delayMs) => {
    if (!timerIdMap) return 0;
    const timerId = window.setTimeout(() => {
      delete timerIdMap[timerId];
      task();
    }, delayMs);
    timerIdMap[timerId] = timerId;
    return timerId;
  };
  let destroy = () => {
    if (!timerIdMap) return;
    Object.values(timerIdMap).forEach(timerId => window.clearTimeout(timerId));
    timerIdMap = null;
    delete manager.setTimeout;
    delete manager.destroy;
    manager = null;
  };
  manager.setTimeout = setTimeout;
  manager.destroy = destroy;
  setTimeout = null;
  destroy = null;
  return manager;
};
