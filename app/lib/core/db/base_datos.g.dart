// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_datos.dart';

// ignore_for_file: type=lint
class $CirculosTable extends Circulos with TableInfo<$CirculosTable, Circulo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CirculosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionClaveMeta = const VerificationMeta(
    'versionClave',
  );
  @override
  late final GeneratedColumn<int> versionClave = GeneratedColumn<int>(
    'version_clave',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, creadoEn, versionClave];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circulos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Circulo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('version_clave')) {
      context.handle(
        _versionClaveMeta,
        versionClave.isAcceptableOrUnknown(
          data['version_clave']!,
          _versionClaveMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Circulo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Circulo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      versionClave: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_clave'],
      )!,
    );
  }

  @override
  $CirculosTable createAlias(String alias) {
    return $CirculosTable(attachedDatabase, alias);
  }
}

class Circulo extends DataClass implements Insertable<Circulo> {
  final String id;
  final String nombre;
  final int creadoEn;
  final int versionClave;
  const Circulo({
    required this.id,
    required this.nombre,
    required this.creadoEn,
    required this.versionClave,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['creado_en'] = Variable<int>(creadoEn);
    map['version_clave'] = Variable<int>(versionClave);
    return map;
  }

  CirculosCompanion toCompanion(bool nullToAbsent) {
    return CirculosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      creadoEn: Value(creadoEn),
      versionClave: Value(versionClave),
    );
  }

  factory Circulo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Circulo(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      versionClave: serializer.fromJson<int>(json['versionClave']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'versionClave': serializer.toJson<int>(versionClave),
    };
  }

  Circulo copyWith({
    String? id,
    String? nombre,
    int? creadoEn,
    int? versionClave,
  }) => Circulo(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    creadoEn: creadoEn ?? this.creadoEn,
    versionClave: versionClave ?? this.versionClave,
  );
  Circulo copyWithCompanion(CirculosCompanion data) {
    return Circulo(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      versionClave: data.versionClave.present
          ? data.versionClave.value
          : this.versionClave,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Circulo(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('versionClave: $versionClave')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, creadoEn, versionClave);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Circulo &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.creadoEn == this.creadoEn &&
          other.versionClave == this.versionClave);
}

class CirculosCompanion extends UpdateCompanion<Circulo> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<int> creadoEn;
  final Value<int> versionClave;
  final Value<int> rowid;
  const CirculosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.versionClave = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CirculosCompanion.insert({
    required String id,
    required String nombre,
    required int creadoEn,
    this.versionClave = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       creadoEn = Value(creadoEn);
  static Insertable<Circulo> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<int>? creadoEn,
    Expression<int>? versionClave,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (versionClave != null) 'version_clave': versionClave,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CirculosCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<int>? creadoEn,
    Value<int>? versionClave,
    Value<int>? rowid,
  }) {
    return CirculosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      creadoEn: creadoEn ?? this.creadoEn,
      versionClave: versionClave ?? this.versionClave,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (versionClave.present) {
      map['version_clave'] = Variable<int>(versionClave.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CirculosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('versionClave: $versionClave, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FotosTable extends Fotos with TableInfo<$FotosTable, Foto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creadaEnMeta = const VerificationMeta(
    'creadaEn',
  );
  @override
  late final GeneratedColumn<int> creadaEn = GeneratedColumn<int>(
    'creada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bytes, mime, creadaEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fotos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Foto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('creada_en')) {
      context.handle(
        _creadaEnMeta,
        creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Foto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Foto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      creadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creada_en'],
      )!,
    );
  }

  @override
  $FotosTable createAlias(String alias) {
    return $FotosTable(attachedDatabase, alias);
  }
}

class Foto extends DataClass implements Insertable<Foto> {
  final String id;
  final Uint8List bytes;
  final String mime;
  final int creadaEn;
  const Foto({
    required this.id,
    required this.bytes,
    required this.mime,
    required this.creadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['mime'] = Variable<String>(mime);
    map['creada_en'] = Variable<int>(creadaEn);
    return map;
  }

  FotosCompanion toCompanion(bool nullToAbsent) {
    return FotosCompanion(
      id: Value(id),
      bytes: Value(bytes),
      mime: Value(mime),
      creadaEn: Value(creadaEn),
    );
  }

  factory Foto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Foto(
      id: serializer.fromJson<String>(json['id']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      mime: serializer.fromJson<String>(json['mime']),
      creadaEn: serializer.fromJson<int>(json['creadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'mime': serializer.toJson<String>(mime),
      'creadaEn': serializer.toJson<int>(creadaEn),
    };
  }

  Foto copyWith({String? id, Uint8List? bytes, String? mime, int? creadaEn}) =>
      Foto(
        id: id ?? this.id,
        bytes: bytes ?? this.bytes,
        mime: mime ?? this.mime,
        creadaEn: creadaEn ?? this.creadaEn,
      );
  Foto copyWithCompanion(FotosCompanion data) {
    return Foto(
      id: data.id.present ? data.id.value : this.id,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      mime: data.mime.present ? data.mime.value : this.mime,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Foto(')
          ..write('id: $id, ')
          ..write('bytes: $bytes, ')
          ..write('mime: $mime, ')
          ..write('creadaEn: $creadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, $driftBlobEquality.hash(bytes), mime, creadaEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Foto &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.mime == this.mime &&
          other.creadaEn == this.creadaEn);
}

class FotosCompanion extends UpdateCompanion<Foto> {
  final Value<String> id;
  final Value<Uint8List> bytes;
  final Value<String> mime;
  final Value<int> creadaEn;
  final Value<int> rowid;
  const FotosCompanion({
    this.id = const Value.absent(),
    this.bytes = const Value.absent(),
    this.mime = const Value.absent(),
    this.creadaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FotosCompanion.insert({
    required String id,
    required Uint8List bytes,
    required String mime,
    required int creadaEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bytes = Value(bytes),
       mime = Value(mime),
       creadaEn = Value(creadaEn);
  static Insertable<Foto> custom({
    Expression<String>? id,
    Expression<Uint8List>? bytes,
    Expression<String>? mime,
    Expression<int>? creadaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bytes != null) 'bytes': bytes,
      if (mime != null) 'mime': mime,
      if (creadaEn != null) 'creada_en': creadaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FotosCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? bytes,
    Value<String>? mime,
    Value<int>? creadaEn,
    Value<int>? rowid,
  }) {
    return FotosCompanion(
      id: id ?? this.id,
      bytes: bytes ?? this.bytes,
      mime: mime ?? this.mime,
      creadaEn: creadaEn ?? this.creadaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<int>(creadaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FotosCompanion(')
          ..write('id: $id, ')
          ..write('bytes: $bytes, ')
          ..write('mime: $mime, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonasTable extends Personas with TableInfo<$PersonasTable, Persona> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circuloIdMeta = const VerificationMeta(
    'circuloId',
  );
  @override
  late final GeneratedColumn<String> circuloId = GeneratedColumn<String>(
    'circulo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circulos (id)',
    ),
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoIdMeta = const VerificationMeta('fotoId');
  @override
  late final GeneratedColumn<String> fotoId = GeneratedColumn<String>(
    'foto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fotos (id)',
    ),
  );
  static const VerificationMeta _zonaHorariaMeta = const VerificationMeta(
    'zonaHoraria',
  );
  @override
  late final GeneratedColumn<String> zonaHoraria = GeneratedColumn<String>(
    'zona_horaria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Europe/Madrid'),
  );
  static const VerificationMeta _creadaEnMeta = const VerificationMeta(
    'creadaEn',
  );
  @override
  late final GeneratedColumn<int> creadaEn = GeneratedColumn<int>(
    'creada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    circuloId,
    alias,
    fotoId,
    zonaHoraria,
    creadaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Persona> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circulo_id')) {
      context.handle(
        _circuloIdMeta,
        circuloId.isAcceptableOrUnknown(data['circulo_id']!, _circuloIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circuloIdMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('foto_id')) {
      context.handle(
        _fotoIdMeta,
        fotoId.isAcceptableOrUnknown(data['foto_id']!, _fotoIdMeta),
      );
    }
    if (data.containsKey('zona_horaria')) {
      context.handle(
        _zonaHorariaMeta,
        zonaHoraria.isAcceptableOrUnknown(
          data['zona_horaria']!,
          _zonaHorariaMeta,
        ),
      );
    }
    if (data.containsKey('creada_en')) {
      context.handle(
        _creadaEnMeta,
        creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Persona map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Persona(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      circuloId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circulo_id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      fotoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_id'],
      ),
      zonaHoraria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zona_horaria'],
      )!,
      creadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creada_en'],
      )!,
    );
  }

  @override
  $PersonasTable createAlias(String alias) {
    return $PersonasTable(attachedDatabase, alias);
  }
}

class Persona extends DataClass implements Insertable<Persona> {
  final String id;
  final String circuloId;
  final String alias;
  final String? fotoId;
  final String zonaHoraria;
  final int creadaEn;
  const Persona({
    required this.id,
    required this.circuloId,
    required this.alias,
    this.fotoId,
    required this.zonaHoraria,
    required this.creadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circulo_id'] = Variable<String>(circuloId);
    map['alias'] = Variable<String>(alias);
    if (!nullToAbsent || fotoId != null) {
      map['foto_id'] = Variable<String>(fotoId);
    }
    map['zona_horaria'] = Variable<String>(zonaHoraria);
    map['creada_en'] = Variable<int>(creadaEn);
    return map;
  }

  PersonasCompanion toCompanion(bool nullToAbsent) {
    return PersonasCompanion(
      id: Value(id),
      circuloId: Value(circuloId),
      alias: Value(alias),
      fotoId: fotoId == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoId),
      zonaHoraria: Value(zonaHoraria),
      creadaEn: Value(creadaEn),
    );
  }

  factory Persona.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Persona(
      id: serializer.fromJson<String>(json['id']),
      circuloId: serializer.fromJson<String>(json['circuloId']),
      alias: serializer.fromJson<String>(json['alias']),
      fotoId: serializer.fromJson<String?>(json['fotoId']),
      zonaHoraria: serializer.fromJson<String>(json['zonaHoraria']),
      creadaEn: serializer.fromJson<int>(json['creadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circuloId': serializer.toJson<String>(circuloId),
      'alias': serializer.toJson<String>(alias),
      'fotoId': serializer.toJson<String?>(fotoId),
      'zonaHoraria': serializer.toJson<String>(zonaHoraria),
      'creadaEn': serializer.toJson<int>(creadaEn),
    };
  }

  Persona copyWith({
    String? id,
    String? circuloId,
    String? alias,
    Value<String?> fotoId = const Value.absent(),
    String? zonaHoraria,
    int? creadaEn,
  }) => Persona(
    id: id ?? this.id,
    circuloId: circuloId ?? this.circuloId,
    alias: alias ?? this.alias,
    fotoId: fotoId.present ? fotoId.value : this.fotoId,
    zonaHoraria: zonaHoraria ?? this.zonaHoraria,
    creadaEn: creadaEn ?? this.creadaEn,
  );
  Persona copyWithCompanion(PersonasCompanion data) {
    return Persona(
      id: data.id.present ? data.id.value : this.id,
      circuloId: data.circuloId.present ? data.circuloId.value : this.circuloId,
      alias: data.alias.present ? data.alias.value : this.alias,
      fotoId: data.fotoId.present ? data.fotoId.value : this.fotoId,
      zonaHoraria: data.zonaHoraria.present
          ? data.zonaHoraria.value
          : this.zonaHoraria,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Persona(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('alias: $alias, ')
          ..write('fotoId: $fotoId, ')
          ..write('zonaHoraria: $zonaHoraria, ')
          ..write('creadaEn: $creadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, circuloId, alias, fotoId, zonaHoraria, creadaEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Persona &&
          other.id == this.id &&
          other.circuloId == this.circuloId &&
          other.alias == this.alias &&
          other.fotoId == this.fotoId &&
          other.zonaHoraria == this.zonaHoraria &&
          other.creadaEn == this.creadaEn);
}

class PersonasCompanion extends UpdateCompanion<Persona> {
  final Value<String> id;
  final Value<String> circuloId;
  final Value<String> alias;
  final Value<String?> fotoId;
  final Value<String> zonaHoraria;
  final Value<int> creadaEn;
  final Value<int> rowid;
  const PersonasCompanion({
    this.id = const Value.absent(),
    this.circuloId = const Value.absent(),
    this.alias = const Value.absent(),
    this.fotoId = const Value.absent(),
    this.zonaHoraria = const Value.absent(),
    this.creadaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonasCompanion.insert({
    required String id,
    required String circuloId,
    required String alias,
    this.fotoId = const Value.absent(),
    this.zonaHoraria = const Value.absent(),
    required int creadaEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       circuloId = Value(circuloId),
       alias = Value(alias),
       creadaEn = Value(creadaEn);
  static Insertable<Persona> custom({
    Expression<String>? id,
    Expression<String>? circuloId,
    Expression<String>? alias,
    Expression<String>? fotoId,
    Expression<String>? zonaHoraria,
    Expression<int>? creadaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circuloId != null) 'circulo_id': circuloId,
      if (alias != null) 'alias': alias,
      if (fotoId != null) 'foto_id': fotoId,
      if (zonaHoraria != null) 'zona_horaria': zonaHoraria,
      if (creadaEn != null) 'creada_en': creadaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonasCompanion copyWith({
    Value<String>? id,
    Value<String>? circuloId,
    Value<String>? alias,
    Value<String?>? fotoId,
    Value<String>? zonaHoraria,
    Value<int>? creadaEn,
    Value<int>? rowid,
  }) {
    return PersonasCompanion(
      id: id ?? this.id,
      circuloId: circuloId ?? this.circuloId,
      alias: alias ?? this.alias,
      fotoId: fotoId ?? this.fotoId,
      zonaHoraria: zonaHoraria ?? this.zonaHoraria,
      creadaEn: creadaEn ?? this.creadaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circuloId.present) {
      map['circulo_id'] = Variable<String>(circuloId.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (fotoId.present) {
      map['foto_id'] = Variable<String>(fotoId.value);
    }
    if (zonaHoraria.present) {
      map['zona_horaria'] = Variable<String>(zonaHoraria.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<int>(creadaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonasCompanion(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('alias: $alias, ')
          ..write('fotoId: $fotoId, ')
          ..write('zonaHoraria: $zonaHoraria, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MiembrosTable extends Miembros with TableInfo<$MiembrosTable, Miembro> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MiembrosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circuloIdMeta = const VerificationMeta(
    'circuloId',
  );
  @override
  late final GeneratedColumn<String> circuloId = GeneratedColumn<String>(
    'circulo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circulos (id)',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relacionMeta = const VerificationMeta(
    'relacion',
  );
  @override
  late final GeneratedColumn<String> relacion = GeneratedColumn<String>(
    'relacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoIdMeta = const VerificationMeta('fotoId');
  @override
  late final GeneratedColumn<String> fotoId = GeneratedColumn<String>(
    'foto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fotos (id)',
    ),
  );
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
    'rol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenEscaladoMeta = const VerificationMeta(
    'ordenEscalado',
  );
  @override
  late final GeneratedColumn<int> ordenEscalado = GeneratedColumn<int>(
    'orden_escalado',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enMiGenteMeta = const VerificationMeta(
    'enMiGente',
  );
  @override
  late final GeneratedColumn<bool> enMiGente = GeneratedColumn<bool>(
    'en_mi_gente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("en_mi_gente" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    circuloId,
    nombre,
    relacion,
    telefono,
    fotoId,
    rol,
    ordenEscalado,
    enMiGente,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'miembros';
  @override
  VerificationContext validateIntegrity(
    Insertable<Miembro> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circulo_id')) {
      context.handle(
        _circuloIdMeta,
        circuloId.isAcceptableOrUnknown(data['circulo_id']!, _circuloIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circuloIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('relacion')) {
      context.handle(
        _relacionMeta,
        relacion.isAcceptableOrUnknown(data['relacion']!, _relacionMeta),
      );
    } else if (isInserting) {
      context.missing(_relacionMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('foto_id')) {
      context.handle(
        _fotoIdMeta,
        fotoId.isAcceptableOrUnknown(data['foto_id']!, _fotoIdMeta),
      );
    }
    if (data.containsKey('rol')) {
      context.handle(
        _rolMeta,
        rol.isAcceptableOrUnknown(data['rol']!, _rolMeta),
      );
    } else if (isInserting) {
      context.missing(_rolMeta);
    }
    if (data.containsKey('orden_escalado')) {
      context.handle(
        _ordenEscaladoMeta,
        ordenEscalado.isAcceptableOrUnknown(
          data['orden_escalado']!,
          _ordenEscaladoMeta,
        ),
      );
    }
    if (data.containsKey('en_mi_gente')) {
      context.handle(
        _enMiGenteMeta,
        enMiGente.isAcceptableOrUnknown(data['en_mi_gente']!, _enMiGenteMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Miembro map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Miembro(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      circuloId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circulo_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      relacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relacion'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      fotoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_id'],
      ),
      rol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol'],
      )!,
      ordenEscalado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden_escalado'],
      ),
      enMiGente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}en_mi_gente'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $MiembrosTable createAlias(String alias) {
    return $MiembrosTable(attachedDatabase, alias);
  }
}

class Miembro extends DataClass implements Insertable<Miembro> {
  final String id;
  final String circuloId;
  final String nombre;
  final String relacion;
  final String? telefono;
  final String? fotoId;

  /// `responsable`, `cuidador`, `apoyo` o `lectura`.
  final String rol;
  final int? ordenEscalado;
  final bool enMiGente;
  final int creadoEn;
  const Miembro({
    required this.id,
    required this.circuloId,
    required this.nombre,
    required this.relacion,
    this.telefono,
    this.fotoId,
    required this.rol,
    this.ordenEscalado,
    required this.enMiGente,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circulo_id'] = Variable<String>(circuloId);
    map['nombre'] = Variable<String>(nombre);
    map['relacion'] = Variable<String>(relacion);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || fotoId != null) {
      map['foto_id'] = Variable<String>(fotoId);
    }
    map['rol'] = Variable<String>(rol);
    if (!nullToAbsent || ordenEscalado != null) {
      map['orden_escalado'] = Variable<int>(ordenEscalado);
    }
    map['en_mi_gente'] = Variable<bool>(enMiGente);
    map['creado_en'] = Variable<int>(creadoEn);
    return map;
  }

  MiembrosCompanion toCompanion(bool nullToAbsent) {
    return MiembrosCompanion(
      id: Value(id),
      circuloId: Value(circuloId),
      nombre: Value(nombre),
      relacion: Value(relacion),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      fotoId: fotoId == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoId),
      rol: Value(rol),
      ordenEscalado: ordenEscalado == null && nullToAbsent
          ? const Value.absent()
          : Value(ordenEscalado),
      enMiGente: Value(enMiGente),
      creadoEn: Value(creadoEn),
    );
  }

  factory Miembro.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Miembro(
      id: serializer.fromJson<String>(json['id']),
      circuloId: serializer.fromJson<String>(json['circuloId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      relacion: serializer.fromJson<String>(json['relacion']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      fotoId: serializer.fromJson<String?>(json['fotoId']),
      rol: serializer.fromJson<String>(json['rol']),
      ordenEscalado: serializer.fromJson<int?>(json['ordenEscalado']),
      enMiGente: serializer.fromJson<bool>(json['enMiGente']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circuloId': serializer.toJson<String>(circuloId),
      'nombre': serializer.toJson<String>(nombre),
      'relacion': serializer.toJson<String>(relacion),
      'telefono': serializer.toJson<String?>(telefono),
      'fotoId': serializer.toJson<String?>(fotoId),
      'rol': serializer.toJson<String>(rol),
      'ordenEscalado': serializer.toJson<int?>(ordenEscalado),
      'enMiGente': serializer.toJson<bool>(enMiGente),
      'creadoEn': serializer.toJson<int>(creadoEn),
    };
  }

  Miembro copyWith({
    String? id,
    String? circuloId,
    String? nombre,
    String? relacion,
    Value<String?> telefono = const Value.absent(),
    Value<String?> fotoId = const Value.absent(),
    String? rol,
    Value<int?> ordenEscalado = const Value.absent(),
    bool? enMiGente,
    int? creadoEn,
  }) => Miembro(
    id: id ?? this.id,
    circuloId: circuloId ?? this.circuloId,
    nombre: nombre ?? this.nombre,
    relacion: relacion ?? this.relacion,
    telefono: telefono.present ? telefono.value : this.telefono,
    fotoId: fotoId.present ? fotoId.value : this.fotoId,
    rol: rol ?? this.rol,
    ordenEscalado: ordenEscalado.present
        ? ordenEscalado.value
        : this.ordenEscalado,
    enMiGente: enMiGente ?? this.enMiGente,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Miembro copyWithCompanion(MiembrosCompanion data) {
    return Miembro(
      id: data.id.present ? data.id.value : this.id,
      circuloId: data.circuloId.present ? data.circuloId.value : this.circuloId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      relacion: data.relacion.present ? data.relacion.value : this.relacion,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      fotoId: data.fotoId.present ? data.fotoId.value : this.fotoId,
      rol: data.rol.present ? data.rol.value : this.rol,
      ordenEscalado: data.ordenEscalado.present
          ? data.ordenEscalado.value
          : this.ordenEscalado,
      enMiGente: data.enMiGente.present ? data.enMiGente.value : this.enMiGente,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Miembro(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('nombre: $nombre, ')
          ..write('relacion: $relacion, ')
          ..write('telefono: $telefono, ')
          ..write('fotoId: $fotoId, ')
          ..write('rol: $rol, ')
          ..write('ordenEscalado: $ordenEscalado, ')
          ..write('enMiGente: $enMiGente, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    circuloId,
    nombre,
    relacion,
    telefono,
    fotoId,
    rol,
    ordenEscalado,
    enMiGente,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Miembro &&
          other.id == this.id &&
          other.circuloId == this.circuloId &&
          other.nombre == this.nombre &&
          other.relacion == this.relacion &&
          other.telefono == this.telefono &&
          other.fotoId == this.fotoId &&
          other.rol == this.rol &&
          other.ordenEscalado == this.ordenEscalado &&
          other.enMiGente == this.enMiGente &&
          other.creadoEn == this.creadoEn);
}

class MiembrosCompanion extends UpdateCompanion<Miembro> {
  final Value<String> id;
  final Value<String> circuloId;
  final Value<String> nombre;
  final Value<String> relacion;
  final Value<String?> telefono;
  final Value<String?> fotoId;
  final Value<String> rol;
  final Value<int?> ordenEscalado;
  final Value<bool> enMiGente;
  final Value<int> creadoEn;
  final Value<int> rowid;
  const MiembrosCompanion({
    this.id = const Value.absent(),
    this.circuloId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.relacion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.fotoId = const Value.absent(),
    this.rol = const Value.absent(),
    this.ordenEscalado = const Value.absent(),
    this.enMiGente = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MiembrosCompanion.insert({
    required String id,
    required String circuloId,
    required String nombre,
    required String relacion,
    this.telefono = const Value.absent(),
    this.fotoId = const Value.absent(),
    required String rol,
    this.ordenEscalado = const Value.absent(),
    this.enMiGente = const Value.absent(),
    required int creadoEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       circuloId = Value(circuloId),
       nombre = Value(nombre),
       relacion = Value(relacion),
       rol = Value(rol),
       creadoEn = Value(creadoEn);
  static Insertable<Miembro> custom({
    Expression<String>? id,
    Expression<String>? circuloId,
    Expression<String>? nombre,
    Expression<String>? relacion,
    Expression<String>? telefono,
    Expression<String>? fotoId,
    Expression<String>? rol,
    Expression<int>? ordenEscalado,
    Expression<bool>? enMiGente,
    Expression<int>? creadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circuloId != null) 'circulo_id': circuloId,
      if (nombre != null) 'nombre': nombre,
      if (relacion != null) 'relacion': relacion,
      if (telefono != null) 'telefono': telefono,
      if (fotoId != null) 'foto_id': fotoId,
      if (rol != null) 'rol': rol,
      if (ordenEscalado != null) 'orden_escalado': ordenEscalado,
      if (enMiGente != null) 'en_mi_gente': enMiGente,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MiembrosCompanion copyWith({
    Value<String>? id,
    Value<String>? circuloId,
    Value<String>? nombre,
    Value<String>? relacion,
    Value<String?>? telefono,
    Value<String?>? fotoId,
    Value<String>? rol,
    Value<int?>? ordenEscalado,
    Value<bool>? enMiGente,
    Value<int>? creadoEn,
    Value<int>? rowid,
  }) {
    return MiembrosCompanion(
      id: id ?? this.id,
      circuloId: circuloId ?? this.circuloId,
      nombre: nombre ?? this.nombre,
      relacion: relacion ?? this.relacion,
      telefono: telefono ?? this.telefono,
      fotoId: fotoId ?? this.fotoId,
      rol: rol ?? this.rol,
      ordenEscalado: ordenEscalado ?? this.ordenEscalado,
      enMiGente: enMiGente ?? this.enMiGente,
      creadoEn: creadoEn ?? this.creadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circuloId.present) {
      map['circulo_id'] = Variable<String>(circuloId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (relacion.present) {
      map['relacion'] = Variable<String>(relacion.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (fotoId.present) {
      map['foto_id'] = Variable<String>(fotoId.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (ordenEscalado.present) {
      map['orden_escalado'] = Variable<int>(ordenEscalado.value);
    }
    if (enMiGente.present) {
      map['en_mi_gente'] = Variable<bool>(enMiGente.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MiembrosCompanion(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('nombre: $nombre, ')
          ..write('relacion: $relacion, ')
          ..write('telefono: $telefono, ')
          ..write('fotoId: $fotoId, ')
          ..write('rol: $rol, ')
          ..write('ordenEscalado: $ordenEscalado, ')
          ..write('enMiGente: $enMiGente, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DispositivosTable extends Dispositivos
    with TableInfo<$DispositivosTable, Dispositivo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DispositivosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circuloIdMeta = const VerificationMeta(
    'circuloId',
  );
  @override
  late final GeneratedColumn<String> circuloId = GeneratedColumn<String>(
    'circulo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circulos (id)',
    ),
  );
  static const VerificationMeta _perfilMeta = const VerificationMeta('perfil');
  @override
  late final GeneratedColumn<String> perfil = GeneratedColumn<String>(
    'perfil',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plataformaMeta = const VerificationMeta(
    'plataforma',
  );
  @override
  late final GeneratedColumn<String> plataforma = GeneratedColumn<String>(
    'plataforma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _miembroIdMeta = const VerificationMeta(
    'miembroId',
  );
  @override
  late final GeneratedColumn<String> miembroId = GeneratedColumn<String>(
    'miembro_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES miembros (id)',
    ),
  );
  static const VerificationMeta _registradoEnMeta = const VerificationMeta(
    'registradoEn',
  );
  @override
  late final GeneratedColumn<int> registradoEn = GeneratedColumn<int>(
    'registrado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    circuloId,
    perfil,
    plataforma,
    miembroId,
    registradoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dispositivos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dispositivo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circulo_id')) {
      context.handle(
        _circuloIdMeta,
        circuloId.isAcceptableOrUnknown(data['circulo_id']!, _circuloIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circuloIdMeta);
    }
    if (data.containsKey('perfil')) {
      context.handle(
        _perfilMeta,
        perfil.isAcceptableOrUnknown(data['perfil']!, _perfilMeta),
      );
    } else if (isInserting) {
      context.missing(_perfilMeta);
    }
    if (data.containsKey('plataforma')) {
      context.handle(
        _plataformaMeta,
        plataforma.isAcceptableOrUnknown(data['plataforma']!, _plataformaMeta),
      );
    } else if (isInserting) {
      context.missing(_plataformaMeta);
    }
    if (data.containsKey('miembro_id')) {
      context.handle(
        _miembroIdMeta,
        miembroId.isAcceptableOrUnknown(data['miembro_id']!, _miembroIdMeta),
      );
    }
    if (data.containsKey('registrado_en')) {
      context.handle(
        _registradoEnMeta,
        registradoEn.isAcceptableOrUnknown(
          data['registrado_en']!,
          _registradoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registradoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dispositivo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dispositivo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      circuloId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circulo_id'],
      )!,
      perfil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perfil'],
      )!,
      plataforma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plataforma'],
      )!,
      miembroId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}miembro_id'],
      ),
      registradoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registrado_en'],
      )!,
    );
  }

  @override
  $DispositivosTable createAlias(String alias) {
    return $DispositivosTable(attachedDatabase, alias);
  }
}

class Dispositivo extends DataClass implements Insertable<Dispositivo> {
  final String id;
  final String circuloId;

  /// `persona` o `familia`.
  final String perfil;

  /// `ios`, `android` o `web`.
  final String plataforma;
  final String? miembroId;
  final int registradoEn;
  const Dispositivo({
    required this.id,
    required this.circuloId,
    required this.perfil,
    required this.plataforma,
    this.miembroId,
    required this.registradoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circulo_id'] = Variable<String>(circuloId);
    map['perfil'] = Variable<String>(perfil);
    map['plataforma'] = Variable<String>(plataforma);
    if (!nullToAbsent || miembroId != null) {
      map['miembro_id'] = Variable<String>(miembroId);
    }
    map['registrado_en'] = Variable<int>(registradoEn);
    return map;
  }

  DispositivosCompanion toCompanion(bool nullToAbsent) {
    return DispositivosCompanion(
      id: Value(id),
      circuloId: Value(circuloId),
      perfil: Value(perfil),
      plataforma: Value(plataforma),
      miembroId: miembroId == null && nullToAbsent
          ? const Value.absent()
          : Value(miembroId),
      registradoEn: Value(registradoEn),
    );
  }

  factory Dispositivo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dispositivo(
      id: serializer.fromJson<String>(json['id']),
      circuloId: serializer.fromJson<String>(json['circuloId']),
      perfil: serializer.fromJson<String>(json['perfil']),
      plataforma: serializer.fromJson<String>(json['plataforma']),
      miembroId: serializer.fromJson<String?>(json['miembroId']),
      registradoEn: serializer.fromJson<int>(json['registradoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circuloId': serializer.toJson<String>(circuloId),
      'perfil': serializer.toJson<String>(perfil),
      'plataforma': serializer.toJson<String>(plataforma),
      'miembroId': serializer.toJson<String?>(miembroId),
      'registradoEn': serializer.toJson<int>(registradoEn),
    };
  }

  Dispositivo copyWith({
    String? id,
    String? circuloId,
    String? perfil,
    String? plataforma,
    Value<String?> miembroId = const Value.absent(),
    int? registradoEn,
  }) => Dispositivo(
    id: id ?? this.id,
    circuloId: circuloId ?? this.circuloId,
    perfil: perfil ?? this.perfil,
    plataforma: plataforma ?? this.plataforma,
    miembroId: miembroId.present ? miembroId.value : this.miembroId,
    registradoEn: registradoEn ?? this.registradoEn,
  );
  Dispositivo copyWithCompanion(DispositivosCompanion data) {
    return Dispositivo(
      id: data.id.present ? data.id.value : this.id,
      circuloId: data.circuloId.present ? data.circuloId.value : this.circuloId,
      perfil: data.perfil.present ? data.perfil.value : this.perfil,
      plataforma: data.plataforma.present
          ? data.plataforma.value
          : this.plataforma,
      miembroId: data.miembroId.present ? data.miembroId.value : this.miembroId,
      registradoEn: data.registradoEn.present
          ? data.registradoEn.value
          : this.registradoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dispositivo(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('perfil: $perfil, ')
          ..write('plataforma: $plataforma, ')
          ..write('miembroId: $miembroId, ')
          ..write('registradoEn: $registradoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, circuloId, perfil, plataforma, miembroId, registradoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dispositivo &&
          other.id == this.id &&
          other.circuloId == this.circuloId &&
          other.perfil == this.perfil &&
          other.plataforma == this.plataforma &&
          other.miembroId == this.miembroId &&
          other.registradoEn == this.registradoEn);
}

class DispositivosCompanion extends UpdateCompanion<Dispositivo> {
  final Value<String> id;
  final Value<String> circuloId;
  final Value<String> perfil;
  final Value<String> plataforma;
  final Value<String?> miembroId;
  final Value<int> registradoEn;
  final Value<int> rowid;
  const DispositivosCompanion({
    this.id = const Value.absent(),
    this.circuloId = const Value.absent(),
    this.perfil = const Value.absent(),
    this.plataforma = const Value.absent(),
    this.miembroId = const Value.absent(),
    this.registradoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DispositivosCompanion.insert({
    required String id,
    required String circuloId,
    required String perfil,
    required String plataforma,
    this.miembroId = const Value.absent(),
    required int registradoEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       circuloId = Value(circuloId),
       perfil = Value(perfil),
       plataforma = Value(plataforma),
       registradoEn = Value(registradoEn);
  static Insertable<Dispositivo> custom({
    Expression<String>? id,
    Expression<String>? circuloId,
    Expression<String>? perfil,
    Expression<String>? plataforma,
    Expression<String>? miembroId,
    Expression<int>? registradoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circuloId != null) 'circulo_id': circuloId,
      if (perfil != null) 'perfil': perfil,
      if (plataforma != null) 'plataforma': plataforma,
      if (miembroId != null) 'miembro_id': miembroId,
      if (registradoEn != null) 'registrado_en': registradoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DispositivosCompanion copyWith({
    Value<String>? id,
    Value<String>? circuloId,
    Value<String>? perfil,
    Value<String>? plataforma,
    Value<String?>? miembroId,
    Value<int>? registradoEn,
    Value<int>? rowid,
  }) {
    return DispositivosCompanion(
      id: id ?? this.id,
      circuloId: circuloId ?? this.circuloId,
      perfil: perfil ?? this.perfil,
      plataforma: plataforma ?? this.plataforma,
      miembroId: miembroId ?? this.miembroId,
      registradoEn: registradoEn ?? this.registradoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circuloId.present) {
      map['circulo_id'] = Variable<String>(circuloId.value);
    }
    if (perfil.present) {
      map['perfil'] = Variable<String>(perfil.value);
    }
    if (plataforma.present) {
      map['plataforma'] = Variable<String>(plataforma.value);
    }
    if (miembroId.present) {
      map['miembro_id'] = Variable<String>(miembroId.value);
    }
    if (registradoEn.present) {
      map['registrado_en'] = Variable<int>(registradoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DispositivosCompanion(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('perfil: $perfil, ')
          ..write('plataforma: $plataforma, ')
          ..write('miembroId: $miembroId, ')
          ..write('registradoEn: $registradoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicamentosTable extends Medicamentos
    with TableInfo<$MedicamentosTable, Medicamento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicamentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personas (id)',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreParaPersonaMeta = const VerificationMeta(
    'nombreParaPersona',
  );
  @override
  late final GeneratedColumn<String> nombreParaPersona =
      GeneratedColumn<String>(
        'nombre_para_persona',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _formaMeta = const VerificationMeta('forma');
  @override
  late final GeneratedColumn<String> forma = GeneratedColumn<String>(
    'forma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoCajaIdMeta = const VerificationMeta(
    'fotoCajaId',
  );
  @override
  late final GeneratedColumn<String> fotoCajaId = GeneratedColumn<String>(
    'foto_caja_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fotos (id)',
    ),
  );
  static const VerificationMeta _fotoPastillaIdMeta = const VerificationMeta(
    'fotoPastillaId',
  );
  @override
  late final GeneratedColumn<String> fotoPastillaId = GeneratedColumn<String>(
    'foto_pastilla_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fotos (id)',
    ),
  );
  static const VerificationMeta _registroCimaMeta = const VerificationMeta(
    'registroCima',
  );
  @override
  late final GeneratedColumn<String> registroCima = GeneratedColumn<String>(
    'registro_cima',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retiradoEnMeta = const VerificationMeta(
    'retiradoEn',
  );
  @override
  late final GeneratedColumn<int> retiradoEn = GeneratedColumn<int>(
    'retirado_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personaId,
    nombre,
    nombreParaPersona,
    forma,
    color,
    fotoCajaId,
    fotoPastillaId,
    registroCima,
    creadoEn,
    retiradoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medicamento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personaIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('nombre_para_persona')) {
      context.handle(
        _nombreParaPersonaMeta,
        nombreParaPersona.isAcceptableOrUnknown(
          data['nombre_para_persona']!,
          _nombreParaPersonaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreParaPersonaMeta);
    }
    if (data.containsKey('forma')) {
      context.handle(
        _formaMeta,
        forma.isAcceptableOrUnknown(data['forma']!, _formaMeta),
      );
    } else if (isInserting) {
      context.missing(_formaMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('foto_caja_id')) {
      context.handle(
        _fotoCajaIdMeta,
        fotoCajaId.isAcceptableOrUnknown(
          data['foto_caja_id']!,
          _fotoCajaIdMeta,
        ),
      );
    }
    if (data.containsKey('foto_pastilla_id')) {
      context.handle(
        _fotoPastillaIdMeta,
        fotoPastillaId.isAcceptableOrUnknown(
          data['foto_pastilla_id']!,
          _fotoPastillaIdMeta,
        ),
      );
    }
    if (data.containsKey('registro_cima')) {
      context.handle(
        _registroCimaMeta,
        registroCima.isAcceptableOrUnknown(
          data['registro_cima']!,
          _registroCimaMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('retirado_en')) {
      context.handle(
        _retiradoEnMeta,
        retiradoEn.isAcceptableOrUnknown(data['retirado_en']!, _retiradoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medicamento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicamento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      nombreParaPersona: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_para_persona'],
      )!,
      forma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forma'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      fotoCajaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_caja_id'],
      ),
      fotoPastillaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_pastilla_id'],
      ),
      registroCima: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registro_cima'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      retiradoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retirado_en'],
      ),
    );
  }

  @override
  $MedicamentosTable createAlias(String alias) {
    return $MedicamentosTable(attachedDatabase, alias);
  }
}

class Medicamento extends DataClass implements Insertable<Medicamento> {
  final String id;
  final String personaId;
  final String nombre;
  final String nombreParaPersona;

  /// `redonda`, `ovalada`, `capsula` u `otra`.
  final String forma;
  final String? color;
  final String? fotoCajaId;
  final String? fotoPastillaId;
  final String? registroCima;
  final int creadoEn;
  final int? retiradoEn;
  const Medicamento({
    required this.id,
    required this.personaId,
    required this.nombre,
    required this.nombreParaPersona,
    required this.forma,
    this.color,
    this.fotoCajaId,
    this.fotoPastillaId,
    this.registroCima,
    required this.creadoEn,
    this.retiradoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['persona_id'] = Variable<String>(personaId);
    map['nombre'] = Variable<String>(nombre);
    map['nombre_para_persona'] = Variable<String>(nombreParaPersona);
    map['forma'] = Variable<String>(forma);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || fotoCajaId != null) {
      map['foto_caja_id'] = Variable<String>(fotoCajaId);
    }
    if (!nullToAbsent || fotoPastillaId != null) {
      map['foto_pastilla_id'] = Variable<String>(fotoPastillaId);
    }
    if (!nullToAbsent || registroCima != null) {
      map['registro_cima'] = Variable<String>(registroCima);
    }
    map['creado_en'] = Variable<int>(creadoEn);
    if (!nullToAbsent || retiradoEn != null) {
      map['retirado_en'] = Variable<int>(retiradoEn);
    }
    return map;
  }

  MedicamentosCompanion toCompanion(bool nullToAbsent) {
    return MedicamentosCompanion(
      id: Value(id),
      personaId: Value(personaId),
      nombre: Value(nombre),
      nombreParaPersona: Value(nombreParaPersona),
      forma: Value(forma),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      fotoCajaId: fotoCajaId == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoCajaId),
      fotoPastillaId: fotoPastillaId == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPastillaId),
      registroCima: registroCima == null && nullToAbsent
          ? const Value.absent()
          : Value(registroCima),
      creadoEn: Value(creadoEn),
      retiradoEn: retiradoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(retiradoEn),
    );
  }

  factory Medicamento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicamento(
      id: serializer.fromJson<String>(json['id']),
      personaId: serializer.fromJson<String>(json['personaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      nombreParaPersona: serializer.fromJson<String>(json['nombreParaPersona']),
      forma: serializer.fromJson<String>(json['forma']),
      color: serializer.fromJson<String?>(json['color']),
      fotoCajaId: serializer.fromJson<String?>(json['fotoCajaId']),
      fotoPastillaId: serializer.fromJson<String?>(json['fotoPastillaId']),
      registroCima: serializer.fromJson<String?>(json['registroCima']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      retiradoEn: serializer.fromJson<int?>(json['retiradoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personaId': serializer.toJson<String>(personaId),
      'nombre': serializer.toJson<String>(nombre),
      'nombreParaPersona': serializer.toJson<String>(nombreParaPersona),
      'forma': serializer.toJson<String>(forma),
      'color': serializer.toJson<String?>(color),
      'fotoCajaId': serializer.toJson<String?>(fotoCajaId),
      'fotoPastillaId': serializer.toJson<String?>(fotoPastillaId),
      'registroCima': serializer.toJson<String?>(registroCima),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'retiradoEn': serializer.toJson<int?>(retiradoEn),
    };
  }

  Medicamento copyWith({
    String? id,
    String? personaId,
    String? nombre,
    String? nombreParaPersona,
    String? forma,
    Value<String?> color = const Value.absent(),
    Value<String?> fotoCajaId = const Value.absent(),
    Value<String?> fotoPastillaId = const Value.absent(),
    Value<String?> registroCima = const Value.absent(),
    int? creadoEn,
    Value<int?> retiradoEn = const Value.absent(),
  }) => Medicamento(
    id: id ?? this.id,
    personaId: personaId ?? this.personaId,
    nombre: nombre ?? this.nombre,
    nombreParaPersona: nombreParaPersona ?? this.nombreParaPersona,
    forma: forma ?? this.forma,
    color: color.present ? color.value : this.color,
    fotoCajaId: fotoCajaId.present ? fotoCajaId.value : this.fotoCajaId,
    fotoPastillaId: fotoPastillaId.present
        ? fotoPastillaId.value
        : this.fotoPastillaId,
    registroCima: registroCima.present ? registroCima.value : this.registroCima,
    creadoEn: creadoEn ?? this.creadoEn,
    retiradoEn: retiradoEn.present ? retiradoEn.value : this.retiradoEn,
  );
  Medicamento copyWithCompanion(MedicamentosCompanion data) {
    return Medicamento(
      id: data.id.present ? data.id.value : this.id,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      nombreParaPersona: data.nombreParaPersona.present
          ? data.nombreParaPersona.value
          : this.nombreParaPersona,
      forma: data.forma.present ? data.forma.value : this.forma,
      color: data.color.present ? data.color.value : this.color,
      fotoCajaId: data.fotoCajaId.present
          ? data.fotoCajaId.value
          : this.fotoCajaId,
      fotoPastillaId: data.fotoPastillaId.present
          ? data.fotoPastillaId.value
          : this.fotoPastillaId,
      registroCima: data.registroCima.present
          ? data.registroCima.value
          : this.registroCima,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      retiradoEn: data.retiradoEn.present
          ? data.retiradoEn.value
          : this.retiradoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medicamento(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('nombre: $nombre, ')
          ..write('nombreParaPersona: $nombreParaPersona, ')
          ..write('forma: $forma, ')
          ..write('color: $color, ')
          ..write('fotoCajaId: $fotoCajaId, ')
          ..write('fotoPastillaId: $fotoPastillaId, ')
          ..write('registroCima: $registroCima, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('retiradoEn: $retiradoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personaId,
    nombre,
    nombreParaPersona,
    forma,
    color,
    fotoCajaId,
    fotoPastillaId,
    registroCima,
    creadoEn,
    retiradoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicamento &&
          other.id == this.id &&
          other.personaId == this.personaId &&
          other.nombre == this.nombre &&
          other.nombreParaPersona == this.nombreParaPersona &&
          other.forma == this.forma &&
          other.color == this.color &&
          other.fotoCajaId == this.fotoCajaId &&
          other.fotoPastillaId == this.fotoPastillaId &&
          other.registroCima == this.registroCima &&
          other.creadoEn == this.creadoEn &&
          other.retiradoEn == this.retiradoEn);
}

class MedicamentosCompanion extends UpdateCompanion<Medicamento> {
  final Value<String> id;
  final Value<String> personaId;
  final Value<String> nombre;
  final Value<String> nombreParaPersona;
  final Value<String> forma;
  final Value<String?> color;
  final Value<String?> fotoCajaId;
  final Value<String?> fotoPastillaId;
  final Value<String?> registroCima;
  final Value<int> creadoEn;
  final Value<int?> retiradoEn;
  final Value<int> rowid;
  const MedicamentosCompanion({
    this.id = const Value.absent(),
    this.personaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.nombreParaPersona = const Value.absent(),
    this.forma = const Value.absent(),
    this.color = const Value.absent(),
    this.fotoCajaId = const Value.absent(),
    this.fotoPastillaId = const Value.absent(),
    this.registroCima = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.retiradoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicamentosCompanion.insert({
    required String id,
    required String personaId,
    required String nombre,
    required String nombreParaPersona,
    required String forma,
    this.color = const Value.absent(),
    this.fotoCajaId = const Value.absent(),
    this.fotoPastillaId = const Value.absent(),
    this.registroCima = const Value.absent(),
    required int creadoEn,
    this.retiradoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personaId = Value(personaId),
       nombre = Value(nombre),
       nombreParaPersona = Value(nombreParaPersona),
       forma = Value(forma),
       creadoEn = Value(creadoEn);
  static Insertable<Medicamento> custom({
    Expression<String>? id,
    Expression<String>? personaId,
    Expression<String>? nombre,
    Expression<String>? nombreParaPersona,
    Expression<String>? forma,
    Expression<String>? color,
    Expression<String>? fotoCajaId,
    Expression<String>? fotoPastillaId,
    Expression<String>? registroCima,
    Expression<int>? creadoEn,
    Expression<int>? retiradoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personaId != null) 'persona_id': personaId,
      if (nombre != null) 'nombre': nombre,
      if (nombreParaPersona != null) 'nombre_para_persona': nombreParaPersona,
      if (forma != null) 'forma': forma,
      if (color != null) 'color': color,
      if (fotoCajaId != null) 'foto_caja_id': fotoCajaId,
      if (fotoPastillaId != null) 'foto_pastilla_id': fotoPastillaId,
      if (registroCima != null) 'registro_cima': registroCima,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (retiradoEn != null) 'retirado_en': retiradoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicamentosCompanion copyWith({
    Value<String>? id,
    Value<String>? personaId,
    Value<String>? nombre,
    Value<String>? nombreParaPersona,
    Value<String>? forma,
    Value<String?>? color,
    Value<String?>? fotoCajaId,
    Value<String?>? fotoPastillaId,
    Value<String?>? registroCima,
    Value<int>? creadoEn,
    Value<int?>? retiradoEn,
    Value<int>? rowid,
  }) {
    return MedicamentosCompanion(
      id: id ?? this.id,
      personaId: personaId ?? this.personaId,
      nombre: nombre ?? this.nombre,
      nombreParaPersona: nombreParaPersona ?? this.nombreParaPersona,
      forma: forma ?? this.forma,
      color: color ?? this.color,
      fotoCajaId: fotoCajaId ?? this.fotoCajaId,
      fotoPastillaId: fotoPastillaId ?? this.fotoPastillaId,
      registroCima: registroCima ?? this.registroCima,
      creadoEn: creadoEn ?? this.creadoEn,
      retiradoEn: retiradoEn ?? this.retiradoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (nombreParaPersona.present) {
      map['nombre_para_persona'] = Variable<String>(nombreParaPersona.value);
    }
    if (forma.present) {
      map['forma'] = Variable<String>(forma.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (fotoCajaId.present) {
      map['foto_caja_id'] = Variable<String>(fotoCajaId.value);
    }
    if (fotoPastillaId.present) {
      map['foto_pastilla_id'] = Variable<String>(fotoPastillaId.value);
    }
    if (registroCima.present) {
      map['registro_cima'] = Variable<String>(registroCima.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (retiradoEn.present) {
      map['retirado_en'] = Variable<int>(retiradoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicamentosCompanion(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('nombre: $nombre, ')
          ..write('nombreParaPersona: $nombreParaPersona, ')
          ..write('forma: $forma, ')
          ..write('color: $color, ')
          ..write('fotoCajaId: $fotoCajaId, ')
          ..write('fotoPastillaId: $fotoPastillaId, ')
          ..write('registroCima: $registroCima, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('retiradoEn: $retiradoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsentimientosTable extends Consentimientos
    with TableInfo<$ConsentimientosTable, Consentimiento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsentimientosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circuloIdMeta = const VerificationMeta(
    'circuloId',
  );
  @override
  late final GeneratedColumn<String> circuloId = GeneratedColumn<String>(
    'circulo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circulos (id)',
    ),
  );
  static const VerificationMeta _otorganteMeta = const VerificationMeta(
    'otorgante',
  );
  @override
  late final GeneratedColumn<String> otorgante = GeneratedColumn<String>(
    'otorgante',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enNombreDeMeta = const VerificationMeta(
    'enNombreDe',
  );
  @override
  late final GeneratedColumn<String> enNombreDe = GeneratedColumn<String>(
    'en_nombre_de',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sobreMeta = const VerificationMeta('sobre');
  @override
  late final GeneratedColumn<String> sobre = GeneratedColumn<String>(
    'sobre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textoMostradoMeta = const VerificationMeta(
    'textoMostrado',
  );
  @override
  late final GeneratedColumn<String> textoMostrado = GeneratedColumn<String>(
    'texto_mostrado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentoFotoIdMeta = const VerificationMeta(
    'documentoFotoId',
  );
  @override
  late final GeneratedColumn<String> documentoFotoId = GeneratedColumn<String>(
    'documento_foto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fotos (id)',
    ),
  );
  static const VerificationMeta _otorgadoEnMeta = const VerificationMeta(
    'otorgadoEn',
  );
  @override
  late final GeneratedColumn<int> otorgadoEn = GeneratedColumn<int>(
    'otorgado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revocaAMeta = const VerificationMeta(
    'revocaA',
  );
  @override
  late final GeneratedColumn<String> revocaA = GeneratedColumn<String>(
    'revoca_a',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    circuloId,
    otorgante,
    enNombreDe,
    sobre,
    textoMostrado,
    documentoFotoId,
    otorgadoEn,
    revocaA,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consentimientos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Consentimiento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circulo_id')) {
      context.handle(
        _circuloIdMeta,
        circuloId.isAcceptableOrUnknown(data['circulo_id']!, _circuloIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circuloIdMeta);
    }
    if (data.containsKey('otorgante')) {
      context.handle(
        _otorganteMeta,
        otorgante.isAcceptableOrUnknown(data['otorgante']!, _otorganteMeta),
      );
    } else if (isInserting) {
      context.missing(_otorganteMeta);
    }
    if (data.containsKey('en_nombre_de')) {
      context.handle(
        _enNombreDeMeta,
        enNombreDe.isAcceptableOrUnknown(
          data['en_nombre_de']!,
          _enNombreDeMeta,
        ),
      );
    }
    if (data.containsKey('sobre')) {
      context.handle(
        _sobreMeta,
        sobre.isAcceptableOrUnknown(data['sobre']!, _sobreMeta),
      );
    } else if (isInserting) {
      context.missing(_sobreMeta);
    }
    if (data.containsKey('texto_mostrado')) {
      context.handle(
        _textoMostradoMeta,
        textoMostrado.isAcceptableOrUnknown(
          data['texto_mostrado']!,
          _textoMostradoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textoMostradoMeta);
    }
    if (data.containsKey('documento_foto_id')) {
      context.handle(
        _documentoFotoIdMeta,
        documentoFotoId.isAcceptableOrUnknown(
          data['documento_foto_id']!,
          _documentoFotoIdMeta,
        ),
      );
    }
    if (data.containsKey('otorgado_en')) {
      context.handle(
        _otorgadoEnMeta,
        otorgadoEn.isAcceptableOrUnknown(data['otorgado_en']!, _otorgadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_otorgadoEnMeta);
    }
    if (data.containsKey('revoca_a')) {
      context.handle(
        _revocaAMeta,
        revocaA.isAcceptableOrUnknown(data['revoca_a']!, _revocaAMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Consentimiento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Consentimiento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      circuloId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circulo_id'],
      )!,
      otorgante: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}otorgante'],
      )!,
      enNombreDe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}en_nombre_de'],
      ),
      sobre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sobre'],
      )!,
      textoMostrado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto_mostrado'],
      )!,
      documentoFotoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documento_foto_id'],
      ),
      otorgadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}otorgado_en'],
      )!,
      revocaA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revoca_a'],
      ),
    );
  }

  @override
  $ConsentimientosTable createAlias(String alias) {
    return $ConsentimientosTable(attachedDatabase, alias);
  }
}

class Consentimiento extends DataClass implements Insertable<Consentimiento> {
  final String id;
  final String circuloId;
  final String otorgante;
  final String? enNombreDe;

  /// `voz`, `grabacion_consulta`, `video_toma`, `ubicacion` o `datos`.
  final String sobre;
  final String textoMostrado;
  final String? documentoFotoId;
  final int otorgadoEn;
  final String? revocaA;
  const Consentimiento({
    required this.id,
    required this.circuloId,
    required this.otorgante,
    this.enNombreDe,
    required this.sobre,
    required this.textoMostrado,
    this.documentoFotoId,
    required this.otorgadoEn,
    this.revocaA,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circulo_id'] = Variable<String>(circuloId);
    map['otorgante'] = Variable<String>(otorgante);
    if (!nullToAbsent || enNombreDe != null) {
      map['en_nombre_de'] = Variable<String>(enNombreDe);
    }
    map['sobre'] = Variable<String>(sobre);
    map['texto_mostrado'] = Variable<String>(textoMostrado);
    if (!nullToAbsent || documentoFotoId != null) {
      map['documento_foto_id'] = Variable<String>(documentoFotoId);
    }
    map['otorgado_en'] = Variable<int>(otorgadoEn);
    if (!nullToAbsent || revocaA != null) {
      map['revoca_a'] = Variable<String>(revocaA);
    }
    return map;
  }

  ConsentimientosCompanion toCompanion(bool nullToAbsent) {
    return ConsentimientosCompanion(
      id: Value(id),
      circuloId: Value(circuloId),
      otorgante: Value(otorgante),
      enNombreDe: enNombreDe == null && nullToAbsent
          ? const Value.absent()
          : Value(enNombreDe),
      sobre: Value(sobre),
      textoMostrado: Value(textoMostrado),
      documentoFotoId: documentoFotoId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentoFotoId),
      otorgadoEn: Value(otorgadoEn),
      revocaA: revocaA == null && nullToAbsent
          ? const Value.absent()
          : Value(revocaA),
    );
  }

  factory Consentimiento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Consentimiento(
      id: serializer.fromJson<String>(json['id']),
      circuloId: serializer.fromJson<String>(json['circuloId']),
      otorgante: serializer.fromJson<String>(json['otorgante']),
      enNombreDe: serializer.fromJson<String?>(json['enNombreDe']),
      sobre: serializer.fromJson<String>(json['sobre']),
      textoMostrado: serializer.fromJson<String>(json['textoMostrado']),
      documentoFotoId: serializer.fromJson<String?>(json['documentoFotoId']),
      otorgadoEn: serializer.fromJson<int>(json['otorgadoEn']),
      revocaA: serializer.fromJson<String?>(json['revocaA']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circuloId': serializer.toJson<String>(circuloId),
      'otorgante': serializer.toJson<String>(otorgante),
      'enNombreDe': serializer.toJson<String?>(enNombreDe),
      'sobre': serializer.toJson<String>(sobre),
      'textoMostrado': serializer.toJson<String>(textoMostrado),
      'documentoFotoId': serializer.toJson<String?>(documentoFotoId),
      'otorgadoEn': serializer.toJson<int>(otorgadoEn),
      'revocaA': serializer.toJson<String?>(revocaA),
    };
  }

  Consentimiento copyWith({
    String? id,
    String? circuloId,
    String? otorgante,
    Value<String?> enNombreDe = const Value.absent(),
    String? sobre,
    String? textoMostrado,
    Value<String?> documentoFotoId = const Value.absent(),
    int? otorgadoEn,
    Value<String?> revocaA = const Value.absent(),
  }) => Consentimiento(
    id: id ?? this.id,
    circuloId: circuloId ?? this.circuloId,
    otorgante: otorgante ?? this.otorgante,
    enNombreDe: enNombreDe.present ? enNombreDe.value : this.enNombreDe,
    sobre: sobre ?? this.sobre,
    textoMostrado: textoMostrado ?? this.textoMostrado,
    documentoFotoId: documentoFotoId.present
        ? documentoFotoId.value
        : this.documentoFotoId,
    otorgadoEn: otorgadoEn ?? this.otorgadoEn,
    revocaA: revocaA.present ? revocaA.value : this.revocaA,
  );
  Consentimiento copyWithCompanion(ConsentimientosCompanion data) {
    return Consentimiento(
      id: data.id.present ? data.id.value : this.id,
      circuloId: data.circuloId.present ? data.circuloId.value : this.circuloId,
      otorgante: data.otorgante.present ? data.otorgante.value : this.otorgante,
      enNombreDe: data.enNombreDe.present
          ? data.enNombreDe.value
          : this.enNombreDe,
      sobre: data.sobre.present ? data.sobre.value : this.sobre,
      textoMostrado: data.textoMostrado.present
          ? data.textoMostrado.value
          : this.textoMostrado,
      documentoFotoId: data.documentoFotoId.present
          ? data.documentoFotoId.value
          : this.documentoFotoId,
      otorgadoEn: data.otorgadoEn.present
          ? data.otorgadoEn.value
          : this.otorgadoEn,
      revocaA: data.revocaA.present ? data.revocaA.value : this.revocaA,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Consentimiento(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('otorgante: $otorgante, ')
          ..write('enNombreDe: $enNombreDe, ')
          ..write('sobre: $sobre, ')
          ..write('textoMostrado: $textoMostrado, ')
          ..write('documentoFotoId: $documentoFotoId, ')
          ..write('otorgadoEn: $otorgadoEn, ')
          ..write('revocaA: $revocaA')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    circuloId,
    otorgante,
    enNombreDe,
    sobre,
    textoMostrado,
    documentoFotoId,
    otorgadoEn,
    revocaA,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Consentimiento &&
          other.id == this.id &&
          other.circuloId == this.circuloId &&
          other.otorgante == this.otorgante &&
          other.enNombreDe == this.enNombreDe &&
          other.sobre == this.sobre &&
          other.textoMostrado == this.textoMostrado &&
          other.documentoFotoId == this.documentoFotoId &&
          other.otorgadoEn == this.otorgadoEn &&
          other.revocaA == this.revocaA);
}

class ConsentimientosCompanion extends UpdateCompanion<Consentimiento> {
  final Value<String> id;
  final Value<String> circuloId;
  final Value<String> otorgante;
  final Value<String?> enNombreDe;
  final Value<String> sobre;
  final Value<String> textoMostrado;
  final Value<String?> documentoFotoId;
  final Value<int> otorgadoEn;
  final Value<String?> revocaA;
  final Value<int> rowid;
  const ConsentimientosCompanion({
    this.id = const Value.absent(),
    this.circuloId = const Value.absent(),
    this.otorgante = const Value.absent(),
    this.enNombreDe = const Value.absent(),
    this.sobre = const Value.absent(),
    this.textoMostrado = const Value.absent(),
    this.documentoFotoId = const Value.absent(),
    this.otorgadoEn = const Value.absent(),
    this.revocaA = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsentimientosCompanion.insert({
    required String id,
    required String circuloId,
    required String otorgante,
    this.enNombreDe = const Value.absent(),
    required String sobre,
    required String textoMostrado,
    this.documentoFotoId = const Value.absent(),
    required int otorgadoEn,
    this.revocaA = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       circuloId = Value(circuloId),
       otorgante = Value(otorgante),
       sobre = Value(sobre),
       textoMostrado = Value(textoMostrado),
       otorgadoEn = Value(otorgadoEn);
  static Insertable<Consentimiento> custom({
    Expression<String>? id,
    Expression<String>? circuloId,
    Expression<String>? otorgante,
    Expression<String>? enNombreDe,
    Expression<String>? sobre,
    Expression<String>? textoMostrado,
    Expression<String>? documentoFotoId,
    Expression<int>? otorgadoEn,
    Expression<String>? revocaA,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circuloId != null) 'circulo_id': circuloId,
      if (otorgante != null) 'otorgante': otorgante,
      if (enNombreDe != null) 'en_nombre_de': enNombreDe,
      if (sobre != null) 'sobre': sobre,
      if (textoMostrado != null) 'texto_mostrado': textoMostrado,
      if (documentoFotoId != null) 'documento_foto_id': documentoFotoId,
      if (otorgadoEn != null) 'otorgado_en': otorgadoEn,
      if (revocaA != null) 'revoca_a': revocaA,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsentimientosCompanion copyWith({
    Value<String>? id,
    Value<String>? circuloId,
    Value<String>? otorgante,
    Value<String?>? enNombreDe,
    Value<String>? sobre,
    Value<String>? textoMostrado,
    Value<String?>? documentoFotoId,
    Value<int>? otorgadoEn,
    Value<String?>? revocaA,
    Value<int>? rowid,
  }) {
    return ConsentimientosCompanion(
      id: id ?? this.id,
      circuloId: circuloId ?? this.circuloId,
      otorgante: otorgante ?? this.otorgante,
      enNombreDe: enNombreDe ?? this.enNombreDe,
      sobre: sobre ?? this.sobre,
      textoMostrado: textoMostrado ?? this.textoMostrado,
      documentoFotoId: documentoFotoId ?? this.documentoFotoId,
      otorgadoEn: otorgadoEn ?? this.otorgadoEn,
      revocaA: revocaA ?? this.revocaA,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circuloId.present) {
      map['circulo_id'] = Variable<String>(circuloId.value);
    }
    if (otorgante.present) {
      map['otorgante'] = Variable<String>(otorgante.value);
    }
    if (enNombreDe.present) {
      map['en_nombre_de'] = Variable<String>(enNombreDe.value);
    }
    if (sobre.present) {
      map['sobre'] = Variable<String>(sobre.value);
    }
    if (textoMostrado.present) {
      map['texto_mostrado'] = Variable<String>(textoMostrado.value);
    }
    if (documentoFotoId.present) {
      map['documento_foto_id'] = Variable<String>(documentoFotoId.value);
    }
    if (otorgadoEn.present) {
      map['otorgado_en'] = Variable<int>(otorgadoEn.value);
    }
    if (revocaA.present) {
      map['revoca_a'] = Variable<String>(revocaA.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsentimientosCompanion(')
          ..write('id: $id, ')
          ..write('circuloId: $circuloId, ')
          ..write('otorgante: $otorgante, ')
          ..write('enNombreDe: $enNombreDe, ')
          ..write('sobre: $sobre, ')
          ..write('textoMostrado: $textoMostrado, ')
          ..write('documentoFotoId: $documentoFotoId, ')
          ..write('otorgadoEn: $otorgadoEn, ')
          ..write('revocaA: $revocaA, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VocesTable extends Voces with TableInfo<$VocesTable, Voz> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _miembroIdMeta = const VerificationMeta(
    'miembroId',
  );
  @override
  late final GeneratedColumn<String> miembroId = GeneratedColumn<String>(
    'miembro_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES miembros (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeloMeta = const VerificationMeta('modelo');
  @override
  late final GeneratedColumn<String> modelo = GeneratedColumn<String>(
    'modelo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consentimientoIdMeta = const VerificationMeta(
    'consentimientoId',
  );
  @override
  late final GeneratedColumn<String> consentimientoId = GeneratedColumn<String>(
    'consentimiento_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consentimientos (id)',
    ),
  );
  static const VerificationMeta _creadaEnMeta = const VerificationMeta(
    'creadaEn',
  );
  @override
  late final GeneratedColumn<int> creadaEn = GeneratedColumn<int>(
    'creada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retiradaEnMeta = const VerificationMeta(
    'retiradaEn',
  );
  @override
  late final GeneratedColumn<int> retiradaEn = GeneratedColumn<int>(
    'retirada_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    miembroId,
    tipo,
    modelo,
    consentimientoId,
    creadaEn,
    retiradaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Voz> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('miembro_id')) {
      context.handle(
        _miembroIdMeta,
        miembroId.isAcceptableOrUnknown(data['miembro_id']!, _miembroIdMeta),
      );
    } else if (isInserting) {
      context.missing(_miembroIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('modelo')) {
      context.handle(
        _modeloMeta,
        modelo.isAcceptableOrUnknown(data['modelo']!, _modeloMeta),
      );
    }
    if (data.containsKey('consentimiento_id')) {
      context.handle(
        _consentimientoIdMeta,
        consentimientoId.isAcceptableOrUnknown(
          data['consentimiento_id']!,
          _consentimientoIdMeta,
        ),
      );
    }
    if (data.containsKey('creada_en')) {
      context.handle(
        _creadaEnMeta,
        creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaEnMeta);
    }
    if (data.containsKey('retirada_en')) {
      context.handle(
        _retiradaEnMeta,
        retiradaEn.isAcceptableOrUnknown(data['retirada_en']!, _retiradaEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Voz map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Voz(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      miembroId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}miembro_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      modelo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modelo'],
      ),
      consentimientoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consentimiento_id'],
      ),
      creadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creada_en'],
      )!,
      retiradaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retirada_en'],
      ),
    );
  }

  @override
  $VocesTable createAlias(String alias) {
    return $VocesTable(attachedDatabase, alias);
  }
}

class Voz extends DataClass implements Insertable<Voz> {
  final String id;
  final String miembroId;

  /// `grabada` o `generada`.
  final String tipo;
  final String? modelo;
  final String? consentimientoId;
  final int creadaEn;
  final int? retiradaEn;
  const Voz({
    required this.id,
    required this.miembroId,
    required this.tipo,
    this.modelo,
    this.consentimientoId,
    required this.creadaEn,
    this.retiradaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['miembro_id'] = Variable<String>(miembroId);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || modelo != null) {
      map['modelo'] = Variable<String>(modelo);
    }
    if (!nullToAbsent || consentimientoId != null) {
      map['consentimiento_id'] = Variable<String>(consentimientoId);
    }
    map['creada_en'] = Variable<int>(creadaEn);
    if (!nullToAbsent || retiradaEn != null) {
      map['retirada_en'] = Variable<int>(retiradaEn);
    }
    return map;
  }

  VocesCompanion toCompanion(bool nullToAbsent) {
    return VocesCompanion(
      id: Value(id),
      miembroId: Value(miembroId),
      tipo: Value(tipo),
      modelo: modelo == null && nullToAbsent
          ? const Value.absent()
          : Value(modelo),
      consentimientoId: consentimientoId == null && nullToAbsent
          ? const Value.absent()
          : Value(consentimientoId),
      creadaEn: Value(creadaEn),
      retiradaEn: retiradaEn == null && nullToAbsent
          ? const Value.absent()
          : Value(retiradaEn),
    );
  }

  factory Voz.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Voz(
      id: serializer.fromJson<String>(json['id']),
      miembroId: serializer.fromJson<String>(json['miembroId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      modelo: serializer.fromJson<String?>(json['modelo']),
      consentimientoId: serializer.fromJson<String?>(json['consentimientoId']),
      creadaEn: serializer.fromJson<int>(json['creadaEn']),
      retiradaEn: serializer.fromJson<int?>(json['retiradaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'miembroId': serializer.toJson<String>(miembroId),
      'tipo': serializer.toJson<String>(tipo),
      'modelo': serializer.toJson<String?>(modelo),
      'consentimientoId': serializer.toJson<String?>(consentimientoId),
      'creadaEn': serializer.toJson<int>(creadaEn),
      'retiradaEn': serializer.toJson<int?>(retiradaEn),
    };
  }

  Voz copyWith({
    String? id,
    String? miembroId,
    String? tipo,
    Value<String?> modelo = const Value.absent(),
    Value<String?> consentimientoId = const Value.absent(),
    int? creadaEn,
    Value<int?> retiradaEn = const Value.absent(),
  }) => Voz(
    id: id ?? this.id,
    miembroId: miembroId ?? this.miembroId,
    tipo: tipo ?? this.tipo,
    modelo: modelo.present ? modelo.value : this.modelo,
    consentimientoId: consentimientoId.present
        ? consentimientoId.value
        : this.consentimientoId,
    creadaEn: creadaEn ?? this.creadaEn,
    retiradaEn: retiradaEn.present ? retiradaEn.value : this.retiradaEn,
  );
  Voz copyWithCompanion(VocesCompanion data) {
    return Voz(
      id: data.id.present ? data.id.value : this.id,
      miembroId: data.miembroId.present ? data.miembroId.value : this.miembroId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      modelo: data.modelo.present ? data.modelo.value : this.modelo,
      consentimientoId: data.consentimientoId.present
          ? data.consentimientoId.value
          : this.consentimientoId,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
      retiradaEn: data.retiradaEn.present
          ? data.retiradaEn.value
          : this.retiradaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Voz(')
          ..write('id: $id, ')
          ..write('miembroId: $miembroId, ')
          ..write('tipo: $tipo, ')
          ..write('modelo: $modelo, ')
          ..write('consentimientoId: $consentimientoId, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('retiradaEn: $retiradaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    miembroId,
    tipo,
    modelo,
    consentimientoId,
    creadaEn,
    retiradaEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Voz &&
          other.id == this.id &&
          other.miembroId == this.miembroId &&
          other.tipo == this.tipo &&
          other.modelo == this.modelo &&
          other.consentimientoId == this.consentimientoId &&
          other.creadaEn == this.creadaEn &&
          other.retiradaEn == this.retiradaEn);
}

class VocesCompanion extends UpdateCompanion<Voz> {
  final Value<String> id;
  final Value<String> miembroId;
  final Value<String> tipo;
  final Value<String?> modelo;
  final Value<String?> consentimientoId;
  final Value<int> creadaEn;
  final Value<int?> retiradaEn;
  final Value<int> rowid;
  const VocesCompanion({
    this.id = const Value.absent(),
    this.miembroId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.modelo = const Value.absent(),
    this.consentimientoId = const Value.absent(),
    this.creadaEn = const Value.absent(),
    this.retiradaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VocesCompanion.insert({
    required String id,
    required String miembroId,
    required String tipo,
    this.modelo = const Value.absent(),
    this.consentimientoId = const Value.absent(),
    required int creadaEn,
    this.retiradaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       miembroId = Value(miembroId),
       tipo = Value(tipo),
       creadaEn = Value(creadaEn);
  static Insertable<Voz> custom({
    Expression<String>? id,
    Expression<String>? miembroId,
    Expression<String>? tipo,
    Expression<String>? modelo,
    Expression<String>? consentimientoId,
    Expression<int>? creadaEn,
    Expression<int>? retiradaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (miembroId != null) 'miembro_id': miembroId,
      if (tipo != null) 'tipo': tipo,
      if (modelo != null) 'modelo': modelo,
      if (consentimientoId != null) 'consentimiento_id': consentimientoId,
      if (creadaEn != null) 'creada_en': creadaEn,
      if (retiradaEn != null) 'retirada_en': retiradaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VocesCompanion copyWith({
    Value<String>? id,
    Value<String>? miembroId,
    Value<String>? tipo,
    Value<String?>? modelo,
    Value<String?>? consentimientoId,
    Value<int>? creadaEn,
    Value<int?>? retiradaEn,
    Value<int>? rowid,
  }) {
    return VocesCompanion(
      id: id ?? this.id,
      miembroId: miembroId ?? this.miembroId,
      tipo: tipo ?? this.tipo,
      modelo: modelo ?? this.modelo,
      consentimientoId: consentimientoId ?? this.consentimientoId,
      creadaEn: creadaEn ?? this.creadaEn,
      retiradaEn: retiradaEn ?? this.retiradaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (miembroId.present) {
      map['miembro_id'] = Variable<String>(miembroId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (modelo.present) {
      map['modelo'] = Variable<String>(modelo.value);
    }
    if (consentimientoId.present) {
      map['consentimiento_id'] = Variable<String>(consentimientoId.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<int>(creadaEn.value);
    }
    if (retiradaEn.present) {
      map['retirada_en'] = Variable<int>(retiradaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocesCompanion(')
          ..write('id: $id, ')
          ..write('miembroId: $miembroId, ')
          ..write('tipo: $tipo, ')
          ..write('modelo: $modelo, ')
          ..write('consentimientoId: $consentimientoId, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('retiradaEn: $retiradaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FrasesTable extends Frases with TableInfo<$FrasesTable, Frase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FrasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vozIdMeta = const VerificationMeta('vozId');
  @override
  late final GeneratedColumn<String> vozId = GeneratedColumn<String>(
    'voz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES voces (id)',
    ),
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usoMeta = const VerificationMeta('uso');
  @override
  late final GeneratedColumn<String> uso = GeneratedColumn<String>(
    'uso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioRutaMeta = const VerificationMeta(
    'audioRuta',
  );
  @override
  late final GeneratedColumn<String> audioRuta = GeneratedColumn<String>(
    'audio_ruta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aprobadaMeta = const VerificationMeta(
    'aprobada',
  );
  @override
  late final GeneratedColumn<bool> aprobada = GeneratedColumn<bool>(
    'aprobada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aprobada" IN (0, 1))',
    ),
  );
  static const VerificationMeta _creadaEnMeta = const VerificationMeta(
    'creadaEn',
  );
  @override
  late final GeneratedColumn<int> creadaEn = GeneratedColumn<int>(
    'creada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vozId,
    texto,
    uso,
    audioRuta,
    aprobada,
    creadaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'frases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Frase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('voz_id')) {
      context.handle(
        _vozIdMeta,
        vozId.isAcceptableOrUnknown(data['voz_id']!, _vozIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vozIdMeta);
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('uso')) {
      context.handle(
        _usoMeta,
        uso.isAcceptableOrUnknown(data['uso']!, _usoMeta),
      );
    } else if (isInserting) {
      context.missing(_usoMeta);
    }
    if (data.containsKey('audio_ruta')) {
      context.handle(
        _audioRutaMeta,
        audioRuta.isAcceptableOrUnknown(data['audio_ruta']!, _audioRutaMeta),
      );
    }
    if (data.containsKey('aprobada')) {
      context.handle(
        _aprobadaMeta,
        aprobada.isAcceptableOrUnknown(data['aprobada']!, _aprobadaMeta),
      );
    } else if (isInserting) {
      context.missing(_aprobadaMeta);
    }
    if (data.containsKey('creada_en')) {
      context.handle(
        _creadaEnMeta,
        creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Frase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Frase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vozId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voz_id'],
      )!,
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      uso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uso'],
      )!,
      audioRuta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_ruta'],
      ),
      aprobada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aprobada'],
      )!,
      creadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creada_en'],
      )!,
    );
  }

  @override
  $FrasesTable createAlias(String alias) {
    return $FrasesTable(attachedDatabase, alias);
  }
}

class Frase extends DataClass implements Insertable<Frase> {
  final String id;
  final String vozId;
  final String texto;
  final String uso;
  final String? audioRuta;
  final bool aprobada;
  final int creadaEn;
  const Frase({
    required this.id,
    required this.vozId,
    required this.texto,
    required this.uso,
    this.audioRuta,
    required this.aprobada,
    required this.creadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['voz_id'] = Variable<String>(vozId);
    map['texto'] = Variable<String>(texto);
    map['uso'] = Variable<String>(uso);
    if (!nullToAbsent || audioRuta != null) {
      map['audio_ruta'] = Variable<String>(audioRuta);
    }
    map['aprobada'] = Variable<bool>(aprobada);
    map['creada_en'] = Variable<int>(creadaEn);
    return map;
  }

  FrasesCompanion toCompanion(bool nullToAbsent) {
    return FrasesCompanion(
      id: Value(id),
      vozId: Value(vozId),
      texto: Value(texto),
      uso: Value(uso),
      audioRuta: audioRuta == null && nullToAbsent
          ? const Value.absent()
          : Value(audioRuta),
      aprobada: Value(aprobada),
      creadaEn: Value(creadaEn),
    );
  }

  factory Frase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Frase(
      id: serializer.fromJson<String>(json['id']),
      vozId: serializer.fromJson<String>(json['vozId']),
      texto: serializer.fromJson<String>(json['texto']),
      uso: serializer.fromJson<String>(json['uso']),
      audioRuta: serializer.fromJson<String?>(json['audioRuta']),
      aprobada: serializer.fromJson<bool>(json['aprobada']),
      creadaEn: serializer.fromJson<int>(json['creadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vozId': serializer.toJson<String>(vozId),
      'texto': serializer.toJson<String>(texto),
      'uso': serializer.toJson<String>(uso),
      'audioRuta': serializer.toJson<String?>(audioRuta),
      'aprobada': serializer.toJson<bool>(aprobada),
      'creadaEn': serializer.toJson<int>(creadaEn),
    };
  }

  Frase copyWith({
    String? id,
    String? vozId,
    String? texto,
    String? uso,
    Value<String?> audioRuta = const Value.absent(),
    bool? aprobada,
    int? creadaEn,
  }) => Frase(
    id: id ?? this.id,
    vozId: vozId ?? this.vozId,
    texto: texto ?? this.texto,
    uso: uso ?? this.uso,
    audioRuta: audioRuta.present ? audioRuta.value : this.audioRuta,
    aprobada: aprobada ?? this.aprobada,
    creadaEn: creadaEn ?? this.creadaEn,
  );
  Frase copyWithCompanion(FrasesCompanion data) {
    return Frase(
      id: data.id.present ? data.id.value : this.id,
      vozId: data.vozId.present ? data.vozId.value : this.vozId,
      texto: data.texto.present ? data.texto.value : this.texto,
      uso: data.uso.present ? data.uso.value : this.uso,
      audioRuta: data.audioRuta.present ? data.audioRuta.value : this.audioRuta,
      aprobada: data.aprobada.present ? data.aprobada.value : this.aprobada,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Frase(')
          ..write('id: $id, ')
          ..write('vozId: $vozId, ')
          ..write('texto: $texto, ')
          ..write('uso: $uso, ')
          ..write('audioRuta: $audioRuta, ')
          ..write('aprobada: $aprobada, ')
          ..write('creadaEn: $creadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vozId, texto, uso, audioRuta, aprobada, creadaEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Frase &&
          other.id == this.id &&
          other.vozId == this.vozId &&
          other.texto == this.texto &&
          other.uso == this.uso &&
          other.audioRuta == this.audioRuta &&
          other.aprobada == this.aprobada &&
          other.creadaEn == this.creadaEn);
}

class FrasesCompanion extends UpdateCompanion<Frase> {
  final Value<String> id;
  final Value<String> vozId;
  final Value<String> texto;
  final Value<String> uso;
  final Value<String?> audioRuta;
  final Value<bool> aprobada;
  final Value<int> creadaEn;
  final Value<int> rowid;
  const FrasesCompanion({
    this.id = const Value.absent(),
    this.vozId = const Value.absent(),
    this.texto = const Value.absent(),
    this.uso = const Value.absent(),
    this.audioRuta = const Value.absent(),
    this.aprobada = const Value.absent(),
    this.creadaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FrasesCompanion.insert({
    required String id,
    required String vozId,
    required String texto,
    required String uso,
    this.audioRuta = const Value.absent(),
    required bool aprobada,
    required int creadaEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vozId = Value(vozId),
       texto = Value(texto),
       uso = Value(uso),
       aprobada = Value(aprobada),
       creadaEn = Value(creadaEn);
  static Insertable<Frase> custom({
    Expression<String>? id,
    Expression<String>? vozId,
    Expression<String>? texto,
    Expression<String>? uso,
    Expression<String>? audioRuta,
    Expression<bool>? aprobada,
    Expression<int>? creadaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vozId != null) 'voz_id': vozId,
      if (texto != null) 'texto': texto,
      if (uso != null) 'uso': uso,
      if (audioRuta != null) 'audio_ruta': audioRuta,
      if (aprobada != null) 'aprobada': aprobada,
      if (creadaEn != null) 'creada_en': creadaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FrasesCompanion copyWith({
    Value<String>? id,
    Value<String>? vozId,
    Value<String>? texto,
    Value<String>? uso,
    Value<String?>? audioRuta,
    Value<bool>? aprobada,
    Value<int>? creadaEn,
    Value<int>? rowid,
  }) {
    return FrasesCompanion(
      id: id ?? this.id,
      vozId: vozId ?? this.vozId,
      texto: texto ?? this.texto,
      uso: uso ?? this.uso,
      audioRuta: audioRuta ?? this.audioRuta,
      aprobada: aprobada ?? this.aprobada,
      creadaEn: creadaEn ?? this.creadaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vozId.present) {
      map['voz_id'] = Variable<String>(vozId.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (uso.present) {
      map['uso'] = Variable<String>(uso.value);
    }
    if (audioRuta.present) {
      map['audio_ruta'] = Variable<String>(audioRuta.value);
    }
    if (aprobada.present) {
      map['aprobada'] = Variable<bool>(aprobada.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<int>(creadaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FrasesCompanion(')
          ..write('id: $id, ')
          ..write('vozId: $vozId, ')
          ..write('texto: $texto, ')
          ..write('uso: $uso, ')
          ..write('audioRuta: $audioRuta, ')
          ..write('aprobada: $aprobada, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PautasTable extends Pautas with TableInfo<$PautasTable, Pauta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PautasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pautaIdMeta = const VerificationMeta(
    'pautaId',
  );
  @override
  late final GeneratedColumn<String> pautaId = GeneratedColumn<String>(
    'pauta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicamentoIdMeta = const VerificationMeta(
    'medicamentoId',
  );
  @override
  late final GeneratedColumn<String> medicamentoId = GeneratedColumn<String>(
    'medicamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicamentos (id)',
    ),
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personas (id)',
    ),
  );
  static const VerificationMeta _dosisMeta = const VerificationMeta('dosis');
  @override
  late final GeneratedColumn<String> dosis = GeneratedColumn<String>(
    'dosis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horasMeta = const VerificationMeta('horas');
  @override
  late final GeneratedColumn<String> horas = GeneratedColumn<String>(
    'horas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diasSemanaMeta = const VerificationMeta(
    'diasSemana',
  );
  @override
  late final GeneratedColumn<int> diasSemana = GeneratedColumn<int>(
    'dias_semana',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _compartimentoMeta = const VerificationMeta(
    'compartimento',
  );
  @override
  late final GeneratedColumn<String> compartimento = GeneratedColumn<String>(
    'compartimento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vozIdMeta = const VerificationMeta('vozId');
  @override
  late final GeneratedColumn<String> vozId = GeneratedColumn<String>(
    'voz_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES voces (id)',
    ),
  );
  static const VerificationMeta _comprobacionMeta = const VerificationMeta(
    'comprobacion',
  );
  @override
  late final GeneratedColumn<String> comprobacion = GeneratedColumn<String>(
    'comprobacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('video'),
  );
  static const VerificationMeta _segundosVideoMeta = const VerificationMeta(
    'segundosVideo',
  );
  @override
  late final GeneratedColumn<int> segundosVideo = GeneratedColumn<int>(
    'segundos_video',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _zonaHorariaMeta = const VerificationMeta(
    'zonaHoraria',
  );
  @override
  late final GeneratedColumn<String> zonaHoraria = GeneratedColumn<String>(
    'zona_horaria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vigenteDesdeMeta = const VerificationMeta(
    'vigenteDesde',
  );
  @override
  late final GeneratedColumn<int> vigenteDesde = GeneratedColumn<int>(
    'vigente_desde',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activaMeta = const VerificationMeta('activa');
  @override
  late final GeneratedColumn<bool> activa = GeneratedColumn<bool>(
    'activa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activa" IN (0, 1))',
    ),
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadaPorMeta = const VerificationMeta(
    'creadaPor',
  );
  @override
  late final GeneratedColumn<String> creadaPor = GeneratedColumn<String>(
    'creada_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creadaEnMeta = const VerificationMeta(
    'creadaEn',
  );
  @override
  late final GeneratedColumn<int> creadaEn = GeneratedColumn<int>(
    'creada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pautaId,
    version,
    medicamentoId,
    personaId,
    dosis,
    horas,
    diasSemana,
    compartimento,
    vozId,
    comprobacion,
    segundosVideo,
    zonaHoraria,
    vigenteDesde,
    activa,
    motivo,
    creadaPor,
    creadaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pautas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pauta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pauta_id')) {
      context.handle(
        _pautaIdMeta,
        pautaId.isAcceptableOrUnknown(data['pauta_id']!, _pautaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pautaIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('medicamento_id')) {
      context.handle(
        _medicamentoIdMeta,
        medicamentoId.isAcceptableOrUnknown(
          data['medicamento_id']!,
          _medicamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicamentoIdMeta);
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personaIdMeta);
    }
    if (data.containsKey('dosis')) {
      context.handle(
        _dosisMeta,
        dosis.isAcceptableOrUnknown(data['dosis']!, _dosisMeta),
      );
    } else if (isInserting) {
      context.missing(_dosisMeta);
    }
    if (data.containsKey('horas')) {
      context.handle(
        _horasMeta,
        horas.isAcceptableOrUnknown(data['horas']!, _horasMeta),
      );
    } else if (isInserting) {
      context.missing(_horasMeta);
    }
    if (data.containsKey('dias_semana')) {
      context.handle(
        _diasSemanaMeta,
        diasSemana.isAcceptableOrUnknown(data['dias_semana']!, _diasSemanaMeta),
      );
    }
    if (data.containsKey('compartimento')) {
      context.handle(
        _compartimentoMeta,
        compartimento.isAcceptableOrUnknown(
          data['compartimento']!,
          _compartimentoMeta,
        ),
      );
    }
    if (data.containsKey('voz_id')) {
      context.handle(
        _vozIdMeta,
        vozId.isAcceptableOrUnknown(data['voz_id']!, _vozIdMeta),
      );
    }
    if (data.containsKey('comprobacion')) {
      context.handle(
        _comprobacionMeta,
        comprobacion.isAcceptableOrUnknown(
          data['comprobacion']!,
          _comprobacionMeta,
        ),
      );
    }
    if (data.containsKey('segundos_video')) {
      context.handle(
        _segundosVideoMeta,
        segundosVideo.isAcceptableOrUnknown(
          data['segundos_video']!,
          _segundosVideoMeta,
        ),
      );
    }
    if (data.containsKey('zona_horaria')) {
      context.handle(
        _zonaHorariaMeta,
        zonaHoraria.isAcceptableOrUnknown(
          data['zona_horaria']!,
          _zonaHorariaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_zonaHorariaMeta);
    }
    if (data.containsKey('vigente_desde')) {
      context.handle(
        _vigenteDesdeMeta,
        vigenteDesde.isAcceptableOrUnknown(
          data['vigente_desde']!,
          _vigenteDesdeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vigenteDesdeMeta);
    }
    if (data.containsKey('activa')) {
      context.handle(
        _activaMeta,
        activa.isAcceptableOrUnknown(data['activa']!, _activaMeta),
      );
    } else if (isInserting) {
      context.missing(_activaMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('creada_por')) {
      context.handle(
        _creadaPorMeta,
        creadaPor.isAcceptableOrUnknown(data['creada_por']!, _creadaPorMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaPorMeta);
    }
    if (data.containsKey('creada_en')) {
      context.handle(
        _creadaEnMeta,
        creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pautaId, version},
  ];
  @override
  Pauta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pauta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pautaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pauta_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      medicamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicamento_id'],
      )!,
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      )!,
      dosis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosis'],
      )!,
      horas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horas'],
      )!,
      diasSemana: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_semana'],
      )!,
      compartimento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compartimento'],
      ),
      vozId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voz_id'],
      ),
      comprobacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comprobacion'],
      )!,
      segundosVideo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segundos_video'],
      )!,
      zonaHoraria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zona_horaria'],
      )!,
      vigenteDesde: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vigente_desde'],
      )!,
      activa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activa'],
      )!,
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      ),
      creadaPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creada_por'],
      )!,
      creadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creada_en'],
      )!,
    );
  }

  @override
  $PautasTable createAlias(String alias) {
    return $PautasTable(attachedDatabase, alias);
  }
}

class Pauta extends DataClass implements Insertable<Pauta> {
  /// Id de la versión.
  final String id;

  /// Id lógico de la pauta, común a todas sus versiones.
  final String pautaId;
  final int version;
  final String medicamentoId;
  final String personaId;
  final String dosis;

  /// JSON `["09:00","14:00"]`, ordenadas y sin repetir.
  final String horas;
  final int diasSemana;
  final String? compartimento;
  final String? vozId;

  /// `video`, `foto` o `ninguna`.
  final String comprobacion;
  final int segundosVideo;
  final String zonaHoraria;
  final int vigenteDesde;
  final bool activa;
  final String? motivo;
  final String creadaPor;
  final int creadaEn;
  const Pauta({
    required this.id,
    required this.pautaId,
    required this.version,
    required this.medicamentoId,
    required this.personaId,
    required this.dosis,
    required this.horas,
    required this.diasSemana,
    this.compartimento,
    this.vozId,
    required this.comprobacion,
    required this.segundosVideo,
    required this.zonaHoraria,
    required this.vigenteDesde,
    required this.activa,
    this.motivo,
    required this.creadaPor,
    required this.creadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pauta_id'] = Variable<String>(pautaId);
    map['version'] = Variable<int>(version);
    map['medicamento_id'] = Variable<String>(medicamentoId);
    map['persona_id'] = Variable<String>(personaId);
    map['dosis'] = Variable<String>(dosis);
    map['horas'] = Variable<String>(horas);
    map['dias_semana'] = Variable<int>(diasSemana);
    if (!nullToAbsent || compartimento != null) {
      map['compartimento'] = Variable<String>(compartimento);
    }
    if (!nullToAbsent || vozId != null) {
      map['voz_id'] = Variable<String>(vozId);
    }
    map['comprobacion'] = Variable<String>(comprobacion);
    map['segundos_video'] = Variable<int>(segundosVideo);
    map['zona_horaria'] = Variable<String>(zonaHoraria);
    map['vigente_desde'] = Variable<int>(vigenteDesde);
    map['activa'] = Variable<bool>(activa);
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    map['creada_por'] = Variable<String>(creadaPor);
    map['creada_en'] = Variable<int>(creadaEn);
    return map;
  }

  PautasCompanion toCompanion(bool nullToAbsent) {
    return PautasCompanion(
      id: Value(id),
      pautaId: Value(pautaId),
      version: Value(version),
      medicamentoId: Value(medicamentoId),
      personaId: Value(personaId),
      dosis: Value(dosis),
      horas: Value(horas),
      diasSemana: Value(diasSemana),
      compartimento: compartimento == null && nullToAbsent
          ? const Value.absent()
          : Value(compartimento),
      vozId: vozId == null && nullToAbsent
          ? const Value.absent()
          : Value(vozId),
      comprobacion: Value(comprobacion),
      segundosVideo: Value(segundosVideo),
      zonaHoraria: Value(zonaHoraria),
      vigenteDesde: Value(vigenteDesde),
      activa: Value(activa),
      motivo: motivo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivo),
      creadaPor: Value(creadaPor),
      creadaEn: Value(creadaEn),
    );
  }

  factory Pauta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pauta(
      id: serializer.fromJson<String>(json['id']),
      pautaId: serializer.fromJson<String>(json['pautaId']),
      version: serializer.fromJson<int>(json['version']),
      medicamentoId: serializer.fromJson<String>(json['medicamentoId']),
      personaId: serializer.fromJson<String>(json['personaId']),
      dosis: serializer.fromJson<String>(json['dosis']),
      horas: serializer.fromJson<String>(json['horas']),
      diasSemana: serializer.fromJson<int>(json['diasSemana']),
      compartimento: serializer.fromJson<String?>(json['compartimento']),
      vozId: serializer.fromJson<String?>(json['vozId']),
      comprobacion: serializer.fromJson<String>(json['comprobacion']),
      segundosVideo: serializer.fromJson<int>(json['segundosVideo']),
      zonaHoraria: serializer.fromJson<String>(json['zonaHoraria']),
      vigenteDesde: serializer.fromJson<int>(json['vigenteDesde']),
      activa: serializer.fromJson<bool>(json['activa']),
      motivo: serializer.fromJson<String?>(json['motivo']),
      creadaPor: serializer.fromJson<String>(json['creadaPor']),
      creadaEn: serializer.fromJson<int>(json['creadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pautaId': serializer.toJson<String>(pautaId),
      'version': serializer.toJson<int>(version),
      'medicamentoId': serializer.toJson<String>(medicamentoId),
      'personaId': serializer.toJson<String>(personaId),
      'dosis': serializer.toJson<String>(dosis),
      'horas': serializer.toJson<String>(horas),
      'diasSemana': serializer.toJson<int>(diasSemana),
      'compartimento': serializer.toJson<String?>(compartimento),
      'vozId': serializer.toJson<String?>(vozId),
      'comprobacion': serializer.toJson<String>(comprobacion),
      'segundosVideo': serializer.toJson<int>(segundosVideo),
      'zonaHoraria': serializer.toJson<String>(zonaHoraria),
      'vigenteDesde': serializer.toJson<int>(vigenteDesde),
      'activa': serializer.toJson<bool>(activa),
      'motivo': serializer.toJson<String?>(motivo),
      'creadaPor': serializer.toJson<String>(creadaPor),
      'creadaEn': serializer.toJson<int>(creadaEn),
    };
  }

  Pauta copyWith({
    String? id,
    String? pautaId,
    int? version,
    String? medicamentoId,
    String? personaId,
    String? dosis,
    String? horas,
    int? diasSemana,
    Value<String?> compartimento = const Value.absent(),
    Value<String?> vozId = const Value.absent(),
    String? comprobacion,
    int? segundosVideo,
    String? zonaHoraria,
    int? vigenteDesde,
    bool? activa,
    Value<String?> motivo = const Value.absent(),
    String? creadaPor,
    int? creadaEn,
  }) => Pauta(
    id: id ?? this.id,
    pautaId: pautaId ?? this.pautaId,
    version: version ?? this.version,
    medicamentoId: medicamentoId ?? this.medicamentoId,
    personaId: personaId ?? this.personaId,
    dosis: dosis ?? this.dosis,
    horas: horas ?? this.horas,
    diasSemana: diasSemana ?? this.diasSemana,
    compartimento: compartimento.present
        ? compartimento.value
        : this.compartimento,
    vozId: vozId.present ? vozId.value : this.vozId,
    comprobacion: comprobacion ?? this.comprobacion,
    segundosVideo: segundosVideo ?? this.segundosVideo,
    zonaHoraria: zonaHoraria ?? this.zonaHoraria,
    vigenteDesde: vigenteDesde ?? this.vigenteDesde,
    activa: activa ?? this.activa,
    motivo: motivo.present ? motivo.value : this.motivo,
    creadaPor: creadaPor ?? this.creadaPor,
    creadaEn: creadaEn ?? this.creadaEn,
  );
  Pauta copyWithCompanion(PautasCompanion data) {
    return Pauta(
      id: data.id.present ? data.id.value : this.id,
      pautaId: data.pautaId.present ? data.pautaId.value : this.pautaId,
      version: data.version.present ? data.version.value : this.version,
      medicamentoId: data.medicamentoId.present
          ? data.medicamentoId.value
          : this.medicamentoId,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      dosis: data.dosis.present ? data.dosis.value : this.dosis,
      horas: data.horas.present ? data.horas.value : this.horas,
      diasSemana: data.diasSemana.present
          ? data.diasSemana.value
          : this.diasSemana,
      compartimento: data.compartimento.present
          ? data.compartimento.value
          : this.compartimento,
      vozId: data.vozId.present ? data.vozId.value : this.vozId,
      comprobacion: data.comprobacion.present
          ? data.comprobacion.value
          : this.comprobacion,
      segundosVideo: data.segundosVideo.present
          ? data.segundosVideo.value
          : this.segundosVideo,
      zonaHoraria: data.zonaHoraria.present
          ? data.zonaHoraria.value
          : this.zonaHoraria,
      vigenteDesde: data.vigenteDesde.present
          ? data.vigenteDesde.value
          : this.vigenteDesde,
      activa: data.activa.present ? data.activa.value : this.activa,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      creadaPor: data.creadaPor.present ? data.creadaPor.value : this.creadaPor,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pauta(')
          ..write('id: $id, ')
          ..write('pautaId: $pautaId, ')
          ..write('version: $version, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('personaId: $personaId, ')
          ..write('dosis: $dosis, ')
          ..write('horas: $horas, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('compartimento: $compartimento, ')
          ..write('vozId: $vozId, ')
          ..write('comprobacion: $comprobacion, ')
          ..write('segundosVideo: $segundosVideo, ')
          ..write('zonaHoraria: $zonaHoraria, ')
          ..write('vigenteDesde: $vigenteDesde, ')
          ..write('activa: $activa, ')
          ..write('motivo: $motivo, ')
          ..write('creadaPor: $creadaPor, ')
          ..write('creadaEn: $creadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pautaId,
    version,
    medicamentoId,
    personaId,
    dosis,
    horas,
    diasSemana,
    compartimento,
    vozId,
    comprobacion,
    segundosVideo,
    zonaHoraria,
    vigenteDesde,
    activa,
    motivo,
    creadaPor,
    creadaEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pauta &&
          other.id == this.id &&
          other.pautaId == this.pautaId &&
          other.version == this.version &&
          other.medicamentoId == this.medicamentoId &&
          other.personaId == this.personaId &&
          other.dosis == this.dosis &&
          other.horas == this.horas &&
          other.diasSemana == this.diasSemana &&
          other.compartimento == this.compartimento &&
          other.vozId == this.vozId &&
          other.comprobacion == this.comprobacion &&
          other.segundosVideo == this.segundosVideo &&
          other.zonaHoraria == this.zonaHoraria &&
          other.vigenteDesde == this.vigenteDesde &&
          other.activa == this.activa &&
          other.motivo == this.motivo &&
          other.creadaPor == this.creadaPor &&
          other.creadaEn == this.creadaEn);
}

class PautasCompanion extends UpdateCompanion<Pauta> {
  final Value<String> id;
  final Value<String> pautaId;
  final Value<int> version;
  final Value<String> medicamentoId;
  final Value<String> personaId;
  final Value<String> dosis;
  final Value<String> horas;
  final Value<int> diasSemana;
  final Value<String?> compartimento;
  final Value<String?> vozId;
  final Value<String> comprobacion;
  final Value<int> segundosVideo;
  final Value<String> zonaHoraria;
  final Value<int> vigenteDesde;
  final Value<bool> activa;
  final Value<String?> motivo;
  final Value<String> creadaPor;
  final Value<int> creadaEn;
  final Value<int> rowid;
  const PautasCompanion({
    this.id = const Value.absent(),
    this.pautaId = const Value.absent(),
    this.version = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.personaId = const Value.absent(),
    this.dosis = const Value.absent(),
    this.horas = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.compartimento = const Value.absent(),
    this.vozId = const Value.absent(),
    this.comprobacion = const Value.absent(),
    this.segundosVideo = const Value.absent(),
    this.zonaHoraria = const Value.absent(),
    this.vigenteDesde = const Value.absent(),
    this.activa = const Value.absent(),
    this.motivo = const Value.absent(),
    this.creadaPor = const Value.absent(),
    this.creadaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PautasCompanion.insert({
    required String id,
    required String pautaId,
    required int version,
    required String medicamentoId,
    required String personaId,
    required String dosis,
    required String horas,
    this.diasSemana = const Value.absent(),
    this.compartimento = const Value.absent(),
    this.vozId = const Value.absent(),
    this.comprobacion = const Value.absent(),
    this.segundosVideo = const Value.absent(),
    required String zonaHoraria,
    required int vigenteDesde,
    required bool activa,
    this.motivo = const Value.absent(),
    required String creadaPor,
    required int creadaEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pautaId = Value(pautaId),
       version = Value(version),
       medicamentoId = Value(medicamentoId),
       personaId = Value(personaId),
       dosis = Value(dosis),
       horas = Value(horas),
       zonaHoraria = Value(zonaHoraria),
       vigenteDesde = Value(vigenteDesde),
       activa = Value(activa),
       creadaPor = Value(creadaPor),
       creadaEn = Value(creadaEn);
  static Insertable<Pauta> custom({
    Expression<String>? id,
    Expression<String>? pautaId,
    Expression<int>? version,
    Expression<String>? medicamentoId,
    Expression<String>? personaId,
    Expression<String>? dosis,
    Expression<String>? horas,
    Expression<int>? diasSemana,
    Expression<String>? compartimento,
    Expression<String>? vozId,
    Expression<String>? comprobacion,
    Expression<int>? segundosVideo,
    Expression<String>? zonaHoraria,
    Expression<int>? vigenteDesde,
    Expression<bool>? activa,
    Expression<String>? motivo,
    Expression<String>? creadaPor,
    Expression<int>? creadaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pautaId != null) 'pauta_id': pautaId,
      if (version != null) 'version': version,
      if (medicamentoId != null) 'medicamento_id': medicamentoId,
      if (personaId != null) 'persona_id': personaId,
      if (dosis != null) 'dosis': dosis,
      if (horas != null) 'horas': horas,
      if (diasSemana != null) 'dias_semana': diasSemana,
      if (compartimento != null) 'compartimento': compartimento,
      if (vozId != null) 'voz_id': vozId,
      if (comprobacion != null) 'comprobacion': comprobacion,
      if (segundosVideo != null) 'segundos_video': segundosVideo,
      if (zonaHoraria != null) 'zona_horaria': zonaHoraria,
      if (vigenteDesde != null) 'vigente_desde': vigenteDesde,
      if (activa != null) 'activa': activa,
      if (motivo != null) 'motivo': motivo,
      if (creadaPor != null) 'creada_por': creadaPor,
      if (creadaEn != null) 'creada_en': creadaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PautasCompanion copyWith({
    Value<String>? id,
    Value<String>? pautaId,
    Value<int>? version,
    Value<String>? medicamentoId,
    Value<String>? personaId,
    Value<String>? dosis,
    Value<String>? horas,
    Value<int>? diasSemana,
    Value<String?>? compartimento,
    Value<String?>? vozId,
    Value<String>? comprobacion,
    Value<int>? segundosVideo,
    Value<String>? zonaHoraria,
    Value<int>? vigenteDesde,
    Value<bool>? activa,
    Value<String?>? motivo,
    Value<String>? creadaPor,
    Value<int>? creadaEn,
    Value<int>? rowid,
  }) {
    return PautasCompanion(
      id: id ?? this.id,
      pautaId: pautaId ?? this.pautaId,
      version: version ?? this.version,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      personaId: personaId ?? this.personaId,
      dosis: dosis ?? this.dosis,
      horas: horas ?? this.horas,
      diasSemana: diasSemana ?? this.diasSemana,
      compartimento: compartimento ?? this.compartimento,
      vozId: vozId ?? this.vozId,
      comprobacion: comprobacion ?? this.comprobacion,
      segundosVideo: segundosVideo ?? this.segundosVideo,
      zonaHoraria: zonaHoraria ?? this.zonaHoraria,
      vigenteDesde: vigenteDesde ?? this.vigenteDesde,
      activa: activa ?? this.activa,
      motivo: motivo ?? this.motivo,
      creadaPor: creadaPor ?? this.creadaPor,
      creadaEn: creadaEn ?? this.creadaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pautaId.present) {
      map['pauta_id'] = Variable<String>(pautaId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (medicamentoId.present) {
      map['medicamento_id'] = Variable<String>(medicamentoId.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (dosis.present) {
      map['dosis'] = Variable<String>(dosis.value);
    }
    if (horas.present) {
      map['horas'] = Variable<String>(horas.value);
    }
    if (diasSemana.present) {
      map['dias_semana'] = Variable<int>(diasSemana.value);
    }
    if (compartimento.present) {
      map['compartimento'] = Variable<String>(compartimento.value);
    }
    if (vozId.present) {
      map['voz_id'] = Variable<String>(vozId.value);
    }
    if (comprobacion.present) {
      map['comprobacion'] = Variable<String>(comprobacion.value);
    }
    if (segundosVideo.present) {
      map['segundos_video'] = Variable<int>(segundosVideo.value);
    }
    if (zonaHoraria.present) {
      map['zona_horaria'] = Variable<String>(zonaHoraria.value);
    }
    if (vigenteDesde.present) {
      map['vigente_desde'] = Variable<int>(vigenteDesde.value);
    }
    if (activa.present) {
      map['activa'] = Variable<bool>(activa.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (creadaPor.present) {
      map['creada_por'] = Variable<String>(creadaPor.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<int>(creadaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PautasCompanion(')
          ..write('id: $id, ')
          ..write('pautaId: $pautaId, ')
          ..write('version: $version, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('personaId: $personaId, ')
          ..write('dosis: $dosis, ')
          ..write('horas: $horas, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('compartimento: $compartimento, ')
          ..write('vozId: $vozId, ')
          ..write('comprobacion: $comprobacion, ')
          ..write('segundosVideo: $segundosVideo, ')
          ..write('zonaHoraria: $zonaHoraria, ')
          ..write('vigenteDesde: $vigenteDesde, ')
          ..write('activa: $activa, ')
          ..write('motivo: $motivo, ')
          ..write('creadaPor: $creadaPor, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TomasTable extends Tomas with TableInfo<$TomasTable, Toma> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TomasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pautaVersionIdMeta = const VerificationMeta(
    'pautaVersionId',
  );
  @override
  late final GeneratedColumn<String> pautaVersionId = GeneratedColumn<String>(
    'pauta_version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pautas (id)',
    ),
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personas (id)',
    ),
  );
  static const VerificationMeta _previstaParaMeta = const VerificationMeta(
    'previstaPara',
  );
  @override
  late final GeneratedColumn<int> previstaPara = GeneratedColumn<int>(
    'prevista_para',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaLocalMeta = const VerificationMeta(
    'fechaLocal',
  );
  @override
  late final GeneratedColumn<String> fechaLocal = GeneratedColumn<String>(
    'fecha_local',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horaLocalMeta = const VerificationMeta(
    'horaLocal',
  );
  @override
  late final GeneratedColumn<String> horaLocal = GeneratedColumn<String>(
    'hora_local',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creadaEnMeta = const VerificationMeta(
    'creadaEn',
  );
  @override
  late final GeneratedColumn<int> creadaEn = GeneratedColumn<int>(
    'creada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pautaVersionId,
    personaId,
    previstaPara,
    fechaLocal,
    horaLocal,
    creadaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tomas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Toma> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pauta_version_id')) {
      context.handle(
        _pautaVersionIdMeta,
        pautaVersionId.isAcceptableOrUnknown(
          data['pauta_version_id']!,
          _pautaVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pautaVersionIdMeta);
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personaIdMeta);
    }
    if (data.containsKey('prevista_para')) {
      context.handle(
        _previstaParaMeta,
        previstaPara.isAcceptableOrUnknown(
          data['prevista_para']!,
          _previstaParaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previstaParaMeta);
    }
    if (data.containsKey('fecha_local')) {
      context.handle(
        _fechaLocalMeta,
        fechaLocal.isAcceptableOrUnknown(data['fecha_local']!, _fechaLocalMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaLocalMeta);
    }
    if (data.containsKey('hora_local')) {
      context.handle(
        _horaLocalMeta,
        horaLocal.isAcceptableOrUnknown(data['hora_local']!, _horaLocalMeta),
      );
    } else if (isInserting) {
      context.missing(_horaLocalMeta);
    }
    if (data.containsKey('creada_en')) {
      context.handle(
        _creadaEnMeta,
        creadaEn.isAcceptableOrUnknown(data['creada_en']!, _creadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Toma map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Toma(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pautaVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pauta_version_id'],
      )!,
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      )!,
      previstaPara: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prevista_para'],
      )!,
      fechaLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_local'],
      )!,
      horaLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora_local'],
      )!,
      creadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creada_en'],
      )!,
    );
  }

  @override
  $TomasTable createAlias(String alias) {
    return $TomasTable(attachedDatabase, alias);
  }
}

class Toma extends DataClass implements Insertable<Toma> {
  final String id;
  final String pautaVersionId;
  final String personaId;
  final int previstaPara;
  final String fechaLocal;
  final String horaLocal;
  final int creadaEn;
  const Toma({
    required this.id,
    required this.pautaVersionId,
    required this.personaId,
    required this.previstaPara,
    required this.fechaLocal,
    required this.horaLocal,
    required this.creadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pauta_version_id'] = Variable<String>(pautaVersionId);
    map['persona_id'] = Variable<String>(personaId);
    map['prevista_para'] = Variable<int>(previstaPara);
    map['fecha_local'] = Variable<String>(fechaLocal);
    map['hora_local'] = Variable<String>(horaLocal);
    map['creada_en'] = Variable<int>(creadaEn);
    return map;
  }

  TomasCompanion toCompanion(bool nullToAbsent) {
    return TomasCompanion(
      id: Value(id),
      pautaVersionId: Value(pautaVersionId),
      personaId: Value(personaId),
      previstaPara: Value(previstaPara),
      fechaLocal: Value(fechaLocal),
      horaLocal: Value(horaLocal),
      creadaEn: Value(creadaEn),
    );
  }

  factory Toma.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Toma(
      id: serializer.fromJson<String>(json['id']),
      pautaVersionId: serializer.fromJson<String>(json['pautaVersionId']),
      personaId: serializer.fromJson<String>(json['personaId']),
      previstaPara: serializer.fromJson<int>(json['previstaPara']),
      fechaLocal: serializer.fromJson<String>(json['fechaLocal']),
      horaLocal: serializer.fromJson<String>(json['horaLocal']),
      creadaEn: serializer.fromJson<int>(json['creadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pautaVersionId': serializer.toJson<String>(pautaVersionId),
      'personaId': serializer.toJson<String>(personaId),
      'previstaPara': serializer.toJson<int>(previstaPara),
      'fechaLocal': serializer.toJson<String>(fechaLocal),
      'horaLocal': serializer.toJson<String>(horaLocal),
      'creadaEn': serializer.toJson<int>(creadaEn),
    };
  }

  Toma copyWith({
    String? id,
    String? pautaVersionId,
    String? personaId,
    int? previstaPara,
    String? fechaLocal,
    String? horaLocal,
    int? creadaEn,
  }) => Toma(
    id: id ?? this.id,
    pautaVersionId: pautaVersionId ?? this.pautaVersionId,
    personaId: personaId ?? this.personaId,
    previstaPara: previstaPara ?? this.previstaPara,
    fechaLocal: fechaLocal ?? this.fechaLocal,
    horaLocal: horaLocal ?? this.horaLocal,
    creadaEn: creadaEn ?? this.creadaEn,
  );
  Toma copyWithCompanion(TomasCompanion data) {
    return Toma(
      id: data.id.present ? data.id.value : this.id,
      pautaVersionId: data.pautaVersionId.present
          ? data.pautaVersionId.value
          : this.pautaVersionId,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      previstaPara: data.previstaPara.present
          ? data.previstaPara.value
          : this.previstaPara,
      fechaLocal: data.fechaLocal.present
          ? data.fechaLocal.value
          : this.fechaLocal,
      horaLocal: data.horaLocal.present ? data.horaLocal.value : this.horaLocal,
      creadaEn: data.creadaEn.present ? data.creadaEn.value : this.creadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Toma(')
          ..write('id: $id, ')
          ..write('pautaVersionId: $pautaVersionId, ')
          ..write('personaId: $personaId, ')
          ..write('previstaPara: $previstaPara, ')
          ..write('fechaLocal: $fechaLocal, ')
          ..write('horaLocal: $horaLocal, ')
          ..write('creadaEn: $creadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pautaVersionId,
    personaId,
    previstaPara,
    fechaLocal,
    horaLocal,
    creadaEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Toma &&
          other.id == this.id &&
          other.pautaVersionId == this.pautaVersionId &&
          other.personaId == this.personaId &&
          other.previstaPara == this.previstaPara &&
          other.fechaLocal == this.fechaLocal &&
          other.horaLocal == this.horaLocal &&
          other.creadaEn == this.creadaEn);
}

class TomasCompanion extends UpdateCompanion<Toma> {
  final Value<String> id;
  final Value<String> pautaVersionId;
  final Value<String> personaId;
  final Value<int> previstaPara;
  final Value<String> fechaLocal;
  final Value<String> horaLocal;
  final Value<int> creadaEn;
  final Value<int> rowid;
  const TomasCompanion({
    this.id = const Value.absent(),
    this.pautaVersionId = const Value.absent(),
    this.personaId = const Value.absent(),
    this.previstaPara = const Value.absent(),
    this.fechaLocal = const Value.absent(),
    this.horaLocal = const Value.absent(),
    this.creadaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TomasCompanion.insert({
    required String id,
    required String pautaVersionId,
    required String personaId,
    required int previstaPara,
    required String fechaLocal,
    required String horaLocal,
    required int creadaEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pautaVersionId = Value(pautaVersionId),
       personaId = Value(personaId),
       previstaPara = Value(previstaPara),
       fechaLocal = Value(fechaLocal),
       horaLocal = Value(horaLocal),
       creadaEn = Value(creadaEn);
  static Insertable<Toma> custom({
    Expression<String>? id,
    Expression<String>? pautaVersionId,
    Expression<String>? personaId,
    Expression<int>? previstaPara,
    Expression<String>? fechaLocal,
    Expression<String>? horaLocal,
    Expression<int>? creadaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pautaVersionId != null) 'pauta_version_id': pautaVersionId,
      if (personaId != null) 'persona_id': personaId,
      if (previstaPara != null) 'prevista_para': previstaPara,
      if (fechaLocal != null) 'fecha_local': fechaLocal,
      if (horaLocal != null) 'hora_local': horaLocal,
      if (creadaEn != null) 'creada_en': creadaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TomasCompanion copyWith({
    Value<String>? id,
    Value<String>? pautaVersionId,
    Value<String>? personaId,
    Value<int>? previstaPara,
    Value<String>? fechaLocal,
    Value<String>? horaLocal,
    Value<int>? creadaEn,
    Value<int>? rowid,
  }) {
    return TomasCompanion(
      id: id ?? this.id,
      pautaVersionId: pautaVersionId ?? this.pautaVersionId,
      personaId: personaId ?? this.personaId,
      previstaPara: previstaPara ?? this.previstaPara,
      fechaLocal: fechaLocal ?? this.fechaLocal,
      horaLocal: horaLocal ?? this.horaLocal,
      creadaEn: creadaEn ?? this.creadaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pautaVersionId.present) {
      map['pauta_version_id'] = Variable<String>(pautaVersionId.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (previstaPara.present) {
      map['prevista_para'] = Variable<int>(previstaPara.value);
    }
    if (fechaLocal.present) {
      map['fecha_local'] = Variable<String>(fechaLocal.value);
    }
    if (horaLocal.present) {
      map['hora_local'] = Variable<String>(horaLocal.value);
    }
    if (creadaEn.present) {
      map['creada_en'] = Variable<int>(creadaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TomasCompanion(')
          ..write('id: $id, ')
          ..write('pautaVersionId: $pautaVersionId, ')
          ..write('personaId: $personaId, ')
          ..write('previstaPara: $previstaPara, ')
          ..write('fechaLocal: $fechaLocal, ')
          ..write('horaLocal: $horaLocal, ')
          ..write('creadaEn: $creadaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComprobacionesTable extends Comprobaciones
    with TableInfo<$ComprobacionesTable, ComprobacionToma> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprobacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tomaIdMeta = const VerificationMeta('tomaId');
  @override
  late final GeneratedColumn<String> tomaId = GeneratedColumn<String>(
    'toma_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tomas (id)',
    ),
  );
  static const VerificationMeta _clipEventoUlidMeta = const VerificationMeta(
    'clipEventoUlid',
  );
  @override
  late final GeneratedColumn<String> clipEventoUlid = GeneratedColumn<String>(
    'clip_evento_ulid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisorMiembroIdMeta = const VerificationMeta(
    'revisorMiembroId',
  );
  @override
  late final GeneratedColumn<String> revisorMiembroId = GeneratedColumn<String>(
    'revisor_miembro_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES miembros (id)',
    ),
  );
  static const VerificationMeta _veredictoMeta = const VerificationMeta(
    'veredicto',
  );
  @override
  late final GeneratedColumn<String> veredicto = GeneratedColumn<String>(
    'veredicto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisadaEnMeta = const VerificationMeta(
    'revisadaEn',
  );
  @override
  late final GeneratedColumn<int> revisadaEn = GeneratedColumn<int>(
    'revisada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tomaId,
    clipEventoUlid,
    revisorMiembroId,
    veredicto,
    nota,
    revisadaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comprobaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComprobacionToma> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('toma_id')) {
      context.handle(
        _tomaIdMeta,
        tomaId.isAcceptableOrUnknown(data['toma_id']!, _tomaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tomaIdMeta);
    }
    if (data.containsKey('clip_evento_ulid')) {
      context.handle(
        _clipEventoUlidMeta,
        clipEventoUlid.isAcceptableOrUnknown(
          data['clip_evento_ulid']!,
          _clipEventoUlidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clipEventoUlidMeta);
    }
    if (data.containsKey('revisor_miembro_id')) {
      context.handle(
        _revisorMiembroIdMeta,
        revisorMiembroId.isAcceptableOrUnknown(
          data['revisor_miembro_id']!,
          _revisorMiembroIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revisorMiembroIdMeta);
    }
    if (data.containsKey('veredicto')) {
      context.handle(
        _veredictoMeta,
        veredicto.isAcceptableOrUnknown(data['veredicto']!, _veredictoMeta),
      );
    } else if (isInserting) {
      context.missing(_veredictoMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('revisada_en')) {
      context.handle(
        _revisadaEnMeta,
        revisadaEn.isAcceptableOrUnknown(data['revisada_en']!, _revisadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_revisadaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComprobacionToma map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComprobacionToma(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tomaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toma_id'],
      )!,
      clipEventoUlid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clip_evento_ulid'],
      )!,
      revisorMiembroId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revisor_miembro_id'],
      )!,
      veredicto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}veredicto'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
      revisadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revisada_en'],
      )!,
    );
  }

  @override
  $ComprobacionesTable createAlias(String alias) {
    return $ComprobacionesTable(attachedDatabase, alias);
  }
}

class ComprobacionToma extends DataClass
    implements Insertable<ComprobacionToma> {
  final String id;
  final String tomaId;
  final String clipEventoUlid;
  final String revisorMiembroId;

  /// `verificada` o `dudosa`.
  final String veredicto;
  final String? nota;
  final int revisadaEn;
  const ComprobacionToma({
    required this.id,
    required this.tomaId,
    required this.clipEventoUlid,
    required this.revisorMiembroId,
    required this.veredicto,
    this.nota,
    required this.revisadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['toma_id'] = Variable<String>(tomaId);
    map['clip_evento_ulid'] = Variable<String>(clipEventoUlid);
    map['revisor_miembro_id'] = Variable<String>(revisorMiembroId);
    map['veredicto'] = Variable<String>(veredicto);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    map['revisada_en'] = Variable<int>(revisadaEn);
    return map;
  }

  ComprobacionesCompanion toCompanion(bool nullToAbsent) {
    return ComprobacionesCompanion(
      id: Value(id),
      tomaId: Value(tomaId),
      clipEventoUlid: Value(clipEventoUlid),
      revisorMiembroId: Value(revisorMiembroId),
      veredicto: Value(veredicto),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      revisadaEn: Value(revisadaEn),
    );
  }

  factory ComprobacionToma.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComprobacionToma(
      id: serializer.fromJson<String>(json['id']),
      tomaId: serializer.fromJson<String>(json['tomaId']),
      clipEventoUlid: serializer.fromJson<String>(json['clipEventoUlid']),
      revisorMiembroId: serializer.fromJson<String>(json['revisorMiembroId']),
      veredicto: serializer.fromJson<String>(json['veredicto']),
      nota: serializer.fromJson<String?>(json['nota']),
      revisadaEn: serializer.fromJson<int>(json['revisadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tomaId': serializer.toJson<String>(tomaId),
      'clipEventoUlid': serializer.toJson<String>(clipEventoUlid),
      'revisorMiembroId': serializer.toJson<String>(revisorMiembroId),
      'veredicto': serializer.toJson<String>(veredicto),
      'nota': serializer.toJson<String?>(nota),
      'revisadaEn': serializer.toJson<int>(revisadaEn),
    };
  }

  ComprobacionToma copyWith({
    String? id,
    String? tomaId,
    String? clipEventoUlid,
    String? revisorMiembroId,
    String? veredicto,
    Value<String?> nota = const Value.absent(),
    int? revisadaEn,
  }) => ComprobacionToma(
    id: id ?? this.id,
    tomaId: tomaId ?? this.tomaId,
    clipEventoUlid: clipEventoUlid ?? this.clipEventoUlid,
    revisorMiembroId: revisorMiembroId ?? this.revisorMiembroId,
    veredicto: veredicto ?? this.veredicto,
    nota: nota.present ? nota.value : this.nota,
    revisadaEn: revisadaEn ?? this.revisadaEn,
  );
  ComprobacionToma copyWithCompanion(ComprobacionesCompanion data) {
    return ComprobacionToma(
      id: data.id.present ? data.id.value : this.id,
      tomaId: data.tomaId.present ? data.tomaId.value : this.tomaId,
      clipEventoUlid: data.clipEventoUlid.present
          ? data.clipEventoUlid.value
          : this.clipEventoUlid,
      revisorMiembroId: data.revisorMiembroId.present
          ? data.revisorMiembroId.value
          : this.revisorMiembroId,
      veredicto: data.veredicto.present ? data.veredicto.value : this.veredicto,
      nota: data.nota.present ? data.nota.value : this.nota,
      revisadaEn: data.revisadaEn.present
          ? data.revisadaEn.value
          : this.revisadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComprobacionToma(')
          ..write('id: $id, ')
          ..write('tomaId: $tomaId, ')
          ..write('clipEventoUlid: $clipEventoUlid, ')
          ..write('revisorMiembroId: $revisorMiembroId, ')
          ..write('veredicto: $veredicto, ')
          ..write('nota: $nota, ')
          ..write('revisadaEn: $revisadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tomaId,
    clipEventoUlid,
    revisorMiembroId,
    veredicto,
    nota,
    revisadaEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComprobacionToma &&
          other.id == this.id &&
          other.tomaId == this.tomaId &&
          other.clipEventoUlid == this.clipEventoUlid &&
          other.revisorMiembroId == this.revisorMiembroId &&
          other.veredicto == this.veredicto &&
          other.nota == this.nota &&
          other.revisadaEn == this.revisadaEn);
}

class ComprobacionesCompanion extends UpdateCompanion<ComprobacionToma> {
  final Value<String> id;
  final Value<String> tomaId;
  final Value<String> clipEventoUlid;
  final Value<String> revisorMiembroId;
  final Value<String> veredicto;
  final Value<String?> nota;
  final Value<int> revisadaEn;
  final Value<int> rowid;
  const ComprobacionesCompanion({
    this.id = const Value.absent(),
    this.tomaId = const Value.absent(),
    this.clipEventoUlid = const Value.absent(),
    this.revisorMiembroId = const Value.absent(),
    this.veredicto = const Value.absent(),
    this.nota = const Value.absent(),
    this.revisadaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComprobacionesCompanion.insert({
    required String id,
    required String tomaId,
    required String clipEventoUlid,
    required String revisorMiembroId,
    required String veredicto,
    this.nota = const Value.absent(),
    required int revisadaEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tomaId = Value(tomaId),
       clipEventoUlid = Value(clipEventoUlid),
       revisorMiembroId = Value(revisorMiembroId),
       veredicto = Value(veredicto),
       revisadaEn = Value(revisadaEn);
  static Insertable<ComprobacionToma> custom({
    Expression<String>? id,
    Expression<String>? tomaId,
    Expression<String>? clipEventoUlid,
    Expression<String>? revisorMiembroId,
    Expression<String>? veredicto,
    Expression<String>? nota,
    Expression<int>? revisadaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tomaId != null) 'toma_id': tomaId,
      if (clipEventoUlid != null) 'clip_evento_ulid': clipEventoUlid,
      if (revisorMiembroId != null) 'revisor_miembro_id': revisorMiembroId,
      if (veredicto != null) 'veredicto': veredicto,
      if (nota != null) 'nota': nota,
      if (revisadaEn != null) 'revisada_en': revisadaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComprobacionesCompanion copyWith({
    Value<String>? id,
    Value<String>? tomaId,
    Value<String>? clipEventoUlid,
    Value<String>? revisorMiembroId,
    Value<String>? veredicto,
    Value<String?>? nota,
    Value<int>? revisadaEn,
    Value<int>? rowid,
  }) {
    return ComprobacionesCompanion(
      id: id ?? this.id,
      tomaId: tomaId ?? this.tomaId,
      clipEventoUlid: clipEventoUlid ?? this.clipEventoUlid,
      revisorMiembroId: revisorMiembroId ?? this.revisorMiembroId,
      veredicto: veredicto ?? this.veredicto,
      nota: nota ?? this.nota,
      revisadaEn: revisadaEn ?? this.revisadaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tomaId.present) {
      map['toma_id'] = Variable<String>(tomaId.value);
    }
    if (clipEventoUlid.present) {
      map['clip_evento_ulid'] = Variable<String>(clipEventoUlid.value);
    }
    if (revisorMiembroId.present) {
      map['revisor_miembro_id'] = Variable<String>(revisorMiembroId.value);
    }
    if (veredicto.present) {
      map['veredicto'] = Variable<String>(veredicto.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (revisadaEn.present) {
      map['revisada_en'] = Variable<int>(revisadaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprobacionesCompanion(')
          ..write('id: $id, ')
          ..write('tomaId: $tomaId, ')
          ..write('clipEventoUlid: $clipEventoUlid, ')
          ..write('revisorMiembroId: $revisorMiembroId, ')
          ..write('veredicto: $veredicto, ')
          ..write('nota: $nota, ')
          ..write('revisadaEn: $revisadaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventosTable extends Eventos with TableInfo<$EventosTable, Evento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ulidMeta = const VerificationMeta('ulid');
  @override
  late final GeneratedColumn<String> ulid = GeneratedColumn<String>(
    'ulid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circuloIdMeta = const VerificationMeta(
    'circuloId',
  );
  @override
  late final GeneratedColumn<String> circuloId = GeneratedColumn<String>(
    'circulo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circulos (id)',
    ),
  );
  static const VerificationMeta _autorMeta = const VerificationMeta('autor');
  @override
  late final GeneratedColumn<String> autor = GeneratedColumn<String>(
    'autor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dispositivoMeta = const VerificationMeta(
    'dispositivo',
  );
  @override
  late final GeneratedColumn<String> dispositivo = GeneratedColumn<String>(
    'dispositivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sujetoMeta = const VerificationMeta('sujeto');
  @override
  late final GeneratedColumn<String> sujeto = GeneratedColumn<String>(
    'sujeto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocurridoEnMeta = const VerificationMeta(
    'ocurridoEn',
  );
  @override
  late final GeneratedColumn<int> ocurridoEn = GeneratedColumn<int>(
    'ocurrido_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registradoEnMeta = const VerificationMeta(
    'registradoEn',
  );
  @override
  late final GeneratedColumn<int> registradoEn = GeneratedColumn<int>(
    'registrado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _corrigeAMeta = const VerificationMeta(
    'corrigeA',
  );
  @override
  late final GeneratedColumn<String> corrigeA = GeneratedColumn<String>(
    'corrige_a',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ulid,
    circuloId,
    autor,
    dispositivo,
    tipo,
    sujeto,
    ocurridoEn,
    registradoEn,
    payload,
    corrigeA,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ulid')) {
      context.handle(
        _ulidMeta,
        ulid.isAcceptableOrUnknown(data['ulid']!, _ulidMeta),
      );
    } else if (isInserting) {
      context.missing(_ulidMeta);
    }
    if (data.containsKey('circulo_id')) {
      context.handle(
        _circuloIdMeta,
        circuloId.isAcceptableOrUnknown(data['circulo_id']!, _circuloIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circuloIdMeta);
    }
    if (data.containsKey('autor')) {
      context.handle(
        _autorMeta,
        autor.isAcceptableOrUnknown(data['autor']!, _autorMeta),
      );
    } else if (isInserting) {
      context.missing(_autorMeta);
    }
    if (data.containsKey('dispositivo')) {
      context.handle(
        _dispositivoMeta,
        dispositivo.isAcceptableOrUnknown(
          data['dispositivo']!,
          _dispositivoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dispositivoMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('sujeto')) {
      context.handle(
        _sujetoMeta,
        sujeto.isAcceptableOrUnknown(data['sujeto']!, _sujetoMeta),
      );
    }
    if (data.containsKey('ocurrido_en')) {
      context.handle(
        _ocurridoEnMeta,
        ocurridoEn.isAcceptableOrUnknown(data['ocurrido_en']!, _ocurridoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_ocurridoEnMeta);
    }
    if (data.containsKey('registrado_en')) {
      context.handle(
        _registradoEnMeta,
        registradoEn.isAcceptableOrUnknown(
          data['registrado_en']!,
          _registradoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registradoEnMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('corrige_a')) {
      context.handle(
        _corrigeAMeta,
        corrigeA.isAcceptableOrUnknown(data['corrige_a']!, _corrigeAMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ulid};
  @override
  Evento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evento(
      ulid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ulid'],
      )!,
      circuloId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circulo_id'],
      )!,
      autor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}autor'],
      )!,
      dispositivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dispositivo'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      sujeto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sujeto'],
      ),
      ocurridoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocurrido_en'],
      )!,
      registradoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registrado_en'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      corrigeA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrige_a'],
      ),
    );
  }

  @override
  $EventosTable createAlias(String alias) {
    return $EventosTable(attachedDatabase, alias);
  }
}

class Evento extends DataClass implements Insertable<Evento> {
  final String ulid;
  final String circuloId;

  /// Miembro o persona.
  final String autor;
  final String dispositivo;
  final String tipo;

  /// Id de toma, medicamento…
  final String? sujeto;
  final int ocurridoEn;
  final int registradoEn;
  final String payload;
  final String? corrigeA;
  const Evento({
    required this.ulid,
    required this.circuloId,
    required this.autor,
    required this.dispositivo,
    required this.tipo,
    this.sujeto,
    required this.ocurridoEn,
    required this.registradoEn,
    required this.payload,
    this.corrigeA,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ulid'] = Variable<String>(ulid);
    map['circulo_id'] = Variable<String>(circuloId);
    map['autor'] = Variable<String>(autor);
    map['dispositivo'] = Variable<String>(dispositivo);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || sujeto != null) {
      map['sujeto'] = Variable<String>(sujeto);
    }
    map['ocurrido_en'] = Variable<int>(ocurridoEn);
    map['registrado_en'] = Variable<int>(registradoEn);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || corrigeA != null) {
      map['corrige_a'] = Variable<String>(corrigeA);
    }
    return map;
  }

  EventosCompanion toCompanion(bool nullToAbsent) {
    return EventosCompanion(
      ulid: Value(ulid),
      circuloId: Value(circuloId),
      autor: Value(autor),
      dispositivo: Value(dispositivo),
      tipo: Value(tipo),
      sujeto: sujeto == null && nullToAbsent
          ? const Value.absent()
          : Value(sujeto),
      ocurridoEn: Value(ocurridoEn),
      registradoEn: Value(registradoEn),
      payload: Value(payload),
      corrigeA: corrigeA == null && nullToAbsent
          ? const Value.absent()
          : Value(corrigeA),
    );
  }

  factory Evento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evento(
      ulid: serializer.fromJson<String>(json['ulid']),
      circuloId: serializer.fromJson<String>(json['circuloId']),
      autor: serializer.fromJson<String>(json['autor']),
      dispositivo: serializer.fromJson<String>(json['dispositivo']),
      tipo: serializer.fromJson<String>(json['tipo']),
      sujeto: serializer.fromJson<String?>(json['sujeto']),
      ocurridoEn: serializer.fromJson<int>(json['ocurridoEn']),
      registradoEn: serializer.fromJson<int>(json['registradoEn']),
      payload: serializer.fromJson<String>(json['payload']),
      corrigeA: serializer.fromJson<String?>(json['corrigeA']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ulid': serializer.toJson<String>(ulid),
      'circuloId': serializer.toJson<String>(circuloId),
      'autor': serializer.toJson<String>(autor),
      'dispositivo': serializer.toJson<String>(dispositivo),
      'tipo': serializer.toJson<String>(tipo),
      'sujeto': serializer.toJson<String?>(sujeto),
      'ocurridoEn': serializer.toJson<int>(ocurridoEn),
      'registradoEn': serializer.toJson<int>(registradoEn),
      'payload': serializer.toJson<String>(payload),
      'corrigeA': serializer.toJson<String?>(corrigeA),
    };
  }

  Evento copyWith({
    String? ulid,
    String? circuloId,
    String? autor,
    String? dispositivo,
    String? tipo,
    Value<String?> sujeto = const Value.absent(),
    int? ocurridoEn,
    int? registradoEn,
    String? payload,
    Value<String?> corrigeA = const Value.absent(),
  }) => Evento(
    ulid: ulid ?? this.ulid,
    circuloId: circuloId ?? this.circuloId,
    autor: autor ?? this.autor,
    dispositivo: dispositivo ?? this.dispositivo,
    tipo: tipo ?? this.tipo,
    sujeto: sujeto.present ? sujeto.value : this.sujeto,
    ocurridoEn: ocurridoEn ?? this.ocurridoEn,
    registradoEn: registradoEn ?? this.registradoEn,
    payload: payload ?? this.payload,
    corrigeA: corrigeA.present ? corrigeA.value : this.corrigeA,
  );
  Evento copyWithCompanion(EventosCompanion data) {
    return Evento(
      ulid: data.ulid.present ? data.ulid.value : this.ulid,
      circuloId: data.circuloId.present ? data.circuloId.value : this.circuloId,
      autor: data.autor.present ? data.autor.value : this.autor,
      dispositivo: data.dispositivo.present
          ? data.dispositivo.value
          : this.dispositivo,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      sujeto: data.sujeto.present ? data.sujeto.value : this.sujeto,
      ocurridoEn: data.ocurridoEn.present
          ? data.ocurridoEn.value
          : this.ocurridoEn,
      registradoEn: data.registradoEn.present
          ? data.registradoEn.value
          : this.registradoEn,
      payload: data.payload.present ? data.payload.value : this.payload,
      corrigeA: data.corrigeA.present ? data.corrigeA.value : this.corrigeA,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evento(')
          ..write('ulid: $ulid, ')
          ..write('circuloId: $circuloId, ')
          ..write('autor: $autor, ')
          ..write('dispositivo: $dispositivo, ')
          ..write('tipo: $tipo, ')
          ..write('sujeto: $sujeto, ')
          ..write('ocurridoEn: $ocurridoEn, ')
          ..write('registradoEn: $registradoEn, ')
          ..write('payload: $payload, ')
          ..write('corrigeA: $corrigeA')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ulid,
    circuloId,
    autor,
    dispositivo,
    tipo,
    sujeto,
    ocurridoEn,
    registradoEn,
    payload,
    corrigeA,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evento &&
          other.ulid == this.ulid &&
          other.circuloId == this.circuloId &&
          other.autor == this.autor &&
          other.dispositivo == this.dispositivo &&
          other.tipo == this.tipo &&
          other.sujeto == this.sujeto &&
          other.ocurridoEn == this.ocurridoEn &&
          other.registradoEn == this.registradoEn &&
          other.payload == this.payload &&
          other.corrigeA == this.corrigeA);
}

class EventosCompanion extends UpdateCompanion<Evento> {
  final Value<String> ulid;
  final Value<String> circuloId;
  final Value<String> autor;
  final Value<String> dispositivo;
  final Value<String> tipo;
  final Value<String?> sujeto;
  final Value<int> ocurridoEn;
  final Value<int> registradoEn;
  final Value<String> payload;
  final Value<String?> corrigeA;
  final Value<int> rowid;
  const EventosCompanion({
    this.ulid = const Value.absent(),
    this.circuloId = const Value.absent(),
    this.autor = const Value.absent(),
    this.dispositivo = const Value.absent(),
    this.tipo = const Value.absent(),
    this.sujeto = const Value.absent(),
    this.ocurridoEn = const Value.absent(),
    this.registradoEn = const Value.absent(),
    this.payload = const Value.absent(),
    this.corrigeA = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventosCompanion.insert({
    required String ulid,
    required String circuloId,
    required String autor,
    required String dispositivo,
    required String tipo,
    this.sujeto = const Value.absent(),
    required int ocurridoEn,
    required int registradoEn,
    this.payload = const Value.absent(),
    this.corrigeA = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ulid = Value(ulid),
       circuloId = Value(circuloId),
       autor = Value(autor),
       dispositivo = Value(dispositivo),
       tipo = Value(tipo),
       ocurridoEn = Value(ocurridoEn),
       registradoEn = Value(registradoEn);
  static Insertable<Evento> custom({
    Expression<String>? ulid,
    Expression<String>? circuloId,
    Expression<String>? autor,
    Expression<String>? dispositivo,
    Expression<String>? tipo,
    Expression<String>? sujeto,
    Expression<int>? ocurridoEn,
    Expression<int>? registradoEn,
    Expression<String>? payload,
    Expression<String>? corrigeA,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ulid != null) 'ulid': ulid,
      if (circuloId != null) 'circulo_id': circuloId,
      if (autor != null) 'autor': autor,
      if (dispositivo != null) 'dispositivo': dispositivo,
      if (tipo != null) 'tipo': tipo,
      if (sujeto != null) 'sujeto': sujeto,
      if (ocurridoEn != null) 'ocurrido_en': ocurridoEn,
      if (registradoEn != null) 'registrado_en': registradoEn,
      if (payload != null) 'payload': payload,
      if (corrigeA != null) 'corrige_a': corrigeA,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventosCompanion copyWith({
    Value<String>? ulid,
    Value<String>? circuloId,
    Value<String>? autor,
    Value<String>? dispositivo,
    Value<String>? tipo,
    Value<String?>? sujeto,
    Value<int>? ocurridoEn,
    Value<int>? registradoEn,
    Value<String>? payload,
    Value<String?>? corrigeA,
    Value<int>? rowid,
  }) {
    return EventosCompanion(
      ulid: ulid ?? this.ulid,
      circuloId: circuloId ?? this.circuloId,
      autor: autor ?? this.autor,
      dispositivo: dispositivo ?? this.dispositivo,
      tipo: tipo ?? this.tipo,
      sujeto: sujeto ?? this.sujeto,
      ocurridoEn: ocurridoEn ?? this.ocurridoEn,
      registradoEn: registradoEn ?? this.registradoEn,
      payload: payload ?? this.payload,
      corrigeA: corrigeA ?? this.corrigeA,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ulid.present) {
      map['ulid'] = Variable<String>(ulid.value);
    }
    if (circuloId.present) {
      map['circulo_id'] = Variable<String>(circuloId.value);
    }
    if (autor.present) {
      map['autor'] = Variable<String>(autor.value);
    }
    if (dispositivo.present) {
      map['dispositivo'] = Variable<String>(dispositivo.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (sujeto.present) {
      map['sujeto'] = Variable<String>(sujeto.value);
    }
    if (ocurridoEn.present) {
      map['ocurrido_en'] = Variable<int>(ocurridoEn.value);
    }
    if (registradoEn.present) {
      map['registrado_en'] = Variable<int>(registradoEn.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (corrigeA.present) {
      map['corrige_a'] = Variable<String>(corrigeA.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosCompanion(')
          ..write('ulid: $ulid, ')
          ..write('circuloId: $circuloId, ')
          ..write('autor: $autor, ')
          ..write('dispositivo: $dispositivo, ')
          ..write('tipo: $tipo, ')
          ..write('sujeto: $sujeto, ')
          ..write('ocurridoEn: $ocurridoEn, ')
          ..write('registradoEn: $registradoEn, ')
          ..write('payload: $payload, ')
          ..write('corrigeA: $corrigeA, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreguntasControlTable extends PreguntasControl
    with TableInfo<$PreguntasControlTable, PreguntaControl> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreguntasControlTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personas (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fraseIdMeta = const VerificationMeta(
    'fraseId',
  );
  @override
  late final GeneratedColumn<String> fraseId = GeneratedColumn<String>(
    'frase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES frases (id)',
    ),
  );
  static const VerificationMeta _lanzadaEnMeta = const VerificationMeta(
    'lanzadaEn',
  );
  @override
  late final GeneratedColumn<int> lanzadaEn = GeneratedColumn<int>(
    'lanzada_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personaId,
    tipo,
    texto,
    fraseId,
    lanzadaEn,
    origen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preguntas_control';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreguntaControl> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personaIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('frase_id')) {
      context.handle(
        _fraseIdMeta,
        fraseId.isAcceptableOrUnknown(data['frase_id']!, _fraseIdMeta),
      );
    }
    if (data.containsKey('lanzada_en')) {
      context.handle(
        _lanzadaEnMeta,
        lanzadaEn.isAcceptableOrUnknown(data['lanzada_en']!, _lanzadaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_lanzadaEnMeta);
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    } else if (isInserting) {
      context.missing(_origenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreguntaControl map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreguntaControl(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      fraseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frase_id'],
      ),
      lanzadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lanzada_en'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
    );
  }

  @override
  $PreguntasControlTable createAlias(String alias) {
    return $PreguntasControlTable(attachedDatabase, alias);
  }
}

class PreguntaControl extends DataClass implements Insertable<PreguntaControl> {
  final String id;
  final String personaId;

  /// `estado`, `dolor`, `plan` o `si_no`.
  final String tipo;
  final String texto;
  final String? fraseId;
  final int lanzadaEn;

  /// `movil`, `reloj` o `cuidador`.
  final String origen;
  const PreguntaControl({
    required this.id,
    required this.personaId,
    required this.tipo,
    required this.texto,
    this.fraseId,
    required this.lanzadaEn,
    required this.origen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['persona_id'] = Variable<String>(personaId);
    map['tipo'] = Variable<String>(tipo);
    map['texto'] = Variable<String>(texto);
    if (!nullToAbsent || fraseId != null) {
      map['frase_id'] = Variable<String>(fraseId);
    }
    map['lanzada_en'] = Variable<int>(lanzadaEn);
    map['origen'] = Variable<String>(origen);
    return map;
  }

  PreguntasControlCompanion toCompanion(bool nullToAbsent) {
    return PreguntasControlCompanion(
      id: Value(id),
      personaId: Value(personaId),
      tipo: Value(tipo),
      texto: Value(texto),
      fraseId: fraseId == null && nullToAbsent
          ? const Value.absent()
          : Value(fraseId),
      lanzadaEn: Value(lanzadaEn),
      origen: Value(origen),
    );
  }

  factory PreguntaControl.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreguntaControl(
      id: serializer.fromJson<String>(json['id']),
      personaId: serializer.fromJson<String>(json['personaId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      texto: serializer.fromJson<String>(json['texto']),
      fraseId: serializer.fromJson<String?>(json['fraseId']),
      lanzadaEn: serializer.fromJson<int>(json['lanzadaEn']),
      origen: serializer.fromJson<String>(json['origen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personaId': serializer.toJson<String>(personaId),
      'tipo': serializer.toJson<String>(tipo),
      'texto': serializer.toJson<String>(texto),
      'fraseId': serializer.toJson<String?>(fraseId),
      'lanzadaEn': serializer.toJson<int>(lanzadaEn),
      'origen': serializer.toJson<String>(origen),
    };
  }

  PreguntaControl copyWith({
    String? id,
    String? personaId,
    String? tipo,
    String? texto,
    Value<String?> fraseId = const Value.absent(),
    int? lanzadaEn,
    String? origen,
  }) => PreguntaControl(
    id: id ?? this.id,
    personaId: personaId ?? this.personaId,
    tipo: tipo ?? this.tipo,
    texto: texto ?? this.texto,
    fraseId: fraseId.present ? fraseId.value : this.fraseId,
    lanzadaEn: lanzadaEn ?? this.lanzadaEn,
    origen: origen ?? this.origen,
  );
  PreguntaControl copyWithCompanion(PreguntasControlCompanion data) {
    return PreguntaControl(
      id: data.id.present ? data.id.value : this.id,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      texto: data.texto.present ? data.texto.value : this.texto,
      fraseId: data.fraseId.present ? data.fraseId.value : this.fraseId,
      lanzadaEn: data.lanzadaEn.present ? data.lanzadaEn.value : this.lanzadaEn,
      origen: data.origen.present ? data.origen.value : this.origen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreguntaControl(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('tipo: $tipo, ')
          ..write('texto: $texto, ')
          ..write('fraseId: $fraseId, ')
          ..write('lanzadaEn: $lanzadaEn, ')
          ..write('origen: $origen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personaId, tipo, texto, fraseId, lanzadaEn, origen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreguntaControl &&
          other.id == this.id &&
          other.personaId == this.personaId &&
          other.tipo == this.tipo &&
          other.texto == this.texto &&
          other.fraseId == this.fraseId &&
          other.lanzadaEn == this.lanzadaEn &&
          other.origen == this.origen);
}

class PreguntasControlCompanion extends UpdateCompanion<PreguntaControl> {
  final Value<String> id;
  final Value<String> personaId;
  final Value<String> tipo;
  final Value<String> texto;
  final Value<String?> fraseId;
  final Value<int> lanzadaEn;
  final Value<String> origen;
  final Value<int> rowid;
  const PreguntasControlCompanion({
    this.id = const Value.absent(),
    this.personaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.texto = const Value.absent(),
    this.fraseId = const Value.absent(),
    this.lanzadaEn = const Value.absent(),
    this.origen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreguntasControlCompanion.insert({
    required String id,
    required String personaId,
    required String tipo,
    required String texto,
    this.fraseId = const Value.absent(),
    required int lanzadaEn,
    required String origen,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personaId = Value(personaId),
       tipo = Value(tipo),
       texto = Value(texto),
       lanzadaEn = Value(lanzadaEn),
       origen = Value(origen);
  static Insertable<PreguntaControl> custom({
    Expression<String>? id,
    Expression<String>? personaId,
    Expression<String>? tipo,
    Expression<String>? texto,
    Expression<String>? fraseId,
    Expression<int>? lanzadaEn,
    Expression<String>? origen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personaId != null) 'persona_id': personaId,
      if (tipo != null) 'tipo': tipo,
      if (texto != null) 'texto': texto,
      if (fraseId != null) 'frase_id': fraseId,
      if (lanzadaEn != null) 'lanzada_en': lanzadaEn,
      if (origen != null) 'origen': origen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreguntasControlCompanion copyWith({
    Value<String>? id,
    Value<String>? personaId,
    Value<String>? tipo,
    Value<String>? texto,
    Value<String?>? fraseId,
    Value<int>? lanzadaEn,
    Value<String>? origen,
    Value<int>? rowid,
  }) {
    return PreguntasControlCompanion(
      id: id ?? this.id,
      personaId: personaId ?? this.personaId,
      tipo: tipo ?? this.tipo,
      texto: texto ?? this.texto,
      fraseId: fraseId ?? this.fraseId,
      lanzadaEn: lanzadaEn ?? this.lanzadaEn,
      origen: origen ?? this.origen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (fraseId.present) {
      map['frase_id'] = Variable<String>(fraseId.value);
    }
    if (lanzadaEn.present) {
      map['lanzada_en'] = Variable<int>(lanzadaEn.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreguntasControlCompanion(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('tipo: $tipo, ')
          ..write('texto: $texto, ')
          ..write('fraseId: $fraseId, ')
          ..write('lanzadaEn: $lanzadaEn, ')
          ..write('origen: $origen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RespuestasTable extends Respuestas
    with TableInfo<$RespuestasTable, Respuesta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RespuestasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preguntaIdMeta = const VerificationMeta(
    'preguntaId',
  );
  @override
  late final GeneratedColumn<String> preguntaId = GeneratedColumn<String>(
    'pregunta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES preguntas_control (id)',
    ),
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioRutaMeta = const VerificationMeta(
    'audioRuta',
  );
  @override
  late final GeneratedColumn<String> audioRuta = GeneratedColumn<String>(
    'audio_ruta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respondidaEnMeta = const VerificationMeta(
    'respondidaEn',
  );
  @override
  late final GeneratedColumn<int> respondidaEn = GeneratedColumn<int>(
    'respondida_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    preguntaId,
    valor,
    audioRuta,
    respondidaEn,
    origen,
    latitud,
    longitud,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'respuestas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Respuesta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pregunta_id')) {
      context.handle(
        _preguntaIdMeta,
        preguntaId.isAcceptableOrUnknown(data['pregunta_id']!, _preguntaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_preguntaIdMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('audio_ruta')) {
      context.handle(
        _audioRutaMeta,
        audioRuta.isAcceptableOrUnknown(data['audio_ruta']!, _audioRutaMeta),
      );
    }
    if (data.containsKey('respondida_en')) {
      context.handle(
        _respondidaEnMeta,
        respondidaEn.isAcceptableOrUnknown(
          data['respondida_en']!,
          _respondidaEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respondidaEnMeta);
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    } else if (isInserting) {
      context.missing(_origenMeta);
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Respuesta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Respuesta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      preguntaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pregunta_id'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
      audioRuta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_ruta'],
      ),
      respondidaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}respondida_en'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
      latitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitud'],
      ),
      longitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitud'],
      ),
    );
  }

  @override
  $RespuestasTable createAlias(String alias) {
    return $RespuestasTable(attachedDatabase, alias);
  }
}

class Respuesta extends DataClass implements Insertable<Respuesta> {
  final String id;
  final String preguntaId;
  final String valor;
  final String? audioRuta;
  final int respondidaEn;
  final String origen;
  final double? latitud;
  final double? longitud;
  const Respuesta({
    required this.id,
    required this.preguntaId,
    required this.valor,
    this.audioRuta,
    required this.respondidaEn,
    required this.origen,
    this.latitud,
    this.longitud,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pregunta_id'] = Variable<String>(preguntaId);
    map['valor'] = Variable<String>(valor);
    if (!nullToAbsent || audioRuta != null) {
      map['audio_ruta'] = Variable<String>(audioRuta);
    }
    map['respondida_en'] = Variable<int>(respondidaEn);
    map['origen'] = Variable<String>(origen);
    if (!nullToAbsent || latitud != null) {
      map['latitud'] = Variable<double>(latitud);
    }
    if (!nullToAbsent || longitud != null) {
      map['longitud'] = Variable<double>(longitud);
    }
    return map;
  }

  RespuestasCompanion toCompanion(bool nullToAbsent) {
    return RespuestasCompanion(
      id: Value(id),
      preguntaId: Value(preguntaId),
      valor: Value(valor),
      audioRuta: audioRuta == null && nullToAbsent
          ? const Value.absent()
          : Value(audioRuta),
      respondidaEn: Value(respondidaEn),
      origen: Value(origen),
      latitud: latitud == null && nullToAbsent
          ? const Value.absent()
          : Value(latitud),
      longitud: longitud == null && nullToAbsent
          ? const Value.absent()
          : Value(longitud),
    );
  }

  factory Respuesta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Respuesta(
      id: serializer.fromJson<String>(json['id']),
      preguntaId: serializer.fromJson<String>(json['preguntaId']),
      valor: serializer.fromJson<String>(json['valor']),
      audioRuta: serializer.fromJson<String?>(json['audioRuta']),
      respondidaEn: serializer.fromJson<int>(json['respondidaEn']),
      origen: serializer.fromJson<String>(json['origen']),
      latitud: serializer.fromJson<double?>(json['latitud']),
      longitud: serializer.fromJson<double?>(json['longitud']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'preguntaId': serializer.toJson<String>(preguntaId),
      'valor': serializer.toJson<String>(valor),
      'audioRuta': serializer.toJson<String?>(audioRuta),
      'respondidaEn': serializer.toJson<int>(respondidaEn),
      'origen': serializer.toJson<String>(origen),
      'latitud': serializer.toJson<double?>(latitud),
      'longitud': serializer.toJson<double?>(longitud),
    };
  }

  Respuesta copyWith({
    String? id,
    String? preguntaId,
    String? valor,
    Value<String?> audioRuta = const Value.absent(),
    int? respondidaEn,
    String? origen,
    Value<double?> latitud = const Value.absent(),
    Value<double?> longitud = const Value.absent(),
  }) => Respuesta(
    id: id ?? this.id,
    preguntaId: preguntaId ?? this.preguntaId,
    valor: valor ?? this.valor,
    audioRuta: audioRuta.present ? audioRuta.value : this.audioRuta,
    respondidaEn: respondidaEn ?? this.respondidaEn,
    origen: origen ?? this.origen,
    latitud: latitud.present ? latitud.value : this.latitud,
    longitud: longitud.present ? longitud.value : this.longitud,
  );
  Respuesta copyWithCompanion(RespuestasCompanion data) {
    return Respuesta(
      id: data.id.present ? data.id.value : this.id,
      preguntaId: data.preguntaId.present
          ? data.preguntaId.value
          : this.preguntaId,
      valor: data.valor.present ? data.valor.value : this.valor,
      audioRuta: data.audioRuta.present ? data.audioRuta.value : this.audioRuta,
      respondidaEn: data.respondidaEn.present
          ? data.respondidaEn.value
          : this.respondidaEn,
      origen: data.origen.present ? data.origen.value : this.origen,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Respuesta(')
          ..write('id: $id, ')
          ..write('preguntaId: $preguntaId, ')
          ..write('valor: $valor, ')
          ..write('audioRuta: $audioRuta, ')
          ..write('respondidaEn: $respondidaEn, ')
          ..write('origen: $origen, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    preguntaId,
    valor,
    audioRuta,
    respondidaEn,
    origen,
    latitud,
    longitud,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Respuesta &&
          other.id == this.id &&
          other.preguntaId == this.preguntaId &&
          other.valor == this.valor &&
          other.audioRuta == this.audioRuta &&
          other.respondidaEn == this.respondidaEn &&
          other.origen == this.origen &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud);
}

class RespuestasCompanion extends UpdateCompanion<Respuesta> {
  final Value<String> id;
  final Value<String> preguntaId;
  final Value<String> valor;
  final Value<String?> audioRuta;
  final Value<int> respondidaEn;
  final Value<String> origen;
  final Value<double?> latitud;
  final Value<double?> longitud;
  final Value<int> rowid;
  const RespuestasCompanion({
    this.id = const Value.absent(),
    this.preguntaId = const Value.absent(),
    this.valor = const Value.absent(),
    this.audioRuta = const Value.absent(),
    this.respondidaEn = const Value.absent(),
    this.origen = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RespuestasCompanion.insert({
    required String id,
    required String preguntaId,
    required String valor,
    this.audioRuta = const Value.absent(),
    required int respondidaEn,
    required String origen,
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       preguntaId = Value(preguntaId),
       valor = Value(valor),
       respondidaEn = Value(respondidaEn),
       origen = Value(origen);
  static Insertable<Respuesta> custom({
    Expression<String>? id,
    Expression<String>? preguntaId,
    Expression<String>? valor,
    Expression<String>? audioRuta,
    Expression<int>? respondidaEn,
    Expression<String>? origen,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (preguntaId != null) 'pregunta_id': preguntaId,
      if (valor != null) 'valor': valor,
      if (audioRuta != null) 'audio_ruta': audioRuta,
      if (respondidaEn != null) 'respondida_en': respondidaEn,
      if (origen != null) 'origen': origen,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RespuestasCompanion copyWith({
    Value<String>? id,
    Value<String>? preguntaId,
    Value<String>? valor,
    Value<String?>? audioRuta,
    Value<int>? respondidaEn,
    Value<String>? origen,
    Value<double?>? latitud,
    Value<double?>? longitud,
    Value<int>? rowid,
  }) {
    return RespuestasCompanion(
      id: id ?? this.id,
      preguntaId: preguntaId ?? this.preguntaId,
      valor: valor ?? this.valor,
      audioRuta: audioRuta ?? this.audioRuta,
      respondidaEn: respondidaEn ?? this.respondidaEn,
      origen: origen ?? this.origen,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (preguntaId.present) {
      map['pregunta_id'] = Variable<String>(preguntaId.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (audioRuta.present) {
      map['audio_ruta'] = Variable<String>(audioRuta.value);
    }
    if (respondidaEn.present) {
      map['respondida_en'] = Variable<int>(respondidaEn.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RespuestasCompanion(')
          ..write('id: $id, ')
          ..write('preguntaId: $preguntaId, ')
          ..write('valor: $valor, ')
          ..write('audioRuta: $audioRuta, ')
          ..write('respondidaEn: $respondidaEn, ')
          ..write('origen: $origen, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComidasTable extends Comidas with TableInfo<$ComidasTable, Comida> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComidasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personas (id)',
    ),
  );
  static const VerificationMeta _momentoMeta = const VerificationMeta(
    'momento',
  );
  @override
  late final GeneratedColumn<String> momento = GeneratedColumn<String>(
    'momento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuantoMeta = const VerificationMeta('cuanto');
  @override
  late final GeneratedColumn<String> cuanto = GeneratedColumn<String>(
    'cuanto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoIdMeta = const VerificationMeta('fotoId');
  @override
  late final GeneratedColumn<String> fotoId = GeneratedColumn<String>(
    'foto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fotos (id)',
    ),
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocurridaEnMeta = const VerificationMeta(
    'ocurridaEn',
  );
  @override
  late final GeneratedColumn<int> ocurridaEn = GeneratedColumn<int>(
    'ocurrida_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registradaPorMeta = const VerificationMeta(
    'registradaPor',
  );
  @override
  late final GeneratedColumn<String> registradaPor = GeneratedColumn<String>(
    'registrada_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personaId,
    momento,
    cuanto,
    fotoId,
    nota,
    ocurridaEn,
    registradaPor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comidas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Comida> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personaIdMeta);
    }
    if (data.containsKey('momento')) {
      context.handle(
        _momentoMeta,
        momento.isAcceptableOrUnknown(data['momento']!, _momentoMeta),
      );
    } else if (isInserting) {
      context.missing(_momentoMeta);
    }
    if (data.containsKey('cuanto')) {
      context.handle(
        _cuantoMeta,
        cuanto.isAcceptableOrUnknown(data['cuanto']!, _cuantoMeta),
      );
    } else if (isInserting) {
      context.missing(_cuantoMeta);
    }
    if (data.containsKey('foto_id')) {
      context.handle(
        _fotoIdMeta,
        fotoId.isAcceptableOrUnknown(data['foto_id']!, _fotoIdMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('ocurrida_en')) {
      context.handle(
        _ocurridaEnMeta,
        ocurridaEn.isAcceptableOrUnknown(data['ocurrida_en']!, _ocurridaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_ocurridaEnMeta);
    }
    if (data.containsKey('registrada_por')) {
      context.handle(
        _registradaPorMeta,
        registradaPor.isAcceptableOrUnknown(
          data['registrada_por']!,
          _registradaPorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registradaPorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Comida map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Comida(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      )!,
      momento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}momento'],
      )!,
      cuanto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuanto'],
      )!,
      fotoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_id'],
      ),
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
      ocurridaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocurrida_en'],
      )!,
      registradaPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registrada_por'],
      )!,
    );
  }

  @override
  $ComidasTable createAlias(String alias) {
    return $ComidasTable(attachedDatabase, alias);
  }
}

class Comida extends DataClass implements Insertable<Comida> {
  final String id;
  final String personaId;

  /// `desayuno`, `comida`, `merienda`, `cena` u `otro`.
  final String momento;

  /// `todo`, `mitad`, `poco` o `nada`.
  final String cuanto;
  final String? fotoId;
  final String? nota;
  final int ocurridaEn;
  final String registradaPor;
  const Comida({
    required this.id,
    required this.personaId,
    required this.momento,
    required this.cuanto,
    this.fotoId,
    this.nota,
    required this.ocurridaEn,
    required this.registradaPor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['persona_id'] = Variable<String>(personaId);
    map['momento'] = Variable<String>(momento);
    map['cuanto'] = Variable<String>(cuanto);
    if (!nullToAbsent || fotoId != null) {
      map['foto_id'] = Variable<String>(fotoId);
    }
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    map['ocurrida_en'] = Variable<int>(ocurridaEn);
    map['registrada_por'] = Variable<String>(registradaPor);
    return map;
  }

  ComidasCompanion toCompanion(bool nullToAbsent) {
    return ComidasCompanion(
      id: Value(id),
      personaId: Value(personaId),
      momento: Value(momento),
      cuanto: Value(cuanto),
      fotoId: fotoId == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoId),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      ocurridaEn: Value(ocurridaEn),
      registradaPor: Value(registradaPor),
    );
  }

  factory Comida.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Comida(
      id: serializer.fromJson<String>(json['id']),
      personaId: serializer.fromJson<String>(json['personaId']),
      momento: serializer.fromJson<String>(json['momento']),
      cuanto: serializer.fromJson<String>(json['cuanto']),
      fotoId: serializer.fromJson<String?>(json['fotoId']),
      nota: serializer.fromJson<String?>(json['nota']),
      ocurridaEn: serializer.fromJson<int>(json['ocurridaEn']),
      registradaPor: serializer.fromJson<String>(json['registradaPor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personaId': serializer.toJson<String>(personaId),
      'momento': serializer.toJson<String>(momento),
      'cuanto': serializer.toJson<String>(cuanto),
      'fotoId': serializer.toJson<String?>(fotoId),
      'nota': serializer.toJson<String?>(nota),
      'ocurridaEn': serializer.toJson<int>(ocurridaEn),
      'registradaPor': serializer.toJson<String>(registradaPor),
    };
  }

  Comida copyWith({
    String? id,
    String? personaId,
    String? momento,
    String? cuanto,
    Value<String?> fotoId = const Value.absent(),
    Value<String?> nota = const Value.absent(),
    int? ocurridaEn,
    String? registradaPor,
  }) => Comida(
    id: id ?? this.id,
    personaId: personaId ?? this.personaId,
    momento: momento ?? this.momento,
    cuanto: cuanto ?? this.cuanto,
    fotoId: fotoId.present ? fotoId.value : this.fotoId,
    nota: nota.present ? nota.value : this.nota,
    ocurridaEn: ocurridaEn ?? this.ocurridaEn,
    registradaPor: registradaPor ?? this.registradaPor,
  );
  Comida copyWithCompanion(ComidasCompanion data) {
    return Comida(
      id: data.id.present ? data.id.value : this.id,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      momento: data.momento.present ? data.momento.value : this.momento,
      cuanto: data.cuanto.present ? data.cuanto.value : this.cuanto,
      fotoId: data.fotoId.present ? data.fotoId.value : this.fotoId,
      nota: data.nota.present ? data.nota.value : this.nota,
      ocurridaEn: data.ocurridaEn.present
          ? data.ocurridaEn.value
          : this.ocurridaEn,
      registradaPor: data.registradaPor.present
          ? data.registradaPor.value
          : this.registradaPor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Comida(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('momento: $momento, ')
          ..write('cuanto: $cuanto, ')
          ..write('fotoId: $fotoId, ')
          ..write('nota: $nota, ')
          ..write('ocurridaEn: $ocurridaEn, ')
          ..write('registradaPor: $registradaPor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personaId,
    momento,
    cuanto,
    fotoId,
    nota,
    ocurridaEn,
    registradaPor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Comida &&
          other.id == this.id &&
          other.personaId == this.personaId &&
          other.momento == this.momento &&
          other.cuanto == this.cuanto &&
          other.fotoId == this.fotoId &&
          other.nota == this.nota &&
          other.ocurridaEn == this.ocurridaEn &&
          other.registradaPor == this.registradaPor);
}

class ComidasCompanion extends UpdateCompanion<Comida> {
  final Value<String> id;
  final Value<String> personaId;
  final Value<String> momento;
  final Value<String> cuanto;
  final Value<String?> fotoId;
  final Value<String?> nota;
  final Value<int> ocurridaEn;
  final Value<String> registradaPor;
  final Value<int> rowid;
  const ComidasCompanion({
    this.id = const Value.absent(),
    this.personaId = const Value.absent(),
    this.momento = const Value.absent(),
    this.cuanto = const Value.absent(),
    this.fotoId = const Value.absent(),
    this.nota = const Value.absent(),
    this.ocurridaEn = const Value.absent(),
    this.registradaPor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComidasCompanion.insert({
    required String id,
    required String personaId,
    required String momento,
    required String cuanto,
    this.fotoId = const Value.absent(),
    this.nota = const Value.absent(),
    required int ocurridaEn,
    required String registradaPor,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personaId = Value(personaId),
       momento = Value(momento),
       cuanto = Value(cuanto),
       ocurridaEn = Value(ocurridaEn),
       registradaPor = Value(registradaPor);
  static Insertable<Comida> custom({
    Expression<String>? id,
    Expression<String>? personaId,
    Expression<String>? momento,
    Expression<String>? cuanto,
    Expression<String>? fotoId,
    Expression<String>? nota,
    Expression<int>? ocurridaEn,
    Expression<String>? registradaPor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personaId != null) 'persona_id': personaId,
      if (momento != null) 'momento': momento,
      if (cuanto != null) 'cuanto': cuanto,
      if (fotoId != null) 'foto_id': fotoId,
      if (nota != null) 'nota': nota,
      if (ocurridaEn != null) 'ocurrida_en': ocurridaEn,
      if (registradaPor != null) 'registrada_por': registradaPor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComidasCompanion copyWith({
    Value<String>? id,
    Value<String>? personaId,
    Value<String>? momento,
    Value<String>? cuanto,
    Value<String?>? fotoId,
    Value<String?>? nota,
    Value<int>? ocurridaEn,
    Value<String>? registradaPor,
    Value<int>? rowid,
  }) {
    return ComidasCompanion(
      id: id ?? this.id,
      personaId: personaId ?? this.personaId,
      momento: momento ?? this.momento,
      cuanto: cuanto ?? this.cuanto,
      fotoId: fotoId ?? this.fotoId,
      nota: nota ?? this.nota,
      ocurridaEn: ocurridaEn ?? this.ocurridaEn,
      registradaPor: registradaPor ?? this.registradaPor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (momento.present) {
      map['momento'] = Variable<String>(momento.value);
    }
    if (cuanto.present) {
      map['cuanto'] = Variable<String>(cuanto.value);
    }
    if (fotoId.present) {
      map['foto_id'] = Variable<String>(fotoId.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (ocurridaEn.present) {
      map['ocurrida_en'] = Variable<int>(ocurridaEn.value);
    }
    if (registradaPor.present) {
      map['registrada_por'] = Variable<String>(registradaPor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComidasCompanion(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('momento: $momento, ')
          ..write('cuanto: $cuanto, ')
          ..write('fotoId: $fotoId, ')
          ..write('nota: $nota, ')
          ..write('ocurridaEn: $ocurridaEn, ')
          ..write('registradaPor: $registradaPor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HidratacionesTable extends Hidrataciones
    with TableInfo<$HidratacionesTable, Hidratacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HidratacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personas (id)',
    ),
  );
  static const VerificationMeta _vasosMeta = const VerificationMeta('vasos');
  @override
  late final GeneratedColumn<int> vasos = GeneratedColumn<int>(
    'vasos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _ocurridaEnMeta = const VerificationMeta(
    'ocurridaEn',
  );
  @override
  late final GeneratedColumn<int> ocurridaEn = GeneratedColumn<int>(
    'ocurrida_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registradaPorMeta = const VerificationMeta(
    'registradaPor',
  );
  @override
  late final GeneratedColumn<String> registradaPor = GeneratedColumn<String>(
    'registrada_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personaId,
    vasos,
    ocurridaEn,
    registradaPor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidrataciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hidratacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personaIdMeta);
    }
    if (data.containsKey('vasos')) {
      context.handle(
        _vasosMeta,
        vasos.isAcceptableOrUnknown(data['vasos']!, _vasosMeta),
      );
    }
    if (data.containsKey('ocurrida_en')) {
      context.handle(
        _ocurridaEnMeta,
        ocurridaEn.isAcceptableOrUnknown(data['ocurrida_en']!, _ocurridaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_ocurridaEnMeta);
    }
    if (data.containsKey('registrada_por')) {
      context.handle(
        _registradaPorMeta,
        registradaPor.isAcceptableOrUnknown(
          data['registrada_por']!,
          _registradaPorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registradaPorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hidratacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hidratacion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      )!,
      vasos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vasos'],
      )!,
      ocurridaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocurrida_en'],
      )!,
      registradaPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registrada_por'],
      )!,
    );
  }

  @override
  $HidratacionesTable createAlias(String alias) {
    return $HidratacionesTable(attachedDatabase, alias);
  }
}

class Hidratacion extends DataClass implements Insertable<Hidratacion> {
  final String id;
  final String personaId;
  final int vasos;
  final int ocurridaEn;
  final String registradaPor;
  const Hidratacion({
    required this.id,
    required this.personaId,
    required this.vasos,
    required this.ocurridaEn,
    required this.registradaPor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['persona_id'] = Variable<String>(personaId);
    map['vasos'] = Variable<int>(vasos);
    map['ocurrida_en'] = Variable<int>(ocurridaEn);
    map['registrada_por'] = Variable<String>(registradaPor);
    return map;
  }

  HidratacionesCompanion toCompanion(bool nullToAbsent) {
    return HidratacionesCompanion(
      id: Value(id),
      personaId: Value(personaId),
      vasos: Value(vasos),
      ocurridaEn: Value(ocurridaEn),
      registradaPor: Value(registradaPor),
    );
  }

  factory Hidratacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hidratacion(
      id: serializer.fromJson<String>(json['id']),
      personaId: serializer.fromJson<String>(json['personaId']),
      vasos: serializer.fromJson<int>(json['vasos']),
      ocurridaEn: serializer.fromJson<int>(json['ocurridaEn']),
      registradaPor: serializer.fromJson<String>(json['registradaPor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personaId': serializer.toJson<String>(personaId),
      'vasos': serializer.toJson<int>(vasos),
      'ocurridaEn': serializer.toJson<int>(ocurridaEn),
      'registradaPor': serializer.toJson<String>(registradaPor),
    };
  }

  Hidratacion copyWith({
    String? id,
    String? personaId,
    int? vasos,
    int? ocurridaEn,
    String? registradaPor,
  }) => Hidratacion(
    id: id ?? this.id,
    personaId: personaId ?? this.personaId,
    vasos: vasos ?? this.vasos,
    ocurridaEn: ocurridaEn ?? this.ocurridaEn,
    registradaPor: registradaPor ?? this.registradaPor,
  );
  Hidratacion copyWithCompanion(HidratacionesCompanion data) {
    return Hidratacion(
      id: data.id.present ? data.id.value : this.id,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      vasos: data.vasos.present ? data.vasos.value : this.vasos,
      ocurridaEn: data.ocurridaEn.present
          ? data.ocurridaEn.value
          : this.ocurridaEn,
      registradaPor: data.registradaPor.present
          ? data.registradaPor.value
          : this.registradaPor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hidratacion(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('vasos: $vasos, ')
          ..write('ocurridaEn: $ocurridaEn, ')
          ..write('registradaPor: $registradaPor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personaId, vasos, ocurridaEn, registradaPor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hidratacion &&
          other.id == this.id &&
          other.personaId == this.personaId &&
          other.vasos == this.vasos &&
          other.ocurridaEn == this.ocurridaEn &&
          other.registradaPor == this.registradaPor);
}

class HidratacionesCompanion extends UpdateCompanion<Hidratacion> {
  final Value<String> id;
  final Value<String> personaId;
  final Value<int> vasos;
  final Value<int> ocurridaEn;
  final Value<String> registradaPor;
  final Value<int> rowid;
  const HidratacionesCompanion({
    this.id = const Value.absent(),
    this.personaId = const Value.absent(),
    this.vasos = const Value.absent(),
    this.ocurridaEn = const Value.absent(),
    this.registradaPor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HidratacionesCompanion.insert({
    required String id,
    required String personaId,
    this.vasos = const Value.absent(),
    required int ocurridaEn,
    required String registradaPor,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personaId = Value(personaId),
       ocurridaEn = Value(ocurridaEn),
       registradaPor = Value(registradaPor);
  static Insertable<Hidratacion> custom({
    Expression<String>? id,
    Expression<String>? personaId,
    Expression<int>? vasos,
    Expression<int>? ocurridaEn,
    Expression<String>? registradaPor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personaId != null) 'persona_id': personaId,
      if (vasos != null) 'vasos': vasos,
      if (ocurridaEn != null) 'ocurrida_en': ocurridaEn,
      if (registradaPor != null) 'registrada_por': registradaPor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HidratacionesCompanion copyWith({
    Value<String>? id,
    Value<String>? personaId,
    Value<int>? vasos,
    Value<int>? ocurridaEn,
    Value<String>? registradaPor,
    Value<int>? rowid,
  }) {
    return HidratacionesCompanion(
      id: id ?? this.id,
      personaId: personaId ?? this.personaId,
      vasos: vasos ?? this.vasos,
      ocurridaEn: ocurridaEn ?? this.ocurridaEn,
      registradaPor: registradaPor ?? this.registradaPor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (vasos.present) {
      map['vasos'] = Variable<int>(vasos.value);
    }
    if (ocurridaEn.present) {
      map['ocurrida_en'] = Variable<int>(ocurridaEn.value);
    }
    if (registradaPor.present) {
      map['registrada_por'] = Variable<String>(registradaPor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HidratacionesCompanion(')
          ..write('id: $id, ')
          ..write('personaId: $personaId, ')
          ..write('vasos: $vasos, ')
          ..write('ocurridaEn: $ocurridaEn, ')
          ..write('registradaPor: $registradaPor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CirculosTable circulos = $CirculosTable(this);
  late final $FotosTable fotos = $FotosTable(this);
  late final $PersonasTable personas = $PersonasTable(this);
  late final $MiembrosTable miembros = $MiembrosTable(this);
  late final $DispositivosTable dispositivos = $DispositivosTable(this);
  late final $MedicamentosTable medicamentos = $MedicamentosTable(this);
  late final $ConsentimientosTable consentimientos = $ConsentimientosTable(
    this,
  );
  late final $VocesTable voces = $VocesTable(this);
  late final $FrasesTable frases = $FrasesTable(this);
  late final $PautasTable pautas = $PautasTable(this);
  late final $TomasTable tomas = $TomasTable(this);
  late final $ComprobacionesTable comprobaciones = $ComprobacionesTable(this);
  late final $EventosTable eventos = $EventosTable(this);
  late final $PreguntasControlTable preguntasControl = $PreguntasControlTable(
    this,
  );
  late final $RespuestasTable respuestas = $RespuestasTable(this);
  late final $ComidasTable comidas = $ComidasTable(this);
  late final $HidratacionesTable hidrataciones = $HidratacionesTable(this);
  late final Index pautasPorPauta = Index(
    'pautas_por_pauta',
    'CREATE INDEX pautas_por_pauta ON pautas (pauta_id, version)',
  );
  late final Index eventosPorSujeto = Index(
    'eventos_por_sujeto',
    'CREATE INDEX eventos_por_sujeto ON eventos (sujeto, ocurrido_en)',
  );
  late final Index eventosPorTipo = Index(
    'eventos_por_tipo',
    'CREATE INDEX eventos_por_tipo ON eventos (tipo, ocurrido_en)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    circulos,
    fotos,
    personas,
    miembros,
    dispositivos,
    medicamentos,
    consentimientos,
    voces,
    frases,
    pautas,
    tomas,
    comprobaciones,
    eventos,
    preguntasControl,
    respuestas,
    comidas,
    hidrataciones,
    pautasPorPauta,
    eventosPorSujeto,
    eventosPorTipo,
  ];
}

typedef $$CirculosTableCreateCompanionBuilder = CirculosCompanion Function({
  required String id,
  required String nombre,
  required int creadoEn,
  Value<int> versionClave,
  Value<int> rowid,
});
typedef $$CirculosTableUpdateCompanionBuilder = CirculosCompanion Function({
  Value<String> id,
  Value<String> nombre,
  Value<int> creadoEn,
  Value<int> versionClave,
  Value<int> rowid,
});

final class $$CirculosTableReferences
    extends BaseReferences<_$AppDatabase, $CirculosTable, Circulo> {
  $$CirculosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonasTable, List<Persona>> _personasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.personas,
    aliasName: 'circulos__id__personas__circulo_id',
  );

  $$PersonasTableProcessedTableManager get personasRefs {
    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.circuloId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_personasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MiembrosTable, List<Miembro>> _miembrosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.miembros,
    aliasName: 'circulos__id__miembros__circulo_id',
  );

  $$MiembrosTableProcessedTableManager get miembrosRefs {
    final manager = $$MiembrosTableTableManager(
      $_db,
      $_db.miembros,
    ).filter((f) => f.circuloId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_miembrosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DispositivosTable, List<Dispositivo>>
  _dispositivosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dispositivos,
    aliasName: 'circulos__id__dispositivos__circulo_id',
  );

  $$DispositivosTableProcessedTableManager get dispositivosRefs {
    final manager = $$DispositivosTableTableManager(
      $_db,
      $_db.dispositivos,
    ).filter((f) => f.circuloId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dispositivosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConsentimientosTable, List<Consentimiento>>
  _consentimientosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.consentimientos,
    aliasName: 'circulos__id__consentimientos__circulo_id',
  );

  $$ConsentimientosTableProcessedTableManager get consentimientosRefs {
    final manager = $$ConsentimientosTableTableManager(
      $_db,
      $_db.consentimientos,
    ).filter((f) => f.circuloId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _consentimientosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventosTable, List<Evento>> _eventosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.eventos,
    aliasName: 'circulos__id__eventos__circulo_id',
  );

  $$EventosTableProcessedTableManager get eventosRefs {
    final manager = $$EventosTableTableManager(
      $_db,
      $_db.eventos,
    ).filter((f) => f.circuloId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CirculosTableFilterComposer
    extends Composer<_$AppDatabase, $CirculosTable> {
  $$CirculosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionClave => $composableBuilder(
    column: $table.versionClave,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personasRefs(
    Expression<bool> Function($$PersonasTableFilterComposer f) f,
  ) {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> miembrosRefs(
    Expression<bool> Function($$MiembrosTableFilterComposer f) f,
  ) {
    final $$MiembrosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableFilterComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dispositivosRefs(
    Expression<bool> Function($$DispositivosTableFilterComposer f) f,
  ) {
    final $$DispositivosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dispositivos,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DispositivosTableFilterComposer(
            $db: $db,
            $table: $db.dispositivos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> consentimientosRefs(
    Expression<bool> Function($$ConsentimientosTableFilterComposer f) f,
  ) {
    final $$ConsentimientosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consentimientos,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentimientosTableFilterComposer(
            $db: $db,
            $table: $db.consentimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventosRefs(
    Expression<bool> Function($$EventosTableFilterComposer f) f,
  ) {
    final $$EventosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableFilterComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CirculosTableOrderingComposer
    extends Composer<_$AppDatabase, $CirculosTable> {
  $$CirculosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionClave => $composableBuilder(
    column: $table.versionClave,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CirculosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CirculosTable> {
  $$CirculosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get versionClave => $composableBuilder(
    column: $table.versionClave,
    builder: (column) => column,
  );

  Expression<T> personasRefs<T extends Object>(
    Expression<T> Function($$PersonasTableAnnotationComposer a) f,
  ) {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> miembrosRefs<T extends Object>(
    Expression<T> Function($$MiembrosTableAnnotationComposer a) f,
  ) {
    final $$MiembrosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableAnnotationComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dispositivosRefs<T extends Object>(
    Expression<T> Function($$DispositivosTableAnnotationComposer a) f,
  ) {
    final $$DispositivosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dispositivos,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DispositivosTableAnnotationComposer(
            $db: $db,
            $table: $db.dispositivos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> consentimientosRefs<T extends Object>(
    Expression<T> Function($$ConsentimientosTableAnnotationComposer a) f,
  ) {
    final $$ConsentimientosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consentimientos,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentimientosTableAnnotationComposer(
            $db: $db,
            $table: $db.consentimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventosRefs<T extends Object>(
    Expression<T> Function($$EventosTableAnnotationComposer a) f,
  ) {
    final $$EventosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.circuloId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableAnnotationComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CirculosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CirculosTable,
          Circulo,
          $$CirculosTableFilterComposer,
          $$CirculosTableOrderingComposer,
          $$CirculosTableAnnotationComposer,
          $$CirculosTableCreateCompanionBuilder,
          $$CirculosTableUpdateCompanionBuilder,
          (Circulo, $$CirculosTableReferences),
          Circulo,
          PrefetchHooks Function({
            bool personasRefs,
            bool miembrosRefs,
            bool dispositivosRefs,
            bool consentimientosRefs,
            bool eventosRefs,
          })
        > {
  $$CirculosTableTableManager(_$AppDatabase db, $CirculosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CirculosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CirculosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CirculosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int> versionClave = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CirculosCompanion(
                id: id,
                nombre: nombre,
                creadoEn: creadoEn,
                versionClave: versionClave,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                required int creadoEn,
                Value<int> versionClave = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CirculosCompanion.insert(
                id: id,
                nombre: nombre,
                creadoEn: creadoEn,
                versionClave: versionClave,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CirculosTable, Circulo>(table),
                  $$CirculosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personasRefs = false,
                miembrosRefs = false,
                dispositivosRefs = false,
                consentimientosRefs = false,
                eventosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personasRefs) db.personas,
                    if (miembrosRefs) db.miembros,
                    if (dispositivosRefs) db.dispositivos,
                    if (consentimientosRefs) db.consentimientos,
                    if (eventosRefs) db.eventos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personasRefs)
                        await $_getPrefetchedData<
                          Circulo,
                          $CirculosTable,
                          Persona
                        >(
                          currentTable: table,
                          referencedTable: $$CirculosTableReferences
                              ._personasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CirculosTableReferences(
                                db,
                                table,
                                p0,
                              ).personasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.circuloId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (miembrosRefs)
                        await $_getPrefetchedData<
                          Circulo,
                          $CirculosTable,
                          Miembro
                        >(
                          currentTable: table,
                          referencedTable: $$CirculosTableReferences
                              ._miembrosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CirculosTableReferences(
                                db,
                                table,
                                p0,
                              ).miembrosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.circuloId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dispositivosRefs)
                        await $_getPrefetchedData<
                          Circulo,
                          $CirculosTable,
                          Dispositivo
                        >(
                          currentTable: table,
                          referencedTable: $$CirculosTableReferences
                              ._dispositivosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CirculosTableReferences(
                                db,
                                table,
                                p0,
                              ).dispositivosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.circuloId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (consentimientosRefs)
                        await $_getPrefetchedData<
                          Circulo,
                          $CirculosTable,
                          Consentimiento
                        >(
                          currentTable: table,
                          referencedTable: $$CirculosTableReferences
                              ._consentimientosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CirculosTableReferences(
                                db,
                                table,
                                p0,
                              ).consentimientosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.circuloId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventosRefs)
                        await $_getPrefetchedData<
                          Circulo,
                          $CirculosTable,
                          Evento
                        >(
                          currentTable: table,
                          referencedTable: $$CirculosTableReferences
                              ._eventosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CirculosTableReferences(
                                db,
                                table,
                                p0,
                              ).eventosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.circuloId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CirculosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CirculosTable,
      Circulo,
      $$CirculosTableFilterComposer,
      $$CirculosTableOrderingComposer,
      $$CirculosTableAnnotationComposer,
      $$CirculosTableCreateCompanionBuilder,
      $$CirculosTableUpdateCompanionBuilder,
      (Circulo, $$CirculosTableReferences),
      Circulo,
      PrefetchHooks Function({
        bool personasRefs,
        bool miembrosRefs,
        bool dispositivosRefs,
        bool consentimientosRefs,
        bool eventosRefs,
      })
    >;
typedef $$FotosTableCreateCompanionBuilder = FotosCompanion Function({
  required String id,
  required Uint8List bytes,
  required String mime,
  required int creadaEn,
  Value<int> rowid,
});
typedef $$FotosTableUpdateCompanionBuilder = FotosCompanion Function({
  Value<String> id,
  Value<Uint8List> bytes,
  Value<String> mime,
  Value<int> creadaEn,
  Value<int> rowid,
});

final class $$FotosTableReferences
    extends BaseReferences<_$AppDatabase, $FotosTable, Foto> {
  $$FotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonasTable, List<Persona>> _personasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.personas,
    aliasName: 'fotos__id__personas__foto_id',
  );

  $$PersonasTableProcessedTableManager get personasRefs {
    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.fotoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_personasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MiembrosTable, List<Miembro>> _miembrosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.miembros,
    aliasName: 'fotos__id__miembros__foto_id',
  );

  $$MiembrosTableProcessedTableManager get miembrosRefs {
    final manager = $$MiembrosTableTableManager(
      $_db,
      $_db.miembros,
    ).filter((f) => f.fotoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_miembrosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MedicamentosTable, List<Medicamento>>
  _medicamentosDeCajaTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicamentos,
    aliasName: 'fotos__id__medicamentos__foto_caja_id',
  );

  $$MedicamentosTableProcessedTableManager get medicamentosDeCaja {
    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.fotoCajaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicamentosDeCajaTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MedicamentosTable, List<Medicamento>>
  _medicamentosDePastillaTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.medicamentos,
        aliasName: 'fotos__id__medicamentos__foto_pastilla_id',
      );

  $$MedicamentosTableProcessedTableManager get medicamentosDePastilla {
    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.fotoPastillaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicamentosDePastillaTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConsentimientosTable, List<Consentimiento>>
  _consentimientosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.consentimientos,
    aliasName: 'fotos__id__consentimientos__documento_foto_id',
  );

  $$ConsentimientosTableProcessedTableManager get consentimientosRefs {
    final manager =
        $$ConsentimientosTableTableManager($_db, $_db.consentimientos).filter(
          (f) => f.documentoFotoId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _consentimientosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComidasTable, List<Comida>> _comidasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.comidas,
    aliasName: 'fotos__id__comidas__foto_id',
  );

  $$ComidasTableProcessedTableManager get comidasRefs {
    final manager = $$ComidasTableTableManager(
      $_db,
      $_db.comidas,
    ).filter((f) => f.fotoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_comidasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FotosTableFilterComposer extends Composer<_$AppDatabase, $FotosTable> {
  $$FotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personasRefs(
    Expression<bool> Function($$PersonasTableFilterComposer f) f,
  ) {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.fotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> miembrosRefs(
    Expression<bool> Function($$MiembrosTableFilterComposer f) f,
  ) {
    final $$MiembrosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.fotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableFilterComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicamentosDeCaja(
    Expression<bool> Function($$MedicamentosTableFilterComposer f) f,
  ) {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.fotoCajaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicamentosDePastilla(
    Expression<bool> Function($$MedicamentosTableFilterComposer f) f,
  ) {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.fotoPastillaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> consentimientosRefs(
    Expression<bool> Function($$ConsentimientosTableFilterComposer f) f,
  ) {
    final $$ConsentimientosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consentimientos,
      getReferencedColumn: (t) => t.documentoFotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentimientosTableFilterComposer(
            $db: $db,
            $table: $db.consentimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> comidasRefs(
    Expression<bool> Function($$ComidasTableFilterComposer f) f,
  ) {
    final $$ComidasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comidas,
      getReferencedColumn: (t) => t.fotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComidasTableFilterComposer(
            $db: $db,
            $table: $db.comidas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FotosTableOrderingComposer
    extends Composer<_$AppDatabase, $FotosTable> {
  $$FotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $FotosTable> {
  $$FotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  Expression<T> personasRefs<T extends Object>(
    Expression<T> Function($$PersonasTableAnnotationComposer a) f,
  ) {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.fotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> miembrosRefs<T extends Object>(
    Expression<T> Function($$MiembrosTableAnnotationComposer a) f,
  ) {
    final $$MiembrosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.fotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableAnnotationComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> medicamentosDeCaja<T extends Object>(
    Expression<T> Function($$MedicamentosTableAnnotationComposer a) f,
  ) {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.fotoCajaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> medicamentosDePastilla<T extends Object>(
    Expression<T> Function($$MedicamentosTableAnnotationComposer a) f,
  ) {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.fotoPastillaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> consentimientosRefs<T extends Object>(
    Expression<T> Function($$ConsentimientosTableAnnotationComposer a) f,
  ) {
    final $$ConsentimientosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consentimientos,
      getReferencedColumn: (t) => t.documentoFotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentimientosTableAnnotationComposer(
            $db: $db,
            $table: $db.consentimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> comidasRefs<T extends Object>(
    Expression<T> Function($$ComidasTableAnnotationComposer a) f,
  ) {
    final $$ComidasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comidas,
      getReferencedColumn: (t) => t.fotoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComidasTableAnnotationComposer(
            $db: $db,
            $table: $db.comidas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FotosTable,
          Foto,
          $$FotosTableFilterComposer,
          $$FotosTableOrderingComposer,
          $$FotosTableAnnotationComposer,
          $$FotosTableCreateCompanionBuilder,
          $$FotosTableUpdateCompanionBuilder,
          (Foto, $$FotosTableReferences),
          Foto,
          PrefetchHooks Function({
            bool personasRefs,
            bool miembrosRefs,
            bool medicamentosDeCaja,
            bool medicamentosDePastilla,
            bool consentimientosRefs,
            bool comidasRefs,
          })
        > {
  $$FotosTableTableManager(_$AppDatabase db, $FotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> creadaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FotosCompanion(
                id: id,
                bytes: bytes,
                mime: mime,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List bytes,
                required String mime,
                required int creadaEn,
                Value<int> rowid = const Value.absent(),
              }) => FotosCompanion.insert(
                id: id,
                bytes: bytes,
                mime: mime,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FotosTable, Foto>(table),
                  $$FotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personasRefs = false,
                miembrosRefs = false,
                medicamentosDeCaja = false,
                medicamentosDePastilla = false,
                consentimientosRefs = false,
                comidasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personasRefs) db.personas,
                    if (miembrosRefs) db.miembros,
                    if (medicamentosDeCaja) db.medicamentos,
                    if (medicamentosDePastilla) db.medicamentos,
                    if (consentimientosRefs) db.consentimientos,
                    if (comidasRefs) db.comidas,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personasRefs)
                        await $_getPrefetchedData<Foto, $FotosTable, Persona>(
                          currentTable: table,
                          referencedTable: $$FotosTableReferences
                              ._personasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FotosTableReferences(
                                db,
                                table,
                                p0,
                              ).personasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fotoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (miembrosRefs)
                        await $_getPrefetchedData<Foto, $FotosTable, Miembro>(
                          currentTable: table,
                          referencedTable: $$FotosTableReferences
                              ._miembrosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FotosTableReferences(
                                db,
                                table,
                                p0,
                              ).miembrosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fotoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicamentosDeCaja)
                        await $_getPrefetchedData<
                          Foto,
                          $FotosTable,
                          Medicamento
                        >(
                          currentTable: table,
                          referencedTable: $$FotosTableReferences
                              ._medicamentosDeCajaTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FotosTableReferences(
                                db,
                                table,
                                p0,
                              ).medicamentosDeCaja,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fotoCajaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicamentosDePastilla)
                        await $_getPrefetchedData<
                          Foto,
                          $FotosTable,
                          Medicamento
                        >(
                          currentTable: table,
                          referencedTable: $$FotosTableReferences
                              ._medicamentosDePastillaTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FotosTableReferences(
                                db,
                                table,
                                p0,
                              ).medicamentosDePastilla,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fotoPastillaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (consentimientosRefs)
                        await $_getPrefetchedData<
                          Foto,
                          $FotosTable,
                          Consentimiento
                        >(
                          currentTable: table,
                          referencedTable: $$FotosTableReferences
                              ._consentimientosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FotosTableReferences(
                                db,
                                table,
                                p0,
                              ).consentimientosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentoFotoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (comidasRefs)
                        await $_getPrefetchedData<Foto, $FotosTable, Comida>(
                          currentTable: table,
                          referencedTable: $$FotosTableReferences
                              ._comidasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FotosTableReferences(db, table, p0).comidasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fotoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FotosTable,
      Foto,
      $$FotosTableFilterComposer,
      $$FotosTableOrderingComposer,
      $$FotosTableAnnotationComposer,
      $$FotosTableCreateCompanionBuilder,
      $$FotosTableUpdateCompanionBuilder,
      (Foto, $$FotosTableReferences),
      Foto,
      PrefetchHooks Function({
        bool personasRefs,
        bool miembrosRefs,
        bool medicamentosDeCaja,
        bool medicamentosDePastilla,
        bool consentimientosRefs,
        bool comidasRefs,
      })
    >;
typedef $$PersonasTableCreateCompanionBuilder = PersonasCompanion Function({
  required String id,
  required String circuloId,
  required String alias,
  Value<String?> fotoId,
  Value<String> zonaHoraria,
  required int creadaEn,
  Value<int> rowid,
});
typedef $$PersonasTableUpdateCompanionBuilder = PersonasCompanion Function({
  Value<String> id,
  Value<String> circuloId,
  Value<String> alias,
  Value<String?> fotoId,
  Value<String> zonaHoraria,
  Value<int> creadaEn,
  Value<int> rowid,
});

final class $$PersonasTableReferences
    extends BaseReferences<_$AppDatabase, $PersonasTable, Persona> {
  $$PersonasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CirculosTable _circuloIdTable(_$AppDatabase db) =>
      db.circulos.createAlias('personas__circulo_id__circulos__id');

  $$CirculosTableProcessedTableManager get circuloId {
    final $_column = $_itemColumn<String>('circulo_id')!;

    final manager = $$CirculosTableTableManager(
      $_db,
      $_db.circulos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circuloIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FotosTable _fotoIdTable(_$AppDatabase db) =>
      db.fotos.createAlias('personas__foto_id__fotos__id');

  $$FotosTableProcessedTableManager? get fotoId {
    final $_column = $_itemColumn<String>('foto_id');
    if ($_column == null) return null;
    final manager = $$FotosTableTableManager(
      $_db,
      $_db.fotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fotoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MedicamentosTable, List<Medicamento>>
  _medicamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicamentos,
    aliasName: 'personas__id__medicamentos__persona_id',
  );

  $$MedicamentosTableProcessedTableManager get medicamentosRefs {
    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.personaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PautasTable, List<Pauta>> _pautasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pautas,
    aliasName: 'personas__id__pautas__persona_id',
  );

  $$PautasTableProcessedTableManager get pautasRefs {
    final manager = $$PautasTableTableManager(
      $_db,
      $_db.pautas,
    ).filter((f) => f.personaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pautasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TomasTable, List<Toma>> _tomasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tomas,
    aliasName: 'personas__id__tomas__persona_id',
  );

  $$TomasTableProcessedTableManager get tomasRefs {
    final manager = $$TomasTableTableManager(
      $_db,
      $_db.tomas,
    ).filter((f) => f.personaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tomasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PreguntasControlTable, List<PreguntaControl>>
  _preguntasControlRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.preguntasControl,
    aliasName: 'personas__id__preguntas_control__persona_id',
  );

  $$PreguntasControlTableProcessedTableManager get preguntasControlRefs {
    final manager = $$PreguntasControlTableTableManager(
      $_db,
      $_db.preguntasControl,
    ).filter((f) => f.personaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preguntasControlRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComidasTable, List<Comida>> _comidasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.comidas,
    aliasName: 'personas__id__comidas__persona_id',
  );

  $$ComidasTableProcessedTableManager get comidasRefs {
    final manager = $$ComidasTableTableManager(
      $_db,
      $_db.comidas,
    ).filter((f) => f.personaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_comidasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HidratacionesTable, List<Hidratacion>>
  _hidratacionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hidrataciones,
    aliasName: 'personas__id__hidrataciones__persona_id',
  );

  $$HidratacionesTableProcessedTableManager get hidratacionesRefs {
    final manager = $$HidratacionesTableTableManager(
      $_db,
      $_db.hidrataciones,
    ).filter((f) => f.personaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_hidratacionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonasTableFilterComposer
    extends Composer<_$AppDatabase, $PersonasTable> {
  $$PersonasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zonaHoraria => $composableBuilder(
    column: $table.zonaHoraria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnFilters(column),
  );

  $$CirculosTableFilterComposer get circuloId {
    final $$CirculosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableFilterComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableFilterComposer get fotoId {
    final $$FotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableFilterComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> medicamentosRefs(
    Expression<bool> Function($$MedicamentosTableFilterComposer f) f,
  ) {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pautasRefs(
    Expression<bool> Function($$PautasTableFilterComposer f) f,
  ) {
    final $$PautasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableFilterComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tomasRefs(
    Expression<bool> Function($$TomasTableFilterComposer f) f,
  ) {
    final $$TomasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tomas,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TomasTableFilterComposer(
            $db: $db,
            $table: $db.tomas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> preguntasControlRefs(
    Expression<bool> Function($$PreguntasControlTableFilterComposer f) f,
  ) {
    final $$PreguntasControlTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntasControl,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasControlTableFilterComposer(
            $db: $db,
            $table: $db.preguntasControl,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> comidasRefs(
    Expression<bool> Function($$ComidasTableFilterComposer f) f,
  ) {
    final $$ComidasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comidas,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComidasTableFilterComposer(
            $db: $db,
            $table: $db.comidas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> hidratacionesRefs(
    Expression<bool> Function($$HidratacionesTableFilterComposer f) f,
  ) {
    final $$HidratacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hidrataciones,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HidratacionesTableFilterComposer(
            $db: $db,
            $table: $db.hidrataciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonasTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonasTable> {
  $$PersonasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zonaHoraria => $composableBuilder(
    column: $table.zonaHoraria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirculosTableOrderingComposer get circuloId {
    final $$CirculosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableOrderingComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableOrderingComposer get fotoId {
    final $$FotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableOrderingComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonasTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonasTable> {
  $$PersonasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get zonaHoraria => $composableBuilder(
    column: $table.zonaHoraria,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  $$CirculosTableAnnotationComposer get circuloId {
    final $$CirculosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableAnnotationComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableAnnotationComposer get fotoId {
    final $$FotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableAnnotationComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> medicamentosRefs<T extends Object>(
    Expression<T> Function($$MedicamentosTableAnnotationComposer a) f,
  ) {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pautasRefs<T extends Object>(
    Expression<T> Function($$PautasTableAnnotationComposer a) f,
  ) {
    final $$PautasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableAnnotationComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tomasRefs<T extends Object>(
    Expression<T> Function($$TomasTableAnnotationComposer a) f,
  ) {
    final $$TomasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tomas,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TomasTableAnnotationComposer(
            $db: $db,
            $table: $db.tomas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> preguntasControlRefs<T extends Object>(
    Expression<T> Function($$PreguntasControlTableAnnotationComposer a) f,
  ) {
    final $$PreguntasControlTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntasControl,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasControlTableAnnotationComposer(
            $db: $db,
            $table: $db.preguntasControl,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> comidasRefs<T extends Object>(
    Expression<T> Function($$ComidasTableAnnotationComposer a) f,
  ) {
    final $$ComidasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comidas,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComidasTableAnnotationComposer(
            $db: $db,
            $table: $db.comidas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> hidratacionesRefs<T extends Object>(
    Expression<T> Function($$HidratacionesTableAnnotationComposer a) f,
  ) {
    final $$HidratacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hidrataciones,
      getReferencedColumn: (t) => t.personaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HidratacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.hidrataciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonasTable,
          Persona,
          $$PersonasTableFilterComposer,
          $$PersonasTableOrderingComposer,
          $$PersonasTableAnnotationComposer,
          $$PersonasTableCreateCompanionBuilder,
          $$PersonasTableUpdateCompanionBuilder,
          (Persona, $$PersonasTableReferences),
          Persona,
          PrefetchHooks Function({
            bool circuloId,
            bool fotoId,
            bool medicamentosRefs,
            bool pautasRefs,
            bool tomasRefs,
            bool preguntasControlRefs,
            bool comidasRefs,
            bool hidratacionesRefs,
          })
        > {
  $$PersonasTableTableManager(_$AppDatabase db, $PersonasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> circuloId = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<String?> fotoId = const Value.absent(),
                Value<String> zonaHoraria = const Value.absent(),
                Value<int> creadaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonasCompanion(
                id: id,
                circuloId: circuloId,
                alias: alias,
                fotoId: fotoId,
                zonaHoraria: zonaHoraria,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String circuloId,
                required String alias,
                Value<String?> fotoId = const Value.absent(),
                Value<String> zonaHoraria = const Value.absent(),
                required int creadaEn,
                Value<int> rowid = const Value.absent(),
              }) => PersonasCompanion.insert(
                id: id,
                circuloId: circuloId,
                alias: alias,
                fotoId: fotoId,
                zonaHoraria: zonaHoraria,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonasTable, Persona>(table),
                  $$PersonasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                circuloId = false,
                fotoId = false,
                medicamentosRefs = false,
                pautasRefs = false,
                tomasRefs = false,
                preguntasControlRefs = false,
                comidasRefs = false,
                hidratacionesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicamentosRefs) db.medicamentos,
                    if (pautasRefs) db.pautas,
                    if (tomasRefs) db.tomas,
                    if (preguntasControlRefs) db.preguntasControl,
                    if (comidasRefs) db.comidas,
                    if (hidratacionesRefs) db.hidrataciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (circuloId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.circuloId,
                            referencedTable: $$PersonasTableReferences
                                ._circuloIdTable(db),
                            referencedColumn: $$PersonasTableReferences
                                ._circuloIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (fotoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fotoId,
                            referencedTable: $$PersonasTableReferences
                                ._fotoIdTable(db),
                            referencedColumn: $$PersonasTableReferences
                                ._fotoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicamentosRefs)
                        await $_getPrefetchedData<
                          Persona,
                          $PersonasTable,
                          Medicamento
                        >(
                          currentTable: table,
                          referencedTable: $$PersonasTableReferences
                              ._medicamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonasTableReferences(
                                db,
                                table,
                                p0,
                              ).medicamentosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pautasRefs)
                        await $_getPrefetchedData<
                          Persona,
                          $PersonasTable,
                          Pauta
                        >(
                          currentTable: table,
                          referencedTable: $$PersonasTableReferences
                              ._pautasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonasTableReferences(
                                db,
                                table,
                                p0,
                              ).pautasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tomasRefs)
                        await $_getPrefetchedData<
                          Persona,
                          $PersonasTable,
                          Toma
                        >(
                          currentTable: table,
                          referencedTable: $$PersonasTableReferences
                              ._tomasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonasTableReferences(
                                db,
                                table,
                                p0,
                              ).tomasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (preguntasControlRefs)
                        await $_getPrefetchedData<
                          Persona,
                          $PersonasTable,
                          PreguntaControl
                        >(
                          currentTable: table,
                          referencedTable: $$PersonasTableReferences
                              ._preguntasControlRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonasTableReferences(
                                db,
                                table,
                                p0,
                              ).preguntasControlRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (comidasRefs)
                        await $_getPrefetchedData<
                          Persona,
                          $PersonasTable,
                          Comida
                        >(
                          currentTable: table,
                          referencedTable: $$PersonasTableReferences
                              ._comidasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonasTableReferences(
                                db,
                                table,
                                p0,
                              ).comidasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (hidratacionesRefs)
                        await $_getPrefetchedData<
                          Persona,
                          $PersonasTable,
                          Hidratacion
                        >(
                          currentTable: table,
                          referencedTable: $$PersonasTableReferences
                              ._hidratacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonasTableReferences(
                                db,
                                table,
                                p0,
                              ).hidratacionesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PersonasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonasTable,
      Persona,
      $$PersonasTableFilterComposer,
      $$PersonasTableOrderingComposer,
      $$PersonasTableAnnotationComposer,
      $$PersonasTableCreateCompanionBuilder,
      $$PersonasTableUpdateCompanionBuilder,
      (Persona, $$PersonasTableReferences),
      Persona,
      PrefetchHooks Function({
        bool circuloId,
        bool fotoId,
        bool medicamentosRefs,
        bool pautasRefs,
        bool tomasRefs,
        bool preguntasControlRefs,
        bool comidasRefs,
        bool hidratacionesRefs,
      })
    >;
typedef $$MiembrosTableCreateCompanionBuilder = MiembrosCompanion Function({
  required String id,
  required String circuloId,
  required String nombre,
  required String relacion,
  Value<String?> telefono,
  Value<String?> fotoId,
  required String rol,
  Value<int?> ordenEscalado,
  Value<bool> enMiGente,
  required int creadoEn,
  Value<int> rowid,
});
typedef $$MiembrosTableUpdateCompanionBuilder = MiembrosCompanion Function({
  Value<String> id,
  Value<String> circuloId,
  Value<String> nombre,
  Value<String> relacion,
  Value<String?> telefono,
  Value<String?> fotoId,
  Value<String> rol,
  Value<int?> ordenEscalado,
  Value<bool> enMiGente,
  Value<int> creadoEn,
  Value<int> rowid,
});

final class $$MiembrosTableReferences
    extends BaseReferences<_$AppDatabase, $MiembrosTable, Miembro> {
  $$MiembrosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CirculosTable _circuloIdTable(_$AppDatabase db) =>
      db.circulos.createAlias('miembros__circulo_id__circulos__id');

  $$CirculosTableProcessedTableManager get circuloId {
    final $_column = $_itemColumn<String>('circulo_id')!;

    final manager = $$CirculosTableTableManager(
      $_db,
      $_db.circulos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circuloIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FotosTable _fotoIdTable(_$AppDatabase db) =>
      db.fotos.createAlias('miembros__foto_id__fotos__id');

  $$FotosTableProcessedTableManager? get fotoId {
    final $_column = $_itemColumn<String>('foto_id');
    if ($_column == null) return null;
    final manager = $$FotosTableTableManager(
      $_db,
      $_db.fotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fotoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DispositivosTable, List<Dispositivo>>
  _dispositivosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dispositivos,
    aliasName: 'miembros__id__dispositivos__miembro_id',
  );

  $$DispositivosTableProcessedTableManager get dispositivosRefs {
    final manager = $$DispositivosTableTableManager(
      $_db,
      $_db.dispositivos,
    ).filter((f) => f.miembroId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dispositivosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VocesTable, List<Voz>> _vocesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.voces,
    aliasName: 'miembros__id__voces__miembro_id',
  );

  $$VocesTableProcessedTableManager get vocesRefs {
    final manager = $$VocesTableTableManager(
      $_db,
      $_db.voces,
    ).filter((f) => f.miembroId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vocesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComprobacionesTable, List<ComprobacionToma>>
  _comprobacionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.comprobaciones,
    aliasName: 'miembros__id__comprobaciones__revisor_miembro_id',
  );

  $$ComprobacionesTableProcessedTableManager get comprobacionesRefs {
    final manager = $$ComprobacionesTableTableManager($_db, $_db.comprobaciones)
        .filter(
          (f) => f.revisorMiembroId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_comprobacionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MiembrosTableFilterComposer
    extends Composer<_$AppDatabase, $MiembrosTable> {
  $$MiembrosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relacion => $composableBuilder(
    column: $table.relacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordenEscalado => $composableBuilder(
    column: $table.ordenEscalado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enMiGente => $composableBuilder(
    column: $table.enMiGente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$CirculosTableFilterComposer get circuloId {
    final $$CirculosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableFilterComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableFilterComposer get fotoId {
    final $$FotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableFilterComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dispositivosRefs(
    Expression<bool> Function($$DispositivosTableFilterComposer f) f,
  ) {
    final $$DispositivosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dispositivos,
      getReferencedColumn: (t) => t.miembroId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DispositivosTableFilterComposer(
            $db: $db,
            $table: $db.dispositivos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vocesRefs(
    Expression<bool> Function($$VocesTableFilterComposer f) f,
  ) {
    final $$VocesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.miembroId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableFilterComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> comprobacionesRefs(
    Expression<bool> Function($$ComprobacionesTableFilterComposer f) f,
  ) {
    final $$ComprobacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comprobaciones,
      getReferencedColumn: (t) => t.revisorMiembroId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprobacionesTableFilterComposer(
            $db: $db,
            $table: $db.comprobaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MiembrosTableOrderingComposer
    extends Composer<_$AppDatabase, $MiembrosTable> {
  $$MiembrosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relacion => $composableBuilder(
    column: $table.relacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordenEscalado => $composableBuilder(
    column: $table.ordenEscalado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enMiGente => $composableBuilder(
    column: $table.enMiGente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirculosTableOrderingComposer get circuloId {
    final $$CirculosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableOrderingComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableOrderingComposer get fotoId {
    final $$FotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableOrderingComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MiembrosTableAnnotationComposer
    extends Composer<_$AppDatabase, $MiembrosTable> {
  $$MiembrosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get relacion =>
      $composableBuilder(column: $table.relacion, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<int> get ordenEscalado => $composableBuilder(
    column: $table.ordenEscalado,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enMiGente =>
      $composableBuilder(column: $table.enMiGente, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  $$CirculosTableAnnotationComposer get circuloId {
    final $$CirculosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableAnnotationComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableAnnotationComposer get fotoId {
    final $$FotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableAnnotationComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dispositivosRefs<T extends Object>(
    Expression<T> Function($$DispositivosTableAnnotationComposer a) f,
  ) {
    final $$DispositivosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dispositivos,
      getReferencedColumn: (t) => t.miembroId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DispositivosTableAnnotationComposer(
            $db: $db,
            $table: $db.dispositivos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vocesRefs<T extends Object>(
    Expression<T> Function($$VocesTableAnnotationComposer a) f,
  ) {
    final $$VocesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.miembroId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableAnnotationComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> comprobacionesRefs<T extends Object>(
    Expression<T> Function($$ComprobacionesTableAnnotationComposer a) f,
  ) {
    final $$ComprobacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comprobaciones,
      getReferencedColumn: (t) => t.revisorMiembroId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprobacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.comprobaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MiembrosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MiembrosTable,
          Miembro,
          $$MiembrosTableFilterComposer,
          $$MiembrosTableOrderingComposer,
          $$MiembrosTableAnnotationComposer,
          $$MiembrosTableCreateCompanionBuilder,
          $$MiembrosTableUpdateCompanionBuilder,
          (Miembro, $$MiembrosTableReferences),
          Miembro,
          PrefetchHooks Function({
            bool circuloId,
            bool fotoId,
            bool dispositivosRefs,
            bool vocesRefs,
            bool comprobacionesRefs,
          })
        > {
  $$MiembrosTableTableManager(_$AppDatabase db, $MiembrosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MiembrosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MiembrosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MiembrosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> circuloId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> relacion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> fotoId = const Value.absent(),
                Value<String> rol = const Value.absent(),
                Value<int?> ordenEscalado = const Value.absent(),
                Value<bool> enMiGente = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MiembrosCompanion(
                id: id,
                circuloId: circuloId,
                nombre: nombre,
                relacion: relacion,
                telefono: telefono,
                fotoId: fotoId,
                rol: rol,
                ordenEscalado: ordenEscalado,
                enMiGente: enMiGente,
                creadoEn: creadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String circuloId,
                required String nombre,
                required String relacion,
                Value<String?> telefono = const Value.absent(),
                Value<String?> fotoId = const Value.absent(),
                required String rol,
                Value<int?> ordenEscalado = const Value.absent(),
                Value<bool> enMiGente = const Value.absent(),
                required int creadoEn,
                Value<int> rowid = const Value.absent(),
              }) => MiembrosCompanion.insert(
                id: id,
                circuloId: circuloId,
                nombre: nombre,
                relacion: relacion,
                telefono: telefono,
                fotoId: fotoId,
                rol: rol,
                ordenEscalado: ordenEscalado,
                enMiGente: enMiGente,
                creadoEn: creadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MiembrosTable, Miembro>(table),
                  $$MiembrosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                circuloId = false,
                fotoId = false,
                dispositivosRefs = false,
                vocesRefs = false,
                comprobacionesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dispositivosRefs) db.dispositivos,
                    if (vocesRefs) db.voces,
                    if (comprobacionesRefs) db.comprobaciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (circuloId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.circuloId,
                            referencedTable: $$MiembrosTableReferences
                                ._circuloIdTable(db),
                            referencedColumn: $$MiembrosTableReferences
                                ._circuloIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (fotoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fotoId,
                            referencedTable: $$MiembrosTableReferences
                                ._fotoIdTable(db),
                            referencedColumn: $$MiembrosTableReferences
                                ._fotoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dispositivosRefs)
                        await $_getPrefetchedData<
                          Miembro,
                          $MiembrosTable,
                          Dispositivo
                        >(
                          currentTable: table,
                          referencedTable: $$MiembrosTableReferences
                              ._dispositivosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MiembrosTableReferences(
                                db,
                                table,
                                p0,
                              ).dispositivosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.miembroId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vocesRefs)
                        await $_getPrefetchedData<Miembro, $MiembrosTable, Voz>(
                          currentTable: table,
                          referencedTable: $$MiembrosTableReferences
                              ._vocesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MiembrosTableReferences(
                                db,
                                table,
                                p0,
                              ).vocesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.miembroId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (comprobacionesRefs)
                        await $_getPrefetchedData<
                          Miembro,
                          $MiembrosTable,
                          ComprobacionToma
                        >(
                          currentTable: table,
                          referencedTable: $$MiembrosTableReferences
                              ._comprobacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MiembrosTableReferences(
                                db,
                                table,
                                p0,
                              ).comprobacionesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisorMiembroId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MiembrosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MiembrosTable,
      Miembro,
      $$MiembrosTableFilterComposer,
      $$MiembrosTableOrderingComposer,
      $$MiembrosTableAnnotationComposer,
      $$MiembrosTableCreateCompanionBuilder,
      $$MiembrosTableUpdateCompanionBuilder,
      (Miembro, $$MiembrosTableReferences),
      Miembro,
      PrefetchHooks Function({
        bool circuloId,
        bool fotoId,
        bool dispositivosRefs,
        bool vocesRefs,
        bool comprobacionesRefs,
      })
    >;
typedef $$DispositivosTableCreateCompanionBuilder =
    DispositivosCompanion Function({
      required String id,
      required String circuloId,
      required String perfil,
      required String plataforma,
      Value<String?> miembroId,
      required int registradoEn,
      Value<int> rowid,
    });
typedef $$DispositivosTableUpdateCompanionBuilder =
    DispositivosCompanion Function({
      Value<String> id,
      Value<String> circuloId,
      Value<String> perfil,
      Value<String> plataforma,
      Value<String?> miembroId,
      Value<int> registradoEn,
      Value<int> rowid,
    });

final class $$DispositivosTableReferences
    extends BaseReferences<_$AppDatabase, $DispositivosTable, Dispositivo> {
  $$DispositivosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CirculosTable _circuloIdTable(_$AppDatabase db) =>
      db.circulos.createAlias('dispositivos__circulo_id__circulos__id');

  $$CirculosTableProcessedTableManager get circuloId {
    final $_column = $_itemColumn<String>('circulo_id')!;

    final manager = $$CirculosTableTableManager(
      $_db,
      $_db.circulos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circuloIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MiembrosTable _miembroIdTable(_$AppDatabase db) =>
      db.miembros.createAlias('dispositivos__miembro_id__miembros__id');

  $$MiembrosTableProcessedTableManager? get miembroId {
    final $_column = $_itemColumn<String>('miembro_id');
    if ($_column == null) return null;
    final manager = $$MiembrosTableTableManager(
      $_db,
      $_db.miembros,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_miembroIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DispositivosTableFilterComposer
    extends Composer<_$AppDatabase, $DispositivosTable> {
  $$DispositivosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get perfil => $composableBuilder(
    column: $table.perfil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plataforma => $composableBuilder(
    column: $table.plataforma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$CirculosTableFilterComposer get circuloId {
    final $$CirculosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableFilterComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MiembrosTableFilterComposer get miembroId {
    final $$MiembrosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.miembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableFilterComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DispositivosTableOrderingComposer
    extends Composer<_$AppDatabase, $DispositivosTable> {
  $$DispositivosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get perfil => $composableBuilder(
    column: $table.perfil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plataforma => $composableBuilder(
    column: $table.plataforma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirculosTableOrderingComposer get circuloId {
    final $$CirculosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableOrderingComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MiembrosTableOrderingComposer get miembroId {
    final $$MiembrosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.miembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableOrderingComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DispositivosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DispositivosTable> {
  $$DispositivosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get perfil =>
      $composableBuilder(column: $table.perfil, builder: (column) => column);

  GeneratedColumn<String> get plataforma => $composableBuilder(
    column: $table.plataforma,
    builder: (column) => column,
  );

  GeneratedColumn<int> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => column,
  );

  $$CirculosTableAnnotationComposer get circuloId {
    final $$CirculosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableAnnotationComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MiembrosTableAnnotationComposer get miembroId {
    final $$MiembrosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.miembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableAnnotationComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DispositivosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DispositivosTable,
          Dispositivo,
          $$DispositivosTableFilterComposer,
          $$DispositivosTableOrderingComposer,
          $$DispositivosTableAnnotationComposer,
          $$DispositivosTableCreateCompanionBuilder,
          $$DispositivosTableUpdateCompanionBuilder,
          (Dispositivo, $$DispositivosTableReferences),
          Dispositivo,
          PrefetchHooks Function({bool circuloId, bool miembroId})
        > {
  $$DispositivosTableTableManager(_$AppDatabase db, $DispositivosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DispositivosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DispositivosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DispositivosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> circuloId = const Value.absent(),
                Value<String> perfil = const Value.absent(),
                Value<String> plataforma = const Value.absent(),
                Value<String?> miembroId = const Value.absent(),
                Value<int> registradoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DispositivosCompanion(
                id: id,
                circuloId: circuloId,
                perfil: perfil,
                plataforma: plataforma,
                miembroId: miembroId,
                registradoEn: registradoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String circuloId,
                required String perfil,
                required String plataforma,
                Value<String?> miembroId = const Value.absent(),
                required int registradoEn,
                Value<int> rowid = const Value.absent(),
              }) => DispositivosCompanion.insert(
                id: id,
                circuloId: circuloId,
                perfil: perfil,
                plataforma: plataforma,
                miembroId: miembroId,
                registradoEn: registradoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DispositivosTable, Dispositivo>(table),
                  $$DispositivosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({circuloId = false, miembroId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (circuloId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.circuloId,
                        referencedTable: $$DispositivosTableReferences
                            ._circuloIdTable(db),
                        referencedColumn: $$DispositivosTableReferences
                            ._circuloIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (miembroId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.miembroId,
                        referencedTable: $$DispositivosTableReferences
                            ._miembroIdTable(db),
                        referencedColumn: $$DispositivosTableReferences
                            ._miembroIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DispositivosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DispositivosTable,
      Dispositivo,
      $$DispositivosTableFilterComposer,
      $$DispositivosTableOrderingComposer,
      $$DispositivosTableAnnotationComposer,
      $$DispositivosTableCreateCompanionBuilder,
      $$DispositivosTableUpdateCompanionBuilder,
      (Dispositivo, $$DispositivosTableReferences),
      Dispositivo,
      PrefetchHooks Function({bool circuloId, bool miembroId})
    >;
typedef $$MedicamentosTableCreateCompanionBuilder =
    MedicamentosCompanion Function({
      required String id,
      required String personaId,
      required String nombre,
      required String nombreParaPersona,
      required String forma,
      Value<String?> color,
      Value<String?> fotoCajaId,
      Value<String?> fotoPastillaId,
      Value<String?> registroCima,
      required int creadoEn,
      Value<int?> retiradoEn,
      Value<int> rowid,
    });
typedef $$MedicamentosTableUpdateCompanionBuilder =
    MedicamentosCompanion Function({
      Value<String> id,
      Value<String> personaId,
      Value<String> nombre,
      Value<String> nombreParaPersona,
      Value<String> forma,
      Value<String?> color,
      Value<String?> fotoCajaId,
      Value<String?> fotoPastillaId,
      Value<String?> registroCima,
      Value<int> creadoEn,
      Value<int?> retiradoEn,
      Value<int> rowid,
    });

final class $$MedicamentosTableReferences
    extends BaseReferences<_$AppDatabase, $MedicamentosTable, Medicamento> {
  $$MedicamentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonasTable _personaIdTable(_$AppDatabase db) =>
      db.personas.createAlias('medicamentos__persona_id__personas__id');

  $$PersonasTableProcessedTableManager get personaId {
    final $_column = $_itemColumn<String>('persona_id')!;

    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FotosTable _fotoCajaIdTable(_$AppDatabase db) =>
      db.fotos.createAlias('medicamentos__foto_caja_id__fotos__id');

  $$FotosTableProcessedTableManager? get fotoCajaId {
    final $_column = $_itemColumn<String>('foto_caja_id');
    if ($_column == null) return null;
    final manager = $$FotosTableTableManager(
      $_db,
      $_db.fotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fotoCajaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FotosTable _fotoPastillaIdTable(_$AppDatabase db) =>
      db.fotos.createAlias('medicamentos__foto_pastilla_id__fotos__id');

  $$FotosTableProcessedTableManager? get fotoPastillaId {
    final $_column = $_itemColumn<String>('foto_pastilla_id');
    if ($_column == null) return null;
    final manager = $$FotosTableTableManager(
      $_db,
      $_db.fotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fotoPastillaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PautasTable, List<Pauta>> _pautasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pautas,
    aliasName: 'medicamentos__id__pautas__medicamento_id',
  );

  $$PautasTableProcessedTableManager get pautasRefs {
    final manager = $$PautasTableTableManager(
      $_db,
      $_db.pautas,
    ).filter((f) => f.medicamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pautasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicamentosTableFilterComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreParaPersona => $composableBuilder(
    column: $table.nombreParaPersona,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forma => $composableBuilder(
    column: $table.forma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registroCima => $composableBuilder(
    column: $table.registroCima,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retiradoEn => $composableBuilder(
    column: $table.retiradoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonasTableFilterComposer get personaId {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableFilterComposer get fotoCajaId {
    final $$FotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoCajaId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableFilterComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableFilterComposer get fotoPastillaId {
    final $$FotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoPastillaId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableFilterComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pautasRefs(
    Expression<bool> Function($$PautasTableFilterComposer f) f,
  ) {
    final $$PautasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableFilterComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreParaPersona => $composableBuilder(
    column: $table.nombreParaPersona,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forma => $composableBuilder(
    column: $table.forma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registroCima => $composableBuilder(
    column: $table.registroCima,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retiradoEn => $composableBuilder(
    column: $table.retiradoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonasTableOrderingComposer get personaId {
    final $$PersonasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableOrderingComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableOrderingComposer get fotoCajaId {
    final $$FotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoCajaId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableOrderingComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableOrderingComposer get fotoPastillaId {
    final $$FotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoPastillaId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableOrderingComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get nombreParaPersona => $composableBuilder(
    column: $table.nombreParaPersona,
    builder: (column) => column,
  );

  GeneratedColumn<String> get forma =>
      $composableBuilder(column: $table.forma, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get registroCima => $composableBuilder(
    column: $table.registroCima,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get retiradoEn => $composableBuilder(
    column: $table.retiradoEn,
    builder: (column) => column,
  );

  $$PersonasTableAnnotationComposer get personaId {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableAnnotationComposer get fotoCajaId {
    final $$FotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoCajaId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableAnnotationComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableAnnotationComposer get fotoPastillaId {
    final $$FotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoPastillaId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableAnnotationComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pautasRefs<T extends Object>(
    Expression<T> Function($$PautasTableAnnotationComposer a) f,
  ) {
    final $$PautasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableAnnotationComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicamentosTable,
          Medicamento,
          $$MedicamentosTableFilterComposer,
          $$MedicamentosTableOrderingComposer,
          $$MedicamentosTableAnnotationComposer,
          $$MedicamentosTableCreateCompanionBuilder,
          $$MedicamentosTableUpdateCompanionBuilder,
          (Medicamento, $$MedicamentosTableReferences),
          Medicamento,
          PrefetchHooks Function({
            bool personaId,
            bool fotoCajaId,
            bool fotoPastillaId,
            bool pautasRefs,
          })
        > {
  $$MedicamentosTableTableManager(_$AppDatabase db, $MedicamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> nombreParaPersona = const Value.absent(),
                Value<String> forma = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> fotoCajaId = const Value.absent(),
                Value<String?> fotoPastillaId = const Value.absent(),
                Value<String?> registroCima = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int?> retiradoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicamentosCompanion(
                id: id,
                personaId: personaId,
                nombre: nombre,
                nombreParaPersona: nombreParaPersona,
                forma: forma,
                color: color,
                fotoCajaId: fotoCajaId,
                fotoPastillaId: fotoPastillaId,
                registroCima: registroCima,
                creadoEn: creadoEn,
                retiradoEn: retiradoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personaId,
                required String nombre,
                required String nombreParaPersona,
                required String forma,
                Value<String?> color = const Value.absent(),
                Value<String?> fotoCajaId = const Value.absent(),
                Value<String?> fotoPastillaId = const Value.absent(),
                Value<String?> registroCima = const Value.absent(),
                required int creadoEn,
                Value<int?> retiradoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicamentosCompanion.insert(
                id: id,
                personaId: personaId,
                nombre: nombre,
                nombreParaPersona: nombreParaPersona,
                forma: forma,
                color: color,
                fotoCajaId: fotoCajaId,
                fotoPastillaId: fotoPastillaId,
                registroCima: registroCima,
                creadoEn: creadoEn,
                retiradoEn: retiradoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicamentosTable, Medicamento>(table),
                  $$MedicamentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personaId = false,
                fotoCajaId = false,
                fotoPastillaId = false,
                pautasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (pautasRefs) db.pautas],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (personaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personaId,
                            referencedTable: $$MedicamentosTableReferences
                                ._personaIdTable(db),
                            referencedColumn: $$MedicamentosTableReferences
                                ._personaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (fotoCajaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fotoCajaId,
                            referencedTable: $$MedicamentosTableReferences
                                ._fotoCajaIdTable(db),
                            referencedColumn: $$MedicamentosTableReferences
                                ._fotoCajaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (fotoPastillaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fotoPastillaId,
                            referencedTable: $$MedicamentosTableReferences
                                ._fotoPastillaIdTable(db),
                            referencedColumn: $$MedicamentosTableReferences
                                ._fotoPastillaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pautasRefs)
                        await $_getPrefetchedData<
                          Medicamento,
                          $MedicamentosTable,
                          Pauta
                        >(
                          currentTable: table,
                          referencedTable: $$MedicamentosTableReferences
                              ._pautasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).pautasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicamentosTable,
      Medicamento,
      $$MedicamentosTableFilterComposer,
      $$MedicamentosTableOrderingComposer,
      $$MedicamentosTableAnnotationComposer,
      $$MedicamentosTableCreateCompanionBuilder,
      $$MedicamentosTableUpdateCompanionBuilder,
      (Medicamento, $$MedicamentosTableReferences),
      Medicamento,
      PrefetchHooks Function({
        bool personaId,
        bool fotoCajaId,
        bool fotoPastillaId,
        bool pautasRefs,
      })
    >;
typedef $$ConsentimientosTableCreateCompanionBuilder =
    ConsentimientosCompanion Function({
      required String id,
      required String circuloId,
      required String otorgante,
      Value<String?> enNombreDe,
      required String sobre,
      required String textoMostrado,
      Value<String?> documentoFotoId,
      required int otorgadoEn,
      Value<String?> revocaA,
      Value<int> rowid,
    });
typedef $$ConsentimientosTableUpdateCompanionBuilder =
    ConsentimientosCompanion Function({
      Value<String> id,
      Value<String> circuloId,
      Value<String> otorgante,
      Value<String?> enNombreDe,
      Value<String> sobre,
      Value<String> textoMostrado,
      Value<String?> documentoFotoId,
      Value<int> otorgadoEn,
      Value<String?> revocaA,
      Value<int> rowid,
    });

final class $$ConsentimientosTableReferences
    extends
        BaseReferences<_$AppDatabase, $ConsentimientosTable, Consentimiento> {
  $$ConsentimientosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CirculosTable _circuloIdTable(_$AppDatabase db) =>
      db.circulos.createAlias('consentimientos__circulo_id__circulos__id');

  $$CirculosTableProcessedTableManager get circuloId {
    final $_column = $_itemColumn<String>('circulo_id')!;

    final manager = $$CirculosTableTableManager(
      $_db,
      $_db.circulos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circuloIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FotosTable _documentoFotoIdTable(_$AppDatabase db) =>
      db.fotos.createAlias('consentimientos__documento_foto_id__fotos__id');

  $$FotosTableProcessedTableManager? get documentoFotoId {
    final $_column = $_itemColumn<String>('documento_foto_id');
    if ($_column == null) return null;
    final manager = $$FotosTableTableManager(
      $_db,
      $_db.fotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentoFotoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VocesTable, List<Voz>> _vocesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.voces,
    aliasName: 'consentimientos__id__voces__consentimiento_id',
  );

  $$VocesTableProcessedTableManager get vocesRefs {
    final manager = $$VocesTableTableManager($_db, $_db.voces).filter(
      (f) => f.consentimientoId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_vocesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConsentimientosTableFilterComposer
    extends Composer<_$AppDatabase, $ConsentimientosTable> {
  $$ConsentimientosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otorgante => $composableBuilder(
    column: $table.otorgante,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enNombreDe => $composableBuilder(
    column: $table.enNombreDe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sobre => $composableBuilder(
    column: $table.sobre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textoMostrado => $composableBuilder(
    column: $table.textoMostrado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get otorgadoEn => $composableBuilder(
    column: $table.otorgadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revocaA => $composableBuilder(
    column: $table.revocaA,
    builder: (column) => ColumnFilters(column),
  );

  $$CirculosTableFilterComposer get circuloId {
    final $$CirculosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableFilterComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableFilterComposer get documentoFotoId {
    final $$FotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoFotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableFilterComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> vocesRefs(
    Expression<bool> Function($$VocesTableFilterComposer f) f,
  ) {
    final $$VocesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.consentimientoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableFilterComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConsentimientosTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsentimientosTable> {
  $$ConsentimientosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otorgante => $composableBuilder(
    column: $table.otorgante,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enNombreDe => $composableBuilder(
    column: $table.enNombreDe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sobre => $composableBuilder(
    column: $table.sobre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textoMostrado => $composableBuilder(
    column: $table.textoMostrado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get otorgadoEn => $composableBuilder(
    column: $table.otorgadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revocaA => $composableBuilder(
    column: $table.revocaA,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirculosTableOrderingComposer get circuloId {
    final $$CirculosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableOrderingComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableOrderingComposer get documentoFotoId {
    final $$FotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoFotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableOrderingComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConsentimientosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsentimientosTable> {
  $$ConsentimientosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get otorgante =>
      $composableBuilder(column: $table.otorgante, builder: (column) => column);

  GeneratedColumn<String> get enNombreDe => $composableBuilder(
    column: $table.enNombreDe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sobre =>
      $composableBuilder(column: $table.sobre, builder: (column) => column);

  GeneratedColumn<String> get textoMostrado => $composableBuilder(
    column: $table.textoMostrado,
    builder: (column) => column,
  );

  GeneratedColumn<int> get otorgadoEn => $composableBuilder(
    column: $table.otorgadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revocaA =>
      $composableBuilder(column: $table.revocaA, builder: (column) => column);

  $$CirculosTableAnnotationComposer get circuloId {
    final $$CirculosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableAnnotationComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableAnnotationComposer get documentoFotoId {
    final $$FotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoFotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableAnnotationComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> vocesRefs<T extends Object>(
    Expression<T> Function($$VocesTableAnnotationComposer a) f,
  ) {
    final $$VocesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.consentimientoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableAnnotationComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConsentimientosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsentimientosTable,
          Consentimiento,
          $$ConsentimientosTableFilterComposer,
          $$ConsentimientosTableOrderingComposer,
          $$ConsentimientosTableAnnotationComposer,
          $$ConsentimientosTableCreateCompanionBuilder,
          $$ConsentimientosTableUpdateCompanionBuilder,
          (Consentimiento, $$ConsentimientosTableReferences),
          Consentimiento,
          PrefetchHooks Function({
            bool circuloId,
            bool documentoFotoId,
            bool vocesRefs,
          })
        > {
  $$ConsentimientosTableTableManager(
    _$AppDatabase db,
    $ConsentimientosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsentimientosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsentimientosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsentimientosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> circuloId = const Value.absent(),
                Value<String> otorgante = const Value.absent(),
                Value<String?> enNombreDe = const Value.absent(),
                Value<String> sobre = const Value.absent(),
                Value<String> textoMostrado = const Value.absent(),
                Value<String?> documentoFotoId = const Value.absent(),
                Value<int> otorgadoEn = const Value.absent(),
                Value<String?> revocaA = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsentimientosCompanion(
                id: id,
                circuloId: circuloId,
                otorgante: otorgante,
                enNombreDe: enNombreDe,
                sobre: sobre,
                textoMostrado: textoMostrado,
                documentoFotoId: documentoFotoId,
                otorgadoEn: otorgadoEn,
                revocaA: revocaA,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String circuloId,
                required String otorgante,
                Value<String?> enNombreDe = const Value.absent(),
                required String sobre,
                required String textoMostrado,
                Value<String?> documentoFotoId = const Value.absent(),
                required int otorgadoEn,
                Value<String?> revocaA = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsentimientosCompanion.insert(
                id: id,
                circuloId: circuloId,
                otorgante: otorgante,
                enNombreDe: enNombreDe,
                sobre: sobre,
                textoMostrado: textoMostrado,
                documentoFotoId: documentoFotoId,
                otorgadoEn: otorgadoEn,
                revocaA: revocaA,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConsentimientosTable, Consentimiento>(table),
                  $$ConsentimientosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                circuloId = false,
                documentoFotoId = false,
                vocesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (vocesRefs) db.voces],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (circuloId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.circuloId,
                            referencedTable: $$ConsentimientosTableReferences
                                ._circuloIdTable(db),
                            referencedColumn: $$ConsentimientosTableReferences
                                ._circuloIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (documentoFotoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentoFotoId,
                            referencedTable: $$ConsentimientosTableReferences
                                ._documentoFotoIdTable(db),
                            referencedColumn: $$ConsentimientosTableReferences
                                ._documentoFotoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vocesRefs)
                        await $_getPrefetchedData<
                          Consentimiento,
                          $ConsentimientosTable,
                          Voz
                        >(
                          currentTable: table,
                          referencedTable: $$ConsentimientosTableReferences
                              ._vocesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsentimientosTableReferences(
                                db,
                                table,
                                p0,
                              ).vocesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.consentimientoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConsentimientosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsentimientosTable,
      Consentimiento,
      $$ConsentimientosTableFilterComposer,
      $$ConsentimientosTableOrderingComposer,
      $$ConsentimientosTableAnnotationComposer,
      $$ConsentimientosTableCreateCompanionBuilder,
      $$ConsentimientosTableUpdateCompanionBuilder,
      (Consentimiento, $$ConsentimientosTableReferences),
      Consentimiento,
      PrefetchHooks Function({
        bool circuloId,
        bool documentoFotoId,
        bool vocesRefs,
      })
    >;
typedef $$VocesTableCreateCompanionBuilder = VocesCompanion Function({
  required String id,
  required String miembroId,
  required String tipo,
  Value<String?> modelo,
  Value<String?> consentimientoId,
  required int creadaEn,
  Value<int?> retiradaEn,
  Value<int> rowid,
});
typedef $$VocesTableUpdateCompanionBuilder = VocesCompanion Function({
  Value<String> id,
  Value<String> miembroId,
  Value<String> tipo,
  Value<String?> modelo,
  Value<String?> consentimientoId,
  Value<int> creadaEn,
  Value<int?> retiradaEn,
  Value<int> rowid,
});

final class $$VocesTableReferences
    extends BaseReferences<_$AppDatabase, $VocesTable, Voz> {
  $$VocesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MiembrosTable _miembroIdTable(_$AppDatabase db) =>
      db.miembros.createAlias('voces__miembro_id__miembros__id');

  $$MiembrosTableProcessedTableManager get miembroId {
    final $_column = $_itemColumn<String>('miembro_id')!;

    final manager = $$MiembrosTableTableManager(
      $_db,
      $_db.miembros,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_miembroIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConsentimientosTable _consentimientoIdTable(_$AppDatabase db) => db
      .consentimientos
      .createAlias('voces__consentimiento_id__consentimientos__id');

  $$ConsentimientosTableProcessedTableManager? get consentimientoId {
    final $_column = $_itemColumn<String>('consentimiento_id');
    if ($_column == null) return null;
    final manager = $$ConsentimientosTableTableManager(
      $_db,
      $_db.consentimientos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consentimientoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FrasesTable, List<Frase>> _frasesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.frases,
    aliasName: 'voces__id__frases__voz_id',
  );

  $$FrasesTableProcessedTableManager get frasesRefs {
    final manager = $$FrasesTableTableManager(
      $_db,
      $_db.frases,
    ).filter((f) => f.vozId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_frasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PautasTable, List<Pauta>> _pautasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pautas,
    aliasName: 'voces__id__pautas__voz_id',
  );

  $$PautasTableProcessedTableManager get pautasRefs {
    final manager = $$PautasTableTableManager(
      $_db,
      $_db.pautas,
    ).filter((f) => f.vozId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pautasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VocesTableFilterComposer extends Composer<_$AppDatabase, $VocesTable> {
  $$VocesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retiradaEn => $composableBuilder(
    column: $table.retiradaEn,
    builder: (column) => ColumnFilters(column),
  );

  $$MiembrosTableFilterComposer get miembroId {
    final $$MiembrosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.miembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableFilterComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsentimientosTableFilterComposer get consentimientoId {
    final $$ConsentimientosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consentimientoId,
      referencedTable: $db.consentimientos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentimientosTableFilterComposer(
            $db: $db,
            $table: $db.consentimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> frasesRefs(
    Expression<bool> Function($$FrasesTableFilterComposer f) f,
  ) {
    final $$FrasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.frases,
      getReferencedColumn: (t) => t.vozId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FrasesTableFilterComposer(
            $db: $db,
            $table: $db.frases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pautasRefs(
    Expression<bool> Function($$PautasTableFilterComposer f) f,
  ) {
    final $$PautasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.vozId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableFilterComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocesTableOrderingComposer
    extends Composer<_$AppDatabase, $VocesTable> {
  $$VocesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retiradaEn => $composableBuilder(
    column: $table.retiradaEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$MiembrosTableOrderingComposer get miembroId {
    final $$MiembrosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.miembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableOrderingComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsentimientosTableOrderingComposer get consentimientoId {
    final $$ConsentimientosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consentimientoId,
      referencedTable: $db.consentimientos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentimientosTableOrderingComposer(
            $db: $db,
            $table: $db.consentimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VocesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocesTable> {
  $$VocesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get modelo =>
      $composableBuilder(column: $table.modelo, builder: (column) => column);

  GeneratedColumn<int> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  GeneratedColumn<int> get retiradaEn => $composableBuilder(
    column: $table.retiradaEn,
    builder: (column) => column,
  );

  $$MiembrosTableAnnotationComposer get miembroId {
    final $$MiembrosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.miembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableAnnotationComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsentimientosTableAnnotationComposer get consentimientoId {
    final $$ConsentimientosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consentimientoId,
      referencedTable: $db.consentimientos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsentimientosTableAnnotationComposer(
            $db: $db,
            $table: $db.consentimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> frasesRefs<T extends Object>(
    Expression<T> Function($$FrasesTableAnnotationComposer a) f,
  ) {
    final $$FrasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.frases,
      getReferencedColumn: (t) => t.vozId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FrasesTableAnnotationComposer(
            $db: $db,
            $table: $db.frases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pautasRefs<T extends Object>(
    Expression<T> Function($$PautasTableAnnotationComposer a) f,
  ) {
    final $$PautasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.vozId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableAnnotationComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocesTable,
          Voz,
          $$VocesTableFilterComposer,
          $$VocesTableOrderingComposer,
          $$VocesTableAnnotationComposer,
          $$VocesTableCreateCompanionBuilder,
          $$VocesTableUpdateCompanionBuilder,
          (Voz, $$VocesTableReferences),
          Voz,
          PrefetchHooks Function({
            bool miembroId,
            bool consentimientoId,
            bool frasesRefs,
            bool pautasRefs,
          })
        > {
  $$VocesTableTableManager(_$AppDatabase db, $VocesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> miembroId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> modelo = const Value.absent(),
                Value<String?> consentimientoId = const Value.absent(),
                Value<int> creadaEn = const Value.absent(),
                Value<int?> retiradaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocesCompanion(
                id: id,
                miembroId: miembroId,
                tipo: tipo,
                modelo: modelo,
                consentimientoId: consentimientoId,
                creadaEn: creadaEn,
                retiradaEn: retiradaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String miembroId,
                required String tipo,
                Value<String?> modelo = const Value.absent(),
                Value<String?> consentimientoId = const Value.absent(),
                required int creadaEn,
                Value<int?> retiradaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocesCompanion.insert(
                id: id,
                miembroId: miembroId,
                tipo: tipo,
                modelo: modelo,
                consentimientoId: consentimientoId,
                creadaEn: creadaEn,
                retiradaEn: retiradaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VocesTable, Voz>(table),
                  $$VocesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                miembroId = false,
                consentimientoId = false,
                frasesRefs = false,
                pautasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (frasesRefs) db.frases,
                    if (pautasRefs) db.pautas,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (miembroId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.miembroId,
                            referencedTable: $$VocesTableReferences
                                ._miembroIdTable(db),
                            referencedColumn: $$VocesTableReferences
                                ._miembroIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (consentimientoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.consentimientoId,
                            referencedTable: $$VocesTableReferences
                                ._consentimientoIdTable(db),
                            referencedColumn: $$VocesTableReferences
                                ._consentimientoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (frasesRefs)
                        await $_getPrefetchedData<Voz, $VocesTable, Frase>(
                          currentTable: table,
                          referencedTable: $$VocesTableReferences
                              ._frasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocesTableReferences(db, table, p0).frasesRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.vozId == item.id),
                          typedResults: items,
                        ),
                      if (pautasRefs)
                        await $_getPrefetchedData<Voz, $VocesTable, Pauta>(
                          currentTable: table,
                          referencedTable: $$VocesTableReferences
                              ._pautasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocesTableReferences(db, table, p0).pautasRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.vozId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VocesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocesTable,
      Voz,
      $$VocesTableFilterComposer,
      $$VocesTableOrderingComposer,
      $$VocesTableAnnotationComposer,
      $$VocesTableCreateCompanionBuilder,
      $$VocesTableUpdateCompanionBuilder,
      (Voz, $$VocesTableReferences),
      Voz,
      PrefetchHooks Function({
        bool miembroId,
        bool consentimientoId,
        bool frasesRefs,
        bool pautasRefs,
      })
    >;
typedef $$FrasesTableCreateCompanionBuilder = FrasesCompanion Function({
  required String id,
  required String vozId,
  required String texto,
  required String uso,
  Value<String?> audioRuta,
  required bool aprobada,
  required int creadaEn,
  Value<int> rowid,
});
typedef $$FrasesTableUpdateCompanionBuilder = FrasesCompanion Function({
  Value<String> id,
  Value<String> vozId,
  Value<String> texto,
  Value<String> uso,
  Value<String?> audioRuta,
  Value<bool> aprobada,
  Value<int> creadaEn,
  Value<int> rowid,
});

final class $$FrasesTableReferences
    extends BaseReferences<_$AppDatabase, $FrasesTable, Frase> {
  $$FrasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocesTable _vozIdTable(_$AppDatabase db) =>
      db.voces.createAlias('frases__voz_id__voces__id');

  $$VocesTableProcessedTableManager get vozId {
    final $_column = $_itemColumn<String>('voz_id')!;

    final manager = $$VocesTableTableManager(
      $_db,
      $_db.voces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vozIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PreguntasControlTable, List<PreguntaControl>>
  _preguntasControlRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.preguntasControl,
    aliasName: 'frases__id__preguntas_control__frase_id',
  );

  $$PreguntasControlTableProcessedTableManager get preguntasControlRefs {
    final manager = $$PreguntasControlTableTableManager(
      $_db,
      $_db.preguntasControl,
    ).filter((f) => f.fraseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preguntasControlRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FrasesTableFilterComposer
    extends Composer<_$AppDatabase, $FrasesTable> {
  $$FrasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uso => $composableBuilder(
    column: $table.uso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioRuta => $composableBuilder(
    column: $table.audioRuta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aprobada => $composableBuilder(
    column: $table.aprobada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnFilters(column),
  );

  $$VocesTableFilterComposer get vozId {
    final $$VocesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vozId,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableFilterComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> preguntasControlRefs(
    Expression<bool> Function($$PreguntasControlTableFilterComposer f) f,
  ) {
    final $$PreguntasControlTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntasControl,
      getReferencedColumn: (t) => t.fraseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasControlTableFilterComposer(
            $db: $db,
            $table: $db.preguntasControl,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FrasesTableOrderingComposer
    extends Composer<_$AppDatabase, $FrasesTable> {
  $$FrasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uso => $composableBuilder(
    column: $table.uso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioRuta => $composableBuilder(
    column: $table.audioRuta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aprobada => $composableBuilder(
    column: $table.aprobada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocesTableOrderingComposer get vozId {
    final $$VocesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vozId,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableOrderingComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FrasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FrasesTable> {
  $$FrasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<String> get uso =>
      $composableBuilder(column: $table.uso, builder: (column) => column);

  GeneratedColumn<String> get audioRuta =>
      $composableBuilder(column: $table.audioRuta, builder: (column) => column);

  GeneratedColumn<bool> get aprobada =>
      $composableBuilder(column: $table.aprobada, builder: (column) => column);

  GeneratedColumn<int> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  $$VocesTableAnnotationComposer get vozId {
    final $$VocesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vozId,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableAnnotationComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> preguntasControlRefs<T extends Object>(
    Expression<T> Function($$PreguntasControlTableAnnotationComposer a) f,
  ) {
    final $$PreguntasControlTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntasControl,
      getReferencedColumn: (t) => t.fraseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasControlTableAnnotationComposer(
            $db: $db,
            $table: $db.preguntasControl,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FrasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FrasesTable,
          Frase,
          $$FrasesTableFilterComposer,
          $$FrasesTableOrderingComposer,
          $$FrasesTableAnnotationComposer,
          $$FrasesTableCreateCompanionBuilder,
          $$FrasesTableUpdateCompanionBuilder,
          (Frase, $$FrasesTableReferences),
          Frase,
          PrefetchHooks Function({bool vozId, bool preguntasControlRefs})
        > {
  $$FrasesTableTableManager(_$AppDatabase db, $FrasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FrasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FrasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FrasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vozId = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<String> uso = const Value.absent(),
                Value<String?> audioRuta = const Value.absent(),
                Value<bool> aprobada = const Value.absent(),
                Value<int> creadaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FrasesCompanion(
                id: id,
                vozId: vozId,
                texto: texto,
                uso: uso,
                audioRuta: audioRuta,
                aprobada: aprobada,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vozId,
                required String texto,
                required String uso,
                Value<String?> audioRuta = const Value.absent(),
                required bool aprobada,
                required int creadaEn,
                Value<int> rowid = const Value.absent(),
              }) => FrasesCompanion.insert(
                id: id,
                vozId: vozId,
                texto: texto,
                uso: uso,
                audioRuta: audioRuta,
                aprobada: aprobada,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FrasesTable, Frase>(table),
                  $$FrasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vozId = false, preguntasControlRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (preguntasControlRefs) db.preguntasControl,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vozId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vozId,
                            referencedTable: $$FrasesTableReferences
                                ._vozIdTable(db),
                            referencedColumn: $$FrasesTableReferences
                                ._vozIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (preguntasControlRefs)
                        await $_getPrefetchedData<
                          Frase,
                          $FrasesTable,
                          PreguntaControl
                        >(
                          currentTable: table,
                          referencedTable: $$FrasesTableReferences
                              ._preguntasControlRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FrasesTableReferences(
                                db,
                                table,
                                p0,
                              ).preguntasControlRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fraseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FrasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FrasesTable,
      Frase,
      $$FrasesTableFilterComposer,
      $$FrasesTableOrderingComposer,
      $$FrasesTableAnnotationComposer,
      $$FrasesTableCreateCompanionBuilder,
      $$FrasesTableUpdateCompanionBuilder,
      (Frase, $$FrasesTableReferences),
      Frase,
      PrefetchHooks Function({bool vozId, bool preguntasControlRefs})
    >;
typedef $$PautasTableCreateCompanionBuilder = PautasCompanion Function({
  required String id,
  required String pautaId,
  required int version,
  required String medicamentoId,
  required String personaId,
  required String dosis,
  required String horas,
  Value<int> diasSemana,
  Value<String?> compartimento,
  Value<String?> vozId,
  Value<String> comprobacion,
  Value<int> segundosVideo,
  required String zonaHoraria,
  required int vigenteDesde,
  required bool activa,
  Value<String?> motivo,
  required String creadaPor,
  required int creadaEn,
  Value<int> rowid,
});
typedef $$PautasTableUpdateCompanionBuilder = PautasCompanion Function({
  Value<String> id,
  Value<String> pautaId,
  Value<int> version,
  Value<String> medicamentoId,
  Value<String> personaId,
  Value<String> dosis,
  Value<String> horas,
  Value<int> diasSemana,
  Value<String?> compartimento,
  Value<String?> vozId,
  Value<String> comprobacion,
  Value<int> segundosVideo,
  Value<String> zonaHoraria,
  Value<int> vigenteDesde,
  Value<bool> activa,
  Value<String?> motivo,
  Value<String> creadaPor,
  Value<int> creadaEn,
  Value<int> rowid,
});

final class $$PautasTableReferences
    extends BaseReferences<_$AppDatabase, $PautasTable, Pauta> {
  $$PautasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicamentosTable _medicamentoIdTable(_$AppDatabase db) =>
      db.medicamentos.createAlias('pautas__medicamento_id__medicamentos__id');

  $$MedicamentosTableProcessedTableManager get medicamentoId {
    final $_column = $_itemColumn<String>('medicamento_id')!;

    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonasTable _personaIdTable(_$AppDatabase db) =>
      db.personas.createAlias('pautas__persona_id__personas__id');

  $$PersonasTableProcessedTableManager get personaId {
    final $_column = $_itemColumn<String>('persona_id')!;

    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VocesTable _vozIdTable(_$AppDatabase db) =>
      db.voces.createAlias('pautas__voz_id__voces__id');

  $$VocesTableProcessedTableManager? get vozId {
    final $_column = $_itemColumn<String>('voz_id');
    if ($_column == null) return null;
    final manager = $$VocesTableTableManager(
      $_db,
      $_db.voces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vozIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TomasTable, List<Toma>> _tomasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tomas,
    aliasName: 'pautas__id__tomas__pauta_version_id',
  );

  $$TomasTableProcessedTableManager get tomasRefs {
    final manager = $$TomasTableTableManager(
      $_db,
      $_db.tomas,
    ).filter((f) => f.pautaVersionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tomasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PautasTableFilterComposer
    extends Composer<_$AppDatabase, $PautasTable> {
  $$PautasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pautaId => $composableBuilder(
    column: $table.pautaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosis => $composableBuilder(
    column: $table.dosis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horas => $composableBuilder(
    column: $table.horas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compartimento => $composableBuilder(
    column: $table.compartimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comprobacion => $composableBuilder(
    column: $table.comprobacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segundosVideo => $composableBuilder(
    column: $table.segundosVideo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zonaHoraria => $composableBuilder(
    column: $table.zonaHoraria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vigenteDesde => $composableBuilder(
    column: $table.vigenteDesde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activa => $composableBuilder(
    column: $table.activa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creadaPor => $composableBuilder(
    column: $table.creadaPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicamentosTableFilterComposer get medicamentoId {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonasTableFilterComposer get personaId {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocesTableFilterComposer get vozId {
    final $$VocesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vozId,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableFilterComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tomasRefs(
    Expression<bool> Function($$TomasTableFilterComposer f) f,
  ) {
    final $$TomasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tomas,
      getReferencedColumn: (t) => t.pautaVersionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TomasTableFilterComposer(
            $db: $db,
            $table: $db.tomas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PautasTableOrderingComposer
    extends Composer<_$AppDatabase, $PautasTable> {
  $$PautasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pautaId => $composableBuilder(
    column: $table.pautaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosis => $composableBuilder(
    column: $table.dosis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horas => $composableBuilder(
    column: $table.horas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compartimento => $composableBuilder(
    column: $table.compartimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comprobacion => $composableBuilder(
    column: $table.comprobacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segundosVideo => $composableBuilder(
    column: $table.segundosVideo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zonaHoraria => $composableBuilder(
    column: $table.zonaHoraria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vigenteDesde => $composableBuilder(
    column: $table.vigenteDesde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activa => $composableBuilder(
    column: $table.activa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creadaPor => $composableBuilder(
    column: $table.creadaPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicamentosTableOrderingComposer get medicamentoId {
    final $$MedicamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableOrderingComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonasTableOrderingComposer get personaId {
    final $$PersonasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableOrderingComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocesTableOrderingComposer get vozId {
    final $$VocesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vozId,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableOrderingComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PautasTableAnnotationComposer
    extends Composer<_$AppDatabase, $PautasTable> {
  $$PautasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pautaId =>
      $composableBuilder(column: $table.pautaId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get dosis =>
      $composableBuilder(column: $table.dosis, builder: (column) => column);

  GeneratedColumn<String> get horas =>
      $composableBuilder(column: $table.horas, builder: (column) => column);

  GeneratedColumn<int> get diasSemana => $composableBuilder(
    column: $table.diasSemana,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compartimento => $composableBuilder(
    column: $table.compartimento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comprobacion => $composableBuilder(
    column: $table.comprobacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get segundosVideo => $composableBuilder(
    column: $table.segundosVideo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zonaHoraria => $composableBuilder(
    column: $table.zonaHoraria,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vigenteDesde => $composableBuilder(
    column: $table.vigenteDesde,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activa =>
      $composableBuilder(column: $table.activa, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<String> get creadaPor =>
      $composableBuilder(column: $table.creadaPor, builder: (column) => column);

  GeneratedColumn<int> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  $$MedicamentosTableAnnotationComposer get medicamentoId {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonasTableAnnotationComposer get personaId {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocesTableAnnotationComposer get vozId {
    final $$VocesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vozId,
      referencedTable: $db.voces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocesTableAnnotationComposer(
            $db: $db,
            $table: $db.voces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tomasRefs<T extends Object>(
    Expression<T> Function($$TomasTableAnnotationComposer a) f,
  ) {
    final $$TomasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tomas,
      getReferencedColumn: (t) => t.pautaVersionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TomasTableAnnotationComposer(
            $db: $db,
            $table: $db.tomas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PautasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PautasTable,
          Pauta,
          $$PautasTableFilterComposer,
          $$PautasTableOrderingComposer,
          $$PautasTableAnnotationComposer,
          $$PautasTableCreateCompanionBuilder,
          $$PautasTableUpdateCompanionBuilder,
          (Pauta, $$PautasTableReferences),
          Pauta,
          PrefetchHooks Function({
            bool medicamentoId,
            bool personaId,
            bool vozId,
            bool tomasRefs,
          })
        > {
  $$PautasTableTableManager(_$AppDatabase db, $PautasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PautasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PautasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PautasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pautaId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> medicamentoId = const Value.absent(),
                Value<String> personaId = const Value.absent(),
                Value<String> dosis = const Value.absent(),
                Value<String> horas = const Value.absent(),
                Value<int> diasSemana = const Value.absent(),
                Value<String?> compartimento = const Value.absent(),
                Value<String?> vozId = const Value.absent(),
                Value<String> comprobacion = const Value.absent(),
                Value<int> segundosVideo = const Value.absent(),
                Value<String> zonaHoraria = const Value.absent(),
                Value<int> vigenteDesde = const Value.absent(),
                Value<bool> activa = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<String> creadaPor = const Value.absent(),
                Value<int> creadaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PautasCompanion(
                id: id,
                pautaId: pautaId,
                version: version,
                medicamentoId: medicamentoId,
                personaId: personaId,
                dosis: dosis,
                horas: horas,
                diasSemana: diasSemana,
                compartimento: compartimento,
                vozId: vozId,
                comprobacion: comprobacion,
                segundosVideo: segundosVideo,
                zonaHoraria: zonaHoraria,
                vigenteDesde: vigenteDesde,
                activa: activa,
                motivo: motivo,
                creadaPor: creadaPor,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pautaId,
                required int version,
                required String medicamentoId,
                required String personaId,
                required String dosis,
                required String horas,
                Value<int> diasSemana = const Value.absent(),
                Value<String?> compartimento = const Value.absent(),
                Value<String?> vozId = const Value.absent(),
                Value<String> comprobacion = const Value.absent(),
                Value<int> segundosVideo = const Value.absent(),
                required String zonaHoraria,
                required int vigenteDesde,
                required bool activa,
                Value<String?> motivo = const Value.absent(),
                required String creadaPor,
                required int creadaEn,
                Value<int> rowid = const Value.absent(),
              }) => PautasCompanion.insert(
                id: id,
                pautaId: pautaId,
                version: version,
                medicamentoId: medicamentoId,
                personaId: personaId,
                dosis: dosis,
                horas: horas,
                diasSemana: diasSemana,
                compartimento: compartimento,
                vozId: vozId,
                comprobacion: comprobacion,
                segundosVideo: segundosVideo,
                zonaHoraria: zonaHoraria,
                vigenteDesde: vigenteDesde,
                activa: activa,
                motivo: motivo,
                creadaPor: creadaPor,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PautasTable, Pauta>(table),
                  $$PautasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicamentoId = false,
                personaId = false,
                vozId = false,
                tomasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (tomasRefs) db.tomas],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (medicamentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.medicamentoId,
                            referencedTable: $$PautasTableReferences
                                ._medicamentoIdTable(db),
                            referencedColumn: $$PautasTableReferences
                                ._medicamentoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (personaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personaId,
                            referencedTable: $$PautasTableReferences
                                ._personaIdTable(db),
                            referencedColumn: $$PautasTableReferences
                                ._personaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (vozId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vozId,
                            referencedTable: $$PautasTableReferences
                                ._vozIdTable(db),
                            referencedColumn: $$PautasTableReferences
                                ._vozIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tomasRefs)
                        await $_getPrefetchedData<Pauta, $PautasTable, Toma>(
                          currentTable: table,
                          referencedTable: $$PautasTableReferences
                              ._tomasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PautasTableReferences(db, table, p0).tomasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pautaVersionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PautasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PautasTable,
      Pauta,
      $$PautasTableFilterComposer,
      $$PautasTableOrderingComposer,
      $$PautasTableAnnotationComposer,
      $$PautasTableCreateCompanionBuilder,
      $$PautasTableUpdateCompanionBuilder,
      (Pauta, $$PautasTableReferences),
      Pauta,
      PrefetchHooks Function({
        bool medicamentoId,
        bool personaId,
        bool vozId,
        bool tomasRefs,
      })
    >;
typedef $$TomasTableCreateCompanionBuilder = TomasCompanion Function({
  required String id,
  required String pautaVersionId,
  required String personaId,
  required int previstaPara,
  required String fechaLocal,
  required String horaLocal,
  required int creadaEn,
  Value<int> rowid,
});
typedef $$TomasTableUpdateCompanionBuilder = TomasCompanion Function({
  Value<String> id,
  Value<String> pautaVersionId,
  Value<String> personaId,
  Value<int> previstaPara,
  Value<String> fechaLocal,
  Value<String> horaLocal,
  Value<int> creadaEn,
  Value<int> rowid,
});

final class $$TomasTableReferences
    extends BaseReferences<_$AppDatabase, $TomasTable, Toma> {
  $$TomasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PautasTable _pautaVersionIdTable(_$AppDatabase db) =>
      db.pautas.createAlias('tomas__pauta_version_id__pautas__id');

  $$PautasTableProcessedTableManager get pautaVersionId {
    final $_column = $_itemColumn<String>('pauta_version_id')!;

    final manager = $$PautasTableTableManager(
      $_db,
      $_db.pautas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pautaVersionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonasTable _personaIdTable(_$AppDatabase db) =>
      db.personas.createAlias('tomas__persona_id__personas__id');

  $$PersonasTableProcessedTableManager get personaId {
    final $_column = $_itemColumn<String>('persona_id')!;

    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ComprobacionesTable, List<ComprobacionToma>>
  _comprobacionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.comprobaciones,
    aliasName: 'tomas__id__comprobaciones__toma_id',
  );

  $$ComprobacionesTableProcessedTableManager get comprobacionesRefs {
    final manager = $$ComprobacionesTableTableManager(
      $_db,
      $_db.comprobaciones,
    ).filter((f) => f.tomaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_comprobacionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TomasTableFilterComposer extends Composer<_$AppDatabase, $TomasTable> {
  $$TomasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previstaPara => $composableBuilder(
    column: $table.previstaPara,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaLocal => $composableBuilder(
    column: $table.fechaLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horaLocal => $composableBuilder(
    column: $table.horaLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnFilters(column),
  );

  $$PautasTableFilterComposer get pautaVersionId {
    final $$PautasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pautaVersionId,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableFilterComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonasTableFilterComposer get personaId {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> comprobacionesRefs(
    Expression<bool> Function($$ComprobacionesTableFilterComposer f) f,
  ) {
    final $$ComprobacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comprobaciones,
      getReferencedColumn: (t) => t.tomaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprobacionesTableFilterComposer(
            $db: $db,
            $table: $db.comprobaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TomasTableOrderingComposer
    extends Composer<_$AppDatabase, $TomasTable> {
  $$TomasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previstaPara => $composableBuilder(
    column: $table.previstaPara,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaLocal => $composableBuilder(
    column: $table.fechaLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horaLocal => $composableBuilder(
    column: $table.horaLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadaEn => $composableBuilder(
    column: $table.creadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$PautasTableOrderingComposer get pautaVersionId {
    final $$PautasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pautaVersionId,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableOrderingComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonasTableOrderingComposer get personaId {
    final $$PersonasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableOrderingComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TomasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TomasTable> {
  $$TomasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get previstaPara => $composableBuilder(
    column: $table.previstaPara,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fechaLocal => $composableBuilder(
    column: $table.fechaLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get horaLocal =>
      $composableBuilder(column: $table.horaLocal, builder: (column) => column);

  GeneratedColumn<int> get creadaEn =>
      $composableBuilder(column: $table.creadaEn, builder: (column) => column);

  $$PautasTableAnnotationComposer get pautaVersionId {
    final $$PautasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pautaVersionId,
      referencedTable: $db.pautas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PautasTableAnnotationComposer(
            $db: $db,
            $table: $db.pautas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonasTableAnnotationComposer get personaId {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> comprobacionesRefs<T extends Object>(
    Expression<T> Function($$ComprobacionesTableAnnotationComposer a) f,
  ) {
    final $$ComprobacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comprobaciones,
      getReferencedColumn: (t) => t.tomaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprobacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.comprobaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TomasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TomasTable,
          Toma,
          $$TomasTableFilterComposer,
          $$TomasTableOrderingComposer,
          $$TomasTableAnnotationComposer,
          $$TomasTableCreateCompanionBuilder,
          $$TomasTableUpdateCompanionBuilder,
          (Toma, $$TomasTableReferences),
          Toma,
          PrefetchHooks Function({
            bool pautaVersionId,
            bool personaId,
            bool comprobacionesRefs,
          })
        > {
  $$TomasTableTableManager(_$AppDatabase db, $TomasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TomasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TomasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TomasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pautaVersionId = const Value.absent(),
                Value<String> personaId = const Value.absent(),
                Value<int> previstaPara = const Value.absent(),
                Value<String> fechaLocal = const Value.absent(),
                Value<String> horaLocal = const Value.absent(),
                Value<int> creadaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TomasCompanion(
                id: id,
                pautaVersionId: pautaVersionId,
                personaId: personaId,
                previstaPara: previstaPara,
                fechaLocal: fechaLocal,
                horaLocal: horaLocal,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pautaVersionId,
                required String personaId,
                required int previstaPara,
                required String fechaLocal,
                required String horaLocal,
                required int creadaEn,
                Value<int> rowid = const Value.absent(),
              }) => TomasCompanion.insert(
                id: id,
                pautaVersionId: pautaVersionId,
                personaId: personaId,
                previstaPara: previstaPara,
                fechaLocal: fechaLocal,
                horaLocal: horaLocal,
                creadaEn: creadaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TomasTable, Toma>(table),
                  $$TomasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pautaVersionId = false,
                personaId = false,
                comprobacionesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (comprobacionesRefs) db.comprobaciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pautaVersionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pautaVersionId,
                            referencedTable: $$TomasTableReferences
                                ._pautaVersionIdTable(db),
                            referencedColumn: $$TomasTableReferences
                                ._pautaVersionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (personaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personaId,
                            referencedTable: $$TomasTableReferences
                                ._personaIdTable(db),
                            referencedColumn: $$TomasTableReferences
                                ._personaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (comprobacionesRefs)
                        await $_getPrefetchedData<
                          Toma,
                          $TomasTable,
                          ComprobacionToma
                        >(
                          currentTable: table,
                          referencedTable: $$TomasTableReferences
                              ._comprobacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TomasTableReferences(
                                db,
                                table,
                                p0,
                              ).comprobacionesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tomaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TomasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TomasTable,
      Toma,
      $$TomasTableFilterComposer,
      $$TomasTableOrderingComposer,
      $$TomasTableAnnotationComposer,
      $$TomasTableCreateCompanionBuilder,
      $$TomasTableUpdateCompanionBuilder,
      (Toma, $$TomasTableReferences),
      Toma,
      PrefetchHooks Function({
        bool pautaVersionId,
        bool personaId,
        bool comprobacionesRefs,
      })
    >;
typedef $$ComprobacionesTableCreateCompanionBuilder =
    ComprobacionesCompanion Function({
      required String id,
      required String tomaId,
      required String clipEventoUlid,
      required String revisorMiembroId,
      required String veredicto,
      Value<String?> nota,
      required int revisadaEn,
      Value<int> rowid,
    });
typedef $$ComprobacionesTableUpdateCompanionBuilder =
    ComprobacionesCompanion Function({
      Value<String> id,
      Value<String> tomaId,
      Value<String> clipEventoUlid,
      Value<String> revisorMiembroId,
      Value<String> veredicto,
      Value<String?> nota,
      Value<int> revisadaEn,
      Value<int> rowid,
    });

final class $$ComprobacionesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ComprobacionesTable, ComprobacionToma> {
  $$ComprobacionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TomasTable _tomaIdTable(_$AppDatabase db) =>
      db.tomas.createAlias('comprobaciones__toma_id__tomas__id');

  $$TomasTableProcessedTableManager get tomaId {
    final $_column = $_itemColumn<String>('toma_id')!;

    final manager = $$TomasTableTableManager(
      $_db,
      $_db.tomas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tomaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MiembrosTable _revisorMiembroIdTable(_$AppDatabase db) => db.miembros
      .createAlias('comprobaciones__revisor_miembro_id__miembros__id');

  $$MiembrosTableProcessedTableManager get revisorMiembroId {
    final $_column = $_itemColumn<String>('revisor_miembro_id')!;

    final manager = $$MiembrosTableTableManager(
      $_db,
      $_db.miembros,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisorMiembroIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComprobacionesTableFilterComposer
    extends Composer<_$AppDatabase, $ComprobacionesTable> {
  $$ComprobacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clipEventoUlid => $composableBuilder(
    column: $table.clipEventoUlid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get veredicto => $composableBuilder(
    column: $table.veredicto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisadaEn => $composableBuilder(
    column: $table.revisadaEn,
    builder: (column) => ColumnFilters(column),
  );

  $$TomasTableFilterComposer get tomaId {
    final $$TomasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tomaId,
      referencedTable: $db.tomas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TomasTableFilterComposer(
            $db: $db,
            $table: $db.tomas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MiembrosTableFilterComposer get revisorMiembroId {
    final $$MiembrosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisorMiembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableFilterComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprobacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $ComprobacionesTable> {
  $$ComprobacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clipEventoUlid => $composableBuilder(
    column: $table.clipEventoUlid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get veredicto => $composableBuilder(
    column: $table.veredicto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisadaEn => $composableBuilder(
    column: $table.revisadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$TomasTableOrderingComposer get tomaId {
    final $$TomasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tomaId,
      referencedTable: $db.tomas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TomasTableOrderingComposer(
            $db: $db,
            $table: $db.tomas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MiembrosTableOrderingComposer get revisorMiembroId {
    final $$MiembrosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisorMiembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableOrderingComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprobacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComprobacionesTable> {
  $$ComprobacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clipEventoUlid => $composableBuilder(
    column: $table.clipEventoUlid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get veredicto =>
      $composableBuilder(column: $table.veredicto, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<int> get revisadaEn => $composableBuilder(
    column: $table.revisadaEn,
    builder: (column) => column,
  );

  $$TomasTableAnnotationComposer get tomaId {
    final $$TomasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tomaId,
      referencedTable: $db.tomas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TomasTableAnnotationComposer(
            $db: $db,
            $table: $db.tomas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MiembrosTableAnnotationComposer get revisorMiembroId {
    final $$MiembrosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisorMiembroId,
      referencedTable: $db.miembros,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MiembrosTableAnnotationComposer(
            $db: $db,
            $table: $db.miembros,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprobacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComprobacionesTable,
          ComprobacionToma,
          $$ComprobacionesTableFilterComposer,
          $$ComprobacionesTableOrderingComposer,
          $$ComprobacionesTableAnnotationComposer,
          $$ComprobacionesTableCreateCompanionBuilder,
          $$ComprobacionesTableUpdateCompanionBuilder,
          (ComprobacionToma, $$ComprobacionesTableReferences),
          ComprobacionToma,
          PrefetchHooks Function({bool tomaId, bool revisorMiembroId})
        > {
  $$ComprobacionesTableTableManager(
    _$AppDatabase db,
    $ComprobacionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprobacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprobacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprobacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tomaId = const Value.absent(),
                Value<String> clipEventoUlid = const Value.absent(),
                Value<String> revisorMiembroId = const Value.absent(),
                Value<String> veredicto = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<int> revisadaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComprobacionesCompanion(
                id: id,
                tomaId: tomaId,
                clipEventoUlid: clipEventoUlid,
                revisorMiembroId: revisorMiembroId,
                veredicto: veredicto,
                nota: nota,
                revisadaEn: revisadaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tomaId,
                required String clipEventoUlid,
                required String revisorMiembroId,
                required String veredicto,
                Value<String?> nota = const Value.absent(),
                required int revisadaEn,
                Value<int> rowid = const Value.absent(),
              }) => ComprobacionesCompanion.insert(
                id: id,
                tomaId: tomaId,
                clipEventoUlid: clipEventoUlid,
                revisorMiembroId: revisorMiembroId,
                veredicto: veredicto,
                nota: nota,
                revisadaEn: revisadaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ComprobacionesTable, ComprobacionToma>(table),
                  $$ComprobacionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tomaId = false, revisorMiembroId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tomaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tomaId,
                        referencedTable: $$ComprobacionesTableReferences
                            ._tomaIdTable(db),
                        referencedColumn: $$ComprobacionesTableReferences
                            ._tomaIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (revisorMiembroId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.revisorMiembroId,
                        referencedTable: $$ComprobacionesTableReferences
                            ._revisorMiembroIdTable(db),
                        referencedColumn: $$ComprobacionesTableReferences
                            ._revisorMiembroIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComprobacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComprobacionesTable,
      ComprobacionToma,
      $$ComprobacionesTableFilterComposer,
      $$ComprobacionesTableOrderingComposer,
      $$ComprobacionesTableAnnotationComposer,
      $$ComprobacionesTableCreateCompanionBuilder,
      $$ComprobacionesTableUpdateCompanionBuilder,
      (ComprobacionToma, $$ComprobacionesTableReferences),
      ComprobacionToma,
      PrefetchHooks Function({bool tomaId, bool revisorMiembroId})
    >;
typedef $$EventosTableCreateCompanionBuilder = EventosCompanion Function({
  required String ulid,
  required String circuloId,
  required String autor,
  required String dispositivo,
  required String tipo,
  Value<String?> sujeto,
  required int ocurridoEn,
  required int registradoEn,
  Value<String> payload,
  Value<String?> corrigeA,
  Value<int> rowid,
});
typedef $$EventosTableUpdateCompanionBuilder = EventosCompanion Function({
  Value<String> ulid,
  Value<String> circuloId,
  Value<String> autor,
  Value<String> dispositivo,
  Value<String> tipo,
  Value<String?> sujeto,
  Value<int> ocurridoEn,
  Value<int> registradoEn,
  Value<String> payload,
  Value<String?> corrigeA,
  Value<int> rowid,
});

final class $$EventosTableReferences
    extends BaseReferences<_$AppDatabase, $EventosTable, Evento> {
  $$EventosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CirculosTable _circuloIdTable(_$AppDatabase db) =>
      db.circulos.createAlias('eventos__circulo_id__circulos__id');

  $$CirculosTableProcessedTableManager get circuloId {
    final $_column = $_itemColumn<String>('circulo_id')!;

    final manager = $$CirculosTableTableManager(
      $_db,
      $_db.circulos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circuloIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventosTableFilterComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ulid => $composableBuilder(
    column: $table.ulid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autor => $composableBuilder(
    column: $table.autor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dispositivo => $composableBuilder(
    column: $table.dispositivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sujeto => $composableBuilder(
    column: $table.sujeto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocurridoEn => $composableBuilder(
    column: $table.ocurridoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get corrigeA => $composableBuilder(
    column: $table.corrigeA,
    builder: (column) => ColumnFilters(column),
  );

  $$CirculosTableFilterComposer get circuloId {
    final $$CirculosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableFilterComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableOrderingComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ulid => $composableBuilder(
    column: $table.ulid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autor => $composableBuilder(
    column: $table.autor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dispositivo => $composableBuilder(
    column: $table.dispositivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sujeto => $composableBuilder(
    column: $table.sujeto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocurridoEn => $composableBuilder(
    column: $table.ocurridoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get corrigeA => $composableBuilder(
    column: $table.corrigeA,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirculosTableOrderingComposer get circuloId {
    final $$CirculosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableOrderingComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ulid =>
      $composableBuilder(column: $table.ulid, builder: (column) => column);

  GeneratedColumn<String> get autor =>
      $composableBuilder(column: $table.autor, builder: (column) => column);

  GeneratedColumn<String> get dispositivo => $composableBuilder(
    column: $table.dispositivo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get sujeto =>
      $composableBuilder(column: $table.sujeto, builder: (column) => column);

  GeneratedColumn<int> get ocurridoEn => $composableBuilder(
    column: $table.ocurridoEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get registradoEn => $composableBuilder(
    column: $table.registradoEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get corrigeA =>
      $composableBuilder(column: $table.corrigeA, builder: (column) => column);

  $$CirculosTableAnnotationComposer get circuloId {
    final $$CirculosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circuloId,
      referencedTable: $db.circulos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirculosTableAnnotationComposer(
            $db: $db,
            $table: $db.circulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventosTable,
          Evento,
          $$EventosTableFilterComposer,
          $$EventosTableOrderingComposer,
          $$EventosTableAnnotationComposer,
          $$EventosTableCreateCompanionBuilder,
          $$EventosTableUpdateCompanionBuilder,
          (Evento, $$EventosTableReferences),
          Evento,
          PrefetchHooks Function({bool circuloId})
        > {
  $$EventosTableTableManager(_$AppDatabase db, $EventosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ulid = const Value.absent(),
                Value<String> circuloId = const Value.absent(),
                Value<String> autor = const Value.absent(),
                Value<String> dispositivo = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> sujeto = const Value.absent(),
                Value<int> ocurridoEn = const Value.absent(),
                Value<int> registradoEn = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> corrigeA = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventosCompanion(
                ulid: ulid,
                circuloId: circuloId,
                autor: autor,
                dispositivo: dispositivo,
                tipo: tipo,
                sujeto: sujeto,
                ocurridoEn: ocurridoEn,
                registradoEn: registradoEn,
                payload: payload,
                corrigeA: corrigeA,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ulid,
                required String circuloId,
                required String autor,
                required String dispositivo,
                required String tipo,
                Value<String?> sujeto = const Value.absent(),
                required int ocurridoEn,
                required int registradoEn,
                Value<String> payload = const Value.absent(),
                Value<String?> corrigeA = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventosCompanion.insert(
                ulid: ulid,
                circuloId: circuloId,
                autor: autor,
                dispositivo: dispositivo,
                tipo: tipo,
                sujeto: sujeto,
                ocurridoEn: ocurridoEn,
                registradoEn: registradoEn,
                payload: payload,
                corrigeA: corrigeA,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventosTable, Evento>(table),
                  $$EventosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({circuloId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (circuloId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.circuloId,
                        referencedTable: $$EventosTableReferences
                            ._circuloIdTable(db),
                        referencedColumn: $$EventosTableReferences
                            ._circuloIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventosTable,
      Evento,
      $$EventosTableFilterComposer,
      $$EventosTableOrderingComposer,
      $$EventosTableAnnotationComposer,
      $$EventosTableCreateCompanionBuilder,
      $$EventosTableUpdateCompanionBuilder,
      (Evento, $$EventosTableReferences),
      Evento,
      PrefetchHooks Function({bool circuloId})
    >;
typedef $$PreguntasControlTableCreateCompanionBuilder =
    PreguntasControlCompanion Function({
      required String id,
      required String personaId,
      required String tipo,
      required String texto,
      Value<String?> fraseId,
      required int lanzadaEn,
      required String origen,
      Value<int> rowid,
    });
typedef $$PreguntasControlTableUpdateCompanionBuilder =
    PreguntasControlCompanion Function({
      Value<String> id,
      Value<String> personaId,
      Value<String> tipo,
      Value<String> texto,
      Value<String?> fraseId,
      Value<int> lanzadaEn,
      Value<String> origen,
      Value<int> rowid,
    });

final class $$PreguntasControlTableReferences
    extends
        BaseReferences<_$AppDatabase, $PreguntasControlTable, PreguntaControl> {
  $$PreguntasControlTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonasTable _personaIdTable(_$AppDatabase db) =>
      db.personas.createAlias('preguntas_control__persona_id__personas__id');

  $$PersonasTableProcessedTableManager get personaId {
    final $_column = $_itemColumn<String>('persona_id')!;

    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FrasesTable _fraseIdTable(_$AppDatabase db) =>
      db.frases.createAlias('preguntas_control__frase_id__frases__id');

  $$FrasesTableProcessedTableManager? get fraseId {
    final $_column = $_itemColumn<String>('frase_id');
    if ($_column == null) return null;
    final manager = $$FrasesTableTableManager(
      $_db,
      $_db.frases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fraseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RespuestasTable, List<Respuesta>>
  _respuestasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.respuestas,
    aliasName: 'preguntas_control__id__respuestas__pregunta_id',
  );

  $$RespuestasTableProcessedTableManager get respuestasRefs {
    final manager = $$RespuestasTableTableManager(
      $_db,
      $_db.respuestas,
    ).filter((f) => f.preguntaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_respuestasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PreguntasControlTableFilterComposer
    extends Composer<_$AppDatabase, $PreguntasControlTable> {
  $$PreguntasControlTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lanzadaEn => $composableBuilder(
    column: $table.lanzadaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonasTableFilterComposer get personaId {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FrasesTableFilterComposer get fraseId {
    final $$FrasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fraseId,
      referencedTable: $db.frases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FrasesTableFilterComposer(
            $db: $db,
            $table: $db.frases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> respuestasRefs(
    Expression<bool> Function($$RespuestasTableFilterComposer f) f,
  ) {
    final $$RespuestasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.respuestas,
      getReferencedColumn: (t) => t.preguntaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RespuestasTableFilterComposer(
            $db: $db,
            $table: $db.respuestas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PreguntasControlTableOrderingComposer
    extends Composer<_$AppDatabase, $PreguntasControlTable> {
  $$PreguntasControlTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lanzadaEn => $composableBuilder(
    column: $table.lanzadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonasTableOrderingComposer get personaId {
    final $$PersonasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableOrderingComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FrasesTableOrderingComposer get fraseId {
    final $$FrasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fraseId,
      referencedTable: $db.frases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FrasesTableOrderingComposer(
            $db: $db,
            $table: $db.frases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreguntasControlTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreguntasControlTable> {
  $$PreguntasControlTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<int> get lanzadaEn =>
      $composableBuilder(column: $table.lanzadaEn, builder: (column) => column);

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  $$PersonasTableAnnotationComposer get personaId {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FrasesTableAnnotationComposer get fraseId {
    final $$FrasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fraseId,
      referencedTable: $db.frases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FrasesTableAnnotationComposer(
            $db: $db,
            $table: $db.frases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> respuestasRefs<T extends Object>(
    Expression<T> Function($$RespuestasTableAnnotationComposer a) f,
  ) {
    final $$RespuestasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.respuestas,
      getReferencedColumn: (t) => t.preguntaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RespuestasTableAnnotationComposer(
            $db: $db,
            $table: $db.respuestas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PreguntasControlTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreguntasControlTable,
          PreguntaControl,
          $$PreguntasControlTableFilterComposer,
          $$PreguntasControlTableOrderingComposer,
          $$PreguntasControlTableAnnotationComposer,
          $$PreguntasControlTableCreateCompanionBuilder,
          $$PreguntasControlTableUpdateCompanionBuilder,
          (PreguntaControl, $$PreguntasControlTableReferences),
          PreguntaControl,
          PrefetchHooks Function({
            bool personaId,
            bool fraseId,
            bool respuestasRefs,
          })
        > {
  $$PreguntasControlTableTableManager(
    _$AppDatabase db,
    $PreguntasControlTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreguntasControlTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreguntasControlTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreguntasControlTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personaId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<String?> fraseId = const Value.absent(),
                Value<int> lanzadaEn = const Value.absent(),
                Value<String> origen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreguntasControlCompanion(
                id: id,
                personaId: personaId,
                tipo: tipo,
                texto: texto,
                fraseId: fraseId,
                lanzadaEn: lanzadaEn,
                origen: origen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personaId,
                required String tipo,
                required String texto,
                Value<String?> fraseId = const Value.absent(),
                required int lanzadaEn,
                required String origen,
                Value<int> rowid = const Value.absent(),
              }) => PreguntasControlCompanion.insert(
                id: id,
                personaId: personaId,
                tipo: tipo,
                texto: texto,
                fraseId: fraseId,
                lanzadaEn: lanzadaEn,
                origen: origen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreguntasControlTable, PreguntaControl>(table),
                  $$PreguntasControlTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({personaId = false, fraseId = false, respuestasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (respuestasRefs) db.respuestas],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (personaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.personaId,
                            referencedTable: $$PreguntasControlTableReferences
                                ._personaIdTable(db),
                            referencedColumn: $$PreguntasControlTableReferences
                                ._personaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (fraseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fraseId,
                            referencedTable: $$PreguntasControlTableReferences
                                ._fraseIdTable(db),
                            referencedColumn: $$PreguntasControlTableReferences
                                ._fraseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (respuestasRefs)
                        await $_getPrefetchedData<
                          PreguntaControl,
                          $PreguntasControlTable,
                          Respuesta
                        >(
                          currentTable: table,
                          referencedTable: $$PreguntasControlTableReferences
                              ._respuestasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PreguntasControlTableReferences(
                                db,
                                table,
                                p0,
                              ).respuestasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.preguntaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PreguntasControlTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreguntasControlTable,
      PreguntaControl,
      $$PreguntasControlTableFilterComposer,
      $$PreguntasControlTableOrderingComposer,
      $$PreguntasControlTableAnnotationComposer,
      $$PreguntasControlTableCreateCompanionBuilder,
      $$PreguntasControlTableUpdateCompanionBuilder,
      (PreguntaControl, $$PreguntasControlTableReferences),
      PreguntaControl,
      PrefetchHooks Function({
        bool personaId,
        bool fraseId,
        bool respuestasRefs,
      })
    >;
typedef $$RespuestasTableCreateCompanionBuilder = RespuestasCompanion Function({
  required String id,
  required String preguntaId,
  required String valor,
  Value<String?> audioRuta,
  required int respondidaEn,
  required String origen,
  Value<double?> latitud,
  Value<double?> longitud,
  Value<int> rowid,
});
typedef $$RespuestasTableUpdateCompanionBuilder = RespuestasCompanion Function({
  Value<String> id,
  Value<String> preguntaId,
  Value<String> valor,
  Value<String?> audioRuta,
  Value<int> respondidaEn,
  Value<String> origen,
  Value<double?> latitud,
  Value<double?> longitud,
  Value<int> rowid,
});

final class $$RespuestasTableReferences
    extends BaseReferences<_$AppDatabase, $RespuestasTable, Respuesta> {
  $$RespuestasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PreguntasControlTable _preguntaIdTable(_$AppDatabase db) => db
      .preguntasControl
      .createAlias('respuestas__pregunta_id__preguntas_control__id');

  $$PreguntasControlTableProcessedTableManager get preguntaId {
    final $_column = $_itemColumn<String>('pregunta_id')!;

    final manager = $$PreguntasControlTableTableManager(
      $_db,
      $_db.preguntasControl,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_preguntaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RespuestasTableFilterComposer
    extends Composer<_$AppDatabase, $RespuestasTable> {
  $$RespuestasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioRuta => $composableBuilder(
    column: $table.audioRuta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respondidaEn => $composableBuilder(
    column: $table.respondidaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  $$PreguntasControlTableFilterComposer get preguntaId {
    final $$PreguntasControlTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntasControl,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasControlTableFilterComposer(
            $db: $db,
            $table: $db.preguntasControl,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RespuestasTableOrderingComposer
    extends Composer<_$AppDatabase, $RespuestasTable> {
  $$RespuestasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioRuta => $composableBuilder(
    column: $table.audioRuta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respondidaEn => $composableBuilder(
    column: $table.respondidaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  $$PreguntasControlTableOrderingComposer get preguntaId {
    final $$PreguntasControlTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntasControl,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasControlTableOrderingComposer(
            $db: $db,
            $table: $db.preguntasControl,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RespuestasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RespuestasTable> {
  $$RespuestasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<String> get audioRuta =>
      $composableBuilder(column: $table.audioRuta, builder: (column) => column);

  GeneratedColumn<int> get respondidaEn => $composableBuilder(
    column: $table.respondidaEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  $$PreguntasControlTableAnnotationComposer get preguntaId {
    final $$PreguntasControlTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntasControl,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasControlTableAnnotationComposer(
            $db: $db,
            $table: $db.preguntasControl,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RespuestasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RespuestasTable,
          Respuesta,
          $$RespuestasTableFilterComposer,
          $$RespuestasTableOrderingComposer,
          $$RespuestasTableAnnotationComposer,
          $$RespuestasTableCreateCompanionBuilder,
          $$RespuestasTableUpdateCompanionBuilder,
          (Respuesta, $$RespuestasTableReferences),
          Respuesta,
          PrefetchHooks Function({bool preguntaId})
        > {
  $$RespuestasTableTableManager(_$AppDatabase db, $RespuestasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RespuestasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RespuestasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RespuestasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> preguntaId = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<String?> audioRuta = const Value.absent(),
                Value<int> respondidaEn = const Value.absent(),
                Value<String> origen = const Value.absent(),
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RespuestasCompanion(
                id: id,
                preguntaId: preguntaId,
                valor: valor,
                audioRuta: audioRuta,
                respondidaEn: respondidaEn,
                origen: origen,
                latitud: latitud,
                longitud: longitud,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String preguntaId,
                required String valor,
                Value<String?> audioRuta = const Value.absent(),
                required int respondidaEn,
                required String origen,
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RespuestasCompanion.insert(
                id: id,
                preguntaId: preguntaId,
                valor: valor,
                audioRuta: audioRuta,
                respondidaEn: respondidaEn,
                origen: origen,
                latitud: latitud,
                longitud: longitud,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RespuestasTable, Respuesta>(table),
                  $$RespuestasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({preguntaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (preguntaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.preguntaId,
                        referencedTable: $$RespuestasTableReferences
                            ._preguntaIdTable(db),
                        referencedColumn: $$RespuestasTableReferences
                            ._preguntaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RespuestasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RespuestasTable,
      Respuesta,
      $$RespuestasTableFilterComposer,
      $$RespuestasTableOrderingComposer,
      $$RespuestasTableAnnotationComposer,
      $$RespuestasTableCreateCompanionBuilder,
      $$RespuestasTableUpdateCompanionBuilder,
      (Respuesta, $$RespuestasTableReferences),
      Respuesta,
      PrefetchHooks Function({bool preguntaId})
    >;
typedef $$ComidasTableCreateCompanionBuilder = ComidasCompanion Function({
  required String id,
  required String personaId,
  required String momento,
  required String cuanto,
  Value<String?> fotoId,
  Value<String?> nota,
  required int ocurridaEn,
  required String registradaPor,
  Value<int> rowid,
});
typedef $$ComidasTableUpdateCompanionBuilder = ComidasCompanion Function({
  Value<String> id,
  Value<String> personaId,
  Value<String> momento,
  Value<String> cuanto,
  Value<String?> fotoId,
  Value<String?> nota,
  Value<int> ocurridaEn,
  Value<String> registradaPor,
  Value<int> rowid,
});

final class $$ComidasTableReferences
    extends BaseReferences<_$AppDatabase, $ComidasTable, Comida> {
  $$ComidasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonasTable _personaIdTable(_$AppDatabase db) =>
      db.personas.createAlias('comidas__persona_id__personas__id');

  $$PersonasTableProcessedTableManager get personaId {
    final $_column = $_itemColumn<String>('persona_id')!;

    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FotosTable _fotoIdTable(_$AppDatabase db) =>
      db.fotos.createAlias('comidas__foto_id__fotos__id');

  $$FotosTableProcessedTableManager? get fotoId {
    final $_column = $_itemColumn<String>('foto_id');
    if ($_column == null) return null;
    final manager = $$FotosTableTableManager(
      $_db,
      $_db.fotos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fotoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComidasTableFilterComposer
    extends Composer<_$AppDatabase, $ComidasTable> {
  $$ComidasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get momento => $composableBuilder(
    column: $table.momento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuanto => $composableBuilder(
    column: $table.cuanto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocurridaEn => $composableBuilder(
    column: $table.ocurridaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registradaPor => $composableBuilder(
    column: $table.registradaPor,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonasTableFilterComposer get personaId {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableFilterComposer get fotoId {
    final $$FotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableFilterComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComidasTableOrderingComposer
    extends Composer<_$AppDatabase, $ComidasTable> {
  $$ComidasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get momento => $composableBuilder(
    column: $table.momento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuanto => $composableBuilder(
    column: $table.cuanto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocurridaEn => $composableBuilder(
    column: $table.ocurridaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registradaPor => $composableBuilder(
    column: $table.registradaPor,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonasTableOrderingComposer get personaId {
    final $$PersonasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableOrderingComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableOrderingComposer get fotoId {
    final $$FotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableOrderingComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComidasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComidasTable> {
  $$ComidasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get momento =>
      $composableBuilder(column: $table.momento, builder: (column) => column);

  GeneratedColumn<String> get cuanto =>
      $composableBuilder(column: $table.cuanto, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<int> get ocurridaEn => $composableBuilder(
    column: $table.ocurridaEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registradaPor => $composableBuilder(
    column: $table.registradaPor,
    builder: (column) => column,
  );

  $$PersonasTableAnnotationComposer get personaId {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FotosTableAnnotationComposer get fotoId {
    final $$FotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fotoId,
      referencedTable: $db.fotos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FotosTableAnnotationComposer(
            $db: $db,
            $table: $db.fotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComidasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComidasTable,
          Comida,
          $$ComidasTableFilterComposer,
          $$ComidasTableOrderingComposer,
          $$ComidasTableAnnotationComposer,
          $$ComidasTableCreateCompanionBuilder,
          $$ComidasTableUpdateCompanionBuilder,
          (Comida, $$ComidasTableReferences),
          Comida,
          PrefetchHooks Function({bool personaId, bool fotoId})
        > {
  $$ComidasTableTableManager(_$AppDatabase db, $ComidasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComidasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComidasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComidasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personaId = const Value.absent(),
                Value<String> momento = const Value.absent(),
                Value<String> cuanto = const Value.absent(),
                Value<String?> fotoId = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<int> ocurridaEn = const Value.absent(),
                Value<String> registradaPor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComidasCompanion(
                id: id,
                personaId: personaId,
                momento: momento,
                cuanto: cuanto,
                fotoId: fotoId,
                nota: nota,
                ocurridaEn: ocurridaEn,
                registradaPor: registradaPor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personaId,
                required String momento,
                required String cuanto,
                Value<String?> fotoId = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                required int ocurridaEn,
                required String registradaPor,
                Value<int> rowid = const Value.absent(),
              }) => ComidasCompanion.insert(
                id: id,
                personaId: personaId,
                momento: momento,
                cuanto: cuanto,
                fotoId: fotoId,
                nota: nota,
                ocurridaEn: ocurridaEn,
                registradaPor: registradaPor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ComidasTable, Comida>(table),
                  $$ComidasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personaId = false, fotoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personaId,
                        referencedTable: $$ComidasTableReferences
                            ._personaIdTable(db),
                        referencedColumn: $$ComidasTableReferences
                            ._personaIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (fotoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.fotoId,
                        referencedTable: $$ComidasTableReferences._fotoIdTable(
                          db,
                        ),
                        referencedColumn: $$ComidasTableReferences
                            ._fotoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComidasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComidasTable,
      Comida,
      $$ComidasTableFilterComposer,
      $$ComidasTableOrderingComposer,
      $$ComidasTableAnnotationComposer,
      $$ComidasTableCreateCompanionBuilder,
      $$ComidasTableUpdateCompanionBuilder,
      (Comida, $$ComidasTableReferences),
      Comida,
      PrefetchHooks Function({bool personaId, bool fotoId})
    >;
typedef $$HidratacionesTableCreateCompanionBuilder =
    HidratacionesCompanion Function({
      required String id,
      required String personaId,
      Value<int> vasos,
      required int ocurridaEn,
      required String registradaPor,
      Value<int> rowid,
    });
typedef $$HidratacionesTableUpdateCompanionBuilder =
    HidratacionesCompanion Function({
      Value<String> id,
      Value<String> personaId,
      Value<int> vasos,
      Value<int> ocurridaEn,
      Value<String> registradaPor,
      Value<int> rowid,
    });

final class $$HidratacionesTableReferences
    extends BaseReferences<_$AppDatabase, $HidratacionesTable, Hidratacion> {
  $$HidratacionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonasTable _personaIdTable(_$AppDatabase db) =>
      db.personas.createAlias('hidrataciones__persona_id__personas__id');

  $$PersonasTableProcessedTableManager get personaId {
    final $_column = $_itemColumn<String>('persona_id')!;

    final manager = $$PersonasTableTableManager(
      $_db,
      $_db.personas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HidratacionesTableFilterComposer
    extends Composer<_$AppDatabase, $HidratacionesTable> {
  $$HidratacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vasos => $composableBuilder(
    column: $table.vasos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocurridaEn => $composableBuilder(
    column: $table.ocurridaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registradaPor => $composableBuilder(
    column: $table.registradaPor,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonasTableFilterComposer get personaId {
    final $$PersonasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableFilterComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HidratacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $HidratacionesTable> {
  $$HidratacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vasos => $composableBuilder(
    column: $table.vasos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocurridaEn => $composableBuilder(
    column: $table.ocurridaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registradaPor => $composableBuilder(
    column: $table.registradaPor,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonasTableOrderingComposer get personaId {
    final $$PersonasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableOrderingComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HidratacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HidratacionesTable> {
  $$HidratacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get vasos =>
      $composableBuilder(column: $table.vasos, builder: (column) => column);

  GeneratedColumn<int> get ocurridaEn => $composableBuilder(
    column: $table.ocurridaEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registradaPor => $composableBuilder(
    column: $table.registradaPor,
    builder: (column) => column,
  );

  $$PersonasTableAnnotationComposer get personaId {
    final $$PersonasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personaId,
      referencedTable: $db.personas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonasTableAnnotationComposer(
            $db: $db,
            $table: $db.personas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HidratacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HidratacionesTable,
          Hidratacion,
          $$HidratacionesTableFilterComposer,
          $$HidratacionesTableOrderingComposer,
          $$HidratacionesTableAnnotationComposer,
          $$HidratacionesTableCreateCompanionBuilder,
          $$HidratacionesTableUpdateCompanionBuilder,
          (Hidratacion, $$HidratacionesTableReferences),
          Hidratacion,
          PrefetchHooks Function({bool personaId})
        > {
  $$HidratacionesTableTableManager(_$AppDatabase db, $HidratacionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HidratacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HidratacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HidratacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personaId = const Value.absent(),
                Value<int> vasos = const Value.absent(),
                Value<int> ocurridaEn = const Value.absent(),
                Value<String> registradaPor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HidratacionesCompanion(
                id: id,
                personaId: personaId,
                vasos: vasos,
                ocurridaEn: ocurridaEn,
                registradaPor: registradaPor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personaId,
                Value<int> vasos = const Value.absent(),
                required int ocurridaEn,
                required String registradaPor,
                Value<int> rowid = const Value.absent(),
              }) => HidratacionesCompanion.insert(
                id: id,
                personaId: personaId,
                vasos: vasos,
                ocurridaEn: ocurridaEn,
                registradaPor: registradaPor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HidratacionesTable, Hidratacion>(table),
                  $$HidratacionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.personaId,
                        referencedTable: $$HidratacionesTableReferences
                            ._personaIdTable(db),
                        referencedColumn: $$HidratacionesTableReferences
                            ._personaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HidratacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HidratacionesTable,
      Hidratacion,
      $$HidratacionesTableFilterComposer,
      $$HidratacionesTableOrderingComposer,
      $$HidratacionesTableAnnotationComposer,
      $$HidratacionesTableCreateCompanionBuilder,
      $$HidratacionesTableUpdateCompanionBuilder,
      (Hidratacion, $$HidratacionesTableReferences),
      Hidratacion,
      PrefetchHooks Function({bool personaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CirculosTableTableManager get circulos =>
      $$CirculosTableTableManager(_db, _db.circulos);
  $$FotosTableTableManager get fotos =>
      $$FotosTableTableManager(_db, _db.fotos);
  $$PersonasTableTableManager get personas =>
      $$PersonasTableTableManager(_db, _db.personas);
  $$MiembrosTableTableManager get miembros =>
      $$MiembrosTableTableManager(_db, _db.miembros);
  $$DispositivosTableTableManager get dispositivos =>
      $$DispositivosTableTableManager(_db, _db.dispositivos);
  $$MedicamentosTableTableManager get medicamentos =>
      $$MedicamentosTableTableManager(_db, _db.medicamentos);
  $$ConsentimientosTableTableManager get consentimientos =>
      $$ConsentimientosTableTableManager(_db, _db.consentimientos);
  $$VocesTableTableManager get voces =>
      $$VocesTableTableManager(_db, _db.voces);
  $$FrasesTableTableManager get frases =>
      $$FrasesTableTableManager(_db, _db.frases);
  $$PautasTableTableManager get pautas =>
      $$PautasTableTableManager(_db, _db.pautas);
  $$TomasTableTableManager get tomas =>
      $$TomasTableTableManager(_db, _db.tomas);
  $$ComprobacionesTableTableManager get comprobaciones =>
      $$ComprobacionesTableTableManager(_db, _db.comprobaciones);
  $$EventosTableTableManager get eventos =>
      $$EventosTableTableManager(_db, _db.eventos);
  $$PreguntasControlTableTableManager get preguntasControl =>
      $$PreguntasControlTableTableManager(_db, _db.preguntasControl);
  $$RespuestasTableTableManager get respuestas =>
      $$RespuestasTableTableManager(_db, _db.respuestas);
  $$ComidasTableTableManager get comidas =>
      $$ComidasTableTableManager(_db, _db.comidas);
  $$HidratacionesTableTableManager get hidrataciones =>
      $$HidratacionesTableTableManager(_db, _db.hidrataciones);
}
