using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Xml;
using FNSiViewSyncLogicLib.Common.Utilities;

namespace FNSiViewSyncLogicLib.Service
{
    public class XmlFileWatcher
    {
        private FileSystemWatcher watcher;
        private Dictionary<string, Dictionary<string, string>> previousValues = new Dictionary<string, Dictionary<string, string>>();
        private Thread watcherThread;

        public event EventHandler<XmlChangedEventArgs> XmlChanged;

        public XmlFileWatcher(string fileName)
        {
            string directoryPath = AppDomain.CurrentDomain.BaseDirectory;
            watcher = new FileSystemWatcher
            {
                Path = directoryPath,
                Filter = fileName,
                NotifyFilter = NotifyFilters.LastWrite
            };

            watcher.Changed += OnChanged;

            SaveInitialValues(Path.Combine(directoryPath, fileName));

            watcherThread = new Thread(StartWatching)
            {
                IsBackground = true
            };
            watcherThread.Start();

            Console.WriteLine("Started monitoring changes to " + Path.Combine(directoryPath, fileName));
        }

        private void StartWatching()
        {
            watcher.EnableRaisingEvents = true;
            while (true)
            {
                Thread.Sleep(1000); // 1秒待機
            }
        }

        private void OnChanged(object source, FileSystemEventArgs e)
        {
            CheckForUpdates(e.FullPath);
        }

        private void SaveInitialValues(string filePath)
        {
            try
            {
                XmlDocument doc = LoadXmlDocumentWithRetry(filePath);

                XmlNodeList views = doc.SelectNodes("//viewList/view");

                foreach (XmlNode view in views)
                {
                    string keyName = view.Attributes["key_name"].Value;
                    previousValues[keyName] = new Dictionary<string, string>();

                    foreach (XmlAttribute attribute in view.Attributes)
                    {
                        previousValues[keyName][attribute.Name] = attribute.Value;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving initial values: {ex.Message}");
            }
        }

        private void CheckForUpdates(string filePath)
        {
            try
            {
                bool flag = false;
                XmlDocument doc = LoadXmlDocumentWithRetry(filePath);

                XmlNodeList views = doc.SelectNodes("//viewList/view");

                foreach (XmlNode view in views)
                {
                    string keyName = view.Attributes["key_name"].Value;
                    if (!previousValues.ContainsKey(keyName))
                    {
                        Console.WriteLine($"New view added: {keyName}");
                        flag = true;
                        previousValues[keyName] = new Dictionary<string, string>();

                        foreach (XmlAttribute attribute in view.Attributes)
                        {
                            previousValues[keyName][attribute.Name] = attribute.Value;
                        }
                        continue;
                    }

                    foreach (XmlAttribute attribute in view.Attributes)
                    {
                        if (attribute.Name == "last_start_date" || attribute.Name == "last_end_date" || attribute.Name == "is_init" || attribute.Name == "once_flg")
                        {
                            continue;
                        }

                        if (previousValues[keyName].TryGetValue(attribute.Name, out string previousValue) && attribute.Value != previousValue)
                        {
                            Console.WriteLine($"Attribute '{attribute.Name}' of view '{keyName}' has been updated from '{previousValue}' to '{attribute.Value}'");
                            previousValues[keyName][attribute.Name] = attribute.Value;
                            flag = true;
                        }
                    }
                }
                if (flag)
                {
                    OnXmlChanged(new XmlChangedEventArgs());
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking for updates: {ex.Message}");
            }
        }

        private XmlDocument LoadXmlDocumentWithRetry(string filePath)
        {
            int retries = 5;
            int delay = 1000; // 1秒待機

            while (true)
            {
                try
                {
                    
                    return CommonUtil.LoadDecryptedXml(filePath);
                }
                catch (IOException ex)
                {
                    if (--retries == 0)
                        throw ex;

                    Console.WriteLine($"File is locked, retrying in {delay / 1000} seconds...");
                    Thread.Sleep(delay);
                }
            }
        }

        protected virtual void OnXmlChanged(XmlChangedEventArgs e)
        {
            XmlChanged?.Invoke(this, e);
        }
    }

    public class XmlChangedEventArgs : EventArgs
    {
        public XmlChangedEventArgs(){}
    }
}
