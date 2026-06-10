using log4net;
using System;

namespace CoopSettingTool.Log
{
  public static class LogHelper
  {
    public static ILog Log;

    private static ILog _log
    {
      set
      {
        Log = value;
      }
      get
      {
        return Log;
      }
    }

    public static ILog CreateInstance()
    {
      _log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
      return _log;
    }

    public static ILog GetLogInstance()
    {
      if (_log == default(ILog))
      {
        CreateInstance();
      }
      return _log;
    }

    public static void LogDebug(object message)
    {
      _log.Debug(message);
    }

    public static void LogDebug(object message, Exception exception)
    {
      _log.Debug(message, exception);
    }

    public static void LogError(object message)
    {
      _log.Error(message);
    }

    public static void LogError(object message, Exception exception)
    {
      _log.Error(message, exception);
    }

    public static void LogInfo(object message)
    {
      _log.Info(message);
    }

    public static void LogInfo(object message, Exception exception)
    {
      _log.Info(message, exception);
    }

    public static void LogWarning(object message)
    {
      _log.Info(message);
    }

    public static void LogWarning(object message, Exception exception)
    {
      _log.Warn(message, exception);
    }
  }
}
