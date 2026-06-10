using System;
using System.Collections.Generic;
using System.Text;

namespace NKK.BloodPurify
{
    static public class IQ21Cmn
    {
        /// <summary>
        /// サイズ
        /// </summary>
        public const int DATA_SIZE = 38;
        /// <summary>
        /// モニタデータ 開始インデックス
        /// </summary>
        public const int MONI_START = 8;
        /// <summary>
        /// モニタデータ 終了インデックス
        /// </summary>
        public const int MONI_END = 32;

        /// <summary>
        /// 発生時刻
        /// </summary>
        public const int POP_TIME = 0;
        /// <summary>
        /// 治療経過時間
        /// </summary>
        public const int ELAPSED_TIME = 1;
        /// <summary>
        /// タイトル
        /// </summary>
        public const int TITLE = 2;
        /// <summary>
        /// 半角タイトル（ｼﾘﾝｼﾞ）
        /// </summary>
        public const int TITLE_HALF = 3;
        /// <summary>
        /// 行名１（流量）
        /// </summary>
        public const int TITLE_LINE1 = 4;
        /// <summary>
        /// タイトル行２（積算）
        /// </summary>
        public const int TITLE_LINE2 = 5;
        /// <summary>
        /// タイトル（下の行）
        /// </summary>
        public const int TITLE_SUB = 6;
        /// <summary>
        /// タイトル行３（圧力）
        /// </summary>
        public const int TITLE_LINE3 = 7;
        /// <summary>
        /// 除水速度(L/h)
        /// </summary>
        public const int RATE_WATER = 8;
        /// <summary>
        /// ろ過ポンプ流量(L/h)
        /// </summary>
        public const int RATE_FILTRATION = 9;
        /// <summary>
        /// 補液ポンプ流量(L/h)
        /// </summary>
        public const int RATE_REHYDRATION = 10;
        /// <summary>
        /// 透析液ポンプ流量(L/h)
        /// </summary>
        public const int RATE_DIALYSIS = 11;
        /// <summary>
        /// 血液ポンプ流量（mL/min)
        /// </summary>
        public const int RATE_BLOOD = 12;
        /// <summary>
        /// シリンジポンプ流量（mL/min)
        /// </summary>
        public const int RATE_SYRINGE = 13;
        /// <summary>
        /// 除水量積算(L)
        /// </summary>
        public const int TOTAL_WATER = 14;
        /// <summary>
        /// ろ過ポンプ積算値(L)
        /// </summary>
        public const int TOTAL_FILTRATION = 15;
        /// <summary>
        /// 補液ポンプ積算値(L)
        /// </summary>
        public const int TOTAL_REHYDRATION = 16;
        /// <summary>
        /// 透析液ポンプ積算値(L)
        /// </summary>
        public const int TOTAL_DIALYSIS = 17;
        /// <summary>
        /// 血液循環量(L)
        /// </summary>
        public const int TOTAL_BLOOD = 18;
        /// <summary>
        /// シリンジポンプ積算値（mL）
        /// </summary>
        public const int TOTAL_SYRINGE = 19;
        /// <summary>
        /// 採血圧
        /// </summary>
        public const int PRESS_BLOOD = 20;
        /// <summary>
        /// 動脈圧
        /// </summary>
        public const int PRESS_ARTERY = 21;
        /// <summary>
        /// 静脈圧
        /// </summary>
        public const int PRESS_VEIN = 22;
        /// <summary>
        /// ろ過圧
        /// </summary>
        public const int PRESS_FILTRATION = 23;
        /// <summary>
        /// TMP
        /// </summary>
        public const int TMP = 24;
        /// <summary>
        /// 分離ポンプ流量（mL/min)
        /// </summary>
        public const int RATE_SEPARATION = 25;
        /// <summary>
        /// 返漿ポンプ流量（mL/min)
        /// </summary>
        public const int RATE_PLASMA = 26;
        /// <summary>
        /// ドレンポンプ流量(L/h)
        /// </summary>
        public const int RATE_DORAIN = 27;
        /// <summary>
        /// 分離ポンプ積算値（L）
        /// </summary>
        public const int TOTAL_SEPARATION = 28;
        /// <summary>
        /// 返漿ポンプ積算値（L）
        /// </summary>
        public const int TOTAL_PLASMA = 29;
        /// <summary>
        /// ドレンポンプ積算値（L）
        /// </summary>
        public const int TOTAL_DORAIN = 30;
        /// <summary>
        /// 血漿圧
        /// </summary>
        public const int PRESS_PLASMA = 31;
        /// <summary>
        /// 血漿入口圧
        /// </summary>
        public const int PRESS_PLASMA_IN = 32;
        /// <summary>
        /// 操作結果１
        /// </summary>
        public const int CONTROL1 = 33;
        /// <summary>
        /// 操作結果２
        /// </summary>
        public const int CONTROL2 = 34;
        /// <summary>
        /// 設定流量
        /// </summary>
        public const int SETTING = 35;
        /// <summary>
        /// 設定流量単位
        /// </summary>
        public const int UNIT = 36;
        /// <summary>
        /// 警報・報知名
        /// </summary>
        public const int WARN = 37;
    }
}
