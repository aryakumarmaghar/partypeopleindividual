import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/SubscriptionModel.dart';
import 'package:http/http.dart' as http;

class SubscriptionController extends GetxController{


 SubscriptionModel subscriptionModel = SubscriptionModel(subsData: []);
 List<SubscriptionData> subsList = [];
 int subsOrderId = 0;
 RxBool isLoading = false.obs;

 @override
 void onInit(){
   super.onInit();
   getSubscriptionPlans();
 }
 
 Future<void> getSubscriptionPlans() async{
   try {
     isLoading.value = true;
     final response = await http.post(Uri.parse(
         'https://app.partypeople.in/v1/subscription/subscription_plan'),
       headers: <String, String>{
         'x-access-token': '${GetStorage().read('token')}',
       },);
     if (response.statusCode == 200) {
       Map<String, dynamic> jsonResponse = jsonDecode(response.body);
       print(jsonResponse);
       if (jsonResponse['status'] == 1 &&
           jsonResponse['message'].contains('Data Found')) {
         var data = SubscriptionModel.fromJson(jsonResponse);
         subscriptionModel = data;
         isLoading.value = false;
         update();

       }
     }
     else
       {
         log('subscription_plans api response is not 200');
       }
   }
   catch(e){
     log("$e");
   }
 }

 Future<String> subscriptionPurchase({required String subsId}) async{
   String value ='0';
   try {
     final response = await http.post(Uri.parse(
         'https://app.partypeople.in/v1/subscription/user_subscriptions_purchase'),
       headers: <String, String>{
         'x-access-token': '${GetStorage().read('token')}',
       },
       body: { 'subscription_id':subsId}
     );
     if (response.statusCode == 200) {

       Map<String, dynamic> jsonResponse = jsonDecode(response.body);
       print(jsonResponse);
       if (jsonResponse['status'] == 1 && jsonResponse['message'].contains(
           'Subscription plan puarchase successfully.')) {
         subsOrderId = jsonResponse['subscription_purchase_id'];
         update();
         value = '1';
       }
       else if (jsonResponse['status'] == 0 &&
           jsonResponse['message'].contains('')) {
         Get.snackbar('Error', '${jsonResponse['message']}');
         update();
         value = '0';
       }
       else {
         update();
      log('${jsonResponse['message']}');
         value ='0';
       }
     }
     else{
       log('subscription_purchase api response is not 200');
       value = '0';
     }
   }
   catch(e)
   {
     log("$e");
   }
   return value ;
 }

  Future<void> updateSubsPaymentStatus({required int subsId,required int paymentStatus,required String paymentResponse,required String paymentId}) async{
   try {
     log('$subsId  $paymentStatus $paymentResponse $paymentId');
     final response = await http.post(Uri.parse(
         'https://app.partypeople.in/v1/subscription/user_subscription_plan_status_update'),
         headers: <String, String>{
           'x-access-token': '${GetStorage().read('token')}',
         },
         body: { 'subscription_purchase_id':subsId?.toString(),
                  'payment_status':paymentStatus?.toString(),
                  'payment_response':paymentResponse?.toString(),
                  'payment_id' :paymentId?.toString()}
     );
     log('STATUS CODE :: ${response.statusCode}');
     if (response.statusCode == 200) {

       Map<String, dynamic> jsonResponse = jsonDecode(response.body);
       print(jsonResponse);

       if (jsonResponse['status'] == 1 && jsonResponse['message'].contains(
           'Your transaction successfully.')) {
         log('${jsonResponse['message']}');
         update();
         Get.snackbar("",'${jsonResponse['message']}' );
       }
       else {
         update();
         log('${jsonResponse['message']}');
       }
     }
     else{
       log('update subscription api response is not 200');
     }
   }
   catch(e)
   {
     log("dfgmhmgmgh $e");
   }
    }

}