part of nuxeo_client;

/** Annotation used to register business adapters. */
class EntityType {
  final String name;
  const EntityType(this.name);
}

/**
 * BusinessAdapter
 */
class BusinessAdapter {
  static final _classMirrors = {};

  /// Register a [BusinessAdapter] for a given [Type]
  static register(Type clazz) {
    ClassMirror cm = reflectClass(clazz);
    var entityType = cm.metadata.first.reflectee;
    _classMirrors[entityType.name] = cm;
  }

  /// Get the [EntityType] of a class
  static EntityType entityTypeOf(Type clazz) {
    ClassMirror cm = reflectClass(clazz);
    return cm.metadata.first.reflectee;
  }

  /// Get the registered [Type]
  static Type typeOf(String type) {
    return _classMirrors[type].reflectedType;
  }

  /// Creates a [BusinessAdapter] from JSON
  static fromJSON(Map json) {
    var entityType = json["entity-type"];

    if (entityType == null) {
      return null;
    }

    ClassMirror cm = _classMirrors[entityType];

    if (cm == null) {
      return null;
    }

    // Invoke default constructor
    var instance = cm.newInstance(const Symbol(''), []);
    // Set all the fields
    json["value"].forEach((k, v) {
      instance.setField(new Symbol(k), v);
    });
    return instance.reflectee;
  }
}