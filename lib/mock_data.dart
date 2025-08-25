import 'models.dart';
final mockProviders = <ProviderProfile>[
  ProviderProfile(id:"p1",name:"Clean&Shine Kft.",services:["apartment_cleaning","general_cleaning","deep_cleaning","post_renovation"],
    districts:[5,6,7,8,9,13],allBudapest:false,ratingAvg:4.8,ratingCount:126,avgResponse:Duration(minutes:18)),
  ProviderProfile(id:"p2",name:"Villám Villany Bt.",services:["electricity","maintenance"],districts:[],allBudapest:true,ratingAvg:4.6,ratingCount:64,avgResponse:Duration(minutes:25)),
  ProviderProfile(id:"p3",name:"ProPlumb Zrt.",services:["plumbing","gas","maintenance"],districts:[1,2,3,11,12,22],allBudapest:false,ratingAvg:4.7,ratingCount:88,avgResponse:Duration(minutes:35),negativePoints:6),
  ProviderProfile(id:"p10",name:"Electric Pro",services:["electricity"],districts:[],allBudapest:true,ratingAvg:4.1,ratingCount:12,avgResponse:Duration(minutes:44),oneStarCount:5),
];
bool providerCoversDistrict(ProviderProfile p,int d)=>p.allBudapest||p.districts.contains(d);
List<ProviderProfile> filterProviders(String serviceId,int district){
  final list=mockProviders.where((p)=>p.services.contains(serviceId)&&providerCoversDistrict(p,district)&&!p.isSuspended).toList();
  list.sort((a,b){ final cmp=a.avgResponse.inMinutes.compareTo(b.avgResponse.inMinutes); if(cmp!=0)return cmp; return b.ratingAvg.compareTo(a.ratingAvg);});
  return list;
}
