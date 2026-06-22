using System;
using System.Xml;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// XML 設定ファイルの読み書きクラス（TdcLib.SystemSettingInfo の代替）
    ///
    /// 対象 XML 構造:
    ///   &lt;Settings&gt;
    ///     &lt;CommonSection&gt;
    ///       &lt;BaseUri&gt;...&lt;/BaseUri&gt;
    ///     &lt;/CommonSection&gt;
    ///   &lt;/Settings&gt;
    ///
    /// セクション指定は バックスラッシュ区切り: "Settings\CommonSection"
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    internal sealed class SimpleConfigReader
    {
        private static SimpleConfigReader _instance;
        private static readonly object _lock = new object();

        private XmlDocument _doc;
        private string _filePath;

        /// <summary>最後に発生したエラー（Load 失敗時に設定される）</summary>
        public Exception Error { get; private set; }

        private SimpleConfigReader() { }

        public static SimpleConfigReader GetInstance()
        {
            if (_instance == null)
                lock (_lock)
                    if (_instance == null)
                        _instance = new SimpleConfigReader();
            return _instance;
        }

        /// <summary>XML ファイルを読み込む。成功時 true を返す。</summary>
        public bool Load(string filePath)
        {
            try
            {
                _filePath = filePath;
                _doc = new XmlDocument();
                _doc.Load(filePath);
                Error = null;
                return true;
            }
            catch (Exception ex)
            {
                Error = ex;
                return false;
            }
        }

        /// <summary>
        /// 指定セクション/キーの値を返す。ノードが存在しない場合は defaultValue を返す。
        /// section = "Settings\CommonSection", key = "BaseUri"
        /// </summary>
        public string GetSingleLineValue(string section, string key, string defaultValue)
        {
            if (_doc == null) return defaultValue;
            try
            {
                string xpath = section.Replace('\\', '/') + "/" + key;
                var node = _doc.SelectSingleNode(xpath);
                if (node == null) return defaultValue;
                return node.InnerText ?? defaultValue;
            }
            catch
            {
                return defaultValue;
            }
        }

        /// <summary>指定セクション/キーの値を書き換える（Save を呼ぶまでファイルには反映しない）。</summary>
        public void SetValue(string section, string key, string value)
        {
            if (_doc == null) return;
            try
            {
                string xpath = section.Replace('\\', '/') + "/" + key;
                var node = _doc.SelectSingleNode(xpath);
                if (node != null) node.InnerText = value ?? string.Empty;
            }
            catch { }
        }

        /// <summary>変更内容をファイルに保存する。</summary>
        public void Save()
        {
            if (_doc == null || string.IsNullOrEmpty(_filePath)) return;
            _doc.Save(_filePath);
        }
    }
}
