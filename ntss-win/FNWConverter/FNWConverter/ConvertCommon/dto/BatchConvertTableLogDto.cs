using System;

namespace ConvertCommon.dto
{
  public class BatchConvertTableLogDto
  {
    public string table_name { get; set; }
    public string content { get; set; }

    public string _reg_date;
    // add ƒƒOo—ÍC³ —k start 
    public string order_no { get; set; }
    // add ƒƒOo—ÍC³ —k end 
    public string reg_date
    {
      get
      {
        // mod #10859-6 djy start
        //if (!string.IsNullOrEmpty(_reg_date))
        //{
        //mod 7338 “Aí start
        //return DateTime.Parse(_reg_date, null, System.Globalization.DateTimeStyles.RoundtripKind).ToString();
        //  DateTime dt = DateTime.Now;
        //  return dt.ToString("yyyy-MM-dd HH:mm:ss");
        //mod 7338@“Aí  end 
        //}
        //else
        //{
        //  return "";
        //}
        DateTime dateTime;
        if (DateTime.TryParse(_reg_date, out dateTime))
        {
            return dateTime.ToString("yyyy-MM-dd HH:mm:ss");
        }
        else
        {
            return "";
        }
        // mod #10859-6 djy end
      }
        set { this._reg_date = value; }
    }

    // add 7997 start 
    public string facility_cd { get; set; }
    // add 7997 end 
    }
}
