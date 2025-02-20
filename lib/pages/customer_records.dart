import 'package:deadlift/custom_widgets/CardV5responsive.dart';
import 'package:deadlift/custom_widgets/customSmsButton.dart';
import 'package:deadlift/custom_widgets/custom_filter_panel_widget.dart';
import 'package:deadlift/custom_widgets/custom_message_container.dart';
import 'package:deadlift/custom_widgets/deleteContianer.dart';
import 'package:deadlift/custom_widgets/message_container.dart';
import 'package:deadlift/custom_widgets/search_bar.dart';
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/pages/view_customer_dialog.dart';
import 'package:deadlift/pages/view_customer_sliding_window.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/style.dart';

class CustomerRecords extends StatefulWidget {
  const CustomerRecords({super.key});

  @override
  State<CustomerRecords> createState() => _CustomerRecords();
}

class _CustomerRecords extends State<CustomerRecords> {
  //* db related
  final DatabaseController dbController = Get.put(DatabaseController());
  //* db related
  //filters
  // bool isLoading = true;
  // bool activeFilter = false;
  // bool expiredFilter = false;
  // bool dueFilter = false;
  // bool inactiveFilter = false;
  String currentFilter = CustomerFilter.all;
  //filters
  //searching
  TextEditingController searchInput = TextEditingController();
  Timer? searchTimer;
  //searching
  double? customerCardWidth;
  int numColumns = 0;
  //multi selection
  bool multiCardSelect = false;
  List<String> multiSelectedIds = [];
  bool selectAllCheckBox = false;
  int numberOfCardsSelected = 0;
  //multi selection
  bool _customerSlidingWindowOpen = false;
  String editCustomerId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // Called when the page is removed from the navigation stack
    debugLog("Customer Records Page Disposed");
    searchInput.dispose();
    dbController.filter.value = CustomerFilter.all;
    currentFilter = CustomerFilter.all;
    super.dispose();
  }

  int totalCardsInCurrentPage = 0;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double customerListContainerWidth;
    double customerSlindingWindowWidth;
    totalCardsInCurrentPage = 0;
    if (_customerSlidingWindowOpen) {
      customerListContainerWidth = deviceWidth * 3 / 4;
      customerSlindingWindowWidth = deviceWidth - customerListContainerWidth;
    } else {
      customerListContainerWidth = deviceWidth;
      customerSlindingWindowWidth = 0;
    }
    customerCardWidth = setCustomerCardWidth(
        customerListContainerWidth, _customerSlidingWindowOpen);
    numColumns = (customerListContainerWidth / customerCardWidth!).floor();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Column(
                children: [
                  CustomSearchBar(
                    searchController: searchInput,
                    onChanged: (value) {
                      debugLog("In search bar onchanged function");
                      rebuildAfterTypingStops();
                    },
                    onTap: () {
                      debugLog("In search bar tap function");
                      _turnOffSlidingCustomerWindow();
                      setState(() {
                        turnOffMultiSelect();
                      });
                    },
                    onClear: () {
                      searchInput.clear();
                      dbController.searchText.value = "";
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //filters
                  Center(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: CustomFilterPanelWidget(
                          filterFunction: (newFilter) {
                            debugLog("filter is: $newFilter");
                            updateFilter(newFilter);
                            _turnOffSlidingCustomerWindow();
                          },
                        )),
                  ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          if (multiCardSelect)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          // showMultiDeleteContiner();
                          //Test below
                          await showDialog(
                              context: context,
                              builder: (context) => DeleteConfirmationDialog(
                                  multiCardSelect: multiCardSelect,
                                  multiSelectedIds: multiSelectedIds));
                          // debugLog("deleted:$deleted");
                          multiSelectedIds.clear();
                          multiCardSelect = false;
                          selectAllCheckBox = false;
                          numberOfCardsSelected = 0;
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.white,
                        )),
                    if (currentFilter == CustomerFilter.expired ||
                        currentFilter ==
                            CustomerFilter
                                .expiredToday) //display the message button only when the expired filter is selected
                      IconButton(
                          onPressed: () async {
                            debugLog("Current selected Ids${multiSelectedIds}");
                            debugLog(
                                "Number of cards selected${numberOfCardsSelected}");
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return multiMessageAlertDialog(
                                //     multiSelectedIds);
                                return MessageContainer(
                                  multiCardSelect: multiCardSelect,
                                  multiSelectedIds: multiSelectedIds,
                                );
                              },
                            );
                            multiSelectedIds.clear();
                            multiCardSelect = false;
                            selectAllCheckBox = false;
                            numberOfCardsSelected = 0;
                            debugLog("Current selected Ids${multiSelectedIds}");
                            debugLog(
                                "Number of cards selected${numberOfCardsSelected}");
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.message_outlined,
                            color: Colors.white,
                          )),
                    if (dbController.isAdmin.value &&
                        currentFilter == CustomerFilter.all)
                      CustomSmsButton(onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return multiMessageAlertDialog(
                            //     multiSelectedIds);
                            return CustomMessageContainer(
                                multiSelectedIds: multiSelectedIds);
                          },
                        );
                        multiSelectedIds.clear();
                        multiCardSelect = false;
                        selectAllCheckBox = false;
                        numberOfCardsSelected = 0;
                        setState(() {});
                      })
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Select all",
                      style: style4().copyWith(fontSize: 16),
                    ),
                    Checkbox(
                      shape: const CircleBorder(),
                      value: selectAllCheckBox,
                      onChanged: (value) {
                        selectAllCheckBox = !selectAllCheckBox;
                        multiSelectedIds.clear();
                        numberOfCardsSelected = 0;
                        if (!selectAllCheckBox) {
                          multiCardSelect = false;
                        }
                        setState(() {});
                      },
                      side: BorderSide(color: Colors.grey.shade400, width: 1),
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                    ),
                  ],
                )
              ],
            ),
          //! db accessed here
          Expanded(
              flex: 13,
              child: Row(
                children: [
                  // if (_customerSlidingWindowOpen)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _customerSlidingWindowOpen
                        ? customerSlindingWindowWidth
                        : 0,
                    child: Container(
                      height: double.infinity,
                      child: editCustomerId.isNotEmpty
                          ? ViewCustomerWindow(
                              customerId: editCustomerId,
                              closeWindow: _turnOffSlidingCustomerWindow)
                          : const SizedBox(),
                    ),
                  ),
                  SizedBox(
                    // color: Colors.blue,
                    width: customerListContainerWidth - 40,
                    child: Obx(() {
                      debugLog(
                          "In obx customers page, current Filter: ${dbController.filter.value}");
                      // debugLog("Loading: ${dbController.isLoading.value}");
                      List<Map<String, dynamic>> filteredCustomerList =
                          dbController.FilteredCustomers();
                      if (dbController.isLoading.value) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.grey,
                        ));
                      } else if (dbController.customers.isEmpty) {
                        return Center(
                          child: Text(
                            "No Customers",
                            style: style2(),
                          ),
                        );
                      } else {
                        return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: numColumns, // Number of columns
                              crossAxisSpacing: 10, // Spacing between columns
                              // mainAxisSpacing: 0, // Spacing between rows
                              childAspectRatio: customerCardWidth! /
                                  90, // Width to height ratio
                            ),
                            itemCount: filteredCustomerList.length,
                            itemBuilder: (context, index) {
                              totalCardsInCurrentPage =
                                  filteredCustomerList.length;
                              return Column(
                                children: [
                                  CustomerCardV5(
                                      customerMap: filteredCustomerList[index],
                                      cardWidth: customerCardWidth,
                                      multiCardSelect: multiCardSelect,
                                      selectAll: selectAllCheckBox,
                                      // onDelete: showDeleteContainer,
                                      onEdit: editCustomer,
                                      onMessage: showMessageContainer,
                                      turnOnMultiCardSelectFunc:
                                          turnOnMultiCardSelectFunc,
                                      addIdToSelectedIdList: addIdToSelectedIds,
                                      removeIdFromSelectedIdList:
                                          removeIdFromSelectedIds,
                                      turnOffSelectAllCheckBox:
                                          turnOffSelectAllCheckBox,
                                      turnOnCustomerSlidingwindow:
                                          _turnOnSlidingCustomerWindow),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              );
                            });
                      }
                    }),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void _turnOffSlidingCustomerWindow() {
    if (_customerSlidingWindowOpen) {
      editCustomerId = "";
      setState(() {
        _customerSlidingWindowOpen = false;
      });
    }
  }

  void _turnOnSlidingCustomerWindow(String tappedOnCustomerId) {
    if (!_customerSlidingWindowOpen) {
      setState(() {
        editCustomerId = tappedOnCustomerId;
        _customerSlidingWindowOpen = true;
      });
    } else if (tappedOnCustomerId != editCustomerId) {
      setState(() {
        editCustomerId = tappedOnCustomerId;
      });
    }
  }

  void rebuildAfterTypingStops() {
    if (searchTimer?.isActive ?? false) searchTimer!.cancel();
    searchTimer = Timer(const Duration(milliseconds: 500), () {
      dbController.searchText.value = searchInput.text.trim();
      // setState(() {});
    });
  }

  void editCustomer(String selectedId) {
    showDialog(
      context: context,
      builder: (context) => ViewCustomerDialog(customerId: selectedId),
    );
  }

  void showMessageContainer(String currentPhoneNumber, String currentName,
      String dueAmount, String currentDate) async {
    // bool messageSent;
    await showDialog(
        context: context,
        builder: (context) => MessageContainer(
              multiCardSelect: false,
              messageName: currentName,
              messageNumber: currentPhoneNumber,
              dueAmount: dueAmount,
              dueDate: currentDate,
            ));
  }

  void turnOnMultiCardSelectFunc() {
    multiCardSelect = true;
    debugLog("multicardselect:$multiCardSelect");
    setState(() {});
  }

//we need to find a way to replace the 4 with total number of cards in the page
//one way is to set totalCardsInPage=0 in every setstate function
  void addIdToSelectedIds(String currentId) {
    debugLog("In add to selectd ids function");
    debugLog("total cards in page= $totalCardsInCurrentPage");
    if (numberOfCardsSelected < totalCardsInCurrentPage) {
      ++numberOfCardsSelected;
      multiSelectedIds.add(currentId);
      if (numberOfCardsSelected >= 1 &&
          numberOfCardsSelected == totalCardsInCurrentPage &&
          !selectAllCheckBox) {
        selectAllCheckBox = true;
        // multiSelectedIds.clear();
        // numberOfCardsSelected = 0;
        setState(() {});
      }
    }
    debugLog("Current selected Ids$multiSelectedIds");
    debugLog("Number of cards selected$numberOfCardsSelected}");
  }

  void removeIdFromSelectedIds(String currentId) {
    multiSelectedIds.remove(currentId);
    --numberOfCardsSelected;
    if (multiSelectedIds.isEmpty) {
      multiCardSelect = false;
      numberOfCardsSelected = 0;
      setState(() {});
    }
    debugLog("Current selected Ids${multiSelectedIds}");
    debugLog("Number of cards selected ${numberOfCardsSelected}");
  }

  void turnOffSelectAllCheckBox() {
    selectAllCheckBox = false;
    setState(() {});
  }

  void updateFilter(String newFilter) {
    setState(() {
      currentFilter = newFilter;
      dbController.filter.value = currentFilter;
      turnOffMultiSelect();
    });
  }

  void turnOffMultiSelect() {
    multiSelectedIds.clear();
    multiCardSelect = false;
    selectAllCheckBox = false;
    numberOfCardsSelected = 0;
  }

  double setCustomerCardWidth(
      double customerListContainerWidth, bool customerSlidingwindowEnabled) {
    //multi card select devicewidth-96
    debugLog("In set card width function");
    double cardWidth;
    if (customerListContainerWidth >= 600) {
      if (!customerSlidingwindowEnabled) {
        cardWidth = customerListContainerWidth / 4 - 48;
      } else {
        cardWidth = customerListContainerWidth * 3 / 8 - 48;
      }
    } else {
      cardWidth = customerListContainerWidth - 48;
    }
    debugLog("card width:$cardWidth");
    return cardWidth;
  }
}
