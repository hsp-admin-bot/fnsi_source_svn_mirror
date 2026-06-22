
using System.Collections.Generic;

public static class CoopMemoUtil
{
    public static CoopDto Parse(string coopId, string memo,string FacilityCd, string ord_no,string patId)
    {
        var dto = new CoopDto
        {
            coop_cd = ConvertCoopId(coopId),
            ord_no = ConvertCoopOrdNo(coopId, ord_no, FacilityCd, memo, patId),
            memo = memo
        };

        if (string.IsNullOrEmpty(memo))
            return dto;

        if (coopId == "SCM04")
        {

            dto.sequence_no = memo;
        }
        else if (coopId == "SCM02") {
            // =========================
            // R（予約受付）
            // =========================
            if (memo.StartsWith("R"))
            {
                var parts = memo.Split('|');
                if (parts.Length > 5)
                {
                    dto.sequence_no = SafeSplit(parts[5], '#', 0);
                }
            }

            // =========================
            // T（処置）
            // =========================
            var tSeg = GetSegment(memo, "#T|");
            var t = Split(tSeg);

            var treatmentStaffCd = Get(t, 1);
            dto.treatment_user_id = BuildUserIdSql(treatmentStaffCd, FacilityCd);
            dto.treatment_send_day = Get(t, 2);
            dto.treatment_seq_no = SafeSplit(Get(t, 3), '#', 0);



            // =========================
            // I（注射）
            // =========================
            var iSeg = GetSegment(memo, "#I|");
            var i = Split(iSeg);
            var staffCd = Get(i, 1);
            dto.injection_user_id = BuildUserIdSql(staffCd, FacilityCd);
           
            dto.injection_send_day = Get(i, 2);
            dto.injection_seq_no = Get(i, 3);

            if (i != null && i.Length > 4)
            {
                for (int idx = 4; idx < i.Length; idx++)
                {
                    var item = i[idx];
                    if (string.IsNullOrEmpty(item) || item.Length < 6)
                        continue;

                    dto.item_list.Add(new ItemDto
                    {
                        rp_no = SafeSubstring(item, 0, 2),
                        medicine_no = SafeSubstring(item, 4, 2)
                    });
                }
            }

            // =========================
            // K（カルテ）
            // =========================
            var kSeg = GetSegment(memo, "#K|");
            var k = Split(kSeg);

            dto.medical_send_day = Get(k, 2);
            dto.medical_seq_no = Get(k, 3);

        }  

        return dto;
    }

    private static string BuildUserIdSql(string staffCd, string facilityCd)
    {
        if (string.IsNullOrWhiteSpace(staffCd))
            return null;

        return $"(select user_id from mst_personal_user where fn_staff_cd='{staffCd.Trim()}' and facility_cd='{facilityCd}')";
    }

    private static string GetSegment(string memo, string startKey)
    {
        int start = memo.IndexOf(startKey);
        if (start == -1) return null;

        int from = start + startKey.Length;
        int next = memo.IndexOf("#", from);

        return next == -1
            ? memo.Substring(from)
            : memo.Substring(from, next - from);
    }

    private static string[] Split(string input)
    {
        return string.IsNullOrEmpty(input) ? null : input.Split('|');
    }

    private static string Get(string[] arr, int index)
    {
        return (arr != null && arr.Length > index) ? arr[index] : null;
    }

    private static string SafeSplit(string input, char c, int index)
    {
        if (string.IsNullOrEmpty(input)) return null;
        var arr = input.Split(c);
        return arr.Length > index ? arr[index] : null;
    }

    private static string SafeSubstring(string input, int start, int length)
    {
        if (string.IsNullOrEmpty(input) || input.Length < start + length)
            return null;

        return input.Substring(start, length);
    }

    private static readonly Dictionary<string, string> CoopMap =
         new Dictionary<string, string>
     {
        { "SCM01", "profile" },
        { "SCM10", "profile" },
        { "SCM02", "ind_dial" },
        { "SCM03", "rst_dial" },
        { "SCM04", "accept" },
        { "SCM05", "exam_ord" },
        { "SCM06", "rad_ord" },
        { "SCM08", "karte_ord" },
        { "SCM09", "rep_dial" }
     };
    private static string ConvertCoopId(string coopId)
    {
        string value;
        return CoopMap.TryGetValue(coopId, out value) ? value : coopId;
    }

    private static string ConvertCoopOrdNo(string coopId,  string ordNo, string facilityCd, string memo,string patId)
    {

        string sql = "";
        if (string.IsNullOrEmpty(ordNo)) {
            return sql;
        }
        if (coopId.Equals("SCM03") || coopId.Equals("SCM04") || coopId.Equals("SCM09"))
        {
            int dialysisNo;
            if (!int.TryParse(ordNo, out dialysisNo))
            {
                return sql;
            }
            sql =   $"(select ord_no from ord_main where facility_cd='{facilityCd}' and rst_fn_dialysis_no={dialysisNo})";
        } else if (coopId.Equals("SCM02")) {

            string datePart = ordNo.Substring(0, 8);
            string fn_plural = ordNo.Substring(27, 1);
            sql = $"(select ord_no from ord_main where facility_cd='{facilityCd}' and fn_pat_id='{patId}' and treat_date='{datePart}'  and fn_plural='{fn_plural}')";
        }
        else if (coopId.Equals("SCM05")) {
            var keyInfo = ParseSpecificKey(ordNo, memo, "SCM05");
            if (keyInfo != null)
            { 
                sql = $"(SELECT em.exam_main_cd FROM pat_exam_main em JOIN LATERAL jsonb_array_elements(em.order_exam_set_info::jsonb) s(item) ON TRUE JOIN mst_exam_set es ON es.exam_set_cd = (s.item ->> 'set_cd')::bigint AND es.facility_cd = em.facility_cd WHERE em.fn_pat_id = '{keyInfo.FnPatId}' AND TO_CHAR(em.reg_exam_date,'YYYYMMDD') = '{keyInfo.RegExamDate}' AND em.reg_order_class = '{keyInfo.RegOrderClass}' AND es.fn_exam_set_cd = '{keyInfo.FnExamSetCd}' and em.exam_status='0' AND em.facility_cd = '{facilityCd}' LIMIT 1)";
            }
        } else if (coopId.Equals("SCM06")) {
            var keyInfo = ParseSpecificKey(ordNo, memo, "SCM06");
            if (keyInfo != null)
            {
                sql = $"(SELECT em.rad_result_cd FROM pat_rad_main em JOIN LATERAL jsonb_array_elements(em.order_rad_set_info::jsonb) s(item) ON TRUE JOIN mst_rad_set es ON es.rad_set_cd = (s.item ->> 'rad_set_cd')::bigint AND es.facility_cd = em.facility_cd WHERE em.fn_pat_id = '{keyInfo.FnPatId}' AND TO_CHAR(em.reg_rad_date,'YYYYMMDD') = '{keyInfo.RegExamDate}' AND em.reg_order_class = '{keyInfo.RegOrderClass}' AND es.fn_exam_set_cd = '{keyInfo.FnExamSetCd}' AND em.facility_cd = '{facilityCd}' LIMIT 1)";
            }
        }

        return sql;
    }
    public static ExamKeyInfo ParseSpecificKey(string specificKey, string memo,string coopId)
    {
        if (string.IsNullOrEmpty(specificKey))
        {
            return null;
        }

        string fnPatId = specificKey.Substring(0, 12);
        string regExamDate = specificKey.Substring(12, 8);
        int regOrderClass = int.Parse(specificKey.Substring(20, 1));

        // SCM06 特殊処理
        if ("SCM06".Equals(coopId)
            && regOrderClass != 2)
        {
            return null;
        }

        string fnExamSetCd;

        if (regOrderClass == 2)
        {
            fnExamSetCd = specificKey.Substring(specificKey.Length - 4);
        }
        else
        {
            int idx = memo.LastIndexOf('|');
            fnExamSetCd = idx >= 0
                ? memo.Substring(idx + 1)
                : string.Empty;
        }

        switch (regOrderClass)
        {
            case 0:
                regOrderClass = 1;
                break;
            case 1:
                regOrderClass = 2;
                break;
            case 2:
                regOrderClass = 0;
                break;
        };
        return new ExamKeyInfo
        {
            FnPatId = fnPatId,
            RegExamDate = regExamDate,
            RegOrderClass = regOrderClass,
            FnExamSetCd = fnExamSetCd
        };
    }
}



public class CoopDto
{
    public string coop_cd { get; set; }
    public string ord_no { get; set; }
    public string memo { get; set; }

    public string sequence_no { get; set; }

    public string treatment_user_id { get; set; }
    public string treatment_send_day { get; set; }
    public string treatment_seq_no { get; set; }

    public string injection_user_id { get; set; }
    public string injection_send_day { get; set; }
    public string injection_seq_no { get; set; }

    public string medical_send_day { get; set; }
    public string medical_seq_no { get; set; }

    public List<ItemDto> item_list { get; set; } = new List<ItemDto>();
}

public class ItemDto
{
    public string medicine_no { get; set; }
    public string rp_no { get; set; }
}

public class ExamKeyInfo
{
    public string FnPatId { get; set; }

    public string RegExamDate { get; set; }

    public int RegOrderClass { get; set; }

    public string FnExamSetCd { get; set; }
}