import {
  Answer,
  StatusText,
} from "@/constants/mainteConstants";

// 点検結果の値と表示文字列の対応テーブル
const StatusTextTable = Object.freeze([
  { key: Answer.NotDate, value: StatusText.NotDate },
  { key: Answer.Good, value: StatusText.Good },
  { key: Answer.Running, value: StatusText.Running },
  { key: Answer.NotGood, value: StatusText.NotGood },
]);

/**
 * @description 点検結果に対応する表示文字列を返す
 * @param {string | null} status 点検結果の値
 * @return {string} 表示文字列
 */
export const convertStatus = status => {
  if (status == Answer.NotDateForDb) {
    status = Answer.NotDate;
  }
  return StatusTextTable.find(item => item.key === status).value;
};
