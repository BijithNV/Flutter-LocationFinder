import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_finder/bloc/bloc_provider.dart';
import 'package:location_finder/bloc/google_address_bloc.dart';
import 'package:location_finder/models/place.dart';
import 'package:location_finder/screens/components/map_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location_finder/screens/components/place_search.dart';

class LocationFinder extends StatefulWidget {
  final String _googleApiKey;
  final ValueChanged onConfirm;
  LocationFinder(this._googleApiKey, {this.onConfirm});

  @override
  _LocationFinderState createState() => _LocationFinderState();
}

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
PersistentBottomSheetController controller;
Place _selectedPlace;

class _LocationFinderState extends State<LocationFinder>
    with WidgetsBindingObserver {
  var initialLocation = LatLng(0, 0);
  var hasLocationAccess = false;
  var settingsAccessDialogDisplayed = false;
  var _googleServiceBloc;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _googleServiceBloc = GoogleAddressBloc(widget._googleApiKey);
    setInitialLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setInitialLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: BlocProvider<GoogleAddressBloc>(
            bloc: _googleServiceBloc,
            child: Scaffold(
              key: scaffoldKey,
              body: Stack(
                children: [
                  MapView(
                    key: UniqueKey(),
                    initialLocation: initialLocation,
                    onLocationMarked: (place) {
                      if (place != null) {
                        Future.delayed(const Duration(milliseconds: 2000), () {
                          _settingModalBottomSheet(context, place);
                        });
                      }
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 10, right: 10),
                    child: PlaceSearch(
                      onPlaceSearchFocus: () {
                        _closeModalBottomSheet();
                      },
                    ),
                  )
                ],
              ),
            )));
  }

  void _settingModalBottomSheet(context, Place place) {
    _selectedPlace = place;
    controller =
        scaffoldKey.currentState.showBottomSheet((BuildContext context) {
      return new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Please Tap on the map to mark precise location',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  color: Colors.green[300],
                  onPressed: () {
                    widget.onConfirm(_selectedPlace);
                  },
                  child: Text('Confirm'),
                ),
              )
            ],
          ));
    });
  }

  void _closeModalBottomSheet() {
    if (controller != null) {
      controller.close();
      controller = null;
    }
  }

  void setInitialLocation() {
    checkLocationAccessPermission().then((value) {
      if (!value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!settingsAccessDialogDisplayed) {
            displayLocationAccessRequestDialog(context);
            settingsAccessDialogDisplayed = true;
          }
        });
      } else {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((position) {
          setState(() {
            this.initialLocation =
                LatLng(position.latitude, position.longitude);
          });
        });
      }
    });
  }
}

Future<bool> checkLocationAccessPermission() async {
  final _permission = Permission.byValue(3);
  final _permissionStatus = await _permission.status;
  if (_permissionStatus == PermissionStatus.undetermined ||
      _permissionStatus == PermissionStatus.denied ||
      _permissionStatus == PermissionStatus.permanentlyDenied) {
    return false;
  }

  return true;
}

displayLocationAccessRequestDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'neighbourfarmer does not have access to your location.' +
                'To enable location access, tap settings and turn on location',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * .38,
                  child: FlatButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 60),
                  width: MediaQuery.of(context).size.width * .38,
                  child: FlatButton(
                    onPressed: () async {
                      Navigator.pop(context, false);
                      AppSettings.openAppSettings();
                    },
                    child: Text('Settings'),
                  ),
                )
              ],
            ),
          ],
        );
      });
}
