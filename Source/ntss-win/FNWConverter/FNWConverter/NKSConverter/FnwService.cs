using System;
using ConvertCommon;
using ConvertCommon.Common;

namespace NKSConverter
{
    public class FnwService

    {
        public FnwService()
        {
        }
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        public bool OnStart()
        {
            bool bret = true;

            try
            {
                ConvertBase.WriteTraceLog("定時起動処理開始");

                // 初期化
                ConvertForm cForm = new ConvertForm(ref bret);
                // 定時起動フロー設定
                if (bret)
                {
                    bret = cForm.makeSqlFlow();
                }

                // ログ記録：Start処理終了
                ConvertBase.WriteTraceLog("定時起動処理終了");
                //add
                CommonConfig.token = null;
                CommonConfig.LoginUrl = null;
                //add
            }
            catch (Exception ex)
            {

                bret = false;

                // ログ記録：エラー
                ConvertBase.WriteErrorLog(string.Format("Start処理,{0}", ex));
            }

            return (bret);
        }
    }
}
