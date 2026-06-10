// マウスカーソルの位置がセルのハンドル領域にあるかを判定する関数
const inHandle = (mouseEvent, cell) => (
  mouseEvent.offsetX > cell.offsetWidth - 10
);

// style.widthが設定されていればその値から、
// そうでなければgetComputedStyleのwidthの値から
// 単位を無視して数値化した値を返す関数
// ※table全体のwidthも指定されているなどの理由で
// 　セルのstyle.widthに設定されている値と実際に表示される幅に
// 　乖離がある場合は幅変更処理が正常に動作しないためご注意ください
const getOrgWidth = cell => {
  if (cell.style.width) {
    const width = parseFloat(cell.style.width);
    if (!isNaN(width)) {
      return width;
    }
  }

  const result = parseFloat(getComputedStyle(cell).width);
  return isNaN(result) ? 0 : result;
}

// getComputedStyleのminWidthとmaxWidthの範囲に補正した値を返す
const getClippedWidth = (value, cell) => {
  const computedStyle = getComputedStyle(cell);
  const minWidth = parseFloat(computedStyle.minWidth);
  if (
    computedStyle.minWidth && !isNaN(minWidth)
    && value < minWidth
  ) {
    value = minWidth;
  }
  const maxWidth = parseFloat(computedStyle.maxWidth);
  if (
    computedStyle.maxWidth && !isNaN(maxWidth)
    && value > maxWidth
  ) {
    value = maxWidth;
  }
  return value;
}

/**
 * @typedef CellInfo セルごとの情報を持つオブジェクト型
 * @property {number} index セルのインデックス
 * @property {HTMLTableCellElement} cell セル要素
 * @property {function(MouseEvent) : void} onMouseMoveInner セルのMouseMoveイベントハンドラ
 * @property {function(MouseEvent) : void} onMouseDown セルのMouseDownイベントハンドラ
 * @property {number} orgX 幅リサイズ操作開始時のX座標
 * @property {number} orgWidth 幅リサイズ操作開始時のセル幅
 */
/**
 * @typedef ListenerOptions addColResizeListenersのオプション引数オブジェクト
 * @property {function(CellInfo) : void} [onStartResize] 幅リサイズ操作開始時のコールバック関数
 * @property {function(CellInfo) : void} [onWidthChanged] 幅リサイズ操作中の幅変更時のコールバック関数
 * @property {function(CellInfo) : void} [onFinishResize] 幅リサイズ操作終了時のコールバック関数
 */
/**
 * @typedef ListenerInfo 幅リサイズ対象セルの管理情報
 * @property {CellInfo[]} infoList セルごとの情報の配列
 * @property {CellInfo} draggingInfo 幅リサイズ操作中のセルの情報
 * @property {function(MouseEvent) : void} onMouseMove document要素のMouseMoveイベントハンドラ
 * @property {function() : void} onMouseUp document要素のMouseUpイベントハンドラ
 * @property {ListenerOptions} options addColResizeListenersのオプション引数オブジェクト
 */

/**
 * 右の縦罫線をドラッグする幅リサイズ処理を有効にしたいセル要素（td/th）に
 * マウスイベント処理を追加し、その管理情報を返す関数
 * @param {HTMLTableCellElement[] | HTMLCollection} cells セル要素の配列
 * @param {ListenerOptions} [options = {}] オプション引数オブジェクト
 * @returns {ListenerInfo} 幅リサイズ対象セルの管理情報（マウスイベント処理削除時に使用する）
 */
export const addColResizeListeners = (cells, options = {}) => {
  const infoList = [];
  const listenerInfo = {
    infoList,
    draggingInfo: null,
    onMouseMove: null,
    onMouseUp: null,
    options: options || {},
  };
  Array.from(cells).forEach((cell, index) => {
    const onMouseMoveInner = event => {
      // 幅リサイズ操作中の場合、もしくは
      // セルのハンドル領域にマウスカーソルがある場合はマウスカーソルを幅リサイズ用に切り替える
      cell.style.cursor = (
        (listenerInfo.draggingInfo?.cell === cell)
        || inHandle(event, cell)
      ) ? "col-resize" : "default";
    };
    cell.addEventListener("mousemove", onMouseMoveInner);

    const onMouseDown = event => {
      // セルのハンドル領域にマウスカーソルがない場合は処理対象外
      if (!inHandle(event, cell)) return;

      // 幅リサイズ対象のセルの管理情報を設定する
      const info = infoList[index];
      info.orgX = event.pageX;
      info.orgWidth = getOrgWidth(cell);
      listenerInfo.draggingInfo = info;

      // 幅リサイズ操作開始時のコールバックを呼ぶ
      if (listenerInfo.options.onStartResize) {
        listenerInfo.options.onStartResize(info);
      }
    };
    cell.addEventListener("mousedown", onMouseDown);

    infoList.push({
      index,
      cell,
      onMouseMoveInner,
      onMouseDown,
      orgX: 0,
      orgWidth: 0,
    });
  });

  listenerInfo.onMouseMove = event => {
    // 幅リサイズ操作中の情報がない場合は処理対象外
    if (!listenerInfo.draggingInfo) return;

    // セル幅のリサイズ処理
    const info = listenerInfo.draggingInfo;
    const diffX = event.pageX - info.orgX;
    const newWidth = getClippedWidth(info.orgWidth + diffX, info.cell);
    info.cell.style.width = `${newWidth}px`;

    // 幅リサイズ操作中の幅変更時のコールバックを呼ぶ
    if (listenerInfo.options.onWidthChanged) {
      listenerInfo.options.onWidthChanged(info);
    }
  };
  document.addEventListener("mousemove", listenerInfo.onMouseMove);

  listenerInfo.onMouseUp = () => {
    // 幅リサイズ操作中の情報がない場合は処理対象外
    if (!listenerInfo.draggingInfo) return;

    // 幅リサイズ操作中の情報をクリアする
    const info = listenerInfo.draggingInfo;
    listenerInfo.draggingInfo = null;

    // 幅リサイズ操作終了時のコールバックを呼ぶ
    if (listenerInfo.options.onFinishResize) {
      listenerInfo.options.onFinishResize(info);
    }
  }
  document.addEventListener("mouseup", listenerInfo.onMouseUp);

  return listenerInfo;
};

/**
 * addColResizeListenersで設定したイベントを削除し、参照関係をクリアする関数
 * @param {ListenerInfo} listenerInfo 幅リサイズ対象セルの管理情報（addColResizeListenersの戻り値）
 */
export const removeColResizeListeners = listenerInfo => {
  if (listenerInfo.options.onStartResize) {
    listenerInfo.options.onStartResize = null;
  }
  if (listenerInfo.options.onWidthChanged) {
    listenerInfo.options.onWidthChanged = null;
  }
  if (listenerInfo.options.onFinishResize) {
    listenerInfo.options.onFinishResize = null;
  }
  listenerInfo.options = null;

  document.removeEventListener("mousemove", listenerInfo.onMouseMove);
  listenerInfo.onMouseMove = null;
  document.removeEventListener("mouseup", listenerInfo.onMouseUp);
  listenerInfo.onMouseUp = null;

  listenerInfo.draggingInfo = null;

  listenerInfo.infoList.forEach(info => {
    info.cell.removeEventListener("mousemove", info.onMouseMoveInner);
    info.onMouseMoveInner = null;
    info.cell.removeEventListener("mousedown", info.onMouseDown);
    info.onMouseDown = null;
    info.cell = null;
  });
  listenerInfo.infoList = null;
};
