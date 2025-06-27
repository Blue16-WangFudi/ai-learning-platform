import 'package:mssql_connection/mssql_connection.dart';

class DatabaseService {
  static DatabaseService? _instance;
  MssqlConnection? _connection;
  
  DatabaseService._internal();
  
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }
  
  // 数据库连接配置
  static const String _connectionString = '';
  
  // 建立连接
  Future<void> connect() async {
    try {
      _connection = MssqlConnection.getInstance();
      await _connection!.connect(
        ip: '127.0.0.1',
        port: '9859',
        databaseName: 'AILearningPlatform',
        username: 'sa',
        password: 'KblS3rv3rP@sASw0rd!2098',
        timeoutInSeconds: 15,
      );
      print('SQL Server连接成功');
    } catch (e) {
      print('SQL Server连接失败: $e');
      rethrow;
    }
  }
  
  // 执行查询
  Future<String> query(String sql, [Map<String, dynamic>? params]) async {
    if (_connection == null || !_connection!.isConnected) {
      await connect();
    }
    
    try {
      String finalSql = sql;
      if (params != null) {
        params.forEach((key, value) {
          // 对于数字类型，不添加引号
          if (value is int || value is double) {
            finalSql = finalSql.replaceAll('@$key', value.toString());
          } else {
            finalSql = finalSql.replaceAll('@$key', "'$value'");
          }
        });
      }
      return await _connection!.getData(finalSql);
    } catch (e) {
      print('查询执行失败: $e');
      rethrow;
    }
  }
  
  // 执行写入操作
  Future<bool> execute(String sql, [Map<String, dynamic>? params]) async {
    if (_connection == null || !_connection!.isConnected) {
      await connect();
    }
    
    try {
      String finalSql = sql;
      if (params != null) {
        params.forEach((key, value) {
          // 对于数字类型，不添加引号
          if (value is int || value is double) {
            finalSql = finalSql.replaceAll('@$key', value.toString());
          } else {
            finalSql = finalSql.replaceAll('@$key', "'$value'");
          }
        });
      }
      await _connection!.writeData(finalSql);
      return true;
    } catch (e) {
      print('执行失败: $e');
      return false;
    }
  }
  
  // 关闭连接
  Future<void> close() async {
    await _connection?.disconnect();
    _connection = null;
  }
}