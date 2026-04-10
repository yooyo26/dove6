// A single station in the route, resolved from /data/station-info/{id}
class Station {
  final int    index;  // position in the full stations list
  final String id;     // UUID from the server
  final String nameFr; // display_name_fr
  final String nameAr; // display_name_ar (falls back to nameFr if absent)

  const Station({
    required this.index,
    required this.id,
    required this.nameFr,
    required this.nameAr,
  });
}
