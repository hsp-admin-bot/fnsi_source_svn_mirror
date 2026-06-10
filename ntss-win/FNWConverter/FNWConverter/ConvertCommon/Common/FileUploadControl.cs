using System;
using System.Collections.Generic;
using System.Text;
using ConvertCommon.parts;
using ConvertCommon.dto;
using System.IO;


namespace ConvertCommon.Common
{

  public static class FileUploadControl
  {
    private static readonly Encoding encoding = Encoding.UTF8;
    public static string MultipartPostResquest(string postUrl, Dictionary<string, object> postParameters)
    {
      string boundary = String.Format("----------{0:N}", Guid.NewGuid());
      string contentType = "multipart/form-data; boundary=" + boundary;

      byte[] formData = CreateFormData(postParameters, boundary);

      return HttpControl.sendPostWebRequest(postUrl, contentType, formData, postParameters);
    }

    private static byte[] CreateFormData(Dictionary<string, object> postParameters, string boundary)
    {
      Stream formDataStream = new System.IO.MemoryStream();
      bool needsCLRF = false;

      foreach (var param in postParameters)
      {
        if (needsCLRF)
          formDataStream.Write(encoding.GetBytes("\r\n"), 0, encoding.GetByteCount("\r\n"));

        needsCLRF = true;

        if (param.Value is FilePropertyDto)
        {
            FilePropertyDto fileToUpload = (FilePropertyDto)param.Value;
            string header = string.Format("--{0}\r\nContent-Disposition: form-data; name=\"{1}\"; filename=\"{2}\"\r\nContent-Type: {3}\r\n\r\n",
                                          boundary,
                                          param.Key,
                                          fileToUpload.FileName ?? param.Key,
                                          fileToUpload.ContentType ?? "application/octet-stream");

            formDataStream.Write(encoding.GetBytes(header), 0, encoding.GetByteCount(header));
            formDataStream.Write(fileToUpload.File, 0, fileToUpload.File.Length);

        }
        else
        {
          string postData = string.Format("--{0}\r\nContent-Disposition: form-data; name=\"{1}\"\r\n\r\n{2}",
                                        boundary,
                                        param.Key,
                                        param.Value);
          formDataStream.Write(encoding.GetBytes(postData), 0, encoding.GetByteCount(postData));
        }
      }

      string footer = "\r\n--" + boundary + "--\r\n";
      formDataStream.Write(encoding.GetBytes(footer), 0, encoding.GetByteCount(footer));

      formDataStream.Position = 0;
      byte[] formData = new byte[formDataStream.Length];
      formDataStream.Read(formData, 0, formData.Length);
      formDataStream.Close();

      return formData;
    }
  }
}
