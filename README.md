# AI Learning Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.10.0+-02569B?style=flat&logo=flutter)](https://flutter.dev/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-CC2927?style=flat&logo=microsoft-sql-server)](https://www.microsoft.com/en-us/sql-server)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A comprehensive **Personalized AI-Assisted Learning Platform** built with Flutter and SQL Server, designed to provide an intelligent, interactive, and personalized learning experience for students, teachers, and administrators.

## 🌟 Features

### 👨‍🎓 For Students
- **User Authentication**: Secure registration and login system
- **Course Management**: Browse, enroll, and manage courses
- **Learning Progress**: Track study progress and achievements
- **Interactive Learning**: Access course materials, videos, and documents
- **Assessment System**: Take exams and view results
- **Forum Participation**: Engage in discussions and Q&A
- **Personalized Dashboard**: View learning statistics and recommendations

### 👨‍🏫 For Teachers
- **Course Creation**: Create and manage course content
- **Student Monitoring**: Track student progress and performance
- **Content Management**: Upload videos, documents, and materials
- **Assessment Tools**: Create and manage exams and quizzes
- **Analytics Dashboard**: View detailed learning analytics
- **Forum Moderation**: Manage discussions and provide guidance

### 👨‍💼 For Administrators
- **User Management**: Manage users and role assignments
- **Platform Oversight**: Monitor system performance and usage
- **Content Moderation**: Review and approve platform content
- **Analytics & Reporting**: Generate comprehensive reports
- **System Configuration**: Manage platform settings and permissions

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Database**: Microsoft SQL Server
- **State Management**: Provider
- **Database Connection**: mssql_connection
- **UI Components**: Material Design 3

### Key Components
- **Direct Database Connection**: Flutter app connects directly to SQL Server
- **Multi-Provider State Management**: Efficient state handling across the app
- **Responsive Design**: Optimized for various screen sizes
- **Custom Fonts**: HarmonyOS Sans for enhanced readability

## 📱 Screenshots

*Coming soon - Screenshots will be added to showcase the user interface*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Microsoft SQL Server (2019 or later)
- Visual Studio Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ai_learning.git
   cd ai_learning
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Database Setup**
   - Install Microsoft SQL Server
   - Run the database initialization script:
     ```sql
     -- Execute the script in docs/init_database.sql
     ```
   - Update database connection settings in `lib/services/database_service.dart`

4. **Configure Database Connection**
   - Update the connection string in your database service
   - Ensure SQL Server is configured to accept connections
   - Configure authentication (SQL Server or Windows Authentication)

5. **Run the application**
   ```bash
   flutter run
   ```

## 📊 Database Schema

The platform uses a comprehensive database schema including:

- **Users & Roles**: User management with role-based access control
- **Courses & Chapters**: Hierarchical course structure
- **Enrollments**: Student-course relationships
- **Study Records**: Learning progress tracking
- **Exams & Questions**: Assessment system
- **Forum Posts & Replies**: Discussion platform
- **Analytics Views**: Performance monitoring

## 🔧 Configuration

### Database Connection
Update the database connection parameters in `lib/services/database_service.dart`:

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
The system comes with pre-configured accounts:
- **Admin**: admin / admin123
- **Teacher**: teacher / teacher123
- **Student**: student / student123

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `mssql_connection`: SQL Server connectivity
- `provider`: State management
- `material_design_icons_flutter`: Icon library
- `shared_preferences`: Local storage
- `crypto`: Encryption utilities

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code analysis

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Microsoft for SQL Server
- Material Design team for the design system
- HarmonyOS team for the beautiful fonts

## 📞 Support

If you have any questions or need support, please:
- Open an issue on GitHub
- Contact the development team
- Check the documentation in the `docs/` folder

## 🔮 Future Enhancements

- **AI Integration**: Advanced AI-powered recommendations
- **Real-time Communication**: Live chat and video conferencing
- **Mobile Optimization**: Enhanced mobile experience
- **Offline Support**: Offline learning capabilities
- **Analytics Dashboard**: Advanced learning analytics
- **Multi-language Support**: Internationalization

---

**Built with ❤️ using Flutter and SQL Server**
