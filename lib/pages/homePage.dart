import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/viagemPage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.grey[750],
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Color(0xFFE5E5EA),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        color: Color(0xFFF5F7FA),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 1),
            search(),
            SizedBox(height: 30),
            Text(
              "Opções de Menu",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.grey[750],
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 90,
              child: listaCategorias(),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Historico de Viagens",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              height: 300,
              child: listaProdutos(context),
            )
          ],
        ),
      ),
    );
  }

  // Função para a barra de pesquisa
  Widget search() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 15),
          Icon(Icons.search),
          SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: "Busca",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para a lista de categorias
  Widget listaCategorias(){
    return Container(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          categoriaItens(),
          categoriaItens(),
          categoriaItens(),
          categoriaItens(),
          categoriaItens(),
        ],
      ),
    );
  }

  // Função para os itens da lista de categorias
  Widget categoriaItens(){
    return Container(
      width: 70,
      height: 70,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          new BoxShadow(
            color: Colors.black12,
            offset: new Offset(1, 7.0),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(64),
      ),
      child: Image.asset("assets/relatorio.png"),
    );
  }

  // Função para a lista de produtos
  Widget listaProdutos(BuildContext context) {
    return Container(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          produtoItem(context),
          produtoItem(context),
          produtoItem(context),
          produtoItem(context),
          produtoItem(context),
          produtoItem(context),
        ],
      ),
    );
  }

  // Função para os itens da lista de produtos
  Widget produtoItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViagemPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        height: 100,
        color: Colors.grey[300],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.calendar_today, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "Data da Viagem",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Icon(Icons.title, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "Título da Viagem",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}