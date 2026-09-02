class ValidationResult {
  final bool isValid;
  final List<String> errors;
  const ValidationResult(this.isValid, this.errors);
  const ValidationResult.valid() : isValid = true, errors = const [];
  ValidationResult.invalid(List<String> errs) : isValid = false, errors = errs;
}

class SduiValidator {
  static const supportedVersion = '1.0';

  static ValidationResult validate(Map<String, dynamic> json) {
    final errors = <String>[];
    if (json.containsKey('version') && json['version'] is! String) {
      errors.add('version must be a string');
    }
    // Handle new entire app screen format: {screenName, layout, components: []}
    if (json.containsKey('components') && json['components'] is List) {
      final comps = json['components'] as List;
      for (var i = 0; i < comps.length; i++) {
        final c = comps[i];
        if (c is! Map) {
          errors.add('components[$i]: must be an object');
        } else {
          final r = validateNode(Map<String, dynamic>.from(c as Map), path: 'components[$i]');
          errors.addAll(r.errors);
        }
      }
      return errors.isEmpty ? const ValidationResult.valid() : ValidationResult.invalid(errors);
    }
    if (json.containsKey('root')) {
      if (json['root'] is! Map) {
        errors.add('root must be an object');
      } else {
        final r = validateNode(Map<String, dynamic>.from(json['root'] as Map), path: 'root');
        errors.addAll(r.errors);
      }
    } else {
      final r = validateNode(json, path: 'root');
      errors.addAll(r.errors);
    }
    return errors.isEmpty ? const ValidationResult.valid() : ValidationResult.invalid(errors);
  }

  static ValidationResult validateNode(Map<String, dynamic> node, {required String path}) {
    final errors = <String>[];
    final type = node['type'];
    if (type == null) {
      errors.add('$path: missing required field "type"');
    } else if (type is! String || (type as String).isEmpty) {
      errors.add('$path: type must be a non-empty string');
    }
    if (node.containsKey('props') && node['props'] is! Map) {
      errors.add('$path: props must be an object');
    }
    if (node.containsKey('style') && node['style'] is! Map) {
      errors.add('$path: style must be an object');
    }
    if (node.containsKey('events') && node['events'] is! Map) {
      errors.add('$path: events must be an object');
    }
    // children: optional array
    if (node.containsKey('children')) {
      final children = node['children'];
      if (children is! List) {
        errors.add('$path: children must be an array');
      } else {
        for (var i = 0; i < children.length; i++) {
          final child = children[i];
          if (child is! Map) {
            errors.add('$path.children[$i]: must be an object');
          } else {
            final r = validateNode(Map<String, dynamic>.from(child as Map), path: '$path.children[$i]');
            errors.addAll(r.errors);
          }
        }
      }
    }
    // child: optional single object or array
    if (node.containsKey('child')) {
      final child = node['child'];
      if (child is Map) {
        final r = validateNode(Map<String, dynamic>.from(child as Map), path: '$path.child');
        errors.addAll(r.errors);
      } else if (child is List) {
        for (var i = 0; i < child.length; i++) {
          final c = child[i];
          if (c is! Map) {
            errors.add('$path.child[$i]: must be an object');
          } else {
            final r = validateNode(Map<String, dynamic>.from(c as Map), path: '$path.child[$i]');
            errors.addAll(r.errors);
          }
        }
      } else {
        errors.add('$path: child must be an object or array');
      }
    }
    return errors.isEmpty ? const ValidationResult.valid() : ValidationResult.invalid(errors);
  }
}
