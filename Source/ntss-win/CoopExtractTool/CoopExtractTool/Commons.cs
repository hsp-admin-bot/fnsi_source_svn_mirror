namespace CoopExtractTool
{
    public static class Commons
    {
        /// <summary>
        /// このアプリケーションの名前
        /// </summary>
        public static string AppName;

        /// <summary>
        /// 戻り値：正常
        /// </summary>
        public const int RetCode_Success = 1;

        /// <summary>
        /// 戻り値：ファイルなし
        /// </summary>
        public const int RetCode_Nothing = 0;

        /// <summary>
        /// 戻り値：エラー
        /// </summary>
        public const int RetCode_Error = -1;
    }

}
