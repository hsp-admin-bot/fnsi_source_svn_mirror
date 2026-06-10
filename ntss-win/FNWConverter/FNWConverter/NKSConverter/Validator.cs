using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Text.RegularExpressions;

namespace NKSConverter
{
    /// <summary>
    /// 値検証クラス
    /// </summary>
    public static class Validator
    {
        /// <summary>
        /// データグリッドビューが選択されているかチェック
        /// </summary>
        /// <returns></returns>
        public static bool CheckDataGridViewSelect(DataGridView dgv)
        {
            if (dgv.SelectedCells.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// 半角数値のチェック
        /// </summary>
        /// <param name="digit">桁数</param>
        /// <param name="target">対象</param>
        /// <returns></returns>
        public static bool CheckHalfWidthNumeric(int digit, string target)
        {
            string regular = "^[0-9]{" + digit.ToString() + "}$";
            if (!Regex.IsMatch(target, regular))
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// 半角数値のチェック
        /// </summary>
        /// <param name="digit">桁数</param>
        /// <param name="target">対象</param>
        /// <returns></returns>
        public static bool CheckHalfWidthAlphaNumeric(int digit, string target)
        {
            string regular = "^[a-zA-Z0-9]{" + digit.ToString() + "}$";
            if (!Regex.IsMatch(target, regular))
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// 半角数値のチェック
        /// </summary>
        /// <param name="target">対象</param>
        /// <returns></returns>
        public static bool CheckNumeric(string target)
        {
            string regular = "^[0-9]+$";
            if (!Regex.IsMatch(target, regular))
            {
                return false;
            }
            else
            {
                return true;
            }
        }
    }
}
