using LDT.SERVICE.Models.Responses;
using System.Net;
using System.Threading.Tasks;

namespace LDT.SERVICE.Interfaces
{
  public interface IBaseHttpClient
  {
    CookieContainer Cookies { get; }

    Task<BaseResponse<T>> GetAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json");

    Task<BaseResponse<T>> PostAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json");

    Task<BaseResponse<T>> DeleteAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json");

    Task<BaseResponse<T>> PutAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json");
  }
}
