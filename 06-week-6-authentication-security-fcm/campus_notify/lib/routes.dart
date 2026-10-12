class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const profile = '/profile';
  static const announcement = '/pengumuman/:id';
  static const debugFcm = '/debug-fcm';

  static String announcementById(String id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] as String?) ?? '/';
  return route.startsWith('/') ? route : '/$route';
}