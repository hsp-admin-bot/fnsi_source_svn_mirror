using System.Collections.Generic;
using FNSiViewSyncLogicLib.Models;
using Newtonsoft.Json;

namespace FNSiViewSyncLogicLib.Services
{
    public class DataService
    {
        public static string GetSendData(List<ViewTableInfo> viewTableInfoList, string host, int port, int syncMode, string jobKeyName)
        {
            var sendData = new SendData
            {
                host = host,
                port = port,
                SyncMode = syncMode,
                RegDate = viewTableInfoList[0].RegDate,
                tables = new List<ViewTable>()
            };

            foreach (ViewTableInfo tbl in viewTableInfoList)
            {
                sendData.tables.Add(new ViewTable
                {
                    tableName = tbl.TableName,
                    keyName = tbl.KeyName,
                    jobKeyName = jobKeyName,
                    sqlCodes = new List<string>(tbl.SqlCd.Split(',')),
                    isFirst = syncMode,
                    dataKey = new DataKey
                    {
                        fromDate = tbl.FromDate,
                        toDate = tbl.ToDate,
                        syncMode = tbl.Mode.ToLower(),
                        paramList1 = tbl.SplitAllItemModeData != null ? string.Join(",", tbl.SplitAllItemModeData) : null
                    }
                });
            }

            return JsonConvert.SerializeObject(sendData, Formatting.Indented);
        }

    }

}
