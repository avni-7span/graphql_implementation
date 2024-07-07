import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_implementation/country-model/CountryModel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final countryQuery = '''
      query ExampleQuery {
      countries {
      name
      emoji
      code
    }
    }''';
  bool _isLoading = false;
  CountryData? _model;
  CountryModel? selectedValue;

  final HttpLink httpLink =
      HttpLink('https://countries.trevorblades.com/graphql');
  late final GraphQLClient _graphQLClient;

  void fetchData() async {
    setState(() {
      _isLoading = true;
    });
    QueryResult queryResult = await _graphQLClient.query(
      QueryOptions(
        document: gql(countryQuery),
      ),
    );
    final data = queryResult.data;
    if (data != null) {
      final result = CountryData.fromJson(data);
      setState(() {
        _model = result;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _graphQLClient = GraphQLClient(link: httpLink, cache: GraphQLCache());
    fetchData();
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
          ? const CircularProgressIndicator()
          : _model?.countries == null
              ? const Center(
                  child: Text(
                    'Failed to load Data',
                    style: TextStyle(fontSize: 30, color: Colors.red),
                  ),
                )
              : Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.only(right: 10, left: 10, top: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DropdownButton<CountryModel>(
                            dropdownColor: Colors.grey.shade200,
                            isExpanded: true,
                            value: selectedValue,
                            items: _model?.countries
                                .map<DropdownMenuItem<CountryModel>>(
                                  (CountryModel value) =>
                                      DropdownMenuItem<CountryModel>(
                                    value: value,
                                    child: Text(value.name ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (CountryModel? newValue) {
                              setState(() {
                                selectedValue = newValue;
                              });
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              Text(
                                'country code : ${selectedValue?.code}',
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.blue),
                              ),
                              Text(
                                'country flag : ${selectedValue?.emoji}',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
