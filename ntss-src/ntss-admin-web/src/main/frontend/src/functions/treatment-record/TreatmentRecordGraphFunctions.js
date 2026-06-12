/**
 * グラフの横軸の目盛数を取得.
 * 開始日時、終了日時が未指定の場合は0を返す.
 * 開始日時のみ指定されている場合は、6時間分の目盛数を返す.
 * 
 * @param {Date} startDate 治療開始日時
 * @param {Date} endDate 治療終了日時
 * @returns x軸の目盛数
 */
export const getXAxisRangeCount = (startDate, endDate) => {  
  // 初期値は6時間を30分で区切った場合の値
  // ※30分で区切った場合、360/30=12 だが、最後のメモリが含まれない為、
  //   +1 した値を設定する.
  let count = 13;
  // 治療開始日時、終了日時が未登録
  if (!startDate && !endDate) {
    return 0;
  }
  // 治療終了日時が未登録
  if (!endDate) {
    return count;
  }
  // 治療開始日時と終了日時の差を算出
  const diff = endDate.getTime() - startDate.getTime();
  // 差を分計算
  const diffMinutes = diff / (1000 * 60);          
  // 時間
  const hours = Math.floor(Math.abs(diffMinutes) / 60);
  // 30分間隔で表示する為、算出した時間を2倍する.
  count = (hours * 2) + 1;
  // 分
  const minutes = Math.abs(diffMinutes % 60);
  if (minutes > 30) {
    count = count + 2;
  } else if (minutes !== 0 && minutes <= 30) {
    count = count + 1;
  }
  return count;
}
