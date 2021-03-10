# anheiqishi25.github.io、eCharts

+ 页面框架可分为三大部分：上、下左、下右
  + 上：主要显示图标信息
  + 下左：按照无线技术分类，按照多选按钮形式可选，包括全选，全不选按钮：（NR/LTE/WCDMA/TDSCDMA/GSM/CDMA/LoRa/Zigbee/WiFi/Bluetooth等），
    + 当，选项为单选某一个无线技术时，下右显示其包含的具体无线信道。
  + 下右：展示每个无线技术的信道（N1/N2/N3……N78等）
+ json格式导入数据。
+ 按照整体与个体区分，比如NR所有频段可以重叠为一行与其他技术同框展示，单独的NR可以拆分每个频段展示。

'{ "sites" : [' +
	'{ "name":"Runoob" , "url":"www.runoob.com" },' +
	'{ "name":"Google" , "url":"www.google.com" },' +
	'{ "name":"Taobao" , "url":"www.taobao.com" } 
]}';

{
rat:[
{name:'NR',
 value[
 {name:Band1,
 duplex:'FDD',
 dlMin:345,
 dlMax:456,
 upMin:789,
 upMax:1011,},
 {name:Band2,
 duplex:'FDD',
 dlMin:345,
 dlMax:456,
 upMin:789,
 upMax:1011,},
 {name:Band3,
 duplex:'FDD',
 dlMin:345,
 dlMax:456,
 upMin:789,
 upMax:1011,},
 
 ]}
]

}