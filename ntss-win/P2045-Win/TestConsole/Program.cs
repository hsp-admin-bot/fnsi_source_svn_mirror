using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestConsole
{
    class Program
    {
        static async Task Main(string[] args)
        {
            //await Download("Dialysis_20190624213145_Excel.zip");
            //await Download("dialysisReport.zip");
            await Download("Dialysis_20190705133819_Report.zip");
        }

        /// <summary>
        /// 指定されたファイルをS3からダウンロードする
        /// </summary>
        /// <param name="fileName">ファイル名</param>
        /// <returns>非同期Task</returns>
        private static async Task Download(string fileName)
        {
            System.Net.Http.HttpResponseMessage response;
            System.Net.ServicePointManager.SecurityProtocol |= System.Net.SecurityProtocolType.Tls12;

            // ファイルダウンロード要求をPOSTする
            using (System.Net.Http.HttpClient httpClient = new System.Net.Http.HttpClient())
            {
                // Limit the max buffer size for the response so we don't get overwhelmed
                //const string bucket = "ntss-s3-root/report/999900";
                //const string bucket = "ntss-esm";
                const string bucket = "ntss-s3-root/Report/999900";
                System.Net.Http.StringContent content = new System.Net.Http.StringContent(
                    $"{{\"filename\": \"{fileName}\",\"bucket\": \"s3://{bucket}\"}}",
                    Encoding.UTF8, "application/json");
                response = await httpClient.PostAsync("https://dev.nksfn.com/ntss-admin-web/api/motion_record/detail/gathering/download", content);
            }
            //_ = response.EnsureSuccessStatusCode();
            //string responseBodyAsText = await response.Content.ReadAsStringAsync();

            //// 文字列をバイト配列に変換して、ZIPファイルとして保存する
            //try
            //{
            //    string zipFilePath = $"{AppDomain.CurrentDomain.BaseDirectory}\\{fileName}";
            //    NKKPrintServer.NKKPrint.WriteToFile(responseBodyAsText, zipFilePath);
            //}
            //catch (Exception ex)
            //{
            //    Console.WriteLine(ex.Message);
            //}
            if (response.StatusCode == System.Net.HttpStatusCode.InternalServerError)
            {
                Console.WriteLine(response.ToString());
            }
            else
            {
                _ = response.EnsureSuccessStatusCode();
                string responseBodyAsText = await response.Content.ReadAsStringAsync();

                // 文字列をバイト配列に変換して、ZIPファイルとして保存する
                try
                {
                    string zipFilePath = $"{AppDomain.CurrentDomain.BaseDirectory}\\{fileName}";
                    NKKPrintServer.NKKPrint.WriteToFile(responseBodyAsText, zipFilePath);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }

            }

        }

    }
}
