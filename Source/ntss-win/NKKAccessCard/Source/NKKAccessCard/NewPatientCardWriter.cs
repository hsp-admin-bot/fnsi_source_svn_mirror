using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using Newtonsoft.Json;

namespace NKKAccessCardLib
{
    public class NewPatientCardWriter
    {
	    private readonly Dictionary<string, int> _dictDecimalNumber = new Dictionary<string, int>();
	    
	    public NewPatientCardWriter()
	    {
		    _dictDecimalNumber.Add("weight_before", 2); // 前体重
		    _dictDecimalNumber.Add("weight_mea", 2); // 体重測定値
		    _dictDecimalNumber.Add("target_weight", 2); // 目標体重
		    _dictDecimalNumber.Add("water_info_weight_1", 2); // 除水補正値1 重量
		    _dictDecimalNumber.Add("water_info_weight_2", 2); // 除水補正値2 重量
		    _dictDecimalNumber.Add("water_info_weight_3", 2); // 除水補正値3 重量
		    _dictDecimalNumber.Add("water_info_weight_4", 2); // 除水補正値4 重量
		    _dictDecimalNumber.Add("water_info_weight_5", 2); // 除水補正値5 重量
		    _dictDecimalNumber.Add("ind_tare_info_weight_1", 2); // 風袋補正値1 重量
		    _dictDecimalNumber.Add("ind_tare_info_weight_2", 2); // 風袋補正値2 重量
		    _dictDecimalNumber.Add("ind_tare_info_weight_3", 2); // 風袋補正値3 重量
		    _dictDecimalNumber.Add("ind_tare_info_weight_4", 2); // 風袋補正値4 重量
		    _dictDecimalNumber.Add("ind_tare_info_weight_5", 2); // 風袋補正値5 重量
		    _dictDecimalNumber.Add("ind_cond_info_20", 1); // 補液量設定
		    _dictDecimalNumber.Add("d_24", 1); // 補液速度 
		    _dictDecimalNumber.Add("ind_cond_info_23", 2); // 補液温度
		    _dictDecimalNumber.Add("ind_cond_info_31", 1); // IPワンショット量
		    _dictDecimalNumber.Add("ind_cond_info_32", 1); // IP速度
		    _dictDecimalNumber.Add("ind_cond_info_18", 2); // 透析液温度
		    _dictDecimalNumber.Add("treat_condition_181", 2); // 除水速度操作範囲上限 
	    }
	    
        public byte[][] ConvertAllServiceData(IEnumerable<CardItemMeta> metas, string json)
        {
	        var cardResponse = ParseCardItemValues(json);
	        var service1Data = ConvertService1Data(cardResponse);
            var service2Data = ConvertService2Data(metas, cardResponse);
            return new [] { service1Data, service2Data };
        }

        private byte[] ConvertService1Data(CardResponse response)
        {
	        var serviceBytes = new byte[4 * 16];
	        
			{
				var cardCode = response.CardWriteValue.CardCd;
				if (string.IsNullOrEmpty(cardCode))
				{
					cardCode = string.Empty;
				}
				var cardCodeBytes = Encoding.UTF8.GetBytes(cardCode);
				Array.Copy(cardCodeBytes, 0, serviceBytes, 0, Math.Min(cardCodeBytes.Length, 12));
			}

			{
				var firstname = string.Empty;
				var lastname = string.Empty;
				
				if (!string.IsNullOrEmpty(response.CardWriteValue.Firstname))
				{
					var bytes = Convert.FromBase64String(response.CardWriteValue.Firstname);
					var decodedString = Encoding.UTF8.GetString(bytes);
					firstname = decodedString;
				}

				if (!string.IsNullOrEmpty(response.CardWriteValue.Lastname))
				{
					var bytes = Convert.FromBase64String(response.CardWriteValue.Lastname);
					var decodedString = Encoding.UTF8.GetString(bytes);
					lastname = decodedString;
				}
			
				var fullname = firstname + lastname;

				byte[] fullnameBytes;
				if (!string.IsNullOrEmpty(fullname))
				{
					// mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン start
					// fullname = Encoding.UTF8.GetBytes(strfullname);
					fullnameBytes = Encoding.GetEncoding("UNICODE").GetBytes(fullname);
					// mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン end
				}
				else
				{
					fullnameBytes = Encoding.UTF8.GetBytes(string.Empty);
				}
				
				Array.Copy(fullnameBytes, 0, serviceBytes, 16, Math.Min(fullname.Length, 40));
			}

			{
				byte[] birthdayBytes;
				if (!string.IsNullOrEmpty(response.CardWriteValue.Birthdate))
				{
					var birthdate = response.CardWriteValue.Birthdate;
					var yearNumber = ParseInt(birthdate.Substring(0, 4), "birthdate-year");
					var month = ParseInt(birthdate.Substring(4, 2), "birthdate-month");
					var day = ParseInt(birthdate.Substring(6, 2), "birthdate-day");
					var birthday = new DateTime(yearNumber, month, day);
					birthdayBytes = GetByteData(birthday);
				}
				else
				{
					var birthday = DateTime.Now.AddYears(-100);
					birthdayBytes = GetByteData(birthday);
				}
				
				Array.Copy(birthdayBytes, 0, serviceBytes, 16 + 40, Math.Min(birthdayBytes.Length, 4));
			}

			return serviceBytes;
        }
        
        public static byte[] ConvertService2Data(IEnumerable<CardItemMeta> metas, CardResponse cardResponse)
        {
            var bytes = new byte[144 * 16];
            foreach (var meta in metas.Where(meta => cardResponse.CardWriteValue.InfoDic.ContainsKey(meta.Name)))
            {
                var bytesValue = ConvertCardItemValueToBytes(meta, cardResponse.CardWriteValue.InfoDic[meta.Name]);
                Array.Copy(
                    sourceArray: bytesValue,
                    sourceIndex: 0,
                    destinationArray: bytes,
                    destinationIndex: meta.Block * 16 + meta.Offset,
                    length: bytesValue.Length
                );
            }
            
            return bytes;
        }

        private static byte[] ConvertCardItemValueToBytes(CardItemMeta meta, string value)
        {
            switch (meta.Spec.Type)
            {
                case "string":
                    return ConvertCardItemValueToStringBytes(meta, value);
                case "number":
                    return ConvertCardItemValueToNumberBytes(meta, value);
                default:
                    Console.WriteLine("Invalid card item value type." + meta.Spec.Type);
                    break;
            }

            return new byte[meta.Size];
        }

        private CardResponse ParseCardItemValues(string json)
        {
            var reader = new JsonTextReader(new StringReader(json));
            var cardResponse = JsonSerializer.CreateDefault().Deserialize<CardResponse>(reader);
            if (cardResponse.CardWriteValue == null)
            {
                cardResponse.CardWriteValue = new CardWriteValue();
            }
            var info = cardResponse.CardWriteValue.Info;
            if (string.IsNullOrWhiteSpace(info))
            {
                cardResponse.CardWriteValue.InfoDic = new Dictionary<string, string>();
            }
            else
            {
                reader = new JsonTextReader(new StringReader(info));
                cardResponse.CardWriteValue.InfoDic = JsonSerializer.CreateDefault().Deserialize<Dictionary<string, string>>(reader);
            }
            return cardResponse;
        }

        private static byte[] ConvertCardItemValueToStringBytes(CardItemMeta meta, string value)
        {
            return string.IsNullOrEmpty(value) ? new byte[meta.Size] : Encoding.GetEncoding("UNICODE").GetBytes(Encoding.UTF8.GetString(Convert.FromBase64String(value)));
        }

        private static byte[] ConvertCardItemValueToNumberBytes(CardItemMeta meta, string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return new byte[meta.Size];
            }
            value = FormatDecimalNumber(meta, value);
            switch (meta.Size)
            {
                case 1:
                    byte.TryParse(value, out var int8Val);
                    return BitConverter.GetBytes(int8Val);
                case 2:
                    ushort.TryParse(value, out var int16Val);
                    return BitConverter.GetBytes(int16Val);
                case 4:
                    uint.TryParse(value, out var int32Val);
                    return BitConverter.GetBytes(int32Val);
                case 8:
                    ulong.TryParse(value, out var int64Val);
                    return BitConverter.GetBytes(int64Val);
                default:
                    Console.WriteLine("Unsupported number size.");
                    break;
            }

            return new byte[meta.Size];
        }

        private static string FormatDecimalNumber(CardItemMeta meta, string value)
        {
            if (!double.TryParse(value, out var doubleVal))
            {
                doubleVal = 0;
            }
            if (meta.Spec.Range?.Length == 2)
            {
                var min = meta.Spec.Range[0];
                var max = meta.Spec.Range[1];

                if (doubleVal < (long)min)
                {
                    // doubleVal = (long) min;
                    return "";
                }

                if (doubleVal > (long) max)
                {
                    // doubleVal = (long) max;
                    return "";
                }
            }
            doubleVal = Math.Floor(doubleVal * Math.Pow(10, meta.Spec.Decimals));
            return doubleVal.ToString(CultureInfo.InvariantCulture);
        }
        
        private int ParseInt(string s, string name)
        {
	        try
	        {
		        return int.Parse(SetDecimalNumber(s, name));
	        }
	        catch (Exception e)
	        {
		        throw e;
	        }
        }

        private long ParseLong(string s, string name)
        {
	        try
	        {
		        return long.Parse(SetDecimalNumber(s, name));
	        }
	        catch (Exception e)
	        {
		        throw e;
	        }
        }
        
        private string SetDecimalNumber(string s, string name)
        {
	        if (_dictDecimalNumber.ContainsKey(name))
	        {
		        int keepDecimalLength = _dictDecimalNumber[name];
		        if (string.IsNullOrEmpty(s))
		        {
			        if (keepDecimalLength > 0)
			        {
				        string value = "0";
				        value = value.PadRight(value.Length + keepDecimalLength, '0');
				        return value;
			        }
			        else
			        {
				        return s;
			        }
		        }
		        else
		        {
			        string[] str = s.Split('.');
			        string para1 = str[0];
			        string para2 = "";
			        if (s.IndexOf('.') > 0)
			        {
				        para2 = str[1];
			        }

			        if (keepDecimalLength > 0)
			        {
				        para2 = para2.PadRight(para2.Length + keepDecimalLength, '0');
				        if (string.IsNullOrEmpty(para1))
				        {
					        para1 = "0";
				        }

				        string value = para1 + para2.Substring(0, keepDecimalLength);
				        return value;
			        }
			        else
			        {
				        return para1;
			        }
		        }
	        }
	        else
	        {
		        return s;
	        }
        }
        
        private static byte[] ShortToByte(short data)
        {
	        return new[]
	        {
		        (byte)(data >> 8),
		        (byte)data
	        };
        }
        
        private byte[] MakeByteArray(List<byte[]> byteList)
        {
	        var array = new byte[0];
	        if (byteList.Count <= 2) return array;
	        array = byteList[0].Concat(byteList[1]).ToArray();
	        for (var i = 2; i < byteList.Count; i++)
	        {
		        array = array.Concat(byteList[i]).ToArray();
	        }

	        return array;
        }
        
        private byte[] GetByteData(DateTime birthday)
        {
	        var list = new List<byte[]>();
	        short.TryParse(birthday.ToString("yyyy"), out var data);
	        list.Add(ShortToByte(data));
	        short.TryParse(birthday.ToString("MMdd"), out data);
	        list.Add(ShortToByte(data));
	        list.Add(new byte[4]);
	        return MakeByteArray(list);
        }
    }
}