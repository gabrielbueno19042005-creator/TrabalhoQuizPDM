import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importação do dotenv
import 'quiz.dart';

Future<void> main() async {
  // Garante a inicialização dos bindings antes de carregar o arquivo
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o arquivo de configuração visível na barra lateral
  await dotenv.load(fileName: "chave.env");

  runApp(const QuizApp());
}

// --- PALETA DE CORES (Azul Noturno e Laranja) ---
const Color primaryColor = Color(0xFF0F2027); // Fundo escuro topo
const Color secondaryColor = Color(0xFF203A43); // Fundo escuro base
const Color accentColor = Color(0xFFFFA726); // Laranja para botões e destaque
const Color darkTextColor = Color(0xFF1A1A1A); // Texto escuro para os cartões

// --- MODELO DE DADOS ---
class Question {
  final String question;
  final List<String> options;
  final int correctIndex;

  Question(this.question, this.options, this.correctIndex);
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Master',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: const HomeScreen(),
    );
  }
}

// Fundo Degradê Reaproveitável
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, secondaryColor],
        ),
      ),
      child: child,
    );
  }
}

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.psychology, size: 90, color: accentColor),
        const SizedBox(height: 10),
        Text(
          "QUIZ MASTER",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppTitle(),
              const SizedBox(height: 80),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ThemeScreen()));
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "TOQUE PARA INICIAR",
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> temas = [
      {"nome": "Jogos", "icone": Icons.sports_esports},
      {"nome": "Filmes", "icone": Icons.movie_filter},
      {"nome": "Esportes", "icone": Icons.sports_soccer},
      {"nome": "Música", "icone": Icons.headphones},
      {"nome": "Geografia", "icone": Icons.public},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Escolha um Tema",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...temas.map((theme) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkTextColor,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      QuizScreen(theme: theme["nome"])),
                            );
                          },
                          icon: Icon(theme["icone"], color: accentColor),
                          label: Text(
                            theme["nome"],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String theme;
  const QuizScreen({super.key, required this.theme});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();

  late Future<List<Question>> _futureQuestions;
  List<Question> _listaDeQuestoes = [];

  int _perguntaAtual = 1;
  final int _limitePerguntas = 5;
  int _acertos = 0;
  int _erros = 0;

  bool _respondeu = false;
  int _indiceSelecionado = -1;

  @override
  void initState() {
    super.initState();
    _futureQuestions = _carregarQuestoes();
  }

  Future<List<Question>> _carregarQuestoes() async {
    final dataList =
        await _quizService.gerarQuestoes(widget.theme, _limitePerguntas);
    return dataList
        .map((data) => Question(
              data['pergunta'],
              List<String>.from(data['opcoes']),
              data['correta'],
            ))
        .toList();
  }

  void _proximaPergunta() {
    if (_perguntaAtual < _limitePerguntas) {
      setState(() {
        _perguntaAtual++;
      });
    } else {
      _mostrarFimDoQuiz();
    }
  }

  void _mostrarFimDoQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text("Fim do Quiz!",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _acertos >= 3 ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              size: 70,
              color: _acertos >= 3 ? accentColor : Colors.grey,
            ),
            const SizedBox(height: 15),
            Text(
              "Você acertou $_acertos",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            Text(
              "Você errou $_erros",
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              "Total: $_limitePerguntas perguntas sobre ${widget.theme}.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("JOGAR NOVAMENTE", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Questão $_perguntaAtual/$_limitePerguntas",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: FutureBuilder<List<Question>>(
            future: _futureQuestions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: accentColor),
                      const SizedBox(height: 20),
                      Text("Gerando quiz de ${widget.theme}...",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 60),
                        const SizedBox(height: 20),
                        const Text(
                          "Ocorreu um problema ao carregar o Quiz.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Detalhe: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _futureQuestions = _carregarQuestoes();
                            });
                          },
                          child: const Text("Tentar Novamente"),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                if (_listaDeQuestoes.isEmpty) {
                  _listaDeQuestoes = snapshot.data!;
                }

                final question = _listaDeQuestoes[_perguntaAtual - 1];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _perguntaAtual / _limitePerguntas,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(accentColor),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Card(
                              elevation: 8,
                              shadowColor: Colors.black45,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Text(
                                  question.question,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            ...List.generate(question.options.length, (index) {
                              Color corFundo = Colors.white;
                              Color corTexto = darkTextColor;

                              if (_respondeu) {
                                if (index == question.correctIndex) {
                                  corFundo = Colors.green.shade600;
                                  corTexto = Colors.white;
                                } else if (index == _indiceSelecionado) {
                                  corFundo = Colors.red.shade600;
                                  corTexto = Colors.white;
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: corFundo,
                                      foregroundColor: corTexto,
                                      disabledBackgroundColor: corFundo,
                                      disabledForegroundColor: corTexto,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: _respondeu
                                        ? null
                                        : () {
                                            setState(() {
                                              _respondeu = true;
                                              _indiceSelecionado = index;

                                              bool acertou = index ==
                                                  question.correctIndex;
                                              if (acertou) {
                                                _acertos++;
                                              } else {
                                                _erros++;
                                              }

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  content: Row(
                                                    children: [
                                                      Icon(
                                                        acertou
                                                            ? Icons.check_circle
                                                            : Icons.cancel,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        acertou
                                                            ? "Resposta Correta!"
                                                            : "Resposta Errada!",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: acertou
                                                      ? Colors.green.shade600
                                                      : Colors.red.shade600,
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                ),
                                              );
                                            });

                                            Future.delayed(
                                              const Duration(
                                                  milliseconds: 2000),
                                              () {
                                                if (mounted) {
                                                  setState(() {
                                                    _respondeu = false;
                                                    _indiceSelecionado = -1;
                                                  });
                                                  _proximaPergunta();
                                                }
                                              },
                                            );
                                          },
                                    child: Text(
                                      question.options[index],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
