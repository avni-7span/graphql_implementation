import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'country-model/CountryModel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<CountryData?>? _future;

  final countryQuery = '''
      query ExampleQuery {
      countries {
      name
      emoji
      code
    }
    }''';

  final httpLink = HttpLink('https://countries.trevorblades.com/graphql');
  late final GraphQLClient _graphQLClient;

  @override
  void initState() {
    super.initState();

    _graphQLClient = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    _future = fetchData();
  }

  Future<CountryData?> fetchData() async {
    QueryResult queryResult = await _graphQLClient.query(
      QueryOptions(
        document: gql(countryQuery),
      ),
    );

    final data = queryResult.data;
    if (data != null) {
      final result = CountryData.fromJson(
        data,
      );
      return result;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GraphQl",
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: _future,
                builder: (context, snapShot) {
                  if (snapShot.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not fetch data!')));
                  }
                  if (snapShot.connectionState == ConnectionState.done) {
                    if (snapShot.hasData) {
                      final model = snapShot.data;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: model?.countries.length,
                        itemBuilder: (context, index) {
                          final country = model?.countries[index];
                          return ListTile(
                            leading: Text(country?.emoji ?? ''),
                            title: Text(country?.name ?? ''),
                            subtitle: Text(country?.code ?? ''),
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could\'nt fetch data!',
                          ),
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return const SizedBox();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
