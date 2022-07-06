// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_persistence_db.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class WebServer extends DataClass implements Insertable<WebServer> {
  final int id;
  final String ipAddress;
  final int portNumber;
  final String displayName;
  final bool lastConnectionSuccessful;
  final bool? activeWebServerConnection;
  WebServer(
      {required this.id,
      required this.ipAddress,
      required this.portNumber,
      required this.displayName,
      required this.lastConnectionSuccessful,
      this.activeWebServerConnection});
  factory WebServer.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return WebServer(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      ipAddress: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}ip_address'])!,
      portNumber: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}port_number'])!,
      displayName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}display_name'])!,
      lastConnectionSuccessful: const BoolType().mapFromDatabaseResponse(
          data['${effectivePrefix}last_connection_successful'])!,
      activeWebServerConnection: const BoolType().mapFromDatabaseResponse(
          data['${effectivePrefix}active_web_server_connection']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ip_address'] = Variable<String>(ipAddress);
    map['port_number'] = Variable<int>(portNumber);
    map['display_name'] = Variable<String>(displayName);
    map['last_connection_successful'] =
        Variable<bool>(lastConnectionSuccessful);
    if (!nullToAbsent || activeWebServerConnection != null) {
      map['active_web_server_connection'] =
          Variable<bool?>(activeWebServerConnection);
    }
    return map;
  }

  WebServersCompanion toCompanion(bool nullToAbsent) {
    return WebServersCompanion(
      id: Value(id),
      ipAddress: Value(ipAddress),
      portNumber: Value(portNumber),
      displayName: Value(displayName),
      lastConnectionSuccessful: Value(lastConnectionSuccessful),
      activeWebServerConnection:
          activeWebServerConnection == null && nullToAbsent
              ? const Value.absent()
              : Value(activeWebServerConnection),
    );
  }

  factory WebServer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WebServer(
      id: serializer.fromJson<int>(json['id']),
      ipAddress: serializer.fromJson<String>(json['ipAddress']),
      portNumber: serializer.fromJson<int>(json['portNumber']),
      displayName: serializer.fromJson<String>(json['displayName']),
      lastConnectionSuccessful:
          serializer.fromJson<bool>(json['lastConnectionSuccessful']),
      activeWebServerConnection:
          serializer.fromJson<bool?>(json['activeWebServerConnection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ipAddress': serializer.toJson<String>(ipAddress),
      'portNumber': serializer.toJson<int>(portNumber),
      'displayName': serializer.toJson<String>(displayName),
      'lastConnectionSuccessful':
          serializer.toJson<bool>(lastConnectionSuccessful),
      'activeWebServerConnection':
          serializer.toJson<bool?>(activeWebServerConnection),
    };
  }

  WebServer copyWith(
          {int? id,
          String? ipAddress,
          int? portNumber,
          String? displayName,
          bool? lastConnectionSuccessful,
          bool? activeWebServerConnection}) =>
      WebServer(
        id: id ?? this.id,
        ipAddress: ipAddress ?? this.ipAddress,
        portNumber: portNumber ?? this.portNumber,
        displayName: displayName ?? this.displayName,
        lastConnectionSuccessful:
            lastConnectionSuccessful ?? this.lastConnectionSuccessful,
        activeWebServerConnection:
            activeWebServerConnection ?? this.activeWebServerConnection,
      );
  @override
  String toString() {
    return (StringBuffer('WebServer(')
          ..write('id: $id, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('portNumber: $portNumber, ')
          ..write('displayName: $displayName, ')
          ..write('lastConnectionSuccessful: $lastConnectionSuccessful, ')
          ..write('activeWebServerConnection: $activeWebServerConnection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ipAddress, portNumber, displayName,
      lastConnectionSuccessful, activeWebServerConnection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WebServer &&
          other.id == this.id &&
          other.ipAddress == this.ipAddress &&
          other.portNumber == this.portNumber &&
          other.displayName == this.displayName &&
          other.lastConnectionSuccessful == this.lastConnectionSuccessful &&
          other.activeWebServerConnection == this.activeWebServerConnection);
}

class WebServersCompanion extends UpdateCompanion<WebServer> {
  final Value<int> id;
  final Value<String> ipAddress;
  final Value<int> portNumber;
  final Value<String> displayName;
  final Value<bool> lastConnectionSuccessful;
  final Value<bool?> activeWebServerConnection;
  const WebServersCompanion({
    this.id = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.portNumber = const Value.absent(),
    this.displayName = const Value.absent(),
    this.lastConnectionSuccessful = const Value.absent(),
    this.activeWebServerConnection = const Value.absent(),
  });
  WebServersCompanion.insert({
    this.id = const Value.absent(),
    required String ipAddress,
    required int portNumber,
    required String displayName,
    required bool lastConnectionSuccessful,
    this.activeWebServerConnection = const Value.absent(),
  })  : ipAddress = Value(ipAddress),
        portNumber = Value(portNumber),
        displayName = Value(displayName),
        lastConnectionSuccessful = Value(lastConnectionSuccessful);
  static Insertable<WebServer> custom({
    Expression<int>? id,
    Expression<String>? ipAddress,
    Expression<int>? portNumber,
    Expression<String>? displayName,
    Expression<bool>? lastConnectionSuccessful,
    Expression<bool?>? activeWebServerConnection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (portNumber != null) 'port_number': portNumber,
      if (displayName != null) 'display_name': displayName,
      if (lastConnectionSuccessful != null)
        'last_connection_successful': lastConnectionSuccessful,
      if (activeWebServerConnection != null)
        'active_web_server_connection': activeWebServerConnection,
    });
  }

  WebServersCompanion copyWith(
      {Value<int>? id,
      Value<String>? ipAddress,
      Value<int>? portNumber,
      Value<String>? displayName,
      Value<bool>? lastConnectionSuccessful,
      Value<bool?>? activeWebServerConnection}) {
    return WebServersCompanion(
      id: id ?? this.id,
      ipAddress: ipAddress ?? this.ipAddress,
      portNumber: portNumber ?? this.portNumber,
      displayName: displayName ?? this.displayName,
      lastConnectionSuccessful:
          lastConnectionSuccessful ?? this.lastConnectionSuccessful,
      activeWebServerConnection:
          activeWebServerConnection ?? this.activeWebServerConnection,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (portNumber.present) {
      map['port_number'] = Variable<int>(portNumber.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (lastConnectionSuccessful.present) {
      map['last_connection_successful'] =
          Variable<bool>(lastConnectionSuccessful.value);
    }
    if (activeWebServerConnection.present) {
      map['active_web_server_connection'] =
          Variable<bool?>(activeWebServerConnection.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WebServersCompanion(')
          ..write('id: $id, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('portNumber: $portNumber, ')
          ..write('displayName: $displayName, ')
          ..write('lastConnectionSuccessful: $lastConnectionSuccessful, ')
          ..write('activeWebServerConnection: $activeWebServerConnection')
          ..write(')'))
        .toString();
  }
}

class $WebServersTable extends WebServers
    with TableInfo<$WebServersTable, WebServer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WebServersTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _ipAddressMeta = const VerificationMeta('ipAddress');
  @override
  late final GeneratedColumn<String?> ipAddress = GeneratedColumn<String?>(
      'ip_address', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 7, maxTextLength: 15),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _portNumberMeta = const VerificationMeta('portNumber');
  @override
  late final GeneratedColumn<int?> portNumber = GeneratedColumn<int?>(
      'port_number', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String?> displayName =
      GeneratedColumn<String?>('display_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 3,
          ),
          type: const StringType(),
          requiredDuringInsert: true);
  final VerificationMeta _lastConnectionSuccessfulMeta =
      const VerificationMeta('lastConnectionSuccessful');
  @override
  late final GeneratedColumn<bool?> lastConnectionSuccessful =
      GeneratedColumn<bool?>('last_connection_successful', aliasedName, false,
          type: const BoolType(),
          requiredDuringInsert: true,
          defaultConstraints: 'CHECK (last_connection_successful IN (0, 1))');
  final VerificationMeta _activeWebServerConnectionMeta =
      const VerificationMeta('activeWebServerConnection');
  @override
  late final GeneratedColumn<bool?> activeWebServerConnection =
      GeneratedColumn<bool?>('active_web_server_connection', aliasedName, true,
          type: const BoolType(),
          requiredDuringInsert: false,
          defaultConstraints: 'CHECK (active_web_server_connection IN (0, 1))');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ipAddress,
        portNumber,
        displayName,
        lastConnectionSuccessful,
        activeWebServerConnection
      ];
  @override
  String get aliasedName => _alias ?? 'web_servers';
  @override
  String get actualTableName => 'web_servers';
  @override
  VerificationContext validateIntegrity(Insertable<WebServer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ip_address')) {
      context.handle(_ipAddressMeta,
          ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta));
    } else if (isInserting) {
      context.missing(_ipAddressMeta);
    }
    if (data.containsKey('port_number')) {
      context.handle(
          _portNumberMeta,
          portNumber.isAcceptableOrUnknown(
              data['port_number']!, _portNumberMeta));
    } else if (isInserting) {
      context.missing(_portNumberMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('last_connection_successful')) {
      context.handle(
          _lastConnectionSuccessfulMeta,
          lastConnectionSuccessful.isAcceptableOrUnknown(
              data['last_connection_successful']!,
              _lastConnectionSuccessfulMeta));
    } else if (isInserting) {
      context.missing(_lastConnectionSuccessfulMeta);
    }
    if (data.containsKey('active_web_server_connection')) {
      context.handle(
          _activeWebServerConnectionMeta,
          activeWebServerConnection.isAcceptableOrUnknown(
              data['active_web_server_connection']!,
              _activeWebServerConnectionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WebServer map(Map<String, dynamic> data, {String? tablePrefix}) {
    return WebServer.fromData(data, attachedDatabase,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $WebServersTable createAlias(String alias) {
    return $WebServersTable(attachedDatabase, alias);
  }
}

class Doorbell extends DataClass implements Insertable<Doorbell> {
  final int id;
  final String name;
  final BigInt activeSinceUnix;
  final String doorbellStatus;
  final BigInt lastActivationTime;
  final int serverId;
  Doorbell(
      {required this.id,
      required this.name,
      required this.activeSinceUnix,
      required this.doorbellStatus,
      required this.lastActivationTime,
      required this.serverId});
  factory Doorbell.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Doorbell(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      activeSinceUnix: const BigIntType().mapFromDatabaseResponse(
          data['${effectivePrefix}active_since_unix'])!,
      doorbellStatus: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}doorbell_status'])!,
      lastActivationTime: const BigIntType().mapFromDatabaseResponse(
          data['${effectivePrefix}last_activation_time'])!,
      serverId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}server_id'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['active_since_unix'] = Variable<BigInt>(activeSinceUnix);
    map['doorbell_status'] = Variable<String>(doorbellStatus);
    map['last_activation_time'] = Variable<BigInt>(lastActivationTime);
    map['server_id'] = Variable<int>(serverId);
    return map;
  }

  DoorbellsCompanion toCompanion(bool nullToAbsent) {
    return DoorbellsCompanion(
      id: Value(id),
      name: Value(name),
      activeSinceUnix: Value(activeSinceUnix),
      doorbellStatus: Value(doorbellStatus),
      lastActivationTime: Value(lastActivationTime),
      serverId: Value(serverId),
    );
  }

  factory Doorbell.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Doorbell(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      activeSinceUnix: serializer.fromJson<BigInt>(json['activeSinceUnix']),
      doorbellStatus: serializer.fromJson<String>(json['doorbellStatus']),
      lastActivationTime:
          serializer.fromJson<BigInt>(json['lastActivationTime']),
      serverId: serializer.fromJson<int>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'activeSinceUnix': serializer.toJson<BigInt>(activeSinceUnix),
      'doorbellStatus': serializer.toJson<String>(doorbellStatus),
      'lastActivationTime': serializer.toJson<BigInt>(lastActivationTime),
      'serverId': serializer.toJson<int>(serverId),
    };
  }

  Doorbell copyWith(
          {int? id,
          String? name,
          BigInt? activeSinceUnix,
          String? doorbellStatus,
          BigInt? lastActivationTime,
          int? serverId}) =>
      Doorbell(
        id: id ?? this.id,
        name: name ?? this.name,
        activeSinceUnix: activeSinceUnix ?? this.activeSinceUnix,
        doorbellStatus: doorbellStatus ?? this.doorbellStatus,
        lastActivationTime: lastActivationTime ?? this.lastActivationTime,
        serverId: serverId ?? this.serverId,
      );
  @override
  String toString() {
    return (StringBuffer('Doorbell(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('activeSinceUnix: $activeSinceUnix, ')
          ..write('doorbellStatus: $doorbellStatus, ')
          ..write('lastActivationTime: $lastActivationTime, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, activeSinceUnix, doorbellStatus, lastActivationTime, serverId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Doorbell &&
          other.id == this.id &&
          other.name == this.name &&
          other.activeSinceUnix == this.activeSinceUnix &&
          other.doorbellStatus == this.doorbellStatus &&
          other.lastActivationTime == this.lastActivationTime &&
          other.serverId == this.serverId);
}

class DoorbellsCompanion extends UpdateCompanion<Doorbell> {
  final Value<int> id;
  final Value<String> name;
  final Value<BigInt> activeSinceUnix;
  final Value<String> doorbellStatus;
  final Value<BigInt> lastActivationTime;
  final Value<int> serverId;
  const DoorbellsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.activeSinceUnix = const Value.absent(),
    this.doorbellStatus = const Value.absent(),
    this.lastActivationTime = const Value.absent(),
    this.serverId = const Value.absent(),
  });
  DoorbellsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required BigInt activeSinceUnix,
    required String doorbellStatus,
    required BigInt lastActivationTime,
    required int serverId,
  })  : name = Value(name),
        activeSinceUnix = Value(activeSinceUnix),
        doorbellStatus = Value(doorbellStatus),
        lastActivationTime = Value(lastActivationTime),
        serverId = Value(serverId);
  static Insertable<Doorbell> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<BigInt>? activeSinceUnix,
    Expression<String>? doorbellStatus,
    Expression<BigInt>? lastActivationTime,
    Expression<int>? serverId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (activeSinceUnix != null) 'active_since_unix': activeSinceUnix,
      if (doorbellStatus != null) 'doorbell_status': doorbellStatus,
      if (lastActivationTime != null)
        'last_activation_time': lastActivationTime,
      if (serverId != null) 'server_id': serverId,
    });
  }

  DoorbellsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<BigInt>? activeSinceUnix,
      Value<String>? doorbellStatus,
      Value<BigInt>? lastActivationTime,
      Value<int>? serverId}) {
    return DoorbellsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      activeSinceUnix: activeSinceUnix ?? this.activeSinceUnix,
      doorbellStatus: doorbellStatus ?? this.doorbellStatus,
      lastActivationTime: lastActivationTime ?? this.lastActivationTime,
      serverId: serverId ?? this.serverId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (activeSinceUnix.present) {
      map['active_since_unix'] = Variable<BigInt>(activeSinceUnix.value);
    }
    if (doorbellStatus.present) {
      map['doorbell_status'] = Variable<String>(doorbellStatus.value);
    }
    if (lastActivationTime.present) {
      map['last_activation_time'] = Variable<BigInt>(lastActivationTime.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoorbellsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('activeSinceUnix: $activeSinceUnix, ')
          ..write('doorbellStatus: $doorbellStatus, ')
          ..write('lastActivationTime: $lastActivationTime, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }
}

class $DoorbellsTable extends Doorbells
    with TableInfo<$DoorbellsTable, Doorbell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoorbellsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _activeSinceUnixMeta =
      const VerificationMeta('activeSinceUnix');
  @override
  late final GeneratedColumn<BigInt?> activeSinceUnix =
      GeneratedColumn<BigInt?>('active_since_unix', aliasedName, false,
          type: const BigIntType(), requiredDuringInsert: true);
  final VerificationMeta _doorbellStatusMeta =
      const VerificationMeta('doorbellStatus');
  @override
  late final GeneratedColumn<String?> doorbellStatus = GeneratedColumn<String?>(
      'doorbell_status', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _lastActivationTimeMeta =
      const VerificationMeta('lastActivationTime');
  @override
  late final GeneratedColumn<BigInt?> lastActivationTime =
      GeneratedColumn<BigInt?>('last_activation_time', aliasedName, false,
          type: const BigIntType(), requiredDuringInsert: true);
  final VerificationMeta _serverIdMeta = const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int?> serverId = GeneratedColumn<int?>(
      'server_id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES web_servers (id)');
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, activeSinceUnix, doorbellStatus, lastActivationTime, serverId];
  @override
  String get aliasedName => _alias ?? 'doorbells';
  @override
  String get actualTableName => 'doorbells';
  @override
  VerificationContext validateIntegrity(Insertable<Doorbell> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active_since_unix')) {
      context.handle(
          _activeSinceUnixMeta,
          activeSinceUnix.isAcceptableOrUnknown(
              data['active_since_unix']!, _activeSinceUnixMeta));
    } else if (isInserting) {
      context.missing(_activeSinceUnixMeta);
    }
    if (data.containsKey('doorbell_status')) {
      context.handle(
          _doorbellStatusMeta,
          doorbellStatus.isAcceptableOrUnknown(
              data['doorbell_status']!, _doorbellStatusMeta));
    } else if (isInserting) {
      context.missing(_doorbellStatusMeta);
    }
    if (data.containsKey('last_activation_time')) {
      context.handle(
          _lastActivationTimeMeta,
          lastActivationTime.isAcceptableOrUnknown(
              data['last_activation_time']!, _lastActivationTimeMeta));
    } else if (isInserting) {
      context.missing(_lastActivationTimeMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Doorbell map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Doorbell.fromData(data, attachedDatabase,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $DoorbellsTable createAlias(String alias) {
    return $DoorbellsTable(attachedDatabase, alias);
  }
}

abstract class _$AppPersistenceDb extends GeneratedDatabase {
  _$AppPersistenceDb(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $WebServersTable webServers = $WebServersTable(this);
  late final $DoorbellsTable doorbells = $DoorbellsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [webServers, doorbells];
}
