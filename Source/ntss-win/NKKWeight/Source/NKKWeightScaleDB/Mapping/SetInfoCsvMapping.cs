using CsvHelper.Configuration;
using CsvHelper.TypeConversion;
using NKKWeightScaleDB.Models;

namespace NKKWeightScaleDB.Mapping
{
    public class SetInfoCsvMapping : ClassMap<Set_info>
    {
        public SetInfoCsvMapping()
        {
            NullableConverter longNullableConverter = new NullableConverter(typeof(long?), new TypeConverterCache());
            Map(item => item.patient_id).TypeConverter(longNullableConverter);
        }
    }
}