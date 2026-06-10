/**
 * CommonPopoverFunctions.js は、処理対象を クラス名： disp_target_*
 * で判別する為、吹き出しを重ねて表示すると正常に処理対象が取得できません。
 * 対応として、別のクラス名を指定可能なこちらの function を利用してください。
 */
const targetClassList = {
  "splitGraph": "sg",
  "viewLog": "vl"
}

/**
 * v-ons-popover の preshowイベント用メソッド
 * 下記 postshow、popoverPosthide メソッドとセットで使用してください。
 * サイズ変更の為、吹き出しを一旦非表示にします。
 */
export const popoverPreShowOther = function(event) {
  // 吹き出しの▲部分を非表示にする
  const upTriObj = event.popover.getElementsByClassName("popover__arrow");
  if (upTriObj.length > 0) {
    upTriObj[0].style.display = "none";
  }
  // 吹き出しを非表示にする
  const popoverObj = event.popover.getElementsByClassName("popover");
  if (popoverObj.length > 0) {
    popoverObj[0].style.visibility = "hidden";
  }
};

/**
 * v-ons-popover の postshowイベント用メソッド
 * 下記 postshow、popoverPosthide メソッドとセットで使用してください。
 * preshow で、吹き出しが非表示になっていた場合に、画面サイズに応じて吹き出しのサイズ調整を行います。
 */
export const popoverPostShowOther = function(event, target) {
  const upTriObj = event.popover.getElementsByClassName("popover__arrow");
  const popoverObj = event.popover.getElementsByClassName("popover");
  const contentObj = event.popover.getElementsByClassName("popover__content");

  if (upTriObj.length > 0 && popoverObj.length > 0 && contentObj.length > 0) {

    if (popoverObj[0].style.visibility !== "hidden") {
      popoverObj[0].style.right = "";
      popoverObj[0].style.left = "";
      popoverObj[0].style.bottom = "";
      popoverObj[0].style.top = "";
      contentObj[0].style.width = "";
      contentObj[0].style.height = "";
      contentObj[0].style.maxHeight = "";
      upTriObj[0].style.display = "unset";
      upTriObj[0].classList.remove('disp_target_' + targetClassList[target] + '_parrow');
      popoverObj[0].classList.remove('disp_target_' + targetClassList[target] + '_p');
      contentObj[0].classList.remove('disp_target_' + targetClassList[target] + '_p_content');
    } else if (popoverObj[0].style.visibility === "hidden") {
      // リサイズ処理の為、要素判別用のclassを付与する
      upTriObj[0]?.classList?.add('disp_target_' + targetClassList[target] + '_parrow');
      popoverObj[0]?.classList?.add('disp_target_' + targetClassList[target] + '_p');
      contentObj[0]?.classList?.add('disp_target_' + targetClassList[target] + '_p_content');
      // 表示時初回リサイズ
      popoverResize();
      // Window resize イベント設定
      window.removeEventListener("resize",popoverEventResize);
      window.addEventListener("resize",popoverEventResize);
    }
  }
}

/**
 * v-ons-popover の posthideイベント用メソッド
 * 上記 preshow、postshow メソッドとセットで使用してください。
 * popoverPostShow でサイズ調整されたサイズ設定を初期化します。
 */
export const popoverPosthideOther = function(event, target) {
  // Window resize イベント解除
  window.removeEventListener("resize",popoverEventResize);
  if (!(event === undefined || event === null) && event.popover != null) {
    const upTriObj = event.popover.getElementsByClassName("popover__arrow");
    const popoverObj = event.popover.getElementsByClassName("popover");
    const contentObj = event.popover.getElementsByClassName("popover__content");
    if (upTriObj.length > 0 && popoverObj.length > 0 && contentObj.length > 0) {
      popoverObj[0].style.right = "";
      popoverObj[0].style.left = "";
      popoverObj[0].style.bottom = "";
      popoverObj[0].style.top = "";
      contentObj[0].style.width = "";
      contentObj[0].style.height = "";
      contentObj[0].style.maxHeight = "";
      upTriObj[0].style.display = "unset";
      upTriObj[0].classList.remove('disp_target_' + targetClassList[target] + '_parrow');
      popoverObj[0].classList.remove('disp_target_' + targetClassList[target] + '_p');
      contentObj[0].classList.remove('disp_target_' + targetClassList[target] + '_p_content');
    }
  }
}

/**
 * リサイズ処理のfunction
 */
const popoverResize = function(event) {
  // 全ての target に対して実施 (targetが存在しない場合はなにも実施されない)
  Object.keys(targetClassList).forEach(function (key) {
    const upTriObj = document.getElementsByClassName("disp_target_" + targetClassList[key] + "_parrow");
    const popoverObj = document.getElementsByClassName("disp_target_" + targetClassList[key] + "_p");
    const contentObj = document.getElementsByClassName("disp_target_" + targetClassList[key] + "_p_content");

    if (upTriObj.length > 0 && popoverObj.length > 0 && contentObj.length > 0) {
      // 表示方向を取得
      const upFlg = upTriObj[0].classList.contains('popover--bottom__arrow');
      const downFlg = upTriObj[0].classList.contains('popover--top__arrow');
      const leftFlg = upTriObj[0].classList.contains('popover--right__arrow');
      const rightFlg = upTriObj[0].classList.contains('popover--left__arrow');

      // 表示方向：left/right の場合
      if (leftFlg || rightFlg) {
        // 幅の調整
        let widthPx = 0;
        if (leftFlg) {
          widthPx = parseInt(popoverObj[0].style.right);
        } else {
          widthPx = parseInt(popoverObj[0].style.left);
        }
        if (isNaN(widthPx)) {
          widthPx = 0;
        }
        const freeSize = window.innerWidth - (widthPx + popoverObj[0].offsetWidth + 12);
        if (freeSize < 0 && widthPx > (freeSize * -1)) {
          // 位置変更だけで問題ない場合
          const tmpPx = widthPx - (freeSize * -1) + 6;
          if (leftFlg) {
            popoverObj[0].style.right = tmpPx + "px";
          } else {
            popoverObj[0].style.left = tmpPx + "px";
          }
          // 誤差10pxまでなら▲の表示を復帰させる
          if ((freeSize * -1) <= 10) {
            upTriObj[0].style.display = "";
          }
        } else if (freeSize < 0 && widthPx < (freeSize * -1)) {
          // 画面全体を使っても表示しきれない場合
          if (leftFlg) {
            popoverObj[0].style.right = "6px";
          } else {
            popoverObj[0].style.left = "6px";
          }
          contentObj[0].style.width = (window.innerWidth - 12) + "px";
        } else {
          upTriObj[0].style.display = "";
        }
        // 高さの調整
        if ((window.innerHeight - 12) <= popoverObj[0].offsetHeight) {
          contentObj[0].style.height = (window.innerHeight - 12) + "px";
        }
        popoverObj[0].style.visibility = "visible";
        return;
      }
      // 表示方向：top/buttom の場合
      if (upFlg || downFlg) {
        // 高さの調整
        let heightPx = 0;
        if (upFlg) {
          heightPx = parseInt(popoverObj[0].style.bottom);
        } else {
          heightPx = parseInt(popoverObj[0].style.top);
        }
        if (isNaN(heightPx)) {
          heightPx = 0;
        }
        const freeSize = window.innerHeight - (heightPx + popoverObj[0].offsetHeight + 12);
        if (freeSize < 0 && heightPx > (freeSize * -1)) {
          // 位置変更だけで問題ない場合
          const tmpPx = heightPx - (freeSize * -1) + 6;
          if (upFlg) {
            popoverObj[0].style.bottom = tmpPx + "px";
          } else {
            popoverObj[0].style.top = tmpPx + "px";
          }
          // contentObj に max-height を設定する (入力内容によっては下にサイズが広がる場合がある )
          contentObj[0].style.maxHeight = popoverObj[0].offsetHeight + "px";
          // 誤差10pxまでなら▲の表示を復帰させる
          if ((freeSize * -1) <= 10) {
            upTriObj[0].style.display = "";
          }
        } else if (freeSize < 0 && heightPx < (freeSize * -1)) {
          // 画面全体を使っても表示しきれない場合
          if (upFlg) {
            popoverObj[0].style.bottom = "6px";
          } else {
            popoverObj[0].style.top = "6px";
          }
          contentObj[0].style.height = (window.innerHeight - 12) + "px";
        } else {
          upTriObj[0].style.display = "";
          // contentObj に max-height を設定する (入力内容によっては下にサイズが広がる場合がある )
          contentObj[0].style.maxHeight = (window.innerHeight - 12 - heightPx) + "px";
        }
        // 幅の調整
        if ((window.innerWidth - 12) <= popoverObj[0].offsetWidth) {
          contentObj[0].style.width = (window.innerWidth - 12) + "px";
        }
        popoverObj[0].style.visibility = "visible";
      }
    }
  });
};

/**
 * リサイズ処理のfunction (Window resize イベント用)
 */
const popoverEventResize = function(event, target) {
  // v-ons-popover の処理とぶつかる為、遅延処理を入れる
  setTimeout(() => {
    const upTriObj = document.getElementsByClassName("disp_target_" + targetClassList[target] + "_parrow");
    const contentObj = document.getElementsByClassName("disp_target_" + targetClassList[target] + "_p_content");
    if (upTriObj.length > 0 && contentObj.length > 0) {
      contentObj[0].style.width = "";
      contentObj[0].style.height = "";
      upTriObj[0].style.display = "none";
    }
    popoverResize();
  }, 200);
};
