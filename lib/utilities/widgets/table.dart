import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:m2/services/api_services/product_apis.dart';
import 'package:m2/services/state_management/cart/cart_data.dart';
import 'package:m2/utilities/utilities.dart';
import 'package:m2/utilities/widgets/widgets.dart';
import 'package:m2/views/account_view/orders_view.dart';
import 'package:provider/provider.dart';
// Show orders and product in a table

class BuildTableWidget extends StatelessWidget {
  const BuildTableWidget(
      {super.key,
      required this.size,
      required this.headers,
      required this.cells,
      this.onTap,
      this.urls,
      this.id});
  final List<String> headers; // Table headers
  final List<Map<String, dynamic>> cells; // Table cells
  final List<String>? urls; // on click divert to the url
  final List<String>? id; // id for api
  final Size size;
  final String? onTap; // On tap funtion of each row
  @override
  Widget build(BuildContext context) {
    int headerLength = 0;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: List.generate(
          cells.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: EdgeInsets.all(5),
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.containerColor,
              ),
              // decoration: BoxDecoration(
              //   color: const Color(0xffffffff),
              //   borderRadius: BorderRadius.circular(7.0),
              //   border: Border.all(width: 1.0, color: AppColors.dividerColor),
              // ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                //headers
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    headers.length,
                    (index) {
                      headerLength++;
                      return getCell(
                        title: headers[index],
                        isTitle: true,
                        context: context,
                        orderNo: '0',
                        index: 0,
                      );
                    },
                  ),
                ),

                // const SizedBox(height: 20),
                // Container(
                //     height: 1, width: 800, color: AppColors.dividerColor),
                const SizedBox(width: 10),

                //body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      cells[index]['list'].length,
                      (index2) => getCell(
                          orderNo: cells[index]['list'][0],
                          title: cells[index]['list'][index2],
                          onTap: urls != null &&
                                  cells[index]['list'][index2] == 'Download'
                              ? urls![index]
                              : onTap,
                          context: context,
                          id: id != null ? id![index] : null,
                          index: index),
                    ),
                    // if (index < cells.length - 1) const SizedBox(height: 20),
                    // if (index < cells.length - 1)
                    // Container(
                    //     height: 100, width: 800, color: AppColors.dividerColor),
                    // if (index < cells.length - 1) const SizedBox(height: 20),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }
}

onTapNavigate(BuildContext context, String orderNo, int index) {
  // TODO: orderDetails
  context.push(
    "/account/${OrdersView.route}/$orderNo",
  );
  // navigate(context, MyOrderDetailView.route, arguments: {'data': cells[index]['data'], 'orderNo': orderNo});
}

getCell({
  required String title,
  bool isTitle = false,
  String? onTap,
  required BuildContext context,
  String? id,
  required String orderNo,
  required int index,
}) {
  var cartData = Provider.of<CartData>(context, listen: false);
  return SizedBox(
    width: 150,
    child: title == 'Download' || title == 'View Items'
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  onTapNavigate(context, orderNo, index);
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    bottom: 1, // Space between underline and text
                  ),
                  decoration:
                      title == 'Download' || title == 'View Items' && !isTitle
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.0, // Underline thickness
                            )))
                          : null,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      color: isTitle
                          ? AppColors.fadedText
                          : title == 'Download' ||
                                  title == 'View Items' && !isTitle
                              ? AppColors.primaryColor
                              : AppColors.fadedText,
                    ),
                  ),
                ),
              ),
              Mutation(
                  options: MutationOptions(
                    document: gql(ProductApi.reorder),
                    onCompleted: (data) {
                      //print(data);
                      try {
                        if (data!['reorderItems']['userInputErrors'].isEmpty) {
                          cartData.putCartCount(data['reorderItems']['cart']
                                  ['total_quantity']
                              .ceil());

                          // TODO: CartView
                          // navigate(context, Cart.route, arguments: {"page": 3});
                        } else {
                          for (var i in data['reorderItems']
                              ['userInputErrors']) {
                            showSnackBar(
                                context: context,
                                message: i['message'],
                                backgroundColor: Colors.red);
                          }
                        }
                      } catch (e) {
                        //print(e);
                      }
                    },
                  ),
                  builder: (runMutation, result) {
                    return InkWell(
                      onTap: () => runMutation({'orderNo': orderNo}),
                      child: Container(
                        padding: const EdgeInsets.only(
                          bottom: 1, // Space between underline and text
                        ),
                        decoration: title == 'Download' ||
                                title == 'View Items' && !isTitle
                            ? BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                color: AppColors.primaryColor,
                                width: 1.0, // Underline thickness
                              )))
                            : null,
                        child: result!.isLoading
                            ? BuildLoadingWidget(
                                color: AppColors.primaryColor, size: 20)
                            : Text(
                                'Re-order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w500,
                                  color: isTitle
                                      ? AppColors.fadedText
                                      : title == 'Download' ||
                                              title == 'View Items' && !isTitle
                                          ? AppColors.primaryColor
                                          : AppColors.fadedText,
                                ),
                              ),
                      ),
                    );
                  }),
            ],
          )
        : Container(
            padding: const EdgeInsets.only(
              bottom: 1, // Space between underline and text
            ),
            decoration: title == 'Download' || title == 'View Items' && !isTitle
                ? BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.0, // Underline thickness
                  )))
                : null,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: isTitle
                    ? AppColors.fadedText
                    : title == 'Download' || title == 'View Items' && !isTitle
                        ? AppColors.primaryColor
                        : AppColors.fadedText,
              ),
            ),
          ),
  );
}
