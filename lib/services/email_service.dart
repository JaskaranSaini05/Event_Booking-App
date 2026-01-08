import 'email_service_stub.dart'
    if (dart.library.html) 'email_service_web.dart';

abstract class EmailService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  });

  factory EmailService() => getEmailService();
}
