
using System.Collections.Generic;


namespace ConvertCommon.parts
{
    public abstract class ConvertValueInfoBase
    {

        protected ConvertValueInfoBase()
        {
        }

        public virtual void AddConvertValueMap(string key, string oldValue, string newValue)
        {
        }

        public virtual string GetConvertValue(string key, string oldValue)
        {
            return "";
        }

        public virtual string GetConvertValue(string key, string oldValue,
            ConvertCommon.ConvertBase.NtssRecord record,
            List<ConvertCommon.ConvertBase.JsonElement> jsonElementList)
        {
            return "";
        }

        public virtual bool ContainsKey(string key)
        {
            return true;
        }


    }
}
