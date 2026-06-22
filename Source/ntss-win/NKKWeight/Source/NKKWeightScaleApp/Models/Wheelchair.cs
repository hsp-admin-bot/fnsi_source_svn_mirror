using NKKWeightScaleApp.Commons;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKWeightScaleApp.Models
{
    public class Wheelchair
    {
        public bool Selected { get; set; }
        public string WheelchairID { get; set; }
        public string WheelchairName { get; set; }
        private string weight;
        public string Weight {
            get
            {
                decimal.TryParse(weight, out decimal _weight);
                if (weight == string.Empty || weight == null || _weight > ConfigValue.MAX_VALUE || _weight < ConfigValue.MIN_VALUE)
                     weight = string.Empty;   
                else
                    weight=_weight.ToString("G29");
                return weight;
            }
            set
            {
                decimal.TryParse(value, out decimal _weight);
                if (value == string.Empty || value == null || (_weight/1000) > ConfigValue.MAX_VALUE || (_weight / 1000) < ConfigValue.MIN_VALUE)
                    weight = string.Empty;
                else
                    weight = _weight.ToString();
            }
        }
        private string weightDisplay;
        public string WeightDisplay
        {
            get
            {
                decimal.TryParse(Weight, out decimal _Weight);
                if (!string.IsNullOrEmpty(Weight))
                    weightDisplay = string.Format("{0}kg", _Weight);
                else
                    weightDisplay = string.Empty;
                return weightDisplay;
            }
        }
        public string OwnerPatient { get; set; }
    }
}
