using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKWeightScaleApp.Commons
{
    public class Delegates
    {
        public delegate void SendMessage<T>(T t);
        public delegate void SendMessageList<T>(List<T> commonList);
        public delegate void FlagClose(bool flag);
    }
}
