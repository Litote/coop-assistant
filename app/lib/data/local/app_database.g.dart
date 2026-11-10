// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PurchaseLinesTable extends PurchaseLines with TableInfo<$PurchaseLinesTable, PurchaseLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
    'uom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalInclMeta = const VerificationMeta('totalIncl');
  @override
  late final GeneratedColumn<double> totalIncl = GeneratedColumn<double>(
    'total_incl',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, orderId, date, productId, productName, barcode, uom, qty, totalIncl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_lines';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseLineRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta, orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta, productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(_productNameMeta, productName.isAcceptableOrUnknown(data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta, barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('uom')) {
      context.handle(_uomMeta, uom.isAcceptableOrUnknown(data['uom']!, _uomMeta));
    } else if (isInserting) {
      context.missing(_uomMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(_qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('total_incl')) {
      context.handle(_totalInclMeta, totalIncl.isAcceptableOrUnknown(data['total_incl']!, _totalInclMeta));
    } else if (isInserting) {
      context.missing(_totalInclMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseLineRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      productId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      barcode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      uom: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uom'])!,
      qty: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}qty'])!,
      totalIncl: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}total_incl'])!,
    );
  }

  @override
  $PurchaseLinesTable createAlias(String alias) {
    return $PurchaseLinesTable(attachedDatabase, alias);
  }
}

class PurchaseLineRow extends DataClass implements Insertable<PurchaseLineRow> {
  final int id;
  final int orderId;
  final DateTime date;
  final int productId;
  final String productName;
  final String? barcode;
  final String uom;
  final double qty;
  final double totalIncl;
  const PurchaseLineRow({
    required this.id,
    required this.orderId,
    required this.date,
    required this.productId,
    required this.productName,
    this.barcode,
    required this.uom,
    required this.qty,
    required this.totalIncl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['date'] = Variable<DateTime>(date);
    map['product_id'] = Variable<int>(productId);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['uom'] = Variable<String>(uom);
    map['qty'] = Variable<double>(qty);
    map['total_incl'] = Variable<double>(totalIncl);
    return map;
  }

  PurchaseLinesCompanion toCompanion(bool nullToAbsent) {
    return PurchaseLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      date: Value(date),
      productId: Value(productId),
      productName: Value(productName),
      barcode: barcode == null && nullToAbsent ? const Value.absent() : Value(barcode),
      uom: Value(uom),
      qty: Value(qty),
      totalIncl: Value(totalIncl),
    );
  }

  factory PurchaseLineRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseLineRow(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      date: serializer.fromJson<DateTime>(json['date']),
      productId: serializer.fromJson<int>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      uom: serializer.fromJson<String>(json['uom']),
      qty: serializer.fromJson<double>(json['qty']),
      totalIncl: serializer.fromJson<double>(json['totalIncl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'date': serializer.toJson<DateTime>(date),
      'productId': serializer.toJson<int>(productId),
      'productName': serializer.toJson<String>(productName),
      'barcode': serializer.toJson<String?>(barcode),
      'uom': serializer.toJson<String>(uom),
      'qty': serializer.toJson<double>(qty),
      'totalIncl': serializer.toJson<double>(totalIncl),
    };
  }

  PurchaseLineRow copyWith({
    int? id,
    int? orderId,
    DateTime? date,
    int? productId,
    String? productName,
    Value<String?> barcode = const Value.absent(),
    String? uom,
    double? qty,
    double? totalIncl,
  }) => PurchaseLineRow(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    date: date ?? this.date,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    barcode: barcode.present ? barcode.value : this.barcode,
    uom: uom ?? this.uom,
    qty: qty ?? this.qty,
    totalIncl: totalIncl ?? this.totalIncl,
  );
  PurchaseLineRow copyWithCompanion(PurchaseLinesCompanion data) {
    return PurchaseLineRow(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      date: data.date.present ? data.date.value : this.date,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present ? data.productName.value : this.productName,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      uom: data.uom.present ? data.uom.value : this.uom,
      qty: data.qty.present ? data.qty.value : this.qty,
      totalIncl: data.totalIncl.present ? data.totalIncl.value : this.totalIncl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLineRow(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('date: $date, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('uom: $uom, ')
          ..write('qty: $qty, ')
          ..write('totalIncl: $totalIncl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, date, productId, productName, barcode, uom, qty, totalIncl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseLineRow &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.date == this.date &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.barcode == this.barcode &&
          other.uom == this.uom &&
          other.qty == this.qty &&
          other.totalIncl == this.totalIncl);
}

class PurchaseLinesCompanion extends UpdateCompanion<PurchaseLineRow> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<DateTime> date;
  final Value<int> productId;
  final Value<String> productName;
  final Value<String?> barcode;
  final Value<String> uom;
  final Value<double> qty;
  final Value<double> totalIncl;
  const PurchaseLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.date = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.uom = const Value.absent(),
    this.qty = const Value.absent(),
    this.totalIncl = const Value.absent(),
  });
  PurchaseLinesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required DateTime date,
    required int productId,
    required String productName,
    this.barcode = const Value.absent(),
    required String uom,
    required double qty,
    required double totalIncl,
  }) : orderId = Value(orderId),
       date = Value(date),
       productId = Value(productId),
       productName = Value(productName),
       uom = Value(uom),
       qty = Value(qty),
       totalIncl = Value(totalIncl);
  static Insertable<PurchaseLineRow> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<DateTime>? date,
    Expression<int>? productId,
    Expression<String>? productName,
    Expression<String>? barcode,
    Expression<String>? uom,
    Expression<double>? qty,
    Expression<double>? totalIncl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (date != null) 'date': date,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (barcode != null) 'barcode': barcode,
      if (uom != null) 'uom': uom,
      if (qty != null) 'qty': qty,
      if (totalIncl != null) 'total_incl': totalIncl,
    });
  }

  PurchaseLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? orderId,
    Value<DateTime>? date,
    Value<int>? productId,
    Value<String>? productName,
    Value<String?>? barcode,
    Value<String>? uom,
    Value<double>? qty,
    Value<double>? totalIncl,
  }) {
    return PurchaseLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      date: date ?? this.date,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      uom: uom ?? this.uom,
      qty: qty ?? this.qty,
      totalIncl: totalIncl ?? this.totalIncl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (uom.present) {
      map['uom'] = Variable<String>(uom.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (totalIncl.present) {
      map['total_incl'] = Variable<double>(totalIncl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('date: $date, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('uom: $uom, ')
          ..write('qty: $qty, ')
          ..write('totalIncl: $totalIncl')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedMeta = const VerificationMeta('feed');
  @override
  late final GeneratedColumn<String> feed = GeneratedColumn<String>(
    'feed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [feed, cursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(Insertable<SyncCursor> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed')) {
      context.handle(_feedMeta, feed.isAcceptableOrUnknown(data['feed']!, _feedMeta));
    } else if (isInserting) {
      context.missing(_feedMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta, cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feed};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      feed: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}feed'])!,
      cursor: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cursor'])!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String feed;
  final String cursor;
  const SyncCursor({required this.feed, required this.cursor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed'] = Variable<String>(feed);
    map['cursor'] = Variable<String>(cursor);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(feed: Value(feed), cursor: Value(cursor));
  }

  factory SyncCursor.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      feed: serializer.fromJson<String>(json['feed']),
      cursor: serializer.fromJson<String>(json['cursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'feed': serializer.toJson<String>(feed), 'cursor': serializer.toJson<String>(cursor)};
  }

  SyncCursor copyWith({String? feed, String? cursor}) =>
      SyncCursor(feed: feed ?? this.feed, cursor: cursor ?? this.cursor);
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      feed: data.feed.present ? data.feed.value : this.feed,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('feed: $feed, ')
          ..write('cursor: $cursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feed, cursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SyncCursor && other.feed == this.feed && other.cursor == this.cursor);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> feed;
  final Value<String> cursor;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.feed = const Value.absent(),
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({required String feed, required String cursor, this.rowid = const Value.absent()})
    : feed = Value(feed),
      cursor = Value(cursor);
  static Insertable<SyncCursor> custom({Expression<String>? feed, Expression<String>? cursor, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (feed != null) 'feed': feed,
      if (cursor != null) 'cursor': cursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({Value<String>? feed, Value<String>? cursor, Value<int>? rowid}) {
    return SyncCursorsCompanion(feed: feed ?? this.feed, cursor: cursor ?? this.cursor, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feed.present) {
      map['feed'] = Variable<String>(feed.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('feed: $feed, ')
          ..write('cursor: $cursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HiddenProductsTable extends HiddenProducts with TableInfo<$HiddenProductsTable, HiddenProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HiddenProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [productId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden_products';
  @override
  VerificationContext validateIntegrity(Insertable<HiddenProduct> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta, productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  HiddenProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HiddenProduct(
      productId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
    );
  }

  @override
  $HiddenProductsTable createAlias(String alias) {
    return $HiddenProductsTable(attachedDatabase, alias);
  }
}

class HiddenProduct extends DataClass implements Insertable<HiddenProduct> {
  final int productId;
  const HiddenProduct({required this.productId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<int>(productId);
    return map;
  }

  HiddenProductsCompanion toCompanion(bool nullToAbsent) {
    return HiddenProductsCompanion(productId: Value(productId));
  }

  factory HiddenProduct.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HiddenProduct(productId: serializer.fromJson<int>(json['productId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'productId': serializer.toJson<int>(productId)};
  }

  HiddenProduct copyWith({int? productId}) => HiddenProduct(productId: productId ?? this.productId);
  HiddenProduct copyWithCompanion(HiddenProductsCompanion data) {
    return HiddenProduct(productId: data.productId.present ? data.productId.value : this.productId);
  }

  @override
  String toString() {
    return (StringBuffer('HiddenProduct(')
          ..write('productId: $productId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => productId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HiddenProduct && other.productId == this.productId);
}

class HiddenProductsCompanion extends UpdateCompanion<HiddenProduct> {
  final Value<int> productId;
  const HiddenProductsCompanion({this.productId = const Value.absent()});
  HiddenProductsCompanion.insert({this.productId = const Value.absent()});
  static Insertable<HiddenProduct> custom({Expression<int>? productId}) {
    return RawValuesInsertable({if (productId != null) 'product_id': productId});
  }

  HiddenProductsCompanion copyWith({Value<int>? productId}) {
    return HiddenProductsCompanion(productId: productId ?? this.productId);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenProductsCompanion(')
          ..write('productId: $productId')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
    'uom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceInclMeta = const VerificationMeta('priceIncl');
  @override
  late final GeneratedColumn<double> priceIncl = GeneratedColumn<double>(
    'price_incl',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasImageMeta = const VerificationMeta('hasImage');
  @override
  late final GeneratedColumn<bool> hasImage = GeneratedColumn<bool>(
    'has_image',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("has_image" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, barcode, category, uom, priceIncl, hasImage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta, barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('uom')) {
      context.handle(_uomMeta, uom.isAcceptableOrUnknown(data['uom']!, _uomMeta));
    } else if (isInserting) {
      context.missing(_uomMeta);
    }
    if (data.containsKey('price_incl')) {
      context.handle(_priceInclMeta, priceIncl.isAcceptableOrUnknown(data['price_incl']!, _priceInclMeta));
    } else if (isInserting) {
      context.missing(_priceInclMeta);
    }
    if (data.containsKey('has_image')) {
      context.handle(_hasImageMeta, hasImage.isAcceptableOrUnknown(data['has_image']!, _hasImageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      barcode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      uom: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uom'])!,
      priceIncl: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}price_incl'])!,
      hasImage: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}has_image'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final int id;
  final String name;
  final String? barcode;
  final String category;
  final String uom;
  final double priceIncl;
  final bool hasImage;
  const ProductRow({
    required this.id,
    required this.name,
    this.barcode,
    required this.category,
    required this.uom,
    required this.priceIncl,
    required this.hasImage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['category'] = Variable<String>(category);
    map['uom'] = Variable<String>(uom);
    map['price_incl'] = Variable<double>(priceIncl);
    map['has_image'] = Variable<bool>(hasImage);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      barcode: barcode == null && nullToAbsent ? const Value.absent() : Value(barcode),
      category: Value(category),
      uom: Value(uom),
      priceIncl: Value(priceIncl),
      hasImage: Value(hasImage),
    );
  }

  factory ProductRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      category: serializer.fromJson<String>(json['category']),
      uom: serializer.fromJson<String>(json['uom']),
      priceIncl: serializer.fromJson<double>(json['priceIncl']),
      hasImage: serializer.fromJson<bool>(json['hasImage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String?>(barcode),
      'category': serializer.toJson<String>(category),
      'uom': serializer.toJson<String>(uom),
      'priceIncl': serializer.toJson<double>(priceIncl),
      'hasImage': serializer.toJson<bool>(hasImage),
    };
  }

  ProductRow copyWith({
    int? id,
    String? name,
    Value<String?> barcode = const Value.absent(),
    String? category,
    String? uom,
    double? priceIncl,
    bool? hasImage,
  }) => ProductRow(
    id: id ?? this.id,
    name: name ?? this.name,
    barcode: barcode.present ? barcode.value : this.barcode,
    category: category ?? this.category,
    uom: uom ?? this.uom,
    priceIncl: priceIncl ?? this.priceIncl,
    hasImage: hasImage ?? this.hasImage,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      category: data.category.present ? data.category.value : this.category,
      uom: data.uom.present ? data.uom.value : this.uom,
      priceIncl: data.priceIncl.present ? data.priceIncl.value : this.priceIncl,
      hasImage: data.hasImage.present ? data.hasImage.value : this.hasImage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('category: $category, ')
          ..write('uom: $uom, ')
          ..write('priceIncl: $priceIncl, ')
          ..write('hasImage: $hasImage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, barcode, category, uom, priceIncl, hasImage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.category == this.category &&
          other.uom == this.uom &&
          other.priceIncl == this.priceIncl &&
          other.hasImage == this.hasImage);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> barcode;
  final Value<String> category;
  final Value<String> uom;
  final Value<double> priceIncl;
  final Value<bool> hasImage;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.category = const Value.absent(),
    this.uom = const Value.absent(),
    this.priceIncl = const Value.absent(),
    this.hasImage = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.barcode = const Value.absent(),
    required String category,
    required String uom,
    required double priceIncl,
    this.hasImage = const Value.absent(),
  }) : name = Value(name),
       category = Value(category),
       uom = Value(uom),
       priceIncl = Value(priceIncl);
  static Insertable<ProductRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<String>? category,
    Expression<String>? uom,
    Expression<double>? priceIncl,
    Expression<bool>? hasImage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (category != null) 'category': category,
      if (uom != null) 'uom': uom,
      if (priceIncl != null) 'price_incl': priceIncl,
      if (hasImage != null) 'has_image': hasImage,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? barcode,
    Value<String>? category,
    Value<String>? uom,
    Value<double>? priceIncl,
    Value<bool>? hasImage,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      uom: uom ?? this.uom,
      priceIncl: priceIncl ?? this.priceIncl,
      hasImage: hasImage ?? this.hasImage,
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
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (uom.present) {
      map['uom'] = Variable<String>(uom.value);
    }
    if (priceIncl.present) {
      map['price_incl'] = Variable<double>(priceIncl.value);
    }
    if (hasImage.present) {
      map['has_image'] = Variable<bool>(hasImage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('category: $category, ')
          ..write('uom: $uom, ')
          ..write('priceIncl: $priceIncl, ')
          ..write('hasImage: $hasImage')
          ..write(')'))
        .toString();
  }
}

class $CataloguePricesTable extends CataloguePrices with TableInfo<$CataloguePricesTable, CataloguePriceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CataloguePricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [productId, recordedAt, price];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalogue_prices';
  @override
  VerificationContext validateIntegrity(Insertable<CataloguePriceRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta, productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(_recordedAtMeta, recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('price')) {
      context.handle(_priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId, recordedAt};
  @override
  CataloguePriceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CataloguePriceRow(
      productId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      recordedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      price: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}price'])!,
    );
  }

  @override
  $CataloguePricesTable createAlias(String alias) {
    return $CataloguePricesTable(attachedDatabase, alias);
  }
}

class CataloguePriceRow extends DataClass implements Insertable<CataloguePriceRow> {
  final int productId;
  final DateTime recordedAt;
  final double price;
  const CataloguePriceRow({required this.productId, required this.recordedAt, required this.price});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<int>(productId);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['price'] = Variable<double>(price);
    return map;
  }

  CataloguePricesCompanion toCompanion(bool nullToAbsent) {
    return CataloguePricesCompanion(productId: Value(productId), recordedAt: Value(recordedAt), price: Value(price));
  }

  factory CataloguePriceRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CataloguePriceRow(
      productId: serializer.fromJson<int>(json['productId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      price: serializer.fromJson<double>(json['price']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<int>(productId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'price': serializer.toJson<double>(price),
    };
  }

  CataloguePriceRow copyWith({int? productId, DateTime? recordedAt, double? price}) => CataloguePriceRow(
    productId: productId ?? this.productId,
    recordedAt: recordedAt ?? this.recordedAt,
    price: price ?? this.price,
  );
  CataloguePriceRow copyWithCompanion(CataloguePricesCompanion data) {
    return CataloguePriceRow(
      productId: data.productId.present ? data.productId.value : this.productId,
      recordedAt: data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      price: data.price.present ? data.price.value : this.price,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CataloguePriceRow(')
          ..write('productId: $productId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('price: $price')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, recordedAt, price);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CataloguePriceRow &&
          other.productId == this.productId &&
          other.recordedAt == this.recordedAt &&
          other.price == this.price);
}

class CataloguePricesCompanion extends UpdateCompanion<CataloguePriceRow> {
  final Value<int> productId;
  final Value<DateTime> recordedAt;
  final Value<double> price;
  final Value<int> rowid;
  const CataloguePricesCompanion({
    this.productId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.price = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CataloguePricesCompanion.insert({
    required int productId,
    required DateTime recordedAt,
    required double price,
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       recordedAt = Value(recordedAt),
       price = Value(price);
  static Insertable<CataloguePriceRow> custom({
    Expression<int>? productId,
    Expression<DateTime>? recordedAt,
    Expression<double>? price,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (price != null) 'price': price,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CataloguePricesCompanion copyWith({
    Value<int>? productId,
    Value<DateTime>? recordedAt,
    Value<double>? price,
    Value<int>? rowid,
  }) {
    return CataloguePricesCompanion(
      productId: productId ?? this.productId,
      recordedAt: recordedAt ?? this.recordedAt,
      price: price ?? this.price,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CataloguePricesCompanion(')
          ..write('productId: $productId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('price: $price, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingItemsTable extends ShoppingItems with TableInfo<$ShoppingItemsTable, ShoppingItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedMeta = const VerificationMeta('checked');
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
    'checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("checked" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, productId, label, quantity, checked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_items';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingItemRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta, productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta, quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('checked')) {
      context.handle(_checkedMeta, checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItemRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}product_id']),
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      quantity: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      checked: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}checked'])!,
    );
  }

  @override
  $ShoppingItemsTable createAlias(String alias) {
    return $ShoppingItemsTable(attachedDatabase, alias);
  }
}

class ShoppingItemRow extends DataClass implements Insertable<ShoppingItemRow> {
  final int id;
  final int? productId;
  final String label;
  final double quantity;
  final bool checked;
  const ShoppingItemRow({
    required this.id,
    this.productId,
    required this.label,
    required this.quantity,
    required this.checked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['label'] = Variable<String>(label);
    map['quantity'] = Variable<double>(quantity);
    map['checked'] = Variable<bool>(checked);
    return map;
  }

  ShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingItemsCompanion(
      id: Value(id),
      productId: productId == null && nullToAbsent ? const Value.absent() : Value(productId),
      label: Value(label),
      quantity: Value(quantity),
      checked: Value(checked),
    );
  }

  factory ShoppingItemRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItemRow(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int?>(json['productId']),
      label: serializer.fromJson<String>(json['label']),
      quantity: serializer.fromJson<double>(json['quantity']),
      checked: serializer.fromJson<bool>(json['checked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int?>(productId),
      'label': serializer.toJson<String>(label),
      'quantity': serializer.toJson<double>(quantity),
      'checked': serializer.toJson<bool>(checked),
    };
  }

  ShoppingItemRow copyWith({
    int? id,
    Value<int?> productId = const Value.absent(),
    String? label,
    double? quantity,
    bool? checked,
  }) => ShoppingItemRow(
    id: id ?? this.id,
    productId: productId.present ? productId.value : this.productId,
    label: label ?? this.label,
    quantity: quantity ?? this.quantity,
    checked: checked ?? this.checked,
  );
  ShoppingItemRow copyWithCompanion(ShoppingItemsCompanion data) {
    return ShoppingItemRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      label: data.label.present ? data.label.value : this.label,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      checked: data.checked.present ? data.checked.value : this.checked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('label: $label, ')
          ..write('quantity: $quantity, ')
          ..write('checked: $checked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, label, quantity, checked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItemRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.label == this.label &&
          other.quantity == this.quantity &&
          other.checked == this.checked);
}

class ShoppingItemsCompanion extends UpdateCompanion<ShoppingItemRow> {
  final Value<int> id;
  final Value<int?> productId;
  final Value<String> label;
  final Value<double> quantity;
  final Value<bool> checked;
  const ShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.label = const Value.absent(),
    this.quantity = const Value.absent(),
    this.checked = const Value.absent(),
  });
  ShoppingItemsCompanion.insert({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    required String label,
    required double quantity,
    this.checked = const Value.absent(),
  }) : label = Value(label),
       quantity = Value(quantity);
  static Insertable<ShoppingItemRow> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<String>? label,
    Expression<double>? quantity,
    Expression<bool>? checked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (label != null) 'label': label,
      if (quantity != null) 'quantity': quantity,
      if (checked != null) 'checked': checked,
    });
  }

  ShoppingItemsCompanion copyWith({
    Value<int>? id,
    Value<int?>? productId,
    Value<String>? label,
    Value<double>? quantity,
    Value<bool>? checked,
  }) {
    return ShoppingItemsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      label: label ?? this.label,
      quantity: quantity ?? this.quantity,
      checked: checked ?? this.checked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('label: $label, ')
          ..write('quantity: $quantity, ')
          ..write('checked: $checked')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PurchaseLinesTable purchaseLines = $PurchaseLinesTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $HiddenProductsTable hiddenProducts = $HiddenProductsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CataloguePricesTable cataloguePrices = $CataloguePricesTable(this);
  late final $ShoppingItemsTable shoppingItems = $ShoppingItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    purchaseLines,
    syncCursors,
    hiddenProducts,
    products,
    cataloguePrices,
    shoppingItems,
  ];
}

typedef $$PurchaseLinesTableCreateCompanionBuilder =
    PurchaseLinesCompanion Function({
      Value<int> id,
      required int orderId,
      required DateTime date,
      required int productId,
      required String productName,
      Value<String?> barcode,
      required String uom,
      required double qty,
      required double totalIncl,
    });
typedef $$PurchaseLinesTableUpdateCompanionBuilder =
    PurchaseLinesCompanion Function({
      Value<int> id,
      Value<int> orderId,
      Value<DateTime> date,
      Value<int> productId,
      Value<String> productName,
      Value<String?> barcode,
      Value<String> uom,
      Value<double> qty,
      Value<double> totalIncl,
    });

class $$PurchaseLinesTableFilterComposer extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName =>
      $composableBuilder(column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uom => $composableBuilder(column: $table.uom, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qty => $composableBuilder(column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalIncl =>
      $composableBuilder(column: $table.totalIncl, builder: (column) => ColumnFilters(column));
}

class $$PurchaseLinesTableOrderingComposer extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName =>
      $composableBuilder(column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uom =>
      $composableBuilder(column: $table.uom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalIncl =>
      $composableBuilder(column: $table.totalIncl, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseLinesTableAnnotationComposer extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId => $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get productId => $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName =>
      $composableBuilder(column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get barcode => $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get uom => $composableBuilder(column: $table.uom, builder: (column) => column);

  GeneratedColumn<double> get qty => $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<double> get totalIncl => $composableBuilder(column: $table.totalIncl, builder: (column) => column);
}

class $$PurchaseLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseLinesTable,
          PurchaseLineRow,
          $$PurchaseLinesTableFilterComposer,
          $$PurchaseLinesTableOrderingComposer,
          $$PurchaseLinesTableAnnotationComposer,
          $$PurchaseLinesTableCreateCompanionBuilder,
          $$PurchaseLinesTableUpdateCompanionBuilder,
          (PurchaseLineRow, BaseReferences<_$AppDatabase, $PurchaseLinesTable, PurchaseLineRow>),
          PurchaseLineRow,
          PrefetchHooks Function()
        > {
  $$PurchaseLinesTableTableManager(_$AppDatabase db, $PurchaseLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PurchaseLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PurchaseLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PurchaseLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> orderId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> uom = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<double> totalIncl = const Value.absent(),
              }) => PurchaseLinesCompanion(
                id: id,
                orderId: orderId,
                date: date,
                productId: productId,
                productName: productName,
                barcode: barcode,
                uom: uom,
                qty: qty,
                totalIncl: totalIncl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int orderId,
                required DateTime date,
                required int productId,
                required String productName,
                Value<String?> barcode = const Value.absent(),
                required String uom,
                required double qty,
                required double totalIncl,
              }) => PurchaseLinesCompanion.insert(
                id: id,
                orderId: orderId,
                date: date,
                productId: productId,
                productName: productName,
                barcode: barcode,
                uom: uom,
                qty: qty,
                totalIncl: totalIncl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseLinesTable, PurchaseLineRow>(table),
                  BaseReferences<_$AppDatabase, $PurchaseLinesTable, PurchaseLineRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchaseLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseLinesTable,
      PurchaseLineRow,
      $$PurchaseLinesTableFilterComposer,
      $$PurchaseLinesTableOrderingComposer,
      $$PurchaseLinesTableAnnotationComposer,
      $$PurchaseLinesTableCreateCompanionBuilder,
      $$PurchaseLinesTableUpdateCompanionBuilder,
      (PurchaseLineRow, BaseReferences<_$AppDatabase, $PurchaseLinesTable, PurchaseLineRow>),
      PurchaseLineRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({required String feed, required String cursor, Value<int> rowid});
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({Value<String> feed, Value<String> cursor, Value<int> rowid});

class $$SyncCursorsTableFilterComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feed => $composableBuilder(column: $table.feed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableOrderingComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feed =>
      $composableBuilder(column: $table.feed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feed => $composableBuilder(column: $table.feed, builder: (column) => column);

  GeneratedColumn<String> get cursor => $composableBuilder(column: $table.cursor, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feed = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(feed: feed, cursor: cursor, rowid: rowid),
          createCompanionCallback:
              ({required String feed, required String cursor, Value<int> rowid = const Value.absent()}) =>
                  SyncCursorsCompanion.insert(feed: feed, cursor: cursor, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$HiddenProductsTableCreateCompanionBuilder = HiddenProductsCompanion Function({Value<int> productId});
typedef $$HiddenProductsTableUpdateCompanionBuilder = HiddenProductsCompanion Function({Value<int> productId});

class $$HiddenProductsTableFilterComposer extends Composer<_$AppDatabase, $HiddenProductsTable> {
  $$HiddenProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnFilters(column));
}

class $$HiddenProductsTableOrderingComposer extends Composer<_$AppDatabase, $HiddenProductsTable> {
  $$HiddenProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnOrderings(column));
}

class $$HiddenProductsTableAnnotationComposer extends Composer<_$AppDatabase, $HiddenProductsTable> {
  $$HiddenProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get productId => $composableBuilder(column: $table.productId, builder: (column) => column);
}

class $$HiddenProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HiddenProductsTable,
          HiddenProduct,
          $$HiddenProductsTableFilterComposer,
          $$HiddenProductsTableOrderingComposer,
          $$HiddenProductsTableAnnotationComposer,
          $$HiddenProductsTableCreateCompanionBuilder,
          $$HiddenProductsTableUpdateCompanionBuilder,
          (HiddenProduct, BaseReferences<_$AppDatabase, $HiddenProductsTable, HiddenProduct>),
          HiddenProduct,
          PrefetchHooks Function()
        > {
  $$HiddenProductsTableTableManager(_$AppDatabase db, $HiddenProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$HiddenProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$HiddenProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$HiddenProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({Value<int> productId = const Value.absent()}) =>
              HiddenProductsCompanion(productId: productId),
          createCompanionCallback: ({Value<int> productId = const Value.absent()}) =>
              HiddenProductsCompanion.insert(productId: productId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HiddenProductsTable, HiddenProduct>(table),
                  BaseReferences<_$AppDatabase, $HiddenProductsTable, HiddenProduct>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HiddenProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HiddenProductsTable,
      HiddenProduct,
      $$HiddenProductsTableFilterComposer,
      $$HiddenProductsTableOrderingComposer,
      $$HiddenProductsTableAnnotationComposer,
      $$HiddenProductsTableCreateCompanionBuilder,
      $$HiddenProductsTableUpdateCompanionBuilder,
      (HiddenProduct, BaseReferences<_$AppDatabase, $HiddenProductsTable, HiddenProduct>),
      HiddenProduct,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> barcode,
      required String category,
      required String uom,
      required double priceIncl,
      Value<bool> hasImage,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> barcode,
      Value<String> category,
      Value<String> uom,
      Value<double> priceIncl,
      Value<bool> hasImage,
    });

class $$ProductsTableFilterComposer extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uom => $composableBuilder(column: $table.uom, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceIncl =>
      $composableBuilder(column: $table.priceIncl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasImage =>
      $composableBuilder(column: $table.hasImage, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uom =>
      $composableBuilder(column: $table.uom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceIncl =>
      $composableBuilder(column: $table.priceIncl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasImage =>
      $composableBuilder(column: $table.hasImage, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode => $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get category => $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get uom => $composableBuilder(column: $table.uom, builder: (column) => column);

  GeneratedColumn<double> get priceIncl => $composableBuilder(column: $table.priceIncl, builder: (column) => column);

  GeneratedColumn<bool> get hasImage => $composableBuilder(column: $table.hasImage, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> uom = const Value.absent(),
                Value<double> priceIncl = const Value.absent(),
                Value<bool> hasImage = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                barcode: barcode,
                category: category,
                uom: uom,
                priceIncl: priceIncl,
                hasImage: hasImage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> barcode = const Value.absent(),
                required String category,
                required String uom,
                required double priceIncl,
                Value<bool> hasImage = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                barcode: barcode,
                category: category,
                uom: uom,
                priceIncl: priceIncl,
                hasImage: hasImage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRow>(table),
                  BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$CataloguePricesTableCreateCompanionBuilder =
    CataloguePricesCompanion Function({
      required int productId,
      required DateTime recordedAt,
      required double price,
      Value<int> rowid,
    });
typedef $$CataloguePricesTableUpdateCompanionBuilder =
    CataloguePricesCompanion Function({
      Value<int> productId,
      Value<DateTime> recordedAt,
      Value<double> price,
      Value<int> rowid,
    });

class $$CataloguePricesTableFilterComposer extends Composer<_$AppDatabase, $CataloguePricesTable> {
  $$CataloguePricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt =>
      $composableBuilder(column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => ColumnFilters(column));
}

class $$CataloguePricesTableOrderingComposer extends Composer<_$AppDatabase, $CataloguePricesTable> {
  $$CataloguePricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt =>
      $composableBuilder(column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => ColumnOrderings(column));
}

class $$CataloguePricesTableAnnotationComposer extends Composer<_$AppDatabase, $CataloguePricesTable> {
  $$CataloguePricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get productId => $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt =>
      $composableBuilder(column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<double> get price => $composableBuilder(column: $table.price, builder: (column) => column);
}

class $$CataloguePricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CataloguePricesTable,
          CataloguePriceRow,
          $$CataloguePricesTableFilterComposer,
          $$CataloguePricesTableOrderingComposer,
          $$CataloguePricesTableAnnotationComposer,
          $$CataloguePricesTableCreateCompanionBuilder,
          $$CataloguePricesTableUpdateCompanionBuilder,
          (CataloguePriceRow, BaseReferences<_$AppDatabase, $CataloguePricesTable, CataloguePriceRow>),
          CataloguePriceRow,
          PrefetchHooks Function()
        > {
  $$CataloguePricesTableTableManager(_$AppDatabase db, $CataloguePricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CataloguePricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CataloguePricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CataloguePricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> productId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CataloguePricesCompanion(productId: productId, recordedAt: recordedAt, price: price, rowid: rowid),
          createCompanionCallback:
              ({
                required int productId,
                required DateTime recordedAt,
                required double price,
                Value<int> rowid = const Value.absent(),
              }) => CataloguePricesCompanion.insert(
                productId: productId,
                recordedAt: recordedAt,
                price: price,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CataloguePricesTable, CataloguePriceRow>(table),
                  BaseReferences<_$AppDatabase, $CataloguePricesTable, CataloguePriceRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CataloguePricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CataloguePricesTable,
      CataloguePriceRow,
      $$CataloguePricesTableFilterComposer,
      $$CataloguePricesTableOrderingComposer,
      $$CataloguePricesTableAnnotationComposer,
      $$CataloguePricesTableCreateCompanionBuilder,
      $$CataloguePricesTableUpdateCompanionBuilder,
      (CataloguePriceRow, BaseReferences<_$AppDatabase, $CataloguePricesTable, CataloguePriceRow>),
      CataloguePriceRow,
      PrefetchHooks Function()
    >;
typedef $$ShoppingItemsTableCreateCompanionBuilder =
    ShoppingItemsCompanion Function({
      Value<int> id,
      Value<int?> productId,
      required String label,
      required double quantity,
      Value<bool> checked,
    });
typedef $$ShoppingItemsTableUpdateCompanionBuilder =
    ShoppingItemsCompanion Function({
      Value<int> id,
      Value<int?> productId,
      Value<String> label,
      Value<double> quantity,
      Value<bool> checked,
    });

class $$ShoppingItemsTableFilterComposer extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => ColumnFilters(column));
}

class $$ShoppingItemsTableOrderingComposer extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => ColumnOrderings(column));
}

class $$ShoppingItemsTableAnnotationComposer extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId => $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get quantity => $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get checked => $composableBuilder(column: $table.checked, builder: (column) => column);
}

class $$ShoppingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingItemsTable,
          ShoppingItemRow,
          $$ShoppingItemsTableFilterComposer,
          $$ShoppingItemsTableOrderingComposer,
          $$ShoppingItemsTableAnnotationComposer,
          $$ShoppingItemsTableCreateCompanionBuilder,
          $$ShoppingItemsTableUpdateCompanionBuilder,
          (ShoppingItemRow, BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItemRow>),
          ShoppingItemRow,
          PrefetchHooks Function()
        > {
  $$ShoppingItemsTableTableManager(_$AppDatabase db, $ShoppingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ShoppingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<bool> checked = const Value.absent(),
              }) => ShoppingItemsCompanion(
                id: id,
                productId: productId,
                label: label,
                quantity: quantity,
                checked: checked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                required String label,
                required double quantity,
                Value<bool> checked = const Value.absent(),
              }) => ShoppingItemsCompanion.insert(
                id: id,
                productId: productId,
                label: label,
                quantity: quantity,
                checked: checked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShoppingItemsTable, ShoppingItemRow>(table),
                  BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItemRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShoppingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingItemsTable,
      ShoppingItemRow,
      $$ShoppingItemsTableFilterComposer,
      $$ShoppingItemsTableOrderingComposer,
      $$ShoppingItemsTableAnnotationComposer,
      $$ShoppingItemsTableCreateCompanionBuilder,
      $$ShoppingItemsTableUpdateCompanionBuilder,
      (ShoppingItemRow, BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItemRow>),
      ShoppingItemRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PurchaseLinesTableTableManager get purchaseLines => $$PurchaseLinesTableTableManager(_db, _db.purchaseLines);
  $$SyncCursorsTableTableManager get syncCursors => $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$HiddenProductsTableTableManager get hiddenProducts => $$HiddenProductsTableTableManager(_db, _db.hiddenProducts);
  $$ProductsTableTableManager get products => $$ProductsTableTableManager(_db, _db.products);
  $$CataloguePricesTableTableManager get cataloguePrices =>
      $$CataloguePricesTableTableManager(_db, _db.cataloguePrices);
  $$ShoppingItemsTableTableManager get shoppingItems => $$ShoppingItemsTableTableManager(_db, _db.shoppingItems);
}
