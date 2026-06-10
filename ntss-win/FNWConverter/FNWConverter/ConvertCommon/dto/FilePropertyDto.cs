using Newtonsoft.Json;


namespace ConvertCommon.dto
{
  public class FilePropertyDto
  {
    [JsonIgnore]
    public byte[] File { get; set; }
    public string FileName { get; set; }
    public string ContentType { get; set; }
    public FilePropertyDto(byte[] file) : this(file, null) { }
    public FilePropertyDto(byte[] file, string filename) : this(file, filename, null) { }
    public FilePropertyDto(byte[] file, string filename, string contenttype)
    {
      File = file;
      FileName = filename;
      ContentType = contenttype;
    }
  }
}
