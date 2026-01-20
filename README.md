# AI Learning Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.10.0+-02569B?style=flat&logo=flutter)](https://flutter.dev/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-CC2927?style=flat&logo=microsoft-sql-server)](https://www.microsoft.com/en-us/sql-server)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An AI-assisted learning platform built with Flutter and SQL Server, serving students, teachers, and administrators with course management, learning progress, assessments, and discussion.

## Features

### Students
- Sign up and sign in
- Browse, enroll, and manage courses
- Track learning progress and results
- Access videos, documents, and other materials
- Take quizzes and view scores
- Join forum discussions and Q&A

### Teachers
- Create and manage courses
- Monitor student progress
- Upload learning resources
- Build and manage exams and questions
- Review learning analytics
- Moderate forum discussions

### Administrators
- Manage users and roles
- Monitor platform usage
- Review and moderate content
- Generate reports
- Configure system settings and permissions

## Tech Stack

- Flutter (Dart)
- Microsoft SQL Server
- Provider (state management)
- mssql_connection (database access)
- Material Design 3

## Screenshots

Coming soon.

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Microsoft SQL Server (2019 or later)
- VS Code or Android Studio

### Setup

1. Clone the repo
   ```bash
   git clone https://github.com/yourusername/ai_learning.git
   cd ai_learning
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Initialize the database
   - Install and start Microsoft SQL Server
   - Run `docs/init_database.sql`

4. Configure database connection
   - Update `lib/services/database_service.dart`

5. Run the app
   ```bash
   flutter run
   ```

## Database Notes

The schema includes users and roles, courses and chapters, enrollments, study records, exams and questions, and forum posts/replies. See the `docs/` folder for details.

## Configuration Example

Edit SQL Server connection settings in `lib/services/database_service.dart`:

```dart
final connection = MssqlConnection.getInstance();
await connection.connect(
  ip: 'your_server_ip',
  port: 'your_port',
  databaseName: 'AILearningPlatform',
  username: 'your_username',
  password: 'your_password',
);
```

### Default Accounts
- Admin: admin / admin123
- Teacher: teacher / teacher123
- Student: student / student123

## Testing

```bash
flutter test
```

## Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -m "Add feature"`)
4. Push the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## License

MIT. See `LICENSE` for details.

## Roadmap

- AI recommendations and learning paths
- Real-time communication (chat/meetings)
- Offline learning support
- Multi-language support
