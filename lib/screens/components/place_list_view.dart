import 'package:flutter/material.dart';
import 'package:location_finder/bloc/bloc_provider.dart';
import 'package:location_finder/bloc/google_address_bloc.dart';
import 'package:location_finder/constants/location_finder_type_defs.dart';
import 'package:location_finder/models/place.dart';

class PlaceListView extends StatelessWidget {
  final List<Place> places;
  final PlaceListSelectionChangeEvent onAddressSelect;
  PlaceListView({Key key, this.places, this.onAddressSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: places.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(0),
          child: ListTile(
            key: UniqueKey(),
            onTap: () {
              var bloc = BlocProvider.of<GoogleAddressBloc>(context);
              bloc.addressSelectEventSink.add(places[index]);
              bloc.searchEventSink.add('');
              this.onAddressSelect(places[index].description);
            },
            leading: Icon(Icons.place),
            title: Text('${places[index].description}'),
          ),
        );
      },
    );
  }
}
