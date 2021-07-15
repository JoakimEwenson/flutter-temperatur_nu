import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/navbar_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class LicensesListPage extends StatefulWidget {
  const LicensesListPage({Key key}) : super(key: key);

  @override
  _LicensesListPageState createState() => _LicensesListPageState();
}

class _LicensesListPageState extends State<LicensesListPage> {
  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
      body: SafeArea(
        child: Container(
          child: FutureBuilder<List<LicenseEntry>>(
            future: LicenseRegistry.licenses.toList(),
            // initial data ...,
            builder: (BuildContext context,
                AsyncSnapshot<List<LicenseEntry>> snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Text(
                          'Applicenser',
                          style: pageTitle,
                        ),
                      ),
                      ...snapshot.data.map((element) {
                        LicenseEntryWithLineBreaks entry = element;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? tempCardDarkBackground
                                : tempCardLightBackground,
                            borderRadius:
                                BorderRadius.circular(cardBorderRadius),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.packages.first}',
                                style: cardTitle,
                              ),
                              Text(
                                '${entry.text}',
                                style: licenseText,
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
