using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoopEventCreateOrStopTool
{
    public class ComboBoxItem
    {
        private string _text = null;
        private object _value = null;
        private object _kbn = null;
        public string Text { get { return this._text; } set { this._text = value; } }
        public object Value { get { return this._value; } set { this._value = value; } }
        public object Kbn { get { return this._kbn; } set { this._kbn = value; } }
        public override string ToString()
        {
            return this._text;
        }
    }
}
