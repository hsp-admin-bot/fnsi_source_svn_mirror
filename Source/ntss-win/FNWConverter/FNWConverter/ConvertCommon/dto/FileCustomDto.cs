

namespace ConvertCommon.dto
{
  public class FileCustomDto
  {
    public string filename { get; set; }
    public string fullpath { get; set; }
    public int index { get; set; }
    public override string ToString()
    {
      return index + " - " + this.filename;
    }
  }
}
