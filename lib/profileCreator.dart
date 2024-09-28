import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'navigator.dart';

class ProfileCreatorPage extends StatefulWidget {
  final List<String> usuario;

  const ProfileCreatorPage({super.key, required this.usuario});

  @override
  State<ProfileCreatorPage> createState() => ProfileCreatorPageState();
}

class ProfileCreatorPageState extends State<ProfileCreatorPage> {
  final _textNome = TextEditingController();
  final _textCPF = TextEditingController();
  final _textTelefone = TextEditingController();
  final _textObservacao = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Preencher os campos com os dados existentes do usuário
    _textNome.text = widget.usuario.isNotEmpty ? widget.usuario[0] : '';
    _textCPF.text = widget.usuario.length > 1 ? widget.usuario[1] : '';
    _textTelefone.text = widget.usuario.length > 2 ? widget.usuario[2] : '';
    _textObservacao.text = widget.usuario.length > 3 ? widget.usuario[3] : '';
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _textNome.text = prefs.getString('nome') ?? '';
      _textCPF.text = prefs.getString('cpf') ?? '';
      _textTelefone.text = prefs.getString('telefone') ?? '';
      _textObservacao.text = prefs.getString('observacao') ?? '';
      String? imagePath = prefs.getString('imagePath');
      _image = File(imagePath!);
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', _textNome.text);
    await prefs.setString('cpf', _textCPF.text);
    await prefs.setString('telefone', _textTelefone.text);
    await prefs.setString('observacao', _textObservacao.text);
    if (_image != null) {
      await prefs.setString('imagePath', _image!.path);
    }
    
    // Atualiza a lista de usuário
    widget.usuario
      ..clear()
      ..addAll([_textNome.text, _textCPF.text, _textTelefone.text, _textObservacao.text]);
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6EEBBA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 150, 82),
        elevation: 0,
        title: const Text('Criação de Perfil',
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Escolher da galeria'),
                                onTap: () {
                                  getImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: const Text('Tirar uma foto'),
                                onTap: () {
                                  getImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.add_a_photo,
                            size: 40, color: Color(0xFF6EEBBA))
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildTextField(_textNome, 'Nome', Icons.person),
                        const SizedBox(height: 20),
                        _buildTextField(_textCPF, 'CPF', Icons.credit_card),
                        const SizedBox(height: 20),
                        _buildTextField(_textTelefone, 'Telefone', Icons.phone),
                        const SizedBox(height: 20),
                        _buildTextField(
                            _textObservacao, 'Observações', Icons.note,
                            maxLines: 3),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_textNome.text.isEmpty || _textCPF.text.isEmpty || _textTelefone.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
                      );
                      return;
                    }

                    await _saveUserData();

                    // Retorna os dados atualizados
                    Navigator.of(context).pop(widget.usuario);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 15, 150, 82),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Salvar Perfil', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 15, 150, 82)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}