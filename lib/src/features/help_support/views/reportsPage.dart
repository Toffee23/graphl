import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/features/help_support/controllers/report_bug_controller.dart';
import 'package:vmodel/src/features/help_support/models/report_model.dart';
import 'package:vmodel/src/features/help_support/widgets/ticket_shimmer_screen.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  List<TicketModel> _ticketList = [];
  final refreshController = RefreshController();

  late final Debounce _debounce;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref.read(ticketProvider.notifier).fetchMoreData();
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);
    return ticketState.when(data: (tickets) {
      if (tickets.isNotEmpty)
        return Scaffold(
          appBar: VWidgetsAppBar(
            leadingIcon: VWidgetsBackButton(),
            appbarTitle: "Reports",
          ),
          body: ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                TicketModel _ticket = tickets[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Stack(
                    children: [
                      Card(
                        elevation: 2,
                        shadowColor: Theme.of(context).colorScheme.onSurface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ticket.subject,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              addVerticalSpacing(10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 7,
                                    child: Text(
                                      _ticket.issue,
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 15,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              // color: Theme.of(context).colorScheme.onBackground,
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(3)),
                          child: Text(
                            _ticket.status,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Theme.of(context).appBarTheme.backgroundColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
        );

      return Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: "Reports",
        ),
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            ref.invalidate(ticketProvider);
            refreshController.refreshCompleted();
          },
          child: Center(
            child: ListView(
              children: [
                addVerticalSpacing(300),
                Center(
                  child: Text(
                    "No tickets available..\nPull down to refresh",
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }, loading: () {
      return const TicketShimmerPage();
    }, error: (error, stackTrace) {
      //print("jkcnwe $error $stackTrace");
      return CustomErrorDialogWithScaffold(
        onTryAgain: () => ref.invalidate(ticketProvider),
        title: "Reports",
      );
    });
  }
}
