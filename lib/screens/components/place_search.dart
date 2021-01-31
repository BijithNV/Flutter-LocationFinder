import 'package:flutter/material.dart';
import 'package:location_finder/bloc/bloc_provider.dart';
import 'package:location_finder/bloc/google_address_bloc.dart';
import 'package:location_finder/models/place.dart';
import 'package:location_finder/screens/components/place_list_view.dart';

class PlaceSearch extends StatefulWidget {
  final VoidCallback onPlaceSearchFocus;
  PlaceSearch({this.onPlaceSearchFocus});
  @override
  _PlaceSearchState createState() => _PlaceSearchState();
}

class _PlaceSearchState extends State<PlaceSearch> {
  TextEditingController txtcontroller = TextEditingController();
  bool _showListView = true;

  @override
  void initState() {
    super.initState();
    txtcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<GoogleAddressBloc>(context);
    return Column(children: [
      TextField(
        onTap: () {
          widget.onPlaceSearchFocus();
        },
        controller: txtcontroller,
        onChanged: (value) {
          if (value.isNotEmpty && value.contains(',')) {
            bloc.searchEventSink.add(value);
            _showListView = true;
          }
        },
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Enter Pincode, Street, City ",
            prefixIcon: Icon(Icons.search),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
      ),
      StreamBuilder<List<Place>>(
          stream: bloc.placeStream,
          initialData: null,
          builder: (context, snapshot) {
            if (_showListView && snapshot.hasData && snapshot.data.length > 0) {
              var places = snapshot.data;
              return PlaceListView(
                onAddressSelect: (selectedText) {
                  txtcontroller.clear();
                  txtcontroller.text = selectedText;
                },
                key: UniqueKey(),
                places: places,
              );
            }
            return Text('');
          })
    ]);
  }
}
