using System;
using System.Collections;
using System.Net;
using System.Reflection;

namespace LDT.SERVICE.Cookies
{
  public static class CookieManager
  {
    private static CookieContainer Cookies = new CookieContainer();

    public static void SetCookie(CookieContainer cookieContainer)
    {
      Cookies = cookieContainer;
    }

    public static CookieContainer GetCookies()
    {
      return Cookies;
    }

    public static string GetToken(string keyToken)
    {
      var result = "";
      var table = (Hashtable)Cookies.GetType().InvokeMember("m_domainTable",
        BindingFlags.NonPublic |
        BindingFlags.GetField |
        BindingFlags.Instance,
        null,
        Cookies,
        null);

      foreach (string key in table.Keys)
      {
        var item = table[key];
        var items = (ICollection)item.GetType().GetProperty("Values").GetGetMethod().Invoke(item, null);
        foreach (CookieCollection cc in items)
        {
          foreach (Cookie cookie in cc)
          {
            Console.WriteLine(cookie.Value);
            if (cookie.Name == keyToken)
            {
              result = cookie.Value;
              break;
            }
          }
        }
      }
      return result;
    }
  }
}
