using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    public class ExcelUtility
    {
        #region メンバ列挙体定義

        /// <summary>
        /// セルのエラー値定義
        /// </summary>
        public enum EnumCVErr : Int32
        {
            /// <summary>
            /// #DIV/0!
            /// </summary>
            ErrDiv0 = -2146826281,
            /// <summary>
            /// #N/A
            /// </summary>
            ErrGettingData = -2146826245,
            /// <summary>
            /// #GETTING_DATA
            /// </summary>
            ErrNA = -2146826246,
            /// <summary>
            /// #NAME?
            /// </summary>
            ErrName = -2146826259,
            /// <summary>
            /// #NULL!
            /// </summary>
            ErrNull = -2146826288,
            /// <summary>
            /// #NUM!
            /// </summary>
            ErrNum = -2146826252,
            /// <summary>
            /// #REF!
            /// </summary>
            ErrRef = -2146826265,
            /// <summary>
            /// #VALUE!
            /// </summary>
            ErrValue = -2146826273
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 指定された値がエラー値かどうか確認します。
        /// </summary>
        /// <param name="aValue"></param>
        /// <returns></returns>
        public static Boolean IsXlCVErr(dynamic aValue) => (aValue) is Int32;

        /// <summary>
        /// 指定された値が指定されたエラー値かどうか確認します。
        /// </summary>
        /// <param name="aValue"></param>
        /// <param name="aError"></param>
        /// <returns></returns>
        public static Boolean IsEqualXlCVErr(dynamic aValue, EnumCVErr aError) => (aValue is Int32) && ((Int32)aValue == (Int32)aError);

        #endregion

    }
}
