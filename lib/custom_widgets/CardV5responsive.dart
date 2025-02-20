// ignore_for_file: file_names
import 'package:deadlift/database_helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:deadlift/style.dart';
import 'package:get/get.dart';
import 'package:deadlift/database_helper/getxController.dart';

// Convert the customerCard3 function into a StatefulWidget
class CustomerCardV5 extends StatefulWidget {
  final Map<String, dynamic>? customerMap;
  final double? cardWidth;
  final bool? multiCardSelect;
  final bool? selectAll;
  // final Function(String id, String fullName) onDelete;
  final Function(String id) onEdit;
  final Function(
          String phoneNumber, String fullName, String dueAmount, String duedate)
      onMessage;
  final Function() turnOnMultiCardSelectFunc;
  final Function(String currentId) addIdToSelectedIdList;
  final Function(String currentId) removeIdFromSelectedIdList;
  final Function() turnOffSelectAllCheckBox;
  final Function(String tappedOnCustomerId) turnOnCustomerSlidingwindow;
  const CustomerCardV5(
      {super.key,
      this.customerMap,
      this.cardWidth,
      this.multiCardSelect,
      this.selectAll,
      // required this.onDelete,
      required this.onEdit,
      required this.onMessage,
      required this.turnOnMultiCardSelectFunc,
      required this.addIdToSelectedIdList,
      required this.removeIdFromSelectedIdList,
      required this.turnOffSelectAllCheckBox,
      required this.turnOnCustomerSlidingwindow});

  @override
  CustomerCardState createState() => CustomerCardState();
}

class CustomerCardState extends State<CustomerCardV5> {
  final DatabaseController dbController = Get.put(DatabaseController());

  Color CardBackgroundColor = Color(0xff1c1c1c);
  bool currentCheckBoxValue = false;
  @override
  Widget build(BuildContext context) {
    int dueAmountInteger =
        int.parse(widget.customerMap![DatabaseHelper.columnDueAmount]);
    DateTime startDate = DateTime.now();
    DateTime endDate =
        DateTime.parse(widget.customerMap![DatabaseHelper.columnDueDate]!);
    Duration difference = endDate.difference(startDate);
    int differenceInDays = (difference.inHours / 24.0).ceil();
    if (!widget.multiCardSelect!) {
      currentCheckBoxValue = false;
    }
    if (widget.multiCardSelect! && widget.selectAll!) {
      currentCheckBoxValue = true;
      widget
          .addIdToSelectedIdList(widget.customerMap![DatabaseHelper.columnId]);
      // setState(() {});
    }
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      //!uncomment the below code to activate multi select
      onTap: () {
        if (!widget.multiCardSelect!) {
          if (dbController.isTablet.value) {
            widget.turnOnCustomerSlidingwindow(
                widget.customerMap![DatabaseHelper.columnId]);
          } else {
            widget.onEdit(widget.customerMap![DatabaseHelper.columnId]);
          }
        } else {
          setState(() {
            currentCheckBoxValue = !currentCheckBoxValue;
            if (currentCheckBoxValue) {
              widget.addIdToSelectedIdList(
                  widget.customerMap![DatabaseHelper.columnId]);
            } else {
              widget.removeIdFromSelectedIdList(
                  widget.customerMap![DatabaseHelper.columnId]);
              widget.turnOffSelectAllCheckBox();
            }
          });
        }
      },
      //!the blelow is commented due to fix a bug
      // onLongPress: () {
      //   if (!widget.multiCardSelect!) {
      //     // if sliding window is opened it will get closed on long tap
      //     widget.turnOffSelectAllCheckBox();
      //     widget.turnOnMultiCardSelectFunc();
      //     widget.addIdToSelectedIdList(
      //         widget.customerMap![DatabaseHelper.columnId]);
      //     currentCheckBoxValue = true;
      //     setState(() {});
      //   }
      // },
      //!comment above to hide the tapping shi
      child: Card(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          decoration: BoxDecoration(
            color: CardBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 72,
          width: widget.cardWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorOfCustomerStatus(
                        widget.customerMap![DatabaseHelper.columnStatus]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1, // Limits to a single line
                            widget.customerMap![DatabaseHelper.columnFullName],
                            style: style4(),
                          ),
                        ),
                        if (widget.multiCardSelect!)
                          SizedBox(
                            height: 20,
                            child: Checkbox(
                              shape: const CircleBorder(),
                              value: currentCheckBoxValue,
                              onChanged: (value) {
                                setState(() {
                                  currentCheckBoxValue = !currentCheckBoxValue;
                                  if (currentCheckBoxValue) {
                                    widget.addIdToSelectedIdList(widget
                                        .customerMap![DatabaseHelper.columnId]);
                                  } else {
                                    widget.removeIdFromSelectedIdList(widget
                                        .customerMap![DatabaseHelper.columnId]);
                                    widget.turnOffSelectAllCheckBox();
                                  }
                                });
                              },
                              side: BorderSide(
                                  color: Colors.grey.shade400, width: 1),
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                            ),
                          ),
                        // if ((widget.customerMap![DatabaseHelper.columnStatus] ==
                        //         CustomerStatus.expired) &&
                        //     !widget.multiCardSelect!)
                        //   SizedBox(
                        //     height: 20,
                        //     child: IconButton(
                        //         // iconSize: 20,
                        //         onPressed: () {
                        //           widget.onMessage(
                        //             widget.customerMap![
                        //                 DatabaseHelper.columnPhoneNumber],
                        //             widget.customerMap![
                        //                 DatabaseHelper.columnFullName],
                        //             // activeStatus,
                        //             widget.customerMap![
                        //                 DatabaseHelper.columnDueAmount],
                        //             "${endDate.day}/${endDate.month}/${endDate.year}",
                        //           );
                        //         },
                        //         icon: const Icon(
                        //           Icons.message_outlined,
                        //           color: Colors.grey,
                        //         )),
                        //   )
                      ],
                    ),
                    differenceInDays > 0
                        ? Text(
                            "$differenceInDays Day(s) left | Due: ₹$dueAmountInteger",
                            style: style3().copyWith(color: Colors.grey[400]),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            "${widget.customerMap![DatabaseHelper.columnStatus]} | Due: ₹$dueAmountInteger",
                            style: style3().copyWith(color: Colors.grey[400]),
                            overflow: TextOverflow.ellipsis,
                          )
                  ],
                ),
              ),
              if ((widget.customerMap![DatabaseHelper.columnStatus] ==
                      CustomerStatus.expired) &&
                  !widget.multiCardSelect!)
                SizedBox(
                  width: 45,
                  height: 40,
                  child: Center(
                    child: IconButton(
                        // iconSize: 20,
                        onPressed: () {
                          widget.onMessage(
                            widget
                                .customerMap![DatabaseHelper.columnPhoneNumber],
                            widget.customerMap![DatabaseHelper.columnFullName],
                            // activeStatus,
                            widget.customerMap![DatabaseHelper.columnDueAmount],
                            "${endDate.day}/${endDate.month}/${endDate.year}",
                          );
                        },
                        icon: const Icon(
                          Icons.message_outlined,
                          color: Colors.grey,
                        )),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  colorOfCustomerStatus(String status) {
    Color statusColor;
    if (status == CustomerStatus.active) {
      statusColor = activeCustomerColor;
    } else if (status == CustomerStatus.expired) {
      statusColor = expiredCustomerColor;
    } else {
      statusColor = inactiveCustomerColor;
    }
    return statusColor;
  }
}
