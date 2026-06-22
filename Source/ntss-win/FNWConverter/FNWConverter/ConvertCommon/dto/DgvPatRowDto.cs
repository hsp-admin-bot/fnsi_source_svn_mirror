
namespace ConvertCommon.Dto
{
  public class DgvPatRowDto
  {
    /// <summary>
    /// 移行元FNWテーブル名
    /// </summary>
    public string fnwTableName;

    /// <summary>
    /// 移行先次世代FNWテーブル名
    /// </summary>
    public string ntssTableName;

    public string type { get; set; }

    public string fkey { get; set; }
  }
}
