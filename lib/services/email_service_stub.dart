import 'email_service.dart';

class MobileEmailService implements EmailService {
  @override
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    // Do nothing or use API
    print("Email service not supported on mobile");
  }
}

EmailService getEmailService() => MobileEmailService();
