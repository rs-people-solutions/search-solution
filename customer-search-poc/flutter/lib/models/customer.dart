class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final List<String> email;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Safely parse email - handle both list and single string cases
    List<String> emails = [];
    final emailData = json['email'];
    if (emailData is List) {
      emails = emailData.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    } else if (emailData is String) {
      emails = [emailData];
    }
    
    return Customer(
      id: (json['id'] as dynamic)?.toInt() ?? 0,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: emails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }
}
