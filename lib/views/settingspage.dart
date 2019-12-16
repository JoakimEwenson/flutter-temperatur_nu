import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:temperatur.nu/views/drawer.dart';

Future<PackageInfo> getPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  return packageInfo;
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Om appen'),),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: getPackageInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            PackageInfo packInfo = snapshot.data;
            return Center(
              child: Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 25,),
                    Image.asset('icon/Solflinga.png', height: 100,),
                    Text('temperatur.nu', style: Theme.of(context).textTheme.display2,),
                    SizedBox(height: 25,),
                    Text('Version ' + packInfo.version + ' (build ' + packInfo.buildNumber + ')', style: Theme.of(context).textTheme.subtitle,),
                    //SizedBox(height: 10,),
                    //Text('https://www.ewenson.se', style: Theme.of(context).textTheme.body1),
                  ],
                )
              )
            );
          }

          return Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 25,),
                CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,),
                Text('Hämtar data', style: Theme.of(context).textTheme.display2,)
              ],
            ),
          );
        }
      ),
    );
  }
}