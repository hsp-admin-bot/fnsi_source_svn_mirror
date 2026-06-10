using System.Net.Http;

namespace LDT.SERVICE.Handler
{
  public class BaseHttpClientHandler : DelegatingHandler
  {
    public BaseHttpClientHandler(DelegatingHandler handler)
    {
      InnerHandler = handler;
    }
  }
}
