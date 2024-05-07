import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql/client.dart';

GraphQLClient cli({String token = ''}) {
  final httpLink = HttpLink(
    '${dotenv.env["LINK_API"]}/graphql',
  );

  final authLink = AuthLink(
    getToken: () async => "Bearer ${token == '' ? dotenv.env["TOKEN"] : token}",
  );

  Link link = authLink.concat(httpLink);

  final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
  return client;
}
