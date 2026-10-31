class Routes {
  const Routes._();

  static const String login = '/login';
  static const String home = '/';
  static const String announcement = '/pengumuman/:id';

  static String announcementFor(String id) => '/pengumuman/$id';
}
