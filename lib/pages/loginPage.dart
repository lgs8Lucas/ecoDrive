import 'package:flutter/material.dart';
import 'package:projeto_app/pages/homePage.dart';

class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Color(0xfff5f5f5),
          padding: EdgeInsets.only(
            top: 80,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: Column(children: <Widget> [
              Container(
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow:[
                    new BoxShadow(
                      color: Colors.black12,
                      offset: new Offset(1, 7.0),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text("Login",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,  // Cor do texto.
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                Text("Logue para continuar"),
                              ],
                            ),
                            TextButton (
                              child: Text("Login"),
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            // Remove preenchimento de fundo
                            filled: false,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey), // Cor da linha inferior
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2), // Cor ao focar
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira seu email';
                            }
                            return null;
                          },
                       ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.password),
                            // Remove preenchimento de fundo
                            filled: false,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey), // Cor da linha inferior
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2), // Cor ao focar
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira sua senha';
                            }
                            return null;
                         },
                      ),
                     ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}