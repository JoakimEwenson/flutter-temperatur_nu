import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:temperatur_nu/views/components/theme.dart';
import 'package:temperatur_nu/views/drawer.dart';

Future<PackageInfo> getPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  return packageInfo;
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Om appen'),
      ),
      drawer: AppDrawer(),
      body:
          LayoutBuilder(builder: (context, BoxConstraints viewportConstraints) {
        return FutureBuilder(
            future: getPackageInfo(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                PackageInfo packInfo = snapshot.data;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: viewportConstraints.maxHeight,
                    maxWidth: viewportConstraints.maxWidth,
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 25,
                      ),
                      Image.asset(
                        'icon/Solflinga.png',
                        height: 100,
                      ),
                      Text(
                        'temperatur.nu',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Version ${packInfo.version}',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      Text(
                        'build ${packInfo.buildNumber}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              appInfo,
                              SizedBox(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }

              return Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 25,
                    ),
                    CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    Text(
                      'Hämtar data',
                      style: Theme.of(context).textTheme.headline3,
                    )
                  ],
                ),
              );
            });
      }),
    );
  }
}
