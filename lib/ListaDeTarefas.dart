import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ListaDeTarefas extends StatefulWidget {
  @override
  _ListaDeTarefasState createState() => _ListaDeTarefasState();
}

class _ListaDeTarefasState extends State<ListaDeTarefas> {

  TextEditingController _novaTarefa = TextEditingController();
  List _listaDeTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() async {
    String textoDigitado = _novaTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaDeTarefas.add(tarefa);
    });
    _salvarArquivo();
    _novaTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = json.encode(_listaDeTarefas);
    arquivo.writeAsStringSync(dados);
//    print("Carminho: " + diretorio.path);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerArquivo().then((dados) {
      setState(() {
        _listaDeTarefas = jsonDecode(dados);
      });
    });
  }

  Widget _CriarItemLista(context, index) {

    final item = _listaDeTarefas[index]["titulo"];

    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {

        _ultimaTarefaRemovida = _listaDeTarefas[index];
        _listaDeTarefas.removeAt(index);
        _salvarArquivo();

        //snackbar
        final snackbar = SnackBar(
          content: Text("Tarefa Removida"),
          duration: Duration(seconds: 5),
//          backgroundColor: Colors.green,
          action:
          SnackBarAction(
              label: "Desfazer",
              onPressed: (){ //Insere novamente item removido na lista
                setState(() {
                  _listaDeTarefas.insert(index, _ultimaTarefaRemovida);
                  });
            _salvarArquivo();
          }
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Color(0xFFe10000),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),

      child: CheckboxListTile(
        title: Text(_listaDeTarefas[index]["titulo"],
          style: TextStyle(
            fontSize: 20
          ),),
        value: _listaDeTarefas[index]["realizada"],
        onChanged: (valorAlterado) {
          setState(() {
            _listaDeTarefas[index]["realizada"] = valorAlterado;
          });
          _salvarArquivo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _listaDeTarefas.length,
                itemBuilder: (context, index) {
                  return _CriarItemLista(context, index);

//                  return ListTile(
//                    title: Text(_listaDeTarefas[index]["titulo"]),
//                  );
                }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 2,
//          mini: true,
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Adicionar Tarefa"),
                    content: TextField(
                      decoration:
                          InputDecoration(labelText: "Digite sua Tarefa"),
                      onChanged: (text) {},
                      controller: _novaTarefa,
                    ),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar")),
                      FlatButton(
                          onPressed: () {
                            _salvarTarefa();
                            Navigator.pop(context);
                          },
                          child: Text("Salvar")),
                    ],
                  );
                });
          }),
//      bottomNavigationBar: BottomNavigationBar(items: ,),
    );
  }
}
