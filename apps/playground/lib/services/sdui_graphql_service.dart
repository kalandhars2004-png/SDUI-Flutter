import 'package:graphql_flutter/graphql_flutter.dart';

// Pure GraphQL — strictly API level, MySQL is behind Java service
class SduiTemplateModel {
  final String id;
  final String name;
  final String json;
  final String? version;
  final String? createdAt;
  final String? updatedAt;
  SduiTemplateModel({required this.id, required this.name, required this.json, this.version, this.createdAt, this.updatedAt});
  factory SduiTemplateModel.fromJson(Map<String, dynamic> m) => SduiTemplateModel(
        id: m['id'] as String,
        name: m['name'] as String,
        json: m['json'] as String,
        version: m['version'] as String?,
        createdAt: m['createdAt'] as String?,
        updatedAt: m['updatedAt'] as String?,
      );
}

class SduiGraphqlService {
  final GraphQLClient client;
  SduiGraphqlService(this.client);

  factory SduiGraphqlService.create({String endpoint = 'http://127.0.0.1:8080/graphql'}) {
    final link = HttpLink(endpoint);
    final client = GraphQLClient(link: link, cache: GraphQLCache(store: InMemoryStore()));
    return SduiGraphqlService(client);
  }

  static const _templatesQuery = r'''
    query Templates { templates { id name json version createdAt updatedAt } }
  ''';

  static const _templateQuery = r'''
    query Template($id: ID!) { template(id: $id) { id name json version createdAt updatedAt } }
  ''';

  static const _saveMutation = r'''
    mutation SaveTemplate($name: String!, $json: String!) {
      saveTemplate(name: $name, json: $json) { id name json version createdAt updatedAt }
    }
  ''';

  static const _updateMutation = r'''
    mutation UpdateTemplate($id: ID!, $name: String, $json: String) {
      updateTemplate(id: $id, name: $name, json: $json) { id name json version createdAt updatedAt }
    }
  ''';

  static const _deleteMutation = r'''
    mutation DeleteTemplate($id: ID!) { deleteTemplate(id: $id) }
  ''';

  Future<List<SduiTemplateModel>> fetchTemplates() async {
    final result = await client.query(QueryOptions(document: gql(_templatesQuery), fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw Exception(result.exception.toString());
    final list = result.data?['templates'] as List? ?? [];
    return list.map((e) => SduiTemplateModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<SduiTemplateModel?> fetchTemplate(String id) async {
    final result = await client.query(QueryOptions(document: gql(_templateQuery), variables: {'id': id}));
    if (result.hasException) throw Exception(result.exception.toString());
    final data = result.data?['template'];
    if (data == null) return null;
    return SduiTemplateModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<SduiTemplateModel> saveTemplate({required String name, required String json}) async {
    final result = await client.mutate(MutationOptions(document: gql(_saveMutation), variables: {'name': name, 'json': json}));
    if (result.hasException) throw Exception(result.exception.toString());
    return SduiTemplateModel.fromJson(Map<String, dynamic>.from(result.data!['saveTemplate'] as Map));
  }

  Future<SduiTemplateModel> updateTemplate({required String id, String? name, String? json}) async {
    final result = await client.mutate(MutationOptions(document: gql(_updateMutation), variables: {'id': id, 'name': name, 'json': json}));
    if (result.hasException) throw Exception(result.exception.toString());
    return SduiTemplateModel.fromJson(Map<String, dynamic>.from(result.data!['updateTemplate'] as Map));
  }

  Future<bool> deleteTemplate(String id) async {
    final result = await client.mutate(MutationOptions(document: gql(_deleteMutation), variables: {'id': id}));
    if (result.hasException) throw Exception(result.exception.toString());
    return result.data?['deleteTemplate'] as bool? ?? false;
  }
}
