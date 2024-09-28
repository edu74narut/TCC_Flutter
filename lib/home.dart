import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String dropdownvalue = 'Localização atual';
  String? latitude, longitude;
  String nome = '', cpf = '', telefone = '', observacao = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('nome') ?? '';
      cpf = prefs.getString('cpf') ?? '';
      telefone = prefs.getString('telefone') ?? '';
      observacao = prefs.getString('observacao') ?? '';
    });
  }

  Future<void> pegarPosicao() async {
    // Solicitar permissão de localização
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Mostrar uma mensagem de erro ou guia para o usuário
      print('Permissão de localização negada');
      return;
    }

    try {
      Position posicao = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = posicao.latitude.toString();
        longitude = posicao.longitude.toString();
      });

      // Certifique-se de que os valores de latitude e longitude não sejam null
      if (latitude != null && longitude != null) {
        String mensagem = '''
Preciso de ajuda;
Nome: $nome
CPF: $cpf
Telefone: $telefone
Observação: $observacao
Latitude: $latitude
Longitude: $longitude
''';

        final Uri smsUri = Uri(
          scheme: 'sms',
          path: '13996540322',
          queryParameters: {'body': mensagem},
        );

        // Tentar enviar o SMS e verificar se é possível lançar o URL
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        } else {
          print('Não foi possível enviar o SMS');
        }
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF6EEBBA),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 150, 82),
          elevation: 0,
          title: const Text('Emergência', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: dropdownvalue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                        items: <String>['Localização atual']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ElevatedButton(
                        onPressed: pegarPosicao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E8449),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emergency, size: 60, color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'CHAMAR',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
