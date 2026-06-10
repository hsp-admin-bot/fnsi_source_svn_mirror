using System;
using System.Collections.Generic;

namespace ConvertCommon.dto
{
    public class SyncConvertHistoryDto
    {
        public int seqNo;
        public String facilityCd;
        public String tableKind;
        public String tableName;
        public DateTime convertDatetime;
        public DateTime startDate;
        public DateTime endDate;
        public List<String> patidList;

        public String GetSqlWhereBlock(String periodColumnName,
                                        String patidColumnName)
        {
            return null;
        }
    }
}
