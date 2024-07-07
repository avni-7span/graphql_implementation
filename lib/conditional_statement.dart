import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'country-model/CountryModel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CountryData? model;
  bool _isLoading = false;

  final countryQuery = '''
      query ExampleQuery {
      countries {
      name
      emoji
      code
    }
    }''';

  void fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final httpLink = HttpLink('https://countries.trevorblades.com/graphql');
    final qlClient = GraphQLClient(link: httpLink, cache: GraphQLCache());
    QueryResult queryResult = await qlClient.query(QueryOptions(
      document: gql(countryQuery),
    ));
    final data = queryResult.data;
    if (data != null) {
      final result = CountryData.fromJson(data);
      //print(result);
      setState(() {
        model = result;
        _isLoading = false;
      });
    } else {
      // Show error message
    }

    //print(queryResult);
    //print(model.runtimeType);

    setState(() {
      _isLoading = false;
    });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : model?.countries == null
              ? Center(
                  child: ElevatedButton(
                  onPressed: () {
                    fetchData();
                    //print("on pressed List : $countries");
                  },
                  child: const Text('Fetch Data'),
                ))
              : ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: model?.countries.length,
                  itemBuilder: (context, index) {
                    final country = model?.countries[index];
                    return ListTile(
                      title: Text(country?.name ?? ''),
                      subtitle: Text(country?.code ?? ''),
                    );
                  },
                ),
    );
  }
}
