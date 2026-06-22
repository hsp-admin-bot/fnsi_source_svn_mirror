using System;
using System.Net;
using System.Text;
using System.Threading;
using System.IO;
using System.Net.Sockets;
using NKKLoggingLib;

namespace FNSiViewSyncLogicLib.Services
{
    /// <summary>
    /// 外部からコマンドを受け取るリスナー
    /// </summary>
    public class ExternalCommandListener : IDisposable
    {
        private readonly TcpListener _listener;
        private readonly Action<string> _onCommand;
        private Thread _thread;
        private volatile bool _running;

        public ExternalCommandListener(int port, Action<string> onCommand)
        {
            _onCommand = onCommand ?? (_ => { });
            _listener = new TcpListener(IPAddress.Any, port);
        }

        public void Start()
        {
            if (_running) return;
            _running = true;

            _listener.Start();

            _thread = new Thread(ListenLoop)
            {
                IsBackground = true,
                Name = "ExternalCommandListener"
            };
            _thread.Start();
        }

        private void ListenLoop()
        {
            while (_running)
            {
                try
                {
                    var client = _listener.AcceptTcpClient();
                    using (var stream = client.GetStream())
                    using (var reader = new StreamReader(stream))
                    {
                        var command = reader.ReadLine();
                        if (!string.IsNullOrEmpty(command))
                        {
                            _onCommand(command);
                        }
                    }
                }
                catch {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "ListenLoop失敗");
                }
            }
        }

        public void Dispose()
        {
            _running = false;
            try { _listener.Stop(); } catch {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Dispose失敗");
            }
        }

        public void Stop()
        {
            _running = false;
            try { _listener.Stop(); } catch {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "Stop失敗");
            }
        }
    }

}
